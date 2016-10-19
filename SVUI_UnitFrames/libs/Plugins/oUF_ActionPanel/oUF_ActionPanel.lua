--GLOBAL NAMESPACE
local _G = _G;
--LUA
local unpack        = _G.unpack;
local select        = _G.select;
local assert        = _G.assert;
local type         	= _G.type;
--BLIZZARD API
local UnitIsConnected 		= _G.UnitIsConnected;
local UnitIsTapDenied       = _G.UnitIsTapDenied;
local UnitIsPlayer       	= _G.UnitIsPlayer;
local UnitIsFriend       	= _G.UnitIsFriend;
local UnitIsDeadOrGhost  	= _G.UnitIsDeadOrGhost;
local UnitClassification 	= _G.UnitClassification;

local parent, ns = ...
local oUF = ns.oUF

local textureCopy;

local Update = function(self, event, unit)
	if(self.unit ~= unit) or not unit then return end
	local action = self.ActionPanel
	--local border = action.border
	local special = action.special
	local class = action.class
	local showSpecial = false
	local react = UnitReaction("player", unit)
	local canShowSpecial = (react and (react < 5)) or false;
	local r,g,b = 0,0,0;
	local category = UnitClassification(unit)

	if(UnitIsDeadOrGhost(unit)) then
		r,g,b = 0.15,0.1,0.2;
	else
		if(category == "elite") then
			r,g,b = 1,0.75,0;
			showSpecial = canShowSpecial
		elseif(category == "rare" or category == "rareelite") then
			r,g,b = 0.59,0.79,1;
			showSpecial = canShowSpecial
		end
	end

	if(action.border) then
		action.border[1]:SetTexture(r,g,b)
		action.border[2]:SetTexture(r,g,b)
		action.border[3]:SetTexture(r,g,b)
		action.border[4]:SetTexture(r,g,b)
	end

	if(special) then
		if(showSpecial) then
			special[1]:SetVertexColor(r,g,b)
			special[2]:SetVertexColor(r,g,b)
			--special[3]:SetVertexColor(r,g,b)
			special:Show()
		else
			special:Hide()
		end
	end

	if(class and class:IsShown()) then
		local className, classFileName = UnitClass(unit)
		local coords = CLASS_ICON_TCOORDS[classFileName]
		if(coords) then
			class:Show()
			class.texture:SetTexCoord(unpack(coords))
		else
			class:Hide()
		end
	end

	local status = self.StatusPanel
	if(status) then
		local texture = status.texture
		local media = status.media

		if(not UnitIsConnected(unit)) then
			texture:SetAlpha(1)
			texture:SetTexture(media[1])
			--texture:SetGradient("VERTICAL",0,1,1,1,1,0)
		elseif(UnitIsDeadOrGhost(unit)) then
			texture:SetAlpha(1)
			texture:SetTexture(media[2])
			--texture:SetGradient("VERTICAL",0,0,1,0,1,0)
		elseif(unit ~= "player" and (unit ~= "vehicle" and (not UnitIsFriend(unit, "player")) and (not UnitIsPlayer(unit)) and UnitIsTapDenied(unit))) then
			texture:SetAlpha(1)
			texture:SetTexture(media[3])
			--texture:SetGradient("VERTICAL",1,1,0,1,0,0)
		else
			texture:SetColorTexture(0,0,0,0)
		end
	end
end

local Path = function(self, ...)
	return (self.ActionPanel.Override or Update) (self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local Enable = function(self, unit)
	local action = self.ActionPanel
	if(action) then
		action.__owner = self
		action.ForceUpdate = ForceUpdate
		local status = self.StatusPanel
		if(status and status.texture) then
			self:RegisterEvent('UNIT_FLAGS', Path)
			self:RegisterEvent('UNIT_FACTION', Path)
		end
		self:RegisterEvent("UNIT_TARGET", Path, true)
		self:RegisterEvent("PLAYER_TARGET_CHANGED", Path, true)
		return true
	end
end

local Disable = function(self)
	local action = self.ActionPanel
	if(action) then
		local status = self.StatusPanel
		if(status) then
			if(self:IsEventRegistered("UNIT_FLAGS")) then
				self:UnregisterEvent("UNIT_FLAGS", Path)
			end
			if(self:IsEventRegistered("UNIT_FACTION")) then
				self:UnregisterEvent("UNIT_FACTION", Path)
			end
		end
		if(self:IsEventRegistered("PLAYER_TARGET_CHANGED")) then
			self:UnregisterEvent("PLAYER_TARGET_CHANGED", Path)
		end
		if(self:IsEventRegistered("UNIT_TARGET")) then
			self:UnregisterEvent("UNIT_TARGET", Path)
		end
	end
end

oUF:AddElement('ActionPanel', Path, Enable, Disable)
