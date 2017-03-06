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
local collectgarbage    = _G.collectgarbage;
local string 	= _G.string;
local math 		= _G.math;
local table 	= _G.table;
--[[ STRING METHODS ]]--
local format = string.format;
--[[ MATH METHODS ]]--
local floor = math.floor
--[[ TABLE METHODS ]]--
local tsort = table.sort;
local IsShiftKeyDown        = _G.IsShiftKeyDown;
local IsAddOnLoaded         = _G.IsAddOnLoaded;
--[[
##########################################################
GET ADDON DATA
##########################################################
]]--
local SV = select(2, ...)
local L = SV.L;
local Reports = SV.Reports;
--[[
##########################################################
SYSTEM STATS (Credit: Richy004)
##########################################################
]]--
local REPORT_NAME = "Mastery";
local HEX_COLOR = "22FFFF";
local TEXT_PATTERN = "|cff%s%s|r";
local int, int2 = 6, 5
local statusColors = {
    "|cff0CD809",
    "|cffE8DA0F",
    "|cffFF9000",
    "|cffD80909"
}
local enteredFrame = false;

local Report = Reports:NewReport(REPORT_NAME, {
    type = "data source",
    text = REPORT_NAME .. " Info",
    icon = [[Interface\Addons\SVUI_!Core\assets\icons\SVUI]]
});

Report.OnEnter = function(self)
    enteredFrame = true;
    Reports:SetDataTip(self)
end

Report.OnLeave = function(self, button)
    enteredFrame = false;
    Reports.ToolTip:Hide()
end

Report.OnUpdate = function(self, elapsed)
    mastery, coefficient = GetMasteryEffect()
    self.text:SetText("MASTERY:" ..  "|cff22CFFF" .. math.floor(mastery + coefficient) .. "%");

    if enteredFrame then
        Report.OnEnter(self)
    end
end
