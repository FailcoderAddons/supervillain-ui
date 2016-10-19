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
SEXYCOOLDOWN
##########################################################
]]--
local function SCDStripStyleSettings(bar)
	bar.optionsTable.args.icon.args.borderheader = nil
	bar.optionsTable.args.icon.args.border = nil
	bar.optionsTable.args.icon.args.borderColor = nil
	bar.optionsTable.args.icon.args.borderSize = nil
	bar.optionsTable.args.icon.args.borderInset = nil
	bar.optionsTable.args.bar.args.bnbheader = nil
	bar.optionsTable.args.bar.args.texture = nil
	bar.optionsTable.args.bar.args.backgroundColor = nil
	bar.optionsTable.args.bar.args.border = nil
	bar.optionsTable.args.bar.args.borderColor = nil
	bar.optionsTable.args.bar.args.borderSize = nil
	bar.optionsTable.args.bar.args.borderInset = nil
end

local function StyleSexyCooldownBar(bar)
	SCDStripStyleSettings(bar)
	SV.API:Set("Frame", bar)
	SV:ManageVisibility(bar)
	if MOD:IsAddonReady("SexyCooldown_Anchored") then
		if(SV.ActionBars and SV.ActionBars.MainAnchor) then
			bar:ClearAllPoints()
			bar:SetPoint('BOTTOMRIGHT', SV.ActionBars.MainAnchor, 'TOPRIGHT', 0, 4)
			bar:SetPoint("BOTTOMLEFT", SV.ActionBars.MainAnchor, "TOPLEFT", 0, 4)
			bar:SetHeight(SV.ActionBars.MainAnchor:GetHeight())
		end
	end
end

local function StyleSexyCooldownIcon(bar, icon)
	if not icon.styled then
		SV.API:Set("Frame", icon, false, true)
		SV.API:Set("Frame", icon.overlay,"Transparent",true)
		icon.styled = true
	end
	icon.overlay.tex:SetTexCoord(0.1,0.9,0.1,0.9)
	icon.tex:SetTexCoord(0.1,0.9,0.1,0.9)
end

local function StyleSexyCooldownBackdrop(bar)
	bar:SetStyle("!_Frame", "Transparent")
end

local function HookSCDBar(bar)
	if bar.hooked then return end
	hooksecurefunc(bar, "UpdateBarLook", StyleSexyCooldownBar)
	hooksecurefunc(bar, "UpdateSingleIconLook", StyleSexyCooldownIcon)
	hooksecurefunc(bar, "UpdateBarBackdrop", StyleSexyCooldownBackdrop)
	bar.settings.icon.borderInset = 0
	bar.hooked = true
end

local function StyleSexyCooldown()
	assert(SexyCooldown2, "AddOn Not Loaded")
	
	for _, bar in ipairs(SexyCooldown2.bars) do
		HookSCDBar(bar)
		bar:UpdateBarLook()
	end
	hooksecurefunc(SexyCooldown2, 'CreateBar', function(self)
		for _, bar in ipairs(self.bars) do
			HookSCDBar(bar)
			bar:UpdateBarLook()
		end
	end)
end
MOD:SaveAddonStyle("SexyCooldown", StyleSexyCooldown)