--[[
##########################################################
S V U I   By: Failcoder
########################################################## 
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local unpack  = _G.unpack;
local select  = _G.select;
local pairs   = _G.pairs;
local string  = _G.string;
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
OMEN
##########################################################
]]--
local function StyleOmen()
  assert(Omen, "AddOn Not Loaded")
  
  --[[ Background Settings ]]--
  Omen.db.profile.Background.BarInset = 3
  Omen.db.profile.Background.EdgeSize = 1
  Omen.db.profile.Background.Texture = "None"
  
  --[[ Bar Settings ]]--
  Omen.db.profile.Bar.Font = "SVUI Default Font"
  Omen.db.profile.Bar.FontOutline = "None"
  Omen.db.profile.Bar.FontSize = 11
  Omen.db.profile.Bar.Height = 14
  Omen.db.profile.Bar.ShowHeadings = false
  Omen.db.profile.Bar.ShowTPS = false
  Omen.db.profile.Bar.Spacing = 1
  Omen.db.profile.Bar.Texture = "SVUI MultiColorBar"
 
 --[[ Titlebar Settings ]]--  
  Omen.db.profile.TitleBar.BorderColor.g = 0
  Omen.db.profile.TitleBar.BorderColor.r = 0
  Omen.db.profile.TitleBar.BorderTexture = "None"
  Omen.db.profile.TitleBar.EdgeSize = 1
  Omen.db.profile.TitleBar.Font = "Arial Narrow"
  Omen.db.profile.TitleBar.FontSize = 12
  Omen.db.profile.TitleBar.Height = 23
  Omen.db.profile.TitleBar.ShowTitleBar=true
  Omen.db.profile.TitleBar.Texture = "None"
  Omen.db.profile.TitleBar.UseSameBG = false

  hooksecurefunc(Omen, 'UpdateBackdrop', function(self)
    if(not MOD.Docklet:IsEmbedded("Omen")) then
      SV.API:Set("Frame", self.BarList, 'Transparent')
      self.Title:RemoveTextures()
      self.Title:SetStyle("Frame", "Default")
      self.Title:SetPanelColor("class")
    end
    self.BarList:SetPoint('TOPLEFT', self.Title, 'BOTTOMLEFT', 0, 1)
  end)

  Omen:UpdateBackdrop()
  Omen:ReAnchorBars()
  Omen:ResizeBars()
end

MOD:SaveAddonStyle("Omen", StyleOmen, nil, true)