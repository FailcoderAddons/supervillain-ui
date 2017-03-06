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
	SV:AdjustTopDockBar(18)
end

local function OrderHallCommandBar_OnHide()
	SV:AdjustTopDockBar(0)
end
--[[ 
########################################################## 
STYLE
##########################################################
]]--
local function OrderHallStyle()
	--print('test OrderHallStyle')
	if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.orderhall ~= true then
		return 
	end 
	--print('begin OrderHallStyle')
	--OrderHallCommandBar:RemoveTextures()
	--OrderHallCommandBar:SetStyle("Inset")
	--OrderHallCommandBar:DisableDrawLayer("BACKGROUND")
	OrderHallCommandBar:SetStyle("!_Frame", "")
	SV.API:Set("IconButton", OrderHallCommandBar.WorldMapButton, [[Interface\ICONS\INV_Misc_Map02]])
	OrderHallCommandBar:HookScript("OnShow", OrderHallCommandBar_OnShow)
	OrderHallCommandBar:HookScript("OnHide", OrderHallCommandBar_OnHide)
	SV:AdjustTopDockBar(18)
end 
--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveBlizzardStyle("Blizzard_OrderHallUI", OrderHallStyle)