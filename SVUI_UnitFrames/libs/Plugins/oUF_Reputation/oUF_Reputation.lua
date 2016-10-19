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
--BLIZZARD API
local UnitXP       		= _G.UnitXP;
local UnitXPMax 		= _G.UnitXPMax;
local GetXPExhaustion   = _G.GetXPExhaustion;
local UnitSex         	= _G.UnitSex;
local GetText  			= _G.GetText;
local GetWatchedFactionInfo = _G.GetWatchedFactionInfo;
local FACTION_BAR_COLORS  	= _G.FACTION_BAR_COLORS;

local __, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, 'oUF Reputation was unable to locate oUF install')

for tag, func in pairs({
	['currep'] = function()
		local __, __, min, __, value = GetWatchedFactionInfo()
		return value - min
	end,
	['maxrep'] = function()
		local __, __, min, max = GetWatchedFactionInfo()
		return max - min
	end,
	['perrep'] = function()
		local __, __, min, max, value = GetWatchedFactionInfo()
		return math.floor((value - min) / (max - min) * 100 + 0.5)
	end,
	['standing'] = function()
		local __, standing = GetWatchedFactionInfo()
		return GetText('FACTION_STANDING_LABEL' .. standing, UnitSex('player'))
	end,
	['reputation'] = function()
		return GetWatchedFactionInfo()
	end,
}) do
	oUF.Tags.Methods[tag] = func
	oUF.Tags.Events[tag] = 'UPDATE_FACTION'
end

oUF.Tags.SharedEvents.UPDATE_FACTION = true

local function Update(self, event, unit)
	local reputation = self.Reputation

	local name, standing, min, max, value = GetWatchedFactionInfo()
	if(not name) then
		return reputation:Hide()
	else
		reputation:Show()
	end

	reputation:SetMinMaxValues(0, max - min)
	reputation:SetValue(value - min)

	if(reputation.colorStanding) then
		local color = FACTION_BAR_COLORS[standing]
		reputation:SetStatusBarColor(color.r, color.g, color.b)
	end

	if(reputation.PostUpdate) then
		return reputation:PostUpdate(unit, name, standing, min, max, value)
	end
end

local function Path(self, ...)
	return (self.Reputation.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self, unit)
	local reputation = self.Reputation
	if(reputation) then
		reputation.__owner = self
		reputation.ForceUpdate = ForceUpdate

		self:RegisterEvent('UPDATE_FACTION', Path)

		if(not reputation:GetStatusBarTexture()) then
			reputation:SetStatusBarTexture([=[Interface\TargetingFrame\UI-StatusBar]=])
		end

		return true
	end
end

local function Disable(self)
	if(self.Reputation) then
		self:UnregisterEvent('UPDATE_FACTION', Path)
	end
end

oUF:AddElement('Reputation', Path, Enable, Disable)
