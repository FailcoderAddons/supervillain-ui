if(select(2, UnitClass('player')) ~= 'WARRIOR') then return end
--GLOBAL NAMESPACE
local _G = _G;
--LUA
local unpack        = _G.unpack;
local select        = _G.select;
local assert        = _G.assert;
--BLIZZARD API
local UnitDebuff      	= _G.UnitDebuff;

local parent, ns = ...
local oUF = ns.oUF

local ENRAGE_ID = 12880;

local function getEnrageAmount()
	for i = 1, 40 do
		local _, _, _, count, _, duration, expires, _, _, _, spellID = 
			UnitBuff("player", i)
		if(spellID and spellID == ENRAGE_ID) then
			return floor(expires), duration
		end
	end
	return 0,0
end

local BarOnUpdate = function(self, elapsed)
	if not self.duration then return end
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed >= 0.5 then
		local timeLeft = (self.duration - GetTime())
		if timeLeft > 0 then
			self:SetValue(timeLeft)
		else
			self.start = nil
			self.duration = nil
			self:SetValue(0)
			self:Hide()
			self:SetScript("OnUpdate", nil)
		end
	end		
end

local EnrageOnUpdate = function(self, elapsed)
	if not self.duration then return end
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed >= 0.5 then
		local timeLeft = (self.duration - self.elapsed)
		if timeLeft > 0 then
			self.bar:SetValue(timeLeft)
		else
			self.start = 0;
			self.duration = 8;
			self.elapsed = 0;
			self.bar:SetValue(0);
			self:SetScript("OnUpdate", nil);
			self:FadeOut();
		end
	end		
end

local Update = function(self, event, unit)
	local element = self.Conqueror
	local enrage = element.Enrage
	if(element.PreUpdate) then element:PreUpdate(event) end

	if(enrage:IsShown()) then
		local start, duration = getEnrageAmount()
		if(duration and start and (start ~= enrage.start)) then
			enrage.bar:SetMinMaxValues(0, duration)
			enrage.bar:SetValue(duration)

			enrage.elapsed = 0;
			enrage.start = start
			enrage.duration = duration
			enrage:SetScript('OnUpdate', EnrageOnUpdate)
			enrage:FadeIn();
		end
	end
	
	if(element.PostUpdate) then
		return element:PostUpdate(event)
	end
end

local Path = function(self, ...)
	return (self.Conqueror.Override or Update)(self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, 'ForceUpdate')
end

local Enable = function(self)
	local bar = self.Conqueror

	if(bar) then
		bar.__owner = self
		bar.ForceUpdate = ForceUpdate

		self:RegisterEvent('UNIT_AURA', Path, true)

		local enrage = bar.Enrage;
		if(enrage.bar:IsObjectType'Texture' and not enrage.bar:GetTexture()) then
			enrage.bar:SetTexture[[Interface\TargetingFrame\UI-StatusBar]]
		end
		enrage.bar:SetMinMaxValues(0, 100)
		enrage.bar:SetValue(0)
		enrage:FadeOut()

		return true
	end
end

local Disable = function(self)
	local bar = self.Conqueror

	if (bar) then
		self:UnregisterEvent('UNIT_AURA', Path)
	end
end

oUF:AddElement('Conqueror', Path, Enable, Disable)
