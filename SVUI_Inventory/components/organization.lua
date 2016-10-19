--[[
##########################################################
S V U I   By: Failcoder
##########################################################
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local unpack  = _G.unpack;
local select  = _G.select;
local pairs   = _G.pairs;
local ipairs  = _G.ipairs;
local table   = _G.table;
local match = string.match;
--[[ TABLE METHODS ]]--
local tremove, tcopy, twipe, tsort, tcat = table.remove, table.copy, table.wipe, table.sort, table.concat;
--BLIZZARD API
local ToggleFrame           = _G.ToggleFrame;
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
local SetBagSlotFlag        = _G.SetBagSlotFlag;
local GetBagSlotFlag        = _G.GetBagSlotFlag;
local GetContainerNumSlots  = _G.GetContainerNumSlots;
local CLEAR_ALL                 = _G.CLEAR_ALL;
local FILTERS                   = _G.FILTERS;
local NUM_LE_BAG_FILTER_FLAGS   	= _G.NUM_LE_BAG_FILTER_FLAGS;
local LE_BAG_FILTER_FLAG_EQUIPMENT  = _G.LE_BAG_FILTER_FLAG_EQUIPMENT;
local BankFrameItemButton_Update        = _G.BankFrameItemButton_Update;
local BankFrameItemButton_UpdateLocked  = _G.BankFrameItemButton_UpdateLocked;
--[[
##########################################################
GET ADDON DATA
##########################################################
]]--
local SV = _G['SVUI']
local L = SV.L;
local MOD = SV.Inventory;
local TTIP = SV.Tooltip;
--[[
##########################################################
LOCAL VARS
##########################################################
]]--
local BAG_FILTER_LABELS = _G.BAG_FILTER_LABELS;
local nameKey = UnitName("player");
local realmKey = GetRealmName();
local BagFilters = _G.SVUI_BagFilterMenu;
--[[
##########################################################
LOCAL FUNCTIONS
##########################################################
]]--
local DD_OnClick = function(self)
	SetBagSlotFlag(self.BagID, self.FilterID, not GetBagSlotFlag(self.BagID, self.FilterID))
	self:GetParent():Hide()
end

local DDClear_OnClick = function(self)
	for i = LE_BAG_FILTER_FLAG_EQUIPMENT, NUM_LE_BAG_FILTER_FLAGS do
		SetBagSlotFlag(self.BagID, i, false)
	end
	self:GetParent():Hide()
end

local DD_OnEnter = function(self)
	self.hoverTex:Show()
end

local DD_OnLeave = function(self)
	self.hoverTex:Hide()
end

local SetFilterMenu = function(self)
	for i = LE_BAG_FILTER_FLAG_EQUIPMENT, NUM_LE_BAG_FILTER_FLAGS do
		if(GetBagSlotFlag(self.internalID, i)) then
			BagFilters.buttons[i].activeTex:Show()
		else
			BagFilters.buttons[i].activeTex:Hide()
		end
		BagFilters.buttons[i].BagID = self.internalID
	end

	BagFilters.buttons[NUM_LE_BAG_FILTER_FLAGS + 1].BagID = self.internalID

	local maxHeight = ((NUM_LE_BAG_FILTER_FLAGS) * 16) + 30
	local maxWidth = 135

	BagFilters:SetSize(maxWidth, maxHeight)
	BagFilters:ClearAllPoints()
	BagFilters:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -8)
	ToggleFrame(BagFilters)
end

local BagMenu_OnEnter = function(self)
	local parent = self.parent
	if(not parent) then return end
	for bagID, bag in pairs(parent.Bags) do
		local numSlots = GetContainerNumSlots(bagID)
		for slotID = 1, numSlots do
			if bag[slotID] then
				if bagID == self.internalID then
					bag[slotID]:SetAlpha(1)
				else
					bag[slotID]:SetAlpha(0.1)
				end
			end
		end
	end

	GameTooltip:AppendText(" |cff00FF11[SHIFT-CLICK] To Set Filters|r")
end

local BagMenu_OnLeave = function(self)
	local parent = self.parent
	if(not parent) then return end
	for bagID, bag in pairs(parent.Bags) do
		local numSlots = GetContainerNumSlots(bagID)
		for slotID = 1, numSlots do
			if bag[slotID] then
				bag[slotID]:SetAlpha(1)
			end
		end
	end
end

local BagMenu_OnClick = function(self)
	if IsShiftKeyDown() then
		SetFilterMenu(self);
	elseif(BagFilters:IsShown()) then
		ToggleFrame(BagFilters)
	end
end

function MOD:NewFilterMenu(bag)
	if(bag.UpdateTooltip) then
		hooksecurefunc(bag, "UpdateTooltip", BagMenu_OnEnter)
	end
	bag:HookScript("OnLeave", BagMenu_OnLeave)
	bag:HookScript("OnClick", BagMenu_OnClick)
end

function MOD:InitializeMenus()
	-- BagFilters:SetParent(SV.Screen)
	BagFilters:SetStyle("Frame", "Default")
	BagFilters.buttons = {}
	BagFilters:SetFrameStrata("DIALOG")
	BagFilters:SetClampedToScreen(true)

	for i = LE_BAG_FILTER_FLAG_EQUIPMENT, NUM_LE_BAG_FILTER_FLAGS do
		BagFilters.buttons[i] = CreateFrame("Button", nil, BagFilters)

		BagFilters.buttons[i].hoverTex = BagFilters.buttons[i]:CreateTexture(nil, 'OVERLAY')
		BagFilters.buttons[i].hoverTex:SetAllPoints()
		BagFilters.buttons[i].hoverTex:SetTexture([[Interface\AddOns\SVUI_!Core\assets\textures\TITLE-HIGHLIGHT]])
		BagFilters.buttons[i].hoverTex:SetBlendMode("ADD")
		BagFilters.buttons[i].hoverTex:Hide()

		BagFilters.buttons[i].activeTex = BagFilters.buttons[i]:CreateTexture(nil, 'OVERLAY')
		BagFilters.buttons[i].activeTex:SetAllPoints()
		BagFilters.buttons[i].activeTex:SetTexture([[Interface\AddOns\SVUI_!Core\assets\textures\TITLE-HIGHLIGHT]])
		BagFilters.buttons[i].activeTex:SetVertexColor(0,0.7,0)
		BagFilters.buttons[i].activeTex:SetBlendMode("ADD")
		BagFilters.buttons[i].activeTex:Hide()

		BagFilters.buttons[i].text = BagFilters.buttons[i]:CreateFontString(nil, 'BORDER')
		BagFilters.buttons[i].text:SetAllPoints()
		BagFilters.buttons[i].text:SetFont(SV.media.font.default,12,"OUTLINE")
		BagFilters.buttons[i].text:SetJustifyH("LEFT")
		BagFilters.buttons[i].text:SetText(BAG_FILTER_LABELS[i])

		BagFilters.buttons[i]:SetScript("OnEnter", DD_OnEnter)
		BagFilters.buttons[i]:SetScript("OnLeave", DD_OnLeave)

		BagFilters.buttons[i]:SetHeight(16)
		BagFilters.buttons[i]:SetWidth(115)

		BagFilters.buttons[i].FilterID = i
		BagFilters.buttons[i]:SetScript("OnClick", DD_OnClick)

		if i == LE_BAG_FILTER_FLAG_EQUIPMENT then
			BagFilters.buttons[i]:SetPoint("TOPLEFT", BagFilters, "TOPLEFT", 10, -10)
		else
			BagFilters.buttons[i]:SetPoint("TOPLEFT", BagFilters.buttons[i - 1], "BOTTOMLEFT", 0, 0)
		end

		BagFilters.buttons[i]:Show()
	end

	local clearID = NUM_LE_BAG_FILTER_FLAGS + 1

	BagFilters.buttons[clearID] = CreateFrame("Button", nil, BagFilters)
	BagFilters.buttons[clearID].hoverTex = BagFilters.buttons[clearID]:CreateTexture(nil, 'OVERLAY')
	BagFilters.buttons[clearID].hoverTex:SetAllPoints()
	BagFilters.buttons[clearID].hoverTex:SetTexture([[Interface\AddOns\SVUI_!Core\assets\textures\TITLE-HIGHLIGHT]])
	BagFilters.buttons[clearID].hoverTex:SetBlendMode("ADD")
	BagFilters.buttons[clearID].hoverTex:Hide()
	BagFilters.buttons[clearID].text = BagFilters.buttons[clearID]:CreateFontString(nil, 'BORDER')
	BagFilters.buttons[clearID].text:SetAllPoints()
	BagFilters.buttons[clearID].text:SetFont(SV.media.font.default,12,"OUTLINE")
	BagFilters.buttons[clearID].text:SetJustifyH("LEFT")
	BagFilters.buttons[clearID].text:SetText(CLEAR_ALL .. " " .. FILTERS)
	BagFilters.buttons[clearID]:SetScript("OnEnter", DD_OnEnter)
	BagFilters.buttons[clearID]:SetScript("OnLeave", DD_OnLeave)
	BagFilters.buttons[clearID]:SetHeight(16)
	BagFilters.buttons[clearID]:SetWidth(115)
	BagFilters.buttons[clearID].FilterID = 0
	BagFilters.buttons[clearID]:SetScript("OnClick", DDClear_OnClick)
	BagFilters.buttons[clearID]:SetPoint("TOPLEFT", BagFilters.buttons[NUM_LE_BAG_FILTER_FLAGS], "BOTTOMLEFT", 0, -10)
	BagFilters.buttons[clearID]:Show()

	BagFilters:Hide()
	SV:ManageVisibility(BagFilters)
end
--[[
##########################################################
BAG EVENTS
##########################################################
]]--
local UpdateSlot = function(self, bagID, slotID)
	if((not self.Bags[bagID]) or (self.Bags[bagID] and self.Bags[bagID].numSlots ~= GetContainerNumSlots(bagID)) or (not self.Bags[bagID][slotID])) then
		return;
	end

	self.Bags[bagID]:SlotUpdate(slotID)
end

local UpdateBagSlots = function(self, bagID)
	if(bagID and self.Bags[bagID]) then
		local maxcount = GetContainerNumSlots(bagID)
		for slotID = 1, maxcount do
			self.Bags[bagID]:SlotUpdate(slotID)
		end
		MOD:UpdateStockpile();
	end
end

local Container_OnEvent = function(self, event, ...)
	if(event == "ITEM_LOCK_CHANGED" or event == "ITEM_UNLOCKED") then
		UpdateSlot(self, ...)
	elseif(event == "BAG_UPDATE" or event == "EQUIPMENT_SETS_CHANGED") then
		SV:BuildEquipmentMap()
		for i, bagID in ipairs(self.BagIDs) do
			local numSlots = GetContainerNumSlots(bagID)
			if(not self.Bags[bagID] and numSlots ~= 0) or (self.Bags[bagID] and (numSlots ~= self.Bags[bagID].numSlots)) then
				self:UpdateLayout();
				return;
			end
		end
		UpdateBagSlots(self, ...)
	elseif(event == "BAG_UPDATE_COOLDOWN") then
		self:RefreshCooldowns()
	elseif(event == "PLAYERBANKSLOTS_CHANGED") then
		if(self.isBank and self.BagMenu) then
			for i, bagID in ipairs(self.BagIDs) do
				local bagSlot = self.BagMenu[i];
				if(bagSlot) then
					BankFrameItemButton_Update(bagSlot)
					BankFrameItemButton_UpdateLocked(bagSlot)
				end
			end
		end
		self:RefreshBags();
	elseif(event == "PLAYERREAGENTBANKSLOTS_CHANGED") then
		local slotID = ...
		local container = _G["SVUI_ReagentContainerFrame"]
		if(slotID and container) then
			local bagID = container.BagID
			container.Bags[bagID]:SlotUpdate(slotID)
		end
	end
end

function MOD:SetContainerEvents(frame)
	frame:SetScript("OnEvent", Container_OnEvent)
end
