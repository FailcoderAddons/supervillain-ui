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
--[[
##########################################################
GET ADDON DATA
##########################################################
]]--
local SV = _G['SVUI'];
local L = SV.L;
local MOD = SV.Skins;
local Schema = MOD.Schema;
local Librarian = _G.Librarian;
--[[
##########################################################
LOCALS
##########################################################
]]--
local TIP_RIGHT_PATTERN = " and %s";
local DOCK_EMBEDS = {};
local DOCK_LISTING = {};
--[[
##########################################################
HELPERS
##########################################################
]]--
local function SafeStringFind(request,value)
	if((not request) or (type(request) == 'table') or (not request.find)) then return false end
	return request:find(value);
end

local function RequestEmbedded(addon)
	local embed1 = SV.private.Docks.Embed1 or "None";
	local embed2 = SV.private.Docks.Embed2 or "None";
	local enabled1 = (embed1 ~= "None")
	local enabled2 = ((embed2 ~= "None") and (embed2 ~= embed1))

	if(addon) then
		local valid = false;
		if(embed1:find(addon) or embed2:find(addon)) then
			valid = true
		end
		return valid, enabled1, enabled2
	end

	return embed1, embed2, enabled1, enabled2
end
--[[
##########################################################
SKADA
##########################################################
]]--
local Skada_PointLock = function(self, a1, p, a2, x, y)
	local parent = self:GetParent()
	if(parent and parent.GetName) then
		local pname = parent:GetName()
		if(((x ~= 0) or (y ~= 0)) and pname:find('SVUI')) then
			self:ClearAllPoints()
			self:SetPoint("BOTTOM", p, "BOTTOM", 0, 0)
		end
	end
end

local Skada_PointTest = function(self, p1, p2, p3, p4, p5)
	print(p1 .. ", " .. p2:GetName() .. ", " .. p3 .. ", " .. p4 .. ", " .. p5)
end

DOCK_EMBEDS["Skada"] = function(self)
	if((not IsAddOnLoaded("Skada")) or (not _G.Skada)) then return false end

	local assigned,otherAssigned = self:EmbedCheck();
	local width = self:GetWidth()
	local height = SV.Dock.BottomRight.Window:GetHeight();
	local frameLinked = false;

	for index,window in pairs(Skada:GetWindows()) do
		if(window) then
			local wname = window.db.name or "Skada"
			local key = "SkadaBarWindow" .. wname
			if(assigned ~= 'None' and (assigned:find(key))) then
				--Librarian:LockLibrary('LibWindow');
				local db = window.db

				if(db) then
					local curHeight = 0
					if(db.enabletitle) then
						curHeight = db.title.height
					end
					db.barspacing = 1;
					db.barwidth = width - 10;
					db.background.height = (height - curHeight) - 8;
					db.spark = false;
					db.barslocked = true;
				end

				local parentFrame = window.bargroup:GetParent();
				if(not window.bargroup.___oldParent) then
					if(parentFrame ~= self) then
						window.bargroup.___oldParent = window.bargroup:GetParent()
					else
						window.bargroup.___oldParent = UIParent
					end
				end

				window.bargroup:SetParent(self)
				window.bargroup:ClearAllPoints()
				window.bargroup:SetSize(width, height)
				window.bargroup:SetPoint("BOTTOM", self, "BOTTOM", 0, 0)
				window.bargroup:SetFrameStrata('LOW')

				if(not window.bargroup.___skinHooked) then
					hooksecurefunc(window.bargroup, "SetPoint", Skada_PointLock)
					window.bargroup.___skinHooked = true;
				end

				local bgroup = window.bargroup.backdrop;
				if(bgroup) then
					bgroup:Show()
					if(not bgroup.Panel) then
						bgroup:SetStyle("!_Frame", 'Transparent', true)
					end
				end

				self.FrameLink = window;
				frameLinked = true;

				Skada.displays['bar']:ApplySettings(window)

				return true
			elseif(not otherAssigned:find(key)) then
				--Librarian:UnlockLibrary('LibWindow');
				window.db.barslocked = false;
				window.bargroup:SetParent(window.bargroup.___oldParent or UIParent)
			end
		end
	end

	if(not frameLinked) then
		self.FrameLink = nil;
	end

	return false
end
--[[
##########################################################
RECOUNT
##########################################################
]]--
DOCK_EMBEDS["Recount"] = function(self)
	if((not IsAddOnLoaded("Recount")) or (not _G.Recount)) then return false end

	local width = self:GetWidth()
	local height = SV.Dock.BottomRight.Window:GetHeight();

	Recount.db.profile.Locked = true;
	Recount.db.profile.Scaling = 1;
	Recount.db.profile.ClampToScreen = true;
	Recount.db.profile.FrameStrata = '2-LOW'
	Recount.MainWindow:ClearAllPoints()
	Recount.MainWindow:SetParent(self)
	Recount.MainWindow:SetSize(width, height)
	Recount.MainWindow:SetPoint("BOTTOM", self, "BOTTOM", 0, 0)
	Recount:SetStrataAndClamp()
	Recount:LockWindows(true)
	Recount:ResizeMainWindow()
	Recount_MainWindow_ScrollBar:Hide()

	Recount.MainWindow:Show()

	self.Framelink = Recount.MainWindow
	return true
end
--[[
##########################################################
OMEN
##########################################################
]]--
DOCK_EMBEDS["Omen"] = function(self)
	if((not IsAddOnLoaded("Omen")) or (not _G.Omen)) then return false end

	local width = self:GetWidth()
	local height = SV.Dock.BottomRight.Window:GetHeight();
	local db = Omen.db;

	--[[ General Settings ]]--
	db.profile.FrameStrata = '2-LOW';
	db.profile.Locked = true;
	db.profile.Scale = 1;
	db.profile.ShowWith.UseShowWith = false;

	--[[ Background Settings ]]--
	db.profile.Background.BarInset = 3;
	db.profile.Background.EdgeSize = 1;
	db.profile.Background.Texture = "None"

	--[[ Bar Settings ]]--
	db.profile.Bar.Font = "SVUI Default Font";
	db.profile.Bar.FontOutline = "None";
	db.profile.Bar.FontSize = 11;
	db.profile.Bar.Height = 14;
	db.profile.Bar.ShowHeadings = false;
	db.profile.Bar.ShowTPS = false;
	db.profile.Bar.Spacing = 1;
	db.profile.Bar.Texture = "SVUI MultiColorBar";

	--[[ Titlebar Settings ]]--
	db.profile.TitleBar.BorderColor.g = 0;
	db.profile.TitleBar.BorderColor.r = 0;
	db.profile.TitleBar.BorderTexture = "None";
	db.profile.TitleBar.EdgeSize = 1;
	db.profile.TitleBar.Font = "Arial Narrow";
	db.profile.TitleBar.FontSize = 12;
	db.profile.TitleBar.Height = 23;
	db.profile.TitleBar.ShowTitleBar = true;
	db.profile.TitleBar.Texture = "None";
	db.profile.TitleBar.UseSameBG = false;

	Omen:OnProfileChanged(nil,db)
	OmenTitle:RemoveTextures()
	OmenTitle.Panel = nil
	OmenTitle:SetStyle("Frame", "Transparent")
	--OmenTitle:SetPanelColor("class")
	--OmenTitle:GetFontString():SetFont(SV.media.font.default, 12, "OUTLINE")

	if(not OmenAnchor.Panel) then
		OmenBarList:RemoveTextures()
		OmenAnchor:SetStyle("Frame", 'Transparent')
	end
	OmenAnchor:ClearAllPoints()
	OmenAnchor:SetParent(self)
	OmenAnchor:SetSize(width, height)
	OmenAnchor:SetPoint("BOTTOM", self, "BOTTOM", 0, 0)

	self.Framelink = OmenAnchor
	return true
end
--[[
##########################################################
ALDAMAGEMETER
##########################################################
]]--
DOCK_EMBEDS["alDamageMeter"] = function(self)
	if((not IsAddOnLoaded("alDamageMeter")) or (not _G.alDamagerMeterFrame)) then return false end

	local w,h = self:GetSize();
	local count = dmconf.maxbars or 10;
	local spacing = dmconf.spacing or 1;

	dmconf.barheight = floor((h / count) - spacing);
	dmconf.width = w;

	alDamageMeterFrame:ClearAllPoints()
	alDamageMeterFrame:SetAllPoints(self)
	alDamageMeterFrame.backdrop:SetStyle("!_Frame", 'Transparent')
	alDamageMeterFrame.bg:Die()
	alDamageMeterFrame:SetFrameStrata('LOW')

	self.Framelink = alDamageMeterFrame
	return true
end
--[[
##########################################################
TINYDPS
##########################################################
]]--
DOCK_EMBEDS["TinyDPS"] = function(self)
	if((not IsAddOnLoaded("TinyDPS")) or (not _G.tdpsFrame)) then return false end

	tdps.hideOOC = false;
	tdps.hideIC = false;
	tdps.hideSolo = false;
	tdps.hidePvP = false;
	tdpsFrame:ClearAllPoints()
	tdpsFrame:SetAllPoints(self)
	tdpsFrame:SetParent(self)
	tdpsRefresh()

	self.Framelink = tdpsFrame
	return true
end
--[[
##########################################################
!DETAILS (IN DEVELOPMENT)
##########################################################
]]--

-- DOCK_EMBEDS["Details"] = function(self)
-- 	if(not IsAddOnLoaded("Details")) then return false end
-- 	local width = self:GetWidth()
-- 	local height = SV.Dock.BottomRight.Window:GetHeight();

-- 	if(DetailsBaseFrame1) then
-- 		DetailsBaseFrame1:ClearAllPoints()
-- 		DetailsBaseFrame1:SetParent(self)
-- 		DetailsBaseFrame1:SetSize(width - 4, height - 4)
-- 		DetailsBaseFrame1:SetPoint("BOTTOM", self, "BOTTOM", 0, 2)
-- 		DetailsBaseFrame1:SetMovable(false);
-- 		if(DetailsRowFrame1) then
-- 			DetailsRowFrame1:ClearAllPoints()
-- 			DetailsRowFrame1:SetParent(self)
-- 			DetailsRowFrame1:SetAllPoints(DetailsBaseFrame1)
-- 			self.Framelink = DetailsRowFrame1
-- 		else
-- 			self.Framelink = DetailsBaseFrame1
-- 		end
-- 		_detalhes.move_janela_func = SV.fubar
-- 		return true
-- 	else
-- 		return false
-- 	end
-- end

--[[
##########################################################
DOCK EMBED METHODS
##########################################################
]]--
local DOCK_EmbedAddon = function(self, request)
	if(not request) then return false end

	for addon,fn in pairs(DOCK_EMBEDS) do
		if(SafeStringFind(request,addon)) then
			local activated = fn(self)
			self.Embedded = addon
			return activated, addon
		end
	end
	self.Embedded = "NONE"
	return false
end

local DOCK_EmbedCheck = function(self, ...)
	local data1 = SV.private.Docks[self.EmbedKey] or 'None';
	local data2 = SV.private.Docks[self.EmbedOther] or 'None';
	return data1,data2
end

local PARENT_IsEmbedded = function(self, request)
	if(self.Dock1.Embedded ~= "NONE") then
		if(SafeStringFind(request,self.Dock1.Embedded)) then
			return true
		end
	end
	if(self.Dock2.Embedded ~= "NONE") then
		if(SafeStringFind(request,self.Dock2.Embedded)) then
			return true
		end
	end
	return false
end

local PARENT_UpdateEmbeds = function(self, ...)
	if(self.Dock1.Embedded ~= "NONE") then
		local fn = DOCK_EMBEDS[self.Dock1.Embedded];
		if(fn) then
			fn(self.Dock1, ...)
		end
	end
	if(self.Dock2.Embedded ~= "NONE") then
		local fn = DOCK_EMBEDS[self.Dock2.Embedded];
		if(fn) then
			fn(self.Dock2, ...)
		end
	end
end
--[[
##########################################################
CORE FUNCTIONS
##########################################################
]]--
function MOD:FindDockables()
	local test = false;
	for addon,_ in pairs(DOCK_EMBEDS) do
		if IsAddOnLoaded(addon) then
			test = true;
		end
	end
	self.Docklet:SetDocked(test);
end

function MOD:SetEmbedHandlers()
	MOD.Docklet.UpdateEmbeds     = PARENT_UpdateEmbeds;
	MOD.Docklet.IsEmbedded       = PARENT_IsEmbedded;

	MOD.Docklet.Dock1.EmbedKey   = "Embed1";
	MOD.Docklet.Dock1.EmbedOther = "Embed2";
	MOD.Docklet.Dock1.Embedded   = "NONE";
	MOD.Docklet.Dock1.EmbedAddon = DOCK_EmbedAddon;
	MOD.Docklet.Dock1.EmbedCheck = DOCK_EmbedCheck;

	MOD.Docklet.Dock2.EmbedKey   = "Embed2";
	MOD.Docklet.Dock2.EmbedOther = "Embed1";
	MOD.Docklet.Dock2.Embedded   = "NONE";
	MOD.Docklet.Dock2.EmbedAddon = DOCK_EmbedAddon;
	MOD.Docklet.Dock2.EmbedCheck = DOCK_EmbedCheck;
end

function MOD:RegisterAddonDocklets()
	-- if(self:FindDockables()) then
	-- 	self.Docklet:SetDocked(true);
	-- 	self.Docklet:Enable();
	-- else
	-- 	self.Docklet:Disable();
	-- 	self.Docklet:SetDocked(false);
	-- 	return
	-- end
	local available = false;
	if(SV.db.Skins.enableAddonDock) then
		for addon,_ in pairs(DOCK_EMBEDS) do
			if IsAddOnLoaded(addon) then
				available = true;
			end
		end
	end

	self.Docklet:SetDocked(available);
	
	if(available) then
		local embed1,embed2,enabled1,enabled2 = RequestEmbedded();
		local addon1, addon2, extraTip = "", "", "";
		local active1, active2 = false, false;

		self.Docklet.Embedded = {}
		self.Docklet.Dock1.FrameLink = nil;
		self.Docklet.Dock1.ExpandCallback = nil;
		self.Docklet.Dock2.FrameLink = nil;
		self.Docklet.Dock2.ExpandCallback = nil;

		local width = self.Docklet:GetWidth() - 2;
		self.Docklet.Dock1:SetWidth(width)

		if(enabled2) then
			if(enabled1) then
				self.Docklet.Dock1:SetWidth(width * 0.5)
			else
				self.Docklet.Dock1:SetWidth(0.1)
			end

			self.Docklet.Dock2:ClearAllPoints()
			self.Docklet.Dock2:SetPoint('TOPLEFT', self.Docklet.Dock1, 'TOPRIGHT', 0, 0);
			self.Docklet.Dock2:SetPoint('BOTTOMRIGHT', self.Docklet, 'BOTTOMRIGHT', 1, -1);

			active2, addon2 = self.Docklet.Dock2:EmbedAddon(embed2)

			if(not active2) then
				self.Docklet.Dock1:SetWidth(width)
			end
		end

		if(enabled1) then
			active1, addon1 = self.Docklet.Dock1:EmbedAddon(embed1)
		end

		if(active1 or active2) then
			if(active2) then
				extraTip = TIP_RIGHT_PATTERN:format(addon2)
				self.Docklet.Dock1:Show()
				self.Docklet.Dock2:Show()
			else
				self.Docklet.Dock1:Show()
				self.Docklet.Dock2:Hide()
			end

			self.Docklet.Button:SetAttribute("tipText", ("%s%s"):format(addon1, extraTip));
		else
			self.Docklet.Dock1:Hide()
			self.Docklet.Dock2:Hide()
		end
	end
end

function MOD:GetAddonDockMenu()
	local t = {};

	local test1 = SV.private.Docks.Embed1 or 'None';
	local test2 = SV.private.Docks.Embed2 or 'None';
	local allowed1, allowed2 = false,false;

	for addon,_ in pairs(DOCK_EMBEDS) do
		if(SafeStringFind(addon,"Skada") and _G.Skada) then
			for index,window in pairs(_G.Skada:GetWindows()) do
				local keyName = window.db.name
			    local key = "SkadaBarWindow" .. keyName
			    if ((not SafeStringFind(test1,key)) and (not SafeStringFind(test2,key))) then
				    local name = (keyName == "Skada") and "Skada - Main" or "Skada - " .. keyName;
				    if(not allowed1) then
				    	tinsert(t,{ title = "Set Primary", divider = true });
				    	allowed1 = true;
				    end
				    tinsert(t,{text = name, func = function() SV.private.Docks.Embed1 = key; MOD:RegisterAddonDocklets() end});
				end
			end
		else
			if(IsAddOnLoaded(addon) and (not SafeStringFind(test1,addon)) and (not SafeStringFind(test2,addon))) then
				if(not allowed1) then
			    	tinsert(t,{ title = "Set Primary", divider = true });
			    	allowed1 = true;
			    end
				tinsert(t,{text = addon, func = function() SV.private.Docks.Embed1 = addon; MOD:RegisterAddonDocklets() end});
			end
		end
	end

	for addon,_ in pairs(DOCK_EMBEDS) do
		if(SafeStringFind(addon,"Skada") and _G.Skada) then
			for index,window in pairs(_G.Skada:GetWindows()) do
				local keyName = window.db.name
			    local key = "SkadaBarWindow" .. keyName;
			    if ((not SafeStringFind(test1,key)) and (not SafeStringFind(test2,key))) then
				    local name = (keyName == "Skada") and "Skada - Main" or "Skada - " .. keyName;
				    if(not allowed2) then
				    	tinsert(t,{ title = "Set Secondary", divider = true });
				    	allowed2 = true;
				    end
				    tinsert(t,{text = name, func = function() SV.private.Docks.Embed2 = key; MOD:RegisterAddonDocklets() end});
				end
			end
		else
			if(IsAddOnLoaded(addon) and (not SafeStringFind(test1,addon)) and (not SafeStringFind(test2,addon))) then
				if(not allowed2) then
			    	tinsert(t,{ title = "Set Secondary", divider = true });
			    	allowed2 = true;
			    end
				tinsert(t,{text = addon, func = function() SV.private.Docks.Embed2 = addon; MOD:RegisterAddonDocklets() end});
			end
		end
	end

	local canRemove1 = (test1 and test1 ~= 'None') or false;
	local canRemove2 = (test2 and test2 ~= 'None') or false;
	if(canRemove1 or canRemove2) then
		tinsert(t,{ title = "Remove", divider = true });
		if canRemove1 then
			tinsert(t,{text = "Primary", func = function() SV.private.Docks.Embed1 = "None"; MOD:RegisterAddonDocklets() end});
		end
		if canRemove2 then
			tinsert(t,{text = "Secondary", func = function() SV.private.Docks.Embed2 = "None"; MOD:RegisterAddonDocklets() end});
		end
	end

	return t;
end
--[[
##########################################################
LISTING FOR OPTIONS
##########################################################
]]--
do
	for addon,_ in pairs(DOCK_EMBEDS) do
		DOCK_LISTING[addon] = addon;
	end
end

function MOD:GetDockables(secondary)
	local t = {["None"] = L["None"]};
	local test = SV.private.Docks.Embed2;
	if(secondary) then test = SV.private.Docks.Embed1; end

	for n,l in pairs(DOCK_LISTING) do
		if(n:find("Skada") and _G.Skada) then
			for index,window in pairs(_G.Skada:GetWindows()) do
			    local name = window.db.name
			    local key = "SkadaBarWindow"..name
			    if(not test or test ~= key) then
			    	t["SkadaBarWindow"..name] = (key == "Skada") and "Skada - Main" or "Skada - "..name;
			    end
			end
		elseif((not test) or (not test:find(n))) then
			if IsAddOnLoaded(n) or IsAddOnLoaded(l) then t[n] = l end
		end
	end

	return t;
end
