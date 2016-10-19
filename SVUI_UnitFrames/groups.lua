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
local CreateFrame           = _G.CreateFrame;
local InCombatLockdown      = _G.InCombatLockdown;

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

local RegisterUnitWatch     = _G.RegisterUnitWatch;
local UnregisterUnitWatch   = _G.UnregisterUnitWatch;
local FACTION_BAR_COLORS    = _G.FACTION_BAR_COLORS;
local RAID_CLASS_COLORS     = _G.RAID_CLASS_COLORS
--[[
##########################################################
LOCAL DATA
##########################################################
]]--
local GroupCounts = {
    ['raid'] = 8,
    ['raidpet'] = 2,
    ['party'] = 1
};

local sortMapping = {
    ["DOWN_RIGHT"]  = { [1] = "TOP",    [2] = "TOPLEFT",        [3] = "LEFT",   [4] = 1,    [5] = -1,   [6] = false },
    ["DOWN_LEFT"]   = { [1] = "TOP",    [2] = "TOPRIGHT",       [3] = "RIGHT",  [4] = 1,    [5] = -1,   [6] = false },
    ["UP_RIGHT"]    = { [1] = "BOTTOM", [2] = "BOTTOMLEFT",     [3] = "LEFT",   [4] = 1,    [5] = 1,    [6] = false },
    ["UP_LEFT"]     = { [1] = "BOTTOM", [2] = "BOTTOMRIGHT",    [3] = "RIGHT",  [4] = -1,   [5] = 1,    [6] = false },
    ["RIGHT_DOWN"]  = { [1] = "LEFT",   [2] = "TOPLEFT",        [3] = "TOP",    [4] = 1,    [5] = -1,   [6] = true  },
    ["RIGHT_UP"]    = { [1] = "LEFT",   [2] = "BOTTOMLEFT",     [3] = "BOTTOM", [4] = 1,    [5] = 1,    [6] = true  },
    ["LEFT_DOWN"]   = { [1] = "RIGHT",  [2] = "TOPRIGHT",       [3] = "TOP",    [4] = -1,   [5] = -1,   [6] = true  },
    ["LEFT_UP"]     = { [1] = "RIGHT",  [2] = "BOTTOMRIGHT",    [3] = "BOTTOM", [4] = -1,   [5] = 1,    [6] = true  },
    ["UP"]          = { [1] = "BOTTOM", [2] = "BOTTOM",         [3] = "BOTTOM", [4] = 1,    [5] = 1,    [6] = false },
    ["DOWN"]        = { [1] = "TOP",    [2] = "TOP",            [3] = "TOP",    [4] = 1,    [5] = 1,    [6] = false },
};

local groupTagPoints = {
    ["DOWN_RIGHT"]  = { [1] = "BOTTOM",     [2] = "TOP",        [3] = 1     },
    ["DOWN_LEFT"]   = { [1] = "BOTTOM",     [2] = "TOP",        [3] = 1     },
    ["UP_RIGHT"]    = { [1] = "TOP",        [2] = "BOTTOM",     [3] = -1    },
    ["UP_LEFT"]     = { [1] = "TOP",        [2] = "BOTTOM",     [3] = -1    },
    ["RIGHT_DOWN"]  = { [1] = "RIGHT",      [2] = "LEFT",       [3] = -1    },
    ["RIGHT_UP"]    = { [1] = "RIGHT",      [2] = "LEFT",       [3] = -1    },
    ["LEFT_DOWN"]   = { [1] = "LEFT",       [2] = "RIGHT",      [3] = 1     },
    ["LEFT_UP"]     = { [1] = "LEFT",       [2] = "RIGHT",      [3] = 1     },
    ["UP"]          = { [1] = "TOP",        [2] = "BOTTOM",     [3] = -1    },
    ["DOWN"]        = { [1] = "BOTTOM",     [2] = "TOP",        [3] = 1     },
};

local GroupDistributor = {
    ["CLASS"] = function(x)
        x:SetAttribute("groupingOrder","DEATHKNIGHT,DRUID,HUNTER,MAGE,PALADIN,PRIEST,SHAMAN,WARLOCK,WARRIOR,MONK")
        x:SetAttribute("sortMethod","NAME")
        x:SetAttribute("groupBy","CLASS")
    end,
    ["MTMA"] = function(x)
        x:SetAttribute("groupingOrder","MAINTANK,MAINASSIST,NONE")
        x:SetAttribute("sortMethod","NAME")
        x:SetAttribute("groupBy","ROLE")
    end,
    ["ROLE_TDH"] = function(x)
        x:SetAttribute("groupingOrder","TANK,DAMAGER,HEALER,NONE")
        x:SetAttribute("sortMethod","NAME")
        x:SetAttribute("groupBy","ASSIGNEDROLE")
    end,
    ["ROLE_HTD"] = function(x)
        x:SetAttribute("groupingOrder","HEALER,TANK,DAMAGER,NONE")
        x:SetAttribute("sortMethod","NAME")
        x:SetAttribute("groupBy","ASSIGNEDROLE")
    end,
    ["ROLE_HDT"] = function(x)
        x:SetAttribute("groupingOrder","HEALER,DAMAGER,TANK,NONE")
        x:SetAttribute("sortMethod","NAME")
        x:SetAttribute("groupBy","ASSIGNEDROLE")
    end,
    ["ROLE"] = function(x)
        x:SetAttribute("groupingOrder","TANK,HEALER,DAMAGER,NONE")
        x:SetAttribute("sortMethod","NAME")
        x:SetAttribute("groupBy","ASSIGNEDROLE")
    end,
    ["NAME"] = function(x)
        x:SetAttribute("groupingOrder","1,2,3,4,5,6,7,8")
        x:SetAttribute("sortMethod","NAME")
        x:SetAttribute("groupBy",nil)
    end,
    ["GROUP"] = function(x)
        x:SetAttribute("groupingOrder","1,2,3,4,5,6,7,8")
        x:SetAttribute("sortMethod","INDEX")
        x:SetAttribute("groupBy","GROUP")
    end,
    ["PETNAME"] = function(x)
        x:SetAttribute("groupingOrder","1,2,3,4,5,6,7,8")
        x:SetAttribute("sortMethod","NAME")
        x:SetAttribute("groupBy", nil)
        x:SetAttribute("filterOnPet", true)
    end
}
--[[
##########################################################
FRAME HELPERS
##########################################################
]]--
local groupLayoutPostSizeFunc = function(self, width, height)
    if(not SV.db.UnitFrames[self.___key]) then return end;
    SV.db.UnitFrames[self.___key].width = width;
    SV.db.UnitFrames[self.___key].height = height;
    self:Update()
end

local DetachSubFrames = function(...)
    for i = 1, select("#", ...) do
        local frame = select(i,...)
        frame:ClearAllPoints()
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
--[[
##########################################################
TEMPLATES AND PROTOTYPES
##########################################################
]]--
local BuildTemplates = {};
local UpdateTemplates = {};
--[[
##########################################################
COMMON
##########################################################
]]--
local PARTY_VIS1 = "[group:party,nogroup:raid] show;hide";
local PARTY_VIS2 = "[group:party,nogroup:raid][@raid6,noexists,group:raid] show;hide";
local RAID_VIS1 = "[group:raid] show;hide";
local RAID_VIS2 = "[@raid6,exists,group:raid] show;hide";
local VISIBILITY_OPTIONS = { party = PARTY_VIS1, raid = RAID_VIS1 };

local Update5ManVisibility = function(token)
    local partyVis = "[group:party,nogroup:raid] show;hide";
    local raidVis = "[group:raid] show;hide";

    if(SV.db.UnitFrames.party.useFor5man) then
        VISIBILITY_OPTIONS.party = PARTY_VIS2;
        VISIBILITY_OPTIONS.raid = RAID_VIS2;
    else
        VISIBILITY_OPTIONS.party = PARTY_VIS1;
        VISIBILITY_OPTIONS.raid = RAID_VIS1;
    end

    SV.db.UnitFrames.party.visibility = VISIBILITY_OPTIONS.party
    SV.db.UnitFrames.raid.visibility = VISIBILITY_OPTIONS.raid

    if(token) then
        return VISIBILITY_OPTIONS[token] or "";
    end
end

local AllowElement = function(self)
    if InCombatLockdown() then return; end

    if not self.isForced then
        self.sourceElement = self.unit;
        self.unit = "player"
        self.isForced = true;
        self.sourceEvent = self:GetScript("OnUpdate")
    end

    self:SetScript("OnUpdate", nil)
    --self.forceShowAuras = true;
    UnregisterUnitWatch(self)
    RegisterUnitWatch(self, true)

    self:Show()
    if self:IsVisible() and self.Update then
        self:Update()
    end
end

local RestrictElement = function(self)
    if(InCombatLockdown() or (not self.isForced)) then return; end

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
PARTY FRAMES
##########################################################
]]--
local PartyUnitUpdate = function(self)
    local db = SV.db.UnitFrames.party
    self.colors = oUF_SVUI.colors;
    self:RegisterForClicks(SV.db.UnitFrames.fastClickTarget and 'AnyDown' or 'AnyUp')
    MOD.RefreshUnitMedia(self, "party")

    if self.isChild then
      local altDB = db.petsGroup;
      if self == _G[self.originalParent:GetName()..'Target'] then
          altDB = db.targetsGroup
      end
      if not self.originalParent.childList then
          self.originalParent.childList = {}
      end
      self.originalParent.childList[self] = true;
      if not InCombatLockdown()then
        if altDB.enable then
            local UNIT_WIDTH, UNIT_HEIGHT = MOD:GetActiveSize(altDB)
            self:SetParent(self.originalParent)
            self:SetSize(UNIT_WIDTH, UNIT_HEIGHT)
            self:ClearAllPoints()
            SV:SetReversePoint(self, altDB.anchorPoint, self.originalParent, altDB.xOffset, altDB.yOffset)
        else
            self:SetParent(SV.Hidden)
        end
      end
      do
          local health = self.Health;
          health.Smooth = nil;
          health.frequentUpdates = nil;
          health.colorSmooth = nil;
          health.colorHealth = nil;
          health.colorClass = true;
          health.colorReaction = true;
          health:ClearAllPoints()
          health:SetPoint("TOPRIGHT", self, "TOPRIGHT", -1, -1)
          health:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 1, 1)
      end
      do
          local nametext = self.TextGrip.Name
          self:Tag(nametext, altDB.tags)
      end
    else
        if not InCombatLockdown() then
            local UNIT_WIDTH, UNIT_HEIGHT = MOD:GetActiveSize(db, "party")
            self:SetSize(UNIT_WIDTH, UNIT_HEIGHT)
        end
        MOD:RefreshUnitLayout(self, "party")
    end
    self:EnableElement('ReadyCheck')
    self:UpdateAllElements()
end

UpdateTemplates["party"] = function(self)
    if(SV.NeedsFrameAudit) then return end
    local visibility = Update5ManVisibility("party")
    local db = SV.db.UnitFrames.party
    local groupFrame = self:GetParent()
    if not self.isForced then
        RegisterStateDriver(groupFrame, "visibility", visibility)
    end

    if not groupFrame.positioned then
        groupFrame:ClearAllPoints()
        groupFrame:SetPoint("BOTTOMLEFT", SV.Dock.BottomLeft, "TOPLEFT", 0, 80)
        SV:NewAnchor(groupFrame, L['Party Frames']);
        SV:SetAnchorResizing(groupFrame, groupLayoutPostSizeFunc, 10, 500)
        groupFrame.positioned = true;
    end

    local index = 1;
    local attIndex = ("child%d"):format(index)
    local childFrame = self:GetAttribute(attIndex)
    local childName, petFrame, targetFrame;

    while childFrame do
        childFrame:UnitUpdate()

        childName = childFrame:GetName()
        petFrame = _G[("%sPet"):format(childName)]
        targetFrame = _G[("%sTarget"):format(childName)]

        if(petFrame) then
            petFrame:UnitUpdate()
        end

        if(targetFrame) then
            targetFrame:UnitUpdate()
        end

        index = index + 1;
        attIndex = ("child%d"):format(index)
        childFrame = self:GetAttribute(attIndex)
    end
end

BuildTemplates["party"] = function(self, unit)
    self.unit = unit
    self.___key = "party"
    self:SetScript("OnEnter", UnitFrame_OnEnter)
    self:SetScript("OnLeave", UnitFrame_OnLeave)

    MOD:SetActionPanel(self, "party")
    self.Health = MOD:CreateHealthBar(self, true)
    self.Health.debug = true
    if self.isChild then
        self.originalParent = self:GetParent()
        MOD:CreatePortrait(self, true)
    else
        self.Power = MOD:CreatePowerBar(self)
        self.Power.frequentUpdates = false
        MOD:CreatePortrait(self, true)
        MOD:CreateAuraFrames(self, "party")
        self.AuraWatch = MOD:CreateAuraWatch(self, "party")
        self.RaidDebuffs = MOD:CreateRaidDebuffs(self)
        self.Afflicted = MOD:CreateAfflicted(self)
        self.ResurrectIcon = MOD:CreateResurectionIcon(self)
        self.LFDRole = MOD:CreateRoleIcon(self)
        self.RaidRoleFramesAnchor = MOD:CreateRaidRoleFrames(self)
        self.RaidIcon = MOD:CreateRaidIcon(self)
        self.ReadyCheck = MOD:CreateReadyCheckIcon(self)
        self.HealPrediction = MOD:CreateHealPrediction(self)
        self.TargetGlow = self.Threat
        tinsert(self.__elements, UpdateTargetGlow)
        self:RegisterEvent("PLAYER_TARGET_CHANGED", UpdateTargetGlow)
        self:RegisterEvent("PLAYER_ENTERING_WORLD", UpdateTargetGlow)
        self:RegisterEvent("GROUP_ROSTER_UPDATE", UpdateTargetGlow)
    end

    self.Range = { insideAlpha = 1, outsideAlpha = 1 }

    self.Restrict = RestrictElement
    self.Allow = AllowElement
    self.UnitUpdate = PartyUnitUpdate

    return self
end
--[[
##########################################################
RAID FRAMES
##########################################################
]]--
local RaidUnitUpdate = function(self)
    local token = self.___key
    local db = SV.db.UnitFrames[token]
    self.colors = oUF_SVUI.colors;
    self:RegisterForClicks(SV.db.UnitFrames.fastClickTarget and "AnyDown" or "AnyUp")

    local UNIT_WIDTH, UNIT_HEIGHT = MOD:GetActiveSize(db)
    if not InCombatLockdown() then
        self:SetSize(UNIT_WIDTH, UNIT_HEIGHT)
    end

    MOD.RefreshUnitMedia(self, token)
    MOD:RefreshUnitLayout(self, token)

    if(token ~= "raidpet") then
        self:EnableElement("ReadyCheck")
    end
    self:UpdateAllElements()
end

UpdateTemplates["raid"] = function(self)
    if(SV.NeedsFrameAudit) then return end
    local visibility = Update5ManVisibility("raid")
    local db = SV.db.UnitFrames.raid
    local groupFrame = self:GetParent()
    if not self.isForced then
        RegisterStateDriver(groupFrame, "visibility", visibility)
    end

    if not groupFrame.positioned then
        groupFrame:ClearAllPoints()
        groupFrame:SetPoint("BOTTOMLEFT", SV.Dock.BottomLeft, "TOPLEFT", 0, 80)
        SV:NewAnchor(groupFrame, "Raid Frames")
        SV:SetAnchorResizing(groupFrame, groupLayoutPostSizeFunc, 10, 500)
        groupFrame.positioned = true
    end

    local index = 1;
    local attIndex = ("child%d"):format(index)
    local childFrame = self:GetAttribute(attIndex)
    local childName, petFrame, targetFrame;

    while childFrame do
        childFrame:UnitUpdate()

        childName = childFrame:GetName()
        petFrame = _G[("%sPet"):format(childName)]
        targetFrame = _G[("%sTarget"):format(childName)]

        if(petFrame) then
            petFrame:UnitUpdate()
        end

        if(targetFrame) then
            targetFrame:UnitUpdate()
        end

        index = index + 1;
        attIndex = ("child%d"):format(index)
        childFrame = self:GetAttribute(attIndex)
    end
end

BuildTemplates["raid"] = function(self, unit)
    self.unit = unit
    self.___key = "raid"
    MOD:SetActionPanel(self, "raid")
    self.Health = MOD:CreateHealthBar(self, true)
    self.Health.frequentUpdates = false
    self.Power = MOD:CreatePowerBar(self)
    self.Power.frequentUpdates = false
    MOD:CreateAuraFrames(self, "raid")
    self.AuraWatch = MOD:CreateAuraWatch(self, "raid")
    self.RaidDebuffs = MOD:CreateRaidDebuffs(self)
    self.Afflicted = MOD:CreateAfflicted(self)
    self.ResurrectIcon = MOD:CreateResurectionIcon(self)
    self.LFDRole = MOD:CreateRoleIcon(self)
    self.RaidRoleFramesAnchor = MOD:CreateRaidRoleFrames(self)
    self.RaidIcon = MOD:CreateRaidIcon(self)
    self.ReadyCheck = MOD:CreateReadyCheckIcon(self)
    self.HealPrediction = MOD:CreateHealPrediction(self)
    self.Range = { insideAlpha = 1, outsideAlpha = 1 }

    self.Restrict = RestrictElement
    self.Allow = AllowElement
    self.UnitUpdate = RaidUnitUpdate
    self.TargetGlow = self.Threat
    tinsert(self.__elements, UpdateTargetGlow)

    self:SetScript("OnEnter", UnitFrame_OnEnter)
    self:SetScript("OnLeave", UnitFrame_OnLeave)
    self:RegisterEvent("PLAYER_TARGET_CHANGED", UpdateTargetGlow)
    self:RegisterEvent("PLAYER_ENTERING_WORLD", UpdateTargetGlow)

    return self
end
--[[
##########################################################
RAID PETS
##########################################################
]]--
UpdateTemplates["raidpet"] = function(self)
    if(SV.NeedsFrameAudit) then return end
    local db = SV.db.UnitFrames.raidpet
    local groupFrame = self:GetParent()

    if not groupFrame.positioned then
        groupFrame:ClearAllPoints()
        groupFrame:SetPoint("BOTTOMLEFT", SV.Screen, "BOTTOMLEFT", 4, 433)
        RegisterStateDriver(groupFrame, "visibility", "[group:raid] show;hide")
        SV:NewAnchor(groupFrame, L["Raid Pet Frames"])
        SV:SetAnchorResizing(groupFrame, groupLayoutPostSizeFunc, 10, 500)
        groupFrame.positioned = true;
    end

    local index = 1;
    local attIndex = ("child%d"):format(index)
    local childFrame = self:GetAttribute(attIndex)
    local childName, petFrame, targetFrame;

    while childFrame do
        childFrame:UnitUpdate()

        childName = childFrame:GetName()
        petFrame = _G[("%sPet"):format(childName)]
        targetFrame = _G[("%sTarget"):format(childName)]

        if(petFrame) then
            petFrame:UnitUpdate()
        end

        if(targetFrame) then
            targetFrame:UnitUpdate()
        end

        index = index + 1;
        attIndex = ("child%d"):format(index)
        childFrame = self:GetAttribute(attIndex)
    end
end

BuildTemplates["raidpet"] = function(self, unit)
    self.unit = unit
    self.___key = "raidpet"
    self:SetScript("OnEnter", UnitFrame_OnEnter)
    self:SetScript("OnLeave", UnitFrame_OnLeave)
    MOD:SetActionPanel(self, "raidpet")
    self.Health = MOD:CreateHealthBar(self, true)
    MOD:CreateAuraFrames(self, "raidpet")
    self.AuraWatch = MOD:CreateAuraWatch(self, "raidpet")
    self.RaidDebuffs = MOD:CreateRaidDebuffs(self)
    self.Afflicted = MOD:CreateAfflicted(self)
    self.RaidIcon = MOD:CreateRaidIcon(self)
    self.Range = { insideAlpha = 1, outsideAlpha = 1 }

    self.Restrict = RestrictElement
    self.Allow = AllowElement
    self.UnitUpdate = RaidUnitUpdate

    self.TargetGlow = self.Threat
    tinsert(self.__elements, UpdateTargetGlow)

    self:RegisterEvent("PLAYER_TARGET_CHANGED", UpdateTargetGlow)
    self:RegisterEvent("PLAYER_ENTERING_WORLD", UpdateTargetGlow)
    return self
end
--[[
##########################################################
TANK
##########################################################
]]--
local TankUnitUpdate = function(self)
    local db = SV.db.UnitFrames.tank
    self.colors = oUF_SVUI.colors;
    self:RegisterForClicks(SV.db.UnitFrames.fastClickTarget and "AnyDown" or "AnyUp")
    MOD.RefreshUnitMedia(self, "tank")
    if self.isChild and self.originalParent then
        local targets = db.targetsGroup;
        if not self.originalParent.childList then
            self.originalParent.childList = {}
        end
        self.originalParent.childList[self] = true;
        if not InCombatLockdown()then
            if targets.enable then
                local UNIT_WIDTH, UNIT_HEIGHT = MOD:GetActiveSize(targets)
                self:SetParent(self.originalParent)
                self:SetSize(UNIT_WIDTH, UNIT_HEIGHT)
                self:ClearAllPoints()
                SV:SetReversePoint(self, targets.anchorPoint, self.originalParent, targets.xOffset, targets.yOffset)
            else
                self:SetParent(SV.Hidden)
            end
        end
    elseif not InCombatLockdown() then
        local UNIT_WIDTH, UNIT_HEIGHT = MOD:GetActiveSize(db)
        self:SetSize(UNIT_WIDTH, UNIT_HEIGHT)
    end
    MOD:RefreshUnitLayout(self, "tank")
    do
        local nametext = self.TextGrip.Name;
        if oUF_SVUI.colors.healthclass then
            self:Tag(nametext, "[name:10]")
        else
            self:Tag(nametext, "[name:color][name:10]")
        end
    end
    self:UpdateAllElements()
end

UpdateTemplates["tank"] = function(self)
    if(SV.NeedsFrameAudit) then return end
    local db = SV.db.UnitFrames.tank

    if db.enable ~= true then
        UnregisterAttributeDriver(self, "state-visibility")
        self:Hide()
        return
    end

    self:Hide()
    DetachSubFrames(self:GetChildren())
    self:SetAttribute("startingIndex", -1)
    RegisterAttributeDriver(self, "state-visibility", "show")
    self.dirtyWidth, self.dirtyHeight = self:GetSize()
    RegisterAttributeDriver(self, "state-visibility", "[group:raid] show;hide")
    self:SetAttribute("startingIndex", 1)
    self:SetAttribute("point", "BOTTOM")
    self:SetAttribute("columnAnchorPoint", "LEFT")
    DetachSubFrames(self:GetChildren())
    self:SetAttribute("yOffset", 7)

    if not self.positioned then
        self:ClearAllPoints()
        self:SetPoint("BOTTOMLEFT", SV.Dock.TopLeft, "BOTTOMLEFT", 0, 0)
        SV:NewAnchor(self, L["Tank Frames"])
        SV:SetAnchorResizing(self, groupLayoutPostSizeFunc, 10, 500)
        self.Grip.positionOverride = "TOPLEFT"
        self:SetAttribute("minHeight", self.dirtyHeight)
        self:SetAttribute("minWidth", self.dirtyWidth)
        self.positioned = true
    end

    local childFrame, childName, petFrame, targetFrame
    for i = 1, self:GetNumChildren() do
        childFrame = select(i, self:GetChildren())
        childFrame:UnitUpdate()

        childName = childFrame:GetName()
        petFrame = _G[("%sPet"):format(childName)]
        targetFrame = _G[("%sTarget"):format(childName)]

        if(petFrame) then
            petFrame:UnitUpdate()
        end
        if(targetFrame) then
            targetFrame:UnitUpdate()
        end
    end
end

BuildTemplates["tank"] = function(self, unit)
    local db = SV.db.UnitFrames.tank
    self.unit = unit
    self.___key = "tank"
    self:SetScript("OnEnter", UnitFrame_OnEnter)
    self:SetScript("OnLeave", UnitFrame_OnLeave)
    MOD:SetActionPanel(self, "tank")
    self.Health = MOD:CreateHealthBar(self, true)
    self.RaidIcon = MOD:CreateRaidIcon(self)
    self.RaidIcon:SetPoint("BOTTOMRIGHT")

    self.Restrict = RestrictElement
    self.Allow = AllowElement
    self.UnitUpdate = TankUnitUpdate

    self.Range = { insideAlpha = 1, outsideAlpha = 1 }
    self.originalParent = self:GetParent()

    self:UnitUpdate()
    return self
end
--[[
##########################################################
ASSIST
##########################################################
]]--
local AssistUnitUpdate = function(self)
    local db = SV.db.UnitFrames.assist
    self.colors = oUF_SVUI.colors;
    self:RegisterForClicks(SV.db.UnitFrames.fastClickTarget and "AnyDown" or "AnyUp")
    MOD.RefreshUnitMedia(self, "assist")
    if self.isChild and self.originalParent then
        local targets = db.targetsGroup;
        if not self.originalParent.childList then
            self.originalParent.childList = {}
        end
        self.originalParent.childList[self] = true;
        if not InCombatLockdown()then
            if targets.enable then
                local UNIT_WIDTH, UNIT_HEIGHT = MOD:GetActiveSize(targets)
                self:SetParent(self.originalParent)
                self:SetSize(UNIT_WIDTH, UNIT_HEIGHT)
                self:ClearAllPoints()
                SV:SetReversePoint(self, targets.anchorPoint, self.originalParent, targets.xOffset, targets.yOffset)
            else
                self:SetParent(SV.Hidden)
            end
        end
    elseif not InCombatLockdown() then
        local UNIT_WIDTH, UNIT_HEIGHT = MOD:GetActiveSize(db)
        self:SetSize(UNIT_WIDTH, UNIT_HEIGHT)
    end

    MOD:RefreshUnitLayout(self, "assist")

    do
        local nametext = self.TextGrip.Name;
        if oUF_SVUI.colors.healthclass then
            self:Tag(nametext, "[name:10]")
        else
            self:Tag(nametext, "[name:color][name:10]")
        end
    end
    self:UpdateAllElements()
end

UpdateTemplates["assist"] = function(self)
    if(SV.NeedsFrameAudit) then return end
    local db = SV.db.UnitFrames.assist

    if db.enable ~= true then
        UnregisterAttributeDriver(self, "state-visibility")
        self:Hide()
        return
    end

    self:Hide()
    DetachSubFrames(self:GetChildren())
    self:SetAttribute("startingIndex", -1)
    RegisterAttributeDriver(self, "state-visibility", "show")
    self.dirtyWidth, self.dirtyHeight = self:GetSize()
    RegisterAttributeDriver(self, "state-visibility", "[group:raid] show;hide")
    self:SetAttribute("startingIndex", 1)
    self:SetAttribute("point", "BOTTOM")
    self:SetAttribute("columnAnchorPoint", "LEFT")
    DetachSubFrames(self:GetChildren())
    self:SetAttribute("yOffset", 7)

    if not self.positioned then
        self:ClearAllPoints()
        self:SetPoint("TOPLEFT", SV.Dock.TopLeft, "BOTTOMLEFT", 0, -10)
        SV:NewAnchor(self, L["Assist Frames"])
        SV:SetAnchorResizing(self, groupLayoutPostSizeFunc, 10, 500)
        self.Grip.positionOverride = "TOPLEFT"
        self:SetAttribute("minHeight", self.dirtyHeight)
        self:SetAttribute("minWidth", self.dirtyWidth)
        self.positioned = true
    end

    local childFrame, childName, petFrame, targetFrame
    for i = 1, self:GetNumChildren() do
        childFrame = select(i, self:GetChildren())
        childFrame:UnitUpdate()

        childName = childFrame:GetName()
        petFrame = _G[("%sPet"):format(childName)]
        targetFrame = _G[("%sTarget"):format(childName)]

        if(petFrame) then
            petFrame:UnitUpdate()
        end
        if(targetFrame) then
            targetFrame:UnitUpdate()
        end
    end
end

BuildTemplates["assist"] = function(self, unit)
    local db = SV.db.UnitFrames.assist
    self.unit = unit
    self.___key = "assist"
    self:SetScript("OnEnter", UnitFrame_OnEnter)
    self:SetScript("OnLeave", UnitFrame_OnLeave)
    MOD:SetActionPanel(self, "assist")
    self.Health = MOD:CreateHealthBar(self, true)
    self.RaidIcon = MOD:CreateRaidIcon(self)
    self.RaidIcon:SetPoint("BOTTOMRIGHT")
    self.Range = { insideAlpha = 1, outsideAlpha = 1 }

    self.Restrict = RestrictElement
    self.Allow = AllowElement
    self.UnitUpdate = AssistUnitUpdate

    self.originalParent = self:GetParent()

    self:UnitUpdate()
    return self
end
--[[
##########################################################
HEADER CONSTRUCTS
##########################################################
]]--
local HeaderMediaUpdate = function(self)
    local token = self.___groupkey
    local index = 1;
    local attIndex = ("child%d"):format(index)
    local childFrame = self:GetAttribute(attIndex)
    local childName, petFrame, targetFrame;

    while childFrame do
        MOD.RefreshUnitMedia(childFrame, token)

        childName = childFrame:GetName()
        petFrame = _G[("%sPet"):format(childName)]
        targetFrame = _G[("%sTarget"):format(childName)]

        if(petFrame) then
            MOD.RefreshUnitMedia(petFrame, token)
        end

        if(targetFrame) then
            MOD.RefreshUnitMedia(targetFrame, token)
        end

        index = index + 1;
        attIndex = ("child%d"):format(index)
        childFrame = self:GetAttribute(attIndex)
    end
end

local HeaderUnsetAttributes = function(self)
    self:Hide()
    self:SetAttribute("showPlayer", true)
    self:SetAttribute("showSolo", true)
    self:SetAttribute("showParty", true)
    self:SetAttribute("showRaid", true)
    self:SetAttribute("columnSpacing", nil)
    self:SetAttribute("columnAnchorPoint", nil)
    self:SetAttribute("sortMethod", nil)
    self:SetAttribute("groupFilter", nil)
    self:SetAttribute("groupingOrder", nil)
    self:SetAttribute("maxColumns", nil)
    self:SetAttribute("nameList", nil)
    self:SetAttribute("point", nil)
    self:SetAttribute("sortDirection", nil)
    self:SetAttribute("sortMethod", "NAME")
    self:SetAttribute("startingIndex", nil)
    self:SetAttribute("strictFiltering", nil)
    self:SetAttribute("unitsPerColumn", nil)
    self:SetAttribute("xOffset", nil)
    self:SetAttribute("yOffset", nil)
end

local HeaderEnableChildren = function(self)
    self.isForced = true;
    for i=1, select("#", self:GetChildren()) do
        local childFrame = select(i, self:GetChildren())
        if(childFrame and childFrame.RegisterForClicks) then
            childFrame:RegisterForClicks(nil)
            childFrame:SetID(i)
            childFrame.TargetGlow:SetAlpha(0)
            childFrame:Allow()
        end
    end
end

local HeaderDisableChildren = function(self)
    self.isForced = nil;
    for i=1, select("#", self:GetChildren()) do
        local childFrame = select(i, self:GetChildren())
        if(childFrame and childFrame.RegisterForClicks) then
            childFrame:RegisterForClicks(SV.db.UnitFrames.fastClickTarget and 'AnyDown' or 'AnyUp')
            childFrame.TargetGlow:SetAlpha(1)
            childFrame:Restrict()
        end
    end
end

function MOD:SetGroupHeader(parentFrame, filter, layout, headerName, token, groupTag)
    local db = SV.db.UnitFrames[token]

    local template1, template2
    if(token == "raidpet") then
        template1 = "SVUI_UNITPET"
        template2 = "SecureGroupPetHeaderTemplate"
    elseif(token == "party") then
        template1 = "SVUI_UNITPET, SVUI_UNITTARGET"
    elseif(token == "tank") then
        filter = "MAINTANK"
        template1 = "SVUI_UNITTARGET"
    elseif(token == "assist") then
        filter = "MAINASSIST"
        template1 = "SVUI_UNITTARGET"
    end

    local UNIT_WIDTH, UNIT_HEIGHT = self:GetActiveSize(db)
    local groupHeader = oUF_SVUI:SpawnHeader(headerName, template2, nil,
        "oUF-initialConfigFunction", ("self:SetWidth(%d); self:SetHeight(%d); self:SetFrameLevel(5)"):format(UNIT_WIDTH, UNIT_HEIGHT),
        "groupFilter", filter,
        "showParty", true,
        "showRaid", true,
        "showSolo", true,
        template1 and "template", template1
    )
    groupHeader.___groupkey = token;
    groupHeader:SetParent(parentFrame);
    groupHeader.Update = UpdateTemplates[token];
    groupHeader.MediaUpdate = HeaderMediaUpdate;
    groupHeader.UnsetAttributes = HeaderUnsetAttributes;
    groupHeader.EnableChildren = HeaderEnableChildren;
    groupHeader.DisableChildren = HeaderDisableChildren;

    if(groupTag) then
        local icon = MOD.media.groupNumbers[groupTag]
        local tag = CreateFrame("Frame", nil, groupHeader);
        tag:SetSize(16,16)
        tag:SetPoint('RIGHT', groupHeader, 'LEFT', -10, 0)
        tag.Icon = tag:CreateTexture(nil, 'BORDER')
        tag.Icon:SetAllPoints(tag)
        tag.Icon:SetTexture(icon)

        groupHeader.GroupTag = tag
    end

    return groupHeader
end
--[[
##########################################################
GROUP CONSTRUCTS
##########################################################
]]--
local GroupUpdate = function(self)
    local token = self.___groupkey
    if SV.db.UnitFrames[token].enable ~= true then
        UnregisterAttributeDriver(self, "state-visibility")
        self:Hide()
        return
    end
    for i=1,#self.groups do
        self.groups[i]:Update()
    end
end

local GroupMediaUpdate = function(self)
    for i=1,#self.groups do
        self.groups[i]:MediaUpdate()
    end
end

local GroupSetVisibility = function(self)
    --print(self.isForced)
    if not self.isForced then
        local token = self.___groupkey
        local db = SV.db.UnitFrames[token]
        if(db) then
            for i=1, #self.groups do
                local frame = self.groups[i]
                if(db.allowedGroup[i]) then
                    frame:Show()
                else
                    if frame.forceShow then
                        frame:Hide()
                        frame:DisableChildren()
                        frame:SetAttribute('startingIndex',1)
                    else
                        frame:UnsetAttributes()
                    end
                end
            end
        end
    end
end

local GroupConfigure = function(self)
    local token = self.___groupkey
    local groupCount = self.___groupcount
    local settings = SV.db.UnitFrames[token]
    local UNIT_WIDTH, UNIT_HEIGHT = MOD:GetActiveSize(settings)
    local sorting = settings.showBy
    local sortMethod = settings.sortMethod
    local rows, cols, groupIncrement = 0, 1, 0;
    local xLabelCalc, yLabelCalc = 0, 0;
    local point, anchorPoint, columnAnchor, horizontal, vertical, isHorizontal = unpack(sortMapping[sorting]);
    local tagPoint1, tagPoint2, mod = unpack(groupTagPoints[sorting]);

    local groupWidth = (isHorizontal) and ((UNIT_WIDTH + settings.wrapXOffset) * 5) or (UNIT_WIDTH + settings.wrapXOffset);
    local groupHeight = (isHorizontal) and (UNIT_HEIGHT + settings.wrapYOffset) or ((UNIT_HEIGHT + settings.wrapYOffset) * 5);

    self.groupCount = groupCount;

    for i = 1, groupCount do
        local frame = self.groups[i]
        local frameEnabled = true;

        if(frame) then
            if(settings.showBy == "UP") then
                settings.showBy = "UP_RIGHT"
            end

            if(settings.showBy == "DOWN") then
                settings.showBy = "DOWN_RIGHT"
            end

            if(isHorizontal) then
                frame:SetAttribute("xOffset", settings.wrapXOffset * horizontal)
                frame:SetAttribute("yOffset", 0)
                frame:SetAttribute("columnSpacing", settings.wrapYOffset)
            else
                frame:SetAttribute("xOffset", 0)
                frame:SetAttribute("yOffset", settings.wrapYOffset * vertical)
                frame:SetAttribute("columnSpacing", settings.wrapXOffset)
            end

            if(not frame.isForced) then
                if not frame.initialized then
                    frame:SetAttribute("startingIndex", -4)
                    frame:Show()
                    frame.initialized = true
                end
                frame:SetAttribute("startingIndex", 1)
            end

            frame:ClearAllPoints()
            frame:SetAttribute("columnAnchorPoint", columnAnchor)

            DetachSubFrames(frame:GetChildren())

            frame:SetAttribute("point", point)

            if(not frame.isForced) then
                frame:SetAttribute("maxColumns", 1)
                frame:SetAttribute("unitsPerColumn", 5)
                GroupDistributor[sortMethod](frame)
                frame:SetAttribute("sortDirection", settings.sortDir)
                frame:SetAttribute("showPlayer", settings.showPlayer)
            end

            frame:SetAttribute("groupFilter", tostring(i))

            if(frame.GroupTag) then
                if(settings.showGroupNumber) then
                    local x,y = 0,0;
                    local size = settings.height * 0.75;
                    if(isHorizontal) then
                        x,y = (4 * mod),0;
                        xLabelCalc = size + 4
                    else
                        x,y = 0,(4 * mod);
                        yLabelCalc = size + 4
                    end
                    frame.GroupTag:Show()
                    frame.GroupTag:SetSize(size, size)
                    frame.GroupTag:SetPoint(tagPoint1, frame, tagPoint2, x, y)
                else
                    frame.GroupTag:Hide()
                end
            end

            if(not settings.allowedGroup[i]) then
                frame:Hide()
                frameEnabled = false;
            else
                frame:Show()
            end
        end

        if(frameEnabled) then
            local yIncrementOffset,xIncrementOffset = 0,0;
            if(groupIncrement == 0) then
                rows = rows + 1;
                cols = 1;
                xIncrementOffset = xLabelCalc;
                yIncrementOffset = yLabelCalc;
            elseif(isHorizontal) then
                if(groupIncrement % settings.gRowCol == 0) then
                    rows = rows + 1;
                    cols = 1;
                    xIncrementOffset = xLabelCalc;
                    yIncrementOffset = ((groupHeight + yLabelCalc) * (rows - 1));
                else
                    xIncrementOffset = (groupWidth * cols) + (xLabelCalc * (cols + 1));
                    yIncrementOffset = (groupHeight * (rows - 1)) + (yLabelCalc * rows);
                    cols = cols + 1;
                end
            else
                if(groupIncrement % settings.gRowCol == 0) then
                    rows = rows + 1;
                    cols = 1;
                    xIncrementOffset = ((groupWidth + xLabelCalc) * (rows - 1));
                    yIncrementOffset = yLabelCalc;
                else
                    xIncrementOffset = (groupWidth * (rows - 1)) + (xLabelCalc * rows);
                    yIncrementOffset = ((groupHeight * cols) + (yLabelCalc * cols)) + yLabelCalc;
                    cols = cols + 1;
                end
            end

            groupIncrement = groupIncrement + 1;
            frame:ClearAllPoints()
            frame:SetPoint(anchorPoint, self, anchorPoint, (xIncrementOffset * horizontal), (yIncrementOffset * vertical));
        end
    end

    if(isHorizontal) then
        local w = ((groupWidth + xLabelCalc) * settings.gRowCol) - settings.wrapXOffset;
        local h = ((groupHeight + yLabelCalc) * rows) - settings.wrapYOffset;
        self:SetSize(w, h)
    else
        local w = ((groupWidth + xLabelCalc) * rows) - settings.wrapXOffset;
        local h = ((groupHeight + yLabelCalc) * settings.gRowCol) - settings.wrapYOffset;
        self:SetSize(w, h)
    end
end

function MOD:GetGroupFrame(token, layout)
    if(not self.Headers[token]) then
        oUF_SVUI:RegisterStyle(layout, BuildTemplates[token])
        oUF_SVUI:SetActiveStyle(layout)
        local groupFrame = CreateFrame("Frame", layout, _G.SVUI_UnitFrameParent, "SecureHandlerStateTemplate")
        groupFrame.___groupkey = token;
        groupFrame.___groupcount = GroupCounts[token] or 1
        groupFrame.groups = {}
        groupFrame.Update = GroupUpdate
        groupFrame.MediaUpdate = GroupMediaUpdate
        groupFrame.SetVisibility = GroupSetVisibility
        groupFrame.Configure = GroupConfigure

        groupFrame:Show()
        self.Headers[token] = groupFrame
    end
    return self.Headers[token]
end

function MOD:SetCustomFrame(token, layout)
    if(not self.Headers[token]) then
        oUF_SVUI:RegisterStyle(layout, BuildTemplates[token])
        oUF_SVUI:SetActiveStyle(layout)
        local groupFrame = self:SetGroupHeader(_G.SVUI_UnitFrameParent, nil, layout, layout, token)
        self.Headers[token] = groupFrame
    end
    self.Headers[token]:Show()
    self.Headers[token]:Update()
end

function MOD:SetGroupFrame(token, forceUpdate)
    if(InCombatLockdown()) then self:RegisterEvent("PLAYER_REGEN_ENABLED"); return end
    Update5ManVisibility()
    local settings = SV.db.UnitFrames[token]
    local realName = token:gsub("(.)", upper, 1)
    local layout = "SVUI_"..realName

    if(token == "tank" or token == "assist") then
        return self:SetCustomFrame(token, layout)
    end

    local groupFrame = self:GetGroupFrame(token, layout)

    if(token ~= "raidpet" and settings.enable ~= true) then
        UnregisterStateDriver(groupFrame, "visibility")
        groupFrame:Hide()
        return
    end

    local groupCount = GroupCounts[token] or 1
    local groupName;
    for i = 1, groupCount do
        if(not groupFrame.groups[i]) then
            groupName = layout .. "Group" .. i;
            groupFrame.groups[i] = self:SetGroupHeader(groupFrame, i, layout, groupName, token, i)
            --groupFrame.groups[i]:SetStyle("LiteButton")
            groupFrame.groups[i]:Show()
        end
    end

    groupFrame:SetVisibility()

    if(forceUpdate or not groupFrame.Grip) then
        groupFrame:Configure()
        if(not groupFrame.isForced and settings.visibility) then
            RegisterStateDriver(groupFrame, "visibility", settings.visibility)
        end
    else
        groupFrame:Configure()
        groupFrame:Update()
    end

    if(token == "raidpet" and settings.enable ~= true) then
        UnregisterStateDriver(groupFrame, "visibility")
        groupFrame:Hide()
        return
    end
    --print('SetGroupFrame')
end
