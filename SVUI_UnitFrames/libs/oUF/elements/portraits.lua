--[[ Element: Portraits

	THIS FILE HEAVILY MODIFIED FOR USE WITH SUPERVILLAIN UI

]]
--GLOBAL NAMESPACE
local _G = _G;
--LUA
local unpack        = _G.unpack;
local select        = _G.select;
local assert        = _G.assert;
--BLIZZARD API
local UnitClass     			= _G.UnitClass;
local UnitReaction     			= _G.UnitReaction;
local UnitGUID     				= _G.UnitGUID;
local UnitIsUnit     			= _G.UnitIsUnit;
local UnitExists     			= _G.UnitExists;
local UnitIsVisible     		= _G.UnitIsVisible;
local UnitIsConnected			= _G.UnitIsConnected;
local UnitIsPlayer 				= _G.UnitIsPlayer;
local SetPortraitTexture 		= _G.SetPortraitTexture;

local parent, ns = ...
local oUF = ns.oUF

local Update = function(self, event, unit, forced)
	if(self.unit ~= unit) or not unit then return end

	local portrait = self.Portrait
	if(portrait.PreUpdate) then portrait:PreUpdate(unit) end

	if(portrait:IsObjectType'Model') then
		local guid = UnitGUID(unit)
		local camera = portrait.UserCamDistance or 1
		local rotate = portrait.UserRotation

		if(not UnitExists(unit) or not UnitIsConnected(unit) or not UnitIsVisible(unit)) then
			portrait:SetCamDistanceScale(1)
			portrait:SetPortraitZoom(0)
			portrait:SetPosition(4,-1,1)
			portrait:ClearModel()
			portrait:SetModel([[Spells\Monk_travelingmist_missile.m2]])
			portrait.guid = nil
			portrait:SetBackdropColor(0.25,0.25,0.25)
			if portrait.UpdateColor then
				portrait:UpdateColor(0.25,0.25,0.25)
			end
		elseif((forced) or (portrait.guid ~= guid) or (event == 'UNIT_MODEL_CHANGED')) then
			portrait:ClearModel()
			portrait:SetUnit(unit)
			portrait:SetCamDistanceScale(camera)
			portrait:SetPortraitZoom(1)
			portrait:SetPosition(0,0,0)
			portrait.guid = guid

			if(rotate and (portrait:GetFacing() ~= (rotate / 60))) then
				portrait:SetFacing(rotate / 60)
			end

			local r, g, b, color = 0.25, 0.25, 0.25
			if not UnitIsPlayer(unit)then
				color = self.colors.reaction[UnitReaction(unit,"player")]
				if(color ~= nil) then
					r,g,b = color[1]*0.35, color[2]*0.35, color[3]*0.35
				end
			else
				local _,unitClass = UnitClass(unit)
				if unitClass then
					color = self.colors.class[unitClass]
					r,g,b = color[1]*0.65, color[2]*0.65, color[3]*0.65
				end
			end
			portrait:SetBackdropColor(r,g,b)
			if portrait.UpdateColor then
				portrait:UpdateColor(r,g,b)
			end
			portrait:RefreshCamera()
		end
	else
		SetPortraitTexture(portrait, unit)
	end

	if(portrait.PostUpdate) then
		return portrait:PostUpdate(unit)
	end
end

local Path = function(self, ...)
	return (self.Portrait.Override or Update) (self, ...)
end

local ForceTargetUpdate = function(self)
	local portrait = self.Portrait
	if(not portrait.__owner) then return end
	return Path(portrait.__owner, 'ForceUpdate', portrait.__owner.unit)
end

local ForceUpdate = function(element)
	if(not element.__owner) then return end
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local Enable = function(self, unit)
	local portrait = self.Portrait
	if(portrait) then
		portrait.__owner = self
		portrait.ForceUpdate = ForceUpdate

		self:RegisterEvent("UNIT_PORTRAIT_UPDATE", Path)
		self:RegisterEvent("UNIT_MODEL_CHANGED", Path)
		self:RegisterEvent('UNIT_CONNECTION', Path)
		if(unit == 'target' or unit == 'targettarget') then
			self:RegisterEvent('PLAYER_TARGET_CHANGED', ForceTargetUpdate)
		end
		-- The quest log uses PARTY_MEMBER_{ENABLE,DISABLE} to handle updating of
		-- party members overlapping quests. This will probably be enough to handle
		-- model updating.
		--
		-- DISABLE isn't used as it fires when we most likely don't have the
		-- information we want.
		if(unit == 'party') then
			self:RegisterEvent('PARTY_MEMBER_ENABLE', Path)
		end

		return true
	end
end

local Disable = function(self)
	local portrait = self.Portrait
	if(portrait) then
		self:UnregisterEvent("UNIT_PORTRAIT_UPDATE", Path)
		self:UnregisterEvent("UNIT_MODEL_CHANGED", Path)
		self:UnregisterEvent('PARTY_MEMBER_ENABLE', Path)
		self:UnregisterEvent('UNIT_CONNECTION', Path)
		self:UnregisterEvent('PLAYER_TARGET_CHANGED', ForceTargetUpdate)
	end
end

oUF:AddElement('Portrait', Path, Enable, Disable)
