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
local L = SV.L;
local MOD = SV:NewModule(...);
local Schema = MOD.Schema;

MOD.media = {}
MOD.media.microMenuFile = [[Interface\AddOns\SVUI_ActionBars\assets\MICROMENU]];
MOD.media.microMenuCoords = {
  {"CharacterMicroButton",0,0.25,0,0.25},     -- MICRO-CHARACTER
  {"SpellbookMicroButton",0.25,0.5,0,0.25},   -- MICRO-SPELLBOOK
  {"TalentMicroButton",0.5,0.75,0,0.25},      -- MICRO-TALENTS
  {"AchievementMicroButton",0.75,1,0,0.25},   -- MICRO-ACHIEVEMENTS
  {"QuestLogMicroButton",0,0.25,0.25,0.5},    -- MICRO-QUESTS
  {"GuildMicroButton",0.25,0.5,0.25,0.5},     -- MICRO-GUILD
  {"PVPMicroButton",0.5,0.75,0.25,0.5},       -- MICRO-PVP
  {"LFDMicroButton",0.75,1,0.25,0.5},         -- MICRO-LFD
  {"EJMicroButton",0,0.25,0.5,0.75},          -- MICRO-ENCOUNTER
  {"StoreMicroButton",0.25,0.5,0.5,0.75},     -- MICRO-STORE
  {"CollectionsMicroButton",0.5,0.75,0.5,0.75},-- MICRO-COMPANION
  {"MainMenuMicroButton",0.75,1,0.5,0.75},    -- MICRO-SYSTEM
  {"HelpMicroButton",0,0.25,0.75,1},          -- MICRO-HELP
}

SV.defaults[Schema] = {
	["barCount"] = 6,
	["font"] = "SVUI Default Font", 
	["fontSize"] = 11,  
	["fontOutline"] = "OUTLINE",
	["countFont"] = "SVUI Number Font", 
	["countFontSize"] = 11,  
	["countFontOutline"] = "OUTLINE",
	["cooldownSize"] = 18, 
	["rightClickSelf"] = false, 
	["macrotext"] = false, 
	["hotkeytext"] = false, 
	["hotkeyAbbrev"] = true, 
	["showGrid"] = true, 
	["unc"] = {0.8, 0.1, 0.1, 0.7}, 
	["unpc"] = {0.5, 0.5, 1, 0.7}, 
	["keyDown"] = false, 
	["unlock"] = "SHIFT", 
	["Micro"] = {
		["enable"] = true, 
		["mouseover"] = true, 
		["alpha"] = 1, 
		["buttonsize"] = 30, 
		["buttonspacing"] = 4, 
		["yOffset"] = 4
	},
	["Totem"] = {
	    ["enable"] = true, 
	    ["showBy"] = "VERTICAL", 
	    ["sortDirection"] = "ASCENDING", 
	    ["buttonsize"] = 40, 
	    ["buttonspacing"] = 4
	},
	["Bar1"] = {
		["enable"] = true, 
		["buttons"] = 12, 
		["mouseover"] = false, 
		["buttonsPerRow"] = 12, 
		["point"] = "BOTTOMLEFT", 
		["backdrop"] = false, 
		["buttonsize"] = 32, 
		["buttonspacing"] = 2,
		["showVehicle"] = true, 
		["useCustomPaging"] = true, 
		["useCustomVisibility"] = false, 
		["customVisibility"] = "[petbattle] hide; show", 
		["customPaging"] = {
		    ["HUNTER"]  	 = "", 
		    ["WARLOCK"] 	 = "[form:2] 10;", 
		    ["PRIEST"]  	 = "[bonusbar:1] 7;", 
		    ["PALADIN"] 	 = "", 
		    ["MAGE"]    	 = "", 
		    ["ROGUE"]   	 = "[stance:1] 7; [stance:2] 7; [stance:3] 7; [bonusbar:1] 7; [form:3] 7;", 
		    ["DRUID"]   	 = "[bonusbar:1, nostealth] 7; [bonusbar:1, stealth] 8; [bonusbar:2] 8; [bonusbar:3] 9; [bonusbar:4] 10;", 
		    ["SHAMAN"]  	 = "", 
		    ["WARRIOR"] 	 = "[bonusbar:1] 7; [bonusbar:2] 8;", 
		    ["DEATHKNIGHT"]  = "", 
		    ["MONK"]    	 = "[bonusbar:1] 7; [bonusbar:2] 8; [bonusbar:3] 9;",
		    ["DEMONHUNTER"]  = "",
		}, 
		["alpha"] = 1
	}, 
	["Bar2"] = {
		["enable"] = false, 
		["mouseover"] = false, 
		["buttons"] = 12, 
		["buttonsPerRow"] = 12, 
		["point"] = "BOTTOMLEFT", 
		["backdrop"] = false, 
		["buttonsize"] = 32, 
		["buttonspacing"] = 2,
		["showVehicle"] = false, 
		["useCustomPaging"] = false, 
		["useCustomVisibility"] = false, 
		["customVisibility"] = "[petbattle] hide; show", 
		["customPaging"] = {
		    ["HUNTER"]  	 = "", 
		    ["WARLOCK"] 	 = "", 
		    ["PRIEST"]  	 = "", 
		    ["PALADIN"] 	 = "", 
		    ["MAGE"]    	 = "", 
		    ["ROGUE"]   	 = "", 
		    ["DRUID"]   	 = "", 
		    ["SHAMAN"]  	 = "", 
		    ["WARRIOR"] 	 = "", 
		    ["DEATHKNIGHT"]  = "", 
		    ["MONK"]    	 = "", 
		    ["DEMONHUNTER"]  = "",
		}, 
		["alpha"] = 1
	}, 
	["Bar3"] = {
		["enable"] = true, 
		["mouseover"] = false, 
		["buttons"] = 6, 
		["buttonsPerRow"] = 6, 
		["point"] = "BOTTOMLEFT", 
		["backdrop"] = false, 
		["buttonsize"] = 32, 
		["buttonspacing"] = 2, 
		["showVehicle"] = false,
		["useCustomPaging"] = false, 
		["useCustomVisibility"] = false, 
		["customVisibility"] = "[petbattle] hide; show", 
		["customPaging"] = {
		    ["HUNTER"]  	 = "", 
		    ["WARLOCK"] 	 = "", 
		    ["PRIEST"]  	 = "", 
		    ["PALADIN"] 	 = "", 
		    ["MAGE"]    	 = "", 
		    ["ROGUE"]   	 = "", 
		    ["DRUID"]   	 = "", 
		    ["SHAMAN"]  	 = "", 
		    ["WARRIOR"] 	 = "", 
		    ["DEATHKNIGHT"]  = "", 
		    ["MONK"]    	 = "", 
		    ["DEMONHUNTER"]  = "",
		}, 
		["alpha"] = 1
	}, 
	["Bar4"] = {
		["enable"] = true, 
		["mouseover"] = true, 
		["buttons"] = 12, 
		["buttonsPerRow"] = 1, 
		["point"] = "TOPRIGHT", 
		["backdrop"] = false, 
		["buttonsize"] = 32, 
		["buttonspacing"] = 2, 
		["showVehicle"] = false,
		["useCustomPaging"] = false, 
		["useCustomVisibility"] = false, 
		["customVisibility"] = "[petbattle] hide; show", 
		["customPaging"] = {
		    ["HUNTER"]  	 = "", 
		    ["WARLOCK"] 	 = "", 
		    ["PRIEST"]  	 = "", 
		    ["PALADIN"] 	 = "", 
		    ["MAGE"]    	 = "", 
		    ["ROGUE"]   	 = "", 
		    ["DRUID"]   	 = "", 
		    ["SHAMAN"]  	 = "", 
		    ["WARRIOR"] 	 = "", 
		    ["DEATHKNIGHT"]  = "", 
		    ["MONK"]    	 = "", 
		    ["DEMONHUNTER"]  = "",
		}, 
		["alpha"] = 1
	}, 
	["Bar5"] = {
		["enable"] = true, 
		["mouseover"] = false, 
		["buttons"] = 6, 
		["buttonsPerRow"] = 6, 
		["point"] = "BOTTOMLEFT", 
		["backdrop"] = false, 
		["buttonsize"] = 32, 
		["buttonspacing"] = 2, 
		["showVehicle"] = false,
		["useCustomPaging"] = false, 
		["useCustomVisibility"] = false, 
		["customVisibility"] = "[petbattle] hide; show", 
		["customPaging"] = {
		    ["HUNTER"]  	 = "", 
		    ["WARLOCK"] 	 = "", 
		    ["PRIEST"]  	 = "", 
		    ["PALADIN"] 	 = "", 
		    ["MAGE"]    	 = "", 
		    ["ROGUE"]   	 = "", 
		    ["DRUID"]   	 = "", 
		    ["SHAMAN"]  	 = "", 
		    ["WARRIOR"] 	 = "", 
		    ["DEATHKNIGHT"]  = "", 
		    ["MONK"]    	 = "", 
		    ["DEMONHUNTER"]  = "",
		}, 
		["alpha"] = 1
	}, 
	["Bar6"] = {
		["enable"] = false, 
		["mouseover"] = false, 
		["buttons"] = 12, 
		["buttonsPerRow"] = 12, 
		["point"] = "BOTTOMLEFT", 
		["backdrop"] = false, 
		["buttonsize"] = 32, 
		["buttonspacing"] = 2, 
		["showVehicle"] = false,
		["useCustomPaging"] = false, 
		["useCustomVisibility"] = false, 
		["customVisibility"] = "[petbattle] hide; show", 
		["customPaging"] = {
		    ["HUNTER"]  	 = "", 
		    ["WARLOCK"] 	 = "", 
		    ["PRIEST"]  	 = "", 
		    ["PALADIN"] 	 = "", 
		    ["MAGE"]    	 = "", 
		    ["ROGUE"]   	 = "", 
		    ["DRUID"]   	 = "", 
		    ["SHAMAN"]  	 = "", 
		    ["WARRIOR"] 	 = "", 
		    ["DEATHKNIGHT"]  = "", 
		    ["MONK"]    	 = "", 
		    ["DEMONHUNTER"]  = "",
		}, 
		["alpha"] = 1
	},
	["Bar7"] = {
		["enable"] = false, 
		["mouseover"] = false, 
		["buttons"] = 12, 
		["buttonsPerRow"] = 12, 
		["point"] = "BOTTOMLEFT", 
		["backdrop"] = false, 
		["buttonsize"] = 32, 
		["buttonspacing"] = 2, 
		["showVehicle"] = false,
		["useCustomPaging"] = false, 
		["useCustomVisibility"] = false, 
		["customVisibility"] = "[petbattle] hide; show", 
		["customPaging"] = {
		    ["HUNTER"]  	 = "", 
		    ["WARLOCK"] 	 = "", 
		    ["PRIEST"]  	 = "", 
		    ["PALADIN"] 	 = "", 
		    ["MAGE"]    	 = "", 
		    ["ROGUE"]   	 = "", 
		    ["DRUID"]   	 = "", 
		    ["SHAMAN"]  	 = "", 
		    ["WARRIOR"] 	 = "", 
		    ["DEATHKNIGHT"]  = "", 
		    ["MONK"]    	 = "", 
		    ["DEMONHUNTER"]  = "",
		}, 
		["alpha"] = 1
	},
	["Bar8"] = {
		["enable"] = false, 
		["mouseover"] = false, 
		["buttons"] = 12, 
		["buttonsPerRow"] = 12, 
		["point"] = "BOTTOMLEFT", 
		["backdrop"] = false, 
		["buttonsize"] = 32, 
		["buttonspacing"] = 2, 
		["showVehicle"] = false,
		["useCustomPaging"] = false, 
		["useCustomVisibility"] = false, 
		["customVisibility"] = "[petbattle] hide; show", 
		["customPaging"] = {
		    ["HUNTER"]  	 = "", 
		    ["WARLOCK"] 	 = "", 
		    ["PRIEST"]  	 = "", 
		    ["PALADIN"] 	 = "", 
		    ["MAGE"]    	 = "", 
		    ["ROGUE"]   	 = "", 
		    ["DRUID"]   	 = "", 
		    ["SHAMAN"]  	 = "", 
		    ["WARRIOR"] 	 = "", 
		    ["DEATHKNIGHT"]  = "", 
		    ["MONK"]    	 = "", 
		    ["DEMONHUNTER"]  = "",
		}, 
		["alpha"] = 1
	},
	["Bar9"] = {
		["enable"] = false, 
		["mouseover"] = false, 
		["buttons"] = 12, 
		["buttonsPerRow"] = 12, 
		["point"] = "BOTTOMLEFT", 
		["backdrop"] = false, 
		["buttonsize"] = 32, 
		["buttonspacing"] = 2, 
		["showVehicle"] = false,
		["useCustomPaging"] = false, 
		["useCustomVisibility"] = false, 
		["customVisibility"] = "[petbattle] hide; show", 
		["customPaging"] = {
		    ["HUNTER"]  	 = "", 
		    ["WARLOCK"] 	 = "", 
		    ["PRIEST"]  	 = "", 
		    ["PALADIN"] 	 = "", 
		    ["MAGE"]    	 = "", 
		    ["ROGUE"]   	 = "", 
		    ["DRUID"]   	 = "", 
		    ["SHAMAN"]  	 = "", 
		    ["WARRIOR"] 	 = "", 
		    ["DEATHKNIGHT"]  = "", 
		    ["MONK"]    	 = "",
		    ["DEMONHUNTER"]  = "",
		}, 
		["alpha"] = 1
	},
	["Bar10"] = {
		["enable"] = false, 
		["mouseover"] = false, 
		["buttons"] = 12, 
		["buttonsPerRow"] = 12, 
		["point"] = "BOTTOMLEFT", 
		["backdrop"] = false, 
		["buttonsize"] = 32, 
		["buttonspacing"] = 2, 
		["showVehicle"] = false,
		["useCustomPaging"] = false, 
		["useCustomVisibility"] = false, 
		["customVisibility"] = "[petbattle] hide; show", 
		["customPaging"] = {
		    ["HUNTER"]  	 = "", 
		    ["WARLOCK"] 	 = "", 
		    ["PRIEST"]  	 = "", 
		    ["PALADIN"] 	 = "", 
		    ["MAGE"]    	 = "", 
		    ["ROGUE"]   	 = "", 
		    ["DRUID"]   	 = "", 
		    ["SHAMAN"]  	 = "", 
		    ["WARRIOR"] 	 = "", 
		    ["DEATHKNIGHT"]  = "", 
		    ["MONK"]    	 = "", 
		    ["DEMONHUNTER"]  = "",
		}, 
		["alpha"] = 1
	},
	["Pet"] = {
		["enable"] = true, 
		["mouseover"] = false, 
		["buttons"] = NUM_PET_ACTION_SLOTS, 
		["buttonsPerRow"] = NUM_PET_ACTION_SLOTS, 
		["point"] = "TOPLEFT", 
		["backdrop"] = false, 
		["buttonsize"] = 24, 
		["buttonspacing"] = 3, 
		["useCustomVisibility"] = false, 
		["customVisibility"] = "[petbattle] hide; [pet, novehicleui, nooverridebar, nopossessbar] show; hide", 
		["alpha"] = 1
	}, 
	["Stance"] = {
		["enable"] = true, 
		["style"] = "darkenInactive", 
		["mouseover"] = false, 
		["buttons"] = NUM_STANCE_SLOTS, 
		["buttonsPerRow"] = NUM_STANCE_SLOTS, 
		["point"] = "BOTTOMLEFT", 
		["backdrop"] = false, 
		["buttonsize"] = 24, 
		["buttonspacing"] = 5, 
		["useCustomVisibility"] = false, 
		["customVisibility"] = "[petbattle] hide; show",  
		["alpha"] = 1
	}
};

function MOD:LoadOptions()
	local count = SV.db.ActionBars.barCount or 6
	local POSITION_VALUES = {
		["TOPLEFT"] = "TOPLEFT", 
		["TOPRIGHT"] = "TOPRIGHT", 
		["BOTTOMLEFT"] = "BOTTOMLEFT", 
		["BOTTOMRIGHT"] = "BOTTOMRIGHT",
	}

	SV.Options.args.primary.args.quickGroup1.args.toggleKeybind = {
		order = 5, 
		width = "full", 
		type = "execute", 
		name = L["Keybind Mode"], 
		func = function()
			MOD:ToggleKeyBindingMode()
			SV:ToggleConfig()
			GameTooltip:Hide()
		end
	};

	SV.Options.args[Schema] = {
		type = "group", 
		name = Schema, 
		childGroups = "tab", 
		get = function(key)
			return SV.db[Schema][key[#key]]
		end, 
		set = function(key, value)
			MOD:ChangeDBVar(value, key[#key]);
			MOD:RefreshActionBars()
		end, 
		args = {
			barGroup = {
				order = 3, 
				type = "group", 
				name = L["Bar Options"], 
				childGroups = "tree",
				args = {
					commonGroup = {
						order = 1, 
						type = "group", 
						name = L["General Settings"], 
						args = { 
							hotkeytext = {
								type = "toggle", 
								name = L["Keybind Text"], 
								desc = L["Display bind names on action buttons."], 
								order = 1
							}, 
							keyDown = {
								type = "toggle", 
								name = L["Key Down"], 
								desc = OPTION_TOOLTIP_ACTION_BUTTON_USE_KEY_DOWN, 
								order = 2
							},
							unlock = {
								type = "select", 
								name = PICKUP_ACTION_KEY_TEXT, 
								desc = L["The button you must hold down in order to drag an ability to another action button."],
								order = 3, 
								values = {
									["SHIFT"] = SHIFT_KEY, 
									["ALT"] = ALT_KEY, 
									["CTRL"] = CTRL_KEY
								}
							},
							macrotext = {
								type = "toggle", 
								name = L["Macro Text"], 
								desc = L["Display macro names on action buttons."], 
								order = 4
							},
							rightClickSelf = {
								type = "toggle", 
								name = L["Self Cast"], 
								desc = L["Right-click any action button to self cast"], 
								order = 5
							}, 
							showGrid = {
								type = "toggle", 
								name = ALWAYS_SHOW_MULTIBARS_TEXT, 
								desc = OPTION_TOOLTIP_ALWAYS_SHOW_MULTIBARS, 
								order = 6
							},
							unc = {
								type = "color", 
								order = 7, 
								name = L["Out of Range"], 
								desc = L["Color of the actionbutton when out of range."], 
								hasAlpha = true, 
								get = function(key) return unpack(SV.db[Schema][key[#key]]) end, 
								set = function(key, rValue, gValue, bValue, aValue)
									SV.db[Schema][key[#key]][1] = rValue
									SV.db[Schema][key[#key]][2] = gValue
									SV.db[Schema][key[#key]][3] = bValue
									SV.db[Schema][key[#key]][4] = aValue
									MOD:RefreshActionBars()
								end, 
							}, 
							unpc = {
								type = "color", 
								order = 8, 
								name = L["Out of Power"], 
								desc = L["Color of the actionbutton when out of power (Mana, Rage, Focus, Holy Power)."], 
								hasAlpha = true, 
								get = function(key) return unpack(SV.db[Schema][key[#key]]) end, 
								set = function(key, rValue, gValue, bValue, aValue)
									SV.db[Schema][key[#key]][1] = rValue
									SV.db[Schema][key[#key]][2] = gValue
									SV.db[Schema][key[#key]][3] = bValue
									SV.db[Schema][key[#key]][4] = aValue
									MOD:RefreshActionBars()
								end, 
							},
							barCount = {
								order = 9, 
								type = "range", 
								width = 'full',
								name = L["Total Bars"], 
								desc = L["The count of available bars."], 
								min = 6, 
								max = 10, 
								step = 1,
								get = function(e)return SV.db[Schema][e[#e]]end, 
								set = function(e, f)SV.db[Schema][e[#e]] = f;SV:StaticPopup_Show("RL_CLIENT")end
							},
							cooldownSize = {
								order = 10, 
								width = "full", 
								name = L["Cooldown Font Size"], 
								type = "range", 
								min = 6, 
								max = 22, 
								step = 1
							},
							
						}
					},
					Pet = {
						order = (count + 2),
						name = L["Pet Bar"],
						type = "group",
						guiInline = false,
						get = function(e)return SV.db[Schema]["Pet"][e[#e]]end,
						set = function(key, value)
							MOD:ChangeDBVar(value, key[#key], "Pet");
							MOD:RefreshBar("Pet")
						end,
						args = {
							enable = {
								order = 1,
								width = 'full',
								type = "toggle",
								name = L["Enable"]
							},
							backdrop = {
								order = 2,
								name = L["Background"],
								type = "toggle",
								disabled = function()return not SV.db[Schema]["Pet"].enable end,
							},
							mouseover = {
								order = 3,
								name = L["Mouse Over"],
								desc = L["The frame is not shown unless you mouse over the frame."],
								type = "toggle",
								disabled = function()return not SV.db[Schema]["Pet"].enable end,
							},
							restorePosition = {
								order = 4,
								type = "execute",
								name = L["Restore Bar"],
								desc = L["Restore the actionbars default settings"],
								func = function()
									SV:ResetData("ActionBars", "Pet")
									SV:ResetAnchors("Pet Bar")
									MOD:RefreshBar("Pet")
								end,
								disabled = function()return not SV.db[Schema]["Pet"].enable end,
							},
							adjustGroup = {
								name = L["Bar Adjustments"],
								type = "group",
								order = 5,
								guiInline = true,
								disabled = function()return not SV.db[Schema]["Pet"].enable end,
								args = {	
									point = {
										order = 1,
										type = "select",
										name = L["Anchor Point"],
										desc = L["The first button anchors itself to this point on the bar."],
										values = POSITION_VALUES
									},
									buttons = {
										order = 2,
										type = "range",
										name = L["Buttons"],
										desc = L["The amount of buttons to display."],
										min = 1,
										max = NUM_PET_ACTION_SLOTS,
										step = 1
									},
									buttonsPerRow = {
										order = 3,
										type = "range",
										name = L["Buttons Per Row"],
										desc = L["The amount of buttons to display per row."],
										min = 1,
										max = NUM_PET_ACTION_SLOTS,
										step = 1
									},
									buttonsize = {
										order = 4,
										type = "range",
										name = L["Button Size"],
										desc = L["The size of the action buttons."],
										min = 15,
										max = 60,
										step = 1,
									},
									buttonspacing = {
										order = 5,
										type = "range",
										name = L["Button Spacing"],
										desc = L["The spacing between buttons."],
										min = 1,
										max = 10,
										step = 1,
									},
									alpha = {
										order = 6,
										type = "range",
										name = L["Alpha"],
										isPercent = true,
										min = 0,
										max = 1,
										step = 0.01
									},
								}
							},
							customGroup = {
								name = L["Visibility Options"],
								type = "group",
								order = 6,
								guiInline = true,
								args = {
									useCustomVisibility = {
										order = 1,
										type = "toggle",
										name = L["Enable"],
										desc = L["Allow the use of custom paging for this bar"],
										get = function()return SV.db[Schema]["Pet"].useCustomVisibility end,
										set = function(e,f)
											SV.db[Schema]["Pet"].useCustomVisibility = f;
											MOD:RefreshBar("Pet")
										end
									},
									resetVisibility = {
										order = 2,
										type = "execute",
										name = L["Restore Defaults"],
										desc = L["Restore default visibility attributes for this bar"],
										func = function()
											SV:ResetData("ActionBars", "Pet", "customVisibility")
											MOD:RefreshBar("Pet")
										end
									},
									customVisibility = {
										order = 3,
										type = "input",
										width = "full",
										name = L["Visibility"],
										desc = L["|cffFF0000ADVANCED:|r Set the visibility attributes for this bar"],
										get = function(e)return SV.db[Schema]["Pet"].customVisibility end,
										set = function(e,f)
											SV.db[Schema]["Pet"].customVisibility = f;
											MOD:RefreshBar("Pet")
										end,
										disabled = function()return not SV.db[Schema]["Pet"].useCustomVisibility end,
									},
								}
							}
						}
					},
					Stance = {
						order = (count + 3),
						name = L["Stance Bar"],
						type = "group",
						guiInline = false,
						get = function(e)return SV.db[Schema]["Stance"][e[#e]]end,
						set = function(key, value)
							MOD:ChangeDBVar(value, key[#key], "Stance");
							MOD:RefreshBar("Stance")
						end,
						args = {
							enable = {
								order = 1,
								width = 'full',
								type = "toggle",
								name = L["Enable"]
							},
							backdrop = {
								order = 2,
								name = L["Background"],
								type = "toggle",
								disabled = function()return not SV.db[Schema]["Stance"].enable end,
							},
							mouseover = {
								order = 3,
								name = L["Mouse Over"],
								desc = L["The frame is not shown unless you mouse over the frame."],
								type = "toggle",
								disabled = function()return not SV.db[Schema]["Stance"].enable end,
							},
							restorePosition = {
								order = 4,
								type = "execute",
								name = L["Restore Bar"],
								desc = L["Restore the actionbars default settings"],
								func = function()
									SVUILib:SetDefault("ActionBars","Stance")
									SV:ResetAnchors("Stance Bar")
									MOD:RefreshBar("Stance")
								end,
								disabled = function()return not SV.db[Schema]["Stance"].enable end,
							},
							adjustGroup = {
								name = L["Bar Adjustments"],
								type = "group",
								order = 5,
								guiInline = true,
								disabled = function()return not SV.db[Schema]["Stance"].enable end,
								args = {
									point = {
										order = 1,
										type = "select",
										name = L["Anchor Point"],
										desc = L["The first button anchors itself to this point on the bar."],
										values = POSITION_VALUES
									},
									buttons = {
										order = 2,
										type = "range",
										name = L["Buttons"],
										desc = L["The amount of buttons to display."],
										min = 1,
										max = NUM_STANCE_SLOTS,
										step = 1
									},
									buttonsPerRow = {
										order = 3,
										type = "range",
										name = L["Buttons Per Row"],
										desc = L["The amount of buttons to display per row."],
										min = 1,
										max = NUM_STANCE_SLOTS,
										step = 1
									},
									buttonsize = {
										order = 4,
										type = "range",
										name = L["Button Size"],
										desc = L["The size of the action buttons."],
										min = 15,
										max = 60,
										step = 1
									},
									buttonspacing = {
										order = 5,
										type = "range",
										name = L["Button Spacing"],
										desc = L["The spacing between buttons."],
										min = 1,
										max = 10,
										step = 1
									},
									alpha = {
										order = 6,
										type = "range",
										name = L["Alpha"],
										isPercent = true,
										min = 0,
										max = 1,
										step = 0.01
									}, 
								}
							},
							customGroup = {
								name = L["Visibility Options"],
								type = "group",
								order = 6,
								guiInline = true,
								disabled = function()return not SV.db[Schema]["Stance"].enable end,
								args = {
									style = {
										order = 1,
										type = "select",
										name = L["Style"],
										desc = L["This setting will be updated upon changing stances."],
										values = {
											["darkenInactive"] = L["Darken Inactive"],
											["classic"] = L["Classic"]
										}
									},
									spacer1 = {
										order = 2,
										type = "description",
										name = "",
									},
									spacer2 = {
										order = 3,
										type = "description",
										name = "",
									},
									useCustomVisibility = {
										order = 4,
										type = "toggle",
										name = L["Enable"],
										desc = L["Allow the use of custom paging for this bar"],
										get = function()return SV.db[Schema]["Stance"].useCustomVisibility end,
										set = function(e,f)
											SV.db[Schema]["Stance"].useCustomVisibility = f;
											MOD:RefreshBar("Stance")
										end
									},
									resetVisibility = {
										order = 5,
										type = "execute",
										name = L["Restore Defaults"],
										desc = L["Restore default visibility attributes for this bar"],
										func = function()
											SV:ResetData("ActionBars", "Stance", "customVisibility")
											MOD:RefreshBar("Stance")
										end
									},
									customVisibility = {
										order = 6,
										type = "input",
										width = "full",
										name = L["Visibility"],
										desc = L["|cffFF0000ADVANCED:|r Set the visibility attributes for this bar"],
										get = function(e)return SV.db[Schema]["Stance"].customVisibility end,
										set = function(e,f)
											SV.db[Schema]["Stance"].customVisibility = f;
											MOD:RefreshBar("Stance")
										end,
										disabled = function()return not SV.db[Schema]["Stance"].useCustomVisibility end,
									},
								}
							}
						}
					},
					Totem = {
						order = (count + 4),
						name = L["Totem Bar"],
						type = "group",
						guiInline = false,
						get = function(key) 
							return SV.db[Schema]["Totem"][key[#key]] 
						end, 
						set = function(key, value)
							MOD:ChangeDBVar(value, key[#key], "Totem");
							SV:StaticPopup_Show("RL_CLIENT")
						end,
						args = {
							enable = {
								order = 1,
								type = "toggle",
								name = L["Enable"],
								width = 'full',
								set = function(key, value)
									MOD:ChangeDBVar(value, key[#key], "Totem");
									SV:StaticPopup_Show("RL_CLIENT")
								end,
							},
							buttonsize = {
								order = 2,
								type = "range",
								name = L["Button Size"],
								desc = L["The size of the action buttons."],
								min = 15,
								max = 60,
								step = 1,
								disabled = function()return not SV.db[Schema]["Totem"].enable end,
							},
							buttonspacing = {
								order = 3,
								type = "range",
								name = L["Button Spacing"],
								desc = L["The spacing between buttons."],
								min = 1,
								max = 10,
								step = 1,
								disabled = function()return not SV.db[Schema]["Totem"].enable end,
							},
							sortDirection = {
								order = 4, 
								type = 'select', 
								name = L["Sort Order"], 
								values = {
									['ASCENDING'] = L['Ascending'], 
									['DESCENDING'] = L['Descending']
								},
								disabled = function()return not SV.db[Schema]["Totem"].enable end,
							},
							showBy = {
								order = 5, 
								type = 'select', 
								name = L["Bar Direction"], 
								values = {
									['VERTICAL'] = L['Vertical'], 
									['HORIZONTAL'] = L['Horizontal']
								},
								disabled = function()return not SV.db[Schema]["Totem"].enable end,
							},
						}
					},
					Micro = {
						order = (count + 5),
						name = L["Micro Menu"],
						type = "group",
						guiInline = false,
						
						get = function(key) 
							return SV.db[Schema]["Micro"][key[#key]] 
						end, 
						set = function(key, value)
							MOD:ChangeDBVar(value, key[#key], "Micro");
							MOD:UpdateMicroButtons()
						end,
						args = {
							enable = {
								order = 1,
								type = "toggle",
								width = 'full',
								name = L["Enable"],
								set = function(key, value)
									MOD:ChangeDBVar(value, key[#key], "Micro");
									SV:StaticPopup_Show("RL_CLIENT")
								end,
							},
							mouseover = {
								order = 2,
								name = L["Mouse Over"],
								desc = L["The frame is not shown unless you mouse over the frame."],
								disabled = function()return not SV.db[Schema]["Micro"].enable end,
								type = "toggle"
							},
							buttonsize = {
								order = 3,
								type = "range",
								name = L["Button Size"],
								desc = L["The size of the action buttons."],
								min = 15,
								max = 60,
								step = 1,
								disabled = function()return not SV.db[Schema]["Micro"].enable end,
							},
							buttonspacing = {
								order = 4,
								type = "range",
								name = L["Button Spacing"],
								desc = L["The spacing between buttons."],
								min = 1,
								max = 10,
								step = 1,
								disabled = function()return not SV.db[Schema]["Micro"].enable end,
							},
						}
					},
				}
			}
		}
	}
	
	for barNumber = 1, count do 
		local barKey = L["Bar"] .. barNumber;
		local barTitle = L["Bar"] .. " " .. barNumber;
		SV.Options.args[Schema].args.barGroup.args[barKey] = {
			order = (barNumber + 1),
			name = barTitle, 
			type = "group", 
			guiInline = false, 
			get = function(key) 
				return SV.db[Schema][barKey][key[#key]] 
			end, 
			set = function(key, value)
				MOD:ChangeDBVar(value, key[#key], barKey);
				MOD:RefreshBar(barKey)
			end, 
			args = {
				enable = {
					order = 1, 
					type = "toggle", 
					width = 'full',
					name = L["Enable"], 
				}, 
				backdrop = {
					order = 2, 
					name = L["Background"], 
					type = "toggle", 
					disabled = function()return not SV.db[Schema][barKey].enable end, 
				}, 
				mouseover = {
					order = 3, 
					name = L["Mouse Over"], 
					desc = L["The frame is not shown unless you mouse over the frame."], 
					type = "toggle", 
					disabled = function()return not SV.db[Schema][barKey].enable end, 
				},
				showVehicle = {
					order = 4, 
					type = "toggle", 
					name = L["Vehicle Bar"], 
					desc = L["Assign " .. barTitle .. " as the location for the vehicle bar. NOTE: Only one bar can have this assigned."], 
					get = function()return SV.db[Schema][barKey].showVehicle end, 
					set = function(e, f)
						SV.db[Schema][barKey].showVehicle = f;
						for z = 1, count do
							if(z ~= barNumber) then
								SV.db[Schema][L["Bar"] .. z].showVehicle = false;
							end
						end
						MOD:UpdateBarPagingDefaults();
						MOD:RefreshActionBars();
						--SV:StaticPopup_Show("RL_CLIENT");
					end
				},
				restorePosition = {
					order = 5, 
					type = "execute", 
					name = L["Restore Bar"], 
					desc = L["Restore the actionbars default settings"], 
					func = function()
						SV:ResetData("ActionBars", barKey)
						SV:ResetAnchors(barKey)
						MOD:RefreshBar(barKey)
					end, 
					disabled = function()return not SV.db[Schema][barKey].enable end, 
				}, 
				adjustGroup = {
					name = L["Bar Adjustments"], 
					type = "group", 
					order = 6, 
					guiInline = true, 
					disabled = function()return not SV.db[Schema][barKey].enable end, 
					args = {
						point = {
							order = 1, 
							type = "select", 
							name = L["Anchor Point"], 
							desc = L["The first button anchors itself to this point on the bar."], 
							values = POSITION_VALUES
						}, 
						buttons = {
							order = 2, 
							type = "range", 
							name = L["Buttons"], 
							desc = L["The amount of buttons to display."], 
							min = 1, 
							max = NUM_ACTIONBAR_BUTTONS, 
							step = 1
						}, 
						buttonsPerRow = {
							order = 3, 
							type = "range", 
							name = L["Buttons Per Row"], 
							desc = L["The amount of buttons to display per row."], 
							min = 1, 
							max = NUM_ACTIONBAR_BUTTONS, 
							step = 1
						}, 
						buttonsize = {
							type = "range", 
							name = L["Button Size"], 
							desc = L["The size of the action buttons."], 
							min = 15, 
							max = 60, 
							step = 1, 
							order = 4
						}, 
						buttonspacing = {
							type = "range", 
							name = L["Button Spacing"], 
							desc = L["The spacing between buttons."], 
							min = 1, 
							max = 10, 
							step = 1, 
							order = 5
						}, 
						alpha = {
							order = 6, 
							type = "range", 
							name = L["Alpha"], 
							isPercent = true, 
							min = 0, 
							max = 1, 
							step = 0.01
						}, 
					}
				}, 
				pagingGroup = {
					name = L["Bar Paging"], 
					type = "group", 
					order = 7, 
					guiInline = true, 
					disabled = function()return not SV.db[Schema][barKey].enable end, 
					args = {
						useCustomPaging = {
							order = 1, 
							type = "toggle", 
							name = L["Custom Paging"], 
							desc = L["Allow the use of custom paging for this bar"], 
							get = function()return SV.db[Schema][barKey].useCustomPaging end, 
							set = function(e, f)
								SV.db[Schema][barKey].useCustomPaging = f;
								MOD:UpdateBarPagingDefaults();
								MOD:RefreshBar(barKey)
							end
						}, 
						resetStates = {
							order = 2, 
							type = "execute", 
							name = L["Restore Defaults"], 
							desc = L["Restore default paging conditions for this bar"], 
							func = function()
								SV:ResetData("ActionBars", barKey, "customPaging")
								MOD:UpdateBarPagingDefaults();
								MOD:RefreshBar(barKey)
							end
						}, 
						customPaging = {
							order = 3, 
							type = "input", 
							width = "full", 
							name = L["Paging Conditions"], 
							desc = L["|cffFF0000ADVANCED:|r Set the paging conditions for this bar"], 
							get = function(e)return SV.db[Schema][barKey].customPaging[SV.class] end, 
							set = function(e, f)
								SV.db[Schema][barKey].customPaging[SV.class] = f;
								MOD:UpdateBarPagingDefaults();
								MOD:RefreshBar(barKey)
							end, 
							disabled = function()return not SV.db[Schema][barKey].useCustomPaging end, 
						},
					}
				},
				visibilityGroup = {
					name = L["Bar Visibility"], 
					type = "group", 
					order = 8, 
					guiInline = true, 
					disabled = function()return not SV.db[Schema][barKey].enable end, 
					args = {
						useCustomVisibility = {
							order = 1, 
							type = "toggle", 
							name = L["Custom Visibility"], 
							desc = L["Allow the use of custom visibility for this bar"], 
							get = function()return SV.db[Schema][barKey].useCustomVisibility end, 
							set = function(e, f)
								SV.db[Schema][barKey].useCustomVisibility = f;
								MOD:UpdateBarPagingDefaults();
								MOD:RefreshBar(barKey)
							end
						}, 
						resetVisibility = {
							order = 2, 
							type = "execute", 
							name = L["Restore Defaults"], 
							desc = L["Restore default visibility conditions for this bar"], 
							func = function()
								--SV:ResetData("ActionBars", barKey, "customVisibility")
								SV.db[Schema][barKey].customVisibility = SV.defaults[Schema][barKey].customVisibility;
								MOD:UpdateBarPagingDefaults();
								MOD:RefreshBar(barKey)
							end
						}, 
						customVisibility = {
							order = 3, 
							type = "input", 
							width = "full", 
							name = L["Visibility Conditions"], 
							desc = L["|cffFF0000ADVANCED:|r Set the visibility conditions for this bar"], 
							get = function(e)return SV.db[Schema][barKey].customVisibility end, 
							set = function(e, f)
								SV.db[Schema][barKey].customVisibility = f;
								MOD:UpdateBarPagingDefaults();
								MOD:RefreshBar(barKey)
							end, 
							disabled = function()return not SV.db[Schema][barKey].useCustomVisibility end, 
						}, 

					}
				}
			}
		}
	end 
end
