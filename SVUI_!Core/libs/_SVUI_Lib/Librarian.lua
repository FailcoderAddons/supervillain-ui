--[[
Librarian is a library used to manage localization, packages, scripts, animations and data embedded
into the SVUI core addon.

It's main purpose is to keep all methods and logic needed to properly keep
core add-ins functioning outside of the core object and away from other libraries like LibStub.                                                                     
--]]
local _G            = getfenv(0)
local assert        = _G.assert;
local type          = _G.type;
local error         = _G.error;
local pairs         = _G.pairs;
local tostring      = _G.tostring;

local Librarian = _G["Librarian"]

if not Librarian then
    Librarian = Librarian or {libs = {}, arrested = {}, warrants = {}}
    _G["Librarian"] = Librarian
    
    function Librarian:NewLibrary(libName)
        assert(type(libName) == "string", "Missing Library Name")
        self.libs[libName] = self.libs[libName] or {}
        return self.libs[libName]
    end
    
    function Librarian:Fetch(libName, silent)
        if not self.libs[libName] and not silent then
            error(("Cannot find a library instance of %q."):format(tostring(libName)), 2)
        end
        return self.libs[libName]
    end

    local dead = function() return end

    function Librarian:LockLibrary(lib)
        local LibStub = _G.LibStub;
        if((self.warrants[lib]) or (not LibStub) or (not LibStub.libs)) then return end
        for libName,libObj in pairs(LibStub.libs) do
            if(libName:find(lib) and (not self.arrested[libName])) then
                self.warrants[lib] = true
                self.arrested[libName] = {}
                for k,v in pairs(libObj) do
                    if(type(v) == 'function') then
                        self.arrested[libName][k] = v
                        v = dead
                    end
                end
            end
        end
    end

    function Librarian:UnlockLibrary(lib)
        local LibStub = _G.LibStub;
        if((not LibStub) or (not LibStub.libs)) then return end
        for libName,libObj in pairs(LibStub.libs) do
            if(libName:find(lib) and (self.arrested[libName])) then
                for k,v in pairs(self.arrested[libName]) do
                    libObj[k] = v
                end
                self.warrants[lib] = nil
                self.arrested[libName] = nil
            end
        end
    end

    setmetatable(Librarian, { __call = Librarian.Fetch })
end
