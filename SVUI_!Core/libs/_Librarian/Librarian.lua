--- Librarian lib management library.
-- Librarian is a versioning manager for use with proprietary SVUI libraries.
-- @file Librarian
-- @author Steven Jackson (2014)
-- @release 1.0.0

--[[
@usage
Librarian is a library used to manage localization, packages, scripts, animations and data embedded
into the SVUI core addon.

It's main purpose is to keep all methods and logic needed to properly keep
core add-ins functioning outside of the core object.

It is also modifyiing LibStub to give me dominating control over which libraries are
allowed to be created and loaded regardless of versioning or timing.

The reasoning for this is due to the potential for other addon to get loaded earlier
and embed newer versions of lib dependencies which can be devastating.
--]]
local _G            = getfenv(0)
local select        = _G.select;
local assert        = _G.assert;
local type          = _G.type;
local error         = _G.error;
local pairs         = _G.pairs;
local next          = _G.next;
local ipairs        = _G.ipairs;
local loadstring    = _G.loadstring;
local setmetatable  = _G.setmetatable;
local rawset        = _G.rawset;
local rawget        = _G.rawget;
local tostring      = _G.tostring;
local tonumber      = _G.tonumber;
local tostring      = _G.tostring;
local xpcall        = _G.xpcall;
local table         = _G.table;
local tconcat       = table.concat;
local tremove       = table.remove;
local strmatch      = _G.strmatch;
local table_sort    = table.sort;
local bit           = _G.bit;
local band          = bit.band;
local math          = _G.math;
local min,max,abs   = math.min,math.max,math.abs;

local UIParent = _G.UIParent;
local GetScreenWidth = _G.GetScreenWidth;
local GetScreenHeight = _G.GetScreenHeight;
local IsAltKeyDown = _G.IsAltKeyDown;

local MAX_MINOR     = 999999999;
local Librarian     = _G.Librarian;

if not Librarian then
    ---------------------------------------------------------------------
    -- Global Librarian object.
    -- @todo Does this need to be global?
    ---------------------------------------------------------------------

    Librarian = { libs = {} };

    _G.Librarian = Librarian;

    ---------------------------------------------------------------------
    -- Adds a new lib to saved objects.
    -- @return Lib class object
    -- @param libName hashable name of the new library.
    ---------------------------------------------------------------------

    function Librarian:NewLibrary(libName)
        assert(type(libName) == "string", "Missing Library Name")
        self.libs[libName] = self.libs[libName] or {}
        return self.libs[libName]
    end

    ---------------------------------------------------------------------
    -- Retrieve a saved library object.
    -- @return Lib class object
    -- @param libName Saved name of the library.
    -- @param silent do not allow errors to propegate.
    ---------------------------------------------------------------------

    function Librarian:Fetch(libName, silent)
        if not self.libs[libName] and not silent then
            error(("Cannot find a library instance of %q."):format(tostring(libName)), 2)
        end
        return self.libs[libName]
    end

    setmetatable(Librarian, { __call = Librarian.Fetch })
end

local LibStub = _G.LibStub;
local dead = function() return end

if not LibStub then
    LibStub         = {libs = {}, minors = {}};
    _G.LibStub      = LibStub;

    function LibStub:GetLibrary(major, silent)
        if not self.libs[major] and not silent then
            error(("Cannot find a library instance of %q."):format(tostring(major)), 2)
        end
        return self.libs[major], self.minors[major]
    end

    function LibStub:IterateLibraries() return pairs(self.libs) end
    setmetatable(LibStub, { __call = LibStub.GetLibrary })
end

local LibStubNew = function(self, major, minor, replace)
    assert(type(major) == "string", "Bad argument #2 to `NewLibrary' (string expected)")
    minor = assert(tonumber(strmatch(minor, "%d+")), "Minor version must either be a number or contain a number.")

    local oldminor = self.minors[major]
    if(replace) then
        minor = MAX_MINOR
    end
    if(oldminor and oldminor >= minor) then return nil end
    self.libs[major] = self.libs[major] or {}
    self.minors[major] = minor
    --print('Returning: '..major..' v.'..minor)
    return self.libs[major], oldminor
end

local LibStubKill = function(self, major, silent)
    if not self.libs[major] and not silent then
        error(("Cannot find a library instance of %q."):format(tostring(major)), 2)
    end
    for key,obj in pairs(self.libs) do
        if(key:find(tostring(major))) then
            self.libs[key] = nil
        end
    end
end

local LibStubLock = function(self, major, silent)
    if(self.locked[major]) then return end
    for key,obj in pairs(self.libs) do
        if(key:find(tostring(major)) and (not self.recovery[key])) then
            self.locked[major] = true
            self.recovery[key] = {}
            for k,v in pairs(obj) do
                if(type(v) == 'function') then
                    self.recovery[key][k] = v
                    v = dead
                end
            end
        end
    end
end

local LibStubUnlock = function(self, major, silent)
    if(not self.locked[major]) then return end
    for key,obj in pairs(self.libs) do
        if(key:find(tostring(major)) and (self.recovery[key])) then
            for k,v in pairs(self.recovery[key]) do
                obj[k] = v
            end
            self.locked[major] = nil
            self.recovery[key] = nil
        end
    end
end

LibStub.minor       = MAX_MINOR;
LibStub.recovery    = {};
LibStub.locked      = {};
LibStub.NewLibrary  = LibStubNew;
LibStub.Kill        = LibStubKill;
LibStub.Lock        = LibStubLock;
LibStub.Unlock      = LibStubUnlock;
