--[[
##############################################################################
S U P E R - V I L L A I N - T H E M E   By: Failcoder
##############################################################################
##########################################################
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local unpack 	= _G.unpack;
local select 	= _G.select;
local math 		= _G.math;
--[[ MATH METHODS ]]--
local random = math.random;
--[[
##########################################################
GET ADDON DATA
##########################################################
]]--
local SV = _G["SVUI"];
local LSM = _G.LibStub("LibSharedMedia-3.0");

LSM:Register("background", "SVUI Backdrop", [[Interface\DialogFrame\UI-DialogBox-Background]])

SV.DialogFontDefault = "SVUI Default Font";

if(GetLocale() == "enUS") then
	SV:AssignMedia("font", "dialog", "SVUI Dialog Font", 10, "OUTLINE")
end

SV:AssignMedia("font", "number", "SVUI Caps Font", 14, "OUTLINE");
SV:AssignMedia("font", "number_big", "SVUI Caps Font", 18, "OUTLINE");
SV:AssignMedia("font", "header", "SVUI Caps Font", 18, "OUTLINE");
SV:AssignMedia("font", "combat", "SVUI Combat Font", 64, "OUTLINE");
SV:AssignMedia("font", "alert", "SVUI Default Font", 20, "OUTLINE");
SV:AssignMedia("font", "zone", "SVUI Default Font", 16, "OUTLINE");
SV:AssignMedia("font", "aura", "SVUI Caps Font", 14, "OUTLINE");
SV:AssignMedia("font", "data", "SVUI Caps Font", 14, "OUTLINE");
SV:AssignMedia("font", "narrator", "SVUI Default Font", 14, "OUTLINE");
SV:AssignMedia("font", "lootnumber", "SVUI Caps Font", 14, "OUTLINE");
SV:AssignMedia("font", "rollnumber", "SVUI Caps Font", 14, "OUTLINE");
SV:AssignMedia("background", "default", "SVUI Backdrop", 0, false);
SV:AssignMedia("background", "pattern", "SVUI Backdrop", 0, false);
SV:AssignMedia("background", "premium", "SVUI Backdrop", 0, false);
SV:AssignMedia("background", "button", "SVUI Default BG", 0, false);
SV:AssignMedia("background", "unitlarge", "SVUI Backdrop", 0, false);
SV:AssignMedia("background", "unitsmall", "SVUI Backdrop", 0, false);
SV:AssignMedia("button", "round", [[Interface\AddOns\SVUITheme_Simple\ROUND-SIMPLE]]);
SV:AssignMedia("color", "button", 0, 0, 0, 0.5);
SV:AssignMedia("template", "Default", "SVUITheme_Simple_Default");
SV:AssignMedia("template", "Button", "SVUITheme_Simple_Default");
SV:AssignMedia("template", "DockButton", "SVUITheme_Simple_DockButton");
SV:AssignMedia("template", "Pattern", "SVUITheme_Simple_Default");
SV:AssignMedia("template", "Premium", "SVUITheme_Simple_Default");
SV:AssignMedia("template", "Model", "SVUITheme_Simple_Default");
SV:AssignMedia("template", "Window", "SVUITheme_Simple_Default");
SV:AssignMedia("template", "Window2", "SVUITheme_Simple_Default");
SV:AssignMedia("template", "Minimap", "SVUITheme_Simple_Minimap");
SV:AssignMedia("template", "ActionPanel", "SVUITheme_Simple_ActionPanel");
SV:AssignMedia("template", "Container", "SVUITheme_Simple_Default");

local _RefreshZoneText = function(self)
	if(self.InfoTop:IsShown()) then
		self.InfoTop:Hide();
	end
	  -- JV - 20160918 Fix error around expectation that SV.db.Maps exists which might not be so if SVUI_Maps is not loaded.
 	if ((SV.Maps and SV.db.Maps) and (not SV.db.Maps.locationText or SV.db.Maps.locationText == "HIDE")) then
		self.InfoBottom:Hide();
 	else
		self.InfoBottom:Show();
		local zone = GetRealZoneText() or UNKNOWN
		self.InfoBottom.Text:SetText(zone)
	end
end

local UpdateBackdrop = function(self)
	local current = SV.Dock.private.Opacity[self:GetName()];
	if(SV.db.Dock.backdrop and (not SV.Dock.private.Disabled[self:GetName() .. 'Button'])) then
		self.backdrop:SetAlpha(1);
	else
		self.backdrop:SetAlpha(0);
	end
	self:SetAlpha(current or 1);
end

local _SetThemedBackdrop = function(frame, isBottom)
	local backdrop = CreateFrame("Frame", nil, frame)
	backdrop:SetAllPoints(frame)
	backdrop:SetFrameStrata("BACKGROUND")
	backdrop:SetBackdrop({
	    bgFile = [[Interface\DialogFrame\UI-DialogBox-Background]],
	    tile = false,
	    tileSize = 0,
	    edgeFile = [[Interface\BUTTONS\WHITE8X8]],
	    edgeSize = 1,
	    insets =
	    {
	        left = 0,
	        right = 0,
	        top = 0,
	        bottom = 0,
	    },
	});
	backdrop:SetBackdropColor(0,0,0,0.5);
	backdrop:SetBackdropBorderColor(0,0,0,0.8);

	frame.backdrop = backdrop

	UpdateBackdrop(frame);
	frame.UpdateBackdrop = UpdateBackdrop;
end

local _SetBorderTheme = function(self)
	self.Top:SetPoint("TOPLEFT", SV.Screen, "TOPLEFT", -1, 1)
	self.Top:SetPoint("TOPRIGHT", SV.Screen, "TOPRIGHT", 1, 1)
	self.Top:SetHeight(10)
	self.Top:SetBackdrop({
		bgFile = [[Interface\BUTTONS\WHITE8X8]],
		edgeFile = [[Interface\BUTTONS\WHITE8X8]],
		tile = false,
		tileSize = 0,
		edgeSize = 1,
		insets = {left = 0, right = 0, top = 0, bottom = 0}
	})
	self.Top:SetBackdropColor(0,0,0,0)
	self.Top:SetBackdropBorderColor(0,0,0,0)
	self.Top:SetFrameLevel(0)
	self.Top:SetFrameStrata('BACKGROUND')
	self.Top:SetScript("OnShow", function(self)
		self:SetFrameLevel(0)
		self:SetFrameStrata('BACKGROUND')
	end)

	self.Bottom:SetPoint("BOTTOMLEFT", SV.Screen, "BOTTOMLEFT", -1, -1)
	self.Bottom:SetPoint("BOTTOMRIGHT", SV.Screen, "BOTTOMRIGHT", 1, -1)
	self.Bottom:SetHeight(10)
	self.Bottom:SetBackdrop({
		bgFile = [[Interface\BUTTONS\WHITE8X8]],
		edgeFile = [[Interface\BUTTONS\WHITE8X8]],
		tile = false,
		tileSize = 0,
		edgeSize = 1,
		insets = {left = 0, right = 0, top = 0, bottom = 0}
	})
	self.Bottom:SetBackdropColor(0,0,0,0)
	self.Bottom:SetBackdropBorderColor(0,0,0,0)
	self.Bottom:SetFrameLevel(0)
	self.Bottom:SetFrameStrata('BACKGROUND')
	self.Bottom:SetScript("OnShow", function(self)
		self:SetFrameLevel(0)
		self:SetFrameStrata('BACKGROUND')
	end)
end

function SV:LoadTheme()
	if(self.defaults.UnitFrames) then
		self:AssignMedia("font", "unitprimary", "SVUI Caps Font", 14, "OUTLINE");
		self:AssignMedia("font", "unitsecondary", "SVUI Caps Font", 14, "OUTLINE");
		self:AssignMedia("font", "unitaurabar", "SVUI Default Font", 14, "OUTLINE");
		self:AssignMedia("font", "unitaura", "SVUI Default Font", 14, "OUTLINE");
	end
	if(self.defaults.Maps) then
		self:AssignMedia("font", "mapinfo", "SVUI Default Font", 14, "OUTLINE");
		self:AssignMedia("font", "mapcoords", "SVUI Caps Font", 14, "OUTLINE");
		self.defaults.Maps.locationText = "SIMPLE";
		self.defaults.Maps.bordersize = 0;
		self.defaults.Maps.bordercolor = "dark";
	end
	if(self.Maps) then
		self.Maps.RefreshZoneText = _RefreshZoneText
	end

	self.Dock.SetThemedBackdrop = _SetThemedBackdrop
	self.Dock.SetBorderTheme = _SetBorderTheme
end
