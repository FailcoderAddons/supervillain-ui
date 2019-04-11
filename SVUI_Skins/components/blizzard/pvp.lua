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
PVP MODR
##########################################################
]]--
local _hook_PVPReadyDialogDisplay = function(self, _, _, _, queueType, _, queueRole)
	PVPReadyDialogRoleIconTexture:SetTexture("Interface\\AddOns\\SVUI_Skins\\artwork\\UI-LFG-ICON-ROLES")
	if(queueType == "ARENA") then
		self:SetHeight(100)
	end
end

local function PVPFrameStyle()
	if (SV.db.Skins and (SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.pvp ~= true)) then
		return
	end

	local HonorFrame = _G.HonorFrame;
	local ConquestFrame = _G.ConquestFrame;
	local PVPUIFrame = _G.PVPUIFrame;
	local WarGamesFrame = _G.WarGamesFrame;
	local PVPReadyDialog = _G.PVPReadyDialog;


	for i = 1, 4 do
		local btn = _G["PVPQueueFrameCategoryButton"..i]
		if(btn) then
			btn.Background:Die()
			btn.Ring:Die()
			btn:SetStyle("Button")
			btn.Icon:SetSize(45, 45)
			btn.Icon:SetTexCoord(.15, .85, .15, .85)
			btn.Icon:SetDrawLayer("OVERLAY", nil, 7)
			btn.Panel:WrapPoints(btn.Icon)
		end
	end

	SV.API:Set("DropDown", HonorFrameTypeDropDown)
	HonorFrame.Inset:RemoveTextures()
	HonorFrame.Inset:SetStyle("!_Frame", "Inset")
	SV.API:Set("ScrollBar", HonorFrameSpecificFrameScrollBar)
	HonorFrame.QueueButton:RemoveTextures()
	HonorFrame.QueueButton:SetStyle("Button")
	HonorFrame.BonusFrame:RemoveTextures()
	HonorFrame.BonusFrame.ShadowOverlay:RemoveTextures()
	HonorFrame.BonusFrame.RandomBGButton:RemoveTextures()
	HonorFrame.BonusFrame.RandomBGButton:SetStyle("!_Frame", "Button")
	HonorFrame.BonusFrame.RandomBGButton:SetStyle("Button")
	HonorFrame.BonusFrame.RandomBGButton.SelectedTexture:InsetPoints()
	HonorFrame.BonusFrame.RandomBGButton.SelectedTexture:SetColorTexture(1, 1, 0, 0.1)
	--HonorFrame.BonusFrame.DiceButton:DisableDrawLayer("ARTWORK")
	--HonorFrame.BonusFrame.DiceButton:SetHighlightTexture("")

	HonorFrame.DPSIcon:RemoveTextures()
    HonorFrame.TankIcon:RemoveTextures()
    HonorFrame.HealerIcon:RemoveTextures()
	HonorFrame.DPSIcon.checkButton:SetStyle("CheckButton")
	HonorFrame.TankIcon.checkButton:SetStyle("CheckButton")
	HonorFrame.HealerIcon.checkButton:SetStyle("CheckButton")
	HonorFrame.TankIcon:DisableDrawLayer("OVERLAY")
	HonorFrame.TankIcon:DisableDrawLayer("BACKGROUND")
	HonorFrame.TankIcon:SetNormalTexture("Interface\\AddOns\\SVUI_Skins\\artwork\\UI-LFG-ICON-ROLES")
	HonorFrame.HealerIcon:DisableDrawLayer("OVERLAY")
	HonorFrame.HealerIcon:DisableDrawLayer("BACKGROUND")
	HonorFrame.HealerIcon:SetNormalTexture("Interface\\AddOns\\SVUI_Skins\\artwork\\UI-LFG-ICON-ROLES")
	HonorFrame.DPSIcon:DisableDrawLayer("OVERLAY")
	HonorFrame.DPSIcon:DisableDrawLayer("BACKGROUND")
	HonorFrame.DPSIcon:SetNormalTexture("Interface\\AddOns\\SVUI_Skins\\artwork\\UI-LFG-ICON-ROLES")
	hooksecurefunc("LFG_PermanentlyDisableRoleButton", function(n)
		if n.bg then
			n.bg:SetDesaturated(true)
		end
	end)

	LFGListPVEStub:RemoveTextures(true)
	LFGListPVPStub:RemoveTextures(true)

	local ConquestPointsBar = _G.ConquestPointsBar;

	ConquestFrame.Inset:RemoveTextures()
	-- ConquestPoints.XPBar:RemoveTextures()
	-- ConquestPoints.XPBar:SetStyle("!_Frame", 'Inset')
	-- ConquestPoints.XPBar.Panel:WrapPoints(ConquestPointsBar, nil, -2)
	--[[
	ConquestPointsBarLeft:Die()
	ConquestPointsBarRight:Die()
	ConquestPointsBarMiddle:Die()
	ConquestPointsBarBG:Die()
	ConquestPointsBarShadow:Die()
	ConquestPointsBar.progress:SetTexture(SV.media.statusbar.default)
	ConquestPointsBar:SetStyle("!_Frame", 'Inset')
	ConquestPointsBar.Panel:WrapPoints(ConquestPointsBar, nil, -2)
	]]--
	ConquestFrame:RemoveTextures()
	ConquestFrame.ShadowOverlay:RemoveTextures()
	ConquestJoinButton:RemoveTextures()
	ConquestJoinButton:SetStyle("Button")
	ConquestFrame.RatedBG:RemoveTextures()
	ConquestFrame.RatedBG:SetStyle("!_Frame", "Inset")
	ConquestFrame.RatedBG:SetStyle("Button")
	ConquestFrame.RatedBG.SelectedTexture:InsetPoints()
	ConquestFrame.RatedBG.SelectedTexture:SetColorTexture(1, 1, 0, 0.1)
	-- Leaving the new Honor Frame alone, because it looks cool -Joe
    --WarGamesFrame:RemoveTextures()
	--WarGamesFrame.RightInset:RemoveTextures()
	--WarGamesFrameInfoScrollFrameScrollBar:RemoveTextures()
	--WarGamesFrameInfoScrollFrameScrollBar:RemoveTextures()
	--WarGameStartButton:RemoveTextures()
	--WarGameStartButton:SetStyle("Button")
	--SV.API:Set("ScrollBar", WarGamesFrameScrollFrame)
	--SV.API:Set("ScrollBar", WarGamesFrameInfoScrollFrame)
	--WarGamesFrame.HorizontalBar:RemoveTextures()
    

	PVPReadyDialog:RemoveTextures()
	PVPReadyDialog:SetStyle("Frame", "Pattern")
	PVPReadyDialogEnterBattleButton:SetStyle("Button")
	PVPReadyDialogLeaveQueueButton:SetStyle("Button")
	SV.API:Set("CloseButton", PVPReadyDialogCloseButton)
	PVPReadyDialogRoleIconTexture:SetTexture("Interface\\AddOns\\SVUI_Skins\\artwork\\UI-LFG-ICON-ROLES")
	PVPReadyDialogRoleIconTexture:SetAlpha(0.5)

	ConquestFrame.Inset:SetStyle("!_Frame", "Inset")
	--WarGamesFrameScrollFrameScrollBar:SetStyle("Frame", "Inset",false,2,2,6)

	hooksecurefunc("PVPReadyDialog_Display", _hook_PVPReadyDialogDisplay)
end
--[[
##########################################################
MOD LOADING
##########################################################
]]--
MOD:SaveBlizzardStyle('Blizzard_PVPUI', PVPFrameStyle)

-- /script StaticPopupSpecial_Show(PVPReadyDialog)
