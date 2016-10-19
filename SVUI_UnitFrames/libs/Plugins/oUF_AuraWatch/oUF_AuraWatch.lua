--GLOBAL NAMESPACE
local _G = _G;
--LUA
local unpack        = _G.unpack;
local select        = _G.select;
local assert        = _G.assert;
local error         = _G.error;
local print         = _G.print;
local pairs         = _G.pairs;
local next          = _G.next;
local tostring      = _G.tostring;
local setmetatable  = _G.setmetatable;
--STRING
local string        = _G.string;
local format        = string.format;
--MATH
local math          = _G.math;
local floor         = math.floor
local ceil          = math.ceil
--BLIZZARD API
local GetTime       	= _G.GetTime;
local CreateFrame       = _G.CreateFrame;
local UnitAura         	= _G.UnitAura;
local GetSpellInfo      = _G.GetSpellInfo;
local NumberFontNormal  = _G.NumberFontNormal;

local _, ns = ...
local oUF = oUF or ns.oUF
assert(oUF, "oUF_AuraWatch cannot find an instance of oUF. If your oUF is embedded into a layout, it may not be embedded properly.")

local UnitBuff, UnitDebuff, UnitGUID = UnitBuff, UnitDebuff, UnitGUID
local CACHED_GUIDS = {};
local CACHED_IDS = {};
local PLAYER_UNITS = {
	player = true,
	vehicle = true,
	pet = true,
};
local COUNT_OFFSETS = {
	["TOPLEFT"] = {6, 1}, 
	["TOPRIGHT"] = {-6, 1}, 
	["BOTTOMLEFT"] = {6, 1}, 
	["BOTTOMRIGHT"] = {-6, 1}, 
	["LEFT"] = {6, 1}, 
	["RIGHT"] = {-6, 1}, 
	["TOP"] = {0, 0}, 
	["BOTTOM"] = {0, 0}, 
};
local TEXT_OFFSETS = {
	["TOPLEFT"] = {"LEFT", "RIGHT", -2, 0}, 
	["TOPRIGHT"] = {"RIGHT", "LEFT", 2, 0}, 
	["BOTTOMLEFT"] = {"LEFT", "RIGHT", -2, 0}, 
	["BOTTOMRIGHT"] = {"RIGHT", "LEFT", 2, 0}, 
	["LEFT"] = {"LEFT", "RIGHT", -2, 0}, 
	["RIGHT"] = {"RIGHT", "LEFT", 2, 0}, 
	["TOP"] = {"RIGHT", "LEFT", 2, 0}, 
	["BOTTOM"] = {"RIGHT", "LEFT", 2, 0}, 
};

local setupGUID
do 
	local cache = setmetatable({}, {__type = "k"})

	local frame = CreateFrame"Frame"
	frame:SetScript("OnEvent", function(self, event)
		for k,t in pairs(CACHED_GUIDS) do
			CACHED_GUIDS[k] = nil
			for a in pairs(t) do
				t[a] = nil
			end
			cache[t] = true
		end
	end)
	frame:RegisterEvent"PLAYER_REGEN_ENABLED"
	frame:RegisterEvent"PLAYER_ENTERING_WORLD"
	
	function setupGUID(guid)
		local t = next(cache)
		if t then
			cache[t] = nil
		else
			t = {}
		end
		CACHED_GUIDS[guid] = t
	end
end

local day, hour, minute, second = 86400, 3600, 60, 1;

local function formatTime(s)
	if s >= day then
		return format("%dd", ceil(s / hour))
	elseif s >= hour then
		return format("%dh", ceil(s / hour))
	elseif s >= minute then
		return format("%dm", ceil(s / minute))
	elseif s >= 5 then
		return floor(s)
	end
	
	return format("%.1f", s)
end

local function updateText(self, elapsed)
	if self.timeLeft then
		self.elapsed = (self.elapsed or 0) + elapsed
		if self.elapsed >= 0.1 then
			if not self.first then
				self.timeLeft = self.timeLeft - self.elapsed
			else
				self.timeLeft = self.timeLeft - GetTime()
				self.first = false
			end
			if self.timeLeft > 0 and ((self.timeLeft <= self.textThreshold) or self.textThreshold == -1) then
				local time = formatTime(self.timeLeft)
				self.text:SetText(time)
			else
				self.text:SetText('')
				self:SetScript("OnUpdate", nil)
			end
			self.elapsed = 0
		end
	end
end


local function resetIcon(icon, frame, count, duration, remaining)
	if icon.onlyShowMissing then
		icon:Hide()
	else
		icon:Show()
		if icon.cooldown then
			if duration and duration > 0 and icon.style ~= 'NONE' then
				icon.cooldown:SetCooldown(remaining - duration, duration)
				icon.cooldown:Show()
			else
				icon.cooldown:Hide()
			end
		end

		if icon.displayText then
			icon.timeLeft = remaining
			icon.first = true;
			icon:SetScript('OnUpdate', updateText)
		end

		if icon.count then
			icon.count:SetText((count > 1 and count))
		end
		if icon.overlay then
			icon.overlay:Hide()
		end
		icon:SetAlpha(icon.presentAlpha)
	end
end

local function expireIcon(icon, frame)
	if icon.onlyShowPresent then
		icon:Hide()
	else
		if (icon.cooldown) then icon.cooldown:Hide() end
		if (icon.count) then icon.count:SetText() end
		icon:SetAlpha(icon.missingAlpha)
		if icon.overlay then
			icon.overlay:Show()
		end
		icon:Show()
	end
end

local Update = function(self, event, unit)
	if self.unit ~= unit or not unit then return end 
	local watch = self.AuraWatch
	local index, watching = 1, watch.Active

	local guid = UnitGUID(unit)
	if not guid then return end
	if not CACHED_GUIDS[guid] then setupGUID(guid) end
	
	for _, aura in pairs(watching) do
		if not aura.onlyShowMissing then
			aura:Hide()
		end
	end
	
	local _, name, texture, count, duration, remaining, caster, key, aura, spellID;
	local filter = "HELPFUL";
	while true do
		name, _, texture, count, _, duration, remaining, caster, _, _, spellID = UnitAura(unit, index, filter)
		if not name then 
			if filter == "HELPFUL" then
				filter = "HARMFUL"
				index = 1
			else
				break
			end
		else
			if watch.strictMatching then
				key = spellID
			else
				key = name..texture
			end
			aura = watching[key]

			if aura and (aura.anyUnit or (caster and aura.fromUnits and aura.fromUnits[caster])) then
				resetIcon(aura, watch, count, duration, remaining)
				CACHED_GUIDS[guid][key] = true
				CACHED_IDS[key] = true
			end
			index = index + 1
		end
	end
	
	for cacheKey in pairs(CACHED_GUIDS[guid]) do
		if watching[cacheKey] and not CACHED_IDS[cacheKey] then
			expireIcon(watching[cacheKey], watch)
		end
	end
	
	for cacheKey in pairs(CACHED_IDS) do
		CACHED_IDS[cacheKey] = nil
	end
end

local UpdateIcons = function(self)
	local auras = self.Cache
	
	for _,aura in pairs(auras) do
	
		local name, _, image = GetSpellInfo(aura.spellID)

		if name then
			aura.name = name
		
			if not aura.cooldown and not (self.hideCooldown or aura.hideCooldown) then
				local cd = CreateFrame("Cooldown", nil, aura, "CooldownFrameTemplate")
				cd:SetAllPoints(aura)
				aura.cooldown = cd
			end

			if not aura.icon then
				local tex = aura:CreateTexture(nil, "BACKGROUND")
				tex:SetAllPoints(aura)
				tex:SetTexture(image)
				aura.icon = tex
				if not aura.overlay then
					local overlay = aura:CreateTexture(nil, "OVERLAY")
					overlay:SetTexture"Interface\\Buttons\\UI-Debuff-Overlays"
					overlay:SetAllPoints(aura)
					overlay:SetTexCoord(.296875, .5703125, 0, .515625)
					overlay:SetVertexColor(1, 0, 0)
					aura.overlay = overlay
				end
			end

			if not aura.count and not (self.hideCount or aura.hideCount) then
				local count = aura:CreateFontString(nil, "OVERLAY")
				count:SetFontObject(NumberFontNormal)
				count:SetPoint("BOTTOMRIGHT", aura, "BOTTOMRIGHT", -1, 0)
				aura.count = count
			end

			if aura.onlyShowMissing == nil then
				aura.onlyShowMissing = self.onlyShowMissing
			end
			if aura.onlyShowPresent == nil then
				aura.onlyShowPresent = self.onlyShowPresent
			end
			if aura.presentAlpha == nil then
				aura.presentAlpha = self.presentAlpha
			end
			if aura.missingAlpha == nil then
				aura.missingAlpha = self.missingAlpha
			end		
			if aura.fromUnits == nil then
				aura.fromUnits = self.fromUnits or PLAYER_UNITS
			end
			if aura.anyUnit == nil then
				aura.anyUnit = self.anyUnit
			end
			
			if self.strictMatching then
				self.Active[aura.spellID] = aura
			else
				self.Active[name..image] = aura
			end

			if self.PostCreateIcon then self:PostCreateIcon(aura, aura.spellID, name, self) end
		--else
			--print("oUF_AuraWatch error: no spell with "..tostring(aura.spellID).." spell ID exists")
		end
	end
end

local ForceUpdate = function(self)
	if self.PreForcedUpdate then self:PreForcedUpdate() end
	local frame = self:GetParent()

	if(not self.watchEnabled) then
		self:Hide();
		return;
	else
		self:Show();
	end
	
	local watchsize = self.watchSize;
	local watchfilter = self.watchFilter;

	if(watchfilter) then
		if self.Cache then 
			for i = 1, #self.Cache do 
				local iconTest = false;
				for id, data in pairs(watchfilter) do 
					if(data.id and (data.id == self.Cache[i])) then 
						iconTest = true;
						break 
					end 
				end 
				if not iconTest then 
					self.Cache[i]:Hide()
					self.Cache[i] = nil 
				end 
			end 
		end

		for stringID, data in pairs(watchfilter) do
			local id = data.id;
			local buffName, _, buffTexture = GetSpellInfo(id)
			if buffName then 
				local aura;
				if not self.Cache[id] then 
					aura = CreateFrame("Frame", nil, self)
				else 
					aura = self.Cache[id]
				end 
				aura.name = buffName;
				aura.image = buffTexture;
				aura.spellID = id;
				aura.anyUnit = data.anyUnit;
				aura.style = data.style or "NONE";
				aura.onlyShowMissing = data.onlyShowMissing;
				aura.presentAlpha = aura.onlyShowMissing and 0 or 1;
				aura.missingAlpha = aura.onlyShowMissing and 1 or 0;
				aura.textThreshold = data.textThreshold or -1;
				aura.displayText = data.displayText;
				aura:SetWidth(watchsize)
				aura:SetHeight(watchsize)
				aura:ClearAllPoints()

				aura:SetPoint(data.point, frame.Health, data.point, data.xOffset, data.yOffset)
				if not aura.icon then 
					aura.icon = aura:CreateTexture(nil, "BORDER")
					aura.icon:SetAllPoints(aura)
				end  
				if not aura.border then 
					aura.border = aura:CreateTexture(nil, "BACKGROUND")
					aura.border:SetPoint("TOPLEFT", -1, 1)
					aura.border:SetPoint("BOTTOMRIGHT", 1, -1)
					aura.border:SetTexture([[Interface\BUTTONS\WHITE8X8]])
					aura.border:SetVertexColor(0, 0, 0)
				end 
				if not aura.cooldown then 
					aura.cooldown = CreateFrame("Cooldown", nil, aura, "CooldownFrameTemplate")
					aura.cooldown:SetAllPoints(aura)
					aura.cooldown:SetReverse(true)
					aura.cooldown:SetHideCountdownNumbers(true)
					aura.cooldown:SetFrameLevel(aura:GetFrameLevel())
				end
				if not aura.grip then 
					aura.grip = CreateFrame("Frame", nil, aura);
					aura.grip:SetAllPoints(aura);
				end
				if not aura.text then 
					aura.text = aura.grip:CreateFontString(nil, "BORDER");
					aura.text:SetFontObject(NumberFontNormal);
				end
				if not aura.count then 
					aura.count = aura.grip:CreateFontString(nil, "OVERLAY");
					aura.count:SetFontObject(NumberFontNormal);
				end

				if(aura.style == "coloredIcon") then 
					aura.icon:SetTexture([[Interface\BUTTONS\WHITE8X8]])
					if(data.color) then 
						aura.icon:SetVertexColor(data.color.r, data.color.g, data.color.b)
					else 
						aura.icon:SetVertexColor(0.8, 0.8, 0.8)
					end 
					aura.icon:Show()
					aura.border:Show()
					aura.cooldown:SetAlpha(1)
				elseif(aura.style == "texturedIcon") then 
					aura.icon:SetVertexColor(1, 1, 1)
					aura.icon:SetTexCoord(.18, .82, .18, .82)
					aura.icon:SetTexture(aura.image)
					aura.icon:Show()
					aura.border:Show()
					aura.cooldown:SetAlpha(1)
				else 
					aura.border:Hide()
					aura.icon:Hide()
					aura.cooldown:SetAlpha(0)
				end

				if aura.displayText then 
					aura.text:Show()
					local r, g, b = 1, 1, 1;
					if(data.textColor) then 
						r, g, b = data.textColor.r, data.textColor.g, data.textColor.b
					end 
					aura.text:SetTextColor(r, g, b)
				else 
					aura.text:Hide()
				end 

				aura.text:ClearAllPoints();
				aura.text:SetPoint(data.point, aura, data.point);
				aura.count:ClearAllPoints()
				if aura.displayText then 
					local anchor, relative, x, y = unpack(TEXT_OFFSETS[data.point])
					aura.count:SetPoint(anchor, aura.text, relative, x, y)
				else 
					aura.count:SetPoint("CENTER", unpack(COUNT_OFFSETS[data.point]))
				end

				if(not data.enable) then 
					self.Cache[id] = nil;
					if self.Active then 
						self.Active[id] = nil 
					end 
					aura:Hide()
					aura = nil 
				else
					self.Cache[id] = aura;
					if self.Active then 
						self.Active[id] = aura 
					end
				end 
			end
		end
	end
	self:UpdateIcons()
end 

local Enable = function(self)
	local watch = self.AuraWatch;
	if watch then
		watch.__owner = self
		watch.UpdateIcons = UpdateIcons
		watch.ForceUpdate = ForceUpdate
		watch.Cache = {}
		watch.Active = {}

		self:RegisterEvent("UNIT_AURA", Update)

		watch:ForceUpdate()

		return true
	else
		return false
	end
end

local Disable = function(self)
	local watch = self.AuraWatch;
	if watch then

		self:UnregisterEvent("UNIT_AURA", Update)

		for _,icon in pairs(watch.Cache) do
			icon:Hide()
		end
	end
end

oUF:AddElement("AuraWatch", Update, Enable, Disable)
