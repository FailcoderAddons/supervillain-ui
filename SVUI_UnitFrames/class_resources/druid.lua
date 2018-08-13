--[[
##########################################################
S V U I   By: Failcoder
##########################################################
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local unpack    = _G.unpack;
local select    = _G.select;
local pairs     = _G.pairs;
local ipairs    = _G.ipairs;
local type      = _G.type;
local error     = _G.error;
local pcall     = _G.pcall;
local tostring  = _G.tostring;
local tonumber  = _G.tonumber;
local assert 	= _G.assert;
local math 		= _G.math;
--[[ MATH METHODS ]]--
local random,floor = math.random, math.floor;
--[[
##########################################################
GET ADDON DATA
##########################################################
]]--
local SV = _G['SVUI']
local L = SV.L;
local LSM = _G.LibStub("LibSharedMedia-3.0")
local MOD = SV.UnitFrames

if(not MOD) then return end

local oUF_SVUI = MOD.oUF
assert(oUF_SVUI, "SVUI UnitFrames: unable to locate oUF.")
if(SV.class ~= "DRUID") then return end
--[[
##########################################################
DRUID ALT MANA
##########################################################
]]--
local TRACKER_FONT = [[Interface\AddOns\SVUI_!Core\assets\fonts\Combo.ttf]];
local cpointColor = {
    [1]={0.69,0.31,0.31},
    [2]={0.69,0.31,0.31},
    [3]={0.65,0.63,0.35},
    [4]={0.65,0.63,0.35},
    [5]={0.33,0.59,0.33}
};

local comboTextures = {
    [1]=[[Interface\Addons\SVUI_UnitFrames\assets\Class\DRUID-CLAW-UP]],
    [2]=[[Interface\Addons\SVUI_UnitFrames\assets\Class\DRUID-CLAW-DOWN]],
    [3]=[[Interface\Addons\SVUI_UnitFrames\assets\Class\DRUID-BITE]],
};



local ShowPoint = function(self)
    self:SetAlpha(1)
end

local HidePoint = function(self)
    self.Icon:SetTexture(comboTextures[random(1,2)])
    self:SetAlpha(0)
end

local UpdateAltPower = function(self, unit, arg1, arg2)
    local value = self:GetParent().TextGrip.Power;
    if(arg1 ~= arg2) then
        local color = oUF_SVUI.colors.power.MANA
        color = SV:HexColor(color[1],color[2],color[3])
        local altValue = floor(arg1 / arg2 * 100)
        local altStr = ""
        if(value:GetText()) then
            if(select(4, value:GetPoint()) < 0) then
                altStr = ("|cff%s%d%%|r |cffD7BEA5- |r"):format(color, altValue)
            else
                altStr = ("|cffD7BEA5-|r|cff%s%d%%|r"):format(color, altValue)
            end
        else
            altStr = ("|cff%s%d%%|r"):format(color, altValue)
        end
        self.Text:SetText(altStr)
    else
        self.Text:SetText()
    end
end
--[[
##########################################################
POSITIONING
##########################################################
]]--
local OnMove = function()
    SV.db.UnitFrames.player.classbar.detachFromFrame = true
end

local Reposition = function(self)
    local db = SV.db.UnitFrames.player

    local bar = self.Druidness;
    if not bar or not db then print("Error") return end
    --self.Druidness.Chicken.isEnabled = db.classbar.enableChicken;
    self.Druidness.Mana.isEnabled = db.classbar.enableAltMana;
    self.Druidness.Cat.isEnabled = db.classbar.enableCat;
    --local chicken = bar.Chicken;
    local height = db.classbar.height
    local offset = (height - 10)
    local adjustedBar = (height * 1.5)
    local adjustedAnim = (height * 1.25)
    local scaled = (height * 0.8)
    local width = db.width * 0.4;

    bar.Holder:SetSize(width, height)
    if(not db.classbar.detachFromFrame) then
        SV:ResetAnchors(L["Classbar"])
    end
    local holderUpdate = bar.Holder:GetScript('OnSizeChanged')
    if holderUpdate then
        holderUpdate(bar.Holder)
    end

    bar:ClearAllPoints()
    bar:SetAllPoints(bar.Holder)

    local max = UnitPowerMax("player", Enum.PowerType.ComboPoints);
    local cat = bar.Cat;
    local size = 30

    cat:ClearAllPoints()
    cat:SetAllPoints(bar)
    if(db.classbar.altComboPoints) then
        for i = 1, max do
            cat[i]:SetAlpha(0)
            cat[i]:ClearAllPoints()
            --cat[i].Icon:ClearAllPoints()
            cat[i]:SetSize(size, size)
           --cat[i].Icon:SetAllPoints(cat[i])
            if i == max then
                cat[i].Icon:SetTexture(comboTextures[3])
            else
                cat[i].Icon:SetTexture(comboTextures[random(1,2)])
            end
            if i==1 then
                cat[i]:SetPoint("LEFT", cat)
            else
                cat[i]:SetPoint("LEFT", cat[i - 1], "RIGHT", -2, 0)
            end
        end
        cat.PointShow = nil;
        cat.PointHide = HidePoint;
    else
        for i = 1, max do
            if cat[i] then
                cat[i]:SetAlpha(1)
                cat[i]:ClearAllPoints()
                cat[i]:SetSize(size, size)
                --cat[i].Icon:ClearAllPoints()
                --cat[i].Icon:SetAllPoints(cat[i])
                if i == max then
                    cat[i].Icon:SetTexture(comboTextures[3])
                else
                    cat[i].Icon:SetTexture(comboTextures[random(1,2)])
                end
                if i==1 then
                    cat[i]:SetPoint("LEFT", cat)
                else
                    cat[i]:SetPoint("LEFT", cat[i - 1], "RIGHT", -2, 0)
                end
            end
        end
        cat.PointShow = ShowPoint;
        cat.PointHide = nil;
    end
end

--[[
##########################################################
DRUID ECLIPSE BAR
##########################################################

local EclipseDirection = function(self)
    local status = GetEclipseDirection()

    if(self.inEclipse) then
        if(status == "sun") then
            --self.Text:SetText("<")
            --self.Text:SetTextColor(0.2, 1, 1, 0.5)
            if(not self.Moon[1].anim:IsPlaying()) then
                self.Sun[1]:Hide()
                self.Sun[1].anim:Finish()
                self.Sun.FX:Hide()
                self.Moon[1]:Show()
                self.Moon[1].anim:Play()
                self.Moon.FX:Show()
                self.Moon.FX:UpdateEffect()
            end
        elseif(status == "moon") then
            --self.Text:SetText(">")
            --self.Text:SetTextColor(1, 0.5, 0, 0.5)
            if(not self.Sun[1].anim:IsPlaying()) then
                self.Moon[1]:Hide()
                self.Moon[1].anim:Finish()
                self.Moon.FX:Hide()
                self.Sun[1]:Show()
                self.Sun[1].anim:Play()
                self.Sun.FX:Show()
                self.Sun.FX:UpdateEffect()
            end
        else
            --self.Text:SetText("<")
            --self.Text:SetTextColor(0.2, 1, 1, 0.5)
            self.Sun[1]:Hide()
            self.Sun[1].anim:Finish()
            self.Sun.FX:Hide()
            self.Moon[1]:Hide()
            self.Moon[1].anim:Finish()
            self.Moon.FX:Hide()
        end
    else
        if(status == "sun") then
            --self.Text:SetText("<")
            --self.Text:SetTextColor(0.2, 1, 1, 0.5)
            if(not self.Moon[1].anim:IsPlaying()) then
                self.Sun[1]:Hide()
                self.Sun[1].anim:Finish()
                self.Sun.FX:Hide()
                self.Moon[1]:Show()
                self.Moon[1].anim:Play()
                self.Moon.FX:Show()
                self.Moon.FX:UpdateEffect()
            end
        elseif(status == "moon") then
            --self.Text:SetText(">")
            --self.Text:SetTextColor(1, 0.5, 0, 0.5)
            if(not self.Sun[1].anim:IsPlaying()) then
                self.Moon[1]:Hide()
                self.Moon[1].anim:Finish()
                self.Moon.FX:Hide()
                self.Sun[1]:Show()
                self.Sun[1].anim:Play()
                self.Sun.FX:Show()
                self.Sun.FX:UpdateEffect()
            end
        else
            --self.Text:SetText("<")
            --self.Text:SetTextColor(0.2, 1, 1, 0.5)
            self.Sun[1]:Hide()
            self.Sun[1].anim:Finish()
            self.Sun.FX:Hide()
            self.Moon[1]:Hide()
            self.Moon[1].anim:Finish()
            self.Moon.FX:Hide()
        end
    end
end
]]--


function MOD:CreateClassBar(playerFrame)
    local bar = CreateFrame('Frame', nil, playerFrame)
    bar:SetFrameLevel(playerFrame.TextGrip:GetFrameLevel() + 30)
    bar:SetSize(100,40)

    local cat = CreateFrame('Frame',nil,bar)
    cat:SetAllPoints(bar)
    local max = UnitPowerMax("player", Enum.PowerType.ComboPoints);
    local size = 30;
    for i = 1, max do
        local cpoint = CreateFrame('Frame',nil, cat)
        cpoint:SetSize(size,size)

        local icon = cpoint:CreateTexture(nil,"OVERLAY",nil,1)
        icon:SetSize(size,size)
        icon:SetAllPoints(cpoint)
        icon:SetBlendMode("BLEND")
        if i == max then
           icon:SetTexture(comboTextures[3])
        else
         icon:SetTexture(comboTextures[random(1,2)])
        end
        cpoint.Icon = icon

        cat[i] = cpoint
    end
    cat.PointShow = ShowPoint;
    cat.PointHide = HidePoint;

    local mana = CreateFrame("Frame", nil, playerFrame)
    mana:SetFrameStrata("LOW")
    mana:InsetPoints(basr, 2, 4)
    mana:SetStyle("!_Frame", "Default")
    mana:SetFrameLevel(mana:GetFrameLevel() + 1)
    mana.colorPower = true;
    mana.PostUpdatePower = UpdateAltPower;
    mana.ManaBar = CreateFrame("StatusBar", nil, mana)
    mana.ManaBar.noupdate = true;
    mana.ManaBar:SetStatusBarTexture(SV.media.statusbar.glow)
    mana.ManaBar:InsetPoints(mana)
    mana.bg = mana:CreateTexture(nil, "BORDER")
    mana.bg:SetAllPoints(mana.ManaBar)
    mana.bg:SetTexture([[Interface\BUTTONS\WHITE8X8]])
    mana.bg.multiplier = 0.3;
    mana.Text = mana.ManaBar:CreateFontString(nil, "OVERLAY")
    mana.Text:SetAllPoints(mana.ManaBar)
    mana.Text:SetFontObject(SVUI_Font_Unit)

    bar.Cat = cat;
    bar.Cat:SetFrameStrata("HIGH")



    bar.Chicken = chicken;
    bar.Mana = mana;

    local classBarHolder = CreateFrame("Frame", "Player_ClassBar", bar)
    classBarHolder:SetPoint("TOPLEFT", playerFrame, "BOTTOMLEFT", 0, -2)
    bar:SetPoint("TOPLEFT", classBarHolder, "TOPLEFT", 0, 0)
    bar.Holder = classBarHolder
    SV:NewAnchor(bar.Holder, L["Classbar"], OnMove)


    playerFrame.MaxClassPower = 5;
    playerFrame.RefreshClassBar = Reposition;
    playerFrame.Druidness = bar
    return 'Druidness'
end
