--[[
##########################################################
S V U I   By: Failcoder
########################################################## 
LOCALIZED LUA FUNCTIONS
##########################################################
GET ADDON DATA
##########################################################
]]--
local SV = select(2, ...)

--[[ PET FILTERS ]]--

SV.defaults.Filters["PetBuffWatch"] = {
    ["19615"] = {-- Frenzy
        ["enable"] = true, 
        ["id"] = 19615, 
        ["point"] = "TOPLEFT", 
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
    ["136"] = {-- Mend Pet
        ["enable"] = true, 
        ["id"] = 136, 
        ["point"] = "TOPRIGHT", 
        ["color"] = {["r"] = 0.2, ["g"] = 0.8, ["b"] = 0.2}, 
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