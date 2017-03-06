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

local LSM = _G.LibStub("LibSharedMedia-3.0")
if(LSM) then
	LSM:Register("background", "SVUI Model BG 2", [[Interface\TALENTFRAME\DeathKnightBlood-TopLeft]]);
	LSM:Register("background", "SVUI Model BG 3", [[Interface\TALENTFRAME\DeathKnightFrost-TopLeft]]);
	LSM:Register("background", "SVUI Model BG 4", [[Interface\TALENTFRAME\DeathKnightUnholy-TopLeft]]);
	LSM:Register("background", "SVUI Model BG 5", [[Interface\TALENTFRAME\DruidBalance-TopLeft]]);
	LSM:Register("background", "SVUI Model BG 6", [[Interface\TALENTFRAME\DruidFeralCombat-TopLeft]]);
	LSM:Register("background", "SVUI Model BG 7", [[Interface\TALENTFRAME\DruidRestoration-TopLeft]]);
	LSM:Register("background", "SVUI Model BG 8", [[Interface\TALENTFRAME\HunterBeastMastery-TopLeft]]);
	LSM:Register("background", "SVUI Model BG 9", [[Interface\TALENTFRAME\HunterMarksmanship-TopLeft]]);
	LSM:Register("background", "SVUI Model BG 10", [[Interface\TALENTFRAME\HunterPetCunning-TopLeft]]);
	LSM:Register("background", "SVUI Model BG 11", [[Interface\TALENTFRAME\HunterPetFerocity-TopLeft]]);
	LSM:Register("background", "SVUI Model BG 12", [[Interface\TALENTFRAME\HunterPetTenacity-TopLeft]]);
	LSM:Register("background", "SVUI Model BG 13", [[Interface\TALENTFRAME\HunterSurvival-TopLeft]]);
	LSM:Register("background", "SVUI Model BG 14", [[Interface\TALENTFRAME\MageArcane-TopLeft]]);
	LSM:Register("background", "SVUI Model BG 15", [[Interface\TALENTFRAME\MageFire-TopLeft]]);
	LSM:Register("background", "SVUI Model BG 16", [[Interface\TALENTFRAME\MageFrost-TopLeft]]);
	LSM:Register("background", "SVUI Model BG 17", [[Interface\TALENTFRAME\PALADINCOMBAT-TOPLEFT]]);
	LSM:Register("background", "SVUI Model BG 18", [[Interface\TALENTFRAME\PALADINHOLY-TOPLEFT]]);
	LSM:Register("background", "SVUI Model BG 19", [[Interface\TALENTFRAME\PALADINPROTECTION-TOPLEFT]]);
	LSM:Register("background", "SVUI Model BG 20", [[Interface\TALENTFRAME\PriestDiscipline-TopLeft]]);
	LSM:Register("background", "SVUI Model BG 21", [[Interface\TALENTFRAME\PriestHoly-TopLeft]]);
	LSM:Register("background", "SVUI Model BG 22", [[Interface\TALENTFRAME\PriestShadow-TopLeft]]);
	LSM:Register("background", "SVUI Model BG 23", [[Interface\TALENTFRAME\RogueAssassination-TopLeft]]);
	LSM:Register("background", "SVUI Model BG 24", [[Interface\TALENTFRAME\RogueCombat-TopLeft]]);
	LSM:Register("background", "SVUI Model BG 25", [[Interface\TALENTFRAME\RogueSubtlety-TopLeft]]);
	LSM:Register("background", "SVUI Model BG 26", [[Interface\TALENTFRAME\ShamanElementalCombat-TopLeft]]);
	LSM:Register("background", "SVUI Model BG 27", [[Interface\TALENTFRAME\ShamanEnhancement-TopLeft]]);
	LSM:Register("background", "SVUI Model BG 28", [[Interface\TALENTFRAME\ShamanRestoration-TopLeft]]);
	LSM:Register("background", "SVUI Model BG 29", [[Interface\TALENTFRAME\WarlockCurses-TopLeft]]);
	LSM:Register("background", "SVUI Model BG 30", [[Interface\TALENTFRAME\WarlockDestruction-TopLeft]]);
	LSM:Register("background", "SVUI Model BG 31", [[Interface\TALENTFRAME\WarlockSummoning-TopLeft]]);
	LSM:Register("background", "SVUI Model BG 32", [[Interface\TALENTFRAME\WarriorArm-TopLeft]]);
	LSM:Register("background", "SVUI Model BG 33", [[Interface\TALENTFRAME\WarriorArms-TopLeft]]);
	LSM:Register("background", "SVUI Model BG 34", [[Interface\TALENTFRAME\WarriorFury-TopLeft]]);
	LSM:Register("background", "SVUI Model BG 35", [[Interface\TALENTFRAME\WarriorProtection-TopLeft]]);
end

SV.defaults[Schema] = {
	["enable"] = true,
	["enableAddonDock"] = true,
	["blizzard"] = {
		["enable"] = true,
		["artifact"] = true,
		["bags"] = true,
		["bmah"] = true,
		["chat"] = true,
		["reforge"] = true,
		["calendar"] = true,
		["achievement"] = true,
		["lfguild"] = true,
		["inspect"] = true,
		["binding"] = true,
		["gbank"] = true,
		["archaeology"] = true,
		["guildcontrol"] = true,
		["gossip"] = true,
		["guild"] = true,
		["tradeskill"] = true,
		["raid"] = false,
		["talent"] = true,
		["auctionhouse"] = true,
		["barber"] = true,
		["macro"] = true,
		["debug"] = true,
		["trainer"] = true,
		["socket"] = true,
		["loot"] = true,
		["alertframes"] = true,
		["bgscore"] = true,
		["merchant"] = true,
		["mail"] = true,
		["help"] = true,
		["trade"] = true,
		["gossip"] = true,
		["greeting"] = true,
		["worldmap"] = true,
		["taxi"] = true,
		["quest"] = true,
		["petition"] = true,
		["dressingroom"] = true,
		["pvp"] = true,
		["lfg"] = true,
		["nonraid"] = true,
		["friends"] = true,
		["spellbook"] = true,
		["character"] = true,
		["misc"] = true,
		["tabard"] = true,
		["guildregistrar"] = true,
		["timemanager"] = true,
		["encounterjournal"] = true,
		["voidstorage"] = true,
		["transmogrify"] = true,
		["stable"] = true,
		["bgmap"] = true,
		["mounts"] = true,
		["petbattleui"] = true,
		["losscontrol"] = true,
		["itemUpgrade"] = true,
		["talkingHead"] = true,
		["orderhall"] = true,
	},
	["addons"] = {
		["enable"] = true,
		['ACP'] = true,
		['AdiBags'] = true,
		['Altoholic'] = true,
		['AtlasLoot'] = true,
		['AuctionLite'] = true,
		['alDamageMeter'] = true,
		['BigWigs'] = true,
		['Bugsack'] = true,
		['Clique'] = true,
		['Cooline'] = true,
		['Details'] = true,
		['DBM'] = true,
		['DXE'] = true,
		['LightHeaded'] = true,
		['MasterPlan'] = true,
		['Mogit'] = true,
		['Omen'] = true,
		['Outfitter'] = true,
		['Postal'] = true,
		['Quartz'] = true,
		['Recount'] = true,
		['SexyCooldown'] = true,
		['Skada'] = true,
		['Storyline'] = true,
		['TinyDPS'] = true,
		['TomTom'] = true,
		['TradeSkillDW'] = true,
		['VEM'] = true,
		['ZygorGuidesViewer'] = true,
	},
};

local function AddonConfigOptions()
	local t = {};
	for addonName,_ in pairs(SV.db[Schema].addons) do
		t[addonName] = {
			type = "toggle",
			name = addonName,
			desc = L["Addon Styling"],
			get = function(key) return MOD:IsAddonReady(key[#key]) end,
			set = function(key,value) MOD:ChangeDBVar(value, key[#key], "addons"); SV:StaticPopup_Show("RL_CLIENT") end,
		}
	end
	return t;
end

function MOD:LoadOptions()
	SV.Options.args.Dock.args.AddonDocklets = {
		order = 13,
		type = "group",
		name = L["Docked Addons"],
		guiInline = true,
		args = {
			enableAddonDock = {
				type = "toggle",
				order = 1,
				width = "full",
				name = "Enable Docking",
				get = function() return SV.db[Schema].enableAddonDock end,
				set = function(a,value) SV.db[Schema].enableAddonDock = value; MOD:RegisterAddonDocklets() end,
			},
			DockletMain = {
				type = "select",
				order = 2,
				name = "Primary Docklet",
				desc = "Select an addon to occupy the primary docklet window",
				disabled = function() return not SV.db[Schema].enableAddonDock end,
				values = function() return MOD:GetDockables() end,
				get = function() return SV.private.Docks.Embed1 end,
				set = function(a,value) SV.private.Docks.Embed1 = value; MOD:RegisterAddonDocklets() end,
			},
			DockletSplit = {
				type = "select",
				order = 3,
				name = "Secondary Docklet",
				desc = "Select another addon",
				disabled = function() return not SV.db[Schema].enableAddonDock end,
				values = function() return MOD:GetDockables(true) end,
				get = function() return SV.private.Docks.Embed2 end,
				set = function(a,value) SV.private.Docks.Embed2 = value; MOD:RegisterAddonDocklets() end,
			}
		}
	};

	SV.Options.args[Schema] = {
		type = 'group',
		name = Schema,
		args = {
			blizzardEnable = {
			    order = 2,
				name = "Standard UI Styling",
			    type = "toggle",
			    get = function(key) return SV.db[Schema].blizzard.enable end,
			    set = function(key,value) SV.db[Schema].blizzard.enable = value; SV:StaticPopup_Show("RL_CLIENT") end
			},
			addonEnable = {
			    order = 3,
				name = "Addon Styling",
			    type = "toggle",
			    get = function(key) return SV.db[Schema].addons.enable end,
			    set = function(key,value) SV.db[Schema].addons.enable = value; SV:StaticPopup_Show("RL_CLIENT") end
			},
			addons = {
				order = 4,
				type = "group",
				name = "Addon Styling",
				get = function(key) return SV.db[Schema].addons[key[#key]] end,
				set = function(key,value) SV.db[Schema].addons[key[#key]] = value; SV:StaticPopup_Show("RL_CLIENT")end,
				disabled = function() return not SV.db[Schema].addons.enable end,
				guiInline = true,
				args = AddonConfigOptions()
			},
			blizzard = {
				order = 300,
				type = "group",
				name = "Individual Mods",
				get = function(key) return SV.db[Schema].blizzard[key[#key]] end,
				set = function(key,value) SV.db[Schema].blizzard[key[#key]] = value; SV:StaticPopup_Show("RL_CLIENT") end,
				disabled = function() return not SV.db[Schema].blizzard.enable end,
				guiInline = true,
				args = {
					bmah = {
						type = "toggle",
						name = L["Black Market AH"],
						desc = L["TOGGLEART_DESC"]
					},
					chat = {
						type = "toggle",
						name = L["Chat Menus"],
						desc = L["TOGGLEART_DESC"]
					},
					transmogrify = {
						type = "toggle",
						name = L["Transmogrify Frame"],
						desc = L["TOGGLEART_DESC"]
					},
					encounterjournal = {
						type = "toggle",
						name = L["Encounter Journal"],
						desc = L["TOGGLEART_DESC"]
					},
					reforge = {
						type = "toggle",
						name = L["Reforge Frame"],
						desc = L["TOGGLEART_DESC"]
					},
					calendar = {
						type = "toggle",
						name = L["Calendar Frame"],
						desc = L["TOGGLEART_DESC"]
					},
					achievement = {
						type = "toggle",
						name = L["Achievement Frame"],
						desc = L["TOGGLEART_DESC"]
					},
					lfguild = {
						type = "toggle",
						name = L["LF Guild Frame"],
						desc = L["TOGGLEART_DESC"]
					},
					inspect = {
						type = "toggle",
						name = L["Inspect Frame"],
						desc = L["TOGGLEART_DESC"]
					},
					binding = {
						type = "toggle",
						name = L["KeyBinding Frame"],
						desc = L["TOGGLEART_DESC"]
					},
					gbank = {
						type = "toggle",
						name = L["Guild Bank"],
						desc = L["TOGGLEART_DESC"]
					},
					archaeology = {
						type = "toggle",
						name = L["Archaeology Frame"],
						desc = L["TOGGLEART_DESC"]
					},
					guildcontrol = {
						type = "toggle",
						name = L["Guild Control Frame"],
						desc = L["TOGGLEART_DESC"]
					},
					guild = {
						type = "toggle",
						name = L["Guild Frame"],
						desc = L["TOGGLEART_DESC"]
					},
					tradeskill = {
						type = "toggle",
						name = L["TradeSkill Frame"],
						desc = L["TOGGLEART_DESC"]
					},
					raid = {
						type = "toggle",
						name = L["Raid Frame"],
						desc = L["TOGGLEART_DESC"]
					},
					talent = {
						type = "toggle",
						name = L["Talent Frame"],
						desc = L["TOGGLEART_DESC"]
					},
					auctionhouse = {
						type = "toggle",
						name = L["Auction Frame"],
						desc = L["TOGGLEART_DESC"]
					},
					timemanager = {
						type = "toggle",
						name = L["Time Manager"],
						desc = L["TOGGLEART_DESC"]
					},
					barber = {
						type = "toggle",
						name = L["Barbershop Frame"],
						desc = L["TOGGLEART_DESC"]
					},
					macro = {
						type = "toggle",
						name = L["Macro Frame"],
						desc = L["TOGGLEART_DESC"]
					},
					debug = {
						type = "toggle",
						name = L["Debug Tools"],
						desc = L["TOGGLEART_DESC"]
					},
					trainer = {
						type = "toggle",
						name = L["Trainer Frame"],
						desc = L["TOGGLEART_DESC"]
					},
					socket = {
						type = "toggle",
						name = L["Socket Frame"],
						desc = L["TOGGLEART_DESC"]
					},
					alertframes = {
						type = "toggle",
						name = L["Alert Frames"],
						desc = L["TOGGLEART_DESC"]
					},
					loot = {
						type = "toggle",
						name = L["Loot Frames"],
						desc = L["TOGGLEART_DESC"]
					},
					bgscore = {
						type = "toggle",
						name = L["BG Score"],
						desc = L["TOGGLEART_DESC"]
					},
					merchant = {
						type = "toggle",
						name = L["Merchant Frame"],
						desc = L["TOGGLEART_DESC"]
					},
					mail = {
						type = "toggle",
						name = L["Mail Frame"],
						desc = L["TOGGLEART_DESC"]
					},
					help = {
						type = "toggle",
						name = L["Help Frame"],
						desc = L["TOGGLEART_DESC"]
					},
					trade = {
						type = "toggle",
						name = L["Trade Frame"],
						desc = L["TOGGLEART_DESC"]
					},
					gossip = {
						type = "toggle",
						name = L["Gossip Frame"],
						desc = L["TOGGLEART_DESC"]
					},
					greeting = {
						type = "toggle",
						name = L["Greeting Frame"],
						desc = L["TOGGLEART_DESC"]
					},
					worldmap = {
						type = "toggle",
						name = L["World Map"],
						desc = L["TOGGLEART_DESC"]
					},
					taxi = {
						type = "toggle",
						name = L["Taxi Frame"],
						desc = L["TOGGLEART_DESC"]
					},
					lfg = {
						type = "toggle",
						name = L["LFG Frame"],
						desc = L["TOGGLEART_DESC"]
					},
					mounts = {
						type = "toggle",
						name = L["Collections"],
						desc = L["TOGGLEART_DESC"]
					},
					quest = {
						type = "toggle",
						name = L["Quest Frames"],
						desc = L["TOGGLEART_DESC"]
					},
					petition = {
						type = "toggle",
						name = L["Petition Frame"],
						desc = L["TOGGLEART_DESC"]
					},
					dressingroom = {
						type = "toggle",
						name = L["Dressing Room"],
						desc = L["TOGGLEART_DESC"]
					},
					pvp = {
						type = "toggle",
						name = L["PvP Frames"],
						desc = L["TOGGLEART_DESC"]
					},
					orderhall = {
						type = "toggle",
						name = L["Order Hall"],
						desc = L["TOGGLEART_DESC"]
					},
					nonraid = {
						type = "toggle",
						name = L["Non-Raid Frame"],
						desc = L["TOGGLEART_DESC"]
					},
					friends = {
						type = "toggle",
						name = L["Friends"],
						desc = L["TOGGLEART_DESC"]
					},
					spellbook = {
						type = "toggle",
						name = L["Spellbook"],
						desc = L["TOGGLEART_DESC"]
					},
					character = {
						type = "toggle",
						name = L["Character Frame"],
						desc = L["TOGGLEART_DESC"]
					},
					misc = {
						type = "toggle",
						name = L["Misc Frames"],
						desc = L["TOGGLEART_DESC"]
					},
					tabard = {
						type = "toggle",
						name = L["Tabard Frame"],
						desc = L["TOGGLEART_DESC"]
					},
					guildregistrar = {
						type = "toggle",
						name = L["Guild Registrar"],
						desc = L["TOGGLEART_DESC"]
					},
					bags = {
						type = "toggle",
						name = L["Bags"],
						desc = L["TOGGLEART_DESC"]
					},
					stable = {
						type = "toggle",
						name = L["Stable"],
						desc = L["TOGGLEART_DESC"]
					},
					bgmap = {
						type = "toggle",
						name = L["BG Map"],
						desc = L["TOGGLEART_DESC"]
					},
					petbattleui = {
						type = "toggle",
						name = L["Pet Battle"],
						desc = L["TOGGLEART_DESC"]
					},
					losscontrol = {
						type = "toggle",
						name = L["Loss Control"],
						desc = L["TOGGLEART_DESC"]
					},
					voidstorage = {
						type = "toggle",
						name = L["Void Storage"],
						desc = L["TOGGLEART_DESC"]
					},
					itemUpgrade = {
						type = "toggle",
						name = L["Item Upgrade"],
						desc = L["TOGGLEART_DESC"]
					}
				}
			}
		}
	}
end
