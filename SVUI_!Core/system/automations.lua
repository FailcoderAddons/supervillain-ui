--[[
##############################################################################
S V U I   By: Failcoder
##############################################################################
--]]
--[[ GLOBALS ]]--
local _G = _G;
--LUA
local unpack        = _G.unpack;
local select        = _G.select;
local assert        = _G.assert;
local type          = _G.type;
local error         = _G.error;
local pcall         = _G.pcall;
local print         = _G.print;
local ipairs        = _G.ipairs;
local pairs         = _G.pairs;
local next          = _G.next;
local rawset        = _G.rawset;
local rawget        = _G.rawget;
local tostring      = _G.tostring;
local tonumber      = _G.tonumber;
local getmetatable  = _G.getmetatable;
local setmetatable  = _G.setmetatable;
--STRING
local string        = _G.string;
local upper         = string.upper;
local format        = string.format;
local find          = string.find;
local match         = string.match;
local gsub          = string.gsub;
--MATH
local math          = _G.math;
local floor         = math.floor;
local random        = math.random;
--TABLE
local table         = _G.table;
local tsort         = table.sort;
local tconcat       = table.concat;
local tremove       = _G.tremove;
local twipe         = _G.wipe;
--BLIZZARD API
local ReloadUI              = _G.ReloadUI;
local GetLocale             = _G.GetLocale;
local CreateFrame           = _G.CreateFrame;
local IsAddOnLoaded         = _G.IsAddOnLoaded;
local InCombatLockdown      = _G.InCombatLockdown;
local GetAddOnInfo          = _G.GetAddOnInfo;
local LoadAddOn             = _G.LoadAddOn;
local SendAddonMessage      = _G.SendAddonMessage;
local LibStub               = _G.LibStub;
local GetAddOnMetadata      = _G.GetAddOnMetadata;
local GetCVarBool           = _G.GetCVarBool;
local GameTooltip           = _G.GameTooltip;
local StaticPopup_Hide      = _G.StaticPopup_Hide;
local ERR_NOT_IN_COMBAT     = _G.ERR_NOT_IN_COMBAT;

local SV = select(2, ...);
local L = SV.L;
--[[
##########################################################
LOCAL VARS
##########################################################
]]--
local incpat 	  = gsub(gsub(FACTION_STANDING_INCREASED, "(%%s)", "(.+)"), "(%%d)", "(.+)");
local changedpat  = gsub(gsub(FACTION_STANDING_CHANGED, "(%%s)", "(.+)"), "(%%d)", "(.+)");
local decpat	  = gsub(gsub(FACTION_STANDING_DECREASED, "(%%s)", "(.+)"), "(%%d)", "(.+)");
local standing    = ('%s:'):format(STANDING);
local reputation  = ('%s:'):format(REPUTATION);
local hideStatic = false;

function SV:VendorGrays(destroy, silent, request)
	if((not MerchantFrame or not MerchantFrame:IsShown()) and (not destroy) and (not request)) then
		SV:AddonMessage(L["You must be at a vendor."])
		return
	end

	local totalValue = 0;
	local canDelete = 0;

	for bagID = 0, 4 do
		for slot = 1, GetContainerNumSlots(bagID) do
			local itemLink = GetContainerItemLink(bagID, slot)
			if(itemLink) then
				local name, link, quality, iLevel, reqLevel, class, subclass, maxStack, equipSlot, texture, vendorPrice = GetItemInfo(itemLink)
				if(vendorPrice) then
					local itemCount = select(2, GetContainerItemInfo(bagID, slot))
					local sellPrice = vendorPrice * itemCount
					local itemID = GetContainerItemID(bagID, slot);
					if(destroy) then
						if(find(itemLink, "ff9d9d9d")) then
							if(not request) then
								PickupContainerItem(bagID, slot)
								DeleteCursorItem()
							end
							totalValue = totalValue + sellPrice;
							canDelete = canDelete + 1
						elseif(SV.Inventory:VendorCheck(itemID, bagID, slot)) then
							if(not request) then
								PickupContainerItem(bagID, slot)
								DeleteCursorItem()
							end
							totalValue = totalValue + sellPrice;
							canDelete = canDelete + 1
						end
					elseif(sellPrice > 0) then
						if(quality == 0) then
							if(not request) then
								UseContainerItem(bagID, slot)
								PickupMerchantItem()
							end
							totalValue = totalValue + sellPrice
						elseif(SV.Inventory and (not request) and SV.Inventory:VendorCheck(itemID, bagID, slot)) then
							totalValue = totalValue + sellPrice
						end
					end
				end
			end
		end
	end

	if request then return totalValue end

	if(not silent) then
		if(totalValue > 0) then
			local prefix, strMsg
			local gold, silver, copper = floor(totalValue / 10000) or 0, floor(totalValue%10000 / 100) or 0, totalValue%100;

			if(not destroy) then
				strMsg = ("%s |cffffffff%s%s%s%s%s%s|r"):format(L["Vendored gray items for:"], gold, L["goldabbrev"], silver, L["silverabbrev"], copper, L["copperabbrev"])
				SV:AddonMessage(strMsg)
			else
				if(canDelete > 0) then
					prefix = ("|cffffffff%s%s%s%s%s%s|r"):format(gold, L["goldabbrev"], silver, L["silverabbrev"], copper, L["copperabbrev"])
					strMsg = (L["Deleted %d gray items. Total Worth: %s"]):format(canDelete, prefix)
					SV:AddonMessage(strMsg)
				else
					SV:AddonMessage(L["No gray items to delete."])
				end
			end
		elseif(destroy) then
			SV:AddonMessage(L["No gray items to delete."])
		end
	end
end
--[[
##########################################################
INVITE AUTOMATONS
##########################################################
]]--
function SV:PARTY_INVITE_REQUEST(event, invitedBy)
	if(not self.db.Extras.autoAcceptInvite) then return; end

	if(QueueStatusMinimapButton:IsShown() or IsInGroup()) then return end
	if(GetNumFriends() > 0) then
		ShowFriends()
	end
	if(IsInGuild()) then
		GuildRoster()
	end

	hideStatic = true;
	local invited = false;

	for f = 1, GetNumFriends() do
		local friend = gsub(GetFriendInfo(f), "-.*", "")
		if(friend == invitedBy) then
			AcceptGroup()
			invited = true;
			self:AddonMessage("Accepted an Invite From Your Friends!")
			break;
		end
	end

	if(not invited) then
		for b = 1, BNGetNumFriends() do
			local _, _, _, _, friend = BNGetFriendInfo(b)
			invitedBy = invitedBy:match("(.+)%-.+") or invitedBy;
			if(friend == invitedBy) then
				AcceptGroup()
				invited = true;
				self:AddonMessage("Accepted an Invite From Your Friends!")
				break;
			end
		end
	end

	if(not invited) then
		for g = 1, GetNumGuildMembers(true) do
			local guildMate = gsub(GetGuildRosterInfo(g), "-.*", "")
			if(guildMate == invitedBy) then
				AcceptGroup()
				invited = true;
				self:AddonMessage("Accepted an Invite From Your Guild!")
				break;
			end
		end
	end

	if(invited) then
		local popup = StaticPopup_FindVisible("PARTY_INVITE")
		if(popup) then
			popup.inviteAccepted = 1
			StaticPopup_Hide("PARTY_INVITE")
		else
			popup = StaticPopup_FindVisible("PARTY_INVITE_XREALM")
			if(popup) then
				popup.inviteAccepted = 1
				StaticPopup_Hide("PARTY_INVITE_XREALM")
			end
		end
	end
end
--[[
##########################################################
REPAIR AUTOMATONS
##########################################################
]]--
function SV:MERCHANT_SHOW()
	if(self.db.Extras.vendorGrays) then
		self:VendorGrays()
	end
	local autoRepair = self.db.Extras.autoRepair;
	local guildRepair = (autoRepair == "GUILD");
	if IsShiftKeyDown() or autoRepair == "NONE" or not CanMerchantRepair() then return end
	local repairCost,canRepair = GetRepairAllCost()

	if repairCost > 0 then
		local loan = GetGuildBankWithdrawMoney()
		if(guildRepair and ((not CanGuildBankRepair()) or (loan ~= -1 and (repairCost > loan)))) then
			guildRepair = false
		end
		if canRepair then
			RepairAllItems(guildRepair)
			local x,y,z= repairCost % 100,floor((repairCost % 10000)/100), floor(repairCost / 10000)
			if(guildRepair) then
				self:AddonMessage("Repairs Complete! ...Using Guild Money!\n"..GetCoinTextureString(repairCost,12))
			else
				self:AddonMessage("Repairs Complete!\n"..GetCoinTextureString(repairCost,12))
			end
		else
			self:AddonMessage("The Minions Say You Are Too Broke To Repair! They Are Laughing..")
		end
	end
end
--[[
##########################################################
REP AUTOMATONS
##########################################################
]]--
function SV:CHAT_MSG_COMBAT_FACTION_CHANGE(event, msg)
	if not self.db.Extras.autorepchange then return end
	local _, _, faction, amount = msg:find(incpat)
	if not faction then
		_, _, faction, amount = msg:find(changedpat) or msg:find(decpat)
	end
	if faction and faction ~= GUILD_REPUTATION then
		local active = GetWatchedFactionInfo()
		for factionIndex = 1, GetNumFactions() do
			local name = GetFactionInfo(factionIndex)
			if name == faction and name ~= active then
				SetWatchedFactionIndex(factionIndex)
				local strMsg = ("Watching Faction: %s"):format(name)
				self:AddonMessage(strMsg)
				break
			end
		end
	end
end
--[[
##########################################################
QUEST AUTOMATONS
##########################################################
]]--
function SV:AutoQuestProxy()
	if(IsShiftKeyDown()) then return false; end
    if(((not QuestIsDaily()) or (not QuestIsWeekly())) and (self.db.Extras.autodailyquests)) then return false; end
    if(QuestFlagsPVP() and (not self.db.Extras.autopvpquests)) then return false; end
    return true
end

function SV:QUEST_GREETING()
    if(self.db.Extras.autoquestaccept == true and self:AutoQuestProxy()) then
        local active,available = GetNumActiveQuests(), GetNumAvailableQuests()
        if(active + available == 0) then return end
        if(available > 0) then
        	for i = 1, available do
            	SelectAvailableQuest(i)
            end
        end
        if(active > 0) then
            for i = 1, active do
            	SelectActiveQuest(i)
            end
        end
    end
end

do
	local ACTIVE_QUESTS = {};

	local function ParseGossipAvailableQuests(...)
		local logCount = GetNumQuestLogEntries()
		twipe(ACTIVE_QUESTS)
		for i=1, logCount do
			local title, level, suggestedGroup, isHeader, isCollapsed, isComplete = GetQuestLogTitle(i)
			ACTIVE_QUESTS[title] = isComplete;
		end
		for i=1, select("#", ...), 6 do
			local title = select(i, ...);
			if(ACTIVE_QUESTS[title] == nil) then
				SelectGossipAvailableQuest(i);
			end
		end
	end

	local function ParseGossipActiveQuests(...)
		for i=1, select("#", ...), 6 do
			local title = select(i, ...);
			if(ACTIVE_QUESTS[title]) then
				SelectGossipActiveQuest(i);
			end
		end
	end

	function SV:GOSSIP_SHOW()
	    if(self.db.Extras.autoquestaccept == true and self:AutoQuestProxy()) then
	    	local numOther = GetNumGossipOptions()
	    	ParseGossipAvailableQuests(GetGossipAvailableQuests())
	    	ParseGossipActiveQuests(GetGossipActiveQuests())
	    end
	end
end

function SV:QUEST_DETAIL()
    if(self.db.Extras.autoquestaccept == true and self:AutoQuestProxy()) then
        if(not QuestGetAutoAccept()) then
			AcceptQuest()
		else
			CloseQuest()
		end
    end
end

function SV:QUEST_ACCEPT_CONFIRM()
    if(self.db.Extras.autoquestaccept == true and self:AutoQuestProxy()) then
        ConfirmAcceptQuest()
        StaticPopup_Hide("QUEST_ACCEPT_CONFIRM")
    end
end

function SV:QUEST_PROGRESS()
	if(IsShiftKeyDown()) then return false; end
  if(self.db.Extras.autoquestcomplete == true and IsQuestCompletable()) then
      CompleteQuest()
  end
end

function SV:QUEST_COMPLETE()
	if(not self.db.Extras.autoquestcomplete and (not self.db.Extras.autoquestreward)) then return end
	if(IsShiftKeyDown()) then return false; end
	local rewards = GetNumQuestChoices()
	local rewardsFrame = QuestInfoFrame.rewardsFrame;
	if(rewards > 1) then
		local auto_select = QuestFrameRewardPanel.itemChoice or QuestInfoFrame.itemChoice;
		local selection, value = 1, 0;

		for i = 1, rewards do
			local iLink = GetQuestItemLink("choice", i)
			if iLink then
				local iValue = select(11,GetItemInfo(iLink))
				if iValue and iValue > value then
					value = iValue;
					selection = i
				end
			end
		end

		local chosenItem = QuestInfo_GetRewardButton(rewardsFrame, selection)

		if chosenItem.type == "choice" then
			QuestInfoItemHighlight:ClearAllPoints()
			QuestInfoItemHighlight:SetAllPoints(chosenItem)
			QuestInfoItemHighlight:Show()
			QuestInfoFrame.itemChoice = chosenItem:GetID()
			self:AddonMessage("A Minion Has Chosen Your Reward!")
		end

		auto_select = selection

		if self.db.Extras.autoquestreward == true then
			GetQuestReward(auto_select)
		end
	else
		if(self.db.Extras.autoquestcomplete == true) then
			GetQuestReward(rewards)
		end
	end
end

local AutoRelease_OnEvent = function(self, event)
	local isInstance, instanceType = IsInInstance()
	if(isInstance and instanceType == "pvp") then
		local spell = GetSpellInfo(20707)
		if(SV.class ~= "SHAMAN" and not(spell and UnitBuff("player", spell))) then
			RepopMe()
		end
	end
	for i=1,GetNumWorldPVPAreas() do
		local _,localizedName, isActive = GetWorldPVPAreaInfo(i)
		if(GetRealZoneText() == localizedName and isActive) then RepopMe() end
	end
end
--[[
##########################################################
BUILD FUNCTION / UPDATE
##########################################################
]]--
local function InitializeAutomations()
	--print("InitializeAutomations")
	SV:RegisterEvent('PARTY_INVITE_REQUEST')
	SV:RegisterEvent('CHAT_MSG_COMBAT_FACTION_CHANGE')
	SV:RegisterEvent('MERCHANT_SHOW')
	SV:RegisterEvent('QUEST_COMPLETE')
	SV:RegisterEvent('QUEST_GREETING')
	SV:RegisterEvent('GOSSIP_SHOW')
	SV:RegisterEvent('QUEST_DETAIL')
	SV:RegisterEvent('QUEST_ACCEPT_CONFIRM')
	SV:RegisterEvent('QUEST_PROGRESS')

	if SV.db.Extras.pvpautorelease then
		local autoReleaseHandler = CreateFrame("frame")
		autoReleaseHandler:RegisterEvent("PLAYER_DEAD")
		autoReleaseHandler:SetScript("OnEvent", AutoRelease_OnEvent)
	end

	if(SV.db.Extras.skipcinematics) then
		local skippy = CreateFrame("Frame")
		skippy:RegisterEvent("CINEMATIC_START")
		skippy:SetScript("OnEvent", CinematicFrame_CancelCinematic)
		MovieFrame:SetScript("OnEvent", GameMovieFinished)
	end
end

SV:NewScript(InitializeAutomations)
