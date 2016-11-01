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
TRADESKILL MODR
##########################################################
]]--
local function TradeSkillStyle()
	if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.tradeskill ~= true then
		 return 
	end

	--local curWidth,curHeight = TradeSkillFrame:GetSize()
	--local enlargedHeight = curHeight + 170;
	--TradeSkillFrame:SetSize(curWidth + 30, curHeight + 166)
	--TradeSkillFrame:RemoveTextures(true)
	SV.API:Set("Window", TradeSkillFrame, true, true)

	TradeSkillFrame.SearchBox:RemoveTextures()
	TradeSkillFrame.RankFrame:RemoveTextures()
	TradeSkillFrame.FilterButton:RemoveTextures(true)
	TradeSkillFrame.LinkNameButton:RemoveTextures(true)
	--TradeSkillFrame.LinkToButton:RemoveTextures(true)
	TradeSkillFrame.FilterDropDown:RemoveTextures(true)
	TradeSkillFrame.LinkToDropDown:RemoveTextures(true)

	TradeSkillFrame.RecipeInset:RemoveTextures()
	--TradeSkillFrame.RecipeList:RemoveTextures()
	TradeSkillFrame.RecipeList.LearnedTab:RemoveTextures()
	TradeSkillFrame.RecipeList.UnlearnedTab:RemoveTextures()

	TradeSkillFrame.DetailsInset:RemoveTextures()
	--TradeSkillFrame.DetailsFrame:RemoveTextures()
	TradeSkillFrame.DetailsFrame.ScrollBar:RemoveTextures()
	TradeSkillFrame.DetailsFrame.CreateButton:RemoveTextures(true)
	TradeSkillFrame.DetailsFrame.CreateAllButton:RemoveTextures(true)
	TradeSkillFrame.DetailsFrame.ExitButton:RemoveTextures(true)
	TradeSkillFrame.DetailsFrame.ViewGuildCraftersButton:RemoveTextures(true)
	TradeSkillFrame.DetailsFrame.CreateMultipleInputBox:RemoveTextures(true)


	-- for i = 9, 18 do
	-- 	local lastLine = "TradeSkillSkill" .. (i - 1);
	-- 	if(lastLine) then
	-- 		local newLine = CreateFrame("Button", "TradeSkillSkill" .. i, TradeSkillFrame, "TradeSkillSkillButtonTemplate")
	-- 		newLine:SetPoint("TOPLEFT", lastLine, "BOTTOMLEFT", 0, 0)
	-- 	end
	-- end
	--_G.TRADE_SKILLS_DISPLAYED = 18;

	-- SV.API:Set("Window", TradeSkillGuildFrame)

	-- TradeSkillGuildFrame:SetPoint("BOTTOMLEFT", TradeSkillFrame, "BOTTOMRIGHT", 3, 19)
	-- TradeSkillGuildFrameContainer:RemoveTextures()
	-- TradeSkillGuildFrameContainer:SetStyle("Frame", "Inset")
	-- SV.API:Set("CloseButton", TradeSkillGuildFrameCloseButton)

	SV.API:Set("DropDown", TradeSkillFrame.FilterDropDown)
	SV.API:Set("DropDown", TradeSkillFrame.LinkToDropDown)
	
	TradeSkillFrame.RankFrame:SetStyle("Frame", "Bar", true)
	TradeSkillFrame.RankFrame:SetStatusBarTexture(SV.media.statusbar.default)
	--print("Test 1")

	--TradeSkillFrame.RecipeList:SetSize(327, 290)
	TradeSkillFrame.RecipeInset:SetStyle("!_ShadowBox", "Model")
	--TradeSkillFrame.RecipeList:SetStyle("Frame", "Inset")
	SV.API:Set("ScrollBar", TradeSkillFrame.RecipeList)
	--TradeSkillFrame.DetailsFrame:SetSize(327, 180)
	TradeSkillFrame.DetailsInset:SetStyle("!_ShadowBox", "Model")
	--TradeSkillFrame.DetailsFrame:SetStyle("Frame", "Inset")
	SV.API:Set("ScrollBar", TradeSkillFrame.DetailsFrame)
	SV.API:Set("ScrollBar", TradeSkillFrame.DetailsFrame.Container)
	SV.API:Set("IconButton", TradeSkillFrame.LinkToButton, [[Interface\CHATFRAME\UI-ChatInput-FocusIcon]])
--TradeSkillFrame.DetailsFrame.Container
	TradeSkillFrame.RetrievingFrame:SetStyle("Frame", "Inset")
	TradeSkillFrame.FilterButton:SetStyle("Button")
	TradeSkillFrame.LinkNameButton:SetStyle("Button")
	--TradeSkillFrame.LinkToButton:SetStyle("Button")
	TradeSkillFrame.RecipeList.LearnedTab:SetStyle("Button")
	TradeSkillFrame.RecipeList.UnlearnedTab:SetStyle("Button")
	TradeSkillFrame.DetailsFrame.CreateButton:SetStyle("Button")
	TradeSkillFrame.DetailsFrame.CreateAllButton:SetStyle("Button")
	TradeSkillFrame.DetailsFrame.ViewGuildCraftersButton:SetStyle("Button")
	TradeSkillFrame.DetailsFrame.ExitButton:SetStyle("Button")
	TradeSkillFrame.DetailsFrame.CreateMultipleInputBox:SetStyle("Editbox")
	TradeSkillFrame.DetailsFrame.ViewGuildCraftersButton:SetStyle("Button")

	SV.API:Set("PageButton", TradeSkillFrame.DetailsFrame.CreateMultipleInputBox.IncrementButton)
	SV.API:Set("PageButton", TradeSkillFrame.DetailsFrame.CreateMultipleInputBox.DecrementButton, false, true)
	SV.API:Set("CloseButton", TradeSkillFrame.CloseButton)
	--SV.API:Set("ScrollBar", TradeSkillFrame.RecipeList)
	-- TradeSkillLinkButton:SetSize(17, 14)
	-- TradeSkillLinkButton:SetPoint("LEFT", TradeSkillLinkFrame, "LEFT", 5, -1)
	-- TradeSkillLinkButton:SetStyle("Button")
	-- TradeSkillLinkButton:GetNormalTexture():SetTexCoord(0.25, 0.7, 0.45, 0.8)

	TradeSkillFrame.SearchBox:SetStyle("Editbox")
	-- TradeSkillInputBox:SetStyle("Editbox")

	-- SV.API:Set("PageButton", TradeSkillDecrementButton)
	-- SV.API:Set("PageButton", TradeSkillIncrementButton)

	-- TradeSkillIncrementButton:SetPoint("RIGHT", TradeSkillCreateButton, "LEFT", -13, 0)
	-- SV.API:Set("CloseButton", TradeSkillFrame.CloseButton) 

	-- local internalTest = false;

	-- hooksecurefunc("TradeSkillFrame_SetSelection", function(_)
	-- 	TradeSkillSkillIcon:SetStyle("Icon") 
	-- 	if TradeSkillSkillIcon:GetNormalTexture() then
	-- 		TradeSkillSkillIcon:GetNormalTexture():SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
	-- 	end 
	-- 	--TradeSkillSkillIconCount:SetFrameLevel(TradeSkillSkillIcon:GetFrameLevel() + 20)
	-- 	for i=1, MAX_TRADE_SKILL_REAGENTS do 
	-- 		local u = _G["TradeSkillReagent"..i]
	-- 		local icon = _G["TradeSkillReagent"..i.."IconTexture"]
	-- 		local a1 = _G["TradeSkillReagent"..i.."Count"]
	-- 		icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
	-- 		icon:SetDrawLayer("OVERLAY")
	-- 		if not icon.backdrop then 
	-- 			local a2 = CreateFrame("Frame", nil, u)
	-- 			if u:GetFrameLevel()-1 >= 0 then
	-- 				 a2:SetFrameLevel(u:GetFrameLevel()-1)
	-- 			else
	-- 				 a2:SetFrameLevel(0)
	-- 			end 
	-- 			a2:WrapPoints(icon)
	-- 			a2:SetStyle("Icon") 
	-- 			icon:SetParent(a2)
	-- 			icon.backdrop = a2 
	-- 		end 
	-- 		a1:SetParent(icon.backdrop)
	-- 		a1:SetDrawLayer("OVERLAY")
	-- 		if i > 2 and internalTest == false then 
	-- 			local d, a3, f, g, h = u:GetPoint()
	-- 			u:ClearAllPoints()
	-- 			u:SetPoint(d, a3, f, g, h-3)
	-- 			internalTest = true 
	-- 		end 
	-- 		_G["TradeSkillReagent"..i.."NameFrame"]:Die()
	-- 	end 
	-- end)
end 
--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveBlizzardStyle("Blizzard_TradeSkillUI",TradeSkillStyle)