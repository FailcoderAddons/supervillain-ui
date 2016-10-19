--[[
##########################################################
S V U I   By: Failcoder
##########################################################
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local unpack 	= _G.unpack;
local select 	= _G.select;
local pairs 	= _G.pairs;
local string 	= _G.string;
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
VEM
##########################################################
]]--
local RaidNotice_AddMessage_ = RaidNotice_AddMessage
local NewHook = hooksecurefunc

local function StyleBars(self)
	for bar in self:GetBarIterator() do
		if not bar.injected then
			bar.ApplyStyle = function()
				local frame = bar.frame
				local tbar = _G[frame:GetName()..'Bar']
				local spark = _G[frame:GetName()..'BarSpark']
				local texture = _G[frame:GetName()..'BarTexture']
				local icon1 = _G[frame:GetName()..'BarIcon1']
				local icon2 = _G[frame:GetName()..'BarIcon2']
				local name = _G[frame:GetName()..'BarName']
				local timer = _G[frame:GetName()..'BarTimer']

				if not icon1.overlay then
					icon1.overlay = CreateFrame('Frame', '$parentIcon1Overlay', tbar)
					icon1.overlay:SetStyle("!_Frame")
					icon1.overlay:SetFrameLevel(0)
					icon1.overlay:SetSize(22, 22)
					icon1.overlay:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMLEFT', -2, 0)
				end
				if not icon2.overlay then
					icon2.overlay = CreateFrame('Frame', '$parentIcon2Overlay', tbar)
					icon2.overlay:SetStyle("!_Frame")
					icon2.overlay:SetFrameLevel(0)
					icon2.overlay:SetSize(22, 22)
					icon2.overlay:SetPoint('BOTTOMLEFT', frame, 'BOTTOMRIGHT', 2, 0)
				end

				if bar.color then
					tbar:SetStatusBarColor(bar.color.r, bar.color.g, bar.color.b)
				else
					tbar:SetStatusBarColor(bar.owner.options.StartColorR, bar.owner.options.StartColorG, bar.owner.options.StartColorB)
				end

				if bar.enlarged then
					frame:SetWidth(bar.owner.options.HugeWidth)
					tbar:SetWidth(bar.owner.options.HugeWidth)
					frame:SetScale(bar.owner.options.HugeScale)
				else
					frame:SetWidth(bar.owner.options.Width)
					tbar:SetWidth(bar.owner.options.Width)
					frame:SetScale(bar.owner.options.Scale)
				end

				spark:SetAlpha(0)
				spark:SetTexture("")

				icon1:SetTexCoord(0.1,0.9,0.1,0.9)
				icon1:ClearAllPoints()
				icon1:InsetPoints(icon1.overlay)

				icon2:SetTexCoord(0.1,0.9,0.1,0.9)
				icon2:ClearAllPoints()
				icon2:InsetPoints(icon2.overlay)

				texture:SetTexture(SV.media.statusbar.default)
				tbar:InsetPoints(frame)

				frame:SetStyle("!_Frame")

				name:ClearAllPoints()
				name:SetWidth(165)
				name:SetHeight(8)
				name:SetJustifyH('LEFT')
				name:SetShadowColor(0, 0, 0, 0)
				timer:ClearAllPoints()
				timer:SetJustifyH('RIGHT')
				timer:SetShadowColor(0, 0, 0, 0)

				frame:SetHeight(22)
				name:SetPoint('LEFT', frame, 'LEFT', 4, 0)
				timer:SetPoint('RIGHT', frame, 'RIGHT', -4, 0)

				name:SetFont(SV.media.font.dialog, 12, 'OUTLINE')
				timer:SetFont(SV.media.font.dialog, 12, 'OUTLINE')

				name:SetTextColor(bar.owner.options.TextColorR, bar.owner.options.TextColorG, bar.owner.options.TextColorB)
				timer:SetTextColor(bar.owner.options.TextColorR, bar.owner.options.TextColorG, bar.owner.options.TextColorB)

				if bar.owner.options.IconLeft then icon1:Show() icon1.overlay:Show() else icon1:Hide() icon1.overlay:Hide() end
				if bar.owner.options.IconRight then icon2:Show() icon2.overlay:Show() else icon2:Hide() icon2.overlay:Hide() end

				tbar:SetAlpha(1)
				frame:SetAlpha(1)
				texture:SetAlpha(1)
				frame:Show()
				bar:Update(0)
				bar.injected = true
			end
			bar:ApplyStyle()
		end
	end
end

local StyleBossTitle = function()
	local anchor = VEMBossHealthDropdown:GetParent()
	if not anchor.styled then
		local header = {anchor:GetRegions()}
		if header[1]:IsObjectType('FontString') then
			header[1]:SetFont(SV.media.font.dialog, 12, 'OUTLINE')
			header[1]:SetTextColor(1, 1, 1)
			header[1]:SetShadowColor(0, 0, 0, 0)
			anchor.styled = true
		end
		header = nil
	end
	anchor = nil
end

local StyleBoss = function()
	local count = 1
	while _G[format('VEM_BossHealth_Bar_%d', count)] do
		local bar = _G[format('VEM_BossHealth_Bar_%d', count)]
		local background = _G[bar:GetName()..'BarBorder']
		local progress = _G[bar:GetName()..'Bar']
		local name = _G[bar:GetName()..'BarName']
		local timer = _G[bar:GetName()..'BarTimer']
		local prev = _G[format('VEM_BossHealth_Bar_%d', count-1)]
		local _, anch, _ ,_, _ = bar:GetPoint()
		bar:ClearAllPoints()
		if count == 1 then
			if VEM_SavedOptions.HealthFrameGrowUp then
				bar:SetPoint('BOTTOM', anch, 'TOP' , 0 , 12)
			else
				bar:SetPoint('TOP', anch, 'BOTTOM' , 0, -22)
			end
		else
			if VEM_SavedOptions.HealthFrameGrowUp then
				bar:SetPoint('TOPLEFT', prev, 'TOPLEFT', 0, 26)
			else
				bar:SetPoint('TOPLEFT', prev, 'TOPLEFT', 0, -26)
			end
		end
		bar:SetStyle("!_Frame", 'Transparent')
		background:SetNormalTexture(nil)
		progress:SetStatusBarTexture(SV.media.statusbar.default)
		progress:ClearAllPoints()
		progress:InsetPoints(bar)
		name:ClearAllPoints()
		name:SetJustifyH('LEFT')
		name:SetShadowColor(0, 0, 0, 0)
		timer:ClearAllPoints()
		timer:SetJustifyH('RIGHT')
		timer:SetShadowColor(0, 0, 0, 0)

		bar:SetHeight(22)
		name:SetPoint('LEFT', bar, 'LEFT', 4, 0)
		timer:SetPoint('RIGHT', bar, 'RIGHT', -4, 0)

		name:SetFont(SV.media.font.dialog, 12, 'OUTLINE')
		timer:SetFont(SV.media.font.dialog, 12, 'OUTLINE')
		count = count + 1
	end
end

local _hook_OnShow = function(self)
	if(not self.Panel) then
		self:SetStyle("!_Frame", 'Transparent')
	end
end

local function StyleVEM(event, addon)
	assert(VEM, "AddOn Not Loaded")

	if event == 'PLAYER_ENTERING_WORLD' then
		NewHook(DBT, 'CreateBar', StyleBars)
		NewHook(VEM.BossHealth, 'Show', StyleBossTitle)
		NewHook(VEM.BossHealth, 'AddBoss', StyleBoss)
		NewHook(VEM.BossHealth, 'UpdateSettings', StyleBoss)

		if not VEM_SavedOptions['DontShowRangeFrame'] then
			VEM.RangeCheck:Show()
			VEM.RangeCheck:Hide()
			VEMRangeCheck:HookScript('OnShow', _hook_OnShow)
			VEMRangeCheckRadar:SetStyle("!_Frame", 'Transparent')
		end

		if not VEM_SavedOptions['DontShowInfoFrame'] then
			VEM.InfoFrame:Show(5, 'test')
			VEM.InfoFrame:Hide()
			VEMInfoFrame:HookScript('OnShow', _hook_OnShow)
		end

		RaidNotice_AddMessage = function(noticeFrame, textString, colorInfo)
			if textString:find(' |T') then
				textString = gsub(textString,'(:12:12)',':18:18:0:0:64:64:5:59:5:59')
			end
			return RaidNotice_AddMessage_(noticeFrame, textString, colorInfo)
		end
	end

	if addon == 'VEM-GUI' then
		VEM_GUI_OptionsFrame:HookScript('OnShow', function()
			SV.API:Set("Frame", VEM_GUI_OptionsFrame)
			SV.API:Set("Frame", VEM_GUI_OptionsFrameBossMods)
			SV.API:Set("Frame", VEM_GUI_OptionsFrameVEMOptions)
			SV.API:Set("Frame", VEM_GUI_OptionsFramePanelContainer, 'Transparent', true)
		end)
		SV.API:Set("Tab", VEM_GUI_OptionsFrameTab1)
		SV.API:Set("Tab", VEM_GUI_OptionsFrameTab2)
		VEM_GUI_OptionsFrameOkay:SetStyle("Button")
		VEM_GUI_OptionsFrameWebsiteButton:SetStyle("Button")
		SV.API:Set("ScrollBar", VEM_GUI_OptionsFramePanelContainerFOVScrollBar)
		MOD:SafeEventRemoval("VEM", event)
	end
end
MOD:SaveAddonStyle("VEM", StyleVEM, nil, true)
