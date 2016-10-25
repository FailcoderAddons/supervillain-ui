--[[
##########################################################
S V U I   By: Failcoder
##########################################################
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
local _G            	= _G;
--LUA
local unpack            = _G.unpack;
local select            = _G.select;
local assert            = _G.assert;
local type              = _G.type;
local error             = _G.error;
local pcall             = _G.pcall;
local print             = _G.print;
local ipairs            = _G.ipairs;
local pairs             = _G.pairs;
local next              = _G.next;
local tostring          = _G.tostring;
local tonumber          = _G.tonumber;
local collectgarbage    = _G.collectgarbage;
--BLIZZARD
local tinsert       = _G.tinsert;
local tremove       = _G.tremove;
local twipe         = _G.wipe;
--STRING
local string        = string;
local format        = string.format;
local find          = string.find;
local match         = string.match;
--MATH
local math          = math;
local min, random   = math.min, math.random;
--TABLE
local table         = table;
--BLIZZARD API
local hooksecurefunc 			= _G.hooksecurefunc;
local InCombatLockdown      	= _G.InCombatLockdown;
local CreateFrame           	= _G.CreateFrame;
local IsAddOnLoaded         	= _G.IsAddOnLoaded;
local IsInInstance          	= _G.IsInInstance;
local GetActiveSpecGroup    	= _G.GetActiveSpecGroup;
local GetSpellInfo    			= _G.GetSpellInfo;
local oUF_RaidDebuffs       	= _G.oUF_RaidDebuffs;
local MAX_BOSS_FRAMES       	= _G.MAX_BOSS_FRAMES;
local RAID_CLASS_COLORS     	= _G.RAID_CLASS_COLORS;
local FACTION_BAR_COLORS    	= _G.FACTION_BAR_COLORS;
local CUSTOM_CLASS_COLORS   	= _G.CUSTOM_CLASS_COLORS;
local RegisterStateDriver       = _G.RegisterStateDriver;
local UnregisterStateDriver     = _G.UnregisterStateDriver;
local RegisterAttributeDriver   = _G.RegisterAttributeDriver;
--[[
##########################################################
GET ADDON DATA AND TEST FOR oUF
##########################################################
]]--
local SV = _G['SVUI']
local L = SV.L;
local LSM = _G.LibStub("LibSharedMedia-3.0");
--[[
##########################################################
MODULE AND INNER CLASSES
##########################################################
]]--
local MOD = SV.UnitFrames;
local oUF_SVUI = MOD.oUF
assert(oUF_SVUI, "SVUI UnitFrames: unable to locate oUF.")
MOD.Units = {}
MOD.Headers = {}
MOD.Dispellable = {}
--[[
##########################################################
LOCALS
##########################################################
]]--
local LoadedUnitFrames, LoadedGroupHeaders;

local function FindAnchorFrame(frame, anchor, badPoint)
	if badPoint or anchor == 'FRAME' then
		if(frame.Gladiator and frame.Gladiator:IsShown()) then
			return frame.Gladiator
		else
			return frame
		end
	elseif(anchor == 'TRINKET' and frame.Gladiator and frame.Gladiator:IsShown()) then
		return frame.Gladiator
	elseif(anchor == 'BUFFS' and frame.Buffs and frame.Buffs:IsShown()) then
		return frame.Buffs
	elseif(anchor == 'DEBUFFS' and frame.Debuffs and frame.Debuffs:IsShown()) then
		return frame.Debuffs
	else
		return frame
	end
end
--[[
##########################################################
CORE FUNCTIONS
##########################################################
]]--
do
	local dummy = CreateFrame("Frame", nil)
	dummy:Hide()

	local function deactivate(unitName)
		local frame;
		if type(unitName) == "string" then frame = _G[unitName] else frame = unitName end
		if frame then
			frame:UnregisterAllEvents()
			frame:Hide()
			frame:SetParent(dummy)
			if frame.healthbar then frame.healthbar:UnregisterAllEvents() end
			if frame.manabar then frame.manabar:UnregisterAllEvents() end
			if frame.spellbar then frame.spellbar:UnregisterAllEvents() end
			if frame.powerBarAlt then frame.powerBarAlt:UnregisterAllEvents() end
		end
	end

	function oUF_SVUI:DisableBlizzard(unit)
		if (not unit) or InCombatLockdown() then return end

		if (unit == "player") then
			PlayerFrame:UnregisterAllEvents()
			PlayerFrame:SetAlpha(0)
			--PlayerFrame:Hide()
			PlayerFrame:EnableMouse(false)
			if PlayerFrame.healthbar then PlayerFrame.healthbar:UnregisterAllEvents() end
			if PlayerFrame.manabar then PlayerFrame.manabar:UnregisterAllEvents() end
			if PlayerFrame.spellbar then PlayerFrame.spellbar:UnregisterAllEvents() end
			if PlayerFrame.powerBarAlt then PlayerFrame.powerBarAlt:UnregisterAllEvents() end
			PlayerFrame:RegisterUnitEvent("UNIT_ENTERING_VEHICLE", "player")
			PlayerFrame:RegisterUnitEvent("UNIT_ENTERED_VEHICLE", "player")
			PlayerFrame:RegisterUnitEvent("UNIT_EXITING_VEHICLE", "player")
			PlayerFrame:RegisterUnitEvent("UNIT_EXITED_VEHICLE", "player")
			PlayerFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
			PlayerFrame:SetUserPlaced(true)
			PlayerFrame:SetDontSavePosition(true)
			RuneFrame:SetParent(PlayerFrame)
		elseif(unit == "pet") then
			deactivate(PetFrame)
		elseif(unit == "target") then
			deactivate(TargetFrame)
			deactivate(ComboFrame)
		elseif(unit == "focus") then
			deactivate(FocusFrame)
			deactivate(TargetofFocusFrame)
		elseif(unit == "targettarget") then
			deactivate(TargetFrameToT)
		elseif(unit:match("(boss)%d?$") == "boss") then
			local id = unit:match("boss(%d)")
			if(id) then
				deactivate("Boss"..id.."TargetFrame")
			else
				for i = 1, 4 do
					deactivate(("Boss%dTargetFrame"):format(i))
				end
			end
		elseif(unit:match("(party)%d?$") == "party") then
			local id = unit:match("party(%d)")
			if(id) then
				deactivate("PartyMemberFrame"..id)
			else
				for i = 1, 4 do
					deactivate(("PartyMemberFrame%d"):format(i))
				end
			end
		elseif(unit:match("(arena)%d?$") == "arena") then
			local id = unit:match("arena(%d)")
			if(id) then
				deactivate("ArenaEnemyFrame"..id)
				deactivate("ArenaPrepFrame"..id)
				deactivate("ArenaEnemyFrame"..id.."PetFrame")
			else
				for i = 1, 5 do
					deactivate(("ArenaEnemyFrame%d"):format(i))
					deactivate(("ArenaPrepFrame%d"):format(i))
					deactivate(("ArenaEnemyFrame%dPetFrame"):format(i))
				end
			end
		end
	end
end

function MOD:GetActiveSize(db, token)
	local width, height, best = 0,0,0
	if(db.grid and db.grid.enable) then
		width = db.grid.size
		height = width
		best = width
	elseif(db) then
		width = db.width
		height = db.height
		best = min(width, height);
	end

	return width, height, best
end

function MOD:ResetUnitOptions(unit)
	SV:ResetData("UnitFrames", unit)
	self:RefreshUnitFrames()
end

function MOD:RefreshUnitColors()
	if(not SV.db.general.customClassColor) then
		for eclass, color in next, RAID_CLASS_COLORS do
			oUF_SVUI.colors.class[eclass] = {color.r, color.g, color.b}
		end
	else
		for eclass, color in next, CUSTOM_CLASS_COLORS do
			oUF_SVUI.colors.class[eclass] = {color.r, color.g, color.b}
		end
	end
	local db = SV.media.extended.unitframes
	for i, setting in pairs(db) do
		if setting and type(setting) == "table" then
			if(setting[1]) then
				oUF_SVUI.colors[i] = setting
			else
				local bt = {}
				for x, color in pairs(setting) do
					if(color)then
						bt[x] = color
					end
					oUF_SVUI.colors[i] = bt
				end
			end
		elseif setting then
			oUF_SVUI.colors[i] = setting
		end
	end
	local r, g, b = db.health[1], db.health[2], db.health[3]
	oUF_SVUI.colors.smooth = {1, 0, 0, 1, 1, 0, r, g, b}
	SV.Events:Trigger("UNITFRAME_COLORS_UPDATED");
end

function MOD:RefreshAllUnitMedia()
	if(not SV.db.UnitFrames) then return end
	self:RefreshUnitColors()
	for unit,frame in pairs(self.Units)do
		if SV.db.UnitFrames[frame.___key].enable then
			frame:MediaUpdate()
			frame:UpdateAllElements()
		end
	end
	for _,group in pairs(self.Headers) do
		group:MediaUpdate()
	end
	collectgarbage("collect")
end

function MOD:RefreshUnitFrames()
	if(InCombatLockdown()) then self:RegisterEvent("PLAYER_REGEN_ENABLED"); return end
	self:RefreshUnitColors()
	for unit,frame in pairs(self.Units)do
		if(SV.db.UnitFrames[frame.___key].enable) then
			frame:Enable()
			frame:Update()
		else
			frame:Disable()
		end
	end
	local _,groupType = IsInInstance()
	local raidDebuffs = SV.oUF_RaidDebuffs or oUF_RaidDebuffs;
	if raidDebuffs then
		raidDebuffs:ResetDebuffData()
		if groupType == "party" or groupType == "raid" then
		  raidDebuffs:RegisterDebuffs(SV.db.Filters["Raid"])
		else
		  raidDebuffs:RegisterDebuffs(SV.db.Filters["CC"])
		end
	end

	for _,group in pairs(self.Headers) do
		group:Update()
		if(group.Configure) then
		  group:Configure()
		end
	end
	if SV.db.UnitFrames.disableBlizzard then
		oUF_SVUI:DisableBlizzard('party')
	end

	if(self.BodyGuard) then
		self.BodyGuard:UpdateSettings()
	end
	collectgarbage("collect")
end

local function UpdateUnitFrames()
	MOD:RefreshUnitFrames()
end

function MOD:RefreshUnitMedia(unitName)
    local db = SV.db.UnitFrames
    local key = unitName or self.___key
    if((not db) or (not self)) then return end
    local CURRENT_BAR_TEXTURE = LSM:Fetch("statusbar", db.statusbar)
    local unitDB = db[key]
    if(unitDB and unitDB.enable) then
        local panel = self.TextGrip
        if(panel) then
          if(panel.Name and unitDB.name) then
          	if(unitDB.grid and unitDB.grid.enable) then
          		panel.Name:SetFont(SV.media.font.pixel, 8, "MONOCHROMEOUTLINE")
          		panel.Name:SetShadowOffset(0, -1)
							panel.Name:SetShadowColor(0, 0, 0, 1)
          	else
              panel.Name:SetFont(LSM:Fetch("font", unitDB.name.font), unitDB.name.fontSize, unitDB.name.fontOutline)
							if(key == 'raid') then
								panel.Name:SetShadowOffset(0, -1)
								panel.Name:SetShadowColor(0, 0, 0, 1)
							else
								if(unitDB.name.fontOutline == 'NONE') then
									panel.Name:SetShadowColor(0, 0, 0, 1)
								else
									panel.Name:SetShadowColor(0, 0, 0, 0.5)
								end
								panel.Name:SetShadowOffset(1, -1)
							end
            end
          end
        end
        if(self.Health) then
            self.Health:SetStatusBarTexture(CURRENT_BAR_TEXTURE)
        end
        if(self.Power and (unitDB.power and unitDB.power.enable)) then
            self.Power:SetStatusBarTexture(CURRENT_BAR_TEXTURE)
        end
        if(self.Castbar and (unitDB.castbar)) then
            if(unitDB.castbar.useCustomColor) then
				self.Castbar.CastColor = unitDB.castbar.castingColor
				self.Castbar.SparkColor = unitDB.castbar.sparkColor
			else
				self.Castbar.CastColor = oUF_SVUI.colors.casting
				self.Castbar.SparkColor = oUF_SVUI.colors.spark
			end
        end
    end
end

local POWER_ANCHORS = {
	["BOTTOM"] = {"BOTTOMLEFT", "BOTTOMLEFT", 1, 1, "BOTTOMRIGHT", "BOTTOMRIGHT", -1, 1},
	["TOP"] = {"TOPLEFT", "TOPLEFT", 1, -1, "TOPRIGHT", "TOPRIGHT", -1, -1},
	["LEFT"] = {"TOPLEFT", "TOPLEFT", 1, -1, "BOTTOMLEFT", "BOTTOMLEFT", 1, 1},
	["RIGHT"] = {"TOPRIGHT", "TOPRIGHT", -1, -1, "BOTTOMRIGHT", "BOTTOMRIGHT", -1, 1},
}

local POWER_DETACHED_ANCHORS = {
	["BOTTOM"] = {"TOP", "BOTTOM", 0, -1},
	["TOP"] = {"BOTTOM", "TOP", 0, 1},
	["LEFT"] = {"RIGHT", "LEFT", -1, 0},
	["RIGHT"] = {"LEFT", "RIGHT", 1, 0},
}

function MOD:RefreshUnitLayout(frame, template)
	local db = SV.db.UnitFrames[template]
	if(not db) then return end

	local TOP_ANCHOR1, TOP_ANCHOR2, TOP_MODIFIER = "TOPRIGHT", "TOPLEFT", 1;
	local BOTTOM_ANCHOR1, BOTTOM_ANCHOR2, BOTTOM_MODIFIER = "BOTTOMLEFT", "BOTTOMRIGHT", -1;
	local REVERSED_LAYOUT = db.reverseLayout;
	if(REVERSED_LAYOUT) then
		TOP_ANCHOR1 = "TOPLEFT"
		TOP_ANCHOR2 = "TOPRIGHT"
		TOP_MODIFIER = -1
		BOTTOM_ANCHOR1 = "BOTTOMRIGHT"
		BOTTOM_ANCHOR2 = "BOTTOMLEFT"
		BOTTOM_MODIFIER = 1
	end

	local MASTER_GRIP = frame.ActionPanel;
	local TEXT_GRIP = frame.TextGrip;

	local UNIT_WIDTH, UNIT_HEIGHT, BEST_SIZE = self:GetActiveSize(db);
	local GRID_MODE = (db.grid and db.grid.enable);
	local MINI_GRID = (GRID_MODE and BEST_SIZE < 26);
	local RESIZE_NEEDED = false;
	local MASTER_X1_OFFSET, MASTER_X2_OFFSET, MASTER_TOP_OFFSET, MASTER_BOTTOM_OFFSET = 0, 0, 0, 0;

	local POWER_GRIP = frame.Power;
	local POWER_POINT;
	local POWER_ENABLED, POWER_DETACHED = false, false;
	local POWER_HEIGHT, POWER_WIDTH = 1, UNIT_WIDTH;
	if(POWER_GRIP and db.power) then
		POWER_ENABLED = (GRID_MODE and db.grid.powerEnable) or db.power.enable;
		POWER_DETACHED = db.power.detached;
		RESIZE_NEEDED = POWER_DETACHED
		if(POWER_ENABLED) then
			if(db.power.height) then POWER_HEIGHT = db.power.height - 1; end
			if(db.power.width and POWER_DETACHED) then POWER_WIDTH = db.power.width; end
		end
		if(db.power.anchor) then
			POWER_POINT = POWER_DETACHED and POWER_DETACHED_ANCHORS[db.power.anchor] or POWER_ANCHORS[db.power.anchor]
			if(POWER_DETACHED) then
				if(db.power.anchor == "TOP") then
					MASTER_TOP_OFFSET = POWER_HEIGHT
				elseif(db.power.anchor == "BOTTOM") then
					MASTER_BOTTOM_OFFSET = POWER_HEIGHT
				else
					if((REVERSED_LAYOUT and db.power.anchor == "LEFT") or ((not REVERSED_LAYOUT) and db.power.anchor == "RIGHT")) then
						MASTER_X2_OFFSET = MASTER_X2_OFFSET + POWER_WIDTH
					else
						MASTER_X1_OFFSET = MASTER_X1_OFFSET + POWER_WIDTH
					end
				end
			end
		end
	end

	local PORTRAIT_GRIP = false;
	local PORTRAIT_ENABLED = false;
	local PORTRAIT_OVERLAY = false;
	local PORTRAIT_OVERLAY_ANIMATION = false;
	local PORTRAIT_WIDTH = 0;
	local PORTRAIT_STYLE = 'None';
	if(db.portrait) then
		PORTRAIT_ENABLED = (not GRID_MODE and db.portrait.enable);
		PORTRAIT_STYLE = db.portrait.style;
		PORTRAIT_OVERLAY = (not GRID_MODE and PORTRAIT_ENABLED and PORTRAIT_STYLE == '3DOVERLAY');
		PORTRAIT_OVERLAY_ANIMATION = (PORTRAIT_OVERLAY) and SV.db.UnitFrames.overlayAnimation or false;
		if(PORTRAIT_ENABLED and (not PORTRAIT_OVERLAY)) then
			if(PORTRAIT_STYLE == '2D') then
				PORTRAIT_WIDTH = UNIT_HEIGHT;
			else
				PORTRAIT_WIDTH = db.portrait.width;
			end
			RESIZE_NEEDED = true
		end

		if(frame.PortraitModel) then
			frame.PortraitModel:Hide()
			frame.PortraitModel:ClearAllPoints()
		end

		if(frame.PortraitTexture) then
			local parent2D = frame.PortraitTexture:GetParent();
			parent2D:Hide()
			parent2D:ClearAllPoints()
		end

		if(frame.PortraitTexture and frame.PortraitModel) then
			if(PORTRAIT_STYLE == '2D') then
				frame.Portrait = frame.PortraitTexture
				PORTRAIT_GRIP = frame.PortraitTexture:GetParent();
			else
				frame.PortraitModel.UserRotation = db.portrait.rotation;
				frame.PortraitModel.UserCamDistance = db.portrait.camDistanceScale;
				frame.Portrait = frame.PortraitModel
				PORTRAIT_GRIP = frame.PortraitModel;
			end
		else
			PORTRAIT_GRIP = frame.Portrait;
		end
	end

	local BUFF_GRIP = frame.Buffs;
	local BUFF_ENABLED = (db.buffs and db.buffs.enable) or false;
	local DEBUFF_GRIP = frame.Debuffs;
	local DEBUFF_ENABLED = (db.debuffs and db.debuffs.enable) or false;
	local RAID_DEBUFFS = frame.RaidDebuffs;
	local RAID_DEBUFFS_ENABLED = (db.rdebuffs and db.rdebuffs.enable) or false;

	if(RESIZE_NEEDED) then
		frame:SetSize(UNIT_WIDTH + (MASTER_X1_OFFSET + MASTER_X2_OFFSET), UNIT_HEIGHT + (MASTER_TOP_OFFSET + MASTER_BOTTOM_OFFSET))
		if(frame.Grip) then frame.Grip:SetSize(frame:GetSize()) end
	end

	MASTER_GRIP:ClearAllPoints();
	MASTER_GRIP:SetPoint(TOP_ANCHOR2, frame, TOP_ANCHOR2, ((MASTER_X1_OFFSET + PORTRAIT_WIDTH) * TOP_MODIFIER), MASTER_TOP_OFFSET);
	MASTER_GRIP:SetPoint(BOTTOM_ANCHOR2, frame, BOTTOM_ANCHOR2, (MASTER_X2_OFFSET * BOTTOM_MODIFIER), MASTER_BOTTOM_OFFSET);
	self:UpdateStatusMedia(frame)

	if(frame.InfoPanelBG) then
		if(SV.db.UnitFrames.infoBackgrounds) then
			frame.InfoPanelBG:SetColorTexture(1,1,1,1)
			frame.InfoPanelLeft:SetColorTexture(1,1,1,1)
			frame.InfoPanelRight:SetColorTexture(1,1,1,1)
		else
			frame.InfoPanelBG:SetColorTexture(0,0,0,0)
			frame.InfoPanelLeft:SetColorTexture(0,0,0,0)
			frame.InfoPanelRight:SetColorTexture(0,0,0,0)
		end
	end

	--[[ THREAT LAYOUT ]]--

	if frame.Threat then
		local threat = frame.Threat;
		if db.threatEnabled then
			if not frame:IsElementEnabled('Threat')then
				frame:EnableElement('Threat')
			end
		elseif frame:IsElementEnabled('Threat')then
			frame:DisableElement('Threat')
		end
	end

	--[[ TARGETGLOW LAYOUT ]]--

	if frame.TargetGlow then
		local glow = frame.TargetGlow;
		glow:ClearAllPoints()
		glow:SetPoint("TOPLEFT", -3, 3)
		glow:SetPoint("TOPRIGHT", 3, 3)
		glow:SetPoint("BOTTOMLEFT", -3, -3)
		glow:SetPoint("BOTTOMRIGHT", 3, -3)
	end

	--[[ INFO TEXTS ]]--
	local point,cX,cY;

	if(TEXT_GRIP.Name and db.name) then
		local nametext = TEXT_GRIP.Name
		if(GRID_MODE) then
			nametext:ClearAllPoints()
			nametext:SetPoint("CENTER", frame, "CENTER", 0, 0)
			nametext:SetJustifyH("CENTER")
			nametext:SetJustifyV("MIDDLE")
			if(db.name.tags ~= nil and db.name.tags ~= '') then
				frame:Tag(nametext, "[name:grid]")
			end
		else
			point = db.name.position
			cX = db.name.xOffset
			cY = db.name.yOffset
			nametext:ClearAllPoints()
			SV:SetReversePoint(nametext, point, TEXT_GRIP, cX, cY)

			if(nametext.initialAnchor:find("RIGHT")) then
				nametext:SetJustifyH("RIGHT")
			elseif(nametext.initialAnchor:find("LEFT")) then
				nametext:SetJustifyH("LEFT")
			else
				nametext:SetJustifyH("CENTER")
			end

			if(nametext.initialAnchor:find("TOP")) then
				nametext:SetJustifyV("TOP")
			elseif(nametext.initialAnchor:find("BOTTOM")) then
				nametext:SetJustifyV("BOTTOM")
			else
				nametext:SetJustifyV("MIDDLE")
			end

			frame:Tag(nametext, db.name.tags)
		end
	end

	if(frame.Health and TEXT_GRIP.Health and db.health) then
		if(GRID_MODE) then
			TEXT_GRIP.Health:Hide()
		else
			if(not TEXT_GRIP.Health:IsShown()) then TEXT_GRIP.Health:Show() end
			local healthtext = TEXT_GRIP.Health
			point = db.health.position
			cX = db.health.xOffset
			cY = db.health.yOffset
			healthtext:ClearAllPoints()
			SV:SetReversePoint(healthtext, point, TEXT_GRIP, cX, cY)
			frame:Tag(healthtext, db.health.tags)
		end
	end

	if(POWER_GRIP and TEXT_GRIP.Power and db.power) then
		if(GRID_MODE) then
			TEXT_GRIP.Power:Hide()
		else
			if(not TEXT_GRIP.Power:IsShown()) then TEXT_GRIP.Power:Show() end
			local powertext = TEXT_GRIP.Power
			if(db.power.tags ~= nil and db.power.tags ~= '') then
				point = db.power.position
				cX = db.power.xOffset
				cY = db.power.yOffset
				powertext:ClearAllPoints()
				SV:SetReversePoint(powertext, point, TEXT_GRIP, cX, cY)
			end
			frame:Tag(powertext, db.power.tags)
		end
	end

	if(TEXT_GRIP.Misc and db.misc) then
		if(GRID_MODE) then
			TEXT_GRIP.Misc:Hide()
		else
			if(not TEXT_GRIP.Misc:IsShown()) then TEXT_GRIP.Misc:Show() end
			frame:Tag(TEXT_GRIP.Misc, db.misc.tags)
		end
	end

	--[[ HEALTH LAYOUT ]]--

	do
		local health = frame.Health;
		if(db.health and (db.health.reversed  ~= nil)) then
			health.fillInverted = db.health.reversed;
		else
			health.fillInverted = false
		end

		health.Smooth = SV.db.UnitFrames.smoothbars;
		health.colorSmooth = nil;
		health.colorHealth = nil;
		health.colorClass = nil;
		health.colorBackdrop = nil;
		health.colorReaction = nil;
		health.colorOverlay = nil;
		health.overlayAnimation = PORTRAIT_OVERLAY_ANIMATION;

		if((not GRID_MODE) and frame.HealPrediction) then
			frame.HealPrediction["frequentUpdates"] = health.frequentUpdates
		end

		if((not GRID_MODE) and PORTRAIT_OVERLAY and SV.db.UnitFrames.forceHealthColor) then
			health.colorOverlay = true;
		else
			local CLASSCOLOR = db.health.classColor or false;
			local VALUECOLOR = (not CLASSCOLOR and db.health.valueColor) or false;

			health.colorClass = CLASSCOLOR;
			health.colorReaction = CLASSCOLOR;
			health.colorSmooth = VALUECOLOR;
			health.colorHealth = ((not CLASSCOLOR) and (not VALUECOLOR)) or false;
			health.colorBackdrop = db.health.classBackdrop;
		end

		health:ClearAllPoints()
		health:SetAllPoints(MASTER_GRIP)

		health.gridMode = GRID_MODE;

		if(db.health and db.health.orientation) then
			health:SetOrientation(GRID_MODE and "VERTICAL" or db.health.orientation)
		end

		if(frame.RefreshHealthBar) then
			frame:RefreshHealthBar(PORTRAIT_OVERLAY)
		end
	end

	--[[ POWER LAYOUT ]]--

	do
		if(POWER_GRIP) then
			if(POWER_ENABLED) then
				if(not frame:IsElementEnabled('Power')) then
					frame:EnableElement('Power')
					POWER_GRIP:Show()
				end

				POWER_GRIP.Smooth = SV.db.UnitFrames.smoothbars;

				POWER_GRIP.colorClass = nil;
				POWER_GRIP.colorReaction = nil;
				POWER_GRIP.colorPower = nil;

				local CLASSCOLOR = db.power.classColor or false;
				POWER_GRIP.colorClass = CLASSCOLOR;
				POWER_GRIP.colorReaction = CLASSCOLOR;
				POWER_GRIP.colorPower = (not CLASSCOLOR);
				POWER_GRIP.frequentUpdates = db.power.frequentUpdates;

				POWER_GRIP:ClearAllPoints()

				if(db.power and POWER_POINT) then
					local a1,a2,ax,ay,b1,b2,bx,by = unpack(POWER_POINT)

					POWER_GRIP:SetPoint(a1, MASTER_GRIP, a2, ax, ay)
					if(b1) then
						POWER_GRIP:SetPoint(b1, MASTER_GRIP, b2, bx, by)
					end
					POWER_GRIP:SetSize((POWER_WIDTH - 2), (POWER_HEIGHT - 2))
					POWER_GRIP.Panel:ClearAllPoints()

					if(POWER_DETACHED) then
						POWER_GRIP.Panel:WrapPoints(POWER_GRIP,2,2)
						if(frame.InfoPanel) then
							frame.InfoPanel:ClearAllPoints()
							if(db.power.anchor == "BOTTOM") then
								frame.InfoPanel:SetPoint("TOPLEFT", POWER_GRIP, "BOTTOMLEFT", 0, 1)
								frame.InfoPanel:SetPoint("TOPRIGHT", POWER_GRIP, "BOTTOMRIGHT", 0, 1)
							else
								frame.InfoPanel:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, 1)
								frame.InfoPanel:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", 0, 1)
							end
						end
					else
						POWER_GRIP.Panel:WrapPoints(POWER_GRIP)
					end
				else
					POWER_GRIP:SetHeight(POWER_HEIGHT - 2)
					POWER_GRIP:SetPoint(BOTTOM_ANCHOR1, MASTER_GRIP, BOTTOM_ANCHOR1, (1 * TOP_MODIFIER), 1)
					POWER_GRIP:SetPoint(BOTTOM_ANCHOR2, MASTER_GRIP, BOTTOM_ANCHOR2, (1 * BOTTOM_MODIFIER), 1)
				end

				if(db.power and db.power.orientation) then
					POWER_GRIP:SetOrientation(db.power.orientation)
				end
			elseif(frame:IsElementEnabled('Power')) then
				frame:DisableElement('Power')
				POWER_GRIP:Hide()
			end
		end

		--[[ ALTPOWER LAYOUT ]]--

		if(frame.AltPowerBar) then
			local altPower = frame.AltPowerBar;
			if(db.power.enable) then
				local Alt_OnShow = function()
					if(not POWER_DETACHED) then
						MASTER_GRIP:SetPoint(TOP_ANCHOR2, frame, TOP_ANCHOR2, PORTRAIT_WIDTH, -(POWER_HEIGHT + 1))
					end
				end

				local Alt_OnHide = function()
					if(not POWER_DETACHED) then
						MASTER_GRIP:SetPoint(TOP_ANCHOR2, frame, TOP_ANCHOR2, PORTRAIT_WIDTH, -1)
					end
					altPower.text:SetText("")
				end

				frame:EnableElement('AltPowerBar')
				if(TEXT_GRIP.Health) then
					altPower.text:SetFont(TEXT_GRIP.Health:GetFont())
				end
				altPower.text:SetAlpha(1)
				altPower:SetPoint(TOP_ANCHOR2, frame, TOP_ANCHOR2, PORTRAIT_WIDTH, -1)
				altPower:SetPoint(TOP_ANCHOR1, frame, TOP_ANCHOR1, (1 * BOTTOM_MODIFIER), -1)
				altPower:SetHeight(POWER_HEIGHT)
				altPower.Smooth = SV.db.UnitFrames.smoothbars;
				altPower:HookScript("OnShow", Alt_OnShow)
				altPower:HookScript("OnHide", Alt_OnHide)
			else
				frame:DisableElement('AltPowerBar')
				altPower.text:SetAlpha(0)
				altPower:Hide()
			end
		end
	end

	--[[ PORTRAIT LAYOUT ]]--

	if(PORTRAIT_GRIP) then
		local PORTRAIT = frame.Portrait;

		if(PORTRAIT and PORTRAIT_ENABLED) then
			if not frame:IsElementEnabled('Portrait')then
				frame:EnableElement('Portrait')
			end

			PORTRAIT_GRIP:SetAlpha(1)
			PORTRAIT_GRIP:ClearAllPoints()
			if(PORTRAIT_OVERLAY) then
				PORTRAIT_GRIP:InsetPoints(MASTER_GRIP,2,2)
				PORTRAIT_GRIP.Outline:Hide()
			else
				PORTRAIT_GRIP:SetPoint(TOP_ANCHOR1, MASTER_GRIP, TOP_ANCHOR2, 0, -2)
				PORTRAIT_GRIP:SetPoint(BOTTOM_ANCHOR2, MASTER_GRIP, BOTTOM_ANCHOR1, 0, 2)
				PORTRAIT_GRIP:SetWidth(PORTRAIT_WIDTH - 2)
				PORTRAIT_GRIP.Outline:Show()
			end

			if(PORTRAIT.ForceUpdate) then PORTRAIT:ForceUpdate() end

			PORTRAIT_GRIP:Show()
		else
			PORTRAIT_GRIP:Hide()

			if frame:IsElementEnabled('Portrait') then
				frame:DisableElement('Portrait')
			end
		end
	end

	--[[ CASTBAR LAYOUT ]]--

	if(db.castbar and frame.Castbar) then
		local castbar = frame.Castbar;
		local castHeight = db.castbar.height;
		local castWidth
		if(db.castbar.matchFrameWidth) then
			castWidth = UNIT_WIDTH
		else
			castWidth = db.castbar.width
		end
		local sparkSize = castHeight * 3;
		--local adjustedWidth = castWidth - 2;
		local lazerScale = castHeight * 1.8;

		if(db.castbar.format) then castbar.TimeFormat = db.castbar.format end

		if(not castbar.pewpew) then
			castbar:SetSize(castWidth, castHeight)
		elseif(castbar:GetHeight() ~= lazerScale) then
			castbar:SetSize(castWidth, lazerScale)
		end

		if castbar.Spark then
			if(db.castbar.spark) then
				castbar.Spark:Show()
				castbar.Spark:SetSize(sparkSize, sparkSize)
				if castbar.Spark[1] and castbar.Spark[2] then
					castbar.Spark[1]:SetAllPoints(castbar.Spark)
					castbar.Spark[2]:InsetPoints(castbar.Spark, 4, 4)
				end
				castbar.Spark.SetHeight = SV.fubar
			else
				castbar.Spark:Hide()
			end
		end
		castbar:SetFrameStrata("HIGH")
		if castbar.Holder then
			castbar.Holder:SetSize((castWidth + 2), (castHeight + 6))
			local holderUpdate = castbar.Holder:GetScript('OnSizeChanged')
			if holderUpdate then
				holderUpdate(castbar.Holder)
			end
		end
		castbar:GetStatusBarTexture():SetHorizTile(false)
		if db.castbar.latency then
			castbar.SafeZone = castbar.LatencyTexture;
			castbar.LatencyTexture:Show()
		else
			castbar.SafeZone = nil;
			castbar.LatencyTexture:Hide()
		end

		if castbar.Organizer then
			local orgSize = castHeight + 2
			castbar.Organizer:SetSize(orgSize, orgSize)
		end

		if castbar.Icon then
			if db.castbar.icon then
				castbar.Organizer.Icon:SetAllPoints(castbar.Organizer)
				castbar.Organizer.Icon:Show()
			else
				castbar.Organizer.Icon:Hide()
			end
		end

		local cr,cg,cb
		if(db.castbar.useCustomColor) then
			cr,cg,cb = db.castbar.castingColor[1], db.castbar.castingColor[2], db.castbar.castingColor[3];
			castbar.CastColor = {cr,cg,cb}
			cr,cg,cb = db.castbar.sparkColor[1], db.castbar.sparkColor[2], db.castbar.sparkColor[3];
			castbar.SparkColor = {cr,cg,cb}
		else
			castbar.CastColor = oUF_SVUI.colors.casting
			castbar.SparkColor = oUF_SVUI.colors.spark
		end

		if db.castbar.enable and not frame:IsElementEnabled('Castbar')then
			frame:EnableElement('Castbar')
		elseif not db.castbar.enable and frame:IsElementEnabled('Castbar')then
			frame:DisableElement('Castbar')
		end
	end

	--[[ AURA LAYOUT ]]--

	if(BUFF_GRIP or DEBUFF_GRIP) then
		if((not BUFF_ENABLED) and (not DEBUFF_ENABLED)) then
			if(frame:IsElementEnabled('Aura')) then
				frame:DisableElement('Aura')
			end
			BUFF_GRIP:Hide()
			DEBUFF_GRIP:Hide()
		else
			if(not frame:IsElementEnabled('Aura')) then
				frame:EnableElement('Aura')
			end

			if(BUFF_GRIP) then
				if(BUFF_ENABLED) then
					BUFF_GRIP:Show()

					local rows 		= db.buffs.numrows;
					local columns = db.buffs.perrow;
					local spacing = db.buffs.spacing;
					local count 	= columns * rows;
					local auraSize;

					if(BUFF_GRIP.Bars and BUFF_GRIP.Icons) then
						BUFF_GRIP.UseBars = db.buffs.useBars or false;
						--if(template == 'player') then print(db.buffs.useBars) end
						if(BUFF_GRIP.UseBars and (BUFF_GRIP.UseBars == true)) then
							count = db.buffs.barCount;
							if(db.buffs.anchorPoint == "BELOW") then
								BUFF_GRIP.down = true
							else
								BUFF_GRIP.down = false
							end
							--if(template == 'player') then print('WIPING BUFF ICONS') end
							for i = 1, #BUFF_GRIP.Icons do
								BUFF_GRIP.Icons[i]:Hide()
							end
						else
							--if(template == 'player') then print('WIPING BUFF BARS') end
							for i = 1, #BUFF_GRIP.Bars do
								BUFF_GRIP.Bars[i]:Hide()
							end
						end
					end

					if(db.buffs.sizeOverride and db.buffs.sizeOverride > 0) then
						auraSize = db.buffs.sizeOverride
						BUFF_GRIP.barHeight = db.buffs.sizeOverride
					else
						local tempSize = (((UNIT_WIDTH + spacing) - (spacing * (columns - 1))) / columns);
						auraSize = min(BEST_SIZE, tempSize)
						BUFF_GRIP.barHeight = 16
					end

					if(db.buffs.barWidthOverride and db.buffs.barWidthOverride > 0) then
						BUFF_GRIP.barWidth = db.buffs.barWidthOverride
					else
						BUFF_GRIP.barWidth = nil
					end

					BUFF_GRIP.spacing  		= spacing;
					BUFF_GRIP.auraSize  	= auraSize;
					BUFF_GRIP.maxCount 		= GRID_MODE and 0 or count;
					BUFF_GRIP.maxRows 		= rows;
					BUFF_GRIP.maxColumns 	= columns;
					BUFF_GRIP.forceShow 	= frame.forceShowAuras;

					local attachTo = db.buffs.attachTo;
					if(attachTo == 'DEBUFFS' and (not DEBUFF_ENABLED)) then
						attachTo = 'FRAME'
					end

					local attachAnchor = FindAnchorFrame(frame, attachTo, attachTo == 'DEBUFFS' and db.debuffs.attachTo == 'BUFFS')
					BUFF_GRIP:ClearAllPoints()
					SV:SetReversePoint(BUFF_GRIP, db.buffs.anchorPoint, attachAnchor, db.buffs.xOffset + BOTTOM_MODIFIER, db.buffs.yOffset)
					BUFF_GRIP["growth-y"] = db.buffs.verticalGrowth;
					BUFF_GRIP["growth-x"] = db.buffs.horizontalGrowth;
					BUFF_GRIP:SetSorting(db.buffs.sort)
					BUFF_GRIP:ForceUpdate()
				else
					BUFF_GRIP:Hide()
				end
			end
			if(DEBUFF_GRIP) then
				if(DEBUFF_ENABLED) then
					DEBUFF_GRIP:Show()
					local rows 		= db.debuffs.numrows;
					local columns = db.debuffs.perrow;
					local spacing = db.debuffs.spacing;
					local count 	= columns * rows;
					local auraSize;

					if(DEBUFF_GRIP.Bars and DEBUFF_GRIP.Icons) then
						DEBUFF_GRIP.UseBars = db.debuffs.useBars or false;
						if(DEBUFF_GRIP.UseBars and (DEBUFF_GRIP.UseBars == true)) then
							count = db.debuffs.barCount;
							if(db.debuffs.anchorPoint == "BELOW") then
								DEBUFF_GRIP.down = true
							else
								DEBUFF_GRIP.down = false
							end
							for i = 1, #DEBUFF_GRIP.Icons do
								DEBUFF_GRIP.Icons[i]:Hide()
							end
						else
							for i = 1, #DEBUFF_GRIP.Bars do
								DEBUFF_GRIP.Bars[i]:Hide()
							end
						end
					end

					if(db.debuffs.sizeOverride and db.debuffs.sizeOverride > 0) then
						auraSize = db.debuffs.sizeOverride
						DEBUFF_GRIP.barHeight = db.debuffs.sizeOverride
					else
						local tempSize = (((UNIT_WIDTH + spacing) - (spacing * (columns - 1))) / columns);
						auraSize = min(BEST_SIZE, tempSize)
						DEBUFF_GRIP.barHeight = 16
					end

					if(db.debuffs.barWidthOverride and db.debuffs.barWidthOverride > 0) then
						DEBUFF_GRIP.barWidth = db.debuffs.barWidthOverride
					else
						DEBUFF_GRIP.barWidth = nil
					end

					DEBUFF_GRIP.spacing  = spacing;
					DEBUFF_GRIP.auraSize  	= auraSize;
					DEBUFF_GRIP.maxRows 	= rows;
					DEBUFF_GRIP.maxColumns 	= columns;
					DEBUFF_GRIP.maxCount 	= GRID_MODE and 0 or count;
					DEBUFF_GRIP.forceShow 	= frame.forceShowAuras;

					local attachTo = db.debuffs.attachTo;
					if(attachTo == 'BUFFS' and (not BUFF_ENABLED)) then
						attachTo = 'FRAME'
					end

					local attachAnchor = FindAnchorFrame(frame, attachTo, attachTo == 'BUFFS' and db.buffs.attachTo == 'DEBUFFS')
					DEBUFF_GRIP:ClearAllPoints()
					SV:SetReversePoint(DEBUFF_GRIP, db.debuffs.anchorPoint, attachAnchor, db.debuffs.xOffset + BOTTOM_MODIFIER, db.debuffs.yOffset)
					DEBUFF_GRIP["growth-y"] = db.debuffs.verticalGrowth;
					DEBUFF_GRIP["growth-x"] = db.debuffs.horizontalGrowth;
					DEBUFF_GRIP:SetSorting(db.debuffs.sort)
					DEBUFF_GRIP:ForceUpdate()
				else
					DEBUFF_GRIP:Hide()
				end
			end
		end
	end

	if(RAID_DEBUFFS) then
		if RAID_DEBUFFS_ENABLED then
			RAID_DEBUFFS.forceShow 	= frame.forceShowAuras;
			if(not frame:IsElementEnabled("RaidDebuffs")) then
				frame:EnableElement("RaidDebuffs")
			end
			local actualSz = db.rdebuffs.size
			RAID_DEBUFFS:SetSize(actualSz, actualSz)
			RAID_DEBUFFS:SetPoint("CENTER", frame, "CENTER", db.rdebuffs.xOffset, db.rdebuffs.yOffset)
			RAID_DEBUFFS:Show()
		else
			RAID_DEBUFFS.forceShow 	= nil;
			frame:DisableElement("RaidDebuffs")
			RAID_DEBUFFS:Hide()
		end
	end

	--[[ ICON LAYOUTS ]]--

	do
		if db.icons then
			local ico = db.icons;

			--[[ CLASS ICON ]]--

			if(ico.classIcon and frame.ActionPanel.class) then
				local classIcon = frame.ActionPanel.class;
				if ico.classIcon.enable then
					classIcon:Show()
					local size = ico.classIcon.size;
					classIcon:ClearAllPoints()

					classIcon:SetAlpha(1)
					classIcon:SetSize(size, size)
					SV:SetReversePoint(classIcon, ico.classIcon.attachTo, MASTER_GRIP, ico.classIcon.xOffset, ico.classIcon.yOffset)
				else
					classIcon:Hide()
				end
			end

			--[[ RAIDICON ]]--

			if(ico.raidicon and frame.RaidIcon) then
				local raidIcon = frame.RaidIcon;
				if ico.raidicon.enable then
					raidIcon:Show()
					frame:EnableElement('RaidIcon')
					local size = ico.raidicon.size;
					raidIcon:ClearAllPoints()

					if(GRID_MODE) then
						raidIcon:SetAlpha(0.7)
						raidIcon:SetSize(10, 10)
						raidIcon:SetPoint("TOP", MASTER_GRIP, "TOP", 0, 0)
					else
						raidIcon:SetAlpha(1)
						raidIcon:SetSize(size, size)
						SV:SetReversePoint(raidIcon, ico.raidicon.attachTo, MASTER_GRIP, ico.raidicon.xOffset, ico.raidicon.yOffset)
					end
				else
					frame:DisableElement('RaidIcon')
					raidIcon:Hide()
				end
			end

			--[[ ROLEICON ]]--

			if(ico.roleIcon and frame.LFDRole) then
				local lfd = frame.LFDRole;
				if(not MINI_GRID and ico.roleIcon.enable) then
					lfd:Show()
					frame:EnableElement('LFDRole')
					local size = ico.roleIcon.size;
					lfd:ClearAllPoints()

					if(GRID_MODE) then
						lfd:SetAlpha(0.7)
						lfd:SetSize(10, 10)
						lfd:SetPoint("BOTTOM", MASTER_GRIP, "BOTTOM", 0, 0)
					else
						lfd:SetAlpha(1)
						lfd:SetSize(size, size)
						SV:SetReversePoint(lfd, ico.roleIcon.attachTo, MASTER_GRIP, ico.roleIcon.xOffset, ico.roleIcon.yOffset)
					end
				else
					frame:DisableElement('LFDRole')
					lfd:Hide()
				end
			end

			--[[ RAIDROLEICON ]]--

			if(ico.raidRoleIcons and frame.RaidRoleFramesAnchor) then
				local roles = frame.RaidRoleFramesAnchor;
				if(not MINI_GRID and ico.raidRoleIcons.enable) then
					roles:Show()
					frame:EnableElement('Leader')
					frame:EnableElement('MasterLooter')
					local size = ico.raidRoleIcons.size;
					roles:ClearAllPoints()

					if(GRID_MODE) then
						roles:SetAlpha(0.7)
						roles:SetSize(10, 10)
						roles:SetPoint("CENTER", MASTER_GRIP, "TOPLEFT", 0, 2)
					else
						roles:SetAlpha(1)
						roles:SetSize(size, size)
						SV:SetReversePoint(roles, ico.raidRoleIcons.attachTo, MASTER_GRIP, ico.raidRoleIcons.xOffset, ico.raidRoleIcons.yOffset)
					end
				else
					roles:Hide()
					frame:DisableElement('Leader')
					frame:DisableElement('MasterLooter')
				end
			end

		end
	end

	--[[ HEAL PREDICTION LAYOUT ]]--

	if frame.HealPrediction then
		if db.predict then
			if not frame:IsElementEnabled('HealPrediction')then
				frame:EnableElement('HealPrediction')
			end
		else
			if frame:IsElementEnabled('HealPrediction')then
				frame:DisableElement('HealPrediction')
			end
		end
	end

	--[[ DEBUFF HIGHLIGHT LAYOUT ]]--

	if frame.Afflicted then
		if SV.db.UnitFrames.debuffHighlighting then
			frame.Afflicted.forceShow 	= frame.forceShowHighlights;
			frame.Afflicted:ClearAllPoints()
			frame.Afflicted:SetAllPoints(MASTER_GRIP)
			-- if(template ~= "player" and template ~= "target" and template ~= "focus") then
			-- 	frame.Afflicted.Texture:SetTexture(SV.BaseTexture)
			-- end
			frame:EnableElement('Afflicted')
		else
			frame.Afflicted.forceShow 	= nil;
			frame:DisableElement('Afflicted')
		end
	end

	--[[ RANGE CHECK LAYOUT ]]--

	if frame.Range then
		if(template:find("raid") or template:find("party")) then
			frame.Range.outsideAlpha = SV.db.UnitFrames.groupOORAlpha or 1
		else
			frame.Range.outsideAlpha = SV.db.UnitFrames.OORAlpha or 1
		end

		if db.rangeCheck then
			if not frame:IsElementEnabled('Range')then
				frame:EnableElement('Range')
			end
		else
			if frame:IsElementEnabled('Range')then
				frame:DisableElement('Range')
			end
		end
	end

	--[[ AURA WATCH LAYOUT ]]--

	if(frame.AuraWatch) then
		if(db.auraWatch) then
			if db.auraWatch.enable then
				if not frame:IsElementEnabled('AuraWatch')then
					frame:EnableElement('AuraWatch')
				end
				frame.AuraWatch:ForceUpdate()
			else
				if frame:IsElementEnabled('AuraWatch')then
					frame:DisableElement('AuraWatch')
				end
			end
		end
	end

	if(frame.XRay) then
        if(SV.db.UnitFrames.xrayFocus) then
            frame.XRay:Show()
        else
            frame.XRay:Hide()
        end
    end

	if(self.PostRefreshUpdate) then
		self:PostRefreshUpdate(frame, template)
	end
end
--[[
##########################################################
EVENTS AND INITIALIZE
##########################################################
]]--
function MOD:FrameForge()
	if not LoadedUnitFrames then
		self:SetUnitFrame("player")
		self:SetUnitFrame("pet")
		self:SetUnitFrame("pettarget")
		self:SetUnitFrame("target")
		self:SetUnitFrame("targettarget")
		self:SetUnitFrame("focus")
		self:SetUnitFrame("focustarget")
		self:SetEnemyFrame("boss", MAX_BOSS_FRAMES)
		self:SetEnemyFrame("arena", 5)
		LoadedUnitFrames = true;
	end
	if not LoadedGroupHeaders then
		self:SetGroupFrame("tank")
		self:SetGroupFrame("assist")
		self:SetGroupFrame("raid")
		self:SetGroupFrame("raidpet")
		self:SetGroupFrame("party")
		LoadedGroupHeaders = true
	end
	if(self.PostFrameForge) then
		self:PostFrameForge()
	end
end

function MOD:KillBlizzardRaidFrames()
	if(InCombatLockdown()) then return end
	if((not _G.CompactRaidFrameManager) or (not _G.CompactRaidFrameContainer) or (not _G.CompactUnitFrameProfiles)) then return end
	_G.CompactRaidFrameManager:Die()
	_G.CompactRaidFrameContainer:Die()
	_G.CompactUnitFrameProfiles:Die()
	local crfmTest = CompactRaidFrameManager_GetSetting("IsShown")
	if crfmTest and crfmTest ~= "0" then
		CompactRaidFrameManager_SetSetting("IsShown", "0")
	end
end

function MOD:PLAYER_REGEN_DISABLED()
	for _,frame in pairs(self.Headers) do
		if frame and frame.forceShow then
			self:ViewGroupFrames(frame)
		end
	end

	for _,frame in pairs(self.Units) do
		if(frame and frame.forceShow and frame.Restrict) then
			frame:Restrict()
		end
	end
end

function MOD:PLAYER_REGEN_ENABLED()
	self:UnregisterEvent("PLAYER_REGEN_ENABLED");
	self:RefreshUnitFrames()
end

function MOD:ADDON_LOADED(event, addon)
	self:KillBlizzardRaidFrames()
	if addon == 'Blizzard_ArenaUI' then
		oUF_SVUI:DisableBlizzard('arena')
		self:UnregisterEvent("ADDON_LOADED")
	end
end

function MOD:PLAYER_ENTERING_WORLD()
	if(not SV.NeedsFrameAudit) then
		self:RefreshUnitFrames()
	end
end

local UnitFrameThreatIndicator_Hook = function(unit, unitFrame)
	unitFrame:UnregisterAllEvents()
end
--[[
##########################################################
CLASS SPECIFIC INFO
##########################################################
]]--
local RefMagicSpec;
local PlayerClass = select(2,UnitClass("player"));
local droodSpell1, droodSpell2 = GetSpellInfo(110309), GetSpellInfo(4987);

if(PlayerClass == "PRIEST") then
    MOD.Dispellable = {["Magic"] = true, ["Disease"] = true}
elseif(PlayerClass == "MAGE") then
    MOD.Dispellable = {["Curse"] = true}
elseif(PlayerClass == "DRUID") then
    RefMagicSpec = 4
    MOD.Dispellable = {["Curse"] = true, ["Poison"] = true}
elseif(PlayerClass == "SHAMAN") then
    RefMagicSpec = 3
    MOD.Dispellable = {["Curse"] = true}
elseif(PlayerClass == "MONK") then
    RefMagicSpec = 2
    MOD.Dispellable = {["Disease"] = true, ["Poison"] = true}
elseif(PlayerClass == "PALADIN") then
    RefMagicSpec = 1
    MOD.Dispellable = {["Poison"] = true, ["Disease"] = true}
end

local function GetTalentInfo(arg)
    if type(arg) == "number" then
        return arg == GetActiveSpecGroup();
    else
        return false;
    end
end

function MOD:CanClassDispel()
	if RefMagicSpec then
    if(GetTalentInfo(RefMagicSpec)) then
      self.Dispellable["Magic"] = true
    elseif(self.Dispellable["Magic"]) then
      self.Dispellable["Magic"] = nil
    end
  end
end

function MOD:SPELLS_CHANGED()
	if (PlayerClass ~= "DRUID") then
		self:UnregisterEvent("SPELLS_CHANGED")
		return
	end
	if GetSpellInfo(droodSpell1) == droodSpell2 then
		self.Dispellable["Disease"] = true
	elseif(self.Dispellable["Disease"]) then
		self.Dispellable["Disease"] = nil
	end
end
--[[
##########################################################
BUILD FUNCTION / UPDATE
##########################################################
]]--
function MOD:ReLoad()
	self:RefreshUnitFrames()
end

function MOD:Load()
	self:RefreshUnitColors()

	local SVUI_UnitFrameParent = CreateFrame("Frame", "SVUI_UnitFrameParent", SV.Screen, "SecureHandlerStateTemplate")
	RegisterStateDriver(SVUI_UnitFrameParent, "visibility", "[petbattle] hide; show")

	self:CanClassDispel()

	self:FrameForge()
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("SPELLS_CHANGED")

	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", "CanClassDispel")
	self:RegisterEvent("PLAYER_TALENT_UPDATE", "CanClassDispel")
	self:RegisterEvent("CHARACTER_POINTS_CHANGED", "CanClassDispel")
	self:RegisterEvent("UNIT_INVENTORY_CHANGED", "CanClassDispel")
	self:RegisterEvent("UPDATE_BONUS_ACTIONBAR", "CanClassDispel")

	if(SV.db.UnitFrames.disableBlizzard) then
		self:KillBlizzardRaidFrames()
		-- This doesn't work as intended any more: Nameplates are now UnitFrames based on CompactUnitFrame and just unhooking RegisterEvent 
		-- means that the nameplates can't register events and therefore can't update (e.g. bars don't update)
		-- hooksecurefunc("CompactUnitFrame_RegisterEvents", CompactUnitFrame_UnregisterEvents)
		oUF_SVUI:DisableBlizzard("player")
		oUF_SVUI:DisableBlizzard("pet")
		oUF_SVUI:DisableBlizzard("pettarget")
		oUF_SVUI:DisableBlizzard("target")
		oUF_SVUI:DisableBlizzard("targettarget")
		oUF_SVUI:DisableBlizzard("focus")
		oUF_SVUI:DisableBlizzard("focustarget")
		oUF_SVUI:DisableBlizzard("boss")

		hooksecurefunc("UnitFrameThreatIndicator_Initialize", UnitFrameThreatIndicator_Hook)

		--[[
		InterfaceOptionsFrameCategoriesButton10:SetScale(0.0001)
		InterfaceOptionsFrameCategoriesButton11:SetScale(0.0001)
		InterfaceOptionsStatusTextPanelPlayer:SetScale(0.0001)
		InterfaceOptionsStatusTextPanelTarget:SetScale(0.0001)
		InterfaceOptionsStatusTextPanelParty:SetScale(0.0001)
		InterfaceOptionsStatusTextPanelPet:SetScale(0.0001)
		InterfaceOptionsStatusTextPanelPlayer:SetAlpha(0)
		InterfaceOptionsStatusTextPanelTarget:SetAlpha(0)
		InterfaceOptionsStatusTextPanelParty:SetAlpha(0)
		InterfaceOptionsStatusTextPanelPet:SetAlpha(0)
		InterfaceOptionsCombatPanelEnemyCastBarsOnPortrait:SetAlpha(0)
		InterfaceOptionsCombatPanelEnemyCastBarsOnPortrait:EnableMouse(false)
		InterfaceOptionsCombatPanelTargetOfTarget:SetScale(0.0001)
		InterfaceOptionsCombatPanelTargetOfTarget:SetAlpha(0)
		InterfaceOptionsCombatPanelEnemyCastBarsOnNameplates:ClearAllPoints()
		InterfaceOptionsCombatPanelEnemyCastBarsOnNameplates:SetPoint(InterfaceOptionsCombatPanelEnemyCastBarsOnPortrait:GetPoint())
		InterfaceOptionsDisplayPanelShowAggroPercentage:SetScale(0.0001)
		InterfaceOptionsDisplayPanelShowAggroPercentage:SetAlpha(0)
		]]--

		if not IsAddOnLoaded("Blizzard_ArenaUI") then
			self:RegisterEvent("ADDON_LOADED")
		else
			oUF_SVUI:DisableBlizzard("arena")
		end

		self:RegisterEvent("GROUP_ROSTER_UPDATE", "KillBlizzardRaidFrames")
		UIParent:UnregisterEvent("GROUP_ROSTER_UPDATE")
	elseif(CompactUnitFrameProfiles) then
		CompactUnitFrameProfiles:RegisterEvent("VARIABLES_LOADED")
	end

	SV.Events:On("AURA_FILTER_OPTIONS_CHANGED", UpdateUnitFrames, true);

	--self:InitializeBodyGuard()

	local rDebuffs = SV.oUF_RaidDebuffs or oUF_RaidDebuffs;
	if not rDebuffs then return end
	rDebuffs.ShowDispelableDebuff = true;
	rDebuffs.FilterDispellableDebuff = true;
	rDebuffs.MatchBySpellName = true;
end
