--[[
##########################################################
S V U I   By: Failcoder
##########################################################
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--LUA
local unpack        = unpack;
local select        = select;
local pairs         = pairs;
local type          = type;
local rawset        = rawset;
local rawget        = rawget;
local tostring      = tostring;
local error         = error;
local next          = next;
local pcall         = pcall;
local getmetatable  = getmetatable;
local setmetatable  = setmetatable;
local assert        = assert;
--BLIZZARD
local _G            = _G;
local tinsert       = _G.tinsert;
local tremove       = _G.tremove;
local twipe         = _G.wipe;
--STRING
local string        = string;
local format        = string.format;
local find          = string.find;
local match         = string.match;
--MATH
local math          = math;
local min, random   = math.min, math.random;
--TABLE
local table         = table;
--[[ LOCALIZED BLIZZ FUNCTIONS ]]--
local NewHook = hooksecurefunc;
--[[
##########################################################
GET ADDON DATA AND TEST FOR oUF
##########################################################
]]--
local SV = _G['SVUI']
local L = SV.L;
local LSM = _G.LibStub("LibSharedMedia-3.0")
local MOD = SV.UnitFrames

if(not MOD) then return end

local oUF_SVUI = MOD.oUF
assert(oUF_SVUI, "SVUI UnitFrames: unable to locate oUF.")
--[[
##########################################################
LOCALS
##########################################################
]]--
local _PRIVATE_ENVIRONMENT;
local _PRIVATE_FUNCTIONS = {};
local _PRIVATE_TAGS = {};

local _PRIVATE_METHODS = {
	UnitPower = function(unit, g)
		-- if unit:find('target') or unit:find('focus') then
		-- 	return UnitPower(unit, g)
		-- end
		return random(1, UnitPowerMax(unit, g)or 1)
	end,
	UnitHealth = function(unit)
		-- if unit:find('target') or unit:find('focus') then
		-- 	return UnitHealth(unit)
		-- end
		return random(1, UnitHealthMax(unit))
	end,
	UnitName = function(unit)
		-- if unit:find('target') or unit:find('focus') then
		-- 	return UnitName(unit)
		-- end
		return "Dummy"
	end,
	UnitClass = function(unit)
		-- if unit:find('target') or unit:find('focus') then
		-- 	return UnitClass(unit)
		-- end
		local token = CLASS_SORT_ORDER[random(1, #(CLASS_SORT_ORDER))]
		return LOCALIZED_CLASS_NAMES_MALE[token], token
	end,
	Hex = function(r, g, b)
		if not r then return end
		if type(r) == "table" then
			if r.r then r, g, b = r.r, r.g, r.b else r, g, b = unpack(r) end
		end
		return ("|cff%02x%02x%02x"):format(r * 255, g * 255, b * 255)
	end,
	ColorGradient = oUF_SVUI.ColorGradient,
};

local AttributeChangeHook = function(self)
	if not self:GetParent().forceShow and not self.forceShow then return end
	if not self:IsShown() then return end

	local key = self.___groupkey
	local db = SV.db.UnitFrames[key]

	local newIndex = -4;
	if self:GetAttribute("startingIndex") ~= newIndex then
		self:SetAttribute("startingIndex", newIndex)
		self.isForced = true;
		self:EnableChildren()
	end
end;

local function SetProxyEnv()
	if(_PRIVATE_ENVIRONMENT ~= nil) then return end

	_PRIVATE_ENVIRONMENT = setmetatable(_PRIVATE_METHODS, { __index = _G, __newindex = function(_,key,value) _G[key] = value end });

	for i=1, 30 do
		_PRIVATE_TAGS['name:'..i] = oUF_SVUI.Tags.Methods['name:'..i]
	end

	_PRIVATE_TAGS['name:color'] = oUF_SVUI.Tags.Methods['name:color']
	_PRIVATE_TAGS['name:grid'] = oUF_SVUI.Tags.Methods['name:grid']
	_PRIVATE_TAGS['health:color'] = oUF_SVUI.Tags.Methods['health:color']
	_PRIVATE_TAGS['health:current'] = oUF_SVUI.Tags.Methods['health:current']
	_PRIVATE_TAGS['health:deficit'] = oUF_SVUI.Tags.Methods['health:deficit']
	_PRIVATE_TAGS['health:curpercent'] = oUF_SVUI.Tags.Methods['health:curpercent']
	_PRIVATE_TAGS['health:curmax'] = oUF_SVUI.Tags.Methods['health:curmax']
	_PRIVATE_TAGS['health:curmax-percent'] = oUF_SVUI.Tags.Methods['health:curmax-percent']
	_PRIVATE_TAGS['health:max'] = oUF_SVUI.Tags.Methods['health:max']
	_PRIVATE_TAGS['health:percent'] = oUF_SVUI.Tags.Methods['health:percent']
	_PRIVATE_TAGS['power:color'] = oUF_SVUI.Tags.Methods['power:color']
	_PRIVATE_TAGS['power:current'] = oUF_SVUI.Tags.Methods['power:current']
	_PRIVATE_TAGS['power:deficit'] = oUF_SVUI.Tags.Methods['power:deficit']
	_PRIVATE_TAGS['power:curpercent'] = oUF_SVUI.Tags.Methods['power:curpercent']
	_PRIVATE_TAGS['power:curmax'] = oUF_SVUI.Tags.Methods['power:curmax']
	_PRIVATE_TAGS['power:curmax-percent'] = oUF_SVUI.Tags.Methods['power:curmax-percent']
	_PRIVATE_TAGS['power:max'] = oUF_SVUI.Tags.Methods['power:max']
	_PRIVATE_TAGS['power:percent'] = oUF_SVUI.Tags.Methods['power:percent']
end

function MOD:ViewEnemyFrames(unit, numGroup)
	if InCombatLockdown()then return end
	for i=1, numGroup do
		local unitName = unit..i
		local frame = self.Units[unitName]
		if(frame and frame.Allow) then
			if(not frame.isForced) then
				frame:Allow()
			else
				frame:Restrict()
			end
		end
	end
end

local function TransferVisibility(frame)
    for i = 1, select("#", frame:GetChildren()) do
        local child = select(i,frame:GetChildren())
		child.forceShowAuras = frame.forceShowAuras
		child.forceShowHighlights = frame.forceShowHighlights
    end
end

function MOD:ViewGroupFrames(headerFrame, setForced, setAuraForced, setHighlightForced)
	if InCombatLockdown() then return end
	if(not headerFrame) then return end
	SetProxyEnv()

	headerFrame.forceShow = setForced;
	headerFrame.forceShowAuras = setAuraForced;
	headerFrame.forceShowHighlights = setAuraForced or setHighlightForced;
	headerFrame.isForced = setForced;
	local raidToken = headerFrame.___groupkey

	if setForced then
		for _, func in pairs(_PRIVATE_TAGS) do
			if type(func) == "function" then
				if(not _PRIVATE_FUNCTIONS[func]) then
					_PRIVATE_FUNCTIONS[func] = getfenv(func)
					setfenv(func, _PRIVATE_ENVIRONMENT)
				end
			end
		end
		RegisterStateDriver(headerFrame, "visibility", "show")
		--print('Now Showing')
	else
		for func, fenv in pairs(_PRIVATE_FUNCTIONS)do
			setfenv(func, fenv)
			_PRIVATE_FUNCTIONS[func] = nil
		end

		local db = SV.db.UnitFrames[raidToken]
		RegisterStateDriver(headerFrame, "visibility", db.visibility)
		--print('Now: '..db.visibility)
		local eventScript = headerFrame:GetScript("OnEvent")
		if eventScript then
			eventScript(headerFrame, "PLAYER_ENTERING_WORLD")
		end
	end

	for i = 1, #headerFrame.groups do
		local groupFrame = headerFrame.groups[i]

		if(groupFrame:IsShown()) then
			groupFrame.forceShow = headerFrame.forceShow;
			groupFrame.forceShowAuras = headerFrame.forceShowAuras;
			groupFrame.forceShowHighlights = headerFrame.forceShowHighlights;
			groupFrame:HookScript("OnAttributeChanged", AttributeChangeHook)

			if setForced then
				groupFrame:SetAttribute("showRaid", nil)
				groupFrame:SetAttribute("showParty", nil)
				groupFrame:SetAttribute("showSolo", nil)

				AttributeChangeHook(groupFrame)
				groupFrame:Update()
			else
				groupFrame:SetAttribute("showRaid", true)
				groupFrame:SetAttribute("showParty", true)
				groupFrame:SetAttribute("showSolo", true)

				groupFrame:DisableChildren()
				groupFrame:SetAttribute("startingIndex", 1)
				groupFrame:Update()
			end
		end

		TransferVisibility(groupFrame)
	end

	headerFrame:SetVisibility()
	collectgarbage("collect")
end
