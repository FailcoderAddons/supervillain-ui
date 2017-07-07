--- SVUI is our global addon object.
-- SuperVillain UI Core Module.
-- @module SVUI_Core
-- @author Steven Jackson (2014)
-- @release 1.0.0
-- @usage
--    -- Every other file will set a reference to the addon using this variable. Here is how we set it.
--
--    -- METHOD 1 ----------------------------------------------------------------
--    -- if we are setting this inside the core.lua file then use this method
--    local global = "SVUI_Global"    -- reference to SavedVariables
--    local errors = "SVUI_Errors"    -- reference to SavedVariables
--    local private = "SVUI_Private"  -- reference to SavedVariables
--    local media = "SVUI_Media"      -- reference to SavedVariables
--    local shared = "SVUI_Shared"    -- reference to SavedVariables
--
--    local Registry = Librarian("Registry")  -- now pull down the Registry object
--    -- finally we use the 'NewCore' function specifically for this
--    local SV = Registry:NewCore(global, errors, private, media, shared)
--
--    -- METHOD 2 ----------------------------------------------------------------
--    -- if we are setting the variable in any other file then use this method
--    local SV = _G['SVUI']

local _G = _G;
---- LUA ----
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
local getmetatable  = _G.getmetatable;
local setmetatable  = _G.setmetatable;
---- STRING ----
local string        = _G.string;
local split         = string.split;
local upper         = string.upper;
local format        = string.format;
local find          = string.find;
local match         = string.match;
local gsub          = string.gsub;
---- MATH ----
local math          = _G.math;
local floor         = math.floor
local random        = math.random;
---- TABLE ----
local table         = _G.table;
local tsort         = table.sort;
local tconcat       = table.concat;
local tremove       = _G.tremove;
local wipe          = _G.wipe;
---- BLIZZARD API ----
local collectgarbage        = _G.collectgarbage;
local ERR_NOT_IN_COMBAT     = _G.ERR_NOT_IN_COMBAT;

local RequestBattlefieldScoreData = _G.RequestBattlefieldScoreData;

local SVUILib = Librarian("Registry");

---- CONSTANTS ----

_G.BINDING_HEADER_SVUI = "SuperVillain UI";
_G.BINDING_NAME_SVUI_MARKERS = "Raid Markers";
_G.BINDING_NAME_SVUI_DOCKS = "Toggle Both Docks";
_G.BINDING_NAME_SVUI_DOCKS_LEFT = "Toggle Left Dock";
_G.BINDING_NAME_SVUI_DOCKS_RIGHT = "Toggle Right Dock";
_G.BINDING_NAME_SVUI_RIDE = "Let's Ride";
_G.BINDING_NAME_SVUI_DRAENORZONE = "Draenor Zone Ability";
_G.BINDING_NAME_SVUI_FRAMEDEBUGGER = "Supervillain UI: Frame Analyzer";

_G.SlashCmdList.RELOADUI = ReloadUI
_G.SLASH_RELOADUI1 = "/rl"
_G.SLASH_RELOADUI2 = "/reloadui"

_G.SVUI_ICON_COORDS = {0.1, 0.9, 0.1, 0.9};

---- LOCALS ----

local rez = GetCVar("gxFullscreenResolution");
local baseHeight = tonumber(rez:match("%d+x(%d+)"))
local baseWidth = tonumber(rez:match("(%d+)x%d+"))
local defaultDockWidth = baseWidth * 0.66;
local defaultCenterWidth = min(defaultDockWidth, 900);
local callbacks = {};
local numCallbacks = 0;
local playerName = UnitName("player");
local playerRealm = GetRealmName();
local playerClass = select(2, UnitClass("player"));
local errorPattern = "|cffff0000Error -- |r|cffff9900Required addon '|r|cffffff00%s|r|cffff9900' is %s.|r";

---- COMMON CONSTANTS ----

_G.SHOWORHIDE = SHOW .. "\\" .. HIDE;
_G.MINIMIZEORMAXIMIZE = MINIMIZE .. "\\" .. WINDOWED_MAXIMIZED;

---- BUILD CLASS COLOR GLOBAL, CAN BE OVERRIDDEN BY THE ADDON !ClassColors ----

local CUSTOM_CLASS_COLORS = _G.CUSTOM_CLASS_COLORS;

if(not CUSTOM_CLASS_COLORS) then
    local env = getfenv(0)
    env.CUSTOM_CLASS_COLORS = {}
    CUSTOM_CLASS_COLORS = env.CUSTOM_CLASS_COLORS

    local function RegisterCallback(self, m, h)
        assert(type(m) == "string" or type(m) == "function", "Bad argument #1 to :RegisterCallback (string or function expected)")
        if type(m) == "string" then
            assert(type(h) == "table", "Bad argument #2 to :RegisterCallback (table expected)")
            assert(type(h[m]) == "function", "Bad argument #1 to :RegisterCallback (m \"" .. m .. "\" not found)")
            m = h[m]
        end
        callbacks[m] = h or true
        numCallbacks = numCallbacks + 1
    end

    local function UnregisterCallback(self, m, h)
        assert(type(m) == "string" or type(m) == "function", "Bad argument #1 to :UnregisterCallback (string or function expected)")
        if type(m) == "string" then
            assert(type(h) == "table", "Bad argument #2 to :UnregisterCallback (table expected)")
            assert(type(h[m]) == "function", "Bad argument #1 to :UnregisterCallback (m \"" .. m .. "\" not found)")
            m = h[m]
        end
        callbacks[m] = nil
        numCallbacks = numCallbacks + 1
    end

    local function DispatchCallbacks()
        if (numCallbacks < 1) then return end
        for m, h in pairs(callbacks) do
            local ok, err = pcall(m, h ~= true and h or nil)
            if not ok then
                print("ERROR:", err)
            end
        end
    end

    local classes = {};
    local supercolors = {
        ["HUNTER"]        = { r = 0.454, g = 0.698, b = 0 },
        ["WARLOCK"]       = { r = 0.286, g = 0,     b = 0.788 },
        ["PRIEST"]        = { r = 0.976, g = 1,     b = 0.839 },
        ["PALADIN"]       = { r = 0.956, g = 0.207, b = 0.733 },
        ["MAGE"]          = { r = 0,     g = 0.796, b = 1 },
        ["ROGUE"]         = { r = 1,     g = 0.894, b = 0.117 },
        ["DRUID"]         = { r = 1,     g = 0.513, b = 0 },
        ["SHAMAN"]        = { r = 0,     g = 0.38,  b = 1 },
        ["WARRIOR"]       = { r = 0.698, g = 0.36,  b = 0.152 },
        ["DEATHKNIGHT"]   = { r = 0.847, g = 0.117, b = 0.074 },
        ["MONK"]          = { r = 0.015, g = 0.886, b = 0.38 },
        ["DEMONHUNTER"]   = { r = 0.286, g = 0,     b = 0.788 },
    };

    ---- IF WE NEED TO FORCE DEFAULT COLORS, USE THIS INSTEAD ----

    -- local supercolors = {
    --     ["HUNTER"]        = { r = 0.67,  g = 0.83,  b = 0.45 },
    --     ["WARLOCK"]       = { r = 0.58,  g = 0.51,  b = 0.79 },
    --     ["PRIEST"]        = { r = 1,     g = 1,     b = 1 },
    --     ["PALADIN"]       = { r = 0.96,  g = 0.55,  b = 0.73 },
    --     ["MAGE"]          = { r = 0.41,  g = 0.80,  b = 0.94 },
    --     ["ROGUE"]         = { r = 1,     g = 0.96,  b = 0.41 },
    --     ["DRUID"]         = { r = 1,     g = 0.49,  b = 0.04 },
    --     ["SHAMAN"]        = { r = 0,     g = 0.44,  b = 0.87 },
    --     ["WARRIOR"]       = { r = 0.78,  g = 0.61,  b = 0.43 },
    --     ["DEATHKNIGHT"]   = { r = 0.77,  g = 0.12,  b = 0.23 },
    --     ["MONK"]          = { r = 0.33,  g = 0.54,  b = 0.52 },
    -- };
    local classCount = 1;
    for class in pairs(RAID_CLASS_COLORS) do
      classes[classCount] = class;
      classCount=classCount+1;
    end
    tsort(classes)
    setmetatable(CUSTOM_CLASS_COLORS,{
        __index = function(t, k)
            if k == "RegisterCallback" then return RegisterCallback end
            if k == "UnregisterCallback" then return UnregisterCallback end
            if k == "DispatchCallbacks" then return DispatchCallbacks end
        end
    });
    for i, class in ipairs(classes) do
        local color = supercolors[class]
        local r, g, b = color.r, color.g, color.b
        local hex = ("ff%02x%02x%02x"):format(r * 255, g * 255, b * 255)
        if not CUSTOM_CLASS_COLORS[class] or not CUSTOM_CLASS_COLORS[class].r or not CUSTOM_CLASS_COLORS[class].g or not CUSTOM_CLASS_COLORS[class].b then
            CUSTOM_CLASS_COLORS[class] = {
                r = r,
                g = g,
                b = b,
                colorStr = hex,
            }
        end
    end
    classes = nil
end

-- SQUARE_BUTTON_TEXCOORDS = {
--     ["UP"] = {     0.45312500,    0.64062500,     0.01562500,     0.20312500};
--     ["DOWN"] = {   0.45312500,    0.64062500,     0.20312500,     0.01562500};
--     ["LEFT"] = {   0.23437500,    0.42187500,     0.01562500,     0.20312500};
--     ["RIGHT"] = {  0.42187500,    0.23437500,     0.01562500,     0.20312500};
--     ["DELETE"] = { 0.01562500,    0.20312500,     0.01562500,     0.20312500};
-- };

---- Global SVUI Object. We have to send the names ----
---- of our three SavedVariables files since the ----
---- WoW API has no method for parsing them in LUA. ----

local SV = SVUILib:NewCore("SVUI_Global", "SVUI_Errors", "SVUI_Private", "SVUI_Media", "SVUI_Shared")

SV.ConfigID           = "SVUI_!Options";
SV.class              = playerClass;
SV.GUID               = UnitGUID('player');
SV.Allegiance         = UnitFactionGroup("player");
SV.ClassRole          = "";
SV.SpecificClassRole  = "NONE";

SV.Screen = CreateFrame("Frame", "SVUIParent", UIParent);
SV.Screen:SetFrameLevel(UIParent:GetFrameLevel());
SV.Screen:SetPoint("CENTER", UIParent, "CENTER");
SV.Screen:SetSize(UIParent:GetSize());

SV.Hidden = CreateFrame("Frame", nil, UIParent);
SV.Hidden:Hide();

SV.RollFrames         = {};
SV.SystemAlert        = {};

SVUILib.CONSTRAINTS.IGNORED["LAYOUT"] = true;
SVUILib.CONSTRAINTS.IGNORED["REPORT_SLOTS"] = true;

SVUILib.CONSTRAINTS.PROTECTED["extended"] = true;
SVUILib.CONSTRAINTS.PROTECTED["shared"] = true;
SVUILib.CONSTRAINTS.PROTECTED["color"] = true;
SVUILib.CONSTRAINTS.PROTECTED["bordercolor"] = true;
SVUILib.CONSTRAINTS.PROTECTED["Filters"] = true;


SV.mediadefaults      = {};
SV.defaults           = {
    LAYOUT = {},
    Filters = {},
    screen = {
        autoScale = true,
        multiMonitor = false,
        advanced = false,
        scaleAdjust = 0.64,
        forcedWidth = baseWidth,
        forcedHeight = baseHeight,
    },
    general = {
        loginmessage = true,
        logincredits = true,
        cooldown = true,
        useDraggable = true,
        saveDraggable = false,
        taintLog = false,
        stickyFrames = true,
        graphSize = 50,
        loot = true,
        lootRoll = true,
        lootRollWidth = 328,
        lootRollHeight = 28,
        filterErrors = true,
        hideErrorFrame = true,
        customClassColor = false,
        errorFilters = {
            [INTERRUPTED] = false,
            [ERR_ABILITY_COOLDOWN] = true,
            [ERR_ATTACK_CHANNEL] = false,
            [ERR_ATTACK_CHARMED] = false,
            [ERR_ATTACK_CONFUSED] = false,
            [ERR_ATTACK_DEAD] = false,
            [ERR_ATTACK_FLEEING] = false,
            [ERR_ATTACK_MOUNTED] = true,
            [ERR_ATTACK_PACIFIED] = false,
            [ERR_ATTACK_STUNNED] = false,
            [ERR_ATTACK_NO_ACTIONS] = false,
            [ERR_AUTOFOLLOW_TOO_FAR] = false,
            [ERR_BADATTACKFACING] = false,
            [ERR_BADATTACKPOS] = false,
            [ERR_CLIENT_LOCKED_OUT] = false,
            [ERR_GENERIC_NO_TARGET] = true,
            [ERR_GENERIC_NO_VALID_TARGETS] = true,
            [ERR_GENERIC_STUNNED] = false,
            [ERR_INVALID_ATTACK_TARGET] = true,
            [ERR_ITEM_COOLDOWN] = true,
            [ERR_NOEMOTEWHILERUNNING] = false,
            [ERR_NOT_IN_COMBAT] = false,
            [ERR_NOT_WHILE_DISARMED] = false,
            [ERR_NOT_WHILE_FALLING] = false,
            [ERR_NOT_WHILE_MOUNTED] = false,
            [ERR_NO_ATTACK_TARGET] = true,
            [ERR_OUT_OF_ENERGY] = true,
            [ERR_OUT_OF_FOCUS] = true,
            [ERR_OUT_OF_MANA] = true,
            [ERR_OUT_OF_RAGE] = true,
            [ERR_OUT_OF_RANGE] = true,
            [ERR_OUT_OF_RUNES] = true,
            [ERR_OUT_OF_RUNIC_POWER] = true,
            [ERR_SPELL_COOLDOWN] = true,
            [ERR_SPELL_OUT_OF_RANGE] = false,
            [ERR_TOO_FAR_TO_INTERACT] = false,
            [ERR_USE_BAD_ANGLE] = false,
            [ERR_USE_CANT_IMMUNE] = false,
            [ERR_USE_TOO_FAR] = false,
            [SPELL_FAILED_BAD_IMPLICIT_TARGETS] = true,
            [SPELL_FAILED_BAD_TARGETS] = true,
            [SPELL_FAILED_CASTER_AURASTATE] = true,
            [SPELL_FAILED_NO_COMBO_POINTS] = true,
            [SPELL_FAILED_SPELL_IN_PROGRESS] = true,
            [SPELL_FAILED_TARGET_AURASTATE] = true,
            [SPELL_FAILED_TOO_CLOSE] = false,
            [SPELL_FAILED_UNIT_NOT_INFRONT] = false,
        }
    },
    Extras = {
        autoRoll = false,
        autoRollDisenchant = false,
        autoRollMaxLevel = false,
        autoRollSoulbound = true,
        autoRollQuality = '2',
        vendorGrays = true,
        autoAcceptInvite = false,
        autorepchange = false,
        pvpautorelease = false,
        autoquestcomplete = false,
        autoquestreward = false,
        autoquestaccept = false,
        autodailyquests = false,
        autopvpquests = false,
        skipcinematics = false,
        mailOpener = true,
        autoRepair = "PLAYER",
        threatbar = false,
        woot = true,
        pvpinterrupt = true,
        lookwhaticando = false,
        reactionChat = false,
        reactionEmote = false,
        sharingiscaring = false,
        arenadrink = true,
        stupidhat = true,
    },
    Gear = {
        durability = {
            enable = true,
            onlydamaged = true,
        },
        labels = {
            characterItemLevel = true,
            inventoryItemLevel = true,
            characterGearSet = true,
            inventoryGearSet = true,
        },
        specialization = {
            enable = false,
            primary = "none",
            secondary = "none",
        },
        battleground = {
            enable = false,
            primary = "none",
            secondary = "none",
        },
    },
    FunStuff = {
        drunk = true,
        NPC = true,
        comix = '1',
        comixLastState = '1',
        gamemenu = '1',
        afk = '1',
    },
    Dock = {
        dockWidth = 412,
        dockHeight = 224,
        dockOpacity = 1,
        backdrop = true,
        dockLeftWidth = 412,
        dockLeftHeight = 224,
        dockRightWidth = 412,
        dockRightHeight = 224,
        dockTopLeftWidth = 412,
        dockTopLeftHeight = 224,
        dockTopRightWidth = 412,
        dockTopRightHeight = 224,
        dockCenterWidth = defaultCenterWidth,
        dockCenterHeight = 20,
        buttonSize = 30,
        buttonSpacing = 4,
        topPanel = true,
        bottomPanel = true,
        dockTools = {
            garrison = true,
            firstAid = true,
            cooking = true,
            archaeology = true,
            primary = true,
            secondary = true,
            hearth = true,
            specswap = true,
            leader = true,
            breakstuff = true,
            power = false
        },
        hearthOptions = {
            left = 6948,
            right = 110560
        },
    },
    REPORT_SLOTS = {
        ['1'] = { "Experience Bar", "Time", "System" },
        ['2'] = { "Gold", "Friends", "Durability Bar" },
        ['3'] = { "None", "None", "None" },
        ['4'] = { "None", "None", "None" },
    },
    Reports = {
        backdrop = false,
        shortGold = true,
        localtime = true,
        time24 = false,
        battleground = true,
    },
};

---- EMBEDDED LIBS ----

SV.Options = {
    type = "group",
    name = "|cff339fffUI Options|r",
    args = {
        SVUI_Header = {
            order = 1,
            type = "header",
            name = ("Powered By |cffff9900SVUI|r - %s: |cff99ff33%s|r"):format(SV.L["Version"], SV.Version),
            width = "full"
        },
        profiles = {
            order = 9997,
            type = "group",
            name = SV.L["Profiles"],
            childGroups = "tab",
            args = {}
        },
        credits = {
            type = "group",
            name = SV.L["Credits"],
            order = -1,
            args = {
                new = {
                    order = 1,
                    type = "description",
                    name = function() return SV:PrintCredits() end
                }
            }
        }
    }
};

local function _tablecopy(d, s)
    if(type(s) ~= "table") then return end
    if(type(d) ~= "table") then return end
    for k, v in pairs(s) do
        local saved = d[k]
        if type(v) == "table" then
            if not saved then d[k] = {} end
            _tablecopy(d[k], v)
        elseif(saved == nil or (saved and type(saved) ~= type(v))) then
            d[k] = v
        end
    end
end

local function _removedeprecated()
    ---- BEGIN DEPRECATED ----
    if(_G.SVUI_Filters and (not _G.SVUI_TRANSFER_WIZARD)) then
        _tablecopy(SV.db.Filters, _G.SVUI_Filters)
        _G.SVUI_Filters = nil
    end
    ---- END DEPRECATED ----
end

local function _needsupdate(value, lowMajor, lowMinor, lowPatch)
    _removedeprecated();
    lowMajor = lowMajor or 0;
    lowMinor = lowMinor or 0;
    lowPatch = lowPatch or 0;
    local version = value or '0.0';
    if(version and type(version) ~= string) then
        version = tostring(version)
    end
    if(not version) then
       ---- print('No Version Found') ----
        return true
    end
    local vt = version:explode(".")
    local MAJOR,MINOR,PATCH = unpack(vt)
    ---- print(PATCH)print(type(lowPatch)) ----
    if(PATCH and (lowPatch > 0)) then
        if(type(PATCH) == "string") then
            PATCH = tonumber(PATCH)
        end
        if(type(PATCH) == "number" and PATCH < lowPatch) then
            SVUILib:CleanUpData(true);
            SVUILib:SaveSafeData("install_version", SV.Version);
        end
    end
    if(MINOR and (lowMinor > 0)) then
        if(type(MINOR) == "string") then
            MINOR = tonumber(MINOR)
        end
        if(type(MINOR) == "number" and MINOR < lowMinor) then
            SVUILib:CleanUpData(true);
            SVUILib:SaveSafeData("install_version", SV.Version);
        end
    end
    if(MAJOR and (lowMajor > 0)) then
        if(type(MAJOR) == "string") then
            MAJOR = tonumber(MAJOR)
        end
        if(type(MAJOR) == "number" and MAJOR < lowMajor) then
            return true
        else
            return false
        end
    else
        return true
    end
end

local SetLoginMessage;
do
  ---------------------------------------------------------------------
  -- Messages
  -- @section MESSAGES Addon Message Handlers
  ---------------------------------------------------------------------
    local commandments = {
        {
            "schemes diabolical",
            "henchmen in-line",
            "entrances grand",
            "battles glorious",
            "power absolute",
        },
        {
            "traps inescapable",
            "enemies overthrown",
            "monologues short",
            "victories infamous",
            "identity a mystery",
        }
    };
    local messagePattern = "|cffFF2F00%s:|r";
    local debugPattern = "|cffFF2F00%s|r [|cff992FFF%s|r]|cffFF2F00:|r";
    local testPattern = "Version |cffAA78FF%s|r, Build |cffAA78FF%s|r."

    local function _send_message(msg, prefix)
        if(type(msg) == "table") then
             msg = tostring(msg)
        end
        if(not msg) then return end
        if(prefix) then
            local outbound = ("%s %s"):format(prefix, msg);
            print(outbound)
        else
            print(msg)
        end
    end

    SetLoginMessage = function(self)
        if(not self.NameID) then return end
        local prefix = (messagePattern):format(self.NameID)
        local first = commandments[1][random(1,5)]
        local second = commandments[2][random(1,5)]
        local custom_msg = (self.L["LOGIN_MSG"]):format(first, second)
        _send_message(custom_msg, prefix)
        local login_msg = (self.L["LOGIN_MSG2"]):format(self.Version)
        ---- local login_msg = (testPattern):format(self.Version, self.GameVersion) ----
        _send_message(login_msg, prefix)
    end

    ---------------------------------------------------------------------
    -- Send messages to the scrolling message frame (combat text).
    -- @function SCTMessage
    -- @tparam string message The dialog to be displayed.
    -- @param red Text coloring, red value.
    -- @param green Text coloring, green value.
    -- @param blue Text coloring, blue value.
    -- @param displayType Special animation type (STICKY, CRITICAL or nil).
    -- @usage SV:SCTMessage('My message', 0.1, 0.2, 0.3, 'STICKY')
    ---------------------------------------------------------------------

    function SV:SCTMessage(message, red, green, blue, displayType)
        ---- /script CombatText_AddMessage("TESTING", COMBAT_TEXT_SCROLL_FUNCTION, 1, 1, 0) ----
        if not _G.CombatText_AddMessage then return end
        _G.CombatText_AddMessage(message, COMBAT_TEXT_SCROLL_FUNCTION, red, green, blue, displayType)
    end

    ---------------------------------------------------------------------
    -- Send messages to the chat frame prefixed with the addon branding.
    -- @function AddonMessage
    -- @tparam string message The dialog to be displayed.
    ---------------------------------------------------------------------

    function SV:AddonMessage(message)
        local outbound = (messagePattern):format(self.NameID)
        _send_message(message, outbound)
    end

    ---------------------------------------------------------------------
    -- Send messages to the chat frame as if they came from your character.
    -- @function CharacterMessage
    -- @tparam string message The dialog to be displayed.
    ---------------------------------------------------------------------

    function SV:CharacterMessage(message)
        local outbound = (messagePattern):format(playerName)
        _send_message(message, outbound)
    end
end

---------------------------------------------------------------------
-- Utilities
-- @section UTILITIES Utilities used and shared by the SVUI core.
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Dummy function used to override existing methods, effectively killing them.
-- @function fubar
-- @return nothing.
-- @usage
--   -- Kill a function
--   SomeObject.some_function = SV.fubar
---------------------------------------------------------------------

function SV:fubar() return end

---------------------------------------------------------------------
-- Request specific 'Static Popup' windows.
-- @function StaticPopup_Show
-- @tparam string arg Name of the popup
-- @usage
--   -- Open the 'Reload UI' popup
--   SV:StaticPopup_Show('RL_CLIENT')
---------------------------------------------------------------------

function SV:StaticPopup_Show(arg)
    if arg == "ADDON_ACTION_FORBIDDEN" then
        StaticPopup_Hide(arg)
    end
end

---------------------------------------------------------------------
-- Reset all SVUI created settings to defaults.
-- @function ResetAllUI
---------------------------------------------------------------------

function SV:ResetAllUI(confirmed)
    if InCombatLockdown()then
        SV:AddonMessage(ERR_NOT_IN_COMBAT)
        return
    end
    if(not confirmed) then
        SV:StaticPopup_Show('RESET_UI_CHECK')
        return
    end
    SV.Setup:Reset()
    SV.Events:Trigger("FULL_UI_RESET");
end

---------------------------------------------------------------------
-- Reset layout positions back to their default.
-- @function ResetUI
---------------------------------------------------------------------

function SV:ResetUI(confirmed)
    if InCombatLockdown()then
        self:AddonMessage(ERR_NOT_IN_COMBAT)
        return
    end
    if(not confirmed) then
        self:StaticPopup_Show('RESETMOVERS_CHECK')
        return
    end
    self:ResetAnchors()
end

---------------------------------------------------------------------
-- Open the config menu ('/sv').
-- @function ToggleConfig
---------------------------------------------------------------------

function SV:ToggleConfig()
    if InCombatLockdown() then
        self:AddonMessage(ERR_NOT_IN_COMBAT)
        self:RegisterEvent('PLAYER_REGEN_ENABLED')
        return
    end
    self.OptionsStandby = nil
    if not IsAddOnLoaded(self.ConfigID) then
        local _,_,_,_,_,state = GetAddOnInfo(self.ConfigID)
        if state ~= "MISSING" and state ~= "DISABLED" then
            LoadAddOn(self.ConfigID)
        else
            local errorMessage = (errorPattern):format(self.ConfigID, state)
            self:AddonMessage(errorMessage)
            return
        end
    end
    local aceConfig = LibStub("AceConfigDialog-3.0", true)
    if(aceConfig) then
        local switch = not aceConfig.OpenFrames[self.NameID] and "Open" or "Close"
        aceConfig[switch](aceConfig, self.NameID)
        GameTooltip:Hide()
    end
end

---------------------------------------------------------------------
-- Checks to see which (if any) version of the core that the client has installed.
-- @function VersionCheck
---------------------------------------------------------------------

function SV:VersionCheck()
    local delayed;
    if(_G.SVUI_TRANSFER_WIZARD) then
        local copied = SVUILib:GetSafeData("transfer_wizard_used");
        if(not copied) then
            delayed = true;
            _G.SVUI_TRANSFER_WIZARD()
        end
    end
    if(not delayed) then
        local version = SVUILib:GetSafeData("install_version");
        if(not version or (version and _needsupdate(version, 1, 1, 0))) then
            self.Setup:Install(true)
        end
    end
end

---------------------------------------------------------------------
-- Reloads all current packages and modules.
-- @function RefreshEverything
---------------------------------------------------------------------

function SV:RefreshEverything(bypass)
    self:UpdateSharedMedia();
    self:UpdateAnchors();
    SVUILib:RefreshAll();
    if not bypass then
        self:VersionCheck()
    end
end

---- EVENT HANDLERS ----

function SV:PLAYER_ENTERING_WORLD()
    self.GUID = UnitGUID('player');
    if(not self.ClassRole or self.ClassRole == "") then
        self:PlayerInfoUpdate()
    else
        self:GearSwap()
    end
    if(not self.MediaInitialized) then
        self:RefreshAllMedia()
    end
    local _,instanceType = IsInInstance()
    if(instanceType == "pvp") then
        self.BGTimer = self.Timers:ExecuteLoop(RequestBattlefieldScoreData, 5)
    elseif(self.BGTimer) then
        self.Timers:RemoveLoop(self.BGTimer)
        self.BGTimer = nil
    end

    if(not InCombatLockdown()) then
        collectgarbage("collect")
    end
end

function SV:PET_BATTLE_CLOSE()
    self:AuditVisibility()
    SVUILib:LiveUpdate()
    ---- self.Events:Trigger("FONT_GROUP_UPDATED", "chatdialog", "chattab"); ----
end

function SV:PET_BATTLE_OPENING_START()
    self:AuditVisibility(true);
    ---- self.Events:Trigger("FONT_GROUP_UPDATED", "chatdialog", "chattab"); ----
end

function SV:PLAYER_REGEN_DISABLED()
    local forceClosed = false;

    if(self.OptionsLoaded) then
        local aceConfig = LibStub("AceConfigDialog-3.0")
        if aceConfig.OpenFrames[self.NameID] then
            self:RegisterEvent("PLAYER_REGEN_ENABLED")
            aceConfig:Close(self.NameID)
            self.OptionsStandby = true
            forceClosed = true
        end
    end

    if(self:ForceAnchors(forceClosed) == true) then
        self:AddonMessage(ERR_NOT_IN_COMBAT)
    end

    if(self.NeedsFrameAudit) then
        self:AuditVisibility()
    end
end

function SV:PLAYER_REGEN_ENABLED()
    self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    if(self.OptionsStandby) then
        self:ToggleConfig()
    end
end

function SV:TaintHandler(event, taint, sourceName, sourceFunc)
    if GetCVarBool('scriptErrors') ~= 1 then return end
    local errorString = ("Error Captured: %s->%s->{%s}"):format(taint, sourceName or "Unknown", sourceFunc or "Unknown")
    self:AddonMessage(errorString)
end

---- LOAD FUNCTIONS ----

function SV:ReLoad()
    self:RefreshAllMedia();
    self:UpdateAnchors();
    if(self.DebugMode) then
        self:AddonMessage("User settings updated");
    end
end

function SV:PreLoad()
    self:RegisterEvent('PLAYER_REGEN_DISABLED');
    self:RegisterEvent("PLAYER_ENTERING_WORLD");
    self:RegisterEvent("UI_SCALE_CHANGED");
    self:RegisterEvent("PET_BATTLE_CLOSE");
    self:RegisterEvent("PET_BATTLE_OPENING_START");
    self:RegisterEvent("ADDON_ACTION_BLOCKED", "TaintHandler");
    self:RegisterEvent("ADDON_ACTION_FORBIDDEN", "TaintHandler");
    self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", "PlayerInfoUpdate");
    self:RegisterEvent("PLAYER_TALENT_UPDATE", "PlayerInfoUpdate");
    self:RegisterEvent("CHARACTER_POINTS_CHANGED", "PlayerInfoUpdate");
    self:RegisterEvent("UNIT_INVENTORY_CHANGED", "PlayerInfoUpdate");
    self:RegisterEvent("UPDATE_BONUS_ACTIONBAR", "PlayerInfoUpdate");
end

function SV:Initialize()
    self:UI_SCALE_CHANGED()
    self.Events:TriggerOnce("LOAD_ALL_ESSENTIALS");
    self.Events:TriggerOnce("LOAD_ALL_WIDGETS");

    SVUILib:Launch();

    self:UI_SCALE_CHANGED("PLAYER_LOGIN")
    self:PlayerInfoUpdate();
    self:VersionCheck();
    self:RefreshAllMedia();

    SVUILib:LoadScripts();
    self.Events:TriggerOnce("CORE_INITIALIZED");

    hooksecurefunc("StaticPopup_Show", self.StaticPopup_Show);
    hooksecurefunc("CloseSpecialWindows", function() SV.OptionsStandby = nil; SV.Events:Trigger("SPECIAL_FRAMES_CLOSED") end)

    if self.db.general.loginmessage then
        SetLoginMessage(self);
    end

    if(self.DebugMode and self.HasErrors and self.ScriptError) then
        self:ShowErrors();
        wipe(self.ERRORLOG)
    end

    ---- print(p1 .. ", " .. p2:GetName() .. ", " .. p3 .. ", " .. p4 .. ", " .. p5) ----

    collectgarbage("collect");

    if self.db.general.logincredits then
        self.Timers:ExecuteTimer(self.RollCredits, 10)
    end
end

---- ################# ----
---- THE CLEANING LADY ----
---- ################# ----

-- Causing script ran too long errors post 7.2.5
--[[local LemonPledge = 0;
local Consuela = CreateFrame("Frame")
Consuela:RegisterAllEvents()
Consuela:SetScript("OnEvent", function(self, event)
    LemonPledge = LemonPledge  +  1
    ---- print(event) ----
    if(InCombatLockdown()) then return end;
    if(LemonPledge > 10000) then
        collectgarbage("collect");
        LemonPledge = 0;
    end
end)]]--
