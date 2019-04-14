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
ENCOUNTERJOURNAL MODR
##########################################################
]]--
local PVP_LOST = [[Interface\WorldMap\Skull_64Red]]

local function Tab_OnEnter(this)
  this.backdrop:SetPanelColor("highlight")
  this.backdrop:SetBackdropBorderColor(0.1, 0.8, 0.8)
end

local function Tab_OnLeave(this)
  this.backdrop:SetPanelColor("dark")
  this.backdrop:SetBackdropBorderColor(0,0,0,1)
end

local function ChangeTabHelper(this, xOffset, yOffset)
  this:SetNormalTexture(SV.NoTexture)
  this:SetPushedTexture(SV.NoTexture)
  this:SetDisabledTexture(SV.NoTexture)
  this:SetHighlightTexture(SV.NoTexture)

  this.backdrop = CreateFrame("Frame", nil, this)
  this.backdrop:InsetPoints(this)
  this.backdrop:SetFrameLevel(0)

  this.backdrop:SetStyle("Frame")
  this.backdrop:SetPanelColor("dark")
  this:HookScript("OnEnter",Tab_OnEnter)
  this:HookScript("OnLeave",Tab_OnLeave)

  local initialAnchor, anchorParent, relativeAnchor, xPosition, yPosition = this:GetPoint()
  this:ClearAllPoints()
  this:SetPoint(initialAnchor, anchorParent, relativeAnchor, xOffset or 0, yOffset or 0)
end

local function Outline(frame, noHighlight)
    if(frame.Outlined) then return; end
    local offset = noHighlight and 30 or 5
    local mod = noHighlight and 50 or 5

    local panel = CreateFrame('Frame', nil, frame)
    panel:SetPoint('TOPLEFT', frame, 'TOPLEFT', 1, -1)
    panel:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -1, 1)

    --[[ UNDERLAY BORDER ]]--
    local borderLeft = panel:CreateTexture(nil, "BORDER")
    borderLeft:SetColorTexture(0, 0, 0)
    borderLeft:SetPoint("TOPLEFT")
    borderLeft:SetPoint("BOTTOMLEFT")
    borderLeft:SetWidth(offset)

    local borderRight = panel:CreateTexture(nil, "BORDER")
    borderRight:SetColorTexture(0, 0, 0)
    borderRight:SetPoint("TOPRIGHT")
    borderRight:SetPoint("BOTTOMRIGHT")
    borderRight:SetWidth(offset)

    local borderTop = panel:CreateTexture(nil, "BORDER")
    borderTop:SetColorTexture(0, 0, 0)
    borderTop:SetPoint("TOPLEFT")
    borderTop:SetPoint("TOPRIGHT")
    borderTop:SetHeight(mod)

    local borderBottom = panel:CreateTexture(nil, "BORDER")
    borderBottom:SetColorTexture(0, 0, 0)
    borderBottom:SetPoint("BOTTOMLEFT")
    borderBottom:SetPoint("BOTTOMRIGHT")
    borderBottom:SetHeight(mod)

    if(not noHighlight) then
      local highlight = frame:CreateTexture(nil, "HIGHLIGHT")
      highlight:SetColorTexture(0, 1, 1, 0.35)
      highlight:SetAllPoints(panel)
    end

    frame.Outlined = true
end

local function _hook_EncounterJournal_SetBullets(object, ...)
    local parent = object:GetParent();
    if (parent.Bullets and #parent.Bullets > 0) then
        for i = 1, #parent.Bullets do
            local bullet = parent.Bullets[i];
            bullet.Text:SetTextColor(1,1,1)
        end
    end
end

local function _hook_EncounterJournal_ListInstances()
  local frame = EncounterJournal.instanceSelect.scroll.child
  local index = 1
  local instanceButton = frame["instance"..index];
  while instanceButton do
      Outline(instanceButton)
      index = index + 1;
      instanceButton = frame["instance"..index]
  end
end

local function _hook_EncounterJournal_ToggleHeaders(self)
  if (not self or not self.isOverview) then
    local usedHeaders = EncounterJournal.encounter.usedHeaders
    for key,used in pairs(usedHeaders) do
      if(not used.button.Panel) then
          used:RemoveTextures(true)
          used.button:RemoveTextures(true)
          used.button:SetStyle("Button")
      end
      used.description:SetTextColor(1, 1, 1)
      --used.button.portrait.icon:Hide()
    end
  else
    local overviews = EncounterJournal.encounter.overviewFrame.overviews
    for i = 1, #overviews do
      local overview = overviews[i];
      if(overview) then
        if(not overview.Panel) then
            overview:RemoveTextures(true)
            overview.button:RemoveTextures(true)
            overview:SetStyle("Button")
        end
        if(overview.loreDescription) then
          overview.loreDescription:SetTextColor(1, 1, 1)
        end
        if(overview.description) then
          overview.description:SetTextColor(1, 1, 1)
        end
      end
    end
  end
end

local function _hook_EncounterJournal_LootUpdate()
  local scrollFrame = EncounterJournal.encounter.info.lootScroll;
  local offset = HybridScrollFrame_GetOffset(scrollFrame);
  local items = scrollFrame.buttons;
  local item, index;

  local numLoot = EJ_GetNumLoot()

  for i = 1,#items do
    item = items[i];
    index = offset + i;
    if index <= numLoot then
        item.icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
        SV.API:Set("ItemButton", item)
        item.slot:SetTextColor(0.5, 1, 0)
        item.armorType:SetTextColor(1, 1, 0)
        item.boss:SetTextColor(0.7, 0.08, 0)
    end
  end
end

local function EncounterJournalStyle()
    if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.encounterjournal ~= true then
         return
    end

    EncounterJournal:RemoveTextures(true)
    EncounterJournalInstanceSelect:RemoveTextures(true)
    EncounterJournalInset:RemoveTextures(true)
    EncounterJournal.NineSlice:RemoveTextures(true);
    EncounterJournalNavBar.overlay:RemoveTextures(true);

    EncounterJournalEncounterFrame:RemoveTextures(true)
    EncounterJournalEncounterFrameInfo:RemoveTextures(true)
    EncounterJournalEncounterFrameInfoDifficulty:RemoveTextures(true)
    EncounterJournalEncounterFrameInfoLootScrollFrameFilterToggle:RemoveTextures(true)

    ChangeTabHelper(EncounterJournalEncounterFrameInfoOverviewTab, 10)
    ChangeTabHelper(EncounterJournalEncounterFrameInfoLootTab, 0, -10)
    ChangeTabHelper(EncounterJournalEncounterFrameInfoBossTab, 0, -10)
    ChangeTabHelper(EncounterJournalEncounterFrameInfoModelTab, 0, -20)

    EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollBar:RemoveTextures()
    EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChildTitle:SetTextColor(1,1,0)
    EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChildLoreDescription:SetTextColor(1,1,1)
    EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChild.overviewDescription.Text:SetTextColor(1,1,1)

    EncounterJournalSearchResults:RemoveTextures(true)
    SV.API:Set("EditBox", EncounterJournalSearchBox)

    EncounterJournal:SetStyle("Frame", "Window")
    EncounterJournalInset:SetStyle("!_Frame", "Window2")
    EncounterJournalInset:SetPanelColor("darkest")


    SV.API:Set("ScrollBar", EncounterJournalInstanceSelectScrollFrame)
    SV.API:Set("ScrollBar", EncounterJournalEncounterFrameInfoBossesScrollFrame)
    SV.API:Set("ScrollBar", EncounterJournalEncounterFrameInfoOverviewScrollFrame)
    SV.API:Set("ScrollBar", EncounterJournalEncounterFrameInfoLootScrollFrame)
    SV.API:Set("ScrollBar", EncounterJournalEncounterFrameInfoDetailsScrollFrame)
    SV.API:Set("DropDown", EncounterJournalInstanceSelectTierDropDown)
    SV.API:Set("CloseButton", EncounterJournalCloseButton)

    EncounterJournalEncounterFrameInfoResetButton:SetStyle("Button")

    EncounterJournalNavBar:RemoveTextures(true)
    --EncounterJournalNavBarOverlay:RemoveTextures(true)
    EncounterJournalNavBarOverflowButton:RemoveTextures(true)
    EncounterJournalNavBarHomeButton:RemoveTextures(true)
    EncounterJournalNavBarHomeButton:SetStyle("Button")
    EncounterJournalNavBarOverflowButton:SetStyle("Button")
    EncounterJournalEncounterFrameInfoDifficulty:SetStyle("Button")
    EncounterJournalEncounterFrameInfoDifficulty:SetFrameLevel(EncounterJournalEncounterFrameInfoDifficulty:GetFrameLevel() + 10)
    EncounterJournalEncounterFrameInfoLootScrollFrameFilterToggle:SetStyle("Button")
    EncounterJournalEncounterFrameInfoLootScrollFrameFilterToggle:SetFrameLevel(EncounterJournalEncounterFrameInfoLootScrollFrameFilterToggle:GetFrameLevel() + 10)

    if(EncounterJournalSuggestFrame) then
    SV.API:Set("PageButton", EncounterJournalSuggestFrameNextButton)
    SV.API:Set("PageButton", EncounterJournalSuggestFramePrevButton, false, true)
    if(EncounterJournalSuggestFrame.Suggestion1 and EncounterJournalSuggestFrame.Suggestion1.button) then
      EncounterJournalSuggestFrame.Suggestion1.button:RemoveTextures(true)
      EncounterJournalSuggestFrame.Suggestion1.button:SetStyle("Button")
    end
    if(EncounterJournalSuggestFrame.Suggestion2 and EncounterJournalSuggestFrame.Suggestion2.centerDisplay and EncounterJournalSuggestFrame.Suggestion2.centerDisplay.button) then
      EncounterJournalSuggestFrame.Suggestion2.centerDisplay.button:RemoveTextures(true)
      EncounterJournalSuggestFrame.Suggestion2.centerDisplay.button:SetStyle("Button")
    end
    if(EncounterJournalSuggestFrame.Suggestion3 and EncounterJournalSuggestFrame.Suggestion3.centerDisplay and EncounterJournalSuggestFrame.Suggestion3.centerDisplay.button) then
      EncounterJournalSuggestFrame.Suggestion3.centerDisplay.button:RemoveTextures(true)
      EncounterJournalSuggestFrame.Suggestion3.centerDisplay.button:SetStyle("Button")
    end
    end

    local tabBaseName = "EncounterJournalInstanceSelect";
    if(_G[tabBaseName .. "SuggestTab"]) then
    _G[tabBaseName .. "SuggestTab"]:RemoveTextures(true)
    _G[tabBaseName .. "SuggestTab"]:SetStyle("Button")
    end
    if(_G[tabBaseName .. "DungeonTab"]) then
    _G[tabBaseName .. "DungeonTab"]:RemoveTextures(true)
    _G[tabBaseName .. "DungeonTab"]:SetStyle("Button")
    end
    if(_G[tabBaseName .. "RaidTab"]) then
    _G[tabBaseName .. "RaidTab"]:RemoveTextures(true)
    _G[tabBaseName .. "RaidTab"]:SetStyle("Button")
    end
    if(_G[tabBaseName .. "LootJournalTab"]) then
    _G[tabBaseName .. "LootJournalTab"]:RemoveTextures(true)
    _G[tabBaseName .. "LootJournalTab"]:SetStyle("Button")
    end

    local bgParent = EncounterJournal.encounter.instance
    local loreParent = EncounterJournal.encounter.instance.loreScroll

    bgParent.loreBG:SetPoint("TOPLEFT", bgParent, "TOPLEFT", 0, 0)
    bgParent.loreBG:SetPoint("BOTTOMRIGHT", bgParent, "BOTTOMRIGHT", 0, 90)

    SV.API:Set("Frame", loreParent, "Pattern")
    --loreParent:SetPanelColor("dark")
    loreParent.child.lore:SetTextColor(1, 1, 1)
    EncounterJournal.encounter.infoFrame.description:SetTextColor(1, 1, 1)

    loreParent:SetFrameLevel(loreParent:GetFrameLevel() + 10)

    local frame = EncounterJournal.instanceSelect.scroll.child
    local index = 1
    local instanceButton = frame["instance"..index];
    while instanceButton do
      Outline(instanceButton)
      index = index + 1;
      instanceButton = frame["instance"..index]
    end

    local bulletParent = EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChild;
    if (bulletParent.Bullets and #bulletParent.Bullets > 0) then
      for i = 1, #bulletParent.Bullets do
          local bullet = bulletParent.Bullets[1];
          bullet.Text:SetTextColor(1,1,1)
      end
    end

    EncounterJournal.instanceSelect.raidsTab:GetFontString():SetTextColor(1, 1, 1);

    SV.API:Set("DropDown", LootJournalViewDropDown)

    hooksecurefunc("EncounterJournal_SetBullets", _hook_EncounterJournal_SetBullets)
    hooksecurefunc("EncounterJournal_ListInstances", _hook_EncounterJournal_ListInstances)
    hooksecurefunc("EncounterJournal_ToggleHeaders", _hook_EncounterJournal_ToggleHeaders)
    hooksecurefunc("EncounterJournal_LootUpdate", _hook_EncounterJournal_LootUpdate)

    _hook_EncounterJournal_ToggleHeaders()
end
--[[
##########################################################
MOD LOADING
##########################################################
]]--
MOD:SaveBlizzardStyle('Blizzard_EncounterJournal', EncounterJournalStyle)
