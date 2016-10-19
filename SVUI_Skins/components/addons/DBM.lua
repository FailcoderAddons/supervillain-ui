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
local gsub 		= string.gsub;
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
DBM
##########################################################
]]--
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
					icon1.overlay:SetSize(28,28)
					icon1.overlay:SetStyle("Frame", "Button")
					icon1.overlay:SetFrameLevel(0)
					icon1.overlay:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMLEFT', -4, 0)
				end

				if not icon2.overlay then
					icon2.overlay = CreateFrame('Frame', '$parentIcon2Overlay', tbar)
					icon2.overlay:SetSize(28,28)
					icon2.overlay:SetStyle("Frame", "Button")
					icon2.overlay:SetFrameLevel(0)
					icon2.overlay:SetPoint('BOTTOMLEFT', frame, 'BOTTOMRIGHT', 4, 0)
				end

				if bar.color then
					tbar:SetStatusBarColor(bar.color.r, bar.color.g, bar.color.b)
				else
					tbar:SetStatusBarColor(bar.owner.options.StartColorR, bar.owner.options.StartColorG, bar.owner.options.StartColorB)
				end

				local sharedWidth = bar.owner.options.Width
				local sharedScale = bar.owner.options.Scale
				if bar.enlarged then
					sharedWidth = bar.owner.options.HugeWidth
					sharedScale = bar.owner.options.HugeScale
				end

				frame:SetWidth(sharedWidth)
				frame:SetHeight(28)
				frame:SetScale(sharedScale)

				spark:SetAlpha(0)
				spark:SetTexture("")

				icon1:SetTexCoord(0.1,0.9,0.1,0.9)
				icon1:ClearAllPoints()
				icon1:SetAllPoints(icon1.overlay)

				icon2:SetTexCoord(0.1,0.9,0.1,0.9)
				icon2:ClearAllPoints()
				icon2:SetAllPoints(icon2.overlay)

				texture:SetTexture(SV.media.statusbar.default)
				tbar:SetWidth(sharedWidth)
				tbar:SetHeight(10)
				tbar:SetPoint('BOTTOMLEFT', frame, 'BOTTOMLEFT', 0, 0)
				tbar:SetStyle("Frame", "Bar")

				name:ClearAllPoints()
				name:SetHeight(8)
				name:SetWidth(sharedWidth)
				name:SetJustifyH('LEFT')
				name:SetShadowColor(0, 0, 0, 0)
				name:SetPoint('TOPLEFT', frame, 'TOPLEFT', 0, 0)
				name:SetFont(SV.media.font.default, 12, 'OUTLINE')
				name:SetTextColor(bar.owner.options.TextColorR, bar.owner.options.TextColorG, bar.owner.options.TextColorB)

				timer:ClearAllPoints()
				timer:SetJustifyH('RIGHT')
				timer:SetShadowColor(0, 0, 0, 0)
				timer:SetPoint('TOPRIGHT', frame, 'TOPRIGHT', 0, 0)
				timer:SetFont(SV.media.font.default, 12, 'OUTLINE')
				timer:SetTextColor(bar.owner.options.TextColorR, bar.owner.options.TextColorG, bar.owner.options.TextColorB)

				if bar.owner.options.IconLeft then icon1:Show() icon1.overlay:Show() else icon1:Hide() icon1.overlay:Hide() end
				if bar.owner.options.IconRight then icon2:Show() icon2.overlay:Show() else icon2:Hide() icon2.overlay:Hide() end

				bar.owner.options.BarYOffset = 8
				bar.owner.options.HugeBarYOffset = 8

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
	local anchor = DBMBossHealthDropdown:GetParent()
	if not anchor.styled then
		local header = {anchor:GetRegions()}
		if header[1]:IsObjectType('FontString') then
			header[1]:SetFontObject(SVUI_Font_Default)
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
	while _G[format('DBM_BossHealth_Bar_%d', count)] do
		local bar = _G[format('DBM_BossHealth_Bar_%d', count)]
		local background = _G[bar:GetName()..'BarBorder']
		local progress = _G[bar:GetName()..'Bar']
		local name = _G[bar:GetName()..'BarName']
		local timer = _G[bar:GetName()..'BarTimer']
		local prev = _G[format('DBM_BossHealth_Bar_%d', count-1)]	
		local _, anch, _ ,_, _ = bar:GetPoint()
		bar:ClearAllPoints()
		if count == 1 then
			if(DBM_SavedOptions and DBM_SavedOptions.HealthFrameGrowUp) then
				bar:SetPoint('BOTTOM', anch, 'TOP' , 0 , 12)
			else
				bar:SetPoint('TOP', anch, 'BOTTOM' , 0, -22)
			end
		else
			if(DBM_SavedOptions and DBM_SavedOptions.HealthFrameGrowUp) then
				bar:SetPoint('TOPLEFT', prev, 'TOPLEFT', 0, 22 + 4)
			else
				bar:SetPoint('TOPLEFT', prev, 'TOPLEFT', 0, -(22 + 4))
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
		name:SetFontObject(SpellFont_Small)
		timer:SetFontObject(SVUI_Font_Default)
		count = count + 1
	end
end

local RangeSet, InfoSet, HooksSet, NoticeSet;
local function StyleDBM(event, addon)
	assert(DBM, "AddOn Not Loaded")
	
	if(DBT and (DBM.BossHealth) and (not HooksSet)) then
		hooksecurefunc(DBT, 'CreateBar', StyleBars)
		hooksecurefunc(DBM.BossHealth, 'Show', StyleBossTitle)
		hooksecurefunc(DBM.BossHealth, 'AddBoss', StyleBoss)
		hooksecurefunc(DBM.BossHealth, 'UpdateSettings', StyleBoss)
		HooksSet = true
	end

	if((not RangeSet) and DBMRangeCheck and (not DBM_SavedOptions['DontShowRangeFrame'])) then
		DBM.RangeCheck:Show()
		DBM.RangeCheck:Hide()
		DBMRangeCheck:HookScript('OnShow', function(self) self:SetStyle("!_Frame", 'Transparent') end)
		DBMRangeCheckRadar:SetStyle("!_Frame", 'Transparent')
		RangeSet = true
	end

	if((not InfoSet) and DBMInfoFrame and (not DBM_SavedOptions['DontShowInfoFrame'])) then
		DBM.InfoFrame:Show(5, 'test')
		DBM.InfoFrame:Hide()
		DBMInfoFrame:HookScript('OnShow', function(self) self:SetStyle("!_Frame", 'Transparent') end)
		InfoSet = true
	end

	if(RaidNotice_AddMessage and (not NoticeSet)) then
		local RaidNotice_AddMessage_ = RaidNotice_AddMessage
		RaidNotice_AddMessage = function(noticeFrame, textString, colorInfo)
			if textString:find(' |T') then
				textString = gsub(textString,'(:12:12)',':18:18:0:0:64:64:5:59:5:59')
			end
			return RaidNotice_AddMessage_(noticeFrame, textString, colorInfo)
		end
		NoticeSet = true
	end

	if(RangeSet and InfoSet and HooksSet and NoticeSet) then
		MOD:SafeEventRemoval("DBM", event)
		MOD:SafeEventRemoval("DBM-GUI", event)
	end
end

MOD:SaveAddonStyle("DBM", StyleDBM, false, true)
--MOD:SaveAddonStyle("DBM-GUI", StyleDBM, false, true)