--GLOBAL NAMESPACE
local _G = _G;
--LUA
local unpack        = _G.unpack;
local select        = _G.select;
--BLIZZARD API
local GameTooltip   = _G.GameTooltip;
local MAX_TOTEMS 	= _G.MAX_TOTEMS;
local TotemFrame 	= _G.TotemFrame;

local class = select(2, UnitClass('player'))
if(class ~= 'SHAMAN') then return end

local parent, ns = ...
local oUF = ns.oUF

oUF.colors.totems = {
	[FIRE_TOTEM_SLOT] = { 181/255, 073/255, 033/255 },
	[EARTH_TOTEM_SLOT] = { 074/255, 142/255, 041/255 },
	[WATER_TOTEM_SLOT] = { 057/255, 146/255, 181/255 },
	[AIR_TOTEM_SLOT] = { 132/255, 056/255, 231/255 }
}

local GetTotemInfo, GetTime = GetTotemInfo, GetTime
local priorities = SHAMAN_TOTEM_PRIORITIES or STANDARD_TOTEM_PRIORITIES

local Totem_OnEnter = function(self)
	if(not self:IsVisible()) then return end
	GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMRIGHT')
	GameTooltip:SetTotem(self:GetID())
end

local Totem_OnLeave = function()
	GameTooltip:Hide()
end
	
local Totem_OnUpdate = function(self, elapsed)
	if not self.expirationTime then return end
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed >= 0.5 then	
		local timeLeft = self.expirationTime - GetTime()
		if timeLeft > 0 then
			self:SetValue(timeLeft)
		else
			self:SetScript("OnUpdate", nil)
		end
	end
end

local Update = function(self, event)
	local totems = self.TotemBars
	if(totems.PreUpdate) then totems:PreUpdate() end
	local haveTotem, name, start, duration, icon, timeLeft
	for i = 1, MAX_TOTEMS do
		local totem = totems[priorities[i]]
		if(totem) then
			haveTotem, name, start, duration, icon = GetTotemInfo(i)
			timeLeft = (start + duration) - GetTime()
			totem:SetMinMaxValues(0,duration)

			if(timeLeft > 0) then
				totem.expirationTime = (start + duration)
				totem:SetValue(timeLeft)
				totem:SetScript('OnUpdate', Totem_OnUpdate)
			else
				totem:SetValue(0)
				totem:SetScript('OnUpdate', nil)
			end
		end
	end

	if(totems.PostUpdate) then
		return totems:PostUpdate()
	end
end

local Path = function(self, ...)
	return (self.TotemBars.Override or Update) (self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, 'ForceUpdate')
end

local Enable = function(self)
	local totems = self.TotemBars

	if(totems) then
		totems.__owner = self
		totems.__map = { unpack(priorities) }
		totems.ForceUpdate = ForceUpdate

		for i = 1, MAX_TOTEMS do
			local totem = totems[i]
			totem:SetID(priorities[i])

			if(totem:IsMouseEnabled()) then
				totem:SetScript('OnEnter', Totem_OnEnter)
				totem:SetScript('OnLeave', Totem_OnLeave)
			end
		end

		self:RegisterEvent('PLAYER_TOTEM_UPDATE', Path, true)

		return true
	end
end

local Disable = function(self)
	if(self.TotemBars) then
		for i = 1, MAX_TOTEMS do
			self.TotemBars[i]:Hide()
		end

		self:UnregisterEvent('PLAYER_TOTEM_UPDATE', Path)
	end
end
			
oUF:AddElement("TotemBars", Path, Enable, Disable)
