--[[
##########################################################
S V U I   By: Failcoder
########################################################## 
LOCALIZED LUA FUNCTIONS
##########################################################
GET ADDON DATA
##########################################################
]]--
if(select(2, UnitClass("player")) ~= 'MONK') then return end;

local SV = select(2, ...)

--[[ MONK FILTERS ]]--

SV.defaults.Filters["BuffWatch"] = {
    ["119611"] = {--Renewing Mist
        ["enable"] = true, 
        ["id"] = 119611, 
        ["point"] = "TOPLEFT", 
        ["color"] = {["r"] = 0.8, ["g"] = 0.4, ["b"] = 0.8}, 
        ["anyUnit"] = false, 
        ["onlyShowMissing"] = false, 
        ['style'] = 'coloredIcon', 
        ['displayText'] = false, 
        ['textColor'] = {["r"] = 1, ["g"] = 1, ["b"] = 1}, 
        ['textThreshold'] = -1, 
        ['xOffset'] = 0, 
        ['yOffset'] = 0
    },
    ["116849"] = {-- Life Cocoon
        ["enable"] = true, 
        ["id"] = 116849, 
        ["point"] = "TOPRIGHT", 
        ["color"] = {["r"] = 0.2, ["g"] = 0.8, ["b"] = 0.2}, 
        ["anyUnit"] = false, 
        ["onlyShowMissing"] = false, 
        ['style'] = 'coloredIcon', 
        ['displayText'] = false, 
        ['textColor'] = {["r"] = 1, ["g"] = 1, ["b"] = 1}, 
        ['textThreshold'] = -1, 
        ['xOffset'] = 0, 
        ['yOffset'] = 0
    },
    ["132120"] = {-- Enveloping Mist
        ["enable"] = true, 
        ["id"] = 132120, 
        ["point"] = "BOTTOMLEFT", 
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
    ["124081"] = {-- Zen Sphere
        ["enable"] = true, 
        ["id"] = 124081, 
        ["point"] = "BOTTOMRIGHT", 
        ["color"] = {["r"] = 0.7, ["g"] = 0.4, ["b"] = 0}, 
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