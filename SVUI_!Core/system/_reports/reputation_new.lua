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
local table     = _G.table;
local twipe     = table.wipe;
local tsort     = table.sort;
--[[ STRING METHODS ]]--
local format, gsub = string.format, string.gsub;
--[[
##########################################################
GET ADDON DATA
##########################################################
]]--
local SV = select(2, ...)
local L = SV.L;
local Reports = SV.Reports;
local LRD = LibStub("LibReputationData-1.0");
--[[
##########################################################
REPUTATION STATS
##########################################################
]]--
local HEX_COLOR = "22FFFF";
local TEXT_PATTERN = "|cff22EF5F%s|r|cff888888 - [|r%d%%|cff888888]|r";
local FACTION_BAR_COLORS = _G.FACTION_BAR_COLORS;

local sort_menu_fn = function(a,b) 
	if (a ~= nil and b ~= nil) then 
		if (a.text ~= nil and b.text ~= nil) then
			return a.text < b.text
		end
	end
	return false 
end;

local function CacheRepData(data)
	local count = 1
	local factions = LRD:GetAllActiveFactionsInfo();
	if not factions then return end

	twipe(data)

	for i=1, #factions do
		if(factions[i].isActive and (not factions[i].isHeader)) then
			local factionIndex = tonumber(factions[i].factionIndex)
			local fn = function()
				local active = LRD:GetWatchedFactionIndex()
				if factionIndex ~= active then
					LRD:SetWatchedFaction(factionIndex)
				end
			end
			tinsert(data,{text = factions[i].name, func = fn});
			count=count+1;
		end
	end
	if #data > 0 then
		tsort(data, sort_menu_fn);
	end
end

local function DoTooltip(self)
	Reports:SetDataTip(self)
	local factionIndex, faction = LRD:GetReputationInfo()
	if not factionIndex then
		Reports.ToolTip:AddLine("No Watched Factions")
	else
		Reports.ToolTip:AddLine(faction.name)
		Reports.ToolTip:AddLine(' ')
		Reports.ToolTip:AddDoubleLine(STANDING..':', faction.standing, 1, 1, 1)
		if (faction.standing == "Exalted") then
			Reports.ToolTip:AddDoubleLine(REPUTATION..':', '24,000 / 24,000 (100%)', 1, 1, 1)
		else
			Reports.ToolTip:AddDoubleLine(REPUTATION..':', format('%d / %d (%d%%)', faction.value - faction.min, faction.max - faction.min, (faction.value - faction.min) / (faction.max - faction.min) * 100), 1, 1, 1)
		end
	end
	Reports.ToolTip:AddLine(" ", 1, 1, 1)
	Reports.ToolTip:AddDoubleLine("[Click]", "Change Watched Faction", 0,1,0, 0.5,1,0.5)
	Reports:ShowDataTip(true)
end
--[[
##########################################################
STANDARD TYPE
##########################################################
]]--

local REPORT_NAME = "Reputation";
local Report = Reports:NewReport(REPORT_NAME, {
	type = "data source",
	text = REPORT_NAME .. " Info",
	icon = [[Interface\Addons\SVUI_!Core\assets\icons\SVUI]]
});


Report.Populate = function(self)
	if self.barframe:IsShown()then
		self.text:SetAllPoints(self)
		self.text:SetJustifyH("CENTER")
		self.barframe:Hide()
		self.text:SetAlpha(1)
		self.text:SetShadowOffset(2, -4)
	end
	local factionIndex, faction = LRD:GetReputationInfo()

	if not factionIndex then
		self.text:SetText("No watched factions")
	else
		self.text:SetFormattedText(TEXT_PATTERN , faction.standing, ((faction.value - faction.min) / (faction.max - faction.min) * 100))
	end
end

Report.OnClick = function(self, button)
	SV.Dropdown:Open(self, self.InnerData, "Select Faction")
end

Report.OnEnter = function(self)
	DoTooltip(self)
end

Report.OnInit = function(self)
	LRD.RegisterCallback(self,"FACTIONS_LOADED", function () 	
		if(not self.InnerData) then
			self.InnerData = {}
		end
		CacheRepData(self.InnerData)
		Report.Populate(self)
	end)
	LRD.RegisterCallback(self, "REPUTATION_CHANGED", function() 
		Report.Populate(self)
	end)
	LRD:ForceUpdate()
end
--[[
##########################################################
BAR TYPE
##########################################################
]]--
local BAR_NAME = "Reputation Bar";
local ReportBar = Reports:NewReport(BAR_NAME, {
	type = "data source",
	text = BAR_NAME,
	icon = [[Interface\Addons\SVUI_!Core\assets\icons\SVUI]]
});


ReportBar.Populate = function(self)
	if not self.barframe:IsShown()then
		self.barframe:Show()
		self.barframe.icon.texture:SetTexture(SV.media.dock.reputationLabel)
		self.text:SetAlpha(1)
		self.text:SetShadowOffset(1, -2)
	end
	local bar = self.barframe.bar;

	local factionIndex, faction = LRD:GetReputationInfo()

	if not factionIndex then
		bar:SetStatusBarColor(0,0,0)
		bar:SetMinMaxValues(0,1)
		bar:SetValue(0)
		self.text:SetText("No Faction")
	else
		local color = FACTION_BAR_COLORS[faction.standingID]
		bar:SetStatusBarColor(color.r, color.g, color.b)
		bar:SetMinMaxValues(faction.min, faction.max)
		bar:SetValue(faction.value)
		self.text:SetText(faction.standing)
	end
end

ReportBar.OnClick = function(self, button)
	SV.Dropdown:Open(self, self.InnerData, "Select Faction")
end

ReportBar.OnEnter = function(self)
	DoTooltip(self)
end

ReportBar.OnInit = function(self)
	LRD.RegisterCallback(self,"FACTIONS_LOADED", function () 	
		if(not self.InnerData) then
			self.InnerData = {}
		end
		CacheRepData(self.InnerData)
		ReportBar.Populate(self)
	end)
	LRD.RegisterCallback(self, "REPUTATION_CHANGED", function() 
		ReportBar.Populate(self)
	end)
	LRD:ForceUpdate()
end
