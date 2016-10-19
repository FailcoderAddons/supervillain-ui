--[[
##############################################################################
S V U I   By: Failcoder
##############################################################################
--]]
--[[ GLOBALS ]]--
local _G = _G;
--LUA
local unpack        = _G.unpack;
local select        = _G.select;
local assert        = _G.assert;
local type          = _G.type;
local error         = _G.error;
local pcall         = _G.pcall;
local print         = _G.print;
local ipairs        = _G.ipairs;
local pairs         = _G.pairs;
local next          = _G.next;
local rawset        = _G.rawset;
local rawget        = _G.rawget;
local tostring      = _G.tostring;
local tonumber      = _G.tonumber;
local getmetatable  = _G.getmetatable;
local setmetatable  = _G.setmetatable;
--STRING
local string        = _G.string;
local upper         = string.upper;
local format        = string.format;
local find          = string.find;
local match         = string.match;
local gsub          = string.gsub;
--MATH
local math          = _G.math;
local floor         = math.floor;
local random        = math.random;
--TABLE
local table         = _G.table;
local tsort         = table.sort;
local tconcat       = table.concat;
local tremove       = _G.tremove;
local twipe         = _G.wipe;
--BLIZZARD API
local CreateFrame           = _G.CreateFrame;
local InCombatLockdown      = _G.InCombatLockdown;
local GameTooltip           = _G.GameTooltip;

local SV = select(2, ...)
local L = SV.L
--[[
##########################################################
LOCAL VARS
##########################################################
]]--
local HenchmenFrame = CreateFrame("Frame", "HenchmenFrame", UIParent);
local STANDARD_TEXT_FONT = _G.STANDARD_TEXT_FONT
local OPTION_LEFT = [[Interface\Addons\SVUI_!Core\assets\textures\Doodads\HENCHMEN-OPTION-LEFT]];
local OPTION_RIGHT = [[Interface\Addons\SVUI_!Core\assets\textures\Doodads\HENCHMEN-OPTION-RIGHT]];
local OPTION_SUB = [[Interface\Addons\SVUI_!Core\assets\textures\Doodads\HENCHMEN-SUBOPTION]];
local SWITCH = [[Interface\Addons\SVUI_!Core\assets\textures\Doodads\HENCHMEN-MINION-SWITCH]];
local BUBBLE = [[Interface\Addons\SVUI_!Core\assets\textures\Doodads\HENCHMEN-SPEECH]];
local SUBOPTIONS = {};
local HENCHMEN_DATA = {
	{
		{40,"Adjust My Colors!","Color Themes","Click here to change your current color theme to one of the default sets."},
		{40,"Adjust My Frames!","Frame Styles","Click here to change your current frame styles to one of the default sets."},
		{0,"Adjust My Bars!","Bar Layouts","Click here to change your current actionbar layout to one of the default sets."},
		{-40,"Adjust My Auras!","Aura Layouts","Click here to change your buff/debuff layout to one of the default sets."},
		{-40,"Show Me All Options!","Config Screen","Click here to access the entire SVUI configuration."}
	},
	{
		{-40,"Accept Quests","Your minions will automatically accept quests for you", "autoquestaccept"},
		{-40,"Complete Quests","Your minions will automatically complete quests for you", "autoquestcomplete"},
		{0,"Select Rewards","Your minions will automatically select quest rewards for you", "autoquestreward"},
		{40,"Greed Roll","Your minions will automatically roll greed (or disenchant if available) on green quality items for you", "autoRoll"},
		{40,"Watch Factions","Your minions will automatically change your tracked reputation to the last faction you were awarded points for", "autorepchange"}
	}
}

local CALLOUTICON = {
	[[Interface\Addons\SVUI_!Core\assets\textures\Doodads\HENCHMEN-CALLOUT]],
	[[Interface\Addons\SVUI_!Core\assets\textures\Doodads\HENCHMEN-WTF]],
	[[Interface\Addons\SVUI_!Core\assets\textures\Doodads\HENCHMEN-WTF]],
	[[Interface\Addons\SVUI_!Core\assets\textures\Doodads\HENCHMEN-SRSLY]],
	[[Interface\Addons\SVUI_!Core\assets\textures\Doodads\HENCHMEN-SRSLY]],
	[[Interface\Addons\SVUI_!Core\assets\textures\Doodads\HENCHMEN-CALLOUT]],
	[[Interface\Addons\SVUI_!Core\assets\textures\Doodads\HENCHMEN-CALLOUT]]
};
SV.YOUR_HENCHMEN = {
	{49084,67,113,69,70,73,75}, --Rascal Bot
	{29404,67,113,69,70,73,75}, --Macabre Marionette
	{45613,0,5,10,69,10,69}, 	--Bishibosh
	{34770,70,82,70,82,70,82}, 	--Gilgoblin
	{45562,69,69,69,69,69,69}, 	--Burgle
	{37339,60,60,60,60,60,60}, 	--Augh
	{2323,67,113,69,70,73,75}, 	--Defias Henchman
}
--[[
##########################################################
SCRIPT HANDLERS
##########################################################
]]--
local ColorFunc = function(self) SV.Setup:ColorTheme(self.value, true); SV:ToggleHenchman() end
local UnitFunc = function(self) SV.Setup:UnitframeLayout(self.value, true); SV:ToggleHenchman() end
local BarFunc = function(self) SV.Setup:BarLayout(self.value, true); SV:ToggleHenchman() end
local AuraFunc = function(self) SV.Setup:Auralayout(self.value, true); SV:ToggleHenchman() end
local ConfigFunc = function() SV:ToggleConfig(); SV:ToggleHenchman() end
local speechTimer;

local Tooltip_Show = function(self)
	GameTooltip:SetOwner(HenchmenFrame,"ANCHOR_TOP",0,12)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(self.ttText)
	GameTooltip:Show()
end

local Tooltip_Hide = function(self)
	GameTooltip:Hide()
end

local Minion_OnMouseUp = function(self)
	local current = self.getval()
	if(not current) then
		self.indicator:SetTexCoord(0,1,0.5,1)
		self.setval(true)
	else
		self.indicator:SetTexCoord(0,1,0,0.5)
		self.setval(false)
	end
end

local Option_OnMouseUp = function(self)
	--print('Option_OnMouseUp Fired')
	if(type(self.callback) == "function") then
		self:callback()
	--else
		--print('Option_OnMouseUp No Callbacks')
	end
end

local SubOption_OnMouseUp = function(self)
	if not InCombatLockdown()then
		local name=self:GetName()
		for _,frame in pairs(SUBOPTIONS) do
			frame.anim:Finish()
			frame:Hide()
		end
		if not self.isopen then
			for i=1, self.suboptions do
				_G[name.."Sub"..i]:Show()
				_G[name.."Sub"..i].anim:Play()
				_G[name.."Sub"..i].anim:Finish()
			end
			self.isopen=true
		else
			self.isopen=false
		end
	end
end

local function UpdateHenchmanModel(hide)
	if(not hide and not HenchmenFrameModel:IsShown()) then
		local models = SV.YOUR_HENCHMEN
		local mod = random(1,#models)
		local emod = random(2,7)
		local id = models[mod][1]
		local emote = models[mod][emod]
		HenchmenCalloutFramePic:SetTexture(CALLOUTICON[mod])
		HenchmenFrameModel:ClearModel()
		HenchmenFrameModel:SetDisplayInfo(id)
		HenchmenFrameModel:SetAnimation(emote)
		HenchmenFrameModel:Show()
	else
		HenchmenFrameModel:Hide()
	end
end
--[[
##########################################################
CORE FUNCTIONS
##########################################################
]]--
local function CreateMinionOptions(i)
	local lastIndex = i - 1;
	local options = HENCHMEN_DATA[2][i]
	local offsetX = options[1]
	local option = CreateFrame("Frame", "MinionOptionButton"..i, HenchmenFrame)
	option:SetSize(148,50)

	if i==1 then
		option:SetPoint("TOP",_G["MinionOptionButton0"],"BOTTOM",offsetX,-32)
	else
		option:SetPoint("TOP",_G["MinionOptionButton"..lastIndex],"BOTTOM",offsetX,-32)
	end

	local setting = options[4];
	local dbSet = SV.db.Extras[setting];

	option.getval = function()
		return SV.db.Extras[setting]
	end
	option.setval = function(toggle)
		SV.db.Extras[setting] = toggle;
	end
	SV.Animate:Slide(option,-500,-500)
	option:SetFrameStrata("DIALOG")
	option:SetFrameLevel(24)
	option:EnableMouse(true)
	option.bg = option:CreateTexture(nil,"BORDER")
	option.bg:SetPoint("TOPLEFT",option,"TOPLEFT",-4,4)
	option.bg:SetPoint("BOTTOMRIGHT",option,"BOTTOMRIGHT",4,-24)
	option.bg:SetTexture(OPTION_LEFT)
	option.bg:SetVertexColor(1,1,1,0.6)
	option.txt = option:CreateFontString(nil,"DIALOG")
	option.txt:InsetPoints(option)
	option.txt:SetFont(SV.media.font.narrator,12,"NONE")
	option.txt:SetJustifyH("CENTER")
	option.txt:SetJustifyV("MIDDLE")
	option.txt:SetText(options[2])
	option.txt:SetTextColor(0,0,0)
	option.txthigh = option:CreateFontString(nil,"HIGHLIGHT")
	option.txthigh:InsetPoints(option)
	option.txthigh:SetFont(SV.media.font.narrator,12,"OUTLINE")
	option.txthigh:SetJustifyH("CENTER")
	option.txthigh:SetJustifyV("MIDDLE")
	option.txthigh:SetText(options[2])
	option.txthigh:SetTextColor(0,1,1)
	option.ttText = options[3]
	option.indicator = option:CreateTexture(nil,"OVERLAY")
	option.indicator:SetSize(100,32)
	option.indicator:SetPoint("RIGHT", option , "LEFT", -5, 0)
	option.indicator:SetTexture(SWITCH)
	if(not dbSet) then
		option.indicator:SetTexCoord(0,1,0,0.5)
	else
		option.indicator:SetTexCoord(0,1,0.5,1)
	end

	option:SetScript("OnEnter", Tooltip_Show)
	option:SetScript("OnLeave", Tooltip_Hide)
	option:SetScript("OnMouseUp", Minion_OnMouseUp)
end

local function CreateHenchmenOptions(i)
	local lastIndex = i - 1;
	local options = HENCHMEN_DATA[1][i]
	local offsetX = options[1]
	local option = CreateFrame("Frame", "HenchmenOptionButton"..i, HenchmenFrame)
	option:SetSize(148,50)
	if i==1 then
		option:SetPoint("TOP",_G["HenchmenOptionButton0"],"BOTTOM",offsetX,-32)
	else
		option:SetPoint("TOP",_G["HenchmenOptionButton"..lastIndex],"BOTTOM",offsetX,-32)
	end
	SV.Animate:Slide(option,500,-500)
	option:SetFrameStrata("DIALOG")
	option:SetFrameLevel(24)
	option:EnableMouse(true)
	option.bg = option:CreateTexture(nil,"BORDER")
	option.bg:SetPoint("TOPLEFT",option,"TOPLEFT",-4,4)
	option.bg:SetPoint("BOTTOMRIGHT",option,"BOTTOMRIGHT",4,-24)
	option.bg:SetTexture(OPTION_RIGHT)
	option.bg:SetVertexColor(1,1,1,0.6)
	option.txt = option:CreateFontString(nil,"DIALOG")
	option.txt:InsetPoints(option)
	option.txt:SetFont(SV.media.font.narrator,12,"NONE")
	option.txt:SetJustifyH("CENTER")
	option.txt:SetJustifyV("MIDDLE")
	option.txt:SetText(options[2])
	option.txt:SetTextColor(0,0,0)
	option.txthigh = option:CreateFontString(nil,"HIGHLIGHT")
	option.txthigh:InsetPoints(option)
	option.txthigh:SetFont(SV.media.font.narrator,12,"OUTLINE")
	option.txthigh:SetJustifyH("CENTER")
	option.txthigh:SetJustifyV("MIDDLE")
	option.txthigh:SetText(options[2])
	option.txthigh:SetTextColor(0,1,1)
	option.ttText = options[3]
	option:SetScript("OnEnter", Tooltip_Show)
	option:SetScript("OnLeave", Tooltip_Hide)
end

local function CreateHenchmenSubOptions(buttonIndex,optionIndex)
	local parent = _G["HenchmenOptionButton"..buttonIndex]
	local name = format("HenchmenOptionButton%dSub%d", buttonIndex, optionIndex);
	local calc = 90 * optionIndex;
	local yOffset = 180 - calc;
	local frame = CreateFrame("Frame",name,HenchmenFrame)
	frame:SetSize(122,50)
	frame:SetPoint("BOTTOMLEFT", parent, "TOPRIGHT", 75, yOffset)
	frame:SetFrameStrata("DIALOG")
	frame:SetFrameLevel(24)
	frame:EnableMouse(true)
	frame.bg = frame:CreateTexture(nil,"BORDER")
	frame.bg:SetPoint("TOPLEFT",frame,"TOPLEFT",-12,12)
	frame.bg:SetPoint("BOTTOMRIGHT",frame,"BOTTOMRIGHT",12,-18)
	frame.bg:SetTexture(OPTION_SUB)
	frame.bg:SetVertexColor(1,1,1,0.6)
	frame.txt = frame:CreateFontString(nil,"DIALOG")
	frame.txt:InsetPoints(frame)
	frame.txt:SetFontObject(SVUI_Font_Default)
	frame.txt:SetTextColor(1,1,1)
	frame.txthigh = frame:CreateFontString(nil,"HIGHLIGHT")
	frame.txthigh:InsetPoints(frame)
	frame.txthigh:SetFontObject(SVUI_Font_Default)
	frame.txthigh:SetTextColor(1,1,0)
	SV.Animate:Slide(frame,500,0)
	local soCount = #SUBOPTIONS + 1;
	SUBOPTIONS[soCount] = frame;
end

local function CreateHenchmenFrame()
	HenchmenFrame:SetParent(UIParent)
	HenchmenFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	HenchmenFrame:SetWidth(500)
	HenchmenFrame:SetHeight(500)
	HenchmenFrame:SetFrameStrata("DIALOG")
	HenchmenFrame:SetFrameLevel(24)
	SV.Animate:Slide(HenchmenFrame,0,-500)

	local model = CreateFrame("PlayerModel", "HenchmenFrameModel", HenchmenFrame)
	model:SetPoint("TOPLEFT",HenchmenFrame,25,-25)
	model:SetPoint("BOTTOMRIGHT",HenchmenFrame,-25,25)
	model:SetFrameStrata("DIALOG")
	model:SetPosition(0,0,0)
	model:Hide()

	HenchmenFrame:Hide()

	local HenchmenCalloutFrame = CreateFrame("Frame", "HenchmenCalloutFrame", UIParent)
	HenchmenCalloutFrame:SetPoint("BOTTOM",UIParent,"BOTTOM",100,150)
	HenchmenCalloutFrame:SetWidth(256)
	HenchmenCalloutFrame:SetHeight(128)
	HenchmenCalloutFrame:SetFrameStrata("DIALOG")
	HenchmenCalloutFrame:SetFrameLevel(24)
	SV.Animate:Slide(HenchmenCalloutFrame,-356,-278)
	local HenchmenCalloutFramePic = HenchmenCalloutFrame:CreateTexture("HenchmenCalloutFramePic","ARTWORK")
	HenchmenCalloutFramePic:SetTexture([[Interface\Addons\SVUI_!Core\assets\textures\Doodads\HENCHMEN-CALLOUT]])
	HenchmenCalloutFramePic:SetAllPoints(HenchmenCalloutFrame)
	HenchmenCalloutFrame:Hide()

	local HenchmenFrameBG = CreateFrame("Frame", "HenchmenFrameBG", UIParent)
	HenchmenFrameBG:SetAllPoints(WorldFrame)
	HenchmenFrameBG:SetBackdrop({bgFile = [[Interface\BUTTONS\WHITE8X8]]})
	HenchmenFrameBG:SetBackdropColor(0,0,0,0.9)
	HenchmenFrameBG:SetFrameStrata("DIALOG")
	HenchmenFrameBG:SetFrameLevel(22)
	HenchmenFrameBG:Hide()
	HenchmenFrameBG:SetScript("OnMouseUp", SV.ToggleHenchman)

	local h_option = CreateFrame("Frame", "HenchmenOptionButton0", HenchmenFrame)
	h_option:SetSize(148,50)
	h_option:SetPoint("TOPLEFT",HenchmenFrame,"TOPRIGHT",32,0)
	SV.Animate:Slide(h_option,500,-500)
	h_option:SetFrameStrata("DIALOG")
	h_option:SetFrameLevel(24)
	h_option:EnableMouse(true)
	h_option.bg = h_option:CreateTexture(nil,"BORDER")
	h_option.bg:SetPoint("TOPLEFT",h_option,"TOPLEFT",-4,4)
	h_option.bg:SetPoint("BOTTOMRIGHT",h_option,"BOTTOMRIGHT",4,-24)
	h_option.bg:SetTexture(OPTION_RIGHT)
	h_option.bg:SetVertexColor(1,1,1,0.6)
	h_option.txt = h_option:CreateFontString(nil,"DIALOG")
	h_option.txt:InsetPoints(h_option)
	h_option.txt:SetFont(SV.media.font.narrator,12,"NONE")
	h_option.txt:SetJustifyH("CENTER")
	h_option.txt:SetJustifyV("MIDDLE")
	h_option.txt:SetText("Random Backdrops!")
	h_option.txt:SetTextColor(0,0,0)
	h_option.txthigh = h_option:CreateFontString(nil,"HIGHLIGHT")
	h_option.txthigh:InsetPoints(h_option)
	h_option.txthigh:SetFont(SV.media.font.narrator,12,"OUTLINE")
	h_option.txthigh:SetJustifyH("CENTER")
	h_option.txthigh:SetJustifyV("MIDDLE")
	h_option.txthigh:SetText("Random Backdrops!")
	h_option.txthigh:SetTextColor(0,1,1)
	h_option.ttText = "Set a random texture for all unit frame backdrops!"
	h_option:SetScript("OnEnter", Tooltip_Show)
	h_option:SetScript("OnLeave", Tooltip_Hide)
	h_option:SetScript("OnMouseUp", function() SV.Setup:RandomBackdrops() end)

	local m_option = CreateFrame("Frame", "MinionOptionButton0", HenchmenFrame)
	m_option:SetSize(148,50)
	m_option:SetPoint("TOPRIGHT",HenchmenFrame,"TOPLEFT",-32,0)
	SV.Animate:Slide(m_option,-500,-500)
	m_option:SetFrameStrata("DIALOG")
	m_option:SetFrameLevel(24)
	m_option:EnableMouse(true)
	m_option.bg = m_option:CreateTexture(nil,"BORDER")
	m_option.bg:SetPoint("TOPLEFT",m_option,"TOPLEFT",-4,4)
	m_option.bg:SetPoint("BOTTOMRIGHT",m_option,"BOTTOMRIGHT",4,-24)
	m_option.bg:SetTexture(OPTION_LEFT)
	m_option.bg:SetVertexColor(1,1,1,0.6)
	m_option.txt = m_option:CreateFontString(nil,"DIALOG")
	m_option.txt:InsetPoints(m_option)
	m_option.txt:SetFont(SV.media.font.narrator,12,"NONE")
	m_option.txt:SetJustifyH("CENTER")
	m_option.txt:SetJustifyV("MIDDLE")
	m_option.txt:SetText("Comic Popups")
	m_option.txt:SetTextColor(0,0,0)
	m_option.txthigh = m_option:CreateFontString(nil,"HIGHLIGHT")
	m_option.txthigh:InsetPoints(m_option)
	m_option.txthigh:SetFont(SV.media.font.narrator,12,"OUTLINE")
	m_option.txthigh:SetJustifyH("CENTER")
	m_option.txthigh:SetJustifyV("MIDDLE")
	m_option.txthigh:SetText("Comic Popups")
	m_option.txthigh:SetTextColor(0,1,1)
	m_option.ttText = "Toggle the use of comic style popups in combat.";
	m_option.indicator = m_option:CreateTexture(nil,"OVERLAY")
	m_option.indicator:SetSize(100,32)
	m_option.indicator:SetPoint("RIGHT", m_option , "LEFT", -5, 0)
	m_option.indicator:SetTexture(SWITCH)
	m_option:SetScript("OnEnter", Tooltip_Show)
	m_option:SetScript("OnLeave", Tooltip_Hide)
	m_option:SetScript("OnMouseUp", Minion_OnMouseUp)
	m_option.getval = function()
		if(SV.db.FunStuff.comix == 'NONE') then
			return false
		else
			return SV.db.FunStuff.comix
		end
	end
	m_option.setval = function(toggle)
		local savedToggle = SV.db.FunStuff.comixLastState;
		if(toggle == true) then
			SV.db.FunStuff.comix = savedToggle;
		else
			SV.db.FunStuff.comix = 'NONE';
		end
	end

	if(SV.db.FunStuff.comix == 'NONE') then
		m_option.indicator:SetTexCoord(0,1,0,0.5)
	else
		m_option.indicator:SetTexCoord(0,1,0.5,1)
	end

	for i=1, 5 do
		CreateHenchmenOptions(i)
		CreateMinionOptions(i)
	end
	------------------------------------------------------------------------
	CreateHenchmenSubOptions(1,1)
	HenchmenOptionButton1Sub1.txt:SetText("KABOOM!")
	HenchmenOptionButton1Sub1.txthigh:SetText("KABOOM!")
	HenchmenOptionButton1Sub1.value = "kaboom"
	HenchmenOptionButton1Sub1.callback = ColorFunc
	HenchmenOptionButton1Sub1:SetScript("OnMouseUp", Option_OnMouseUp)

	CreateHenchmenSubOptions(1,2)
	HenchmenOptionButton1Sub2.txt:SetText("Darkness")
	HenchmenOptionButton1Sub2.txthigh:SetText("Darkness")
	HenchmenOptionButton1Sub2.value = "dark"
	HenchmenOptionButton1Sub2.callback = ColorFunc
	HenchmenOptionButton1Sub2:SetScript("OnMouseUp", Option_OnMouseUp)

	CreateHenchmenSubOptions(1,3)
	HenchmenOptionButton1Sub3.txt:SetText("Classy")
	HenchmenOptionButton1Sub3.txthigh:SetText("Classy")
	HenchmenOptionButton1Sub3.value = "classy"
	HenchmenOptionButton1Sub3.callback = ColorFunc
	HenchmenOptionButton1Sub3:SetScript("OnMouseUp", Option_OnMouseUp)

	CreateHenchmenSubOptions(1,4)
	HenchmenOptionButton1Sub4.txt:SetText("Vintage")
	HenchmenOptionButton1Sub4.txthigh:SetText("Vintage")
	HenchmenOptionButton1Sub4.value = "default"
	HenchmenOptionButton1Sub4.callback = ColorFunc
	HenchmenOptionButton1Sub4:SetScript("OnMouseUp", Option_OnMouseUp)

	HenchmenOptionButton1.suboptions = 4;
	HenchmenOptionButton1.isopen = false;
	HenchmenOptionButton1:SetScript("OnMouseUp",SubOption_OnMouseUp)
	------------------------------------------------------------------------
	CreateHenchmenSubOptions(2,1)
	HenchmenOptionButton2Sub1.txt:SetText("SUPER: Elaborate Frames")
	HenchmenOptionButton2Sub1.txthigh:SetText("SUPER: Elaborate Frames")
	HenchmenOptionButton2Sub1.value = "super"
	HenchmenOptionButton2Sub1.callback = UnitFunc
	HenchmenOptionButton2Sub1:SetScript("OnMouseUp", Option_OnMouseUp)

	CreateHenchmenSubOptions(2,2)
	HenchmenOptionButton2Sub2.txt:SetText("Simple: Basic Frames")
	HenchmenOptionButton2Sub2.txthigh:SetText("Simple: Basic Frames")
	HenchmenOptionButton2Sub2.value = "simple"
	HenchmenOptionButton2Sub2.callback = UnitFunc
	HenchmenOptionButton2Sub2:SetScript("OnMouseUp", Option_OnMouseUp)

	CreateHenchmenSubOptions(2,3)
	HenchmenOptionButton2Sub3.txt:SetText("Compact: Minimal Frames")
	HenchmenOptionButton2Sub3.txthigh:SetText("Compact: Minimal Frames")
	HenchmenOptionButton2Sub3.value = "compact"
	HenchmenOptionButton2Sub3.callback = UnitFunc
	HenchmenOptionButton2Sub3:SetScript("OnMouseUp", Option_OnMouseUp)

	HenchmenOptionButton2.suboptions = 3;
	HenchmenOptionButton2.isopen = false;
	HenchmenOptionButton2:SetScript("OnMouseUp",SubOption_OnMouseUp)
	------------------------------------------------------------------------
	CreateHenchmenSubOptions(3,1)
	HenchmenOptionButton3Sub1.txt:SetText("One Row: Small Buttons")
	HenchmenOptionButton3Sub1.txthigh:SetText("One Row: Small Buttons")
	HenchmenOptionButton3Sub1.value = "default"
	HenchmenOptionButton3Sub1.callback = BarFunc
	HenchmenOptionButton3Sub1:SetScript("OnMouseUp", Option_OnMouseUp)

	CreateHenchmenSubOptions(3,2)
	HenchmenOptionButton3Sub2.txt:SetText("Two Rows: Small Buttons")
	HenchmenOptionButton3Sub2.txthigh:SetText("Two Rows: Small Buttons")
	HenchmenOptionButton3Sub2.value = "twosmall"
	HenchmenOptionButton3Sub2.callback = BarFunc
	HenchmenOptionButton3Sub2:SetScript("OnMouseUp", Option_OnMouseUp)

	CreateHenchmenSubOptions(3,3)
	HenchmenOptionButton3Sub3.txt:SetText("One Row: Large Buttons")
	HenchmenOptionButton3Sub3.txthigh:SetText("One Row: Large Buttons")
	HenchmenOptionButton3Sub3.value = "onebig"
	HenchmenOptionButton3Sub3.callback = BarFunc
	HenchmenOptionButton3Sub3:SetScript("OnMouseUp", Option_OnMouseUp)

	CreateHenchmenSubOptions(3,4)
	HenchmenOptionButton3Sub4.txt:SetText("Two Rows: Large Buttons")
	HenchmenOptionButton3Sub4.txthigh:SetText("Two Rows: Large Buttons")
	HenchmenOptionButton3Sub4.value = "twobig"
	HenchmenOptionButton3Sub4.callback = BarFunc
	HenchmenOptionButton3Sub4:SetScript("OnMouseUp", Option_OnMouseUp)

	HenchmenOptionButton3.suboptions = 4;
	HenchmenOptionButton3.isopen = false;
	HenchmenOptionButton3:SetScript("OnMouseUp",SubOption_OnMouseUp)
	------------------------------------------------------------------------
	CreateHenchmenSubOptions(4,1)
	HenchmenOptionButton4Sub1.txt:SetText("Icons")
	HenchmenOptionButton4Sub1.txthigh:SetText("Icons")
	HenchmenOptionButton4Sub1.value = "default"
	HenchmenOptionButton4Sub1.callback = AuraFunc
	HenchmenOptionButton4Sub1:SetScript("OnMouseUp", Option_OnMouseUp)

	CreateHenchmenSubOptions(4,2)
	HenchmenOptionButton4Sub2.txt:SetText("Bars")
	HenchmenOptionButton4Sub2.txthigh:SetText("Bars")
	HenchmenOptionButton4Sub2.value = "bars"
	HenchmenOptionButton4Sub2.callback = AuraFunc
	HenchmenOptionButton4Sub2:SetScript("OnMouseUp", Option_OnMouseUp)

	HenchmenOptionButton4.suboptions = 2;
	HenchmenOptionButton4.isopen = false;
	HenchmenOptionButton4:SetScript("OnMouseUp",SubOption_OnMouseUp)
	------------------------------------------------------------------------
	HenchmenOptionButton5:SetScript("OnMouseUp", ConfigFunc)
	------------------------------------------------------------------------
	for _,frame in pairs(SUBOPTIONS) do
		frame.anim:Finish()
		frame:Hide()
	end

	SV.PostLoaded = true
end


function SV:ToggleHenchman()
	if(InCombatLockdown() or (not SV.HenchmenButton)) then return end
	if(not SV.PostLoaded) then
		CreateHenchmenFrame()
	end
	if not HenchmenFrame:IsShown()then
		HenchmenFrameBG:Show()

		UpdateHenchmanModel()

		HenchmenFrame.anim:Finish()
		HenchmenFrame:Show()
		HenchmenFrame.anim:Play()
		HenchmenCalloutFrame.anim:Finish()
		HenchmenCalloutFrame:Show()
		HenchmenCalloutFrame:SetAlpha(1)
		HenchmenCalloutFrame.anim:Play()
		UIFrameFadeOut(HenchmenCalloutFrame,5)
		for i=0,5 do
			local option=_G["HenchmenOptionButton"..i]
			option.anim:Finish()
			option:Show()
			option.anim:Play()

			local minion=_G["MinionOptionButton"..i]
			minion.anim:Finish()
			minion:Show()
			minion.anim:Play()
			local current = minion.getval()
			if(not current) then
				minion.indicator:SetTexCoord(0,1,0,0.5)
			else
				minion.indicator:SetTexCoord(0,1,0.5,1)
			end
		end
		SV.HenchmenButton.Icon:SetGradient(unpack(SV.media.gradient.green))
	else
		UpdateHenchmanModel(true)
		for _,frame in pairs(SUBOPTIONS)do
			frame.anim:Finish()
			frame:Hide()
		end
		HenchmenOptionButton1.isopen=false;
		HenchmenOptionButton2.isopen=false;
		HenchmenOptionButton3.isopen=false;
		HenchmenCalloutFrame.anim:Finish()
		HenchmenCalloutFrame:Hide()
		HenchmenFrame.anim:Finish()
		HenchmenFrame:Hide()
		HenchmenFrameBG:Hide()
		for i=0,5 do
			local option=_G["HenchmenOptionButton"..i]
			option.anim:Finish()
			option:Hide()

			local minion=_G["MinionOptionButton"..i]
			minion.anim:Finish()
			minion:Hide()
		end
		SV.HenchmenButton.Icon:SetGradient("VERTICAL", 0.5, 0.53, 0.55, 0.8, 0.8, 1)
	end
end
--[[
##########################################################
BUILD FUNCTION / UPDATE
##########################################################
]]--
local function LockdownCallback()
	if(HenchmenFrameModel and HenchmenFrame and HenchmenFrame:IsShown()) then
        HenchmenFrame:Hide()
        HenchmenFrameBG:Hide()
    end
end

local function InitializeHenchmen()
	SV.HenchmenButton = SV.Dock:SetDockButton("BottomRight", "Call Henchman!", "SVUI_Henchmen", [[Interface\AddOns\SVUI_!Core\assets\textures\Dock\DOCK-ICON-HENCHMAN]])
	SV.HenchmenButton:SetClickCallbacks(SV.ToggleHenchman, false);
	SV.Events:OnLock(LockdownCallback);
end

SV:NewScript(InitializeHenchmen)
