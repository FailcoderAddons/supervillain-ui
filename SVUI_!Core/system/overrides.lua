--[[
##########################################################
S V U I   By: Failcoder
##########################################################
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
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
local string 	= _G.string;
local math 		= _G.math;
--[[ STRING METHODS ]]--
local find, format, len, split = string.find, string.format, string.len, string.split;
--[[ MATH METHODS ]]--
local abs, ceil, floor, round, max = math.abs, math.ceil, math.floor, math.round, math.max;
--BLIZZARD API
local CreateFrame           = _G.CreateFrame;
local InCombatLockdown      = _G.InCombatLockdown;
local GameTooltip           = _G.GameTooltip;
local LootFrame           	= _G.LootFrame;
local ConfirmLootRoll       = _G.ConfirmLootRoll;
local StaticPopup_Hide      = _G.StaticPopup_Hide;
local C_LootHistory         = _G.C_LootHistory;
local UnitName              = _G.UnitName;
local UnitIsDead            = _G.UnitIsDead;
local UnitIsFriend          = _G.UnitIsFriend;
local UnitInVehicle         = _G.UnitInVehicle;
local UnitControllingVehicle= _G.UnitControllingVehicle;
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
local POSITION, ANCHOR_POINT, YOFFSET = "TOP", "BOTTOM", -10
local FORCE_POSITION = false;
local NewHook = hooksecurefunc;
local lastQuality,lastID,lastName;
local dead_rollz = {};
-- UPVALUES
local AUTOROLL_ENABLED = false;
local AUTOROLL_SOULBOUND = false;
local AUTOROLL_LEVEL = false;
local AUTOROLL_QUALITY = 2;
local AUTOROLL_DE = true;
--[[
##########################################################
MIRROR BARS
##########################################################
]]--
local MirrorBarEventFrame = CreateFrame("Frame", nil)

local mirrorYOffset={
	["BREATH"] = 96,
	["EXHAUSTION"] = 119,
	["FEIGNDEATH"] = 142
}
local mirrorTypeColor={
	EXHAUSTION = {1,.9,0},
	BREATH = {0.31,0.45,0.63},
	DEATH = {1,.7,0},
	FEIGNDEATH = {1,.7,0}
}
local RegisteredMirrorBars = {}

local MirrorBar_OnUpdate = function(self, elapsed)
	if self.paused then
		return
	end
	self.lastupdate = (self.lastupdate or 0) + elapsed;
	if self.lastupdate < .1 then
		return
	end
	self.lastupdate = 0;
	self:SetValue(GetMirrorTimerProgress(self.type) / 1e3)
end

local MirrorBar_Start = function(self, min, max, s, t, text)
	if t > 0 then
		self.paused = 1
	elseif self.paused then
		self.paused = nil
	end
	self.text:SetText(text)
	self:SetMinMaxValues(0, max / 1e3)
	self:SetValue(min / 1e3)
	if not self:IsShown() then
		self:Show()
	end
end

local function MirrorBarRegistry(barType)
	if RegisteredMirrorBars[barType] then
		return RegisteredMirrorBars[barType]
	end
	local bar = CreateFrame('StatusBar', nil, UIParent)
	bar:SetStyle("Frame", "Bar", false, 3, 3, 3)
	bar:SetScript("OnUpdate", MirrorBar_OnUpdate)
	local r, g, b = unpack(mirrorTypeColor[barType])
	bar.text = bar:CreateFontString(nil, 'OVERLAY')
	bar.text:SetFontObject(SVUI_Font_Default)
	bar.text:SetJustifyH('CENTER')
	bar.text:SetTextColor(1, 1, 1)
	bar.text:SetPoint('LEFT', bar)
	bar.text:SetPoint('RIGHT', bar)
	bar.text:SetPoint('TOP', bar, 0, 2)
	bar.text:SetPoint('BOTTOM', bar)
	bar:SetSize(222, 18)
	bar:SetStatusBarTexture(SV.media.statusbar.gradient)
	bar:SetStatusBarColor(r, g, b)
	bar.type = barType;
	bar.Start = MirrorBar_Start;

	local yOffset = mirrorYOffset[bar.type]
	bar:SetPoint("TOP", SV.Screen, "TOP", 0, -yOffset)
	RegisteredMirrorBars[barType] = bar;
	return bar
end

local function SetTimerStyle(bar)
	for i=1, bar:GetNumRegions()do
		local child = select(i, bar:GetRegions())
		if child:GetObjectType() == "Texture"then
			child:SetTexture("")
		elseif child:GetObjectType() == "FontString" then
			child:SetFontObject(SVUI_Font_Default)
		end
	end
	bar:SetStatusBarTexture(SV.media.statusbar.gradient)
	bar:SetStatusBarColor(0.37, 0.92, 0.08)
	bar:SetStyle("Frame", "Bar", false, 3, 3, 3)
end

local MirrorBar_OnEvent = function(self, event, arg, ...)
	if(event == 'CVAR_UPDATE' or event == 'PLAYER_ENTERING_WORLD') then
		if not GetCVarBool("lockActionBars") and SV.db.ActionBars.enable then
			SetCVar("lockActionBars", 1)
		end
		if(event == "PLAYER_ENTERING_WORLD") then
			for i = 1, MIRRORTIMER_NUMTIMERS do
				local v, q, r, s, t, u = GetMirrorTimerInfo(i)
				if v ~= "UNKNOWN"then
					MirrorBarRegistry(v):Start(q, r, s, t, u)
				end
			end
		end
	else
		if(event == "START_TIMER") then
			for _,timer in pairs(TimerTracker.timerList)do
				if timer["bar"] and not timer["bar"].styled then
					SetTimerStyle(timer["bar"])
					timer["bar"].styled = true
				end
			end
		elseif(event == "MIRROR_TIMER_START") then
			return MirrorBarRegistry(arg):Start(...)
		elseif(event == "MIRROR_TIMER_STOP") then
			return MirrorBarRegistry(arg):Hide()
		elseif(event == "MIRROR_TIMER_PAUSE") then
			local pausedValue = (arg > 0 and arg or nil);
			for barType,bar in next,RegisteredMirrorBars do
				bar.paused = pausedValue;
			end
		end
	end
end
--[[
##########################################################
LOOTING
##########################################################
]]--
local LootingEventFrame = CreateFrame("Frame", nil);
local RollTypePresets = {
	[0] = {
		"Interface\\Buttons\\UI-GroupLoot-Pass-Up",
		"",
		"Interface\\Buttons\\UI-GroupLoot-Pass-Down",
		[[0]],
		[[2]]
	},
	[1] = {
		"Interface\\Buttons\\UI-GroupLoot-Dice-Up",
		"Interface\\Buttons\\UI-GroupLoot-Dice-Highlight",
		"Interface\\Buttons\\UI-GroupLoot-Dice-Down",
		[[5]],
		[[-1]]
	},
	[2] = {
		"Interface\\Buttons\\UI-GroupLoot-Coin-Up",
		"Interface\\Buttons\\UI-GroupLoot-Coin-Highlight",
		"Interface\\Buttons\\UI-GroupLoot-Coin-Down",
		[[0]],
		[[-1]]
	},
	[3] = {
		"Interface\\Buttons\\UI-GroupLoot-DE-Up",
		"Interface\\Buttons\\UI-GroupLoot-DE-Highlight",
		"Interface\\Buttons\\UI-GroupLoot-DE-Down",
		[[0]],
		[[-1]]
	}
};
local LootRollType = {[1] = "need", [2] = "greed", [3] = "disenchant", [0] = "pass"};
local LOOT_WIDTH, LOOT_HEIGHT = 328, 28;

local SVUI_LootFrameHolder = CreateFrame("Frame", "SVUI_LootFrameHolder", UIParent);
SVUI_LootFrameHolder:SetPoint("BOTTOMRIGHT", SVUI_DockTopLeft, "BOTTOMRIGHT", 0, 0);
SVUI_LootFrameHolder:SetSize(150, 22);
SVUI_LootFrameHolder:SetFrameStrata("FULLSCREEN_DIALOG");
SVUI_LootFrameHolder:SetToplevel(true);

local SVUI_LootFrame = CreateFrame('Button', 'SVUI_LootFrame', SVUI_LootFrameHolder);
SVUI_LootFrame:SetClampedToScreen(true);
SVUI_LootFrame:SetPoint('TOPLEFT');
SVUI_LootFrame:SetSize(256, 64);
SVUI_LootFrame.title = SVUI_LootFrame:CreateFontString(nil,'OVERLAY');
SVUI_LootFrame.title:SetPoint('BOTTOMLEFT',SVUI_LootFrame,'TOPLEFT',0,1);
SVUI_LootFrame.slots = {};
SVUI_LootFrame:Hide();
SVUI_LootFrame:SetScript("OnHide", function(self)
	SV:StaticPopup_Hide("CONFIRM_LOOT_DISTRIBUTION");
	CloseLoot()
end);

local function UpdateLootUpvalues()
	LOOT_WIDTH = SV.db.general.lootRollWidth
	LOOT_HEIGHT = SV.db.general.lootRollHeight
end

local DoDaRoll = function(self)
	RollOnLoot(self.parent.rollID, self.rolltype)
end

local LootRoll_OnLeave = function(self)
	GameTooltip:Hide()
end

local LootItem_OnLeave = function(self)
	GameTooltip:Hide()
	ResetCursor()
end

local LootRoll_SetTooltip = function(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetText(self.tiptext)
	if self:IsEnabled() == 0 then
		GameTooltip:AddLine("|cffff3333"..L["Can't Roll"])
	end
	for r, s in pairs(self.parent.rolls)do
		if LootRollType[s] == LootRollType[self.rolltype] then
			GameTooltip:AddLine(r, 1, 1, 1)
		end
	end
	GameTooltip:Show()
end

local LootItem_SetTooltip = function(self)
	if not self.link then
		return
	end
	GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
	GameTooltip:SetHyperlink(self.link)
	if IsShiftKeyDown() then
		GameTooltip_ShowCompareItem()
	end
	if IsModifiedClick("DRESSUP") then
		ShowInspectCursor()
	else
		ResetCursor()
	end
end

local LootItem_OnUpdate = function(self)
	if IsShiftKeyDown() then
		GameTooltip_ShowCompareItem()
	end
	CursorOnUpdate(self)
end

local LootRoll_OnClick = function(self)
	if IsControlKeyDown() then
		DressUpItemLink(self.link)
	elseif IsShiftKeyDown() then
		ChatEdit_InsertLink(self.link)
	end
end

local LootRoll_OnEvent = function(self, event, value)
	dead_rollz[value] = true;
	if self.rollID ~= value then
		return
	end
	self.rollID = nil;
	self.time = nil;
	self:Hide()
end

local LootRoll_OnUpdate = function(self)
	if not self.parent.rollID then return end
	local remaining = GetLootRollTimeLeft(self.parent.rollID)
	local mu = remaining / self.parent.time;
	self.spark:SetPoint("CENTER", self, "LEFT", mu * self:GetWidth(), 0)
	self:SetValue(remaining)
	if remaining > 1000000000 then
		self:GetParent():Hide()
	end
end

local LootSlot_OnEnter = function(self)
	local slotID = self:GetID()
	if LootSlotHasItem(slotID) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetLootItem(slotID)
		CursorUpdate(self)
	end
	self.drop:Show()
	self.drop:SetVertexColor(1, 1, 0)
end

local LootSlot_OnLeave = function(self)
	if self.quality and self.quality > 1 then
		local color = ITEM_QUALITY_COLORS[self.quality]
		self.drop:SetVertexColor(color.r, color.g, color.b)
	else
		self.drop:Hide()
	end
	GameTooltip:Hide()
	ResetCursor()
end

local LootSlot_OnClick = function(self)
	LootFrame.selectedQuality = self.quality;
	LootFrame.selectedItemName = self.name:GetText()
	LootFrame.selectedSlot = self:GetID()
	LootFrame.selectedLootButton = self:GetName()
	LootFrame.selectedTexture = self.icon:GetTexture()
	if IsModifiedClick() then
		HandleModifiedItemClick(GetLootSlotLink(self:GetID()))
	else
		StaticPopup_Hide("CONFIRM_LOOT_DISTRIBUTION")
		lastID = self:GetID()
		lastQuality = self.quality;
		lastName = self.name:GetText()
		LootSlot(lastID)
	end
end

local LootSlot_OnShow = function(self)
	if GameTooltip:IsOwned(self) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetLootItem(self:GetID())
		CursorOnUpdate(self)
	end
end

local function HandleSlots(frame)
	local scale = 30;
	local counter = 0;
	for i = 1, #frame.slots do
		local slot = frame.slots[i]
		if slot:IsShown() then
			counter = counter + 1;
			slot:SetPoint("TOP", SVUI_LootFrame, 4, (-8 + scale) - (counter * scale))
		end
	end
	frame:SetHeight(max(counter * scale + 16, 20))
end

local function MakeSlots(id)
	local size = LOOT_HEIGHT;
	local slot = CreateFrame("Button", "SVUI_LootSlot"..id, SVUI_LootFrame)
	slot:SetPoint("LEFT", 8, 0)
	slot:SetPoint("RIGHT", -8, 0)
	slot:SetHeight(size)
	slot:SetID(id)
	slot:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	slot:SetScript("OnEnter", LootSlot_OnEnter)
	slot:SetScript("OnLeave", LootSlot_OnLeave)
	slot:SetScript("OnClick", LootSlot_OnClick)
	slot:SetScript("OnShow", LootSlot_OnShow)

	slot.iconFrame = CreateFrame("Frame", nil, slot)
	slot.iconFrame:SetHeight(size)
	slot.iconFrame:SetWidth(size)
	slot.iconFrame:SetPoint("RIGHT", slot)
	slot.iconFrame:SetStyle("Frame", "Transparent")

	slot.icon = slot.iconFrame:CreateTexture(nil, "ARTWORK")
	slot.icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
	slot.icon:InsetPoints()

	slot.count = slot.iconFrame:CreateFontString(nil, "OVERLAY")
	slot.count:SetJustifyH("RIGHT")
	slot.count:SetPoint("BOTTOMRIGHT", slot.iconFrame, -2, 2)
	slot.count:SetFontObject(SVUI_Font_Loot_Number)
	slot.count:SetText(1)

	slot.name = slot:CreateFontString(nil, "OVERLAY")
	slot.name:SetJustifyH("LEFT")
	slot.name:SetPoint("LEFT", slot)
	slot.name:SetPoint("RIGHT", slot.icon, "LEFT")
	slot.name:SetNonSpaceWrap(true)
	slot.name:SetFontObject(SVUI_Font_Loot)

	slot.drop = slot:CreateTexture(nil, "ARTWORK")
	slot.drop:SetTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight")
	slot.drop:SetPoint("LEFT", slot.icon, "RIGHT", 0, 0)
	slot.drop:SetPoint("RIGHT", slot)
	slot.drop:SetAllPoints(slot)
	slot.drop:SetAlpha(.3)

	slot.questTexture = slot.iconFrame:CreateTexture(nil, "OVERLAY")
	slot.questTexture:InsetPoints()
	slot.questTexture:SetTexture(TEXTURE_ITEM_QUEST_BANG)
	slot.questTexture:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))

	SVUI_LootFrame.slots[id] = slot;
	return slot
end

local function CreateRollButton(rollFrame, type, locale, anchor)
	local btnSize = LOOT_HEIGHT - 4;
	local preset = RollTypePresets[type];
	local rollButton = CreateFrame("Button", nil, rollFrame)
	rollButton:SetPoint("LEFT", anchor, "RIGHT", tonumber(preset[4]), tonumber(preset[5]))
	rollButton:SetSize(btnSize, btnSize)
	rollButton:SetNormalTexture(preset[1])
	if preset[2] and preset[2] ~= "" then
		rollButton:SetPushedTexture(preset[2])
	end
	rollButton:SetHighlightTexture(preset[3])
	rollButton.rolltype = type;
	rollButton.parent = rollFrame;
	rollButton.tiptext = locale;
	rollButton:SetScript("OnEnter", LootRoll_SetTooltip)
	rollButton:SetScript("OnLeave", LootRoll_OnLeave)
	rollButton:SetScript("OnClick", DoDaRoll)
	rollButton:SetMotionScriptsWhileDisabled(true)
	local text = rollButton:CreateFontString(nil, nil)
	text:SetFontObject(SVUI_Font_Roll)
	text:SetPoint("CENTER", 0, ((type == 2 and 1) or (type == 0 and -1.2) or 0))
	return rollButton, text
end

local function CreateRollFrame()
	UpdateLootUpvalues()
	local btnSize = LOOT_HEIGHT - 2;
	local rollFrame = CreateFrame("Frame", nil, UIParent)
	rollFrame:SetSize(LOOT_WIDTH,LOOT_HEIGHT)
	rollFrame:SetStyle("!_Frame", 'Default')
	rollFrame:SetScript("OnEvent",LootRoll_OnEvent)
	rollFrame:RegisterEvent("CANCEL_LOOT_ROLL")
	rollFrame:Hide()
	rollFrame.button = CreateFrame("Button",nil,rollFrame)
	rollFrame.button:SetPoint("RIGHT",rollFrame,'LEFT',0,0)
	rollFrame.button:SetSize(btnSize, btnSize)
	rollFrame.button:SetStyle("Frame", 'Default')
	rollFrame.button:SetScript("OnEnter",LootItem_SetTooltip)
	rollFrame.button:SetScript("OnLeave",LootItem_OnLeave)
	rollFrame.button:SetScript("OnUpdate",LootItem_OnUpdate)
	rollFrame.button:SetScript("OnClick",LootRoll_OnClick)
	rollFrame.button.icon = rollFrame.button:CreateTexture(nil,'OVERLAY')
	rollFrame.button.icon:SetAllPoints()
	rollFrame.button.icon:SetTexCoord(0.1,0.9,0.1,0.9 )
	local border = rollFrame:CreateTexture(nil,"BORDER")
	border:SetPoint("TOPLEFT",rollFrame,"TOPLEFT",4,0)
	border:SetPoint("BOTTOMRIGHT",rollFrame,"BOTTOMRIGHT",-4,0)
	border:SetTexture("Interface\\ChatFrame\\ChatFrameBackground")
	border:SetBlendMode("ADD")
	border:SetGradientAlpha("VERTICAL",.1,.1,.1,0,.1,.1,.1,0)
	rollFrame.status=CreateFrame("StatusBar",nil,rollFrame)
	rollFrame.status:InsetPoints()
	rollFrame.status:SetScript("OnUpdate",LootRoll_OnUpdate)
	rollFrame.status:SetFrameLevel(rollFrame.status:GetFrameLevel() - 1)
	rollFrame.status:SetStatusBarTexture(SV.media.statusbar.gradient)
	rollFrame.status:SetStatusBarColor(.8,.8,.8,.9)
	rollFrame.status.parent = rollFrame;
	rollFrame.status.bg = rollFrame.status:CreateTexture(nil,'BACKGROUND')
	rollFrame.status.bg:SetAlpha(0.1)
	rollFrame.status.bg:SetAllPoints()
	rollFrame.status.bg:SetDrawLayer('BACKGROUND',2)
	rollFrame.status.spark = rollFrame:CreateTexture(nil,"OVERLAY")
	rollFrame.status.spark:SetSize(LOOT_HEIGHT * 0.5, LOOT_HEIGHT)
	rollFrame.status.spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
	rollFrame.status.spark:SetBlendMode("ADD")

	local needButton,needText = CreateRollButton(rollFrame,1,NEED,rollFrame.button)
	local greedButton,greedText = CreateRollButton(rollFrame,2,GREED,needButton,"RIGHT")
	local deButton,deText = CreateRollButton(rollFrame,3,ROLL_DISENCHANT,greedButton)
	local passButton,passText = CreateRollButton(rollFrame,0,PASS,deButton or greedButton)
	rollFrame.NeedIt,rollFrame.WantIt,rollFrame.BreakIt = needButton,greedButton,deButton;
	rollFrame.need,rollFrame.greed,rollFrame.pass,rollFrame.disenchant = needText,greedText,passText,deText;
	rollFrame.bindText = rollFrame:CreateFontString()
	rollFrame.bindText:SetPoint("LEFT",passButton,"RIGHT",3,1)
	rollFrame.bindText:SetFontObject(SVUI_Font_Roll_Number)
	rollFrame.lootText = rollFrame:CreateFontString(nil,"ARTWORK")
	rollFrame.lootText:SetFontObject(SVUI_Font_Roll_Number)
	rollFrame.lootText:SetPoint("LEFT",rollFrame.bindText,"RIGHT",0,0)
	rollFrame.lootText:SetPoint("RIGHT",rollFrame,"RIGHT",-5,0)
	rollFrame.lootText:SetSize(200,10)
	rollFrame.lootText:SetJustifyH("LEFT")

	rollFrame.yourRoll = rollFrame:CreateFontString(nil,"ARTWORK")
	rollFrame.yourRoll:SetFontObject(SVUI_Font_Roll_Number)
	rollFrame.yourRoll:SetSize(22,22)
	rollFrame.yourRoll:SetPoint("LEFT",rollFrame,"RIGHT",5,0)
	rollFrame.yourRoll:SetJustifyH("CENTER")

	rollFrame.rolls = {}
	return rollFrame
end

local function FetchRollFrame()
	local rollFrames = SV.RollFrames;
	local rollCount = #rollFrames;
	for i=1, rollCount do
		local frame = rollFrames[i];
		if not frame.rollID then
			return frame
		end
	end

	local anchorParent = rollFrames[rollCount] or SVUI_AlertFrame;
	local roll = CreateRollFrame();
	roll:SetPoint("TOP", anchorParent, "BOTTOM", 0, -4);
	rollFrames[rollCount+1] = roll;
	return roll
end
--[[
##########################################################
CORE FUNCTIONS
##########################################################
]]--
local function AutoGreed(rollID, quality, DE, BoP)
	if(not AUTOROLL_ENABLED) then return end
	-- if(AUTOROLL_LEVEL and (UnitLevel('player') < MAX_PLAYER_LEVEL)) then
	-- 	return
	-- end
	if(quality <= AUTOROLL_QUALITY) then
		if(DE and AUTOROLL_DE) then
			if(not (BoP and (not AUTOROLL_SOULBOUND))) then
				RollOnLoot(rollID, 3)
			else
				RollOnLoot(rollID, 2)
			end
		else
			RollOnLoot(rollID, 2)
		end
	end
end

local EventFunc = {};

EventFunc["CONFIRM_LOOT_ROLL"] = function(arg1, arg2, ...)
	ConfirmLootRoll(arg1, arg2)
	StaticPopup_Hide("CONFIRM_LOOT_ROLL")
end

EventFunc["CONFIRM_DISENCHANT_ROLL"] = function(arg1, arg2, ...)
	ConfirmLootRoll(arg1, arg2)
	StaticPopup_Hide("CONFIRM_LOOT_ROLL")
end

EventFunc["LOOT_BIND_CONFIRM"] = function(arg1, arg2, ...)
	ConfirmLootSlot(arg1, arg2)
	StaticPopup_Hide("LOOT_BIND", ...)
end

EventFunc["LOOT_SLOT_CLEARED"] = function(slot)
	if not SVUI_LootFrame:IsShown() then return; end
	SVUI_LootFrame.slots[slot]:Hide()
	HandleSlots(SVUI_LootFrame)
end

EventFunc["LOOT_CLOSED"] = function(...)
	StaticPopup_Hide("LOOT_BIND")
	SVUI_LootFrame:Hide()
	for _,slot in pairs(SVUI_LootFrame.slots)do
		slot:Hide()
	end
end

EventFunc["OPEN_MASTER_LOOT_LIST"] = function(...)
	ToggleDropDownMenu(1, nil, GroupLootDropDown, SVUI_LootFrame.slots[lastID], 0, 0)
end

EventFunc["UPDATE_MASTER_LOOT_LIST"] = function(...)
	MasterLooterFrame_UpdatePlayers()
end

EventFunc["LOOT_HISTORY_ROLL_CHANGED"] = function(arg1, arg2)
	local rollID,_,_,_,_,_ = C_LootHistory.GetItem(arg1);
	local name,_,rollType,rollResult,_ = C_LootHistory.GetPlayerInfo(arg1,arg2);
	if name and rollType then
		for _,roll in ipairs(SV.RollFrames)do
			if roll.rollID == rollID then
				roll.rolls[name] = rollType;
				roll[LootRollType[rollType]]:SetText(tonumber(roll[LootRollType[rollType]]:GetText()) + 1);
				return
			end
			if rollResult then
				roll.yourRoll:SetText(tostring(rollResult))
			end
		end
	end
end

EventFunc["START_LOOT_ROLL"] = function(rollID, rollTime)
	if dead_rollz[rollID] then return end
	local texture,name,count,quality,bindOnPickUp,canNeed,canGreed,canBreak = GetLootRollItemInfo(rollID);
	local color = ITEM_QUALITY_COLORS[quality];
	local rollFrame = FetchRollFrame();
	rollFrame.rollID = rollID;
	rollFrame.time = rollTime;
	for i in pairs(rollFrame.rolls)do
		rollFrame.rolls[i] = nil
	end
	rollFrame.need:SetText(0)
	rollFrame.greed:SetText(0)
	rollFrame.pass:SetText(0)
	rollFrame.disenchant:SetText(0)
	rollFrame.button.icon:SetTexture(texture)
	rollFrame.button.link = GetLootRollItemLink(rollID)
	if canNeed then
		rollFrame.NeedIt:Enable()
		rollFrame.NeedIt:SetAlpha(1)
	else
		rollFrame.NeedIt:SetAlpha(0.2)
		rollFrame.NeedIt:Disable()
	end
	if canGreed then
		rollFrame.WantIt:Enable()
		rollFrame.WantIt:SetAlpha(1)
	else
		rollFrame.WantIt:SetAlpha(0.2)
		rollFrame.WantIt:Disable()
	end
	if canBreak then
		rollFrame.BreakIt:Enable()
		rollFrame.BreakIt:SetAlpha(1)
	else
		rollFrame.BreakIt:SetAlpha(0.2)
		rollFrame.BreakIt:Disable()
	end
	SetDesaturation(rollFrame.NeedIt:GetNormalTexture(),not canNeed)
	SetDesaturation(rollFrame.WantIt:GetNormalTexture(),not canGreed)
	SetDesaturation(rollFrame.BreakIt:GetNormalTexture(),not canBreak)
	rollFrame.bindText:SetText(bindOnPickUp and "BoP" or "BoE")
	rollFrame.bindText:SetVertexColor(bindOnPickUp and 1 or 0.3, bindOnPickUp and 0.3 or 1, bindOnPickUp and 0.1 or 0.3)
	rollFrame.lootText:SetText(name)
	rollFrame.yourRoll:SetText("")
	rollFrame.status:SetStatusBarColor(color.r,color.g,color.b,0.7)
	rollFrame.status.bg:SetTexture(color.r,color.g,color.b)
	rollFrame.status:SetMinMaxValues(0,rollTime)
	rollFrame.status:SetValue(rollTime)
	rollFrame:SetPoint("CENTER",WorldFrame,"CENTER")
	rollFrame:Show()
	-- Gone in Legion. AlertFrame_FixAnchors()
	AutoGreed(rollID, quality, canBreak, bindOnPickUp)
end
EventFunc["LOOT_READY"] = function(autoLoot)
	local drops = GetNumLootItems()
	if drops > 0 then
		SVUI_LootFrame:Show()
	else
		CloseLoot(autoLoot == 0)
	end

	if IsFishingLoot() then
		SVUI_LootFrame.title:SetText(L["Fishy Loot"])
	elseif not UnitIsFriend("player", "target") and UnitIsDead"target" then
		SVUI_LootFrame.title:SetText(UnitName("target"))
	else
		SVUI_LootFrame.title:SetText(LOOT)
	end

	if GetCVar("lootUnderMouse") == "1" then
		local cursorX,cursorY = GetCursorPosition()
		cursorX = cursorX / SVUI_LootFrame:GetEffectiveScale()
		cursorY = (cursorY / (SVUI_LootFrame:GetEffectiveScale()));
		SVUI_LootFrame:ClearAllPoints()
		SVUI_LootFrame:SetPoint("TOPLEFT", nil, "BOTTOMLEFT", cursorX - 40, cursorY + 20)
		SVUI_LootFrame:GetCenter()
	else
		SVUI_LootFrame:ClearAllPoints()
		SVUI_LootFrame:SetPoint("TOPLEFT", SVUI_LootFrameHolder, "TOPLEFT")
	end

	SVUI_LootFrame:Raise()

	local iQuality, nameWidth, titleWidth = 0, 0, SVUI_LootFrame.title:GetStringWidth()
	UpdateLootUpvalues()
	if drops > 0 then
		for i = 1, drops do
			local slot = SVUI_LootFrame.slots[i] or MakeSlots(i)
			local textureID, item, quantity, _, quality, locked, isQuestItem, questId, isActive = GetLootSlotInfo(i)
			local color = ITEM_QUALITY_COLORS[quality]
			if quantity and quantity > 1 then
				slot.count:SetText(quantity)
				slot.count:Show()
			else
				slot.count:Hide()
			end
			if quality and quality > 1 then
				slot.drop:SetVertexColor(color.r, color.g, color.b)
				slot.drop:Show()
			else
				slot.drop:Hide()
			end
			slot.quality = quality;
			slot.name:SetText(item)
			if color then
				slot.name:SetTextColor(color.r, color.g, color.b)
			end
			slot.icon:SetTexture(textureID)
			if quality then
				iQuality = max(iQuality, quality)
			end
			nameWidth = max(nameWidth, slot.name:GetStringWidth())
			local qTex = slot.questTexture;
			if questId and not isActive then
				qTex:Show()
				ActionButton_ShowOverlayGlow(slot.iconFrame)
			elseif questId or isQuestItem then
				qTex:Hide()
				ActionButton_ShowOverlayGlow(slot.iconFrame)
			else
				qTex:Hide()
				ActionButton_HideOverlayGlow(slot.iconFrame)
			end
			slot:Enable()
			slot:Show()
			ConfirmLootSlot(i)
		end
	else
		local slot = SVUI_LootFrame.slots[1] or MakeSlots(1)
		local color = ITEM_QUALITY_COLORS[0]
		slot.name:SetText(L["Empty Slot"])
		if color then
			slot.name:SetTextColor(color.r, color.g, color.b)
		end
		slot.icon:SetTexture[[Interface\Icons\INV_Misc_Herb_AncientLichen]]
		drops = 1;
		nameWidth = max(nameWidth, slot.name:GetStringWidth())
		slot.count:Hide()
		slot.drop:Hide()
		slot:Disable()
		slot:Show()
	end

	HandleSlots(SVUI_LootFrame)
	nameWidth = nameWidth + 60;
	titleWidth = titleWidth + 5;
	local color = ITEM_QUALITY_COLORS[iQuality]
	SVUI_LootFrame:SetBackdropBorderColor(color.r, color.g, color.b, .8)
	SVUI_LootFrame:SetWidth(max(nameWidth, titleWidth))
end

local LootFrame_OnEvent = function(self, event, ...)
	if(EventFunc[event]) then
		EventFunc[event](...)
	end
end

_G.GroupLootDropDown_GiveLoot = function(self)
	if lastQuality >= MASTER_LOOT_THREHOLD then
		local confirmed = SV:StaticPopup_Show("CONFIRM_LOOT_DISTRIBUTION",ITEM_QUALITY_COLORS[lastQuality].hex..lastName..FONT_COLOR_CODE_CLOSE,self:GetText());
		if confirmed then confirmed.data = self.value end
	else
		GiveMasterLoot(lastID, self.value)
	end
	CloseDropDownMenus()
	SV.SystemAlert["CONFIRM_LOOT_DISTRIBUTION"].OnAccept = function(self,index) GiveMasterLoot(lastID,index) end
end
--[[
##########################################################
BAIL OUT BUTTON
##########################################################
]]--
local BailOut_TaxiTimer, BailOut_EarlyLandingRequested;
local SVUI_BailOut = CreateFrame("Button", "SVUI_BailOut", UIParent)
SVUI_BailOut:SetSize(50, 50)
SVUI_BailOut:SetPoint("TOP", SVUI_DockTopCenter, "BOTTOM", 0, -10)
-- JV - 20160923: This is showing sometimes when it shouldn't so make sure it's hidden by default
SVUI_BailOut:Hide()

local function UpdateTaxiBailOut()
	if(not UnitOnTaxi("player")) then
		SV.Timers:RemoveLoop(BailOut_TaxiTimer)
		BailOut_TaxiTimer = nil;
		BailOut_EarlyLandingRequested = nil;
		SVUI_BailOut:Hide()
	end
end

local BailOut_OnHook = function()
	SVUI_BailOut:Show()
	BailOut_TaxiTimer = SV.Timers:ExecuteLoop(UpdateMiniMapCoords, 1)
end

local BailOut_OnEvent = function(self, event, ...)
	if((event == "UNIT_ENTERED_VEHICLE" and CanExitVehicle()) or UnitControllingVehicle("player") or UnitInVehicle("player")) then
 		self:Show()
 	else
 		self:Hide()
 	end
end

local BailOut_OnClick = function(self, event, ...)
	if(UnitOnTaxi("player")) then
 		TaxiRequestEarlyLanding()
 		if(not BailOut_EarlyLandingRequested) then
 			BailOut_EarlyLandingRequested = true;
 			SV:CharacterMessage('Let me off at the next stop!')
 		end
 	else
 		VehicleExit()
 	end
end
--[[
##########################################################
MISC OVERRIDES
##########################################################
]]--
local SVUI_WorldStateHolder = CreateFrame("Frame", "SVUI_WorldStateHolder", UIParent)
SVUI_WorldStateHolder:SetPoint("TOP", SVUI_DockTopCenter, "BOTTOM", 0, -10)
SVUI_WorldStateHolder:SetSize(200, 45)

local SVUI_AltPowerBar = CreateFrame("Frame", "SVUI_AltPowerBar", UIParent)
SVUI_AltPowerBar:SetPoint("TOP", SVUI_DockTopCenter, "BOTTOM", 0, -60)
SVUI_AltPowerBar:SetSize(128, 50)

local PVPRaidNoticeHandler = function(self, event, msg)
	local _, instanceType = IsInInstance()
	if((instanceType == 'pvp') or (instanceType == 'arena')) then
		RaidNotice_AddMessage(RaidBossEmoteFrame, msg, ChatTypeInfo["RAID_BOSS_EMOTE"]);
	end
end

local CaptureBarHandler = function()
	local lastFrame = SVUI_WorldStateHolder
	local offset = "TOP";

	if(NUM_ALWAYS_UP_UI_FRAMES) then
		for i=1, NUM_ALWAYS_UP_UI_FRAMES do
			local frame = _G["AlwaysUpFrame"..i]
			if(frame and frame:IsVisible()) then
				frame:ClearAllPoints()
				frame:SetPoint("TOP", lastFrame, offset, 0, 0)
				lastFrame = frame
				offset = "BOTTOM";
			end
		end
	end

	if(NUM_EXTENDED_UI_FRAMES) then
		for i=1, NUM_EXTENDED_UI_FRAMES do
			local name = "WorldStateCaptureBar"..i;
			local frame = _G[name]
			if(frame and frame:IsVisible()) then
				if(_G[name .. "LeftBar"]) then _G[name .. "LeftBar"]:SetTexture("Interface\\AddOns\\SVUI_!Core\\assets\\textures\\WorldState-CaptureBar") end
				if(_G[name .. "RightBar"]) then _G[name .. "RightBar"]:SetTexture("Interface\\AddOns\\SVUI_!Core\\assets\\textures\\WorldState-CaptureBar") end
				if(_G[name .. "MiddleBar"]) then _G[name .. "MiddleBar"]:SetTexture("Interface\\AddOns\\SVUI_!Core\\assets\\textures\\WorldState-CaptureBar") end
				if(_G[name .. "LeftLine"]) then _G[name .. "LeftLine"]:SetTexture("Interface\\AddOns\\SVUI_!Core\\assets\\textures\\WorldState-CaptureBar") end
				if(_G[name .. "RightLine"]) then _G[name .. "RightLine"]:SetTexture("Interface\\AddOns\\SVUI_!Core\\assets\\textures\\WorldState-CaptureBar") end
				if(_G[name .. "LeftIconHighlight"]) then _G[name .. "LeftIconHighlight"]:SetTexture("Interface\\AddOns\\SVUI_!Core\\assets\\textures\\WorldState-CaptureBar") end
				if(_G[name .. "RightIconHighlight"]) then _G[name .. "RightIconHighlight"]:SetTexture("Interface\\AddOns\\SVUI_!Core\\assets\\textures\\WorldState-CaptureBar") end
				if(_G[name .. "IndicatorLeft"]) then _G[name .. "IndicatorLeft"]:SetTexture("Interface\\AddOns\\SVUI_!Core\\assets\\textures\\WorldState-CaptureBar") end
				if(_G[name .. "IndicatorRight"]) then _G[name .. "IndicatorRight"]:SetTexture("Interface\\AddOns\\SVUI_!Core\\assets\\textures\\WorldState-CaptureBar") end
				frame:ClearAllPoints()
				frame:SetPoint("TOP", lastFrame, offset, 0, 0)
				lastFrame = frame
				offset = "BOTTOM";
			end
		end
	end
end

local Vehicle_OnSetPoint = function(self, _, parent)
	if(parent == "MinimapCluster" or parent == _G["MinimapCluster"]) then
		VehicleSeatIndicator:ClearAllPoints()
		if _G.VehicleSeatIndicator_MOVE then
			VehicleSeatIndicator:SetPoint("BOTTOM", VehicleSeatIndicator_MOVE, "BOTTOM", 0, 0)
		else
			VehicleSeatIndicator:SetPoint("TOPLEFT", SV.Dock.TopLeft, "TOPLEFT", 0, 0)
			SV:NewAnchor(VehicleSeatIndicator, L["Vehicle Seat Frame"])
		end
		VehicleSeatIndicator:SetScale(0.8)
	end
end

local PlayerPowerBarAlt_OnClearAllPoints = function(self)
		self:SetPoint("CENTER", SVUI_AltPowerBar, "CENTER", 0, 0)
end

local Dura_OnSetPoint = function(self, _, parent)
	if(parent ~= Minimap) then
		self:ClearAllPoints()
		self:SetPoint("RIGHT", Minimap, "RIGHT")
		self:SetScale(0.6)
	end
end

local function AlterBlizzMainBar()
	if(not SV.ActionBars and MainMenuBar) then
		MainMenuBar:ClearAllPoints()
		MainMenuBar:SetPoint("BOTTOM", SV.Dock.BottomCenter, "TOP", 0, 4)
		if(MainMenuBarTexture0) then
			MainMenuBarTexture0:SetTexture("")
		end
		if(MainMenuBarTexture1) then
			MainMenuBarTexture1:SetTexture("")
		end
		if(MainMenuBarTexture2) then
			MainMenuBarTexture2:SetTexture("")
		end
		if(MainMenuBarTexture3) then
			MainMenuBarTexture3:SetTexture("")
		end
		if(MainMenuBarLeftEndCap) then
			MainMenuBarLeftEndCap:SetTexture("")
		end
		if(MainMenuBarRightEndCap) then
			MainMenuBarRightEndCap:SetTexture("")
		end
		if(MainMenuXPBar) then
			MainMenuXPBar:Die()
		end
		if(ReputationWatchBar) then
			ReputationWatchBar:Die()
		end
		-- if(MainMenuXPBarTextureLeftCap) then
		-- 	MainMenuXPBarTextureLeftCap:SetTexture("")
		-- end
		-- if(MainMenuXPBarTextureRightCap) then
		-- 	MainMenuXPBarTextureRightCap:SetTexture("")
		-- end
		-- if(MainMenuXPBarTextureMid) then
		-- 	MainMenuXPBarTextureMid:SetTexture("")
		-- end
		-- if(ReputationWatchBarTexture0) then
		-- 	ReputationWatchBarTexture0:SetTexture("")
		-- end
		-- if(ReputationWatchBarTexture1) then
		-- 	ReputationWatchBarTexture1:SetTexture("")
		-- end
		-- if(ReputationWatchBarTexture2) then
		-- 	ReputationWatchBarTexture2:SetTexture("")
		-- end
		-- if(ReputationWatchBarTexture3) then
		-- 	ReputationWatchBarTexture3:SetTexture("")
		-- end
		-- if(ReputationXPBarTexture0) then
		-- 	ReputationXPBarTexture0:SetTexture("")
		-- end
		-- if(ReputationXPBarTexture1) then
		-- 	ReputationXPBarTexture1:SetTexture("")
		-- end
		-- if(ReputationXPBarTexture2) then
		-- 	ReputationXPBarTexture2:SetTexture("")
		-- end
		-- if(ReputationXPBarTexture3) then
		-- 	ReputationXPBarTexture3:SetTexture("")
		-- end
	end
end
--[[
##########################################################
LOAD
##########################################################
]]--
local function UpdateLootingUpvalues()
	AUTOROLL_ENABLED = SV.db.Extras.autoRoll;
	AUTOROLL_SOULBOUND = SV.db.Extras.autoRollSoulbound;
	AUTOROLL_LEVEL = SV.db.Extras.autoRollMaxLevel;
	local dbQuality = SV.db.Extras.autoRollQuality;
	AUTOROLL_QUALITY = tonumber(dbQuality);
	if(type(AUTOROLL_QUALITY) ~= 'number') then
		AUTOROLL_QUALITY = 2;
	end
	AUTOROLL_DE = SV.db.Extras.autoRollDisenchant;
end

local function SetOverrides()
	if(CollectionsMicroButtonAlert) then
		CollectionsMicroButtonAlert:Die()
	end

	DurabilityFrame:SetFrameStrata("HIGH")
	NewHook(DurabilityFrame, "SetPoint", Dura_OnSetPoint)

	TicketStatusFrame:ClearAllPoints()
	TicketStatusFrame:SetPoint("TOPRIGHT", SV.Dock.TopLeft, "TOPRIGHT", 0, 0)
	-- SV:NewAnchor(TicketStatusFrame, L["GM Ticket Frame"], nil, nil, "GM")
	SV:NewAnchor(TicketStatusFrame, L["GM Ticket Frame"])

	HelpPlate:Die()
	HelpPlateTooltip:Die()
	HelpOpenTicketButtonTutorial:Die()
	HelpOpenTicketButton:SetParent(Minimap)
	HelpOpenTicketButton:ClearAllPoints()
	HelpOpenTicketButton:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT")

	NewHook(VehicleSeatIndicator, "SetPoint", Vehicle_OnSetPoint)
	-- May be taining MinimapCluster -- VehicleSeatIndicator:SetPoint("TOPLEFT", MinimapCluster, "TOPLEFT", 2, 2)

	SVUI_WorldStateHolder:SetSize(200, 45)
	SV:NewAnchor(SVUI_WorldStateHolder, L["Capture Bars"])
	NewHook("UIParent_ManageFramePositions", CaptureBarHandler)
	--WorldStateAlwaysUpFrame:ClearAllPoints()
	--WorldStateAlwaysUpFrame:SetPoint("TOP",SVUI_WorldStateHolder,"TOP",0,0)

	SVUI_AltPowerBar:SetSize(128, 50)
	PlayerPowerBarAlt:ClearAllPoints()
	PlayerPowerBarAlt:SetPoint("CENTER", SVUI_AltPowerBar, "CENTER", 0, 0)
	PlayerPowerBarAlt:SetParent(SVUI_AltPowerBar)
	PlayerPowerBarAlt.ignoreFramePositionManager = true;
	NewHook(PlayerPowerBarAlt, "ClearAllPoints", PlayerPowerBarAlt_OnClearAllPoints)
	SV:NewAnchor(SVUI_AltPowerBar, L["Alternative Power"])

	if(SVUI_Player) then
		SVUI_BailOut:ClearAllPoints()
		local size = SVUI_Player:GetHeight()
		SVUI_BailOut:SetSize(size, size)
		SVUI_BailOut:SetPoint("TOPLEFT", SVUI_Player, "TOPRIGHT", 4, 0)
		SVUI_BailOut:Hide()
	end
	SVUI_BailOut:SetNormalTexture(SV.media.icon.exitIcon)
	SVUI_BailOut:SetPushedTexture(SV.media.icon.exitIcon)
	SVUI_BailOut:SetHighlightTexture(SV.media.icon.exitIcon)
	SVUI_BailOut:SetStyle("!_Frame", "Transparent")
	SVUI_BailOut:RegisterForClicks("AnyUp")
	SVUI_BailOut:SetScript("OnClick", BailOut_OnClick)
	SVUI_BailOut:RegisterEvent("UNIT_ENTERED_VEHICLE")
 	SVUI_BailOut:RegisterEvent("UNIT_EXITED_VEHICLE")
 	SVUI_BailOut:RegisterEvent("VEHICLE_UPDATE")
 	--SVUI_BailOut:RegisterEvent("PLAYER_ENTERING_WORLD")
 	SVUI_BailOut:SetScript("OnEvent", BailOut_OnEvent)
 	NewHook("TakeTaxiNode", BailOut_OnHook)
	SV:NewAnchor(SVUI_BailOut, L["Bail Out"])
	SVUI_BailOut:Hide()

	LossOfControlFrame:ClearAllPoints()
	LossOfControlFrame:SetSize(75, 75)
	LossOfControlFrame:SetPoint("CENTER", SV.Screen, "CENTER", -146, -40)
	-- SV:NewAnchor(LossOfControlFrame, L["Loss Control Icon"], nil, nil, "LoC")
	SV:NewAnchor(LossOfControlFrame, L["Loss Control Icon"])

	SV:RegisterEvent("CHAT_MSG_BG_SYSTEM_HORDE", PVPRaidNoticeHandler)
	SV:RegisterEvent("CHAT_MSG_BG_SYSTEM_ALLIANCE", PVPRaidNoticeHandler)
	SV:RegisterEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL", PVPRaidNoticeHandler)

	UIParent:UnregisterEvent("MIRROR_TIMER_START")
	MirrorBarEventFrame:RegisterEvent("CVAR_UPDATE")
	MirrorBarEventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	MirrorBarEventFrame:RegisterEvent("MIRROR_TIMER_START")
	MirrorBarEventFrame:RegisterEvent("MIRROR_TIMER_STOP")
	MirrorBarEventFrame:RegisterEvent("MIRROR_TIMER_PAUSE")
	MirrorBarEventFrame:RegisterEvent("START_TIMER")
	MirrorBarEventFrame:SetScript("OnEvent", MirrorBar_OnEvent)

	if(SV.db.general.loot) then
		UIPARENT_MANAGED_FRAME_POSITIONS["GroupLootContainer"] = nil;
		LootFrame:UnregisterAllEvents();

		SVUI_LootFrameHolder:SetSize(150, 22);
		-- SV:NewAnchor(SVUI_LootFrameHolder, L["Loot Frame"], nil, nil, "SVUI_LootFrame");
		SV:NewAnchor(SVUI_LootFrameHolder, L["Loot Frame"]);

		SVUI_LootFrame:SetSize(256, 64);
		SVUI_LootFrame:SetStyle("!_Frame", 'Transparent');
		SVUI_LootFrame.title:SetFontObject(SVUI_Font_Header)
		SV:ManageVisibility(SVUI_LootFrame);
		SVUI_LootFrame:Hide();

		UIParent:UnregisterEvent("LOOT_BIND_CONFIRM")
		UIParent:UnregisterEvent("CONFIRM_DISENCHANT_ROLL")
		UIParent:UnregisterEvent("CONFIRM_LOOT_ROLL")

		LootingEventFrame:RegisterEvent("CONFIRM_DISENCHANT_ROLL")
		LootingEventFrame:RegisterEvent("CONFIRM_LOOT_ROLL")
		LootingEventFrame:RegisterEvent("LOOT_BIND_CONFIRM")
		LootingEventFrame:RegisterEvent("LOOT_READY")
		LootingEventFrame:RegisterEvent("LOOT_SLOT_CLEARED");
		LootingEventFrame:RegisterEvent("LOOT_CLOSED");
		LootingEventFrame:RegisterEvent("OPEN_MASTER_LOOT_LIST");
		LootingEventFrame:RegisterEvent("UPDATE_MASTER_LOOT_LIST");

		if SV.db.general.lootRoll then
			LootingEventFrame:RegisterEvent("LOOT_HISTORY_ROLL_CHANGED");
			LootingEventFrame:RegisterEvent("START_LOOT_ROLL");
			UIParent:UnregisterEvent("START_LOOT_ROLL");
			UIParent:UnregisterEvent("CANCEL_LOOT_ROLL");
			SV.Events:On("LOOTING_UPVALUES_UPDATED", UpdateLootingUpvalues, true);
			UpdateLootingUpvalues()
		end

		LootingEventFrame:SetScript("OnEvent", LootFrame_OnEvent);
	end

	ColorPickerFrame:SetFrameStrata("FULLSCREEN_DIALOG")
	ColorPickerFrame:SetBackdrop(SV.media.backdrop.darkened)
	ColorPickerFrame:SetFrameLevel(999)

	AlterBlizzMainBar()
end

SV:NewScript(SetOverrides)
