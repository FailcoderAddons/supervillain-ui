--[[
##########################################################
S V U I   By: S.Jackson
##########################################################
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local unpack            = _G.unpack;
local select            = _G.select;
local assert            = _G.assert;
local type              = _G.type;
local error             = _G.error;
local pcall             = _G.pcall;
local print             = _G.print;
local ipairs            = _G.ipairs;
local pairs             = _G.pairs;
local next              = _G.next;
local tostring          = _G.tostring;
local tonumber          = _G.tonumber;
local collectgarbage    = _G.collectgarbage;
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
local CreateFrame           = _G.CreateFrame;
local IsInRaid              = _G.IsInRaid;
local IsInGroup             = _G.IsInGroup;
local IsInInstance          = _G.IsInInstance;
local UnitName              = _G.UnitName;
local UnitAura              = _G.UnitAura;
local UnitBuff              = _G.UnitBuff;
local UnitStat              = _G.UnitStat;
local UnitRace              = _G.UnitRace;
local UnitLevel             = _G.UnitLevel;
local UnitClass             = _G.UnitClass;
local UnitReaction          = _G.UnitReaction;
local UnitExists            = _G.UnitExists;
local UnitIsUnit            = _G.UnitIsUnit;
local UnitInRaid            = _G.UnitInRaid;
local UnitInParty           = _G.UnitInParty;
local UnitInRange           = _G.UnitInRange;
local GetMouseFocus         = _G.GetMouseFocus;
local UnitIsConnected       = _G.UnitIsConnected;
local GetNumGroupMembers    = _G.GetNumGroupMembers;
--[[
##########################################################
GET ADDON DATA
##########################################################
]]--
local SV = _G["SVUI"];
local L = SV.L;
local PLUGIN = select(2, ...);
local CONFIGS = SV.defaults[PLUGIN.Schema];

local GPS_UpdateHandler = CreateFrame("Frame");

local playerGUID = UnitGUID("player")
local _FRAMES, _PROXIMITY = {}, {}
local minThrottle = 0.02
local numArrows, inRange, GPS
local TriangulateUnit = TriangulateUnit
local NewHook = hooksecurefunc;
--[[
##########################################################
GPS CONSTRUCTOR
##########################################################
]]--
local GPS_Rotate_Arrow = function(self, angle)
    local radius, ULx, ULy, LLx, LLy, URx, URy, LRx, LRy

    radius = angle - 0.785398163
    URx = 0.5 + cos(radius) / sqrt2
    URy =  0.5 + sin(radius) / sqrt2
    -- (-1)
    radius = angle + 0.785398163
    LRx = 0.5 + cos(radius) / sqrt2
    LRy =  0.5 + sin(radius) / sqrt2
    -- 1
    radius = angle + 2.35619449
    LLx = 0.5 + cos(radius) / sqrt2
    LLy =  0.5 + sin(radius) / sqrt2
    -- 3
    radius = angle + 3.92699082
    ULx = 0.5 + cos(radius) / sqrt2
    ULy =  0.5 + sin(radius) / sqrt2
    -- 5

    self.Arrow:SetTexCoord(ULx, ULy, LLx, LLy, URx, URy, LRx, LRy);
end

local function CreateGPS(frame)
    if not frame then return end
    local size = 32

    local gps = CreateFrame("Frame", nil, frame.TextGrip)
    gps:SetFrameLevel(99)
    gps:SetSize(size, size)
    gps.DefaultSize = size
    gps:SetPoint("RIGHT", frame, "RIGHT", 0, 0)

    gps.Arrow = gps:CreateTexture(nil, "OVERLAY", nil, 7)
    gps.Arrow:SetTexture([[Interface\AddOns\SVUI_TrackOMatic\artwork\GPS-ARROW]])
    gps.Arrow:SetSize(size, size)
    gps.Arrow:SetPoint("CENTER", gps, "CENTER", 0, 0)
    gps.Arrow:SetVertexColor(0.1, 0.8, 0.8)
    --gps.Arrow:SetBlendMode("ADD")

    gps.onMouseOver = true
    gps.OnlyProximity = false

    gps.Spin = GPS_Rotate_Arrow

    frame.GPS = gps
end

local RefreshGPS = function(self, frame, template)
    if(template:find("raid") or template:find("party")) then
        if not frame.GPS then CreateGPS(frame) end
        if(CONFIGS.groups) then
            frame.GPS.OnlyProximity = CONFIGS.proximity
            local actualSz = min(frame.GPS.DefaultSize, (frame:GetHeight() + 2))
            frame.GPS:SetSize(actualSz, actualSz)
            frame.GPS.Arrow:SetSize(actualSz, actualSz)
            if(not frame:IsElementEnabled("GPS")) then
                frame:EnableElement("GPS")
            end
        else
            if(frame:IsElementEnabled("GPS")) then
                frame:DisableElement("GPS")
            end
        end
    end
end
--[[
##########################################################
GPS ELEMENT
##########################################################
]]--
local sortFunc = function(a,b) return a[1] < b[1] end

local Update = function(self, elapsed)
	if self.elapsed and self.elapsed > (self.throttle or minThrottle) then
		numArrows = 0
		twipe(_PROXIMITY)
		for _, object in next, _FRAMES do
			if(object:IsShown()) then
				GPS = object.GPS
				local unit = object.unit
				if(unit) then
					if(GPS.PreUpdate) then GPS:PreUpdate(object) end

					local outOfRange = GPS.outOfRange and UnitInRange(unit) or false

					if(not unit or not (UnitInParty(unit) or UnitInRaid(unit)) or UnitIsUnit(unit, "player") or not UnitIsConnected(unit) or (not GPS.OnlyProximity and ((GPS.onMouseOver and (GetMouseFocus() ~= object)) or outOfRange))) then
						GPS:Hide()
					else
						local distance, angle = self.Track(unit)
						if not angle then
							GPS:Hide()
						else
							if(GPS.OnlyProximity == false) then
								GPS:Show()
							else
								GPS:Hide()
							end

							if GPS.Arrow then
								if(distance > 40) then
									GPS.Arrow:SetVertexColor(1,0.1,0.1)
								else
									if(distance > 30) then
										GPS.Arrow:SetVertexColor(0.4,0.8,0.1)
									else
										GPS.Arrow:SetVertexColor(0.1,1,0.1)
									end
									if(GPS.OnlyProximity and object.Health.percent and object.Health.percent < 80) then
										local value = object.Health.percent + distance
										_PROXIMITY[#_PROXIMITY + 1] = {value, GPS}
									end
								end
								GPS:Spin(angle)
							end

							if GPS.Text then
								GPS.Text:SetText(floor(distance))
							end

							if(GPS.PostUpdate) then GPS:PostUpdate(object, distance, angle) end
							numArrows = numArrows + 1
						end
					end
				else
					GPS:Hide()
				end
			end
		end

        if(_PROXIMITY[1]) then
        	tsort(_PROXIMITY, sortFunc)
        	if(_PROXIMITY[1][2]) then
	        	_PROXIMITY[1][2]:Show()
	        end
        end

		self.elapsed = 0
		self.throttle = max(minThrottle, 0.005 * numArrows)
	else
		self.elapsed = (self.elapsed or 0) + elapsed
	end
end

local Enable = function(self)
	if(self.GPS) then
		tinsert(_FRAMES, self)
		GPS_UpdateHandler:Show()
		return true
	end
end

local Disable = function(self)
	local GPS = self.GPS
	if GPS then
		for k, frame in next, _FRAMES do
			if(frame == self) then
				tremove(_FRAMES, k)
				GPS:Hide()
				break
			end
		end

		if #_FRAMES == 0 and GPS_UpdateHandler then
			GPS_UpdateHandler:Hide()
		end
	end
end

local taggedUnits = {}
local groupTagManager = CreateFrame("Frame")
function PLUGIN:EnableGPS()
    if(not SV.UnitFrames) then print("No Units") return end;
    local oUF = SV.UnitFrames.oUF
    if(not oUF) then print("No OUF") return end;

    CONFIGS = SV.db[self.Schema];

    groupTagManager:RegisterEvent("GROUP_ROSTER_UPDATE")
    groupTagManager:SetScript("OnEvent", function()
        local group, count;
        twipe(taggedUnits)
        if IsInRaid() then
            group = "raid"
            count = GetNumGroupMembers()
        elseif IsInGroup() then
            group = "party"
            count = GetNumGroupMembers() - 1;
            taggedUnits["player"] = true
        else
            group = "solo"
            count = 1
        end
        for i = 1, count do
            local realName = group..i;
            if not UnitIsUnit(realName, "player") then
                taggedUnits[realName] = true
            end
        end
    end);

    oUF.Tags.OnUpdateThrottle['nearbyplayers:8'] = 0.25
    oUF.Tags.Methods["nearbyplayers:8"] = function(unit)
        local unitsInRange, distance = 0;
        if UnitIsConnected(unit)then
            for taggedUnit, _ in pairs(taggedUnits)do
                if not UnitIsUnit(unit, taggedUnit) and UnitIsConnected(taggedUnit)then
                    distance = TriangulateUnit(unit, taggedUnit, true)
                    if distance and distance <= 8 then
                        unitsInRange = unitsInRange + 1
                    end
                end
            end
        end
        return unitsInRange
    end

    oUF.Tags.OnUpdateThrottle['nearbyplayers:10'] = 0.25
    oUF.Tags.Methods["nearbyplayers:10"] = function(unit)
        local unitsInRange, distance = 0;
        if UnitIsConnected(unit)then
            for taggedUnit, _ in pairs(taggedUnits)do
                if not UnitIsUnit(unit, taggedUnit) and UnitIsConnected(taggedUnit)then
                    distance = TriangulateUnit(unit, taggedUnit, true)
                    if distance and distance <= 10 then
                        unitsInRange = unitsInRange + 1
                    end
                end
            end
        end
        return unitsInRange
    end

    oUF.Tags.OnUpdateThrottle['nearbyplayers:30'] = 0.25
    oUF.Tags.Methods["nearbyplayers:30"] = function(unit)
        local unitsInRange, distance = 0;
        if UnitIsConnected(unit)then
            for taggedUnit, _ in pairs(taggedUnits)do
                if not UnitIsUnit(unit, taggedUnit) and UnitIsConnected(taggedUnit)then
                    distance = TriangulateUnit(unit, taggedUnit, true)
                    if distance and distance <= 30 then
                        unitsInRange = unitsInRange + 1
                    end
                end
            end
        end
        return unitsInRange
    end

    oUF.Tags.OnUpdateThrottle['distance'] = 0.25
    oUF.Tags.Methods["distance"] = function(unit)
        if not UnitIsConnected(unit) or UnitIsUnit(unit, "player")then return "" end
        local dst = TriangulateUnit("player", unit, true)
        if dst and dst > 0 then
            return format("%d", dst)
        end
        return ""
    end

    GPS_UpdateHandler.Track = TriangulateUnit
    GPS_UpdateHandler:SetScript("OnUpdate", Update)

    oUF:AddElement('GPS', nil, Enable, Disable)

    NewHook(SV.UnitFrames, "RefreshUnitLayout", RefreshGPS)
end
