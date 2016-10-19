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
local pairs 	= _G.pairs;
local ipairs 	= _G.ipairs;
local type 		= _G.type;
local error 	= _G.error;
local pcall 	= _G.pcall;
local assert 	= _G.assert;
local tostring 	= _G.tostring;
local tonumber 	= _G.tonumber;
local string 	= _G.string;
local math 		= _G.math;
local table 	= _G.table;
--[[ STRING METHODS ]]--
local lower, upper = string.lower, string.upper;
local find, format, len, split = string.find, string.format, string.len, string.split;
local match, sub, join = string.match, string.sub, string.join;
local gmatch, gsub = string.gmatch, string.gsub;
--[[ MATH METHODS ]]--
local abs, ceil, floor, round = math.abs, math.ceil, math.floor, math.round;  -- Basic
--[[ TABLE METHODS ]]--
local twipe, tsort = table.wipe, table.sort;

local NUM_BAG_SLOTS             = _G.NUM_BAG_SLOTS;
local CURRENCY          		= _G.CURRENCY;
local GetContainerNumFreeSlots  = _G.GetContainerNumFreeSlots;
local GetContainerNumSlots      = _G.GetContainerNumSlots;
local ToggleAllBags     		= _G.ToggleAllBags;
local MAX_WATCHED_TOKENS        = _G.MAX_WATCHED_TOKENS;
local GetBackpackCurrencyInfo  = _G.GetBackpackCurrencyInfo;
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
BAG STATS
##########################################################
]]--
local hexColor = "22FFFF"
local bags_text = "%s|cff%s%d / %d|r";

local Report = Reports:NewReport("Bags", {
	type = "data source",
	text = "Bags Info",
	icon = [[Interface\Addons\SVUI_!Core\assets\icons\SVUI]]
});

Report.events = {"PLAYER_ENTERING_WORLD", "BAG_UPDATE"};

Report.OnEvent = function(self, event, ...)
	local f, g, h = 0, 0, 0;
	for i = 0, NUM_BAG_SLOTS do
		f, g = f + GetContainerNumFreeSlots(i),
		g + GetContainerNumSlots(i)
	end
	h = g - f;
	self.text:SetFormattedText(bags_text, L["Bags"]..": ", hexColor, h, g)
end

Report.OnClick = function(self, button)
	ToggleAllBags()
end

Report.OnEnter = function(self)
	Reports:SetDataTip(self)
	for i = 1, MAX_WATCHED_TOKENS do
		local l, m, n, o, p = GetBackpackCurrencyInfo(i)
		if l and i == 1 then
			Reports.ToolTip:AddLine(CURRENCY)
			Reports.ToolTip:AddLine(" ")
		end
		if l and m then
			Reports.ToolTip:AddDoubleLine(l, m, 1, 1, 1)
		end
	end
	Reports:ShowDataTip()
end
