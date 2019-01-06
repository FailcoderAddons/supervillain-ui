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
    QuestScrollFrame.DetailFrame:SetFrameLevel(2)
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
  --WorldMapFrame.BorderFrame.ButtonFrameEdge:SetTexture("")
  --WorldMapFrame.BorderFrame.InsetBorderTop:SetTexture("")
  --print('test StripQuestMapFrame 1')
  --print('test StripQuestMapFrame 2')
  QuestMapFrame:RemoveTextures(true)
  QuestMapFrame.DetailsFrame:RemoveTextures(true)
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

  --print('test StripQuestMapFrame 5')
  local detailWidth = QuestMapFrame.DetailsFrame.RewardsFrame:GetWidth()
  QuestMapFrame.DetailsFrame:ClearAllPoints()
  QuestMapFrame.DetailsFrame:SetPoint("BOTTOMRIGHT", QuestMapFrame, "BOTTOMRIGHT", 4, -50)
  QuestMapFrame.DetailsFrame:SetWidth(detailWidth)
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
  QuestScrollFrame.DetailFrame:SetStyle("Frame", "Blackout")

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

  -- Movable Window
  WorldMapFrame:SetMovable(true)
  WorldMapFrame:EnableMouse(true)
  WorldMapFrame:RegisterForDrag("LeftButton")
  WorldMapFrame:SetScript("OnDragStart", WorldMapFrame.StartMoving)
  WorldMapFrame:SetScript("OnDragStop", WorldMapFrame.StopMovingOrSizing)
  
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
