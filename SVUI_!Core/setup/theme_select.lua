--[[
##########################################################
S V U I   By: Failcoder
##########################################################
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local select        = _G.select;
local assert        = _G.assert;
local type          = _G.type;
local error         = _G.error;
local pcall         = _G.pcall;
local print         = _G.print;
local ipairs        = _G.ipairs;
local pairs         = _G.pairs;
local next          = _G.next;
local rawset        = _G.rawset;
local rawget        = _G.rawget;
local tostring      = _G.tostring;
local tonumber      = _G.tonumber;
local string 	= _G.string;
local table     = _G.table;
local format = string.format;
local tcopy = table.copy;
--[[
##########################################################
GET ADDON DATA
##########################################################
]]--
local SV = select(2, ...)
local SVUILib = Librarian("Registry");
local L = SV.L;

function SV.Setup:SelectTheme()
	if not SVUI_ThemeSelectFrame then
		local frame = CreateFrame("Button", "SVUI_ThemeSelectFrame", UIParent)
		frame:SetSize(350, 145)
		frame:SetStyle("Frame", "Window2")
		frame:SetPoint("CENTER", SV.Screen, "CENTER", 0, 0)
		frame:SetFrameStrata("TOOLTIP");

		local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
		closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT")
		closeButton:SetScript("OnClick", function() frame:Hide() end)
		SV.API:Set("CloseButton", closeButton)
	end

	local count = 0;
	for themeName, _ in pairs(SV.AvailableThemes) do
		local yOffset = ((125 * count) + 10) * -1;
		local icon = SV.media.icon[themeName] or SV.media.icon.theme
		local themeButton = SVUI_ThemeSelectFrame[themeName]
		if(not themeButton) then
			themeButton = CreateFrame("Frame", nil, SVUI_ThemeSelectFrame)
			themeButton:SetSize(125, 125)
			themeButton:SetPoint("TOP", SVUI_ThemeSelectFrame, "TOP", 0, yOffset)
			themeButton.texture = themeButton:CreateTexture(nil, "BORDER")
			themeButton.texture:SetAllPoints()
			themeButton.texture:SetTexture(icon)
			themeButton.texture:SetVertexColor(1, 1, 1)
			themeButton.text = themeButton:CreateFontString(nil, "OVERLAY")
			themeButton.text:SetFont(SV.media.font.zone, 18, "OUTLINE")
			themeButton.text:SetPoint("BOTTOM")
			themeButton.text:SetText(themeName .. " Theme")
			themeButton.text:SetTextColor(0.1, 0.5, 1)
			themeButton:EnableMouse(true)
			themeButton:SetScript("OnMouseDown", function(self)
				SVUILib:SaveSafeData("THEME", themeName)
				SV:StaticPopup_Show("RL_CLIENT");
			end)
			themeButton:SetScript("OnEnter", function(this)
				this.texture:SetVertexColor(0, 1, 1)
				this.text:SetTextColor(1, 1, 0)
			end)
			themeButton:SetScript("OnLeave", function(this)
				this.texture:SetVertexColor(1, 1, 1)
				this.text:SetTextColor(0.1, 0.5, 1)
			end)
			SVUI_ThemeSelectFrame[themeName] = themeButton
		end

		count = count + 1
	end

	if(count > 1) then
		SVUI_ThemeSelectFrame:ClearAllPoints()
		SVUI_ThemeSelectFrame:SetSize(350, (135 * count) + 20)
		SVUI_ThemeSelectFrame:SetPoint("CENTER", SV.Screen, "CENTER", 0, 0)
		SVUI_ThemeSelectFrame:Show()
	else
		SVUI_ThemeSelectFrame:Hide()
		SV:AddonMessage("You do not have any themes installed")
	end
end
