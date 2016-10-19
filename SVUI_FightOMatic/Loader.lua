--[[
##########################################################
S V U I   By: S.Jackson
########################################################## 
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--GLOBAL NAMESPACE
local _G = _G;
--LUA
local unpack        = _G.unpack;
local select        = _G.select;
local assert        = _G.assert;

local SV = _G["SVUI"];
local L = SV.L;
local AddonName, AddonObj = ...;
local PLUGIN = SV:NewPlugin(AddonName, AddonObj, "SVUI_Public_FightOMatic");
local Schema = PLUGIN.Schema;

SV.defaults[Schema] = {
    ["annoyingEmotes"] = false, 
}

SV:AssignMedia("font", "fightdialog", "SVUI Default Font", 12, "OUTLINE");
SV:AssignMedia("font", "fightnumber", "SVUI Caps Font", 12, "OUTLINE");
SV:AssignMedia("globalfont", "fightdialog", "SVUI_Font_Fight");
SV:AssignMedia("globalfont", "fightnumber", "SVUI_Font_FightNumber");

function PLUGIN:LoadOptions()
    local fightFonts = {
      ["fightdialog"] = {
        order = 1,
        name = "Fight-O-Matic Dialog",
        desc = "Font used for log window text."
      },
      ["fightnumber"] = {
        order = 2,
        name = "Fight-O-Matic Numbers",
        desc = "Font used for log window numbers."
      },
    };
    
    SV:GenerateFontOptionGroup("Fight-O-Matic", 13, "Font used for Fight-O-Matic text.", fightFonts)

    SV.Options.args[Schema] = {
        type = "group", 
        name = Schema, 
        get = function(a)return SV.db[Schema][a[#a]]end, 
        set = function(a,b)PLUGIN:ChangeDBVar(b,a[#a]); end, 
        args = {
            annoyingEmotes = {
                order = 1,
                name = L["Annoying Emotes"],
                desc = L["Aggravate your opponents (and team-mates) with incessant emotes"],
                type = "toggle",
                get = function(key) return SV.db[Schema].annoyingEmotes end,
                set = function(key,value) PLUGIN:ChangeDBVar(value, key[#key]); end
            }
        }
    }
end