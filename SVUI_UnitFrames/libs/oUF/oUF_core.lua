local parent, ns = ...

local oUF = {}

local global = GetAddOnMetadata(parent, 'X-oUF')
local _VERSION = GetAddOnMetadata(parent, 'version')

local upper = string.upper
local split = string.split
local tinsert, tremove = table.insert, table.remove

local styles, style = {}
local callback, objects = {}, {}

local elements = {}
local activeElements = {}

--[[
 /$$$$$$$          /$$                      /$$              
| $$__  $$        |__/                     | $$              
| $$  \ $$/$$$$$$  /$$ /$$    /$$/$$$$$$  /$$$$$$    /$$$$$$ 
| $$$$$$$/$$__  $$| $$|  $$  /$$/____  $$|_  $$_/   /$$__  $$
| $$____/ $$  \__/| $$ \  $$/$$/ /$$$$$$$  | $$    | $$$$$$$$
| $$    | $$      | $$  \  $$$/ /$$__  $$  | $$ /$$| $$_____/
| $$    | $$      | $$   \  $/ |  $$$$$$$  |  $$$$/|  $$$$$$$
|__/    |__/      |__/    \_/   \_______/   \___/   \_______/
--]]

local Private = {}

local match = string.match
local format = string.format

function Private.argcheck(value, num, ...)
	assert(type(num) == 'number', "Bad argument #2 to 'argcheck' (number expected, got "..type(num)..")")

	for i=1,select("#", ...) do
		if type(value) == select(i, ...) then return end
	end

	local types = strjoin(", ", ...)
	local name = match(debugstack(2,2,0), ": in function [`<](.-)['>]")
	error(("Bad argument #%d to '%s' (%s expected, got %s"):format(num, name, types, type(value)), 3)
end

function Private.print(...)
	print("|cff33ff99oUF:|r", ...)
end

function Private.error(...)
	Private.print("|cffff0000Error:|r "..format(...))
end

local argcheck = Private.argcheck
local error = Private.error
local print = Private.print
local frame_metatable = Private.frame_metatable

--[[
           /$$   /$$ /$$$$$$$$
          | $$  | $$| $$_____/
  /$$$$$$ | $$  | $$| $$      
 /$$__  $$| $$  | $$| $$$$$   
| $$  \ $$| $$  | $$| $$__/   
| $$  | $$| $$  | $$| $$      
|  $$$$$$/|  $$$$$$/| $$      
 \______/  \______/ |__/      
--]]

-- updating of "invalid" units.
local enableTargetUpdate = function(object)
	object.onUpdateFrequency = object.onUpdateFrequency or .5
	object.__eventless = true

	local total = 0
	object:SetScript('OnUpdate', function(self, elapsed)
		if(not self.unit) then
			return
		elseif(total > self.onUpdateFrequency) then
			self:UpdateAllElements'OnUpdate'
			total = 0
		end

		total = total + elapsed
	end)
end
Private.enableTargetUpdate = enableTargetUpdate

local updateActiveUnit = function(self, event, unit)
	-- Calculate units to work with
	local realUnit, modUnit = SecureButton_GetUnit(self), SecureButton_GetModifiedUnit(self)

	-- _GetUnit() doesn't rewrite playerpet -> pet like _GetModifiedUnit does.
	if(realUnit == 'playerpet') then
		realUnit = 'pet'
	elseif(realUnit == 'playertarget') then
		realUnit = 'target'
	end

	if(modUnit == "pet" and realUnit ~= "pet") then
		modUnit = "vehicle"
	end

	-- Drop out if the event unit doesn't match any of the frame units.
	if(not UnitExists(modUnit) or unit and unit ~= realUnit and unit ~= modUnit) then return end

	-- Change the active unit and run a full update.
	if Private.UpdateUnits(self, modUnit, realUnit) then
		self:UpdateAllElements('RefreshUnit')

		return true
	end
end

local iterateChildren = function(...)
	for l = 1, select("#", ...) do
		local obj = select(l, ...)

		if(type(obj) == 'table' and obj.isChild) then
			updateActiveUnit(obj, "iterateChildren")
		end
	end
end

local OnAttributeChanged = function(self, name, value)
	if(name == "unit" and value) then
		if(self.hasChildren) then
			iterateChildren(self:GetChildren())
		end

		if(not self:GetAttribute'oUF-onlyProcessChildren') then
			updateActiveUnit(self, "OnAttributeChanged")
		end
	end
end

local frame_metatable = {
	__index = CreateFrame"Button"
}
Private.frame_metatable = frame_metatable

for k, v in pairs{
	UpdateElement = function(self, name)
		local unit = self.unit
		if(not unit or not UnitExists(unit)) then return end	
		
		local element = elements[name]
		if(not element or not self:IsElementEnabled(name) or not activeElements[self]) then return end
		if(element.update) then
			element.update(self, 'OnShow', unit)
		end	
	end,
	
	EnableElement = function(self, name, unit)
		argcheck(name, 2, 'string')
		argcheck(unit, 3, 'string', 'nil')
		
		local element = elements[name]
		
		
		if(not element or self:IsElementEnabled(name) or not activeElements[self]) then return end

		if(element.enable(self, unit or self.unit)) then
			activeElements[self][name] = true

			if(element.update) then
				tinsert(self.__elements, element.update)
			end
		end
	end,

	DisableElement = function(self, name)
		argcheck(name, 2, 'string')

		local enable = self:IsElementEnabled(name)
		if(not enable) then return end

		local update = elements[name].update
		for k, func in next, self.__elements do
			if(func == update) then
				tremove(self.__elements, k)
				break
			end
		end

		activeElements[self][name] = nil

		-- We need to run a new update cycle in-case we knocked ourself out of sync.
		-- The main reason we do this is to make sure the full update is completed
		-- if an element for some reason removes itself _during_ the update
		-- progress.
		self:UpdateAllElements('DisableElement', name)

		return elements[name].disable(self)
	end,

	IsElementEnabled = function(self, name)
		argcheck(name, 2, 'string')

		local element = elements[name]
		if(not element) then return end

		local active = activeElements[self]
		return active and active[name]
	end,

	Enable = RegisterUnitWatch,
	Disable = function(self)
		UnregisterUnitWatch(self)
		self:Hide()
	end,

	UpdateAllElements = function(self, event)
		local unit = self.unit
		if(not unit or not UnitExists(unit)) then return end

		if(self.PreUpdate) then
			self:PreUpdate(event)
		end

		for _, func in next, self.__elements do
			func(self, event, unit)
		end

		if(self.PostUpdate) then
			self:PostUpdate(event)
		end
	end,
} do
	frame_metatable.__index[k] = v
end

local OnShow = function(self)
	if(not updateActiveUnit(self, 'OnShow')) then
		return self:UpdateAllElements'OnShow'
	end
end

local UpdatePet = function(self, event, unit)
	local petUnit
	if(unit == 'target') then
		return
	elseif(unit == 'player') then
		petUnit = 'pet'
	else
		-- Convert raid26 -> raidpet26
		petUnit = unit:gsub('^(%a+)(%d+)', '%1pet%2')
	end

	if(self.unit ~= petUnit) then return end
	if(not updateActiveUnit(self, event)) then
		return self:UpdateAllElements(event)
	end
end

local initObject = function(unit, style, styleFunc, header, ...)
	local num = select('#', ...)
	for i=1, num do
		local object = select(i, ...)
		local objectUnit = object:GetAttribute'oUF-guessUnit' or unit
		local suffix = object:GetAttribute'unitsuffix'

		object.__elements = {}
		object.style = style
		object = setmetatable(object, frame_metatable)

		-- Expose the frame through oUF.objects.
		tinsert(objects, object)

		-- We have to force update the frames when PEW fires.
		object:RegisterEvent("PLAYER_ENTERING_WORLD", object.UpdateAllElements)

		-- Handle the case where someone has modified the unitsuffix attribute in
		-- oUF-initialConfigFunction.
		if(suffix and objectUnit and not objectUnit:match(suffix)) then
			objectUnit = objectUnit .. suffix
		end

		if(not (suffix == 'target' or objectUnit and objectUnit:match'target')) then
			object:RegisterEvent('UNIT_ENTERED_VEHICLE', updateActiveUnit)
			object:RegisterEvent('UNIT_EXITED_VEHICLE', updateActiveUnit)

			-- We don't need to register UNIT_PET for the player unit. We register it
			-- mainly because UNIT_EXITED_VEHICLE and UNIT_ENTERED_VEHICLE doesn't always
			-- have pet information when they fire for party and raid units.
			if(objectUnit ~= 'player') then
				object:RegisterEvent('UNIT_PET', UpdatePet)
			end
		end

		if(not header) then
			-- No header means it's a frame created through :Spawn().
			object:SetAttribute("*type1", "target")
			object:SetAttribute('*type2', 'togglemenu')

			-- No need to enable this for *target frames.
			if(not (unit:match'target' or suffix == 'target')) then
				object:SetAttribute('toggleForVehicle', true)
			end

			-- Other boss and target units are handled by :HandleUnit().
			if(suffix == 'target') then
				enableTargetUpdate(object)
			else
				oUF:HandleUnit(object)
			end
		else
			-- Used to update frames when they change position in a group.
			object:RegisterEvent('GROUP_ROSTER_UPDATE', object.UpdateAllElements)

			if(num > 1) then
				if(object:GetParent() == header) then
					object.hasChildren = true
				else
					object.isChild = true
				end
			end

			if(suffix == 'target') then
				enableTargetUpdate(object)
			end
		end

		Private.UpdateUnits(object, objectUnit)

		styleFunc(object, objectUnit, not header)

		object:SetScript("OnAttributeChanged", OnAttributeChanged)
		object:SetScript("OnShow", OnShow)

		activeElements[object] = {}
		for element in next, elements do
			object:EnableElement(element, objectUnit)
		end

		for _, func in next, callback do
			func(object)
		end

		-- Make Clique happy
		_G.ClickCastFrames = ClickCastFrames or {}
		ClickCastFrames[object] = true
	end
end

local walkObject = function(object, unit)
	local parent = object:GetParent()
	local style = parent.style or style
	local styleFunc = styles[style]

	local header = parent:GetAttribute'oUF-headerType' and parent

	-- Check if we should leave the main frame blank.
	if(object:GetAttribute'oUF-onlyProcessChildren') then
		object.hasChildren = true
		object:SetScript('OnAttributeChanged', OnAttributeChanged)
		return initObject(unit, style, styleFunc, header, object:GetChildren())
	end

	return initObject(unit, style, styleFunc, header, object, object:GetChildren())
end

function oUF:RegisterInitCallback(func)
	tinsert(callback, func)
end

function oUF:RegisterMetaFunction(name, func)
	argcheck(name, 2, 'string')
	argcheck(func, 3, 'function', 'table')

	if(frame_metatable.__index[name]) then
		return
	end

	frame_metatable.__index[name] = func
end

function oUF:RegisterStyle(name, func)
	argcheck(name, 2, 'string')
	argcheck(func, 3, 'function', 'table')

	if(styles[name]) then return error("Style [%s] already registered.", name) end
	if(not style) then style = name end

	styles[name] = func
end

function oUF:SetActiveStyle(name)
	argcheck(name, 2, 'string')
	if(not styles[name]) then return error("Style [%s] does not exist.", name) end

	style = name
end

do
	local function iter(_, n)
		-- don't expose the style functions.
		return (next(styles, n))
	end

	function oUF.IterateStyles()
		return iter, nil, nil
	end
end

local getCondition
do
	local conditions = {
		raid40 = '[@raid26,exists] show;',
		raid25 = '[@raid11,exists] show;',
		raid10 = '[@raid6,exists] show;',
		raid = '[group:raid] show;',
		party = '[group:party,nogroup:raid] show;',
		solo = '[@player,exists,nogroup:party] show;',
	}

	function getCondition(...)
		local cond = ''

		for i=1, select('#', ...) do
			local short = select(i, ...)

			local condition = conditions[short]
			if(condition) then
				cond = cond .. condition
			end
		end

		return cond .. 'hide'
	end
end

local generateName = function(unit, ...)
	local name = 'oUF_' .. style:gsub('[^%a%d_]+', '')

	local raid, party, groupFilter
	for i=1, select('#', ...), 2 do
		local att, val = select(i, ...)
		if(att == 'showRaid') then
			raid = true
		elseif(att == 'showParty') then
			party = true
		elseif(att == 'groupFilter') then
			groupFilter = val
		end
	end

	local append
	if(raid) then
		if(groupFilter) then
			if(type(groupFilter) == 'number' and groupFilter > 0) then
				append = groupFilter
			elseif(groupFilter:match'TANK') then
				append = 'MainTank'
			elseif(groupFilter:match'ASSIST') then
				append = 'MainAssist'
			else
				local _, count = groupFilter:gsub(',', '')
				if(count == 0) then
					append = 'Raid' .. groupFilter
				else
					append = 'Raid'
				end
			end
		else
			append = 'Raid'
		end
	elseif(party) then
		append = 'Party'
	elseif(unit) then
		append = unit:gsub("^%l", upper)
	end

	if(append) then
		name = name .. append
	end

	-- Change oUF_LilyRaidRaid into oUF_LilyRaid
	name = name:gsub('(%u%l+)([%u%l]*)%1', '%1')
	-- Change oUF_LilyTargettarget into oUF_LilyTargetTarget
	name = name:gsub('t(arget)', 'T%1')

	local base = name
	local i = 2
	while(_G[name]) do
		name = base .. i
		i = i + 1
	end

	return name
end

do
	local styleProxy = function(self, frame, ...)
		return walkObject(_G[frame])
	end

	-- There has to be an easier way to do this.
	local initialConfigFunction = [[
		local header = self:GetParent()
		local frames = table.new()
		table.insert(frames, self)
		self:GetChildList(frames)
		for i=1, #frames do
			local frame = frames[i]
			local unit
			-- There's no need to do anything on frames with onlyProcessChildren
			if(not frame:GetAttribute'oUF-onlyProcessChildren') then
				RegisterUnitWatch(frame)

				-- Attempt to guess what the header is set to spawn.
				local groupFilter = header:GetAttribute'groupFilter'

				if(type(groupFilter) == 'string' and groupFilter:match('MAIN[AT]')) then
					local role = groupFilter:match('MAIN([AT])')
					if(role == 'T') then
						unit = 'maintank'
					else
						unit = 'mainassist'
					end
				elseif(header:GetAttribute'showRaid') then
					unit = 'raid'
				elseif(header:GetAttribute'showParty') then
					unit = 'party'
				end

				local headerType = header:GetAttribute'oUF-headerType'
				local suffix = frame:GetAttribute'unitsuffix'
				if(unit and suffix) then
					if(headerType == 'pet' and suffix == 'target') then
						unit = unit .. headerType .. suffix
					else
						unit = unit .. suffix
					end
				elseif(unit and headerType == 'pet') then
					unit = unit .. headerType
				end

				frame:SetAttribute('*type1', 'target')
				frame:SetAttribute('*type2', 'togglemenu')
				frame:SetAttribute('toggleForVehicle', true)
				frame:SetAttribute('oUF-guessUnit', unit)
			end

			local body = header:GetAttribute'oUF-initialConfigFunction'
			if(body) then
				frame:Run(body, unit)
			end
		end

		header:CallMethod('styleFunction', self:GetName())

		local clique = header:GetFrameRef("clickcast_header")
		if(clique) then
			clique:SetAttribute("clickcast_button", self)
			clique:RunAttribute("clickcast_register")
		end
	]]

	function oUF:SpawnHeader(overrideName, template, visibility, ...)
		if(not style) then return error("Unable to create frame. No styles have been registered.") end

		template = (template or 'SecureGroupHeaderTemplate')

		local isPetHeader = template:match'PetHeader'
		local name = overrideName or generateName(nil, ...)
		local header = CreateFrame('Frame', name, UIParent, template)

		header:SetAttribute("template", "oUF_ClickCastUnitTemplate")
		for i=1, select("#", ...), 2 do
			local att, val = select(i, ...)
			if(not att) then break end
			header:SetAttribute(att, val)
		end

		header.style = style
		header.styleFunction = styleProxy

		-- We set it here so layouts can't directly override it.
		header:SetAttribute('initialConfigFunction', initialConfigFunction)
		header:SetAttribute('oUF-headerType', isPetHeader and 'pet' or 'group')

		if(Clique) then
			SecureHandlerSetFrameRef(header, 'clickcast_header', Clique.header)
		end

		if(header:GetAttribute'showParty') then
			self:DisableBlizzard'party'
		end

		if(visibility) then
			local type, list = split(' ', visibility, 2)
			if(list and type == 'custom') then
				RegisterAttributeDriver(header, 'state-visibility', list)
			else
				local condition = getCondition(split(',', visibility))
				RegisterAttributeDriver(header, 'state-visibility', condition)
			end
		end

		return header
	end
end

function oUF:Spawn(unit, overrideName, overrideTemplate)
	argcheck(unit, 2, 'string')
	if(not style) then return error("Unable to create frame. No styles have been registered.") end

	unit = unit:lower()

	local name = overrideName or generateName(unit)
	local object = CreateFrame("Button", name, UIParent, overrideTemplate or "SecureUnitButtonTemplate")
	Private.UpdateUnits(object, unit)

	self:DisableBlizzard(unit)
	walkObject(object, unit)

	object:SetAttribute("unit", unit)
	RegisterUnitWatch(object)

	return object
end

function oUF:AddElement(name, update, enable, disable)
	argcheck(name, 2, 'string')
	argcheck(update, 3, 'function', 'nil')
	argcheck(enable, 4, 'function', 'nil')
	argcheck(disable, 5, 'function', 'nil')

	if(elements[name]) then return error('Element [%s] is already registered.', name) end
	elements[name] = {
		update = update;
		enable = enable;
		disable = disable;
	}
end

oUF.version = _VERSION
oUF.objects = objects

if(global) then
	if(parent ~= 'oUF' and global == 'oUF') then
		error("%s is doing it wrong and setting its global to oUF.", parent)
	else
		_G[global] = oUF
	end
end


--[[
 /$$$$$$$$                             /$$             
| $$_____/                            | $$             
| $$    /$$    /$$/$$$$$$  /$$$$$$$  /$$$$$$   /$$$$$$$
| $$$$$|  $$  /$$/$$__  $$| $$__  $$|_  $$_/  /$$_____/
| $$__/ \  $$/$$/ $$$$$$$$| $$  \ $$  | $$   |  $$$$$$ 
| $$     \  $$$/| $$_____/| $$  | $$  | $$ /$$\____  $$
| $$$$$$$$\  $/ |  $$$$$$$| $$  | $$  |  $$$$//$$$$$$$/
|________/ \_/   \_______/|__/  |__/   \___/ |_______/ 
--]]

local RegisterEvent, UnregisterEvent, IsEventRegistered

do
	local eventFrame = CreateFrame("Frame")
	local registry = {}
	local framesForUnit = {}
	local alternativeUnits = {
		['player'] = 'vehicle',
		['pet'] = 'player',
		['party1'] = 'partypet1',
		['party2'] = 'partypet2',
		['party3'] = 'partypet3',
		['party4'] = 'partypet4',
	}
	
	local RegisterFrameForUnit = function(frame, unit)
		if not unit then return end
		if framesForUnit[unit] then
			framesForUnit[unit][frame] = true
		else
			framesForUnit[unit] = { [frame] = true }
		end
	end

	local UnregisterFrameForUnit = function(frame, unit)
		if not unit then return end
		local frames = framesForUnit[unit]
		if frames and frames[frame] then
			frames[frame] = nil
			if not next(frames) then
				framesForUnit[unit] = nil
			end
		end
	end

	Private.UpdateUnits = function(frame, unit, realUnit)
		if unit == realUnit then
			realUnit = nil
		end
		if frame.unit ~= unit or frame.realUnit ~= realUnit then
			if not frame:GetScript('OnUpdate') then
				UnregisterFrameForUnit(frame, frame.unit)
				UnregisterFrameForUnit(frame, frame.realUnit)
				RegisterFrameForUnit(frame, unit)
				RegisterFrameForUnit(frame, realUnit)
			end

			frame.alternativeUnit = alternativeUnits[unit]
			frame.unit = unit
			frame.realUnit = realUnit
			frame.id = unit:match'^.-(%d+)'
			return true
		end
	end

	-- Holds true for every event, where the first (unit) argument should be ignored.
	local sharedUnitEvents = {
		UNIT_ENTERED_VEHICLE = true,
		UNIT_EXITED_VEHICLE = true,
		UNIT_PET = true,
	}

	eventFrame:SetScript('OnEvent', function(_, event, arg1, ...)
		local listeners = registry[event]
		if arg1 and not sharedUnitEvents[event] then
			local frames = framesForUnit[arg1]
			if frames then
				for frame in next, frames do
					if listeners[frame] and frame:IsVisible() then
						frame[event](frame, event, arg1, ...)
					end
				end
			end
		else
			for frame in next, listeners do
				if frame:IsVisible() then
					frame[event](frame, event, arg1, ...)
				end
			end
		end
	end)

	function RegisterEvent(self, event, unitless)
		if(unitless) then
			sharedUnitEvents[event] = true
		end

		if not registry[event] then
			registry[event] = { [self] = true }
			eventFrame:RegisterEvent(event)
		else
			registry[event][self] = true
		end
	end

	function UnregisterEvent(self, event)
		if registry[event] then
			registry[event][self] = nil
			if not next(registry[event]) then
				registry[event] = nil
				eventFrame:UnregisterEvent(event)
			end
		end
	end

	function IsEventRegistered(self, event)
		return registry[event] and registry[event][self]
	end
end

local event_metatable = {
	__call = function(funcs, self, ...)
		for _, func in next, funcs do
			func(self, ...)
		end
	end,
}

function frame_metatable.__index:RegisterEvent(event, func, unitless)
	-- Block OnUpdate polled frames from registering events.
	if(self.__eventless) then return end

	argcheck(event, 2, 'string')

	if(type(func) == 'string' and type(self[func]) == 'function') then
		func = self[func]
	end

	local curev = self[event]
	local kind = type(curev)
	if(curev and func) then
		if(kind == 'function' and curev ~= func) then
			self[event] = setmetatable({curev, func}, event_metatable)
		elseif(kind == 'table') then
			for _, infunc in next, curev do
				if(infunc == func) then return end
			end

			tinsert(curev, func)
		end
	elseif(IsEventRegistered(self, event)) then
		return
	else
		if(type(func) == 'function') then
			self[event] = func
		elseif(not self[event]) then
			return error("Style [%s] attempted to register event [%s] on unit [%s] with a handler that doesn't exist.", self.style, event, self.unit or 'unknown')
		end

		RegisterEvent(self, event, unitless)
	end
end

function frame_metatable.__index:UnregisterEvent(event, func)
	argcheck(event, 2, 'string')

	local curev = self[event]
	if(type(curev) == 'table' and func) then
		for k, infunc in next, curev do
			if(infunc == func) then
				tremove(curev, k)

				local n = #curev
				if(n == 1) then
					local _, handler = next(curev)
					self[event] = handler
				elseif(n == 0) then
					UnregisterEvent(self, event)
				end

				break
			end
		end
	elseif(curev == func) then
		self[event] = nil
		UnregisterEvent(self, event)
	end
end

function frame_metatable.__index:IsEventRegistered(event)
	return IsEventRegistered(self, event)
end

--[[
 /$$$$$$$$                  /$$                                  
| $$_____/                 | $$                                  
| $$    /$$$$$$   /$$$$$$$/$$$$$$    /$$$$$$   /$$$$$$  /$$   /$$
| $$$$$|____  $$ /$$_____/_  $$_/   /$$__  $$ /$$__  $$| $$  | $$
| $$__/ /$$$$$$$| $$       | $$    | $$  \ $$| $$  \__/| $$  | $$
| $$   /$$__  $$| $$       | $$ /$$| $$  | $$| $$      | $$  | $$
| $$  |  $$$$$$$|  $$$$$$$ |  $$$$/|  $$$$$$/| $$      |  $$$$$$$
|__/   \_______/ \_______/  \___/   \______/ |__/       \____  $$
                                                        /$$  | $$
                                                       |  $$$$$$/
                                                        \______/ 
--]]

local tinsert = table.insert

local _QUEUE = {}
local _FACTORY = CreateFrame'Frame'
_FACTORY:SetScript('OnEvent', function(self, event, ...)
	return self[event](self, event, ...)
end)

_FACTORY:RegisterEvent'PLAYER_LOGIN'
_FACTORY.active = true

function _FACTORY:PLAYER_LOGIN()
	if(not self.active) then return end

	for _, func in next, _QUEUE do
		func(oUF)
	end

	-- Avoid creating dupes.
	wipe(_QUEUE)
end

function oUF:Factory(func)
	argcheck(func, 2, 'function')

	-- Call the function directly if we're active and logged in.
	if(IsLoggedIn() and _FACTORY.active) then
		return func(self)
	else
		tinsert(_QUEUE, func)
	end
end

function oUF:EnableFactory()
	_FACTORY.active = true
end

function oUF:DisableFactory()
	_FACTORY.active = nil
end

function oUF:RunFactoryQueue()
	_FACTORY:PLAYER_LOGIN()
end

--[[
 /$$$$$$$  /$$ /$$                                             /$$
| $$__  $$| $$|__/                                            | $$
| $$  \ $$| $$ /$$ /$$$$$$$$/$$$$$$$$  /$$$$$$   /$$$$$$  /$$$$$$$
| $$$$$$$ | $$| $$|____ /$$/____ /$$/ |____  $$ /$$__  $$/$$__  $$
| $$__  $$| $$| $$   /$$$$/   /$$$$/   /$$$$$$$| $$  \__/ $$  | $$
| $$  \ $$| $$| $$  /$$__/   /$$__/   /$$__  $$| $$     | $$  | $$
| $$$$$$$/| $$| $$ /$$$$$$$$/$$$$$$$$|  $$$$$$$| $$     |  $$$$$$$
|_______/ |__/|__/|________/________/ \_______/|__/      \_______/
--]]

local hiddenParent = CreateFrame("Frame")
hiddenParent:Hide()

local HandleFrame = function(baseName)
	local frame
	if(type(baseName) == 'string') then
		frame = _G[baseName]
	else
		frame = baseName
	end

	if(frame) then
		frame:UnregisterAllEvents()
		frame:Hide()

		-- Keep frame hidden without causing taint
		frame:SetParent(hiddenParent)

		local health = frame.healthbar
		if(health) then
			health:UnregisterAllEvents()
		end

		local power = frame.manabar
		if(power) then
			power:UnregisterAllEvents()
		end

		local spell = frame.spellbar
		if(spell) then
			spell:UnregisterAllEvents()
		end

		local altpowerbar = frame.powerBarAlt
		if(altpowerbar) then
			altpowerbar:UnregisterAllEvents()
		end
	end
end

function oUF:DisableBlizzard(unit)
	if(not unit) or InCombatLockdown() then return end

	if(unit == 'player') then
		HandleFrame(PlayerFrame)

		-- For the damn vehicle support:
		PlayerFrame:RegisterUnitEvent('UNIT_ENTERING_VEHICLE', "player")
		PlayerFrame:RegisterUnitEvent('UNIT_ENTERED_VEHICLE', "player")
		PlayerFrame:RegisterUnitEvent('UNIT_EXITING_VEHICLE', "player")
		PlayerFrame:RegisterUnitEvent('UNIT_EXITED_VEHICLE', "player")

		-- User placed frames don't animate
		PlayerFrame:SetUserPlaced(true)
		PlayerFrame:SetDontSavePosition(true)
	elseif(unit == 'pet') then
		HandleFrame(PetFrame)
	elseif(unit == 'target') then
		HandleFrame(TargetFrame)
		HandleFrame(ComboFrame)
	elseif(unit == 'focus') then
		HandleFrame(FocusFrame)
		HandleFrame(TargetofFocusFrame)
	elseif(unit == 'targettarget') then
		HandleFrame(TargetFrameToT)
	elseif(unit:match'(boss)%d?$' == 'boss') then
		local id = unit:match'boss(%d)'
		if(id) then
			HandleFrame('Boss' .. id .. 'TargetFrame')
		else
			for i=1, 4 do
				HandleFrame(('Boss%dTargetFrame'):format(i))
			end
		end
	elseif(unit:match'(party)%d?$' == 'party') then
		local id = unit:match'party(%d)'
		if(id) then
			HandleFrame('PartyMemberFrame' .. id)
		else
			for i=1, 4 do
				HandleFrame(('PartyMemberFrame%d'):format(i))
			end
		end
	elseif(unit:match'(arena)%d?$' == 'arena') then
		local id = unit:match'arena(%d)'
		if(id) then
			HandleFrame('ArenaEnemyFrame' .. id)
		else
			for i=1, 4 do
				HandleFrame(('ArenaEnemyFrame%d'):format(i))
			end
		end

		-- Blizzard_ArenaUI should not be loaded
		Arena_LoadUI = function() end
		SetCVar('showArenaEnemyFrames', '0', 'SHOW_ARENA_ENEMY_FRAMES_TEXT')
	end
end

--[[
 /$$   /$$           /$$   /$$             
| $$  | $$          |__/  | $$             
| $$  | $$ /$$$$$$$  /$$ /$$$$$$   /$$$$$$$
| $$  | $$| $$__  $$| $$|_  $$_/  /$$_____/
| $$  | $$| $$  \ $$| $$  | $$   |  $$$$$$ 
| $$  | $$| $$  | $$| $$  | $$ /$$\____  $$
|  $$$$$$/| $$  | $$| $$  |  $$$$//$$$$$$$/
 \______/ |__/  |__/|__/   \___/ |_______/                                      
--]]

local enableTargetUpdate = Private.enableTargetUpdate

-- Handles unit specific actions.
function oUF:HandleUnit(object, unit)
	local unit = object.unit or unit

	if(unit == 'target') then
		object:RegisterEvent('PLAYER_TARGET_CHANGED', object.UpdateAllElements)
	elseif(unit == 'mouseover') then
		object:RegisterEvent('UPDATE_MOUSEOVER_UNIT', object.UpdateAllElements)
	elseif(unit == 'focus') then
		object:RegisterEvent('PLAYER_FOCUS_CHANGED', object.UpdateAllElements)
	elseif(unit:match'(boss)%d?$' == 'boss') then
		object:RegisterEvent('INSTANCE_ENCOUNTER_ENGAGE_UNIT', object.UpdateAllElements, true)
		object:RegisterEvent('UNIT_TARGETABLE_CHANGED', object.UpdateAllElements)
	elseif(unit:match'%w+target') then
		enableTargetUpdate(object)
	end
end

--[[
  /$$$$$$            /$$                             
 /$$__  $$          | $$                             
| $$  \__/  /$$$$$$ | $$  /$$$$$$   /$$$$$$  /$$$$$$$
| $$       /$$__  $$| $$ /$$__  $$ /$$__  $$/$$_____/
| $$      | $$  \ $$| $$| $$  \ $$| $$  \__/  $$$$$$ 
| $$    $$| $$  | $$| $$| $$  | $$| $$      \____  $$
|  $$$$$$/|  $$$$$$/| $$|  $$$$$$/| $$      /$$$$$$$/
 \______/  \______/ |__/ \______/ |__/     |_______/ 
--]]



local colors = {
	smooth = {
		1, 0, 0,
		1, 1, 0,
		0, 1, 0
	},
	disconnected = {.6, .6, .6},
	tapped = {.6,.6,.6},
	class = {},
	reaction = {},
}

-- We do this because people edit the vars directly, and changing the default
-- globals makes SPICE FLOW!
local customClassColors = function()
	if(CUSTOM_CLASS_COLORS) then
		local updateColors = function()
			for eclass, color in next, CUSTOM_CLASS_COLORS do
				colors.class[eclass] = {color.r, color.g, color.b}
			end

			for _, obj in next, oUF.objects do
				obj:UpdateAllElements("CUSTOM_CLASS_COLORS")
			end
		end

		updateColors()
		CUSTOM_CLASS_COLORS:RegisterCallback(updateColors)

		return true
	end
end
if not customClassColors() then
	for eclass, color in next, RAID_CLASS_COLORS do
		colors.class[eclass] = {color.r, color.g, color.b}
	end

	local f = CreateFrame("Frame")
	f:RegisterEvent("ADDON_LOADED")
	f:SetScript("OnEvent", function()
		if customClassColors() then
			f:UnregisterEvent("ADDON_LOADED")
			f:SetScript("OnEvent", nil)
		end
	end)
end

for eclass, color in next, FACTION_BAR_COLORS do
	colors.reaction[eclass] = {color.r, color.g, color.b}
end

local function ColorsAndPercent(a, b, ...)
	if a <= 0 or b == 0 then
		return nil, ...
	elseif a >= b then
		return nil, select(select('#', ...) - 2, ...)
	end

	local num = select('#', ...) / 3
	local segment, relperc = math.modf((a/b)*(num-1))
	return relperc, select((segment*3)+1, ...)
end

-- http://www.wowwiki.com/ColorGradient
local RGBColorGradient = function(...)
	local relperc, r1, g1, b1, r2, g2, b2 = ColorsAndPercent(...)
	if relperc then
		return r1 + (r2-r1)*relperc, g1 + (g2-g1)*relperc, b1 + (b2-b1)*relperc
	else
		return r1, g1, b1
	end
end


local function GetY(r, g, b)
	return 0.3 * r + 0.59 * g + 0.11 * b
end

local function RGBToHCY(r, g, b)
	local min, max = min(r, g, b), max(r, g, b)
	local chroma = max - min
	local hue
	if chroma > 0 then
		if r == max then
			hue = ((g - b) / chroma) % 6
		elseif g == max then
			hue = (b - r) / chroma + 2
		elseif b == max then
			hue = (r - g) / chroma + 4
		end
		hue = hue / 6
	end
	return hue, chroma, GetY(r, g, b)
end

local abs = math.abs
local function HCYtoRGB(hue, chroma, luma)
	local r, g, b = 0, 0, 0
	if hue then
		local h2 = hue * 6
		local x = chroma * (1 - abs(h2 % 2 - 1))
		if h2 < 1 then
			r, g, b = chroma, x, 0
		elseif h2 < 2 then
			r, g, b = x, chroma, 0
		elseif h2 < 3 then
			r, g, b = 0, chroma, x
		elseif h2 < 4 then
			r, g, b = 0, x, chroma
		elseif h2 < 5 then
			r, g, b = x, 0, chroma
		else
			r, g, b = chroma, 0, x
		end
	end
	local m = luma - GetY(r, g, b)
	return r + m, g + m, b + m
end

local HCYColorGradient = function(...)
	local relperc, r1, g1, b1, r2, g2, b2 = ColorsAndPercent(...)
	if not relperc then return r1, g1, b1 end
	local h1, c1, y1 = RGBToHCY(r1, g1, b1)
	local h2, c2, y2 = RGBToHCY(r2, g2, b2)
	local c = c1 + (c2-c1) * relperc
	local y = y1 + (y2-y1) * relperc
	if h1 and h2 then
		local dh = h2 - h1
		if dh < -0.5  then
			dh = dh + 1
		elseif dh > 0.5 then
			dh = dh - 1
		end
		return HCYtoRGB((h1 + dh * relperc) % 1, c, y)
	else
		return HCYtoRGB(h1 or h2, c, y)
	end

end

local ColorGradient = function(...)
	return (oUF.useHCYColorGradient and HCYColorGradient or RGBColorGradient)(...)
end

Private.colors = colors

oUF.colors = colors
oUF.ColorGradient = ColorGradient
oUF.RGBColorGradient = RGBColorGradient
oUF.HCYColorGradient = HCYColorGradient
oUF.useHCYColorGradient = false

frame_metatable.__index.colors = colors
frame_metatable.__index.ColorGradient = ColorGradient

--[[
 /$$$$$$$$/$$                     /$$ /$$                    
| $$_____/__/                    | $$|__/                    
| $$      /$$ /$$$$$$$   /$$$$$$ | $$ /$$ /$$$$$$$$  /$$$$$$ 
| $$$$$  | $$| $$__  $$ |____  $$| $$| $$|____ /$$/ /$$__  $$
| $$__/  | $$| $$  \ $$  /$$$$$$$| $$| $$   /$$$$/ | $$$$$$$$
| $$     | $$| $$  | $$ /$$__  $$| $$| $$  /$$__/  | $$_____/
| $$     | $$| $$  | $$|  $$$$$$$| $$| $$ /$$$$$$$$|  $$$$$$$
|__/     |__/|__/  |__/ \_______/|__/|__/|________/ \_______/
--]]

-- It's named Private for a reason!
-- Private = nil
ns.oUF = oUF