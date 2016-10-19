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
HELPERS
##########################################################
]]--
local RaidGroupList = {
	"RaidGroup1",
	"RaidGroup2",
	"RaidGroup3",
	"RaidGroup4",
	"RaidGroup5",
	"RaidGroup6",
	"RaidGroup7",
	"RaidGroup8"
};

local RaidInfoFrameList = {
	"RaidFrameConvertToRaidButton",
	"RaidFrameRaidInfoButton",
	"RaidFrameNotInRaidRaidBrowserButton",
	"RaidInfoExtendButton",
	"RaidInfoCancelButton" 
};
--[[ 
########################################################## 
RAID MODRS
##########################################################
]]--
local function RaidUIStyle()
	if InCombatLockdown() then return end 
	if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.raid ~= true then return end 
	for _,group in pairs(RaidGroupList)do 
		if _G[group] then
			_G[group]:RemoveTextures()
			for i = 1, 5 do
				local name = ("%sSlot%d"):format(group, i)
				local slot = _G[name]
				if(slot) then
					slot:RemoveTextures()
					slot:SetStyle("Frame", "Inset", true)
				end
			end
		end 
	end
end 

local function RaidInfoStyle()
	--print('test RaidInfoStyle')
	if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.nonraid ~= true then
		return 
	end

	_G["RaidInfoFrame"]:RemoveTextures()
	_G["RaidInfoInstanceLabel"]:RemoveTextures()
	_G["RaidInfoIDLabel"]:RemoveTextures()
	_G["RaidInfoScrollFrameScrollBarBG"]:Die()
	_G["RaidInfoScrollFrameScrollBarTop"]:Die()
	_G["RaidInfoScrollFrameScrollBarBottom"]:Die()
	_G["RaidInfoScrollFrameScrollBarMiddle"]:Die()

	for g = 1, #RaidInfoFrameList do 
		if _G[RaidInfoFrameList[g]] then
			_G[RaidInfoFrameList[g]]:SetStyle("Button")
		end 
	end

	RaidInfoScrollFrame:RemoveTextures()
	RaidInfoFrame:SetStyle("Frame", 'Transparent')
	RaidInfoFrame.Panel:SetPoint("TOPLEFT", RaidInfoFrame, "TOPLEFT")
	RaidInfoFrame.Panel:SetPoint("BOTTOMRIGHT", RaidInfoFrame, "BOTTOMRIGHT")

	SV.API:Set("CloseButton", RaidInfoCloseButton, RaidInfoFrame)
	SV.API:Set("ScrollBar", RaidInfoScrollFrame)
	
	if RaidFrameRaidBrowserButton then RaidFrameRaidBrowserButton:SetStyle("Button") end
	RaidFrameAllAssistCheckButton:SetStyle("CheckButton")
end 
--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveBlizzardStyle("Blizzard_RaidUI", RaidUIStyle)
MOD:SaveCustomStyle(RaidInfoStyle)