--[[
##########################################################
S V U I   By: Failcoder
##########################################################
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local unpack 	= _G.unpack;
local select 	= _G.select;
local pairs 	= _G.pairs;
local type 		= _G.type;
local tostring 	= _G.tostring;
local print 	= _G.print;
local pcall 	= _G.pcall;
local tinsert 	= _G.tinsert;
local string 	= _G.string;
local math 		= _G.math;
local table 	= _G.table;
--[[ STRING METHODS ]]--
local format,find = string.format, string.find;
--[[ MATH METHODS ]]--
local floor = math.floor;
--[[ TABLE METHODS ]]--
local twipe, tcopy = table.wipe, table.copy;
local IsAddOnLoaded = _G.IsAddOnLoaded;
local LoadAddOn = _G.LoadAddOn;
--BLIZZARD API
local InCombatLockdown      = _G.InCombatLockdown;
local CreateFrame           = _G.CreateFrame;
--[[
##########################################################
GET ADDON DATA
##########################################################
]]--
local SV = _G["SVUI"];
local L = SV.L
local MOD = SV.Skins;
if(not MOD) then return end;
local NewHook = hooksecurefunc;
local Schema = MOD.Schema;
local VERSION = MOD.Version;
--[[
##########################################################
CORE DATA
##########################################################
]]--
MOD.AddOnQueue = {};
MOD.AddOnEvents = {};
MOD.CustomQueue = {};
MOD.EventListeners = {};
MOD.OnLoadAddons = {};
MOD.SkinnedAddons = {};
MOD.Debugging = false;
MOD.DebugInternal = true;
MOD.DebugExternal = false;
--[[
##########################################################
CORE FUNCTIONS
##########################################################
]]--
local BLIZZCACHE = {};
local charming = {"Spiffy", "Pimped Out", "Fancy", "Awesome", "Bad Ass", "Sparkly", "Gorgeous", "Handsome", "Shiny"}
local styleMessage = '|cffFFAA00[Skinned]|r |cff00FF77%s|r Is Now %s!'

local function ListSkinnedAddons(msg, prefix)
	for style,_ in pairs(MOD.SkinnedAddons) do
		local verb = charming[math.random(1,#charming)]
		SV:AddonMessage(styleMessage:format(style, verb))
	end
end

function MOD:LoadAlert(MainText, Function)
	self.Alert.Text:SetText(MainText)
	self.Alert.Accept:SetScript('OnClick', Function)
	self.Alert:Show()
end

function MOD:Style(style, fn, ...)
	local pass, catch = pcall(fn, ...)
	if(catch and self.Debugging) then
		SV:HandleError("SKINS", style, catch);
	elseif(pass and (not style:find("Blizzard")) and (not style:find("CUSTOM")) and not self.SkinnedAddons[style]) then
		self.SkinnedAddons[style] = true
		return true;
	end
	return false;
end

function MOD:IsAddonReady(addon, ...)
	if not SV.db.Skins.addons then return end
	for i = 1, select('#', ...) do
		local a = select(i, ...)
		if not a then break end
		if not IsAddOnLoaded(a) then return false end
	end

	return SV.db.Skins.addons[addon]
end

function MOD:SaveAddonStyle(addon, fn, force, passive, ...)
	self:DefineEventFunction("PLAYER_ENTERING_WORLD", addon)
	if(passive) then
		self:DefineEventFunction("ADDON_LOADED", addon)
	end
	for i=1, select("#",...) do
		local event = select(i,...)
		if(event) then
			self:DefineEventFunction(event, addon)
		end
	end
	if(SV.defaults.Skins.addons and SV.defaults.Skins.addons[addon] == nil) then
		SV.defaults.Skins.addons[addon] = true
	end

	if force then
		fn()
	else
		self.AddOnQueue[addon] = fn
	end
end

function MOD:SaveBlizzardStyle(addon, fn, force)
	if force then
		if(not IsAddOnLoaded(addon)) then
			LoadAddOn(addon)
		end
		fn()
	else
		self.OnLoadAddons[addon] = fn
	end
end

function MOD:SaveCustomStyle(addon, fn)
	self.CustomQueue["CUSTOM_"..addon] = fn;
end

function MOD:DefineEventFunction(addonEvent, addon)
	if(not addon) then return end
	if(not self.EventListeners[addonEvent]) then
		self.EventListeners[addonEvent] = {}
	end
	self.EventListeners[addonEvent][addon] = true
	if(not self[addonEvent]) then
		self[addonEvent] = function(self, event, ...)
			for name,fn in pairs(self.AddOnQueue) do
				if self:IsAddonReady(name) and self.EventListeners[event] and self.EventListeners[event][name] then
					self.Debugging = self.DebugExternal
					self:Style(name, fn, event, ...)
					self.AddOnQueue[name] = nil
				end
			end
		end
		self:RegisterEvent(addonEvent);
	end
end

function MOD:SafeEventRemoval(addon, event)
	if not self.EventListeners[event] then return end
	if not self.EventListeners[event][addon] then return end
	self.EventListeners[event][addon] = nil;
	local defined = false;
	for name,_ in pairs(self.EventListeners[event]) do
		if name then
			defined = true;
			break
		end
	end
	if not defined then
		self:UnregisterEvent(event)
	end
end

function MOD:PLAYER_ENTERING_WORLD(event, ...)
	for name,fn in pairs(self.OnLoadAddons) do
		if(IsAddOnLoaded(name)) then
			self.Debugging = self.DebugInternal
			if(self:Style(name, fn, event, ...)) then
				self.OnLoadAddons[name] = nil
			end
		end
	end

	for name,fn in pairs(self.CustomQueue) do
		self.Debugging = self.DebugInternal
		if(self:Style(name, fn, event, ...)) then
			self.CustomQueue[name] = nil
		end
	end

	local listener = self.EventListeners[event]
	for name,fn in pairs(self.AddOnQueue)do
		if(SV.db.Skins.addons[name] == nil) then
			SV.db.Skins.addons[name] = true
		end
		if(listener[name] and self:IsAddonReady(name)) then
			self.Debugging = self.DebugExternal
			if(self:Style(name, fn, event, ...)) then
				self.AddOnQueue[name] = nil
			end
		end
	end

	SV.Events:Trigger("REQUEST_TEMPLATE_UPDATED");
end

function MOD:ADDON_LOADED(event, addon)
	--print(addon)
	local apiRefreshed = false;
	local needsUpdate = false
	for name, fn in pairs(self.OnLoadAddons) do
		if(addon:find(name)) then
			self.Debugging = self.DebugInternal
			if(not apiRefreshed) then
				SV:AppendAPI();
				apiRefreshed = true
			end
			if(self:Style(name, fn, event, addon)) then
				self.OnLoadAddons[name] = nil
				needsUpdate = true
			end
		end
	end

	local listener = self.EventListeners[event]
	if(listener) then
		for name, fn in pairs(self.AddOnQueue) do
			if(listener[name] and self:IsAddonReady(name)) then
				self.Debugging = self.DebugExternal
				if(not apiRefreshed) then
					SV:AppendAPI();
					apiRefreshed = true
				end
				if(self:Style(name, fn, event, addon)) then
					self.AddOnQueue[name] = nil
					needsUpdate = true
				end
			end
		end
	end

	-- if(addon == 'SVUI_!Options') then
	-- 	self:Style(addon, MOD.StyleSVUIOptions)
	-- end

	if(needsUpdate) then
		SV.Events:Trigger("REQUEST_TEMPLATE_UPDATED");
	end
end
--[[
##########################################################
CUSTOM HANDLERS
##########################################################
]]--
local AddonDockletToggle = function(self)
	if(not MOD.Docklet:IsShown()) then
		MOD.Docklet:Show()
	end
	if(not MOD.Docklet.Dock1:IsShown()) then
		MOD.Docklet.Dock1:Show()
	end
	if(not MOD.Docklet.Dock2:IsShown()) then
		MOD.Docklet.Dock2:Show()
	end
end

local ShowSubDocklet = function(self)
	local frame  = self.FrameLink
	if(frame and frame.Show) then
		if(InCombatLockdown() and (frame.IsProtected and frame:IsProtected())) then return end
		if(not frame:IsShown()) then
			frame:Show()
		end
	end
end

local HideSubDocklet = function(self)
	local frame  = self.FrameLink
	if(frame and frame.Hide) then
		if(InCombatLockdown() and (frame.IsProtected and frame:IsProtected())) then return end
		if(frame:IsShown()) then
			frame:Hide()
		end
	end
end

local function DockExpandDocklet(location)
	if(not location or (location ~= MOD.Docklet.Parent.Bar.Data.Location)) then return end
	MOD.Docklet:UpdateEmbeds()
end

local function DockFadeInDocklet(location)
	if(not location or (location ~= MOD.Docklet.Parent.Bar.Data.Location)) then return end
	local active = MOD.Docklet.Button.ActiveDocklet
	if(active) then
		MOD.Docklet.Dock1:Show()
		MOD.Docklet.Dock2:Show()
	end
end

local function DockFadeOutDocklet(location)
	if(not location or (location ~= MOD.Docklet.Parent.Bar.Data.Location)) then return end
	local active = MOD.Docklet.Button.ActiveDocklet
	if(active) then
		MOD.Docklet.Dock1:Hide()
		MOD.Docklet.Dock2:Hide()
	end
end
--[[
##########################################################
BUILD FUNCTION
##########################################################
]]--
function MOD:ReLoad()
	self:RegisterAddonDocklets()
end

function MOD:Load()
	SV.private.Docks = SV.private.Docks or {"None", "None"}
	
	-- ArtifactWatchBar
	ArtifactWatchBar:Hide();
	ArtifactWatchBar.OverlayFrame:Hide();
	MainMenuBar:Hide();		
			
	local alert = CreateFrame('Frame', nil, UIParent);
	alert:SetStyle("!_Frame", 'Transparent');
	alert:SetSize(250, 70);
	alert:SetPoint('CENTER', UIParent, 'CENTER');
	alert:SetFrameStrata('DIALOG');
	alert.Text = alert:CreateFontString(nil, "OVERLAY");
	alert.Text:SetFont(SV.media.font.dialog, 12);
	alert.Text:SetPoint('TOP', alert, 'TOP', 0, -10);
	alert.Accept = CreateFrame('Button', nil, alert);
	alert.Accept:SetSize(70, 25);
	alert.Accept:SetPoint('RIGHT', alert, 'BOTTOM', -10, 20);
	alert.Accept.Text = alert.Accept:CreateFontString(nil, "OVERLAY");
	alert.Accept.Text:SetFont(SV.media.font.dialog, 10);
	alert.Accept.Text:SetPoint('CENTER');
	alert.Accept.Text:SetText(_G.YES);
	alert.Close = CreateFrame('Button', nil, alert);
	alert.Close:SetSize(70, 25);
	alert.Close:SetPoint('LEFT', alert, 'BOTTOM', 10, 20);
	alert.Close:SetScript('OnClick', function(this) this:GetParent():Hide() end);
	alert.Close.Text = alert.Close:CreateFontString(nil, "OVERLAY");
	alert.Close.Text:SetFont(SV.media.font.dialog, 10);
	alert.Close.Text:SetPoint('CENTER');
	alert.Close.Text:SetText(_G.NO);
	alert.Accept:SetStyle("Button");
	alert.Close:SetStyle("Button");
	alert:Hide();

	self.Alert = alert;

	self.Docklet = SV.Dock:NewDocklet("BottomRight", "SVUI_SkinsDock", "Addon Docklet", [[Interface\AddOns\SVUI_Skins\artwork\DOCK-ICON-ADDON]]);
	--self.Docklet:SetVisibilityCallbacks(false, false);
	self.Docklet:SetClickCallbacks(AddonDockletToggle, false, self.GetAddonDockMenu);

	--SV.Dock.BottomRight.Bar.Button.GetDockOptions = self.GetAddonDockMenu;

	local dockWidth = self.Docklet:GetWidth()

	self.Docklet.Dock1 = CreateFrame("Frame", "SVUI_SkinsDockAddon1", self.Docklet);
	self.Docklet.Dock1:SetPoint('TOPLEFT', self.Docklet, 'TOPLEFT', -1, 0);
	self.Docklet.Dock1:SetPoint('BOTTOMLEFT', self.Docklet, 'BOTTOMLEFT', -1, -1);
	self.Docklet.Dock1:SetWidth(dockWidth);
	self.Docklet.Dock1:SetScript('OnShow', ShowSubDocklet);
	self.Docklet.Dock1:SetScript('OnHide', HideSubDocklet);

	self.Docklet.Dock2 = CreateFrame("Frame", "SVUI_SkinsDockAddon2", self.Docklet);
	self.Docklet.Dock2:SetPoint('TOPLEFT', self.Docklet.Dock1, 'TOPRIGHT', 0, 0);
	self.Docklet.Dock2:SetPoint('BOTTOMRIGHT', self.Docklet, 'BOTTOMRIGHT', 1, -1);
	self.Docklet.Dock2:SetWidth(dockWidth * 0.5);
	self.Docklet.Dock2:SetScript('OnShow', ShowSubDocklet);
	self.Docklet.Dock2:SetScript('OnHide', HideSubDocklet);

	self:SetEmbedHandlers()

	self.Docklet:Hide()

	self:RegisterAddonDocklets()

	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("ADDON_LOADED");

	SV:AddSlashCommand("skinned", "List all addons skinned by SVUI", ListSkinnedAddons);

	SV.Events:On("DOCK_FADE_IN", DockFadeInDocklet, true);
	SV.Events:On("DOCK_FADE_OUT", DockFadeOutDocklet, true);
	SV.Events:On("DOCK_EXPANDED", DockExpandDocklet, true);
end
