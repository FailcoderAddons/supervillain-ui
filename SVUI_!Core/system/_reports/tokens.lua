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

--[[
##########################################################
Tables of tokens (we're interested in)
Format: ID, Cap
##########################################################
]]--
local ARCHAEOLOGY_TOKENS={
	{ 829, 250},
	{ 1174, 200},
	{ 398, 200},
	{ 821, 250},
	{ 384, 200},
	{ 393, 200},
	{ 1172, 200},
	{ 1173, 200},
	{ 754, 200},
	{ 677, 200},
	{ 400, 200},
	{ 394, 200},
	{ 828, 250},
	{ 397, 200},
	{ 676, 200},
	{ 401, 200},
	{ 385, 200},
	{ 399, 200}
}

local JEWELCRAFTING_TOKENS={
	{ 61, 0},
	{ 361, 0},
	{ 1008, 0}
}

local COOKING_TOKENS={
	{ 81, 0},
	{ 402, 0}
}

local DUNGEON_TOKENS={
	{ 1166, 0},
	{ 1191, 5000},
	{ 1273, 10},
	{ 776, 20},
	{ 1129, 20},
	{ 994, 20},
}

local GARRISON_TOKENS={
	{ 823, 0},
	{ 824, 10000},
	{ 1101, 100000}
}

local LEGION_TOKENS={
	{ 1220, 0},
	{ 1155, 300},
	{ 1275, 0},
	{ 1226, 2000},
	{ 1154, 500},
	{ 1149, 5000},
	{ 1268, 1000}
}

local PVP_TOKENS={
	{ 391, 300}
}

local MISC_TOKENS={
	{ 777, 0 },
	{ 416, 0 }
}

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

local function AddTokenTableToMenu(self,ttable,key)
	for k,v in pairs(ttable) do
		AddToTokenMenu(self, v[1], key)	
	end
end

local function CacheTokenData(self)
	twipe(self.InnerData);
	local prof1, prof2, archaeology, _, cooking = GetProfessions();
	local key = self:GetName();
	if archaeology then
		AddTokenTableToMenu(self, ARCHAEOLOGY_TOKENS, key)
	end
	if cooking then
		AddTokenTableToMenu(self, COOKING_TOKENS, key)
	end
	if(prof1 == 9 or prof2 == 9) then
		AddTokenTableToMenu(self, JEWELCRAFTING_TOKENS, key)
	end
	AddTokenTableToMenu(self, GARRISON_TOKENS, key)
	AddTokenTableToMenu(self, DUNGEON_TOKENS, key)
	AddTokenTableToMenu(self, LEGION_TOKENS, key)
	AddTokenTableToMenu(self, PVP_TOKENS, key)
	AddTokenTableToMenu(self, MISC_TOKENS, key)


	tsort(self.InnerData, sort_menu_fn)
end

local function TokenInquiry(id, weekly, cap)
	--name, amount, texturePath, earnedThisWeek, weeklyMax, totalMax, isDiscovered = GetCurrencyInfo(id)
	local name, amount, tex, week, weekmax, maxed, discovered = GetCurrencyInfo(id)
	local max = maxed or cap -- If there's a maxed value returned, use that not our default - e.g. Ancient Mana
	local r, g, b = 1, 1, 1
	for i = 1, GetNumWatchedTokens() do
		local _, _, _, itemID = GetBackpackCurrencyInfo(i)
		if id == itemID then r, g, b = 0.23, 0.88, 0.27 end
	end
	local texStr = ("\124T%s:12\124t %s"):format(tex, name)
	local altStr = ""
	-- JV - 20160919: I think weekly caps are gone in legion...
	-- if weekly then
	-- 	if discovered then
	-- 		if id == 390 then
	-- 			local pointsThisWeek, maxPointsThisWeek = GetPVPRewards();
	-- 			altStr = ("Current: %d | Weekly: %d / %d"):format(amount, pointsThisWeek, maxPointsThisWeek)
	-- 		else
	-- 			altStr = ("Current: %d / %d | Weekly: %d / %d"):format(amount, maxed, week, weekmax)
	-- 		end
	-- 		Reports.ToolTip:AddDoubleLine(texStr, altStr, r, g, b, r, g, b)
	-- 	end
	-- elseif capped then
	if max > 0 then
		if discovered then
			altStr = ("%d / %d"):format(amount, max)
			Reports.ToolTip:AddDoubleLine(texStr, altStr, r, g, b, r, g, b)
		end
	else
		if discovered then
			Reports.ToolTip:AddDoubleLine(texStr, amount, r, g, b, r, g, b)
		end
	end
end

local function TokenInquiryTable(ttable)
	for k,v in pairs(ttable) do
		TokenInquiry(v[1], false, v[2])
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
	TokenInquiryTable(MISC_TOKENS)

	Reports.ToolTip:AddLine(" ")
	Reports.ToolTip:AddLine("Legion")
	TokenInquiryTable(LEGION_TOKENS)


	Reports.ToolTip:AddLine(" ")
	Reports.ToolTip:AddLine("Garrison")
	TokenInquiryTable(GARRISON_TOKENS)


	Reports.ToolTip:AddLine(" ")
	Reports.ToolTip:AddLine("Raiding and Dungeons")
	TokenInquiryTable(DUNGEON_TOKENS)

	Reports.ToolTip:AddLine(" ")
	Reports.ToolTip:AddLine("PvP")
	TokenInquiryTable(PVP_TOKENS)


	local prof1, prof2, archaeology, _, cooking = GetProfessions()
	if(archaeology or cooking or prof1 == 9 or prof2 == 9) then
		Reports.ToolTip:AddLine(" ")
		Reports.ToolTip:AddLine("Professions")
	end
	if cooking then
		TokenInquiryTable(COOKING_TOKENS)
	end
	if(prof1 == 9 or prof2 == 9) then
		TokenInquiryTable(JEWELCRAFTING_TOKENS)
	end
	if archaeology then
		TokenInquiryTable(ARCHAEOLOGY_TOKENS)
	end
	Reports.ToolTip:AddLine(" ")
	Reports.ToolTip:AddDoubleLine("[Shift + Click]", "Change Watched Token", 0,1,0, 0.5,1,0.5)
	Reports:ShowDataTip(true)
end

Report.OnInit = function(self)
-- JV - 20160919: Bug #15 - This is causing an error. Not sure why it necessary?!
--	if not IsAddOnLoaded("Blizzard_PVPUI") then
--		LoadAddOn("Blizzard_PVPUI")
--	end
	if(not self.InnerData) then
		self.InnerData = {}
	end
	Reports:SetAccountantData('tokens', 'table', {})
	local key = self:GetName()
	Reports.Accountant["tokens"][playerName][key] = Reports.Accountant["tokens"][playerName][key] or 738;
	self.TokenKey = Reports.Accountant["tokens"][playerName][key]
	CacheTokenData(self);
end