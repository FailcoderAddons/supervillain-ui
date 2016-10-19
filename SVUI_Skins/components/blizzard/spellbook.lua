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

local SV = _G["SVUI"];
local L = SV.L;
local MOD = SV.Skins;
local Schema = MOD.Schema;
--[[
##########################################################
FRAME LISTS
##########################################################
]]--
local proButtons = {
	"PrimaryProfession1SpellButtonTop",
	"PrimaryProfession1SpellButtonBottom",
	"PrimaryProfession2SpellButtonTop",
	"PrimaryProfession2SpellButtonBottom",
	"SecondaryProfession1SpellButtonLeft",
	"SecondaryProfession1SpellButtonRight",
	"SecondaryProfession2SpellButtonLeft",
	"SecondaryProfession2SpellButtonRight",
	"SecondaryProfession3SpellButtonLeft",
	"SecondaryProfession3SpellButtonRight",
	"SecondaryProfession4SpellButtonLeft",
	"SecondaryProfession4SpellButtonRight"
}

local proFrames = {
	"PrimaryProfession1",
	"PrimaryProfession2",
	"SecondaryProfession1",
	"SecondaryProfession2",
	"SecondaryProfession3",
	"SecondaryProfession4"
}
local proBars = {
	"PrimaryProfession1StatusBar",
	"PrimaryProfession2StatusBar",
	"SecondaryProfession1StatusBar",
	"SecondaryProfession2StatusBar",
	"SecondaryProfession3StatusBar",
	"SecondaryProfession4StatusBar"
}
--[[
##########################################################
HELPERS
##########################################################
]]--
local Tab_OnEnter = function(self)
	self.backdrop:SetBackdropColor(0.1, 0.8, 0.8)
	self.backdrop:SetBackdropBorderColor(0.1, 0.8, 0.8)
end

local Tab_OnLeave = function(self)
	self.backdrop:SetBackdropColor(0,0,0,1)
	self.backdrop:SetBackdropBorderColor(0,0,0,1)
end

local function ChangeTabHelper(tab)
	if(tab.backdrop) then return end

	local nTex = tab:GetNormalTexture()
	tab:RemoveTextures()
	if(nTex) then
		nTex:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
		nTex:InsetPoints()
	end

	tab.pushed = true;

	tab.backdrop = CreateFrame("Frame", nil, tab)
	tab.backdrop:WrapPoints(tab,1,1)
	tab.backdrop:SetFrameLevel(0)
	tab.backdrop:SetBackdrop(SV.media.backdrop.glow);
    tab.backdrop:SetBackdropColor(0,0,0,1)
	tab.backdrop:SetBackdropBorderColor(0,0,0,1)
	tab:SetScript("OnEnter", Tab_OnEnter)
	tab:SetScript("OnLeave", Tab_OnLeave)

	local a1, p, a2, x, y = tab:GetPoint()
	tab:SetPoint(a1, p, a2, 1, y)
end

local function GetSpecTabHelper(index)
	local tab = SpellBookCoreAbilitiesFrame.SpecTabs[index]
	if(not tab) then return end
	ChangeTabHelper(tab)
	if(index > 1) then
		local a1, p, a2, x, y = tab:GetPoint()
		tab:ClearAllPoints()
		tab:SetPoint(a1, p, a2, 0, y)
	end
end

local function AbilityButtonHelper(index)
	local button = SpellBookCoreAbilitiesFrame.Abilities[index]

	if(button and (not button.Panel)) then
		local icon = button.iconTexture;

		if(not InCombatLockdown()) then
			if not button.properFrameLevel then
			 	button.properFrameLevel = button:GetFrameLevel() + 1
			end
			button:SetFrameLevel(button.properFrameLevel)
		end

		button:RemoveTextures()
		button:SetStyle("Frame", "Icon", true, 2, 0, 0)

		if(button.iconTexture) then
			button.iconTexture:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
			button.iconTexture:ClearAllPoints()
			button.iconTexture:InsetPoints(button, 1, 1)
		end

		if(button.Name) then
			button.Name:SetFontObject(NumberFont_Outline_Large)
			button.Name:SetTextColor(1,1,0)
		end

		if(button.InfoText) then
			button.InfoText:SetFontObject(SubSpellFont)
			button.InfoText:SetTextColor(0.8,0.8,0.8)
		end
	end
end

local ButtonUpdateHelper = function(self)
	local name = self:GetName();
	local icon = _G[name.."IconTexture"];

	if(not self.Panel) then
    	local iconTex;

		if(not InCombatLockdown()) then
			self:SetFrameLevel(SpellBookFrame:GetFrameLevel() + 5)
		end

		if(icon) then
			iconTex = icon:GetTexture()
		end

		self:RemoveTextures()
		self:SetStyle("Frame", "Icon", true, 2, 0, 0)

		if(icon) then
			icon:SetTexture(iconTex)
			icon:ClearAllPoints()
			icon:InsetPoints(self, 1, 1)
		end

		self.SpellName:SetFontObject(NumberFontNormal)

		if(self.FlyoutArrow) then
			self.FlyoutArrow:SetTexture([[Interface\Buttons\ActionBarFlyoutButton]])
		end
	end

	if(icon) then
		icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
	end

	if(self.SpellName) then
		self.SpellName:SetFontObject(NumberFont_Outline_Large)
		self.SpellName:SetTextColor(1,1,0)
	end

	if(self.SpellSubName) then
		self.SpellSubName:SetFontObject(SubSpellFont)
		self.SpellSubName:SetTextColor(0.8,0.8,0.8)
	end
end
--[[
##########################################################
SPELLBOOK MODR
##########################################################
]]--
local function SpellBookStyle()
	--print('test SpellBookStyle')
	if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.spellbook ~= true then return end

	SV:FontManager(_G["SubSpellFont"], "caps", "SYSTEM", 1, "OUTLINE", 0.8, 0.8, 0.8);
	SV:FontManager(_G["CoreAbilityFont"], "zone", "SYSTEM", 10, "OUTLINE", 0, 0, 0);

	SV.API:Set("Window", SpellBookFrame, false, false, 1, 3, 3)
	SV.API:Set("CloseButton", SpellBookFrameCloseButton)

	if(SpellBookFrameInset) then
		SpellBookFrameInset:RemoveTextures()
		SpellBookFrameInset:SetStyle("!_Frame", "Inset", true, 6)
	end
	if(SpellBookSpellIconsFrame) then SpellBookSpellIconsFrame:RemoveTextures() end
	if(SpellBookSideTabsFrame) then SpellBookSideTabsFrame:RemoveTextures() end
	if(SpellBookPageNavigationFrame) then SpellBookPageNavigationFrame:RemoveTextures() end

	for i = 1, 3 do
		local page = _G["SpellBookPage" .. i]
		if(page) then
			page:SetDrawLayer('BACKGROUND')
		end
	end

	SpellBookFrameTutorialButton:Die()

	SV.API:Set("PageButton", SpellBookPrevPageButton)
	SV.API:Set("PageButton", SpellBookNextPageButton)

	hooksecurefunc("SpellButton_UpdateButton", ButtonUpdateHelper)
	--hooksecurefunc("SpellBook_GetCoreAbilityButton", AbilityButtonHelper)

	for i = 1, MAX_SKILLLINE_TABS do
		local tabName = "SpellBookSkillLineTab" .. i
		local tab = _G[tabName]
		if(tab) then
			if(_G[tabName .. "Flash"]) then _G[tabName .. "Flash"]:Die() end
			ChangeTabHelper(tab)
		end
	end

	--hooksecurefunc('SpellBook_GetCoreAbilitySpecTab', GetSpecTabHelper)

	for _, gName in pairs(proFrames)do
		local frame = _G[gName]
		if(frame) then
			if(_G[gName .. "Missing"]) then
				_G[gName .. "Missing"]:SetTextColor(1, 1, 0)
			end
			if(frame.missingText) then
				frame.missingText:SetTextColor(1, 0, 0)
			end
	    	if(frame.missingHeader) then
	    		frame.missingHeader:SetFontObject(NumberFont_Outline_Large)
	    		frame.missingHeader:SetTextColor(1,1,0)
	    	end
	    	if(frame.missingText) then
	    		frame.missingText:SetFontObject(NumberFont_Shadow_Small)
	    		frame.missingText:SetTextColor(0.9,0.9,0.9)
	    	end
	    	if(frame.rank) then
	    		frame.rank:SetFontObject(NumberFontNormal)
	    		frame.rank:SetTextColor(0.9,0.9,0.9)
	    	end
	    	if(frame.professionName) then
	    		frame.professionName:SetFontObject(NumberFont_Outline_Large)
	    		frame.professionName:SetTextColor(1,1,0)
	    	end
	    end
	end

	for _, gName in pairs(proButtons)do
		local button = _G[gName]
		local buttonTex = _G[("%sIconTexture"):format(gName)]
		if(button) then
			button:RemoveTextures()
			if(buttonTex) then
				buttonTex:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
				buttonTex:InsetPoints()
				button:SetFrameLevel(button:GetFrameLevel() + 2)
				if not button.Panel then
					button:SetStyle("Frame", "Inset", false, 3, 3, 3)
					button.Panel:SetAllPoints()
				end
			end
			if(button.spellString) then
				button.spellString:SetFontObject(NumberFontNormal)
				button.spellString:SetTextColor(1,1,0)
			end
			if(button.subSpellString) then
				button.subSpellString:SetFontObject(SubSpellFont)
			end
		end
	end

	for _, gName in pairs(proBars) do
		local bar = _G[gName]
		if(bar) then
			bar:RemoveTextures()
			bar:SetHeight(12)
			bar:SetStatusBarTexture(SV.media.statusbar.default)
			bar:SetStatusBarColor(0, 220/255, 0)
			bar:SetStyle("Frame", "Default")
			bar.rankText:ClearAllPoints()
			bar.rankText:SetPoint("CENTER")
		end
	end

--[[
	if(SpellBookCoreAbilitiesFrame.SpecName) then
		SpellBookCoreAbilitiesFrame.SpecName:SetTextColor(1,1,0)
	end
]]--
	if(SpellBookFrameTabButton1) then
		SV.API:Set("Tab", SpellBookFrameTabButton1)
		SpellBookFrameTabButton1:ClearAllPoints()
		SpellBookFrameTabButton1:SetPoint('TOPLEFT', SpellBookFrame, 'BOTTOMLEFT', 0, 2)
	end
	if(SpellBookFrameTabButton2) then
		SV.API:Set("Tab", SpellBookFrameTabButton2)
	end
	if(SpellBookFrameTabButton3) then
		SV.API:Set("Tab", SpellBookFrameTabButton3)
	end
	if(SpellBookFrameTabButton4) then
		SV.API:Set("Tab", SpellBookFrameTabButton4)
	end
	if(SpellBookFrameTabButton5) then
		SV.API:Set("Tab", SpellBookFrameTabButton5)
	end
end
--[[
##########################################################
MOD LOADING
##########################################################
]]--
MOD:SaveCustomStyle(SpellBookStyle)
