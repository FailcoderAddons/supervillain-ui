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
local tostring      = _G.tostring;
local tonumber      = _G.tonumber;

--STRING
local string        = _G.string;
local upper         = string.upper;
local format        = string.format;
local find          = string.find;
local match         = string.match;
local gsub          = string.gsub;
--TABLE
local table 		= _G.table;
local tremove       = _G.tremove;
local twipe 		= _G.wipe;
--MATH
local math      	= _G.math;
local min 			= math.min;
local floor         = math.floor
local ceil          = math.ceil
--BLIZZARD API
local GameTooltip          	= _G.GameTooltip;
local InCombatLockdown     	= _G.InCombatLockdown;
local CreateFrame          	= _G.CreateFrame;
local GetTime         		= _G.GetTime;
local GetItemCooldown       = _G.GetItemCooldown;
local GetItemCount         	= _G.GetItemCount;
local GetItemInfo          	= _G.GetItemInfo;
local GetSpellInfo         	= _G.GetSpellInfo;
local IsSpellKnown         	= _G.IsSpellKnown;
local GetProfessions       	= _G.GetProfessions;
local GetProfessionInfo    	= _G.GetProfessionInfo;
local hooksecurefunc     	= _G.hooksecurefunc;
--[[
##########################################################
ADDON
##########################################################
]]--
local SV = select(2, ...)
local L = SV.L

local MOD = SV.Dock;
--[[
##########################################################
LOCALS
##########################################################
]]--
local LastAddedMacro;
local MacroCount = 0;

local function GetMacroCooldown(itemID)
	local start,duration = GetItemCooldown(itemID)
	local expires = duration - (GetTime() - start)
	if expires > 0.05 then
		local timeLeft = 0;
		local calc = 0;
		if expires < 4 then
			return format("|cffff0000%.1f|r", expires)
		elseif expires < 60 then
			return format("|cffffff00%d|r", floor(expires))
		elseif expires < 3600 then
			timeLeft = ceil(expires / 60);
			calc = floor((expires / 60) + .5);
			return format("|cffff9900%dm|r", timeLeft)
		elseif expires < 86400 then
			timeLeft = ceil(expires / 3600);
			calc = floor((expires / 3600) + .5);
			return format("|cff66ffff%dh|r", timeLeft)
		else
			timeLeft = ceil(expires / 86400);
			calc = floor((expires / 86400) + .5);
			return format("|cff6666ff%dd|r", timeLeft)
		end
	else
		return "|cff6666ffReady|r"
	end
end

local MacroButton_OnEnter = function(self)
	local text1 = self:GetAttribute("tipText")
	local text2 = self:GetAttribute("tipExtraText")
	GameTooltip:AddLine(text1, 1, 1, 0)
	GameTooltip:AddLine(" ", 1, 1, 1)
	GameTooltip:AddDoubleLine("[Left-Click]", text1, 0, 1, 0, 1, 1, 1)
	if(text2) then
		GameTooltip:AddDoubleLine("[Right-Click]", "Use " .. text2, 0, 1, 0, 1, 1, 1)
		if InCombatLockdown() then return end
		if(self.ItemToUse) then
			GameTooltip:AddLine(" ", 1, 1, 1)
			local remaining = GetMacroCooldown(self.ItemToUse)
			GameTooltip:AddDoubleLine(text2, remaining, 1, 0.5, 0, 0, 1, 1)
		end
	end
end

local function CreateMacroToolButton(proName, proID, itemID)
	local data = SV.media.dock.professionIconCoords[proID]
	if(not data) then return end

	local globalName = ("SVUI_%s"):format(proName)
	local button = SV.Dock:SetDockButton("BottomRight", proName, globalName, SV.media.dock.professionIconFile, MacroButton_OnEnter, "SecureActionButtonTemplate")

	button.Icon:SetTexCoord(data[1], data[2], data[3], data[4])

	if proID == 186 then proName = GetSpellInfo(2656) end

	--button:RegisterForClicks("AnyDown")
	button:SetAttribute("type1", "macro")
	button:SetAttribute("macrotext1", "/cast [nomod]" .. proName)

	if(data[5]) then
		local rightClick
		if(data[6] and GetItemCount(data[6], true) > 0) then
			rightClick = GetItemInfo(data[6])
			button.ItemToUse = data[6]
		else
			rightClick = GetSpellInfo(data[5])
		end
		button:SetAttribute("tipExtraText", rightClick)
		button:SetAttribute("type2", "macro")
		button:SetAttribute("macrotext2", "/cast [nomod] " .. rightClick)
	end
end

local function LoadToolBarProfessions()
	if(MOD.ToolBarLoaded) then return end

	if(InCombatLockdown()) then
		MOD.ProfessionNeedsUpdate = true;
		MOD:RegisterEvent("PLAYER_REGEN_ENABLED");
		return
	end

	-- PROFESSION BUTTONS
	local proName, proID
	local prof1, prof2, archaeology, _, cooking, firstAid = GetProfessions()

	if(firstAid ~= nil and (SV.db.Dock.dockTools.firstAid)) then
		proName, _, _, _, _, _, proID = GetProfessionInfo(firstAid)
		CreateMacroToolButton(proName, proID, firstAid)
	end

	if(archaeology ~= nil and (SV.db.Dock.dockTools.archaeology)) then
		proName, _, _, _, _, _, proID = GetProfessionInfo(archaeology)
		CreateMacroToolButton(proName, proID, archaeology)
	end

	if(cooking ~= nil and (SV.db.Dock.dockTools.cooking)) then
		proName, _, _, _, _, _, proID = GetProfessionInfo(cooking)
		CreateMacroToolButton(proName, proID, cooking)
	end

	if(prof2 ~= nil and (SV.db.Dock.dockTools.secondary)) then
		proName, _, _, _, _, _, proID = GetProfessionInfo(prof2)
		if(proID ~= 182 and proID ~= 393) then
			CreateMacroToolButton(proName, proID, prof2)
		end
	end

	if(prof1 ~= nil and (SV.db.Dock.dockTools.primary)) then
		proName, _, _, _, _, _, proID = GetProfessionInfo(prof1)
		if(proID ~= 182 and proID ~= 393) then
			CreateMacroToolButton(proName, proID, prof1)
		end
	end

	MOD.ToolBarLoaded = true
end
--[[
##########################################################
BUILD/UPDATE
##########################################################
]]--
function MOD:UpdateProfessionTools()
	if(self.ToolBarLoaded) then return end
	LoadToolBarProfessions()
end

function MOD:LoadProfessionTools()
	if(self.ToolBarLoaded) then return end
	SV.Timers:ExecuteTimer(LoadToolBarProfessions, 5)
end
