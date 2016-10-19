--[[
##############################################################################
S V U I   By: Failcoder
##############################################################################
--]]
--[[ GLOBALS ]]--
local _G = _G;
local unpack  = _G.unpack;
local select  = _G.select;
local ipairs  = _G.ipairs;
local pairs   = _G.pairs;
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
local InspectSlotList = {
	"HeadSlot",
	"NeckSlot",
	"ShoulderSlot",
	"BackSlot",
	"ChestSlot",
	"ShirtSlot",
	"TabardSlot",
	"WristSlot",
	"HandsSlot",
	"WaistSlot",
	"LegsSlot",
	"FeetSlot",
	"Finger0Slot",
	"Finger1Slot",
	"Trinket0Slot",
	"Trinket1Slot",
	"MainHandSlot",
	"SecondaryHandSlot"
};
--[[ 
########################################################## 
INSPECT UI MODR
##########################################################
]]--
local function InspectStyle()
	if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.inspect ~= true then
		return 
	end 
	InspectFrame:RemoveTextures(true)
	InspectFrameInset:RemoveTextures(true)
	InspectFrame:SetStyle("Frame", "Window2")
	SV.API:Set("CloseButton", InspectFrameCloseButton)
	for d = 1, 4 do
		SV.API:Set("Tab", _G["InspectFrameTab"..d])
	end 
	InspectModelFrameBorderTopLeft:Die()
	InspectModelFrameBorderTopRight:Die()
	InspectModelFrameBorderTop:Die()
	InspectModelFrameBorderLeft:Die()
	InspectModelFrameBorderRight:Die()
	InspectModelFrameBorderBottomLeft:Die()
	InspectModelFrameBorderBottomRight:Die()
	InspectModelFrameBorderBottom:Die()
	InspectModelFrameBorderBottom2:Die()
	InspectModelFrameBackgroundOverlay:Die()
	InspectModelFrame:SetStyle("Frame", "Default")
	for _, slot in pairs(InspectSlotList)do 
		local texture = _G["Inspect"..slot.."IconTexture"]
		local frame = _G["Inspect"..slot]
		frame:RemoveTextures()
		frame:SetStyle("Button")
		texture:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
		texture:InsetPoints()
		frame:SetFrameLevel(frame:GetFrameLevel() + 1)
		frame:SetStyle("!_Frame")
	end 
	hooksecurefunc('InspectPaperDollItemSlotButton_Update', function(q)
		local unit = InspectFrame.unit;
		local r = GetInventoryItemQuality(unit, q:GetID())
		if r and q.Panel then 
			local s, t, f = GetItemQualityColor(r)
			q:SetBackdropBorderColor(s, t, f)
		elseif q.Panel then 
			q:SetBackdropBorderColor(0,0,0,1)
		end 
	end)
	InspectGuildFrameBG:Die()
	InspectTalentFrame:RemoveTextures()
end 
--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveBlizzardStyle("Blizzard_InspectUI",InspectStyle)