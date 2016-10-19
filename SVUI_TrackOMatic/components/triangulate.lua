--[[
##########################################################
S V U I   By: S.Jackson
##########################################################
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local unpack    = _G.unpack;
local select    = _G.select;
local pairs     = _G.pairs;
local type      = _G.type;
local tostring  = _G.tostring;
local tonumber  = _G.tonumber;
local rawset    = _G.rawset;
local rawget    = _G.rawget;
local tinsert   = _G.tinsert;
local tremove   = _G.tremove;
local string    = _G.string;
local math      = _G.math;
local bit       = _G.bit;
local table     = _G.table;
--[[ STRING METHODS ]]--
local format, find, lower, match = string.format, string.find, string.lower, string.match;
--[[ MATH METHODS ]]--
local abs, ceil, floor, round = math.abs, math.ceil, math.floor, math.round;  -- Basic
local fmod, modf, sqrt = math.fmod, math.modf, math.sqrt;   -- Algebra
local atan2, cos, deg, rad, sin = math.atan2, math.cos, math.deg, math.rad, math.sin;  -- Trigonometry
local min, huge, random = math.min, math.huge, math.random;  -- Uncommon
local sqrt2, max = math.sqrt(2), math.max;
--[[ TABLE METHODS ]]--
local tcopy, twipe, tsort, tconcat, tdump = table.copy, table.wipe, table.sort, table.concat, table.dump;
--[[ BINARY METHODS ]]--
local band = bit.band;
--BLIZZARD API
local InCombatLockdown      = _G.InCombatLockdown;
local SetMapZoom            = _G.SetMapZoom;
local SetMapToCurrentZone   = _G.SetMapToCurrentZone;
local ZoomOut               = _G.ZoomOut;
local SetMapByID            = _G.SetMapByID;
local SetDungeonMapLevel    = _G.SetDungeonMapLevel;
local QuestPOIGetIconInfo   = _G.QuestPOIGetIconInfo;
local WORLDMAP_WORLD_ID     = _G.WORLDMAP_WORLD_ID;
local WorldMapFrame         = _G.WorldMapFrame;
local GetCurrentMapDungeonLevel   = _G.GetCurrentMapDungeonLevel;
--[[
##########################################################
LOCALS
##########################################################
]]--
local radian90 = (3.141592653589793 / 2) * -1;
local WORLDMAPAREA_DEFAULT_DUNGEON_FLOOR_IS_TERRAIN = 0x00000004
local WORLDMAPAREA_VIRTUAL_CONTINENT = 0x00000008
local DUNGEONMAP_MICRO_DUNGEON = 0x00000001
--[[
##########################################################
LOCALIZED BLIZZARD FUNCTIONS
##########################################################
]]--
local GetMapInfo = GetMapInfo
local GetMapZones = GetMapZones
local GetPlayerFacing = GetPlayerFacing
local GetCurrentMapZone = GetCurrentMapZone
local GetCurrentMapAreaID = GetCurrentMapAreaID
local GetPlayerMapPosition = GetPlayerMapPosition
local GetNumDungeonMapLevels = GetNumDungeonMapLevels
local GetCurrentMapContinent = GetCurrentMapContinent
local GetWorldMapTransformInfo = GetWorldMapTransformInfo
--[[
##########################################################
MAPPING DATA STORAGE
##########################################################
]]--
local DUNGEON_DATA = {};
local GEOGRAPHICAL_DATA = {
    [0] = {
        height = 22266.74312,
        system = -1,
        width = 33400.121,
        xOffset = 0,
        yOffset = 0,
        [1] = {
            xOffset = -10311.71318,
            yOffset = -19819.33898,
            scale = 0.56089997291565,
        },
        [0] = {
            xOffset = -48226.86993,
            yOffset = -16433.90283,
            scale = 0.56300002336502,
        },
        [571] = {
            xOffset = -29750.89905,
            yOffset = -11454.50802,
            scale = 0.5949000120163,
        },
        [870] = {
            xOffset = -27693.71178,
            yOffset = -29720.0585,
            scale = 0.65140002965927,
        },
    },
}


do
    local backup_cache, temp_cache, swap_cache = {}, {}, {};

    local meta_backup = {
        xOffset = 0,
        height = 1,
        yOffset = 0,
        width = 1,
        __index = function(t, k)
            if(type(k) == "number") then
                return backup_cache;
            else
                return rawget(backup_cache, k);
            end
        end
    };

    setmetatable(backup_cache, meta_backup);
    setmetatable(GEOGRAPHICAL_DATA, backup_cache);

    local transforms = GetWorldMapTransforms()

    for _,id in ipairs(transforms) do
        local terrain, newterrain, _, _, transformMinY, transformMaxY, transformMinX, transformMaxX, offsetY, offsetX = GetWorldMapTransformInfo(id)
        if ( offsetX ~= 0 or offsetY ~= 0 ) then
            swap_cache[id] = {
                terrain = terrain,
                newterrain = newterrain,
                BRy = -transformMinY,
                TLy = -transformMaxY,
                BRx = -transformMinX,
                TLx = -transformMaxX,
                offsetY = offsetY,
                offsetX = offsetX,
            }
        end
    end

    local function SetTempData()
        local map = {}
        local mapName = GetMapInfo();
        local id = GetCurrentMapAreaID();
        local numFloors = GetNumDungeonMapLevels();
        map.mapName = mapName;
        map.cont = (GetCurrentMapContinent()) or -100;
        map.zone = (GetCurrentMapZone()) or -100;
        map.numFloors = numFloors;
        local _, TLx, TLy, BRx, BRy = GetCurrentMapZone();
        if(TLx and TLy and BRx and BRy and (TLx~=0 or TLy~=0 or BRx~=0 or BRy~=0)) then
            map[0] = {};
            map[0].TLx = TLx;
            map[0].TLy = TLy;
            map[0].BRx = BRx;
            map[0].BRy = BRy;
        end
        if(not map[0] and numFloors == 0 and (GetCurrentMapDungeonLevel()) == 1) then
            numFloors = 1;
            map.hiddenFloor = true;
        end
        if(numFloors > 0) then
            for i = 1, numFloors do
                SetDungeonMapLevel(i);
                local _, TLx, TLy, BRx, BRy = GetCurrentMapDungeonLevel();
                if(TLx and TLy and BRx and BRy) then
                    map[i] = {};
                    map[i].TLx = TLx;
                    map[i].TLy = TLy;
                    map[i].BRx = BRx;
                    map[i].BRy = BRy;
                end
            end
        end

        temp_cache[id] = map;
    end

    local continent_map_data = { GetMapContinents() };

    for continent in pairs(continent_map_data) do
        local zone_map_data = { GetMapZones(continent) };
        continent_map_data[continent] = zone_map_data;
        local pass, error = pcall(SetMapZoom, continent, 0)
        if(pass) then
            zone_map_data[0] = GetCurrentMapAreaID();
            SetTempData();
            for zone in ipairs(zone_map_data) do
                SetMapZoom(continent, zone);
                zone_map_data[zone] = GetCurrentMapAreaID();
                SetTempData();
            end
        end
    end

    local area_maps = GetAreaMaps()

    for _,id in ipairs(area_maps) do
        if((not temp_cache[id]) and SetMapByID(id)) then
            SetTempData();
        end
    end

    for id, map in pairs(temp_cache) do
        local terrain, _, _, _, _, _, _, _, _, flags = GetAreaMapInfo(id)
        local origin = terrain;
        local data = GEOGRAPHICAL_DATA[id];
        if not (data) then data = {}; end
        if(map.numFloors > 0 or map.hiddenFloor) then
            for f, coords in pairs(map) do
                if(type(f) == "number" and f > 0) then
                    if not (data[f]) then
                        data[f] = {};
                    end
                    local flr = data[f]
                    local TLx, TLy, BRx, BRy = -coords.BRx, -coords.BRy, -coords.TLx, -coords.TLy
                    if not (flr.width) then
                        flr.width = BRx - TLx
                    end
                    if not (flr.height) then
                        flr.height = BRy - TLy
                    end
                    if not (flr.xOffset) then
                        flr.xOffset = TLx
                    end
                    if not (flr.yOffset) then
                        flr.yOffset = TLy
                    end
                end
            end
            for f = 1, map.numFloors do
                if not (data[f]) then
                    if(f == 1 and map[0] and map[0].TLx and map[0].TLy and map[0].BRx and map[0].BRy and
                      band(flags, WORLDMAPAREA_DEFAULT_DUNGEON_FLOOR_IS_TERRAIN) == WORLDMAPAREA_DEFAULT_DUNGEON_FLOOR_IS_TERRAIN) then
                        data[f] = {};
                        local flr = data[f]
                        local coords = map[0]
                        local TLx, TLy, BRx, BRy = -coords.TLx, -coords.TLy, -coords.BRx, -coords.BRy
                        flr.width = BRx - TLx
                        flr.height = BRy - TLy
                        flr.xOffset = TLx
                        flr.yOffset = TLy
                    end
                end
            end
            if(map.hiddenFloor) then
                data.width = data[1].width
                data.height = data[1].height
                data.xOffset = data[1].xOffset
                data.yOffset = data[1].yOffset
            end
        else
            local coords = map[0]
            if(coords ~= nil) then
                local TLx, TLy, BRx, BRy = -coords.TLx, -coords.TLy, -coords.BRx, -coords.BRy
                for _, trans in pairs(swap_cache) do
                    if(trans.terrain == terrain) then
                        if((trans.TLx < TLx and BRx < trans.BRx) and (trans.TLy < TLy and BRy < trans.BRy)) then
                            TLx = TLx - trans.offsetX;
                            BRx = BRx - trans.offsetX;
                            BRy = BRy - trans.offsetY;
                            TLy = TLy - trans.offsetY;
                            terrain = trans.newterrain;
                            break;
                        end
                    end
                end
                if not (TLx==0 and TLy==0 and BRx==0 and BRy==0) then
                    if not (TLx < BRx) then
                        printError("Bad x-axis Orientation (Zone): ", id, TLx, BRx);
                    end
                    if not (TLy < BRy) then
                        printError("Bad y-axis Orientation (Zone): ", id, TLy, BRy);
                    end
                end
                if not (data.width) then
                    data.width = BRx - TLx
                end
                if not (data.height) then
                    data.height = BRy - TLy
                end
                if not (data.xOffset) then
                    data.xOffset = TLx
                end
                if not (data.yOffset) then
                    data.yOffset = TLy
                end
            end
        end

        if(not next(data, nil)) then
            data = { xOffset = 0, height = 1, yOffset = 0, width = 1 };
        end

        if(not data.origin) then
            data.origin = origin;
        end

        GEOGRAPHICAL_DATA[id] = data;

        if(data and data ~= backup_cache) then
            if(not data.system) then
                data.system = terrain;
            end
            if(map.cont > 0 and map.zone > 0) then
                DUNGEON_DATA[terrain] = {}
            end
            setmetatable(data, backup_cache);
        end
    end
end

local function GetCoordinates(map, mapFloor, x, y)
    if not map then return 0,0 end
    if (mapFloor ~= 0) then
        map = rawget(map, mapFloor) or DUNGEON_DATA[map.origin][mapFloor];
    end
    if not map then return 0,0 end
    x = x * map.width + map.xOffset;
    y = y * map.height + map.yOffset;
    return x, y;
end

local function GetDistance(map1, floor1, x1, y1, map2, floor2, x2, y2)
    if not (map1 and map2) then return end
    floor1 = floor1 or min(#GEOGRAPHICAL_DATA[map1], 1);
    floor2 = floor2 or min(#GEOGRAPHICAL_DATA[map2], 1);
    local dist, xDelta, yDelta, angle;
    if(map1 == map2 and floor1 == floor2) then
        local chunk = GEOGRAPHICAL_DATA[map1];
        if(not chunk) then
            xDelta = 0;
            yDelta = 0;
        else
            local tmp = chunk
            if(floor1 ~= 0) then
                tmp = rawget(chunk, floor1)
            end
            local w,h = 1,1
            if(not tmp) then
                if(DUNGEON_DATA[chunk.origin] and DUNGEON_DATA[chunk.origin][floor1]) then
                    chunk = DUNGEON_DATA[chunk.origin][floor1]
                    w = chunk.width
                    h = chunk.height
                else
                    w = 1
                    h = 1
                end
            else
                w = chunk.width
                h = chunk.height
            end
            xDelta = (x2 - x1) * (w or 1);
            yDelta = (y2 - y1) * (h or 1);
        end
    else
        local mapX = GEOGRAPHICAL_DATA[map1];
        local mapY = GEOGRAPHICAL_DATA[map2];

        if(mapX.system == mapY.system) then
            x1, y1 = GetCoordinates(mapX, floor1, x1, y1);
            x2, y2 = GetCoordinates(mapY, floor2, x2, y2);
            xDelta = (x2 - x1);
            yDelta = (y2 - y1);
        else
            local s1 = mapX.system;
            local s2 = mapY.system;
            if((mapX==0 or GEOGRAPHICAL_DATA[0][s1]) and (mapY == 0 or GEOGRAPHICAL_DATA[0][s2])) then
                x1, y1 = GetCoordinates(mapX, floor1, x1, y1);
                x2, y2 = GetCoordinates(mapY, floor2, x2, y2);
                if(mapX ~= 0) then
                    local cont1 = GEOGRAPHICAL_DATA[0][s1];
                    x1 = (x1 - cont1.xOffset) * cont1.scale;
                    y1 = (y1 - cont1.yOffset) * cont1.scale;
                end
                if(mapY ~= 0) then
                    local cont2 = GEOGRAPHICAL_DATA[0][s2];
                    x2 = (x2 - cont2.xOffset) * cont2.scale;
                    y2 = (y2 - cont2.yOffset) * cont2.scale;
                end
                xDelta = x2 - x1;
                yDelta = y2 - y1;
            end
        end
    end

    if(xDelta and yDelta) then
        local playerAngle = GetPlayerFacing()
        dist = sqrt(xDelta * xDelta + yDelta * yDelta);
        angle = (radian90 - playerAngle) - atan2(yDelta, xDelta)
    end

    return dist, angle;
end

_G.TriangulateUnit = function(unit, noMapLocation)
    if(WorldMapFrame and WorldMapFrame:IsShown()) then return end

    local plot1, plot2, plot3, plot4, plot5, plot6, plot7, plot8;

    plot3, plot4 = GetPlayerMapPosition("player");

    if(plot3 <= 0 and plot4 <= 0) then
        SetMapToCurrentZone();
        plot3, plot4 = GetPlayerMapPosition("player");
        if(plot3 <= 0 and plot4 <= 0) then
                if(ZoomOut()) then
                elseif(GetCurrentMapZone() ~= WORLDMAP_WORLD_ID) then
                    SetMapZoom(GetCurrentMapContinent());
                else
                    SetMapZoom(WORLDMAP_WORLD_ID);
                end
            plot3, plot4 = GetPlayerMapPosition("player");
            if(plot3 <= 0 and plot4 <= 0) then
                return;
            end
        end
    end

    plot1 = GetCurrentMapAreaID()
    plot2 = GetCurrentMapDungeonLevel()
    plot7, plot8 = GetPlayerMapPosition(unit);

    if(noMapLocation and (plot7 <= 0 and plot8 <= 0)) then
        local lastMapID, lastFloor = GetCurrentMapAreaID(), GetCurrentMapDungeonLevel();
        SetMapToCurrentZone();
        plot7, plot8 = GetPlayerMapPosition(unit);

        if(plot7 <= 0 and plot8 <= 0) then
                if(ZoomOut()) then
                elseif(GetCurrentMapZone() ~= WORLDMAP_WORLD_ID) then
                    SetMapZoom(GetCurrentMapContinent());
                else
                    SetMapZoom(WORLDMAP_WORLD_ID);
                end
            plot7, plot8 = GetPlayerMapPosition(unit);
            if(plot7 <= 0 and plot8 <= 0) then
                return;
            end
        end

        plot5, plot6 = GetCurrentMapAreaID(), GetCurrentMapDungeonLevel();

        if(plot5 ~= lastMapID or plot6 ~= lastFloor) then
            SetMapByID(lastMapID);
            SetDungeonMapLevel(lastFloor);
        end

        return GetDistance(plot1, plot2, plot3, plot4, plot5, plot6, plot7, plot8)
    end

    return GetDistance(plot1, plot2, plot3, plot4, plot1, plot2, plot7, plot8)
end

--QuestPOIGetIconInfo(questID)

_G.TriangulateQuest = function(questID)
    --print(questID)
    if(WorldMapFrame and WorldMapFrame:IsShown()) then return end

    local _, debug, plot1, plot2, plot3, plot4, plot5, plot6, plot7, plot8;

    plot3, plot4 = GetPlayerMapPosition("player");

    if(plot3 <= 0 and plot4 <= 0) then
        SetMapToCurrentZone();
        plot3, plot4 = GetPlayerMapPosition("player");
        if(plot3 <= 0 and plot4 <= 0) then
                if(ZoomOut()) then
                elseif(GetCurrentMapZone() ~= WORLDMAP_WORLD_ID) then
                    SetMapZoom(GetCurrentMapContinent());
                else
                    SetMapZoom(WORLDMAP_WORLD_ID);
                end
            plot3, plot4 = GetPlayerMapPosition("player");
            if(plot3 <= 0 and plot4 <= 0) then
                return;
            end
        end
    end

    plot1 = GetCurrentMapAreaID()
    plot2 = GetCurrentMapDungeonLevel()
    _, plot7, plot8, _ = QuestPOIGetIconInfo(questID);
    if((not plot7) or (not plot8)) then
        local mapID, floorNumber = GetQuestWorldMapAreaID(questID)
        SetMapByID(mapID)
        _, plot7, plot8, _ = QuestPOIGetIconInfo(questID);
        if((not plot7) or (not plot8)) then return end
    end
    return GetDistance(plot1, plot2, plot3, plot4, plot1, plot2, plot7, plot8)
end
