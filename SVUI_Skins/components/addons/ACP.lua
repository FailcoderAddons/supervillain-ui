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
--[[ 
########################################################## 
GET ADDON DATA
##########################################################
]]--
local SV = _G['SVUI'];
local L = SV.L;
local MOD = SV.Skins;
local Schema = MOD.Schema;
--[[ 
########################################################## 
ACP
##########################################################
]]--
local function cbResize(self,elapsed)
	self.timeLapse = self.timeLapse + elapsed
	if(self.timeLapse < 2) then 
		return 
	else
		self.timeLapse = 0
	end
	for i=1,20,1 do 
		local d=_G["ACP_AddonListEntry"..i.."Enabled"]
		local e=_G["ACP_AddonListEntry"..i.."Collapse"]
		local f=_G["ACP_AddonListEntry"..i.."Security"]
		local g=""
		if g=="" then 
			d:SetPoint("LEFT",5,0)
			if e:IsShown()then 
				d:SetWidth(26)
				d:SetHeight(26)
			else 
				d:SetPoint("LEFT",15,0)
				d:SetWidth(20)
				d:SetHeight(20)
			end 
		end 
		if f:IsShown()then 
			d:SetPoint("LEFT",5,0)
			d:SetWidth(26)
			d:SetHeight(26)
		end 
	end 
end

local function StyleACP()
	assert(ACP_AddonList, "AddOn Not Loaded")

	SV.API:Set("Frame", ACP_AddonList)
	SV.API:Set("Frame", ACP_AddonList_ScrollFrame)
	local h={"ACP_AddonListSetButton","ACP_AddonListDisableAll","ACP_AddonListEnableAll","ACP_AddonList_ReloadUI","ACP_AddonListBottomClose"}
	for i,j in pairs(h)do _G[j]:SetStyle("Button")end 
	for c=1,20 do _G["ACP_AddonListEntry"..c.."LoadNow"]:SetStyle("Button")end 
	SV.API:Set("CloseButton", ACP_AddonListCloseButton)
	for c=1,20,1 do 
		local k=_G["ACP_AddonList"]
		k.timeLapse = 0
		k:SetScript("OnUpdate",cbResize)
	end 
	for c=1,20 do 
		_G["ACP_AddonListEntry"..c.."Enabled"]:SetStyle("CheckButton")
	end 
	ACP_AddonList_NoRecurse:SetStyle("CheckButton")
	SV.API:Set("ScrollBar", ACP_AddonList_ScrollFrameScrollBar)
	SV.API:Set("DropDown", ACP_AddonListSortDropDown)
	ACP_AddonListSortDropDown:SetWidth(130)
	ACP_AddonList_ScrollFrame:SetWidth(590)
	ACP_AddonList_ScrollFrame:SetHeight(412)
	ACP_AddonList:SetHeight(502)
	ACP_AddonListEntry1:SetPoint("TOPLEFT",ACP_AddonList,"TOPLEFT",47,-62)
	ACP_AddonList_ScrollFrame:SetPoint("TOPLEFT",ACP_AddonList,"TOPLEFT",20,-53)
	ACP_AddonListCloseButton:SetPoint("TOPRIGHT",ACP_AddonList,"TOPRIGHT",4,5)
	ACP_AddonListSetButton:SetPoint("BOTTOMLEFT",ACP_AddonList,"BOTTOMLEFT",20,8)
	ACP_AddonListSetButton:SetHeight(25)
	ACP_AddonListDisableAll:SetPoint("BOTTOMLEFT",ACP_AddonList,"BOTTOMLEFT",90,8)
	ACP_AddonListDisableAll:SetHeight(25)
	ACP_AddonListEnableAll:SetPoint("BOTTOMLEFT",ACP_AddonList,"BOTTOMLEFT",175,8)
	ACP_AddonListEnableAll:SetHeight(25)
	ACP_AddonList_ReloadUI:SetPoint("BOTTOMRIGHT",ACP_AddonList,"BOTTOMRIGHT",-160,8)
	ACP_AddonListBottomClose:SetPoint("BOTTOMRIGHT",ACP_AddonList,"BOTTOMRIGHT",-50,8)
	ACP_AddonListBottomClose:SetHeight(25)ACP_AddonList:SetParent(UIParent)
end

MOD:SaveAddonStyle("ACP", StyleACP)