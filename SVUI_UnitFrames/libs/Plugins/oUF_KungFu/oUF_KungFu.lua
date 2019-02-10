--GLOBAL NAMESPACE
local _G = _G;
--LUA
local unpack        = _G.unpack;
local select        = _G.select;
local assert        = _G.assert;
local error         = _G.error;
local print         = _G.print;
local pairs         = _G.pairs;
local next          = _G.next;
local tostring      = _G.tostring;
local type  		= _G.type;

if select(2, UnitClass('player')) ~= "MONK" then return end

--BLIZZARD API
local UnitStagger 		= _G.UnitStagger;
local UnitPower     	= _G.UnitPower;
local UnitPowerMax 		= _G.UnitPowerMax;
local UnitHealthMax 	= _G.UnitHealthMax;
local UnitHasVehicleUI 	= _G.UnitHasVehicleUI;
local GetLocale 					= _G.GetLocale;
local GetShapeshiftFormID 			= _G.GetShapeshiftFormID;
local UnitAura         				= _G.UnitAura;
local UnitHasVehiclePlayerFrameUI 	= _G.UnitHasVehiclePlayerFrameUI;
local MonkStaggerBar 				= _G.MonkStaggerBar;
local SPELL_POWER_CHI 				= Enum.PowerType.Chi; -- _G.SPELL_POWER_CHI wasn't resolving properly to 12 the way it needed to


local parent, ns = ...
local oUF = ns.oUF
local floor = math.floor;
local DM_L = {};

if GetLocale() == "enUS" then
	DM_L["Stagger"] = "Stagger"
	DM_L["Light Stagger"] = "Light Stagger"
	DM_L["Moderate Stagger"] = "Moderate Stagger"
	DM_L["Heavy Stagger"] = "Heavy Stagger"

elseif GetLocale() == "frFR" then
	DM_L["Stagger"] = "Report"
	DM_L["Light Stagger"] = "Report mineur"
	DM_L["Moderate Stagger"] = "Report mod??"
	DM_L["Heavy Stagger"] = "Report majeur"

elseif GetLocale() == "itIT" then
	DM_L["Stagger"] = "Noncuranza"
	DM_L["Light Stagger"] = "Noncuranza Parziale"
	DM_L["Moderate Stagger"] = "Noncuranza Moderata"
	DM_L["Heavy Stagger"] = "Noncuranza Totale"

elseif GetLocale() == "deDE" then
	DM_L["Stagger"] = "Staffelung"
	DM_L["Light Stagger"] = "Leichte Staffelung"
	DM_L["Moderate Stagger"] = "Moderate Staffelung"
	DM_L["Heavy Stagger"] = "Schwere Staffelung"

elseif GetLocale() == "zhCN" then
	DM_L["Stagger"] = "醉拳"
	DM_L["Light Stagger"] = "轻度醉拳"
	DM_L["Moderate Stagger"] = "中度醉拳"
	DM_L["Heavy Stagger"] = "重度醉拳"

elseif GetLocale() == "ruRU" then
	DM_L["Stagger"] = "Пошатывание"
	DM_L["Light Stagger"] = "Легкое пошатывание"
	DM_L["Moderate Stagger"] = "Умеренное пошатывание"
	DM_L["Heavy Stagger"] = "Сильное пошатывание"

else
	DM_L["Stagger"] = "Stagger"
	DM_L["Light Stagger"] = "Light Stagger"
	DM_L["Moderate Stagger"] = "Moderate Stagger"
	DM_L["Heavy Stagger"] = "Heavy Stagger"
end

local STANCE_OF_THE_STURY_OX_ID = 23;
local DEFAULT_BREW_COLOR = {0.91, 0.75, 0.25, 0.5};
local BREW_COLORS = {
	[124275] = {0, 1, 0, 1}, -- Light
	[124274] = {1, 0.5, 0, 1}, -- Moderate
	[124273] = {1, 0, 0, 1}, -- Heavy
};
local DEFAULT_STAGGER_COLOR = {1, 1, 1, 0.5};
local STAGGER_COLORS = {
	[124275] = {0.2, 0.8, 0.2, 1}, -- Light
	[124274] = {1.0, 0.8, 0.2, 1}, -- Moderate
	[124273] = {1.0, 0.4, 0.2, 1}, -- Heavy
};
local STAGGER_DEBUFFS = {
	[124275] = true, -- Light
	[124274] = true, -- Moderate
	[124273] = true, -- Heavy
};
local CURRENT_STAGGER_COLOR = {1, 1, 1, 0.5};
local CURRENT_BREW_COLOR = {0.91, 0.75, 0.25, 0.5};
local CHI_COLORS = {
	[1] = {.57, .63, .35, 1},
	[2] = {.47, .63, .35, 1},
	[3] = {.37, .63, .35, 1},
	[4] = {.27, .63, .33, 1},
	[5] = {.17, .63, .33, 1},
	[6] = {0, .63, .33, 1},
}

local function getStaggerAmount()
	for i = 1, 40 do
		local _, _, _, _, _, _, _, _, _, _, spellID, _, _, _, amount =
			UnitDebuff("player", i)
		if STAGGER_DEBUFFS[spellID] then
			if (spellID) then
				CURRENT_STAGGER_COLOR = STAGGER_COLORS[spellID] or DEFAULT_STAGGER_COLOR
				CURRENT_BREW_COLOR = BREW_COLORS[spellID] or DEFAULT_BREW_COLOR
			else
				CURRENT_STAGGER_COLOR = DEFAULT_STAGGER_COLOR
				CURRENT_BREW_COLOR = DEFAULT_BREW_COLOR
			end
			return amount
		end
	end
	return 0
end

local Update = function(self, event, unit)
	if(unit and unit ~= self.unit) then return end
	local bar = self.KungFu
	local stagger = bar.DrunkenMaster
	local spec = GetSpecialization()

	if(bar.PreUpdate) then bar:PreUpdate(event) end

	local light = UnitPower("player", SPELL_POWER_CHI)
	local numPoints = UnitPowerMax("player", SPELL_POWER_CHI)

	if UnitHasVehicleUI("player") then
		bar:Hide()
	else
		bar:Show()
	end

	if spec == 3 then -- magic number 3 is windwalker
		if bar.numPoints ~= numPoints then
			if numPoints == 6 then
				bar[5]:Show()
				bar[6]:Show()
			elseif numPoints == 5 then
				bar[5]:Show()
				bar[6]:Hide()
			else
				bar[5]:Hide()
				bar[6]:Hide()
			end
		end
	end

	for i = 1, 6 do
		local orb = bar[i]
		if(orb) then
			if i <= light then
				orb:Show()
			else
				orb:Hide()
			end
		end
	end

	bar.numPoints = numPoints

	if(stagger.available) then
		local staggering = getStaggerAmount()
		if staggering == 0 then
			stagger:SetValue(0)
			stagger:FadeOut()
		else
			stagger:FadeIn()
			local health = UnitHealth("player")
			local maxHealth = UnitHealthMax("player")
			local staggerTotal = UnitStagger("player")
			if staggerTotal == 0 and staggering > 0 then
				staggerTotal = staggering * 10
			end

			local staggerPercent = staggerTotal / maxHealth * 100
			local currentStagger = floor(staggerPercent)
			stagger:SetMinMaxValues(0, 100)

			if(staggerPercent == 0) then
				stagger:SetStatusBarColor(unpack(DEFAULT_BREW_COLOR))
			else
				stagger:SetStatusBarColor(unpack(CURRENT_BREW_COLOR))
			end

			stagger:SetValue(staggerPercent)

			-- local icon = stagger.icon
			-- if(icon) then
			-- 	icon:SetVertexColor(unpack(CURRENT_STAGGER_COLOR))
			-- end
			if(stagger.PostUpdate) then
				stagger:PostUpdate(maxHealth, currentStagger, staggerPercent)
			end
		end
	end

	if(bar.PostUpdate) then bar:PostUpdate(event) end
end

local ProxyDisable = function(self, element)
	if(element:IsShown()) then
		element:Hide()
	end
	element.available = false;
	self:UnregisterEvent('UNIT_AURA', Update)
end

local ProxyEnable = function(self, element)
	if(not element.isEnabled) then
		element.available = false;
		return
	end
	element:Show()
	element.available = true;
	self:RegisterEvent('UNIT_AURA', Update)
end

local Visibility = function(self, ...)
	local bar = self.KungFu;
	local stagger = bar.DrunkenMaster;
	if(STANCE_OF_THE_STURY_OX_ID ~= GetShapeshiftFormID() or UnitHasVehiclePlayerFrameUI("player")) then
		ProxyDisable(self, stagger)
	else
		ProxyEnable(self, stagger)
		return Update(self, ...)
	end
end

local Path = function(self, ...)
	return (self.KungFu.Override or Visibility)(self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, "ForceUpdate", element.__owner.unit)
end

local function Enable(self, unit)
	if(unit ~= 'player') then return end
	local bar = self.KungFu
	local maxBars = UnitPowerMax("player", SPELL_POWER_CHI)

	if bar then
		local stagger = bar.DrunkenMaster
		stagger.__owner = self
		stagger.ForceUpdate = ForceUpdate

		self:RegisterEvent("PLAYER_ENTERING_WORLD", Update)
		self:RegisterEvent("UNIT_POWER_UPDATE", Update)
		self:RegisterEvent("PLAYER_LEVEL_UP", Update)
		self:RegisterEvent('UNIT_DISPLAYPOWER', Path)
		self:RegisterEvent('UPDATE_SHAPESHIFT_FORM', Path)
		
		for i = 1, 6 do
			if not bar[i]:GetStatusBarTexture() then
				bar[i]:SetStatusBarTexture([=[Interface\TargetingFrame\UI-StatusBar]=])
			end

			bar[i]:SetStatusBarColor(unpack(CHI_COLORS[i]))
			bar[i]:SetFrameLevel(bar:GetFrameLevel() + 1)
			bar[i]:GetStatusBarTexture():SetHorizTile(false)
		end
		bar.numPoints = maxBars

		if(stagger:IsObjectType'StatusBar' and not stagger:GetStatusBarTexture()) then
			stagger:SetStatusBarTexture(0.91, 0.75, 0.25)
		end
		stagger:SetStatusBarColor(unpack(DEFAULT_BREW_COLOR))
		stagger:SetMinMaxValues(0, 100)
		stagger:SetValue(0)

		MonkStaggerBar.Hide = MonkStaggerBar.Show
		MonkStaggerBar:UnregisterEvent'PLAYER_ENTERING_WORLD'
		MonkStaggerBar:UnregisterEvent'PLAYER_SPECIALIZATION_CHANGED'
		MonkStaggerBar:UnregisterEvent'UNIT_DISPLAYPOWER'
		MonkStaggerBar:UnregisterEvent'UPDATE_VEHICLE_ACTIONBAR'
        MonkStaggerBar:UnregisterEvent'UNIT_EXITED_VEHICLE'

		return true
	end
end

local function Disable(self)
	if self.KungFu then
		self:UnregisterEvent("PLAYER_ENTERING_WORLD", Update)
		self:UnregisterEvent("UNIT_POWER_UPDATE", Update)
		self:UnregisterEvent("PLAYER_LEVEL_UP", Update)
		self:UnregisterEvent("UNIT_DISPLAYPOWER", Path)
		self:UnregisterEvent('UPDATE_SHAPESHIFT_FORM', Path)

		MonkStaggerBar.Show = nil
		MonkStaggerBar:Show()
		MonkStaggerBar:UnregisterEvent'PLAYER_ENTERING_WORLD'
		MonkStaggerBar:UnregisterEvent'PLAYER_SPECIALIZATION_CHANGED'
		MonkStaggerBar:UnregisterEvent'UNIT_DISPLAYPOWER'
		MonkStaggerBar:UnregisterEvent'UPDATE_VEHICLE_ACTIONBAR'
        MonkStaggerBar:UnregisterEvent'UNIT_EXITED_VEHICLE'
	end
end

oUF:AddElement('KungFu', Update, Enable, Disable)
