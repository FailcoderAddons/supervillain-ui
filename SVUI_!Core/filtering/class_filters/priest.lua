--[[
##########################################################
S V U I   By: Failcoder
##########################################################
LOCALIZED LUA FUNCTIONS
##########################################################
GET ADDON DATA
##########################################################
]]--
if(select(2, UnitClass("player")) ~= 'PRIEST') then return end;

local SV = select(2, ...)

--[[ PRIEST FILTERS ]]--

SV.defaults.Filters["BuffWatch"] = {
    ["6788"] = {-- Weakened Soul
        ["enable"] = true,
        ["id"] = 6788,
        ["point"] = "TOPRIGHT",
        ["color"] = {["r"] = 1, ["g"] = 0, ["b"] = 0},
        ["anyUnit"] = true,
        ["onlyShowMissing"] = false,
        ['style'] = 'coloredIcon',
        ['displayText'] = false,
        ['textColor'] = {["r"] = 1, ["g"] = 1, ["b"] = 1},
        ['textThreshold'] = -1,
        ['xOffset'] = 0,
        ['yOffset'] = 0
    },
    ["41635"] = {-- Prayer of Mending
        ["enable"] = true,
        ["id"] = 41635,
        ["point"] = "BOTTOMRIGHT",
        ["color"] = {["r"] = 0.2, ["g"] = 0.7, ["b"] = 0.2},
        ["anyUnit"] = false,
        ["onlyShowMissing"] = false,
        ['style'] = 'coloredIcon',
        ['displayText'] = false,
        ['textColor'] = {["r"] = 1, ["g"] = 1, ["b"] = 1},
        ['textThreshold'] = -1,
        ['xOffset'] = 0,
        ['yOffset'] = 0
    },
    ["139"] = {-- Renew
        ["enable"] = true,
        ["id"] = 139,
        ["point"] = "BOTTOMLEFT",
        ["color"] = {["r"] = 0.4, ["g"] = 0.7, ["b"] = 0.2},
        ["anyUnit"] = false,
        ["onlyShowMissing"] = false,
        ['style'] = 'coloredIcon',
        ['displayText'] = false,
        ['textColor'] = {["r"] = 1, ["g"] = 1, ["b"] = 1},
        ['textThreshold'] = -1,
        ['xOffset'] = 0,
        ['yOffset'] = 0
    },
    ["17"] = {-- Power Word: Shield
        ["enable"] = true,
        ["id"] = 17,
        ["point"] = "TOPLEFT",
        ["color"] = {["r"] = 0.81, ["g"] = 0.85, ["b"] = 0.1},
        ["anyUnit"] = true,
        ["onlyShowMissing"] = false,
        ['style'] = 'coloredIcon',
        ['displayText'] = false,
        ['textColor'] = {["r"] = 1, ["g"] = 1, ["b"] = 1},
        ['textThreshold'] = -1,
        ['xOffset'] = 0,
        ['yOffset'] = 0
    },
    ["123258"] = {-- Power Word: Shield Power Insight
        ["enable"] = true,
        ["id"] = 123258,
        ["point"] = "TOPLEFT",
        ["color"] = {["r"] = 0.81, ["g"] = 0.85, ["b"] = 0.1},
        ["anyUnit"] = true,
        ["onlyShowMissing"] = false,
        ['style'] = 'coloredIcon',
        ['displayText'] = false,
        ['textColor'] = {["r"] = 1, ["g"] = 1, ["b"] = 1},
        ['textThreshold'] = -1,
        ['xOffset'] = 0,
        ['yOffset'] = 0
    },
    ["10060"] = {-- Power Infusion
        ["enable"] = true,
        ["id"] = 10060,
        ["point"] = "RIGHT",
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
    ["47788"] = {-- Guardian Spirit
        ["enable"] = true,
        ["id"] = 47788,
        ["point"] = "LEFT",
        ["color"] = {["r"] = 0.86, ["g"] = 0.44, ["b"] = 0},
        ["anyUnit"] = true,
        ["onlyShowMissing"] = false,
        ['style'] = 'coloredIcon',
        ['displayText'] = false,
        ['textColor'] = {["r"] = 1, ["g"] = 1, ["b"] = 1},
        ['textThreshold'] = -1,
        ['xOffset'] = 0,
        ['yOffset'] = 0
    },
    ["33206"] = {-- Pain Suppression
        ["enable"] = true,
        ["id"] = 33206,
        ["point"] = "LEFT",
        ["color"] = {["r"] = 0.89, ["g"] = 0.09, ["b"] = 0.05},
        ["anyUnit"] = true,
        ["onlyShowMissing"] = false,
        ['style'] = 'coloredIcon',
        ['displayText'] = false,
        ['textColor'] = {["r"] = 1, ["g"] = 1, ["b"] = 1},
        ['textThreshold'] = -1,
        ['xOffset'] = 0,
        ['yOffset'] = 0
    },
};
