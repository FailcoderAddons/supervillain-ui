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
BATTLEFIELD MODR
##########################################################
]]--
local function BattlefieldStyle()
	if SV.db.Skins.blizzard.enable~=true or SV.db.Skins.blizzard.bgmap~=true then return end 
	BattlefieldMinimap:SetClampedToScreen(true)
	BattlefieldMinimapCorner:Die()
	BattlefieldMinimapBackground:Die()
	BattlefieldMinimapTab:Die()
	BattlefieldMinimapTabLeft:Die()
	BattlefieldMinimapTabMiddle:Die()
	BattlefieldMinimapTabRight:Die()
	BattlefieldMinimap:SetStyle("!_Frame", "Transparent")
	BattlefieldMinimap.Panel:SetPoint("BOTTOMRIGHT", -4, 2)
	BattlefieldMinimap:SetFrameStrata("LOW")
	BattlefieldMinimapCloseButton:ClearAllPoints()
	BattlefieldMinimapCloseButton:SetPoint("TOPRIGHT", -4, 0)
	SV.API:Set("CloseButton", BattlefieldMinimapCloseButton)
	BattlefieldMinimapCloseButton:SetFrameStrata("MEDIUM")
	BattlefieldMinimap:EnableMouse(true)
	BattlefieldMinimap:SetMovable(true)
	BattlefieldMinimap:SetScript("OnMouseUp", function(f, g)
		if g == "LeftButton"then 
			BattlefieldMinimapTab:StopMovingOrSizing()BattlefieldMinimapTab:SetUserPlaced(true)
			if OpacityFrame:IsShown()then 
				OpacityFrame:Hide()
			end 
		elseif g == "RightButton"then 
			ToggleDropDownMenu(1, nil, BattlefieldMinimapTabDropDown, f:GetName(), 0, -4)
			if OpacityFrame:IsShown()then 
				OpacityFrame:Hide()
			end 
		end 
	end)
	BattlefieldMinimap:SetScript("OnMouseDown", function(f, g)
		if g == "LeftButton"then 
			if BattlefieldMinimapOptions and BattlefieldMinimapOptions.locked then 
				return 
			else 
				BattlefieldMinimapTab:StartMoving()
			end 
		end 
	end)
	hooksecurefunc("BattlefieldMinimap_UpdateOpacity", function(opacity)
		local h = 1.0-BattlefieldMinimapOptions.opacity or 0;
		BattlefieldMinimap.Panel:SetAlpha(h)
	end)
	local i;
	BattlefieldMinimap:HookScript("OnEnter", function()
		i = BattlefieldMinimapOptions.opacity or 0;
		BattlefieldMinimap_UpdateOpacity(0)
	end)
	BattlefieldMinimap:HookScript("OnLeave", function()
		if i then 
			BattlefieldMinimap_UpdateOpacity(i)i = nil 
		end 
	end)
	BattlefieldMinimapCloseButton:HookScript("OnEnter", function()
		i = BattlefieldMinimapOptions.opacity or 0;
		BattlefieldMinimap_UpdateOpacity(0)
	end)
	BattlefieldMinimapCloseButton:HookScript("OnLeave", function()
		if i then 
			BattlefieldMinimap_UpdateOpacity(i)i = nil 
		end 
	end)
end 
--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveBlizzardStyle("Blizzard_BattlefieldMinimap",BattlefieldStyle)