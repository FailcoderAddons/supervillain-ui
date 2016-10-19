--[[
##############################################################################
S V U I NAMEPLATES   By: joev
##############################################################################
credit: Abu.       NamePlates was adapted from AbuNameplates                 #
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
LOCAL VARS
##########################################################
]]--
local PLATE_TOP = MOD.media.topArt;
local PLATE_BOTTOM = MOD.media.bottomArt;
local PLATE_RIGHT = MOD.media.rightArt;
local PLATE_LEFT = MOD.media.leftArt;

local DriverFrame = CreateFrame('Frame', 'SVUI_Nameplates_DriverFrame', UIParent)
local UnitFrameMixin = {}
local UnitBuffMixin = {}

local path= "Interface\\Addons\\SVUI_NamePlates\\assets\\"

local NPUseThreat = false;
local NPThreatGS = 1;
local NPThreatBS = 1;
local NPReactTap = {0.3,0.3,0.3}
local NPReactNPCGood = {0.31,0.45,0.63}
local NPReactPlayerGood = {0.29,0.68,0.3}
local NPReactNeutral = {0.85,0.77,0.36}
local NPReactEnemy = {0.78,0.25,0.25}
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


local config = {
	Colors = {
		Frame 	= { 0, 0, 0 },	
		Border   = { 0.5, 0.5, 0.4 },
		Interrupt = { 0.5, 0.5, 0.4 },
	},

	IconTextures = {
		White = path..'Border\\textureWhite',
		Normal = path..'Border\\textureNormal',
		Shadow = path..'Border\\textureShadow',
	},

	-- Nameplates
	StatusbarTexture = SV.media.statusbar.default,
	Font = SV.media.font.default,
	FontSize = 10,

	SuperStyled = false,

	CombatHide = false,

	friendlyConfig = {
		useClassColors = false,
		displaySelectionHighlight = true,
		colorHealthBySelection = true,
		considerSelectionInCombatAsHostile = true,
		displayNameByPlayerNameRules = true,
		colorHealthByRaidIcon = true,
		displayName = true,
		filter = "NONE",

		castBarHeight = 8,
		healthBarHeight = 4*2,

		displayAggroHighlight = false,
		displaySelectionHighlight = true,
		--fadeOutOfRange = false,
		--displayStatusText = true,
		displayHealPrediction = true,
		--displayDispelDebuffs = true,
		colorNameBySelection = true,
		colorNameWithExtendedColors = true,
		colorHealthWithExtendedColors = true,
		colorHealthBySelection = true,
		considerSelectionInCombatAsHostile = true,
		--smoothHealthUpdates = false,
		displayNameWhenSelected = true,
		displayNameByPlayerNameRules = true,
	},

	enemyConfig = {
		useClassColors = true,
		displayAggroHighlight = true,
		--playLoseAggroHighlight = true,
		displaySelectionHighlight = true,
		colorHealthBySelection = true,
		considerSelectionInCombatAsHostile = true,
		displayNameByPlayerNameRules = true,
		colorHealthByRaidIcon = true,
		tankBorderColor = true,
		castBarHeight = 8,
		healthBarHeight = 4*2,
		filter = "HARMFUL|INCLUDE_NAME_PLATE_ONLY",
		displayName = true,
		--fadeOutOfRange = false,
		displayHealPrediction = true,
		colorNameBySelection = true,
		--smoothHealthUpdates = false,
		displayNameWhenSelected = true,
		greyOutWhenTapDenied = true,
		--showClassificationIndicator = true,
	},

	playerConfig = {
		displayHealPrediction = true,
		filter = "HELPFUL",
		useClassColors = true,
		hideCastbar = true,
		healthBarHeight = 4*2,
		manaBarHeight = 4*2,
	
		displaySelectionHighlight = false,
		displayAggroHighlight = false,
		displayName = false,
		fadeOutOfRange = false,
		colorNameBySelection = true,
		smoothHealthUpdates = false,
		displayNameWhenSelected = false,
	},
}

MOD.config = config
MOD.DriverFrame = DriverFrame
MOD.UnitFrameMixin = UnitFrameMixin

local BorderTex = path..'Border\\Plate.blp'
local BorderTexGlow = path..'Border\\PlateGlow.blp'
local MarkTex = path..'Border\\Mark.blp'
local HighlightTex = path..'Border\\Highlight.blp'


local TexCoord 		= {24/256, 186/256, 35/128, 59/128}
local CbTexCoord 	= {24/256, 186/256, 59/128, 35/128}

local GlowTexCoord 	= {15/256, 195/256, 21/128, 73/128}
local CbGlowTexCoord= {15/256, 195/256, 73/128, 21/128}

local HiTexCoord 	= {5/128, 105/128, 20/32, 26/32}

local raidIconColor = {
	[1] = {r = 1.0,  g = 0.92, b = 0,     },
	[2] = {r = 0.98, g = 0.57, b = 0,     },
	[3] = {r = 0.83, g = 0.22, b = 0.9,   },
	[4] = {r = 0.04, g = 0.95, b = 0,     },
	[5] = {r = 0.7,  g = 0.82, b = 0.875, },
	[6] = {r = 0,    g = 0.71, b = 1,     },
	[7] = {r = 1.0,  g = 0.24, b = 0.168, },
	[8] = {r = 0.98, g = 0.98, b = 0.98,  },
}

local Backdrop = {
	bgFile = 'Interface\\Buttons\\WHITE8x8',
}

local NPComboColor={
	[1]={0.69,0.31,0.31},
	[2]={0.69,0.31,0.31},
	[3]={0.65,0.63,0.35},
	[4]={0.65,0.63,0.35},
	[5]={0.33,0.59,0.33},
	[6]={0.22,0.79,0.22},
	[7]={0.11,0.99,0.11},
	[8]={0.11,0.99,0.11}
}


--------
-- Utils
--------

function MOD.GetPlateThreatReaction(plate)
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

function MOD.GetPlateReaction(plate)
	if plate.unit ~= nil then
		local class, classToken, _, _, _, _, _ = GetPlayerInfoByGUID(UnitGUID(plate.unit))
		if RAID_CLASS_COLORS[classToken] then
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
			return REACTION_COLORING[1](classToken)
		end
	end

	if(r + b < 0.25) then
		return REACTION_COLORING[3]()
	else
		local threatReaction = MOD.GetPlateThreatReaction(plate)
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

function MOD.Colorize(plate)

	local latestColor, scale = MOD.GetPlateReaction(plate);
	local r,g,b
	if(latestColor) then
		r,g,b = unpack(latestColor)
	else
		r,g,b = plate.healthBar:GetStatusBarColor()
	end
	plate.healthBar:SetStatusBarColor(r,g,b)
end

function MOD.IsPlayerEffectivelyTank()
	local assignedRole = UnitGroupRolesAssigned("player");
	if ( assignedRole == "NONE" ) then
		local spec = GetSpecialization();
		return spec and GetSpecializationRole(spec) == "TANK";
	end

	return assignedRole == "TANK";
end

local scanner = CreateFrame("GameTooltip", "SVUI_NameplatesScanner", nil, "GameTooltipTemplate")
local questtipLine = setmetatable({}, { __index = function(k, i)
	local line = _G["SVUI_NameplatesScannerTextLeft" .. i]
	if line then rawset(k, i, line) end
	return line
end })

function MOD.IsEliteUnit(namePlateUnitToken)
	local isElite = false
	if not UnitIsUnit('player', namePlateUnitToken) and not UnitIsFriend('player', namePlateUnitToken) then
		if 	(UnitClassification(namePlateUnitToken) == "worldboss" or UnitLevel(namePlateUnitToken) == -1 or
			UnitClassification(namePlateUnitToken) == "rare" or UnitClassification(namePlateUnitToken) =="rareelite" or 
			UnitClassification(namePlateUnitToken) == "elite") then
			isElite = true
		end
	end
	return isElite
end

function MOD.GetUnitQuestInfo(namePlateUnitToken)
	if not namePlateUnitToken or UnitIsPlayer(namePlateUnitToken) then
		return false
	end

	local is_quest
	local num_left = 0

	scanner:SetOwner(UIParent, "ANCHOR_NONE")
	scanner:SetUnit(namePlateUnitToken)

	for i = 3, scanner:NumLines() do
		local str = questtipLine[i]
		if (not str) then break; end
		local r,g,b = str:GetTextColor()
		if (r > .99) and (g > .82) and (g < .83) and (b < .01) then -- quest title (yellow)
			is_quest = true
		else
			local done, total = str:GetText():match('(%d+)/(%d+)')  -- kill objective
			if (done and total) then
				local left = total - done
				if (left > num_left) then
					num_left = left
				end
			end
		end
	end
	return is_quest, num_left
end

function MOD.CreatePlateBorder(plate)

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

		plate.eliteborder.right = plate.eliteborder:CreateTexture(nil, "BACKGROUND")
		plate.eliteborder.right:SetPoint("TOPLEFT", plate.eliteborder, "TOPRIGHT", 0, 0)
		plate.eliteborder.right:SetPoint("BOTTOMLEFT", plate.eliteborder, "BOTTOMRIGHT", 0, 0)
		plate.eliteborder.right:SetWidth(plate:GetHeight() * 4)
		plate.eliteborder.right:SetTexture(PLATE_RIGHT)
		plate.eliteborder.right:SetVertexColor(1, 1, 0)
		plate.eliteborder.right:SetBlendMode("BLEND")

		plate.eliteborder.left = plate.eliteborder:CreateTexture(nil, "BACKGROUND")
		plate.eliteborder.left:SetPoint("TOPRIGHT", plate.eliteborder, "TOPLEFT", 0, 0)
		plate.eliteborder.left:SetPoint("BOTTOMRIGHT", plate.eliteborder, "BOTTOMLEFT", 0, 0)
		plate.eliteborder.left:SetWidth(plate:GetHeight() * 4)
		plate.eliteborder.left:SetTexture(PLATE_LEFT)
		plate.eliteborder.left:SetVertexColor(1, 1, 0)
		plate.eliteborder.left:SetBlendMode("BLEND")

		plate.eliteborder:SetAlpha(0.35)

		plate.eliteborder:Hide()
	end

end


function MOD:ComboToggle()
	if(config.ComboPoints) then
		config.ComboPoints = false
		SetCVar("nameplateResourceOnTarget", 0)
	else
		config.ComboPoints = true
		SetCVar("nameplateResourceOnTarget", 1)
	end
	DriverFrame:UpdateComboPointsBar()
end

function MOD:CombatToggle()
	if(config.CombatHide) then
		config.CombatHide = false
		SetCVar("nameplateShowEnemies", 0)
	else
		config.CombatHide = true
		SetCVar("nameplateShowEnemies", 1)
	end
end

function MOD:UpdateAllPlates()
	self:UpdateLocals()
	DriverFrame:UpdateNamePlateOptions()
end

function MOD:UpdateLocals()
	local db = SV.db.NamePlates
	if not db then return end

	config.StatusbarTexture = LSM:Fetch("statusbar", db.barTexture);

	config.CombatHide = db.combatHide;
	config.ComboPoimts = db.comboPoints;

	config.SuperStyled = db.themed;

	config.friendlyConfig.healthBarHeight = db.healthBar.height;
	config.enemyConfig.healthBarHeight = db.healthBar.height;
	config.playerConfig.healthBarHeight = db.healthBar.height;


	config.friendlyConfig.castBarHeight = db.castBar.height;
	config.enemyConfig.castBarHeight = db.castBar.height;
	config.playerConfig.manaBarHeight = db.castBar.height;

end

function MOD:Load() 
	self:UpdateLocals();
	DriverFrame:SetScript('OnEvent', DriverFrame.OnEvent)
	DriverFrame:RegisterEvent'PLAYER_ENTERING_WORLD'
end
-------
--  DriverFrame
------

function DriverFrame:OnEvent(event, ...)

	if event == 'PLAYER_ENTERING_WORLD' then
		self:OnLoad();
	elseif (event == 'NAME_PLATE_CREATED') then
		local namePlateFrameBase = ...
		self:OnNamePlateCreated(namePlateFrameBase)
	elseif (event == 'NAME_PLATE_UNIT_ADDED') then
		local namePlateUnitToken = ...
		self:OnNamePlateAdded(namePlateUnitToken)
	elseif (event == 'NAME_PLATE_UNIT_REMOVED') then
		local namePlateUnitToken = ...
		self:OnNamePlateRemoved(namePlateUnitToken)
	elseif event == 'PLAYER_TARGET_CHANGED' then
		self:OnTargetChanged();
	elseif event == 'DISPLAY_SIZE_CHANGED' then -- resolution change
		self:UpdateNamePlateOptions()
	elseif event == "CVAR_UPDATE" then
		local name = ...;
		if name == "SHOW_CLASS_COLOR_IN_V_KEY" or name == "SHOW_NAMEPLATE_LOSE_AGGRO_FLASH" then
			self:UpdateNamePlateOptions();
		end
	elseif event == 'UPDATE_MOUSEOVER_UNIT' then
		self:UpdateMouseOver()
	elseif event == 'UNIT_FACTION' then
		self:OnUnitFactionChanged(...)
	elseif event == 'RAID_TARGET_UPDATE' then
		self:OnRaidTargetUpdate()
	elseif event == 'QUEST_LOG_UPDATE' then
		self:OnQuestLogUpdate()
	end
end

function DriverFrame:DisableBlizzard()
	NamePlateDriverFrame:UnregisterAllEvents()
	NamePlateDriverFrame:Hide()

	NamePlateDriverFrame.UpdateNamePlateOptions = function()
		DriverFrame:UpdateNamePlateOptions()
	end
end

function DriverFrame:OnLoad()

	self:DisableBlizzard()

	self:RegisterEvent'NAME_PLATE_CREATED'
	self:RegisterEvent'NAME_PLATE_UNIT_ADDED'
	self:RegisterEvent'NAME_PLATE_UNIT_REMOVED'

	self:RegisterEvent'PLAYER_TARGET_CHANGED'

	self:RegisterEvent'DISPLAY_SIZE_CHANGED' -- Resolution change
	self:RegisterEvent'CVAR_UPDATE'

	self:RegisterEvent'UPDATE_MOUSEOVER_UNIT'
	self:RegisterEvent'UNIT_FACTION'

	self:RegisterEvent'RAID_TARGET_UPDATE'
	self:RegisterEvent'QUEST_LOG_UPDATE'
	self:UpdateNamePlateOptions();

end

function DriverFrame:UpdateNamePlateOptions()
	self.baseNamePlateWidth = 110;
	self.baseNamePlateHeight = 45;

	local namePlateVerticalScale = tonumber(GetCVar("NamePlateVerticalScale"));
	local horizontalScale = tonumber(GetCVar("NamePlateHorizontalScale"));
	C_NamePlate.SetNamePlateOtherSize(self.baseNamePlateWidth * horizontalScale, self.baseNamePlateHeight);
	C_NamePlate.SetNamePlateSelfSize(self.baseNamePlateWidth * horizontalScale, self.baseNamePlateHeight);


	for i, frame in ipairs(C_NamePlate.GetNamePlates()) do
		frame.UnitFrame:ApplyFrameOptions(frame.UnitFrame.unit);
		frame.UnitFrame:UpdateAllElements()
	end

	self:UpdateClassResourceBar()
	self:UpdateManaBar()
	self:UpdateComboPointsBar()
end

function DriverFrame:OnNamePlateCreated(nameplate)
	local f = CreateFrame('Button', nameplate:GetName()..'UnitFrame', nameplate)
	f:SetAllPoints(nameplate)
	f:Show()
	Mixin(f, UnitFrameMixin)
	f:Create(nameplate)
	f:EnableMouse(false)

	nameplate.UnitFrame = f
end

function DriverFrame:OnNamePlateAdded(namePlateUnitToken)
	local nameplate = C_NamePlate.GetNamePlateForUnit(namePlateUnitToken)
	nameplate.UnitFrame:ApplyFrameOptions(namePlateUnitToken)
	nameplate.UnitFrame:OnAdded(namePlateUnitToken)
	nameplate.UnitFrame:UpdateAllElements()

	self:UpdateClassResourceBar()
	self:UpdateManaBar()
	self:UpdateComboPointsBar()
end

function DriverFrame:OnNamePlateRemoved(namePlateUnitToken)
	local nameplate = C_NamePlate.GetNamePlateForUnit(namePlateUnitToken)
	nameplate.UnitFrame:OnAdded(nil)
end

function DriverFrame:OnTargetChanged()
	local nameplate = C_NamePlate.GetNamePlateForUnit'target'
	if nameplate then
		if nameplate.UnitFrame then nameplate.UnitFrame:OnUnitAuraUpdate() end
	end

	self:UpdateClassResourceBar()
	self:UpdateManaBar()
	self:UpdateComboPointsBar()
end

function DriverFrame:OnRaidTargetUpdate()
	for _, frame in pairs(C_NamePlate.GetNamePlates()) do
		frame.UnitFrame:UpdateRaidTarget()
		CompactUnitFrame_UpdateHealthColor(frame.UnitFrame)
	end
end

function DriverFrame:OnUnitFactionChanged(unit)
	local nameplate = C_NamePlate.GetNamePlateForUnit(unit);
	if (nameplate) then
		CompactUnitFrame_UpdateName(nameplate.UnitFrame);
		CompactUnitFrame_UpdateHealthColor(nameplate.UnitFrame);
	end
end

function DriverFrame:OnQuestLogUpdate()
	for _, frame in pairs(C_NamePlate.GetNamePlates()) do
		frame.UnitFrame:UpdateQuestVisuals()
	end
end

local mouseoverframe -- if theres a better way im all ears
function DriverFrame:OnUpdate(elapsed) 
	local nameplate = C_NamePlate.GetNamePlateForUnit('mouseover')
	if not nameplate or nameplate ~= mouseoverframe then
		mouseoverframe.UnitFrame.hoverHighlight:Hide()
		mouseoverframe = nil
		self:SetScript('OnUpdate', nil)
	end
end

function DriverFrame:UpdateMouseOver()
	local nameplate = C_NamePlate.GetNamePlateForUnit('mouseover')

	if mouseoverframe == nameplate then
		return
	elseif mouseoverframe then
		mouseoverframe.UnitFrame.hoverHighlight:Hide()
		self:SetScript('OnUpdate', nil)
	end

	if nameplate then
		nameplate.UnitFrame.hoverHighlight:Show()
		mouseoverframe = nameplate
		self:SetScript('OnUpdate', self.OnUpdate) --onupdate until mouse leaves frame
	end
end

-------------------------
--	Class Resource bar
-------------------------

function DriverFrame:UpdateClassResourceBar()
	local classResourceBar = NamePlateDriverFrame.nameplateBar;
	if ( not classResourceBar ) then 
		return;
	end
	classResourceBar:Hide();

	local showSelf = GetCVar("nameplateShowSelf");
	if ( showSelf == "0" ) then
		return;
	end

	local targetMode = GetCVarBool("nameplateResourceOnTarget");
	if (classResourceBar.overrideTargetMode ~= nil) then
		targetMode = classResourceBar.overrideTargetMode;
	end

	if ( targetMode ) then
		local namePlateTarget = C_NamePlate.GetNamePlateForUnit("target");
		if ( namePlateTarget ) then
			classResourceBar:SetParent(NamePlateTargetResourceFrame);
			NamePlateTargetResourceFrame:SetParent(namePlateTarget.UnitFrame);
			NamePlateTargetResourceFrame:ClearAllPoints();
			NamePlateTargetResourceFrame:SetPoint("BOTTOM", namePlateTarget.UnitFrame.name, "TOP", 0, 9);
			classResourceBar:Show();
		end
		NamePlateTargetResourceFrame:SetShown(namePlateTarget ~= nil);
	elseif ( not targetMode ) then
		local namePlatePlayer = C_NamePlate.GetNamePlateForUnit("player");
		if ( namePlatePlayer ) then
			classResourceBar:SetParent(NamePlatePlayerResourceFrame);
			NamePlatePlayerResourceFrame:SetParent(namePlatePlayer.UnitFrame);
			NamePlatePlayerResourceFrame:ClearAllPoints();
			--NamePlatePlayerResourceFrame:SetPoint("TOP",ClassNameplateManaBarFrame, "BOTTOM", 0, -3);
			classResourceBar:Show();
		end
		NamePlatePlayerResourceFrame:SetShown(namePlatePlayer ~= nil);
	end
end

-------------------------
--	Class Mana Bar
-------------------------

local manabar = ClassNameplateManaBarFrame
manabar:SetStatusBarTexture(config.StatusbarTexture, 'BACKGROUND', 1)
manabar:SetBackdrop(Backdrop)
manabar:SetBackdropColor(0, 0, 0, .8)
manabar.Border:Hide()

manabar.FeedbackFrame.BarTexture:SetTexture(config.StatusbarTexture)

manabar.border = manabar:CreateTexture(nil, 'ARTWORK', nil, 2)
-- manabar.border:SetTexture(BorderTex)
-- manabar.border:SetTexCoord(unpack(TexCoord))
MOD.CreatePlateBorder(manabar)
manabar.border:SetPoint('TOPLEFT', manabar, -4, 6)
manabar.border:SetPoint('BOTTOMRIGHT', manabar, 4, -6)
manabar.border:SetVertexColor(unpack(config.Colors.Frame))
manabar:SetFrameLevel(90)

function ClassNameplateManaBarFrame:OnOptionsUpdated()
	local width, height = C_NamePlate.GetNamePlateSelfSize();
	self:SetHeight(config.playerConfig.manaBarHeight);
	self:SetStatusBarTexture(config.StatusbarTexture, 'BACKGROUND', 1)
end


-------------------------
--	Class ComboPoints Bar
-------------------------
local comboBar = nil

local _, myclass = UnitClass("player")
if (myclass == "ROGUE" or myclass=="DRUID") then
	comboBar=ClassNameplateBarRogueDruidFrame
	comboBar:SetSize(68, 1)
	comboBar:SetFrameStrata("HIGH")
	comboBar:SetFrameLevel(50) -- Make sure it's always on top, even over castBar...

	for i = 1, #comboBar.ComboPoints do
		comboBar.ComboPoints[i].Background:SetTexture(nil)
		comboBar.ComboPoints[i].Point:SetTexture(MOD.media.comboIcon)
		comboBar.ComboPoints[i].Point:SetSize(12, 12)
		comboBar.ComboPoints[i].Point:SetVertexColor(unpack(NPComboColor[i]))
		comboBar.ComboPoints[i]:SetFrameLevel(49)
	end
end

function DriverFrame:UpdateComboPointsBar()
	if ( not comboBar ) then 
		return;
	end

	local targetMode = GetCVarBool("nameplateResourceOnTarget");

	local showSelf = GetCVar("nameplateShowSelf");
	if (not targetMode and showSelf == "0") then
		return;
	end
	local h = nil
	if ( targetMode ) then
		local namePlateTarget = C_NamePlate.GetNamePlateForUnit("target");
		if ( namePlateTarget ) then
			h = namePlateTarget.UnitFrame.healthBar;
		end
	elseif ( not targetMode ) then
		local namePlatePlayer = C_NamePlate.GetNamePlateForUnit("player");
		if ( namePlatePlayer ) then
			h = namePlatePlayer.UnitFrame.healthBar;
		end
	end
	if (h) then
		comboBar:ClearAllPoints()
		comboBar:SetPoint("CENTER", h, "CENTER",0,0)
		comboBar:SetSize(68, 1)
		comboBar:SetFrameStrata("HIGH")
		comboBar:SetFrameLevel(50)
	end
end

function DriverFrame:UpdateManaBar()
	manabar:Hide()

	local showSelf = GetCVar("nameplateShowSelf");
	if ( showSelf == "0" ) then
		return;
	end

	local namePlatePlayer = C_NamePlate.GetNamePlateForUnit("player");
	if ( namePlatePlayer ) then
		manabar:SetParent(namePlatePlayer);
		manabar:ClearAllPoints();
		manabar:SetPoint("TOPLEFT", namePlatePlayer.UnitFrame.healthBar, "BOTTOMLEFT", 0, -6);
		manabar:SetPoint("TOPRIGHT", namePlatePlayer.UnitFrame.healthBar, "BOTTOMRIGHT", 0, -6);
		manabar:Show();
	end
end

------------------------
--	Nameplate
------------------------

function UnitFrameMixin:Create(unitframe)
	-- Healthbar
	local h = CreateFrame('Statusbar', '$parentHealthBar', unitframe)
	self.healthBar = h
	h:SetFrameLevel(90)
    h:SetStatusBarTexture(config.StatusbarTexture, 'BACKGROUND', 1)
	h:SetBackdrop(Backdrop)
	h:SetBackdropColor(0, 0, 0, .8)

	-- 	Healthbar textures --blizzard capital letters policy
	self.myHealPrediction = h:CreateTexture(nil, 'BORDER', nil, 5)
	self.myHealPrediction:SetVertexColor(0.0, 0.659, 0.608)
	self.myHealPrediction:SetTexture[[Interface\TargetingFrame\UI-TargetingFrame-BarFill]]

	self.otherHealPrediction = h:CreateTexture(nil, 'ARTWORK', nil, 5)
	self.otherHealPrediction:SetVertexColor(0.0, 0.659, 0.608)
	self.otherHealPrediction:SetTexture[[Interface\TargetingFrame\UI-TargetingFrame-BarFill]]

	self.totalAbsorb = h:CreateTexture(nil, 'ARTWORK', nil, 5)
	self.totalAbsorb:SetTexture[[Interface\RaidFrame\Shield-Fill]]
	--
	self.totalAbsorbOverlay = h:CreateTexture(nil, 'BORDER', nil, 6)
	self.totalAbsorbOverlay:SetTexture([[Interface\RaidFrame\Shield-Overlay]], true, true);	--Tile both vertically and horizontally
	self.totalAbsorbOverlay:SetAllPoints(self.totalAbsorb);
	self.totalAbsorbOverlay.tileSize = 20;
	--
	self.myHealAbsorb = h:CreateTexture(nil, 'ARTWORK', nil, 1)
	self.myHealAbsorb:SetTexture([[Interface\RaidFrame\Absorb-Fill]], true, true)

	self.myHealAbsorbLeftShadow = h:CreateTexture(nil, 'ARTWORK', nil, 1)
	self.myHealAbsorbLeftShadow:SetTexture[[Interface\RaidFrame\Absorb-Edge]]

	self.myHealAbsorbRightShadow = h:CreateTexture(nil, 'ARTWORK', nil, 1)
	self.myHealAbsorbRightShadow:SetTexture[[Interface\RaidFrame\Absorb-Edge]]
	self.myHealAbsorbRightShadow:SetTexCoord(1, 0, 0, 1)
	--
	h.border = h:CreateTexture(nil, 'ARTWORK', nil, 2)
	
	MOD.CreatePlateBorder(h)

	h.border:SetVertexColor(unpack(config.Colors.Frame))

	self.level = h:CreateFontString(nil, 'OVERLAY',"SVUI_Font_NamePlate_Number")
	self.level:SetPoint("RIGHT", h, "RIGHT", 2, 0)
	self.level:SetJustifyH("RIGHT")
	
	--
	self.overAbsorbGlow = h:CreateTexture(nil, 'ARTWORK', nil, 3)
	self.overAbsorbGlow:SetTexture[[Interface\RaidFrame\Shield-Overshield]]
	self.overAbsorbGlow:SetBlendMode'ADD'
	self.overAbsorbGlow:SetPoint('BOTTOMLEFT', h, 'BOTTOMRIGHT', -4, -1)
	self.overAbsorbGlow:SetPoint('TOPLEFT', h, 'TOPRIGHT', -4, 1)
	self.overAbsorbGlow:SetWidth(8);

	self.overHealAbsorbGlow = h:CreateTexture(nil, 'ARTWORK', nil, 3)
	self.overHealAbsorbGlow:SetTexture[[Interface\RaidFrame\Absorb-Overabsorb]]
	self.overHealAbsorbGlow:SetBlendMode'ADD'
	self.overHealAbsorbGlow:SetPoint('BOTTOMRIGHT', h, 'BOTTOMLEFT', 2, -1)
	self.overHealAbsorbGlow:SetPoint('TOPRIGHT', h, 'TOPLEFT', 2, 1)
	self.overHealAbsorbGlow:SetWidth(8);

	-- Castbar
	local c = CreateFrame('StatusBar', '$parentCastBar', nameplate)
	do
		self.castBar = c
		c:SetFrameLevel(90)
		c:Hide()
		c:SetStatusBarTexture(config.StatusbarTexture, 'BACKGROUND', 1)
		c:SetBackdrop(Backdrop)
		c:SetBackdropColor(0, 0, 0, .5)

		--		Castbar textures
		c.border = c:CreateTexture(nil, 'ARTWORK', nil, 0)
		--c.border:SetTexCoord(unpack(CbTexCoord))
		-- c.border:SetTexture(BorderTex)
		-- c.border:SetPoint('TOPLEFT', c, -4, 6)
		-- c.border:SetPoint('BOTTOMRIGHT', c, 4, -6)
		MOD.CreatePlateBorder(c)
		c.border:SetVertexColor(unpack(config.Colors.Frame))

		c.BorderShield = c:CreateTexture(nil, 'ARTWORK', nil, 1)
		c.BorderShield:SetTexture(MarkTex)
		c.BorderShield:SetTexCoord(unpack(CbTexCoord))
		c.BorderShield:SetAllPoints(c.border)
		c.BorderShield:SetBlendMode'ADD'
		c.BorderShield:SetVertexColor(1, .9, 0, 0.7)
		CastingBarFrame_AddWidgetForFade(c, c.BorderShield)

		c.Text = c:CreateFontString(nil, 'OVERLAY', "SVUI_Font_NamePlate")
		c.Text:SetPoint('CENTER', c, 0, 0)
		c.Text:SetPoint('LEFT', c, 0, 0)
		c.Text:SetPoint('RIGHT', c, 0, 0)
		--c.Text:SetFont(config.Font, config.FontSize, 'THINOUTLINE')
		c.Text:SetShadowColor(0, 0, 0, 0)

		c.Icon = c:CreateTexture(nil, 'OVERLAY', nil, 1)
		c.Icon:SetTexCoord(.1, .9, .1, .9)
		c.Icon:SetPoint('BOTTOMRIGHT', c, 'BOTTOMLEFT', -7, 0)
		c.Icon:SetPoint('TOPRIGHT', h, 'TOPLEFT', -7, 0)
		CastingBarFrame_AddWidgetForFade(c, c.Icon)

		c.IconBorder = c:CreateTexture(nil, 'OVERLAY', nil, 2)
		c.IconBorder:SetTexture(config.IconTextures.Normal)
		c.IconBorder:SetVertexColor(unpack(config.Colors.Border))
		c.IconBorder:SetPoint('TOPRIGHT', c.Icon, 2, 2)
		c.IconBorder:SetPoint('BOTTOMLEFT', c.Icon, -2, -2)
		CastingBarFrame_AddWidgetForFade(c, c.IconBorder)

		c.Spark = c:CreateTexture(nil, 'OVERLAY', nil, 2)
		c.Spark:SetTexture[[Interface\CastingBar\UI-CastingBar-Spark]]
		c.Spark:SetBlendMode'ADD'
		c.Spark:SetSize(16,16)
		c.Spark:SetPoint('CENTER', c, 0, 0)

		c.Flash = c:CreateTexture(nil, 'OVERLAY', nil, 2)
		c.Flash:SetTexture(config.StatusbarTexture)
		c.Flash:SetBlendMode'ADD'

		c:SetScript('OnEvent', CastingBarFrame_OnEvent)
		c:SetScript('OnUpdate',CastingBarFrame_OnUpdate)
		c:SetScript('OnShow', CastingBarFrame_OnShow)
		CastingBarFrame_OnLoad(c, nil, false, true);
		--CastingBarFrame_SetNonInterruptibleCastColor(c, 0.7, 0.7, 0.7)
	end

	self.raidTargetIcon = h:CreateTexture(nil, 'OVERLAY', nil)
	self.raidTargetIcon:SetSize(18,18)
	self.raidTargetIcon:SetPoint('LEFT', h, 'RIGHT', 4, 1)
	self.raidTargetIcon:SetTexture[[Interface\TargetingFrame\UI-RaidTargetingIcons]]

	self.name = h:CreateFontString(nil, 'ARTWORK', "SVUI_Font_NamePlate")
	self.name:SetPoint('BOTTOM', h, 'TOP', 0, 4)
	self.name:SetWordWrap(false)
	self.name:SetJustifyH'CENTER'
	--self.name:SetFont(config.Font, config.FontSize, 'THINOUTLINE')

	self.aggroHighlight = h:CreateTexture(nil, 'BORDER', nil, 4)
	self.aggroHighlight:SetTexture(BorderTexGlow)
	self.aggroHighlight:SetTexCoord(unpack(GlowTexCoord))
	self.aggroHighlight:SetPoint('TOPLEFT', h.border, -7, 15)
	self.aggroHighlight:SetPoint('BOTTOMRIGHT', h.border, 7, -15)
	self.aggroHighlight:SetAlpha(.7)
	self.aggroHighlight:Hide()

	self.hoverHighlight = h:CreateTexture(nil, 'ARTWORK', nil, 1)
	self.hoverHighlight:SetTexture(HighlightTex)
	self.hoverHighlight:SetAllPoints(h)
	self.hoverHighlight:SetVertexColor(1, 1, 1)
	self.hoverHighlight:SetBlendMode('ADD')
	self.hoverHighlight:SetTexCoord(unpack(HiTexCoord))
	self.hoverHighlight:Hide()

	self.selectionHighlight = h:CreateTexture(nil, 'ARTWORK', nil, 4)
	self.selectionHighlight:SetTexture(MarkTex)
	self.selectionHighlight:SetTexCoord(unpack(TexCoord))
	self.selectionHighlight:SetAllPoints(h.border)
	self.selectionHighlight:SetBlendMode('ADD')
	self.selectionHighlight:SetVertexColor(.8, .8, 1, .7)
	self.selectionHighlight:Hide()

	self.BuffFrame = CreateFrame('StatusBar', '$parentBuffFrame', self, 'HorizontalLayoutFrame')
	Mixin(self.BuffFrame, NameplateBuffContainerMixin)
	self.BuffFrame:SetPoint('LEFT', self.healthBar, -1, 0)
	self.BuffFrame.spacing = 4
	self.BuffFrame.fixedHeight = 14
	self.BuffFrame:SetScript('OnEvent', self.BuffFrame.OnEvent)
	self.BuffFrame:SetScript('OnUpdate', self.BuffFrame.OnUpdate)
	self.BuffFrame:OnLoad()

	-- Quest
	self.questIcon = self:CreateTexture(nil, nil, nil, 0)
	self.questIcon:SetSize(12, 12)

	self.questIcon:SetTexture(path..'QUEST-BG-ICON.blp')
	self.questIcon:SetPoint('LEFT', h, 'RIGHT', 2, 0)

	self.questText = self:CreateFontString(nil, nil, "SVUI_Font_NamePlate_Number")
	self.questText:SetPoint('CENTER', self.questIcon, 0, 0)
	self.questText:SetShadowOffset(1, -1)
	self.questText:SetTextColor(1,.82,0)



end

function UnitFrameMixin:ApplyFrameOptions(namePlateUnitToken)
	if UnitIsUnit('player', namePlateUnitToken) then
		self.optionTable = config.playerConfig
		self.healthBar:SetPoint('LEFT', self, 'LEFT', 12, 5);
		self.healthBar:SetPoint('RIGHT', self, 'RIGHT', -12, 5);
		self.healthBar:SetHeight(self.optionTable.healthBarHeight);
		self.healthBar.eliteborder:Hide() 
	else

		if UnitIsFriend('player', namePlateUnitToken) then
			self.optionTable = config.friendlyConfig
		else
			self.optionTable = config.enemyConfig
		end

		self.castBar:SetPoint('BOTTOMLEFT', self, 'BOTTOMLEFT', 12, 6);
		self.castBar:SetPoint('BOTTOMRIGHT', self, 'BOTTOMRIGHT', -12, 6);
		self.castBar:SetHeight(self.optionTable.castBarHeight);
		self.castBar.Icon:SetWidth(self.optionTable.castBarHeight + self.optionTable.healthBarHeight + 6)
	
		self.healthBar:SetPoint('BOTTOMLEFT', self.castBar, 'TOPLEFT', 0, 6);
		self.healthBar:SetPoint('BOTTOMRIGHT', self.castBar, 'TOPRIGHT', 0, 6);
		self.healthBar:SetHeight(self.optionTable.healthBarHeight);
	end
end

function UnitFrameMixin:OnAdded(namePlateUnitToken)
	self.unit = namePlateUnitToken
	self.displayedUnit = namePlateUnitToken
	self.inVehicle = false;
	
	if namePlateUnitToken then 
		self:RegisterEvents()
	else
		self:UnregisterEvents()
	end

	if self.castBar then
		if namePlateUnitToken and (not self.optionTable.hideCastbar) then
			CastingBarFrame_SetUnit(self.castBar, namePlateUnitToken, false, true);
		else
			CastingBarFrame_SetUnit(self.castBar, nil, nil, nil);
		end
	end
end

function UnitFrameMixin:RegisterEvents()
	self:RegisterEvent'UNIT_NAME_UPDATE'
	self:RegisterEvent'PLAYER_TARGET_CHANGED'

	self:RegisterEvent'UNIT_ENTERED_VEHICLE'
	self:RegisterEvent'UNIT_EXITED_VEHICLE'
	self:RegisterEvent'UNIT_PET'

	self:UpdateUnitEvents();
	self:SetScript('OnEvent', self.OnEvent);
end

function UnitFrameMixin:UpdateUnitEvents()
	local unit = self.unit;
	local displayedUnit;
	if ( unit ~= self.displayedUnit ) then
		displayedUnit = self.displayedUnit;
	end
	self:RegisterUnitEvent('UNIT_MAXHEALTH', unit, displayedUnit);
	self:RegisterUnitEvent('UNIT_HEALTH', unit, displayedUnit);
	self:RegisterUnitEvent('UNIT_HEALTH_FREQUENT', unit, displayedUnit);

	self:RegisterUnitEvent('UNIT_AURA', unit, displayedUnit);
	self:RegisterUnitEvent('UNIT_THREAT_SITUATION_UPDATE', unit, displayedUnit);
	self:RegisterUnitEvent('UNIT_THREAT_LIST_UPDATE', unit, displayedUnit);
	self:RegisterUnitEvent('UNIT_HEAL_PREDICTION', unit, displayedUnit);

	self:RegisterUnitEvent('UNIT_ABSORB_AMOUNT_CHANGED', unit.displayedUnit);
	self:RegisterUnitEvent('UNIT_HEAL_ABSORB_AMOUNT_CHANGED', unit.displayedUnit);
end

function UnitFrameMixin:UnregisterEvents()
	self:SetScript('OnEvent', nil)
end


function UnitFrameMixin:UpdateAllElements()
	self:UpdateInVehicle()

	if UnitExists(self.displayedUnit) then
		CompactUnitFrame_UpdateSelectionHighlight(self)
		CompactUnitFrame_UpdateMaxHealth(self) 
		CompactUnitFrame_UpdateHealth(self)
		CompactUnitFrame_UpdateHealPrediction(self)

		self:UpdateRaidTarget()
		CompactUnitFrame_UpdateHealthColor(self)
		CompactUnitFrame_UpdateName(self);
		self:UpdateThreat()
		self:OnUnitAuraUpdate()
		self:UpdateQuestVisuals()
		self:UpdateStatusBar()
	end
end

function UnitFrameMixin:OnEvent(event, ...)
	local arg1, arg2, arg3, arg4 = ...
	if ( event == 'PLAYER_TARGET_CHANGED' ) then
		CompactUnitFrame_UpdateSelectionHighlight(self);
		CompactUnitFrame_UpdateName(self);

	elseif ( arg1 == self.unit or arg1 == self.displayedUnit ) then
		if ( event == 'UNIT_MAXHEALTH' ) then
			CompactUnitFrame_UpdateMaxHealth(self)
			CompactUnitFrame_UpdateHealth(self)
			CompactUnitFrame_UpdateHealPrediction(self)
		elseif ( event == 'UNIT_HEALTH' or event == 'UNIT_HEALTH_FREQUENT' ) then
			CompactUnitFrame_UpdateHealth(self)
			CompactUnitFrame_UpdateHealPrediction(self)
		elseif ( event == 'UNIT_NAME_UPDATE' ) then
			CompactUnitFrame_UpdateName(self)
			CompactUnitFrame_UpdateHealthColor(self)
		elseif ( event == 'UNIT_AURA' ) then
			self:OnUnitAuraUpdate()
		elseif ( event == 'UNIT_THREAT_SITUATION_UPDATE' ) then
			self:UpdateThreat()
			--CompactUnitFrame_UpdateHealthBorder(self)
		elseif ( event == 'UNIT_THREAT_LIST_UPDATE' ) then
			if ( self.optionTable.considerSelectionInCombatAsHostile ) then
				CompactUnitFrame_UpdateHealthColor(self)
				CompactUnitFrame_UpdateName(self)
			end
			self:UpdateThreat()
		elseif ( event == 'UNIT_HEAL_PREDICTION' or event == 'UNIT_ABSORB_AMOUNT_CHANGED' or event == 'UNIT_HEAL_ABSORB_AMOUNT_CHANGED' ) then
			CompactUnitFrame_UpdateHealPrediction(self)
		elseif ( event == 'UNIT_ENTERED_VEHICLE' or event == 'UNIT_EXITED_VEHICLE' or event == 'UNIT_PET' ) then
			self:UpdateAllElements()
		end
	end
end

function UnitFrameMixin:UpdateInVehicle()
	if ( UnitHasVehicleUI(self.unit) ) then
		if ( not self.inVehicle ) then
			self.inVehicle = true
			local prefix, id, suffix = string.match(self.unit, '([^%d]+)([%d]*)(.*)')
			self.displayedUnit = prefix..'pet'..id..suffix
			self:UpdateUnitEvents()
		end
	else
		if ( self.inVehicle ) then
			self.inVehicle = false
			self.displayedUnit = self.unit
			self:UpdateUnitEvents()
		end
	end
end

function UnitFrameMixin:UpdateRaidTarget()
	local icon = self.raidTargetIcon;
	local index = GetRaidTargetIndex(self.unit)
	if ( index ) then
		SetRaidTargetIconTexture(icon, index);
		icon:Show();
		if self.optionTable.colorHealthByRaidIcon then
			self.optionTable.healthBarColorOverride = raidIconColor[index]
		end
	else
		self.optionTable.healthBarColorOverride = nil
		icon:Hide();
	end
end

function UnitFrameMixin:UpdateThreat()
	local tex = self.aggroHighlight
	if not self.optionTable.tankBorderColor then
		tex:Hide() 
		return
	end

	local isTanking, status = UnitDetailedThreatSituation('player', self.displayedUnit)
	if status ~= nil then
		if MOD.IsPlayerEffectivelyTank() then
			status = math.abs(status - 3)
		end
		if status > 0 then
			tex:SetVertexColor(GetThreatStatusColor(status))
			if not tex:IsShown() then 
				tex:Show()
			end
			return
		end
	end
	tex:Hide() 
end

function UnitFrameMixin:UpdateStatusBar()
	self.healthBar:SetStatusBarTexture(config.StatusbarTexture, 'BACKGROUND', 1)
	self.castBar:SetStatusBarTexture(config.StatusbarTexture, 'BACKGROUND', 1)
	if not UnitIsUnit(self.displayedUnit,'player') then 
		self.level:SetText(UnitLevel(self.displayedUnit))

		if config.SuperStyled and MOD.IsEliteUnit(self.displayedUnit) then 
			self.healthBar.eliteborder:Show() 
		else
			self.healthBar.eliteborder:Hide() 
		end
		MOD.Colorize(self)
	else
		self.level:SetText(nil)
		self.healthBar.eliteborder:Hide() 
	end
end

function UnitFrameMixin:UpdateQuestVisuals()
	local isQuest, numLeft = MOD.GetUnitQuestInfo(self.displayedUnit)
	if (isQuest) then
		if (numLeft > 0) then
			self.questText:SetText(numLeft)
		else
			self.questText:SetText('?')
		end
		self.questIcon:Show()
	else
		self.questText:SetText(nil)
		self.questIcon:Hide()
	end
end

function UnitFrameMixin:OnUnitAuraUpdate()
	self.BuffFrame:UpdateBuffs(self.displayedUnit, self.optionTable.filter)


end

