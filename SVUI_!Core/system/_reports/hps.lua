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
local string 	= _G.string;
--[[ STRING METHODS ]]--
local match, sub, join = string.match, string.sub, string.join;
local max = math.max;
local time      = _G.time;
local wipe      = _G.wipe;
local UnitGUID  = _G.UnitGUID;
local UNIT_PET  = _G.UNIT_PET;
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
UTILS
##########################################################
]]--
local function round(num, idp)
  return string.format("%." .. (idp or 0) .. "f", num)
end
--[[ 
########################################################## 
HPS STATS
##########################################################
]]--
local REPORT_NAME = "HPS";
local HEX_COLOR = "22FFFF";
local TEXT_PATTERN1 = "|cff%s%.1f|r";
local TEXT_PATTERN2 = "%s |cff00CCFF%s|r";
local PlayerEvents = {["SPELL_HEAL"] = true, ["SPELL_PERIODIC_HEAL"] = true};
local playerID, petID = UnitGUID('player');

local Report = Reports:NewReport(REPORT_NAME, {
	type = "data source",
	text = REPORT_NAME .. " Info",
	icon = [[Interface\Addons\SVUI_!Core\assets\icons\SVUI]],
});

Report.events = {"PLAYER_ENTERING_WORLD", "COMBAT_LOG_EVENT_UNFILTERED", "PLAYER_LEAVE_COMBAT", "PLAYER_REGEN_DISABLED", "UNIT_PET"};

Report.OnInit = function(self)
	playerID = UnitGUID('player')
	petID = UnitGUID("pet")

	if(not self.InnerData) then
		self.InnerData = {}
	end

	self.InnerData.thistime = 0
	self.InnerData.lasttime = 0
	self.InnerData.totaltime = 0
	self.InnerData.lastamount = 0
	self.InnerData.totalamount = 0
	self.InnerData.overamount = 0
end

Report.OnEvent = function(self, event, ...)
	local data = self.InnerData
	if event == "PLAYER_ENTERING_WORLD" then
		playerID = UnitGUID('player')
	elseif event == 'PLAYER_REGEN_DISABLED' or event == "PLAYER_LEAVE_COMBAT" then
		local now = time()
		if now - data.lasttime > 20 then --time since the last segment
			data.thistime = 0
			data.totaltime = 0
			data.totalamount = 0
			data.lastamount = 0
			data.overamount = 0
		end
		data.lasttime = now
	elseif event == 'COMBAT_LOG_EVENT_UNFILTERED' then
		local newTime, event, _, srcGUID, _, _, _, _, _, _, _, _, _, test, lastHealAmount, overHeal = ...
		if not PlayerEvents[event] then return end
		if(srcGUID == playerID or srcGUID == petID) then
			if data.thistime == 0 then data.thistime = newTime end
			data.lasttime = data.thistime
			data.totaltime = newTime - data.thistime
			-- JV 20161019: For some reason this was lastamount + (...) which meant that it was over counting since lastamount wasn't necessarily 0
			data.lastamount =  (lastHealAmount - overHeal)
			data.totalamount = data.totalamount + data.lastamount
			data.overamount = data.overamount + overHeal
		end
	elseif event == UNIT_PET then
		data.petID = UnitGUID("pet")
	end
	
	if data.totalamount == 0 or data.totaltime == 0 then
		self.text:SetText(TEXT_PATTERN2:format(L["HPS"], "..PAUSED"))
		self.TText = "No Healing Done"
		self.TText2 = "Surely there is someone \nwith an ouchie somewhere!"
	else
		local HPS = (data.totalamount) / (data.totaltime)
		self.text:SetFormattedText(TEXT_PATTERN1, HEX_COLOR, HPS)
		self.TText = "HPS:"
		self.TText2 = round(HPS,4)
	end
end

Report.OnClick = function(self, button)
	local data = self.InnerData
	data.thistime = 0
	data.totaltime = 0
	data.totalamount = 0
	data.lastamount = 0
	if data.totalamount == 0 or data.totaltime == 0 then
		self.text:SetText(TEXT_PATTERN2:format(L["HPS"], "..PAUSED"))
		self.TText = "No Healing Done"
		self.TText2 = "Surely there is someone \nwith an ouchie somewhere!"
	else
		local HPS = (data.totalamount) / (data.totaltime)
		self.text:SetFormattedText(TEXT_PATTERN1, HEX_COLOR, HPS)
		self.TText = "HPS:"
		self.TText2 = round(HPS,4)
	end
end

Report.OnEnter = function(self)
	Reports:SetDataTip(self)
	Reports.ToolTip:AddDoubleLine("Healing Total:", self.InnerData.totalamount, 1, 1, 1)
	Reports.ToolTip:AddDoubleLine("OverHealing Total:", self.InnerData.overamount, 1, 1, 1)
	Reports.ToolTip:AddLine(" ", 1, 1, 1)
	Reports.ToolTip:AddDoubleLine(self.TText, self.TText2, 1, 1, 1)
	Reports.ToolTip:AddLine(" ", 1, 1, 1)
	Reports.ToolTip:AddDoubleLine("[Click]", "Clear HPS", 0,1,0, 0.5,1,0.5)
	Reports:ShowDataTip(true)
end