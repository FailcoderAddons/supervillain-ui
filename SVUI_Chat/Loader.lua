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
local name, obj = ...
local MOD = SV:NewModule(name, obj, "SVUI_Global_ChatCache", "SVUI_Private_ChatCache");
local Schema = MOD.Schema;

SV:AssignMedia("font", "chatdialog", "SVUI Default Font", 12, "OUTLINE");
SV:AssignMedia("font", "chattab", "SVUI Caps Font", 12, "OUTLINE");
SV:AssignMedia("globalfont", "chatdialog", "SVUI_Font_Chat");
SV:AssignMedia("globalfont", "chattab", "SVUI_Font_ChatTab");

MOD.media = {}
MOD.media.dockIcon = [[Interface\AddOns\SVUI_Chat\assets\DOCK-ICON-CHAT]];
MOD.media.scrollIcon = [[Interface\AddOns\SVUI_Chat\assets\CHAT-SCROLL]];
MOD.media.whisperIcon = [[Interface\AddOns\SVUI_Chat\assets\CHAT-WHISPER]];
 
SV.defaults[Schema] = {
	["docked"] = "BottomLeft",
	["tabHeight"] = 20,
	["tabWidth"] = 75,
	["tabStyled"] = true,
	["font"] = "SVUI Default Font",
	["fontOutline"] = "OUTLINE",
	["tabFont"] = "SVUI Tab Font",
	["tabFontSize"] = 11,
	["tabFontOutline"] = "OUTLINE",
	["url"] = true,
	["hyperlinkHover"] = true,
	["throttleInterval"] = 45,
	["fade"] = false,
	["sticky"] = true,
	["smileys"] = true,
	["shortChannels"] = true,
	["hideRealms"] = false,
	["mention"] = "Mention Alert",
	["mention_channel"] = "Master",
	["psst"] = "Whisper Alert",
	["psst_channel"] = "Master",
	["noWipe"] = false,
	["timeStampFormat"] = "NONE",
	["secretWords"] = "%MYNAME%, SVUI",
	["basicTools"] = true,
	["bubbles"] = true,
};

function MOD:LoadOptions()
	local chatFonts = {
		["chatdialog"] = {
			order = 1,
			name = "Chat",
			desc = "Font used for chat text."
		},
		["chattab"] = {
			order = 2,
			name = "Chat Tabs",
			desc = "Font used for chat tab labels."
		},
	};

	SV:GenerateFontOptionGroup("Chat", 5, "Fonts used for the chat frame.", chatFonts)

	SV.Options.args[Schema] = {
		type = "group",
		name = Schema,
		get = function(a)return SV.db[Schema][a[#a]]end,
		set = function(a,b)MOD:ChangeDBVar(b,a[#a]); end,
		args = {
			intro = {
				order = 1,
				type = "description",
				name = L["CHAT_DESC"],
				width = 'full'
			},
			common = {
				order = 2,
				type = "group",
				name = L["General"],
				guiInline = true,
				args = {
					sticky = {
						order = 1,
						type = "toggle",
						name = L["Sticky Chat"],
						desc = L["When opening the Chat Editbox to type a message having this option set means it will retain the last channel you spoke in. If this option is turned off opening the Chat Editbox should always default to the SAY channel."]
					},
					url = {
						order = 2,
						type = "toggle",
						name = L["URL Links"],
						desc = L["Attempt to create URL links inside the chat."],
						set = function(a,b) MOD:ChangeDBVar(b,a[#a]) end
					},
					hyperlinkHover = {
						order = 3,
						type = "toggle",
						name = L["Hyperlink Hover"],
						desc = L["Display the hyperlink tooltip while hovering over a hyperlink."],
						set = function(a,b) MOD:ChangeDBVar(b,a[#a]); MOD:ToggleHyperlinks(b); end
					},
					smileys = {
						order = 4,
						type = "toggle",
						name = L["Emotion Icons"],
						desc = L["Display emotion icons in chat."]
					},
					tabStyled = {
						order = 5,
						type = "toggle",
						name = L["Custom Tab Style"],
						set = function(a,b) MOD:ChangeDBVar(b,a[#a]);SV:StaticPopup_Show("RL_CLIENT") end,
					},
					shortChannels = {
						order = 6,
						type = "toggle",
						name = L["Abbreviation"],
						desc = "Shortened channel names",
					},
					hideRealms = {
						order = 7,
						type = "toggle",
						name = L['Player Realms'],
						desc = L['Show/hide the players realm next to their name.'],
					},
					bubbles = {
						order = 8,
						type = "toggle",
						name = L['Chat Bubbles'],
						desc = L['Style the blizzard chat bubbles.'],
						get = function(a)return SV.db[Schema][a[#a]] end,
						set = function(a,b) MOD:ChangeDBVar(b,a[#a]);SV:StaticPopup_Show("RL_CLIENT")end
					},
					spacer1 = {
						order = 9,
						type = "description",
						name = ""
					},
					timeStampFormat = {
						order = 10,
						type = "select",
						name = TIMESTAMPS_LABEL,
						desc = OPTION_TOOLTIP_TIMESTAMPS,
						values = {
							["NONE"] = NONE,
							["%I:%M "] = "03:27",
							["%I:%M:%S "] = "03:27:32",
							["%I:%M %p "] = "03:27 PM",
							["%I:%M:%S %p "] = "03:27:32 PM",
							["%H:%M "] = "15:27",
							["%H:%M:%S "] = "15:27:32"
						}
					},
					psst = {
						order = 11,
						type = "select",
						dialogControl = "LSM30_Sound",
						name = L["Whisper Alert"],
						disabled = function()return not SV.db[Schema].psst end,
						values = AceVillainWidgets.sound,
						set = function(a,b) MOD:ChangeDBVar(b,a[#a]) end
					},
					psst_channel = {
						order = 12,
						type = "select",
						name = L["Whisper Alert Sound Channel"],
						desc = L["Select the sound channel for Whisper Alerts"],
						disabled = function()return not SV.db[Schema].psst end,
						values = {
							["Master"] = "Master",
							["Dialog"] = "Dialog",
							["Sound"] = "SFX",
							["Ambience"] = "Ambience",
							["Music"] = "Music"
						},
						set = function(a,b) MOD:ChangeDBVar(b,a[#a]) end
					},
					mention = {
						order = 13,
						type = "select",
						dialogControl = "LSM30_Sound",
						name = L["Mention Alert"],
						disabled = function()return not SV.db[Schema].mention end,
						values = AceVillainWidgets.sound,
						set = function(a,b) MOD:ChangeDBVar(b,a[#a]) end
					},
					mention_channel = {
						order = 14,
						type = "select",
						name = L["Mention Alert Sound Channel"],
						desc = L["Select the sound channel for Mention Alerts"],
						disabled = function()return not SV.db[Schema].mention end,
						values = {
							["Master"] = "Master",
							["Dialog"] = "Dialog",
							["Sound"] = "SFX",
							["Ambience"] = "Ambience",
							["Music"] = "Music"
						},
						set = function(a,b) MOD:ChangeDBVar(b,a[#a]) end
					},
					spacer2 = {
						order = 15,
						type = "description",
						name = ""
					},
					throttleInterval = {
						order = 16,
						type = "range",
						name = L["Spam Interval"],
						desc = L["Prevent the same messages from displaying in chat more than once within this set amount of seconds, set to zero to disable."],
						min = 0,
						max = 120,
						step = 1,
						width = "full",
						set = function(a,b) MOD:ChangeDBVar(b,a[#a]) end
					},
				}
			},
		}
	}
end
