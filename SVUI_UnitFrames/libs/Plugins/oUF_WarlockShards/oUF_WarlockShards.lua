--GLOBAL NAMESPACE
local _G = _G;
--LUA
local unpack        = _G.unpack;
local select        = _G.select;
local assert        = _G.assert;
--MATH
local math          = _G.math;
local floor         = math.floor
--BLIZZARD API
local UnitPower     	= _G.UnitPower;
local UnitPowerMax 		= _G.UnitPowerMax;
local UnitHasVehicleUI 	= _G.UnitHasVehicleUI;
local GetSpecialization = _G.GetSpecialization;

if select(2, UnitClass('player')) ~= "WARLOCK" then return end

local _, ns = ...
local oUF = ns.oUF or oUF

assert(oUF, 'oUF_WarlockShards was unable to locate oUF install')

local shardColor = {
	[1] = {0,0.72,0.1},
	[2] = {0.57,0.08,1},
	[3] = {1,0.25,0}
}

local Update = function(self, event, unit, powerType)
	local bar = self.WarlockShards;

	if(bar.PreUpdate) then bar:PreUpdate(unit) end

	if UnitHasVehicleUI("player") then
		bar:Hide()
	else
		bar:Show()
	end

	local spec = GetSpecialization()

	if spec then
		local colors = shardColor[spec]
		local numShards = UnitPower("player", Enum.PowerType.SoulShards);
		bar.MaxCount = UnitPowerMax("player", Enum.PowerType.SoulShards);

		if not bar:IsShown() then
			bar:Show()
		end

		if((not bar.CurrentSpec) or (bar.CurrentSpec ~= spec and bar.UpdateTextures)) then
			bar:UpdateTextures(spec)
		end

		for i = 1, 5 do
			if(i > bar.MaxCount) then
				bar[i]:Hide()
			else
				bar[i]:Show()
				bar[i]:SetStatusBarColor(unpack(colors))
				bar[i]:SetMinMaxValues(0, 1)
				local filled = (i <= numShards) and 1 or 0
				bar[i]:SetValue(filled)
				if(bar[i].Update) then
					bar[i]:Update(filled)
				end
			end
		end
	else
		if bar:IsShown() then bar:Hide() end;
	end

	if(bar.PostUpdate) then
		return bar:PostUpdate(unit, spec)
	end
end

local Path = function(self, ...)
	return (self.WarlockShards.Override or Update) (self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit, 'SOUL_SHARDS')
end

local function Enable(self, unit)
	if(unit ~= 'player') then return end

	local bar = self.WarlockShards
	if(bar) then
		bar.__owner = self
		bar.ForceUpdate = ForceUpdate

		self:RegisterEvent('UNIT_POWER_UPDATE', Path)
		self:RegisterEvent("PLAYER_TALENT_UPDATE", Path)
		self:RegisterEvent("PLAYER_ENTERING_WORLD", Path)
		self:RegisterEvent('UNIT_DISPLAYPOWER', Path)
		self:RegisterEvent("UNIT_POWER_FREQUENT", Path)
		self:RegisterEvent("UNIT_MAXPOWER", Path)
		self:RegisterUnitEvent('UNIT_DISPLAYPOWER', "player")
		self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
		self:RegisterUnitEvent("UNIT_MAXPOWER", "player")

		for i = 1, 5 do
			if not bar[i]:GetStatusBarTexture() then
				bar[i]:SetStatusBarTexture([=[Interface\TargetingFrame\UI-StatusBar]=])
			end

			bar[i]:SetFrameLevel(bar:GetFrameLevel() + 1)
			bar[i]:GetStatusBarTexture():SetHorizTile(false)
		end

		return true
	end
end

local function Disable(self)
	local bar = self.WarlockShards
	if(bar) then
		self:UnregisterEvent('UNIT_POWER_UPDATE', Path)
		self:UnregisterEvent("PLAYER_TALENT_UPDATE", Path)
		self:UnregisterEvent("PLAYER_ENTERING_WORLD", Path)
		self:UnregisterEvent('UNIT_DISPLAYPOWER', Path)
		self:UnregisterEvent("UNIT_POWER_FREQUENT", Path)
		self:UnregisterEvent("UNIT_MAXPOWER", Path)
		bar:Hide()
	end
end

oUF:AddElement('WarlockShards', Path, Enable, Disable)
