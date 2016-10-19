--[[
##########################################################
S V U I   By: Failcoder
########################################################## 
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local unpack 	= _G.unpack;
local select 	= _G.select;
local pairs 	= _G.pairs;
--[[ 
########################################################## 
GET ADDON DATA
##########################################################
]]--
local SV = _G['SVUI'];
local L = SV.L;
local MOD = SV.Skins;
local Schema = MOD.Schema;
--[[ 
########################################################## 
ATLASLOOT
##########################################################
]]--
local timeLapse = 0;
local nineisthere = {"AtlasLootCompareFrameSortButton_7","AtlasLootCompareFrameSortButton_8","AtlasLootCompareFrameSortButton_9"}
local StripAllTextures = {"AtlasLootDefaultFrame","AtlasLootDefaultFrame_ScrollFrame","AtlasLootItemsFrame","AtlasLootPanel","AtlasLootCompareFrame","AtlasLootCompareFrame_ScrollFrameMainFilterScrollChildFrame","AtlasLootCompareFrame_ScrollFrameItemFrame","AtlasLootCompareFrame_ScrollFrameMainFilter","AtlasLootCompareFrameSortButton_Name","AtlasLootCompareFrameSortButton_Rarity","AtlasLootCompareFrameSortButton_1","AtlasLootCompareFrameSortButton_2","AtlasLootCompareFrameSortButton_3","AtlasLootCompareFrameSortButton_4","AtlasLootCompareFrameSortButton_5","AtlasLootCompareFrameSortButton_6"}

local SetTemplateDefault = {"AtlasLootCompareFrameSortButton_Name","AtlasLootCompareFrameSortButton_Rarity","AtlasLootCompareFrameSortButton_1","AtlasLootCompareFrameSortButton_2","AtlasLootCompareFrameSortButton_3","AtlasLootCompareFrameSortButton_4","AtlasLootCompareFrameSortButton_5","AtlasLootCompareFrameSortButton_6"}

local buttons = {"AtlasLoot_AtlasInfoFrame_ToggleALButton","AtlasLootPanelSearch_SearchButton","AtlasLootDefaultFrame_CompareFrame","AtlasLootPanelSearch_ClearButton","AtlasLootPanelSearch_LastResultButton","AtlasLoot10Man25ManSwitch","AtlasLootItemsFrame_BACK","AtlasLootCompareFrameSearch_ClearButton","AtlasLootCompareFrameSearch_SearchButton","AtlasLootCompareFrame_WishlistButton","AtlasLootCompareFrame_CloseButton2"}

local function AL_OnShow(self, event, ...)
	AtlasLootPanel:SetPoint("TOP", AtlasLootDefaultFrame, "BOTTOM", 0, -1)
	AtlasLootQuickLooksButton:SetPoint("BOTTOM", AtlasLootItemsFrame, "BOTTOM", 53, 33)
	AtlasLootPanelSearch_Box:ClearAllPoints()
	AtlasLootPanelSearch_Box:SetPoint("TOP", AtlasLoot_PanelButton_7, "BOTTOM", 80, -10)
	AtlasLootPanelSearch_SearchButton:SetPoint("LEFT", AtlasLootPanelSearch_Box, "RIGHT", 5, 0)
	AtlasLootPanelSearch_SelectModuel:SetPoint("LEFT", AtlasLootPanelSearch_SearchButton, "RIGHT", 5, 0)
	AtlasLootPanelSearch_ClearButton:SetPoint("LEFT", AtlasLootPanelSearch_SelectModuel, "RIGHT", 5, 0)
	AtlasLootPanelSearch_LastResultButton:SetPoint("LEFT", AtlasLootPanelSearch_ClearButton, "RIGHT", 5, 0)
	AtlasLoot10Man25ManSwitch:SetPoint("BOTTOM", AtlasLootItemsFrame, "BOTTOM", -130, 4)
	if AtlasLoot_PanelButton_2 then AtlasLoot_PanelButton_2:SetPoint("LEFT", AtlasLoot_PanelButton_1, "RIGHT", 1, 0) end
	if AtlasLoot_PanelButton_3 then AtlasLoot_PanelButton_3:SetPoint("LEFT", AtlasLoot_PanelButton_2, "RIGHT", 1, 0) end
	if AtlasLoot_PanelButton_4 then AtlasLoot_PanelButton_4:SetPoint("LEFT", AtlasLoot_PanelButton_3, "RIGHT", 1, 0) end
	if AtlasLoot_PanelButton_5 then AtlasLoot_PanelButton_5:SetPoint("LEFT", AtlasLoot_PanelButton_4, "RIGHT", 1, 0) end
	if AtlasLoot_PanelButton_6 then AtlasLoot_PanelButton_6:SetPoint("LEFT", AtlasLoot_PanelButton_5, "RIGHT", 1, 0) end
	if AtlasLoot_PanelButton_8 then AtlasLoot_PanelButton_8:SetPoint("LEFT", AtlasLoot_PanelButton_7, "RIGHT", 1, 0) end
	if AtlasLoot_PanelButton_9 then AtlasLoot_PanelButton_9:SetPoint("LEFT", AtlasLoot_PanelButton_8, "RIGHT", 1, 0) end
	if AtlasLoot_PanelButton_10 then AtlasLoot_PanelButton_10:SetPoint("LEFT", AtlasLoot_PanelButton_9, "RIGHT", 1, 0) end
	if AtlasLoot_PanelButton_11 then AtlasLoot_PanelButton_11:SetPoint("LEFT", AtlasLoot_PanelButton_10, "RIGHT", 1, 0) end
	if AtlasLoot_PanelButton_12 then AtlasLoot_PanelButton_12:SetPoint("LEFT", AtlasLoot_PanelButton_11, "RIGHT", 1, 0) end
	AtlasLootCompareFrameSortButton_Rarity:SetPoint("LEFT", AtlasLootCompareFrameSortButton_Name, "RIGHT", 1, 0)
	AtlasLootCompareFrameSortButton_Rarity:SetWidth(80)
	AtlasLootCompareFrameSortButton_Name:SetWidth(80)
	AtlasLootCompareFrameSortButton_1:SetPoint("LEFT", AtlasLootCompareFrameSortButton_Rarity, "RIGHT", 1, 0)
	AtlasLootCompareFrameSortButton_2:SetPoint("LEFT", AtlasLootCompareFrameSortButton_1, "RIGHT", 1, 0)
	AtlasLootCompareFrameSortButton_3:SetPoint("LEFT", AtlasLootCompareFrameSortButton_2, "RIGHT", 1, 0)
	AtlasLootCompareFrameSortButton_4:SetPoint("LEFT", AtlasLootCompareFrameSortButton_3, "RIGHT", 1, 0)
	AtlasLootCompareFrameSortButton_5:SetPoint("LEFT", AtlasLootCompareFrameSortButton_4, "RIGHT", 1, 0)
	AtlasLootCompareFrameSortButton_6:SetPoint("LEFT", AtlasLootCompareFrameSortButton_5, "RIGHT", 1, 0)
	AtlasLootCompareFrame_CloseButton2:SetPoint("BOTTOMRIGHT", AtlasLootCompareFrame, "BOTTOMRIGHT", -7, 10)
	AtlasLootCompareFrame_WishlistButton:SetPoint("RIGHT", AtlasLootCompareFrame_CloseButton2, "LEFT", -1, 0)
	AtlasLootCompareFrameSearch_SearchButton:SetPoint("LEFT", AtlasLootCompareFrameSearch_Box, "RIGHT", 5, 0)
	AtlasLootCompareFrameSearch_SelectModuel:SetPoint("LEFT", AtlasLootCompareFrameSearch_SearchButton, "RIGHT", 5, 0)
	AtlasLootDefaultFrame_CloseButton:ClearAllPoints()
	AtlasLootDefaultFrame_CloseButton:SetPoint("TOPRIGHT", AtlasLootDefaultFrame, "TOPRIGHT", -5 -2)
	AtlasLootDefaultFrame:SetFrameLevel(0)
	AtlasLootItemsFrame:SetFrameLevel(AtlasLootDefaultFrame:GetFrameLevel()+1)
	for i = 1, 30 do if _G["AtlasLootDefaultFrame_ScrollLine"..i] then _G["AtlasLootDefaultFrame_ScrollLine"..i]:SetFrameLevel(AtlasLootDefaultFrame:GetFrameLevel()+1)end end 

	if(AtlasLootDefaultFrame_PackageSelect) then
		AtlasLootDefaultFrame_PackageSelect:SetFrameLevel(AtlasLootDefaultFrame:GetFrameLevel()+1)
	end
	AtlasLootDefaultFrame_InstanceSelect:SetFrameLevel(AtlasLootDefaultFrame:GetFrameLevel()+1)
	AtlasLoot_AtlasInfoFrame_ToggleALButton:SetFrameLevel(AtlasLootDefaultFrame:GetFrameLevel()+1)
	AtlasLootDefaultFrame_CompareFrame:SetFrameLevel(AtlasLootDefaultFrame:GetFrameLevel()+1)
	AtlasLootPanelSearch_Box:SetHeight(16)
	AtlasLootPanel:SetWidth(921)
end

local function Nine_IsThere(self, elapsed)
	self.timeLapse = self.timeLapse + elapsed
	if(self.timeLapse < 2) then 
		return 
	else
		self.timeLapse = 0
	end
	for i = 1, 9 do local f = _G["AtlasLootCompareFrameSortButton_"..i]f:SetWidth(44.44)end 
	for _, object in pairs(nineisthere) do SV.API:Set("Frame", _G[object]) end 
	AtlasLootCompareFrameSortButton_7:SetPoint("LEFT", AtlasLootCompareFrameSortButton_6, "RIGHT", 1, 0)
	AtlasLootCompareFrameSortButton_8:SetPoint("LEFT", AtlasLootCompareFrameSortButton_7, "RIGHT", 1, 0)
	AtlasLootCompareFrameSortButton_9:SetPoint("LEFT", AtlasLootCompareFrameSortButton_8, "RIGHT", 1, 0)
end

local function Compare_OnShow(self, event, ...)
	for i = 1, 6 do _G["AtlasLootCompareFrameSortButton_"..i]:SetWidth(40)end 
	local Nine = AtlasLootCompareFrameSortButton_9
	if Nine ~= nil then
		Nine.timeLapse = 0
		Nine:SetScript("OnUpdate", Nine_IsThere)
	end 
end

local _hook_ALPanel = function(self,_,parent,_,_,_,breaker)
	if not breaker then 
		self:ClearAllPoints()
		self:SetPoint("TOP",parent,"BOTTOM",0,-1,true)
	end 
end

local _hook_OnUpdate = function(self, elapsed)
	self.timeLapse = self.timeLapse + elapsed
	if(self.timeLapse < 2) then 
		return 
	else
		self.timeLapse = 0
	end
	self:SetWidth(AtlasLootDefaultFrame:GetWidth()) 
end


local function StyleAtlasLoot(event, addon)
	assert(AtlasLootPanel, "AddOn Not Loaded")

	for _, object in pairs(StripAllTextures) do _G[object]:RemoveTextures()end 
	for _, object in pairs(SetTemplateDefault) do SV.API:Set("Frame", _G[object], "Default")end 
	for _, button in pairs(buttons) do _G[button]:SetStyle("Button")end 

	-- Manipulate the main frames
	SV.API:Set("Frame", _G["AtlasLootDefaultFrame"], "Window2");
	SV.API:Set("!_Frame", _G["AtlasLootItemsFrame"], "Inset");
	SV.API:Set("Frame", _G["AtlasLootPanel"], "Default");
	hooksecurefunc(_G["AtlasLootPanel"], "SetPoint", _hook_ALPanel);

	_G["AtlasLootPanel"]:SetPoint("TOP",_G["AtlasLootDefaultFrame"],"BOTTOM",0,-1);
	-- Back to the rest
	SV.API:Set("Frame", _G["AtlasLootCompareFrame"], "Transparent");
	if AtlasLoot_PanelButton_1 then AtlasLoot_PanelButton_1:SetStyle("Button") end
	if AtlasLoot_PanelButton_2 then AtlasLoot_PanelButton_2:SetStyle("Button") end
	if AtlasLoot_PanelButton_3 then AtlasLoot_PanelButton_3:SetStyle("Button") end
	if AtlasLoot_PanelButton_4 then AtlasLoot_PanelButton_4:SetStyle("Button") end
	if AtlasLoot_PanelButton_5 then AtlasLoot_PanelButton_5:SetStyle("Button") end
	if AtlasLoot_PanelButton_6 then AtlasLoot_PanelButton_6:SetStyle("Button") end
	if AtlasLoot_PanelButton_7 then AtlasLoot_PanelButton_7:SetStyle("Button") end
	if AtlasLoot_PanelButton_8 then AtlasLoot_PanelButton_8:SetStyle("Button") end
	if AtlasLoot_PanelButton_9 then AtlasLoot_PanelButton_9:SetStyle("Button") end
	if AtlasLoot_PanelButton_10 then AtlasLoot_PanelButton_10:SetStyle("Button") end
	if AtlasLoot_PanelButton_11 then AtlasLoot_PanelButton_11:SetStyle("Button") end
	if AtlasLoot_PanelButton_12 then AtlasLoot_PanelButton_12:SetStyle("Button") end

	for i = 1, 15 do local f = _G["AtlasLootCompareFrameMainFilterButton"..i]f:RemoveTextures() end 

	SV.API:Set("CloseButton", AtlasLootDefaultFrame_CloseButton)
	SV.API:Set("CloseButton", AtlasLootCompareFrame_CloseButton)
	SV.API:Set("CloseButton", AtlasLootCompareFrame_CloseButton_Wishlist)
	SV.API:Set("PageButton", AtlasLootQuickLooksButton)
	SV.API:Set("PageButton", AtlasLootItemsFrame_NEXT)
	AtlasLootItemsFrame_NEXT:SetWidth(25)
	AtlasLootItemsFrame_NEXT:SetHeight(25)
	SV.API:Set("PageButton", AtlasLootItemsFrame_PREV)
	AtlasLootItemsFrame_PREV:SetWidth(25)
	AtlasLootItemsFrame_PREV:SetHeight(25)
	SV.API:Set("PageButton", AtlasLootPanelSearch_SelectModuel)	
	SV.API:Set("PageButton", AtlasLootCompareFrameSearch_SelectModuel)

	if(AtlasLootDefaultFrame_PackageSelect) then
		SV.API:Set("DropDown", AtlasLootDefaultFrame_PackageSelect)
		AtlasLootDefaultFrame_PackageSelect:SetWidth(240)
		AtlasLootDefaultFrame_PackageSelect:SetPoint("TOPLEFT", AtlasLootDefaultFrame, "TOPLEFT", 50, -50)
	end

	SV.API:Set("DropDown", AtlasLootDefaultFrame_ModuleSelect,240)
	SV.API:Set("DropDown", AtlasLootDefaultFrame_InstanceSelect,240)
	
	SV.API:Set("DropDown", AtlasLootCompareFrameSearch_StatsListDropDown)
	AtlasLootCompareFrameSearch_StatsListDropDown:SetWidth(240)
	SV.API:Set("DropDown", AtlasLootCompareFrame_WishlistDropDown)
	AtlasLootCompareFrame_WishlistDropDown:SetWidth(240)
	AtlasLootPanelSearch_Box:SetStyle("Editbox")
	AtlasLootCompareFrameSearch_Box:SetStyle("Editbox")

	if AtlasLootFilterCheck then 
		AtlasLootFilterCheck:SetStyle("CheckButton") 
	end
	if AtlasLootItemsFrame_Heroic then 
		AtlasLootItemsFrame_Heroic:SetStyle("CheckButton") 
	end
	if AtlasLootCompareFrameSearch_FilterCheck then AtlasLootCompareFrameSearch_FilterCheck:SetStyle("CheckButton")
	end
	if AtlasLootItemsFrame_RaidFinder then 
		AtlasLootItemsFrame_RaidFinder:SetStyle("CheckButton") 
	end
	if AtlasLootItemsFrame_Thunderforged then 
		AtlasLootItemsFrame_Thunderforged:SetStyle("CheckButton") 
	end

	AtlasLootPanel.Titel:SetTextColor(23/255, 132/255, 209/255)
	AtlasLootPanel.Titel:SetPoint("BOTTOM", AtlasLootPanel.TitelBg, "BOTTOM", 0, 40)
	SV.API:Set("ScrollBar", AtlasLootCompareFrame_ScrollFrameItemFrameScrollBar)
	SV.API:Set("ScrollBar", AtlasLootCompareFrame_WishlistScrollFrameScrollBar)
	AtlasLootDefaultFrame:HookScript("OnShow", AL_OnShow)
	AtlasLootCompareFrame:HookScript("OnShow", Compare_OnShow)
	AtlasLootPanel.timeLapse = 0;

	--AtlasLootPanel:HookScript("OnUpdate", _hook_OnUpdate)

	if(AtlasLootTooltip:GetName() ~= "GameTooltip") then 
		SV.API:Set("Tooltip", AtlasLootTooltip)
	end
end
MOD:SaveAddonStyle("AtlasLoot", StyleAtlasLoot, nil, true)