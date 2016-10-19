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
--[[ 
########################################################## 
HELPERS
##########################################################
]]--
local RegisterAsWidget, RegisterAsContainer;

local ProxyLSMType = {
	["LSM30_Font"] = true, 
	["LSM30_Sound"] = true, 
	["LSM30_Border"] = true, 
	["LSM30_Background"] = true, 
	["LSM30_Statusbar"] = true
}

local ProxyType = {
	["InlineGroup"] = true, 
	["TreeGroup"] = true, 
	["TabGroup"] = true, 
	["SimpleGroup"] = true,
	["DropdownGroup"] = true
}

local function Widget_OnEnter(b)
	b:SetBackdropBorderColor(0.1, 0.8, 0.8)
end

local function Widget_OnLeave(b)
	b:SetBackdropBorderColor(0,0,0,1)
end

local function Widget_ScrollStyle(frame, arg)
	return SV.API:Set("ScrollBar", frame) 
end 

local function Widget_ButtonStyle(frame, strip, bypass)
	if frame.Left then frame.Left:SetAlpha(0) end 
	if frame.Middle then frame.Middle:SetAlpha(0) end 
	if frame.Right then frame.Right:SetAlpha(0) end 
	if frame.SetNormalTexture then frame:SetNormalTexture("") end 
	if frame.SetHighlightTexture then frame:SetHighlightTexture(0,0,0,0) end 
	if frame.SetPushedTexture then frame:SetPushedTexture(0,0,0,0) end 
	if frame.SetDisabledTexture then frame:SetDisabledTexture("") end 
	if strip then frame:RemoveTextures() end 
	if not bypass then 
		frame:SetStyle("Button")
	end
end 

local function Widget_PaginationStyle(...)
	SV.API:Set("PageButton", ...)
end

local function SetAdjustedStyle(this, xTopleft, yTopleft, xBottomright, yBottomright)
	if(not this or (this and this.Panel)) then return end
	this:RemoveTextures()
	this:SetStyle("Frame", "Transparent")
	this.Panel:SetPoint("TOPLEFT", this, "TOPLEFT", xTopleft, yTopleft)
	this.Panel:SetPoint("BOTTOMRIGHT", this, "BOTTOMRIGHT", xBottomright, yBottomright)
end

local NOOP = SV.fubar

local WidgetButton_OnClick = function(self)
	local obj = self.obj;
	if(obj and obj.pullout and obj.pullout.frame) then
		SV.API:Set("Frame", obj.pullout.frame, "Default", true)
	end
end

local WidgetDropButton_OnClick = function(self)
	local obj = self.obj;
	local widgetFrame = obj.dropdown
	if(widgetFrame) then
    	widgetFrame:SetWidth(220)
		widgetFrame:SetStyle("Frame", "Default")
	end
end
--[[ 
########################################################## 
AceGUI MOD
##########################################################
]]--
function MOD:StyleSVUIOptions()
	local AceGUI = LibStub("AceGUI-3.0")

	assert(AceGUI and (AceGUI.RegisterAsContainer ~= RegisterAsContainer or AceGUI.RegisterAsWidget ~= RegisterAsWidget), "Addon Not Loaded")

	local regWidget = AceGUI.RegisterAsWidget;
	local regContainer = AceGUI.RegisterAsContainer;

	RegisterAsWidget = function(self, widget)

		local widgetType = widget.type;
		-- print("RegisterAsWidget: " .. widgetType);
		if(widgetType == "MultiLineEditBox") then 
			local widgetFrame = widget.frame;
			SV.API:Set("!_Frame", widgetFrame, "Default", true)
			SV.API:Set("Frame", widget.scrollBG, "Lite", true) 
			Widget_ButtonStyle(widget.button)
			SV.API:Set("ScrollBar", widget.scrollBar) 
			widget.scrollBar:SetPoint("RIGHT", widgetFrame, "RIGHT", -4)
			widget.scrollBG:SetPoint("TOPRIGHT", widget.scrollBar, "TOPLEFT", -2, 19)
			widget.scrollBG:SetPoint("BOTTOMLEFT", widget.button, "TOPLEFT")
			widget.scrollFrame:SetPoint("BOTTOMRIGHT", widget.scrollBG, "BOTTOMRIGHT", -4, 8)

		elseif(widgetType == "CheckBox") then 
			widget.checkbg:Die()
			widget.highlight:Die()
			if not widget.styledCheckBG then 
				widget.styledCheckBG = CreateFrame("Frame", nil, widget.frame)
				widget.styledCheckBG:InsetPoints(widget.check)
				SV.API:Set("!_Frame", widget.styledCheckBG, "CheckButton")
			end 
			widget.check:SetParent(widget.styledCheckBG)

		elseif(widgetType == "Dropdown") then 
			local widgetDropdown = widget.dropdown;
			local widgetButton = widget.button;

			widgetDropdown:RemoveTextures()
			widgetButton:ClearAllPoints()
			widgetButton:SetPoint("RIGHT", widgetDropdown, "RIGHT", -20, 0)
			widgetButton:SetFrameLevel(widgetButton:GetFrameLevel() + 1)
			Widget_PaginationStyle(widgetButton, true)

			SetAdjustedStyle(widgetDropdown, 20, -2, -20, 2)

			widgetButton:SetParent(widgetDropdown.Panel)
			widget.text:SetParent(widgetDropdown.Panel)
			widgetButton:HookScript("OnClick", WidgetButton_OnClick)

		elseif(widgetType == "EditBox") then 
			local widgetEditbox = widget.editbox;
			SV.API:Set("EditBox", widgetEditbox, nil, 15, 2, -2)

		elseif(widgetType == "Button") then 
			local widgetFrame = widget.frame;
			Widget_ButtonStyle(widgetFrame, true)
			widget.text:SetParent(widgetFrame.Panel)

		elseif(widgetType == "Slider") then 
			local widgetSlider = widget.slider;
			local widgetEditbox = widget.editbox;

			SV.API:Set("!_Frame", widgetSlider, "Bar")

			widgetSlider:SetHeight(20)
			widgetSlider:SetThumbTexture("Interface\\Buttons\\UI-ScrollBar-Knob")
			widgetSlider:GetThumbTexture():SetVertexColor(0.8, 0.8, 0.8)

			widgetEditbox:SetHeight(15)
			widgetEditbox:SetPoint("TOP", widgetSlider, "BOTTOM", 0, -1)

			widget.lowtext:SetPoint("TOPLEFT", widgetSlider, "BOTTOMLEFT", 2, -2)
			widget.hightext:SetPoint("TOPRIGHT", widgetSlider, "BOTTOMRIGHT", -2, -2)

		elseif(ProxyLSMType[widgetType]) then 
			local widgetFrame = widget.frame;
			local dropButton = widgetFrame.dropButton;

			widgetFrame:RemoveTextures()
			Widget_PaginationStyle(dropButton, true)
			widgetFrame.text:ClearAllPoints()
			widgetFrame.text:SetPoint("RIGHT", dropButton, "LEFT", -2, 0)
			dropButton:ClearAllPoints()
			dropButton:SetPoint("RIGHT", widgetFrame, "RIGHT", -10, -6)
			if(not widgetFrame.Panel) then 
				if(widgetType == "LSM30_Sound") then 
					SetAdjustedStyle(widgetFrame, 20, -17, 2, -2)
					widget.soundbutton:SetParent(widgetFrame.Panel)
					widget.soundbutton:ClearAllPoints()
					widget.soundbutton:SetPoint("LEFT", widgetFrame.Panel, "LEFT", 2, 0)
				elseif(widgetType == "LSM30_Statusbar") then 
					SetAdjustedStyle(widgetFrame, 20, -17, 2, -2)
					widget.bar:SetParent(widgetFrame.Panel)
					widget.bar:InsetPoints()
				elseif(widgetType == "LSM30_Border" or widgetType == "LSM30_Background") then 
					SetAdjustedStyle(widgetFrame, 42, -17, 2, -2)
				else
					SetAdjustedStyle(widgetFrame, 20, -17, 2, -2)
				end 
				widgetFrame.Panel:SetPoint("BOTTOMRIGHT", dropButton, "BOTTOMRIGHT", 2, -2)
			end 
			dropButton:SetParent(widgetFrame.Panel)
			widgetFrame.text:SetParent(widgetFrame.Panel)
		end
		return regWidget(self, widget)
	end

	AceGUI.RegisterAsWidget = RegisterAsWidget

	RegisterAsContainer = function(self, widget)
		local widgetType = widget.type;
		-- print("RegisterAsContainer: " .. widgetType);
		local widgetParent = widget.content:GetParent()
		if widgetType == "ScrollFrame" then 
			SV.API:Set("ScrollBar", widget.scrollBar) 
		elseif widgetType == "Frame" then
			for i = 1, widgetParent:GetNumChildren()do 
				local childFrame = select(i, widgetParent:GetChildren())
				if childFrame:GetObjectType() == "Button" and childFrame:GetText() then 
					Widget_ButtonStyle(childFrame)
				else 
					childFrame:RemoveTextures()
				end 
			end
			SV.API:Set("Window", widgetParent)
		elseif(ProxyType[widgetType]) then

			if widget.treeframe then 
				SV.API:Set("Frame", widget.treeframe, "Transparent")
				widgetParent:SetPoint("TOPLEFT", widget.treeframe, "TOPRIGHT", 1, 0)
				local oldFunc = widget.CreateButton;
				widget.CreateButton = function(self)
					local newButton = oldFunc(self)
					newButton.toggle:RemoveTextures()
					newButton.toggle.SetNormalTexture = NOOP;
					newButton.toggle.SetPushedTexture = NOOP;
					newButton.toggle:SetStyle("Button")
					newButton.toggleText = newButton.toggle:CreateFontString(nil, "OVERLAY")
					newButton.toggleText:SetFont([[Interface\AddOns\SVUI_!Core\assets\fonts\Default.ttf]], 19)
					newButton.toggleText:SetPoint("CENTER")
					newButton.toggleText:SetText("*")
					return newButton 
				end
			elseif(not widgetParent.Panel) then
				SV.API:Set("Frame", widgetParent, "Lite")
			end

			if(widgetType == "TabGroup") then
				local oldFunc = widget.CreateTab;
				widget.CreateTab = function(self, arg)
					local newTab = oldFunc(self, arg)
					newTab:RemoveTextures()
					return newTab 
				end 
			end

			if widget.scrollbar then 
				SV.API:Set("ScrollBar", widget.scrollBar) 
			end 
		end
		return regContainer(self, widget)
	end 

	AceGUI.RegisterAsContainer = RegisterAsContainer
end