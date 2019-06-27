if(select(2, UnitClass('player')) ~= 'DRUID') then return end
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
--STRING
local string        = _G.string;
local format        = string.format;
--MATH
local math          = _G.math;
local floor         = math.floor
local ceil          = math.ceil
--TABLE
local table         = _G.table;
local wipe          = _G.wipe;
--BLIZZARD API
local BEAR_FORM       		= _G.BEAR_FORM;
local CAT_FORM 				= _G.CAT_FORM;
local SPELL_POWER_MANA      = _G.SPELL_POWER_MANA;
local UnitClass         	= _G.UnitClass;
local UnitPower         	= _G.UnitPower;
local UnitReaction         	= _G.UnitReaction;
local UnitPowerMax         	= _G.UnitPowerMax;
local UnitIsPlayer      	= _G.UnitIsPlayer;
local UnitPlayerControlled  = _G.UnitPlayerControlled;
local GetShapeshiftFormID 	= _G.GetShapeshiftFormID;

local _, ns = ...
local oUF = ns.oUF or oUF

local ECLIPSE_BAR_SOLAR_BUFF_ID = _G.ECLIPSE_BAR_SOLAR_BUFF_ID
local ECLIPSE_BAR_LUNAR_BUFF_ID = _G.ECLIPSE_BAR_LUNAR_BUFF_ID
local SPELL_POWER_ECLIPSE = _G.SPELL_POWER_ECLIPSE
local MOONKIN_FORM = _G.MOONKIN_FORM
local ALERTED = false;
local TextColors = {
	[1]={1,0.1,0.1},
	[2]={1,0.5,0.1},
	[3]={1,1,0.1},
	[4]={0.5,1,0.1},
	[5]={0.1,1,0.1}
};

local ProxyShow = function(self)
	if(not self.isEnabled) then return end
	self:Show()
end

local function CatOverMana(mana, form)
	if mana.ManaBar:GetValue() < UnitPowerMax('player', SPELL_POWER_MANA) then
		mana:Hide()
		return false
	else
		mana:Hide()
		return form == CAT_FORM
	end
end

local UpdateVisibility = function(self, event)
	local bar = self.Druidness
	local cat = bar.Cat
	local mana = bar.Mana
	local form = GetShapeshiftFormID()

	if(form) then
		if (form == BEAR_FORM or form == CAT_FORM) then
			if(CatOverMana(mana, form) or GetSpecializationInfo(GetSpecialization()) == 103) then
				cat:ProxyShow()
			else
				if(GetSpecializationInfo(GetSpecialization()) == 103) then
					cat:ProxyShow()
				else
					cat:Hide()
				end
			end
		else
			if(GetSpecializationInfo(GetSpecialization()) == 103) then
				cat:ProxyShow()
			else
				cat:Hide()
			end
			mana:Hide()
		end
	else
		mana:Hide()
		if(GetSpecializationInfo(GetSpecialization()) ~= 103) then
			cat:Hide()
		else
			cat:ProxyShow()
		end
	end
end

local UpdatePower = function(self, event, unit, powerType)
	if(self.unit ~= unit) then return end
	local bar = self.Druidness

	if(bar.Mana and bar.Mana.ManaBar) then
		local mana = bar.Mana
		if(mana.PreUpdate) then
			mana:PreUpdate(unit)
		end
		local min, max = UnitPower('player', SPELL_POWER_MANA), UnitPowerMax('player', SPELL_POWER_MANA)

		mana.ManaBar:SetMinMaxValues(0, max)
		mana.ManaBar:SetValue(min)

		local r, g, b, t
		if(mana.colorPower) then
			t = self.colors.power["MANA"]
		elseif(mana.colorClass and UnitIsPlayer(unit)) or
			(mana.colorClassNPC and not UnitIsPlayer(unit)) or
			(mana.colorClassPet and UnitPlayerControlled(unit) and not UnitIsPlayer(unit)) then
			local _, class = UnitClass(unit)
			t = self.colors.class[class]
		elseif(mana.colorReaction and UnitReaction(unit, 'player')) then
			t = self.colors.reaction[UnitReaction(unit, "player")]
		elseif(mana.colorSmooth) then
			r, g, b = self.ColorGradient(min / max, unpack(mana.smoothGradient or self.colors.smooth))
		end

		if(t) then
			r, g, b = t[1], t[2], t[3]
		end

		if(b) then
			mana.ManaBar:SetStatusBarColor(r, g, b)

			local bg = mana.bg
			if(bg) then
				local mu = bg.multiplier or 1
				bg:SetVertexColor(r * mu, g * mu, b * mu)
			end
		end

		if(mana.PostUpdatePower) then
			mana:PostUpdatePower(unit, min, max)
		end
	end

	UpdateVisibility(self)
end

local UpdateComboPoints = function(self, event, unit)
	if(unit == 'pet') then return end
	local bar = self.Druidness;
	local cpoints = bar.Cat;



	if(bar.PreUpdate) then
		bar:PreUpdate()
	end

	local current = 0
	if(UnitHasVehicleUI'player') then
		current = UnitPower("vehicle", SPELL_POWER_COMBO_POINTS);
	else
		current = UnitPower("player", SPELL_POWER_COMBO_POINTS);
	end
	if(cpoints) then
		local MAX_COMBO_POINTS = UnitPowerMax("player", SPELL_POWER_COMBO_POINTS);
		for i=1, MAX_COMBO_POINTS do
			if(i <= current) then
				if cpoints[i] then
					cpoints[i]:Show()
					if(bar.PointShow) then
						bar.PointShow(cpoints[i])
					end
				end
			else
				if cpoints[i] then
					cpoints[i]:Hide()
					if(bar.PointHide) then
						bar.PointHide(cpoints[i], i)
					end
				end
			end
		end
	end

	if(bar.PostUpdateComboPoints) then
		return bar:PostUpdateComboPoints(current)
	end
end

local Update = function(self, ...)
	UpdatePower(self, ...)
	UpdateComboPoints(self, ...)
	return UpdateVisibility(self, ...)
end

local ForceUpdate = function(element)
	return Update(element.__owner, 'ForceUpdate', element.__owner.unit, 'ECLIPSE')
end

local function Enable(self)
	local bar = self.Druidness

	if(bar) then
		local mana = bar.Mana;
		local cpoints = bar.Cat;
		mana.ProxyShow = ProxyShow;
		cpoints.ProxyShow = ProxyShow;

		self:RegisterEvent('UNIT_POWER_FREQUENT', UpdatePower)
		self:RegisterEvent('PLAYER_TALENT_UPDATE', UpdateVisibility, true)
		self:RegisterEvent('UPDATE_SHAPESHIFT_FORM', UpdateVisibility, true)
		self:RegisterEvent('PLAYER_TARGET_CHANGED', UpdateComboPoints, true)
		self:SetScript("OnUpdate", UpdateComboPoints)
		self:RegisterEvent('UNIT_DISPLAYPOWER', UpdateComboPoints, true)
		self:RegisterEvent('UNIT_MAXPOWER', UpdateComboPoints, true)
		self:RegisterUnitEvent('UNIT_DISPLAYPOWER', "player")
		self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
		self:RegisterUnitEvent("UNIT_MAXPOWER", "player")

		UpdateVisibility(self)
		return true
	end
end

local function Disable(self)
	local bar = self.Druidness

	if(bar) then
		--local chicken = bar.Chicken
		local mana = bar.Mana
		--chicken:Hide()
		mana:Hide()

		self:RegisterEvent('UNIT_POWER_FREQUENT', UpdatePower)
		self:UnregisterEvent('PLAYER_TALENT_UPDATE', UpdateVisibility)
		self:UnregisterEvent('UPDATE_SHAPESHIFT_FORM', UpdateVisibility)
		self:UnregisterEvent('UNIT_COMBO_POINTS', UpdateComboPoints)
		self:UnregisterEvent('PLAYER_TARGET_CHANGED', UpdateComboPoints)
		self:UnregisterEvent('UNIT_DISPLAYPOWER', UpdateComboPoints)
		self:UnregisterEvent('UNIT_MAXPOWER', UpdateComboPoints)
	end
end

oUF:AddElement('BoomChicken', Update, Enable, Disable)
