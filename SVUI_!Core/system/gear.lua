--[[
##########################################################
S V U I   By: Failcoder
##########################################################
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local unpack 	= _G.unpack;
local select 	= _G.select;
local pairs 	= _G.pairs;
local string 	= _G.string;
local math 		= _G.math;
--[[ STRING METHODS ]]--
local find, format, match, split, join = string.find, string.format, string.match, string.split, string.join;
local sub, byte = string.sub, string.byte;
--[[ MATH METHODS ]]--
local ceil, floor, round = math.ceil, math.floor, math.round;
--[[ TABLE METHODS ]]--
local tremove, tcopy, twipe, tsort, tcat = table.remove, table.copy, table.wipe, table.sort, table.concat;
--[[
##########################################################
GET ADDON DATA
##########################################################
]]--
local SV = select(2, ...)
local L = SV.L
local GetDetailedItemLevelInfo = _G.GetDetailedItemLevelInfo
--[[
##########################################################
LOCAL VARS
##########################################################
]]--
local NewHook = hooksecurefunc;
local EquipmentManager_UnpackLocation = EquipmentManager_UnpackLocation
local C_EquipmentSet = C_EquipmentSet
local ParseGearSlots;
local GEAR_CACHE, GEARSET_LISTING = {}, {};
local setNum;
local EquipmentSlots = {
    ["HeadSlot"] = {true,true},
    ["NeckSlot"] = {true,false},
    ["ShoulderSlot"] = {true,true},
    ["BackSlot"] = {true,false},
    ["ChestSlot"] = {true,true},
    ["WristSlot"] = {true,true},
    ["MainHandSlot"] = {true,true,true},
    ["SecondaryHandSlot"] = {true,true},
    ["HandsSlot"] = {true,true,true},
    ["WaistSlot"] = {true,true,true},
    ["LegsSlot"] = {true,true,true},
    ["FeetSlot"] = {true,true,true},
    ["Finger0Slot"] = {true,false,true},
    ["Finger1Slot"] = {true,false,true},
    ["Trinket0Slot"] = {true,false,true},
    ["Trinket1Slot"] = {true,false,true}
}

--[[
	Quick explaination of what Im doing with all of these locals...
	Unlike many of the other modules, Inventory has to continuously
	reference config settings which can start to get sluggish. What
	I have done is set local variables for every database value
	that the module can read efficiently. The function "UpdateLocals"
	is used to refresh these any time a change is made to configs
	and once when the mod is loaded.
]]--
local COLOR_KEYS = { [0] = "|cffff0000", [1] = "|cff00ff00", [2] = "|cffffff88" };
local LIVESET, LASTSET, BG_SET, SPEC_SET, SHOW_DURABILITY, ONLY_DAMAGED, AVG_LEVEL, MAX_LEVEL;
local SPEC_SWAP, BG_SWAP;
local SHOW_CHAR_LEVEL, SHOW_BAG_LEVEL, SHOW_CHAR_SET, SHOW_BAG_SET;
local iLevelFilter = ITEM_LEVEL:gsub( "%%d", "(%%d+)" )
--[[
##########################################################
LOCAL FUNCTIONS
##########################################################
]]--
local GearHandler = CreateFrame("Frame", nil);

local function encodeSub(i, j, k)
	local l = j;
	while((k > 0) and (l <= #i)) do
		local m = byte(i, l)
		if(m > 240) then
			l = l + 4;
		elseif(m > 225) then
			l = l + 3;
		elseif(m > 192) then
			l = l + 2;
		else
			l = l + 1;
		end
		k = k - 1;
	end
	return i:sub(j, (l - 1))
end

do
    local _heirlooms80 = {
      44102,42944,44096,42943,42950,48677,42946,42948,42947,42992,
      50255,44103,44107,44095,44098,44097,44105,42951,48683,48685,
      42949,48687,42984,44100,44101,44092,48718,44091,42952,48689,
      44099,42991,42985,48691,44094,44093,42945,48716
    }
    local _heirlooms90h = {105689,105683,105686,105687,105688,105685,105690,105691,105684,105692,105693}
    local _heirlooms90n = {104399,104400,104401,104402,104403,104404,104405,104406,104407,104408,104409}
    local _heirlooms90f = {105675,105670,105672,105671,105674,105673,105676,105677,105678,105679,105680}

    -- DEPRECATED
    -- local _heirloom_regex = "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?";

    local _slots = {
        ["HeadSlot"] = {true, true},            ["NeckSlot"] = {true, false},
        ["ShoulderSlot"] = {true, true},        ["BackSlot"] = {true, false},
        ["ChestSlot"] = {true, true},           ["WristSlot"] = {true, true},
        ["MainHandSlot"] = {true, true, true},  ["SecondaryHandSlot"] = {true, true},
        ["HandsSlot"] = {true, true, true},     ["WaistSlot"] = {true, true, true},
        ["LegsSlot"] = {true, true, true},      ["FeetSlot"] = {true, true, true},
        ["Finger0Slot"] = {true, false, true},  ["Finger1Slot"] = {true, false, true},
        ["Trinket0Slot"] = {true, false, true}, ["Trinket1Slot"] = {true, false, true}
    }


    local function _setLevelDisplay(frame, iLevel)
      if(not frame or (not frame.ItemLevel)) then return; end
      frame.ItemLevel:SetText('')
      if(SHOW_CHAR_LEVEL and iLevel) then
        local key = (iLevel < (AVG_LEVEL - 10)) and 0 or (iLevel > (AVG_LEVEL + 10)) and 1 or 2;
        frame.ItemLevel:SetFormattedText("%s%d|r", COLOR_KEYS[key], iLevel)
      end
    end

    local function _setDurabilityDisplay(frame, slotId)
      if(not frame or (not frame.DurabilityInfo)) then return; end
      if(SHOW_DURABILITY) then
        local current,total,actual,perc,r,g,b;
        current,total = GetInventoryItemDurability(slotId)
        if(current and total) then
          frame.DurabilityInfo.bar:SetMinMaxValues(0, 100)
          if(current == total and ONLY_DAMAGED) then
            frame.DurabilityInfo:Hide()
          else
            if(current ~= total) then
              actual = current / total;
              perc = actual * 100;
              r,g,b = SV:ColorGradient(actual,1,0,0,1,1,0,0,1,0)
              frame.DurabilityInfo.bar:SetValue(perc)
              frame.DurabilityInfo.bar:SetStatusBarColor(r,g,b)
              if not frame.DurabilityInfo:IsShown() then
                frame.DurabilityInfo:Show()
              end
            else
              frame.DurabilityInfo.bar:SetValue(100)
              frame.DurabilityInfo.bar:SetStatusBarColor(0, 1, 0)
            end
          end
        else
          frame.DurabilityInfo:Hide()
        end
      else
        frame.DurabilityInfo:Hide()
      end
    end

    function ParseGearSlots(unit, category, setLevel, setDurability)
        local averageLevel,totalSlots = 0,0;

        for slotName, flags in pairs(_slots) do
            local iLevel
            local slotId = GetInventorySlotInfo(slotName);
            local iLink = GetInventoryItemLink(unit, slotId);
			local itemID, altItemID, name, _, _, _, _, _, _, _, _, altOnTop = C_ArtifactUI.GetArtifactInfo();
            if(iLink and type(iLink) == "string") then
                iLevel = SV:GetItemLevel(iLink)
				local relicLevel = GetRelicItemLevel(iLink) * 5;
				iLevel = iLevel + relicLevel;
                if(iLevel and iLevel > 0) then
                    -- handle dual wielded artifact weapons properly
                    if (slotName == "SecondaryHandSlot") then
						local mainslotId = GetInventorySlotInfo("MainHandSlot");
						local mainiLink = GetInventoryItemLink(unit, mainslotId)
						local mainiLevel = SV:GetItemLevel(mainiLink);
						relicLevel = GetRelicItemLevel(mainiLink) * 5;
						iLevel = mainiLevel + relicLevel;
                    end
                    totalSlots = totalSlots + 1;
                    averageLevel = averageLevel + iLevel
                end
            end

            if(setLevel and flags[1]) then
              _setLevelDisplay(_G[category .. slotName], iLevel)
            end
            if(setDurability and (slotId ~= nil) and (not inspecting) and flags[2]) then
              _setDurabilityDisplay(_G[category .. slotName], slotId)
            end
        end
        return averageLevel,totalSlots
    end
end

function SV:GetItemLevel(itemLink)
    if (itemLink) then
        return GetDetailedItemLevelInfo(itemLink) or 0
      else
        return 0
    end
end

function GetRelicItemLevel(itemLink)
	-- make sure the linked item is a weapon, otherwise weird things happen
	local itemName, _, _, iLevelInfo, _, itemType, itemSubType, _, _, _, _ = GetItemInfo(itemLink)
	local attuned = 0;
	
	if (checkName == itemName) or (checkAltName == itemName) then
		for i=1, 3 do
			isAttuned, canAttune = true, true;
			if isAttuned then
				attuned = attuned + 1;
			end
		end
	end
	
	return attuned;
end


function SV:ParseGearSlots(unit, inspecting, setLevel, setDurability)
    local category = (inspecting) and "Inspect" or "Character";
    local averageLevel,totalSlots = ParseGearSlots(unit, category, setLevel, setDurability);
    if(averageLevel < 1 or totalSlots < 15) then return end
    return floor(averageLevel / totalSlots)
end

function SV:SetGearLabels(frame, bagID, slotID, itemLink, quality, equipSlot)
	quality = quality or 0;
	equipSlot = equipSlot or '';

	if(frame.GearInfo) then
		local loc = format("%d_%d", bagID, slotID);
		if((not SHOW_BAG_SET) or (not GEARSET_LISTING[loc])) then
			frame.GearInfo:SetText('')
		else
			local setNumber = #GEARSET_LISTING[loc] < 4 and #GEARSET_LISTING[loc] or 3;
			if(setNumber == 1) then
				frame.GearInfo:SetFormattedText("|cffffffaa%s|r", encodeSub(GEARSET_LISTING[loc][1], 1, 4))
			elseif(setNumber == 2) then
				frame.GearInfo:SetFormattedText("|cffffffaa%s %s|r", encodeSub(GEARSET_LISTING[loc][1], 1, 4), encodeSub(GEARSET_LISTING[loc][2], 1, 4))
			elseif(setNumber == 3) then
				frame.GearInfo:SetFormattedText("|cffffffaa%s %s %s|r", encodeSub(GEARSET_LISTING[loc][1], 1, 4), encodeSub(GEARSET_LISTING[loc][2], 1, 4), encodeSub(GEARSET_LISTING[loc][3], 1, 4))
			else
				frame.GearInfo:SetText('')
			end
		end
	end
	
	if(frame.ItemLevel) then
        local iLevel = SV:GetItemLevel(itemLink)
		local itemName, _, _, iLevelInfo, _, _, itemSubType, _, _, _, _
		local overall, equipped = GetAverageItemLevel()

		if(itemLink) then
			itemName, _, _, iLevelInfo, _, _, itemSubType, _, _, _, _ = GetItemInfo(itemLink)
		end
		if((not SHOW_BAG_LEVEL) or (iLevel <= 1) or (quality == 7) or (not equipSlot:find('INVTYPE'))) then
			if (itemSubType ==  "Artifact Relic") then
				local key = (iLevelInfo < (equipped - 10)) and 0 or (iLevelInfo > (equipped + 10)) and 1 or 2;
				frame.ItemLevel:SetFormattedText("%s%d|r", COLOR_KEYS[key], iLevelInfo)
			else
				frame.ItemLevel:SetText('')
			end
		else
			local key = (iLevel < (equipped - 10)) and 0 or (iLevel > (equipped + 10)) and 1 or 2;
			frame.ItemLevel:SetFormattedText("%s%d|r", COLOR_KEYS[key], iLevel)
		end
	end
end

local function GetActiveGear()
	local resultSpec = GetSpecialization()
	local _, sname = GetSpecializationInfo(resultSpec)
	local resultSet

	BG_SET = SV.db.Gear.battleground.equipmentset
	SPEC_SET = "none"

	if(sname) then
		SPEC_SET = SV.db.Gear.specialization[sname] or SPEC_SET
	end

	if(not C_EquipmentSet.GetNumEquipmentSets()) then
		return resultSpec,false
	end
	for i=1, C_EquipmentSet.GetNumEquipmentSets() do
		local setName,_,_,setUsed = C_EquipmentSet.GetEquipmentSetInfo(i)
		if setUsed then
			resultSet = setName
			break
		end
	end
	return resultSpec,resultSet
end

local function SetDisplayStats(arg)
	for slotName, flags in pairs(EquipmentSlots) do
		local globalName = format("%s%s", arg, slotName)
		local frame = _G[globalName]

		if(flags[1]) then
			frame.ItemLevel = frame:CreateFontString(nil, "OVERLAY")
			frame.ItemLevel:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 2, 1)
			frame.ItemLevel:SetFontObject(SVUI_Font_Default)
		end

		if(arg == "Character" and flags[2]) then
			frame.DurabilityInfo = CreateFrame("Frame", nil, frame)
			frame.DurabilityInfo:SetWidth(7)
			if flags[3] then
				frame.DurabilityInfo:SetPoint("TOPRIGHT", frame, "TOPLEFT", -1, 1)
				frame.DurabilityInfo:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", -1, -1)
			else
				frame.DurabilityInfo:SetPoint("TOPLEFT", frame, "TOPRIGHT", 1, 1)
				frame.DurabilityInfo:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", 1, -1)
			end
			frame.DurabilityInfo:SetFrameLevel(frame:GetFrameLevel()-1)
			frame.DurabilityInfo:SetBackdrop(SV.media.backdrop.glow)
			frame.DurabilityInfo:SetBackdropColor(0, 0, 0, 0.5)
			frame.DurabilityInfo:SetBackdropBorderColor(0, 0, 0, 0.8)
			frame.DurabilityInfo.bar = CreateFrame("StatusBar", nil, frame.DurabilityInfo)
			frame.DurabilityInfo.bar:InsetPoints(frame.DurabilityInfo, 2, 2)
			frame.DurabilityInfo.bar:SetStatusBarTexture(SV.media.statusbar.default)
			frame.DurabilityInfo.bar:SetOrientation("VERTICAL")
			frame.DurabilityInfo.bg = frame.DurabilityInfo:CreateTexture(nil, "BORDER")
			frame.DurabilityInfo.bg:InsetPoints(frame.DurabilityInfo, 2, 2)
			frame.DurabilityInfo.bg:SetTexture([[Interface\BUTTONS\WHITE8X8]])
			frame.DurabilityInfo.bg:SetVertexColor("VERTICAL", 0.5, 0.53, 0.55, 0.8, 0.8, 1)
		end
	end
end
--[[
##########################################################
CORE FUNCTIONS
##########################################################
]]--
local function RefreshInspectedGear()
	if(not SV.GearBuildComplete) then return end
	if(InCombatLockdown()) then
		GearHandler:RegisterEvent("PLAYER_REGEN_ENABLED", RefreshInspectedGear)
		return
	else
		GearHandler.WaitingOnInspect = nil
	end

	local unit = InspectFrame and InspectFrame.unit or "player";
	if(not unit or (unit and not CanInspect(unit,false))) then return end

  SV:ParseGearSlots(unit, true, true)
end

local function UpdateLocals()
	SPEC_SWAP = SV.db.Gear.specialization.enable
	BG_SWAP = SV.db.Gear.battleground.enable
	SHOW_CHAR_LEVEL = SV.db.Gear.labels.characterItemLevel
	SHOW_BAG_LEVEL = SV.db.Gear.labels.inventoryItemLevel
	SHOW_CHAR_SET = SV.db.Gear.labels.characterGearSet
	SHOW_BAG_SET = SV.db.Gear.labels.inventoryGearSet
	SHOW_DURABILITY = SV.db.Gear.durability.enable
	ONLY_DAMAGED = SV.db.Gear.durability.onlydamaged
	MAX_LEVEL, AVG_LEVEL = GetAverageItemLevel()
end

function SV:BuildEquipmentMap()
	UpdateLocals()
	for key, gearData in pairs(GEARSET_LISTING) do
		twipe(gearData);
	end
	
	if (not C_EquipmentSet.GetNumEquipmentSets()) then
		return
	end
	
	local name, player, bank, bags, slotIndex, bagIndex, loc, _;
	local equipmentSetIDs = C_EquipmentSet.GetEquipmentSetIDs();
	
	for i = 1, C_EquipmentSet.GetNumEquipmentSets() do
		name = C_EquipmentSet.GetEquipmentSetInfo(equipmentSetIDs[i]);
		local equipmentSetID = C_EquipmentSet.GetEquipmentSetID(name);
		GEAR_CACHE = C_EquipmentSet.GetItemLocations(equipmentSetID);
		for _, location in pairs(GEAR_CACHE) do
			if(type(location) ~= "string") then
				player, bank, bags, _, slotIndex, bagIndex = EquipmentManager_UnpackLocation(location);
				if((bank or bags) and (slotIndex and bagIndex)) then
					loc = format("%d_%d", bagIndex, slotIndex);
					GEARSET_LISTING[loc] = GEARSET_LISTING[loc] or {};
					local gslCount = #GEARSET_LISTING[loc] + 1
					GEARSET_LISTING[loc][gslCount] = name;
				end
			end
		end
	end
end

function SV:UpdateGearInfo()
	if(not SV.GearBuildComplete) then return end
	if(InCombatLockdown()) then
		GearHandler:RegisterEvent("PLAYER_REGEN_ENABLED")
		return
	end
	UpdateLocals()
  SV:ParseGearSlots("player", false, true, true)
end

local Gear_UpdateTabs = function()
	GearHandler.WaitingOnInspect = true
	SV.Timers:ExecuteTimer(RefreshInspectedGear, 0.2)
end

function SV:GearSwap()
	if(InCombatLockdown()) then return; end
	local gearSpec, gearSet = GetActiveGear()
	if(not gearSet) then return; end

	if(BG_SWAP and (BG_SET ~= "none" and BG_SET ~= gearSet)) then
		local inDungeon,dungeonType = IsInInstance()
		if(inDungeon and dungeonType == "pvp" or dungeonType == "arena") then
			if BG_SET ~= "none" and BG_SET ~= gearSet then
				LIVESET = BG_SET;
				C_EquipmentSet.UseEquipmentSet(BG_SET)
			end
			return
		end
	end

	if(SPEC_SWAP and (SPEC_SET ~= "none" and SPEC_SET ~= gearSet)) then
		LIVESET = SPEC_SET;
		C_EquipmentSet.UseEquipmentSet(SPEC_SET)
	end
end

local MSG_PREFIX = "You have equipped equipment set: "

local GearHandler_OnEvent = function(self, event, ...)
	if(event == "PLAYER_REGEN_ENABLED") then
		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
		if(self.WaitingOnInspect) then
			SV.Timers:ExecuteTimer(RefreshInspectedGear, 0.2)
		else
			SV:UpdateGearInfo()
		end
	elseif(event == "EQUIPMENT_SWAP_FINISHED") then
		if LIVESET then
			local strMsg = ("%s%s"):format(MSG_PREFIX, LIVESET)
			SV:AddonMessage(strMsg)
			LIVESET = nil
		end
	else
		SV:UpdateGearInfo()
	end
end

local function InitializeGearInfo()
	MSG_PREFIX = L["You have equipped equipment set: "]
	SHOW_CHAR_LEVEL = SV.db.Gear.labels.characterItemLevel
	SHOW_BAG_LEVEL = SV.db.Gear.labels.inventoryItemLevel
	SHOW_CHAR_SET = SV.db.Gear.labels.characterGearSet
	SHOW_BAG_SET = SV.db.Gear.labels.inventoryGearSet
	SHOW_DURABILITY = SV.db.Gear.durability.enable
	ONLY_DAMAGED = SV.db.Gear.durability.onlydamaged
	MAX_LEVEL, AVG_LEVEL = GetAverageItemLevel()


	LoadAddOn("Blizzard_InspectUI")
	SetDisplayStats("Character")
	SetDisplayStats("Inspect")
  
	GearHandler:RegisterEvent("PLAYER_ENTERING_WORLD")
	GearHandler:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
	GearHandler:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	GearHandler:RegisterEvent("SOCKET_INFO_UPDATE")
	GearHandler:RegisterEvent("COMBAT_RATING_UPDATE")
	GearHandler:RegisterEvent("MASTERY_UPDATE")
	GearHandler:RegisterEvent("EQUIPMENT_SWAP_FINISHED")
	GearHandler:SetScript("OnEvent", GearHandler_OnEvent)

	NewHook('InspectFrame_UpdateTabs', Gear_UpdateTabs)
	SV.Timers:ExecuteTimer(SV.UpdateGearInfo, 10)
	SV:GearSwap()
	SV.GearBuildComplete = true
end

SV:NewScript(InitializeGearInfo)
