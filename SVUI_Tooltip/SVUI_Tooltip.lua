--[[
##########################################################
S V U I   By: Failcoder
##########################################################
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local unpack 	= _G.unpack;
local select 	= _G.select;
local pairs 	= _G.pairs;
local tinsert 	= _G.tinsert;
local tremove 	= _G.tremove;
local string 	= _G.string;
local math 		= _G.math;
local table 	= _G.table;
--[[ STRING METHODS ]]--
local find, format, match, sub, gsub = string.find, string.format, string.match, string.sub, string.gsub;
--[[ MATH METHODS ]]--
local floor,min = math.floor, math.min;
--[[ TABLE METHODS ]]--
local wipe, tconcat = table.wipe, table.concat;
--[[
##########################################################
GET ADDON DATA
##########################################################
]]--
local SV = _G['SVUI']
local L = SV.L
local LSM = _G.LibStub("LibSharedMedia-3.0")
local MOD = SV.Tooltip;
if(not MOD) then return end;

MOD.Holder = CreateFrame("Frame", "SVUI_ToolTip", UIParent)
MOD.DefaultPadding = 24;
--[[
##########################################################
LOCAL VARIABLES
##########################################################
]]--
local _G = getfenv(0);
local ID = _G.ID;
local GameTooltip = _G.GameTooltip;
local GameTooltipStatusBar = _G.GameTooltipStatusBar;
local NewHook = _G.hooksecurefunc;
local playerGUID = UnitGUID("player");
local targetList, inspectCache = {}, {};

local GENDER = {"", "Male ", "Female "};
local NIL_COLOR = { r = 0, g = 0, b = 0 };
local TAPPED_COLOR = { r = .6, g = .6, b = .6 };
local SKULL_ICON = "|TInterface\\TARGETINGFRAME\\UI-TargetingFrame-Skull.blp:16:16|t";
local TAMABLE_INDICATOR = "|cffFFFF00Tamable|r";

local TAMABLE_FAMILIES = {
	["Basilisk"] = true, 	 ["Bat"] = true, 		  ["Bear"] = true, 		   ["Beetle"] = true,
	["Bird of Prey"] = true, ["Boar"] = true, 		  ["Carrion Bird"] = true, ["Cat"] = true,
	["Chimaera"] = true, 	 ["Core Hound"] = true,   ["Crab"] = true, 		   ["Crane"] = true,
	["Crocolisk"] = true, 	 ["Devilsaur"] = true, 	  ["Direhorn"] = true, 	   ["Dog"] = true,
	["Dragonhawk"] = true, 	 ["Fox"] = true, 		  ["Goat"] = true, 		   ["Gorilla"] = true,
	["Wasp"] = true, 		 ["Hydra"] = true, 		  ["Hyena"] = true, 	   ["Monkey"] = true,
	["Moth"] = true, 		 ["Nether Ray"] = true,   ["Porcupine"] = true,    ["Quilen"] = true,
	["Raptor"] = true, 		 ["Ravager"] = true, 	  ["Rhino"] = true, 	   ["Riverbeast"] = true,
	["Scorpid"] = true, 	 ["Shale Spider"] = true, ["Spirit Beast"] = true, ["Serpent"] = true,
	["Silithid"] = true, 	 ["Spider"] = true, 	  ["Sporebat"] = true, 	   ["Tallstrider"] = true,
	["Turtle"] = true,		 ["Warp Stalker"] = true, ["Wasp"] = true, 		   ["Water strider"] = true,
	["Wind Serpent"] = true, ["Wolf"] = true, 		  ["Worm"] = true
};

local tooltips = {
	GameTooltip, ItemRefTooltip, ItemRefShoppingTooltip1,
	ItemRefShoppingTooltip2, ItemRefShoppingTooltip3, AutoCompleteBox,
	FriendsTooltip, ConsolidatedBuffsTooltip, ShoppingTooltip1,
	ShoppingTooltip2, ShoppingTooltip3, WorldMapTooltip,
	WorldMapCompareTooltip1, WorldMapCompareTooltip2,
	WorldMapCompareTooltip3, DropDownList1MenuBackdrop,
	DropDownList2MenuBackdrop, DropDownList3MenuBackdrop, BNToastFrame,
	PetBattlePrimaryAbilityTooltip, PetBattlePrimaryUnitTooltip,
	BattlePetTooltip, FloatingBattlePetTooltip, FloatingPetBattleAbilityTooltip, FloatingGarrisonFollowerTooltip,
	GarrisonMissionMechanicTooltip, GarrisonFollowerTooltip,
	GarrisonMissionMechanicFollowerCounterTooltip, GarrisonFollowerAbilityTooltip,
	SmallTextTooltip, BrowserSettingsTooltip, QueueStatusFrame, EventTraceTooltip,
	ItemSocketingDescription
};

local INSPECT_CACHE_DURATION = 600 -- how long something lives in the inspect cache.

-- local ignored_tooltips = {
-- 	FrameStackTooltip
-- };

local classification = {
	worldboss = format("|cffAF5050%s|r", BOSS),
	rareelite = format("|cffAF5050+%s|r", ITEM_QUALITY3_DESC),
	elite = "|cffAF5050+|r",
	rare = format("|cffAF5050%s|r", ITEM_QUALITY3_DESC)
};
--[[
##########################################################
LOCAL UPVALUES
##########################################################
]]--
local COMIC_TIPS = true;
local TIP_ICONS = true;
local SPELL_IDS = false;
local ON_CURSOR = false;
local TARGET_INFO = true;
local PLAYER_INFO = true;
local GENDER_INFO = false;
local INSPECT_INFO = false;
local GUILD_INFO = true;
local VISIBILITY_UNITS = "NONE";
local VISIBILITY_COMBAT = false;
local BAR_TEXT = true;
local BAR_HEIGHT = 10;
local ITEM_COUNTS = true;

local VisibilityTest = {
	NONE = function() return false end,
	ALL = function() return true end,
	SHIFT = function() return (not IsShiftKeyDown()) end,
	CTRL = function() return (not IsControlKeyDown()) end,
	ALT = function() return (not IsAltKeyDown()) end,
};
--[[
##########################################################
LOCAL FUNCTIONS
##########################################################
]]--
local function Pinpoint(parent)
    local centerX,centerY = parent:GetCenter()
    local screenWidth = GetScreenWidth()
    local screenHeight = GetScreenHeight()
    local result;
    if not centerX or not centerY then
        return "CENTER"
    end
    local heightTop = screenHeight * 0.75;
    local heightBottom = screenHeight * 0.25;
    local widthLeft = screenWidth * 0.25;
    local widthRight = screenWidth * 0.75;
    if(((centerX > widthLeft) and (centerX < widthRight)) and (centerY > heightTop)) then
        result="TOP"
    elseif((centerX < widthLeft) and (centerY > heightTop)) then
        result="TOPLEFT"
    elseif((centerX > widthRight) and (centerY > heightTop)) then
        result="TOPRIGHT"
    elseif(((centerX > widthLeft) and (centerX < widthRight)) and centerY < heightBottom) then
        result="BOTTOM"
    elseif((centerX < widthLeft) and (centerY < heightBottom)) then
        result="BOTTOMLEFT"
    elseif((centerX > widthRight) and (centerY < heightBottom)) then
        result="BOTTOMRIGHT"
    elseif((centerX < widthLeft) and (centerY > heightBottom) and (centerY < heightTop)) then
        result="LEFT"
    elseif((centerX > widthRight) and (centerY < heightTop) and (centerY > heightBottom)) then
        result="RIGHT"
    else
        result="CENTER"
    end
    return result
end

local function TruncateString(value)
    if value >= 1e9 then
        return ("%.1fb"):format(value/1e9):gsub("%.?0+([kmb])$","%1")
    elseif value >= 1e6 then
        return ("%.1fm"):format(value/1e6):gsub("%.?0+([kmb])$","%1")
    elseif value >= 1e3 or value <= -1e3 then
        return ("%.1fk"):format(value/1e3):gsub("%.?0+([kmb])$","%1")
    else
        return value
    end
end

local function GetTalentSpec(unit,isPlayer)
	local spec;
	if isPlayer then
		spec = GetSpecialization()
	else
		spec = GetInspectSpecialization(unit)
	end
	if spec ~= nil and spec > 0 then
		if not isPlayer then
			local byRole = GetSpecializationRoleByID(spec)
			if byRole ~= nil then
				local _,byRoleData = GetSpecializationInfoByID(spec)
				return byRoleData
			end
		else
			local _,specData = GetSpecializationInfo(spec)
			return specData
		end
	end
end

local function AddIcon(self, icon)
	if((not TIP_ICONS) or (not icon)) then return end
	local title = _G[self:GetName() .. "TextLeft1"]
	if(title) then
		local text = title:GetText() or '';
		if((not text) or (not text:find("|T" .. icon))) then
			title:SetFormattedText("|T%s:20:20:0:0:64:64:5:59:5:59:%d|t  %s", icon, 20, text)
		end
	end
end
--[[
##########################################################
CORE FUNCTIONS
##########################################################
]]--
local SetMaskBorderColor = function(self, r, g, b, hasStatusBar)
	if(self:GetAlpha() == 0) then
		self:FadeIn()
	end
	--self:SetBackdropColor(0, 0, 0, 0.8)
	-- if(COMIC_TIPS) then
	-- 	local a = self.ToggleAlpha
	-- 	if(hasStatusBar) then
	-- 		self[1]:SetVertexColor(r, g, b, a)
	-- 		self[2]:SetVertexColor(r, g, b, a)
	-- 		self[3]:SetVertexColor(0, 0, 0, 0)
	-- 		self[4]:SetVertexColor(0, 0, 0, 0)
	-- 	else
	-- 		self[1]:SetVertexColor(0, 0, 0, 0)
	-- 		self[2]:SetVertexColor(0, 0, 0, 0)
	-- 		self[3]:SetVertexColor(r, g, b, a)
	-- 		self[4]:SetVertexColor(r, g, b, a)
	-- 	end
	-- end
	r,g,b = (r * 0.5),(g * 0.5),(b * 0.5)
	self[5]:SetTexture(r, g, b, 1)
	self[6]:SetTexture(r, g, b, 1)
	self[7]:SetTexture(r, g, b, 1)
	self[8]:SetTexture(r, g, b, 1)
	--print('Set Color')
end

local ClearMaskColors = function(self, hide)
	--self[1]:SetVertexColor(0, 0, 0, 0)
	--self[2]:SetVertexColor(0, 0, 0, 0)
	--self[3]:SetVertexColor(0, 0, 0, 0)
	--self[4]:SetVertexColor(0, 0, 0, 0)

	self[5]:SetColorTexture(0, 0, 0, 0)
	self[6]:SetColorTexture(0, 0, 0, 0)
	self[7]:SetColorTexture(0, 0, 0, 0)
	self[8]:SetColorTexture(0, 0, 0, 0)

	-- if(hide) then
	-- 	self:SetBackdropColor(0, 0, 0, 0)
	-- end
end

function MOD:INSPECT_READY(event, GUID)
	if(MOD.lastGUID ~= GUID) then return end
	local unit = "mouseover"
	if(UnitExists(unit)) then
		local itemLevel = SV:ParseGearSlots(unit, true)
		local spec = GetTalentSpec(unit)
		inspectCache[GUID] = {time = GetTime()}
		if(spec) then
			inspectCache[GUID].talent = spec
		end
		if(itemLevel) then
			inspectCache[GUID].itemLevel = itemLevel
		end
		GameTooltip:SetUnit(unit)
	end
	MOD:UnregisterEvent("INSPECT_READY")
end

local function ShowInspectInfo(this, unit, unitLevel, r, g, b, iteration)
	local inspectable = CanInspect(unit)
	if((not inspectable) or (unitLevel < 10) or (iteration > 2)) then return end
	local GUID = UnitGUID(unit)

	if(GUID == playerGUID) then
		local total,equipped = GetAverageItemLevel()
		this:AddDoubleLine(L["Talent Specialization:"], GetTalentSpec(unit, true), nil, nil, nil, r, g, b)
		this:AddDoubleLine(L["Item Level:"], floor(equipped), nil, nil, nil, 1, 1, 1)
	elseif(inspectCache[GUID]) then
		local talent = inspectCache[GUID].talent;
		local itemLevel = inspectCache[GUID].itemLevel;
		if(((GetTime() - inspectCache[GUID].time) > INSPECT_CACHE_DURATION) or not talent or not itemLevel) then
			inspectCache[GUID] = nil;
			return ShowInspectInfo(this,unit,unitLevel,r,g,b,iteration+1)
		end
		this:AddDoubleLine(L["Talent Specialization:"],talent,nil,nil,nil,r,g,b)
		this:AddDoubleLine(L["Item Level:"],itemLevel,nil,nil,nil,1,1,1)
	else
		if((not inspectable) or (InspectFrame and InspectFrame:IsShown())) then
			return
		end
		MOD.lastGUID = GUID;
		NotifyInspect(unit)
		MOD:RegisterEvent("INSPECT_READY")
	end
end

local function tipcleaner(this)
	for i=3, this:NumLines() do
		local tip = _G["GameTooltipTextLeft"..i]
		local tipText = tip:GetText()
		if(tipText and (tipText:find(PVP) or tipText:find(FACTION_ALLIANCE) or tipText:find(FACTION_HORDE))) then
			tip:SetText(nil)
			tip:Hide()
		end
	end
end

local function tiplevel(this, start)
	for i = start, this:NumLines() do
		local tip = _G["GameTooltipTextLeft"..i]
		if tip:GetText() and tip:GetText():find(LEVEL) then
			return tip
		end
	end
end

local function tipbackground(this)
	this:SetBackdropColor(0, 0, 0, 0.8)
	--this:SetBackdropBorderColor(0, 0, 0, 1)
	if(this.SuperBorder) then
		--this.SuperBorder:SetBackdropColor(0, 0, 0, 0.8)
		if(not GameTooltipStatusBar:IsShown()) then
			this.SuperBorder:ClearAllPoints()
			this.SuperBorder:SetPoint("TOPLEFT", this, "TOPLEFT", -1, 1)
			this.SuperBorder:SetPoint("BOTTOMRIGHT", this, "BOTTOMRIGHT", 1, -1)
		end
	end
end

local function tipupdate(this, color, hasStatusBar)
	if(hasStatusBar) then
		local barColor = color or TAPPED_COLOR
		GameTooltipStatusBar:SetStatusBarColor(barColor.r, barColor.g, barColor.b)
	end
	if(this.SuperBorder) then
		local mask = this.SuperBorder
		local borderColor = color or NIL_COLOR
		local yOffset = (hasStatusBar) and mask.ToggleHeight or 0;
		mask:ClearAllPoints()
		mask:SetPoint("TOPLEFT", this, "TOPLEFT", -1, 1)
		mask:SetPoint("BOTTOMRIGHT", this, "BOTTOMRIGHT", 1, yOffset)
		mask:SetMaskBorderColor(borderColor.r, borderColor.g, borderColor.b, hasStatusBar)
	end
end

local _hook_GameTooltip_OnTooltipSetUnit = function(self)
	--print('SetUnit: ' .. self:GetName())
	if(not self) then return end
	tipbackground(self)

	local unit = select(2, self:GetUnit())

	-- local TamablePet;
	if(self:GetOwner() ~= UIParent) then
		if(VisibilityTest[VISIBILITY_UNITS] and VisibilityTest[VISIBILITY_UNITS]()) then
			self:Hide()
			return
		end
	end
	if not unit then
		local mFocus = GetMouseFocus()
		if mFocus and mFocus:GetAttribute("unit") then
			unit = mFocus:GetAttribute("unit")
		end
		if not unit or not UnitExists(unit) then return end
	end

	tipcleaner(self)
	local unitLevel = UnitLevel(unit)
	local colors, qColor, totColor;
	local lvlLine;
	local lineIncrement = 2;
	local isShiftKeyDown = IsShiftKeyDown()

	if UnitIsPlayer(unit) then
		local className, classToken = UnitClass(unit)
		local unitName, unitRealm = UnitName(unit)
		local guildName, guildRankName, _, guildRealm = GetGuildInfo(unit)
		local gender = GENDER[UnitSex(unit)];
		local realmRelation = UnitRealmRelationship(unit)
		local nameString = "";
		colors = RAID_CLASS_COLORS[classToken] or CUSTOM_CLASS_COLORS[classToken] or RAID_CLASS_COLORS['ROGUE']

		if(PLAYER_INFO) then
			nameString = UnitPVPName(unit) or unitName
		else
			nameString = unitName
		end

		if unitRealm and unitRealm ~= "" then
			if(isShiftKeyDown) then
				nameString = nameString.."-"..unitRealm
			elseif(realmRelation == LE_REALM_RELATION_COALESCED) then
				nameString = nameString..FOREIGN_SERVER_LABEL
			elseif(realmRelation == LE_REALM_RELATION_VIRTUAL) then
				nameString = nameString..INTERACTIVE_SERVER_LABEL
			end
		end

		if(UnitIsAFK(unit)) then
			GameTooltipTextLeft1:SetFormattedText("[|cffFF0000%s|r] |c%s%s|r ", L["AFK"], colors.colorStr, nameString)
		elseif(UnitIsDND(unit)) then
			GameTooltipTextLeft1:SetFormattedText("[|cffFF9900%s|r] |c%s%s|r ", L["DND"], colors.colorStr, nameString)
		else
			GameTooltipTextLeft1:SetFormattedText("|c%s%s|r", colors.colorStr, nameString)
		end

		if(guildName) then
			if(guildRealm and isShiftKeyDown) then
				guildName = guildName.."-"..guildRealm
			end

			if(guildRankName and GUILD_INFO) then
				GameTooltipTextLeft2:SetText(("<|cff00ff10%s|r> [|cff00ff10%s|r]"):format(guildName, guildRankName))
			else
				GameTooltipTextLeft2:SetText(("<|cff00ff10%s|r>"):format(guildName))
			end
			lineIncrement = lineIncrement + 1
		end

		lvlLine = tiplevel(self, lineIncrement)

		if(lvlLine and className) then
			qColor = GetQuestDifficultyColor(unitLevel)
			local race, englishRace = UnitRace(unit)
			local _, factionGroup = UnitFactionGroup(unit)

			if(factionGroup and englishRace == "Pandaren") then
				race = factionGroup.." "..race
			end

			if(GENDER_INFO) then
				local gender = GENDER[UnitSex(unit)];
				if(gender) then race = race .. " " .. gender end
			end
			lvlLine:SetFormattedText("|cff%02x%02x%02x%s|r %s |c%s%s|r", qColor.r * 255, qColor.g * 255, qColor.b * 255, unitLevel > 0 and unitLevel or SKULL_ICON, race or "", colors.colorStr, className)
		end

		if(not IsAddOnLoaded("HealBot") and (INSPECT_INFO or isShiftKeyDown)) then
			ShowInspectInfo(self, unit, unitLevel, colors.r, colors.g, colors.b, 0)
		end
	else
		if UnitIsTapDenied(unit) then
			colors = TAPPED_COLOR
		else
			colors = FACTION_BAR_COLORS[UnitReaction(unit, "player")]
		end

		lvlLine = tiplevel(self, 2)

		if(lvlLine) then
			local creatureClassification = UnitClassification(unit)
			local creatureType = UnitCreatureType(unit)
			local temp = ""
			if(UnitIsWildBattlePet(unit) or UnitIsBattlePetCompanion(unit)) then
				unitLevel = UnitBattlePetLevel(unit)
				local ab = C_PetJournal.GetPetTeamAverageLevel()
				if ab then
					qColor = GetRelativeDifficultyColor(ab, unitLevel)
				else
					qColor = GetQuestDifficultyColor(unitLevel)
				end
			else
				qColor = GetQuestDifficultyColor(unitLevel)
			end

			if UnitIsPVP(unit) then
				temp = format(" (%s)", PVP)
			end

			if(creatureType) then
				local family = UnitCreatureFamily(unit) or creatureType
				if(SV.class == "HUNTER" and creatureType == PET_TYPE_SUFFIX[8] and (family and TAMABLE_FAMILIES[family])) then
					local hunterLevel = UnitLevel("player")
					-- if(unitLevel <= hunterLevel) then
					-- 	TamablePet = true
					-- end
				end
				creatureType = family
			else
				creatureType = ""
			end

			lvlLine:SetFormattedText("|cff%02x%02x%02x%s|r %s %s%s", qColor.r * 255, qColor.g * 255, qColor.b * 255, unitLevel > 0 and unitLevel or "??", classification[creatureClassification] or "", creatureType, temp)
		end
	end
	-- if(TamablePet) then
	-- 	self:AddLine(TAMABLE_INDICATOR)
	-- end
	if(TARGET_INFO) then
		local unitTarget = unit.."target"
		if(unit ~= "player" and UnitExists(unitTarget)) then
			if UnitIsPlayer(unitTarget) and not UnitHasVehicleUI(unitTarget) then
				totColor = RAID_CLASS_COLORS[select(2, UnitClass(unitTarget))]
			else
				totColor = FACTION_BAR_COLORS[UnitReaction(unitTarget, "player")]
			end
			self:AddDoubleLine(format("%s:", TARGET), format("|cff%02x%02x%02x%s|r", totColor.r * 255, totColor.g * 255, totColor.b * 255, UnitName(unitTarget)))
		end
		if IsInGroup() then
			for i = 1, GetNumGroupMembers() do
				local groupedUnit = IsInRaid() and "raid"..i or "party"..i;
				if UnitIsUnit(groupedUnit.."target", unit) and not UnitIsUnit(groupedUnit, "player") then
					local _, classToken = UnitClass(groupedUnit)
					tinsert(targetList, format("|c%s%s|r", RAID_CLASS_COLORS[classToken].colorStr, UnitName(groupedUnit)))
				end
			end
			local maxTargets = #targetList;
			if maxTargets > 0 then
				self:AddLine(format("%s (|cffffffff%d|r): %s", L["Targeted By:"], maxTargets, tconcat(targetList, ", ")), nil, nil, nil, true)
				wipe(targetList)
			end
		end
	end

	tipupdate(self, colors, GameTooltipStatusBar:IsShown())
end

local _hook_GameTooltipStatusBar_OnValueChanged = function(self, value)
	if((not value) or (not BAR_TEXT) or (not self.text)) then return end
	local tooltip = self:GetParent()
	local unit = select(2, tooltip:GetUnit())
	if not unit then
		-- We used to get try this but it's broken in 7.1
		-- local mFocus = GetMouseFocus()
		-- if mFocus and mFocus:GetAttribute("unit") then
		-- 	unit = mFocus:GetAttribute("unit")
		-- end
		return
	end
	local min,max = self:GetMinMaxValues()
	if((value > 0) and (max == 1)) then
		self.text:SetText(format("%d%%",floor(value * 100)))
		self:SetStatusBarColor(TAPPED_COLOR.r,TAPPED_COLOR.g,TAPPED_COLOR.b)
	elseif((value == 0) or (unit and UnitIsDeadOrGhost(unit))) then
		self.text:SetText(DEAD)
	else
		self.text:SetText(TruncateString(value).." / "..TruncateString(max))
	end
end


local _hook_GameTooltip_OnTooltipSetItem = function(self)
	tipbackground(self)
	local key,itemLink = self:GetItem()
	if(key and (not self.itemCleared)) then
		if(itemLink) then
			local itemName, _, quality, _, _, _, _, _, equipSlot, icon = GetItemInfo(itemLink)
			AddIcon(self, icon)
			if(quality) then
				local r,g,b = GetItemQualityColor(quality)
				self.SuperBorder:SetMaskBorderColor(r, g, b)
			end
		end
		
		if(ITEM_COUNTS and SV.SetLootTooltip) then
			SV:SetLootTooltip(self, key)
		end

		if(SPELL_IDS and (itemLink ~= nil)) then
			self:AddLine(" ")
			local left = "|cFFCA3C3CSpell ID: |r"
			local itemID = ("|cFFCA3C3C%s|r %s"):format(left, itemLink):match(":(%w+)")
			self:AddLine(("|cFFCA3C3C%s# %d|r"):format(ID, itemID))
		end

		-- self:AddLine(("|cffFFFF00 Equip: %s|r"):format(equipSlot))
		-- self:AddLine(("|cffFFFF00 Quality: %s|r"):format(quality))

		if(self.InjectedDouble and self.InjectedDouble[8]) then
			self:AddLine(" ");
			self:AddDoubleLine(unpack(self.InjectedDouble));
		end

		self.itemCleared = true
	end
end

local _hook_GameTooltip_ShowStatusBar = function(self, ...)
	local name = self:GetName()
	local barName = ("%sStatusBar%d"):format(name, self.shownStatusBars)
	local bar = _G[barName]
	if bar and not bar.styled then
		bar:RemoveTextures()
		bar:SetStatusBarTexture(SV.media.statusbar.default)
		bar:SetStyle("!_Frame", 'Inset',true)
		if not bar.border then
			local border=CreateFrame("Frame",nil,bar)
			border:WrapPoints(bar,1,1)
			border:SetFrameLevel(bar:GetFrameLevel() - 1)
			border:SetBackdrop({
				edgeFile=[[Interface\BUTTONS\WHITE8X8]],
				edgeSize=1,
				insets={left=1,right=1,top=1,bottom=1}
			})
			border:SetBackdropBorderColor(0,0,0,1)
			bar.border=border
		end
		bar.styled=true
	end
end

local _hook_OnSetUnitAura = function(self, unit, index, filter)
	tipbackground(self)
	local _, _, _, _, _, _, _, caster, _, _, spellID = UnitAura(unit, index, filter)
	if(spellID) then
		if caster then
			local name = UnitName(caster)
			local _, class = UnitClass(caster)
			local color = RAID_CLASS_COLORS[class]
			if(color) then
				self.SuperBorder:SetMaskBorderColor(color.r, color.g, color.b)
				self:AddDoubleLine(("|c%sCast By|r"):format(color.colorStr), format("|c%s%s|r", color.colorStr, name))
			end
		end
		if(SPELL_IDS) then
			self:AddLine(("|cFFCA3C3C%s# %d|r"):format(ID, spellID))
		end
		self:Show()
	end
end

local _hook_OnSetHyperUnitAura = function(self, unit, index, filter)
	tipbackground(self)
	if unit ~= "player" then return end
	local auraName, _, _, _, _, _, _, caster, _, shouldConsolidate, spellID = UnitAura(unit, index, filter)
	if shouldConsolidate then
		if caster then
			local name = UnitName(caster)
			local _, class = UnitClass(caster)
			local color = RAID_CLASS_COLORS[class]
			if color then
				self.SuperBorder:SetMaskBorderColor(color.r, color.g, color.b)
				self:AddDoubleLine(("|cFFCA3C3C%s|r"):format(auraName), format("|c%s%s|r", color.colorStr, name))
			end
		else
			self:AddLine(("|cFFCA3C3C%s|r"):format(auraName))
		end
		self:Show()
	end
end

local _hook_GameTooltip_OnTooltipSetSpell = function(self)
	local ref = select(3, self:GetSpell())
	if not ref then return end
	local text = ("|cFFCA3C3C%s# %d|r"):format(ID, ref)
	local max = self:NumLines()
	local check;
	for i = 1, max do
		local tip = _G[("GameTooltipTextLeft%d"):format(i)]
		if tip and tip:GetText() and tip:GetText():find(text) then
			check = true;
			break
		end
	end
	if not check then
		tipbackground(self)
		self:AddLine(text)
		self:Show()
	end
end

local _hook_GameTooltip_SetDefaultAnchor = function(self, parent)
	tipbackground(self)
	if(self:GetAnchorType() ~= "ANCHOR_NONE") then return end
	if(InCombatLockdown() and VISIBILITY_COMBAT) then
		self:Hide()
		return
	end
	if parent then
		if(ON_CURSOR) then
			self:SetOwner(parent, "ANCHOR_CURSOR")
			return
		else
			self:SetOwner(parent, "ANCHOR_NONE")
		end
	end
	if(MOD.Holder.Grip and (not MOD.Holder.Grip:HasMoved())) then
		self:ClearAllPoints()
		if(SV.Inventory and SV.Inventory.MasterFrame and SV.Inventory.MasterFrame:IsShown()) then
			self:SetPoint("BOTTOMLEFT", SV.Inventory.MasterFrame, "TOPLEFT", 0, MOD.DefaultPadding)
		elseif(SV.Dock.BottomRight:GetAlpha() == 1 and SV.Dock.BottomRight:IsShown()) then
			self:SetPoint("BOTTOMLEFT", SV.Dock.BottomRight.Window, "TOPLEFT", 0, MOD.DefaultPadding)
		else
			self:SetPoint("BOTTOMLEFT", SV.Dock.BottomRight.Bar, "TOPLEFT", 0, MOD.DefaultPadding)
		end
	else
		local point = Pinpoint(MOD.Holder.Grip)
		self:ClearAllPoints()
		if(point == "TOPLEFT") then
			self:SetPoint("TOPLEFT", MOD.Holder.Grip, "TOPLEFT", 0, 0)
		elseif(point == "TOPRIGHT") then
			self:SetPoint("TOPRIGHT", MOD.Holder.Grip, "TOPRIGHT", 0, 0)
		elseif(point == "BOTTOMLEFT" or point == "LEFT" )then
			self:SetPoint("BOTTOMLEFT", MOD.Holder.Grip, "BOTTOMLEFT", 0, 0)
		else
			self:SetPoint("BOTTOMRIGHT", MOD.Holder.Grip, "BOTTOMRIGHT", 0, 0)
		end
	end
end

MOD.GameTooltip_SetDefaultAnchor = _hook_GameTooltip_SetDefaultAnchor

local _hook_BNToastOnShow = function(self,anchor,parent,relative,x,y)
	if parent ~= BNToastFrame_MOVE then
		BNToastFrame:ClearAllPoints()
		BNToastFrame:SetPoint('TOPLEFT',BNToastFrame_MOVE,'TOPLEFT')
	end
end

local _hook_OnItemRef = function(link, text, button, chatFrame)
	if link:find("^spell:") then
		local ref = sub(link,7)
		ItemRefTooltip:AddLine(("|cFFCA3C3C%s|r %d"):format(ID, ref))
		ItemRefTooltip:Show()
	end
end

local TooltipModifierChangeHandler = function(self, event, mod)
	if (mod == "LSHIFT" or mod == "RSHIFT") and UnitExists("mouseover") then
		GameTooltip:SetUnit("mouseover")
	end
end

local Override_BGColor = function(self, r, g, b, a)
	if((r ~= 0) and (g ~= 0) and (b ~= 0)) then
		self:SetBackdropColor(0, 0, 0, 0.8)
		--self.SuperBorder:SetBackdropColor(r, g, b, 0.8)
	end
end

local Override_BorderColor = function(self, r, g, b, a)
	self.SuperBorder:SetMaskBorderColor(r, g, b, 1)
end

local _hook_OnTipCleared = function(self)
	tipbackground(self)
	self.SuperBorder:ClearMaskColors()
	self.itemCleared = nil
end

local _hook_OnTipShow = function(self)
	--print('Showing: ' .. self:GetName())
	tipbackground(self)
end

local _hook_OnTipHide = function(self)
	--print('Hide')
	tipbackground(self)
	self.SuperBorder:ClearMaskColors(true)
	if(self.InjectedDouble) then
		wipe(self.InjectedDouble)
	end
end

local _hook_OnSizeChanged = function(self)
	if((not COMIC_TIPS) or (not self.SuperBorder)) then return; end
	local height = self:GetHeight() or 32
	local heightScale = min(64, height)
	local width = self:GetWidth() or 64
	local widthScale = min(128, width)
	self.SuperBorder[1]:SetSize(widthScale,(widthScale * 0.35))
	self.SuperBorder[2]:SetSize(widthScale,(widthScale * 0.35))
	self.SuperBorder[3]:SetSize(heightScale,heightScale)
	self.SuperBorder[4]:SetSize(heightScale,heightScale)
end

function MOD:SetCustomStyle(tooltip)
	if(not tooltip) then return end
	local barHeight = GameTooltipStatusBar:GetHeight()
	local barOffset = 0
    local alpha = 0.2
    if(tooltip == GameTooltip) then
        barOffset = (barHeight + 6) * -1
        alpha = 0.5
    end

    local mask = CreateFrame("Frame", nil, tooltip)
    mask:SetPoint("TOPLEFT", tooltip, "TOPLEFT", -1, 1)
    mask:SetPoint("BOTTOMRIGHT", tooltip, "BOTTOMRIGHT", 1, barOffset)
    mask:SetFrameLevel(0)
    mask.ToggleHeight = barOffset
    mask.ToggleAlpha = alpha

    --[[ STARBURST TOP ]]
    mask[1] = mask:CreateTexture(nil, "BACKGROUND")
    mask[1]:SetPoint("BOTTOMLEFT", mask, "TOPLEFT", 0, 0)
    mask[1]:SetHeight(mask:GetWidth() * 0.25)
    mask[1]:SetWidth(mask:GetWidth() * 0.25)
    -- mask[1]:SetTexture(MOD.media.topArt)
    -- mask[1]:SetVertexColor(0,0,0)
    -- mask[1]:SetBlendMode("BLEND")
    -- mask[1]:SetAlpha(alpha)
    --[[ STARBURST BOTTOM ]]
    mask[2] = mask:CreateTexture(nil, "BACKGROUND")
    mask[2]:SetPoint("TOPRIGHT", mask, "BOTTOMRIGHT", 0, 0)
    mask[2]:SetHeight(mask:GetWidth() * 0.25)
    mask[2]:SetWidth(mask:GetWidth() * 0.25)
    --mask[2]:SetTexture(MOD.media.bottomArt)
    --mask[2]:SetVertexColor(0,0,0)
    --mask[2]:SetBlendMode("BLEND")
    --mask[2]:SetAlpha(alpha)
    --[[ HALFTONE RIGHT ]]
    mask[3] = mask:CreateTexture(nil, "BACKGROUND")
    mask[3]:SetPoint("LEFT", mask, "RIGHT", 0, 0)
    mask[3]:SetSize(64,64)
    -- mask[3]:SetTexture(MOD.media.rightArt)
    -- mask[3]:SetVertexColor(0,0,0)
    -- mask[3]:SetBlendMode("BLEND")
    -- mask[3]:SetAlpha(alpha)
    --[[ HALFTONE LEFT ]]
    mask[4] = mask:CreateTexture(nil, "BACKGROUND")
    mask[4]:SetPoint("RIGHT", mask, "LEFT", 0, 0)
    mask[4]:SetSize(64,64)
    -- mask[4]:SetTexture(MOD.media.leftArt)
    -- mask[4]:SetVertexColor(0,0,0)
    -- mask[4]:SetBlendMode("BLEND")
    -- mask[4]:SetAlpha(alpha)

    --[[ BORDER TOP ]]
    mask[5] = mask:CreateTexture(nil, "OVERLAY")
    mask[5]:SetPoint("TOPLEFT", mask, "TOPLEFT", 0, 0)
    mask[5]:SetPoint("TOPRIGHT", mask, "TOPRIGHT", 0, 0)
    mask[5]:SetHeight(1)
    mask[5]:SetColorTexture(0,0,0)
    --[[ BORDER BOTTOM ]]
    mask[6] = mask:CreateTexture(nil, "OVERLAY")
    mask[6]:SetPoint("BOTTOMLEFT", mask, "BOTTOMLEFT", 0, 0)
    mask[6]:SetPoint("BOTTOMRIGHT", mask, "BOTTOMRIGHT", 0, 0)
    mask[6]:SetHeight(1)
    mask[6]:SetColorTexture(0,0,0)
    --[[ BORDER RIGHT ]]
    mask[7] = mask:CreateTexture(nil, "OVERLAY")
    mask[7]:SetPoint("TOPRIGHT", mask, "TOPRIGHT", 0, 0)
    mask[7]:SetPoint("BOTTOMRIGHT", mask, "BOTTOMRIGHT", 0, 0)
    mask[7]:SetWidth(1)
    mask[7]:SetColorTexture(0,0,0)
    --[[ BORDER LEFT ]]
    mask[8] = mask:CreateTexture(nil, "OVERLAY")
    mask[8]:SetPoint("TOPLEFT", mask, "TOPLEFT", 0, 0)
    mask[8]:SetPoint("BOTTOMLEFT", mask, "BOTTOMLEFT", 0, 0)
    mask[8]:SetWidth(1)
    mask[8]:SetColorTexture(0,0,0)

    mask:SetBackdrop(SV.media.backdrop.tooltip)
    --mask:SetBackdropBorderColor(0, 0, 0)

    mask.SetMaskBorderColor = SetMaskBorderColor
	mask.ClearMaskColors = ClearMaskColors

	tooltip.SuperBorder = mask;

    SV.API:Set("Tooltip", tooltip)

	NewHook(tooltip, "SetBackdropColor", Override_BGColor)
	--NewHook(tooltip, "SetBackdropBorderColor", Override_BorderColor)
	tooltip:HookScript("OnShow", _hook_OnTipShow)
	tooltip:HookScript("OnHide", _hook_OnTipHide)
	tooltip:HookScript("OnSizeChanged", _hook_OnSizeChanged)
end


local function ApplyTooltipSkins()
	for i, tooltip in pairs(tooltips) do
		if(not tooltip) then return end
		if(not tooltip.InjectedDouble) then
			tooltip.InjectedDouble = {}
		end
		if(not tooltip.SuperBorder) then
			MOD:SetCustomStyle(tooltip)
			tremove(tooltips, i)
		end
	end
end

local function Throttled_Styling()
	if(#tooltips > 0) then
		ApplyTooltipSkins()
	end
end

function MOD:UpdateLocals()
	COMIC_TIPS = SV.db.Tooltip.themed;
	VISIBILITY_COMBAT = SV.db.Tooltip.visibility.combat;
	BAR_HEIGHT = SV.db.Tooltip.healthBar.height;
	SPELL_IDS = SV.db.Tooltip.spellID;
	ON_CURSOR = SV.db.Tooltip.cursorAnchor;
	BAR_TEXT = SV.db.Tooltip.healthBar.text;
	TARGET_INFO = SV.db.Tooltip.targetInfo;
	PLAYER_INFO = SV.db.Tooltip.playerTitles;
	GENDER_INFO = SV.db.Tooltip.playerGender;
	INSPECT_INFO = SV.db.Tooltip.inspectInfo;
	GUILD_INFO = SV.db.Tooltip.guildRanks;
	VISIBILITY_UNITS = SV.db.Tooltip.visibility.unitFrames;
	ITEM_COUNTS = SV.db.Tooltip.itemCount;
end

function MOD:ReLoad()
	Throttled_Styling()
end

function MOD:Load()
	self:UpdateLocals()

	self.Holder:SetPoint("BOTTOMLEFT", SV.Dock.BottomRight, "TOPLEFT", 0, 56)
	self.Holder:SetSize(130, 20)
	self.Holder:SetFrameLevel(self.Holder:GetFrameLevel() + 50)
	SV:NewAnchor(self.Holder, L["Tooltip"])

	GameTooltipStatusBar:SetHeight(BAR_HEIGHT)
	GameTooltipStatusBar:SetStatusBarTexture(SV.media.statusbar.default)

	BNToastFrame:ClearAllPoints()
	BNToastFrame:SetPoint("BOTTOMRIGHT", SV.Dock.BottomLeft, "TOPRIGHT", 0, 20)
	--SV:NewAnchor(BNToastFrame, L["BattleNet Frame"], nil, nil, "BattleNetToasts")
	SV:NewAnchor(BNToastFrame, L["BattleNet Frame"])
	NewHook(BNToastFrame, "SetPoint", _hook_BNToastOnShow)

	ApplyTooltipSkins()

	GameTooltipStatusBar:ClearAllPoints()
	GameTooltipStatusBar:SetPoint("BOTTOMLEFT", GameTooltip.SuperBorder, "BOTTOMLEFT", 3, 3)
	GameTooltipStatusBar:SetPoint("BOTTOMRIGHT", GameTooltip.SuperBorder, "BOTTOMRIGHT", -3, 3)
	GameTooltipStatusBar.text = GameTooltipStatusBar:CreateFontString(nil, "OVERLAY")
	GameTooltipStatusBar.text:SetPoint("CENTER", GameTooltipStatusBar, "CENTER", 0, 0)
	GameTooltipStatusBar.text:SetFontObject(SVUI_Font_Default)


	if not GameTooltipStatusBar.border then
		local border = CreateFrame("Frame", nil, GameTooltipStatusBar)
		border:WrapPoints(GameTooltipStatusBar, 1, 1)
		border:SetFrameLevel(GameTooltipStatusBar:GetFrameLevel() - 1)
		border:SetBackdrop({edgeFile = [[Interface\BUTTONS\WHITE8X8]], edgeSize = 1})
		border:SetBackdropBorderColor(0, 0, 0, 1)
		GameTooltipStatusBar.border = border
	end

	NewHook("GameTooltip_SetDefaultAnchor", _hook_GameTooltip_SetDefaultAnchor)
	NewHook("GameTooltip_ShowStatusBar", _hook_GameTooltip_ShowStatusBar)

	NewHook("GameTooltip_ShowCompareItem", Throttled_Styling)

	NewHook(GameTooltip, "SetUnitAura", _hook_OnSetUnitAura)
	NewHook(GameTooltip, "SetUnitBuff", _hook_OnSetUnitAura)
	NewHook(GameTooltip, "SetUnitDebuff", _hook_OnSetUnitAura)
	--NewHook(GameTooltip, "SetUnitConsolidatedBuff", _hook_OnSetHyperUnitAura)

	if(SPELL_IDS) then
		NewHook("SetItemRef", _hook_OnItemRef)
		GameTooltip:HookScript("OnTooltipSetSpell", _hook_GameTooltip_OnTooltipSetSpell)
	end

	GameTooltip:HookScript("OnTooltipCleared", _hook_OnTipCleared)
	GameTooltip:HookScript("OnTooltipSetItem", _hook_GameTooltip_OnTooltipSetItem)
	GameTooltip:HookScript("OnTooltipSetUnit", _hook_GameTooltip_OnTooltipSetUnit)
	GameTooltipStatusBar:HookScript("OnValueChanged", _hook_GameTooltipStatusBar_OnValueChanged)
	self:RegisterEvent("MODIFIER_STATE_CHANGED", TooltipModifierChangeHandler)
end
