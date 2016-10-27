--[[
##########################################################
S V U I   By: S.Jackson
##########################################################
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local unpack 	= _G.unpack;
local select 	= _G.select;
local type 		= _G.type;
local string    = _G.string;
local math 		= _G.math;
local table 	= _G.table;
local rept,format   = string.rep, string.format;
local tsort,twipe 	= table.sort, table.wipe;
local floor,ceil  	= math.floor, math.ceil;
local min 			= math.min
--BLIZZARD API
local CreateFrame           = _G.CreateFrame;
local InCombatLockdown      = _G.InCombatLockdown;
local GameTooltip           = _G.GameTooltip;
local hooksecurefunc        = _G.hooksecurefunc;
local IsSpellKnown      	= _G.IsSpellKnown;
local GetSpellInfo      	= _G.GetSpellInfo;
local GetProfessions      	= _G.GetProfessions;
local GetProfessionInfo     = _G.GetProfessionInfo;
local PlaySound             = _G.PlaySound;
local PlaySoundFile         = _G.PlaySoundFile;
--[[
##########################################################
GET ADDON DATA
##########################################################
]]--
local SV = _G.SVUI;
local L = SV.L;
local PLUGIN = select(2, ...);
local CONFIGS = SV.defaults[PLUGIN.Schema];
--[[
##########################################################
LOCAL VARS
##########################################################
]]--
local playerRace = select(2,UnitRace("player"))
local archSpell, survey, surveyIsKnown, skillRank, skillModifier;
local EnableListener, DisableListener;
local CanScanResearchSite = CanScanResearchSite
local GetNumArtifactsByRace = GetNumArtifactsByRace
local GetArchaeologyRaceInfo = GetArchaeologyRaceInfo
local GetSelectedArtifactInfo = GetSelectedArtifactInfo
local GetArtifactProgress = GetArtifactProgress
local CanSolveArtifact = CanSolveArtifact
local GetContainerNumSlots = GetContainerNumSlots
local GetContainerItemInfo = GetContainerItemInfo
local GetContainerItemID = GetContainerItemID
local ModeLogsFrame;

local ArchRaces = 0
local COUNT_TEX = [[Interface\AddOns\SVUI_!Core\assets\textures\Numbers\TYPE2\NUM]]
local refArtifacts = {};
local ArchCrafting = CreateFrame("Frame", "SVUI_ArchCrafting", UIParent)
local KEYSTONE_FORMAT = {"|cff00f12a%d|r/%d", "|cff00f12a%d|r|cff00a1fa/%d|r"};
local NORMAL_FORMAT = {"%d/%d", "|cff00a1fa%d/%d|r"};
--[[
##########################################################
DATA
##########################################################
]]--
PLUGIN.Archaeology = {};
PLUGIN.Archaeology.Bars = {};
PLUGIN.Archaeology.Loaded = false;
--[[
##########################################################
LOCAL FUNCTIONS
##########################################################
]]--
local function EnableSolve(index, button)
	button:SetAlpha(1)
	button.text:SetTextColor(1, 1, 1)
	button:SetScript("OnClick", function(self)
		SetSelectedArtifact(index)
		local _, _, _, _, _, numSockets = GetActiveArtifactByRace(index)
		local _, _, itemID = GetArchaeologyRaceInfo(index)
		local ready = true
		if numSockets and numSockets > 0 then
			for socketNum = 1, numSockets do
				if not ItemAddedToArtifact(itemID) then
					SocketItemToArtifact()
				end
			end
		end

		if GetNumArtifactsByRace(index) > 0 then
			print("Solving...")
			SolveArtifact()
		end
	end)
end

local function DisableSolve(button)
	button:SetAlpha(0)
	button.text:SetTextColor(0.5, 0.5, 0.5)
	button.text:SetText("")
	button:SetScript("OnClick", SV.fubar)
end

local function UpdateArtifactBars(index)
	local cache = refArtifacts[index]
	local bar = PLUGIN.Archaeology.Bars[index]

	bar["race"]:SetText(cache["race"])

	if GetNumArtifactsByRace(index) ~= 0 then
		local keystoneBonus = 0
		bar["race"]:SetTextColor(1, 0.8, 0)
		bar["progress"]:SetTextColor(1, 1, 1)
		if cache["numKeysockets"] then
			keystoneBonus = min(cache["numKeystones"], cache["numKeysockets"]) * ArchRaces
		end
		local actual = min(cache["progress"], cache["total"])
		local potential = cache["total"]
		local green = 0.75 * (actual / potential);
		bar["bar"]:SetMinMaxValues(0, potential)
		bar["bar"]:SetValue(actual)

		local solveText = SOLVE
		if (cache["numKeystones"] and cache["numKeystones"] > 0) then
			if (cache["numKeysockets"] and cache["numKeysockets"] > 0) then
				solveText = SOLVE.." ["..cache["numKeystones"] .. "/" .. cache["numKeysockets"].."]"
			end
		end
		bar["solve"].text:SetText(solveText)


		local FORMAT = NORMAL_FORMAT
		if keystoneBonus > 0 then
			FORMAT = KEYSTONE_FORMAT
		end

		if cache["total"] > 65 then
			bar["progress"]:SetText(format(FORMAT[2], cache["progress"], cache["total"]))
		else
			bar["progress"]:SetText(format(FORMAT[1], cache["progress"], cache["total"]))
		end

		if cache["canSolve"] then
			EnableSolve(index, bar["solve"])
		else
			DisableSolve(bar["solve"])
		end
		bar["bar"]:SetStatusBarColor(0.1, green, 1, 0.5)
	else
		DisableSolve(bar["solve"])
		bar["progress"]:SetText("")
		bar["bar"]:SetStatusBarColor(0, 0, 0, 0)
		bar["race"]:SetTextColor(0.25, 0.25, 0.25)
		bar["progress"]:SetTextColor(0.25, 0.25, 0.25)
	end
end

local function UpdateArtifactCache()
	local found, raceName, raceItemID, cache, _;
	for index = 1, ArchRaces do
		found = GetNumArtifactsByRace(index)
		raceName, _, raceItemID = GetArchaeologyRaceInfo(index)
		cache = refArtifacts[index]
		cache["race"] = raceName
		cache["keyID"] = raceItemID
		cache["numKeystones"] = 0
		local oldNum = cache["progress"]
		if found == 0 then
			cache["numKeysockets"] = 0
			cache["progress"] = 0
			cache["modifier"] = 0
			cache["total"] = 0
			cache["canSolve"] = false
		else
			SetSelectedArtifact(index)
			local _, _, _, _, _, keystoneCount = GetSelectedArtifactInfo()
			local numFragmentsCollected, numFragmentsAdded, numFragmentsRequired = GetArtifactProgress()

			cache["numKeysockets"] = keystoneCount
			cache["progress"] = numFragmentsCollected
			cache["modifier"] = numFragmentsAdded
			cache["total"] = numFragmentsRequired
			cache["canSolve"] = CanSolveArtifact()

			for i = 0, 4 do
				for j = 1, GetContainerNumSlots(i) do
					local slotID = GetContainerItemID(i, j)
					if slotID == cache["keyID"] then
						local _, count = GetContainerItemInfo(i, j)
						if cache["numKeystones"] < cache["numKeysockets"] then
							cache["numKeystones"] = cache["numKeystones"] + count
						end
						if min(cache["numKeystones"], cache["numKeysockets"]) * ArchRaces + cache["progress"] >= cache["total"] then
							cache["canSolve"] = true
						end
					end
				end
			end
		end
		UpdateArtifactBars(index)
	end
end

local function GetTitleAndSkill()
	local msg = "|cff22ff11Archaeology Mode|r"
	if(skillRank) then
		if(skillModifier) then
			skillRank = skillRank + skillModifier;
		end
		msg = msg .. " (|cff00ddff" .. skillRank .. "|r)";
	end
	return msg
end
--[[
##########################################################
EVENT HANDLER
##########################################################
]]--
do
	local SURVEYCOLOR = {
		{0.1, 1, 0.1, 1},
		{1, 0.5, 0.1, 1},
		{1, 0.1, 0, 1}
	}
	local last = 0
	local time = 3

	local ArchEventHandler = CreateFrame("Frame");
	local SurveyCooldown = CreateFrame("Frame", nil, UIParent);
	local ArchSiteFound;
	local ArchCanSurvey, ArchWillSurvey = false, false;

	SurveyCooldown:SetPoint("CENTER", UIParent, "CENTER", 0, -50)
	SurveyCooldown:SetSize(50, 50)
	SurveyCooldown.text = SurveyCooldown:CreateTexture(nil, "OVERLAY")
	SurveyCooldown.text:SetAllPoints(SurveyCooldown)
	SurveyCooldown.text:SetVertexColor(0,1,0.12,0.5)
	SurveyCooldown:SetScale(1)
	SV.Animate:Kapow(SurveyCooldown)

	local Arch_OnEvent = function(self, event, ...)
		if(InCombatLockdown() or not archSpell) then return end
		local NEEDS_UPDATE = false;
		if(event == "CURRENCY_DISPLAY_UPDATE" or event == "CHAT_MSG_SKILL" or event == "ARTIFACT_COMPLETE") then
			local msg = GetTitleAndSkill()
			PLUGIN.TitleWindow:Clear()
			PLUGIN.TitleWindow:AddMessage(msg)
			if(event ~= "CHAT_MSG_SKILL") then
				NEEDS_UPDATE = true
			end
		end
		if(CanScanResearchSite() and (event == "CURRENCY_DISPLAY_UPDATE")) then
			NEEDS_UPDATE = true
		elseif(event == "ARCHAEOLOGY_SURVEY_CAST" or event == "ARTIFACT_COMPLETE" or event == "ARTIFACT_DIG_SITE_UPDATED") then
			NEEDS_UPDATE = true
		elseif(event == "ARTIFACT_HISTORY_READY" or event == "ARTIFACT_DIGSITE_COMPLETE") then
			NEEDS_UPDATE = true
		else
			ArchCanSurvey = CanScanResearchSite()
			if(ArchCanSurvey and not ArchWillSurvey) then
				_G["SVUI_ModeCaptureWindow"]:SetAttribute("type", "spell")
				_G["SVUI_ModeCaptureWindow"]:SetAttribute('spell', survey)
				PLUGIN.ModeAlert.HelpText = "Double-Right-Click anywhere on the screen to survey.";
				ArchWillSurvey = true
			elseif(not ArchCanSurvey and ArchWillSurvey) then
				_G["SVUI_ModeCaptureWindow"]:SetAttribute("type", "spell")
				_G["SVUI_ModeCaptureWindow"]:SetAttribute('spell', archSpell)
				PLUGIN.ModeAlert.HelpText = "Double-Right-Click anywhere on the screen to open the artifacts window.";
				ArchWillSurvey = false
			end
			if(event == "ZONE_CHANGED_NEW_AREA") then ArchSiteFound = nil end
			if(not ArchSiteFound) then
				local sites = ArchaeologyMapUpdateAll();
				if(sites and sites > 0) then
					ArchSiteFound = true
					SV:SCTMessage("Digsite Located", 0.91, 0.78, 0.12);
				else
					ArchSiteFound = nil
				end
			end
		end

		if(NEEDS_UPDATE) then
			UpdateArtifactCache()
		end
	end

	local Survey_OnUpdate = function(self, elapsed)
		last = last + elapsed
		if last >= 1 then
			time = time - 1
			if time > 0 then
				self.text:SetTexture(COUNT_TEX .. time)
				self.text:SetVertexColor(unpack(SURVEYCOLOR[time]))
				if not self.anim:IsPlaying() then
			        self.anim:Play()
			    end
			else
				time = 3
				self:SetScript("OnUpdate", nil)
			end
			last = 0
		end
	end

	local Survey_OnEvent = function(self, event, unit, _, _, _, spellid)
		if not unit == "player" then return end
		if spellid == 80451 then
			time = 3
			self.text:SetTexture(COUNT_TEX .. 3)
			self.text:SetVertexColor(1,0,0,1)
			self:SetScript("OnUpdate", Survey_OnUpdate)
			if not self.anim:IsPlaying() then
		        self.anim:Play()
		    end
		end
	end

	function EnableListener()
		UpdateArtifactCache()

		ArchEventHandler:RegisterEvent("ZONE_CHANGED")
		ArchEventHandler:RegisterEvent("ZONE_CHANGED_NEW_AREA")
		ArchEventHandler:RegisterEvent("ZONE_CHANGED_INDOORS")

		ArchEventHandler:RegisterEvent("ARTIFACT_DIG_SITE_UPDATED")
		ArchEventHandler:RegisterEvent("ARTIFACT_DIGSITE_COMPLETE")
		ArchEventHandler:RegisterEvent("ARTIFACT_HISTORY_READY")
		ArchEventHandler:RegisterEvent("ARTIFACT_COMPLETE")

		ArchEventHandler:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
		ArchEventHandler:RegisterEvent("ARCHAEOLOGY_SURVEY_CAST")

		ArchEventHandler:RegisterEvent("CHAT_MSG_SKILL")

		ArchEventHandler:SetScript("OnEvent", Arch_OnEvent)
		if(playerRace ~= "Dwarf") then
			SurveyCooldown:RegisterEvent("UNIT_SPELLCAST_STOP")
			SurveyCooldown:SetScript("OnEvent", Survey_OnEvent)
		end
	end

	function DisableListener()
		ArchEventHandler:UnregisterAllEvents()
		ArchEventHandler:SetScript("OnEvent", nil)
		if(playerRace ~= "Dwarf") then
			SurveyCooldown:UnregisterAllEvents()
			SurveyCooldown:SetScript("OnEvent", nil)
		end
	end
end
--[[
##########################################################
CORE FUNCTIONS
##########################################################
]]--
function PLUGIN.Archaeology:Enable()
	PLUGIN.Archaeology:Update()
	if(not PLUGIN.Docklet:IsShown()) then PLUGIN.Docklet.Button:Click() end

	PlaySoundFile("Sound\\Item\\UseSounds\\UseCrinklingPaper.wav")
	PLUGIN.ModeAlert:SetBackdropColor(0.25, 0.52, 0.1)
	ArchCrafting:Show()
	local canArch = IsSpellKnown(80451)
	if(canArch) then
		ArchCrafting:FadeIn()
		local msg = GetTitleAndSkill()
		if surveyIsKnown and CanScanResearchSite() then
			PLUGIN:ModeLootLoader("Archaeology", msg, "Double-Right-Click anywhere on the screen to survey.");
			_G["SVUI_ModeCaptureWindow"]:SetAttribute("type", "spell")
			_G["SVUI_ModeCaptureWindow"]:SetAttribute('spell', survey)
		else
			PLUGIN:ModeLootLoader("Archaeology", msg, "Double-Right-Click anywhere on the screen to open the artifacts window.");
			_G["SVUI_ModeCaptureWindow"]:SetAttribute("type", "spell")
			_G["SVUI_ModeCaptureWindow"]:SetAttribute('spell', archSpell)
		end
		PLUGIN.TitleWindow:Clear();
		PLUGIN.TitleWindow:AddMessage(msg);
	else
		ArchCrafting:FadeOut(0.1,1,0,true)
		PLUGIN:ModeLootLoader("Archaeology", "WTF is Archaeology?", "You don't know archaeology! \nPicking up a rock and telling everyone that \nyou found a fossil is cute, BUT WRONG!! \nGo find someone who can train you to do this job.");
		PLUGIN.TitleWindow:Clear();
		PLUGIN.TitleWindow:AddMessage("WTF is Archaeology?");
		PLUGIN.LogWindow:Clear();
		PLUGIN.LogWindow:AddMessage("You don't know archaeology! \nPicking up a rock and telling everyone that \nyou found a fossil is cute, BUT WRONG!! \nGo find someone who can train you to do this job.", 1, 1, 1);
		PLUGIN.LogWindow:AddMessage(" ", 1, 1, 1);
	end
	EnableListener()
	PLUGIN.ModeAlert:Show()
	SV:SCTMessage("Archaeology Mode Enabled", 0.28, 0.9, 0.1);
end

function PLUGIN.Archaeology:Disable()
	DisableListener()
	ArchCrafting:FadeOut(0.1,1,0,true)
end

function PLUGIN.Archaeology:Bind()
	if InCombatLockdown() then return end
	if(archSpell) then
		if surveyIsKnown and CanScanResearchSite() then
			_G["SVUI_ModeCaptureWindow"]:SetAttribute("type", "spell")
			_G["SVUI_ModeCaptureWindow"]:SetAttribute('spell', survey)
			PLUGIN.ModeAlert.HelpText = 'Double-Right-Click anywhere on the screen to survey.'
		else
			_G["SVUI_ModeCaptureWindow"]:SetAttribute("type", "spell")
			_G["SVUI_ModeCaptureWindow"]:SetAttribute('spell', archSpell)
			PLUGIN.ModeAlert.HelpText = 'Double-Right-Click anywhere on the screen to open the artifacts window.'
		end
		SetOverrideBindingClick(_G["SVUI_ModeCaptureWindow"], true, "BUTTON2", "SVUI_ModeCaptureWindow");
		_G["SVUI_ModeCaptureWindow"].Handler:Show();
	end
end

function PLUGIN.Archaeology:Update()
	surveyIsKnown = IsSpellKnown(80451);
	survey = GetSpellInfo(80451);
	local _,_,arch,_,_,_ = GetProfessions();
	if(arch) then
		archSpell, _, skillRank, _, _, _, _, skillModifier = GetProfessionInfo(arch)
	end
end
--[[
##########################################################
LOADER
##########################################################
]]--
function PLUGIN:LoadArchaeologyMode()
	ArchRaces = GetNumArchaeologyRaces()
	for i = 1, ArchRaces do
		refArtifacts[i] = {}
	end
	CONFIGS = SV.db[self.Schema];
	ModeLogsFrame = self.LogWindow;

	local progressBars = self.Archaeology.Bars

	ArchCrafting:SetParent(ModeLogsFrame)
	ArchCrafting:SetFrameStrata("MEDIUM")
	ArchCrafting:InsetPoints(ModeLogsFrame)

	local BAR_WIDTH = (ArchCrafting:GetWidth() * 0.33) - 4
	local BAR_HEIGHT = (ArchCrafting:GetHeight() / math.floor(ArchRaces / 3)) - 4

	for i = 1, ArchRaces do
		local bar = CreateFrame("StatusBar", nil, ArchCrafting)
		local solve = CreateFrame("Button", nil, bar, "SecureHandlerClickTemplate")
		local xMod = (i == 1) and 0 or ((i-1) % 3);
		local xOffset = ((BAR_WIDTH + 4) * xMod) + 4;
		local yMod = (i == 1) and 0 or math.floor((i-1) / 3);
		local yOffset = ((BAR_HEIGHT + 4) * yMod) + 4;

		bar:SetStyle("Frame", "Bar")
		bar:SetStatusBarTexture([[Interface\AddOns\SVUI\assets\artwork\Template\DEFAULT]])
		bar:SetSize(BAR_WIDTH,BAR_HEIGHT)
		bar:SetPoint("TOPLEFT", ArchCrafting, "TOPLEFT", xOffset, -yOffset)
		bar:SetStatusBarColor(0.2, 0.2, 0.8, 0.5)

		-- Race Text
		local race = bar:CreateFontString()
		race:SetFontObject(SVUI_Font_CraftNumber)
		race:SetText(RACE)
		race:SetPoint("TOPLEFT", bar, "TOPLEFT", 2, -4)
		race:SetTextColor(1,0.8,0)

		-- Progress Text
		local progress = bar:CreateFontString()
		progress:SetFontObject(SVUI_Font_CraftNumber)
		progress:SetText("")
		progress:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", -1, 1)

		-- Solve
		solve:SetAllPoints(bar)

		solve.bg = solve:CreateTexture(nil,"BORDER")
		solve.bg:SetAllPoints(solve)
		solve.bg:SetTexture(SV.media.statusbar.default)
		solve.bg:SetVertexColor(0.1,0.5,0)

		solve.text = solve:CreateFontString(nil,"OVERLAY")
		solve.text:SetFontObject(SVUI_Font_Craft)
		solve.text:SetShadowOffset(-1,-1)
		solve.text:SetShadowColor(0,0,0,0.5)
		solve.text:SetText(SOLVE)
		solve.text:SetPoint("CENTER", solve, "CENTER", 2, 0)
		solve.RaceIndex = i
		solve.border = bar
		solve:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 2, 250)
			GameTooltip:ClearLines()
			if GetNumArtifactsByRace(self.RaceIndex) > 0 then
				self.text:SetTextColor(1, 1, 0)
				self.border:SetBackdropBorderColor(0,0.8,1)
				SetSelectedArtifact(self.RaceIndex)
				local artifactName, artifactDescription, artifactRarity, _, _, keystoneCount = GetSelectedArtifactInfo()
				local numFragmentsCollected, numFragmentsAdded, numFragmentsRequired = GetArtifactProgress()
				local r, g, b
				if artifactRarity == 1 then
					artifactRarity = ITEM_QUALITY3_DESC
					r, g, b = GetItemQualityColor(3)
				else
					artifactRarity = ITEM_QUALITY1_DESC
					r, g, b = GetItemQualityColor(1)
				end
				GameTooltip:AddLine(artifactName, r, g, b, 1)
				GameTooltip:AddLine(artifactRarity, r, g, b, r, g, b)
				GameTooltip:AddDoubleLine(ARCHAEOLOGY_RUNE_STONES..": "..numFragmentsCollected.."/"..numFragmentsRequired, "Keystones: "..keystoneCount, 1, 1, 1, 1, 1, 1)
				GameTooltip:AddLine(" ")
				GameTooltip:AddLine(artifactDescription, 1, 1, 1, 1)
				GameTooltip:Show()
			end
		end)
		solve:SetScript("OnLeave", function(self)
			self.text:SetTextColor(0.7, 0.7, 0.7)
			self.border:SetBackdropBorderColor(0,0,0)
			GameTooltip:Hide()
		end)

		progressBars[i] = {
			["bar"] = bar,
			["race"] = race,
			["progress"] = progress,
			["solve"] = solve
		}
	end
	ArchCrafting:FadeOut(0.1,1,0,true)
	self.Archaeology:Update()
	UpdateArtifactCache()
end
