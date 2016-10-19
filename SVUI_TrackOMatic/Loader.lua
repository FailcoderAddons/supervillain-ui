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
local PLUGIN = SV:NewPlugin(...);
local Schema = PLUGIN.Schema;

SV.defaults[Schema] = {
    ["size"] = 75, 
    ["groups"] = true,
    ["proximity"] = false, 
}

SV:AssignMedia("font", "tracking", "SVUI Number Font", 12, "OUTLINE");
SV:AssignMedia("globalfont", "tracking", "SVUI_Font_Tracking");

function PLUGIN:LoadOptions()
    local trackFonts = {
        ["tracking"] = {
            order = 1,
            name = "Track-O-Matic Text",
            desc = "Font used for all tracking text."
        },
    };
    
    SV:GenerateFontOptionGroup("Track-O-Matic", 12, "Font used for tracking devices.", trackFonts)

    SV.Options.args[Schema] = {
        type = "group", 
        name = Schema, 
        get = function(a)return SV.db[Schema][a[#a]]end, 
        set = function(a,b)PLUGIN:ChangeDBVar(b,a[#a]); end, 
        args = {
            groups = {
                order = 1,
                name = L["GPS"],
                desc = L["Use group frame GPS elements"],
                type = "toggle",
                get = function(key) return SV.db[Schema].groups end,
                set = function(key,value) SV.db[Schema].groups = value; end
            },
            proximity = {
                order = 2,
                name = L["GPS Proximity"],
                desc = L["Only point to closest low health unit (if one is in range)."],
                type = "toggle",
                get = function(key) return SV.db[Schema].proximity end,
                set = function(key,value) SV.db[Schema].proximity = value; end
            }
        }
    }
end