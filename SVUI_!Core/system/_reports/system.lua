--[[
##############################################################################
S V U I   By: Failcoder
##############################################################################

##########################################################
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;

local select 	= _G.select;
local collectgarbage    = _G.collectgarbage;
local string 	= _G.string;
local math 		= _G.math;
local table 	= _G.table;
--[[ STRING METHODS ]]--
local format = string.format;
--[[ MATH METHODS ]]--
local floor = math.floor
--[[ TABLE METHODS ]]--
local tsort = table.sort;
local IsShiftKeyDown        = _G.IsShiftKeyDown;
local IsAddOnLoaded         = _G.IsAddOnLoaded;
--[[
##########################################################
GET ADDON DATA
##########################################################
]]--
local SV = select(2, ...)
local L = SV.L;
local Reports = SV.Reports;
--[[
##########################################################
SYSTEM STATS (Credit: Elv)
##########################################################
]]--
local REPORT_NAME = "System";
local HEX_COLOR = "22FFFF";
local TEXT_PATTERN = "|cff%s%s|r";
local int, int2 = 6, 5
local statusColors = {
	"|cff0CD809",
	"|cffE8DA0F",
	"|cffFF9000",
	"|cffD80909"
}

local enteredFrame = false;
local bandwidthString = "%.2f Mbps"
local percentageString = "%.2f%%"
local homeLatencyString = "%d ms"
local kiloByteString = "%d kb"
local megaByteString = "%.2f mb"
local totalMemory = 0
local bandwidth = 0
local memoryTable = {}
local cpuTable = {}

local function formatMem(memory)
	local mult = 10^1
	if memory > 999 then
		local mem = ((memory/1024) * mult) / mult
		return megaByteString:format(mem)
	else
		local mem = (memory * mult) / mult
		return kiloByteString:format(mem)
	end
end

local function RebuildAddonList()
	local addOnCount = GetNumAddOns()
	if (addOnCount == #memoryTable) then return end
	memoryTable = {}
	cpuTable = {}
	for i = 1, addOnCount do
		local addonName = select(2, GetAddOnInfo(i))
		memoryTable[i] = { i, addonName, 0, IsAddOnLoaded(i) }
		cpuTable[i] = { i, addonName, 0, IsAddOnLoaded(i) }
	end
end

local function UpdateMemory()
	UpdateAddOnMemoryUsage()
	totalMemory = 0
	for i = 1, #memoryTable do
		memoryTable[i][3] = GetAddOnMemoryUsage(memoryTable[i][1])
		totalMemory = totalMemory + memoryTable[i][3]
	end
	tsort(memoryTable, function(a, b)
		if a and b then
			return a[3] > b[3]
		end
	end)
end

local function UpdateCPU()
	UpdateAddOnCPUUsage()
	local addonCPU = 0
	local totalCPU = 0
	for i = 1, #cpuTable do
		addonCPU = GetAddOnCPUUsage(cpuTable[i][1])
		cpuTable[i][3] = addonCPU
		totalCPU = totalCPU + addonCPU
	end

	tsort(cpuTable, function(a, b)
		if a and b then
			return a[3] > b[3]
		end
	end)

	return totalCPU
end

local Report = Reports:NewReport(REPORT_NAME, {
	type = "data source",
	text = REPORT_NAME .. " Info",
	icon = [[Interface\Addons\SVUI_!Core\assets\icons\SVUI]]
});

Report.OnClick = function(self, button)
	collectgarbage("collect");
	ResetCPUUsage();
end

Report.OnEnter = function(self)
	enteredFrame = true;
	local cpuProfiling = false
	Reports:SetDataTip(self)

	UpdateMemory()
	bandwidth = GetAvailableBandwidth()

	Reports.ToolTip:AddDoubleLine(L['Home Latency:'], homeLatencyString:format(select(3, GetNetStats())), 0.69, 0.31, 0.31,0.84, 0.75, 0.65)

	if bandwidth ~= 0 then
		local percent = GetDownloadedPercentage()
		percent = percent * 100
		Reports.ToolTip:AddDoubleLine(L['Bandwidth'] , bandwidthString:format(bandwidth), 0.69, 0.31, 0.31,0.84, 0.75, 0.65)
		Reports.ToolTip:AddDoubleLine(L['Download'] , percentageString:format(percent), 0.69, 0.31, 0.31, 0.84, 0.75, 0.65)
		Reports.ToolTip:AddLine(" ")
	end

	local totalCPU = nil
	Reports.ToolTip:AddDoubleLine(L['Total Memory:'], formatMem(totalMemory), 0.69, 0.31, 0.31,0.84, 0.75, 0.65)
	if cpuProfiling then
		totalCPU = UpdateCPU()
		Reports.ToolTip:AddDoubleLine(L['Total CPU:'], homeLatencyString:format(totalCPU), 0.69, 0.31, 0.31,0.84, 0.75, 0.65)
	end

	local red, green
	if IsShiftKeyDown() or not cpuProfiling then
		Reports.ToolTip:AddLine(" ")
		for i = 1, #memoryTable do
			if (memoryTable[i][4]) then
				red = memoryTable[i][3] / totalMemory
				green = 1 - red
				Reports.ToolTip:AddDoubleLine(memoryTable[i][2], formatMem(memoryTable[i][3]), 1, 1, 1, red, green + .5, 0)
			end
		end
	end

	if cpuProfiling and not IsShiftKeyDown() then
		Reports.ToolTip:AddLine(" ")
		for i = 1, #cpuTable do
			if (cpuTable[i][4]) then
				red = cpuTable[i][3] / totalCPU
				green = 1 - red
				Reports.ToolTip:AddDoubleLine(cpuTable[i][2], homeLatencyString:format(cpuTable[i][3]), 1, 1, 1, red, green + .5, 0)
			end
		end

		Reports.ToolTip:AddLine(" ")
		Reports.ToolTip:AddLine(L['(Hold Shift) Memory Usage'])
	end

	Reports.ToolTip:Show()
end

Report.OnLeave = function(self, button)
	enteredFrame = false;
	Reports.ToolTip:Hide()
end

Report.OnUpdate = function(self, elapsed)
	int = int - elapsed
	int2 = int2 - elapsed

	if int < 0 then
		RebuildAddonList()
		int = 10
	end
	if int2 < 0 then
		local framerate = floor(GetFramerate())
		local latency = select(4, GetNetStats())

		self.text:SetFormattedText("FPS: %s%d|r MS: %s%d|r",
			statusColors[framerate >= 30 and 1 or (framerate >= 20 and framerate < 30) and 2 or (framerate >= 10 and framerate < 20) and 3 or 4],
			framerate,
			statusColors[latency < 150 and 1 or (latency >= 150 and latency < 300) and 2 or (latency >= 300 and latency < 500) and 3 or 4],
			latency)
		int2 = 1
		if enteredFrame then
			Report.OnEnter(self)
		end
	end
end
