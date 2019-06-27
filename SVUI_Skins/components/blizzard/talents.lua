--[[
##############################################################################
S V U I   By: Failcoder
##############################################################################
--]]
--[[ GLOBALS ]]--
local _G = _G;
local unpack  	= _G.unpack;
local select  	= _G.select;
local ipairs  	= _G.ipairs;
local pairs   	= _G.pairs;
local type 		= _G.type;
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
local SpecButtonList = {
	"PlayerTalentFrameActivateButton",
	"PlayerTalentFrameSpecializationLearnButton",
	"PlayerTalentFrameTalentsLearnButton",
	"PlayerTalentFramePetSpecializationLearnButton"
};

local scrollButtons = {
    "PlayerTalentFrameSpecializationSpellScrollFrameScrollBarScrollUpButton.Normal",
    "PlayerTalentFrameSpecializationSpellScrollFrameScrollBarScrollUpButton.Pushed",
    "PlayerTalentFrameSpecializationSpellScrollFrameScrollBarScrollUpButton.Disabled",
    "PlayerTalentFrameSpecializationSpellScrollFrameScrollBarScrollUpButton.Highlight",
    "PlayerTalentFrameSpecializationSpellScrollFrameScrollBarScrollDownButton.Normal",
    "PlayerTalentFrameSpecializationSpellScrollFrameScrollBarScrollDownButton.Pushed",
    "PlayerTalentFrameSpecializationSpellScrollFrameScrollBarScrollDownButton.Disabled",
    "PlayerTalentFrameSpecializationSpellScrollFrameScrollBarScrollDownButton.Highlight",
    "PlayerTalentFramePetSpecializationSpellScrollFrameScrollBarScrollUpButton.Normal",
    "PlayerTalentFramePetSpecializationSpellScrollFrameScrollBarScrollUpButton.Pushed",
    "PlayerTalentFramePetSpecializationSpellScrollFrameScrollBarScrollUpButton.Disabled",
    "PlayerTalentFramePetSpecializationSpellScrollFrameScrollBarScrollUpButton.Highlight",
    "PlayerTalentFramePetSpecializationSpellScrollFrameScrollBarScrollDownButton.Normal",
    "PlayerTalentFramePetSpecializationSpellScrollFrameScrollBarScrollDownButton.Pushed",
    "PlayerTalentFramePetSpecializationSpellScrollFrameScrollBarScrollDownButton.Disabled",
    "PlayerTalentFramePetSpecializationSpellScrollFrameScrollBarScrollDownButton.Highlight"
};

local function Tab_OnEnter(this)
	this.backdrop:SetPanelColor("highlight")
	this.backdrop:SetBackdropBorderColor(0.1, 0.8, 0.8, 1)
	--this:SetBackdropBorderColor(0.1, 0.8, 0.8, 0.5)
end

local function Tab_OnLeave(this)
	this.backdrop:SetPanelColor("dark")
	this.backdrop:SetBackdropBorderColor(0,0,0,0.5)
	--this:SetBackdropBorderColor(0,0,0,1)
end

local function ChangeTabHelper(this)
	this:RemoveTextures()
	local nTex = this:GetNormalTexture()
	if(nTex) then
		nTex:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
		nTex:InsetPoints()
	end

	this.pushed = true;

	this.backdrop = CreateFrame("Frame", nil, this)
	this.backdrop:WrapPoints(this,1,1)
	this.backdrop:SetFrameLevel(0)
	this.backdrop:SetBackdrop(SV.media.backdrop.glow);
    this.backdrop:SetBackdropColor(0,0,0,1)
	this.backdrop:SetBackdropBorderColor(0,0,0,0.5)
	this:SetScript("OnEnter", Tab_OnEnter)
	this:SetScript("OnLeave", Tab_OnLeave)
end

local function StyleGlyphHolder(holder, offset)
    if((not holder) or holder.styled) then return end
    offset = offset or 1;

    holder:RemoveTextures()

    local outer = holder:CreateTexture(nil, "OVERLAY")
    outer:WrapPoints(holder, offset, offset)
    outer:SetTexture(SV.media.button.round)
    outer:SetGradient(unpack(SV.media.gradient.class))

    local hover = holder:CreateTexture(nil, "HIGHLIGHT")
    hover:WrapPoints(holder, offset, offset)
    hover:SetTexture(SV.media.button.round)
    hover:SetGradient(unpack(SV.media.gradient.yellow))
    holder.hover = hover

    if holder.SetDisabledTexture then
        local disabled = holder:CreateTexture(nil, "BORDER")
        disabled:WrapPoints(holder, offset, offset)
        disabled:SetTexture(SV.media.button.round)
        disabled:SetGradient(unpack(SV.media.gradient.default))
        holder:SetDisabledTexture(disabled)
    end

    local cd = holder:GetName() and _G[holder:GetName().."Cooldown"]
    if cd then
        cd:ClearAllPoints()
        cd:InsetPoints(holder)
    end

    holder.styled = true
end
--[[
##########################################################
TALENTFRAME MODR
##########################################################
]]--
local function TalentFrameStyle()
	--print("TalentFrameStyle")
	if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.talent ~= true then return end

	SV.API:Set("Window", PlayerTalentFrame)
	PlayerTalentFrameInset:RemoveTextures()
	PlayerTalentFrameTalents:RemoveTextures()
	PlayerTalentFrameSpecialization:DisableDrawLayer("BORDER")
	PlayerTalentFramePetSpecialization:DisableDrawLayer("BORDER")
	PlayerTalentFrameSpecializationTutorialButton:Die()
	PlayerTalentFrameTalentsTutorialButton:Die()
	PlayerTalentFramePetSpecializationTutorialButton:Die()

	PlayerTalentFrame.Panel:SetPoint("BOTTOMRIGHT", PlayerTalentFrame, "BOTTOMRIGHT", 0, -5)

	PlayerTalentFrameTalents:SetStyle("!_Frame", "Inset")
	PlayerTalentFrameSpecialization:SetStyle("Frame", "Inset")
	PlayerTalentFrameSpecialization.Panel:SetPoint("TOPLEFT", PlayerTalentFrameSpecialization, "TOPLEFT", 0, 4)
	PlayerTalentFrameSpecialization.Panel:SetPoint("BOTTOMRIGHT", PlayerTalentFrameSpecialization, "BOTTOMRIGHT", 3, 0)
	PlayerTalentFramePetSpecialization:SetStyle("!_Frame", "Inset")
	PlayerTalentFramePetSpecialization.Panel:SetPoint("TOPLEFT", PlayerTalentFramePetSpecialization, "TOPLEFT", 0, 4)
	PlayerTalentFramePetSpecialization.Panel:SetPoint("BOTTOMRIGHT", PlayerTalentFramePetSpecialization, "BOTTOMRIGHT", 3, 0)

	SV.API:Set("CloseButton", PlayerTalentFrameCloseButton)
	--SV.API:Set("ScrollBar", PlayerTalentFrameSpecializationSpellScrollFrame)
	--SV.API:Set("ScrollBar", PlayerTalentFramePetSpecializationSpellScrollFrame)
	for i = 1, 4 do
		SV.API:Set("Tab", _G["PlayerTalentFrameTab"..i])
	end
    
    PlayerTalentFrameSpecializationSpellScrollFrameScrollBar:RemoveTextures(true);
    PlayerTalentFramePetSpecializationSpellScrollFrameScrollBar:RemoveTextures(true);
    PlayerTalentFrameSpecializationSpellScrollFrameScrollBarScrollUpButton:RemoveTextures(true);
    PlayerTalentFrameSpecializationSpellScrollFrameScrollBarScrollDownButton:RemoveTextures(true);
    PlayerTalentFramePetSpecializationSpellScrollFrameScrollBarScrollUpButton:RemoveTextures(true);
    PlayerTalentFramePetSpecializationSpellScrollFrameScrollBarScrollDownButton:RemoveTextures(true);
    PlayerTalentFrameSpecializationSpellScrollFrameScrollBarScrollDownButton.Normal:SetTexture(""); -- must be manually removed
    for _,name in pairs(scrollButtons) do
        local remove = _G[name];
        if (remove) then
            remove:SetTexture("");
            remove:Hide();
        end
    end
    
	for _,name in pairs(SpecButtonList) do
		local button = _G[name];
		if(button) then
			button:RemoveTextures()
			button:SetStyle("Button")
			local initialAnchor, anchorParent, relativeAnchor, xPosition, yPosition = button:GetPoint()
			button:SetPoint(initialAnchor, anchorParent, relativeAnchor, xPosition, -28)
		end
	end

	local maxTiers = 7

	for i = 1, 7 do
		local gName = ("PlayerTalentFrameTalentsTalentRow%d"):format(i)
		local rowFrame = _G[gName]
		if(rowFrame) then
			local bgFrame = _G[("%sBg"):format(gName)]
			if(bgFrame) then bgFrame:Hide() end

			rowFrame:DisableDrawLayer("BORDER")
			rowFrame:RemoveTextures()
			rowFrame.TopLine:SetPoint("TOP", 0, 4)
			rowFrame.BottomLine:SetPoint("BOTTOM", 0, -4)

			for z = 1, 3 do
				local talentItem = _G[("%sTalent%d"):format(gName, z)]
				if(talentItem) then
					SV.API:Set("ItemButton", talentItem)
				end
			end
		end
	end

	hooksecurefunc("TalentFrame_Update", function()
		for i = 1, 7 do
			local gName = ("PlayerTalentFrameTalentsTalentRow%d"):format(i)

			for z = 1, 3 do
				local talentItem = _G[("%sTalent%d"):format(gName, z)]
				if(talentItem) then
					if talentItem.knownSelection:IsShown() then
						talentItem:SetBackdropBorderColor(0, 1, 0)
					else
			 			talentItem:SetBackdropBorderColor(0, 0, 0)
					end
				end
			end
		end
	end)
end
--[[
##########################################################
MOD LOADING
##########################################################
]]--
MOD:SaveBlizzardStyle("Blizzard_TalentUI", TalentFrameStyle)

local function GlyphStyle()
	assert(GlyphFrame, "GlyphFrame Not Loaded")

	GlyphFrame:RemoveTextures()
	GlyphFrame:SetStyle("!_Frame", "Premium")

	if(GlyphFrameSideInset) then GlyphFrameSideInset:RemoveTextures() end
	if(GlyphFrameHeader1) then GlyphFrameHeader1:RemoveTextures() end
	if(GlyphFrameHeader2) then GlyphFrameHeader2:RemoveTextures() end
	if(GlyphFrameScrollFrame) then GlyphFrameScrollFrameScrollBar:SetStyle("Frame", "Inset", false, 3, 2, 2) end
	if(GlyphFrameSearchBox) then GlyphFrameSearchBox:SetStyle("Editbox") end

	if(GlyphFrameClearInfoFrame and GlyphFrameClearInfoFrame.icon) then
		GlyphFrameClearInfoFrame:RemoveTextures()
		local w,h = GlyphFrameClearInfoFrame:GetSize()
		GlyphFrameClearInfoFrame:SetSize((w - 2),(h - 2))
		GlyphFrameClearInfoFrame:SetPoint("TOPLEFT", GlyphFrame, "BOTTOMLEFT", 6, -10)
		GlyphFrameClearInfoFrame.icon:SetSize((w - 2),(h - 2))
		GlyphFrameClearInfoFrame.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	end

	SV.API:Set("DropDown", GlyphFrameFilterDropDown, 212)
	SV.API:Set("ScrollBar", GlyphFrameScrollFrame, 5)

	for i = 1, 10 do
		local button = _G["GlyphFrameScrollFrameButton"..i]
		if(button) then
			SV.API:Set("ItemButton", button)
			local icon = _G["GlyphFrameScrollFrameButton"..i.."Icon"]
			if(icon) then
				icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
			end
		end
	end

	for i = 1, 6 do
		local glyphHolder = _G["GlyphFrameGlyph"..i]
		if glyphHolder then
			if(i % 2 == 0) then
				StyleGlyphHolder(glyphHolder, 4)
			else
				StyleGlyphHolder(glyphHolder, 1)
			end
		end
	end
end

MOD:SaveBlizzardStyle("Blizzard_GlyphUI", GlyphStyle)
