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
ALDAMAGEMETER
##########################################################
]]--
local function StyleALDamageMeter()
  assert(_G['alDamagerMeterFrame'], "AddOn Not Loaded")
  
  alDamageMeterFrame.bg:Die()
  SV.API:Set("Frame", alDamageMeterFrame)
  alDamageMeterFrame:HookScript('OnShow', function()
    if InCombatLockdown() then return end 
    if MOD.Docklet:IsEmbedded("alDamageMeter") then
    	MOD.Docklet:Show()
    end
  end)
end
MOD:SaveAddonStyle("alDamageMeter", StyleALDamageMeter) 