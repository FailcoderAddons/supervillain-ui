--[[
##############################################################################
S V U I   By: Failcoder
##############################################################################
--]]
--LUA
local unpack        = unpack;
local select        = select;
local pairs         = pairs;
local type          = type;
local rawset        = rawset;
local rawget        = rawget;
local tostring      = tostring;
local tonumber      = tonumber;
local error         = error;
local next          = next;
local pcall         = pcall;
local getmetatable  = getmetatable;
local setmetatable  = setmetatable;
local assert        = assert;
--BLIZZARD
local _G            = _G;
local tinsert       = _G.tinsert;
local tremove       = _G.tremove;
local twipe         = _G.wipe;
--STRING
local string        = string;
local format        = string.format;
local sub           = string.sub;
local upper         = string.upper;
local match         = string.match;
local gsub          = string.gsub;
--MATH
local math          = math;
local numMin        = math.min;
--TABLE
local table         = table;
local tsort         = table.sort;
local tremove       = table.remove;

local SV = _G['SVUI']
local L = SV.L;
local LSM = _G.LibStub("LibSharedMedia-3.0")
local MOD = SV.UnitFrames

if(not MOD) then return end

local oUF_SVUI = MOD.oUF
assert(oUF_SVUI, "SVUI UnitFrames: unable to locate oUF.")
--[[
##########################################################
LOCALIZED GLOBALS
##########################################################
]]--
local UIParent              = _G.UIParent;
local GameTooltip           = _G.GameTooltip;
local CreateFrame           = _G.CreateFrame;
local InCombatLockdown      = _G.InCombatLockdown;
local IsAddOnLoaded         = _G.IsAddOnLoaded;
local IsInInstance          = _G.IsInInstance;

local UnitIsUnit            = _G.UnitIsUnit;
local UnitReaction          = _G.UnitReaction;
local UnitIsPlayer          = _G.UnitIsPlayer;
local UnitClass             = _G.UnitClass;
local UnitFrame_OnEnter     = _G.UnitFrame_OnEnter;
local UnitFrame_OnLeave     = _G.UnitFrame_OnLeave;

local RegisterStateDriver       = _G.RegisterStateDriver;
local UnregisterStateDriver     = _G.UnregisterStateDriver;
local RegisterAttributeDriver   = _G.RegisterAttributeDriver;
local UnregisterAttributeDriver = _G.UnregisterAttributeDriver;

local RegisterUnitWatch          = _G.RegisterUnitWatch;
local UnregisterUnitWatch        = _G.UnregisterUnitWatch;
local FOCUSTARGET                = _G.FOCUSTARGET;
local CLEAR_FOCUS                = _G.CLEAR_FOCUS;
local FACTION_BAR_COLORS         = _G.FACTION_BAR_COLORS;
local RAID_CLASS_COLORS          = _G.RAID_CLASS_COLORS;
local CUSTOM_CLASS_COLORS        = _G.CUSTOM_CLASS_COLORS
local LOCALIZED_CLASS_NAMES_MALE = _G.LOCALIZED_CLASS_NAMES_MALE;
--[[
##########################################################
LOCAL DATA
##########################################################
]]--
local CONSTRUCTORS = {}
local lastArenaFrame, lastBossFrame
--[[
##########################################################
ALL UNIT HELPERS
##########################################################
]]--
local unitLayoutPostSizeFunc = function(self, width, height)
  SV.db.UnitFrames[self.___key].width = width;
  SV.db.UnitFrames[self.___key].height = height;
  self:Update()
end

local enemyLayoutPostSizeFunc = function(self, width, height)
  SV.db.UnitFrames[self.___key].width = width;
  SV.db.UnitFrames[self.___key].height = height;
  for i=1, self.___maxCount do
    local frame = MOD.Units[self.___key .. i];
    if(frame) then
      frame:Update()
    end
  end
end

local UpdateTargetGlow = function(self)
    if not self.unit then return end
    local unit = self.unit;
    if(UnitIsUnit(unit, "target")) then
        self.TargetGlow:Show()
        local reaction = UnitReaction(unit, "player")
        if(reaction) then
            local colors = FACTION_BAR_COLORS[reaction]
            self.TargetGlow:SetBackdropBorderColor(colors.r, colors.g, colors.b)
        else
            self.TargetGlow:SetBackdropBorderColor(0.2, 1, 0.3)
        end
    else
        self.TargetGlow:Hide()
    end
end

local AllowElement = function(self)
    if InCombatLockdown() then return; end
    -- print('Allowed')
    -- print(self.unit)
    -- print(self.isForced)
    if not self.isForced then
        self.sourceElement = self.unit;
        self.unit = "player"
        self.isForced = true;
        self.sourceEvent = self:GetScript("OnUpdate")
    end

    self:SetScript("OnUpdate", nil)
    self.forceShowAuras = true;
    UnregisterUnitWatch(self)
    RegisterUnitWatch(self, true)

    self:Show()
    if self:IsVisible() and self.Update then
        self:Update()
    end
end

local RestrictElement = function(self)
    if(InCombatLockdown() or (not self.isForced)) then return; end
    -- print('Restricted')
    -- print(self.unit)
    -- print(self.isForced)
    self.forceShowAuras = nil
    self.isForced = nil

    UnregisterUnitWatch(self)
    RegisterUnitWatch(self)

    if self.sourceEvent then
        self:SetScript("OnUpdate", self.sourceEvent)
        self.sourceEvent = nil
    end

    self.unit = self.sourceElement or self.unit;

    if self:IsVisible() and self.Update then
        self:Update()
    end
end
--[[
##########################################################
PLAYER
##########################################################
]]--
local UpdatePlayerFrame = function(self)
    local db = SV.db.UnitFrames["player"]
    local UNIT_WIDTH = db.width;
    local UNIT_HEIGHT = db.height;
    local USE_CLASSBAR = db.classbar.enable;
    local classBarHeight = db.classbar.height;
    local classBarWidth = db.width * 0.4;
    local iconDB = db.icons
    self:RegisterForClicks(SV.db.UnitFrames.fastClickTarget and "AnyDown" or "AnyUp")

    MOD.RefreshUnitMedia(self, "player")

    self.colors = oUF_SVUI.colors;
    self:SetSize(UNIT_WIDTH, UNIT_HEIGHT)
    self.Grip:SetSize(self:GetSize())
    local lossSize = UNIT_WIDTH * 0.6
    self.LossOfControl.stunned:SetSize(lossSize, lossSize)

    MOD:RefreshUnitLayout(self, "player")

    do
        local resting = self.Resting;
        if resting then
            if iconDB and iconDB.restIcon and iconDB.restIcon.enable then
                local size = iconDB.restIcon.size;
                resting:ClearAllPoints()
                resting:SetSize(size, size)
                SV:SetReversePoint(resting, iconDB.restIcon.attachTo, self, iconDB.restIcon.xOffset, iconDB.restIcon.yOffset)
                if not self:IsElementEnabled("Resting")then
                    self:EnableElement("Resting")
                end
            elseif self:IsElementEnabled("Resting")then
                self:DisableElement("Resting")
                resting:Hide()
            end
        end
    end
    do
        local combat = self.Combat;
        if combat then
            if iconDB and iconDB.combatIcon and iconDB.combatIcon.enable then
                local size = iconDB.combatIcon.size;
                combat:ClearAllPoints()
                combat:SetSize(size, size)
                SV:SetReversePoint(combat, iconDB.combatIcon.attachTo, self, iconDB.combatIcon.xOffset, iconDB.combatIcon.yOffset)
                if not self:IsElementEnabled("Combat")then
                    self:EnableElement("Combat")
                end
            elseif self:IsElementEnabled("Combat")then
                self:DisableElement("Combat")
                combat:Hide()
            end
        end
    end
    do 
        local aggro = self.Aggro;
        if aggro then
            if iconDB and iconDB.aggroIcon then
                aggro.isEnabled = iconDB.aggroIcon.enable;
                if(iconDB.aggroIcon.enable) then
                local size = iconDB.aggroIcon.size;
                    aggro:ClearAllPoints()
                    aggro:SetSize(size, size)
                    SV:SetReversePoint(aggro, iconDB.aggroIcon.attachTo, self, iconDB.aggroIcon.xOffset, iconDB.aggroIcon.yOffset)
                end
            end
        end
    end
    do
        local pvp = self.PvPText;
        local point = db.pvp.position;
        pvp:ClearAllPoints()
        pvp:SetPoint(db.pvp.position, self, db.pvp.position)
        self:Tag(pvp, db.pvp.tags)
    end
    do
        if(self.ClassBar) then
            if USE_CLASSBAR and self.RefreshClassBar then
                self.RefreshClassBar(self)
            end
            local classBar = self[self.ClassBar];
            if USE_CLASSBAR then
                if(not self:IsElementEnabled(self.ClassBar)) then
                    self:EnableElement(self.ClassBar)
                end
                classBar:Show()
            else
                if(self:IsElementEnabled(self.ClassBar)) then
                    self:DisableElement(self.ClassBar)
                end
                classBar:Hide()
            end
        end
    end

    do
        self.CombatFade = db.combatfade;
        if(self.CombatFade and (not self:IsElementEnabled("CombatFade"))) then
            self:EnableElement("CombatFade")
        elseif(self:IsElementEnabled("CombatFade") and (not self.CombatFade)) then
            self:DisableElement("CombatFade")
        end
    end

    self:UpdateAllElements()
end

CONSTRUCTORS["player"] = function(self, unit)
    local key = "player"
    self.unit = unit
    self.___key = key

    self:SetScript("OnEnter", UnitFrame_OnEnter)
    self:SetScript("OnLeave", UnitFrame_OnLeave)
    self:SetFrameLevel(2)

    MOD:SetActionPanel(self, key)
    self.Health = MOD:CreateHealthBar(self, true)
    self.Health.frequentUpdates = true
    self.Power = MOD:CreatePowerBar(self)
    self.Power.frequentUpdates = true
    MOD:CreatePortrait(self, false, true)
    MOD:CreateAuraFrames(self, key, true)
    self.Castbar = MOD:CreateCastbar(self, false, L["Player Castbar"], true, true, false, true)
    MOD:CreateExperienceRepBar(self)
    self.ClassBar = MOD:CreateClassBar(self)
    self.RaidIcon = MOD:CreateRaidIcon(self)
    MOD:CreatePlayerIndicators(self)
    self.PvPText = self.TextGrip:CreateFontString(nil,'OVERLAY')
    self.PvPText:SetFontObject(SpellFont_Small)
    self.Afflicted = MOD:CreateAfflicted(self)
    self.HealPrediction = MOD:CreateHealPrediction(self, true)
    -- JV - 20160919 : Resolve mechanic is now gone as of Legion.
    --self.ResolveBar = MOD:CreateResolveBar(self)
    self.CombatFade = false;
    self:SetPoint("BOTTOMRIGHT", SV.Screen, "BOTTOM", -80, 182)
    SV:NewAnchor(self, L["Player Frame"])
    SV:SetAnchorResizing(self, unitLayoutPostSizeFunc, 10, 500)

    self.MediaUpdate = MOD.RefreshUnitMedia
    self.Update = UpdatePlayerFrame

    return self
end
--[[
##########################################################
TARGET
##########################################################
]]--
local UpdateTargetFrame = function(self)
    local db = SV.db.UnitFrames["target"]
    local UNIT_WIDTH = db.width;
    local UNIT_HEIGHT = db.height;
    local USE_COMBOBAR = db.combobar.enable;
    local comboBarHeight = db.combobar.height;
    self:RegisterForClicks(SV.db.UnitFrames.fastClickTarget and "AnyDown" or "AnyUp")

    MOD.RefreshUnitMedia(self, "target")
    self.colors = oUF_SVUI.colors;
    self:SetSize(UNIT_WIDTH, UNIT_HEIGHT)
    self.Grip:SetSize(self:GetSize())
    if not self:IsElementEnabled("ActionPanel")then
        self:EnableElement("ActionPanel")
    end

    if not self:IsElementEnabled("Friendship")then
        self:EnableElement("Friendship")
    end
    MOD:RefreshUnitLayout(self, "target")

    if(not IsAddOnLoaded("Clique")) then
        if db.middleClickFocus then
            self:SetAttribute("type3", "focus")
        elseif self:GetAttribute("type3") == "focus"then
            self:SetAttribute("type3", nil)
        end
    end

    self:UpdateAllElements()
end

CONSTRUCTORS["target"] = function(self, unit)
    local key = "target"
    self.unit = unit
    self.___key = key

    self:SetScript("OnEnter", UnitFrame_OnEnter)
    self:SetScript("OnLeave", UnitFrame_OnLeave)
    self:SetFrameLevel(2)

    MOD:SetActionPanel(self, key)

    self.Health = MOD:CreateHealthBar(self, true)
    self.Health.frequentUpdates = true
    self.HealPrediction = MOD:CreateHealPrediction(self, true)

    self.Power = MOD:CreatePowerBar(self)
    self.Power.frequentUpdates = true

    MOD:CreatePortrait(self)

    self.Castbar = MOD:CreateCastbar(self, true, L["Target Castbar"], true, false, false, true)

    MOD:CreateAuraFrames(self, key, true)
    self.Afflicted = MOD:CreateAfflicted(self)
    self.RaidIcon = MOD:CreateRaidIcon(self)

    local xray = CreateFrame("Button", "SVUI_XRayFocus", self, "SecureActionButtonTemplate")
    xray:SetPoint("TOPRIGHT", 12, 12)
    xray:EnableMouse(true)
    xray:RegisterForClicks("AnyUp")
    xray:SetAttribute("type", "macro")
    xray:SetAttribute("macrotext", "/focus")
    xray:SetSize(64,64)
    xray:SetFrameStrata("MEDIUM")
    xray.icon = xray:CreateTexture(nil,"ARTWORK")
    xray.icon:SetTexture([[Interface\Addons\SVUI_!Core\assets\textures\Doodads\UNIT-XRAY]])
    xray.icon:SetAllPoints(xray)
    xray.icon:SetAlpha(0)
    xray:SetScript("OnLeave", function(self) GameTooltip:Hide() self.icon:SetAlpha(0) end)
    xray:SetScript("OnEnter", function(self)
        self.icon:SetAlpha(1)
        local anchor1, anchor2 = SV:GetScreenXY(self)
        GameTooltip:SetOwner(self, "ANCHOR_NONE")
        GameTooltip:SetPoint(anchor1, self, anchor2)
        GameTooltip:SetText(FOCUSTARGET)
    end)

    self.XRay = xray

    self.Friendship = MOD:CreateFriendshipBar(self)
    self.Range = { insideAlpha = 1, outsideAlpha = 1 }

    self:SetPoint("BOTTOMLEFT", SV.Screen, "BOTTOM", 80, 182)
    SV:NewAnchor(self, L["Target Frame"])
    SV:SetAnchorResizing(self, unitLayoutPostSizeFunc, 10, 500)

    self.MediaUpdate = MOD.RefreshUnitMedia
    self.Update = UpdateTargetFrame
    return self
end
--[[
##########################################################
TARGET OF TARGET
##########################################################
]]--
local UpdateTargetTargetFrame = function(self)
    local db = SV.db.UnitFrames["targettarget"]
    local UNIT_WIDTH = db.width
    local UNIT_HEIGHT = db.height
    self:RegisterForClicks(SV.db.UnitFrames.fastClickTarget and "AnyDown" or "AnyUp")
    MOD.RefreshUnitMedia(self, "targettarget")
    self.colors = oUF_SVUI.colors;
    self:SetSize(UNIT_WIDTH, UNIT_HEIGHT)
    self.Grip:SetSize(self:GetSize())
    MOD:RefreshUnitLayout(self, "targettarget")
    self:UpdateAllElements()
end

CONSTRUCTORS["targettarget"] = function(self, unit)
    local key = "targettarget"
    self.unit = unit
    self.___key = key

    self:SetScript("OnEnter", UnitFrame_OnEnter)
    self:SetScript("OnLeave", UnitFrame_OnLeave)
    self:SetFrameLevel(2)

    MOD:SetActionPanel(self, key)
    self.Health = MOD:CreateHealthBar(self, true)
    self.Power = MOD:CreatePowerBar(self)
    MOD:CreatePortrait(self, true)
    MOD:CreateAuraFrames(self, key)
    self.RaidIcon = MOD:CreateRaidIcon(self)
    self.Range = { insideAlpha = 1, outsideAlpha = 1 }
    self:SetPoint("LEFT", SVUI_Target, "RIGHT", 4, 0)
    SV:NewAnchor(self, L["TargetTarget Frame"])
    SV:SetAnchorResizing(self, unitLayoutPostSizeFunc, 10, 500)

    self.MediaUpdate = MOD.RefreshUnitMedia
    self.Update = UpdateTargetTargetFrame
    return self
end
--[[
##########################################################
PET
##########################################################
]]--
local UpdatePetFrame = function(self)
    local db = SV.db.UnitFrames["pet"]
    local UNIT_WIDTH = db.width;
    local UNIT_HEIGHT = db.height;
    self:RegisterForClicks(SV.db.UnitFrames.fastClickTarget and "AnyDown" or "AnyUp")
    MOD.RefreshUnitMedia(self, "pet")
    self.colors = oUF_SVUI.colors;
    self:SetSize(UNIT_WIDTH, UNIT_HEIGHT)
    self.Grip:SetSize(self:GetSize())
    MOD:RefreshUnitLayout(self, "pet")
    do
        if SVUI_Player and not InCombatLockdown()then
            self:SetParent(SVUI_Player)
        end
    end
    self:UpdateAllElements()
end

CONSTRUCTORS["pet"] = function(self, unit)
    local key = "pet"
    self.unit = unit
    self.___key = key
    self:SetScript("OnEnter", UnitFrame_OnEnter)
    self:SetScript("OnLeave", UnitFrame_OnLeave)
    self:SetFrameLevel(2)
    MOD:SetActionPanel(self, key)
    self.Health = MOD:CreateHealthBar(self, true)
    self.Health.frequentUpdates = true;
    self.HealPrediction = MOD:CreateHealPrediction(self)
    self.Power = MOD:CreatePowerBar(self)
    self.Power.frequentUpdates = false;
    MOD:CreatePortrait(self, true)
    self.Castbar = MOD:CreateCastbar(self, false, L["Pet Castbar"], false)
    MOD:CreateAuraFrames(self, key)
    self.AuraWatch = MOD:CreateAuraWatch(self, key)
    self.RaidIcon = MOD:CreateRaidIcon(self)
    self.Range = { insideAlpha = 1, outsideAlpha = 1 }
    self:SetPoint("RIGHT", SVUI_Player, "LEFT", -4, 0)
    SV:NewAnchor(self, L["Pet Frame"])
    SV:SetAnchorResizing(self, unitLayoutPostSizeFunc, 10, 500)
    self.MediaUpdate = MOD.RefreshUnitMedia
    self.Update = UpdatePetFrame
    return self
end
--[[
##########################################################
TARGET OF PET
##########################################################
]]--
local UpdatePetTargetFrame = function(self)
    local db = SV.db.UnitFrames["pettarget"]
    local UNIT_WIDTH = db.width;
    local UNIT_HEIGHT = db.height;
    self:RegisterForClicks(SV.db.UnitFrames.fastClickTarget and "AnyDown" or "AnyUp")
    MOD.RefreshUnitMedia(self, "pettarget")
    self.colors = oUF_SVUI.colors;
    self:SetSize(UNIT_WIDTH, UNIT_HEIGHT)
    self.Grip:SetSize(self:GetSize())
    MOD:RefreshUnitLayout(self, "pettarget")
    do
        if SVUI_Pet and not InCombatLockdown()then
            self:SetParent(SVUI_Pet)
        end
    end
    self:UpdateAllElements()
end

CONSTRUCTORS["pettarget"] = function(self, unit)
    local key = "pettarget"
    self.unit = unit
    self.___key = key

    self:SetScript("OnEnter", UnitFrame_OnEnter)
    self:SetScript("OnLeave", UnitFrame_OnLeave)
    self:SetFrameLevel(2)

    MOD:SetActionPanel(self, key)
    self.Health = MOD:CreateHealthBar(self, true)
    self.Power = MOD:CreatePowerBar(self)
    MOD:CreateAuraFrames(self, key)
    self.Range = { insideAlpha = 1, outsideAlpha = 1 }
    self:SetPoint("BOTTOM", SVUI_Pet, "TOP", 0, 7)
    self.snapOffset = -7
    SV:NewAnchor(self, L["PetTarget Frame"])
    SV:SetAnchorResizing(self, unitLayoutPostSizeFunc, 10, 500)

    self.MediaUpdate = MOD.RefreshUnitMedia
    self.Update = UpdatePetTargetFrame
    return self
end
--[[
##########################################################
FOCUS
##########################################################
]]--
local UpdateFocusFrame = function(self)
    local db = SV.db.UnitFrames["focus"]
    local UNIT_WIDTH = db.width;
    local UNIT_HEIGHT = db.height;
    self:RegisterForClicks(SV.db.UnitFrames.fastClickTarget and "AnyDown" or "AnyUp")
    MOD.RefreshUnitMedia(self, "focus")
    self.colors = oUF_SVUI.colors;
    self:SetSize(UNIT_WIDTH, UNIT_HEIGHT)
    self.Grip:SetSize(self:GetSize())
    MOD:RefreshUnitLayout(self, "focus")

    self:UpdateAllElements()
end

CONSTRUCTORS["focus"] = function(self, unit)
    local key = "focus"
    self.unit = unit
    self.___key = key

    self:SetScript("OnEnter", UnitFrame_OnEnter)
    self:SetScript("OnLeave", UnitFrame_OnLeave)
    self:SetFrameLevel(2)

    MOD:SetActionPanel(self, key)

    self.Health = MOD:CreateHealthBar(self, true)
    self.Health.frequentUpdates = true

    self.HealPrediction = MOD:CreateHealPrediction(self, true)
    self.Power = MOD:CreatePowerBar(self)

    self.Castbar = MOD:CreateCastbar(self, false, L["Focus Castbar"])
    self.Castbar.SafeZone = nil

    self.Castbar.LatencyTexture:Hide()
    MOD:CreateAuraFrames(self, key, true)
    self.AuraWatch = MOD:CreateAuraWatch(self, key)
    self.RaidIcon = MOD:CreateRaidIcon(self)
    self.Range = { insideAlpha = 1, outsideAlpha = 1 }

    local xray = CreateFrame("Button", "SVUI_XRayFocusClear", self, "SecureActionButtonTemplate")
    xray:SetPoint("RIGHT", 20, 0)
    xray:EnableMouse(true)
    xray:RegisterForClicks("AnyUp")
    xray:SetAttribute("type", "macro")
    xray:SetAttribute("macrotext", "/clearfocus")
    xray:SetSize(50,50)
    xray:SetFrameStrata("MEDIUM")
    xray.icon = xray:CreateTexture(nil,"ARTWORK")
    xray.icon:SetTexture([[Interface\Addons\SVUI_!Core\assets\textures\Doodads\UNIT-XRAY-CLOSE]])
    xray.icon:SetAllPoints(xray)
    xray.icon:SetAlpha(0)
    xray.icon:SetVertexColor(1,0.2,0.1)
    xray:SetScript("OnLeave", function(self) GameTooltip:Hide() self.icon:SetAlpha(0) end)
    xray:SetScript("OnEnter",function(self)
        self.icon:SetAlpha(1)
        local anchor1, anchor2 = SV:GetScreenXY(self)
        GameTooltip:SetOwner(self, "ANCHOR_NONE")
        GameTooltip:SetPoint(anchor1, self, anchor2)
        GameTooltip:SetText(CLEAR_FOCUS)
    end)

    self.XRay = xray

    self:SetPoint("BOTTOMRIGHT", SVUI_Target, "TOPRIGHT", 0, 220)
    SV:NewAnchor(self, L["Focus Frame"])
    SV:SetAnchorResizing(self, unitLayoutPostSizeFunc, 10, 500)

    self.MediaUpdate = MOD.RefreshUnitMedia
    self.Update = UpdateFocusFrame
    return self
end
--[[
##########################################################
TARGET OF FOCUS
##########################################################
]]--
local UpdateFocusTargetFrame = function(self)
    local db = SV.db.UnitFrames["focustarget"]
    local UNIT_WIDTH = db.width;
    local UNIT_HEIGHT = db.height;
    self:RegisterForClicks(SV.db.UnitFrames.fastClickTarget and "AnyDown" or "AnyUp")
    MOD.RefreshUnitMedia(self, "focustarget")
    self.colors = oUF_SVUI.colors;
    self:SetSize(UNIT_WIDTH, UNIT_HEIGHT)
    self.Grip:SetSize(self:GetSize())
    MOD:RefreshUnitLayout(self, "focustarget")
    self:UpdateAllElements()
end

CONSTRUCTORS["focustarget"] = function(self, unit)
    local key = "focustarget"
    self.unit = unit
    self.___key = key

    self:SetScript("OnEnter", UnitFrame_OnEnter)
    self:SetScript("OnLeave", UnitFrame_OnLeave)
    self:SetFrameLevel(2)

    MOD:SetActionPanel(self, key)
    self.Health = MOD:CreateHealthBar(self, true)
    self.Power = MOD:CreatePowerBar(self)
    MOD:CreateAuraFrames(self, key)
    self.RaidIcon = MOD:CreateRaidIcon(self)
    self.Range = { insideAlpha = 1, outsideAlpha = 1 }
    self:SetPoint("LEFT", SVUI_Focus, "RIGHT", 12, 0)
    self.snapOffset = -7
    SV:NewAnchor(self, L["FocusTarget Frame"])
    SV:SetAnchorResizing(self, unitLayoutPostSizeFunc, 10, 500)

    self.MediaUpdate = MOD.RefreshUnitMedia
    self.Update = UpdateFocusTargetFrame
    return self
end
--[[
##########################################################
BOSS
##########################################################
]]--
local UpdateBossFrame = function(self)
    local db = SV.db.UnitFrames["boss"]
    local INDEX = self:GetID() or 1;
    local holder = _G['SVUI_Boss1_MOVE']
    local UNIT_WIDTH = db.width;
    local UNIT_HEIGHT = db.height;

    MOD.RefreshUnitMedia(self, "boss")

    self.colors = oUF_SVUI.colors;
    self:SetSize(UNIT_WIDTH, UNIT_HEIGHT)
    self.Grip:SetSize(self:GetSize())

    if(holder and (tonumber(INDEX) > 1) and (not self.Grip:HasMoved())) then
      self.Grip:ClearAllPoints()
      local yOffset = (UNIT_HEIGHT + 12 + db.castbar.height) * (INDEX - 1)
      if db.showBy == "UP" then
          self.Grip:SetPoint("BOTTOMRIGHT", holder, "BOTTOMRIGHT", 0, yOffset)
      else
          self.Grip:SetPoint("TOPRIGHT", holder, "TOPRIGHT", 0, -yOffset)
      end
    end

    self:RegisterForClicks(SV.db.UnitFrames.fastClickTarget and "AnyDown" or "AnyUp")
    MOD:RefreshUnitLayout(self, "boss")
    self:UpdateAllElements()
end

CONSTRUCTORS["boss"] = function(self, unit)
    local key = "boss"
    local selfID = unit:match('boss(%d)')
    self.unit = unit
    self.___key = key;
    self:SetID(selfID)

    self:SetScript("OnEnter", UnitFrame_OnEnter)
    self:SetScript("OnLeave", UnitFrame_OnLeave)
    self:SetFrameLevel(2)

    MOD:SetActionPanel(self, key)
    self.Health = MOD:CreateHealthBar(self, true)
    self.Health.frequentUpdates = true
    self.Power = MOD:CreatePowerBar(self)
    MOD:CreatePortrait(self)
    MOD:CreateAuraFrames(self, key)
    self.Afflicted = MOD:CreateAfflicted(self)
    self.Castbar = MOD:CreateCastbar(self, true, nil, true, nil, true)
    self.RaidIcon = MOD:CreateRaidIcon(self)
    --self.AltPowerBar = MOD:CreateAltPowerBar(self)

    self.Restrict = RestrictElement
    self.Allow = AllowElement

    self.Range = { insideAlpha = 1, outsideAlpha = 1 }
    self:SetAttribute("type2", "focus")

    local db = SV.db.UnitFrames["boss"]
    local UNIT_WIDTH = db.width;
    local UNIT_HEIGHT = db.height;
    local yOffset = 12 + db.castbar.height
    self:SetSize(UNIT_WIDTH, UNIT_HEIGHT)

    if(db.showBy == "UP") then
      if(not lastBossFrame) then
          self:SetPoint("RIGHT", SV.Screen, "RIGHT", -100, -190)
      else
          self:SetPoint("BOTTOMRIGHT", lastBossFrame, "TOPRIGHT", 0, yOffset)
      end
    else
      if(not lastBossFrame) then
          self:SetPoint("RIGHT", SV.Screen, "RIGHT", -85, 190)
      else
          self:SetPoint("TOPRIGHT", lastBossFrame, "BOTTOMRIGHT", 0, -yOffset)
      end
    end
    SV:NewAnchor(self, L["Boss Frame "..selfID])
    SV:SetAnchorResizing(self, enemyLayoutPostSizeFunc, 10, 500)

    self.MediaUpdate = MOD.RefreshUnitMedia
    self.Update = UpdateBossFrame
    lastBossFrame = self
    return self
end
--[[
##########################################################
ARENA
##########################################################
]]--
local UpdateArenaFrame = function(self)
    local db = SV.db.UnitFrames["arena"]
    local INDEX = self:GetID() or 1;
    local holder = _G['SVUI_Arena1_MOVE'];
    local UNIT_WIDTH = db.width;
    local UNIT_HEIGHT = db.height

    MOD.RefreshUnitMedia(self, "arena")

    self.colors = oUF_SVUI.colors;
    self:SetSize(UNIT_WIDTH, UNIT_HEIGHT)
    self.Grip:SetSize(self:GetSize())
    self:RegisterForClicks(SV.db.UnitFrames.fastClickTarget and "AnyDown" or "AnyUp")

    if(holder and (tonumber(INDEX) > 1) and (not self.Grip:HasMoved())) then
      self.Grip:ClearAllPoints()
      local yOffset = (UNIT_HEIGHT + 12 + db.castbar.height) * (INDEX - 1)
      if(db.showBy == "UP") then
          self.Grip:SetPoint("BOTTOMRIGHT", holder, "BOTTOMRIGHT", 0, yOffset)
      else
          self.Grip:SetPoint("TOPRIGHT", holder, "TOPRIGHT", 0, -yOffset)
      end
    end

    MOD:RefreshUnitLayout(self, "arena")

    if(self.Gladiator) then
        local pvp = self.Gladiator
        local trinket = pvp.Trinket
        local badge = pvp.Badge
        local trinketsize = db.pvp.trinketSize
        local specsize = db.pvp.specSize

        local leftAnchor = self
        local rightAnchor = self

        local trinketSize = db.pvp.trinketSize
        local specSize = db.pvp.specSize
        trinket:SetSize(trinketSize, trinketSize)
        trinket:ClearAllPoints()
        if(db.pvp.trinketPosition == "RIGHT") then
            trinket:SetPoint("LEFT", rightAnchor, "RIGHT", db.pvp.trinketX, db.pvp.trinketY)
            rightAnchor = trinket
        else
            trinket:SetPoint("RIGHT", leftAnchor, "LEFT", db.pvp.trinketX, db.pvp.trinketY)
            leftAnchor = trinket
        end

        badge:SetSize(specSize, specSize)
        badge:ClearAllPoints()
        if(db.pvp.specPosition == "RIGHT") then
            badge:SetPoint("LEFT", rightAnchor, "RIGHT", db.pvp.specX, db.pvp.specY)
            rightAnchor = badge
        else
            badge:SetPoint("RIGHT", leftAnchor, "LEFT", db.pvp.specX, db.pvp.specY)
            leftAnchor = badge
        end

        pvp:ClearAllPoints()
        pvp:SetPoint("TOPLEFT", leftAnchor, "TOPLEFT", 0, 0)
        pvp:SetPoint("BOTTOMRIGHT", rightAnchor, "BOTTOMRIGHT", 0, 0)

        if(db.pvp.enable and (not self:IsElementEnabled("Gladiator"))) then
            self:EnableElement("Gladiator")
            pvp:Show()
        elseif((not db.pvp.enable) and self:IsElementEnabled("Gladiator")) then
            self:DisableElement("Gladiator")
            pvp:Hide()
        end
    end

    self:UpdateAllElements()
end

CONSTRUCTORS["arena"] = function(self, unit)
    local key = "arena"
    local selfID = unit:match('arena(%d)')
    self.unit = unit
    self.___key = key
    self:SetID(selfID)

    self:SetScript("OnEnter", UnitFrame_OnEnter)
    self:SetScript("OnLeave", UnitFrame_OnLeave)
    self:SetFrameLevel(2)

    local selfName = self:GetName()
    local prepName = selfName.."PrepFrame";


    MOD:SetActionPanel(self, key)
    self.Health = MOD:CreateHealthBar(self, true)
    self.Power = MOD:CreatePowerBar(self)
    MOD:CreatePortrait(self)
    MOD:CreateAuraFrames(self, key)
    self.Castbar = MOD:CreateCastbar(self, true, nil, true, nil, true)
    self.Gladiator = MOD:CreateGladiator(self)
    self.Range = { insideAlpha = 1, outsideAlpha = 1 }
    self:SetAttribute("type2", "focus")

    self.Restrict = RestrictElement
    self.Allow = AllowElement

    if(not _G[prepName]) then
        local prep = CreateFrame("Frame", prepName, UIParent)
        prep:SetFrameStrata("MEDIUM")
        prep:SetAllPoints(self)
        prep:SetID(selfID)
        prep:SetStyle("Frame", "Bar", true, 3, 1, 1)

        local health = CreateFrame("StatusBar", nil, prep)
        health:SetAllPoints(prep)
        health:SetStatusBarTexture(SV.media.statusbar.default)
        prep.Health = health

        local icon = CreateFrame("Frame", nil, prep)
        icon:SetSize(45,45)
        icon:SetPoint("LEFT", prep, "RIGHT", 2, 0)
        icon:SetBackdrop({
            bgFile = [[Interface\BUTTONS\WHITE8X8]],
            tile = false,
            tileSize = 0,
            edgeFile = [[Interface\BUTTONS\WHITE8X8]],
            edgeSize = 2,
            insets = {
                left = 0,
                right = 0,
                top = 0,
                bottom = 0
            }
        })
        icon:SetBackdropColor(0, 0, 0, 0)
        icon:SetBackdropBorderColor(0, 0, 0)
        icon.Icon = icon:CreateTexture(nil, "OVERLAY")
        icon.Icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
        icon.Icon:InsetPoints(icon, 2, 2)
        prep.SpecIcon = icon

        local text = prep.Health:CreateFontString(nil, "OVERLAY")
        text:SetFont(SV.media.font.dialog, 16, "OUTLINE")
        text:SetTextColor(1, 1, 1)
        text:SetPoint("CENTER")
        prep.SpecClass = text

        prep:Hide()
    end

    local db = SV.db.UnitFrames["arena"]
    local UNIT_WIDTH = db.width;
    local UNIT_HEIGHT = db.height
    local yOffset = 12 + db.castbar.height
    self:SetSize(UNIT_WIDTH, UNIT_HEIGHT)

    if(db.showBy == "UP") then
      if(not lastArenaFrame) then
          self:SetPoint("RIGHT", SV.Screen, "RIGHT", -85, -200)
      else
          self:SetPoint("BOTTOMRIGHT", lastArenaFrame, "TOPRIGHT", 0, yOffset)
      end
    else
      if(not lastArenaFrame) then
          self:SetPoint("RIGHT", SV.Screen, "RIGHT", -85, 200)
      else
          self:SetPoint("TOPRIGHT", lastArenaFrame, "BOTTOMRIGHT", 0, -yOffset)
      end
    end

    SV:NewAnchor(self, L["Arena Frame "..selfID])
    SV:SetAnchorResizing(self, enemyLayoutPostSizeFunc, 10, 500)

    self.MediaUpdate = MOD.RefreshUnitMedia
    self.Update = UpdateArenaFrame
    lastArenaFrame = self
    return self
end
--[[
##########################################################
PREP FRAME
##########################################################
]]--
local ArenaPrepHandler = CreateFrame("Frame")
local ArenaPrepHandler_OnEvent = function(self, event)
    local prepframe
    local _, instanceType = IsInInstance()
    if(not SV.db or not SV.db.UnitFrames or not SV.db.UnitFrames.arena or not SV.db.UnitFrames.arena.enable or instanceType ~= "arena") then return end
    if event == "PLAYER_LOGIN" then
        for i = 1, 5 do
            prepframe = _G["SVUI_Arena"..i.."PrepFrame"]
            if(prepframe) then
                prepframe:SetAllPoints(_G["SVUI_Arena"..i])
            end
        end
    elseif event == "ARENA_OPPONENT_UPDATE" then
        for i = 1, 5 do
            prepframe = _G["SVUI_Arena"..i.."PrepFrame"]
            if(prepframe and prepframe:IsShown()) then
                prepframe:Hide()
            end
        end
    else
        local numOpps = GetNumArenaOpponentSpecs()
        if numOpps > 0 then
            for i = 1, 5 do
                prepframe = _G["SVUI_Arena"..i.."PrepFrame"]
                if(prepframe) then
                    if i <= numOpps then
                        local s = GetArenaOpponentSpec(i)
                        local _, spec, classToken, icon = nil, "UNKNOWN", "UNKNOWN", [[INTERFACE\ICONS\INV_MISC_QUESTIONMARK]]
                        if s and s > 0 then
                            _, spec, _, icon, _, _, classToken = GetSpecializationInfoByID(s)
                        end
                        if classToken and spec then
                            prepframe.SpecClass:SetText(spec .. " - " .. LOCALIZED_CLASS_NAMES_MALE[classToken])
                            prepframe.SpecIcon.Icon:SetTexture(icon or [[INTERFACE\ICONS\INV_MISC_QUESTIONMARK]])

                            local color = CUSTOM_CLASS_COLORS[classToken]
                            if(not SV.db.general.customClassColor) then
                                color = RAID_CLASS_COLORS[classToken]
                            end
                            local textcolor = RAID_CLASS_COLORS[class] or color
                            if color then
                                prepframe.Health:SetStatusBarColor(color.r, color.g, color.b)
                                prepframe.SpecClass:SetTextColor(textcolor.r, textcolor.g, textcolor.b)
                            else
                                prepframe.Health:SetStatusBarColor(0.25, 0.25, 0.25)
                                prepframe.SpecClass:SetTextColor(1, 1, 1)
                            end

                            prepframe:Show()
                        end
                    else
                        prepframe:Hide()
                    end
                end
            end
        else
            for i = 1, 5 do
                prepframe = _G["SVUI_Arena"..i.."PrepFrame"]
                if(prepframe and prepframe:IsShown()) then
                    prepframe:Hide()
                end
            end
        end
    end
end

ArenaPrepHandler:RegisterEvent("PLAYER_LOGIN")
ArenaPrepHandler:RegisterEvent("PLAYER_ENTERING_WORLD")
ArenaPrepHandler:RegisterEvent("ARENA_OPPONENT_UPDATE")
ArenaPrepHandler:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")
ArenaPrepHandler:SetScript("OnEvent", ArenaPrepHandler_OnEvent)
--[[
##########################################################
LOAD/UPDATE METHOD
##########################################################
]]--
function MOD:SetUnitFrame(key)
    if(InCombatLockdown()) then self:RegisterEvent("PLAYER_REGEN_ENABLED"); return end
    local unit = key
    local realName = unit:gsub("(.)", upper, 1)
    realName = realName:gsub("t(arget)", "T%1")
    local styleName = "SVUI_"..realName
    local frame
    if not self.Units[unit] then
        oUF_SVUI:RegisterStyle(styleName, CONSTRUCTORS[key])
        oUF_SVUI:SetActiveStyle(styleName)
        frame = oUF_SVUI:Spawn(unit, styleName)
        self.Units[unit] = frame
    else
        frame = self.Units[unit]
    end
    if frame:GetParent() ~= SVUI_UnitFrameParent then
        frame:SetParent(SVUI_UnitFrameParent)
    end
    if(SV.db.UnitFrames[key].enable) then
        frame:Enable()
        frame:Update()
    else
        frame:Disable()
    end
end

function MOD:SetEnemyFrame(key, maxCount)
    if(InCombatLockdown()) then self:RegisterEvent("PLAYER_REGEN_ENABLED"); return end
    for i = 1, maxCount do
        local unit = key..i
        local realName = unit:gsub("(.)", upper, 1)
        realName = realName:gsub("t(arget)", "T%1")
        local styleName = "SVUI_"..realName
        local frame
        if not self.Units[unit] then
            oUF_SVUI:RegisterStyle(styleName, CONSTRUCTORS[key])
            oUF_SVUI:SetActiveStyle(styleName)
            frame = oUF_SVUI:Spawn(unit, styleName)
            frame.___maxCount = maxCount;
            self.Units[unit] = frame
        else
            frame = self.Units[unit]
        end
        if frame:GetParent() ~= SVUI_UnitFrameParent then
            frame:SetParent(SVUI_UnitFrameParent)
        end
        if(SV.db.UnitFrames[key].enable) then
            frame:Enable()
            frame:Update()
        else
            frame:Disable()
        end

        if(frame.isForced) then
            frame:Allow()
        end
    end
end

-- tinsert(self.__elements, ELEMENT_FUNCTION)
-- self:RegisterEvent(ELEMENT_EVENT, ELEMENT_FUNCTION)
