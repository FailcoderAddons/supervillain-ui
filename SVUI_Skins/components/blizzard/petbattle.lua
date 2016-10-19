--[[
##############################################################################
S V U I   By: Failcoder
##############################################################################
--]]
--[[ GLOBALS ]]--
local _G = _G;
local unpack  = _G.unpack;
local select  = _G.select;
local ipairs  = _G.ipairs;
local pairs   = _G.pairs;
local hooksecurefunc = _G.hooksecurefunc;
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
local PBAB_WIDTH = 382;
local PBAB_HEIGHT = 72;
local PetBattleActionBar = CreateFrame("Frame", "SVUI_PetBattleActionBar", UIParent)
local ITEM_QUALITY_COLORS = _G.ITEM_QUALITY_COLORS;

local function PetBattleButtonHelper(frame)
	frame:SetStyle("Frame", "Icon", 2, 2, 2)
	frame:SetNormalTexture("")
	frame:SetPushedTexture("")
	frame.Icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
	frame.Icon:SetDrawLayer('BACKGROUND')
	frame.Icon:SetParent(frame.Panel)
	if(frame.SelectedHighlight) then frame.SelectedHighlight:SetAlpha(0) end
	if(frame.checked) then frame.checked = true end
	if(frame.pushed) then frame.pushed:InsetPoints(frame.Panel) end
	if(frame.hover) then frame.hover:InsetPoints(frame.Panel) end
	frame:SetFrameStrata('LOW')
end

local _hook_UpdateSpeedIndicators = function()
	local frame = _G.PetBattleFrame;

	if not frame.ActiveAlly.SpeedIcon:IsShown() and not frame.ActiveEnemy.SpeedIcon:IsShown() then
		frame.ActiveAlly.FirstAttack:Hide()
		frame.ActiveEnemy.FirstAttack:Hide()
		return 
	end

	frame.ActiveAlly.FirstAttack:Show()

	if frame.ActiveAlly.SpeedIcon:IsShown() then
		frame.ActiveAlly.FirstAttack:SetVertexColor(0, 1, 0, 1)
	else
		frame.ActiveAlly.FirstAttack:SetVertexColor(.8, 0, .3, 1)
	end

	frame.ActiveEnemy.FirstAttack:Show()

	if frame.ActiveEnemy.SpeedIcon:IsShown() then
		frame.ActiveEnemy.FirstAttack:SetVertexColor(0, 1, 0, 1)
	else
		frame.ActiveEnemy.FirstAttack:SetVertexColor(.8, 0, .3, 1)
	end 
end

local _hook_UpdatePetType = function(self)
	if self.PetType then
		local C_PetBattles = _G.C_PetBattles;
		local pettype = C_PetBattles.GetPetType(self.petOwner, self.petIndex)
		if self.PetTypeFrame then
			local text = _G.PET_TYPE_SUFFIX[pettype]
			self.PetTypeFrame.text:SetText(text)
		end 
	end 
end

local _hook_AuraHolderUpdate = function(self)
    if ( not self.petOwner or not self.petIndex ) then
        self:Hide();
        return;
    end
 
    local nextFrame = 1;
    local C_PetBattles = _G.C_PetBattles;
    for i=1, C_PetBattles.GetNumAuras(self.petOwner, self.petIndex) do
        local auraID, instanceID, turnsRemaining, isBuff = C_PetBattles.GetAuraInfo(self.petOwner, self.petIndex, i);
        if ( (isBuff and self.displayBuffs) or (not isBuff and self.displayDebuffs) ) then
			local frame = self.frames[nextFrame]
			frame.DebuffBorder:Hide()
			if not frame.isStyled then
				frame:SetStyle("Icon", 2, -8,-2)
				frame.Icon:InsetPoints(frame.Panel, 2, 2)
				frame.Icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
				frame.isStyled = true
			end 
			if isBuff then
				frame:SetBackdropBorderColor(0, 1, 0)
			else
				frame:SetBackdropBorderColor(1, 0, 0)
			end 
			frame.Duration:SetFont(SV.media.font.number, 16, "OUTLINE")
			frame.Duration:ClearAllPoints()
			frame.Duration:SetPoint("BOTTOMLEFT", frame.Icon, "BOTTOMLEFT", 4, 4)
			if turnsRemaining > 0 then
				frame.Duration:SetText(turnsRemaining)
			end 
			nextFrame = nextFrame + 1 
		end 
	end
end

local _hook_WeatherFrameUpdate = function(self)
	local LE_BATTLE_PET_WEATHER = _G.LE_BATTLE_PET_WEATHER;
	local PET_BATTLE_PAD_INDEX = _G.PET_BATTLE_PAD_INDEX;
	local C_PetBattles = _G.C_PetBattles;
	local auraID = C_PetBattles.GetAuraInfo(LE_BATTLE_PET_WEATHER, PET_BATTLE_PAD_INDEX, 1)
	if auraID then
		self.Icon:Hide()
		self.Name:Hide()
		self.DurationShadow:Hide()
		self.Label:Hide()
		self.Duration:SetPoint("CENTER", self, 0, 8)
		self:ClearAllPoints()
		self:SetPoint("TOP", SV.Screen, 0, -15)
	end 
end

local _hook_UpdateDisplay = function(self)
	self.Icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
	--Update the pet rarity border
    if (self.IconBackdrop) then
    	local petOwner = self.petOwner;
		local petIndex = self.petIndex;
        local rarity = _G.C_PetBattles.GetBreedQuality(petOwner, petIndex);
        if (_G.ENABLE_COLORBLIND_MODE ~= "1") then
        	self.IconBackdrop:SetBackdropColor(ITEM_QUALITY_COLORS[rarity-1].r, ITEM_QUALITY_COLORS[rarity-1].g, ITEM_QUALITY_COLORS[rarity-1].b);
            self.IconBackdrop:SetBackdropBorderColor(ITEM_QUALITY_COLORS[rarity-1].r, ITEM_QUALITY_COLORS[rarity-1].g, ITEM_QUALITY_COLORS[rarity-1].b);
        end
    end
end

local _hook_AbilityTooltipShow = function()
	SV:AnchorToCursor(PetBattlePrimaryAbilityTooltip)
end

local _hook_SkipButtonSetPoint = function(self, arg1, _, arg2, arg3, arg4)
	if (arg1 ~= "BOTTOMLEFT" or arg2 ~= "TOPLEFT" or arg3 ~= 2 or arg4 ~= 2) then
		self:ClearAllPoints()
		self:SetPoint("BOTTOMLEFT", PetBattleActionBar.Panel, "TOPLEFT", 2, 2)
	end 
end

local _hook_PetSelectionFrameShow = function()
	local frame = _G.PetBattleFrame;
	if(frame and frame.BottomFrame) then
		frame.BottomFrame.PetSelectionFrame:ClearAllPoints()
		frame.BottomFrame.PetSelectionFrame:SetPoint("BOTTOM", frame.BottomFrame.xpBar, "TOP", 0, 8)
	end
end

local _hook_UpdateActionBarLayout = function(self)
	local list = _G.NUM_BATTLE_PET_ABILITIES;
	for i = 1, list do 
		local actionButton = self.BottomFrame.abilityButtons[i]
		PetBattleButtonHelper(actionButton)
		actionButton:SetParent(PetBattleActionBar)
		actionButton:ClearAllPoints()
		if i == 1 then
			actionButton:SetPoint("BOTTOMLEFT", 10, 10)
		else
			local lastActionButton = self.BottomFrame.abilityButtons[i - 1]
			actionButton:SetPoint("LEFT", lastActionButton, "RIGHT", 10, 0)
		end 
	end
	self.BottomFrame.SwitchPetButton:SetParent(PetBattleActionBar)
	self.BottomFrame.SwitchPetButton:ClearAllPoints()
	self.BottomFrame.SwitchPetButton:SetPoint("LEFT", self.BottomFrame.abilityButtons[3], "RIGHT", 10, 0)
	PetBattleButtonHelper(self.BottomFrame.SwitchPetButton)
	self.BottomFrame.CatchButton:SetParent(PetBattleActionBar)
	self.BottomFrame.CatchButton:ClearAllPoints()
	self.BottomFrame.CatchButton:SetPoint("LEFT", self.BottomFrame.SwitchPetButton, "RIGHT", 10, 0)
	PetBattleButtonHelper(self.BottomFrame.CatchButton)
	self.BottomFrame.ForfeitButton:SetParent(PetBattleActionBar)
	self.BottomFrame.ForfeitButton:ClearAllPoints()
	self.BottomFrame.ForfeitButton:SetPoint("LEFT", self.BottomFrame.CatchButton, "RIGHT", 10, 0)
	PetBattleButtonHelper(self.BottomFrame.ForfeitButton)
end
--[[ 
########################################################## 
PETBATTLE MODR
##########################################################
]]--
local function PetBattleStyle()
	if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.petbattleui ~= true then
		return 
	end

	local PetBattleFrame = _G.PetBattleFrame;
	local BottomFrame = PetBattleFrame.BottomFrame;
	local ActiveFramesList = { PetBattleFrame.ActiveAlly, PetBattleFrame.ActiveEnemy }
	local StandardFramesList = { PetBattleFrame.Ally2, PetBattleFrame.Ally3, PetBattleFrame.Enemy2, PetBattleFrame.Enemy3 }

	SV.API:Set("CloseButton", FloatingBattlePetTooltip.CloseButton)
	PetBattleFrame:RemoveTextures()
	
	for i, frame in pairs(ActiveFramesList) do 
		if(not frame.isStyled) then
			frame.Border:SetAlpha(0)
			frame.Border2:SetAlpha(0)
			frame.healthBarWidth = 300;

			frame.IconBackdrop = CreateFrame("Frame", nil, frame)
			frame.IconBackdrop:SetFrameLevel(0)
			frame.IconBackdrop:SetAllPoints(frame.Icon)
			frame.IconBackdrop:SetStyle("Icon", 2, 2, 2);

			frame.BorderFlash:Die()
			frame.HealthBarBG:Die()
			frame.HealthBarFrame:Die()
			frame.HealthBarBackdrop = CreateFrame("Frame", nil, frame)
			frame.HealthBarBackdrop:SetFrameLevel(frame:GetFrameLevel()-1)
			frame.HealthBarBackdrop:SetStyle("Frame", "Bar")
			frame.HealthBarBackdrop:SetWidth(frame.healthBarWidth + 4)
			frame.ActualHealthBar:SetTexture(SV.media.statusbar.default)
			frame.PetTypeFrame = CreateFrame("Frame", nil, frame)
			frame.PetTypeFrame:SetSize(100, 23)
			frame.PetTypeFrame.text = frame.PetTypeFrame:CreateFontString(nil, 'OVERLAY')
			frame.PetTypeFrame.text:SetFont(SV.media.font.default, 12, "OUTLINE")
			frame.PetTypeFrame.text:SetText("")
			frame.ActualHealthBar:ClearAllPoints()
			frame.Name:SetFontObject(SystemFont_Shadow_Outline_Huge2)
			frame.Name:ClearAllPoints()
			frame.FirstAttack = frame:CreateTexture(nil, "ARTWORK")
			frame.FirstAttack:SetSize(30, 30)
			frame.FirstAttack:SetTexture("Interface\\PetBattles\\PetBattle-StatIcons")
			if i == 1 then 
				frame.HealthBarBackdrop:SetPoint('TOPLEFT', frame.ActualHealthBar, 'TOPLEFT', -1, 1)
				frame.HealthBarBackdrop:SetPoint('BOTTOMLEFT', frame.ActualHealthBar, 'BOTTOMLEFT', -1, -1)
				frame.ActualHealthBar:SetVertexColor(171/255, 214/255, 116/255)
				PetBattleFrame.Ally2.iconPoint = frame.IconBackdrop;
				PetBattleFrame.Ally3.iconPoint = frame.IconBackdrop;
				frame.ActualHealthBar:SetPoint('BOTTOMLEFT', frame.Icon, 'BOTTOMRIGHT', 10, 0)
				frame.Name:SetPoint('BOTTOMLEFT', frame.ActualHealthBar, 'TOPLEFT', 0, 8)
				frame.PetTypeFrame:SetPoint("BOTTOMRIGHT", frame.HealthBarBackdrop, "TOPRIGHT", 0, 4)
				frame.PetTypeFrame.text:SetPoint("RIGHT")
				frame.FirstAttack:SetPoint("LEFT", frame.HealthBarBackdrop, "RIGHT", 5, 0)
				frame.FirstAttack:SetTexCoord(frame.SpeedIcon:GetTexCoord())
				frame.FirstAttack:SetVertexColor(.1, .1, .1, 1)
			else
				frame.HealthBarBackdrop:SetPoint('TOPRIGHT', frame.ActualHealthBar, 'TOPRIGHT', 1, 1)
				frame.HealthBarBackdrop:SetPoint('BOTTOMRIGHT', frame.ActualHealthBar, 'BOTTOMRIGHT', 1, -1)
				frame.ActualHealthBar:SetVertexColor(196/255, 30/255, 60/255)
				PetBattleFrame.Enemy2.iconPoint = frame.IconBackdrop;
				PetBattleFrame.Enemy3.iconPoint = frame.IconBackdrop;
				frame.ActualHealthBar:SetPoint('BOTTOMRIGHT', frame.Icon, 'BOTTOMLEFT', -10, 0)
				frame.Name:SetPoint('BOTTOMRIGHT', frame.ActualHealthBar, 'TOPRIGHT', 0, 8)
				frame.PetTypeFrame:SetPoint("BOTTOMLEFT", frame.HealthBarBackdrop, "TOPLEFT", 2, 4)
				frame.PetTypeFrame.text:SetPoint("LEFT")
				frame.FirstAttack:SetPoint("RIGHT", frame.HealthBarBackdrop, "LEFT", -5, 0)
				frame.FirstAttack:SetTexCoord(.5, 0, .5, 1)
				frame.FirstAttack:SetVertexColor(.1, .1, .1, 1)
			end 
			frame.HealthText:ClearAllPoints()
			frame.HealthText:SetPoint('CENTER', frame.HealthBarBackdrop, 'CENTER')
			frame.PetType:SetFrameLevel(frame.PetTypeFrame:GetFrameLevel()+2)
			frame.PetType:ClearAllPoints()
			frame.PetType:SetAllPoints(frame.PetTypeFrame)
			frame.PetType:SetAlpha(0)
			frame.LevelUnderlay:SetAlpha(0)
			frame.Level:SetFontObject(NumberFont_Outline_Huge)
			frame.Level:ClearAllPoints()
			frame.Level:SetPoint('BOTTOMLEFT', frame.Icon, 'BOTTOMLEFT', -2, -2)
			if frame.SpeedIcon then 
				frame.SpeedIcon:ClearAllPoints()
				frame.SpeedIcon:SetPoint("CENTER")
				frame.SpeedIcon:SetAlpha(0)
				frame.SpeedUnderlay:SetAlpha(0)
			end
			frame.isStyled = true
		end 
	end 

	for _, frame in pairs(StandardFramesList) do
		if(not frame.hasTempBG) then
			frame.BorderAlive:SetAlpha(0)
			frame.HealthBarBG:SetAlpha(0)
			frame.HealthDivider:SetAlpha(0)
			frame:SetSize(40, 40)

			frame.IconBackdrop = CreateFrame("Frame", nil, frame)
			frame.IconBackdrop:SetFrameLevel(0)
			frame.IconBackdrop:SetAllPoints(frame)
			frame.IconBackdrop:SetStyle("Icon", 2, 2, 2);

			frame:ClearAllPoints()
			frame.healthBarWidth = 40;
			frame.ActualHealthBar:ClearAllPoints()
			frame.ActualHealthBar:SetPoint("TOPLEFT", frame.IconBackdrop, 'BOTTOMLEFT', 0, -6)
			frame.ActualHealthBar:SetTexture(SV.media.statusbar.default)
			frame.HealthBarBackdrop = CreateFrame("Frame", nil, frame)
			frame.HealthBarBackdrop:SetFrameLevel(frame:GetFrameLevel()-1)
			frame.HealthBarBackdrop:SetStyle("Frame", "Bar")
			frame.HealthBarBackdrop:SetWidth(frame.healthBarWidth + 4)
			frame.HealthBarBackdrop:SetPoint('TOPLEFT', frame.ActualHealthBar, 'TOPLEFT', -1, 1)
			frame.HealthBarBackdrop:SetPoint('BOTTOMLEFT', frame.ActualHealthBar, 'BOTTOMLEFT', -1, -1)
			frame.hasTempBG = true
		end
	end 

	PetBattleActionBar:SetParent(PetBattleFrame)
	PetBattleActionBar:SetSize(PBAB_WIDTH, PBAB_HEIGHT)
	PetBattleActionBar:EnableMouse(true)
	PetBattleActionBar:SetFrameLevel(0)
	PetBattleActionBar:SetFrameStrata('BACKGROUND')
	PetBattleActionBar:SetStyle("Frame", "Bar")

	local SVUI_DockBottomCenter = _G.SVUI_DockBottomCenter;
	if(SVUI_DockBottomCenter) then
		PetBattleActionBar:SetPoint("BOTTOM", SVUI_DockBottomCenter, "TOP", 0, 4)
	else
		PetBattleActionBar:SetPoint("BOTTOM", SV.Screen, "BOTTOM", 0, 4)
	end

	PetBattleFrame.TopVersusText:ClearAllPoints()
	PetBattleFrame.TopVersusText:SetPoint("TOP", PetBattleFrame, "TOP", 0, -42)

	PetBattleFrame.Ally2:SetPoint("TOPRIGHT", PetBattleFrame.Ally2.iconPoint, "TOPLEFT", -6, -2)
	PetBattleFrame.Ally3:SetPoint('TOPRIGHT', PetBattleFrame.Ally2, 'TOPLEFT', -8, 0)
	PetBattleFrame.Enemy2:SetPoint("TOPLEFT", PetBattleFrame.Enemy2.iconPoint, "TOPRIGHT", 6, -2)
	PetBattleFrame.Enemy3:SetPoint('TOPLEFT', PetBattleFrame.Enemy2, 'TOPRIGHT', 8, 0)

	BottomFrame:RemoveTextures()
	BottomFrame.TurnTimer:RemoveTextures()

	BottomFrame.TurnTimer.SkipButton:ClearAllPoints()
	BottomFrame.TurnTimer.SkipButton:SetParent(PetBattleActionBar)
	BottomFrame.TurnTimer.SkipButton:SetSize((PBAB_WIDTH * 0.2) - 4, 18)
	BottomFrame.TurnTimer.SkipButton:SetPoint("BOTTOMLEFT", PetBattleActionBar.Panel, "TOPLEFT", 2, 2)
	BottomFrame.TurnTimer.SkipButton:SetStyle("Button")

	BottomFrame.TurnTimer:SetSize(BottomFrame.TurnTimer.SkipButton:GetWidth(), BottomFrame.TurnTimer.SkipButton:GetHeight())
	BottomFrame.TurnTimer:ClearAllPoints()
	BottomFrame.TurnTimer:SetPoint("TOP", SV.Screen, "TOP", 0, -140)
	BottomFrame.TurnTimer.TimerText:SetPoint("CENTER")

	BottomFrame.FlowFrame:RemoveTextures()
	BottomFrame.MicroButtonFrame:Die()
	BottomFrame.Delimiter:RemoveTextures()

	BottomFrame.xpBar:ClearAllPoints()
	BottomFrame.xpBar:RemoveTextures()
	BottomFrame.xpBar:SetParent(PetBattleActionBar)
	BottomFrame.xpBar:SetSize((PBAB_WIDTH * 0.8) - 4, 16)
	BottomFrame.xpBar:SetStatusBarTexture(SV.media.statusbar.default)
	BottomFrame.xpBar:SetStyle("Frame", "Bar")
	BottomFrame.xpBar:SetPoint("BOTTOMRIGHT", PetBattleActionBar.Panel, "TOPRIGHT", -3, 3)
	BottomFrame.xpBar:SetScript("OnShow", function(self)
		self:RemoveTextures()
		self:SetStatusBarTexture(SV.media.statusbar.default)
	end)

	for i = 1, 3 do 
		local pet = BottomFrame.PetSelectionFrame["Pet"..i]
		pet.HealthBarBG:SetAlpha(0)
		pet.HealthDivider:SetAlpha(0)
		pet.ActualHealthBar:SetAlpha(0)
		pet.SelectedTexture:SetAlpha(0)
		pet.MouseoverHighlight:SetAlpha(0)
		pet.Framing:SetAlpha(0)
		pet.Icon:SetAlpha(0)
		pet.Name:SetAlpha(0)
		pet.DeadOverlay:SetAlpha(0)
		pet.Level:SetAlpha(0)
		pet.HealthText:SetAlpha(0)
	end 

	local PetBattleQueueReadyFrame = _G.PetBattleQueueReadyFrame;

	PetBattleQueueReadyFrame:RemoveTextures()
	PetBattleQueueReadyFrame:SetStyle("Frame", 'Transparent')
	PetBattleQueueReadyFrame.AcceptButton:SetStyle("Button")
	PetBattleQueueReadyFrame.DeclineButton:SetStyle("Button")
	PetBattleQueueReadyFrame.Art:SetTexture([[Interface\PetBattles\PetBattlesQueue]])
	
	--[[ TOO MANY GOD DAMN HOOKS ]]--
	hooksecurefunc("PetBattleFrame_UpdateSpeedIndicators", _hook_UpdateSpeedIndicators)
	hooksecurefunc("PetBattleUnitFrame_UpdatePetType", _hook_UpdatePetType)
	hooksecurefunc("PetBattleAuraHolder_Update", _hook_AuraHolderUpdate)
	hooksecurefunc("PetBattleWeatherFrame_Update", _hook_WeatherFrameUpdate)
	hooksecurefunc("PetBattleUnitFrame_UpdateDisplay", _hook_UpdateDisplay)
	hooksecurefunc("PetBattleAbilityTooltip_Show", _hook_AbilityTooltipShow)
	hooksecurefunc(BottomFrame.TurnTimer.SkipButton, "SetPoint", _hook_SkipButtonSetPoint)
	hooksecurefunc("PetBattlePetSelectionFrame_Show", _hook_PetSelectionFrameShow)
	hooksecurefunc("PetBattleFrame_UpdateActionBarLayout", _hook_UpdateActionBarLayout)

	SV.Tooltip:ReLoad()
end 
--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveBlizzardStyle('Blizzard_PetBattleUI', PetBattleStyle)