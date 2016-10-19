--[[
##########################################################
S V U I   By: S.Jackson
##########################################################
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local unpack    = _G.unpack;
local select    = _G.select;
local pairs     = _G.pairs;
local type      = _G.type;
local tostring  = _G.tostring;
local tonumber  = _G.tonumber;
local tinsert   = _G.tinsert;
local tremove   = _G.tremove;
local string    = _G.string;
local math      = _G.math;
local bit       = _G.bit;
local table     = _G.table;
--[[ STRING METHODS ]]--
local format, find, lower, match = string.format, string.find, string.lower, string.match;
--[[ MATH METHODS ]]--
local abs, ceil, floor, round = math.abs, math.ceil, math.floor, math.round;  -- Basic
local fmod, modf, sqrt = math.fmod, math.modf, math.sqrt;   -- Algebra
local atan2, cos, deg, rad, sin = math.atan2, math.cos, math.deg, math.rad, math.sin;  -- Trigonometry
local min, huge, random = math.min, math.huge, math.random;  -- Uncommon
local sqrt2, max = math.sqrt(2), math.max;
--[[ TABLE METHODS ]]--
local tcopy, twipe, tsort, tconcat, tdump = table.copy, table.wipe, table.sort, table.concat, table.dump;
--[[ BINARY METHODS ]]--
local band = bit.band;
--BLIZZARD API
local InCombatLockdown      = _G.InCombatLockdown;
local CreateFrame           = _G.CreateFrame;
local SetMapToCurrentZone   = _G.SetMapToCurrentZone;
local GetTime               = _G.GetTime;
local GameTooltip           = _G.GameTooltip;
local UnitName              = _G.UnitName;
local UnitRace              = _G.UnitRace;
local UnitAura              = _G.UnitAura;
local UnitLevel             = _G.UnitLevel;
local UnitClass             = _G.UnitClass;
local UnitIsUnit            = _G.UnitIsUnit;
local UnitExists            = _G.UnitExists;
local UnitInRaid            = _G.UnitInRaid;
local UnitInParty           = _G.UnitInParty;
local UnitGUID              = _G.UnitGUID;
local UnitIsPVP             = _G.UnitIsPVP;
local UnitIsDND             = _G.UnitIsDND;
local UnitIsAFK             = _G.UnitIsAFK;
local GetItemInfo           = _G.GetItemInfo;
local GetItemCount          = _G.GetItemCount;
local GetItemQualityColor   = _G.GetItemQualityColor;
local ERR_NOT_IN_COMBAT     = _G.ERR_NOT_IN_COMBAT;
local RAID_CLASS_COLORS     = _G.RAID_CLASS_COLORS;
local CUSTOM_CLASS_COLORS   = _G.CUSTOM_CLASS_COLORS;

--[[  CONSTANTS ]]--

_G.BINDING_HEADER_SVUITRACK = "Supervillain UI: Track-O-Matic";
_G.BINDING_NAME_SVUITRACK_DOODAD = "Toggle Tracking Device";
--[[
##########################################################
GET ADDON DATA
##########################################################
]]--
local SV = _G["SVUI"];
local L = SV.L;
local PLUGIN = select(2, ...)
local CONFIGS = SV.defaults[PLUGIN.Schema];
--[[
##########################################################
LOCALS
##########################################################
]]--
local NewHook = hooksecurefunc;
local playerGUID = UnitGUID('player')
local classColor = RAID_CLASS_COLORS
--[[
##########################################################
BUILD
##########################################################
]]--
function SVUIToggleTrackingDoodad()
    if(not SVUI_UnitTrackingCompass.Trackable) then
        SVUI_UnitTrackingCompass.Trackable = true
        if((UnitInParty("target") or UnitInRaid("target")) and not UnitIsUnit("target", "player")) then
            SVUI_UnitTrackingCompass:Show()
        end
        SV:AddonMessage("Tracking Device |cff00FF00Enabled|r")
    else
        SVUI_UnitTrackingCompass.Trackable = false
        SVUI_UnitTrackingCompass:Hide()
        SV:AddonMessage("Tracking Device |cffFF0000Disabled|r")
    end
end
--[[
##########################################################
MAIN MOVABLE TRACKER
##########################################################
]]--
function PLUGIN:PLAYER_TARGET_CHANGED()
    if not SVUI_UnitTrackingCompass then return end
    if((UnitInParty("target") or UnitInRaid("target")) and not UnitIsUnit("target", "player")) then
        SVUI_UnitTrackingCompass.Trackable = true
        SVUI_UnitTrackingCompass:Show()
    else
        SVUI_UnitTrackingCompass.Trackable = false
        SVUI_UnitTrackingCompass:Hide()
    end
end

local Rotate_Arrow = function(self, angle)
    local radius, ULx, ULy, LLx, LLy, URx, URy, LRx, LRy

    radius = angle - 0.785398163
    URx = 0.5 + cos(radius) / sqrt2
    URy =  0.5 + sin(radius) / sqrt2
    -- (-1)
    radius = angle + 0.785398163
    LRx = 0.5 + cos(radius) / sqrt2
    LRy =  0.5 + sin(radius) / sqrt2
    -- 1
    radius = angle + 2.35619449
    LLx = 0.5 + cos(radius) / sqrt2
    LLy =  0.5 + sin(radius) / sqrt2
    -- 3
    radius = angle + 3.92699082
    ULx = 0.5 + cos(radius) / sqrt2
    ULy =  0.5 + sin(radius) / sqrt2
    -- 5

    self.Arrow:SetTexCoord(ULx, ULy, LLx, LLy, URx, URy, LRx, LRy);
end

local UnitTracker_OnUpdate = function(self, elapsed)
    if self.elapsed and self.elapsed > (self.throttle or 0.08) then
        if(self.Trackable) then
            local distance, angle = TriangulateUnit("target", true)
            if not angle then
                self.throttle = 4
                self.Arrow:SetAlpha(0)
                self.Radar:SetVertexColor(0.8,0.1,0.1,0.15)
                -- self.Border:SetVertexColor(1,0,0,0.15)
                self.BG:SetVertexColor(1,0,0,0.15)
            else
                self.throttle = 0.08
                local range = floor(distance)
                self:Spin(angle)
                if(range > 0) then
                    self.Arrow:SetAlpha(1)
                    self.Radar:SetAlpha(1)
                    self.Border:Show()
                    self.BG:SetAlpha(1)
                    if(range > 100) then
                        self.Arrow:SetVertexColor(1,0.1,0.1,0.4)
                        self.Radar:SetVertexColor(0.8,0.1,0.1,0.25)
                        -- self.Border:SetVertexColor(0.5,0.2,0.1,0.25)
                        self.BG:SetVertexColor(0.8,0.4,0.1,0.6)
                    elseif(range > 40) then
                        self.Arrow:SetVertexColor(1,0.8,0.1,0.6)
                        self.Radar:SetVertexColor(0.8,0.8,0.1,0.5)
                        -- self.Border:SetVertexColor(0.5,0.5,0.1,0.8)
                        self.BG:SetVertexColor(0.4,0.8,0.1,0.5)
                    else
                        self.Arrow:SetVertexColor(0.1,1,0.8,0.9)
                        self.Radar:SetVertexColor(0.1,0.8,0.8,0.75)
                        -- self.Border:SetVertexColor(0.1,0.5,0.1,1)
                        self.BG:SetVertexColor(0.1,0.8,0.1,0.75)
                    end
                    self.Range:SetText(range)
                else
                    self.Arrow:SetVertexColor(0.1,0.1,0.1,0)
                    self.Radar:SetVertexColor(0.1,0.1,0.1,0)
                    -- self.Border:SetVertexColor(0.1,0.1,0.1,0)
                    self.BG:SetVertexColor(0.1,0.1,0.1,0)
                    self.Arrow:SetAlpha(0)
                    self.Radar:SetAlpha(0)
                    self.Border:Hide()
                    self.BG:SetAlpha(0)
                    self.Range:SetText("")
                end
            end
        else
            self:Hide()
        end
        self.elapsed = 0
    else
        self.elapsed = (self.elapsed or 0) + elapsed
    end
end

local QuestTracker_OnUpdate = function(self, elapsed)
    if self.elapsed and self.elapsed > (self.throttle or 0.08) then
        if(self.questID) then
            local distance, angle = TriangulateQuest(self.questID)
            --print(angle)
            if not angle then
                self.questID = nil
                self.throttle = 4
                self.Arrow:SetAlpha(0)
                self.BG:SetVertexColor(0.1,0.1,0.1,0)
                self.Range:SetTextColor(1,1,1,1)
            else
                self.throttle = 0.08
                local range = floor(distance)
                self:Spin(angle)
                if(range > 25) then
                    self.Arrow:SetAlpha(1)
                    self.BG:SetAlpha(1)
                    if(range > 100) then
                        self.BG:SetVertexColor(0.8,0.1,0.1,1)
                        self.Range:SetTextColor(1,0.5,0.5,1)
                    elseif(range > 40) then
                        self.BG:SetVertexColor(0.8,0.8,0.1,1)
                        self.Range:SetTextColor(1,1,0.5,1)
                    else
                        self.BG:SetVertexColor(0.1,0.8,0.1,1)
                        self.Range:SetTextColor(0.5,1,0.5,1)
                    end
                    self.Range:SetText("Distance: " .. range .. " Yards")
                else
                    self.BG:SetVertexColor(0.1,0.1,0.1,0)
                    self.Range:SetTextColor(1,1,1,1)
                    self.Arrow:SetAlpha(0)
                    self.BG:SetAlpha(0)
                    self.Range:SetText("")
                end
            end
        else
            self:Hide()
            self:SetScript("OnUpdate", nil)
        end
        self.elapsed = 0
    else
        self.elapsed = (self.elapsed or 0) + elapsed
    end
end

local StartTrackingQuest = function(self, questID)
    if(questID) then
        if(not WorldMapFrame:IsShown()) then
            SetMapToCurrentZone()
        end
        self.Compass.questID = questID
        self.Compass:Show()
        self.Compass:SetScript("OnUpdate", QuestTracker_OnUpdate)
    else
        self.Compass.questID = nil
        self.Compass:Hide()
        self.Compass:SetScript("OnUpdate", nil)
    end
end

function SV:AddQuestCompass(parent, anchor)
    if anchor.Compass then return end
    local compass = CreateFrame("Frame", nil, parent)
    compass:SetAllPoints(anchor)
    compass:SetFrameLevel(anchor:GetFrameLevel() + 99)
    compass.BG = compass:CreateTexture(nil, 'BACKGROUND')
    compass.BG:InsetPoints(compass)
    compass.BG:SetTexture([[Interface\AddOns\SVUI_TrackOMatic\artwork\QUEST-COMPASS-BG]])
    compass.BG:SetVertexColor(0.1, 0.3, 0.4)
    compass.Arrow = compass:CreateTexture(nil, 'BORDER')
    compass.Arrow:SetAllPoints(compass)
    compass.Arrow:SetTexture([[Interface\AddOns\SVUI_TrackOMatic\artwork\QUEST-COMPASS-ARROW]])
    compass.Range = compass:CreateFontString(nil, 'ARTWORK')
    compass.Range:SetPoint("CENTER", compass, "CENTER", 0, 0)
    compass.Range:SetFontObject(SVUI_Font_Tracking);
    compass.Range:SetTextColor(1, 1, 1, 0.75)
    compass.Spin = Rotate_Arrow
    compass:Hide()

    anchor.Compass = compass
    anchor.StartTracking = StartTrackingQuest
    anchor.StopTracking = function(self) self.Compass:SetScript("OnUpdate", nil) end
end
--[[
##########################################################
CORE
##########################################################
]]--
function PLUGIN:ReLoad()
    local frameSize = CONFIGS.size or 70
    local arrowSize = frameSize * 0.5
    local frame = _G["SVUI_UnitTrackingCompass"]

    frame:SetSize(frameSize, frameSize)
    frame.Arrow:SetSize(arrowSize, arrowSize)
end

function PLUGIN:Load()
    CONFIGS = SV.db[self.Schema];
    local UNIT_TRACKER = SVUI_UnitTrackingCompass
    local TRACKER_TARGET = SVUI_Target

    if(UNIT_TRACKER) then
        UNIT_TRACKER.Border:SetGradient(unpack(SV.media.gradient.special))
        UNIT_TRACKER.Arrow:SetVertexColor(0.1, 0.8, 0.8)
        UNIT_TRACKER.Range:SetTextColor(1, 1, 1, 0.75)
        UNIT_TRACKER.Spin = Rotate_Arrow

        UNIT_TRACKER:RegisterForDrag("LeftButton");
        UNIT_TRACKER:SetScript("OnUpdate", UnitTracker_OnUpdate)

        SV.Animate:Orbit(UNIT_TRACKER.Radar, 8, true)

        UNIT_TRACKER:Hide()

        if(TRACKER_TARGET) then
            UNIT_TRACKER:SetParent(TRACKER_TARGET)
        end
        UNIT_TRACKER:SetPoint("CENTER", UIParent, "CENTER", 0, -200)

        self:RegisterEvent("PLAYER_TARGET_CHANGED")
    end

    self:EnableGPS()
end
