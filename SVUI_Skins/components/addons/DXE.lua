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
local playerName = UnitName("player");
local playerRealm = GetRealmName();
local playerKey = ("%s - %s"):format(playerName, playerRealm)
--[[
##########################################################
DXE
##########################################################
]]--
local function StyleDXEBar(bar)
	bar:SetStyle("!_Frame", "Transparent")
	bar.bg:SetTexture("")
	bar.border.Show = SV.fubar
	bar.border:Hide()
	bar.statusbar:SetStatusBarTexture(SV.media.statusbar.default)
	bar.statusbar:ClearAllPoints()
	bar.statusbar:InsetPoints()
	bar.righticon:SetStyle("!_Frame", "Default")
	bar.righticon.border.Show = SV.fubar
	bar.righticon.border:Hide()
	bar.righticon:ClearAllPoints()
	bar.righticon:SetPoint("LEFT", bar, "RIGHT", 2, 0)
	bar.righticon.t:SetTexCoord(0.1,0.9,0.1,0.9)
	bar.righticon.t:ClearAllPoints()
	bar.righticon.t:InsetPoints()
	bar.righticon.t:SetDrawLayer("ARTWORK")
	bar.lefticon:SetStyle("!_Frame", "Default")
	bar.lefticon.border.Show = SV.fubar
	bar.lefticon.border:Hide()
	bar.lefticon:ClearAllPoints()
	bar.lefticon:SetPoint("RIGHT", bar, "LEFT", -2, 0)
	bar.lefticon.t:SetTexCoord(0.1,0.9,0.1,0.9)
	bar.lefticon.t:ClearAllPoints()
	bar.lefticon.t:InsetPoints()
	bar.lefticon.t:SetDrawLayer("ARTWORK")
end

local function RefreshDXEBars(frame)
	if frame.refreshing then return end
	frame.refreshing = true
	local i = 1
	while _G["DXEAlertBar"..i] do
		local bar = _G["DXEAlertBar"..i]
		if not bar.styled then
			bar:SetScale(1)
			bar.SetScale = SV.fubar
			StyleDXEBar(bar)
			bar.styled = true
		end
		i = i + 1
	end
	frame.refreshing = false
end

LoadAddOn("DXE")

local function StyleDXE()
	assert(DXE, "AddOn Not Loaded")

	DXE.LayoutHealthWatchers_ = DXE.LayoutHealthWatchers
	DXE.LayoutHealthWatchers = function(frame)
		DXE:LayoutHealthWatchers_()
		for i,hw in ipairs(frame.HW) do
			if hw:IsShown() then
				hw:SetStyle("!_Frame", "Transparent")
				hw.border.Show = SV.fubar
				hw.border:Hide()
				hw.healthbar:SetStatusBarTexture(SV.media.statusbar.default)
			end
		end
	end

	local DXEAlerts = DXE:GetModule("Alerts")
	local frame = CreateFrame("Frame")

	frame.elapsed = 1
	frame:SetScript("OnUpdate", function(frame,elapsed)
		frame.elapsed = frame.elapsed + elapsed
		if(frame.elapsed >= 1) then
			RefreshDXEBars(DXEAlerts)
			frame.elapsed = 0
		end
	end)

	hooksecurefunc(DXEAlerts, "Simple", RefreshDXEBars)
	hooksecurefunc(DXEAlerts, "RefreshBars", RefreshDXEBars)
	DXE:LayoutHealthWatchers()
	DXE.Alerts:RefreshBars()

	if not DXEDB then DXEDB = {} end
	if not DXEDB["profiles"] then DXEDB["profiles"] = {} end
	if not DXEDB["profiles"][playerKey] then DXEDB["profiles"][playerKey] = {} end
	if not DXEDB["profiles"][playerKey]["Globals"] then DXEDB["profiles"][playerKey]["Globals"] = {} end

	DXEDB["profiles"][playerKey]["Globals"]["BackgroundTexture"] = [[Interface\BUTTONS\WHITE8X8]]
	DXEDB["profiles"][playerKey]["Globals"]["BarTexture"] = SV.media.statusbar.default
	DXEDB["profiles"][playerKey]["Globals"]["Border"] = "None"
	DXEDB["profiles"][playerKey]["Globals"]["Font"] = SV.media.font.dialog
	DXEDB["profiles"][playerKey]["Globals"]["TimerFont"] = SV.media.font.dialog
end
MOD:SaveAddonStyle("DXE", StyleDXE)
