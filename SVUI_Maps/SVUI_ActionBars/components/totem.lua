--[[
##########################################################
S V U I   By: Failcoder
##########################################################
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local unpack 	= _G.unpack;
local select 	= _G.select;
local pairs 	= _G.pairs;
local ipairs 	= _G.ipairs;
local type 		= _G.type;
local math 		= _G.math;
local cos, deg, rad, sin = math.cos, math.deg, math.rad, math.sin;
local hooksecurefunc = _G.hooksecurefunc;
--[[
##########################################################
GET ADDON DATA
##########################################################
]]--
local SV = _G['SVUI']
local L = SV.L;
local MOD = SV.ActionBars;
--[[
##########################################################
LOCALS
##########################################################
]]--
local PlayerClass = select(2, UnitClass('player'))
local TOTEM_PRIORITIES = STANDARD_TOTEM_PRIORITIES;
local MOVER_NAME = L["Totem Bar"];
if(PlayerClass == "SHAMAN") then
	TOTEM_PRIORITIES = SHAMAN_TOTEM_PRIORITIES
elseif(PlayerClass == "DEATHKNIGHT") then
	MOVER_NAME = L["Ghoul Bar"]
elseif(PlayerClass == "DRUID") then
	MOVER_NAME = L["Mushroom Bar"]
end
--[[
##########################################################
TOTEMS
##########################################################
]]--
local Totems = CreateFrame("Frame", "SVUI_TotemBar", UIParent);

function Totems:Refresh()
	for i = 1, MAX_TOTEMS do
		local slot = TOTEM_PRIORITIES[i]
		local haveTotem, name, start, duration, icon = GetTotemInfo(slot)
		local svuitotem = _G["SVUI_TotemBarTotem"..slot]
		if(haveTotem) then
			svuitotem:Show()
			svuitotem.Icon:SetTexture(icon)
			CooldownFrame_Set(svuitotem.CD, start, duration, 1)
			local blizztotem = _G["TotemFrameTotem"..slot]
			local tslot = blizztotem.slot
			if(tslot and tslot > 0) then
				local anchor = _G["SVUI_TotemBarTotem"..tslot]
				blizztotem:ClearAllPoints()
				blizztotem:SetAllPoints(anchor)
				blizztotem:SetFrameStrata(anchor:GetFrameStrata())
				blizztotem:SetFrameLevel(anchor:GetFrameLevel() + 99)
			end
		else
			svuitotem:Hide()
		end
	end
end

function Totems:Update()
	local settings = SV.db.ActionBars.Totem;
	local totemSize = settings.buttonsize;
	local totemSpace = settings.buttonspacing;
	local totemGrowth = settings.showBy;
	local totemSort = settings.sortDirection;

	for i = 1, MAX_TOTEMS do
		local button = self[i]
		if(button) then
			local lastButton = self[i - 1]
			button:SetSize(totemSize, totemSize)
			button:ClearAllPoints()
			if(totemGrowth == "HORIZONTAL" and totemSort == "ASCENDING") then
				if(i == 1) then
					button:SetPoint("LEFT", self, "LEFT", totemSpace, 0)
				elseif lastButton then
					button:SetPoint("LEFT", lastButton, "RIGHT", totemSpace, 0)
				end
			elseif(totemGrowth == "VERTICAL" and totemSort == "ASCENDING") then
				if(i == 1) then
					button:SetPoint("TOP", self, "TOP", 0, -totemSpace)
				elseif lastButton then
					button:SetPoint("TOP", lastButton, "BOTTOM", 0, -totemSpace)
				end
			elseif(totemGrowth == "HORIZONTAL" and totemSort == "DESCENDING") then
				if(i == 1) then
					button:SetPoint("RIGHT", self, "RIGHT", -totemSpace, 0)
				elseif lastButton then
					button:SetPoint("RIGHT", lastButton, "LEFT", -totemSpace, 0)
				end
			else
				if(i == 1) then
					button:SetPoint("BOTTOM", self, "BOTTOM", 0, totemSpace)
				elseif lastButton then
					button:SetPoint("BOTTOM", lastButton, "TOP", 0, totemSpace)
				end
			end
		end
	end

	local calcWidth, calcHeight;
	if(totemGrowth == "HORIZONTAL") then
		calcWidth = ((totemSize * MAX_TOTEMS) + (totemSpace * MAX_TOTEMS) + totemSpace);
		calcHeight = (totemSize + (totemSpace * 2));
	else
		calcWidth = (totemSize + (totemSpace * 2));
		calcHeight = ((totemSize * MAX_TOTEMS) + (totemSpace * MAX_TOTEMS) + totemSpace);
	end

	self:SetSize(calcWidth, calcHeight);
	self:Refresh()
end

local Totems_OnEnter = function(self)
	if(not self:IsVisible()) then return end
	GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMRIGHT')
	GameTooltip:SetTotem(self:GetID())
end

local Totems_OnLeave = function()
	GameTooltip:Hide()
end

local Totems_OnEvent = function(self, event, ...)
	self:Refresh()
end

local _hook_TotemFrame_OnUpdate = function()
	for i=1, MAX_TOTEMS do
		local slot = TOTEM_PRIORITIES[i]
		local blizztotem = _G["TotemFrameTotem"..slot]
		local tslot = blizztotem.slot
		if(tslot and tslot > 0) then
			local anchor = _G["SVUI_TotemBarTotem"..tslot]
			blizztotem:ClearAllPoints()
			blizztotem:SetAllPoints(anchor)
			blizztotem:SetFrameStrata(anchor:GetFrameStrata())
			blizztotem:SetFrameLevel(anchor:GetFrameLevel() + 99)
		end
	end
end

function MOD:InitializeTotemBar()
	if(not SV.db.ActionBars.Totem.enable) then return; end

	local xOffset = SV.db.Dock.dockLeftWidth + 12

	Totems:SetPoint("BOTTOMLEFT", SV.Screen, "BOTTOMLEFT", xOffset, 40)

	for i = 1, MAX_TOTEMS do
		local slot = TOTEM_PRIORITIES[i]
		local totem = CreateFrame("Button", "SVUI_TotemBarTotem"..slot, Totems)
		totem:SetFrameStrata("BACKGROUND")
		totem:SetID(slot)
		totem:SetStyle("Frame", "Icon")
		totem:Hide()

		totem.Icon = totem:CreateTexture(nil, "ARTWORK")
		totem.Icon:InsetPoints()
		totem.Icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
		totem.CD = CreateFrame("Cooldown", "SVUI_TotemBarTotem"..slot.."Cooldown", totem, "CooldownFrameTemplate")
		totem.CD:SetReverse(true)

		totem.Anchor = CreateFrame("Frame", nil, totem)
		totem.Anchor:SetAllPoints()

		Totems[i] = totem
	end

	Totems:Show()
	TotemFrame:Show()
	TotemFrame.Hide = TotemFrame.Show
	_G.TotemFrame_AdjustPetFrame = SV.fubar
	hooksecurefunc("TotemFrame_Update", _hook_TotemFrame_OnUpdate)

	Totems:RegisterEvent("PLAYER_TOTEM_UPDATE")
	Totems:RegisterEvent("PLAYER_ENTERING_WORLD")
	Totems:SetScript("OnEvent", Totems_OnEvent)

	Totems:Update()

	SV:NewAnchor(Totems, MOVER_NAME)
end
