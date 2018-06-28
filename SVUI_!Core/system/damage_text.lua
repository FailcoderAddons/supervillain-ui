--[[
##########################################################
S V U I   By: Failcoder
##########################################################
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G 	= _G;
local type 	= type;
--[[
##########################################################
FORCIBLY CHANGE THE GAME WORLD COMBAT TEXT FONT
##########################################################
]]--
local FONT_NAME = "helsinki";

local MAIN_DIR = "Fonts\\%s.ttf";
local BASE_DIR = "Interface\\AddOns\\SVUI_!Core\\%s.ttf";
local FONT_DIR = "Interface\\AddOns\\SVUI_!Core\\assets\\fonts\\%s.ttf";

--local FONTSIZE = 32;
--local USER_FONT1 = BASE_DIR:format(FONT_NAME);
--local USER_FONT2 = MAIN_DIR:format(FONT_NAME);

local NEW_DAMAGE_FONT  = FONT_DIR:format(FONT_NAME);

local function ForceDamageFont()
	_G.DAMAGE_TEXT_FONT = NEW_DAMAGE_FONT
	_G.COMBAT_TEXT_CRIT_SCALE_TIME = 0.7;
	_G.COMBAT_TEXT_SPACING = 15;
end

ForceDamageFont();
