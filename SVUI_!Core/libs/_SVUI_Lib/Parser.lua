--[[
 /$$$$$$$
| $$__  $$
| $$  \ $$/$$$$$$   /$$$$$$  /$$$$$$$  /$$$$$$   /$$$$$$
| $$$$$$$/____  $$ /$$__  $$/$$_____/ /$$__  $$ /$$__  $$
| $$____/ /$$$$$$$| $$  \__/  $$$$$$ | $$$$$$$$| $$  \__/
| $$     /$$__  $$| $$      \____  $$| $$_____/| $$
| $$    |  $$$$$$$| $$      /$$$$$$$/|  $$$$$$$| $$
|__/     \_______/|__/     |_______/  \_______/|__/



--]]

--[[ LOCALIZED GLOBALS ]]--
--GLOBAL NAMESPACE
local _G = getfenv(0);
--LUA
local select        = _G.select;
local assert        = _G.assert;
local type          = _G.type;
local error         = _G.error;
local pcall         = _G.pcall;
local print         = _G.print;
local ipairs        = _G.ipairs;
local pairs         = _G.pairs;
local next          = _G.next;
local rawset        = _G.rawset;
local rawget        = _G.rawget;
local tostring      = _G.tostring;
local tonumber      = _G.tonumber;
local getmetatable  = _G.getmetatable;
local setmetatable  = _G.setmetatable;
--STRING
local string        = _G.string;
local upper         = string.upper;
local format        = string.format;
local find          = string.find;
local match         = string.match;
local gsub          = string.gsub;
--MATH
local math          = _G.math;
local random        = math.random;
local floor         = math.floor
--TABLE
local table         = _G.table;
local tsort         = table.sort;
local tconcat       = table.concat;
local tremove       = _G.tremove;
local wipe          = _G.wipe;
local bit_band      = bit.band;
local bit_bor       = bit.bor;
-- Bit flags.
local AFFILIATION_MINE		= 0x00000001
local AFFILIATION_PARTY		= 0x00000002
local AFFILIATION_RAID		= 0x00000004
local AFFILIATION_OUTSIDER	= 0x00000008
local REACTION_FRIENDLY		= 0x00000010
local REACTION_NEUTRAL		= 0x00000020
local REACTION_HOSTILE		= 0x00000040
local CONTROL_HUMAN			= 0x00000100
local CONTROL_SERVER		= 0x00000200
local UNITTYPE_PLAYER		= 0x00000400
local UNITTYPE_NPC			= 0x00000800
local UNITTYPE_PET			= 0x00001000
local UNITTYPE_GUARDIAN		= 0x00002000
local UNITTYPE_OBJECT		= 0x00004000
local TARGET_TARGET			= 0x00010000
local TARGET_FOCUS			= 0x00020000
local OBJECT_NONE			= 0x80000000

local GUID_NONE				= "0x0000000000000000"

local MAX_BUFFS = 16
local MAX_DEBUFFS = 40

local AURA_TYPE_BUFF = "BUFF"
local AURA_TYPE_DEBUFF = "DEBUFF"

local UNIT_MAP_UPDATE_DELAY = 0.2
local PET_UPDATE_DELAY = 1
local REFLECT_HOLD_TIME = 3
local CLASS_HOLD_TIME = 300

local FLAGS_ME			= bit_bor(AFFILIATION_MINE, REACTION_FRIENDLY, CONTROL_HUMAN, UNITTYPE_PLAYER)
local FLAGS_MINE		= bit_bor(AFFILIATION_MINE, REACTION_FRIENDLY, CONTROL_HUMAN)
local FLAGS_MY_GUARDIAN	= bit_bor(AFFILIATION_MINE, REACTION_FRIENDLY, CONTROL_HUMAN, UNITTYPE_GUARDIAN)

--[[ LIB CONSTRUCT ]]--

local CoreName, CoreObject  = ...
local lib = Librarian:NewLibrary("Parser")

if not lib then return end -- No upgrade needed

--[[ LIB STORAGE ]]--

lib.EventCallback = {};

--[[ EVENT HANDLING ]]--

local LOG_EVENT, _R, _T = {},{},{};
local COMBAT_LOG_EVENTS = {
  SWING_DAMAGE            = function (...)
                                wipe(LOG_EVENT);
                                LOG_EVENT.type = "damage";
                                LOG_EVENT.amount, LOG_EVENT.overkill, LOG_EVENT.damage, LOG_EVENT.resisted, LOG_EVENT.blocked,
                                LOG_EVENT.absorbed, LOG_EVENT.crit, LOG_EVENT.glancing, LOG_EVENT.crushing, LOG_EVENT.multi = ...;
                            end,
  RANGE_DAMAGE            = function (...)
                                wipe(LOG_EVENT);
                                LOG_EVENT.type = "damage";
                                LOG_EVENT.ranged = true;
                                LOG_EVENT.spellID, LOG_EVENT.spellName, LOG_EVENT.school, LOG_EVENT.amount, LOG_EVENT.overkill,
                                LOG_EVENT.damage, LOG_EVENT.resisted, LOG_EVENT.blocked, LOG_EVENT.absorbed, LOG_EVENT.crit,
                                LOG_EVENT.glancing, LOG_EVENT.crushing, LOG_EVENT.offhand, LOG_EVENT.multi = ...;
                            end,
  DAMAGE_SPLIT            = function (...)
                                wipe(LOG_EVENT);
                                LOG_EVENT.type = "damage";
                                LOG_EVENT.spellID, LOG_EVENT.spellName, LOG_EVENT.school, LOG_EVENT.amount, LOG_EVENT.overkill,
                                LOG_EVENT.damage, LOG_EVENT.resisted, LOG_EVENT.blocked, LOG_EVENT.absorbed, LOG_EVENT.crit,
                                LOG_EVENT.glancing, LOG_EVENT.crushing, LOG_EVENT.offhand, LOG_EVENT.multi = ...;
                            end,
  SPELL_DAMAGE            = function (...)
                                wipe(LOG_EVENT);
                                LOG_EVENT.type = "damage";
                                LOG_EVENT.spellID, LOG_EVENT.spellName, LOG_EVENT.school, LOG_EVENT.amount, LOG_EVENT.overkill,
                                LOG_EVENT.damage, LOG_EVENT.resisted, LOG_EVENT.blocked, LOG_EVENT.absorbed, LOG_EVENT.crit,
                                LOG_EVENT.glancing, LOG_EVENT.crushing, LOG_EVENT.offhand, LOG_EVENT.multi = ...;
                            end,
  SPELL_PERIODIC_DAMAGE   = function (...)
                                wipe(LOG_EVENT);
                                LOG_EVENT.type = "damage";
                                LOG_EVENT.dot = true;
                                LOG_EVENT.spellID, LOG_EVENT.spellName, LOG_EVENT.school, LOG_EVENT.amount, LOG_EVENT.overkill,
                                LOG_EVENT.damage, LOG_EVENT.resisted, LOG_EVENT.blocked, LOG_EVENT.absorbed, LOG_EVENT.crit,
                                LOG_EVENT.glancing, LOG_EVENT.crushing, LOG_EVENT.offhand, LOG_EVENT.multi = ...;
                            end,
  SPELL_BUILDING_DAMAGE   = function (...)
                                wipe(LOG_EVENT);
                                LOG_EVENT.type = "damage";
                                LOG_EVENT.spellID, LOG_EVENT.spellName, LOG_EVENT.school, LOG_EVENT.amount, LOG_EVENT.overkill,
                                LOG_EVENT.damage, LOG_EVENT.resisted, LOG_EVENT.blocked, LOG_EVENT.absorbed, LOG_EVENT.crit,
                                LOG_EVENT.glancing, LOG_EVENT.crushing = ...;
                            end,
  DAMAGE_SHIELD           = function (...)
                                wipe(LOG_EVENT);
                                LOG_EVENT.type = "damage";
                                LOG_EVENT.shield = true;
                                LOG_EVENT.spellID, LOG_EVENT.spellName, LOG_EVENT.school, LOG_EVENT.amount, LOG_EVENT.overkill,
                                LOG_EVENT.damage, LOG_EVENT.resisted, LOG_EVENT.blocked, LOG_EVENT.absorbed, LOG_EVENT.crit,
                                LOG_EVENT.glancing, LOG_EVENT.crushing = ...;
                            end,
  SWING_MISSED            = function (...)
                                wipe(LOG_EVENT);
                                LOG_EVENT.type = "miss";
                                LOG_EVENT.miss, LOG_EVENT.offhand, LOG_EVENT.multi, LOG_EVENT.amount = ...;
                            end,
  RANGE_MISSED            = function (...)
                                wipe(LOG_EVENT);
                                LOG_EVENT.type = "miss";
                                LOG_EVENT.ranged = true;
                                LOG_EVENT.spellID, LOG_EVENT.spellName, LOG_EVENT.school, LOG_EVENT.miss,
                                LOG_EVENT.offhand, LOG_EVENT.multi, LOG_EVENT.amount = ...;
                            end,
  SPELL_MISSED            = function (...)
                                wipe(LOG_EVENT);
                                LOG_EVENT.type = "miss";
                                LOG_EVENT.spellID, LOG_EVENT.spellName, LOG_EVENT.school, LOG_EVENT.miss,
                                LOG_EVENT.offhand, LOG_EVENT.multi, LOG_EVENT.amount = ...;
                            end,
  SPELL_PERIODIC_MISSED   = function (...)
                                wipe(LOG_EVENT);
                                LOG_EVENT.type = "miss";
                                LOG_EVENT.spellID, LOG_EVENT.spellName, LOG_EVENT.school, LOG_EVENT.miss,
                                LOG_EVENT.offhand, LOG_EVENT.multi, LOG_EVENT.amount = ...;
                            end,
  DAMAGE_SHIELD_MISSED    = function (...)
                                wipe(LOG_EVENT);
                                LOG_EVENT.type = "miss";
                                LOG_EVENT.shield = true;
                                LOG_EVENT.spellID, LOG_EVENT.spellName, LOG_EVENT.school, LOG_EVENT.miss,
                                LOG_EVENT.offhand, LOG_EVENT.multi, LOG_EVENT.amount = ...;
                            end,
  SPELL_DISPEL_FAILED     = function (...)
                                wipe(LOG_EVENT);
                                LOG_EVENT.type = "miss";
                                LOG_EVENT.miss = "RESIST";
                                LOG_EVENT.spellID, LOG_EVENT.spellName, LOG_EVENT.school, LOG_EVENT.spellID2,
                                LOG_EVENT.spellName2, LOG_EVENT.school2 = ...;
                            end,
  SPELL_PERIODIC_ENERGIZE = function (...)
                                wipe(LOG_EVENT);
                                LOG_EVENT.type = "power";
                                LOG_EVENT.gain = true;
                                LOG_EVENT.spellID, LOG_EVENT.spellName, LOG_EVENT.school, LOG_EVENT.amount, LOG_EVENT.powerType = ...;
                            end,
  SPELL_PERIODIC_DRAIN    = function (...)
                                wipe(LOG_EVENT);
                                LOG_EVENT.type = "power";
                                LOG_EVENT.drain = true;
                                LOG_EVENT.spellID, LOG_EVENT.spellName, LOG_EVENT.school, LOG_EVENT.amount,
                                LOG_EVENT.powerType, LOG_EVENT.amount2 = ...;
                            end,
  SPELL_PERIODIC_LEECH    = function (...)
                                wipe(LOG_EVENT);
                                LOG_EVENT.type = "power";
                                LOG_EVENT.leech = true;
                                LOG_EVENT.spellID, LOG_EVENT.spellName, LOG_EVENT.school, LOG_EVENT.amount,
                                LOG_EVENT.powerType, LOG_EVENT.amount2 = ...;
                            end,
  SPELL_ENERGIZE          = function (...)
                                wipe(LOG_EVENT);
                                LOG_EVENT.type = "power";
                                LOG_EVENT.gain = true;
                                LOG_EVENT.spellID, LOG_EVENT.spellName, LOG_EVENT.school, LOG_EVENT.amount, LOG_EVENT.powerType = ...;
                            end,
  SPELL_DRAIN             = function (...)
                                wipe(LOG_EVENT);
                                LOG_EVENT.type = "power";
                                LOG_EVENT.drain = true;
                                LOG_EVENT.spellID, LOG_EVENT.spellName, LOG_EVENT.school, LOG_EVENT.amount,
                                LOG_EVENT.powerType, LOG_EVENT.amount2 = ...;
                            end,
  SPELL_LEECH             = function (...)
                                wipe(LOG_EVENT);
                                LOG_EVENT.type = "power";
                                LOG_EVENT.leech = true;
                                LOG_EVENT.spellID, LOG_EVENT.spellName, LOG_EVENT.school, LOG_EVENT.amount,
                                LOG_EVENT.powerType, LOG_EVENT.amount2 = ...;
                            end,
  SPELL_STOLEN            = function (...)
                                wipe(LOG_EVENT);
                                LOG_EVENT.type = "dispel";
                                LOG_EVENT.spellID, LOG_EVENT.spellName, LOG_EVENT.school, LOG_EVENT.spellID2,
                                LOG_EVENT.spellName2, LOG_EVENT.school2, LOG_EVENT.aura = ...;
                            end,
  SPELL_DISPEL            = function (...)
                                wipe(LOG_EVENT);
                                LOG_EVENT.type = "dispel";
                                LOG_EVENT.spellID, LOG_EVENT.spellName, LOG_EVENT.school, LOG_EVENT.spellID2,
                                LOG_EVENT.spellName2, LOG_EVENT.school2, LOG_EVENT.aura = ...;
                            end,
  SPELL_HEAL              = function (...)
                                wipe(LOG_EVENT);
                                LOG_EVENT.type = "heal";
                                LOG_EVENT.spellID, LOG_EVENT.spellName, LOG_EVENT.school, LOG_EVENT.amount,
                                LOG_EVENT.overheal, LOG_EVENT.absorbed, LOG_EVENT.crit, LOG_EVENT.multi = ...;
                            end,
  SPELL_PERIODIC_HEAL     = function (...)
                                wipe(LOG_EVENT);
                                LOG_EVENT.type = "heal";
                                LOG_EVENT.hot = true;
                                LOG_EVENT.spellID, LOG_EVENT.spellName, LOG_EVENT.school, LOG_EVENT.amount,
                                LOG_EVENT.overheal, LOG_EVENT.absorbed, LOG_EVENT.crit, LOG_EVENT.multi = ...;
                            end,
  ENVIRONMENTAL_DAMAGE    = function (...)
                                wipe(LOG_EVENT);
                                LOG_EVENT.type = "environmental";
                                LOG_EVENT.hazard, LOG_EVENT.amount, LOG_EVENT.overkill, LOG_EVENT.damage,
                                LOG_EVENT.resisted, LOG_EVENT.blocked, LOG_EVENT.absorbed, LOG_EVENT.crit,
                                LOG_EVENT.glancing, LOG_EVENT.crushing = ...;
                            end,
  SPELL_INTERRUPT         = function (...)
                                wipe(LOG_EVENT);
                                LOG_EVENT.type = "interrupt";
                                LOG_EVENT.spellID, LOG_EVENT.spellName, LOG_EVENT.school, LOG_EVENT.spellID2,
                                LOG_EVENT.spellName2, LOG_EVENT.school2 = ...;
                            end,
  SPELL_AURA_APPLIED      = function (...)
                                wipe(LOG_EVENT);
                                LOG_EVENT.type = "aura";
                                LOG_EVENT.spellID, LOG_EVENT.spellName, LOG_EVENT.school, LOG_EVENT.aura, LOG_EVENT.amount = ...;
                            end,
  SPELL_AURA_APPLIED_DOSE = function (...)
                                wipe(LOG_EVENT);
                                LOG_EVENT.type = "aura";
                                LOG_EVENT.dose = true;
                                LOG_EVENT.spellID, LOG_EVENT.spellName, LOG_EVENT.school, LOG_EVENT.aura, LOG_EVENT.amount = ...;
                            end,
  SPELL_AURA_REMOVED      = function (...)
                                wipe(LOG_EVENT);
                                LOG_EVENT.type = "aura";
                                LOG_EVENT.faded = true;
                                LOG_EVENT.spellID, LOG_EVENT.spellName, LOG_EVENT.school, LOG_EVENT.aura, LOG_EVENT.amount = ...;
                            end,
  SPELL_AURA_REMOVED_DOSE = function (...)
                                wipe(LOG_EVENT);
                                LOG_EVENT.type = "aura";
                                LOG_EVENT.faded = true;
                                LOG_EVENT.dose = true;
                                LOG_EVENT.spellID, LOG_EVENT.spellName, LOG_EVENT.school, LOG_EVENT.aura, LOG_EVENT.amount = ...;
                            end,
  ENCHANT_APPLIED         = function (...)
                                wipe(LOG_EVENT);
                                LOG_EVENT.type = "enchant";
                                LOG_EVENT.spellName, LOG_EVENT.itemID, LOG_EVENT.itemName = ...;
                            end,
  ENCHANT_REMOVED         = function (...)
                                wipe(LOG_EVENT);
                                LOG_EVENT.type = "enchant";
                                LOG_EVENT.faded = true;
                                LOG_EVENT.spellName, LOG_EVENT.itemID, LOG_EVENT.itemName = ...;
                            end,
  SPELL_CAST_START        = function (...)
                                wipe(LOG_EVENT);
                                LOG_EVENT.type = "cast";
                                LOG_EVENT.spellID, LOG_EVENT.spellName, LOG_EVENT.school = ...;
                            end,
  PARTY_KILL              = function (...)
                                wipe(LOG_EVENT);
                                LOG_EVENT.type = "kill";
                            end,
  SPELL_EXTRA_ATTACKS     = function (...)
                                wipe(LOG_EVENT);
                                LOG_EVENT.type = "extraattacks";
                                LOG_EVENT.spellID, LOG_EVENT.spellName, LOG_EVENT.school, LOG_EVENT.amount = ...;
                            end
};
local FULL_PARSE = {
  SPELL_AURA_APPLIED = true,
  SPELL_AURA_REMOVED = true,
  SPELL_AURA_APPLIED_DOSE = true,
  SPELL_AURA_REMOVED_DOSE = true,
  SPELL_CAST_START = true,
};
local PROXY_UNITS = { player = true, pet = true };

local function flagTest(a, b, c)
  if(c) then
    if(bit_band(a, b) > 0) then return true end
  else
    if(bit_band(a, b) == b) then return true end
  end
end
--[[ LIB METHODS ]]--

function lib:Register(event, obj, callback)
    local key = obj.Schema
    if(not self.EventCallback[event]) then
        self.EventCallback[event] = {}
    end
    self.EventCallback[event][key] = callback;
end;

function lib:Unregister(event, obj)
    local key = obj.Schema
    if((not self.EventCallback[event]) or (not self.EventCallback[event][key])) then
        return
    end
    self.EventCallback[event][key] = nil;
end;

function lib:BroadCast(event)
  if(not self.EventCallback[event]) then return end;
  for key,fn in pairs(self.EventCallback[event]) do
    local obj = CoreObject[key];
    local _, catch = pcall(fn, obj, LOG_EVENT)
    if(catch) then
        CoreObject:HandleError("Librarian:Parser", "BroadCast", catch)
    end
  end
end;

--[[ COMBAT LOG PARSING ]]--

function lib:COMBAT_LOG_EVENT_UNFILTERED(timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, ...)
  local fn = COMBAT_LOG_EVENTS[event]
  if (not fn) then return end

  if (sourceGUID == destGUID and _T[destGUID] and event == "SPELL_DAMAGE") then
    local skillID = ...
    if (skillID == _R[destGUID]) then
      _T[destGUID] = nil;
      _R[destGUID] = nil;
      sourceGUID = playerGUID;
      sourceName = playerName;
      sourceFlags = FLAGS_ME;
    end
  end

  local sourceUnit = unitMap[sourceGUID] or petMap[sourceGUID];
  local destUnit = unitMap[destGUID] or petMap[destGUID];
  if ((not sourceUnit) and flagTest(sourceFlags, FLAGS_MINE)) then
    sourceUnit = flagTest(sourceFlags, FLAGS_MY_GUARDIAN) and "pet" or "player";
  end
  if ((not destUnit) and flagTest(destFlags, FLAGS_MINE)) then
    destUnit = flagTest(destFlags, FLAGS_MY_GUARDIAN) and "pet" or "player";
  end
  if ((not FULL_PARSE[event]) and (not PROXY_UNITS[sourceUnit]) and (not PROXY_UNITS[destUnit])) then
    return;
  end

  fn(...)

  LOG_EVENT.hostile = flagTest(sourceFlags, COMBATLOG_OBJECT_REACTION_HOSTILE)
  LOG_EVENT.sourceGUID = sourceGUID
  LOG_EVENT.sourceName = sourceName
  LOG_EVENT.sourceFlags = sourceFlags
  LOG_EVENT.sourceUnit = sourceUnit
  LOG_EVENT.destGUID = destGUID
  LOG_EVENT.destName = destName
  LOG_EVENT.destFlags = destFlags
  LOG_EVENT.destUnit = destUnit

  if (LOG_EVENT.type == "miss" and LOG_EVENT.miss == "REFLECT" and LOG_EVENT.destUnit == "player") then
    for guid, reflectTime in pairs(_T) do
      if (timestamp - reflectTime > REFLECT_HOLD_TIME) then
        _T[guid] = nil
        _R[guid] = nil
      end
    end

    _T[sourceGUID] = timestamp
    _R[sourceGUID] = LOG_EVENT.spellID
  end

  self:BroadCast()
end

--[[ COMMON EVENTS ]]--

local Library_OnEvent = function(self, event, ...)
  local fn = self[event]
  if(fn and type(fn) == "function") then
      local _, catch = pcall(fn, self, ...)
      if(catch) then
          CoreObject:HandleError("Librarian:Parser", event, catch)
      end
  end
end

lib.EventManager = CreateFrame("Frame", nil)
lib.EventManager:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
lib.EventManager:SetScript("OnEvent", Library_OnEvent)
