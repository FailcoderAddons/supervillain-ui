--[[
##########################################################
S V U I   By: Failcoder
##########################################################
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local unpack    = _G.unpack;
local select    = _G.select;
local pairs     = _G.pairs;
local tostring  = _G.tostring;
local tonumber  = _G.tonumber;
local tinsert   = _G.tinsert;
local string    = _G.string;
local math      = _G.math;
--[[ STRING METHODS ]]--
local lower, upper, len = string.lower, string.upper, string.len;
local match, gsub, find = string.match, string.gsub, string.find;
--[[ MATH METHODS ]]--
local parsefloat = math.parsefloat;  -- Uncommon
--[[
##########################################################
GET ADDON DATA
##########################################################
]]--
local SV = _G['SVUI']
local L = SV.L
local MOD = SV.Maps;
if(not MOD) then return end;
--[[
##########################################################
LOCALIZED GLOBALS
##########################################################
]]--
local RAID_CLASS_COLORS = _G.RAID_CLASS_COLORS
--[[
##########################################################
LOCAL VARS
##########################################################
]]--
local temp = SLASH_CALENDAR1:gsub("/", "");
local calendar_string = temp:gsub("^%l", upper)
local cColor = RAID_CLASS_COLORS[SV.class];
local MMBHolder, MMBBar;

local NewHook = hooksecurefunc
local Initialized = false
local CoordPattern = "%.1f";
--[[
##########################################################
DATA UPVALUES
##########################################################
]]--
local MM_XY_COORD = false;
local WMP_XY_COORD = false;
local WMM_XY_COORD = false;
local WM_TINY = false;
local MM_COLOR = "darkest"
local MM_BRDR = 0
local MM_SIZE = 240
local MM_BTN_SIZE = 30
local MM_BTN_ROW = 8
local MM_OFFSET_TOP = (MM_SIZE * 0.07)
local MM_OFFSET_BOTTOM = (MM_SIZE * 0.11)
local MM_WIDTH = MM_SIZE + (MM_BRDR * 2)
local MM_HEIGHT = (MM_SIZE - (MM_OFFSET_TOP + MM_OFFSET_BOTTOM) + (MM_BRDR * 2))
local WM_ALPHA = false;
local MM_BTN_SIZE = 30;
local MM_SHAPE = 'RECTANGLE';
local NARR_TEXT = "Meanwhile";
local NARR_PREFIX = "In ";
--[[
##########################################################
MODULE CHILDREN
##########################################################
]]--
MOD.MinimapButtons = {}
MOD.Holder = _G["SVUI_MinimapFrame"];
MOD.InfoTop = _G["SVUI_MinimapInfoTop"];
MOD.InfoBottom = _G["SVUI_MinimapInfoBottom"];
local MiniMapCoords = _G["SVUI_MiniMapCoords"];
local WorldMapCoords = _G["SVUI_WorldMapCoords"];
--local SVUI_MinimapFrame = CreateFrame("Frame", "SVUI_MinimapFrame", UIParent)
--local WMCoords = CreateFrame('Frame', 'SVUI_WorldMapCoords', WorldMapFrame)
--SVUI_MinimapFrame:SetSize(MM_WIDTH, MM_HEIGHT);
--[[
##########################################################
GENERAL HELPERS
##########################################################
]]--
--[[
 /$$$$$$$  /$$   /$$ /$$$$$$$$/$$$$$$$$/$$$$$$  /$$   /$$  /$$$$$$
| $$__  $$| $$  | $$|__  $$__/__  $$__/$$__  $$| $$$ | $$ /$$__  $$
| $$  \ $$| $$  | $$   | $$     | $$ | $$  \ $$| $$$$| $$| $$  \__/
| $$$$$$$ | $$  | $$   | $$     | $$ | $$  | $$| $$ $$ $$|  $$$$$$
| $$__  $$| $$  | $$   | $$     | $$ | $$  | $$| $$  $$$$ \____  $$
| $$  \ $$| $$  | $$   | $$     | $$ | $$  | $$| $$\  $$$ /$$  \ $$
| $$$$$$$/|  $$$$$$/   | $$     | $$ |  $$$$$$/| $$ \  $$|  $$$$$$/
|_______/  \______/    |__/     |__/  \______/ |__/  \__/ \______/
--]]
local MMB_OnEnter = function(self)
	if(not SV.db.Maps.minimapbar.mouseover or SV.db.Maps.minimapbar.styleType == "NOANCHOR") then return end
	UIFrameFadeIn(SVUI_MiniMapButtonBar, 0.2, SVUI_MiniMapButtonBar:GetAlpha(), 1)
	if self:GetName() ~= "SVUI_MiniMapButtonBar" then
		self:SetBackdropBorderColor(.7, .7, 0)
	end
end

local MMB_OnLeave = function(self)
	if(not SV.db.Maps.minimapbar.mouseover or SV.db.Maps.minimapbar.styleType == "NOANCHOR") then return end
	UIFrameFadeOut(SVUI_MiniMapButtonBar, 0.2, SVUI_MiniMapButtonBar:GetAlpha(), 0)
	if self:GetName() ~= "SVUI_MiniMapButtonBar" then
		self:SetBackdropBorderColor(0, 0, 0)
	end
end

do
	local reserved = {"Node", "Tab", "Pin", "SVUI_ConsolidatedBuffs", "GameTimeframe", "HelpOpenTicketButton", "SVUI_MinimapFrame", "SVUI_EnhancedMinimap", "QueueStatusMinimapButton", "TimeManagerClockButton", "Archy", "GatherMatePin", "GatherNote", "GuildInstance", "HandyNotesPin", "MinimMap", "Spy_MapNoteList_mini", "ZGVMarker", "ZygorGuidesViewerMapIcon"}

	local function UpdateMinimapButtons()
		if(not SV.db.Maps.minimapbar.enable) then return end

		MMBBar:SetPoint("CENTER", MMBHolder, "CENTER", 0, 0)
		MMBBar:SetHeight(MM_BTN_SIZE + 4)
		MMBBar:SetWidth(MM_BTN_SIZE + 4)
		MMBBar:SetFrameStrata("LOW")
		MMBBar:SetFrameLevel(0)

		local list  = MOD.MinimapButtons
		local count,column = 0,1;

		for name,btn in pairs(list) do
			local preset = btn.preset;
			if(SV.db.Maps.minimapbar.styleType == "NOANCHOR") then
				btn:SetParent(preset.Parent)
				if preset.DragStart then
					btn:SetScript("OnDragStart", preset.DragStart)
				end
				if preset.DragEnd then
					btn:SetScript("OnDragStop", preset.DragEnd)
				end
				btn:ClearAllPoints()
				btn:SetSize(preset.Width, preset.Height)
				btn:SetPoint(preset.Point, preset.relativeTo, preset.relativePoint, preset.xOfs, preset.yOfs)
				btn:SetFrameStrata(preset.FrameStrata)
				btn:SetFrameLevel(preset.FrameLevel)
				btn:SetScale(preset.Scale)
				btn:SetMovable(true)
			else
				btn:SetParent(MMBBar)
				btn:SetMovable(false)
				btn:SetScript("OnDragStart", nil)
				btn:SetScript("OnDragStop", nil)
				btn:ClearAllPoints()
				btn:SetFrameStrata("LOW")
				btn:SetFrameLevel(20)
				btn:SetSize(MM_BTN_SIZE, MM_BTN_SIZE)
				if(column > MM_BTN_ROW) then
					column = 1;
				end
				local xPos, yPos = 0,0;
				local row = floor(count / MM_BTN_ROW);
				if SV.db.Maps.minimapbar.styleType == "HORIZONTAL"then
					xPos = ((MM_BTN_SIZE + 2) * column);
					yPos = ((MM_BTN_SIZE + 2) * row);
				else
					xPos = ((MM_BTN_SIZE + 2) * row);
					yPos = ((MM_BTN_SIZE + 2) * column);
				end
				btn:SetPoint("TOPRIGHT", MMBBar, "TOPRIGHT", -xPos, -yPos)
			end
			column = column + 1;
			count = count + 1;
		end

		if (SV.db.Maps.minimapbar.styleType ~= "NOANCHOR" and (count > 0)) then
			if SV.db.Maps.minimapbar.styleType == "HORIZONTAL" then
				MMBBar:SetWidth((MM_BTN_SIZE + 2) * MM_BTN_ROW)
			else
				MMBBar:SetHeight((MM_BTN_SIZE + 2) * MM_BTN_ROW)
			end
			MMBHolder:SetSize(MMBBar:GetSize())
			MMBBar:Show()
		else
			MMBBar:Hide()
		end
	end

	local function SetMinimapButton(btn)
		if btn == nil or btn:GetName() == nil or btn:GetObjectType() ~= "Button" or not btn:IsVisible() then return end
		local name = btn:GetName()
		local isLib = false;
		if name:sub(1,len("LibDBIcon")) == "LibDBIcon" then isLib = true end
		if(not isLib) then
			local count = #reserved
			for i = 1, count do
				if name:sub(1,len(reserved[i])) == reserved[i] then return end
				if name:find(reserved[i]) ~= nil then return end
			end
		end

		btn:SetPushedTexture("")
		btn:SetHighlightTexture("")
		btn:SetDisabledTexture("")

		if not btn.isStyled then
			btn:HookScript("OnEnter", MMB_OnEnter)
			btn:HookScript("OnLeave", MMB_OnLeave)
			btn:HookScript("OnClick", UpdateMinimapButtons)
			btn.preset = {}
			btn.preset.Width, btn.preset.Height = btn:GetSize()
			btn.preset.Point, btn.preset.relativeTo, btn.preset.relativePoint, btn.preset.xOfs, btn.preset.yOfs = btn:GetPoint()
			btn.preset.Parent = btn:GetParent()
			btn.preset.FrameStrata = btn:GetFrameStrata()
			btn.preset.FrameLevel = btn:GetFrameLevel()
			btn.preset.Scale = btn:GetScale()
			if btn:HasScript("OnDragStart") then
				btn.preset.DragStart = btn:GetScript("OnDragStart")
			end
			if btn:HasScript("OnDragEnd") then
				btn.preset.DragEnd = btn:GetScript("OnDragEnd")
			end
			for i = 1, btn:GetNumRegions() do
				local frame = select(i, btn:GetRegions())
				if frame:GetObjectType() == "Texture" then
					local iconFile = frame:GetTexture()
					--JV: Check type in case iconFile is a number - reported error involving LiDBIcon - need to find root cause
					if((iconFile ~= nil and type(iconFile) == "string") and (iconFile:find("Border") or iconFile:find("Background") or iconFile:find("AlphaMask"))) then
						frame:SetTexture("")
					else
						frame:ClearAllPoints()
						frame:SetPoint("TOPLEFT", btn, "TOPLEFT", 2, -2)
						frame:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -2, 2)
						frame:SetTexCoord(0.1, 0.9, 0.1, 0.9 )
						frame:SetDrawLayer("ARTWORK")
						if name == "PS_MinimapButton" then
							frame.SetPoint = SV.fubar
						end
					end
				end
			end

			btn:SetStyle("Button", -1, -1)

			if(name == "DBMMinimapButton") then
				btn:SetNormalTexture("Interface\\Icons\\INV_Helmet_87")
			end

			if(name == "SmartBuff_MiniMapButton") then
				btn:SetNormalTexture(select(3, GetSpellInfo(12051)))
			end

			btn.isStyled = true

			MOD.MinimapButtons[name] = btn
		end
	end

	local StyleMinimapButtons = function()
		local count = Minimap:GetNumChildren()

		for i=1, count do
			local child = select(i,Minimap:GetChildren())
			SetMinimapButton(child)
		end

		UpdateMinimapButtons()

		if SV.db.Maps.minimapbar.mouseover then
			MMBBar:SetAlpha(0)
		else
			MMBBar:SetAlpha(1)
		end
	end

	function MOD:UpdateMinimapButtonSettings(notimer)
		if(not SV.db.Maps.minimapbar.enable or not MMBBar:IsShown()) then return end
		if(notimer) then
			StyleMinimapButtons()
		else
			SV.Timers:ExecuteTimer(StyleMinimapButtons, 4)
		end
	end
end

local function UpdateMiniMapCoords()
	if(WMP_XY_COORD and WorldMapFrame:IsShown()) then return end
    if (IsInInstance()) then return end
    local cmap = C_Map.GetBestMapForUnit("player")
    local position = C_Map.GetPlayerMapPosition(cmap, "player");
    local playerX = position.x
    local playerY = position.y
	if((playerX ~= 0 and playerY ~= 0)) then
		playerX = parsefloat(100 * playerX, 2)
		playerY = parsefloat(100 * playerY, 2)
		if(playerX ~= 0 and playerY ~= 0) then
			if(not MiniMapCoords:IsShown()) then
				MiniMapCoords:FadeIn()
			end
			MiniMapCoords.XLabel:SetText("X:")
			MiniMapCoords.X:SetFormattedText(CoordPattern, playerX)
			MiniMapCoords.YLabel:SetText("Y:")
			MiniMapCoords.Y:SetFormattedText(CoordPattern, playerY)
		else
			-- if(MiniMapCoords:IsShown()) then
			-- 	MiniMapCoords:FadeOut(0.2, 1, 0)
			-- end
			MiniMapCoords.XLabel:SetText("")
			MiniMapCoords.X:SetText("")
			MiniMapCoords.YLabel:SetText("")
			MiniMapCoords.Y:SetText("")
		end
	else
		MiniMapCoords.XLabel:SetText("")
		MiniMapCoords.X:SetText("")
		MiniMapCoords.YLabel:SetText("")
		MiniMapCoords.Y:SetText("")
	end
end

local function UpdateWorldMapCoords()
	if(not WorldMapFrame:IsShown()) then return end
    if (IsInInstance()) then return end
    
	if(WMP_XY_COORD) then
		local cmap = C_Map.GetBestMapForUnit("player")
	    local position = C_Map.GetPlayerMapPosition(cmap, "player");
        local playerX = position.x
        local playerY = position.y
		if((playerX ~= 0 and playerY ~= 0)) then
			playerX = parsefloat(100 * playerX, 2)
			playerY = parsefloat(100 * playerY, 2)
			if(playerX ~= 0 and playerY ~= 0) then
				if(not WorldMapCoords.Player:IsShown()) then
					WorldMapCoords.Player:FadeIn()
				end
				WorldMapCoords.Player.X:SetFormattedText(CoordPattern, playerX)
				WorldMapCoords.Player.Y:SetFormattedText(CoordPattern, playerY)
			else
				WorldMapCoords.Player:FadeOut(0.2, 1, 0, true)
			end
		else
			WorldMapCoords.Player:FadeOut(0.2, 1, 0, true)
		end
	end

	if(WMM_XY_COORD) then
		local scale = WorldMapFrame:GetEffectiveScale()
		local width = WorldMapFrame:GetWidth()
		local height = WorldMapFrame:GetHeight()
		local centerX, centerY = WorldMapFrame:GetCenter()
		local cursorX, cursorY = GetCursorPosition()
		local mouseX = (cursorX / scale - (centerX - (width / 2))) / width;
		local mouseY = (centerY + (height / 2) - cursorY / scale) / height;
		if(((mouseX >= 0) and (mouseX <= 1)) and ((mouseY >= 0) and (mouseY <= 1))) then
			mouseX = parsefloat(100 * mouseX, 2)
			mouseY = parsefloat(100 * mouseY, 2)
			if(not WorldMapCoords.Mouse:IsShown()) then
				WorldMapCoords.Mouse:FadeIn()
			end
			WorldMapCoords.Mouse.X:SetFormattedText(CoordPattern, mouseX)
			WorldMapCoords.Mouse.Y:SetFormattedText(CoordPattern, mouseY)
		else
			WorldMapCoords.Mouse:FadeOut(0.2, 1, 0, true)
		end
	end

	--[[if(WM_ALPHA and (not WorldMapFrame_InWindowedMode())) then
		local speed = GetUnitSpeed("player")
		if(speed ~= 0) then
			WorldMapFrame:SetAlpha(0.2)
		else
			WorldMapFrame:SetAlpha(1)
		end
	end]]--
end

--[[
 /$$      /$$  /$$$$$$  /$$$$$$$  /$$       /$$$$$$$  /$$      /$$  /$$$$$$  /$$$$$$$
| $$  /$ | $$ /$$__  $$| $$__  $$| $$      | $$__  $$| $$$    /$$$ /$$__  $$| $$__  $$
| $$ /$$$| $$| $$  \ $$| $$  \ $$| $$      | $$  \ $$| $$$$  /$$$$| $$  \ $$| $$  \ $$
| $$/$$ $$ $$| $$  | $$| $$$$$$$/| $$      | $$  | $$| $$ $$/$$ $$| $$$$$$$$| $$$$$$$/
| $$$$_  $$$$| $$  | $$| $$__  $$| $$      | $$  | $$| $$  $$$| $$| $$__  $$| $$____/
| $$$/ \  $$$| $$  | $$| $$  \ $$| $$      | $$  | $$| $$\  $ | $$| $$  | $$| $$
| $$/   \  $$|  $$$$$$/| $$  | $$| $$$$$$$$| $$$$$$$/| $$ \/  | $$| $$  | $$| $$
|__/     \__/ \______/ |__/  |__/|________/|_______/ |__/     |__/|__/  |__/|__/
--]]

local function SetLargeWorldMap()
	if InCombatLockdown() then return end

	if SV.db.Maps.tinyWorldMap == true then
		-- WorldMapFrame:SetParent(SV.Screen)
		WorldMapFrame:EnableMouse(false)
		WorldMapFrame:EnableKeyboard(false)
		WorldMapFrame:SetScale(1)
		if WorldMapFrame:GetAttribute('UIPanelLayout-area') ~= 'center'then
			SetUIPanelAttribute(WorldMapFrame, "area", "center")
		end
		if WorldMapFrame:GetAttribute('UIPanelLayout-allowOtherPanels') ~= true then
			SetUIPanelAttribute(WorldMapFrame, "allowOtherPanels", true)
		end
	end

	--WorldMapFrameSizeUpButton:Hide()
	--WorldMapFrameSizeDownButton:Show()
end

local function SetSmallWorldMap()
	if InCombatLockdown() then return end
	--WorldMapFrameSizeUpButton:Show()
	--WorldMapFrameSizeDownButton:Hide()
end

local function AdjustMapSize()
	if InCombatLockdown() then return end

	--[[if WORLDMAP_SETTINGS.size == WORLDMAP_FULLMAP_SIZE then
		WorldMapFrame:SetPoint("TOP", SV.Screen, "TOP", 0, 0)
	end

	if SV.db.Maps.tinyWorldMap == true then
		BlackoutWorld:SetTexture("")
	else
		BlackoutWorld:SetColorTexture(0, 0, 0, 1)
	end--]]
end

local function UpdateWorldMapConfig()
	if(not MM_XY_COORD) then
		if MOD.MMCoordTimer then
			SV.Timers:RemoveLoop(MOD.MMCoordTimer)
			MOD.MMCoordTimer = nil;
		end
		MiniMapCoords.XLabel:SetText("")
		MiniMapCoords.X:SetText("")
		MiniMapCoords.YLabel:SetText("")
		MiniMapCoords.Y:SetText("")
	else
		MiniMapCoords.XLabel:SetText("X:")
		MiniMapCoords.YLabel:SetText("Y:")
		UpdateMiniMapCoords()
		MOD.MMCoordTimer = SV.Timers:ExecuteLoop(UpdateMiniMapCoords, 0.1)
	end

	if((not WMP_XY_COORD) and (not WMM_XY_COORD)) then
		if MOD.WMCoordTimer then
			SV.Timers:RemoveLoop(MOD.WMCoordTimer)
			MOD.WMCoordTimer = nil;
		end
		WorldMapCoords.Player.Name:SetText("")
		WorldMapCoords.Player.XLabel:SetText("")
		WorldMapCoords.Player.X:SetText("")
		WorldMapCoords.Player.YLabel:SetText("")
		WorldMapCoords.Player.Y:SetText("")

		WorldMapCoords.Mouse.Name:SetText("")
		WorldMapCoords.Mouse.XLabel:SetText("")
		WorldMapCoords.Mouse.X:SetText("")
		WorldMapCoords.Mouse.YLabel:SetText("")
		WorldMapCoords.Mouse.Y:SetText("")
	else
		if(not WMP_XY_COORD) then
			WorldMapCoords.Player.XLabel:SetText("")
			WorldMapCoords.Player.X:SetText("")
			WorldMapCoords.Player.YLabel:SetText("")
			WorldMapCoords.Player.Y:SetText("")
			WorldMapCoords.Player.Name:SetText("");
		else
			WorldMapCoords.Player.XLabel:SetText("X:")
			WorldMapCoords.Player.YLabel:SetText("Y:")
			WorldMapCoords.Player.Name:SetText(PLAYER);
		end
		if(not WMM_XY_COORD) then
			WorldMapCoords.Mouse.XLabel:SetText("")
			WorldMapCoords.Mouse.X:SetText("")
			WorldMapCoords.Mouse.YLabel:SetText("")
			WorldMapCoords.Mouse.Y:SetText("")
			WorldMapCoords.Mouse.Name:SetText("");
		else
			WorldMapCoords.Mouse.XLabel:SetText("X:")
			WorldMapCoords.Mouse.YLabel:SetText("Y:")
			WorldMapCoords.Mouse.Name:SetText(MOUSE_LABEL);
		end
		UpdateWorldMapCoords()
		MOD.WMCoordTimer = SV.Timers:ExecuteLoop(UpdateWorldMapCoords, 0.1)
	end

	if InCombatLockdown()then return end
	--[[if(not MOD.WorldMapHooked) then
		NewHook("WorldMap_ToggleSizeUp", AdjustMapSize)
		--Removed for 7.3
		--NewHook("WorldMap_ToggleSizeDown", SetSmallWorldMap)
		MOD.WorldMapHooked = true
	end--]]
	AdjustMapSize()
end
--[[
##########################################################
HANDLERS
##########################################################
]]--
local MiniMap_MouseUp = function(self, btn)
	local position = self:GetPoint()
	if btn == "RightButton" then
		local xoff = -1
		if position:match("RIGHT") then xoff = -16 end
		ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, self, xoff, -3)
	else
		Minimap_OnClick(self)
	end
end

local MiniMap_MouseWheel = function(self, delta)
	if delta > 0 then
		_G.MinimapZoomIn:Click()
	elseif delta < 0 then
		_G.MinimapZoomOut:Click()
	end
end

local Calendar_OnClick = function(self)
	GameTimeFrame:Click();
end

local Tracking_OnClick = function(self)
	local position = self:GetPoint()
	local xoff = -1
	if position:match("RIGHT") then xoff = -16 end
	ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, self, xoff, -3)
end

local Basic_OnEnter = function(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 4)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(self.TText, 1, 1, 1)
	GameTooltip:Show()
end

local Basic_OnLeave = function(self)
	GameTooltip:Hide()
end

local Tour_OnEnter = function(self, ...)
	if InCombatLockdown() then
		GameTooltip:Hide()
	else
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -4)
		GameTooltip:ClearAllPoints()
		GameTooltip:SetPoint("BOTTOM", self, "BOTTOM", 0, 0)
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(L["Click : "], L["Toggle WorldMap"], 0.7, 0.7, 1, 0.7, 0.7, 1)
		GameTooltip:AddDoubleLine(L["ShiftClick : "], L["Announce your position in chat"],0.7, 0.7, 1, 0.7, 0.7, 1)
		GameTooltip:Show()
	end
end

local Tour_OnLeave = function(self, ...)
	GameTooltip:Hide()
end

local Tour_OnClick = function(self, btn)
	if IsShiftKeyDown() then
		local zoneText = GetRealZoneText() or UNKNOWN;
		local subZone = GetSubZoneText() or UNKNOWN;
		local edit_box = ChatEdit_ChooseBoxForSend();
        local cmap = C_Map.GetBestMapForUnit("player")
        local position = C_Map.GetPlayerMapPosition(cmap, "player");
        local x = position.x
        local y = position.y

		x = tonumber(parsefloat(100 * x, 0));
		y = tonumber(parsefloat(100 * y, 0));
		local coords = ("%d, %d"):format(x, y);

		ChatEdit_ActivateChat(edit_box)

		if(zoneText ~= subZone) then
			local message = ("%s: %s (%s)"):format(zoneText, subZone, coords)
			edit_box:Insert(message)
		else
			local message = ("%s (%s)"):format(zoneText, coords)
			edit_box:Insert(message)
		end
	else
		ToggleFrame(WorldMapFrame)
	end
	GameTooltip:Hide()
end
--[[
##########################################################
HOOKS
##########################################################
]]--
local _hook_WorldMapZoneDropDownButton_OnClick = function(self)
	DropDownList1:ClearAllPoints()
	DropDownList1:SetPoint("TOPRIGHT",self,"BOTTOMRIGHT",-17,-4)
end

local _hook_WorldMapFrame_OnShow = function()
	MOD:RegisterEvent("PLAYER_REGEN_DISABLED");

	if InCombatLockdown()then return end

	if(not SV.db.Maps.tinyWorldMap and not Initialized) then
      WorldMap_ToggleSizeUp()
      Initialized = true
    end
end

local _hook_WorldMapFrame_OnHide = function()
	MOD:UnregisterEvent("PLAYER_REGEN_DISABLED")
end

local _hook_DropDownList1 = function(self)
	local parentScale = UIParent:GetScale()
	if(self:GetScale() ~= parentScale) then
		self:SetScale(parentScale)
	end
end
--[[
##########################################################
EVENTS
##########################################################
]]--
function MOD:RefreshZoneText()
	if(not SV.db.Maps.locationText or SV.db.Maps.locationText == "HIDE") then
		self.InfoTop:Hide();
		self.InfoBottom:Hide();
	else
		if(SV.db.Maps.locationText == "SIMPLE") then
			self.InfoTop:Hide();
			self.InfoBottom:Show();
			NARR_TEXT = "";
			NARR_PREFIX = "";
			self.InfoTop.Text:SetText(NARR_TEXT)
		else
			self.InfoTop:Show();
			self.InfoBottom:Show();
			NARR_TEXT = L['Meanwhile'];
			NARR_PREFIX = L["..at "];
			self.InfoTop.Text:SetText(NARR_TEXT)
		end
		local zone = GetMinimapZoneText() or UNKNOWN
		zone = zone:sub(1, 25);
		local zoneText = ("%s%s"):format(NARR_PREFIX, zone);
		self.InfoBottom.Text:SetText(zoneText)
	end
end

local InfoBottom_OnEnter = function(self)
	if(not self:IsShown()) then return end
	local zone = GetRealZoneText() or UNKNOWN
	zone = zone:sub(1, 25);
	local zoneText = ("%s%s"):format(L["..in "], zone);
	self.Text:SetText(zoneText)
end

local InfoBottom_OnLeave = function(self)
	if(not self:IsShown()) then return end
	local zone = GetMinimapZoneText() or UNKNOWN
	zone = zone:sub(1, 25);
	local zoneText = ("%s%s"):format(NARR_PREFIX, zone);
	self.Text:SetText(zoneText)
end

function MOD:ADDON_LOADED(event, addon)
	if TimeManagerClockButton then
		TimeManagerClockButton:Die()
	end
	self:UnregisterEvent("ADDON_LOADED")
	if addon == "Blizzard_FeedbackUI" then
		FeedbackUIButton:Die()
	end
	self:UpdateMinimapButtonSettings()
end

function MOD:PLAYER_REGEN_ENABLED()
	--WorldMapFrameSizeDownButton:Enable()
	--WorldMapFrameSizeUpButton:Enable()
	if(self.CombatLocked) then
		self:RefreshMiniMap()
		self.CombatLocked = nil
	end
end

function MOD:PLAYER_REGEN_DISABLED()
	--WorldMapFrameSizeDownButton:Disable()
	--WorldMapFrameSizeUpButton:Disable()
end
--[[
##########################################################
CORE FUNCTIONS
##########################################################
]]--
function MOD:RefreshMiniMap()
	if(InCombatLockdown()) then
		self.CombatLocked = true
		return
	end

	self:UpdateLocals()

	if(self.Holder and self.Holder:IsShown()) then
		local minimapRotationEnabled = GetCVar("rotateMinimap") ~= "0"

		if(minimapRotationEnabled or (MM_SHAPE == 'ROUND')) then
			--SV.Dock.TopRight:SetSize(MM_WIDTH, (MM_WIDTH + 4))
			self.Holder:SetSize(MM_WIDTH, MM_WIDTH)
			Minimap:SetSize(MM_SIZE,MM_SIZE)
			self.Holder.Square:Hide()
			self.Holder.Circle:Show()
			Minimap:SetHitRectInsets(0, 0, 0, 0)
			Minimap:InsetPoints(self.Holder, MM_BRDR, MM_BRDR)
			Minimap:SetMaskTexture('Textures\\MinimapMask')
		else
			--SV.Dock.TopRight:SetSize(MM_WIDTH, (MM_HEIGHT + 4))
			self.Holder:SetSize(MM_WIDTH, MM_HEIGHT)
			Minimap:SetSize(MM_SIZE,MM_SIZE)
			self.Holder.Circle:Hide()
			self.Holder.Square:Show()
			self.Holder.Square:SetPanelColor(MM_COLOR)

			if MM_SHAPE == 'RECTANGLE' then
				Minimap:SetPoint("BOTTOMLEFT", self.Holder, "BOTTOMLEFT", MM_BRDR, (MM_OFFSET_BOTTOM - MM_BRDR) * -1)
				Minimap:SetPoint("TOPRIGHT", self.Holder, "TOPRIGHT", -MM_BRDR, (MM_OFFSET_TOP - MM_BRDR))
				Minimap:SetMaskTexture(MOD.media.rectangleMask)
			else
				Minimap:SetHitRectInsets(0, 0, 0, 0)
				Minimap:InsetPoints(self.Holder, MM_BRDR, MM_BRDR)
				Minimap:SetMaskTexture(MOD.media.squareMask)
			end
		end
		Minimap:SetParent(self.Holder)
		Minimap:SetZoom(1)
		Minimap:SetZoom(0)

		if(SV.Auras and self.Holder.Grip) then
			SV.Auras:UpdateAuraHolder(MM_HEIGHT, self.Holder.Grip)
		end
	--else
		--SV.Dock.TopRight:SetSize(MM_WIDTH, (MM_HEIGHT + 4))
	end

	--self.InfoTop.Text:SetSize(MM_WIDTH,28)
	self.InfoBottom.Text:SetSize(MM_WIDTH,32)
	self:RefreshZoneText()

	if TimeManagerClockButton then
		TimeManagerClockButton:Die()
	end

	UpdateWorldMapConfig()
end

local function RotationHook()
	MOD:RefreshMiniMap()
end
--[[
##########################################################
BUILD FUNCTION / UPDATE
##########################################################
]]--
function MOD:UpdateLocals()
	local db = SV.db.Maps
	if not db then return end

	MM_XY_COORD = db.miniPlayerXY;
	WMP_XY_COORD = db.worldPlayerXY;
	WMM_XY_COORD = db.worldMouseXY;
	WM_TINY = db.tinyWorldMap;
	MM_COLOR = db.bordercolor
	MM_BRDR = db.bordersize or 0
	MM_SIZE = db.size or 240
	MM_OFFSET_TOP = (MM_SIZE * 0.07)
	MM_OFFSET_BOTTOM = (MM_SIZE * 0.11)
	MM_WIDTH = MM_SIZE + (MM_BRDR * 2)
	MM_SHAPE = db.mapShape;
	MM_BTN_SIZE = db.minimapbar.buttonSize;
	MM_BTN_ROW = db.minimapbar.perRow;
	MM_HEIGHT = (MM_SHAPE == 'RECTANGLE') and (MM_SIZE - (MM_OFFSET_TOP + MM_OFFSET_BOTTOM) + (MM_BRDR * 2)) or MM_WIDTH
	WM_ALPHA = GetCVarBool("mapFade")
end

function MOD:ReLoad()
	self:RefreshMiniMap()
	self:UpdateMinimapButtonSettings(true)
end

local function MapTriggerFired()
	MOD:RefreshMiniMap()
	MOD:UpdateMinimapButtonSettings()
end

local _hook_BlipTextures = function(self, texture)
	if(SV.db.Maps.customIcons and (texture ~= MOD.media.customBlips)) then
		self:SetBlipTexture(MOD.media.customBlips)
	else
		if((not SV.db.Maps.customIcons) and texture ~= MOD.media.defaultBlips) then
			self:SetBlipTexture(MOD.media.defaultBlips)
		end
	end
end

function MOD:Load()
	self:UpdateLocals()

	--Minimap:SetPlayerTexture(MOD.media.playerArrow)
	--Minimap:SetCorpsePOIArrowTexture(MOD.media.corpseArrow)
	--Minimap:SetPOIArrowTexture(MOD.media.guideArrow)
	if(SV.db.Maps.customIcons) then
		--Minimap:SetBlipTexture(MOD.media.customBlips)
	else
		--Minimap:SetBlipTexture(MOD.media.defaultBlips)
	end

	Minimap:SetClampedToScreen(false)
	if TimeManagerClockButton then
		TimeManagerClockButton:Die()
	end

	Minimap:SetQuestBlobRingAlpha(0)
	Minimap:SetArchBlobRingAlpha(0)
	Minimap:SetParent(self.Holder)
	Minimap:SetFrameStrata("LOW")
	Minimap:SetFrameLevel(Minimap:GetFrameLevel() + 2)

	self.Holder:SetFrameLevel(Minimap:GetFrameLevel() - 2)
	self.Holder:SetFrameStrata("LOW")
	self.Holder:SetPoint("TOPRIGHT", SV.Dock.Top, "TOPRIGHT", -15, -18)
	self.Holder:SetSize(MM_WIDTH, MM_HEIGHT)

	self.Holder.Square = CreateFrame("Frame", nil, self.Holder)
	self.Holder.Square:WrapPoints(self.Holder, 2)
	self.Holder.Square:SetStyle("Frame", "Minimap")
	self.Holder.Square:SetPanelColor(MM_COLOR)

	self.Holder.Circle = self.Holder:CreateTexture(nil, "BACKGROUND", nil, -2)
	self.Holder.Circle:WrapPoints(self.Holder, 2)
	self.Holder.Circle:SetTexture(MOD.media.roundBorder)
	self.Holder.Circle:SetVertexColor(0,0,0)
	self.Holder.Circle:Hide()

	--ShowUIPanel(SpellBookFrame)
	HideUIPanel(SpellBookFrame)
	MinimapBorder:Hide()
	MinimapBorderTop:Hide()
	MinimapZoomIn:Hide()
	MinimapZoomOut:Hide()
	--MiniMapVoiceChatFrame:Hide()
	MinimapNorthTag:Die()
	GameTimeFrame:Hide()
	MinimapZoneTextButton:Hide()
	MiniMapTracking:Hide()
	MiniMapMailFrame:ClearAllPoints()
	MiniMapMailFrame:SetPoint("TOPRIGHT", self.Holder, 3, 4)
	MiniMapMailBorder:Hide()
	MiniMapMailIcon:SetTexture(MOD.media.mailIcon)
	MiniMapWorldMapButton:Hide()

	MiniMapInstanceDifficulty:ClearAllPoints()
	MiniMapInstanceDifficulty:SetParent(Minimap)
	MiniMapInstanceDifficulty:SetPoint("LEFT", self.Holder, "LEFT", 0, 0)

	GuildInstanceDifficulty:ClearAllPoints()
	GuildInstanceDifficulty:SetParent(Minimap)
	GuildInstanceDifficulty:SetPoint("LEFT", self.Holder, "LEFT", 0, 0)

	MiniMapChallengeMode:ClearAllPoints()
	MiniMapChallengeMode:SetParent(Minimap)
	MiniMapChallengeMode:SetPoint("LEFT", self.Holder, "LEFT", 12, 0)

	QueueStatusMinimapButton:ClearAllPoints()
	QueueStatusMinimapButton:SetPoint("BOTTOMLEFT", self.Holder, "BOTTOMLEFT", 2, 1)
	QueueStatusMinimapButton:SetStyle("Frame", "Default", true, 1, -4, -4)

	QueueStatusFrame:SetClampedToScreen(true)
	QueueStatusMinimapButtonBorder:Hide()
	QueueStatusMinimapButton:SetScript("OnShow", function()
		MiniMapInstanceDifficulty:SetPoint("BOTTOMLEFT", QueueStatusMinimapButton, "TOPLEFT", 0, 0)
		GuildInstanceDifficulty:SetPoint("BOTTOMLEFT", QueueStatusMinimapButton, "TOPLEFT", 0, 0)
		MiniMapChallengeMode:SetPoint("BOTTOMLEFT", QueueStatusMinimapButton, "TOPRIGHT", 0, 0)
	end)
	QueueStatusMinimapButton:SetScript("OnHide", function()
		MiniMapInstanceDifficulty:SetPoint("LEFT", self.Holder, "LEFT", 0, 0)
		GuildInstanceDifficulty:SetPoint("LEFT", self.Holder, "LEFT", 0, 0)
		MiniMapChallengeMode:SetPoint("LEFT", self.Holder, "LEFT", 12, 0)
	end)

	if FeedbackUIButton then
		FeedbackUIButton:Die()
	end

	local mwfont = SV.media.font.narrator

	self.InfoTop:SetPoint("TOPLEFT", self.Holder, "TOPLEFT", 4, -4)
	--self.InfoTop:SetSize(100, 22)
	self.InfoTop:SetStyle("Frame")
  	self.InfoTop:SetPanelColor("yellow")
  	self.InfoTop:SetBackdropColor(1, 1, 0, 1)
	self.InfoTop:SetFrameLevel(Minimap:GetFrameLevel() + 2)

	self.InfoTop.Text:SetShadowColor(0, 0, 0, 0.3)
	self.InfoTop.Text:SetShadowOffset(2, -2);

	self.InfoTop.Panel:ClearAllPoints();
	self.InfoTop.Panel:SetPoint("TOPLEFT", self.InfoTop.Text, "TOPLEFT", -4, 4);
	self.InfoTop.Panel:SetPoint("BOTTOMRIGHT", self.InfoTop.Text, "BOTTOMRIGHT", 4, -4);
	self.InfoTop.Panel:SetAttribute("panelLocked", true);

	self.InfoBottom:SetPoint("BOTTOMRIGHT", self.Holder, "BOTTOMRIGHT", -MM_BRDR, -3)
	self.InfoBottom:SetSize(MM_WIDTH, 28)
	self.InfoBottom:SetFrameLevel(Minimap:GetFrameLevel() + 1)

	self.InfoBottom.Text:SetShadowColor(0, 0, 0, 0.3)
	self.InfoBottom.Text:SetShadowOffset(-2, 2)
	self.InfoBottom:SetScript("OnEnter", InfoBottom_OnEnter)
	self.InfoBottom:SetScript("OnLeave", InfoBottom_OnLeave)

	Minimap:EnableMouseWheel(true)
	Minimap:SetScript("OnMouseWheel", MiniMap_MouseWheel)
	Minimap:SetScript("OnMouseUp", MiniMap_MouseUp)

	SV:NewAnchor(self.Holder, L["Minimap"])

	if(SV.db.Maps.tinyWorldMap) then
		setfenv(WorldMapFrame_OnShow, setmetatable({ UpdateMicroButtons = SV.fubar }, { __index = _G }))
		-- WorldMapFrame:SetParent(SV.Screen)
		WorldMapFrame:HookScript('OnShow', _hook_WorldMapFrame_OnShow)
		WorldMapFrame:HookScript('OnHide', _hook_WorldMapFrame_OnHide)
	end

	WorldMapCoords:SetFrameLevel(QuestLogPopupDetailFrame:GetFrameLevel() + 1);
	WorldMapCoords:SetFrameStrata(QuestLogPopupDetailFrame:GetFrameStrata());
	WorldMapCoords.Player.Name:SetText(PLAYER);
	WorldMapCoords.Mouse.Name:SetText(MOUSE_LABEL);

	--SV:NewAnchor(WorldMapCoords, L["WorldMap Coordinates"])

	DropDownList1:HookScript('OnShow', _hook_DropDownList1)
	WorldFrame:SetAllPoints()

	SV:ManageVisibility(self.Holder)

	MiniMapCoords:ClearAllPoints()
	MiniMapCoords:SetFrameLevel(Minimap:GetFrameLevel() + 1)
	MiniMapCoords:SetFrameStrata(Minimap:GetFrameStrata())
	MiniMapCoords:SetPoint("TOPLEFT", self.Holder, "BOTTOMLEFT", 0, -4)
	MiniMapCoords:SetWidth(self.Holder:GetWidth())
	MiniMapCoords:EnableMouse(true)
	MiniMapCoords:SetScript("OnEnter",Tour_OnEnter)
	MiniMapCoords:SetScript("OnLeave",Tour_OnLeave)
	MiniMapCoords:SetScript("OnMouseDown",Tour_OnClick)

	MiniMapCoords.X:SetTextColor(cColor.r, cColor.g, cColor.b)
	MiniMapCoords.Y:SetTextColor(cColor.r, cColor.g, cColor.b)

	if (SV.db.Maps.calendarShortcut) then
		local calendarButton = CreateFrame("Button", "SVUI_CalendarButton", MiniMapCoords)
		calendarButton:SetSize(22,22)
		calendarButton:SetPoint("RIGHT", MiniMapCoords, "RIGHT", 0, 0)
		calendarButton:RemoveTextures()
		calendarButton:SetNormalTexture(MOD.media.calendarIcon)
		calendarButton:SetPushedTexture(MOD.media.calendarIcon)
		calendarButton:SetHighlightTexture(MOD.media.calendarIcon)
		calendarButton.TText = "Calendar"
		calendarButton:RegisterForClicks("AnyUp")
		calendarButton:SetScript("OnEnter", Basic_OnEnter)
		calendarButton:SetScript("OnLeave", Basic_OnLeave)
		calendarButton:SetScript("OnClick", Calendar_OnClick)
	end

	if (SV.db.Maps.trackingShortcut) then
		local trackingButton = CreateFrame("Button", "SVUI_TrackingButton", MiniMapCoords)
		trackingButton:SetSize(22,22)
		if (SVUI_CalendarButton) then
			trackingButton:SetPoint("RIGHT", SVUI_CalendarButton, "LEFT", -4, 0)
		else
			trackingButton:SetPoint("RIGHT", MiniMapCoords, "RIGHT", 0, 0)
		end
		trackingButton:RemoveTextures()
		trackingButton:SetNormalTexture(MOD.media.trackingIcon)
		trackingButton:SetPushedTexture(MOD.media.trackingIcon)
		trackingButton:SetHighlightTexture(MOD.media.trackingIcon)
		trackingButton.TText = "Tracking"
		trackingButton:RegisterForClicks("AnyUp")
		trackingButton:SetScript("OnEnter", Basic_OnEnter)
		trackingButton:SetScript("OnLeave", Basic_OnLeave)
		trackingButton:SetScript("OnClick", Tracking_OnClick)
	end

	SV:NewAnchor(MiniMapCoords, L["Minimap ToolBar"])

	if(SV.db.Maps.minimapbar.enable == true) then
		MMBHolder = CreateFrame("Frame", "SVUI_MiniMapButtonHolder", self.Holder)
		MMBHolder:SetPoint("TOPRIGHT", MiniMapCoords, "BOTTOMRIGHT", 0, -4)
		MMBHolder:SetSize(self.Holder:GetWidth(), 32)
		MMBHolder:SetFrameStrata("BACKGROUND")
		MMBBar = CreateFrame("Frame", "SVUI_MiniMapButtonBar", MMBHolder)
		MMBBar:SetFrameStrata("LOW")
		MMBBar:ClearAllPoints()
		MMBBar:SetPoint("CENTER", MMBHolder, "CENTER", 0, 0)
		MMBBar:SetScript("OnEnter", MMB_OnEnter)
		MMBBar:SetScript("OnLeave", MMB_OnLeave)
		SV:NewAnchor(MMBHolder, L["Minimap Button Bar"])
		self:UpdateMinimapButtonSettings()
	end

	self:RefreshMiniMap()

	self:RegisterEvent('ADDON_LOADED')
	self:RegisterEvent('PLAYER_REGEN_ENABLED')
	self:RegisterEvent('PLAYER_REGEN_DISABLED')
	self:RegisterEvent("ZONE_CHANGED", "RefreshZoneText")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "RefreshZoneText")

	NewHook("Minimap_UpdateRotationSetting", RotationHook)

	SV.Events:On("CORE_INITIALIZED", MapTriggerFired);
end
