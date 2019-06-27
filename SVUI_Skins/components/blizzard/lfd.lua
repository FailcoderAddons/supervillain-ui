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
local LFDFrameList = {
  "LFDQueueFrameRoleButtonHealer",
  "LFDQueueFrameRoleButtonDPS",
  "LFDQueueFrameRoleButtonLeader",
  "LFDQueueFrameRoleButtonTank",
  "RaidFinderQueueFrameRoleButtonHealer",
  "RaidFinderQueueFrameRoleButtonDPS",
  "RaidFinderQueueFrameRoleButtonLeader",
  "RaidFinderQueueFrameRoleButtonTank",
  "LFGInvitePopupRoleButtonTank",
  "LFGInvitePopupRoleButtonHealer",
  "LFGInvitePopupRoleButtonDPS",
};

local LFGStatusList = {
  "LFGDungeonReadyStatusIndividualPlayer1",
  "LFGDungeonReadyStatusIndividualPlayer2",
  "LFGDungeonReadyStatusIndividualPlayer3",
  "LFGDungeonReadyStatusIndividualPlayer4",
  "LFGDungeonReadyStatusIndividualPlayer5"
};

local function StyleMoneyRewards(frameName)
  local frame = _G[frameName]
  local icon = _G[frameName .. "IconTexture"]
  if(not frame.Panel and icon) then
      local size = frame:GetHeight() - 6
      local texture = icon:GetTexture()
      frame:RemoveTextures()
      frame:SetStyle("!_Frame", "Inset")
      icon:SetTexture(texture)
      icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
      icon:ClearAllPoints()
      icon:SetPoint("TOPLEFT", frame, "TOPLEFT", 3, -3)
      icon:SetSize(size, size)
      if(not frame.IconSlot) then
        frame.IconSlot = CreateFrame("Frame", nil, frame)
        frame.IconSlot:WrapPoints(icon)
        frame.IconSlot:SetStyle("Icon")
        icon:SetParent(frame.IconSlot)
      end
  end
end

local Incentive_OnShow = function(button)
  local parent = button:GetParent()
  local check = parent.checkButton or parent.CheckButton
  ActionButton_ShowOverlayGlow(check)
end

local Incentive_OnHide = function(button)
  local parent = button:GetParent()
  local check = parent.checkButton or parent.CheckButton
  ActionButton_HideOverlayGlow(check)
end

local LFDQueueRandom_OnUpdate = function()
  LFDQueueFrame:RemoveTextures()
  for u = 1, LFD_MAX_REWARDS do
    local t = _G["LFDQueueFrameRandomScrollFrameChildFrameItem"..u]
    local icon = _G["LFDQueueFrameRandomScrollFrameChildFrameItem"..u.."IconTexture"]
    if t then
      if not t.restyled then
        local x = _G["LFDQueueFrameRandomScrollFrameChildFrameItem"..u.."ShortageBorder"]
        local y = _G["LFDQueueFrameRandomScrollFrameChildFrameItem"..u.."Count"]
        local z = _G["LFDQueueFrameRandomScrollFrameChildFrameItem"..u.."NameFrame"]
        icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
        icon:SetDrawLayer("OVERLAY")
        y:SetDrawLayer("OVERLAY")
        z:SetTexture()
        z:SetSize(118, 39)
        x:SetAlpha(0)
        t.border = CreateFrame("Frame", nil, t)
        t.border:SetStyle("!_Frame")
        t.border:WrapPoints(icon)
        icon:SetParent(t.border)
        y:SetParent(t.border)
        t.restyled = true;
        for A = 1, 3 do
          local B = _G["LFDQueueFrameRandomScrollFrameChildFrameItem"..u.."RoleIcon"..A]
          if B then
             B:SetParent(t.border)
          end
        end
      end
    end
  end
end

local ScenarioQueueRandom_OnUpdate = function()
  LFDQueueFrame:RemoveTextures()
  for u = 1, LFD_MAX_REWARDS do
    local t = _G["ScenarioQueueFrameRandomScrollFrameChildFrameItem"..u]
    local icon = _G["ScenarioQueueFrameRandomScrollFrameChildFrameItem"..u.."IconTexture"]
    if t then
      if not t.restyled then
        local x = _G["ScenarioQueueFrameRandomScrollFrameChildFrameItem"..u.."ShortageBorder"]
        local y = _G["ScenarioQueueFrameRandomScrollFrameChildFrameItem"..u.."Count"]
        local z = _G["ScenarioQueueFrameRandomScrollFrameChildFrameItem"..u.."NameFrame"]icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
        icon:SetDrawLayer("OVERLAY")
        y:SetDrawLayer("OVERLAY")
        z:SetTexture()
        z:SetSize(118, 39)
        x:SetAlpha(0)
        t.border = CreateFrame("Frame", nil, t)
        t.border:SetStyle("!_Frame")
        t.border:WrapPoints(icon)
        icon:SetParent(t.border)
        y:SetParent(t.border)
        t.restyled = true
      end
    end
  end
  StyleMoneyRewards("LFDQueueFrameRandomScrollFrameChildFrameMoneyReward")
  StyleMoneyRewards("RaidFinderQueueFrameScrollFrameChildFrameMoneyReward")
  StyleMoneyRewards("ScenarioQueueFrameRandomScrollFrameChildFrameMoneyReward")
end
--[[
##########################################################
LFD MODR
##########################################################
]]--
local function LFDFrameStyle()
    if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.lfg ~= true then return end

    SV.API:Set("Window", PVEFrame)

    LFGDungeonReadyDialog:RemoveTextures()
    LFGDungeonReadyDialog:SetStyle("Frame", "Pattern", true, 2, 4, 4)

    PVEFrameLeftInset:RemoveTextures()
    RaidFinderQueueFrame:RemoveTextures(true)
    PVEFrameBg:Hide()
    PVEFrame.TitleBg:Hide()
    PVEFrameTRCorner:Hide()
    PVEFrameTopLine:Hide()
    PVEFrame.shadows:Hide()
    PVEFrame:EnableMouse(false)

    LFDQueueFramePartyBackfillBackfillButton:SetStyle("Button")
    LFDQueueFramePartyBackfillNoBackfillButton:SetStyle("Button")
    LFDQueueFrameRandomScrollFrameChildFrameBonusRepFrame.ChooseButton:SetStyle("Button")
    ScenarioQueueFrameRandomScrollFrameChildFrameBonusRepFrame.ChooseButton:SetStyle("Button")

    SV.API:Set("ScrollBar", ScenarioQueueFrameRandomScrollFrame)

    GroupFinderFrameGroupButton1.icon:SetTexture("Interface\\Icons\\INV_Helmet_08")
    GroupFinderFrameGroupButton2.icon:SetTexture("Interface\\Icons\\Icon_Scenarios")
    GroupFinderFrameGroupButton3.icon:SetTexture("Interface\\LFGFrame\\UI-LFR-PORTRAIT")
    GroupFinderFrameGroupButton4.icon:SetTexture("Interface\\Icons\\Achievement_General_StayClassy")

    LFGDungeonReadyDialogBackground:Die()
    LFGDungeonReadyDialogEnterDungeonButton:SetStyle("Button")
    LFGDungeonReadyDialogLeaveQueueButton:SetStyle("Button")
    SV.API:Set("CloseButton", LFGDungeonReadyDialogCloseButton)

    LFGDungeonReadyStatus:RemoveTextures()
    LFGDungeonReadyStatus:SetStyle("Frame", "Pattern", true, 2, 4, 4)
    LFGDungeonReadyPopup:RemoveTextures()
    LFGDungeonReadyPopup:SetStyle("Frame", "Pattern", true, 2, 4, 4)

    for _,name in pairs(LFDFrameList) do
    local frame = _G[name];
    if(frame) then
      frame:DisableDrawLayer("BACKGROUND")
      frame:DisableDrawLayer("OVERLAY")
      if(frame.incentiveIcon) then
        frame.incentiveIcon:SetAlpha(0);
        frame.incentiveIcon:HookScript("OnShow", Incentive_OnShow);
        frame.incentiveIcon:HookScript("OnHide", Incentive_OnHide);
      end
      if(frame.checkButton) then
        frame.checkButton:SetStyle("CheckButton");
      end
      if(frame.shortageBorder) then
        frame.shortageBorder:Die();
      end
      if(frame.cover) then
        frame.cover:SetTexture("Interface\\AddOns\\SVUI_Skins\\artwork\\UI-LFG-ICON-ROLES")
      end
      frame:SetNormalTexture("Interface\\AddOns\\SVUI_Skins\\artwork\\UI-LFG-ICON-ROLES")
    end
    end

    for _,name in pairs(LFGStatusList) do
    local frame = _G[name];
    if(frame) then
      local tex = _G[name..'Texture'];
      if(tex) then
        tex:SetTexture("Interface\\AddOns\\SVUI_Skins\\artwork\\UI-LFG-ICON-ROLES")
      end
    end
    end

    LFGDungeonReadyDialog.filigree:SetAlpha(0)
    LFGDungeonReadyDialog.bottomArt:SetAlpha(0)
    SV.API:Set("CloseButton", LFGDungeonReadyStatusCloseButton)

    LFDQueueFrameRoleButtonLeader.leadIcon = LFDQueueFrameRoleButtonLeader:CreateTexture(nil, 'BACKGROUND')
    LFDQueueFrameRoleButtonLeader.leadIcon:SetTexture([[Interface\GroupFrame\UI-Group-LeaderIcon]])
    LFDQueueFrameRoleButtonLeader.leadIcon:SetPoint(LFDQueueFrameRoleButtonLeader:GetNormalTexture():GetPoint())
    LFDQueueFrameRoleButtonLeader.leadIcon:SetSize(50, 50)
    LFDQueueFrameRoleButtonLeader.leadIcon:SetAlpha(0.4)
    RaidFinderQueueFrameRoleButtonLeader.leadIcon = RaidFinderQueueFrameRoleButtonLeader:CreateTexture(nil, 'BACKGROUND')
    RaidFinderQueueFrameRoleButtonLeader.leadIcon:SetTexture([[Interface\GroupFrame\UI-Group-LeaderIcon]])
    RaidFinderQueueFrameRoleButtonLeader.leadIcon:SetPoint(RaidFinderQueueFrameRoleButtonLeader:GetNormalTexture():GetPoint())
    RaidFinderQueueFrameRoleButtonLeader.leadIcon:SetSize(50, 50)
    RaidFinderQueueFrameRoleButtonLeader.leadIcon:SetAlpha(0.4)

    if(QueueStatusFrame and QueueStatusFrame.StatusEntriesPool) then
    for i=1, #QueueStatusFrame.StatusEntriesPool do
      local node = QueueStatusFrame.StatusEntriesPool[i];
      if(node.RoleIcon1) then
        node.RoleIcon1:SetTexture("Interface\\AddOns\\SVUI_Skins\\artwork\\UI-LFG-ICON-ROLES")
      end
      if(node.RoleIcon2) then
        node.RoleIcon2:SetTexture("Interface\\AddOns\\SVUI_Skins\\artwork\\UI-LFG-ICON-ROLES")
      end
      if(node.RoleIcon3) then
        node.RoleIcon3:SetTexture("Interface\\AddOns\\SVUI_Skins\\artwork\\UI-LFG-ICON-ROLES")
      end
      if(node.HealersFound) then
        node.HealersFound.Cover:SetTexture("Interface\\AddOns\\SVUI_Skins\\artwork\\UI-LFG-ICON-ROLES")
        node.HealersFound.Texture:SetTexture("Interface\\AddOns\\SVUI_Skins\\artwork\\UI-LFG-ICON-ROLES")
      end
      if(node.TanksFound) then
        node.TanksFound.Cover:SetTexture("Interface\\AddOns\\SVUI_Skins\\artwork\\UI-LFG-ICON-ROLES")
        node.TanksFound.Texture:SetTexture("Interface\\AddOns\\SVUI_Skins\\artwork\\UI-LFG-ICON-ROLES")
      end
      if(node.DamagersFound) then
        node.DamagersFound.Cover:SetTexture("Interface\\AddOns\\SVUI_Skins\\artwork\\UI-LFG-ICON-ROLES")
        node.DamagersFound.Texture:SetTexture("Interface\\AddOns\\SVUI_Skins\\artwork\\UI-LFG-ICON-ROLES")
      end
    end
    end

    hooksecurefunc('LFG_DisableRoleButton', function(self)
    local check = self.checkButton or self.CheckButton
    if(check) then
      if(check:GetChecked()) then
         check:SetAlpha(1)
      else
         check:SetAlpha(0)
      end
    end
    if self.background then
       self.background:Show()
    end
    end)

    hooksecurefunc('LFG_EnableRoleButton', function(self)
    local check = self.checkButton or self.CheckButton
    if(check) then
      check:SetAlpha(1)
    end
    end)

    hooksecurefunc("LFG_PermanentlyDisableRoleButton", function(self)
    if self.background then
       self.background:Show()
       self.background:SetDesaturated(true)
    end
    end)

    for i = 1, 4 do
    local button = GroupFinderFrame["groupButton"..i]
    if(button) then
      button.ring:Hide()
      button.bg:SetTexture("")
      button.bg:SetAllPoints()
      button:SetStyle("Frame", 'Button')
      button:SetStyle("Button")
      button.icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
      button.icon:SetDrawLayer("OVERLAY")
      button.icon:SetSize(40, 40)
      button.icon:ClearAllPoints()
      button.icon:SetPoint("LEFT", button, "LEFT", 10, 0)
      button.border = CreateFrame("Frame", nil, button)
      button.border:SetStyle("!_Frame", 'Default')
      button.border:WrapPoints(button.icon)
      button.icon:SetParent(button.border)
    end
    end

    for u = 1, 3 do
     SV.API:Set("Tab", _G['PVEFrameTab'..u])
    end

    PVEFrameTab1:SetPoint('BOTTOMLEFT', PVEFrame, 'BOTTOMLEFT', 19, -31)
    SV.API:Set("CloseButton", PVEFrameCloseButton)
    LFDParentFrame:RemoveTextures()
    LFDQueueFrameFindGroupButton:RemoveTextures()
    LFDParentFrameInset:Hide()
    LFDQueueFrameFindGroupButton:SetStyle("Button")
    hooksecurefunc("LFDQueueFrameRandom_UpdateFrame", LFDQueueRandom_OnUpdate)

    SV.API:Set("DropDown", LFDQueueFrameTypeDropDown)

    RaidFinderFrame:RemoveTextures()
    RaidFinderFrameBottomInset:RemoveTextures()
    RaidFinderFrameRoleInset:Hide()
    RaidFinderFrameBottomInset:Hide()
    SV.API:Set("DropDown", RaidFinderQueueFrameSelectionDropDown)
    RaidFinderFrameFindRaidButton:RemoveTextures()
    RaidFinderFrameFindRaidButton:SetStyle("Button")
    RaidFinderQueueFrame:RemoveTextures()

    for u = 1, LFD_MAX_REWARDS do
    local t = _G["RaidFinderQueueFrameScrollFrameChildFrameItem"..u]
    local icon = _G["RaidFinderQueueFrameScrollFrameChildFrameItem"..u.."IconTexture"]
    if t then
      if not t.restyled then
        local x = _G["RaidFinderQueueFrameScrollFrameChildFrameItem"..u.."ShortageBorder"]
        local y = _G["RaidFinderQueueFrameScrollFrameChildFrameItem"..u.."Count"]
        local z = _G["RaidFinderQueueFrameScrollFrameChildFrameItem"..u.."NameFrame"]
        t:RemoveTextures()
        icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
        icon:SetDrawLayer("OVERLAY")
        y:SetDrawLayer("OVERLAY")
        z:SetTexture()
        z:SetSize(118, 39)
        x:SetAlpha(0)
        t.border = CreateFrame("Frame", nil, t)
        t.border:SetStyle("!_Frame")
        t.border:WrapPoints(icon)
        icon:SetParent(t.border)
        y:SetParent(t.border)
        t.restyled = true
      end
    end
    end

    StyleMoneyRewards("LFDQueueFrameRandomScrollFrameChildFrameMoneyReward")
    StyleMoneyRewards("RaidFinderQueueFrameScrollFrameChildFrameMoneyReward")
    StyleMoneyRewards("ScenarioQueueFrameRandomScrollFrameChildFrameMoneyReward")


    ScenarioFinderFrameInset:DisableDrawLayer("BORDER")
    ScenarioQueueFrame.Bg:Hide()
    ScenarioFinderFrameInset:Hide()
    hooksecurefunc("ScenarioQueueFrameRandom_UpdateFrame", ScenarioQueueRandom_OnUpdate)
    ScenarioQueueFrameFindGroupButton:RemoveTextures()
    ScenarioQueueFrameFindGroupButton:SetStyle("Button")
    SV.API:Set("DropDown", ScenarioQueueFrameTypeDropDown)
    LFRBrowseFrameRoleInset:DisableDrawLayer("BORDER")
    RaidBrowserFrameBg:Hide()
    LFRQueueFrameSpecificListScrollFrameScrollBackgroundTopLeft:Hide()
    LFRQueueFrameSpecificListScrollFrameScrollBackgroundBottomRight:Hide()
    LFRBrowseFrameRoleInset:Hide()

    RaidBrowserFrame:SetStyle("Frame", 'Pattern')
    SV.API:Set("CloseButton", RaidBrowserFrameCloseButton)
    LFRQueueFrameFindGroupButton:SetStyle("Button")
    LFRQueueFrameAcceptCommentButton:SetStyle("Button")
    SV.API:Set("ScrollBar", LFRQueueFrameCommentScrollFrame)
    SV.API:Set("ScrollBar", LFDQueueFrameSpecificListScrollFrame)

    RaidBrowserFrame:HookScript('OnShow', function()
    if not LFRQueueFrameSpecificListScrollFrame.styled then
      SV.API:Set("ScrollBar", LFRQueueFrameSpecificListScrollFrame)
      LFRBrowseFrame:RemoveTextures()
      for u = 1, 2 do
        local C = _G['LFRParentFrameSideTab'..u]
        C:DisableDrawLayer('BACKGROUND')
        C:GetNormalTexture():SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
        C:GetNormalTexture():InsetPoints()
        C.pushed = true;
        C:SetStyle("Frame", "Default")
        C.Panel:SetAllPoints()
        C:SetStyle("Frame")
        hooksecurefunc(C:GetHighlightTexture(), "SetTexture", function(o, D)
          if D ~= nil then
             o:SetTexture("")
          end
        end)
      end
      for u = 1, 7 do
        local C = _G['LFRBrowseFrameColumnHeader'..u]
        C:DisableDrawLayer('BACKGROUND')
      end
      SV.API:Set("DropDown", LFRBrowseFrameRaidDropDown)
      LFRBrowseFrameRefreshButton:SetStyle("Button")
      LFRBrowseFrameInviteButton:SetStyle("Button")
      LFRBrowseFrameSendMessageButton:SetStyle("Button")
      LFRQueueFrameSpecificListScrollFrameScrollBar.styled = true
    end
    end)

    LFGInvitePopup:RemoveTextures()
    LFGInvitePopup:SetStyle("Frame", "Pattern", true, 2, 4, 4)
    LFGInvitePopup.timeOut = 60;
    LFGInvitePopupAcceptButton:SetStyle("Button")
    LFGInvitePopupDeclineButton:SetStyle("Button")

    _G[LFDQueueFrame.PartyBackfill:GetName().."BackfillButton"]:SetStyle("Button")
    _G[LFDQueueFrame.PartyBackfill:GetName().."NoBackfillButton"]:SetStyle("Button")
    _G[RaidFinderQueueFrame.PartyBackfill:GetName().."BackfillButton"]:SetStyle("Button")
    _G[RaidFinderQueueFrame.PartyBackfill:GetName().."NoBackfillButton"]:SetStyle("Button")
    _G[ScenarioQueueFrame.PartyBackfill:GetName().."BackfillButton"]:SetStyle("Button")
    _G[ScenarioQueueFrame.PartyBackfill:GetName().."NoBackfillButton"]:SetStyle("Button")

    SV.API:Set("ScrollBar", LFDQueueFrameRandomScrollFrame)
    SV.API:Set("ScrollBar", ScenarioQueueFrameSpecificScrollFrame)
    LFDQueueFrameRandomScrollFrameScrollBar:SetStyle("Frame", 'Transparent')
    ScenarioQueueFrameRandomScrollFrameScrollBar:SetStyle("Frame", 'Transparent')
    RaidFinderQueueFrameScrollFrameScrollBar:SetStyle("Frame", 'Transparent')

    LFGListFrame.CategorySelection:RemoveTextures()
    LFGListFrame.CategorySelection.Inset:RemoveTextures()
    LFGListFrame.CategorySelection.StartGroupButton:RemoveTextures()
    LFGListFrame.CategorySelection.StartGroupButton:SetStyle("Button")
    LFGListFrame.CategorySelection.FindGroupButton:RemoveTextures()
    LFGListFrame.CategorySelection.FindGroupButton:SetStyle("Button")

    LFGListFrame.NothingAvailable:RemoveTextures()
    LFGListFrame.NothingAvailable.Inset:RemoveTextures()

    LFGListFrame.SearchPanel:RemoveTextures()
    LFGListFrame.SearchPanel.ResultsInset:RemoveTextures()

    LFGListFrame.SearchPanel.RefreshButton:SetStyle("Button")

    LFGListFrame.SearchPanel.FilterButton:RemoveTextures()
    LFGListFrame.SearchPanel.FilterButton:SetStyle("Button")

    LFGListFrame.SearchPanel.BackButton:RemoveTextures()
    LFGListFrame.SearchPanel.BackButton:SetStyle("Button")
    LFGListFrame.SearchPanel.SignUpButton:RemoveTextures()
    LFGListFrame.SearchPanel.SignUpButton:SetStyle("Button")

    SV.API:Set("!_EditBox", LFGListFrame.SearchPanel.SearchBox, false, false, -2, -1)
    SV.API:Set("ScrollBar", LFGListSearchPanelScrollFrame)
    PVEFrame:EnableMouse(true)
end
--[[
##########################################################
MOD LOADING
##########################################################
]]--
MOD:SaveCustomStyle("LFD", LFDFrameStyle)
