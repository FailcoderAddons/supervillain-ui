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
BARBERSHOP MODR
##########################################################
]]--
local function BarberShopStyle()
	if SV.db.Skins.blizzard.enable~=true or SV.db.Skins.blizzard.barber~=true then return end

	local buttons = {"BarberShopFrameOkayButton", "BarberShopFrameCancelButton", "BarberShopFrameResetButton"}

	BarberShopFrameOkayButton:SetPoint("RIGHT", BarberShopFrameSelector4, "BOTTOM", 2, -50)

	for b = 1, #buttons do 
		_G[buttons[b]]:RemoveTextures()
		_G[buttons[b]]:SetStyle("Button")
	end

	BarberShopFrame:RemoveTextures()
	BarberShopFrame:SetStyle("Frame", "Window")
	BarberShopFrame:SetSize(BarberShopFrame:GetWidth()-30, BarberShopFrame:GetHeight()-56)

	local lastframe;
	for i = 1, 5 do 
		local selector = _G["BarberShopFrameSelector"..i] 
		if selector then
			SV.API:Set("PageButton", _G["BarberShopFrameSelector"..i.."Prev"])
			SV.API:Set("PageButton", _G["BarberShopFrameSelector"..i.."Next"])
			selector:ClearAllPoints()

			if lastframe then 
				selector:SetPoint("TOP", lastframe, "BOTTOM", 0, -3)
			else
				selector:SetPoint("TOP", BarberShopFrame, "TOP", 0, -12)
			end

			selector:RemoveTextures()
			if(selector:IsShown()) then
				lastframe = selector
			end
		end 
	end

	BarberShopFrameMoneyFrame:RemoveTextures()
	BarberShopFrameMoneyFrame:SetStyle("Frame", "Inset")
	BarberShopFrameMoneyFrame:SetPoint("TOP", lastframe, "BOTTOM", 0, -10)

	--BarberShopFrameBackground:Die()
	BarberShopBannerFrameBGTexture:Die()
	BarberShopBannerFrame:Die()

	BarberShopAltFormFrameBorder:RemoveTextures()
	BarberShopAltFormFrame:SetPoint("BOTTOM", BarberShopFrame, "TOP", 0, 5)
	BarberShopAltFormFrame:RemoveTextures()
	BarberShopAltFormFrame:SetStyle("Frame", "Window2")

	BarberShopFrameResetButton:ClearAllPoints()
	BarberShopFrameResetButton:SetPoint("BOTTOM", BarberShopFrame.Panel, "BOTTOM", 0, 4)
end 
--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveBlizzardStyle("Blizzard_BarbershopUI",BarberShopStyle)
