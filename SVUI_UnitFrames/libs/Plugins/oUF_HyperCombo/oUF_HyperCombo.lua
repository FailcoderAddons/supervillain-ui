--GLOBAL NAMESPACE
local _G = _G;
--LUA
local unpack        = _G.unpack;
local select        = _G.select;

local class = select(2, UnitClass("player"));
if(class ~= "ROGUE") then return end;

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
local GetShapeshiftForm         = _G.GetShapeshiftForm;
local UnitHasVehicleUI 			= _G.UnitHasVehicleUI;
local UnitBuff         			= _G.UnitBuff;
local MAX_COMBO_POINTS      	= _G.MAX_COMBO_POINTS;
local GetSpellInfo      		= _G.GetSpellInfo;
local GetComboPoints  			= _G.GetComboPoints;
local SPELL_POWER_COMBO_POINTS = Enum.PowerType.ComboPoints;

local parent, ns = ...
local oUF = ns.oUF

local ALERTED = false
local TextColors = {
	[1]={1,0.1,0.1},
	[2]={1,0.5,0.1},
	[3]={1,1,0.1},
	[4]={0.5,1,0.1},
	[5]={0.1,1,0.1}
};

local Update = function(self, event, unit)
	if(unit and unit ~= self.unit) then return end
	local bar = self.HyperCombo;
	local cpoints = bar.Combo;
	
	local current = 0
	if(UnitHasVehicleUI'player') then
		current = UnitPower("vehicle", SPELL_POWER_COMBO_POINTS);
	else
		current = UnitPower("player", SPELL_POWER_COMBO_POINTS);
	end

	if(cpoints and current) then
		if(bar.PreUpdate) then
			bar:PreUpdate()
		end

		local MAX_COMBO_POINTS = UnitPowerMax("player", SPELL_POWER_COMBO_POINTS);
		for i=1, MAX_COMBO_POINTS do
			if(i <= current) then
				if (cpoints[i]) then
					cpoints[i]:Show()
					if(bar.PointShow) then
						bar.PointShow(cpoints[i])
					end
				end
			else
				if (cpoints[i]) then
					cpoints[i]:Hide()
					if(bar.PointHide) then
						bar.PointHide(cpoints[i], i)
					end
				end
			end
		end

		if(bar.PostUpdate) then
			return bar:PostUpdate(current)
		end
	end
end

local Path = function(self, ...)
	return (self.HyperCombo.Override or Update) (self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local Enable = function(self)
	local bar = self.HyperCombo
	if(bar) then
		bar.__owner = self
		bar.ForceUpdate = ForceUpdate
		self:RegisterEvent('PLAYER_ENTERING_WORLD', Path, true)
		self:RegisterEvent('PLAYER_TARGET_CHANGED', Path, true)
		self:RegisterEvent('UNIT_DISPLAYPOWER', Path, true)
		self:RegisterUnitEvent('UNIT_DISPLAYPOWER', "player")
		self:RegisterEvent('UNIT_POWER_FREQUENT', Path, true)
		self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
		self:RegisterEvent('UNIT_MAXPOWER', Path, true)
		self:RegisterUnitEvent("UNIT_MAXPOWER", "player")
		
		local cpoints = bar.Combo;
		if(cpoints) then
			local maxComboPoints = UnitPowerMax("player", SPELL_POWER_COMBO_POINTS);
			for index = 1, maxComboPoints do
				local cpoint = cpoints[index]
				if(cpoint and cpoint:IsObjectType'Texture' and not cpoint:GetTexture()) then
					cpoint:SetTexture[[Interface\ComboFrame\ComboPoint]]
					cpoint:SetTexCoord(0, 0.375, 0, 1)
				end
			end
		end
		return true
	end
end

local Disable = function(self)
	local bar = self.HyperCombo
	if(bar) then
		local cpoints = bar.Combo;
		if(cpoints) then
			local maxComboPoints = UnitPowerMax(self.unit, SPELL_POWER_COMBO_POINTS);
			for index = 1, maxComboPoints do
				if (cpoints[index]) then cpoints[index]:Hide() end
			end
		end
		self:UnregisterEvent('PLAYER_ENTERING_WORLD', Path)
		self:UnregisterEvent('UNIT_DISPLAYPOWER', Path)
		self:UnregisterEvent('PLAYER_TARGET_CHANGED', Path)
		self:UnregisterEvent('UNIT_POWER_FREQUENT', Path)
		self:UnregisterEvent('UNIT_MAXPOWER', Path)
	end
end

oUF:AddElement('HyperCombo', Path, Enable, Disable)
