--GLOBAL NAMESPACE
local _G = _G;
--LUA
local unpack        = _G.unpack;
local select        = _G.select;
local assert        = _G.assert;
local type         	= _G.type;
--MATH
local math          = _G.math;
local floor         = math.floor
local ceil          = math.ceil
local random 				= math.random
--BLIZZARD API
local UnitAura       	 = _G.UnitAura;
local UnitCanAssist      = _G.UnitCanAssist;
local GetSpellInfo       = _G.GetSpellInfo;
local GetSpecialization  = _G.GetSpecialization;
local GetActiveSpecGroup = _G.GetActiveSpecGroup;

local _, ns = ...
local oUF = oUF or ns.oUF
if not oUF then return end

local playerClass = select(2,UnitClass("player"))
local CanDispel = {
	PRIEST = { Magic = true, Disease = true },
	SHAMAN = { Magic = false, Curse = true },
	PALADIN = { Magic = false, Poison = true, Disease = true },
	MAGE = { Curse = true },
	DRUID = { Magic = false, Curse = true, Poison = true, Disease = false },
	MONK = { Magic = false, Poison = true, Disease = true }
}

local AfflictedColor = { };
AfflictedColor["none"] = { r = 1, g = 0, b = 0 };
AfflictedColor["Magic"]    = { r = 0, g = 0.4, b = 1 };
AfflictedColor["Curse"]    = { r = 0.6, g = 0.1, b = 1 };
AfflictedColor["Disease"]  = { r = 1, g = 0.4, b = 0 };
AfflictedColor["Poison"]   = { r = 0.4, g = 1, b = 0 };
AfflictedColor[""] = AfflictedColor["none"];

local DEMO_COLORS = {"none", "Magic", "Curse", "Disease", "Poison"};

local SymbiosisName = GetSpellInfo(110309)
local CleanseName = GetSpellInfo(4987)
local dispellist = CanDispel[playerClass] or {}
local blackList = {
	[GetSpellInfo(140546)] = true, --Fully Mutated
	[GetSpellInfo(136184)] = true, --Thick Bones
	[GetSpellInfo(136186)] = true, --Clear mind
	[GetSpellInfo(136182)] = true, --Improved Synapses
	[GetSpellInfo(136180)] = true, --Keen Eyesight
}

local function GetDebuffType(unit, filter)
	if not unit or not UnitCanAssist("player", unit) then return nil end
	local i = 1
	while true do
		local name, _, texture, _, debufftype = UnitAura(unit, i, "HARMFUL")
		if not texture then break end
		if debufftype and (not filter or (filter and dispellist[debufftype])) and not blackList[name] then
			return debufftype, texture
		end
		i = i + 1
	end
end

local function UpdateTalentSpec(self, event, levels)
	if event == "CHARACTER_POINTS_CHANGED" and levels > 0 then return end

	local currentSpec = 0;
	local activeGroup = GetActiveSpecGroup()

	if(activeGroup) then
		currentSpec = GetSpecialization(false, false, activeGroup)
	end;

	if playerClass == "PRIEST" then
		if currentSpec == 3 then
			dispellist.Disease = false
		else
			dispellist.Disease = true
		end
	elseif playerClass == "PALADIN" then
		if currentSpec == 1 then
			dispellist.Magic = true
		else
			dispellist.Magic = false
		end
	elseif playerClass == "SHAMAN" then
		if currentSpec == 3 then
			dispellist.Magic = true
		else
			dispellist.Magic = false
		end
	elseif playerClass == "DRUID" then
		if currentSpec == 4 then
			dispellist.Magic = true
		else
			dispellist.Magic = false
		end
	elseif playerClass == "MONK" then
		if currentSpec == 2 then
			dispellist.Magic = true
		else
			dispellist.Magic = false
		end
	end
end

local function CheckSymbiosis()
	if GetSpellInfo(SymbiosisName) == CleanseName then
		dispellist.Disease = true
	else
		dispellist.Disease = false
	end
end

local function Update(self, event, unit)
	if(unit ~= self.unit and (not self.Afflicted.forceShow)) then return; end
	local afflicted = self.Afflicted
	if afflicted.forceShow then
		local color = AfflictedColor[DEMO_COLORS[random(1,#DEMO_COLORS)]]
		afflicted.Texture:SetVertexColor(color.r, color.g, color.b, 0.2)
		afflicted:SetBackdropBorderColor(color.r, color.g, color.b, 0.5)
	else
		local debuffType, texture  = GetDebuffType(unit, afflicted.ClassFilter)
		if debuffType then
			local color = AfflictedColor[debuffType]
			afflicted.Texture:SetVertexColor(color.r, color.g, color.b, 0.2)
			afflicted:SetBackdropBorderColor(color.r, color.g, color.b, 0.5)
		else
			afflicted.Texture:SetVertexColor(0,0,0,0)
			afflicted:SetBackdropBorderColor(0,0,0,0)
		end
	end
end

local function Enable(self)
	local afflicted = self.Afflicted
	if(not afflicted) then return end
	if(afflicted.ClassFilter and (not CanDispel[playerClass])) then return end

	self:RegisterEvent("UNIT_AURA", Update)
	self:RegisterEvent("PLAYER_TALENT_UPDATE", UpdateTalentSpec)
	self:RegisterEvent("CHARACTER_POINTS_CHANGED", UpdateTalentSpec)

	UpdateTalentSpec(self)

  	self:RegisterUnitEvent("UNIT_AURA", self.unit)

	if playerClass == "DRUID" then
    self:RegisterEvent("SPELLS_CHANGED", CheckSymbiosis)
	end

	return true
end

local function Disable(self)
	local afflicted = self.Afflicted
	if(not afflicted) then return end
	self:UnregisterEvent("UNIT_AURA", Update)
	self:UnregisterEvent("PLAYER_TALENT_UPDATE", UpdateTalentSpec)
	self:UnregisterEvent("CHARACTER_POINTS_CHANGED", UpdateTalentSpec)

	if playerClass == "DRUID" then
    self:UnregisterEvent("SPELLS_CHANGED", CheckSymbiosis)
	end
	afflicted.Texture:SetVertexColor(0,0,0,0)
	afflicted:SetBackdropBorderColor(0,0,0,0)
end

oUF:AddElement('Afflicted', Update, Enable, Disable)
