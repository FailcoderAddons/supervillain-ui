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
	["fontSize"] = 12, 
	["farming"] = {
		["buttonsize"] = 35, 
		["buttonspacing"] = 3, 
		["onlyactive"] = false, 
		["droptools"] = true, 
		["toolbardirection"] = "HORIZONTAL", 
	}, 
	["fishing"] = {
		["autoequip"] = true, 
	}, 
	["cooking"] = {
		["autoequip"] = true, 
	},
}

SV:AssignMedia("font", "craftdialog", "SVUI Default Font", 12, "OUTLINE");
SV:AssignMedia("font", "craftnumber", "SVUI Caps Font", 12, "OUTLINE");
SV:AssignMedia("globalfont", "craftdialog", "SVUI_Font_Craft");
SV:AssignMedia("globalfont", "craftnumber", "SVUI_Font_CraftNumber");

function PLUGIN:LoadOptions()
	local craftFonts = {
		["craftdialog"] = {
			order = 1,
			name = "Craft-O-Matic Dialog",
			desc = "Font used for log window text."
		},
		["craftnumber"] = {
			order = 2,
			name = "Craft-O-Matic Numbers",
			desc = "Font used for log window numbers."
		},
	};
	
	SV:GenerateFontOptionGroup("Craft-O-Matic", 11, "Fonts used for the Craft-O-Matic log window.", craftFonts)

	SV.Options.args[Schema] = {
		type = "group", 
		name = Schema, 
		get = function(a)return SV.db[Schema][a[#a]]end, 
		set = function(a,b) PLUGIN:ChangeDBVar(b,a[#a]); end, 
		args = {
			fishing = {
			    order = 1, 
				type = "group", 
				name = L["Fishing Mode Settings"], 
				guiInline = true, 
				args = {
					autoequip = {
						type = "toggle", 
						order = 1, 
						name = L['AutoEquip'], 
						desc = L['Enable/Disable automatically equipping fishing gear.'], 
						get = function(key)return SV.db[Schema].fishing[key[#key]] end,
						set = function(key, value) PLUGIN:ChangeDBVar(value, key[#key], "fishing") end
					}
				}
			},
			cooking = {
			    order = 2, 
				type = "group", 
				name = L["Cooking Mode Settings"], 
				guiInline = true, 
				args = {
					autoequip = {
						type = "toggle", 
						order = 1, 
						name = L['AutoEquip'], 
						desc = L['Enable/Disable automatically equipping cooking gear.'], 
						get = function(key)return SV.db[Schema].cooking[key[#key]]end,
						set = function(key, value) PLUGIN:ChangeDBVar(value, key[#key], "cooking")end
					}
				}
			},
			farming = {
			    order = 3, 
				type = "group", 
				name = L["Farming Mode Settings"], 
				guiInline = true, 
				get = function(key)return SV.db[Schema].farming[key[#key]]end, 
				set = function(key, value) SV.db[Schema].farming[key[#key]] = value end, 
				args = {
					buttonsize = {
						type = 'range', 
						name = L['Button Size'], 
						desc = L['The size of the action buttons.'], 
						min = 15, 
						max = 60, 
						step = 1, 
						order = 1, 
						set = function(key, value)
							PLUGIN:ChangeDBVar(value, key[#key], "farming");
							PLUGIN:RefreshFarmingTools()
						end,
					},
					buttonspacing = {
						type = 'range', 
						name = L['Button Spacing'], 
						desc = L['The spacing between buttons.'], 
						min = 1, 
						max = 10, 
						step = 1, 
						order = 2, 
						set = function(key, value)
							PLUGIN:ChangeDBVar(value, key[#key], "farming");
							PLUGIN:RefreshFarmingTools()
						end,
					},
					onlyactive = {
						order = 3, 
						type = 'toggle', 
						name = L['Only active buttons'], 
						desc = L['Only show the buttons for the seeds, portals, tools you have in your bags.'], 
						set = function(key, value)
							PLUGIN:ChangeDBVar(value, key[#key], "farming");
							PLUGIN:RefreshFarmingTools()
						end,
					},
					droptools = {
						order = 4, 
						type = 'toggle', 
						name = L['Drop '], 
						desc = L['Automatically drop tools from your bags when leaving the farming area.'],
					},
					toolbardirection = {
						order = 5, 
						type = 'select', 
						name = L['Bar Direction'], 
						desc = L['The direction of the bar buttons (Horizontal or Vertical).'], 
						set = function(key, value) PLUGIN:ChangeDBVar(value, key[#key],"farming"); PLUGIN:RefreshFarmingTools() end,
						values = {
								['VERTICAL'] = L['Vertical'], ['HORIZONTAL'] = L['Horizontal']
						}
					}
				}
			}
		}
	}
end