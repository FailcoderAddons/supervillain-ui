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
OVERRIDES AND HOOKS
##########################################################
]]--
local RING_TEXTURE = [[Interface\AddOns\SVUI_Skins\artwork\FOLLOWER-RING]]
local LVL_TEXTURE = [[Interface\AddOns\SVUI_Skins\artwork\FOLLOWER-LEVEL]]

local AlphaBlock = function() return end

local _hook_DisableBackground = function(self)
    self:DisableDrawLayer("BACKGROUND")
end;

local _hook_DisableBorder = function(self)
    self:DisableDrawLayer("BORDER")
end;

local _hook_DisableBoth = function(self)
	self:DisableDrawLayer("BACKGROUND")
    self:DisableDrawLayer("BORDER")
end;

local _hook_DisableOverlay = function(self)
    self:DisableDrawLayer("OVERLAY")
end;

local _hook_BackdropColor = function(self,...)
    if(self.AlertPanel) then
        self.AlertPanel:AlertColor(...)
    end
end
--[[
##########################################################
HELPERS
##########################################################
]]--
local function StyleAlertIcon(frame, icon)
	if((not frame) or (not icon)) then return end

	icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
	icon:SetDrawLayer("BORDER")

	if(not frame.IconSlot) then
		frame.IconSlot = CreateFrame("Frame", nil, frame)
		frame.IconSlot:WrapPoints(icon)
		frame.IconSlot:SetStyle("Icon")
		icon:SetParent(frame.IconSlot)
	end
end
--/script LOOT_WON_ALERT_FRAMES[1]:Show()
local function StyleLootFrame(frame)
	if(not frame) then return end

	if(not frame.Panel) then
		SV.API:Set("!_Alert", frame)
    if(frame.PvPBackground) then frame.PvPBackground:Die() end
		if(frame.Background) then frame.Background:Die() end
		if(frame.BGAtlas) then frame.BGAtlas:Die() end
		if(frame.IconBorder) then frame.IconBorder:Die() end
		if(frame.SpecIcon) then frame.SpecIcon:Die() end
		if(frame.SpecRing) then frame.SpecRing:Die() end
	end

	if(frame.Icon and (not frame.IconSlot)) then
		StyleAlertIcon(frame, frame.Icon)
		frame.Icon:ClearAllPoints()
		frame.Icon:SetPoint("CENTER", frame.AlertPanel.icon, "CENTER", 0, 0)
	end

	if(frame.Label) then
		frame.Label:ClearAllPoints()
		frame.Label:SetPoint("TOPLEFT", frame.Icon, "TOPRIGHT", 57, 5)
	end
	if(frame.ItemName) then
		frame.ItemName:ClearAllPoints()
		frame.ItemName:SetPoint("TOPLEFT", frame.Icon, "TOPRIGHT", 60, -16)
	end
	if(frame.Amount) then
		frame.Amount:ClearAllPoints()
		frame.Amount:SetPoint("TOPLEFT", frame.Icon, "TOPRIGHT", 60, -16)
	end
end

local function StyleUpgradeFrame(frame)
	if(not frame) then return end

	if(not frame.Panel) then
		SV.API:Set("!_Alert", frame)

		frame.Background:Die()
		frame.BorderGlow:Die()
		frame.BaseQualityBorder:Die()
		frame.UpgradeQualityBorder:Die()

		frame:DisableDrawLayer("OVERLAY")
		frame:HookScript("OnShow", _hook_DisableOverlay)
	end

	if(frame.Icon and (not frame.IconSlot)) then
		frame.Icon:ClearAllPoints()
		frame.Icon:SetPoint("CENTER", frame.AlertPanel.icon, "CENTER", 0, 0)
		StyleAlertIcon(frame, frame.Icon)
	end
end
--[[
local function AchievementStyle()
	for i = 1, MAX_ACHIEVEMENT_ALERTS do
		local frameName = "AchievementAlertFrame"..i
		local frame = _G[frameName]
		if(frame and (not frame.Panel)) then

			SV.API:Set("!_Alert", frame)

			local icon = _G[frameName.."IconTexture"];
			icon:ClearAllPoints()
			icon:SetPoint("CENTER", frame.AlertPanel.icon, "CENTER", 0, 0)

			_G[frameName.."Unlocked"]:SetTextColor(1, 1, 1);
			_G[frameName.."Name"]:SetTextColor(1, 1, 0);

			StyleAlertIcon(frame, icon)

			if(_G[frameName .. 'Glow']) then _G[frameName .. 'Glow']:Die() end
			if(_G[frameName .. 'Shine']) then _G[frameName .. 'Shine']:Die() end
			if(_G[frameName .. 'Background']) then _G[frameName .. 'Background']:SetTexture("") end
			if(_G[frameName .. 'IconOverlay']) then _G[frameName .. 'IconOverlay']:Die() end
			if(_G[frameName .. 'GuildBanner']) then _G[frameName .. 'GuildBanner']:Die() end
			if(_G[frameName .. 'GuildBorder']) then _G[frameName .. 'GuildBorder']:Die() end
			if(_G[frameName .. 'OldAchievement']) then _G[frameName .. 'OldAchievement']:Die() end
		end
	end
end

local function CriteriaStyle()
	for i = 1, MAX_ACHIEVEMENT_ALERTS do
		local frameName = "CriteriaAlertFrame"..i
		local frame = _G[frameName]
		if(frame and (not frame.Panel)) then

			SV.API:Set("!_Alert", frame)

			local icon = _G[frameName .. 'IconTexture'];
			if(icon) then
				icon:ClearAllPoints()
				icon:SetPoint("CENTER", frame.AlertPanel.icon, "CENTER", 0, 0)
				StyleAlertIcon(frame, icon)
			end

			if(_G[frameName .. 'Glow']) then _G[frameName .. 'Glow']:Die() end
			if(_G[frameName .. 'Shine']) then _G[frameName .. 'Shine']:Die() end
			if(_G[frameName .. 'Background']) then _G[frameName .. 'Background']:SetTexture("") end
			if(_G[frameName .. 'IconOverlay']) then _G[frameName .. 'IconOverlay']:Die() end
			if(_G[frameName .. 'IconBling']) then _G[frameName .. 'IconBling']:Die() end
		end
	end
end
]]--
local function DungeonCompletionStyle()
	local frameName = "DungeonCompletionAlertFrame1"
	local frame = _G[frameName]
	if(frame and (not frame.Panel)) then

		SV.API:Set("!_Alert", frame)

		local icon = frame.dungeonTexture;
		if(icon) then
			icon:SetDrawLayer("OVERLAY")
			icon:ClearAllPoints()
			icon:SetPoint("CENTER", frame.AlertPanel.icon, "CENTER", 0, 0)
			StyleAlertIcon(frame, icon)
		end

		if(_G[frameName .. 'GlowFrame']) then
			if(_G[frameName .. 'GlowFrame'].glow) then _G[frameName .. 'GlowFrame'].glow:Die() end
			_G[frameName .. 'GlowFrame']:Die()
		end
		if(_G[frameName .. 'Shine']) then _G[frameName .. 'Shine']:Die() end

		frame:DisableDrawLayer("BORDER")
		frame:HookScript("OnShow", _hook_DisableBorder)
	end
end

local function GuildChallengeStyle()
    local frameName = "GuildChallengeAlertFrame"
	local frame = _G[frameName];
	if(frame and (not frame.Panel)) then

		SV.API:Set("!_Alert", frame)

		local icon = _G[frameName .. 'EmblemIcon'];
		if(icon) then
			icon:ClearAllPoints()
			icon:SetPoint("CENTER", frame.AlertPanel.icon, "CENTER", 0, 0)
			StyleAlertIcon(frame, icon)
			SetLargeGuildTabardTextures("player", icon, nil, nil)
		end

		if(_G[frameName .. 'Glow']) then _G[frameName .. 'Glow']:Die() end
		if(_G[frameName .. 'Shine']) then _G[frameName .. 'Shine']:Die() end

		frame:DisableDrawLayer("BACKGROUND")
		frame:DisableDrawLayer("BORDER")
		frame:HookScript("OnShow", _hook_DisableBoth)
	end
end

local function ChallengeModeStyle()
	local frameName = "ChallengeModeAlertFrame1"
	local frame = _G[frameName];
	if(frame and (not frame.Panel)) then

		SV.API:Set("!_Alert", frame)

		local icon = _G[frameName .. 'DungeonTexture'];
		if(icon) then
			icon:ClearAllPoints()
			icon:SetPoint("CENTER", frame.AlertPanel.icon, "CENTER", 0, 0)
			StyleAlertIcon(frame, icon)
		end

		if(_G[frameName .. 'GlowFrame']) then
			if(_G[frameName .. 'GlowFrame'].glow) then _G[frameName .. 'GlowFrame'].glow:Die() end
			_G[frameName .. 'GlowFrame']:Die()
		end
		if(_G[frameName .. 'Shine']) then _G[frameName .. 'Shine']:Die() end
		if(_G[frameName .. 'Border']) then _G[frameName .. 'Border']:Die() end

		frame:DisableDrawLayer("BACKGROUND")
		frame:HookScript("OnShow", _hook_DisableBackground)
	end
end

local function ScenarioStyle()
	local frameName = "ScenarioAlertFrame1"
	local frame = _G[frameName];
	if(frame and (not frame.Panel)) then

		SV.API:Set("!_Alert", frame)

		local icon = _G[frameName .. 'DungeonTexture'];
		if(icon) then
			icon:ClearAllPoints()
			icon:SetPoint("CENTER", frame.AlertPanel.icon, "CENTER", 0, 0)
			StyleAlertIcon(frame, icon)
		end

		if(_G[frameName .. 'GlowFrame']) then
			if(_G[frameName .. 'GlowFrame'].glow) then _G[frameName .. 'GlowFrame'].glow:Die() end
			_G[frameName .. 'GlowFrame']:Die()
		end
		if(_G[frameName .. 'Shine']) then _G[frameName .. 'Shine']:Die() end

		frame:DisableDrawLayer("BORDER")
		frame:HookScript("OnShow", _hook_DisableBorder)
	end
end

-- [[ GarrisonMissionAlertFrame ]] --
local function GarrisonAlertPositioning(frame, missionID)
	if (frame.MissionType and frame.AlertPanel and frame.AlertPanel.icon) then
		frame.MissionType:ClearAllPoints()
		frame.MissionType:SetPoint("CENTER", frame.AlertPanel.icon, "CENTER", 0, 0)
	end
end

-- [[ GarrisonFollowerAlertFrame ]] --
local function GarrisonFollowerAlertStyle(followerID, name, displayID, level, quality, isUpgraded)
	local color = BAG_ITEM_QUALITY_COLORS[quality];
	if (color) then
		GarrisonFollowerAlertFrame.PortraitFrame.LevelBorder:SetVertexColor(color.r, color.g, color.b);
		GarrisonFollowerAlertFrame.PortraitFrame.PortraitRing:SetVertexColor(color.r, color.g, color.b);
	else
		GarrisonFollowerAlertFrame.PortraitFrame.LevelBorder:SetVertexColor(1, 1, 1);
		GarrisonFollowerAlertFrame.PortraitFrame.PortraitRing:SetVertexColor(1, 1, 1);
	end
end
--[[
##########################################################
ALERTFRAME STYLES
##########################################################
]]--
local function AlertStyle()
	--print('test AlertStyle')
	if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.alertframes ~= true then return end

	--[[ SVUI ]]--
	for i = 1, 4 do
		local frame = _G["SVUI_SystemAlert"..i];
		if(frame) then
			frame:RemoveTextures()

			SV.API:Set("Alert", frame)

			frame.buttons[1]:SetStyle("Button")
			frame.buttons[2]:SetStyle("Button")
			frame.buttons[3]:SetStyle("Button")

			frame.gold:SetStyle("Editbox")
			frame.silver:SetStyle("Editbox")
			frame.copper:SetStyle("Editbox")

			frame.input:SetStyle("Editbox")
			frame.input.Panel:SetPoint("TOPLEFT", -2, -4)
			frame.input.Panel:SetPoint("BOTTOMRIGHT", 2, 4)
		end
	end

	--[[
	do
		for i = 1, #LOOT_WON_ALERT_FRAMES do
			StyleLootFrame(LOOT_WON_ALERT_FRAMES[i])
		end
		StyleLootFrame(BonusRollLootWonFrame)
		hooksecurefunc("AlertFrame_SetLootWonAnchors", function()
			for i = 1, #LOOT_WON_ALERT_FRAMES do
				local frame = LOOT_WON_ALERT_FRAMES[i]
				if(frame) then StyleLootFrame(frame) end
			end
		end)
		hooksecurefunc("LootWonAlertFrame_SetUp", function(self, itemLink, ...)
		    local itemName, itemHyperLink, itemRarity, itemTexture, _;
		    if (self.isCurrency) then
		        itemName, _, itemTexture, _, _, _, _, itemRarity = GetCurrencyInfo(itemLink);
		        itemHyperLink = itemLink;
		    else
		        itemName, itemHyperLink, itemRarity, _, _, _, _, _, _, itemTexture = GetItemInfo(itemLink);
		    end
	    	if(itemRarity) then
		    	local color = ITEM_QUALITY_COLORS[itemRarity];
		    	if(not self.IconSlot) then return end;
				self.IconSlot:SetBackdropColor(color.r, color.g, color.b);
				self:AlertColor(color.r, color.g, color.b)
			end
		end)
	end

	do
		for i = 1, #MONEY_WON_ALERT_FRAMES do
			StyleLootFrame(MONEY_WON_ALERT_FRAMES[i])
		end
		StyleLootFrame(BonusRollMoneyWonFrame)
		hooksecurefunc("AlertFrame_SetMoneyWonAnchors", function()
			for i = 1, #MONEY_WON_ALERT_FRAMES do
				local frame = MONEY_WON_ALERT_FRAMES[i]
				if(frame) then StyleLootFrame(frame) end
			end
		end)
	end

	do
		for i = 1, #LOOT_UPGRADE_ALERT_FRAMES do
			StyleUpgradeFrame(LOOT_UPGRADE_ALERT_FRAMES[i])
		end
		hooksecurefunc("AlertFrame_SetLootUpgradeFrameAnchors", function()
			for i = 1, #LOOT_UPGRADE_ALERT_FRAMES do
				local frame = LOOT_UPGRADE_ALERT_FRAMES[i]
				if(frame) then StyleUpgradeFrame(frame) end
			end
		end)
		hooksecurefunc("LootUpgradeFrame_SetUp", function(self, itemLink, ...)
		    local itemName, itemHyperLink, itemRarity, _, _, _, _, _, _, itemTexture = GetItemInfo(itemLink);
		    if(itemRarity) then
		    	local color = ITEM_QUALITY_COLORS[itemRarity];
		    	if(not self.IconSlot) then return end;
				self.IconSlot:SetBackdropColor(color.r, color.g, color.b);
				self:AlertColor(color.r, color.g, color.b)
			end
		end)
	end

	AchievementStyle()
	hooksecurefunc("AlertFrame_SetAchievementAnchors", AchievementStyle)

	CriteriaStyle()
	hooksecurefunc("AlertFrame_SetCriteriaAnchors", CriteriaStyle)

	DungeonCompletionStyle()
	hooksecurefunc("AlertFrame_SetDungeonCompletionAnchors", DungeonCompletionStyle)

	GuildChallengeStyle()
	hooksecurefunc("AlertFrame_SetGuildChallengeAnchors", GuildChallengeStyle)

	ChallengeModeStyle()
	hooksecurefunc("AlertFrame_SetChallengeModeAnchors", ChallengeModeStyle)
	
	ScenarioStyle()
	hooksecurefunc("AlertFrame_SetScenarioAnchors", ScenarioStyle)
	]]--


	--[[ GARRISON ]]--
	do
		local frameName, frame;

		--Garrison Mission
	    frameName = "GarrisonMissionAlertFrame"
	    frame = _G[frameName]
	    if(frame and (not frame.Panel)) then
			frame:DisableDrawLayer("BACKGROUND")

			SV.API:Set("!_Alert", frame)
			frame.IconBG:ClearAllPoints()
			frame.IconBG:SetPoint("CENTER", frame.AlertPanel.icon, "CENTER", 0, 0)
			frame.IconBG:SetTexture('')
			frame.IconBG:SetDrawLayer("BORDER")
			frame.MissionType:ClearAllPoints()
			frame.MissionType:SetPoint("CENTER", frame.AlertPanel.icon, "CENTER", 0, 0)
			frame.Title:SetTextColor(1, 1, 1)

			if(_G[frameName .. 'Glow']) then _G[frameName .. 'Glow']:Die() end
			if(_G[frameName .. 'Shine']) then _G[frameName .. 'Shine']:Die() end

			frame:HookScript("OnShow", _hook_DisableBackground)

		end

		--Garrison Shipyard Mission
	    frameName = "GarrisonShipMissionAlertFrame"
	    frame = _G[frameName]
	    if(frame and (not frame.Panel)) then
			frame:DisableDrawLayer("BACKGROUND")

			SV.API:Set("!_Alert", frame)
			frame.MissionType:ClearAllPoints()
			frame.MissionType:SetPoint("CENTER", frame.AlertPanel.icon, "CENTER", 0, 0)
			frame.Title:SetTextColor(1, 1, 1)

			if(_G[frameName .. 'Glow']) then _G[frameName .. 'Glow']:Die() end
			if(_G[frameName .. 'Shine']) then _G[frameName .. 'Shine']:Die() end

			frame:HookScript("OnShow", _hook_DisableBackground)
		end

		--Garrison Building
		frameName = "GarrisonBuildingAlertFrame"
	    frame = _G[frameName]
	    if(frame and (not frame.Panel)) then
			frame:DisableDrawLayer("BACKGROUND")

			SV.API:Set("!_Alert", frame)
			frame.Icon:ClearAllPoints()
			frame.Icon:SetPoint("CENTER", frame.AlertPanel.icon, "CENTER", 0, 0)
			frame.Icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
			frame.Icon:SetDrawLayer("BORDER")
			frame.Title:SetTextColor(1, 1, 1)

			if(_G[frameName .. 'Glow']) then _G[frameName .. 'Glow']:Die() end
			if(_G[frameName .. 'Shine']) then _G[frameName .. 'Shine']:Die() end

			frame:HookScript("OnShow", _hook_DisableBackground)
		end

		--Garrison Follower
		frameName = "GarrisonFollowerAlertFrame"
	    frame = _G[frameName]
	    if(frame) then
	    	if(not frame.Panel) then
				frame:DisableDrawLayer("BACKGROUND")

				SV.API:Set("!_Alert", frame)
				frame.Title:SetTextColor(1, 1, 1)

				if(_G[frameName .. 'Glow']) then _G[frameName .. 'Glow']:Die() end
				if(_G[frameName .. 'Shine']) then _G[frameName .. 'Shine']:Die() end

				frame:HookScript("OnShow", _hook_DisableBackground)
			end

			if(frame.PortraitFrame) then
				frame.PortraitFrame.PortraitRing:SetTexture(RING_TEXTURE)
				frame.PortraitFrame.PortraitRingQuality:SetTexture('')
				frame.PortraitFrame.LevelBorder:SetTexture('')

				if(not frame.PortraitFrame.LevelCallout) then
					frame.PortraitFrame.LevelCallout = frame.PortraitFrame:CreateTexture(nil, 'BORDER')
					frame.PortraitFrame.LevelCallout:SetAllPoints(frame.PortraitFrame)
					frame.PortraitFrame.LevelCallout:SetTexture(LVL_TEXTURE)
					frame.PortraitFrame.LevelBorder:SetDrawLayer('OVERLAY')
				end

				frame.PortraitFrame:ClearAllPoints()
				frame.PortraitFrame:SetPoint("CENTER", frame.AlertPanel.icon, "CENTER", 0, 0)
			end
		end
	end
	hooksecurefunc("GarrisonMissionAlertFrame_SetUp", GarrisonAlertPositioning)
	hooksecurefunc("GarrisonFollowerAlertFrame_SetUp", GarrisonFollowerAlertStyle)
end
--[[
##########################################################
MOD LOADING
##########################################################
]]--
MOD:SaveCustomStyle("ALERTS", AlertStyle)
-- /script GarrisonMissionAlertFrame:Show()
-- /script GarrisonBuildingAlertFrame:Show()
-- /script GarrisonFollowerAlertFrame:Show()
