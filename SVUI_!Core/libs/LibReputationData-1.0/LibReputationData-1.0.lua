local MAJOR, MINOR = "LibReputationData-1.0", 2

assert(_G.LibStub, MAJOR .. " requires LibStub")
local lib = _G.LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end

lib.callbacks = lib.callbacks or _G.LibStub("CallbackHandler-1.0"):New(lib)

-- local store
local reputationChanges = {}
local allFactions = {}
local watchedFaction = 0

-- blizzard api
local GetFactionInfo                = _G.GetFactionInfo
local GetFriendshipReputation		= _G.GetFriendshipReputation
local IsFactionInactive 			= _G.IsFactionInactive
local SetWatchedFactionIndex        = _G.SetWatchedFactionIndex
local TimerAfter					= _G.C_Timer.After

-- lua api
local select   = _G.select
local strmatch = _G.string.match
local tonumber = _G.tonumber

local private = {} -- private space for the event handlers

lib.frame = lib.frame or _G.CreateFrame("Frame")
local frame = lib.frame
frame:UnregisterAllEvents() -- deactivate old versions
frame:SetScript("OnEvent", function(_, event, ...) private[event](event, ...) end)
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

local function CopyTable(tbl)
	if not tbl then return {} end
	local copy = {};
	for k, v in pairs(tbl) do
		if ( type(v) == "table" ) then
			copy[k] = CopyTable(v);
		else
			copy[k] = v;
		end
	end
	return copy;
end

local function GetFLocalFactionInfo(factionIndex)
	return allFactions[factionIndex]
end

local function GetFactionIndex(factionName)
	for i = 1, #allFactions do
		local name,  _, standingID, bottomValue, topValue, earnedValue, _,
		_, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, hasBonus, lfgBonus = GetFactionInfo(i);
		if name == factionName then return i end
	end
end

local function GetFactionData(factionIndex)

	local name, _, standingID, bottomValue, topValue, earnedValue, _,
		_, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID, hasBonus, lfgBonus = GetFactionInfo(factionIndex)
	if not name then return nil end

	if isWatched then watchedFaction = factionIndex end
	local standingText = _G['FACTION_STANDING_LABEL'..standingID]

	local friendID, friendRep, friendMaxRep, _, _, _, friendTextLevel, friendThresh = GetFriendshipReputation(factionID)
	if friendID ~= nil then
		bottomValue = friendThresh
		if nextThresh then
			topValue = friendThresh + min( friendMaxRep - friendThresh, 8400 ) -- Magic number! Yay!
		end
		earnedValue = friendRep
		standingText = friendTextLevel
	end
	
	local faction = {
		factionIndex = factionIndex,
		name = name,
		standingID = standingID,
		standing = standingText,
		min = bottomValue,
		max = topValue,
		value = earnedValue,
		isHeader = isHeader,
		isChild = isChild,
		hasRep = hasRep,
		isActive = not IsFactionInactive(factionIndex),
		factionID = factionID,
		friendID = friendID
	}
	return faction	
end

-- Refresh the list of known factions
local function RefreshAllFactions()
	local i = 1
	local lastName
	local factions = {}

	repeat
		local name, description, standingId, bottomValue, topValue, earnedValue, atWarWith,
			canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID = GetFactionInfo(i)
		if not name or name == lastName and name ~= GUILD then break end

		lastName = name
		local faction = GetFactionData(i)

		if faction then 
			tinsert(factions, faction)
		end

		if isCollapsed then ExpandFactionHeader(i) end
		i = i + 1
	until i > 200
	allFactions = factions
	lib.callbacks:Fire("FACTIONS_LOADED")
end

local function UpdateFaction(factionIndex)
	allFactions[factionIndex] = GetFactionData(factionIndex)
end


------------------------------------------------------------------------------
-- Ensure factions and guild info are loaded
------------------------------------------------------------------------------
local function EnsureFactionsLoaded()
	-- Sometimes it takes a while for faction and guild info
	-- to load when the game boots up so we need to periodically
	-- check whether its loaded before we can display it
	if GetFactionInfo(1) == nil or (IsInGuild() and GetGuildInfo("player") == nil) then
			TimerAfter(0.5, EnsureFactionsLoaded)
	else
		-- Refresh all factions and notify subscribers
		RefreshAllFactions() 
	end
end

------------------------------------------------------------------------------
-- Update reputation
------------------------------------------------------------------------------
local function UpdateReputationChanges()

	RefreshAllFactions()

	-- Build sorted change table
	local changes = {}
	for name, amount in pairs(reputationChanges) do

		local factionIndex= GetFactionIndex(name)
		if factionIndex then
			UpdateFaction(factionIndex)
			tinsert(changes, {
				name = name,
				amount = amount,
				factionIndex = factionIndex
			})
		end
	end

	if #changes > 1 then
		table.sort(changes, function(a, b) return a.amount > b.amount end)
	end

	if #changes > 0 then
		-- Notify subscribers
		InformReputationsChanged(changes)
	end
	
	reputationChanges = {}
end


local function InformReputationsChanged(changes)
	for _,_,factionIndex in changes do
		lib.callbacks:Fire("REPUTATION_CHANGED", factionIndex)
	end
end

------------------------------------------------------------------------------
-- Events
------------------------------------------------------------------------------
function private.PLAYER_ENTERING_WORLD(event)
	TimerAfter(3, function()
		frame:RegisterEvent("COMBAT_TEXT_UPDATE")
		--frame:RegisterEvent("UPDATE_FACTION")
		EnsureFactionsLoaded()
	end)
end

function private.COMBAT_TEXT_UPDATE(event, type, name, amount)
	if (type == "FACTION") then
        if not name or name == "" then return end
        
		if IsInGuild() then
			-- Check name for guild reputation
			if name == GUILD_NAME then
				name = GetGuildInfo("player");
			end
		end
	
		if not reputationChanges[name] then
			reputationChanges[name] = amount
		else
			reputationChanges[name] = reputationChanges[name] + amount
		end

		TimerAfter(0.5,UpdateReputationChanges)

	end
end

function private.UPDATE_FACTION(event)
	RefreshAllFactions()
end

------------------------------------------------------------------------------
-- API
------------------------------------------------------------------------------
function lib:SetWatchedFaction(factionIndex)
	
	SetWatchedFactionIndex(factionIndex)
	watchedFaction = factionIndex
	lib.callbacks:Fire("REPUTATION_CHANGED", factionIndex)
end

function lib:GetWatchedFactionIndex()
	return watchedFaction
end

function lib:GetReputationInfo(_, factionIndex)
	factionIndex = factionIndex or watchedFaction
	if allFactions[factionIndex] then
		return factionIndex, CopyTable(allFactions[factionIndex])
	else
		return nil,nil
	end
end

function lib:GetAllFactionsInfo()
	return CopyTable(allFactions)
end

function lib:GetAllActiveFactionsInfo()
	local activeFactions = {}
	for i=1,#allFactions do
		if allFactions[i].isActive then
			tinsert(activeFactions,allFactions[i])
		end
	end

	if #activeFactions > 0 then
		return CopyTable(activeFactions)
	else
		return nil
	end
end

function lib:GetNumObtainedReputations()
	return #allFactions
end

function lib:ForceUpdate()
	EnsureFactionsLoaded()
end
