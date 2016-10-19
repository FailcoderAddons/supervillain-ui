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
local table 		= _G.table;
local tsort 		= table.sort;

local SV = _G["SVUI"];
local L = SV.L;
local name, obj = ...;
local MOD = SV:NewModule(name, obj, "SVUI_LootCache", "SVUI_Private_LootCache");
local Schema = MOD.Schema;
local pointList = {
	["TOPLEFT"] = "TOPLEFT",
	["TOPRIGHT"] = "TOPRIGHT",
	["BOTTOMLEFT"] = "BOTTOMLEFT",
	["BOTTOMRIGHT"] = "BOTTOMRIGHT",
};

MOD.media = {}
MOD.media.cleanupIcon = [[Interface\AddOns\SVUI_Inventory\assets\BAGS-CLEANUP]];
MOD.media.bagIcon = [[Interface\AddOns\SVUI_Inventory\assets\BAGS-BAGS]];
MOD.media.depositIcon = [[Interface\AddOns\SVUI_Inventory\assets\BAGS-DEPOSIT]];
MOD.media.purchaseIcon = [[Interface\AddOns\SVUI_Inventory\assets\BAGS-PURCHASE]];
MOD.media.reagentIcon = [[Interface\AddOns\SVUI_Inventory\assets\BAGS-REAGENTS]];
MOD.media.sortIcon = [[Interface\AddOns\SVUI_Inventory\assets\BAGS-SORT]];
MOD.media.stackIcon = [[Interface\AddOns\SVUI_Inventory\assets\BAGS-STACK]];
MOD.media.transferIcon = [[Interface\AddOns\SVUI_Inventory\assets\BAGS-TRANSFER]];
MOD.media.vendorIcon = [[Interface\AddOns\SVUI_Inventory\assets\BAGS-VENDOR]];

SV:AssignMedia("font", "bagdialog", "SVUI Default Font", 11, "OUTLINE");
SV:AssignMedia("font", "bagnumber", "SVUI Number Font", 11, "OUTLINE");
SV:AssignMedia("globalfont", "bagdialog", "SVUI_Font_Bag");
SV:AssignMedia("globalfont", "bagnumber", "SVUI_Font_Bag_Number");

SV.defaults[Schema] = {
	["incompatible"] = {
		["AdiBags"] = true,
		["ArkInventory"] = true,
		["Bagnon"] = true,
	},
	["sortInverted"] = false,
	["bags"] = {
		["xOffset"] = -40,
		["yOffset"] = 40,
		["point"] = "BOTTOMRIGHT",
	},
	["bank"] = {
		["xOffset"] = 40,
		["yOffset"] = 40,
		["point"] = "BOTTOMLEFT",
	},
	["separateBags"] = false,
	["bagSize"] = 34,
	["bankSize"] = 34,
	["alignToChat"] = false,
	["bagWidth"] = 525,
	["bankWidth"] = 525,
	["currencyFormat"] = "ICON",
	["ignoreItems"] = "",
	["bagTools"] = true,
	["iLevels"] = true,
	["bagBar"] = {
		["enable"] = false,
		["showBy"] = "VERTICAL",
		["sortDirection"] = "ASCENDING",
		["size"] = 30,
		["spacing"] = 4,
		["showBackdrop"] = false,
		["mouseover"] = false,
	},
};

function MOD:LoadOptions()
	local bagFonts = {
		["bagdialog"] = {
			order = 1,
			name = "Bag Slot Dialog",
			desc = "Default font used in bag and bank slots"
		},
	    ["bagnumber"] = {
			order = 2,
			name = "Bag Slot Numbers",
			desc = "Font used in bag and bank slots to display numeric values."
		},
	};

	SV:GenerateFontOptionGroup("Bags", 7, "Fonts used in bag slots.", bagFonts)

	SV.Options.args[Schema] = {
		type = 'group',
		name = Schema,
		childGroups = "tab",
		get = function(a)return SV.db[Schema][a[#a]]end,
		set = function(a,b)MOD:ChangeDBVar(b,a[#a]) end,
		args = {
			intro = {
				order = 1,
				type = "description",
				name = L["BAGS_DESC"]
			},
			bagGroups={
				order = 2,
				type = 'group',
				name = L['Bag Options'],
				guiInline = true,
				args = {
					common = {
						order = 1,
						type = "group",
						guiInline = true,
						name = L["General"],
						args = {
							bagSize = {
								order = 1,
								type = "range",
								name = L["Button Size (Bag)"],
								desc = L["The size of the individual buttons on the bag frame."],
								min = 15,
								max = 45,
								step = 1,
								set = function(a,b) MOD:ChangeDBVar(b,a[#a]) MOD:RefreshBagFrames("BagFrame") end,
								disabled = function()return SV.db[Schema].alignToChat end
							},
							bankSize = {
								order = 2,
								type = "range",
								name = L["Button Size (Bank)"],
								desc = L["The size of the individual buttons on the bank frame."],
								min = 15,
								max = 45,
								step = 1,
								set = function(a,b) MOD:ChangeDBVar(b,a[#a]) MOD:RefreshBagFrames("BankFrame") end,
								disabled = function()return SV.db[Schema].alignToChat end
							},
							bagWidth = {
								order = 3,
								type = "range",
								name = L["Panel Width (Bags)"],
								desc = L["Adjust the width of the bag frame."],
								min = 150,
								max = 700,
								step = 1,
								set = function(a,b) MOD:ChangeDBVar(b,a[#a]) MOD:RefreshBagFrames("BagFrame") end,
								disabled = function()return SV.db[Schema].alignToChat end
							},
							bankWidth = {
								order = 4,
								type = "range",
								name = L["Panel Width (Bank)"],
								desc = L["Adjust the width of the bank frame."],
								min = 150,
								max = 700,
								step = 1,
								set = function(a,b) MOD:ChangeDBVar(b,a[#a]) MOD:RefreshBagFrames("BankFrame") end,
								disabled = function() return SV.db[Schema].alignToChat end
							},
							currencyFormat = {
								order = 5,
								type = "select",
								name = L["Currency Format"],
								desc = L["The display format of the currency icons that get displayed below the main bag. (You have to be watching a currency for this to display)"],
								values = {
									["ICON"] = L["Icons Only"],
									["ICON_TEXT"] = L["Icons and Text"]
								},
								set = function(a,b)MOD:ChangeDBVar(b,a[#a]) MOD:RefreshTokens() end
							},
							sortInverted = {
								order = 6,
								type = "toggle",
								name = L["Sort Inverted"],
								desc = L["Direction the bag sorting will use to allocate the items."]
							},
							bagTools = {
								order = 7,
								type = "toggle",
								name = L["Profession Tools"],
								desc = L["Enable/Disable Prospecting, Disenchanting and Milling buttons on the bag frame."],
								set = function(a,b)MOD:ChangeDBVar(b,a[#a])SV:StaticPopup_Show("RL_CLIENT")end
							},
							ignoreItems = {
								order = 8,
								name = L["Ignore Items"],
								desc = L["List of items to ignore when sorting. If you wish to add multiple items you must seperate the word with a comma."],
								type = "input",
								width = "full",
								multiline = true,
								set = function(a,b) SV.db[Schema][a[#a]] = b end
							}
						}
					},
					position = {
						order = 2,
						type = "group",
						guiInline = true,
						name = L["Bag/Bank Positioning"],
						args = {
							separateBags = {
								order = 0,
								type = "toggle",
								name = L["Separate Bag Windows"],
								desc = L["Allows the use of multiple panels for bags, instead of just one."]
							},
							alignToChat = {
								order = 1,
								type = "toggle",
								name = L["Align To Docks"],
								desc = L["Align the width of the bag frame to fit inside dock windows."],
								set = function(a,b)MOD:ChangeDBVar(b,a[#a]) MOD:RefreshBagFrames() end
							},
							bags = {
								order = 2,
								type = "group",
								name = L["Bag Position"],
								guiInline = true,
								get = function(key) return SV.db[Schema].bags[key[#key]] end,
								set = function(key, value) MOD:ChangeDBVar(value, key[#key], "bags"); MOD:ModifyBags() end,
								args = {
									point = {
										order = 1,
										name = L["Anchor Point"],
										type = "select",
										values = pointList,
									},
									xOffset = {
										order = 2,
										type = "range",
										name = L["X Offset"],
										min = -600,
										max = 600,
										step = 1,
									},
									yOffset = {
										order = 3,
										type = "range",
										name = L["Y Offset"],
										min = -600,
										max = 600,
										step = 1,
									},
								}
							},
							bank = {
								order = 3,
								type = "group",
								name = L["Bank Position"],
								guiInline = true,
								get = function(key) return SV.db[Schema].bank[key[#key]] end,
								set = function(key, value) MOD:ChangeDBVar(value, key[#key], "bank"); MOD:ModifyBags() end,
								args = {
									point = {
										order = 1,
										name = L["Anchor Point"],
										type = "select",
										values = pointList,
									},
									xOffset = {
										order = 2,
										type = "range",
										name = L["X Offset"],
										min = -600,
										max = 600,
										step = 1,
									},
									yOffset = {
										order = 3,
										type = "range",
										name = L["Y Offset"],
										min = -600,
										max = 600,
										step = 1,
									},
								}
							},
						}
					},
					bagBar = {
						order = 4,
						type = "group",
						name = L["Bag-Bar"],
						guiInline = true,
						get = function(key) return SV.db[Schema].bagBar[key[#key]] end,
						set = function(key, value) MOD:ChangeDBVar(value, key[#key], "bagBar"); MOD:ModifyBagBar() end,
						args={
							enable = {
								order = 1,
								type = "toggle",
								name = L["Bags Bar Enabled"],
								desc = L["Enable/Disable the Bag-Bar."],
								get = function() return SV.db[Schema].bagBar.enable end,
								set = function(key, value) MOD:ChangeDBVar(value, key[#key], "bagBar"); SV:StaticPopup_Show("RL_CLIENT")end
							},
							mouseover = {
								order = 2,
								name = L["Mouse Over"],
								desc = L["Hidden unless you mouse over the frame."],
								type = "toggle"
							},
							showBackdrop = {
								order = 3,
								name = L["Backdrop"],
								desc = L["Show/Hide bag bar backdrop"],
								type = "toggle"
							},
							spacer = {
								order = 4,
								name = "",
								type = "description",
								width = "full",
							},
							size = {
								order = 5,
								type = "range",
								name = L["Button Size"],
								desc = L["Set the size of your bag buttons."],
								min = 24,
								max = 60,
								step = 1
							},
							spacing = {
								order = 6,
								type = "range",
								name = L["Button Spacing"],
								desc = L["The spacing between buttons."],
								min = 1,
								max = 10,
								step = 1
							},
							sortDirection = {
								order = 7,
								type = "select",
								name = L["Sort Direction"],
								desc = L["The direction that the bag frames will grow from the anchor."],
								values = {
									["ASCENDING"] = L["Ascending"],
									["DESCENDING"] = L["Descending"]
								}
							},
							showBy = {
								order = 8,
								type = "select",
								name = L["Bar Direction"],
								desc = L["The direction that the bag frames be (Horizontal or Vertical)."],
								values = {
									["VERTICAL"] = L["Vertical"],
									["HORIZONTAL"] = L["Horizontal"]
								}
							}
						}
					},
				}
			}
		}
	};
end
