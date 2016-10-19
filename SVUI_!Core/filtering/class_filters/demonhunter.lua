--[[
##########################################################
S V U I   By: Failcoder
########################################################## 
LOCALIZED LUA FUNCTIONS
##########################################################
GET ADDON DATA
##########################################################
]]--
if(select(2, UnitClass("player")) ~= 'DEMONHUNTER') then return end;

local SV = select(2, ...)

--[[ DEMONHUNTER FILTERS ]]--

SV.defaults.Filters["BuffWatch"] = {
    ["178740"] = {-- Immolation Aura
        ["enable"] = true, 
        ["id"] = 178740, 
        ["point"] = "TOPRIGHT", 
        ["color"] = {["r"] = 0.4, ["g"] = 0.8, ["b"] = 0.2}, 
        ["anyUnit"] = false, 
        ["onlyShowMissing"] = false, 
        ['style'] = 'coloredIcon', 
        ['displayText'] = false, 
        ['textColor'] = {["r"] = 1, ["g"] = 1, ["b"] = 1}, 
        ['textThreshold'] = -1, 
        ['xOffset'] = 0, 
        ['yOffset'] = 0
    },
    ["218256"] = {-- Empower Wards
        ["enable"] = true, 
        ["id"] = 218256, 
        ["point"] = "TOPLEFT", 
        ["color"] = {["r"] = 0.2, ["g"] = 1, ["b"] = 0.2}, 
        ["anyUnit"] = false, 
        ["onlyShowMissing"] = false, 
        ['style'] = 'coloredIcon', 
        ['displayText'] = false, 
        ['textColor'] = {["r"] = 1, ["g"] = 1, ["b"] = 1}, 
        ['textThreshold'] = -1, 
        ['xOffset'] = 0, 
        ['yOffset'] = 0
    },
    ["162264"] = {-- Metamorphosis (Havoc)
        ["enable"] = true, 
        ["id"] = 162264, 
        ["point"] = "BOTTOMLEFT", 
        ["color"] = {["r"] = 0.8, ["g"] = 0.1, ["b"] = 0.8}, 
        ["anyUnit"] = true, 
        ["onlyShowMissing"] = false, 
        ['style'] = 'coloredIcon', 
        ['displayText'] = false, 
        ['textColor'] = {["r"] = 1, ["g"] = 1, ["b"] = 1}, 
        ['textThreshold'] = -1, 
        ['xOffset'] = 0, 
        ['yOffset'] = 0
    },
    ["187827"] = {-- Metamorphosis (Vengence)
        ["enable"] = true, 
        ["id"] = 187827, 
        ["point"] = "BOTTOMLEFT", 
        ["color"] = {["r"] = 0.8, ["g"] = 0.1, ["b"] = 0.8}, 
        ["anyUnit"] = false, 
        ["onlyShowMissing"] = false, 
        ['style'] = 'coloredIcon', 
        ['displayText'] = false, 
        ['textColor'] = {["r"] = 1, ["g"] = 1, ["b"] = 1}, 
        ['textThreshold'] = -1, 
        ['xOffset'] = 0, 
        ['yOffset'] = 0
    },
};
