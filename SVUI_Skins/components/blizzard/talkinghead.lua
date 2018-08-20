--[[
##############################################################################
S V U I   By: 		Failcoder
Talking Head By: 	JoeyMagz
##############################################################################
--]]
--[[ GLOBALS ]]--
local _G = _G;
local unpack  	= _G.unpack;
local select  	= _G.select;
local ipairs  	= _G.ipairs;
local pairs   	= _G.pairs;
local type 		= _G.type;
--[[ ADDON ]]--
local SV = _G['SVUI'];
local L = SV.L;
local MOD = SV.Skins;
local Schema = MOD.Schema;
--[[
##########################################################
TALKING HEAD
##########################################################
]]--
-- Create Talking Head Minion
local THFMinion = CreateFrame("Frame", "SVUI_THFMinion");
local thf;

THFMinion:RegisterEvent("ADDON_LOADED");
--THFMinion:RegisterEvent("TALKINGHEAD_REQUESTED");


local function initializeTHF()
	if (thf ~= nil) then return end
	
	thf = CreateFrame("Frame", "SVUI_TalkingHeadFrame", UIParent);
	thf:SetPoint("CENTER", 0, 0);
	thf:SetSize(500, 200);
	SV.API:Set("Window", thf, true);
	
	SV:NewAnchor(thf, L["Talking Head Anchor"]);
end

function THFMinion:OnEvent(event, ...)
	if (event == "ADDON_LOADED") then
		initializeTHF();
	end
end

THFMinion:SetScript("OnEvent", THFMinion.OnEvent);

function SV:MoveTHF()
	TalkingHeadFrame:SetPoint("TOP", SVUI_TalkingHeadFrame_MOVE, 0, 0);
end

local function TalkingHeadStyle()
	if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.talkinghead ~= true then
		 return 
	end
	
	SV:MoveTHF();

end
--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveBlizzardStyle("Blizzard_TalkingHeadUI",TalkingHeadStyle)
