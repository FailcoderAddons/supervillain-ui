--[[
##########################################################
S V U I   By: S.Jackson
##########################################################
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local unpack            = _G.unpack;
local select            = _G.select;
local assert            = _G.assert;
local type              = _G.type;
local error             = _G.error;
local pcall             = _G.pcall;
local print             = _G.print;
local ipairs            = _G.ipairs;
local pairs             = _G.pairs;
local next              = _G.next;
local tostring          = _G.tostring;
local tonumber          = _G.tonumber;
local collectgarbage    = _G.collectgarbage;
local tinsert   = _G.tinsert;
local tremove   = _G.tremove;
local string    = _G.string;
local math      = _G.math;
local bit       = _G.bit;
local table     = _G.table;
--[[ STRING METHODS ]]--
local format, find, lower, match = string.format, string.find, string.lower, string.match;
--[[ MATH METHODS ]]--
local abs, ceil, floor, round = math.abs, math.ceil, math.floor, math.round;  -- Basic
local fmod, modf, sqrt = math.fmod, math.modf, math.sqrt;   -- Algebra
local atan2, cos, deg, rad, sin = math.atan2, math.cos, math.deg, math.rad, math.sin;  -- Trigonometry
local min, huge, random = math.min, math.huge, math.random;  -- Uncommon
local sqrt2, max = math.sqrt(2), math.max;
--[[ TABLE METHODS ]]--
local tcopy, twipe, tsort, tconcat, tdump = table.copy, table.wipe, table.sort, table.concat, table.dump;
--[[ BINARY METHODS ]]--
local band = bit.band;
--BLIZZARD API
local InCombatLockdown      = _G.InCombatLockdown;
local CreateFrame           = _G.CreateFrame;
local IsInRaid              = _G.IsInRaid;
local IsInGroup             = _G.IsInGroup;
local IsInInstance          = _G.IsInInstance;
--[[
##########################################################
GET ADDON DATA
##########################################################
]]--
local SV = _G["SVUI"];
local L = SV.L;
local PLUGIN = select(2, ...);
local CONFIGS = SV.defaults[PLUGIN.Schema];

local JOURNAL_CACHE = {};

local function CacheEncounterData()
	local instanceID = EJ_GetCurrentInstance()
	local difficultyID = GetDungeonDifficultyID()
	EJ_SetDifficulty(difficultyID)
	local bossIndex = 1;
	local _, _, encounterID = EJ_GetEncounterInfoByIndex(bossIndex);
	while encounterID do
		local stack, encounter, _, _, curSectionID = {}, EJ_GetEncounterInfo(encounterID);

		repeat
			local title, desc, _, _, _, siblingID, nextSectionID = EJ_GetSectionInfo(curSectionID)
			JOURNAL_CACHE[curSectionID] = {title, desc}
			table.insert(stack, siblingID)
			table.insert(stack, nextSectionID)
			curSectionID = table.remove(stack)
		until not curSectionID

		bossIndex = bossIndex + 1;
		_, _, encounterID = EJ_GetEncounterInfoByIndex(bossIndex);
	end
end

function PLUGIN:InitializeGuides()
	LoadAddOn("Blizzard_EncounterJournal")
	CacheEncounterData()
end
