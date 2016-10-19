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
local string 	= _G.string;
--[[ STRING METHODS ]]--
local format = string.format;
--[[ 
########################################################## 
GET ADDON DATA
##########################################################
]]--
local SV = _G["SVUI"];
local L = SV.L;
local MOD = SV.Skins;
local Schema = MOD.Schema;
--[[ 
########################################################## 
AUCTIONLITE
##########################################################
]]--
local function BGHelper(parent)
  parent.bg = CreateFrame("Frame", nil, parent)
  parent.bg:SetStyle("!_Frame", "Inset")
  parent.bg:SetPoint("TOPLEFT", parent, "TOPLEFT", 16, -103)
  parent.bg:SetPoint("BOTTOMRIGHT", AuctionFrame, "BOTTOMRIGHT", -8, 36)
  parent.bg:SetFrameLevel(parent.bg:GetFrameLevel() - 1)
end

local function StyleAuctionLite(event, ...)
  assert(AuctionFrameTab4, "AddOn Not Loaded")
  if(not event or (event and event == 'PLAYER_ENTERING_WORLD')) then return; end

  BuyName:SetStyle("Editbox")
  BuyQuantity:SetStyle("Editbox")
  SellStacks:SetStyle("Editbox")
  SellSize:SetStyle("Editbox")
  SellBidPriceGold:SetStyle("Editbox")
  SellBidPriceSilver:SetStyle("Editbox")
  SellBidPriceCopper:SetStyle("Editbox")
  SellBuyoutPriceGold:SetStyle("Editbox")
  SellBuyoutPriceSilver:SetStyle("Editbox")
  SellBuyoutPriceCopper:SetStyle("Editbox")

  BuySearchButton:SetStyle("Button")
  BuyBidButton:SetStyle("Button")
  BuyBuyoutButton:SetStyle("Button")
  BuyCancelSearchButton:SetStyle("Button")
  BuyCancelAuctionButton:SetStyle("Button")
  BuyScanButton:SetStyle("Button")
  SellCreateAuctionButton:SetStyle("Button")

  SV.API:Set("PageButton", BuyAdvancedButton)
  SV.API:Set("PageButton", SellRememberButton)

  SV.API:Set("Tab", AuctionFrameTab4)
  SV.API:Set("Tab", AuctionFrameTab5)

  if(_G["AuctionFrameBuy"]) then
    BGHelper(_G["AuctionFrameBuy"])
  end
  if(_G["AuctionFrameSell"]) then
    BGHelper(_G["AuctionFrameSell"])
  end

  MOD:SafeEventRemoval("AuctionLite", event)
end

MOD:SaveAddonStyle("AuctionLite", StyleAuctionLite, nil, nil, "AUCTION_HOUSE_SHOW")