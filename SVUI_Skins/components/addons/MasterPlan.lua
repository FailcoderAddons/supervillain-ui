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
local HIGHLIGHT_TEXTURE = SV.media.background.default
local DEFAULT_COLOR = {r = 0.25, g = 0.25, b = 0.25};
local FOCUS_RINGS = {}
--[[
##########################################################
STYLE
##########################################################
]]--
local StyleRewardIcon = function(self)
  local icon = self.Icon or self.icon
  if(icon) then
    local texture = icon:GetTexture()
    icon:SetTexture(texture)
    icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
    icon:ClearAllPoints()
    icon:InsetPoints(self, 1, 1)
    icon:SetDesaturated(false)
  end
end

local MasterPlan_GarrPortraits = function(self)
  local parent = self:GetParent()
  parent:RemoveTextures()
  self:ClearAllPoints()
  self:SetPoint("TOPLEFT", parent, "TOPLEFT", -3, 0)
  self:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 3, -6)
  self:SetTexture(RING_TEXTURE)
  self:SetVertexColor(1, 0.86, 0)
  if(parent:GetWidth() == 36) then
    tinsert(FOCUS_RINGS, parent)
  end
end

local GarrMission_FocusRings = function(self)
  for k,frame in pairs(FOCUS_RINGS) do
    frame:RemoveTextures()
  end
end

local GarrMission_Rewards = function(self)
  local frame = self:GetParent()
  if(frame and (not frame.Panel)) then
    local size = frame:GetHeight() - 6
    frame:RemoveTextures()
    frame:SetStyle("Frame", 'Icon', true, 2)
    hooksecurefunc(frame, "SetPoint", StyleRewardIcon)
  end
end

local GarrMission_Buttons = function(self)
  local frame = self:GetParent()
  if(frame) then
    SV.API:Set("ItemButton", frame)
  end
end

local GarrMission_Highlights = function(self)
  local parent = self:GetParent()
  if(not parent.AtlasHighlight) then
      local frame = parent:CreateTexture(nil, "HIGHLIGHT")
    frame:InsetPoints(parent,1,1)
    frame:SetTexture(HIGHLIGHT_TEXTURE)
    frame:SetGradientAlpha("VERTICAL",0.1,0.82,0.95,0.1,0.1,0.82,0.95,0.68)
    parent.AtlasHighlight = frame
  end
  self:SetTexture("")
end

local function StyleMasterPlan()
	assert(MasterPlan, "AddOn Not Loaded")

  SV:SetAtlasFunc("MasterPlan_GarrPortraits", MasterPlan_GarrPortraits)
  SV:SetAtlasFunc("GarrMission_Rewards", GarrMission_Rewards)
  SV:SetAtlasFunc("GarrMission_Buttons", GarrMission_Buttons)
  SV:SetAtlasFunc("GarrMission_Highlights", GarrMission_Highlights)

  SV:SetAtlasFilter("Garr_FollowerPortrait_Ring", "MasterPlan_GarrPortraits");
  SV:SetAtlasFilter("_GarrMission_MissionListTopHighlight", "GarrMission_Highlights")
  SV:SetAtlasFilter("!GarrMission_Bg-Edge", "GarrMission_Buttons")
  SV:SetAtlasFilter("GarrMission_RewardsShadow", "GarrMission_Rewards")

  SV:SetAtlasFilter("_GarrMission_TopBorder-Highlight");
  SV:SetAtlasFilter("GarrMission_ListGlow-Highlight");
  SV:SetAtlasFilter("GarrMission_TopBorderCorner-Highlight");
  SV:SetAtlasFilter("Garr_InfoBox-BackgroundTile");
  SV:SetAtlasFilter("_Garr_InfoBoxBorder-Top");
  SV:SetAtlasFilter("!Garr_InfoBoxBorder-Left");
  SV:SetAtlasFilter("!Garr_InfoBox-Left");
  SV:SetAtlasFilter("_Garr_InfoBox-Top");
  SV:SetAtlasFilter("Garr_InfoBoxBorder-Corner");
  SV:SetAtlasFilter("Garr_InfoBox-CornerShadow");
  SV:SetAtlasFilter("_GarrMission_Bg-BottomEdgeSmall");
  SV:SetAtlasFilter("_GarrMission_TopBorder");
  SV:SetAtlasFilter("GarrMission_TopBorderCorner");
  SV:SetAtlasFilter("Garr_MissionList-IconBG");

  -- SV:SetAtlasFunc("GarrMission_FocusRings", GarrMission_FocusRings)
  -- SV:SetAtlasFilter("GarrMission_MissionParchment", "GarrMission_FocusRings");

	SV.API:Set("Tab", GarrisonMissionFrameTab3)
	SV.API:Set("Tab", GarrisonMissionFrameTab4)
end
--[[
##########################################################
MOD LOADING
##########################################################
]]--
MOD:SaveAddonStyle("MasterPlan", StyleMasterPlan, false, true)
