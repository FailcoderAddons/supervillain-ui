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
TAXIFRAME MODR
##########################################################
]]--
local function SocialStyle()
	MOD.Debugging = true;
	if SV.db.Skins.blizzard.enable ~= true then
		 return 
	end
	--print("Skinning Social")
	SV.API:Set("Window", SocialPostFrame)
	--SV.API:Set("Tooltip", _G.StoreTooltip)
	--print("Skinning Completed")
end 
--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveBlizzardStyle("Blizzard_SocialUI", SocialStyle)