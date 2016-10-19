--[[ MODIFIED FOR SVUI BY SVUILUNCH ]]--

--GLOBAL NAMESPACE
local _G = _G;
--LUA
local unpack        = _G.unpack;
local select        = _G.select;
local assert        = _G.assert;
local type         	= _G.type;
--STRING
local string        = _G.string;
local format        = string.format;
--MATH
local math          = math;
local floor         = math.floor
local ceil         	= math.ceil
local hugeMath 			= math.huge;
local min 					= math.min;
local random 				= math.random;
--TABLE
local table 				= _G.table;
local tsort 				= table.sort;
local tinsert 			= _G.tinsert;
--BLIZZARD API
local GetTime       = _G.GetTime;
local CreateFrame   = _G.CreateFrame;
local UnitAura      = _G.UnitAura;
local UnitIsFriend  = _G.UnitIsFriend;
local GameTooltip  	= _G.GameTooltip;
local GetSpellInfo  = _G.GetSpellInfo;
local DebuffTypeColor  = _G.DebuffTypeColor;
local NumberFontNormal  = _G.NumberFontNormal;

local _, ns = ...
local oUF = oUF or ns.oUF
assert(oUF, 'oUF_Auras was unable to locate oUF install.')

local DAY, HOUR, MINUTE = 86400, 3600, 60;
local BUFF_FILTER = 'HELPFUL';
local DEBUFF_FILTER = 'HARMFUL';
local VISIBLE = 1;
local HIDDEN = 0;

local DEMO_SPELLS = {47540, 974, 111264, 57934, 124081}

local function FormatTime(seconds)
	if seconds < MINUTE then
		return ("%.1f"):format(seconds)
	elseif seconds < HOUR then
		return ("%d:%d"):format(seconds/60%60, seconds%60)
	elseif seconds < DAY then
		return ("%dh %dm"):format(seconds/(60*60), seconds/60%60)
	else
		return ("%dd %dh"):format(seconds/DAY, (seconds / HOUR) - (floor(seconds/DAY) * 24))
	end
end

local SORTING_METHODS = {
	["TIME_REMAINING"] = function(a, b)
		local compA = a.noTime and hugeMath or a.expirationTime
		local compB = b.noTime and hugeMath or b.expirationTime
		return compA > compB
	end,
	["TIME_REMAINING_REVERSE"] = function(a, b)
		local compA = a.noTime and hugeMath or a.expirationTime
		local compB = b.noTime and hugeMath or b.expirationTime
		return compA < compB
	end,
	["TIME_DURATION"] = function(a, b)
		local compA = a.noTime and hugeMath or a.duration
		local compB = b.noTime and hugeMath or b.duration
		return compA > compB
	end,
	["TIME_DURATION_REVERSE"] = function(a, b)
		local compA = a.noTime and hugeMath or a.duration
		local compB = b.noTime and hugeMath or b.duration
		return compA < compB
	end,
	["NAME"] = function(a, b)
		return a.name > b.name
	end,
}

local SetSorting = function(self, sorting)
	if(sorting) then
		if((type(sorting) == "string") and SORTING_METHODS[sorting]) then
			self.sort = SORTING_METHODS[sorting];
		else
			self.sort = SORTING_METHODS["TIME_REMAINING"];
		end
	else
		self.sort = nil;
	end
end

local Aura_OnEnter = function(self)
	if(not self:IsVisible()) then return end
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
	GameTooltip:SetUnitAura(self.unit, self.index, self.filter)
end

local Aura_OnLeave = function()
	GameTooltip:Hide()
end

local AuraBars_OnUpdate = function(self)
	local timeNow = GetTime()
	for index = 1, #self do
		local frame = self[index]
		local bar = frame.statusBar
		if not frame:IsVisible() then
			break
		end
		if frame.noTime then
			bar.spelltime:SetText()
			bar.spark:Hide()
		else
			local timeleft = frame.expirationTime - timeNow
			bar:SetValue(timeleft)
			bar.spelltime:SetText(FormatTime(timeleft))
			if self.spark == true then
				bar.spark:Show()
			end
		end
	end
end

local AuraIcon_OnUpdate = function(self, elapsed)
	self.expiration = self.expiration - elapsed;

	if(self.nextUpdate > 0) then
		self.nextUpdate = self.nextUpdate - elapsed;
		return;
	end

	if(self.expiration <= 0) then
		self:SetScript("OnUpdate", nil)
		self.text:SetText('')
		return;
	end

	local expires = self.expiration;
	local calc, timeLeft = 0, 0;
	if expires < 4 then
        self.nextUpdate = 0.051
        self.text:SetFormattedText("|cffff0000%.1f|r", expires)
    elseif expires < 60 then
        self.nextUpdate = 0.51
        self.text:SetFormattedText("|cffffff00%d|r", floor(expires))
    elseif expires < 3600 then
        timeLeft = ceil(expires / 60);
        calc = floor((expires / 60) + .5);
        self.nextUpdate = calc > 1 and ((expires - calc) * 29.5) or (expires - 59.5);
        self.text:SetFormattedText("|cffffffff%dm|r", timeLeft)
    elseif expires < 86400 then
        timeLeft = ceil(expires / 3600);
        calc = floor((expires / 3600) + .5);
        self.nextUpdate = calc > 1 and ((expires - calc) * 1799.5) or (expires - 3570);
        self.text:SetFormattedText("|cff66ffff%dh|r", timeLeft)
    else
        timeLeft = ceil(expires / 86400);
        calc = floor((expires / 86400) + .5);
        self.nextUpdate = calc > 1 and ((expires - calc) * 43199.5) or (expires - 85680);
        if(timeLeft > 7) then
            self.text:SetFormattedText("|cff6666ff%s|r", "long")
        else
            self.text:SetFormattedText("|cff6666ff%dd|r", timeLeft)
        end
    end
end

local SetBarLayout = function(self, visible, cache)
	local auras = self.Bars;

	local width = self.barWidth or self:GetParent():GetWidth();
	local height = self.barHeight or 16;
	local growDown = self.down or false;
	local spacing = self.spacing or 0;
	local gap = self.gap;
	local size = self.auraSize + spacing;

	if(visible > 0) then
		local newHeight = 1 + (size * visible);
		self:SetSize(width, newHeight)
	else
		self:SetSize(width, 1)
	end

	for i = visible + 1, #auras do
		auras[i]:Hide()
	end

	local lastBar;
	if(cache) then
		for i = 1, #cache do
			local info = cache[i]
			local bar = auras[info.ref]
			if(bar and bar:IsShown()) then
				bar:SetHeight(height)
				bar:SetWidth(width)
				bar.iconHolder:SetWidth(height)
				bar:ClearAllPoints()
				if(growDown) then
					if(not lastBar) then
						bar:SetPoint('TOPLEFT', self, 'TOPLEFT', 0, 0)
					else
						bar:SetPoint('TOPLEFT', lastBar, 'BOTTOMLEFT', 0, -spacing)
					end
				else
					if(not lastBar) then
						bar:SetPoint('BOTTOMLEFT', self, 'BOTTOMLEFT', 0, 0)
					else
						bar:SetPoint('BOTTOMLEFT', lastBar, 'TOPLEFT', 0, spacing)
					end
				end
				lastBar = bar
			end
		end
	else
		for index = 1, #auras do
			local bar = auras[index]
			if(bar and bar:IsShown()) then
				bar:SetHeight(height)
				bar:SetWidth(width)
				bar.iconHolder:SetWidth(height)
				bar:ClearAllPoints()
				if(growDown) then
					if(not lastBar) then
						bar:SetPoint('TOPLEFT', self, 'TOPLEFT', 0, 0)
					else
						bar:SetPoint('TOPLEFT', lastBar, 'BOTTOMLEFT', 0, -spacing)
					end
				else
					if(not lastBar) then
						bar:SetPoint('BOTTOMLEFT', self, 'BOTTOMLEFT', 0, 0)
					else
						bar:SetPoint('BOTTOMLEFT', lastBar, 'TOPLEFT', 0, spacing)
					end
				end
				lastBar = bar
			end
		end
	end
end

local SetIconLayout = function(self, visible, cache)
	local auras = self.Icons

	local col = 0
	local row = 0
	local gap = self.gap
	local size = self.auraSize + self.spacing
	local anchor = self.initialAnchor or "BOTTOMLEFT"
	local growthx = (self["growth-x"] == "LEFT" and -1) or 1
	local growthy = (self["growth-y"] == "DOWN" and -1) or 1
	local cols = self.maxColumns
	local rows = self.maxRows

	for i = visible + 1, #auras do
		auras[i]:Hide()
	end

	if(cache) then
		for i = 1, #cache do
			local info = cache[i]
			local button = auras[info.ref]
			if(button and button:IsShown()) then
				if(gap and button.debuff) then
					if(col > 0) then
						col = col + 1
					end
					gap = false
				end

				if(col >= cols) then
					col = 0
					row = row + 1
				end
				button:ClearAllPoints()
				button:SetPoint(anchor, self, anchor, col * size * growthx, row * size * growthy)
				button:SetWidth(self.auraSize)
				button:SetHeight(self.auraSize)
				col = col + 1
			elseif(not button) then
				break
			end
		end
	else
		for i = 1, #auras do
			local button = auras[i]
			if(button and button:IsShown()) then
				if(gap and button.debuff) then
					if(col > 0) then
						col = col + 1
					end
					gap = false
				end

				if(col >= cols) then
					col = 0
					row = row + 1
				end
				button:ClearAllPoints()
				button:SetPoint(anchor, self, anchor, col * size * growthx, row * size * growthy)
				button:SetWidth(self.auraSize)
				button:SetHeight(self.auraSize)
				col = col + 1
			elseif(not button) then
				break
			end
		end
	end

	local newWidth, newHeight;
	if(visible > 0) then
		local visibleRows = ceil(visible / cols);
		newHeight = 1 + (size * visibleRows);
		if(visibleRows <= 1) then
			newWidth = 1 + (size * col)
		else
			newWidth = 1 + (size * cols)
		end
	else
		newWidth = 1 + (size * cols)
		newHeight = 1
	end
	self:SetSize(newWidth, newHeight)
end

--[[ ICON SPECIFIC ]]--

local CreateAuraIcon = function(self, index)
	local button = CreateFrame("Button", nil, self)
	button:EnableMouse(true)
	button:RegisterForClicks'RightButtonUp'

	button:SetWidth(self.auraSize or 16)
	button:SetHeight(self.auraSize or 16)

	local cd = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
	cd:SetAllPoints(button)

	local icon = button:CreateTexture(nil, "BORDER")
	icon:SetAllPoints(button)

	local count = button:CreateFontString(nil, "OVERLAY")
	count:SetFontObject(NumberFontNormal)
	count:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 0)

	local overlay = button:CreateTexture(nil, "OVERLAY")
	overlay:SetTexture"Interface\\Buttons\\UI-Debuff-Overlays"
	overlay:SetAllPoints(button)
	overlay:SetTexCoord(.296875, .5703125, 0, .515625)
	button.overlay = overlay

	local stealable = button:CreateTexture(nil, 'OVERLAY')
	stealable:SetTexture[[Interface\TargetingFrame\UI-TargetingFrame-Stealable]]
	stealable:SetPoint('TOPLEFT', -3, 3)
	stealable:SetPoint('BOTTOMRIGHT', 3, -3)
	stealable:SetBlendMode'ADD'
	button.stealable = stealable

	button:SetScript("OnEnter", Aura_OnEnter)
	button:SetScript("OnLeave", Aura_OnLeave)

	button.icon = icon
	button.count = count
	button.cooldown = cd

	if(self.PostCreateIcon) then self:PostCreateIcon(button) end

	return button
end

--[[ BAR SPECIFIC ]]--

local CreateAuraBar = function(self, index)
	local frame = CreateFrame("Button", nil, self)

	frame:SetScript('OnEnter', Aura_OnEnter)
	frame:SetScript('OnLeave', Aura_OnLeave)

	local iconHolder = CreateFrame('Frame', nil, frame)
	iconHolder:SetPoint('TOPLEFT', frame, 'TOPLEFT', 0, 0)
	iconHolder:SetPoint('BOTTOMLEFT', frame, 'BOTTOMLEFT', 0, 0)
	iconHolder:SetWidth(frame:GetHeight())
	iconHolder:SetBackdrop({
        bgFile = [[Interface\BUTTONS\WHITE8X8]],
        edgeFile = [[Interface\BUTTONS\WHITE8X8]],
        tile = false,
        tileSize = 0,
        edgeSize = 1,
        insets =
        {
            left = 0,
            right = 0,
            top = 0,
            bottom = 0,
        },
    })
    iconHolder:SetBackdropColor(0,0,0,0.5)
    iconHolder:SetBackdropBorderColor(0,0,0)
	frame.iconHolder = iconHolder

	frame.icon = frame.iconHolder:CreateTexture(nil, 'BORDER')
	frame.icon:SetTexCoord(.1, .9, .1, .9)
	frame.icon:SetPoint("TOPLEFT", frame.iconHolder, "TOPLEFT", 1, -1)
	frame.icon:SetPoint("BOTTOMRIGHT", frame.iconHolder, "BOTTOMRIGHT", -1, 1)

	frame.count = frame.iconHolder:CreateFontString(nil, "OVERLAY")
	frame.count:SetFontObject(NumberFontNormal)
	frame.count:SetPoint("BOTTOMRIGHT", frame.iconHolder, "BOTTOMRIGHT", -1, 0)

	local barHolder = CreateFrame('Frame', nil, frame)
	barHolder:SetPoint('BOTTOMLEFT', frame.iconHolder, 'BOTTOMRIGHT', self.gap, 0)
	barHolder:SetPoint('TOPRIGHT', frame, 'TOPRIGHT', 0, 0)
	barHolder:SetBackdrop({
        bgFile = [[Interface\BUTTONS\WHITE8X8]],
        edgeFile = [[Interface\BUTTONS\WHITE8X8]],
        tile = false,
        tileSize = 0,
        edgeSize = 1,
        insets =
        {
            left = 0,
            right = 0,
            top = 0,
            bottom = 0,
        },
    })
    barHolder:SetBackdropColor(0,0,0,0.5)
    barHolder:SetBackdropBorderColor(0,0,0)
	frame.barHolder = barHolder

	-- the main bar
	frame.statusBar = CreateFrame("StatusBar", nil, frame.barHolder)
	frame.statusBar:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
	frame.statusBar:SetAlpha(self.fgalpha or 1)
	frame.statusBar:SetPoint("TOPLEFT", frame.barHolder, "TOPLEFT", 1, -1)
	frame.statusBar:SetPoint("BOTTOMRIGHT", frame.barHolder, "BOTTOMRIGHT", -1, 1)

	local spark = frame.statusBar:CreateTexture(nil, "OVERLAY", nil);
	spark:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]]);
	spark:SetWidth(12);
	spark:SetBlendMode("ADD");
	spark:SetPoint('CENTER', frame.statusBar:GetStatusBarTexture(), 'RIGHT')
	frame.statusBar.spark = spark

	frame.statusBar.spelltime = frame.statusBar:CreateFontString(nil, 'ARTWORK')
	frame.statusBar.spellname = frame.statusBar:CreateFontString(nil, 'ARTWORK')

	--print("New Bar #" .. index)

	if self.PostCreateBar then
		self.PostCreateBar(frame)
	else
		frame.statusBar.spelltime:SetFont([[Fonts\FRIZQT__.TTF]], 10, "NONE")
		frame.statusBar.spelltime:SetTextColor(1 ,1, 1)
		frame.statusBar.spelltime:SetShadowOffset(1, -1)
	  frame.statusBar.spelltime:SetShadowColor(0, 0, 0)
		frame.statusBar.spelltime:SetJustifyH'RIGHT'
		frame.statusBar.spelltime:SetJustifyV'CENTER'
		frame.statusBar.spelltime:SetPoint'RIGHT'
		frame.statusBar.spellname:SetFont([[Fonts\FRIZQT__.TTF]], 10, "NONE")
		frame.statusBar.spellname:SetTextColor(1, 1, 1)
		frame.statusBar.spellname:SetShadowOffset(1, -1)
	  frame.statusBar.spellname:SetShadowColor(0, 0, 0)
		frame.statusBar.spellname:SetJustifyH'LEFT'
		frame.statusBar.spellname:SetJustifyV'CENTER'
		frame.statusBar.spellname:SetPoint'LEFT'
		frame.statusBar.spellname:SetPoint('RIGHT', frame.statusBar.spelltime, 'LEFT')
	end
	return frame
end

local UpdateIconAuras = function(self, cache, unit, index, filter, visible, isEnemy)
	if not unit then return; end

	local isDebuff = filter == DEBUFF_FILTER
	local timeNow = GetTime()
	local auras = self.Icons;

	local name, rank, texture, count, debuffType, duration, timeLeft, caster, isStealable, shouldConsolidate, spellID, canApplyAura, isBossDebuff;

	if(self.forceShow) then
		spellID = DEMO_SPELLS[random(1, #DEMO_SPELLS)];
		name, rank, texture = GetSpellInfo(spellID)
		count, debuffType, duration, timeLeft, caster, isStealable, shouldConsolidate, canApplyAura, isBossDebuff = 5, 'Magic', 0, 60, 'player', nil, nil, nil, nil
	else
		name, rank, texture, count, debuffType, duration, timeLeft, caster, isStealable, shouldConsolidate, spellID, canApplyAura, isBossDebuff = UnitAura(unit, index, filter);
	end

	if(name) then
		local show = true
		local isPlayer = false;
		if((not caster) or (caster == "player" or caster == "vehicle")) then isPlayer = true end;
		if(self.CustomFilter and (not self.forceShow)) then
			show = self:CustomFilter(isEnemy, isPlayer, name, spellID, debuffType, duration, shouldConsolidate)
		end

		if(show) then
			local i = visible + 1
			local this = auras[i]
			if(not this) then
				this = (self.CreateAuraIcon or CreateAuraIcon) (self, i)
				auras[i] = this
			end

			duration = duration or 0;
			timeLeft = timeLeft or 0;
			count = count or 0;
			local noTime = (duration == 0 and timeLeft == 0)
			--FOR TOOLTIPS
			this.unit = unit
			this.index = index
			this.filter = filter
			--FOR ONCLICK EVENTS
			this.name = name
			this.spellID = spellID
			--FOR ONUPDATE EVENTS
			this.expirationTime = timeLeft
			this.noTime = noTime

			this.icon:SetTexture(texture)
			this.count:SetText((count > 1 and count))

			this:Show()

			--SORTING CACHE
			local cached = {
				ref = i,
				noTime = noTime,
				duration = duration,
				expirationTime = timeLeft
			}
			tinsert(cache, cached)

			local cd = this.cooldown
			if(cd and not self.disableCooldown) then
				if(noTime) then
					cd:Hide()
				else
					cd:SetCooldown(timeLeft - duration, duration)
					cd:Show()
				end
			end

			if(isDebuff) then
				local color = DebuffTypeColor[debuffType] or DebuffTypeColor.none
				if((isEnemy) and (not isPlayer)) then
					this:SetBackdropBorderColor(0.9, 0.1, 0.1, 1)
					this.bg:SetBackdropColor(1, 0, 0, 1)
					this.icon:SetDesaturated((unit and not unit:find('arena%d')) and true or false)
				else
					this:SetBackdropBorderColor(color.r * 0.6, color.g * 0.6, color.b * 0.6, 1)
					this.bg:SetBackdropColor(color.r, color.g, color.b, 1)
					this.icon:SetDesaturated(false)
				end

				this.bg:SetBackdropBorderColor(0, 0, 0, 1)

				if(self.showType and this.overlay) then
					this.overlay:SetVertexColor(color.r, color.g, color.b)
					this.overlay:Show()
				else
					this.overlay:Hide()
				end
			else
				if((isStealable) and (isEnemy)) then
					this:SetBackdropBorderColor(0.92, 0.91, 0.55, 1)
					this.bg:SetBackdropColor(1, 1, 0.5, 1)
					this.bg:SetBackdropBorderColor(0, 0, 0, 1)
				else
					this:SetBackdropBorderColor(0, 0, 0, 1)
					this.bg:SetBackdropColor(0, 0, 0, 0)
					this.bg:SetBackdropBorderColor(0, 0, 0, 0)
				end
			end

			if(noTime) then
				this:SetScript('OnUpdate', nil)
				this.text:SetText('')
			else
				this.expirationTime = timeLeft
				this.expiration = timeLeft - timeNow
				this.nextUpdate = -1
				if(not this:GetScript('OnUpdate')) then
					this:SetScript('OnUpdate', AuraIcon_OnUpdate)
				end
			end

			return VISIBLE
		else
			return HIDDEN
		end
	end
end

local UpdateBarAuras = function(self, cache, unit, index, filter, visible, isEnemy)
	if not unit then return; end
	local isDebuff = filter == DEBUFF_FILTER
	local timeNow = GetTime()
	local auras = self.Bars;

	local name, rank, texture, count, debuffType, duration, timeLeft, caster, isStealable, shouldConsolidate, spellID, canApplyAura, isBossDebuff = UnitAura(unit, index, filter);

	if(self.forceShow) then
		spellID = DEMO_SPELLS[random(1, #DEMO_SPELLS)];
		name, rank, texture = GetSpellInfo(spellID)
		count, debuffType, duration, timeLeft, caster, isStealable, shouldConsolidate, canApplyAura, isBossDebuff = 5, 'Magic', 0, 60, 'player', nil, nil, nil, nil
	end

	if(name) then
		local show = true
		local isPlayer = false;
		if((not caster) or (caster == "player" or caster == "vehicle")) then isPlayer = true end;
		if((not self.forceShow) and self.CustomFilter) then
			show = self:CustomFilter(isEnemy, isPlayer, name, spellID, debuffType, duration, shouldConsolidate)
		end

		if(show) then
			local i = visible + 1
			local this = auras[i]
			if(not this) then
				this = (self.CreateAuraBar or CreateAuraBar) (self, i)
				auras[i] = this
			end

			duration = duration or 0;
			timeLeft = timeLeft or 0;
			count = count or 0;
			local noTime = (duration == 0 and timeLeft == 0)
			--FOR TOOLTIPS
			this.unit = unit
			this.index = index
			this.filter = filter
			--FOR ONCLICK EVENTS
			this.name = name
			this.spellID = spellID
			--FOR ONUPDATE EVENTS
			this.expirationTime = timeLeft
			this.noTime = noTime

			this.icon:SetTexture(texture)
			this.count:SetText((count > 1 and count))

			this:Show()

			--SORTING CACHE
			local cached = {
				ref = i,
				noTime = noTime,
				duration = duration,
				expirationTime = timeLeft
			}
			tinsert(cache, cached)

			local bar = this.statusBar
			if(noTime) then
				bar:SetMinMaxValues(0, 1)
				bar:SetValue(1)
				bar.spelltime:SetText('')
			else
				local value = timeLeft - timeNow
				bar:SetMinMaxValues(0, duration)
				bar:SetValue(value)
				bar.spelltime:SetText(value)
			end
			bar.spellname:SetText(count > 1 and format("%s [%d]", name, count) or name)

			if self.PostBarUpdate then
				self:PostBarUpdate(bar, spellID, isDebuff, debuffType)
			elseif(isDebuff) then
				bar:SetStatusBarColor(.9, 0, 0)
			else
				bar:SetStatusBarColor(.2, .6, 1)
			end

			return VISIBLE
		else
			return HIDDEN
		end
	end
end

local ParseIconAuras = function(self, unit)
	local limit = self.maxCount or 0;
	local filter = self.filtering;
	local index = 1;
	local visible = 0;
	local cache = {};
	local isEnemy = UnitIsEnemy('player', unit);

	while(visible < limit) do
		if(self.forceShow and visible > 8) then break end
		local result = UpdateIconAuras(self, cache, unit, index, filter, visible, isEnemy)
		if(not result) then
			break
		elseif(result == VISIBLE) then
			visible = visible + 1
		end

		index = index + 1
	end

	if(self.sort and type(self.sort) == 'function' and (#cache > 0)) then
		tsort(cache, self.sort)
		SetIconLayout(self, visible, cache)
	else
		SetIconLayout(self, visible)
	end
end

local ParseBarAuras = function(self, unit)
	local limit = self.maxCount or 0;
	local filter = self.filtering;
	local index = 1;
	local visible = 0;
	local cache = {};
	local isEnemy = UnitIsEnemy('player', unit);

	while(visible < limit) do
		if(self.forceShow and visible > 8) then break end
		local result = UpdateBarAuras(self, cache, unit, index, filter, visible, isEnemy)
		if(not result) then
			break
		elseif(result == VISIBLE) then
			visible = visible + 1
		end

		index = index + 1
	end

	if(self.sort and type(self.sort) == 'function' and (#cache > 0)) then
		tsort(cache, self.sort)
		SetBarLayout(self, visible, cache)
	else
		SetBarLayout(self, visible)
	end
end

--[[ SETUP AND ENABLE/DISABLE ]]--

local Update = function(self, event, unit)
	if((not unit) or (self.unit ~= unit)) then return end

	local buffs = self.Buffs
	if(buffs) then
		--if(self.unit == 'player') then print(event)print(buffs.UseBars) end
		if(buffs.UseBars and (buffs.UseBars == true)) then
			--if(self.unit == 'player') then print('Parsing BUFF BARS') end
			ParseBarAuras(buffs, unit)
		else
			--if(self.unit == 'player') then print('Parsing BUFF ICONS') end
			ParseIconAuras(buffs, unit)
		end
	end

	local debuffs = self.Debuffs
	if(debuffs) then
		--if(self.unit == 'player') then print(event)print(debuffs.UseBars) end
		if(debuffs.UseBars and (debuffs.UseBars == true)) then
			--if(self.unit == 'player') then print('Parsing DEBUFF BARS') end
			ParseBarAuras(debuffs, unit)
		else
			--if(self.unit == 'player') then print('Parsing DEBUFF ICONS') end
			ParseIconAuras(debuffs, unit)
		end
	end
end

local ForceUpdate = function(element)
	return Update(element.__owner, 'ForceUpdate', element.unit)
end

local Enable = function(self)
	if(self.Buffs or self.Debuffs) then
		self:RegisterEvent('UNIT_AURA', Update)

		local barsAvailable = self.AuraBarsAvailable;

		local buffs = self.Buffs
		if(buffs) then
			buffs.__owner 		= self;
			buffs.gap 			= buffs.gap or 2;
			buffs.spacing 		= buffs.spacing or 2;
			buffs.auraSize 		= buffs.auraSize or 16;
			buffs.maxRows 		= buffs.maxRows or 2;
			buffs.maxColumns 	= buffs.maxColumns or 8;
			buffs.maxCount 		= buffs.maxCount or 16;
			buffs.filtering 	= BUFF_FILTER;
			buffs.ForceUpdate 	= ForceUpdate;
			buffs.SetSorting 	= SetSorting;

			buffs:SetHeight(1)

			buffs.Icons = buffs.Icons or CreateFrame("Frame", nil, buffs)
			buffs.Icons:SetAllPoints(buffs)

			if(barsAvailable) then
				buffs.spark = true;
				buffs.UseBars = false;
				buffs.barHeight = buffs.barHeight or 16
				buffs.Bars = buffs.Bars or CreateFrame("Frame", nil, buffs)
				buffs.Bars:SetAllPoints(buffs)
				buffs.Bars:SetScript('OnUpdate', AuraBars_OnUpdate)
			end
		end

		local debuffs = self.Debuffs
		if(debuffs) then
			debuffs.__owner 	= self;
			debuffs.gap 		= debuffs.gap or 2;
			debuffs.spacing 	= debuffs.spacing or 2;
			debuffs.auraSize 	= debuffs.auraSize or 16;
			debuffs.maxRows 	= debuffs.maxRows or 2;
			debuffs.maxColumns 	= debuffs.maxColumns or 8;
			debuffs.maxCount 	= debuffs.maxCount or 16;
			debuffs.filtering 	= DEBUFF_FILTER;
			debuffs.ForceUpdate = ForceUpdate;
			debuffs.SetSorting 	= SetSorting;

			debuffs:SetHeight(1)

			debuffs.Icons = debuffs.Icons or CreateFrame("Frame", nil, debuffs)
			debuffs.Icons:SetAllPoints(debuffs)

			if(barsAvailable) then
				debuffs.spark = true;
				debuffs.UseBars = false;
				debuffs.barHeight = debuffs.barHeight or 16
				debuffs.Bars = debuffs.Bars or CreateFrame("Frame", nil, debuffs)
				debuffs.Bars:SetAllPoints(debuffs)
				debuffs.Bars:SetScript('OnUpdate', AuraBars_OnUpdate)
			end
		end

		return true
	end
end

local Disable = function(self)
	if(self.Buffs or self.Debuffs) then
		self:UnregisterEvent('UNIT_AURA', Update)
		if(self.Buffs and self.Buffs.Bars) then
			self.Buffs.Bars:SetScript('OnUpdate', nil)
		end
		if(self.Debuffs and self.Debuffs.Bars) then
			self.Debuffs.Bars:SetScript('OnUpdate', nil)
		end
	end
end

oUF:AddElement('Auras', Update, Enable, Disable)
