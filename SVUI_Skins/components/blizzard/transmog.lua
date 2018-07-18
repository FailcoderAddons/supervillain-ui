--[[
##############################################################################
S V U I   By: Failcoder
##############################################################################
--]]
--[[ GLOBALS ]]--
local _G = _G;
local unpack  	= _G.unpack;
local select  	= _G.select;
local ipairs  	= _G.ipairs;
local pairs   	= _G.pairs;
local type 		= _G.type;
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
local TransmogFrameList = {
	"TransmogrifyModelFrameLines",
	"TransmogrifyModelFrameMarbleBg",
	"TransmogrifyFrameButtonFrameButtonBorder",
	"TransmogrifyFrameButtonFrameButtonBottomBorder",
	"TransmogrifyFrameButtonFrameMoneyLeft",
	"TransmogrifyFrameButtonFrameMoneyRight",
	"TransmogrifyFrameButtonFrameMoneyMiddle"
};
local TransmogSlotList = {
	"Head",
	"Shoulder",
	"Chest",
	"Waist",
	"Legs",
	"Feet",
	"Wrist",
	"Hands",
	"Back",
	"MainHand",
	"SecondaryHand"
};
--[[ 
########################################################## 
TRANSMOG MODR
##########################################################
]]--
local function TransmogStyle()
	if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.transmogrify ~= true then return end
	
	TransmogrifyFrame:SetSize(500, 600)
	SV.API:Set("Window", TransmogrifyFrame, true)

	for p, texture in pairs(TransmogFrameList)do
		 _G[texture]:Die()
	end

	select(2, TransmogrifyModelFrame:GetRegions()):Die()

	TransmogrifyModelFrame:ClearAllPoints()
	TransmogrifyModelFrame:SetPoint("TOPLEFT", TransmogrifyFrame, "TOPLEFT", 12, -22)
	TransmogrifyModelFrame:SetPoint("BOTTOMRIGHT", TransmogrifyFrame, "BOTTOMRIGHT", -12, 36)
	TransmogrifyModelFrame:SetStyle("!_Frame", "Model")

	TransmogrifyFrameButtonFrame:GetRegions():Die()
	TransmogrifyApplyButton:RemoveTextures()
	TransmogrifyApplyButton:SetStyle("Button")
	TransmogrifyApplyButton:SetPoint("BOTTOMRIGHT", TransmogrifyFrame, "BOTTOMRIGHT", -4, 4)
	SV.API:Set("CloseButton", TransmogrifyArtFrameCloseButton)
	TransmogrifyArtFrame:RemoveTextures()

	for p, a9 in pairs(TransmogSlotList) do 
		local icon = _G["TransmogrifyFrame"..a9 .."SlotIconTexture"]
		local a9 = _G["TransmogrifyFrame"..a9 .."Slot"]
		if a9 then
			a9:RemoveTextures()
			a9:SetStyle("ActionSlot")
			a9:SetFrameLevel(a9:GetFrameLevel()+2)
			
			a9.Panel:SetAllPoints()
			icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
			icon:ClearAllPoints()
			icon:InsetPoints()
		end 
	end
	
	TransmogrifyConfirmationPopup:SetParent(UIParent)
	TransmogrifyConfirmationPopup:RemoveTextures()
	TransmogrifyConfirmationPopup:SetStyle("Frame", "Pattern")
	TransmogrifyConfirmationPopup.Button1:SetStyle("Button")
	TransmogrifyConfirmationPopup.Button2:SetStyle("Button")
	SV.API:Set("!_ItemButton", TransmogrifyConfirmationPopupItemFrame1)
	SV.API:Set("!_ItemButton", TransmogrifyConfirmationPopupItemFrame2)
end 
--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveBlizzardStyle("Blizzard_ItemAlterationUI", TransmogStyle)