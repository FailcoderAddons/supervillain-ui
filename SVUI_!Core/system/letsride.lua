--[[
##########################################################
S V U I   By: Failcoder
##########################################################
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local unpack 		= _G.unpack;
local select 		= _G.select;
local pairs 		= _G.pairs;
local type          = _G.type;
local tonumber		= _G.tonumber;
local table 		= _G.table;
local math 			= _G.math;
local bit 			= _G.bit;
local random 		= math.random;
local twipe,band 	= table.wipe, bit.band;
--BLIZZARD API
local CreateFrame           = _G.CreateFrame;
local InCombatLockdown      = _G.InCombatLockdown;
local GameTooltip           = _G.GameTooltip;
local LoadAddOn             = _G.LoadAddOn;
local hooksecurefunc        = _G.hooksecurefunc;
local IsAltKeyDown          = _G.IsAltKeyDown;
local IsShiftKeyDown        = _G.IsShiftKeyDown;
local IsControlKeyDown      = _G.IsControlKeyDown;
local IsModifiedClick       = _G.IsModifiedClick;
local PlaySound             = _G.PlaySound;
local PlaySoundFile         = _G.PlaySoundFile;
local PlayMusic             = _G.PlayMusic;
local StopMusic             = _G.StopMusic;
local UnitName              = _G.UnitName;
local ToggleFrame           = _G.ToggleFrame;
local ERR_NOT_IN_COMBAT     = _G.ERR_NOT_IN_COMBAT;
local RAID_CLASS_COLORS     = _G.RAID_CLASS_COLORS;
local CUSTOM_CLASS_COLORS   = _G.CUSTOM_CLASS_COLORS;
local C_MountJournal        = _G.C_MountJournal;
--[[
##########################################################
GET ADDON DATA
##########################################################
]]--
local SV = select(2, ...);
--[[
##########################################################
LOCAL VARIABLES
##########################################################
]]--
local TOOLTIP_SUMMARY = "";
local MountListener = CreateFrame("Frame");
MountListener.favorites = false
--[[
##########################################################
LOCAL FUNCTIONS
##########################################################
]]--
local function CacheMounts()
	return C_MountJournal.GetMountIDs()
end

local function RandomMount()
	if(MountListener.favorites) then
		return 0
	end
	local maxMounts = C_MountJournal.GetNumMounts()
	return random(1, maxMounts)
end

local function MountInfo(index)
	index = index or RandomMount()
	return C_MountJournal.GetDisplayedMountInfo(index)
end

local function CheckFallbackDruidShaman()
	local _,class,_ = UnitClass('player')
	if (not IsMounted() and (class == "DRUID" or class == "SHAMAN")) then
	-- If we fail to mount, but we're a druid or shaman, we have a backup plan...
	-- JV: Working on this... TBC 
	end

end

local function MountUp(index)
	local _, _, _, _, _, _, _, _, _, _, _, id = MountInfo(index);
	if id then 
		C_MountJournal.SummonByID(id) 
		CheckFallbackDruidShaman()
	end
end

local UnMount = C_MountJournal.Dismiss

local function UpdateMountCheckboxes(button, index)
	local creatureName = MountInfo(index);

	local n = button.MountBar
	local bar = _G[n]

	if(bar) then
		bar["GROUND"].index = index
		bar["GROUND"].name = creatureName
		bar["FLYING"].index = index
		bar["FLYING"].name = creatureName
		bar["SWIMMING"].index = index
		bar["SWIMMING"].name = creatureName
	    bar["SPECIAL"].index = index
	    bar["SPECIAL"].name = creatureName

		if(SV.private.Mounts.names["GROUND"] == creatureName) then
			if(SV.private.Mounts.types["GROUND"] ~= index) then
				SV.private.Mounts.types["GROUND"] = index
			end
			bar["GROUND"]:SetChecked(true)
		else
			bar["GROUND"]:SetChecked(false)
		end

		if(SV.private.Mounts.names["FLYING"] == creatureName) then
			if(SV.private.Mounts.types["FLYING"] ~= index) then
				SV.private.Mounts.types["FLYING"] = index
			end
			bar["FLYING"]:SetChecked(true)
		else
			bar["FLYING"]:SetChecked(false)
		end

		if(SV.private.Mounts.names["SWIMMING"] == creatureName) then
			if(SV.private.Mounts.types["SWIMMING"] ~= index) then
				SV.private.Mounts.types["SWIMMING"] = index
			end
			bar["SWIMMING"]:SetChecked(true)
		else
			bar["SWIMMING"]:SetChecked(false)
		end

		if(SV.private.Mounts.names["SPECIAL"] == creatureName) then
			if(SV.private.Mounts.types["SPECIAL"] ~= index) then
				SV.private.Mounts.types["SPECIAL"] = index
			end
			bar["SPECIAL"]:SetChecked(true)
		else
			bar["SPECIAL"]:SetChecked(false)
		end
	end
end

local function UpdateMountsCache()
	if(not MountJournal) then return end
	local myMounts = CacheMounts();
	MountListener.favorites = false

	for index, id in pairs(myMounts) do
		--creatureName, spellID, icon, active, isUsable, sourceType, isFavorite, isFactionSpecific, faction, hideOnChar, isCollected, mountID
		local info, spellId, _, _, _, _, favorite, _, _, _, _, mId = MountInfo(index);
		if(favorite == true) then
			MountListener.favorites = true
		end
		if(SV.private.Mounts.names["GROUND"] == info) then
			if(SV.private.Mounts.types["GROUND"] ~= index) then
				SV.private.Mounts.types["GROUND"] = index
			end
		end
		if(SV.private.Mounts.names["FLYING"] == info) then
			if(SV.private.Mounts.types["FLYING"] ~= index) then
				SV.private.Mounts.types["FLYING"] = index
			end
		end
		if(SV.private.Mounts.names["SWIMMING"] == info) then
			if(SV.private.Mounts.types["SWIMMING"] ~= index) then
				SV.private.Mounts.types["SWIMMING"] = index
			end
		end
		if(SV.private.Mounts.names["SPECIAL"] == info) then
			if(SV.private.Mounts.types["SPECIAL"] ~= index) then
				SV.private.Mounts.types["SPECIAL"] = index
			end
		end
	end
end

local function Update_MountCheckButtons()
	if(not MountJournal) then return end
	local count = C_MountJournal.GetNumMounts();
	local scrollFrame = MountJournal.ListScrollFrame;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
  	local buttons = scrollFrame.buttons;
	for i=1, #buttons do
        local button = buttons[i];
        local displayIndex = i + offset;
        if ( displayIndex <= count ) then
			UpdateMountCheckboxes(button, displayIndex)
		end
	end
end

local ProxyUpdate_Mounts = function(self, event, ...)
	if(event == "COMPANION_LEARNED" or event == "COMPANION_UNLEARNED") then
		UpdateMountsCache()
	end
	Update_MountCheckButtons()
end

local function UpdateCurrentMountSelection()
	TOOLTIP_SUMMARY = ""
	local creatureName

	if(SV.private.Mounts.types["FLYING"]) then
		creatureName = SV.private.Mounts.names["FLYING"]
		if(creatureName) then
			TOOLTIP_SUMMARY = TOOLTIP_SUMMARY .. "\nFlying: " .. creatureName
		end
	end

	if(SV.private.Mounts.types["SWIMMING"]) then
		creatureName = SV.private.Mounts.names["SWIMMING"]
		if(creatureName) then
			TOOLTIP_SUMMARY = TOOLTIP_SUMMARY .. "\nSwimming: " .. creatureName
		end
	end

	if(SV.private.Mounts.types["GROUND"]) then
		creatureName = SV.private.Mounts.names["GROUND"]
		if(creatureName) then
			TOOLTIP_SUMMARY = TOOLTIP_SUMMARY .. "\nGround: " .. creatureName
		end
	end

	if(SV.private.Mounts.types["SPECIAL"]) then
		creatureName = SV.private.Mounts.names["SPECIAL"]
		if(creatureName) then
			TOOLTIP_SUMMARY = TOOLTIP_SUMMARY .. "\nSpecial: " .. creatureName
		end
	end
end

local CheckButton_OnClick = function(self)
	local index = self.index
	local name = self.name
	local key = self.key

	if(index) then
		if(self:GetChecked() == true) then
			SV.private.Mounts.types[key] = index
			SV.private.Mounts.names[key] = name
		else
			SV.private.Mounts.types[key] = false
			SV.private.Mounts.names[key] = ""
		end
		Update_MountCheckButtons()
		UpdateCurrentMountSelection()
	end
	GameTooltip:Hide()
end

local CheckButton_OnEnter = function(self)
	local index = self.name
	local key = self.key
	local r,g,b = self:GetBackdropColor()
	GameTooltip:SetOwner(self, 'ANCHOR_TOPLEFT', 0, 20)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(key,r,g,b)
	GameTooltip:AddLine("",1,1,0)
	GameTooltip:AddLine("Check this box to enable/disable \nthis mount for \nthe 'Lets Ride' key-binding",1,1,1)
	if(key == "SPECIAL") then
		GameTooltip:AddLine("",1,1,0)
		GameTooltip:AddLine("Hold |cff00FF00[SHIFT]|r or |cff00FF00[CTRL]|r while \nclicking to force this mount \nover all others.",1,1,1)
	end
	GameTooltip:AddLine(TOOLTIP_SUMMARY,1,1,1)

	GameTooltip:Show()
end

local CheckButton_OnLeave = function(self)
	GameTooltip:Hide()
end

local _hook_SetChecked = function(self, checked)
    local r,g,b = 0,0,0
    if(checked) then
        r,g,b = self:GetCheckedTexture():GetVertexColor()
    end
    self:SetBackdropBorderColor(r,g,b)
end

local function CreateMountCheckBox(name, parent)
	local frame = CreateFrame("CheckButton", name, parent, "UICheckButtonTemplate")
    frame:RemoveTextures()
	frame:SetBackdrop({
        bgFile = SV.media.statusbar.gloss,
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
    });

    if(frame.Left) then frame.Left:SetAlpha(0) end
    if(frame.Middle) then frame.Middle:SetAlpha(0) end
    if(frame.Right) then frame.Right:SetAlpha(0) end
    if(frame.SetNormalTexture) then frame:SetNormalTexture("") end
    if(frame.SetDisabledTexture) then frame:SetDisabledTexture("") end
    if(frame.SetCheckedTexture) then frame:SetCheckedTexture("") end
    if(frame.SetHighlightTexture) then
        if(not frame.hover) then
            local hover = frame:CreateTexture(nil, "HIGHLIGHT")
            hover:InsetPoints(frame.Panel)
            frame.hover = hover;
        end
        frame.hover:SetColorTexture(0.1, 0.8, 0.8, 0.5)
        frame:SetHighlightTexture(frame.hover)
    end
    if(frame.SetPushedTexture) then
        if(not frame.pushed) then
            local pushed = frame:CreateTexture(nil, "OVERLAY")
            pushed:InsetPoints(frame.Panel)
            frame.pushed = pushed;
        end
        frame.pushed:SetColorTexture(0.1, 0.8, 0.1, 0.3)
        frame:SetPushedTexture(frame.pushed)
    end
    if(frame.SetCheckedTexture) then
        if(not frame.checked) then
            local checked = frame:CreateTexture(nil, "OVERLAY")
            checked:InsetPoints(frame.Panel)
            frame.checked = checked
        end

        frame.checked:SetTexture(SV.media.statusbar.gloss)
        frame.checked:SetVertexColor(0, 1, 0, 1)

        frame:SetCheckedTexture(frame.checked)
    end

    hooksecurefunc(frame, "SetChecked", _hook_SetChecked)

    return frame
end;
--[[
##########################################################
LOAD BY TRIGGER
##########################################################
]]--
local function InitializeLetsRide()
	if(SV.GameVersion > 60000) then
		LoadAddOn("Blizzard_Collections")
	else
		LoadAddOn("Blizzard_PetJournal")
	end
	SV.private.Mounts = SV.private.Mounts or {}

	if not SV.private.Mounts.types then
		SV.private.Mounts.types = {
			["GROUND"] = false,
			["FLYING"] = false,
			["SWIMMING"] = false,
			["SPECIAL"] = false
		}
	end
	if not SV.private.Mounts.names then
		SV.private.Mounts.names = {
			["GROUND"] = "",
			["FLYING"] = "",
			["SWIMMING"] = "",
			["SPECIAL"] = ""
		}
	end

	UpdateMountsCache()

	local scrollFrame = MountJournal.ListScrollFrame;
	local scrollBar = _G["MountJournalListScrollFrameScrollBar"]
  	local buttons = scrollFrame.buttons;

	for i = 1, #buttons do
		local button = buttons[i]
		local barWidth = button:GetWidth()
		local width = (barWidth - 18) * 0.25
		local height = 7
		local barName = ("SVUI_MountSelectBar%d"):format(i)

		local buttonBar = CreateFrame("Frame", barName, button)
		buttonBar:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", 0, 0)
		buttonBar:SetSize(barWidth, height + 8)

		--[[ CREATE CHECKBOXES ]]--
		buttonBar["GROUND"] = CreateMountCheckBox(("%s_GROUND"):format(barName), buttonBar)
		buttonBar["GROUND"]:SetSize(width,height)
		buttonBar["GROUND"]:SetPoint("BOTTOMLEFT", buttonBar, "BOTTOMLEFT", 6, 4)
		buttonBar["GROUND"]:SetBackdropColor(0.2, 0.7, 0.1, 0.25)
		buttonBar["GROUND"]:SetBackdropBorderColor(0, 0, 0, 1)
		buttonBar["GROUND"]:GetCheckedTexture():SetVertexColor(0.2, 0.7, 0.1, 1)
		buttonBar["GROUND"].key = "GROUND"
		buttonBar["GROUND"]:SetChecked(false)
		buttonBar["GROUND"]:SetScript("OnClick", CheckButton_OnClick)
		buttonBar["GROUND"]:SetScript("OnEnter", CheckButton_OnEnter)
		buttonBar["GROUND"]:SetScript("OnLeave", CheckButton_OnLeave)

		buttonBar["FLYING"] = CreateMountCheckBox(("%s_FLYING"):format(barName), buttonBar)
		buttonBar["FLYING"]:SetSize(width,height)
		buttonBar["FLYING"]:SetPoint("BOTTOMLEFT", buttonBar["GROUND"], "BOTTOMRIGHT", 2, 0)
		buttonBar["FLYING"]:SetBackdropColor(1, 1, 0.2, 0.25)
		buttonBar["FLYING"]:SetBackdropBorderColor(0, 0, 0, 1)
		buttonBar["FLYING"]:GetCheckedTexture():SetVertexColor(1, 1, 0.2, 1)
		buttonBar["FLYING"].key = "FLYING"
		buttonBar["FLYING"]:SetChecked(false)
		buttonBar["FLYING"]:SetScript("OnClick", CheckButton_OnClick)
		buttonBar["FLYING"]:SetScript("OnEnter", CheckButton_OnEnter)
		buttonBar["FLYING"]:SetScript("OnLeave", CheckButton_OnLeave)

		buttonBar["SWIMMING"] = CreateMountCheckBox(("%s_SWIMMING"):format(barName), buttonBar)
		buttonBar["SWIMMING"]:SetSize(width,height)
		buttonBar["SWIMMING"]:SetPoint("BOTTOMLEFT", buttonBar["FLYING"], "BOTTOMRIGHT", 2, 0)
		buttonBar["SWIMMING"]:SetBackdropColor(0.2, 0.42, 0.76, 0.25)
		buttonBar["SWIMMING"]:SetBackdropBorderColor(0, 0, 0, 1)
		buttonBar["SWIMMING"]:GetCheckedTexture():SetVertexColor(0.2, 0.42, 0.76, 1)
		buttonBar["SWIMMING"].key = "SWIMMING"
		buttonBar["SWIMMING"]:SetChecked(false)
		buttonBar["SWIMMING"]:SetScript("OnClick", CheckButton_OnClick)
		buttonBar["SWIMMING"]:SetScript("OnEnter", CheckButton_OnEnter)
		buttonBar["SWIMMING"]:SetScript("OnLeave", CheckButton_OnLeave)

		buttonBar["SPECIAL"] = CreateMountCheckBox(("%s_SPECIAL"):format(barName), buttonBar)
		buttonBar["SPECIAL"]:SetSize(width,height)
		buttonBar["SPECIAL"]:SetPoint("BOTTOMLEFT", buttonBar["SWIMMING"], "BOTTOMRIGHT", 2, 0)
		buttonBar["SPECIAL"]:SetBackdropColor(0.7, 0.1, 0.1, 0.25)
		buttonBar["SPECIAL"]:SetBackdropBorderColor(0, 0, 0, 1)
		buttonBar["SPECIAL"]:GetCheckedTexture():SetVertexColor(0.7, 0.1, 0.1, 1)
		buttonBar["SPECIAL"].key = "SPECIAL"
		buttonBar["SPECIAL"]:SetChecked(false)
		buttonBar["SPECIAL"]:SetScript("OnClick", CheckButton_OnClick)
		buttonBar["SPECIAL"]:SetScript("OnEnter", CheckButton_OnEnter)
		buttonBar["SPECIAL"]:SetScript("OnLeave", CheckButton_OnLeave)

		button.MountBar = barName

		UpdateMountCheckboxes(button, i)
	end

	UpdateCurrentMountSelection()

	MountListener:RegisterEvent("MOUNT_JOURNAL_USABILITY_CHANGED")
	MountListener:RegisterEvent("COMPANION_LEARNED")
	MountListener:RegisterEvent("COMPANION_UNLEARNED")
	MountListener:RegisterEvent("COMPANION_UPDATE")
	MountListener:SetScript("OnEvent", ProxyUpdate_Mounts)

	scrollFrame:HookScript("OnMouseWheel", Update_MountCheckButtons)
	scrollBar:HookScript("OnValueChanged", Update_MountCheckButtons)
	hooksecurefunc("MountJournal_UpdateMountList", Update_MountCheckButtons)
end

SV.Events:On("CORE_INITIALIZED", InitializeLetsRide);
--[[
##########################################################
KEYBIND FUNCTION
##########################################################
]]--
_G.SVUILetsRide = function()
	local myMounts = CacheMounts()

	if(not myMounts or IsMounted()) then
		UnMount()
		return
	end

	if(CanExitVehicle()) then
		VehicleExit()
		return
	end

	SV.private.Mounts = SV.private.Mounts or {}
	if not SV.private.Mounts.types then
		SV.private.Mounts.types = {
			["GROUND"] = false,
			["FLYING"] = false,
			["SWIMMING"] = false,
			["SPECIAL"] = false
		}
	end

	local continent = GetCurrentMapContinent()
	local checkList = SV.private.Mounts.types
	local letsFly = (IsFlyableArea() and (continent ~= 962 and continent ~= 7))
	local letsSwim = IsSwimming()

	if(IsModifierKeyDown() and checkList["SPECIAL"]) then
		MountUp(checkList["SPECIAL"])
	else
		if(letsSwim) then
			if(checkList["SWIMMING"]) then
				MountUp(checkList["SWIMMING"])
			elseif(letsFly) then
				MountUp(checkList["FLYING"])
			else
				MountUp(checkList["GROUND"])
			end
		elseif(letsFly) then
			if(checkList["FLYING"]) then
				MountUp(checkList["FLYING"])
			else
				MountUp(checkList["GROUND"])
			end
		else
			MountUp(checkList["GROUND"])
		end
	end
end
