--[[
  /$$$$$$                                      /$$
 /$$__  $$                                    | $$
| $$  \__/  /$$$$$$  /$$   /$$ /$$$$$$$   /$$$$$$$  /$$$$$$$
|  $$$$$$  /$$__  $$| $$  | $$| $$__  $$ /$$__  $$ /$$_____/
 \____  $$| $$  \ $$| $$  | $$| $$  \ $$| $$  | $$|  $$$$$$
 /$$  \ $$| $$  | $$| $$  | $$| $$  | $$| $$  | $$ \____  $$
|  $$$$$$/|  $$$$$$/|  $$$$$$/| $$  | $$|  $$$$$$$ /$$$$$$$/
 \______/  \______/  \______/ |__/  |__/ \_______/|_______/
--]]

--[[ LOCALIZED GLOBALS ]]--
--GLOBAL NAMESPACE
local _G = getfenv(0);
--LUA
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
--STRING
local string        = _G.string;
local upper         = string.upper;
local format        = string.format;
local find          = string.find;
local match         = string.match;
local gsub          = string.gsub;
--MATH
local math          = _G.math;
local random        = math.random;
local floor         = math.floor
--TABLE
local table         = _G.table;
local tsort         = table.sort;
local tconcat       = table.concat;
local tremove       = _G.tremove;
local twipe         = _G.wipe;

local PlaySoundFile         = _G.PlaySoundFile;

--[[ LIB CONSTRUCT ]]--

local lib = Librarian:NewLibrary("Sounds")

if not lib then return end -- No upgrade needed

--[[ DUMMY FALLBACK ]]--

local BLANK_FOLEY = function()
    return;
end;

--[[ LIB MASTER LIST ]]--

lib.Master = {};

-- do
--     local DEFAULT_SOUND_TYPES = { 'button', 'error', 'window', 'misc' };

--     for i = 1, #DEFAULT_SOUND_TYPES do
--         local key = DEFAULT_SOUND_TYPES[i];
--         lib.Master[key] = {};
--     end
-- end

--[[ LIB TYPE CONTROLLERS ]]--

lib.Effects = {};
lib.Blends = {};

--[[ LIB METHODS ]]--

function lib:Register(soundType, soundFile)
    soundType = soundType:lower();
    if(not self.Master[soundType]) then self.Master[soundType] = {} end;
    local count = #self.Master + 1;
    self.Master[soundType][count] = soundFile;
end;

--[[ BLENDED SOUND EFFECTS ]]--

local BlendedSound_Effect = function(self)
    local key, sound, list;
    local bank = self.Bank;
    local channels = self.Channels;
    for i = 1, channels do
        key = random(1, #bank[i]);
        sound = bank[i][key];
        PlaySoundFile(sound);
    end
end

function lib:Blend(blendName, ...)
    blendName = blendName:lower();
    if(not self.Blends[blendName]) then
        self.Blends[blendName] = {};
        self.Blends[blendName].Bank = {};

        local numChannels = select('#', ...)

        for i = 1, numChannels do
            local soundType = select(i, ...)
            soundType = soundType:lower();
            if not soundType then break end
            if(not self.Master[soundType]) then
                self.Master[soundType] = {};
            end
            self.Blends[blendName].Bank[i] = self.Master[soundType];
        end

        self.Blends[blendName].Channels = numChannels;
        self.Blends[blendName].Foley = BlendedSound_Effect;

        setmetatable(self.Blends[blendName], { __call = self.Blends[blendName].Foley })
    end

    if(self.Blends[blendName]) then
        return self.Blends[blendName]
    else
        return BLANK_FOLEY
    end
end;

--[[ STANDARD SOUND EFFECTS ]]--

local StandardSound_Effect = function(self)
    local key, sound, list;
    local bank = self.Bank;
    local channels = self.Channels;
    for i = 1, channels do
        list = bank[i];
        key = random(1,#list);
        sound = list[key];
        PlaySoundFile(sound)
    end
end

function lib:Effect(effectName)
    effectName = effectName:lower();
    if(not self.Effects[effectName]) then
        self.Effects[effectName] = {};

        if(not self.Master[effectName]) then
            self.Master[effectName] = {};
        end

        self.Effects[effectName].Bank = self.Master[effectName];
        self.Effects[effectName].Foley = StandardSound_Effect;

        setmetatable(self.Effects[effectName], { __call = self.Effects[effectName].Foley })
    end

    if(self.Effects[effectName]) then
        return self.Effects[effectName]
    else
        return BLANK_FOLEY
    end
end;
