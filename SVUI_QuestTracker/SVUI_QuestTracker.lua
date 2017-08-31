--[[
##########################################################
S V U I   By: Failcoder
##########################################################
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local pairs     = _G.pairs;
--BLIZZARD API
local CreateFrame           = _G.CreateFrame;
local GetTime               = _G.GetTime;
local PERCENTAGE_STRING     = _G.PERCENTAGE_STRING;
local GetTimeStringFromSeconds = _G.GetTimeStringFromSeconds;
local GetQuestProgressBarPercent = _G.GetQuestProgressBarPercent;
--[[
##########################################################
GET ADDON DATA
##########################################################
]]--
local SV = _G['SVUI']
local MOD = SV.QuestTracker;
if(not MOD) then return end;
MOD.DOCK_IS_FADED = false;
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
--local OBJ_ICON_ACTIVE = [[Interface\COMMON\Indicator-Yellow]];
local OBJ_ICON_COMPLETE = [[Interface\COMMON\Indicator-Green]];
local OBJ_ICON_INCOMPLETE = [[Interface\COMMON\Indicator-Gray]];
--[[
##########################################################
OBJECTIVE SCRIPT HANDLERS
##########################################################
]]--
local OBJECTIVE_StartProgress = function(self, ...)
	local questID, finished = ...

	local status = self:GetStatus();
	status:FadeIn();
	status.Bar.questID = questID;
	status.Bar.finished = finished;
	status.Bar:SetMinMaxValues(0, 100);
	local percent = 100;
	if(not finished) then
		percent = GetQuestProgressBarPercent(questID);
	end
	status.Bar:SetValue(percent);
	status.Label:SetFormattedText(PERCENTAGE_STRING, percent);
	self:RegisterEvent("QUEST_LOG_UPDATE")
end

local OBJECTIVE_StopProgress = function(self)
	if(not self.Status) then return end
	local status = self.Status;
	status:SetAlpha(0);
	status.Bar:SetValue(0);
	status.Label:SetText('');
	self:UnregisterEvent("QUEST_LOG_UPDATE")
end

local OBJECTIVE_UpdateProgress = function(self)
	if(not self.Status) then
		self:UnregisterEvent("QUEST_LOG_UPDATE")
		return
	end
	local status = self.Status;
	local percent = 100;
	if(not status.Bar.finished) then
		percent = GetQuestProgressBarPercent(status.Bar.questID);
	end
	status.Bar:SetValue(percent);
	status.Label:SetFormattedText(PERCENTAGE_STRING, percent);
end

local OBJECTIVE_StartTimer = function(self, ...)
	local duration, elapsed = ...
	local timeNow = GetTime();
	local startTime = timeNow - elapsed;
	local timeRemaining = duration - startTime;

	local status = self:GetStatus();
	status:FadeIn();
	status.Bar.duration = duration or 1;
	status.Bar.startTime = startTime;
	status.Bar:SetMinMaxValues(0, status.Bar.duration);
	status.Bar:SetValue(timeRemaining);
	status.Label:SetText(GetTimeStringFromSeconds(duration, nil, true));
	status.Label:SetTextColor(MOD:GetTimerTextColor(duration, duration - timeRemaining));

	self:SetScript("OnUpdate", self.UpdateTimer);
end

local OBJECTIVE_StopTimer = function(self)
	if(not self.Status) then return end
	local status = self.Status;
	status:SetAlpha(0);
	status.Bar.duration = 1;
	status.Bar.startTime = 0;
	status.Bar:SetMinMaxValues(0, status.Bar.duration);
	status.Bar:SetValue(0);
	status.Label:SetText('');
	status.Label:SetTextColor(1,1,1);

	self:SetScript("OnUpdate", nil);
end

local OBJECTIVE_UpdateTimer = function(self)
	if(not self.Status) then
		self:SetScript("OnUpdate", nil);
		return
	end
	local status = self.Status;
	local timeNow = GetTime();
	local timeRemaining = status.Bar.duration - (timeNow - status.Bar.startTime);
	status.Bar:SetValue(timeRemaining);
	if(timeRemaining < 0) then
		-- hold at 0 for a moment
		if(timeRemaining > -1) then
			timeRemaining = 0;
		else
			self:SetAlpha(0);
			status.Bar.duration = 1;
			status.Bar.startTime = 0;
			status.Bar:SetMinMaxValues(0, status.Bar.duration);
			status.Bar:SetValue(0);
			status.Label:SetText('');
			status.Label:SetTextColor(1,1,1);
			self:SetScript("OnUpdate", nil);
		end
	end
	local r,g,b = MOD:GetTimerTextColor(status.Bar.duration, status.Bar.duration - timeRemaining)
	status.Label:SetText(GetTimeStringFromSeconds(timeRemaining, nil, true));
	status.Label:SetTextColor(r,g,b);
end

local OBJECTIVE_GetStatus = function(self)
	if(not self.Status) then
		local status = CreateFrame("Frame", nil, self)
		status:SetPoint("TOPLEFT", self.Icon, "TOPRIGHT", 4, 0);
		status:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0);

		status.Bar = CreateFrame("StatusBar", nil, status);
		status.Bar:SetPoint("TOPLEFT", status, "TOPLEFT", 4, -2);
		status.Bar:SetPoint("BOTTOMRIGHT", status, "BOTTOMRIGHT", -4, 2);
		status.Bar:SetStatusBarTexture(SV.media.statusbar.default)
		status.Bar:SetStatusBarColor(0.15,0.5,1) --1,0.15,0.08
		status.Bar:SetMinMaxValues(0, 1)
		status.Bar:SetValue(0)

		local bgFrame = CreateFrame("Frame", nil, status.Bar)
		bgFrame:InsetPoints(status.Bar, -2, -2)
		bgFrame:SetFrameLevel(bgFrame:GetFrameLevel() - 1)

		bgFrame.bg = bgFrame:CreateTexture(nil, "BACKGROUND")
		bgFrame.bg:SetAllPoints(bgFrame)
		bgFrame.bg:SetTexture(SV.media.statusbar.default)
	  	bgFrame.bg:SetVertexColor(0,0,0,0.5)

		local borderB = bgFrame:CreateTexture(nil,"OVERLAY")
		borderB:SetColorTexture(0,0,0)
		borderB:SetPoint("BOTTOMLEFT")
		borderB:SetPoint("BOTTOMRIGHT")
		borderB:SetHeight(2)

		local borderT = bgFrame:CreateTexture(nil,"OVERLAY")
		borderT:SetColorTexture(0,0,0)
		borderT:SetPoint("TOPLEFT")
		borderT:SetPoint("TOPRIGHT")
		borderT:SetHeight(2)

		local borderL = bgFrame:CreateTexture(nil,"OVERLAY")
		borderL:SetColorTexture(0,0,0)
		borderL:SetPoint("TOPLEFT")
		borderL:SetPoint("BOTTOMLEFT")
		borderL:SetWidth(2)

		local borderR = bgFrame:CreateTexture(nil,"OVERLAY")
		borderR:SetColorTexture(0,0,0)
		borderR:SetPoint("TOPRIGHT")
		borderR:SetPoint("BOTTOMRIGHT")
		borderR:SetWidth(2)

		status.Label = status.Bar:CreateFontString(nil,"OVERLAY");
		status.Label:InsetPoints(status.Bar);
		status.Label:SetFontObject(SVUI_Font_Quest_Number)
		status.Label:SetTextColor(1,1,1)
		status.Label:SetText('')

		status:SetAlpha(0);

		self.Status = status;

		self:SetScript("OnEvent", self.UpdateProgress);

		return status;
	end

	return self.Status;
end
--[[
##########################################################
OBJECTIVE HEADER METHODS
##########################################################
]]--
local OBJECTIVE_HEADER_Reset = function(self, lite)
	for x = 1, #self.Rows do
		local objective = self.Rows[x]
		if(objective) then
			if(not objective:IsShown()) then
				objective:Show()
			end
			objective.Text:SetText('');
			objective.Icon:SetTexture("");
			objective:StopTimer();
			objective:StopProgress();
			objective:SetHeight(1);
			if(not lite) then
				objective:SetAlpha(0);
			end
		end
	end
	self:SetHeight(1);
end

local OBJECTIVE_HEADER_Get = function(self, index)
	if(not self.Rows[index]) then
		local yOffset = (index * (ROW_HEIGHT)) - ROW_HEIGHT;

		local objective = CreateFrame("Frame", nil, self);
		objective:SetPoint("TOPLEFT", self, "TOPLEFT", 22, -yOffset);
		objective:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, -yOffset);
		objective:SetHeight(ROW_HEIGHT);

		objective.Icon = objective:CreateTexture(nil,"OVERLAY");
		objective.Icon:SetPoint("TOPLEFT", objective, "TOPLEFT", 4, -2);
		objective.Icon:SetSize(INNER_HEIGHT,INNER_HEIGHT);
		objective.Icon:SetTexture(OBJ_ICON_INCOMPLETE);

		objective.Text = objective:CreateFontString(nil,"OVERLAY");
		objective.Text:SetPoint("TOPLEFT", objective, "TOPLEFT", 20 + 6, -2);
		objective.Text:SetPoint("TOPRIGHT", objective, "TOPRIGHT", 0, -2);
		objective.Text:SetHeight(INNER_HEIGHT);
		objective.Text:SetFontObject(SVUI_Font_Quest);
		objective.Text:SetJustifyH('LEFT')
		objective.Text:SetTextColor(0.6,0.6,0.6);
		objective.Text:SetText('');

		objective.StartProgress = OBJECTIVE_StartProgress;
		objective.StopProgress = OBJECTIVE_StopProgress;
		objective.UpdateProgress = OBJECTIVE_UpdateProgress;
		objective.StartTimer = OBJECTIVE_StartTimer;
		objective.StopTimer = OBJECTIVE_StopTimer;
		objective.UpdateTimer = OBJECTIVE_UpdateTimer;
		objective.GetStatus = OBJECTIVE_GetStatus;

		self.Rows[index] = objective;
		return objective;
	end

	return self.Rows[index];
end

local OBJECTIVE_HEADER_SetInfo = function(self, index, ...)
	index = index + 1;
	local description, completed, failed = ...
	local objective = self:Get(index);

	if(failed) then
		objective.Text:SetTextColor(1,0,0)
		objective.Icon:SetTexture(OBJ_ICON_INCOMPLETE)
	elseif(completed) then
		objective.Text:SetTextColor(0.1,0.9,0.1)
		objective.Icon:SetTexture(OBJ_ICON_COMPLETE)
	else
		objective.Text:SetTextColor(0.6,0.6,0.6)
		objective.Icon:SetTexture(OBJ_ICON_INCOMPLETE)
	end
	objective.Text:SetText(description);
	objective:SetHeight(INNER_HEIGHT);
	objective:FadeIn();

	return index;
end

local OBJECTIVE_HEADER_SetTimer = function(self, index, ...)
	index = index + 1;

	local objective = self:Get(index);
	objective.Text:SetText('')
	objective:SetHeight(INNER_HEIGHT);
	objective:FadeIn();

	objective:StartTimer(...)

	return index;
end

local OBJECTIVE_HEADER_SetProgress = function(self, index, ...)
	index = index + 1;

	local objective = self:Get(index);
	objective.Text:SetText('')
	objective:SetHeight(INNER_HEIGHT);
	objective:FadeIn();

	objective:StartProgress(...)

	return index;
end
--[[
##########################################################
OBJECTIVE CONSTRUCTOR
##########################################################
]]--
function MOD:NewObjectiveHeader()
	local header = CreateFrame("Frame", nil, self);
	header.Rows = {};

	header.Reset = OBJECTIVE_HEADER_Reset;
	header.Get = OBJECTIVE_HEADER_Get;
	header.SetInfo = OBJECTIVE_HEADER_SetInfo;
	header.SetTimer = OBJECTIVE_HEADER_SetTimer;
	header.SetProgress = OBJECTIVE_HEADER_SetProgress;

	return header;
end
--[[
##########################################################
CORE FUNCTIONS
##########################################################
]]--
function MOD:GetTimerTextColor(duration, elapsed)
	local yellowPercent = .66
	local redPercent = .33

	local percentageLeft = 1 - ( elapsed / duration )
	if(percentageLeft > yellowPercent) then
		return 1, 1, 1;
	elseif(percentageLeft > redPercent) then
		local blueOffset = (percentageLeft - redPercent) / (yellowPercent - redPercent);
		return 1, 1, blueOffset;
	else
		local greenOffset = percentageLeft / redPercent;
		return 1, greenOffset, 0;
	end
end

function MOD:UpdateDimensions()
	local totalHeight = 1;
	local scrollHeight = MOD.Docklet.ScrollFrame:GetHeight();
	local scrollWidth = MOD.Docklet.ScrollFrame:GetWidth();

	for headerName, headerFrame in pairs(MOD.Headers) do
		if(headerName == 'Active' or headerName == 'Popups') then
			totalHeight = totalHeight - headerFrame:GetHeight()
		else
			totalHeight = totalHeight + headerFrame:GetHeight()
		end
		headerFrame:SetWidth(scrollWidth)
	end
	if totalHeight < 1 then totalHeight = 1 end
	MOD.Docklet.ScrollFrame.MaxVal = totalHeight;
	MOD.Docklet.ScrollFrame.ScrollBar:SetMinMaxValues(1, totalHeight);
	--MOD.Docklet.ScrollFrame.ScrollBar:SetHeight(scrollHeight);
	MOD.Docklet.ScrollFrame.ScrollChild:SetWidth(scrollWidth);
	MOD.Docklet.ScrollFrame.ScrollChild:SetHeight(totalHeight);
	SV.Events:Trigger("QUEST_LAYOUT_UPDATED");
end

local function ExpandQuestTracker(location)
	if(not location or (location ~= MOD.Docklet.Parent.Bar.Data.Location)) then return end
	SV.Timers:ExecuteTimer(MOD.UpdateDimensions, 0.2)
end

local function PostFadeInCallback(location)
	if(not location or (location ~= MOD.Docklet.Parent.Bar.Data.Location)) then return end
	MOD.DOCK_IS_FADED = false;
	--print(MOD.DOCK_IS_FADED)
end

local function PostFadeOutCallback(location)
	if(not location or (location ~= MOD.Docklet.Parent.Bar.Data.Location)) then return end
	MOD.DOCK_IS_FADED = true;
	--print(MOD.DOCK_IS_FADED)
end

function MOD:UpdateSetup()
	for headerName, headerFrame in pairs(MOD.Headers) do
		if(headerFrame.Refresh) then
			headerFrame:Refresh()
		end
	end
end

function MOD:UpdateLocals()
	ROW_WIDTH = self.Docklet.ScrollFrame:GetWidth();
	local baseWidth = SV.db.QuestTracker.rowHeight;
	local calculated = SV.media.shared.font.questdialog.size + 4;
	ROW_HEIGHT = (baseWidth < calculated) and calculated or baseWidth;
	INNER_HEIGHT = ROW_HEIGHT - 4;
	LARGE_ROW_HEIGHT = ROW_HEIGHT * 2;
	LARGE_INNER_HEIGHT = LARGE_ROW_HEIGHT - 4;
	SV.Events:Trigger("QUEST_UPVALUES_UPDATED", ROW_WIDTH, ROW_HEIGHT, INNER_HEIGHT, LARGE_ROW_HEIGHT, LARGE_INNER_HEIGHT);
end

function MOD:ReLoad()
	-- DO STUFF
	self:UpdateDimensions()
end

function MOD:Load()
	self.Headers = {}
	self.Docklet = SV.Dock:NewDocklet("BottomRight", "SVUI_QuestTracker", "Quest Tracker", MOD.media.dockIcon);

	self:InitializePopups()
	self:InitializeActive()

	local scrollFrame = CreateFrame("ScrollFrame", "SVUI_QuestTrackerScrollFrame", self.Docklet);
	scrollFrame:SetPoint("TOPLEFT", self.Headers["Active"], "BOTTOMLEFT", 4, -2);
	scrollFrame:SetPoint("BOTTOMRIGHT", self.Docklet, "BOTTOMRIGHT", -30, 2);
	scrollFrame:EnableMouseWheel(true);
	scrollFrame.MaxVal = 420;

	local scrollBar = CreateFrame("Slider", "SVUI_QuestTrackerScrollFrameScrollBar", scrollFrame);
	--scrollBar:SetHeight(scrollFrame:GetHeight());
	scrollBar:SetWidth(18);
	scrollBar:SetPoint("TOPRIGHT", self.Headers["Active"], "BOTTOMRIGHT", -4, 2);
	scrollBar:SetPoint("BOTTOMRIGHT", self.Docklet, "BOTTOMRIGHT", -4, 2);
	scrollBar:SetFrameLevel(6)
	scrollBar:SetOrientation("VERTICAL");
	scrollBar:SetValueStep(5);
	scrollBar:SetMinMaxValues(1, 420);
	scrollBar:SetValue(1);
	scrollBar:SetScript("OnValueChanged", function(self, argValue)
		_G.SVUI_QuestTrackerScrollFrame:SetVerticalScroll(argValue)
	end)
	SV.API:Set("ScrollBar", scrollBar)

	local scrollChild = CreateFrame("Frame", "SVUI_QuestTrackerScrollFrameScrollChild", scrollFrame);
	scrollChild:SetWidth(scrollFrame:GetWidth());
	scrollChild:SetClampedToScreen(false)
	scrollChild:SetHeight(500)
	scrollChild:SetPoint("BOTTOMRIGHT", scrollFrame, "BOTTOMRIGHT", -2, 0)
	scrollChild:SetFrameLevel(scrollFrame:GetFrameLevel() + 1)

	scrollFrame:SetScrollChild(scrollChild);
	scrollFrame.ScrollBar = scrollBar;
	scrollFrame.ScrollChild = scrollChild;
	scrollFrame:SetScript("OnMouseWheel", function(self, delta)
		local scroll = self:GetVerticalScroll();
		local value = (scroll - (20  *  delta));
		if value < -1 then
			value = 0
		end
		if value > self.MaxVal then
			value = self.MaxVal
		end
		self:SetVerticalScroll(value)
		self.ScrollBar:SetValue(value)
	end)

	self.Docklet.ScrollFrame = scrollFrame;
	self:UpdateLocals();

	self.ClosestQuest = 0;
	self.CurrentQuest = 0;

	self:InitializeScenarios()
	--self:InitializeQuestItem()
	self:InitializeBonuses()
	self:InitializeQuests()
	self:InitializeAchievements()

	self:UpdateDimensions();
	self.Docklet:Show();

	ObjectiveTrackerFrame:UnregisterAllEvents();
	ObjectiveTrackerFrame:SetParent(SV.Hidden);
	if (ObjectiveTrackerFrame:IsVisible() or ObjectiveTrackerFrame:IsShown()) then ObjectiveTrackerFrame:Hide(); end
	
	self.Headers["Popups"]:Refresh()

	SV.Events:On("DOCK_EXPANDED", ExpandQuestTracker, true);
	SV.Events:On("DOCK_FADE_IN", PostFadeInCallback, true);
	SV.Events:On("DOCK_FADE_OUT", PostFadeOutCallback, true);
end
