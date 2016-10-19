--[[
##########################################################
S V U I   By: Failcoder
##########################################################
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local unpack    = _G.unpack;
local select    = _G.select;
local pairs     = _G.pairs;
local ipairs    = _G.ipairs;
local type      = _G.type;
local error     = _G.error;
local pcall     = _G.pcall;
local tostring  = _G.tostring;
local tonumber  = _G.tonumber;
local assert 	= _G.assert;
local math 		= _G.math;
--[[ MATH METHODS ]]--
local random = math.random;
--[[
##########################################################
GET ADDON DATA
##########################################################
]]--
local SV = _G['SVUI']
local L = SV.L;
local LSM = _G.LibStub("LibSharedMedia-3.0")
local MOD = SV.UnitFrames

if(not MOD) then return end

local oUF_SVUI = MOD.oUF
assert(oUF_SVUI, "SVUI UnitFrames: unable to locate oUF.")
if(SV.class ~= "DEATHKNIGHT") then return end
--[[
##########################################################
LOCALS
##########################################################
]]--
SV.SpecialFX:Register("rune_blood", [[Spells\Monk_drunkenhaze_impact.m2]], 0, 0, 0, 0, 0.00001, 0, 0.3)
SV.SpecialFX:Register("rune_frost", [[Spells\Ice_cast_low_hand.m2]], 0, 0, 0, 0, 0.00001, -0.2, 0.4)
SV.SpecialFX:Register("rune_unholy", [[Spells\Poison_impactdot_med_chest.m2]], 0, 0, 0, 0, 0.13, -0.3, -0.2)
SV.SpecialFX:Register("rune_death", [[Spells\Shadow_strikes_state_hand.m2]], 0, 0, 0, 0, 0.001, 0, -0.25)
local specEffects = {
	[1] = "rune_blood",
	[2] = "rune_frost",
	[3] = "rune_unholy",
	[4] = "rune_death"
};
local RUNE_FG = [[Interface\AddOns\SVUI_UnitFrames\assets\Class\RUNES-FG]];
local RUNE_BG = [[Interface\AddOns\SVUI_UnitFrames\assets\Class\RUNES-BG]];
local runeColors = {
	{0.75, 0, 0},   -- blood
	{0, 0.75, 1},   -- frost
	{0.1, 0.75, 0},  -- unholy
	{1, 1, 1}, -- death
};
local runeTextures = {
	[[Interface\AddOns\SVUI_UnitFrames\assets\Class\DEATHKNIGHT-BLOOD]],
	[[Interface\AddOns\SVUI_UnitFrames\assets\Class\DEATHKNIGHT-FROST]],
	[[Interface\AddOns\SVUI_UnitFrames\assets\Class\DEATHKNIGHT-UNHOLY]],
	[[Interface\AddOns\SVUI_UnitFrames\assets\Class\DEATHKNIGHT-DEATH]]
};
local runeClassic = {
	runeTextures[1],
	runeTextures[1],
	runeTextures[2],
	runeTextures[2],
	runeTextures[3],
	runeTextures[3]
};
--[[
##########################################################
POSITIONING
##########################################################
]]--
local OnMove = function()
	SV.db.UnitFrames.player.classbar.detachFromFrame = true
end

local RuneChange = function(self, ...)
	local spec = GetSpecialization()
	self.FX:SetEffect(specEffects[spec])
end

local ClassicRuneChange = function(self, ...)
	local spec = GetSpecialization()
	local graphic = runeTextures[spec]
	local colors = runeColors[spec]
	self:SetStatusBarColor(colors[1], colors[2], colors[3])
	self.bg:SetTexture(graphic)
	self:SetStatusBarTexture(graphic)
	self.FX:SetEffect(specEffects[spec])
end

local Reposition = function(self)
	local db = SV.db.UnitFrames.player
	local bar = self.Necromancy;
	local max = self.MaxClassPower;
	local size = db.classbar.height
	local inset = size * 0.1
	local width = size * max;

	local spec = GetSpecialization()

	bar.Holder:SetSize(width, size)
    if(not db.classbar.detachFromFrame) then
    	SV:ResetAnchors(L["Classbar"])
    end
    local holderUpdate = bar.Holder:GetScript('OnSizeChanged')
    if holderUpdate then
        holderUpdate(bar.Holder)
    end

    bar:ClearAllPoints()
    bar:SetAllPoints(bar.Holder)

	if(db.classbar.altRunes) then
		for i = 1, max do
			local graphic = runeTextures[spec]
			bar[i]:ClearAllPoints()
			bar[i]:SetHeight(size)
			bar[i]:SetWidth(size)
			bar[i].bar:GetStatusBarTexture():SetHorizTile(false)
			if i == 1 then
				bar[i]:SetPoint("TOPLEFT", bar, "TOPLEFT", 0, 0)
			elseif i == 2 then
				bar[i]:SetPoint("LEFT", bar[1], "RIGHT", -6, 0)
			else
				bar[i]:SetPoint("LEFT", bar[i - 1], "RIGHT", -2, 0)
			end
			bar[i].bar:ClearAllPoints()
			bar[i].bar:SetAllPoints(bar[i].holder)
			bar[i].bar.bg:SetTexture(graphic)
			bar[i].bar.bg:SetAlpha(0.5)
			bar[i].bar.bg.multiplier = 0.1
			bar[i].fg:SetColorTexture(0,0,0,0)
			bar[i].fg:SetAlpha(0)
			bar[i].bar.FX:SetAlpha(0.2)
			bar[i].bar:SetStatusBarTexture(graphic)
			bar[i].bar.Change = ClassicRuneChange;
		end
	else
		for i = 1, max do
			bar[i]:ClearAllPoints()
			bar[i]:SetHeight(size + 4)
			bar[i]:SetWidth(size)
			bar[i].bar:GetStatusBarTexture():SetHorizTile(false)
			if i==1 then
				bar[i]:SetPoint("TOPLEFT", bar, "TOPLEFT", 0, 1)
			else
				bar[i]:SetPoint("LEFT", bar[i - 1], "RIGHT", -6, 0)
			end
			bar[i].bar:ClearAllPoints()
			bar[i].bar:InsetPoints(bar[i].holder,inset,inset)
			bar[i].bar.bg:SetTexture(RUNE_BG)
			bar[i].bar.bg:SetAlpha(1)
			bar[i].bar.bg.multiplier = 1
			bar[i].fg:SetTexture(RUNE_FG)
			bar[i].fg:SetAlpha(1)
			bar[i].bar.FX:SetAlpha(1)
			bar[i].bar:SetStatusBarTexture(SV.media.statusbar.default)
			bar[i].bar.Change = RuneChange;
		end
	end

	if bar.UpdateAllRuneTypes then
		bar.UpdateAllRuneTypes(self)
	end
end
--[[
##########################################################
DEATHKNIGHT
##########################################################
]]--
function MOD:CreateClassBar(playerFrame)
	local max = 6
	local bar = CreateFrame("Frame", nil, playerFrame)
	bar:SetFrameLevel(playerFrame.TextGrip:GetFrameLevel() + 30)
	for i=1, max do
		local rune = CreateFrame("Frame", nil, bar)
		rune:SetFrameStrata("BACKGROUND")
		rune:SetFrameLevel(0)

		local bgFrame = CreateFrame("Frame", nil, rune)
		bgFrame:InsetPoints(rune)
		rune.holder = bgFrame;

		local bgTexture = bgFrame:CreateTexture(nil, "BORDER")
		bgTexture:SetAllPoints(bgFrame)
		bgTexture:SetTexture(RUNE_BG)
		bgTexture:SetGradientAlpha("VERTICAL",0,0,0,0.5,0,0,0,0.85)

	    rune.bar = CreateFrame("StatusBar", nil, bgFrame)
		rune.bar.noupdate = true;
		rune.bar:InsetPoints(bgFrame,4,4)
		rune.bar:SetOrientation("HORIZONTAL")
		rune.bar:SetStatusBarTexture(SV.media.statusbar.default)
		rune.bar.bg = bgTexture;

		local fgFrame = CreateFrame("Frame", nil, rune.bar)
		fgFrame:SetAllPoints(bgFrame)

		local fgTexture = fgFrame:CreateTexture(nil, "OVERLAY")
		fgTexture:SetAllPoints(fgFrame)
		fgTexture:SetTexture(RUNE_FG)
		fgTexture:SetVertexColor(0.25,0.25,0.25)
		rune.fg = fgTexture;

		local effectName = specEffects[i]
		SV.SpecialFX:SetFXFrame(rune.bar, effectName)

		bar[i] = rune;
		bar[i].bar.effectIndex = i;
		bar[i].bar.Change = RuneChange;
		bar[i].bar:SetOrientation("VERTICAL");
	end

	local classBarHolder = CreateFrame("Frame", "Player_ClassBar", bar)
	classBarHolder:SetPoint("TOPLEFT", playerFrame, "BOTTOMLEFT", 0, -2)
	bar:SetPoint("TOPLEFT", classBarHolder, "TOPLEFT", 0, 0)
	bar.Holder = classBarHolder
	SV:NewAnchor(bar.Holder, L["Classbar"], OnMove)

	playerFrame.MaxClassPower = max;
	playerFrame.RefreshClassBar = Reposition;
	playerFrame.Necromancy = bar
	return 'Necromancy'
end
