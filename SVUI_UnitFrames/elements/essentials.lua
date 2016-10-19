--[[
##########################################################
S V U I   By: Failcoder
##########################################################
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
local _G = _G;
--LUA
local unpack        = _G.unpack;
local select        = _G.select;
local assert        = _G.assert;
local type          = _G.type;
local error         = _G.error;
local pcall         = _G.pcall;
local print         = _G.print;
local ipairs        = _G.ipairs;
local pairs         = _G.pairs;
local next          = _G.next;
local rawset        = _G.rawset;
local rawget        = _G.rawget;
local tostring      = _G.tostring;
local tonumber      = _G.tonumber;
local getmetatable  = _G.getmetatable;
local setmetatable  = _G.setmetatable;
--STRING
local string        = _G.string;
local upper         = string.upper;
local format        = string.format;
local find          = string.find;
local match         = string.match;
local gsub          = string.gsub;
--MATH
local math          = _G.math;
local random        = math.random;
local floor         = math.floor;
local ceil         	= math.ceil;
local min 			= math.min;

local CreateFrame           = _G.CreateFrame;
local InCombatLockdown      = _G.InCombatLockdown;
local IsLoggedIn            = _G.IsLoggedIn;
local GameTooltip           = _G.GameTooltip;
local UnitClass             = _G.UnitClass;
local UnitIsPlayer          = _G.UnitIsPlayer;
local UnitReaction          = _G.UnitReaction;
local UnitIsConnected  		= _G.UnitIsConnected;
local UnitIsDeadOrGhost  	= _G.UnitIsDeadOrGhost;
local UnitClassBase  		= _G.UnitClassBase;
local UnitPowerType  		= _G.UnitPowerType;
local UnitPlayerControlled  = _G.UnitPlayerControlled;
local UnitThreatSituation   = _G.UnitThreatSituation;
local UnitAffectingCombat   = _G.UnitAffectingCombat;
local GetThreatStatusColor   = _G.GetThreatStatusColor;
local UnitAlternatePowerInfo  = _G.UnitAlternatePowerInfo;
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
--[[
##########################################################
LOCALS
##########################################################
]]--
local FontMapping = {
	["player"] = "SVUI_Font_Unit",
	["target"] = "SVUI_Font_Unit",
	["targettarget"] = "SVUI_Font_Unit_Small",
	["pet"] = "SVUI_Font_Unit",
	["pettarget"] = "SVUI_Font_Unit_Small",
	["focus"] = "SVUI_Font_Unit",
	["focustarget"] = "SVUI_Font_Unit_Small",
	["boss"] = "SVUI_Font_Unit",
	["arena"] = "SVUI_Font_Unit",
	["party"] = "SVUI_Font_Unit_Small",
	["raid"] = "SVUI_Font_Unit_Small",
	["raidpet"] = "SVUI_Font_Unit_Small",
	["tank"] = "SVUI_Font_Unit_Small",
	["assist"] = "SVUI_Font_Unit_Small",
};
local ThreatMapping = {
	["player"] = true,
	["pet"] = true,
	["focus"] = true,
	["party"] = true,
	["raid"] = true,
	["raidpet"] = true,
	["tank"] = true,
	["assist"] = true,
};

local _hook_ActionPanel_OnSizeChanged = function(self)
	local width,height = self:GetSize()
	local widthScale = min(128, width)
	local heightScale = widthScale * 0.25

	self.special[1]:SetSize(widthScale, heightScale)
	self.special[2]:SetSize(widthScale, heightScale)
	--self.special[3]:SetSize(height * 0.5, height)
end
-- local MISSING_MODEL_FILE = [[Spells\Blackmagic_precast_base.m2]];
-- local MISSING_MODEL_FILE = [[Spells\Crow_baked.m2]];
-- local MISSING_MODEL_FILE = [[Spells\monsterlure01.m2]];
-- local MISSING_MODEL_FILE = [[interface\buttons\talktome_gears.m2]];
-- local MISSING_MODEL_FILE = [[creature\Ghostlyskullpet\ghostlyskullpet.m2]];
-- local MISSING_MODEL_FILE = [[creature\ghost\ghost.m2]];
-- local MISSING_MODEL_FILE = [[Spells\Monk_travelingmist_missile.m2]];
local ELITE_TOP = [[Interface\Addons\SVUI_UnitFrames\assets\Border\ELITE-TOP]];
local ELITE_BOTTOM = [[Interface\Addons\SVUI_UnitFrames\assets\Border\ELITE-BOTTOM]];
local ELITE_RIGHT = [[Interface\Addons\SVUI_UnitFrames\assets\Border\ELITE-RIGHT]];
local STUNNED_ANIM = [[Interface\Addons\SVUI_UnitFrames\assets\UNIT-STUNNED]];
local AGGRO_TEXTURE = [[Interface\AddOns\SVUI_UnitFrames\assets\UNIT-AGGRO]];
local token = {[0] = "MANA", [1] = "RAGE", [2] = "FOCUS", [3] = "ENERGY", [6] = "RUNIC_POWER"}
--[[
##########################################################
ACTIONPANEL
##########################################################
]]--
local UpdateThreat = function(self, event, unit)
	if(not unit or (self.unit ~= unit) or not IsLoggedIn()) then return end
	local threat = self.Threat
	local status = UnitThreatSituation(unit)
	local r, g, b
	if(status and status > 0) then
		r, g, b = GetThreatStatusColor(status)
		threat:SetBackdropBorderColor(r, g, b)
		threat:Show()
	else
		threat:SetBackdropBorderColor(0, 0, 0, 0.5)
		threat:Hide()
	end
end

local UpdatePlayerThreat = function(self, event, unit)
	if(unit ~= "player" or not IsLoggedIn()) then return end
	local threat = self.Threat;
	local aggro = self.Aggro;
	local useAggro = aggro.isEnabled;
	local status = UnitThreatSituation(unit)
	local r, g, b
	if(status and status > 0) then
		r, g, b = GetThreatStatusColor(status)
		threat:SetBackdropBorderColor(r, g, b)
		if(useAggro and (status > 1) and (not aggro:IsShown())) then
			self.Combat:Hide()
			aggro:Show()
		end
		threat:Show()
	else
		threat:SetBackdropBorderColor(0, 0, 0, 0.5)
		if(useAggro and aggro:IsShown()) then
			aggro:Hide()
			if(UnitAffectingCombat('player')) then
				self.Combat:Show()
			end
		end
		threat:Hide()
	end
end

local function CreateThreat(frame, unit)
	if(not frame.ActionPanel) then return; end
	local threat = CreateFrame("Frame", nil, frame.ActionPanel)
    threat:SetPoint("TOPLEFT", frame.ActionPanel, "TOPLEFT", -3, 3)
    threat:SetPoint("BOTTOMRIGHT", frame.ActionPanel, "BOTTOMRIGHT", 3, -3)
    threat:SetBackdrop({
        edgeFile = SV.media.border.shadow,
        edgeSize = 3,
        insets =
        {
            left = 2,
            right = 2,
            top = 2,
            bottom = 2,
        },
    });
    threat:SetBackdropBorderColor(0,0,0,0.5)

	if(unit == "player") then
		local aggro = CreateFrame("Frame", "SVUI_PlayerThreatAlert", frame)
		aggro:SetFrameStrata("HIGH")
		aggro:SetFrameLevel(30)
		aggro:SetSize(40,40)
		aggro:SetPoint("BOTTOMLEFT", frame, "TOPRIGHT", -6, -6)
		aggro.texture = aggro:CreateTexture(nil, "OVERLAY")
		aggro.texture:SetAllPoints(aggro)
		aggro.texture:SetTexture(AGGRO_TEXTURE)
		SV.Animate:Pulse(aggro)
		aggro:SetScript("OnShow", function(this)
			this.anim:Play()
		end);
		aggro:Hide();
		aggro.isEnabled = true;
		frame.Aggro = aggro

		threat.Override = UpdatePlayerThreat
	else
		threat.Override = UpdateThreat
	end

	return threat
end

local function CreateNameText(frame, unitName)
	local db = SV.db.UnitFrames
	if(SV.db.UnitFrames[unitName] and SV.db.UnitFrames[unitName].name) then
		db = SV.db.UnitFrames[unitName].name
	end
	local name = frame:CreateFontString(nil, "OVERLAY")
	name:SetFont(LSM:Fetch("font", db.font), db.fontSize, db.fontOutline)
	name:SetShadowOffset(1.5, -1.5)
	name:SetShadowColor(0, 0, 0, 0.5)
	if unitName == "target" then
		name:SetPoint("RIGHT", frame)
		name:SetJustifyH("RIGHT")
    	name:SetJustifyV("MIDDLE")
	else
		name:SetPoint("CENTER", frame)
		name:SetJustifyH("CENTER")
    	name:SetJustifyV("MIDDLE")
	end
	return name;
end

local function ADDInfoBG(frame)
	local bg = frame.InfoPanel:CreateTexture(nil, "BACKGROUND")
	bg:SetPoint("TOPLEFT", frame.InfoPanel, "TOPLEFT", 0, 1)
	bg:SetPoint("BOTTOMRIGHT", frame.InfoPanel, "BOTTOMRIGHT", 0, 1)
	bg:SetColorTexture(1, 1, 1, 1)
	bg:SetGradientAlpha("VERTICAL", 0, 0, 0, 0, 0, 0, 0, 0.7)
	frame.InfoPanelBG = bg

	local left = frame.InfoPanel:CreateTexture(nil, "BACKGROUND")
	left:SetPoint("TOPLEFT", frame.InfoPanel, "TOPLEFT", 0, -1)
	left:SetPoint("BOTTOMLEFT", frame.InfoPanel, "BOTTOMLEFT", 0, -2)
	left:SetWidth(2)
	left:SetColorTexture(1, 1, 1, 1)
	left:SetGradientAlpha("VERTICAL", 0, 0, 0, 0, 0, 0, 0, 1)
	frame.InfoPanelLeft = left

	local right = frame.InfoPanel:CreateTexture(nil, "BACKGROUND")
	right:SetPoint("TOPRIGHT", frame.InfoPanel, "TOPRIGHT", 0, -1)
	right:SetPoint("BOTTOMRIGHT", frame.InfoPanel, "BOTTOMRIGHT", 0, -2)
	right:SetWidth(2)
	right:SetColorTexture(1, 1, 1, 1)
	right:SetGradientAlpha("VERTICAL", 0, 0, 0, 0, 0, 0, 0, 1)
	frame.InfoPanelRight = right
end

function MOD:SetActionPanel(frame, unit, noHealthText, noPowerText, noMiscText)
	if(frame.ActionPanel) then return; end
	frame:SetStyle("Frame", "ActionPanel")
	frame.ActionPanel = frame.Panel
	local baseSize = SV.media.shared.font.unitprimary.size / 0.48;
	if(unit and (unit == "target" or unit == "player")) then
		local info = CreateFrame("Frame", nil, frame)
		info:SetFrameStrata("BACKGROUND")
		info:SetFrameLevel(0)
		info:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, 1)
		info:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", 0, 1)
		info:SetHeight(baseSize)

		frame.TextGrip = CreateFrame("Frame", nil, info)
		frame.TextGrip:SetFrameStrata("LOW")
		frame.TextGrip:SetFrameLevel(20)
		frame.TextGrip:SetAllPoints(info)

		frame.InfoPanel = info;
		ADDInfoBG(frame)

		if(unit == "target") then
			frame.ActionPanel:SetFrameLevel(1)
			if(SV.db.UnitFrames.themed) then
				frame.ActionPanel.special = CreateFrame("Frame", nil, frame.ActionPanel)
				frame.ActionPanel.special:SetAllPoints(frame)
				frame.ActionPanel.special:SetFrameStrata("BACKGROUND")
				frame.ActionPanel.special:SetFrameLevel(0)
				frame.ActionPanel.special[1] = frame.ActionPanel.special:CreateTexture(nil, "OVERLAY", nil, 1)
				frame.ActionPanel.special[1]:SetPoint("BOTTOMRIGHT", frame.ActionPanel.special, "TOPRIGHT", 0, 0)
				frame.ActionPanel.special[1]:SetWidth(frame.ActionPanel:GetWidth())
				frame.ActionPanel.special[1]:SetHeight(frame.ActionPanel:GetWidth() * 0.25)
				frame.ActionPanel.special[1]:SetTexture(ELITE_TOP)
				frame.ActionPanel.special[1]:SetVertexColor(1, 0.75, 0)
				frame.ActionPanel.special[1]:SetBlendMode("BLEND")
				frame.ActionPanel.special[2] = frame.ActionPanel.special:CreateTexture(nil, "OVERLAY", nil, 1)
				frame.ActionPanel.special[2]:SetPoint("TOPRIGHT", frame.ActionPanel.special, "BOTTOMRIGHT", 0, 0)
				frame.ActionPanel.special[2]:SetWidth(frame.ActionPanel:GetWidth())
				frame.ActionPanel.special[2]:SetHeight(frame.ActionPanel:GetWidth() * 0.25)
				frame.ActionPanel.special[2]:SetTexture(ELITE_BOTTOM)
				frame.ActionPanel.special[2]:SetVertexColor(1, 0.75, 0)
				frame.ActionPanel.special[2]:SetBlendMode("BLEND")
				-- frame.ActionPanel.special[3] = frame.ActionPanel.special:CreateTexture(nil, "OVERLAY", nil, 1)
				-- frame.ActionPanel.special[3]:SetPoint("LEFT", frame.ActionPanel.special, "RIGHT", 0, 0)
				-- frame.ActionPanel.special[3]:SetHeight(frame.ActionPanel:GetHeight())
				-- frame.ActionPanel.special[3]:SetWidth(frame.ActionPanel:GetHeight() * 0.5)
				-- frame.ActionPanel.special[3]:SetTexture(ELITE_RIGHT)
				-- frame.ActionPanel.special[3]:SetVertexColor(1, 0.75, 0)
				-- frame.ActionPanel.special[3]:SetBlendMode("BLEND")
				frame.ActionPanel.special:SetAlpha(0.7)
				frame.ActionPanel.special:Hide()

				frame.ActionPanel:SetScript("OnSizeChanged", _hook_ActionPanel_OnSizeChanged)
			end

			frame.ActionPanel.class = CreateFrame("Frame", nil, frame.TextGrip)
			frame.ActionPanel.class:SetSize(18, 18)
			frame.ActionPanel.class:SetPoint("TOPLEFT", frame.ActionPanel, "TOPLEFT", 2, -2)
			frame.ActionPanel.class:SetStyle("Frame", "Default", true, 2, 0, 0)

			frame.ActionPanel.class.texture = frame.ActionPanel.class.Panel:CreateTexture(nil, "BORDER")
			frame.ActionPanel.class.texture:SetAllPoints(frame.ActionPanel.class.Panel)
			frame.ActionPanel.class.texture:SetTexture([[Interface\Glues\CharacterCreate\UI-CharacterCreate-Classes]])

			local border1 = frame.ActionPanel.class:CreateTexture(nil, "OVERLAY")
			border1:SetColorTexture(0, 0, 0)
			border1:SetPoint("TOPLEFT")
			border1:SetPoint("TOPRIGHT")
			border1:SetHeight(2)

			local border2 = frame.ActionPanel.class:CreateTexture(nil, "OVERLAY")
			border2:SetColorTexture(0, 0, 0)
			border2:SetPoint("BOTTOMLEFT")
			border2:SetPoint("BOTTOMRIGHT")
			border2:SetHeight(2)

			local border3 = frame.ActionPanel.class:CreateTexture(nil, "OVERLAY")
			border3:SetColorTexture(0, 0, 0)
			border3:SetPoint("TOPRIGHT")
			border3:SetPoint("BOTTOMRIGHT")
			border3:SetWidth(2)

			local border4 = frame.ActionPanel.class:CreateTexture(nil, "OVERLAY")
			border4:SetColorTexture(0, 0, 0)
			border4:SetPoint("TOPLEFT")
			border4:SetPoint("BOTTOMLEFT")
			border4:SetWidth(2)
		else
			frame.LossOfControl = CreateFrame("Frame", nil, frame.TextGrip)
			frame.LossOfControl:SetAllPoints(frame)
			frame.LossOfControl:SetFrameStrata("DIALOG")
			frame.LossOfControl:SetFrameLevel(99)

			local stunned = frame.LossOfControl:CreateTexture(nil, "OVERLAY", nil, 1)
			stunned:SetPoint("CENTER", frame, "CENTER", 0, 0)
			stunned:SetSize(96, 96)
			stunned:SetTexture(STUNNED_ANIM)
			stunned:SetBlendMode("ADD")
			SV.Animate:Sprite4(stunned, 0.12, false, true)
			frame.LossOfControl.stunned = stunned

			frame.LossOfControl:SetParent(LossOfControlFrame)
		end
	elseif(unit and (unit == 'pet' or unit == 'targettarget')) then
		local info = CreateFrame("Frame", nil, frame)
		info:SetFrameStrata("BACKGROUND")
		info:SetFrameLevel(0)
		info:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, 1)
		info:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", 0, 1)
		info:SetHeight(baseSize)

		frame.InfoPanel = info;
		ADDInfoBG(frame)

		frame.TextGrip = CreateFrame("Frame", nil, info)
		-- frame.TextGrip:SetFrameStrata("LOW")
		frame.TextGrip:SetFrameLevel(20)
		frame.TextGrip:SetAllPoints(info)
	else
		local info = CreateFrame("Frame", nil, frame)
		info:SetFrameLevel(20)
		info:SetAllPoints(frame)
		frame.TextGrip = CreateFrame("Frame", nil, info)
		--frame.TextGrip:SetFrameStrata("LOW")
		frame.TextGrip:SetAllPoints(info)
	end

	frame.TextGrip.Name = CreateNameText(frame.TextGrip, unit)

	local reverse = unit and (unit == "target" or unit == "focus" or unit == "boss" or unit == "arena") or false;
	local offset, direction
	local fontgroup = FontMapping[unit]
	if(not noHealthText) then
		frame.TextGrip.Health = frame.TextGrip:CreateFontString(nil, "OVERLAY")
		frame.TextGrip.Health:SetFontObject(_G[fontgroup])
		offset = reverse and 2 or -2;
		direction = reverse and "LEFT" or "RIGHT";
		frame.TextGrip.Health:SetPoint(direction, frame.TextGrip, direction, offset, 0)
	end

	if(not noPowerText) then
		frame.TextGrip.Power = frame.TextGrip:CreateFontString(nil, "OVERLAY")
		frame.TextGrip.Power:SetFontObject(_G[fontgroup])
		offset = reverse and -2 or 2;
		direction = reverse and "RIGHT" or "LEFT";
		frame.TextGrip.Power:SetPoint(direction, frame.TextGrip, direction, offset, 0)
	end

	if(not noMiscText) then
		frame.TextGrip.Misc = frame.TextGrip:CreateFontString(nil, "OVERLAY")
		frame.TextGrip.Misc:SetFontObject(_G[fontgroup])
		frame.TextGrip.Misc:SetPoint("CENTER", frame, "CENTER", 0, 0)
	end

	frame.StatusPanel = CreateFrame("Frame", nil, frame)
	frame.StatusPanel:EnableMouse(false)

	if(unit and (unit == "player" or unit == "pet" or unit == "target" or unit == "targettarget" or unit == "focus" or unit == "focustarget")) then
		frame.StatusPanel:SetAllPoints(frame)
		frame.StatusPanel.media = {
			[[Interface\Addons\SVUI_UnitFrames\assets\TARGET-DC]],
			[[Interface\Addons\SVUI_UnitFrames\assets\TARGET-DEAD]],
			[[Interface\Addons\SVUI_UnitFrames\assets\TARGET-TAPPED]]
		}
	else
		frame.StatusPanel:SetSize(50, 50)
		frame.StatusPanel:SetPoint("CENTER", frame, "CENTER", 0, 0)
		frame.StatusPanel.media = {
			[[Interface\Addons\SVUI_UnitFrames\assets\UNIT-DC]],
			[[Interface\Addons\SVUI_UnitFrames\assets\UNIT-DEAD]],
			[[Interface\Addons\SVUI_UnitFrames\assets\UNIT-TAPPED]]
		}
	end

	frame.StatusPanel:SetFrameStrata("LOW")
	frame.StatusPanel:SetFrameLevel(32)
	frame.StatusPanel.texture = frame.StatusPanel:CreateTexture(nil, "OVERLAY")
	frame.StatusPanel.texture:SetAllPoints()
	if(ThreatMapping[unit]) then
		frame.Threat = CreateThreat(frame, unit)
	end
end

function MOD:UpdateStatusMedia(frame)
	if(not frame.StatusPanel) then return end
	local width,height = frame.ActionPanel:GetSize()
	frame.StatusPanel:ClearAllPoints()
	if((height > (width * 0.5)) or (width < 75)) then
		frame.StatusPanel:SetSize(height * 1.25, height * 1.25)
		frame.StatusPanel:SetPoint("CENTER", frame.ActionPanel, "CENTER", 0, 0)
		frame.StatusPanel.media = {
			[[Interface\Addons\SVUI_UnitFrames\assets\UNIT-DC]],
			[[Interface\Addons\SVUI_UnitFrames\assets\UNIT-DEAD]],
			[[Interface\Addons\SVUI_UnitFrames\assets\UNIT-TAPPED]]
		}
	else
		frame.StatusPanel:SetAllPoints(frame)
		frame.StatusPanel.media = {
			[[Interface\Addons\SVUI_UnitFrames\assets\TARGET-DC]],
			[[Interface\Addons\SVUI_UnitFrames\assets\TARGET-DEAD]],
			[[Interface\Addons\SVUI_UnitFrames\assets\TARGET-TAPPED]]
		}
	end
	frame.StatusPanel.texture:ClearAllPoints()
	frame.StatusPanel.texture:SetAllPoints()
end
--[[
##########################################################
HEALTH ANIMATIONS
##########################################################
]]--
local Anim_OnUpdate = function(self)
	local parent = self.parent
	local coord = self._coords;
	parent:SetTexCoord(coord[1],coord[2],coord[3],coord[4])
end

local Anim_OnPlay = function(self)
	local parent = self.parent
	parent:SetAlpha(1)
	if not parent:IsShown() then
		parent:Show()
	end
end

local Anim_OnStop = function(self)
	local parent = self.parent
	parent:SetAlpha(0)
	if parent:IsShown() then
		parent:Hide()
	end
end

local function SetNewAnimation(frame, animType, parent)
	local anim = frame:CreateAnimation(animType)
	anim.parent = parent
	return anim
end

local function SetAnim(frame, parent)
	local speed = 0.08
	frame.anim = frame:CreateAnimationGroup("Sprite")
	frame.anim.parent = parent;
	frame.anim:SetScript("OnPlay", Anim_OnPlay)
	frame.anim:SetScript("OnFinished", Anim_OnStop)
	frame.anim:SetScript("OnStop", Anim_OnStop)

	frame.anim[1] = SetNewAnimation(frame.anim, "Translation", frame)
	frame.anim[1]:SetOrder(1)
	frame.anim[1]:SetDuration(speed)
	frame.anim[1]._coords = {0,0.5,0,0.25}
	frame.anim[1]:SetScript("OnUpdate", Anim_OnUpdate)

	frame.anim[2] = SetNewAnimation(frame.anim, "Translation", frame)
	frame.anim[2]:SetOrder(2)
	frame.anim[2]:SetDuration(speed)
	frame.anim[2]._coords = {0.5,1,0,0.25}
	frame.anim[2]:SetScript("OnUpdate", Anim_OnUpdate)

	frame.anim[3] = SetNewAnimation(frame.anim, "Translation", frame)
	frame.anim[3]:SetOrder(3)
	frame.anim[3]:SetDuration(speed)
	frame.anim[3]._coords = {0,0.5,0.25,0.5}
	frame.anim[3]:SetScript("OnUpdate", Anim_OnUpdate)

	frame.anim[4] = SetNewAnimation(frame.anim, "Translation", frame)
	frame.anim[4]:SetOrder(4)
	frame.anim[4]:SetDuration(speed)
	frame.anim[4]._coords = {0.5,1,0.25,0.5}
	frame.anim[4]:SetScript("OnUpdate", Anim_OnUpdate)

	frame.anim[5] = SetNewAnimation(frame.anim, "Translation", frame)
	frame.anim[5]:SetOrder(5)
	frame.anim[5]:SetDuration(speed)
	frame.anim[5]._coords = {0,0.5,0.5,0.75}
	frame.anim[5]:SetScript("OnUpdate", Anim_OnUpdate)

	frame.anim[6] = SetNewAnimation(frame.anim, "Translation", frame)
	frame.anim[6]:SetOrder(6)
	frame.anim[6]:SetDuration(speed)
	frame.anim[6]._coords = {0.5,1,0.5,0.75}
	frame.anim[6]:SetScript("OnUpdate", Anim_OnUpdate)

	frame.anim[7] = SetNewAnimation(frame.anim, "Translation", frame)
	frame.anim[7]:SetOrder(7)
	frame.anim[7]:SetDuration(speed)
	frame.anim[7]._coords = {0,0.5,0.75,1}
	frame.anim[7]:SetScript("OnUpdate", Anim_OnUpdate)

	frame.anim[8] = SetNewAnimation(frame.anim, "Translation", frame)
	frame.anim[8]:SetOrder(8)
	frame.anim[8]:SetDuration(speed)
	frame.anim[8]._coords = {0.5,1,0.75,1}
	frame.anim[8]:SetScript("OnUpdate", Anim_OnUpdate)

	frame.anim:SetLooping("REPEAT")
end
--[[
##########################################################
HEALTH
##########################################################
]]--
local function CreateAbsorbBar(parent, unit)
	local absorbBar = CreateFrame("StatusBar", nil, parent)
	absorbBar:SetFrameStrata("LOW")
	absorbBar:SetFrameLevel(3)
	absorbBar:SetStatusBarTexture(SV.media.statusbar.default);
	absorbBar:SetMinMaxValues(0, 100)
	absorbBar:SetAllPoints(parent)
	absorbBar:SetScript("OnUpdate", function(self)
		if unit then
			local hpMax = UnitHealthMax(unit)
			local currentHP = UnitHealth(unit)
			local absorb = UnitGetTotalAbsorbs(unit)
			local effectiveHP = absorb + currentHP

			if effectiveHP > hpMax then effectiveHP = hpMax end
			self:SetMinMaxValues(0, hpMax)
			self:SetValue(effectiveHP)
		end
	end)
	return absorbBar
end

local OverlayHealthUpdate = function(health, unit, min, max)
	local disconnected = not UnitIsConnected(unit)
	health:SetMinMaxValues(-max, 0)
	health:SetValue(disconnected and 0 or -min)
	local invisible = ((min == max) or UnitIsDeadOrGhost(unit) or disconnected);
	if invisible then health.lowAlerted = false end

	if health.fillInverted then
		health:SetReverseFill(true)
	end
	health.percent = invisible and 100 or ((min / max) * 100)
	health.disconnected = disconnected

	local bg = health.bg;
	local mu = 0;
	if(max ~= 0) then
		mu = (min / max)
	end

	if(invisible or not health.overlayAnimation) then
		health.animation[1].anim:Stop()
		health.animation[1]:SetAlpha(0)
	end

	if(invisible) then
		health:SetStatusBarColor(0.6,0.4,1,0.5)
		health.animation[1]:SetVertexColor(0.8,0.3,1,0.4)
	elseif(health.colorOverlay) then
		local t = oUF_SVUI.colors.health
		health:SetStatusBarColor(t[1], t[2], t[3], 0.9)
	else
		health:SetStatusBarColor(1-(0.65 * mu), 0.15 * mu, 0, 0.85)
		health.animation[1]:SetVertexColor(1, 0.1 * mu, 0, 0.5)
	end

	if(health.overlayAnimation and not invisible) then
		if(mu <= 0.25) then
			health.animation[1]:SetAlpha(1)
			health.animation[1].anim:Play()
		else
			health.animation[1].anim:Stop()
			health.animation[1]:SetAlpha(0)
		end
	end
end

local RefreshHealthBar = function(self, overlay)
	local db = SV.db.UnitFrames[self.unit]
	local absorbBarEnabled = false

	if db and db.health.absorbsBar then
		absorbBarEnabled = true
	end

	if(overlay) then
		self.Health.bg:SetVertexColor(0, 0, 0, 0)
		self.Health.PreUpdate = OverlayHealthUpdate;
	else
		self.Health.bg:SetVertexColor(0.4, 0.1, 0.1, 0.8)
		self.Health.PreUpdate = nil;
	end

	if absorbBarEnabled then
		local absorbBar
			if self.Health.absorbBar then
				absorbBar = self.Health.absorbBar
			else
				absorbBar = CreateAbsorbBar(self.Health, self.unit)
			end

		self.Health.bg:SetParent(absorbBar)
		absorbBar:Show()
	else
		self.Health.bg:SetParent(self.Health)
		if self.Health.absorbBar then
			self.Health.absorbBar:Hide()
		end
	end
end

function MOD:CreateHealthBar(frame, hasbg)
	local db = SV.db.UnitFrames[frame.unit]
	local enableAbsorbsBar = false

	if db and db.health.absorbsBar then
		enableAbsorbsBar = true
	end



	local healthBar = CreateFrame("StatusBar", nil, frame)
	healthBar:SetFrameStrata("LOW")
	healthBar:SetFrameLevel(4)
	healthBar:SetStatusBarTexture(SV.media.statusbar.default);

	if enableAbsorbsBar then
		local absorbBar = CreateAbsorbBar(healthBar, frame.unit)
		healthBar.absorbBar = absorbBar
	end

	if hasbg then
		if not enableAbsorbsBar then
			healthBar.bg = healthBar:CreateTexture(nil, "BORDER")
		else
			healthBar.bg = healthBar.absorbBar:CreateTexture(nil, "BORDER")
		end
		healthBar.bg:SetAllPoints()
		healthBar.bg:SetTexture(SV.media.statusbar.gradient)
		healthBar.bg:SetVertexColor(0.4, 0.1, 0.1)
		healthBar.bg.multiplier = 0.25
	end

	local flasher = CreateFrame("Frame", nil, frame)
	flasher:SetFrameLevel(3)
	flasher:SetAllPoints(healthBar)

	flasher[1] = flasher:CreateTexture(nil, "OVERLAY", nil, 1)
	flasher[1]:SetTexture([[Interface\Addons\SVUI_UnitFrames\assets\UNIT-HEALTH-ANIMATION]])
	flasher[1]:SetTexCoord(0, 0.5, 0, 0.25)
	flasher[1]:SetVertexColor(1, 0.3, 0.1, 0.5)
	flasher[1]:SetBlendMode("ADD")
	flasher[1]:SetAllPoints(flasher)
	SetAnim(flasher[1], flasher)
	flasher:Hide()

	healthBar.animation = flasher
	healthBar.noupdate = false;
	healthBar.fillInverted = false;
	healthBar.gridMode = false;
	healthBar.colorTapping = true;
	healthBar.colorDisconnected = true;

	frame.RefreshHealthBar = RefreshHealthBar

	return healthBar
end
--[[
##########################################################
POWER
##########################################################
]]--
local PostUpdateAltPower = function(self, min, current, max)
	local remaining = floor(current  /  max  *  100)
	local parent = self:GetParent()
	if remaining < 35 then
		self:SetStatusBarColor(0, 1, 0)
	elseif remaining < 70 then
		self:SetStatusBarColor(1, 1, 0)
	else
		self:SetStatusBarColor(1, 0, 0)
	end
	local unit = parent.unit;
	if(unit == "player" and self.text) then
		local apInfo = select(10, UnitAlternatePowerInfo(unit))
		if remaining > 0 then
			self.text:SetText(apInfo..": "..format("%d%%", remaining))
		else
			self.text:SetText(apInfo..": 0%")
		end
	elseif(unit and unit:find("boss%d") and self.text) then
		self.text:SetTextColor(self:GetStatusBarColor())
		if not parent.TextGrip.Power:GetText() or parent.TextGrip.Power:GetText() == "" then
			self.text:SetPoint("BOTTOMRIGHT", parent.Health, "BOTTOMRIGHT")
		else
			self.text:SetPoint("RIGHT", parent.TextGrip.Power, "LEFT", 2, 0)
		end
		if remaining > 0 then
			self.text:SetText("|cffD7BEA5[|r"..format("%d%%", remaining).."|cffD7BEA5]|r")
		else
			self.text:SetText(nil)
		end
	end
end

function MOD:CreatePowerBar(frame)
	local power = CreateFrame("StatusBar", nil, frame)
	power:SetStatusBarTexture(SV.media.statusbar.default)
	power:SetFrameStrata("LOW")
	power:SetFrameLevel(6)
	power:SetStyle("Frame", "Bar")
	power.bg = power:CreateTexture(nil, "BORDER")
	power.bg:SetAllPoints()
	power.bg:SetTexture(SV.media.statusbar.gradient)
	power.bg:SetVertexColor(0.4, 0.1, 0.1)
	power.bg.multiplier = 0.25

	power.colorDisconnected = false;
	power.colorTapping = false;
	power.PostUpdate = MOD.PostUpdatePower;
	return power
end

function MOD:CreateAltPowerBar(frame)
	local altPower = CreateFrame("StatusBar", nil, frame)
	altPower:SetStatusBarTexture(SV.media.statusbar.default)
	altPower:SetStyle("Frame", "Bar")
	altPower:GetStatusBarTexture():SetHorizTile(false)
	altPower:SetFrameStrata("LOW")
	altPower:SetFrameLevel(8)
	altPower.text = altPower:CreateFontString(nil, "OVERLAY")
	altPower.text:SetPoint("CENTER")
	altPower.text:SetJustifyH("CENTER")
	altPower.text:SetFontObject(SVUI_Font_Unit)
	altPower.PostUpdate = PostUpdateAltPower;
	return altPower
end

function MOD:PostUpdatePower(unit, value, max)
	local db = SV.db.UnitFrames[unit]
	local powerType, powerToken = UnitPowerType(unit)
	local parent = self:GetParent()
	if parent.isForced then
		value = random(1, max)
		powerType = random(0, 4)
		self:SetValue(value)
	end
	local colors = oUF_SVUI.colors.power[powerToken]
	local mult = self.bg.multiplier or 1;
	local isPlayer = UnitPlayerControlled(unit)
	if isPlayer and self.colorClass then
		local _, class = UnitClassBase(unit);
		colors = oUF_SVUI["colors"].class[class]
	elseif(not isPlayer and (powerType and powerType == 1 and value == 0)) then
		colors = nil
	end
	if(not colors) then
		self:Hide()
	else
		if(not self:IsShown()) then self:Show() end
		self:SetStatusBarColor(colors[1], colors[2], colors[3])
		self.bg:SetVertexColor(colors[1] * mult, colors[2] * mult, colors[3] * mult)
	end
end
--[[
##########################################################
PORTRAIT
##########################################################
]]--
function MOD:CreatePortrait(frame,smallUnit,isPlayer)
	-- 3D Portrait
	local portrait3D = CreateFrame("PlayerModel",nil,frame)
	portrait3D:SetFrameStrata("LOW")
	portrait3D:SetFrameLevel(2)

	if smallUnit then
		portrait3D:SetStyle("Frame", "UnitSmall")
	else
		portrait3D:SetStyle("Frame", "UnitLarge")
	end

	portrait3D.Outline = CreateFrame("Frame", nil, portrait3D)
	portrait3D.Outline:WrapPoints(portrait3D)
	portrait3D.Outline:SetStyle("Frame", "ActionPanel")

	portrait3D.UserRotation = 0;
	portrait3D.UserCamDistance = 1.3;

	-- 2D Portrait
	local portrait2Danchor = CreateFrame('Frame', nil, frame)
	portrait2Danchor:SetFrameStrata("LOW")
	portrait2Danchor:SetFrameLevel(2)

	portrait2Danchor:SetStyle("Frame")
	portrait2Danchor:SetPanelColor("darkest")

	portrait2Danchor.Outline = CreateFrame("Frame", nil, portrait2Danchor)
	portrait2Danchor.Outline:WrapPoints(portrait2Danchor)
	portrait2Danchor.Outline:SetStyle("Frame", "ActionPanel")

	local portrait2D = portrait2Danchor:CreateTexture(nil,'OVERLAY')
	portrait2D:SetAllPoints()
	portrait2D:SetTexCoord(0.15,0.85,0.15,0.85)
	portrait2D:SetBlendMode("ADD")

	-- Assign To Frame
	frame.PortraitModel = portrait3D;
	frame.PortraitTexture = portrait2D;
end
