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
local function AddFadeBanner(frame)
	local bg = frame:CreateTexture(nil, "OVERLAY")
	bg:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
	bg:SetPoint("BOTTOMRIGHT", frame, "RIGHT", 0, 0)
	bg:SetColorTexture(1, 1, 1, 1)
	bg:SetGradientAlpha("VERTICAL", 0, 0, 0, 0, 0, 0, 0, 0.9)
end

local function StyleTextureIcon(frame)
	if((not frame) or (not frame.Texture)) then return end
	frame.Texture:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
	if(not frame.IconSlot) then
		frame.IconSlot = CreateFrame("Frame", nil, frame)
		frame.IconSlot:WrapPoints(frame.Texture)
		frame.IconSlot:SetStyle("Icon")
		frame.Texture:SetParent(frame.IconSlot)
	end
end

local function StyleIconElement(frame)
	if(not frame) then return end
	if(frame.Icon) then
    	local size = frame:GetHeight() - 6
    	if(not frame.IconSlot) then
    		local texture = frame.Icon:GetTexture()
			frame:RemoveTextures()
			frame.IconSlot = CreateFrame("Frame", nil, frame)
			frame.IconSlot:WrapPoints(frame.Icon)
			frame.IconSlot:SetStyle("Icon")
			frame.Icon:SetParent(frame.IconSlot)
			frame.Icon:SetTexture(texture)
		end
		frame.Icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
		frame.Icon:ClearAllPoints()
		frame.Icon:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -3, -3)
		frame.Icon:SetSize(size, size)
		frame.Icon:SetDesaturated(false)
		frame.Icon:SetDrawLayer("ARTWORK", -1)
		if(frame.Quantity) then
	    	frame.Quantity:SetFontObject(SVUI_Font_Number)
	        frame.Quantity:SetParent(frame.IconSlot)
	    end
    end
end

local function _hook_GarrisonMissionFrame_SetItemRewardDetails(item)
	if(not item) then return; end
    if(item.Icon) then
    	local size = item:GetHeight() - 8
    	local texture = item.Icon:GetTexture()
		item:RemoveTextures()
    	item:SetStyle("Inset")
    	item.Icon:SetTexture(texture)
		item.Icon:ClearAllPoints()
		item.Icon:SetPoint("TOPLEFT", item, "TOPLEFT", 4, -4)
		item.Icon:SetSize(size, size)
		item.Icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
		item.Icon:SetDesaturated(false)
		if(not item.IconSlot) then
			item.IconSlot = CreateFrame("Frame", nil, item)
			item.IconSlot:SetAllPoints(item.Icon)
			item.IconSlot:SetStyle("Icon")
			item.Icon:SetParent(item.IconSlot)
		end
		item.Icon:SetDrawLayer("ARTWORK", -1)
    end
    if(item.Quantity) then
    	item.Quantity:SetFontObject(SVUI_Font_Number)
        item.Quantity:SetDrawLayer("ARTWORK", 1)
    end
end

local function StyleAbilityIcon(frame)
	if(not frame) then return; end
    if(frame.Icon) then
    	local texture = frame.Icon:GetTexture()
    	local size = frame:GetHeight() - 2
    	frame:RemoveTextures()
    	frame.Icon:SetTexture(texture)
		frame.Icon:ClearAllPoints()
		frame.Icon:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -1)
		frame.Icon:SetSize(size, size)
		frame.Icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
		frame.Icon:SetDesaturated(false)
		if(not frame.IconSlot) then
			frame.IconSlot = CreateFrame("Frame", nil, frame)
			frame.IconSlot:WrapPoints(frame.Icon)
			frame.IconSlot:SetStyle("Icon")
			frame.Icon:SetParent(frame.IconSlot)
		end
    end
end

local function StyleFollowerPortrait(frame, color)
	frame.PortraitRing:SetTexture('')
	frame.PortraitRingQuality:SetTexture(RING_TEXTURE)
end

local _hook_GarrisonCapacitiveDisplayFrame_Update = function(self)
	local reagents = GarrisonCapacitiveDisplayFrame.CapacitiveDisplay.Reagents;
    for i = 1, #reagents do
    	if(reagents[i] and (not reagents[i].Panel)) then
    		reagents[i]:RemoveTextures()
        	reagents[i]:SetStyle("Icon")
        	if(reagents[i].Icon) then
				reagents[i].Icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
			end
		end
    end
end

local _hook_GarrisonBuildingTab_Select = function()
	local list = GarrisonBuildingFrame.BuildingList;
	for i=1, GARRISON_NUM_BUILDING_SIZES do
		local tab = list["Tab"..i];
		if(tab and tab.buildings) then
			for i=1, #tab.buildings do
				_hook_GarrisonMissionFrame_SetItemRewardDetails(list.Buttons[i])
			end
		end
	end
end

local _hook_GarrisonFollowerList_Update = function(self)
    local buttons = self.FollowerList.listScroll.buttons;
    local followers = self.FollowerList.followers;
    local followersList = self.FollowerList.followersList;
    local numFollowers = #followersList;
    local scrollFrame = self.FollowerList.listScroll;
    local offset = HybridScrollFrame_GetOffset(scrollFrame);
    local numButtons = #buttons;

    for i = 1, numButtons do
        local button = buttons[i];
        local index = offset + i;
        if(index <= numFollowers) then
        	local follower = followers[followersList[index]];
	        if(not button.Panel) then
	            button:RemoveTextures()
	            button:SetStyle("Frame", 'Blackout', true, 1, 0, 0)
				if(button.XPBar) then
					button.XPBar:SetTexture(SV.media.statusbar.default)
					button.XPBar:SetGradient('HORIZONTAL', 0.5, 0, 1, 1, 0, 1)
				end
	        end
	        if(button.PortraitFrame) then
	        	local color
		        if(follower.isCollected) then
	            	color = ITEM_QUALITY_COLORS[follower.quality]
	            else
	            	color = DEFAULT_COLOR
				end
				StyleFollowerPortrait(button.PortraitFrame, color)
			end
	    end
    end
end

local _hook_GarrisonFollowerTooltipTemplate_SetGarrisonFollower = function(tooltip, data)
	local color = ITEM_QUALITY_COLORS[data.quality];
	StyleFollowerPortrait(tooltip.Portrait, color)
end

local _hook_GarrisonBuildingInfoBox_ShowFollowerPortrait = function(owned, hasFollowerSlot, infoBox, isBuilding, canActivate, ID)
	local portraitFrame = infoBox.FollowerPortrait;
	StyleFollowerPortrait(portraitFrame)
end

local _hook_GarrisonMissionFrame_SetFollowerPortrait = function(portraitFrame, followerInfo)
	local color = ITEM_QUALITY_COLORS[followerInfo.quality];
	StyleFollowerPortrait(portraitFrame, color)
end

local _hook_GarrisonRecruitSelectFrame_UpdateRecruits = function()
	local recruitFrame = GarrisonRecruitSelectFrame.FollowerSelection;
	local followers = C_Garrison.GetAvailableRecruits();
	for i=1, 3 do
		local follower = followers[i];
		local frame = recruitFrame["Recruit"..i];
		if(follower)then
			local color = ITEM_QUALITY_COLORS[follower.quality];
			StyleFollowerPortrait(frame.PortraitFrame, color);
		end
	end
end

local _hook_GarrisonMissionComplete_SetFollowerLevel = function(followerFrame, level, quality)
	if(not followerFrame or (not followerFrame.PortraitFrame)) then return end
	local color = ITEM_QUALITY_COLORS[quality];
	followerFrame.PortraitFrame.PortraitRing:SetVertexColor(color.r, color.g, color.b)
end

local function _hook_GarrisonFollowerButton_SetCounterButton(self, index, info)
	local counter = self.Counters[index];
	StyleAbilityIcon(counter)
end

local function _hook_GarrisonFollowerButton_AddAbility(self, index, ability)
	local ability = self.Abilities[index];
	StyleAbilityIcon(ability)
end

local _hook_GarrisonFollowerPage_ShowFollower = function(self, followerID)
	local followerInfo = C_Garrison.GetFollowerInfo(followerID);
    if(not self.XPBar.Panel) then
	    self.XPBar:RemoveTextures()
		self.XPBar:SetStatusBarTexture(SV.media.statusbar.default)
		self.XPBar:SetStyle("!_Frame", "Bar")
	end

    for i=1, #self.AbilitiesFrame.Abilities do
        local abilityFrame = self.AbilitiesFrame.Abilities[i];
        StyleAbilityIcon(abilityFrame.IconButton)
    end

    for i=1, #self.AbilitiesFrame.Counters do
        local abilityFrame = self.AbilitiesFrame.Counters[i];
        StyleAbilityIcon(abilityFrame)
    end
end

local _hook_GarrisonFollowerPage_UpdateMissionForParty = function(self, followerID)
	local MISSION_PAGE_FRAME = GarrisonMissionFrame.MissionTab.MissionPage;
	local totalTimeString, totalTimeSeconds, isMissionTimeImproved, successChance, partyBuffs, isEnvMechanicCountered, xpBonus, materialMultiplier = C_Garrison.GetPartyMissionInfo(MISSION_PAGE_FRAME.missionInfo.missionID);
	-- for i = 1, #MISSION_PAGE_FRAME.Enemies do
	-- 	local enemyFrame = MISSION_PAGE_FRAME.Enemies[i];
	-- 	for mechanicIndex = 1, #enemyFrame.Mechanics do
	-- 		local mechanic = enemyFrame.Mechanics[mechanicIndex];
	--         StyleAbilityIcon(mechanic)
	-- 	end
	-- end
	-- PARTY BOOFS
	local buffsFrame = MISSION_PAGE_FRAME.BuffsFrame;
	local buffCount = #partyBuffs;
	if(buffCount > 0) then
		for i = 1, buffCount do
			local buff = buffsFrame.Buffs[i];
			StyleAbilityIcon(buff)
		end
	end
end

local function StyleRewardButtons(rewardButtons)
    for i = 1, #rewardButtons do
        local frame = rewardButtons[i];
				_hook_GarrisonMissionFrame_SetItemRewardDetails(frame);
    end
end

local function StyleListButtons(parent)
	if(not parent) then return end
	local listButtons = parent.Rewards
	SV.API:Set("ItemButton", parent)
	if(parent.LocBG) then
		parent.LocBG:SetDrawLayer("ARTWORK", -2)
	end
    for i = 1, #listButtons do
        StyleIconElement(listButtons[i])
    end
end

local function StyleMissionComplete(parentFrame)
	local mComplete = parentFrame.MissionComplete;
	local mStage = mComplete.Stage;
	local mFollowers = mStage.FollowersFrame;

	mComplete:RemoveTextures()
	mComplete:SetStyle("Frame", 'Paper', false, 4, 0, 0)
	mStage:RemoveTextures()
	mStage.MissionInfo:RemoveTextures()

	if(mFollowers.Follower1 and mFollowers.Follower1.PortraitFrame) then
		StyleFollowerPortrait(mFollowers.Follower1.PortraitFrame)
	end
	if(mFollowers.Follower2 and mFollowers.Follower2.PortraitFrame) then
		StyleFollowerPortrait(mFollowers.Follower2.PortraitFrame)
	end
	if(mFollowers.Follower3 and mFollowers.Follower3.PortraitFrame) then
		StyleFollowerPortrait(mFollowers.Follower3.PortraitFrame)
	end

	AddFadeBanner(mStage)
	mComplete.NextMissionButton:RemoveTextures(true)
	mComplete.NextMissionButton:SetStyle("Button")

	local completedBG = CreateFrame("Frame", nil, parentFrame.MissionCompleteBackground)
	completedBG:SetAllPoints(parentFrame.Panel)
	local completedBGTex = completedBG:CreateTexture(nil, "BACKGROUND")
	completedBGTex:SetAllPoints(completedBG)
	completedBGTex:SetColorTexture(0,0,0,0.8)
	parentFrame.MissionCompleteBackground:DisableDrawLayer("BACKGROUND")
end

local _hook_GarrisonMissionFrame_CheckRewardButtons = function(rewards)
	StyleRewardButtons(rewards);
end

local function _hook_GarrisonMissionList_Update()
	local self = GarrisonMissionFrame
    local missionButtons = self.MissionTab.MissionList.listScroll.buttons;
    for i = 1, #missionButtons do
        StyleListButtons(missionButtons[i])
    end
    StyleRewardButtons(self.MissionTab.MissionPage.RewardsFrame.Rewards);
    StyleRewardButtons(self.MissionComplete.BonusRewards.Rewards);
end

local _hook_GarrisonMissionButton_SetRewards = function(self, rewards, numRewards)
	if (numRewards > 0) then
		local index = 1;
		for id, reward in pairs(rewards) do
	        StyleIconElement(self.Rewards[index])
		    index = index + 1;
		end
	end
end

local function LoadGarrisonStyle()
	if SV.db.Skins.blizzard.enable ~= true then
		return
	end
	--[[
	##############################################################################
	BUILDING FRAME
	##############################################################################
	--]]
	SV.API:Set("Window", GarrisonBuildingFrame, true, false, 1, 0, 4)

	GarrisonBuildingFrameFollowers:RemoveTextures()
	GarrisonBuildingFrameFollowers:SetStyle("Frame", 'Inset', true, 1, -5, -5)
	GarrisonBuildingFrameFollowers:ClearAllPoints()
	GarrisonBuildingFrameFollowers:SetPoint("LEFT", GarrisonBuildingFrame, "LEFT", 10, 0)
	GarrisonBuildingFrame.BuildingList:RemoveTextures()
	GarrisonBuildingFrame.BuildingList:SetStyle("!_Frame", 'Inset')
	GarrisonBuildingFrame.TownHallBox:RemoveTextures()
	GarrisonBuildingFrame.TownHallBox:SetStyle("!_Frame", 'Inset')
	GarrisonBuildingFrame.InfoBox:RemoveTextures()
	GarrisonBuildingFrame.InfoBox:SetStyle("!_Frame", 'Inset')
	--SV.API:Set("Tab", GarrisonBuildingFrame.BuildingList.Tab1)
	GarrisonBuildingFrame.BuildingList.Tab1:GetNormalTexture().SetAtlas = function() return end
	GarrisonBuildingFrame.BuildingList.Tab1:RemoveTextures(true)
	GarrisonBuildingFrame.BuildingList.Tab1:SetStyle("Button", -4, -10)
	--SV.API:Set("Tab", GarrisonBuildingFrame.BuildingList.Tab2)
	GarrisonBuildingFrame.BuildingList.Tab2:GetNormalTexture().SetAtlas = function() return end
	GarrisonBuildingFrame.BuildingList.Tab2:RemoveTextures(true)
	GarrisonBuildingFrame.BuildingList.Tab2:SetStyle("Button", -4, -10)
	--SV.API:Set("Tab", GarrisonBuildingFrame.BuildingList.Tab3)
	GarrisonBuildingFrame.BuildingList.Tab3:GetNormalTexture().SetAtlas = function() return end
	GarrisonBuildingFrame.BuildingList.Tab3:RemoveTextures(true)
	GarrisonBuildingFrame.BuildingList.Tab3:SetStyle("Button", -4, -10)
	GarrisonBuildingFrame.BuildingList.MaterialFrame:RemoveTextures()
	GarrisonBuildingFrame.BuildingList.MaterialFrame:SetStyle("Frame", "Inset", true, 1, -5, -7)
	GarrisonBuildingFrameTutorialButton:Die()

	SV.API:Set("CloseButton", GarrisonBuildingFrame.CloseButton)

	hooksecurefunc("GarrisonBuildingTab_Select", _hook_GarrisonBuildingTab_Select)
  hooksecurefunc("GarrisonBuildingList_SelectTab", _hook_GarrisonBuildingTab_Select)
  hooksecurefunc("GarrisonBuildingInfoBox_ShowFollowerPortrait", _hook_GarrisonBuildingInfoBox_ShowFollowerPortrait)
	--[[
	##############################################################################
	LANDING PAGE
	##############################################################################
	--]]
	SV.API:Set("Window", GarrisonLandingPage, true, false, 1, 0, 0)
	SV.API:Set("Skin", GarrisonLandingPage.FollowerTab, 12, 0, -2, 30)

	GarrisonLandingPage.FollowerTab.AbilitiesFrame:RemoveTextures()
	GarrisonLandingPage.FollowerList:RemoveTextures()
	GarrisonLandingPage.FollowerList:SetStyle("Frame", 'Inset', false, 4, 0, 0)

	local bgFrameTop = CreateFrame("Frame", nil, GarrisonLandingPage.Report)
	bgFrameTop:SetPoint("TOPLEFT", GarrisonLandingPage.Report, "TOPLEFT", 38, -91)
	bgFrameTop:SetPoint("BOTTOMRIGHT", GarrisonLandingPage.Report.List, "BOTTOMLEFT", -4, 0)
	bgFrameTop:SetStyle("Frame", "Paper")

	GarrisonLandingPageReportList:RemoveTextures()
	GarrisonLandingPageReportList:SetStyle("Frame", 'Inset', false, 4, 0, 0)
	GarrisonLandingPageReport.Available:RemoveTextures(true)
	GarrisonLandingPageReport.Available:SetStyle("Button")
	GarrisonLandingPageReport.Available:GetNormalTexture().SetAtlas = function() return end
	GarrisonLandingPageReport.InProgress:RemoveTextures(true)
	GarrisonLandingPageReport.InProgress:SetStyle("Button")
	GarrisonLandingPageReport.InProgress:GetNormalTexture().SetAtlas = function() return end

	GarrisonLandingPageShipFollowerList:RemoveTextures()
	GarrisonLandingPageShipFollowerList:SetStyle("Frame", 'Inset', false, 4, 0, 0)

	for i = 1, GarrisonLandingPageReportListListScrollFrameScrollChild:GetNumChildren() do
		local child = select(i, GarrisonLandingPageReportListListScrollFrameScrollChild:GetChildren())
		for j = 1, child:GetNumChildren() do
			local childC = select(j, child:GetChildren())
			childC.Icon:SetTexCoord(0.1,0.9,0.1,0.9)
			childC.Icon:SetDesaturated(false)
		end
	end

	local a1, p, a2, x, y = GarrisonLandingPageTab1:GetPoint()
	GarrisonLandingPageTab1:SetPoint(a1, p, a2, x, (y - 15))
	SV.API:Set("Tab", GarrisonLandingPageTab1, nil, 10, 4)
	SV.API:Set("Tab", GarrisonLandingPageTab2, nil, 10, 4)
	SV.API:Set("Tab", GarrisonLandingPageTab3, nil, 10, 4)
	SV.API:Set("ScrollBar", GarrisonLandingPageListScrollFrame)
	SV.API:Set("ScrollBar", GarrisonLandingPageReportListListScrollFrame)
	SV.API:Set("ScrollBar", GarrisonLandingPageShipFollowerListListScrollFrame)
	SV.API:Set("CloseButton", GarrisonLandingPage.CloseButton)
	GarrisonLandingPage.CloseButton:SetFrameStrata("HIGH")
	--[[
	##############################################################################
	MISSION FRAME
	##############################################################################
	--]]
	SV.API:Set("Window", GarrisonMissionFrame, true, false, 1, 0, 4)
	GarrisonMissionFrame.GarrCorners:RemoveTextures()
	GarrisonMissionFrameMissions:RemoveTextures()
	GarrisonMissionFrameMissions:SetStyle("!_Frame", "Inset")

	local readyBG = CreateFrame("Frame", nil, GarrisonMissionFrameMissions.CompleteDialog)
	readyBG:SetAllPoints(GarrisonMissionFrame.Panel)
	local readyBGTex = readyBG:CreateTexture(nil, "BACKGROUND")
	readyBGTex:SetAllPoints(readyBG)
	readyBGTex:SetColorTexture(0,0,0,0.8)

	GarrisonMissionFrameMissions.CompleteDialog:DisableDrawLayer("BACKGROUND")
	GarrisonMissionFrameMissions.CompleteDialog.BorderFrame:RemoveTextures()
	GarrisonMissionFrameMissions.CompleteDialog.BorderFrame:SetStyle("Frame", 'Window', false, 4, 0, 0)
	GarrisonMissionFrameMissions.CompleteDialog.BorderFrame.Stage:RemoveTextures()
	GarrisonMissionFrameMissions.CompleteDialog.BorderFrame.Stage:SetStyle("!_Frame", "Model")
	GarrisonMissionFrameMissions.CompleteDialog.BorderFrame.ViewButton:RemoveTextures(true)
	GarrisonMissionFrameMissions.CompleteDialog.BorderFrame.ViewButton:SetStyle("Button")

	GarrisonMissionFrameMissions.MaterialFrame:RemoveTextures()
	GarrisonMissionFrameMissions.MaterialFrame:SetStyle("Frame", "Inset", true, 1, -3, -3)

	GarrisonMissionFrame.FollowerTab.ItemWeapon:RemoveTextures()
	_hook_GarrisonMissionFrame_SetItemRewardDetails(GarrisonMissionFrame.FollowerTab.ItemWeapon)
	GarrisonMissionFrame.FollowerTab.ItemArmor:RemoveTextures()
	_hook_GarrisonMissionFrame_SetItemRewardDetails(GarrisonMissionFrame.FollowerTab.ItemArmor)

	GarrisonMissionFrame.MissionTab:RemoveTextures()
	GarrisonMissionFrame.MissionTab.MissionPage:RemoveTextures()
	GarrisonMissionFrame.MissionTab.MissionPage:SetStyle("Frame", 'Paper', false, 4, 0, 0)

	local missionChance = GarrisonMissionFrame.MissionTab.MissionPage.RewardsFrame.Chance;
	missionChance:SetFontObject(SVUI_Font_Number_Huge)
	local chanceLabel = GarrisonMissionFrame.MissionTab.MissionPage.RewardsFrame.ChanceLabel
	chanceLabel:SetFontObject(SVUI_Font_Header)
	chanceLabel:ClearAllPoints()
	chanceLabel:SetPoint("TOP", missionChance, "BOTTOM", 0, -8)

	GarrisonMissionFrame.MissionTab.MissionPage.Panel:ClearAllPoints()
	GarrisonMissionFrame.MissionTab.MissionPage.Panel:SetPoint("TOPLEFT", GarrisonMissionFrame.MissionTab.MissionPage, "TOPLEFT", 0, 4)
	GarrisonMissionFrame.MissionTab.MissionPage.Panel:SetPoint("BOTTOMRIGHT", GarrisonMissionFrame.MissionTab.MissionPage, "BOTTOMRIGHT", 0, -20)

	GarrisonMissionFrame.MissionTab.MissionPage.Stage:RemoveTextures()
	StyleTextureIcon(GarrisonMissionFrame.MissionTab.MissionPage.Stage.MissionEnvIcon);
	AddFadeBanner(GarrisonMissionFrame.MissionTab.MissionPage.Stage)
	GarrisonMissionFrame.MissionTab.MissionPage.StartMissionButton:RemoveTextures(true)
	GarrisonMissionFrame.MissionTab.MissionPage.StartMissionButton:SetStyle("Button")

	GarrisonMissionFrameFollowers:RemoveTextures()
	GarrisonMissionFrameFollowers:SetStyle("Frame", 'Inset', false, 4, 0, 0)
	GarrisonMissionFrameFollowers.MaterialFrame:RemoveTextures()
	GarrisonMissionFrameFollowers.MaterialFrame:SetStyle("Frame", "Inset", true, 1, -5, -7)

	StyleMissionComplete(GarrisonMissionFrame)

	local a1, p, a2, x, y = GarrisonMissionFrameMissionsTab1:GetPoint()
	GarrisonMissionFrameMissionsTab1:SetPoint(a1, p, a2, x, (y + 8))
	SV.API:Set("Tab", GarrisonMissionFrameTab1)
	SV.API:Set("Tab", GarrisonMissionFrameTab2)
	SV.API:Set("Tab", GarrisonMissionFrameMissionsTab1, nil, 10, 4)
	SV.API:Set("Tab", GarrisonMissionFrameMissionsTab2, nil, 10, 4)
	SV.API:Set("ScrollBar", GarrisonMissionFrameMissionsListScrollFrame)
	SV.API:Set("ScrollBar", GarrisonMissionFrameFollowersListScrollFrame)
	SV.API:Set("Skin", GarrisonMissionFrame.FollowerTab)
	SV.API:Set("EditBox", GarrisonMissionFrameFollowers.SearchBox)
	SV.API:Set("CloseButton", GarrisonMissionFrame.CloseButton)
	SV.API:Set("CloseButton", GarrisonMissionFrame.MissionTab.MissionPage.CloseButton)
	--SV.API:Set("Button", GarrisonMissionFrame.MissionTab.MissionPage.MinimizeButton)

	_hook_GarrisonMissionList_Update()
	--hooksecurefunc("GarrisonMissionList_Update", _hook_GarrisonMissionList_Update)
	hooksecurefunc("GarrisonMissionFrame_SetItemRewardDetails", _hook_GarrisonMissionFrame_SetItemRewardDetails)
 	--hooksecurefunc("GarrisonMissionFrame_SetFollowerPortrait", _hook_GarrisonMissionFrame_SetFollowerPortrait)
  	hooksecurefunc(GarrisonFollowerMissionComplete, "SetFollowerLevel", _hook_GarrisonMissionComplete_SetFollowerLevel)
  	--hooksecurefunc(GarrisonMission, "UpdateMissionParty", _hook_GarrisonFollowerPage_UpdateMissionForParty)
	hooksecurefunc("GarrisonMissionButton_SetRewards", _hook_GarrisonMissionButton_SetRewards)
  	--hooksecurefunc("GarrisonMissionFrame_CheckRewardButtons", _hook_GarrisonMissionFrame_CheckRewardButtons)
	--[[
	##############################################################################
	CAPACITIVE DISPLAY
	##############################################################################
	--]]
	SV.API:Set("Window", GarrisonCapacitiveDisplayFrame, true, false, 1, 0, 4)

	--GarrisonCapacitiveDisplayFrame:RemoveTextures(true)
	--GarrisonCapacitiveDisplayFrame:SetStyle("Frame", "Window2")
	GarrisonCapacitiveDisplayFrameInset:RemoveTextures(true)
	GarrisonCapacitiveDisplayFrame.CapacitiveDisplay:RemoveTextures(true)
	GarrisonCapacitiveDisplayFrame.CapacitiveDisplay:SetStyle("Frame", 'Transparent')
	GarrisonCapacitiveDisplayFrame.CapacitiveDisplay.ShipmentIconFrame:SetStyle("Icon")
	GarrisonCapacitiveDisplayFrame.CapacitiveDisplay.ShipmentIconFrame.Icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))

	local reagents = GarrisonCapacitiveDisplayFrame.CapacitiveDisplay.Reagents;
  for i = 1, #reagents do
  	if(reagents[i]) then
  		reagents[i]:RemoveTextures()
      reagents[i]:SetStyle("Icon")
      if(reagents[i].Icon) then
				reagents[i].Icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
			end
		end
  end

	if(GarrisonCapacitiveDisplayFrame.StartWorkOrderButton) then
		GarrisonCapacitiveDisplayFrame.StartWorkOrderButton:RemoveTextures(true)
		GarrisonCapacitiveDisplayFrame.StartWorkOrderButton:SetStyle("Button")
	end

	if(GarrisonCapacitiveDisplayFrame.CreateAllWorkOrdersButton) then
		GarrisonCapacitiveDisplayFrame.CreateAllWorkOrdersButton:RemoveTextures(true)
		GarrisonCapacitiveDisplayFrame.CreateAllWorkOrdersButton:SetStyle("Button")
		SV.API:Set("PageButton", GarrisonCapacitiveDisplayFrame.DecrementButton, false, true)
		SV.API:Set("EditBox", GarrisonCapacitiveDisplayFrame.Count)
		SV.API:Set("PageButton", GarrisonCapacitiveDisplayFrame.IncrementButton)
	end
	GarrisonCapacitiveDisplayFrame.CapacitiveDisplay.FollowerActive:ClearAllPoints()
	GarrisonCapacitiveDisplayFrame.CapacitiveDisplay.FollowerActive:SetPoint("TOP", GarrisonCapacitiveDisplayFrame, "TOP", 0, -32)
	hooksecurefunc("GarrisonCapacitiveDisplayFrame_Update", _hook_GarrisonCapacitiveDisplayFrame_Update)
	SV.NPC:Register(GarrisonCapacitiveDisplayFrame, GarrisonCapacitiveDisplayFrameTitleText)
	GarrisonCapacitiveDisplayFrame.StartWorkOrderButton:HookScript('OnClick', function() SV.NPC:PlayerTalksFirst() end)
	--[[
	##############################################################################
	RECRUITER FRAME
	##############################################################################
	--]]
	SV.API:Set("Window", GarrisonRecruiterFrame, true)
	SV.API:Set("Window", GarrisonRecruitSelectFrame, true)

	GarrisonRecruiterFrameInset:RemoveTextures()
	GarrisonRecruiterFrameInset:SetStyle("!_Frame", "Inset")
	GarrisonRecruiterFrame.Pick.Radio1:SetStyle("!_CheckButton", false, -3, -3, true)
	GarrisonRecruiterFrame.Pick.Radio2:SetStyle("!_CheckButton", false, -3, -3, true)
	GarrisonRecruiterFrame.PortraitTexture:Die()

	GarrisonRecruitSelectFrame.FollowerSelection:RemoveTextures()
	GarrisonRecruitSelectFrame.FollowerList:RemoveTextures()
	GarrisonRecruitSelectFrame.FollowerList:SetStyle("Frame", 'Inset', false, 4, 0, 0)
	GarrisonRecruitSelectFrame.FollowerSelection.Recruit1:RemoveTextures()
	GarrisonRecruitSelectFrame.FollowerSelection.Recruit2:RemoveTextures()
	GarrisonRecruitSelectFrame.FollowerSelection.Recruit3:RemoveTextures()
	GarrisonRecruitSelectFrame.FollowerSelection.Recruit1:SetStyle("Frame", 'Inset')
	GarrisonRecruitSelectFrame.FollowerSelection.Recruit2:SetStyle("Frame", 'Inset')
	GarrisonRecruitSelectFrame.FollowerSelection.Recruit3:SetStyle("Frame", 'Inset')

	StyleFollowerPortrait(GarrisonRecruitSelectFrame.FollowerSelection.Recruit1.PortraitFrame)
	StyleFollowerPortrait(GarrisonRecruitSelectFrame.FollowerSelection.Recruit2.PortraitFrame)
	StyleFollowerPortrait(GarrisonRecruitSelectFrame.FollowerSelection.Recruit3.PortraitFrame)

	GarrisonRecruitSelectFrame.FollowerSelection.Recruit1.HireRecruits:SetStyle("Button")
	GarrisonRecruitSelectFrame.FollowerSelection.Recruit2.HireRecruits:SetStyle("Button")
	GarrisonRecruitSelectFrame.FollowerSelection.Recruit3.HireRecruits:SetStyle("Button")

	SV.API:Set("DropDown", GarrisonRecruiterFramePickThreatDropDown)
	SV.API:Set("CloseButton", GarrisonRecruiterFrame.CloseButton)
	SV.API:Set("CloseButton", GarrisonRecruitSelectFrame.CloseButton)
	SV.API:Set("Button", GarrisonRecruiterFrame.Pick.ChooseRecruits)
	SV.API:Set("Button", GarrisonRecruiterFrame.Random.ChooseRecruits)

	hooksecurefunc("GarrisonRecruitSelectFrame_UpdateRecruits", _hook_GarrisonRecruitSelectFrame_UpdateRecruits)
	--[[
	##############################################################################
	SHIPYARD FRAME
	##############################################################################
	--]]
	SV.API:Set("Window", GarrisonShipyardFrame, true)
	GarrisonShipyardFrame.BorderFrame:RemoveTextures()
	GarrisonShipyardFrame.BorderFrame.GarrCorners:RemoveTextures()
	SV.API:Set("CloseButton", GarrisonShipyardFrame.BorderFrame.CloseButton2)
	GarrisonShipyardFrame.FollowerList:RemoveTextures()
	GarrisonShipyardFrame.FollowerList:SetStyle("Frame", 'Inset', false, 4, 0, 0)
	GarrisonShipyardFrame.FollowerList.MaterialFrame:RemoveTextures()
	GarrisonShipyardFrame.FollowerList.MaterialFrame:SetStyle("Frame", "Inset", true, 1, -5, -7)
	GarrisonShipyardFrame.MissionTab:RemoveTextures()
	GarrisonShipyardFrame.MissionTab.MissionPage:RemoveTextures()
	GarrisonShipyardFrame.MissionTab.MissionPage:SetStyle("Frame", 'Paper', false, 4, 0, 0)
	GarrisonShipyardFrame.MissionTab.MissionPage.Panel:ClearAllPoints()
	GarrisonShipyardFrame.MissionTab.MissionPage.Panel:SetPoint("TOPLEFT", GarrisonShipyardFrame.MissionTab.MissionPage, "TOPLEFT", 0, 4)
	GarrisonShipyardFrame.MissionTab.MissionPage.Panel:SetPoint("BOTTOMRIGHT", GarrisonShipyardFrame.MissionTab.MissionPage, "BOTTOMRIGHT", 0, -20)

	GarrisonShipyardFrame.MissionTab.MissionList.CompleteDialog:DisableDrawLayer("BACKGROUND")
	GarrisonShipyardFrame.MissionTab.MissionList.CompleteDialog.BorderFrame:RemoveTextures()
	GarrisonShipyardFrame.MissionTab.MissionList.CompleteDialog.BorderFrame:SetStyle("Frame", 'Window', false, 4, 0, 0)
	GarrisonShipyardFrame.MissionTab.MissionList.CompleteDialog.BorderFrame.Stage:RemoveTextures()
	GarrisonShipyardFrame.MissionTab.MissionList.CompleteDialog.BorderFrame.Stage:SetStyle("!_Frame", "Model")
	GarrisonShipyardFrame.MissionTab.MissionList.CompleteDialog.BorderFrame.ViewButton:RemoveTextures(true)
	GarrisonShipyardFrame.MissionTab.MissionList.CompleteDialog.BorderFrame.ViewButton:SetStyle("Button")

	SV.API:Set("CloseButton", GarrisonShipyardFrame.MissionTab.MissionPage.CloseButton)
	GarrisonShipyardFrame.MissionTab.MissionPage.StartMissionButton:RemoveTextures(true)
	GarrisonShipyardFrame.MissionTab.MissionPage.StartMissionButton:SetStyle("Button")

	GarrisonShipyardFrame.MissionTab.MissionList:SetStyle("Frame", 'Paper', false, 4, 0, 0)
	GarrisonShipyardFrame.FollowerTab:RemoveTextures()

	SV.API:Set("ScrollBar", GarrisonShipyardFrameFollowersListScrollFrame)
	SV.API:Set("Skin", GarrisonShipyardFrame.FollowerTab, 12, 0, -2, 30)
	SV.API:Set("EditBox", GarrisonShipyardFrameFollowers.SearchBox)

	StyleMissionComplete(GarrisonShipyardFrame)
	SV.API:Set("Tab",GarrisonShipyardFrameTab1)
	SV.API:Set("Tab",GarrisonShipyardFrameTab2)
	--[[
	##############################################################################
	FOLLOWER HOOKS
	##############################################################################
	--]]
	--hooksecurefunc("GarrisonFollowerList_Update", _hook_GarrisonFollowerList_Update)
	--hooksecurefunc("GarrisonFollowerPage_ShowFollower", _hook_GarrisonFollowerPage_ShowFollower)
	--hooksecurefunc("GarrisonFollowerButton_AddAbility", _hook_GarrisonFollowerButton_AddAbility)
  	--hooksecurefunc("GarrisonFollowerButton_SetCounterButton", _hook_GarrisonFollowerButton_SetCounterButton)
	--hooksecurefunc("GarrisonFollowerTooltipTemplate_SetGarrisonFollower", _hook_GarrisonFollowerTooltipTemplate_SetGarrisonFollower)
	--print('GARRISON DONE')
end
--[[
##########################################################
MOD LOADING
##########################################################
]]--
MOD:SaveBlizzardStyle("Blizzard_GarrisonUI", LoadGarrisonStyle)
