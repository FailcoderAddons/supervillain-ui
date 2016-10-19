--[[
##########################################################
S V U I   By: Failcoder
##########################################################
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local unpack    = _G.unpack;
local select    = _G.select;
local pairs     = _G.pairs;
local ipairs    = _G.ipairs;
local type      = _G.type;
local error     = _G.error;
local pcall     = _G.pcall;
local tostring  = _G.tostring;
local tonumber  = _G.tonumber;
local tinsert 	= _G.tinsert;
local string 	= _G.string;
local math 		= _G.math;
local table 	= _G.table;
--[[ STRING METHODS ]]--
local format = string.format;
--[[ MATH METHODS ]]--
local abs, ceil, floor, round = math.abs, math.ceil, math.floor, math.round;
--[[ TABLE METHODS ]]--
local tremove, twipe = table.remove, table.wipe;
--[[ BINARY METHODS ]]--
local band, bor = bit.band, bit.bor;
--BLIZZARD API
local CreateFrame           = _G.CreateFrame;
local InCombatLockdown      = _G.InCombatLockdown;
--[[
##########################################################
GET ADDON DATA
##########################################################
]]--
local SV = _G['SVUI']
local L = SV.L
local LSM = _G.LibStub("LibSharedMedia-3.0")
local MOD = SV.NamePlates;
--[[
##########################################################
LOCALS
##########################################################
]]--
local HEALER_ROSTER = {};
local HEALER_SPECS = {
	["Druid"] = { ["Restoration"] = true, },
	["Paladin"] = { ["Holy"] = true, },
	["Priest"] = { ["Discipline"] = true, ["Holy"] = true, },
	["Shaman"] = { ["Restoration"] = true, },
	["Monk"] = { ["Mistweaver"] = true, },
}
local HEALER_SPELLS = {
	[47540] = "PRIEST", -- Penance
	[88625] = "PRIEST", -- Holy Word: Chastise
	[88684] = "PRIEST", -- Holy Word: Serenity
	[88685] = "PRIEST", -- Holy Word: Sanctuary
	[89485] = "PRIEST", -- Inner Focus
	[10060] = "PRIEST", -- Power Infusion
	[33206] = "PRIEST", -- Pain Suppression
	[62618] = "PRIEST", -- Power Word: Barrier
	[724]   = "PRIEST",   -- Lightwell
	[14751] = "PRIEST", -- Chakra
	[34861] = "PRIEST", -- Circle of Healing
	[47788] = "PRIEST", -- Guardian Spirit
	[18562] = "DRUID", -- Swiftmend
	[17116] = "DRUID", -- Nature's Swiftness
	[48438] = "DRUID", -- Wild Growth
	[33891] = "DRUID", -- Tree of Life
	[974]   = "SHAMAN", -- Earth Shield
	[17116] = "SHAMAN", -- Nature's Swiftness
	[16190] = "SHAMAN", -- Mana Tide Totem
	[61295] = "SHAMAN", -- Riptide
	[20473] = "PALADIN", -- Holy Shock
	[31842] = "PALADIN", -- Divine Favor
	[53563] = "PALADIN", -- Beacon of Light
	[31821] = "PALADIN", -- Aura Mastery
	[85222] = "PALADIN", -- Light of Dawn
	[115175] = "MONK", -- Soothing Mist
	[115294] = "MONK", -- Mana Tea
	[115310] = "MONK", -- Revival
	[116670] = "MONK", -- Uplift
	[116680] = "MONK", -- Thunder Focus Tea
	[116849] = "MONK", -- Life Cocoon
	[116995] = "MONK", -- Surging mist
	[119611] = "MONK", -- Renewing mist
	[132120] = "MONK", -- Envelopping Mist
}
--[[
##########################################################
HELPER FUNCTIONS
##########################################################
]]--
local function IsHealer(name)
	if(name) then
		local role = HEALER_ROSTER[name]
		if(not role) then
			RequestBattlefieldScoreData()
		else
			return true;
		end
	end
	return false;
end
--[[
##########################################################
CORE FUNCTIONS
##########################################################
]]--
function MOD:UpdateHealerPlate(plate, name, spellID)
	if(HEALER_SPELLS[spellID] and (not HEALER_ROSTER[name])) then
		HEALER_ROSTER[name] = true;
	end
	plate.isHealer = IsHealer(name);
end

do
	local NextUpdate = 0
	function MOD:UPDATE_BATTLEFIELD_SCORE()
		local now = GetTime()
		if(now > NextUpdate) then
			NextUpdate = now + 3;
		else
			return
		end

		local hasChanges = false;
		local scoreCount = GetNumBattlefieldScores();

		if(scoreCount > 0) then
			for i = 1, scoreCount do
				local name, _, _, _, _, faction, _, class, _, _, _, _, _, _, _, talentSpec = GetBattlefieldScore(i)
				if(name and class and HEALER_SPECS[class] and talentSpec) then
					local role = HEALER_SPECS[class][talentSpec]
					if(role) then
						HEALER_ROSTER[name] = true
						hasChanges = true
					elseif(HEALER_ROSTER[name]) then
						HEALER_ROSTER[name] = nil
						hasChanges = true
					end
				end
			end
			if hasChanges then
				TidyPlates:RequestDelegateUpdate()
			end
		end
	end
end
