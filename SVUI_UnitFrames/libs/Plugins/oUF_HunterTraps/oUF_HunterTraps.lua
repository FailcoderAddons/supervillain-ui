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

if select(2, UnitClass('player')) ~= "HUNTER" then return end

local _, ns = ...
local oUF = oUF or ns.oUF
if not oUF then return end

local TRAP_MASTERY_ID = 63458;
local TRAP_MASTERY = IsSpellKnown(TRAP_MASTERY_ID);
local ENHANCED_TRAPS_ID = 157751;
local ENHANCED_TRAPS = IsSpellKnown(ENHANCED_TRAPS_ID);
--local FIRE_TRAP = GetSpellInfo(13813);
local FROST_TRAP = GetSpellInfo(187650);
local TAR_TRAP = GetSpellInfo(187698);
--local SNAKE_TRAP, SNAKE_RANK, SNAKE_ICON = GetSpellInfo(34600);

--local FIRE_COLOR = {1,0.25,0};
local FROST_COLOR = {0.5,1,1};
--local ICE_COLOR = {0.1,0.9,1};
local TAR_COLOR = {0,0,0};
local SNAKE_COLOR = {0.2,0.8,0};
--/script print(IsSpellKnown(34600))
--/script print(IsSpellKnown(13809))
local TRAP_IDS = { 
	[1] = FROST_TRAP, 
	[2] = TAR_TRAP,
};
local TRAP_COLORS = {
	[1] = FROST_COLOR, 
	[2] = TAR_COLOR,
};

local HAS_SNAKE_TRAP = false;

local function UpdateTrap(self, elapsed)
	if not self.duration then return end
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed >= 0.5 then
		local timeLeft = (self.duration - (self.duration - (GetTime() - self.start))) * 1000
		if timeLeft < self.duration then
			self:SetValue(timeLeft)
			self:SetStatusBarColor(unpack(TRAP_COLORS[self.colorIndex]))
		else
			self:SetStatusBarColor(0.9,0.9,0.9)
			self.elapsed = 0
			self.start = nil
			self.duration = nil
			self:SetScript("OnUpdate", nil)
			self:Update(true)
		end
	end		
end

local function UpdateSnakeTrap(self, elapsed)
	if not self.duration then return end
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed >= 0.5 then
		local timeLeft = (self.duration - (self.duration - (GetTime() - self.start))) * 1000
		if timeLeft < self.duration then
			self:SetValue(timeLeft)
			self:SetStatusBarColor(unpack(TRAP_COLORS[self.colorIndex]))
		else
			self:SetStatusBarColor(0.9,0.9,0.9)
			self.elapsed = 0
			self.start = nil
			self.duration = nil
			self:SetScript("OnUpdate", nil)
			self:Update(true, HAS_SNAKE_TRAP)
		end
	end		
end

local Update = function(self, event, ...)
	local bar = self.HunterTraps
	if(event and event == "SPELLS_CHANGED") then
		ENHANCED_TRAPS = IsSpellKnown(ENHANCED_TRAPS_ID);
		TRAP_MASTERY = IsSpellKnown(TRAP_MASTERY_ID);
		local ice_icon = select(3, GetSpellInfo(13809));
		if(ice_icon == SNAKE_ICON) then
			TRAP_IDS[3] = SNAKE_TRAP
			TRAP_COLORS[3] = SNAKE_COLOR
			HAS_SNAKE_TRAP = true
		else
		    TRAP_IDS[2] = TAR_TRAP
		    TRAP_COLORS[2] = TAR_COLOR
		    HAS_SNAKE_TRAP = false
		end
		bar[3]:Update(nil, HAS_SNAKE_TRAP, true)
	end

	if(bar.PreUpdate) then bar:PreUpdate(event) end

	local name, start, duration, isReady, enable;
	local unit, _, _, _, spellID = ...
	if(unit and (self.unit ~= unit)) then
		return 
	end
	if(spellID) then
		name = GetSpellInfo(spellID)
		start, isReady, enable = GetSpellCooldown(spellID)
		duration = GetSpellBaseCooldown(spellID)
		if(duration and duration > 0) then
			if(TRAP_MASTERY) then
				duration = duration - 6;
			end
			if(ENHANCED_TRAPS) then
				duration = duration * 0.5
			end
		end
	end

	if bar:IsShown() then		
		for i = 1, 2 do
			--bar[i]:SetStatusBarColor(unpack(TRAP_COLORS[i]))
			if(name and TRAP_IDS[i] == name and isReady == 1) then
				bar[i]:Show()
				if((start and start > 0) and (duration and duration > 0)) then
					bar[i]:SetMinMaxValues(0, duration)
					bar[i]:SetValue(0)
					bar[i].start = start
					bar[i].duration = duration
					if(i == 3) then
						bar[i]:SetScript('OnUpdate', UpdateSnakeTrap)
						bar[i]:Update(false, HAS_SNAKE_TRAP)
					else
						bar[i]:SetScript('OnUpdate', UpdateTrap)
						bar[i]:Update()
					end
				end
			end
		end		
	end
	
	if(bar.PostUpdate) then
		return bar:PostUpdate(event)
	end
end


local Path = function(self, ...)
	return (self.HunterTraps.Override or Update) (self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self, unit)
	local bar = self.HunterTraps

	if(bar) then
		self:RegisterEvent("SPELLS_CHANGED", Path)
		self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", Path)
		self:RegisterEvent("PLAYER_TALENT_UPDATE", Path)
		self:RegisterEvent("PLAYER_ENTERING_WORLD", Path)
		bar.__owner = self
		bar.ForceUpdate = ForceUpdate

		local barWidth,barHeight = bar:GetSize()
		local trapSize = barWidth * 0.25

		local ice_icon = select(3, GetSpellInfo(13809));
		if(ice_icon == SNAKE_ICON) then
			TRAP_IDS[3] = SNAKE_TRAP
			TRAP_COLORS[3] = SNAKE_COLOR
			HAS_SNAKE_TRAP = true
		else
			TRAP_IDS[3] = ICE_TRAP
			TRAP_COLORS[3] = ICE_COLOR
			HAS_SNAKE_TRAP = false
		end
		for i = 1, 2 do
			if not bar[i] then
				bar[i] = CreateFrame("Statusbar", nil, bar)
				bar[i]:SetPoint("LEFT", bar, "LEFT", (trapSize * (i - 1)), 0)
				bar[i]:SetSize(trapSize,trapSize)
			end

			bar[i].colorIndex = i;

			if not bar[i]:GetStatusBarTexture() then
				bar[i]:SetStatusBarTexture([=[Interface\TargetingFrame\UI-StatusBar]=])
			end

			bar[i]:SetFrameLevel(bar:GetFrameLevel() + 1)
			bar[i]:GetStatusBarTexture():SetHorizTile(false)
			bar[i]:SetStatusBarColor(0.9,0.9,0.9)
			
			if bar[i].bg then
				bar[i].bg:SetAllPoints()
			end

			bar[i]:SetMinMaxValues(0, 1)
			bar[i]:SetValue(1)
			bar[i]:Update(true, HAS_SNAKE_TRAP)
		end
		
		return true;
	end	
end

local function Disable(self,unit)
	local bar = self.HunterTraps

	if(bar) then
		self:UnregisterEvent("SPELLS_CHANGED", Path)
		self:UnregisterEvent('UNIT_SPELLCAST_SUCCEEDED', Path)
		self:UnregisterEvent("PLAYER_TALENT_UPDATE", Path)
		self:UnregisterEvent("PLAYER_ENTERING_WORLD", Path)
		bar:Hide()
	end
end
			
oUF:AddElement("HunterTraps",Path,Enable,Disable)