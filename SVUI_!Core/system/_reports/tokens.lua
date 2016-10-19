--[[
##############################################################################
S V U I By: Failcoder
##############################################################################

##########################################################
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;

local select = _G.select;
local table = _G.table;
local twipe = table.wipe;
local tsort = table.sort;
local GetCurrencyInfo = _G.GetCurrencyInfo;
local GetNumWatchedTokens = _G.GetNumWatchedTokens;
local GetBackpackCurrencyInfo = _G.GetBackpackCurrencyInfo;
local GetProfessions = _G.GetProfessions;
local IsLoggedIn = _G.IsLoggedIn;
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
local REPORT_NAME = "Tokens";
local HEX_COLOR = "22FFFF";
local TEXT_PATTERN = "\124T%s:12\124t %s";
local playerName = UnitName("player");
local playerRealm = GetRealmName();

local sort_menu_fn = function(a,b) return a.text < b.text end;

local Tokens_OnEvent = function(self, event, ...)
if(not IsLoggedIn() or (not self)) then return end
local id = self.TokenKey or 738;
local _, current, tex = GetCurrencyInfo(id)
local currentText = TEXT_PATTERN:format(tex, current);
self.text:SetText(currentText)
end

local function AddToTokenMenu(self, id, key)
local itemName, _, tex, _, _, _, _ = GetCurrencyInfo(id)
local fn = function()
Reports.Accountant["tokens"][playerName][key] = id;
self.TokenKey = id
Tokens_OnEvent(self)
end
local nextIndex = #self.InnerData+1;
self.InnerData[nextIndex] = {text = itemName, icon = "\124T"..tex..":12\124t ", func = fn};
end

local function CacheTokenData(self)
twipe(self.InnerData);
local prof1, prof2, archaeology, _, cooking = GetProfessions();
local key = self:GetName();
if archaeology then
AddToTokenMenu(self, 398, key)
AddToTokenMenu(self, 384, key)
AddToTokenMenu(self, 393, key)
AddToTokenMenu(self, 677, key)
AddToTokenMenu(self, 400, key)
AddToTokenMenu(self, 394, key)
AddToTokenMenu(self, 397, key)
AddToTokenMenu(self, 676, key)
AddToTokenMenu(self, 401, key)
AddToTokenMenu(self, 385, key)
AddToTokenMenu(self, 399, key)
AddToTokenMenu(self, 821, key)
AddToTokenMenu(self, 829, key)
AddToTokenMenu(self, 944, key)
end
if cooking then
AddToTokenMenu(self, 81, key)
AddToTokenMenu(self, 402, key)
end
if(prof1 == 9 or prof2 == 9) then
AddToTokenMenu(self, 61, key)
AddToTokenMenu(self, 361, key)
AddToTokenMenu(self, 698, key)

AddToTokenMenu(self, 910, key)
AddToTokenMenu(self, 999, key)
AddToTokenMenu(self, 1020, key)
AddToTokenMenu(self, 1008, key)
AddToTokenMenu(self, 1017, key)
end
AddToTokenMenu(self, 1166, key)
AddToTokenMenu(self, 1129, key)
AddToTokenMenu(self, 994, key)
AddToTokenMenu(self, 697, key)
AddToTokenMenu(self, 738, key)
AddToTokenMenu(self, 615, key)
AddToTokenMenu(self, 614, key)
AddToTokenMenu(self, 395, key)
AddToTokenMenu(self, 396, key)
AddToTokenMenu(self, 390, key)
AddToTokenMenu(self, 392, key)
AddToTokenMenu(self, 391, key)
AddToTokenMenu(self, 241, key)
AddToTokenMenu(self, 416, key)
AddToTokenMenu(self, 515, key)
AddToTokenMenu(self, 776, key)
AddToTokenMenu(self, 777, key)
AddToTokenMenu(self, 789, key)
AddToTokenMenu(self, 823, key)
AddToTokenMenu(self, 824, key)
AddToTokenMenu(self, 1101, key)

tsort(self.InnerData, sort_menu_fn)
end

local function TokenInquiry(id, weekly, capped)
--name, amount, texturePath, earnedThisWeek, weeklyMax, totalMax, isDiscovered = GetCurrencyInfo(id)
local name, amount, tex, week, weekmax, maxed, discovered = GetCurrencyInfo(id)
local r, g, b = 1, 1, 1
for i = 1, GetNumWatchedTokens() do
local _, _, _, itemID = GetBackpackCurrencyInfo(i)
if id == itemID then r, g, b = 0.23, 0.88, 0.27 end
end
local texStr = ("\124T%s:12\124t %s"):format(tex, name)
local altStr = ""
if weekly then
if discovered then
if id == 390 then
local pointsThisWeek, maxPointsThisWeek = GetPVPRewards();
altStr = ("Current: %d | Weekly: %d / %d"):format(amount, pointsThisWeek, maxPointsThisWeek)
else
altStr = ("Current: %d / %d | Weekly: %d / %d"):format(amount, maxed, week, weekmax)
end
Reports.ToolTip:AddDoubleLine(texStr, altStr, r, g, b, r, g, b)
end
elseif capped then
if id == 392 or id == 395 then maxed = 4000 end
if id == 396 then maxed = 3000 end
if id == 1129 then maxed = 10 end
if discovered then
altStr = ("%d / %d"):format(amount, maxed)
Reports.ToolTip:AddDoubleLine(texStr, altStr, r, g, b, r, g, b)
end
else
if discovered then
Reports.ToolTip:AddDoubleLine(texStr, amount, r, g, b, r, g, b)
end
end
end
--[[
##########################################################
REPORT TEMPLATE
##########################################################
]]--
local Report = Reports:NewReport(REPORT_NAME, {
type = "data source",
text = REPORT_NAME .. " Info",
icon = [[Interface\Addons\SVUI_!Core\assets\icons\SVUI]]
});

Report.events = {"PLAYER_ENTERING_WORLD", "PLAYER_MONEY", "CURRENCY_DISPLAY_UPDATE"};

Report.OnEvent = Tokens_OnEvent;

Report.OnClick = function(self, button)
CacheTokenData(self);
SV.Dropdown:Open(self, self.InnerData, "Select Currency", 200)
end

Report.OnEnter = function(self)
Reports:SetDataTip(self)
Reports.ToolTip:AddLine(playerName .. "\'s Tokens")

Reports.ToolTip:AddLine(" ")
Reports.ToolTip:AddLine("Common")
TokenInquiry(241)
TokenInquiry(416)
TokenInquiry(515)
TokenInquiry(776)
TokenInquiry(777)
TokenInquiry(789)

Reports.ToolTip:AddLine(" ")
Reports.ToolTip:AddLine("Garrison")
TokenInquiry(823)
TokenInquiry(824)
TokenInquiry(1101)
TokenInquiry(910)
TokenInquiry(999)
TokenInquiry(1020)
TokenInquiry(1008)
TokenInquiry(1017)

Reports.ToolTip:AddLine(" ")
Reports.ToolTip:AddLine("Raiding and Dungeons")
TokenInquiry(1166)
TokenInquiry(1129, false, true)
TokenInquiry(994, false, true)
TokenInquiry(697, false, true)
TokenInquiry(738)
TokenInquiry(615)
TokenInquiry(614)
TokenInquiry(395, false, true)
TokenInquiry(396, false, true)

Reports.ToolTip:AddLine(" ")
Reports.ToolTip:AddLine("PvP")
TokenInquiry(390, true)
TokenInquiry(392, false, true)
TokenInquiry(391)

local prof1, prof2, archaeology, _, cooking = GetProfessions()
if(archaeology or cooking or prof1 == 9 or prof2 == 9) then
Reports.ToolTip:AddLine(" ")
Reports.ToolTip:AddLine("Professions")
end
if cooking then
TokenInquiry(81)
TokenInquiry(402)
end
if(prof1 == 9 or prof2 == 9) then
TokenInquiry(61)
TokenInquiry(361)
TokenInquiry(698)
end
if archaeology then
TokenInquiry(821)
TokenInquiry(829)
TokenInquiry(944)
TokenInquiry(398)
TokenInquiry(384)
TokenInquiry(393)
TokenInquiry(677)
TokenInquiry(400)
TokenInquiry(394)
TokenInquiry(397)
TokenInquiry(676)
TokenInquiry(401)
TokenInquiry(385)
TokenInquiry(399)
end
Reports.ToolTip:AddLine(" ")
Reports.ToolTip:AddDoubleLine("[Shift + Click]", "Change Watched Token", 0,1,0, 0.5,1,0.5)
Reports:ShowDataTip(true)
end

Report.OnInit = function(self)
if not IsAddOnLoaded("Blizzard_PVPUI") then
LoadAddOn("Blizzard_PVPUI")
end
if(not self.InnerData) then
self.InnerData = {}
end
Reports:SetAccountantData('tokens', 'table', {})
local key = self:GetName()
Reports.Accountant["tokens"][playerName][key] = Reports.Accountant["tokens"][playerName][key] or 738;
self.TokenKey = Reports.Accountant["tokens"][playerName][key]
CacheTokenData(self);
end