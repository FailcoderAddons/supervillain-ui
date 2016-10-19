--[[
##########################################################
S V U I   By: Failcoder
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
local L = SV.L
local MOD = SV:NewModule(...);
local Schema = MOD.Schema;
local LSM = _G.LibStub("LibSharedMedia-3.0");

MOD.media = {}
MOD.media.backgroundArt = [[Interface\DialogFrame\UI-DialogBox-Background-Dark]];
MOD.media.topArt = [[Interface\AddOns\SVUI_Tooltip\assets\TT-TOP]];
MOD.media.bottomArt = [[Interface\AddOns\SVUI_Tooltip\assets\TT-BOTTOM]];
MOD.media.rightArt = [[Interface\AddOns\SVUI_Tooltip\assets\TT-RIGHT]];
MOD.media.leftArt = [[Interface\AddOns\SVUI_Tooltip\assets\TT-LEFT]];

SV.defaults[Schema] = {
	["themed"] = true,
	["cursorAnchor"] = false,
	["targetInfo"] = true,
	["playerTitles"] = true,
	["playerGender"] = false,
	["guildRanks"] = true,
	["inspectInfo"] = false,
	["itemCount"] = true,
	["spellID"] = false,
	["progressInfo"] = true,
	["visibility"] = {
		["unitFrames"] = "NONE",
		["combat"] = false,
	},
	["healthBar"] = {
		["text"] = true,
		["height"] = 10,
		["font"] = "SVUI Default Font",
		["fontSize"] = 10,
	},
};

SV:AssignMedia("font", "tipdialog", "SVUI Default Font", 12, "OUTLINE");
SV:AssignMedia("font", "tipheader", "SVUI Default Font", 14, "OUTLINE");

function MOD:LoadOptions()
	local tipFonts = {
		["tipdialog"] = {
			order = 1,
			name = "Tooltip Dialog",
			desc = "Default font used in tooltips"
		},
	    ["tipheader"] = {
			order = 2,
			name = "Tooltip Headers",
			desc = "Font used in tooltips to display large names."
		},
	};

	SV:GenerateFontOptionGroup("Tooltip", 8, "Fonts used in tooltips.", tipFonts)

	SV.Options.args[Schema] = {
		type = "group",
		name = Schema,
		childGroups = "tab",
		get = function(a)return SV.db[Schema][a[#a]] end,
		set = function(a, b) MOD:ChangeDBVar(b,a[#a]); end,
		args = {
			commonGroup = {
				order = 1,
				type = "group",
				name = L["Tooltip Options"],
				guiInline = true,
				args = {
					intro = {
						order = 1,
						type = "description",
						name = L["TOOLTIP_DESC"]
					},
					common = {
						order = 3,
						type = "group",
						name = L["General"],
						guiInline = true,
						args = {
							cursorAnchor = {
								order = 1,
								type = "toggle",
								name = L["Cursor Anchor"],
								desc = L["Should tooltip be anchored to mouse cursor"]
							},
							targetInfo = {
								order = 2,
								type = "toggle",
								name = L["Target Info"],
								desc = L["When in a raid group display if anyone in your raid is targeting the current tooltip unit."]
							},
							playerTitles = {
								order = 3,
								type = "toggle",
								name = L["Player Titles"],
								desc = L["Display player titles."]
							},
							playerGender = {
								order = 4,
								type = "toggle",
								name = L["Player Gender"],
								desc = L["Display player gender."]
							},
							guildRanks = {
								order = 5,
								type = "toggle",
								name = L["Guild Ranks"],
								desc = L["Display guild ranks if a unit is guilded."]
							},
							inspectInfo = {
								order = 6,
								type = "toggle",
								name = L["Talent Spec"],
								desc = L["Display the players talent spec in the tooltip, this may not immediately update when mousing over a unit."]
							},
							spellID = {
								order = 7,
								type = "toggle",
								name = L["Spell/Item IDs"],
								desc = L["Display the spell or item ID when mousing over a spell or item tooltip."],
								get = function(a)return SV.db[Schema].spellID end,
								set = function(a, b) MOD:ChangeDBVar(b, "spellID") end,
							},
							itemCount = {
								order = 8,
								type = "toggle",
								name = L["Item Counts"],
								desc = L["Display the total owned of an item across all recently played characters."],
								get = function(a)return SV.db[Schema].itemCount end,
								set = function(a, b) MOD:ChangeDBVar(b, "itemCount") end,
							},
						}

					},
					visibility={
						order=100,
						type="group",
						guiInline = true,
						name=L["Visibility"],
						get=function(a)return SV.db[Schema].visibility[a[#a]]end,
						set=function(a,b)SV.db[Schema].visibility[a[#a]]=b end,
						args={
							combat={order=1,type='toggle',name=COMBAT,desc=L["Hide tooltip while in combat."]},
							unitFrames={order=2,type='select',name=L['Unitframes'],desc=L["Don't display the tooltip when mousing over a unitframe."],values={['ALL']=L['Always Hide'],['NONE']=L['Never Hide'],['SHIFT']=SHIFT_KEY,['ALT']=ALT_KEY,['CTRL']=CTRL_KEY}}
						}
					},
					healthBar={
						order=200,
						type="group",
						guiInline = true,
						name=L["Health Bar"],
						get=function(a)return SV.db[Schema].healthBar[a[#a]]end,
						set=function(a,b)SV.db[Schema].healthBar[a[#a]]=b end,
						args={
							height = {
								order = 1,
								name = L["Height"],
								type = "range",
								min = 1,
								max = 15,
								step = 1,
								width = "full",
								set = function(a,b)SV.db[Schema].healthBar.height = b;GameTooltipStatusBar:SetHeight(b)end
							},
						}
					}
				}
			}
		}
	}
end
