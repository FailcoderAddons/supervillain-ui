--[[
##############################################################################
S V U I   By: Failcoder
##############################################################################
--]]
--[[ GLOBALS ]]--
local _G = _G;
local unpack  = _G.unpack;
local select  = _G.select;
local ipairs  = _G.ipairs;
local pairs   = _G.pairs;
--[[ ADDON ]]--
local SV = _G['SVUI'];
local L = SV.L;
local MOD = SV.Skins;
local Schema = MOD.Schema;
--[[
##########################################################
STYLE (IN DEVELOPMENT)
##########################################################
]]--
local function StyleDetails()
	assert(_G._detalhes, "AddOn Not Loaded");

	for i=1, 10 do
		local baseframe = _G['DetailsBaseFrame'..i];

		if(baseframe) then
			local bgframe = _G['Details_WindowFrame'..i];
			baseframe:RemoveTextures();
			if(bgframe) then
				bgframe:RemoveTextures();
				bgframe:SetStyle("Frame", "Transparent");
			else
				baseframe:SetStyle("Frame", "Transparent");
			end
		end
	end
end
--[[
##########################################################
MOD LOADING
##########################################################
]]--
MOD:SaveAddonStyle("Details", StyleDetails)
