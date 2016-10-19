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
local random, floor = math.random, math.floor;
local CreateFrame = _G.CreateFrame;
local GetSpecialization = _G.GetSpecialization;
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
if(SV.class ~= "WARLOCK") then return end

--SV.SpecialFX:Register("affliction", [[Spells\Fel_fire_precast_high_hand.m2]], -12, 12, 12, -12, 0.35, 0, 0);
SV.SpecialFX:Register("demonology", [[Spells\Warlock_bodyofflames_medium_state_shoulder_right_purple.m2]], -12, 12, 12, -12, 0.4, 0, 0.45)
SV.SpecialFX:Register("destruction", [[Spells\Fill_fire_cast_01.m2]], -12, 12, 12, -12, 1.5, -0.25, 0.5);
--[[
##########################################################
LOCAL FUNCTIONS
##########################################################
]]--
local FURY_FONT = [[Interface\AddOns\SVUI_!Core\assets\fonts\Numbers.ttf]]
local shardColors = {
	[1] = {{0.5,1,0,1}, {0,0,0,0.9}},
	[2] = {{0.67,0.42,0.93,1}, {0,0,0,0.9}},
	[3] = {{1,1,0,1}, {0,0,0,0.9}},
	[4] = {{0.5,1,0,1}, {0,0,0,0.9}}
}
local shardTextures = {
	[1] = {
		[[Interface\Addons\SVUI_UnitFrames\assets\Class\WARLOCK-SHARD]],
		[[Interface\Addons\SVUI_UnitFrames\assets\Class\WARLOCK-SHARD-BG]],
		[[Interface\Addons\SVUI_UnitFrames\assets\Class\WARLOCK-SHARD-FG]]
	},
	[2] = {
		[[Interface\Addons\SVUI_UnitFrames\assets\Class\WARLOCK-SHARD]],
		[[Interface\Addons\SVUI_UnitFrames\assets\Class\WARLOCK-SHARD-BG]],
		[[Interface\Addons\SVUI_UnitFrames\assets\Class\WARLOCK-SHARD-FG]]
	},
	[3] = {
		[[Interface\Addons\SVUI_UnitFrames\assets\Class\WARLOCK-EMBER]],
		[[Interface\Addons\SVUI_UnitFrames\assets\Class\WARLOCK-EMBER]],
		[[Interface\Addons\SVUI_UnitFrames\assets\Class\WARLOCK-EMBER-FG]]
	},
}
local specFX = {"demonology","demonology","destruction"};
--[[
##########################################################
POSITIONING
##########################################################
]]--
local OnMove = function()
	SV.db.UnitFrames.player.classbar.detachFromFrame = true
end

local Reposition = function(self)
	local db = SV.db.UnitFrames.player
	local bar = self.WarlockShards;
	local max = self.MaxClassPower;
	local size = db.classbar.height
	local width = size * max;
	local dbOffset = (size * 0.15)
	bar.Holder:SetSize(width, size)
    if(not db.classbar.detachFromFrame) then
    	SV:ResetAnchors(L["Classbar"], true)
    end
    local holderUpdate = bar.Holder:GetScript('OnSizeChanged')
    if holderUpdate then
        holderUpdate(bar.Holder)
    end

    bar:ClearAllPoints()
    bar:SetAllPoints(bar.Holder)

	for i = 1, max do
		bar[i]:ClearAllPoints()
		bar[i]:SetHeight(size)
		bar[i]:SetWidth(size)
		if(i == 1) then
			bar[i]:SetPoint("LEFT", bar)
		else
			bar[i]:SetPoint("LEFT", bar[i - 1], "RIGHT", -2, 0)
		end
	end
end
--[[
##########################################################
CUSTOM HANDLERS
##########################################################
]]--
local UpdateTextures = function(self, spec)
	local max = self.MaxCount;
	local colors = shardColors[spec];
	local textures = shardTextures[spec];
	for i = 1, max do
		self[i]:SetStatusBarTexture(textures[1])
		self[i]:GetStatusBarTexture():SetHorizTile(false)
		self[i].overlay:SetTexture(textures[3])
		self[i].overlay:SetVertexColor(unpack(colors[1]))
		self[i].bg:SetTexture(textures[2])
		self[i].bg:SetVertexColor(unpack(colors[2]))
		self[i].FX:SetEffect(specFX[spec])
	end
	self.CurrentSpec = spec
end

local ShardUpdate = function(self, value)
	if (value and value == 1) then
		if(self.overlay) then
			self.overlay:Show()
			SV.Animate:Flash(self.overlay,1,true)
		end
		if(not self.FX:IsShown()) then
			self.FX:Show()
		end
		self.FX:UpdateEffect()
	else
		if(self.overlay) then
			SV.Animate:StopFlash(self.overlay)
			self.overlay:Hide()
		end
		self.FX:Hide()
	end
end
--[[
##########################################################
WARLOCK
##########################################################
]]--
local EffectModel_OnShow = function(self)
	self:SetEffect("overlay_demonbar");
end

function MOD:CreateClassBar(playerFrame)
	local max = 5;
	local textures = shardTextures[1];
	local colors = shardColors[1];
	local bar = CreateFrame("Frame",nil,playerFrame)
	bar:SetFrameLevel(playerFrame.TextGrip:GetFrameLevel() + 30)
	for i = 1, max do
		bar[i] = CreateFrame("StatusBar", nil, bar)
		bar[i].noupdate = true;
		bar[i]:SetOrientation("VERTICAL")
		bar[i]:SetStatusBarTexture(textures[1])
		bar[i]:GetStatusBarTexture():SetHorizTile(false)

		bar[i].bg = bar[i]:CreateTexture(nil,'BORDER',nil,1)
		bar[i].bg:SetAllPoints(bar[i])
		bar[i].bg:SetTexture(textures[2])
		bar[i].bg:SetVertexColor(unpack(colors[2]))

		bar[i].overlay = bar[i]:CreateTexture(nil,'OVERLAY')
		bar[i].overlay:SetAllPoints(bar[i])
		bar[i].overlay:SetTexture(textures[3])
		bar[i].overlay:SetBlendMode("BLEND")
		bar[i].overlay:Hide()
		bar[i].overlay:SetVertexColor(unpack(colors[1]))

		SV.SpecialFX:SetFXFrame(bar[i], specFX[1], true)
		bar[i].Update = ShardUpdate
	end

	bar.UpdateTextures = UpdateTextures;
	bar.MaxCount = max;

	local classBarHolder = CreateFrame("Frame", "Player_ClassBar", bar)
	classBarHolder:SetPoint("TOPLEFT", playerFrame, "BOTTOMLEFT", 0, -2)
	bar:SetPoint("TOPLEFT", classBarHolder, "TOPLEFT", 0, 0)
	bar.Holder = classBarHolder
	SV:NewAnchor(bar.Holder, L["Classbar"], OnMove)

	playerFrame.MaxClassPower = max;
	playerFrame.RefreshClassBar = Reposition;
	playerFrame.WarlockShards = bar
	return 'WarlockShards'
end
