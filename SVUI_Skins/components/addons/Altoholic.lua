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
ALTOHOLIC
##########################################################
]]--
local function ColorAltoBorder(self)
	if self.border then
		local Backdrop = self.backdrop or self.Backdrop
		if not Backdrop then return end
		local r, g, b = self.border:GetVertexColor()
		Backdrop:SetBackdropBorderColor(r, g, b, 1)
	end
end

local function ApplyTextureStyle(self)
	if not self then return end
	self:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
	local parent = self:GetParent()
	if(parent) then
		self:InsetPoints(parent, 1, 1)
	end
end

local AltoholicFrameStyled = false;

local function StyleAltoholic(event, addon)
	assert(AltoholicFrame, "AddOn Not Loaded")

	if not AltoholicFrameStyled then
		SV.API:Set("Tooltip", AltoTooltip)

		AltoholicFramePortrait:Die()

		SV.API:Set("Frame", AltoholicFrame, "Window2")
		SV.API:Set("Frame", AltoMsgBox)
		SV.API:Set("Button", AltoMsgBoxYesButton)
		SV.API:Set("Button", AltoMsgBoxNoButton)
		SV.API:Set("CloseButton", AltoholicFrameCloseButton)
		SV.API:Set("EditBox", AltoholicFrame_SearchEditBox, 175, 15)
		SV.API:Set("Button", AltoholicFrame_ResetButton)
		SV.API:Set("Button", AltoholicFrame_SearchButton)

		AltoholicFrameTab1:SetPoint("TOPLEFT", AltoholicFrame, "BOTTOMLEFT", -5, 2)
		AltoholicFrame_ResetButton:SetPoint("TOPLEFT", AltoholicFrame, "TOPLEFT", 25, -77)
		AltoholicFrame_SearchEditBox:SetPoint("TOPLEFT", AltoholicFrame, "TOPLEFT", 37, -56)
		AltoholicFrame_ResetButton:SetSize(85, 24)
		AltoholicFrame_SearchButton:SetSize(85, 24)
		AltoholicFrameStyled = true
	end

	if IsAddOnLoaded("Altoholic_Summary") then
		SV.API:Set("Frame", AltoholicFrameSummary)
		SV.API:Set("Frame", AltoholicFrameBagUsage)
		SV.API:Set("Frame", AltoholicFrameSkills)
		SV.API:Set("Frame", AltoholicFrameActivity)
		SV.API:Set("ScrollBar", AltoholicFrameSummaryScrollFrameScrollBar)
		SV.API:Set("ScrollBar", AltoholicFrameBagUsageScrollFrameScrollBar)
		SV.API:Set("ScrollBar", AltoholicFrameSkillsScrollFrameScrollBar)
		SV.API:Set("ScrollBar", AltoholicFrameActivityScrollFrameScrollBar)
		SV.API:Set("DropDown", AltoholicTabSummary_SelectLocation, 200)

		if(AltoholicFrameSummaryScrollFrame) then
			AltoholicFrameSummaryScrollFrameScrollBar:RemoveTextures(true)
		end

		if(AltoholicFrameBagUsageScrollFrame) then
			AltoholicFrameBagUsageScrollFrameScrollBar:RemoveTextures(true)
		end

		if(AltoholicFrameSkillsScrollFrame) then
			AltoholicFrameSkillsScrollFrameScrollBar:RemoveTextures(true)
		end

		if(AltoholicFrameActivityScrollFrame) then
			AltoholicFrameActivityScrollFrameScrollBar:RemoveTextures(true)
		end

		SV.API:Set("Button", AltoholicTabSummary_RequestSharing)
		ApplyTextureStyle(AltoholicTabSummary_RequestSharingIconTexture)
		SV.API:Set("Button", AltoholicTabSummary_Options)
		ApplyTextureStyle(AltoholicTabSummary_OptionsIconTexture)
		SV.API:Set("Button", AltoholicTabSummary_OptionsDataStore)
		ApplyTextureStyle(AltoholicTabSummary_OptionsDataStoreIconTexture)

		for i = 1, 5 do
			SV.API:Set("Button", _G["AltoholicTabSummaryMenuItem"..i], true)
		end
		for i = 1, 8 do
			SV.API:Set("Button", _G["AltoholicTabSummary_Sort"..i], true)
		end
		for i = 1, 7 do
			SV.API:Set("Tab", _G["AltoholicFrameTab"..i], true)
		end
	end

	if IsAddOnLoaded("Altoholic_Characters") then
		SV.API:Set("Frame", AltoholicFrameContainers)
		SV.API:Set("Frame", AltoholicFrameRecipes)
		SV.API:Set("Frame", AltoholicFrameQuests)
		SV.API:Set("Frame", AltoholicFrameGlyphs)
		SV.API:Set("Frame", AltoholicFrameMail)
		SV.API:Set("Frame", AltoholicFrameSpellbook)
		SV.API:Set("Frame", AltoholicFramePets)
		SV.API:Set("Frame", AltoholicFrameAuctions)
		SV.API:Set("ScrollBar", AltoholicFrameContainersScrollFrameScrollBar)
		SV.API:Set("ScrollBar", AltoholicFrameQuestsScrollFrameScrollBar)
		SV.API:Set("ScrollBar", AltoholicFrameRecipesScrollFrameScrollBar)
		SV.API:Set("DropDown", AltoholicFrameTalents_SelectMember)
		SV.API:Set("DropDown", AltoholicTabCharacters_SelectRealm)
		SV.API:Set("PageButton", AltoholicFrameSpellbookPrevPage)
		SV.API:Set("PageButton", AltoholicFrameSpellbookNextPage)
		SV.API:Set("PageButton", AltoholicFramePetsNormalPrevPage)
		SV.API:Set("PageButton", AltoholicFramePetsNormalNextPage)
		SV.API:Set("Button", AltoholicTabCharacters_Sort1)
		SV.API:Set("Button", AltoholicTabCharacters_Sort2)
		SV.API:Set("Button", AltoholicTabCharacters_Sort3)
		AltoholicFrameContainersScrollFrameScrollBar:RemoveTextures(true)
		AltoholicFrameQuestsScrollFrameScrollBar:RemoveTextures(true)
		AltoholicFrameRecipesScrollFrameScrollBar:RemoveTextures(true)

		local Buttons = {
			'AltoholicTabCharacters_Characters',
			'AltoholicTabCharacters_CharactersIcon',
			'AltoholicTabCharacters_BagsIcon',
			'AltoholicTabCharacters_QuestsIcon',
			'AltoholicTabCharacters_TalentsIcon',
			'AltoholicTabCharacters_AuctionIcon',
			'AltoholicTabCharacters_MailIcon',
			'AltoholicTabCharacters_SpellbookIcon',
			'AltoholicTabCharacters_ProfessionsIcon',
		}

		for _, object in pairs(Buttons) do
			ApplyTextureStyle(_G[object..'IconTexture'])
			ApplyTextureStyle(_G[object])
		end

		for i = 1, 7 do
			for j = 1, 14 do
				SV.API:Set("ItemButton", _G["AltoholicFrameContainersEntry"..i.."Item"..j])
				_G["AltoholicFrameContainersEntry"..i.."Item"..j]:HookScript('OnShow', ColorAltoBorder)
			end
		end
	end

	if IsAddOnLoaded("Altoholic_Achievements") then
		SV.API:Set("!_Frame", AltoholicFrameAchievements)
		AltoholicFrameAchievementsScrollFrameScrollBar:RemoveTextures(true)
		AltoholicAchievementsMenuScrollFrameScrollBar:RemoveTextures(true)
		SV.API:Set("ScrollBar", AltoholicFrameAchievementsScrollFrameScrollBar)
		SV.API:Set("ScrollBar", AltoholicAchievementsMenuScrollFrameScrollBar)
		SV.API:Set("DropDown", AltoholicTabAchievements_SelectRealm)
		AltoholicTabAchievements_SelectRealm:SetPoint("TOPLEFT", AltoholicFrame, "TOPLEFT", 205, -57)

		for i = 1, 15 do
			SV.API:Set("Button", _G["AltoholicTabAchievementsMenuItem"..i], true)
		end

		for i = 1, 8 do
			for j = 1, 10 do
				SV.API:Set("!_Frame", _G["AltoholicFrameAchievementsEntry"..i.."Item"..j])
				local Backdrop = _G["AltoholicFrameAchievementsEntry"..i.."Item"..j].backdrop or _G["AltoholicFrameAchievementsEntry"..i.."Item"..j].Backdrop
				ApplyTextureStyle(_G["AltoholicFrameAchievementsEntry"..i.."Item"..j..'_Background'])
				_G["AltoholicFrameAchievementsEntry"..i.."Item"..j..'_Background']:SetInside(Backdrop)
			end
		end
	end

	if IsAddOnLoaded("Altoholic_Agenda") then
		SV.API:Set("Frame", AltoholicFrameCalendarScrollFrame)
		SV.API:Set("Frame", AltoholicTabAgendaMenuItem1)
		SV.API:Set("ScrollBar", AltoholicFrameCalendarScrollFrameScrollBar)
		SV.API:Set("PageButton", AltoholicFrameCalendar_NextMonth)
		SV.API:Set("PageButton", AltoholicFrameCalendar_PrevMonth)
		SV.API:Set("Button", AltoholicTabAgendaMenuItem1, true)

		for i = 1, 14 do
			SV.API:Set("Frame", _G["AltoholicFrameCalendarEntry"..i])
		end
	end

	if IsAddOnLoaded("Altoholic_Grids") then
		AltoholicFrameGridsScrollFrameScrollBar:RemoveTextures(true)
		SV.API:Set("!_Frame", AltoholicFrameGrids)
		SV.API:Set("ScrollBar", AltoholicFrameGridsScrollFrameScrollBar)
		SV.API:Set("DropDown", AltoholicTabGrids_SelectRealm)
		SV.API:Set("DropDown", AltoholicTabGrids_SelectView)

		for i = 1, 8 do
			for j = 1, 10 do
				SV.API:Set("!_Frame", _G["AltoholicFrameGridsEntry"..i.."Item"..j])
				_G["AltoholicFrameGridsEntry"..i.."Item"..j]:HookScript('OnShow', ColorAltoBorder)
			end
		end

		AltoholicFrameGrids:HookScript('OnUpdate', function()
			for i = 1, 10 do
				for j = 1, 10 do
					if _G["AltoholicFrameGridsEntry"..i.."Item"..j.."_Background"] then
						_G["AltoholicFrameGridsEntry"..i.."Item"..j.."_Background"]:SetTexCoord(.08, .92, .08, .82)
					end
				end
			end
		end)

	end

	if IsAddOnLoaded("Altoholic_Guild") then
		SV.API:Set("Frame", AltoholicFrameGuildMembers)
		SV.API:Set("Frame", AltoholicFrameGuildBank)
		SV.API:Set("ScrollBar", AltoholicFrameGuildMembersScrollFrameScrollBar)
		AltoholicFrameGuildMembersScrollFrameScrollBar:RemoveTextures(true)

		for i = 1, 2 do
			SV.API:Set("Button", _G["AltoholicTabGuildMenuItem"..i])
		end

		for i = 1, 7 do
			for j = 1, 14 do
				SV.API:Set("ItemButton", _G["AltoholicFrameGuildBankEntry"..i.."Item"..j])
			end
		end

		for i = 1, 19 do
			SV.API:Set("ItemButton", _G["AltoholicFrameGuildMembersItem"..i])
		end

		for i = 1, 5 do
			SV.API:Set("Button", _G["AltoholicTabGuild_Sort"..i])
		end
	end

	if IsAddOnLoaded("Altoholic_Search") then
		SV.API:Set("!_Frame", AltoholicFrameSearch)
		AltoholicFrameSearchScrollFrameScrollBar:RemoveTextures(true)
		AltoholicSearchMenuScrollFrameScrollBar:RemoveTextures(true)
		SV.API:Set("ScrollBar", AltoholicFrameSearchScrollFrameScrollBar)
		SV.API:Set("ScrollBar", AltoholicSearchMenuScrollFrameScrollBar)
		SV.API:Set("DropDown", AltoholicTabSearch_SelectRarity)
		SV.API:Set("DropDown", AltoholicTabSearch_SelectSlot)
		SV.API:Set("DropDown", AltoholicTabSearch_SelectLocation)
		AltoholicTabSearch_SelectRarity:SetSize(125, 32)
		AltoholicTabSearch_SelectSlot:SetSize(125, 32)
		AltoholicTabSearch_SelectLocation:SetSize(175, 32)
		SV.API:Set("EditBox", _G["AltoholicTabSearch_MinLevel"])
		SV.API:Set("EditBox", _G["AltoholicTabSearch_MaxLevel"])

		for i = 1, 15 do
			SV.API:Set("Button", _G["AltoholicTabSearchMenuItem"..i])
		end

		for i = 1, 8 do
			SV.API:Set("Button", _G["AltoholicTabSearch_Sort"..i])
		end
	end
end

MOD:SaveAddonStyle("Altoholic", StyleAltoholic, false, true)
