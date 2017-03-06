--[[
##############################################################################
S V U I   By: Failcoder
##############################################################################
--]]
--[[ GLOBALS ]]--
local _G = _G;
local unpack  = _G.unpack;
local select  = _G.select;
local tinsert = _G.tinsert;
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

--[[ 
########################################################## 
STYLE
##########################################################
]]--
local function ArtifactStyle()
	--print('test ArtifactStyle')
	if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.artifact ~= true then
		return 
	end 
	--print('begin ArtifactStyle')
	--ArtifactFrame:RemoveTextures(true)
	SV.API:Set("Window", ArtifactFrame, true, true, 1, 3, 3)
end 
--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveBlizzardStyle("Blizzard_ArtifactUI", ArtifactStyle)