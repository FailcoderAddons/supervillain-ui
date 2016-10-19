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
if(SV.class ~= "SHAMAN") then return end
--[[
##########################################################
LOCALS
##########################################################
]]--
SV.SpecialFX:Register("maelstrom", [[Spells\Fill_lightning_cast_01.m2]], 0, 0, 0, 0, 1.18, 0, 0)
SV.SpecialFX:Register("maelstrom_air", [[Spells\Monk_rushingjadewind_grey.m2]], 2, -2, -2, 2, 0.5, 0, 2)
SV.SpecialFX:Register("maelstrom_water", [[Spells\Flowingwater_high.m2]], 2, -2, -2, 2, 0.008, -0.02, -0.22)
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
	local bar = self.Maelstrom;
	local max = self.MaxClassPower;
	local size = db.classbar.height
	local width = size * max;
	bar.Holder:SetSize(width, size*0.8)
    if(not db.classbar.detachFromFrame) then
    	SV:ResetAnchors(L["Classbar"])
    end
    local holderUpdate = bar.Holder:GetScript('OnSizeChanged')
    if holderUpdate then
        holderUpdate(bar.Holder)
    end

    bar:ClearAllPoints()
    bar:SetAllPoints(bar.Holder)
end
--[[
##########################################################
SHAMAN
##########################################################
]]--
local PostUpdate = function(self, ...)
	local value = ...;
	if(not value) then return end
	if(value > 0) then
		self:FadeIn()
		if(not self.Bar.FX:IsShown()) then
			self.Bar.FX:Show()
			self.Bar.FX:UpdateEffect()
		end
	else
		self:FadeOut()
	end
end

function MOD:CreateClassBar(playerFrame)
	local max = 6
	local bar = CreateFrame("Frame",nil,playerFrame)
	bar:SetFrameLevel(playerFrame.TextGrip:GetFrameLevel() + 30)

	local bgTexture = bar:CreateTexture(nil, "BACKGROUND")
	bgTexture:SetAllPoints(bar)
	bgTexture:SetColorTexture(0,0.05,0.1,0.5)

	local borderB = bar:CreateTexture(nil,"OVERLAY")
	borderB:SetColorTexture(0,0,0)
	borderB:SetPoint("BOTTOMLEFT")
	borderB:SetPoint("BOTTOMRIGHT")
	borderB:SetHeight(2)

	local borderT = bar:CreateTexture(nil,"OVERLAY")
	borderT:SetColorTexture(0,0,0)
	borderT:SetPoint("TOPLEFT")
	borderT:SetPoint("TOPRIGHT")
	borderT:SetHeight(2)

	local borderL = bar:CreateTexture(nil,"OVERLAY")
	borderL:SetColorTexture(0,0,0)
	borderL:SetPoint("TOPLEFT")
	borderL:SetPoint("BOTTOMLEFT")
	borderL:SetWidth(2)

	local borderR = bar:CreateTexture(nil,"OVERLAY")
	borderR:SetColorTexture(0,0,0)
	borderR:SetPoint("TOPRIGHT")
	borderR:SetPoint("BOTTOMRIGHT")
	borderR:SetWidth(2)

	bar.bg = bgTexture;

	local maelBar = CreateFrame("StatusBar", nil, bar)
	maelBar.noupdate = true;
	maelBar:InsetPoints(bar)
	maelBar:SetOrientation("HORIZONTAL")
	maelBar:SetStatusBarTexture(SV.media.statusbar.gradient)
	maelBar:SetStatusBarColor(0.2, 0.9, 1, 0.75)
	maelBar.text = maelBar:CreateFontString(nil, "OVERLAY")
	maelBar.text:SetPoint("LEFT")
	maelBar.text:SetFontObject(SVUI_Font_Unit_Small)
	maelBar.text:SetJustifyH('LEFT')
	maelBar.text:SetTextColor(1,1,1)
	maelBar.text:SetText("0")

	SV.SpecialFX:SetFXFrame(bar, "maelstrom_air", true)
	SV.SpecialFX:SetFXFrame(maelBar, "maelstrom", true)
	bar.FX:SetFrameLevel(0)
	bar.FX:SetAlpha(0.5)

	bar.Bar = maelBar;
	bar.PostUpdate = PostUpdate;

	local classBarHolder = CreateFrame("Frame", "Player_ClassBar", bar)
	classBarHolder:SetPoint("TOPLEFT", playerFrame, "BOTTOMLEFT", 0, -2)
	bar:SetPoint("TOPLEFT", classBarHolder, "TOPLEFT", 0, 0)
	bar.Holder = classBarHolder
	SV:NewAnchor(bar.Holder, L["Classbar"], OnMove)

	playerFrame.MaxClassPower = max
	playerFrame.PostTalentUpdate = PostUpdate;
	playerFrame.RefreshClassBar = Reposition;
	playerFrame.Maelstrom = bar
	return 'Maelstrom'
end
