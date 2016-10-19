--[[
##########################################################
S V U I   By: Failcoder
########################################################## 
LOCALIZED LUA FUNCTIONS
##########################################################
GET ADDON DATA
##########################################################
]]--
if(select(2, UnitClass("player")) ~= 'SHAMAN') then return end;

local SV = select(2, ...)

--[[ SHAMAN FILTERS ]]--

SV.defaults.Filters["BuffWatch"] = {
    ["61295"] = {-- Riptide
        ["enable"] = true, 
        ["id"] = 61295, 
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
    ["974"] = {-- Earth Shield
        ["enable"] = true, 
        ["id"] = 974, 
        ["point"] = "BOTTOMLEFT", 
        ["color"] = {["r"] = 0.2, ["g"] = 0.7, ["b"] = 0.2}, 
        ["anyUnit"] = true, 
        ["onlyShowMissing"] = false, 
        ['style'] = 'coloredIcon', 
        ['displayText'] = false, 
        ['textColor'] = {["r"] = 1, ["g"] = 1, ["b"] = 1}, 
        ['textThreshold'] = -1, 
        ['xOffset'] = 0, 
        ['yOffset'] = 0
    },
    ["51945"] = {-- Earthliving
        ["enable"] = true, 
        ["id"] = 51945, 
        ["point"] = "BOTTOMRIGHT", 
        ["color"] = {["r"] = 0.7, ["g"] = 0.4, ["b"] = 0.4}, 
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