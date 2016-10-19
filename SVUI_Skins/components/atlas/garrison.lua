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
local RING_TEXTURE = [[Interface\AddOns\SVUI_Skins\artwork\FOLLOWER-RING]]
local LVL_TEXTURE = [[Interface\AddOns\SVUI_Skins\artwork\FOLLOWER-LEVEL]]
local DEFAULT_COLOR = {r = 0.25, g = 0.25, b = 0.25};
--[[
##########################################################
STYLE
##########################################################
]]--
local GarrMission_PortraitsFromLevel = function(self)
	local parent = self:GetParent()
	if(parent.PortraitRing) then
  		parent.PortraitRing:SetTexture(RING_TEXTURE)
  	end
end
SV:SetAtlasFunc("GarrMission_PortraitsFromLevel", GarrMission_PortraitsFromLevel)

local GarrMission_MaterialFrame = function(self)
  local frame = self:GetParent()
  frame:RemoveTextures()
  frame:SetStyle("Frame", "Inset", true, 1, -5, -7)
  self:SetTexture("")
end
SV:SetAtlasFunc("GarrMission_MaterialFrame", GarrMission_MaterialFrame)

SV:SetAtlasFilter("GarrMission_PortraitRing_LevelBorder", "GarrMission_PortraitsFromLevel")
SV:SetAtlasFilter("GarrMission_PortraitRing_iLvlBorder", "GarrMission_PortraitsFromLevel")
SV:SetAtlasFilter("Garr_Mission_MaterialFrame", "GarrMission_MaterialFrame")
SV:SetAtlasFilter("Garr_FollowerToast-Uncommon");
SV:SetAtlasFilter("Garr_FollowerToast-Epic");
SV:SetAtlasFilter("Garr_FollowerToast-Rare");
SV:SetAtlasFilter("GarrLanding-MinimapIcon-Horde-Up");
SV:SetAtlasFilter("GarrLanding-MinimapIcon-Horde-Down");
SV:SetAtlasFilter("GarrLanding-MinimapIcon-Alliance-Up");
SV:SetAtlasFilter("GarrLanding-MinimapIcon-Alliance-Down");

SV:SetAtlasFilter("Garr_FollowerToast-Rare");
