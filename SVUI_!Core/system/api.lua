--[[
##########################################################
S V U I   By: Failcoder
##########################################################
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local unpack    = _G.unpack;
local select    = _G.select;
local pairs     = _G.pairs;
local ipairs    = _G.ipairs;
local type      = _G.type;
local error     = _G.error;
local pcall     = _G.pcall;
local tostring          = _G.tostring;
local tonumber          = _G.tonumber;
local getmetatable      = _G.getmetatable;
local setmetatable      = _G.setmetatable;
local collectgarbage    = _G.collectgarbage;
local table     = _G.table;
local string    = _G.string;
local math      = _G.math;
local wipe      = _G.wipe;
local tremove       = _G.tremove;
--[[ MATH METHODS ]]--
local floor, abs, min, max = math.floor, math.abs, math.min, math.max;
local parsefloat, ceil = math.parsefloat, math.ceil;
--[[ STRING METHODS ]]--
local lower, upper = string.lower, string.upper;
--[[ TABLE METHODS ]]--
local tremove, tcopy, twipe, tsort, tconcat = table.remove, table.copy, table.wipe, table.sort, table.concat;
--BLIZZARD API
local CreateFrame           = _G.CreateFrame;
local InCombatLockdown      = _G.InCombatLockdown;
local GameTooltip           = _G.GameTooltip;
local ReloadUI              = _G.ReloadUI;
local GetTime               = _G.GetTime;
local hooksecurefunc        = _G.hooksecurefunc;
local IsAltKeyDown          = _G.IsAltKeyDown;
local IsShiftKeyDown        = _G.IsShiftKeyDown;
local IsControlKeyDown      = _G.IsControlKeyDown;
local IsModifiedClick       = _G.IsModifiedClick;
local PlaySound             = _G.PlaySound;
local PlaySoundFile         = _G.PlaySoundFile;
local SetCVar               = _G.SetCVar;
local GetCVar               = _G.GetCVar;
local GetCVarBool           = _G.GetCVarBool;
local SquareButton_SetIcon  = _G.SquareButton_SetIcon;
local RAID_CLASS_COLORS     = _G.RAID_CLASS_COLORS;
local CUSTOM_CLASS_COLORS   = _G.CUSTOM_CLASS_COLORS;
--[[
##########################################################
GET ADDON DATA
##########################################################
]]--
local SV = select(2, ...)
local L = SV.L;
local SVUILib = Librarian("Registry");
local MOD = SV:NewPackage("API", L["API"]);
--[[
##########################################################
LOCALS
##########################################################
]]--
local MAC_DISPLAY;
local BASE_MOD = 0.64;
local LIVE_UPDATE_FRAMES = {};
--[[
##########################################################
LOOKUP TABLE
##########################################################
]]--
MOD.Templates = {
    ["Default"]     = "SVUI_CoreStyle_Default",
    ["Transparent"] = "SVUI_CoreStyle_Transparent",
    ["Button"]      = "SVUI_CoreStyle_Button",
    ["EditBox"]     = "SVUI_CoreStyle_EditBox",
    ["CheckButton"] = "SVUI_CoreStyle_CheckButton",
    ["DockButton"]  = "SVUI_CoreStyle_DockButton",
    ["ActionSlot"]  = "SVUI_CoreStyle_ActionSlot",
    ["Lite"]        = "SVUI_CoreStyle_Lite",
    ["Icon"]        = "SVUI_CoreStyle_Icon",
    ["Bar"]         = "SVUI_CoreStyle_Bar",
    ["Inset"]       = "SVUI_CoreStyle_Inset",
    ["Blackout"]    = "SVUI_CoreStyle_Blackout",
    ["Component"]   = "SVUI_CoreStyle_Component",
    ["Paper"]       = "SVUI_CoreStyle_Paper",
    ["Container"]   = "SVUI_CoreStyle_Container",
    ["Pattern"]     = "SVUI_CoreStyle_Pattern",
    ["Premium"]     = "SVUI_CoreStyle_Premium",
    ["Model"]       = "SVUI_CoreStyle_Model",
    ["UnitLarge"]   = "SVUI_CoreStyle_UnitLarge",
    ["UnitSmall"]   = "SVUI_CoreStyle_UnitSmall",
    ["Window"]      = "SVUI_CoreStyle_Window",
    ["Window2"]     = "SVUI_CoreStyle_Window2",
};
MOD.Methods = {};
MOD.Concepts = {};
--[[
##########################################################
UI SCALING
##########################################################
]]--
local function ScreenUpdate()
    local rez = GetCVar("gxFullscreenResolution")
    local height = rez:match("%d+x(%d+)")
    local width = rez:match("(%d+)x%d+")
    local gxHeight = tonumber(height)
    local gxWidth = tonumber(width)
    local gxMod = (768 / gxHeight)
    local customScale = false;
    if(IsMacClient()) then
        if(not MAC_DISPLAY) then
            MAC_DISPLAY = SVUILib:NewGlobal("Display");
            if(not MAC_DISPLAY.Y or (MAC_DISPLAY.Y and type(MAC_DISPLAY.Y) ~= "number")) then
                MAC_DISPLAY.Y = gxHeight;
            end
            if(not MAC_DISPLAY.X or (MAC_DISPLAY.X and type(MAC_DISPLAY.X) ~= "number")) then
                MAC_DISPLAY.X = gxWidth;
            end
        end
        if(MAC_DISPLAY and MAC_DISPLAY.Y and MAC_DISPLAY.X) then
            if(gxHeight ~= MAC_DISPLAY.Y or gxWidth ~= MAC_DISPLAY.X) then
                gxHeight = MAC_DISPLAY.Y;
                gxWidth = MAC_DISPLAY.X;
            end
        end
    end

    local gxScale;
    if(SV.db.screen.advanced) then
        BASE_MOD = 0.64
        local ADJUSTED_SCALE = SV.db.screen.scaleAdjust;
        if(ADJUSTED_SCALE) then
            if(type(ADJUSTED_SCALE) ~= "number") then
                ADJUSTED_SCALE = tonumber(ADJUSTED_SCALE);
            end
            if(ADJUSTED_SCALE and ADJUSTED_SCALE ~= BASE_MOD) then
                BASE_MOD = ADJUSTED_SCALE;
                customScale = true;
            end
        end

        gxScale = BASE_MOD;
    else
        -- local default_autoscale = true;
		-- if(BlizzardOptionsPanel_GetCVarSafe("useUiScale") ~= 0) then
        --     default_autoscale = false;
		-- end
        if(SV.db.screen.autoScale) then
            gxScale = max(0.64, min(1.15, gxMod));
        else
            gxScale = max(0.64, min(1.15, GetCVar("uiScale") or UIParent:GetScale() or gxMod));
        end
    end

    return gxWidth, gxHeight, gxScale, customScale
end
--[[
##########################################################
APPENDED POSITIONING METHODS
##########################################################
]]--
local FIND_EDGES = {
    CENTER = function(frame, x, y)
        local xX,yY = frame:GetCenter();
        return (xX + x),(yY + y);
    end,
    TOP = function(frame, x, y)
        local yY = frame:GetTop() - UIParent:GetHeight() + y;
        return x,yY;
    end,
    TOPLEFT = function(frame, x, y)
        local xX = frame:GetLeft() + x;
        local yY = frame:GetTop() - UIParent:GetHeight() + y;
        return xX,yY;
    end,
    TOPRIGHT = function(frame, x, y)
        local xX = frame:GetRight() - UIParent:GetWidth() + x;
        local yY = frame:GetTop() - UIParent:GetHeight() + y;
        return xX,yY;
    end,
    BOTTOM = function(frame, x, y)
        local yY = frame:GetBottom() + y;
        return x,yY;
    end,
    BOTTOMLEFT = function(frame, x, y)
        local xX = frame:GetLeft() + x;
        local yY = frame:GetBottom() + y;
        return xX,yY;
    end,
    BOTTOMRIGHT = function(frame, x, y)
        local xX = frame:GetRight() - UIParent:GetWidth() + x;
        local yY = frame:GetBottom() + y;
        return xX,yY;
    end,
};

local function GetRelativeEdges(frame, anchor)
    local x,y = 0,0;
    if(FIND_EDGES[anchor]) then
        x,y = FIND_EDGES[anchor](frame);
    end
    return x,y;
end

local ModSize = function(self, width, height)
    if(type(width) == "number") then
        local h = (height and type(height) == "number") and height or width
        self:SetSize(width, h)
    end
end

local WrapPoints = function(self, parent, x, y)
    x = type(x) == "number" and x or 1
    y = y or x
    parent = parent or self:GetParent()
    if self:GetPoint() then
        self:ClearAllPoints()
    end
    self:SetPoint("TOPLEFT", parent, "TOPLEFT", -x, y)
    self:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", x, -y)
end

local InsetPoints = function(self, parent, x, y)
    x = type(x) == "number" and x or 1
    y = y or x
    parent = parent or self:GetParent()
    if self:GetPoint() then
        self:ClearAllPoints()
    end
    self:SetPoint("TOPLEFT", parent, "TOPLEFT", x, -y)
    self:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -x, y)
end

local SetSecurePoint = function(self, anchor1, parent, anchor2, x, y)
    local pX,pY = x,y;
    if(FIND_EDGES[anchor2]) then
        pX,pY = FIND_EDGES[anchor2](parent, x, y);
    end
    self:SetPoint(anchor1, UIParent, anchor2, pX, pY);
end

local SetAllSecurePoints = function(self, parent)
    local pX,pY = FIND_EDGES["TOPLEFT"](parent, 0, 0);
    local w,h = parent:GetSize();
    self:ClearAllPoints();
    self:SetPoint("TOPLEFT", UIParent, "TOPLEFT", pX, pY);
    self:SetSize(w,h);
end
--[[
##########################################################
APPENDED DESTROY METHODS
##########################################################
]]--
local _purgatory = CreateFrame("Frame", nil)
_purgatory:Hide()

local Die = function(self)
    if(self.UnregisterAllEvents) then
        self:UnregisterAllEvents()
        self:SetParent(_purgatory)
    else
        self:Hide()
        self.Show = SV.fubar
    end
end

local RemoveTextures = function(self, option)
    if((not self.GetNumRegions) or (self.Panel and (not self.Panel.CanBeRemoved))) then return end
    local region, layer, texture
    for i = 1, self:GetNumRegions()do
        region = select(i, self:GetRegions())
        if(region and (region:GetObjectType() == "Texture")) then

            layer = region:GetDrawLayer()
            texture = region:GetTexture()

            if(option) then
                if(type(option) == "boolean") then
                    if region.UnregisterAllEvents then
                        region:UnregisterAllEvents()
                        region:SetParent(_purgatory)
                    else
                        region.Show = region.Hide
                    end
                    region:Hide()
                elseif(type(option) == "string" and ((layer == option) or (texture ~= option))) then
                    region:SetTexture("")
                end
            else
                region:SetTexture("")
            end
        end
    end
end
--[[
##########################################################
SECURE FADING
##########################################################
]]--
local FRAMES_TO_HIDE = {};
local FRAMES_TO_SHOW = {};

local FadeEventManager_OnEvent = function(self, event)
    if(event == 'PLAYER_REGEN_ENABLED') then
        self:UnregisterEvent("PLAYER_REGEN_ENABLED")
        for frame in pairs(FRAMES_TO_HIDE) do
            frame:Hide()
        end
        wipe(FRAMES_TO_HIDE)
        for frame in pairs(FRAMES_TO_SHOW) do
            frame:Show()
        end
        wipe(FRAMES_TO_SHOW)
    end
end

local FadeEventManager = CreateFrame('Frame')
FadeEventManager:SetScript("OnEvent", FadeEventManager_OnEvent)

local SecureFade_OnUpdate = function(self, elasped)
    local frame = self.owner;
    if(frame) then
        local state = frame.___fadeset;
        state[4] = (state[4] or 0) + elasped;
        if(state[4] < state[3]) then

            if(frame.___fademode == "IN") then
                frame:SetAlpha((state[4] / state[3]) * (state[2] - state[1]) + state[1])
            elseif(frame.___fademode == "OUT") then
                frame:SetAlpha(((state[3] - state[4]) / state[3]) * (state[1] - state[2]) + state[2])
            end

        else
            state[4] = 0
            frame:SetAlpha(state[2])
            local canfade = (not InCombatLockdown()) or (InCombatLockdown() and (not frame:IsProtected()))
            if(frame.___fadehide) then
                if(canfade) then
                    frame:Hide()
                else
                    frame:SetAlpha(state[2])
                    FRAMES_TO_HIDE[frame] = true;
                    FadeEventManager:RegisterEvent("PLAYER_REGEN_ENABLED");
                end
            end

            if(frame.___fadefunc and canfade) then
                local _, catch = pcall(frame.___fadefunc, frame)
                if(not catch) then
                    frame.___fadefunc = nil
                end
            end

            self.Running = false;
            self:SetScript("OnUpdate", nil);
        end
    end
end

local SecureFadeIn = function(self, duration, alphaStart, alphaEnd)
    if(self.___visibilityLocked) then return end
    local alpha1 = alphaStart or 0;
    local alpha2 = alphaEnd or 1;
    local timer = duration or 0.1;

    local canfade = (not InCombatLockdown()) or (InCombatLockdown() and (not self:IsProtected()))
    if((not self:IsShown()) and canfade) then
        self:Show()
    end

    if((not self:IsShown()) and (not canfade)) then
        FRAMES_TO_SHOW[self] = true
    end

    if(self:IsShown() and self:GetAlpha() == alpha2) then return end
    if(not self.___fadehandler) then
        self.___fadehandler = CreateFrame("Frame", nil)
        self.___fadehandler.owner = self;
    end
    if(not self.___fademode or (self.___fademode and self.___fademode ~= "IN")) then
        if(FRAMES_TO_HIDE[self]) then
            FRAMES_TO_HIDE[self] = nil
        end

        self.___fademode = "IN";
        self.___fadehide = nil;
        self.___fadefunc = self.___fadeshowfunc;

        if(not self.___fadeset) then
            self.___fadeset = {};
        end
        self.___fadeset[1] = alpha1;
        self.___fadeset[2] = alpha2;
        self.___fadeset[3] = timer;

        self:SetAlpha(alpha1)
    end
    if(not self.___fadehandler.Running) then
        self.___fadehandler.Running = true;
        self.___fadehandler:SetScript("OnUpdate", SecureFade_OnUpdate)
    end
end

local SecureFadeOut = function(self, duration, alphaStart, alphaEnd, hideOnFinished)
    if(self.___visibilityLocked) then return end
    local alpha1 = alphaStart or 1;
    local alpha2 = alphaEnd or 0;
    local timer = duration or 0.1;

    if((not self:IsShown()) or self:GetAlpha() == alpha2) then return end
    if(not self.___fadehandler) then
        self.___fadehandler = CreateFrame("Frame", nil)
        self.___fadehandler.owner = self;
    end
    if(not self.___fademode or (self.___fademode and self.___fademode ~= "OUT")) then
        if(FRAMES_TO_SHOW[self]) then
            FRAMES_TO_SHOW[self] = nil
        end

        self.___fademode = "OUT";
        self.___fadehide = hideOnFinished;
        self.___fadefunc = self.___fadehidefunc;

        if(not self.___fadeset) then
            self.___fadeset = {};
        end

        self.___fadeset[1] = alpha1;
        self.___fadeset[2] = alpha2;
        self.___fadeset[3] = timer;

        self:SetAlpha(alpha1)
    end
    if(not self.___fadehandler.Running) then
        self.___fadehandler.Running = true;
        self.___fadehandler:SetScript("OnUpdate", SecureFade_OnUpdate)
    end
end

local SecureFadeCallback = function(self, callback, alwaysOnHide, alwaysOnShow)
    if(alwaysOnHide) then
        self.___fadehidefunc = callback;
    elseif(alwaysOnShow) then
        self.___fadeshowfunc = callback;
    else
        self.___fadefunc = callback;
    end
end
--[[
##########################################################
TEMPLATE INTERNAL HANDLERS
##########################################################
]]--
local HookPanelBorderColor = function(self,r,g,b,a)
    if self.BorderLeft then
        self.BorderLeft:SetVertexColor(r,g,b,a)
        self.BorderRight:SetVertexColor(r,g,b,a)
        self.BorderTop:SetVertexColor(r,g,b,a)
        self.BorderBottom:SetVertexColor(r,g,b,a)
    end
    if self.InnerGlow then
        self.InnerGlow:SetBackdropColor(r*0.25,g*0.25,b*0.25,0.5)
    end
    if self.Shadow then
        local alpha = self.Shadow:GetAttribute("shadowAlpha") or 0.5
        self.Shadow:SetBackdropBorderColor(r,g,b,alpha)
    end
end

local HookBackdrop = function(self,...)
    if(self.Panel) then
        self.Panel:SetBackdrop(...)
    end
end

local HookBackdropColor = function(self,r,g,b)
    if(self.Panel) then
        self.Panel:SetBackdropColor(r,g,b)
    end
end

local HookBackdropBorderColor = function(self,...)
    if(self.Panel) then
        self.Panel:SetBackdropBorderColor(...)
    end
end

local HookVertexColor = function(self,...)
    if(self.Panel) then
        self.Panel.Skin:SetVertexColor(...)
    end
end

local HookCustomBackdrop_TypeA = function(self)
    if(self.Panel) then
        local bgid = self.Panel:GetAttribute("panelID")
        local bdSet = SV.media.backdrop[bgid]
        if(bdSet) then
            if(not self.Panel:GetAttribute("panelLocked")) then
                local edgeSize = bdSet.edgeSize;
                if(edgeSize and type(edgeSize) == 'number') then
                    local offset = ceil(edgeSize * 0.2);
                    self.Panel:ClearAllPoints()
                    self.Panel:SetPoint("TOPLEFT", self, "TOPLEFT", -offset, offset)
                    self.Panel:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", offset, -offset)
                end
            end
            self.Panel:SetBackdrop(bdSet)
            self.Panel:SetBackdropBorderColor(0,0,0,1)
        else
            local newBgFile = SV.media.background[bgid]
            local newBorderFile = SV.media.border[bgid]
            if(newBgFile and newBorderFile) then
                local w,h = self:GetSize()
                local sizeMod = max(w,h)
                local edgeSize = self.Panel:GetAttribute("panelPadding") or 1
                local offset = ceil(edgeSize * 0.2)
                local bdSet = {
                    bgFile = newBgFile,
                    edgeFile = newBorderFile,
                    tile = true,
                    tileSize = sizeMod,
                    edgeSize = edgeSize,
                    insets =
                    {
                        left = offset,
                        right = offset,
                        top = offset,
                        bottom = offset,
                    },
                };
                self.Panel:SetBackdrop(bdSet)
                self.Panel:SetBackdropBorderColor(0,0,0,1)
                if(not self.Panel:GetAttribute("panelLocked")) then
                    self.Panel:ClearAllPoints()
                    self.Panel:SetPoint("TOPLEFT", self, "TOPLEFT", -offset, offset)
                    self.Panel:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", offset, -offset)
                end
            end
        end

        local colorID = self.Panel:GetAttribute("panelColor")
        local panelColor = SV.media.color[colorID];
        if(panelColor) then
            self.Panel:SetBackdropColor(panelColor[1], panelColor[2], panelColor[3], panelColor[4] or 1)
        end
    end
end

local HookCustomBackdrop_TypeB = function(self)
    if(self.Panel) then
        local bgid = self.Panel:GetAttribute("panelID")
        local bdSet = SV.media.backdrop[bgid]
        if(bdSet) then
            self:SetBackdrop(bdSet)
            self:SetBackdropBorderColor(0,0,0,1)
        else
            local newBgFile = SV.media.background[bgid]
            local newBorderFile = SV.media.border[bgid]
            if(newBgFile and newBorderFile) then
                local w,h = self:GetSize()
                local sizeMod = max(w,h)
                local edgeSize = self.Panel:GetAttribute("panelPadding") or 1
                local offset = ceil(edgeSize * 0.2)
                local bdSet = {
                    bgFile = newBgFile,
                    edgeFile = newBorderFile,
                    tile = true,
                    tileSize = sizeMod,
                    edgeSize = edgeSize,
                    insets =
                    {
                        left = offset,
                        right = offset,
                        top = offset,
                        bottom = offset,
                    },
                };
                self:SetBackdrop(bdSet)
                self:SetBackdropBorderColor(0,0,0,1)
            end
        end

        local colorID = self.Panel:GetAttribute("panelColor")
        local panelColor = SV.media.color[colorID];
        if(panelColor) then
            self:SetBackdropColor(panelColor[1], panelColor[2], panelColor[3], panelColor[4] or 1)
        end
    end
end

local HookFrameLevel = function(self, level)
    if(self.Panel) then
        local adjustment = level - 1;
        if(adjustment < 0) then adjustment = 0 end
        self.Panel:SetFrameLevel(adjustment)
    end
end

local Cooldown_ForceUpdate = function(self)
    self.nextUpdate = 0;
    self:Show()
end

local Cooldown_StopTimer = function(self)
    self.enable = nil;
    if(self.parent and self.parent.HideAfterCooldown) then
        self.parent:Hide();
    else
        self:Hide();
    end
end

local Cooldown_OnUpdate = function(self, elapsed)
    if self.nextUpdate > 0 then
        self.nextUpdate = self.nextUpdate - elapsed;
        return
    end
    local now = GetTime();
    local start = self.start;
    local remaining = now - start;
    local expires = (self.duration - remaining);
    if expires > 0.05 then
        if (self.fontScale * self:GetEffectiveScale() / UIParent:GetScale()) < 0.5 then
            self.text:SetText('')
            self.nextUpdate = 500
        else
            local timeLeft = 0;
            local calc = 0;
            if expires < 4 then
                self.nextUpdate = 0.051
                self.text:SetFormattedText("|cffff0000%.1f|r", expires)
            elseif expires < 60 then
                self.nextUpdate = 0.51
                self.text:SetFormattedText("|cffffff00%d|r", floor(expires))
            elseif expires < 3600 then
                timeLeft = ceil(expires / 60);
                calc = floor((expires / 60) + .5);
                self.nextUpdate = calc > 1 and ((expires - calc) * 29.5) or (expires - 59.5);
                self.text:SetFormattedText("|cffffffff%dm|r", timeLeft)
            elseif expires < 86400 then
                timeLeft = ceil(expires / 3600);
                calc = floor((expires / 3600) + .5);
                self.nextUpdate = calc > 1 and ((expires - calc) * 1799.5) or (expires - 3570);
                self.text:SetFormattedText("|cff66ffff%dh|r", timeLeft)
            else
                timeLeft = ceil(expires / 86400);
                calc = floor((expires / 86400) + .5);
                self.nextUpdate = calc > 1 and ((expires - calc) * 43199.5) or (expires - 85680);
                if(timeLeft > 7) then
                    self.text:SetFormattedText("|cff6666ff%s|r", "long")
                else
                    self.text:SetFormattedText("|cff6666ff%dd|r", timeLeft)
                end
            end
        end
    else
        Cooldown_StopTimer(self)
    end
end

local Cooldown_OnSizeChanged = function(self, width, height)
    local frame = self.timer
    local override = self.SizeOverride
    local newSize = floor(width + .5) / 36;
    override = override or frame:GetParent():GetParent().SizeOverride;
    if override then
        newSize = override / 20
    end
    if newSize == frame.fontScale then
        return
    end
    frame.fontScale = newSize;
    if newSize < 0.5 and not override then
        frame:Hide()
    else
        frame:Show()
        frame.text:SetFont(SV.media.font.number, newSize * 15, 'OUTLINE')
        if frame.enable then
            Cooldown_ForceUpdate(frame)
        end
    end
end

local CreateCooldownTimer = function(self)
    local timer = CreateFrame('Frame', nil, self)
    timer.parent = self:GetParent()
    timer:SetAllPoints()
    timer:SetScript('OnUpdate', Cooldown_OnUpdate)

    local timeText = timer:CreateFontString(nil,'OVERLAY')
    timeText:SetPoint('CENTER',1,1)
    timeText:SetJustifyH("CENTER")
    timer.text = timeText;

    timer:Hide()

    self.timer = timer;

    local width, height = self:GetSize()
    Cooldown_OnSizeChanged(self, width, height)
    self:SetScript('OnSizeChanged', Cooldown_OnSizeChanged)

    return self.timer
end

local _hook_Cooldown_SetCooldown = function(self, start, duration, elapsed)
    if start > 0 and duration > 2.5 then
        local timer = self.timer or CreateCooldownTimer(self)
        timer.start = start;
        timer.duration = duration;
        timer.enable = true;
        timer.nextUpdate = 0;

        if timer.fontScale >= 0.5 then
            timer:Show()
        end
    else
        local timer = self.timer;
        if timer then
            Cooldown_StopTimer(timer)
        end
    end
    if self.timer then
        if elapsed and elapsed > 0 then
            self.timer:SetAlpha(0)
        else
            self.timer:SetAlpha(0.8)
        end
    end
end

local SetFrameBorderColor = function(self, r, g, b, setPrevious, reset)
    if(setPrevious) then
        self.Panel.__previous = setPrevious
    elseif(reset) then
        r,g,b = unpack(SV.media.color[self.Panel.__previous])
    end
    self.Panel.Shadow:SetBackdropBorderColor(r, g, b)
end

local ShowAlertFlash = function(self)
    self:ColorBorder(1,0.9,0)
    SV.Animate:Flash(self.Panel.Shadow, 0.75, true)
end

local HideAlertFlash = function(self)
    SV.Animate:StopFlash(self.Panel.Shadow)
    self:ColorBorder(1,0.9,0, nil, true)
end
--[[
##########################################################
TEMPLATE HELPERS
##########################################################
]]--
local function SetCD(button, noSwipe)
    local bn = button:GetName()
    if(bn) then
        local cooldown = _G[bn.."Cooldown"];
        if(cooldown) then
            if(not SV.db.general or (SV.db.general and (not SV.db.general.cooldown))) then return end
            cooldown:ClearAllPoints()
            cooldown:InsetPoints()
            cooldown:SetDrawEdge(false)
            cooldown:SetDrawBling(false)
            cooldown:SetHideCountdownNumbers(true)
            cooldown.SetHideCountdownNumbers = SV.fubar
            if(not noSwipe) then
                cooldown:SetSwipeColor(0, 0, 0, 1)
            end

            if(not cooldown.HookedCooldown) then
                hooksecurefunc(cooldown, "SetCooldown", _hook_Cooldown_SetCooldown)
                cooldown.HookedCooldown = true
            end
        end
        return cooldown
    end
    return false
end

function MOD:FLASH(frame)
    if(frame.Panel.Shadow) then
        frame.Panel.__previous = 'darkest';
        frame.ColorBorder = SetFrameBorderColor
        frame.StartAlert = ShowAlertFlash
        frame.StopAlert = HideAlertFlash
    end
end

function MOD:CD(frame, noSwipe)
    local cooldown = SetCD(frame, noSwipe)
    if(not cooldown) then
        cooldown = CreateFrame("Cooldown", nil, frame)
        cooldown:ClearAllPoints()
        cooldown:InsetPoints(frame, 1, 1)
        cooldown:SetDrawEdge(false)
        cooldown:SetDrawBling(false)
        cooldown:SetHideCountdownNumbers(true)
        cooldown.SetHideCountdownNumbers = SV.fubar
        if(not noSwipe) then
            cooldown:SetSwipeColor(0, 0, 0, 1)
        end
        if(not cooldown.HookedCooldown) then
            hooksecurefunc(cooldown, "SetCooldown", _hook_Cooldown_SetCooldown)
            cooldown.HookedCooldown = true
        end
    end
    return cooldown
end

function MOD:APPLY(frame, templateName, underlay, padding, xOffset, yOffset, defaultColor)
    local xmlTemplate = self.Templates[templateName] or self.Templates.Default;

    local borderColor = {0,0,0,1}

    local panel = CreateFrame('Frame', nil, frame, xmlTemplate)

    local level = frame:GetFrameLevel()
    if(level == 0 and not InCombatLockdown()) then
        frame:SetFrameLevel(1)
        level = 1
    end

    local adjustment = level - 1;

    if(adjustment < 0) then adjustment = 0 end

    panel:SetFrameLevel(adjustment)

    hooksecurefunc(frame, "SetFrameLevel", HookFrameLevel)

    if(defaultColor) then
        panel:SetAttribute("panelColor", defaultColor)
    end

    local panelID       = panel:GetAttribute("panelID")
    local colorName     = panel:GetAttribute("panelColor")
    local gradientName  = panel:GetAttribute("panelGradient")
    local forcedOffset  = panel:GetAttribute("panelOffset")

    if(forcedOffset or xOffset or yOffset) then
        panel:SetAttribute("panelLocked", true)
    end

    if(frame.noStyleUpdate) then
        panel:SetAttribute("panelSkipUpdate", true)
    end

    padding = padding or panel:GetAttribute("panelPadding")
    if(forcedOffset) then
        xOffset = xOffset or forcedOffset
        yOffset = yOffset or forcedOffset
    else
        xOffset = xOffset or padding
        yOffset = yOffset or padding
    end

    --panel:WrapPoints(frame, xOffset, yOffset)
    panel:SetPoint("TOPLEFT", frame, "TOPLEFT", -xOffset, yOffset)
    panel:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", xOffset, -yOffset)

    local bgColor = SV.media.color[colorName] or SV.media.color.default;
    local borderColor = SV.media.bordercolor[panelID] or SV.media.bordercolor.default;

    if(panel:GetBackdrop()) then
        if(underlay) then
            panel:SetBackdropColor(bgColor[1],bgColor[2],bgColor[3],bgColor[4] or 1)
            panel:SetBackdropBorderColor(borderColor[1],borderColor[2],borderColor[3],borderColor[4] or 1)
        else
            local bd = panel:GetBackdrop()
            frame:SetBackdrop(bd)
            frame:SetBackdropColor(bgColor[1],bgColor[2],bgColor[3],bgColor[4] or 1)
            frame:SetBackdropBorderColor(borderColor[1],borderColor[2],borderColor[3],borderColor[4] or 1)

            panel:SetBackdrop(nil)
        end

        if(templateName ~= 'Transparent') then
            hooksecurefunc(panel, "SetBackdropBorderColor", HookPanelBorderColor)
            hooksecurefunc(frame, "SetBackdropBorderColor", HookBackdropBorderColor)
            if(underlay) then
                frame:SetBackdrop(nil)
                frame.SetBackdrop = panel.SetBackdrop
                --hooksecurefunc(frame, "SetBackdrop", HookBackdrop)
                --hooksecurefunc(frame, "SetBackdropColor", HookBackdropColor)
                frame.UpdateBackdrop = HookCustomBackdrop_TypeA
            else
                frame.UpdateBackdrop = HookCustomBackdrop_TypeB
            end

            frame.BackdropNeedsUpdate = true
        end
    end

    if(padding and panel.BorderLeft) then
        panel.BorderLeft:SetWidth(padding)
        panel.BorderRight:SetWidth(padding)
        panel.BorderTop:SetHeight(padding)
        panel.BorderBottom:SetHeight(padding)
    end

    if(panel.Shadow) then
        --panel.Shadow:SetAllPoints(panel)
        panel.Shadow:SetPoint('TOPLEFT', panel, 'TOPLEFT', -2, 2)
        panel.Shadow:SetPoint('BOTTOMRIGHT', panel, 'BOTTOMRIGHT', 2, -2)

        local alpha = panel.Shadow:GetAttribute("shadowAlpha") or 0.5
        panel.Shadow:SetBackdropBorderColor(0,0,0,alpha)

        local level = panel.Shadow:GetFrameLevel() - 1
        if(level >= 0) then
            panel.Shadow:SetFrameLevel(level)
        else
            panel.Shadow:SetFrameLevel(0)
        end
    end

    if(panel.Skin) then
        panel.Skin:ClearAllPoints()
        panel.Skin:SetAllPoints(panel)
        if(not underlay) then
            panel.Skin:SetParent(frame)
        end
        if(gradientName and SV.media.gradient[gradientName]) then
            panel.Skin:SetGradient(unpack(SV.media.gradient[gradientName]))
        else
            panel.Skin:SetVertexColor(bgColor[1], bgColor[2], bgColor[3], bgColor[4] or 1)
        end

        if((not panel:GetAttribute("panelSkipUpdate")) and panel:GetAttribute("panelTexUpdate")) then
            frame.TextureNeedsUpdate = true
            if(panel:GetAttribute("panelHookVertex")) then
                frame.UpdateColor = HookVertexColor
                frame.NoColorUpdate = true
            end
        end
    end

    if(panel.TopLeft and (not underlay)) then
        panel.TopLeft:SetParent(frame)
        panel.TopRight:SetParent(frame)
        panel.BottomLeft:SetParent(frame)
        panel.BottomRight:SetParent(frame)
    end

    frame.Panel = panel;
end
--[[
##########################################################
UI ELEMENT METHODS
##########################################################
]]--
local function CommonButtonSettings(frame, addChecked, noSwipe)
    if(frame.Left) then
        frame.Left:SetAlpha(0)
    end

    if(frame.Middle) then
        frame.Middle:SetAlpha(0)
    end

    if(frame.Right) then
        frame.Right:SetAlpha(0)
    end

    if(frame.SetNormalTexture) then
        frame:SetNormalTexture("")
    end

    if(frame.SetDisabledTexture) then
        frame:SetDisabledTexture("")
    end

    if(frame.SetCheckedTexture) then
        frame:SetCheckedTexture("")
    end

    if(frame.SetHighlightTexture) then
        if(not frame.hover) then
            local hover = frame:CreateTexture(nil, "HIGHLIGHT")
            hover:InsetPoints(frame.Panel)
            frame.hover = hover;
        end
        frame.hover:SetColorTexture(0.1, 0.8, 0.8, 0.5)
        frame:SetHighlightTexture(frame.hover)
    end

    if(frame.SetPushedTexture) then
        if(not frame.pushed) then
            local pushed = frame:CreateTexture(nil, "OVERLAY")
            pushed:InsetPoints(frame.Panel)
            frame.pushed = pushed;
        end
        frame.pushed:SetColorTexture(0.1, 0.8, 0.1, 0.3)
        frame:SetPushedTexture(frame.pushed)
    end

    if(frame.SetCheckedTexture and addChecked) then
        if(not frame.checked) then
            local checked = frame:CreateTexture(nil, "OVERLAY")
            checked:InsetPoints(frame.Panel)
            frame.checked = checked
        end
        frame.checked:SetColorTexture(0, 0.5, 0, 0.2)
        frame:SetCheckedTexture(frame.checked)
    end

    SetCD(frame, noSwipe)
end

MOD.Methods["Button"] = function(self, frame, inverse, xOffset, yOffset, defaultColor)
    if(not frame or (frame and frame.Panel)) then return end

    local x,y = -1,-1
    if(xOffset or yOffset) then
        x = xOffset or -1
        y = yOffset or -1
        inverse = true
    end

    self:APPLY(frame, "Button", inverse, 1, x, y, defaultColor)
    CommonButtonSettings(frame, true)
    if(defaultColor) then
        frame.Panel:SetAttribute("panelID", "button"..defaultColor)
        local count = #LIVE_UPDATE_FRAMES+1;
        LIVE_UPDATE_FRAMES[count] = frame;
    end
end;

MOD.Methods["LiteButton"] = function(self, frame, inverse, xOffset, yOffset, defaultColor)
    if(not frame or (frame and frame.Panel)) then return end

    local x,y = 1,1
    if(xOffset or yOffset) then
        x = xOffset or 1
        y = yOffset or 1
        inverse = true
    end

    self:APPLY(frame, "Lite", inverse, 1, x, y)
    --frame:SetBackdropColor(0,0,0,0)
    --frame:SetBackdropBorderColor(0,0,0,0)
    CommonButtonSettings(frame, true)
end;

MOD.Methods["ActionSlot"] = function(self, frame, inverse, addChecked)
    if(not frame or (frame and frame.Panel)) then return end

    addChecked = addChecked or false;
    local underlay = (not inverse)
    self:APPLY(frame, "ActionSlot", underlay)

    CommonButtonSettings(frame, addChecked, true)
end;

MOD.Methods["CheckButton"] = function(self, frame, inverse, x, y)
    if(not frame or (frame and frame.Panel)) then return end

    local width, height = frame:GetSize()
    width = width * 0.7
    height = height * 0.7
    frame:SetSize(width, height)

    local underlay = (not inverse)
    self:APPLY(frame, "CheckButton", inverse, 1, 1, 1)

    if(frame.SetNormalTexture) then
        frame:SetNormalTexture("")
    end

    if(frame.SetPushedTexture) then
        frame:SetPushedTexture("")
    end

    if(frame.SetHighlightTexture) then
        if(not frame.hover) then
            local hover = frame:CreateTexture(nil, "OVERLAY")
            hover:InsetPoints(frame.Panel)
            frame.hover = hover;
        end
        local color = SV.media.color.highlight
        frame.hover:SetTexture(color[1], color[2], color[3], 0.5)
        frame:SetHighlightTexture(frame.hover)
    end

    if(frame.SetCheckedTexture) then
        frame:SetCheckedTexture(SV.media.button.check)
        local ct = frame:GetCheckedTexture()
        ct:SetTexCoord(0, 1, 0, 1)
    end

    if(frame.SetDisabledCheckedTexture) then
        frame:SetDisabledCheckedTexture(SV.media.button.uncheck)
        local ct = frame:GetDisabledCheckedTexture()
        ct:SetTexCoord(0, 1, 0, 1)
    end
end;

MOD.Methods["Editbox"] = function(self, frame, inverse, x, y)
    if(not frame or (frame and frame.Panel)) then return end

    if frame.TopLeftTex then frame.TopLeftTex:Die() end
    if frame.TopRightTex then frame.TopRightTex:Die() end
    if frame.TopTex then frame.TopTex:Die() end
    if frame.BottomLeftTex then frame.BottomLeftTex:Die() end
    if frame.BottomRightTex then frame.BottomRightTex:Die() end
    if frame.BottomTex then frame.BottomTex:Die() end
    if frame.LeftTex then frame.LeftTex:Die() end
    if frame.RightTex then frame.RightTex:Die() end
    if frame.MiddleTex then frame.MiddleTex:Die() end
    if frame.Left then frame.Left:Die() end
    if frame.Right then frame.Right:Die() end
    if frame.Middle then frame.Middle:Die() end

    local underlay = (not inverse)
    self:APPLY(frame, "EditBox", underlay, 1, x, y)
    if(frame.Panel.InnerGlow) then
        frame.Panel.InnerGlow:SetFrameLevel(0)
    end
    local globalName = frame:GetName();
    if globalName then
        if _G[globalName.."Left"] then _G[globalName.."Left"]:Die() end
        if _G[globalName.."Middle"] then _G[globalName.."Middle"]:Die() end
        if _G[globalName.."Right"] then _G[globalName.."Right"]:Die() end
        if _G[globalName.."Mid"] then _G[globalName.."Mid"]:Die() end

        if globalName:find("Silver") or globalName:find("Copper") or globalName:find("Gold") then
            frame.Panel:SetPoint("TOPLEFT", -3, 1)
            if globalName:find("Silver") or globalName:find("Copper") then
                frame.Panel:SetPoint("BOTTOMRIGHT", -12, -2)
            else
                frame.Panel:SetPoint("BOTTOMRIGHT", -2, -2)
            end
        end
    end
end;
--[[
##########################################################
CUSTOM TEMPLATING METHODS
##########################################################
]]--
MOD.Methods["Icon"] = function(self, frame, inverse, ...)
    if(not frame or (frame and frame.Panel)) then return end
    local underlay = (not inverse)
    self:APPLY(frame, "Icon", underlay, ...)
end;

MOD.Methods["DockButton"] = function(self, frame, inverse, template)
    if(not frame or (frame and frame.Panel)) then return end
    template = template or "DockButton"
    self:APPLY(frame, template, inverse)
    self:FLASH(frame)

    if(frame.Left) then
        frame.Left:SetAlpha(0)
    end

    if(frame.Middle) then
        frame.Middle:SetAlpha(0)
    end

    if(frame.Right) then
        frame.Right:SetAlpha(0)
    end

    if(frame.SetNormalTexture) then
        frame:SetNormalTexture("")
    end

    if(frame.SetDisabledTexture) then
        frame:SetDisabledTexture("")
    end

    if(frame.SetCheckedTexture) then
        frame:SetCheckedTexture("")
    end

    if(frame.SetHighlightTexture) then
        if(not frame.hover) then
            local hover = frame:CreateTexture(nil, "HIGHLIGHT")
            hover:InsetPoints(frame.Panel)
            frame.hover = hover;
        end
        frame.hover:SetColorTexture(0.1, 0.8, 0.8, 0.5)
        frame:SetHighlightTexture(frame.hover)
    end

    if(not frame.Panel:GetAttribute("panelSkipUpdate")) then
      local count = #LIVE_UPDATE_FRAMES+1;
      LIVE_UPDATE_FRAMES[count] = frame;
    end
end;

MOD.Methods["ShadowBox"] = function(self, frame, inverse, styleName, noupdate, overridePadding, xOffset, yOffset, defaultColor)
    if(not frame or (frame and frame.Panel)) then return end
    local padding = false;
    if(overridePadding and type(overridePadding) == "number") then
        padding = overridePadding
    end
    styleName = styleName or "Default";
    local underlay = (not inverse)
    if(noupdate) then
        frame.noStyleUpdate = true
    end
    xOffset = xOffset or 2
    yOffset = yOffset or 2
    self:APPLY(frame, styleName, underlay, padding, xOffset, yOffset, defaultColor)
    local shadowbox = CreateFrame('Frame', nil, frame, "SVUI_ShadowBoxTemplate")
    shadowbox:SetPoint("TOPLEFT", frame, "TOPLEFT", -xOffset, yOffset)
    shadowbox:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", xOffset, -yOffset)
    if(not noupdate) then
      local count = #LIVE_UPDATE_FRAMES+1;
      LIVE_UPDATE_FRAMES[count] = frame;
    end
end;

MOD.Methods["Frame"] = function(self, frame, inverse, styleName, noupdate, overridePadding, xOffset, yOffset, defaultColor)
    if(not frame or (frame and frame.Panel)) then return end
    local padding = false;
    if(overridePadding and type(overridePadding) == "number") then
        padding = overridePadding
    end
    styleName = styleName or "Default";
    local underlay = (not inverse)
    if(noupdate) then
        frame.noStyleUpdate = true
    end
    self:APPLY(frame, styleName, underlay, padding, xOffset, yOffset, defaultColor)
    if(not noupdate) then
      local count = #LIVE_UPDATE_FRAMES+1;
      LIVE_UPDATE_FRAMES[count] = frame;
    end
end;
--[[
##########################################################
TEMPLATE API
##########################################################
]]--
local SetPanelColor = function(self, ...)
    local arg1,arg2,arg3,arg4,arg5,arg6,arg7 = select(1, ...)
    if(not self.Panel or not arg1) then return; end
    if(self.Panel.Skin and self.Panel:GetAttribute("panelGradient")) then
        if(type(arg1) == "string") then
            if(arg1 == "VERTICAL" or arg1 == "HORIZONTAL") then
                self.Panel.Skin:SetGradient(...)
            elseif(SV.media.gradient[arg1]) then
                self.Panel:SetAttribute("panelColor", arg1)
                self.Panel.Skin:SetGradient(unpack(SV.media.gradient[arg1]))
                if(SV.media.color[arg1]) then
                    local t = SV.media.color[arg1]
                    self:SetBackdropColor(t[1], t[2], t[3], t[4])
                end
            end
        end
    elseif(type(arg1) == "string" and SV.media.color[arg1]) then
        local t = SV.media.color[arg1]
        self.Panel:SetAttribute("panelColor", arg1)
        self:SetBackdropColor(t[1], t[2], t[3], t[4])
    elseif(arg1 and type(arg1) == "number") then
        self:SetBackdropColor(...)
    end
end

local SetStyle = function(self, method, ...)
    if(not self or (self and self.Panel)) then return end
    method = method or "Frame";
    local methodName, flags = method:gsub("!_", "");
    local param = false;
    if(flags and (flags > 0)) then
        param = true;
    end
    local fn = MOD.Methods[methodName];
    if(fn) then
        local pass, catch = pcall(fn, MOD, self, param, ...)
        if(catch) then
            SV:HandleError("API", "SetStyle", catch);
            return
        end
    end
end
--[[
##########################################################
HOOKED ATLAS HIJACKER
##########################################################
]]--
local ATLAS_THIEF = {} -- Wasn't this the name of a movie?
local ATLAS_HACKS = {} -- Couldn't think of anything clever honestly.
ATLAS_HACKS["default"] = function(self)
  self:SetTexture("")
end

local StealAtlas = function(self, atlas)
    if(not self or not atlas) then return end
    --print(atlas)
    local hack = ATLAS_THIEF[atlas];
    if(hack) then
        local fn = ATLAS_HACKS[hack] or ATLAS_HACKS["default"]
        local pass, catch = pcall(fn, self, atlas)
        if(catch) then
            SV:HandleError("API", "SetStyle", catch);
            return
        end
    end
end
--[[
##########################################################
UPDATE CALLBACKS
##########################################################
]]--
local function FrameTemplateUpdates()
    for i=1, #LIVE_UPDATE_FRAMES do
        local frame = LIVE_UPDATE_FRAMES[i]
        if(frame) then
            local panelID = frame.Panel:GetAttribute("panelID")
            local colorID = frame.Panel:GetAttribute("panelColor")
            local panelColor = SV.media.color[colorID];
            if(frame.BackdropNeedsUpdate) then
                if(frame.UpdateBackdrop) then
                    frame:UpdateBackdrop()
                end
                if(panelColor) then
                    frame:SetBackdropColor(panelColor[1], panelColor[2], panelColor[3], panelColor[4] or 1)
                end
                if(SV.media.bordercolor[panelID]) then
                    local borderColor = SV.media.bordercolor[panelID]
                    frame:SetBackdropBorderColor(borderColor[1], borderColor[2], borderColor[3], borderColor[4] or 1)
                else
                    frame:SetBackdropBorderColor(0,0,0,1)
                end
            end
            if(frame.TextureNeedsUpdate and frame.Panel.Skin) then
                local tex = SV.media.background[panelID]
                if(tex) then
                    frame.Panel.Skin:SetTexture(tex)
                    --if(panelID == 'unitlarge') then print(frame.Panel.Skin:GetTexture()) end
                end
                if(not frame.NoColorUpdate) then
                    local gradient = frame.Panel:GetAttribute("panelGradient")
                    if(gradient and SV.media.gradient[gradient]) then
                        local g = SV.media.gradient[gradient]
                        frame.Panel.Skin:SetGradient(g[1], g[2], g[3], g[4], g[5], g[6], g[7])
                    elseif(panelColor) then
                        frame.Panel.Skin:SetVertexColor(panelColor[1], panelColor[2], panelColor[3], panelColor[4] or 1)
                    end
                end
            end
        end
    end
end

SV.Events:On("SHARED_MEDIA_UPDATED", FrameTemplateUpdates, true);
SV.Events:On("REQUEST_TEMPLATE_UPDATED", FrameTemplateUpdates, true);
--[[
##########################################################
CORE FUNCTIONS
##########################################################
]]--
function SV:SetAtlasFunc(atlas, fn)
    ATLAS_HACKS[atlas] = fn
end

function SV:SetAtlasFilter(atlas, fn)
    if(not fn) then
        fn = "default"
    end
    ATLAS_THIEF[atlas] = fn
end
--[[
##########################################################
SCREEN HANDLER (IN DEVELOPMENT)
##########################################################
]]--
function SV:UI_SCALE_CHANGED(event)
    local managedScale = self.db.screen.autoScale;
    local gxWidth, gxHeight, gxScale, customScale = ScreenUpdate();

    if(managedScale) then
        local needCalc = true;
        if(self.db.screen.advanced) then
            if(self.db.screen.forcedWidth ~= gxWidth) then
                gxWidth = self.db.screen.forcedWidth
                needCalc = false;
            end
            if(self.db.screen.forcedHeight ~= gxHeight) then
                gxHeight = self.db.screen.forcedHeight
                needCalc = false;
            end
        end
        if(needCalc) then
            if(gxWidth < 1600) then
                self.LowRez = true;
            elseif(gxWidth >= 3840) then
                self.LowRez = nil
                local evalwidth;
                if(self.db.screen.multiMonitor) then
                    if(gxWidth < 4080) then
                        evalwidth = 1224;
                    elseif(gxWidth < 4320) then
                        evalwidth = 1360;
                    elseif(gxWidth < 4680) then
                        evalwidth = 1400;
                    elseif(gxWidth < 4800) then
                        evalwidth = 1440;
                    elseif(gxWidth < 5760) then
                        if(gxHeight == 900) then evalwidth = 1600 else evalwidth = 1680 end
                    elseif(gxWidth < 7680) then
                        evalwidth = 1920;
                    elseif(gxWidth < 9840) then
                        evalwidth = 2560;
                    elseif(gxWidth > 9839) then
                        evalwidth = 3280;
                    end
                else
                    if(gxWidth < 4080) then
                        evalwidth = 3840;
                    elseif(gxWidth < 4320) then
                        evalwidth = 4080;
                    elseif(gxWidth < 4680) then
                        evalwidth = 4320;
                    elseif(gxWidth < 4800) then
                        evalwidth = 4680;
                    elseif(gxWidth < 5040) then
                        evalwidth = 4800;
                    elseif(gxWidth < 5760) then
                        evalwidth = 5040;
                    elseif(gxWidth < 7680) then
                        evalwidth = 5760;
                    elseif(gxWidth < 9840) then
                        evalwidth = 7680;
                    elseif(gxWidth > 9839) then
                        evalwidth = 9840;
                    end
                end

                gxWidth = evalwidth;
            end
        end
    end
    if(event == 'PLAYER_LOGIN' or event == 'UI_SCALE_CHANGED') then
        self.Screen:ClearAllPoints()
        self.Screen:SetPoint("CENTER")
        local ignoreChange = false;
        local testScale1 = 0
        local testScale2 = 0

        if(managedScale) then
            testScale1 = parsefloat(UIParent:GetScale(), 5);
            testScale2 = parsefloat(gxScale, 5);

            if(event == "PLAYER_LOGIN" and (testScale1 ~= testScale2)) then
                SetCVar("useUiScale", 1)
                SetCVar("uiScale", gxScale)
                WorldMapFrame.hasTaint = true;
                ignoreChange = true;
                _G.Advanced_UseUIScale:SetScale(0.0001)
                _G.Advanced_UseUIScale:SetAlpha(0)
                _G.Advanced_UIScaleSlider:SetScale(0.0001)
                _G.Advanced_UIScaleSlider:SetAlpha(0)
            end

            if(gxWidth) then
                local width = gxWidth
                local height = gxHeight;
                if(height > 1200) then
                    height = UIParent:GetHeight();
                    local ratio = gxHeight / height;
                    width = gxWidth / ratio;
                end
                self.Screen:SetSize(width, height);
            else
                self.Screen:SetSize(UIParent:GetSize());
            end
        else
            self.Screen:SetSize(UIParent:GetSize());
        end

        if((not customScale) and (not ignoreChange) and (event == 'UI_SCALE_CHANGED')) then
            local change = abs((testScale1 * 100) - (testScale2 * 100))
            if(change > 1) then
                if(managedScale) then
                    self:StaticPopup_Show('CHANGED_MANAGED_UISCALE')
                elseif(BlizzardOptionsPanel_GetCVarSafe("useUiScale") ~= 0) then
                    self:StaticPopup_Show('RELOAD_UI')
                end
            end
        end
    end
end
--[[
##########################################################
API INJECTION
##########################################################
]]--
local MODIFIED_OBJECTS = {};

local function AppendFrameMethods(OBJECT, FORCE)
    local objType = OBJECT:GetObjectType()
    if(FORCE or (not MODIFIED_OBJECTS[objType])) then
        local META = getmetatable(OBJECT).__index
        if not OBJECT.SetStyle then META.SetStyle = SetStyle end
        if not OBJECT.SetPanelColor then META.SetPanelColor = SetPanelColor end
        if not OBJECT.ModSize then META.ModSize = ModSize end
        if not OBJECT.SetSecurePoint then META.SetSecurePoint = SetSecurePoint end
        if not OBJECT.SetAllSecurePoints then META.SetAllSecurePoints = SetAllSecurePoints end
        if not OBJECT.WrapPoints then META.WrapPoints = WrapPoints end
        if not OBJECT.InsetPoints then META.InsetPoints = InsetPoints end
        if not OBJECT.Die then META.Die = Die end
        if not OBJECT.RemoveTextures then META.RemoveTextures = RemoveTextures end
        if not OBJECT.FadeIn then META.FadeIn = SecureFadeIn end
        if not OBJECT.FadeOut then META.FadeOut = SecureFadeOut end
        if not OBJECT.FadeCallback then META.FadeCallback = SecureFadeCallback end
        MODIFIED_OBJECTS[objType] = true
    end
end

local function AppendTextureMethods(OBJECT)
    local META = getmetatable(OBJECT).__index
    if not OBJECT.ModSize then META.ModSize = ModSize end
    if not OBJECT.SetSecurePoint then META.SetSecurePoint = SetSecurePoint end
    if not OBJECT.SetAllSecurePoints then META.SetAllSecurePoints = SetAllSecurePoints end
    if not OBJECT.WrapPoints then META.WrapPoints = WrapPoints end
    if not OBJECT.InsetPoints then META.InsetPoints = InsetPoints end
    if not OBJECT.Die then META.Die = Die end
    if(OBJECT.SetAtlas) then
        hooksecurefunc(META, "SetAtlas", StealAtlas)
    end
end

local function AppendFontStringMethods(OBJECT)
    local META = getmetatable(OBJECT).__index
    if not OBJECT.ModSize then META.ModSize = ModSize end
    if not OBJECT.SetSecurePoint then META.SetSecurePoint = SetSecurePoint end
    if not OBJECT.SetAllSecurePoints then META.SetAllSecurePoints = SetAllSecurePoints end
    if not OBJECT.WrapPoints then META.WrapPoints = WrapPoints end
    if not OBJECT.InsetPoints then META.InsetPoints = InsetPoints end
end

local CURRENT_OBJECT = CreateFrame("Frame");
AppendFrameMethods(CURRENT_OBJECT)
AppendTextureMethods(CURRENT_OBJECT:CreateTexture())
AppendFontStringMethods(CURRENT_OBJECT:CreateFontString())

CURRENT_OBJECT = EnumerateFrames()
while CURRENT_OBJECT do
    AppendFrameMethods(CURRENT_OBJECT)
    CURRENT_OBJECT = EnumerateFrames(CURRENT_OBJECT)
end

function SV:AppendAPI()
    local NEW_OBJECT = EnumerateFrames()
    while NEW_OBJECT do
        AppendFrameMethods(NEW_OBJECT, true)
        NEW_OBJECT = EnumerateFrames(NEW_OBJECT)
    end
end
--[[
##########################################################
STYLING CONCEPTS
##########################################################
]]--
local Button_OnEnter = function(self)
    self:SetBackdropColor(0.1, 0.8, 0.8)
end

local Button_OnLeave = function(self)
    self:SetBackdropColor(unpack(SV.media.color.button))
end

local ConceptButton_OnEnter = function(self)
    self:SetBackdropBorderColor(0.1, 0.8, 0.8)
end

local ConceptButton_OnLeave = function(self)
    self:SetBackdropBorderColor(0,0,0,1)
end

local Tab_OnEnter = function(self)
    self.backdrop:SetPanelColor("highlight")
    self.backdrop:SetBackdropBorderColor(0.1, 0.8, 0.8)
end

local Tab_OnLeave = function(self)
    self.backdrop:SetPanelColor("button")
    self.backdrop:SetBackdropBorderColor(0,0,0,1)
end

local _hook_DropDownButton_SetPoint = function(self, _, _, _, _, _, breaker)
    if not breaker then
        self:SetPoint("RIGHT", self.AnchorParent, "RIGHT", -10, 3, true)
    end
end

local _hook_Tooltip_OnShow = function(self)
    self:SetBackdrop(SV.media.backdrop.tooltip)
end

MOD.Concepts["Frame"] = function(self, adjustable, frame, template, noStripping, padding, xOffset, yOffset)
    if(not frame or (frame and frame.Panel)) then return end
    template = template or "Transparent"
    local baselevel = frame:GetFrameLevel()
    if(baselevel < 1) then
        frame:SetFrameLevel(1)
    end
    if(not noStripping) then
        RemoveTextures(frame)
    end
    self.Methods["Frame"](self, frame, (not adjustable), template, true, padding, xOffset, yOffset)
end

MOD.Concepts["Window"] = function(self, adjustable, frame, altStyle, fullStrip, padding, xOffset, yOffset)
    if(not frame or (frame and frame.Panel)) then return end
    local template = altStyle and "Window2" or "Window"
    local baselevel = frame:GetFrameLevel()
    if(baselevel < 1) then
        frame:SetFrameLevel(1)
    end
    RemoveTextures(frame, fullStrip)
    if(name and _G[name.."BtnCornerLeft"]) then
        _G[name.."BtnCornerLeft"]:SetTexture("");
		_G[name.."BtnCornerRight"]:SetTexture("");
        _G[name.."ButtonBottomBorder"]:SetTexture("");
    end
    if (frame.NineSlice) then
        frame.NineSlice:RemoveTextures(true);
    end
    self.Methods["Frame"](self, frame, (not adjustable), template, false, padding, xOffset, yOffset)
    if(frame.Inset) then
      RemoveTextures(frame.Inset, fullStrip)
      self.Methods["Frame"](self, frame.Inset, adjustable, "Inset", false, 3, 1, 1)
    end
    if(frame.portrait) then
        frame.portrait:Hide()
    end
end

MOD.Concepts["Button"] = function(self, adjustable, frame)
    if(not frame or (frame and frame.Panel)) then return end
    RemoveTextures(frame)
    self.Methods["Button"](self, frame, adjustable)
end

MOD.Concepts["IconButton"] = function(self, adjustable, frame, texture)
    if(not frame or (frame and frame.Panel)) then return end
    iconTexture = texture or frame:GetNormalTexture()
    RemoveTextures(frame)
    self.Methods["Button"](self, frame, adjustable, -1, -1)
    if not frame.icon then
        frame.icon = frame:CreateTexture(nil,'ARTWORK')
        InsetPoints(frame.icon, frame, 3, 3);
        frame.icon:SetTexture(iconTexture)
        frame.icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
    end
end

MOD.Concepts["CheckButton"] = function(self, adjustable, frame)
    if(not frame or (frame and frame.Panel)) then return end
    --RemoveTextures(frame)
    self.Methods["CheckButton"](self, frame, adjustable)
end

MOD.Concepts["CloseButton"] = function(self, adjustable, frame, targetAnchor)
    if(not frame or (frame and frame.Panel)) then return end

    RemoveTextures(frame)

    self.Methods["Button"](self, frame, adjustable, -6, -6, "red")
    frame:SetFrameLevel(frame:GetFrameLevel() + 4)
    frame:SetNormalTexture(SV.media.icon.close)
    frame:HookScript("OnEnter", ConceptButton_OnEnter)
    frame:HookScript("OnLeave", ConceptButton_OnLeave)

    if(targetAnchor) then
        frame:ClearAllPoints()
        frame:SetPoint("TOPRIGHT", targetAnchor, "TOPRIGHT", 3, 3)
    end
end

MOD.Concepts["InfoButton"] = function(self, adjustable, frame, targetAnchor, size)
    if(not frame or (frame and frame.Panel)) then return end

    RemoveTextures(frame)
    size = size or 26
    frame:SetSize(size, size)
    --self.Methods["Button"](self, frame, false, -2, -2, "yellow")
    frame:SetNormalTexture(SV.media.icon.info)
    --frame:HookScript("OnEnter", ConceptButton_OnEnter)
    --frame:HookScript("OnLeave", ConceptButton_OnLeave)

    if(targetAnchor) then
        frame:ClearAllPoints()
        frame:SetPoint("TOPRIGHT", targetAnchor, "TOPRIGHT", 3, 3)
    end
end

MOD.Concepts["ArrowButton"] = function(self, adjustable, frame, direction, targetAnchor)
    if(not frame or (frame and frame.Panel)) then return end
    local iconKey = "move_" .. direction:lower()

    RemoveTextures(frame)

    self.Methods["Button"](self, frame, adjustable, -7, -7, "green")
    frame:SetFrameLevel(frame:GetFrameLevel() + 4)
    frame:SetNormalTexture(SV.media.icon[iconKey])
    frame:HookScript("OnEnter", ConceptButton_OnEnter)
    frame:HookScript("OnLeave", ConceptButton_OnLeave)

    if(targetAnchor) then
        frame:ClearAllPoints()
        frame:SetPoint("TOPRIGHT", targetAnchor, "TOPRIGHT", 0, 0)
    end
end

MOD.Concepts["ItemButton"] = function(self, adjustable, frame, noScript)
    if(not frame) then return end

    RemoveTextures(frame)

    if(not frame.Panel) then
        if(not noScript) then
            self.Methods["Frame"](self, frame, false, "Button", true, 1, -1, -1)
            frame:HookScript("OnEnter", Button_OnEnter)
            frame:HookScript("OnLeave", Button_OnLeave)
        else
            self.Methods["Frame"](self, frame, false, "Inset", true, 1, -1, -1)
            -- frame:HookScript("OnEnter", ConceptButton_OnEnter)
            -- frame:HookScript("OnLeave", ConceptButton_OnLeave)
        end
    end

    local link = frame:GetName()

    if(link) then
        local nameObject = _G[("%sName"):format(link)]
        local subNameObject = _G[("%sSubName"):format(link)]
        local arrowObject = _G[("%sFlyoutArrow"):format(link)]
        local levelObject = _G[("%sLevel"):format(link)]
        local iconObject = _G[("%sIcon"):format(link)] or _G[("%sIconTexture"):format(link)] or frame.Icon or frame.icon
        local countObject = _G[("%sCount"):format(link)]

        if(not frame.Riser) then
            local fg = CreateFrame("Frame", nil, frame)
            fg:SetSize(120, 22)
            fg:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, -11)
            fg:SetFrameLevel(frame:GetFrameLevel() + 1)
            frame.Riser = fg
        end

        if(iconObject) then
            iconObject:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))

            if(not adjustable) then
                iconObject:InsetPoints(frame, 2, 2)
            end
            if(not frame.IconShadow) then
                frame.IconShadow = CreateFrame("Frame", nil, frame)
                frame.IconShadow:WrapPoints(iconObject)
                frame.IconShadow:SetStyle("Icon")
            end

            iconObject:SetParent(frame.Riser)
            iconObject:SetDrawLayer("ARTWORK", -1)
        end

        if(countObject) then
            countObject:SetParent(frame.Riser)
            countObject:SetAllPoints(frame.Riser)
            countObject:SetFontObject(SVUI_Font_Number)
            countObject:SetDrawLayer("ARTWORK", 7)
        end

        if(nameObject) then nameObject:SetParent(frame.Riser) end
        if(subNameObject) then subNameObject:SetParent(frame.Riser) end
        if(arrowObject) then arrowObject:SetParent(frame.Riser) end

        if(levelObject) then
            levelObject:SetParent(frame.Riser)
            levelObject:SetFontObject(SVUI_Font_Number)
            levelObject:SetDrawLayer("ARTWORK", 7)
        end
    end
end

MOD.Concepts["PageButton"] = function(self, adjustable, frame, isVertical, isLeft)
    if(not frame) then return end

    local bName = frame:GetName()
    local leftDown;
    if(bName) then
        local testName = bName:lower()
        leftDown = ((bName and testName:find('left')) or testName:find('prev') or testName:find('decrement')) or false
    else
        leftDown = isLeft or false
    end

    frame:SetNormalTexture("")
    frame:SetPushedTexture("")
    frame:SetHighlightTexture("")
    frame:SetDisabledTexture("")

    if(not frame.Panel) then
        RemoveTextures(frame)
        frame:SetFrameLevel(frame:GetFrameLevel() + 2)
        self.Methods["Button"](self, frame, adjustable, -4, -4)
    end

    if not frame.icon then
        frame.icon = frame:CreateTexture(nil,'ARTWORK')
        frame.icon:SetSize(13, 13)
        frame.icon:SetPoint('CENTER')
        frame.icon:SetTexture(SV.media.button.radio)
        frame.icon:SetTexCoord(0.02, 0.2, 0.02, 0.2)

        frame:HookScript('OnMouseDown',function(self)
            if self:IsEnabled() then
                self.icon:SetPoint("CENTER",-1,-1)
            end
        end)

        frame:HookScript('OnMouseUp',function(self)
            self.icon:SetPoint("CENTER",0,0)
        end)

        frame:SetScript('OnDisable',function(self)
            SetDesaturation(self.icon, true)
            self.icon:SetAlpha(0.5)
        end)

        frame:SetScript('OnEnable',function(self)
            SetDesaturation(self.icon, false)
            self.icon:SetAlpha(1.0)
        end)

        if not frame:IsEnabled() then
            frame:GetScript('OnDisable')(frame)
        end
    end

    if isVertical then
        if leftDown then SquareButton_SetIcon(frame,'UP') else SquareButton_SetIcon(frame,'DOWN')end
    else
        if leftDown then SquareButton_SetIcon(frame,'LEFT') else SquareButton_SetIcon(frame,'RIGHT')end
    end
end

MOD.Concepts["Tab"] = function(self, adjustable, frame, addBackground, xOffset, yOffset)
    if(not frame or (frame and frame.Panel)) then return end

    local tab = frame:GetName();

    if _G[tab.."Left"] then _G[tab.."Left"]:SetTexture("") end
    if _G[tab.."LeftDisabled"] then _G[tab.."LeftDisabled"]:SetTexture("") end
    if _G[tab.."Right"] then _G[tab.."Right"]:SetTexture("") end
    if _G[tab.."RightDisabled"] then _G[tab.."RightDisabled"]:SetTexture("") end
    if _G[tab.."Middle"] then _G[tab.."Middle"]:SetTexture("") end
    if _G[tab.."MiddleDisabled"] then _G[tab.."MiddleDisabled"]:SetTexture("") end

    if(frame.GetHighlightTexture and frame:GetHighlightTexture()) then
        frame:GetHighlightTexture():SetTexture("")
    end

    RemoveTextures(frame)

    if(addBackground) then
        local nTex = frame:GetNormalTexture()

        if(nTex) then
            nTex:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
            InsetPoints(nTex, frame)
        end

        xOffset = xOffset or 1
        yOffset = yOffset or 1

        frame.pushed = true;
        frame.backdrop = CreateFrame("Frame", nil, frame)
        WrapPoints(frame.backdrop, frame, xOffset, yOffset)
        frame.backdrop:SetFrameLevel(0)
        self.Methods["Frame"](self, frame.backdrop, (not adjustable), "Button", false)

        local initialAnchor, anchorParent, relativeAnchor, xPosition, yPosition = frame:GetPoint()
        frame:SetPoint(initialAnchor, anchorParent, relativeAnchor, 1, yPosition)
    else
        xOffset = xOffset or 10
        yOffset = yOffset or 3
        frame.backdrop = CreateFrame("Frame", nil, frame)
        InsetPoints(frame.backdrop, frame, xOffset, yOffset);
        if(frame:GetFrameLevel() > 0) then
            frame.backdrop:SetFrameLevel(frame:GetFrameLevel() - 1)
        end

        self.Methods["Frame"](self, frame.backdrop, (not adjustable), "Button", false)
    end

    frame:HookScript("OnEnter", Tab_OnEnter)
    frame:HookScript("OnLeave", Tab_OnLeave)
    -- if(frame.backdrop.UpdateBackdrop) then
    --     frame.backdrop:UpdateBackdrop()
    -- end
end

MOD.Concepts["DropDown"] = function(self, adjustable, frame, width)
    if(not frame or (frame and frame.Panel)) then return end

    local ddName = frame:GetName();
    local ddText = _G[("%sText"):format(ddName)]
    local ddButton = _G[("%sButton"):format(ddName)]

    if not width then width = max(frame:GetWidth(), 128) end

    RemoveTextures(frame)
    frame:SetWidth(width)

    if(ddButton) then
        if(ddText) then
            --ddText:SetPoint("RIGHT", ddButton, "LEFT", 2, 0)
        end

        ddButton:ClearAllPoints()
        ddButton:SetPoint("RIGHT", frame, "RIGHT", -10, 3)
        ddButton.AnchorParent = frame

        hooksecurefunc(ddButton, "SetPoint", _hook_DropDownButton_SetPoint)

        self.Concepts["PageButton"](self, false, ddButton, true)

        local currentLevel = frame:GetFrameLevel()
        if(currentLevel == 0) then
            currentLevel = 1
        end

        if(not frame.BG) then
            frame.BG = frame:CreateTexture(nil, "BACKGROUND")
            frame.BG:SetPoint("TOPLEFT", frame, "TOPLEFT", 18, -2)
            frame.BG:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 6)
            frame.BG:SetTexture(SV.media.background.transparent)

            local fg = CreateFrame("Frame", nil, frame)
            fg:SetPoint("TOPLEFT", frame, "TOPLEFT", 18, -2)
            fg:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 6)
            fg:SetBackdrop(SV.media.backdrop.outline)
            frame.Brdr = fg
        end
    end
end

MOD.Concepts["Tooltip"] = function(self, adjustable, frame, useHook)
    if(not frame or (frame and frame.Panel)) then return end

    if frame.Background then
        frame.Background:SetTexture("")
    end

    if frame.Delimiter1 then
        frame.Delimiter1:SetTexture("")
        frame.Delimiter2:SetTexture("")
    end

    if frame.BorderTop then
        frame.BorderTop:SetTexture("")
    end

    if frame.BorderTopLeft then
        frame.BorderTopLeft:SetTexture("")
    end

    if frame.BorderTopRight then
        frame.BorderTopRight:SetTexture("")
    end

    if frame.BorderLeft then
        frame.BorderLeft:SetTexture("")
    end

    if frame.BorderRight then
        frame.BorderRight:SetTexture("")
    end

    if frame.BorderBottom then
        frame.BorderBottom:SetTexture("")
    end

    if frame.BorderBottomRight then
        frame.BorderBottomRight:SetTexture("")
    end

    if frame.BorderBottomLeft then
        frame.BorderBottomLeft:SetTexture("")
    end

    frame:SetBackdrop(SV.media.backdrop.tooltip)

    if(useHook) then
        frame:HookScript('OnShow', _hook_Tooltip_OnShow)
    end
end

MOD.Concepts["EditBox"] = function(self, adjustable, frame, width, height, x, y)
    if(not frame or (frame and frame.Panel)) then return end

    RemoveTextures(frame, true)
    self.Methods["Editbox"](self, frame, adjustable, x, y)

    if width then frame:SetWidth(width) end
    if height then frame:SetHeight(height) end
end

MOD.Concepts["QuestItem"] = function(self, adjustable, frame)
    if(not frame or (frame and frame.Panel)) then return end

    local icon, oldIcon;
    local name = frame:GetName();
    if(name and _G[name.."IconTexture"]) then
        icon = _G[name.."IconTexture"];
        oldIcon = _G[name.."IconTexture"]:GetTexture();
    elseif(frame.Icon) then
        icon = frame.Icon;
        oldIcon = frame.Icon:GetTexture();
    end

    RemoveTextures(frame)
    self.Methods["Icon"](self, frame, adjustable)

    local width,height = frame:GetSize()
    local fittedWidth = (width - height) + 4
    local insetFrame = CreateFrame("Frame", nil, frame.Panel)
    insetFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")
    insetFrame:SetWidth(fittedWidth)
    insetFrame:SetHeight(height)
    self.Methods["Frame"](self, insetFrame, false, "Inset", 1, 0, -2)

    if(icon) then
        local size = height - 4
        icon:ClearAllPoints()
        icon:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -2)
        icon:SetSize(size, size)

        local iconFallback = frame.Panel:CreateTexture(nil, "BACKGROUND")
        iconFallback:SetAllPoints(icon)
        iconFallback:SetTexture([[Interface\ICONS\INV_Misc_Bag_10]])
        iconFallback:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))

        if(oldIcon) then
            icon:SetTexture(oldIcon)
        end
        icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
    end
end

MOD.Concepts["Skin"] = function(self, style, frame, topX, topY, bottomX, bottomY)
    if(not frame or (frame and frame.Panel)) then return end
    if(not style) then style = "model" end
    local artname = style:lower()
    local texture = SV.media.background[artname] or SV.media.background.model
    RemoveTextures(frame, true)

    local borderFrame = CreateFrame("Frame", nil, frame)
    borderFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", topX, topY)
    borderFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", bottomX, bottomY)
    borderFrame:SetBackdrop(SV.media.backdrop.outline)

    local skin = frame:CreateTexture(nil, "BACKGROUND", nil, -1)
    skin:SetAllPoints(borderFrame)
    skin:SetTexture(texture)
    skin:SetGradient(unpack(SV.media.gradient.special))
end

local ALERT_TEMPLATE = {
    ["typeA"] = {
        COLOR   = {0.8, 0.2, 0.2},
        BG      = [[Interface\AddOns\SVUI_!Core\assets\textures\Alert\ALERT-BG]],
        LEFT    = [[Interface\AddOns\SVUI_!Core\assets\textures\Alert\ALERT-LEFT]],
        RIGHT   = [[Interface\AddOns\SVUI_!Core\assets\textures\Alert\ALERT-RIGHT]],
        TOP     = [[Interface\AddOns\SVUI_!Core\assets\textures\Alert\ALERT-TOP]],
        BOTTOM  = [[Interface\AddOns\SVUI_!Core\assets\textures\Alert\ALERT-BOTTOM]],
    },
    ["typeB"] = {
        COLOR   = {0.08, 0.4, 0},
        BG      = [[Interface\AddOns\SVUI_!Core\assets\textures\Alert\ALERT-BG-2]],
        LEFT    = [[Interface\AddOns\SVUI_!Core\assets\textures\Alert\ALERT-LEFT-2]],
        RIGHT   = [[Interface\AddOns\SVUI_!Core\assets\textures\Alert\ALERT-RIGHT-2]],
        TOP     = [[Interface\AddOns\SVUI_!Core\assets\textures\Alert\ALERT-TOP]],
        BOTTOM  = [[Interface\AddOns\SVUI_!Core\assets\textures\Alert\ALERT-BOTTOM]],
    },
};

local SetIconAlertColor = function(self, r, g, b)
    self.AlertPanel.icon:SetGradient('VERTICAL', (r*0.5), (g*0.5), (b*0.5), r, g, b)
end;

local SetAlertColor = function(self, r, g, b)
    self.AlertPanel:SetBackdropColor(r,g,b)
    self.AlertPanel.left:SetVertexColor(r,g,b)
    self.AlertPanel.right:SetVertexColor(r,g,b)
    self.AlertPanel.top:SetVertexColor(r,g,b)
    self.AlertPanel.bottom:SetVertexColor(r,g,b)
end;

MOD.Concepts["Alert"] = function(self, defaultStyle, frame, arg)
    if(not frame or (frame and frame.AlertPanel)) then return end

    if(not defaultStyle) then
        local size = frame:GetWidth() * 0.5;
        local lvl = frame:GetFrameLevel();

        if lvl < 1 then lvl = 1 end

        local alertpanel = CreateFrame("Frame", nil, frame)
        alertpanel:SetPoint("TOPLEFT", frame, "TOPLEFT", -25, 10)
        alertpanel:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 10, 10)
        alertpanel:SetHeight(size)
        alertpanel:SetFrameLevel(lvl - 1)

        --[[ FRAME BG ]]--
        alertpanel.bg = alertpanel:CreateTexture(nil, "BACKGROUND", nil, -5)
        alertpanel.bg:SetAllPoints()
        alertpanel.bg:SetTexture([[Interface\AddOns\SVUI_!Core\assets\textures\Alert\ALERT-FULL]])
        alertpanel.bg:SetGradient('VERTICAL', 0, 0, 0, .37, .32, .29)

        --[[ ICON BG ]]--
        alertpanel.icon = alertpanel:CreateTexture(nil, "BACKGROUND", nil, -2)
        alertpanel.icon:SetTexture([[Interface\AddOns\SVUI_!Core\assets\textures\Alert\ALERT-ICON-BORDER]])
        alertpanel.icon:SetGradient('VERTICAL', 1, 0.35, 0, 1, 1, 0)
        alertpanel.icon:SetPoint("LEFT", alertpanel, "LEFT", -10, 30)
        alertpanel.icon:SetSize(size, size)

        frame.AlertPanel = alertpanel
        frame.AlertColor = SetIconAlertColor
    else
        local alertType = arg and "typeB" or "typeA";

        local TEMPLATE = ALERT_TEMPLATE[alertType];
        local r,g,b = unpack(TEMPLATE.COLOR);
        local size = frame:GetHeight();
        local half = size * 0.5;
        local offset = size * 0.1;
        local lvl = frame:GetFrameLevel();

        if lvl < 1 then lvl = 1 end

        local alertpanel = CreateFrame("Frame", nil, frame)
        alertpanel:SetPoint("TOPLEFT", frame, "TOPLEFT", offset, 0)
        alertpanel:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -offset, 0)
        alertpanel:SetFrameLevel(lvl - 1)
        alertpanel:SetBackdrop({
            bgFile = TEMPLATE.BG
        })
        alertpanel:SetBackdropColor(r,g,b)

        --[[ LEFT ]]--
        alertpanel.left = alertpanel:CreateTexture(nil, "BORDER")
        alertpanel.left:SetTexture(TEMPLATE.LEFT)
        alertpanel.left:SetVertexColor(r,g,b)
        alertpanel.left:SetPoint("TOPRIGHT", alertpanel, "TOPLEFT", 0, 0)
        alertpanel.left:SetPoint("BOTTOMRIGHT", alertpanel, "BOTTOMLEFT", 0, 0)
        alertpanel.left:SetWidth(size)

        --[[ RIGHT ]]--
        alertpanel.right = alertpanel:CreateTexture(nil, "BORDER")
        alertpanel.right:SetTexture(TEMPLATE.RIGHT)
        alertpanel.right:SetVertexColor(r,g,b)
        alertpanel.right:SetPoint("TOPLEFT", alertpanel, "TOPRIGHT", 0, 0)
        alertpanel.right:SetPoint("BOTTOMLEFT", alertpanel, "BOTTOMRIGHT", 0, 0)
        alertpanel.right:SetWidth(size * 2)

        --[[ TOP ]]--
        alertpanel.top = alertpanel:CreateTexture(nil, "BORDER")
        alertpanel.top:SetTexture(TEMPLATE.TOP)
        alertpanel.top:SetPoint("BOTTOMLEFT", alertpanel, "TOPLEFT", 0, 0)
        alertpanel.top:SetPoint("BOTTOMRIGHT", alertpanel, "TOPRIGHT", 0, 0)
        alertpanel.top:SetHeight(half)

        --[[ BOTTOM ]]--
        alertpanel.bottom = alertpanel:CreateTexture(nil, "BORDER")
        alertpanel.bottom:SetTexture(TEMPLATE.BOTTOM)
        alertpanel.bottom:SetPoint("TOPLEFT", alertpanel, "BOTTOMLEFT", 0, 0)
        alertpanel.bottom:SetPoint("TOPRIGHT", alertpanel, "BOTTOMRIGHT", 0, 0)
        alertpanel.bottom:SetWidth(half)

        frame.AlertPanel = alertpanel
        frame.AlertColor = SetAlertColor
    end
end

--[[
##########################################################
SCROLL FRAME (COMPLEX) HANDLER
##########################################################
]]--
local ModifyScrollType1 = function(self, adjustable, frame, scale, yOffset, upButton, downButton)
    RemoveTextures(upButton)
    if(not upButton.icon) then
        local upW, upH = upButton:GetSize()
        self.Concepts["PageButton"](self, false, upButton)
        SquareButton_SetIcon(upButton, "UP")
        upButton:SetSize(upW + scale, upH + scale)
        if(yOffset) then
            local anchor, parent, relative, xBase, yBase = upButton:GetPoint()
            local yAdjust = (yOffset or 0) + yBase
            upButton:ClearAllPoints()
            upButton:SetPoint(anchor, parent, relative, xBase, yAdjust)
        end
    end
    RemoveTextures(downButton)
    if(not downButton.icon) then
        local dnW, dnH = downButton:GetSize()
        self.Concepts["PageButton"](self, false, downButton)
        SquareButton_SetIcon(downButton, "DOWN")
        downButton:SetSize(dnW + scale, dnH + scale)
        if(yOffset) then
            local anchor, parent, relative, xBase, yBase = downButton:GetPoint()
            local yAdjust = ((yOffset or 0) * -1) + yBase
            downButton:ClearAllPoints()
            downButton:SetPoint(anchor, parent, relative, xBase, yAdjust)
        end
    end
    if(not frame.BG) then
        frame.BG = frame:CreateTexture(nil, "BACKGROUND")
        frame.BG:SetPoint("TOPLEFT", upButton, "TOPLEFT", 1, -1)
        frame.BG:SetPoint("BOTTOMRIGHT", downButton, "BOTTOMRIGHT", -1, 1)
        frame.BG:SetTexture(SV.media.background.transparent)

        -- local fg = CreateFrame("Frame", nil, frame)
        -- fg:SetPoint("TOPLEFT", frame, "TOPLEFT", 18, -2)
        -- fg:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 6)
        -- fg:SetBackdrop(SV.media.backdrop.outline)
        -- frame.Brdr = fg
    end
    if(frame.SetThumbTexture) then
        frame:SetThumbTexture(SV.media.button.knob)
    end
end

local ModifyScrollType2 = function(self, adjustable, frame, scale)
    if(frame:GetOrientation() == "VERTICAL") then
        frame:SetWidth(12)
    else
        frame:SetHeight(12)
        for i=1, frame:GetNumRegions() do
            local child = select(i, frame:GetRegions())
            if(child and child:GetObjectType() == "FontString") then
                local anchor, parent, relative, x, y = child:GetPoint()
                if relative:find("BOTTOM") then
                    child:SetPoint(anchor, parent, relative, x, y - 4)
                end
            end
        end
    end

    RemoveTextures(frame)
    frame:SetBackdrop(nil)
    self.Methods["Frame"](self, frame, (not adjustable), "Transparent", true)
    frame:SetBackdropBorderColor(0.2,0.2,0.2)
    frame:SetThumbTexture(SV.media.button.knob)
    frame:DisableDrawLayer("BACKGROUND")
end

local ModifyBasicScroll = function(self, adjustable, frame, scale, yOffset, scrollName)
    local bg, track, top, bottom, mid, upButton, downButton
    bg = _G[("%sBG"):format(scrollName)] or frame.BG;
    if(bg) then bg:SetTexture("") end
    track = _G[("%sTrack"):format(scrollName)] or frame.Track;
    if(track) then track:SetTexture("") end
    top = _G[("%sTop"):format(scrollName)] or frame.Top;
    if(top) then top:SetTexture("") end
    bottom = _G[("%sBottom"):format(scrollName)] or frame.Bottom;
    if(bottom) then bottom:SetTexture("") end
    mid = _G[("%sMiddle"):format(scrollName)] or frame.Middle;
    if(mid) then mid:SetTexture("") end
    upButton = _G[("%sScrollUpButton"):format(scrollName)] or frame.ScrollUpButton;
    downButton = _G[("%sScrollDownButton"):format(scrollName)] or frame.ScrollDownButton;

    if(upButton and downButton) then
        ModifyScrollType1(self, adjustable, frame, scale, yOffset, upButton, downButton)
    elseif(frame.GetOrientation) then
        ModifyScrollType2(self, adjustable, frame, scale)
    end
end

local ModifyHybridScroll = function(self, adjustable, frame, scale, yOffset)
    local parent, bg, track, top, bottom, mid, upButton, downButton
    bg = frame.BG;
    if(bg) then bg:SetTexture("") end
    track = frame.trackBG or frame.Track;
    if(track) then track:SetTexture("") end
    top = frame.ScrollBarTop or frame.Top;
    if(top) then top:SetTexture("") end
    bottom = frame.ScrollBarBottom or frame.Bottom;
    if(bottom) then bottom:SetTexture("") end
    mid = frame.ScrollBarMiddle or frame.Middle;
    if(mid) then mid:SetTexture("") end
    parent = frame:GetParent()
    if parent then 
        upButton = parent.scrollUp or frame.ScrollUpButton;
        downButton = parent.scrollDown or frame.ScrollDownButton;
    end
    if(upButton and downButton) then
        ModifyScrollType1(self, adjustable, frame, scale, yOffset, upButton, downButton)
    elseif(frame.GetOrientation) then
        ModifyScrollType2(self, adjustable, frame, scale)
    end
end

MOD.Concepts["ScrollBar"] = function(self, adjustable, frame, scale, yOffset)
    if(not frame or (frame and frame.Panel)) then return end
    scale = scale or 5
    local scrollName = frame:GetName()
    if(scrollName) then
        local testForBasic = _G[("%sScrollBar"):format(scrollName)];
        if(testForBasic) then
            RemoveTextures(frame)
            scrollName = testForBasic:GetName()
            frame = testForBasic
            ModifyBasicScroll(self, adjustable, frame, scale, yOffset, scrollName)
        else 
            local testForBar = frame.ScrollBar or frame.scrollBar;
            if(testForBar) then
                RemoveTextures(frame)
                frame = testForBar
                ModifyHybridScroll(self, adjustable, frame, scale, yOffset)
            end
        end
    else 
        local testForBar = frame.ScrollBar or frame.scrollBar;
        if(testForBar) then
            RemoveTextures(frame)
            frame = testForBar
            ModifyHybridScroll(self, adjustable, frame, scale, yOffset)
        end
    end
end

--[[
##########################################################
SET METHOD
##########################################################
]]--
function MOD:Set(concept, ...)
    if(not concept) then return end

    local fn;
    local conceptString, flags = concept:gsub("!_", "");
    local param = true;
    if(flags and (flags > 0)) then
        param = false;
    end

    local nameString, typeflags = conceptString:gsub("Skin", "");
    if(typeflags and (typeflags > 0)) then
        fn = self.Concepts["Skin"];
        param = nameString
    else
        fn = self.Concepts[nameString];
    end

    if(fn) then
        local pass, catch = pcall(fn, self, param, ...)
        if(catch) then
            SV:HandleError("API", "SetStyle", catch);
            return
        end
    end
end
-- _G.Proxy_CreateFrame = CreateFrame;
-- _G.CreateFrame = function(frameType, frameName, parentFrame, template)
--     local f
--     if(template and template == "UIPanelButtonTemplate") then
--         f = Proxy_CreateFrame(frameType, frameName, parentFrame, template)
--     else
--         f = Proxy_CreateFrame(frameType, frameName, parentFrame, template)
--     end
--     return f
-- end
-- hooksecurefunc("CreateFrame", function(frameType, globalName, parent, template)
--     if(template and template:find("UIPanelButtonTemplate")) then
--         if(globalName) then
--             print(globalName .. ' -> ' .. template)
--         else
--             print(template)
--         end
--     end
-- end)
