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
HELPERS
##########################################################
]]--
local function AdjustMapLevel()
  if InCombatLockdown()then return end
    local WorldMapFrame = _G.WorldMapFrame;
    WorldMapFrame:SetFrameStrata("HIGH");
    WorldMapTooltip:SetFrameStrata("TOOLTIP");
    --WorldMapPlayerLower:SetFrameStrata("MEDIUM");
    --WorldMapPlayerLower:SetFrameStrata("FULLSCREEN");
    WorldMapFrame:SetFrameLevel(1)
    WorldMapDetailFrame:SetFrameLevel(2)
    --WorldMapArchaeologyDigSites:SetFrameLevel(3)
end

local function WorldMap_SmallView()
  local WorldMapFrame = _G.WorldMapFrame;
  WorldMapFrame.Panel:ClearAllPoints()
  WorldMapFrame.Panel:WrapPoints(WorldMapFrame, 4, 4)
  --WorldMapFrame.Panel.Panel:WrapPoints(WorldMapFrame.Panel)
  if(SVUI_WorldMapCoords) then
    SVUI_WorldMapCoords:SetPoint("BOTTOMLEFT", WorldMapFrame, "BOTTOMLEFT", 5, 5)
  end
end

local function WorldMap_FullView()
  local WorldMapFrame = _G.WorldMapFrame;
  --WorldMapFrame:ClearAllPoints()
 -- WorldMapFrame:SetPoint("TOP", SV.Screen, "TOP", 0, 0)
  WorldMapFrame.Panel:ClearAllPoints()
  local w, h = WorldMapDetailFrame:GetSize()
  WorldMapFrame.Panel:SetSize(w + 24, h + 98)
  WorldMapFrame.Panel:SetPoint("TOP", WorldMapFrame, "TOP", 0, 0)
  --WorldMapFrame.Panel.Panel:WrapPoints(WorldMapFrame.Panel)
  if(SVUI_WorldMapCoords) then
    SVUI_WorldMapCoords:SetPoint("BOTTOMLEFT", WorldMapFrame, "BOTTOMLEFT", 5, 5)
  end
end

local function StripQuestMapFrame()
  local WorldMapFrame = _G.WorldMapFrame;

  WorldMapFrame.BorderFrame:RemoveTextures(true)
  WorldMapFrame.BorderFrame.ButtonFrameEdge:SetTexture("")
  WorldMapFrame.BorderFrame.InsetBorderTop:SetTexture("")
  WorldMapFrame.BorderFrame.Inset:RemoveTextures(true)
  --print('test StripQuestMapFrame 1')
  WorldMapTitleButton:RemoveTextures(true)
  WorldMapFrameNavBar:RemoveTextures(true)
  WorldMapFrameNavBarOverlay:RemoveTextures(true)
  --print('test StripQuestMapFrame 2')
  QuestMapFrame:RemoveTextures(true)
  QuestMapFrame.DetailsFrame:RemoveTextures(true)
  --QuestScrollFrameScrollBar:RemoveTextures(true)
  --QuestScrollFrame.ViewAll:RemoveTextures(true)
  --print('test StripQuestMapFrame 3')
  QuestMapFrame.DetailsFrame.CompleteQuestFrame:RemoveTextures(true)
  QuestMapFrame.DetailsFrame.CompleteQuestFrame.CompleteButton:RemoveTextures(true)
  QuestMapFrame.DetailsFrame.BackButton:RemoveTextures(true)
  QuestMapFrame.DetailsFrame.AbandonButton:RemoveTextures(true)
  QuestMapFrame.DetailsFrame.ShareButton:RemoveTextures(true)
  QuestMapFrame.DetailsFrame.TrackButton:RemoveTextures(true)
  QuestMapFrame.DetailsFrame.RewardsFrame:RemoveTextures(true)
  --print('test StripQuestMapFrame 4')
  QuestMapFrame.DetailsFrame:SetStyle("Frame", "Paper")
  QuestMapFrame.DetailsFrame.CompleteQuestFrame.CompleteButton:SetStyle("Button")
  QuestMapFrame.DetailsFrame.BackButton:SetStyle("Button")
  QuestMapFrame.DetailsFrame.AbandonButton:SetStyle("Button")
  QuestMapFrame.DetailsFrame.ShareButton:SetStyle("Button")
  QuestMapFrame.DetailsFrame.TrackButton:SetStyle("Button")

  SV.API:Set("ScrollBar", QuestMapDetailsScrollFrame)
  SV.API:Set("Skin", QuestMapFrame.DetailsFrame.RewardsFrame, 0, -10, 0, 0)

  --QuestScrollFrameScrollBar:SetStyle("Frame", "Paper")
  --QuestScrollFrame.ViewAll:SetStyle("Button")
  --print('test StripQuestMapFrame 5')
  local detailWidth = QuestMapFrame.DetailsFrame.RewardsFrame:GetWidth()
  QuestMapFrame.DetailsFrame:ClearAllPoints()
  QuestMapFrame.DetailsFrame:SetPoint("BOTTOMRIGHT", QuestMapFrame, "BOTTOMRIGHT", 2, 0)
  QuestMapFrame.DetailsFrame:SetWidth(detailWidth)

  WorldMapFrameNavBar:ClearAllPoints()
  WorldMapFrameNavBar:SetPoint("TOPLEFT", WorldMapFrame.Panel, "TOPLEFT", 12, -26)
  WorldMapFrameTutorialButton:ClearAllPoints()
  WorldMapFrameTutorialButton:SetPoint("LEFT", WorldMapFrameNavBar.Panel, "RIGHT", -50, 0)
end

local function WorldMap_OnShow()
  local WorldMapFrame = _G.WorldMapFrame;

  if WORLDMAP_SETTINGS.size == WORLDMAP_FULLMAP_SIZE then
    WorldMap_FullView()
  elseif WORLDMAP_SETTINGS.size == WORLDMAP_WINDOWED_SIZE then
    WorldMap_SmallView()
  end
  -- WorldMap_SmallView()
  
  -- JV - 20160918 Fix error around expectation that SV.db.Maps exists which might not be so if SVUI_Maps is not be true if it's not loaded/installed
  if ((SV.Maps and SV.db.Maps) and not SV.db.Maps.tinyWorldMap) then
    BlackoutWorld:SetColorTexture(0,0,0,1)
  else
    BlackoutWorld:SetTexture("")
  end


  WorldMapFrameAreaLabel:SetShadowOffset(2, -2)
  WorldMapFrameAreaLabel:SetTextColor(0.90, 0.8294, 0.6407)
  WorldMapFrameAreaDescription:SetShadowOffset(2, -2)
  WorldMapZoneInfo:SetShadowOffset(2, -2)

  if InCombatLockdown() then return end
  AdjustMapLevel()
end
--[[
##########################################################
WORLDMAP MODR
##########################################################
]]--
local function WorldMapStyle()
  --print('test WorldMapStyle')
  if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.worldmap ~= true then return end

  SV.API:Set("Window", WorldMapFrame, true, true)
  SV.API:Set("ScrollBar", QuestScrollFrame)
  SV.API:Set("ScrollBar", WorldMapQuestScrollFrame)
  SV.API:Set("ScrollBar", WorldMapQuestDetailScrollFrame, 4)
  SV.API:Set("ScrollBar", WorldMapQuestRewardScrollFrame, 4)

  --print('test WorldMapStyle 1')
  WorldMapDetailFrame:SetStyle("Frame", "Blackout")

  --WorldMapFrameSizeDownButton:SetFrameLevel(999)
  --WorldMapFrameSizeUpButton:SetFrameLevel(999)
  WorldMapFrameCloseButton:SetFrameLevel(999)

  --print('test WorldMapStyle 2')
  SV.API:Set("CloseButton", WorldMapFrameCloseButton)
  --SV.API:Set("ArrowButton", WorldMapFrameSizeDownButton, "down")
  --SV.API:Set("ArrowButton", WorldMapFrameSizeUpButton, "up")
  SV.API:Set("DropDown", WorldMapLevelDropDown)
  SV.API:Set("DropDown", WorldMapZoneMinimapDropDown)
  SV.API:Set("DropDown", WorldMapContinentDropDown)
  SV.API:Set("DropDown", WorldMapZoneDropDown)
  SV.API:Set("DropDown", WorldMapShowDropDown)
  --print('test WorldMapStyle 3')
  StripQuestMapFrame()

  --WorldMapFrame.UIElementsFrame:SetStyle("Frame", "Blackout")
  
  WorldMapFrame:HookScript("OnShow", WorldMap_OnShow)
  hooksecurefunc("WorldMap_ToggleSizeUp", WorldMap_OnShow)
  BlackoutWorld:SetParent(WorldMapFrame.Panel)
  --print('test WorldMapStyle 4')
  WorldMapFrameNavBar:ClearAllPoints()
  WorldMapFrameNavBar:SetPoint("TOPLEFT", WorldMapFrame.Panel, "TOPLEFT", 12, -26)
  WorldMapFrameNavBar:SetStyle("Frame", "Inset", true, 2, 2, 1)
  WorldMapFrameNavBarHomeButton:RemoveTextures(true)
  WorldMapFrameNavBarHomeButton:SetStyle("Button")
  WorldMapFrameTutorialButton:Die()

  --SV.API:Set("InfoButton", WorldMapFrameTutorialButton)
  --WorldMapFrameTutorialButton:SetPoint("LEFT", WorldMapFrameNavBar.Panel, "RIGHT", -50, 0)

  -- Movable Window
  WorldMapFrame:SetMovable(true)
  WorldMapFrame:EnableMouse(true)
  WorldMapFrame:RegisterForDrag("LeftButton")
  WorldMapFrame:SetScript("OnDragStart", WorldMapFrame.StartMoving)
  WorldMapFrame:SetScript("OnDragStop", WorldMapFrame.StopMovingOrSizing)
  
  WorldMap_OnShow()
end
--[[
##########################################################
MOD LOADING
##########################################################
]]--
MOD:SaveCustomStyle("WORLDMAP", WorldMapStyle)

--[[
function ArchaeologyDigSiteFrame_OnUpdate()
    WorldMapArchaeologyDigSites:DrawNone();
    local numEntries = ArchaeologyMapUpdateAll();
    for i = 1, numEntries do
        local blobID = ArcheologyGetVisibleBlobID(i);
        WorldMapArchaeologyDigSites:DrawBlob(blobID, true);
    end
end
]]
