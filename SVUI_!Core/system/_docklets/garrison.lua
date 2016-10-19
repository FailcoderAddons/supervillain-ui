--[[
##########################################################
S V U I   By: Failcoder
##########################################################
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local select        = _G.select;
local assert        = _G.assert;
local type          = _G.type;
local error         = _G.error;
local pcall         = _G.pcall;
local print         = _G.print;
local ipairs        = _G.ipairs;
local pairs         = _G.pairs;
local tostring      = _G.tostring;
local tonumber      = _G.tonumber;

--STRING
local string        = _G.string;
local upper         = string.upper;
local format        = string.format;
local find          = string.find;
local match         = string.match;
local gsub          = string.gsub;
--TABLE
local table 				= _G.table;
local tremove       = _G.tremove;
local twipe 				= _G.wipe;
--MATH
local math      		= _G.math;
local min 					= math.min;
local floor         = math.floor
local ceil          = math.ceil

local time          = _G.time;
local wipe          = _G.wipe;
--BLIZZARD API
local CreateFrame           = _G.CreateFrame;
local InCombatLockdown      = _G.InCombatLockdown;
local GameTooltip           = _G.GameTooltip;
local ReloadUI              = _G.ReloadUI;
local hooksecurefunc        = _G.hooksecurefunc;
local IsAltKeyDown          = _G.IsAltKeyDown;
local IsShiftKeyDown        = _G.IsShiftKeyDown;
local IsControlKeyDown      = _G.IsControlKeyDown;
local IsModifiedClick       = _G.IsModifiedClick;
local PlaySound             = _G.PlaySound;
local PlaySoundFile         = _G.PlaySoundFile;
local PlayMusic             = _G.PlayMusic;
local StopMusic             = _G.StopMusic;
local ToggleFrame           = _G.ToggleFrame;
local ERR_NOT_IN_COMBAT     = _G.ERR_NOT_IN_COMBAT;
local RAID_CLASS_COLORS     = _G.RAID_CLASS_COLORS;
local CUSTOM_CLASS_COLORS   = _G.CUSTOM_CLASS_COLORS;

local C_Garrison            = _G.C_Garrison;
local GetTime         		= _G.GetTime;
local GetItemCooldown       = _G.GetItemCooldown;
local GetItemCount         	= _G.GetItemCount;
local GetItemInfo          	= _G.GetItemInfo;
local GetSpellInfo         	= _G.GetSpellInfo;
local IsSpellKnown         	= _G.IsSpellKnown;
local GetGarrison       	= _G.GetGarrison;
local GetProfessionInfo    	= _G.GetProfessionInfo;
local GetCurrencyInfo    	= _G.GetCurrencyInfo;
--[[
##########################################################
ADDON
##########################################################
]]--
local SV = select(2, ...)
local L = SV.L
local MOD = SV.Dock;
local GarrisonData = {};
--[[
##########################################################
LOCALS
##########################################################
]]--

local function GetInProgressMissions()
    local garrisonMission = {}

    local types = {
        LE_FOLLOWER_TYPE_GARRISON_7_0,
        LE_FOLLOWER_TYPE_GARRISON_6_0,
        LE_FOLLOWER_TYPE_SHIPYARD_6_2
    }

    for key, type in pairs(types) do
        local localMission = {}
        C_Garrison.GetInProgressMissions(localMission, type)
        for i = 1, #localMission do
            garrisonMission[#garrisonMission + 1] = localMission[i]
        end
    end

    return garrisonMission
end

local function GetCompleteMissions()
    local garrisonMission = {}

    local types = {
        LE_FOLLOWER_TYPE_GARRISON_7_0,
        LE_FOLLOWER_TYPE_GARRISON_6_0,
        LE_FOLLOWER_TYPE_SHIPYARD_6_2
    }

    for key, type in pairs(types) do
        local localMission = {}
        C_Garrison.GetCompleteMissions(garrisonMission, type)
        for i = 1, #localMission do
            garrisonMission[#garrisonMission + 1] = localMission[i]
        end
    end

    return garrisonMission
end

local function GetDockCooldown(itemID)
	local start,duration = GetItemCooldown(itemID)
	local expires = duration - (GetTime() - start)
	if expires > 0.05 then
		local timeLeft = 0;
		local calc = 0;
		if expires < 4 then
			return format("|cffff0000%.1f|r", expires)
		elseif expires < 60 then
			return format("|cffffff00%d|r", floor(expires))
		elseif expires < 3600 then
			timeLeft = ceil(expires / 60);
			calc = floor((expires / 60) + .5);
			return format("|cffff9900%dm|r", timeLeft)
		elseif expires < 86400 then
			timeLeft = ceil(expires / 3600);
			calc = floor((expires / 3600) + .5);
			return format("|cff66ffff%dh|r", timeLeft)
		else
			timeLeft = ceil(expires / 86400);
			calc = floor((expires / 86400) + .5);
			return format("|cff6666ff%dd|r", timeLeft)
		end
	else
		return "|cff6666ffReady|r"
	end
end

local GarrisonButton_OnEvent = function(self, event, ...)
	if(not InCombatLockdown()) then
		if (event == "GARRISON_HIDE_LANDING_PAGE") then
			self:SetDocked()
		elseif (event == "GARRISON_SHOW_LANDING_PAGE") then
			self:SetDocked(true)
		end
	end
	if((not self.StartAlert) or (not self.StopAlert)) then return end
	if ( event == "GARRISON_BUILDING_ACTIVATABLE" ) then
		self:StartAlert();
	elseif ( event == "GARRISON_BUILDING_ACTIVATED" or event == "GARRISON_ARCHITECT_OPENED") then
		self:StopAlert();
	elseif ( event == "GARRISON_MISSION_FINISHED" ) then
		self:StartAlert();
	elseif ( event == "GARRISON_MISSION_NPC_OPENED" ) then
		self:StopAlert();
	elseif ( event == "GARRISON_SHIPYARD_NPC_OPENED" ) then
		self:StopAlert();
	elseif (event == "GARRISON_INVASION_AVAILABLE") then
		self:StartAlert();
	elseif (event == "GARRISON_INVASION_UNAVAILABLE") then
		self:StopAlert();
	elseif (event == "SHIPMENT_UPDATE") then
		local shipmentStarted = ...;
		if (shipmentStarted) then
			self:StartAlert();
		end
	end
end

local function getColoredString(text, color)
	local hex = SV:HexColor(color)
	return ("|cff%s%s|r"):format(hex, text)
end

local function GetSafeData(fn)
	local t = fn(1) or {}
	for k,v in pairs(fn(2) or {}) do
		t[#t+1] = v
	end
	return t
end

local function GetActiveMissions()
	wipe(GarrisonData)
	local hasMission = false
	local inProgressMissions = {}
	local completedMissions = {}

	GameTooltip:AddLine(" ", 1, 1, 1)
	GameTooltip:AddLine("Active Missions", 1, 0.7, 0)

	for key,data in pairs(GetSafeData(C_Garrison.GetInProgressMissions)) do
		GarrisonData[data.missionID] = {
			name = data.name,
			level = data.level,
			seconds = data.durationSeconds,
			timeLeft = data.timeLeft,
			completed = false,
			isRare = data.isRare,
			type = data.type,
		}
		hasMission = true
	end

	for key,data in pairs(GetSafeData(C_Garrison.GetCompleteMissions)) do
		if(GarrisonData[data.missionID]) then
			GarrisonData[data.missionID].completed = true
		end
	end

	for key,data in pairs(GarrisonData) do
		local hex = data.isRare and "blue" or "green"
		local mission = ("%s|cff888888 - |r%s"):format(getColoredString(data.level, "yellow"), getColoredString(data.name, hex));
		local remaining
		if (data.completed) then
			remaining = L["Complete!"]
		else
			remaining = ("%s %s"):format(data.timeLeft, getColoredString(" ("..SV:ParseSeconds(data.seconds)..")", "lightgrey"))
		end

		GameTooltip:AddDoubleLine(mission, remaining, 0, 1, 0, 1, 1, 1)
		hasMission = true
	end

	if(not hasMission) then
		GameTooltip:AddLine("None", 1, 0, 0)
	end
end

local function GetBuildingData()
	local hasBuildings = false
	local now = time();
	local prefixed = false;

	local buildings = GetSafeData(C_Garrison.GetBuildings)
	for i = 1, #buildings do
		local buildingID = buildings[i].buildingID
		local plotID = buildings[i].plotID

		local id, name, texPrefix, icon, rank, isBuilding, timeStart, buildTime, canActivate, canUpgrade, isPrebuilt = C_Garrison.GetOwnedBuildingInfoAbbrev(plotID)
		local remaining;

		if(isBuilding) then
			local timeLeft = buildTime - (now - timeStart);
			if(canActivate or timeLeft < 0) then
				remaining = L["Complete!"]
			else
				remaining = ("Building %s"):format(getColoredString("("..SV:ParseSeconds(timeLeft)..")", "lightgrey"))
			end
		else
			local name, texture, shipmentCapacity, shipmentsReady, shipmentsTotal, creationTime, duration, timeleftString, itemName, itemIcon, itemQuality, itemID = C_Garrison.GetLandingPageShipmentInfo(buildingID)
			if(shipmentsReady and shipmentsReady > 0) then
				timeleftString = timeleftString or 'Unknown'
				remaining = ("Ready: %s, Next: %s"):format(getColoredString(shipmentsReady, "green"), getColoredString(timeleftString, "lightgrey"))
			elseif(timeleftString) then
				remaining = ("Next: %s"):format(getColoredString(timeleftString, "lightgrey"))
			end
		end

		if(remaining) then
			if(not prefixed) then
				GameTooltip:AddLine(" ", 1, 1, 1)
				GameTooltip:AddLine("Buildings / Work Orders", 1, 0.7, 0)
				prefixed = true
			end
			local building = ("|cffFF5500%s|r|cff888888 - |r|cffFFFF00Rank %s|r"):format(name, rank);
			GameTooltip:AddDoubleLine(building, remaining, 0, 1, 0, 1, 1, 1)
		end
	end
end

local SetGarrisonTooltip = function(self)
	if(not InCombatLockdown()) then C_Garrison.RequestLandingPageShipmentInfo() end
	local name, amount, tex, week, weekmax, maxed, discovered = GetCurrencyInfo(1220)
	local texStr = ("\124T%s:12\124t %d"):format(tex, amount)
	GameTooltip:AddDoubleLine(name, texStr, 1, 1, 0, 1, 1, 1)
	name, amount, tex, week, weekmax, maxed, discovered = GetCurrencyInfo(1155)
	texStr = ("\124T%s:12\124t %d"):format(tex, amount)
	GameTooltip:AddDoubleLine(name, texStr, 1, 1, 0, 1, 1, 1)
	name, amount, tex, week, weekmax, maxed, discovered = GetCurrencyInfo(824)
	texStr = ("\124T%s:12\124t %d"):format(tex, amount)
	GameTooltip:AddDoubleLine(name, texStr, 1, 1, 0, 1, 1, 1)
	name, amount, tex, week, weekmax, maxed, discovered = GetCurrencyInfo(1101)
	texStr = ("\124T%s:12\124t %d"):format(tex, amount)
	GameTooltip:AddDoubleLine(name, texStr, 1, 1, 0, 1, 1, 1)

	GetActiveMissions()
	GetBuildingData()
	if(self.StopAlert) then
		self:StopAlert()
	end
	local text1 = self:GetAttribute("tipText")
	local text2 = self:GetAttribute("tipExtraText")
	GameTooltip:AddLine(" ", 1, 1, 1)
	GameTooltip:AddDoubleLine("[Left-Click]", text1, 0, 1, 0, 1, 1, 1)
	if InCombatLockdown() then return end
	if(text2) then
		local remaining = GetDockCooldown(110560)
		GameTooltip:AddDoubleLine("[Right Click]", text2, 0, 1, 0, 1, 1, 1)
		GameTooltip:AddDoubleLine(L["Time Remaining"], remaining, 1, 0.5, 0, 1, 1, 1)
	end
end

local function LoadToolBarGarrison()
	local mmButton = _G.GarrisonLandingPageMinimapButton;
	if((not SV.db.Dock.dockTools.garrison) or (not mmButton) or MOD.GarrisonLoaded) then return end

	mmButton:FadeOut()

	if(InCombatLockdown()) then
		MOD.GarrisonNeedsUpdate = true;
		MOD:RegisterEvent("PLAYER_REGEN_ENABLED");
		return
	end

	local garrison = SV.Dock:SetDockButton("BottomLeft", L["Landing Page"], "SVUI_Garrison", SV.media.dock.garrisonToolIcon, SetGarrisonTooltip, "SecureActionButtonTemplate")
	garrison:SetAttribute("type1", "click")
	garrison:SetAttribute("clickbutton", mmButton)

	local garrisonStone = GetItemInfo(110560);
	if(garrisonStone and type(garrisonStone) == "string") then
		garrison:SetAttribute("tipExtraText", L["Garrison Hearthstone"])
		garrison:SetAttribute("type2", "macro")
		garrison:SetAttribute("macrotext", "/use [nomod] " .. garrisonStone)
	end

	mmButton:RemoveTextures()
	mmButton:ClearAllPoints()
	mmButton:SetAllPoints(garrison)
	mmButton:SetNormalTexture("")
	mmButton:SetPushedTexture("")
	mmButton:SetHighlightTexture("")
	mmButton:EnableMouse(false)

	garrison:RegisterEvent("GARRISON_HIDE_LANDING_PAGE");
	garrison:RegisterEvent("GARRISON_SHOW_LANDING_PAGE");
	garrison:RegisterEvent("GARRISON_BUILDING_ACTIVATABLE");
	garrison:RegisterEvent("GARRISON_BUILDING_ACTIVATED");
	garrison:RegisterEvent("GARRISON_ARCHITECT_OPENED");
	garrison:RegisterEvent("GARRISON_MISSION_FINISHED");
	garrison:RegisterEvent("GARRISON_MISSION_NPC_OPENED");
	garrison:RegisterEvent("GARRISON_SHIPYARD_NPC_OPENED");
	garrison:RegisterEvent("GARRISON_INVASION_AVAILABLE");
	garrison:RegisterEvent("GARRISON_INVASION_UNAVAILABLE");
	garrison:RegisterEvent("SHIPMENT_UPDATE");

	garrison:SetScript("OnEvent", GarrisonButton_OnEvent);

	if(not mmButton:IsShown()) then
		garrison:SetDocked()
	end

	C_Garrison.RequestLandingPageShipmentInfo();
	MOD.GarrisonLoaded = true
end
--[[
##########################################################
BUILD/UPDATE
##########################################################
]]--
function MOD:UpdateGarrisonTool()
	if((not SV.db.Dock.dockTools.garrison) or self.GarrisonLoaded) then return end
	LoadToolBarGarrison()
end

function MOD:LoadGarrisonTool()
	if((not SV.db.Dock.dockTools.garrison) or self.GarrisonLoaded or (not _G.GarrisonLandingPageMinimapButton)) then return end
	SV.Timers:ExecuteTimer(LoadToolBarGarrison, 5)
end
