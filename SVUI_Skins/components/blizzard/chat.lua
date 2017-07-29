--[[
##############################################################################
S V U I   By: Failcoder
##############################################################################
--]]
--[[ GLOBALS ]]--
local _G = _G;
local unpack  = _G.unpack;
local select  = _G.select;
local string 	= _G.string;
local math 		= _G.math;
local table 	= _G.table;
--[[ STRING METHODS ]]--
local format, join, gsub = string.format, string.join, string.gsub;
--[[ MATH METHODS ]]--
local ceil = math.ceil;  -- Basic
--[[ ADDON ]]--
local SV = _G['SVUI'];
local L = SV.L;
local MOD = SV.Skins;
local Schema = MOD.Schema;
--[[
##########################################################
FRAME LISTS
##########################################################
]]--
local CHAT_CONFIG_CHANNEL_LIST = _G.CHAT_CONFIG_CHANNEL_LIST;
local CHANNELS = _G.CHANNELS;

local ChatMenuList = {
	"ChatMenu",
	"EmoteMenu",
	"LanguageMenu",
	"VoiceMacroMenu",
};
local ChatFrameWipeList = {
	"ChatConfigFrame",
	"ChatConfigBackgroundFrame",
	"ChatConfigCategoryFrame",
	"ChatConfigChatSettingsClassColorLegend",
	"ChatConfigChatSettingsLeft",
	"ChatConfigChannelSettingsLeft",
	"ChatConfigChannelSettingsClassColorLegend",
	"ChatConfigOtherSettingsCombat",
	"ChatConfigOtherSettingsPVP",
	"ChatConfigOtherSettingsSystem",
	"ChatConfigOtherSettingsCreature",
	"ChatConfigCombatSettingsFilters",
	"CombatConfigMessageSourcesDoneBy",
	"CombatConfigMessageSourcesDoneTo",
	"CombatConfigColorsUnitColors",
	"CombatConfigColorsHighlighting",
	"CombatConfigColorsColorizeUnitName",
	"CombatConfigColorsColorizeSpellNames",
	"CombatConfigColorsColorizeDamageNumber",
	"CombatConfigColorsColorizeDamageSchool",
	"CombatConfigColorsColorizeEntireLine",
	"ChatConfigFrameDefaultButton",
	"ChatConfigFrameRedockButton",
	"ChatConfigFrameOkayButton",
	"CombatLogDefaultButton",
	"ChatConfigCombatSettingsFiltersCopyFilterButton",
	"ChatConfigCombatSettingsFiltersAddFilterButton",
	"ChatConfigCombatSettingsFiltersDeleteButton",
	"CombatConfigSettingsSaveButton",
	"ChatConfigFrameCancelButton",
	"ChatConfigCategoryFrame",
	"ChatConfigBackgroundFrame",
	"ChatConfigChatSettingsClassColorLegend",
	"ChatConfigChannelSettingsClassColorLegend",
	"ChatConfigCombatSettingsFilters",
	"ChatConfigCombatSettingsFiltersScrollFrame",
	"CombatConfigColorsHighlighting",
	"CombatConfigColorsColorizeUnitName",
	"CombatConfigColorsColorizeSpellNames",
	"CombatConfigColorsColorizeDamageNumber",
	"CombatConfigColorsColorizeDamageSchool",
	"CombatConfigColorsColorizeEntireLine",
	"ChatConfigChatSettingsLeft",
	"ChatConfigOtherSettingsCombat",
	"ChatConfigOtherSettingsPVP",
	"ChatConfigOtherSettingsSystem",
	"ChatConfigOtherSettingsCreature",
	"ChatConfigChannelSettingsLeft",
	"CombatConfigMessageSourcesDoneBy",
	"CombatConfigMessageSourcesDoneTo",
	"CombatConfigColorsUnitColors",
};
local ChatFrameList4 = {
	"CombatConfigColorsColorizeSpellNames",
	"CombatConfigColorsColorizeDamageNumber",
	"CombatConfigColorsColorizeDamageSchool",
	"CombatConfigColorsColorizeEntireLine",
};
local ChatFrameList5 = {
	"ChatConfigFrameOkayButton",
	"ChatConfigFrameDefaultButton",
	"ChatConfigFrameRedockButton",
	"CombatLogDefaultButton",
	"ChatConfigCombatSettingsFiltersDeleteButton",
	"ChatConfigCombatSettingsFiltersAddFilterButton",
	"ChatConfigCombatSettingsFiltersCopyFilterButton",
	"CombatConfigSettingsSaveButton",
};
local ChatFrameList6 = {
	"CombatConfigColorsHighlightingLine",
	"CombatConfigColorsHighlightingAbility",
	"CombatConfigColorsHighlightingDamage",
	"CombatConfigColorsHighlightingSchool",
	"CombatConfigColorsColorizeUnitNameCheck",
	"CombatConfigColorsColorizeSpellNamesCheck",
	"CombatConfigColorsColorizeSpellNamesSchoolColoring",
	"CombatConfigColorsColorizeDamageNumberCheck",
	"CombatConfigColorsColorizeDamageNumberSchoolColoring",
	"CombatConfigColorsColorizeDamageSchoolCheck",
	"CombatConfigColorsColorizeEntireLineCheck",
	"CombatConfigFormattingShowTimeStamp",
	"CombatConfigFormattingShowBraces",
	"CombatConfigFormattingUnitNames",
	"CombatConfigFormattingSpellNames",
	"CombatConfigFormattingItemNames",
	"CombatConfigFormattingFullText",
	"CombatConfigSettingsShowQuickButton",
	"CombatConfigSettingsSolo",
	"CombatConfigSettingsParty",
	"CombatConfigSettingsRaid",
};
--[[
##########################################################
HELPERS
##########################################################
]]--
local ChatGeneric_OnShow = function(self)
	 if(not self.Panel) then
	 	self:SetStyle("Frame", "Window")
	end
end

local ChatMenu_OnShow = function(self)
	if(not self.Panel) then
		self:SetStyle("Frame", "Window")
	end
	self:ClearAllPoints()
	self:SetPoint("BOTTOMLEFT", ChatFrame1, "TOPLEFT", 0, 30)
end

local _hook_ChatConfig_UpdateCheckboxes = function(frame)
	local checkBoxTable = frame.checkBoxTable;
	local checkBoxNameString = frame:GetName().."CheckBox";
	local boxHeight = ChatConfigOtherSettingsCombatCheckBox1:GetHeight() or 20
  local colorsHeight = ChatConfigChatSettingsLeftCheckBox1Check:GetHeight() or 20

	local checkbox, baseName;

	for index, value in ipairs(checkBoxTable) do
		baseName = checkBoxNameString..index;
		checkbox = _G[baseName];
		if(checkbox) then
			if(not checkbox.Panel) then
				checkbox:RemoveTextures()
				checkbox:SetStyle("Frame", 'Transparent')
			end
			checkbox:SetHeight(boxHeight)
			checkbox.Panel:SetPoint("TOPLEFT",3,-1)
			checkbox.Panel:SetPoint("BOTTOMRIGHT",-3,1)

			local check = _G[baseName.."Check"]
			if(check) then
				check:SetStyle("CheckButton")
			end

			local colors = _G[baseName.."ColorClasses"]
			if(colors) then
				colors:SetStyle("CheckButton")
				colors:SetHeight(colorsHeight)
			end
		end
	end
end
--[[
##########################################################
CHAT MODR
##########################################################
]]--
local function ChatStyle()
	--print('test ChatStyle')
	if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.chat ~= true then
		 return
	end

	for i = 1, #ChatMenuList do
		local name = ChatMenuList[i]
		local this = _G[name]
		if(this) then
			if(name == "ChatMenu") then
				this:HookScript("OnShow", ChatMenu_OnShow)
			else
				this:HookScript("OnShow", ChatGeneric_OnShow)
			end
		end
	end

	for i = 1, #ChatFrameWipeList do
		local frame = _G[ChatFrameWipeList[i]]
		if(frame) then
			-- JV: 20161025 - Broken in 70100-22900 (7.1 build 22900)
			--frame:RemoveTextures()
		end
	end

	ChatConfigFrameOkayButton:SetPoint("RIGHT", ChatConfigFrameCancelButton, "RIGHT", -11, -1)
	ChatConfigCombatSettingsFiltersDeleteButton:SetPoint("TOPRIGHT", ChatConfigCombatSettingsFilters, "BOTTOMRIGHT", 0, -1)
	ChatConfigCombatSettingsFiltersAddFilterButton:SetPoint("RIGHT", ChatConfigCombatSettingsFiltersDeleteButton, "LEFT", -1, 0)
	ChatConfigCombatSettingsFiltersCopyFilterButton:SetPoint("RIGHT", ChatConfigCombatSettingsFiltersAddFilterButton, "LEFT", -1, 0)

	if(_G["CombatConfigTab1"]) then _G["CombatConfigTab1"]:RemoveTextures() end
	if(_G["CombatConfigTab2"]) then _G["CombatConfigTab2"]:RemoveTextures() end
	if(_G["CombatConfigTab3"]) then _G["CombatConfigTab3"]:RemoveTextures() end
	if(_G["CombatConfigTab4"]) then _G["CombatConfigTab4"]:RemoveTextures() end
	if(_G["CombatConfigTab5"]) then _G["CombatConfigTab5"]:RemoveTextures() end

	CombatConfigSettingsNameEditBox:SetStyle("Editbox")
	ChatConfigFrame:SetStyle("Frame", "Window", true)

	ChatConfigCategoryFrame:SetStyle("Frame", 'Transparent')
	ChatConfigBackgroundFrame:SetStyle("Frame", 'Transparent')

	for i = 1, #ChatFrameList4 do
		local this = _G[ChatFrameList4[i]]
		if(this) then
			this:ClearAllPoints()
			if this == CombatConfigColorsColorizeSpellNames then
				this:SetPoint("TOP",CombatConfigColorsColorizeUnitName,"BOTTOM",0,-2)
			else
				this:SetPoint("TOP",_G[ChatFrameList4[i-1]],"BOTTOM",0,-2)
			end
		end
	end

	hooksecurefunc("ChatConfig_UpdateCheckboxes", _hook_ChatConfig_UpdateCheckboxes)
	-- do
	-- 	local chatchannellist = GetChannelList()
	-- 	local CreateChatChannelList = _G.CreateChatChannelList;
	-- 	local ChatConfigChannelSettings = _G.ChatConfigChannelSettings;
	-- 	CreateChatChannelList(ChatConfigChannelSettings, chatchannellist)
	-- end

	ChatConfig_CreateCheckboxes(ChatConfigChannelSettingsLeft, CHAT_CONFIG_CHANNEL_LIST, "ChatConfigCheckBoxWithSwatchAndClassColorTemplate", CHANNELS)
	ChatConfig_UpdateCheckboxes(ChatConfigChannelSettingsLeft)

	for i = 1, #COMBAT_CONFIG_TABS do
		local this = _G["CombatConfigTab"..i]
		if(this) then
			SV.API:Set("Tab", this)
			this:SetHeight(this:GetHeight()-2)
			this:SetWidth(ceil(this:GetWidth()+1.6))
			_G["CombatConfigTab"..i.."Text"]:SetPoint("BOTTOM", 0, 10)
		end
	end

	CombatConfigTab1:ClearAllPoints()
	CombatConfigTab1:SetPoint("BOTTOMLEFT", ChatConfigBackgroundFrame, "TOPLEFT", 6, -2)

	for i = 1, #ChatFrameList5 do
		local this = _G[ChatFrameList5[i]]
		if(this) then
			this:SetStyle("Button")
		end
	end

	ChatConfigFrameOkayButton:SetPoint("TOPRIGHT", ChatConfigBackgroundFrame, "BOTTOMRIGHT", -3, -5)
	ChatConfigFrameDefaultButton:SetPoint("TOPLEFT", ChatConfigCategoryFrame, "BOTTOMLEFT", 1, -5)
	ChatConfigFrameRedockButton:SetPoint("TOPLEFT", ChatConfigBackgroundFrame, "BOTTOMLEFT", 10, -5)
	CombatLogDefaultButton:SetPoint("TOPLEFT", ChatConfigCategoryFrame, "BOTTOMLEFT", 1, -5)
	ChatConfigCombatSettingsFiltersDeleteButton:SetPoint("TOPRIGHT", ChatConfigCombatSettingsFilters, "BOTTOMRIGHT", -3, -1)
	ChatConfigCombatSettingsFiltersCopyFilterButton:SetPoint("RIGHT", ChatConfigCombatSettingsFiltersDeleteButton, "LEFT", -2, 0)
	ChatConfigCombatSettingsFiltersAddFilterButton:SetPoint("RIGHT", ChatConfigCombatSettingsFiltersCopyFilterButton, "LEFT", -2, 0)

	for i = 1, #ChatFrameList6 do
		local this = _G[ChatFrameList6[i]]
		if(this) then
			this:SetStyle("CheckButton")
		end
	end

	SV.API:Set("PageButton", ChatConfigMoveFilterUpButton,true)
	SV.API:Set("PageButton", ChatConfigMoveFilterDownButton,true)
	SV.API:Set("PageButton", CombatLogQuickButtonFrame_CustomAdditionalFilterButton,true)

	SV.API:Set("ScrollBar", SVUI_CopyChatScrollFrameScrollBar)
	SV.API:Set("CloseButton", SVUI_CopyChatFrameCloseButton)

	ChatConfigMoveFilterUpButton:ClearAllPoints()
	ChatConfigMoveFilterDownButton:ClearAllPoints()
	ChatConfigMoveFilterUpButton:SetPoint("TOPLEFT",ChatConfigCombatSettingsFilters,"BOTTOMLEFT",3,0)
	ChatConfigMoveFilterDownButton:SetPoint("LEFT",ChatConfigMoveFilterUpButton,24,0)

	CombatConfigSettingsNameEditBox:SetStyle("Editbox")

	ChatConfigFrame:SetSize(680,596)
	ChatConfigFrameHeader:ClearAllPoints()
	ChatConfigFrameHeader:SetPoint("TOP", ChatConfigFrame, "TOP", 0, -5)

	-- for i=1, select("#", GetChatWindowChannels(3)) do
	-- 	local info = select(i, GetChatWindowChannels(3))
	-- 	print(info)
	-- end
	_hook_ChatConfig_UpdateCheckboxes(ChatConfigChatSettingsLeft)
	_hook_ChatConfig_UpdateCheckboxes(ChatConfigChannelSettingsLeft)
end
--[[
##########################################################
MOD LOADING
##########################################################
]]--
MOD:SaveCustomStyle("CHAT", ChatStyle)
