--[[
##############################################################################
S V U I   By: Failcoder
##############################################################################
credit: Kemayo.               original logic from BankStack. Adapted to SVUI #
##############################################################################
##########################################################
LOCALIZED LUA FUNCTIONS
##########################################################
(<a href="[^0-9\"]+">)
]]--
--[[ GLOBALS ]]--
local _G = _G;
local unpack            = _G.unpack;
local select            = _G.select;
local assert            = _G.assert;
local type              = _G.type;
local error             = _G.error;
local pcall             = _G.pcall;
local print             = _G.print;
local ipairs            = _G.ipairs;
local pairs             = _G.pairs;
local next              = _G.next;
local tostring          = _G.tostring;
local tonumber          = _G.tonumber;
local collectgarbage    = _G.collectgarbage;
local tinsert 	= _G.tinsert;
local string 	= _G.string;
local math 		= _G.math;
local bit 		= _G.bit;
local table 	= _G.table;
--[[ STRING METHODS ]]--
local gmatch, gsub, match, split = string.gmatch, string.gsub, string.match, string.split;
--[[ MATH METHODS ]]--
local floor = math.floor;
--[[ BINARY METHODS ]]--
local band = bit.band;
--[[ TABLE METHODS ]]--
local tremove, tcopy, twipe, tsort = table.remove, table.copy, table.wipe, table.sort;
--BLIZZARD API
local CreateFrame           = _G.CreateFrame;
local InCombatLockdown      = _G.InCombatLockdown;
local GameTooltip           = _G.GameTooltip;
local hooksecurefunc        = _G.hooksecurefunc;
local IsAltKeyDown          = _G.IsAltKeyDown;
local IsShiftKeyDown        = _G.IsShiftKeyDown;
local IsControlKeyDown      = _G.IsControlKeyDown;
local IsModifiedClick       = _G.IsModifiedClick;
local RAID_CLASS_COLORS     = _G.RAID_CLASS_COLORS;
local CUSTOM_CLASS_COLORS   = _G.CUSTOM_CLASS_COLORS;
local C_PetJournal          = _G.C_PetJournal;
local GetTime               = _G.GetTime;
local GetContainerNumSlots  = _G.GetContainerNumSlots;
local GetGuildBankTabInfo   = _G.GetGuildBankTabInfo;
local GetItemFamily         = _G.GetItemFamily;
local GetGuildBankItemInfo  = _G.GetGuildBankItemInfo;
local GetContainerItemInfo  = _G.GetContainerItemInfo;
local GetGuildBankItemLink  = _G.GetGuildBankItemLink;
local GetContainerItemLink  = _G.GetContainerItemLink;
local GetItemInfo           = _G.GetItemInfo;
local GetItemCount          = _G.GetItemCount;
local GetItemQualityColor   = _G.GetItemQualityColor;
local GetCursorInfo         = _G.GetCursorInfo;
local PickupGuildBankItem   = _G.PickupGuildBankItem;
local PickupContainerItem   = _G.PickupContainerItem;
local QueryGuildBankTab     = _G.QueryGuildBankTab;
local GetInventoryItemLink  = _G.GetInventoryItemLink;
local SplitGuildBankItem    = _G.SplitGuildBankItem;
local SplitContainerItem    = _G.SplitContainerItem;

local ARMOR                     = _G.ARMOR;
local ENCHSLOT_WEAPON           = _G.ENCHSLOT_WEAPON;
local NUM_BAG_FRAMES            = _G.NUM_BAG_FRAMES;
local NUM_BAG_SLOTS             = _G.NUM_BAG_SLOTS;
local NUM_BANKBAGSLOTS          = _G.NUM_BANKBAGSLOTS;
local BANK_CONTAINER            = _G.BANK_CONTAINER;
local REAGENTBANK_CONTAINER     = _G.REAGENTBANK_CONTAINER;
local GetAuctionItemSubClasses  = _G.GetAuctionItemSubClasses;
local ContainerIDToInventoryID  = _G.ContainerIDToInventoryID;
local GetContainerItemID        = _G.GetContainerItemID;
local GetCurrentGuildBankTab	= _G.GetCurrentGuildBankTab;
local GetContainerNumFreeSlots  = _G.GetContainerNumFreeSlots;
--[[
##########################################################
GET ADDON DATA
##########################################################
]]--
local SV = _G['SVUI']
local L = SV.L;
local MOD = SV.Inventory;
--[[
##########################################################
LOCAL VARS
##########################################################
]]--
local WAIT_TIME = 0.05
local bagGroups = {};
local initialOrder = {};
local bagSorted = {};
local bagLocked = {};
local targetItems = {};
local sourceUsed = {};
local targetSlots = {};
local specialtyBags = {};
local emptySlots = {};
local moveRetries = 0;
local moveTracker = {};
local blackListedSlots = {};
local blackList = {};
local lastItemID, lockStop, lastDestination, lastMove, itemTypes, itemSubTypes;
local IterateBagsForSorting;
local RefEquipmentSlots = {
	INVTYPE_AMMO = 0,
	INVTYPE_HEAD = 1,
	INVTYPE_NECK = 2,
	INVTYPE_SHOULDER = 3,
	INVTYPE_BODY = 4,
	INVTYPE_CHEST = 5,
	INVTYPE_ROBE = 5,
	INVTYPE_WAIST = 6,
	INVTYPE_LEGS = 7,
	INVTYPE_FEET = 8,
	INVTYPE_WRIST = 9,
	INVTYPE_HAND = 10,
	INVTYPE_FINGER = 11,
	INVTYPE_TRINKET = 12,
	INVTYPE_CLOAK = 13,
	INVTYPE_WEAPON = 14,
	INVTYPE_SHIELD = 15,
	INVTYPE_2HWEAPON = 16,
	INVTYPE_WEAPONMAINHAND = 18,
	INVTYPE_WEAPONOFFHAND = 19,
	INVTYPE_HOLDABLE = 20,
	INVTYPE_RANGED = 21,
	INVTYPE_THROWN = 22,
	INVTYPE_RANGEDRIGHT = 23,
	INVTYPE_RELIC = 24,
	INVTYPE_TABARD = 25
}
local ItemCategories = {
	AUCTION_CATEGORY_WEAPONS,
	AUCTION_CATEGORY_ARMOR,
	AUCTION_CATEGORY_CONTAINERS,
	AUCTION_CATEGORY_CONSUMABLES,
	AUCTION_CATEGORY_ITEM_ENHANCEMENT,
	AUCTION_CATEGORY_GLYPHS,
	AUCTION_CATEGORY_TRADE_GOODS,
	AUCTION_CATEGORY_RECIPES,
	AUCTION_CATEGORY_GEMS,
	AUCTION_CATEGORY_MISCELLANEOUS,
	AUCTION_CATEGORY_QUEST_ITEMS,
	AUCTION_CATEGORY_BATTLE_PETS
}
local sortingCache = {
	[1] = {}, --BAG
	[2] = {}, --ID
	[3] = {}, --PETID
	[4] = {}, --STACK
	[5] = {}, --MAXSTACK
	[6] = {}, --MOVES
}

local scanningCache = {
	["all"] = {},
	["bags"] = {},
	["bank"] = {BANK_CONTAINER},
	["reagent"] = {REAGENTBANK_CONTAINER},
	["guild"] = {51,52,53,54,55,56,57,58},
}
do
	local cacheCount = 1;
	for i = NUM_BAG_SLOTS + 1, (NUM_BAG_SLOTS + NUM_BANKBAGSLOTS), 1 do
	  scanningCache.bank[cacheCount] = i
		cacheCount=cacheCount+1;
	end
end
do
	local cacheCount = 1;
	for i = 0, NUM_BAG_SLOTS do
	  scanningCache.bags[cacheCount] = i
		cacheCount=cacheCount+1;
	end
end
do
	local cacheCount = 1;
	for _,i in ipairs(scanningCache.bags) do
		scanningCache.all[cacheCount] = i
		cacheCount=cacheCount+1;
	end
	for _,i in ipairs(scanningCache.bank) do
		scanningCache.all[cacheCount] = i
		cacheCount=cacheCount+1;
	end
	for _,i in ipairs(scanningCache.reagent) do
		scanningCache.all[cacheCount] = i
		cacheCount=cacheCount+1;
	end
	for _,i in ipairs(scanningCache.guild) do
		scanningCache.all[cacheCount] = i
		cacheCount=cacheCount+1;
	end
end
--[[
##########################################################
SORTING UPDATES HANDLER
##########################################################
]]--
local SortUpdateTimer = CreateFrame("Frame")
SortUpdateTimer.timeLapse = 0
SortUpdateTimer:Hide()
--[[
##########################################################
HELPERS
##########################################################
]]--
local function ValidateBag(bagid)
	return (bagid == BANK_CONTAINER or ((bagid >= 0) and bagid <= (NUM_BAG_SLOTS + NUM_BANKBAGSLOTS)))
end
local function ValidateBank(bagid)
	return (bagid == BANK_CONTAINER or bagid == REAGENTBANK_CONTAINER or (bagid > NUM_BAG_SLOTS and bagid <= NUM_BANKBAGSLOTS))
end
local function ValidateGuildBank(bagid)
	return (bagid > 50 and bagid <= 58)
end
local function BagEncoder(bag, slot) return (bag * 100) + slot end
local function BagDecoder(int) return math.floor(int / 100), int % 100 end
local function MoveEncoder(source, target) return (source * 10000) + target end
local function MoveDecoder(move)
	local s = math.floor(move / 10000)
	local t = move % 10000
	s = (t > 9000) and (s + 1) or s
	t = (t > 9000) and (t - 10000) or t
	return s, t
end
--[[
##########################################################
LOCAL FUNCTIONS
##########################################################
]]--
local function SetCacheBlacklist(...)
	twipe(blackList)
	for index = 1, select('#', ...) do
		local name = select(index, ...)
		local isLink = GetItemInfo(name)
		if isLink then
			blackList[isLink] = true
		end
	end
end

local function BuildSortOrder()
	itemTypes = {}
	itemSubTypes = {}
	for i, iType in ipairs(ItemCategories) do
		itemTypes[iType] = i
		itemSubTypes[iType] = {}
		for ii, isType in ipairs({GetAuctionItemSubClasses(i)}) do
			itemSubTypes[iType][isType] = ii
		end
	end
end

local function UpdateLocation(from, to)
	if (sortingCache[2][from] == sortingCache[2][to]) and (sortingCache[4][to] < sortingCache[5][to]) then
		local stackSize = sortingCache[5][to]
		if (sortingCache[4][to] + sortingCache[4][from]) > stackSize then
			sortingCache[4][from] = sortingCache[4][from] - (stackSize - sortingCache[4][to])
			sortingCache[4][to] = stackSize
		else
			sortingCache[4][to] = sortingCache[4][to] + sortingCache[4][from]
			sortingCache[4][from] = nil
			sortingCache[2][from] = nil
			sortingCache[5][from] = nil
		end
	else
		sortingCache[2][from], sortingCache[2][to] = sortingCache[2][to], sortingCache[2][from]
		sortingCache[4][from], sortingCache[4][to] = sortingCache[4][to], sortingCache[4][from]
		sortingCache[5][from], sortingCache[5][to] = sortingCache[5][to], sortingCache[5][from]
	end
end

local function PrimarySort(a, b)
	local aName, _, _, aLvl, _, _, _, _, _, _, aPrice = GetItemInfo(sortingCache[2][a])
	local bName, _, _, bLvl, _, _, _, _, _, _, bPrice = GetItemInfo(sortingCache[2][b])
	if aLvl ~= bLvl and aLvl and bLvl then
		return aLvl > bLvl
	end
	if aPrice ~= bPrice and aPrice and bPrice then
		return aPrice > bPrice
	end
	if aName and bName then
		return aName < bName
	end
end

local function DefaultSort(b, a)
	local aID = sortingCache[2][a]
	local bID = sortingCache[2][b]
	if (not aID) or (not bID) then return aID end
	if sortingCache[3][a] and sortingCache[3][b] then
		local aName, _, aType = C_PetJournal.GetPetInfoBySpeciesID(aID);
		local bName, _, bType = C_PetJournal.GetPetInfoBySpeciesID(bID);
		if aType and bType and aType ~= bType then
			return aType > bType
		end
		if aName and bName and (type(aName) == type(bName)) and aName ~= bName then
			return aName < bName
		end
	end
	local aOrder, bOrder = initialOrder[a], initialOrder[b]
	if aID == bID then
		local aCount = sortingCache[4][a]
		local bCount = sortingCache[4][b]
		if aCount and bCount and aCount == bCount then
			return aOrder < bOrder
		elseif aCount and bCount then
			return aCount < bCount
		end
	end
	local _, _, aRarity, _, _, aType, aSubType, _, aEquipLoc = GetItemInfo(aID)
	local _, _, bRarity, _, _, bType, bSubType, _, bEquipLoc = GetItemInfo(bID)
	if sortingCache[3][a] then
		aRarity = 1
	end
	if sortingCache[3][b] then
		bRarity = 1
	end
	if aRarity ~= bRarity and aRarity and bRarity then
		return aRarity > bRarity
	end
	if itemTypes[aType] ~= itemTypes[bType] then
		return (itemTypes[aType] or 99) < (itemTypes[bType] or 99)
	end
	if aType == ARMOR or aType == ENCHSLOT_WEAPON then
		local aEquipLoc = RefEquipmentSlots[aEquipLoc] or -1
		local bEquipLoc = RefEquipmentSlots[bEquipLoc] or -1
		if aEquipLoc == bEquipLoc then
			return PrimarySort(a, b)
		end
		if aEquipLoc and bEquipLoc then
			return aEquipLoc < bEquipLoc
		end
	end
	if aSubType == bSubType then
		return PrimarySort(a, b)
	end
	return ((itemSubTypes[aType] or {})[aSubType] or 99) < ((itemSubTypes[bType] or {})[bSubType] or 99)
end

local function ReverseSort(a, b)
	return DefaultSort(b, a)
end

local function ConvertLinkToID(link)
	if not link then return; end
	if tonumber(match(link, "item:(%d+)")) then
		return tonumber(match(link, "item:(%d+)"));
	else
		return tonumber(match(link, "battlepet:(%d+)")), true;
	end
end

local function GetSortingGroup(id)
	if match(id, "^[-%d,]+$") then
		local bags = {}
		local count = 1;
		for b in gmatch(id, "-?%d+") do
			bags[count] = tonumber(b);
			count=count+1;
		end
		return bags
	end
	return scanningCache[id]
end

local function GetSortingInfo(bag, slot)
	if (ValidateGuildBank(bag)) then
		return GetGuildBankItemInfo(bag - 50, slot)
	else
		return GetContainerItemInfo(bag, slot)
	end
end

local function GetSortingItemLink(bag, slot)
	if (ValidateGuildBank(bag)) then
		return GetGuildBankItemLink(bag - 50, slot)
	else
		return GetContainerItemLink(bag, slot)
	end
end
--[[
##########################################################
BAG ITERATION METHOD
##########################################################
]]--
do
	local bagRole;

	local function GetNumSortingSlots(bag, role)
		if (ValidateGuildBank(bag)) then
			if not role then role = "deposit" end
			local name, icon, canView, canDeposit, numWithdrawals = GetGuildBankTabInfo(bag - 50)
			if name and canView then
				return 98
			end
		else
			return GetContainerNumSlots(bag)
		end
		return 0
	end

	local function IterateForwards(bagList, i)
		i = i + 1
		local step = 1
		for _,bag in ipairs(bagList) do
			local slots = GetNumSortingSlots(bag, bagRole)
			if i > slots + step then
				step = step + slots
			else
				for slot = 1, slots do
					if step == i then
						return i, bag, slot
					end
					step = step + 1
				end
			end
		end
		bagRole = nil
	end

	local function IterateBackwards(bagList, i)
		i = i + 1
		local step = 1
		for ii = #bagList, 1, -1 do
			local bag = bagList[ii]
			local slots = GetNumSortingSlots(bag, bagRole)
			if i > slots + step then
				step = step + slots
			else
				for slot=slots, 1, -1 do
					if step == i then
						return i, bag, slot
					end
					step = step + 1
				end
			end
		end
		bagRole = nil
	end

	function IterateBagsForSorting(bagList, reverse, role)
		bagRole = role
		return (reverse and IterateBackwards or IterateForwards), bagList, 0
	end
end
--[[
##########################################################
CORE FUNCTIONS
##########################################################
]]--
-- function MOD.Compress(...)
-- 	for i=1, select("#", ...) do
-- 		local bags = select(i, ...)
-- 		MOD.Stack(bags, bags, MOD.IsPartial)
-- 	end
-- end

-- function MOD.Organizer(fnType, sourceBags, targetBags)
-- 	if(fnType == 'stack') then
-- 		MOD.Stack(sourceBags, targetBags, MOD.IsPartial)
-- 	elseif(fnType == 'move') then
-- 		MOD.Stack(sourceBags, targetBags, MOD.IsPartial)
-- 	else
-- 		MOD.Sort()
-- 	end
-- end
--[[
##########################################################
EXTERNAL SORTING CALLS
##########################################################
]]--
do
	local function SetSortingPath(source, target)
		UpdateLocation(source, target)
		local move=MoveEncoder(source, target);
		tinsert(sortingCache[6], 1, move)
	end

	local function IsPartial(bag, slot)
		local bagSlot = BagEncoder(bag, slot)
		return ((sortingCache[5][bagSlot] or 0) - (sortingCache[4][bagSlot] or 0)) > 0
	end

	local function IsSpecialtyBag(bagID)
		if(bagID == 0 or (ValidateBank(bagID)) or (ValidateGuildBank(bagID))) then return false end
		local inventorySlot = ContainerIDToInventoryID(bagID)
		if not inventorySlot then return false end
		local bag = GetInventoryItemLink("player", inventorySlot)
		if not bag then return false end
		local family = GetItemFamily(bag)
		if family == 0 or family == nil then return false end
		return family
	end

	local function CanItemGoInBag(bag, slot, targetBag)
		if (ValidateGuildBank(targetBag)) then return true end
		local item = sortingCache[2][(BagEncoder(bag, slot))]
		local itemFamily = GetItemFamily(item)
		if itemFamily and itemFamily > 0 then
			local equipSlot = select(9, GetItemInfo(item))
			if equipSlot == "INVTYPE_BAG" then
				itemFamily = 1
			end
		end
		local bagFamily = select(2, GetContainerNumFreeSlots(targetBag))
		if itemFamily then
			return (bagFamily == 0) or band(itemFamily, bagFamily) > 0
		else
			return false;
		end
	end

	local function ShouldMove(source, destination)
		if((destination == source) or (not sortingCache[2][source])) then return; end
		if((sortingCache[2][source] == sortingCache[2][destination]) and (sortingCache[4][source] == sortingCache[4][destination])) then return; end
		return true
	end

	local function UpdateSorted(source, destination)
		for i, bs in pairs(bagSorted) do
			if bs == source then
				bagSorted[i] = destination
			elseif bs == destination then
				bagSorted[i] = source
			end
		end
	end

	local function Sorter(bags, sorter, reverse)
		if not sorter then sorter = reverse and ReverseSort or DefaultSort end
		if not itemTypes then BuildSortOrder() end
		twipe(blackListedSlots)
		local ignoreItems = SV.db.Inventory.ignoreItems
		ignoreItems = ignoreItems:gsub(',%s', ',')
		SetCacheBlacklist(split(",", ignoreItems))
		for i, bag, slot in IterateBagsForSorting(bags, nil, 'both') do
			local bagSlot = BagEncoder(bag, slot)
			local link = GetSortingItemLink(bag, slot);
			if link and blackList[GetItemInfo(link)] then
				blackListedSlots[bagSlot] = true
			end
			if not blackListedSlots[bagSlot] then
				initialOrder[bagSlot] = i
				tinsert(bagSorted, bagSlot)
			end
		end
		tsort(bagSorted, sorter)
		local passNeeded = true
		while passNeeded do
			passNeeded = false
			local i = 1
			for _, bag, slot in IterateBagsForSorting(bags, nil, 'both') do
				local destination = BagEncoder(bag, slot)
				local source = bagSorted[i]
				if not blackListedSlots[destination] then
					if(ShouldMove(source, destination)) then
						if not (bagLocked[source] or bagLocked[destination]) then
							SetSortingPath(source, destination)
							UpdateSorted(source, destination)
							bagLocked[source] = true
							bagLocked[destination] = true
						else
							passNeeded = true
						end
					end
					i = i + 1
				end
			end
			twipe(bagLocked)
		end
		twipe(bagSorted)
		twipe(initialOrder)
	end

	local function SortFiller(sourceBags, targetBags, reverse, canMove)
		if not canMove then canMove = true end
		for _, bag, slot in IterateBagsForSorting(targetBags, reverse, "deposit") do
			local bagSlot = BagEncoder(bag, slot)
			if not sortingCache[2][bagSlot] then
				tinsert(emptySlots, bagSlot)
			end
		end
		for _, bag, slot in IterateBagsForSorting(sourceBags, not reverse, "withdraw") do
			if #emptySlots == 0 then break end
			local bagSlot = BagEncoder(bag, slot)
			local targetBag, targetSlot = BagDecoder(emptySlots[1])
			if sortingCache[2][bagSlot] and CanItemGoInBag(bag, slot, targetBag) and (canMove == true or canMove(sortingCache[2][bagSlot], bag, slot)) then
				SetSortingPath(bagSlot, tremove(emptySlots, 1))
			end
		end
		twipe(emptySlots)
	end

	function MOD.Sort(...)
		for i=1, select("#", ...) do
			local bags = select(i, ...)
			for _, slotNum in ipairs(bags) do
				local bagType = IsSpecialtyBag(slotNum)
				if bagType == false then bagType = 'Normal' end
				if not sortingCache[1][bagType] then sortingCache[1][bagType] = {} end
				tinsert(sortingCache[1][bagType], slotNum)
			end
			for bagType, sortedBags in pairs(sortingCache[1]) do
				if bagType ~= 'Normal' then
					MOD.Stack(sortedBags, IsPartial)
					SortFiller(sortingCache[1]['Normal'], sortedBags, SV.db.Inventory.sortInverted)
					MOD.Stack(sortingCache[1]['Normal'], IsPartial)
					Sorter(sortedBags, nil, SV.db.Inventory.sortInverted)
					twipe(sortedBags)
				end
			end
			if sortingCache[1]['Normal'] then
				MOD.Stack(sortingCache[1]['Normal'], IsPartial)
				Sorter(sortingCache[1]['Normal'], nil, SV.db.Inventory.sortInverted)
				twipe(sortingCache[1]['Normal'])
			end
			twipe(sortingCache[1])
			twipe(bagGroups)
		end
	end

	function MOD.Transfer(sourceBags, targetBags, canMove)
		if not canMove then canMove = true end
		for _, bag, slot in IterateBagsForSorting(targetBags, nil, "deposit") do
			local bagSlot = BagEncoder(bag, slot)
			local itemID = sortingCache[2][bagSlot]
			if itemID and (sortingCache[4][bagSlot] ~= sortingCache[5][bagSlot]) then
				targetItems[itemID] = (targetItems[itemID] or 0) + 1
				tinsert(targetSlots, bagSlot)
			end
		end

		for _, bag, slot in IterateBagsForSorting(sourceBags, true, "withdraw") do
			local sourceSlot = BagEncoder(bag, slot)
			local itemID = sortingCache[2][sourceSlot]
			if itemID and targetItems[itemID] and (canMove == true or canMove(itemID, bag, slot)) then
				for i = #targetSlots, 1, -1 do
					local targetedSlot = targetSlots[i]
					if sortingCache[2][sourceSlot] and sortingCache[2][targetedSlot] == itemID and targetedSlot ~= sourceSlot and not (sortingCache[4][targetedSlot] == sortingCache[5][targetedSlot]) and not sourceUsed[targetedSlot] then
						SetSortingPath(sourceSlot, targetedSlot)
						sourceUsed[sourceSlot] = true
						if sortingCache[4][targetedSlot] == sortingCache[5][targetedSlot] then
							targetItems[itemID] = (targetItems[itemID] > 1) and (targetItems[itemID] - 1) or nil
						end
						if sortingCache[4][sourceSlot] == 0 then
							targetItems[itemID] = (targetItems[itemID] > 1) and (targetItems[itemID] - 1) or nil
							break
						end
						if not targetItems[itemID] then break end
					end
				end
			end
		end
		twipe(targetItems)
		twipe(targetSlots)
		twipe(sourceUsed)
	end

	function MOD.Stack(bags, canMove)
		if not canMove then canMove = true end
		for _, bag, slot in IterateBagsForSorting(bags, nil, "deposit") do
			local bagSlot = BagEncoder(bag, slot)
			local itemID = sortingCache[2][bagSlot]
			if itemID and (sortingCache[4][bagSlot] ~= sortingCache[5][bagSlot]) then
				targetItems[itemID] = (targetItems[itemID] or 0) + 1
				tinsert(targetSlots, bagSlot)
			end
		end

		for _, bag, slot in IterateBagsForSorting(bags, true, "withdraw") do
			local sourceSlot = BagEncoder(bag, slot)
			local itemID = sortingCache[2][sourceSlot]
			if itemID and targetItems[itemID] and (canMove == true or (type(canMove) == "function" and canMove(itemID, bag, slot))) then
				for i = #targetSlots, 1, -1 do
					local targetedSlot = targetSlots[i]
					if sortingCache[2][sourceSlot] and sortingCache[2][targetedSlot] == itemID and targetedSlot ~= sourceSlot and not (sortingCache[4][targetedSlot] == sortingCache[5][targetedSlot]) and not sourceUsed[targetedSlot] then
						SetSortingPath(sourceSlot, targetedSlot)
						sourceUsed[sourceSlot] = true
						if sortingCache[4][targetedSlot] == sortingCache[5][targetedSlot] then
							targetItems[itemID] = (targetItems[itemID] > 1) and (targetItems[itemID] - 1) or nil
						end
						if sortingCache[4][sourceSlot] == 0 then
							targetItems[itemID] = (targetItems[itemID] > 1) and (targetItems[itemID] - 1) or nil
							break
						end
						if not targetItems[itemID] then break end
					end
				end
			end
		end
		twipe(targetItems)
		twipe(targetSlots)
		twipe(sourceUsed)
	end
end
--[[
##########################################################
INTERNAL SORTING CALLS
##########################################################
]]--
do
	local function GetSortingItemID(bag, slot)
		if (ValidateGuildBank(bag)) then
			local link = GetSortingItemLink(bag, slot)
			return link and tonumber(string.match(link, "item:(%d+)"))
		else
			return GetContainerItemID(bag, slot)
		end
	end

	function SortUpdateTimer:StopStacking(message)
		twipe(sortingCache[6])
		twipe(moveTracker)
		moveRetries, lastItemID, lockStop, lastDestination, lastMove = 0, nil, nil, nil, nil
		self:SetScript("OnUpdate", nil)
		self:Hide()
		if(message) then
			SV:SCTMessage(message, 1, 0.35, 0)
		end
	end

	function SortUpdateTimer:MoveItem(move)
		if GetCursorInfo() == "item" then
			return false, 'cursorhasitem'
		end
		local source, target = MoveDecoder(move)
		local sourceBag, sourceSlot = BagDecoder(source)
		local targetBag, targetSlot = BagDecoder(target)
		local _, sourceCount, sourceLocked = GetSortingInfo(sourceBag, sourceSlot)
		local _, targetCount, targetLocked = GetSortingInfo(targetBag, targetSlot)
		if sourceLocked or targetLocked then
			return false, 'source/target_locked'
		end
		local sourceLink = GetSortingItemLink(sourceBag, sourceSlot)
		local sourceItemID = GetSortingItemID(sourceBag, sourceSlot)
		local targetItemID = GetSortingItemID(targetBag, targetSlot)

		if not sourceItemID then
			if moveTracker[source] then
				return false, 'move incomplete'
			else
				return self:StopStacking(L['Confused.. Try Again!'])
			end
		end

		local stackSize = select(8, GetItemInfo(sourceItemID))

		local sourceGuild = ValidateGuildBank(sourceBag)
		local targetGuild = ValidateGuildBank(targetBag)

		if (sourceItemID == targetItemID) and (targetCount ~= stackSize) and ((targetCount + sourceCount) > stackSize) then
			local amount = (stackSize - targetCount)
			if (sourceGuild) then
				SplitGuildBankItem(sourceBag - 50, sourceSlot, amount)
			else
				SplitContainerItem(sourceBag, sourceSlot, amount)
			end
		else
			if (sourceGuild) then
				PickupGuildBankItem(sourceBag - 50, sourceSlot)
			else
				PickupContainerItem(sourceBag, sourceSlot)
			end
		end

		if GetCursorInfo() == "item" then
			if (targetGuild) then
				PickupGuildBankItem(targetBag - 50, targetSlot)
			else
				PickupContainerItem(targetBag, targetSlot)
			end
		end

		if sourceGuild then
			QueryGuildBankTab(sourceBag - 50)
		end
		if targetGuild then
			QueryGuildBankTab(targetBag - 50)
		end
		return true, sourceItemID, source, targetItemID, target, sourceGuild or targetGuild
	end

	local SortUpdateTimer_OnUpdate = function(self, elapsed)
		self.timeLapse = self.timeLapse + (elapsed or 0.01)
		if(self.timeLapse > 0.05) then
			self.timeLapse = 0
			if InCombatLockdown() then
				return self:StopStacking(L["Can't Clean Bags in Combat!"])
			end
			local cursorType, cursorItemID = GetCursorInfo()
			if cursorType == "item" and cursorItemID then
				if lastItemID ~= cursorItemID then
					return self:StopStacking(L["Bag Cleaning Error, Try Again"])
				end
				if moveRetries < 100 then
					local targetBag, targetSlot = BagDecoder(lastDestination)
					local _, _, targetLocked = GetSortingInfo(targetBag, targetSlot)
					if not targetLocked then
						if(ValidateGuildBank(targetBag)) then
							PickupGuildBankItem(targetBag - 50, targetSlot)
						else
							PickupContainerItem(targetBag, targetSlot)
						end
						WAIT_TIME = 0.1
						lockStop = GetTime()
						moveRetries = moveRetries + 1
						return
					end
				end
			end
			if lockStop then
				local i = 1;
				for slot, itemID in pairs(moveTracker) do
					local sourceBag, sourceSlot = BagDecoder(slot)
					local actualItemID = GetSortingItemID(sourceBag, sourceSlot)
					if actualItemID ~= itemID then
						WAIT_TIME = 0.1
						if (GetTime() - lockStop) > 1.25 then
							if lastMove and moveRetries < 100 then
								local success, moveID, moveSource, targetID, moveTarget, wasGuild = self:MoveItem(lastMove)
								WAIT_TIME = wasGuild and 0.5 or 0.1
								if not success then
									lockStop = GetTime()
									moveRetries = moveRetries + 1
									return
								end
								moveTracker[moveSource] = targetID
								moveTracker[moveTarget] = moveID
								lastDestination = moveTarget
								lastMove = sortingCache[6][i]
								lastItemID = moveID
								tremove(sortingCache[6], i)
								return
							end
							self:StopStacking()
							return
						end
						return
					end
					moveTracker[slot] = nil
					i = i + 1;
				end
			end
			lastItemID, lockStop, lastDestination, lastMove = nil, nil, nil, nil
			twipe(moveTracker)
			local start, success, moveID, targetID, moveSource, moveTarget, wasGuild
			start = GetTime()
			if #sortingCache[6] > 0 then
				for i = #sortingCache[6], 1, -1 do
					success, moveID, moveSource, targetID, moveTarget, wasGuild = self:MoveItem(sortingCache[6][i])
					if not success then
						WAIT_TIME = wasGuild and 0.3 or 0.1
						lockStop = GetTime()
						return
					end
					moveTracker[moveSource] = targetID
					moveTracker[moveTarget] = moveID
					lastDestination = moveTarget
					lastMove = sortingCache[6][i]
					lastItemID = moveID
					tremove(sortingCache[6], i)
					if sortingCache[6][i-1] then
						WAIT_TIME = wasGuild and 0.3 or 0;
						return
					end
				end
			end
			self:StopStacking()
		end
	end

	function SortUpdateTimer:StartStacking()
		twipe(sortingCache[5])
		twipe(sortingCache[4])
		twipe(sortingCache[2])
		twipe(moveTracker)
		if #sortingCache[6] > 0 then
			self:Show()
			self:SetScript("OnUpdate", SortUpdateTimer_OnUpdate)
		else
			self:StopStacking()
		end
	end
end

function MOD:RunSortingProcess(func, groupsDefaults, altFunc)
	local bagGroups = {}
	return function(groups)
		if(altFunc and IsShiftKeyDown()) then
			PlaySound(SOUNDKIT.UI_BAG_SORTING_01);
			altFunc()
		else
			if SortUpdateTimer:IsShown() then
				SortUpdateTimer:StopStacking(L['Already Running.. Bailing Out!'])
				return;
			end
			twipe(bagGroups)
			if not groups or #groups == 0 then
				groups = groupsDefaults
			end
			for bags in (groups or ""):gmatch("[^%s]+") do
				if bags == "guild" then
					bags = GetSortingGroup(bags)
					if bags then
						tinsert(bagGroups, {bags[GetCurrentGuildBankTab()]})
					end
				else
					bags = GetSortingGroup(bags)
					if bags then
						tinsert(bagGroups, bags)
					end
				end
			end
			for _, bag, slot in IterateBagsForSorting(scanningCache.all) do
				local bagSlot = BagEncoder(bag, slot)
				local itemID, isBattlePet = ConvertLinkToID(GetSortingItemLink(bag, slot))
				if itemID then
					if isBattlePet then
						sortingCache[3][bagSlot] = itemID
						sortingCache[5][bagSlot] = 1
					else
						sortingCache[5][bagSlot] = select(8, GetItemInfo(itemID))
					end
					sortingCache[2][bagSlot] = itemID
					sortingCache[4][bagSlot] = select(2, GetSortingInfo(bag, slot))
				end
			end
			if func(unpack(bagGroups)) == false then
				return
			end
			twipe(bagGroups)
			SortUpdateTimer:StartStacking()
		end
		collectgarbage("collect")
	end
end
