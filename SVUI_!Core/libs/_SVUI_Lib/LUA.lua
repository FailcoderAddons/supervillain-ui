--- LUA companion library.
-- @class file
-- @name LUA
-- @author Steven Jackson (2014)
-- @release 1.0.0
local _G            = getfenv(0)
local select        = _G.select;
local assert        = _G.assert;
local type          = _G.type;
local error         = _G.error;
local pairs         = _G.pairs;
local next          = _G.next;
local ipairs        = _G.ipairs;
local loadstring    = _G.loadstring;
local setmetatable  = _G.setmetatable;
local getmetatable  = _G.getmetatable;
local rawset        = _G.rawset;
local rawget        = _G.rawget;
local tostring      = _G.tostring;
local tonumber      = _G.tonumber;
local xpcall        = _G.xpcall;
local pcall         = _G.pcall;
local table         = _G.table;
local tconcat       = table.concat;
local tremove       = table.remove;
local tinsert       = table.insert;
local table_sort    = table.sort;
local string        = _G.string;
local match         = string.match;
local gmatch 				= string.gmatch;
local gsub          = string.gsub;
local rep           = string.rep;
local char 					= string.char;
local strmatch      = _G.strmatch;
local bit           = _G.bit;
local band          = bit.band;
local math          = _G.math;
local floor         = math.floor;
local huge          = math.huge;

---------------------------------------------------------------------
-- Math
-- @section MATH UTILITIES
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Integer float utility for lua.
-- @return floating point integer
-- @param value The integer amount to be adjusted.
-- @param decimal Number of decimal places allowed.
---------------------------------------------------------------------

function math.parsefloat(value, decimal)
	value = value or 0
	if(decimal and decimal > 0) then
		local calc1 = 10 ^ decimal;
		local calc2 = (value * calc1) + 0.5;
		return floor(calc2) / calc1
	end
	return floor(value + 0.5)
end

---------------------------------------------------------------------
-- Pickle
-- @section SERIALIZE UTILITIES
---------------------------------------------------------------------

---------------------------------------------------------------------
-- Global class used by pickle/unpickle functions.
-- @todo Does this need to be global?
---------------------------------------------------------------------

Pickle = {
  clone = function (t) local nt={}; for i, v in pairs(t) do nt[i]=v end return nt end
}

---------------------------------------------------------------------
-- A table serialization utility for lua.
-- @return serialized table data
-- @param t A table to be serialized.
-- @author Steve Dekorte, http://www.dekorte.com, Apr 2000
---------------------------------------------------------------------

function pickle(t)
  return Pickle:clone():pickle_(t)
end

function Pickle:pickle_(root)
  if type(root) ~= "table" then
    error("can only pickle tables, not ".. type(root).."s")
  end
  self._tableToRef = {}
  self._refToTable = {}
  local savecount = 0
  self:ref_(root)
  local s = ""

  while table.getn(self._refToTable) > savecount do
    savecount = savecount + 1
    local t = self._refToTable[savecount]
    s = s.."{\n"
    for i, v in pairs(t) do
        s = string.format("%s[%s]=%s,\n", s, self:value_(i), self:value_(v))
    end
    s = s.."},\n"
  end

  return string.format("{%s}", s)
end

function Pickle:value_(v)
  local vtype = type(v)
  if     vtype == "string" then return string.format("%q", v)
  elseif vtype == "number" then return v
  elseif vtype == "boolean" then return tostring(v)
  elseif vtype == "table" then return "{"..self:ref_(v).."}"
  else --error("pickle a "..type(v).." is not supported")
  end
end

function Pickle:ref_(t)
  local ref = self._tableToRef[t]
  if not ref then
    if t == self then error("can't pickle the pickle class") end
    table.insert(self._refToTable, t)
    ref = table.getn(self._refToTable)
    self._tableToRef[t] = ref
  end
  return ref
end

---------------------------------------------------------------------
-- Un-serialization tool (pretty sure thats not a word).
-- @return serialized table data
-- @param s A serialized table to be reversed.
-- @author Steve Dekorte, http://www.dekorte.com, Apr 2000
---------------------------------------------------------------------

function unpickle(s)
  if type(s) ~= "string" then
    error("can't unpickle a "..type(s)..", only strings")
  end
  local gentables = loadstring("return "..s)
  local tables = gentables()

  for tnum = 1, table.getn(tables) do
    local t = tables[tnum]
    local tcopy = {}; for i, v in pairs(t) do tcopy[i] = v end
    for i, v in pairs(tcopy) do
      local ni, nv
      if type(i) == "table" then ni = tables[i[1]] else ni = i end
      if type(v) == "table" then nv = tables[v[1]] else nv = v end
      t[i] = nil
      t[ni] = nv
    end
  end
  return tables[1]
end

---------------------------------------------------------------------
-- String
-- @section STRING UTILITIES
---------------------------------------------------------------------

local char_table='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

---------------------------------------------------------------------
-- Base64 encoding tool.
-- @return encoded string
-- @param data string data to be encoded.
---------------------------------------------------------------------

function string.encode(data)
    return ((data:gsub('.', function(x)
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return char_table:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

---------------------------------------------------------------------
-- Base64 decoding tool.
-- @return decoded string
-- @param data encoded string to be decoded.
---------------------------------------------------------------------

function string.decode(data)
    data = gsub(data, '[^'..char_table..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(char_table:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return char(c)
    end))
end

---------------------------------------------------------------------
-- String to array utility.
-- @return table data
-- @param data string to be converted to table data.
-- @param delim Character delimiter to separate the string by.
---------------------------------------------------------------------

function string.explode(data, delim)
    local pattern = format("([^%s]+)", delim);
    local res = {};
		local count = 1;
    for line in gmatch(data, pattern) do
				res[count] = line;
				count = count + 1;
    end
    return res
end

function string.loadtable(data)
   local t = {}
   local f = assert(loadstring(data))
   setfenv(f, t)
   f()
   return t
end

-------------------------------------------------------------------
--PRETTY PRINT FOR TABLES

local prettify = {}
prettify.KEY       = setmetatable({}, {__tostring = function() return 'prettify.KEY' end})
prettify.METATABLE = setmetatable({}, {__tostring = function() return 'prettify.METATABLE' end})

-- Apostrophizes the string if it has quotes, but not aphostrophes
-- Otherwise, it returns a regular quoted string
local function smartQuote(str)
  if str:match('"') and not str:match("'") then
	return "'" .. str .. "'"
  end
  return '"' .. str:gsub('"', '\\"') .. '"'
end

local controlCharsTranslation = {
  ["\a"] = "\\a",  ["\b"] = "\\b", ["\f"] = "\\f",  ["\n"] = "\\n",
  ["\r"] = "\\r",  ["\t"] = "\\t", ["\v"] = "\\v"
}

local function escape(str)
  local result = str:gsub("\\", "\\\\"):gsub("(%c)", controlCharsTranslation)
  return result
end

local function isIdentifier(str)
  return type(str) == 'string' and str:match( "^[_%a][_%a%d]*$" )
end

local function isSequenceKey(k, length)
  return type(k) == 'number'
	 and 1 <= k
	 and k <= length
	 and floor(k) == k
end

local defaultTypeOrders = {
  ['number']   = 1, ['boolean']  = 2, ['string'] = 3, ['table'] = 4,
  ['function'] = 5, ['userdata'] = 6, ['thread'] = 7
}

local function sortKeys(a, b)
  local ta, tb = type(a), type(b)

  -- strings and numbers are sorted numerically/alphabetically
  if ta == tb and (ta == 'string' or ta == 'number') then return a < b end

  local dta, dtb = defaultTypeOrders[ta], defaultTypeOrders[tb]
  -- Two default types are compared according to the defaultTypeOrders table
  if dta and dtb then return defaultTypeOrders[ta] < defaultTypeOrders[tb]
  elseif dta     then return true  -- default types before custom ones
  elseif dtb     then return false -- custom types after default ones
  end

  -- custom types are sorted out alphabetically
  return ta < tb
end

local function getNonSequentialKeys(t)
  local keys, length = {}, #t
  for k,_ in pairs(t) do
	if not isSequenceKey(k, length) then table.insert(keys, k) end
  end
  table.sort(keys, sortKeys)
  return keys
end

local function getToStringResultSafely(t, mt)
  local __tostring = type(mt) == 'table' and rawget(mt, '__tostring')
  local str, ok
  if type(__tostring) == 'function' then
	ok, str = pcall(__tostring, t)
	str = ok and str or 'error: ' .. tostring(str)
  end
  if type(str) == 'string' and #str > 0 then return str end
end

local maxIdsMetaTable = {
  __index = function(self, typeName)
	rawset(self, typeName, 0)
	return 0
  end
}

local idsMetaTable = {
  __index = function (self, typeName)
	local col = setmetatable({}, {__mode = "kv"})
	rawset(self, typeName, col)
	return col
  end
}

local function countTableAppearances(t, tableAppearances)
  tableAppearances = tableAppearances or setmetatable({}, {__mode = "k"})

  if type(t) == 'table' then
	if not tableAppearances[t] then
	  tableAppearances[t] = 1
	  for k,v in pairs(t) do
		countTableAppearances(k, tableAppearances)
		countTableAppearances(v, tableAppearances)
	  end
	  countTableAppearances(getmetatable(t), tableAppearances)
	else
	  tableAppearances[t] = tableAppearances[t] + 1
	end
  end

  return tableAppearances
end

local copySequence = function(s)
  local copy, len = {}, #s
  for i=1, len do copy[i] = s[i] end
  return copy, len
end

local function makePath(path, ...)
  local keys = {...}
  local newPath, len = copySequence(path)
  for i=1, #keys do
	newPath[len + i] = keys[i]
  end
  return newPath
end

local function processRecursive(process, item, path)
  if item == nil then return nil end

  local processed = process(item, path)
  if type(processed) == 'table' then
	local processedCopy = {}
	local processedKey

	for k,v in pairs(processed) do
	  processedKey = processRecursive(process, k, makePath(path, k, prettify.KEY))
	  if processedKey ~= nil then
		processedCopy[processedKey] = processRecursive(process, v, makePath(path, processedKey))
	  end
	end

	local mt  = processRecursive(process, getmetatable(processed), makePath(path, prettify.METATABLE))
	setmetatable(processedCopy, mt)
	processed = processedCopy
  end
  return processed
end


-------------------------------------------------------------------

local PrettifyTable = {}
local PrettifyTable_mt = {__index = PrettifyTable}

function PrettifyTable:puts(...)
  local args   = {...}
  local buffer = self.buffer
  local len    = #buffer
  for i=1, #args do
	len = len + 1
	buffer[len] = tostring(args[i])
  end
end

function PrettifyTable:down(f)
  self.level = self.level + 1
  f()
  self.level = self.level - 1
end

function PrettifyTable:tabify()
  self:puts(self.newline, rep(self.indent, self.level))
end

function PrettifyTable:alreadyVisited(v)
  return self.ids[type(v)][v] ~= nil
end

function PrettifyTable:getId(v)
  local tv = type(v)
  local id = self.ids[tv][v]
  if not id then
	id              = self.maxIds[tv] + 1
	self.maxIds[tv] = id
	self.ids[tv][v] = id
  end
  return id
end

function PrettifyTable:putKey(k)
  if isIdentifier(k) then return self:puts(k) end
  self:puts("[")
  self:putValue(k)
  self:puts("]")
end

function PrettifyTable:putTable(t)
  if t == prettify.KEY or t == prettify.METATABLE then
	self:puts(tostring(t))
  elseif self:alreadyVisited(t) then
	self:puts('<table ', self:getId(t), '>')
  elseif self.level >= self.depth then
	self:puts('{...}')
  else
	if self.tableAppearances[t] > 1 then self:puts('<', self:getId(t), '>') end

	local nonSequentialKeys = getNonSequentialKeys(t)
	local length            = #t
	local mt                = getmetatable(t)
	local toStringResult    = getToStringResultSafely(t, mt)

	self:puts('{')
	self:down(function()
	  if toStringResult then
		self:puts(' -- ', escape(toStringResult))
		if length >= 1 then self:tabify() end
	  end

	  local count = 0
	  for i=1, length do
		if count > 0 then self:puts(',') end
		self:puts(' ')
		self:putValue(t[i])
		count = count + 1
	  end

	  for _,k in ipairs(nonSequentialKeys) do
		if count > 0 then self:puts(',') end
		self:tabify()
		self:putKey(k)
		self:puts(' = ')
		self:putValue(t[k])
		count = count + 1
	  end

	  if mt then
		if count > 0 then self:puts(',') end
		self:tabify()
		self:puts('<metatable> = ')
		self:putValue(mt)
	  end
	end)

	if #nonSequentialKeys > 0 or mt then -- result is multi-lined. Justify closing }
	  self:tabify()
	elseif length > 0 then -- array tables have one extra space before closing }
	  self:puts(' ')
	end

	self:puts('}')
  end
end

function PrettifyTable:putValue(v)
  local tv = type(v)

  if tv == 'string' then
	self:puts(smartQuote(escape(v)))
  elseif tv == 'number' or tv == 'boolean' or tv == 'nil' then
	self:puts(tostring(v))
  elseif tv == 'table' then
	self:putTable(v)
  else
	self:puts('<',tv,' ',self:getId(v),'>')
  end
end


function prettify.prettify(root, options)
  options       = options or {}

  local depth   = options.depth   or huge
  local newline = options.newline or '\n'
  local indent  = options.indent  or '  '
  local process = options.process

  if process then
	root = processRecursive(process, root, {})
  end

  local prettify_table = setmetatable({
	depth            = depth,
	buffer           = {},
	level            = 0,
	ids              = setmetatable({}, idsMetaTable),
	maxIds           = setmetatable({}, maxIdsMetaTable),
	newline          = newline,
	indent           = indent,
	tableAppearances = countTableAppearances(root)
  }, PrettifyTable_mt)

  prettify_table:putValue(root)

  return tconcat(prettify_table.buffer)
end

setmetatable(prettify, { __call = function(_, ...) return prettify.prettify(...) end })

---------------------------------------------------------------------
-- Table
-- @section TABLE UTILITIES
---------------------------------------------------------------------

function table.val_to_str(v)
  	if "string" == type(v) then
		v = gsub(v, "\n", "\\n")
		if match( gsub(v,"[^'\"]",""), '^"+$') then
			return "'" .. v .. "'"
		end
	  	return '"' .. gsub(v,'"', '\\"') .. '"'
	else
		return "table" == type(v) and table.tostring(v) or
		tostring(v)
	end
end

function table.key_to_str(k)
	if "string" == type(k) and match(k, "^[_%a][_%a%d]*$") then
		return k
	else
		return "[" .. table.val_to_str(k) .. "]"
	end
end

---------------------------------------------------------------------
-- Dump table contents to string
-- @return string value
-- @param tbl A table to be stringified.
-- @param pretty Flag to syntactically format the result.
---------------------------------------------------------------------

function table.tostring(tbl, pretty)
	if(pretty) then
		return prettify(tbl)
	else
		local result, done = {}, {}
		for k, v in ipairs(tbl) do
			tinsert(result, table.val_to_str(v))
			done[k] = true
		end
		for k, v in pairs(tbl) do
			if not done[k] then
			  	tinsert(result, table.key_to_str(k) .. "=" .. table.val_to_str(v))
		  	end
		end
		return "{" .. tconcat( result, "," ) .. "}"
	end
end

---------------------------------------------------------------------
-- Copy all table data from a source to another table
-- @return copied data
-- @param targetTable The recipient of the copied data.
-- @param deepCopy Flag the use of DEEP copying.
-- @param mergeTable The origin of the copied data.
---------------------------------------------------------------------

function table.copy(targetTable, deepCopy, mergeTable)
	mergeTable = mergeTable or {};
	if(targetTable == nil) then return nil end
	if(mergeTable[targetTable]) then return mergeTable[targetTable] end
	local replacementTable = {}
	for key,value in pairs(targetTable)do
		if deepCopy and type(value) == "table" then
			replacementTable[key] = table.copy(value, deepCopy, mergeTable)
		else
			replacementTable[key] = value
		end
	end
	setmetatable(replacementTable, table.copy(getmetatable(targetTable), deepCopy, mergeTable))
	mergeTable[targetTable] = replacementTable;
	return replacementTable
end
