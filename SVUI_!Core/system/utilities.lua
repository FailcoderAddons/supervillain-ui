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
local table         = _G.table;
local string        = _G.string;
local math          = _G.math;
local tremove       = _G.tremove;
local twipe         = _G.wipe;
--[[ STRING METHODS ]]--
local lower, upper = string.lower, string.upper;
local find, format, len, split = string.find, string.format, string.len, string.split;
local match, sub, join = string.match, string.sub, string.join;
local gmatch, gsub = string.gmatch, string.gsub;
--[[ MATH METHODS ]]--
local abs, ceil, floor, round, mod, modf = math.abs, math.ceil, math.floor, math.round, math.fmod, math.modf;  -- Basic
--[[ TABLE METHODS ]]--
local twipe, tsort = table.wipe, table.sort;
--BLIZZARD API
local CreateFrame           = _G.CreateFrame;
local InCombatLockdown      = _G.InCombatLockdown;
local GameTooltip           = _G.GameTooltip;
local ReloadUI              = _G.ReloadUI;
local hooksecurefunc        = _G.hooksecurefunc;
--[[
##########################################################
GET ADDON DATA
##########################################################
]]--
local SV = select(2, ...)
local L = SV.L
--[[
##########################################################
FRAME VISIBILITY MANAGEMENT
##########################################################
]]--
do
    local FRAMELIST = {};

    function SV:ManageVisibility(frame)
        if(not frame) then return end
        local parent = UIParent;
        if(frame.GetParent) then
            parent = frame:GetParent();
        end
        local frameCount = #FRAMELIST + 1;
        FRAMELIST[frameCount] = {frame = frame, parent = parent};
    end

    function SV:AuditVisibility(hidden)
        if(hidden) then
          self.NeedsFrameAudit = true
          if(InCombatLockdown()) then return end
          for i=1, #FRAMELIST do
            local data = FRAMELIST[i]
            data.frame:SetParent(self.Hidden)
          end
        else
          if(InCombatLockdown()) then return end
          for i=1, #FRAMELIST do
            local data = FRAMELIST[i]
            data.frame:SetParent(data.parent or UIParent)
          end
          self.NeedsFrameAudit = false
        end
    end
end
--[[
##########################################################
MISC UTILITY FUNCTIONS
##########################################################
]]--
local PlayerClass = select(2,UnitClass("player"));
local PlayerName = UnitName("player");

function SV:DisbandRaidGroup()
    if InCombatLockdown() then return end
    if UnitInRaid("player") then
        for i = 1, GetNumGroupMembers() do
            local name, _, _, _, _, _, _, online = GetRaidRosterInfo(i)
            if(online and (name ~= PlayerName)) then
                UninviteUnit(name)
            end
        end
    else
        for i = MAX_PARTY_MEMBERS, 1, -1 do
            if UnitExists("party"..i) then
                UninviteUnit(UnitName("party"..i))
            end
        end
    end
    LeaveParty()
end

function SV:PlayerInfoUpdate()
    local spec = GetSpecialization();
    if not spec then return end
    self.CurrentSpec = spec

    local roleToken = GetSpecializationRole(spec);
    local actualRole = roleToken;
    if(roleToken == "DAMAGER") then
        local intellect = select(2, UnitStat("player", 4))
        local agility = select(2, UnitStat("player", 2))
        local baseAP, posAP, negAP = UnitAttackPower("player")
        local totalAP = baseAP  +  posAP  +  negAP;
        if totalAP > intellect or agility > intellect then
          actualRole = "MELEE"
        else
          actualRole = "CASTER"
        end
    elseif(roleToken == "HEALER") then
      actualRole = "CASTER"
    end

    if((self.SpecificClassRole ~= actualRole) or (self.ClassRole ~= roleToken)) then
        self.SpecificClassRole = actualRole;
        self.ClassRole = roleToken;
        SV.Events:Trigger("PLAYER_ROLE_CHANGED")
    end

    self:GearSwap()
end
--[[
##########################################################
POSITIONING UTILITY FUNCTIONS
##########################################################
]]--
SV.PointIndexes = {
    ["TOP"] = "TOP",
    ["BOTTOM"] = "BOTTOM",
    ["LEFT"] = "LEFT",
    ["RIGHT"] = "RIGHT",
    ["TOPRIGHT"] = "UP AND RIGHT",
    ["TOPLEFT"] = "UP AND LEFT",
    ["BOTTOMRIGHT"] = "DOWN AND RIGHT",
    ["BOTTOMLEFT"] = "DOWN AND LEFT",
    ["CENTER"] = "CENTER",
    ["RIGHTTOP"] = "RIGHT AND UP",
    ["LEFTTOP"] = "LEFT AND UP",
    ["RIGHTBOTTOM"] = "RIGHT AND DOWN",
    ["LEFTBOTTOM"] = "LEFT AND DOWN",
    ["INNERRIGHT"] = "INNER RIGHT",
    ["INNERLEFT"] = "INNER LEFT",
    ["INNERTOPRIGHT"] = "INNER TOP RIGHT",
    ["INNERTOPLEFT"] = "INNER TOP LEFT",
    ["INNERBOTTOMRIGHT"] = "INNER BOTTOM RIGHT",
    ["INNERBOTTOMLEFT"] = "INNER BOTTOM LEFT",
}

do
    local _reversed = {
        TOP = "BOTTOM",
        BOTTOM = "TOP",
        LEFT = "RIGHT",
        RIGHT = "LEFT",
        TOPRIGHT = "TOPLEFT",
        TOPLEFT = "TOPRIGHT",
        BOTTOMRIGHT = "BOTTOMLEFT",
        BOTTOMLEFT = "BOTTOMRIGHT",
    }

    local _inverted = {
        TOP = "BOTTOM",
        BOTTOM = "TOP",
        LEFT = "RIGHT",
        RIGHT = "LEFT",
        TOPRIGHT = "BOTTOMRIGHT",
        TOPLEFT = "BOTTOMLEFT",
        BOTTOMRIGHT = "TOPRIGHT",
        BOTTOMLEFT = "TOPLEFT",
        CENTER = "CENTER",
        RIGHTTOP = "TOPLEFT",
        LEFTTOP = "TOPRIGHT",
        RIGHTBOTTOM = "BOTTOMLEFT",
        LEFTBOTTOM = "BOTTOMRIGHT",
        INNERRIGHT = "RIGHT",
        INNERLEFT = "LEFT",
        INNERTOPRIGHT = "TOPRIGHT",
        INNERTOPLEFT = "TOPLEFT",
        INNERBOTTOMRIGHT = "BOTTOMRIGHT",
        INNERBOTTOMLEFT = "BOTTOMLEFT",
    }
    setmetatable(_inverted, { __index = function(t, k)
        return "CENTER"
    end})

    local _translated = {
        TOP = "TOP",
        BOTTOM = "BOTTOM",
        LEFT = "LEFT",
        RIGHT = "RIGHT",
        TOPRIGHT = "TOPRIGHT",
        TOPLEFT = "TOPLEFT",
        BOTTOMRIGHT = "BOTTOMRIGHT",
        BOTTOMLEFT = "BOTTOMLEFT",
        CENTER = "CENTER",
        RIGHTTOP = "TOPRIGHT",
        LEFTTOP = "TOPLEFT",
        RIGHTBOTTOM = "BOTTOMRIGHT",
        LEFTBOTTOM = "BOTTOMLEFT",
        INNERRIGHT = "RIGHT",
        INNERLEFT = "LEFT",
        INNERTOPRIGHT = "TOPRIGHT",
        INNERTOPLEFT = "TOPLEFT",
        INNERBOTTOMRIGHT = "BOTTOMRIGHT",
        INNERBOTTOMLEFT = "BOTTOMLEFT",
    }
    setmetatable(_translated, { __index = function(t, k)
        return "CENTER"
    end})

    function SV:GetReversePoint(point)
        return _inverted[point];
    end

    function SV:SetReversePoint(frame, point, target, x, y)
        if((not frame) or (not point)) then return; end
        target = target or frame:GetParent()
        if(not target) then print(frame:GetName()) return; end
        local anchor = _inverted[point];
        local relative = _translated[point];
        x = x or 0;
        y = y or 0;
        frame:SetPoint(anchor, target, relative, x, y)
        --[[ auto-set specific properties to save on logic ]]--
        frame.initialAnchor = anchor;
    end
end

function SV:GetScreenXY(frame)
    local screenHeight = GetScreenHeight();
    local screenWidth = GetScreenWidth();
    local screenX, screenY = frame:GetCenter();
    local isLeft = (screenX < (screenHeight * 0.5));
    if (screenY < (screenWidth * 0.5)) then
        if(isLeft) then
            return "BOTTOMLEFT", "TOPLEFT"
        else
            return "BOTTOMRIGHT", "TOPRIGHT"
        end
    else
        if(isLeft) then
            return "TOPLEFT", "BOTTOMLEFT"
        else
            return "TOPRIGHT", "BOTTOMRIGHT"
        end
    end
end

function SV:AnchorToCursor(frame)
    local x, y = GetCursorPosition()
    local vHold = (UIParent:GetHeight() * 0.33)
    local scale = self.Screen:GetEffectiveScale()
    local initialAnchor = "CENTER"
    local mod = 0

    if(y > (vHold * 2)) then
        initialAnchor = "TOPLEFT"
        mod = -12
    elseif(y < vHold) then
        initialAnchor = "BOTTOMLEFT"
        mod = 12
    end

    frame:ClearAllPoints()
    frame:SetPoint(initialAnchor, self.Screen, "BOTTOMLEFT", (x  /  scale), (y  /  scale) + mod)
end
--[[
##########################################################
TIME UTILITIES
##########################################################
]]--
local SECONDS_PER_HOUR = 60 * 60
local SECONDS_PER_DAY = 24 * SECONDS_PER_HOUR

function SV:ParseSeconds(seconds)
    local negative = ""

    if not seconds then
        seconds = 0
    end

    if seconds < 0 then
        negative = "-"
        seconds = -seconds
    end
    local L_DAY_ONELETTER_ABBR = _G.DAY_ONELETTER_ABBR:gsub("%s*%%d%s*", "")

    if not seconds or seconds >= SECONDS_PER_DAY * 36500 then -- 100 years
        return ("%s**%s **:**"):format(negative, L_DAY_ONELETTER_ABBR)
    elseif seconds >= SECONDS_PER_DAY then
        return ("%s%d%s %d:%02d"):format(negative, seconds / SECONDS_PER_DAY, L_DAY_ONELETTER_ABBR, math.fmod(seconds / SECONDS_PER_HOUR, 24), math.fmod(seconds / 60, 60))
    else
        return ("%s%d:%02d:%02d"):format(negative, seconds / SECONDS_PER_HOUR, math.fmod(seconds / 60, 60), math.fmod(seconds, 60))
    end
end
--[[
##########################################################
CONTROL UTILITIES
##########################################################
]]--
local Frame_ForceHide = function(self, locked)
  if(locked) then
    self.Show = self.___HideFunc
    self.___visibilityLocked = true
  elseif(self.___visibilityLocked) then
    self.Show = self.___ShowFunc
    self.___visibilityLocked = nil
  end
end

local Frame_ForceShow = function(self, locked)
  if(locked) then
    self.Hide = self.___ShowFunc
    self.___visibilityLocked = true
  elseif(self.___visibilityLocked) then
    self.Hide = self.___HideFunc
    self.___visibilityLocked = nil
  end
end

function SV:SetFrameVisibilityLocks(frame)
    if(frame.___ShowFunc or frame.___HideFunc or frame.ForceHide or frame.ForceShow) then return end
    local fnShow = frame.Show
    local fnHide = frame.Hide
    frame.___ShowFunc = fnShow
    frame.___HideFunc = fnHide
    frame.ForceHide = Frame_ForceHide
    frame.ForceShow = Frame_ForceShow
end
--[[
##########################################################
MISC HELPERS
##########################################################
]]--
do
  local COPPER_PATTERN = "%d" .. L.copperabbrev;
  local SILVER_PATTERN = "%d" .. L.silverabbrev .. " %.2d" .. L.copperabbrev;
  local GOLD_PATTERN = "%s" .. L.goldabbrev .. " %.2d" .. L.silverabbrev .. " %.2d" .. L.copperabbrev;
  local SILVER_ABBREV_PATTERN = "%d" .. L.silverabbrev;
  local GOLD_ABBREV_PATTERN = "%s" .. L.goldabbrev;

  local function _formatCurrency(amount, short)
  	if not amount then return end
  	local gold, silver, copper = floor(abs(amount/10000)), abs(mod(amount/100,100)), abs(mod(amount,100))
  	if(short) then
  		if gold ~= 0 then
  			gold = BreakUpLargeNumbers(gold)
  			return GOLD_ABBREV_PATTERN:format(gold)
  		elseif silver ~= 0 then
  			return SILVER_ABBREV_PATTERN:format(silver)
  		else
  			return COPPER_PATTERN:format(copper)
  		end
  	else
  		if gold ~= 0 then
  			gold = BreakUpLargeNumbers(gold)
  			return GOLD_PATTERN:format(gold, silver, copper)
  		elseif silver ~= 0 then
  			return SILVER_PATTERN:format(silver, copper)
  		else
  			return COPPER_PATTERN:format(copper)
  		end
  	end
  end

  function SV:FormatCurrency(...)
    return _formatCurrency(...)
  end
end
