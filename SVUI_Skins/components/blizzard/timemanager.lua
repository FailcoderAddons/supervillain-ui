--[[
##############################################################################
S V U I   By: Failcoder
##############################################################################
--]]
--[[ GLOBALS ]]--
local _G = _G;
local unpack  = _G.unpack;
local select  = _G.select;
--[[ ADDON ]]--
local SV = _G['SVUI'];
local L = SV.L;
local MOD = SV.Skins;
local Schema = MOD.Schema;
--[[ 
########################################################## 
TIMEMANAGER MODR
##########################################################
]]--
local function TimeManagerStyle()
	if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.timemanager ~= true then
		 return 
	end 
	
	SV.API:Set("Window", TimeManagerFrame, true)

	SV.API:Set("CloseButton", TimeManagerFrameCloseButton)
	TimeManagerFrameInset:Die()
	SV.API:Set("DropDown", TimeManagerAlarmHourDropDown, 80)
	SV.API:Set("DropDown", TimeManagerAlarmMinuteDropDown, 80)
	SV.API:Set("DropDown", TimeManagerAlarmAMPMDropDown, 80)
	TimeManagerAlarmMessageEditBox:SetStyle("Editbox")
	TimeManagerAlarmEnabledButton:SetStyle("CheckButton")
	TimeManagerMilitaryTimeCheck:SetStyle("CheckButton")
	TimeManagerLocalTimeCheck:SetStyle("CheckButton")
	TimeManagerStopwatchFrame:RemoveTextures()
	TimeManagerStopwatchCheck:SetStyle("!_Frame", "Default")
	TimeManagerStopwatchCheck:GetNormalTexture():SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
	TimeManagerStopwatchCheck:GetNormalTexture():InsetPoints()
	local sWatch = TimeManagerStopwatchCheck:CreateTexture(nil, "OVERLAY")
	sWatch:SetColorTexture(1, 1, 1, 0.3)
	sWatch:SetPoint("TOPLEFT", TimeManagerStopwatchCheck, 2, -2)
	sWatch:SetPoint("BOTTOMRIGHT", TimeManagerStopwatchCheck, -2, 2)
	TimeManagerStopwatchCheck:SetHighlightTexture(sWatch)

	StopwatchFrame:RemoveTextures()
	StopwatchFrame:SetStyle("Frame", 'Transparent')
	StopwatchFrame.Panel:SetPoint("TOPLEFT", 0, -17)
	StopwatchFrame.Panel:SetPoint("BOTTOMRIGHT", 0, 2)

	StopwatchTabFrame:RemoveTextures()
	
	SV.API:Set("CloseButton", StopwatchCloseButton)
	SV.API:Set("PageButton", StopwatchPlayPauseButton)
	SV.API:Set("PageButton", StopwatchResetButton)
	StopwatchPlayPauseButton:SetPoint("RIGHT", StopwatchResetButton, "LEFT", -4, 0)
	StopwatchResetButton:SetPoint("BOTTOMRIGHT", StopwatchFrame, "BOTTOMRIGHT", -4, 6)
end 
--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveBlizzardStyle("Blizzard_TimeManager",TimeManagerStyle)