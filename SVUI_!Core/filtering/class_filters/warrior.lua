--[[
##########################################################
S V U I   By: Failcoder
########################################################## 
LOCALIZED LUA FUNCTIONS
##########################################################
GET ADDON DATA
##########################################################
]]--
if(select(2, UnitClass("player")) ~= 'WARRIOR') then return end;

local SV = select(2, ...)

--[[ WARRIOR FILTERS ]]--

SV.defaults.Filters["BuffWatch"] = {
    ["114030"] = {-- Vigilance
        ["enable"] = true, 
        ["id"] = 114030, 
        ["point"] = "TOPLEFT", 
        ["color"] = {["r"] = 0.2, ["g"] = 0.2, ["b"] = 1},
        ["anyUnit"] = false, 
        ["onlyShowMissing"] = false, 
        ['style'] = 'coloredIcon', 
        ['displayText'] = false, 
        ['textColor'] = {["r"] = 1, ["g"] = 1, ["b"] = 1}, 
        ['textThreshold'] = -1, 
        ['xOffset'] = 0, 
        ['yOffset'] = 0
    },
    ["3411"] = {-- Intervene
        ["enable"] = true, 
        ["id"] = 3411, 
        ["point"] = "TOPRIGHT", 
        ["color"] = {["r"] = 0.89, ["g"] = 0.09, ["b"] = 0.05},
        ["anyUnit"] = false, 
        ["onlyShowMissing"] = false, 
        ['style'] = 'coloredIcon', 
        ['displayText'] = false, 
        ['textColor'] = {["r"] = 1, ["g"] = 1, ["b"] = 1}, 
        ['textThreshold'] = -1, 
        ['xOffset'] = 0, 
        ['yOffset'] = 0
    },
    ["114029"] = {-- Safe Guard
        ["enable"] = true, 
        ["id"] = 114029, 
        ["point"] = "TOPRIGHT", 
        ["color"] = {["r"] = 0.89, ["g"] = 0.09, ["b"] = 0.05},
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