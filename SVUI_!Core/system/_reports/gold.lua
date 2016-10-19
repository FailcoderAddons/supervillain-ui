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
local abs, ceil, floor, round, mod = math.abs, math.ceil, math.floor, math.round, math.fmod;  -- Basic
--[[ TABLE METHODS ]]--
local twipe, tsort = table.wipe, table.sort;
--[[
##########################################################
GET ADDON DATA
##########################################################
]]--
local SV = select(2, ...)
local L = SV.L;
local Reports = SV.Reports;
--[[
##########################################################
GOLD STATS
##########################################################
]]--
local REPORT_NAME = "Gold";
local HEX_COLOR = "22FFFF";
local TEXT_PATTERN = join("","|cffaaaaaa",L["Reset Data: Hold Left Ctrl + Shift then Click"],"|r");
local playerName = UnitName("player");
local playerRealm = GetRealmName();
local gains = 0;
local loss = 0;
local recorded = 0;

local Gold_OnEvent = function(self, event, ...)
    if not IsLoggedIn() then return end
	local current = GetMoney()
	recorded = Reports.Accountant["gold"][playerName] or current;
	local adjusted = current - recorded;
	if recorded > current then
		loss = loss - adjusted
	else
		gains = gains + adjusted
	end
	self.text:SetText(SV:FormatCurrency(current, SV.db.Reports.shortGold))
	Reports.Accountant["gold"][playerName] = current
end

local Report = Reports:NewReport(REPORT_NAME, {
	type = "data source",
	text = REPORT_NAME .. " Info",
	icon = [[Interface\Addons\SVUI_!Core\assets\icons\SVUI]]
});

Report.events = {"PLAYER_ENTERING_WORLD", "PLAYER_MONEY", "SEND_MAIL_MONEY_CHANGED", "SEND_MAIL_COD_CHANGED", "PLAYER_TRADE_MONEY", "TRADE_MONEY_CHANGED"};

Report.OnEvent = Gold_OnEvent

Report.OnClick = function(self, button)
	if IsLeftControlKeyDown() and IsShiftKeyDown() then
		Reports.Accountant["gold"] = {};
		Reports.Accountant["gold"][playerName] = GetMoney();
		Gold_OnEvent(self)
		Reports.ToolTip:Hide()
	else
		ToggleAllBags()
	end
end

Report.OnEnter = function(self)
	Reports:SetDataTip(self)
	Reports.ToolTip:AddLine(L['Session:'])
	Reports.ToolTip:AddDoubleLine(L["Earned:"],SV:FormatCurrency(gains),1,1,1,1,1,1)
	Reports.ToolTip:AddDoubleLine(L["Spent:"],SV:FormatCurrency(loss),1,1,1,1,1,1)
	if gains < loss then
		Reports.ToolTip:AddDoubleLine(L["Deficit:"],SV:FormatCurrency(gains - loss),1,0,0,1,1,1)
	elseif (gains - loss) > 0 then
		Reports.ToolTip:AddDoubleLine(L["Profit:"],SV:FormatCurrency(gains - loss),0,1,0,1,1,1)
	end
	Reports.ToolTip:AddLine(" ")
	local networth = Reports.Accountant["gold"][playerName];
	Reports.ToolTip:AddLine(L[playerName..": "])
	Reports.ToolTip:AddDoubleLine(L["Total: "], SV:FormatCurrency(networth), 1,1,1,1,1,1)
	Reports.ToolTip:AddLine(" ")

	Reports.ToolTip:AddLine(L["Characters: "])
	for name,amount in pairs(self.InnerData)do
		if(name ~= playerName and name ~= 'total') then
			networth = networth + amount;
			Reports.ToolTip:AddDoubleLine(name, SV:FormatCurrency(amount), 1,1,1,1,1,1)
		end
	end

	Reports.Accountant["networth"] = networth;

	Reports.ToolTip:AddLine(" ")
	Reports.ToolTip:AddLine(L["Server: "])
	Reports.ToolTip:AddDoubleLine(L["Total: "], SV:FormatCurrency(networth), 1,1,1,1,1,1)
	Reports.ToolTip:AddLine(" ")
	Reports.ToolTip:AddLine(TEXT_PATTERN)
	Reports:ShowDataTip()
end

Report.OnInit = function(self)
	if(not self.InnerData) then
		self.InnerData = {}
	end
	Reports:SetAccountantData('gold', 'number', 0);
	Reports:SetAccountantData('networth', 'number', 0);

	local totalGold = 0;
	for name,amount in pairs(Reports.Accountant["gold"]) do
		if(amount) then
			self.InnerData[name] = amount;
			totalGold = totalGold + amount
		end
	end

	self.InnerData['total'] = totalGold;
end
