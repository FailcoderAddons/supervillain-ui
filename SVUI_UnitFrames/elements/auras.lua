--[[
##########################################################
S V U I   By: Failcoder
##########################################################
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--LUA
local unpack        = unpack;
local select        = select;
local pairs         = pairs;
local type          = type;
local rawset        = rawset;
local rawget        = rawget;
local tostring      = tostring;
local error         = error;
local next          = next;
local pcall         = pcall;
local getmetatable  = getmetatable;
local setmetatable  = setmetatable;
local assert        = assert;
--BLIZZARD
local _G            = _G;
local tinsert       = _G.tinsert;
local tremove       = _G.tremove;
local twipe         = _G.wipe;
--STRING
local string        = string;
local upper         = string.upper;
local format        = string.format;
local find          = string.find;
local match         = string.match;
local gsub          = string.gsub;
--MATH
local math          = math;
local floor         = math.floor
local ceil         	= math.ceil
--TABLE
local table         = table;
local tsort         = table.sort;
local tremove       = table.remove;

local CreateFrame           = _G.CreateFrame;
local InCombatLockdown      = _G.InCombatLockdown;
local GameTooltip           = _G.GameTooltip;
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

local DEFAULT_BUFFS_COLOR = {0.04, 0.52, 0.95};
local BUFFS_COLOR = DEFAULT_BUFFS_COLOR;
local DEFAULT_DEBUFFS_COLOR = {.9, 0, 0};
local DEBUFFS_COLOR = DEFAULT_DEBUFFS_COLOR;
local AURA_STATUSBAR = SV.media.statusbar.default;
local BASIC_TEXTURE = SV.media.statusbar.default;
local CanSteal = (SV.class == "MAGE");

local CreateFrame 		= _G.CreateFrame;
local UnitIsEnemy 		= _G.UnitIsEnemy;
local IsShiftKeyDown 	= _G.IsShiftKeyDown;
local DebuffTypeColor 	= _G.DebuffTypeColor;

local SVUI_Font_UnitAura 		= _G.SVUI_Font_UnitAura;
local SVUI_Font_UnitAura_Bar 	= _G.SVUI_Font_UnitAura_Bar;
--[[
##########################################################
LOCAL FUNCTIONS
##########################################################
]]--
local FilterAura_OnClick = function(self)
	if not IsShiftKeyDown() then return end
	local name = self.name;
	local spellID = self.spellID;
	local filterKey = tostring(spellID)
	if name and filterKey then
		SV:AddonMessage((L["The spell '%s' has been added to the BlackList unitframe aura filter."]):format(name))
		SV.db.Filters["BlackList"][filterKey] = {['enable'] = true, ['id'] = spellID}
		MOD:RefreshUnitFrames()
	end
end

local Aura_OnEnter = function(self)
	if(not self:IsVisible()) then return end
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
	GameTooltip:SetUnitAura(self.unit, self.index, self.filter)
end

local Aura_OnLeave = function()
	GameTooltip:Hide()
end

local _hook_AuraBGBorderColor = function(self, ...) self.bg:SetBackdropBorderColor(...) end

local CreateAuraIcon = function(icons, index)
	local baseSize = icons.auraSize or 16
	local aura = CreateFrame("Button", nil, icons)
	aura:RemoveTextures()
	aura:EnableMouse(true)
	aura:RegisterForClicks('RightButtonUp')

	aura:SetWidth(baseSize)
	aura:SetHeight(baseSize)

	aura:SetBackdrop({
    bgFile = [[Interface\BUTTONS\WHITE8X8]],
		tile = false,
		tileSize = 0,
		edgeFile = [[Interface\BUTTONS\WHITE8X8]],
      edgeSize = 1,
      insets = {
          left = 0,
          right = 0,
          top = 0,
          bottom = 0
      }
  });
  aura:SetBackdropColor(0, 0, 0, 0)
  aura:SetBackdropBorderColor(0, 0, 0)

  local bg = CreateFrame("Frame", nil, aura)
  bg:SetFrameStrata("BACKGROUND")
  bg:SetFrameLevel(0)
  bg:WrapPoints(aura, 2, 2)
  bg:SetBackdrop(SV.media.backdrop.aura)
  bg:SetBackdropColor(0, 0, 0, 0)
  bg:SetBackdropBorderColor(0, 0, 0, 0)
  aura.bg = bg;

  --hooksecurefunc(aura, "SetBackdropBorderColor", _hook_AuraBGBorderColor)

  local fontgroup = "SVUI_Font_UnitAura";
  if(baseSize < 18) then
  	fontgroup = "SVUI_Font_UnitAura_Small";
  end
  --print(baseSize)
  --print(fontgroup)

	local cd = CreateFrame("Cooldown", nil, aura, "CooldownFrameTemplate");
	cd:InsetPoints(aura, 1, 1);
	cd.noOCC = true;
	cd.noCooldownCount = true;
	cd:SetReverse(true);
	cd:SetHideCountdownNumbers(true);

	local fg = CreateFrame("Frame", nil, aura)
  fg:WrapPoints(aura, 2, 2)

	local text = fg:CreateFontString(nil, 'OVERLAY');
	text:SetFontObject(_G[fontgroup]);
	text:SetPoint('CENTER', aura, 'CENTER', 1, 1);
	text:SetJustifyH('CENTER');

	local count = fg:CreateFontString(nil, "OVERLAY");
	count:SetFontObject(_G[fontgroup]);
	count:SetPoint("CENTER", aura, "BOTTOMRIGHT", -3, 3);

	local icon = aura:CreateTexture(nil, "BACKGROUND");
	icon:SetAllPoints(aura);
	icon:InsetPoints(aura, 1, 1);
  icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS));

	local overlay = aura:CreateTexture(nil, "OVERLAY");
	overlay:InsetPoints(aura, 1, 1);
	overlay:SetTexture(BASIC_TEXTURE);
	overlay:SetVertexColor(0, 0, 0);
	overlay:Hide();

	-- local stealable = aura:CreateTexture(nil, 'OVERLAY')
	-- stealable:SetTexture("")
	-- stealable:SetPoint('TOPLEFT', -3, 3)
	-- stealable:SetPoint('BOTTOMRIGHT', 3, -3)
	-- aura.stealable = stealable

	aura:SetScript("OnClick", FilterAura_OnClick);
	aura:SetScript("OnEnter", Aura_OnEnter);
	aura:SetScript("OnLeave", Aura_OnLeave);

	aura.parent = icons;
	aura.cooldown = cd;
	aura.text = text;
	aura.icon = icon;
	aura.count = count;
	aura.overlay = overlay;

	return aura
end

local PostCreateAuraBars = function(self)
	local bar = self.statusBar
	local barTexture = LSM:Fetch("statusbar", SV.db.UnitFrames.auraBarStatusbar)
	bar:SetStatusBarTexture(barTexture)
	bar.spelltime:SetFontObject(SVUI_Font_UnitAura_Bar);
	bar.spelltime:SetTextColor(1 ,1, 1)
	bar.spelltime:SetShadowOffset(1, -1)
  	bar.spelltime:SetShadowColor(0, 0, 0)
	bar.spelltime:SetJustifyH'RIGHT'
	bar.spelltime:SetJustifyV'CENTER'
	bar.spelltime:SetPoint'RIGHT'

	bar.spellname:SetFontObject(SVUI_Font_UnitAura_Bar);
	bar.spellname:SetTextColor(1, 1, 1)
	bar.spellname:SetShadowOffset(1, -1)
  	bar.spellname:SetShadowColor(0, 0, 0)
	bar.spellname:SetJustifyH'LEFT'
	bar.spellname:SetJustifyV'CENTER'
	bar.spellname:SetPoint'LEFT'
	bar.spellname:SetPoint('RIGHT', bar.spelltime, 'LEFT')

	self:RegisterForClicks("RightButtonUp")
	self:SetScript("OnClick", FilterAura_OnClick)
end

local PostBarUpdate = function(self, bar, spellID, isDebuff, debuffType)
	if((not bar) or (not bar:IsVisible())) then return end

	local color;
	if(SV.db.UnitFrames.auraBarByType) then
		local filterKey = tostring(spellID)
		if(SV.db.Filters.AuraBars[filterKey]) then
			color = SV.db.Filters.AuraBars[filterKey]
		elseif isDebuff then
			if(debuffType and DebuffTypeColor[debuffType]) then
				color = {DebuffTypeColor[debuffType].r, DebuffTypeColor[debuffType].g, DebuffTypeColor[debuffType].b}
			else
				color = DEBUFFS_COLOR;
			end
		else
			color = BUFFS_COLOR;
		end
	else
		color = BUFFS_COLOR;
	end

	bar:SetStatusBarTexture(AURA_STATUSBAR)

	bar:SetStatusBarColor(unpack(color))
end

--[[ AURA FILTERING ]]--

local CommonAuraFilter = function(self, isEnemy, isPlayer, auraName, spellID, debuffType, duration, shouldConsolidate)
	local db = SV.db.UnitFrames[self.___unitkey]
	if((not db) or (db and not db[self.___aurakey])) then
		return false;
	end

	local auraDB = db[self.___aurakey];
	local filterKey = tostring(spellID)

	if(auraDB.filterWhiteList and (not SV.db.Filters.WhiteList[filterKey])) then
		return false;
	elseif(SV.db.Filters.BlackList[filterKey] and SV.db.Filters.BlackList[filterKey].enable) then
		return false;
	else
		if(auraDB.filterPlayer and (not isPlayer)) then
			return false
		end

		if(auraDB.filterDispellable and (debuffType and not MOD.Dispellable[debuffType])) then
			return false
		end

		if(auraDB.filterRaid and shouldConsolidate) then
			return false
		end

		if(auraDB.filterInfinite and ((not duration) or (duration and duration == 0))) then
			return false
		end

		local active = auraDB.useFilter
		if(active and SV.db.Filters[active]) then
			local spellDB = SV.db.Filters[active];
			if(spellDB[filterKey] and spellDB[filterKey].enable) then
				return false
			end
		end
	end
  	return true
end

--[[ DETAILED AURA FILTERING ]]--

local function filter_test(setting, isEnemy)
	if((not setting) or (setting and type(setting) ~= "table")) then
		return false;
	end
	if((setting.enemy and isEnemy) or (setting.friendly and (not isEnemy))) then
	  return true;
	end
  	return false
end

local DetailedAuraFilter = function(self, isEnemy, isPlayer, auraName, spellID, debuffType, duration, shouldConsolidate)
	local db = SV.db.UnitFrames[self.___unitkey]
	local auraType = self.___aurakey
	if((not db) or (not auraType) or (db and (not db[auraType]))) then
		return false;
	end

	local auraDB = db[self.___aurakey];
	local filterKey = tostring(spellID)

	if(filter_test(auraDB.filterAll, isEnemy)) then
		return false
	elseif(filter_test(auraDB.filterWhiteList, isEnemy) and (not SV.db.Filters.WhiteList[filterKey])) then
		return false;
	elseif(SV.db.Filters.BlackList[filterKey] and SV.db.Filters.BlackList[filterKey].enable) then
		return false
	else
		if(filter_test(auraDB.filterPlayer, isEnemy) and (not isPlayer)) then
			return false
		end
		if(filter_test(auraDB.filterDispellable, isEnemy)) then
			if((CanSteal and (auraType == 'buffs' and isStealable)) or (debuffType and (not MOD.Dispellable[debuffType])) or (not debuffType)) then
				return false
			end
		end
		if(filter_test(auraDB.filterRaid, isEnemy) and shouldConsolidate) then
			return false
		end
		if(filter_test(auraDB.filterInfinite, isEnemy) and ((not duration) or (duration and duration == 0))) then
			return false
		end
		local active = auraDB.useFilter
		if(active and SV.db.Filters[active]) then
			local spellDB = SV.db.Filters[active];
			if(spellDB[filterKey] and spellDB[filterKey].enable) then
				return false
			end
		end
	end
  	return true
end
--[[
##########################################################
BUILD FUNCTION
##########################################################
]]--
local BoolFilters = {
	['player'] = true,
	['pet'] = true,
	['boss'] = true,
	['arena'] = true,
	['party'] = true,
	['raid'] = true,
	['raidpet'] = true,
};

function MOD:CreateAuraFrames(frame, unit, barsAvailable)
	local buffs = CreateFrame("Frame", frame:GetName().."Buffs", frame)
	buffs.___unitkey = unit;
	buffs.___aurakey = "buffs";
	buffs.CreateAuraIcon = CreateAuraIcon;
	if(BoolFilters[unit]) then
		buffs.CustomFilter = CommonAuraFilter;
	else
		buffs.CustomFilter = DetailedAuraFilter;
	end
	buffs:SetFrameLevel(10)
	frame.Buffs = buffs

	local debuffs = CreateFrame("Frame", frame:GetName().."Debuffs", frame)
	debuffs.___unitkey = unit;
	debuffs.___aurakey = "debuffs";
	debuffs.CreateAuraIcon = CreateAuraIcon;
	if(BoolFilters[unit]) then
		debuffs.CustomFilter = CommonAuraFilter;
	else
		debuffs.CustomFilter = DetailedAuraFilter;
	end
	debuffs:SetFrameLevel(10)
	frame.Debuffs = debuffs

	if(barsAvailable) then
		frame.AuraBarsAvailable = true;
		buffs.PostCreateBar = PostCreateAuraBars;
		buffs.PostBarUpdate = PostBarUpdate;
		debuffs.PostCreateBar = PostCreateAuraBars;
		debuffs.PostBarUpdate = PostBarUpdate;
	end
end
--[[
##########################################################
AURA WATCH
##########################################################
]]--
local PreForcedUpdate = function(self)
	local unit = self.___key;
	if not SV.db.UnitFrames[unit] then return end
	local db = SV.db.UnitFrames[unit].auraWatch;
	if not db then return end;
	if(unit == "pet" or unit == "raidpet") then
		self.watchFilter = SV.db.Filters.PetBuffWatch
	else
		self.watchFilter = SV.db.Filters.BuffWatch
	end
	self.watchEnabled = db.enable;
	self.watchSize = db.size;
end

function MOD:CreateAuraWatch(frame, unit)
	local watch = CreateFrame("Frame", nil, frame)
	watch:SetFrameLevel(frame:GetFrameLevel() + 25)
	watch:SetAllPoints(frame);
	watch.___key = unit;
	watch.watchEnabled = true;
	watch.presentAlpha = 1;
	watch.missingAlpha = 0;
	if(unit == "pet" or unit == "raidpet") then
		watch.watchFilter = SV.db.Filters.PetBuffWatch
	else
		watch.watchFilter = SV.db.Filters.BuffWatch
	end

	watch.PreForcedUpdate = PreForcedUpdate
	return watch
end
--[[
##########################################################
CUSTOM EVENT UPDATES
##########################################################
]]--
local function UpdateAuraMediaLocals()
	BUFFS_COLOR = oUF_SVUI.colors.buff_bars or DEFAULT_BUFFS_COLOR;
	DEBUFFS_COLOR = oUF_SVUI.colors.debuff_bars or DEFAULT_DEBUFFS_COLOR;
	AURA_STATUSBAR = LSM:Fetch("statusbar", SV.db.UnitFrames.auraBarStatusbar);
end
SV.Events:On("UNITFRAME_COLORS_UPDATED", UpdateAuraMediaLocals, true);
