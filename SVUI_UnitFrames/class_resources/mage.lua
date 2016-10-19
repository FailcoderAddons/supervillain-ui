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
if(SV.class ~= "MAGE") then return end

local ORB_ICON = [[Interface\AddOns\SVUI_UnitFrames\assets\Class\ORB]];
local ORB_BG = [[Interface\AddOns\SVUI_UnitFrames\assets\Class\ORB-BG]];
local CHARGE_ICON = [[Interface\AddOns\SVUI_UnitFrames\assets\Class\MAGE-CHARGE]];
local ICICLE_ICON = [[Interface\AddOns\SVUI_UnitFrames\assets\Class\MAGE-ICICLE]];
local NO_ART = SV.NoTexture;
SV.SpecialFX:Register("mage_fire", [[Spells\Fill_fire_cast_01.m2]], 2, -2, -2, 2, 0.85, -0.45, 1)
local specEffects = { [1] = "arcane", [2] = "mage_fire", [3] = "frost" };
local specColors = {
	[1] = {0.8, 1, 1, 1},
	[2] = {1, 0.2, 0, 0.75},
	[3] = {0.95, 1, 1, 0.75}
};
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
	local bar = self.MageMagic;
	local max = self.MaxClassPower;
	local size = db.classbar.height
	local width = size * max;
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
	for i = 1, max do
		bar[i]:ClearAllPoints()
		bar[i]:SetHeight(size-4)
		bar[i]:SetWidth(size-4)
		if i==1 then
			bar[i]:SetPoint("TOPLEFT", bar, "TOPLEFT", 0, 0)
		else
			bar[i]:SetPoint("LEFT", bar[i - 1], "RIGHT", -3, 0)
		end
	end
end
--[[
##########################################################
MAGE CHARGES
##########################################################
]]--
local PostTalentUpdate = function(self, spec)
	if(not self:IsShown()) then
		self:Show()
	end
	local color = specColors[spec]
	if(spec == 1) then
		for i = 1, 5 do
			self[i]:SetStatusBarTexture(CHARGE_ICON)
			self[i].bg:SetTexture(ORB_BG)
			self[i]:SetStatusBarColor(unpack(color))
			self[i].FX:SetEffect(specEffects[spec])
		end
	elseif(spec == 3) then
		for i = 1, 5 do
			self[i]:SetStatusBarTexture(ICICLE_ICON.."-"..i)
			self[i].bg:SetTexture(ICICLE_ICON.."-"..i)
			self[i]:SetStatusBarColor(unpack(color))
			self[i].FX:SetEffect(specEffects[spec])
		end
	else
		self.Ignite.FX:SetEffect(specEffects[spec])
	end
end

function MOD:CreateClassBar(playerFrame)
	local max = 5
	local bar = CreateFrame("Frame",nil,playerFrame)
	bar:SetFrameLevel(playerFrame.TextGrip:GetFrameLevel() + 30)

	for i = 1, max do
		bar[i] = CreateFrame("StatusBar", nil, bar)
		bar[i]:SetStatusBarTexture(CHARGE_ICON)
		bar[i]:GetStatusBarTexture():SetHorizTile(false)
		bar[i]:SetOrientation("VERTICAL")
		bar[i]:SetStatusBarColor(0.95, 1, 1, 0.75)
		bar[i].noupdate = true;

		bar[i].bg = bar[i]:CreateTexture(nil, "BACKGROUND")
		bar[i].bg:SetAllPoints(bar[i])
		bar[i].bg:SetTexture(ORB_BG);
		bar[i].bg:SetVertexColor(0.25,0.5,0.5)

		SV.SpecialFX:SetFXFrame(bar[i], "arcane")
		--bar[i].FX:SetFrameLevel(0)
		bar[i].FX:SetAlpha(0.5)
	end

	local bgFrame = CreateFrame("Frame", nil, bar)
	bgFrame:InsetPoints(bar)
	SV.SpecialFX:SetFXFrame(bgFrame, "arcane")

	local bgTexture = bgFrame:CreateTexture(nil, "BACKGROUND")
	bgTexture:SetAllPoints(bgFrame)
	bgTexture:SetColorTexture(0.09,0.01,0,0.5)

	local borderB = bgFrame:CreateTexture(nil,"OVERLAY")
	borderB:SetColorTexture(0,0,0)
	borderB:SetPoint("BOTTOMLEFT")
	borderB:SetPoint("BOTTOMRIGHT")
	borderB:SetHeight(2)

	local borderT = bgFrame:CreateTexture(nil,"OVERLAY")
	borderT:SetColorTexture(0,0,0)
	borderT:SetPoint("TOPLEFT")
	borderT:SetPoint("TOPRIGHT")
	borderT:SetHeight(2)

	local borderL = bgFrame:CreateTexture(nil,"OVERLAY")
	borderL:SetColorTexture(0,0,0)
	borderL:SetPoint("TOPLEFT")
	borderL:SetPoint("BOTTOMLEFT")
	borderL:SetWidth(2)

	local borderR = bgFrame:CreateTexture(nil,"OVERLAY")
	borderR:SetColorTexture(0,0,0)
	borderR:SetPoint("TOPRIGHT")
	borderR:SetPoint("BOTTOMRIGHT")
	borderR:SetWidth(2)

	bar.bg = bgTexture;


	local ignite = CreateFrame("StatusBar", nil, bgFrame)
	ignite.noupdate = true;
	ignite:InsetPoints(bgFrame)
	ignite:SetOrientation("HORIZONTAL")
	ignite:SetStatusBarTexture(SV.media.statusbar.glow)
	ignite:SetStatusBarColor(1, 0.2, 0, 0.75)
	ignite.text = ignite:CreateFontString(nil, "OVERLAY")
	ignite.text:SetPoint("LEFT")
	ignite.text:SetFontObject(SVUI_Font_Unit_Small)
	ignite.text:SetJustifyH('LEFT')
	ignite.text:SetTextColor(1,1,0)
	ignite.text:SetText("0")
	bgFrame.Bar = ignite;
    --SV.SpecialFX:SetFXFrame(ignite, "conqueror", true)
	--ignite.FX:SetScript("OnShow", EffectModel_OnShow)
	bar.Ignite = bgFrame;
	bar.Ignite:Hide();

	bar.PostTalentUpdate = PostTalentUpdate;
	local classBarHolder = CreateFrame("Frame", "Player_ClassBar", bar)
	classBarHolder:SetPoint("TOPLEFT", playerFrame, "BOTTOMLEFT", 0, -2)
	bar:SetPoint("TOPLEFT", classBarHolder, "TOPLEFT", 0, 0)
	bar.Holder = classBarHolder
	SV:NewAnchor(bar.Holder, L["Classbar"], OnMove)

	playerFrame.MaxClassPower = max;
	playerFrame.RefreshClassBar = Reposition;
	playerFrame.MageMagic = bar
	return 'MageMagic'
end
