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
local ceil          = math.ceil
local random 				= math.random
--TABLE
local table         = _G.table;
local wipe          = _G.wipe;
--BLIZZARD API
local GetTime       		= _G.GetTime;
local GetSpecialization 	= _G.GetSpecialization;
local UnitAura         		= _G.UnitAura;
local UnitIsCharmed         = _G.UnitIsCharmed;
local UnitCanAttack         = _G.UnitCanAttack;
local GetSpellInfo      	= _G.GetSpellInfo;
local GetActiveSpecGroup  	= _G.GetActiveSpecGroup;

local _, ns = ...
local oUF = ns.oUF or oUF

local SymbiosisName = GetSpellInfo(110309)
local CleanseName = GetSpellInfo(4987)

local addon = {}
ns.oUF_RaidDebuffs = addon
_G.oUF_RaidDebuffs = ns.oUF_RaidDebuffs

local debuff_data = {}
addon.DebuffData = debuff_data


addon.ShowDispelableDebuff = true
addon.FilterDispellableDebuff = true
addon.MatchBySpellName = true


addon.priority = 10

local function add(spell, priority)
	if addon.MatchBySpellName and type(spell) == 'number' then
		spell = GetSpellInfo(spell)
	end

	debuff_data[spell] = addon.priority + priority
end

function addon:RegisterDebuffs(t)
	for spell, value in pairs(t) do
		if type(t[spell]) == 'boolean' then
			local oldValue = t[spell]
			t[spell] = {
				['enable'] = oldValue,
				['priority'] = 0
			}
		else
			if t[spell].enable then
				add(spell, t[spell].priority)
			end
		end
	end
end

function addon:ResetDebuffData()
	wipe(debuff_data)
end

local DispellColor = {
	['Magic']	= {.2, .6, 1},
	['Curse']	= {.6, 0.1, 1},
	['Disease']	= {.6, .4, 0},
	['Poison']	= {0, .6, 0},
	['none'] = { .23, .23, .23},
}

local DispellPriority = {
	['Magic']	= 4,
	['Curse']	= 3,
	['Disease']	= 2,
	['Poison']	= 1,
}

local DispellFilter
do
	local dispellClasses = {
		['PRIEST'] = {
			['Magic'] = true,
			['Disease'] = true,
		},
		['SHAMAN'] = {
			['Magic'] = false,
			['Curse'] = true,
		},
		['PALADIN'] = {
			['Poison'] = true,
			['Magic'] = false,
			['Disease'] = true,
		},
		['MAGE'] = {
			['Curse'] = true,
		},
		['DRUID'] = {
			['Magic'] = false,
			['Curse'] = true,
			['Poison'] = true,
			['Disease'] = false,
		},
		['MONK'] = {
			['Magic'] = false,
			['Disease'] = true,
			['Poison'] = true,
		},
	}

	DispellFilter = dispellClasses[select(2, UnitClass('player'))] or {}
end

local DEMO_SPELLS = {116281,116784,116417,116942,116161,117708,118303,118048,118135,117878,117949}

local function CheckTalentTree(tree)
	local activeGroup = GetActiveSpecGroup()
	if activeGroup and GetSpecialization(false, false, activeGroup) then
		return tree == GetSpecialization(false, false, activeGroup)
	end
end

local playerClass = select(2, UnitClass('player'))
local function CheckSpec(self, event, levels)
	-- Not interested in gained points from leveling
	if event == "CHARACTER_POINTS_CHANGED" and levels > 0 then return end

	--Check for certain talents to see if we can dispel magic or not
	if playerClass == "PRIEST" then
		if CheckTalentTree(3) then
			DispellFilter.Disease = false
		else
			DispellFilter.Disease = true
		end
	elseif playerClass == "PALADIN" then
		if CheckTalentTree(1) then
			DispellFilter.Magic = true
		else
			DispellFilter.Magic = false
		end
	elseif playerClass == "SHAMAN" then
		if CheckTalentTree(3) then
			DispellFilter.Magic = true
		else
			DispellFilter.Magic = false
		end
	elseif playerClass == "DRUID" then
		if CheckTalentTree(4) then
			DispellFilter.Magic = true
		else
			DispellFilter.Magic = false
		end
	elseif playerClass == "MONK" then
		if CheckTalentTree(2) then
			DispellFilter.Magic = true
		else
			DispellFilter.Magic = false
		end
	end
end

local function CheckSymbiosis()
	if GetSpellInfo(SymbiosisName) == CleanseName then
		DispellFilter.Disease = true
	else
		DispellFilter.Disease = false
	end
end

local function formatTime(s)
	if s > 60 then
		return format('%dm', s/60), s%60
	elseif s < 1 then
		return format("%.1f", s), s - floor(s)
	else
		return format('%d', s), s - floor(s)
	end
end

local abs = math.abs
local function OnUpdate(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed >= 0.1 then
		local timeLeft = self.endTime - GetTime()
		if self.reverse then timeLeft = abs((self.endTime - GetTime()) - self.duration) end
		if timeLeft > 0 then
			local text = formatTime(timeLeft)
			self.time:SetText(text)
		else
			self:SetScript('OnUpdate', nil)
			self.time:Hide()
		end
		self.elapsed = 0
	end
end

local function UpdateDebuff(self, name, icon, count, debuffType, duration, endTime, spellId)
	local f = self.RaidDebuffs

	if name then
		f.icon:SetTexture(icon)
		f.icon:Show()
		f.duration = duration

		if f.count then
			if count and (count > 1) then
				f.count:SetText(count)
				f.count:Show()
			else
				f.count:SetText("")
				f.count:Hide()
			end
		end

		if f.time then
			if duration and (duration > 0) then
				f.endTime = endTime
				f.nextUpdate = 0
				f:SetScript('OnUpdate', OnUpdate)
				f.time:Show()
			else
				f:SetScript('OnUpdate', nil)
				f.time:Hide()
			end
		end

		if f.cooldown then
			if duration and (duration > 0) then
				f.cooldown:SetCooldown(endTime - duration, duration)
				f.cooldown:Show()
			else
				f.cooldown:Hide()
			end
		end

		local c = DispellColor[debuffType] or DispellColor.none
		f:SetBackdropBorderColor(c[1], c[2], c[3])

		f:Show()
		if (f.nameText) then f.nameText:Hide(); end
	else
		f:Hide()
		if (f.nameText) then f.nameText:Show(); end
	end
end

local blackList = {
	[105171] = true, -- Deep Corruption
	[108220] = true, -- Deep Corruption
	[116095] = true, -- Disable, Slow
	[137637] = true, -- Warbringer, Slow
}

local function Update(self, event, unit)
	if unit ~= self.unit then return end
	local _name, _icon, _count, _dtype, _duration, _endTime, _spellId
	local _priority, priority = 0, 0

	--store if the unit its charmed, mind controlled units (Imperial Vizier Zor'lok: Convert)
	local isCharmed = UnitIsCharmed(unit)

	--store if we cand attack that unit, if its so the unit its hostile (Amber-Shaper Un'sok: Reshape Life)
	local canAttack = UnitCanAttack("player", unit)

	for i = 1, 40 do
		local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId, canApplyAura, isBossDebuff = UnitAura(unit, i, 'HARMFUL')
		if (not name) then break end

		--we coudln't dispell if the unit its charmed, or its not friendly
		if addon.ShowDispelableDebuff and debuffType and (not isCharmed) and (not canAttack) then

			if addon.FilterDispellableDebuff then
				DispellPriority[debuffType] = (DispellPriority[debuffType] or 0) + addon.priority --Make Dispell buffs on top of Boss Debuffs
				priority = DispellFilter[debuffType] and DispellPriority[debuffType] or 0
				if priority == 0 then
					debuffType = nil
				end
			else
				priority = DispellPriority[debuffType] or 0
			end

			if priority > _priority then
				_priority, _name, _icon, _count, _dtype, _duration, _endTime, _spellId = priority, name, icon, count, debuffType, duration, expirationTime, spellId
			end
		end

		priority = debuff_data[addon.MatchBySpellName and name or spellId]
		if priority and not blackList[spellId] and (priority > _priority) then
			_priority, _name, _icon, _count, _dtype, _duration, _endTime, _spellId = priority, name, icon, count, debuffType, duration, expirationTime, spellId
		end
	end

	if(self.RaidDebuffs.forceShow) then
		_spellId = DEMO_SPELLS[random(1, #DEMO_SPELLS)];
		_name, rank, _icon = GetSpellInfo(_spellId)
		_count, _dtype, _duration, _endTime = 5, 'Magic', 0, 60
	end

	UpdateDebuff(self, _name, _icon, _count, _dtype, _duration, _endTime, _spellId)

	--Reset the DispellPriority
	DispellPriority = {
		['Magic']	= 4,
		['Curse']	= 3,
		['Disease']	= 2,
		['Poison']	= 1,
	}
end


local function Enable(self)
	if self.RaidDebuffs then
		self:RegisterEvent('UNIT_AURA', Update)
		return true
	end
	--Need to run these always
	self:RegisterEvent("PLAYER_TALENT_UPDATE", CheckSpec)
	self:RegisterEvent("CHARACTER_POINTS_CHANGED", CheckSpec)
	if playerClass == "DRUID" then
		self:RegisterEvent("SPELLS_CHANGED", CheckSymbiosis)
	end
end

local function Disable(self)
	if self.RaidDebuffs then
		self:UnregisterEvent('UNIT_AURA', Update)
		self.RaidDebuffs:Hide()
	end
	self:UnregisterEvent("PLAYER_TALENT_UPDATE", CheckSpec)
	self:UnregisterEvent("CHARACTER_POINTS_CHANGED", CheckSpec)
	if playerClass == "DRUID" then
		self:UnregisterEvent("SPELLS_CHANGED", CheckSymbiosis)
	end
end

oUF:AddElement('RaidDebuffs', Update, Enable, Disable)
