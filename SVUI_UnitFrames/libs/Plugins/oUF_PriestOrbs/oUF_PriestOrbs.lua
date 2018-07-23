--GLOBAL NAMESPACE
local _G = _G;
--LUA
local unpack        = _G.unpack;
local select        = _G.select;
local assert        = _G.assert;
--BLIZZARD API
local UnitPower     	= _G.UnitPower;
local UnitPowerMax 		= _G.UnitPowerMax;
local UnitHasVehicleUI 	= _G.UnitHasVehicleUI;
local GetSpecialization = _G.GetSpecialization;
local UnitLevel 		= _G.UnitLevel;
local UnitBuff 			= _G.UnitBuff;

local SHADOW_ORBS = _G.SHADOW_ORBS;

if select(2, UnitClass('player')) ~= "PRIEST" then return end

local _, ns = ...
local oUF = ns.oUF or oUF

local SPEC_PRIEST_DISC = 1
local SPEC_PRIEST_HOLY = 2
local SPEC_PRIEST_SHADOW = 3

local SHADOW_ORBS_SHOW_LEVEL = SHADOW_ORBS_SHOW_LEVEL
local HOLY_ORBS_SHOW_LEVEL = 44
local DISC_ORBS_SHOW_LEVEL = 44

--[[ 8.0.1
local EVANGELISM = GetSpellInfo(81662) or GetSpellInfo(81661) or GetSpellInfo(81660)
local DARK_EVANGELISM = GetSpellInfo(87118) or GetSpellInfo(87117)
local SERENDIPITY = GetSpellInfo(63733)
--]]
local OrbColors = {
	[1] = {1, 1, 0},
	[2] = {1, 1, 0},
	[3] = {0.6, 0.06, 1}	
};

local function Update(self, event, unit)
	local pb = self.PriestOrbs
	
	local numOrbs, invalid = 0, false
	local spec = GetSpecialization()
	local level = UnitLevel("player")
    local _, class = UnitClass("player")
	local color = OrbColors[spec]
	local name, _, icon, count
    if (false and class == "PRIEST") then
        numOrbs = UnitPower("player", SHADOW_ORBS)
        pb:Show()
	--[[ 8.0.1 Priest Fixes
    if(spec == SPEC_PRIEST_SHADOW and level >= SHADOW_ORBS_SHOW_LEVEL) then
		if (DARK_EVANGELISM) then
			numOrbs = UnitPower("player", SHADOW_ORBS)
			pb:Show()
		end;
	elseif(spec == SPEC_PRIEST_DISC and level >= DISC_ORBS_SHOW_LEVEL) then
		if (EVANGELISM) then
			name, _, icon, count = UnitBuff("player", EVANGELISM)
			numOrbs = count or 0
			pb:Show()
		end;
	elseif(spec == SPEC_PRIEST_HOLY and level >= HOLY_ORBS_SHOW_LEVEL) then
		if (SERENDIPITY) then
			name, _, icon, count = UnitBuff("player", SERENDIPITY)
			numOrbs = count or 0
			pb:Show()
		end;
    --]]
	else
		invalid = true;
		pb:Hide()
	end	

	if(not invalid) then
		if(pb.PreUpdate) then
			pb:PreUpdate(spec)
		end

		for i = 1, 5 do
			pb[i]:SetStatusBarColor(unpack(color))
			if i <= numOrbs then
				pb[i]:Show()
			else
				pb[i]:Hide()
			end
		end
		self:RegisterEvent("UNIT_DISPLAYPOWER", Update)
		self:RegisterEvent("UNIT_POWER_FREQUENT", Update)
		self:RegisterEvent("UNIT_AURA", Update)

		if(pb.PostUpdate) then
			pb:PostUpdate(spec)
		end	
	else
		for i = 1, 5 do
			pb[i]:Hide()
		end
		self:UnregisterEvent("UNIT_DISPLAYPOWER", Update)
		self:UnregisterEvent("UNIT_POWER_FREQUENT", Update)
		self:UnregisterEvent("UNIT_AURA", Update)
	end	
end

local ForceUpdate = function(element)
	return Update(element.__owner, "ForceUpdate")
end

local function Enable(self, unit)
	if(unit ~= 'player') then return end
	local pb = self.PriestOrbs
	if pb then
		pb.__owner = self
		pb.ForceUpdate = ForceUpdate
		
		self:RegisterEvent("PLAYER_LEVEL_UP", Update)
		self:RegisterEvent("PLAYER_TALENT_UPDATE", Update)
		self:RegisterEvent("UNIT_DISPLAYPOWER", Update)
		self:RegisterEvent("UNIT_POWER_FREQUENT", Update)
		self:RegisterEvent("UNIT_AURA", Update)

		for i = 1, 5 do
			if not pb[i]:GetStatusBarTexture() then
				pb[i]:SetStatusBarTexture([=[Interface\TargetingFrame\UI-StatusBar]=])
			end
			
			pb[i]:SetFrameLevel(pb:GetFrameLevel() + 1)
			pb[i]:GetStatusBarTexture():SetHorizTile(false)
		end
		
		return true
	end
end

local function Disable(self)
	if self.PriestOrbs then
		self:UnregisterEvent("PLAYER_LEVEL_UP", Update)
		self:UnregisterEvent("PLAYER_TALENT_UPDATE", Update)
		self:UnregisterEvent("UNIT_DISPLAYPOWER", Update)
		self:UnregisterEvent("UNIT_POWER_FREQUENT", Update)
		self:UnregisterEvent("UNIT_AURA", Update)
	end
end

oUF:AddElement('PriestOrbs', Update, Enable, Disable)