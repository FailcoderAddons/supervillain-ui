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
local string    = _G.string;
local math      = _G.math;
local table 	= _G.table;
--[[ STRING METHODS ]]--
local join, len = string.join, string.len;
--[[ MATH METHODS ]]--
local min = math.min;
--TABLE
local table         = _G.table;
local tsort         = table.sort;
local tconcat       = table.concat;
local tinsert       = _G.tinsert;
local tremove       = _G.tremove;
local wipe         = _G.wipe;
--BLIZZARD API
local CreateFrame           = _G.CreateFrame;
local InCombatLockdown      = _G.InCombatLockdown;
local GameTooltip           = _G.GameTooltip;
local hooksecurefunc        = _G.hooksecurefunc;
local IsAltKeyDown          = _G.IsAltKeyDown;
local IsShiftKeyDown        = _G.IsShiftKeyDown;
local IsControlKeyDown      = _G.IsControlKeyDown;
local IsModifiedClick       = _G.IsModifiedClick;
local NONE                  = _G.NONE;
local IsInInstance          = _G.IsInInstance;
local GetCurrentMapAreaID          		= _G.GetCurrentMapAreaID;
local RequestBattlefieldScoreData       = _G.RequestBattlefieldScoreData;
local GetBattlefieldStatData            = _G.GetBattlefieldStatData;
local GetNumBattlefieldScores           = _G.GetNumBattlefieldScores;
local GetBattlefieldScore            	= _G.GetBattlefieldScore;
--[[
##########################################################
GET ADDON DATA
##########################################################
]]--
local SV = select(2, ...)
local L = SV.L
local SVLib = _G.Librarian("Registry")
local LSM = _G.LibStub("LibSharedMedia-3.0")
local LDB = LibStub("LibDataBroker-1.1", true)
local MOD = SV:NewPackage("Reports", L["Informative Panels"]);

MOD.Sockets = {};
MOD.Plugins = {};
MOD.References = {};
MOD.ToolTip = CreateFrame("GameTooltip", "SVUI_Report_ToolTip", UIParent, "GameTooltipTemplate");
MOD.CallBacks = _G.LibStub:GetLibrary("CallbackHandler-1.0"):New(MOD)

local PVP_SOCKETS = {};
local PVP_INFO_SORTING = {
	{"Honor", "Kills", "Assists"},
	{"Damage", "Healing", "Deaths"}
};
local PVP_INFO_LOOKUP = {
	["Name"] = {1, NAME},
	["Kills"] = {2, KILLS},
	["Assists"] = {3, PET_ASSIST},
	["Deaths"] = {4, DEATHS},
	["Honor"] = {5, HONOR},
	["Faction"] = {6, FACTION},
	["Race"] = {7, RACE},
	["Class"] = {8, CLASS},
	["Damage"] = {10, DAMAGE},
	["Healing"] = {11, SHOW_COMBAT_HEALING},
	["Rating"] = {12, BATTLEGROUND_RATING},
	["Changes"] = {13, RATING_CHANGE},
	["Spec"] = {16, SPECIALIZATION}
};
local LDB_TEXT_PATTERN = "|cff22CFFF(|r%s|cff22CFFF)|r";
local LDB_ICON_PATTERN = "\124T%s:12\124t %s";
local DIRTY_LIST = true;
--[[
##########################################################
LOCALIZED GLOBALS
##########################################################
]]--
local RAID_CLASS_COLORS = _G.RAID_CLASS_COLORS
--[[
##########################################################
LOCAL VARIABLES
##########################################################
]]--
local playerName = UnitName("player");
local playerRealm = GetRealmName();
local BGStatString = "%s: %s"
local myName = UnitName("player");
local myClass = select(2,UnitClass("player"));
local classColor = RAID_CLASS_COLORS[myClass];
local SCORE_CACHE = {};
local hexHighlight = "FFFFFF";
local StatMenuListing = {}
--[[
##########################################################
LOCAL FUNCTIONS
##########################################################
]]--
local UpdateAnchor = function()
	local backdrops, width, height = SV.db.Reports.backdrop
	for _, parent in ipairs(MOD.Sockets) do
		local point1, point2, x, y = "LEFT", "RIGHT", 4, 0;
		local slots = parent.Stats.Slots
		local numPoints = #slots
		if(parent.Stats.Orientation == "VERTICAL") then
			width = parent:GetWidth() - 4;
			height = parent:GetHeight() / numPoints - 4;

			point1, point2, x, y = "TOP", "BOTTOM", 0, -4
		else
			width = parent:GetWidth() / numPoints - 4;
			height = parent:GetHeight() - 4;
			if(backdrops) then
				height = height + 6

			end
		end

		for i = 1, numPoints do
			slots[i]:SetWidth(width)
			slots[i]:SetHeight(height)
			if(i == 1) then
				slots[i]:SetPoint(point1, parent, point1, x, y)
			else
				slots[i]:SetPoint(point1, slots[i - 1], point2, x, y)
			end
		end
	end
end

local _hook_TooltipOnShow = function(self)
	self:SetBackdrop({
		bgFile = SV.media.background.default,
		edgeFile = [[Interface\BUTTONS\WHITE8X8]],
		tile = false,
		edgeSize = 1
		})
	self:SetBackdropColor(0.05, 0.05, 0.05, 0.95)
	self:SetBackdropBorderColor(0, 0, 0)
end

local function TruncateString(value)
	if(not value or value == 0) then return 0 end
	if value >= 1e9 then
		return ("%.1fb"):format(value/1e9):gsub("%.?0+([kmb])$","%1")
	elseif value >= 1e6 then
		return ("%.1fm"):format(value/1e6):gsub("%.?0+([kmb])$","%1")
	elseif value >= 1e3 or value <= -1e3 then
		return ("%.1fk"):format(value/1e3):gsub("%.?0+([kmb])$","%1")
	else
		return value
	end
end
--[[
##########################################################
CORE FUNCTIONS
##########################################################
]]--
function MOD:SetDataTip(stat)
	local parent = stat:GetParent()
	MOD.ToolTip:Hide()
	MOD.ToolTip:SetOwner(parent, parent.Stats.TooltipAnchor)
	MOD.ToolTip:ClearLines()
	GameTooltip:Hide()
end

function MOD:SetBrokerTip(stat)
	local parent = stat:GetParent()
	MOD.ToolTip:Hide()
	MOD.ToolTip:SetOwner(parent, "ANCHOR_CURSOR")
	MOD.ToolTip:ClearLines()
	GameTooltip:Hide()
end

function MOD:PrependDataTip()
	MOD.ToolTip:AddDoubleLine("[Alt + Click]", "Swap Stats", 0, 1, 0, 0.5, 1, 0.5)
	MOD.ToolTip:AddLine(" ")
end

function MOD:ShowDataTip(noSpace)
	if(not noSpace) then
		MOD.ToolTip:AddLine(" ")
	end
	MOD.ToolTip:AddDoubleLine("[Alt + Click]", "Swap Stats", 0, 1, 0, 0.5, 1, 0.5)
	MOD.ToolTip:Show()
end

local function GetDataSlot(parent, index)
	if(not parent.Stats.Slots[index]) then
		local GlobalName = parent:GetName() .. 'StatSlot' .. index;

		local slot = CreateFrame("Button", GlobalName, parent);
		slot:RegisterForClicks("AnyUp")


		slot.barframe = CreateFrame("Frame", nil, slot)
		slot:SetStyle(parent.Stats.templateType, parent.Stats.templateName, false, 2, 0, 0)

		if(not SV.db.Reports.backdrop) then
			slot.barframe:SetPoint("TOPLEFT", slot, "TOPLEFT", 24, 2)
			slot.barframe:SetPoint("BOTTOMRIGHT", slot, "BOTTOMRIGHT", 2, -2)
			slot.barframe.bg = slot.barframe:CreateTexture(nil, "BORDER")
			slot.barframe.bg:InsetPoints(slot.barframe, 2, 2)
			slot.barframe.bg:SetTexture([[Interface\BUTTONS\WHITE8X8]])
			slot.barframe.bg:SetGradient(unpack(SV.media.gradient.dark))
			slot.Panel:Hide()
		else
			slot.barframe:SetPoint("TOPLEFT", slot, "TOPLEFT", 24, -2)
			slot.barframe:SetPoint("BOTTOMRIGHT", slot, "BOTTOMRIGHT", -2, 2)
			slot.Panel:Show()
		end

		slot.barframe:SetFrameLevel(slot:GetFrameLevel()-1)
		slot.barframe:SetBackdrop({
			bgFile = [[Interface\BUTTONS\WHITE8X8]],
			edgeFile = SV.media.border.shadow,
			tile = false,
			tileSize = 0,
			edgeSize = 2,
			insets = {left = 0, right = 0, top = 0, bottom = 0}
			})
		slot.barframe:SetBackdropColor(0, 0, 0, 0.5)
		slot.barframe:SetBackdropBorderColor(0, 0, 0, 0.8)

		slot.barframe.icon = CreateFrame("Frame", nil, slot.barframe)
		slot.barframe.icon:SetPoint("TOPLEFT", slot, "TOPLEFT", 0, 6)
		slot.barframe.icon:SetPoint("BOTTOMRIGHT", slot, "BOTTOMLEFT", 26, -6)
		slot.barframe.icon.texture = slot.barframe.icon:CreateTexture(nil, "OVERLAY")
		slot.barframe.icon.texture:InsetPoints(slot.barframe.icon, 2, 2)
		slot.barframe.icon.texture:SetTexture("")

		slot.barframe.bar = CreateFrame("StatusBar", nil, slot.barframe)
		slot.barframe.bar:InsetPoints(slot.barframe, 2, 2)
		slot.barframe.bar:SetStatusBarTexture(SV.media.statusbar.default)

		slot.barframe.bar.extra = CreateFrame("StatusBar", nil, slot.barframe.bar)
		slot.barframe.bar.extra:SetAllPoints()
		slot.barframe.bar.extra:SetStatusBarTexture(SV.media.statusbar.default)
		slot.barframe.bar.extra:Hide()

		slot.barframe:Hide()

		slot.textframe = CreateFrame("Frame", nil, slot)
		slot.textframe:SetAllPoints(slot)
		slot.textframe:SetFrameStrata(parent.Stats.textStrata)

		slot.text = slot.textframe:CreateFontString(nil, "OVERLAY", nil, 7)
		slot.text:SetAllPoints()

		SV:FontManager(slot.text, "data")
		if(SV.db.Reports.backdrop) then
			slot.text:SetShadowColor(0, 0, 0, 0.5)
			slot.text:SetShadowOffset(2, -4)
		end

		slot.SlotKey = index;
		slot.TokenKey = 738;
		slot.MenuList = {};
		slot.TokenList = {};

		parent.Stats.Slots[index] = slot;
		return slot;
	end

	return parent.Stats.Slots[index];
end

local function LDB_AttributeChanged(event, data_name, key, value, obj)
	local name = obj.ReportName
	local socket = MOD.References[name]
	if(not socket) then return end
	value = value or obj.text
	local icon = obj.icon
	if(type(value) ~= "string") then
		value = name
	end
	if(not value or value == name) then
		local prev = socket.text:GetText()
		if((not prev) or (not prev:find(name)) or (prev == "")) then
			socket.text:SetText(name)
		end
	elseif(icon and type(icon) == "string") then
		socket.text:SetText(LDB_ICON_PATTERN:format(icon, value))
	else
		socket.text:SetText(LDB_TEXT_PATTERN:format(value))
	end
end

local function CreateLDB_OnEventHandler(name, obj)
	return function(self, ...)
		LDB:RegisterCallback("LibDataBroker_AttributeChanged_"..name, LDB_AttributeChanged)
		LDB_AttributeChanged(nil, name, nil, nil, obj)
	end
end

local Socket_OnEvent = function(self, ...)
	if(self.eventFunc) then
		self.eventFunc(self, ...)
	end
end

local Socket_OnUpdate = function(self, ...)
	if(self.updateFunc) then
		self.updateFunc(self, ...)
	end
end

local LDB_OnEnter = function(self, ...)
	self.OnTooltipShow(GameTooltip)
end

local Socket_OnEnter = function(self, ...)
	if(self.enterFunc) then
		self.enterFunc(self, ...)
	end
end

local Socket_OnLeave = function(self, ...)
	if(self.leaveFunc) then
		self.leaveFunc(self, ...)
	end
	MOD.ToolTip:Hide()
end

local Socket_OnClick = function(self, button)
	if IsAltKeyDown() then
		SV.Dropdown:Open(self, self.MenuList, "Select Report");
	elseif(self.clickFunc) then
		self.clickFunc(self, button);
	end
end

function MOD:EnableReport(socket, name)
	local obj = self.Plugins[name]
	if(not obj) then return end

	if(socket.InnerData) then
		wipe(socket.InnerData)
	end

	if obj.OnInit then
		obj.OnInit(socket)
	end

	if obj.OnEvent and obj.events then
		for i=1, #obj.events do
			socket:RegisterEvent(obj.events[i])
		end
		socket.eventFunc = obj.OnEvent
		socket:SetScript("OnEvent", Socket_OnEvent)
		Socket_OnEvent(socket, "SVUI_FORCE_RUN")
	end

	if obj.OnUpdate then
		socket.updateFunc = obj.OnUpdate
	end
	socket:SetScript("OnUpdate", Socket_OnUpdate)
	Socket_OnUpdate(socket, 20000)

	if(LDB and obj.LDBName and obj.OnTooltipShow) then
		socket:SetScript("OnEnter", LDB_OnEnter)
	end

	if obj.OnEnter then
		socket.enterFunc = obj.OnEnter
	end
	socket:SetScript("OnEnter", Socket_OnEnter)

	if obj.OnLeave then
		socket.leaveFunc = obj.OnLeave
	end
	socket:SetScript("OnLeave", Socket_OnLeave)

	if obj.OnClick then
		socket.clickFunc = obj.OnClick
	end
	socket:SetScript("OnClick", Socket_OnClick)

	socket:Show()

	if(not SV.db.Reports.backdrop) then
		socket.Panel:Hide()
	else
		socket.Panel:Show()
	end

	if(LDB and obj.LDBName) then
		LDB:RegisterCallback("LibDataBroker_AttributeChanged_"..obj.LDBName, LDB_AttributeChanged)
		LDB_AttributeChanged(nil, name, nil, nil, obj)
	end
end

function MOD:NewReport(name, obj, LDBname)
	local pluginList = self.Plugins;
	local statMenu = StatMenuListing;
	if pluginList[name] then return end
	pluginList[name] = obj or {}
	if(LDBname) then
		pluginList[name].LDBName = LDBname
		pluginList[name].ReportName = name
	end
	local statCount = #statMenu + 1;
	StatMenuListing[statCount] = name;
	return obj
end

do
	local BG_OnUpdate = function(self)
		local scoreString;
		local scoreindex = self.scoreindex;
		local scoreType = self.scoretype;
		local scoreCount = GetNumBattlefieldScores()
		for i = 1, scoreCount do
			SCORE_CACHE = {GetBattlefieldScore(i)}
			if(SCORE_CACHE[1] and SCORE_CACHE[1] == myName and SCORE_CACHE[scoreindex]) then
				scoreString = TruncateString(SCORE_CACHE[scoreindex])
				self.text:SetFormattedText(BGStatString, scoreType, scoreString)
				break
			end
		end
	end

	local BG_OnEnter = function(self)
		MOD:SetDataTip(self)
		local bgName;
		local mapToken = GetCurrentMapAreaID()
		local r, g, b;
		if(classColor) then
			r, g, b = classColor.r, classColor.g, classColor.b
		else
			r, g, b = 1, 1, 1
		end

		local scoreCount = GetNumBattlefieldScores()

		for i = 1, scoreCount do
			bgName = GetBattlefieldScore(i)
			if(bgName and bgName == myName) then
				MOD.ToolTip:AddDoubleLine(L["Stats For:"], bgName, 1, 1, 1, r, g, b)
				MOD.ToolTip:AddLine(" ")
				if(mapToken == 443 or mapToken == 626) then
					MOD.ToolTip:AddDoubleLine(L["Flags Captured"], GetBattlefieldStatData(i, 1), 1, 1, 1)
					MOD.ToolTip:AddDoubleLine(L["Flags Returned"], GetBattlefieldStatData(i, 2), 1, 1, 1)
				elseif(mapToken == 482) then
					MOD.ToolTip:AddDoubleLine(L["Flags Captured"], GetBattlefieldStatData(i, 1), 1, 1, 1)
				elseif(mapToken == 401) then
					MOD.ToolTip:AddDoubleLine(L["Graveyards Assaulted"], GetBattlefieldStatData(i, 1), 1, 1, 1)
					MOD.ToolTip:AddDoubleLine(L["Graveyards Defended"], GetBattlefieldStatData(i, 2), 1, 1, 1)
					MOD.ToolTip:AddDoubleLine(L["Towers Assaulted"], GetBattlefieldStatData(i, 3), 1, 1, 1)
					MOD.ToolTip:AddDoubleLine(L["Towers Defended"], GetBattlefieldStatData(i, 4), 1, 1, 1)
				elseif(mapToken == 512) then
					MOD.ToolTip:AddDoubleLine(L["Demolishers Destroyed"], GetBattlefieldStatData(i, 1), 1, 1, 1)
					MOD.ToolTip:AddDoubleLine(L["Gates Destroyed"], GetBattlefieldStatData(i, 2), 1, 1, 1)
				elseif(mapToken == 540 or mapToken == 736 or mapToken == 461) then
					MOD.ToolTip:AddDoubleLine(L["Bases Assaulted"], GetBattlefieldStatData(i, 1), 1, 1, 1)
					MOD.ToolTip:AddDoubleLine(L["Bases Defended"], GetBattlefieldStatData(i, 2), 1, 1, 1)
				elseif(mapToken == 856) then
					MOD.ToolTip:AddDoubleLine(L["Orb Possessions"], GetBattlefieldStatData(i, 1), 1, 1, 1)
					MOD.ToolTip:AddDoubleLine(L["Victory Points"], GetBattlefieldStatData(i, 2), 1, 1, 1)
				elseif(mapToken == 860) then
					MOD.ToolTip:AddDoubleLine(L["Carts Controlled"], GetBattlefieldStatData(i, 1), 1, 1, 1)
				end
				break
			end
		end
		MOD:ShowDataTip()
	end

	local ForceHideBGStats;
	local BG_OnClick = function()
		ForceHideBGStats = true;
		MOD:UpdateAllReports()
		SV:AddonMessage(L["Battleground statistics temporarily hidden, to show type \"/sv bg\" or \"/sv pvp\""])
	end

	local function setMenuLists()
		local anchorTable = MOD.Sockets;
		local statMenu = StatMenuListing;
		tsort(statMenu)
		for reportIndex, parent in ipairs(anchorTable) do
			local slotKey = tostring(reportIndex)
			local slots = parent.Stats.Slots;
			local numPoints = #slots;
			for i = 1, numPoints do
				local subList = wipe(slots[i].MenuList)
				tinsert(subList,{text = NONE, func = function() SV.db.REPORT_SLOTS[slotKey][i] = ""; MOD:UpdateAllReports() end});
				for _,name in pairs(statMenu) do
					tinsert(subList,{text = name, func = function() SV.db.REPORT_SLOTS[slotKey][i] = name; MOD:UpdateAllReports() end});
				end
			end
		end

		DIRTY_LIST = false;
	end

	function MOD:UpdateAllReports()
		if(LDB) then
			for dataName, dataObj in LDB:DataObjectIterator() do
				local listName = dataName:gsub("Broker_", "");
				if(not MOD.Plugins[listName]) then
		  			MOD:ReportAdded(nil, dataName, dataObj, true)
		  		end
		  	end
		end
		if(DIRTY_LIST) then setMenuLists() end

		local instance, groupType = IsInInstance()
		local anchorTable = MOD.Sockets
		local reportTable = MOD.Plugins
		local docks = SV.db.REPORT_SLOTS
		local allowPvP = (SV.db.Reports.battleground and not ForceHideBGStats) or false

		for reportIndex, parent in ipairs(anchorTable) do
			if(parent.Stats and parent.Stats.Slots) then
				local slots = parent.Stats.Slots;
				local numPoints = #slots;
				local pvpIndex = parent.Stats.BGStats;
				local pvpSwitch = (allowPvP and pvpIndex and (PVP_SOCKETS[pvpIndex] == reportIndex))

				for i = 1, numPoints do
					local pvpTable = (pvpSwitch and PVP_INFO_SORTING[pvpIndex]) and PVP_INFO_SORTING[pvpIndex][i]
					local socket = slots[i];

					socket:UnregisterAllEvents()
					socket:SetScript("OnUpdate", nil)
					socket:SetScript("OnEnter", nil)
					socket:SetScript("OnLeave", nil)
					socket:SetScript("OnClick", nil)

					if socket.barframe then
						socket.barframe:Hide()
					end

					socket:Hide()

					if(pvpTable and ((instance and groupType == "pvp") or parent.lockedOpen)) then
						socket.scoreindex = PVP_INFO_LOOKUP[pvpTable][1]
						socket.scoretype = PVP_INFO_LOOKUP[pvpTable][2]
						socket:RegisterEvent("UPDATE_BATTLEFIELD_SCORE")
						socket:SetScript("OnEvent", BG_OnUpdate)
						socket:SetScript("OnEnter", BG_OnEnter)
						socket:SetScript("OnLeave", Socket_OnLeave)
						socket:SetScript("OnClick", BG_OnClick)

						BG_OnUpdate(socket)

						socket:Show()
					else
						local loaded = false;
						local x = tostring(reportIndex)
						for n, _ in pairs(reportTable) do
							for s, d in pairs(docks) do
								if(d and ((type(d) == "table" and x == s and d[i] and d[i] == n) or (type(d) == "string" and d == n))) then
									MOD.References[n] = socket
									MOD:EnableReport(socket, n)
									loaded = true
								end
							end
						end
						if(not loaded) then
							socket.text:SetText(nil)
						end
					end
				end
			end
		end

		if ForceHideBGStats then ForceHideBGStats = nil end

		local baseWidth, dockHeight = SV.Dock.BottomCenter:GetSize()
		local dockWidth = baseWidth * 0.5;
		MOD.ReportGroup1:SetSize(dockWidth, dockHeight);
		MOD.ReportGroup2:SetSize(dockWidth, dockHeight);
		MOD.ReportGroup3:SetSize(dockWidth, dockHeight);
		MOD.ReportGroup4:SetSize(dockWidth, dockHeight);
	end
end

local currentIndex = 1;

function MOD:NewHolder(parent, maxCount, tipAnchor, pvpSet, customTemplate, isVertical)
	DIRTY_LIST = true
	local parentName = parent:GetName();

	self.Sockets[currentIndex] = parent;
	parent.Stats = {};
	parent.Stats.Slots = {};
	parent.Stats.Orientation = isVertical and "VERTICAL" or "HORIZONTAL";
	parent.Stats.TooltipAnchor = tipAnchor or "ANCHOR_CURSOR";
	if(pvpSet) then
		parent.Stats.BGStats = pvpSet;
		PVP_SOCKETS[pvpSet] = currentIndex;
	end

	local point1, point2, x, y = "LEFT", "RIGHT", 4, 0;
	if(isVertical) then
		point1, point2, x, y = "TOP", "BOTTOM", 0, -4;
	end

	if(customTemplate) then
		parent.Stats.templateType = "Frame"
		parent.Stats.templateName = customTemplate
		parent.Stats.textStrata = "LOW"
	else
		parent.Stats.templateType = "Frame";
		parent.Stats.templateName = "Transparent";
		parent.Stats.textStrata = "MEDIUM";
	end

	for i = 1, maxCount do
		local slot = GetDataSlot(parent, i)
		if(i == 1) then
			parent.Stats.Slots[i]:SetPoint(point1, parent, point1, x, y)
		else
			parent.Stats.Slots[i]:SetPoint(point1, parent.Stats.Slots[i - 1], point2, x, y)
		end
	end

	parent:SetScript("OnSizeChanged", UpdateAnchor);
	local slotKey = tostring(currentIndex);
	if(slotKey and (not SV.db.REPORT_SLOTS[slotKey])) then
		SV.db.REPORT_SLOTS[slotKey] = {};
        for i = 1, maxCount do
        	SV.db.REPORT_SLOTS[slotKey][i] = "None"
        end
	end

	currentIndex = currentIndex + 1;

	UpdateAnchor(parent);
end

local function SlashPvPStats()
	MOD.ForceHideBGStats = nil;
	MOD:UpdateAllReports()
	SV:AddonMessage(L['Battleground statistics will now show again if you are inside a battleground.'])
end
--[[
##########################################################
BUILD FUNCTION / UPDATE
##########################################################
]]--
function SV:GetReportData(key)
	return MOD.Accountant[key]
end

function MOD:SetAccountantData(key, cacheType, defaultValue)
	self.Accountant[key] = self.Accountant[key] or {};
	local cache = self.Accountant[key];
	if(type(cache) == 'number') then
		cache = defaultValue;
	elseif(not cache[playerName] or type(cache[playerName]) ~= cacheType) then
		cache[playerName] = defaultValue;
	end
end

function MOD:SetSubSettingsData(key, cacheType, defaultValue)
	self.SubSettings[key] = self.SubSettings[key] or {};
	local cache = self.SubSettings[key];
	if(type(cache) == 'number') then
		cache = defaultValue;
	elseif(not cache[playerName] or type(cache[playerName]) ~= cacheType) then
		cache[playerName] = defaultValue;
	end
end

function MOD:ReportAdded(event, dataName, dataObj, noupdate)
	local t = dataObj.type
	if(t) then
		if(t == "data source" or t == "launcher") then
		    local listName = dataName:gsub("Broker_", "");
		    MOD:NewReport(listName, dataObj, dataName);
		    DIRTY_LIST = true
		else
			SV:HandleError("LibDataBroker", dataName, "Data type (" .. t .. ") is not allowed")
		end
	--else
		--SV:HandleError("LibDataBroker", dataName, "CAUTION: This is a badly written addon")
	end
end

function MOD:Load()
	local baseWidth, dockHeight = SV.Dock.BottomCenter:GetSize()
	local dockWidth = baseWidth * 0.5;

	hexHighlight = SV:HexColor("highlight") or "FFFFFF"
	local hexClass = classColor.colorStr
	BGStatString = "|cff" .. hexHighlight .. "%s: |c" .. hexClass .. "%s|r";

	local accountant = SVLib:NewGlobal("Accountant")
	accountant[playerRealm] = accountant[playerRealm] or {};
	self.Accountant = accountant[playerRealm];

	local subsettings = SVLib:NewGlobal("ReportSubSettings")
	subsettings[playerRealm] = subsettings[playerRealm] or {};
	self.SubSettings = subsettings[playerRealm];

	--BOTTOM CENTER BARS
	local bottomLeft = CreateFrame("Frame", "SVUI_ReportsGroup1", SV.Dock.BottomCenter)
	bottomLeft:SetSize(dockWidth, dockHeight)
	bottomLeft:SetPoint("BOTTOMLEFT", SV.Dock.BottomCenter, "BOTTOMLEFT", 0, 0)
	SV:NewAnchor(bottomLeft, L["Data Reports 1"])
	self:NewHolder(bottomLeft, 3, "ANCHOR_CURSOR")

	local bottomRight = CreateFrame("Frame", "SVUI_ReportsGroup2", SV.Dock.BottomCenter)
	bottomRight:SetSize(dockWidth, dockHeight)
	bottomRight:SetPoint("BOTTOMRIGHT", SV.Dock.BottomCenter, "BOTTOMRIGHT", 0, 0)
	SV:NewAnchor(bottomRight, L["Data Reports 2"])
	self:NewHolder(bottomRight, 3, "ANCHOR_CURSOR")

	--TOP CENTER BARS
	local topLeft = CreateFrame("Frame", "SVUI_ReportsGroup3", SV.Dock.TopCenter)
	topLeft:SetSize(dockWidth, dockHeight)
	topLeft:SetPoint("TOPLEFT", SV.Dock.TopCenter, "TOPLEFT", 0, 0)

	SV:NewAnchor(topLeft, L["Data Reports 3"])
	self:NewHolder(topLeft, 3, "ANCHOR_CURSOR", 1)

	local topRight = CreateFrame("Frame", "SVUI_ReportsGroup4", SV.Dock.TopCenter)
	topRight:SetSize(dockWidth, dockHeight)
	topRight:SetPoint("TOPRIGHT", SV.Dock.TopCenter, "TOPRIGHT", 0, 0)

	SV:NewAnchor(topRight, L["Data Reports 4"])
	self:NewHolder(topRight, 3, "ANCHOR_CURSOR", 2)

	self.ReportGroup1 = bottomLeft;
	self.ReportGroup2 = bottomRight;
	self.ReportGroup3 = topLeft;
	self.ReportGroup4 = topRight;

	-- self.ToolTip:SetParent(SV.Screen)
	self.ToolTip:SetFrameStrata("DIALOG")
	self.ToolTip:HookScript("OnShow", _hook_TooltipOnShow)

	if(LDB) then
		for dataName, dataObj in LDB:DataObjectIterator() do
	  		MOD:ReportAdded(nil, dataName, dataObj, true)
	  	end
	  	LDB.RegisterCallback(MOD, "LibDataBroker_DataObjectCreated", "ReportAdded")
	end
	MOD:UpdateAllReports()

	self:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdateAllReports");

	local slashDesc = "Toggle PvP stats on docks";
	SV:AddSlashCommand("bg", slashDesc, SlashPvPStats);
	SV:AddSlashCommand("pvp", slashDesc, SlashPvPStats);
	SV.Events:On("DOCKS_UPDATED", MOD.UpdateAllReports, true);
end
