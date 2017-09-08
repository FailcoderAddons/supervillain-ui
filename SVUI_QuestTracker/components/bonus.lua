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
local pairs     = _G.pairs;
local ipairs    = _G.ipairs;
local type      = _G.type;
local error     = _G.error;
local pcall     = _G.pcall;
local tostring  = _G.tostring;
local tonumber  = _G.tonumber;
local tinsert 	= _G.tinsert;
local tDeleteItem = _G.tDeleteItem;
local string 	= _G.string;
local math 		= _G.math;
local table 	= _G.table;
--[[ STRING METHODS ]]--
local format = string.format;
--[[ MATH METHODS ]]--
local abs, ceil, floor, round = math.abs, math.ceil, math.floor, math.round;
--[[ TABLE METHODS ]]--
local tremove, twipe = table.remove, table.wipe;
--[[
##########################################################
GET ADDON DATA
##########################################################
]]--
local SV = _G['SVUI']
local L = SV.L
local LSM = _G.LibStub("LibSharedMedia-3.0")
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
local OBJ_ICON_ACTIVE = [[Interface\COMMON\Indicator-Yellow]];
local OBJ_ICON_COMPLETE = [[Interface\COMMON\Indicator-Green]];
local OBJ_ICON_INCOMPLETE = [[Interface\COMMON\Indicator-Gray]];
local CACHED_BONUS_DATA = {};
local COMPLETED_BONUS_DATA = {};
--[[
##########################################################
DATA CACHE HANDLERS
##########################################################
]]--
local function CacheBonusData(questID, xp, money)
	if(not questID or (questID and questID <= 0)) then return; end

	local data = {};
	data.objectives = {};
	local isInArea, isOnMap, numObjectives = GetTaskInfo(questID);
	local iscomplete = true;

	if(numObjectives and (type(numObjectives) == "number") and numObjectives > 0) then
		for objectiveIndex = 1, numObjectives do
			local text, objectiveType, finished = GetQuestObjectiveInfo(questID, objectiveIndex, true);
			if not finished then iscomplete = false end
			tinsert(data.objectives, text);
			data.objectiveType = objectiveType;
		end
	end

	data.rewards = {};
	if(not xp) then
		xp = GetQuestLogRewardXP(questID);
	end
	if(xp > 0 and UnitLevel("player") < MAX_PLAYER_LEVEL) then
		local t = {};
		t.label = xp;
		t.texture = "Interface\\Icons\\XP_Icon";
		t.count = 0;
		t.font = "NumberFontNormal";
		tinsert(data.rewards, t);
	end

	local numCurrencies = GetNumQuestLogRewardCurrencies(questID);
	for i = 1, numCurrencies do
		local name, texture, count = GetQuestLogRewardCurrencyInfo(i, questID);
		local t = {};
		t.label = name;
		t.texture = texture;
		t.count = count;
		t.font = "GameFontHighlightSmall";
		tinsert(data.rewards, t);
	end

	local numItems = GetNumQuestLogRewards(questID);
	for i = 1, numItems do
		local name, texture, count, quality, isUsable = GetQuestLogRewardInfo(i, questID);
		local t = {};
		t.label = name;
		t.texture = texture;
		t.count = count;
		t.font = "GameFontHighlightSmall";
		tinsert(data.rewards, t);
	end

	if(not money) then
		money = GetQuestLogRewardMoney(questID);
	end
	if(money > 0) then
		local t = {};
		t.label = GetMoneyString(money);
		t.texture = "Interface\\Icons\\inv_misc_coin_01";
		t.count = 0;
		t.font = "GameFontHighlight";
		tinsert(data.rewards, t);
	end
	CACHED_BONUS_DATA[questID] = data;

	if(iscomplete or #data.rewards <= 0) then
		CACHED_BONUS_DATA[questID] = nil;
		COMPLETED_BONUS_DATA[questID] = true;
		PlaySound(SOUNDKIT.UI_SCENARIO_STAGE_END);
	end
end

local function GetBonusCache()
	local cache = GetTasksTable();
	for questID, data in pairs(CACHED_BONUS_DATA) do
		if(questID > 0) then
			local found = false;
			for i = 1, #cache do
				if(cache[i] == questID) then
					found = true;
					break;
				end
			end
			if(not found) then
				tinsert(cache, questID);
			end
		end
	end
	return cache;
end

local function GetCachedTaskInfo(questID)
	if(CACHED_BONUS_DATA[questID]) then
		return true, true, #CACHED_BONUS_DATA[questID].objectives;
	else
		return GetTaskInfo(questID);
	end
end

local function GetCachedQuestObjectiveInfo(questID, objectiveIndex)
	if(CACHED_BONUS_DATA[questID]) then
		return CACHED_BONUS_DATA[questID].objectives[objectiveIndex], CACHED_BONUS_DATA[questID].objectiveType, true;
	else
		return GetQuestObjectiveInfo(questID, objectiveIndex, false);
	end
end

local function GetScenarioBonusStep(index)
	local cachedObjectives = C_Scenario.GetSupersededObjectives();
	for i = 1, #cachedObjectives do
		local pairs = cachedObjectives[i];
		local k,v = unpack(pairs);
		if(v == index) then
			return k;
		end
	end
end
--[[
##########################################################
TRACKER FUNCTIONS
##########################################################
]]--
local GetBonusRow = function(self, index)
	if(not self.Rows[index]) then
		local previousFrame = self.Rows[#self.Rows]
		local index = #self.Rows + 1;
		local yOffset = 0;

		local row = CreateFrame("Frame", nil, self)
		if(previousFrame and previousFrame.Objectives) then
			row:SetPoint("TOPLEFT", previousFrame.Objectives, "BOTTOMLEFT", 0, -6);
			row:SetPoint("TOPRIGHT", previousFrame.Objectives, "BOTTOMRIGHT", 0, -6);
		else
			row:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0);
			row:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 0);
		end
		row:SetHeight(ROW_HEIGHT);

		row.Header = CreateFrame("Frame", nil, row)
		row.Header:SetPoint("TOPLEFT", row, "TOPLEFT", 2, -2);
		row.Header:SetPoint("TOPRIGHT", row, "TOPRIGHT", -2, -2);
		row.Header:SetHeight(INNER_HEIGHT);

		row.Header.Text = row.Header:CreateFontString(nil,"OVERLAY")
		row.Header.Text:SetFontObject(SVUI_Font_Quest_Header);
		row.Header.Text:SetJustifyH('LEFT')
		row.Header.Text:SetTextColor(0.2,0.75,1)
		row.Header.Text:SetText('')
		row.Header.Text:SetPoint("TOPLEFT", row.Header, "TOPLEFT", 0, 0);
		row.Header.Text:SetPoint("BOTTOMRIGHT", row.Header, "BOTTOMRIGHT", 0, 0);

		row.Objectives = MOD.NewObjectiveHeader(row);
		row.Objectives:SetPoint("TOPLEFT", row, "BOTTOMLEFT", 0, 0);
		row.Objectives:SetPoint("TOPRIGHT", row, "BOTTOMRIGHT", 0, 0);
		row.Objectives:SetHeight(1);

		row.RowID = 0;

		self.Rows[index] = row;

		return row;
	end

	return self.Rows[index];
end

local SetCriteriaRow = function(self, index, bonusStepIndex, subCount, hasFailed)
	index = index + 1
	local objective_rows = 0;
	local fill_height = 0;
	local iscomplete = true;

	local row = self:Get(index);
	row.RowID = 0
	row.Header.Text:SetText(TRACKER_HEADER_BONUS_OBJECTIVES)
	row:SetHeight(ROW_HEIGHT);
	row:SetAlpha(1);

	local objective_block = row.Objectives;
	objective_block:Reset()

	for i = 1, subCount do
		local text, category, completed, quantity, totalQuantity, flags, assetID, quantityString, criteriaID, duration, elapsed, failed = C_Scenario.GetCriteriaInfoByStep(bonusStepIndex, i);
		if(text and text ~= '') then
			if not completed then iscomplete = false end
			objective_rows = objective_block:SetInfo(objective_rows, text, completed, failed);
			fill_height = fill_height + (INNER_HEIGHT + 2);
			if(duration > 0 and elapsed <= duration and not (failed or completed)) then
				objective_rows = objective_block:SetTimer(objective_rows, duration, elapsed);
				fill_height = fill_height + (INNER_HEIGHT + 2);
			end
		end
	end

	if(hasFailed) then
		row.Header.Text:SetTextColor(1,0,0)
	elseif(iscomplete) then
		row.Header.Text:SetTextColor(0.1,0.9,0.1)
	else
		row.Header.Text:SetTextColor(1,1,1)
	end

	if(objective_rows > 0) then
		objective_block:SetHeight(fill_height);
	end

	fill_height = fill_height + (ROW_HEIGHT + 2);

	return index, fill_height;
end

local SetBonusRow = function(self, index, questID, subCount)
	index = index + 1
	local objective_rows = 0;
	local fill_height = 0;
	local iscomplete = true;
	local row = self:Get(index);
	local objective_block = row.Objectives;

	for i = 1, subCount do
		local text, category, objective_completed = GetCachedQuestObjectiveInfo(questID, i);
		if not objective_completed then iscomplete = false end
		if(text and text ~= '') then
			objective_rows = objective_block:SetInfo(objective_rows, text, objective_completed);
			fill_height = fill_height + (INNER_HEIGHT + 2);
		end
		if(category and category == 'progressbar') then
			objective_rows = objective_block:SetProgress(objective_rows, questID, objective_completed);
			fill_height = fill_height + (INNER_HEIGHT + 2);
		end
	end

	if(not iscomplete) then
		row.RowID = questID
		row.Header.Text:SetText(TRACKER_HEADER_BONUS_OBJECTIVES)
		row:SetHeight(ROW_HEIGHT);
		row:FadeIn();

		if(objective_rows > 0) then
			objective_block:SetHeight(fill_height);
		end

		fill_height = fill_height + (ROW_HEIGHT + 2);

		return index, fill_height;
	else
		CACHED_BONUS_DATA[questID] = nil;
		COMPLETED_BONUS_DATA[questID] = true;
		PlaySound(45142);
		--PlaySoundKitID(45142);
		return index, 0;
	end
end

local UpdateBonusObjectives = function(self)
	local fill_height = 0;
	local rows = 0;

	if(C_Scenario.IsInScenario()) then
		local tblBonusSteps = C_Scenario.GetBonusSteps();
		local cachedToRemove = {};
		for i = 1, #tblBonusSteps do
			local bonusStepIndex = tblBonusSteps[i];
			local cachedIndex = GetScenarioBonusStep(bonusStepIndex);
			if(cachedIndex) then
				local name, description, numCriteria, stepFailed, isBonusStep, isForCurrentStepOnly = C_Scenario.GetStepInfo(bonusStepIndex);
				local completed = true;
				for criteriaIndex = 1, numCriteria do
					local criteriaString, criteriaType, criteriaCompleted, quantity, totalQuantity, flags, assetID, quantityString, criteriaID, duration, elapsed, criteriaFailed = C_Scenario.GetCriteriaInfoByStep(bonusStepIndex, criteriaIndex);
					if(criteriaString) then
						if(not criteriaCompleted) then
							completed = false;
							break;
						end
					end
				end
				if(not completed) then
					tinsert(cachedToRemove, cachedIndex);
				end
			end
		end
		for i = 1, #cachedToRemove do
			tDeleteItem(tblBonusSteps, cachedToRemove[i]);
		end

		for i = 1, #tblBonusSteps do
			local bonusStepIndex = tblBonusSteps[i];
			local name, description, numCriteria, stepFailed, isBonusStep, isForCurrentStepOnly = C_Scenario.GetStepInfo(bonusStepIndex);
			local add_height = 0;
			rows, add_height = self:SetCriteria(rows, bonusStepIndex, numCriteria, stepFailed)
			fill_height = fill_height + add_height;
		end
	else
		local cache = GetBonusCache();
		for i = 1, #cache do
			local questID = cache[i];
			local completedData = COMPLETED_BONUS_DATA[questID];
			if(not completedData) then
				local existingTask = CACHED_BONUS_DATA[questID];
				local isInArea, isOnMap, numObjectives = GetCachedTaskInfo(questID);
				if(isInArea or (isOnMap and existingTask)) then
					local add_height = 0;
					rows, add_height = self:SetBonus(rows, questID, numObjectives)
					fill_height = fill_height + add_height;
				end
			end
		end
	end

	if(rows == 0 or (fill_height <= 1)) then
		self:SetHeight(1);
		self:SetAlpha(0);
		self:Reset();
	else
		self:SetHeight(fill_height + 2);
		self:FadeIn();
	end
end

local RefreshBonusObjectives = function(self, event, ...)
	-- print('BONUS-------->')
	-- print(event)
	-- print(...)
	if(event == "CRITERIA_COMPLETE") then
		local id = ...;
		if(id > 0) then
			local tblBonusSteps = C_Scenario.GetBonusSteps();
			for i = 1, #tblBonusSteps do
				local bonusStepIndex = tblBonusSteps[i];
				local _, _, numCriteria = C_Scenario.GetStepInfo(bonusStepIndex);
				for criteriaIndex = 1, numCriteria do
					local _, _, _, _, _, _, _, _, criteriaID = C_Scenario.GetCriteriaInfoByStep(bonusStepIndex, criteriaIndex);
					if(id == criteriaID) then
						local questID = C_Scenario.GetBonusStepRewardQuestID(bonusStepIndex);
						if(questID ~= 0) then
							CacheBonusData(questID);
							return;
						end
					end
				end
			end
		end
	end
	self:UpdateAll();
end

local ResetBonusBlock = function(self)
	for x = 1, #self.Rows do
		local row = self.Rows[x]
		if(row) then
			row.RowID = 0;
			row.Header.Text:SetText('');
			row:SetHeight(1);
			row:SetAlpha(0);
			row.Objectives:Reset();
		end
	end
end
--[[
##########################################################
CORE FUNCTIONS
##########################################################
]]--
function MOD:UpdateBonusObjective(event, ...)
	self.Headers["Bonus"]:Reset()
	self.Headers["Bonus"]:Refresh(event, ...)
	self:UpdateDimensions();
end

function MOD:CacheBonusObjective(event, ...)
	CacheBonusData(...)
end

local function UpdateBonusLocals(...)
	ROW_WIDTH, ROW_HEIGHT, INNER_HEIGHT, LARGE_ROW_HEIGHT, LARGE_INNER_HEIGHT = ...;
end

function MOD:InitializeBonuses()
	local scrollChild = self.Docklet.ScrollFrame.ScrollChild;
	local bonus = CreateFrame("Frame", nil, scrollChild)
	bonus:SetWidth(ROW_WIDTH);
	bonus:SetHeight(1);
	bonus:SetPoint("TOPLEFT", self.Headers["Scenario"], "BOTTOMLEFT", 0, -4);

	bonus.Rows = {};

	bonus.Get = GetBonusRow;
	bonus.SetBonus = SetBonusRow;
	bonus.SetCriteria = SetCriteriaRow;
	bonus.Refresh = RefreshBonusObjectives;
	bonus.Reset = ResetBonusBlock;
	bonus.UpdateAll = UpdateBonusObjectives;

	self.Headers["Bonus"] = bonus

	self:RegisterEvent("CRITERIA_COMPLETE", self.UpdateBonusObjective);
	SV.Events:On("QUEST_UPVALUES_UPDATED", UpdateBonusLocals, true);
end
