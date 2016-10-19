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
ZYGOR
##########################################################
]]--
local function StyleZygorTabs()
	if(not ZGVCharacterGearFinderButton) then return end
	ZGVCharacterGearFinderButton.Highlight:SetColorTexture(1, 1, 1, 0.3)
	ZGVCharacterGearFinderButton.Highlight:SetPoint("TOPLEFT", 3, -4)
	ZGVCharacterGearFinderButton.Highlight:SetPoint("BOTTOMRIGHT", -1, 0)
	ZGVCharacterGearFinderButton.Hider:SetColorTexture(0.4, 0.4, 0.4, 0.4)
	ZGVCharacterGearFinderButton.Hider:SetPoint("TOPLEFT", 3, -4)
	ZGVCharacterGearFinderButton.Hider:SetPoint("BOTTOMRIGHT", -1, 0)
	ZGVCharacterGearFinderButton.TabBg:Die()
	if i == 1 then
		for x = 1, ZGVCharacterGearFinderButton:GetNumRegions()do 
			local texture = select(x, ZGVCharacterGearFinderButton:GetRegions())
			texture:SetTexCoord(0.16, 0.86, 0.16, 0.86)
		end 
	end 
	ZGVCharacterGearFinderButton:SetStyle("Frame", "Default", true, 2)
	ZGVCharacterGearFinderButton.Panel:SetPoint("TOPLEFT", 2, -3)
	ZGVCharacterGearFinderButton.Panel:SetPoint("BOTTOMRIGHT", 0, -2)
end 

local function StyleZygor()
	--MOD.Debugging = true;
	local ZygorGuidesViewer = LibStub('AceAddon-3.0'):GetAddon('ZygorGuidesViewer')
	assert(ZygorGuidesViewer, "AddOn Not Loaded")

	SV.API:Set("Window", ZygorGuidesViewerFrame)
	ZygorGuidesViewerFrame_Border:RemoveTextures(true)
	SV.API:Set("Frame", ZygorGuidesViewer_CreatureViewer, 'Model')

	for i = 1, 6 do
		SV.API:Set("Frame", _G['ZygorGuidesViewerFrame_Step'..i], 'Default')
	end

	CharacterFrame:HookScript("OnShow", StyleZygorTabs)

	ZygorGuidesViewerFrame_Border:HookScript('OnHide', function(self) self:RemoveTextures(true) end)
	ZygorGuidesViewerFrame_Border:HookScript('OnShow', function(self) self:RemoveTextures(true) end)
	if(SV.Maps and SV.db.Maps) then 
		if(SV.db.Maps.customIcons) then
			--Minimap:SetBlipTexture(SV.Maps.media.customBlips)
			--Minimap.SetBlipTexture = function() return end
		else
			--Minimap:SetBlipTexture(SV.Maps.media.defaultBlips)
			--Minimap.SetBlipTexture = function() return end
		end
	end
end

MOD:SaveAddonStyle("ZygorGuidesViewer", StyleZygor)