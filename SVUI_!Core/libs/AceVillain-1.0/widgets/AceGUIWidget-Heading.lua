--[[-----------------------------------------------------------------------------
Heading Widget
-------------------------------------------------------------------------------]]
local Type, Version = "Heading", 999999
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

-- Lua APIs
local pairs = pairs

-- WoW APIs
local CreateFrame, UIParent = CreateFrame, UIParent

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {
	["OnAcquire"] = function(self)
		self:SetText()
		self:SetFullWidth()
		self:SetHeight(18)
	end,

	-- ["OnRelease"] = nil,

	["SetText"] = function(self, text)
		self.label:SetText(text or "")
	end
}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local function Constructor()
	local frame = CreateFrame("Frame", nil, UIParent)
	frame:Hide()

	local label = frame:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
	label:SetPoint("TOP")
	label:SetPoint("BOTTOM")
	label:SetJustifyH("CENTER")

	local labelbg = frame:CreateTexture(nil, "BACKGROUND")
	labelbg:SetTexture("Interface\\AddOns\\SVUI_!Core\\assets\\textures\\DIALOGBOX-HEADER")
	labelbg:SetPoint("TOPLEFT", label, "TOPLEFT", 0, 0)
	labelbg:SetPoint("BOTTOMRIGHT", label, "BOTTOMRIGHT", 0, -32)

	local widget = {
		label = label,
		frame = frame,
		type  = Type
	}
	for method, func in pairs(methods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
