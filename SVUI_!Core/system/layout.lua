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
local ipairs    = _G.ipairs;
local type      = _G.type;
local error     = _G.error;
local pcall     = _G.pcall;
local tostring  = _G.tostring;
local tonumber  = _G.tonumber;
local string 	= _G.string;
local math 		= _G.math;
--[[ STRING METHODS ]]--
local format, split, upper, lower = string.format, string.split, string.upper, string.lower;
--[[ MATH METHODS ]]--
local min, floor, ceil = math.min, math.floor, math.ceil;
local parsefloat = math.parsefloat;
--BLIZZARD API
local CreateFrame           = _G.CreateFrame;
local InCombatLockdown      = _G.InCombatLockdown;
local GameTooltip           = _G.GameTooltip;
local ReloadUI              = _G.ReloadUI;
local hooksecurefunc        = _G.hooksecurefunc;
local IsAltKeyDown          = _G.IsAltKeyDown;
local IsShiftKeyDown        = _G.IsShiftKeyDown;
local IsControlKeyDown      = _G.IsControlKeyDown;
local IsModifiedClick       = _G.IsModifiedClick;
local PlaySound             = _G.PlaySound;
local PlaySoundFile         = _G.PlaySoundFile;
local PlayMusic             = _G.PlayMusic;
local StopMusic             = _G.StopMusic;
local UnitName              = _G.UnitName;
local ToggleFrame           = _G.ToggleFrame;
local ERR_NOT_IN_COMBAT     = _G.ERR_NOT_IN_COMBAT;
local RAID_CLASS_COLORS     = _G.RAID_CLASS_COLORS;
local CUSTOM_CLASS_COLORS   = _G.CUSTOM_CLASS_COLORS;
--[[
##########################################################
GET ADDON DATA
##########################################################
]]--
local SV = select(2, ...);
local L = SV.L;
local SVUILib = Librarian("Registry");

local Layout = _G["SVUI_Layout"];
Layout.Frames = {};
Layout.Sections = {
	['ALL'] = {},
	['GENERAL'] = {}
};

local CLOAKED_BG = CreateFrame('Frame', nil, UIParent)

local UIPanels = {};
UIPanels["AchievementFrame"] 				= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["AuctionFrame"] 					= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["ArchaeologyFrame"] 				= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["BattlefieldMinimap"] 				= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = true };
UIPanels["BarberShopFrame"] 				= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["BlackMarketFrame"] 				= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["CalendarFrame"] 					= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = true };
UIPanels["CharacterFrame"] 					= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["ClassTrainerFrame"] 				= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["CollectionsJournal"] 				= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["DressUpFrame"] 					= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
--UIPanels["DraenorZoneAbilityFrame"] 		= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["EncounterJournal"] 				= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["FriendsFrame"] 					= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["GMSurveyFrame"] 					= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = true };
UIPanels["GossipFrame"] 					= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["GuildFrame"] 						= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["GuildBankFrame"] 					= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["GuildRegistrarFrame"] 			= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["GarrisonLandingPage"] 			= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = true };
UIPanels["GarrisonMissionFrame"] 			= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = true };
UIPanels["GarrisonBuildingFrame"] 			= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = true };
UIPanels["GarrisonShipyardFrame"] 			= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = true };
UIPanels["GarrisonCapacitiveDisplayFrame"]  = { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["HelpFrame"] 						= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = true };
UIPanels["InterfaceOptionsFrame"] 			= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = true };
UIPanels["ItemUpgradeFrame"]				= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["KeyBindingFrame"] 				= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = true };
UIPanels["LFGDungeonReadyPopup"] 			= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = true };
UIPanels["MacOptionsFrame"] 				= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = true };
UIPanels["MacroFrame"] 						= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["MailFrame"] 						= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["MerchantFrame"] 					= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["ObjectiveTrackerFrame"] 			= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["PlayerTalentFrame"] 				= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["PetJournalParent"] 				= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["PetStableFrame"] 					= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["PVEFrame"] 						= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["PVPFrame"] 						= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["QuestFrame"] 						= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["QuestLogFrame"] 					= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["RaidBrowserFrame"] 				= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["ReadyCheckFrame"] 				= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = true };
UIPanels["ReforgingFrame"] 					= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["ReportCheatingDialog"] 			= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["ReportPlayerNameDialog"] 			= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["RolePollPopup"] 					= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = true };
UIPanels["SpellBookFrame"] 					= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["TabardFrame"] 					= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["TaxiFrame"] 						= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["TimeManagerFrame"] 				= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["TradeSkillFrame"] 				= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["TradeFrame"] 						= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["TransmogrifyFrame"] 				= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["TutorialFrame"] 					= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = true };
UIPanels["VideoOptionsFrame"] 				= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = true };
UIPanels["VoidStorageFrame"] 				= { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
UIPanels["ScrollOfResurrectionSelectionFrame"] = { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };

local Sticky = {};
Sticky.Frames = {};
Sticky.Frames[1] = SV.Screen;
Sticky.scripts = Sticky.scripts or {}
Sticky.rangeX = 15
Sticky.rangeY = 15
Sticky.StuckTo = Sticky.StuckTo or {}

local function SnapStickyFrame(frameA, frameB, left, top, right, bottom)
	local sA, sB = frameA:GetEffectiveScale(), frameB:GetEffectiveScale()
	local xA, yA = frameA:GetCenter()
	local xB, yB = frameB:GetCenter()
	local hA, hB = frameA:GetHeight()  /  2, ((frameB:GetHeight()  *  sB)  /  sA)  /  2
	local wA, wB = frameA:GetWidth()  /  2, ((frameB:GetWidth()  *  sB)  /  sA)  /  2
	local newX, newY = xA, yA
	if not left then left = 0 end
	if not top then top = 0 end
	if not right then right = 0 end
	if not bottom then bottom = 0 end
	if not xB or not yB or not sB or not sA or not sB then return end
	xB, yB = (xB * sB)  /  sA, (yB * sB)  /  sA
	local stickyAx, stickyAy = wA  *  0.75, hA  *  0.75
	local stickyBx, stickyBy = wB  *  0.75, hB  *  0.75
	local lA, tA, rA, bA = frameA:GetLeft(), frameA:GetTop(), frameA:GetRight(), frameA:GetBottom()
	local lB, tB, rB, bB = frameB:GetLeft(), frameB:GetTop(), frameB:GetRight(), frameB:GetBottom()
	local snap = nil
	lB, tB, rB, bB = (lB  *  sB)  /  sA, (tB  *  sB)  /  sA, (rB  *  sB)  /  sA, (bB  *  sB)  /  sA
	if (bA  <= tB and bB  <= tA) then
		if xA  <= (xB  +  Sticky.rangeX) and xA  >= (xB - Sticky.rangeX) then
			newX = xB
			snap = true
		end
		if lA  <= (lB  +  Sticky.rangeX) and lA  >= (lB - Sticky.rangeX) then
			newX = lB  +  wA
			if frameB == UIParent or frameB == WorldFrame or frameB == SVUIParent then
				newX = newX  +  4
			end
			snap = true
		end
		if rA  <= (rB  +  Sticky.rangeX) and rA  >= (rB - Sticky.rangeX) then
			newX = rB - wA
			if frameB == UIParent or frameB == WorldFrame or frameB == SVUIParent then
				newX = newX - 4
			end
			snap = true
		end
		if lA  <= (rB  +  Sticky.rangeX) and lA  >= (rB - Sticky.rangeX) then
			newX = rB  +  (wA - left)
			snap = true
		end
		if rA  <= (lB  +  Sticky.rangeX) and rA  >= (lB - Sticky.rangeX) then
			newX = lB - (wA - right)
			snap = true
		end
	end
	if (lA  <= rB and lB  <= rA) then
		if yA  <= (yB  +  Sticky.rangeY) and yA  >= (yB - Sticky.rangeY) then
			newY = yB
			snap = true
		end
		if tA  <= (tB  +  Sticky.rangeY) and tA  >= (tB - Sticky.rangeY) then
			newY = tB - hA
			if frameB == UIParent or frameB == WorldFrame or frameB == SVUIParent then
				newY = newY - 4
			end
			snap = true
		end
		if bA  <= (bB  +  Sticky.rangeY) and bA  >= (bB - Sticky.rangeY) then
			newY = bB  +  hA
			if frameB == UIParent or frameB == WorldFrame or frameB == SVUIParent then
				newY = newY  +  4
			end
			snap = true
		end
		if tA  <= (bB  +  Sticky.rangeY  +  bottom) and tA  >= (bB - Sticky.rangeY  +  bottom) then
			newY = bB - (hA - top)
			snap = true
		end
		if bA  <= (tB  +  Sticky.rangeY - top) and bA  >= (tB - Sticky.rangeY - top) then
			newY = tB  +  (hA - bottom)
			snap = true
		end
	end
	if snap then
		frameA:ClearAllPoints()
		frameA:SetPoint("CENTER", UIParent, "BOTTOMLEFT", newX, newY)
		return true
	end
end

local function GetStickyUpdate(frame, xoffset, yoffset, left, top, right, bottom)
	return function()
		local x, y = GetCursorPosition()
		local s = frame:GetEffectiveScale()
		x, y = x / s, y / s
		frame:ClearAllPoints()
		frame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x + xoffset, y + yoffset)
		Sticky.StuckTo[frame] = nil
		for i = 1, #Sticky.Frames do
			local v = Sticky.Frames[i]
			if(frame ~= v and frame ~= v:GetParent() and IsShiftKeyDown() and v:IsVisible()) then
				if SnapStickyFrame(frame, v, left, top, right, bottom) then
					Sticky.StuckTo[frame] = v
					break
				end
			end
		end
	end
end

local function StickyStartMoving(frame, left, top, right, bottom)
	local x, y = GetCursorPosition()
	local aX, aY = frame:GetCenter()
	local aS = frame:GetEffectiveScale()
	aX, aY = aX * aS, aY * aS
	local xoffset, yoffset = (aX - x), (aY - y)
	Sticky.scripts[frame] = frame:GetScript("OnUpdate")
	frame:SetScript("OnUpdate", GetStickyUpdate(frame, xoffset, yoffset, left, top, right, bottom))
end

local function StickyStopMoving(frame)
	frame:SetScript("OnUpdate", Sticky.scripts[frame])
	Sticky.scripts[frame] = nil
	if Sticky.StuckTo[frame] then
		local frame2 = Sticky.StuckTo[frame]
		Sticky.StuckTo[frame] = nil
		return true, frame2
	else
		return false, nil
	end
end
local CurrentFrameTarget, UpdateFrameTarget;
--[[
##########################################################
LOCAL FUNCTIONS
##########################################################
]]--
local function Pinpoint(parent)
    local centerX, centerY = parent:GetCenter()
    local screenWidth = GetScreenWidth()
    local screenHeight = GetScreenHeight()
    local result;
    if not centerX or not centerY then
        return "CENTER"
    end
    local heightTop = screenHeight  *  0.75;
    local heightBottom = screenHeight  *  0.25;
    local widthLeft = screenWidth  *  0.25;
    local widthRight = screenWidth  *  0.75;
    if(((centerX > widthLeft) and (centerX < widthRight)) and (centerY > heightTop)) then
        result = "TOP"
    elseif((centerX < widthLeft) and (centerY > heightTop)) then
        result = "TOPLEFT"
    elseif((centerX > widthRight) and (centerY > heightTop)) then
        result = "TOPRIGHT"
    elseif(((centerX > widthLeft) and (centerX < widthRight)) and centerY < heightBottom) then
        result = "BOTTOM"
    elseif((centerX < widthLeft) and (centerY < heightBottom)) then
        result = "BOTTOMLEFT"
    elseif((centerX > widthRight) and (centerY < heightBottom)) then
        result = "BOTTOMRIGHT"
    elseif((centerX < widthLeft) and (centerY > heightBottom) and (centerY < heightTop)) then
        result = "LEFT"
    elseif((centerX > widthRight) and (centerY < heightTop) and (centerY > heightBottom)) then
        result = "RIGHT"
    else
        result = "CENTER"
    end
    return result
end

local function CurrentPosition(frame)
	if not frame then return end
	local parentName
	local anchor1, parent, anchor2, x, y = frame:GetPoint()
	if((not anchor1) or (not anchor2) or (not x) or (not y)) then
		anchor1, anchor2, x, y = "TOPLEFT", "TOPLEFT", 160, -80
	end
	if(not parent or (parent and (not parent:GetName()))) then
		parentName = "UIParent"
	else
		parentName = parent:GetName()
	end
	local width, height = frame:GetSize()
	if((not width) or (not height)) then
		width, height = 0, 0
	end
	return ("%s|%s|%s|%d|%d|%d|%d"):format(anchor1, parentName, anchor2, parsefloat(x), parsefloat(y), parsefloat(width), parsefloat(height))
end

local function SaveAnchor(frameName)
	if((not _G[frameName]) or (not Layout.Anchors)) then return end
	Layout.Anchors[frameName] = CurrentPosition(_G[frameName])
end

local function LayoutParser(str, frameName)
	if not str then return end
	if(str:find("\031")) then
		if(frameName and _G[frameName] and Layout.Anchors[frameName]) then
			str = str:gsub("\031", "|")
			Layout.Anchors[frameName] = str
		else
			return split("\031", str)
		end
	end

	return split("|", str)
end

local function GrabUsableRegions(frame)
	local parent = frame or SV.Screen
	local right = parent:GetRight()
	local top = parent:GetTop()
	local center = parent:GetCenter()
	return right, top, center
end

local function CalculateOffsets(frame)
	if(not CurrentFrameTarget) then return end
	local right, top, center = GrabUsableRegions()
	local xOffset, yOffset = CurrentFrameTarget:GetCenter()
	local screenLeft = (right * 0.33);
	local screenRight = (right * 0.66);
	local topMedian = (top * 0.5);
	local anchor, a1, a2;

	xOffset = xOffset or 0
	yOffset = yOffset or 0

	if(yOffset >= (top * 0.5)) then
		a1 = "TOP"
		yOffset = -(top - CurrentFrameTarget:GetTop())
	else
		a1 = "BOTTOM"
		yOffset = CurrentFrameTarget:GetBottom()
	end

	if xOffset >= screenRight then
		a2 = "RIGHT"
		xOffset = (CurrentFrameTarget:GetRight() - right)
	elseif xOffset <= screenLeft then
		a2 = "LEFT"
		xOffset = CurrentFrameTarget:GetLeft()
	else
		a2 = ""
		xOffset = (xOffset - center)
	end

	xOffset = parsefloat(xOffset, 0)
	yOffset = parsefloat(yOffset, 0)
	anchor = ("%s%s"):format(a1,a2)

	return xOffset, yOffset, anchor
end

local function ResetAllAlphas()
	for entry,_ in pairs(Layout.Frames) do
		local frame = _G[entry]
		if(frame) then
			frame:SetAlpha(0.4)
		end
	end
end
--[[
##########################################################
MOVING ANIMATION WIDGET
##########################################################
]]--
local TheHand = CreateFrame("Frame", nil, UIParent)
TheHand:SetFrameStrata("DIALOG")
TheHand:SetFrameLevel(99)
TheHand:SetClampedToScreen(true)
TheHand:SetSize(128,128)
TheHand:SetPoint("CENTER")
TheHand.bg = TheHand:CreateTexture(nil, "OVERLAY")
TheHand.bg:SetAllPoints(TheHand)
TheHand.bg:SetTexture([[Interface\AddOns\SVUI_!Core\assets\textures\Doodads\MENTALO-HAND-OFF]])
TheHand.energy = TheHand:CreateTexture(nil, "OVERLAY")
TheHand.energy:SetAllPoints(TheHand)
TheHand.energy:SetTexture([[Interface\AddOns\SVUI_!Core\assets\textures\Doodads\MENTALO-ENERGY]])
SV.Animate:Orbit(TheHand.energy, 10)
TheHand.flash = TheHand.energy.anim;
TheHand.energy:Hide()
TheHand.elapsedTime = 0;
TheHand.flash:Stop()
TheHand:Hide()
TheHand.UserHeld = false;

local TheHand_OnUpdate = function(self, elapsed)
	self.elapsedTime = self.elapsedTime  +  elapsed
	if self.elapsedTime > 0.1 then
		self.elapsedTime = 0
		local x, y = GetCursorPosition()
		local scale = SV.Screen:GetEffectiveScale()
		self:SetPoint("CENTER", SV.Screen, "BOTTOMLEFT", (x  /  scale)  +  50, (y  /  scale)  +  50)
	end
end

function TheHand:Enable()
	self:Show()
	self.bg:SetTexture([[Interface\AddOns\SVUI_!Core\assets\textures\Doodads\MENTALO-HAND-ON]])
	self.energy:Show()
	self.flash:Play()
	self:SetScript("OnUpdate", TheHand_OnUpdate)
end

function TheHand:Disable()
	self.flash:Stop()
	self.energy:Hide()
	self.bg:SetTexture([[Interface\AddOns\SVUI_!Core\assets\textures\Doodads\MENTALO-HAND-OFF]])
	self:SetScript("OnUpdate", nil)
	self.elapsedTime = 0
	self:Hide()
end
--[[
##########################################################
HANDLERS
##########################################################
]]--
local LayoutUpdateHandler = CreateFrame("Frame", nil)

local function SetPrecisionSizes()
	if(not CurrentFrameTarget) then return end
	if(not CurrentFrameTarget.postsize) then
		SVUI_LayoutPrecision:SetHeight(70)
		SVUI_LayoutPrecisionWidthAdjust:Hide()
		SVUI_LayoutPrecisionHeightAdjust:Hide()
	else
		local x,y = SVUI_LayoutPrecision:GetCenter()
		SVUI_LayoutPrecision:ClearAllPoints()
		SVUI_LayoutPrecision:SetPoint("BOTTOMLEFT", SVUIParent, "BOTTOMLEFT", x,y)

		SVUI_LayoutPrecision:SetHeight(144)
		local minRange = CurrentFrameTarget.minRange or 0;
		local maxRange = CurrentFrameTarget.maxRange or 500;
		local min2Range = CurrentFrameTarget.min2Range or minRange;
		local max2Range = CurrentFrameTarget.max2Range or maxRange;

		local curWidth = floor(CurrentFrameTarget:GetWidth())
		local curHeight = floor(CurrentFrameTarget:GetHeight())

		SVUI_LayoutPrecisionWidthAdjust.rangeLow:SetText(minRange);
		SVUI_LayoutPrecisionWidthAdjust.rangeHigh:SetText(maxRange);
		SVUI_LayoutPrecisionWidthAdjust:SetMinMaxValues(minRange, maxRange);
		SVUI_LayoutPrecisionWidthAdjust:SetValue(curWidth);
		SVUI_LayoutPrecisionWidthAdjust.rangeValue:SetText(curWidth);
		SVUI_LayoutPrecisionWidthAdjust:Show()
		SVUI_LayoutPrecisionHeightAdjust.rangeLow:SetText(min2Range);
		SVUI_LayoutPrecisionHeightAdjust.rangeHigh:SetText(max2Range);
		SVUI_LayoutPrecisionHeightAdjust:SetMinMaxValues(minRange, maxRange);
		SVUI_LayoutPrecisionHeightAdjust:SetValue(curHeight);
		SVUI_LayoutPrecisionHeightAdjust.rangeValue:SetText(curHeight);
		SVUI_LayoutPrecisionHeightAdjust:Show()
	end
end

function Layout:Movable_OnMouseUp()
	if(not SVUI_LayoutPrecision) then return end;
	CurrentFrameTarget = self;
	local xOffset, yOffset, anchor = CalculateOffsets()

	SVUI_LayoutPrecisionSetX.CurrentValue = xOffset;
	SVUI_LayoutPrecisionSetX:SetText(xOffset)

	SVUI_LayoutPrecisionSetY.CurrentValue = yOffset;
	SVUI_LayoutPrecisionSetY:SetText(yOffset)

	SVUI_LayoutPrecision.Title:SetText(self.textString)
end

function Layout:Movable_OnUpdate()
	local frame = UpdateFrameTarget;
	if not frame then return end
	local rightPos, topPos, centerPos = GrabUsableRegions()
	local centerX, centerY = frame:GetCenter()
	local calc1 = rightPos * 0.33;
	local calc2 = rightPos * 0.66;
	local calc3 = topPos * 0.5;
	local anchor1, anchor2;
	local xOffset,yOffset = 0,0;
	if centerY >= calc3 then
		anchor1 = "TOP"
		anchor2 = "BOTTOM"
		yOffset = -25
	else
		anchor1 = "BOTTOM"
		anchor2 = "TOP"
		yOffset = 25
	end
	if centerX >= calc2 then
		anchor1 = "RIGHT"
		anchor2 = "LEFT"
		xOffset = -25
	elseif centerX <= calc1 then
		anchor1 = "LEFT"
		anchor2 = "RIGHT"
		xOffset = 25
	end
	if(not SVUI_LayoutPrecision) then return end;
	if CurrentFrameTarget ~= frame then
		SVUI_LayoutPrecision:Hide()
		frame:GetScript("OnMouseUp")(frame)
	else
		SVUI_LayoutPrecision:ClearAllPoints()
		SVUI_LayoutPrecision:SetPoint(anchor1, frame, anchor2, xOffset, yOffset)
		SetPrecisionSizes()
	end
	Layout.Movable_OnMouseUp(frame)
end

function Layout:Movable_OnSizeChanged()
	if InCombatLockdown()then return end
	if self.dirtyWidth and self.dirtyHeight then
		self.Grip:SetSize(self.dirtyWidth, self.dirtyHeight)
	else
		self.Grip:SetSize(self:GetSize())
	end
end

function Layout:Movable_OnDragStart()
	if InCombatLockdown() then SV:AddonMessage(ERR_NOT_IN_COMBAT)return end
	if SV.db.general.stickyFrames then
		StickyStartMoving(self, self.snapOffset, -2)
	else
		self:StartMoving()
	end
	UpdateFrameTarget = self;
	LayoutUpdateHandler:Show()
	LayoutUpdateHandler:SetScript("OnUpdate", Layout.Movable_OnUpdate)
	TheHand:Enable()
	TheHand.UserHeld = true
end

function Layout:Movable_OnDragStop()
	if InCombatLockdown()then SV:AddonMessage(ERR_NOT_IN_COMBAT)return end
	if SV.db.general.stickyFrames then
		StickyStopMoving(self)
	else
		self:StopMovingOrSizing()
	end
	local pR, pT, pC = GrabUsableRegions()
	local cX, cY = self:GetCenter()
	local newAnchor;
	if cY >= (pT * 0.5) then
		newAnchor = "TOP";
		cY = (-(pT - self:GetTop()))
	else
		newAnchor = "BOTTOM"
		cY = self:GetBottom()
	end
	if cX >= (pR * 0.66) then
		newAnchor = newAnchor.."RIGHT"
		cX = self:GetRight() - pR
	elseif cX <= (pR * 0.33) then
		newAnchor = newAnchor.."LEFT"
		cX = self:GetLeft()
	else
		cX = cX - pC
	end
	if self.positionOverride then
		self.parent:ClearAllPoints()
		self.parent:SetPoint(self.positionOverride, self, self.positionOverride)
	end

	self:ClearAllPoints()
	self:SetPoint(newAnchor, SV.Screen, newAnchor, cX, cY)

	SaveAnchor(self.name)

	if SVUI_LayoutPrecision then
		Layout.Movable_OnMouseUp(self)
	end

	UpdateFrameTarget = nil;

	LayoutUpdateHandler:SetScript("OnUpdate", nil)
	LayoutUpdateHandler:Hide()

	if(self.postdrag ~= nil and type(self.postdrag) == "function") then
		self:postdrag(Pinpoint(self))
	end
	self:SetUserPlaced(false)
	TheHand.UserHeld = false;
	TheHand:Disable()
end

function Layout:Movable_OnShow()
	self:SetBackdropBorderColor(0, 0.25, 1, 0.5)
end

function Layout:Movable_OnEnter()
	if TheHand.UserHeld then return end
	ResetAllAlphas()
	self:SetAlpha(1)
	if(CurrentFrameTarget ~= self) then
		self.text:SetTextColor(0, 1, 1)
		self:SetBackdropBorderColor(0, 0.7, 1, 1)
	end
	UpdateFrameTarget = self;
	Layout.Portrait:SetTexture([[Interface\AddOns\SVUI_!Core\assets\textures\Doodads\MENTALO-ON]])
	TheHand:SetPoint("CENTER", self, "TOP", 0, 0)
	TheHand:Show()
end

function Layout:Movable_OnLeave()
	if TheHand.UserHeld then return end
	if(CurrentFrameTarget ~= self) then
		self.text:SetTextColor(1, 1, 1)
		self:SetBackdropBorderColor(0, 0.25, 1, 0.5)
	end
	Layout.Portrait:SetTexture([[Interface\AddOns\SVUI_!Core\assets\textures\Doodads\MENTALO-OFF]])
	TheHand:Hide()
	if(not SVUI_LayoutPrecision) then return end;
	if(CurrentFrameTarget ~= self and not SVUI_LayoutPrecision:IsShown()) then
		self:SetAlpha(0.4)
	end
end

function Layout:Movable_OnMouseDown(button)
	if button == "RightButton" then
		TheHand.UserHeld = false;
		if(SV.db.general.stickyFrames) then
			StickyStopMoving(self)
		else
			self:StopMovingOrSizing()
		end
		if(not SVUI_LayoutPrecision) then return end;
		CurrentFrameTarget = self
		self.text:SetTextColor(0.2, 1, 0)
		self:SetBackdropBorderColor(0, 1, 0, 1)
		Layout:Movable_OnUpdate()
		SVUI_LayoutPrecision:Show()
	end
end

function Layout:Movable_HasMoved()
	if(Layout.Anchors and Layout.Anchors[self.name]) then
		return true
	else
		return false
	end
end
--[[
##########################################################
CONSTRUCTS
##########################################################
]]--
local function SetNewAnchor(frame, moveName, title, postDragFunc)
	if((not frame) or (not moveName) or (Layout.Frames[moveName] ~= nil)) then return end

	Layout.Frames[moveName] = {
		text = title,
		postdrag = postDragFunc,
		layoutString = CurrentPosition(frame),
	}
	Layout.Sections.ALL[moveName] = true;
	local currentCategory = SVUILib.CURRENT_SCHEMA;
	if(currentCategory) then
		currentCategory = upper(currentCategory)
		if(not Layout.Sections[currentCategory]) then
			Layout.Sections[currentCategory] = {}
		end
		Layout.Sections[currentCategory][moveName] = true;
	end

	local grip = CreateFrame("Button", moveName, SV.Screen)
	grip:SetFrameLevel(frame:GetFrameLevel() + 1)
	grip:SetClampedToScreen(true)
	grip:SetFrameStrata("DIALOG")

	grip.parent = frame;
	grip.name = moveName;
	grip.textString = title;
	grip.postdrag = postDragFunc;
	grip.HasMoved = Layout.Movable_HasMoved
	grip.snapOffset = frame.snapOffset or -2;

	local anchor1, anchorParent, anchor2, xPos, yPos
	if(Layout.Anchors and Layout.Anchors[moveName] and (type(Layout.Anchors[moveName]) == "string")) then
		anchor1, anchorParent, anchor2, xPos, yPos = LayoutParser(Layout.Anchors[moveName])
	else
		anchor1, anchorParent, anchor2, xPos, yPos = LayoutParser(CurrentPosition(frame))
	end

	local width, height = frame:GetSize()
	grip:SetPoint(anchor1, anchorParent, anchor2, xPos, yPos)
	grip:SetSize(width, height)
	grip:SetStyle("!_Frame", "Transparent")
	grip:SetAlpha(0.4)

	frame:SetScript("OnSizeChanged", Layout.Movable_OnSizeChanged)
	frame.Grip = grip;
	frame:ClearAllPoints()
	frame:SetPoint(anchor1, grip, anchor1, 0, 0)

	local mtext = grip:CreateFontString(nil, "OVERLAY")
	mtext:SetFontObject(SVUI_Font_Default)
	mtext:SetJustifyH("CENTER")
	mtext:SetPoint("CENTER")
	mtext:SetText(title or moveName)
	mtext:SetTextColor(1, 1, 1)

	grip:SetFontString(mtext)
	grip.text = mtext;

	grip:RegisterForDrag("LeftButton", "RightButton")

	grip:SetScript("OnMouseUp", Layout.Movable_OnMouseUp)
	grip:SetScript("OnDragStart", Layout.Movable_OnDragStart)
	grip:SetScript("OnDragStop", Layout.Movable_OnDragStop)
	grip:SetScript("OnShow", Layout.Movable_OnShow)
	grip:SetScript("OnEnter", Layout.Movable_OnEnter)
	grip:SetScript("OnMouseDown", Layout.Movable_OnMouseDown)
	grip:SetScript("OnLeave", Layout.Movable_OnLeave)

	grip:SetMovable(true)
	grip:Hide()

	Sticky.Frames[#Sticky.Frames + 1] = grip;
end

function Layout:Reset(request, bypass)
	if(request == "" or request == nil) then
		for frameName, frameData in pairs(self.Frames) do
			local frame = _G[frameName];
			if(frameData.layoutString) then
				local anchor1, anchorParent, anchor2, xPos, yPos, width, height = LayoutParser(frameData.layoutString)
				frame:ClearAllPoints()
				frame:SetPoint(anchor1, anchorParent, anchor2, xPos, yPos)
				if(not bypass) then
					if(frameData.postdrag and (type(frameData.postdrag) == "function")) then
						frameData.postdrag(frame, Pinpoint(frame))
					end
				end
			end
			if(self.Anchors and self.Anchors[frameName]) then
				self.Anchors[frameName] = nil
			end
		end
	else
		for frameName, frameData in pairs(self.Frames) do
			if(frameData.layoutString and (request == frameName or request == frameData.text)) then
				local frame = _G[frameName]
				local anchor1, anchorParent, anchor2, xPos, yPos, width, height = LayoutParser(frameData.layoutString)
				frame:ClearAllPoints()
				frame:SetPoint(anchor1, anchorParent, anchor2, xPos, yPos)
				if(not bypass) then
					if(frameData.postdrag and (type(frameData.postdrag) == "function")) then
						frameData.postdrag(frame, Pinpoint(frame))
					end
				end
				if(self.Anchors and self.Anchors[frameName]) then
					self.Anchors[frameName] = nil
				end
				break
			end
		end
	end
end

function Layout:Update()
	self.Anchors = SV.db.LAYOUT or {}
	for frameName, frameData in pairs(self.Frames) do
		--print('Layout:Update(' .. frameName .. ')')
		local frame = _G[frameName];
		local anchor1, parent, anchor2, x, y, width, height;
		if frame then
			if (self.Anchors and self.Anchors[frameName] and (type(self.Anchors[frameName]) == "string")) then
				anchor1, parent, anchor2, x, y, width, height = LayoutParser(self.Anchors[frameName], frameName)
				frame:ClearAllPoints()
				frame:SetPoint(anchor1, parent, anchor2, x, y)
			elseif(frameData.layoutString) then
				anchor1, parent, anchor2, x, y, width, height = LayoutParser(frameData.layoutString, frameName)
				frame:ClearAllPoints()
				frame:SetPoint(anchor1, parent, anchor2, x, y)
			end
		end
	end
end

function Layout:Toggle(arg)
	if(InCombatLockdown()) then return end
	local enabled = false;
	local aceConfig = LibStub("AceConfigDialog-3.0")
	if(aceConfig and SV.OptionsLoaded) then
		aceConfig:Close(SV.NameID)
		GameTooltip:Hide()
	end
	SVUI_LayoutPrecision:Hide()
	for frameName, _ in pairs(self.Frames) do
		local frame = _G[frameName];
		if(frame) then frame:Hide() end
	end
	if(self:IsShown()) then
		SV:AddonMessage('Frames are now locked!')
		self:Hide()
	else
		--print(arg)
		arg = arg or 'ALL';
		local category = upper(arg);
		if(category == 'HELP') then
			SV:AddonMessage('You can use the following commands to specify which frame-groups you want to move at a time.')
			for section,_ in pairs(self.Sections) do
		        print('/sv move |cff00FF00' .. lower(section) .. '|r')
			end
		else
			SV:AddonMessage('Frames are now unlocked!')
			SV:AddonMessage('To see move commands type |cff00FF00/sv move help|r.')
			local list = self.Sections[category]
			for frameName, _ in pairs(list) do
				local frame = _G[frameName];
				if(frame) then frame:Show() end
			end
			self:Show()
		end
	end
	-- for section, _ in pairs(self.Sections) do
	-- 	print(section)
	-- end
end
--[[
##########################################################
ALIGNMENT GRAPH
##########################################################
]]--
local Graph = {}

function Graph:Toggle(enabled)
	if((not self.Grid) or (self.CellSize ~= SV.db.general.graphSize)) then
		self:UpdateAllReports()
	end
	if(not enabled) then
    self.Grid:Hide()
	else
		self.Grid:Show()
	end
end

function Graph:UpdateAllReports()
	-- for the record, this SUCKED trying to optimize the math
	local cellSize = SV.db.general.graphSize
	self.CellSize = cellSize

	self.Grid = CreateFrame('Frame', nil, UIParent)
	self.Grid:SetAllPoints(SV.Screen)
	self.Grid:SetFrameStrata('BACKGROUND')
	self.Grid:SetFrameLevel(1)

	local width = SV.Screen:GetWidth();
	local height = SV.Screen:GetHeight();
	local ratio = width / height;
	local size = height * ratio;
	local interval = size / cellSize;
	local halfWidth = ceil(cellSize * 0.5);
	local halfHeight = floor((height / interval) * 0.5);
	--print('-------')print(width)print(height)
	--print('-------')print(cellSize)
	--print('-------')print(size)print(interval)
	--print('-------')print(halfWidth)print(halfHeight)

	for i = 0, cellSize do
		local mod = i*interval;

		local xGrid = self.Grid:CreateTexture(nil, 'BACKGROUND')
		local yGrid = self.Grid:CreateTexture(nil, 'BACKGROUND')
		if(i == halfWidth) then
			xGrid:SetColorTexture(0, 1, 0, 0.8)
		else
			xGrid:SetColorTexture(0.1, 0.1, 0.1, 0.8)
		end
		if(i == halfHeight) then
			yGrid:SetColorTexture(0, 1, 0, 0.8)
		else
			yGrid:SetColorTexture(0.1, 0.1, 0.1, 0.8)
		end

		xGrid:SetPoint("TOPLEFT", self.Grid, "TOPLEFT", (mod - 0.5), 0)
		xGrid:SetPoint('BOTTOMRIGHT', self.Grid, 'BOTTOMLEFT', (mod + 0.5), 0)
		yGrid:SetPoint("TOPLEFT", self.Grid, "TOPLEFT", 0, -mod + 0.5)
		yGrid:SetPoint('BOTTOMRIGHT', self.Grid, 'TOPRIGHT', 0, -(mod + 0.5))
	end

	self.Grid:Hide()
end

function Graph:Initialize()
	self:UpdateAllReports()
end
--[[
##########################################################
SCRIPT AND EVENT HANDLERS
##########################################################
]]--
local XML_Layout_OnEvent = function(self)
	if self:IsShown() then
		self:Hide()
		Layout:Toggle()
	end
end

local XML_LayoutGridButton_OnClick = function(self)
	local enabled = true
	if(Graph.Grid and Graph.Grid:IsShown()) then
		enabled = false
	end

	Graph:Toggle(enabled)
end

local XML_LayoutLockButton_OnClick = function(self)
	Graph:Toggle()
	Layout:Toggle()
	if(SV.OptionsLoaded and SV.OptionsStandby) then
		SV.OptionsStandby = nil
		LibStub("AceConfigDialog-3.0"):Open(SV.NameID)
	end
end

local SVUI_LayoutPrecisionResetButton_OnClick = function(self)
	if(not CurrentFrameTarget) then return end
	local name = CurrentFrameTarget.name
	Layout:Reset(name)
end

local XML_LayoutPrecisionInputX_EnterPressed = function(self)
	local current = tonumber(self:GetText())
	if(current) then
		if(CurrentFrameTarget) then
			local xOffset, yOffset, anchor = CalculateOffsets()
			yOffset = tonumber(SVUI_LayoutPrecisionSetY.CurrentValue)
			CurrentFrameTarget:ClearAllPoints()
			CurrentFrameTarget:SetPoint(anchor, SVUIParent, anchor, current, yOffset)
			SaveAnchor(CurrentFrameTarget.name)
		end
		self.CurrentValue = current
	end
	self:SetText(floor((self.CurrentValue or 0) + 0.5))
	EditBox_ClearFocus(self)
end

local XML_LayoutPrecisionInputY_EnterPressed = function(self)
	local current = tonumber(self:GetText())
	if(current) then
		if(CurrentFrameTarget) then
			local xOffset, yOffset, anchor = CalculateOffsets()
			xOffset = tonumber(SVUI_LayoutPrecisionSetX.CurrentValue)
			CurrentFrameTarget:ClearAllPoints()
			CurrentFrameTarget:SetPoint(anchor, SVUIParent, anchor, xOffset, current)
			SaveAnchor(CurrentFrameTarget.name)
		end
		self.CurrentValue = current
	end
	self:SetText(floor((self.CurrentValue or 0) + 0.5))
	EditBox_ClearFocus(self)
end

local XML_LayoutPrecisionWidthAdjust_OnValueChanged = function(self, widthValue)
	self.rangeValue:SetText(floor(widthValue))
	if(CurrentFrameTarget and CurrentFrameTarget.postsize) then
		local frame = CurrentFrameTarget.parent;
		local heightValue = SVUI_LayoutPrecisionHeightAdjust:GetValue();
		CurrentFrameTarget.postsize(frame, widthValue, heightValue);
	end
end

local XML_LayoutPrecisionHeightAdjust_OnValueChanged = function(self, heightValue)
	self.rangeValue:SetText(floor(heightValue))
	if(CurrentFrameTarget and CurrentFrameTarget.postsize) then
		local frame = CurrentFrameTarget.parent;
		local widthValue = SVUI_LayoutPrecisionWidthAdjust:GetValue();
		CurrentFrameTarget.postsize(frame, widthValue, heightValue);
	end
end
--[[
##########################################################
DRAGGABLES
##########################################################
]]--
local Dragger = CreateFrame("Frame", nil);
Dragger.Frames = {};

local function SetDraggablePoint(frame, data)
	if((not frame) or (not data)) then return; end
	local frameName = frame:GetName()
	local point = Dragger.Frames[frameName];
	if(point and (type(point) == "string") and (point ~= 'TBD')) then
		local anchor1, parent, anchor2, x, y = LayoutParser(point);
		data.cansetpoint = true;
		data.snapped = false;
		frame:ClearAllPoints();
		frame:SetPoint(anchor1, parent, anchor2, x, y);
	end
end

local function SaveCurrentPosition(frame)
	if not frame then return end
	local result;
	local frameName = frame:GetName()
	local anchor1, parent, anchor2, x, y = frame:GetPoint()
	if((not anchor1) or (not anchor2) or (not x) or (not y)) then
		result = "TBD";
	else
		local parentName
		if(not parent or (parent and (not parent:GetName()))) then
			parentName = "UIParent"
		else
			parentName = parent:GetName()
		end
		result = ("%s|%s|%s|%d|%d"):format(anchor1, parentName, anchor2, parsefloat(x), parsefloat(y))
	end
	if(SV.db.general.saveDraggable) then
		SV.private.Draggables[frameName] = result
		Dragger.Frames = SV.private.Draggables
	else
		Dragger.Frames[frameName] = result
	end
end

local DraggerFrame_OnDragStart = function(self)
	if(not self:IsMovable()) then return; end
	self:StartMoving();
	local data = UIPanels[self:GetName()];
	if(data) then
		data.moving = true;
		data.snapped = false;
		data.canupdate = false;
	end
end

local DraggerFrame_OnDragStop = function(self)
	if(not self:IsMovable()) then return; end
	self:StopMovingOrSizing();
	local data = UIPanels[self:GetName()];
	if(data) then
		data.moving = false;
		data.snapped = false;
		data.canupdate = true;
		SaveCurrentPosition(self);
	end
end

local _hook_DraggerFrame_OnShow = function(self)
	if(InCombatLockdown() or (not self:IsMovable())) then return; end
	local data = UIPanels[self:GetName()];
	if(data and (not data.snapped)) then
		SetDraggablePoint(self, data)
	end
end

local _hook_DraggerFrame_OnHide = function(self)
	if(InCombatLockdown() or (not self:IsMovable())) then return; end
	local data = UIPanels[self:GetName()];
	if(data) then
		data.moving = false;
		data.snapped = false;
		data.canupdate = true;
	end
end

local _hook_DraggerFrame_OnUpdate = function(self)
	if(InCombatLockdown()) then return; end
	local data = UIPanels[self:GetName()];
	if(data and (not data.moving) and (not data.snapped)) then
		SetDraggablePoint(self, data)
	end
end

local _hook_DraggerFrame_OnSetPoint = function(self)
	if(not self:IsMovable()) then return; end
	local data = UIPanels[self:GetName()];
	if(data and (not data.moving)) then
		if(not data.cansetpoint) then
			data.snapped = true;
			data.canupdate = false;
		end
	end
end

local _hook_UIParent_ManageFramePositions = function()
	for frameName, point in pairs(Dragger.Frames) do
		local data = UIPanels[frameName]
		if(data and (not data.snapped)) then
			SetDraggablePoint(_G[frameName], data)
		end
	end
end

local DraggerEventHandler = function(self, event, ...)
	if(InCombatLockdown()) then return end

	local noMoreChanges = true;
	local allCentered = SV.db.screen.multiMonitor

	for frameName, data in pairs(UIPanels) do
		if(not self.Frames[frameName] or (self.Frames[frameName] and type(self.Frames[frameName]) ~= 'string')) then
			self.Frames[frameName] = 'TBD'
			noMoreChanges = false;
		end
		if(not data.initialized) then
			local frame = _G[frameName]
			if(frame) then
				frame:EnableMouse(true)

				if(frameName == "LFGDungeonReadyPopup") then
					LFGDungeonReadyDialog:EnableMouse(false)
				end

				frame:SetMovable(true)
				frame:RegisterForDrag("LeftButton")
				frame:SetClampedToScreen(true)

				if(allCentered) then
					frame:ClearAllPoints()
					frame:SetPoint('TOP', SV.Screen, 'TOP', 0, -180)
					data.centered = true
				end

				if(self.Frames[frameName] == 'TBD') then
					SaveCurrentPosition(frame);
				end

				data.canupdate = true

				frame:SetScript("OnDragStart", DraggerFrame_OnDragStart)
				frame:SetScript("OnDragStop", DraggerFrame_OnDragStop)

				frame:HookScript("OnUpdate", _hook_DraggerFrame_OnUpdate)
				hooksecurefunc(frame, "SetPoint", _hook_DraggerFrame_OnSetPoint)

				if(SV.db.general.saveDraggable) then
					frame:HookScript("OnShow", _hook_DraggerFrame_OnShow)
					frame:HookScript("OnHide", _hook_DraggerFrame_OnHide)
				end

				data.initialized = true
			end
			noMoreChanges = false;
		end
	end

	if(noMoreChanges) then
		self.EventsActive = false;
		self:UnregisterEvent("ADDON_LOADED")
		self:UnregisterEvent("LFG_UPDATE")
		self:UnregisterEvent("ROLE_POLL_BEGIN")
		self:UnregisterEvent("READY_CHECK")
		self:UnregisterEvent("UPDATE_WORLD_STATES")
		self:UnregisterEvent("WORLD_STATE_TIMER_START")
		self:UnregisterEvent("WORLD_STATE_UI_TIMER_UPDATE")
		self:SetScript("OnEvent", nil)
	end
end

--[[METHODS]]--

function Dragger:New(frameName)
	if(not UIPanels[frameName]) then
		UIPanels[frameName] = { moving = false, snapped = false, canupdate = false, cansetpoint = false, centered = false };
		if(not self.EventsActive) then
			self:RegisterEvent("ADDON_LOADED")
			self:RegisterEvent("LFG_UPDATE")
			self:RegisterEvent("ROLE_POLL_BEGIN")
			self:RegisterEvent("READY_CHECK")
			self:RegisterEvent("UPDATE_WORLD_STATES")
			self:RegisterEvent("WORLD_STATE_TIMER_START")
			self:RegisterEvent("WORLD_STATE_UI_TIMER_UPDATE")
			self:SetScript("OnEvent", DraggerEventHandler)
			self.EventsActive = true;
		end
	end
end

function Dragger:SetPositions()
	for frameName, point in pairs(Dragger.Frames) do
		local data = UIPanels[frameName]
		if(data and (not data.snapped)) then
			SetDraggablePoint(_G[frameName], point, data)
		end
	end
end

function Dragger:Reset()
	if(SV.db.general.saveDraggable) then
		for frameName, data in pairs(UIPanels) do
			if(SV.private.Draggables[frameName]) then
				SV.private.Draggables[frameName] = nil
			end
			data.initialized = nil
		end
		self.Frames = SV.private.Draggables
	else
		for frameName, data in pairs(UIPanels) do
			if(self.Frames[frameName]) then
				self.Frames[frameName] = nil
			end
			data.initialized = nil
		end
	end

	if(not self.EventsActive) then
		self:RegisterEvent("ADDON_LOADED")
		self:RegisterEvent("LFG_UPDATE")
		self:RegisterEvent("ROLE_POLL_BEGIN")
		self:RegisterEvent("READY_CHECK")
		self:RegisterEvent("UPDATE_WORLD_STATES")
		self:RegisterEvent("WORLD_STATE_TIMER_START")
		self:RegisterEvent("WORLD_STATE_UI_TIMER_UPDATE")
		self:SetScript("OnEvent", DraggerEventHandler)
		self.EventsActive = true;
	end

	ReloadUI()
end
--[[
##########################################################
LOAD BY TRIGGER
##########################################################
]]--
local function InitializeMovables()
	CLOAKED_BG:SetAllPoints(SV.Screen);
	CLOAKED_BG:SetParent(Layout);
	CLOAKED_BG:SetFrameStrata('BACKGROUND')
	CLOAKED_BG:SetFrameLevel(0)
	CLOAKED_BG:SetBackdrop({
		bgFile = [[Interface\BUTTONS\WHITE8X8]],
	    tile = false,
	    tileSize = 0,
	    edgeFile = [[Interface\AddOns\SVUI_!Core\assets\textures\EMPTY]],
	    edgeSize = 1,
	    insets =
	    {
	        left = 0,
	        right = 0,
	        top = 0,
	        bottom = 0,
	    },
	});
	CLOAKED_BG:SetBackdropColor(0,0,0,0.15);

	Layout.Anchors = SV.db.LAYOUT or {}
	--Layout:SetPanelColor("yellow")
	Layout:RegisterForDrag("LeftButton")
	Layout:RegisterEvent("PLAYER_REGEN_DISABLED")
	Layout:SetScript("OnEvent", XML_Layout_OnEvent)
	Layout.Portrait:SetTexture([[Interface\AddOns\SVUI_!Core\assets\textures\Doodads\MENTALO-OFF]])

	SVUI_LayoutLockButton:SetSize(110, 25)
	SVUI_LayoutLockButton.Left:SetAlpha(0)
	SVUI_LayoutLockButton.Middle:SetAlpha(0)
	SVUI_LayoutLockButton.Right:SetAlpha(0)
	SVUI_LayoutLockButton:SetNormalTexture("")
	SVUI_LayoutLockButton:SetPushedTexture("")
	SVUI_LayoutLockButton:SetPushedTexture("")
	SVUI_LayoutLockButton:SetDisabledTexture("")
	SVUI_LayoutLockButton:RemoveTextures()
	SVUI_LayoutLockButton:SetFrameLevel(SVUI_LayoutLockButton:GetFrameLevel() + 1)
	SVUI_LayoutLockButton.texture = SVUI_LayoutLockButton:CreateTexture(nil, "BORDER")
	SVUI_LayoutLockButton.texture:SetSize(110, 50)
	SVUI_LayoutLockButton.texture:SetPoint("CENTER", SVUI_LayoutLockButton, "CENTER", 0, -4)
	SVUI_LayoutLockButton.texture:SetTexture([[Interface\AddOns\SVUI_!Core\assets\textures\Doodads\QUESTION]])
	SVUI_LayoutLockButton.texture:SetVertexColor(1, 1, 1)
	SVUI_LayoutLockButton.texture:SetTexCoord(1, 0, 1, 1, 0, 0, 0, 1)
	SVUI_LayoutLockButton.text = SVUI_LayoutLockButton:CreateFontString(nil, "OVERLAY")
	SVUI_LayoutLockButton.text:SetFont(SV.media.font.caps, 18, "OUTLINE")
	SVUI_LayoutLockButton.text:SetTextColor(1, 0.5, 0)
	SVUI_LayoutLockButton.text:SetPoint("CENTER")
	SVUI_LayoutLockButton.text:SetText("Lock")
	SVUI_LayoutLockButton:SetScript("OnEnter", function(this)
		this.texture:SetVertexColor(0.1, 0.1, 0.1)
		this.text:SetTextColor(1, 1, 0)
	end)
	SVUI_LayoutLockButton:SetScript("OnLeave", function(this)
		this.texture:SetVertexColor(1, 1, 1)
		this.text:SetTextColor(1, 0.5, 0)
	end)
	SVUI_LayoutLockButton:SetScript("OnClick", XML_LayoutLockButton_OnClick)

	SVUI_LayoutGridButton:SetSize(110, 25)
	SVUI_LayoutGridButton.Left:SetAlpha(0)
	SVUI_LayoutGridButton.Middle:SetAlpha(0)
	SVUI_LayoutGridButton.Right:SetAlpha(0)
	SVUI_LayoutGridButton:SetNormalTexture("")
	SVUI_LayoutGridButton:SetPushedTexture("")
	SVUI_LayoutGridButton:SetPushedTexture("")
	SVUI_LayoutGridButton:SetDisabledTexture("")
	SVUI_LayoutGridButton:RemoveTextures()
	SVUI_LayoutGridButton:SetFrameLevel(SVUI_LayoutGridButton:GetFrameLevel() + 1)
	SVUI_LayoutGridButton.texture = SVUI_LayoutGridButton:CreateTexture(nil, "BORDER")
	SVUI_LayoutGridButton.texture:SetSize(110, 50)
	SVUI_LayoutGridButton.texture:SetPoint("CENTER", SVUI_LayoutGridButton, "CENTER", 0, -4)
	SVUI_LayoutGridButton.texture:SetTexture([[Interface\AddOns\SVUI_!Core\assets\textures\Doodads\QUESTION]])
	SVUI_LayoutGridButton.texture:SetVertexColor(1, 1, 1)
	SVUI_LayoutGridButton.text = SVUI_LayoutGridButton:CreateFontString(nil, "OVERLAY")
	SVUI_LayoutGridButton.text:SetFont(SV.media.font.caps, 18, "OUTLINE")
	SVUI_LayoutGridButton.text:SetTextColor(1, 0.5, 0)
	SVUI_LayoutGridButton.text:SetPoint("CENTER")
	SVUI_LayoutGridButton.text:SetText("Grid")
	SVUI_LayoutGridButton:SetScript("OnEnter", function(this)
		this.texture:SetVertexColor(0.1, 0.1, 0.1)
		this.text:SetTextColor(1, 1, 0)
	end)
	SVUI_LayoutGridButton:SetScript("OnLeave", function(this)
		this.texture:SetVertexColor(1, 1, 1)
		this.text:SetTextColor(1, 0.5, 0)
	end)
	SVUI_LayoutGridButton:SetScript("OnClick", XML_LayoutGridButton_OnClick)

	SVUI_LayoutPrecision:SetFrameLevel(999)
	SVUI_LayoutPrecision:SetStyle("Frame", "Pattern")
	SVUI_LayoutPrecision:EnableMouse(true)
	SVUI_LayoutPrecision:RegisterForDrag("LeftButton")

	SV.API:Set("CloseButton", SVUI_LayoutPrecisionCloseButton)

	SVUI_LayoutPrecisionSetX:SetStyle("Editbox")
	SVUI_LayoutPrecisionSetX.CurrentValue = 0;
	SVUI_LayoutPrecisionSetX:SetScript("OnEnterPressed", XML_LayoutPrecisionInputX_EnterPressed)
	SVUI_LayoutPrecisionSetY:SetStyle("Editbox")
	SVUI_LayoutPrecisionSetY.CurrentValue = 0;
	SVUI_LayoutPrecisionSetY:SetScript("OnEnterPressed", XML_LayoutPrecisionInputY_EnterPressed)
	SVUI_LayoutPrecisionResetButton:SetStyle("Button")
	SVUI_LayoutPrecisionUpButton:SetStyle("Button")
	SVUI_LayoutPrecisionDownButton:SetStyle("Button")
	SVUI_LayoutPrecisionLeftButton:SetStyle("Button")
	SVUI_LayoutPrecisionRightButton:SetStyle("Button")
	SVUI_LayoutPrecisionResetButton:SetScript("OnClick", SVUI_LayoutPrecisionResetButton_OnClick)

	SVUI_LayoutPrecisionWidthAdjust:SetValueStep(1);
	SVUI_LayoutPrecisionHeightAdjust:SetValueStep(1);
	SVUI_LayoutPrecisionWidthAdjust:SetScript("OnValueChanged", XML_LayoutPrecisionWidthAdjust_OnValueChanged)
	SVUI_LayoutPrecisionHeightAdjust:SetScript("OnValueChanged", XML_LayoutPrecisionHeightAdjust_OnValueChanged)

	SVUI_LayoutPrecision:SetScript("OnHide", function()
		if(not CurrentFrameTarget) then return end
		CurrentFrameTarget.text:SetTextColor(0.8, 0.4, 0)
		CurrentFrameTarget:SetBackdropBorderColor(0.8, 0.4, 0)
		CurrentFrameTarget = nil
	end)

	Layout:Update()

	if(SV.db.general.useDraggable) then
		if(not SV.private.Draggables) then SV.private.Draggables = {} end

		if(SV.db.general.saveDraggable) then
			Dragger.Frames = SV.private.Draggables
		else
			Dragger.Frames = {}
		end

		Dragger.EventsActive = true

		Dragger:RegisterEvent("ADDON_LOADED")
		Dragger:RegisterEvent("LFG_UPDATE")
		Dragger:RegisterEvent("ROLE_POLL_BEGIN")
		Dragger:RegisterEvent("READY_CHECK")
		Dragger:RegisterEvent("UPDATE_WORLD_STATES")
		Dragger:RegisterEvent("WORLD_STATE_TIMER_START")
		Dragger:RegisterEvent("WORLD_STATE_UI_TIMER_UPDATE")

		DraggerEventHandler(Dragger)
		Dragger:SetScript("OnEvent", DraggerEventHandler)

		if(SV.db.general.saveDraggable) then
			hooksecurefunc("UIParent_ManageFramePositions", _hook_UIParent_ManageFramePositions)
		end
	end
end

SV.Events:On("LOAD_ALL_WIDGETS", InitializeMovables);
--[[
##########################################################
CORE FUNCTIONS
##########################################################
]]--
function SV:NewAnchor(frame, title, postDragFunc)
	if(not frame or (not frame.GetName)) then return end
	local frameName = frame:GetName()
	local moveName = ("%s_MOVE"):format(frameName)
	SetNewAnchor(frame, moveName, title, postDragFunc)
	if(self.initialized) then Layout:Update() end
	return moveName
end

function SV:SetAnchorResizing(frame, postSizeFunc, minRange, maxRange, min2Range, max2Range)
	if(not frame or (not frame.Grip)) then return end
	Layout.Frames[frame.Grip.name].postsize = postSizeFunc;
	frame.Grip.minRange = minRange;
	frame.Grip.maxRange = maxRange;
	frame.Grip.min2Range = min2Range;
	frame.Grip.max2Range = max2Range;
	frame.Grip.postsize = postSizeFunc;
end

function SV:ReAnchor(name, ...)
	if((not name) or (not _G[name])) then return end
	local frame = _G[name]
	if(not frame.Grip) then return end
	frame.Grip:ClearAllPoints()
	frame.Grip:SetPoint(...)
	SaveAnchor(frame.Grip.name)
end

function SV:MoveAnchors(...)
	Layout:Toggle(...)
end

function SV:UpdateAnchors()
	Layout:Update()
end

function SV:ResetAnchors(...)
	Layout:Reset(...)
end

function SV:ForceAnchors(forced)
	if(Layout.Frames) then
        for frame,_ in pairs(Layout.Frames) do
            if _G[frame] and _G[frame]:IsShown() then
                forced = true;
                _G[frame]:Hide()
            end
        end
    end
    return forced
end

SV.SystemAlert["RESETBLIZZARD_CHECK"] = {
	text = L["Are you sure you want to all draggable Blizzard frames to their original positions? This will reload your UI."],
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(a) Dragger:Reset() end,
	timeout = 0,
	whileDead = 1
};

SV.SystemAlert["RESETLAYOUT_CHECK"] = {
	text = L["Are you sure you want to all movable frames to their original positions?"],
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(a) Layout:Reset() end,
	timeout = 0,
	whileDead = 1
};
