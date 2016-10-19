--[[
##############################################################################
S V U I   By: Failcoder
##############################################################################
credit: Elv.       NamePlatess was parently nameplates.lua adapted from ElvUI #
##############################################################################
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
local tinsert   = _G.tinsert;
local string    = _G.string;
local math      = _G.math;
local bit       = _G.bit;
local table     = _G.table;
--[[ STRING METHODS ]]--
local lower, upper = string.lower, string.upper;
local find, format, split = string.find, string.format, string.split;
local match, gmatch, gsub = string.match, string.gmatch, string.gsub;
--[[ MATH METHODS ]]--
local floor, ceil = math.floor, math.ceil;  -- Basic
--[[ BINARY METHODS ]]--
local band, bor = bit.band, bit.bor;
--[[ TABLE METHODS ]]--
local tremove, tcopy, twipe, tsort, tconcat = table.remove, table.copy, table.wipe, table.sort, table.concat;
--[[
##########################################################
GET ADDON DATA
##########################################################
]]--
local SV = _G['SVUI'];
local L = SV.L;
local MOD = SV.NamePlates;
if(not MOD) then return end;

local LSM = _G.LibStub("LibSharedMedia-3.0")
--[[
##########################################################
LOCALIZED GLOBALS
##########################################################
]]--
local SetCVar           	= _G.SetCVar;
local UIParent              = _G.UIParent;
local WorldFrame           	= _G.WorldFrame;
local GameTooltip           = _G.GameTooltip;

local CreateFrame           = _G.CreateFrame;
local InCombatLockdown      = _G.InCombatLockdown;
--[[
##########################################################
LOCAL VARS
##########################################################
]]--
local numChildren = -1;
local PlateRegistry, VisiblePlates = {}, {};
local WorldFrameUpdateHook, UpdatePlateElements, PlateForge;
local BLIZZ_PLATE, SVUI_PLATE, PLATE_REF, PLATE_ARGS, PLATE_AURAS, PLATE_AURAICONS, PLATE_REALNAME;
local CURRENT_TARGET_NAME;
local TARGET_CHECKS = 0;
local PLATE_TOP = MOD.media.topArt;
local PLATE_BOTTOM = MOD.media.bottomArt;
local PLATE_RIGHT = MOD.media.rightArt;
local PLATE_LEFT = MOD.media.leftArt;
--[[
	Quick explaination of what Im doing with all of these locals...
	Unlike many of the other modules, NamePlatess has to continuously
	reference config settings which can start to get sluggish. What
	I have done is set local variables for every database value
	that the module can read efficiently. The function "UpdateLocals"
	is used to refresh these any time a change is made to configs
	and once when the mod is loaded.
]]--
local NPBaseAlpha = 0.6;
local NPCombatHide = false;
local NPNameMatch = false;
local NPComboColor={
	[1]={0.69,0.31,0.31},
	[2]={0.69,0.31,0.31},
	[3]={0.65,0.63,0.35},
	[4]={0.65,0.63,0.35},
	[5]={0.33,0.59,0.33}
}

local NPBarTex = [[Interface\BUTTONS\WHITE8X8]];

local NPUsePointer = true;
local NPPointerMatch = false;
local NPUseModel = true;
local NPPointerColor = {0.9, 1, 0.9, 0.5};

local NPUseThreat = false;
local NPThreatGS = 1;
local NPThreatBS = 1;
local NPReactTap = {0.3,0.3,0.3}
local NPReactNPCGood = {0.31,0.45,0.63}
local NPReactPlayerGood = {0.29,0.68,0.3}
local NPReactNeutral = {0.85,0.77,0.36}
local NPReactEnemy = {0.78,0.25,0.25}

local RIconCoords = {[0]={[0]="STAR", [0.25]="MOON"}, [0.25]={[0]="CIRCLE", [0.25]="SQUARE"}, [0.5]={[0]="DIAMOND", [0.25]="CROSS"}, [0.75]={[0]="TRIANGLE", [0.25]="SKULL"}};
local RIAnchor = "LEFT";
local RIXoffset = -4;
local RIYoffset = 6;
local RISize = 36;

local HBThresh = 0.4;
local HBTextFormat = false;
local HBTextAnchor = "CENTER";
local HBXoffset = 0;
local HBYoffset = 0;
local HBWidth = 108;
local HBHeight = 9;

local NPIcons = 14;
local ICON_SIZE = 20;

local CBColor = {0.1,0.81,0}
local CBNoInterrupt = {1,0.25,0.25}
local CBHeight = 6;
local CBText = true;
local CBXoffset = 0;
local CBYoffset = 0;

local AuraFilterName, AuraFilter;
local AuraMaxCount = 5;

local NPFindHealers = false;

local RestrictedPlates = {
	["Army of the Dead Ghoul"] = true,
	["Venomous Snake"] = true,
	["Healing Tide Totem"] = true,
	["Dragonmaw War Banner"] = true
};
local RIconData = {["STAR"] = 0x00000001, ["CIRCLE"] = 0x00000002, ["DIAMOND"] = 0x00000004, ["TRIANGLE"] = 0x00000008, ["MOON"] = 0x00000010, ["SQUARE"] = 0x00000020, ["CROSS"] = 0x00000040, ["SKULL"] = 0x00000080};
local RIconNames = {"STAR", "CIRCLE", "DIAMOND", "TRIANGLE", "MOON", "SQUARE", "CROSS", "SKULL"}
local UnitPlateAuras = {};
local AuraByRaidIcon = {};
local AuraByName = {};
local CachedAuraDurations = {};
local AurasCache = {};
local AuraClocks = {};
local ClockIsTicking = false;
local TickTock = 0;
local LastKnownTarget;
--[[
##########################################################
COLORING THREAT/REACTIONS
##########################################################
]]--
local CONFIG_THREAT_HOSTILE = { {0.29,0.68,0.3}, {0.85,0.77,0.36}, {0.94,0.6,0.06}, {0.78,0.25,0.25} };
local CONFIG_THREAT_SCALE = { 1,1,1,1 };
local PLATE_CLASS_COLORS = {};

do
	for classToken, colorData in pairs(RAID_CLASS_COLORS) do
			PLATE_CLASS_COLORS[classToken] = {colorData.r, colorData.g, colorData.b}
	end
end

local REACTION_COLORING = {
	-- (1) PLAYER
	function(token)
		if(not token) then
			return NPReactPlayerGood,NPThreatGS
		else
			return PLATE_CLASS_COLORS[token],NPThreatGS
		end
	end,
	-- (2) TAPPED
	function() return NPReactTap,NPThreatGS end,
	-- (3) FRIENDLY
	function() return NPReactNPCGood,NPThreatGS end,
	-- (4) NEUTRAL
	function(threatLevel)
		local color,scale;
		if((not threatLevel) or (not NPUseThreat) or (not InCombatLockdown())) then
			color = NPReactNeutral
			scale = NPThreatGS
		else
			color = CONFIG_THREAT_HOSTILE[threatLevel]
			scale = CONFIG_THREAT_SCALE[threatLevel]
		end
		return color,scale
	end,
	-- (5) HOSTILE
	function(threatLevel)
		local color,scale;
		if((not threatLevel) or (not NPUseThreat) or (not InCombatLockdown())) then
			color = NPReactEnemy
			scale = NPThreatGS
		else
			color = CONFIG_THREAT_HOSTILE[threatLevel]
			scale = CONFIG_THREAT_SCALE[threatLevel]
		end
		return color,scale
	end,
};
--[[
##########################################################
UTILITY FRAMES
##########################################################
]]--
local NPGrip = _G.SVUI_PlateParentFrame
local NPGlow = _G.SVUI_PlateGlowFrame
local AuraClockManager = CreateFrame("Frame")
--[[
##########################################################
PRE VARS/FUNCTIONS
##########################################################
]]--
local formatting = {
	["CURRENT"] = "%s",
	["CURRENT_MAX"] = "%s - %s",
	["CURRENT_PERCENT"] = "%s - %s%%",
	["CURRENT_MAX_PERCENT"] = "%s - %s | %s%%",
	["PERCENT"] = "%s%%",
	["DEFICIT"] = "-%s"
};

local function IsEnemyPlayer(flags)
	if((band(flags, COMBATLOG_OBJECT_REACTION_FRIENDLY) == 0) and (band(flags, COMBATLOG_OBJECT_CONTROL_PLAYER) > 0)) then
		return true
	end
end

local function TruncateString(value)
    if value  >= 1e9 then
        return ("%.1fb"):format(value / 1e9):gsub("%.?0 + ([kmb])$", "%1")
    elseif value  >= 1e6 then
        return ("%.1fm"):format(value / 1e6):gsub("%.?0 + ([kmb])$", "%1")
    elseif value  >= 1e3 or value  <= -1e3 then
        return ("%.1fk"):format(value / 1e3):gsub("%.?0 + ([kmb])$", "%1")
    else
        return value
    end
end

local function SetTextStyle(style, min, max)
	if max == 0 then max = 1 end
	local result;
	local textFormat = formatting[style]
	if style == "DEFICIT" then
		local result = max - min;
		if result  <= 0 then
			return ""
		else
			return format(textFormat, TruncateString(result))
		end
	elseif style == "PERCENT" then
		result = format(textFormat, format("%.1f", min  /  max  *  100))
		result = result:gsub(".0%%", "%%")
		return result
	elseif style == "CURRENT" or (style == "CURRENT_MAX" or style == "CURRENT_MAX_PERCENT" or style == "CURRENT_PERCENT") and min == max then
		return format(formatting["CURRENT"], TruncateString(min))
	elseif style == "CURRENT_MAX" then
		return format(textFormat, TruncateString(min), TruncateString(max))
	elseif style == "CURRENT_PERCENT" then
		result = format(textFormat, TruncateString(min), format("%.1f", min  /  max  *  100))
		result = result:gsub(".0%%", "%%")
		return result
	elseif style == "CURRENT_MAX_PERCENT" then
		result = format(textFormat, TruncateString(min), TruncateString(max), format("%.1f", min  /  max  *  100))
		result = result:gsub(".0%%", "%%")
		return result
	end
end

local function CreatePlateBorder(plate)

	if(not plate.backdrop) then
		plate.backdrop = plate:CreateTexture(nil, "BORDER")
		plate.backdrop:SetDrawLayer("BORDER", -4)
		plate.backdrop:SetAllPoints(plate)
		plate.backdrop:SetTexture(SV.media.statusbar.default)
		plate.backdrop:SetVertexColor(0.1,0.1,0.1)

		plate.bordertop = plate:CreateTexture(nil, "BORDER")
		plate.bordertop:SetPoint("TOPLEFT", plate, "TOPLEFT", -2, 2)
		plate.bordertop:SetPoint("TOPRIGHT", plate, "TOPRIGHT", 2, 2)
		plate.bordertop:SetHeight(2)
		plate.bordertop:SetColorTexture(0,0,0)
		plate.bordertop:SetDrawLayer("BORDER", 1)

		plate.borderbottom = plate:CreateTexture(nil, "BORDER")
		plate.borderbottom:SetPoint("BOTTOMLEFT", plate, "BOTTOMLEFT", -2, -2)
		plate.borderbottom:SetPoint("BOTTOMRIGHT", plate, "BOTTOMRIGHT", 2, -2)
		plate.borderbottom:SetHeight(2)
		plate.borderbottom:SetColorTexture(0,0,0)
		plate.borderbottom:SetDrawLayer("BORDER", 1)

		plate.borderleft = plate:CreateTexture(nil, "BORDER")
		plate.borderleft:SetPoint("TOPLEFT", plate, "TOPLEFT", -2, 2)
		plate.borderleft:SetPoint("BOTTOMLEFT", plate, "BOTTOMLEFT", 2, -2)
		plate.borderleft:SetWidth(2)
		plate.borderleft:SetColorTexture(0,0,0)
		plate.borderleft:SetDrawLayer("BORDER", 1)

		plate.borderright = plate:CreateTexture(nil, "BORDER")
		plate.borderright:SetPoint("TOPRIGHT", plate, "TOPRIGHT", 2, 2)
		plate.borderright:SetPoint("BOTTOMRIGHT", plate, "BOTTOMRIGHT", -2, -2)
		plate.borderright:SetWidth(2)
		plate.borderright:SetColorTexture(0,0,0)
		plate.borderright:SetDrawLayer("BORDER", 1)
	end

	if(not plate.eliteborder) then
		plate.eliteborder = CreateFrame("Frame", nil, plate)
		plate.eliteborder:SetAllPoints(plate)
		plate.eliteborder:SetFrameStrata("BACKGROUND")
		plate.eliteborder:SetFrameLevel(0)

		plate.eliteborder.top = plate.eliteborder:CreateTexture(nil, "BACKGROUND")
		plate.eliteborder.top:SetPoint("BOTTOMLEFT", plate.eliteborder, "TOPLEFT", 0, 0)
		plate.eliteborder.top:SetPoint("BOTTOMRIGHT", plate.eliteborder, "TOPRIGHT", 0, 0)
		plate.eliteborder.top:SetHeight(22)
		plate.eliteborder.top:SetTexture(PLATE_TOP)
		plate.eliteborder.top:SetVertexColor(1, 1, 0)
		plate.eliteborder.top:SetBlendMode("BLEND")

		plate.eliteborder.bottom = plate.eliteborder:CreateTexture(nil, "BACKGROUND")
		plate.eliteborder.bottom:SetPoint("TOPLEFT", plate.eliteborder, "BOTTOMLEFT", 0, 0)
		plate.eliteborder.bottom:SetPoint("TOPRIGHT", plate.eliteborder, "BOTTOMRIGHT", 0, 0)
		plate.eliteborder.bottom:SetHeight(32)
		plate.eliteborder.bottom:SetTexture(PLATE_BOTTOM)
		plate.eliteborder.bottom:SetVertexColor(1, 1, 0)
		plate.eliteborder.bottom:SetBlendMode("BLEND")

		-- plate.eliteborder.right = plate.eliteborder:CreateTexture(nil, "BACKGROUND")
		-- plate.eliteborder.right:SetPoint("TOPLEFT", plate.eliteborder, "TOPRIGHT", 0, 0)
		-- plate.eliteborder.right:SetPoint("BOTTOMLEFT", plate.eliteborder, "BOTTOMRIGHT", 0, 0)
		-- plate.eliteborder.right:SetWidth(plate:GetHeight() * 4)
		-- plate.eliteborder.right:SetTexture(PLATE_RIGHT)
		-- plate.eliteborder.right:SetVertexColor(1, 1, 0)
		-- plate.eliteborder.right:SetBlendMode("BLEND")

		-- plate.eliteborder.left = plate.eliteborder:CreateTexture(nil, "BACKGROUND")
		-- plate.eliteborder.left:SetPoint("TOPRIGHT", plate.eliteborder, "TOPLEFT", 0, 0)
		-- plate.eliteborder.left:SetPoint("BOTTOMRIGHT", plate.eliteborder, "BOTTOMLEFT", 0, 0)
		-- plate.eliteborder.left:SetWidth(plate:GetHeight() * 4)
		-- plate.eliteborder.left:SetTexture(PLATE_LEFT)
		-- plate.eliteborder.left:SetVertexColor(1, 1, 0)
		-- plate.eliteborder.left:SetBlendMode("BLEND")

		plate.eliteborder:SetAlpha(0.35)

		plate.eliteborder:Hide()
	end
end
--[[
##########################################################
UPVALUE PROXYS
##########################################################
]]--
local function ProxyThisPlate(plate, updateName)
	if(not plate or not plate.frame) then return false; end
	BLIZZ_PLATE = plate
	SVUI_PLATE = plate.frame
	PLATE_AURAS = plate.frame.auras
	PLATE_AURAICONS = plate.frame.auraicons
	PLATE_ARGS = plate.setting
	if updateName then
		plate.nametext = gsub(plate.name:GetText(), '%s%(%*%)','');
	end
	PLATE_REALNAME = plate.nametext
	return true
end
--[[
##########################################################
LOCAL HELPERS
##########################################################
]]--
local function ParseByGUID(guid)
	for plate, _ in pairs(VisiblePlates) do
		if plate and plate:IsShown() and plate.guid == guid then
			return plate
		end
	end
end

local function CheckRaidIcon(plate)
	if(plate and plate.frame) then
		SVUI_PLATE = plate.frame
	end
	if PLATE_REF.raidicon:IsShown() then
		local ULx,ULy,LLx,LLy,URx,URy,LRx,LRy = PLATE_REF.raidicon:GetTexCoord()
		PLATE_REF.raidicontype = RIconCoords[ULx][ULy]
		SVUI_PLATE.raidicon:Show()
		SVUI_PLATE.raidicon:SetTexCoord(ULx,ULy,LLx,LLy,URx,URy,LRx,LRy)
	else
		PLATE_REF.raidicontype = nil;
		SVUI_PLATE.raidicon:Hide()
	end
end

local function UpdateComboPoints()
	local guid = UnitGUID("target")
	if (not guid) then return end
	local numPoints = GetComboPoints(UnitHasVehicleUI('player') and 'vehicle' or 'player', 'target')
	numPoints = numPoints or 0
	if(numPoints > 0) then
		if(LastKnownTarget and LastKnownTarget.guid and LastKnownTarget.guid ~= guid) then
			LastKnownTarget.frame.combo[1]:Hide()
			LastKnownTarget.frame.combo[2]:Hide()
			LastKnownTarget.frame.combo[3]:Hide()
			LastKnownTarget.frame.combo[4]:Hide()
			LastKnownTarget.frame.combo[5]:Hide()
			LastKnownTarget = nil
		end
	end
	local plate = ParseByGUID(guid)
	if(plate) then
		for i=1, MAX_COMBO_POINTS do
			if(i <= numPoints) then
				plate.frame.combo[i]:Show()
			else
				plate.frame.combo[i]:Hide()
			end
		end
		LastKnownTarget = plate
	end
end
--[[
##########################################################
AURA HELPERS
##########################################################
]]--
local ClockUpdateHandler = function(self, elapsed)
	local curTime = GetTime()
	if curTime < TickTock then return end
	local deactivate = true;
	TickTock = curTime + 0.1
	for frame, expiration in pairs(AuraClocks) do
		local calc = 0;
		local expires = expiration - curTime;
		if expiration < curTime then
			frame:Hide();
			AuraClocks[frame] = nil
		else
			if expires < 60 then
				calc = floor(expires)
				if expires >= 4 then
					frame.TimeLeft:SetFormattedText("|cffffff00%d|r", calc)
				elseif expires >= 1 then
					frame.TimeLeft:SetFormattedText("|cffff0000%d|r", calc)
				else
					frame.TimeLeft:SetFormattedText("|cffff0000%.1f|r", expires)
				end
			elseif expires < 3600 then
				calc = ceil(expires / 60);
				frame.TimeLeft:SetFormattedText("|cffffffff%.1f|r", calc)
			elseif expires < 86400 then
				calc = ceil(expires / 3600);
				frame.TimeLeft:SetFormattedText("|cff66ffff%.1f|r", calc)
			else
				calc = ceil(expires / 86400);
				frame.TimeLeft:SetFormattedText("|cff6666ff%.1f|r", calc)
			end
			deactivate = false
		end
	end
	if deactivate then
		self:SetScript("OnUpdate", nil);
		ClockIsTicking = false
	end
end

local function RegisterAuraClock(frame, expiration)
	if(not frame) then return end
	if expiration == 0 then
		frame:Hide()
		AuraClocks[frame] = nil
	else
		AuraClocks[frame] = expiration
		frame:Show()
		if(not ClockIsTicking) then
			AuraClockManager:SetScript("OnUpdate", ClockUpdateHandler)
			ClockIsTicking = true
		end
	end
end

local function GetUnitPlateAuras(guid)
	if guid and UnitPlateAuras[guid] then return UnitPlateAuras[guid] end
end

local function SetAuraInstance(guid, spellID, expiration, stacks, caster, duration, texture)
	if(spellID == 65148) then return end
	local filter = true;
	if (caster == UnitGUID('player')) then
		filter = nil;
	end
	if(AuraFilter and AuraFilterName) then
		local name = GetSpellInfo(spellID)
		if(AuraFilter[name] and AuraFilter[name].enable and ((AuraFilterName ~= 'BlackList') and (AuraFilterName ~= 'Allowed'))) then
			filter = nil;
		end
	end
	if(not filter and (guid and spellID and caster and texture)) then
		local auraID = spellID..(tostring(caster or "UNKNOWN_CASTER"))
		UnitPlateAuras[guid] = UnitPlateAuras[guid] or {}
			UnitPlateAuras[guid][auraID] = {
			spellID = spellID,
			expiration = expiration or 0,
			stacks = stacks,
			duration = duration,
			texture = texture
		}
	end
end

local function UpdateAuraIcon(aura, texture, expiration, stacks, test)
	if aura and texture and expiration then
		aura.Icon:SetTexture(texture)
		if(stacks and stacks > 1) then
			aura.Stacks:SetText(stacks)
		else
			aura.Stacks:SetText("")
		end
		aura:Show()
		RegisterAuraClock(aura, expiration)
	else
		RegisterAuraClock(aura, 0)
	end
end

local function SortExpires(t)
	tsort(t, function(a,b) return a.expiration < b.expiration end)
	return t
end

local function UpdateAuraIconGrid(plate)
	local frame = plate.frame;
	local guid = plate.guid;
	local iconCache = frame.auraicons;
	local AurasOnUnit = GetUnitPlateAuras(guid);
	local AuraSlotIndex = 1;
	local auraID;
	if AurasOnUnit then
		frame.auras:Show()
		local auraCount = 1
		for auraID,aura in pairs(AurasOnUnit) do
			if tonumber(aura.spellID) then
				aura.name = GetSpellInfo(tonumber(aura.spellID))
				aura.unit = plate.unit
				if(aura.expiration > GetTime()) then
					AurasCache[auraCount] = aura
					auraCount = auraCount + 1
				end
			end
		end
	end
	AurasCache = SortExpires(AurasCache)
	for index = 1,  #AurasCache do
		local cachedaura = AurasCache[index]
		local gridaura = iconCache[AuraSlotIndex]
		if gridaura and cachedaura.spellID and cachedaura.expiration then
			UpdateAuraIcon(gridaura, cachedaura.texture, cachedaura.expiration, cachedaura.stacks)
			AuraSlotIndex = AuraSlotIndex + 1
		end
		if(AuraSlotIndex > AuraMaxCount) then
			break
		end
	end
	if(iconCache[AuraSlotIndex]) then
		RegisterAuraClock(iconCache[AuraSlotIndex], 0)
	end
	twipe(AurasCache)
end

local function LoadDuration(spellID)
	if spellID then
		return CachedAuraDurations[spellID] or 0
	end
	return 0
end

local function SaveDuration(spellID, duration)
	duration = duration or 0
	if spellID then CachedAuraDurations[spellID] = duration end
end

local function CreateAuraIcon(auras, plate)

	local button = CreateFrame("Frame", nil, auras)

	button.bord = button:CreateTexture(nil, "BACKGROUND")
	button.bord:SetDrawLayer('BACKGROUND', 2)
	button.bord:SetColorTexture(0,0,0,1)
	button.bord:SetPoint("TOPLEFT", button, "TOPLEFT", -2, 2)
	button.bord:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 2, -2)

	button.Icon = button:CreateTexture(nil, "BORDER")
	button.Icon:SetPoint("TOPLEFT",button,"TOPLEFT")
	button.Icon:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT")
	button.Icon:SetTexCoord(.1, .9, .2, .8)

	button.TimeLeft = button:CreateFontString(nil, 'OVERLAY')
	button.TimeLeft:SetFontObject(SVUI_Font_NamePlate_Aura)
	button.TimeLeft:SetPoint("BOTTOMLEFT",button,"TOPLEFT",-3,-1)
	button.TimeLeft:SetJustifyH('CENTER')

	button.Stacks = button:CreateFontString(nil,"OVERLAY")
	button.Stacks:SetFontObject(SVUI_Font_NamePlate_Aura)
	button.Stacks:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT",3,-3)

	button:SetScript('OnHide', function()
		if plate.guid then
			UpdateAuraIconGrid(plate)
		end
	end)

	button:Hide()

	return button
end

function MOD:UpdateAuras(plate)
	if plate.setting.tiny then return end
	local guid = plate.guid
	local frame = plate.frame
	if(NPFindHealers and plate.isHealer) then
		frame.health.icon:Show()
	end
	if not guid then
		if RAID_CLASS_COLORS[plate.setting.classToken] then
			local pn = plate.name:GetText()
			local name = pn:gsub("%s%(%*%)", "")
			guid = AuraByName[name]
		--elseif plate.raidicon:IsShown() then
			--guid = AuraByRaidIcon[plate.raidicontype]
		end
		if guid then
			plate.guid = guid
		else
			frame.auras:Hide()
			return
		end
	end
	UpdateAuraIconGrid(plate)
	if(self.UseCombo) then
		local numPoints = GetComboPoints(UnitHasVehicleUI("player") and "vehicle" or "player", "target")
		for i = 1, MAX_COMBO_POINTS do
			if(i <= numPoints) then
				frame.combo[i]:Show()
			else
				frame.combo[i]:Hide()
			end
		end
	end

end

function MOD:UpdateAurasByUnitID(unitid)
	local guid = UnitGUID(unitid)
	if(guid and UnitPlateAuras[guid]) then
		local auras = UnitPlateAuras[guid]
		for auraID, _ in pairs(auras) do
			UnitPlateAuras[guid][auraID] = nil
		end
	end
	for i = 1, 40 do
		local spellname , _, texture, count, dispelType, duration, expirationTime, unitCaster, _, _, spellid, _, isBossDebuff = UnitAura(unitid, i, "HARMFUL")
		if(not spellname) then break end
		SaveDuration(spellid, duration)
		SetAuraInstance(guid, spellid, expirationTime, count, UnitGUID(unitCaster or ""), duration, texture)
	end
	local name;
	if UnitPlayerControlled(unitid) then
		name = UnitName(unitid)
		AuraByName[name] = guid
	end
	local raidIcon = RIconNames[GetRaidTargetIndex(unitid) or ""];
	if(raidIcon) then
		AuraByRaidIcon[raidIcon] = guid
	end
	self:RequestScanUpdate(guid, raidIcon, name, "UpdateAuras")
end
--[[
##########################################################
PLATE COLORING
##########################################################
]]--
do
	local function GetPlateThreatReaction(plate)
		if plate.aggroHighlight:IsShown() then
			local r, g, b = plate.aggroHighlight:GetVertexColor()
			local lastThreat = plate.reaction or 1
			if g + b < 1 then
				plate.reaction = 4
				return 4
			else
				if lastThreat > 2 then
					plate.reaction = 2
					return 2
				elseif lastThreat < 3 then
					plate.reaction = 3
					return 3
				end
			end
		end
		plate.reaction = 1
		return 1
	end

	local function GetPlateReaction(plate)
		if plate.guid ~= nil then
			local class, classToken, _, _, _, _, _ = GetPlayerInfoByGUID(plate.guid)
			if RAID_CLASS_COLORS[classToken] then
				plate.setting.classToken = classToken
				return REACTION_COLORING[1](classToken)
			end
		end

		local oldR,oldG,oldB = plate.healthBar:GetStatusBarColor()
		local r = floor(oldR * 100 + .5) * 0.01;
		local g = floor(oldG * 100 + .5) * 0.01;
		local b = floor(oldB * 100 + .5) * 0.01;
		--print(plate.health:GetStatusBarColor())
		for classToken, _ in pairs(RAID_CLASS_COLORS) do
			local bb = b
			if classToken == 'MONK' then
				bb = bb - 0.01
			end
			if RAID_CLASS_COLORS[classToken].r == r and RAID_CLASS_COLORS[classToken].g == g and RAID_CLASS_COLORS[classToken].b == bb then
				plate.setting.classToken = classToken
				return REACTION_COLORING[1](classToken)
			end
		end

		plate.setting.classToken = nil
		if(r + b < 0.25) then
			return REACTION_COLORING[3]()
		else
			local threatReaction = GetPlateThreatReaction(plate)
			if(r + g > 1.8) then
				return REACTION_COLORING[4](threatReaction)
			elseif(g + b < 0.25) then
				return REACTION_COLORING[5](threatReaction)
			elseif((r > 0.45 and r < 0.55) and (g > 0.45 and g < 0.55) and (b > 0.45 and b < 0.55)) then
				REACTION_COLORING[2]()
			else
				REACTION_COLORING[1]()
			end
		end
	end

	local function ColorizeAndScale(plate, frame)
		local unitType = GetPlateReaction(plate)

		plate.setting.classToken = unitType

		local latestColor, scale = GetPlateReaction(plate);
		local r,g,b
		if(latestColor) then
			r,g,b = unpack(latestColor)
		else
			r,g,b = plate.healthBar:GetStatusBarColor()
		end

		frame.health:SetStatusBarColor(r,g,b)
		if(NPUsePointer and (NPPointerMatch == true) and plate.setting.unit == "target") then
			NPGlow:SetBackdropColor(r,g,b,0.5)
			NPGlow:SetBackdropBorderColor(r,g,b,0.5)
		end
		--frame.health.elite.bottom:SetVertexColor(r,g,b)
		--frame.health.elite.right:SetVertexColor(r,g,b)
		--frame.health.elite.left:SetVertexColor(r,g,b)
		scale = scale or 1
		if(not plate.setting.scaled and not plate.setting.tiny and frame.health:GetWidth() ~= (HBWidth * scale)) then
			frame.health:SetSize(HBWidth * scale, HBHeight * scale)
			local scaledIconSize = CBHeight + (HBHeight * scale) + 5;
			plate.castBar.Icon:SetSize(scaledIconSize, scaledIconSize)
		end
	end

	function UpdatePlateElements(plate, frame)
		ColorizeAndScale(plate, frame)
		frame.health.elitetop:Hide()
		frame.health.elitebottom:Hide()
		if(frame.name.SetText) then
			frame.name:SetText(plate.name:GetText())
		end
	end
end
--[[
##########################################################
PLATE UPDATE HANDLERS
##########################################################
]]--
do
	local function IsNamePlate(frame)
		local frameName = frame:GetName()
		if frameName and frameName:find('^NamePlate%d') then
			local textObj = select(2, frame:GetChildren())
			if textObj then
				local textRegions = textObj:GetRegions()
				return (textRegions and textRegions:GetObjectType() == 'FontString')
			end
		end
	end

	local function SetPlateAlpha(plate, frame)
		if plate:GetAlpha() < 1 then
			frame:SetAlpha(NPBaseAlpha)
		else
			frame:SetAlpha(1)
		end
	end

	local function UpdatePlateUnit()
		local plateName = BLIZZ_PLATE.nametext

		if BLIZZ_PLATE:GetAlpha() == 1 and CURRENT_TARGET_NAME and (CURRENT_TARGET_NAME == plateName) then
			BLIZZ_PLATE.guid = UnitGUID("target")
			PLATE_ARGS.unit = "target"
			SVUI_PLATE:SetFrameLevel(2)
			SVUI_PLATE.highlight:Hide()
			if(NPUsePointer) then
				NPGlow:SetParent(SVUI_PLATE)
				NPGlow:WrapPoints(SVUI_PLATE.health,2,2)
				NPGlow:SetFrameLevel(0)
				NPGlow:SetFrameStrata("BACKGROUND")
				if(not NPGlow:IsShown()) then
					NPGlow:Show()
					if(NPUseModel) then
						NPGlow.FX:Show()
						NPGlow.FX:SetEffect("platepoint")
					end
				end
			end
			if((TARGET_CHECKS > 0) or PLATE_ARGS.allowed) then
				TARGET_CHECKS = TARGET_CHECKS + 1
				if(TARGET_CHECKS == 2) then
					TARGET_CHECKS = 0
				end
				MOD:UpdateAurasByUnitID('target')
				if MOD.UseCombo then
					UpdateComboPoints()
				end
				PLATE_ARGS.allowed = nil
			end
		elseif UnitExists("mouseover") and (UnitName("mouseover") == plateName) then
			if(PLATE_ARGS.unit ~= "mouseover" or PLATE_ARGS.allowed) then
				SVUI_PLATE:SetFrameLevel(1)
				SVUI_PLATE.highlight:Show()
				MOD:UpdateAurasByUnitID('mouseover')
				if MOD.UseCombo then
					UpdateComboPoints()
				end
				PLATE_ARGS.allowed = nil
			end
			BLIZZ_PLATE.guid = UnitGUID("mouseover")
			PLATE_ARGS.unit = "mouseover"
		else
			SVUI_PLATE:SetFrameLevel(0)
			SVUI_PLATE.highlight:Hide()
			PLATE_ARGS.unit = nil
		end
		--CheckRaidIcon()
		UpdatePlateElements(BLIZZ_PLATE,SVUI_PLATE)
	end

	function MOD:NAME_PLATE_CREATED(event, ...)
		local frame = ...;
		if(not PlateRegistry[frame]) then
			PlateForge(frame)
		end
	end

	function MOD:NAME_PLATE_UNIT_ADDED(event, ...)
		local namePlateUnitToken = ...;
		local frame = C_NamePlate.GetNamePlateForUnit(namePlateUnitToken);
		if(not PlateRegistry[frame]) then
			PlateForge(frame)
		end
	end
end
--[[
##########################################################
SCRIPT HANDLERS
##########################################################
]]--
do
	local function HealthBarSizeChanged(self, width, height)
		if(not ProxyThisPlate(self.sync)) then return; end
		width = floor(width + 0.5)
		local numAuras = AuraMaxCount
		local auraWidth = ((width - (4 * (numAuras - 1))) / numAuras)
		local auraHeight = (auraWidth * 0.7)
		for index = 1, numAuras do
			if not PLATE_AURAICONS[index] then
				PLATE_AURAICONS[index] = CreateAuraIcon(PLATE_AURAS, SVUI_PLATE);
			end
			PLATE_AURAICONS[index]:SetWidth(auraWidth)
			PLATE_AURAICONS[index]:SetHeight(auraHeight)
			PLATE_AURAICONS[index]:ClearAllPoints()
			if(index == 1) then
				PLATE_AURAICONS[index]:SetPoint("LEFT", PLATE_AURAS, 0, 0)
			else
				PLATE_AURAICONS[index]:SetPoint("LEFT", PLATE_AURAICONS[index-1], "RIGHT", 4, 0)
			end
		end
		if(numAuras > #PLATE_AURAICONS) then
			for index = (numAuras + 1), #PLATE_AURAICONS do
				RegisterAuraClock(PLATE_AURAICONS[index], 0)
			end
		end
	end

	local function HealthBarValueChanged(self, value)
		local healthBar = self.sync;
		local alert = healthBar.alert;
		local minValue, maxValue = self:GetMinMaxValues()
		local showText = false
		healthBar:SetMinMaxValues(minValue, maxValue)
		healthBar:SetValue(value)
		local percentValue = (value/maxValue)
		if percentValue < HBThresh then
			alert:Show()
			if percentValue < (HBThresh / 2) then
				alert:SetBackdropBorderColor(1, 0, 0, 0.9)
			else
				alert:SetBackdropBorderColor(1, 1, 0, 0.9)
			end
		elseif alert:IsShown() then
			alert:Hide()
		end
		if((value and value > 0) and (maxValue and maxValue > 1) and self:GetScale() == 1) then
			showText = true
		end
		if(HBTextFormat and showText) then
			healthBar.text:Show()
			healthBar.text:SetText(SetTextStyle(HBTextFormat, value, maxValue))
		elseif healthBar.text:IsShown() then
			healthBar.text:Hide()
		end
	end

	local function CastBarValueChanged(self, value)
		local castBar = self.sync
		local min, max = self:GetMinMaxValues()
		local isChannel = value < castBar:GetValue()
		castBar:SetMinMaxValues(min, max)
		castBar:SetValue(value)
		castBar.Text:SetFormattedText("%.1f ", value)
		local color
		if(self.shield and self.shield:IsShown()) then
			color = CBNoInterrupt
		else
			if value > 0 and (isChannel and (value/max) <= 0.02 or (value/max) >= 0.98) then
				color = {0,1,0}
			else
				color = CBColor
			end
		end
		castBar:SetStatusBarColor(unpack(color))
	end

	local function ShowThisPlate(plate)
		if(not ProxyThisPlate(plate, true)) then return; end

		if RestrictedPlates[PLATE_REALNAME] then
			SVUI_PLATE:Hide()
			return
		elseif(not SVUI_PLATE:IsShown()) then
			SVUI_PLATE:Show()
		end

		VisiblePlates[BLIZZ_PLATE] = true

		PLATE_ARGS.tiny = (BLIZZ_PLATE.healthBar:GetEffectiveScale() < 1)
		SVUI_PLATE:SetSize(BLIZZ_PLATE:GetSize())

		SVUI_PLATE.name:ClearAllPoints()
		if(PLATE_ARGS.tiny) then
			SVUI_PLATE.health:SetSize(BLIZZ_PLATE.healthBar:GetWidth() * (BLIZZ_PLATE.healthBar:GetEffectiveScale() * 1.25), HBHeight)
			SVUI_PLATE.name:SetPoint("BOTTOM", SVUI_PLATE.health, "TOP", 0, 3)
		else
			SVUI_PLATE.name:SetPoint("BOTTOMLEFT", SVUI_PLATE.health, "TOPLEFT", 0, 3)
			SVUI_PLATE.name:SetPoint("BOTTOMRIGHT", SVUI_PLATE.level, "BOTTOMLEFT", -2, 0)
		end

		UpdatePlateElements(BLIZZ_PLATE, SVUI_PLATE)

		HealthBarValueChanged(BLIZZ_PLATE.healthBar, BLIZZ_PLATE.healthBar:GetValue())

		if(not PLATE_ARGS.tiny) then
			--CheckRaidIcon()
			MOD:UpdateAuras(BLIZZ_PLATE)
		else
			PLATE_ARGS.allowed = true
		end

		if(NPUsePointer and (not NPPointerMatch)) then
			NPGlow:SetBackdropColor(unpack(NPPointerColor))
			NPGlow:SetBackdropBorderColor(unpack(NPPointerColor))
		end
	end

	local function HideThisPlate(plate)
		if(not ProxyThisPlate(plate)) then return; end

		SVUI_PLATE:Hide()
		VisiblePlates[plate] = nil
		PLATE_ARGS.classToken = nil
		plate.guid = nil
		PLATE_ARGS.unit = nil
		PLATE_ARGS.scaled = nil
		PLATE_ARGS.tiny = nil
		PLATE_ARGS.allowed = nil
		if(NPGlow:GetParent() == SVUI_PLATE) then
			NPGlow:Hide()
			if(NPGlow.FX:IsShown()) then
				NPGlow.FX:Hide()
			end
		end
		SVUI_PLATE.health.alert:Hide()
		SVUI_PLATE.health.icon:Hide()
		if SVUI_PLATE.health then
			SVUI_PLATE.health:SetSize(HBWidth, HBHeight)
			plate.castBar.Icon:SetSize(ICON_SIZE, ICON_SIZE)
		end
		if PLATE_AURAS then
			for index = 1, #PLATE_AURAICONS do
				RegisterAuraClock(PLATE_AURAICONS[index], 0)
			end
		end
		if MOD.UseCombo then
			for i=1, MAX_COMBO_POINTS do
				SVUI_PLATE.combo[i]:Hide()
			end
		end

		SVUI_PLATE:SetPoint("BOTTOMLEFT", plate, "BOTTOMLEFT")
	end

	local function UpdateThisPlate(plate)
		--print("NamePlate UpdateThisPlate Start")
		if(not ProxyThisPlate(plate, true)) then return; end
		SVUI_PLATE.name:SetFontObject(SVUI_Font_NamePlate)
		SVUI_PLATE.name:SetTextColor(1, 1, 1)
		-- SVUI_PLATE.level:SetFontObject(SVUI_Font_NamePlate_Number)
		-- if not PLATE_ARGS.scaled and not PLATE_ARGS.tiny then
		-- 	SVUI_PLATE.health:SetSize(HBWidth, HBHeight)
		-- end
		-- SVUI_PLATE.health:SetStatusBarTexture(NPBarTex)
		-- SVUI_PLATE.health.text:SetFontObject(SVUI_Font_NamePlate_Number)
		-- SVUI_PLATE.cast:SetSize(HBWidth, CBHeight)
		-- SVUI_PLATE.cast:SetStatusBarTexture(NPBarTex)
		-- SVUI_PLATE.cast.text:SetFont(SV.media.font.default, 8, "OUTLINE")
		-- SVUI_PLATE.health.icon:ClearAllPoints()
		-- SV:SetReversePoint(SVUI_PLATE.health.icon, RIAnchor, SVUI_PLATE.health, RIXoffset, RIYoffset)
		-- SVUI_PLATE.health.icon:SetSize(RISize, RISize)
		-- for index = 1, #PLATE_AURAICONS do
		-- 	if PLATE_AURAICONS and PLATE_AURAICONS[index] then
		-- 		PLATE_AURAICONS[index].TimeLeft:SetFontObject(SVUI_Font_NamePlate_Aura)
		-- 		PLATE_AURAICONS[index].Stacks:SetFontObject(SVUI_Font_NamePlate_Aura)
		-- 		PLATE_AURAICONS[index].Icon:SetTexCoord(.07, 0.93, .23, 0.77)
		-- 	end
		-- end
		--
		-- if(MOD.UseCombo and not SVUI_PLATE.combo:IsShown()) then
		-- 	SVUI_PLATE.combo:Show()
		-- elseif(SVUI_PLATE.combo:IsShown()) then
		-- 	SVUI_PLATE.combo:Hide()
		-- end
		--
		-- ShowThisPlate(plate)
		-- HealthBarSizeChanged(SVUI_PLATE.health, SVUI_PLATE.health:GetSize())
	end

	function PlateForge(source)
		local plate = source.UnitFrame;
		if(not plate) then return end;
		--print("NamePlate Creation Start")
		local ref, skin = {}, {};

		plate.healthBar:SetStatusBarTexture(SV.NoTexture)
		plate.castBar:SetStatusBarTexture(SV.NoTexture)

		plate.healthBar:Hide()
		plate.castBar:Hide()
		plate.name:ClearAllPoints()
		plate.name:Hide()

		local frame = CreateFrame("Frame", nil, plate)

		--[[ HEALTH BAR ]]--
		--print("NamePlate Creating Health")
		frame.health = CreateFrame("StatusBar", nil, frame)
		frame.health:SetPoint('BOTTOM', frame, 'BOTTOM', 0, 5)
		frame.health:SetFrameStrata("BACKGROUND")
		frame.health:SetFrameLevel(1)
		frame.health:SetStyle("Frame", "Nameplate")
		frame.health:SetScript("OnSizeChanged", HealthBarSizeChanged)
		frame.health.elitetop = frame.health.Panel.Top
		frame.health.elitebottom = frame.health.Panel.Bottom
		frame.health.sync = plate.healthBar;

		--CreatePlateBorder(frame.health)

		frame.health.text = frame.health:CreateFontString(nil, 'OVERLAY')
		frame.health.text:SetPoint("CENTER", frame.health, HBTextAnchor, HBXoffset, HBYoffset)
		frame.health.text:SetJustifyH("CENTER")

		--print("NamePlate Creating LevelText")
		frame.level = frame.health:CreateFontString(nil, 'OVERLAY')
		frame.level:SetPoint("BOTTOMRIGHT", frame.health, "TOPRIGHT", 3, 3)
		frame.level:SetJustifyH("RIGHT")

		frame.name = frame.health:CreateFontString(nil, 'OVERLAY')
		frame.name:SetJustifyH("LEFT")
--print("NamePlate Creating Icons")
		frame.eliteicon = frame:CreateTexture(nil, "OVERLAY")
		frame.skullicon = frame:CreateTexture(nil, "OVERLAY")

		frame.raidicon = frame:CreateTexture(nil, "ARTWORK")
		frame.raidicon:SetSize(NPIcons,NPIcons)
		frame.raidicon:SetPoint("RIGHT", frame.health, "LEFT", -3, 0)
		--frame.raidicon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
		frame.raidicon:SetTexture("")

		frame.health.icon = frame:CreateTexture(nil, 'ARTWORK')
		frame.health.icon:SetSize(14,14)
		frame.health.icon:SetPoint("BOTTOMRIGHT", frame.health, "TOPLEFT", -3, 3)

		frame.health.icon:SetTexture(MOD.media.roles)
		frame.health.icon:SetTexCoord(0,0.5,0.5,1)
		frame.health.icon:Hide()

		frame.highlight = frame:CreateTexture(nil, 'OVERLAY')
		frame.highlight:SetAllPoints(frame.health)
		frame.highlight:SetColorTexture(1, 1, 1, 0.3)
		frame.highlight:Hide()
--print("NamePlate Creating Alert")
		local alert = CreateFrame("Frame", nil, frame)
		alert:SetFrameLevel(0)
		alert:WrapPoints(frame.health,2,2)
		alert:SetBackdrop({
			edgeFile = SV.media.border.shadow,
			edgeSize = 2
		});
		alert:SetBackdropColor(0, 0, 0, 0)
		alert:SetBackdropBorderColor(1, 1, 0, 0.9)
		alert:SetScale(1.5)
		alert:Hide()
		frame.health.alert = alert

		plate.healthBar.sync = frame.health

		--[[ CAST BAR ]]--
--print("NamePlate Creating CastBar")
		frame.cast = CreateFrame("StatusBar", nil, frame)
		frame.cast:SetPoint('TOPLEFT', frame.health, 'BOTTOMLEFT', 0, -8)
		frame.cast:SetPoint('TOPRIGHT', frame.health, 'BOTTOMRIGHT', 0, -8)
		frame.cast:SetFrameStrata("BACKGROUND")
		frame.cast:SetStyle("Frame", 'Bar')
		frame.cast:SetFrameLevel(0)

		frame.cast.text = frame.cast:CreateFontString(nil, 'OVERLAY')
		frame.cast.text:SetPoint("RIGHT", frame.cast, "LEFT", -4, CBYoffset)
		frame.cast.text:SetJustifyH("LEFT")

		-- plate.castBar.Text:SetParent(frame.cast)
		-- plate.castBar.Text:ClearAllPoints()
		-- plate.castBar.Text:SetPoint("LEFT", frame.cast, "LEFT", CBXoffset, CBYoffset)
		-- plate.castBar.Text:SetJustifyH("LEFT")
		--
		-- plate.castBar.Icon:SetParent(frame.cast)
		-- plate.castBar.Icon:SetTexCoord(.07, .93, .07, .93)
		-- plate.castBar.Icon:SetDrawLayer("OVERLAY")
		-- plate.castBar.Icon:ClearAllPoints()
		-- plate.castBar.Icon:SetPoint("TOPLEFT", frame.health, "TOPRIGHT", 5, 0)

		-- local bgFrame = CreateFrame("Frame", nil, frame.cast)
		-- bgFrame:WrapPoints(plate.castBar.Icon)
		-- bgFrame:SetFrameLevel(bgFrame:GetFrameLevel() - 1)
		-- bgFrame:SetStyle("Frame", "Bar", true, 2, 0, 0)

		plate.castBar.sync = frame.cast
--print("NamePlate Creating Combo")
		frame.combo = CreateFrame("Frame", nil, frame.health)
		frame.combo:SetPoint("CENTER", frame.health, "BOTTOM")
		frame.combo:SetSize(68, 1)
		frame.combo:Hide()

		if MOD.UseCombo then
			for i = 1, MAX_COMBO_POINTS do
				frame.combo[i] = frame.combo:CreateTexture(nil, 'OVERLAY')
				frame.combo[i]:SetTexture(MOD.media.comboIcon)
				frame.combo[i]:SetSize(12, 12)
				frame.combo[i]:SetVertexColor(unpack(NPComboColor[i]))
				if(i == 1) then
					frame.combo[i]:SetPoint("TOPLEFT", frame.combo, "TOPLEFT")
				else
					frame.combo[i]:SetPoint("LEFT", frame.combo[i-1], "RIGHT", 2, 0)
				end
				frame.combo[i]:Hide()
			end
		end
--print("NamePlate Creating Auras")
		frame.auras = CreateFrame("Frame", nil, frame)
		frame.auras:SetHeight(32); frame.auras:Show()
		frame.auras:SetPoint('BOTTOMRIGHT', frame.health, 'TOPRIGHT', 0, 10)
		frame.auras:SetPoint('BOTTOMLEFT', frame.health, 'TOPLEFT', 0, 10)
		frame.auras:SetFrameStrata("BACKGROUND")
		frame.auras:SetFrameLevel(0)
		frame.auraicons = {}

		plate.frame = frame;
		plate.setting = {};
--print("NamePlate UpdateThisPlate")
		UpdateThisPlate(plate)
--print("NamePlate Setting Hooks")
		plate:HookScript("OnShow", ShowThisPlate)
		plate:HookScript("OnHide", HideThisPlate)
		plate:HookScript("OnSizeChanged", function(self, width, height)
			self.frame:SetSize(width, height)
		end)

		plate.healthBar:HookScript("OnValueChanged", HealthBarValueChanged)

		plate.castBar:HookScript("OnShow", function(self) self.sync:Show() end)
		plate.castBar:HookScript("OnHide", function(self) self.sync:Hide() end)
		plate.castBar:HookScript("OnValueChanged", CastBarValueChanged)

		VisiblePlates[plate] = true
		PlateRegistry[source] = true;
		--print("NamePlate Added")
	end

	function MOD:UpdateAllPlates()
		self:UpdateLocals()
		for plate, _ in pairs(VisiblePlates) do
			if(plate) then
				UpdateThisPlate(plate)
			end
		end
	end
end
--[[
##########################################################
SCANNER
##########################################################
]]--
do
	local function ParseByName(sourceName)
		if not sourceName then return; end
		local SearchFor = split("-", sourceName)
		for plate, _ in pairs(VisiblePlates) do
			if plate and plate:IsShown() and plate.nametext == SearchFor and RAID_CLASS_COLORS[plate.setting.classToken] then
				return plate
			end
		end
	end

	local function ParseByIconName(raidIcon)
		for plate, _ in pairs(VisiblePlates) do
			--CheckRaidIcon(plate)
			if plate and plate:IsShown() and plate.raidicon:IsShown() and (plate.raidicontype and plate.raidicontype == raidIcon) then
				return plate
			end
		end
	end

	function MOD:RequestScanUpdate(guid, raidIcon, name, callbackFunc, ...)
		local plate
		if guid then plate = ParseByGUID(guid) end
		if (not plate) and name then plate = ParseByName(name) end
		--if (not plate) and raidIcon then plate = ParseByIconName(raidIcon) end
		if(plate and callbackFunc and MOD[callbackFunc]) then
			MOD[callbackFunc](MOD, plate, ...)
		end
	end
end
--[[
##########################################################
EVENTS
##########################################################
]]--
function MOD:PLAYER_ENTERING_WORLD()
	self:UpdateLocals();
end

function MOD:UPDATE_MOUSEOVER_UNIT()
	WorldFrame.elapsed = 0.1
end

function MOD:PLAYER_REGEN_DISABLED()
	SetCVar("nameplateShowEnemies", 1)
end

function MOD:PLAYER_REGEN_ENABLED()
	SetCVar("nameplateShowEnemies", 0)
end

function MOD:PLAYER_TARGET_CHANGED()
	NPGlow:Hide()
	if(NPGlow.FX:IsShown()) then
		NPGlow.FX:Hide()
	end
	if(UnitExists("target")) then
		CURRENT_TARGET_NAME = UnitName("target");
		TARGET_CHECKS = 1;
		WorldFrame.elapsed = 0.1;
	else
		CURRENT_TARGET_NAME = nil;
		TARGET_CHECKS = 0;
	end
end

function MOD:UNIT_COMBO_POINTS(event, unit)
	if(unit == "player" or unit == "vehicle") then
		UpdateComboPoints()
	end
end

function MOD:UNIT_AURA(event, unit)
  if(unit == "target" or unit == "focus") then
    self:UpdateAurasByUnitID(unit)
		if(self.UseCombo) then
			UpdateComboPoints()
		end
  end
end

do
	local COMBAT_HEAL_EVENTS = {
		["SPELL_HEAL"] = true,
		["SPELL_AURA_APPLIED"] = true,
		["SPELL_CAST_START"] = true,
		["SPELL_CAST_SUCCESS"] = true,
		["SPELL_PERIODIC_HEAL"] = true,
	}

	local COMBAT_AURA_EVENTS = {
		["SPELL_AURA_BROKEN"] = 1,
		["SPELL_AURA_BROKEN_SPELL"] = 1,
		["SPELL_AURA_REMOVED"] = 1,
		["SPELL_AURA_APPLIED"] = 2,
		["SPELL_AURA_REFRESH"] = 2,
		["SPELL_AURA_APPLIED_DOSE"] = 3,
		["SPELL_AURA_REMOVED_DOSE"] = 3,
	}

	function MOD:COMBAT_LOG_EVENT_UNFILTERED(event, timestamp, combatevent, hideCaster, ...)
	  local sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellname = ...;
		local hasChange = false;
		local eventCheck = COMBAT_AURA_EVENTS[combatevent];
		if(eventCheck and destGUID and spellID) then
			if(eventCheck > 1) then
				local stackCount = 1
				local duration = LoadDuration(spellID)
				local texture = GetSpellTexture(spellID)
				if(eventCheck == 3) then stackCount = select(16, ...) end
				SetAuraInstance(destGUID, spellID, (GetTime() + duration), stackCount, sourceGUID, duration, texture)
			else
				local auraID = spellID..(tostring(sourceName or "UNKNOWN_CASTER"))
				if(auraID and UnitPlateAuras[destGUID] and UnitPlateAuras[destGUID][auraID]) then
				  UnitPlateAuras[destGUID][auraID] = nil
				end
			end
			hasChange = true;
		end

		if(NPFindHealers and COMBAT_HEAL_EVENTS[combatevent] and IsEnemyPlayer(sourceFlags) and sourceName) then
			local healerName = split("-", sourceName)
			self:RequestScanUpdate(sourceGUID, false, healerName, "UpdateHealer", healerName, spellID)
			hasChange = true;
		end

	  if(not hasChange) then
	    return
	  end

	  local rawName, raidIcon
	  if(destName and (band(destFlags, COMBATLOG_OBJECT_CONTROL_PLAYER) > 0)) then
	    rawName = split("-", destName)
	    AuraByName[rawName] = destGUID
	  end
	  for iconName, bitmask in pairs(RIconData) do
	    if band(destRaidFlags, bitmask) > 0  then
	      raidIcon = iconName
	      AuraByRaidIcon[raidIcon] = destGUID
	      break
	    end
	  end
	  self:RequestScanUpdate(destGUID, raidIcon, rawName, "UpdateAuras")
	end
end
--[[
##########################################################
UPDATE AND BUILD
##########################################################
]]--
local function PlayerRoleUpdate()
	MOD:UpdateAllPlates()
end

function MOD:UpdateLocals()
	local db = SV.db.NamePlates
	if not db then return end

	NPBarTex = LSM:Fetch("statusbar", db.barTexture);

	NPBaseAlpha = db.nonTargetAlpha;
	NPCombatHide = db.combatHide;

	RIAnchor = db.raidHealIcon.attachTo;
	RIXoffset = db.raidHealIcon.xOffset;
	RIYoffset = db.raidHealIcon.yOffset;
	RISize = db.raidHealIcon.size;

	HBThresh = db.healthBar.lowThreshold;
	NPNameMatch = db.colorNameByValue;
	HBTextFormat = db.healthBar.text.enable and db.healthBar.text.format or false;
	HBTextAnchor = db.healthBar.text.attachTo;
	HBXoffset = db.healthBar.text.xOffset;
	HBYoffset = db.healthBar.text.yOffset;
	HBWidth = db.healthBar.width;
	HBHeight = db.healthBar.height;

	NPIcons = HBHeight * 1.5

	CBColor = {db.castBar.color[1], db.castBar.color[2], db.castBar.color[3]}
	CBNoInterrupt = {db.castBar.noInterrupt[1], db.castBar.noInterrupt[2], db.castBar.noInterrupt[3]}
	CBHeight = db.castBar.height;
	CBText = db.castBar.text.enable;
	CBXoffset = db.castBar.text.xOffset;
	CBYoffset = db.castBar.text.yOffset;

	ICON_SIZE = CBHeight + HBHeight + 5

	NPUsePointer = db.pointer.enable;
	NPPointerMatch = db.pointer.colorMatchHealthBar;
	NPPointerColor = {db.pointer.color[1], db.pointer.color[2], db.pointer.color[3], 0.5};
	NPUseModel = db.pointer.useArrowEffect

	local rc = db.reactions
	NPReactTap = {rc.tapped[1], rc.tapped[2], rc.tapped[3]}
	NPReactNPCGood = {rc.friendlyNPC[1], rc.friendlyNPC[2], rc.friendlyNPC[3]}
	NPReactPlayerGood = {rc.friendlyPlayer[1], rc.friendlyPlayer[2], rc.friendlyPlayer[3]}
	NPReactNeutral = {rc.neutral[1], rc.neutral[2], rc.neutral[3]}
	NPReactEnemy = {rc.enemy[1], rc.enemy[2], rc.enemy[3]}

	AuraMaxCount = db.auras.numAuras;
	AuraFilterName = db.auras.additionalFilter
	AuraFilter = SV.db.Filters[AuraFilterName]

	NPFindHealers = db.findHealers

	local tc = SV.db.NamePlates.threat
	NPUseThreat = tc.enable;
	NPThreatGS = tc.goodScale;
	NPThreatBS = tc.badScale;
	if(SV.ClassRole == 'TANK') then
		CONFIG_THREAT_HOSTILE = {
			{tc.badColor[1], tc.badColor[2], tc.badColor[3]},
			{tc.badTransitionColor[1], tc.badTransitionColor[2], tc.badTransitionColor[3]},
			{tc.goodTransitionColor[1], tc.goodTransitionColor[2], tc.goodTransitionColor[3]},
			{tc.goodColor[1], tc.goodColor[2], tc.goodColor[3]}
		};
		CONFIG_THREAT_SCALE = { NPThreatBS, NPThreatBS, NPThreatGS, NPThreatGS };
	else
		CONFIG_THREAT_HOSTILE = {
			{tc.goodColor[1], tc.goodColor[2], tc.goodColor[3]},
			{tc.goodTransitionColor[1], tc.goodTransitionColor[2], tc.goodTransitionColor[3]},
			{tc.badTransitionColor[1], tc.badTransitionColor[2], tc.badTransitionColor[3]},
			{tc.badColor[1], tc.badColor[2], tc.badColor[3]}
		};
		CONFIG_THREAT_SCALE = { NPThreatGS, NPThreatGS, NPThreatBS, NPThreatBS };
	end

	if(not db.themed) then
		PLATE_TOP = SV.NoTexture
		PLATE_BOTTOM = SV.NoTexture
		PLATE_RIGHT = SV.NoTexture
		PLATE_LEFT = SV.NoTexture
	else
		PLATE_TOP = self.media.topArt
		PLATE_BOTTOM = self.media.bottomArt
		PLATE_RIGHT = self.media.rightArt
		PLATE_LEFT = self.media.leftArt
	end

	if (db.comboPoints and (SV.class == 'ROGUE' or SV.class == 'DRUID')) then
		self.UseCombo = true
		self:RegisterEvent("UNIT_COMBO_POINTS")
	else
		self.UseCombo = false
		self:UnregisterEvent("UNIT_COMBO_POINTS")
	end

	if (NPFindHealers) then
		self:RegisterEvent("UPDATE_BATTLEFIELD_SCORE")
	else
		self:UnregisterEvent("UPDATE_BATTLEFIELD_SCORE")
	end
end

function MOD:CombatToggle(noToggle)
	if(NPCombatHide) then
		self:RegisterEvent("PLAYER_REGEN_DISABLED")
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		if(not noToggle) then
			SetCVar("nameplateShowEnemies", 0)
		end
	else
		self:UnregisterEvent("PLAYER_REGEN_DISABLED")
		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
		if(not noToggle) then
			SetCVar("nameplateShowEnemies", 1)
		end
	end
end

function MOD:ReLoad()
	self:UpdateAllPlates();
end

function MOD:Load()
	--SV.SpecialFX:Register("platepoint", [[Spells\Arcane_missile_lvl1.m2]], -12, 48, 12, -48, 0.25, 0, 0)
	SV.SpecialFX:Register("platepoint", [[Spells\Arrow_state_animated.m2]], -12, 12, 12, -50, 0.75, 0, 0.1)
	--SV.SpecialFX:Register("platepoint", [[Spells\Cast_arcane_01.m2]], -12, 48, 12, -48, 0.25, 0, 0)
	--SV.SpecialFX:Register("platepoint", [[Spells\Cast_arcane_01.m2]], -12, 48, 12, -48, 0.25, 0, 0)
	--SV.SpecialFX:Register("platepoint", [[Spells\Shadow_precast_uber_hand.m2]],  -12, 22, 12, -22, 0.23, -0.1, 0.1)
	SV.SpecialFX:SetFXFrame(NPGlow, "platepoint", true)
	NPGlow.FX:SetParent(SV.Screen)
	NPGlow.FX:SetFrameStrata("BACKGROUND")
	NPGlow.FX:SetFrameLevel(0)
	NPGlow.FX:Hide()
	self:UpdateLocals()
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	self:RegisterEvent("UNIT_AURA")
	self:RegisterEvent("PLAYER_TARGET_CHANGED")
	self:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
	self:RegisterEvent("NAME_PLATE_CREATED")
	self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
	--WorldFrame:HookScript('OnUpdate', WorldFrameUpdateHook)
	self:CombatToggle(true)
	SV.Events:On("PLAYER_ROLE_CHANGED", PlayerRoleUpdate, true)
end
