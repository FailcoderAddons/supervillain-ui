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
local UnitAura              = _G.UnitAura;
local UnitBuff              = _G.UnitBuff;
local UnitStat              = _G.UnitStat;
local UnitLevel             = _G.UnitLevel;
local UnitClass             = _G.UnitClass;
--local NUM_LE_RAID_BUFF_TYPES = _G.NUM_LE_RAID_BUFF_TYPES;
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
local LSM = _G.LibStub("LibSharedMedia-3.0")
local MOD = SV.Auras;
if(not MOD) then return end;

MOD.Holder = CreateFrame("Frame", "SVUI_AurasAnchor", UIParent)
MOD.HyperBuffFrame = CreateFrame('Frame', 'SVUI_ConsolidatedBuffs', UIParent)
--[[
##########################################################
LOCAL VARS
##########################################################
]]--
local HOLDER_OFFSET = -8;
local AURA_FADE_TIME = 5;
local DIRECTION_TO_POINT = {
	DOWN_RIGHT = "TOPLEFT",
	DOWN_LEFT = "TOPRIGHT",
	UP_RIGHT = "BOTTOMLEFT",
	UP_LEFT = "BOTTOMRIGHT",
	RIGHT_DOWN = "TOPLEFT",
	RIGHT_UP = "BOTTOMLEFT",
	LEFT_DOWN = "TOPRIGHT",
	LEFT_UP = "BOTTOMRIGHT",
};
local DIRECTION_TO_HORIZONTAL_SPACING_MULTIPLIER = {
	DOWN_RIGHT = 1,
	DOWN_LEFT = -1,
	UP_RIGHT = 1,
	UP_LEFT = -1,
	RIGHT_DOWN = 1,
	RIGHT_UP = 1,
	LEFT_DOWN = -1,
	LEFT_UP = -1,
};
local DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER = {
	DOWN_RIGHT = -1,
	DOWN_LEFT = -1,
	UP_RIGHT = 1,
	UP_LEFT = 1,
	RIGHT_DOWN = -1,
	RIGHT_UP = 1,
	LEFT_DOWN = -1,
	LEFT_UP = 1,
};
local IS_HORIZONTAL_GROWTH = {
	RIGHT_DOWN = true,
	RIGHT_UP = true,
	LEFT_DOWN = true,
	LEFT_UP = true,
};
--[[
##########################################################
CORE FUNCTIONS
##########################################################
]]--
do
	local RefreshAuraTime = function(self, elapsed)
		if(self.offset) then
			local expiration = select(self.offset, GetWeaponEnchantInfo())
			if expiration then
				self.timeLeft = expiration / 1e3
			else
				self.timeLeft = 0
			end
		else
			self.timeLeft = self.timeLeft - elapsed
		end

		if(self.nextUpdate > 0) then
			self.nextUpdate = self.nextUpdate - elapsed;
			return
		end

		local expires = self.timeLeft
		local calc = 0;
		local remaining = 0;
		if expires < 60 then
			if expires >= AURA_FADE_TIME then
				remaining = floor(expires)
				self.nextUpdate = 0.51
				self.time:SetFormattedText("|cffffff00%d|r", remaining)
			else
				remaining = expires
				self.nextUpdate = 0.051
				self.time:SetFormattedText("|cffff0000%.1f|r", remaining)
			end
		elseif expires < 3600 then
			remaining = ceil(expires / 60);
			calc = floor((expires / 60) + .5);
			self.nextUpdate = calc > 1 and ((expires - calc) * 29.5) or (expires - 59.5);
			self.time:SetFormattedText("|cffffffff%dm|r", remaining)
		elseif expires < 86400 then
			remaining = ceil(expires / 3600);
			calc = floor((expires / 3600) + .5);
			self.nextUpdate = calc > 1 and ((expires - calc) * 1799.5) or (expires - 3570);
			self.time:SetFormattedText("|cff66ffff%dh|r", remaining)
		else
			remaining = ceil(expires / 86400);
			calc = floor((expires / 86400) + .5);
			self.nextUpdate = calc > 1 and ((expires - calc) * 43199.5) or (expires - 86400);
			self.time:SetFormattedText("|cff6666ff%dd|r", remaining)
		end

		if(self.timeLeft > AURA_FADE_TIME) then
			SV.Animate:StopFlash(self)
		else
			SV.Animate:Flash(self, 1)
		end
	end

	local Aura_OnAttributeChanged = function(self, attribute, auraIndex)
		if(attribute == "index") then
			local filter = self:GetParent():GetAttribute("filter")
			local unit = self:GetParent():GetAttribute("unit")
			local name, icon, count, dispelType, val, expires, caster = UnitAura(unit, auraIndex, filter)
			if name then
				if val > 0 and expires then
					local timeLeft = expires - GetTime()
					if(not self.timeLeft) then
						self.timeLeft = timeLeft;
						self:SetScript("OnUpdate", RefreshAuraTime)
					else
						self.timeLeft = timeLeft
					end
					self.nextUpdate = -1;
					RefreshAuraTime(self, 0)
				else
					self.timeLeft = nil;
					self.time:SetText("")
					self:SetScript("OnUpdate", nil)
				end
				if count > 0 then
					self.count:SetText(count)
				else
					self.count:SetText("")
				end
				if filter == "HARMFUL" then
					local color = DebuffTypeColor[dispelType or ""]
					self:SetBackdropBorderColor(color.r, color.g, color.b)
				else
					self:SetBackdropBorderColor(0, 0, 0);
				end
				self.texture:SetTexture(icon)
				self.offset = nil
			end
		elseif(attribute == "target-slot") then
			local quality = GetInventoryItemQuality("player", auraIndex)
			local tex = GetInventoryItemTexture("player", auraIndex)
			self.texture:SetTexture(tex)
			local offset = 2;
			local enchantIndex = self:GetName():sub(-1)
			if(enchantIndex:match("2")) then
				offset = 5
			end

			if(quality) then
				self:SetBackdropBorderColor(GetItemQualityColor(quality))
			end

			local enchantInfo = select(offset, GetWeaponEnchantInfo())
			if(enchantInfo) then
				self.offset = offset;
				self:SetScript("OnUpdate", RefreshAuraTime)
				self.nextUpdate = -1;
				RefreshAuraTime(self, 0)
			else
				self.timeLeft = nil;
				self.offset = nil;
				self:SetScript("OnUpdate", nil)
				self.time:SetText("")
				self:SetAlpha(0)
			end
		end
	end

	function MOD:CreateIcon(aura, has_attrib)
		aura:SetBackdrop({
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
	 	aura:SetBackdropColor(0, 0, 0)
	 	aura:SetBackdropBorderColor(0, 0, 0)

		aura.texture = aura:CreateTexture(nil, "BORDER")
		aura.texture:InsetPoints(aura, 2, 2)
		aura.texture:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))

		aura.count = aura:CreateFontString(nil, "ARTWORK")
		aura.count:SetPoint("BOTTOMRIGHT", (-1 + SV.db.Auras.countOffsetH), (1 + SV.db.Auras.countOffsetV))
		aura.count:SetFontObject(SVUI_Font_Aura)

		aura.time = aura:CreateFontString(nil, "ARTWORK")
		aura.time:SetPoint("TOP", aura, "BOTTOM", 1 + SV.db.Auras.timeOffsetH, 0 + SV.db.Auras.timeOffsetV)
		aura.time:SetFontObject(SVUI_Font_Aura)

		aura.highlight = aura:CreateTexture(nil, "HIGHLIGHT")
		aura.highlight:SetTexture(SV.media.statusbar.default)
		aura.highlight:SetVertexColor(1, 1, 1, 0.45)
		aura.highlight:InsetPoints(aura, 2, 2)

		SV.Animate:Flash(aura)
		aura:SetScript("OnAttributeChanged", Aura_OnAttributeChanged)
	end
end

do
	local ConsolidatedBuff_OnUpdate = function(self, current)
		local expires = (self.expiration - current);
		self.expiration = expires;
		self.bar:SetValue(expires)
		if self.nextUpdate > 0 then
			self.nextUpdate = self.nextUpdate - current;
			return
		end
		if self.expiration <= 0 then
			self:SetScript("OnUpdate", nil)
			return
		end

		local calc = 0;
		if expires < 60 then
			if expires >= AURA_FADE_TIME then
				self.nextUpdate = 0.51;
			else
				self.nextUpdate = 0.051;
			end
		elseif expires < 3600 then
			calc = floor((expires / 60) + .5);
			self.nextUpdate = calc > 1 and ((expires - calc) * 29.5) or (expires - 59.5);
		elseif expires < 86400 then
			calc = floor((expires / 3600) + .5);
			self.nextUpdate = calc > 1 and ((expires - calc) * 1799.5) or (expires - 3570);
		else
			calc = floor((expires / 86400) + .5);
			self.nextUpdate = calc > 1 and ((expires - calc) * 43199.5) or (expires - 86400);
		end
	end

	local UpdateConsolidatedReminder = function(self, event, arg)
		if(event == "UNIT_AURA" and arg ~= "player") then return end
		for i = 1, NUM_LE_RAID_BUFF_TYPES do
			local name, _, duration, expiration, spellId, slot, caster, classFileName, unitName;
			name, _, _, duration, expiration, spellId, slot = GetRaidBuffTrayAuraInfo(i)

			--[[ EXPERIMENTAL ]]--
			if(name) then
				_, _, _, _, _, _, _, caster = UnitBuff('player', name)
			elseif(slot) then
				name, _, _, _, _, _, _, caster = UnitBuff('player', slot)
			end
			local buff = MOD.HyperBuffFrame[i]
			--[[ ____________ ]]--

			if name then
				if(caster) then
					_,classFileName = UnitClass(caster)
					unitName = UnitName(caster)
					if(classFileName and RAID_CLASS_COLORS[classFileName]) then
						local hex = RAID_CLASS_COLORS[classFileName].colorStr
						buff.casterTip = ("|c%s%s|r"):format(hex, unitName)
					else
						buff.casterTip = unitName
					end
				end
				local timeLeft = expiration - GetTime()

				buff.expiration = timeLeft;
				buff.duration = duration;
				buff.spellName = name;
				buff.nextUpdate = 0;
				buff:SetAlpha(1)
				buff.empty:SetAlpha(1)
				if(duration > 0 and timeLeft > 0) then
					buff:SetAlpha(1)
					buff:SetScript("OnUpdate", ConsolidatedBuff_OnUpdate)
					buff.bar:SetMinMaxValues(0, duration)
					buff.bar:SetValue(timeLeft)
				else
					buff:SetScript("OnUpdate", nil)
					buff.bar:SetMinMaxValues(0, 1)
					buff.bar:SetValue(1)
				end
			else
				buff.spellName = nil;
				buff.casterTip = nil;
				buff.bar:SetValue(0)
				buff:SetAlpha(0.1)
				buff.empty:SetAlpha(0)
				buff:SetScript("OnUpdate", nil)
			end
		end
	end

	local function PlayerRoleChanged()
		if(SV.db.Auras.hyperBuffsEnabled) then
			MOD:Update_ConsolidatedBuffsSettings()
		end
	end

	function MOD:ToggleConsolidatedBuffs()
		if(SV.db.Auras.hyperBuffsEnabled) then
			local maxShown = #MOD.media.hyperAuraIcons - 1
			local CB_HEIGHT = Minimap:GetHeight()
			local CB_WIDTH = (CB_HEIGHT / maxShown) + 4
			--print("ToggleConsolidatedBuffs "..CB_WIDTH)
			MOD.Holder:SetSize(CB_WIDTH, CB_HEIGHT)
			MOD.HyperBuffFrame:Show()
			BuffFrame:RegisterUnitEvent("UNIT_AURA", "player")
			MOD:RegisterEvent("UNIT_AURA", UpdateConsolidatedReminder)
			MOD:RegisterEvent("GROUP_ROSTER_UPDATE", UpdateConsolidatedReminder)
			MOD:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", UpdateConsolidatedReminder)
			UpdateConsolidatedReminder()
		else
			MOD.HyperBuffFrame:Hide()
			--BuffFrame:UnregisterEvent("UNIT_AURA")
			--MOD:UnregisterEvent("UNIT_AURA")
			MOD:UnregisterEvent("GROUP_ROSTER_UPDATE")
			MOD:UnregisterEvent("PLAYER_SPECIALIZATION_CHANGED")
		end
	end
end

do
	local AuraButton_OnEnter = function(self)
		GameTooltip:Hide()
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", -3, self:GetHeight() + 2)
		GameTooltip:ClearLines()
		local parent = self:GetParent()
		local id = parent:GetID()
		if parent.spellName then
			GameTooltip:SetUnitConsolidatedBuff("player", id)
			if parent.casterTip then
				GameTooltip:AddDoubleLine("|cff00FFFFCast By:|r", parent.casterTip)
			end
		end
		GameTooltip:AddDoubleLine("|cff00FFFFBuff Type:|r", _G[("RAID_BUFF_%d"):format(id)])
		GameTooltip:Show()
	end

	local AuraButton_OnLeave = function(self)
		GameTooltip:Hide()
	end

	function MOD:Update_ConsolidatedBuffsSettings(event)
		MOD.HyperBuffFrame:SetAllPoints(MOD.Holder)
		local hideIndex;
		if(SV.db.Auras.hyperBuffsFiltered) then
			if SV.SpecificClassRole == 'CASTER' then
				hideIndex = 3
			else
				hideIndex = 5
			end
		end
		local lastGoodFrame
		local maxShown = #MOD.media.hyperAuraIcons - 1
		local CB_HEIGHT = Minimap:GetHeight() - 50
		local buffSize = (CB_HEIGHT / maxShown) - 1

		for i=1, NUM_LE_RAID_BUFF_TYPES do
			local buff = MOD.HyperBuffFrame[i]
			local lastIndex = (i - 1)
			if(buff) then
				buff:ClearAllPoints()

				if i==1 then
					buff:SetPoint("TOP", MOD.HyperBuffFrame, "TOP", 0, 0)
					lastGoodFrame = buff
				else
					buff:SetPoint("TOP", lastGoodFrame, "BOTTOM", 0, -4)
				end

				if(hideIndex and i == hideIndex) then
					buff:Hide()
				else
					buff:Show()
					lastGoodFrame = buff
				end

				buff:SetSize(buffSize,buffSize)

				local tip = _G[("ConsolidatedBuffsTooltipBuff%d"):format(i)]
				tip:ClearAllPoints()
				tip:SetAllPoints(MOD.HyperBuffFrame[i])
				tip:SetParent(MOD.HyperBuffFrame[i])
				tip:SetAlpha(0)
				tip:SetScript("OnEnter",AuraButton_OnEnter)
				tip:SetScript("OnLeave",AuraButton_OnLeave)
			end
		end
		if not event then
			MOD:ToggleConsolidatedBuffs()
		end
	end
end

function MOD:UpdateAuraHeader(auraHeader, auraType)
	if(InCombatLockdown() or not auraHeader) then return end

	local db = SV.db.Auras[auraType]
	local showBy = db.showBy

	if(auraType == "buffs") then
		auraHeader:SetAttribute("consolidateTo", SV.db.Auras.hyperBuffsEnabled == true and 1 or 0)
		auraHeader:SetAttribute("weaponTemplate", ("SVUI_AuraTemplate%d"):format(db.size))
	end

	auraHeader:SetAttribute("separateOwn", db.isolate)
	auraHeader:SetAttribute("sortMethod", db.sortMethod)
	auraHeader:SetAttribute("sortDirection", db.sortDir)
	auraHeader:SetAttribute("maxWraps", db.maxWraps)
	auraHeader:SetAttribute("wrapAfter", db.wrapAfter)

	auraHeader:SetAttribute("point", DIRECTION_TO_POINT[showBy])

	if(IS_HORIZONTAL_GROWTH[showBy]) then
		auraHeader:SetAttribute("minWidth", ((db.wrapAfter == 1 and 0 or db.wrapXOffset) + db.size) * db.wrapAfter)
		auraHeader:SetAttribute("minHeight", (db.wrapYOffset + db.size) * db.maxWraps)
		auraHeader:SetAttribute("xOffset", DIRECTION_TO_HORIZONTAL_SPACING_MULTIPLIER[showBy] * (db.wrapXOffset + db.size))
		auraHeader:SetAttribute("yOffset", 0)
		auraHeader:SetAttribute("wrapXOffset", 0)
		auraHeader:SetAttribute("wrapYOffset", DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER[showBy] * (db.wrapYOffset + db.size))
	else
		auraHeader:SetAttribute("minWidth", (db.wrapXOffset + db.size) * db.maxWraps)
		auraHeader:SetAttribute("minHeight", ((db.wrapAfter == 1 and 0 or db.wrapYOffset) + db.size) * db.wrapAfter)
		auraHeader:SetAttribute("xOffset", 0)
		auraHeader:SetAttribute("yOffset", DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER[showBy] * (db.wrapYOffset + db.size))
		auraHeader:SetAttribute("wrapXOffset", DIRECTION_TO_HORIZONTAL_SPACING_MULTIPLIER[showBy] * (db.wrapXOffset + db.size))
		auraHeader:SetAttribute("wrapYOffset", 0)
	end

	auraHeader:SetAttribute("template", ("SVUI_AuraTemplate%d"):format(db.size))

	local i = 1;
	local auraChild = select(i, auraHeader:GetChildren())

	while(auraChild) do
		if ((floor(auraChild:GetWidth() * 100 + 0.5) / 100) ~= db.size) then
			auraChild:SetSize(db.size, db.size)
		end
		if(auraChild.time) then
			auraChild.time:ClearAllPoints()
			auraChild.time:SetPoint("TOP", auraChild, "BOTTOM", 1 + SV.db.Auras.timeOffsetH, SV.db.Auras.timeOffsetV)
			auraChild.count:ClearAllPoints()
			auraChild.count:SetPoint("BOTTOMRIGHT", -1 + SV.db.Auras.countOffsetH, SV.db.Auras.countOffsetV)
		end
		if ((i > (db.maxWraps * db.wrapAfter)) and auraChild:IsShown()) then
			auraChild:Hide()
		end

		i = i + 1;
		auraChild = select(i, auraHeader:GetChildren())
	end
end

function MOD:UpdateAuraHolder(newHeight, referenceHolder)
	if(not newHeight) then return end
	self.Holder:SetHeight(newHeight)
	if(self.Holder.Grip) then
		self.Holder.Grip:SetHeight(newHeight)
		if((not self.Holder.Grip:HasMoved()) and (referenceHolder and referenceHolder.HasMoved and (not referenceHolder:HasMoved()))) then
			HOLDER_OFFSET = -8;
			self.Holder.Grip:ClearAllPoints()
			self.Holder.Grip:SetPoint("TOPRIGHT", referenceHolder, "TOPLEFT", HOLDER_OFFSET, 0)
		end
	end
	--[[
	if(self.HyperBuffFrame) then
		self:Update_ConsolidatedBuffsSettings()
	end
	]]--
end
--[[
##########################################################
UPDATE AND BUILD
##########################################################
]]--
function MOD:ReLoad()
	if(InCombatLockdown()) then return end
	local maxShown = #self.media.hyperAuraIcons - 1
	local CB_HEIGHT = Minimap:GetHeight() - 50;
	local CB_WIDTH = (CB_HEIGHT / maxShown) + 4;
	if(SVUI_MinimapFrame) then
		CB_HEIGHT = SVUI_MinimapFrame:GetHeight() - 50;
	end
	self.Holder:SetSize(CB_WIDTH, CB_HEIGHT)
	AURA_FADE_TIME = SV.db.Auras.fadeBy
	self:UpdateAuraHeader(SVUI_PlayerBuffs, "buffs");
	self:UpdateAuraHeader(SVUI_PlayerDebuffs, "debuffs");
	self:UpdateProcWatch();
end

function MOD:Load()
	local maxShown = #self.media.hyperAuraIcons - 1;
	local CB_HEIGHT = Minimap:GetHeight() - 50;
	local CB_WIDTH = (CB_HEIGHT / maxShown) + 4;

	if(SVUI_MinimapFrame) then
		CB_HEIGHT = SVUI_MinimapFrame:GetHeight() - 50;
	end

	self.Holder:SetSize(CB_WIDTH, CB_HEIGHT)
	self.Holder:SetPoint("TOPRIGHT", Minimap, "TOPLEFT", HOLDER_OFFSET, 0)

	--[[
	if(SV.db.Auras.hyperBuffsEnabled) then
		ConsolidatedBuffs:Die()

		self.HyperBuffFrame:SetAllPoints(self.Holder)
		self.HyperBuffFrame:SetFrameStrata("BACKGROUND")
		SV:ManageVisibility(self.HyperBuffFrame)

		for i = 1, NUM_LE_RAID_BUFF_TYPES do
			local texture = self.media.hyperAuraIcons[i]
			local buff = CreateFrame("Button", nil, self.HyperBuffFrame)
			buff.bar = CreateFrame("StatusBar", nil, buff)
			buff.bar:SetAllPoints(buff)
			buff.bar:SetStatusBarTexture(texture)
			buff.bar:SetOrientation("VERTICAL")
			buff.bar:SetMinMaxValues(0, 100)
			buff.bar:SetValue(0)

			buff.bg = buff.bar:CreateTexture(nil, "BACKGROUND", nil, -2)
			buff.bg:WrapPoints(buff, 1, 1)
			buff.bg:SetTexture(texture)
			buff.bg:SetVertexColor(0, 0, 0, 0.5)

			buff.empty = buff.bar:CreateTexture(nil, "BACKGROUND", nil, -1)
			buff.empty:SetAllPoints(buff)
			buff.empty:SetTexture(texture)
			buff.empty:SetDesaturated(true)
			buff.empty:SetVertexColor(0.5, 0.5, 0.5)
			buff.empty:SetBlendMode("ADD")

			buff:SetAlpha(0.1)
			buff:SetID(i)

			self.HyperBuffFrame[i] = buff
		end
		SV.Events:On("PLAYER_ROLE_CHANGED", PlayerRoleChanged)
		self:Update_ConsolidatedBuffsSettings()
	end
	]]--
	if(SV.db.Auras.aurasEnabled) then
		BuffFrame:Die()
		TemporaryEnchantFrame:Die()
		InterfaceOptionsFrameCategoriesButton12:SetScale(0.0001)

		local buffHeader = CreateFrame("Frame", "SVUI_PlayerBuffs", self.Holder, "SecureAuraHeaderTemplate")
		buffHeader:SetClampedToScreen(true)
		buffHeader:SetPoint("TOPRIGHT", self.Holder, "TOPLEFT", -8, 0)
		buffHeader:SetAttribute("unit", "player")
		buffHeader:SetAttribute("filter", "HELPFUL")
		RegisterStateDriver(buffHeader, "visibility", "[petbattle] hide; show")
		RegisterAttributeDriver(buffHeader, "unit", "[vehicleui] vehicle; player")
		buffHeader:SetAttribute("consolidateDuration", -1)
		buffHeader:SetAttribute("includeWeapons", 1)
		self:UpdateAuraHeader(buffHeader, "buffs")
		buffHeader:Show()

		local debuffHeader = CreateFrame("Frame", "SVUI_PlayerDebuffs", self.Holder, "SecureAuraHeaderTemplate")
		debuffHeader:SetClampedToScreen(true)
		debuffHeader:SetPoint( "BOTTOMRIGHT", self.Holder, "BOTTOMLEFT", -8, 0)
		debuffHeader:SetAttribute("unit", "player")
		debuffHeader:SetAttribute("filter", "HARMFUL")
		RegisterStateDriver(debuffHeader, "visibility", "[petbattle] hide; show")
		RegisterAttributeDriver(debuffHeader, "unit", "[vehicleui] vehicle; player")
		self:UpdateAuraHeader(debuffHeader, "debuffs")
		debuffHeader:Show()
	end

	SV:NewAnchor(self.Holder, L["Auras Frame"])
	SV:ManageVisibility(self.Holder)

	self:InitializeProcWatch()
end
