--[[
##########################################################
S V U I   By: Failcoder
##########################################################
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--

local _G = _G;
--LUA
local unpack        = _G.unpack;
local select        = _G.select;
local assert        = _G.assert;
local type          = _G.type;
local error         = _G.error;
local pcall         = _G.pcall;
local print         = _G.print;
local ipairs        = _G.ipairs;
local pairs         = _G.pairs;
local next          = _G.next;
local rawset        = _G.rawset;
local rawget        = _G.rawget;
local tostring      = _G.tostring;
local tonumber      = _G.tonumber;
local getmetatable  = _G.getmetatable;
local setmetatable  = _G.setmetatable;
local tinsert       = _G.tinsert;
local tremove       = _G.tremove;
local twipe         = _G.wipe;
--STRING
local string        = _G.string;
local format        = string.format;
local find          = string.find;
local match         = string.match;
--MATH
local math          = _G.math;
local min, random   = math.min, math.random;
--TABLE
local table         = _G.table;
local bit 					= _G.bit;
local band, bor 		= bit.band, bit.bor
--[[ LOCALIZED BLIZZ FUNCTIONS ]]--
local NewHook = hooksecurefunc;
--[[
##########################################################
GET ADDON DATA AND TEST FOR oUF
##########################################################
]]--
local SV = _G['SVUI']
local L = SV.L;
local LSM = _G.LibStub("LibSharedMedia-3.0")
local MOD = SV.UnitFrames

if(not MOD) then return end

local oUF_SVUI = MOD.oUF
assert(oUF_SVUI, "SVUI UnitFrames: unable to locate oUF.")
--[[
##########################################################
LOCALS
##########################################################
]]--
local BodyGuard = {
  CurrentName = false,
  CurrentHealth = 1,
  CurrentMaxHealth = 1,
  CurrentStatus = 0,
  Initialized = false,
};
BodyGuard.UF = CreateFrame("Button", "SVUI_BodyGuard", UIParent, "SecureActionButtonTemplate")
local EventListener = CreateFrame("Frame");
local CONTINENT_DRAENOR = 7;
local BODYGUARD_IDS, BODYGUARD_NAMES, BARRACKS_LIST, BODYGUARD_BANNED_ZONES = {}, {}, {[27]=true,[28]=true}, {[978]=true,[1009]=true,[1011]=true};
local FLAGMASK = bor(COMBATLOG_OBJECT_TYPE_GUARDIAN, COMBATLOG_OBJECT_CONTROL_PLAYER, COMBATLOG_OBJECT_REACTION_FRIENDLY, COMBATLOG_OBJECT_AFFILIATION_MINE);

do
  local AURA_SEARCH = {
    [173663]=true,[173662]=true,[173664]=true,[173977]=true,[173665]=true,[173656]=true,[173666]=true,
    [173660]=true,[173657]=true,[173658]=true,[173976]=true,[173659]=true,[173649]=true,[173661]=true
  };
  for id, _ in pairs(AURA_SEARCH) do
    local spellName = GetSpellInfo(id)
    local name = spellName:match("^([%w%s]+) %w+")
    if name then
      BODYGUARD_NAMES[name] = true
      BODYGUARD_IDS[id] = name
    end
  end
end

local function ZoneTest()
  SetMapToCurrentZone()
  if(GetCurrentMapContinent() ~= 7) then return false; end
  local zone = GetCurrentMapAreaID()
  if(BODYGUARD_BANNED_ZONES[zone]) then return false; end
  return true
end

function BodyGuard:RefreshData()
  self.CurrentName = false
  self.CurrentHealth = 1
  self.CurrentMaxHealth = 1
  self.CurrentStatus = 0
  self.Initialized = true

  local buildings = C_Garrison.GetBuildings(LE_GARRISON_TYPE_6_0)

  for i = 1, #buildings do
    local building = buildings[i]
    local building_id = building.buildingID
    if(building_id and BARRACKS_LIST[building_id]) then
      local name, level, quality, displayID, followerID, garrFollowerID, status, portraitIconID = C_Garrison.GetFollowerInfoForBuilding(building.plotID)
      if(not name) then
        self.CurrentStatus = 0;
        self:StatusUpdate()
        return
      end
      self.CurrentName = name
      self.CurrentStatus = 2
      self:NameUpdate()
      break
    end
  end
end

function BodyGuard:GARRISON_BUILDINGS_SWAPPED()
  self:RefreshData()
end

function BodyGuard:GARRISON_BUILDING_ACTIVATED()
  self:RefreshData()
end

function BodyGuard:GARRISON_BUILDING_UPDATE(buildingID)
  if BARRACKS_LIST[buildingID] then self:RefreshData() end
end

function BodyGuard:GARRISON_FOLLOWER_REMOVED()
  self:RefreshData()
end

function BodyGuard:GARRISON_FOLLOWER_ADDED()
  self:RefreshData()
end

function BodyGuard:GARRISON_UPDATE()
  self:RefreshData()
end

function BodyGuard:PLAYER_TARGET_CHANGED(arg)
  if(not self.CurrentName) then return end
  if((arg ~= "LeftButton") and (arg ~= "up")) then return end
  local unit = "target"
  if(self.CurrentName ~= UnitName(unit)) then return end
  self.CurrentHealth = UnitHealth(unit)
  self.CurrentMaxHealth = UnitHealthMax(unit)
  self:HealthUpdate()
end

function BodyGuard:UPDATE_MOUSEOVER_UNIT()
  if(not self.CurrentName) then return end
  local unit = "mouseover"
  local mouseover_name = UnitName(unit)
  if(self.CurrentName == mouseover_name) then
    local tip = _G["GameTooltipTextLeft2"]
    if tip and tip.GetText then
      local text = tip:GetText()
      if(text:find("Bodyguard")) then
        if(self.CurrentStatus == 2) then self.CurrentStatus = 1 end
      else
        self.CurrentStatus = 0
      end
    end
    if(self.CurrentStatus == 1) then
      self.CurrentHealth = UnitHealth(unit)
      self.CurrentMaxHealth = UnitHealthMax(unit)
    end
    self:StatusUpdate()
  end
end

function BodyGuard:UNIT_HEALTH(unit)
  if(not self.CurrentName) then return end
  if(self.CurrentName ~= UnitName(unit)) then return end
  self.CurrentHealth = UnitHealth(unit)
  self.CurrentMaxHealth = UnitHealthMax(unit)
  self:HealthUpdate()
end

function BodyGuard:COMBAT_LOG_EVENT_UNFILTERED(timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, ...)
  if(not self.CurrentName) then return end
  if(sourceName and (sourceName == self.CurrentName)) then
    if(not band(sourceFlags, FLAGMASK) == FLAGMASK) then return end
    self.CurrentStatus = 1
    self:StatusUpdate()
  elseif(destName and (destName == self.CurrentName)) then
    if(not band(destFlags, FLAGMASK) == FLAGMASK) then return end
    local prefix, suffix = event:match("^([A-Z_]+)_([A-Z]+)$")
    local value, updated = 0;

    if prefix:match("^SPELL") then
      value = select(4, ...);
    elseif prefix == "ENVIRONMENTAL" then
      value = select(2, ...);
    else
      value = select(1, ...);
    end

    if suffix == "DAMAGE" then
      self.CurrentHealth = self.CurrentHealth - value
      updated = true
    elseif suffix == "HEAL" then
      self.CurrentHealth = self.CurrentHealth + value
      if self.CurrentMaxHealth <= self.CurrentHealth then
        self.CurrentHealth = self.CurrentMaxHealth
      end
      updated = true
    elseif suffix == "INSTAKILL" then
      self.CurrentHealth = 0
      updated = true
    end

    if(updated) then
      if self.CurrentHealth <= 0 then
        self.CurrentHealth = 0
        self.CurrentStatus = 2
      else
        self.CurrentStatus = 1
      end
      self:HealthUpdate()
    end

    self:StatusUpdate()
  end
end

function BodyGuard:PLAYER_REGEN_ENABLED()
  if(self.CurrentHealth <= 0) then return end
  self.CurrentHealth = self.CurrentMaxHealth
  self:HealthUpdate()
end

function BodyGuard:UNIT_AURA()
  for i = 1, 40 do
    local _, _, _, _, _, duration, expireTime, _, _, _, id = UnitDebuff("player", i)
    if not BODYGUARD_IDS[id] then return end
    local name = BODYGUARD_IDS[id]
    if name == self.CurrentName then
      self.CurrentStatus = 0
      self.CurrentHealth = 0
      self:HealthUpdate()
      self:StatusUpdate()
      return
    end
  end
end

function BodyGuard:PLAYER_ENTERING_WORLD()
  local showing = self:IsShowing()

  if(not self.Initialized) then
    self:RefreshData()
  end

  if((not self.CurrentName) or (self.CurrentStatus == 0)) then
    self:ToggleVisibility("Hide")
    return
  end
  if(not ZoneTest()) then
    self:ToggleVisibility("Hide")
  elseif showing then
    self:UpdateSettings()
  elseif self.CurrentStatus == 1 then
    self:ToggleVisibility("Show")
  end
end

function BodyGuard:ZONE_CHANGED_NEW_AREA()
  if(not ZoneTest()) then
    if not self:IsShowing() then return end
    self:ToggleVisibility("Hide")
  elseif self.CurrentStatus == 1 then
    self:ToggleVisibility("Show")
  end
end

function BodyGuard:IsShowing()
  if(self.UF and (self.UF:IsShown() or self.UF.VisualState == "Show")) then
    return true
  else
    return false
  end
end

function BodyGuard:ToggleVisibility(state)
  if(InCombatLockdown()) then
    self.UF:RegisterEvent("PLAYER_REGEN_ENABLED")
    self.UF.VisualState = state
    return
  elseif(self.UF:IsEventRegistered("PLAYER_REGEN_ENABLED")) then
    self.UF:UnregisterEvent("PLAYER_REGEN_ENABLED")
  end
  if(state == "Hide") then self.UF:Hide() else self.UF:Show() end
end

function BodyGuard:UpdateSettings()
  if(not self.UF) then return end
  if(SV.db.UnitFrames.bodyguard.enable) then
    self.UF:SetParent(SV.Screen)
  else
    self.UF:SetParent(SV.Hidden)
  end

  self:HealthUpdate()
  self.UF:SetWidth(SV.db.UnitFrames.bodyguard.width)
  self.UF:SetHeight(SV.db.UnitFrames.bodyguard.height)
end

function BodyGuard:StatusUpdate()
  if self.CurrentStatus == 1 then
    self:NameUpdate()
    self:HealthUpdate()
    self:ToggleVisibility("Show")
  else
    self:ToggleVisibility("Hide")
  end
end

function BodyGuard:NameUpdate()
  if(not InCombatLockdown() and self.CurrentName) then
    self.UF:SetAttribute("macrotext1", "/targetexact " .. self.CurrentName)
  end
  if(not self.UF.Name) then return end
  self.UF.Name:SetText(self.CurrentName)
end

function BodyGuard:HealthUpdate()
  if(not self.UF) then return end
  local health = self.CurrentHealth;
  local maxHealth = self.CurrentMaxHealth;

  self.UF.Health:SetMinMaxValues(0, maxHealth)
  self.UF.Health:SetValue(health)

  local r, g, b = unpack(oUF_SVUI.colors.health)
  r, g, b = oUF_SVUI.ColorGradient(health, maxHealth, 1, 0, 0, 1, 1, 0, r, g, b)

  self.UF.Health:SetStatusBarColor(r, g, b)
  self.UF.Health.bg:SetVertexColor(r * 0.25, g * 0.25, b * 0.25)
end

-- LOAD

local EventListener_OnEvent = function(self, event, ...)
    local fn = BodyGuard[event]
    if(fn and type(fn) == "function") then
        local _, catch = pcall(fn, BodyGuard, ...)
        if(catch) then
            SV:HandleError("UnitFrames [BodyGuard]", event, catch)
        end
    end
end

local _hook_GOSSIP_CONFIRM = function(...)
  if(not BodyGuard:IsShowing()) then return end
  BodyGuard.CurrentStatus = 0
  BodyGuard.CurrentHealth = BodyGuard.CurrentMaxHealth
  BodyGuard:StatusUpdate()
  BodyGuard:HealthUpdate()
end

function MOD:InitializeBodyGuard()
  BodyGuard.UF.VisualState = "Hide"
  BodyGuard.UF:SetPoint("BOTTOMRIGHT", SV.Dock.BottomLeft, "TOPRIGHT", 0, 10)
  BodyGuard.UF:SetWidth(SV.db.UnitFrames.bodyguard.width)
  BodyGuard.UF:SetHeight(SV.db.UnitFrames.bodyguard.height)
  BodyGuard.UF:SetScript("OnEvent", function(self, event)
    if(event == "PLAYER_REGEN_ENABLED") then
      BodyGuard:ToggleVisibility(self.VisualState)
    elseif(event == "PLAYER_TARGET_CHANGED") then
      if(UnitExists("target") and UnitName("target") == BodyGuard.CurrentName) then
        self.TargetGlow:Show()
      else
        self.TargetGlow:Hide()
      end
    end
  end)
  BodyGuard.UF:SetStyle("Frame", "Icon")

  BodyGuard.UF.TargetGlow = BodyGuard.UF.Panel.Shadow
  BodyGuard.UF.TargetGlow:SetBackdropBorderColor(0, 1, 0, 0.5)
  BodyGuard.UF.TargetGlow:Hide()

  BodyGuard.UF:RegisterEvent("PLAYER_TARGET_CHANGED")
  BodyGuard.UF.Health = CreateFrame("StatusBar", nil, BodyGuard.UF)
  BodyGuard.UF.Health:InsetPoints(BodyGuard.UF)
  BodyGuard.UF.Health:SetMinMaxValues(0, 1)
  BodyGuard.UF.Health:SetValue(1)
  BodyGuard.UF.Health:SetStatusBarTexture(LSM:Fetch("statusbar", SV.db.UnitFrames.statusbar))

  BodyGuard.UF.Health.bg = BodyGuard.UF.Health:CreateTexture(nil, "BORDER")
  BodyGuard.UF.Health.bg:SetAllPoints()
  BodyGuard.UF.Health.bg:SetTexture(SV.media.statusbar.gradient)
  BodyGuard.UF.Health.bg:SetVertexColor(0.1, 0.1, 0.1)

  BodyGuard.UF.Name = BodyGuard.UF.Health:CreateFontString(nil, 'OVERLAY')
  SV:FontManager(BodyGuard.UF.Name, "unitsecondary")
  BodyGuard.UF.Name:SetPoint("CENTER", BodyGuard.UF, "CENTER")
  BodyGuard.UF.Name:SetTextColor(unpack(oUF_SVUI.colors.reaction[5]))

  SV:NewAnchor(BodyGuard.UF, L["BodyGuard Frame"])

  BodyGuard.UF:SetAttribute("type1", "macro")
  if BodyGuard.CurrentName then
    BodyGuard.UF:SetAttribute("macrotext1", "/targetexact " .. BodyGuard.CurrentName)
  end
  BodyGuard:RefreshData()
  BodyGuard:HealthUpdate()
  BodyGuard.UF:Hide()

  EventListener:SetScript("OnEvent", EventListener_OnEvent)

  EventListener:RegisterEvent("GARRISON_BUILDINGS_SWAPPED")
  EventListener:RegisterEvent("GARRISON_BUILDING_ACTIVATED")
  EventListener:RegisterEvent("GARRISON_BUILDING_UPDATE")
  EventListener:RegisterEvent("GARRISON_FOLLOWER_REMOVED")
  EventListener:RegisterEvent("GARRISON_FOLLOWER_ADDED")
  EventListener:RegisterEvent("GARRISON_UPDATE")
  EventListener:RegisterEvent("PLAYER_TARGET_CHANGED")
  EventListener:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
  EventListener:RegisterEvent("UNIT_HEALTH")
  EventListener:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
  EventListener:RegisterEvent("PLAYER_REGEN_ENABLED")
  EventListener:RegisterEvent("PLAYER_ENTERING_WORLD")
  EventListener:RegisterEvent("ZONE_CHANGED_NEW_AREA")
  EventListener:RegisterUnitEvent("UNIT_AURA", "player")

  hooksecurefunc(StaticPopupDialogs.GOSSIP_CONFIRM, "OnAccept", _hook_GOSSIP_CONFIRM)
end

BodyGuard:RefreshData()
MOD.BodyGuard = BodyGuard;
