--[[
 /$$$$$$$$/$$
|__  $$__/__/
   | $$   /$$ /$$$$$$/$$$$   /$$$$$$   /$$$$$$  /$$$$$$$
   | $$  | $$| $$_  $$_  $$ /$$__  $$ /$$__  $$/$$_____/
   | $$  | $$| $$ \ $$ \ $$| $$$$$$$$| $$  \__/  $$$$$$
   | $$  | $$| $$ | $$ | $$| $$_____/| $$      \____  $$
   | $$  | $$| $$ | $$ | $$|  $$$$$$$| $$      /$$$$$$$/
   |__/  |__/|__/ |__/ |__/ \_______/|__/     |_______/
--]]

--[[ LOCALIZED GLOBALS ]]--
--GLOBAL NAMESPACE
local _G = getfenv(0);
--LUA
local select        = _G.select;
local type          = _G.type;
local pairs         = _G.pairs;
local assert        = _G.assert;
local rawset        = _G.rawset;
local rawget        = _G.rawget;
local getmetatable  = _G.getmetatable;
local setmetatable  = _G.setmetatable;
local string        = _G.string;
local math          = _G.math;
local table         = _G.table;
--[[ STRING METHODS ]]--
local format = string.format;
--[[ MATH METHODS ]]--
local abs, ceil, floor, round = math.abs, math.ceil, math.floor, math.round;
--[[ TABLE METHODS ]]--
local tremove = table.remove;
--BLIZZARD API
local wipe          = _G.wipe;
local GetLocale     = _G.GetLocale;

--[[ LIB CONSTRUCT ]]--

local lib = Librarian:NewLibrary("Timers")

if not lib then return end -- No upgrade needed

--[[ LIB EVENT LISTENER ]]--

lib.Handler = CreateFrame("Frame", nil)

--[[ LOCAL VARS ]]--

local TimerQueue = {};
local TimerCount = 0;

local ExeTimerManager_OnUpdate = function(self, elapsed)
    if(TimerCount > 0) then
        for id,_ in pairs(TimerQueue) do
            local callback = TimerQueue[id]
            if(callback.f) then
                if callback.t > elapsed then
                    local newTime = callback.t - elapsed
                    TimerQueue[id].t = newTime
                else
                    callback.f()
                    if(callback.x) then
                        TimerQueue[id].t = callback.x
                    else
                        TimerQueue[id] = nil
                        TimerCount = TimerCount - 1;
                    end
                end
            end
        end
    end
end

local Timers_EventHandler = function(self, event)
    if(event == "PLAYER_REGEN_DISABLED") then
        self:SetScript("OnUpdate", nil)
    else
        self:SetScript("OnUpdate", ExeTimerManager_OnUpdate)
    end
end

--[[ PUBLIC METHODS ]]--

function lib:ExecuteTimer(timeOutFunction, duration, idCheck)
    if(type(duration) == "number" and type(timeOutFunction) == "function") then
        if(idCheck and TimerQueue[idCheck]) then
            TimerQueue[idCheck].t = duration
            return idCheck
        else
            TimerCount = TimerCount + 1
            local id = "LOOP" .. TimerCount;
            TimerQueue[id] = {t = duration, f = timeOutFunction}
            return id
        end
    end
    return false
end

function lib:RemoveTimer(id)
    if(TimerQueue[id]) then
        TimerQueue[id] = nil
        TimerCount = TimerCount - 1;
    end
end

function lib:ExecuteLoop(timeOutFunction, duration, idCheck)
    if(type(duration) == "number" and type(timeOutFunction) == "function") then
        if(idCheck and TimerQueue[idCheck]) then
            TimerQueue[idCheck].x = duration
            TimerQueue[idCheck].t = duration
            return idCheck
        else
            TimerCount = TimerCount + 1
            local id = "LOOP" .. TimerCount;
            TimerQueue[id] = {x = duration, t = duration, f = timeOutFunction}
            return id
        end
    end
    return false
end

function lib:RemoveLoop(id)
    if(TimerQueue[id]) then
        TimerQueue[id] = nil
        TimerCount = TimerCount - 1;
    end
end

function lib:ClearAllTimers()
    wipe(TimerQueue)
    self.Handler:SetScript("OnUpdate", nil)
    self.Handler:SetScript("OnUpdate", ExeTimerManager_OnUpdate)
end

function lib:Initialize()
    self.Handler:RegisterEvent('PLAYER_REGEN_ENABLED')
    self.Handler:RegisterEvent('PLAYER_REGEN_DISABLED')
    self.Handler:SetScript("OnEvent", Timers_EventHandler)
    self.Handler:SetScript("OnUpdate", ExeTimerManager_OnUpdate)
end
