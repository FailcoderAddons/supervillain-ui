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
CHALLENGES UI MODR
##########################################################
]]--
local function ChallengesFrameStyle()
  if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.lfg ~= true then return end 
  ChallengesFrameInset:RemoveTextures()
  ChallengesFrameInsetBg:Hide()
  ChallengesFrameDetails.bg:Hide()
  ChallengesFrameDetails:SetStyle("Frame", "Inset")
  ChallengesFrameLeaderboard:SetStyle("Button")
  select(2, ChallengesFrameDetails:GetRegions()):Hide()
  select(9, ChallengesFrameDetails:GetRegions()):Hide()
  select(10, ChallengesFrameDetails:GetRegions()):Hide()
  select(11, ChallengesFrameDetails:GetRegions()):Hide()
  ChallengesFrameDungeonButton1:SetPoint("TOPLEFT", ChallengesFrame, "TOPLEFT", 8, -83)

  for u = 1, 9 do 
    local v = ChallengesFrame["button"..u]
    v:SetStyle("Button")
    v:SetHighlightTexture("")
    v.selectedTex:SetAlpha(.2)
    v.selectedTex:SetPoint("TOPLEFT", 1, -1)
    v.selectedTex:SetPoint("BOTTOMRIGHT", -1, 1)
    v.NoMedal:Die()
  end
   
  for u = 1, 3 do 
    local F = ChallengesFrame["RewardRow"..u]
    for A = 1, 2 do 
      local v = F["Reward"..A]
      v:SetStyle("Frame")
      v.Icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
    end 
  end 
end 
--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveBlizzardStyle("Blizzard_ChallengesUI",ChallengesFrameStyle)