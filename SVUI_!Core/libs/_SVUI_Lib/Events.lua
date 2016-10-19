--[[
 /$$$$$$$$                              /$$
| $$_____/                             | $$
| $$    /$$    /$$ /$$$$$$  /$$$$$$$  /$$$$$$   /$$$$$$$
| $$$$$|  $$  /$$//$$__  $$| $$__  $$|_  $$_/  /$$_____/
| $$__/ \  $$/$$/| $$$$$$$$| $$  \ $$  | $$   |  $$$$$$
| $$     \  $$$/ | $$_____/| $$  | $$  | $$ /$$\____  $$
| $$$$$$$$\  $/  |  $$$$$$$| $$  | $$  |  $$$$//$$$$$$$/
|________/ \_/    \_______/|__/  |__/   \___/ |_______/
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
local floor         = math.floor
--TABLE
local table         = _G.table;
local tsort         = table.sort;
local tconcat       = table.concat;
local tremove       = _G.tremove;
local twipe         = _G.wipe;

--[[ LIB CONSTRUCT ]]--

local lib = Librarian:NewLibrary("Events")

if not lib then return end -- No upgrade needed

--[[ ADDON DATA ]]--

local CoreName, CoreObject  = ...

--[[ LIB CALLBACK STORAGE ]]--

lib.Triggers = {};
lib.FireOnce = {};
lib.LockCallback = {};
lib.UnlockCallback = {};

--[[ EVENT TRIGGERING ]]--

function lib:Trigger(eventName, ...)
    if(not eventName) then return end;
    --print(eventName)
    if(self.Triggers[eventName]) then
        for i=1, #self.Triggers[eventName] do
            local fn = self.Triggers[eventName][i];
            if(fn and type(fn) == "function") then
                local _, catch = pcall(fn, ...)
                if(catch) then
                    CoreObject:HandleError("Librarian:Events:Trigger(" .. eventName .. "):", "callback", catch)
                end
            end
        end
    elseif(self.FireOnce[eventName]) then
        for i=1, #self.FireOnce[eventName] do
            local fn = self.FireOnce[eventName][i];
            if(fn and type(fn) == "function") then
                local _, catch = pcall(fn, ...)
                if(catch) then
                    CoreObject:HandleError("Librarian:Events:Trigger(" .. eventName .. "):", "callback", catch)
                end
            end
        end

        self.FireOnce[eventName] = nil;
    end
end

function lib:TriggerOnce(eventName, ...)
    if(not eventName) then return end;
    if(self.Triggers[eventName]) then
        for i=1, #self.Triggers[eventName] do
            local fn = self.Triggers[eventName][i];
            if(fn and type(fn) == "function") then
                local _, catch = pcall(fn, ...)
                if(catch) then
                    CoreObject:HandleError("Librarian:Events:TriggerOnce(" .. eventName .. "):", "callback", catch)
                end
            end
        end

        self.Triggers[eventName] = nil;

    elseif(self.FireOnce[eventName]) then
        for i=1, #self.FireOnce[eventName] do
            local fn = self.FireOnce[eventName][i];
            if(fn and type(fn) == "function") then
                local _, catch = pcall(fn, ...)
                if(catch) then
                    CoreObject:HandleError("Librarian:Events:TriggerOnce(" .. eventName .. "):", "callback", catch)
                end
            end
        end

        self.FireOnce[eventName] = nil;
    end
end

--[[ REGISTRATION ]]--

function lib:On(event, callback, always)
    if((not event) or (not callback)) then return end;
    if(type(callback) == "function") then
        if(always) then
            if(not self.Triggers[event]) then
                self.Triggers[event] = {}
            end
            self.Triggers[event][#self.Triggers[event] + 1] = callback
        else
            if(not self.FireOnce[event]) then
                self.FireOnce[event] = {}
            end
            self.FireOnce[event][#self.FireOnce[event] + 1] = callback
        end
    end
end

function lib:OnLock(callback)
    if(callback and type(callback) == "function") then
        self.LockCallback[#self.LockCallback + 1] = callback
    end
end

function lib:OnUnlock(callback)
    if(callback and type(callback) == "function") then
        self.UnlockCallback[#self.UnlockCallback + 1] = callback
    end
end

--[[ COMMON EVENTS ]]--

function lib:PLAYER_REGEN_DISABLED(...)
  for i=1, #self.LockCallback do
      local fn = self.LockCallback[i]
      if(fn and type(fn) == "function") then
          local _, catch = pcall(fn, ...)
          if(catch) then
              CoreObject:HandleError("Librarian:Events:OnLock(PLAYER_REGEN_DISABLED):", "callback", catch)
          end
      end
  end
end

function lib:PLAYER_REGEN_ENABLED(...)
  for i=1, #self.UnlockCallback do
      local fn = self.UnlockCallback[i]
      if(fn and type(fn) == "function") then
          local _, catch = pcall(fn, ...)
          if(catch) then
              CoreObject:HandleError("Librarian:Events:OnLock(PLAYER_REGEN_ENABLED):", "callback", catch)
          end
      end
  end
end

--[[ EVENT DISTRIBUTION ]]--

local Library_OnEvent = function(self, event, ...)
  local fn = self[event]
  if(fn and type(fn) == "function") then
      local _, catch = pcall(fn, self, ...)
      if(catch) then
          CoreObject:HandleError("Librarian:Events:OnEvent", event, catch)
      end
  end
end

lib.EventManager = CreateFrame("Frame", nil)
lib.EventManager:RegisterEvent("PLAYER_REGEN_DISABLED")
lib.EventManager:RegisterEvent("PLAYER_REGEN_ENABLED")
lib.EventManager:SetScript("OnEvent", Library_OnEvent)
