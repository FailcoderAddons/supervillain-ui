--[[
##############################################################################
S V U I   By: Failcoder
##############################################################################
--]]
--[[ GLOBALS ]]--
local _G = _G;
local unpack  = _G.unpack;
local select  = _G.select;
--[[ ADDON ]]--
local SV = _G['SVUI'];
local L = SV.L;
local MOD = SV.Skins;
local Schema = MOD.Schema;
--[[ 
########################################################## 
BLACKMARKET MODR
##########################################################
]]--
local function ChangeTab(tab)
	tab.Left:SetAlpha(0)
	if tab.Middle then 
		tab.Middle:SetAlpha(0)
	end 
	tab.Right:SetAlpha(0)
end

local _hook_ScrollFrameUpdate = function()
	local self = BlackMarketScrollFrame;
	local buttons = self.buttons;
	local offset = HybridScrollFrame_GetOffset(self)
	local itemCount = C_BlackMarket.GetNumItems()
	for i = 1, #buttons do 
		local button = buttons[i];
		if(button) then
			local indexOffset = offset + i;
			if(not button.Panel) then 
				button:RemoveTextures()
				button:SetStyle("Button")
				SV.API:Set("ItemButton", button.Item)
			end 
			if indexOffset <= itemCount then 
				local name, texture = C_BlackMarket.GetItemInfoByIndex(indexOffset)
				if(name) then 
					button.Item.IconTexture:SetTexture(texture)
				end 
			end
		end
	end 
end

local function BlackMarketStyle()
	if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.bmah ~= true then 
		return 
	end 

	SV.API:Set("Window", BlackMarketFrame)

	BlackMarketFrame.Inset:RemoveTextures()
	BlackMarketFrame.Inset:SetStyle("!_Frame", "Inset")

	SV.API:Set("CloseButton", BlackMarketFrame.CloseButton)
	SV.API:Set("ScrollBar", BlackMarketScrollFrame, 4)

	ChangeTab(BlackMarketFrame.ColumnName)
	ChangeTab(BlackMarketFrame.ColumnLevel)
	ChangeTab(BlackMarketFrame.ColumnType)
	ChangeTab(BlackMarketFrame.ColumnDuration)
	ChangeTab(BlackMarketFrame.ColumnHighBidder)
	ChangeTab(BlackMarketFrame.ColumnCurrentBid)

	BlackMarketFrame.MoneyFrameBorder:RemoveTextures()
	BlackMarketBidPriceGold:SetStyle("Editbox")
	BlackMarketBidPriceGold.Panel:SetPoint("TOPLEFT", -2, 0)
	BlackMarketBidPriceGold.Panel:SetPoint("BOTTOMRIGHT", -2, 0)
	BlackMarketFrame.BidButton:SetStyle("Button")

	hooksecurefunc("BlackMarketScrollFrame_Update", _hook_ScrollFrameUpdate)

	BlackMarketFrame.HotDeal:RemoveTextures()
	SV.API:Set("ItemButton", BlackMarketFrame.HotDeal.Item)
end 
--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveBlizzardStyle("Blizzard_BlackMarketUI",BlackMarketStyle)