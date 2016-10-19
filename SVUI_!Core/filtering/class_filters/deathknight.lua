--[[
##########################################################
S V U I   By: Failcoder
########################################################## 
LOCALIZED LUA FUNCTIONS
##########################################################
GET ADDON DATA
##########################################################
]]--
if(select(2, UnitClass("player")) ~= 'DEATHKNIGHT') then return end;

local SV = select(2, ...)

--[[ PRIEST FILTERS ]]--

SV.defaults.Filters["BuffWatch"] = {
    ["49016"] = {-- Unholy Frenzy
        ["enable"] = true, 
        ["id"] = 49016, 
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