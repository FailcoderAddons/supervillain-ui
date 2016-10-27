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
local string 	= _G.string;
local math 		= _G.math;
local table 	= _G.table;
--[[ STRING METHODS ]]--
local format = string.format;
--[[ MATH METHODS ]]--
local abs, ceil, floor, round = math.abs, math.ceil, math.floor, math.round;
--[[ TABLE METHODS ]]--
local tremove, twipe = table.remove, table.wipe;
--BLIZZARD API
local CreateFrame           = _G.CreateFrame;
local InCombatLockdown      = _G.InCombatLockdown;
local GameTooltip           = _G.GameTooltip;
local ReloadUI              = _G.ReloadUI;
local hooksecurefunc        = _G.hooksecurefunc;
local GetTime               = _G.GetTime;
local UnitName              = _G.UnitName;
local UnitGUID              = _G.UnitGUID;
local UnitAura              = _G.UnitAura;
local UnitBuff              = _G.UnitBuff;
local UnitDebuff            = _G.UnitDebuff;
local UnitStat              = _G.UnitStat;
local UnitLevel             = _G.UnitLevel;
local UnitClass             = _G.UnitClass;
local NUM_LE_RAID_BUFF_TYPES = _G.NUM_LE_RAID_BUFF_TYPES;
local RAID_CLASS_COLORS     = _G.RAID_CLASS_COLORS;
local CUSTOM_CLASS_COLORS   = _G.CUSTOM_CLASS_COLORS;
local GetItemQualityColor   = _G.GetItemQualityColor;
local GetInventoryItemQuality   = _G.GetInventoryItemQuality;
local GetInventoryItemTexture   = _G.GetInventoryItemTexture;
local GetWeaponEnchantInfo  = _G.GetWeaponEnchantInfo;
local RegisterStateDriver   = _G.RegisterStateDriver;
local UnregisterStateDriver = _G.UnregisterStateDriver;
local RegisterAttributeDriver   = _G.RegisterAttributeDriver;
local GetRaidBuffTrayAuraInfo 	= _G.GetRaidBuffTrayAuraInfo;
--[[
##########################################################
GET ADDON DATA
##########################################################
]]--
local SV = _G['SVUI']
local L = SV.L
local MOD = SV.Auras;
if(not MOD) then return end;

--[[
##########################################################
LOCAL VARS
##########################################################
]]--
local ProcWatch = CreateFrame('Frame', 'SVUI_ProcWatch', UIParent);

local OnCooldDownExpired = function(self)
	self.timeLeft = nil;
	self:FadeOut(0.2, 1, 0, true)
end

local function CreateProcIcon()
	local proc = CreateFrame("Frame", nil, ProcWatch)

 	local bg = proc:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetColorTexture(0,0,0,0.5)

	proc.icon = proc:CreateTexture(nil, "BORDER")
	proc.icon:InsetPoints(proc, 2, 2)
	proc.icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
	proc.icon:SetVertexColor(1,1,1,0.6)

	proc.count = proc:CreateFontString(nil, "ARTWORK")
	proc.count:SetPoint("BOTTOMRIGHT", (-1 + SV.db.Auras.countOffsetH), (1 + SV.db.Auras.countOffsetV))
	proc.count:SetFontObject(SVUI_Font_Aura)

	proc.time = proc:CreateFontString(nil, "ARTWORK")
	proc.time:SetPoint("TOP", proc, "BOTTOM", 1 + SV.db.Auras.timeOffsetH, 0 + SV.db.Auras.timeOffsetV)
	proc.time:SetFontObject(SVUI_Font_Aura)
	proc.HideAfterCooldown = true
	proc.cooldown = SV.API:CD(proc);

	proc.highlight = proc:CreateTexture(nil, "HIGHLIGHT")
	proc.highlight:SetTexture(SV.media.statusbar.default)
	proc.highlight:SetVertexColor(1, 1, 1, 0.45)
	proc.highlight:InsetPoints(proc, 2, 2)

	SV.Animate:Kapow(proc, false, true, true)

	return proc;
end
--[[
##########################################################
CORE FUNCTIONS
##########################################################
]]--
local PROC_UNIT_AURA = function(self, event, unit)
	if(not unit) then return end

	local index = 1
	local SPELLS = self.cache
	local PROCS = self.slots
	local _, name, texture, count, duration, expiration, caster, key, spellID
	local filter = "HELPFUL";
	local lastProc;
	local lastIndex = 1;

	while true do

		name, _, texture, count, _, duration, expiration, caster, _, _, spellID = UnitAura(unit, index, filter)

		if not name then
			if filter == "HELPFUL" then
				filter = "HARMFUL"
				index = 1
			else
				break
			end
		else
			local aura = PROCS[lastIndex]
			if(SPELLS[spellID] and aura and duration and (duration > 0)) then
				aura:ClearAllPoints()
				if(not lastProc) then
					aura:SetPoint('RIGHT', self, 'RIGHT', 0, 0)
				else
					aura:SetPoint('RIGHT', lastProc, 'LEFT', -1, 0)
				end
				local timeleft = expiration - duration;
				local lastTimer = aura.LastTimer or 0

				if(lastTimer < expiration) then
					aura.anim:Stop()
					aura.icon:SetTexture(texture)
					aura:Show()
					aura.anim[2]:SetDuration(duration)
      		aura.anim:Play()
      		aura.cooldown:SetCooldown(timeleft, duration)
      	end
      	aura.LastTimer = expiration

				local textCount = '';
				if(count and (count > 1)) then
					textCount = count
				end
				aura.count:SetText(textCount);

				lastProc = aura;
				lastIndex = lastIndex + 1;
			end
			index = index + 1
		end
	end

	for x=lastIndex, #PROCS do
		PROCS[x]:Hide()
	end
end

function MOD:UpdateProcWatch()
	ProcWatch.cache = {}
	ProcWatch.slots = {}
	local pwSize = SV.db.Auras.procSize or 40;
	local CONFIG = SV.db.Filters.Procs
	local i,j = 1,1;
	for procID,procData in pairs(CONFIG) do
		if(procData.enable) then
			local spellID = tonumber(procID);
			local spellName,_,spellTexture = GetSpellInfo(spellID)
			if spellName then
				local proc = ProcWatch.slots[j];
				ProcWatch.cache[spellID] = true
				if(not proc) then
					proc = CreateProcIcon()
					ProcWatch.slots[j] = proc
				end;
				j = j + 1;
				proc.name = spellName;
				proc.index = i;
				proc.spellID = spellID;
				proc:SetWidth(pwSize)
				proc:SetHeight(pwSize)
				proc:ClearAllPoints()
				proc:SetPoint('RIGHT', ProcWatch, 'RIGHT', -((i - 1) * 43), 0)
				proc.icon:SetTexture(spellTexture)
				proc:Hide();

				i = i + 1
			end
		end
	end;
end;

function MOD:InitializeProcWatch()
	if(not SV.db.Auras.procsEnabled) then return end;

	if(not SV.db.Filters.Procs) then
		SV.db.Filters.Procs = {}
	end

	local ProcsAnchor = CreateFrame('Frame', 'SVUI_ProcWatchFrame', SV.Screen)
	ProcsAnchor:SetSize(172,40)
	ProcsAnchor:SetPoint("TOPRIGHT", SV.Screen, "CENTER", -50, -50)

	ProcWatch:SetParent(ProcsAnchor)
	ProcWatch:SetWidth(720)
	ProcWatch:SetHeight(40)
	ProcWatch:SetPoint('RIGHT', ProcsAnchor, 'RIGHT', 0, 0)
	ProcWatch:RegisterUnitEvent("UNIT_AURA", "player")
	ProcWatch:SetScript('OnEvent', PROC_UNIT_AURA)

	SV:NewAnchor(ProcsAnchor, L["Procs Frame"])

	self:UpdateProcWatch();
	SV.Events:On("AURA_FILTER_OPTIONS_CHANGED", MOD.UpdateProcWatch, true);
end;
