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
local LAD = LibStub("LibArtifactData-1.0");

--[[
##########################################################
UTILITIES
##########################################################
]]--
local function GetArtifactData()
	local artID = LAD:GetActiveArtifactID()
	if not artID then return false end

	local data = nil
	artID, data = LAD:GetArtifactInfo(artID)
	if not artID then return false end
	
	return true, data.numRanksPurchased, data.power, data.maxPower , data.numRanksPurchasable
end

local function SetTooltipText(report)
	Reports:SetDataTip(report)
	local isEquipped, rank, currentPower,powerToNextLevel,pointsToSpend = GetArtifactData()
	Reports.ToolTip:AddLine(L["Artifact Power"])
	Reports.ToolTip:AddLine(" ")

	if isEquipped then
		local calc1 = (currentPower / powerToNextLevel) * 100;
		Reports.ToolTip:AddDoubleLine(L["Rank:"], (" %d "):format(rank), 1, 1, 1)
		Reports.ToolTip:AddDoubleLine(L["Current Artifact Power:"], (" %d  /  %d (%d%%)"):format(currentPower, powerToNextLevel, calc1), 1, 1, 1)
		Reports.ToolTip:AddDoubleLine(L["Remaining:"], (" %d "):format(powerToNextLevel - currentPower), 1, 1, 1)
		Reports.ToolTip:AddDoubleLine(L["Points to Spend:"], format(" %d ", pointsToSpend), 1, 1, 1)
	else
		Reports.ToolTip:AddDoubleLine(L["No Artifact"])		
	end
end

local function FormatPower(rank, currentPower, powerForNextPoint, pointsToSpend)
	local currentText = ("%d(+%d) %d/%d"):format(rank, pointsToSpend, currentPower, powerForNextPoint);
	return currentText
end


--[[
##########################################################
REPORT TEMPLATE
##########################################################
]]--
local REPORT_NAME = "Artifact";
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

Report.events = {"PLAYER_ENTERING_WORLD"};

Report.OnEvent = function(self, event, ...)
	LAD.RegisterCallback(self,"ARTIFACT_ADDED", function () 
		Report.Populate(self)
	end)
	LAD.RegisterCallback(self,"ARTIFACT_ACTIVE_CHANGED", function () 	
		Report.Populate(self)
	end)
	LAD.RegisterCallback(self,"ARTIFACT_POWER_CHANGED", function () 
		Report.Populate(self)
	end)
end

Report.Populate = function(self)
	if self.barframe:IsShown() then
		self.text:SetAllPoints(self)
		self.text:SetJustifyH("CENTER")
		self.barframe:Hide()
	end

	local isEquipped,rank,currentPower,powerToNextLevel,pointsToSpend = GetArtifactData()

	if isEquipped then
		local text = FormatPower(rank, currentPower,powerToNextLevel,pointsToSpend);
		self.text:SetText(text)
	else
		self.text:SetText(L["No Artifact"])		
	end
end

Report.OnEnter = function(self)
	SetTooltipText(self)
	Reports:ShowDataTip()
end

Report.OnInit = function(self)

end

--[[
##########################################################
BAR TYPE
##########################################################
]]--
local BAR_NAME = "Artifact Bar";
local ReportBar = Reports:NewReport(BAR_NAME, {
	type = "data source",
	text = BAR_NAME,
	icon = [[Interface\Addons\SVUI_!Core\assets\icons\SVUI]]
});

ReportBar.events = {"PLAYER_ENTERING_WORLD"};

ReportBar.OnEvent = function(self, event, ...)
	LAD.RegisterCallback(self,"ARTIFACT_ADDED", function () 
		ReportBar.Populate(self)
	end)
	LAD.RegisterCallback(self,"ARTIFACT_ACTIVE_CHANGED", function () 	
		ReportBar.Populate(self)
	end)
	LAD.RegisterCallback(self,"ARTIFACT_POWER_CHANGED", function () 
		ReportBar.Populate(self)
	end)
end

ReportBar.Populate = function(self)
	if (not self.barframe:IsShown())then
		self.barframe:Show()
		self.barframe.icon.texture:SetTexture(SV.media.dock.artifactLabel)
	end
	local bar = self.barframe.bar;

	local isEquipped, rank, currentPower, powerToNextLevel, pointsToSpend = GetArtifactData()

	if isEquipped then
		bar:SetMinMaxValues(0, powerToNextLevel)
		bar:SetValue(currentPower)
		bar:SetStatusBarColor(0.9, 0.64, 0.37)
		local toSpend = "" 
		if pointsToSpend>0 then
			toSpend = " (+"..pointsToSpend..")"
		end
		self.text:SetText(rank..toSpend)
	else
		bar:SetMinMaxValues(0, 1)
		bar:SetValue(0)
		self.text:SetText(L["No Artifact"])
	end
end

ReportBar.OnEnter = function(self)
	SetTooltipText(self)
	Reports:ShowDataTip()
end

ReportBar.OnInit = function(self)

end
