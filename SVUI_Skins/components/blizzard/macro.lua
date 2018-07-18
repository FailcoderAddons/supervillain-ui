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
HELPERS
##########################################################
]]--
local MacroButtonList = {
	"MacroSaveButton", "MacroCancelButton", "MacroDeleteButton", "MacroNewButton", "MacroExitButton", "MacroEditButton", "MacroFrameTab1", "MacroFrameTab2", "MacroPopupFrame.BorderBox.OkayButton", "MacroPopupFrame.BorderBox.CancelButton"
}
local MacroButtonList2 = {
	"MacroDeleteButton", "MacroNewButton", "MacroExitButton"
}
--[[ 
########################################################## 
MACRO UI MODR
##########################################################
]]--
local function MacroUIStyle()
	if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.macro ~= true then return end
	
	local bStrata = "DIALOG";
	
	SV.API:Set("Window", MacroFrame, true)
	SV.API:Set("CloseButton", MacroFrameCloseButton)
	SV.API:Set("ScrollBar", MacroButtonScrollFrame)
	SV.API:Set("ScrollBar", MacroFrameScrollFrame)
	SV.API:Set("ScrollBar", MacroPopupScrollFrame)

	MacroFrame:SetWidth(360)

	for i = 1, #MacroButtonList do
		local button = _G[MacroButtonList[i]]
		if(button) then
			button:SetFrameStrata(bStrata)
			SV.API:Set("Button", button)
		end
	end 

	for i = 1, #MacroButtonList2 do
		local button = _G[MacroButtonList2[i]]
		if(button) then
			local a1,p,a2,x,y = button:GetPoint()
			button:SetPoint(a1,p,a2,x,-25)
		end
	end 

	local firstTab
	for i = 1, 2 do
		local tab = _G[("MacroFrameTab%d"):format(i)]
		if(tab) then
			tab:SetHeight(22)
			if(i == 1) then
				tab:SetPoint("TOPLEFT", MacroFrame, "TOPLEFT", 85, -39)
				firstTab = tab
			elseif(firstTab) then
				tab:SetPoint("LEFT", firstTab, "RIGHT", 4, 0)
			end
		end
	end 

	MacroFrameText:SetFont(SV.media.font.default, 12, "NONE")
	MacroFrameTextBackground:RemoveTextures()
	MacroFrameTextBackground:SetStyle("Frame", 'Transparent')

	MacroPopupFrame:RemoveTextures()
	MacroPopupFrame:SetStyle("Frame", 'Transparent')
	MacroPopupFrame.BorderBox:RemoveTextures()
	SV.API:Set("EditBox", MacroPopupEditBox)
	MacroPopupScrollFrameScrollBar:RemoveTextures()
	--MacroPopupScrollFrameScrollBar:SetStyle("ScrollBar", "Pattern")
	--MacroPopupScrollFrameScrollBar.Panel:SetPoint("TOPLEFT", 51, 2)
	--MacroPopupScrollFrameScrollBar.Panel:SetPoint("BOTTOMRIGHT", -4, 4)
	--MacroPopupEditBox:SetStyle("Editbox")
	MacroPopupNameLeft:SetTexture("")
	MacroPopupNameMiddle:SetTexture("")
	MacroPopupNameRight:SetTexture("")
	MacroPopupFrame.BorderBox.CancelButton:SetPoint("BOTTOM", MacroPopupFrame, "BOTTOMLEFT", 0, -25)
	MacroFrameInset:Die()

	MacroButtonContainer:RemoveTextures()
	SV.API:Set("ScrollBar", MacroButtonScrollFrame)
	MacroButtonScrollFrameScrollBar:SetStyle("Frame", "Inset")

	MacroPopupFrame:HookScript("OnShow", function(c)
		c:ClearAllPoints()
		c:SetPoint("TOPLEFT", MacroFrame, "TOPRIGHT", 5, -2)
	end)

	MacroFrameSelectedMacroButton:SetFrameStrata(bStrata)
	MacroFrameSelectedMacroButton:RemoveTextures()
	MacroFrameSelectedMacroButton:SetStyle("ActionSlot")
	MacroFrameSelectedMacroButtonIcon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
	MacroFrameSelectedMacroButtonIcon:InsetPoints()

	MacroEditButton:ClearAllPoints()
	MacroEditButton:SetPoint("BOTTOMLEFT", MacroFrameSelectedMacroButton.Panel, "BOTTOMRIGHT", 10, 0)

	MacroFrameCharLimitText:ClearAllPoints()
	MacroFrameCharLimitText:SetPoint("BOTTOM", MacroFrameTextBackground, -25, -35)

	for i = 1, MAX_ACCOUNT_MACROS do 
		local button = _G["MacroButton"..i]
		if(button) then
			button:RemoveTextures()
			button:SetStyle("ActionSlot")

			local icon = _G["MacroButton"..i.."Icon"]
			if(icon) then
				icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
				icon:InsetPoints()
				icon:SetDrawLayer("OVERLAY")
			end

			local popup = _G["MacroPopupButton"..i]
			if(popup) then
				popup:RemoveTextures()
				popup:SetStyle("Button")
				popup:SetBackdropColor(0, 0, 0, 0)

				local popupIcon = _G["MacroPopupButton"..i.."Icon"]
				if(popupIcon) then
					popupIcon:InsetPoints()
					popupIcon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
				end
			end 
		end  
	end 
end 

--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveBlizzardStyle("Blizzard_MacroUI", MacroUIStyle)
