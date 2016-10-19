--[[
##############################################################################
S V U I   By: Failcoder
##############################################################################

##########################################################
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;

local select 	= _G.select;
local type 		= _G.type;
local string 	= _G.string;
local math 		= _G.math;
--[[ STRING METHODS ]]--
local format, join = string.format, string.join;
--[[ MATH METHODS ]]--
local floor = math.floor;
--[[
##########################################################
GET ADDON DATA
##########################################################
]]--
local SV = select(2, ...)
local L = SV.L
local Reports = SV.Reports;
--[[
##########################################################
TIME STATS (Credit: Elv)
##########################################################
]]--
local APM = { TIMEMANAGER_PM, TIMEMANAGER_AM }
local TEXT_PATTERN1 = "%02d|cff22CFFF:|r%02d";
local TEXT_PATTERN2 = "%d|cff22CFFF:|r%02d|cff22CFFF %s|r";
local europeDisplayFormat_nocolor = join("", "%02d", ":|r%02d")
local ukDisplayFormat_nocolor = join("", "", "%d", ":|r%02d", " %s|r")
local timerLongFormat = "%d:%02d:%02d"
local timerShortFormat = "%d:%02d"
local lockoutInfoFormat = "%s%s |cffaaaaaa(%s, %s/%s)"
local lockoutInfoFormatNoEnc = "%s%s |cffaaaaaa(%s)"
local formatBattleGroundInfo = "%s: "
local curHr, curMin, curAmPm
local enteredFrame = false;
local date = _G.date
local localizedName, isActive, canQueue, startTime, canEnter, _
local name, instanceID, reset, difficultyId, locked, extended, isRaid, maxPlayers, difficulty, numEncounters, encounterProgress

local function ConvertTime(h, m)
	local AmPm
	if SV.db.Reports.time24 == true then
		return h, m, -1
	else
		if h >= 12 then
			if h > 12 then h = h - 12 end
			AmPm = 1
		else
			if h == 0 then h = 12 end
			AmPm = 2
		end
	end
	return h, m, AmPm
end

local function CalculateTimeValues(tooltip)
	if (tooltip and SV.db.Reports.localtime) or (not tooltip and not SV.db.Reports.localtime) then
		return ConvertTime(GetGameTime())
	else
		local dateTable = date("*t")
		return ConvertTime(dateTable["hour"], dateTable["min"])
	end
end
--[[
##########################################################
REPORT TEMPLATE
##########################################################
]]--
local REPORT_NAME = "Time";
local HEX_COLOR = "22FFFF";

local Report = Reports:NewReport(REPORT_NAME, {
	type = "data source",
	text = REPORT_NAME .. " Info",
	icon = [[Interface\Addons\SVUI_!Core\assets\icons\SVUI]]
});

Report.events = {"UPDATE_INSTANCE_INFO"};

Report.OnEvent = function(self, event, ...)
	if event == "UPDATE_INSTANCE_INFO" and enteredFrame then
		RequestRaidInfo()
	end
end

Report.OnClick = function(self, button)
	GameTimeFrame:Click();
end

Report.OnEnter = function(self)
	Reports:SetDataTip(self)

	if(not enteredFrame) then
		enteredFrame = true;
		RequestRaidInfo()
	end

	Reports.ToolTip:AddLine(VOICE_CHAT_BATTLEGROUND);
	for i = 1, GetNumWorldPVPAreas() do
		_, localizedName, isActive, canQueue, startTime, canEnter = GetWorldPVPAreaInfo(i)
		if canEnter then
			if isActive then
				startTime = WINTERGRASP_IN_PROGRESS
			elseif startTime == nil then
				startTime = QUEUE_TIME_UNAVAILABLE
			else
				startTime = SecondsToTime(startTime, false, nil, 3)
			end
			Reports.ToolTip:AddDoubleLine(format(formatBattleGroundInfo, localizedName), startTime, 1, 1, 1, 0.8, 0.8, 0.8)
		end
	end

	local oneraid;
	local r, g, b = 0.8, 0.8, 0.8
	for i = 1, GetNumSavedInstances() do
		name, _, reset, difficultyId, locked, extended, _, isRaid, maxPlayers, difficulty, numEncounters, encounterProgress  = GetSavedInstanceInfo(i)
		if isRaid and (locked or extended) and name then
			if not oneraid then
				Reports.ToolTip:AddLine(" ")
				Reports.ToolTip:AddLine(L["Saved Raid(s)"])
				oneraid = true
			end
			if extended then
				local c = SV.media.color.green
				r, g, b = c[1], c[2], c[3]
			else
				r, g, b = 0.8, 0.8, 0.8
			end
			local _, _, isHeroic, isChallengeMode, displayHeroic, displayMythic = GetDifficultyInfo(difficultyId)
			local difficultyPrefix = "N";
			if ( isHeroic or isChallengeMode or displayMythic or displayHeroic ) then
				difficultyPrefix = "H"
			end
			if (numEncounters and numEncounters > 0) and (encounterProgress and encounterProgress > 0) then
				Reports.ToolTip:AddDoubleLine(format(lockoutInfoFormat, maxPlayers, difficultyPrefix, name, encounterProgress, numEncounters), SecondsToTime(reset, false, nil, 3), 1, 1, 1, r, g, b)
			else
				Reports.ToolTip:AddDoubleLine(format(lockoutInfoFormatNoEnc, maxPlayers, difficultyPrefix, name), SecondsToTime(reset, false, nil, 3), 1, 1, 1, r, g, b)
			end
		end
	end

	local addedLine = false
	for i = 1, GetNumSavedWorldBosses() do
		name, instanceID, reset = GetSavedWorldBossInfo(i)
		if(reset) then
			if(not addedLine) then
				Reports.ToolTip:AddLine(' ')
				Reports.ToolTip:AddLine(RAID_INFO_WORLD_BOSS.."(s)")
				addedLine = true
			end
			Reports.ToolTip:AddDoubleLine(name, SecondsToTime(reset, true, nil, 3), 1, 1, 1, 0.8, 0.8, 0.8)
		end
	end

	local timeText
	local Hr, Min, AmPm = CalculateTimeValues(true)

	Reports.ToolTip:AddLine(" ")
	if AmPm == -1 then
		Reports.ToolTip:AddDoubleLine(SV.db.Reports.localtime and TIMEMANAGER_TOOLTIP_REALMTIME or TIMEMANAGER_TOOLTIP_LOCALTIME,
			format(europeDisplayFormat_nocolor, Hr, Min), 1, 1, 1, 0.8, 0.8, 0.8)
	else
		Reports.ToolTip:AddDoubleLine(SV.db.Reports.localtime and TIMEMANAGER_TOOLTIP_REALMTIME or TIMEMANAGER_TOOLTIP_LOCALTIME,
			format(ukDisplayFormat_nocolor, Hr, Min, APM[AmPm]), 1, 1, 1, 0.8, 0.8, 0.8)
	end

	Reports.ToolTip:Show()
end

Report.OnLeave = function(self, button)
	Reports.ToolTip:Hide();
	enteredFrame = false;
end

local int = 3
local Time_OnUpdate = function(self, t)
	int = int - t

	if int > 0 then return end

	if GameTimeFrame.flashInvite then
		SV.Animate:Flash(self, 0.53)
	else
		SV.Animate:StopFlash(self)
	end

	if enteredFrame then
		Report.OnEnter(self)
	end

	local Hr, Min, AmPm = CalculateTimeValues(false)

	-- no update quick exit
	if (Hr == curHr and Min == curMin and AmPm == curAmPm) and not (int < -15000) then
		int = 5
		return
	end

	curHr = Hr
	curMin = Min
	curAmPm = AmPm

	if AmPm == -1 then
		self.text:SetFormattedText(TEXT_PATTERN1, Hr, Min)
	else
		self.text:SetFormattedText(TEXT_PATTERN2, Hr, Min, APM[AmPm])
	end
	int = 5
end

Report.OnUpdate = Time_OnUpdate
