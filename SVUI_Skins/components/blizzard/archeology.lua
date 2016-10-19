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
ARCHEOLOGYFRAME MODR
##########################################################
]]--
local function ArchaeologyStyle()
	if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.archaeology ~= true then return end

	ArchaeologyFrame:RemoveTextures()
	ArchaeologyFrameInset:RemoveTextures()
	ArchaeologyFrame:SetStyle("Frame", "Window")
	ArchaeologyFrame.Panel:SetAllPoints()
	ArchaeologyFrame.portrait:SetAlpha(0)
	ArchaeologyFrameInset:SetStyle("Frame", "Inset")
	ArchaeologyFrameInset.Panel:SetPoint("TOPLEFT")
	ArchaeologyFrameInset.Panel:SetPoint("BOTTOMRIGHT", -3, -1)
	ArchaeologyFrameArtifactPageSolveFrameSolveButton:SetStyle("Button")
	ArchaeologyFrameArtifactPageBackButton:SetStyle("Button")
	ArchaeologyFrameRaceFilter:SetFrameLevel(ArchaeologyFrameRaceFilter:GetFrameLevel()+2)
	SV.API:Set("DropDown", ArchaeologyFrameRaceFilter, 125)
	SV.API:Set("PageButton", ArchaeologyFrameCompletedPageNextPageButton)
	SV.API:Set("PageButton", ArchaeologyFrameCompletedPagePrevPageButton)
	ArchaeologyFrameRankBar:RemoveTextures()
	ArchaeologyFrameRankBar:SetStatusBarTexture(SV.media.statusbar.default)
	ArchaeologyFrameRankBar:SetFrameLevel(ArchaeologyFrameRankBar:GetFrameLevel()+2)
	ArchaeologyFrameRankBar:SetStyle("Frame", "Default")
	ArchaeologyFrameArtifactPageSolveFrameStatusBar:RemoveTextures()
	ArchaeologyFrameArtifactPageSolveFrameStatusBar:SetStatusBarTexture(SV.media.statusbar.default)
	ArchaeologyFrameArtifactPageSolveFrameStatusBar:SetStatusBarColor(0.7, 0.2, 0)
	ArchaeologyFrameArtifactPageSolveFrameStatusBar:SetFrameLevel(ArchaeologyFrameArtifactPageSolveFrameStatusBar:GetFrameLevel()+2)
	ArchaeologyFrameArtifactPageSolveFrameStatusBar:SetStyle("Frame", "Default")

	for b = 1, ARCHAEOLOGY_MAX_COMPLETED_SHOWN do
		local c = _G["ArchaeologyFrameCompletedPageArtifact"..b]
		if c then
			_G["ArchaeologyFrameCompletedPageArtifact"..b.."Border"]:Die()
			_G["ArchaeologyFrameCompletedPageArtifact"..b.."Bg"]:Die()
			_G["ArchaeologyFrameCompletedPageArtifact"..b.."Icon"]:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
			_G["ArchaeologyFrameCompletedPageArtifact"..b.."Icon"].backdrop = CreateFrame("Frame", nil, c)
			_G["ArchaeologyFrameCompletedPageArtifact"..b.."Icon"].backdrop:SetStyle("!_Frame", "Default")
			_G["ArchaeologyFrameCompletedPageArtifact"..b.."Icon"].backdrop:WrapPoints(_G["ArchaeologyFrameCompletedPageArtifact"..b.."Icon"])
			_G["ArchaeologyFrameCompletedPageArtifact"..b.."Icon"].backdrop:SetFrameLevel(c:GetFrameLevel()-2)
			_G["ArchaeologyFrameCompletedPageArtifact"..b.."Icon"]:SetDrawLayer("OVERLAY")
		end
	end

	ArchaeologyFrameArtifactPageIcon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
	ArchaeologyFrameArtifactPageIcon.backdrop = CreateFrame("Frame", nil, ArchaeologyFrameArtifactPage)
	ArchaeologyFrameArtifactPageIcon.backdrop:SetStyle("!_Frame", "Default")
	ArchaeologyFrameArtifactPageIcon.backdrop:WrapPoints(ArchaeologyFrameArtifactPageIcon)
	ArchaeologyFrameArtifactPageIcon.backdrop:SetFrameLevel(ArchaeologyFrameArtifactPage:GetFrameLevel())
	ArchaeologyFrameArtifactPageIcon:SetParent(ArchaeologyFrameArtifactPageIcon.backdrop)
	ArchaeologyFrameArtifactPageIcon:SetDrawLayer("OVERLAY")
	SV.API:Set("CloseButton", ArchaeologyFrameCloseButton)

	local progressBarHolder = CreateFrame("Frame", "SVUI_ArcheologyProgressBar", SV.Screen)
	progressBarHolder:SetSize(240, 24)
	progressBarHolder:SetPoint("TOP", SV.Screen, "CENTER", 0, -180)
	SV:NewAnchor(progressBarHolder, "Archeology Progress Bar")

	ArcheologyDigsiteProgressBar:SetAllPoints(progressBarHolder)
	progressBarHolder:SetParent(ArcheologyDigsiteProgressBar)

	ArcheologyDigsiteProgressBar.Shadow:SetTexture("Interface\\AddOns\\SVUI_Skins\\artwork\\ArcheologyToast")
	ArcheologyDigsiteProgressBar.BarBackground:SetTexture("Interface\\AddOns\\SVUI_Skins\\artwork\\ArcheologyToast")
	ArcheologyDigsiteProgressBar.BarBorderAndOverlay:SetTexture("Interface\\AddOns\\SVUI_Skins\\artwork\\ArcheologyToast")
	ArcheologyDigsiteProgressBar.Flash:SetTexture("Interface\\AddOns\\SVUI_Skins\\artwork\\ArcheologyToast")
	ArcheologyDigsiteProgressBar.FillBar:SetStatusBarTexture("Interface\\AddOns\\SVUI_Skins\\artwork\\Arch-Progress-Fill")
end
--[[
##########################################################
MOD LOADING
##########################################################
]]--
MOD:SaveBlizzardStyle("Blizzard_ArchaeologyUI", ArchaeologyStyle)
