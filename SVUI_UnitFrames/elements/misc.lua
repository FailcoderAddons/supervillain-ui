--[[
##############################################################################
S V U I   By: Failcoder
##############################################################################
--]]
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
local floor         = math.floor
local ceil         	= math.ceil
local max         	= math.max

local CreateFrame           = _G.CreateFrame;
local InCombatLockdown      = _G.InCombatLockdown;

local SV = _G['SVUI']
local L = SV.L;
local LSM = _G.LibStub("LibSharedMedia-3.0")
local MOD = SV.UnitFrames

if(not MOD) then return end

local oUF_SVUI = MOD.oUF
assert(oUF_SVUI, "SVUI UnitFrames: unable to locate oUF.")
--[[
##########################################################
LOCAL VARIABLES
##########################################################
]]--
local AFFLICTED_SKIN = [[Interface\AddOns\SVUI_UnitFrames\assets\UNIT-AFFLICTED]];

local ROLE_ICON_DATA = {
	["TANK"] = {0,0.5,0,0.5, 0.5,0.75,0.51,0.75},
	["HEALER"] = {0,0.5,0.5,1, 0.5,0.75,0.76,1},
	["DAMAGER"] = {0.5,1,0,0.5, 0.76,1,0.51,0.75}
}

local function BasicBG(frame)
	frame:SetBackdrop({
    	bgFile = [[Interface\BUTTONS\WHITE8X8]],
		tile = false,
		tileSize = 0,
		edgeFile = [[Interface\BUTTONS\WHITE8X8]],
        edgeSize = 2,
        insets = {
            left = 0,
            right = 0,
            top = 0,
            bottom = 0
        }
    })
    frame:SetBackdropColor(0, 0, 0, 0)
    frame:SetBackdropBorderColor(0, 0, 0)
end
--[[
##########################################################
RAID DEBUFFS / DEBUFF HIGHLIGHT
##########################################################
]]--
function MOD:CreateRaidDebuffs(frame)
	local raidDebuff = CreateFrame("Frame", nil, frame.TextGrip)
	raidDebuff:SetFrameLevel(50)
	raidDebuff:SetStyle("!_Frame", "Icon")
	raidDebuff.icon = raidDebuff:CreateTexture(nil, "OVERLAY")
	raidDebuff.icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
	raidDebuff.icon:InsetPoints(raidDebuff)
	raidDebuff.count = raidDebuff:CreateFontString(nil, "OVERLAY")
	raidDebuff.count:SetFontObject(SVUI_Font_UnitAura)
	raidDebuff.count:SetPoint("BOTTOMRIGHT", 0, 2)
	raidDebuff.count:SetTextColor(1, .9, 0)
	raidDebuff.time = raidDebuff:CreateFontString(nil, "OVERLAY")
	raidDebuff.time:SetFontObject(SVUI_Font_UnitAura)
	raidDebuff.time:SetPoint("CENTER")
	raidDebuff.time:SetTextColor(1, .9, 0)
	if (frame.TextGrip.Name) then
		raidDebuff.nameText = frame.TextGrip.Name
	end
	return raidDebuff
end

function MOD:CreateAfflicted(frame)
	local afflicted = CreateFrame("Frame", nil, frame.TextGrip)
	afflicted:SetFrameLevel(30)
	afflicted:SetPoint("TOPLEFT", frame.Health, "TOPLEFT", -1, 1)
	afflicted:SetPoint("BOTTOMRIGHT", frame.Health, "BOTTOMRIGHT", 1, -1)
	afflicted:SetStyle("!_Frame", "Icon")
	afflicted.Texture = afflicted:CreateTexture(nil, "OVERLAY", nil, 7)
	afflicted.Texture:SetAllPoints(afflicted)
	afflicted.Texture:SetTexture(AFFLICTED_SKIN)
	afflicted.Texture:SetVertexColor(0, 0, 0, 0)
	afflicted.Texture:SetBlendMode("ADD")
	afflicted.ClassFilter = true
	return afflicted
end
--[[
##########################################################
VARIOUS ICONS
##########################################################
]]--
function MOD:CreateResurectionIcon(frame)
	local rez = frame.TextGrip:CreateTexture(nil, "OVERLAY")
	rez:SetPoint("CENTER", frame.TextGrip.Health, "CENTER")
	rez:SetSize(30, 25)
	rez:SetDrawLayer("OVERLAY", 7)
	return rez
end

function MOD:CreateReadyCheckIcon(frame)
	local rdyHolder = CreateFrame("Frame", nil, frame.TextGrip)
	rdyHolder:SetAllPoints(frame)
	local rdy = rdyHolder:CreateTexture(nil, "OVERLAY", nil, 7)
	rdy:SetSize(18, 18)
	rdy:SetPoint("RIGHT", rdyHolder, "RIGHT", 0, 0)
	return rdy
end

function MOD:CreateGladiator(frame)
	local pvp = CreateFrame("Frame", nil, frame)
	pvp:SetFrameLevel(pvp:GetFrameLevel() + 1)

	local trinket = CreateFrame("Frame", nil, pvp)
	BasicBG(trinket)
	trinket.Icon = trinket:CreateTexture(nil, "BORDER")
	trinket.Icon:InsetPoints(trinket, 2, 2)
	trinket.Icon:SetTexture([[Interface\Icons\INV_MISC_QUESTIONMARK]])
	trinket.Icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))

	trinket.Unavailable = trinket:CreateTexture(nil, "OVERLAY")
	trinket.Unavailable:SetAllPoints(trinket)
	trinket.Unavailable:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
	trinket.Unavailable:SetTexture([[Interface\BUTTONS\UI-GroupLoot-Pass-Up]])
	trinket.Unavailable:Hide()

	trinket.CD = CreateFrame("Cooldown", nil, trinket)
	trinket.CD:SetAllPoints(trinket)

	pvp.Trinket = trinket

	local badge = CreateFrame("Frame", nil, pvp)
	BasicBG(badge)
	badge.Icon = badge:CreateTexture(nil, "OVERLAY")
	badge.Icon:InsetPoints(badge, 2, 2)
	badge.Icon:SetTexture([[Interface\Icons\INV_MISC_QUESTIONMARK]])
	badge.Icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))

	pvp.Badge = badge

	return pvp
end

function MOD:CreateFriendshipBar(frame)
	local buddy = CreateFrame("StatusBar", nil, frame.Power)
    buddy:SetAllPoints(frame.Power)
    buddy:SetStatusBarTexture(SV.media.statusbar.default)
    buddy:SetStatusBarColor(1,0,0)
    local bg = buddy:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints(buddy)
	bg:SetColorTexture(0.2,0,0)
	local icon = buddy:CreateTexture(nil, "OVERLAY")
	icon:SetPoint("LEFT", buddy, "LEFT", -11, 0)
	icon:SetSize(22,22)
	icon:SetTexture(MOD.media.buddy)

	return buddy
end
--[[
##########################################################
CONFIGURABLE ICONS
##########################################################
]]--
function MOD:CreateRaidIcon(frame)
	local rIcon = frame.TextGrip:CreateTexture(nil, "OVERLAY", nil, 2)
	rIcon:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
	rIcon:SetSize(18, 18)
	rIcon:SetPoint("CENTER", frame.TextGrip, "TOP", 0, 2)
	return rIcon
end

local UpdateRoleIcon = function(self)
	local key = self.___key
	local db = SV.db.UnitFrames[key]
	if(not db or not db.icons or (db.icons and not db.icons.roleIcon)) then return end
	local lfd = self.LFDRole
	if(not db.icons.roleIcon.enable) then lfd:Hide() return end
	local unitRole = UnitGroupRolesAssigned(self.unit)
	if(self.isForced and unitRole == "NONE") then
		local rng = random(1, 3)
		unitRole = rng == 1 and "TANK" or rng == 2 and "HEALER" or rng == 3 and "DAMAGER"
	end
	if(unitRole ~= "NONE" and (self.isForced or UnitIsConnected(self.unit))) then
		local coords = ROLE_ICON_DATA[unitRole]
		lfd:SetTexture(MOD.media.roles)
		if(lfd:GetHeight() <= 13) then
			lfd:SetTexCoord(coords[5], coords[6], coords[7], coords[8])
		else
			lfd:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
		end
		lfd:Show()
	else
		lfd:Hide()
	end
end

function MOD:CreateRoleIcon(frame)
	local parent = frame.TextGrip or frame;
	local rIconHolder = CreateFrame("Frame", nil, parent)
	rIconHolder:SetAllPoints()
	local rIcon = rIconHolder:CreateTexture(nil, "ARTWORK", nil, 2)
	rIcon:SetSize(14, 14)
	rIcon:SetPoint("BOTTOMRIGHT", rIconHolder, "BOTTOMRIGHT")
	rIcon.Override = UpdateRoleIcon;
	frame:RegisterEvent("UNIT_CONNECTION", UpdateRoleIcon)
	return rIcon
end

function MOD:CreateRaidRoleFrames(frame)
	local parent = frame.TextGrip or frame;
	local raidRoles = CreateFrame("Frame", nil, frame)
	raidRoles:SetSize(24, 12)
	raidRoles:SetPoint("TOPLEFT", frame.ActionPanel, "TOPLEFT", -2, 4)
	raidRoles:SetFrameLevel(parent:GetFrameLevel() + 50)

	frame.Leader = raidRoles:CreateTexture(nil, "OVERLAY")
	frame.Leader:SetSize(12, 12)
	frame.Leader:SetTexture(MOD.media.lml)
	frame.Leader:SetTexCoord(0, 0.5, 0, 0.5)
	frame.Leader:SetVertexColor(1, 0.85, 0)
	frame.Leader:SetPoint("LEFT")

	frame.MasterLooter = raidRoles:CreateTexture(nil, "OVERLAY")
	frame.MasterLooter:SetSize(12, 12)
	frame.MasterLooter:SetTexture(MOD.media.lml)
	frame.MasterLooter:SetTexCoord(0.5, 1, 0, 0.5)
	frame.MasterLooter:SetVertexColor(1, 0.6, 0)
	frame.MasterLooter:SetPoint("RIGHT")

	frame.Leader.PostUpdate = MOD.RaidRoleUpdate;
	frame.MasterLooter.PostUpdate = MOD.RaidRoleUpdate;
	return raidRoles
end

function MOD:RaidRoleUpdate()
	local frame = self:GetParent()
	local leaderIcon = frame.Leader;
	local looterIcon = frame.MasterLooter;
	if not leaderIcon or not looterIcon then return end
		local key = frame.___key;
		local db = SV.db.UnitFrames[key];
		local leaderShown = leaderIcon:IsShown()
		local looterShown = looterIcon:IsShown()
		leaderIcon:ClearAllPoints()
		looterIcon:ClearAllPoints()
		if db and db.icons and db.icons.raidRoleIcons then
			local settings = db.icons.raidRoleIcons
			if leaderShown and settings.position == "TOPLEFT"then
				leaderIcon:SetPoint("LEFT", frame, "LEFT")
				looterIcon:SetPoint("RIGHT", frame, "RIGHT")
			elseif leaderShown and settings.position == "TOPRIGHT" then
				leaderIcon:SetPoint("RIGHT", frame, "RIGHT")
				looterIcon:SetPoint("LEFT", frame, "LEFT")
			elseif looterShown and settings.position == "TOPLEFT" then
				looterIcon:SetPoint("LEFT", frame, "LEFT")
			else
			looterIcon:SetPoint("RIGHT", frame, "RIGHT")
		end
	end
end
--[[
##########################################################
PLAYER ONLY COMPONENTS
##########################################################
]]--
function MOD:CreatePlayerIndicators(frame)
	local resting = CreateFrame("Frame",nil,frame)
	resting:SetFrameStrata("MEDIUM")
	resting:SetFrameLevel(20)
	resting:SetSize(26,26)
	resting:SetPoint("BOTTOMRIGHT", frame.Health, "BOTTOMRIGHT", 0, 0)
	resting.bg = resting:CreateTexture(nil,"OVERLAY",nil,1)
	resting.bg:SetAllPoints(resting)
	resting.bg:SetTexture(MOD.media.playerstate)
	resting.bg:SetTexCoord(0.5,1,0,0.5)

	local combat = CreateFrame("Frame",nil,frame)
	combat:SetFrameStrata("MEDIUM")
	combat:SetFrameLevel(30)
	combat:SetSize(26,26)
	combat:SetPoint("BOTTOMLEFT", frame , "TOPRIGHT", 3, 3)
	combat.bg = combat:CreateTexture(nil,"OVERLAY",nil,5)
	combat.bg:SetAllPoints(combat)
	combat.bg:SetTexture(MOD.media.playerstate)
	combat.bg:SetTexCoord(0,0.5,0,0.5)
	combat.linked = resting
	SV.Animate:Pulse(combat)
	--IsResting()
	combat:SetScript("OnShow", function(this)
		if not this.anim:IsPlaying() then this.anim:Play() end
		if(resting:IsShown()) then
			resting:SetAlpha(0)
		end
	end)
	combat:Hide()
	combat:SetScript("OnHide", function(this)
		if(IsResting()) then
			resting:SetAlpha(1)
		end
	end)

	frame.Resting = resting
	frame.Combat = combat
end

local ExRep_OnEnter = function(self)if self:IsShown() then UIFrameFadeIn(self,.1,0,1) end end
local ExRep_OnLeave = function(self)if self:IsShown() then UIFrameFadeOut(self,.2,1,0) end end

function MOD:CreateExperienceRepBar(frame)
	local db = SV.db.UnitFrames.player;

	if db.playerExpBar then
		local xp = CreateFrame("StatusBar", "PlayerFrameExperienceBar", frame.Power)
		xp:InsetPoints(frame.Power, 0, 0)
		xp:SetStyle("Frame")
		xp:SetStatusBarTexture(SV.media.statusbar.default)
		xp:SetStatusBarColor(0, 0.1, 0.6)
		--xp:SetBackdropColor(1, 1, 1, 0.8)
		xp:SetFrameLevel(xp:GetFrameLevel() + 2)
		xp.Tooltip = true;
		xp.Rested = CreateFrame("StatusBar", nil, xp)
		xp.Rested:SetAllPoints(xp)
		xp.Rested:SetStatusBarTexture(SV.media.statusbar.default)
		xp.Rested:SetStatusBarColor(1, 0, 1, 0.6)
		xp.Value = xp:CreateFontString(nil, "TOOLTIP")
		xp.Value:SetAllPoints(xp)
		xp.Value:SetFontObject(SVUI_Font_Default)
		xp.Value:SetTextColor(0.2, 0.75, 1)
		xp.Value:SetShadowColor(0, 0, 0, 0)
		xp.Value:SetShadowOffset(0, 0)
		frame:Tag(xp.Value, "[curxp] / [maxxp]")
		xp.Rested:SetBackdrop({bgFile = [[Interface\BUTTONS\WHITE8X8]]})
		xp.Rested:SetBackdropColor(unpack(SV.media.color.default))
		xp:SetScript("OnEnter", ExRep_OnEnter)
		xp:SetScript("OnLeave", ExRep_OnLeave)
		xp:SetAlpha(0)
		frame.Experience = xp
	end

	if db.playerRepBar then
		local rep = CreateFrame("StatusBar", "PlayerFrameReputationBar", frame.Power)
		rep:InsetPoints(frame.Power, 0, 0)
		rep:SetStyle("Frame")
		rep:SetStatusBarTexture(SV.media.statusbar.default)
		rep:SetStatusBarColor(0, 0.6, 0)
		--rep:SetBackdropColor(1, 1, 1, 0.8)
		rep:SetFrameLevel(rep:GetFrameLevel() + 2)
		rep.Tooltip = true;
		rep.Value = rep:CreateFontString(nil, "TOOLTIP")
		rep.Value:SetAllPoints(rep)
		rep.Value:SetFontObject(SVUI_Font_Default)
		rep.Value:SetTextColor(0.1, 1, 0.2)
		rep.Value:SetShadowColor(0, 0, 0, 0)
		rep.Value:SetShadowOffset(0, 0)
		frame:Tag(rep.Value, "[standing]: [currep] / [maxrep]")
		rep:SetScript("OnEnter", ExRep_OnEnter)
		rep:SetScript("OnLeave", ExRep_OnLeave)
		rep:SetAlpha(0)
		frame.Reputation = rep
	end
end
--[[
##########################################################
HEAL PREDICTION
##########################################################
]]--
local OverrideUpdate = function(self, event, unit)
	if(self.unit ~= unit) or not unit then return end

	local hp = self.HealPrediction
	hp.parent = self
	local hbar = self.Health;
	local anchor, relative, relative2 = 'TOPLEFT', 'BOTTOMRIGHT', 'BOTTOMLEFT';
	local reversed = true
	hp.reversed = hbar.fillInverted or false
	if(hp.reversed == true) then
		anchor, relative, relative2 = 'TOPRIGHT', 'BOTTOMLEFT', 'BOTTOMRIGHT';
		reversed = false
	end

	local myIncomingHeal = UnitGetIncomingHeals(unit, 'player') or 0
	local allIncomingHeal = UnitGetIncomingHeals(unit) or 0
	local totalAbsorb = UnitGetTotalAbsorbs(unit) or 0
	local myCurrentHealAbsorb = UnitGetTotalHealAbsorbs(unit) or 0
	local health, maxHealth = UnitHealth(unit), UnitHealthMax(unit)

	local overHealAbsorb = false
	if(health < myCurrentHealAbsorb) then
		overHealAbsorb = true
		myCurrentHealAbsorb = health
	end

	if(health - myCurrentHealAbsorb + allIncomingHeal > maxHealth * hp.maxOverflow) then
		allIncomingHeal = maxHealth * hp.maxOverflow - health + myCurrentHealAbsorb
	end

	local otherIncomingHeal = 0
	if(allIncomingHeal < myIncomingHeal) then
		myIncomingHeal = allIncomingHeal
	else
		otherIncomingHeal = allIncomingHeal - myIncomingHeal
	end

	local overAbsorb = false
	if(health - myCurrentHealAbsorb + allIncomingHeal + totalAbsorb >= maxHealth or health + totalAbsorb >= maxHealth) then
		if(totalAbsorb > 0) then
			overAbsorb = true
		end

		if(allIncomingHeal > myCurrentHealAbsorb) then
			totalAbsorb = max(0, maxHealth - (health - myCurrentHealAbsorb + allIncomingHeal))
		else
			totalAbsorb = max(0, maxHealth - health)
		end
	end

	if(myCurrentHealAbsorb > allIncomingHeal) then
		myCurrentHealAbsorb = myCurrentHealAbsorb - allIncomingHeal
	else
		myCurrentHealAbsorb = 0
	end

	local barMin, barMax, barMod = 0, maxHealth, 1;

	local previous = hbar:GetStatusBarTexture()
	if(hp.myBar) then
		hp.myBar:SetMinMaxValues(barMin, barMax)
		if(not hp.otherBar) then
			hp.myBar:SetValue(allIncomingHeal)
		else
			hp.myBar:SetValue(myIncomingHeal)
		end
		hp.myBar:SetPoint(anchor, hbar, anchor, 0, 0)
		hp.myBar:SetPoint(relative, previous, relative, 0, 0)
		hp.myBar:SetReverseFill(reversed)
		previous = hp.myBar
		hp.myBar:Show()
	end

	if(hp.absorbBar) then
		hp.absorbBar:SetMinMaxValues(barMin, barMax)
		hp.absorbBar:SetValue(totalAbsorb)
		hp.absorbBar:SetAllPoints(hbar)
		hp.absorbBar:SetReverseFill(not reversed)
		hp.absorbBar:Show()
	end

	if(hp.healAbsorbBar) then
		hp.healAbsorbBar:SetMinMaxValues(barMin, barMax)
		hp.healAbsorbBar:SetValue(myCurrentHealAbsorb)
		hp.healAbsorbBar:SetPoint(anchor, hbar, anchor, 0, 0)
		hp.healAbsorbBar:SetPoint(relative, previous, relative, 0, 0)
		hp.healAbsorbBar:SetReverseFill(reversed)
		previous = hp.healAbsorbBar
		hp.healAbsorbBar:Show()
	end
end

function MOD:CreateHealPrediction(frame, fullSet)
	local health = frame.Health;
	local isReversed = false
	if(health.fillInverted and health.fillInverted == true) then
		isReversed = true
	end
	local hTex = health:GetStatusBarTexture()
	local myBar = CreateFrame('StatusBar', nil, health)
	myBar:SetFrameStrata("LOW")
	myBar:SetFrameLevel(6)
	myBar:SetStatusBarTexture([[Interface\BUTTONS\WHITE8X8]])
	myBar:SetStatusBarColor(0.15, 0.7, 0.05, 0.9)

	local absorbBar = CreateFrame('StatusBar', nil, health)
	absorbBar:SetFrameStrata("LOW")
	absorbBar:SetFrameLevel(7)
	absorbBar:SetStatusBarTexture(SV.media.statusbar.gradient)
	absorbBar:SetStatusBarColor(1, 1, 0, 0.5)

	local healPrediction = {
		myBar = myBar,
		absorbBar = absorbBar,
		maxOverflow = 1,
		reversed = isReversed,
		Override = OverrideUpdate
	}

	if(fullSet) then
		local healAbsorbBar = CreateFrame('StatusBar', nil, health)
		healAbsorbBar:SetFrameStrata("LOW")
		healAbsorbBar:SetFrameLevel(9)
		healAbsorbBar:SetStatusBarTexture(SV.media.statusbar.gradient)
		healAbsorbBar:SetStatusBarColor(0.5, 0.2, 1, 0.9)
		healPrediction["healAbsorbBar"] = healAbsorbBar;
	end

	return healPrediction
end

-- JV - 20160919 : Resolve mechanic is now gone as of Legion.
--[[
##########################################################
RESOLVE
##########################################################
]]--
-- local cached_resolve;
-- local RESOLVE_ID = 158300;

-- local function Short(value)
-- 	local fmt
-- 	if value >= 10000 then
-- 		fmt = "%.0fk"
-- 		value = value / 1000
-- 	elseif value >= 1000 then
-- 		fmt = "%.1fk"
-- 		value = value / 1000
-- 	else
-- 		fmt = "%d"
-- 	end
-- 	return fmt:format(value)
-- end

-- local function IsTank()
-- 	local _, playerclass = UnitClass("player")
-- 	local masteryIndex
-- 	local tank = false
-- 	if playerclass == "DEATHKNIGHT" then
-- 		masteryIndex = GetSpecialization()
-- 		if masteryIndex and masteryIndex == 1 then
-- 			tank = true
-- 		end
-- 	elseif playerclass == "DRUID" then
-- 		masteryIndex = GetSpecialization()
-- 		if masteryIndex and masteryIndex == 3 then
-- 			tank = true
-- 		end
-- 	elseif playerclass == "MONK" then
-- 		masteryIndex = GetSpecialization()
-- 		if masteryIndex and masteryIndex == 1 then
-- 			tank = true
-- 		end
-- 	elseif playerclass == "PALADIN" then
-- 		masteryIndex = GetSpecialization()
-- 		if masteryIndex and masteryIndex == 2 then
-- 			tank = true
-- 		end
-- 	elseif playerclass == "WARRIOR" then
-- 		masteryIndex = GetSpecialization()
-- 		if masteryIndex and masteryIndex == 3 then
-- 			tank = true
-- 		end
-- 	elseif playerclass == "DEMONHUNTER" then
-- 		masteryIndex = GetSpecialization()
-- 		if masteryIndex and masteryIndex == 2 then
-- 			tank = true
-- 		end
-- 	end
-- 	return tank
-- end

-- local ResolveBar_OnEvent = function(self, event, unit)
-- 	if(SV.db.UnitFrames.resolveBar) then
-- 		if(event == 'UNIT_AURA') then
-- 			for index = 1, 30 do
-- 				local _, _, _, _, _, _, _, _, _, _, spellID, _, _, _, value, amount = UnitBuff('player', index)
-- 				if((spellID == RESOLVE_ID) and (amount and (cached_resolve ~= amount))) then
-- 					if(value) then
-- 						self.bar:SetValue(value)
-- 					end
-- 					self.bar.text:SetText(Short(amount))
-- 					self:FadeIn()
-- 					cached_resolve = amount
-- 				end
-- 			end
-- 		else
-- 			if IsTank() then
-- 				if(not self.bar:IsShown()) then
-- 					self:RegisterUnitEvent("UNIT_AURA", "player")
-- 					self.bar:Show()
-- 				end
-- 			else
-- 				if(self.bar:IsShown()) then
-- 					self:UnregisterEvent("UNIT_AURA")
-- 					self.bar:Hide()
-- 				end
-- 			end
-- 		end
-- 	else
-- 		if(self.bar:IsShown()) then
-- 			self:UnregisterEvent("UNIT_AURA")
-- 			self.bar:Hide()
-- 		end
-- 	end
-- 	if(self.bar:IsShown()) then
-- 		if(self.bar.text:GetText() == "0") then
-- 			self.bar.text:SetText("")
-- 			self:FadeOut()
-- 		end
-- 	end
-- end

-- function MOD:CreateResolveBar(frame)
-- 	local resolve = CreateFrame("Frame", nil, frame)
-- 	resolve:SetPoint("TOPLEFT", frame.Health, "TOPLEFT", 0, 0)
-- 	resolve:SetPoint("TOPRIGHT", frame.Health, "TOPRIGHT", 0, 0)
-- 	resolve:SetHeight(8)

-- 	local bar = CreateFrame('StatusBar', nil, resolve)
-- 	bar:InsetPoints(resolve)
-- 	bar:SetStyle("Frame", "Bar")
-- 	bar:SetStatusBarTexture([[Interface\BUTTONS\WHITE8X8]])
-- 	bar:SetStatusBarColor(0.15, 0.7, 0.05, 0.9)
-- 	bar:SetMinMaxValues(0, 100)
-- 	bar.text = bar:CreateFontString(nil, "OVERLAY")
-- 	bar.text:SetPoint("LEFT")
-- 	bar.text:SetFontObject(SVUI_Font_Pixel)
-- 	bar.text:SetJustifyH('LEFT')
-- 	bar.text:SetTextColor(0.8, 0.42, 0.09)
-- 	bar:Hide()
-- 	resolve.bar = bar;

-- 	resolve:RegisterEvent("PLAYER_TALENT_UPDATE")
-- 	resolve:RegisterEvent("PLAYER_ENTERING_WORLD")
-- 	resolve:SetScript('OnEvent', ResolveBar_OnEvent)

-- 	ResolveBar_OnEvent(resolve)
-- 	return resolve
-- end
