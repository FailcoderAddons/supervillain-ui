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
local type      = _G.type;
--BLIZZARD API
local CreateFrame           			= _G.CreateFrame;
local GameTooltip           			= _G.GameTooltip;
local IsShiftKeyDown        			= _G.IsShiftKeyDown;
local IsModifiedClick       			= _G.IsModifiedClick;
local GetQuestLink  							= _G.GetQuestLink;
local GetQuestLogTitle  					= _G.GetQuestLogTitle;
local GetQuestWatchInfo  					= _G.GetQuestWatchInfo;
local GetQuestWatchIndex  				= _G.GetQuestWatchIndex;
local ShowQuestComplete  					= _G.ShowQuestComplete;
local RemoveQuestWatch  					= _G.RemoveQuestWatch;
local IsQuestComplete  						= _G.IsQuestComplete;
local GetSuperTrackedQuestID			= _G.GetSuperTrackedQuestID;
local GetQuestLogIndexByID  			= _G.GetQuestLogIndexByID;
local GetQuestObjectiveInfo				= _G.GetQuestObjectiveInfo;
local GetQuestLogIsAutoComplete  	= _G.GetQuestLogIsAutoComplete;
local GetQuestDifficultyColor  		= _G.GetQuestDifficultyColor;
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
local DEFAULT_COLOR = {r = 1, g = 0.68, b = 0.1}
--[[
##########################################################
SCRIPT HANDLERS
##########################################################
]]--
-- local ObjectiveTimer_OnUpdate = function(self, elapsed)
-- 	local statusbar = self.Timer.Bar
-- 	local timeNow = GetTime();
-- 	local timeRemaining = statusbar.duration - (timeNow - statusbar.startTime);
-- 	statusbar:SetValue(timeRemaining);
-- 	if(timeRemaining < 0) then
-- 		-- hold at 0 for a moment
-- 		if(timeRemaining > -1) then
-- 			timeRemaining = 0;
-- 		else
-- 			self:StopTimer();
-- 		end
-- 	end
-- 	local r,g,b = MOD:GetTimerTextColor(statusbar.duration, statusbar.duration - timeRemaining)
-- 	statusbar.Label:SetText(GetTimeStringFromSeconds(timeRemaining, nil, true));
-- 	statusbar.Label:SetTextColor(r,g,b);
-- end
--
-- local ObjectiveProgressBar_OnEvent = function(self, event, ...)
-- 	local statusbar = self.Progress.Bar;
-- 	local percent = 100;
-- 	if(not statusbar.finished) then
-- 		percent = GetQuestProgressBarPercent(statusbar.questID);
-- 	end
-- 	statusbar:SetValue(percent);
-- 	statusbar.Label:SetFormattedText(PERCENTAGE_STRING, percent);
-- end

local ActiveButton_OnEnter = function(self)
	if(MOD.DOCK_IS_FADED) then return end
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 0, ROW_HEIGHT)
	GameTooltip:ClearLines()
	GameTooltip:AddDoubleLine("[Left-Click]", "View the log entry for this quest.", 0, 1, 0, 1, 1, 1)
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine("[Right-Click]", "Remove this quest from the tracker.", 0, 1, 0, 1, 1, 1)
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine("[SHIFT+Click]", "Show this quest on the map.", 0, 1, 0, 1, 1, 1)
	GameTooltip:Show()
end

local ActiveButton_OnLeave = function()
	GameTooltip:Hide()
end

local ActiveButton_OnClick = function()
	MOD.Headers["Active"]:Unset();
end

local ViewButton_OnClick = function(self, button)
	local questIndex = self.LogID;
	if(questIndex and (questIndex ~= 0)) then
		local questID = select(8, GetQuestLogTitle(questIndex));
		if(IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow()) then
			local questLink = GetQuestLink(questIndex);
			if(questLink) then
				ChatEdit_InsertLink(questLink);
			end
		elseif(questID and IsShiftKeyDown()) then
			QuestMapFrame_OpenToQuestDetails(questID);
		elseif(questID and button ~= "RightButton") then
			CloseDropDownMenus();
			if(IsQuestComplete(questID) and GetQuestLogIsAutoComplete(questIndex)) then
				AutoQuestPopupTracker_RemovePopUp(questID);
				ShowQuestComplete(questIndex);
			else
				QuestLogPopupDetailFrame_Show(questIndex);
			end
		elseif(questID) then
			local superTrackedQuestID = GetSuperTrackedQuestID();
			RemoveQuestWatch(questIndex);
			if(questID == superTrackedQuestID) then
				QuestSuperTracking_OnQuestUntracked();
			end
		end
	end
end

local CloseButton_OnEnter = function(self)
    self:SetBackdropBorderColor(0.1, 0.8, 0.8)
end

local CloseButton_OnLeave = function(self)
    self:SetBackdropBorderColor(0,0,0,1)
end
--[[
##########################################################
TRACKER FUNCTIONS
##########################################################
]]--
local UnsetActiveData = function(self, bypass)
	local block = self.Block;
	block:SetHeight(1);
	block.Header.Text:SetText('');
	block.Header.Level:SetText('');
	block.Badge.Icon:SetTexture("");
	block.Button.LogID = 0;
	self.ActiveQuestID = 0;
	MOD.ActiveQuestID = self.ActiveQuestID;
	MOD.CurrentQuest = 0;
	block.Objectives:Reset();
	block:SetAlpha(0);
	self:SetAlpha(0);
	self:SetHeight(1);
	-- if(MOD.QuestItem and MOD.QuestItem:IsShown()) then
	-- 	MOD.QuestItem.CurrentQuest = 0;
	-- 	MOD.QuestItem.Artwork:SetTexture("");
	-- 	MOD.QuestItem:ClearUsage();
	-- end
	if(block.Badge.StopTracking) then
		block.Badge:StopTracking()
	end
	if(not bypass and MOD.Headers["Quests"]) then
		MOD:UpdateObjectives('FORCED_UPDATE')
	end
end

local SetActiveData = function(self, title, level, icon, questID, questLogIndex, numObjectives, duration, elapsed, isComplete, itemLink)
	if(not questID) then return end
	self.ActiveQuestID = questID;
	MOD.ActiveQuestID = self.ActiveQuestID;
	local fill_height = 0;
	local objective_rows = 0;
	local block = self.Block;

	local color = DEFAULT_COLOR
	if(level and type(level) == 'number') then
		color = GetQuestDifficultyColor(level);
	end
	block.Header.Level:SetTextColor(color.r, color.g, color.b);
	block.Header.Level:SetText(level);
	block.Header.Text:SetText(title);

	block.Button.LogID = questLogIndex;

	MOD.CurrentQuest = questLogIndex;

	local objective_block = block.Objectives;
	objective_block:Reset();
	for i = 1, numObjectives do
		local description, category, completed = GetQuestObjectiveInfo(questID, i, false);
		if(not completed) then isComplete = false end
		if(duration and elapsed and (elapsed < duration)) then
			objective_rows = objective_block:SetTimer(objective_rows, duration, elapsed);
			fill_height = fill_height + (INNER_HEIGHT + 2);
		elseif(description and description ~= '') then
			objective_rows = objective_block:SetInfo(objective_rows, description, completed);
			fill_height = fill_height + (INNER_HEIGHT + 2);
		end
	end

	if(objective_rows > 0) then
		objective_block:SetHeight(fill_height);
		objective_block:FadeIn();
	end
	fill_height = fill_height + (LARGE_INNER_HEIGHT + 8);
	local padding = block.Details:GetHeight()
	block:SetHeight(fill_height + padding);

	MOD.Docklet.ScrollFrame.ScrollBar:SetValue(0);

	if(isComplete) then
		icon = MOD.media.completeIcon;
	else
		icon = icon or MOD.media.incompleteIcon;
	end
	block.Badge.Icon:SetTexture(icon);
	-- if(itemLink) then
	-- 	local iName, _, _, _ = GetItemInfo(itemLink);
	-- 	block.Badge.Button.macrotext = '/use '..iName;
	-- 	if(InCombatLockdown()) then
 --            block.Badge.Button:RegisterEvent('PLAYER_REGEN_ENABLED')
 --        else
 --            block.Badge.Button:SetAttribute('item', block.Badge.Button.macrotext)
 --        end
	-- end

	if(block.Badge.StartTracking) then
		block.Badge:StartTracking(questID)
	end

	self:RefreshHeight()
end

local RefreshActiveHeight = function(self)
	if(self.ActiveQuestID == 0) then
		self:Unset()
	else
		self:FadeIn();
		self.Block:FadeIn();
		local height = self.Block:GetHeight()
		self:SetHeight(height)
	end
end

local RefreshActiveObjective = function(self, event, ...)
	-- print('<-----ACTIVE')
	-- print(event)
	-- print(...)
	if(event) then
		if(event == 'ACTIVE_QUEST_LOADED') then
			self.ActiveQuestID = 0;
			self:Set(...)
		elseif(event == 'SUPER_TRACKED_QUEST_CHANGED') then
			local questID = ...;
			if(questID and questID ~= self.ActiveQuestID) then
				local questLogIndex = GetQuestLogIndexByID(questID)
				if(questLogIndex) then
					local questWatchIndex = GetQuestWatchIndex(questLogIndex)
					if(questWatchIndex) then
						local title, level, suggestedGroup = GetQuestLogTitle(questLogIndex)
						local questID, _, questLogIndex, numObjectives, requiredMoney, completed, startEvent, isAutoComplete, duration, elapsed, questType, isTask, isStory, isOnMap, hasLocalPOI = GetQuestWatchInfo(questWatchIndex);
						self:Set(title, level, nil, questID, questLogIndex, numObjectives, duration, elapsed, hasLocalPOI)
					end
				end
			end
		elseif(event == 'FORCED_UPDATE') then
			local questID = self.ActiveQuestID;
			if(questID and questID ~= 0) then
				local questLogIndex = GetQuestLogIndexByID(questID)
				if(questLogIndex) then
					local questWatchIndex = GetQuestWatchIndex(questLogIndex)
					if(questWatchIndex) then
						local title, level, suggestedGroup = GetQuestLogTitle(questLogIndex)
						local questID, _, questLogIndex, numObjectives, requiredMoney, completed, startEvent, isAutoComplete, duration, elapsed, questType, isTask, isStory, isOnMap, hasLocalPOI = GetQuestWatchInfo(questWatchIndex);
						self:Set(title, level, nil, questID, questLogIndex, numObjectives, duration, elapsed, hasLocalPOI)
					end
				end
			end
		end
	end
end

local MacroButton_OnEvent = function(self, event)
    if(event == 'PLAYER_REGEN_ENABLED') then
        self:SetAttribute('macrotext', self.macrotext)
        self:UnregisterEvent(event)
    end
end
--[[
##########################################################
CORE FUNCTIONS
##########################################################
]]--
function MOD:CheckActiveQuest(questID, ...)
	if(questID and self.Headers["Active"].ActiveQuestID == questID) then
		self.Headers["Active"]:Unset(true);
	else
		local currentQuestIndex = self.CurrentQuest;
		if(currentQuestIndex and (currentQuestIndex ~= 0)) then
			local questLogIndex = select(5, ...);
			if(questLogIndex and (questLogIndex == currentQuestIndex)) then
				self.Headers["Active"]:Set(...);
				return true;
			end
		end
	end
	return false;
end

function MOD:UpdateActiveObjective(event, ...)
	self.Headers["Active"]:Refresh(event, ...)
	self:UpdateDimensions();
end

local function UpdateActiveLocals(...)
	ROW_WIDTH, ROW_HEIGHT, INNER_HEIGHT, LARGE_ROW_HEIGHT, LARGE_INNER_HEIGHT = ...;
end

function MOD:InitializeActive()
	local active = CreateFrame("Frame", nil, self.Docklet)
    active:SetPoint("TOPLEFT", self.Docklet, "TOPLEFT");
    active:SetPoint("TOPRIGHT", self.Docklet, "TOPRIGHT");
    active:SetHeight(1);

	local block = CreateFrame("Frame", nil, active)
	block:SetPoint("TOPLEFT", active, "TOPLEFT", 2, -4);
	block:SetPoint("TOPRIGHT", active, "TOPRIGHT", -2, -4);
	block:SetHeight(LARGE_INNER_HEIGHT);

	block.Button = CreateFrame("Button", nil, block)
	block.Button:SetPoint("TOPLEFT", block, "TOPLEFT", 0, 0);
	block.Button:SetPoint("BOTTOMRIGHT", block, "BOTTOMRIGHT", 0, 8);
	block.Button:SetStyle("DockButton", "Transparent")
	--block.Button:SetBackdropBorderColor(0, 0.9, 0, 0.5)
	block.Button.LogID = 0
	block.Button.Parent = active;
	block.Button:SetScript("OnClick", ViewButton_OnClick)
	block.Button:SetScript("OnEnter", ActiveButton_OnEnter)
	block.Button:SetScript("OnLeave", ActiveButton_OnLeave)

	block.CloseButton = CreateFrame("Button", nil, block.Button, "UIPanelCloseButton")
	block.CloseButton:RemoveTextures()
	block.CloseButton:SetStyle("Button", -7, -7, "red")
	block.CloseButton:SetFrameLevel(block.Button:GetFrameLevel() + 4)
	block.CloseButton:SetNormalTexture(SV.media.icon.close)
  	block.CloseButton:HookScript("OnEnter", CloseButton_OnEnter)
  	block.CloseButton:HookScript("OnLeave", CloseButton_OnLeave)
	block.CloseButton:SetPoint("TOPRIGHT", block.Button, "TOPRIGHT", 4, 4);
	block.CloseButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	block.CloseButton.Parent = active;
	block.CloseButton:SetScript("OnClick", ActiveButton_OnClick)

	block.Badge = CreateFrame("Frame", nil, block.Button)
	block.Badge:SetPoint("TOPLEFT", block.Button, "TOPLEFT", 4, -4);
	block.Badge:SetSize((LARGE_INNER_HEIGHT - 4), (LARGE_INNER_HEIGHT - 4));
	block.Badge:SetStyle("!_Frame", "Inset")

	block.Badge.Icon = block.Badge:CreateTexture(nil,"OVERLAY")
	block.Badge.Icon:InsetPoints(block.Badge);
	block.Badge.Icon:SetTexture(MOD.media.incompleteIcon)
	block.Badge.Icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))

	-- block.Badge.Button = CreateFrame("Button", nil, UIParent, "SecureActionButtonTemplate")
	-- local bX,bY = block.Badge:GetCenter()
	-- block.Badge.Button:SetPoint("CENTER", UIParent, "CENTER", bX,bY);
	-- block.Badge.Button:SetStyle("LiteButton")
	-- block.Badge.Button.LogID = 0
	-- block.Badge.Button:SetFrameLevel(999);
	-- block.Badge.Button.Icon = block.Badge.Icon;
	-- block.Badge.Button:SetAttribute("type", "macro")
	-- block.Badge.Button:SetScript('OnEvent', MacroButton_OnEvent);

	block.Header = CreateFrame("Frame", nil, block)
	block.Header:SetPoint("TOPLEFT", block.Badge, "TOPRIGHT", 4, 0);
	block.Header:SetPoint("TOPRIGHT", block.Button, "TOPRIGHT", -24, -4);
	block.Header:SetHeight(INNER_HEIGHT - 2);
	block.Header:SetStyle("Frame")

	block.Header.Level = block.Header:CreateFontString(nil,"OVERLAY")
	block.Header.Level:SetFontObject(SVUI_Font_Quest);
	block.Header.Level:SetJustifyH('LEFT')
	block.Header.Level:SetText('')
	block.Header.Level:SetPoint("TOPLEFT", block.Header, "TOPLEFT", 4, 0);
	block.Header.Level:SetPoint("BOTTOMLEFT", block.Header, "BOTTOMLEFT", 4, 0);

	block.Header.Text = block.Header:CreateFontString(nil,"OVERLAY")
	block.Header.Text:SetFontObject(SVUI_Font_Quest);
	block.Header.Text:SetJustifyH('LEFT')
	block.Header.Text:SetTextColor(1,1,0)
	block.Header.Text:SetText('')
	block.Header.Text:SetPoint("TOPLEFT", block.Header.Level, "TOPRIGHT", 4, 0);
	block.Header.Text:SetPoint("BOTTOMRIGHT", block.Header, "BOTTOMRIGHT", 0, 0);

	block.Details = CreateFrame("Frame", nil, block.Header)
	block.Details:SetPoint("TOPLEFT", block.Header, "BOTTOMLEFT", 0, -2);
	block.Details:SetPoint("TOPRIGHT", block.Header, "BOTTOMRIGHT", 0, -2);

	if(SV.AddQuestCompass) then
		block.Details:SetHeight(INNER_HEIGHT - 4);
		SV:AddQuestCompass(block, block.Badge)
		block.Badge.Compass.Range:ClearAllPoints()
		block.Badge.Compass.Range:SetPoint("TOPLEFT", block.Details, "TOPLEFT", 4, 0);
		block.Badge.Compass.Range:SetPoint("BOTTOMLEFT", block.Details, "BOTTOMLEFT", 4, 0);
		block.Badge.Compass.Range:SetJustifyH("LEFT");
	else
		block.Details:SetHeight(1);
	end

	block.Objectives = MOD.NewObjectiveHeader(block);
	block.Objectives:SetPoint("TOPLEFT", block.Details, "BOTTOMLEFT", 0, -2);
	block.Objectives:SetPoint("TOPRIGHT", block.Details, "BOTTOMRIGHT", 0, -2);
	block.Objectives:SetHeight(1);

	active.Block = block;

	active.ActiveQuestID = 0;
	active.Set = SetActiveData;
	active.Unset = UnsetActiveData;
	active.Refresh = RefreshActiveObjective;
	active.RefreshHeight = RefreshActiveHeight;

	self.Headers["Active"] = active;

	self.Headers["Active"]:RefreshHeight()

	self.ActiveQuestID = self.Headers["Active"].ActiveQuestID;

	self:RegisterEvent("SUPER_TRACKED_QUEST_CHANGED", self.UpdateActiveObjective);

	SV.Events:On("QUEST_UPVALUES_UPDATED", UpdateActiveLocals, true);
end
