--[[
##########################################################
S V U I   By: Failcoder
##########################################################
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
--LUA

local unpack            = _G.unpack;
local select            = _G.select;
local assert            = _G.assert;
local type              = _G.type;
local error             = _G.error;
local pcall             = _G.pcall;
local print             = _G.print;
local ipairs            = _G.ipairs;
local pairs             = _G.pairs;
local next              = _G.next;
local rawset            = _G.rawset;
local rawget            = _G.rawget;
local tostring          = _G.tostring;
local tonumber          = _G.tonumber;
--STRING
local string        = _G.string;
local format        = string.format;
local find          = string.find;
--MATH
local math          = _G.math;
local min 			= math.min;
local max 			= math.max;
local random 		= math.random;
--BLIZZARD API
local CreateFrame           = _G.CreateFrame;
local InCombatLockdown      = _G.InCombatLockdown;
local GameTooltip           = _G.GameTooltip;
local hooksecurefunc        = _G.hooksecurefunc;
local PlaySound             = _G.PlaySound;
local PlaySoundFile         = _G.PlaySoundFile;
local PlayMusic             = _G.PlayMusic;
local StopMusic             = _G.StopMusic;
local SetCVar               = _G.SetCVar;
local GetCVar               = _G.GetCVar;
local UnitName              = _G.UnitName;
local ToggleFrame           = _G.ToggleFrame;
local ERR_NOT_IN_COMBAT     = _G.ERR_NOT_IN_COMBAT;
local RAID_CLASS_COLORS     = _G.RAID_CLASS_COLORS;
local CUSTOM_CLASS_COLORS   = _G.CUSTOM_CLASS_COLORS;
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
NPC
##########################################################
]]--
SV.NPC = _G["SVUI_NPCFrame"];

local talkAnims = {60,64,65,67};

local function NPCTalking()
	local timer = 0;
	local sequence = random(1, #talkAnims);
	SV.NPC.Model:ClearModel()
	SV.NPC.Model:SetUnit('target')
	SV.NPC.Model:SetCamDistanceScale(1)
	SV.NPC.Model:SetPortraitZoom(0.95)
	SV.NPC.Model:SetPosition(0,0,0)
	SV.NPC.Model:SetAnimation(talkAnims[sequence],0)
	SV.NPC.Model:SetScript("OnUpdate",function(self,e)
		if(timer < 2000) then
			timer = (timer + (e*1000))
		else
			timer = 0;
			self:ClearModel()
			self:SetUnit('player')
			self:SetCamDistanceScale(1)
			self:SetPortraitZoom(0.95)
			self:SetPosition(0.15,0,0)
			self:SetRotation(-1)
			self:SetAnimation(0)
			self:SetScript("OnUpdate", nil)
		end
	end)
end

local function PlayerTalking()
	local timer = 0;
	local sequence = random(1, #talkAnims);
	SV.NPC.Model:ClearModel()
	SV.NPC.Model:SetUnit('player')
	SV.NPC.Model:SetCamDistanceScale(1)
	SV.NPC.Model:SetPortraitZoom(0.95)
	SV.NPC.Model:SetPosition(0.15,0,0)
	SV.NPC.Model:SetRotation(-1)
	SV.NPC.Model:SetAnimation(talkAnims[sequence],0)
	SV.NPC.Model:SetScript("OnUpdate",function(self,e)
		if(timer < 2000) then
			timer = (timer + (e*1000))
		else
			timer = 0;
			if(UnitExists("target")) then
				self:ClearModel()
				self:SetUnit('target')
				self:SetCamDistanceScale(1)
				self:SetPortraitZoom(0.95)
				self:SetPosition(0,0,0)
				self:SetRotation(0)
			end
			self:SetAnimation(0)
			self:SetScript("OnUpdate", nil)
		end
	end)
end

function SV.NPC:NPCTalksFirst()
	if(InCombatLockdown() or (not SV.db.FunStuff.NPC) or (not UnitExists("target"))) then return end
	local timer = 0;
	self.Model:ClearModel()
	self.Model:SetUnit('target')
	self.Model:SetCamDistanceScale(1)
	self.Model:SetPortraitZoom(0.95)
	self.Model:SetPosition(0,0,0)
	self.Model:SetRotation(0)
	self.Model:SetAnimation(67)
	self.Model:SetScript("OnUpdate",function(self,e)
		if(timer < 2000) then
			timer = (timer + (e*1000))
		else
			timer = 0;
			self:SetAnimation(0)
			self:SetScript("OnUpdate", nil)
			PlayerTalking()
		end
	end)
end

function SV.NPC:PlayerTalksFirst()
	if(InCombatLockdown() or (not SV.db.FunStuff.NPC) or (not UnitExists("target"))) then return end
	local timer = 0;
	self.Model:ClearModel()
	self.Model:SetUnit('player')
	self.Model:SetCamDistanceScale(1)
	self.Model:SetPortraitZoom(0.95)
	self.Model:SetPosition(0.15,0,0)
	self.Model:SetRotation(-1)
	self.Model:SetAnimation(67)
	self.Model:SetScript("OnUpdate",function(self,e)
		if(timer < 2000) then
			timer = (timer + (e*1000))
		else
			timer = 0;
			self:SetAnimation(0)
			self:SetScript("OnUpdate", nil)
			NPCTalking()
		end
	end)
end

local SetNPCText = function(self, text)
	self:Hide()
	SV.NPC.InfoTop.Text:SetText(text)
	SV.NPC.InfoTop:Show()
end

function SV.NPC:Toggle(parentFrame, textFrame)
	if(InCombatLockdown() or (not SV.db.FunStuff.NPC) or (not UnitExists("target"))) then return end
	local timer = 0;
	if(parentFrame) then
		self:SetParent(parentFrame)
		self:ClearAllPoints();
		self:SetAllPoints(parentFrame)
		self:Show();
		self:SetAlpha(1);

		self.Model:ClearModel()
		self.Model:SetUnit('target')
		self.Model:SetCamDistanceScale(1)
		self.Model:SetPortraitZoom(0.95)
		self.Model:SetPosition(0,0,0)

		if(textFrame and textFrame.GetText) then
			local text = textFrame:GetText()
			textFrame:Hide()
			self.InfoTop.Text:SetText(text)
			self.InfoTop:Show()
		else
			self.InfoTop:Hide()
		end

		SV.NPC:NPCTalksFirst()
	else
		self.Model:SetScript("OnUpdate", nil)
		self:SetAlpha(0);
		self.InfoTop:Hide();
		self:Hide();
	end
end

function SV.NPC:Register(parentFrame, textFrame)
	if(not SV.db.FunStuff.NPC) then return end
	parentFrame:HookScript('OnShow', function() SV.NPC:Toggle(parentFrame, textFrame) end)
	parentFrame:HookScript('OnHide', function() SV.NPC:Toggle() end)
	if(textFrame and textFrame.SetText) then
		hooksecurefunc(textFrame, "SetText", SetNPCText)
	end
end
--[[
##########################################################
AFK
##########################################################
]]--
SV.AFK = _G["SVUI_AFKFrame"];
local AFK_SEQUENCES = {
	[1] = 120,
	[2] = 141,
	[3] = 119,
	[4] = 5,
};

local Kill_AFK_Widget = function()
	if(InCombatLockdown()) then return end
	SV.AFK:SetScript("OnMouseDown", nil)
	for i,name in pairs(CHAT_FRAMES) do
		if(_G[name]) then
			SetChatWindowUninteractable(i, false)
		end
	end
	UIParent:Show();
	SV.AFK:SetAlpha(0);
	SV.AFK:Hide();
	if(SV.db.FunStuff.afk == '1') then
		MoveViewLeftStop();
	end
end

local Start_AFK_Widget = function()
	if(InCombatLockdown()) then return end
	local sequence = random(1, 4);
	if(SV.db.FunStuff.afk == '1') then
		MoveViewLeftStart(0.05);
	end
	SV.AFK:SetScript("OnMouseDown", Kill_AFK_Widget)
	SV.AFK:Show();
	UIParent:Hide();
	SV.AFK:SetAlpha(1);
	SV.AFK.Model:SetAnimation(AFK_SEQUENCES[sequence])
	DoEmote("READ")
end

local AFK_OnEvent = function(self, event)
	if(event == "PLAYER_FLAGS_CHANGED") then
		if(IsChatAFK() or UnitIsAFK("player")) then
			Start_AFK_Widget()
		else
			Kill_AFK_Widget()
		end
	else
		Kill_AFK_Widget()
	end
end

function SV.AFK:Toggle()
	if(SV.db.FunStuff.afk ~= 'NONE') then
		self:RegisterEvent("PLAYER_FLAGS_CHANGED")
		self:RegisterEvent("PLAYER_REGEN_DISABLED")
		self:RegisterEvent("PLAYER_ENTERING_WORLD")
		self:RegisterEvent("PET_BATTLE_OPENING_START")
		self:RegisterEvent("PLAYER_DEAD")
		self:SetScript("OnEvent", AFK_OnEvent)
	else
		self:UnregisterEvent("PLAYER_FLAGS_CHANGED")
		self:UnregisterEvent("PLAYER_REGEN_DISABLED")
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		self:UnregisterEvent("PET_BATTLE_OPENING_START")
		self:UnregisterEvent("PLAYER_DEAD")
		self:SetScript("OnEvent", nil)
	end
end
--[[
##########################################################
COMIX
##########################################################
]]--
SV.Comix = _G["SVUI_ComixFrame"];
local COMIX_DATA = {
	{
		{0,0.25,0,0.25},
		{0.25,0.5,0,0.25},
		{0.5,0.75,0,0.25},
		{0.75,1,0,0.25},
		{0,0.25,0.25,0.5},
		{0.25,0.5,0.25,0.5},
		{0.5,0.75,0.25,0.5},
		{0.75,1,0.25,0.5},
		{0,0.25,0.5,0.75},
		{0.25,0.5,0.5,0.75},
		{0.5,0.75,0.5,0.75},
		{0.75,1,0.5,0.75},
		{0,0.25,0.75,1},
		{0.25,0.5,0.75,1},
		{0.5,0.75,0.75,1},
		{0.75,1,0.75,1}
	},
	{
		{220, 210, 20, -20, 220, 210, -1, 5},
	    {230, 210, 20, 5, 280, 210, -5, 1},
	    {280, 160, 1, 20, 280, 210, -1, 5},
	    {220, 210, 20, -20, 220, 210, -1, 5},
	    {210, 190, 20, 20, 220, 210, -1, 5},
	    {220, 210, 20, -20, 220, 210, -1, 5},
	    {230, 210, 20, 5, 280, 210, -5, 1},
	    {280, 160, 1, 20, 280, 210, -1, 5},
	    {220, 210, 20, -20, 220, 210, -1, 5},
	    {210, 190, 20, 20, 220, 210, -1, 5},
	    {220, 210, 20, -20, 220, 210, -1, 5},
	    {230, 210, 20, 5, 280, 210, -5, 1},
	    {280, 160, 1, 20, 280, 210, -1, 5},
	    {220, 210, 20, -20, 220, 210, -1, 5},
	    {210, 190, 20, 20, 220, 210, -1, 5},
	    {210, 190, 20, 20, 220, 210, -1, 5}
	}
};

SV.Comix.Ready = true;

--/script SVUI.Comix:LaunchPremium()
function SV.Comix:LaunchPremium()
	self.Ready = false
	local coords, step1_x, step1_y, step2_x, step2_y, size, offsets;
	local key = random(1, 16);
	coords = COMIX_DATA[1][key];
	if(not coords) then return end
	offsets = COMIX_DATA[2][key]
	step1_x = offsets[1] * 0.1;
	step1_y = offsets[2] * 0.1;
	step2_x = (offsets[5] * 0.1) + offsets[3];
	step2_y = (offsets[6] * 0.1) + offsets[4];
	self.Premium.tex:SetTexCoord(coords[1],coords[2],coords[3],coords[4])
	self.Premium.bg.tex:SetTexCoord(coords[1],coords[2],coords[3],coords[4])
	-- self.Premium.anim[1]:SetOffset(offsets[1],offsets[2])
	-- self.Premium.anim[2]:SetOffset(offsets[3],offsets[4])
	self.Premium.anim[1]:SetOffset(step1_x, step1_y);
	self.Premium.anim[2]:SetOffset(offsets[3],offsets[4]);
	self.Premium.anim[3]:SetOffset(0,0)
	-- self.Premium.bg.anim[1]:SetOffset(offsets[5],offsets[6])
	-- self.Premium.bg.anim[2]:SetOffset(offsets[7],offsets[8])
	self.Premium.bg.anim[1]:SetOffset(step2_x, step2_y);
	self.Premium.bg.anim[2]:SetOffset(offsets[7],offsets[8]);
	self.Premium.bg.anim[3]:SetOffset(0,0)

	self.Premium.anim:Play()
	self.Premium.bg.anim:Play()
end

--/script SVUI.Comix:LaunchPopup()
function SV.Comix:LaunchPopup()
	self.Ready = false
	local coords, step1_x, step1_y, step2_x, step2_y, size, offsets;
	local rng = random(0, 32);
	local key = random(1, 16);
	coords = COMIX_DATA[1][key];
	if(not coords) then return end
	if((rng == 32) and (SV.db.FunStuff.comix == '1')) then
		ComixToastyPanelBG.anim[2]:SetOffset(256, -256)
		ComixToastyPanelBG.anim[2]:SetOffset(0, 0)
		ComixToastyPanelBG.anim:Play()
		PlaySoundFile([[Interface\AddOns\SVUI_!Core\assets\sounds\toasty.mp3]])
	elseif(rng < 24) then
		step1_x = random(-150, 150);
		if(step1_x > -20 and step1_x < 20) then step1_x = step1_x * 3 end
		step1_y = random(50, 150);
		step2_x = step1_x * 0.5;
		step2_y = step1_y * 0.75;
		self.Deluxe.tex:SetTexCoord(coords[1],coords[2],coords[3],coords[4]);
		self.Deluxe.anim[1]:SetOffset(step1_x, step1_y);
		self.Deluxe.anim[2]:SetOffset(step2_x, step2_y);
		self.Deluxe.anim[3]:SetOffset(0,0);
		self.Deluxe.anim:Play();
	elseif(rng < 12) then
		step1_x = random(-100, 100);
		step1_y = random(-50, 1);
		size = random(96,128);
		self.Basic:SetSize(size,size);
		self.Basic.tex:SetTexCoord(coords[1],coords[2],coords[3],coords[4]);
		self.Basic:ClearAllPoints();
		self.Basic:SetPoint("CENTER", SV.Screen, "CENTER", step1_x, step1_y);
		self.Basic.anim:Play();
	end
end

function SV:ToastyKombat()
	ComixToastyPanelBG.anim[2]:SetOffset(256, -256)
	ComixToastyPanelBG.anim[2]:SetOffset(0, 0)
	ComixToastyPanelBG.anim:Play()
	PlaySoundFile([[Interface\AddOns\SVUI_!Core\assets\sounds\toasty.mp3]])
end

_G.SlashCmdList["KOMBAT"] = function(msg)
	SV:ToastyKombat()
end
_G.SLASH_KOMBAT1 = "/kombat"

local Comix_OnEvent = function(self, event, ...)
	if(not self.Ready) then return end
	local _, subEvent, _, guid = ...;
	if((subEvent == "PARTY_KILL") and (guid == UnitGUID('player'))) then
		self:LaunchPopup()
	end
end

local Comix_OnUpdate = function() SV.Comix.Ready = true; end

local Toasty_OnUpdate = function(self) SV.Comix.Ready = true; self.parent:SetAlpha(0) end

function SV.Comix:Toggle()
	if(SV.db.FunStuff.comix == 'NONE') then
		self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		self:SetScript("OnEvent", nil)
	else
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		self:SetScript("OnEvent", Comix_OnEvent)
	end
end
--[[
##########################################################
DRUNK MODE
##########################################################
]]--
SV.Drunk = _G["SVUI_BoozedUpFrame"];
local WORN_ITEMS = {};
local DRUNK_EFFECT = [[Spells\Largebluegreenradiationfog.m2]];
local DRUNK_EFFECT2 = [[Spells\Monk_drunkenhaze_impact.m2]];
local TIPSY_FILTERS = {
	[DRUNK_MESSAGE_ITEM_SELF1] = true,
	[DRUNK_MESSAGE_ITEM_SELF2] = true,
	[DRUNK_MESSAGE_SELF1] = true,
	[DRUNK_MESSAGE_SELF2] = true,
};
local DRUNK_FILTERS = {
	[DRUNK_MESSAGE_ITEM_SELF3] = true,
	[DRUNK_MESSAGE_ITEM_SELF4] = true,
	[DRUNK_MESSAGE_SELF3] = true,
	[DRUNK_MESSAGE_SELF4] = true,
};

local function GetNekkid()
	for c = 1, 19 do
		if CursorHasItem() then
			ClearCursor()
		end
		local item = GetInventoryItemID("player", c);
		WORN_ITEMS[c] = item;
		PickupInventoryItem(c);
		for b = 1, 4 do
			if CursorHasItem() then
				PutItemInBag(b)
			end
		end
	end
end

local function GetDressed()
	for c, item in pairs(WORN_ITEMS) do
		if(item) then
			EquipItemByName(item)
			WORN_ITEMS[c] = false
		end
	end
end

function SV.Drunk:PartysOver()
	SetCVar("Sound_MusicVolume", 0)
	SetCVar("Sound_EnableMusic", 0)
	StopMusic()
	SV.Drunk:Hide()
	SV.Drunk.PartyMode = nil
	SV:AddonMessage("Party's Over...")
	--GetDressed()
end

function SV.Drunk:LetsParty()
	if(not SV.db.FunStuff.drunk) then return end
	--GetNekkid()
	self.PartyMode = true
	SetCVar("Sound_MusicVolume", 100)
	SetCVar("Sound_EnableMusic", 1)
	StopMusic()
	PlayMusic([[Interface\AddOns\SVUI_!Core\assets\sounds\beer30.mp3]])
	self:Show()
	self.ScreenEffect1:ClearModel()
	self.ScreenEffect1:SetModel(DRUNK_EFFECT)
	self.ScreenEffect2:ClearModel()
	self.ScreenEffect2:SetModel(DRUNK_EFFECT2)
	self.ScreenEffect3:ClearModel()
	self.ScreenEffect3:SetModel(DRUNK_EFFECT2)
	SV:AddonMessage("YEEEEEEEEE-HAW!!!")
	DoEmote("dance")
	-- SV.Timers:ExecuteTimer(PartysOver, 60)
end

local DrunkAgain_OnEvent = function(self, event, message, ...)
	if(self.PartyMode) then
		for pattern,_ in pairs(TIPSY_FILTERS) do
			if(message:find(pattern)) then
				self:PartysOver()
				break
			end
		end
	else
		for pattern,_ in pairs(DRUNK_FILTERS) do
			if(message:find(pattern)) then
				self:LetsParty()
				break
			end
		end
	end
end

_G.SLASH_PARTYSOVER1 = "/sobriety"
_G.SlashCmdList["PARTYSOVER"] = function(msg)
	if(SV.Drunk.PartyMode) then
		SV.Drunk:PartysOver()
	end
end

function SV.Drunk:Toggle()
	if(not SV.db.FunStuff.drunk) then
		self:UnregisterEvent("CHAT_MSG_SYSTEM")
		self:SetScript("OnEvent", nil)
	else
		self:RegisterEvent("CHAT_MSG_SYSTEM")
		self:SetScript("OnEvent", DrunkAgain_OnEvent)
	end
end
--[[
##########################################################
GAMEMENU
##########################################################
]]--
SV.GameMenu = _G["SVUI_GameMenuFrame"];
--[[
4    - walk
5    - run
26   - attack stance
40   - falling loop
52   - casting loop
55   - roar pose (paused)
60   - chat normal
64   - chat exclaimation
65   - chat shrug
69   - dance
74   - roar
111  - attack ready
119  - stealth walk
120  - stealth standing loop
125  - spell2
138  - craft loop
141  - kneel loop
203  - cannibalize
225  - cower loop
]]--
local Sequences = {26, 52, 111, 69};

local GameMenu_Activate = function(self)
	if(SV.db.FunStuff.gamemenu == 'NONE') then
		self:Toggle()
		return
	end
	local key = random(1, 4)
	local emote = Sequences[key]
	self:SetAlpha(1)
	self.ModelLeft:SetAnimation(emote)
	local models = SV.YOUR_HENCHMEN
	local mod = random(1, #models)
	self.ModelRight:ClearModel()
	self.ModelRight:SetDisplayInfo(models[mod][1])
	self.ModelRight:SetAnimation(emote)
end

function SV.GameMenu:Toggle()
	if(SV.db.FunStuff.gamemenu ~= 'NONE') then
		self:Show()
		self:SetScript("OnShow", GameMenu_Activate)
	else
		self:Hide()
		self:SetScript("OnShow", nil)
	end
end
--[[
##########################################################
LOAD BY TRIGGER
##########################################################
]]--
local function InitializeFunStuff()
	--[[ AFK SCREEN ]]--
	local afk = SV.AFK;
	local classToken = select(2,UnitClass("player"))
	local color = CUSTOM_CLASS_COLORS[classToken]
	if(not SV.db.general.customClassColor) then
		color = RAID_CLASS_COLORS[classToken]
	end

	afk.BG:SetVertexColor(color.r, color.g, color.b)
	afk.BG:ClearAllPoints()
	afk.BG:SetSize(500,600)
	afk.BG:SetPoint("BOTTOMRIGHT", afk, "BOTTOMRIGHT", 0, 0)

	afk:SetFrameLevel(0)
	afk:SetAllPoints(SV.Screen)

	local narr = afk.Model:CreateTexture(nil, "OVERLAY")
	narr:SetSize(300, 150)
	narr:SetTexture([[Interface\AddOns\SVUI_!Core\assets\textures\Doodads\AFK-NARRATIVE]])
	narr:SetPoint("TOPLEFT", SV.Screen, "TOPLEFT", 15, -15)

	afk.Model:ClearAllPoints()
	afk.Model:SetSize(600,600)
	afk.Model:SetPoint("BOTTOMRIGHT", afk, "BOTTOMRIGHT", 64, -64)
	afk.Model:SetUnit("player")
	afk.Model:SetCamDistanceScale(1.15)
	afk.Model:SetFacing(6)

	local splash = afk.Model:CreateTexture(nil, "OVERLAY")
	splash:SetSize(350, 175)
	splash:SetTexture([[Interface\AddOns\SVUI_!Core\assets\textures\Doodads\PLAYER-AFK]])
	splash:SetPoint("BOTTOMRIGHT", afk.Model, "CENTER", -75, 75)

	afk:Hide()
	if(SV.db.FunStuff.afk ~= 'NONE') then
		afk:RegisterEvent("PLAYER_FLAGS_CHANGED")
		afk:RegisterEvent("PLAYER_REGEN_DISABLED")
		afk:RegisterEvent("PLAYER_ENTERING_WORLD")
		afk:RegisterEvent("PET_BATTLE_OPENING_START")
		afk:SetScript("OnEvent", AFK_OnEvent)
		UIParent:HookScript("OnShow", Kill_AFK_Widget)
		SV.Events:On("SPECIAL_FRAMES_CLOSED", Kill_AFK_Widget, true);
	end

	--[[ COMIX POPUPS ]]--
	local comix = SV.Comix
	comix.Basic = _G["SVUI_ComixPopup1"]
	comix.Deluxe = _G["SVUI_ComixPopup2"]
	comix.Premium = _G["SVUI_ComixPopup3"]

	comix.Basic:SetParent(SV.Screen)
	comix.Basic:SetSize(100,100)
	comix.Basic.tex:SetTexCoord(0,0.25,0,0.25)
	SV.Animate:Kapow(comix.Basic, true, true)
	comix.Basic:SetAlpha(0)
	comix.Basic:Show()
	comix.Basic.anim[2]:SetScript("OnFinished", Comix_OnUpdate)

	comix.Deluxe:SetParent(SV.Screen)
	comix.Deluxe:SetSize(100,100)
	comix.Deluxe.tex:SetTexCoord(0,0.25,0,0.25)
	SV.Animate:RandomSlide(comix.Deluxe, true)
	comix.Deluxe:SetAlpha(0)
	comix.Deluxe:Show()
	comix.Deluxe.anim[3]:SetScript("OnFinished", Comix_OnUpdate)

	comix.Premium:SetParent(SV.Screen)
	comix.Premium:SetSize(96,96);
	comix.Premium.tex:SetTexCoord(0,0.25,0,0.25)
	--comix.Premium.tex:SetBlendMode('ADD')
	SV.Animate:RandomSlide(comix.Premium, true)
	comix.Premium:SetAlpha(0)
	comix.Premium:Show()
	comix.Premium.anim[3]:SetScript("OnFinished", Comix_OnUpdate)

	comix.Premium.bg:SetSize(96,96);
	comix.Premium.bg.tex:SetTexCoord(0,0.25,0,0.25)
	comix.Premium.bg.tex:SetBlendMode('ADD')
	SV.Animate:RandomSlide(comix.Premium.bg, false)
	comix.Premium.bg:SetAlpha(0)
	comix.Premium.bg.anim[3]:SetScript("OnFinished", Comix_OnUpdate)

	local toasty = CreateFrame("Frame", "ComixToastyPanelBG", SV.Screen)
	toasty:SetSize(256, 256)
	toasty:SetFrameStrata("DIALOG")
	toasty:SetPoint("BOTTOMRIGHT", SV.Screen, "BOTTOMRIGHT", 0, 0)
	toasty.tex = toasty:CreateTexture(nil, "ARTWORK")
	toasty.tex:InsetPoints(toasty)
	toasty.tex:SetTexture([[Interface\AddOns\SVUI_!Core\assets\textures\Doodads\TOASTY]])
	SV.Animate:Slide(toasty, 256, -256, true)
	toasty:SetAlpha(0)
	toasty.anim[4]:SetScript("OnFinished", Toasty_OnUpdate)

	comix.Ready = true;
	comix:Toggle()

	--[[ DRUNK MODE ]]--
	local drunk = SV.Drunk;
	drunk:SetParent(SV.Screen)
	drunk:ClearAllPoints()
	drunk:SetAllPoints(SV.Screen)

	drunk.ScreenEffect1:SetParent(drunk)
	drunk.ScreenEffect1:SetAllPoints(SV.Screen)
	drunk.ScreenEffect1:SetModel(DRUNK_EFFECT)
	drunk.ScreenEffect1:SetCamDistanceScale(1)

	drunk.ScreenEffect2:SetParent(drunk)
	drunk.ScreenEffect2:SetPoint("BOTTOMLEFT", SV.Screen, "BOTTOMLEFT", 0, 0)
	drunk.ScreenEffect2:SetPoint("TOPRIGHT", SV.Screen, "TOP", 0, 0)
	drunk.ScreenEffect2:SetModel(DRUNK_EFFECT2)
	drunk.ScreenEffect2:SetCamDistanceScale(0.25)

	drunk.ScreenEffect3:SetParent(drunk)
	drunk.ScreenEffect3:SetPoint("BOTTOMRIGHT", SV.Screen, "BOTTOMRIGHT", 0, 0)
	drunk.ScreenEffect3:SetPoint("TOPLEFT", SV.Screen, "TOP", 0, 0)
	drunk.ScreenEffect3:SetModel(DRUNK_EFFECT2)
	drunk.ScreenEffect3:SetCamDistanceScale(0.25)

	drunk.YeeHaw:SetSize(512,350);
	drunk:Hide()
	drunk:Toggle()

	--[[ GAME MENU ]]--
	local gamemenu = SV.GameMenu;
	gamemenu:SetAllPoints(SV.Screen)

	gamemenu.ModelLeft:SetUnit("player")
	gamemenu.ModelLeft:SetRotation(1)
	gamemenu.ModelLeft:SetPortraitZoom(0.05)
	gamemenu.ModelLeft:SetPosition(0,0,-0.25)

	if(SV.db.FunStuff.gamemenu == '1') then
		gamemenu.ModelRight:SetDisplayInfo(49084)
		gamemenu.ModelRight:SetRotation(-1)
		gamemenu.ModelRight:SetCamDistanceScale(1.9)
		gamemenu.ModelRight:SetFacing(6)
		gamemenu.ModelRight:SetPosition(0,0,-0.3)
	elseif(SV.db.FunStuff.gamemenu == '2') then
		gamemenu.ModelRight:SetUnit("player")
		gamemenu.ModelRight:SetRotation(-1)
		gamemenu.ModelRight:SetCamDistanceScale(1.9)
		gamemenu.ModelRight:SetFacing(6)
		gamemenu.ModelRight:SetPosition(0,0,-0.3)
	end

	gamemenu:SetScript("OnShow", GameMenu_Activate)

	local npc = SV.NPC;
	npc.Model:SetStyle("Frame", "Model", false, 5, 3, 3)
	npc.InfoTop = CreateFrame("Frame", nil, npc)
	npc.InfoTop:SetPoint("BOTTOMLEFT", npc.Model, "BOTTOMRIGHT", 2, 22)
	npc.InfoTop:SetSize(196, 98)
	npc.InfoTop:SetBackdrop({
		bgFile = [[Interface\AddOns\SVUI_!Core\assets\textures\NPC-NAMETAG]],
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
	});
  	npc.InfoTop:SetBackdropColor(1, 1, 0, 1)
	npc.InfoTop:SetFrameLevel(npc:GetFrameLevel() + 1)

	npc.InfoTop.Text = npc.InfoTop:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	npc.InfoTop.Text:SetPoint("TOPLEFT", npc.InfoTop, "TOPLEFT", 0, -33)
	npc.InfoTop.Text:SetPoint("BOTTOMRIGHT", npc.InfoTop, "BOTTOMRIGHT", 0, 0)
end

SV.Events:On("CORE_INITIALIZED", InitializeFunStuff);
