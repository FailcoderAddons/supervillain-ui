--[[
  /$$$$$$                                /$$           /$$ /$$$$$$$$ /$$   /$$
 /$$__  $$                              |__/          | $$| $$_____/| $$  / $$
| $$  \__/  /$$$$$$   /$$$$$$   /$$$$$$$ /$$  /$$$$$$ | $$| $$      |  $$/ $$/
|  $$$$$$  /$$__  $$ /$$__  $$ /$$_____/| $$ |____  $$| $$| $$$$$    \  $$$$/
 \____  $$| $$  \ $$| $$$$$$$$| $$      | $$  /$$$$$$$| $$| $$__/     >$$  $$
 /$$  \ $$| $$  | $$| $$_____/| $$      | $$ /$$__  $$| $$| $$       /$$/\  $$
|  $$$$$$/| $$$$$$$/|  $$$$$$$|  $$$$$$$| $$|  $$$$$$$| $$| $$      | $$  \ $$
 \______/ | $$____/  \_______/ \_______/|__/ \_______/|__/|__/      |__/  |__/
          | $$
          | $$
          |__/
--]]

--[[ LOCALIZED GLOBALS ]]--
--GLOBAL NAMESPACE
local _G = getfenv(0);
--LUA
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
--STRING
local string        = _G.string;
local upper         = string.upper;
local format        = string.format;
local find          = string.find;
local match         = string.match;
local gsub          = string.gsub;
--MATH
local math          = _G.math;
local random        = math.random;
local floor         = math.floor
--TABLE
local table         = _G.table;
local tsort         = table.sort;
local tconcat       = table.concat;
local tremove       = _G.tremove;
local twipe         = _G.wipe;

local CreateFrame           = _G.CreateFrame;

--[[ LIB CONSTRUCT ]]--

local lib = Librarian:NewLibrary("SpecialFX")

if not lib then return end

--[[ LIB EFFECT TABLES ]]--

local DEFAULT_MODEL = [[Spells\Missile_bomb.m2]];
local DEFAULT_EFFECT = {DEFAULT_MODEL, 0, 0, 0, 0, 0.75, 0, 0};
local EFFECTS_LIST = setmetatable({
    ["default"]     = {[[Spells\Missile_bomb.m2]], -12, 12, 12, -12, 0.4, 0.125, 0.05},
    ["holy"]        = {[[Spells\Solar_precast_hand.m2]], -12, 12, 12, -12, 0.23, 0, 0},
    ["shadow"]      = {[[Spells\Shadow_precast_uber_hand.m2]], -12, 12, 12, -12, 0.23, -0.1, 0.1},
    ["arcane"]      = {[[Spells\Cast_arcane_01.m2]], -12, 12, 12, -12, 0.25, 0, 0},
    ["fire"]        = {[[Spells\Bloodlust_state_hand.m2]], -8, 4, 24, -24, 0.70, -0.22, 0.22},
    ["frost"]       = {[[Spells\Ice_cast_low_hand.m2]], -12, 12, 12, -12, 0.25, -0.2, -0.35},
    ["chi"]         = {[[Spells\Fel_fire_precast_high_hand.m2]], -12, 12, 12, -12, 0.3, -0.04, -0.1},
    ["lightning"]   = {[[Spells\Fill_lightning_cast_01.m2]], -12, 12, 12, -12, 1.25, 0, 0},
    ["water"]       = {[[Spells\Monk_drunkenhaze_impact.m2]], -12, 12, 12, -12, 0.9, 0, 0},
    ["earth"]       = {[[Spells\Sand_precast_hand.m2]], -12, 12, 12, -12, 0.23, 0, 0},
}, { __index = function(t, k)
  return DEFAULT_EFFECT
end });

local DEFAULT_ROUTINE = {0, 2000};
local MODEL_ROUTINES = setmetatable({
    ["idle"]            = {0, 2000},
    ["walk"]            = {4, 2000},
    ["run"]             = {5, 2000},
    ["attack1"]         = {26, 2000},
    ["falling"]         = {40, 2000},
    ["casting1"]        = {52, 2000},
    ["static_roar"]     = {55, 2000},
    ["chat"]            = {60, 2000},
    ["yell"]            = {64, 2000},
    ["shrug"]           = {65, 2000},
    ["dance"]           = {69, 2000},
    ["roar"]            = {74, 2000},
    ["attack2"]         = {111, 2000},
    ["sneak"]           = {119, 2000},
    ["stealth"]         = {120, 2000},
    ["casting2"]        = {125, 2000},
    ["crafting"]        = {138, 2000},
    ["kneel"]           = {141, 2000},
    ["cannibalize"]     = {203, 2000},
    ["cower"]           = {225, 2000},
}, { __index = function(t, k)
  return DEFAULT_ROUTINE
end });

--[[ CHARACTER MODEL METHODS ]]--

local CharacterModel_OnUpdate = function(self, elapsed)
    if(self.___frameIndex < self.___maxIndex) then
        self.___frameIndex = (self.___frameIndex + (elapsed * 1000));
    else
        self.___frameIndex = 0;
        self:SetAnimation(0);
        self:SetScript("OnUpdate", nil);
    end
end

local CharacterModel_UseAnimation = function(self, animationName)
    animationName = animationName or self.___currentAnimation;
    local effectTable = self.___routines[effectName];
    self.___frameIndex = 0;
    self.___maxIndex = effectTable[2];
    self.___currentAnimation = animationName;
    self:SetAnimation(effectTable[1]);
    self:SetScript("OnUpdate", CharacterModel_OnUpdate);
end

--[[ EFFECT FRAME METHODS ]]--

local EffectModel_SetAnchorParent = function(self, frame)
    self.___anchorParent = frame;
    self:SetEffect(self.currentEffect);
end

local EffectModel_OnShow = function(self)
    self.FX:UpdateEffect();
end

local EffectModel_UpdateEffect = function(self)
    local effect = self.currentEffect;
    local effectTable = self.___fx[effect];
    self:ClearModel();
    self:SetModel(effectTable[1]);
end

local EffectModel_SetEffect = function(self, effectName)
    effectName = effectName or self.currentEffect;
    local effectTable = self.___fx[effectName];
    local parent = self.___anchorParent;
    self:ClearAllPoints();
    self:SetPoint("TOPLEFT", parent, "TOPLEFT", effectTable[2], effectTable[3]);
    self:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", effectTable[4], effectTable[5]);
    self:ClearModel();
    self:SetModel(effectTable[1]);
    self:SetCamDistanceScale(effectTable[6]);
    self:SetPosition(0, effectTable[7], effectTable[8]);
    self:SetPortraitZoom(0);
    self.currentEffect = effectName;
end

--[[ LIB METHODS ]]--

function lib:Register(request, modelFile, leftX, leftY, rightX, rightY, zoom, posX, posY)
    if(type(request) == 'string') then
      request = request:lower();
      modelFile = modelFile or DEFAULT_MODEL;
      leftX = leftX or 0;
      leftY = leftY or 0;
      rightX = rightX or 0;
      rightY = rightY or 0;
      zoom = zoom or 0.75;
      posX = posX or 0;
      posY = posY or 0;
      rawset(EFFECTS_LIST, request, {modelFile, leftX, leftY, rightX, rightY, zoom, posX, posY})
    elseif(request.SetAnimation) then
      request.___routines = {};
      setmetatable(request.___routines, { __index = ANIMATION_IDS });
      request.___frameIndex = 0;
      request.___maxIndex = 2000;
      request.___currentAnimation = "idle";
      request.UseAnimation = CharacterModel_UseAnimation;
    end
end;

function lib:SetFXFrame(parent, defaultEffect, noScript, anchorParent)
    defaultEffect = defaultEffect or "default"
    local model = CreateFrame("PlayerModel", nil, parent);
    model.___fx = {};
    setmetatable(model.___fx, { __index = EFFECTS_LIST });
    model.___anchorParent = anchorParent or parent;
    model.SetEffect = EffectModel_SetEffect;
    model.SetAnchorParent = EffectModel_SetAnchorParent;
    model.UpdateEffect = EffectModel_UpdateEffect;
    model.currentEffect = defaultEffect;
    parent.FX = model;
    --print(defaultEffect)
    EffectModel_SetEffect(model, defaultEffect)

    if(not noScript) then
        if(parent:GetScript("OnShow")) then
            parent:HookScript("OnShow", EffectModel_OnShow)
        else
            parent:SetScript("OnShow", EffectModel_OnShow)
        end
    end
end

--[[ MODEL FILES FOUND FOR EFFECTS ]]--

-- [[Spells\Fel_fire_precast_high_hand.m2]]
-- [[Spells\Fire_precast_high_hand.m2]]
-- [[Spells\Fire_precast_low_hand.m2]]
-- [[Spells\Focused_casting_state.m2]]
-- [[Spells\Fill_holy_cast_01.m2]]
-- [[Spells\Fill_fire_cast_01.m2]]
-- [[Spells\Paladin_healinghands_state_01.m2]]
-- [[Spells\Fill_magma_cast_01.m2]]
-- [[Spells\Fill_shadow_cast_01.m2]]
-- [[Spells\Fill_arcane_precast_01.m2]]
-- [[Spells\Ice_cast_low_hand.m2]]
-- [[Spells\Immolate_state.m2]]
-- [[Spells\Immolate_state_v2_illidari.m2]]
-- [[Spells\Intervenetrail.m2]]
-- [[Spells\Invisibility_impact_base.m2]]
-- [[Spells\Fire_dot_state_chest.m2]]
-- [[Spells\Fire_dot_state_chest_jade.m2]]
-- [[Spells\Cast_arcane_01.m2]]
-- [[Spells\Spellsteal_missile.m2]]
-- [[Spells\Missile_bomb.m2]]
-- [[Spells\Shadow_frost_weapon_effect.m2]]
-- [[Spells\Shadow_precast_high_base.m2]]
-- [[Spells\Shadow_precast_high_hand.m2]]
-- [[Spells\Shadow_precast_low_hand.m2]]
-- [[Spells\Shadow_precast_med_base.m2]]
-- [[Spells\Shadow_precast_uber_hand.m2]]
-- [[Spells\Shadow_strikes_state_hand.m2]]
-- [[Spells\Shadowbolt_missile.m2]]
-- [[Spells\Shadowworddominate_chest.m2]]
-- [[Spells\Infernal_smoke_rec.m2]]
-- [[Spells\Largebluegreenradiationfog.m2]]
-- [[Spells\Leishen_lightning_fill.m2]]
-- [[Spells\Mage_arcanebarrage_missile.m2]]
-- [[Spells\Mage_firestarter.m2]]
-- [[Spells\Mage_greaterinvis_state_chest.m2]]
-- [[Spells\Magicunlock.m2]]
-- [[Spells\Chiwave_impact_hostile.m2]]
-- [[Spells\Cripple_state_base.m2]]
-- [[Spells\Monk_expelharm_missile.m2]]
-- [[Spells\Monk_forcespere_orb.m2]]
-- [[Spells\Fill_holy_cast_01.m2]]
-- [[Spells\Fill_fire_cast_01.m2]]
-- [[Spells\Fill_lightning_cast_01.m2]]
-- [[Spells\Fill_magma_cast_01.m2]]
-- [[Spells\Fill_shadow_cast_01.m2]]
-- [[Spells\Sprint_impact_chest.m2]]
-- [[Spells\Spellsteal_missile.m2]]
-- [[Spells\Warlock_destructioncharge_impact_chest.m2]]
-- [[Spells\Warlock_destructioncharge_impact_chest_fel.m2]]
-- [[Spells\Xplosion_twilight_impact_noflash.m2]]
-- [[Spells\Warlock_bodyofflames_medium_state_shoulder_right_purple.m2]]
-- [[Spells\Blink_impact_chest.m2]]
-- [[Spells\Christmassnowrain.m2]]
-- [[Spells\Detectinvis_impact_base.m2]]
-- [[Spells\Eastern_plaguelands_beam_effect.m2]]
-- [[Spells\battlemasterglow_high.m2]]
-- [[Spells\blueflame_low.m2]]
-- [[Spells\greenflame_low.m2]]
-- [[Spells\purpleglow_high.m2]]
-- [[Spells\redflame_low.m2]]
-- [[Spells\poisondrip.m2]]
-- [[Spells\savageryglow_high.m2]]
-- [[Spells\spellsurgeglow_high.m2]]
-- [[Spells\sunfireglow_high.m2]]
-- [[Spells\whiteflame_low.m2]]
-- [[Spells\yellowflame_low.m2]]
-- [[Spells\Food_healeffect_base.m2]]
-- [[Spells\Bloodlust_state_hand.m2]]
-- [[Spells\Deathwish_state_hand.m2]]
-- [[Spells\Disenchant_precast_hand.m2]]
-- [[Spells\Enchant_cast_hand.m2]]
-- [[Spells\Eviscerate_cast_hands.m2]]
-- [[Spells\Fire_blue_precast_hand.m2]]
-- [[Spells\Fire_blue_precast_high_hand.m2]]
-- [[Spells\Fire_precast_hand.m2]]
-- [[Spells\Fire_precast_hand_pink.m2]]
-- [[Spells\Fire_precast_hand_sha.m2]]
-- [[Spells\Fire_precast_high_hand.m2]]
-- [[Spells\Fire_precast_low_hand.m2]]
-- [[Spells\Ice_precast_high_hand.m2]]
-- [[Spells\Sand_precast_hand.m2]]
-- [[Spells\Solar_precast_hand.m2]]
-- [[Spells\Twilight_fire_precast_high_hand.m2]]
-- [[Spells\Vengeance_state_hand.m2]]
-- [[Spells\Fel_djinndeath_fire_02.m2]]
