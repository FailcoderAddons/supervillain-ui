--[[
##############################################################################
S V U I   By: Failcoder
##############################################################################

QUEST TRACKER BUTTON: 

Originally "ExtraQuestButton" by p3lim, 
modified/minimally re-written for SVUI by Failcoder

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

local C_Timer 				= _G.C_Timer;
local GetNumQuestWatches  	= _G.GetNumQuestWatches;
local GetQuestWatchInfo  	= _G.GetQuestWatchInfo;
local QuestHasPOIInfo  	= _G.QuestHasPOIInfo;
local GetQuestLogSpecialItemInfo  	= _G.GetQuestLogSpecialItemInfo;
local GetCurrentMapAreaID  	= _G.GetCurrentMapAreaID;
local GetDistanceSqToQuest  	= _G.GetDistanceSqToQuest;
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
local QuestInZone = {
	[14108] = 541,
	[13998] = 11,
	[25798] = 61,
	[25799] = 61,
	[25112] = 161,
	[25111] = 161,
	[24735] = 201,
};
--[[ 
########################################################## 
BUTTON INTERNALS
##########################################################
]]--
local ticker;
local UpdateButton = function(self)
	local numItems = 0
	local shortestDistance = 62500
	local closestQuestLink, closestQuestTexture
	local activeQuestLink, activeQuestTexture

	for index = 1, GetNumQuestWatches() do
		local questID, _, questIndex, _, _, isComplete = GetQuestWatchInfo(index)
		if(questID and QuestHasPOIInfo(questID)) then
			local link, texture, _, showCompleted = GetQuestLogSpecialItemInfo(questIndex)
			if(link) then
				local areaID = QuestInZone[questID]
				if questIndex == MOD.CurrentQuest then
					activeQuestLink = link
					activeQuestTexture = texture
				end
				if(areaID and areaID == GetCurrentMapAreaID()) then
					closestQuestLink = link
					closestQuestTexture = texture
				elseif(not isComplete or (isComplete and showCompleted)) then
					local distanceSq, onContinent = GetDistanceSqToQuest(questIndex)
					if(onContinent and distanceSq < shortestDistance) then
						shortestDistance = distanceSq
						closestQuestLink = link
						closestQuestTexture = texture
					end
				end

				numItems = numItems + 1
			end
		end
	end

	if(closestQuestLink) then
		self:SetUsage(closestQuestLink, closestQuestTexture);
	elseif(activeQuestLink) then
		self:SetUsage(activeQuestLink, activeQuestTexture);
	end

	if(numItems > 0 and not ticker) then
		ticker = C_Timer.NewTicker(30, function()
			self:Update()
		end)
	elseif(numItems == 0 and ticker) then
		ticker:Cancel()
		ticker = nil
	end
end
--[[ 
########################################################## 
PACKAGE CALL
##########################################################
]]--
function MOD:InitializeQuestItem()
	SVUI_QuestItemBar:SetParent(SV.Screen)
	SVUI_QuestItemBar:SetPoint("BOTTOM", SV.Screen, "BOTTOM", 0, 250)
	SVUI_QuestItemBar:SetSize(40,40)

	SV:NewAnchor(SVUI_QuestItemBar, L["Quest Item Button"])

	local questitem = SV:CreateSecureButton("item", "SVUI_QuestItemBar", "SVUI_QuestAutoItemButton", UpdateButton);
	questitem.ArtFile = MOD.media.buttonArt;
	questitem.blacklist[113191] = true
	questitem.blacklist[110799] = true
	questitem.blacklist[109164] = true
	questitem:RegisterEvent('UPDATE_EXTRA_ACTIONBAR')
	questitem:RegisterEvent('BAG_UPDATE_COOLDOWN')
	questitem:RegisterEvent('BAG_UPDATE_DELAYED')
	questitem:RegisterEvent('WORLD_MAP_UPDATE')
	questitem:RegisterEvent('QUEST_LOG_UPDATE')
	questitem:RegisterEvent('QUEST_POI_UPDATE')

	self.QuestItem = questitem
end