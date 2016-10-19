--[[
##############################################################################
S V U I   By: Failcoder
##############################################################################
]]--
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
local InboxFrame_OnClick 		= _G.InboxFrame_OnClick;

local SV = select(2, ...);
local L = SV.L;

local MailMinion 				= _G["SVUI_MailMinion"];
local MailMinionGetMail = _G["SVUI_MailMinionGetMail"];
local MailMinionGetGold = _G["SVUI_MailMinionGetGold"];
local MailMinionDelete 	= _G["SVUI_MailMinionDelete"];
--[[
##########################################################
LOCAL VARS
##########################################################
]]--
local StartMailMinion, StopMailMinion
local takingOnlyCash = false;
local lastopened, lastdeleted = 0, 0;
local mailElapsed, deleteElapsed, deletedelay = 0, 0, 0.5;
local GetAllMail, GetAllMailCash, WaitForMail, DeleteAllMail, DeleteMailItem, WaitForDelete;
local needsToWait, waitToDelete, total_cash, baseInboxFrame_OnClick;
local dummy = function() return end;
--[[
##########################################################
LOCAL FUNCTIONS
##########################################################
]]--
local function FancifyMoneys(cash)
	if cash > 10000 then
		return("%d|cffffd700g|r%d|cffc7c7cfs|r%d|cffeda55fc|r"):format((cash / 10000), ((cash / 100) % 100), (cash % 100))
	elseif cash > 100 then
		return("%d|cffc7c7cfs|r%d|cffeda55fc|r"):format(((cash / 100) % 100), (cash % 100))
	else
		return("%d|cffeda55fc|r"):format(cash%100)
	end
end

local MailMinionOpening_OnUpdate = function(self, elapsed)
	mailElapsed = mailElapsed + elapsed;
	if not needsToWait or mailElapsed > deletedelay then
		if not InboxFrame:IsVisible() then return StopMailMinion("The Mailbox Minion Needs a Mailbox!") end
		mailElapsed = 0;
		needsToWait = nil;

		MailMinionGetMail:SetScript("OnUpdate", nil)

		local _, _, _, _, money, CODAmount, _, itemCount = GetInboxHeaderInfo(lastopened)
		local return_index;
		if((money and money > 0) or ((not takingOnlyCash) and (not (CODAmount > 0)) and (itemCount and itemCount > 0))) then
			return_index = lastopened
		else
			return_index = lastopened - 1
		end

		StartMailMinion(return_index, false)
	end
end

local MailMinionDeleting_OnUpdate = function(self, elapsed)
	deleteElapsed = deleteElapsed + elapsed;
	if not waitToDelete or deleteElapsed > deletedelay then
		if not InboxFrame:IsVisible() then return StopMailMinion("The Mailbox Minion Needs a Mailbox!") end
		deleteElapsed = 0;
		waitToDelete = nil;

		MailMinionDelete:SetScript("OnUpdate", nil)

		local return_index = lastdeleted - 1;

		StartMailMinion(return_index, true)
	end
end

function StopMailMinion(mail_message)
	MailMinionGetMail:SetScript("OnUpdate", nil)
	MailMinionDelete:SetScript("OnUpdate", nil)

	MailMinionGetMail:Enable()
	MailMinionDelete:Enable()
	MailMinionGetGold:Enable()

	if(baseInboxFrame_OnClick) then
		InboxFrame_OnClick = baseInboxFrame_OnClick;
	end

	MailMinionGetMail:UnregisterEvent("UI_ERROR_MESSAGE");

	local mail_index = GetInboxNumItems()

	takingOnlyCash = false;
	total_cash = nil;
	needsToWait = nil;
	waitToDelete = nil;
	lastopened = mail_index;
	lastdeleted = mail_index;

	mailElapsed = 0;
	deleteElapsed = 0;

	if(mail_message) then
		SV:AddonMessage(mail_message)
	end
end

function StartMailMinion(mail_index, is_deleting)
	if(not InboxFrame:IsVisible()) then
		return StopMailMinion("Mailbox Minion Needs a Mailbox!")
	elseif(mail_index == 0) then
		MiniMapMailFrame:Hide()
		return StopMailMinion("Mailbox Minion Has Finished!")
	end

	local _, _, _, _, money, CODAmount, _, itemCount = GetInboxHeaderInfo(mail_index)
	if(not is_deleting) then
		if((not takingOnlyCash) and ((money and money > 0) or (itemCount and itemCount > 0)) and (CODAmount and CODAmount <= 0)) then
			AutoLootMailItem(mail_index)
			needsToWait = true;
		elseif(money and (money > 0)) then
			TakeInboxMoney(mail_index)
			needsToWait = true;
			if(total_cash) then
				total_cash = total_cash - money
			end
		end

		local numMail = GetInboxNumItems()
		if((mail_index ~= lastopened) and (itemCount and itemCount > 0) or ((numMail > 1) and (not (mail_index > numMail)))) then
			lastopened = mail_index;
			MailMinionGetMail:SetScript("OnUpdate", MailMinionOpening_OnUpdate)
		else
			MiniMapMailFrame:Hide()
			StopMailMinion()
		end
	else
		if(((not money) or (money and money == 0)) and ((not itemCount) or (itemCount and itemCount == 0))) then
			DeleteInboxItem(mail_index)
			waitToDelete = true;
		end

		local numMail = GetInboxNumItems()
		if((mail_index ~= lastdeleted) and ((numMail > 1) and (not (mail_index > numMail)))) then
			lastdeleted = mail_index;
			MailMinionDelete:SetScript("OnUpdate", MailMinionDeleting_OnUpdate)
		else
			MiniMapMailFrame:Hide()
			StopMailMinion()
		end
	end
end
--[[
##########################################################
BUTTON SPECIFIC HANDLERS
##########################################################
]]--
function MailMinionGetMail:ClickHandler(mail_index)
	--print("MailMinionGetMail:ClickHandler")
	MailMinionGetMail:RegisterEvent("UI_ERROR_MESSAGE")
	StartMailMinion(mail_index, false)
end

function MailMinionGetGold:ClickHandler(mail_index)
	--print("MailMinionGetGold:ClickHandler")
	takingOnlyCash = true;
	StartMailMinion(mail_index, false)
end

function MailMinionDelete:ClickHandler(mail_index)
	--print("MailMinionDelete:ClickHandler")
	StartMailMinion(mail_index, true)
end
--[[
##########################################################
SCRIPT HANDLERS
##########################################################
]]--
local GoldMinionButton_OnEnter = function(self)
	if(not total_cash) then
		total_cash = 0;
		for i = 0, GetInboxNumItems() do
			total_cash = total_cash + select(5, GetInboxHeaderInfo(i))
		end
	end
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:AddLine(FancifyMoneys(total_cash), 1, 1, 1)
	GameTooltip:Show()
end

local MailMinionButton_OnEnter = function(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:AddLine(("%d messages"):format(GetInboxNumItems()), 1, 1, 1)
	GameTooltip:Show()
end

local MailMinionButton_OnLeave = function(self)
	GameTooltip:Hide()
end

local MailMinionButton_OnClick = function(self, ...)
	if(GetInboxNumItems() == 0) then return end

	MailMinionGetMail:Disable()
	MailMinionGetGold:Disable()
	MailMinionDelete:Disable()

	baseInboxFrame_OnClick = InboxFrame_OnClick;
	InboxFrame_OnClick = dummy;

	local mail_index = GetInboxNumItems();
	self:ClickHandler(mail_index);
end

local MailMinionButton_OnEvent = function(self, event, subEvent)
	if(event == "UI_ERROR_MESSAGE") then
		if((subEvent == ERR_INV_FULL) or (subEvent == ERR_ITEM_MAX_COUNT)) then
			StopMailMinion("Your bags are too full!")
		end
	end
end
--[[
##########################################################
MAIL HELPER
##########################################################
]]--
function SV:ToggleMailMinions()
	if not SV.db.Extras.mailOpener then
		MailMinion:Hide()
	else
		MailMinion:Show()
	end
end
--[[
##########################################################
LOAD BY TRIGGER
##########################################################
]]--
local function LoadMailMinions()
	if IsAddOnLoaded("Postal") then
		SV.db.Extras.mailOpener = false
	else
		MailMinion:Show()

		MailMinionGetMail:SetStyle("Button")
		MailMinionGetMail:SetScript("OnClick", MailMinionButton_OnClick)
		MailMinionGetMail:SetScript("OnEnter", MailMinionButton_OnEnter)
		MailMinionGetMail:SetScript("OnLeave", MailMinionButton_OnLeave)
		MailMinionGetMail:SetScript("OnEvent", MailMinionButton_OnEvent)

		MailMinionGetGold:SetStyle("Button")
		MailMinionGetGold:SetScript("OnClick", MailMinionButton_OnClick)
		MailMinionGetGold:SetScript("OnEnter", GoldMinionButton_OnEnter)
		MailMinionGetGold:SetScript("OnLeave", MailMinionButton_OnLeave)

		MailMinionDelete:SetStyle("Button", 1, 1, "red")
		MailMinionDelete:SetScript("OnClick", MailMinionButton_OnClick)
		MailMinionDelete:SetScript("OnEnter", MailMinionButton_OnEnter)
		MailMinionDelete:SetScript("OnLeave", MailMinionButton_OnLeave)

		SV:ToggleMailMinions()
	end
end

SV.Events:On("CORE_INITIALIZED", LoadMailMinions);
