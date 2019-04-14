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
    WorldMapFrame:SetFrameLevel(1)
    QuestScrollFrame.DetailFrame:SetFrameLevel(2)
end

local function WorldMap_SmallView()
  local WorldMapFrame = _G.WorldMapFrame;
  WorldMapFrame.Panel:ClearAllPoints()
  WorldMapFrame.Panel:WrapPoints(WorldMapFrame, 4, 4)
  if(SVUI_WorldMapCoords) then
    SVUI_WorldMapCoords:SetPoint("BOTTOMLEFT", WorldMapFrame, "BOTTOMLEFT", 5, 5)
  end
end

local function WorldMap_FullView()
  local WorldMapFrame = _G.WorldMapFrame;
  WorldMapFrame.Panel:ClearAllPoints()
  local w, h = WorldMapDetailFrame:GetSize()
  WorldMapFrame.Panel:SetSize(w + 24, h + 98)
  WorldMapFrame.Panel:SetPoint("TOP", WorldMapFrame, "TOP", 0, 0)
  if(SVUI_WorldMapCoords) then
    SVUI_WorldMapCoords:SetPoint("BOTTOMLEFT", WorldMapFrame, "BOTTOMLEFT", 5, 5)
  end
end

local function StripQuestMapFrame()
    local WorldMapFrame = _G.WorldMapFrame;

    WorldMapFrame.BorderFrame:RemoveTextures(true);
    
    WorldMapFrame.NavBar:RemoveTextures(true);
    WorldMapFrame.NavBar.overlay:RemoveTextures(true);

    QuestMapFrame:RemoveTextures(true)
    QuestMapFrame.DetailsFrame:RemoveTextures(true)
    QuestMapFrame.DetailsFrame.CompleteQuestFrame:RemoveTextures(true)
    QuestMapFrame.DetailsFrame.CompleteQuestFrame.CompleteButton:RemoveTextures(true)
    QuestMapFrame.DetailsFrame.BackButton:RemoveTextures(true)
    QuestMapFrame.DetailsFrame.AbandonButton:RemoveTextures(true)
    QuestMapFrame.DetailsFrame.ShareButton:RemoveTextures(true)
    QuestMapFrame.DetailsFrame.TrackButton:RemoveTextures(true)
    QuestMapFrame.DetailsFrame.RewardsFrame:RemoveTextures(true)
    QuestMapFrame.DetailsFrame:SetStyle("Frame", "Paper")
    QuestMapFrame.DetailsFrame.CompleteQuestFrame.CompleteButton:SetStyle("Button")
    QuestMapFrame.DetailsFrame.BackButton:SetStyle("Button")
    QuestMapFrame.DetailsFrame.AbandonButton:SetStyle("Button")
    QuestMapFrame.DetailsFrame.ShareButton:SetStyle("Button")
    QuestMapFrame.DetailsFrame.TrackButton:SetStyle("Button")

    SV.API:Set("ScrollBar", QuestMapDetailsScrollFrame)
    SV.API:Set("Skin", QuestMapFrame.DetailsFrame.RewardsFrame, 0, -10, 0, 0)

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

    QuestScrollFrame.DetailFrame:SetStyle("Frame", "Blackout")
    
    WorldMapFrame.BorderFrame.NineSlice:RemoveTextures(true);
    WorldMapFrameCloseButton:SetFrameLevel(999)

    SV.API:Set("CloseButton", WorldMapFrameCloseButton)
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

