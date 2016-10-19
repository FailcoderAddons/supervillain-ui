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

MOD.media = {}
MOD.media.dockIcon = [[Interface\AddOns\SVUI_QuestTracker\assets\DOCK-ICON-QUESTS]];
MOD.media.buttonArt = [[Interface\AddOns\SVUI_QuestTracker\assets\QUEST-BUTTON-ART]];
MOD.media.completeIcon = [[Interface\AddOns\SVUI_QuestTracker\assets\QUEST-COMPLETE-ICON]];
MOD.media.incompleteIcon = [[Interface\AddOns\SVUI_QuestTracker\assets\QUEST-INCOMPLETE-ICON]];

SV.defaults[Schema] = {
	["rowHeight"] = 0,
	["itemBarDirection"] = 'VERTICAL',
	["itemButtonSize"] = 28,
	["itemButtonsPerRow"] = 5,
};

SV:AssignMedia("font", "questdialog", "SVUI Default Font", 12, "OUTLINE");
SV:AssignMedia("font", "questheader", "SVUI Caps Font", 16, "OUTLINE");
SV:AssignMedia("font", "questnumber", "SVUI Number Font", 11, "OUTLINE");
SV:AssignMedia("globalfont", "questdialog", "SVUI_Font_Quest");
SV:AssignMedia("globalfont", "questheader", "SVUI_Font_Quest_Header");
SV:AssignMedia("globalfont", "questnumber", "SVUI_Font_Quest_Number");


function MOD:LoadOptions()
	local questFonts = {
		["questdialog"] = {
			order = 1,
			name = "Quest Tracker Dialog",
			desc = "Default font used in the quest tracker"
		},
		["questheader"] = {
			order = 2,
			name = "Quest Tracker Titles",
			desc = "Font used in the quest tracker for listing headers."
		},
		["questnumber"] = {
			order = 3,
			name = "Quest Tracker Numbers",
			desc = "Font used in the quest tracker to display numeric values."
		},
	};

	SV:GenerateFontOptionGroup("QuestTracker", 6, "Fonts used in the SVUI Quest Tracker.", questFonts)

	SV.Options.args[Schema] = {
		type = "group",
		name = Schema,
		args = {
			generalGroup = {
				order = 1,
				type = "group",
				name = "General",
				guiInline = true,
				args = {
					rowHeight = {
						order = 1,
						type = 'range',
						name = L["Row Height (minimum adjusted by font size)"],
						desc = L["Setting this to 0 (zero) will force an automatic size"],
						min = 0,
						max = 50,
						step = 1,
						width = "full",
						get = function(a)return SV.db[Schema][a[#a]] end,
						set = function(a,b) 
							local c = SV.media.shared.font.questdialog.size;
							local d = c + 4;
							if((b > 0) and (b < d)) then 
								b = d;
							end
							MOD:ChangeDBVar(b,a[#a]);
							MOD:UpdateSetup();
						end
					},
				}
			},
			itemsGroup = {
				order = 2,
				type = "group",
				name = "Quest Items",
				guiInline = true,
				get = function(a)return SV.db[Schema][a[#a]] end,
				set = function(a,b)
					MOD:ChangeDBVar(b,a[#a]);
					MOD:UpdateLocals();
				end,
				args = {
					itemBarDirection = {
						order = 1,
						type = 'select',
						name = L["Bar Direction"],
						values = {
							['VERTICAL'] = L['Vertical'],
							['HORIZONTAL'] = L['Horizontal']
						},
					},
					itemButtonSize = {
						order = 2,
						type = 'range',
						name = L["Button Size"],
						min = 10,
						max = 100,
						step = 1,
						width = "full",
					},
					itemButtonsPerRow = {
						order = 3,
						type = 'range',
						name = L["Buttons Per Row"],
						desc = L["This will only take effect if you have moved the item bar away from the dock."],
						min = 1,
						max = 20,
						step = 1,
						width = "full",
					},
				}
			}
		}
	}
end
