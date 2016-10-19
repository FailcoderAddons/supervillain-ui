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
local ToggleCharacter      			= _G.ToggleCharacter;
local GetInventoryItemDurability    = _G.GetInventoryItemDurability;
local GetInventorySlotInfo  		= _G.GetInventorySlotInfo;
local DURABILITY  					= _G.DURABILITY;
--[[
##########################################################
GET ADDON DATA
##########################################################
]]--
local SV = select(2, ...)
local L = SV.L
local LSM = _G.LibStub("LibSharedMedia-3.0")
local Reports = SV.Reports;
--[[
##########################################################
DURABILITY STATS
##########################################################
]]--
local displayString = "%s: |cff%s%d%%|r";
local overall = 0;
local min, max, currentObject;
local equipment = {}
local inventoryMap = {
	["SecondaryHandSlot"] = L["Offhand"],
	["MainHandSlot"] = L["Main Hand"],
	["FeetSlot"] = L["Feet"],
	["LegsSlot"] = L["Legs"],
	["HandsSlot"] = L["Hands"],
	["WristSlot"] = L["Wrist"],
	["WaistSlot"] = L["Waist"],
	["ChestSlot"] = L["Chest"],
	["ShoulderSlot"] = L["Shoulder"],
	["HeadSlot"] = L["Head"]
}
local HEX_COLOR = "22FFFF";
local TEXT_PATTERN = "|cff%s%s|r";
--[[
##########################################################
STANDARD TYPE
##########################################################
]]--
local REPORT_NAME = "Durability";
local Report = Reports:NewReport(REPORT_NAME, {
	type = "data source",
	text = REPORT_NAME .. " Info",
	icon = [[Interface\Addons\SVUI_!Core\assets\icons\SVUI]]
});

Report.events = {"PLAYER_ENTERING_WORLD", "UPDATE_INVENTORY_DURABILITY", "MERCHANT_SHOW"};

Report.OnEvent = function(self, event, ...)
	overall = 100;
	if self.barframe:IsShown() then
		self.text:SetAllPoints(self)
		self.text:SetJustifyH("CENTER")
		self.barframe:Hide()
	end
	for slot,name in pairs(inventoryMap)do
		local slotID = GetInventorySlotInfo(slot)
		min,max = GetInventoryItemDurability(slotID)
		if min then
			equipment[name] = min / max * 100;
			if min / max * 100 < overall then
				overall = min / max * 100
			end
		end
	end
	self.text:SetFormattedText(displayString, DURABILITY, HEX_COLOR, overall)
end

Report.OnClick = function(self, button)
	ToggleCharacter("PaperDollFrame")
end

Report.OnEnter = function(self)
	Reports:SetDataTip(self)
	for name,amt in pairs(equipment)do
		Reports.ToolTip:AddDoubleLine(name, format("%d%%", amt),1, 1, 1, SV:ColorGradient(amt * 0.01, 1, 0, 0, 1, 1, 0, 0, 1, 0))
	end
	Reports:ShowDataTip()
end
--[[
##########################################################
BAR TYPE
##########################################################
]]--
local BAR_NAME = "Durability Bar";
local ReportBar = Reports:NewReport(BAR_NAME, {
	type = "data source",
	text = BAR_NAME,
	icon = [[Interface\Addons\SVUI_!Core\assets\icons\SVUI]]
});

ReportBar.events = {"PLAYER_ENTERING_WORLD", "UPDATE_INVENTORY_DURABILITY", "MERCHANT_SHOW"};

ReportBar.OnEvent = function(self, event, ...)
	overall = 100;
	if not self.barframe:IsShown() then
		self.barframe:Show()
		self.barframe.icon.texture:SetTexture(SV.media.dock.durabilityLabel)
	end
	for slot,name in pairs(inventoryMap)do
		local slotID = GetInventorySlotInfo(slot)
		min,max = GetInventoryItemDurability(slotID)
		if min then
			equipment[name] = min / max * 100;
			if min / max * 100 < overall then
				overall = min / max * 100
			end
		end
	end
	local newRed = (100 - overall) * 0.01;
	local newGreen = overall * 0.01;
	self.barframe.bar:SetMinMaxValues(0, 100)
	self.barframe.bar:SetValue(overall)
	self.barframe.bar:SetStatusBarColor(newRed, newGreen, 0)
	self.text:SetText('')
end

ReportBar.OnClick = function(self, button)
	ToggleCharacter("PaperDollFrame")
end

ReportBar.OnEnter = function(self)
	Reports:SetDataTip(self)
	for name,amt in pairs(equipment)do
		Reports.ToolTip:AddDoubleLine(name, format("%d%%", amt),1, 1, 1, SV:ColorGradient(amt * 0.01, 1, 0, 0, 1, 1, 0, 0, 1, 0))
	end
	Reports:ShowDataTip()
end
