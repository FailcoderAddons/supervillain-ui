--[[
##############################################################################
S V U I   By: Failcoder
##############################################################################

##########################################################
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;

local select 	= _G.select;
local pairs 	= _G.pairs;
local ipairs 	= _G.ipairs;
local type 		= _G.type;
local error 	= _G.error;
local pcall 	= _G.pcall;
local assert 	= _G.assert;
local tostring 	= _G.tostring;
local tonumber 	= _G.tonumber;
local string 	= _G.string;
local math 		= _G.math;
local table 	= _G.table;
--[[ STRING METHODS ]]--
local lower, upper = string.lower, string.upper;
local find, format, len, split = string.find, string.format, string.len, string.split;
local match, sub, join = string.match, string.sub, string.join;
local gmatch, gsub = string.gmatch, string.gsub;
--[[ MATH METHODS ]]--
local abs, ceil, floor, round = math.abs, math.ceil, math.floor, math.round;  -- Basic
--[[ TABLE METHODS ]]--
local wipe, tsort = table.wipe, table.sort;
--[[
##########################################################
GET ADDON DATA
##########################################################
]]--
local SV = select(2, ...)
local L = SV.L
local Reports = SV.Reports;
--[[
##########################################################
FRIENDS HELPERS
##########################################################
]]--
local TEXT_PATTERN0 = "|cff%02x%02x%02x%s|r";
local TEXT_PATTERN1 = "%s: |cff22FFFF%d|r";
local TEXT_PATTERN2 = "|cff%02x%02x%02x%s|r |cff%02x%02x%02x%d|r";
local TEXT_PATTERN3 = "%s |cff%02x%02x%02x%d|r %s";
local TEXT_PATTERN4 = FRIENDS_LIST_ONLINE .. ": %s/%s";
local ONLINE_MSG = gsub(ERR_FRIEND_ONLINE_SS, "\124Hplayer:%%s\124h%[%%s%]\124h", "");
local OFFLINE_MSG = gsub(ERR_FRIEND_OFFLINE_S, "%%s", "");
local MATCH_COLOR = {r = 0.25, g = 0.9, b = 0.08};
local MISMATCH_COLOR = {r = 0.47, g = 0.47, b = 0.47};
local BATTLENET_LABELS = {};
local UpdateFriendsData;
local COUNT_GENERAL = 0;
local ONLINE_GENERAL = 0;
local COUNT_BNET = 0;
local ONLINE_BNET = 0;
local COUNT_TOTAL = 0;
local ONLINE_TOTAL = 0;
local FRIEND_DATA = {
  ['General'] = {},
};
local UPDATE_REQUIRED = false;

do
  	local AFK_INSERT = "|cffFFFFFF[|r|cffFF0000"..L['AFK'].."|r|cffFFFFFF]|r";
  	local DND_INSERT = "|cffFFFFFF[|r|cffFF0000"..L['DND'].."|r|cffFFFFFF]|r";

	local function _reg(a, b)
		if(a.NAME and b.NAME) then
		  return a.NAME < b.NAME
		end
	end

	local function _bn(a, b)
		if(a.BNET_NAME and b.BNET_NAME) then
			if(a.BNET_NAME == b.BNET_NAME and (a.NAME and b.NAME)) then
	    return a.NAME < b.NAME;
	  end
			return a.BNET_NAME < b.BNET_NAME
		end
	end

  	local function _update()
		local generalUpdated, bnetUpdated = false, false;

		if(COUNT_GENERAL and (COUNT_GENERAL > 0)) then
		  wipe(FRIEND_DATA.General);

			for i = 1, COUNT_GENERAL do
				local toonName, level, class, zoneName, isOnline, status, noteText = GetFriendInfo(i)

				if(isOnline) then
				if(status) then
					if(status:find(AFK)) then
						status = AFK_INSERT
					elseif(status:find(DND)) then
						status = DND_INSERT
					end
				end

		      	local classUpdated = false;

				for k,v in pairs(LOCALIZED_CLASS_NAMES_MALE) do
					if class == v then
					  class = k;
					  classUpdated = true;
					end
				end

				if(not classUpdated) then
					for k,v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
					  if class == v then
					    class = k;
					  end
					end
				end

				FRIEND_DATA.General[#FRIEND_DATA.General + 1] = {
		            ONLINE = isOnline,
		            CLIENT = BNET_CLIENT_WOW,
		            NAME = toonName,
		            CLASS = class,
		            LOC = zoneName,
		            LVL = level,
		            STATUS = status,
		            REALM = false,
		            FACTION = false,
		            RACE = false,
		            BNET_ID = false,
		            BNET_NAME = false,
		            ID = false,
		            NOTES = noteText,
		         };

		      	generalUpdated = true;
				end
			end
		end

		if(COUNT_BNET and (COUNT_BNET > 0)) then
			wipe(FRIEND_DATA[BNET_CLIENT_WOW])
			wipe(FRIEND_DATA[BNET_CLIENT_D3])
			wipe(FRIEND_DATA[BNET_CLIENT_SC2])
			wipe(FRIEND_DATA[BNET_CLIENT_WTCG])
			wipe(FRIEND_DATA[BNET_CLIENT_HEROES])
			wipe(FRIEND_DATA[BATTLENET_OPTIONS_LABEL])

			for i = 1, COUNT_BNET do
				local presenceID, presenceName, battleTag, isBattleTagPresence, toonName, toonID, client, isOnline, lastOnline, isAFK, isDND, messageText, noteText, isRIDFriend, messageTime, canSoR = BNGetFriendInfo(i)
		        local _, hasFocus, realmName, realmID, faction, race, class, guild, zoneName, level, gameText, broadcastText, broadcastTime;
		        if(toonID) then
		          	hasFocus, toonName, client, realmName, realmID, faction, race, class, guild, zoneName, level, gameText, broadcastText, broadcastTime = BNGetGameAccountInfo(toonID);
		        else
		          	hasFocus, toonName, client, realmName, realmID, faction, race, class, guild, zoneName, level, gameText, broadcastText, broadcastTime = BNGetGameAccountInfo(presenceID);
		        end

		        if(not client or (client == BNET_CLIENT_APP)) then
		        	client = BATTLENET_OPTIONS_LABEL
		        end

				if(isOnline and FRIEND_DATA[client]) then
		          	local classUpdated = false;

		    		for k,v in pairs(LOCALIZED_CLASS_NAMES_MALE) do
						if class == v then
						  class = k;
						  classUpdated = true;
						end
					end

					if(not classUpdated) then
						for k,v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
						  if class == v then
						    class = k;
						  end
						end
					end

		          	local status = "";
		          	if(isAFK) then
		      			status = AFK_INSERT
		      		elseif(isDND) then
		      			status = DND_INSERT
		      		end

					FRIEND_DATA[client][#FRIEND_DATA[client] + 1] = {
						ONLINE = isOnline,
						CLIENT = client,
						NAME = toonName,
						CLASS = class,
						LOC = zoneName,
						LVL = level,
						STATUS = status,
						REALM = realmName,
						FACTION = faction,
						RACE = race,
						BNET_ID = presenceID,
						BNET_NAME = presenceName,
						ID = toonID,
						NOTES = noteText,
					};

		          	bnetUpdated = true;
				end
			end
		end

		if(generalUpdated) then
		  	tsort(FRIEND_DATA.General, _reg);
		end

    	if(bnetUpdated) then
	      tsort(FRIEND_DATA[BNET_CLIENT_WOW], _bn)
	      tsort(FRIEND_DATA[BNET_CLIENT_SC2], _bn)
	      tsort(FRIEND_DATA[BNET_CLIENT_D3], _bn)
	      tsort(FRIEND_DATA[BNET_CLIENT_WTCG], _bn)
	      tsort(FRIEND_DATA[BNET_CLIENT_HEROES], _bn)
	      tsort(FRIEND_DATA[BATTLENET_OPTIONS_LABEL], _bn)
    	end
  	end

	function UpdateFriendsData(updateCache)
		COUNT_GENERAL, ONLINE_GENERAL = GetNumFriends();
		COUNT_BNET, ONLINE_BNET = BNGetNumFriends();
		COUNT_TOTAL = COUNT_GENERAL + COUNT_BNET;
		ONLINE_TOTAL = ONLINE_GENERAL + ONLINE_BNET;
		if(updateCache) then
		  _update()
		end
	end
end
--[[
##########################################################
FRIENDS MENUS
##########################################################
]]--
SV.SystemAlert.SET_BN_BROADCAST={
	text = BN_BROADCAST_TOOLTIP,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	editBoxWidth = 350,
	maxLetters = 127,
	OnAccept = function(self) BNSetCustomMessage(self.editBox:GetText()) end,
	OnShow = function(self) self.editBox:SetText(select(4, BNGetInfo()) ) self.editBox:SetFocus() end,
	OnHide = ChatEdit_FocusActiveWindow,
	EditBoxOnEnterPressed = function(self) BNSetCustomMessage(self:GetText()) self:GetParent():Hide() end,
	EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1,
	preferredIndex = 3
};

local menuFrame = CreateFrame("Frame", "FriendDatatextRightClickMenu", SV.Screen, "UIDropDownMenuTemplate")
local menuList = {
	{ text = OPTIONS_MENU, isTitle = true, notCheckable = true},
	{ text = INVITE, hasArrow = true, notCheckable = true, },
	{ text = CHAT_MSG_WHISPER_INFORM, hasArrow = true, notCheckable = true, },
	{ text = PLAYER_STATUS, hasArrow = true, notCheckable = true,
		menuList = {
			{ text = "|cff2BC226"..AVAILABLE.."|r", notCheckable = true, func = function() if IsChatAFK() then SendChatMessage("", "AFK") elseif IsChatDND() then SendChatMessage("", "DND") end end },
			{ text = "|cffE7E716"..DND.."|r", notCheckable = true, func = function() if not IsChatDND() then SendChatMessage("", "DND") end end },
			{ text = "|cffFF0000"..AFK.."|r", notCheckable = true, func = function() if not IsChatAFK() then SendChatMessage("", "AFK") end end },
		},
	},
	{ text = BN_BROADCAST_TOOLTIP, notCheckable = true, func = function() SV:StaticPopup_Show("SET_BN_BROADCAST") end },
}

local function inviteClick(self, name)
	menuFrame:Hide()

	if type(name) ~= 'number' then
		InviteUnit(name)
	else
		BNInviteFriend(name);
	end
end

local function whisperClick(self, name, battleNet)
	menuFrame:Hide()

	if battleNet then
		ChatFrame_SendSmartTell(name)
	else
		SetItemRef( "player:"..name, ("|Hplayer:%1$s|h[%1$s]|h"):format(name), "LeftButton" )
	end
end

local REPORT_NAME = "Friends";

local Report = Reports:NewReport(REPORT_NAME, {
	type = "data source",
	text = REPORT_NAME .. " Info",
	icon = [[Interface\Addons\SVUI_!Core\assets\icons\SVUI]]
});

Report.events = {
	"PLAYER_ENTERING_WORLD",
	"BN_FRIEND_ACCOUNT_ONLINE",
	"BN_FRIEND_ACCOUNT_OFFLINE",
	"CLUB_INVITATION_ADDED_FOR_SELF",
	"BN_CUSTOM_MESSAGE_CHANGED",
    "BN_FRIEND_INVITE_ADDED",
    "BN_FRIEND_INVITE_LIST_INITIALIZED",
	"CHAT_MSG_SYSTEM"
};

Report.OnEvent = function(self, event, ...)
	if event == "CHAT_MSG_SYSTEM" then
		local message = select(1, ...)
		if not (find(message, ONLINE_MSG) or find(message, OFFLINE_MSG)) then return end
	end
	UpdateFriendsData();
	UPDATE_REQUIRED = true;
	self.text:SetFormattedText(TEXT_PATTERN1, L['Friends'], ONLINE_TOTAL);
end

Report.OnClick = function(self, button)
	Reports.ToolTip:Hide()

	if button == "RightButton" then
		local menuCountWhispers = 0;
		local menuCountInvites = 0;

		menuList[2].menuList = {}
		menuList[3].menuList = {}

		local currentFaction = UnitFactionGroup("player");

		for client, cache in pairs(FRIEND_DATA) do
			if(#cache > 0) then
				for i = 1, #cache do
					local friend = cache[i]
					if (friend.ONLINE) then
						local INVITE_TAG = friend.BNET_NAME or friend.NAME;
						local INVITE_TEXT = format(TEXT_PATTERN0, 130.05, 197.115, 255, INVITE_TAG)
						menuCountWhispers = menuCountWhispers + 1

						if((client == 'General') or ((BNET_CLIENT_WOW == friend.CLIENT) and (currentFaction == friend.FACTION))) then
							menuCountInvites = menuCountInvites + 1
							local lC = GetQuestDifficultyColor(friend.LVL);
							local cC = RAID_CLASS_COLORS[friend.CLASS] or lC;
							INVITE_TEXT = format(TEXT_PATTERN2, cC.r*255, cC.g*255, cC.b*255, friend.NAME, lC.r*255, lC.g*255, lC.b*255, friend.LVL)
						end

						menuList[2].menuList[menuCountInvites] = {text = INVITE_TEXT, arg1 = INVITE_TAG, notCheckable = true, func = inviteClick}
						menuList[3].menuList[menuCountWhispers] = {text = INVITE_TEXT, arg1 = INVITE_TAG, arg2 = true, notCheckable = true, func = whisperClick}
					end
				end
			end
		end

		EasyMenu(menuList, menuFrame, "cursor", 0, 0, "MENU", 2)
	else
		ToggleFriendsFrame()
	end
end

Report.OnEnter = function(self)
	Reports:SetDataTip(self)

	local groupString = "";
	local numberOfFriends, onlineFriends = GetNumFriends()
	local totalBNet, numBNetOnline = BNGetNumFriends()


	if(UPDATE_REQUIRED) then
		UpdateFriendsData(true);
		UPDATE_REQUIRED = false;
	end

	if(ONLINE_TOTAL == 0) then return end

	local zonec, classc, levelc, realmc;
	Reports.ToolTip:AddDoubleLine(L['Friends List'], format(TEXT_PATTERN4, ONLINE_TOTAL, COUNT_TOTAL), 0.51, 0.773, 1, 0.51, 0.773, 1)
	Reports.ToolTip:AddLine(' ')

	local currentZone = GetRealZoneText();
	local currentRealm = GetRealmName();

	if(ONLINE_GENERAL > 0) then
		local cache, addSpacer = FRIEND_DATA.General, false;

		for i = 1, #cache do
			local friend = cache[i];

			if(friend.ONLINE) then
				local zC = (currentZone == friend.LOC) and MATCH_COLOR or MISMATCH_COLOR;
				local lC = GetQuestDifficultyColor(friend.LVL);
				local cC = RAID_CLASS_COLORS[friend.CLASS] or lC;
				local statusString = friend.STATUS;
				if(UnitInParty(friend.NAME) or UnitInRaid(friend.NAME)) then statusString = "|cffaaaaaa*|r " .. statusString; end
				local LEFT_TEXT = format(TEXT_PATTERN3, friend.NAME, lC.r*255, lC.g*255, lC.b*255, friend.LVL, statusString)
				Reports.ToolTip:AddDoubleLine(LEFT_TEXT, friend.LOC, cC.r, cC.g, cC.b, zC.r, zC.g, zC.b)
				addSpacer = true;
			end
		end

		if(addSpacer) then
			Reports.ToolTip:AddLine(' ')
		end
	end

	if(ONLINE_BNET > 0) then

		for client, cache in pairs(FRIEND_DATA) do
			local GROUP_LABEL = BATTLENET_LABELS[client];

			if(GROUP_LABEL and (#cache > 0)) then
				Reports.ToolTip:AddLine(GROUP_LABEL .. client)

				for i = 1, #cache do
					local friend = cache[i]

					if(friend.ONLINE) then
						if friend.CLIENT == BNET_CLIENT_WOW then
							local statusString = friend.STATUS;
							if(UnitInParty(friend.NAME) or UnitInRaid(friend.NAME)) then statusString = "|cffaaaaaa*|r " .. statusString; end
							local cC = RAID_CLASS_COLORS[friend.CLASS] or RAID_CLASS_COLORS["PRIEST"];
							local LEFT_TEXT = "";
							if(friend.LVL and (friend.LVL ~= '')) then
								local lC = GetQuestDifficultyColor(friend.LVL);
								LEFT_TEXT = format(TEXT_PATTERN3, friend.NAME, lC.r*255, lC.g*255, lC.b*255, friend.LVL, statusString)
							else
								LEFT_TEXT = friend.NAME .. statusString;
							end

							Reports.ToolTip:AddDoubleLine(LEFT_TEXT, friend.BNET_NAME, cC.r, cC.g, cC.b, 0.51, 0.773, 1)

							if IsShiftKeyDown() then
								local zC = (currentZone == friend.LOC) and MATCH_COLOR or MISMATCH_COLOR;
								local rC = (currentRealm == friend.REALM) and MATCH_COLOR or MISMATCH_COLOR;
								Reports.ToolTip:AddDoubleLine(friend.LOC, friend.REALM, zC.r, zC.g, zC.b, rC.r, rC.g, rC.b)
							end
						else
							Reports.ToolTip:AddLine(friend.BNET_NAME, 0.51, 0.773, 1)
						end
					end
				end
			end
		end
	end

	Reports:ShowDataTip()
end

Report.OnInit = function(self)
	BATTLENET_LABELS = {
		[BNET_CLIENT_WOW] = "|TInterface\\ChatFrame\\UI-ChatIcon-WOW:16:16:0:-1|t",
		[BNET_CLIENT_SC2] = "|TInterface\\ChatFrame\\UI-ChatIcon-SC2:16:16:0:-1|t",
		[BNET_CLIENT_D3] = "|TInterface\\ChatFrame\\UI-ChatIcon-D3:16:16:0:-1|t",
		[BNET_CLIENT_WTCG] = "|TInterface\\ChatFrame\\UI-ChatIcon-WTCG:16:16:0:-1|t",
		[BNET_CLIENT_HEROES] = "|TInterface\\ChatFrame\\UI-ChatIcon-HotS:16:16:0:-1|t",
		[BATTLENET_OPTIONS_LABEL] = "|TInterface\\ChatFrame\\UI-ChatIcon-Battlenet:16:16:0:-1|t",
	};
	FRIEND_DATA[BATTLENET_OPTIONS_LABEL] = {}
	FRIEND_DATA[BNET_CLIENT_WOW] = {}
	FRIEND_DATA[BNET_CLIENT_D3] = {}
	FRIEND_DATA[BNET_CLIENT_SC2] = {}
	FRIEND_DATA[BNET_CLIENT_WTCG] = {}
	FRIEND_DATA[BNET_CLIENT_HEROES] = {}
	UpdateFriendsData();
	UPDATE_REQUIRED = false;
end
