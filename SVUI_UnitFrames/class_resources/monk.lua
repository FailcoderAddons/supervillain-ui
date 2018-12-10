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
if(SV.class ~= "MONK") then return end

local ORB_ICON = [[Interface\AddOns\SVUI_UnitFrames\assets\Class\ORB]];
local ORB_BG = [[Interface\AddOns\SVUI_UnitFrames\assets\Class\ORB-BG]];

local STAGGER_BAR = [[Interface\AddOns\SVUI_UnitFrames\assets\Class\MONK-STAGGER-BAR]];
local STAGGER_BG = [[Interface\AddOns\SVUI_UnitFrames\assets\Class\MONK-STAGGER-BG]];
local STAGGER_FG = [[Interface\AddOns\SVUI_UnitFrames\assets\Class\MONK-STAGGER-FG]];
local STAGGER_ICON = [[Interface\AddOns\SVUI_UnitFrames\assets\Class\MONK-STAGGER-ICON]];

local CHI_FILE = [[Interface\Addons\SVUI_UnitFrames\assets\Class\MONK]];
local CHI_COORDS = {
	[1] = {0,0.5,0,0.5},
	[2] = {0.5,1,0,0.5},
	[3] = {0,0.5,0.5,1},
	[4] = {0.5,1,0.5,1},
	[5] = {0.5,1,0,0.5},
	[6] = {0,0.5,0.5,1},
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
	self.KungFu.DrunkenMaster.isEnabled = db.classbar.enableStagger;
	local bar = self.KungFu;
	local max = UnitPowerMax("player", Enum.PowerType.Chi);
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
	local tmp = 0.67
	for i = 1, 6 do
		local chi = tmp - (i * 0.1)
		bar[i]:ClearAllPoints()
		bar[i]:SetHeight(size)
		bar[i]:SetWidth(size)
		bar[i]:SetStatusBarColor(chi, 0.87, 0.35)
		if i==1 then
			bar[i]:SetPoint("TOPLEFT", bar, "TOPLEFT", 0, 0)
		else
			bar[i]:SetPoint("LEFT", bar[i - 1], "RIGHT", -2, 0)
		end
	end
end

local StartFlash = function(self) SV.Animate:Flash(self.overlay,1,true) end
local StopFlash = function(self) SV.Animate:StopFlash(self.overlay) end
--[[
##########################################################
MONK HARMONY
##########################################################
]]--
function MOD:CreateClassBar(playerFrame)
	local max = UnitPowerMax("player", Enum.PowerType.Chi)
	local bar = CreateFrame("Frame", nil, playerFrame)
	bar:SetFrameLevel(playerFrame.TextGrip:GetFrameLevel() + 30)
	for i=1, 6 do
		local coords = CHI_COORDS[i]
		bar[i] = CreateFrame("StatusBar", nil, bar)
		bar[i]:SetStatusBarTexture(ORB_ICON)
		bar[i]:GetStatusBarTexture():SetHorizTile(false)
		bar[i].noupdate = true;

		bar[i].bg = bar[i]:CreateTexture(nil, "BACKGROUND")
		bar[i].bg:SetAllPoints(bar[i])
		bar[i].bg:SetTexture(ORB_BG)

		bar[i].glow = bar[i]:CreateTexture(nil, "OVERLAY")
		bar[i].glow:SetAllPoints(bar[i])
		bar[i].glow:SetTexture(CHI_FILE)
		bar[i].glow:SetTexCoord(coords[1],coords[2],coords[3],coords[4])

		bar[i].overlay = bar[i]:CreateTexture(nil, "OVERLAY", nil, 7)
		bar[i].overlay:SetAllPoints(bar[i])
		bar[i].overlay:SetTexture(CHI_FILE)
		bar[i].overlay:SetTexCoord(coords[1],coords[2],coords[3],coords[4])
		bar[i].overlay:SetVertexColor(0, 0, 0)

		bar[i]:SetScript("OnShow", StartFlash)
		bar[i]:SetScript("OnHide", StopFlash)

		SV.SpecialFX:SetFXFrame(bar[i], "chi")
		bar[i].FX:SetFrameLevel(bar[i]:GetFrameLevel())
	end

	local stagger = CreateFrame("Statusbar",nil,playerFrame)
	stagger:SetPoint('TOPLEFT', playerFrame, 'TOPRIGHT', 3, 0)
	stagger:SetPoint('BOTTOMLEFT', playerFrame, 'BOTTOMRIGHT', 3, 0)
	stagger:SetWidth(10)
	stagger:SetStyle("Frame", "Bar")
	stagger:SetOrientation("VERTICAL")
	stagger:SetStatusBarTexture(SV.media.statusbar.default)
	--stagger:GetStatusBarTexture():SetHorizTile(false)

	stagger.bg = stagger:CreateTexture(nil,'BORDER',nil,1)
	stagger.bg:SetAllPoints(stagger)
	stagger.bg:SetTexture(SV.media.statusbar.default)
	stagger.bg:SetVertexColor(0,0,0,0.33)

	-- stagger.overlay = stagger:CreateTexture(nil,'OVERLAY')
	-- stagger.overlay:SetAllPoints(stagger)
	-- stagger.overlay:SetTexture(STAGGER_FG)
	-- stagger.overlay:SetVertexColor(1,1,1)

	-- stagger.icon = stagger:CreateTexture(nil,'OVERLAY')
	-- stagger.icon:SetAllPoints(stagger)
	-- stagger.icon:SetTexture(STAGGER_ICON)
	stagger.isEnabled = true;

	bar.DrunkenMaster = stagger

	local classBarHolder = CreateFrame("Frame", "Player_ClassBar", bar)
	classBarHolder:SetPoint("TOPLEFT", playerFrame, "BOTTOMLEFT", 0, -2)
	bar:SetPoint("TOPLEFT", classBarHolder, "TOPLEFT", 0, 0)
	bar.Holder = classBarHolder
	SV:NewAnchor(bar.Holder, L["Classbar"], OnMove)

	playerFrame.MaxClassPower = max;
	playerFrame.RefreshClassBar = Reposition

	playerFrame.KungFu = bar
	return 'KungFu'
end
