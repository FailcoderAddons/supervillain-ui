--[[
##########################################################
S V U I   By: Failcoder
########################################################## 
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local unpack 	= _G.unpack;
local select 	= _G.select;
local pairs 	= _G.pairs;
local string 	= _G.string;
--[[ STRING METHODS ]]--
local format = string.format;
--[[ 
########################################################## 
GET ADDON DATA
##########################################################
]]--
local SV = _G['SVUI'];
local L = SV.L;
local MOD = SV.Skins;
local Schema = MOD.Schema;
--[[ 
########################################################## 
ADIBAGS
##########################################################
]]--
local function StyleAdiBags(event)
	local AdiBags = LibStub('AceAddon-3.0'):GetAddon('AdiBags')
	assert(AdiBags, "AddOn Not Loaded")
	--hooksecurefunc(AdiBags, 'HookBagFrameCreation', function(self) print(self) end)

	local function SkinFrame(frame)
		local region = frame.HeaderRightRegion
		frame:SetStyle("Frame", 'Transparent')
		_G[frame:GetName()..'Bags']:SetStyle("Frame", "Default")
		for i = 1, 3 do
			region.widgets[i].widget:SetStyle("Button")
		end
	end

	if event == 'PLAYER_ENTERING_WORLD' then
		SV.Timers:ExecuteTimer(function()
			if not AdiBagsContainer1 then ToggleBackpack() ToggleBackpack() end
			if AdiBagsContainer1 then
				SkinFrame(AdiBagsContainer1)
				AdiBagsContainer1SearchBox:SetStyle("Editbox")
				AdiBagsContainer1SearchBox:SetPoint('TOPRIGHT', AdiBagsSimpleLayeredRegion2, 'TOPRIGHT', -75, -1)
			end
		end, 1)
	elseif event == 'BANKFRAME_OPENED' then
		SV.Timers:ExecuteTimer(function()
			if AdiBagsContainer2 then
				SkinFrame(AdiBagsContainer2)
				MOD:SafeEventRemoval("AdiBags", event)
			end
		end, 1)
	end
end

MOD:SaveAddonStyle("AdiBags", StyleAdiBags, nil, nil, 'BANKFRAME_OPENED')