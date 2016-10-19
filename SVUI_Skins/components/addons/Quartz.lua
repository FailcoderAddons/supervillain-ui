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
QUARTZ
##########################################################
]]--
local function StyleQuartz()
	local AceAddon = LibStub("AceAddon-3.0")
	if(not AceAddon) then return end
	local Quartz3 = AceAddon:GetAddon("Quartz3", true)
	
	assert(Quartz3, "AddOn Not Loaded")

	local GCD = Quartz3:GetModule("GCD")
	local CastBar = Quartz3.CastBarTemplate.template
	local function StyleQuartzBar(self)
		if not self.isStyled then
			self.IconBorder = CreateFrame("Frame", nil, self)
			SV.API:Set("Frame", self.IconBorder,"Transparent")
			self.IconBorder:SetFrameLevel(0)
			self.IconBorder:WrapPoints(self.Icon)
			SV.API:Set("Frame", self.Bar,"Transparent",true)
			self.isStyled = true
		end
 		if self.config.hideicon then
 			self.IconBorder:Hide()
 		else
 			self.IconBorder:Show()
 		end
	end

	hooksecurefunc(CastBar, 'ApplySettings', StyleQuartzBar)
	hooksecurefunc(CastBar, 'UNIT_SPELLCAST_START', StyleQuartzBar)
	hooksecurefunc(CastBar, 'UNIT_SPELLCAST_CHANNEL_START', StyleQuartzBar)

	if GCD then
		hooksecurefunc(GCD, 'CheckGCD', function()
			if not Quartz3GCDBar.backdrop then
				SV.API:Set("Frame", Quartz3GCDBar,"Transparent",true)
			end
		end)
	end
end
MOD:SaveAddonStyle("Quartz", StyleQuartz)