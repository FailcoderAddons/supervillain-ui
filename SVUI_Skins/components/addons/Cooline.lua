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
COOLINE
##########################################################
]]--
local function StyleCoolLine()
	assert(CoolLineDB, "AddOn Not Loaded")
	
	CoolLineDB.bgcolor = { r = 0, g = 0, b = 0, a = 0, }
	CoolLineDB.border = "None"
	CoolLine.updatelook()

	if(not CoolLine.Panel) then
		SV.API:Set("Frame", CoolLine, "Transparent")
	end

	SV:ManageVisibility(CoolLine)

	if MOD:IsAddonReady("CoolLine_Anchored") then
		if(not CoolLineDB.vertical and (SV.ActionBars and SV.ActionBars.MainAnchor)) then
			CoolLine:ClearAllPoints()
			CoolLine:SetPoint('BOTTOMRIGHT', SV.ActionBars.MainAnchor, 'TOPRIGHT', 0, 4)
			CoolLine:SetPoint("BOTTOMLEFT", SV.ActionBars.MainAnchor, "TOPLEFT", 0, 4)
		end
	end
end
MOD:SaveAddonStyle("CoolLine", StyleCoolLine)