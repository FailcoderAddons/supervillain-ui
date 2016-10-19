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
local math 		= _G.math;
--[[ STRING METHODS ]]--
local find, format, split = string.find, string.format, string.split;
local gsub = string.gsub;
--[[ MATH METHODS ]]--
local ceil = math.ceil;
--[[ 
########################################################## 
GET ADDON DATA
##########################################################
]]--
local SV = _G['SVUI']
local L = SV.L;
local MOD = SV.ActionBars;
--[[ 
########################################################## 
LOCAL VARS
##########################################################
]]--
local NewFrame = CreateFrame
local NewHook = hooksecurefunc
--[[ 
########################################################## 
LOCAL FUNCTIONS
##########################################################
]]--
local function RefreshMicrobar()
	if not SVUI_MicroBar then return end 
	local lastParent = SVUI_MicroBar;
	local buttonSize =  SV.db.ActionBars.Micro.buttonsize or 30;
	local spacing =  SV.db.ActionBars.Micro.buttonspacing or 1;
	local barWidth = (buttonSize + spacing) * 13;
	SVUI_MicroBar_MOVE:SetSize(barWidth, buttonSize)
	SVUI_MicroBar:SetAllPoints(SVUI_MicroBar_MOVE)
	for i=1,13 do
		local data = MOD.media.microMenuCoords[i]
		local button = _G[data[1]]
		if(button) then
			button:ClearAllPoints()
			button:SetSize(buttonSize, buttonSize + 28)
			button._fade = SV.db.ActionBars.Micro.mouseover
			if lastParent == SVUI_MicroBar then 
				button:SetPoint("BOTTOMLEFT", lastParent, "BOTTOMLEFT", 0, 0)
			else 
				button:SetPoint("BOTTOMLEFT", lastParent, "BOTTOMRIGHT", spacing, 0)
			end 
			lastParent = button;
			button:Show()
		end
	end 
end

local SVUIMicroButton_SetNormal = function()
	local level = MainMenuMicroButton:GetFrameLevel()
	if(level > 0) then 
		MainMenuMicroButton:SetFrameLevel(level - 1)
	else 
		MainMenuMicroButton:SetFrameLevel(0)
	end
	MainMenuMicroButton:SetFrameStrata("BACKGROUND")
	MainMenuMicroButton.overlay:SetFrameLevel(level + 1)
	MainMenuMicroButton.overlay:SetFrameStrata("HIGH")
	MainMenuBarPerformanceBar:Hide()
	HelpMicroButton:Show()
end 

local SVUIMicroButtonsParent = function(self)
	if self ~= SVUI_MicroBar then 
		self = SVUI_MicroBar 
	end 
	for i=1,13 do
		local data = MOD.media.microMenuCoords[i]
		if(data) then
			local mButton = _G[data[1]]
			if(mButton) then mButton:SetParent(SVUI_MicroBar) end
		end
	end 
end 

local MicroButton_OnEnter = function(self)
	if(self._fade) then
		SVUI_MicroBar:FadeIn(0.2,SVUI_MicroBar:GetAlpha(),1)
	end
	if InCombatLockdown()then return end 
	self.overlay:SetPanelColor("highlight")
	self.overlay.icon:SetGradient("VERTICAL", 0.75, 0.75, 0.75, 1, 1, 1)
end

local MicroButton_OnLeave = function(self)
	if(self._fade) then
		SVUI_MicroBar:FadeOut(1,SVUI_MicroBar:GetAlpha(),0)
	end
	if InCombatLockdown()then return end 
	self.overlay:SetPanelColor("default")
	self.overlay.icon:SetGradient("VERTICAL", 0.5, 0.53, 0.55, 0.8, 0.8, 1)
end
--[[ 
########################################################## 
BAR CREATION
##########################################################
]]--
function MOD:UpdateMicroButtons()
	if(not SV.db.ActionBars.Micro.mouseover) then
		SVUI_MicroBar:SetAlpha(1)
	else
		SVUI_MicroBar:SetAlpha(0)
	end
	GuildMicroButtonTabard:ClearAllPoints();
	GuildMicroButtonTabard:Hide();
	RefreshMicrobar()
end

function MOD:InitializeMicroBar()
	if(not SV.db.ActionBars.Micro.enable) then return end
	local buttonSize = SV.db.ActionBars.Micro.buttonsize or 30;
	local spacing =  SV.db.ActionBars.Micro.buttonspacing or 1;
	local barWidth = (buttonSize + spacing) * 13;
	local barHeight = (buttonSize + 6);
	local microBar = NewFrame('Frame', 'SVUI_MicroBar', UIParent)
	microBar:SetSize(barWidth, barHeight)
	microBar:SetFrameStrata("HIGH")
	microBar:SetFrameLevel(0)
	microBar:SetPoint('BOTTOMLEFT', SV.Dock.TopLeft.Bar.ToolBar, 'BOTTOMRIGHT', 4, 0)
	SV:ManageVisibility(microBar)

	for i=1,13 do
		local data = MOD.media.microMenuCoords[i]
		if(data) then
			local button = _G[data[1]]
			if(button) then
				button:SetParent(SVUI_MicroBar)
				button:SetSize(buttonSize, buttonSize + 28)
				button.Flash:SetTexture("")
				if button.SetPushedTexture then 
					button:SetPushedTexture("")
				end 
				if button.SetNormalTexture then 
					button:SetNormalTexture("")
				end 
				if button.SetDisabledTexture then 
					button:SetDisabledTexture("")
				end 
				if button.SetHighlightTexture then 
					button:SetHighlightTexture("")
				end 
				button:RemoveTextures()

				local buttonMask = NewFrame("Frame",nil,button)
				buttonMask:SetPoint("TOPLEFT",button,"TOPLEFT",0,-28)
				buttonMask:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT",0,0)
				buttonMask:SetStyle("DockButton") 
				buttonMask:SetPanelColor()
				buttonMask.icon = buttonMask:CreateTexture(nil,"OVERLAY",nil,2)
				buttonMask.icon:InsetPoints(buttonMask,2,2)
				buttonMask.icon:SetTexture(MOD.media.microMenuFile)
				buttonMask.icon:SetTexCoord(data[2],data[3],data[4],data[5])
				buttonMask.icon:SetGradient("VERTICAL", 0.5, 0.53, 0.55, 0.8, 0.8, 1)
				button.overlay = buttonMask;
				button._fade = SV.db.ActionBars.Micro.mouseover
				button:HookScript('OnEnter', MicroButton_OnEnter)
				button:HookScript('OnLeave', MicroButton_OnLeave)
				button:Show()
			end
		end
	end 

	MicroButtonPortrait:ClearAllPoints()
	MicroButtonPortrait:Hide()
	MainMenuBarPerformanceBar:ClearAllPoints()
	MainMenuBarPerformanceBar:Hide()

	NewHook('MainMenuMicroButton_SetNormal', SVUIMicroButton_SetNormal)
	NewHook('UpdateMicroButtonsParent', SVUIMicroButtonsParent)
	NewHook('MoveMicroButtons', RefreshMicrobar)
	NewHook('UpdateMicroButtons', MOD.UpdateMicroButtons)

	SVUIMicroButtonsParent(microBar)
	SVUIMicroButton_SetNormal()

	SV:NewAnchor(microBar, L["Micro Bar"])

	RefreshMicrobar()
	SVUI_MicroBar:SetAlpha(0)
end