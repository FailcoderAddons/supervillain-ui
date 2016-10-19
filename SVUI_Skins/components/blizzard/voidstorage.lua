--[[
##############################################################################
S V U I   By: Failcoder
##############################################################################
--]]
--[[ GLOBALS ]]--
local _G = _G;
local unpack    = _G.unpack;
local select    = _G.select;
local ipairs    = _G.ipairs;
local pairs     = _G.pairs;
local type    = _G.type;
--[[ ADDON ]]--
local SV = _G['SVUI'];
local L = SV.L;
local MOD = SV.Skins;
local Schema = MOD.Schema;
--[[ 
########################################################## 
HELPERS
##########################################################
]]--
local NO_TEXTURE = SV.NoTexture;

local VoidStorageList = {
  "VoidStorageBorderFrame",
  "VoidStorageDepositFrame",
  "VoidStorageWithdrawFrame",
  "VoidStorageCostFrame",
  "VoidStorageStorageFrame",
  "VoidStoragePurchaseFrame",
  "VoidItemSearchBox"
};

local function Tab_OnEnter(this)
  this.backdrop:SetBackdropColor(0.1, 0.8, 0.8)
  this.backdrop:SetBackdropBorderColor(0.1, 0.8, 0.8)
end

local function Tab_OnLeave(this)
  this.backdrop:SetBackdropColor(0,0,0,1)
  this.backdrop:SetBackdropBorderColor(0,0,0,1)
end

local function ChangeTabHelper(this)
  this:RemoveTextures()
  local nTex = this:GetNormalTexture()
  if(nTex) then
    nTex:SetTexture([[Interface\ICONS\INV_Enchant_VoidSphere]])
    nTex:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
    nTex:InsetPoints()
  end

  this.pushed = true;

  this.backdrop = CreateFrame("Frame", nil, this)
  this.backdrop:WrapPoints(this,1,1)
  this.backdrop:SetFrameLevel(0)
  this.backdrop:SetBackdrop(SV.media.backdrop.glow);
  this.backdrop:SetBackdropColor(0,0,0,1)
  this.backdrop:SetBackdropBorderColor(0,0,0,1)
  this:SetScript("OnEnter", Tab_OnEnter)
  this:SetScript("OnLeave", Tab_OnLeave)

  local a,b,c,d,e = this:GetPoint()
  this:SetPoint(a,b,c,1,e)
end

local SlotBorderColor_Hook = function(self, ...)
  local parent = self:GetParent()
  if(parent) then
    parent:SetBackdropBorderColor(...)
  end
end
local SlotBorder_OnHide = function(self, ...)
  local parent = self:GetParent()
  if(parent) then
    parent:SetBackdropBorderColor(0,0,0,0.5)
  end
end

local function VoidSlotStyler(name, index)
  local gName = ("%sButton%d"):format(name, index)
  local button = _G[gName]
  local icon = _G[gName .. "IconTexture"]
  local bg = _G[gName .. "Bg"]
  if(button) then
    local border = button.IconBorder
    if(bg) then bg:Hide() end
    button:SetStyle("ActionSlot")
    if(icon) then
      icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
      icon:InsetPoints(button)
    end
    if(border) then
      border:SetTexture(NO_TEXTURE)
      hooksecurefunc(border, "Hide", SlotBorder_OnHide)
      hooksecurefunc(border, "SetVertexColor", SlotBorderColor_Hook)
    end
  end
end
--[[ 
########################################################## 
VOIDSTORAGE MODR
##########################################################
]]--
local function VoidStorageStyle()
  MOD.Debugging = true
  if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.voidstorage ~= true then
     return 
  end

  SV.API:Set("Window", VoidStorageFrame, true)

  for _,gName in pairs(VoidStorageList) do
    local frame = _G[gName]
    if(frame) then 
      frame:RemoveTextures()
    end
  end

  VoidStoragePurchaseFrame:SetFrameStrata('DIALOG')
  VoidStoragePurchaseFrame:SetStyle("!_Frame", "Button", true)
  VoidStorageFrameMarbleBg:Die()
  VoidStorageFrameLines:Die()

  select(2, VoidStorageFrame:GetRegions()):Die()

  VoidStoragePurchaseButton:SetStyle("Button")
  VoidStorageHelpBoxButton:SetStyle("Button")
  VoidStorageTransferButton:SetStyle("Button")

  SV.API:Set("CloseButton", VoidStorageBorderFrame.CloseButton)

  VoidItemSearchBox:SetStyle("Frame", "Inset")
  VoidItemSearchBox.Panel:SetPoint("TOPLEFT", 10, -1)
  VoidItemSearchBox.Panel:SetPoint("BOTTOMRIGHT", 4, 1)

  for i = 1, 9 do
    VoidSlotStyler("VoidStorageDeposit", i)
    VoidSlotStyler("VoidStorageWithdraw", i)
  end 

  for i = 1, 80 do
    VoidSlotStyler("VoidStorageStorage", i)
  end

  ChangeTabHelper(VoidStorageFrame.Page1)
  ChangeTabHelper(VoidStorageFrame.Page2)
end 
--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveBlizzardStyle("Blizzard_VoidStorageUI", VoidStorageStyle)