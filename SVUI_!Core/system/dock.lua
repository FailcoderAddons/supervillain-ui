--[[
##############################################################################
S V U I   By: Failcoder
############################################################################## ]]--
--[[ GLOBALS ]]--
local _G = _G;
local unpack        = _G.unpack;
local select        = _G.select;
local assert        = _G.assert;
local type          = _G.type;
local error         = _G.error;
local pcall         = _G.pcall;
local print         = _G.print;
local ipairs        = _G.ipairs;
local pairs         = _G.pairs;
local tostring      = _G.tostring;
local tonumber      = _G.tonumber;

--STRING
local string        = _G.string;
local upper         = string.upper;
local format        = string.format;
local find          = string.find;
local match         = string.match;
local gsub          = string.gsub;
local split 		= string.split;
--TABLE
local table 		= _G.table;
local tinsert       = _G.tinsert;
local tremove       = _G.tremove;
local wipe 			= _G.wipe;
local tsort 		= table.sort;
--MATH
local math      	= _G.math;
local random 		= math.random;
local min 			= math.min;
local floor         = math.floor;
local ceil          = math.ceil;
local parsefloat 	= math.parsefloat;
--BLIZZARD API
local InCombatLockdown     	= _G.InCombatLockdown;
local CreateFrame          	= _G.CreateFrame;
--[[
##########################################################
ADDON
##########################################################
]]--
local SV = select(2, ...);
local L = SV.L;
local MOD = SV:NewPackage("Dock", L["Docks"]);
--[[
##########################################################
LOCALS
##########################################################
]]--
-- SV.SpecialFX:Register("dragging_highlight", [[Spells\Warlock_bodyofflames_medium_state_shoulder_right_purple.m2]], -20, 50, 20, -50, 0.35, 0, 0.5)
SV.SpecialFX:Register("dragging_highlight_top", [[Spells\Creature_spellportal_blue_clickable.m2]], 0, 0, 0, -80, 0.8, 0, 2.5)
SV.SpecialFX:Register("dragging_highlight_bottom", [[Spells\Creature_spellportal_blue_clickable.m2]], 0, 80, 0, 0, 0.9, 0, -0.25)

local ToggleDraggingMode;
local DOCK_CHECK, DRAG_LASTINDEX, DRAG_ORDERINDEX, DRAG_TARGETBAR, DRAG_BUTTONWIDTH, DRAG_ENABLED;
local ORDER_TEMP, DOCK_REGISTRY, DOCK_DROPDOWN_OPTIONS = {}, {}, {};
local DOCK_LOCATIONS = {
	["BottomLeft"] = {1, "LEFT", true, "ANCHOR_TOPLEFT"},
	["BottomRight"] = {-1, "RIGHT", true, "ANCHOR_TOPLEFT"},
	["TopLeft"] = {1, "LEFT", false, "ANCHOR_BOTTOMLEFT"},
	["TopRight"] = {-1, "RIGHT", false, "ANCHOR_BOTTOMLEFT"},
};
--[[
	Quick explaination of what Im doing with all of these locals...
	Unlike many of the other modules, Chat has to continuously
	reference config settings which can start to get sluggish. What
	I have done is set local variables for every database value
	that the module can read efficiently. The function "UpdateLocals"
	is used to refresh these any time a change is made to configs
	and once when the mod is loaded.
]]--
-- local DOCK_WIDTH = 412;
-- local DOCK_HEIGHT = 224;
-- local DOCK_ALPHA = 1;
--[[
##########################################################
THEMEABLE ITEMS
##########################################################
]]--
MOD.ButtonSound = SV.Sounds:Blend("DockButton", "Buttons", "Levers");
MOD.ErrorSound = SV.Sounds:Blend("Malfunction", "Sparks", "Wired");

local function getParentAnchor(location)
	if (location:find("BOTTOM")) then
		return MOD.Bottom;
	end
	return MOD.Top;
end

local function copyTable(tab)
	local copy = {};
	for k, v in pairs(tab) do
		if ( type(v) == "table" ) then
			copy[k] = copyTable(v);
		else
			copy[k] = v;
		end
	end
	return copy;
end

local function GetDockDimensions(location)
	local width, height;
	local isTop = location:find("Top")
	local isLeft = location:find("Left")
	if(isTop) then
		if(isLeft) then
			width = SV.db.Dock.dockTopLeftWidth;
			height = SV.db.Dock.dockTopLeftHeight;
		else
			width = SV.db.Dock.dockTopRightWidth;
			height = SV.db.Dock.dockTopRightHeight;
		end
	else
		if(isLeft) then
			width = SV.db.Dock.dockLeftWidth;
			height = SV.db.Dock.dockLeftHeight;
			if(MOD.private.LeftExpanded) then
				height = height + 300
			end
		else
			width = SV.db.Dock.dockRightWidth;
			height = SV.db.Dock.dockRightHeight;
			if(MOD.private.RightExpanded) then
				height = height + 300
			end
		end
	end

	return width, height;
end

local function SetDockDimensions(location, width, height, buttonSize)
	local isTop = location:find("Top")
	local isLeft = location:find("Left")
	if(isTop) then
		if(isLeft) then
			SV.db.Dock.dockTopLeftWidth = width;
			if(not buttonSize) then
				SV.db.Dock.dockTopLeftHeight = height;
			end
		else
			SV.db.Dock.dockTopRightWidth = width;
			if(not buttonSize) then
				SV.db.Dock.dockTopRightHeight = height;
			end
		end
	else
		if(isLeft) then
			SV.db.Dock.dockLeftWidth = width;
			if(not buttonSize) then
				SV.db.Dock.dockLeftHeight = height;
			end
		else
			SV.db.Dock.dockRightWidth = width;
			if(not buttonSize) then
				SV.db.Dock.dockRightHeight = height;
			end
		end
	end

	if(buttonSize) then
		SV.db.Dock.buttonSize = height;
	end
end

local dockPostSizeFunc = function(self, width, height)
	local name = self:GetName()
	SetDockDimensions(name, width, height)
	MOD:Refresh()
end

local dockBarPostSizeFunc = function(self, width, height)
	local name = self:GetName()
	SetDockDimensions(name, width, height, true)
	MOD:Refresh()
end

local function SaveCurrentPosition(button)
	if((not button) or (not MOD.private.Dimensions)) then return end

	local anchor1, parent, anchor2, x, y = button:GetPoint();

	if(anchor1 and anchor2 and x and y) then
		local parentName;
		if(not parent or (not parent.GetName) or (not parent:GetName())) then
			parentName = "UIParent"
		else
			parentName = parent:GetName()
		end

		local name = button:GetName();
		local width, height = 0,0;
		if(button.FrameLink) then
			local frame = button.FrameLink;
			frame:ClearAllPoints();
			frame:SetPoint("BOTTOMLEFT", button, "TOPLEFT", -3, 6);
			if(frame.UpdateBackdrop) then frame:UpdateBackdrop() end
			local saved = MOD.private.Dimensions[name];
			local currentWidth, currentHeight = frame:GetSize();
			if(saved) then
				local _, _, _, _, _, w, h = split("|", saved);
				width, height = w, h
				if((currentWidth ~= w) or (currentHeight ~= h)) then
					frame:SetSize(w, h)
				end
			else
				width, height = currentWidth, currentHeight;
			end
			if((not width) or (not height)) then
				width, height = 0,0;
			end
		end
		local result = ("%s|%s|%s|%d|%d|%d|%d"):format(anchor1, parentName, anchor2, parsefloat(x), parsefloat(y), parsefloat(width), parsefloat(height))
		MOD.private.Dimensions[name] = result;
	end
end

local function SaveCurrentDimensions(button)
	if((not button) or (not MOD.private.Dimensions)) then return end

	if(button.FrameLink) then
		local name = button:GetName();
		local saved = MOD.private.Dimensions[name];
		local anchor1, parent, anchor2, x, y, width, height;
		if(saved) then
			anchor1, parent, anchor2, x, y = split("|", saved);
		else
			anchor1, parent, anchor2, x, y = button:GetPoint();
		end
		local frame = button.FrameLink;
		width, height = frame:GetSize()
		if((not width) or (not height)) then
			-- print(frame:GetSize())
			width, height = 0, 0
		end
		local parentName;
		if(not parent or (not parent.GetName) or (not parent:GetName())) then
			parentName = "UIParent"
		else
			parentName = parent:GetName()
		end
		local result = ("%s|%s|%s|%d|%d|%d|%d"):format(anchor1, parentName, anchor2, parsefloat(x), parsefloat(y), parsefloat(width), parsefloat(height))
		frame:ClearAllPoints();
		frame:SetPoint("BOTTOMLEFT", button, "TOPLEFT", -3, 6);
		if(frame.UpdateBackdrop) then
			frame:UpdateBackdrop()
		end
		MOD.private.Dimensions[name] = result;
	end
end

local function LoadSavedDimensions(button)
	local saved = MOD.private.Dimensions[button:GetName()];
	if(saved and (type(saved) == "string") and (saved ~= 'TBD')) then
		local anchor1, anchorParent, anchor2, xPos, yPos, width, height = split("|", saved)
		button:ClearAllPoints()
		button:SetPoint(anchor1, anchorParent, anchor2, xPos, yPos)

		local frame = button.FrameLink;
		if(frame) then
			frame:ClearAllPoints();
			frame:SetPoint("BOTTOMLEFT", button, "TOPLEFT", -3, 6);
			if((not width) or (not height)) then
				width, height = frame:GetSize()
			end
			frame:SetSize(width, height)
			if(frame.UpdateBackdrop) then frame:UpdateBackdrop() end
		end
	end
end

local function ScreenBorderVisibility()
	if SV.db.Dock.bottomPanel then
		SVUI_DockBarBottom:Show()
	else
		SVUI_DockBarBottom:Hide()
	end

	if SV.db.Dock.topPanel then
		SVUI_DockBarTop:Show()
	else
		SVUI_DockBarTop:Hide()
	end
end

local function SetBasicBackdrop(frame)
	local backdrop = CreateFrame("Frame", nil, frame)
	backdrop:InsetPoints(frame,4,4)
	backdrop:SetFrameStrata("BACKGROUND")

	local underlay = backdrop:CreateTexture(nil, "BORDER")
	underlay:InsetPoints(backdrop)
	underlay:SetColorTexture(0, 0, 0, 0.5)

	local left = backdrop:CreateTexture(nil, "OVERLAY")
	left:SetColorTexture(0, 0, 0, 1)
	left:SetPoint("TOPLEFT", 1, -1)
	left:SetPoint("BOTTOMLEFT", -1, -1)
	left:SetWidth(2)

	local right = backdrop:CreateTexture(nil, "OVERLAY")
	right:SetColorTexture(0, 0, 0, 1)
	right:SetPoint("TOPRIGHT", -1, -1)
	right:SetPoint("BOTTOMRIGHT", -1, -1)
	right:SetWidth(2)

	local bottom = backdrop:CreateTexture(nil, "OVERLAY")
	bottom:SetColorTexture(0, 0, 0, 1)
	bottom:SetPoint("BOTTOMLEFT", 1, -1)
	bottom:SetPoint("BOTTOMRIGHT", -1, -1)
	bottom:SetHeight(2)

	local top = backdrop:CreateTexture(nil, "OVERLAY")
	top:SetColorTexture(0, 0, 0, 1)
	top:SetPoint("TOPLEFT", 1, -1)
	top:SetPoint("TOPRIGHT", -1, 1)
	top:SetHeight(2)

	return backdrop
end

local UpdateBackdrop = function(self)
	local centerX, centerY = self:GetCenter()
	local screenHeight = GetScreenHeight()
	local heightTop = screenHeight  *  0.75;
	local current = MOD.private.Opacity[self:GetName()];

	if(SV.db.Dock.backdrop and (not MOD.private.Disabled[self:GetName() .. 'Button'])) then
		if(self.backdrop.forceTop or (centerY and (centerY > heightTop))) then
			self.backdrop.underlay:SetGradientAlpha("VERTICAL", 0, 0, 0, 0, 0, 0, 0, 0.8)
			self.backdrop.left:SetGradientAlpha("VERTICAL", 0, 0, 0, 0, 0, 0, 0, 1)
			self.backdrop.right:SetGradientAlpha("VERTICAL", 0, 0, 0, 0, 0, 0, 0, 1)
			--self.backdrop.bottom:SetColorTexture(0, 0, 0, 0)
			self.backdrop.bottom:SetAlpha(0)
			self.backdrop.bottom:SetHeight(1)
			--self.backdrop.top:SetColorTexture(0, 0, 0, 1)
			self.backdrop.top:SetAlpha(1)
			self.backdrop.top:SetHeight(2)
		else
			self.backdrop.underlay:SetGradientAlpha("VERTICAL", 0, 0, 0, 0.8, 0, 0, 0, 0)
			self.backdrop.left:SetGradientAlpha("VERTICAL", 0, 0, 0, 1, 0, 0, 0, 0)
			self.backdrop.right:SetGradientAlpha("VERTICAL", 0, 0, 0, 1, 0, 0, 0, 0)
			--self.backdrop.bottom:SetColorTexture(0, 0, 0, 1)
			self.backdrop.bottom:SetAlpha(1)
			self.backdrop.bottom:SetHeight(2)
			--self.backdrop.top:SetColorTexture(0, 0, 0, 0)
			self.backdrop.top:SetAlpha(0)
			self.backdrop.top:SetHeight(1)
		end
		self.backdrop:SetAlpha(1);
	else
		self.backdrop:SetAlpha(0);
	end
	self.backdrop:SetFrameLevel(0)
	self:SetAlpha(current or 1);
end

function MOD.SetThemedBackdrop(frame, forceTop)
	local frameLevel = frame:GetFrameLevel()
	local backdrop = CreateFrame("Frame", nil, frame)
	backdrop:SetAllPoints(frame)
	backdrop:SetFrameStrata("BACKGROUND")
	backdrop.forceTop = forceTop

	backdrop:SetFrameLevel(0)

	local underlay = backdrop:CreateTexture(nil, "BACKGROUND")
	underlay:InsetPoints(backdrop)
	underlay:SetColorTexture(1, 1, 1, 1)

	backdrop.underlay = underlay;

	local left = backdrop:CreateTexture(nil, "BORDER")
	left:SetColorTexture(1, 1, 1, 1)
	left:SetPoint("TOPLEFT", -1, 1)
	left:SetPoint("BOTTOMLEFT", -1, -1)
	left:SetWidth(2)

	backdrop.left = left;

	local right = backdrop:CreateTexture(nil, "BORDER")
	right:SetColorTexture(1, 1, 1, 1)
	right:SetPoint("TOPRIGHT", 1, 1)
	right:SetPoint("BOTTOMRIGHT", 1, -1)
	right:SetWidth(2)

	backdrop.right = right;

	local bottom = backdrop:CreateTexture(nil, "BORDER")
	bottom:SetColorTexture(0, 0, 0, 1)
	bottom:SetPoint("BOTTOMLEFT", -1, -1)
	bottom:SetPoint("BOTTOMRIGHT", 1, -1)
	bottom:SetHeight(2)

	backdrop.bottom = bottom;

	local top = backdrop:CreateTexture(nil, "BORDER")
	top:SetColorTexture(0, 0, 0, 1)
	top:SetPoint("TOPLEFT", -1, 1)
	top:SetPoint("TOPRIGHT", 1, 1)
	top:SetHeight(2)

	backdrop.top = top;

	frame.backdrop = backdrop

	UpdateBackdrop(frame);
	frame.UpdateBackdrop = UpdateBackdrop;
end

function SV:AdjustTopDockBar(size)
	MOD.Top:ClearAllPoints()
	if (not size) then
		MOD.Top:SetPoint("TOPLEFT", 0, 0);
		MOD.Top:SetPoint("TOPRIGHT", 0, 0);
		MOD.Top:SetAlpha(1)
	else
		MOD.Top:SetPoint("TOPLEFT", 0, -size);
		MOD.Top:SetPoint("TOPRIGHT", 0, -size);
		MOD.Top:SetAlpha(0)
	end
end

function MOD:SetBorderTheme()
	self.Top:ClearAllPoints()
	self.Top:SetPoint("TOPLEFT", SV.Screen, "TOPLEFT", -1, 1)
	self.Top:SetPoint("TOPRIGHT", SV.Screen, "TOPRIGHT", 1, 1)
	self.Top:SetHeight(10)
	self.Top:SetBackdrop({
		bgFile = SV.media.background.button,
		edgeFile = [[Interface\BUTTONS\WHITE8X8]],
		tile = false,
		tileSize = 0,
		edgeSize = 1,
		insets = {left = 0, right = 0, top = 0, bottom = 0}
	})
	self.Top:SetBackdropColor(unpack(SV.media.color.dark))
	self.Top:SetBackdropBorderColor(0,0,0,1)
	self.Top:SetFrameLevel(0)
	self.Top:SetFrameStrata('BACKGROUND')
	self.Top:SetScript("OnShow", function(self)
		self:SetFrameLevel(0)
		self:SetFrameStrata('BACKGROUND')
	end)
	self.Bottom:ClearAllPoints()
	self.Bottom:SetPoint("BOTTOMLEFT", SV.Screen, "BOTTOMLEFT", -1, -1)
	self.Bottom:SetPoint("BOTTOMRIGHT", SV.Screen, "BOTTOMRIGHT", 1, -1)
	self.Bottom:SetHeight(10)
	self.Bottom:SetBackdrop({
		bgFile = SV.media.background.button,
		edgeFile = [[Interface\BUTTONS\WHITE8X8]],
		tile = false,
		tileSize = 0,
		edgeSize = 1,
		insets = {left = 0, right = 0, top = 0, bottom = 0}
	})
	self.Bottom:SetBackdropColor(unpack(SV.media.color.dark))
	self.Bottom:SetBackdropBorderColor(0,0,0,1)
	self.Bottom:SetFrameLevel(0)
	self.Bottom:SetFrameStrata('BACKGROUND')
	self.Bottom:SetScript("OnShow", function(self)
		self:SetFrameLevel(0)
		self:SetFrameStrata('BACKGROUND')
	end)
end

function MOD:SetButtonTheme(button, size)
	local sparkSize = size * 5;
    local sparkOffset = size * 0.5;

    button:SetStyle("DockButton")

	local sparks = button:CreateTexture(nil, "OVERLAY", nil, 2)
	sparks:SetSize(sparkSize, sparkSize)
	sparks:SetPoint("CENTER", button, "BOTTOMRIGHT", -sparkOffset, 4)
	sparks:SetTexture(SV.media.dock.sparks[1])
	sparks:SetVertexColor(0.7, 0.6, 0.5)
	sparks:SetBlendMode("ADD")
	sparks:SetAlpha(0)

	SV.Animate:Sprite8(sparks, 0.08, 2, false, true)

	button.Sparks = sparks;

	button.ClickTheme = function(self)
		self.Sparks:SetTexture(SV.media.dock.sparks[random(1,3)])
		self.Sparks.anim:Play()
	end
end
--[[
##########################################################
CORE FUNCTIONS
##########################################################
]]--
_G.ToggleSuperDockLeft = function(self, button)
	GameTooltip:Hide()
	local activeDock = MOD.private.Active.BottomLeft
	if(button and IsAltKeyDown()) then
		SV:StaticPopup_Show('RESETDOCKS_CHECK')
	elseif(button and button == 'RightButton') then
		if(InCombatLockdown()) then
			MOD.ErrorSound()
			SV:AddonMessage(ERR_NOT_IN_COMBAT)
			return
		end
		MOD.ButtonSound()
		local userSize = SV.db.Dock.dockLeftHeight
		if(not MOD.private.LeftExpanded) then
			MOD.private.LeftExpanded = true
			MOD.BottomLeft.Window:SetHeight(userSize + 300)
		else
			MOD.private.LeftExpanded = nil
			MOD.BottomLeft.Window:SetHeight(userSize)
		end
		MOD.BottomLeft.Bar:Update()
		MOD:UpdateDockBackdrops()
		SV.Events:Trigger("DOCK_EXPANDED", "BottomLeft", activeDock);
	else
		if MOD.private.LeftFaded then
			MOD.private.LeftFaded = nil;
			MOD.BottomLeft:FadeIn(0.2, MOD.BottomLeft:GetAlpha(), 1)
			MOD.BottomLeft.Bar:FadeIn(0.2, MOD.BottomLeft.Bar:GetAlpha(), 1)
			SV.Events:Trigger("DOCK_FADE_IN", "BottomLeft", activeDock);
			PlaySoundFile(565875)
		else
			MOD.private.LeftFaded = true;
			MOD.BottomLeft:FadeOut(0.2, MOD.BottomLeft:GetAlpha(), 0)
			MOD.BottomLeft.Bar:FadeOut(0.2, MOD.BottomLeft.Bar:GetAlpha(), 0)
			SV.Events:Trigger("DOCK_FADE_OUT", "BottomLeft", activeDock);
			PlaySoundFile(565875)
		end
	end
end

_G.ToggleSuperDockRight = function(self, button)
	GameTooltip:Hide()
	local activeDock = MOD.private.Active.BottomRight
	if(button and IsAltKeyDown()) then
		SV:StaticPopup_Show('RESETDOCKS_CHECK')
	elseif(button and button == 'RightButton') then
		if(InCombatLockdown()) then
			MOD.ErrorSound()
			SV:AddonMessage(ERR_NOT_IN_COMBAT)
			return
		end
		MOD.ButtonSound()
		local userSize = SV.db.Dock.dockRightHeight
		if(not MOD.private.RightExpanded) then
			MOD.private.RightExpanded = true
			MOD.BottomRight.Window:SetHeight(userSize + 300)
		else
			MOD.private.RightExpanded = nil
			MOD.BottomRight.Window:SetHeight(userSize)
		end
		MOD.BottomRight.Bar:Update()
		MOD:UpdateDockBackdrops()
		SV.Events:Trigger("DOCK_EXPANDED", "BottomRight", activeDock);
	else
		if MOD.private.RightFaded then
			MOD.private.RightFaded = nil;
			MOD.BottomRight:FadeIn(0.2, MOD.BottomRight:GetAlpha(), 1)
			MOD.BottomRight.Bar:FadeIn(0.2, MOD.BottomRight.Bar:GetAlpha(), 1)
			SV.Events:Trigger("DOCK_FADE_IN", "BottomRight", activeDock);
			PlaySoundFile(565875)
		else
			MOD.private.RightFaded = true;
			MOD.BottomRight:FadeOut(0.2, MOD.BottomRight:GetAlpha(), 0)
			MOD.BottomRight.Bar:FadeOut(0.2, MOD.BottomRight.Bar:GetAlpha(), 0)
			SV.Events:Trigger("DOCK_FADE_OUT", "BottomRight", activeDock);
			PlaySoundFile(565875)
		end
	end
end

_G.ToggleSuperDocks = function()
	if(MOD.private.AllFaded) then
		MOD.private.AllFaded = nil;
		MOD.private.LeftFaded = nil;
		MOD.private.RightFaded = nil;
		MOD.BottomLeft:FadeIn(0.2, MOD.BottomLeft:GetAlpha(), 1)
		MOD.BottomLeft.Bar:FadeIn(0.2, MOD.BottomLeft.Bar:GetAlpha(), 1)
		SV.Events:Trigger("DOCK_FADE_IN", "BottomLeft", MOD.private.Active.BottomLeft);
		MOD.BottomRight:FadeIn(0.2, MOD.BottomRight:GetAlpha(), 1)
		MOD.BottomRight.Bar:FadeIn(0.2, MOD.BottomRight.Bar:GetAlpha(), 1)
		SV.Events:Trigger("DOCK_FADE_IN", "BottomRight", MOD.private.Active.BottomRight);
		PlaySoundFile(565875)
	else
		MOD.private.AllFaded = true;
		MOD.private.LeftFaded = true;
		MOD.private.RightFaded = true;
		MOD.BottomLeft:FadeOut(0.2, MOD.BottomLeft:GetAlpha(), 0)
		MOD.BottomLeft.Bar:FadeOut(0.2, MOD.BottomLeft.Bar:GetAlpha(), 0)
		SV.Events:Trigger("DOCK_FADE_OUT", "BottomLeft");
		MOD.BottomRight:FadeOut(0.2, MOD.BottomRight:GetAlpha(), 0)
		MOD.BottomRight.Bar:FadeOut(0.2, MOD.BottomRight.Bar:GetAlpha(), 0)
		SV.Events:Trigger("DOCK_FADE_OUT", "BottomRight");
		PlaySoundFile(565875)
	end
end

function MOD:EnterFade()
	if MOD.private.LeftFaded then
		self.BottomLeft:FadeIn(0.2, self.BottomLeft:GetAlpha(), 1)
		self.BottomLeft.Bar:FadeIn(0.2, self.BottomLeft.Bar:GetAlpha(), 1)
		SV.Events:Trigger("DOCK_FADE_IN", "BottomLeft", MOD.private.Active.BottomLeft);
	end
	if MOD.private.RightFaded then
		self.BottomRight:FadeIn(0.2, self.BottomRight:GetAlpha(), 1)
		self.BottomRight.Bar:FadeIn(0.2, self.BottomRight.Bar:GetAlpha(), 1)
		SV.Events:Trigger("DOCK_FADE_IN", "BottomRight", MOD.private.Active.BottomRight);
	end
end

function MOD:ExitFade()
	if MOD.private.LeftFaded then
		self.BottomLeft:FadeOut(2, self.BottomLeft:GetAlpha(), 0)
		self.BottomLeft.Bar:FadeOut(2, self.BottomLeft.Bar:GetAlpha(), 0)
		SV.Events:Trigger("DOCK_FADE_OUT", "BottomLeft");
	end
	if MOD.private.RightFaded then
		self.BottomRight:FadeOut(2, self.BottomRight:GetAlpha(), 0)
		self.BottomRight.Bar:FadeOut(2, self.BottomRight.Bar:GetAlpha(), 0)
		SV.Events:Trigger("DOCK_FADE_OUT", "BottomRight");
	end
end
--[[
##########################################################
DRAGGING HIGHLIGHT FUNCTIONS
##########################################################
]]--
do
	local function UpdateDividers(self)
		local anchorParent = self.ToolBar;
		local offsetMod = self.Data.Modifier;
		local orderList = self.Data.Order;
		local buttonList = self.Data.Buttons;
		local dividerList = self.Data.Dividers;
		local location = self.Data.Location;
		local anchor = upper(location);
		local count = #orderList;
		local offset = 2;

		if(count > 0) then
			for i = 1, count do
				local nextButton = buttonList[orderList[i]];
				local divider = dividerList[i];
				if(nextButton and (not nextButton:IsDragging())) then
					local buttonWidth = nextButton:GetWidth();
					local dividerWidth = divider:GetWidth();
					if(not nextButton:IsDragging()) then
						divider:ClearAllPoints();
						divider:SetPoint(anchor, anchorParent, anchor, (offset * offsetMod), 0);
						offset = offset + (dividerWidth + 2);

						nextButton:ClearAllPoints();
						nextButton:SetPoint(anchor, anchorParent, anchor, (offset * offsetMod), 0);
						offset = offset + (buttonWidth + 2);
					end
				end
			end
		end
	end

	local HighLight_OnUpdate = function(self)
		local highlight = self.Highlight;

		if(not highlight) then
			self:SetScript("OnUpdate", nil)
			return
		end

		if(highlight:IsMouseOver(50, -50, -50, 50)) then
			highlight:SetAlpha(1)
			local orderList = self.Data.Order;
			local dividerList = self.Data.Dividers;
			local hovering = false;
			for i = 1, #orderList do
				local divider = dividerList[i]
				if(divider) then
					if(divider:IsMouseOver(25, 0, -25, 0) and (not hovering)) then
						hovering = true;
						highlight:SetAlpha(0.5)
						divider:SetAlpha(1)
						divider:SetWidth(DRAG_BUTTONWIDTH)
					else
						divider:SetAlpha(0)
						divider:SetWidth(1)
					end
				end
			end
		else
			highlight:SetAlpha(0.2)
		end

		UpdateDividers(self)
	end

	ToggleDraggingMode = function(enabled)
		DRAG_TARGETBAR = nil;
		DRAG_ORDERINDEX = nil;
		if(enabled) then
			for location, settings in pairs(DOCK_LOCATIONS) do
				local dock = MOD[location];
				if(dock and dock.Bar) then
					local dockbar = dock.Bar;
					local orderList = dockbar.Data.Order;
					local dividerList = dockbar.Data.Dividers;
					dockbar.Highlight:Show()
					dockbar.Highlight:SetAlpha(0.2)
					dockbar:SetScript("OnUpdate", HighLight_OnUpdate)
					for i = 1, #orderList do
						if(dividerList[i]) then
							dividerList[i]:SetAlpha(0)
							dividerList[i]:SetWidth(1)
							dividerList[i]:SetBackdropColor(0, 0.5, 1, 1)
							dividerList[i]:SetBackdropBorderColor(0, 1, 1, 1)
						end
					end
				end
			end
		else
			local hovering = false;
			for location, settings in pairs(DOCK_LOCATIONS) do
				local dock = MOD[location];
				local dockbar = dock.Bar;
				local dock = MOD[location];
				if(dock and dock.Bar) then
					local dockbar = dock.Bar;
					local orderList = dockbar.Data.Order;
					local dividerList = dockbar.Data.Dividers;
					if(dockbar.Highlight:IsMouseOver(50, -50, -50, 50)) then
						DRAG_TARGETBAR = dockbar;
					end
					dockbar.Highlight:Hide()
					dockbar.Highlight:SetAlpha(0)
					dockbar:SetScript("OnUpdate", nil)
					for i = 1, #orderList do
						local divider = dividerList[i];
						if(divider) then
							if(divider:IsMouseOver(25, 0, -25, 0) and (divider:GetAlpha() > 0) and (not hovering)) then
								DRAG_ORDERINDEX = i;
								hovering = true;
							end
							divider:SetAlpha(0)
							divider:SetWidth(1)
							divider:SetBackdropColor(0, 0.5, 1, 1)
							divider:SetBackdropBorderColor(0, 1, 1, 1)
						end
					end
				end
			end
		end
	end
end
--[[
##########################################################
DOCKBAR FUNCTIONS
##########################################################
]]--
local function DeactivateDockletButton(button)
	button.ActiveDocklet = false;
	button:SetPanelColor("default")
	if(button.Icon) then
		button.Icon:SetGradient(unpack(SV.media.gradient.icon));
	end
end

local function DeactivateAllDockletButtons(dockbar)
	local location = dockbar.Data.Location;
	local buttonList = dockbar.Data.Buttons;
	for nextName,nextButton in pairs(buttonList) do
		DeactivateDockletButton(nextButton)
	end
end

local function ActivateDockletButton(button)
	DeactivateAllDockletButtons(button.Parent);
	button.ActiveDocklet = true;
	button:SetPanelColor("default");
	if(button.Icon) then
		button.Icon:SetGradient(unpack(SV.media.gradient.checked));
	end
end

local function ShowDockletWindow(button, location)
	if((not button) or (not button.FrameLink)) then return end
	--print(button:GetName())
	local window = button.FrameLink
	window:FadeIn(0.1, 0, 1)
	if(not InCombatLockdown()) then	window:SetFrameLevel(5) end
	if(window.PostShowCallback) then
		window:PostShowCallback()
	else
		SV.Events:Trigger("DOCKLET_SHOWN", location, button.LinkKey);
	end
	return true;
end

local function HideDockletWindow(button, location)
	if((not button) or (not button.FrameLink)) then return end
	local window = button.FrameLink
	window:FadeOut(0.1, 1, 0, true)
	if(not InCombatLockdown()) then	window:SetFrameLevel(0) end
	if(window.PostHideCallback) then
		window:PostHideCallback()
	else
		SV.Events:Trigger("DOCKLET_HIDDEN", location, button.LinkKey);
	end
	return true;
end

local function ResetAllDockletWindows(dockbar, button)
	local location = dockbar.Data.Location;
	local buttonList = dockbar.Data.Buttons;
	local currentButton = "";
	if(button and button.GetName) then
		currentButton = button:GetName()
	end
	--print('ResetAllDockletWindows: ' .. currentButton)
	for nextName,nextButton in pairs(buttonList) do
		if(nextName ~= currentButton) then
			if(nextButton.FrameLink) then
				HideDockletWindow(nextButton, location)
			end
		end
	end
	SV.Events:Trigger("DOCKLET_RESET", location);
end

local DockBar_ResetAll = function(self)
	ResetAllDockletWindows(self);
	DeactivateAllDockletButtons(self);
end

local DockBar_SetDefault = function(self, button)
	local location = self.Data.Location;
	self.Parent.Alert:Deactivate()
	if(button) then
		local name = button:GetName()
		local lookup = MOD.private.Locations[name];
		if(button.isFloating or (lookup and (lookup == "Floating"))) then
			button.OrderIndex = 0;
			SaveCurrentPosition(button);
			if(ShowDockletWindow(button, lookup)) then
				ActivateDockletButton(button);
			end
			return true;
		elseif(button.FrameLink) then
			MOD.private.Active[location] = name;
		end
	end

	if((not button) or (not button.FrameLink)) then
		local defaultButton = MOD.private.Active[location];
		button = _G[defaultButton];
	end

	if(button and button.FrameLink) then
		ResetAllDockletWindows(self, button);
		self.Parent.Window.FrameLink = button.FrameLink;
		if(not InCombatLockdown()) then
			self.Parent.Window:Show();
		end
		self.Parent.Window:FadeIn();
		if(ShowDockletWindow(button, location)) then
			ActivateDockletButton(button);
			return true;
		end
	end

	return false
end

local DockBar_NextDefault = function(self)
	local location = self.Data.Location;
	local buttonList = self.Data.Buttons;
	for name,button in pairs(buttonList) do
		if(button.FrameLink) then
			MOD.private.Active[location] = name;
			ResetAllDockletWindows(self, button);
			self.Parent.Window.FrameLink = button.FrameLink;
			if(not InCombatLockdown()) then
				self.Parent.Window:Show();
			end
			self.Parent.Window:FadeIn();
			if(ShowDockletWindow(button, location)) then
				ActivateDockletButton(button);
				return;
			end
		end
	end
	SV.Events:Trigger("DOCKLET_LIST_EMPTY", location);
end

local DockBar_UpdateOrder = function(self)
	local ORDER_TEMP = {};
	local location = self.Data.Location;
	local buttonList = self.Data.Buttons;
	local orderList = self.Data.Order;
	local internalCount = #orderList;

	for i=1, internalCount do
		orderList[i] = nil;
	end

	local saved = MOD.private.Order[location];
	local savedCount = #saved;
	local safeIndex = 1;
	for i=1, savedCount do
		local nextName = saved[i];
		local nextButton = buttonList[nextName];
		if(nextButton) then
			if(not ORDER_TEMP[nextName]) then
				ORDER_TEMP[nextName] = true;
				nextButton.OrderIndex = safeIndex;
				orderList[safeIndex] = nextName;
				safeIndex = safeIndex + 1;
			end
		end
	end
end

local DockBar_ChangeOrder = function(self, button, targetIndex)
	local ORDER_TEMP = {};
	local location = self.Data.Location;
	local targetName = button:GetName();
	local currentIndex = button.OrderIndex;
	local saved = MOD.private.Order[location];
	local maxCount = #saved;
	local count = 1;
	for i=1, maxCount do
		local nextName = saved[i];
		if(i == targetIndex) then
			if(currentIndex > targetIndex) then
				ORDER_TEMP[count] = targetName;
				count=count+1;
				ORDER_TEMP[count] = nextName;
				count=count+1;
			else
				ORDER_TEMP[count] = nextName;
				count=count+1;
				ORDER_TEMP[count] = targetName;
				count=count+1;
			end
		elseif(targetName ~= nextName) then
			ORDER_TEMP[count] = nextName;
			count=count+1;
		end
	end

	for i=1, maxCount do
		MOD.private.Order[location][i] = ORDER_TEMP[i];
	end

	DockBar_UpdateOrder(self);
end

local DockBar_CheckOrder = function(self, targetName)
	local masterOrder = MOD.private.Order;
	local masterLocation = MOD.private.Locations;
	for otherLoc,otherData in pairs(masterOrder) do
		for x = 1, #otherData do
			local otherName = otherData[x];
			local registeredLocation = masterLocation[otherName];
			if(registeredLocation ~= otherLoc) then
				masterOrder[otherLoc][x] = nil;
			end
		end
	end

	local found = false;
	local location = self.Data.Location;
	local saved = masterOrder[location];
	if(not saved) then return end
	local maxCount = #saved;
	for i = 1, maxCount do
		if(saved[i] == targetName) then
			found = true;
		end
	end
	if(not found) then
		saved[maxCount+1] = targetName;
	end

	DockBar_UpdateOrder(self);
end

local function CreateDivider(parent)
	local size = parent.ToolBar:GetHeight();
	local frame = CreateFrame("Frame", nil, parent);
	frame:SetSize(1,size);
	frame:SetStyle("!_Frame", "Transparent")
	frame:SetBackdropColor(0, 0.5, 1)
	frame:SetBackdropBorderColor(0, 1, 1)
	frame:SetAlpha(0)
	return frame;
end

local DockBar_UpdateLayout = function(self)
	local anchorParent = self.ToolBar;
	local offsetMod = self.Data.Modifier;
	local orderList = self.Data.Order;
	local buttonList = self.Data.Buttons;
	local dividerList = self.Data.Dividers;
	local location = self.Data.Location;

	local anchor = upper(location);
	local size = anchorParent:GetHeight();
	local count = #orderList;
	local offset = 2;

	for i = 1, #dividerList do
		local divider = dividerList[i];
		divider:Hide()
	end

	local safeIndex = 1;
	for i = 1, #orderList do
		local nextName = orderList[i];
		local nextButton = buttonList[nextName];

		if(nextButton and (not nextButton.isFloating)) then
			nextButton.OrderIndex = safeIndex;

			local calcWidth = size * (nextButton.widthMultiplier or 1);

			local divider = dividerList[safeIndex];
			if(not divider) then
				divider = CreateDivider(self);
				dividerList[safeIndex] = divider;
			end

			divider:Show();
			divider:SetAlpha(0);
			divider:ClearAllPoints();
			divider:SetSize(1, size);
			divider:SetPoint(anchor, anchorParent, anchor, (offset * offsetMod), 0);
			offset = offset + 3;

			if(not InCombatLockdown() or (not nextButton:IsProtected())) then
				nextButton:Show();
				nextButton:ClearAllPoints();
				nextButton:SetSize(calcWidth, size);
				nextButton:SetPoint(anchor, anchorParent, anchor, (offset * offsetMod), 0);
			end
			offset = offset + (calcWidth + 2);

			safeIndex = safeIndex + 1;
		end
	end

	local defaultButton = MOD.private.Active[location];
	if(not buttonList[defaultButton]) then
		MOD.private.Active[location] = nil
	end

	anchorParent:SetWidth(offset + size);
end

local DockBar_AddButton = function(self, button, order)
	if not button then return end
	local name = button:GetName();
	local currentLocation = self.Data.Location
	order = order or 0;
	--if(self.Data.Buttons[name] and (order == 0)) then return end
	local registeredLocation = MOD.private.Locations[name];

	if(registeredLocation) then
		if(registeredLocation == 'Floating') then
			return
		elseif(registeredLocation ~= currentLocation) then
			if(MOD[registeredLocation].Bar.Data.Buttons[name]) then
				MOD[registeredLocation].Bar:Remove(button, true);
			else
				--MOD[registeredLocation].Bar:Add(button);
				return
			end
		end
	end
	if(MOD.private.Disabled[name]) then return end

	MOD.private.Dimensions[name] = nil;

	button:Show()
	self.Data.Buttons[name] = button;

	DockBar_CheckOrder(self, name);
	if(order > 0) then
		DockBar_ChangeOrder(self, button, order)
	end

	MOD.private.Locations[name] = currentLocation;
	button.Parent = self;
	button:SetParent(self.ToolBar);

	if(button.FrameLink) then
		local frame = button.FrameLink
		local frameName = frame:GetName()
		self.Data.Windows[frameName] = frame;
		MOD.private.Windows[frameName] = currentLocation;
		frame:Show()
		frame:ClearAllPoints()
		frame:SetParent(self.Parent.Window)
		frame:InsetPoints(self.Parent.Window)
		frame.Parent = self.Parent
		if(frame.UpdateBackdrop) then
			frame:UpdateBackdrop();
		end
		frame:FadeIn()
		if(not MOD.private.Active[currentLocation]) then
			DockBar_SetDefault(self, button)
		end
	end

	self:SetDefault()
	self:Update()
end

local DockBar_RemoveButton = function(self, button, isMoving)
	if not button then return end
	local name = button:GetName();
	local registeredLocation = MOD.private.Locations[name];
	local currentLocation = self.Data.Location

	if(registeredLocation and (registeredLocation == currentLocation)) then
		MOD.private.Locations[name] = nil;
	end

	for i = 1, #self.Data.Order do
		local nextName = self.Data.Order[i];
		if(nextName == name) then
			--print('Removing #' .. i .. ' = ' .. nextName)
			tremove(self.Data.Order, i);
			break;
		end
	end

	if(self.Data.Buttons[name]) then
		button.OrderIndex = 0;
		button:Hide()
		MOD.private.Disabled[name] = currentLocation;
		if(button.FrameLink) then
			button.FrameLink:SetParent(UIParent)
			local frameName = button.FrameLink:GetName()
			MOD.private.Windows[frameName] = nil;
			if(button.FrameLink.UpdateBackdrop) then
				button.FrameLink:UpdateBackdrop();
			end
			button.FrameLink:FadeOut(0.2, 1, 0, true);
			self.Data.Windows[frameName] = nil;
		end

		if(#self.Data.Order == 0) then
			MOD.private.Active[currentLocation] = nil;
		end

		self.Data.Buttons[name] = nil;
		DockBar_UpdateOrder(self);
		if(MOD.private.Active[currentLocation] == name or (not MOD.private.Active[currentLocation]) or (MOD.private.Active[currentLocation] == "")) then
			self:NextDefault()
		else
			self:SetDefault()
		end
	end
	self:Update()
end
--[[
##########################################################
DOCKBUTTON FUNCTIONS
##########################################################
]]--
local function UpdateAllLayouts()
	for location, settings in pairs(DOCK_LOCATIONS) do
		local dock = MOD[location];
		local dockbar = dock.Bar;
		if(dockbar) then
			dockbar:Update()
		end
	end
end

local function SetFloatingDock(dock)
	local name = dock:GetName();
	dock:SetDocked(false);
	MOD.private.Disabled[name] = nil;
	dock:Show();
	dock.isFloating = true;
	SaveCurrentPosition(dock);

	if(dock.FrameLink) then
		dock.FrameLink:ClearAllPoints();
		dock.FrameLink:SetPoint("BOTTOMLEFT", dock, "TOPLEFT", -3, 6);
		dock.FrameLink:SetResizable(true);
		dock.FrameLink:Show();
		dock.FrameLink.resize:Show();
	end
	LoadSavedDimensions(dock);
	if(ShowDockletWindow(dock, "Floating")) then
		ActivateDockletButton(dock);
	end
	if(MOD.private.Locations[name] == 'Floating') then return end
	MOD.private.Locations[name] = "Floating";
	UpdateAllLayouts()
end

local DockButton_OnDragStart = function(self)
	if(IsShiftKeyDown() and (not InCombatLockdown())) then
		GameTooltip:Hide();

		self:SetMovable(true);
		self:StartMoving();
		local name = self:GetName();
		MOD.private.Disabled[name] = nil;
		DRAG_TARGETBAR = nil;
		DRAG_LASTINDEX = self.OrderIndex;
		DRAG_BUTTONWIDTH = self:GetWidth()
		ToggleDraggingMode(true);
		DRAG_ENABLED = true;
	end
end

local DockButton_OnDragStop = function(self)
	if(DRAG_ENABLED) then
		self:StopMovingOrSizing();
		ToggleDraggingMode(false);
		local name = self:GetName();
		local previous = MOD.private.Locations[name];
		self.OrderIndex = 0;
		if(not DRAG_TARGETBAR) then
			SetFloatingDock(self)
		else
			local target = DRAG_TARGETBAR;
			if(not target) then
				target = MOD[previous];
			end
			self:SetMovable(false);
			self.isFloating = nil;
			MOD.private.Locations[name] = nil;
			if(self.FrameLink) then
				self.FrameLink:SetResizable(false);
				self.FrameLink.resize:Hide();
			end

			target:Add(self, DRAG_ORDERINDEX);

			if(self.FrameLink and self.FrameLink.UpdateBackdrop) then
				self.FrameLink:UpdateBackdrop()
			end

			SV.Events:Trigger("DOCKLET_MOVED", self.LocationKey);
		end

		DRAG_ENABLED = false;
	end
end

local DockButton_DefaultTip = function(self, ...)
	local tipText = self:GetAttribute("tipText")
	if(tipText) then
		GameTooltip:AddDoubleLine("[Left-Click]", tipText, 0, 1, 0, 1, 1, 1)
	end
end

local DockButton_OnEnter = function(self, ...)
	if(self:IsDragging()) then return end
	MOD:EnterFade()
	self:SetPanelColor("highlight")
	self.Icon:SetGradient(unpack(SV.media.gradient.highlight))
	local tipAnchor = self:GetAttribute("tipAnchor")
	GameTooltip:SetOwner(self, tipAnchor, 0, 4)
	GameTooltip:ClearLines()
	if(self.GeneralTip) then
		self:GeneralTip()
		GameTooltip:AddLine(" ", 1, 1, 1)
	end
	if(self.ShowDockOptions) then
		GameTooltip:AddDoubleLine("Right-Click", "Options", 0, 1, 0, 0.5, 1, 0.5)
	end
	GameTooltip:AddDoubleLine("|cff0099FFSHIFT|r + Drag", "Relocate", 0, 1, 0, 0.5, 1, 0.5)
	GameTooltip:AddDoubleLine("|cff0099FFALT|r + Right-Click", "Hide", 0, 1, 0, 0.5, 1, 0.5)
	GameTooltip:Show()
end

local DockButton_OnLeave = function(self, ...)
	MOD:ExitFade()
	self:SetPanelColor("default")
	if(self.ActiveDocklet) then
		self.Icon:SetGradient(unpack(SV.media.gradient.checked))
	else
		self.Icon:SetGradient(unpack(SV.media.gradient.icon))
	end
	GameTooltip:Hide()
end

local DockButton_OnClick = function(self, button)
	if(self.ClickTheme) then
		self:ClickTheme()
	end
	MOD.ButtonSound()
	if(button and (button == "RightButton")) then
		if(IsAltKeyDown()) then
			self.ActiveDocklet = false;
			self:SetPanelColor("default")
			if(self.Icon) then
				self.Icon:SetGradient(unpack(SV.media.gradient.icon));
			end
			if(self.FrameLink) then
				local registeredLocation = MOD.private.Locations[self.LocationKey];
				HideDockletWindow(self, registeredLocation)
			end
		elseif(self.RightClickCallback) then
			self:RightClickCallback();
		elseif((not InCombatLockdown()) and self.ShowDockOptions) then
			self:ShowDockOptions();
		end
	else
		local clickAllowed = false;
		if(self.FrameLink) then
			clickAllowed = DockBar_SetDefault(self.Parent, self)
		else
			clickAllowed = true;
		end
		if(self.LeftClickCallback and clickAllowed) then
			self:LeftClickCallback(button)
		end
	end
end

local DockButton_OnPostClick = function(self, button)
	if InCombatLockdown() then
		MOD.ErrorSound()
		return
	end
	if(self.ClickTheme) then self:ClickTheme() end
	if(button and (button == "RightButton")) then
		if(self.RightClickCallback) then
			self:RightClickCallback()
		end
	elseif(self.LeftClickCallback) then
		self:LeftClickCallback()
	end
	MOD.ButtonSound()
end

local DockButton_SetEnabled = function(self, isEnabled)
	local name = self:GetName()
	if(isEnabled) then
		MOD.private.Disabled[name] = nil
	elseif(self.Parent) then
		MOD.private.Disabled[name] = self.Parent.Data.Location
	else
		MOD.private.Disabled[name] = "Floating"
	end
end

local DockButton_IsEnabled = function(self)
	return (not MOD.private.Disabled[self:GetName()]);
end

local DockButton_SetDocked = function(self, attach)
	local name = self:GetName()
	local lastKnownLocation = MOD.private.Disabled[name];
	if((not self.Parent) and (not lastKnownLocation)) then return end
	local lookup = MOD.private.Locations[name] or MOD.private.Windows[name];
	local parent = self.Parent;
	if(attach) then
		if(lastKnownLocation and MOD[lastKnownLocation]) then
			parent = MOD[lastKnownLocation].Bar;
		end
		MOD.private.Disabled[name] = nil;
		if(not parent.Add) then return end
		parent:Add(self)
		if(lookup and (lookup == "Floating")) then
			SetFloatingDock(self);
		end
	elseif(parent and parent.Remove) then
		parent:Remove(self)
	end
end

local DockButton_SetClickCallbacks = function(self, onleftclick, onrightclick, extendedoptions)
	if(onleftclick and (type(onleftclick) == 'function')) then
		self.LeftClickCallback = onleftclick;
	end
	if((onrightclick and (type(onrightclick) == 'function'))) then
		self.RightClickCallback = onrightclick;
	end
	if((extendedoptions and (type(extendedoptions) == 'function'))) then
		self.ExtendedOptions = extendedoptions;
	end
end
--[[
##########################################################
DROPDOWN OPTION BUILDERS
##########################################################
]]--
local OptionMenu_ButtonFunc = function(self)
 --DO STUFF
end

local OptionMenu_SliderFunc = function(self, value)
	local frame = self.FrameLink;
	if(frame) then
		local name = frame:GetName();
		MOD.private.Opacity[name] = value;
		if(frame.UpdateBackdrop) then
			frame:UpdateBackdrop()
		end
	end
end

local DockButton_ShowDockOptions = function(self)
	local button = self;
	local frame = button.FrameLink;
	local list;

	if(self.ExtendedOptions) then
		list = self:ExtendedOptions();
	else
		list = {};
	end

	if(frame) then
		local name = frame:GetName();
		local current = MOD.private.Opacity[name] or 1;
		tinsert(list, { title = "Backdrop Alpha", divider = true });
		tinsert(list, { range = {0,1}, value = current, func = OptionMenu_SliderFunc });
	end

	local menuTitle = self:GetAttribute("tipText") or "Dock";
	SV.Dropdown:Open(self, list, menuTitle);
end
--[[
##########################################################
REMAINING DOCKBAR FUNCTIONS
##########################################################
]]--
local DockBar_CreateButton = function(self, displayName, globalName, texture, tipFunction, primaryTemplate, frameLink)
	local dockIcon = texture or [[Interface\AddOns\SVUI_!Core\assets\textures\Dock\DOCK-ICON-ADDON]];
	local size = self.ToolBar:GetHeight();
	local template = "SVUI_DockletButtonTemplate"
	local isAction = false;

	if(primaryTemplate) then
		template = primaryTemplate .. ", SVUI_DockletButtonTemplate";
		isAction = true;
	end

	local button = _G[globalName .. "DockletButton"] or CreateFrame("Button", globalName, self.ToolBar, template)

	button:ClearAllPoints()
	button:SetSize(size, size)
	MOD:SetButtonTheme(button, size)
	button:SetPanelColor("default")
	button.Icon:SetTexture(dockIcon)
	button.Icon:SetGradient(unpack(SV.media.gradient.icon))

	button:SetAttribute("tipText", displayName)
	button:SetAttribute("tipAnchor", self.Data.TipAnchor)
	button:SetScript("OnEnter", DockButton_OnEnter)
	button:SetScript("OnLeave", DockButton_OnLeave)
	button:RegisterForDrag("LeftButton");
	button:SetScript("OnDragStart", DockButton_OnDragStart);
	button:SetScript("OnDragStop", DockButton_OnDragStop);
	if(not isAction) then
		button:SetScript("OnClick", DockButton_OnClick)
	else
		button:SetScript("PostClick", DockButton_OnPostClick)
	end

	button.Parent 				= self;
	button.OrderIndex 			= 0;
	button.LocationKey  		= globalName;
	button.SetDocked 			= DockButton_SetDocked;
	button.SetClickCallbacks 	= DockButton_SetClickCallbacks;
	button.SetEnabled 			= DockButton_SetEnabled;
	button.IsEnabled 			= DockButton_IsEnabled;

	if(tipFunction and type(tipFunction) == "function") then
		button.GeneralTip = tipFunction
	else
		button.GeneralTip = DockButton_DefaultTip
	end

	if(frameLink) then
		button.FrameLink 				= frameLink;
		button.LinkKey   				= frameLink:GetName();
		button.ShowDockOptions 	= DockButton_ShowDockOptions;
	end

	self:Add(button)

	return button
end

function MOD:SetDockButton(location, displayName, globalName, texture, tipFunction, primaryTemplate)
	if(not self.private) then return end
	if(self.private.Locations[globalName]) then
		location = self.private.Locations[globalName];
	else
		self.private.Locations[globalName] = location;
	end
	local parent = self[location]
	return DockBar_CreateButton(parent.Bar, displayName, globalName, texture, tipFunction, primaryTemplate)
end
--[[
##########################################################
DOCKS
##########################################################
]]--
MOD.Top = _G["SVUI_DockBarTop"];
--MOD.Top:SetParent(SV.Screen)
MOD.Bottom = _G["SVUI_DockBarBottom"];
MOD.TopCenter = _G["SVUI_DockTopCenter"];
MOD.BottomCenter = _G["SVUI_DockBottomCenter"];

local dockAlertCombatActive = false

local DockAlert_OnEvent = function(self, event)
    if(event == 'PLAYER_REGEN_ENABLED') then
    	if dockAlertCombatActive then
    		DockAlert_Deactivate(self)
    		dockAlertCombatActive = false
    	end
        self:SetHeight(self.activeHeight)
        self:UnregisterEvent(event)
    end
end

local DockAlert_Activate = function(self, child, newHeight)
	local fallbackHeight = SV.db.Dock.buttonSize or 22;
	local size = newHeight or fallbackHeight;
	self:SetHeight(size);
	if(child) then
		child:SetAllSecurePoints(self)
	end
end

local DockAlert_Deactivate = function(self)
	if InCombatLockdown() then 
		-- Make sure we deactivate later
		dockAlertCombatActive = true 
		return 
	end
	self:SetHeight(1)
end

local DockProxy_ResetAll = function(self, ...)
	if(self.Bar and self.Bar.Reset) then
		self.Bar:Reset(...)
	end
end

local DockProxy_UpdateLayout = function(self, ...)
	if(self.Bar and self.Bar.Update) then
		self.Bar:Update(...)
	end
end

local DockProxy_AddButton = function(self, ...)
	if(self.Bar and self.Bar.Add) then
		self.Bar:Add(...)
	end
end

local DockProxy_RemoveButton = function(self, ...)
	if(self.Bar and self.Bar.Remove) then
		self.Bar:Remove(...)
	end
end

local DockProxy_CreateButton = function(self, ...)
	if(self.Bar and self.Bar.Create) then
		self.Bar:Create(...)
	end
end

for location, settings in pairs(DOCK_LOCATIONS) do
	MOD[location] = _G["SVUI_Dock" .. location];
	MOD[location].Bar = _G["SVUI_DockBar" .. location];

	MOD[location].Alert.Activate 	= DockAlert_Activate;
	MOD[location].Alert.Deactivate 	= DockAlert_Deactivate;
	--MOD[location].Alert:SetScript("OnEvent", DockAlert_OnEvent);

	MOD[location].Bar.Parent 		= MOD[location];
	MOD[location].Bar.SetDefault 	= DockBar_SetDefault;
	MOD[location].Bar.NextDefault 	= DockBar_NextDefault;
	MOD[location].Bar.Reset 		= DockBar_ResetAll;
	MOD[location].Bar.Update 		= DockBar_UpdateLayout;
	MOD[location].Bar.Add 			= DockBar_AddButton;
	MOD[location].Bar.Remove 		= DockBar_RemoveButton;
	MOD[location].Bar.Create 		= DockBar_CreateButton;
	MOD[location].Bar.Data = {
		Location = location,
		Anchor = settings[2],
		Modifier = settings[1],
		TipAnchor = settings[4],
		Buttons = {},
		Windows = {},
		Order = {},
		Dividers = {}
	};

	-- PROXY METHODS
	MOD[location].Reset 		= DockProxy_ResetAll;
	MOD[location].Update 		= DockProxy_UpdateLayout;
	MOD[location].Add 			= DockProxy_AddButton;
	MOD[location].Remove 		= DockProxy_RemoveButton;
	MOD[location].Create 		= DockProxy_CreateButton;
	--MOD[location].Bar:SetScript("OnEvent", DockBar_OnEvent)
end
--[[
##########################################################
DOCKLETS (DOCK BUTTONS WITH ASSOCIATED WINDOWS)
##########################################################
]]--
local Docklet_Enable = function(self)
	local dock = self.Parent;
	if(self.Button) then dock.Bar:Add(self.Button) end
end

local Docklet_Disable = function(self)
	local dock = self.Parent;
	if(self.Button) then dock.Bar:Remove(self.Button) end
end

local Docklet_ButtonSize = function(self)
	local size = self.Bar.ToolBar:GetHeight() or 30;
	return size;
end

local Docklet_Relocate = function(self, location)
	local newParent = MOD[location];

	if(not newParent) then return end

	if(self.Button) then
		newParent.Bar:Add(self.Button)
	end

	if(self.Bar) then
		local height = newParent.Bar.ToolBar:GetHeight();
		local mod = newParent.Bar.Data[1];
		local barAnchor = newParent.Bar.Data[2];
		local barReverse = SV:GetReversePoint(barAnchor);
		local spacing = SV.db.Dock.buttonSpacing;

		self.Bar:ClearAllPoints();
		self.Bar:SetPoint(barAnchor, newParent.Bar.ToolBar, barReverse, (spacing * mod), 0)
	end
end

local DockletResize_OnMouseDown = function(self)
	local centerX, centerY = self.parent:GetCenter();
	self.parent:ClearAllPoints()
	self.parent:SetPoint("CENTER", UIParent, "BOTTOMLEFT", centerX, centerY)
	self.parent.Button:ClearAllPoints()
	self.parent.Button:SetPoint("TOPLEFT", self.parent, "BOTTOMLEFT", 3, -6)
	self.parent:StartSizing("BOTTOMRIGHT");
end

local DockletResize_OnMouseUp = function(self)
	local centerX, centerY = self.parent.Button:GetCenter();
	self.parent:StopMovingOrSizing();
	self.parent.Button:ClearAllPoints()
	self.parent.Button:SetPoint("CENTER", UIParent, "BOTTOMLEFT", centerX, centerY)
	self.parent:ClearAllPoints()
	self.parent:SetPoint("BOTTOMLEFT", self.parent.Button, "TOPLEFT", -3, 6)
	SaveCurrentDimensions(self.parent.Button);
	if(self.parent.PostResizeCallback) then
		self.parent.PostResizeCallback(self.parent);
	end
end

local Docklet_SetClickCallbacks = function(self, ...)
	if(not self.Button) then return end
	self.Button:SetClickCallbacks(...)
end

local Docklet_SetDocked = function(self, ...)
	if(not self.Button) then return end
	self.Button:SetDocked(...)
end

local Docklet_SetEnabled = function(self)
	if(not self.Button) then return end
	local result = self.Button:SetEnabled()
	return result;
end

local Docklet_IsEnabled = function(self)
	if(not self.Button) then return end
	local result = self.Button:IsEnabled()
	return result;
end

local Docklet_SetVisibilityCallbacks = function(self, onshow, onhide, onsize)
	if(onshow and (type(onshow) == 'function')) then
		self.PostShowCallback = onshow;
	end
	if(onhide and (type(onhide) == 'function')) then
		self.PostHideCallback = onhide;
	end
	if(onsize and (type(onsize) == 'function')) then
		self.PostResizeCallback = onsize;
	end
end

function MOD:NewDocklet(location, globalName, readableName, texture, onenter)
	if(DOCK_REGISTRY[globalName]) then return end;

	if(self.private.Windows[globalName]) then
		location = self.private.Windows[globalName];
	else
		self.private.Windows[globalName] = location;
	end
	self.private.Locations[globalName] = nil;

	local newParent = self[location];
	if(not newParent) then return end

	local frame = _G[globalName] or CreateFrame("Frame", globalName, UIParent);

	if(not self.private.Opacity[globalName]) then
		self.private.Opacity[globalName] = 1;
	end

	local parentWidth, parentHeight = newParent.Window:GetSize();

	frame:SetParent(newParent.Window);
	frame:SetSize(parentWidth, parentHeight);
	frame:SetPoint("TOPLEFT", newParent.Window, "TOPLEFT", 0, 0);
	frame:SetPoint("BOTTOMRIGHT", newParent.Window, "BOTTOMRIGHT", 0, 0);
	frame:SetFrameStrata("BACKGROUND");

	frame.Parent = newParent;
	frame.Bar = newParent.Bar;
	frame.Disable = Docklet_Disable;
	frame.Enable = Docklet_Enable;
	frame.SetDocked = Docklet_SetDocked;
	frame.Relocate = Docklet_Relocate;
	frame.GetButtonSize = Docklet_ButtonSize;
	frame.SetEnabled = Docklet_SetEnabled;
	frame.IsEnabled = Docklet_IsEnabled;
	frame.SetClickCallbacks = Docklet_SetClickCallbacks;
	frame.SetVisibilityCallbacks = Docklet_SetVisibilityCallbacks;

	self.SetThemedBackdrop(frame)
	frame.resize = CreateFrame("Button", nil, frame);
	frame.resize:SetSize(16,16)
	frame.resize:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
	frame.resize:SetNormalTexture([[Interface\ChatFrame\UI-ChatIM-SizeGrabber-Up]])
	frame.resize:Hide()

	newParent.Bar.Data.Windows[globalName] = frame;

	local buttonName = ("%sButton"):format(globalName)
	frame.Button = newParent.Bar:Create(readableName, buttonName, texture, onenter, false, frame);
	DOCK_REGISTRY[globalName] = frame;
	frame:SetAlpha(0);
	DOCK_CHECK = true;

	frame.resize.parent = frame;
	frame.resize:SetScript("OnMouseDown", DockletResize_OnMouseDown);
	frame.resize:SetScript("OnMouseUp", DockletResize_OnMouseUp);

	LoadSavedDimensions(frame.Button);

	return frame
end
--[[
##########################################################
BUILD/UPDATE
##########################################################
]]--
local CornerButton_OnEnter = function(self, ...)
	MOD:EnterFade()

	self:SetPanelColor("highlight")
	self.Icon:SetGradient(unpack(SV.media.gradient.highlight))

	GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 4)
	GameTooltip:ClearLines()
	local tipText = self:GetAttribute("tipText")
	GameTooltip:AddDoubleLine("Left-Click", tipText, 0, 1, 0, 1, 1, 1)
	local tipExtraText = self:GetAttribute("tipExtraText")
	GameTooltip:AddDoubleLine("Right-Click", tipExtraText, 0, 1, 0, 1, 1, 1)
	GameTooltip:Show()
end

local CornerButton_OnLeave = function(self, ...)
	MOD:ExitFade()
	self:SetPanelColor("default")
	if(self.ActiveDocklet) then
		self.Icon:SetGradient(unpack(SV.media.gradient.checked))
	else
		self.Icon:SetGradient(unpack(SV.media.gradient.icon))
	end
	GameTooltip:Hide()
end

local CornerButton_OnClick = function(self, button)
	if(button and IsAltKeyDown() and button == 'RightButton') then
		SV:StaticPopup_Show('RESETDOCKS_CHECK')
	else
		self:ToggleFunc(button)
	end
end

local CornerButton2_OnEnter = function(self, ...)
	MOD:EnterFade()

	self:SetPanelColor("highlight")
	self.Icon:SetGradient(unpack(SV.media.gradient.highlight))

	GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 4)
	GameTooltip:ClearLines()
	GameTooltip:AddDoubleLine("Left-Click", "Enable Docklets", 0, 1, 0, 1, 1, 1)
	GameTooltip:AddDoubleLine("Right-Click", "Disable Docklets", 0, 1, 0, 1, 1, 1)
	GameTooltip:AddDoubleLine("|cff0099FFAlt|r + Right-Click", "Reset All Docklets", 0, 1, 0, 1, 1, 1)
	GameTooltip:Show()
end

local sort_menu_fn = function(a,b) return a.text < b.text end;

local CornerButton2_OnClick = function(self, button)
	if(IsAltKeyDown() and button and button == 'RightButton') then
		SV:StaticPopup_Show('RESETDOCKS_CHECK')
	else
		if(InCombatLockdown()) then return end
		local menu = {};
		local titleText = "Disabled";
		if(button and button == 'RightButton') then
			titleText = "Enabled";
			for name,parent in pairs(MOD.private.Locations) do
				if((not MOD.private.Disabled[name]) and _G[name]) then
					local b = _G[name];
					local tipText = b:GetAttribute("tipText")
					if(tipText) then
						tinsert(menu, { text = tipText, func = function() b:SetDocked(false); end });
					end
				end
			end
		else
			for name,parent in pairs(MOD.private.Disabled) do
				local b = _G[name];
				if(b) then
					local tipText = b:GetAttribute("tipText")
					if(tipText) then
						tinsert(menu, { text = tipText, func = function() b:SetDocked(true); end });
					end
				end
			end
		end

		tsort(menu, sort_menu_fn)

		SV.Dropdown:Open(self, menu, titleText);
	end
end

function MOD:UpdateDockBackdrops()
	for name,frame in pairs(DOCK_REGISTRY) do
		if(frame.backdrop and frame.UpdateBackdrop) then
			frame:UpdateBackdrop()
		end
	end
end

function MOD:ResetAllButtons()
	wipe(MOD.private.Order)
	wipe(MOD.private.Locations)
	wipe(MOD.private.Windows)
	wipe(MOD.private.Dimensions)
	wipe(MOD.private.Opacity)
	wipe(MOD.private.Disabled)
	SV.Events:Trigger("DOCKLETS_RESET", location);
	ReloadUI()
end

local function LoadAllDocklets()
	for name, location in pairs(MOD.private.Locations) do
		local button = _G[name];
		local disabled = MOD.private.Disabled[name];
		if(button and (location == 'Floating') and (not disabled)) then
			button:Show();

			if(MOD.private.Dimensions) then
				LoadSavedDimensions(button);
			end

			if(ShowDockletWindow(button, location)) then
				ActivateDockletButton(button);
			end
		elseif(button) then
			button:StopMovingOrSizing();
			button:SetMovable(false)
			if(disabled) then
				button:Hide();
				local frame = button.FrameLink;
				if(frame) then
					frame:FadeOut(0.2, 1, 0, true);
				end
			end
		end
	end

	for location, settings in pairs(DOCK_LOCATIONS) do
		local dock = MOD[location];
		DockBar_SetDefault(dock.Bar);
		DockBar_UpdateOrder(dock.Bar);
	end

	MOD:UpdateDockBackdrops()
end

function MOD:Refresh()
	local buttonsize = SV.db.Dock.buttonSize;
	local spacing = SV.db.Dock.buttonSpacing;

	for location, settings in pairs(DOCK_LOCATIONS) do
		local width, height = GetDockDimensions(location);
		local dock = self[location];

		dock.Bar:SetSize(width, buttonsize)
	    dock.Bar.ToolBar:SetHeight(buttonsize)
	    dock:SetSize(width, height)
	    dock.Alert:SetSize(width, 1)
	    dock.Window:SetSize(width, height)

	    if(dock.Bar.Button) then
	    	dock.Bar.Button:SetSize(buttonsize, buttonsize)
	    end

	    dock.Bar:Update()
	end

	local centerWidth = SV.db.Dock.dockCenterWidth;
	local dockWidth = centerWidth * 0.5;
	local dockHeight = SV.db.Dock.dockCenterHeight;

	self.BottomCenter:SetSize(centerWidth, dockHeight);
	self.TopCenter:SetSize(centerWidth, dockHeight);

	ScreenBorderVisibility();

	self:UpdateDockBackdrops();
	self:UpdateProfessionTools();
	self:UpdateMiscTools();
	self:UpdateGarrisonTool();
	self:UpdateRaidLeader();

	LoadAllDocklets()

	SV.Events:Trigger("DOCKS_UPDATED");
end

function MOD:PLAYER_REGEN_ENABLED()
	self:UnregisterEvent('PLAYER_REGEN_ENABLED')

	if(self.ProfessionNeedsUpdate) then
		self.ProfessionNeedsUpdate = nil;
		self:UpdateProfessionTools()
	end

	if(self.MiscNeedsUpdate) then
		self.MiscNeedsUpdate = nil;
		self:UpdateMiscTools()
	end

	if(self.GarrisonNeedsUpdate) then
		self.GarrisonNeedsUpdate = nil;
		self:UpdateGarrisonTool()
	end

	if(self.RaidLeaderNeedsUpdate) then
		self.RaidLeaderNeedsUpdate = nil;
		self:UpdateRaidLeader()
	end
end

function MOD:Load()
	if(not SV.private.Docks) then
		SV.private.Docks = {}
	end

	self.private = SV.private.Docks;

	if(not self.private.AllFaded) then self.private.AllFaded = false; end
	if(not self.private.LeftFaded) then self.private.LeftFaded = false; end
	if(not self.private.RightFaded) then self.private.RightFaded = false; end
	if(not self.private.LeftExpanded) then self.private.LeftExpanded = false; end
	if(not self.private.RightExpanded) then self.private.RightExpanded = false; end

	if(not self.private.Order) then self.private.Order = {} end
	if(not self.private.Locations) then self.private.Locations = {} end
	if(not self.private.Windows) then self.private.Windows = {} end
	if(not self.private.Dimensions) then self.private.Dimensions = {} end
	if(not self.private.Opacity) then self.private.Opacity = {} end
	if(not self.private.Disabled) then self.private.Disabled = {} end

	if(self.private.DefaultDocklets) then
		self.private.Active = copyTable(self.private.DefaultDocklets);
		self.private.DefaultDocklets = nil;
	elseif(not self.private.Active) then
		self.private.Active = {}
	end

	self:MakeSharable();
	self:IgnoreSharedKeys('AllFaded','LeftFaded','RightFaded','LeftExpanded','RightExpanded','Embed1','Embed2');

	local buttonsize = SV.db.Dock.buttonSize;
	local spacing = SV.db.Dock.buttonSpacing;

	-- [[ TOP AND BOTTOM BORDERS ]] --

	self:SetBorderTheme();
	ScreenBorderVisibility();

	for location, settings in pairs(DOCK_LOCATIONS) do
		local width, height = GetDockDimensions(location);
		local dock = self[location];
		local mod = settings[1];
		local anchor = upper(location);
		local reverse = SV:GetReversePoint(anchor);
		local barAnchor = settings[2];
		local barReverse = SV:GetReversePoint(barAnchor);
		local isBottom = settings[3];
		local vertMod = isBottom and 1 or -1
		local anchorParent = getParentAnchor(anchor);

		dock.Bar:SetParent(SV.Screen)
		dock.Bar:ClearAllPoints()
		dock.Bar:SetSize(width, buttonsize)
		dock.Bar:SetPoint(anchor, anchorParent, anchor, (2 * mod), (2 * vertMod))

		local highlight = CreateFrame("Frame", nil, dock.Bar)
		highlight:SetFrameStrata("BACKGROUND")
		highlight:SetFrameLevel(1)
		if(location:find('Top')) then
			highlight:SetPoint("TOPLEFT", dock.Bar, "TOPLEFT", 0, 0)
			highlight:SetPoint("TOPRIGHT", dock.Bar, "TOPRIGHT", 0, 0)
			highlight:SetHeight(buttonsize * 2)
			SV.SpecialFX:SetFXFrame(highlight, "dragging_highlight_top")
			highlight.texture = highlight:CreateTexture(nil, "BACKGROUND")
			highlight.texture:SetAllPoints()
			highlight.texture:SetTexture(SV.media.statusbar.default);
			highlight.texture:SetGradientAlpha("VERTICAL",0,0,1,0,0,0.8,1,0.8)
		else
			highlight:SetPoint("BOTTOMLEFT", dock.Bar, "BOTTOMLEFT", 0, 0)
			highlight:SetPoint("BOTTOMRIGHT", dock.Bar, "BOTTOMRIGHT", 0, 0)
			highlight:SetHeight(buttonsize * 2)
			SV.SpecialFX:SetFXFrame(highlight, "dragging_highlight_bottom")
			highlight.texture = highlight:CreateTexture(nil, "BACKGROUND")
			highlight.texture:SetAllPoints()
			highlight.texture:SetTexture(SV.media.statusbar.default);
			highlight.texture:SetGradientAlpha("VERTICAL",0,0.8,1,0.8,0,0,1,0)
		end
		highlight:Hide()

		dock.Bar.Highlight = highlight

		if(not MOD.private.Order[location]) then
			MOD.private.Order[location] = {}
		end

		dock.Bar.ToolBar:ClearAllPoints()

		if(dock.Bar.Button) then
			dock.Bar.Button:SetSize(buttonsize, buttonsize)
			self:SetButtonTheme(dock.Bar.Button, buttonsize)
			dock.Bar.Button.Icon:SetTexture(SV.media.dock.sizeIcon)
			dock.Bar.ToolBar:SetSize(1, buttonsize)
			dock.Bar.ToolBar:SetPoint(barAnchor, dock.Bar.Button, barReverse, (spacing * mod), 0)
			dock.Bar.Button:SetPanelColor("default")
			dock.Bar.Button.Icon:SetGradient(unpack(SV.media.gradient.icon))
			if(location:find('Left')) then
				dock.Bar.Button:SetAttribute("tipText", SHOWORHIDE .. " Left Dock")
				dock.Bar.Button:SetAttribute("tipExtraText", MINIMIZEORMAXIMIZE .. " Left Dock")
			else
				dock.Bar.Button:SetAttribute("tipText", SHOWORHIDE .. " Right Dock")
				dock.Bar.Button:SetAttribute("tipExtraText", MINIMIZEORMAXIMIZE .. " Right Dock")
			end
			dock.Bar.Button:SetScript("OnEnter", CornerButton_OnEnter)
			dock.Bar.Button:SetScript("OnLeave", CornerButton_OnLeave)

			if(location == "BottomLeft") then
				dock.Bar.Button.ToggleFunc = ToggleSuperDockLeft;
			else
				dock.Bar.Button.ToggleFunc = ToggleSuperDockRight;
			end
			dock.Bar.Button:SetScript("OnClick", CornerButton_OnClick)

			if(dock.Bar.Button2) then
				dock.Bar.Button2:SetSize(buttonsize, buttonsize)
				self:SetButtonTheme(dock.Bar.Button2, buttonsize)
				dock.Bar.Button2.Icon:SetTexture(SV.media.dock.optionsIcon)
				dock.Bar.ToolBar:SetSize(1, buttonsize)
				dock.Bar.ToolBar:SetPoint(barAnchor, dock.Bar.Button2, barReverse, (spacing * mod), 0)
				dock.Bar.Button2:SetPanelColor("default")
				dock.Bar.Button2.Icon:SetGradient(unpack(SV.media.gradient.icon))
				if(location:find('Left')) then
					dock.Bar.Button2:SetAttribute("tipText", SHOWORHIDE .. " Left Dock")
					dock.Bar.Button2:SetAttribute("tipExtraText", MINIMIZEORMAXIMIZE .. " Left Dock")
				else
					dock.Bar.Button2:SetAttribute("tipText", SHOWORHIDE .. " Right Dock")
					dock.Bar.Button2:SetAttribute("tipExtraText", MINIMIZEORMAXIMIZE .. " Right Dock")
				end
				dock.Bar.Button2:SetScript("OnEnter", CornerButton2_OnEnter)
				dock.Bar.Button2:SetScript("OnLeave", CornerButton_OnLeave)
				dock.Bar.Button2.ShowDockOptions = CornerButton2_OnClick

				dock.Bar.Button2.ToggleFunc = CornerButton2_OnClick;
				dock.Bar.Button2:SetScript("OnClick", CornerButton_OnClick)
			end
		else
			dock.Bar.ToolBar:SetSize(1, buttonsize)
			dock.Bar.ToolBar:SetPoint(barAnchor, dock.Bar, barAnchor, 0, 0)
		end

		dock:SetParent(SV.Screen)
		dock:ClearAllPoints()
		dock:SetPoint(anchor, dock.Bar, reverse, 0, (12 * vertMod))
		dock:SetSize(width, height)
		dock:SetAttribute("buttonSize", buttonsize)
		dock:SetAttribute("spacingSize", spacing)

		dock.Alert:ClearAllPoints()
		dock.Alert:SetSize(width, 1)
		dock.Alert:SetPoint(anchor, dock, anchor, 0, 0)
		--dock.Alert:SetParent(UIParent)

		dock.Window:ClearAllPoints()
		dock.Window:SetSize(width, height)
		dock.Window:SetPoint(anchor, dock.Alert, reverse, 0, 4)
		dock.Window:SetFrameStrata("BACKGROUND")

		SV:NewAnchor(dock.Bar, location .. " Dock ToolBar");
		SV:SetAnchorResizing(dock.Bar, dockBarPostSizeFunc, 10, 500, 10, 80);
		SV:NewAnchor(dock, location .. " Dock Window");
		SV:SetAnchorResizing(dock, dockPostSizeFunc, 10, 500);

		--dock.Alert:SetParent(UIParent)
	end

	if MOD.private.LeftFaded then MOD.BottomLeft:Hide() end
	if MOD.private.RightFaded then MOD.BottomRight:Hide() end

	SV:ManageVisibility(self.BottomRight.Window)
	SV:ManageVisibility(self.TopLeft)
	SV:ManageVisibility(self.TopRight)
	--SV:ManageVisibility(self.BottomCenter)
	SV:ManageVisibility(self.TopCenter)

	local centerWidth = SV.db.Dock.dockCenterWidth;
	local dockHeight = SV.db.Dock.dockCenterHeight;

	self.TopCenter:SetParent(SV.Screen)
	self.TopCenter:ClearAllPoints()
	self.TopCenter:SetSize(centerWidth, dockHeight)
	self.TopCenter:SetPoint("TOP", SV.Screen, "TOP", 0, 0)

	self.BottomCenter:SetParent(SV.Screen)
	self.BottomCenter:ClearAllPoints()
	self.BottomCenter:SetSize(centerWidth, dockHeight)
	self.BottomCenter:SetPoint("BOTTOM", SV.Screen, "BOTTOM", 0, 0)

	DockBar_SetDefault(self.BottomLeft.Bar)
	DockBar_SetDefault(self.BottomRight.Bar)
	DockBar_SetDefault(self.TopLeft.Bar)
	DockBar_SetDefault(self.TopRight.Bar)

	self:LoadProfessionTools();
	self:LoadAllMiscTools();
	self:LoadGarrisonTool();
	self:LoadRaidLeaderTools();
	self:LoadBreakStuff();
end

SV:NewScript(LoadAllDocklets)
