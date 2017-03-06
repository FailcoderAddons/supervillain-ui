--[[
##########################################################
S V U I   By: S.Jackson
##########################################################
LOCALIZED LUA FUNCTIONS
##########################################################
]]--

--[[ GLOBALS ]]--

local _G = _G;
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
local rawset            = _G.rawset;
local rawget            = _G.rawget;
local getmetatable      = _G.getmetatable;
local setmetatable      = _G.setmetatable;
local loadstring        = _G.loadstring;
local string    = _G.string;
local math 		= _G.math;
local table 	= _G.table;
local rept      = string.rep;
local tsort,twipe = table.sort,table.wipe;
local floor,ceil  = math.floor, math.ceil;
--BLIZZARD API
local CreateFrame           = _G.CreateFrame;
local InCombatLockdown      = _G.InCombatLockdown;
local GameTooltip           = _G.GameTooltip;
local hooksecurefunc        = _G.hooksecurefunc;
local IsAltKeyDown          = _G.IsAltKeyDown;
local IsShiftKeyDown        = _G.IsShiftKeyDown;
local IsControlKeyDown      = _G.IsControlKeyDown;
local IsModifiedClick       = _G.IsModifiedClick;
local PlaySound             = _G.PlaySound;
local PlaySoundFile         = _G.PlaySoundFile;
local PlayMusic             = _G.PlayMusic;
local StopMusic             = _G.StopMusic;
local GetTime               = _G.GetTime;
local ToggleFrame           = _G.ToggleFrame;
local EquipItemByName       = _G.EquipItemByName;
local IsSpellKnown      	= _G.IsSpellKnown;
local ERR_NOT_IN_COMBAT     = _G.ERR_NOT_IN_COMBAT;
local RAID_CLASS_COLORS     = _G.RAID_CLASS_COLORS;
local CUSTOM_CLASS_COLORS   = _G.CUSTOM_CLASS_COLORS;

--[[  CONSTANTS ]]--

_G.BINDING_HEADER_SVUICRAFT = "Supervillain UI: Craft-O-Matic";
_G.BINDING_NAME_SVUICRAFT_FISH = "Toggle Fishing Mode";
_G.BINDING_NAME_SVUICRAFT_FARM = "Toggle Farming Mode";
_G.BINDING_NAME_SVUICRAFT_COOK = "Toggle Cooking Mode";
_G.BINDING_NAME_SVUICRAFT_ARCH = "Toggle Archaeology Mode";

--[[
##########################################################
GET ADDON DATA
##########################################################
]]--
local SV = _G["SVUI"];
local L = SV.L;
local PLUGIN = select(2, ...)
local CONFIGS = SV.defaults[PLUGIN.Schema];

local NewHook = hooksecurefunc;
local playerGUID = UnitGUID('player')
local classColor = RAID_CLASS_COLORS
--[[
##########################################################
GLOBAL BINDINGS
##########################################################
]]--
_G.SVUIFishingMode = function()
	if InCombatLockdown() then SV:AddonMessage(ERR_NOT_IN_COMBAT); return; end
	if PLUGIN.CurrentMode and PLUGIN.CurrentMode == "Fishing" then PLUGIN:EndJobModes() else PLUGIN:SetJobMode("Fishing") end
end

_G.SVUIFarmingMode = function()
	if InCombatLockdown() then SV:AddonMessage(ERR_NOT_IN_COMBAT); return; end
	if PLUGIN.CurrentMode and SV.CurrentMode == "Farming" then PLUGIN:EndJobModes() else PLUGIN:SetJobMode("Farming") end
end

_G.SVUIArchaeologyMode = function()
	if InCombatLockdown() then SV:AddonMessage(ERR_NOT_IN_COMBAT); return; end
	if PLUGIN.CurrentMode and PLUGIN.CurrentMode == "Archaeology" then PLUGIN:EndJobModes() else PLUGIN:SetJobMode("Archaeology") end
end

_G.SVUICookingMode = function()
	if InCombatLockdown() then SV:AddonMessage(ERR_NOT_IN_COMBAT); return; end
	if PLUGIN.CurrentMode and PLUGIN.CurrentMode == "Cooking" then PLUGIN:EndJobModes() else PLUGIN:SetJobMode("Cooking") end
end
--[[
##########################################################
LOCALIZED GLOBALS
##########################################################
]]--
local LOOT_ITEM_SELF = _G.LOOT_ITEM_SELF;
local LOOT_ITEM_CREATED_SELF = _G.LOOT_ITEM_CREATED_SELF;
local LOOT_ITEM_SELF_MULTIPLE = _G.LOOT_ITEM_SELF_MULTIPLE
local LOOT_ITEM_PUSHED_SELF_MULTIPLE = _G.LOOT_ITEM_PUSHED_SELF_MULTIPLE
local LOOT_ITEM_PUSHED_SELF = _G.LOOT_ITEM_PUSHED_SELF
--[[
##########################################################
LOCAL VARS
##########################################################
]]--
local currentModeKey = false;
local ModeLogsFrame = CreateFrame("Frame", "SVUI_ModeLogsFrame", UIParent)
local classColors = CUSTOM_CLASS_COLORS[SV.class]
local classR, classG, classB = classColors.r, classColors.g, classColors.b
local classA = 0.35
local lastClickTime;
local ICON_FILE = [[Interface\AddOns\SVUI_CraftOMatic\artwork\DOCK-LABORER]]
local COOK_ICON = [[Interface\AddOns\SVUI_CraftOMatic\artwork\LABORER-COOKING]]
local FISH_ICON = [[Interface\AddOns\SVUI_CraftOMatic\artwork\LABORER-FISHING]]
local ARCH_ICON = [[Interface\AddOns\SVUI_CraftOMatic\artwork\LABORER-SURVEY]]
local FARM_ICON = [[Interface\AddOns\SVUI_CraftOMatic\artwork\LABORER-FARMING]]
--[[
##########################################################
LOCAL FUNCTIONS
##########################################################
]]--
local function onMouseWheel(self, delta)
	if (delta > 0) then
		self:ScrollUp()
	elseif (delta < 0) then
		self:ScrollDown()
	end
end

local function CheckForDoubleClick()
	if lastClickTime then
		local pressTime = GetTime()
		local doubleTime = pressTime - lastClickTime
		if ( (doubleTime < 0.4) and (doubleTime > 0.05) ) then
			lastClickTime = nil
			return true
		end
	end
	lastClickTime = GetTime()
	return false
end
--[[
##########################################################
CHAT LOG PARSING FUNCTIONS (from LibDeformat  by:ckknight)
##########################################################
]]--
local ChatDeFormat;
do
    local FORMAT_SEQUENCES = {
        ["s"] = ".+",
        ["c"] = ".",
        ["%d*d"] = "%%-?%%d+",
        ["[fg]"] = "%%-?%%d+%%.?%%d*",
        ["%%%.%d[fg]"] = "%%-?%%d+%%.?%%d*",
    }

    local STRING_BASED_SEQUENCES = {
        ["s"] = true,
        ["c"] = true,
    }

    local cache = setmetatable({}, {__mode='k'})

    local function _deformat(pattern)
        local func = cache[pattern]
        if func then return func end
        local unpattern = '^' .. pattern:gsub("([%(%)%.%*%+%-%[%]%?%^%$%%])", "%%%1") .. '$'
        local number_indexes = {}
        local index_translation = nil
        local highest_index
        if not pattern:find("%%1%$") then
            local i = 0
            while true do
                i = i + 1
                local first_index
                local first_sequence
                for sequence in pairs(FORMAT_SEQUENCES) do
                    local index = unpattern:find("%%%%" .. sequence)
                    if index and (not first_index or index < first_index) then
                        first_index = index
                        first_sequence = sequence
                    end
                end
                if not first_index then
                    break
                end
                unpattern = unpattern:gsub("%%%%" .. first_sequence, "(" .. FORMAT_SEQUENCES[first_sequence] .. ")", 1)
                number_indexes[i] = not STRING_BASED_SEQUENCES[first_sequence]
            end
            highest_index = i - 1
        else
            local i = 0
            while true do
                i = i + 1
                local found_sequence
                for sequence in pairs(FORMAT_SEQUENCES) do
                    if unpattern:find("%%%%" .. i .. "%%%$" .. sequence) then
                        found_sequence = sequence
                        break
                    end
                end
                if not found_sequence then
                    break
                end
                unpattern = unpattern:gsub("%%%%" .. i .. "%%%$" .. found_sequence, "(" .. FORMAT_SEQUENCES[found_sequence] .. ")", 1)
                number_indexes[i] = not STRING_BASED_SEQUENCES[found_sequence]
            end
            highest_index = i - 1
            i = 0
            index_translation = {}
            pattern:gsub("%%(%d)%$", function(w)
                i = i + 1
                index_translation[i] = tonumber(w)
            end)
        end
        if highest_index == 0 then
            cache[pattern] = SV.fubar
        else
            local t = {}
            t[#t+1] = [=[
                return function(text)
                    local ]=]
            for i = 1, highest_index do
                if i ~= 1 then
                    t[#t+1] = ", "
                end
                t[#t+1] = "a"
                if not index_translation then
                    t[#t+1] = i
                else
                    t[#t+1] = index_translation[i]
                end
            end
            t[#t+1] = [=[ = text:match(]=]
            t[#t+1] = ("%q"):format(unpattern)
            t[#t+1] = [=[)
                if not a1 then
                    return ]=]
            for i = 1, highest_index do
                if i ~= 1 then
                    t[#t+1] = ", "
                end
                t[#t+1] = "nil"
            end
            t[#t+1] = "\n"
            t[#t+1] = [=[
                end
            ]=]
            t[#t+1] = "return "
            for i = 1, highest_index do
                if i ~= 1 then
                    t[#t+1] = ", "
                end
                t[#t+1] = "a"
                t[#t+1] = i
                if number_indexes[i] then
                    t[#t+1] = "+0"
                end
            end
            t[#t+1] = "\n"
            t[#t+1] = [=[
                end
            ]=]
            t = table.concat(t, "")
            cache[pattern] = assert(loadstring(t))()
        end
        return cache[pattern]
    end

    ChatDeFormat = function(text, pattern)
        if((type(text) == "string") and (type(pattern) == "string")) then
            return _deformat(pattern)(text)
        end
        return false;
    end
end
--[[
##########################################################
WORLDFRAME HANDLER
##########################################################
]]--
local _hook_WorldFrame_OnMouseDown = function(self, button)
	if InCombatLockdown() then return end
	if(currentModeKey and button == "RightButton" and CheckForDoubleClick()) then
		local handle = PLUGIN[currentModeKey];
		if(handle and handle.Bind) then
			handle.Bind()
		end
	end
end

local ModeCapture_PostClickHandler = function(self, button)
	if InCombatLockdown() then
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		return
	end
	ClearOverrideBindings(self)
	self.Handler:Hide()
end

local ModeCapture_EventHandler = function(self, event, ...)
	if event == "PLAYER_REGEN_ENABLED" then
		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
		PLUGIN:ChangeModeGear()
		ModeCapture_PostClickHandler(self)
	end
	if event == "PLAYER_ENTERING_WORLD" then
		if (IsSpellKnown(131474) or IsSpellKnown(80451) or IsSpellKnown(818)) then
			WorldFrame:HookScript("OnMouseDown", _hook_WorldFrame_OnMouseDown)
		end
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	end
end

local Handler = CreateFrame("Frame", nil, UIParent)
Handler:SetPoint("LEFT", UIParent, "RIGHT", 10000, 0)
local ModeCapture = CreateFrame("Button", "SVUI_ModeCaptureWindow", UIParent, "SecureActionButtonTemplate")
ModeCapture.Handler = Handler
ModeCapture:EnableMouse(true)
ModeCapture:RegisterForClicks("RightButtonUp")
ModeCapture:RegisterEvent("PLAYER_ENTERING_WORLD")
ModeCapture:SetScript("PostClick", ModeCapture_PostClickHandler)
ModeCapture:SetScript("OnEvent", ModeCapture_EventHandler)

ModeCapture:Hide()
--[[
##########################################################
CORE FUNCTIONS
##########################################################
]]--
function PLUGIN:CraftingReset()
	self.TitleWindow:Clear();
	self.LogWindow:Clear();
	self.TitleWindow:AddMessage("Crafting Modes", 1, 1, 0);
	self.LogWindow:AddMessage("Select a Tool to Begin", 1, 1, 1);
	self.LogWindow:AddMessage(" ", 0, 1, 1);
	collectgarbage("collect")
end

function PLUGIN:ModeLootLoader(mode, msg, info)
	self.TitleWindow:Clear();
	self.LogWindow:Clear();
	self.ModeAlert.HelpText = info
	if(mode and self[mode]) then
		if(self[mode].Log) then
			local stored = self[mode].Log;
			self.TitleWindow:AddMessage(msg, 1, 1, 1);
			local previous = false
			for name,data in pairs(stored) do
				if type(data) == "table" and data.amount and data.texture then
					self.LogWindow:AddMessage("|cff55FF55"..data.amount.." x|r |T".. data.texture ..":16:16:0:0:64:64:4:60:4:60|t".." "..name, 0.8, 0.8, 0.8);
					previous = true
				end
			end
			if(previous) then
				self.LogWindow:AddMessage("----------------", 0, 0, 0);
				self.LogWindow:AddMessage(" ", 0, 0, 0);
			end
			self.LogWindow:AddMessage(info, 1, 1, 1);
			self.LogWindow:AddMessage(" ", 1, 1, 1);
		end
	else
		self:CraftingReset()
	end
end

function PLUGIN:CheckForModeLoot(msg)
  	local item, amt, item_check = ChatDeFormat(msg, LOOT_ITEM_SELF_MULTIPLE)
	if not item then
	  item = ChatDeFormat(msg, LOOT_ITEM_CREATED_SELF)
	  	if not item then
		  item = ChatDeFormat(msg, LOOT_ITEM_SELF)
		  	if not item then
		      	item = ChatDeFormat(msg, LOOT_ITEM_PUSHED_SELF_MULTIPLE)
		      	if not item then
		        	item, amt = ChatDeFormat(msg, LOOT_ITEM_PUSHED_SELF)
		        	--print(item)
		      	end
		    end
		end
	end

	--print(msg)
	if item then
		if not amt then
		  	amt = 1
		end
		return item, amt
	end
end

function PLUGIN:SetJobMode(category)
	if InCombatLockdown() then return end
	if(not category) then
		self:EndJobModes()
		return;
	end
	self:ChangeModeGear()
	if(currentModeKey and self[currentModeKey] and self[currentModeKey].Disable) then
		if(currentModeKey == category) then 
			self:EndJobModes()
			return; 
		else
			self:EndJobModes()
		end
	end
	currentModeKey = category;
	if(self[category] and self[category].Enable) then
		for key,button in pairs(self.ToolBar.Buttons) do
			if(key == category) then
				button.currentColor = "highlight";
				button.icon:SetGradient(unpack(SV.media.gradient.highlight))
				button:SetAlpha(1)
			else
				button.currentColor = "icon";
				button.icon:SetGradient(unpack(SV.media.gradient.icon))
				button:SetAlpha(0.5)
			end
		end
		self[category].Enable()
	else
		self:EndJobModes()
		return;
	end
end

function PLUGIN:EndJobModes()
	for key,button in pairs(self.ToolBar.Buttons) do
		button.currentColor = "icon";
		button.icon:SetGradient(unpack(SV.media.gradient.icon));
		button:SetAlpha(1);
	end
	if(currentModeKey and self[currentModeKey] and self[currentModeKey].Disable) then
		self[currentModeKey].Disable()
	end
	currentModeKey = false;
	--if self.Docklet:IsShown() then self.Docklet.Button:Click() end
	self:ChangeModeGear()
	self.ModeAlert:Hide();
	SV:SCTMessage("Mode Disabled", 1, 0.35, 0);
	PlaySound("UndeadExploration");
	self:CraftingReset()
end

function PLUGIN:ChangeModeGear()
	if(not self.InModeGear) then return end
	if InCombatLockdown() then
		_G["SVUI_ModeCaptureWindow"]:RegisterEvent("PLAYER_REGEN_ENABLED");
		return
	else
		if(self.WornItems["HEAD"]) then
			EquipItemByName(self.WornItems["HEAD"])
			self.WornItems["HEAD"] = false
		end
		if(self.WornItems["TAB"]) then
			EquipItemByName(self.WornItems["TAB"])
			self.WornItems["TAB"] = false
		end
		if(self.WornItems["MAIN"]) then
			EquipItemByName(self.WornItems["MAIN"])
			self.WornItems["MAIN"] = false
		end
		if(self.WornItems["OFF"]) then
			EquipItemByName(self.WornItems["OFF"])
			self.WornItems["OFF"] = false
		end

		self.InModeGear = false
	end
end

function PLUGIN:SKILL_LINES_CHANGED()
	if(currentModeKey and self[currentModeKey] and self[currentModeKey].Update) then
		self[currentModeKey].Update()
	end
end
--[[
##########################################################
BUILD FUNCTION / UPDATE
##########################################################
]]--
local ModeAlert_OnEnter = function(self)
	if InCombatLockdown() then return; end
	self:SetBackdropColor(0.9, 0.15, 0.1)
	GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 4)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(self.ModeText, 1, 1, 0)
	GameTooltip:AddLine("")
	GameTooltip:AddLine("Click here end this mode.", 0.79, 0.23, 0.23)
	GameTooltip:AddLine("")
	GameTooltip:AddLine(self.HelpText, 0.74, 1, 0.57)
	GameTooltip:Show()
end

local ModeAlert_OnLeave = function(self)
	GameTooltip:Hide()
	if InCombatLockdown() then return end
	self:SetBackdropColor(0.25, 0.52, 0.1)
end

local ModeAlert_OnHide = function()
	if InCombatLockdown() then
		SV:AddonMessage(ERR_NOT_IN_COMBAT);
		return;
	end
	PLUGIN.Docklet.Parent.Alert:Deactivate()
end

local ModeAlert_OnShow = function(self)
	if InCombatLockdown() then
		SV:AddonMessage(ERR_NOT_IN_COMBAT);
		return;
	end
	PLUGIN.Docklet.Parent.Alert:Activate(self)
end

local ModeAlert_OnMouseDown = function(self)
	PLUGIN:EndJobModes()
	self:FadeOut(0.5, 1, 0, true)
end

local ModeButton_OnEnter = function(self)
	if InCombatLockdown() then return; end
	local name = self.modeName
	self.icon:SetGradient(unpack(SV.media.gradient.yellow))
	GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 4)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(L[name .. " Mode"], 1, 1, 1)
	GameTooltip:Show()
end

local ModeButton_OnLeave = function(self)
	if InCombatLockdown() then return; end
	self.icon:SetGradient(unpack(SV.media.gradient[self.currentColor]))
	GameTooltip:Hide()
end

local ModeButton_OnMouseDown = function(self)
	local name = self.modeName
	PLUGIN:SetJobMode(name)
end
--[[
##########################################################
SIZING CALLBACK
##########################################################
]]--
local function ResizeCraftingDock()
	local DOCK_HEIGHT = PLUGIN.Docklet.Parent.Window:GetHeight();
	SVUI_ModesDockToolBar:SetHeight(DOCK_HEIGHT);
end

SV.Events:On("DOCKS_UPDATED", ResizeCraftingDock, true);
--[[
##########################################################
BUILD FUNCTION
##########################################################
]]--
function PLUGIN:Load()
	CONFIGS = SV.db[self.Schema];

	lastClickTime = nil;
	self.WornItems = {};
	self.InModeGear = false;

	self.Docklet = SV.Dock:NewDocklet("BottomRight", "SVUI_ModesDockFrame", self.TitleID, ICON_FILE);

	local DOCK_HEIGHT = self.Docklet.Parent.Window:GetHeight();
	local DOCKLET_HEIGHT = DOCK_HEIGHT - 4;
	local BUTTON_SIZE = (DOCK_HEIGHT * 0.25) - 4;

	local toolBar = CreateFrame("Frame", "SVUI_ModesDockToolBar", self.Docklet)
	toolBar:SetWidth(BUTTON_SIZE + 4);
	toolBar:SetHeight((BUTTON_SIZE + 4) * 4);
	toolBar:SetPoint("BOTTOMLEFT", self.Docklet, "BOTTOMLEFT", 0, 0);

	local tool4 = CreateFrame("Frame", nil, toolBar)
	tool4:SetPoint("BOTTOM",toolBar,"BOTTOM",0,0)
	tool4:SetSize(BUTTON_SIZE,BUTTON_SIZE)
	tool4.icon = tool4:CreateTexture(nil, 'BACKGROUND')
	tool4.icon:SetTexture(FARM_ICON)
	tool4.icon:InsetPoints(tool4)
	tool4.icon:SetGradient("VERTICAL", 0.5, 0.53, 0.55, 0.8, 0.8, 1)
	tool4.modeName = "Farming"
	tool4.currentColor = "icon"
	tool4:SetScript('OnEnter', ModeButton_OnEnter)
	tool4:SetScript('OnLeave', ModeButton_OnLeave)
	tool4:SetScript('OnMouseDown', ModeButton_OnMouseDown)

	local tool3 = CreateFrame("Frame", nil, toolBar)
	tool3:SetPoint("BOTTOM",tool4,"TOP",0,2)
	tool3:SetSize(BUTTON_SIZE,BUTTON_SIZE)
	tool3.icon = tool3:CreateTexture(nil, 'BACKGROUND')
	tool3.icon:SetTexture(ARCH_ICON)
	tool3.icon:InsetPoints(tool3)
	tool3.icon:SetGradient("VERTICAL", 0.5, 0.53, 0.55, 0.8, 0.8, 1)
	tool3.modeName = "Archaeology"
	tool3.currentColor = "icon"
	tool3:SetScript('OnEnter', ModeButton_OnEnter)
	tool3:SetScript('OnLeave', ModeButton_OnLeave)
	tool3:SetScript('OnMouseDown', ModeButton_OnMouseDown)

	local tool2 = CreateFrame("Frame", nil, toolBar)
	tool2:SetPoint("BOTTOM",tool3,"TOP",0,2)
	tool2:SetSize(BUTTON_SIZE,BUTTON_SIZE)
	tool2.icon = tool2:CreateTexture(nil, 'BACKGROUND')
	tool2.icon:SetTexture(FISH_ICON)
	tool2.icon:InsetPoints(tool2)
	tool2.icon:SetGradient("VERTICAL", 0.5, 0.53, 0.55, 0.8, 0.8, 1)
	tool2.modeName = "Fishing"
	tool2.currentColor = "icon"
	tool2:SetScript('OnEnter', ModeButton_OnEnter)
	tool2:SetScript('OnLeave', ModeButton_OnLeave)
	tool2:SetScript('OnMouseDown', ModeButton_OnMouseDown)

	local tool1 = CreateFrame("Frame", nil, toolBar)
	tool1:SetPoint("BOTTOM",tool2,"TOP",0,2)
	tool1:SetSize(BUTTON_SIZE,BUTTON_SIZE)
	tool1.icon = tool1:CreateTexture(nil, 'BACKGROUND')
	tool1.icon:SetTexture(COOK_ICON)
	tool1.icon:InsetPoints(tool1)
	tool1.icon:SetGradient("VERTICAL", 0.5, 0.53, 0.55, 0.8, 0.8, 1)
	tool1.modeName = "Cooking"
	tool1.currentColor = "icon"
	tool1:SetScript('OnEnter', ModeButton_OnEnter)
	tool1:SetScript('OnLeave', ModeButton_OnLeave)
	tool1:SetScript('OnMouseDown', ModeButton_OnMouseDown)

	local ModeAlert = CreateFrame("Frame", nil, SV.Screen)
	ModeAlert:SetAllSecurePoints(self.Docklet.Parent.Alert)
	ModeAlert:SetBackdrop(SV.media.backdrop.button)

	ModeAlert:SetBackdropBorderColor(0,0,0,1)
	ModeAlert:SetBackdropColor(0.25, 0.52, 0.1)
	ModeAlert.text = ModeAlert:CreateFontString(nil, 'ARTWORK', 'GameFontWhite')
	ModeAlert.text:SetAllPoints(ModeAlert)
	ModeAlert.text:SetTextColor(1, 1, 1)
	ModeAlert.text:SetJustifyH("CENTER")
	ModeAlert.text:SetJustifyV("MIDDLE")
	ModeAlert.text:SetText("Click to Exit")
	ModeAlert.ModeText = "Click to Exit";
	ModeAlert.HelpText = "";
	ModeAlert:SetScript('OnEnter', ModeAlert_OnEnter)
	ModeAlert:SetScript('OnLeave', ModeAlert_OnLeave)
	ModeAlert:SetScript('OnHide', ModeAlert_OnHide)
	ModeAlert:SetScript('OnShow', ModeAlert_OnShow)
	ModeAlert:SetScript('OnMouseDown', ModeAlert_OnMouseDown)
	ModeAlert:Hide()

	ModeLogsFrame:SetFrameStrata("MEDIUM")
	ModeLogsFrame:SetPoint("TOPLEFT", toolBar, "TOPRIGHT", 5, -5)
	ModeLogsFrame:SetPoint("BOTTOMRIGHT", self.Docklet, "BOTTOMRIGHT", -5, 5)
	ModeLogsFrame:SetParent(self.Docklet)

	local title = CreateFrame("ScrollingMessageFrame", nil, ModeLogsFrame)
	title:SetSpacing(4)
	title:SetClampedToScreen(false)
	title:SetFrameStrata("MEDIUM")
	title:SetPoint("TOPLEFT",ModeLogsFrame,"TOPLEFT",0,0)
	title:SetPoint("BOTTOMRIGHT",ModeLogsFrame,"TOPRIGHT",0,-20)
	title:SetFontObject(SVUI_Font_Header)
	title:SetMaxLines(1)
	title:EnableMouseWheel(false)
	title:SetFading(false)
	title:SetInsertMode('TOP')

	title.divider = title:CreateTexture(nil,"OVERLAY")
  	title.divider:SetColorTexture(0,0,0,0.5)
  	title.divider:SetPoint("BOTTOMLEFT")
  	title.divider:SetPoint("BOTTOMRIGHT")
  	title.divider:SetHeight(1)

	local topleftline = title:CreateTexture(nil,"OVERLAY")
	topleftline:SetColorTexture(0,0,0,0.5)
	topleftline:SetPoint("TOPLEFT")
	topleftline:SetPoint("BOTTOMLEFT")
	topleftline:SetWidth(1)

	local log = CreateFrame("ScrollingMessageFrame", nil, ModeLogsFrame)
	log:SetSpacing(4)
	log:SetClampedToScreen(false)
	log:SetFrameStrata("MEDIUM")
	log:SetPoint("TOPLEFT",title,"BOTTOMLEFT",0,0)
	log:SetPoint("BOTTOMRIGHT",ModeLogsFrame,"BOTTOMRIGHT",0,0)
	log:SetFontObject(SVUI_Font_Craft)
	log:SetJustifyH("CENTER")
	log:SetJustifyV("MIDDLE")
	log:SetShadowColor(0, 0, 0, 0)
	log:SetMaxLines(120)
	log:EnableMouseWheel(true)
	log:SetScript("OnMouseWheel", onMouseWheel)
	log:SetFading(false)
	log:SetInsertMode('TOP')

	local bottomleftline = log:CreateTexture(nil,"OVERLAY")
	bottomleftline:SetColorTexture(0,0,0,0.5)
	bottomleftline:SetPoint("TOPLEFT")
	bottomleftline:SetPoint("BOTTOMLEFT")
	bottomleftline:SetWidth(1)

	self.ToolBar = toolBar;
	self.ToolBar.Buttons = {
		["Cooking"] 	= tool1,
		["Fishing"] 	= tool2,
		["Archaeology"] = tool3,
		["Farming"] 	= tool4
	};

  	self.ModeAlert = ModeAlert;
	self.TitleWindow = title;
	self.LogWindow = log;
	--self.Docklet:Hide()
	self.ListenerEnabled = false;
	self:CraftingReset()
	self:LoadCookingMode()
	self:LoadFishingMode()
	self:LoadArchaeologyMode()
	self:PrepareFarmingTools()

	self:RegisterEvent("SKILL_LINES_CHANGED")
	SV.Events:On("DOCK_EXPANDED", ResizeCraftingDock, true);
end
