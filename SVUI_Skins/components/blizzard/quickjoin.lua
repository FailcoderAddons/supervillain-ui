--[[
##############################################################################
S V U I   By: Failcoder
QuickJoinToast By: JoeyMagz
##############################################################################
--]]
--[[ GLOBALS ]]--
local _G = _G;
local unpack  = _G.unpack;
local select  = _G.select;
local ipairs  = _G.ipairs;
local pairs   = _G.pairs;
--[[ ADDON ]]--
local SV = _G['SVUI'];
local L = SV.L;
local MOD = SV.Skins;
local Schema = MOD.Schema;
--[[ 
########################################################## 
HELPERS
##########################################################
]]--
local socQueue = C_SocialQueue;
local lfg = C_LFGList;
local pvp = C_PvP;

local ToastMinion = CreateFrame("Frame", "SVUI_ToastMinion");
local ToastVault;
local anchor = "";

ToastMinion:RegisterEvent("SOCIAL_QUEUE_UPDATE");
ToastMinion:RegisterEvent("ADDON_LOADED");

local function SummonToast(friendName, queueText, queueDesc, id, parent)
	local superToast = CreateFrame("Frame", "qjToastFrame"..id, parent);
	superToast:SetPoint(SV.db.Skins.quickjoin.growth);
	superToast:SetSize(SV.db.Skins.quickjoin.toastwidth, SV.db.Skins.quickjoin.toastheight);
	superToast.id = id;
	
	superToast.Text = superToast:CreateFontString(superToast:GetName() .. "QueueText", "OVERLAY", "FriendsFont_Normal");
	superToast.Text:SetText(friendName .. " joined " .. queueText);
	superToast.Text:SetFont(SV.media.font.alert, 12, "None") 
	superToast.Text:SetAllPoints(superToast);

	SV.API:Set("Button", superToast);
	
	superToast.animation = superToast:CreateAnimationGroup();
	superToast.animation.fadeIn = superToast.animation:CreateAnimation("Alpha");
	superToast.animation.fadeIn:SetDuration(0.6);
	superToast.animation.fadeIn:SetSmoothing("IN");
	superToast.animation.fadeIn:SetFromAlpha(0);
	superToast.animation.fadeIn:SetToAlpha(1);
	superToast.animation.fadeIn:SetOrder(1);
	superToast.animation.fadeOut = superToast.animation:CreateAnimation("Alpha");
	superToast.animation.fadeOut:SetStartDelay(5);
	superToast.animation.fadeOut:SetDuration(0.6);
	superToast.animation.fadeOut:SetSmoothing("OUT");
	superToast.animation.fadeOut:SetFromAlpha(1);
	superToast.animation.fadeOut:SetToAlpha(0);
	superToast.animation.fadeOut:SetOrder(2);
	superToast.animation.fadeOut:SetScript("OnFinished", function(self)
		self:GetParent():GetParent():close();
	end);
	
	superToast.close = function(self)
		ToastVault:close(self.id);
	end;
	
	superToast:SetScript("OnMouseUp", function (self, button)
		if (button == "LeftButton") then
			ToggleQuickJoinPanel();
		elseif (button == "RightButton") then
			self:close();
		end
	end);
	
	superToast.setQueueText = function(self, friendName, queueText)
		self.Text:SetText(friendName .. " joined " .. queueText);
	end;
	
	return superToast;
end

local function initializeToastVault()
	if (ToastVault ~= nil) then return; end
	
	ToastVault = CreateFrame("Frame", "ToastVault", UIParent);
	ToastVault:ClearAllPoints();
	ToastVault:SetPoint("TOP", UIParent, SV.db.Skins.quickjoin.xoffset, SV.db.Skins.quickjoin.yoffset);
	SV:RefreshToast(false);
	ToastVault:SetClampedToScreen(true);
	
	if (SV.db.Skins.quickjoin.growth == "TOP") then
		anchor = "BOTTOM";
	elseif (SV.db.Skins.quickjoin.growth == "BOTTOM") then
		anchor = "TOP";
	end
	
	local padding = 5;
	if (SV.db.Skins.quickjoin.growth == "BOTTOM") then
		padding = padding * -1;
	end
	
	ToastVault.secretVault = {};
	ToastVault.toast = {};
	ToastVault.next = SV.db.Skins.quickjoin.maxtoast + 1;
	
	ToastVault.addToast = function(self, friendName, queueText, queueDesc)
		local vaultData = { ["friendName"] = friendName, ["queueText"] = queueText, ["queueDesc"] = queueDesc };
		table.insert(self.secretVault, vaultData);
		self:handleToast();
	end;
	
	ToastVault.close = function(self, closeID)
		local repositionToast = nil;
		local closedToast = nil;
		
		for k, toast in pairs(self.toast) do
			if (toast.id == closeID) then
				toast:Hide();
				toast.id = self.next;
				self.next = self.next + 1;
				closedToast = toast;
			end
		end
		
		--Sort the table by oldest to newest. Reverse for newest to oldest.
		table.sort(self.toast, function(toast1, toast2)
			return toast1.id < toast2.id;
		end);
		
		for k, toast in pairs(self.toast) do
			toast:ClearAllPoints();
			if (repositionToast == nil) then
				toast:SetPoint(anchor, ToastVault, anchor);
			else
				toast:SetPoint(anchor, repositionToast, SV.db.Skins.quickjoin.growth, 0, padding);
			end
			repositionToast = toast;
		end
		
		self:handleToast();
	end;
	
	ToastVault.handleToast = function(self)	
		if(#self.secretVault == 0) then
			return;
		end;
		
		local tIndex = -1;
		local nToastID = self.next + 1;
		for index, toast in pairs(self.toast) do
			if (not toast:IsShown() and toast.id < nToastID) then
				tIndex = index;
				nToastID = toast.id;
			end
		end
		
		if (tIndex == -1) then
			return;
		end
		
		local tData = table.remove(self.secretVault, 1);
		self.toast[tIndex]:setQueueText(tData["friendName"], tData["queueText"]);
		self.toast[tIndex]:Show();
		self.toast[tIndex].animation:Stop();
		self.toast[tIndex].animation:Play();
		
		self:handleToast();
	end;
	
	for i=1,SV.db.Skins.quickjoin.maxtoast do
		ToastVault.toast[i] = SummonToast("", "", "", i, ToastVault);
		ToastVault.toast[i]:Hide();
		
		if (i == 1) then
			ToastVault.toast[i]:ClearAllPoints();
			ToastVault.toast[i]:SetPoint(anchor, ToastVault, anchor);
		else
			ToastVault.toast[i]:ClearAllPoints();
			ToastVault.toast[i]:SetPoint(anchor, ToastVault.toast[i-1], SV.db.Skins.quickjoin.growth, 0, padding);
		end
	end
end

local function AppendQueueName(textTable, name, nameFormatter)
	if (name) then
		if (nameFormatter) then
			name = nameFormatter:format(name);
		end

		table.insert(textTable, name);
	end
end

local function SVUI_SocialQueueUtil_GetQueueName(queue, nameFormatter)
	local nameText = {};

	if (queue.queueType == "lfg") then
		for i, lfgID in ipairs(queue.lfgIDs) do
			local name, typeID, subtypeID, minLevel, maxLevel, recLevel, minRecLevel, maxRecLevel, expansionLevel, groupID, textureFilename, difficulty, maxPlayers, description, isHoliday, _, _, isTimeWalker = GetLFGDungeonInfo(lfgID);
			if (typeID == TYPEID_RANDOM_DUNGEON or isTimeWalker or isHoliday) then
				-- Name remains unchanged
			elseif (subtypeID == LFG_SUBTYPEID_DUNGEON) then
				name = SOCIAL_QUEUE_FORMAT_DUNGEON:format(name);
			elseif (subtypeID == LFG_SUBTYPEID_HEROIC) then
				name = SOCIAL_QUEUE_FORMAT_HEROIC_DUNGEON:format(name);
			elseif (subtypeID == LFG_SUBTYPEID_RAID) then
				name = SOCIAL_QUEUE_FORMAT_RAID:format(name);
			elseif (subtypeID == LFG_SUBTYPEID_FLEXRAID) then
				name = SOCIAL_QUEUE_FORMAT_RAID:format(name);
			elseif (subtypeID == LFG_SUBTYPEID_WORLDPVP) then
				name = SOCIAL_QUEUE_FORMAT_WORLDPVP:format(name);
			else
				-- Name remains unchanged
			end

			AppendQueueName(nameText, name, nameFormatter);
		end
	elseif (queue.queueType == "pvp") then
		local battlefieldType = queue.battlefieldType;
		local isBrawl = queue.isBrawl;
		local name = queue.mapName;
		if (isBrawl) then
			local brawlInfo = pvp.GetBrawlInfo();
			if (brawlInfo and brawlInfo.active) then
				name = brawlInfo.name;
			end
		elseif (battlefieldType == "BATTLEGROUND") then
			name = SOCIAL_QUEUE_FORMAT_BATTLEGROUND:format(name);
		elseif (battlefieldType == "ARENA") then
			name = SOCIAL_QUEUE_FORMAT_ARENA:format(queue.teamSize);
		elseif (battlefieldType == "ARENASKIRMISH") then
			name = SOCIAL_QUEUE_FORMAT_ARENA_SKIRMISH;
		end

		AppendQueueName(nameText, name, nameFormatter);
	elseif (queue.queueType == "lfglist") then
		local name;
		if (queue.lfgListID) then
			name = select(3, lfg.GetSearchResultInfo(queue.lfgListID));
		else
			if (queue.activityID) then
				name = lfg.GetActivityInfo(queue.activityID);
			end
		end

		AppendQueueName(nameText, name, nameFormatter);
	end
	
	return nameText;
end

function ToastMinion:OnEvent(event, ...)
	if (event == "SOCIAL_QUEUE_UPDATE") then
		local guid, numAdded = ...;

		if (numAdded == 0 or socQueue.GetGroupMembers(guid) == nil) then
			return;
		end
	
		local members, playerName, color;
	
		if (socQueue.GetGroupMembers(guid) ~= nil) then
			members = SocialQueueUtil_SortGroupMembers(socQueue.GetGroupMembers(guid));
			playerName, color = SocialQueueUtil_GetNameAndColor(members[1]);
		end
		
		playerName = color..playerName.."|r";
		
		local getQueues = socQueue.GetGroupQueues(guid);
		if getQueues ~= nil then
			if (getQueues[1].queueData.queueType == "lfglist") then
				if (getQueues[1].eligible) then
					local id, activityID, name, comment, voiceChat, iLvl, honorLevel, age, numBNetFriends, numCharFriends, numGuildMates, isDelisted, leaderName, numMembers = lfg.GetSearchResultInfo(getQueues[1].queueData.lfgListID);
					
					local activityName, shortName, categoryID, groupID, minItemLevel, filters, minLevel, maxPlayers, displayType, _, useHonorLevel = lfg.GetActivityInfo(activityID);
					
					-- Roles
					-- I might expand the toast frame to include roles at a later date
					--[[
					local roles = {TANK = 0, HEALER = 0, DAMAGER = 0};
					for i=1,numMembers do
						local role, class, classLocalized = lfg.GetSearchResultMemberInfo(getQueues[1].queueData.lfgListID, i);
						roles[role] = roles[role] + 1;
					end
					roleText = "("..roles["TANK"].."/"..roles["HEALER"].."/"..roles["DAMAGER"]..")";
					]]--
					
					ToastVault:addToast(playerName, activityName..": "..name, "lfglist", getQueues[1].queueData.lfgListID);
					--SV:AddonMessage(playerName .. " joined a group: " .. activityName..": "..name .. "lfglist" .. getQueues[1].queueData.lfgListID);
				end
			else
				local allQueues = "";
				local eQueue = false;
				for id, queue in pairs(getQueues) do
					if (queue.eligible) then
						eQueue = true;
						local queueTable = SVUI_SocialQueueUtil_GetQueueName(queue.queueData);
						local queueName = "";
						for queueId, name in pairs(queueTable) do
							if (queueName == "") then
								queueName = name;
							 else
								queueName = queueName..", "..name;
							end
						end
						if (allQueues == "") then
							allQueues = queueName;
						else
							allQueues = allQueues..", "..queueName;
						end
					end
				end
				if (eQueue) then
					ToastVault:addToast(playerName, allQueues, "lfg", guid);
					--SV:AddonMessage(playerName .. " joined a group: " .. allQueues .. "lfg" .. guid);
				end
			end
		end
	elseif (event == "ADDON_LOADED") then
		-- Initialize Toast Systems
		-- If we don't initialize, then there won't be any toasting to our victories.
		initializeToastVault();
	end
end

ToastMinion:SetScript("OnEvent", ToastMinion.OnEvent);

function SV:RefreshToast(growChange)
	if (not growChange) then
		local maxToasts = SV.db.Skins.quickjoin.maxtoast;
		local height = SV.db.Skins.quickjoin.toastheight;
		local width = SV.db.Skins.quickjoin.toastwidth;

		ToastVault:SetSize(width, maxToasts * (height + 5));
	else
		SV:StaticPopup_Show("RL_CLIENT");
	end
end

function SV:MoveToast()
	local xoffset = ToastVault_MOVE:GetLeft();
	local yoffset = ToastVault_MOVE:GetTop();
	SV.db.Skins.quickjoin.xoffset = xoffset;
	SV.db.Skins.quickjoin.yoffset = yoffset;
	ToastVault:SetPoint("TOP", UIParent, SV.db.Skins.quickjoin.xoffset, SV.db.Skins.quickjoin.yoffset);
end
--[[ 
########################################################## 
Quick Join Toast MODR
##########################################################
]]--
local function QuickJoinStyle()
	if SV.db.Skins.quickjoin.enable ~= true then
		 return 
	end
	
	-- Hide the goofball default Blizz toasts that like to show up offscreen and ruin our Evil plans!
	QuickJoinToastButton.Toast:Hide();
	QuickJoinToastButton.Toast2:Hide();
	
	SV:NewAnchor(ToastVault, L["Quick Join Toast Anchor"]);
	SV:MoveToast();	
	
	SV:AddSlashCommand("addtoast", "Display test quick join toast", function()
		ToastVault:addToast("Supervillain", "RAID: Chamber of the Avatar", "lfglist", 9999);
		SV:AddonMessage(SV.db.Skins.quickjoin.xoffset .. ", " .. SV.db.Skins.quickjoin.yoffset);
	end);
end
--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveCustomStyle("QuickJoin", QuickJoinStyle)
