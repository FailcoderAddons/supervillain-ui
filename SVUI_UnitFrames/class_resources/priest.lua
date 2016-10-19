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
if(SV.class ~= "PRIEST") then return end 

local ORB_ICON = [[Interface\AddOns\SVUI_UnitFrames\assets\Class\ORB]]
local ORB_BG = [[Interface\AddOns\SVUI_UnitFrames\assets\Class\ORB-BG]]
local specEffects = { [1] = "holy", [2] = "holy", [3] = "shadow" };
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
	local bar = self.PriestOrbs;
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
		bar[i]:SetHeight(size)
		bar[i]:SetWidth(size)
		if i==1 then 
			bar[i]:SetPoint("TOPLEFT", bar, "TOPLEFT", 0, 0)
		else 
			bar[i]:SetPoint("LEFT", bar[i - 1], "RIGHT", -1, 0) 
		end
	end 
	--print(UnitPowerType('player'))
end 
--[[ 
########################################################## 
PRIEST
##########################################################
]]--
local PreUpdate = function(self, spec)
	if(self.CurrentSpec and (self.CurrentSpec == spec)) then return end
	local effectName = specEffects[spec]
	for i = 1, 5 do
		self[i].FX:SetEffect(effectName)
	end
	self.CurrentSpec = spec
end 

function MOD:CreateClassBar(playerFrame)
	local max = 5
	local bar = CreateFrame("Frame", nil, playerFrame)
	bar:SetFrameLevel(playerFrame.TextGrip:GetFrameLevel() + 30)

	for i=1, max do 
		bar[i] = CreateFrame("StatusBar", nil, bar)
		bar[i]:SetStatusBarTexture(ORB_ICON)
		bar[i]:GetStatusBarTexture():SetHorizTile(false)
		bar[i].noupdate = true;
		
		bar[i].bg = bar[i]:CreateTexture(nil, "BACKGROUND")
		bar[i].bg:SetAllPoints(bar[i])
		bar[i].bg:SetTexture(ORB_BG)

		local spec = GetSpecialization()
		local effectName = specEffects[spec]
		SV.SpecialFX:SetFXFrame(bar[i], effectName)
	end 
	bar.PreUpdate = PreUpdate

	local classBarHolder = CreateFrame("Frame", "Player_ClassBar", bar)
	classBarHolder:SetPoint("TOPLEFT", playerFrame, "BOTTOMLEFT", 0, -2)
	bar:SetPoint("TOPLEFT", classBarHolder, "TOPLEFT", 0, 0)
	bar.Holder = classBarHolder
	SV:NewAnchor(bar.Holder, L["Classbar"], OnMove)

	playerFrame.MaxClassPower = max;
	playerFrame.RefreshClassBar = Reposition;

	playerFrame.PriestOrbs = bar
	return 'PriestOrbs' 
end 