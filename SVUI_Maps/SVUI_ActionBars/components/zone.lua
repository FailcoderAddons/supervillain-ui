--[[
##########################################################
S V U I   By: Failcoder
##########################################################
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local unpack 	= _G.unpack;
local select 	= _G.select;
local pairs 	= _G.pairs;
local string 	= _G.string;
local math 		= _G.math;
--[[ STRING METHODS ]]--
local find, format, split = string.find, string.format, string.split;
local gsub = string.gsub;
--[[ MATH METHODS ]]--
local ceil = math.ceil;
--BLIZZARD API
local PickupSpell       = _G.PickupSpell;
local GetSpellInfo      = _G.GetSpellInfo;
local GetSpellCharges   = _G.GetSpellCharges;
local GetSpellCooldown  = _G.GetSpellCooldown;
local GetTime           = _G.GetTime;
local SpellHasRange     = _G.SpellHasRange;
local GetBindingKey     = _G.GetBindingKey;
local GetBindingText    = _G.GetBindingText;
local CreateFrame       = _G.CreateFrame;
local InCombatLockdown  = _G.InCombatLockdown;
local GameTooltip       = _G.GameTooltip;
local hooksecurefunc    = _G.hooksecurefunc;
local IsAltKeyDown      = _G.IsAltKeyDown;
local IsShiftKeyDown    = _G.IsShiftKeyDown;
local IsControlKeyDown  = _G.IsControlKeyDown;
local IsModifiedClick   = _G.IsModifiedClick;
local RegisterStateDriver = _G.RegisterStateDriver;
local RANGE_INDICATOR   = _G.RANGE_INDICATOR;
local CooldownFrame_Set = _G.CooldownFrame_Set;
--[[
##########################################################
GET ADDON DATA
##########################################################
]]--
local SV = _G['SVUI']
local L = SV.L;
local MOD = SV.ActionBars;

local NO_ART = SV.NoTexture;
--[[
##########################################################
DRAENOR ZONE BUTTON INTERNALS
##########################################################
]]--
local DraenorButton_OnDrag = function(self)
	if(self.spellID) then
		PickupSpell(DraenorZoneAbilitySpellID);
	end
end

local DraenorButton_OnEvent = function(self, event)
	if(event == "SPELLS_CHANGED") then
		if(not self.baseName) then
			self.baseName = GetSpellInfo(DraenorZoneAbilitySpellID);
		end
		self:UpdateCooldown()
	elseif(event == 'PLAYER_REGEN_ENABLED') then
		self:SetAttribute('spell', self.attribute)
		self:UnregisterEvent(event)
		self:UpdateCooldown()
	elseif(event == 'UPDATE_BINDINGS') then
		if(self:IsShown()) then
			self:SetUsage()
			self:SetAttribute('binding', GetTime())
		end
	else
		self:Update()
	end

	if(not self.baseName) then
		return;
	end

	local lastState = self.BuffSeen;
	self.BuffSeen = HasDraenorZoneAbility();
	local spellName, _, texture, _, _, _, spellID = GetSpellInfo(self.baseName);

	if(self.BuffSeen) then
		if(not HasDraenorZoneSpellOnBar(self)) then
			self:SetUsage(spellID, spellName, texture);
		else
			self:ClearUsage();
		end
	else
		DraenorZoneAbilityFrame.CurrentTexture = texture;
		self:ClearUsage();
	end

	-- if(lastState ~= self.BuffSeen) then
	-- 	UIParent_ManageFramePositions();
	-- 	ActionBarController_UpdateAll(true);
	-- end
end

local DraenorButtonUpdate = function(self)
	if (not self.baseName) then
		return;
	end
	local name, _, tex, _, _, _, spellID = GetSpellInfo(self.baseName);

	DraenorZoneAbilityFrame.CurrentTexture = tex;
	DraenorZoneAbilityFrame.CurrentSpell = name;

	self.Icon:SetTexture(tex);
	self.Artwork:SetTexture(DRAENOR_ZONE_SPELL_ABILITY_TEXTURES_BASE[spellID])

	local charges, maxCharges, chargeStart, chargeDuration = GetSpellCharges(spellID);
	local usesCharges = false;
	if(self.Count) then
		if(maxCharges and maxCharges > 1) then
			self.Count:SetText(charges);
			usesCharges = true;
		else
			self.Count:SetText("");
		end
	end

	local start, duration, enable = GetSpellCooldown(name);

	if(usesCharges and charges < maxCharges) then
		CooldownFrame_Set(self.Cooldown, chargeStart, chargeDuration, enable, charges, maxCharges);
	elseif(start) then
		CooldownFrame_Set(self.Cooldown, start, duration, enable);
	end

	self.spellName = name;
	self.spellID = spellID;
end
--[[
##########################################################
ZONE BUTTON CONSTRUCT
##########################################################
]]--
local UpdateSpellCooldown = function(self)
    if(self:IsShown() and self.spellName) then
        local start, duration, enable = GetSpellCooldown(self.spellName)
        if((start and start > 0) and (duration and duration > 0)) then
            self.Cooldown:SetCooldown(start, duration)
            self.Cooldown:Show()
        else
            self.Cooldown:Hide()
        end
    end
end

local SpellButton_OnEnter = function(self)
    if(self.spellID) then
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT')
        GameTooltip:SetSpellByID(self.spellID)
    end
end

local ButtonSpell_OnEvent = function(self, event)
    if(event == 'PLAYER_REGEN_ENABLED') then
        self:SetAttribute('spell', self.attribute)
        self:UnregisterEvent(event)
        self:UpdateCooldown()
    elseif(event == 'UPDATE_BINDINGS') then
        if(self:IsShown()) then
            self:SetUsage()
            self:SetAttribute('binding', GetTime())
        end
    else
        self:Update()
    end
end

local SetButtonSpell = function(self, spellID, spellName, texture)
    if(spellID and spellName) then
        if(spellID == self.spellID and self:IsShown()) then
            return false
        end

        self.Icon:SetTexture(texture)
        self.spellID = spellID
        self.spellName = spellName
    end

    local HotKey = self.HotKey
    local key = GetBindingKey('SVUI_DRAENORZONE')
    if(key) then
        HotKey:SetText(GetBindingText(key, 1))
        HotKey:Show()
    elseif(self.spellName and SpellHasRange(self.spellName)) then
        HotKey:SetText(RANGE_INDICATOR)
        HotKey:Show()
    else
        HotKey:Hide()
    end

    if(InCombatLockdown()) then
        self.attribute = self.spellName
        self:RegisterEvent('PLAYER_REGEN_ENABLED')
    else
        self:SetAttribute('spell', self.spellName)
        self:UpdateCooldown()
    end

    self:FadeIn()
end

local ClearButtonSpell = function(self)
    self:FadeOut()
    if(InCombatLockdown()) then
        self.attribute = nil;
        self:RegisterEvent('PLAYER_REGEN_ENABLED');
    else
        self:SetAttribute('spell', nil);
    end
end
--[[
##########################################################
PACKAGE CALL
##########################################################
]]--
function MOD:InitializeZoneButton()
if(not DraenorZoneAbilityFrame) then return end;
	local size = SVUI_DraenorButtonHolder:GetHeight()
    local draenor = CreateFrame('Button', "SVUI_DraenorZoneAbility", UIParent, 'SecureActionButtonTemplate, SecureHandlerStateTemplate, SecureHandlerAttributeTemplate');
    draenor:SetSize(size,size);
    draenor:SetPoint("CENTER", SVUI_DraenorButtonHolder, "CENTER", 0, 0);
    draenor:SetAlpha(0);
    draenor:SetStyle("!_ActionSlot");

    draenor.SetUsage = SetButtonSpell;
    draenor.ClearUsage = ClearButtonSpell;
    draenor.UpdateCooldown = UpdateSpellCooldown;
    draenor.Update = DraenorButtonUpdate

    local texture = DraenorZoneAbilityFrame.SpellButton.Style:GetTexture();
    if(SV.Allegiance == 'Horde') then
        texture = "Interface\\ExtraButton\\GarrZoneAbility-BarracksHorde";
    end

    local Artwork = draenor.Panel:CreateTexture('$parentArtwork', 'BACKGROUND')
    Artwork:SetPoint('CENTER', -2, 2)
    Artwork:SetSize(size * 4.2, size * 2.1)
    Artwork:SetTexture(texture)
    draenor.Artwork = Artwork

    local Icon = draenor:CreateTexture('$parentIcon', 'BACKGROUND')
    Icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
    Icon:SetAllPoints()
    draenor.Icon = Icon

    local HotKey = draenor:CreateFontString('$parentHotKey', nil, 'NumberFontNormal')
    HotKey:SetPoint('BOTTOMRIGHT', -5, 5)
    draenor.HotKey = HotKey

    local Cooldown = CreateFrame('Cooldown', '$parentCooldown', draenor, 'CooldownFrameTemplate')
    Cooldown:ClearAllPoints()
    Cooldown:SetPoint('TOPRIGHT', -2, -3)
    Cooldown:SetPoint('BOTTOMLEFT', 2, 1)
    Cooldown:Hide()
    draenor.Cooldown = Cooldown

    RegisterStateDriver(draenor, 'visible', '[petbattle] hide; show')
    draenor:SetAttribute('type', 'spell');
    draenor:SetAttribute('_onattributechanged', [[
        if(name == 'spell') then
            if(value and not self:IsShown()) then
                self:Show()
            elseif(not value) then
                self:Hide()
            end
        elseif(name == 'state-visible') then
            if(value == 'show') then
                self:CallMethod('Update')
            else
                self:Hide()
            end
        end

        if(self:IsShown() and (name == 'item' or name == 'binding')) then
			self:ClearBindings()
			local key = GetBindingKey('SVUI_DRAENORZONE')
			if(key) then
				self:SetBindingClick(1, key, self, 'LeftButton')
			end
		end
    ]]);

  draenor:SetScript('OnEnter', SpellButton_OnEnter);
  draenor:SetScript('OnLeave', GameTooltip_Hide);
	draenor:RegisterForDrag("LeftButton");
	draenor:SetScript('OnDragStart', DraenorButton_OnDrag);

	draenor:RegisterUnitEvent("UNIT_AURA", "player");
	draenor:RegisterEvent("SPELL_UPDATE_COOLDOWN");
	draenor:RegisterEvent("SPELL_UPDATE_USABLE");
	draenor:RegisterEvent("SPELL_UPDATE_CHARGES");
	draenor:RegisterEvent("SPELLS_CHANGED");
	draenor:RegisterEvent("ACTIONBAR_SLOT_CHANGED");
	draenor:RegisterEvent("UPDATE_BINDINGS");
    draenor:SetScript('OnEvent', DraenorButton_OnEvent);

    SV:NewAnchor(draenor, L["Zone Ability Button"]);

	DraenorZoneAbilityFrame:UnregisterAllEvents()
end
