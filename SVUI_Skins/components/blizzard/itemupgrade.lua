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
ITEMUPGRADE UI MODR
##########################################################
]]--
local function ItemUpgradeStyle()
	if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.itemUpgrade ~= true then
		 return 
	end 
	
	SV.API:Set("Window", ItemUpgradeFrame, true)

	SV.API:Set("CloseButton", ItemUpgradeFrameCloseButton)
	ItemUpgradeFrameUpgradeButton:RemoveTextures()
	ItemUpgradeFrameUpgradeButton:SetStyle("Button")
	ItemUpgradeFrame.ItemButton:RemoveTextures()
	ItemUpgradeFrame.ItemButton:SetStyle("ActionSlot")
	ItemUpgradeFrame.ItemButton.IconTexture:InsetPoints()
	hooksecurefunc('ItemUpgradeFrame_Update', function()
		if GetItemUpgradeItemInfo() then
			ItemUpgradeFrame.ItemButton.IconTexture:SetAlpha(1)
			ItemUpgradeFrame.ItemButton.IconTexture:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
		else
			ItemUpgradeFrame.ItemButton.IconTexture:SetAlpha(0)
		end 
	end)
	ItemUpgradeFrameMoneyFrame:RemoveTextures()
	ItemUpgradeFrame.FinishedGlow:Die()
	ItemUpgradeFrame.ButtonFrame:DisableDrawLayer('BORDER')
end 
--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveBlizzardStyle("Blizzard_ItemUpgradeUI",ItemUpgradeStyle)