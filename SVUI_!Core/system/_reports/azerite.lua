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
UTILITIES
##########################################################
]]--
local percColors = {
	"|cff0CD809",
	"|cffE8DA0F",
	"|cffFF9000",
	"|cffD80909"
}

local function SetTooltipText(report)
	Reports:SetDataTip(report);
	
	Reports.ToolTip:AddLine(L["Heart of Azeroth"]);
	Reports.ToolTip:AddLine(" ");
    
    local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem(); 
	
	if (not azeriteItemLocation) then
        Reports.ToolTip:AddDoubleLine(L["No Heart of Azeroth"]);
		return; 
    end

	local xp, totalLevelXP = C_AzeriteItem.GetAzeriteItemXPInfo(azeriteItemLocation);
    local currentLevel = C_AzeriteItem.GetPowerLevel(azeriteItemLocation); 
    local xpToNextLevel = totalLevelXP - xp; 
    local calc1 = (xp / totalLevelXP) * 100;

    Reports.ToolTip:AddDoubleLine(L["Current Level:"], (" %d "):format(currentLevel), 1, 1, 1);
    Reports.ToolTip:AddDoubleLine(L["Current Artifact Power:"], (" %s  /  %s (%d%%)"):format(BreakUpLargeNumbers(xp), BreakUpLargeNumbers(totalLevelXP), calc1), 1, 1, 1);
    Reports.ToolTip:AddDoubleLine(L["Remaining:"], (" %s "):format(BreakUpLargeNumbers(xpToNextLevel)), 1, 1, 1);
end

local function FormatPower(level, currXP, totalLevel, nextLevel)
	local calc1 = (currXP / totalLevel) * 100;
	local currentText = ("Level: %d (%s%d%%|r)"):format(level, percColors[calc1 >= 75 and 1 or (calc1 >= 50 and calc1 < 75) and 2 or (calc1 >= 25 and calc1 < 50) and 3 or (calc1 >= 0 and calc1 < 25) and 4], calc1);
	return currentText;
end


--[[
##########################################################
REPORT TEMPLATE
##########################################################
]]--
local REPORT_NAME = "Azerite";
local HEX_COLOR = "22FFFF";
--SV.media.color.green
--SV.media.color.normal
--r, g, b = 0.8, 0.8, 0.8
--local c = SV.media.color.green
--r, g, b = c[1], c[2], c[3]
local Report = Reports:NewReport(REPORT_NAME, {
	type = "data source",
	text = REPORT_NAME .. " Info",
	icon = [[Interface\Addons\SVUI_!Core\assets\icons\SVUI]]
});

Report.events = {"PLAYER_ENTERING_WORLD", "AZERITE_ITEM_EXPERIENCE_CHANGED"};

Report.OnEvent = function(self, event, ...)
    if (event == "AZERITE_ITEM_EXPERIENCE_CHANGED") then
        ReportBar.Populate(self);
    end
end

Report.Populate = function(self)
	if self.barframe:IsShown() then
		self.text:SetAllPoints(self);
		self.text:SetJustifyH("CENTER");
		self.barframe:Hide();
	end
    
    local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem(); 
	
	if (not azeriteItemLocation) then
        Reports.ToolTip:AddDoubleLine(L["No Heart of Azeroth"]);
		return; 
    end
	
    local xp, totalLevelXP = C_AzeriteItem.GetAzeriteItemXPInfo(azeriteItemLocation);
    local currentLevel = C_AzeriteItem.GetPowerLevel(azeriteItemLocation); 
    local xpToNextLevel = totalLevelXP - xp; 
    local text = FormatPower(currentLevel, xp, totalLevelXP, xpToNextLevel);
    self.text:SetText(text);
end

Report.OnEnter = function(self)
	SetTooltipText(self);
	Reports:ShowDataTip();
end

Report.OnInit = function(self)
	if(not self.InnerData) then
		self.InnerData = {};
	end
	Report.Populate(self);
end

--[[
##########################################################
BAR TYPE
##########################################################
]]--
local BAR_NAME = "Azerite Bar";
local ReportBar = Reports:NewReport(BAR_NAME, {
	type = "data source",
	text = BAR_NAME,
	icon = [[Interface\Addons\SVUI_!Core\assets\icons\SVUI]]
});

ReportBar.events = {"PLAYER_ENTERING_WORLD", "AZERITE_ITEM_EXPERIENCE_CHANGED"};

ReportBar.OnEvent = function(self, event, ...)
    if (event == "AZERITE_ITEM_EXPERIENCE_CHANGED") then
        ReportBar.Populate(self);
    end
end

ReportBar.Populate = function(self)
	if (not self.barframe:IsShown())then
		self.barframe:Show();
		self.barframe.icon.texture:SetTexture(SV.media.dock.azeriteLabel);
	end
	local bar = self.barframe.bar;
    
    local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem(); 
	
	if (not azeriteItemLocation) then
        bar:SetMinMaxValues(0, 1);
		bar:SetValue(0);
		self.text:SetText(L["No Heart of Azeroth"]);
		return; 
    end

    local xp, totalLevelXP = C_AzeriteItem.GetAzeriteItemXPInfo(azeriteItemLocation);
    local currentLevel = C_AzeriteItem.GetPowerLevel(azeriteItemLocation); 
    local xpToNextLevel = totalLevelXP - xp; 
    bar:SetMinMaxValues(0, totalLevelXP);
    bar:SetValue(xp);
    bar:SetStatusBarColor(0.9, 0.64, 0.37);
    local toSpend = "Level "..currentLevel;
    self.text:SetText(toSpend);
    self.barframe:Show();
end

ReportBar.OnEnter = function(self)
	SetTooltipText(self);
	Reports:ShowDataTip();
end

ReportBar.OnInit = function(self)
	if(not self.InnerData) then
		self.InnerData = {};
	end
	ReportBar.Populate(self);
	if (not self.barframe:IsShown())then
		self.barframe:Show();
		self.barframe.icon.texture:SetTexture(SV.media.dock.azeriteLabel);
	end
end
