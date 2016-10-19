--[[
##########################################################
S V U I   By: Failcoder
########################################################## 
LOCALIZED LUA FUNCTIONS
##########################################################
GET ADDON DATA
##########################################################
]]--
if(select(2, UnitClass("player")) ~= 'PALADIN') then return end;

local SV = select(2, ...)

--[[ PALADIN FILTERS ]]--

SV.defaults.Filters["BuffWatch"] = {
    ["53563"] = {-- Beacon of Light
        ["enable"] = true, 
        ["id"] = 53563, 
        ["point"] = "TOPRIGHT", 
        ["color"] = {["r"] = 0.7, ["g"] = 0.3, ["b"] = 0.7}, 
        ["anyUnit"] = false, 
        ["onlyShowMissing"] = false, 
        ['style'] = 'coloredIcon', 
        ['displayText'] = false, 
        ['textColor'] = {["r"] = 1, ["g"] = 1, ["b"] = 1}, 
        ['textThreshold'] = -1, 
        ['xOffset'] = 0, 
        ['yOffset'] = 0
    },
    ["1022"] = {-- Hand of Protection
        ["enable"] = true, 
        ["id"] = 1022, 
        ["point"] = "BOTTOMRIGHT", 
        ["color"] = {["r"] = 0.2, ["g"] = 0.2, ["b"] = 1}, 
        ["anyUnit"] = true, 
        ["onlyShowMissing"] = false, 
        ['style'] = 'coloredIcon', 
        ['displayText'] = false, 
        ['textColor'] = {["r"] = 1, ["g"] = 1, ["b"] = 1}, 
        ['textThreshold'] = -1, 
        ['xOffset'] = 0, 
        ['yOffset'] = 0
    },
    ["1044"] = {-- Hand of Freedom
        ["enable"] = true, 
        ["id"] = 1044, 
        ["point"] = "BOTTOMRIGHT", 
        ["color"] = {["r"] = 0.89, ["g"] = 0.45, ["b"] = 0}, 
        ["anyUnit"] = true, 
        ["onlyShowMissing"] = false, 
        ['style'] = 'coloredIcon', 
        ['displayText'] = false, 
        ['textColor'] = {["r"] = 1, ["g"] = 1, ["b"] = 1}, 
        ['textThreshold'] = -1, 
        ['xOffset'] = 0, 
        ['yOffset'] = 0
    },
    ["1038"] = {-- Hand of Salvation
        ["enable"] = true, 
        ["id"] = 1038, 
        ["point"] = "BOTTOMRIGHT", 
        ["color"] = {["r"] = 0.93, ["g"] = 0.75, ["b"] = 0}, 
        ["anyUnit"] = true, 
        ["onlyShowMissing"] = false, 
        ['style'] = 'coloredIcon', 
        ['displayText'] = false, 
        ['textColor'] = {["r"] = 1, ["g"] = 1, ["b"] = 1}, 
        ['textThreshold'] = -1, 
        ['xOffset'] = 0, 
        ['yOffset'] = 0
    },
    ["6940"] = {-- Hand of Sacrifice
        ["enable"] = true, 
        ["id"] = 6940, 
        ["point"] = "BOTTOMRIGHT", 
        ["color"] = {["r"] = 0.89, ["g"] = 0.1, ["b"] = 0.1}, 
        ["anyUnit"] = true, 
        ["onlyShowMissing"] = false, 
        ['style'] = 'coloredIcon', 
        ['displayText'] = false, 
        ['textColor'] = {["r"] = 1, ["g"] = 1, ["b"] = 1}, 
        ['textThreshold'] = -1, 
        ['xOffset'] = 0, 
        ['yOffset'] = 0
    },
    ["114039"] = {-- Hand of Purity
        ["enable"] = true, 
        ["id"] = 114039, 
        ["point"] = "BOTTOMRIGHT", 
        ["color"] = {["r"] = 0.64, ["g"] = 0.41, ["b"] = 0.72}, 
        ["anyUnit"] = false, 
        ["onlyShowMissing"] = false, 
        ['style'] = 'coloredIcon', 
        ['displayText'] = false, 
        ['textColor'] = {["r"] = 1, ["g"] = 1, ["b"] = 1}, 
        ['textThreshold'] = -1, 
        ['xOffset'] = 0, 
        ['yOffset'] = 0
    },
    ["20925"] = {-- Sacred Shield
        ["enable"] = true, 
        ["id"] = 20925, 
        ["point"] = "TOPLEFT", 
        ["color"] = {["r"] = 0.93, ["g"] = 0.75, ["b"] = 0},
        ["anyUnit"] = false, 
        ["onlyShowMissing"] = false, 
        ['style'] = 'coloredIcon', 
        ['displayText'] = false, 
        ['textColor'] = {["r"] = 1, ["g"] = 1, ["b"] = 1}, 
        ['textThreshold'] = -1, 
        ['xOffset'] = 0, 
        ['yOffset'] = 0
    },
    ["114163"] = {-- Eternal Flame
        ["enable"] = true, 
        ["id"] = 114163, 
        ["point"] = "BOTTOMLEFT", 
        ["color"] = {["r"] = 0.87, ["g"] = 0.7, ["b"] = 0.03}, 
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