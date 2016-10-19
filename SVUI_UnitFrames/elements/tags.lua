--[[
##############################################################################
S V U I  By: Failcoder               #
##############################################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
--LUA
local unpack        = _G.unpack;
local select        = _G.select;
local assert        = _G.assert;
local type          = _G.type;
--STRING
local string        = _G.string;
local upper         = string.upper;
local format        = string.format;
local find          = string.find;
local match         = string.match;
local sub         	= string.sub;
local gsub          = string.gsub;
local byte 			= string.byte;
local upper 		= string.upper;
local len         	= string.len;
--MATH
local math          = _G.math;
local floor         = math.floor
--TABLE
local table         = _G.table;
local tsort         = table.sort;
local tconcat       = table.concat;
local tinsert       = _G.tinsert;
local tremove       = _G.tremove;
local twipe         = _G.wipe;

local CreateFrame           = _G.CreateFrame;
local InCombatLockdown      = _G.InCombatLockdown;
--[[
##########################################################
GET ADDON DATA
##########################################################
]]--
local SV = _G['SVUI']
local L = SV.L;
local LSM = _G.LibStub("LibSharedMedia-3.0")
local MOD = SV.UnitFrames

if(not MOD) then return end

local oUF_SVUI = MOD.oUF
assert(oUF_SVUI, "SVUI UnitFrames: unable to locate oUF.")
--[[
##########################################################
LOCAL VARIABLES
##########################################################
]]--
local Harmony = {
	[0] = {1, 1, 1},
	[1] = {.57, .63, .35, 1},
	[2] = {.47, .63, .35, 1},
	[3] = {.37, .63, .35, 1},
	[4] = {.27, .63, .33, 1},
	[5] = {.17, .63, .33, 1}
}
local SKULL_ICON = "|TInterface\\TARGETINGFRAME\\UI-TargetingFrame-Skull.blp:16:16|t";
--[[
##########################################################
LOCAL FUNCTIONS
##########################################################
]]--
local function Hex(r, g, b)
	if(not r) then
		r, g, b = 1, 1, 1;
	elseif type(r) == "table" then
		if r.r then r, g, b = r.r, r.g, r.b else r, g, b = unpack(r) end
	end
	return ("|cff%02x%02x%02x"):format(r*255, g*255, b*255)
end

local function TruncateString(value)
	if value >= 1e9 then
		return ("%.1fb"):format(value / 1e9):gsub("%.?0 + ([kmb])$", "%1")
	elseif value >= 1e6 then
		return ("%.1fm"):format(value / 1e6):gsub("%.?0 + ([kmb])$", "%1")
	elseif value >= 1e3 or value <= -1e3 then
		return ("%.1fk"):format(value / 1e3):gsub("%.?0 + ([kmb])$", "%1")
	else
		return value
	end
end

local function SetTagStyle(style, min, max)
	if max == 0 then max = 1 end
	local result;
	if style == "DEFICIT" then
		local result = max - min;
		if result <= 0 then
			return ""
		else
			return ("-%s"):format(TruncateString(result))
		end
	elseif style == "PERCENT" then
		local prct = min / max * 100
		result = ("%.1f"):format(prct)
		result = ("%s%%"):format(result)
		result = result:gsub(".0%%", "%%")
		return result
	elseif style == "CURRENT" or ((style == "CURRENT_MAX" or style == "CURRENT_MAX_PERCENT" or style == "CURRENT_PERCENT") and min == max) then
		return ("%s"):format(TruncateString(min))
	elseif style == "CURRENT_MAX" then
		return ("%s - %s"):format(TruncateString(min), TruncateString(max))
	elseif style == "CURRENT_PERCENT" then
		local prct = min / max * 100
		result = ("%.1f"):format(prct)
		result = ("%s - %s%%"):format(TruncateString(min), result)
		result = result:gsub(".0%%", "%%")
		return result
	elseif style == "CURRENT_MAX_PERCENT" then
		local prct = min / max * 100
		result = ("%.1f"):format(prct)
		result = ("%s - %s - %s%%"):format(TruncateString(min), TruncateString(max), result)
		result = result:gsub(".0%%", "%%")
		return result
	end
end

local function TrimTagText(text, limit, ellipsis)
	local length = text:len()
	if length <= limit then
		return text
	else
		local overall, charPos = 0, 1;
		while charPos <= length do
			overall = overall + 1;
			local parse = text:byte(charPos)
			if parse > 0 and parse <= 127 then
				charPos = charPos + 1
			elseif parse >= 192 and parse <= 223 then
				charPos = charPos + 2
			elseif parse >= 224 and parse <= 239 then
				charPos = charPos + 3
			elseif parse >= 240 and parse <= 247 then
				charPos = charPos + 4
			end
			if overall == limit then break end
		end
		if overall == limit and charPos <= length then
			return text:sub(1, charPos - 1)..(ellipsis and "..." or "")
		else
			return text
		end
	end
end

local function GetClassPower(class)
	local currentPower, maxPower, r, g, b = 0, 0, 0, 0, 0;
	local spec = GetSpecialization()
	if class == "PALADIN"then
		currentPower = UnitPower("player", SPELL_POWER_HOLY_POWER)
		maxPower = UnitPowerMax("player", SPELL_POWER_HOLY_POWER)
		r, g, b = 228 / 255, 225 / 255, 16 / 255
	elseif class == "MONK"then
		currentPower = UnitPower("player", SPELL_POWER_CHI)
		maxPower = UnitPowerMax("player", SPELL_POWER_CHI)
		r, g, b = unpack(Harmony[currentPower])
	elseif class == "DRUID" and GetShapeshiftFormID() == MOONKIN_FORM then
		currentPower = UnitPower("player", SPELL_POWER_ECLIPSE)
		maxPower = UnitPowerMax("player", SPELL_POWER_ECLIPSE)
		r, g, b = .30, .52, .90
		--[[
		if GetEclipseDirection() == "moon"then
			r, g, b = .80, .82, .60
		else
			r, g, b = .30, .52, .90
		end
		]]--
	elseif class == "PRIEST" and spec == SPEC_PRIEST_SHADOW and UnitLevel("player") > SHADOW_ORBS_SHOW_LEVEL then
		currentPower = UnitPower("player", SPELL_POWER_SHADOW_ORBS)
		maxPower = UnitPowerMax("player", SPELL_POWER_SHADOW_ORBS)
		r, g, b = 1, 1, 1
	elseif class == "WARLOCK"then
		if spec == SPEC_WARLOCK_DESTRUCTION then
			currentPower = UnitPower("player", SPELL_POWER_BURNING_EMBERS, true)
			maxPower = UnitPowerMax("player", SPELL_POWER_BURNING_EMBERS, true)
			currentPower = floor(currentPower / 10)
			maxPower = floor(maxPower / 10)
			r, g, b = 230 / 255, 95 / 255, 95 / 255
		elseif spec == SPEC_WARLOCK_AFFLICTION then
			currentPower = UnitPower("player", SPELL_POWER_SOUL_SHARDS)
			maxPower = UnitPowerMax("player", SPELL_POWER_SOUL_SHARDS)
			r, g, b = 148 / 255, 130 / 255, 201 / 255
		elseif spec == SPEC_WARLOCK_DEMONOLOGY then
			currentPower = UnitPower("player", SPELL_POWER_DEMONIC_FURY)
			maxPower = UnitPowerMax("player", SPELL_POWER_DEMONIC_FURY)
			r, g, b = 148 / 255, 130 / 255, 201 / 255
		end
	end
	return currentPower, maxPower, r, g, b
end

local function GetStatusString(unit)
	local afk, dnd, c = UnitIsAFK(unit), UnitIsDND(unit), UnitClassification(unit)
	local preString, postString = "","";
	if afk then
		preString = ("|cffFFFFFF[|r|cffFF0000%s|r|cffFFFFFF] |r"):format(DEFAULT_AFK_MESSAGE)
	elseif dnd then
		preString = ("|cffFFFFFF[|r|cffFF0000%s|r|cffFFFFFF] |r"):format(L["DND"])
	elseif(c == "rare" or c == "rareelite") then
		preString = ("|cff00FFFF%s |r"):format("Rare")
	end
	if(c == "rareelite" or c == "elite") then
		postString = "+"
	end
	return preString, postString
end

local function UnitName(unit)
	local name = _G.UnitName(unit)
	if name == UNKNOWN and SV.class == "MONK" and UnitIsUnit(unit, "pet") then
		name = ("%s\'s Spirit"):format(_G.UnitName("player"))
	else
		return name
	end
end
--[[
##########################################################
TAG EVENTS
##########################################################
]]--
oUF_SVUI.Tags.Events["name:color"] = "UNIT_NAME_UPDATE";
for i = 1, 30 do
	oUF_SVUI.Tags.Events["name:"..i] = "UNIT_NAME_UPDATE";
end
oUF_SVUI.Tags.Events["name:level"] = "UNIT_LEVEL PLAYER_LEVEL_UP PLAYER_FLAGS_CHANGED";
oUF_SVUI.Tags.Events["name:grid"] = "UNIT_NAME_UPDATE";

oUF_SVUI.Tags.Events["health:color"] = "UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED";
oUF_SVUI.Tags.Events["health:deficit"] = "UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED";
oUF_SVUI.Tags.Events["health:current"] = "UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED";
oUF_SVUI.Tags.Events["health:curmax"] = "UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED";
oUF_SVUI.Tags.Events["health:curpercent"] = "UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED";
oUF_SVUI.Tags.Events["health:curmax-percent"] = "UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED";
oUF_SVUI.Tags.Events["health:percent"] = "UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED";

oUF_SVUI.Tags.Events["power:color"] = "UNIT_POWER_FREQUENT UNIT_MAXPOWER";
oUF_SVUI.Tags.Events["power:deficit"] = "UNIT_POWER_FREQUENT UNIT_MAXPOWER";
oUF_SVUI.Tags.Events["power:current"] = "UNIT_POWER_FREQUENT UNIT_MAXPOWER";
oUF_SVUI.Tags.Events["power:curmax"] = "UNIT_POWER_FREQUENT UNIT_MAXPOWER";
oUF_SVUI.Tags.Events["power:curpercent"] = "UNIT_POWER_FREQUENT UNIT_MAXPOWER";
oUF_SVUI.Tags.Events["power:curmax-percent"] = "UNIT_POWER_FREQUENT UNIT_MAXPOWER";
oUF_SVUI.Tags.Events["power:percent"] = "UNIT_POWER_FREQUENT UNIT_MAXPOWER";

oUF_SVUI.Tags.Events["absorbs"] = "UNIT_ABSORB_AMOUNT_CHANGED";
oUF_SVUI.Tags.Events["incoming"] = "UNIT_HEAL_PREDICTION";
oUF_SVUI.Tags.Events["classpower"] = "UNIT_POWER PLAYER_TALENT_UPDATE UPDATE_SHAPESHIFT_FORM";
oUF_SVUI.Tags.Events["altpower"] = "UNIT_POWER UNIT_MAXPOWER";
oUF_SVUI.Tags.Events["threat"] = "UNIT_THREAT_LIST_UPDATE GROUP_ROSTER_UPDATE";
--[[
##########################################################
NAME TAG METHODS
##########################################################
]]--
oUF_SVUI.Tags.Methods["name:color"] = function(unit)
	local unitReaction = UnitReaction(unit, "player")
	local _, classToken = UnitClass(unit)
	if UnitIsPlayer(unit) then
		local class = RAID_CLASS_COLORS[classToken]
		if not class then return "" end
		return Hex(class.r, class.g, class.b)
	elseif unitReaction then
		local reaction = oUF_SVUI["colors"].reaction[unitReaction]
		return Hex(reaction[1], reaction[2], reaction[3])
	else
		return "|cFFC2C2C2"
	end
end

for i = 1, 30 do
	oUF_SVUI.Tags.Methods["name:"..i] = function(unit)
		local name = UnitName(unit)
		local result = (name ~= nil) and (TrimTagText(name, i).."|r ") or ""
		return result
	end
end

oUF_SVUI.Tags.Methods["name:level"] = function(unit)
	local afk, dnd, c = UnitIsAFK(unit), UnitIsDND(unit), UnitClassification(unit)
	local r, g, b, color = 0.55, 0.57, 0.61;
	local hexString = "";
	local level = UnitLevel(unit)
	if(c == "worldboss" or not (level > 0)) then
		return SKULL_ICON
	end
	if(UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit)) then
		level = UnitBattlePetLevel(unit)
		local pta = C_PetJournal.GetPetTeamAverageLevel()
		if pta < level or pta > level then
			color = GetRelativeDifficultyColor(pta, level)
			r, g, b = color.r, color.g, color.b
		else
			color = QuestDifficultyColors["difficult"]
			r, g, b = color.r, color.g, color.b
		end
	else
		local diff = UnitLevel(unit) - UnitLevel("player")
		if diff >= 5 then
			r, g, b = 0.69, 0.31, 0.31
		elseif diff >= 3 then
			r, g, b = 0.71, 0.43, 0.27
		elseif diff >= -2 then
			r, g, b = 0.84, 0.75, 0.65
		elseif -diff <= GetQuestGreenRange() then
			r, g, b = 0.33, 0.59, 0.33
		else
			r, g, b = 0.55, 0.57, 0.61
		end
	end
	local pre,status = GetStatusString(unit)
	local levelString = " " .. pre .. level .. status
	hexString = Hex(r, g, b)
	return ("%s%s|r"):format(hexString, levelString)
end

oUF_SVUI.Tags.Methods["name:grid"] = function(unit)
	local name = UnitName(unit)
	if not name then return "" end
	local unitReaction = UnitReaction(unit, "player")
	local _, classToken = UnitClass(unit)
	local result = "|cffC2C2C2"
	if UnitIsPlayer(unit) then
		local class = RAID_CLASS_COLORS[classToken]
		if class then
			result = Hex(class.r, class.g, class.b)
		end
	elseif unitReaction then
		local reaction = oUF_SVUI["colors"].reaction[unitReaction]
		result = Hex(reaction[1], reaction[2], reaction[3])
	end
	name = TrimTagText(name, 4)
	name = upper(name)
	result = ("%s%s|r"):format(result, name)
	return result
end
--[[
##########################################################
HEALTH TAG METHODS
##########################################################
]]--
oUF_SVUI.Tags.Methods["health:color"] = function(f)
	if UnitIsDeadOrGhost(f) or not UnitIsConnected(f)then
		return Hex(0.84, 0.75, 0.65)
	else
		local r, g, b = oUF_SVUI.ColorGradient(UnitHealth(f), UnitHealthMax(f), 0.89, 0.21, 0.21, 0.85, 0.53, 0.25, 0.23, 0.89, 0.33)
		return Hex(r, g, b)
	end
end

oUF_SVUI.Tags.Methods["health:current"] = function(f)local i = UnitIsDead(f)and DEAD or UnitIsGhost(f)and L["Ghost"]or not UnitIsConnected(f)and L["Offline"]if i then return i else return SetTagStyle("CURRENT", UnitHealth(f), UnitHealthMax(f))end end

oUF_SVUI.Tags.Methods["health:curmax"] = function(f)local i = UnitIsDead(f)and DEAD or UnitIsGhost(f)and L["Ghost"]or not UnitIsConnected(f)and L["Offline"]if i then return i else return SetTagStyle("CURRENT_MAX", UnitHealth(f), UnitHealthMax(f))end end

oUF_SVUI.Tags.Methods["health:curpercent"] = function(f)local i = UnitIsDead(f)and DEAD or UnitIsGhost(f)and L["Ghost"]or not UnitIsConnected(f)and L["Offline"]if i then return i else return SetTagStyle("CURRENT_PERCENT", UnitHealth(f), UnitHealthMax(f))end end

oUF_SVUI.Tags.Methods["health:curmax-percent"] = function(f)local i = UnitIsDead(f)and DEAD or UnitIsGhost(f)and L["Ghost"]or not UnitIsConnected(f)and L["Offline"]if i then return i else return SetTagStyle("CURRENT_MAX_PERCENT", UnitHealth(f), UnitHealthMax(f))end end

oUF_SVUI.Tags.Methods["health:percent"] = function(f)local i = UnitIsDead(f)and DEAD or UnitIsGhost(f)and L["Ghost"]or not UnitIsConnected(f)and L["Offline"]if i then return i else return SetTagStyle("PERCENT", UnitHealth(f), UnitHealthMax(f))end end

oUF_SVUI.Tags.Methods["health:deficit"] = function(f)local i = UnitIsDead(f)and DEAD or UnitIsGhost(f)and L["Ghost"]or not UnitIsConnected(f)and L["Offline"]if i then return i else return SetTagStyle("DEFICIT", UnitHealth(f), UnitHealthMax(f))end end
--[[
##########################################################
POWER TAG METHODS
##########################################################
]]--
oUF_SVUI.Tags.Methods["power:color"] = function(f)
	local j, k, l, m, n = UnitPowerType(f)
	local o = oUF_SVUI["colors"].power[k]
	if o then
		return Hex(o[1], o[2], o[3])
	else
		return Hex(l, m, n)
	end
end

oUF_SVUI.Tags.Methods["power:current"] = function(f)local j = UnitPowerType(f)local p = UnitPower(f, j)return p == 0 and" "or SetTagStyle("CURRENT", p, UnitPowerMax(f, j))end

oUF_SVUI.Tags.Methods["power:curmax"] = function(f)local j = UnitPowerType(f)local p = UnitPower(f, j)return p == 0 and" "or SetTagStyle("CURRENT_MAX", p, UnitPowerMax(f, j))end

oUF_SVUI.Tags.Methods["power:curpercent"] = function(f)local j = UnitPowerType(f)local p = UnitPower(f, j)return p == 0 and" "or SetTagStyle("CURRENT_PERCENT", p, UnitPowerMax(f, j))end

oUF_SVUI.Tags.Methods["power:curmax-percent"] = function(f)local j = UnitPowerType(f)local p = UnitPower(f, j)return p == 0 and" "or SetTagStyle("CURRENT_PERCENT", p, UnitPowerMax(f, j))end

oUF_SVUI.Tags.Methods["power:percent"] = function(f)local j = UnitPowerType(f)local p = UnitPower(f, j)return p == 0 and" "or SetTagStyle("PERCENT", p, UnitPowerMax(f, j))end

oUF_SVUI.Tags.Methods["power:deficit"] = function(f)local j = UnitPowerType(f) return SetTagStyle("DEFICIT", UnitPower(f, j), UnitPowerMax(f, j))end
--[[
##########################################################
MISC TAG METHODS
##########################################################
]]--
oUF_SVUI.Tags.Methods["absorbs"] = function(unit)
	local asrb = UnitGetTotalAbsorbs(unit) or 0;
	if asrb == 0 then
		return " "
	else
		local amt = TruncateString(asrb)
		return ("|cffFFFFFF(%s) |r"):format(amt)
	end
end

oUF_SVUI.Tags.Methods["incoming"] = function(unit)
	local fromPlayer = UnitGetIncomingHeals(unit, "player") or 0;
	local fromOthers = UnitGetIncomingHeals(unit) or 0;
	local amt = fromPlayer + fromOthers;
	if amt == 0 then
		return " "
	else
		local incoming = TruncateString(amt)
		return ("|cff2EFF2E+%s |r"):format(incoming)
	end
end

oUF_SVUI.Tags.Methods["threat"] = function(unit)
	if UnitCanAttack("player", unit)then
		local status, threat = select(2, UnitDetailedThreatSituation("player", unit))
		if status then
			local color = Hex(GetThreatStatusColor(status))
			return ("%s%.0f%% |r"):format(color, threat)
		end
	end
	return " "
end

oUF_SVUI.Tags.Methods["classpower"] = function()
	local currentPower, maxPower, r, g, b = GetClassPower(SV.class)
	if currentPower == 0 then
		return " "
	else
		local color = Hex(r, g, b)
		local amt = SetTagStyle("CURRENT", currentPower, maxPower)
		return ("%s%s "):format(color, amt)
	end
end

oUF_SVUI.Tags.Methods["altpower"] = function(unit)
	local power = UnitPower(unit, ALTERNATE_POWER_INDEX)
	if(power > 0) then
		local texture, r, g, b = UnitAlternatePowerTextureInfo(unit, 2)
		if not r then
			r, g, b = 1, 1, 1
		end
		local color = Hex(r, g, b)
		return ("%s%s "):format(color, power)
	else
		return " "
	end
end

oUF_SVUI.Tags.Methods["pvptimer"] = function(unit)
	if UnitIsPVPFreeForAll(unit) or UnitIsPVP(unit)then
		local clock = GetPVPTimer()
		if clock  ~= 301000 and clock  ~= -1 then
			local dur1 = floor(clock  /  1000  /  60)
			local dur2 = floor(clock  /  1000 - dur1  *  60)
			return("%s (%01.f:%02.f)"):format(PVP, dur1, dur2)
		else
			return PVP
		end
	else
		return ""
	end
end
