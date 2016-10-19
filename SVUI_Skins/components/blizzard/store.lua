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
local function StoreStyle()
	-- if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.store ~= true then
	-- 	 return 
	-- end

	--SV.API:Set("Window", StoreFrame)
	SV.API:Set("Tooltip", _G.StoreTooltip)
end 
--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveBlizzardStyle("Blizzard_StoreUI", StoreStyle)