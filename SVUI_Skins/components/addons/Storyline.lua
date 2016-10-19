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

local bubbleBackdrop = {
	bgFile = [[Interface\AddOns\SVUI_!Core\assets\textures\CHATBUBBLE-BG]],
    tile = false,
    tileSize = 0,
    edgeFile = [[Interface\AddOns\SVUI_!Core\assets\textures\CHATBUBBLE-BACKDROP]],
    edgeSize = 15,
    insets =
    {
        left = 15,
        right = 15,
        top = 15,
        bottom = 15,
    },
};
--[[
##########################################################
STYLE (IN DEVELOPMENT)
##########################################################
]]--
local function StyleStoryline()
	assert(_G.Storyline_NPCFrame, "AddOn Not Loaded");

	Storyline_NPCFrame:RemoveTextures()
	Storyline_NPCFrame:SetStyle("Frame", "Window2")
	Storyline_NPCFrameModels:RemoveTextures()

	local leftBG = CreateFrame("Frame", nil, Storyline_NPCFrame)
	leftBG:SetPoint("TOPLEFT",  Storyline_NPCFrame, "TOPLEFT", 20, -20)
	leftBG:SetPoint("BOTTOMRIGHT",  Storyline_NPCFrame, "BOTTOM", -4, 20)
	leftBG:SetStyle("Frame", 'Model', false, 3, 2, 2)

	local rightBG = CreateFrame("Frame", nil, Storyline_NPCFrame)
	rightBG:SetPoint("TOPLEFT",  Storyline_NPCFrame, "TOP", 4, -20)
	rightBG:SetPoint("BOTTOMRIGHT",  Storyline_NPCFrame, "BOTTOMRIGHT", -20, 20)
	rightBG:SetStyle("Frame", 'Model', false, 3, 2, 2)

	Storyline_NPCFrameModels:SetParent(leftBG)

	--SV.API:Set("Button", Storyline_NPCFrameConfigButton, true)
	Storyline_NPCFrameConfigButton:RemoveTextures()
	Storyline_NPCFrameConfigButton:SetParent(Storyline_NPCFrameModels)
	Storyline_NPCFrameConfigButton:ClearAllPoints()
	Storyline_NPCFrameConfigButton:SetSize(24,24)
	Storyline_NPCFrameConfigButton:SetPoint("BOTTOMLEFT", Storyline_NPCFrame, "BOTTOMLEFT", 0, 0)
	Storyline_NPCFrameConfigButton:SetNormalTexture([[Interface\WorldMap\Gear_64Grey]])
	Storyline_NPCFrameConfigButton:GetNormalTexture():SetTexCoord(0,1,0,1)
	Storyline_NPCFrameConfigButton:SetPushedTexture([[Interface\WorldMap\Gear_64Grey]])
	Storyline_NPCFrameConfigButton:GetPushedTexture():SetTexCoord(0,1,0,1)
	Storyline_NPCFrameConfigButton:SetHighlightTexture([[Interface\WorldMap\Gear_64Grey]])

	--SV.API:Set("Button", Storyline_NPCFrameResizeButton, true)
	Storyline_NPCFrameResizeButton:RemoveTextures()
	Storyline_NPCFrameResizeButton:SetParent(Storyline_NPCFrameModels)
	Storyline_NPCFrameResizeButton:ClearAllPoints()
	Storyline_NPCFrameResizeButton:SetSize(24,24)
	Storyline_NPCFrameResizeButton:SetPoint("BOTTOMRIGHT", Storyline_NPCFrame, "BOTTOMRIGHT", 0, 0)
	Storyline_NPCFrameResizeButton:SetNormalTexture([[Interface\ChatFrame\UI-ChatIM-SizeGrabber-Up]])
	Storyline_NPCFrameResizeButton:GetNormalTexture():SetTexCoord(0,1,0,1)
	Storyline_NPCFrameResizeButton:SetPushedTexture([[Interface\ChatFrame\UI-ChatIM-SizeGrabber-Down]])
	Storyline_NPCFrameResizeButton:GetPushedTexture():SetTexCoord(0,1,0,1)
	Storyline_NPCFrameResizeButton:SetHighlightTexture([[Interface\ChatFrame\UI-ChatIM-SizeGrabber-Highlight]])

	SV.API:Set("CloseButton", Storyline_NPCFrameClose)
	Storyline_NPCFrameClose:SetParent(Storyline_NPCFrameModels)
	Storyline_NPCFrameClose:ClearAllPoints()
	Storyline_NPCFrameClose:SetPoint("TOPRIGHT", Storyline_NPCFrame, "TOPRIGHT", 0, 0)

	Storyline_NPCFrameChat:RemoveTextures()
	Storyline_NPCFrameChat:SetBackdrop(bubbleBackdrop)
	Storyline_NPCFrameChat:SetParent(Storyline_NPCFrameModels)
	local tail0 = Storyline_NPCFrameChat:CreateTexture(nil, 'OVERLAY')
	tail0:SetSize(20,20)
	tail0:SetPoint("BOTTOMRIGHT", Storyline_NPCFrameChat, "TOPRIGHT", -60, -2)
	tail0:SetTexture([[Interface\AddOns\SVUI_!Core\assets\textures\CHATBUBBLE-TAIL-UP]])

	Storyline_NPCFrameChatOption1:RemoveTextures()
	Storyline_NPCFrameChatOption2:RemoveTextures()
	Storyline_NPCFrameChatOption3:RemoveTextures()
	--frame:SetStyle("!_Frame", 'Transparent')
	local callout = CreateFrame("Frame", nil, Storyline_NPCFrameChatOption1)
	callout:SetPoint("TOPLEFT",  Storyline_NPCFrameChatOption1, "TOPLEFT", 0, 15)
	callout:SetPoint("BOTTOMRIGHT",  Storyline_NPCFrameChatOption3, "BOTTOMRIGHT", 0, -15)
	callout:SetBackdrop(bubbleBackdrop)

	local tail = callout:CreateTexture(nil, 'OVERLAY')
	tail:SetSize(20,20)
	tail:SetPoint("RIGHT", callout, "LEFT", 2, 0)
	tail:SetTexture([[Interface\AddOns\SVUI_!Core\assets\textures\CHATBUBBLE-TAIL-LEFT]])

	local level = Storyline_NPCFrameChatOption1:GetFrameLevel()
	callout:SetFrameLevel(level)
	Storyline_NPCFrameChatOption1:SetFrameLevel(level + 2)
	Storyline_NPCFrameChatOption2:SetFrameLevel(level + 2)
	Storyline_NPCFrameChatOption3:SetFrameLevel(level + 2)

	Storyline_NPCFrameChatPrevious:RemoveTextures()
	Storyline_NPCFrameChatPrevious:SetSize(18,18)
	Storyline_NPCFrameChatPrevious:SetNormalTexture([[Interface\Buttons\UI-RefreshButton]])
	Storyline_NPCFrameChatPrevious:GetNormalTexture():SetTexCoord(0,1,0,1)
	Storyline_NPCFrameChatPrevious:SetPushedTexture([[Interface\Buttons\UI-RefreshButton]])
	Storyline_NPCFrameChatPrevious:GetPushedTexture():SetTexCoord(0,1,0,1)
	Storyline_NPCFrameChatPrevious:SetHighlightTexture([[Interface\Buttons\UI-RefreshButton]])

	Storyline_NPCFrameConfig:RemoveTextures()
	Storyline_NPCFrameConfig:SetStyle("Frame", "Paper")
	Storyline_NPCFrameConfig:ClearAllPoints()
	Storyline_NPCFrameConfig:SetPoint("TOPLEFT", Storyline_NPCFrame, "BOTTOMLEFT", 20, -10)
	Storyline_NPCFrameConfig:SetPoint("TOPRIGHT", Storyline_NPCFrame, "BOTTOMRIGHT", -20, -10)
	Storyline_NPCFrameConfig:SetHeight(150)

	SV.API:Set("DropDown", Storyline_NPCFrameConfigLocale)
	Storyline_NPCFrameConfigLocale:ClearAllPoints()
	Storyline_NPCFrameConfigLocale:SetPoint("TOP", Storyline_NPCFrameConfigText, "BOTTOM", 0, -10);

	SV.API:Set("ScrollBar", Storyline_NPCFrameConfigSpeedSlider)
	Storyline_NPCFrameConfigSpeedSliderValText:ClearAllPoints()
	Storyline_NPCFrameConfigSpeedSliderValText:SetPoint("BOTTOMLEFT", Storyline_NPCFrameConfigSpeedSlider, "TOPLEFT", 0, 4)
	Storyline_NPCFrameConfigSpeedSliderValText:SetPoint("BOTTOMRIGHT", Storyline_NPCFrameConfigSpeedSlider, "TOPRIGHT", 0, 4)

	Storyline_NPCFrameConfigSpeedSlider:ClearAllPoints()
	Storyline_NPCFrameConfigSpeedSlider:SetPoint("TOPLEFT", Storyline_NPCFrameConfigText, "BOTTOMLEFT", 0, -70);

	SV.API:Set("CheckButton", Storyline_NPCFrameConfigAutoEquip)
	Storyline_NPCFrameConfigAutoEquipText:ClearAllPoints()
	Storyline_NPCFrameConfigAutoEquipText:SetPoint("LEFT", Storyline_NPCFrameConfigAutoEquip, "RIGHT", 10, 0)

	Storyline_NPCFrameObjectives:SetFrameLevel(Storyline_NPCFrameModels:GetFrameLevel() + 20)

	if(SV.Tooltip) then
		SV.Tooltip:SetCustomStyle(Storyline_MainTooltip)
	end
end
--[[
##########################################################
MOD LOADING
##########################################################
]]--
MOD:SaveAddonStyle("Storyline", StyleStoryline)
