--[[
##########################################################
S V U I   By: Failcoder
##########################################################
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
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
local tostring          = _G.tostring;
local tonumber          = _G.tonumber;
local collectgarbage    = _G.collectgarbage;
local string        = _G.string;
local split         = string.split;
local upper         = string.upper;
local format        = string.format;
local find          = string.find;
local match         = string.match;
local gsub          = string.gsub;
local math 			= _G.math;
local min 			= math.min;
local cos, deg, rad, sin = math.cos, math.deg, math.rad, math.sin;
local random 		= math.random;
local wipe          = _G.wipe;
--BLIZZARD API
local CreateFrame           = _G.CreateFrame;
local InCombatLockdown      = _G.InCombatLockdown;
local GameTooltip           = _G.GameTooltip;
local ReloadUI              = _G.ReloadUI;
local hooksecurefunc        = _G.hooksecurefunc;
local IsAltKeyDown          = _G.IsAltKeyDown;
local IsShiftKeyDown        = _G.IsShiftKeyDown;
local IsControlKeyDown      = _G.IsControlKeyDown;
local IsModifiedClick       = _G.IsModifiedClick;
local PlaySound             = _G.PlaySound;
local PlaySoundFile         = _G.PlaySoundFile;
local PlayMusic             = _G.PlayMusic;
local StopMusic             = _G.StopMusic;
local ToggleFrame           = _G.ToggleFrame;
local ERR_NOT_IN_COMBAT     = _G.ERR_NOT_IN_COMBAT;
local RAID_CLASS_COLORS     = _G.RAID_CLASS_COLORS;
local CUSTOM_CLASS_COLORS   = _G.CUSTOM_CLASS_COLORS;
local SendChatMessage       = _G.SendChatMessage;
local GetSpellLink          = _G.GetSpellLink;
local UnitName              = _G.UnitName;
local UnitClass             = _G.UnitClass;
local UnitIsPlayer          = _G.UnitIsPlayer;
local UnitReaction          = _G.UnitReaction;
local UnitExists            = _G.UnitExists;
local UnitIsUnit            = _G.UnitIsUnit;
local UnitInRaid            = _G.UnitInRaid;
local UnitInParty           = _G.UnitInParty;
local UnitGUID              = _G.UnitGUID;
local UnitIsDead            = _G.UnitIsDead;
local UnitIsGroupLeader     = _G.UnitIsGroupLeader;
local UnitIsGroupAssistant  = _G.UnitIsGroupAssistant;
local IsEveryoneAssistant   = _G.IsEveryoneAssistant;
local GetItemInfo           = _G.GetItemInfo;
local BuyMerchantItem       = _G.BuyMerchantItem;
local GetMerchantItemLink   = _G.GetMerchantItemLink;
local GetMerchantItemMaxStack     = _G.GetMerchantItemMaxStack;
local UnitDetailedThreatSituation = _G.UnitDetailedThreatSituation;
--[[
##########################################################
GET ADDON DATA
##########################################################
]]--
local SV = select(2, ...);
local L = SV.L;
--[[
##########################################################
LOCALS
##########################################################
]]--
local PlayerName = UnitName("player");
local ThreatMeter = _G["SVUI_ThreatOMeter"];

--[[ LOCALS ]]--
local BARFILE = [[Interface\AddOns\SVUI_!Core\assets\textures\Doodads\THREAT-BAR]];
local TEXTUREFILE = [[Interface\AddOns\SVUI_!Core\assets\textures\Doodads\THREAT-BAR-ELEMENTS]];
local REACTION_COLORS = {
	[1] = {0.92, 0.15, 0.15},
	[2] = {0.92, 0.15, 0.15},
	[3] = {0.92, 0.15, 0.15},
	[4] = {0.85, 0.85, 0.13},
	[5] = {0.19, 0.85, 0.13},
	[6] = {0.19, 0.85, 0.13},
	[7] = {0.19, 0.85, 0.13},
	[8] = {0.19, 0.85, 0.13},
};
local Reactions = {
	Woot = {
		[29166] = true, [20484] = true, [61999] = true,
		[20707] = true, [50769] = true, [2006] = true,
		[7328] = true, [2008] = true, [115178] = true,
		[110478] = true, [110479] = true, [110482] = true,
		[110483] = true, [110484] = true, [110485] = true,
		[110486] = true, [110488] = true, [110490] = true,
		[110491] = true
	},
	LookWhatICanDo = {
		34477, 19801, 57934, 633, 20484, 113269, 61999,
		20707, 2908, 120668, 16190, 64901, 108968
	},
	Toys = {
		[61031] = true, [49844] = true
	},
	Bots = {
		[22700] = true, [44389] = true, [54711] = true,
		[67826] = true, [126459] = true
	},
	Portals = {
		[10059] = true, [11416] = true, [11419] = true,
		[32266] = true, [49360] = true, [33691] = true,
		[88345] = true, [132620] = true, [11417] = true,
		[11420] = true, [11418] = true, [32267] = true,
		[49361] = true, [35717] = true, [88346] = true,
		[132626] = true, [53142] = true
	},
	StupidHat = {
		[1] = {88710, 33820, 19972, 46349, 92738},
		[2] = {32757},
		[8] = {50287, 19969},
		[15] = {65360, 65274},
		[16] = {44050, 19970, 84660, 84661, 45992, 86559, 45991},
		[17] = {86558}
	}
};
local SAPPED_MESSAGE = {
	"Oh Hell No ... {rt8}SAPPED{rt8}",
	"{rt8}SAPPED{rt8} ...Someone's about to get slapped!",
	"Mother Fu... {rt8}SAPPED{rt8}",
	"{rt8}SAPPED{rt8} ...How cute",
	"{rt8}SAPPED{rt8} ...Ain't Nobody Got Time For That!",
	"Uh-Oh... {rt8}SAPPED{rt8}"
};
local ReactionEmotes = {
	"SALUTE",
	"THANK",
	"DRINK"
};
local REACTION_INTERRUPT, REACTION_WOOT, REACTION_LOOKY, REACTION_SHARE, REACTION_EMOTE, REACTION_CHAT = false, false, false, false, false, false;

local MsgTest = function(warning)
	if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
		return "INSTANCE_CHAT"
	elseif IsInRaid(LE_PARTY_CATEGORY_HOME) then
		if warning and (UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") or IsEveryoneAssistant()) then
			return "RAID_WARNING"
		else
			return "RAID"
		end
	elseif IsInGroup(LE_PARTY_CATEGORY_HOME) then
		return "PARTY"
	end
	return "SAY"
end
--[[
##########################################################
MERCHANT MAX STACK
##########################################################
]]--
local BuyMaxStack = function(self, ...)
	if ( IsAltKeyDown() ) then
		local index = self:GetID()
		local itemLink = GetMerchantItemLink(index)
		if not itemLink then return end
		local price = select(3, GetMerchantItemInfo(index))
		local maxStack = select(8, GetItemInfo(itemLink))
		local currencyCount = GetMerchantItemCostInfo(index)
		if ( maxStack and maxStack > 1 ) then
			local maxAllowed = GetMerchantItemMaxStack(index);
			if(currencyCount == 0) then
				local canAfford = GetMoney() / maxStack;
				BuyMerchantItem(index, min(maxAllowed,canAfford));
			else
				BuyMerchantItem(index, maxAllowed);
			end
		end
	end
end

local MaxStackTooltip = function(self)
	if(not GameTooltip.InjectedDouble) then
		GameTooltip.InjectedDouble = {}
	else
		wipe(GameTooltip.InjectedDouble)
	end
	local itemLink = GetMerchantItemLink(self:GetID())
	if not itemLink then return end
	local maxStack = select(8, GetItemInfo(itemLink))
	if((not maxStack) or (maxStack < 2)) then return end
    GameTooltip.InjectedDouble[1] = "[Alt + Click]"
    GameTooltip.InjectedDouble[2] = "Buy a full stack."
    GameTooltip.InjectedDouble[3] = 0
    GameTooltip.InjectedDouble[4] = 0.5
    GameTooltip.InjectedDouble[5] = 1
    GameTooltip.InjectedDouble[6] = 0.5
    GameTooltip.InjectedDouble[7] = 1
    GameTooltip.InjectedDouble[8] = 0.5
end
--[[
##########################################################
RAIDMARKERS
##########################################################
]]--
local RaidMarkFrame = _G["SVUI_RaidMarkFrame"];
RaidMarkFrame.Active = false;

do
	RaidMarkFrame:EnableMouse(true)
	RaidMarkFrame:SetSize(100, 100)
	RaidMarkFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	RaidMarkFrame:SetFrameStrata("DIALOG")

	local RaidMarkButton_OnEnter = function(self)
		self.Texture:ClearAllPoints()
		self.Texture:SetPoint("TOPLEFT",-10,10)
		self.Texture:SetPoint("BOTTOMRIGHT",10,-10)
	end

	local RaidMarkButton_OnLeave = function(self)
		self.Texture:SetAllPoints()
	end

	local RaidMarkButton_OnClick = function(self, button)
		PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
		SetRaidTarget("target", button ~= "RightButton" and self:GetID() or 0)
		self:GetParent():FadeOut(0.2, 1, 0, true)
	end

	for i=1,8 do
		local mark = CreateFrame("Button", "RaidMarkIconButton"..i, RaidMarkFrame)
		mark:SetSize(40, 40)
		mark:SetID(i)
		mark.Texture = mark:CreateTexture(mark:GetName().."NormalTexture", "ARTWORK")
		mark.Texture:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
		mark.Texture:SetAllPoints()
		SetRaidTargetIconTexture(mark.Texture, i)
		mark:RegisterForClicks("LeftbuttonUp", "RightbuttonUp")
		mark:SetScript("OnClick", RaidMarkButton_OnClick)
		mark:SetScript("OnEnter", RaidMarkButton_OnEnter)
		mark:SetScript("OnLeave", RaidMarkButton_OnLeave)
		if(i == 8) then
			mark:SetPoint("CENTER")
		else
			local radian = 360 / 7 * i;
			mark:SetPoint("CENTER", sin(radian) * 60, cos(radian) * 60)
		end
	end
end

function RaidMarkFrame:IsAllowed(button)
	if(button and button == "down") then
		if GetNumGroupMembers()>0 then
			if UnitIsGroupLeader('player') or UnitIsGroupAssistant("player") then
				self.Active = true
			elseif IsInGroup() and not IsInRaid() then
				self.Active = true
			else
				UIErrorsFrame:AddMessage(L["You don't have permission to mark targets."], 1.0, 0.1, 0.1, 1.0, UIERRORS_HOLD_TIME)
				self.Active = false
			end
		else
			self.Active = true
		end
	else
		self.Active = false
	end
end

function RaidMarkFrame:Toggle(button)
	local canFade = false;
	if(button) then
		canFade = true;
		self:IsAllowed(button)
	end
	if(self.Active) then
		if not UnitExists("target") or UnitIsDead("target") then return end
		local x,y = GetCursorPosition()
		local scale = SV.Screen:GetEffectiveScale()
		self:SetPoint("CENTER", SV.Screen, "BOTTOMLEFT", (x / scale), (y / scale))
		self:FadeIn()
	elseif(canFade) then
		self:FadeOut(0.2, 1, 0, true)
	end
end

local RaidMarkFrame_OnEvent = function(self, event)
	self:Toggle();
end

_G.RaidMark_HotkeyPressed = function(button)
	RaidMarkFrame:Toggle(button)
end
--[[
##########################################################
DRESSUP HELPERS by: Leatrix
##########################################################
]]--
local CreateCharacterToggles;
do
	local HelmetToggle;
	local CloakToggle;
	local DressUpdateTimer = 0;
	local HShowing, CShowing, HChecked, CChecked


	local function LockItem(item, lock)
		if lock then
			item:Disable()
			item:SetAlpha(0.3)
		else
			item:Enable()
			item:SetAlpha(1.0)
		end
	end

	local function SetVanityPlacement()
		HelmetToggle:ClearAllPoints();
		HelmetToggle:SetPoint("TOPLEFT", 166, -326)
		HelmetToggle:SetHitRectInsets(0, -10, 0, 0);
		HelmetToggle.text:SetText("H");
		HelmetToggle:SetAlpha(0.7);

		CloakToggle:ClearAllPoints();
		CloakToggle:SetPoint("TOPLEFT", 206, -326)
		CloakToggle:SetHitRectInsets(0, -10, 0, 0);
		CloakToggle.text:SetText("C");
		CloakToggle:SetAlpha(0.7);
	end

	local MouseEventHandler = function(self, btn)
		if btn == "RightButton" and IsShiftKeyDown() then
			SetVanityPlacement();
		end
	end

	local DressUpdateHandler = function(self, elapsed)
		DressUpdateTimer = DressUpdateTimer + elapsed;
		while (DressUpdateTimer > 0.05) do
			if UnitIsDeadOrGhost("player") then
				LockItem(HelmetToggle,true)
				LockItem(CloakToggle,true)
				return
			else
				LockItem(HelmetToggle,false)
				LockItem(CloakToggle,false)
			end

			--[[
			HShowing = ShowingHelm()
			CShowing = ShowingCloak()
			HChecked = HelmetToggle:GetChecked()
			CChecked = CloakToggle:GetChecked()

			if(HChecked ~= HShowing) then
				if HelmetToggle:IsEnabled() then
					HelmetToggle:Disable()
				end
			else
				if not HelmetToggle:IsEnabled() then
					HelmetToggle:Enable()
				end
			end

			if(CChecked ~= CShowing) then
				if CloakToggle:IsEnabled() then
					CloakToggle:Disable()
				end
			else
				if not CloakToggle:IsEnabled() then
					CloakToggle:Enable()
				end
			end

			HelmetToggle:SetChecked(HShowing);
			CloakToggle:SetChecked(CShowing);
			]]--
			DressUpdateTimer = 0;
		end
	end

	local DressUp_OnEnter = function(self)
		if InCombatLockdown() then return end
		GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 4)
		GameTooltip:ClearLines()
		GameTooltip:AddLine(self.TText, 1, 1, 1)
		GameTooltip:Show()
	end

	local DressUp_OnLeave = function(self)
		if InCombatLockdown() then return end
		if(GameTooltip:IsShown()) then GameTooltip:Hide() end
	end

	local Button_OnEnter = function(self, ...)
	    if InCombatLockdown() then return end
	    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 4)
	    GameTooltip:ClearLines()
	    GameTooltip:AddLine(self.TText, 1, 1, 1)
	    GameTooltip:Show()
	end

	local function CreateSimpleButton(frame, label, anchor, x, y, width, height, tooltip)
	    local button = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	    button:SetWidth(width)
	    button:SetHeight(height)
	    button:SetPoint(anchor, x, y)
	    button:SetText(label)
	    button:RegisterForClicks("AnyUp")
	    button:SetHitRectInsets(0, 0, 0, 0);
	    button:SetFrameStrata("FULLSCREEN_DIALOG");
	    button.TText = tooltip
	    button:SetStyle("Button")
	    button:SetScript("OnEnter", Button_OnEnter)
	    button:SetScript("OnLeave", GameTooltip_Hide)
	    return button
	end

	function CreateCharacterToggles()
		local BtnStrata = SideDressUpModelResetButton:GetFrameStrata();
		local BtnLevel = SideDressUpModelResetButton:GetFrameLevel();

		local tabard1 = CreateSimpleButton(DressUpFrame, "Tabard", "BOTTOMLEFT", 12, 12, 80, 22, "")
		tabard1:SetScript("OnClick", function()
			DressUpModel:UndressSlot(19)
		end)

		local tabard2 = CreateSimpleButton(SideDressUpFrame, "Tabard", "BOTTOMLEFT", 14, 20, 60, 22, "")
		tabard2:SetFrameStrata(BtnStrata);
		tabard2:SetFrameLevel(BtnLevel);
		tabard2:SetScript("OnClick", function()
			SideDressUpModel:UndressSlot(19)
		end)

		local nude1 = CreateSimpleButton(DressUpFrame, "Nude", "BOTTOMLEFT", 104, 12, 80, 22, "")
		nude1:SetScript("OnClick", function()
			DressUpFrameResetButton:Click()
			for i = 1, 19 do
				DressUpModel:UndressSlot(i)
			end
		end)

		local nude2 = CreateSimpleButton(SideDressUpFrame, "Nude", "BOTTOMRIGHT", -18, 20, 60, 22, "")
		nude2:SetFrameStrata(BtnStrata);
		nude2:SetFrameLevel(BtnLevel);
		nude2:SetScript("OnClick", function()
			SideDressUpModelResetButton:Click()
			for i = 1, 19 do
				SideDressUpModel:UndressSlot(i)
			end
		end)

		--[[
		HelmetToggle = CreateFrame('CheckButton', nil, CharacterModelFrame, "OptionsCheckButtonTemplate")
		HelmetToggle:SetSize(16, 16)
		HelmetToggle:SetStyle("Checkbox")
		HelmetToggle.text = HelmetToggle:CreateFontString(nil, 'OVERLAY', "GameFontNormal")
		HelmetToggle.text:SetPoint("LEFT", 24, 0)
		HelmetToggle.TText = "Show/Hide Helmet"
		HelmetToggle:SetScript('OnEnter', DressUp_OnEnter)
		HelmetToggle:SetScript('OnLeave', DressUp_OnLeave)
		HelmetToggle:SetScript('OnUpdate', DressUpdateHandler)

		CloakToggle = CreateFrame('CheckButton', nil, CharacterModelFrame, "OptionsCheckButtonTemplate")
		CloakToggle:SetSize(16, 16)
		CloakToggle:SetStyle("Checkbox")
		CloakToggle.text = CloakToggle:CreateFontString(nil, 'OVERLAY', "GameFontNormal")
		CloakToggle.text:SetPoint("LEFT", 24, 0)
		CloakToggle.TText = "Show/Hide Cloak"
		CloakToggle:SetScript('OnEnter', DressUp_OnEnter)
		CloakToggle:SetScript('OnLeave', DressUp_OnLeave)

		HelmetToggle:SetScript('OnClick', function(self, btn)
			ShowHelm(HelmetToggle:GetChecked())
		end)
		CloakToggle:SetScript('OnClick', function(self, btn)
			ShowCloak(CloakToggle:GetChecked())
		end)

		HelmetToggle:SetScript('OnMouseDown', MouseEventHandler)
		CloakToggle:SetScript('OnMouseDown', MouseEventHandler)
		
		CharacterModelFrame:HookScript("OnShow", SetVanityPlacement)
		]]--
	end
end
--[[
##########################################################
VARIOUS COMBAT REACTIONS
##########################################################
]]--
local ReactionListener = CreateFrame("Frame")

local function Thanks_Emote(sourceName)
	if not REACTION_EMOTE then return end
	local index = random(1,#ReactionEmotes)
	DoEmote(ReactionEmotes[index], sourceName)
end

local function StupidHatEventHandler()
	if(not IsInInstance()) then return end
	local item = {}
	for i = 1, 17 do
		if Reactions.StupidHat[i] ~= nil then
			item[i] = GetInventoryItemID("player", i) or 0
			for j, baditem in pairs(Reactions.StupidHat[i]) do
				if item[i] == baditem then
					PlaySound(SOUNDKIT.RAID_WARNING)
					RaidNotice_AddMessage(RaidWarningFrame, format("%s %s", CURRENTLY_EQUIPPED, GetItemInfo(item[i]).."!!!"), ChatTypeInfo["RAID_WARNING"])
					print(format("|cffff3300%s %s", CURRENTLY_EQUIPPED, GetItemInfo(item[i]).."!!!|r"))
				end
			end
		end
	end
end

local function ChatLogEventHandler(...)
	local _, subEvent, _, sourceGUID, sourceName, _, _, destGUID, destName, _, _, spellID, _, _, otherSpellID = ...

	if not sourceName then return end

	if(REACTION_INTERRUPT) then
		if ((spellID == 6770) and (destName == PlayerName) and (subEvent == "SPELL_AURA_APPLIED" or subEvent == "SPELL_AURA_REFRESH")) then
			local msg = SAPPED_MESSAGE[random(1,6)]
			SendChatMessage(msg, "SAY")
			SV:AddonMessage("Sapped by: "..sourceName)
			DoEmote("CRACK", sourceName)
		elseif(subEvent == "SPELL_INTERRUPT" and sourceGUID == UnitGUID("player") and IsInGroup()) then
			SendChatMessage(INTERRUPTED.." "..destName..": "..GetSpellLink(otherSpellID), MsgTest())
		end
	end

	if(REACTION_WOOT) then
		for key, value in pairs(Reactions.Woot) do
			if spellID == key and value == true and destName == PlayerName and sourceName ~= PlayerName and (subEvent == "SPELL_AURA_APPLIED" or subEvent == "SPELL_CAST_SUCCESS") then
				Thanks_Emote(sourceName)
				--SendChatMessage(L["Thanks for "]..GetSpellLink(spellID)..", "..sourceName, "WHISPER", nil, sourceName)
				print(GetSpellLink(spellID)..L[" received from "]..sourceName)
			end
		end
	end

	if(REACTION_LOOKY) then
		local outbound;
		local spells = Reactions.LookWhatICanDo
		local _, _, difficultyID = GetInstanceInfo()

		if(difficultyID ~= 0 and subEvent == "SPELL_CAST_SUCCESS") then
			if(not (sourceGUID == UnitGUID("player") and sourceName == PlayerName)) then
				for i, spells in pairs(spells) do
					if(spellID == spells) then
						if(destName == nil) then
							outbound = (L["%s used a %s."]):format(sourceName, GetSpellLink(spellID))
						else
							outbound = (L["%s used a %s."]):format(sourceName, GetSpellLink(spellID).." -> "..destName)
						end
						if(REACTION_CHAT) then
							SendChatMessage(outbound, MsgTest())
						else
							print(outbound)
						end
					end
				end
			else
				if(not (sourceGUID == UnitGUID("player") and sourceName == PlayerName)) then return end
				for i, spells in pairs(spells) do
					if(spellID == spells) then
						if(destName == nil) then
							outbound = (L["%s used a %s."]):format(sourceName, GetSpellLink(spellID))
						else
							outbound = GetSpellLink(spellID).." -> "..destName
						end
						if(REACTION_CHAT) then
							SendChatMessage(outbound, MsgTest())
						else
							print(outbound)
						end
					end
				end
			end
		end
	end

	if(REACTION_SHARE) then
		if not IsInGroup() or InCombatLockdown() or not subEvent or not spellID then return end
		if not UnitInRaid(sourceName) and not UnitInParty(sourceName) then return end

		local sourceName = format(sourceName:gsub("%-[^|]+", ""))
		if(not sourceName) then return end
		local thanks = false
		local outbound
		if subEvent == "SPELL_CAST_SUCCESS" then
			-- Feasts
			if (spellID == 126492 or spellID == 126494) then
				outbound = (L["%s has prepared a %s - [%s]."]):format(sourceName, GetSpellLink(spellID), SPELL_STAT1_NAME)
			elseif (spellID == 126495 or spellID == 126496) then
				outbound = (L["%s has prepared a %s - [%s]."]):format(sourceName, GetSpellLink(spellID), SPELL_STAT2_NAME)
			elseif (spellID == 126501 or spellID == 126502) then
				outbound = (L["%s has prepared a %s - [%s]."]):format(sourceName, GetSpellLink(spellID), SPELL_STAT3_NAME)
			elseif (spellID == 126497 or spellID == 126498) then
				outbound = (L["%s has prepared a %s - [%s]."]):format(sourceName, GetSpellLink(spellID), SPELL_STAT4_NAME)
			elseif (spellID == 126499 or spellID == 126500) then
				outbound = (L["%s has prepared a %s - [%s]."]):format(sourceName, GetSpellLink(spellID), SPELL_STAT5_NAME)
			elseif (spellID == 104958 or spellID == 105193 or spellID == 126503 or spellID == 126504 or spellID == 145166 or spellID == 145169 or spellID == 145196) then
				outbound = (L["%s has prepared a %s."]):format(sourceName, GetSpellLink(spellID))
			-- Refreshment Table
			elseif spellID == 43987 then
				outbound = (L["%s has prepared a %s."]):format(sourceName, GetSpellLink(spellID))
			-- Ritual of Summoning
			elseif spellID == 698 then
				outbound = (L["%s is casting %s. Click!"]):format(sourceName, GetSpellLink(spellID))
			-- Piccolo of the Flaming Fire
			elseif spellID == 18400 then
				outbound = (L["%s used a %s."]):format(sourceName, GetSpellLink(spellID))
			end
			if(outbound) then thanks = true end
		elseif subEvent == "SPELL_SUMMON" then
			-- Repair Bots
			if Reactions.Bots[spellID] then
				outbound = (L["%s has put down a %s."]):format(sourceName, GetSpellLink(spellID))
				thanks = true
			end
		elseif subEvent == "SPELL_CREATE" then
			-- Ritual of Souls and MOLL-E
			if (spellID == 29893 or spellID == 54710) then
				outbound = (L["%s has put down a %s."]):format(sourceName, GetSpellLink(spellID))
				thanks = true
			-- Toys
			elseif Reactions.Toys[spellID] then
				outbound = (L["%s has put down a %s."]):format(sourceName, GetSpellLink(spellID))
			-- Portals
			elseif Reactions.Portals[spellID] then
				outbound = (L["%s is casting %s."]):format(sourceName, GetSpellLink(spellID))
			end
		elseif subEvent == "SPELL_AURA_APPLIED" then
			-- Turkey Feathers and Party G.R.E.N.A.D.E.
			if (spellID == 61781 or ((spellID == 51508 or spellID == 51510) and destName == PlayerName)) then
				outbound = (L["%s used a %s."]):format(sourceName, GetSpellLink(spellID))
			end
		end

		if(outbound) then
			if(REACTION_CHAT) then
				SendChatMessage(outbound, MsgTest(true))
			else
				print(outbound)
			end
			if(thanks and sourceName) then
				Thanks_Emote(sourceName)
			end
		end
	end
end

local ReactionListener_OnEvent = function(self, event, ...)
	if(event == "ZONE_CHANGED_NEW_AREA") then
		StupidHatEventHandler()
	elseif(event == "COMBAT_LOG_EVENT_UNFILTERED") then
		ChatLogEventHandler(...)
	end
end

function SV:ToggleReactions()
	local settings = SV.db.Extras

	REACTION_INTERRUPT = settings.pvpinterrupt
	REACTION_WOOT = settings.woot
	REACTION_LOOKY = settings.lookwhaticando
	REACTION_SHARE = settings.sharingiscaring
	REACTION_EMOTE = settings.reactionEmote
	REACTION_CHAT = settings.reactionChat

	if(settings.stupidhat) then
		ReactionListener:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	else
		ReactionListener:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
	end

	if(not REACTION_SHARE) and (not REACTION_INTERRUPT) and (not REACTION_WOOT) and (not REACTION_LOOKY) then
		ReactionListener:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	else
		ReactionListener:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	end
end

--[[ HELPER ]]--
local function GetThreatBarColor(highest)
	local unitReaction = UnitReaction(highest, 'player');
	local r, g, b = 0.5, 0.5, 0.5;

	if(UnitIsPlayer(highest)) then
		local _,token = UnitClass(highest);
		local colors = RAID_CLASS_COLORS[token];
		if(colors) then
			r, g, b = colors.r*255, colors.g*255, colors.b*255
		end
	elseif(unitReaction) then
		local colors = REACTION_COLORS[unitReaction];
		if(colors) then
			r, g, b = colors[1], colors[2], colors[3]
		end
	end

	return r, g, b
end

--[[ HANDLER ]]--
local ThreatBar_OnEvent = function(self, event)
	local isTanking, status, scaledPercent = UnitDetailedThreatSituation('player', 'target')
	if(scaledPercent and (scaledPercent > 0)) then
		-- if SVUI is installed then fade instead of show
		if(self.FadeIn) then
			self:FadeIn()
		else
			self:Show()
		end

		local r,g,b = 0,0.9,0;
		local peak = 0;
		local unitKey, highest;

		if(UnitExists('pet')) then
			local threat = select(3, UnitDetailedThreatSituation('pet', 'target'))
			if(threat and threat > peak) then
				peak = threat;
				highest = 'pet';
			end
		end

		if(IsInRaid()) then
			for i=1,40 do
				unitKey = 'raid'..i;
				if(UnitExists(unitKey) and not UnitIsUnit(unitKey, 'player')) then
					local threat = select(3, UnitDetailedThreatSituation(unitKey, 'target'))
					if(threat and threat > peak) then
						peak = threat;
						highest = 'pet';
					end
				end
			end
		elseif(IsInGroup()) then
			for i=1,4 do
				unitKey = 'party'..i;
				if(UnitExists(unitKey)) then
					local threat = select(3, UnitDetailedThreatSituation(unitKey, 'target'))
					if(threat and threat > peak) then
						peak = threat;
						highest = 'pet';
					end
				end
			end
		end

		if(highest) then
			if(isTanking or (scaledPercent == 100)) then
				peak = (scaledPercent - peak);
				if(peak > 0) then
					scaledPercent = peak;
				end
			else
				r,g,b = GetThreatBarColor(highest)
			end
		elseif(status) then
			r,g,b = GetThreatStatusColor(status);
		end

		self:SetStatusBarColor(r,g,b)
		self:SetValue(scaledPercent)
		self.text:SetFormattedText('%.0f%%', scaledPercent)
	else
		-- if SVUI is installed then fade instead of hide
		if(self.FadeOut) then
			self:FadeOut(0.2, 1, 0, true)
		else
			self:Hide()
		end
	end
end
--[[
##########################################################
LOAD BY TRIGGER
##########################################################
]]--
local function InitializeMisc()
	hooksecurefunc("MerchantItemButton_OnEnter", MaxStackTooltip);
	hooksecurefunc("MerchantItemButton_OnModifiedClick", BuyMaxStack);

	RaidMarkFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
	RaidMarkFrame:SetScript("OnEvent", RaidMarkFrame_OnEvent)

	if(not IsAddOnLoaded("DressingRoomFunctions")) then
		CreateCharacterToggles()
	end

	SV:ToggleReactions()
	ReactionListener:SetScript("OnEvent", ReactionListener_OnEvent)

	if(SV.db.Extras.threatbar) then
		ThreatMeter:SetParent(SV.Screen)
		ThreatMeter:SetPoint('CENTER', UIParent, 'CENTER', 150, -150)
		ThreatMeter:SetSize(50, 100)
		ThreatMeter:SetStatusBarTexture(BARFILE)
		ThreatMeter:SetFrameStrata('MEDIUM')
		ThreatMeter:SetOrientation("VERTICAL")
		ThreatMeter:SetMinMaxValues(0, 100)

		ThreatMeter.backdrop = ThreatMeter:CreateTexture(nil,"BACKGROUND")
		ThreatMeter.backdrop:SetAllPoints(ThreatMeter)
		ThreatMeter.backdrop:SetTexture(TEXTUREFILE)
		ThreatMeter.backdrop:SetTexCoord(0.5,0.75,0,0.5)
		ThreatMeter.backdrop:SetBlendMode("ADD")

		ThreatMeter.overlay = ThreatMeter:CreateTexture(nil,"OVERLAY",nil,1)
		ThreatMeter.overlay:SetAllPoints(ThreatMeter)
		ThreatMeter.overlay:SetTexture(TEXTUREFILE)
		ThreatMeter.overlay:SetTexCoord(0.75,1,0,0.5)

		ThreatMeter.text = ThreatMeter:CreateFontString(nil, 'OVERLAY')
		ThreatMeter.text:SetFontObject(NumberFontNormal)
		ThreatMeter.text:SetPoint('TOP',ThreatMeter,'BOTTOM',0,0)

		ThreatMeter:RegisterEvent('PLAYER_TARGET_CHANGED');
		ThreatMeter:RegisterEvent('UNIT_THREAT_LIST_UPDATE');
		ThreatMeter:RegisterEvent('GROUP_ROSTER_UPDATE');
		ThreatMeter:RegisterEvent('UNIT_PET');
		ThreatMeter:SetScript("OnEvent", ThreatBar_OnEvent);
		SV:NewAnchor(ThreatMeter, L["Threat-O-Meter"])
	end

	local cfg = CreateFrame("Button", "GameMenuButtonSVUI", GameMenuFrame, "GameMenuButtonTemplate")
	cfg:SetSize(GameMenuButtonHelp:GetWidth(), GameMenuButtonHelp:GetHeight())
	cfg:SetPoint(GameMenuButtonHelp:GetPoint())
	cfg:SetScript("OnClick", function() SV:ToggleConfig() HideUIPanel(GameMenuFrame) end)
	cfg:SetText("|cffFF9900SuperVillain UI|r")
	GameMenuFrame:HookScript("OnShow", function()
		GameMenuFrame:SetHeight(GameMenuFrame:GetHeight() + GameMenuButtonHelp:GetHeight() + 10)
	end)
	GameMenuButtonHelp:ClearAllPoints()
	GameMenuButtonHelp:SetPoint("TOP", cfg, "BOTTOM", 0, -11)
end

SV.Events:On("CORE_INITIALIZED", InitializeMisc);
--[[
##########################################################
DIRTY DEEDS
##########################################################
]]--
LFRParentFrame:SetScript("OnHide", nil)
