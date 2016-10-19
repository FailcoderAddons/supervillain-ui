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
local string 	= _G.string;
--[[ STRING METHODS ]]--
local format = string.format;
--[[ 
########################################################## 
GET ADDON DATA
##########################################################
]]--
local SV = _G['SVUI'];
local L = SV.L;
local MOD = SV.Skins;
local Schema = MOD.Schema;
--[[ 
########################################################## 
RECOUNT
##########################################################
]]--
local StripKeys = {"CloseButton", "ConfigButton", "FileButton", "LeftButton", "ResetButton", "RightButton", "ReportButton", "SummaryButton"}

local Recount_ShowReset = function(self)
	MOD:LoadAlert(L['Reset Recount?'], function(self) Recount:ResetData() self:GetParent():Hide() end)
end

local Title_OnUpdate = function(self, elapsed)
	self.timeLapse = self.timeLapse + elapsed
	if(self.timeLapse < 0.2) then 
		return 
	else
		self.timeLapse = 0
	end
	local parent = self:GetParent()parent:GetWidth()
	self:SetSize(parent:GetWidth(), 23) 
end

local function StyleFrame(frame)
	if((not frame) or (frame.Panel)) then return end

	frame:SetBackdrop(nil)
	frame:SetStyle("Frame", "Transparent")
	--frame.Panel:SetAllPoints()
	--frame.Panel:SetPoint('TOPLEFT', frame, 'TOPLEFT', 0, -6)
	frame.CloseButton:SetPoint('TOPRIGHT', frame, 'TOPRIGHT', -1, -1)

	frame.TitleBackground = CreateFrame('Frame', nil, frame)
	frame.TitleBackground:SetStyle("!_Frame", "Transparent")
	--frame.TitleBackground:SetPanelColor("class")
	frame.TitleBackground:SetPoint('TOP', frame, 'TOP', 0, 0)
	frame.TitleBackground.timeLapse = 0;
	frame.TitleBackground:SetFrameLevel(frame:GetFrameLevel())
	frame.TitleBackground:SetScript('OnUpdate', Title_OnUpdate)

	frame.Title:ClearAllPoints()
	frame.Title:SetPoint('TOPLEFT', frame, 'TOPLEFT', 6, -5)

	for i=1, #StripKeys do
		local subframe = frame[StripKeys[i]]
		if(subframe) then
			for i = 1, subframe:GetNumRegions() do 
				local region = select(i, subframe:GetRegions())
				if(region:GetObjectType() == 'Texture') then 
					region:SetDesaturated(true)
					if(region:GetTexture() == 'Interface\\DialogFrame\\UI-DialogBox-Corner') then 
						region:SetTexture("")
						region:Die()
					end 
				end 
			end
		end
	end
end

local function StyleRecount()
	assert(Recount, "AddOn Not Loaded")
	
	Recount.ShowReset = Recount_ShowReset

	local RecountFrames = {
		Recount.MainWindow,
		Recount.ConfigWindow,
		Recount.GraphWindow,
		Recount.DetailWindow,
	}

	for _, frame in pairs(RecountFrames) do StyleFrame(frame) end

	SV.API:Set("ScrollBar", Recount_MainWindow_ScrollBarScrollBar)

	Recount.MainWindow:HookScript('OnShow', function(self) if InCombatLockdown() then return end if MOD.Docklet:IsEmbedded("Recount") then MOD.Docklet:Show() end end)
	Recount.MainWindow.FileButton:HookScript('OnClick', function(self) if LibDropdownFrame0 then SV.API:Set("Frame", LibDropdownFrame0) end end)

	hooksecurefunc(Recount, 'ShowScrollbarElements', function(self, name) Recount_MainWindow_ScrollBarScrollBar:Show() end)
	hooksecurefunc(Recount, 'HideScrollbarElements', function(self, name) Recount_MainWindow_ScrollBarScrollBar:Hide() end)
	hooksecurefunc(Recount, 'CreateFrame', function(self, frame) StyleFrame(_G[frame]) end)

	hooksecurefunc(Recount, 'ShowReport', function(self)
		if Recount_ReportWindow.isStyled then return end
		Recount_ReportWindow.isStyled = true
		SV.API:Set("Frame", Recount_ReportWindow.Whisper)
		Recount_ReportWindow.ReportButton:SetStyle("Button")
		SV.API:Set("ScrollBar", Recount_ReportWindow_Slider)
		Recount_ReportWindow_Slider:GetThumbTexture():SetSize(6,6)
	end)
end
MOD:SaveAddonStyle("Recount", StyleRecount) 