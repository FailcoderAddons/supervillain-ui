--[[
##########################################################
S V U I  By: Failcoder
##########################################################
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local unpack 	= _G.unpack;
local select 	= _G.select;
local pairs 	= _G.pairs;
local ipairs 	= _G.ipairs;
local type 		= _G.type;
local tinsert 	= _G.tinsert;
local string 	= _G.string;
local math 		= _G.math;
local table 	= _G.table;
--[[ STRING METHODS ]]--
local find, format, len = string.find, string.format, string.len;
local sub, byte = string.sub, string.byte;
--[[ MATH METHODS ]]--
local floor, ceil, abs = math.floor, math.ceil, math.abs;
local twipe = table.wipe;
--BLIZZARD API
local UnitName   			= _G.UnitName;
local CreateFrame           = _G.CreateFrame;
local PlaySoundFile 		= _G.PlaySoundFile;
local GameTooltip 			= _G.GameTooltip;
local InCombatLockdown      = _G.InCombatLockdown;
local hooksecurefunc        = _G.hooksecurefunc;

local SVUI_Font_Default 	= _G.SVUI_Font_Default;
local SVUI_Font_Header 		= _G.SVUI_Font_Header;
local SVUI_Font_Bag 		= _G.SVUI_Font_Bag;
local SVUI_Font_Bag_Number 	= _G.SVUI_Font_Bag_Number;

local BagFilters = _G.SVUI_BagFilterMenu;
local BagBar = _G.SVUI_BagBar;
--[[
##########################################################
GET ADDON DATA
##########################################################
]]--
local SV = _G['SVUI']
local L = SV.L;
local MOD = SV.Inventory;
if(not MOD) then return end;
--[[
##########################################################
LOCAL VARS
##########################################################
]]--
local nameKey = UnitName("player");
local realmKey = GetRealmName();
local toonClass = select(2,UnitClass("player"));
local DEBUG_BAGS = false;
local CreateFrame = _G.CreateFrame;
local hooksecurefunc = _G.hooksecurefunc;
local numBagFrame = NUM_BAG_FRAMES + 1;
local MULTI_BAG_LAYOUT = false;
local MULTI_BAG_HEIGHT_OFFSET = 0;
local LOOT_CACHE, GEAR_CACHE, GEARSET_LISTING = {}, {}, {};
local internalTimer;
local RefProfessionColors = {
	[0x0008] = {224/255,187/255,74/255},
	[0x0010] = {74/255,77/255,224/255},
	[0x0020] = {18/255,181/255,32/255},
	[0x0040] = {160/255,3/255,168/255},
	[0x0080] = {232/255,118/255,46/255},
	[0x0200] = {8/255,180/255,207/255},
	[0x0400] = {105/255,79/255,7/255},
	[0x10000] = {222/255,13/255,65/255},
	[0x100000] = {18/255,224/255,180/255}
}
--[[
##########################################################
LOCAL FUNCTIONS
##########################################################
]]--
local goldFormat = "%s|TInterface\\MONEYFRAME\\UI-GoldIcon.blp:16:16|t"

function MOD:UpdateStockpile()
	local journal = self.public[realmKey]["loot"][nameKey]
	for id,amt in pairs(journal) do
		if(not LOOT_CACHE[id]) then
			LOOT_CACHE[id] = {}
		end
		local starting = 0;
		LOOT_CACHE[id][nameKey] = (starting + amt)
	end
end

local function FormatCurrency(amount)
	if not amount then return end
	local gold = floor(abs(amount/10000))
	if gold ~= 0 then
		gold = BreakUpLargeNumbers(gold)
		return goldFormat:format(gold)
	end
end

local function StyleBagToolButton(button, iconTex)
	if button.styled then return end

	local bg = button:CreateTexture(nil, "BACKGROUND")
	bg:WrapPoints(button, 4, 4)
	bg:SetTexture(SV.media.button.roundbg)
	bg:SetVertexColor(unpack(SV.media.color.default))

	local outer = button:CreateTexture(nil, "OVERLAY")
	outer:WrapPoints(button, 5, 5)
	outer:SetTexture(SV.media.button.round)
	outer:SetGradient(unpack(SV.media.gradient.special))

	button:SetNormalTexture(iconTex)
	iconTex = button:GetNormalTexture()
	iconTex:SetGradient(unpack(SV.media.gradient.medium))

	local icon = button:CreateTexture(nil, "OVERLAY")
	icon:WrapPoints(button, 5, 5)
	SetPortraitToTexture(icon, iconTex)
	hooksecurefunc(icon, "SetTexture", SetPortraitToTexture)

	local hover = button:CreateTexture(nil, "HIGHLIGHT")
	hover:WrapPoints(button, 5, 5)
	hover:SetTexture(SV.media.button.round)
	hover:SetGradient(unpack(SV.media.gradient.yellow))

	if button.SetPushedTexture then
		local pushed = button:CreateTexture(nil, "BORDER")
		pushed:WrapPoints(button, 5, 5)
		pushed:SetTexture(SV.media.button.round)
		pushed:SetGradient(unpack(SV.media.gradient.highlight))
		button:SetPushedTexture(pushed)
	end

	if button.SetCheckedTexture then
		local checked = button:CreateTexture(nil, "BORDER")
		checked:WrapPoints(button, 5, 5)
		checked:SetTexture(SV.media.button.round)
		checked:SetGradient(unpack(SV.media.gradient.green))
		button:SetCheckedTexture(checked)
	end

	if button.SetDisabledTexture then
		local disabled = button:CreateTexture(nil, "BORDER")
		disabled:WrapPoints(button, 5, 5)
		disabled:SetTexture(SV.media.button.round)
		disabled:SetGradient(unpack(SV.media.gradient.default))
		button:SetDisabledTexture(disabled)
	end

	local cd = button:GetName() and _G[button:GetName().."Cooldown"]
	if cd then
		cd:ClearAllPoints()
		cd:InsetPoints()
	end
	button.styled = true
end
--[[
##########################################################
CORE FUNCTIONS
##########################################################
]]--
local function SearchInBags(frame)
	if((not frame) or (not frame.BagIDs) or (not frame:IsShown())) then return end
	for _, bagID in ipairs(frame.BagIDs) do
		local container = frame.Bags[bagID];
		if(container) then
			for i = 1, GetContainerNumSlots(bagID) do
				local _, _, _, _, _, _, _, isFiltered = GetContainerItemInfo(bagID, i)
				local item = container[i]
				if(item and item:IsShown()) then
					if isFiltered then
						SetItemButtonDesaturated(item, 1)
						item:SetAlpha(0.4)
					else
						SetItemButtonDesaturated(item)
						item:SetAlpha(1)
					end
				end
			end
		end
	end
end

function MOD:INVENTORY_SEARCH_UPDATE()
	SearchInBags(self.MasterFrame)
	SearchInBags(self.BankFrame)
	SearchInBags(self.ReagentFrame)
end

local SlotUpdate = function(self, slotID)
	if(not self[slotID]) then return end
	local bagID = self:GetID();
	local slot = self[slotID];
	local bagType = self.bagFamily;

	slot:Show()

	local texture, count, locked = GetContainerItemInfo(bagID, slotID);
	local start, duration, enable = GetContainerItemCooldown(bagID, slotID);
	local isQuestItem, questId, isActiveQuest = GetContainerItemQuestInfo(bagID, slotID);
	local itemLink = GetContainerItemLink(bagID, slotID);
	local key, _, quality, _, _, _, _, _, equipSlot

	local itemID = GetContainerItemID(bagID, slotID);
	if(itemID and MOD.private.junk[itemID]) then
		slot.JunkIcon:Show()
	else
		slot.JunkIcon:Hide()
	end

	local r,g,b = 0,0,0
	slot.HasQuestItem = nil
	if(questId and (not isActiveQuest)) then
		r,g,b = 1,0.3,0.3
		slot.questIcon:Show();
		slot.HasQuestItem = true;
	elseif(questId or isQuestItem) then
		r,g,b = 1,0.3,0.3
		slot.questIcon:Hide();
		slot.HasQuestItem = true;
	else
		slot.questIcon:Hide();
		if(itemLink) then
			key, _, quality, _, _, _, _, _, equipSlot = GetItemInfo(itemLink)
			if(key) then
				local journal = MOD.public[realmKey]["loot"][nameKey]
				local id = GetContainerItemID(bagID, slotID)
				if id ~= 6948 then
					journal[key] = GetItemCount(id,true)
				end
			end

			if(quality) then
				if(quality > 1) then
					r,g,b = GetItemQualityColor(quality)
				elseif(quality == 0) then
					slot.JunkIcon:Show()
				end
			end
		end
		if(bagType) then
			r,g,b = bagType[1],bagType[2],bagType[3]
		end
	end

	slot:SetBackdropColor(r,g,b,0.6)
	slot:SetBackdropBorderColor(r,g,b,1)

	CooldownFrame_Set(slot.cooldown, start, duration, enable);

	if((duration > 0) and (enable == 0)) then
		SetItemButtonTextureVertexColor(slot, 0.4, 0.4, 0.4)
	else
		SetItemButtonTextureVertexColor(slot, 1, 1, 1)
	end

	if(C_NewItems.IsNewItem(bagID, slotID)) then
		C_NewItems.RemoveNewItem(bagID, slotID)
	end

	if(slot.NewItemTexture) then slot.NewItemTexture:Hide() end;
	if(slot.flashAnim) then slot.flashAnim:Stop() end;
    if(slot.newitemglowAnim) then slot.newitemglowAnim:Stop() end;
    
	SetItemButtonTexture(slot, texture)
	SetItemButtonCount(slot, count)
	SetItemButtonDesaturated(slot, locked, 0.5, 0.5, 0.5)

	SV:SetGearLabels(slot, bagID, slotID, itemLink, quality, equipSlot)
end

local ContainerFrame_RefreshSlots = function(self)
	local bagID = self:GetID()
	if(not bagID) then return end
	local maxcount = GetContainerNumSlots(bagID)
	for slotID = 1, maxcount do
		self:SlotUpdate(slotID)
	end
end

local ContainerFrame_UpdateCooldowns = function(self)
	if self.isReagent then return end
	for _, bagID in ipairs(self.BagIDs) do
		if self.Bags[bagID] then
			for slotID = 1, GetContainerNumSlots(bagID)do
				local start, duration, enable = GetContainerItemCooldown(bagID, slotID)
				if(self.Bags[bagID][slotID]) then
					CooldownFrame_Set(self.Bags[bagID][slotID].cooldown, start, duration, enable)
					if duration > 0 and enable == 0 then
						SetItemButtonTextureVertexColor(self.Bags[bagID][slotID], 0.4, 0.4, 0.4)
					else
						SetItemButtonTextureVertexColor(self.Bags[bagID][slotID], 1, 1, 1)
					end
				end
			end
		end
	end
end

local ContainerFrame_UpdateBags = function(self)
	for _, bagID in ipairs(self.BagIDs) do
		if self.Bags[bagID] then
			self.Bags[bagID]:RefreshSlots();
		end
	end
	MOD:UpdateStockpile()
end

local ContainerFrame_UpdateLayout = function(self)
	local isBank = self.isBank
	local containerName = self:GetName()
	local buttonSpacing = 8;
	local containerWidth, numContainerColumns, buttonSize
	local precount = 0;
	for i, bagID in ipairs(self.BagIDs) do
		if((not SV.db.Inventory.separateBags) or (isBank or (bagID > 0))) then
			local numSlots = GetContainerNumSlots(bagID);
			precount = precount + (numSlots or 0);
		end
	end

	if(SV.db.Inventory.alignToChat) then
		containerWidth = (isBank and SV.db.Dock.dockLeftWidth or SV.db.Dock.dockRightWidth)
		local avg = 0.08;
		if(precount > 287) then
			avg = 0.12
		elseif(precount > 167) then
			avg = 0.11
		elseif(precount > 127) then
			avg = 0.1
		elseif(precount > 97) then
			avg = 0.09
		end

		numContainerColumns = avg * 100;

		local unitSize = floor(containerWidth / numContainerColumns)
		buttonSize = unitSize - buttonSpacing;
	else
		containerWidth = (isBank and SV.db.Inventory.bankWidth) or SV.db.Inventory.bagWidth
		buttonSize = isBank and SV.db.Inventory.bankSize or SV.db.Inventory.bagSize;
		numContainerColumns = floor(containerWidth / (buttonSize + buttonSpacing));
	end

	local numContainerRows = ceil(precount / numContainerColumns)
	local containerHeight = (((buttonSize + buttonSpacing) * numContainerRows) - buttonSpacing) + self.topOffset + self.bottomOffset;
	local holderWidth = ((buttonSize + buttonSpacing) * numContainerColumns) - buttonSpacing;
	local bottomPadding = (containerWidth - holderWidth) * 0.5;
	local lastButton, lastRowButton, globalName;
	local numContainerSlots, fullContainerSlots = GetNumBankSlots();
	local totalSlots = 0;

	if(SV.db.Inventory.separateBags) then
		local bpCount = GetContainerNumSlots(0);
		local bpRows = ceil(bpCount / numContainerColumns);
		containerHeight = (((buttonSize + buttonSpacing) * bpRows) - buttonSpacing) + self.topOffset + self.bottomOffset;
	end

	self.ButtonSize = buttonSize;
	self.holderFrame:SetWidth(holderWidth);

	local menu = self.BagMenu;
	local lastMenu;
	for i, bagID in ipairs(self.BagIDs) do
		if((not isBank and bagID <= 3) or (isBank and bagID ~= -1 and numContainerSlots >= 1 and not (i - 1 > numContainerSlots))) then
			local menuWidth = ((buttonSize + buttonSpacing) * (isBank and i - 1 or i)) + buttonSpacing;
			local menuHeight = buttonSize + (buttonSpacing * 2);
			menu:SetSize(menuWidth, menuHeight)
			local bagSlot = menu[i];

			if(not bagSlot) then
				local globalName, bagTemplate;
				if isBank then
					globalName = "SVUI_BankBag" .. bagID - 4;
					bagTemplate = "BankItemButtonBagTemplate";
				else
					globalName = "SVUI_MainBag" .. bagID .. "Slot";
					bagTemplate = "BagSlotButtonTemplate";
				end
				bagSlot = CreateFrame("ItemButton", globalName, menu, bagTemplate)
				bagSlot.parent = self;

				bagSlot:SetNormalTexture("")
				bagSlot:SetPushedTexture("")
				bagSlot:RemoveTextures()
				bagSlot:SetStyle("!_ActionSlot");

				if(not bagSlot.icon) then
					bagSlot.icon = bagSlot:CreateTexture(nil, "BORDER");
				end
				bagSlot.icon:InsetPoints()
				bagSlot.icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))

				if(not bagSlot.tooltipText) then
					bagSlot.tooltipText = ""
				end

				if(isBank) then
					bagSlot:SetID(bagID - 4)
					bagSlot.internalID = bagID;
				else
					bagSlot.internalID = (bagID + 1);
				end

				MOD:NewFilterMenu(bagSlot)

				menu[i] = bagSlot;
			end

			bagSlot:SetSize(buttonSize, buttonSize)
			bagSlot:ClearAllPoints()

			if(isBank) then
				BankFrameItemButton_Update(bagSlot)
				BankFrameItemButton_UpdateLocked(bagSlot)

				if(i == 2) then
					bagSlot:SetPoint("BOTTOMLEFT", menu, "BOTTOMLEFT", buttonSpacing, buttonSpacing)
				else
					bagSlot:SetPoint("LEFT", lastMenu, "RIGHT", buttonSpacing, 0)
				end
			else
				if(i == 1) then
					bagSlot:SetPoint("BOTTOMLEFT", menu, "BOTTOMLEFT", buttonSpacing, buttonSpacing)
				else
					bagSlot:SetPoint("LEFT", lastMenu, "RIGHT", buttonSpacing, 0)
				end
			end
			lastMenu = bagSlot;
		end

		local numSlots = GetContainerNumSlots(bagID);

		local bagName = ("%sBag%d"):format(containerName, bagID)
		local bag;

		if numSlots > 0 then
			if not self.Bags[bagID] then
				self.Bags[bagID] = CreateFrame("Frame", bagName, self);
				self.Bags[bagID]:SetID(bagID);
				self.Bags[bagID].SlotUpdate = SlotUpdate;
				self.Bags[bagID].RefreshSlots = ContainerFrame_RefreshSlots;
			end

			local bagAnchor = self.holderFrame;
			local numCols = numContainerColumns;
			local rowCount = 0;

			if(self.Bags[bagID].holderFrame) then
				bagAnchor = self.Bags[bagID].holderFrame;
				lastButton = false;
				lastRowButton = false;
				totalSlots = 0;
				numCols = ceil(numSlots * 0.2);
				local multiSize = (((buttonSize + buttonSpacing) * numCols) - buttonSpacing) + 16
				self.Bags[bagID]:SetSize(multiSize,multiSize)
			end

			self.Bags[bagID].numSlots = numSlots;
			self.Bags[bagID].bagFamily = false;

			local btype = select(2, GetContainerNumFreeSlots(bagID));
			if RefProfessionColors[btype] then
				local r, g, b = unpack(RefProfessionColors[btype]);
				self.Bags[bagID].bagFamily = {r, g, b};
			end

			for i = 1, MAX_CONTAINER_ITEMS do
				if self.Bags[bagID][i] then
					self.Bags[bagID][i]:Hide();
				end
			end

			for slotID = 1, numSlots do
				totalSlots = totalSlots + 1;

				if not self.Bags[bagID][slotID] then
					local slotName = ("%sSlot%d"):format(bagName, slotID)
					local iconName = ("%sIconTexture"):format(slotName)
					local cdName = ("%sCooldown"):format(slotName)
					local questIcon = ("%sIconQuestTexture"):format(slotName)

					self.Bags[bagID][slotID] = CreateFrame("CheckButton", slotName, self.Bags[bagID], bagID == -1 and "BankItemButtonGenericTemplate" or "ContainerFrameItemButtonTemplate");
					self.Bags[bagID][slotID]:SetNormalTexture("");
					self.Bags[bagID][slotID]:SetCheckedTexture("");
					self.Bags[bagID][slotID]:RemoveTextures();
					self.Bags[bagID][slotID]:SetStyle("!_ActionSlot");

					if(self.Bags[bagID][slotID].IconBorder) then
						self.Bags[bagID][slotID].IconBorder:Die()
					end

					if(not self.Bags[bagID][slotID].NewItemTexture) then
						self.Bags[bagID][slotID].NewItemTexture = self.Bags[bagID][slotID]:CreateTexture(nil, "OVERLAY", 1);
					end
					self.Bags[bagID][slotID].NewItemTexture:InsetPoints(self.Bags[bagID][slotID]);
					self.Bags[bagID][slotID].NewItemTexture:SetTexture("");
					self.Bags[bagID][slotID].NewItemTexture:Hide()

					if(not self.Bags[bagID][slotID].JunkIcon) then
						self.Bags[bagID][slotID].JunkIcon = self.Bags[bagID][slotID]:CreateTexture(nil, "OVERLAY");
						self.Bags[bagID][slotID].JunkIcon:SetSize(16,16);
					end
					self.Bags[bagID][slotID].JunkIcon:SetTexture([[Interface\BUTTONS\UI-GroupLoot-Coin-Up]]);
					self.Bags[bagID][slotID].JunkIcon:SetPoint("TOPLEFT", self.Bags[bagID][slotID], "TOPLEFT", -4, 4);

					if(not self.Bags[bagID][slotID].icon) then
						self.Bags[bagID][slotID].icon = self.Bags[bagID][slotID]:CreateTexture(nil, "BORDER");
					end
					self.Bags[bagID][slotID].icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS));
					self.Bags[bagID][slotID].icon:InsetPoints(self.Bags[bagID][slotID]);

					self.Bags[bagID][slotID].questIcon = _G[questIcon] or self.Bags[bagID][slotID]:CreateTexture(nil, "OVERLAY")
					self.Bags[bagID][slotID].questIcon:SetTexture(TEXTURE_ITEM_QUEST_BANG);
					self.Bags[bagID][slotID].questIcon:InsetPoints(self.Bags[bagID][slotID]);
					self.Bags[bagID][slotID].questIcon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS));

					hooksecurefunc(self.Bags[bagID][slotID], "SetBackdropColor", function(self, r, g, b, a) if(self.HasQuestItem and (r ~= 1)) then self:SetBackdropColor(1,0.3,0.3,a) end end)
					hooksecurefunc(self.Bags[bagID][slotID], "SetBackdropBorderColor", function(self, r, g, b, a) if(self.HasQuestItem and (r ~= 1)) then self:SetBackdropBorderColor(1,0.3,0.3,a) end end)

					self.Bags[bagID][slotID].cooldown = _G[cdName];
				end

				if(not self.Bags[bagID][slotID].GearInfo) then
					self.Bags[bagID][slotID].GearInfo = self.Bags[bagID][slotID]:CreateFontString(nil,"OVERLAY")
					self.Bags[bagID][slotID].GearInfo:SetFontObject(SVUI_Font_Default)
					self.Bags[bagID][slotID].GearInfo:SetAllPoints(self.Bags[bagID][slotID])
					self.Bags[bagID][slotID].GearInfo:SetWordWrap(true)
					self.Bags[bagID][slotID].GearInfo:SetJustifyH('RIGHT')
					self.Bags[bagID][slotID].GearInfo:SetJustifyV('TOP')
				end

				if(not self.Bags[bagID][slotID].ItemLevel) then
					self.Bags[bagID][slotID].ItemLevel = self.Bags[bagID][slotID]:CreateFontString(nil,"OVERLAY")
					self.Bags[bagID][slotID].ItemLevel:SetFontObject(SVUI_Font_Default)
					self.Bags[bagID][slotID].ItemLevel:SetAllPoints(self.Bags[bagID][slotID])
					self.Bags[bagID][slotID].ItemLevel:SetWordWrap(true)
					self.Bags[bagID][slotID].ItemLevel:SetJustifyH('LEFT')
					self.Bags[bagID][slotID].ItemLevel:SetJustifyV('BOTTOM')
				end

				self.Bags[bagID][slotID]:SetID(slotID);
				self.Bags[bagID][slotID]:SetSize(buttonSize, buttonSize);

				if self.Bags[bagID][slotID]:GetPoint() then
					self.Bags[bagID][slotID]:ClearAllPoints();
				end

				if lastButton then
					if((totalSlots - 1) % numCols == 0) then
						self.Bags[bagID][slotID]:SetPoint("TOP", lastRowButton, "BOTTOM", 0, -buttonSpacing);
						lastRowButton = self.Bags[bagID][slotID];
						rowCount = rowCount + 1;
					else
						self.Bags[bagID][slotID]:SetPoint("LEFT", lastButton, "RIGHT", buttonSpacing, 0);
					end
				else
					self.Bags[bagID][slotID]:SetPoint("TOPLEFT", bagAnchor, "TOPLEFT");
					lastRowButton = self.Bags[bagID][slotID];
					rowCount = rowCount + 1;
				end
				lastButton = self.Bags[bagID][slotID];
                
                if(not self.Bags[bagID][slotID].Count) then
                    self.Bags[bagID][slotID].Count = self.Bags[bagID][slotID]:CreateFontString(nil, "ARTWORK")
                    self.Bags[bagID][slotID].Count:SetFontObject(SVUI_Font_Default)
                    self.Bags[bagID][slotID].Count:ClearAllPoints()
                    self.Bags[bagID][slotID].Count:SetPoint("BOTTOMRIGHT", self.Bags[bagID][slotID], "BOTTOMRIGHT", 0, 0)
                end
                
				self.Bags[bagID]:SlotUpdate(slotID);
			end

			if(self.Bags[bagID].holderFrame) then
				local multiWidth = (((buttonSize + buttonSpacing) * numCols) - buttonSpacing) + 16;
				local multiHeight = (((buttonSize + buttonSpacing) * rowCount) - buttonSpacing) + 50;
				self.Bags[bagID]:SetSize(multiWidth,multiHeight)
			end
		else
			if(self.Bags[bagID]) then
				self.Bags[bagID].numSlots = numSlots;

				for i = 1, MAX_CONTAINER_ITEMS do
					if(self.Bags[bagID][i]) then
						self.Bags[bagID][i]:Hide();
					end
				end
			end

			if(isBank) then
				if(menu[i]) then
					BankFrameItemButton_Update(menu[i])
					BankFrameItemButton_UpdateLocked(menu[i])
				end
			end
		end
	end

	self:SetSize(containerWidth, containerHeight);
	MOD:UpdateStockpile()
end

local ReagentFrame_UpdateLayout = function(self)
	if not _G.ReagentBankFrame then return; end

	local ReagentBankFrame = _G.ReagentBankFrame;

	local containerName = self:GetName()
	local buttonSpacing = 8;
	local preColumns = ReagentBankFrame.numColumn or 7
	local preSubColumns = ReagentBankFrame.numSubColumn or 2
	local numContainerColumns = preColumns * preSubColumns
	local numContainerRows = ReagentBankFrame.numRow or 7
	local buttonSize = MOD.BankFrame.ButtonSize
	local containerWidth = (buttonSize + buttonSpacing) * numContainerColumns + buttonSpacing
	local containerHeight = (((buttonSize + buttonSpacing) * numContainerRows) - buttonSpacing) + self.topOffset + self.bottomOffset
	local maxCount = numContainerColumns * numContainerRows
	local holderWidth = ((buttonSize + buttonSpacing) * numContainerColumns) - buttonSpacing;
	local lastButton, lastRowButton;
	local bagID = REAGENTBANK_CONTAINER;
	local totalSlots = 0;

	self.holderFrame:SetWidth(holderWidth);
	self.BagID = bagID

	local bag;
	local bagName = ("%sBag%d"):format(containerName, bagID)

	if not self.Bags[bagID] then
		bag = CreateFrame("Frame", bagName, self);
		bag:SetID(bagID);
		bag.SlotUpdate = SlotUpdate;
		bag.RefreshSlots = ContainerFrame_RefreshSlots;
		self.Bags[bagID] = bag
	else
		bag = self.Bags[bagID]
	end

	self.numSlots = maxCount;
	bag.numSlots = maxCount;
	bag.bagFamily = false;

	for slotID = 1, maxCount do
		local slot;
		totalSlots = totalSlots + 1;

		if not bag[slotID] then
			local slotName = ("%sSlot%d"):format(bagName, slotID)
			local iconName = ("%sIconTexture"):format(slotName)
			local questIcon = ("%sIconQuestTexture"):format(slotName)
			local cdName = ("%sCooldown"):format(slotName)

			slot = CreateFrame("ItemButton", slotName, bag, "ReagentBankItemButtonGenericTemplate")
			slot:SetNormalTexture(nil)
			slot:RemoveTextures()
			slot:SetStyle("!_ActionSlot")

			if(slot.IconBorder) then
				slot.IconBorder:Die()
			end

			slot.NewItemTexture = slot:CreateTexture(nil, "OVERLAY", 1)
			slot.NewItemTexture:InsetPoints(slot)
			slot.NewItemTexture:SetTexture("")
			slot.NewItemTexture:Hide()

			slot.JunkIcon = slot:CreateTexture(nil, "OVERLAY")
			slot.JunkIcon:SetSize(16,16)
			slot.JunkIcon:SetTexture("")
			slot.JunkIcon:SetPoint("TOPLEFT", slot, "TOPLEFT", -4, 4)

			slot.icon = _G[iconName] or slot:CreateTexture(nil, "BORDER")
			slot.icon:InsetPoints(slot)
			slot.icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))

			slot.questIcon = _G[questIcon] or slot:CreateTexture(nil, "OVERLAY")
			slot.questIcon:SetTexture(TEXTURE_ITEM_QUEST_BANG)
			slot.questIcon:InsetPoints(slot)
			slot.questIcon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))

			slot.cooldown = _G[cdName]

			bag[slotID] = slot
		else
			slot = bag[slotID]
		end

		slot:SetID(slotID);
		slot:SetSize(buttonSize, buttonSize);

		if slot:GetPoint() then
			slot:ClearAllPoints();
		end

		if lastButton then
			if((totalSlots - 1) % numContainerColumns == 0) then
				slot:SetPoint("TOP", lastRowButton, "BOTTOM", 0, -buttonSpacing);
				lastRowButton = slot;
			else
				slot:SetPoint("LEFT", lastButton, "RIGHT", buttonSpacing, 0);
			end
		else
			slot:SetPoint("TOPLEFT", self.holderFrame, "TOPLEFT");
			lastRowButton = slot;
		end

		lastButton = slot;
        
        if(not slot.Count) then
            self.Bags[bagID][slotID].Count = self.Bags[bagID][slotID]:CreateFontString(nil, "ARTWORK")
            self.Bags[bagID][slotID].Count:SetFontObject(SVUI_Font_Default)
            self.Bags[bagID][slotID].Count:ClearAllPoints()
            self.Bags[bagID][slotID].Count:SetPoint("BOTTOMRIGHT", self.Bags[bagID][slotID], "BOTTOMRIGHT", 0, 0)
        end

		if(slot.GetInventorySlot) then
			BankFrameItemButton_Update(slot)
			BankFrameItemButton_UpdateLocked(slot)
		end

		bag:SlotUpdate(slotID);
	end

	self:SetSize(containerWidth, containerHeight);
	MOD:UpdateStockpile()
end

function MOD:RefreshBagFrames(frame)
	if(frame and self[frame]) then
		self[frame]:UpdateLayout()
		return
	else
		if(self.MasterFrame) then
			self.MasterFrame:UpdateLayout()
		end
		if self.BankFrame then
			self.BankFrame:UpdateLayout()
		end
		if self.ReagentFrame then
			self.ReagentFrame:UpdateLayout()
		end
	end
end

function SV:SetLootTooltip(tooltip, itemKey)
	if((not LOOT_CACHE) or (not LOOT_CACHE[itemKey])) then return end
	tooltip:AddLine(" ")
	tooltip:AddDoubleLine("|cFFFFDD3C[Character]|r","|cFFFFDD3C[Count]|r")
	for alt,amt in pairs(LOOT_CACHE[itemKey]) do
		local hexString = MOD.public[realmKey]["info"][alt] or "|cffCC1410"
		local name = ("%s%s|r"):format(hexString, alt)
		local result = ("%s%s|r"):format(hexString, amt)
		tooltip:AddDoubleLine(name,result)
	end
	tooltip:AddLine(" ")
end

function MOD:UpdateGoldText()
	self.MasterFrame.goldText:SetText(GetCoinTextureString(GetMoney(), 12))
end

function MOD:VendorCheck(itemID, bagID, slot)
	if((not MOD.private) or (not MOD.private.junk)) then return end
	if(itemID and MOD.private.junk[itemID]) then
		UseContainerItem(bagID, slot)
		PickupMerchantItem()
		return true
	end
end

function MOD:ModifyBags()
	local docked = SV.db.Inventory.alignToChat
	local anchor, x, y

	MULTI_BAG_HEIGHT_OFFSET = 0;

	if(SV.db.Inventory.separateBags) then
		for bagID,bag in pairs(self.MasterFrame.Bags) do
			if(bagID == 1 or bagID == 3) then
				local bagHeight = bag:GetHeight()
				MULTI_BAG_HEIGHT_OFFSET = MULTI_BAG_HEIGHT_OFFSET + (bagHeight + 4);
			end
		end
	end

	if(docked) then
		if self.MasterFrame then
			self.MasterFrame:ClearAllPoints()
			self.MasterFrame:SetPoint("BOTTOMRIGHT", SV.Dock.BottomRight, "BOTTOMRIGHT", 0, MULTI_BAG_HEIGHT_OFFSET)
		end
		if self.BankFrame then
			self.BankFrame:ClearAllPoints()
			self.BankFrame:SetPoint("BOTTOMLEFT", SV.Dock.BottomLeft, "BOTTOMLEFT", 0, 0)
		end
	else
		if self.MasterFrame then
			local anchor, x, y = SV.db.Inventory.bags.point, SV.db.Inventory.bags.xOffset, SV.db.Inventory.bags.yOffset
			self.MasterFrame:ClearAllPoints()
			self.MasterFrame:SetPoint(anchor, SV.Screen, anchor, x, y + MULTI_BAG_HEIGHT_OFFSET)
		end
		if self.BankFrame then
			local anchor, x, y = SV.db.Inventory.bank.point, SV.db.Inventory.bank.xOffset, SV.db.Inventory.bank.yOffset
			self.BankFrame:ClearAllPoints()
			self.BankFrame:SetPoint(anchor, SV.Screen, anchor, x, y)
		end
	end
end

do
	local BagBar_OnEnter = function(self)
		if(not self.___fade) then return end
		BagBar:FadeIn()
	end

	local BagBar_OnLeave = function(self)
		if(not self.___fade) then return end
		BagBar:FadeOut()
	end

	local function AlterBagBarButton(button)
		local icon = _G[button:GetName().."IconTexture"]
		button.oldTex = icon:GetTexture()
		button:RemoveTextures()
		button:SetStyle("!_Frame", "Default")
		button:SetStyle("!_ActionSlot", 1, nil, nil, true)
		icon:SetTexture(button.oldTex)
		icon:InsetPoints()
		icon:SetTexCoord(0.1, 0.9, 0.1, 0.9 )
	end

	function MOD:PositionBagBar(reset)
		if(not self.BagBarLoaded) then return end
		if(BagBar.Grip and (not BagBar.Grip:HasMoved())) then
			BagBar:ClearAllPoints()
			if(reset) then
				BagBar:SetPoint("BOTTOMLEFT", SV.Dock.BottomRight.Window, "TOPLEFT", -4, 0)
			else
				BagBar:SetPoint("BOTTOMLEFT", self.MasterFrame, "TOPLEFT", -4, 0)
			end
		end
	end

	local function LoadBagBar()
		local bagFading = SV.db.Inventory.bagBar.mouseover

		BagBar:SetParent(SV.Screen)
		BagBar:ClearAllPoints()
		BagBar:SetSize(160, 30)
		BagBar:SetPoint("BOTTOMLEFT", SV.Dock.BottomRight.Window, "TOPLEFT", -4, 0)
		BagBar.buttons = {}
		BagBar.___fade = bagFading;
		BagBar:EnableMouse(true)
		BagBar:SetScript("OnEnter", BagBar_OnEnter)
		BagBar:SetScript("OnLeave", BagBar_OnLeave)
		BagBar:SetStyle("Frame", "Default")

		MainMenuBarBackpackButton:SetParent(BagBar)
		MainMenuBarBackpackButton.SetParent = SV.fubar;
		MainMenuBarBackpackButton.___fade = bagFading;
		MainMenuBarBackpackButton:ClearAllPoints()
		MainMenuBarBackpackButton:SetPoint("BOTTOMLEFT", BagBar, "BOTTOMLEFT", 2, 2)
		MainMenuBarBackpackButtonCount:SetFontObject(SVUI_Font_Default)
		MainMenuBarBackpackButtonCount:ClearAllPoints()
		MainMenuBarBackpackButtonCount:SetPoint("BOTTOMRIGHT", MainMenuBarBackpackButton, "BOTTOMRIGHT", -1, 4)
		MainMenuBarBackpackButton:HookScript("OnEnter", BagBar_OnEnter)
		MainMenuBarBackpackButton:HookScript("OnLeave", BagBar_OnLeave)

		tinsert(BagBar.buttons, MainMenuBarBackpackButton)
		AlterBagBarButton(MainMenuBarBackpackButton)

		local frameCount = NUM_BAG_FRAMES - 1;

		for i = 0, frameCount do
			local bagSlot = _G["CharacterBag"..i.."Slot"]
			bagSlot:SetParent(BagBar)
			bagSlot.SetParent = SV.fubar;
			bagSlot.___fade = bagFading;
			bagSlot:HookScript("OnEnter", BagBar_OnEnter)
			bagSlot:HookScript("OnLeave", BagBar_OnLeave)
			AlterBagBarButton(bagSlot)
			BagBar.buttons[i + 2] = bagSlot
		end

		SV:NewAnchor(BagBar, L["Bags Bar"])

		MOD.BagBarLoaded = true
	end

	function MOD:ModifyBagBar()
		if(not SV.db.Inventory.bagBar.enable) then return end

		if not self.BagBarLoaded then
			LoadBagBar()
		end

		local showBy = SV.db.Inventory.bagBar.showBy
		local showBG = SV.db.Inventory.bagBar.showBackdrop
		local sortDir = SV.db.Inventory.bagBar.sortDirection
		local bagSize = SV.db.Inventory.bagBar.size
		local bagSpacing = SV.db.Inventory.bagBar.spacing
		local bagFading = SV.db.Inventory.bagBar.mouseover
		local bagCount = #BagBar.buttons

		for i = 1, bagCount do
			local button = BagBar.buttons[i]
			local lastButton = BagBar.buttons[i - 1]

			button:SetSize(bagSize, bagSize)
			button:ClearAllPoints()

			if(showBy == "HORIZONTAL" and sortDir == "ASCENDING") then
				if i == 1 then
					button:SetPoint("LEFT", BagBar, "LEFT", bagSpacing, 0)
				elseif lastButton then
					button:SetPoint("LEFT", lastButton, "RIGHT", bagSpacing, 0)
				end
			elseif(showBy == "VERTICAL" and sortDir == "ASCENDING") then
				if i == 1 then
					button:SetPoint("TOP", BagBar, "TOP", 0, -bagSpacing)
				elseif lastButton then
					button:SetPoint("TOP", lastButton, "BOTTOM", 0, -bagSpacing)
				end
			elseif(showBy == "HORIZONTAL" and sortDir == "DESCENDING") then
				if i == 1 then
					button:SetPoint("RIGHT", BagBar, "RIGHT", -bagSpacing, 0)
				elseif lastButton then
					button:SetPoint("RIGHT", lastButton, "LEFT", -bagSpacing, 0)
				end
			else
				if i == 1 then
					button:SetPoint("BOTTOM", BagBar, "BOTTOM", 0, bagSpacing)
				elseif lastButton then
					button:SetPoint("BOTTOM", lastButton, "TOP", 0, bagSpacing)
				end
			end

			button.___fade = bagFading
		end

		local size1 = (bagSize * bagCount) + (bagSpacing * bagCount) + bagSpacing
		local size2 = bagSize + (bagSpacing * 2)
		if(showBy == "HORIZONTAL") then BagBar:SetSize(size1, size2) else BagBar:SetSize(size2, size1) end
	    if(showBG) then BagBar.Panel:FadeIn() else BagBar.Panel:FadeOut() end
	    BagBar.___fade = bagFading;
		if(bagFading) then BagBar:FadeOut() else BagBar:FadeIn() end
	end
end
--[[
##########################################################
BAG CONTAINER CREATION
##########################################################
]]--
local NEXT_ACTION_ALLOWED, NEXT_ACTION_TOGGLED = false, false;
local NEXT_ACTION_FORCED, FORCED_CLOSED, FORCED_OPEN = false, false, false;

do
	local InventorySearch_OnReset = function(self)
		self.button:Show()
		self:ClearFocus()
		SetItemSearch('')
	end

	local InventorySearch_OnChar = function(self)
		local MIN_REPEAT_CHARACTERS = 4;
		local searchString = self:GetText();
		if (len(searchString) >= MIN_REPEAT_CHARACTERS) then
			local repeatChar = true;
			for i=1, MIN_REPEAT_CHARACTERS - 1, 1 do
				if ( searchString:sub((0-i), (0-i)) ~= searchString:sub((-1-i),(-1-i)) ) then
					repeatChar = false;
					break;
				end
			end
			if ( repeatChar ) then
				InventorySearch_OnReset(self)
			end
		end
	end

	local InventorySearch_OnTextChanged = function(self)
		local MIN_REPEAT_CHARACTERS = 4;
		local searchString = self:GetText();
		if (len(searchString) >= MIN_REPEAT_CHARACTERS) then
			local repeatChar = true;
			for i=1, MIN_REPEAT_CHARACTERS - 1, 1 do
				if ( searchString:sub((0-i), (0-i)) ~= searchString:sub((-1-i),(-1-i)) ) then
					repeatChar = false;
					break;
				end
			end
			if ( repeatChar ) then
				InventorySearch_OnReset(self)
			end
		end
		SetItemSearch(searchString)
	end

	local Search_OnClick = function(self, button)
		local container = self:GetParent()
		if button == "RightButton"then
			container.detail:Hide()
			container.editBox:Show()
			container.editBox:SetText(SEARCH)
			container.editBox:HighlightText()
		else
			if container.editBox:IsShown()then
				container.editBox:Hide()
				container.editBox:ClearFocus()
				container.detail:Show()
				SetItemSearch('')
			else
				container.detail:Hide()
				container.editBox:Show()
				container.editBox:SetText(SEARCH)
				container.editBox:HighlightText()
			end
		end
	end

	local Vendor_OnClick = function(self)
		if(IsShiftKeyDown() or (not MerchantFrame or not MerchantFrame:IsShown())) then
			SV.SystemAlert["DELETE_GRAYS"].Money = SV:VendorGrays(false,true,true)
			SV:StaticPopup_Show('DELETE_GRAYS')
		else
			SV:VendorGrays()
		end
	end

	local Token_OnEnter = function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetBackpackToken(self:GetID())
	end

	local Token_OnLeave = function(self)
		GameTooltip:Hide()
	end

	local Token_OnClick = function(self)
		if IsModifiedClick("CHATLINK") then
			HandleModifiedItemClick(GetCurrencyLink(self.currencyID))
		end
	end

	local TopInfo_OnEnter = function(self)
		GameTooltip:SetOwner(self,"ANCHOR_BOTTOM",0,-4)
		GameTooltip:ClearLines()

		local goldData = SV:GetReportData("gold")

		local networth = goldData[nameKey];
		GameTooltip:AddLine(L[nameKey..": "])
		GameTooltip:AddDoubleLine(L["Total: "], SV:FormatCurrency(networth), 1,1,1,1,1,1)
		GameTooltip:AddLine(" ")

		GameTooltip:AddLine(L["Characters: "])
		for name,amount in pairs(goldData)do
			if(name ~= nameKey and name ~= 'total') then
				networth = networth + amount;
				GameTooltip:AddDoubleLine(name, SV:FormatCurrency(amount), 1,1,1,1,1,1)
			end
		end

		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(L["Server: "])
		GameTooltip:AddDoubleLine(L["Total: "], SV:FormatCurrency(networth), 1,1,1,1,1,1)
		GameTooltip:AddLine(" ")

		GameTooltip:Show()
	end

	local Tooltip_Show = function(self)
		GameTooltip:SetOwner(self:GetParent(),"ANCHOR_TOP",0,4)
		GameTooltip:ClearLines()
		GameTooltip:AddLine(self.ttText)

		if self.ttText2 then
			GameTooltip:AddLine(' ')
			GameTooltip:AddDoubleLine(self.ttText2,self.ttText2desc,1,1,1)
		end

		self:GetNormalTexture():SetGradient(unpack(SV.media.gradient.highlight))
		GameTooltip:Show()
	end

	local Tooltip_Hide = function(self)
		self:GetNormalTexture():SetGradient(unpack(SV.media.gradient.medium))
		GameTooltip:Hide()
	end

	local Container_OnDragStart = function(self)
		if IsShiftKeyDown()then self:StartMoving()end
	end
	local Container_OnDragStop = function(self)
		self:StopMovingOrSizing()
	end
	local Container_OnClick = function(self)
		if IsControlKeyDown() then MOD:ModifyBags() end
	end
	local Container_OnEnter = function(self)
		GameTooltip:SetOwner(self,"ANCHOR_TOPLEFT",0,4)
		GameTooltip:ClearLines()
		GameTooltip:AddDoubleLine(L['Hold Shift + Drag:'],L['Temporary Move'],1,1,1)
		GameTooltip:AddDoubleLine(L['Hold Control + Right Click:'],L['Reset Position'],1,1,1)
		GameTooltip:Show()
	end

	local Container_OnShow = function(self)
		NEXT_ACTION_ALLOWED = true
		MOD:PositionBagBar()
		if(SV.db.Inventory.separateBags) then
			for bagID, bagFrame in ipairs(MOD.MasterFrame.Bags) do
				bagFrame:Show()
			end
		end
	end

	local Container_OnHide = function(self)
		NEXT_ACTION_ALLOWED = false
		MOD:PositionBagBar(true)
	end

	function MOD:CreateMasterFrame()
		local bagName = "SVUI_ContainerFrame";
		local frame = CreateFrame("Button", "SVUI_ContainerFrame", SV.Screen);
		tinsert(UISpecialFrames, bagName);

		frame:SetStyle("Frame", "Pattern")
		frame:SetFrameStrata("HIGH")
		frame.UpdateLayout = ContainerFrame_UpdateLayout;
		frame.RefreshBags = ContainerFrame_UpdateBags;
		frame.RefreshCooldowns = ContainerFrame_UpdateCooldowns;

		frame:RegisterEvent("ITEM_LOCK_CHANGED")
		frame:RegisterEvent("ITEM_UNLOCKED")
		frame:RegisterEvent("BAG_UPDATE_COOLDOWN")
		frame:RegisterEvent("BAG_UPDATE")
		frame:RegisterEvent("EQUIPMENT_SETS_CHANGED")
		frame:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
		frame:RegisterEvent("PLAYERREAGENTBANKSLOTS_CHANGED")

		frame:SetMovable(true)

		frame:RegisterForDrag("LeftButton", "RightButton")
		frame:RegisterForClicks("AnyUp")

		frame:SetScript("OnDragStart", Container_OnDragStart)
		frame:SetScript("OnDragStop", Container_OnDragStop)
		frame:SetScript("OnClick", Container_OnClick)
		frame:SetScript("OnEnter", Container_OnEnter)
		frame:SetScript("OnLeave", Token_OnLeave)
		frame:SetScript("OnHide", Container_OnHide)
		frame:SetScript("OnShow", Container_OnShow)
		self:SetContainerEvents(frame)

		frame.isBank = false;
		frame.isReagent = false;
		frame:Hide()
		frame.bottomOffset = 32;
		frame.topOffset = 65;
		frame.BagIDs = {0, 1, 2, 3, 4}
		frame.Bags = {}

		frame.closeButton = CreateFrame("Button", "SVUI_ContainerFrameCloseButton", frame, "UIPanelCloseButton")
		frame.closeButton:SetPoint("TOPRIGHT", -4, -4)
		SV.API:Set("CloseButton", frame.closeButton);
		frame.closeButton:SetScript("PostClick", function()
			if(not InCombatLockdown()) then CloseBag(0) end
		end)

		frame.holderFrame = CreateFrame("Frame", nil, frame)
		frame.holderFrame:SetPoint("TOP", frame, "TOP", 0, -frame.topOffset)
		frame.holderFrame:SetPoint("BOTTOM", frame, "BOTTOM", 0, frame.bottomOffset)

		frame.Title = frame:CreateFontString()
		frame.Title:SetFontObject(SVUI_Font_Header)
		frame.Title:SetText(INVENTORY_TOOLTIP)
		frame.Title:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -2)
		frame.Title:SetTextColor(1,0.8,0)

		frame.BagMenu = CreateFrame("Button", "SVUI_ContainerFrameBagMenu", frame)
		frame.BagMenu:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 0, 1)
		frame.BagMenu:SetStyle("!_Frame", "Transparent")
		frame.BagMenu:Hide()

		frame.goldText = frame:CreateFontString(nil, "OVERLAY")
		frame.goldText:SetFontObject(SVUI_Font_Bag_Number)
		frame.goldText:SetPoint("BOTTOMRIGHT", frame.holderFrame, "TOPRIGHT", -2, 4)
		frame.goldText:SetJustifyH("RIGHT")

		frame.goldInfo = CreateFrame("Frame", nil, frame)
		frame.goldInfo:SetAllPoints(frame.goldText)
		frame.goldInfo:SetScript("OnEnter", TopInfo_OnEnter)

		frame.editBox = CreateFrame("EditBox", "SVUI_ContainerFrameEditBox", frame)
		frame.editBox:SetStyle("Editbox")
		frame.editBox:SetHeight(15)
		frame.editBox:Hide()
		frame.editBox:SetPoint("BOTTOMLEFT", frame.holderFrame, "TOPLEFT", 2, 4)
		frame.editBox:SetPoint("RIGHT", frame.goldText, "LEFT", -5, 0)
		frame.editBox:SetAutoFocus(true)
		frame.editBox:SetScript("OnEscapePressed", InventorySearch_OnReset)
		frame.editBox:SetScript("OnEnterPressed", InventorySearch_OnReset)
		frame.editBox:SetScript("OnEditFocusLost", frame.editBox.Hide)
		frame.editBox:SetScript("OnEditFocusGained", frame.editBox.HighlightText)
		frame.editBox:SetScript("OnTextChanged", InventorySearch_OnTextChanged)
		frame.editBox:SetScript("OnChar", InventorySearch_OnChar)
		frame.editBox.SearchReset = InventorySearch_OnReset
		frame.editBox:SetText(SEARCH)
		frame.editBox:SetFontObject(SVUI_Font_Bag)

		local searchButton = CreateFrame("Button", nil, frame)
		searchButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
		searchButton:SetSize(60, 18)
		searchButton:SetPoint("BOTTOMLEFT", frame.editBox, "BOTTOMLEFT", -2, 0)
		searchButton:SetStyle("Button")
		searchButton:SetScript("OnClick", Search_OnClick)
		local searchText = searchButton:CreateFontString(nil, "OVERLAY")
		searchText:SetFontObject(SVUI_Font_Bag)
		searchText:SetAllPoints(searchButton)
		searchText:SetJustifyH("CENTER")
		searchText:SetText("|cff9999ff"..SEARCH.."|r")
		searchButton:SetFontString(searchText)
		frame.detail = searchButton
		frame.editBox.button = frame.detail;

		frame.sortButton = CreateFrame("Button", nil, frame)
		frame.sortButton:SetPoint("TOP", frame, "TOP", 0, -10)
		frame.sortButton:SetSize(25, 25)
		StyleBagToolButton(frame.sortButton, MOD.media.cleanupIcon)
		frame.sortButton.ttText = L["Sort Bags"]
		frame.sortButton.ttText2 = L["[SHIFT + CLICK]"]
		frame.sortButton.ttText2desc = L["Filtered Cleanup (Default Sorting)"]
		frame.sortButton:SetScript("OnEnter", Tooltip_Show)
		frame.sortButton:SetScript("OnLeave", Tooltip_Hide)
		local Sort_OnClick = MOD:RunSortingProcess(MOD.Sort, "bags", SortBags)
		frame.sortButton:SetScript("OnClick", Sort_OnClick)

		frame.stackButton = CreateFrame("Button", nil, frame)
		frame.stackButton:SetPoint("LEFT", frame.sortButton, "RIGHT", 10, 0)
		frame.stackButton:SetSize(25, 25)
		StyleBagToolButton(frame.stackButton, MOD.media.stackIcon)
		frame.stackButton.ttText = L["Stack Items"]
		frame.stackButton:SetScript("OnEnter", Tooltip_Show)
		frame.stackButton:SetScript("OnLeave", Tooltip_Hide)
		local Stack_OnClick = MOD:RunSortingProcess(MOD.Stack, "bags")
		frame.stackButton:SetScript("OnClick", Stack_OnClick)

		frame.vendorButton = CreateFrame("Button", nil, frame)
		frame.vendorButton:SetPoint("RIGHT", frame.sortButton, "LEFT", -10, 0)
		frame.vendorButton:SetSize(25, 25)
		StyleBagToolButton(frame.vendorButton, MOD.media.vendorIcon)
		frame.vendorButton.ttText = L["Vendor Grays"]
		frame.vendorButton.ttText2 = L["Hold Shift:"]
		frame.vendorButton.ttText2desc = L["Delete Grays"]
		frame.vendorButton:SetScript("OnEnter", Tooltip_Show)
		frame.vendorButton:SetScript("OnLeave", Tooltip_Hide)
		frame.vendorButton:SetScript("OnClick", Vendor_OnClick)

		frame.bagsButton = CreateFrame("Button", nil, frame)
		frame.bagsButton:SetPoint("RIGHT", frame.vendorButton, "LEFT", -10, 0)
		frame.bagsButton:SetSize(25, 25)
		StyleBagToolButton(frame.bagsButton, MOD.media.bagIcon)
		frame.bagsButton.ttText = L["Toggle Bags"]
		frame.bagsButton:SetScript("OnEnter", Tooltip_Show)
		frame.bagsButton:SetScript("OnLeave", Tooltip_Hide)
		local BagBtn_OnClick = function()
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION);
			if(BagFilters and BagFilters:IsShown()) then
				ToggleFrame(BagFilters)
			end
			ToggleFrame(frame.BagMenu)
		end
		frame.bagsButton:SetScript("OnClick", BagBtn_OnClick)

		frame.transferButton = CreateFrame("Button", nil, frame)
		frame.transferButton:SetPoint("LEFT", frame.stackButton, "RIGHT", 10, 0)
		frame.transferButton:SetSize(25, 25)
		StyleBagToolButton(frame.transferButton, MOD.media.transferIcon)
		frame.transferButton.ttText = L["Stack Bags to Bank"]
		frame.transferButton:SetScript("OnEnter", Tooltip_Show)
		frame.transferButton:SetScript("OnLeave", Tooltip_Hide)
		local Transfer_OnClick = MOD:RunSortingProcess(MOD.Transfer, "bags bank")
		frame.transferButton:SetScript("OnClick", Transfer_OnClick)

		frame.currencyButton = CreateFrame("Frame", nil, frame)
		frame.currencyButton:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 4, 0)
		frame.currencyButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -4, 0)
		frame.currencyButton:SetHeight(32)

		for h = 1, MAX_WATCHED_TOKENS do
			frame.currencyButton[h] = CreateFrame("Button", nil, frame.currencyButton)
			frame.currencyButton[h]:SetSize(22, 22)
			frame.currencyButton[h]:SetStyle("!_Frame", "Default")
			frame.currencyButton[h]:SetID(h)
			frame.currencyButton[h].icon = frame.currencyButton[h]:CreateTexture(nil, "OVERLAY")
			frame.currencyButton[h].icon:InsetPoints()
			frame.currencyButton[h].icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
			frame.currencyButton[h].text = frame.currencyButton[h]:CreateFontString(nil, "OVERLAY")
			frame.currencyButton[h].text:SetPoint("LEFT", frame.currencyButton[h], "RIGHT", 2, 0)
			frame.currencyButton[h].text:SetFontObject(SVUI_Font_Bag_Number)
			frame.currencyButton[h]:SetScript("OnEnter", Token_OnEnter)
			frame.currencyButton[h]:SetScript("OnLeave", Token_OnLeave)
			frame.currencyButton[h]:SetScript("OnClick", Token_OnClick)
			frame.currencyButton[h]:Hide()
		end

		if(SV.db.Inventory.separateBags) then
            print("hello")
			for i, bagID in ipairs(frame.BagIDs) do
				if(bagID > 0) then
					local singleBagFrameName = "SVUI_ContainerFrameBag" .. bagID;
					local singleBagFrame = CreateFrame("Button", singleBagFrameName, frame);
					tinsert(UISpecialFrames, singleBagFrameName);

					if(bagID == 1) then
						singleBagFrame:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", 0, -4)
					elseif(bagID == 2) then
						singleBagFrame:SetPoint("TOPRIGHT", _G['SVUI_ContainerFrameBag1'], "TOPLEFT", -4, 0)
					elseif(bagID == 3) then
						singleBagFrame:SetPoint("TOPRIGHT", _G['SVUI_ContainerFrameBag1'], "BOTTOMRIGHT", 0, -4)
					else
						singleBagFrame:SetPoint("TOPRIGHT", _G['SVUI_ContainerFrameBag3'], "TOPLEFT", -4, 0)
					end

					singleBagFrame:SetStyle("Frame", "Pattern")
					singleBagFrame:SetFrameStrata("HIGH")
					singleBagFrame:SetMovable(true)
					singleBagFrame:RegisterForDrag("LeftButton", "RightButton")
					singleBagFrame:RegisterForClicks("AnyUp")
					singleBagFrame:SetID(bagID);
					singleBagFrame.SlotUpdate = SlotUpdate;
					singleBagFrame.RefreshSlots = ContainerFrame_RefreshSlots;

					singleBagFrame.closeButton = CreateFrame("Button", singleBagFrameName .. "CloseButton", singleBagFrame, "UIPanelCloseButton")
					singleBagFrame.closeButton:SetPoint("TOPRIGHT", -4, -4)
					SV.API:Set("CloseButton", singleBagFrame.closeButton);
					singleBagFrame.closeButton:SetScript("PostClick", function()
						if(not InCombatLockdown()) then CloseBag(bagID) end
					end)

					singleBagFrame.holderFrame = CreateFrame("Frame", nil, singleBagFrame)
					singleBagFrame.holderFrame:SetPoint("TOPLEFT", singleBagFrame, "TOPLEFT", 8, -42)
					singleBagFrame.holderFrame:SetPoint("BOTTOMRIGHT", singleBagFrame, "BOTTOMRIGHT", -8, 8)

					singleBagFrame:SetScript("OnDragStart", Container_OnDragStart)
					singleBagFrame:SetScript("OnDragStop", Container_OnDragStop)
					singleBagFrame:SetScript("OnClick", Container_OnClick)
					singleBagFrame:SetScript("OnEnter", Container_OnEnter)
					singleBagFrame:SetScript("OnLeave", Token_OnLeave)
					singleBagFrame:SetScript("OnHide", Container_OnHide)
					singleBagFrame:SetScript("OnShow", Container_OnShow)

					frame.Bags[bagID] = singleBagFrame;
				end
			end
		end

		self.MasterFrame = frame
	end

	function MOD:CreateBankOrReagentFrame(isReagent)
		-- Reagent Slots: 1 - 98
		-- /script print(ReagentBankFrameItem1:GetInventorySlot())
		local bagName = isReagent and "SVUI_ReagentContainerFrame" or "SVUI_BankContainerFrame"
		local uisCount = #UISpecialFrames + 1;

		local frame = CreateFrame("Button", bagName, isReagent and self.BankFrame or SV.Screen)
		frame:SetStyle("Frame", "Pattern")
		frame:SetFrameStrata("HIGH")
		frame:SetFrameLevel(self.MasterFrame:GetFrameLevel() + 99)

		frame.UpdateLayout = isReagent and ReagentFrame_UpdateLayout or ContainerFrame_UpdateLayout;
		frame.RefreshBags = ContainerFrame_UpdateBags;
		frame.RefreshCooldowns = ContainerFrame_UpdateCooldowns;

		frame:RegisterEvent("ITEM_LOCK_CHANGED")
		frame:RegisterEvent("ITEM_UNLOCKED")
		frame:RegisterEvent("BAG_UPDATE_COOLDOWN")
		frame:RegisterEvent("BAG_UPDATE")
		frame:RegisterEvent("EQUIPMENT_SETS_CHANGED")
		frame:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
		frame:RegisterEvent("PLAYERREAGENTBANKSLOTS_CHANGED")

		frame:SetMovable(true)
		frame:RegisterForDrag("LeftButton", "RightButton")
		frame:RegisterForClicks("AnyUp")
		frame:SetScript("OnDragStart", Container_OnDragStart)
		frame:SetScript("OnDragStop", Container_OnDragStop)
		frame:SetScript("OnClick", Container_OnClick)
		frame:SetScript("OnEnter", Container_OnEnter)
		frame:SetScript("OnLeave", Token_OnLeave)
		self:SetContainerEvents(frame)

		frame.isBank = true;
		frame.isReagent = isReagent;
		frame:Hide()
		frame.bottomOffset = 8;
		frame.topOffset = 60;

		if(isReagent) then
			frame.BagIDs = {REAGENTBANK_CONTAINER}
		else
			frame.BagIDs = {-1, 5, 6, 7, 8, 9, 10, 11}
		end

		frame.Bags = {}

		frame.closeButton = CreateFrame("Button", bagName.."CloseButton", frame, "UIPanelCloseButton")
		frame.closeButton:SetPoint("TOPRIGHT", -4, -4)
		SV.API:Set("CloseButton", frame.closeButton);
		frame.closeButton:SetScript("PostClick", function()
			if(not InCombatLockdown()) then CloseBag(0) end
		end)

		frame.holderFrame = CreateFrame("Frame", nil, frame)
		frame.holderFrame:SetPoint("TOP", frame, "TOP", 0, -frame.topOffset)
		frame.holderFrame:SetPoint("BOTTOM", frame, "BOTTOM", 0, frame.bottomOffset)

		frame.Title = frame:CreateFontString()
		frame.Title:SetFontObject(SVUI_Font_Header)
		frame.Title:SetText(isReagent and REAGENT_BANK or BANK or "Bank")
		frame.Title:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -2)
		frame.Title:SetTextColor(1,0.8,0)

		frame.sortButton = CreateFrame("Button", nil, frame)
		frame.sortButton:SetPoint("TOPRIGHT", frame, "TOP", 0, -10)
		frame.sortButton:SetSize(25, 25)
		StyleBagToolButton(frame.sortButton, MOD.media.cleanupIcon)
		frame.sortButton.ttText = L["Sort Bank"]
		frame.sortButton.ttText2 = L["[SHIFT + CLICK]"]

		frame.sortButton.ttText2desc = L["Filtered Cleanup (Default Sorting)"]
		frame.sortButton:SetScript("OnEnter", Tooltip_Show)
		frame.sortButton:SetScript("OnLeave", Tooltip_Hide)

		frame.stackButton = CreateFrame("Button", nil, frame)
		frame.stackButton:SetPoint("LEFT", frame.sortButton, "RIGHT", 10, 0)
		frame.stackButton:SetSize(25, 25)
		StyleBagToolButton(frame.stackButton, MOD.media.stackIcon)
		frame.stackButton.ttText = L["Stack Items"]
		frame.stackButton:SetScript("OnEnter", Tooltip_Show)
		frame.stackButton:SetScript("OnLeave", Tooltip_Hide)

		if(not isReagent) then
			frame.BagMenu = CreateFrame("Button", bagName.."BagMenu", frame)
			frame.BagMenu:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 0, 1)
			frame.BagMenu:SetStyle("!_Frame", "Transparent")
			frame.BagMenu:Hide()

			local Sort_OnClick = MOD:RunSortingProcess(MOD.Sort, "bank", SortBankBags)
			frame.sortButton:SetScript("OnClick", Sort_OnClick)
			local Stack_OnClick = MOD:RunSortingProcess(MOD.Stack, "bank")
			frame.stackButton:SetScript("OnClick", Stack_OnClick)

			frame.transferButton = CreateFrame("Button", nil, frame)
			frame.transferButton:SetPoint("LEFT", frame.stackButton, "RIGHT", 10, 0)
			frame.transferButton:SetSize(25, 25)
			StyleBagToolButton(frame.transferButton, MOD.media.transferIcon)
			frame.transferButton.ttText = L["Stack Bank to Bags"]
			frame.transferButton:SetScript("OnEnter", Tooltip_Show)
			frame.transferButton:SetScript("OnLeave", Tooltip_Hide)
			local Transfer_OnClick = MOD:RunSortingProcess(MOD.Transfer, "bank bags")
			frame.transferButton:SetScript("OnClick", Transfer_OnClick)

			tinsert(UISpecialFrames, bagName)

			frame.bagsButton = CreateFrame("Button", nil, frame)
			frame.bagsButton:SetPoint("RIGHT", frame.sortButton, "LEFT", -10, 0)
			frame.bagsButton:SetSize(25, 25)
			StyleBagToolButton(frame.bagsButton, MOD.media.bagIcon)
			frame.bagsButton.ttText = L["Toggle Bags"]
			frame.bagsButton:SetScript("OnEnter", Tooltip_Show)
			frame.bagsButton:SetScript("OnLeave", Tooltip_Hide)
			local BagBtn_OnClick = function()
				PlaySound(SOUNDKIT.IG_MAINMENU_OPTION);
				if(BagFilters and BagFilters:IsShown()) then
					ToggleFrame(BagFilters)
				end
				local numSlots, _ = GetNumBankSlots()
				if numSlots  >= 1 then
					ToggleFrame(frame.BagMenu)
				else
					SV:StaticPopup_Show("NO_BANK_BAGS")
				end
			end
			frame.bagsButton:SetScript("OnClick", BagBtn_OnClick)

			frame.purchaseBagButton = CreateFrame("Button", nil, frame)
			frame.purchaseBagButton:SetSize(25, 25)
			frame.purchaseBagButton:SetPoint("RIGHT", frame.bagsButton, "LEFT", -10, 0)
			frame.purchaseBagButton:SetFrameLevel(frame.purchaseBagButton:GetFrameLevel()+2)
			StyleBagToolButton(frame.purchaseBagButton, MOD.media.purchaseIcon)
			frame.purchaseBagButton.ttText = L["Purchase"]
			frame.purchaseBagButton:SetScript("OnEnter", Tooltip_Show)
			frame.purchaseBagButton:SetScript("OnLeave", Tooltip_Hide)
			local PurchaseBtn_OnClick = function()
				PlaySound(SOUNDKIT.IG_MAINMENU_OPTION);
				local _, full = GetNumBankSlots()
				if not full then
					SV:StaticPopup_Show("BUY_BANK_SLOT")
				else
					SV:StaticPopup_Show("CANNOT_BUY_BANK_SLOT")
				end
			end
			frame.purchaseBagButton:SetScript("OnClick", PurchaseBtn_OnClick)

			local active_icon = IsReagentBankUnlocked() and MOD.media.reagentIcon or MOD.media.purchaseIcon
			frame.swapButton = CreateFrame("Button", nil, frame)
			frame.swapButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -40, -10)
			frame.swapButton:SetSize(25, 25)
			StyleBagToolButton(frame.swapButton, active_icon)
			frame.swapButton.ttText = L["Toggle Reagents Bank"]
			frame.swapButton:SetScript("OnEnter", function(self)
				GameTooltip:SetOwner(self:GetParent(),"ANCHOR_TOP",0,4)
				GameTooltip:ClearLines()
				if(not IsReagentBankUnlocked()) then
					GameTooltip:AddDoubleLine("Purchase Reagents Bank", SV:FormatCurrency(GetReagentBankCost()), 0.1,1,0.1, 1,1,1)
				else
					GameTooltip:AddLine(self.ttText)
				end
				self:GetNormalTexture():SetGradient(unpack(SV.media.gradient.highlight))
				GameTooltip:Show()
			end)
			frame.swapButton:SetScript("OnLeave", Tooltip_Hide)
			frame.swapButton:SetScript("OnClick", function()
				if(not IsReagentBankUnlocked()) then
					SV:StaticPopup_Show("CONFIRM_BUY_REAGENTBANK_TAB");
				else
					PlaySound(SOUNDKIT.IG_MAINMENU_OPTION);
					if(_G["SVUI_ReagentContainerFrame"]:IsShown()) then
						_G["SVUI_ReagentContainerFrame"]:Hide()
					else
						_G["SVUI_ReagentContainerFrame"]:Show()
					end
				end
			end)
			frame:SetScript("OnHide", CloseBankFrame)
			self.BankFrame = frame
		else
			local Sort_OnClick = MOD:RunSortingProcess(MOD.Sort, "reagent", SortBankBags)
			frame.sortButton:SetScript("OnClick", Sort_OnClick)
			local Stack_OnClick = MOD:RunSortingProcess(MOD.Stack, "reagent")
			frame.stackButton:SetScript("OnClick", Stack_OnClick)

			frame.transferButton = CreateFrame("Button", nil, frame)
			frame.transferButton:SetPoint("LEFT", frame.stackButton, "RIGHT", 10, 0)
			frame.transferButton:SetSize(25, 25)
			StyleBagToolButton(frame.transferButton, MOD.media.depositIcon)
			frame.transferButton.ttText = L["Deposit All Reagents"]
			frame.transferButton:SetScript("OnEnter", Tooltip_Show)
			frame.transferButton:SetScript("OnLeave", Tooltip_Hide)
			frame.transferButton:SetScript("OnClick", DepositReagentBank)

			frame:SetPoint("BOTTOMLEFT", self.BankFrame, "BOTTOMRIGHT", 2, 0)
			self.ReagentFrame = frame
		end

		SV:UpdateSharedMedia()
	end
end

function MOD:RefreshTokens()
	local frame = MOD.MasterFrame;
	local index = 0;

	for i=1,MAX_WATCHED_TOKENS do
		local name,count,icon,currencyID = GetBackpackCurrencyInfo(i)
		local set = frame.currencyButton[i]
		set:ClearAllPoints()
		if name then
			set.icon:SetTexture(icon)
			if SV.db.Inventory.currencyFormat == 'ICON_TEXT' then
				set.text:SetText(name..': '..count)
			elseif SV.db.Inventory.currencyFormat == 'ICON' then
				set.text:SetText(count)
			end
			set.currencyID = currencyID;
			set:Show()
			index = index + 1;
		else
			set:Hide()
		end
	end

	if index == 0 then
		frame.bottomOffset = 8;
		if frame.currencyButton:IsShown() then
			frame.currencyButton:Hide()
			MOD.MasterFrame:UpdateLayout()
		end
		return
	elseif not frame.currencyButton:IsShown() then
		frame.bottomOffset = 28;
		frame.currencyButton:Show()
		MOD.MasterFrame:UpdateLayout()
	end

	frame.bottomOffset = 28;
	local set = frame.currencyButton;
	if index == 1 then
		set[1]:SetPoint("BOTTOM", set, "BOTTOM", -(set[1].text:GetWidth() / 2), 3)
	elseif index == 2 then
		set[1]:SetPoint("BOTTOM", set, "BOTTOM", -set[1].text:GetWidth()-set[1]:GetWidth() / 2, 3)
		frame.currencyButton[2]:SetPoint("BOTTOMLEFT", set, "BOTTOM", set[2]:GetWidth() / 2, 3)
	else
		set[1]:SetPoint("BOTTOMLEFT", set, "BOTTOMLEFT", 3, 3)
		set[2]:SetPoint("BOTTOM", set, "BOTTOM", -(set[2].text:GetWidth() / 3), 3)
		set[3]:SetPoint("BOTTOMRIGHT", set, "BOTTOMRIGHT", -set[3].text:GetWidth()-set[3]:GetWidth() / 2, 3)
	end
end

local function _isBagOpen(bagID)
	if(MOD.MasterFrame.Bags[0] and MOD.MasterFrame.Bags[0]:IsShown()) then
		return true
	elseif(MOD.BankFrame.Bags[bagID] and MOD.BankFrame.Bags[bagID]:IsShown()) then
		return true
	end
	return nil;
end

local function _openBags()
	--print('_openBags')
	GameTooltip:Hide()
	if(not MOD.MasterFrame:IsShown()) then
		MOD.MasterFrame:Show()
		MOD.MasterFrame:RefreshBags()
		if(SV.Tooltip) then
			SV.Tooltip.GameTooltip_SetDefaultAnchor(GameTooltip)
		end
		MOD.MasterFrame.editBox:SearchReset()
	end
end

local function _closeBags()
	--print('_closeBags')
	GameTooltip:Hide()
	if(MOD.MasterFrame:IsShown()) then
		MOD.MasterFrame:Hide()
		if(MOD.BankFrame) then
			MOD.BankFrame:Hide()
		end
		if(MOD.ReagentFrame) then
			MOD.ReagentFrame:Hide()
		end
		if(SV.Dock.CloseBreakStuff) then
			SV.Dock:CloseBreakStuff()
		end
		if(SV.Tooltip) then
			SV.Tooltip.GameTooltip_SetDefaultAnchor(GameTooltip)
		end
		MOD.MasterFrame.editBox:SearchReset()
	end
	NEXT_ACTION_TOGGLED = false
end

local function _openAllBags()
	--print('OpenAllBags --------->')
	NEXT_ACTION_ALLOWED = true
	NEXT_ACTION_TOGGLED = false
	NEXT_ACTION_FORCED = false
	_openBags()
end

local function _closeAllBags()
	--print('<--------- CloseAllBags')
	FORCED_OPEN = false
	FORCED_CLOSED = false
	NEXT_ACTION_ALLOWED = true
	NEXT_ACTION_FORCED = true
	NEXT_ACTION_TOGGLED = false
	_closeBags()
end

local function _openBackpack()
	--print('OpenBackpack --------->')
	if(FORCED_OPEN) then
		FORCED_OPEN = false
		FORCED_CLOSED = true
		ToggleBag(0)
		CloseAllBags()
	else
		--FORCED_CLOSED = NEXT_ACTION_FORCED
		NEXT_ACTION_ALLOWED = true
		if(NEXT_ACTION_TOGGLED) then
			_openBags()
		end
	end
	NEXT_ACTION_FORCED = false
end

local function _closeBackpack()
	--print('<--------- CloseBackpack')
	if(FORCED_CLOSED) then
		FORCED_OPEN = true
		FORCED_CLOSED = false
		CloseAllBags()
		ToggleBag(0)
	else
		NEXT_ACTION_ALLOWED = NEXT_ACTION_FORCED
		FORCED_OPEN = NEXT_ACTION_FORCED
		if(NEXT_ACTION_TOGGLED) then
			_closeBags()
		end
	end
	NEXT_ACTION_FORCED = false
end

local function _toggleByID(bagID)
	if(not bagID) then return end
	local size = GetContainerNumSlots(bagID);
	if((size > 0) or (bagID == KEYRING_CONTAINER)) then
		--print('ToggleBag: '..bagID)
		if(not MOD.MasterFrame:IsShown()) then
			_openBags()
		end
		if(MOD.MasterFrame.Bags[bagID]) then
			MOD.MasterFrame.Bags[bagID]:RefreshSlots()
		elseif(MOD.BankFrame and MOD.BankFrame.Bags[bagID]) then
			MOD.BankFrame.Bags[bagID]:RefreshSlots()
		elseif(MOD.ReagentFrame and MOD.ReagentFrame.Bags[bagID]) then
			MOD.ReagentFrame.Bags[bagID]:RefreshSlots()
		end
	end
end

local function _toggleAllBags()
	--print('[[ ToggleAllBags ]]')
	NEXT_ACTION_TOGGLED = true
	if(NEXT_ACTION_ALLOWED) then
		_openBags()
	else
		_closeBags()
	end
end

local function _toggleBackpack()
	--print('[[ ToggleBackpack ]]')
	NEXT_ACTION_TOGGLED = true
end

local function _closeSpecialWindows()
	--print('<--------- CloseSpecialWindows')
	CloseAllBags()
end

local _hook_OnModifiedClick = function(self, button)
	if(MerchantFrame and MerchantFrame:IsShown()) then return end;
    if(IsAltKeyDown() and (button == "RightButton")) then
    	local slotID = self:GetID()
    	local bagID = self:GetParent():GetID()
    	local itemID = GetContainerItemID(bagID, slotID);
    	if(itemID) then
    		if(MOD.private.junk[itemID]) then
    			if(self.JunkIcon) then self.JunkIcon:Hide() end
    			MOD.private.junk[itemID] = nil
	    	else
	    		if(self.JunkIcon) then self.JunkIcon:Show() end
	    		MOD.private.junk[itemID] = true
	    	end
    	end
    end
end

function MOD:BANKFRAME_OPENED()
	if(not self.BankFrame) then
		self:CreateBankOrReagentFrame()
	end
	self.BankFrame:UpdateLayout()

	if(not self.ReagentFrame) then
		self:CreateBankOrReagentFrame(true)
	end

	if(self.ReagentFrame) then
		self.ReagentFrame:UpdateLayout()
	end

	self:ModifyBags()

	self.BankFrame:Show()
	self.BankFrame:RefreshBags()
	self.MasterFrame:Show()
	self.MasterFrame:RefreshBags()
	self.RefreshTokens()
end

function MOD:BANKFRAME_CLOSED()
	if(self.BankFrame and self.BankFrame:IsShown()) then
		self.BankFrame:Hide()
	end
	if(self.ReagentFrame and self.ReagentFrame:IsShown()) then
		self.ReagentFrame:Hide()
	end
end

function MOD:PLAYERBANKBAGSLOTS_CHANGED()
	if(self.BankFrame) then
		self.BankFrame:UpdateLayout()
	end
	if(self.ReagentFrame) then
		self.ReagentFrame:UpdateLayout()
	end
end

function MOD:PLAYER_ENTERING_WORLD()
	self:UpdateGoldText()
	self.MasterFrame:RefreshBags()
end

local function ResetInventoryLogs()
	if MOD.public[realmKey] then
		if MOD.public[realmKey]["loot"] and MOD.public[realmKey]["loot"][nameKey] then MOD.public[realmKey]["loot"][nameKey] = {} end
		if MOD.public[realmKey]["gold"] and MOD.public[realmKey]["gold"][nameKey] then MOD.public[realmKey]["gold"][nameKey] = 0 end
	end
end
--[[
##########################################################
BUILD FUNCTION / UPDATE
##########################################################
]]--
function MOD:ReLoad()
	self:RefreshBagFrames()
	self:ModifyBags();
	self:ModifyBagBar();
end

function MOD:Load()
	local r,g,b = RAID_CLASS_COLORS[toonClass].r, RAID_CLASS_COLORS[toonClass].g, RAID_CLASS_COLORS[toonClass].b;
	local hexString = ("|cff%02x%02x%02x"):format(r * 255, g * 255, b * 255);

	if(not LOOT_CACHE) then LOOT_CACHE = {} end

	if(not self.private) then self.private = {} end
	if(not self.private.junk) then self.private.junk = {} end
	if(not self.public) then self.public = {} end
	if(not self.public[realmKey]) then
		self.public[realmKey] = {}
	end
	if(not self.public[realmKey]["loot"]) then
		self.public[realmKey]["loot"] = {}
	end
	if(not self.public[realmKey]["info"]) then
		self.public[realmKey]["info"] = {}
	end
	if(not self.public[realmKey]["loot"][nameKey]) then
		self.public[realmKey]["loot"][nameKey] = {}
	end
	if(not self.public[realmKey]["info"][nameKey]) then
		self.public[realmKey]["info"][nameKey] = hexString;
	end

	-- REMOVE DEPRECATED STORAGE
	if(self.public[realmKey]["bags"]) then
		local old = self.public[realmKey]["bags"]
		for toon,data in pairs(old) do
			if(not self.public[realmKey]["loot"][toon]) then self.public[realmKey]["loot"][toon] = {} end
			for bag,items in pairs(data) do
				for itemKey,amt in pairs(items) do
					local lastAmt = self.public[realmKey]["loot"][toon][itemKey] or 0;
					self.public[realmKey]["loot"][toon][itemKey] = (lastAmt + amt)
				end
			end
		end
		self.public[realmKey]["bags"] = nil
	end

	for index,_ in pairs(self.public[realmKey]["loot"][nameKey]) do
		if(type(index) ~= string) then
			self.public[realmKey]["loot"][nameKey][index] = nil
		end
	end

	self:UpdateStockpile();

	local journal = self.public[realmKey]["loot"]
	for altName,items in pairs(journal) do
		if(altName ~= nameKey) then
			for itemKey,amt in pairs(items) do
				if(not LOOT_CACHE[itemKey]) then
					LOOT_CACHE[itemKey] = {}
				end
				LOOT_CACHE[itemKey][altName] = amt
			end
		end
	end

	self:ModifyBagBar()
	self:CreateMasterFrame()
	self.MasterFrame:UpdateLayout()
	self:ModifyBags()

	self:InitializeMenus()

	BankFrame:UnregisterAllEvents()
	for i = 1, NUM_CONTAINER_FRAMES do
		local frame = _G["ContainerFrame"..i]
		if(frame) then frame:Die() end
	end

	hooksecurefunc("OpenAllBags", _openAllBags)
	hooksecurefunc("CloseAllBags", _closeAllBags)
	hooksecurefunc("OpenBackpack", _openBackpack)
	hooksecurefunc("CloseBackpack", _closeBackpack)
	hooksecurefunc("ToggleBag", _toggleByID)
	hooksecurefunc("ToggleAllBags", _toggleAllBags)
	hooksecurefunc("ToggleBackpack", _toggleBackpack)

	hooksecurefunc("BackpackTokenFrame_Update", self.RefreshTokens)
	hooksecurefunc("ContainerFrameItemButton_OnModifiedClick", _hook_OnModifiedClick)

	SV.Events:On("SPECIAL_FRAMES_CLOSED", _closeSpecialWindows, true);
	SV.Events:On("FULL_UI_RESET", ResetInventoryLogs, true);

	self:RegisterEvent("BANKFRAME_OPENED")
	self:RegisterEvent("BANKFRAME_CLOSED")
	self:RegisterEvent("INVENTORY_SEARCH_UPDATE")
	self:RegisterEvent("PLAYER_MONEY", "UpdateGoldText")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PLAYER_TRADE_MONEY", "UpdateGoldText")
	self:RegisterEvent("TRADE_MONEY_CHANGED", "UpdateGoldText")
	self:RegisterEvent("PLAYERBANKBAGSLOTS_CHANGED")

	StackSplitFrame:SetFrameStrata("DIALOG")

	SV.SystemAlert["BUY_BANK_SLOT"] = {
		text = CONFIRM_BUY_BANK_SLOT,
		button1 = YES,
		button2 = NO,
		OnAccept = function(self) PurchaseSlot() end,
		OnShow = function(self) MoneyFrame_Update(self.moneyFrame, GetBankSlotCost()) end,
		hasMoneyFrame = 1,
		timeout = 0,
		hideOnEscape = 1
	};

	SV.SystemAlert["CONFIRM_BUY_REAGENTBANK_TAB"] = {
		text = L["Purchase Reagents Bank?"],
		button1 = YES,
		button2 = NO,
		OnAccept = function(self) BuyReagentBank() end,
		OnShow = function(self)
			MoneyFrame_Update(self.moneyFrame, GetReagentBankCost());
			if(MOD.ReagentFrame) then
				MOD.ReagentFrame:UpdateLayout()
				MOD.ReagentFrame:Show()
				if(MOD.ReagentFrame.swapButton) then
					MOD.ReagentFrame.swapButton:SetNormalTexture(MOD.media.reagentIcon)
				end
			end
		end,
		hasMoneyFrame = 1,
		timeout = 0,
		hideOnEscape = 1
	};

	SV.SystemAlert["CANNOT_BUY_BANK_SLOT"] = {
		text = L["Can't buy anymore slots!"],
		button1 = ACCEPT,
		timeout = 0,
		whileDead = 1
	};

	SV.SystemAlert["NO_BANK_BAGS"] = {
		text = L["You must purchase a bank slot first!"],
		button1 = ACCEPT,
		timeout = 0,
		whileDead = 1
	};
end
