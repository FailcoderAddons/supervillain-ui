--[[
##########################################################
S V U I   By: Failcoder
##########################################################
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--GLOBAL NAMESPACE
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
local len          	= string.len;
local sub          	= string.sub;
local trim          = string.trim;
--MATH
local math          = _G.math;
local floor         = math.floor
local random 		= math.random;
--TABLE
local table         = _G.table;
local tsort         = table.sort;
local tconcat       = table.concat;
local tinsert       = _G.tinsert;
local tremove       = _G.tremove;
local wipe          = _G.wipe;
--BLIZZARD API
local time 					= _G.time;
local difftime 			= _G.difftime;
 
local ChatFrame_AddMessageEventFilter = _G.ChatFrame_AddMessageEventFilter;
local ChatEdit_ChooseBoxForSend = _G.ChatEdit_ChooseBoxForSend;
--[[
##########################################################
GET ADDON DATA
##########################################################
]]--
local SV = _G['SVUI']
local L = SV.L
local LSM = _G.LibStub("LibSharedMedia-3.0")
local MOD = SV.Chat;
if(not MOD) then return end;
--[[
##########################################################
LOCAL VARS
##########################################################
]]--
local SetAllChatHooks, SetParseHandlers;
local internalTest = false
local locale = GetLocale()
local NewHook = hooksecurefunc;
--[[
	Quick explaination of what Im doing with all of these locals...
	Unlike many of the other modules, Chat has to continuously
	reference config settings which can start to get sluggish. What
	I have done is set local variables for every database value
	that the module can read efficiently. The function "UpdateLocals"
	is used to refresh these any time a change is made to configs
	and once when the mod is loaded.
]]--
local PLAYER_NAME = UnitName("player");
local PLAYER_FILTER = PLAYER_NAME:upper();
local CHAT_THROTTLE = 45;
local CHAT_ALLOW_URL = true;
local CHAT_HOVER_URL = true;
local CHAT_STICKY = true;
local TAB_WIDTH = 75;
local TAB_HEIGHT = 20;
local TAB_SKINS = true;
local CHAT_FADING = false;
local CHAT_ABBREV = false;
local TIME_STAMP_MASK = "NONE";
local THROTTLE_CACHE = {};
local COPY_LINES = {};
local ACTIVE_HYPER_LINK;
local TABS_DIRTY = false;
local HIDE_REALM = false;
--[[
##########################################################
INIT SETTINGS
##########################################################
]]--
local REFRESH_LOCKED = false;
local CHANNEL_LINK   		= "|Hchannel:%1$s|h%d:|h"
local CHANNEL_PATTERN      	= "|Hchannel:(.-)|h%[(%d+)%.%s?([^:%-%]]+)%s?[:%-]?%s?[^|%]]*%]|h%s?"
local CHANNEL_PATTERN_PLUS 	= CHANNEL_PATTERN .. ".+"
local CHANNEL_STRINGS 		= {
	[L["Conversation"]] 	= L["S_Conversation"],
	[L["General"]] 			= L["S_General"],
	[L["LocalDefense"]] 	= L["S_LocalDefense"],
	[L["LookingForGroup"]] 	= L["S_LookingForGroup"],
	[L["Trade"]] 			= L["S_Trade"],
	[L["WorldDefense"]] 	= L["WorldDefense"],
}
local INTERNAL_TABLES = { 'channelList', 'zoneChannelList', 'messageTypeList' };
local SECRET_SOUND = [[Interface\AddOns\SVUI_!Core\assets\sounds\whisper.mp3]];
local WHISPER_SOUND = [[Interface\AddOns\SVUI_!Core\assets\sounds\whisper.mp3]];

local GENERAL_LINK_PATTERN = "[^%:]+";
local GENERAL_REALM_PATTERN = "%-[^|]+";
local PLAYER_PATTERN = "|Hplayer:(.-)|h%[(.-)%]|h";
local PLAYER_LINK    = "|Hplayer:%s|h%s|h"
local PLAYER_BN_LINK = "|HBNplayer:%s|h%s%s|h"
local BNPLAYER_PATTERN = "|HBNplayer:(.-)|h%[(|Kb(%d+).-)%](.*)|h"
--[[
##########################################################
LOCAL FUNCTIONS
##########################################################
]]--
local function case_insensitive(source)
  local p = source:gsub("(%%?)(.)", function(percent, letter)
    if percent ~= "" or not letter:match("%a") then
      return percent .. letter
    else
      return format("[%s%s]", letter:lower(), letter:upper())
    end
  end)
  return p
end

local PLAYERNAME_MATCH = case_insensitive(PLAYER_NAME);

local AddModifiedMessage;
local ScrollIndicator = CreateFrame("Frame", nil)
local HighLight_OnUpdate = function(self)
	if(self:IsMouseOver(50, -2, 0, 50)) then
		self.texture:SetGradientAlpha("HORIZONTAL",0,1,0,0.8,0,0.3,0,0)
	else
		self.texture:SetGradientAlpha("HORIZONTAL",0,1,1,0.8,0,0.3,0.3,0)
	end
end
do
	local EmoteCount = 38;
	local EmotePatterns = {
		{
			"%:%-%@","%:%@","%:%-%)","%:%)","%:D","%:%-D","%;%-D","%;D","%=D",
			"xD","XD","%:%-%(","%:%(","%:o","%:%-o","%:%-O","%:O","%:%-0",
			"%:P","%:%-P","%:p","%:%-p","%=P","%=p","%;%-p","%;p","%;P","%;%-P",
			"%;%-%)","%;%)","%:S","%:%-S","%:%,%(","%:%,%-%(","%:%'%(",
			"%:%'%-%(","<3","</3",
			--"%:%F",
		},
		{
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\angry.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\angry.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\happy.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\happy.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\grin.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\grin.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\grin.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\grin.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\grin.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\grin.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\grin.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\sad.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\sad.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\surprise.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\surprise.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\surprise.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\surprise.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\surprise.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\tongue.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\tongue.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\tongue.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\tongue.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\tongue.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\tongue.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\tongue.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\tongue.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\tongue.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\tongue.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\winky.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\winky.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\hmm.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\hmm.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\weepy.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\weepy.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\weepy.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\weepy.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\heart.blp]],
			[[Interface\AddOns\SVUI_Chat\assets\Emoticons\broken_heart.blp]],
			--[[Interface\AddOns\SVUI_Chat\assets\Emoticons\middle_finger.blp]]
		}
	}

	local function GetEmoticon(pattern)
		for i=1, #EmotePatterns[1] do
			local emote,icon = EmotePatterns[1][i], EmotePatterns[2][i];
			pattern = gsub(pattern, emote, "|T" .. icon .. ":16|t");
		end
		return pattern;
	end

	local function SetEmoticon(text)
		if not text then return end
		if (not SV.db.Chat.smileys or text:find(" / run") or text:find(" / dump") or text:find(" / script")) then
			return text
		end
		local result = "";
		local maxLen = len(text);
		local count = 1;
		local temp, pattern;
		while count  <= maxLen do
			temp = maxLen;
			local section = find(text, "|H", count, true)
			if section ~= nil then temp = section end
			pattern = sub(text, count, temp);
			result = result .. GetEmoticon(pattern)
			count = temp  +  1;
			if section ~= nil then
				temp = find(text, "|h]|r", count, -1) or find(text, "|h", count, -1)
				temp = temp or maxLen;
				if count < temp then
					result = result..sub(text, count, temp)
					count = temp  +  1;
				end
			end
		end
		return result
	end

	local SVUI_ParseMessage = function(self, event, text, ...)
		if(not CHAT_ALLOW_URL) then
			text = SetEmoticon(text)
			return false, text, ...
		end
		local result, ct = text:gsub("(%a+)://(%S+)%s?", "%1://%2")
		if ct > 0 then
			return false, SetEmoticon(result), ...
		end
		result, ct = text:gsub("www%.([_A-Za-z0-9-]+)%.(%S+)%s?", "www.%1.%2")
		if ct > 0 then
			return false, SetEmoticon(result), ...
		end
		result, ct = text:gsub("([_A-Za-z0-9-%.]+)@([_A-Za-z0-9-]+)(%.+)([_A-Za-z0-9-%.]+)%s?", "%1@%2%3%4")
		if ct > 0 then
			return false, SetEmoticon(result), ...
		end
		text = SetEmoticon(text)
		return false, text, ...
	end

	local function _concatTimeStamp(msg)
		if (TIME_STAMP_MASK and TIME_STAMP_MASK ~= 'NONE' ) then
			local timeStamp = BetterDate(TIME_STAMP_MASK, time());
			timeStamp = timeStamp:gsub(' ', '')
			timeStamp = timeStamp:gsub('AM', ' AM')
			timeStamp = timeStamp:gsub('PM', ' PM')
			msg = '|cffB3B3B3['..timeStamp..'] |r'..msg
		end
		return msg
	end

	local function _getlink(this, prefix, text, color)
	    text = tostring(text)
	    local colorstring = ("|cff%s%s|r"):format(color or "ffffff", tostring(this))
	    return format("|H%s:%s|h%s|h", prefix, text, colorstring)
	end

	local function _parse(arg1, arg2, arg3)
		internalTest = true;
		local prefix = (" [%s]"):format(arg2)
		local slink = _getlink(prefix, "url", arg2, "0099FF")
		return ("%s "):format(slink)
	end

	local function _escape(arg1)
		return arg1:gsub("([%%%+%-%.%[%]%*%?])", "%%%1")
	end

	function AddModifiedMessage(self, message, ...)
		internalTest = false;
		if type(message) == "string" then
			-- if(message:find("%pHshare%p+") or message:find("%pHSHARE%p+")) then
			-- 	internalTest = true
			-- end

			-- print(message)

			if((not internalTest) and CHAT_ABBREV) then
				local channelData, channelID, channelName = message:match(CHANNEL_PATTERN_PLUS)
				if(channelData) then
					local shortName = CHANNEL_STRINGS[channelName] or CHANNEL_STRINGS[channelName:lower()] or channelName:sub(1, 2);
					message = message:gsub(CHANNEL_PATTERN, CHANNEL_LINK:format(channelData, channelID, shortName))
				end

				local playerData, playerName = message:match(PLAYER_PATTERN)

				if(playerData) then
					local strName = playerName
					if(HIDE_REALM) then
						if(playerName:match("|cff")) then
							strName = playerName:gsub(GENERAL_REALM_PATTERN, "")
						else
							strName = playerName:match("[^%-]+")
						end
					else
						if(not playerName:match("|cff")) then
							strName = playerName:match("[^%-]+")
						end
					end
					strName = "[" .. strName .. "]"
					message = message:gsub(PLAYER_PATTERN, PLAYER_LINK:format(playerData, strName))
				elseif(channelID) then
					message = message:gsub("(|Hchannel:.-|h): ", "%1 ", 1)
				end

				local bnData, bnName, bnID, bnExtra = message:match(BNPLAYER_PATTERN)
				if bnData and bnName then
					local toastIcon = message:match("|TInterface\\FriendsFrame\\UI%-Toast%-ToastIcons.-|t")
					if toastIcon then
						local gameIcon = message:match("|TInterface\\ChatFrame\\UI%-ChatIcon.-|t")
						if gameIcon then
							message = message:gsub(_escape(toastIcon), gameIcon, 1)
							bnExtra = bnExtra:gsub("%s?%(.-%)", "")
						end
					end
					message = gsub(message, BNPLAYER_PATTERN, format(PLAYER_BN_LINK, bnData, bnName, bnExtra or ""))
				end
			end

			if(message:find("%pTInterface%p+") or message:find("%pTINTERFACE%p+")) then
				internalTest = true
			end

			if not internalTest then message = message:gsub("(%s?)(%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?:%d%d?%d?%d?%d?)(%s?)", _parse) end
			if not internalTest then message = message:gsub("(%s?)(%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?)(%s?)", _parse) end
			if not internalTest then message = message:gsub("(%s?)([%w_-]+%.?[%w_-]+%.[%w_-]+:%d%d%d?%d?%d?)(%s?)", _parse) end
			if not internalTest then message = message:gsub("(%s?)(%a+://[%w_/%.%?%%=~&-'%-]+)(%s?)", _parse) end
			if not internalTest then message = message:gsub("(%s?)(www%.[%w_/%.%?%%=~&-'%-]+)(%s?)", _parse) end
			if not internalTest then message = message:gsub("(%s?)([_%w-%.~-]+@[_%w-]+%.[_%w-%.]+)(%s?)", _parse) end
			if(self.___isFaded) then
				--message = message:gsub("|TInterface\\TargetingFrame\\UI%-RaidTargetingIcon_(.*)|t", "")
				message = message:gsub("|TInterface.-|t", "")
				message = message:gsub("(%s?)({.-})(%s?)", "");
			end
		end
		self.TempAddMessage(self, _concatTimeStamp(message), ...)
	end

	local Standard_ChatEventFilter = function(self, event, message, author, ...)
		if locale == 'enUS' or locale == 'enGB' then
			if message:find('[\227-\237]') then
				return true;
			end
		end

		return SVUI_ParseMessage(self, event, message, author, ...)
	end

	local AntiSpam_ChatEventFilter = function(self, event, message, author, ...)
		if locale == 'enUS' or locale == 'enGB' then
			if message:find('[\227-\237]') then
				return true;
			end
		end

		--print(message)
		local test, flags = message:gsub("(%s?)({.-})(%s?)", "");
    if(flags and (flags > 1)) then
    	if(flags > 2) then
			return true;
	    end
    end

		if(CHAT_THROTTLE ~= 0) then
			local sentFrom = author:upper()
			if(not sentFrom:find(PLAYER_FILTER)) then
				local msg
				if(self.GetID) then
					local chatID = self:GetID() or 0;
					msg = chatID .. sentFrom .. message;
				else
					msg = sentFrom .. message;
				end
				if(msg ~= nil) then
					if THROTTLE_CACHE[msg] then
						local timeDiff = (time() - THROTTLE_CACHE[msg]) or 0
						if timeDiff <= CHAT_THROTTLE then
							return true;
						end
					end
					THROTTLE_CACHE[msg] = time()
				end
			end
		end

		if(message:find(PLAYERNAME_MATCH) and (not InCombatLockdown())) then
	

			PlaySoundFile(SECRET_SOUND, SV.db.Chat.mention_channel or "Master")
		end

		return SVUI_ParseMessage(self, event, message, author, ...)
	end

	function SetParseHandlers()
		ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", AntiSpam_ChatEventFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", AntiSpam_ChatEventFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", AntiSpam_ChatEventFilter)

		ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", Standard_ChatEventFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", Standard_ChatEventFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", Standard_ChatEventFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_OFFICER", Standard_ChatEventFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", Standard_ChatEventFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", Standard_ChatEventFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", Standard_ChatEventFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", Standard_ChatEventFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT", Standard_ChatEventFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT_LEADER", Standard_ChatEventFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_CONVERSATION", Standard_ChatEventFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER", Standard_ChatEventFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER_INFORM", Standard_ChatEventFilter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_INLINE_TOAST_BROADCAST", Standard_ChatEventFilter);
	end
end
--[[
##########################################################
CORE FUNCTIONS
##########################################################
]]--
local TabsList = {};

local function removeIconFromLine(text)
	-- for i=1, 8 do
	-- 	text = gsub(text, "|TInterface\\TargetingFrame\\UI%-RaidTargetingIcon_"..i..":0|t", "")
	-- end
	text = gsub(text, "(|TInterface(.*)|t)", "")
	return text
end

function MOD:FadeLines(frame)
	--print('Fading Lines for '..frame:GetName())
	if(frame.___isFaded) then return end
	for i = select("#", frame:GetRegions()), 1, -1 do
		local region = select(i, frame:GetRegions())
		if region:GetObjectType() == "FontString" then
			local line = tostring(region:GetText())
			local newtext = removeIconFromLine(line)
			region:SetText(newtext)
			region:SetAlpha(0)
		end
	end
	frame.___isFaded = true;
end

function MOD:ShowLines(frame)
	for i = select("#", frame:GetRegions()), 1, -1 do
		local region = select(i, frame:GetRegions())
		if region:GetObjectType() == "FontString" then
			region:SetAlpha(1)
		end
	end
	frame.___isFaded = nil;
end

function MOD:GetLines(...)
	local index = 1
	for i = select("#", ...), 1, -1 do
		local region = select(i, ...)
		if region:GetObjectType() == "FontString" then
			local line = tostring(region:GetText())
			COPY_LINES[index] = removeIconFromLine(line)
			index = index + 1
		end
	end
	return index - 1
end

do
	local EB_HISTORY, EBH_LINE = {},{};
	local doskey = false;

	local _hook_AddHistoryLine = function(self, text)
		if(not text or len(text) == 0) then
			return
		end
		local cmd = text:match("^(/%S+)")
		if(cmd and IsSecureCmd(cmd)) then
			return
		end
		local ebName = self:GetName();
		local frameHistory = EB_HISTORY[ebName];
		local histCount = #frameHistory;
		for i=1,histCount do
			if frameHistory[i] == text then
				EBH_LINE[ebName] = i + 1
				return
			end
		end
		histCount=histCount+1;
		frameHistory[histCount] = text;
		local histLines = self:GetHistoryLines();
		for i=1,histCount do
			if i > histLines then
				frameHistory[i] = nil;
				histCount=histCount-1;
			end
		end
		EBH_LINE[ebName] = histCount+1;
	end

	local function UpdateFromEditBoxHistory(self, increment)
		local ebName = self:GetName();
		if(#EB_HISTORY[ebName] == 0) then return end
		local current_line = EBH_LINE[ebName] + increment
		if(current_line < 1) then
			current_line = #EB_HISTORY[ebName];
		elseif(current_line > #EB_HISTORY[ebName]) then
			current_line = 1;
		end
		EBH_LINE[ebName] = current_line;
		if(EB_HISTORY[ebName][current_line] ~= self:GetText()) then
			local text = EB_HISTORY[ebName][current_line];
			self:SetText(trim(text));
			self:SetCursorPosition(len(text));
		end
	end

	local SetHyperlink = ItemRefTooltip.SetHyperlink
	function ItemRefTooltip:SetHyperlink(data, ...)
		if (data):sub(1, 3) == "url" then
			local ChatFrameEditBox = ChatEdit_ChooseBoxForSend()
			local currentLink = (data):sub(5)
			if (not ChatFrameEditBox:IsShown()) then
				ChatEdit_ActivateChat(ChatFrameEditBox)
			end
			ChatFrameEditBox:Insert(currentLink)
			ChatFrameEditBox:HighlightText()
		else
			SetHyperlink(self, data, ...)
		end
	end

	local _hook_TabTextColor = function(self, r, g, b, a)
		local val = r + g + b;
		if(val ~= 3) then
			self:SetTextColor(1, 1, 1, 1)
			self:SetShadowColor(0, 0, 0)
			self:SetShadowOffset(2, -2)
		end
	end

	local EditBox_OnArrowPressed = function(self, key)
		if(not key) then return end
		if(doskey) then
			if(key == "LEFT") then
				self:SetCursorPosition(0)
			elseif(key == "RIGHT") then
				self:SetCursorPosition(self:GetNumLetters())
			end
			doskey = false
		elseif key == "UP" then
			doskey = true
			return UpdateFromEditBoxHistory(self, -1)
		elseif key == "DOWN" then
			doskey = true
			return UpdateFromEditBoxHistory(self, 1)
		end
	end

	local EditBox_OnEditFocusGained = function(self)
		self:Show()
		if not self.DockLink:IsShown()then
			self.DockLink.editboxforced = true;
			self.DockLink.Bar.Button:GetScript("OnEnter")(self.DockLink.Bar.Button)
		end
		self.DockLink.Alert:Activate(self)
	end

	local EditBox_OnEditFocusLost = function(self)
		if self.DockLink.editboxforced then
			self.DockLink.editboxforced = nil;
			if self.DockLink:IsShown()then
				self.DockLink.Bar.Button:GetScript("OnLeave")(self.DockLink.Bar.Button)
			end
		end
		self:Hide()
		self.DockLink.Alert:Deactivate()
		doskey = false
	end

	local EditBox_OnTextChanged = function(self)
		local text = self:GetText()
		if(InCombatLockdown()) then
			local max = 5;
			if(len(text) > max) then
				local testText = true;
				for i = 1, max, 1 do
					if(sub(text, 0 - i, 0 - i) ~= sub(text, -1 - i, -1 - i)) then
						testText = false;
						break
					end
				end
				if(testText) then
					self:Hide()
					return
				end
			end
		end

		if(text:len() < 5) then
			if(text:sub(1, 4) == "/tt ") then
				local name, realm = UnitName("target")
				if(name) then
					name = gsub(name, " ", "")
					if(name and (not UnitIsSameServer("player", "target"))) then
						name = name.."-"..gsub(realm, " ", "")
					end
				else
					name = L["Invalid Target"]
				end
				ChatFrame_SendTell(name, ChatFrame1)
			end
			if(text:sub(1, 4) == "/gr ") then
				self:SetText(MOD:GetGroupDistribution()..text:sub(5))
				ChatEdit_ParseText(self, 0)
				doskey = false
			end
		end

		local result, ct = text:gsub("|Kf(%S+)|k(%S+)%s(%S+)|k", "%2 %3")
		if(ct > 0) then
			result = result:gsub("|", "")
			self:SetText(result)
			doskey = false
		end
	end

	local function _customTab(tab, holder)
		if(tab.Holder) then return end
		local chatID = tab.chatID;
		local tabName = tab:GetName();

		holder.widthMultiplier = 1.75;
		holder:SetWidth(holder:GetWidth() * 1.75)

		tab:SetParent(holder)
		tab:ClearAllPoints()
		tab:SetAllPoints(holder)

		if(tab.conversationIcon) then
			tab:SetPanelColor("VERTICAL", 0.1, 0.53, 0.65, 0.6, 0.2, 1)
			holder.Icon:SetGradient("VERTICAL", 0.1, 0.53, 0.65, 0.3, 0.7, 1)
		else
			tab:SetPanelColor("default")
			holder.Icon:SetGradient(unpack(SV.media.gradient.icon))
		end

		holder.Icon:SetAlpha(0.5);
		holder.Icon:ClearAllPoints()
		holder.Icon:InsetPoints(holder, 6, 3)
		holder.Icon:SetDrawLayer("BORDER")
		tab.icon = holder.Icon;

		tab:SetAlpha(1);
		tab:EnableMouse(false);

		tab.SetAlpha = SV.fubar
		tab.SetHeight = SV.fubar
		tab.SetWidth = SV.fubar
		tab.SetSize = SV.fubar
		tab.SetParent = SV.fubar
		tab.ClearAllPoints = SV.fubar
		tab.SetAllPoints = SV.fubar
		tab.SetPoint = SV.fubar

		holder.link = tab
		tab.Holder = holder
	end

	local ChatDockTab_OnEnter = function(self)
		self = self.link
		local chatID = self:GetID();
		local chatFrame = _G[("ChatFrame%d"):format(chatID)];
		local tabText = self.text:GetText() or "Chat "..chatID;
		GameTooltip:AddLine(tabText, 1, 1, 0);
		GameTooltip:AddLine(" ", 1, 1, 1);
	    if ( chatFrame.isTemporary and chatFrame.chatType == "BN_CONVERSATION" ) then
	        BNConversation_DisplayConversationTooltip(tonumber(chatFrame.chatTarget));
	    else
	        GameTooltip_AddNewbieTip(self, CHAT_OPTIONS_LABEL, 1.0, 1.0, 1.0, NEWBIE_TOOLTIP_CHATOPTIONS, 1);
	    end
	end

	local ChatDock_ResizeCallback = function(self)
		if(not InCombatLockdown()) then
			local chat = self.Owner;
			chat:ClearAllPoints();
			chat:SetAllPoints(self);
		end
	end

	local ChatDock_HideCallback = function(self)
		--print('ChatDock_HideCallback ' .. self:GetName())
		--print('ChatDock_HideCallback: ' .. self.Button:GetName())
		local chat = self.Owner;
		MOD:FadeLines(chat)
		chat:FadeOut(0.2, chat:GetAlpha(), 0, true)
		chat:ForceHide(true)
	end

	local ChatDock_ShowCallback = function(self)
		--print('ChatDock_ShowCallback ' .. self:GetName())
		local chat = self.Owner;
		MOD:ShowLines(chat)
		chat:ForceHide(false)
		chat:FadeIn(0.2, chat:GetAlpha(), 1)
	end

	local ChatDock_LeftClickCallback = function(self, button)
		local chatTab = self.link
		local chatFrame = _G[("ChatFrame%d"):format(chatTab:GetID())];
		-- if(not self.isFloating) then
		-- 	FCF_Tab_OnClick(chatTab, button);
		-- end
		ScrollIndicator:ClearAllPoints()
		ScrollIndicator:SetPoint("BOTTOMRIGHT", chatFrame, "BOTTOMRIGHT", 6, 0)
		if(chatFrame:AtBottom() and ScrollIndicator:IsShown()) then
			SV.Animate:StopFlash(ScrollIndicator)
			ScrollIndicator:Hide()
		elseif(not chatFrame:AtBottom() and not ScrollIndicator:IsShown()) then
			ScrollIndicator:Show()
			SV.Animate:Flash(ScrollIndicator,1,true)
		end
		if(not InCombatLockdown()) then
			chatFrame:ClearAllPoints();
			chatFrame:SetAllPoints(chatFrame.Dock);
		end
	end

	local ChatDock_FontSizeSliderFunc = function(self, value)
		SV.media.shared.font.chatdialog.size = value;
		SV.Events:Trigger("FONT_GROUP_UPDATED", "chatdialog");
	end

	local function ConfigChatFrame(chat)
		if(not chat) then return; end
		local chatName = chat:GetName();
		local chatID = chat:GetID();
		local tabName = chatName.."Tab";
		local tabText = _G[chatName.."TabText"];
		local tab = _G[tabName];
		local editBoxName = chatName.."EditBox";
		local editBox = _G[editBoxName];
		local dropdown = _G[tabName.."DropDown"]
		local tabEnabled = (chat.inUse or chat.isDocked or chat.isTemporary);
		-------------------------------------------
		SV:SetFrameVisibilityLocks(chat);
		-------------------------------------------
		--chat:SetStyle("Frame", "Transparent", true, 1, 3, 6);
		--chat.Panel:Hide();
		chat.Dock = SV.Dock:NewDocklet("BottomLeft", format("SVUI_ChatFrameDock%d", chatID), "Chat Frame "..chatID, MOD.media.dockIcon, ChatDockTab_OnEnter);
		chat.Dock.Owner = chat;

		local ChatDock_ExtendedOptions;
		if(chatID == 1) then
			ScrollIndicator:ClearAllPoints()
			ScrollIndicator:SetPoint("BOTTOMRIGHT", chat, "BOTTOMRIGHT", 6, 0)
			ChatDock_ExtendedOptions = function()
				local t = {};
				local currentFontSize = SV.media.shared.font.chatdialog.size;
				tinsert(t, { title = CHAT, divider = true });
				tinsert(t, { text = RENAME_CHAT_WINDOW, func = function() CURRENT_CHAT_FRAME_ID = 1; FCF_RenameChatWindow_Popup(); end });
				tinsert(t, { text = NEW_CHAT_WINDOW, func = function() CURRENT_CHAT_FRAME_ID = 1; SV:StaticPopup_Show("NEW_CHAT_DOCK"); end });
				tinsert(t, { text = RESET_ALL_WINDOWS, func = function() CURRENT_CHAT_FRAME_ID = 1; MOD:ResetChatWindows(); end });
				tinsert(t, { text = CHAT_CONFIGURATION, func = function() CURRENT_CHAT_FRAME_ID = 1; ShowUIPanel(ChatConfigFrame); end });
				tinsert(t, { title = FONT_SIZE, divider = true });
				tinsert(t, { range = {8,20}, value = currentFontSize, func = ChatDock_FontSizeSliderFunc });
				return t;
			end
		else
			ChatDock_ExtendedOptions = function()
				local t = {};
				tinsert(t, { title = CHAT, divider = true });
				if(not chat.isTemporary) then
					tinsert(t, { text = RENAME_CHAT_WINDOW, func = function() CURRENT_CHAT_FRAME_ID = chatID; FCF_RenameChatWindow_Popup(); end });
					tinsert(t, { text = CHAT_CONFIGURATION, func = function() CURRENT_CHAT_FRAME_ID = chatID; ShowUIPanel(ChatConfigFrame); end });
				end
				tinsert(t, { text = CLOSE_CHAT_WINDOW, func = function() CURRENT_CHAT_FRAME_ID = chatID; FCF_Close(); end });
				return t;
			end
		end

		chat.Dock:SetVisibilityCallbacks(ChatDock_ShowCallback, ChatDock_HideCallback, ChatDock_ResizeCallback);
		chat.Dock:SetClickCallbacks(ChatDock_LeftClickCallback, false, ChatDock_ExtendedOptions);
		--chat.Dock:FadeCallback(ChatDock_ResizeCallback, false, true);
		-------------------------------------------
		SV:FontManager(chat, "chatdialog", "LEFT")
		SV:FontManager(editBox, "chatdialog", "LEFT", false, "NONE")
		SV:FontManager(tabText, "chattab")

		if(SV.media.shared.font.chatdialog.outline ~= 'NONE' ) then
			chat:SetShadowColor(0, 0, 0, 0)
			chat:SetShadowOffset(0, 0)
		else
			chat:SetShadowColor(0, 0, 0, 1)
			chat:SetShadowOffset(1, -1)
		end

		chat:SetFrameLevel(10)
		chat:SetClampRectInsets(0, 0, 0, 0)
		chat:SetClampedToScreen(false);
		chat:SetMovable(true);
		chat:SetUserPlaced(true);

		chat:RemoveTextures(true)
		chat:SetBackdropColor(0,0,0,0)
		chat:SetBackdropBorderColor(1,0,0,1)

		_G[chatName.."ButtonFrame"]:Die()
		-------------------------------------------
		_G[tabName .."Left"]:SetTexture("")
		_G[tabName .."Middle"]:SetTexture("")
		_G[tabName .."Right"]:SetTexture("")
		_G[tabName .."SelectedLeft"]:SetTexture("")
		_G[tabName .."SelectedMiddle"]:SetTexture("")
		_G[tabName .."SelectedRight"]:SetTexture("")
		_G[tabName .."HighlightLeft"]:SetTexture("")
		_G[tabName .."HighlightMiddle"]:SetTexture("")
		_G[tabName .."HighlightRight"]:SetTexture("")

		tabText:SetTextColor(1, 1, 1, 1)
		tabText:SetShadowColor(0, 0, 0)
		tabText:SetShadowOffset(2, -2)
		tabText:ClearAllPoints()
		tabText:InsetPoints(tab)
		tabText:SetJustifyH("CENTER")
		tabText:SetJustifyV("MIDDLE")
		tabText:SetAlpha(1)
		NewHook(tabText, "SetTextColor", _hook_TabTextColor)
		tabText:Show()
		tab.text = tabText

		if tab.conversationIcon then
			tab.conversationIcon:SetAlpha(0)
			tab.conversationIcon:ClearAllPoints()
			tab.conversationIcon:SetPoint("TOPLEFT", tab, "TOPLEFT", 0, 0)
		end

		tab.chatID = chatID;

		_customTab(tab, chat.Dock.Button)
		-------------------------------------------
		local ebPoint1, ebPoint2, ebPoint3 = select(6, editBox:GetRegions())
		ebPoint1:Die()
		ebPoint2:Die()
		ebPoint3:Die()
		_G[editBoxName.."FocusLeft"]:Die()
		_G[editBoxName.."FocusMid"]:Die()
		_G[editBoxName.."FocusRight"]:Die()
		editBox:SetAltArrowKeyMode(false)
		editBox:SetAllPoints(chat.Dock.Parent.Alert)
		SV.API:Set("!_EditBox", editBox, false, false, -2, -1)

		if(not EB_HISTORY[editBoxName]) then
			editBox:HookScript("OnEditFocusGained", EditBox_OnEditFocusGained)
			editBox:HookScript("OnEditFocusLost", EditBox_OnEditFocusLost)
			editBox:HookScript("OnTextChanged", EditBox_OnTextChanged)
			editBox:HookScript("OnArrowPressed", EditBox_OnArrowPressed)
			hooksecurefunc(editBox, "AddHistoryLine", _hook_AddHistoryLine)
			EB_HISTORY[editBoxName] = {};
			EBH_LINE[editBoxName] = {};
		end

		editBox.DockLink = chat.Dock.Parent;
		-------------------------------------------
		chat:SetTimeVisible(100)
		chat:SetFading(CHAT_FADING)
		--chat:HookScript("OnHyperlinkClick", SVUI_OnHyperlinkShow)

		local alertSize = chat.Dock.Bar:GetHeight();
		local alertOffset = alertSize * 0.25
		local alert = CreateFrame("Frame", nil, tab)
		alert:SetSize(alertSize, alertSize)
		alert:SetFrameStrata("DIALOG")
		alert:SetPoint("TOPRIGHT", tab, "TOPRIGHT", alertOffset, alertOffset)
		local alticon = alert:CreateTexture(nil, "OVERLAY")
		alticon:SetAllPoints(alert)
		alticon:SetTexture(MOD.media.whisperIcon)
		alert:Hide()
		chat.WhisperAlert = alert

		--copy chat button
		tab.CopyButton = CreateFrame('Frame', format("SVUI_CopyChatButton%d", chatID), chat)
		tab.CopyButton:SetAlpha(0.35)
		tab.CopyButton:SetSize(38, 18)
		tab.CopyButton:SetPoint('TOPRIGHT', chat, 'TOPRIGHT', 0, 0)
		tab.CopyButton:SetStyle("Frame", "Lite")

		tab.CopyButton.Title = tab.CopyButton:CreateFontString()
		tab.CopyButton.Title:SetFontObject(SVUI_Font_ChatTab)
		tab.CopyButton.Title:SetText("copy")
		tab.CopyButton.Title:InsetPoints(tab.CopyButton)
		tab.CopyButton.Title:SetTextColor(1,0.8,0)

		tab.CopyButton:SetScript("OnMouseUp", function(self, btn)
			if btn == "RightButton" and chatID == 1 then
				ToggleFrame(ChatMenu)
			else
				MOD:CopyChat(chat)
			end
		end)

		tab.CopyButton:SetScript("OnEnter", function(self) self:FadeIn() end)
		tab.CopyButton:SetScript("OnLeave", function(self) self:FadeOut() end)
		tab.CopyButton:FadeOut()
	end

	local _linkTokens = {
		['item'] = true,
		['spell'] = true,
		['unit'] = true,
		['quest'] = true,
		['enchant'] = true,
		['achievement'] = true,
		['instancelock'] = true,
		['talent'] = true,
		['glyph'] = true,
	}

	local _hook_OnHyperlinkEnter = function(self, refString)
		if(not CHAT_HOVER_URL or InCombatLockdown()) then return; end
		local token = refString:match("^([^:]+)")
		if _linkTokens[token] then
			ShowUIPanel(GameTooltip)
			GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
			GameTooltip:SetHyperlink(refString)
			ACTIVE_HYPER_LINK = self;
			GameTooltip:Show()
		end
	end

	local _hook_OnHyperlinkLeave = function(self)
		if(not CHAT_HOVER_URL) then return; end
		HideUIPanel(GameTooltip)
		ACTIVE_HYPER_LINK = nil;
	end

	local _hook_OnMessageScrollChanged = function(self)
		if(not CHAT_HOVER_URL) then return; end
		if(ACTIVE_HYPER_LINK == self) then
			HideUIPanel(GameTooltip)
			ACTIVE_HYPER_LINK = false;
		end
		if(self:AtBottom() and ScrollIndicator:IsShown()) then
			SV.Animate:StopFlash(ScrollIndicator)
			ScrollIndicator:Hide()
		elseif(not self:AtBottom() and not ScrollIndicator:IsShown()) then
			ScrollIndicator:Show()
			ScrollIndicator.parent = self
			SV.Animate:Flash(ScrollIndicator,1,true)
		end
	end

	local _hook_OnMouseWheel = function(self, delta)
		if(IsShiftKeyDown()) then
			if(delta and delta > 0) then
				self:ScrollToTop()
			else
				self:ScrollToBottom()
			end
		end
		if(self:AtBottom() and ScrollIndicator:IsShown()) then
			SV.Animate:StopFlash(ScrollIndicator)
			ScrollIndicator:Hide()
		elseif(not self:AtBottom() and not ScrollIndicator:IsShown()) then
			ScrollIndicator:Show()
			SV.Animate:Flash(ScrollIndicator,1,true)
		end
	end

	local _hook_TabOnEnter = function(self)
		if self.conversationIcon then
			self.conversationIcon:Show()
		end
	end

	local _hook_TabOnLeave = function(self)
		if self.conversationIcon then
			self.conversationIcon:Hide()
		end
	end

	local _forced_SetPoint = function(self, a1, p, a2, x, y)
		if(not self.Dock) then return end
		if((a1 ~= 'LEFT') or (a2 ~= 'LEFT') or (x ~= 0) or (y ~= 0)) then
			self:ClearAllPoints()
			self:SetPoint('LEFT', p, 'LEFT', 0, 0)
			self:SetSize(self.Dock:GetSize());
		end
	end

	local _forced_SetAllPoints = function(self, parent)
		if(self.Dock and (parent ~= self.Dock)) then
			self:ClearAllPoints()
			self:SetAllPoints(self.Dock)
		end
	end

	function MOD:RefreshChatFrames(event, forced)
		--print(event)
		if ((not forced) and (REFRESH_LOCKED and (IsMouseButtonDown("LeftButton") or InCombatLockdown()))) then return; end

		for i,name in pairs(CHAT_FRAMES) do
			local chat = _G[name]
			local id = chat:GetID()
			local tab = _G[name.."Tab"]
			local tabText = _G[name.."TabText"]

			if(not chat.Dock) then
				ConfigChatFrame(chat)
			end

			--FCF_SetLocked(chat, true);

			--/script print(ChatFrame1:GetLeft())
			--/script print(ChatFrame11:GetLeft())
			--/script local a1,p,a2,x,y = ChatFrame1.Dock:GetPoint(); print(p:GetName())print(a1..' '..a2..' '..x..' '..y)
			--/script local a1,p,a2,x,y = ChatFrame11.Dock:GetPoint(); print(p:GetName())print(a1..' '..a2..' '..x..' '..y)

			--/script ChatFrame11:SetBackdrop({bgFile = [[Interface\AddOns\SVUI_!Core\assets\backgrounds\DEFAULT]]})
			--/script ChatFrame11:ClearAllPoints()
			--/script ChatFrame11:SetAllPoints(ChatFrame11.Dock)
			--/script ChatFrame11.Dock:ClearAllPoints()
			--/script ChatFrame11.Dock:SetAllPoints(ChatFrame1.Dock)
			chat:SetBackdrop({
				bgFile = [[Interface\AddOns\SVUI_!Core\assets\textures\EMPTY]],
			    tile = false,
			    tileSize = 0,
			    edgeFile = [[Interface\AddOns\SVUI_!Core\assets\textures\EMPTY]],
			    edgeSize = 1,
			    insets =
			    {
			        left = 0,
			        right = 0,
			        top = 0,
			        bottom = 0,
			    },
			})
			chat:SetBackdropColor(0,0,0,0);
			chat:SetBackdropBorderColor(0,0,0,0);

			-- chat:SetPoint("TOPLEFT", chat.Dock, "TOPLEFT", 0, 0);
			-- chat:SetPoint("BOTTOMLEFT", chat.Dock, "BOTTOMLEFT", 0, 0);
			-- chat:SetPoint("TOPRIGHT", chat.Dock, "TOPRIGHT", 0, 0);
			-- chat:SetPoint("BOTTOMRIGHT", chat.Dock, "BOTTOMRIGHT", 0, 0);
			--local CHAT_WIDTH, CHAT_HEIGHT = chat.Dock:GetSize();
			--chat:SetSize(CHAT_WIDTH - 4, CHAT_HEIGHT - 4);

			--FCF_SavePositionAndDimensions(chat)

			--/svdf ChatFrame11
			--/svdf SVUI_ChatFrameDock11
			-- /script ChatFrame11:ClearAllPoints();
			-- /script ChatFrame11:WrapPoints(SVUI_ChatFrameDock11,10,10);

			--tab.Holder.CanFloat = true;
			--tabText:Hide()
			if(tab.CopyButton and (GetMouseFocus() ~= tab.CopyButton)) then
				tab.CopyButton:SetAlpha(0)
			end
			if tab.conversationIcon then
				tab.conversationIcon:Hide()
			end

			if((not chat.TempAddMessage) and (chat:GetID() ~= 2)) then
				chat.TempAddMessage = chat.AddMessage;
				chat.AddMessage = AddModifiedMessage
			end

			if(not chat.hookedHyperLinks) then
				chat:HookScript('OnHyperlinkEnter', _hook_OnHyperlinkEnter)
				chat:HookScript('OnHyperlinkLeave', _hook_OnHyperlinkLeave)
				--chat:HookScript('OnMessageScrollChanged', _hook_OnMessageScrollChanged)
				chat:HookScript('OnMouseWheel', _hook_OnMouseWheel)
				tab:HookScript('OnEnter', _hook_TabOnEnter)
				tab:HookScript('OnLeave', _hook_TabOnLeave)
				chat.hookedHyperLinks = true
			end

			chat.isDocked = nil;
			chat.hasBeenFaded = nil;
			chat.isUninteractable = true;
			chat.oldAlpha = 0;
			--FCF_FadeInChatFrame(chat);
			local isActive = MOD:IsChatActive(chat)
			chat.Dock:UpdateBackdrop()
			chat.Dock.Button:SetDocked(isActive)
			chat:ClearAllPoints();
			chat:SetAllPoints(chat.Dock);
			FCF_SetLocked(chat, true);
			SetChatWindowUninteractable(i, false);
			if(chat.name) then
				tabText:SetText(chat.name)
			end
		end

		REFRESH_LOCKED = true
	end
end

local function OpenNewSVUIChatFrame(newname)
	local chatFrame, chatTab;
	for i,name in pairs(CHAT_FRAMES) do
		chatFrame = _G[name];
		chatTab = _G[name.."Tab"];
		local key = format("SVUI_ChatFrameDock%d", i);
		local tabText = newname;
		if((not newname) or (newname == "")) then
			tabText = format(CHAT_NAME_TEMPLATE, i);
		end
		if(not MOD:IsChatActive(chatFrame)) then
			FCF_SetWindowName(chatFrame, tabText);
			FCF_SetLocked(chatFrame, false);

			-- clear stale messages
			chatFrame:Clear();

			-- Listen to the standard messages
			ChatFrame_RemoveAllMessageGroups(chatFrame);
			ChatFrame_RemoveAllChannels(chatFrame);
			ChatFrame_ReceiveAllPrivateMessages(chatFrame);
			--ChatFrame_ReceiveAllBNConversations(chatFrame);

			ChatFrame_AddMessageGroup(chatFrame, "SAY");
			ChatFrame_AddMessageGroup(chatFrame, "YELL");
			ChatFrame_AddMessageGroup(chatFrame, "GUILD");
			ChatFrame_AddMessageGroup(chatFrame, "WHISPER");
			ChatFrame_AddMessageGroup(chatFrame, "BN_WHISPER");
			ChatFrame_AddMessageGroup(chatFrame, "PARTY");
			ChatFrame_AddMessageGroup(chatFrame, "PARTY_LEADER");
			ChatFrame_AddMessageGroup(chatFrame, "CHANNEL");

			--Clear the edit box history.
			chatFrame.editBox:ClearHistory();

			-- Show the frame and tab
			chatFrame:Show();
			chatTab:Show();
			SetChatWindowShown(i, true);

			-- Dock the frame by default
			-- FCF_DockFrame(chatFrame, (#FCFDock_GetChatFrames(GENERAL_CHAT_DOCK)+1), true);
			-- FCF_FadeInChatFrame(FCFDock_GetSelectedWindow(GENERAL_CHAT_DOCK));

			--FCF_CopyChatSettings(chatFrame, DEFAULT_CHAT_FRAME);
			MOD:SaveActiveFlag(key,tabText);
			chatFrame:FadeIn(0.2, chatFrame:GetAlpha(), 1)
			MOD.RefreshChatFrames()
			return;
		end
	end
end

function MOD:ResetChatWindows()
	REFRESH_LOCKED = false;
	FCF_ResetChatWindows();

	MOD:ResetInternalData();

	for k,v in pairs(SV.Dock.private.Disabled) do
		if k:find("ChatFrame") then
			SV.Dock.private.Disabled[k] = nil
		end
	end

	for i=1, NUM_CHAT_WINDOWS do
		local chatFrame = _G["ChatFrame"..i];
		if(chatFrame) then
			chatFrame.isUninteractable = true;
			chatFrame:SetMovable(true);
		end
	end

	FCF_SetLocked(ChatFrame1, true)
	FCF_SetWindowName(ChatFrame1, GENERAL)
	if(ChatFrame1.Dock) then
		ChatFrame1.Dock:UpdateBackdrop()
		ChatFrame1.Dock:SetDocked(true)
	end
	MOD:SaveActiveFlag('SVUI_ChatFrameDock1',GENERAL);

	FCF_SetLocked(ChatFrame2, true)
	FCF_SetWindowName(ChatFrame2, GUILD_EVENT_LOG)
	if(ChatFrame2.Dock) then
		ChatFrame2.Dock:UpdateBackdrop()
		ChatFrame2.Dock:SetDocked(true)
	end
	MOD:SaveActiveFlag('SVUI_ChatFrameDock2',GUILD_EVENT_LOG);

	FCF_OpenNewWindow(LOOT)
	FCF_SetLocked(ChatFrame3, true)
	FCF_SetWindowName(ChatFrame3, LOOT)
	if(ChatFrame3.Dock) then
		ChatFrame3.Dock:UpdateBackdrop()
		ChatFrame3.Dock:SetDocked(true)
	end
	MOD:SaveActiveFlag('SVUI_ChatFrameDock3',LOOT);

	for i=4, NUM_CHAT_WINDOWS do
		local chatFrame = _G["ChatFrame"..i];
		if(chatFrame and chatFrame.Dock) then
			chatFrame.Dock:SetDocked(false)
		end
	end

	ChatFrame_RemoveAllMessageGroups(ChatFrame1)
	ChatFrame_AddMessageGroup(ChatFrame1, "SAY")
	ChatFrame_AddMessageGroup(ChatFrame1, "EMOTE")
	ChatFrame_AddMessageGroup(ChatFrame1, "YELL")
	ChatFrame_AddMessageGroup(ChatFrame1, "GUILD")
	ChatFrame_AddMessageGroup(ChatFrame1, "OFFICER")
	ChatFrame_AddMessageGroup(ChatFrame1, "GUILD_ACHIEVEMENT")
	ChatFrame_AddMessageGroup(ChatFrame1, "WHISPER")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_SAY")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_EMOTE")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_YELL")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_BOSS_EMOTE")
	ChatFrame_AddMessageGroup(ChatFrame1, "PARTY")
	ChatFrame_AddMessageGroup(ChatFrame1, "PARTY_LEADER")
	ChatFrame_AddMessageGroup(ChatFrame1, "RAID")
	ChatFrame_AddMessageGroup(ChatFrame1, "RAID_LEADER")
	ChatFrame_AddMessageGroup(ChatFrame1, "RAID_WARNING")
	ChatFrame_AddMessageGroup(ChatFrame1, "INSTANCE_CHAT")
	ChatFrame_AddMessageGroup(ChatFrame1, "INSTANCE_CHAT_LEADER")
	ChatFrame_AddMessageGroup(ChatFrame1, "BATTLEGROUND")
	ChatFrame_AddMessageGroup(ChatFrame1, "BATTLEGROUND_LEADER")
	ChatFrame_AddMessageGroup(ChatFrame1, "BG_HORDE")
	ChatFrame_AddMessageGroup(ChatFrame1, "BG_ALLIANCE")
	ChatFrame_AddMessageGroup(ChatFrame1, "BG_NEUTRAL")
	ChatFrame_AddMessageGroup(ChatFrame1, "SYSTEM")
	ChatFrame_AddMessageGroup(ChatFrame1, "ERRORS")
	ChatFrame_AddMessageGroup(ChatFrame1, "AFK")
	ChatFrame_AddMessageGroup(ChatFrame1, "DND")
	ChatFrame_AddMessageGroup(ChatFrame1, "IGNORED")
	ChatFrame_AddMessageGroup(ChatFrame1, "ACHIEVEMENT")
	ChatFrame_AddMessageGroup(ChatFrame1, "BN_WHISPER")
	ChatFrame_AddMessageGroup(ChatFrame1, "BN_CONVERSATION")
	ChatFrame_AddMessageGroup(ChatFrame1, "BN_INLINE_TOAST_ALERT")
	ChatFrame_AddMessageGroup(ChatFrame1, "COMBAT_FACTION_CHANGE")
	ChatFrame_AddMessageGroup(ChatFrame1, "SKILL")
	ChatFrame_AddMessageGroup(ChatFrame1, "LOOT")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONEY")
	ChatFrame_AddMessageGroup(ChatFrame1, "COMBAT_XP_GAIN")
	ChatFrame_AddMessageGroup(ChatFrame1, "COMBAT_HONOR_GAIN")
	ChatFrame_AddMessageGroup(ChatFrame1, "COMBAT_GUILD_XP_GAIN")

	ChatFrame_RemoveAllMessageGroups(ChatFrame3)
	ChatFrame_AddMessageGroup(ChatFrame3, "COMBAT_FACTION_CHANGE")
	ChatFrame_AddMessageGroup(ChatFrame3, "SKILL")
	ChatFrame_AddMessageGroup(ChatFrame3, "LOOT")
	ChatFrame_AddMessageGroup(ChatFrame3, "MONEY")
	ChatFrame_AddMessageGroup(ChatFrame3, "COMBAT_XP_GAIN")
	ChatFrame_AddMessageGroup(ChatFrame3, "COMBAT_HONOR_GAIN")
	ChatFrame_AddMessageGroup(ChatFrame3, "COMBAT_GUILD_XP_GAIN")

	ChatFrame_AddChannel(ChatFrame1, GENERAL)

	ToggleChatColorNamesByClassGroup(true, "SAY")
	ToggleChatColorNamesByClassGroup(true, "EMOTE")
	ToggleChatColorNamesByClassGroup(true, "YELL")
	ToggleChatColorNamesByClassGroup(true, "GUILD")
	ToggleChatColorNamesByClassGroup(true, "OFFICER")
	ToggleChatColorNamesByClassGroup(true, "GUILD_ACHIEVEMENT")
	ToggleChatColorNamesByClassGroup(true, "ACHIEVEMENT")
	ToggleChatColorNamesByClassGroup(true, "WHISPER")
	ToggleChatColorNamesByClassGroup(true, "PARTY")
	ToggleChatColorNamesByClassGroup(true, "PARTY_LEADER")
	ToggleChatColorNamesByClassGroup(true, "RAID")
	ToggleChatColorNamesByClassGroup(true, "RAID_LEADER")
	ToggleChatColorNamesByClassGroup(true, "RAID_WARNING")
	ToggleChatColorNamesByClassGroup(true, "BATTLEGROUND")
	ToggleChatColorNamesByClassGroup(true, "BATTLEGROUND_LEADER")
	ToggleChatColorNamesByClassGroup(true, "INSTANCE_CHAT")
	ToggleChatColorNamesByClassGroup(true, "INSTANCE_CHAT_LEADER")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL1")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL2")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL3")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL4")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL5")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL6")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL7")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL8")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL9")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL10")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL11")

	ChangeChatColor("CHANNEL1", 195 / 255, 230 / 255, 232 / 255)
	ChangeChatColor("CHANNEL2", 232 / 255, 158 / 255, 121 / 255)
	ChangeChatColor("CHANNEL3", 232 / 255, 228 / 255, 121 / 255)

	MOD:ReLoad()
end
--[[
##########################################################
CHAT HISTORY FUNCTIONS
##########################################################
]]--
local function MessageTimeStamp()
	local timestamp, current;
	local actual = time();
	local estimate = GetTime()
	if(not estimate) then
		current = random(1, 999)
	else
		current = select(2, ("."):split(estimate, 2)) or 0
	end
	timestamp = ("%d.%d"):format(actual, current)
	return timestamp;
end

function MOD:SAVE_CHAT_HISTORY(event, ...)
	local temp_cache = {}
	for i = 1, select('#', ...) do
		temp_cache[i] = select(i, ...) or false
	end
	if(#temp_cache > 0) then
	  	temp_cache[20] = event
	  	local timestamp = MessageTimeStamp()
		local lineNum, lineID = 0

		self.ChatHistory[timestamp] = temp_cache

		for id, data in pairs(self.ChatHistory) do
			lineNum = lineNum + 1
			if((not lineID) or lineID > id) then
				lineID = id
			end
		end

		if(lineNum > 128) then
			self.ChatHistory[lineID] = nil
		end
	end
	temp_cache = nil
end

function MOD:EnableChatHistory()
	self:RegisterEvent("CHAT_MSG_CHANNEL", "SAVE_CHAT_HISTORY")
	self:RegisterEvent("CHAT_MSG_EMOTE", "SAVE_CHAT_HISTORY")
	self:RegisterEvent("CHAT_MSG_GUILD_ACHIEVEMENT", "SAVE_CHAT_HISTORY")
	self:RegisterEvent("CHAT_MSG_RAID_WARNING", "SAVE_CHAT_HISTORY")
	self:RegisterEvent("CHAT_MSG_SAY", "SAVE_CHAT_HISTORY")
	self:RegisterEvent("CHAT_MSG_YELL", "SAVE_CHAT_HISTORY")
	self:RegisterEvent("CHAT_MSG_WHISPER_INFORM", "SAVE_CHAT_HISTORY")
	self:RegisterEvent("CHAT_MSG_GUILD", "SAVE_CHAT_HISTORY")
	self:RegisterEvent("CHAT_MSG_OFFICER", "SAVE_CHAT_HISTORY")
	self:RegisterEvent("CHAT_MSG_PARTY", "SAVE_CHAT_HISTORY")
	self:RegisterEvent("CHAT_MSG_PARTY_LEADER", "SAVE_CHAT_HISTORY")
	self:RegisterEvent("CHAT_MSG_RAID", "SAVE_CHAT_HISTORY")
	self:RegisterEvent("CHAT_MSG_RAID_LEADER", "SAVE_CHAT_HISTORY")
	self:RegisterEvent("CHAT_MSG_INSTANCE_CHAT", "SAVE_CHAT_HISTORY")
	self:RegisterEvent("CHAT_MSG_INSTANCE_CHAT_LEADER", "SAVE_CHAT_HISTORY")
	self:RegisterEvent("CHAT_MSG_BN_CONVERSATION", "SAVE_CHAT_HISTORY")
	self:RegisterEvent("CHAT_MSG_BN_WHISPER_INFORM", "SAVE_CHAT_HISTORY")

	local temp_cache, data_cache = {}
	local count = 1;
	for id, _ in pairs(self.ChatHistory) do
		temp_cache[count] = tonumber(id);
		count=count+1;
	end
	tsort(temp_cache, function(a, b)
		return a < b
	end)
	for i = 1, #temp_cache do
		local lineID = tostring(temp_cache[i])
		data_cache = self.ChatHistory[lineID]
		if(data_cache) then
			local GUID = data_cache[12]
			if((type(data_cache) == "table") and data_cache[20] ~= nil and (GUID and type(GUID) == "string")) then
				if(not GUID:find("Player-")) then
					self.ChatHistory[lineID] = nil
				else
					ChatFrame_MessageEventHandler(DEFAULT_CHAT_FRAME, data_cache[20], unpack(data_cache))
				end
			end
		end
	end

	temp_cache = nil
	data_cache = nil
	wipe(self.ChatHistory)
end

function MOD:DisableChatHistory()
	self:UnregisterEvent("CHAT_MSG_CHANNEL")
	self:UnregisterEvent("CHAT_MSG_EMOTE")
	self:UnregisterEvent("CHAT_MSG_GUILD_ACHIEVEMENT")
	self:UnregisterEvent("CHAT_MSG_RAID_WARNING")
	self:UnregisterEvent("CHAT_MSG_SAY")
	self:UnregisterEvent("CHAT_MSG_YELL")
	self:UnregisterEvent("CHAT_MSG_WHISPER_INFORM")
	self:UnregisterEvent("CHAT_MSG_GUILD")
	self:UnregisterEvent("CHAT_MSG_OFFICER")
	self:UnregisterEvent("CHAT_MSG_PARTY")
	self:UnregisterEvent("CHAT_MSG_PARTY_LEADER")
	self:UnregisterEvent("CHAT_MSG_RAID")
	self:UnregisterEvent("CHAT_MSG_RAID_LEADER")
	self:UnregisterEvent("CHAT_MSG_INSTANCE_CHAT")
	self:UnregisterEvent("CHAT_MSG_INSTANCE_CHAT_LEADER")
	self:UnregisterEvent("CHAT_MSG_BN_CONVERSATION")
	self:UnregisterEvent("CHAT_MSG_BN_WHISPER_INFORM")
end
--[[
##########################################################
EVENTS
##########################################################
]]--
function MOD:CHAT_MSG_WHISPER(event, ...)
	if(not InCombatLockdown() and WHISPER_SOUND) then PlaySoundFile(WHISPER_SOUND, SV.db.Chat.psst_channel or "Master") end
	if(self.db.general.saveChats) then
		self:SAVE_CHAT_HISTORY(event, ...)
	end
end

function MOD:CHAT_MSG_BN_WHISPER(event, ...)
	if(not InCombatLockdown() and WHISPER_SOUND) then PlaySoundFile(WHISPER_SOUND, SV.db.Chat.psst_channel or "Master") end
	if(self.db.general.saveChats) then
		self:SAVE_CHAT_HISTORY(event, ...)
	end
end

function MOD:PET_BATTLE_CLOSE()
	for _, frameName in pairs(CHAT_FRAMES) do
		local chat = _G[frameName]
		if chat and _G[frameName.."Tab"]:GetText():match(PET_BATTLE_COMBAT_LOG) then
			CURRENT_CHAT_FRAME_ID = chat:GetID();
			FCF_Close();
		end
	end
end
--[[
##########################################################
HOOKS
##########################################################
]]--
do
	local _hook_ChatEditOnEnterKey = function(self, input)
		local ctype = self:GetAttribute("chatType");
		local attr = (not CHAT_STICKY) and "SAY" or ctype;
		local chat = self:GetParent();
		if not chat.isTemporary and ChatTypeInfo[ctype].sticky == 1 then
			self:SetAttribute("chatType", attr);
		end
	end

	local _hook_ChatFontUpdate = function(self, chat, size)
		if(C_PetBattles.IsInBattle()) then return end
		SV.Events:Trigger("FONT_GROUP_UPDATED", "chatdialog");
		if ( not chat ) then
			chat = FCF_GetCurrentChatFrame();
		end
		if(SV.media.shared.font.chatdialog.outline ~= 'NONE' )then
			chat:SetShadowColor(0, 0, 0, 0)
			chat:SetShadowOffset(0, 0)
		else
			chat:SetShadowColor(0, 0, 0, 1)
			chat:SetShadowOffset(1, -1)
		end
	end

	local _hook_GDMFrameSetPoint = function(self)
		self:SetAllPoints(SV.Dock.BottomLeft.Bar)
	end

	local _hook_GDMScrollSetPoint = function(self, point, anchor, attachTo, x, y)
		if(anchor == GeneralDockManagerOverflowButton and x == 0 and y == 0) then
			self:SetPoint(point, anchor, attachTo, -2, -6)
		end
	end

	local _hook_OnUpdateHeader = function(editBox)
		local attrib = editBox:GetAttribute("chatType")
		if attrib == "CHANNEL" then
			local channel = GetChannelName(editBox:GetAttribute("channelTarget"))
			if channel == 0 then
				editBox:SetBackdropBorderColor(0,0,0)
			else
				editBox:SetBackdropBorderColor(ChatTypeInfo[attrib..channel].r, ChatTypeInfo[attrib..channel].g, ChatTypeInfo[attrib..channel].b)
			end
		elseif attrib then
			editBox:SetBackdropBorderColor(ChatTypeInfo[attrib].r, ChatTypeInfo[attrib].g, ChatTypeInfo[attrib].b)
		end
	end

	local _hook_FCFStartAlertFlash = function(self)
		if(not self.WhisperAlert) then return end
		self.WhisperAlert:Show()
		SV.Animate:Flash(self.WhisperAlert,1,true)
	end

	local _hook_FCFStopAlertFlash = function(self)
		if(not self.WhisperAlert) then return end
		SV.Animate:StopFlash(self.WhisperAlert)
		self.WhisperAlert:Hide()
	end

	local _hook_FCF_SetWindowColor = function(self, r, g, b)
		local name = self:GetName();
		local chat = _G[name]
		local id = chat:GetID()
		local tab = _G[name.."Tab"]
		if(tab.Holder.isFloating) then
			chat:SetBackdropColor(r,g,b,1)
		else
			chat:SetBackdropColor(0,0,0,0)
		end
	end

	local _hook_FCF_SetWindowAlpha = function(self, a)
		local name = self:GetName();
		local chat = _G[name]
		local id = chat:GetID()
		local tab = _G[name.."Tab"]
		if(tab.Holder.isFloating) then
			local r,g,b = chat:GetBackdropColor()
			chat:SetBackdropColor(r,g,b,a)
		end
	end

	local _hook_FCF_Close = function(self)
		local chatFrame = self or _G["ChatFrame" .. CURRENT_CHAT_FRAME_ID]
		if((not chatFrame) or (not chatFrame.Dock)) then return end
		local key = format("SVUI_ChatFrameDock%d", chatFrame:GetID())
		chatFrame.Dock:SetDocked(false);
		MOD:DeleteActiveFlag(key);
	end

	local _hook_FCF_Tab_OnClick = function(self)
		if(not self) then
			self = FCF_GetCurrentChatFrame();
		end
	end

	local _hook_FCF_OpenTemporaryWindow = function(...)
		--print('_hook_FCF_OpenTemporaryWindow')
		for id, chatFrameName in pairs(CHAT_FRAMES) do
			local frame = _G[chatFrameName];
			local key = format("SVUI_ChatFrameDock%d", id)
			if ( frame.isTemporary and (not MOD.private.activeTabs[key]) ) then
				local tabText = frame.name;
				if(tabText) then
					MOD:SaveActiveFlag(key,tabText);
				end
				if(frame.Dock) then
					frame.oldAlpha = 0;
					frame.Dock:UpdateBackdrop();
				end;
				break;
			end
		end
		MOD.RefreshChatFrames();
		--print(chatFrame:GetName())
	end

	local _hook_FCF_OpenNewWindow = function(...)
		--print('_hook_FCF_OpenNewWindow')
		OpenNewSVUIChatFrame(...);
		--print(chatFrame:GetName())
	end

	local _hook_FCF_FadeInChatFrame = function(chat)
		chat:ForceHide(false)
	end

	local _hook_FCF_FadeOutChatFrame = function(chat)
		chat:ForceHide(true)
	end

	_G.FCFDock_UpdateTabs = function(dock, forceUpdate)
		if ( not dock.isDirty and not forceUpdate ) then
			return;
		end

		for index, chatFrame in ipairs(dock.DOCKED_CHAT_FRAMES) do
			local chatTab = _G[chatFrame:GetName().."Tab"];
			chatTab:Show();
		end

		dock.isDirty = false;

		return FCFDock_ScrollToSelectedTab(dock);
	end

	_G.FCF_UpdateDockPosition = function() end
	_G.FCF_RestorePositionAndDimensions = function() end

	--TESTS
	local _hook_FCF_DockFrame = function(self)
		FCF_SetLocked(self, false);
		if(self.Dock) then
			local key = self.Dock:GetName();
			local tabText = self.name;
			if(tabText) then
				MOD:SaveActiveFlag(key,tabText);
			end
			self.oldAlpha = 0;
			self.Dock:UpdateBackdrop();
			--self.Dock.Parent.Bar:SetDefault(self.Dock.Button)
		end;
		MOD.RefreshChatFrames();
	end

	function SetAllChatHooks()
		NewHook('FCF_StartAlertFlash', _hook_FCFStartAlertFlash)
		NewHook('FCF_StopAlertFlash', _hook_FCFStopAlertFlash)
		NewHook('FCF_OpenNewWindow', _hook_FCF_OpenNewWindow)
		NewHook('FCF_UnDockFrame', MOD.RefreshChatFrames)
		NewHook('FCF_DockFrame', _hook_FCF_DockFrame)
		NewHook('FCF_OpenTemporaryWindow', _hook_FCF_OpenTemporaryWindow)
		NewHook('ChatEdit_OnEnterPressed', _hook_ChatEditOnEnterKey)
		NewHook('FCF_SetChatWindowFontSize', _hook_ChatFontUpdate)
		NewHook(GeneralDockManager, 'SetPoint', _hook_GDMFrameSetPoint)
		NewHook(GeneralDockManagerScrollFrame, 'SetPoint', _hook_GDMScrollSetPoint)
		--NewHook("FCF_SetWindowColor", _hook_FCF_SetWindowColor)
		--NewHook("FCFDock_UpdateTabs", function() print('FCFDock_UpdateTabs') end)
		NewHook("FCF_Close", _hook_FCF_Close)
		NewHook("ChatEdit_UpdateHeader", _hook_OnUpdateHeader)

		-- TESTING
		--NewHook('FCFDock_AddChatFrame', _hook_FCFDock_AddChatFrame)
		--NewHook('FCF_DockUpdate', _hook_FCF_DockUpdate)
		--NewHook("FCF_FadeInChatFrame", _hook_FCF_FadeInChatFrame)
		--NewHook("FCF_FadeOutChatFrame", _hook_FCF_FadeOutChatFrame)
	end
end

local ScrollFullButton = function(self)
	if(not self.parent) then return end
	self.parent:ScrollToBottom()
	self:Hide()
end

function MOD:CopyChat(frame)
	if not SVUI_CopyChatFrame:IsShown() then
		SVUI_CopyChatFrame:Show()
		local lineCt = self:GetLines(frame:GetRegions())
		local text = tconcat(COPY_LINES, "\n", 1, lineCt)
		SVUI_CopyChatFrameEditBox:SetText(text)
	else
		SVUI_CopyChatFrame:Hide()
	end
end

function MOD:UpdateLocals()
	PLAYER_NAME = UnitName("player");
	PLAYER_FILTER = PLAYER_NAME:upper();
	CHAT_THROTTLE = SV.db.Chat.throttleInterval;
	CHAT_ALLOW_URL = SV.db.Chat.url;
	CHAT_HOVER_URL = SV.db.Chat.hyperlinkHover;
	CHAT_STICKY = SV.db.Chat.sticky;
	TAB_WIDTH = SV.db.Chat.tabWidth;
	TAB_HEIGHT = SV.db.Chat.tabHeight;
	TAB_SKINS = SV.db.Chat.tabStyled;
	CHAT_ABBREV = SV.db.Chat.shortChannels;
	CHAT_FADING = SV.db.Chat.fade;
	WHISPER_SOUND = LSM:Fetch("sound", SV.db.Chat.psst);
	SECRET_SOUND = LSM:Fetch("sound", SV.db.Chat.mention);
	TIME_STAMP_MASK = SV.db.Chat.timeStampFormat;
	HIDE_REALM = SV.db.Chat.hideRealms;
	if(CHAT_THROTTLE and CHAT_THROTTLE == 0) then
		wipe(THROTTLE_CACHE)
	end
end

local function ExpandChatDock(location)
	if(not location) then return end
	local needsUpdate = false;
	for _, name in pairs(CHAT_FRAMES) do
		local chat = _G[name];
		if(chat and (location == chat.Dock.Parent.Bar.Data.Location)) then
			needsUpdate = true;
		end
	end
	if(needsUpdate) then SV.Timers:ExecuteTimer(MOD.RefreshChatFrames, 0.1); end
end

local function DockFadeInChat(location, default)
	--print('DockFadeInChat ' .. location)
	if(not location) then return end
	for _, name in pairs(CHAT_FRAMES) do
		local chat = _G[name];
		if(chat and chat.Dock and (location == chat.Dock.Parent.Bar.Data.Location)) then
			local buttonName = chat.Dock.Button:GetName();
			if((default == buttonName) and (not SV.Dock.private.Disabled[buttonName])) then
				MOD:ShowLines(chat)
				chat:FadeIn(0.2, chat:GetAlpha(), 1)
			else
				MOD:FadeLines(chat)
				chat:FadeOut(2, chat:GetAlpha(), 0, true)
			end
		end
	end
end

local function DockFadeOutChat(location)
	--print('DockFadeOutChat ' .. location)
	if(not location) then return end
	for _, name in pairs(CHAT_FRAMES) do
		local chat = _G[name];
		if(chat and chat.Dock) then
			local buttonName = chat.Dock.Button:GetName();
			if((location == chat.Dock.Parent.Bar.Data.Location) or (SV.Dock.private.Disabled[buttonName])) then
				MOD:FadeLines(chat)
				chat:FadeOut(2, chat:GetAlpha(), 0, true)
			end
		end
	end
end

function MOD:ResetInternalData()
	self:ClearPrivateData();
	self.private.history = {};
	self.private.activeTabs = {};
	self.private.tabNames = {};
	self.ChatHistory = self.private.history;
	for _, internal in pairs(INTERNAL_TABLES) do
		self.private[internal] = {};
	end
end

function MOD:IsChatActive(chatFrame)
	if(not chatFrame) then return false; end
	local id = chatFrame:GetID();
	local name,isActive = '',false;
	local key = format("SVUI_ChatFrameDock%d", id);
	for tabName, tabKey in pairs(self.private.tabNames) do
		if(tabKey == key) then
			name = tabName;
		end
	end
	for tabKey, tabName in pairs(self.private.activeTabs) do
		if(tabName == name) then
			isActive = true;
		end
	end
	return isActive;
end

function MOD:SaveActiveFlag(key,name)
	if((not key) or (not name)) then return false; end
	for tabName, tabKey in pairs(self.private.tabNames) do
		if(tabKey == key) then
			self.private.tabNames[tabName] = nil;
		end
	end
	for tabKey, tabName in pairs(self.private.activeTabs) do
		if(tabName == name) then
			self.private.activeTabs[tabKey] = nil;
		end
	end
	self.private.activeTabs[key] = name;
	self.private.tabNames[name] = key;
	return true;
end

function MOD:DeleteActiveFlag(key)
	if(not key) then return false; end
	for tabName, tabKey in pairs(self.private.tabNames) do
		if(tabKey == key) then
			self.private.tabNames[tabName] = nil;
		end
	end
	self.private.activeTabs[key] = nil;
	return true;
end

function MOD:ReLoad()
	self:RefreshChatFrames('RELOAD', true)
end

function MOD:Load()
	self.private.history = self.private.history or {};
	self.private.activeTabs = self.private.activeTabs or {};
	self.private.tabNames = self.private.tabNames or {};
	self.ChatHistory = self.private.history;

	self:IgnoreSharedKeys('history');
	self:MakeSharable();

	local baseDock = SV.Dock.BottomLeft;

	ScrollIndicator:SetParent(baseDock)
	ScrollIndicator:SetSize(20,20)
	ScrollIndicator:SetPoint("BOTTOMRIGHT", baseDock, "BOTTOMRIGHT", 6, 0)
	ScrollIndicator:SetFrameStrata("HIGH")
	ScrollIndicator:EnableMouse(true)
	ScrollIndicator.icon = ScrollIndicator:CreateTexture(nil, "BACKGROUND")
	ScrollIndicator.icon:SetAllPoints()
	ScrollIndicator.icon:SetTexture(MOD.media.scrollIcon)
	ScrollIndicator.icon:SetBlendMode("ADD")
	ScrollIndicator:Hide()
	ScrollIndicator:SetScript("OnMouseDown", ScrollFullButton)

	self:RegisterEvent('UPDATE_CHAT_WINDOWS', 'RefreshChatFrames')
	self:RegisterEvent('UPDATE_FLOATING_CHAT_WINDOWS', 'RefreshChatFrames')
	self:RegisterEvent('PET_BATTLE_CLOSE')

	self:UpdateLocals()

	for _, internal in pairs(INTERNAL_TABLES) do
		self.private[internal] = self.private[internal] or {};
	end

	for i,name in pairs(CHAT_FRAMES) do
		local chatFrame = _G[name];
		if(chatFrame) then
			SetChatWindowUninteractable(i, false)
			for _, internal in pairs(INTERNAL_TABLES) do
				self.private[internal][name] = self.private[internal][name] or {};
				if(chatFrame[internal]) then
					for x,y in pairs(chatFrame[internal]) do
						self.private[internal][name][x] = y
					end
				end
				chatFrame[internal] = self.private[internal][name];
			end
			chatFrame.oldAlpha = 0;
			local key = format("SVUI_ChatFrameDock%d", i)
			if(self.private.activeTabs[key] or ((not self.private.activeTabs[key]) and (i < 4))) then
				local tabText = chatFrame.name;
				if(tabText) then
					self:SaveActiveFlag(key,tabText);
				end
			end
		end
	end

	self:RefreshChatFrames('LOAD', true)
	SetParseHandlers()

	_G.CombatLogQuickButtonFrame_Custom:SetParent(ChatFrame2.Dock)
	_G.CombatLogQuickButtonFrame_Custom.SetParent = SV.fubar

	_G.GeneralDockManagerOverflowButton:ClearAllPoints()
	_G.GeneralDockManagerOverflowButton:SetPoint('BOTTOMLEFT', baseDock.Bar, 'BOTTOMRIGHT', 2, 0)
	_G.GeneralDockManagerOverflowButtonList:SetStyle("!_Frame", 'Transparent')
	_G.GeneralDockManager:SetAllPoints(baseDock.Bar)

	SetAllChatHooks()

	--FriendsMicroButton:Die()
	ChatFrameMenuButton:Die()

	_G.InterfaceOptionsSocialPanelTimestampsButton:SetAlpha(0)
	_G.InterfaceOptionsSocialPanelTimestampsButton:SetScale(0.000001)
	_G.InterfaceOptionsSocialPanelTimestamps:SetAlpha(0)
	_G.InterfaceOptionsSocialPanelTimestamps:SetScale(0.000001)
	_G.InterfaceOptionsSocialPanelChatStyle:EnableMouse(false)
	_G.InterfaceOptionsSocialPanelChatStyleButton:Hide()
	_G.InterfaceOptionsSocialPanelChatStyle:SetAlpha(0)

	local frame = CreateFrame("Frame", "SVUI_CopyChatFrame", baseDock)
	frame:SetPoint('BOTTOMLEFT', baseDock, 'TOPLEFT', 0, 0)
	frame:SetPoint('BOTTOMRIGHT', baseDock, 'TOPRIGHT', 0, 0)
	frame:SetHeight(baseDock:GetHeight())
	frame:Hide()
	frame:EnableMouse(true)
	frame:SetFrameStrata("DIALOG")
	SV.Dock.SetThemedBackdrop(frame, true);

	frame.Title = frame:CreateFontString()
	frame.Title:SetFontObject(SVUI_Font_Header)
	frame.Title:SetJustifyH('LEFT')
	frame.Title:SetText("Copy Chat")
	frame.Title:SetPoint("TOPLEFT", frame, "TOPLEFT", 4, 4)
	frame.Title:SetTextColor(1,0.8,0)

	local scrollArea = CreateFrame("ScrollFrame", "SVUI_CopyChatScrollFrame", frame, "UIPanelScrollFrameTemplate")
	scrollArea:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, -30)
	scrollArea:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 8)

	local editBox = CreateFrame("EditBox", "SVUI_CopyChatFrameEditBox", frame)
	editBox:SetMultiLine(true)
	editBox:SetMaxLetters(99999)
	editBox:EnableMouse(true)
	editBox:SetAutoFocus(false)
	editBox:SetFontObject(SVUI_Font_Chat)
	editBox:SetJustifyH('LEFT')
	editBox:SetWidth(scrollArea:GetWidth())
	editBox:SetHeight(200)
	editBox:SetScript("OnEscapePressed", function() SVUI_CopyChatFrame:Hide() end)

	scrollArea:SetScrollChild(editBox)

	editBox:SetScript("OnTextChanged", function(self, userInput)
		if userInput then return end
		local _, max = SVUI_CopyChatScrollFrameScrollBar:GetMinMaxValues()
		for i=1, max do
			ScrollFrameTemplate_OnMouseWheel(SVUI_CopyChatScrollFrame, -1)
		end
	end)

	local close = CreateFrame("Button", "SVUI_CopyChatFrameCloseButton", frame, "UIPanelCloseButton");
	close:SetPoint("TOPRIGHT");
	close:SetFrameLevel(close:GetFrameLevel() + 1);
	close:EnableMouse(true);
	SV.API:Set("CloseButton", close);
	local uisfCount = #UISpecialFrames+1;
	UISpecialFrames[uisfCount] = "SVUI_CopyChatFrame";

	if(SV.db.Chat.saveChats) then
		self:EnableChatHistory()
		self:RegisterEvent("CHAT_MSG_WHISPER")
		self:RegisterEvent("CHAT_MSG_BN_WHISPER")
	end

	self:LoadChatBubbles()

	SV.Events:On("DOCK_FADE_IN", DockFadeInChat, true);
	SV.Events:On("DOCK_FADE_OUT", DockFadeOutChat, true);
	SV.Events:On("DOCK_EXPANDED", ExpandChatDock, true);
	SV.Events:On("DOCKLETS_RESET", MOD.ResetChatWindows);

	SV.SystemAlert["NEW_CHAT_DOCK"] = {
		text = NAME_CHAT_WINDOW,
		button1 = YES,
		button2 = NO,
		hasEditBox = 1,
		OnAccept = function(self)
			local name = self.editBox:GetText();
			self.editBox:SetText("");
			OpenNewSVUIChatFrame(name);
		end,
		EditBoxOnEnterPressed = function(self)
			local parent = self:GetParent();
			local editBox = parent.editBox
			local name = editBox:GetText();
			editBox:SetText("");
			parent:Hide();
			OpenNewSVUIChatFrame(name);
		end,
		EditBoxOnEscapePressed = function (self)
			self:GetParent():Hide();
		end,
		hideOnEscape = 1,
		OnCancel = SV.fubar,
		timeout = 0,
		whileDead = 1,
		state1 = 1
	};
end
