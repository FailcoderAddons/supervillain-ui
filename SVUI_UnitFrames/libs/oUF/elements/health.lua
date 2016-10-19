--[[ Element: Health Bar

	THIS FILE HEAVILY MODIFIED FOR USE WITH SUPERVILLAIN UI

]]
--GLOBAL NAMESPACE
local _G = _G;
--LUA
local unpack        = _G.unpack;
local select        = _G.select;
local assert        = _G.assert;
--MATH
local math          = _G.math;
local max         	= math.max
local random 		= math.random
--BLIZZARD API
local UnitClass     			= _G.UnitClass;
local UnitReaction     			= _G.UnitReaction;
local UnitIsEnemy     			= _G.UnitIsEnemy;
local GetCVarBool     			= _G.GetCVarBool;
local SetCVar     				= _G.SetCVar;
local UnitHealth     			= _G.UnitHealth;
local UnitHealthMax     		= _G.UnitHealthMax;
local UnitIsConnected			= _G.UnitIsConnected;
local UnitIsDeadOrGhost 		= _G.UnitIsDeadOrGhost;
local UnitIsPlayer 				= _G.UnitIsPlayer;
local UnitPlayerControlled 		= _G.UnitPlayerControlled;
local UnitIsTapDenied 			= _G.UnitIsTapDenied;


local parent, ns = ...
local oUF = ns.oUF

oUF.colors.health = {49/255, 207/255, 37/255}
--local UpdateFrequentUpdates

local Update = function(self, event, unit)
	if(self.unit ~= unit) or not unit then return end
	local health = self.Health
	local min, max = UnitHealth(unit), UnitHealthMax(unit)

	if(health.PreUpdate) then
		health:PreUpdate(unit, min, max)
	else
		local disconnected = not UnitIsConnected(unit)
		local invisible = ((min == max) or UnitIsDeadOrGhost(unit) or disconnected)
		if invisible then health.lowAlerted = false end

		if health.fillInverted then
			health:SetReverseFill(true)
		end

		health:SetMinMaxValues(0, max)
		health:SetValue(disconnected and 0 or min)
		health.percent = invisible and 100 or ((min / max) * 100)
		health.disconnected = disconnected

		local bg = health.bg;
		local r, g, b, t, t2;
		local _, class = UnitClass(unit);
		local reaction = UnitReaction(unit, 'player');
		local classColors = oUF.colors.class[class];
		local bgColors = classColors or oUF.colors.reaction[reaction];
		if(health.colorTapping and not UnitPlayerControlled(unit) and UnitIsTapDenied(unit)) then
			t = oUF.colors.tapped
		elseif(health.colorDisconnected and not UnitIsConnected(unit)) then
			t = oUF.colors.disconnected
		elseif(health.colorClass and UnitIsPlayer(unit)) or
			(health.colorClassNPC and not UnitIsPlayer(unit)) or
			(health.colorClassPet and UnitPlayerControlled(unit) and not UnitIsPlayer(unit)) then
			local tmp = classColors or oUF.colors.health
			t = {(tmp[1] * 0.75),(tmp[2] * 0.75),(tmp[3] * 0.75)}
		elseif(health.colorReaction and reaction) then
			t = oUF.colors.reaction[reaction]
		elseif(health.colorSmooth) then
			r, g, b = oUF.ColorGradient(min, max, unpack(health.smoothGradient or oUF.colors.smooth))
		elseif(health.colorHealth) then
			t = oUF.colors.health
		end

		if(t) then
			r, g, b = t[1], t[2], t[3]
		end

		if(b) then
			if((health.colorClass and health.colorSmooth) or (health.colorSmooth and self.isForced and not UnitIsTapDenied(unit))) then
				r, g, b = self.ColorGradient(min,max,1,0,0,1,1,0,r,g,b)
			end
			health:SetStatusBarColor(r, g, b)
			if(bg) then
				local mu = bg.multiplier or 1
				if(health.colorBackdrop and bgColors) then
					r, g, b = bgColors[1], bgColors[2], bgColors[3]
				elseif(oUF.colors.healthBackdrop) then
					r, g, b = unpack(oUF.colors.healthBackdrop)
				else
					r, g, b = unpack(oUF.colors.health)
				end
				bg:SetVertexColor(r * mu, g * mu, b * mu)
			end
		end
	end

	-- if health.frequentUpdates ~= health.__frequentUpdates then
	-- 	UpdateFrequentUpdates(self)
	-- end

	if self.ResurrectIcon then
		self.ResurrectIcon:SetAlpha(min == 0 and 1 or 0)
	end

	if self.isForced then
		min = random(1,max)
		health:SetValue(min)
	end

	if(health.gridMode) then
		health:SetOrientation("VERTICAL")
	end

	if(health.LowAlertFunc and UnitIsPlayer("target") and health.percent < 6 and UnitIsEnemy("target", "player") and not health.lowAlerted) then
		health.lowAlerted = true
		health.LowAlertFunc(self)
	end

	if(health.PostUpdate) then
		return health.PostUpdate(self, health.percent)
	end
end

local ForceUpdate = function(element)
	return Update(element.__owner, 'ForceUpdate', element.__owner.unit)
end

-- function UpdateFrequentUpdates(self)
-- 	local health = self.Health
-- 	health.__frequentUpdates = health.frequentUpdates
-- 	if health.frequentUpdates and not self:IsEventRegistered("UNIT_HEALTH_FREQUENT") then
-- 		if GetCVarBool("predictedHealth") ~= 1 then
-- 			SetCVar("predictedHealth", 1)
-- 		end
--
-- 		self:RegisterEvent('UNIT_HEALTH_FREQUENT', Update)
--
-- 		if self:IsEventRegistered("UNIT_HEALTH") then
-- 			self:UnregisterEvent("UNIT_HEALTH", Update)
-- 		end
-- 	elseif not self:IsEventRegistered("UNIT_HEALTH") then
-- 		self:RegisterEvent('UNIT_HEALTH', Update)
--
-- 		if self:IsEventRegistered("UNIT_HEALTH_FREQUENT") then
-- 			self:UnregisterEvent("UNIT_HEALTH_FREQUENT", Update)
-- 		end
-- 	end
-- end

local Enable = function(self, unit)
	local health = self.Health
	if(health) then
		health.__owner = self
		health.ForceUpdate = ForceUpdate
		health.__frequentUpdates = health.frequentUpdates

		self:RegisterEvent('UNIT_HEALTH', Update)
		self:RegisterEvent("UNIT_MAXHEALTH", Update)
		self:RegisterEvent('UNIT_CONNECTION', Update)
		self:RegisterEvent('UNIT_FACTION', Update)
		self:RegisterUnitEvent("UNIT_HEALTH", unit);
		self:RegisterUnitEvent("UNIT_MAXHEALTH", unit);

		if(health:IsObjectType'StatusBar' and not health:GetStatusBarTexture()) then
			health:SetStatusBarTexture[[Interface\TargetingFrame\UI-StatusBar]]
		end

		return true
	end
end

local Disable = function(self)
	local health = self.Health
	if(health) then
		health:Hide()
		self:UnregisterEvent('UNIT_HEALTH_FREQUENT', Update)
		self:UnregisterEvent('UNIT_HEALTH', Update)
		self:UnregisterEvent('UNIT_MAXHEALTH', Update)
		self:UnregisterEvent('UNIT_CONNECTION', Update)

		self:UnregisterEvent('UNIT_FACTION', Update)
	end
end

oUF:AddElement('Health', Update, Enable, Disable)
