--[[
##############################################################################
S V U I   By: Failcoder
##############################################################################
--]]
--[[ GLOBALS ]]--
local _G = _G;
local unpack  = _G.unpack;
local select  = _G.select;
local tinsert = _G.tinsert;
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
local function OrderHallCommandBar_OnShow()
	SV:AdjustTopDockBar(18);
end

local function OrderHallCommandBar_OnHide()
	SV:AdjustTopDockBar();
end
--[[ 
########################################################## 
STYLE
##########################################################
]]--
local function OrderHallStyle()
	if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.orderhall ~= true then
		return 
	end 
	
	local frame = OrderHallTalentFrame;
	
	-- Set API
	SV.API:Set("Window", frame, true);
	SV.API:Set("Button", frame.BackButton, nil, true);
	
	--Reposition the back button slightly (if there is one)
	--This should only occur inside the Chromie scenario
	frame.BackButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -15, 10);
	
	OrderHallCommandBar:SetStyle("!_Frame", "")
	SV.API:Set("IconButton", OrderHallCommandBar.WorldMapButton, [[Interface\ICONS\INV_Misc_Map02]])
	
	local inOrderHall = C_Garrison.IsPlayerInGarrison(LE_GARRISON_TYPE_7_0);
	if (inOrderHall) then
		OrderHallCommandBar:HookScript("OnShow", OrderHallCommandBar_OnShow);
		frame.currencyButton = CreateFrame("Frame", nil, frame);
		frame.currencyButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -85, -35);
		frame.currencyButton:SetHeight(20);
		frame.currencyButton:SetWidth(20);
		frame.currencyButton:CreateTexture("resources");
		resources:SetAllPoints();
		resources:SetTexture("Interface\\ICONS\\INV_Garrison_Resource");
	end
	
	OrderHallCommandBar:HookScript("OnHide", OrderHallCommandBar_OnHide)
	
	-- Movable Talent Window
	frame:SetMovable(true);
	frame:EnableMouse(true);
	frame:RegisterForDrag("LeftButton");
	frame:SetScript("OnDragStart", frame.StartMoving);
	frame:SetScript("OnDragStop", frame.StopMovingOrSizing);
	
end
--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveBlizzardStyle("Blizzard_OrderHallUI", OrderHallStyle)
