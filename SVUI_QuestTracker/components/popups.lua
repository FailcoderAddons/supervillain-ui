--[[
##########################################################
S V U I   By: Failcoder
##########################################################
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local unpack    = _G.unpack;
local select    = _G.select;
--[[
##########################################################
GET ADDON DATA
##########################################################
]]--
local SV = _G['SVUI']
local MOD = SV.QuestTracker;
--[[
##########################################################
LOCALS
##########################################################
]]--
local ROW_WIDTH = 300;
local ROW_HEIGHT = 24;
local INNER_HEIGHT = ROW_HEIGHT - 4;
local LARGE_ROW_HEIGHT = ROW_HEIGHT * 2;
local LARGE_INNER_HEIGHT = LARGE_ROW_HEIGHT - 4;
--[[
##########################################################
SCRIPT HANDLERS
##########################################################
]]--
local PopUpButton_OnClick = function(self)
	local questIndex = self:GetID();
	if(questIndex and (questIndex ~= 0) and self.PopUpType) then
		local questID = select(8, GetQuestLogTitle(questIndex));
		if(self.PopUpType == "OFFER") then
			ShowQuestOffer(questIndex);
		else
			ShowQuestComplete(questIndex);
		end
		MOD.Headers["Popups"]:RemovePopup(questID)
	end
end
--[[
##########################################################
TRACKER FUNCTIONS
##########################################################
]]--
local GetPopUpRow = function(self, index)
	if(not self.Rows[index]) then
		local previousFrame = self.Rows[#self.Rows]
		index = #self.Rows + 1;
		local row = CreateFrame("Frame", nil, self)
		if(previousFrame) then
			row:SetPoint("TOPLEFT", previousFrame, "BOTTOMLEFT", 0, -2);
			row:SetPoint("TOPRIGHT", previousFrame, "BOTTOMRIGHT", 0, -2);
		else
			row:SetPoint("TOPLEFT", self, "TOPLEFT", 0, -2);
			row:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, -2);
		end
		row:SetHeight(LARGE_ROW_HEIGHT);
		row.Button = CreateFrame("Button", nil, row)
		row.Button:SetPoint("TOPLEFT", row, "TOPLEFT", 0, 0);
		row.Button:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", 0, 0);
		row.Button:SetStyle("Button")
		row.Button:SetPanelColor('yellow')
		row.Button:SetID(0)
		row.Button.PopUpType = nil;
		row.Button:SetScript("OnClick", PopUpButton_OnClick)
		row.Badge = CreateFrame("Frame", nil, row.Button)
		row.Badge:SetPoint("TOPLEFT", row.Button, "TOPLEFT", 4, -4);
		row.Badge:SetSize((LARGE_INNER_HEIGHT - 4), (LARGE_INNER_HEIGHT - 4));
		row.Badge:SetStyle("!_Frame", "Icon")
		row.Badge.Icon = row.Badge:CreateTexture(nil,"OVERLAY")
		row.Badge.Icon:InsetPoints(row.Badge);
		row.Badge.Icon:SetTexture(MOD.media.incompleteIcon)
		row.Badge.Icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
		row.Header = CreateFrame("Frame", nil, row.Button)
		row.Header:SetPoint("TOPLEFT", row.Badge, "TOPRIGHT", 4, -1);
		row.Header:SetPoint("BOTTOMRIGHT", row.Button, "BOTTOMRIGHT", -5, 5);
		row.Header:SetStyle("Frame")
		row.Header.Text = row.Header:CreateFontString(nil,"OVERLAY")
		row.Header.Text:SetFontObject(SVUI_Font_Quest);
		row.Header.Text:SetJustifyH('LEFT')
		row.Header.Text:SetTextColor(1,1,0)
		row.Header.Text:SetText('')
		row.Header.Text:SetPoint("TOPLEFT", row.Header, "TOPLEFT", 0, 0);
		row.Header.Text:SetPoint("BOTTOMRIGHT", row.Header, "BOTTOMRIGHT", 0, 0);
		row.RowID = 0;
		self.Rows[index] = row;
		return row;
	end

	return self.Rows[index];
end

local SetPopupRow = function(self, index, title, popUpType, questID, questLogIndex)
	index = index + 1;
	local icon = (popUpType == 'COMPLETED') and MOD.media.completeIcon or MOD.media.incompleteIcon
	local row = self:GetPopup(index);
	row.RowID = questID
	row.Header:SetAlpha(1);
	row.Header.Text:SetText(title)
	row.Badge.Icon:SetTexture(icon);
	row.Badge:SetAlpha(1);
	row.Button:Enable();
	row.Button.PopUpType = popUpType;
	row.Button:SetID(questLogIndex);
	row:SetHeight(LARGE_ROW_HEIGHT);
	row:FadeIn();

	local fill_height = LARGE_ROW_HEIGHT + 6;

	return index, fill_height;
end

local RefreshPopupObjective = function(self)
	local rows = 0;
	local add_height;
	local fill_height = 0;
	for i = 1, GetNumAutoQuestPopUps() do
		local questID, popUpType = GetAutoQuestPopUp(i);
		if(questID) then
			local questLogIndex = GetQuestLogIndexByID(questID);
			local title = GetQuestLogTitle(questLogIndex);
			if(title and title ~= '') then
				rows, add_height = self:SetPopup(rows, title, popUpType, questID, questLogIndex);
				add_height = add_height or 0;
				fill_height = fill_height + add_height
			end
		end
	end

	if(rows == 0 or (fill_height <= 1)) then
		self.CurrentHeight = 1;
		self:SetAlpha(0);
	else
		self.CurrentHeight = (fill_height + 2);
		self:FadeIn();
	end
end

local ResetPopupBlock = function(self)
	for x = 1, #self.Rows do
		local row = self.Rows[x]
		if(row) then
			row.RowID = 0;
			row.Header.Text:SetText('');
			row.Header:SetAlpha(0);
			row.Button:SetID(0);
			row.Button:Disable();
			row.Badge:SetAlpha(0);
			row.Badge.Icon:SetTexture("");
			row:SetHeight(1);
			row:SetAlpha(0);
		end
	end
end

local AddAutoPopUp = function(self, questID, popUpType, noCheck)
	local checkPassed = true;
	if(not noCheck) then
		checkPassed = AddAutoQuestPopUp(questID, popUpType)
	end
	if(checkPassed) then
		self:Reset()
		self:Refresh();
		MOD:UpdateDimensions();
		PlaySound(SOUNDKIT.UI_AUTO_QUEST_COMPLETE)
		self:SetHeight(self.CurrentHeight)
	end
end

local RemoveAutoPopUp = function(self, questID, noRemove)
	if(not noRemove) then
		RemoveAutoQuestPopUp(questID);
	end
	self:Reset();
	self:Refresh();
	self:SetHeight(1);
	MOD:UpdateDimensions();
end

local _hook_AddAutoPopUpQuests = function(questID, popUpType)
	MOD.Headers["Popups"]:AddPopup(questID, popUpType, true)
end

local _hook_RemoveAutoPopUpQuests = function(questID)
	MOD.Headers["Popups"]:RemovePopup(questID, true)
end
--[[
##########################################################
CORE FUNCTIONS
##########################################################
]]--

function MOD:UpdatePopupQuests(event, ...)
	local questID = ...;
	self.Headers["Popups"]:AddPopup(questID, "COMPLETE");
end

local function UpdatePopupLocals(...)
	ROW_WIDTH, ROW_HEIGHT, INNER_HEIGHT, LARGE_ROW_HEIGHT, LARGE_INNER_HEIGHT = ...;
end

function MOD:InitializePopups()
	local popups = CreateFrame("Frame", nil, self.Docklet)
	popups:SetPoint("BOTTOMLEFT", self.Docklet, "TOPLEFT");
    popups:SetPoint("BOTTOMRIGHT", self.Docklet, "TOPRIGHT");
    popups:SetHeight(1);
	popups.Rows = {};

	popups.GetPopup = GetPopUpRow;
	popups.SetPopup = SetPopupRow;
	popups.AddPopup = AddAutoPopUp;
	popups.RemovePopup = RemoveAutoPopUp;
	popups.Reset = ResetPopupBlock;
	popups.Refresh = RefreshPopupObjective;

	self.Headers["Popups"] = popups;

	self:RegisterEvent("QUEST_AUTOCOMPLETE", self.UpdatePopupQuests);

	hooksecurefunc("AutoQuestPopupTracker_AddPopUp", _hook_AddAutoPopUpQuests);
	hooksecurefunc("AutoQuestPopupTracker_RemovePopUp", _hook_RemoveAutoPopUpQuests);

	SV.Events:On("QUEST_UPVALUES_UPDATED", UpdatePopupLocals, true);
end
