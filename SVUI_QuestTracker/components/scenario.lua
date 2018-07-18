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
local string 	= _G.string;
local math 		= _G.math;
local table 	= _G.table;
--[[ STRING METHODS ]]--
local format = string.format;
--[[ MATH METHODS ]]--
local abs, ceil, floor, round = math.abs, math.ceil, math.floor, math.round;
--[[ TABLE METHODS ]]--
local tremove, twipe = table.remove, table.wipe;
--BLIZZARD API
local CreateFrame           = _G.CreateFrame;
local InCombatLockdown      = _G.InCombatLockdown;
local GameTooltip           = _G.GameTooltip;
local hooksecurefunc        = _G.hooksecurefunc;
local IsAltKeyDown          = _G.IsAltKeyDown;
local IsShiftKeyDown        = _G.IsShiftKeyDown;
local IsControlKeyDown      = _G.IsControlKeyDown;
local IsModifiedClick       = _G.IsModifiedClick;
local PlaySound             = _G.PlaySound;
local PlaySoundKitID        = _G.PlaySoundKitID;
local GetTime               = _G.GetTime;
local C_Scenario            = _G.C_Scenario;
local GetWorldElapsedTimers = _G.GetWorldElapsedTimers;
local GetInstanceInfo 		= _G.GetInstanceInfo;
local GetWorldElapsedTime 	= _G.GetWorldElapsedTime;
local GetTimeStringFromSeconds	= _G.GetTimeStringFromSeconds;
local GetChallengeModeMapTimes 	= _G.GetChallengeModeMapTimes;
local GENERIC_FRACTION_STRING 	= _G.GENERIC_FRACTION_STRING;
local CHALLENGE_MEDAL_GOLD   	= _G.CHALLENGE_MEDAL_GOLD;
local CHALLENGE_MEDAL_SILVER    = _G.CHALLENGE_MEDAL_SILVER;
local CHALLENGE_MEDAL_TEXTURES  = _G.CHALLENGE_MEDAL_TEXTURES;
local CHALLENGE_MODE_COMPLETE_TIME_EXPIRED = _G.CHALLENGE_MODE_COMPLETE_TIME_EXPIRED;
local LE_WORLD_ELAPSED_TIMER_TYPE_CHALLENGE_MODE = _G.LE_WORLD_ELAPSED_TIMER_TYPE_CHALLENGE_MODE;
local LE_WORLD_ELAPSED_TIMER_TYPE_PROVING_GROUND = _G.LE_WORLD_ELAPSED_TIMER_TYPE_PROVING_GROUND;
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
local LINE_FAILED_ICON = [[Interface\ICONS\Ability_Blackhand_Marked4Death]];
local LINE_SCENARIO_ICON = [[Interface\ICONS\Icon_Scenarios]];
local LINE_CHALLENGE_ICON = [[Interface\ICONS\Achievement_ChallengeMode_Platinum]];
--[[
##########################################################
SCRIPT HANDLERS
##########################################################
]]--
local TimerBar_OnUpdate = function(self, elapsed)
	local statusbar = self.Bar
	statusbar.elapsed = statusbar.elapsed + elapsed;
	local currentTime = statusbar.duration - statusbar.elapsed
	local timeString = GetTimeStringFromSeconds(currentTime)
	local r,g,b = MOD:GetTimerTextColor(statusbar.duration, statusbar.elapsed)
	if(statusbar.elapsed <= statusbar.duration) then
		statusbar:SetValue(currentTime);
		statusbar.TimeLeft:SetText(timeString);
		statusbar.TimeLeft:SetTextColor(r,g,b);
	else
		self:StopTimer()
	end
end
--[[
##########################################################
TRACKER FUNCTIONS
##########################################################
]]--
local SetScenarioData = function(self, title, stageName, currentStage, numStages, stageDescription, numObjectives)
	local objective_rows = 0;
	local fill_height = 0;
	local block = self.Block;
    local mythic_txt = ""

	block.HasData = true;
    local _, _, difficulty, _, _, _, _, mapID = GetInstanceInfo();

	if (difficulty == 8) then
        local cmLevel, affixes, empowered = C_ChallengeMode.GetActiveKeystoneInfo();
        local bonus = C_ChallengeMode.GetPowerLevelDamageHealthMod(cmLevel);

        cmLevel, affixes, empowered = C_ChallengeMode.GetActiveKeystoneInfo();

        for _, affixID in ipairs(affixes) do
            local affixName, affixDesc, _ = C_ChallengeMode.GetAffixInfo(affixID);
            mythic_txt = mythic_txt.." - "..affixName;
        end
		block.Header.Stage:SetText("|cFFFFFF00"..title .. ' +' .. cmLevel .. "|cFFFFFFFF" .. mythic_txt)
		
    elseif (currentStage ~= 0) then
		block.Header.Stage:SetText('Stage ' .. currentStage .. ' - ' .. "|cFFFFFF00"..title)
	else
		block.Header.Stage:SetText('')
		block.Header.Stage:SetText("|cFFFFFF00"..title)
	end
	block.Icon:SetTexture(LINE_SCENARIO_ICON)


    local objective_block = block.Objectives;
	for i = 1, numObjectives do
		local description, criteriaType, completed, quantity, totalQuantity, flags, assetID, quantityString, criteriaID, duration, elapsed, failed, kills = C_Scenario.GetCriteriaInfo(i);
		if(duration > 0 and elapsed <= duration and not (failed or completed)) then
			objective_rows = objective_block:SetTimer(objective_rows, duration, elapsed);
			fill_height = fill_height + (INNER_HEIGHT + 2);
		end
		if(description and description ~= '') then
			objective_rows = objective_block:SetInfo(objective_rows, description, completed, failed);
			fill_height = fill_height + (INNER_HEIGHT + 2);
		end		
	end

	local timerHeight = self.Timer:GetHeight()

	if(objective_rows > 0) then

		objective_block:SetHeight(fill_height);
		objective_block:FadeIn();
    end



	fill_height = fill_height + (LARGE_ROW_HEIGHT + 2) + timerHeight;
	block:SetHeight(fill_height);

	MOD.Docklet.ScrollFrame.ScrollBar:SetValue(0)
end

local UnsetScenarioData = function(self)
	local block = self.Block;
	block:SetHeight(1);
	block.Header.Text:SetText('');
	block.Header.Stage:SetText('');
	block.Icon:SetTexture(LINE_SCENARIO_ICON);
	block.HasData = false;
	block.Objectives:Reset()
	self:SetHeight(1);
	self:SetAlpha(0);
end

local RefreshScenarioHeight = function(self)
	if(not self.Block.HasData) then
		self:Unset();
	else
		local h1 = self.Timer:GetHeight()
		local h2 = self.Block:GetHeight()
		self:SetHeight(h1 + h2 + 2);
		self:FadeIn();
	end
end
--[[
##########################################################
TIMER FUNCTIONS
##########################################################
]]--
local MEDAL_TIMES = {};
local LAST_MEDAL;

local StartTimer = function(self, elapsed, duration, medalIndex, currWave, maxWave)
	self:SetHeight(INNER_HEIGHT);
	self:FadeIn();
	self.Bar.duration = duration or 1;
	self.Bar.elapsed = elapsed or 0;
	self.Bar:SetMinMaxValues(0, self.Bar.duration);
	self.Bar:SetValue(self.Bar.elapsed);
	self:SetScript("OnUpdate", TimerBar_OnUpdate);
	local blockHeight = MOD.Headers["Scenario"].Block:GetHeight();
	MOD.Headers["Scenario"].Block:SetHeight(blockHeight + INNER_HEIGHT + 4);

	if (medalIndex < 4) then
		self.Bar.Wave:SetFormattedText(GENERIC_FRACTION_STRING, currWave, maxWave);
	else
		self.Bar.Wave:SetText(currWave);
	end
end

local StopTimer = function(self)
	local timerHeight = self:GetHeight();
	self:SetHeight(1);
	self:SetAlpha(0);
	self.Bar.duration = 1;
	self.Bar.elapsed = 0;
	self.Bar:SetMinMaxValues(0, self.Bar.duration);
	self.Bar:SetValue(0);
	self:SetScript("OnUpdate", nil);
	local blockHeight = MOD.Headers["Scenario"].Block:GetHeight();
	MOD.Headers["Scenario"].Block:SetHeight((blockHeight - timerHeight) + 1);
end

local SetChallengeMedals = function(self, elapsedTime, maxTime)
	self:SetHeight(INNER_HEIGHT);
	local blockHeight = MOD.Headers["Scenario"].Block:GetHeight();
	local cmID = C_ChallengeMode.GetActiveChallengeMapID();
	MOD.Headers["Scenario"].Block:SetHeight(blockHeight + INNER_HEIGHT + 4);
	self:FadeIn();
	self.Bar.timeLimit = maxTime;
	self.Bar:SetMinMaxValues(0, maxTime);
	self.Bar:SetValue(elapsedTime);

	if(cmID) then
		MEDAL_TIMES[1] = maxTime * 0.6; -- 3 chest
		MEDAL_TIMES[2] = maxTime * 0.8; -- 2 chest
		MEDAL_TIMES[3] = maxTime -- 1 chest
	else
		for i = 1, select("#", maxTime) do
			MEDAL_TIMES[i] = select(i, maxTime);
		end
	end
	LAST_MEDAL = nil;
	self:UpdateMedals(elapsedTime);
end

local UpdateChallengeMedals = function(self, elapsedTime)
	local prevMedalTime = 0;
	for i = #MEDAL_TIMES, 1, -1 do
		local currentMedalTime = MEDAL_TIMES[i];
		if ( elapsedTime < currentMedalTime ) then
			self.Bar:SetMinMaxValues(0, currentMedalTime - prevMedalTime);
			self.Bar.medalTime = currentMedalTime;
			if(CHALLENGE_MEDAL_TEXTURES[i]) then
				self.Icon:SetTexture(CHALLENGE_MEDAL_TEXTURES[i]);
			end
			if(LAST_MEDAL and LAST_MEDAL ~= i) then
				if(LAST_MEDAL == CHALLENGE_MEDAL_GOLD) then
					PlaySound(SOUNDKIT.UI_70_CHALLENGE_MODE_KEYSTONE_UPGRADE);
				elseif(LAST_MEDAL == CHALLENGE_MEDAL_SILVER) then
					PlaySound(SOUNDKIT.UI_70_CHALLENGE_MODE_KEYSTONE_UPGRADE);
				else
					PlaySound(SOUNDKIT.UI_70_CHALLENGE_MODE_COMPLETE_NO_UPGRADE);
				end
			end
			LAST_MEDAL = i;
			return;
		else
			prevMedalTime = currentMedalTime;
		end
	end

	self.Bar.TimeLeft:SetText(GetTimeStringFromSeconds(elapsedTime));
	self.Bar:SetValue(0);
	self.Bar.medalTime = nil;
	self:SetHeight(1)
	self.Icon:SetTexture(LINE_FAILED_ICON);

	if(LAST_MEDAL and LAST_MEDAL ~= 0) then
		PlaySound(SOUNDKIT.UI_70_CHALLENGE_MODE_COMPLETE_NO_UPGRADE);
	end

	LAST_MEDAL = 0;
end


local UpdateChallengeTimer = function(self, elapsedTime)
	local statusBar = self.Bar;
	if ( statusBar.medalTime ) then
		local timeLeft = statusBar.medalTime - elapsedTime;
		if (timeLeft == 10) then
			if (not statusBar.playedSound) then
				PlaySoundKitID(34154);
				statusBar.playedSound = true;
			end
		else
			statusBar.playedSound = false;
		end
		if(timeLeft < 0) then
			self:UpdateMedals(elapsedTime);
		else
			statusBar:SetValue(timeLeft);
			statusBar.TimeLeft:SetText(GetTimeStringFromSeconds(timeLeft));
		end
	end
end

local UpdateAllTimers = function(self, ...)
	for i = 1, select("#", ...) do
		local timerID = select(i, ...);
		local _, elapsedTime, type = GetWorldElapsedTime(timerID);
		if (type == LE_WORLD_ELAPSED_TIMER_TYPE_CHALLENGE_MODE) then
			local cmID = C_ChallengeMode.GetActiveChallengeMapID();
			if(cmID) then
				local _, _, maxTime = C_ChallengeMode.GetMapInfo(cmID);
				self:SetMedals(elapsedTime, maxTime);
				return;
			end
		elseif (type == LE_WORLD_ELAPSED_TIMER_TYPE_PROVING_GROUND) then
			local diffID, currWave, maxWave, duration = C_Scenario.GetProvingGroundsInfo()
			if (duration > 0) then
				self:StartTimer(elapsedTime, duration, diffID, currWave, maxWave)
				return;
			end
		end
	end
	--self:StopTimer()
end

local RefreshScenarioObjective = function(self, event, ...)
	local _, _, difficulty, _, _, _, _, _ = GetInstanceInfo();
	if(C_Scenario.IsInScenario()) then
		if(event == "PLAYER_ENTERING_WORLD") then
			self.Timer:UpdateTimers(GetWorldElapsedTimers());
		elseif(event == "WORLD_STATE_TIMER_START" or event ==  "CHALLENGE_MODE_START" or event ==  "CHALLENGE_MODE_RESET") then
			self.Timer:UpdateTimers(...)
			if (difficulty == 8) then
				self.Timer:SetScript("OnUpdate", UpdateAllTimers);
			end
		elseif(event == "WORLD_STATE_TIMER_STOP" or event ==  "CHALLENGE_MODE_COMPLETED") then
			self.Timer:StopTimer()
		elseif(event == "PROVING_GROUNDS_SCORE_UPDATE") then
			local score = ...
			self.Block.Header.Score:SetText(score);
		elseif(event == "SCENARIO_COMPLETED" or event == 'SCENARIO_UPDATE' or event == 'SCENARIO_CRITERIA_UPDATE') then
			if(event == "SCENARIO_COMPLETED") then
				self.Timer:StopTimer()
			else
				self.Block.Objectives:Reset()
				local title, currentStage, numStages, flags, _, _, _, xp, money = C_Scenario.GetInfo();
				if(title) then
					local stageName, stageDescription, numObjectives = C_Scenario.GetStepInfo();
					-- local inChallengeMode = bit.band(flags, SCENARIO_FLAG_CHALLENGE_MODE) == SCENARIO_FLAG_CHALLENGE_MODE;
					-- local inProvingGrounds = bit.band(flags, SCENARIO_FLAG_PROVING_GROUNDS) == SCENARIO_FLAG_PROVING_GROUNDS;
					-- local dungeonDisplay = bit.band(flags, SCENARIO_FLAG_USE_DUNGEON_DISPLAY) == SCENARIO_FLAG_USE_DUNGEON_DISPLAY;
					local scenariocompleted = currentStage > numStages;
					if(not scenariocompleted) then
						self:Set(title, stageName, currentStage, numStages, stageDescription, numObjectives)
						if(currentStage > 1) then
							PlaySound(PlaySoundKitID and "UI_Scenario_Stage_End" or 31757);
						end
					else
						self.Timer:StopTimer()
						self.Block.HasData = false
					end
				end
			end
		end
	else
		self.Timer:StopTimer()
		self.Block.HasData = false
	end

	self:RefreshHeight()
end

--[[
##########################################################
CORE FUNCTIONS
##########################################################
]]--
function MOD:UpdateScenarioObjective(event, ...)
	self.Headers["Scenario"]:Refresh(event, ...)
	self:UpdateDimensions();
end

local function UpdateScenarioLocals(...)
	ROW_WIDTH, ROW_HEIGHT, INNER_HEIGHT, LARGE_ROW_HEIGHT, LARGE_INNER_HEIGHT = ...;
end

function MOD:InitializeScenarios()
	local scrollChild = self.Docklet.ScrollFrame.ScrollChild;

	local scenario = CreateFrame("Frame", nil, scrollChild)
	scenario:SetHeight(ROW_HEIGHT);
	scenario:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, 0);
	scenario:SetPoint("TOPRIGHT", scrollChild, "TOPRIGHT", 0, 0);

	scenario.Set = SetScenarioData;
	scenario.Unset = UnsetScenarioData;
	scenario.Refresh = RefreshScenarioObjective;
	scenario.RefreshHeight = RefreshScenarioHeight;

	local block = CreateFrame("Frame", nil, scenario)
	block:SetPoint("TOPLEFT", scenario, "TOPLEFT", 2, -2);
	block:SetPoint("TOPRIGHT", scenario, "TOPRIGHT", -2, -2);
	block:SetHeight(1);
	block:SetStyle("Frame", "Lite");

	block.Badge = CreateFrame("Frame", nil, block)
	block.Badge:SetPoint("TOPLEFT", block, "TOPLEFT", 4, -4);
	block.Badge:SetSize((LARGE_INNER_HEIGHT - 4), (LARGE_INNER_HEIGHT - 4));
	block.Badge:SetStyle("!_Frame", "Inset")

	block.Icon = block.Badge:CreateTexture(nil,"OVERLAY")
	block.Icon:InsetPoints(block.Badge);
	block.Icon:SetTexture(LINE_SCENARIO_ICON)
	block.Icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))

	block.Header = CreateFrame("Frame", nil, block)
	block.Header:SetPoint("TOPLEFT", block.Badge, "TOPRIGHT", 4, -1);
	block.Header:SetPoint("TOPRIGHT", block, "TOPRIGHT", -4, 0);
	block.Header:SetHeight(INNER_HEIGHT);
	block.Header:SetStyle("Frame")

	block.Header.Stage = block.Header:CreateFontString(nil,"OVERLAY")
	block.Header.Stage:SetFontObject(SVUI_Font_Quest);
	block.Header.Stage:SetJustifyH('LEFT')
	block.Header.Stage:SetText('')
	block.Header.Stage:SetPoint("TOPLEFT", block.Header, "TOPLEFT", 4, 0);
	block.Header.Stage:SetPoint("BOTTOMLEFT", block.Header, "BOTTOMLEFT", 4, 0);

	block.Header.Score = block.Header:CreateFontString(nil,"OVERLAY")
	block.Header.Score:SetFontObject(SVUI_Font_Quest);
	block.Header.Score:SetJustifyH('RIGHT')
	block.Header.Score:SetTextColor(1,1,0)
	block.Header.Score:SetText('')
	block.Header.Score:SetPoint("TOPRIGHT", block.Header, "TOPRIGHT", -2, 0);
	block.Header.Score:SetPoint("BOTTOMRIGHT", block.Header, "BOTTOMRIGHT", -2, 0);

	block.Header.Text = block.Header:CreateFontString(nil,"OVERLAY")
	block.Header.Text:SetFontObject(SVUI_Font_Quest);
	block.Header.Text:SetTextColor(1,1,0)
	block.Header.Text:SetText('')
	block.Header.Text:SetPoint("TOPLEFT", block.Header.Stage, "TOPRIGHT", 4, 0);
	block.Header.Text:SetPoint("BOTTOMRIGHT", block.Header.Score, "BOTTOMRIGHT", 0, 0);

	local timer = CreateFrame("Frame", nil, block.Header)
	timer:SetPoint("TOPLEFT", block.Header, "BOTTOMLEFT", 4, -4);
	timer:SetPoint("TOPRIGHT", block.Header, "BOTTOMRIGHT", -4, -4);
	timer:SetHeight(INNER_HEIGHT);
	timer:SetStyle("!_Frame", "Bar");

	timer.StartTimer = StartTimer;
	timer.StopTimer = StopTimer;
	timer.UpdateTimers = UpdateAllTimers;
	timer.SetMedals = SetChallengeMedals;
	timer.UpdateMedals = UpdateChallengeMedals;
	timer.UpdateChallenges = UpdateChallengeTimer;

	timer.Bar = CreateFrame("StatusBar", nil, timer);
	timer.Bar:SetAllPoints(timer);
	timer.Bar:SetStatusBarTexture(SV.media.statusbar.default)
	timer.Bar:SetStatusBarColor(0.5,0,1) --1,0.15,0.08
	timer.Bar:SetMinMaxValues(0, 1)
	timer.Bar:SetValue(0)

	timer.Bar.Wave = timer.Bar:CreateFontString(nil,"OVERLAY")
	timer.Bar.Wave:SetPoint("TOPLEFT", timer.Bar, "TOPLEFT", 4, 0);
	timer.Bar.Wave:SetPoint("BOTTOMLEFT", timer.Bar, "BOTTOMLEFT", 4, 0);
	timer.Bar.Wave:SetFontObject(SVUI_Font_Quest);
	timer.Bar.Wave:SetJustifyH('LEFT')
	timer.Bar.Wave:SetTextColor(1,1,0)
	timer.Bar.Wave:SetText('')

	timer.Bar.TimeLeft = timer.Bar:CreateFontString(nil,"OVERLAY");
	timer.Bar.TimeLeft:SetPoint("TOPLEFT", timer.Bar, "TOPRIGHT", 4, -4);
	timer.Bar.TimeLeft:SetFontObject(SVUI_Font_Quest_Number);
	timer.Bar.TimeLeft:SetTextColor(1,1,1)
	timer.Bar.TimeLeft:SetText('')

	timer.Icon = block.Icon;
	timer:SetHeight(1);
	timer:SetAlpha(0)


	block.Objectives = MOD.NewObjectiveHeader(block);
	block.Objectives:SetPoint("TOPLEFT", timer, "BOTTOMLEFT", -4, -4);
	block.Objectives:SetPoint("TOPRIGHT", timer, "BOTTOMRIGHT", 4, -4);
	block.Objectives:SetHeight(1);

	block.HasData = false;

	scenario.Timer = timer;
	scenario.Block = block;

	self.Headers["Scenario"] = scenario;

	self.Headers["Scenario"]:RefreshHeight()

	self:RegisterEvent("PLAYER_ENTERING_WORLD", self.UpdateScenarioObjective);
	self:RegisterEvent("PROVING_GROUNDS_SCORE_UPDATE", self.UpdateScenarioObjective);
	self:RegisterEvent("WORLD_STATE_TIMER_START", self.UpdateScenarioObjective);
	self:RegisterEvent("WORLD_STATE_TIMER_STOP", self.UpdateScenarioObjective);
	self:RegisterEvent("SCENARIO_UPDATE", self.UpdateScenarioObjective);
	self:RegisterEvent("SCENARIO_CRITERIA_UPDATE", self.UpdateScenarioObjective);
	self:RegisterEvent("SCENARIO_COMPLETED", self.UpdateScenarioObjective);

	self:RegisterEvent("CHALLENGE_MODE_START", self.UpdateScenarioObjective);
	self:RegisterEvent("CHALLENGE_MODE_COMPLETED", self.UpdateScenarioObjective);
	self:RegisterEvent("CHALLENGE_MODE_RESET", self.UpdateScenarioObjective);


	SV.Events:On("QUEST_UPVALUES_UPDATED", UpdateScenarioLocals, true);
end
