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
TINYDPS
##########################################################
]]--
local function StyleTinyDPS()
	assert(tdpsFrame, "AddOn Not Loaded")

	SV.API:Set("Frame", tdpsFrame)

	tdpsFrame:HookScript("OnShow", function()
		if InCombatLockdown() then return end
		if MOD.Docklet:IsEmbedded("TinyDPS") then
			MOD.Docklet:Show()
		end
	end)

	if tdpsStatusBar then
		tdpsStatusBar:SetBackdrop({bgFile = SV.media.background.default, edgeFile = [[Interface\AddOns\SVUI_!Core\assets\textures\EMPTY]], tile = false, tileSize = 0, edgeSize = 1})
		tdpsStatusBar:SetStatusBarTexture(SV.media.statusbar.default)
	end

	tdpsRefresh()
end

MOD:SaveAddonStyle("TinyDPS", StyleTinyDPS)
