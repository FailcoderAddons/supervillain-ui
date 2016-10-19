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
local setmetatable  = _G.setmetatable;
--STRING
local string        = _G.string;
local format        = string.format;
--MATH
local math          = _G.math;
local floor         = math.floor
local ceil          = math.ceil
--BLIZZARD API
local GetTime       			= _G.GetTime;
local CreateFrame       		= _G.CreateFrame;
local UnitIsEnemy         		= _G.UnitIsEnemy;
local UnitGUID      			= _G.UnitGUID;
local IsActiveBattlefieldArena  = _G.IsActiveBattlefieldArena;
local UnitFactionGroup 			= _G.UnitFactionGroup;
local GetNumArenaOpponentSpecs 	= _G.GetNumArenaOpponentSpecs;
local GetArenaOpponentSpec      = _G.GetArenaOpponentSpec;
local GetSpecializationInfoByID = _G.GetSpecializationInfoByID;
local UnitName       			= _G.UnitName;
local SendChatMessage  			= _G.SendChatMessage;
local CooldownFrame_Set 	= _G.CooldownFrame_Set;

local _, ns = ...
local oUF = ns.oUF

local trinketSpells = {
	[59752] = 120,
	[42292] = 120,
	[7744] = 45,
}

local timeLeft = 0
local Trinket_OnUpdate = function(self, elapsed)
	local expires = (self.duration - (GetTime() - self.start));
	if(expires == 0) then
		local parent = self:GetParent()
		parent.Icon:SetDesaturated(false)
		parent.Unavailable:Hide()
		self:SetScript("OnUpdate", nil)
	end
end

local function GetPVPIcons(unit, frameID)
	local _, trinket, badge
	local unitFactionGroup = UnitFactionGroup(unit)
	if unitFactionGroup == "Horde" then
		trinket, badge = [[Interface\Icons\INV_Jewelry_TrinketPVP_02]], [[Interface\Icons\INV_BannerPVP_01]]
	elseif unitFactionGroup == "Alliance" then
		trinket, badge = [[Interface\Icons\INV_Jewelry_TrinketPVP_01]], [[Interface\Icons\INV_BannerPVP_02]]
	else
		trinket, badge = [[Interface\Icons\INV_MISC_QUESTIONMARK]], [[Interface\Icons\INV_MISC_QUESTIONMARK]]
	end
	if(frameID) then
		local numOpps = GetNumArenaOpponentSpecs()
		local specID = GetArenaOpponentSpec(frameID)
		if((numOpps > 0) and specID) then
			_, _, _, badge = GetSpecializationInfoByID(specID)
		end
	end
	return trinket, badge
end

local function LogUpdate(self, event, ...)
	local arenaMatch = IsActiveBattlefieldArena()
	local element = self.Gladiator
	local trinket = element.Trinket
	local alert = element.Alert
	if not arenaMatch then trinket:Hide() return end
	trinket:Show()
	if(event == "COMBAT_LOG_EVENT_UNFILTERED") then
		local _, eventType, _, sourceGUID, _, _, _, _, _, _, _, spellID = ...
		if eventType == "SPELL_CAST_SUCCESS" and sourceGUID == UnitGUID(self.unit) and trinketSpells[spellID] then
			local startTime = GetTime()
			local duration = trinketSpells[spellID]
			trinket.CD.start = startTime
			trinket.CD.duration = duration
			trinket.CD.nextUpdate = 0
			trinket.CD:SetScript("OnUpdate", Trinket_OnUpdate)
			trinket.Icon:SetDesaturated(true)
			trinket.Unavailable:Show()
			CooldownFrame_Set(trinket.CD, startTime, duration, 1)
		end
	elseif(alert and event == "UNIT_SPELLCAST_SUCCEEDED") then
		local unitID, spellName, _, _, spellID = ...
		if UnitIsEnemy("player", unitID) and (spellID == 118358 or spellID == 104270 or spellName:find("Drink")) then
			SendChatMessage(("%s is drinking."):format(UnitName(self.unit)), "RAID_WARNING")
		end
	end
end

local Update = function(self, event, ...)
	local unit, unitType = ...
	if(event == "COMBAT_LOG_EVENT_UNFILTERED" or event == "UNIT_SPELLCAST_SUCCEEDED") then return LogUpdate(self, event, ...) end
	if(not unit or unit ~= self.unit) then return end
	local element = self.Gladiator
	local trinket = element.Trinket
	local badge = element.Badge
	local arenaMatch = IsActiveBattlefieldArena()
	local frameID = arenaMatch and self:GetID()
	local tIcon, bIcon = GetPVPIcons(unit, frameID)
	if(badge) then badge.Icon:SetTexture(bIcon) end
	if(trinket) then
		if(not arenaMatch) then trinket:Hide() return end
		trinket.Icon:SetTexture(tIcon)
		trinket:Show()
		if event == 'PLAYER_ENTERING_WORLD' then
			CooldownFrame_Set(trinket.CD, 1, 1, 1)
		end
	end
end

local Enable = function(self, unit)
	--if(not unit:match("arena%d")) then return end
	local element = self.Gladiator
		
	if(element) then
		local trinket = element.Trinket
		local badge = element.Badge
		self:RegisterEvent("ARENA_OPPONENT_UPDATE", Update)
		self:RegisterEvent("PLAYER_ENTERING_WORLD", Update)

		if(trinket) then
			self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", Update)
			self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", Update)
			if not trinket.CD then
				trinket.CD = CreateFrame("Cooldown", nil, trinket, "CooldownFrameTemplate")
				trinket.CD:SetAllPoints(trinket)
			end
			
			if not trinket.Icon then
				trinket.Icon = trinket:CreateTexture(nil, "BORDER")
				trinket.Icon:SetAllPoints(trinket)
				trinket.Icon:SetTexture([[INTERFACE\ICONS\INV_MISC_QUESTIONMARK]])
			end

			if not trinket.Unavailable then
				trinket.Unavailable = trinket:CreateTexture(nil, "OVERLAY")
				trinket.Unavailable:SetAllPoints(trinket)
				trinket.Unavailable:SetTexture([[Interface\BUTTONS\UI-GroupLoot-Pass-Up]])
			end
			trinket:Show()
		end

		if(badge) then
			self:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS", Update)
			if not badge.Icon then
				badge.Icon = badge:CreateTexture(nil, "OVERLAY")
				badge.Icon:SetAllPoints(badge)
				badge.Icon:SetTexture([[INTERFACE\ICONS\INV_MISC_QUESTIONMARK]])
			end
			badge:Show()
		end

		return true
	end
end
 
local Disable = function(self)
	local element = self.Gladiator
	local trinket = element.Trinket
	local badge = element.Badge
	if(trinket or badge) then
		self:UnregisterEvent("ARENA_OPPONENT_UPDATE", Update)
		self:UnregisterEvent("PLAYER_ENTERING_WORLD", Update)		
		if trinket then
			self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", Update)
			self:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", Update)
			trinket:Hide()
		end
		if badge then
			self:UnregisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS", Update)
			badge:Hide() 
		end
	end
end
 
oUF:AddElement('Gladiator', Update, Enable, Disable)