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
local HelpFrameList = {
	"HelpFrameLeftInset",
	"HelpFrameMainInset",
	"HelpFrameKnowledgebase",
	"HelpFrameHeader",
	"HelpFrameKnowledgebaseErrorFrame"
}

local HelpFrameButtonList = {
	"HelpFrameOpenTicketHelpItemRestoration",
	"HelpFrameAccountSecurityOpenTicket",
	"HelpFrameOpenTicketHelpTopIssues",
	"HelpFrameOpenTicketHelpOpenTicket",
	"HelpFrameKnowledgebaseSearchButton",
	--"HelpFrameKnowledgebaseNavBarHomeButton",
	"HelpFrameCharacterStuckStuck",
	"GMChatOpenLog",
	"HelpFrameTicketSubmit",
	"HelpFrameTicketCancel"
}

local function NavBarHelper(button)
	for i = 1, #button.navList do 
		local this = button.navList[i]
		local last = button.navList[i - 1]
		if this and last then
			local level = last:GetFrameLevel()
			if(level >= 2) then
				level = level - 2
			else
				level = 0
			end
			this:SetFrameLevel(level)
		end 
	end 
end 
--[[ 
########################################################## 
HELPFRAME MODR
##########################################################
]]--
local function HelpFrameStyle()
	--print('test HelpFrameStyle')
	if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.help ~= true then
		return 
	end 
	tinsert(HelpFrameButtonList, "HelpFrameButton16")
	tinsert(HelpFrameButtonList, "HelpFrameSubmitSuggestionSubmit")
	tinsert(HelpFrameButtonList, "HelpFrameReportBugSubmit")
	for d = 1, #HelpFrameList do
		_G[HelpFrameList[d]]:RemoveTextures(true)
		_G[HelpFrameList[d]]:SetStyle("Frame", "Default")
	end 
	HelpFrameHeader:SetFrameLevel(HelpFrameHeader:GetFrameLevel()+2)
	HelpFrameKnowledgebaseErrorFrame:SetFrameLevel(HelpFrameKnowledgebaseErrorFrame:GetFrameLevel()+2)
	HelpFrameReportBugScrollFrameScrollBar:RemoveTextures()
	HelpFrameReportBugScrollFrameScrollBar:SetStyle("Frame", "Default")
	HelpFrameReportBugScrollFrameScrollBar.Panel:SetPoint("TOPLEFT", -4, 4)
	HelpFrameReportBugScrollFrameScrollBar.Panel:SetPoint("BOTTOMRIGHT", 6, -4)
	for d = 1, HelpFrameReportBug:GetNumChildren()do 
		local e = select(d, HelpFrameReportBug:GetChildren())
		if not e:GetName() then
			e:RemoveTextures()
		end 
	end 
	SV.API:Set("ScrollBar", HelpFrameReportBugScrollFrame)
	HelpFrameSubmitSuggestionScrollFrameScrollBar:RemoveTextures()
	HelpFrameSubmitSuggestionScrollFrameScrollBar:SetStyle("Frame", "Default")
	HelpFrameSubmitSuggestionScrollFrameScrollBar.Panel:SetPoint("TOPLEFT", -4, 4)
	HelpFrameSubmitSuggestionScrollFrameScrollBar.Panel:SetPoint("BOTTOMRIGHT", 6, -4)
	for d = 1, HelpFrameSubmitSuggestion:GetNumChildren()do 
		local e = select(d, HelpFrameSubmitSuggestion:GetChildren())
		if not e:GetName() then
			e:RemoveTextures()
		end 
	end 
	SV.API:Set("ScrollBar", HelpFrameSubmitSuggestionScrollFrame)
	SV.API:Set("ScrollBar", HelpFrameKnowledgebaseScrollFrame2ScrollBar)
	for d = 1, #HelpFrameButtonList do
		local bname = HelpFrameButtonList[d]
		if(bname and _G[bname]) then
			_G[bname]:RemoveTextures(true)
			_G[bname]:SetStyle("Button")
			if _G[bname].text then
				_G[bname].text:ClearAllPoints()
				_G[bname].text:SetPoint("CENTER")
				_G[bname].text:SetJustifyH("CENTER")
			end 
		end
	end 
	for d = 1, 6 do 
		local f = _G["HelpFrameButton"..d]
		f:SetStyle("Button")
		f.text:ClearAllPoints()
		f.text:SetPoint("CENTER")
		f.text:SetJustifyH("CENTER")
	end 
	for d = 1, HelpFrameKnowledgebaseScrollFrameScrollChild:GetNumChildren()do 
		local f = _G["HelpFrameKnowledgebaseScrollFrameButton"..d]
		f:RemoveTextures(true)
		f:SetStyle("Button")
	end 
	HelpFrameKnowledgebaseSearchBox:ClearAllPoints()
	HelpFrameKnowledgebaseSearchBox:SetPoint("TOPLEFT", HelpFrameMainInset, "TOPLEFT", 13, -10)
	--HelpFrameKnowledgebaseNavBarOverlay:Die()
	--HelpFrameKnowledgebaseNavBar:RemoveTextures()
	HelpFrame:RemoveTextures(true)
	HelpFrame:SetStyle("Frame", "Window")
	HelpFrameKnowledgebaseSearchBox:SetStyle("Editbox")
	SV.API:Set("ScrollBar", HelpFrameKnowledgebaseScrollFrame, 5)
	
	SV.API:Set("CloseButton", HelpFrameCloseButton, HelpFrame.Panel)
	SV.API:Set("CloseButton", HelpFrameKnowledgebaseErrorFrameCloseButton, HelpFrameKnowledgebaseErrorFrame.Panel)
	HelpFrameCharacterStuckHearthstone:SetStyle("Button")
	HelpFrameCharacterStuckHearthstone:SetStyle("!_Frame", "Default")
	HelpFrameCharacterStuckHearthstone.IconTexture:InsetPoints()
	HelpFrameCharacterStuckHearthstone.IconTexture:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
	hooksecurefunc("NavBar_AddButton", function(h, k)
		local i = h.navList[#h.navList]
		if not i.styled then
			i:SetStyle("Button")
			i.styled = true;
			i:HookScript("OnClick", function()
				NavBarHelper(h)
			end)
		end 
		NavBarHelper(h)
	end)
	HelpFrameGM_ResponseNeedMoreHelp:SetStyle("Button")
	HelpFrameGM_ResponseCancel:SetStyle("Button")
	for d = 1, HelpFrameGM_Response:GetNumChildren()do 
		local e = select(d, HelpFrameGM_Response:GetChildren())
		if e and e:GetObjectType()
		 == "Frame"and not e:GetName()
		then
			e:SetStyle("!_Frame", "Default")
		end 
	end

	if(_G['HelpFrameTicket']) then
		if(_G['HelpFrameTicketScrollFrame']) then
			HelpFrameTicketScrollFrameScrollBar:RemoveTextures()
			HelpFrameTicketScrollFrameScrollBar:SetStyle("Frame", "Default")
			HelpFrameTicketScrollFrameScrollBar.Panel:SetPoint("TOPLEFT", -4, 4)
			HelpFrameTicketScrollFrameScrollBar.Panel:SetPoint("BOTTOMRIGHT", 6, -4)
		end
		for d = 1, HelpFrameTicket:GetNumChildren()do 
			local e = select(d, HelpFrameTicket:GetChildren())
			if not e:GetName() then
				e:RemoveTextures()
			end 
		end
		SV.API:Set("ScrollBar", HelpFrameTicketScrollFrame, 4)
	end
end 
--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveCustomStyle("HELP", HelpFrameStyle)