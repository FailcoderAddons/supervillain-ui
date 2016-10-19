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
local SV = _G['SVUI'];
local L = SV.L;
local MOD = SV.Skins;
local Schema = MOD.Schema;
--[[ 
########################################################## 
CLIQUE
##########################################################
]]--
local CliqueFrames = {
	"CliqueDialog",
	"CliqueConfig",
	"CliqueConfigPage1",
	"CliqueConfigPage2",
	"CliqueClickGrabber",
	"CliqueScrollFrame"
}

local CliqueButtons = {
	"CliqueConfigPage1ButtonSpell",
	"CliqueConfigPage1ButtonOther",
	"CliqueConfigPage1ButtonOptions",
	"CliqueConfigPage2ButtonBinding",
	"CliqueDialogButtonAccept",
	"CliqueDialogButtonBinding",
	"CliqueConfigPage2ButtonSave",
	"CliqueConfigPage2ButtonCancel",
	"CliqueSpellTab",
}

local CliqueStripped = {
	"CliqueConfigPage1Column1",
	"CliqueConfigPage1Column2",
	"CliqueConfigPage1_VSlider",
	"CliqueSpellTab",
	"CliqueConfigPage1ButtonSpell",
	"CliqueConfigPage1ButtonOther",
	"CliqueConfigPage1ButtonOptions",
	"CliqueConfigPage2ButtonBinding",
	"CliqueDialogButtonAccept",
	"CliqueDialogButtonBinding",
	"CliqueConfigPage2ButtonSave",
	"CliqueConfigPage2ButtonCancel",
}

local CliqueConfigPage1_OnShow = function(self)
	for i = 1, 12 do
		if _G["CliqueRow"..i] then
			_G["CliqueRow"..i.."Icon"]:SetTexCoord(0.1,0.9,0.1,0.9);
			_G["CliqueRow"..i.."Bind"]:ClearAllPoints()
			if _G["CliqueRow"..i] == CliqueRow1 then
				_G["CliqueRow"..i.."Bind"]:SetPoint("RIGHT", _G["CliqueRow"..i], 8,0)
			else
				_G["CliqueRow"..i.."Bind"]:SetPoint("RIGHT", _G["CliqueRow"..i], -9,0)
			end
			_G["CliqueRow"..i]:GetHighlightTexture():SetDesaturated(true)
		end
	end
	CliqueRow1:ClearAllPoints()
	CliqueRow1:SetPoint("TOPLEFT",5,-(CliqueConfigPage1Column1:GetHeight() +3))
end

local function StyleClique()
	assert(CliqueDialog, "AddOn Not Loaded")

	for _, gName in pairs(CliqueFrames) do
		local frame = _G[gName]
		if(frame) then
			SV.API:Set("Frame", frame, "Transparent")
			if(gName == "CliqueConfig") then
				frame.Panel:SetPoint("TOPLEFT",0,0)
				frame.Panel:SetPoint("BOTTOMRIGHT",0,-5)
			elseif(gName == "CliqueClickGrabber" or gName == "CliqueScrollFrame") then
				frame.Panel:SetPoint("TOPLEFT",4,0)
				frame.Panel:SetPoint("BOTTOMRIGHT",-2,4)
			else
				frame.Panel:SetPoint("TOPLEFT",0,0)
				frame.Panel:SetPoint("BOTTOMRIGHT",2,0)
			end
		end
	end

	for _, gName in pairs(CliqueStripped) do
		local frame = _G[gName]
		if(frame) then
			frame:RemoveTextures(true)
		end
	end

	for _, gName in pairs(CliqueButtons) do
		local button = _G[gName]
		if(button) then
			button:SetStyle("Button")
		end
	end

	SV.API:Set("CloseButton", CliqueDialog.CloseButton)

	CliqueConfigPage1:SetScript("OnShow", CliqueConfigPage1_OnShow)

	CliqueDialog:SetSize(CliqueDialog:GetWidth()-1, CliqueDialog:GetHeight()-1)

	CliqueConfigPage1ButtonSpell:ClearAllPoints()
	CliqueConfigPage1ButtonSpell:SetPoint("TOPLEFT", CliqueConfigPage1,"BOTTOMLEFT",0,-4)

	CliqueConfigPage1ButtonOptions:ClearAllPoints()
	CliqueConfigPage1ButtonOptions:SetPoint("TOPRIGHT", CliqueConfigPage1,"BOTTOMRIGHT",2,-4)

	CliqueConfigPage2ButtonSave:ClearAllPoints()
	CliqueConfigPage2ButtonSave:SetPoint("TOPLEFT", CliqueConfigPage2,"BOTTOMLEFT",0,-4)

	CliqueConfigPage2ButtonCancel:ClearAllPoints()
	CliqueConfigPage2ButtonCancel:SetPoint("TOPRIGHT", CliqueConfigPage2,"BOTTOMRIGHT",2,-4)

	CliqueSpellTab:GetRegions():SetSize(.1,.1)
	CliqueSpellTab:GetNormalTexture():SetTexCoord(0.1,0.9,0.1,0.9)
	CliqueSpellTab:GetNormalTexture():ClearAllPoints()
	CliqueSpellTab:GetNormalTexture():InsetPoints()
end

MOD:SaveAddonStyle("Clique", StyleClique)