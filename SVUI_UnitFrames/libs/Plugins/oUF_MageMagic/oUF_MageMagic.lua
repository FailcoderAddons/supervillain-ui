--GLOBAL NAMESPACE
local _G = _G;
--LUA
local unpack        = _G.unpack;
local select        = _G.select;
local assert        = _G.assert;
local type         	= _G.type;
--BLIZZARD API
local GetTime       	= _G.GetTime;
local GetSpecialization = _G.GetSpecialization;
local UnitDebuff      	= _G.UnitDebuff;

if select(2, UnitClass('player')) ~= "MAGE" then return end

local _, ns = ...
local oUF = oUF or ns.oUF
if not oUF then return end

local playerGUID;

local ARCANE_CHARGE_ID = 36032;
local ARCANE_BARRAGE_ID = 44425;
local IGNITE_ID = 12654;
local COMBUSTION_ID = 83853;
local PYROBLAST_ID = 11366;
--local ICICLE_ID = 148022;
local ICICLE_ID = 205473;
local FROSTBOLT_ID = 116;
local FROSTFIREBOLT_ID = 44614;
local ICELANCE_ID = 30455;
local ICYVEINS_NAME = GetSpellInfo(12472);
local ALTERTIME_ID = 108978;
local ALTERTIMEAURA_ID = 110909;

local CAST_SUCCESS = 'SPELL_CAST_SUCCESS';
local AURA_REMOVED = 'SPELL_AURA_REMOVED';
local SPELL_START = 'SPELL_CAST_START';

local DAMAGECOUNT = 0;
local DAMAGETOTAL = 0;
local SPELLCOUNT = 0;
local ALTERCOUNT = 0;
local LASTRECORD = 0;

local SpecMaximum = {
	[1] = 4,
	[2] = 4,
	[3] = 5,
};

local ResetMagic = function(self)
	local bar = self.MageMagic;
	local ignite = bar.Ignite;
	local igniteBar = ignite.Bar;
	SPELLCOUNT = 0;
	ALTERCOUNT = 0;
	LASTRECORD = 0;
	DAMAGETOTAL = 0;
	for i = 1, 5 do
		bar[i].start = 0
		bar[i].duration = 0
		bar[i]:SetValue(0)
		bar[i]:Hide()
		bar[i]:SetScript("OnUpdate", nil)
	end

	igniteBar.start = 0
	igniteBar.duration = 0
	igniteBar:SetValue(0)
	ignite:Hide()
	igniteBar:SetScript("OnUpdate", nil)
end

local GetResources = {
	[1] = function(self, event, ...)
		SPELLCOUNT = UnitPower("player", 16);-- hard coded change - variable is returning incorrect value SPELL_POWER_ARCANE_CHARGES);
		return 0,0
	end,
	[2] = function(self, event, ...)
		if(event == 'COMBAT_LOG_EVENT_UNFILTERED') then
			local _, eventType, _, srcGUID, _, _, _, destGUID, _, _, _, spellID, _, _, amount = ...
			if(srcGUID == playerGUID) then
				if(eventType:find("_DAMAGE")) then
					if(spellID == IGNITE_ID) then
						DAMAGETOTAL = amount
					elseif(spellID == COMBUSTION_ID) then
						DAMAGETOTAL = 0
					end
				end
			end
		elseif(event == 'UNIT_AURA') then
			local unit = ...;
			if(unit == 'player') then
				for index = 1, 30 do
					local name, rank, icon, count, dispelType, duration, expires, caster, isStealable, shouldConsolidate, spellID = UnitDebuff('target', index)
					if(spellID == IGNITE_ID) then
						return floor(expires), duration
					end
				end
			end
		end
		return 0,0,true
	end,
	[3] = function(self, event, ...)
		--SPELLCOUNT = 0;
		if(event == 'COMBAT_LOG_EVENT_UNFILTERED') then
			local _, eventType, _, srcGUID, _, _, _, _, _, _, _, spellID, _, _, amount = ...
			if (srcGUID == playerGUID) then
				if((eventType == CAST_SUCCESS) and (spellID == ICELANCE_ID)) then
					SPELLCOUNT = 0
					return 0,0;
				elseif(eventType:find("_DAMAGE") and (spellID == ICICLE_ID)) then
					if(SPELLCOUNT > 0) then
						SPELLCOUNT = SPELLCOUNT - 1
						return 0,0;
					end
				end
			end
		elseif(event == 'UNIT_AURA') then
			local unit = ...;
			if(unit == 'player') then
				for index = 1, 30 do
					local name, rank, icon, count, dispelType, duration, expires, caster, isStealable, shouldConsolidate, spellID = UnitBuff(unit, index)
					if(spellID == ICICLE_ID) then
						SPELLCOUNT = count
						return floor(expires), duration
					end
				end
				SPELLCOUNT = 0
			end
		end
		return 0,0,true;
	end,
};

local BarOnUpdate = function(self, elapsed)
	if not self.duration then return end
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed >= 0.5 then
		local timeLeft = (self.duration - GetTime())
		if timeLeft > 0 then
			self:SetValue(timeLeft)
		else
			if(SPELLCOUNT > 0) then
				SPELLCOUNT = SPELLCOUNT - 1
			end
			self.start = 0;
			self.duration = 0;
			self.elapsed = 0;
			self:SetValue(0)
			self:Hide()
			self:SetScript("OnUpdate", nil)
		end
	end
end

local IgniteOnUpdate = function(self, elapsed)
	if not self.duration then return end
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed >= 0.5 then
		local timeLeft = (self.duration - self.elapsed)
		local remaining = floor(timeLeft * DAMAGETOTAL)
		if timeLeft > 0 then
			self:SetValue(timeLeft)
			self.text:SetText(remaining)
		else
			self.text:SetText('0')
			DAMAGETOTAL = 0;
			self.start = 0;
			self.duration = 5;
			self.elapsed = 0;
			self:SetValue(0);
			self:SetScript("OnUpdate", nil);
		end
	end
end

local IcicleOnUpdate = function(self, elapsed)
	if not self.duration then return end
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed >= 0.5 then
		local timeLeft = (self.duration - self.elapsed)
		if((SPELLCOUNT > 0) and timeLeft > 0) then
			self:SetValue(timeLeft)
		else
			if(SPELLCOUNT > 0) then
				SPELLCOUNT = SPELLCOUNT - 1
			end
			self.start = 0;
			self.duration = 5;
			self.elapsed = 0;
			self:SetValue(0);
			self:Hide();
			self:SetScript("OnUpdate", nil);
		end
	end
end

local Update = function(self, event, ...)
	local bar = self.MageMagic
	local spec = bar.CurrentSpec;
	if(not spec) then return end

	if(bar.PreUpdate) then bar:PreUpdate(spec) end

	local maxCount = SpecMaximum[spec];
	local start, duration, reset = GetResources[spec](self, event, ...);
	if(not reset) then
		if(spec == 2) then
			local ignite = bar.Ignite;
			local igniteBar = ignite.Bar;
			if(not ignite:IsShown()) then ignite:Show() end
			if(duration and start and (start > igniteBar.start)) then
				igniteBar.start = start
				igniteBar.duration = duration
				igniteBar.elapsed = 0
				igniteBar:SetMinMaxValues(0, duration)
				igniteBar:SetValue(duration)
				igniteBar:SetScript('OnUpdate', IgniteOnUpdate)
			end
		else
			for i = 1, 5 do
				if(i > maxCount) then
					bar[i]:SetValue(0)
					bar[i]:Hide()
				else
					if(not bar[i]:IsShown()) then bar[i]:Show() end
					if(spec == 1) then
						if i <= SPELLCOUNT then
							bar[i]:Show()
							bar[i]:SetMinMaxValues(0, 100)
							bar[i]:SetValue(100)
							bar[i]:SetScript('OnUpdate', nil)
						else
							bar[i]:SetValue(0)
							bar[i]:Hide()
						end
					else
						if i <= SPELLCOUNT then
							bar[i]:FadeIn()
							if(duration and start and (start > bar[i].start)) then
								bar[i].start = start
								bar[i].duration = duration
								bar[i].elapsed = 0
								bar[i]:SetMinMaxValues(0, duration)
								bar[i]:SetValue(duration)
								bar[i]:SetScript('OnUpdate', IcicleOnUpdate)
							end
						else
							bar[i].start = 0
							bar[i].duration = 0
							bar[i].elapsed = 0
							bar[i]:SetValue(0)
							bar[i]:SetScript('OnUpdate', nil)
							bar[i]:FadeOut()
						end
					end
				end
			end
		end
	end

	if(bar.PostUpdate) then
		return bar:PostUpdate(event, SPELLCOUNT, maxCount)
	end
end

local Proxy = function(self, ...)
	local bar = self.MageMagic
	local spec = GetSpecialization()
	if(not playerGUID) then
		playerGUID = UnitGUID('player')
	end
	if((not bar.CurrentSpec) or (bar.CurrentSpec ~= spec)) then
		ResetMagic(self);
		if(spec) then
			bar.CurrentSpec = spec;
			if(spec == 3) then
				self:RegisterEvent('UNIT_AURA', Update)
				self:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED', Update, true)
				--print("Switch To Frost")
			elseif(spec == 2) then
				self:RegisterEvent('UNIT_AURA', Update)
				self:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED', Update, true)
				if(not bar.Ignite:IsShown()) then bar.Ignite:Show() end
				bar.Ignite.Bar:SetValue(0)
				--print("Switch To Fire")
			elseif(spec == 1) then
				self:RegisterEvent('UNIT_AURA', Update)
				self:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED', Update, true)
				--print("Switch To Arcane")
			end
			if(bar.PostTalentUpdate) then bar:PostTalentUpdate(spec) end
		else
			self:UnregisterEvent('UNIT_AURA', Update)
			self:UnregisterEvent('COMBAT_LOG_EVENT_UNFILTERED', Update)
		end
	end
	return Update(self, ...)
end

local Path = function(self, ...)
	return (self.MageMagic.Override or Proxy) (self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local Enable = function(self, unit)
	local bar = self.MageMagic

	if(bar) then
		self:RegisterEvent("PLAYER_TALENT_UPDATE", Path)
		self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", Path)
		self:RegisterEvent("PLAYER_ENTERING_WORLD", Path)
		bar.__owner = self
		bar.ForceUpdate = ForceUpdate

		for i = 1, 5 do
			if not bar[i]:GetStatusBarTexture() then
				bar[i]:SetStatusBarTexture([=[Interface\TargetingFrame\UI-StatusBar]=])
			end

			bar[i]:SetFrameLevel(bar:GetFrameLevel() + 1)
			bar[i]:GetStatusBarTexture():SetHorizTile(false)

			if bar[i].bg then
				bar[i]:SetMinMaxValues(0, 1)
				bar[i]:SetValue(0)
				bar[i].bg:SetAlpha(0.4)
				bar[i].bg:SetAllPoints()
				bar[i]:Hide()
			end
		end
		bar.Ignite.Bar:SetMinMaxValues(0, 5)
		bar.Ignite.Bar:SetValue(0)
		bar.Ignite:Hide()

		return true;
	end
end

local Disable = function(self, unit)
	local bar = self.MageMagic

	if(bar) then
		self:UnregisterEvent("UNIT_AURA", Update)
		self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", Update)
		self:UnregisterEvent("PLAYER_TALENT_UPDATE", Path)
		self:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED", Path)
		self:UnregisterEvent("PLAYER_ENTERING_WORLD", Path)
		bar:Hide()
	end
end

oUF:AddElement("MageMagic", Path, Enable, Disable)
