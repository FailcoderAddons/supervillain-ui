--[[
Linguist is a simple localization component. Seriously, thats it!
--]]

--[[ LOCALIZED GLOBALS ]]--
--GLOBAL NAMESPACE
local _G = getfenv(0);
--LUA
local select        = _G.select;
local assert        = _G.assert;
local rawset        = _G.rawset;
local rawget        = _G.rawget;
local getmetatable  = _G.getmetatable;
local setmetatable  = _G.setmetatable;
--BLIZZARD API
local GetLocale             = _G.GetLocale;

--[[ LIB CONSTRUCT ]]--

local lib = Librarian:NewLibrary("Linguist")

if not lib then return end -- No upgrade needed

--[[ COMMON LOCAL VARS ]]--

local activeLocale

local failsafe = function() assert(false) end

--LINGUIST META METHODS
local metaread = {
    __index = function(self, key)
        rawset(self, key, key)
        return key
    end
}

local defaultwrite = setmetatable({}, {
    __newindex = function(self, key, value)
        if not rawget(activeLocale, key) then
            rawset(activeLocale, key, value == true and key or value)
        end
    end,
    __index = failsafe
})

local metawrite = setmetatable({}, {
    __newindex = function(self, key, value)
        rawset(activeLocale, key, value == true and key or value)
    end,
    __index = failsafe
})

--LINGUIST STORAGE
lib.Localization = setmetatable({}, metaread);

--LINGUIST PUBLIC METHOD
function lib:Lang(locale, isDefault)
    if(not locale) then
        return self.Localization
    else
        local GAME_LOCALE = GetLocale()
        if GAME_LOCALE == "enGB" then GAME_LOCALE = "enUS" end

        activeLocale = self.Localization

        if isDefault then
            return defaultwrite
        elseif(locale == GAME_LOCALE) then
            return metawrite
        end
    end
end
