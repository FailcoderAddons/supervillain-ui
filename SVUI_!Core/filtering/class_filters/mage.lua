--[[
##########################################################
S V U I   By: Failcoder
########################################################## 
LOCALIZED LUA FUNCTIONS
##########################################################
GET ADDON DATA
##########################################################
]]--
if(select(2, UnitClass("player")) ~= 'MAGE') then return end;

local SV = select(2, ...)

--[[ MAGE FILTERS ]]--

SV.defaults.Filters["BuffWatch"] = {
    ["111264"] = {-- Ice Ward
        ["enable"] = true, 
        ["id"] = 111264, 
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
};