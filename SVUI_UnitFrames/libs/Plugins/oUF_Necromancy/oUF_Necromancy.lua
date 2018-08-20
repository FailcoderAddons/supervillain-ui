if select(2, UnitClass("player")) ~= "DEATHKNIGHT" then return end


local parent, ns = ...
local oUF = ns.oUF
local floor = math.floor

local runeColors = {
	{0.75, 0, 0},   -- blood
	{0, 0.75, 1},   -- frost
	{0.1, 0.75, 0},  -- unholy
	{0.75, 0, 1}, -- death
}

local runemap = { 1, 2, 5, 6, 3, 4 }
local BLOOD_OF_THE_NORTH = 54637
local OnUpdate = function(self, elapsed)
	local duration = self.duration + elapsed
	if(duration >= self.max) then
		return self:SetScript("OnUpdate", nil)
	else
		self.duration = duration
		return self:SetValue(duration)
	end
end

local spellName = GetSpellInfo(54637)
local UpdateType = function(self, event, rid)
	local spec = GetSpecialization()
	local isUsable = IsUsableSpell(spellName)
	local rune = self.Necromancy[rid]
	local colors = runeColors[spec]
	if (rune and colors) then
		local r, g, b = colors[1], colors[2], colors[3]
		rune.bar:SetStatusBarColor(r, g, b)
		if(rune.bar.Change) then
			rune.bar:Change(rid)
		end
	end
end

local UpdateRune = function(self, event, rid)
	local rune = self.Necromancy[rid]
	if(rune) then
		local start, duration, runeReady = GetRuneCooldown(rid)
		start = start or 0;
		duration = duration or 1;
		if(runeReady) then
			rune.bar:SetMinMaxValues(0, 1)
			rune.bar:SetValue(1)
			rune.bar:SetScript("OnUpdate", nil)
		else
			rune.bar.duration = GetTime() - start
			rune.bar.max = duration
			rune.bar:SetMinMaxValues(1, duration)
			rune.bar:SetScript("OnUpdate", OnUpdate)
		end
	end
end

local Update = function(self, event)
	for i=1, 6 do
		UpdateRune(self, event, i)
	end
end

local function UpdateAllRuneTypes(self)
	if(self) then
		for i=1, 6 do
			UpdateType(self, nil, i)
		end
	end
end

local ForceUpdate = function(element)
	return Update(element.__owner, 'ForceUpdate')
end

local Enable = function(self, unit)
	local runes = self.Necromancy
	if(runes and unit == 'player') then
		runes.__owner = self
		runes.ForceUpdate = ForceUpdate
		self:RegisterEvent("PLAYER_TALENT_UPDATE", UpdateAllRuneTypes)
		self:RegisterEvent("RUNE_POWER_UPDATE", UpdateRune, true)
		--self:RegisterEvent("RUNE_TYPE_UPDATE", UpdateType, true)	--8.0.1
		self:RegisterEvent("PLAYER_ENTERING_WORLD", UpdateAllRuneTypes)

		if not runes.UpdateAllRuneTypes then runes.UpdateAllRuneTypes = UpdateAllRuneTypes end

		for i=1, 6 do
			UpdateType(self, nil, i)
		end

		RuneFrame.Show = RuneFrame.Hide
		RuneFrame:Hide()

		return true
	end
end

local Disable = function(self)
	RuneFrame.Show = nil
	RuneFrame:Show()


	local runes = self.Necromancy
	if(runes) then
		runes:SetScript('OnUpdate', nil)
		self:UnregisterEvent("PLAYER_TALENT_UPDATE", UpdateAllRuneTypes)
		self:UnregisterEvent("RUNE_POWER_UPDATE", UpdateRune)
		--self:UnregisterEvent("RUNE_TYPE_UPDATE", UpdateType) -- 8.0.1
		self:UnregisterEvent("PLAYER_ENTERING_WORLD", UpdateAllRuneTypes)
	end
end

oUF:AddElement("Necromancy", Update, Enable, Disable)
