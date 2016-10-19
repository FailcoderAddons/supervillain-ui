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
local twipe = table.wipe;
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
SKADA
##########################################################
]]--
local function Skada_ShowPopup(self)
	MOD:LoadAlert('Do you want to reset Skada?', function(self) Skada:Reset() self:GetParent():Hide() end)
end

local function StyleSkada()
	assert(Skada, "AddOn Not Loaded")
	Skada.ShowPopup = Skada_ShowPopup

	local SkadaDisplayBar = Skada.displays['bar']

	hooksecurefunc(SkadaDisplayBar, 'AddDisplayOptions', function(self, window, options)
		options.baroptions.args.barspacing = nil
		options.titleoptions.args.texture = nil
		options.titleoptions.args.bordertexture = nil
		options.titleoptions.args.thickness = nil
		options.titleoptions.args.margin = nil
		options.titleoptions.args.color = nil
		options.windowoptions = nil
	end)

	hooksecurefunc(SkadaDisplayBar, 'ApplySettings', function(self, window)
		local skada = window.bargroup
		if not skada then return end
		local panelAnchor = skada
		skada:SetSpacing(1)
		skada:SetFrameLevel(5)
		skada:SetBackdrop(nil)

		if(window.db.enabletitle) then
			panelAnchor = skada.button
			skada.button:SetHeight(23)
			skada.button:RemoveTextures()
			skada.button:SetStyle("Frame", "Transparent")
			--skada.button:SetPanelColor("class")
			local titleFont = skada.button:GetFontString()
			titleFont:SetFont(SV.media.font.dialog, 13, "NONE")
			titleFont:SetShadowColor(0, 0, 0, 1)
			titleFont:SetShadowOffset(1, -1)
		end

		skada:SetStyle("Frame", "Transparent")
	end)

	hooksecurefunc(Skada, 'CreateWindow', function()
		if MOD.Docklet:IsEmbedded("Skada") then
			MOD:RegisterAddonDocklets()
		end
	end)

	hooksecurefunc(Skada, 'DeleteWindow', function()
		if MOD.Docklet:IsEmbedded("Skada") then
			MOD:RegisterAddonDocklets()
		end
	end)
end

MOD:SaveAddonStyle("Skada", StyleSkada, nil, true)
