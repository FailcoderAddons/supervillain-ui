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
LOCAL VARS
##########################################################
]]--
local PlateRegistry, VisiblePlates = {}, {};
local _hook_NamePlateDriverMixin, PlateForge, PlateUpdate;
local CURRENT_TARGET_NAME;
local TARGET_CHECKS = 0;
local PLATE_TOP = MOD.media.topArt;
local PLATE_BOTTOM = MOD.media.bottomArt;
local PLATE_RIGHT = MOD.media.rightArt;
local PLATE_LEFT = MOD.media.leftArt;
local NPBarTex = [[Interface\BUTTONS\WHITE8X8]];
--[[
##########################################################
UTILITY FRAMES
##########################################################
]]--
local NPGrip = _G.SVUI_PlateParentFrame
local NPGlow = _G.SVUI_PlateGlowFrame
--[[
##########################################################
PLATE UPDATE HANDLERS
##########################################################
]]--
function _hook_NamePlateDriverMixin(self, event, ...)
	if event == "NAME_PLATE_CREATED" then
		local frame = ...;
		if(not PlateRegistry[frame]) then
			PlateForge(frame)
		else
			PlateUpdate(frame)
		end
	elseif event == "NAME_PLATE_UNIT_ADDED" then
		local namePlateUnitToken = ...;
		local frame = C_NamePlate.GetNamePlateForUnit(namePlateUnitToken);
		if(not PlateRegistry[frame]) then
			PlateForge(frame)
		else
			PlateUpdate(frame)
		end
	elseif event == "NAME_PLATE_UNIT_REMOVED" then
		local namePlateUnitToken = ...;
		local frame = C_NamePlate.GetNamePlateForUnit(namePlateUnitToken);
		PlateUpdate(frame)
	elseif event == "PLAYER_TARGET_CHANGED" then
		-- DO STUFF
	elseif event == "DISPLAY_SIZE_CHANGED" then
		-- DO STUFF
	elseif event == "RAID_TARGET_UPDATE" then
		-- DO STUFF
	elseif ( event == "UNIT_FACTION" ) then
		-- DO STUFF
	end
end

function PlateUpdate(source)
	local plate = source.UnitFrame;
	if(not plate) then return end;
	plate.healthBar:SetStatusBarTexture(NPBarTex)
	plate.castBar:SetStatusBarTexture(NPBarTex)
	plate.name:SetFontObject(SVUI_Font_NamePlate)
	plate.name:SetTextColor(1, 1, 1)
end

function PlateForge(source)
	local plate = source.UnitFrame;
	if(not plate) then return end;

	plate.healthBar:SetStyle("Frame", "Bar")
	plate.castBar:SetStyle("Frame", 'Bar')

	VisiblePlates[plate] = true
	PlateRegistry[source] = true;
	PlateUpdate(source)
end
--[[
##########################################################
EVENTS
##########################################################
]]--
function MOD:PLAYER_REGEN_DISABLED()
	SetCVar("nameplateShowEnemies", 1)
end

function MOD:PLAYER_REGEN_ENABLED()
	SetCVar("nameplateShowEnemies", 0)
end

function MOD:PLAYER_TARGET_CHANGED()
	-- NPGlow:Hide()
	-- if(NPGlow.FX:IsShown()) then
	-- 	NPGlow.FX:Hide()
	-- end
	if(UnitExists("target")) then
		CURRENT_TARGET_NAME = UnitName("target");
		TARGET_CHECKS = 1;
	else
		CURRENT_TARGET_NAME = nil;
		TARGET_CHECKS = 0;
	end
end
--[[
##########################################################
UPDATE AND BUILD
##########################################################
]]--
function MOD:UpdateLocals()
	local db = SV.db.NamePlates
	if not db then return end

	NPBarTex = LSM:Fetch("statusbar", db.barTexture);

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
	SV:FontManager(SystemFont_NamePlate, "platename")
	--SV.SpecialFX:Register("platepoint", [[Spells\Arrow_state_animated.m2]], -12, 12, 12, -50, 0.75, 0, 0.1)
	--SV.SpecialFX:SetFXFrame(NPGlow, "platepoint", true)
	-- NPGlow.FX:SetParent(SV.Screen)
	-- NPGlow.FX:SetFrameStrata("BACKGROUND")
	-- NPGlow.FX:SetFrameLevel(0)
	-- NPGlow.FX:Hide()
	self:UpdateLocals()
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PLAYER_TARGET_CHANGED")
	NamePlateDriverFrame:HookScript("OnEvent", _hook_NamePlateDriverMixin)

	if (ClassNameplateManaBarFrame) then
		ClassNameplateManaBarFrame:SetStyle("Frame", "Bar")
		ClassNameplateManaBarFrame:SetStatusBarTexture(SV.media.statusbar.glow)
	end

	self:CombatToggle(true)
end
