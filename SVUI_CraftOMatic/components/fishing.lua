--[[
##########################################################
S V U I   By: S.Jackson
##########################################################
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local unpack        = _G.unpack;
local select        = _G.select;
local assert        = _G.assert;
local type          = _G.type;
local error         = _G.error;
local pcall         = _G.pcall;
local print         = _G.print;
local ipairs        = _G.ipairs;
local pairs         = _G.pairs;
local next          = _G.next;
local rawset        = _G.rawset;
local rawget        = _G.rawget;
local tostring      = _G.tostring;
local tonumber      = _G.tonumber;
local getmetatable  = _G.getmetatable;
local setmetatable  = _G.setmetatable;
--STRING
local string        = _G.string;
local upper         = string.upper;
local format        = string.format;
local find          = string.find;
local match         = string.match;
local gsub          = string.gsub;
local rept      = string.rep;
local math 		= _G.math;
local table 	= _G.table;
local tsort,twipe = table.sort,table.wipe;
local floor,ceil  = math.floor, math.ceil;
local band 		= _G.bit.band;
--BLIZZARD API
local CreateFrame           = _G.CreateFrame;
local InCombatLockdown      = _G.InCombatLockdown;
local GameTooltip           = _G.GameTooltip;
local hooksecurefunc        = _G.hooksecurefunc;
local IsSpellKnown      	= _G.IsSpellKnown;
local GetSpellInfo      	= _G.GetSpellInfo;
local GetProfessions      	= _G.GetProfessions;
local GetProfessionInfo     = _G.GetProfessionInfo;
local PlaySound             = _G.PlaySound;
local PlaySoundFile         = _G.PlaySoundFile;
local C_PetJournal          = _G.C_PetJournal;
local GetItemInfo           = _G.GetItemInfo;
local GetItemCount          = _G.GetItemCount;
local GetItemQualityColor   = _G.GetItemQualityColor;
local GetItemFamily         = _G.GetItemFamily;
--[[
##########################################################
GET ADDON DATA
##########################################################
]]--
local SV = _G.SVUI;
local L = SV.L;
local PLUGIN = select(2, ...);
local CONFIGS = SV.defaults[PLUGIN.Schema];
--[[
##########################################################
LOCAL VARS
##########################################################
]]--
local fishingIsKnown, fishingSpell, fishingLure;
local proxyTest = false;
local refLures = {
	{ ["id"] = 6529, 		["bonus"] = 25, 	["skillReq"] = 1, 	["order"] = 10, }, --Shiny Bauble
	{ ["id"] = 6811, 		["bonus"] = 50, 	["skillReq"] = 50, 	["order"] = 10, }, --Aquadynamic Fish Lens
	{ ["id"] = 6530, 		["bonus"] = 50, 	["skillReq"] = 50, 	["order"] = 10, }, --Nightcrawlers
	{ ["id"] = 7307, 		["bonus"] = 75, 	["skillReq"] = 100, ["order"] = 10, }, --Flesh Eating Worm
	{ ["id"] = 6532, 		["bonus"] = 75, 	["skillReq"] = 100, ["order"] = 10, }, --Bright Baubles
	{ ["id"] = 34861, 	["bonus"] = 100, 	["skillReq"] = 100, ["order"] = 10, }, --Sharpened Fish Hook
	{ ["id"] = 6533, 		["bonus"] = 100, 	["skillReq"] = 100, ["order"] = 10, }, --Aquadynamic Fish Attractor
	{ ["id"] = 62673, 	["bonus"] = 100, 	["skillReq"] = 100, ["order"] = 10, }, --Feathered Lure
	{ ["id"] = 46006, 	["bonus"] = 100, 	["skillReq"] = 100, ["order"] = 60, }, --Glow Worm
	{ ["id"] = 68049, 	["bonus"] = 150, 	["skillReq"] = 250, ["order"] = 5,  }, --Heat-Treated Spinning Lure
	{ ["id"] = 118391, 	["bonus"] = 200, 	["skillReq"] = 100, ["order"] = 70, }, --Worm Supreme WOD
	{ ["id"] = 67404, 	["bonus"] = 15, 	["skillReq"] = 1, 	["order"] = 10, }, --Glass Fishing Bobber
}
tsort(refLures, function(a,b)
	if ( a.bonus == b.bonus ) then
		return a.order < b.order;
	else
		return a.bonus < b.bonus;
	end
end);
local refHats = {
	{ ["id"] = 93732, 	["weight"] = 10, 	["nocast"] = true 	},  --Darkmoon Fishing Hat
	{ ["id"] = 33820, 	["weight"] = 50, 	["nocast"] = false 	},  --Weather Beaten Fishing Hat
	{ ["id"] = 19972, 	["weight"] = 75, 	["nocast"] = false 	},  --Lucky Fishing Hat
	{ ["id"] = 118380, 	["weight"] = 100, ["nocast"] = false 	},  --Hightfish Cap 7Days WOD
	{ ["id"] = 118393, 	["weight"] = 100, ["nocast"] = false 	},  --Tentacled Hat 7Days WOD
	{ ["id"] = 88710, 	["weight"] = 100, ["nocast"] = false 	},  --Nats Hat
	{ ["id"] = 117405, 	["weight"] = 100, ["nocast"] = false 	},  --Nats Drinking Hat
}
local refPoles = {
	{ ["id"] = 118381, 	["weight"] = 50 }, --Ephemeral Fishing Pole 24hours WOD
	{ ["id"] = 44050, 	["weight"] = 33 }, --Kaluak
	{ ["id"] = 25978, 	["weight"] = 22 }, --Seths Graphite
	{ ["id"] = 19022, 	["weight"] = 21 }, --Nat Pagles Extreme Angler
	{ ["id"] = 6367, 		["weight"] = 20 }, --Big Iron
	{ ["id"] = 6366, 		["weight"] = 15 }, --Darkwood
	{ ["id"] = 84661, 	["weight"] = 32 }, --Dragon
	{ ["id"] = 19970, 	["weight"] = 40 }, --Arcanite
	{ ["id"] = 45858, 	["weight"] = 25 }, --Nats Lucky
	{ ["id"] = 45992, 	["weight"] = 31 }, --Jeweled
	{ ["id"] = 45991, 	["weight"] = 30 }, --Bone
	{ ["id"] = 6365, 		["weight"] = 5 	}, --Strong
	{ ["id"] = 12225, 	["weight"] = 4 	}, --Blump Family
	{ ["id"] = 46337, 	["weight"] = 3 	}, --Staats
	{ ["id"] = 84660, 	["weight"] = 10 }, --Pandaren
	{ ["id"] = 6256, 		["weight"] = 1 	}  --Standard
}
--[[
##########################################################
LOCAL FUNCTIONS
##########################################################
]]--
local function GetFishingSkill()
	local fishing = select(4, GetProfessions())
	if (fishing) then
		local rank = select(3, GetProfessionInfo(fishing))
		return rank
	end
	return 0, 0, 0
end

local function FishingPoleIsEquipped()
	local itemId = GetInventoryItemID("player", 16)
	if itemId then
		local subclass = select(7, GetItemInfo(itemId))
		local weaponSubTypesList = select(17, GetAuctionItemSubClasses(1))
		if subclass == weaponSubTypesList then
			return true
		else
			return false
		end
	else
		return false
	end
end

local function UpdateFishingGear(autoequip)
	local lastBonus, lastWeight = 0,0;
	local rawskill = GetFishingSkill();
	local item,id,bonus,count;

	-- Check for and equip a fishing hat, if autoequip is enabled
	if(autoequip) then
		local fishingHat = false;
		for i=1, #refHats do
			item = refHats[i]
			id = item.id
			bonus = item.weight
			count = GetItemCount(id)
			if ( count > 0 and bonus > lastWeight ) then
				fishingHat = id
				lastWeight = bonus
				if(item.weight > 10) then
					fishingLure = id
					lastBonus = bonus
				end
			end
		end
		if(fishingHat) then
			local HelmetID = GetInventoryItemID("player", INVSLOT_HEAD);
			if(HelmetID) then
				PLUGIN.WornItems["HEAD"] = HelmetID
			end
			EquipItemByName(fishingHat)
			PLUGIN.InModeGear = true
		end
	end

	-- Check for and save best fishing lure
	for i=1, #refLures do
		item = refLures[i]
		id = item.id
		bonus = item.bonus
		count = GetItemCount(id)
		if ( count > 0 and bonus > (lastBonus or 0) ) then
			if ( item.skillReq <= rawskill ) then
				fishingLure = id
				lastBonus = bonus
			end
		end
	end

	-- Check for and equip a fishing pole, if autoequip is enabled
	if(autoequip) then
		lastBonus = 0;
		local fishingPole = false;
		for i=1, #refPoles do
			item = refPoles[i]
			id = item.id
			bonus = item.weight
			count = GetItemCount(id)
			if ( count > 0 and bonus > (lastBonus or 0) ) then
				fishingPole = id
				lastBonus = bonus
			end
		end

		local MainHandID = GetInventoryItemID("player", INVSLOT_MAINHAND);
		if(MainHandID) then
			PLUGIN.WornItems["MAIN"] = MainHandID
		end

		local OffHandID = GetInventoryItemID("player", INVSLOT_OFFHAND);
		if(OffHandID) then
			PLUGIN.WornItems["OFF"] = OffHandID;
		end

		if(fishingPole) then
			EquipItemByName(fishingPole)
			PLUGIN.InModeGear = true
		end
	end
end

local function LootProxy(item, name)
	if(item) then
		local mask = [[0x100000]];
		local itemType = GetItemFamily(item);
		local pass = band(itemType, mask);
		if pass > 0 then
			proxyTest = true;
		end
	end
end

local function GetTitleAndSkill()
	local skillRank, skillModifier;
	local msg = "|cff22ff11Fishing Mode|r"
	local _,_,_,fishing,_,_ = GetProfessions();
	if fishing ~= nil then
		_, _, skillRank, _, _, _, _, skillModifier = GetProfessionInfo(fishing)
		if(skillModifier) then
			skillRank = skillRank + skillModifier;
		end
		msg = msg .. " (|cff00ddff" .. skillRank .. "|r)";
	end
	return msg
end
--[[
##########################################################
CORE NAMESPACE
##########################################################
]]--
PLUGIN.Fishing = {};
PLUGIN.Fishing.Log = {};
PLUGIN.Fishing.Loaded = false;
--[[
##########################################################
EVENT HANDLER
##########################################################
]]--
local EnableListener, DisableListener
do
	local FishEventHandler = CreateFrame("Frame")
	local LootProxy = function(item, name)
		if(item) then
			local mask = [[0x10000]];
			local itemType = GetItemFamily(item);
			local pass = band(itemType, mask);
			if pass > 0 then
				proxyTest = true;
			end
		end
	end

	local Fish_OnEvent = function(self, event, ...)
		if(InCombatLockdown()) then return end
		if(event == "BAG_UPDATE" or event == "CHAT_MSG_SKILL") then
			local msg = GetTitleAndSkill()
			PLUGIN.TitleWindow:Clear()
			PLUGIN.TitleWindow:AddMessage(msg)
		elseif(event == "LOOT_OPENED") then
			if IsFishingLoot() then
				proxyTest = true;
			else
				proxyTest = false;
			end
		elseif(event == "CHAT_MSG_LOOT") then
			local item, amt = PLUGIN:CheckForModeLoot(...);
			if item then
				local name, lnk, rarity, lvl, mlvl, itype, stype, cnt, ieq, tex, price = GetItemInfo(item);
				if proxyTest == false then
					LootProxy(lnk, name)
				end
				if proxyTest == false then return end
				if not PLUGIN.Fishing.Log[name] then
					PLUGIN.Fishing.Log[name] = {amount = 0, texture = ""};
				end
				local r, g, b, hex = GetItemQualityColor(rarity);
				local stored = PLUGIN.Fishing.Log
				local mod = stored[name];
				local newAmt = mod.amount + 1;
				if amt >= 2 then newAmt = mod.amount + amt end
				PLUGIN.Fishing.Log[name].amount = newAmt;
				PLUGIN.Fishing.Log[name].texture = tex;
				PLUGIN.LogWindow:Clear();

				for name,data in pairs(stored) do
					if type(data) == "table" and data.amount and data.texture then
						PLUGIN.LogWindow:AddMessage("|cff55FF55"..data.amount.." x|r |T".. data.texture ..":16:16:0:0:64:64:4:60:4:60|t".." "..name, r, g, b);
					end
				end
				PLUGIN.LogWindow:AddMessage("----------------", 0, 0, 0);
				PLUGIN.LogWindow:AddMessage("Caught So Far...", 0, 1, 1);
				PLUGIN.LogWindow:AddMessage(" ", 0, 0, 0);
				proxyTest = false;
			end
		end
	end

	function EnableListener()
		FishEventHandler:RegisterEvent("LOOT_OPENED")
		FishEventHandler:RegisterEvent("CHAT_MSG_LOOT")
		FishEventHandler:RegisterEvent("BAG_UPDATE")
		FishEventHandler:RegisterEvent("CHAT_MSG_SKILL")
		FishEventHandler:SetScript("OnEvent", Fish_OnEvent)
	end

	function DisableListener()
		FishEventHandler:UnregisterAllEvents()
		FishEventHandler:SetScript("OnEvent", nil)
	end
end
--[[
##########################################################
CORE METHODS
##########################################################
]]--
function PLUGIN.Fishing:Enable()
	PLUGIN:UpdateFishingMode()
	if(not PLUGIN.Docklet:IsShown()) then PLUGIN.Docklet.Button:Click() end
	UpdateFishingGear(CONFIGS.fishing.autoequip);
	PlaySoundFile("Sound\\Spells\\Tradeskills\\FishCast.wav")
	PLUGIN.ModeAlert:SetBackdropColor(0.25, 0.52, 0.1)
	if(not IsSpellKnown(131474)) then
		PLUGIN:ModeLootLoader("Fishing", "WTF is Fishing?", "You have no clue how to fish! \nThe last time you tried \nyou hooked yourself through the eyelid. \nGo find a trainer and learn \nhow to do this properly!");
	else
		local msg = GetTitleAndSkill();
		PLUGIN:ModeLootLoader("Fishing", msg, "Double-Right-Click anywhere on the screen \nto cast your fishing line.");
	end
	EnableListener()
	PLUGIN.ModeAlert:Show()
	SV:SCTMessage("Fishing Mode Enabled", 0.28, 0.9, 0.1);
end

function PLUGIN.Fishing:Disable()
	DisableListener()
end

function PLUGIN.Fishing:Bind()
	if InCombatLockdown() then return end
	if fishingIsKnown then
		if FishingPoleIsEquipped() then
			local hasMainHandEnchant = GetWeaponEnchantInfo()
			if hasMainHandEnchant then
				_G["SVUI_ModeCaptureWindow"]:SetAttribute("type", "spell")
				_G["SVUI_ModeCaptureWindow"]:SetAttribute('spell', fishingSpell)
				PLUGIN.ModeAlert.HelpText = 'Double-Right-Click to fish.'
			elseif(fishingLure) then
				_G["SVUI_ModeCaptureWindow"]:SetAttribute("type", "item")
				_G["SVUI_ModeCaptureWindow"]:SetAttribute("item", "item:" .. fishingLure)
				if(GetItemCooldown(fishingLure) > 0) then
					_G["SVUI_ModeCaptureWindow"]:SetAttribute("type", "spell")
					_G["SVUI_ModeCaptureWindow"]:SetAttribute('spell', fishingSpell)
					PLUGIN.ModeAlert.HelpText = 'Double-Right-Click to fish.'
				else
					PLUGIN.ModeAlert.HelpText = 'Double-Right-Click to apply fishing enchants.'
				end
			else
				_G["SVUI_ModeCaptureWindow"]:SetAttribute("type", "spell")
				_G["SVUI_ModeCaptureWindow"]:SetAttribute('spell', fishingSpell)
				PLUGIN.ModeAlert.HelpText = 'Double-Right-Click to fish.'
			end
		else
			_G["SVUI_ModeCaptureWindow"]:SetAttribute("type", "spell")
			_G["SVUI_ModeCaptureWindow"]:SetAttribute('spell', fishingSpell)
			PLUGIN.ModeAlert.HelpText = 'Double-Right-Click to fish.'
		end
		SetOverrideBindingClick(_G["SVUI_ModeCaptureWindow"], true, "BUTTON2", "SVUI_ModeCaptureWindow");
		_G["SVUI_ModeCaptureWindow"].Handler:Show();
	end
end
--[[
##########################################################
LOADER
##########################################################
]]--
function PLUGIN:UpdateFishingMode()
	fishingIsKnown = IsSpellKnown(131474);
	fishingSpell = GetSpellInfo(131474);
end

function PLUGIN:LoadFishingMode()
	CONFIGS = SV.db[self.Schema];
	self:UpdateFishingMode()
end
