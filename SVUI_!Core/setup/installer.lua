--[[
##########################################################
S V U I   By: Failcoder
##########################################################
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
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
local string 	= _G.string;
local table     = _G.table;
local format = string.format;
local tcopy = table.copy;
--[[
##########################################################
GET ADDON DATA
##########################################################
]]--
local SV = select(2, ...)
local SVUILib = Librarian("Registry");
local L = SV.L;
--[[
##########################################################
LOCAL VARS
##########################################################
]]--
local CURRENT_PAGE, MAX_PAGE, XOFF = 0, 9, (GetScreenWidth() * 0.025)
local okToResetMOVE = false;
local mungs = false;
local user_music_vol = GetCVar("Sound_MusicVolume") or 0;
local musicIsPlaying;
local PageData, OnClickData;
local SetCVar = _G.SetCVar;
local ToggleChatColorNamesByClassGroup = _G.ToggleChatColorNamesByClassGroup;
local ChatFrame_AddMessageGroup = _G.ChatFrame_AddMessageGroup;
--[[
##########################################################
SETUP CLASS OBJECT
##########################################################
]]--
SV.Setup = {};
SV.media.button = {
	["option"] 		= [[Interface\AddOns\SVUI_!Core\assets\textures\SETUP-OPTION]],
	["arrow"] 		= [[Interface\AddOns\SVUI_!Core\assets\textures\SETUP-ARROW]],
	["theme"] 		= [[Interface\AddOns\SVUI_!Core\assets\textures\THEME-DEFAULT]]
};
local preset_mediastyle = "default";
local preset_barstyle = "default";
local preset_unitstyle = "default";
local preset_groupstyle = "default";
local preset_aurastyle = "default";
--[[
##########################################################
LOCAL FUNCTIONS
##########################################################
]]--
local function PlayThemeSong()
	if(not musicIsPlaying) then
		SetCVar("Sound_MusicVolume", 100)
		SetCVar("Sound_EnableMusic", 1)
		StopMusic()
		PlayMusic([[Interface\AddOns\SVUI_!Core\assets\sounds\SuperVillain.mp3]])
		musicIsPlaying = true
	end
end

local function SetInstallButton(button)
    if(not button) then return end
    button.Left:SetAlpha(0)
    button.Middle:SetAlpha(0)
    button.Right:SetAlpha(0)
    button:SetNormalTexture("")
    button:SetPushedTexture("")
    button:SetPushedTexture("")
    button:SetDisabledTexture("")
    button:RemoveTextures()
    button:SetFrameLevel(button:GetFrameLevel() + 1)
end

local function forceCVars()
	SetCVar("statusTextDisplay","BOTH")
	SetCVar("ShowClassColorInNameplate",1)
	SetCVar("screenshotQuality",10)
	SetCVar("chatMouseScroll",1)
	SetCVar("chatStyle","classic")
	SetCVar("WholeChatWindowClickable",0)
	SetCVar("showTutorials",0)
	SetCVar("UberTooltips",1)
	SetCVar("threatWarning",3)
	SetCVar('alwaysShowActionBars',1)
	SetCVar('lockActionBars',1)
	SetCVar('SpamFilter',0)
	InterfaceOptionsActionBarsPanelPickupActionKeyDropDown:SetValue('SHIFT')
	InterfaceOptionsActionBarsPanelPickupActionKeyDropDown:RefreshValue()
end

local function ShowLayout(show)
	if(not SV.UnitFrames) then return end
	if(not _G["SVUI_Raid"] or (show and _G["SVUI_Raid"].forceShow == true)) then return end
	if(not show and _G["SVUI_Raid"].forceShow ~= true) then return end
	SV.UnitFrames:ViewGroupFrames(_G["SVUI_Raid"], show)
end

local function ShowAuras(show)
	if(not SV.UnitFrames) then return end
	if(not _G["SVUI_Player"] or (show and _G["SVUI_Player"].forceShowAuras)) then return end
	if(not show and not _G["SVUI_Player"].forceShowAuras) then return end
	_G["SVUI_Player"].forceShowAuras = show
	SV.UnitFrames:SetUnitFrame("player")
end

local function BarShuffle()
	if(not SV.ActionBars) then return end
	local bS = SV.db.ActionBars.Bar1.buttonspacing;

	SV:ReAnchor("SVUI_ActionBar2", "BOTTOM", SVUI_ActionBar1, "TOP", 0, -bS);
	SV:ReAnchor("SVUI_ActionBar3", "BOTTOMLEFT", SVUI_ActionBar1, "BOTTOMRIGHT", 4, 0);
	SV:ReAnchor("SVUI_ActionBar5", "BOTTOMRIGHT", SVUI_ActionBar1, "BOTTOMLEFT", -4, 0);
	SV:ReAnchor("SVUI_PetActionBar", "BOTTOMLEFT", SVUI_ActionBarMainAnchor, "TOPLEFT", 0, 4);
	SV:ReAnchor("SVUI_StanceBar", "BOTTOMRIGHT", SVUI_ActionBarMainAnchor, "TOPRIGHT", 0, 4);
	SV:ReAnchor("SVUI_SpecialAbility", "BOTTOM", SVUI_ActionBarMainAnchor, "TOP", 0, 75);
end

local function UFMoveBottomQuadrant(toggle)
	if(not SV.UnitFrames) then return end
	local x, y, x2, y2, x3, y3;
	if(SV.LowRez) then
		x, y, x2, y2, x3, y3 = 80, 135, 136, 285, 495, 135;
	elseif(not toggle) then
		x, y, x2, y2, x3, y3 = 80, 182, 310, 432, 495, 182;
	else
		x, y, x2, y2, x3, y3 = 80, 210, 310, 432, 495, 210;
	end

	SV:ReAnchor("SVUI_Player", "BOTTOMRIGHT", SV.Screen, "BOTTOM", -x, y);
	SV:ReAnchor("SVUI_PlayerCastbar", "BOTTOMRIGHT", SV.Screen, "BOTTOM", -x, y-60);
	SV:ReAnchor("SVUI_Pet", "RIGHT", SVUI_Player, "LEFT", -2, 0);
	SV:ReAnchor("SVUI_Target", "BOTTOMLEFT", SV.Screen, "BOTTOM", x, y);
	SV:ReAnchor("SVUI_TargetCastbar", "BOTTOMLEFT", SV.Screen, "BOTTOM", x, y-60);
	SV:ReAnchor("SVUI_TargetTarget", "LEFT", SVUI_Target, "RIGHT", 2, 0);
	SV:ReAnchor("SVUI_Focus", "BOTTOMLEFT", SV.Screen, "BOTTOM", x2, y2);
	SV:ReAnchor("SVUI_ThreatBar", "BOTTOMRIGHT", SV.Screen, "BOTTOMRIGHT", -x3, y3);
end

local function UFMoveLeftQuadrant(toggle)
	if(not SV.UnitFrames) then return end
	local dH = SV.db.Dock.dockLeftHeight + 60
	local x, y1, y2, y3;
	if(not toggle) then
		x, y1, y2, y3 = XOFF, 325, 250, 175;
	else
		x, y1, y2, y3 = 4, 325, 250, 175;
	end

	SV:ReAnchor("SVUI_Party", "BOTTOMLEFT", SV.Screen, "BOTTOMLEFT", x, dH);
	SV:ReAnchor("SVUI_Raid", "BOTTOMLEFT", SV.Screen, "BOTTOMLEFT", x, dH);
	SV:ReAnchor("SVUI_Raidpet", "TOPLEFT", SV.Screen, "TOPLEFT", x, -y1);
	SV:ReAnchor("SVUI_Assist", "TOPLEFT", SV.Screen, "TOPLEFT", x, -y2);
	SV:ReAnchor("SVUI_Tank", "TOPLEFT", SV.Screen, "TOPLEFT", x, -y3);
end

local function UFMoveTopQuadrant(toggle)
	if(not SV.UnitFrames) then return end
	local x1, x2, y1, y2, y3, y4;
	if(not toggle) then
		x1, x2, y1, y2, y3, y4 = 250, 4, 25, 350, 40, 250;
	else
		x1, x2, y1, y2, y3, y4 = 344, 4, 25, 254, 40, 250;
	end

	SV:ReAnchor("TicketStatusFrame", "TOPLEFT", SV.Screen, "TOPLEFT", x1, -y1);
	SV:ReAnchor("SVUI_LootFrame", "BOTTOM", SV.Screen, "BOTTOM", 0, y2);
	SV:ReAnchor("SVUI_AltPowerBar", "TOP", SV.Screen, "TOP", 0, -y3);
	SV:ReAnchor("BattleNetToasts", "TOPRIGHT", SV.Screen, "TOPRIGHT", x2, -y4);
end

local function UFMoveRightQuadrant(toggle)
	if(not SV.UnitFrames) then return end
	local dH = SV.db.Dock.dockRightHeight + 60
	local x, x2;
	if(not toggle) then
		x, x2 = 105, 284;
	else
		x, x2 = 105, 284;
	end

	SV:ReAnchor("SVUI_BossHolder", "RIGHT", SV.Screen, "RIGHT", -x, 0);
	SV:ReAnchor("SVUI_ArenaHolder", "RIGHT", SV.Screen, "RIGHT", -x, 0);
	if(SV.Tooltip) then
		SV:ReAnchor("SVUI_ToolTip", "BOTTOMRIGHT", SV.Screen, "BOTTOMRIGHT", -x2, dH);
	end
end
--[[
##########################################################
GLOBAL/MODULE FUNCTIONS
##########################################################
]]--
function SV.Setup:UserScreen(rez, preserve)
	if not preserve then
		if okToResetMOVE then
			SV:ResetAnchors("")
			okToResetMOVE = false;
		end
		SV:ResetData("UnitFrames")
	end

	if rez == "low" then
		if not preserve then
			SV.db.Dock.dockLeftWidth = 350;
			SV.db.Dock.dockLeftHeight = 180;
			SV.db.Dock.dockRightWidth = 350;
			SV.db.Dock.dockRightHeight = 180;
			if(SV.Auras) then
				SV.db.Auras.wrapAfter = 10;
			end
			if(SV.UnitFrames) then
				SV.db.UnitFrames.fontSize = 10;
				SV.db.UnitFrames.player.width = 150;
				SV.db.UnitFrames.player.castbar.width = 150;
				SV.db.UnitFrames.player.classbar.fill = "fill"
				SV.db.UnitFrames.player.health.tags = "[health:color][health:current]"
				SV.db.UnitFrames.target.width = 150;
				SV.db.UnitFrames.target.castbar.width = 150;
				SV.db.UnitFrames.target.health.tags = "[health:color][health:current]"
				SV.db.UnitFrames.pet.power.enable = false;
				SV.db.UnitFrames.pet.width = 75;
				SV.db.UnitFrames.targettarget.debuffs.enable = false;
				SV.db.UnitFrames.targettarget.power.enable = false;
				SV.db.UnitFrames.targettarget.width = 75;
				SV.db.UnitFrames.boss.width = 150;
				SV.db.UnitFrames.boss.castbar.width = 150;
				SV.db.UnitFrames.arena.width = 150;
				SV.db.UnitFrames.arena.castbar.width = 150
			end
		end
		SV.LowRez = true
	else
		SV:ResetData("Dock")
		SV:ResetData("Auras")
		SV.LowRez = nil
	end

	if(not preserve and not mungs) then
		-- BarShuffle()
    SV:UpdateAnchors()
		SVUILib:RefreshModule('Dock')
		SVUILib:RefreshModule('Auras')
		SVUILib:RefreshModule('ActionBars')
		SVUILib:RefreshModule('UnitFrames')
		SV:SavedPopup()
	end
end

function SV.Setup:ChatConfigs(mungs)
	forceCVars()

	if(SV.Chat) then
		SV.Chat:ResetChatWindows()
	else
		for i=1, NUM_CHAT_WINDOWS do
			local chatFrame = _G["ChatFrame"..i];
			if(chatFrame) then
				chatFrame.isUninteractable = false;
				chatFrame:SetMovable(true);
			end
		end

		FCF_ResetChatWindows()
		FCF_SetLocked(ChatFrame1, true)
		FCF_SetLocked(ChatFrame2, true)
		FCF_OpenNewWindow(LOOT)
		FCF_SetLocked(ChatFrame3, true)

		for i = 1, NUM_CHAT_WINDOWS do
			local chat = _G["ChatFrame"..i]
			local chatID = chat:GetID()
			if i == 1 and SV.Chat then
				chat:ClearAllPoints()
				chat:SetAllPoints(SV.Chat.Dock);
			end
			FCF_SavePositionAndDimensions(chat)
			FCF_StopDragging(chat)
			FCF_SetChatWindowFontSize(nil, chat, 12)
			if i == 1 then
				FCF_SetWindowName(chat, GENERAL)
			elseif i == 2 then
				FCF_SetWindowName(chat, GUILD_EVENT_LOG)
			elseif i == 3 then
				FCF_SetWindowName(chat, LOOT)
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
	end

	if not mungs then
		if SV.Chat then
			SV.Chat:ReLoad(true)
			if(SV.private.Docks.LeftFaded or SV.private.Docks.RightFaded) then
				ToggleSuperDocks()
			end
		end
		SV:SavedPopup()
	end
end

function SV.Setup:RandomBackdrops()
	self:GenerateBackdrops()
	SV:UpdateSharedMedia()
	if(SV.UnitFrames) then SVUILib:RefreshModule('UnitFrames') end
end

function SV.Setup:ColorTheme(style, preserve)
	preset_mediastyle = style or "default";

	if not preserve then
		SV:ResetData("media")
	end

	self:CopyPreset("media", preset_mediastyle)
	SVUILib:SaveSafeData("preset_mediastyle", preset_mediastyle);

	if(SV.UnitFrames) then
		if(preset_mediastyle == "default") then
			SV.db.UnitFrames.healthclass = true;
		else
			SV.db.UnitFrames.healthclass = false;
		end
	end

	if(not mungs) then
		SV:UpdateSharedMedia()
		SVUILib:RefreshModule('Dock')
		if(SV.UnitFrames) then SVUILib:RefreshModule('UnitFrames') end
		if(not preserve) then
			SV:SavedPopup()
		end
	end
end

function SV.Setup:UnitframeLayout(style, preserve)
	if(not SV.UnitFrames) then return end
	preset_unitstyle = style or "default";

	if not preserve then
		SV:ResetData("UnitFrames")
		SV:ResetData("Dock")
		if okToResetMOVE then
			SV:ResetAnchors('')
			okToResetMOVE = false
		end
	end

	self:CopyPreset("units", preset_unitstyle)
	SVUILib:SaveSafeData("preset_unitstyle", preset_unitstyle);

	if(preset_mediastyle == "default") then
		SV.db.UnitFrames.healthclass = true;
	end

	if(not mungs) then
		if(not preserve) then
			if preset_barstyle and (preset_barstyle == "twosmall" or preset_barstyle == "twobig") then
				UFMoveBottomQuadrant(true)
			else
				UFMoveBottomQuadrant()
			end
			SV:UpdateAnchors()
		end
		if(not preserve) then
			--BarShuffle()
			SV:UpdateAnchors()
		end
		SVUILib:RefreshModule('Dock')
		SVUILib:RefreshModule('ActionBars')
		SVUILib:RefreshModule('UnitFrames')
		if(not preserve) then
			SV:SavedPopup()
		end
	end
end

function SV.Setup:GroupframeLayout(style, preserve)
	if(not SV.UnitFrames) then return end
	preset_groupstyle = style or "default";
	self:CopyPreset("layouts", preset_groupstyle)
	SVUILib:SaveSafeData("preset_groupstyle", preset_groupstyle);

	if(not mungs) then
		SVUILib:RefreshModule('UnitFrames')
		if(not preserve) then
			SV:SavedPopup()
		end
	end
end

function SV.Setup:BarLayout(style, preserve)
	if(not SV.ActionBars) then return end
	preset_barstyle = style or "default";

	if not preserve then
		SV:ResetData("ActionBars")
		if okToResetMOVE then
			SV:ResetAnchors('')
			okToResetMOVE=false
		end
	end

	self:CopyPreset("bars", preset_barstyle)
	SVUILib:SaveSafeData("preset_barstyle", preset_barstyle);

	if(not mungs) then
		if(not preserve) then
			if(preset_barstyle == 'twosmall' or preset_barstyle == 'twobig') then
				UFMoveBottomQuadrant("shift")
			else
				UFMoveBottomQuadrant()
			end
		end
		SVUILib:RefreshModule('Dock')
		SVUILib:RefreshModule('ActionBars')
		if(not preserve) then
			--BarShuffle()
			SV:UpdateAnchors()
			SV:SavedPopup()
		end
	end
end

function SV.Setup:Auralayout(style, preserve)
	if(not SV.UnitFrames) then return end
	preset_aurastyle = style or "default";

	self:CopyPreset("auras", preset_aurastyle)

	SVUILib:SaveSafeData("preset_aurastyle", preset_aurastyle);

	if(not mungs) then
		SVUILib:RefreshModule('UnitFrames')
		if(not preserve) then
			SV:SavedPopup()
		end
	end
end

function SV.Setup:EZDefault()
	mungs = true;
	okToResetMOVE = false;

	self:SetAllDefaults()

	self:ChatConfigs(true);
	self:UserScreen()
	self:ColorTheme("default", true);
	self:UnitframeLayout("default", true);
	self:GroupframeLayout("default", true);
	self:BarLayout("default", true);
	self:Auralayout("default", true);

	SV.db.FunStuff.comix = '1';
	SV.db.FunStuff.gamemenu = '1';
	SV.db.FunStuff.afk = '1';

	SV.db.general.woot = true;
	SV.db.general.arenadrink = true;
	SV.db.general.stupidhat = true;

	SV.db.Dock.backdrop = true;
	SV.db.Reports.backdrop = true;

	if(SV.Auras) then
		SV.db.Auras.hyperBuffsEnabled = true;
	end
	if(SV.Inventory) then
		SV.db.Inventory.bagTools = true;
		SV.db.Inventory.enable = true;
	end
	if(SV.Maps) then
		SV.db.Maps.customIcons = true;
		SV.db.Maps.bordersize = 6;
		SV.db.Maps.locationText = "";
		SV.db.Maps.playercoords = "";
	end
	if(SV.NamePlates) then
		SV.db.NamePlates.themed = true;
	end
	if(SV.Tooltip) then
		SV.db.Tooltip.themed = true;
	end
	if(SV.UnitFrames) then
		SV.db.UnitFrames.themed = true;
	end
	SVUILib:SaveSafeData("install_version", SV.Version)
	StopMusic()
	SetCVar("Sound_MusicVolume", user_music_vol or 0)
	ReloadUI()
end

function SV.Setup:Minimalist()
	mungs = true;
	okToResetMOVE = false;
	self:SetAllDefaults()
	self:ChatConfigs(true);
	self:UserScreen()
	self:ColorTheme("classy", true);
	self:UnitframeLayout("compact", true);
	self:GroupframeLayout("grid", true);
	self:BarLayout("default", true);
	self:Auralayout("default", true);

	SV.db.general.comix = false;
	SV.db.general.gamemenu = false;
	SV.db.general.afk = false;
	SV.db.general.woot = false;
	SV.db.general.arenadrink = false;
	SV.db.general.stupidhat = false;

	SV.db.Dock.backdrop = false;
	SV.db.Reports.backdrop = false;
	if(SV.Auras) then
		SV.db.Auras.hyperBuffsEnabled = false;
	end
	if(SV.Inventory) then
		SV.db.Inventory.bagTools = false;
		SV.db.Inventory.enable = false;
	end
	if(SV.Maps) then
		SV.db.Maps.customIcons = false;
		SV.db.Maps.bordersize = 0;
		SV.db.Maps.bordercolor = "dark";
		SV.db.Maps.locationText = "SIMPLE";
		SV.db.Maps.playercoords = "HIDE";
	end
	if(SV.NamePlates) then
		SV.db.NamePlates.themed = false;
	end
	if(SV.Tooltip) then
		SV.db.Tooltip.themed = false;
	end
	if(SV.UnitFrames) then
		SV.db.UnitFrames.themed = false;
		SV.db.UnitFrames.player.height = 22;
		SV.db.UnitFrames.player.power.height = 6;
		SV.db.UnitFrames.target.height = 22;
		SV.db.UnitFrames.target.power.height = 6;
		SV.db.UnitFrames.targettarget.height = 22;
		SV.db.UnitFrames.targettarget.power.height = 6;
		SV.db.UnitFrames.pet.height = 22;
		SV.db.UnitFrames.pet.power.height = 6;
		SV.db.UnitFrames.focus.height = 22;
		SV.db.UnitFrames.focus.power.height = 6;
		SV.db.UnitFrames.boss.height = 22;
		SV.db.UnitFrames.boss.power.height = 6;
		UFMoveBottomQuadrant()
	end

	SVUILib:SaveSafeData("install_version", SV.Version)
	StopMusic()
	SetCVar("Sound_MusicVolume", user_music_vol or 0)
	ReloadUI()
end

function SV.Setup:Complete()
	SVUILib:SaveSafeData("install_version", SV.Version)
	StopMusic()
	SetCVar("Sound_MusicVolume", user_music_vol or 0)
	okToResetMOVE = false;
	ReloadUI()
end

function SV.Setup:NewSettings()
	CURRENT_PAGE = 2;
	SVUI_InstallerFrame:SetPage(CURRENT_PAGE)
end

local OptionButton_OnClick = function(self)
	local fn = self.FuncName
	if(self.ClickIndex) then
		for option, text in pairs(self.ClickIndex) do
			SVUI_InstallerFrame[option]:SetText(text)
		end
	end
	if(SV.Setup[fn] and type(SV.Setup[fn]) == "function") then
		SV.Setup[fn](SV.Setup, self.Arg)
	end
end

local InstallerFrame_PreparePage = function(self)
	self.Option01:Hide()
	self.Option01:SetScript("OnClick",nil)
	self.Option01:SetText("")
	self.Option01.FuncName = nil
	self.Option01.Arg = nil
	self.Option01.ClickIndex = nil
	self.Option01:SetWidth(160)
	self.Option01.texture:SetSize(160, 160)
	self.Option01.texture:SetPoint("CENTER", self.Option01, "BOTTOM", 0, -(160 * 0.09))
	self.Option01:ClearAllPoints()
	self.Option01:SetPoint("BOTTOM", 0, 15)

	self.Option02:Hide()
	self.Option02:SetScript("OnClick",nil)
	self.Option02:SetText("")
	self.Option02.FuncName = nil
	self.Option02.Arg = nil
	self.Option02.ClickIndex = nil
	self.Option02:ClearAllPoints()
	self.Option02:SetPoint("BOTTOMLEFT", self, "BOTTOM", 4, 15)

	self.Option03:Hide()
	self.Option03:SetScript("OnClick",nil)
	self.Option03:SetText("")
	self.Option03.FuncName = nil
	self.Option03.Arg = nil
	self.Option03.ClickIndex = nil

	self.Option1:Hide()
	self.Option1:SetScript("OnClick",nil)
	self.Option1:SetText("")
	self.Option1.FuncName = nil
	self.Option1.Arg = nil
	self.Option1.ClickIndex = nil
	self.Option1:SetWidth(160)
	self.Option1.texture:SetSize(160, 160)
	self.Option1.texture:SetPoint("CENTER", self.Option1, "BOTTOM", 0, -(160 * 0.09))
	self.Option1:ClearAllPoints()
	self.Option1:SetPoint("BOTTOM", 0, 15)

	self.Option2:Hide()
	self.Option2:SetScript('OnClick',nil)
	self.Option2:SetText('')
	self.Option2.FuncName = nil
	self.Option2.Arg = nil
	self.Option2.ClickIndex = nil
	self.Option2:SetWidth(120)
	self.Option2.texture:SetSize(120, 120)
	self.Option2.texture:SetPoint("CENTER", self.Option2, "BOTTOM", 0, -(120 * 0.09))
	self.Option2:ClearAllPoints()
	self.Option2:SetPoint("BOTTOMLEFT", self, "BOTTOM", 4, 15)

	self.Option3:Hide()
	self.Option3:SetScript('OnClick',nil)
	self.Option3:SetText('')
	self.Option3.FuncName = nil
	self.Option3.Arg = nil
	self.Option3.ClickIndex = nil
	self.Option3:SetWidth(120)
	self.Option3.texture:SetSize(120, 120)
	self.Option3.texture:SetPoint("CENTER", self.Option3, "BOTTOM", 0, -(120 * 0.09))
	self.Option3:ClearAllPoints()
	self.Option3:SetPoint("LEFT", self.Option2, "RIGHT", 4, 0)

	self.Option4:Hide()
	self.Option4:SetScript('OnClick',nil)
	self.Option4:SetText('')
	self.Option4.FuncName = nil
	self.Option4.Arg = nil
	self.Option4.ClickIndex = nil
	self.Option4:SetWidth(110)
	self.Option4.texture:SetSize(110, 110)
	self.Option4.texture:SetPoint("CENTER", self.Option4, "BOTTOM", 0, -(110 * 0.09))
	self.Option4:ClearAllPoints()
	self.Option4:SetPoint("LEFT", self.Option3, "RIGHT", 4, 0)

	self.SubTitle:SetText("")
	self.Desc1:SetText("")
	self.Desc2:SetText("")
	self.Desc3:SetText("")

	if CURRENT_PAGE == 1 then
		self.Prev:Disable()
		self.Prev:Hide()
	else
		self.Prev:Enable()
		self.Prev:Show()
	end

	if CURRENT_PAGE == MAX_PAGE then
		self.Next:Disable()
		self.Next:Hide()
		self:SetSize(550, 350)
	else
		self.Next:Enable()
		self.Next:Show()
		self:SetSize(550,400)
	end
end

local InstallerFrame_SetPage = function(self, newPage)
	PageData, MAX_PAGE = SV.Setup:CopyPage(newPage)
	CURRENT_PAGE = newPage;
	local willShowLayout = CURRENT_PAGE == 5 or CURRENT_PAGE == 6;
	local willShowAuras = CURRENT_PAGE == 8;

	self:PreparePage()
	self.Status:SetText(CURRENT_PAGE.."  /  "..MAX_PAGE)

	ShowLayout(willShowLayout)
	ShowAuras(willShowAuras)

	for option, data in pairs(PageData) do
		if(self[option]) then
			if(type(data) == "table" and data[1]) then
				if(type(data[1]) == 'function') then
					local n,fn = data[1]()
					self[option]:SetText(n)
					self[option].FuncName = fn
					self[option].Arg = nil
				else
					if(not data[2]) then return end
					self[option]:SetText(data[1])
					self[option].FuncName = data[2]
					self[option].Arg = data[3]
				end
				self[option]:Show()
				local postclickIndex = ("%d_%s"):format(newPage, option)
				self[option].ClickIndex = SV.Setup:CopyOnClick(postclickIndex)
				self[option]:SetScript("OnClick", OptionButton_OnClick)
			elseif(type(data) == "function") then
				local optionText = data()
				self[option]:SetText(optionText)
			else
				self[option]:SetText(data)
			end
		end
	end
end

local NextPage_OnClick = function(self)
	if CURRENT_PAGE ~= MAX_PAGE then
		CURRENT_PAGE = CURRENT_PAGE + 1;
		self.parent:SetPage(CURRENT_PAGE)
		PlayThemeSong();
	end
end

local PreviousPage_OnClick = function(self)
	if CURRENT_PAGE ~= 1 then
		CURRENT_PAGE = CURRENT_PAGE - 1;
		self.parent:SetPage(CURRENT_PAGE)
	end
end

function SV.Setup:Reset()
	SVUILib:WipeDatabase()

	mungs = true;
	okToResetMOVE = false;
	self:ChatConfigs(true);
	self:UserScreen()

	local old = SVUILib:GetSafeData()
    preset_mediastyle = old.preset_mediastyle or "default";
	preset_barstyle = old.preset_barstyle or "default";
	preset_unitstyle = old.preset_unitstyle or "default";
	preset_groupstyle = old.preset_groupstyle or "default";
	preset_aurastyle = old.preset_aurastyle or "default";

	self:ColorTheme(preset_mediastyle)
    self:BarLayout(preset_barstyle)
    self:UnitframeLayout(preset_unitstyle)
    self:GroupframeLayout(preset_groupstyle)
    self:Auralayout(preset_aurastyle)

	SVUILib:SaveSafeData("install_version", SV.Version);
	ReloadUI()
end

function SV.Setup:Install(autoLoaded)
	local mp = SVUILib:CheckMasterProfile();
	if(mp) then
    	SV.SystemAlert["MASTER_PROFILE_PROMPT"].OnAccept = function() SVUILib:CopyDatabase(mp) end
		SV.SystemAlert["MASTER_PROFILE_PROMPT"].OnCancel = function() SV.Setup:LoadInstaller(autoLoaded) end
    	SV:StaticPopup_Show("MASTER_PROFILE_PROMPT")
	else
		SV.Setup:LoadInstaller(autoLoaded)
	end
end

function SV.Setup:LoadInstaller(autoLoaded)
	local old = SVUILib:GetSafeData()
	preset_mediastyle = old.preset_mediastyle or "default";
	preset_barstyle = old.preset_barstyle or "default";
	preset_unitstyle = old.preset_unitstyle or "default";
	preset_groupstyle = old.preset_groupstyle or "default";
	preset_aurastyle = old.preset_aurastyle or "default";

	if not SVUI_InstallerFrame then
		local frame = CreateFrame("Button", "SVUI_InstallerFrame", UIParent)
		frame:SetSize(550, 400)
		frame:SetStyle("Frame", "Window2")
		frame:SetPoint("TOP", SV.Screen, "TOP", 0, -150)
		frame:SetFrameStrata("TOOLTIP")

		frame.SetPage = InstallerFrame_SetPage;
		frame.PreparePage = InstallerFrame_PreparePage;

		--[[ NEXT PAGE BUTTON ]]--

		frame.Next = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
		frame.Next:RemoveTextures()
		frame.Next:SetSize(110, 25)
		frame.Next:SetPoint("BOTTOMRIGHT", 50, 5)
		SetInstallButton(frame.Next)
		frame.Next.texture = frame.Next:CreateTexture(nil, "BORDER")
		frame.Next.texture:SetSize(110, 75)
		frame.Next.texture:SetPoint("RIGHT")
		frame.Next.texture:SetTexture(SV.media.button.arrow)
		frame.Next.texture:SetVertexColor(1, 0.5, 0)
		frame.Next.text = frame.Next:CreateFontString(nil, "OVERLAY")
		frame.Next.text:SetFont(SV.media.font.flash, 18, "OUTLINE")
		frame.Next.text:SetPoint("CENTER")
		frame.Next.text:SetText(L[CONTINUE])
		frame.Next:Disable()
		frame.Next.parent = frame
		frame.Next:SetScript("OnClick", NextPage_OnClick)
		frame.Next:SetScript("OnEnter", function(this)
			this.texture:SetVertexColor(1, 1, 0)
		end)
		frame.Next:SetScript("OnLeave", function(this)
			this.texture:SetVertexColor(1, 0.5, 0)
		end)

		--[[ PREVIOUS PAGE BUTTON ]]--

		frame.Prev = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
		frame.Prev:RemoveTextures()
		frame.Prev:SetSize(110, 25)
		frame.Prev:SetPoint("BOTTOMLEFT", -50, 5)
		SetInstallButton(frame.Prev)
		frame.Prev.texture = frame.Prev:CreateTexture(nil, "BORDER")
		frame.Prev.texture:SetSize(110, 75)
		frame.Prev.texture:SetPoint("LEFT")
		frame.Prev.texture:SetTexture(SV.media.button.arrow)
		frame.Prev.texture:SetTexCoord(1, 0, 1, 1, 0, 0, 0, 1)
		frame.Prev.texture:SetVertexColor(1, 0.5, 0)
		frame.Prev.text = frame.Prev:CreateFontString(nil, "OVERLAY")
		frame.Prev.text:SetFont(SV.media.font.flash, 18, "OUTLINE")
		frame.Prev.text:SetPoint("CENTER")
		frame.Prev.text:SetText(L[PREVIOUS])
		frame.Prev:Disable()
		frame.Prev.parent = frame
		frame.Prev:SetScript("OnClick", PreviousPage_OnClick)
		frame.Prev:SetScript("OnEnter", function(this)
			this.texture:SetVertexColor(1, 1, 0)
		end)
		frame.Prev:SetScript("OnLeave", function(this)
			this.texture:SetVertexColor(1, 0.5, 0)
		end)

		--[[ OPTION 01 ]]--

		frame.Option01 = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
		frame.Option01:RemoveTextures()
		frame.Option01:SetSize(160, 30)
		frame.Option01:SetPoint("BOTTOM", 0, 15)
		frame.Option01:SetText("")
		SetInstallButton(frame.Option01)
		frame.Option01.texture = frame.Option01:CreateTexture(nil, "BORDER")
		frame.Option01.texture:SetSize(160, 160)
		frame.Option01.texture:SetPoint("CENTER", frame.Option01, "BOTTOM", 0, -15)
		frame.Option01.texture:SetTexture(SV.media.button.option)
		frame.Option01.texture:SetGradient("VERTICAL", 0, 0.3, 0, 0, 0.7, 0)
		frame.Option01:SetScript("OnEnter", function(this)
			this.texture:SetVertexColor(0.5, 1, 0.4)
		end)
		frame.Option01:SetScript("OnLeave", function(this)
			this.texture:SetGradient("VERTICAL", 0, 0.3, 0, 0, 0.7, 0)
		end)
		frame.Option01:SetFrameLevel(frame.Option01:GetFrameLevel() + 10)
		frame.Option01:Hide()

		--[[ OPTION 02 ]]--

		frame.Option02 = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
		frame.Option02:RemoveTextures()
		frame.Option02:SetSize(130, 30)
		frame.Option02:SetPoint("BOTTOMLEFT", frame, "BOTTOM", 4, 15)
		frame.Option02:SetText("")
		SetInstallButton(frame.Option02)
		frame.Option02.texture = frame.Option02:CreateTexture(nil, "BORDER")
		frame.Option02.texture:SetSize(130, 110)
		frame.Option02.texture:SetPoint("CENTER", frame.Option02, "BOTTOM", 0, -15)
		frame.Option02.texture:SetTexture(SV.media.button.option)
		frame.Option02.texture:SetGradient("VERTICAL", 0, 0.1, 0.3, 0, 0.5, 0.7)
		frame.Option02:SetScript("OnEnter", function(this)
			this.texture:SetVertexColor(0.5, 1, 0.4)
		end)
		frame.Option02:SetScript("OnLeave", function(this)
			this.texture:SetGradient("VERTICAL", 0, 0.1, 0.3, 0, 0.5, 0.7)
		end)
		frame.Option02:SetScript("OnShow", function(self)
			if(not frame.Option03:IsShown()) then
				frame.Option01:SetWidth(130)
				frame.Option01.texture:SetSize(130, 130)
				frame.Option01.texture:SetPoint("CENTER", frame.Option01, "BOTTOM", 0, -(130 * 0.09))
				frame.Option01:ClearAllPoints()
				frame.Option01:SetPoint("BOTTOMRIGHT", frame, "BOTTOM", -4, 15)

				self:SetWidth(130)
				self.texture:SetSize(130, 130)
			end
		end)
		frame.Option02:SetFrameLevel(frame.Option01:GetFrameLevel() + 10)
		frame.Option02:Hide()

		--[[ OPTION 03 ]]--

		frame.Option03 = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
		frame.Option03:RemoveTextures()
		frame.Option03:SetSize(130, 30)
		frame.Option03:SetPoint("BOTTOM", frame, "BOTTOM", 0, 15)
		frame.Option03:SetText("")
		SetInstallButton(frame.Option03)
		frame.Option03.texture = frame.Option03:CreateTexture(nil, "BORDER")
		frame.Option03.texture:SetSize(130, 110)
		frame.Option03.texture:SetPoint("CENTER", frame.Option03, "BOTTOM", 0, -15)
		frame.Option03.texture:SetTexture(SV.media.button.option)
		frame.Option03.texture:SetGradient("VERTICAL", 0.3, 0, 0, 0.7, 0, 0)
		frame.Option03:SetScript("OnEnter", function(this)
			this.texture:SetVertexColor(0.2, 0.5, 1)
		end)
		frame.Option03:SetScript("OnLeave", function(this)
			this.texture:SetGradient("VERTICAL", 0.3, 0, 0, 0.7, 0, 0)
		end)
		frame.Option03:SetScript("OnShow", function(this)
			this:SetWidth(130)
			this.texture:SetSize(130, 130)
			this.texture:SetPoint("CENTER", this, "BOTTOM", 0, -(130 * 0.09))

			frame.Option01:SetWidth(130)
			frame.Option01.texture:SetSize(130, 130)
			frame.Option01.texture:SetPoint("CENTER", frame.Option01, "BOTTOM", 0, -(130 * 0.09))
			frame.Option01:ClearAllPoints()
			frame.Option01:SetPoint("RIGHT", this, "LEFT", -8, 0)

			frame.Option02:SetWidth(130)
			frame.Option02.texture:SetSize(130, 130)
			frame.Option02.texture:SetPoint("CENTER", frame.Option02, "BOTTOM", 0, -(130 * 0.09))
			frame.Option02:ClearAllPoints()
			frame.Option02:SetPoint("LEFT", this, "RIGHT", 8, 0)
		end)
		frame.Option03:SetFrameLevel(frame.Option01:GetFrameLevel() + 10)
		frame.Option03:Hide()

		--[[ OPTION 1 ]]--

		frame.Option1 = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
		frame.Option1:RemoveTextures()
		frame.Option1:SetSize(160, 30)
		frame.Option1:SetPoint("BOTTOM", 0, 15)
		frame.Option1:SetText("")
		SetInstallButton(frame.Option1)
		frame.Option1.texture = frame.Option1:CreateTexture(nil, "BORDER")
		frame.Option1.texture:SetSize(160, 160)
		frame.Option1.texture:SetPoint("CENTER", frame.Option1, "BOTTOM", 0, -15)
		frame.Option1.texture:SetTexture(SV.media.button.option)
		frame.Option1.texture:SetGradient("VERTICAL", 0.3, 0.3, 0.3, 0.7, 0.7, 0.7)
		frame.Option1:SetScript("OnEnter", function(this)
			this.texture:SetVertexColor(0.5, 1, 0.4)
		end)
		frame.Option1:SetScript("OnLeave", function(this)
			this.texture:SetGradient("VERTICAL", 0.3, 0.3, 0.3, 0.7, 0.7, 0.7)
		end)
		frame.Option1:SetFrameLevel(frame.Option1:GetFrameLevel() + 10)
		frame.Option1:Hide()

		--[[ OPTION 2 ]]--

		frame.Option2 = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
		frame.Option2:RemoveTextures()
		frame.Option2:SetSize(120, 30)
		frame.Option2:SetPoint("BOTTOMLEFT", frame, "BOTTOM", 4, 15)
		frame.Option2:SetText("")
		SetInstallButton(frame.Option2)
		frame.Option2.texture = frame.Option2:CreateTexture(nil, "BORDER")
		frame.Option2.texture:SetSize(120, 110)
		frame.Option2.texture:SetPoint("CENTER", frame.Option2, "BOTTOM", 0, -15)
		frame.Option2.texture:SetTexture(SV.media.button.option)
		frame.Option2.texture:SetGradient("VERTICAL", 0.3, 0.3, 0.3, 0.7, 0.7, 0.7)
		frame.Option2:SetScript("OnEnter", function(this)
			this.texture:SetVertexColor(0.5, 1, 0.4)
		end)
		frame.Option2:SetScript("OnLeave", function(this)
			this.texture:SetGradient("VERTICAL", 0.3, 0.3, 0.3, 0.7, 0.7, 0.7)
		end)
		frame.Option2:SetScript("OnShow", function()
			if(not frame.Option3:IsShown() and (not frame.Option4:IsShown())) then
				frame.Option1:SetWidth(120)
				frame.Option1.texture:SetSize(120, 120)
				frame.Option1.texture:SetPoint("CENTER", frame.Option1, "BOTTOM", 0, -(120 * 0.09))
				frame.Option1:ClearAllPoints()
				frame.Option1:SetPoint("BOTTOMRIGHT", frame, "BOTTOM", -4, 15)
			end
		end)
		frame.Option2:SetFrameLevel(frame.Option1:GetFrameLevel() + 10)
		frame.Option2:Hide()

		--[[ OPTION 3 ]]--

		frame.Option3 = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
		frame.Option3:RemoveTextures()
		frame.Option3:SetSize(110, 30)
		frame.Option3:SetPoint("LEFT", frame.Option2, "RIGHT", 4, 0)
		frame.Option3:SetText("")
		SetInstallButton(frame.Option3)
		frame.Option3.texture = frame.Option3:CreateTexture(nil, "BORDER")
		frame.Option3.texture:SetSize(110, 100)
		frame.Option3.texture:SetPoint("CENTER", frame.Option3, "BOTTOM", 0, -9)
		frame.Option3.texture:SetTexture(SV.media.button.option)
		frame.Option3.texture:SetGradient("VERTICAL", 0.3, 0.3, 0.3, 0.7, 0.7, 0.7)
		frame.Option3:SetScript("OnEnter", function(this)
			this.texture:SetVertexColor(0.5, 1, 0.4)
		end)
		frame.Option3:SetScript("OnLeave", function(this)
			this.texture:SetGradient("VERTICAL", 0.3, 0.3, 0.3, 0.7, 0.7, 0.7)
		end)
		frame.Option3:SetScript("OnShow", function(this)
			if(not frame.Option4:IsShown()) then
				frame.Option2:SetWidth(110)
				frame.Option2.texture:SetSize(110, 110)
				frame.Option2.texture:SetPoint("CENTER", frame.Option2, "BOTTOM", 0, -(110 * 0.09))
				frame.Option2:ClearAllPoints()
				frame.Option2:SetPoint("BOTTOM", frame, "BOTTOM", 0, 15)

				frame.Option1:SetWidth(110)
				frame.Option1.texture:SetSize(110, 110)
				frame.Option1.texture:SetPoint("CENTER", frame.Option1, "BOTTOM", 0, -(110 * 0.09))
				frame.Option1:ClearAllPoints()
				frame.Option1:SetPoint("RIGHT", frame.Option2, "LEFT", -4, 0)

				this:SetWidth(110)
				this.texture:SetSize(110, 110)
				this.texture:SetPoint("CENTER", this, "BOTTOM", 0, -(110 * 0.09))
				this:ClearAllPoints()
				this:SetPoint("LEFT", frame.Option2, "RIGHT", 4, 0)
			end
		end)
		frame.Option3:SetFrameLevel(frame.Option1:GetFrameLevel() + 10)
		frame.Option3:Hide()

		--[[ OPTION 4 ]]--

		frame.Option4 = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
		frame.Option4:RemoveTextures()
		frame.Option4:SetSize(110, 30)
		frame.Option4:SetPoint("LEFT", frame.Option3, "RIGHT", 4, 0)
		frame.Option4:SetText("")
		SetInstallButton(frame.Option4)
		frame.Option4.texture = frame.Option4:CreateTexture(nil, "BORDER")
		frame.Option4.texture:SetSize(110, 100)
		frame.Option4.texture:SetPoint("CENTER", frame.Option4, "BOTTOM", 0, -9)
		frame.Option4.texture:SetTexture(SV.media.button.option)
		frame.Option4.texture:SetGradient("VERTICAL", 0.3, 0.3, 0.3, 0.7, 0.7, 0.7)
		frame.Option4:SetScript("OnEnter", function(this)
			this.texture:SetVertexColor(0.5, 1, 0.4)
		end)
		frame.Option4:SetScript("OnLeave", function(this)
			this.texture:SetGradient("VERTICAL", 0.3, 0.3, 0.3, 0.7, 0.7, 0.7)
		end)
		frame.Option4:SetScript("OnShow", function()

			frame.Option2:SetWidth(110)
			frame.Option2.texture:SetSize(110, 110)
			frame.Option2.texture:SetPoint("CENTER", frame.Option2, "BOTTOM", 0, -(110 * 0.09))
			frame.Option2:ClearAllPoints()
			frame.Option2:SetPoint("BOTTOMRIGHT", frame, "BOTTOM", -4, 15)

			frame.Option1:SetWidth(110)
			frame.Option1.texture:SetSize(110, 110)
			frame.Option1.texture:SetPoint("CENTER", frame.Option1, "BOTTOM", 0, -(110 * 0.09))
			frame.Option1:ClearAllPoints()
			frame.Option1:SetPoint("RIGHT", frame.Option2, "LEFT", -4, 0)

			frame.Option3:SetWidth(110)
			frame.Option3.texture:SetSize(110, 110)
			frame.Option3.texture:SetPoint("CENTER", frame.Option3, "BOTTOM", 0, -(110 * 0.09))
			frame.Option3:ClearAllPoints()
			frame.Option3:SetPoint("LEFT", frame.Option2, "RIGHT", 4, 0)
		end)

		frame.Option4:SetFrameLevel(frame.Option1:GetFrameLevel() + 10)
		frame.Option4:Hide()

		--[[ TEXT HOLDERS ]]--

		local statusHolder = CreateFrame("Frame", nil, frame)
		statusHolder:SetFrameLevel(statusHolder:GetFrameLevel() + 2)
		statusHolder:SetSize(150, 30)
		statusHolder:SetPoint("BOTTOM", frame, "TOP", 0, 2)

		frame.Status = statusHolder:CreateFontString(nil, "OVERLAY")
		frame.Status:SetFont(SV.media.font.number, 22, "OUTLINE")
		frame.Status:SetPoint("CENTER")
		frame.Status:SetText(CURRENT_PAGE.."  /  "..MAX_PAGE)

		local titleHolder = frame:CreateFontString(nil, "OVERLAY")
		titleHolder:SetFont(SV.media.font.dialog, 22, "OUTLINE")
		titleHolder:SetPoint("TOP", 0, -5)
		titleHolder:SetText(L["SVUI Installation"])

		frame.SubTitle = frame:CreateFontString(nil, "OVERLAY")
		frame.SubTitle:SetFont(SV.media.font.alert, 16, "OUTLINE")
		frame.SubTitle:SetPoint("TOP", 0, -40)

		frame.Desc1 = frame:CreateFontString(nil, "OVERLAY")
		frame.Desc1:SetFont(SV.media.font.default, 14, "OUTLINE")
		frame.Desc1:SetPoint("TOPLEFT", 20, -75)
		frame.Desc1:SetWidth(frame:GetWidth()-40)

		frame.Desc2 = frame:CreateFontString(nil, "OVERLAY")
		frame.Desc2:SetFont(SV.media.font.default, 14, "OUTLINE")
		frame.Desc2:SetPoint("TOPLEFT", 20, -125)
		frame.Desc2:SetWidth(frame:GetWidth()-40)

		frame.Desc3 = frame:CreateFontString(nil, "OVERLAY")
		frame.Desc3:SetFont(SV.media.font.default, 14, "OUTLINE")
		frame.Desc3:SetPoint("TOPLEFT", 20, -175)
		frame.Desc3:SetWidth(frame:GetWidth()-40)

		--[[ MISC ]]--

		local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
		closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT")
		closeButton:SetScript("OnClick", function() frame:Hide() end)

		local tutorialImage = frame:CreateTexture(nil, "OVERLAY")
		tutorialImage:SetSize(256, 128)
		tutorialImage:SetTexture(SV.SplashImage)
		tutorialImage:SetPoint("BOTTOM", 0, 70)
	end

	SVUI_InstallerFrame:SetScript("OnHide", function()
		StopMusic()
		SetCVar("Sound_MusicVolume", 0)
		musicIsPlaying = nil;
		ShowLayout()
		ShowAuras()
	end)

	SVUI_InstallerFrame:Show()
	SVUI_InstallerFrame:SetPage(1)
	if(not autoLoaded) then
		PlayThemeSong();
	end
end
