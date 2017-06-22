--[[
##############################################################################
S V U I   By: 		Failcoder
Obliterum Skin By: 	JoeyMagz
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
OBLITERUM FORGE
##########################################################
]]--
local function OblitFrameStyle()
	if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.obliterum ~= true then
		 return 
	end
	
	-- Set API
	SV.API:Set("Window", ObliterumForgeFrame, true)
	SV.API:Set("Button", ObliterumForgeFrame.ObliterateButton, true)
	SV.API:Set("ItemButton", ObliterumForgeFrame.ItemSlot, nil, true)
	
	-- Item Slot
	ObliterumForgeFrame.ItemSlot:SetWidth(75)
	ObliterumForgeFrame.ItemSlot:SetHeight(75)

end
--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveBlizzardStyle("Blizzard_ObliterumUI",OblitFrameStyle)