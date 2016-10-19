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
local ClassTrainerFrameList = {
	"ClassTrainerFrame",
	"ClassTrainerScrollFrameScrollChild",
	"ClassTrainerFrameSkillStepButton",
	"ClassTrainerFrameBottomInset"
};
local ClassTrainerTextureList = {
	"ClassTrainerFrameInset",
	"ClassTrainerFramePortrait",
	"ClassTrainerScrollFrameScrollBarBG",
	"ClassTrainerScrollFrameScrollBarTop",
	"ClassTrainerScrollFrameScrollBarBottom",
	"ClassTrainerScrollFrameScrollBarMiddle"
};
--[[
##########################################################
TRAINER MODR
##########################################################
]]--
local function TrainerStyle()
	if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.trainer ~= true then return end

	ClassTrainerFrame:SetHeight(ClassTrainerFrame:GetHeight() + 42)
	SV.API:Set("Window", ClassTrainerFrame)

	for i=1, 8 do
		local item = _G["ClassTrainerScrollFrameButton"..i];
		if item then
			SV.API:Set("ItemButton", item, nil, true)
			_G["ClassTrainerScrollFrameButton"..i.."Icon"]:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
			item.selectedTex:SetColorTexture(1, 1, 1, 0.3)
			item.selectedTex:InsetPoints()
		end
	end

	SV.API:Set("ScrollBar", ClassTrainerScrollFrame, 5)

	for _,frame in pairs(ClassTrainerFrameList)do
		_G[frame]:RemoveTextures()
	end

	for _,texture in pairs(ClassTrainerTextureList)do
		_G[texture]:Die()
	end

	_G["ClassTrainerTrainButton"]:RemoveTextures()
	_G["ClassTrainerTrainButton"]:SetStyle("Button")
	SV.API:Set("DropDown", ClassTrainerFrameFilterDropDown, 155)
	ClassTrainerScrollFrame:SetStyle("!_Frame", "Inset")
	SV.API:Set("CloseButton", ClassTrainerFrameCloseButton, ClassTrainerFrame)
	ClassTrainerFrameSkillStepButton.icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
	ClassTrainerFrameSkillStepButton:SetStyle("!_Frame", "Button", true)
	--ClassTrainerFrameSkillStepButton.Panel:WrapPoints(ClassTrainerFrameSkillStepButton.icon)
	--ClassTrainerFrameSkillStepButton.icon:SetParent(ClassTrainerFrameSkillStepButton.Panel)
	ClassTrainerFrameSkillStepButtonHighlight:SetColorTexture(1, 1, 1, 0.3)
	ClassTrainerFrameSkillStepButton.selectedTex:SetColorTexture(1, 1, 1, 0.3)
	ClassTrainerStatusBar:RemoveTextures()
	ClassTrainerStatusBar:SetStatusBarTexture(SV.media.statusbar.gradient)
	ClassTrainerStatusBar:SetStyle("Frame", "Inset", true, 1, 2, 2)
	ClassTrainerStatusBar.rankText:ClearAllPoints()
	ClassTrainerStatusBar.rankText:SetPoint("CENTER", ClassTrainerStatusBar, "CENTER")
end
--[[
##########################################################
MOD LOADING
##########################################################
]]--
MOD:SaveBlizzardStyle("Blizzard_TrainerUI",TrainerStyle)
