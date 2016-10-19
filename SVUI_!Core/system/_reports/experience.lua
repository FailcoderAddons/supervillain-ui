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
local format = string.format;
local gsub = string.gsub;
--MATH
local math      = _G.math;
local min       = math.min
local UnitXP    = _G.UnitXP;
local UnitXPMax = _G.UnitXPMax;
local GetXPExhaustion  = _G.GetXPExhaustion;
--[[
##########################################################
GET ADDON DATA
##########################################################
]]--
local SV = select(2, ...)
local L = SV.L;
local LSM = _G.LibStub("LibSharedMedia-3.0")
local Reports = SV.Reports;
--[[
##########################################################
EXPERIENCE STATS
##########################################################
]]--
local HEX_COLOR = "22FFFF";
local TEXT_PATTERN = "|cff%s%s|r";
local playerName = UnitName("player");
local maxPlayerLevel = GetMaxPlayerLevel();

local function FormatExp(subset, value, maxValue, remain, exhaust)
	local trunc, calc;

	if(maxPlayerLevel == UnitLevel("player")) then return "|cff11CC00Max Level|r" end

	local expString,prefix,suffix = "","","";
	if(exhaust and exhaust > 0) then
		prefix = "|cff1188FF";
		suffix = "|r";
	end

	if(subset:find("XP")) then
	    if value >= 1e9 then
	        trunc = ("%.1fb"):format(value/1e9):gsub("%.?0+([kmb])$","%1")
	    elseif value >= 1e6 then
	        trunc = ("%.1fm"):format(value/1e6):gsub("%.?0+([kmb])$","%1")
	    elseif value >= 1e3 or value <= -1e3 then
	        trunc = ("%.1fk"):format(value/1e3):gsub("%.?0+([kmb])$","%1")
	    else
	        trunc = value
	    end

	    if(exhaust and exhaust > 0) then
			trunc = "|cff1188FF" .. trunc .. "|r";
		end

		if(subset:find("_Percent")) then
		    if(maxValue > 0) then
				if(value > 0) then
	    			calc = (value / maxValue) * 100
	    			calc = ("%d%%"):format(calc)
				else
					calc = 100
				end
		    else
		    	calc = 100
		    end
		    expString = prefix .. trunc .. suffix .. "  |cffAAAAAA=|r  " .. calc
		else
			expString = prefix .. trunc .. suffix .. "  |cffAAAAAA/|r  " .. maxValue
		end
	end

	if(subset:find("Remaining")) then
	    if(maxValue > 0) then
			remain = remain or (maxValue - value);
			if remain >= 1e9 then
				trunc = ("%.1fb"):format(remain/1e9):gsub("%.?0+([kmb])$","%1")
		    elseif remain >= 1e6 then
				trunc = ("%.1fm"):format(remain/1e6):gsub("%.?0+([kmb])$","%1")
		    elseif remain >= 1e3 or value <= -1e3 then
				trunc = ("%.1fk"):format(remain/1e3):gsub("%.?0+([kmb])$","%1")
		    else
				trunc = remain
		    end
		else
			remain = 0
			trunc = 0;
		end

		if(subset:find("_Percent")) then
		    if(maxValue > 0) then
				if(remain > 0) then
					calc = (remain / maxValue) * 100
					calc = ("%d%%"):format(calc)
				else
					calc = 100
				end
		    else
		    	calc = 100
		    end
		    expString = prefix .. trunc .. suffix .. "  |cffAAAAAA=|r  " .. calc
		else
			expString = prefix .. trunc .. suffix .. "  |cffAAAAAA/|r  " .. maxValue
		end
	end

    return expString
end

local function FetchExperience()
	local xp = UnitXP("player")
	if((not xp) or (xp <= 0)) then
		xp = 1
	end

	local mxp = UnitXPMax("player")
	if((not mxp) or (mxp <= 0)) then
		mxp = 1
	end

	local exp = GetXPExhaustion()
	if(not exp) then
		exp = 0
	end

	local rxp = mxp - xp;

	return xp,mxp,exp,rxp
end

-- local function CacheRepData(data)
-- 	local nextIndex = #data+1;
-- 	data[nextIndex] = {text = factionName, func = fn};
-- 	tsort(data, function(a,b) return a.text < b.text end)
-- end
--[[
##########################################################
STANDARD TYPE
##########################################################
]]--
local REPORT_NAME = "Experience";
local Report = Reports:NewReport(REPORT_NAME, {
	type = "data source",
	text = REPORT_NAME .. " Info",
	icon = [[Interface\Addons\SVUI_!Core\assets\icons\SVUI]]
});

Report.events = {"PLAYER_ENTERING_WORLD", "PLAYER_XP_UPDATE", "PLAYER_LEVEL_UP", "DISABLE_XP_GAIN", "ENABLE_XP_GAIN", "UPDATE_EXHAUSTION"};

Report.OnClick = function(self, button)
  SV.Dropdown:Open(self, self.InnerData, "Select Format")
end

Report.OnEvent = function(self, event, ...)
	local subset = self.ExpKey or "XP";
	if self.barframe:IsShown()then
		self.text:SetAllPoints(self)
		self.text:SetJustifyH("CENTER")
		self.barframe:Hide()
	end

	local XP, maxXP, exhaust, remaining = FetchExperience();
	local text = FormatExp(subset, XP, maxXP, remaining, exhaust);

	self.text:SetText(text)
end

Report.OnEnter = function(self)
	local subset = self.ExpKey or "XP";
	Reports:SetDataTip(self)
	local XP, maxXP, exhaust, remaining = FetchExperience();
	Reports.ToolTip:AddLine(L["Experience"])
	Reports.ToolTip:AddLine(" ")

	if((XP > 0) and (maxXP > 0)) then
		local calc1 = (XP / maxXP) * 100;
		local r_percent = (remaining / maxXP) * 100;
		local r_bars = r_percent / 5;
		Reports.ToolTip:AddDoubleLine(L["XP:"], (" %d  /  %d (%d%%)"):format(XP, maxXP, calc1), 1, 1, 1)
		Reports.ToolTip:AddDoubleLine(L["Remaining:"], (" %d (%d%% - %d "..L["Bars"]..")"):format(remaining, r_percent, r_bars), 1, 1, 1)
		if(exhaust > 0) then
			local calc = (exhaust / maxXP) * 100;
			Reports.ToolTip:AddDoubleLine(L["Rested:"], format(" + %d (%d%%)", exhaust, calc), 1, 1, 1)
		end
	end
	Reports.ToolTip:AddLine(" ")
  	Reports.ToolTip:AddDoubleLine("[Click]", "Change XP Format", 0,1,0, 0.5,1,0.5)
	Reports:ShowDataTip()
end
--[[
##########################################################
BAR TYPE
##########################################################
]]--
local BAR_NAME = "Experience Bar";
local ReportBar = Reports:NewReport(BAR_NAME, {
	type = "data source",
	text = BAR_NAME,
	icon = [[Interface\Addons\SVUI_!Core\assets\icons\SVUI]]
});

ReportBar.events = {"PLAYER_ENTERING_WORLD", "PLAYER_XP_UPDATE", "PLAYER_LEVEL_UP", "DISABLE_XP_GAIN", "ENABLE_XP_GAIN", "UPDATE_EXHAUSTION"};

ReportBar.OnEvent = function(self, event, ...)
	if (not self.barframe:IsShown())then
		self.barframe:Show()
		self.barframe.icon.texture:SetTexture(SV.media.dock.experienceLabel)
	end
	if not self.barframe.bar.extra:IsShown() then
		self.barframe.bar.extra:Show()
	end
	local bar = self.barframe.bar;
	local XP, maxXP, exhaust = FetchExperience()

	bar:SetMinMaxValues(0, maxXP)
	bar:SetValue(XP)
	bar:SetStatusBarColor(0, 0.5, 1)

	if(exhaust > 0) then
		local exhaust_value = min(XP + exhaust, maxXP);
		bar.extra:SetMinMaxValues(0, maxXP)
		bar.extra:SetValue(exhaust_value)
		bar.extra:SetStatusBarColor(0.8, 0.5, 1)
		bar.extra:SetAlpha(0.5)
	else
		bar.extra:SetMinMaxValues(0, 1)
		bar.extra:SetValue(0)
	end
	self.text:SetText("")
end

ReportBar.OnEnter = function(self)
	Reports:SetDataTip(self)
	local XP, maxXP, exhaust, remaining = FetchExperience()
	Reports.ToolTip:AddLine(L["Experience"])
	Reports.ToolTip:AddLine(" ")

	if((XP > 0) and (maxXP > 0)) then
		local subset = self.ExpKey or "XP";
		local calc1 = (XP / maxXP) * 100;
		local r_percent = (remaining / maxXP) * 100;
		local r_bars = r_percent / 5;
		Reports.ToolTip:AddDoubleLine(L["XP:"], (" %d  /  %d (%d%%)"):format(XP, maxXP, calc1), 1, 1, 1)
		Reports.ToolTip:AddDoubleLine(L["Remaining:"], (" %d (%d%% - %d "..L["Bars"]..")"):format(remaining, r_percent, r_bars), 1, 1, 1)
		if(exhaust > 0) then
			local calc = (exhaust / maxXP) * 100;
			Reports.ToolTip:AddDoubleLine(L["Rested:"], format(" + %d (%d%%)", exhaust, calc), 1, 1, 1)
		end
	end
	Reports:ShowDataTip()
end

Report.OnInit = function(self)
  if(not self.InnerData) then
    self.InnerData = {}
  end

  Reports:SetSubSettingsData('experience', 'table', {})

  local key = self:GetName()

  Reports.SubSettings["experience"][playerName][key] = Reports.SubSettings["experience"][playerName][key] or "XP";
  self.ExpKey = Reports.SubSettings["experience"][playerName][key]

  local fn1 = function()
    Reports.SubSettings["experience"][playerName][key] = "XP";
    self.ExpKey = "XP"
    Report.OnEvent(self)
  end

  local fn2 = function()
    Reports.SubSettings["experience"][playerName][key] = "XP_Percent";
    self.ExpKey = "XP_Percent"
    Report.OnEvent(self)
  end

  local fn3 = function()
    Reports.SubSettings["experience"][playerName][key] = "Remaining";
    self.ExpKey = "Remaining"
    Report.OnEvent(self)
  end

  local fn4 = function()
    Reports.SubSettings["experience"][playerName][key] = "Remaining_Percent";
    self.ExpKey = "Remaining_Percent"
    Report.OnEvent(self)
  end

  tinsert(self.InnerData, {text = "XP", func = fn1});
  tinsert(self.InnerData, {text = "XP_Percent", func = fn2});
  tinsert(self.InnerData, {text = "Remaining", func = fn3});
  tinsert(self.InnerData, {text = "Remaining_Percent", func = fn4});
end
