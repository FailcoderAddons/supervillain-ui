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
KEYBINDING MODR
##########################################################
]]--
local BindButtons = {
	"KeyBindingFrameDefaultButton", 
	"KeyBindingFrameUnbindButton", 
	"KeyBindingFrameOkayButton", 
	"KeyBindingFrameCancelButton"
}

local function BindingStyle()
	if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.binding ~= true then return end 

	for _, gName in pairs(BindButtons)do 
		local btn = _G[gName]
		if(btn) then
			btn:RemoveTextures()
			btn:SetStyle("Button")
		end
	end

	for i = 1, KEY_BINDINGS_DISPLAYED do 
		local button1 = _G["KeyBindingFrameBinding"..i.."Key1Button"]
		if(button1) then
			button1:RemoveTextures(true)
			button1:SetStyle("Editbox")
		end

		local button2 = _G["KeyBindingFrameBinding"..i.."Key2Button"]
		if(button2) then
			button2:RemoveTextures(true)
			button2:SetStyle("Editbox")
		end
	end

	SV.API:Set("ScrollBar", KeyBindingFrameScrollFrame)
	KeyBindingFrame:RemoveTextures()
	KeyBindingFrame:SetStyle("Frame", "Window")
end
--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveBlizzardStyle("Blizzard_BindingUI", BindingStyle)