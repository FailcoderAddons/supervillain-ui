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

local math 		= _G.math;
local table 	= _G.table;
local rept      = string.rep;
local tsort,twipe = table.sort,table.wipe;
local floor,ceil  = math.floor, math.ceil;
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
local NUM_SEED_BARS = 7
local EnableListener, DisableListener, InventoryUpdate, LoadFarmingModeTools;
local seedButtons,farmToolButtons,portalButtons = {},{},{};
local DockButton, ModeLogsFrame;
local refSeeds = {[79102]={1},[89328]={1},[80590]={1},[80592]={1},[80594]={1},[80593]={1},[80591]={1},[89329]={1},[80595]={1},[89326]={1},[80809]={3},[95434]={4},[89848]={3},[95437]={4},[84782]={3},[95436]={4},[85153]={3},[95438]={4},[85162]={3},[95439]={4},[85158]={3},[95440]={4},[84783]={3},[95441]={4},[89849]={3},[95442]={4},[85163]={3},[95443]={4},[89847]={3},[95444]={4},[85216]={2},[85217]={2},[89202]={2},[85215]={2},[89233]={2},[89197]={2},[85219]={2},[91806]={2},[95449]={5},[95450]={6},[95451]={5},[95452]={6},[95457]={5},[95458]={6},[95447]={5},[95448]={6},[95445]={5},[95446]={6},[95454]={5},[95456]={6},[85267]={7},[85268]={7},[85269]={7}};
local refTools = {[79104]={30254},[80513]={30254},[89880]={30535},[89815]={31938}};
local refPortals = {[91850]={"Horde"},[91861]={"Horde"},[91862]={"Horde"},[91863]={"Horde"},[91860]={"Alliance"},[91864]={"Alliance"},[91865]={"Alliance"},[91866]={"Alliance"}};
--[[
##########################################################
LOCAL FUNCTIONS
##########################################################
]]--
local Scroll_OnValueChanged = function(self,argValue)
	FarmModeFrame:SetVerticalScroll(argValue)
end

local Scroll_OnMouseWheel = function(self, delta)
	local scroll = self:GetVerticalScroll();
	local value = (scroll - (20 * delta));
	if value < -1 then
		value = 0
	end
	if value > 420 then
		value = 420
	end
	self:SetVerticalScroll(value)
	self.slider:SetValue(value)
end

local function FindItemInBags(itemId)
	for container = 0, NUM_BAG_SLOTS do
		for slot = 1, GetContainerNumSlots(container) do
			if itemId == GetContainerItemID(container, slot) then
				return container, slot
			end
		end
	end
end
--[[
##########################################################
EVENT HANDLER
##########################################################
]]--
do
	local FarmEventHandler = CreateFrame("Frame")

	local ButtonUpdate = function(button)
		button.items = GetItemCount(button.itemId)
		if button.text then
			button.text:SetText(button.items)
		end
		button.icon:SetDesaturated(button.items == 0)
		button.icon:SetAlpha(button.items == 0 and .25 or 1)
	end

	local InFarmZone = function()
		local zone = GetSubZoneText()
		if (zone == L["Sunsong Ranch"] or zone == L["The Halfhill Market"]) then
			if PLUGIN.Farming.ToolsLoaded and PLUGIN.ModeAlert:IsShown() then
				PLUGIN.TitleWindow:Clear()
	 			PLUGIN.TitleWindow:AddMessage("|cff22ff11Farming Mode|r")
			end
			return true
		else
			if PLUGIN.Farming.ToolsLoaded and PLUGIN.ModeAlert:IsShown() then
				PLUGIN.TitleWindow:Clear()
	 			PLUGIN.TitleWindow:AddMessage("|cffff2211Must be in Sunsong Ranch|r")
			end
			return false
		end
	end

	local UpdateFarmtoolCooldown = function()
		for i = 1, NUM_SEED_BARS do
			for _, button in ipairs(seedButtons[i]) do
				if button.cooldown then
					button.cooldown:SetCooldown(GetItemCooldown(button.itemId))
				end
			end
		end
		for _, button in ipairs(farmToolButtons) do
			if button.cooldown then
				button.cooldown:SetCooldown(GetItemCooldown(button.itemId))
			end
		end
		for _, button in ipairs(portalButtons) do
			if button.cooldown then
				button.cooldown:SetCooldown(GetItemCooldown(button.itemId))
			end
		end
	end

	local Farm_OnEvent = function(self, event, ...)
		if(InCombatLockdown()) then return end
		if(event == "ZONE_CHANGED") then
			local inZone = InFarmZone()
			if((not inZone) and CONFIGS.farming.droptools) then
				for k, v in pairs(refTools) do
					local container, slot = FindItemInBags(k)
					if container and slot then
						PickupContainerItem(container, slot)
						DeleteCursorItem()
					end
				end
			end
			InventoryUpdate()
		elseif(event == "BAG_UPDATE") then
			InventoryUpdate()
		elseif(event == "BAG_UPDATE_COOLDOWN") then
			UpdateFarmtoolCooldown()
		end
	end

	InventoryUpdate = function()
		if InCombatLockdown() then
			FarmEventHandler:RegisterEvent("PLAYER_REGEN_ENABLED", InventoryUpdate)
			return
		else
			FarmEventHandler:UnregisterEvent("PLAYER_REGEN_ENABLED")
	 	end
		for i = 1, NUM_SEED_BARS do
			for _, button in ipairs(seedButtons[i]) do
				ButtonUpdate(button)
			end
		end
		for _, button in ipairs(farmToolButtons) do
			ButtonUpdate(button)
		end
		for _, button in ipairs(portalButtons) do
			ButtonUpdate(button)
		end

		PLUGIN:RefreshFarmingTools()
	end

	EnableListener = function()
		FarmEventHandler:RegisterEvent("ZONE_CHANGED")
		FarmEventHandler:RegisterEvent("BAG_UPDATE")
		FarmEventHandler:RegisterEvent("BAG_UPDATE_COOLDOWN")
		FarmEventHandler:SetScript("OnEvent", Farm_OnEvent)
	end

	DisableListener = function()
		FarmEventHandler:UnregisterAllEvents()
		FarmEventHandler:SetScript("OnEvent", nil)
	end
end
--[[
##########################################################
LOADING HANDLER
##########################################################
]]--
do
	local seedsort = function(a, b) return a.sortname < b.sortname end

	local SeedToSoil = function(group, itemId)
		if(UnitName("target") ~= L["Tilled Soil"]) then return false; end
		for i, v in pairs(group) do
			if i == itemId then return true end
		end
		return false
	end

	local Button_OnEnter = function(self)
		GameTooltip:SetOwner(self, 'ANCHOR_TOPLEFT', 2, 4)
		GameTooltip:ClearLines()
		GameTooltip:AddDoubleLine(self.sortname)
		if self.allowDrop then
			GameTooltip:AddLine(L['Right-click to drop the item.'])
		end
		GameTooltip:Show()
	end

	local Button_OnLeave = function()
		GameTooltip:Hide()
	end

	local Button_OnMouseDown = function(self, mousebutton)
		if InCombatLockdown() then return end
		if mousebutton == "LeftButton" then
			self:SetAttribute("type", self.buttonType)
			self:SetAttribute(self.buttonType, self.sortname)
			if(SeedToSoil(refSeeds, self.itemId)) then
				local container, slot = FindItemInBags(self.itemId)
				if container and slot then
					self:SetAttribute("type", "macro")
					self:SetAttribute("macrotext", format("/targetexact %s \n/use %s %s", L["Tilled Soil"], container, slot))
				end
			end
			if self.cooldown then
				self.cooldown:SetCooldown(GetItemCooldown(self.itemId))
			end
		elseif mousebutton == "RightButton" and self.allowDrop then
			self:SetAttribute("type", "click")
			local container, slot = FindItemInBags(self.itemId)
			if container and slot then
				PickupContainerItem(container, slot)
				DeleteCursorItem()
			end
		end
	end

	local function CreateFarmingButton(index, owner, buttonName, buttonType, name, texture, allowDrop, showCount)
		local BUTTONSIZE = owner.ButtonSize;
		local button = CreateFrame("Button", ("FarmingButton"..buttonName.."%d"):format(index), owner, "SecureActionButtonTemplate")
		button:SetStyle("!_Frame", "Transparent")
		button.Panel:SetFrameLevel(0)
		button:SetNormalTexture(nil)
		button:SetSize(BUTTONSIZE, BUTTONSIZE)
		button.sortname = name
		button.itemId = index
		button.allowDrop = allowDrop
		button.buttonType = buttonType
		button.items = GetItemCount(index)
		button.icon = button:CreateTexture(nil, "OVERLAY", nil, 2)
		button.icon:SetTexture(texture)
		button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		button.icon:InsetPoints(button,2,2)
		if showCount then
			button.text = button:CreateFontString(nil, "OVERLAY")
			button.text:SetFontObject(SVUI_Font_CraftNumber)
			button.text:SetPoint("BOTTOMRIGHT", button, 1, 2)
		end
		button.cooldown = CreateFrame("Cooldown", ("FarmingButton"..buttonName.."%dCooldown"):format(index), button)
		button.cooldown:SetAllPoints(button)
		button:SetScript("OnEnter", Button_OnEnter)
		button:SetScript("OnLeave", Button_OnLeave)
		button:SetScript("OnMouseDown", Button_OnMouseDown)
		return button
	end

	function LoadFarmingModeTools()
		local itemError = false
		for k, v in pairs(refSeeds) do
			if select(2, GetItemInfo(k)) == nil then print(GetItemInfo(k)) itemError = true end
		end
		for k, v in pairs(refTools) do
			if select(2, GetItemInfo(k)) == nil then print(GetItemInfo(k)) itemError = true end
		end
		for k, v in pairs(refPortals) do
			if select(2, GetItemInfo(k)) == nil then print(GetItemInfo(k)) itemError = true end
		end
		if InCombatLockdown() or itemError then
			if PLUGIN.FarmLoadTimer then
				PLUGIN.FarmLoadTimer = nil
				PLUGIN.Farming:Disable()
				PLUGIN.TitleWindow:AddMessage("|cffffff11The Loader is Being Dumb...|r|cffff1111PLEASE TRY AGAIN|r")
				return
			end
			PLUGIN.TitleWindow:AddMessage("|cffffff11Loading Farm Tools...|r|cffff1111PLEASE WAIT|r")
			PLUGIN.FarmLoadTimer = SV.Timers:ExecuteTimer(LoadFarmingModeTools, 5)
		else
			local horizontal = CONFIGS.farming.toolbardirection == 'HORIZONTAL'

			local seeds, farmtools, portals = {},{},{}

			for k, v in pairs(refSeeds) do
				seeds[k] = { v[1], GetItemInfo(k) }
			end

			for k, v in pairs(refTools) do
				farmtools[k] = { v[1], GetItemInfo(k) }
			end

			for k, v in pairs(refPortals) do
				portals[k] = { v[1], GetItemInfo(k) }
			end

			for i = 1, NUM_SEED_BARS do
				local seedBar = _G["FarmSeedBar"..i]
				seedButtons[i] = seedButtons[i] or {}
				local sbc = 1;
				for k, v in pairs(seeds) do
					if v[1] == i then
						seedButtons[i][sbc] = CreateFarmingButton(k, seedBar, "SeedBar"..i.."Seed", "item", v[2], v[11], false, true);
						sbc = sbc + 1;
					end
					tsort(seedButtons[i], seedsort)
				end
			end

			local ftc = 1;
			for k, v in pairs(farmtools) do
				farmToolButtons[ftc] = CreateFarmingButton(k, _G["FarmToolBar"], "Tools", "item", v[2], v[11], true, false);
				ftc = ftc + 1;
			end

			local playerFaction = UnitFactionGroup('player')
			local pbc = 1;
			for k, v in pairs(portals) do
				if v[1] == playerFaction then
					portalButtons[pbc] = CreateFarmingButton(k, _G["FarmPortalBar"], "Portals", "item", v[2], v[11], false, true);
					pbc = pbc + 1;
				end
			end

			PLUGIN.Farming.Loaded = true
			PLUGIN.FarmLoadTimer = nil
			PLUGIN.FarmEnableTimer = SV.Timers:ExecuteTimer(PLUGIN.Farming.Enable, 1.5)
		end
	end
end
--[[
##########################################################
CORE FUNCTIONS
##########################################################
]]--
PLUGIN.Farming = {};
PLUGIN.Farming.Loaded = false;
PLUGIN.Farming.ToolsLoaded = false;

function PLUGIN.Farming:Enable()
	if InCombatLockdown() then return end

 	PLUGIN:ModeLootLoader("Farming", "Farming Mode", "This mode will provide you \nwith fast-access buttons for each \nof your seeds and farming tools.");

 	PLUGIN.TitleWindow:Clear()
	if(not PLUGIN.Farming.Loaded) then
		PLUGIN.TitleWindow:AddMessage("|cffffff11Loading Farm Tools...|r")
		LoadFarmingModeTools()
		return
	else
		if not PLUGIN.Farming.ToolsLoaded then
			PlaySoundFile("Sound\\Effects\\DeathImpacts\\mDeathImpactColossalDirtA.wav")
			PLUGIN.TitleWindow:AddMessage("|cff22ff11Farming Mode|r")
			PLUGIN.ModeAlert:Show()
			InventoryUpdate()
			PLUGIN.Farming.ToolsLoaded = true
			EnableListener()
			if not FarmModeFrame:IsShown() then FarmModeFrame:Show() end
			if(not PLUGIN.Docklet:IsShown()) then DockButton:Click() end
		end
	end
end

function PLUGIN.Farming:Disable()
	if(InCombatLockdown() or (not PLUGIN.Farming.Loaded) or (not PLUGIN.Farming.ToolsLoaded)) then
		DisableListener()
		return
	end
	if CONFIGS.farming.droptools then
		for k, v in pairs(refTools) do
			local container, slot = FindItemInBags(k)
			if container and slot then
				PickupContainerItem(container, slot)
				DeleteCursorItem()
			end
		end
	end
	if FarmModeFrame:IsShown() then FarmModeFrame:Hide() end
	PLUGIN.Farming.ToolsLoaded = false
	DisableListener()
end
--[[
##########################################################
CORE FUNCTIONS
##########################################################
]]--
function PLUGIN:RefreshFarmingTools()
	local count, horizontal = 0, CONFIGS.farming.toolbardirection == 'HORIZONTAL'
	local BUTTONSPACE = CONFIGS.farming.buttonspacing or 2;
	local lastBar;
	if not FarmToolBar:IsShown() then
		_G["FarmSeedBarAnchor"]:SetPoint("TOPLEFT", _G["FarmModeFrameSlots"], "TOPLEFT", 0, 0)
	else
		_G["FarmSeedBarAnchor"]:SetPoint("TOPLEFT", _G["FarmToolBar"], horizontal and "BOTTOMLEFT" or "TOPRIGHT", 0, 0)
	end

	for i = 1, NUM_SEED_BARS do

		local seedBar = _G["FarmSeedBar"..i]
		count = 0
		if(seedButtons[i]) then
			for i, button in ipairs(seedButtons[i]) do
				local BUTTONSIZE = seedBar.ButtonSize;
				button:SetPoint("TOPLEFT", seedBar, "TOPLEFT", horizontal and (count * (BUTTONSIZE + BUTTONSPACE) + 1) or 1, horizontal and -1 or -(count * (BUTTONSIZE + BUTTONSPACE) + 1))
				button:SetSize(BUTTONSIZE,BUTTONSIZE)
				if (not CONFIGS.farming.onlyactive or (CONFIGS.farming.onlyactive and button.items > 0)) then
					button.icon:SetVertexColor(1,1,1)
					count = count + 1
				elseif (not CONFIGS.farming.onlyactive and button.items <= 0) then
					button:Show()
					button.icon:SetVertexColor(0.25,0.25,0.25)
					count = count + 1
				else
					button:Hide()
				end
			end
		end
		if(CONFIGS.farming.onlyactive and not CONFIGS.farming.undocked) then
			if count==0 then
				seedBar:Hide()
			else
				seedBar:Show()
				if(not lastBar) then
					seedBar:SetPoint("TOPLEFT", _G["FarmSeedBarAnchor"], "TOPLEFT", 0, 0)
				else
					seedBar:SetPoint("TOPLEFT", lastBar, horizontal and "BOTTOMLEFT" or "TOPRIGHT", 0, 0)
				end
				lastBar = seedBar
			end
		end
	end
	count = 0;
	lastBar = nil;
	FarmToolBar:ClearAllPoints()
	FarmToolBar:SetAllPoints(FarmToolBarAnchor)
	for i, button in ipairs(farmToolButtons) do
		local BUTTONSIZE = FarmToolBar.ButtonSize;
		button:SetPoint("TOPLEFT", FarmToolBar, "TOPLEFT", horizontal and (count * (BUTTONSIZE + BUTTONSPACE) + 1) or 1, horizontal and -1 or -(count * (BUTTONSIZE + BUTTONSPACE) + 1))
		button:SetSize(BUTTONSIZE,BUTTONSIZE)
		if (not CONFIGS.farming.onlyactive or (CONFIGS.farming.onlyactive and button.items > 0)) then
			button:Show()
			button.icon:SetVertexColor(1,1,1)
			count = count + 1
		elseif (not CONFIGS.farming.onlyactive and button.items == 0) then
			button:Show()
			button.icon:SetVertexColor(0.25,0.25,0.25)
			count = count + 1
		else
			button:Hide()
		end
	end
	if(CONFIGS.farming.onlyactive and not CONFIGS.farming.undocked) then
		if count==0 then
			FarmToolBarAnchor:Hide()
			FarmPortalBar:SetPoint("TOPLEFT", FarmModeFrameSlots, "TOPLEFT", 0, 0)
		else
			FarmToolBarAnchor:Show()
			FarmPortalBar:SetPoint("TOPLEFT", FarmToolBarAnchor, "TOPRIGHT", 0, 0)
		end
	end
	count = 0;
	FarmPortalBar:ClearAllPoints()
	FarmPortalBar:SetAllPoints(FarmPortalBarAnchor)
	for i, button in ipairs(portalButtons) do
		local BUTTONSIZE = FarmPortalBar.ButtonSize;
		button:SetPoint("TOPLEFT", FarmPortalBar, "TOPLEFT", horizontal and (count * (BUTTONSIZE + BUTTONSPACE) + 1) or 1, horizontal and -1 or -(count * (BUTTONSIZE + BUTTONSPACE) + 1))
		button:SetSize(BUTTONSIZE,BUTTONSIZE)
		if (not CONFIGS.farming.onlyactive or (CONFIGS.farming.onlyactive and button.items > 0)) then
			button:Show()
			button.icon:SetVertexColor(1,1,1)
			count = count + 1
		elseif (not CONFIGS.farming.onlyactive and button.items == 0) then
			button:Show()
			button.icon:SetVertexColor(0.25,0.25,0.25)
			count = count + 1
		else
			button:Hide()
		end
	end
	if(CONFIGS.farming.onlyactive) then
		if count==0 then
			FarmPortalBar:Hide()
		else
			FarmPortalBar:Show()
		end
	end
end

function PLUGIN:PrepareFarmingTools()
	CONFIGS = SV.db[self.Schema];
	local horizontal = CONFIGS.farming.toolbardirection == "HORIZONTAL"
	local BUTTONSPACE = CONFIGS.farming.buttonspacing or 2;

	ModeLogsFrame = self.LogWindow;
	DockButton = self.Docklet.Button

	if not CONFIGS.farming.undocked then
		local bgTex = [[Interface\BUTTONS\WHITE8X8]]
		local bdTex = SV.media.statusbar.glow
		local farmingDocklet = CreateFrame("ScrollFrame", "FarmModeFrame", ModeLogsFrame);
		farmingDocklet:SetPoint("TOPLEFT", ModeLogsFrame, 31, -3);
		farmingDocklet:SetPoint("BOTTOMRIGHT", ModeLogsFrame, -3, 3);
		farmingDocklet:EnableMouseWheel(true);

		local farmingDockletSlots = CreateFrame("Frame", "FarmModeFrameSlots", farmingDocklet);
		farmingDockletSlots:SetPoint("TOPLEFT", farmingDocklet, 0, 0);
		farmingDockletSlots:SetWidth(farmingDocklet:GetWidth())
		farmingDockletSlots:SetHeight(500);
		farmingDockletSlots:SetFrameLevel(farmingDocklet:GetFrameLevel() + 1)
		farmingDocklet:SetScrollChild(farmingDockletSlots)

		local slotSlider = CreateFrame("Slider", "FarmModeSlotSlider", farmingDocklet);
		slotSlider:SetHeight(farmingDocklet:GetHeight() - 3);
		slotSlider:SetWidth(18);
		slotSlider:SetPoint("TOPLEFT", farmingDocklet, -28, 0);
		slotSlider:SetPoint("BOTTOMLEFT", farmingDocklet, -28, 0);
		slotSlider:SetBackdrop({bgFile = bgTex, edgeFile = bdTex, edgeSize = 4, insets = {left = 3, right = 3, top = 3, bottom = 3}});
		slotSlider:SetFrameLevel(6)
		slotSlider:SetStyle("!_Frame", "Transparent", true);
		slotSlider:SetThumbTexture("Interface\\Buttons\\UI-ScrollBar-Knob");
		slotSlider:SetOrientation("VERTICAL");
		slotSlider:SetValueStep(5);
		slotSlider:SetMinMaxValues(1, 420);
		slotSlider:SetValue(1);

		farmingDocklet.slider = slotSlider;
		slotSlider:SetScript("OnValueChanged", Scroll_OnValueChanged)
		farmingDocklet:SetScript("OnMouseWheel", Scroll_OnMouseWheel);

		local parentWidth = FarmModeFrameSlots:GetWidth() - 31
		local BUTTONSIZE = (parentWidth / (horizontal and 10 or 8));
		local TOOLSIZE = (parentWidth / 8);

		-- FARM TOOLS
		local farmToolBarAnchor = CreateFrame("Frame", "FarmToolBarAnchor", farmingDockletSlots)
		farmToolBarAnchor:SetPoint("TOPLEFT", farmingDockletSlots, "TOPLEFT", 0, 0)
		farmToolBarAnchor:SetSize(horizontal and ((TOOLSIZE + BUTTONSPACE) * 4) or (TOOLSIZE + BUTTONSPACE), horizontal and (TOOLSIZE + BUTTONSPACE) or ((TOOLSIZE + BUTTONSPACE) * 4))

		local farmToolBar = CreateFrame("Frame", "FarmToolBar", farmToolBarAnchor)
		farmToolBar:SetSize(horizontal and ((TOOLSIZE + BUTTONSPACE) * 4) or (TOOLSIZE + BUTTONSPACE), horizontal and (TOOLSIZE + BUTTONSPACE) or ((TOOLSIZE + BUTTONSPACE) * 4))
		farmToolBar:SetPoint("TOPLEFT", farmToolBarAnchor, "TOPLEFT", (horizontal and BUTTONSPACE or (TOOLSIZE + BUTTONSPACE)), (horizontal and -(TOOLSIZE + BUTTONSPACE) or -BUTTONSPACE))
		farmToolBar.ButtonSize = TOOLSIZE;

		-- PORTALS
		local farmPortalBarAnchor = CreateFrame("Frame", "FarmPortalBarAnchor", farmingDockletSlots)
		farmPortalBarAnchor:SetPoint("TOPLEFT", farmToolBarAnchor, "TOPRIGHT", 0, 0)
		farmPortalBarAnchor:SetSize(horizontal and ((TOOLSIZE + BUTTONSPACE) * 4) or (TOOLSIZE + BUTTONSPACE), horizontal and (TOOLSIZE + BUTTONSPACE) or ((TOOLSIZE + BUTTONSPACE) * 4))

		local farmPortalBar = CreateFrame("Frame", "FarmPortalBar", farmPortalBarAnchor)
		farmPortalBar:SetSize(horizontal and ((TOOLSIZE + BUTTONSPACE) * 4) or (TOOLSIZE + BUTTONSPACE), horizontal and (TOOLSIZE + BUTTONSPACE) or ((TOOLSIZE + BUTTONSPACE) * 4))
		farmPortalBar:SetPoint("TOPLEFT", farmPortalBarAnchor, "TOPLEFT", (horizontal and BUTTONSPACE or (TOOLSIZE + BUTTONSPACE)), (horizontal and -(TOOLSIZE + BUTTONSPACE) or -BUTTONSPACE))
		farmPortalBar.ButtonSize = TOOLSIZE;

		-- SEEDS
		local farmSeedBarAnchor = CreateFrame("Frame", "FarmSeedBarAnchor", farmingDockletSlots)
		farmSeedBarAnchor:SetPoint("TOPLEFT", farmPortalBarAnchor, horizontal and "BOTTOMLEFT" or "TOPRIGHT", 0, 0)
		farmSeedBarAnchor:SetSize(horizontal and ((BUTTONSIZE + BUTTONSPACE) * 10) or ((BUTTONSIZE + BUTTONSPACE) * 8), horizontal and ((BUTTONSIZE + BUTTONSPACE) * 8) or ((BUTTONSIZE + BUTTONSPACE) * 10))

		for i = 1, NUM_SEED_BARS do
			local seedBar = CreateFrame("Frame", "FarmSeedBar"..i, farmSeedBarAnchor)
			seedBar.ButtonSize = BUTTONSIZE;
			seedBar:SetSize(horizontal and ((BUTTONSIZE + BUTTONSPACE) * 10) or (BUTTONSIZE + BUTTONSPACE), horizontal and (BUTTONSIZE + BUTTONSPACE) or ((BUTTONSIZE + BUTTONSPACE) * 10))
			if i == 1 then
				seedBar:SetPoint("TOPLEFT", farmSeedBarAnchor, "TOPLEFT", 0, 0)
			else
				seedBar:SetPoint("TOPLEFT", "FarmSeedBar"..i-1, horizontal and "BOTTOMLEFT" or "TOPRIGHT", 0, 0)
			end
		end

		farmingDocklet:Hide()
	else
		local BUTTONSIZE = CONFIGS.farming.buttonsize or 35;

		-- SEEDS
		local farmSeedBarAnchor = CreateFrame("Frame", "FarmSeedBarAnchor", UIParent)
		farmSeedBarAnchor:SetPoint("TOPRIGHT", SV.Screen, "TOPRIGHT", -40, -300)
		farmSeedBarAnchor:SetSize(horizontal and ((BUTTONSIZE + BUTTONSPACE) * 10) or ((BUTTONSIZE + BUTTONSPACE) * 8), horizontal and ((BUTTONSIZE + BUTTONSPACE) * 8) or ((BUTTONSIZE + BUTTONSPACE) * 10))
		for i = 1, NUM_SEED_BARS do
			local seedBar = CreateFrame("Frame", "FarmSeedBar"..i, farmSeedBarAnchor)
			seedBar:SetSize(horizontal and ((BUTTONSIZE + BUTTONSPACE) * 10) or (BUTTONSIZE + BUTTONSPACE), horizontal and (BUTTONSIZE + BUTTONSPACE) or ((BUTTONSIZE + BUTTONSPACE) * 10))
			seedBar:SetPoint("TOPRIGHT", _G["FarmSeedBarAnchor"], "TOPRIGHT", (horizontal and 0 or -((BUTTONSIZE + BUTTONSPACE) * i)), (horizontal and -((BUTTONSIZE + BUTTONSPACE) * i) or 0))
			seedBar.ButtonSize = BUTTONSIZE;
		end
		SV.Mentalo:Add(farmSeedBarAnchor, "Farming Seeds")

		-- FARM TOOLS
		local farmToolBarAnchor = CreateFrame("Frame", "FarmToolBarAnchor", UIParent)
		farmToolBarAnchor:SetPoint("TOPRIGHT", farmSeedBarAnchor, horizontal and "BOTTOMRIGHT" or "TOPLEFT", horizontal and 0 or -(BUTTONSPACE * 2), horizontal and -(BUTTONSPACE * 2) or 0)
		farmToolBarAnchor:SetSize(horizontal and ((BUTTONSIZE + BUTTONSPACE) * 4) or (BUTTONSIZE + BUTTONSPACE), horizontal and (BUTTONSIZE + BUTTONSPACE) or ((BUTTONSIZE + BUTTONSPACE) * 4))
		local farmToolBar = CreateFrame("Frame", "FarmToolBar", farmToolBarAnchor)
		farmToolBar:SetSize(horizontal and ((BUTTONSIZE + BUTTONSPACE) * 4) or (BUTTONSIZE + BUTTONSPACE), horizontal and (BUTTONSIZE + BUTTONSPACE) or ((BUTTONSIZE + BUTTONSPACE) * 4))
		farmToolBar:SetPoint("TOPRIGHT", farmToolBarAnchor, "TOPRIGHT", (horizontal and -BUTTONSPACE or -(BUTTONSIZE + BUTTONSPACE)), (horizontal and -(BUTTONSIZE + BUTTONSPACE) or -BUTTONSPACE))
		farmToolBar.ButtonSize = BUTTONSIZE;
		SV.Mentalo:Add(farmToolBarAnchor, "Farming Tools")

		-- PORTALS
		local farmPortalBarAnchor = CreateFrame("Frame", "FarmPortalBarAnchor", UIParent)
		farmPortalBarAnchor:SetPoint("TOPRIGHT", farmToolBarAnchor, horizontal and "BOTTOMRIGHT" or "TOPLEFT", horizontal and 0 or -(BUTTONSPACE * 2), horizontal and -(BUTTONSPACE * 2) or 0)
		farmPortalBarAnchor:SetSize(horizontal and ((BUTTONSIZE + BUTTONSPACE) * 4) or (BUTTONSIZE + BUTTONSPACE), horizontal and (BUTTONSIZE + BUTTONSPACE) or ((BUTTONSIZE + BUTTONSPACE) * 4))
		local farmPortalBar = CreateFrame("Frame", "FarmPortalBar", farmPortalBarAnchor)
		farmPortalBar:SetSize(horizontal and ((BUTTONSIZE + BUTTONSPACE) * 4) or (BUTTONSIZE + BUTTONSPACE), horizontal and (BUTTONSIZE + BUTTONSPACE) or ((BUTTONSIZE + BUTTONSPACE) * 4))
		farmPortalBar:SetPoint("TOPRIGHT", farmPortalBarAnchor, "TOPRIGHT", (horizontal and -BUTTONSPACE or -(BUTTONSIZE + BUTTONSPACE)), (horizontal and -(BUTTONSIZE + BUTTONSPACE) or -BUTTONSPACE))
		farmPortalBar.ButtonSize = BUTTONSIZE;
		SV.Mentalo:Add(farmPortalBarAnchor, "Farming Portals")
	end
end
