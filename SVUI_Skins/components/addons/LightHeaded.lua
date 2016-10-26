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
--[[ 
########################################################## 
LIGHTHEADED
##########################################################
]]--
local timeLapse = 0;

local function DoDis(self, elapsed)
	self.timeLapse = self.timeLapse + elapsed
	if(self.timeLapse < 2) then 
		return 
	else
		self.timeLapse = 0
	end
	QuestNPCModel:ClearAllPoints()
	QuestNPCModel:SetPoint("TOPLEFT", LightHeadedFrame, "TOPRIGHT", 5, -10)
	QuestNPCModel:SetAlpha(0.85)
	LightHeadedFrame:SetPoint("LEFT", QuestLogFrame, "RIGHT", 2, 0)
end

local function StyleLightHeaded()
	assert(LightHeadedFrame, "AddOn Not Loaded")

	local lhframe 	= _G["LightHeadedFrame"]
	local lhsub 	= _G["LightHeadedFrameSub"]
	local lhopts 	= _G["LightHeaded_Panel"]

	SV.API:Set("Frame", LightHeadedFrame)
	SV.API:Set("Frame", LightHeadedFrameSub)
	SV.API:Set("Frame", LightHeadedSearchBox)
	SV.API:Set("Tooltip", LightHeadedTooltip)
	LightHeadedScrollFrameScrollBar:RemoveTextures()
			
	lhframe.close:Hide()
	SV.API:Set("CloseButton", lhframe.close)
	lhframe.handle:Hide()
	
	SV.API:Set("PageButton", lhsub.prev)
	SV.API:Set("PageButton", lhsub.next)
	lhsub.prev:SetWidth(16)
	lhsub.prev:SetHeight(16)
	lhsub.next:SetWidth(16)
	lhsub.next:SetHeight(16)
	lhsub.prev:SetPoint("RIGHT", lhsub.page, "LEFT", -25, 0)
	lhsub.next:SetPoint("LEFT", lhsub.page, "RIGHT", 25, 0)
	SV.API:Set("ScrollBar", LightHeadedScrollFrameScrollBar, 5)
	lhsub.title:SetTextColor(23/255, 132/255, 209/255)	
	
	lhframe.timeLapse = 0;
	lhframe:SetScript("OnUpdate", DoDis)
	
	if lhopts:IsVisible() then
		for i = 1, 9 do
			local cbox = _G["LightHeaded_Panel_Toggle"..i]
			cbox:SetStyle("CheckButton")
		end
		local buttons = {
			"LightHeaded_Panel_Button1",
			"LightHeaded_Panel_Button2",
		}

		for _, button in pairs(buttons) do
			_G[button]:SetStyle("Button")
		end

		LightHeaded_Panel_Button2:Disable()
	end
end
MOD:SaveAddonStyle("Lightheaded", StyleLightHeaded)