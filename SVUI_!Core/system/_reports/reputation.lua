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
--[[
##########################################################
REPUTATION STATS
##########################################################
]]--
local HEX_COLOR = "22FFFF";
local TEXT_PATTERN = "|cff22EF5F%s|r|cff888888 - [|r%d%%|cff888888]|r";
local standingName = {
	[1] = "Hated",
	[2] = "Hostile",
	[3] = "Unfriendly",
	[4] = "Neutral",
	[5] = "Friendly",
	[6] = "Honored",
	[7] = "Revered",
	[8] = "Exalted"
}

local function TruncateString(value)
    if value >= 1e9 then
        return ("%.1fb"):format(value/1e9):gsub("%.?0+([kmb])$","%1")
    elseif value >= 1e6 then
        return ("%.1fm"):format(value/1e6):gsub("%.?0+([kmb])$","%1")
    elseif value >= 1e3 or value <= -1e3 then
        return ("%.1fk"):format(value/1e3):gsub("%.?0+([kmb])$","%1")
    else
        return value
    end
end

local sort_menu_fn = function(a,b) 
	if (a ~= nil and b ~= nil) then 
		if (a.text ~= nil and b.text ~= nil) then
			return a.text < b.text
		end
	end
	return false 
end;

local function CacheRepData(data)
	local count = 1;
	local savedCount = #data;
	ExpandAllFactionHeaders();
	local totalFactions = GetNumFactions();
	local maxCount = totalFactions;
	if(savedCount > totalFactions) then maxCount = savedCount; end

	for i=1, maxCount do
		if(i <= totalFactions) then
			local factionName, description, standingID, barMin, barMax, barValue, _, _, isHeader, _, hasRep, isWatched, isChild = GetFactionInfo(i)

			if((not isHeader) and standingID > 0) then
				if not IsFactionInactive(i) then
					local fn = function()
						local active = GetWatchedFactionInfo()
						if factionName ~= active then
							SetWatchedFactionIndex(i)
						end
					end
					data[count] = {text = factionName, func = fn};
					--DEFAULT_CHAT_FRAME:AddMessage("Faction: " .. data[count].text .. " - " .. count)
					count=count+1;
				end
			end
		else
			tremove(data, count);
		end
	end
	if #data > 0 then
		tsort(data, sort_menu_fn);
	end
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

Report.events = {"PLAYER_ENTERING_WORLD", "UPDATE_FACTION"};

Report.OnEvent = function(self, event, ...)
	if self.barframe:IsShown()then
		self.text:SetAllPoints(self)
		self.text:SetJustifyH("CENTER")
		self.barframe:Hide()
		self.text:SetAlpha(1)
		self.text:SetShadowOffset(2, -4)
	end
	local ID = 100
	local friendText
	local name, reaction, min, max, value = GetWatchedFactionInfo()
	local numFactions = GetNumFactions();
	if not name then
		self.text:SetText("No watched factions")
	else
		for i=1, numFactions do
			local factionName, description, standingID, barMin, barMax, barValue, _, _, _, _, hasRep, isWatched, isChild = GetFactionInfo(i);
			local friendID, friendRep, friendMaxRep, _, _, _, friendTextLevel = GetFriendshipReputation(isChild);
			if(not factionName or (name == "No watched factions") or (name == factionName)) then
				if friendID ~= nil then
					friendText = friendTextLevel
				else
					ID = standingID
				end
			end
		end
		friendText = friendText or _G["FACTION_STANDING_LABEL"..ID] or " ";
		self.text:SetFormattedText(TEXT_PATTERN , friendText, ((value - min) / (max - min) * 100))
	end
end

Report.OnClick = function(self, button)
	CacheRepData(self.InnerData)
	SV.Dropdown:Open(self, self.InnerData, "Select Faction")
end

Report.OnEnter = function(self)
	Reports:SetDataTip(self)
	local name, reaction, min, max, value, factionID = GetWatchedFactionInfo()
	local friendID, _, _, _, _, _, friendTextLevel = GetFriendshipReputation(factionID);
	if not name then
		Reports.ToolTip:AddLine("No Watched Factions")
	else
		Reports.ToolTip:AddLine(name)
		Reports.ToolTip:AddLine(' ')
		Reports.ToolTip:AddDoubleLine(STANDING..':', friendID and friendTextLevel or _G['FACTION_STANDING_LABEL'..reaction], 1, 1, 1)
		Reports.ToolTip:AddDoubleLine(REPUTATION..':', format('%d / %d (%d%%)', value - min, max - min, (value - min) / (max - min) * 100), 1, 1, 1)
	end
	Reports.ToolTip:AddLine(" ", 1, 1, 1)
	Reports.ToolTip:AddDoubleLine("[Click]", "Change Watched Faction", 0,1,0, 0.5,1,0.5)
	Reports:ShowDataTip(true)
end

Report.OnInit = function(self)
	if(not self.InnerData) then
		self.InnerData = {}
	end
	CacheRepData(self.InnerData)
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

ReportBar.events = {"PLAYER_ENTERING_WORLD", "UPDATE_FACTION"};

ReportBar.OnEvent = function(self, event, ...)
	if not self.barframe:IsShown()then
		self.barframe:Show()
		self.barframe.icon.texture:SetTexture(SV.media.dock.reputationLabel)
		self.text:SetAlpha(1)
		self.text:SetShadowOffset(1, -2)
	end
	local bar = self.barframe.bar;
	local name, reaction, min, max, value = GetWatchedFactionInfo()
	local numFactions = GetNumFactions();
	if not name then
		bar:SetStatusBarColor(0,0,0)
		bar:SetMinMaxValues(0,1)
		bar:SetValue(0)
		self.text:SetText("No Faction")
	else
		for i=1, numFactions do
			local factionName, description, standingID, barMin, barMax, barValue, _, _, _, _, hasRep, isWatched, isChild = GetFactionInfo(i);
			if(isChild) then
				local friendID, friendRep, friendMaxRep, _, _, _, friendTextLevel, friendThreshold, nextFriendThreshold = GetFriendshipReputation(isChild);
				if friendID ~= nil then
					min = friendThreshold
					max = friendMaxRep
					value = friendRep
				end
			end
		end
		local txt = standingName[reaction];
		local color = FACTION_BAR_COLORS[reaction]
		bar:SetStatusBarColor(color.r, color.g, color.b)
		bar:SetMinMaxValues(min, max)
		bar:SetValue(value)
		self.text:SetText(txt)
	end
end

ReportBar.OnClick = function(self, button)
	CacheRepData(self.InnerData)
	SV.Dropdown:Open(self, self.InnerData, "Select Faction")
end

ReportBar.OnEnter = function(self)
	Reports:SetDataTip(self)
	local name, reaction, min, max, value, factionID = GetWatchedFactionInfo()
	local friendID, _, _, _, _, _, friendTextLevel = GetFriendshipReputation(factionID);
	if not name then
		Reports.ToolTip:AddLine("No Watched Factions")
	else
		Reports.ToolTip:AddLine(name)
		Reports.ToolTip:AddLine(' ')
		Reports.ToolTip:AddDoubleLine(STANDING..':', friendID and friendTextLevel or _G['FACTION_STANDING_LABEL'..reaction], 1, 1, 1)
		Reports.ToolTip:AddDoubleLine(REPUTATION..':', format('%d / %d (%d%%)', value - min, max - min, (value - min) / (max - min) * 100), 1, 1, 1)
	end
	Reports.ToolTip:AddLine(" ", 1, 1, 1)
	Reports.ToolTip:AddDoubleLine("[Click]", "Change Watched Faction", 0,1,0, 0.5,1,0.5)
	Reports:ShowDataTip(true)
end

ReportBar.OnInit = function(self)
	if(not self.InnerData) then
		self.InnerData = {}
	end
	CacheRepData(self.InnerData)
end
