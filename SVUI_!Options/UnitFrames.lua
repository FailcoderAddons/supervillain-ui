--[[
##########################################################
S V U I   By: Failcoder
##########################################################
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
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
local table 	 	= _G.table;
local string 	 	= _G.string;
local upper 		= string.upper;
local gsub 			= string.gsub;
--[[ TABLE METHODS ]]--
local tsort = table.sort;

local NONE = _G.NONE;
local GetSpellInfo = _G.GetSpellInfo;
local collectgarbage = _G.collectgarbage;
--[[
##########################################################
GET ADDON DATA
##########################################################
]]--
local SV = _G["SVUI"];
local L = SV.L;
local MOD = SV.UnitFrames;
if(not MOD) then return end;
local _, SVUIOptions = ...;
local Schema = MOD.Schema;
local ACD = LibStub("AceConfigDialog-3.0");
local playerClass = select(2, UnitClass("player"));
local DEFAULT_COLOR = {["r"] = 1, ["g"] = 0, ["b"] = 0};
local STYLE_SELECT = {["coloredIcon"] = L["Colored Icon"], ["texturedIcon"] = L["Textured Icon"], [""] = NONE};
local POSITION_SELECT = {
	["TOPLEFT"] = "TOPLEFT",
	["TOPRIGHT"] = "TOPRIGHT",
	["BOTTOMLEFT"] = "BOTTOMLEFT",
	["BOTTOMRIGHT"] = "BOTTOMRIGHT",
	["LEFT"] = "LEFT",
	["RIGHT"] = "RIGHT",
	["TOP"] = "TOP",
	["BOTTOM"] = "BOTTOM"
};

local ANCHOR_SELECT = {
	["LEFT"] = "LEFT",
	["RIGHT"] = "RIGHT",
	["TOP"] = "TOP",
	["BOTTOM"] = "BOTTOM"
};

local textStringFormats = {
	["none"] = "None",
	["current"] = "Current",
	["deficit"] = "Deficit",
	["percent"] = "Percent",
	["curpercent"] = "Current - Percent",
	["curmax"] = "Current - Maximum",
	["curmax-percent"] = "Current - Maximum | %",
};

local FRAME_MAP = {
	["player"] = "SVUI_Player",
	["target"] = "SVUI_Target",
	["targettarget"] = "SVUI_TargetTarget",
	["pet"] = "SVUI_Pet",
	["pettarget"] = "SVUI_PetTarget",
	["focus"] = "SVUI_Focus",
	["focustarget"] = "SVUI_FocusTarget",
};

local tempFilterTable, filterList = {}, {};

if(not SV.db.Filters.PetBuffWatch) then
	SV.db.Filters.PetBuffWatch = {}
end

if(not SV.db.Filters.BuffWatch) then
	SV.db.Filters.BuffWatch = {}
end

local function SetWatchedBuff(stringID, id, data, enable, point, color, anyUnit)
	if(not data[id]) then
		data[stringID] = {["enable"] = enable, ["id"] = id, ["point"] = point, ["color"] = color, ["anyUnit"] = anyUnit}
	else
		data[stringID]["id"] = id;
		data[stringID]["enable"] = enable;
		data[stringID]["point"] = point;
		data[stringID]["color"] = color;
		data[stringID]["anyUnit"] = anyUnit;
	end
end

local function UpdateBuffWatch()
	MOD:SetUnitFrame("focus")
	MOD:SetGroupFrame("raid")
	MOD:SetGroupFrame("party")
end

local function UpdatePetBuffWatch()
	MOD:SetUnitFrame("pet")
	MOD:SetGroupFrame("raidpet")
end

local unitFonts = {
	["unitaurabar"] = {
		order = 1,
		name = "Unitframe AuraBar",
		desc = "Used on unit aurabars."
	},
    ["unitaura"] = {
		order = 2,
		name = "Unitframe Aura",
		desc = "Used on unit frames for auras (normal scale)."
	},
    ["unitaurasmall"] = {
		order = 3,
		name = "Unitframe Aura (Small)",
		desc = "Used on unit frames for auras (small scale)."
	},
    ["unitprimary"] = {
		order = 4,
		name = "Unitframe Values",
		desc = "Used on all primary unit frames for health, power and misc values.\nUnits: player, pet, target, focus, boss and arena"
	},
    ["unitsecondary"] = {
		order = 5,
		name = "Unitframe Values",
		desc = "Used on all non-primary unit frames for health, power and misc values.\nUnits: pettarget, targettarget, focustarget, party, raid, raidpet, tank and assist."
	},
};

--[[
##########################################################
HELPER FUNCTIONS
##########################################################
]]--
function SVUIOptions:SetSizeConfigGroup(gridMode, unitName)

	local sizeGroup = {
		order = 2,
		guiInline = true,
		type = "group",
		name = L["Size Settings"],
		args = {}
	}

	if(gridMode) then
		sizeGroup.args = {
			size = {
				order = 1,
				name = L["Grid Size"],
				type = "range",
				min = 10,
				max = 100,
				step = 1,
				width = 'full',
				get = function(key) return SV.db.UnitFrames[unitName].grid[key[#key]] end,
				set = function(key, value) MOD:ChangeDBVar(value, key[#key], unitName, "grid"); MOD:SetGroupFrame(unitName) end,
			},
			spacer1 = {
				order = 2,
				name = "",
				type = "description",
				width = "full",
			},
			wrapXOffset = {
				order = 3,
				type = "range",
				name = L["Horizontal Spacing"],
				min = 0,
				max = 50,
				step = 1,
				get = function(key) return SV.db.UnitFrames[unitName][key[#key]] end,
				set = function(key, value) MOD:ChangeDBVar(value, key[#key], unitName); MOD:SetGroupFrame(unitName) end,
			},
			wrapYOffset = {
				order = 4,
				type = "range",
				name = L["Vertical Spacing"],
				min = 0,
				max = 50,
				step = 1,
				get = function(key) return SV.db.UnitFrames[unitName][key[#key]] end,
				set = function(key, value) MOD:ChangeDBVar(value, key[#key], unitName); MOD:SetGroupFrame(unitName) end,
			},
		}
	else
		sizeGroup.args = {
			width = {
				order = 1,
				name = L["Width"],
				type = "range",
				min = 10,
				max = 500,
				step = 1,
				width = 'full',
				get = function(key) return SV.db.UnitFrames[unitName][key[#key]] end,
				set = function(key, value) MOD:ChangeDBVar(value, key[#key], unitName); MOD:SetGroupFrame(unitName) end,
			},
			height = {
				order = 2,
				name = L["Height"],
				type = "range",
				min = 10,
				max = 500,
				step = 1,
				width = 'full',
				get = function(key) return SV.db.UnitFrames[unitName][key[#key]] end,
				set = function(key, value) MOD:ChangeDBVar(value, key[#key], unitName); MOD:SetGroupFrame(unitName) end,
			},
			spacer1 = {
				order = 3,
				name = "",
				type = "description",
				width = "full",
			},
			wrapXOffset = {
				order = 4,
				type = "range",
				name = L["Horizontal Spacing"],
				min = 0,
				max = 50,
				step = 1,
				width = 'full',
				get = function(key) return SV.db.UnitFrames[unitName][key[#key]] end,
				set = function(key, value) MOD:ChangeDBVar(value, key[#key], unitName); MOD:SetGroupFrame(unitName) end,
			},
			wrapYOffset = {
				order = 5,
				type = "range",
				name = L["Vertical Spacing"],
				min = 0,
				max = 50,
				step = 1,
				width = 'full',
				get = function(key) return SV.db.UnitFrames[unitName][key[#key]] end,
				set = function(key, value) MOD:ChangeDBVar(value, key[#key], unitName); MOD:SetGroupFrame(unitName) end,
			},
		}
	end

	return sizeGroup
end

function SVUIOptions:SetCastbarConfigGroup(updateFunction, unitName, count)
	local configTable = {
		order = 800,
		type = "group",
		name = L["Castbar"],
		get = function(key)
			return SV.db.UnitFrames[unitName]["castbar"][key[#key]]
		end,
		set = function(key, value)
			MOD:ChangeDBVar(value, key[#key], unitName, "castbar")
			updateFunction(MOD, unitName, count)
		end,
		args = {
			enable = {
				type = "toggle",
				order = 1,
				name = L["Enable"]
			},
			commonGroup = {
				order = 2,
				guiInline = true,
				type = "group",
				name = L["Base Settings"],
				args = {
					forceshow = {
						order = 1,
						name = SHOW.." / "..HIDE,
						type = "execute",
						func = function()
							local v = unitName:gsub("(.)", upper, 1)
							v = "SVUI_"..v;
							v = v:gsub("t(arget)", "T%1")
							if count then
								for w = 1, count do
									local castbar = _G[v..w].Castbar;
									if not castbar.oldHide then
										castbar.oldHide = castbar.Hide;
										castbar.Hide = castbar.Show;
										castbar:Show()
									else
										castbar.Hide = castbar.oldHide;
										castbar.oldHide = nil;
										castbar:Hide()
										castbar.lastUpdate = 0
									end
								end
							else
								local castbar = _G[v].Castbar;
								if not castbar.oldHide then
									castbar.oldHide = castbar.Hide;
									castbar.Hide = castbar.Show;
									castbar:Show()
								else
									castbar.Hide = castbar.oldHide;
									castbar.oldHide = nil;
									castbar:Hide()
									castbar.lastUpdate = 0
								end
							end
						end,
					},
					icon = {
						order = 2,
						name = L["Icon"],
						type = "toggle"
					},
					latency = {
						order = 3,
						name = L["Latency"],
						type = "toggle"
					},
					spark = {
						order = 4,
						type = "toggle",
						name = L["Spark"]
					},
				}
			},
			sizeGroup = {
				order = 3,
				guiInline = true,
				type = "group",
				name = L["Size Settings"],
				args = {
					matchFrameWidth = {
						order = 1,
						name = L["Auto Width"],
						desc = "Force the castbar to ALWAYS match its unitframes width.",
						type = "toggle",
					},
					matchsize = {
						order = 2,
						type = "execute",
						name = L["Match Frame Width"],
						desc = "Set the castbar width to match its unitframe.",
						func = function()
							SV.db.UnitFrames[unitName]["castbar"]["width"] = SV.db.UnitFrames[unitName]["width"]
							updateFunction(MOD, unitName, count)
						end
					},
					width = {
						order = 3,
						name = L["Width"],
						type = "range",
						width = "full",
						min = 50,
						max = 600,
						step = 1,
						disabled = function() return SV.db.UnitFrames[unitName]["castbar"].matchFrameWidth end
					},
					height = {
						order = 4,
						name = L["Height"],
						type = "range",
						width = "full",
						min = 10,
						max = 85,
						step = 1
					},
				}
			},
			colorGroup = {
				order = 4,
				type = "group",
				guiInline = true,
				name = L["Custom Coloring"],
				args = {
					useCustomColor = {
						type = "toggle",
						order = 1,
						name = L["Enable"]
					},
					castingColor = {
						order = 2,
						name = L["Custom Bar Color"],
						type = "color",
						get = function(key)
							local color = SV.db.UnitFrames[unitName]["castbar"]["castingColor"]
							return color[1], color[2], color[3], color[4]
						end,
						set = function(key, rValue, gValue, bValue)
							SV.db.UnitFrames[unitName]["castbar"]["castingColor"] = {rValue, gValue, bValue}
							MOD:RefreshUnitFrames()
						end,
						disabled = function() return not SV.db.UnitFrames[unitName]["castbar"].useCustomColor end
					},
					sparkColor = {
						order = 3,
						name = L["Custom Spark Color"],
						type = "color",
						get = function(key)
							local color = SV.db.UnitFrames[unitName]["castbar"]["sparkColor"]
							return color[1], color[2], color[3], color[4]
						end,
						set = function(key, rValue, gValue, bValue)
							SV.db.UnitFrames[unitName]["castbar"]["sparkColor"] = {rValue, gValue, bValue}
							MOD:RefreshUnitFrames()
						end,
						disabled = function() return not SV.db.UnitFrames[unitName]["castbar"].useCustomColor end
					},
				}
			},
			formatGroup = {
				order = 4,
				guiInline = true,
				type = "group",
				name = L["Text Settings"],
				args = {
					format = {
						order = 1,
						type = "select",
						name = L["Format"],
						values = { ["CURRENTMAX"] = L["Current / Max"], ["CURRENT"] = L["Current"], ["REMAINING"] = L["Remaining"] }
					},
				}
			}
		}
	}
	if(unitName == "player") then
		configTable.args.commonGroup.args.ticks = {
			order = 6,
			type = "toggle",
			name = L["Ticks"],
			desc = L["Display tick marks on the castbar."]
		}
		configTable.args.commonGroup.args.displayTarget = {
			order = 7,
			type = "toggle",
			name = L["Display Target"],
			desc = L["Display the target of your current cast."]
		}
	end
	return configTable
end

function SVUIOptions:SetMiscConfigGroup(partyRaid, updateFunction, unitName, count)
	local miscGroup = {
		order = 99,
		type = "group",
		name = L["Misc Text"],
		set = function(key, value)
			MOD:ChangeDBVar(value, key[#key], unitName, "formatting");
			local tag = ""
			local pc = SV.db.UnitFrames[unitName]["formatting"].threat and "[threat]" or "";
			tag = tag .. pc;
			local ap = SV.db.UnitFrames[unitName]["formatting"].absorbs and "[absorbs]" or "";
			tag = tag .. ap;
			local cp = SV.db.UnitFrames[unitName]["formatting"].incoming and "[incoming]" or "";
			tag = tag .. cp;

			MOD:ChangeDBVar(tag, "tags", unitName, "misc");
			updateFunction(MOD, unitName, count)
		end,
		args = {
			incoming = {
				order = 1,
				name = L["Show Incoming Heals"],
				type = "toggle",
				get = function() return SV.db.UnitFrames[unitName]["formatting"].incoming end,
			},
			absorbs = {
				order = 2,
				name = L["Show Absorbs"],
				type = "toggle",
				get = function() return SV.db.UnitFrames[unitName]["formatting"].absorbs end,
			},
			threat = {
				order = 3,
				name = L["Show Threat"],
				type = "toggle",
				get = function() return SV.db.UnitFrames[unitName]["formatting"].threat end,
			},
			xOffset = {
				order = 4,
				type = "range",
				width = "full",
				name = L["Misc Text X Offset"],
				desc = L["Offset position for text."],
				min = -300,
				max = 300,
				step = 1,
				get = function() return SV.db.UnitFrames[unitName]["formatting"].xOffset end,
				set = function(key, value) MOD:ChangeDBVar(value, key[#key], unitName, "formatting"); end,
			},
			yOffset = {
				order = 5,
				type = "range",
				width = "full",
				name = L["Misc Text Y Offset"],
				desc = L["Offset position for text."],
				min = -300,
				max = 300,
				step = 1,
				get = function() return SV.db.UnitFrames[unitName]["formatting"].yOffset end,
				set = function(key, value) MOD:ChangeDBVar(value, key[#key], unitName, "formatting"); end,
			},
		}
	}
	return miscGroup
end

function SVUIOptions:SetHealthConfigGroup(partyRaid, updateFunction, unitName, count)
	local healthOptions = {
		order = 100,
		type = "group",
		name = L["Health"],
		get = function(key)
			return SV.db.UnitFrames[unitName]["health"][key[#key]]
		end,
		set = function(key, value)
			MOD:ChangeDBVar(value, key[#key], unitName, "health");
			updateFunction(MOD, unitName, count)
		end,
		args = {
			commonGroup = {
				order = 1,
				type = "group",
				guiInline = true,
				name = L["Base Settings"],
				args = {
					position = {
						type = "select",
						order = 1,
						name = L["Text Position"],
						desc = L["Set the anchor for this bars value text"],
						values = SV.PointIndexes
					},
					xOffset = {
						order = 2,
						type = "range",
						name = L["Text xOffset"],
						desc = L["Offset position for text."],
						min = -300,
						max = 300,
						step = 1
					},
					yOffset = {
						order = 3,
						type = "range",
						name = L["Text yOffset"],
						desc = L["Offset position for text."],
						min = -300,
						max = 300,
						step = 1
					},
					spacer1 = {
						order = 4,
						name = "",
						type = "description",
						width = "full",
					},
					reversed = {
						type = "toggle",
						order = 5,
						name = L["Reverse Fill"],
						desc = L["Invert this bars fill direction"]
					},
				}
			},
			formatGroup = {
				order = 2,
				type = "group",
				guiInline = true,
				name = L["Text Settings"],
				set = function(key, value)
					MOD:ChangeDBVar(value, key[#key], unitName, "formatting");
					local tag = ""
					local pc = SV.db.UnitFrames[unitName]["formatting"].health_colored and "[health:color]" or "";
					tag = tag .. pc;

					local pt = SV.db.UnitFrames[unitName]["formatting"].health_type;
					if(pt and pt ~= "none") then
						tag = tag .. "[health:" .. pt .. "]"
					end

					MOD:ChangeDBVar(tag, "tags", unitName, "health");
					updateFunction(MOD, unitName, count)
				end,
				args = {
					health_colored = {
						order = 1,
						name = L["Colored"],
						type = "toggle",
						get = function() return SV.db.UnitFrames[unitName]["formatting"].health_colored end,
						desc = L["Use various name coloring methods"]
					},
					health_type = {
						order = 3,
						name = L["Text Format"],
						type = "select",
						get = function() return SV.db.UnitFrames[unitName]["formatting"].health_type end,
						desc = L["TEXT_FORMAT_DESC"],
						values = textStringFormats,
					}
				}
			},
			colorGroup = {
				order = 3,
				type = "group",
				guiInline = true,
				name = L["Color Settings"],
				args = {
					classColor = {
						order = 1,
						type = "toggle",
						name = L["Class Health"],
						desc = L["Color health by classcolor or reaction."],
					},
					valueColor = {
						order = 2,
						type = "toggle",
						name = L["Health By Value"],
						desc = L["Color health by amount remaining."],
					},
					classBackdrop = {
						order = 3,
						type = "toggle",
						name = L["Class Backdrop"],
						desc = L["Color the health backdrop by class or reaction."],
					},
					configureButton = {
						order = 4,
						name = L["Coloring"],
						type = "execute",
						width = 'full',
						func = function() ACD:SelectGroup(SV.NameID, "UnitFrames", "commonGroup", "baseGroup", "allColorsGroup", "healthGroup") end
					},
				}
			},
			extra = {
				order = 4,
				type = "group",
				guiInline = true,
				name = "Extras",
				args = {
					absorbsBar = {
						type = "toggle",
						name = "Absorbs Bar",
						desc = "Show an absorb bar anchored to health bar. \n It allows to see the current health effective (current health + current absorbs).",
					}
				}
			}
		}
	}
	if SV.db.UnitFrames[unitName].health.orientation then
		healthOptions.args.commonGroup.args.orientation = {
			type = "select",
			order = 6,
			name = L["Orientation"],
			desc = L["Direction the health bar moves when gaining/losing health."],
			values = {["HORIZONTAL"] = L["Horizontal"], ["VERTICAL"] = L["Vertical"]}
		}
	end
	if partyRaid then
		healthOptions.args.commonGroup.args.frequentUpdates = {
			type = "toggle",
			order = 7,
			name = L["Frequent Updates"],
			desc = L["Rapidly update the health, uses more memory and cpu. Only recommended for healing."]
		}
	end
	return healthOptions
end

function SVUIOptions:SetPowerConfigGroup(playerTarget, updateFunction, unitName, count)
	local powerOptions = {
		order = 200,
		type = "group",
		name = L["Power"],
		get = function(key)
			return SV.db.UnitFrames[unitName]["power"][key[#key]]
		end,
		set = function(key, value)
			MOD:ChangeDBVar(value, key[#key], unitName, "power");
			updateFunction(MOD, unitName, count)
		end,
		args = {
			enable = {type = "toggle", order = 1, name = L["Power Bar Enabled"]},
			commonGroup = {
				order = 2,
				type = "group",
				guiInline = true,
				name = L["Base Settings"],
				args = {
					detached = {
						type = "toggle",
						order = 1,
						name = L["Detached"],
						desc = L["Detach the power bar from the unit frame."]
					},
					anchor = {
						type = "select",
						order = 2,
						name = L["Bar Position"],
						desc = L["Set direction to anchor this bar"],
						values = ANCHOR_SELECT
					},
					height = {
						type = "range",
						name = L["Height"],
						width = 'full',
						order = 4,
						min = 3,
						max = 250,
						step = 1
					},
					width = {
						type = "range",
						name = L["Width"],
						width = 'full',
						order = 5,
						min = 3,
						max = 250,
						step = 1
					},
				}
			},
			textGroup = {
				order = 3,
				type = "group",
				guiInline = true,
				name = L["Text Settings"],
				args = {
					position = {
						type = "select",
						order = 1,
						name = L["Text Position"],
						desc = L["Set the anchor for this bars value text"],
						values = SV.PointIndexes
					},
					xOffset = {
						order = 2,
						type = "range",
						name = L["Text xOffset"],
						desc = L["Offset position for text."],
						min = -300,
						max = 300,
						step = 1
					},
					yOffset = {
						order = 3,
						type = "range",
						name = L["Text yOffset"],
						desc = L["Offset position for text."],
						min = -300,
						max = 300,
						step = 1
					},
				}
			},
			formatGroup = {
				order = 4,
				type = "group",
				guiInline = true,
				name = L["Text Formatting"],
				set = function(key, value)
					MOD:ChangeDBVar(value, key[#key], unitName, "formatting");
					local tag = ""
					local cp = SV.db.UnitFrames[unitName]["formatting"].power_class and "[classpower]" or "";
					tag = tag .. cp;
					local ap = SV.db.UnitFrames[unitName]["formatting"].power_alt and "[altpower]" or "";
					tag = tag .. ap;
					local pc = SV.db.UnitFrames[unitName]["formatting"].power_colored and "[power:color]" or "";
					tag = tag .. pc;

					local pt = SV.db.UnitFrames[unitName]["formatting"].power_type;
					if(pt and pt ~= "none") then
						tag = tag .. "[power:" .. pt .. "]"
					end

					MOD:ChangeDBVar(tag, "tags", unitName, "power");
					updateFunction(MOD, unitName, count)
				end,
				args = {
					power_colored = {
						order = 1,
						name = L["Colored"],
						type = "toggle",
						get = function() return SV.db.UnitFrames[unitName]["formatting"].power_colored end,
						desc = L["Use various name coloring methods"]
					},
					power_class = {
						order = 2,
						name = L["Show Class Power"],
						type = "toggle",
						get = function() return SV.db.UnitFrames[unitName]["formatting"].power_class end,
					},
					power_alt = {
						order = 3,
						name = L["Show Alt Power"],
						type = "toggle",
						get = function() return SV.db.UnitFrames[unitName]["formatting"].power_alt end,
					},
					power_type = {
						order = 4,
						name = L["Text Format"],
						type = "select",
						get = function() return SV.db.UnitFrames[unitName]["formatting"].power_type end,
						desc = L["TEXT_FORMAT_DESC"],
						values = textStringFormats,
					}
				}
			},
			colorGroup = {
				order = 5,
				type = "group",
				guiInline = true,
				name = L["Color Settings"],
				args = {
					classColor = {
						order = 1,
						type = "toggle",
						name = L["Class Power"],
						desc = L["Color power by classcolor or reaction."],
					},
					configureButton = {
						order = 2,
						name = L["Coloring"],
						type = "execute",
						width = 'full',
						func = function() ACD:SelectGroup(SV.NameID, "UnitFrames", "commonGroup", "baseGroup", "allColorsGroup", "powerGroup") end
					},
				}
			}
		}
	}

	if SV.db.UnitFrames[unitName].power.orientation then
		powerOptions.args.commonGroup.args.orientation = {
			type = "select",
			order = 3,
			name = L["Orientation"],
			desc = L["Direction the power bar moves when gaining/losing power."],
			values = {["HORIZONTAL"] = L["Horizontal"], ["VERTICAL"] = L["Vertical"]}
		}
	end

	return powerOptions
end

function SVUIOptions:SetNameConfigGroup(updateFunction, unitName, count)
	local k = {
		order = 400,
		type = "group",
		name = L['Name'],
		get = function(key)
			return SV.db.UnitFrames[unitName]["name"][key[#key]]
		end,
		set = function(key, value)
			MOD:ChangeDBVar(value, key[#key], unitName, "name");
			updateFunction(MOD, unitName, count)
		end,
		disabled = function()
			if(SV.db.UnitFrames[unitName].grid and SV.db.UnitFrames[unitName].grid.enable) then
				return true
			end
			return false
		end,
		args = {
			description = {
				order = 1,
				name = function()
					if(SV.db.UnitFrames[unitName].grid and SV.db.UnitFrames[unitName].grid.enable) then
						return L['Name Options Disabled While in Grid Mode']
					end
					return ''
				end,
				type = "description",
				width = "full",
			},
			enable = {
				type = "toggle",
				order = 2,
				name = L["Unit Name Enabled"],
				get = function(key)
					return SV.db.UnitFrames[unitName]["name"].tags ~= ""
				end,
				set = function(key, value)
					MOD:ChangeDBVar(value, key[#key], unitName, "formatting");
					local tag = ""
					if(value == true) then
						tag = SV.db.UnitFrames[unitName]["formatting"].name_colored and "[name:color]" or "";

						local length = SV.db.UnitFrames[unitName]["formatting"].name_length;
						tag = tag .. "[name:" .. length .. "]"
						local lvl = SV.db.UnitFrames[unitName]["formatting"].smartlevel and "[smartlevel]" or "";
						tag = tag .. lvl
					end

					MOD:ChangeDBVar(tag, "tags", unitName, "name");
					updateFunction(MOD, unitName, count)
				end,
			},
			commonGroup = {
				order = 3,
				type = "group",
				guiInline = true,
				name = L["Base Settings"],
				args = {
					position = {
						type = "select",
						order = 1,
						name = L["Text Position"],
						desc = L["Set the anchor for this units name text"],
						values = SV.PointIndexes
					},
					xOffset = {
						order = 2,
						type = "range",
						name = L["Text xOffset"],
						desc = L["Offset position for text."],
						min = -300,
						max = 300,
						step = 1
					},
					yOffset = {
						order = 3,
						type = "range",
						name = L["Text yOffset"],
						desc = L["Offset position for text."],
						min = -300,
						max = 300,
						step = 1
					},
				}
			},
			fontGroup = {
				order = 4,
				type = "group",
				guiInline = true,
				name = L["Fonts"],
				set = function(key, value)
					MOD:ChangeDBVar(value, key[#key], unitName, "name");
					MOD:RefreshAllUnitMedia()
				end,
				args = {
					font = {
						type = "select",
						dialogControl = "LSM30_Font",
						order = 0,
						name = L["Default Font"],
						desc = L["The font used to show unit names."],
						values = AceVillainWidgets.font
					},
					fontOutline = {
						order = 1,
						name = L["Font Outline"],
						desc = L["Set the font outline."],
						type = "select",
						values = {["NONE"] = L["None"], ["OUTLINE"] = "OUTLINE", ["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE", ["THICKOUTLINE"] = "THICKOUTLINE"}
					},
					fontSize = {
						order = 2,
						name = L["Font Size"],
						desc = L["Set the font size."],
						type = "range",
						min = 6,
						max = 22,
						step = 1
					}
				}
			},
			formatGroup = {
				order = 5,
				type = "group",
				guiInline = true,
				name = L["Text Settings"],
				set = function(key, value)
					MOD:ChangeDBVar(value, key[#key], unitName, "formatting");
					local tag = ""
					tag = SV.db.UnitFrames[unitName]["formatting"].name_colored and "[name:color]" or "";

					local length = SV.db.UnitFrames[unitName]["formatting"].name_length;
					tag = tag .. "[name:" .. length .. "]"
					local lvl = SV.db.UnitFrames[unitName]["formatting"].smartlevel and "[smartlevel]" or "";
					tag = tag .. lvl

					MOD:ChangeDBVar(tag, "tags", unitName, "name");
					updateFunction(MOD, unitName, count)
				end,
				args = {
					name_colored = {
						order = 1,
						name = L["Colored"],
						type = "toggle",
						get = function() return SV.db.UnitFrames[unitName]["formatting"].name_colored end,
						desc = L["Use various name coloring methods"]
					},
					smartlevel = {
						order = 2,
						name = L["Unit Level"],
						type = "toggle",
						get = function() return SV.db.UnitFrames[unitName]["formatting"].smartlevel end,
						desc = L["Display the units level"]
					},
					name_length = {
						order = 3,
						name = L["Name Length"],
						desc = L["TEXT_FORMAT_DESC"],
						type = "range",
						get = function() return SV.db.UnitFrames[unitName]["formatting"].name_length end,
						min = 1,
						max = 30,
						step = 1
					}
				}
			}
		}
	}
	return k
end

local portraitStyles = {["2D"] = L["2D"], ["3D"] = L["3D"], ["3DOVERLAY"] = L["3D Overlay"]};

function SVUIOptions:SetPortraitConfigGroup(updateFunction, unitName, count)
	local k = {
		order = 400,
		type = "group",
		name = L["Portrait"],
		get = function(key)
			return SV.db.UnitFrames[unitName]["portrait"][key[#key]]
		end,
		set = function(key, value)
			MOD:ChangeDBVar(value, key[#key], unitName, "portrait")
			updateFunction(MOD, unitName, count)
		end,
		args = {
			enable = {
				type = "toggle",
				order = 1,
				name = L["Unit Portrait Enabled"]
			},
			styleGroup = {
				order = 2,
				type = "group",
				guiInline = true,
				name = L["Base Settings"],
				args = {
					style = {
						order = 1,
						type = "select",
						name = L["Style"],
						desc = L["Select the display method of the portrait. NOTE: if overlay is set then only 3D will be available"],
						values = portraitStyles
					},
					width = {
						order = 2,
						type = "range",
						name = L["Width"],
						min = 15,
						max = 150,
						step = 1,
						disabled = function() return SV.db.UnitFrames[unitName]["portrait"].style == "3DOVERLAY" end
					}
				}
			},
			modGroup = {
				order = 3,
				type = "group",
				guiInline = true,
				name = L["3D Settings (Reload required to take affect)"],
				disabled = function() return SV.db.UnitFrames[unitName]["portrait"].style == "2D" end,
				args = {
					rotation = {
						order = 1,
						type = "range",
						name = L["Model Rotation"],
						min = 0,
						max = 360,
						step = 1
					},
					camDistanceScale = {
						order = 2,
						type = "range",
						name = L["Camera Distance Scale"],
						desc = L["How far away the portrait is from the camera."],
						min = 0.01,
						max = 4,
						step = 0.01
					},
				}
			}
		}
	}
	return k
end

function SVUIOptions:SetIconConfigGroup(updateFunction, unitName, count)
	local iconGroup = SV.db.UnitFrames[unitName]["icons"]
	local grouporder = 1
	local k = {
		order = 5000,
		type = "group",
		name = L["Icons"],
		get = function(key)
			return SV.db.UnitFrames[unitName]["icons"][key[#key]]
		end,
		set = function(key, value)
			MOD:ChangeDBVar(value, key[#key], unitName, "icons")
			updateFunction(MOD, unitName, count)
		end,
		args = {}
	};

	if(iconGroup["classIcon"]) then
		k.args.classIcon = {
			order = grouporder,
			type = "group",
			guiInline = true,
			name = L["Class Icons"],
			get = function(key)
				return SV.db.UnitFrames[unitName]["icons"]["classIcon"][key[#key]]
			end,
			set = function(key, value)
				MOD:ChangeDBVar(value, key[#key], unitName, "icons", "classIcon")
				updateFunction(MOD, unitName, count)
			end,
			args = {
				enable = {type = "toggle", order = 1, name = L["Enable"]},
				attachTo = {type = "select", order = 2, name = L["Position"], values = SV.PointIndexes},
				spacer = { order = 3, name = "", type = "description", width = "full"},
				size = {type = "range", name = L["Size"], order = 3, min = 8, max = 60, step = 1},
				xOffset = {order = 4, type = "range", name = L["xOffset"], min = -300, max = 300, step = 1},
				yOffset = {order = 5, type = "range", name = L["yOffset"], min = -300, max = 300, step = 1}
			}
		}
		grouporder = grouporder + 1
	end

	if(iconGroup["raidicon"]) then
		k.args.raidicon = {
			order = grouporder,
			type = "group",
			guiInline = true,
			name = L["Raid Marker"],
			get = function(key)
				return SV.db.UnitFrames[unitName]["icons"]["raidicon"][key[#key]]
			end,
			set = function(key, value)
				MOD:ChangeDBVar(value, key[#key], unitName, "icons", "raidicon")
				updateFunction(MOD, unitName, count)
			end,
			args = {
				enable = {type = "toggle", order = 1, name = L["Enable"]},
				attachTo = {type = "select", order = 2, name = L["Position"], values = SV.PointIndexes},
				spacer = { order = 3, name = "", type = "description", width = "full"},
				size = {type = "range", name = L["Size"], order = 3, min = 8, max = 60, step = 1},
				xOffset = {order = 4, type = "range", name = L["xOffset"], min = -300, max = 300, step = 1},
				yOffset = {order = 5, type = "range", name = L["yOffset"], min = -300, max = 300, step = 1}
			}
		}
		grouporder = grouporder + 1
	end

	if(iconGroup["aggroIcon"]) then
		k.args.aggroIcon = {
			order = grouporder,
			type = "group",
			guiInline = true,
			name = L["Aggro (aka: !)"],
			get = function(key)
				return SV.db.UnitFrames[unitName]["icons"]["aggroIcon"][key[#key]]
			end,
			set = function(key, value)
				MOD:ChangeDBVar(value, key[#key], unitName, "icons", "aggroIcon")
				updateFunction(MOD, unitName, count)
			end,
			args = {
				enable = {type = "toggle", order = 1, name = L["Enable"]},
				attachTo = {type = "select", order = 2, name = L["Position"], values = SV.PointIndexes},
				spacer = { order = 3, name = "", type = "description", width = "full"},
				size = {type = "range", name = L["Size"], order = 3, min = 8, max = 60, step = 1},
				xOffset = {order = 4, type = "range", name = L["xOffset"], min = -300, max = 300, step = 1},
				yOffset = {order = 5, type = "range", name = L["yOffset"], min = -300, max = 300, step = 1}
			}
		}
		grouporder = grouporder + 1
	end

	if(iconGroup["combatIcon"]) then
		k.args.combatIcon = {
			order = grouporder,
			type = "group",
			guiInline = true,
			name = L["Combat"],
			get = function(key)
				return SV.db.UnitFrames[unitName]["icons"]["combatIcon"][key[#key]]
			end,
			set = function(key, value)
				MOD:ChangeDBVar(value, key[#key], unitName, "icons", "combatIcon")
				updateFunction(MOD, unitName, count)
			end,
			args = {
				enable = {type = "toggle", order = 1, name = L["Enable"]},
				attachTo = {type = "select", order = 2, name = L["Position"], values = SV.PointIndexes},
				spacer = { order = 3, name = "", type = "description", width = "full"},
				size = {type = "range", name = L["Size"], order = 3, min = 8, max = 60, step = 1},
				xOffset = {order = 4, type = "range", name = L["xOffset"], min = -300, max = 300, step = 1},
				yOffset = {order = 5, type = "range", name = L["yOffset"], min = -300, max = 300, step = 1}
			}
		}
		grouporder = grouporder + 1
	end

	if(iconGroup["restIcon"]) then
		k.args.restIcon = {
			order = grouporder,
			type = "group",
			guiInline = true,
			name = L["Resting"],
			get = function(key)
				return SV.db.UnitFrames[unitName]["icons"]["restIcon"][key[#key]]
			end,
			set = function(key, value)
				MOD:ChangeDBVar(value, key[#key], unitName, "icons", "restIcon")
				updateFunction(MOD, unitName, count)
			end,
			args = {
				enable = {type = "toggle", order = 1, name = L["Enable"]},
				attachTo = {type = "select", order = 2, name = L["Position"], values = SV.PointIndexes},
				spacer = { order = 3, name = "", type = "description", width = "full"},
				size = {type = "range", name = L["Size"], order = 3, min = 8, max = 60, step = 1},
				xOffset = {order = 4, type = "range", name = L["xOffset"], min = -300, max = 300, step = 1},
				yOffset = {order = 5, type = "range", name = L["yOffset"], min = -300, max = 300, step = 1}
			}
		}
		grouporder = grouporder + 1
	end

	if(iconGroup["classicon"]) then
		k.args.classicon = {
			order = grouporder,
			type = "group",
			guiInline = true,
			name = L["Class"],
			get = function(key)
				return SV.db.UnitFrames[unitName]["icons"]["classicon"][key[#key]]
			end,
			set = function(key, value)
				MOD:ChangeDBVar(value, key[#key], unitName, "icons", "classicon")
				updateFunction(MOD, unitName, count)
			end,
			args = {
				enable = {type = "toggle", order = 1, name = L["Enable"]},
				attachTo = {type = "select", order = 2, name = L["Position"], values = SV.PointIndexes},
				spacer = { order = 3, name = "", type = "description", width = "full"},
				size = {type = "range", name = L["Size"], order = 3, min = 8, max = 60, step = 1},
				xOffset = {order = 4, type = "range", name = L["xOffset"], min = -300, max = 300, step = 1},
				yOffset = {order = 5, type = "range", name = L["yOffset"], min = -300, max = 300, step = 1}
			}
		}
		grouporder = grouporder + 1
	end

	if(iconGroup["eliteicon"]) then
		k.args.eliteicon = {
			order = grouporder,
			type = "group",
			guiInline = true,
			name = L["Elite / Rare"],
			get = function(key)
				return SV.db.UnitFrames[unitName]["icons"]["eliteicon"][key[#key]]
			end,
			set = function(key, value)
				MOD:ChangeDBVar(value, key[#key], unitName, "icons", "eliteicon")
				updateFunction(MOD, unitName, count)
			end,
			args = {
				enable = {type = "toggle", order = 1, name = L["Enable"]},
				attachTo = {type = "select", order = 2, name = L["Position"], values = SV.PointIndexes},
				spacer = { order = 3, name = "", type = "description", width = "full"},
				size = {type = "range", name = L["Size"], order = 3, min = 8, max = 60, step = 1},
				xOffset = {order = 4, type = "range", name = L["xOffset"], min = -300, max = 300, step = 1},
				yOffset = {order = 5, type = "range", name = L["yOffset"], min = -300, max = 300, step = 1}
			}
		}
		grouporder = grouporder + 1
	end

	if(iconGroup["roleIcon"]) then
		k.args.roleIcon = {
			order = grouporder,
			type = "group",
			guiInline = true,
			name = L["Role"],
			get = function(key)
				return SV.db.UnitFrames[unitName]["icons"]["roleIcon"][key[#key]]
			end,
			set = function(key, value)
				MOD:ChangeDBVar(value, key[#key], unitName, "icons", "roleIcon")
				updateFunction(MOD, unitName, count)
			end,
			args = {
				enable = {type = "toggle", order = 1, name = L["Enable"]},
				attachTo = {type = "select", order = 2, name = L["Position"], values = SV.PointIndexes},
				spacer = { order = 3, name = "", type = "description", width = "full"},
				size = {type = "range", name = L["Size"], order = 3, min = 8, max = 60, step = 1},
				xOffset = {order = 4, type = "range", name = L["xOffset"], min = -300, max = 300, step = 1},
				yOffset = {order = 5, type = "range", name = L["yOffset"], min = -300, max = 300, step = 1}
			}
		}
		grouporder = grouporder + 1
	end

	if(iconGroup["raidRoleIcons"]) then
		k.args.raidRoleIcons = {
			order = grouporder,
			type = "group",
			guiInline = true,
			name = L["Leader / MasterLooter"],
			get = function(key)
				return SV.db.UnitFrames[unitName]["icons"]["raidRoleIcons"][key[#key]]
			end,
			set = function(key, value)
				MOD:ChangeDBVar(value, key[#key], unitName, "icons", "raidRoleIcons")
				updateFunction(MOD, unitName, count)
			end,
			args = {
				enable = {type = "toggle", order = 1, name = L["Enable"]},
				attachTo = {type = "select", order = 2, name = L["Position"], values = SV.PointIndexes},
				spacer = { order = 3, name = "", type = "description", width = "full"},
				size = {type = "range", name = L["Size"], order = 3, min = 8, max = 60, step = 1},
				xOffset = {order = 4, type = "range", name = L["xOffset"], min = -300, max = 300, step = 1},
				yOffset = {order = 5, type = "range", name = L["yOffset"], min = -300, max = 300, step = 1}
			}
		}
		grouporder = grouporder + 1
	end

	return k
end

local BoolFilters = {
	['player'] = true,
	['pet'] = true,
	['boss'] = true,
	['arena'] = true,
	['party'] = true,
	['raid'] = true,
	['raidpet'] = true,
};

local function setAuraFilteringOptions(configTable, unitName, auraType, updateFunction, isPlayer)
	if BoolFilters[unitName] then
		configTable.filterGroup = {
			order = 20,
			guiInline = true,
			type = "group",
			name = L["Aura filtering..."],
			args = {
				filterWhiteList = {
					order = 1,
					type = "toggle",
					name = L["Only White Listed"],
					desc = L["Only show auras that are on the whitelist."],
					get = function(key)return SV.db.UnitFrames[unitName][auraType].filterWhiteList end,
					set = function(key, value)
						SV.db.UnitFrames[unitName][auraType].filterWhiteList = value;
						if(value) then
							SV.db.UnitFrames[unitName][auraType].filterPlayer = false;
							SV.db.UnitFrames[unitName][auraType].filterDispellable = false;
							SV.db.UnitFrames[unitName][auraType].filterInfinite = false;
							SV.db.UnitFrames[unitName][auraType].filterRaid = false;
						end
						updateFunction(MOD, unitName)
					end,
				},
				filterPlayer = {
					order = 2,
					type = "toggle",
					name = L["From You"],
					desc = L["Only show auras that were cast by you."],
					get = function(key) return SV.db.UnitFrames[unitName][auraType].filterPlayer end,
					set = function(key, value) SV.db.UnitFrames[unitName][auraType].filterPlayer = value; updateFunction(MOD, unitName) end,
					disabled = function() return SV.db.UnitFrames[unitName][auraType].filterWhiteList end,
				},
				filterDispellable = {
					order = 3,
					type = "toggle",
					name = L["You Can Remove"],
					desc = L["Only show auras that can be removed by you. (example: Purge, Dispel)"],
					get = function(key) return SV.db.UnitFrames[unitName][auraType].filterDispellable end,
					set = function(key, value) SV.db.UnitFrames[unitName][auraType].filterDispellable = value; updateFunction(MOD, unitName) end,
					disabled = function() return SV.db.UnitFrames[unitName][auraType].filterWhiteList end,
				},
				filterInfinite = {
					order = 4,
					type = "toggle",
					name = L["No Duration"],
					desc = L["Don't display auras that have no duration."],
					get = function(key) return SV.db.UnitFrames[unitName][auraType].filterInfinite end,
					set = function(key, value) SV.db.UnitFrames[unitName][auraType].filterInfinite = value; updateFunction(MOD, unitName) end,
					disabled = function() return SV.db.UnitFrames[unitName][auraType].filterWhiteList end,
				},
				filterRaid = {
					order = 5,
					type = "toggle",
					name = L["Consolidated Buffs"],
					desc = L["Don't display consolidated buffs"],
					get = function(key) return SV.db.UnitFrames[unitName][auraType].filterRaid end,
					set = function(key, value) SV.db.UnitFrames[unitName][auraType].filterRaid = value; updateFunction(MOD, unitName) end,
					disabled = function() return SV.db.UnitFrames[unitName][auraType].filterWhiteList end,
				},
			}
		}
	else
		configTable.friendlyGroup = {
			order = 20,
			guiInline = true,
			type = "group",
			name = L["When the unit is friendly..."],
			args = {
				filterAll = {
					order = 1,
					type = "toggle",
					name = L["Hide All"],
					desc = L["Don't display any " .. auraType .. "."],
					get = function(key) return SV.db.UnitFrames[unitName][auraType].filterAll.friendly end,
					set = function(key, value)
						SV.db.UnitFrames[unitName][auraType].filterAll.friendly = value;
						if(value) then
							SV.db.UnitFrames[unitName][auraType].filterWhiteList.friendly = false;
							SV.db.UnitFrames[unitName][auraType].filterPlayer.friendly = false;
							SV.db.UnitFrames[unitName][auraType].filterDispellable.friendly = false;
							SV.db.UnitFrames[unitName][auraType].filterInfinite.friendly = false;
							if(SV.db.UnitFrames[unitName][auraType].filterRaid) then
								SV.db.UnitFrames[unitName][auraType].filterRaid.friendly = false;
							end
						end
						updateFunction(MOD, unitName)
					end,
				},
				filterWhiteList = {
					order = 2,
					type = "toggle",
					name = L["Only White Listed"],
					desc = L["Only show auras that are on the whitelist."],
					get = function(key)return SV.db.UnitFrames[unitName][auraType].filterWhiteList.friendly end,
					set = function(key, value)SV.db.UnitFrames[unitName][auraType].filterWhiteList.friendly = value; updateFunction(MOD, unitName) end,
					set = function(key, value)
						SV.db.UnitFrames[unitName][auraType].filterWhiteList.friendly = value;
						if(value) then
							SV.db.UnitFrames[unitName][auraType].filterPlayer.friendly = false;
							SV.db.UnitFrames[unitName][auraType].filterDispellable.friendly = false;
							SV.db.UnitFrames[unitName][auraType].filterInfinite.friendly = false;
							if(SV.db.UnitFrames[unitName][auraType].filterRaid) then
								SV.db.UnitFrames[unitName][auraType].filterRaid.friendly = false;
							end
						end
						updateFunction(MOD, unitName)
					end,
					disabled = function()
						return SV.db.UnitFrames[unitName][auraType].filterAll.friendly
					end,
				},
				filterPlayer = {
					order = 3,
					type = "toggle",
					name = L["From You"],
					desc = L["Only show auras that were cast by you."],
					get = function(key)return SV.db.UnitFrames[unitName][auraType].filterPlayer.friendly end,
					set = function(key, value)SV.db.UnitFrames[unitName][auraType].filterPlayer.friendly = value; updateFunction(MOD, unitName) end,
					disabled = function()
						return (SV.db.UnitFrames[unitName][auraType].filterAll.friendly or SV.db.UnitFrames[unitName][auraType].filterWhiteList.friendly)
					end,
				},
				filterDispellable = {
					order = 4,
					type = "toggle",
					name = L["You Can Remove"],
					desc = L["Only show auras that can be removed by you. (example: Purge, Dispel)"],
					get = function(key)return SV.db.UnitFrames[unitName][auraType].filterDispellable.friendly end,
					set = function(key, value)SV.db.UnitFrames[unitName][auraType].filterDispellable.friendly = value; updateFunction(MOD, unitName) end,
					disabled = function()
						return (SV.db.UnitFrames[unitName][auraType].filterAll.friendly or SV.db.UnitFrames[unitName][auraType].filterWhiteList.friendly)
					end,
				},
				filterInfinite = {
					order = 5,
					type = "toggle",
					name = L["No Duration"],
					desc = L["Don't display auras that have no duration."],
					get = function(key)return SV.db.UnitFrames[unitName][auraType].filterInfinite.friendly end,
					set = function(key, value)SV.db.UnitFrames[unitName][auraType].filterInfinite.friendly = value; updateFunction(MOD, unitName) end,
					disabled = function()
						return (SV.db.UnitFrames[unitName][auraType].filterAll.friendly or SV.db.UnitFrames[unitName][auraType].filterWhiteList.friendly)
					end,
				},
			},
		}
		configTable.enemyGroup = {
			order = 21,
			guiInline = true,
			type = "group",
			name = L["When the unit is hostile..."],
			args = {
				filterAll = {
					order = 1,
					type = "toggle",
					name = L["Hide All"],
					desc = L["Don't display any " .. auraType .. "."],
					get = function(key)return SV.db.UnitFrames[unitName][auraType].filterAll.enemy end,
					set = function(key, value)
						SV.db.UnitFrames[unitName][auraType].filterAll.enemy = value;
						if(value) then
							SV.db.UnitFrames[unitName][auraType].filterWhiteList.enemy = false;
							SV.db.UnitFrames[unitName][auraType].filterPlayer.enemy = false;
							SV.db.UnitFrames[unitName][auraType].filterDispellable.enemy = false;
							SV.db.UnitFrames[unitName][auraType].filterInfinite.enemy = false;
							if(SV.db.UnitFrames[unitName][auraType].filterRaid) then
								SV.db.UnitFrames[unitName][auraType].filterRaid.enemy = false;
							end
						end
						updateFunction(MOD, unitName)
					end,
				},
				filterWhiteList = {
					order = 2,
					type = "toggle",
					name = L["Only White Listed"],
					desc = L["Only show auras that are on the whitelist."],
					get = function(key)return SV.db.UnitFrames[unitName][auraType].filterWhiteList.enemy end,
					set = function(key, value)
						SV.db.UnitFrames[unitName][auraType].filterWhiteList.enemy = value;
						if(value) then
							SV.db.UnitFrames[unitName][auraType].filterPlayer.enemy = false;
							SV.db.UnitFrames[unitName][auraType].filterDispellable.enemy = false;
							SV.db.UnitFrames[unitName][auraType].filterInfinite.enemy = false;
							if(SV.db.UnitFrames[unitName][auraType].filterRaid) then
								SV.db.UnitFrames[unitName][auraType].filterRaid.enemy = false;
							end
						end
						updateFunction(MOD, unitName)
					end,
					disabled = function()
						return SV.db.UnitFrames[unitName][auraType].filterAll.enemy
					end,
				},
				filterPlayer = {
					order = 3,
					type = "toggle",
					name = L["From You"],
					desc = L["Only show auras that were cast by you."],
					get = function(key)return SV.db.UnitFrames[unitName][auraType].filterPlayer.enemy end,
					set = function(key, value)SV.db.UnitFrames[unitName][auraType].filterPlayer.enemy = value; updateFunction(MOD, unitName) end,
					disabled = function()
						return (SV.db.UnitFrames[unitName][auraType].filterAll.enemy or SV.db.UnitFrames[unitName][auraType].filterWhiteList.enemy)
					end,
				},
				filterDispellable = {
					order = 4,
					type = "toggle",
					name = L["You Can Remove"],
					desc = L["Only show auras that can be removed by you. (example: Purge, Dispel)"],
					get = function(key)return SV.db.UnitFrames[unitName][auraType].filterDispellable.enemy end,
					set = function(key, value)SV.db.UnitFrames[unitName][auraType].filterDispellable.enemy = value; updateFunction(MOD, unitName) end,
					disabled = function()
						return (SV.db.UnitFrames[unitName][auraType].filterAll.enemy or SV.db.UnitFrames[unitName][auraType].filterWhiteList.enemy)
					end,
				},
				filterInfinite = {
					order = 5,
					type = "toggle",
					name = L["No Duration"],
					desc = L["Don't display auras that have no duration."],
					get = function(key)return SV.db.UnitFrames[unitName][auraType].filterInfinite.enemy end,
					set = function(key, value)SV.db.UnitFrames[unitName][auraType].filterInfinite.enemy = value; updateFunction(MOD, unitName) end,
					disabled = function()
						return (SV.db.UnitFrames[unitName][auraType].filterAll.enemy or SV.db.UnitFrames[unitName][auraType].filterWhiteList.enemy)
					end,
				},
			},
		}

		if(SV.db.UnitFrames[unitName][auraType].filterRaid) then
			configTable.friendlyGroup.args.filterRaid = {
				order = 6,
				type = "toggle",
				name = L["Consolidated Buffs"],
				desc = L["Don't display consolidated buffs"],
				get = function(key)return SV.db.UnitFrames[unitName][auraType].filterRaid.friendly end,
				set = function(key, value)SV.db.UnitFrames[unitName][auraType].filterRaid.friendly = value; updateFunction(MOD, unitName) end,
				disabled = function()
					return (SV.db.UnitFrames[unitName][auraType].filterAll.friendly or SV.db.UnitFrames[unitName][auraType].filterWhiteList.friendly)
				end,
			};
			configTable.enemyGroup.args.filterRaid = {
				order = 6,
				type = "toggle",
				name = L["Consolidated Buffs"],
				desc = L["Don't display consolidated buffs"],
				get = function(key)return SV.db.UnitFrames[unitName][auraType].filterRaid.enemy end,
				set = function(key, value)SV.db.UnitFrames[unitName][auraType].filterRaid.enemy = value; updateFunction(MOD, unitName) end,
				disabled = function()
					return (SV.db.UnitFrames[unitName][auraType].filterAll.enemy or SV.db.UnitFrames[unitName][auraType].filterWhiteList.enemy)
				end,
			};
		end
	end
end

function SVUIOptions:SetAuraConfigGroup(isPlayer, auraType, unused, updateFunction, unitName, count)
	local groupOrder = auraType == "buffs" and 600 or 700
	local groupName = auraType == "buffs" and L["Buffs"] or L["Debuffs"]
	local attachToValue, attachToName;
	if auraType == "buffs" then
		attachToValue = "DEBUFFS"
		attachToName = L["Debuffs"]
	else
		attachToValue = "BUFFS"
		attachToName = L["Buffs"]
	end

	local configTable = {
		order = groupOrder,
		name = groupName,
		type = "group",
		get = function(key)
			return SV.db.UnitFrames[unitName][auraType][key[#key]]
		end,
		set = function(key, value)
			MOD:ChangeDBVar(value, key[#key], unitName, auraType)
			updateFunction(MOD, unitName, count)
		end,
		args = {
			enable = {
				type = "toggle",
				order = 2,
				name = L["Enable "..groupName]
			},
			attachTo1 = {
				type = "toggle",
				order = 3,
				name = L["Attach To"] .. " " .. L["Frame"],
				get = function(key)
					return SV.db.UnitFrames[unitName][auraType]["attachTo"] == "FRAME"
				end,
				set = function(key, value)
					if(not value) then
						MOD:ChangeDBVar(attachToValue, "attachTo", unitName, auraType)
					else
						MOD:ChangeDBVar("FRAME", "attachTo", unitName, auraType)
					end
					updateFunction(MOD, unitName, count)
				end,
			},
			attachTo2 = {
				type = "toggle",
				order = 4,
				name = L["Attach To"] .. " " .. attachToName,
				get = function(key)
					return SV.db.UnitFrames[unitName][auraType]["attachTo"] == attachToValue
				end,
				set = function(key, value)
					if(not value) then
						MOD:ChangeDBVar("FRAME", "attachTo", unitName, auraType)
					else
						MOD:ChangeDBVar(attachToValue, "attachTo", unitName, auraType)
					end
					updateFunction(MOD, unitName, count)
				end,
			},
			spacer1 = {
				order = 5,
				name = "",
				type = "description",
				width = "full",
			},
			anchorPoint = {
				type = "select",
				order = 6,
				name = L["Anchor Point"],
				desc = L["What point to anchor to the frame you set to attach to."],
				values = SV.PointIndexes
			},
			verticalGrowth = {
				type = "select",
				order = 7,
				name = L["Vertical Growth"],
				desc = L["The vertical direction that the auras will position themselves"],
				values = {UP = "UP", DOWN = "DOWN"}
			},
			horizontalGrowth = {
				type = "select",
				order = 8,
				name = L["Horizontal Growth"],
				desc = L["The horizontal direction that the auras will position themselves"],
				values = {LEFT = "LEFT", RIGHT = "RIGHT"}
			},
			spacer2 = {
				order = 9,
				name = "",
				type = "description",
				width = "full",
			},
			perrow = {
				type = "range",
				order = 10,
				name = L["Per Row"],
				min = 1,
				max = 20,
				step = 1
			},
			numrows = {
				type = "range",
				order = 11,
				name = L["Num Rows"],
				min = 1,
				max = 4,
				step = 1
			},
			sizeOverride = {
				type = "range",
				order = 12,
				name = L["Size Override"],
				desc = L["If not set to 0 then override the size of the aura icons (or height of aura bars)."],
				min = 0,
				max = 60,
				step = 1
			},
			barWidthOverride = {
				type = "range",
				order = 13,
				name = L["Bar Width Override"],
				desc = L["If not set to 0 then override the width of aura bars."],
				min = 0,
				max = 500,
				step = 1
			},
			spacer3 = {
				order = 14,
				name = "",
				type = "description",
				width = "full",
			},
			xOffset = {
				order = 15,
				type = "range",
				name = L["xOffset"],
				min = -60,
				max = 60,
				step = 1
			},
			yOffset = {
				order = 16,
				type = "range",
				name = L["yOffset"],
				min = -60,
				max = 60,
				step = 1
			},
			spacing = {
				order = 17,
				name = L["Aura Spacing"],
				type = "range",
				min = 0,
				max = 20,
				step = 1,
				width = "fill",
			},
			useFilter = {
				order = 18,
				type = "select",
				name = L["Custom Filter"],
				desc = L["Select a custom filter to include."],
				values = function()
					filterList = {}
					filterList[""] = NONE;
					for n in pairs(SV.db.Filters.Custom) do
						filterList[n] = n
					end
					return filterList
				end,
				get = function(key) return SV.db.UnitFrames[unitName][auraType].useFilter end,
				set = function(key, value) SV.db.UnitFrames[unitName][auraType].useFilter = value; updateFunction(MOD, unitName) end,
			},
			spacer4 = {
				order = 19,
				name = "",
				type = "description",
				width = "full",
			},
		}
	}

	local unitGlobalName = FRAME_MAP[unitName];
	if(unitGlobalName) then
		configTable.args.showAuras = {
			order = 0,
			type = "execute",
			name = L["Show Auras"],
			func = function()
				local unitframe = _G[unitGlobalName];
				if unitframe.forceShowAuras then
					unitframe.forceShowAuras = nil
				else
					unitframe.forceShowAuras = true
				end
				updateFunction(MOD, unitName, count)
			end
		}
		configTable.args.showAurasSpacer = {
			order = 1,
			name = "",
			type = "description",
			width = "full",
		}
	end

	setAuraFilteringOptions(configTable.args, unitName, auraType, updateFunction, isPlayer)

	if(unitName == 'player' or unitName == 'target' or unitName == 'focus') then
		configTable.args.barGroup = {
			order = 20,
			type = "group",
			guiInline = true,
			name = L["Bar Style "..groupName],
			args = {
				useBars = {
					type = "toggle",
					order = 1,
					name = L["Enable"]
				},
				configureButton1 = {
					order = 2,
					name = L["Coloring"],
					type = "execute", func = function() ACD:SelectGroup(SV.NameID, "UnitFrames", "commonGroup", "baseGroup", "allColorsGroup", "auraBars") end,
					disabled = function() return not SV.db.UnitFrames[unitName][auraType].useBars end,
				},
				configureButton2 = {
					order = 3,
					name = L["Coloring (Specific)"],
					type = "execute", func = function() SVUIOptions:SetToFilterConfig("AuraBars") end,
					disabled = function() return not SV.db.UnitFrames[unitName][auraType].useBars end,
				},
				spacer = {
					order = 4,
					name = "",
					type = "description",
					width = "full",
					disabled = function() return not SV.db.UnitFrames[unitName][auraType].useBars end,
				},
				sort = {
					type = "select",
					order = 5,
					name = L["Sort Method"],
					values = {["TIME_REMAINING"] = L["Time Remaining"], ["TIME_REMAINING_REVERSE"] = L["Time Remaining Reverse"], ["TIME_DURATION"] = L["Duration"], ["TIME_DURATION_REVERSE"] = L["Duration Reverse"], ["NAME"] = NAME, ["NONE"] = NONE},
					disabled = function() return not SV.db.UnitFrames[unitName][auraType].useBars end,
				},
			}
		}
	end

	return configTable
end

SV:GenerateFontOptionGroup("UnitFrame", 6, "Fonts used in unit frames.", unitFonts)

SVUIOptions.FilterOptionGroups['AuraBars'] = function(selectedSpell)
	if(not SV.db.Filters.AuraBars) then SV.db.Filters.AuraBars = {} end;

	local RESULT = {
		type = "group",
		name = 'AuraBars',
		guiInline = true,
		order = 10,
		args = {
			addSpell = {
				order = 1,
				name = L["Add Spell"] ..  " by ID",
				desc = L["Add a spell to the filter by ID (number). You can use wowhead.com to find the ID of your desired spell"],
				type = "input",
				guiInline = true,
				get = function(key) return "" end,
				set = function(key, value)
					local spellID = tonumber(value);
					if(not spellID) then
						SV:AddonMessage(L["Value must be a number"])
					elseif(not GetSpellInfo(spellID)) then
						SV:AddonMessage(L["Not valid spell id"])
					elseif not SV.db.Filters.AuraBars[value] then
						SV.db.Filters.AuraBars[value] = false
						MOD:SetUnitFrame("player")
						MOD:SetUnitFrame("target")
						MOD:SetUnitFrame("focus")
						SVUIOptions:SetFilterOptions('AuraBars', value)
					end
				end
			},
			removeSpell = {
				order = 2,
				name = L["Remove Spell"],
				desc = L["Remove a spell from the filter."],
				type = "select",
				guiInline = true,
				disabled = function()
					local EMPTY = true;
					for g in pairs(SV.db.Filters.AuraBars) do
						EMPTY = false;
					end
					return EMPTY
				end,
				values = function()
					wipe(tempFilterTable)
					for stringID,color in pairs(SV.db.Filters.AuraBars) do
						local spellID
						if(type(stringID) ~= 'number') then
							spellID = tonumber(stringID)
						else
							spellID = stringID
							stringID = tostring(stringID)
						end
						local auraName = GetSpellInfo(spellID)
						tempFilterTable[stringID] = auraName
						--print(stringID)print(auraName)print('-----')
					end
					return tempFilterTable
				end,
				get = function(key) return "" end,
				set = function(key, value)
					--print(value)
					SV.db.Filters.AuraBars[value] = nil
					MOD:SetUnitFrame("player")
					MOD:SetUnitFrame("target")
					MOD:SetUnitFrame("focus")
					SVUIOptions:SetFilterOptions('AuraBars')
				end
			},
			selectSpell = {
				name = L["Select Spell"],
				type = "select",
				order = 3,
				guiInline = true,
				get = function(key) return selectedSpell end,
				set = function(key, value)
					SVUIOptions:SetFilterOptions('AuraBars', value)
				end,
				values = function()
					wipe(tempFilterTable)
					tempFilterTable[""] = NONE;
					for stringID,color in pairs(SV.db.Filters.AuraBars) do
						local spellID
						if(type(stringID) ~= 'number') then
							spellID = tonumber(stringID)
						else
							spellID = stringID
							stringID = tostring(stringID)
						end
						local auraName = GetSpellInfo(spellID)
						tempFilterTable[stringID] = auraName
					end
					return tempFilterTable
				end
			}
		}
	};

	return RESULT;
end;

SVUIOptions.FilterOptionSpells['AuraBars'] = function(selectedSpell)
	if(not SV.db.Filters.AuraBars) then SV.db.Filters.AuraBars = {} end;
	local RESULT;
	if(selectedSpell and (SV.db.Filters.AuraBars[selectedSpell] ~= nil)) then
		RESULT = {
			type = "group",
			name = selectedSpell,
			order = 15,
			guiInline = true,
			args = {
				color = {
					name = L["Color"],
					type = "color",
					order = 1,
					get = function(key)
						local abColor = SV.db.Filters.AuraBars[selectedSpell]
						if type(abColor) == "boolean" then
							return 0, 0, 0, 1
						else
							return abColor[1], abColor[2], abColor[3], abColor[4]
						end
					end,
					set = function(key, r, g, b)
						SV.db.Filters.AuraBars[selectedSpell] = {r, g, b}
						MOD:SetUnitFrame("player")
						MOD:SetUnitFrame("target")
						MOD:SetUnitFrame("focus")
					end
				},
				removeColor = {
					type = "execute",
					order = 2,
					name = L["Restore Defaults"],
					func = function(key, value)
						SV.db.Filters.AuraBars[selectedSpell] = false;
						MOD:SetUnitFrame("player")
						MOD:SetUnitFrame("target")
						MOD:SetUnitFrame("focus")
					end
				}
			}
		};
	end

	return RESULT;
end;

SVUIOptions.FilterOptionGroups['BuffWatch'] = function(selectedSpell)
	local FILTER = SV.db.Filters.BuffWatch;

	local RESULT = {
		type = "group",
		name = 'BuffWatch',
		guiInline = true,
		order = 4,
		args = {
			addSpellID = {
				order = 1,
				name = L["Add SpellID"],
				desc = L["Add a spell to the filter."],
				type = "input",
				get = function(key)return""end,
				set = function(key, value)
					local spellID = tonumber(value);
					if(not spellID) then
						SV:AddonMessage(L["Value must be a number"])
					elseif(not GetSpellInfo(spellID)) then
						SV:AddonMessage(L["Not valid spell id"])
					else
						SetWatchedBuff(value, spellID, FILTER, true, "TOPRIGHT", DEFAULT_COLOR, false)
						UpdateBuffWatch()
						SVUIOptions:SetFilterOptions('BuffWatch', spellID)
					end
				end
			},
			removeSpellID = {
				order = 2,
				name = L["Remove SpellID"],
				desc = L["Remove a spell from the filter."],
				type = "input",
				get = function(key)return""end,
				set = function(key, value)
					local spellID = tonumber(value);
					if(not spellID) then
						SV:AddonMessage(L["Value must be a number"])
					elseif(not GetSpellInfo(spellID)) then
						SV:AddonMessage(L["Not valid spell id"])
					else
						local temp;
						for id, data in pairs(FILTER) do
							if(tonumber(id) == spellID) then
								temp = data;
								FILTER[id] = nil
							end
						end
						if temp == nil then
							SV:AddonMessage(L["Spell not found in list."])
						else
							SVUIOptions:SetFilterOptions('BuffWatch')
						end
					end
					UpdateBuffWatch("raid")
					UpdateBuffWatch("party")
					SVUIOptions:SetFilterOptions('BuffWatch')
				end
			},
			selectSpell = {
				name = L["Select Spell"],
				type = "select",
				order = 3,
				values = function()
					wipe(tempFilterTable)
					for id, watchData in pairs(FILTER) do
						local spellID = tonumber(id)
						local name = GetSpellInfo(spellID)
						if(name) then
							tempFilterTable[spellID] = name
						end
					end
					return tempFilterTable
				end,
				get = function(key) return selectedSpell end,
				set = function(key, value) SVUIOptions:SetFilterOptions('BuffWatch', value) end
			}
		}
	}
	return RESULT;
end;

SVUIOptions.FilterOptionSpells['BuffWatch'] = function(selectedSpell)
	local RESULT;
	local FILTER = SV.db.Filters.BuffWatch;

	if(selectedSpell) then
		local registeredSpell;

		for id, watchData in pairs(FILTER)do
			if(tonumber(id) == selectedSpell) then
				registeredSpell = id
			end
		end

		local currentSpell = GetSpellInfo(selectedSpell)

		if(currentSpell and registeredSpell) then

			RESULT = {
				name = currentSpell.." (Spell ID#: "..selectedSpell..")",
				type = "group",
				guiInline = true,
				get = function(key) return FILTER[registeredSpell][key[#key]] end,
				set = function(key, value)
					SV.db.Filters.BuffWatch[registeredSpell][key[#key]] = value;
					UpdateBuffWatch();
				end,
				order = 5,
				args = {
					enable = {
						name = L["Enable"],
						width = 'full',
						order = 0,
						type = "toggle"
					},
					displayText = {
						name = L["Display Text"],
						width = 'full',
						type = "toggle",
						order = 1,
					},
					anyUnit = {
						name = L["Show Aura From Other Players"],
						width = 'full',
						order = 2,
						type = "toggle"
					},
					onlyShowMissing = {
						name = L["Show When Not Active"],
						width = 'full',
						order = 3,
						type = "toggle",
						disabled = function() return FILTER[registeredSpell].style == "text" end
					},
					point = {
						name = L["Anchor Point"],
						order = 4,
						type = "select",
						values = POSITION_SELECT
					},
					style = {
						name = L["Style"],
						order = 5,
						type = "select",
						values = STYLE_SELECT
					},
					color = {
						name = L["Color"],
						type = "color",
						order = 6,
						get = function(key)
							local abColor = FILTER[registeredSpell][key[#key]]
							return abColor.r,  abColor.g,  abColor.b,  abColor.a
						end,
						set = function(key, r, g, b)
							local abColor = FILTER[registeredSpell][key[#key]]
							abColor.r,  abColor.g,  abColor.b = r, g, b;
							UpdateBuffWatch()
						end
					},
					textColor = {
						name = L["Text Color"],
						type = "color",
						order = 7,
						get = function(key)
							local abColor = FILTER[registeredSpell][key[#key]]
							if abColor then
								return abColor.r,  abColor.g,  abColor.b,  abColor.a
							else
								return 1, 1, 1, 1
							end
						end,
						set = function(key, r, g, b)
							FILTER[registeredSpell][key[#key]] = FILTER[registeredSpell][key[#key]] or {}
							local abColor = FILTER[registeredSpell][key[#key]]
							abColor.r,  abColor.g,  abColor.b = r, g, b;
							UpdateBuffWatch()
						end
					},
					textThreshold = {
						name = L["Text Threshold"],
						desc = L["At what point should the text be displayed. Set to -1 to disable."],
						type = "range",
						order = 8,
						width = 'full',
						min = -1,
						max = 60,
						step = 1
					},
					xOffset = {order = 9, type = "range", width = 'full', name = L["xOffset"], min = -75, max = 75, step = 1},
					yOffset = {order = 10, type = "range", width = 'full', name = L["yOffset"], min = -75, max = 75, step = 1},
				}
			}
		end
	end
	return RESULT;
end;

SVUIOptions.FilterOptionGroups['PetBuffWatch'] = function(selectedSpell)
	local FILTER = SV.db.Filters.PetBuffWatch;
	local RESULT = {
		type = "group",
		name = 'PetBuffWatch',
		guiInline = true,
		order = 4,
		args = {
			addSpellID = {
				order = 1,
				name = L["Add SpellID"],
				desc = L["Add a spell to the filter."],
				type = "input",
				get = function(key) return "" end,
				set = function(key, value)
					local spellID = tonumber(value);
					if(not spellID) then
						SV:AddonMessage(L["Value must be a number"])
					elseif(not GetSpellInfo(spellID)) then
						SV:AddonMessage(L["Not valid spell id"])
					else
						SetWatchedBuff(value, spellID, FILTER, true, "TOPRIGHT", DEFAULT_COLOR, true)
						UpdatePetBuffWatch()
						SVUIOptions:SetFilterOptions('PetBuffWatch', spellID)
					end
				end
			},
			removeSpellID = {
				order = 2,
				name = L["Remove SpellID"],
				desc = L["Remove a spell from the filter."],
				type = "input",
				get = function(key) return "" end,
				set = function(key, value)
					local spellID = tonumber(value);
					if(not spellID) then
						SV:AddonMessage(L["Value must be a number"])
					elseif(not GetSpellInfo(spellID)) then
						SV:AddonMessage(L["Not valid spell id"])
					else
						local success = false;
						for id, data in pairs(FILTER) do
							if(tonumber(id) == spellID) then
								success = true;
								data.enable = false;
							end
						end
						if not success then
							SV:AddonMessage(L["Spell not found in list."])
						else
							SVUIOptions:SetFilterOptions()
						end
					end
					UpdatePetBuffWatch()
					SVUIOptions:SetFilterOptions('PetBuffWatch', value)
				end
			},
			selectSpell = {
				name = L["Select Spell"],
				type = "select",
				order = 3,
				values = function()
					wipe(tempFilterTable)
					for id, watchData in pairs(FILTER) do
						local spellID = tonumber(id)
						local name = GetSpellInfo(spellID)
						if(name) then
							tempFilterTable[spellID] = name
						end
					end
					return tempFilterTable
				end,
				get = function(key) return selectedSpell end,
				set = function(key, value) SVUIOptions:SetFilterOptions('PetBuffWatch', value) end
			}
		}
	};

	return RESULT;
end;

SVUIOptions.FilterOptionSpells['PetBuffWatch'] = function(selectedSpell)
	local RESULT;
	local FILTER = SV.db.Filters.PetBuffWatch;

	if(selectedSpell) then
		local registeredSpell;

		for id, watchData in pairs(FILTER)do
			if(tonumber(id) == selectedSpell) then
				registeredSpell = id
			end
		end

		local currentSpell = GetSpellInfo(selectedSpell)

		if(currentSpell and registeredSpell) then

			RESULT = {
				name = currentSpell.." ("..selectedSpell..")",
				type = "group",
				get = function(key)return FILTER[registeredSpell][key[#key]] end,
				set = function(key, value)
					FILTER[registeredSpell][key[#key]] = value;
					UpdatePetBuffWatch()
				end,
				order = 5,
				guiInline = true,
				args = {
					enable = {
						name = L["Enable"],
						order = 0,
						type = "toggle"
					},
					point = {
						name = L["Anchor Point"],
						order = 1,
						type = "select",
						values = POSITION_SELECT
					},
					xOffset = {order = 2, type = "range", name = L["xOffset"], min = -75, max = 75, step = 1},
					yOffset = {order = 2, type = "range", name = L["yOffset"], min = -75, max = 75, step = 1},
					style = {
						name = L["Style"],
						order = 3,
						type = "select",
						values = STYLE_SELECT

					},
					color = {
						name = L["Color"],
						type = "color",
						order = 4,
						get = function(key)
							local abColor = FILTER[registeredSpell][key[#key]]
							return abColor.r,  abColor.g,  abColor.b,  abColor.a
						end,
						set = function(key, r, g, b)
							local abColor = FILTER[registeredSpell][key[#key]]
							abColor.r,  abColor.g,  abColor.b = r, g, b;
							UpdatePetBuffWatch()
						end
					},
					displayText = {
						name = L["Display Text"],
						type = "toggle",
						order = 5
					},
					textColor = {
						name = L["Text Color"],
						type = "color",
						order = 6,
						get = function(key)
							local abColor = FILTER[registeredSpell][key[#key]]
							if abColor then
								return abColor.r,abColor.g,abColor.b,abColor.a
							else
								return 1,1,1,1
							end
						end,
						set = function(key, r, g, b)
							local abColor = FILTER[registeredSpell][key[#key]]
							abColor.r,abColor.g,abColor.b = r, g, b;
							UpdatePetBuffWatch()
						end
					},
					textThreshold = {
						name = L["Text Threshold"],
						desc = L["At what point should the text be displayed. Set to -1 to disable."],
						type = "range",
						order = 6,
						min = -1,
						max = 60,
						step = 1
					},
					anyUnit = {
						name = L["Show Aura From Other Players"],
						order = 7,
						type = "toggle"
					},
					onlyShowMissing = {
						name = L["Show When Not Active"],
						order = 8,
						type = "toggle",
						disabled = function() return FILTER[registeredSpell].style == "text" end
					}
				}
			}
		end
	end

	return RESULT;
end;

local function GetPowerColorOptions()
	local args = {};
	local count = 1;
	for power, color in next, SV.media.extended.unitframes.power do
		args[power] = {
			order = count,
			name = power,
			type = "color",
			get = function(key)
				local color = SV.media.extended.unitframes.power[power]
				return color[1],color[2],color[3]
			end,
			set = function(key, rValue, gValue, bValue)
				SV.media.extended.unitframes.power[power] = {rValue, gValue, bValue}
				MOD:RefreshAllUnitMedia()
			end,
		};
		count = count + 1;
	end
	return args;
end;

SV.Options.args[Schema] = {
	type = "group",
	name = Schema,
	childGroups = "tab",
	get = function(key)
		return SV.db[Schema][key[#key]]
	end,
	set = function(key, value)
		MOD:ChangeDBVar(value, key[#key]);
		MOD:RefreshUnitFrames();
	end,
	args = {
		commonGroup = {
			order = 1,
			type = 'group',
			name = '',
			childGroups = "tree",
			args = {
				baseGroup = {
					order = 1,
					type = "group",
					name = L["General"],
					args = {
						commonGroup = {
							order = 1,
							type = "group",
							guiInline = true,
							name = L["General"],
							args = {
								themed = {
									order = 1,
									name = L["Elite Bursts"],
									desc = L["Toggle the styled starbursts around the target frame for elites and rares"],
									type = "toggle"
								},
								disableBlizzard = {
									order = 2,
									name = L["Disable Blizzard"],
									desc = L["Disables the blizzard party/raid frames."],
									type = "toggle",
									get = function(key)
										return SV.db[Schema].disableBlizzard
									end,
									set = function(key, value)
										MOD:ChangeDBVar(value, "disableBlizzard");
										SV:StaticPopup_Show("RL_CLIENT")
									end
								},
								fastClickTarget = {
									order = 3,
									name = L["Fast Clicks"],
									desc = L["Immediate mouse-click-targeting"],
									type = "toggle"
								},
								debuffHighlighting = {
									order = 4,
									name = L["Debuff Highlight"],
									desc = L["Color the unit if there is a debuff that can be dispelled by your class."],
									type = "toggle"
								},
								xrayFocus = {
									order = 5,
									name = L["X-Ray Specs"],
									desc = L["Use handy graphics to focus the current target, or clear the current focus"],
									type = "toggle"
								},
								-- JV - 20160919 : Resolve mechanic is now gone as of Legion.
								-- resolveBar = {
								-- 	order = 6,
								-- 	name = L["Resolve Meter"],
								-- 	desc = L["A convenient meter for tanks to display their current resolve."],
								-- 	type = "toggle",
								-- 	set = function(key, value)
								-- 		MOD:ChangeDBVar(value, "resolveBar");
								-- 		SV:StaticPopup_Show("RL_CLIENT")
								-- 	end
								-- },
								infoBackgrounds = {
									order = 7,
									name = L["Info Backgrounds"],
									desc = L["Show or hide the gradient under each of the four main unitframes. (Player, Target, Pet, Target of Target)"],
									type = "toggle"
								},
								spacer99 = {
									order = 8,
									name = "",
									type = "description",
									width = "full",
								},
								OORAlpha = {
									order = 9,
									name = L["Range Fading"],
									desc = L["The transparency of units that are out of range."],
									type = "range",
									min = 0,
									max = 1,
									step = 0.01,
									set = function(key, value)
										MOD:ChangeDBVar(value, key[#key]);
									end
								},
								groupOORAlpha = {
									order = 10,
									name = L["Group Range Fading"],
									desc = L["The transparency of group units that are out of range."],
									type = "range",
									min = 0,
									max = 1,
									step = 0.01,
									set = function(key, value)
										MOD:ChangeDBVar(value, key[#key]);
									end
								},
							}
						},
						backgroundGroup = {
							order = 2,
							type = "group",
							guiInline = true,
							name = "Unit Backgrounds (3D Portraits Only)",
							get = function(key)
								return SV.media.shared.background[key[#key]].file
							end,
							set = function(key, value)
								SV.media.shared.background[key[#key]].file = value
								SV:RefreshEverything(true)
							end,
							args = {
								unitlarge = {
									type = "select",
									dialogControl = "LSM30_Background",
									order = 2,
									name = "Unit Background",
									values = AceVillainWidgets.background,
								},
								unitsmall = {
									type = "select",
									dialogControl = "LSM30_Background",
									order = 3,
									name = "Small Unit Background",
									values = AceVillainWidgets.background,
								}
							}
						},
						barGroup = {
							order = 3,
							type = "group",
							guiInline = true,
							name = L["Bars"],
							get = function(key)
								return SV.db[Schema][key[#key]]
							end,
							set = function(key, value)
								MOD:ChangeDBVar(value, key[#key]);
								MOD:RefreshAllUnitMedia()
							end,
							args = {
								smoothbars = {
									type = "toggle",
									order = 1,
									name = L["Smooth Bars"],
									desc = L["Bars will transition smoothly."]
								},
								statusbar = {
									type = "select",
									dialogControl = "LSM30_Statusbar",
									order = 2,
									name = L["StatusBar Texture"],
									desc = L["Main statusbar texture."],
									values = AceVillainWidgets.statusbar
								},
								auraBarStatusbar = {
									type = "select",
									dialogControl = "LSM30_Statusbar",
									order = 3,
									name = L["AuraBar Texture"],
									desc = L["Main statusbar texture."],
									values = AceVillainWidgets.statusbar
								},
							}
						},
						fontGroup = {
							order = 4,
							type = "group",
							guiInline = true,
							name = L["Fonts"],
							args = {
								fontConfigButton = {
									order = 1,
									name = L["Set UnitFrame Fonts"],
									type = "execute", func = function() SVUIOptions:SetToFontConfig("UnitFrame") end
								},
							}
						},
						allColorsGroup = {
							order = 5,
							type = "group",
							guiInline = true,
							name = L["Colors"],
							args = {
								healthGroup = {
									order = 9,
									type = "group", guiInline = true,
									name = HEALTH,
									args = {
										forceHealthColor = {
											order = 1,
											type = "toggle",
											name = L["Overlay Health Color"],
											desc = L["Allow custom health colors when using portrait overlays."],
											get = function(key)
												return SV.db[Schema][key[#key]]
											end,
											set = function(key, value)
												MOD:ChangeDBVar(value, key[#key]);
												MOD:RefreshUnitFrames()
											end
										},
										overlayAnimation = {
											order = 2,
											type = "toggle",
											name = L["Overlay Animations"],
											desc = L["Toggle health animations on portrait overlays."],
											get = function(key)
												return SV.db[Schema][key[#key]]
											end,
											set = function(key, value)
												MOD:ChangeDBVar(value, key[#key]);
												MOD:RefreshUnitFrames()
											end
										},
										health = {
											order = 3,
											type = "color",
											name = L["Health"],
											get = function(key)
												local color = SV.media.extended.unitframes.health
												return color[1],color[2],color[3]
											end,
											set = function(key, rValue, gValue, bValue)
												SV.media.extended.unitframes.health = {rValue, gValue, bValue}
												MOD:RefreshAllUnitMedia()
											end,
										},
										healthBackdrop = {
											order = 4,
											type = "color",
											name = L["Health Backdrop"],
											get = function(key)
												local color = SV.media.extended.unitframes.healthBackdrop
												return color[1],color[2],color[3]
											end,
											set = function(key, rValue, gValue, bValue)
												SV.media.extended.unitframes.healthBackdrop = {rValue, gValue, bValue}
												MOD:RefreshAllUnitMedia()
											end,
										},
										tapped = {
											order = 5,
											type = "color",
											name = L["Tapped"],
											get = function(key)
												local color = SV.media.extended.unitframes.tapped
												return color[1],color[2],color[3]
											end,
											set = function(key, rValue, gValue, bValue)
												SV.media.extended.unitframes.tapped = {rValue, gValue, bValue}
												MOD:RefreshAllUnitMedia()
											end,
										},
										disconnected = {
											order = 6,
											type = "color",
											name = L["Disconnected"],
											get = function(key)
												local color = SV.media.extended.unitframes.disconnected
												return color[1],color[2],color[3]
											end,
											set = function(key, rValue, gValue, bValue)
												SV.media.extended.unitframes.disconnected = {rValue, gValue, bValue}
												MOD:RefreshAllUnitMedia()
											end,
										}
									}
								},
								powerGroup = {
									order = 10,
									type = "group",
									guiInline = true,
									name = L["Powers"],
									args = GetPowerColorOptions()
								},
								castBars = {
									order = 11,
									type = "group",
									guiInline = true,
									name = L["Castbar"],
									args = {
										castClassColor = {
											order = 0,
											type = "toggle",
											name = L["Class Castbars"],
											desc = L["Color castbars by the class or reaction type of the unit."],
											get = function(key)
												return SV.db[Schema][key[#key]]
											end,
											set = function(key, value)
												MOD:ChangeDBVar(value, key[#key]);
												MOD:RefreshUnitFrames()
											end
										},
										casting = {
											order = 3,
											name = L["Interruptable"],
											type = "color",
											get = function(key)
												local color = SV.media.extended.unitframes.casting
												return color[1],color[2],color[3]
											end,
											set = function(key, rValue, gValue, bValue)
												SV.media.extended.unitframes.casting = {rValue, gValue, bValue}
												MOD:RefreshAllUnitMedia()
											end,
										},
										spark = {
											order = 4,
											name = "Spark Color",
											type = "color",
											get = function(key)
												local color = SV.media.extended.unitframes.spark
												return color[1],color[2],color[3]
											end,
											set = function(key, rValue, gValue, bValue)
												SV.media.extended.unitframes.spark = {rValue, gValue, bValue}
												MOD:RefreshAllUnitMedia()
											end,
										},
										interrupt = {
											order = 5,
											name = L["Non-Interruptable"],
											type = "color",
											get = function(key)
												local color = SV.media.extended.unitframes.interrupt
												return color[1],color[2],color[3]
											end,
											set = function(key, rValue, gValue, bValue)
												SV.media.extended.unitframes.interrupt = {rValue, gValue, bValue}
												MOD:RefreshAllUnitMedia()
											end,
										}
									}
								},
								auraBars = {
									order = 11,
									type = "group",
									guiInline = true,
									name = L["Aura Bars"],
									args = {
										auraBarByType = {
											order = 1,
											name = L["By Type"],
											desc = L["Color aurabar debuffs by type."],
											type = "toggle",
											get = function(key)
												return SV.db[Schema][key[#key]]
											end,
											set = function(key, value)
												MOD:ChangeDBVar(value, key[#key]);
												MOD:RefreshUnitFrames()
											end
										},
										auraBarShield = {
											order = 2,
											name = L["Color Shield Buffs"],
											desc = L["Color all buffs that reduce incoming damage."],
											type = "toggle",
											get = function(key)
												return SV.db[Schema][key[#key]]
											end,
											set = function(key, value)
												MOD:ChangeDBVar(value, key[#key]);
												MOD:RefreshUnitFrames()
											end
										},
										buff_bars = {
											order = 10,
											name = L["Buffs"],
											type = "color",
											get = function(key)
												local color = SV.media.extended.unitframes.buff_bars
												return color[1],color[2],color[3]
											end,
											set = function(key, rValue, gValue, bValue)
												SV.media.extended.unitframes.buff_bars = {rValue, gValue, bValue}
												MOD:RefreshAllUnitMedia()
											end,
										},
										debuff_bars = {
											order = 11,
											name = L["Debuffs"],
											type = "color",
											get = function(key)
												local color = SV.media.extended.unitframes.debuff_bars
												return color[1],color[2],color[3]
											end,
											set = function(key, rValue, gValue, bValue)
												SV.media.extended.unitframes.debuff_bars = {rValue, gValue, bValue}
												MOD:RefreshAllUnitMedia()
											end,
										},
										shield_bars = {
											order = 12,
											name = L["Shield Buffs Color"],
											type = "color",
											get = function(key)
												local color = SV.media.extended.unitframes.shield_bars
												return color[1],color[2],color[3]
											end,
											set = function(key, rValue, gValue, bValue)
												SV.media.extended.unitframes.shield_bars = {rValue, gValue, bValue}
												MOD:RefreshAllUnitMedia()
											end,
										}
									}
								},
								predict = {
									order = 12,
									name = L["Heal Prediction"],
									type = "group",
									args = {
										personal = {
											order = 1,
											name = L["Personal"],
											type = "color",
											hasAlpha = true,
											get = function(key)
												local color = SV.media.extended.unitframes.predict["personal"]
												return color[1],color[2],color[3]
											end,
											set = function(key, rValue, gValue, bValue)
												SV.media.extended.unitframes.predict["personal"] = {rValue, gValue, bValue}
												MOD:RefreshUnitFrames()
											end,
										},
										others = {
											order = 2,
											name = L["Others"],
											type = "color",
											hasAlpha = true,
											get = function(key)
												local color = SV.media.extended.unitframes.predict["others"]
												return color[1],color[2],color[3]
											end,
											set = function(key, rValue, gValue, bValue)
												SV.media.extended.unitframes.predict["others"] = {rValue, gValue, bValue}
												MOD:RefreshUnitFrames()
											end,
										},
										absorbs = {
											order = 2,
											name = L["Absorbs"],
											type = "color",
											hasAlpha = true,
											get = function(key)
												local color = SV.media.extended.unitframes.predict["absorbs"]
												return color[1],color[2],color[3]
											end,
											set = function(key, rValue, gValue, bValue)
												SV.media.extended.unitframes.predict["absorbs"] = {rValue, gValue, bValue}
												MOD:RefreshUnitFrames()
											end,
										}
									}
								}
							}
						}
					}
				},
				player = {
					name = L['Player'],
					type = 'group',
					order = 3,
					childGroups = "select",
					get = function(l)return SV.db.UnitFrames['player'][l[#l]]end,
					set = function(l,m)MOD:ChangeDBVar(m, l[#l], "player");MOD:SetUnitFrame('player')end,
					args = {
						enable = {
							type = 'toggle',
							order = 1,
							name = L['Enable']
						},
						resetSettings = {
							type = 'execute',
							order = 2,
							name = L['Restore Defaults'],
							func = function(l,m)
								MOD:ResetUnitOptions('player')
								SV:ResetAnchors('Player Frame')
							end
						},
						spacer1 = {
							order = 3,
							name = "",
							type = "description",
							width = "full",
						},
						spacer2 = {
							order = 4,
							name = "",
							type = "description",
							width = "full",
						},
						commonGroup = {
							order = 5,
							type = 'group',
							name = L['General Settings'],
							args = {
								baseGroup = {
									order = 1,
									type = "group",
									guiInline = true,
									name = L["Base Settings"],
									args = {
										combatfade = {
											order = 1,
											name = L["Combat Fade"],
											desc = L["Fade the unitframe when out of combat, not casting, no target exists."],
											type = "toggle",
											set = function(l, m)
												MOD:ChangeDBVar(m, l[#l], "player");
												MOD:SetUnitFrame("player")
												if m == true then
													SVUI_Pet:SetParent(SVUI_Player)
												else
													SVUI_Pet:SetParent(SVUI_UnitFrameParent)
												end
											end
										},
										predict = {
											order = 2,
											name = L["Heal Prediction"],
											desc = L["Show a incomming heal prediction bar on the unitframe. Also display a slightly different colored bar for incoming overheals."],
											type = "toggle"
										},
										threatEnabled = {
											type = "toggle",
											order = 3,
											name = L["Show Threat"]
										},
										playerExpBar = {
											order = 4,
											name = "Playerframe Experience Bar",
											desc = "Show player experience on power bar mouseover",
											type = "toggle",
											set = function(l, m)MOD:ChangeDBVar(m, l[#l], "player");SV:StaticPopup_Show("RL_CLIENT")end
										},
										playerRepBar = {
											order = 5,
											name = "Playerframe Reputation Bar",
											desc = "Show player reputations on power bar mouseover",
											type = "toggle",
											set = function(l, m)MOD:ChangeDBVar(m, l[#l], "player");SV:StaticPopup_Show("RL_CLIENT")end
										}
									}
								},
								sizeGroup = {
									order = 2,
									guiInline = true,
									type = "group",
									name = L["Size Settings"],
									args = {
										width = {
											order = 1,
											name = L["Width"],
											type = "range",
											width = "full",
											min = 50,
											max = 500,
											step = 1,
											set = function(l, m)
												if SV.db.UnitFrames["player"].castbar.width == SV.db.UnitFrames["player"][l[#l]] then
													SV.db.UnitFrames["player"].castbar.width = m
												end
												MOD:ChangeDBVar(m, l[#l], "player");
												MOD:SetUnitFrame("player")
											end
										},
										height = {
											order = 2,
											name = L["Height"],
											type = "range",
											width = "full",
											min = 10,
											max = 250,
											step = 1
										},
									}
								},
								pvpGroup = {
									order = 3,
									type = "group",
									guiInline = true,
									name = PVP,
									get = function(l)return SV.db.UnitFrames["player"]["pvp"][l[#l]]end,
									set = function(l, m)MOD:ChangeDBVar(m, l[#l], "player", "pvp");MOD:SetUnitFrame("player")end,
									args = {
										position = {
											type = "select",
											order = 2,
											name = L["Position"],
											values = {
												TOPLEFT = "TOPLEFT",
												LEFT = "LEFT",
												BOTTOMLEFT = "BOTTOMLEFT",
												RIGHT = "RIGHT",
												TOPRIGHT = "TOPRIGHT",
												BOTTOMRIGHT = "BOTTOMRIGHT",
												CENTER = "CENTER",
												TOP = "TOP",
												BOTTOM = "BOTTOM"
											}
										},
										tags = {
											order = 100,
											name = L["Text Format"],
											type = "input",
											width = "full",
											desc = L["TEXT_FORMAT_DESC"]
										}
									}
								}
							}
						},
						misc = SVUIOptions:SetMiscConfigGroup(false, MOD.SetUnitFrame, "player"),
						health = SVUIOptions:SetHealthConfigGroup(false, MOD.SetUnitFrame, "player"),
						power = SVUIOptions:SetPowerConfigGroup(true, MOD.SetUnitFrame, "player"),
						name = SVUIOptions:SetNameConfigGroup(MOD.SetUnitFrame, "player"),
						portrait = SVUIOptions:SetPortraitConfigGroup(MOD.SetUnitFrame, "player"),
						buffs = SVUIOptions:SetAuraConfigGroup(true, "buffs", false, MOD.SetUnitFrame, "player"),
						debuffs = SVUIOptions:SetAuraConfigGroup(true, "debuffs", false, MOD.SetUnitFrame, "player"),
						castbar = SVUIOptions:SetCastbarConfigGroup(MOD.SetUnitFrame, "player"),
						icons = SVUIOptions:SetIconConfigGroup(MOD.SetUnitFrame, "player"),
						classbar = {
							order = 1000,
							type = "group",
							name = L["Classbar"],
							get = function(l)return SV.db.UnitFrames["player"]["classbar"][l[#l]]end,
							set = function(l, m)MOD:ChangeDBVar(m, l[#l], "player", "classbar");MOD:SetUnitFrame("player")end,
							args = {
								enable = {
									type = "toggle",
									order = 1,
									name = L["Classbar Enabled"]
								},
								detachFromFrame = {
									type = "toggle",
									order = 2,
									name = L["Detach From Frame"]
								},
								height = {
									type = "range",
									order = 4,
									name = L["Classbar Height (Size)"],
									min = 15,
									max = 45,
									step = 1
								},
								altRunes = {
									type = "toggle",
									order = 5,
									width = 'full',
									name = L["Use Alternate Styled Death Knight Runes"],
									disabled = function() return playerClass ~= 'DEATHKNIGHT' end
								},
								altComboPoints = {
									type = "toggle",
									order = 6,
									width = 'full',
									name = L["Use Alternate Styled Rogue Combo Points"],
									disabled = function() return playerClass ~= 'ROGUE' end
								},
								enableStagger = {
									type = "toggle",
									order = 7,
									width = 'full',
									name = L["Use Monk's Stagger Bar"],
									disabled = function() return playerClass ~= 'MONK' end
								},
								enableAltMana = {
									type = "toggle",
									order = 8,
									width = 'full',
									name = L["Use Druid Alt-Mana Bar"],
									disabled = function() return playerClass ~= 'DRUID' end
								},
								enableCat = {
									type = "toggle",
									order = 9,
									width = 'full',
									name = L["Use Druid Cat-Form Combo Points"],
									disabled = function() return playerClass ~= 'DRUID' end
								},
								enableChicken = {
									type = "toggle",
									order = 10,
									width = 'full',
									name = L["Use Druid Eclipse Bar"],
									disabled = function() return playerClass ~= 'DRUID' end
								},
							}
						}
					}
				},
				pet = {
					name = L["Pet"],
					type = "group",
					order = 4,
					childGroups = "select",
					get = function(l)return SV.db.UnitFrames["pet"][l[#l]]end,
					set = function(l, m)MOD:ChangeDBVar(m, l[#l], "pet");MOD:SetUnitFrame("pet")end,
					args = {
						enable = {type = "toggle", order = 1, name = L["Enable"]},
						resetSettings = {type = "execute", order = 2, name = L["Restore Defaults"], func = function(l, m)MOD:ResetUnitOptions("pet")SV:ResetAnchors("Pet Frame")end},
						spacer1 = {
							order = 3,
							name = "",
							type = "description",
							width = "full",
						},
						spacer2 = {
							order = 4,
							name = "",
							type = "description",
							width = "full",
						},
						commonGroup = {
							order = 5,
							type = "group",
							name = L["General Settings"],
							args = {
								showAuras = {
									order = 1,
									type = "execute",
									name = L["Show Auras"],
									func = function()local U = SVUI_Pet;if U.forceShowAuras then U.forceShowAuras = nil else U.forceShowAuras = true end MOD:SetUnitFrame("pet")end
								},
								miscGroup = {
									order = 2,
									type = "group",
									guiInline = true,
									name = L["Base Settings"],
									args = {
										rangeCheck = {
											order = 2,
											name = L["Range Check"],
											desc = L["Check if you are in range to cast spells on this specific unit."],
											type = "toggle"
										},
										predict = {
											order = 3,
											name = L["Heal Prediction"],
											desc = L["Show a incomming heal prediction bar on the unitframe. Also display a slightly different colored bar for incoming overheals."],
											type = "toggle"
										},
										hideonnpc = {
											type = "toggle",
											order = 4,
											name = L["Text Toggle On NPC"],
											desc = L["Power text will be hidden on NPC targets, in addition the name text will be repositioned to the power texts anchor point."],
											get = function(l)return SV.db.UnitFrames["pet"]["power"].hideonnpc end,
											set = function(l, m)SV.db.UnitFrames["pet"]["power"].hideonnpc = m;MOD:SetUnitFrame("pet")end
										},
										threatEnabled = {
											type = "toggle",
											order = 5,
											name = L["Show Threat"]
										},
									}
								},
								scaleGroup = {
									order = 6,
									type = "group",
									guiInline = true,
									name = L["Frame Size"],
									args = {
										width = {order = 1, name = L["Width"], width = "full", type = "range", min = 50, max = 500, step = 1},
										height = {order = 2, name = L["Height"], width = "full", type = "range", min = 10, max = 250, step = 1},
									}
								},
								watchGroup = {
									order = 8,
									type = "group",
									guiInline = true,
									name = L["Aura Watch"],
									get = function(l)return SV.db.UnitFrames["pet"]["auraWatch"][l[#l]]end,
									set = function(l, m)MOD:ChangeDBVar(m, l[#l], "pet", "auraWatch");MOD:SetUnitFrame("pet")end,
									args = {
										enable = {
											type = "toggle",
											name = L["Enable"],
											order = 1
										},
										size = {
											type = "range",
											name = L["Size"],
											desc = L["Size of the indicator icon."],
											order = 2,
											min = 4,
											max = 15,
											step = 1
										}
									}
								},
							},
						},
						misc = SVUIOptions:SetMiscConfigGroup(false, MOD.SetUnitFrame, "pet"),
						health = SVUIOptions:SetHealthConfigGroup(false, MOD.SetUnitFrame, "pet"),
						power = SVUIOptions:SetPowerConfigGroup(false, MOD.SetUnitFrame, "pet"),
						portrait = SVUIOptions:SetPortraitConfigGroup(MOD.SetUnitFrame, "pet"),
						name = SVUIOptions:SetNameConfigGroup(MOD.SetUnitFrame, "pet"),
						buffs = SVUIOptions:SetAuraConfigGroup(true, "buffs", false, MOD.SetUnitFrame, "pet"),
						debuffs = SVUIOptions:SetAuraConfigGroup(true, "debuffs", false, MOD.SetUnitFrame, "pet")
					}
				},
				pettarget = {
					name = L["Pet Target"],
					type = "group",
					order = 5,
					childGroups = "select",
					get = function(l)return SV.db.UnitFrames["pettarget"][l[#l]]end,
					set = function(l, m)MOD:ChangeDBVar(m, l[#l], "pettarget");MOD:SetUnitFrame("pettarget")end,
					args = {
						enable = {type = "toggle", order = 1, name = L["Enable"]},
						resetSettings = {type = "execute", order = 2, name = L["Restore Defaults"], func = function(l, m)MOD:ResetUnitOptions("pettarget")SV:ResetAnchors("PetTarget Frame")end},
						spacer1 = {
							order = 3,
							name = "",
							type = "description",
							width = "full",
						},
						spacer2 = {
							order = 4,
							name = "",
							type = "description",
							width = "full",
						},
						commonGroup = {
							order = 5,
							type = "group",
							name = L["General Settings"],
							args = {
								showAuras = {
									order = 1,
									type = "execute",
									name = L["Show Auras"],
									func = function()local U = SVUI_PetTarget;if U.forceShowAuras then U.forceShowAuras = nil else U.forceShowAuras = true end MOD:SetUnitFrame("pettarget")end
								},
								miscGroup = {
									order = 2,
									type = "group",
									guiInline = true,
									name = L["Base Settings"],
									args = {
										rangeCheck = {
											order = 2,
											name = L["Range Check"],
											desc = L["Check if you are in range to cast spells on this specific unit."],
											type = "toggle"
										},
										hideonnpc = {
											type = "toggle",
											order = 4,
											name = L["Text Toggle On NPC"],
											desc = L["Power text will be hidden on NPC targets, in addition the name text will be repositioned to the power texts anchor point."],
											get = function(l)return SV.db.UnitFrames["pettarget"]["power"].hideonnpc end,
											set = function(l, m)SV.db.UnitFrames["pettarget"]["power"].hideonnpc = m;MOD:SetUnitFrame("pettarget")end
										},
										threatEnabled = {
											type = "toggle",
											order = 5,
											name = L["Show Threat"]
										},
									}
								},
								scaleGroup = {
									order = 3,
									type = "group",
									guiInline = true,
									name = L["Frame Size"],
									args = {
										width = {order = 1, name = L["Width"], width = "full", type = "range", min = 50, max = 500, step = 1},
										height = {order = 2, name = L["Height"], width = "full", type = "range", min = 10, max = 250, step = 1},
									}
								},
							},
						},
						misc = SVUIOptions:SetMiscConfigGroup(false, MOD.SetUnitFrame, "pettarget"),
						health = SVUIOptions:SetHealthConfigGroup(false, MOD.SetUnitFrame, "pettarget"),
						power = SVUIOptions:SetPowerConfigGroup(false, MOD.SetUnitFrame, "pettarget"),
						name = SVUIOptions:SetNameConfigGroup(MOD.SetUnitFrame, "pettarget"),
						buffs = SVUIOptions:SetAuraConfigGroup(false, "buffs", false, MOD.SetUnitFrame, "pettarget"),
						debuffs = SVUIOptions:SetAuraConfigGroup(false, "debuffs", false, MOD.SetUnitFrame, "pettarget")
					}
				},
				target = {
					name = L['Target'],
					type = 'group',
					order = 6,
					childGroups = "select",
					get=function(l)return SV.db.UnitFrames['target'][l[#l]]end,
					set=function(l,m)MOD:ChangeDBVar(m, l[#l], "target");MOD:SetUnitFrame('target')end,
					args={
						enable={type='toggle',order=1,name=L['Enable']},
						resetSettings={type='execute',order=2,name=L['Restore Defaults'],func=function(l,m)MOD:ResetUnitOptions('target')SV:ResetAnchors('Target Frame')end},
						spacer1 = {
							order = 3,
							name = "",
							type = "description",
							width = "full",
						},
						spacer2 = {
							order = 4,
							name = "",
							type = "description",
							width = "full",
						},
						commonGroup = {
							order = 5,
							type = 'group',
							name = L['General Settings'],
							args = {
								baseGroup = {
									order = 1,
									type = "group",
									guiInline = true,
									name = L["Base Settings"],
									args = {
										showAuras = {
											order = 1,
											type = "execute",
											name = L["Show Auras"],
											func = function()local U = SVUI_Target;if U.forceShowAuras then U.forceShowAuras = nil else U.forceShowAuras = true end MOD:SetUnitFrame("target")end
										},
										predict = {
											order = 2,
											name = L["Heal Prediction"],
											desc = L["Show a incomming heal prediction bar on the unitframe. Also display a slightly different colored bar for incoming overheals."],
											type = "toggle"
										},
										hideonnpc = {
											type = "toggle",
											order = 3,
											name = L["Text Toggle On NPC"],
											desc = L["Power text will be hidden on NPC targets, in addition the name text will be repositioned to the power texts anchor point."],
											get = function(l)return SV.db.UnitFrames["target"]["power"].hideonnpc end,
											set = function(l, m)SV.db.UnitFrames["target"]["power"].hideonnpc = m;MOD:SetUnitFrame("target")end
										},
										threatEnabled = {
											type = "toggle",
											order = 4,
											name = L["Show Threat"]
										},
										middleClickFocus = {
											order = 5,
											name = L["Middle Click - Set Focus"],
											desc = L["Middle clicking the unit frame will cause your focus to match the unit."],
											type = "toggle",
											disabled = function()return IsAddOnLoaded("Clique")end
										},

									}
								},
								sizeGroup = {
									order = 2,
									guiInline = true,
									type = "group",
									name = L["Size Settings"],
									args = {
										width = {
											order = 1,
											name = L["Width"],
											type = "range",
											width = "full",
											min = 10,
											max = 500,
											step = 1,
											set = function(l, m)
												if SV.db.UnitFrames["target"].castbar.width == SV.db.UnitFrames["target"][l[#l]] then
													SV.db.UnitFrames["target"].castbar.width = m
												end
												MOD:ChangeDBVar(m, l[#l], "target");
												MOD:SetUnitFrame("target")
											end
										},
										height = {
											order = 2,
											name = L["Height"],
											type = "range",
											width = "full",
											min = 10,
											max = 500,
											step = 1
										},
									}
								}
							}
						},
						combobar = {
							order = 800,
							type = "group",
							name = L["Combobar"],
							get = function(l)return SV.db.UnitFrames["target"]["combobar"][l[#l]]end,
							set = function(l, m)MOD:ChangeDBVar(m, l[#l], "target", "combobar");MOD:SetUnitFrame("target")end,
							args = {
								enable = {
									type = "toggle",
									order = 1,
									name = L["Enable"]
								},
								smallIcons = {
									type = "toggle",
									name = L["Small Points"],
									order = 2
								},
								height = {
									type = "range",
									order = 3,
									name = L["Height"],
									min = 15,
									max = 45,
									step = 1
								},
								autoHide = {
									type = "toggle",
									name = L["Auto-Hide"],
									order = 4
								}
							}
						},
						misc = SVUIOptions:SetMiscConfigGroup(false, MOD.SetUnitFrame, "target"),
						health = SVUIOptions:SetHealthConfigGroup(false, MOD.SetUnitFrame, "target"),
						power = SVUIOptions:SetPowerConfigGroup(true, MOD.SetUnitFrame, "target"),
						name = SVUIOptions:SetNameConfigGroup(MOD.SetUnitFrame, "target"),
						portrait = SVUIOptions:SetPortraitConfigGroup(MOD.SetUnitFrame, "target"),
						buffs = SVUIOptions:SetAuraConfigGroup(false, "buffs", false, MOD.SetUnitFrame, "target"),
						debuffs = SVUIOptions:SetAuraConfigGroup(false, "debuffs", false, MOD.SetUnitFrame, "target"),
						castbar = SVUIOptions:SetCastbarConfigGroup(MOD.SetUnitFrame, "target"),
						icons = SVUIOptions:SetIconConfigGroup(MOD.SetUnitFrame, "target")
					}
				},
				targettarget = {
					name = L['Target of Target'],
					type = 'group',
					order = 7,
					childGroups = "select",
					get = function(l)return SV.db.UnitFrames['targettarget'][l[#l]]end,
					set = function(l,m)MOD:ChangeDBVar(m, l[#l], "targettarget");MOD:SetUnitFrame('targettarget')end,
					args={
						enable={type='toggle',order=1,name=L['Enable']},
						resetSettings={type='execute',order=2,name=L['Restore Defaults'],func=function(l,m)MOD:ResetUnitOptions('targettarget')SV:ResetAnchors('TargetTarget Frame')end},
						spacer1 = {
							order = 3,
							name = "",
							type = "description",
							width = "full",
						},
						spacer2 = {
							order = 4,
							name = "",
							type = "description",
							width = "full",
						},
						commonGroup = {
							order = 5,
							type = 'group',
							name = L['General Settings'],
							args = {
								baseGroup = {
									order = 1,
									type = "group",
									guiInline = true,
									name = L["Base Settings"],
									args = {
										showAuras = {
											order = 1,
											type = "execute",
											name = L["Show Auras"],
											func = function()local U = SVUI_TargetTarget;if U.forceShowAuras then U.forceShowAuras = nil else U.forceShowAuras = true end MOD:SetUnitFrame("targettarget")end
										},
										spacer1 = {
											order = 2,
											type = "description",
											name = "",
										},
										rangeCheck = {
											order = 3,
											name = L["Range Check"],
											desc = L["Check if you are in range to cast spells on this specific unit."],
											type = "toggle"
										},
										hideonnpc = {
											type = "toggle",
											order = 4,
											name = L["Text Toggle On NPC"],
											desc = L["Power text will be hidden on NPC targets, in addition the name text will be repositioned to the power texts anchor point."],
											get = function(l)return SV.db.UnitFrames["target"]["power"].hideonnpc end,
											set = function(l, m)SV.db.UnitFrames["target"]["power"].hideonnpc = m;MOD:SetUnitFrame("target")end
										},
										threatEnabled = {
											type = "toggle",
											order = 5,
											name = L["Show Threat"]
										}
									}
								},
								sizeGroup = {
									order = 2,
									guiInline = true,
									type = "group",
									name = L["Size Settings"],
									args = {
										width = {
											order = 1,
											name = L["Width"],
											type = "range",
											width = "full",
											min = 10,
											max = 500,
											step = 1,
										},
										height = {
											order = 2,
											name = L["Height"],
											type = "range",
											width = "full",
											min = 10,
											max = 500,
											step = 1
										},
									}
								}
							}
						},
						misc = SVUIOptions:SetMiscConfigGroup(false, MOD.SetUnitFrame, "targettarget"),
						health = SVUIOptions:SetHealthConfigGroup(false, MOD.SetUnitFrame, "targettarget"),
						power = SVUIOptions:SetPowerConfigGroup(nil, MOD.SetUnitFrame, "targettarget"),
						name = SVUIOptions:SetNameConfigGroup(MOD.SetUnitFrame, "targettarget"),
						portrait = SVUIOptions:SetPortraitConfigGroup(MOD.SetUnitFrame, "targettarget"),
						buffs = SVUIOptions:SetAuraConfigGroup(false, "buffs", false, MOD.SetUnitFrame, "targettarget"),
						debuffs = SVUIOptions:SetAuraConfigGroup(false, "debuffs", false, MOD.SetUnitFrame, "targettarget"),
						icons = SVUIOptions:SetIconConfigGroup(MOD.SetUnitFrame, "targettarget")
					}
				},
				focus = {
					name = L["Focus"],
					type = "group",
					order = 8,
					childGroups = "select",
					get = function(l)return SV.db.UnitFrames["focus"][l[#l]]end,
					set = function(l, m)MOD:ChangeDBVar(m, l[#l], "focus");MOD:SetUnitFrame("focus")end,
					args = {
						enable = {type = "toggle", order = 1, name = L["Enable"]},
						resetSettings = {type = "execute", order = 2, name = L["Restore Defaults"], func = function(l, m)MOD:ResetUnitOptions("focus");SV:ResetAnchors("Focus Frame")end},
						spacer1 = {
							order = 3,
							name = "",
							type = "description",
							width = "full",
						},
						spacer2 = {
							order = 4,
							name = "",
							type = "description",
							width = "full",
						},
						commonGroup = {
							order = 5,
							type = "group",
							name = L["General Settings"],
							args = {
								baseGroup = {
									order = 1,
									type = "group",
									guiInline = true,
									name = L["Base Settings"],
									args = {
										showAuras = {
											order = 1,
											type = "execute",
											name = L["Show Auras"],
											func = function()local U = SVUI_Focus;if U.forceShowAuras then U.forceShowAuras = nil else U.forceShowAuras = true end MOD:SetUnitFrame("focus")end
										},
										rangeCheck = {
											order = 2,
											name = L["Range Check"],
											desc = L["Check if you are in range to cast spells on this specific unit."],
											type = "toggle"
										},
										predict = {
											order = 3,
											name = L["Heal Prediction"],
											desc = L["Show a incomming heal prediction bar on the unitframe. Also display a slightly different colored bar for incoming overheals."],
											type = "toggle"
										},
										hideonnpc = {
											type = "toggle",
											order = 4,
											name = L["Text Toggle On NPC"],
											desc = L["Power text will be hidden on NPC targets, in addition the name text will be repositioned to the power texts anchor point."],
											get = function(l)return SV.db.UnitFrames["focus"]["power"].hideonnpc end,
											set = function(l, m)SV.db.UnitFrames["focus"]["power"].hideonnpc = m;MOD:SetUnitFrame("focus")end
										},
										threatEnabled = {
											type = "toggle",
											order = 5,
											name = L["Show Threat"]
										}
									}
								},
								sizeGroup = {
									order = 2,
									guiInline = true,
									type = "group",
									name = L["Size Settings"],
									args = {
										width = {
											order = 1,
											name = L["Width"],
											type = "range",
											width = "full",
											min = 10,
											max = 500,
											step = 1,
										},
										height = {
											order = 2,
											name = L["Height"],
											type = "range",
											width = "full",
											min = 10,
											max = 500,
											step = 1
										},
									}
								},
							}
						},
						misc = SVUIOptions:SetMiscConfigGroup(false, MOD.SetUnitFrame, "focus"),
						health = SVUIOptions:SetHealthConfigGroup(false, MOD.SetUnitFrame, "focus"),
						power = SVUIOptions:SetPowerConfigGroup(nil, MOD.SetUnitFrame, "focus"),
						name = SVUIOptions:SetNameConfigGroup(MOD.SetUnitFrame, "focus"),
						buffs = SVUIOptions:SetAuraConfigGroup(false, "buffs", false, MOD.SetUnitFrame, "focus"),
						debuffs = SVUIOptions:SetAuraConfigGroup(false, "debuffs", false, MOD.SetUnitFrame, "focus"),
						castbar = SVUIOptions:SetCastbarConfigGroup(MOD.SetUnitFrame, "focus"),
						icons = SVUIOptions:SetIconConfigGroup(MOD.SetUnitFrame, "focus")
					}
				},
				focustarget = {
					name = L["FocusTarget"],
					type = "group",
					order = 9,
					childGroups = "select",
					get = function(l)return SV.db.UnitFrames["focustarget"][l[#l]]end,
					set = function(l, m)MOD:ChangeDBVar(m, l[#l], "focustarget");MOD:SetUnitFrame("focustarget")end,
					args = {
						enable = {type = "toggle", order = 1, name = L["Enable"]},
						resetSettings = {type = "execute", order = 2, name = L["Restore Defaults"], func = function(l, m)MOD:ResetUnitOptions("focustarget")SV:ResetAnchors("FocusTarget Frame")end},
						spacer1 = {
							order = 3,
							name = "",
							type = "description",
							width = "full",
						},
						spacer2 = {
							order = 4,
							name = "",
							type = "description",
							width = "full",
						},
						commonGroup = {
							order = 5,
							type = "group",
							name = L["General Settings"],
							args = {
								baseGroup = {
									order = 1,
									type = "group",
									guiInline = true,
									name = L["Base Settings"],
									args = {
										showAuras = {
											order = 1,
											type = "execute",
											name = L["Show Auras"],
											func = function()
												if(SVUI_FocusTarget.forceShowAuras == true) then
													SVUI_FocusTarget.forceShowAuras = nil
												else
													SVUI_FocusTarget.forceShowAuras = true
												end
												MOD:SetUnitFrame("focustarget")
											end
										},
										spacer1 = {
											order = 2,
											type = "description",
											name = "",
										},
										rangeCheck = {order = 3, name = L["Range Check"], desc = L["Check if you are in range to cast spells on this specific unit."], type = "toggle"},
										hideonnpc = {type = "toggle", order = 4, name = L["Text Toggle On NPC"], desc = L["Power text will be hidden on NPC targets, in addition the name text will be repositioned to the power texts anchor point."], get = function(l)return SV.db.UnitFrames["focustarget"]["power"].hideonnpc end, set = function(l, m)SV.db.UnitFrames["focustarget"]["power"].hideonnpc = m;MOD:SetUnitFrame("focustarget")end},
										threatEnabled = {type = "toggle", order = 5, name = L["Show Threat"]}
									}
								},
								sizeGroup = {
									order = 2,
									guiInline = true,
									type = "group",
									name = L["Size Settings"],
									args = {
										width = {
											order = 1,
											name = L["Width"],
											type = "range",
											width = "full",
											min = 10,
											max = 500,
											step = 1,
										},
										height = {
											order = 2,
											name = L["Height"],
											type = "range",
											width = "full",
											min = 10,
											max = 500,
											step = 1
										},
									}
								},
							}
						},
						misc = SVUIOptions:SetMiscConfigGroup(false, MOD.SetUnitFrame, "focustarget"),
						health = SVUIOptions:SetHealthConfigGroup(false, MOD.SetUnitFrame, "focustarget"),
						power = SVUIOptions:SetPowerConfigGroup(false, MOD.SetUnitFrame, "focustarget"),
						name = SVUIOptions:SetNameConfigGroup(MOD.SetUnitFrame, "focustarget"),
						buffs = SVUIOptions:SetAuraConfigGroup(false, "buffs", false, MOD.SetUnitFrame, "focustarget"),
						debuffs = SVUIOptions:SetAuraConfigGroup(false, "debuffs", false, MOD.SetUnitFrame, "focustarget"),
						icons = SVUIOptions:SetIconConfigGroup(MOD.SetUnitFrame, "focustarget")
					}
				},
				party = {
					name = L['Party'],
					type = 'group',
					order = 10,
					childGroups = "select",
					get = function(l) return SV.db.UnitFrames['party'][l[#l]] end,
					set = function(l, m) MOD:ChangeDBVar(m, l[#l], "party"); MOD:SetGroupFrame('party') end,
					args = {
						enable = {
							type = 'toggle',
							order = 1,
							name = L['Enable'],
						},
						configureToggle = {
							order = 2,
							type = 'execute',
							name = L['Display Frames'],
							func = function()
								MOD:ViewGroupFrames(SVUI_Party, SVUI_Party.forceShow ~= true or nil)
							end,
						},
						resetSettings = {
							type = 'execute',
							order = 3,
							name = L['Restore Defaults'],
							func = function(l, m)MOD:ResetUnitOptions('party')SV:ResetAnchors('Party Frames')end,
						},
						spacer1 = {
							order = 4,
							name = "",
							type = "description",
							width = "full",
						},
						spacer2 = {
							order = 5,
							name = "",
							type = "description",
							width = "full",
						},
						general = {
							order = 6,
							type = "group",
							name = L["General Settings"],
							args = {
								commonGroup = {
									order = 1,
									name = L["Basic Options"],
									type = "group",
									guiInline = true,
									args = {
										rangeCheck = {
											order = 1,
											type = "toggle",
											name = L["Range Check"],
											desc = L["Check if you are in range to cast spells on this specific unit."],
										},
										predict = {
											order = 2,
											type = "toggle",
											name = L["Heal Prediction"],
											desc = L["Show a incomming heal prediction bar on the unitframe. Also display a slightly different colored bar for incoming overheals."],
										},
										threatEnabled = {
											order = 3,
											type = "toggle",
											name = L["Show Threat"],
										},
										useFor5man = {
											order = 4,
											type = "toggle",
											name = L["Raid 5 Party"],
											desc = L["Use party frames when in a 5-man raid group"],
											get = function(l) return SV.db.UnitFrames['party'][l[#l]] end,
											set = function(l, m) MOD:ChangeDBVar(m, l[#l], "party"); MOD:SetGroupFrame("party"); MOD:SetGroupFrame("raid"); end,
										},
									}
								},
								layoutGroup = {
									order = 2,
									name = L["Layout Options"],
									type = "group",
									guiInline = true,
									set = function(key, value) MOD:ChangeDBVar(value, key[#key], "party"); MOD:SetGroupFrame("party", true) end,
									args = {
										common = {
											order = 1,
											name = L["General Layout"],
											type = "group",
											guiInline = true,
											args = {
												enable = {
													order = 1,
													name = L["Enable Grid Mode"],
													desc = L["Converts frames into symmetrical squares. Ideal for healers."],
													type = "toggle",
													get = function(key) return SV.db.UnitFrames["party"].grid.enable end,
													set = function(key, value)
														MOD:ChangeDBVar(value, key[#key], "party", "grid");
														MOD:SetGroupFrame("party", true);
														SV.Options.args.UnitFrames.args.commonGroup.args.party.args.general.args.layoutGroup.args.sizing = SVUIOptions:SetSizeConfigGroup(value, "party");
													end,
												},
												invertGroupingOrder = {
													order = 2,
													type = "toggle",
													name = L["Invert Grouping Order"],
													desc = L["Enabling this inverts the grouping order."],
													disabled = function() return not SV.db.UnitFrames["party"].customSorting end,
												},
											}
										},
										sizing = SVUIOptions:SetSizeConfigGroup(SV.db.UnitFrames.party.grid.enable, "party"),
										sorting = {
											order = 3,
											name = L["Sorting"],
											type = "group",
											guiInline = true,
											args = {
												gRowCol = {
													order = 1,
													type = "range",
													name = L["Groups Per Row / Column"],
													min = 1,
													max = 8,
													step = 1,
													width = 'full',
													set = function(key, value)
														MOD:ChangeDBVar(value, key[#key], "party");
														MOD:SetGroupFrame("party")
														if(_G["SVUI_Raid"] and _G["SVUI_Raid"].isForced) then
															MOD:ViewGroupFrames(_G["SVUI_Raid"])
															MOD:ViewGroupFrames(_G["SVUI_Raid"], true)
														end
													end,
												},
												showBy = {
													order = 2,
													name = L["Growth Direction"],
													desc = L["Growth direction from the first unitframe."],
													type = "select",
													values = {
														DOWN_RIGHT = format(L["%s and then %s"], L["Down"], L["Right"]),
														DOWN_LEFT = format(L["%s and then %s"], L["Down"], L["Left"]),
														UP_RIGHT = format(L["%s and then %s"], L["Up"], L["Right"]),
														UP_LEFT = format(L["%s and then %s"], L["Up"], L["Left"]),
														RIGHT_DOWN = format(L["%s and then %s"], L["Right"], L["Down"]),
														RIGHT_UP = format(L["%s and then %s"], L["Right"], L["Up"]),
														LEFT_DOWN = format(L["%s and then %s"], L["Left"], L["Down"]),
														LEFT_UP = format(L["%s and then %s"], L["Left"], L["Up"]),
													},
												},
												sortMethod = {
													order = 3,
													name = L["Group By"],
													desc = L["Set the order that the group will sort."],
													type = "select",
													values = {
														["CLASS"] = CLASS,
														["ROLE"] = ROLE.."(Tanks, Healers, DPS)",
														["ROLE_TDH"] = ROLE.."(Tanks, DPS, Healers)",
														["ROLE_HDT"] = ROLE.."(Healers, DPS, Tanks)",
														["ROLE_HTD"] = ROLE.."(Healers, Tanks, DPS)",
														["NAME"] = NAME,
														["MTMA"] = L["Main Tanks  /  Main Assist"],
														["GROUP"] = GROUP,
													},
												},
												sortDir = {
													order = 4,
													name = L["Sort Direction"],
													desc = L["Defines the sort order of the selected sort method."],
													type = "select",
													values = {
														["ASC"] = L["Ascending"],
														["DESC"] = L["Descending"],
													},
												},
											}
										}
									},
								},
							}
						},
						auraWatch = {
							order = 600,
							type = 'group',
							name = L['Aura Watch'],
							get = function(l)return
							SV.db.UnitFrames['party']['auraWatch'][l[#l]]end,
							set = function(l, m) MOD:ChangeDBVar(m, l[#l], "party", "auraWatch"); MOD:SetGroupFrame('party')end,
							args = {
								enable = {
									type = 'toggle',
									name = L['Enable'],
									order = 1,
								},
								size = {
									type = 'range',
									name = L['Size'],
									desc = L['Size of the indicator icon.'],
									order = 2,
									min = 4,
									max = 15,
									step = 1,
								},
								configureButton = {
									type = 'execute',
									name = L['Configure Auras'],
									func = function()SVUIOptions:SetToFilterConfig('BuffWatch')end,
									order = 3,
								},

							},
						},
						misc = SVUIOptions:SetMiscConfigGroup(true, MOD.SetGroupFrame, 'party'),
						health = SVUIOptions:SetHealthConfigGroup(true, MOD.SetGroupFrame, 'party'),
						power = SVUIOptions:SetPowerConfigGroup(false, MOD.SetGroupFrame, 'party'),
						name = SVUIOptions:SetNameConfigGroup(MOD.SetGroupFrame, 'party'),
						portrait = SVUIOptions:SetPortraitConfigGroup(MOD.SetGroupFrame, 'party'),
						buffs = SVUIOptions:SetAuraConfigGroup(true, 'buffs', true, MOD.SetGroupFrame, 'party'),
						debuffs = SVUIOptions:SetAuraConfigGroup(true, 'debuffs', true, MOD.SetGroupFrame, 'party'),
						petsGroup = {
							order = 800,
							type = 'group',
							name = L['Party Pets'],
							get = function(l)return SV.db.UnitFrames['party']['petsGroup'][l[#l]]end,
							set = function(l, m)MOD:ChangeDBVar(m, l[#l], "party", "petsGroup");MOD:SetGroupFrame('party')end,
							args = {
								enable = {
									type = 'toggle',
									name = L['Enable'],
									order = 1,
								},
								width = {
									order = 3,
									name = L['Width'],
									type = 'range',
									min = 10,
									max = 500,
									step = 1,
								},
								height = {
									order = 4,
									name = L['Height'],
									type = 'range',
									min = 10,
									max = 250,
									step = 1,
								},
								anchorPoint = {
									type = 'select',
									order = 5,
									name = L['Anchor Point'],
									desc = L['What point to anchor to the frame you set to attach to.'],
									values = {TOPLEFT='TOPLEFT',LEFT='LEFT',BOTTOMLEFT='BOTTOMLEFT',RIGHT='RIGHT',TOPRIGHT='TOPRIGHT',BOTTOMRIGHT='BOTTOMRIGHT',CENTER='CENTER',TOP='TOP',BOTTOM='BOTTOM'},
								},
								xOffset = {
									order = 6,
									type = 'range',
									name = L['xOffset'],
									desc = L['An X offset (in pixels) to be used when anchoring new frames.'],
									min =  - 500,
									max = 500,
									step = 1,
								},
								yOffset = {
									order = 7,
									type = 'range',
									name = L['yOffset'],
									desc = L['An Y offset (in pixels) to be used when anchoring new frames.'],
									min =  - 500,
									max = 500,
									step = 1,
								},
								name_length = {
									order = 8,
									name = L["Name Length"],
									desc = L["TEXT_FORMAT_DESC"],
									type = "range",
									width = "full",
									min = 1,
									max = 30,
									step = 1,
									set = function(key, value)
										MOD:ChangeDBVar(value, key[#key], "party", "petsGroup");
										local tag = "[name:" .. value .. "]";
										MOD:ChangeDBVar(tag, "tags", "party", "petsGroup");
									end,
								}
							},
						},
						targetsGroup = {
							order = 900,
							type = 'group',
							name = L['Party Targets'],
							get = function(l)return
							SV.db.UnitFrames['party']['targetsGroup'][l[#l]]end,
							set = function(l, m) MOD:ChangeDBVar(m, l[#l], "party", "targetsGroup"); MOD:SetGroupFrame('party') end,
							args = {
								enable = {
									type = 'toggle',
									name = L['Enable'],
									order = 1,
								},
								width = {
									order = 3,
									name = L['Width'],
									type = 'range',
									min = 10,
									max = 500,
									step = 1,
								},
								height = {
									order = 4,
									name = L['Height'],
									type = 'range',
									min = 10,
									max = 250,
									step = 1,
								},
								anchorPoint = {
									type = 'select',
									order = 5,
									name = L['Anchor Point'],
									desc = L['What point to anchor to the frame you set to attach to.'],
									values = {TOPLEFT='TOPLEFT',LEFT='LEFT',BOTTOMLEFT='BOTTOMLEFT',RIGHT='RIGHT',TOPRIGHT='TOPRIGHT',BOTTOMRIGHT='BOTTOMRIGHT',CENTER='CENTER',TOP='TOP',BOTTOM='BOTTOM'},
								},
								xOffset = {
									order = 6,
									type = 'range',
									name = L['xOffset'],
									desc = L['An X offset (in pixels) to be used when anchoring new frames.'],
									min =  - 500,
									max = 500,
									step = 1,
								},
								yOffset = {
									order = 7,
									type = 'range',
									name = L['yOffset'],
									desc = L['An Y offset (in pixels) to be used when anchoring new frames.'],
									min =  - 500,
									max = 500,
									step = 1,
								},
								name_length = {
									order = 8,
									name = L["Name Length"],
									desc = L["TEXT_FORMAT_DESC"],
									type = "range",
									width = "full",
									min = 1,
									max = 30,
									step = 1,
									set = function(key, value)
										MOD:ChangeDBVar(value, key[#key], "party", "targetsGroup");
										local tag = "[name:" .. value .. "]";
										MOD:ChangeDBVar(tag, "tags", "party", "targetsGroup");
									end,
								}
							},
						},
						rdebuffs = {
							order = 700,
							type = 'group',
							name = L['Raid Debuffs'],
							get = function(l)return
							SV.db.UnitFrames['party']['rdebuffs'][l[#l]]end,
							set = function(l, m) MOD:ChangeDBVar(m, l[#l], "party", "rdebuffs"); MOD:SetGroupFrame('party')end,
							args = {
								enable = {
									type = "toggle",
									name = L["Enable"],
									order = 1,
								},
								configureToggle = {
									order = 2,
									type = "execute",
									name = L["Show Indicators"],
									func = function()
										local toggle = (not _G["SVUI_Party"].forceShowAuras) or nil
										MOD:ViewGroupFrames(_G["SVUI_Party"], true, toggle)
										MOD:SetGroupFrame('party')
									end,
								},
								configureButton = {
									type = "execute",
									name = L["Configure Filters"],
									func = function() SVUIOptions:SetToFilterConfig("Raid") end,
									order = 3,
								},
								size = {
									type = "range",
									name = L["Size"],
									order = 4,
									min = 8,
									max = 35,
									step = 1,
								},
								fontSize = {
									type = "range",
									name = L["Font Size"],
									order = 5,
									min = 7,
									max = 22,
									step = 1,
								},
								xOffset = {
									order = 6,
									type = "range",
									name = L["xOffset"],
									min =  - 300,
									max = 300,
									step = 1,
								},
								yOffset = {
									order = 7,
									type = "range",
									name = L["yOffset"],
									min =  - 300,
									max = 300,
									step = 1,
								},
							},
						},
						icons = SVUIOptions:SetIconConfigGroup(MOD.SetGroupFrame, 'party')
					},
				},
				raid = {
					name = "Raid",
					type = "group",
					order = 11,
					childGroups = "select",
					get = function(l) return SV.db.UnitFrames.raid[l[#l]] end,
					set = function(l, m) MOD:ChangeDBVar(m, l[#l], "raid"); MOD:SetGroupFrame("raid") end,
					args = {
						enable = {
							type = "toggle",
							order = 1,
							name = L["Enable"],
						},
						configureToggle = {
							order = 2,
							type = "execute",
							name = L["Display Frames"],
							func = function()
								local setForced = (_G["SVUI_Raid"].forceShow ~= true) or nil;
								MOD:ViewGroupFrames(_G["SVUI_Raid"], setForced)
							end,
						},
						resetSettings = {
							type = "execute",
							order = 3,
							name = L["Restore Defaults"],
							func = function(l, m)MOD:ResetUnitOptions("raid") SV:ResetAnchors("Raid Frames") end,
						},
						spacer1 = {
							order = 4,
							name = "",
							type = "description",
							width = "full",
						},
						spacer2 = {
							order = 5,
							name = "",
							type = "description",
							width = "full",
						},
						general = {
							order = 6,
							type = "group",
							name = L["General Settings"],
							args = {
								commonGroup = {
									order = 1,
									name = L["Basic Options"],
									type = "group",
									guiInline = true,
									args = {
										rangeCheck = {
											order = 1,
											type = "toggle",
											name = L["Range Check"],
											desc = L["Check if you are in range to cast spells on this specific unit."],
										},
										predict = {
											order = 2,
											type = "toggle",
											name = L["Heal Prediction"],
											desc = L["Show a incomming heal prediction bar on the unitframe. Also display a slightly different colored bar for incoming overheals."],
										},
										threatEnabled = {
											order = 3,
											type = "toggle",
											name = L["Show Threat"],
										},
										useFor5man = {
											order = 4,
											type = "toggle",
											name = L["Raid 5 Party"],
											desc = L["Use party frames when in a 5-man raid group"],
											get = function(l) return SV.db.UnitFrames.party[l[#l]] end,
											set = function(l, m) MOD:ChangeDBVar(m, l[#l], "party"); MOD:SetGroupFrame("party"); MOD:SetGroupFrame("raid"); end,
										},
									}
								},
								layoutGroup = {
									order = 2,
									name = L["Layout Options"],
									type = "group",
									guiInline = true,
									set = function(key, value) MOD:ChangeDBVar(value, key[#key], "raid"); MOD:SetGroupFrame("raid", true) end,
									args = {
										common = {
											order = 1,
											name = L["General Layout"],
											type = "group",
											guiInline = true,
											args = {
												enable = {
													order = 1,
													name = L["Enable Grid Mode"],
													desc = L["Converts frames into symmetrical squares. Ideal for healers."],
													type = "toggle",
													get = function(key) return SV.db.UnitFrames.raid.grid.enable end,
													set = function(key, value)
														MOD:ChangeDBVar(value, key[#key], "raid", "grid");
														MOD:SetGroupFrame("raid", true);
														SV.Options.args.UnitFrames.args.commonGroup.args.raid.args.general.args.layoutGroup.args.sizing = SVUIOptions:SetSizeConfigGroup(value, "raid");
													end,
												},
												showPlayer = {
													order = 2,
													type = "toggle",
													name = L["Display Player"],
													desc = L["When true, always show player in raid frames."],
													get = function(l)return SV.db.UnitFrames.raid.showPlayer end,
													set = function(l, m) MOD:ChangeDBVar(m, l[#l], "raid"); MOD:SetGroupFrame("raid", true) end,
												},
												invertGroupingOrder = {
													order = 3,
													type = "toggle",
													name = L["Invert Grouping Order"],
													desc = L["Enabling this inverts the grouping order when the raid is not full, this will reverse the direction it starts from."],
													disabled = function() return not SV.db.UnitFrames.raid.customSorting end,
												},
											}
										},
										sizing = SVUIOptions:SetSizeConfigGroup(SV.db.UnitFrames.raid.grid.enable, "raid"),
										sorting = {
											order = 3,
											name = L["Sorting"],
											type = "group",
											guiInline = true,
											args = {
												gRowCol = {
													order = 1,
													type = "range",
													name = L["Groups Per Row / Column"],
													min = 1,
													max = 8,
													step = 1,
													width = 'full',
													set = function(key, value)
														MOD:ChangeDBVar(value, key[#key], "raid");
														MOD:SetGroupFrame("raid")
														if(_G["SVUI_Raid"] and _G["SVUI_Raid"].isForced) then
															MOD:ViewGroupFrames(_G["SVUI_Raid"])
															MOD:ViewGroupFrames(_G["SVUI_Raid"], true)
														end
													end,
												},
												showBy = {
													order = 2,
													name = L["Growth Direction"],
													desc = L["Growth direction from the first unitframe."],
													type = "select",
													values = {
														DOWN_RIGHT = format(L["%s and then %s"], L["Down"], L["Right"]),
														DOWN_LEFT = format(L["%s and then %s"], L["Down"], L["Left"]),
														UP_RIGHT = format(L["%s and then %s"], L["Up"], L["Right"]),
														UP_LEFT = format(L["%s and then %s"], L["Up"], L["Left"]),
														RIGHT_DOWN = format(L["%s and then %s"], L["Right"], L["Down"]),
														RIGHT_UP = format(L["%s and then %s"], L["Right"], L["Up"]),
														LEFT_DOWN = format(L["%s and then %s"], L["Left"], L["Down"]),
														LEFT_UP = format(L["%s and then %s"], L["Left"], L["Up"]),
													},
												},
												sortMethod = {
													order = 3,
													name = L["Group By"],
													desc = L["Set the order that the group will sort."],
													type = "select",
													values = {
														["CLASS"] = CLASS,
														["ROLE"] = ROLE.."(Tanks, Healers, DPS)",
														["ROLE_TDH"] = ROLE.."(Tanks, DPS, Healers)",
														["ROLE_HDT"] = ROLE.."(Healers, DPS, Tanks)",
														["ROLE_HTD"] = ROLE.."(Healers, Tanks, DPS)",
														["NAME"] = NAME,
														["MTMA"] = L["Main Tanks  /  Main Assist"],
														["GROUP"] = GROUP,
													},
												},
												sortDir = {
													order = 4,
													name = L["Sort Direction"],
													desc = L["Defines the sort order of the selected sort method."],
													type = "select",
													values = {
														["ASC"] = L["Ascending"],
														["DESC"] = L["Descending"],
													},
												},
												spacer3 = {
													order = 5,
													type = "description",
													width = "full",
													name = " ",
												},
												allowedGroup = {
													order = 6,
													name = L["Enabled Groups"],
													type = "group",
													guiInline = true,
													args = {
														showGroupNumber = {
															type = "toggle",
															order = 1,
															name = L["Show Group Number Icons"],
															width = 'full',
														},
														one = {
															type = "toggle",
															order = 2,
															name = L["Group 1"],
															get = function(key) return SV.db.UnitFrames.raid["allowedGroup"][1] end,
															set = function(key, value)
																SV.db.UnitFrames.raid["allowedGroup"][1] = value;
																MOD:SetGroupFrame("raid")
															end,
														},
														two = {
															type = "toggle",
															order = 3,
															name = L["Group 2"],
															get = function(key) return SV.db.UnitFrames.raid["allowedGroup"][2] end,
															set = function(key, value)
																SV.db.UnitFrames.raid["allowedGroup"][2] = value;
																MOD:SetGroupFrame("raid")
															end,
														},
														three = {
															type = "toggle",
															order = 4,
															name = L["Group 3"],
															get = function(key) return SV.db.UnitFrames.raid["allowedGroup"][3] end,
															set = function(key, value)
																SV.db.UnitFrames.raid["allowedGroup"][3] = value;
																MOD:SetGroupFrame("raid")
															end,
														},
														four = {
															type = "toggle",
															order = 5,
															name = L["Group 4"],
															get = function(key) return SV.db.UnitFrames.raid["allowedGroup"][4] end,
															set = function(key, value)
																SV.db.UnitFrames.raid["allowedGroup"][4] = value;
																MOD:SetGroupFrame("raid")
															end,
														},
														five = {
															type = "toggle",
															order = 6,
															name = L["Group 5"],
															get = function(key) return SV.db.UnitFrames.raid["allowedGroup"][5] end,
															set = function(key, value)
																SV.db.UnitFrames.raid["allowedGroup"][5] = value;
																MOD:SetGroupFrame("raid")
															end,
														},
														six = {
															type = "toggle",
															order = 7,
															name = L["Group 6"],
															get = function(key) return SV.db.UnitFrames.raid["allowedGroup"][6] end,
															set = function(key, value)
																SV.db.UnitFrames.raid["allowedGroup"][6] = value;
																MOD:SetGroupFrame("raid")
															end,
														},
														seven = {
															type = "toggle",
															order = 8,
															name = L["Group 7"],
															get = function(key) return SV.db.UnitFrames.raid["allowedGroup"][7] end,
															set = function(key, value)
																SV.db.UnitFrames.raid["allowedGroup"][7] = value;
																MOD:SetGroupFrame("raid")
															end,
														},
														eight = {
															type = "toggle",
															order = 9,
															name = L["Group 8"],
															get = function(key) return SV.db.UnitFrames.raid["allowedGroup"][8] end,
															set = function(key, value)
																SV.db.UnitFrames.raid["allowedGroup"][8] = value;
																MOD:SetGroupFrame("raid")
															end,
														},
													},
												},
											}
										}
									},
								},
							}
						},
						misc = SVUIOptions:SetMiscConfigGroup(true, MOD.SetGroupFrame, "raid"),
						health = SVUIOptions:SetHealthConfigGroup(true, MOD.SetGroupFrame, "raid"),
						power = SVUIOptions:SetPowerConfigGroup(false, MOD.SetGroupFrame, "raid"),
						name = SVUIOptions:SetNameConfigGroup(MOD.SetGroupFrame, "raid"),
						buffs = SVUIOptions:SetAuraConfigGroup(true, "buffs", true, MOD.SetGroupFrame, "raid"),
						debuffs = SVUIOptions:SetAuraConfigGroup(true, "debuffs", true, MOD.SetGroupFrame, "raid"),
						auraWatch = {
							order = 600,
							type = "group",
							name = L["Aura Watch"],
							args = {
								enable = {
									type = "toggle",
									name = L["Enable"],
									order = 1,
									get = function(l)return SV.db.UnitFrames.raid.auraWatch.enable end,
									set = function(l, m)MOD:ChangeDBVar(m, "enable", "raid", "auraWatch");MOD:SetGroupFrame("raid")end,
								},
								size = {
									type = "range",
									name = L["Size"],
									desc = L["Size of the indicator icon."],
									order = 2,
									min = 4,
									max = 15,
									step = 1,
									get = function(l)return SV.db.UnitFrames.raid.auraWatch.size end,
									set = function(l, m)MOD:ChangeDBVar(m, "size", "raid", "auraWatch");MOD:SetGroupFrame("raid")end,
								},
								configureButton = {
									type = "execute",
									name = L["Configure Auras"],
									func = function()SVUIOptions:SetToFilterConfig("BuffWatch")end,
									order = 3,
								},

							},
						},
						rdebuffs = {
							order = 800,
							type = "group",
							name = L["Raid Debuffs"],
							get = function(l)return
							SV.db.UnitFrames.raid["rdebuffs"][l[#l]]end,
							set = function(l, m)MOD:ChangeDBVar(m, l[#l], "raid", "rdebuffs");MOD:SetGroupFrame("raid")end,
							args = {
								enable = {
									type = "toggle",
									name = L["Enable"],
									order = 1,
								},
								configureToggle = {
									order = 2,
									type = "execute",
									name = L["Show Indicators"],
									func = function()
										local toggle = (not _G["SVUI_Raid"].forceShowAuras) or nil
										MOD:ViewGroupFrames(_G["SVUI_Raid"], true, toggle)
										MOD:SetGroupFrame("raid")
									end,
								},
								configureButton = {
									type = "execute",
									name = L["Configure Filters"],
									func = function()SVUIOptions:SetToFilterConfig("Raid")end,
									order = 3,
								},
								size = {
									type = "range",
									name = L["Size"],
									order = 4,
									min = 8,
									max = 35,
									step = 1,
								},
								fontSize = {
									type = "range",
									name = L["Font Size"],
									order = 5,
									min = 7,
									max = 22,
									step = 1,
								},
								xOffset = {
									order = 6,
									type = "range",
									name = L["xOffset"],
									min =  - 300,
									max = 300,
									step = 1,
								},
								yOffset = {
									order = 7,
									type = "range",
									name = L["yOffset"],
									min =  - 300,
									max = 300,
									step = 1,
								},
							},
						},
						icons = SVUIOptions:SetIconConfigGroup(MOD.SetGroupFrame, "raid"),
					},
				},
				raidpet = {
					order = 12,
					type = 'group',
					name = L['Raid Pets'],
					childGroups = "select",
					get = function(l) return SV.db.UnitFrames['raidpet'][l[#l]] end,
					set = function(l, m) MOD:ChangeDBVar(m, l[#l], "raidpet"); MOD:SetGroupFrame('raidpet'); end,
					args = {
						enable = {
							type = 'toggle',
							order = 1,
							name = L['Enable'],
						},
						configureToggle = {
							order = 2,
							type = 'execute',
							name = L['Display Frames'],
							func = function() MOD:ViewGroupFrames(SVUI_Raidpet, SVUI_Raidpet.forceShow ~= true or nil); end,
						},
						resetSettings = {
							type = 'execute',
							order = 3,
							name = L['Restore Defaults'],
							func = function(l, m) MOD:ResetUnitOptions('raidpet'); SV:ResetAnchors('Raid Pet Frames'); MOD:SetGroupFrame('raidpet', true); end,
						},
						spacer1 = {
							order = 4,
							name = "",
							type = "description",
							width = "full",
						},
						spacer2 = {
							order = 5,
							name = "",
							type = "description",
							width = "full",
						},
						general = {
							order = 6,
							type = "group",
							name = L["General Settings"],
							args = {
								commonGroup = {
									order = 1,
									name = L["Basic Options"],
									type = "group",
									guiInline = true,
									args = {
										rangeCheck = {
											order = 1,
											type = "toggle",
											name = L["Range Check"],
											desc = L["Check if you are in range to cast spells on this specific unit."],
										},
										predict = {
											order = 2,
											type = "toggle",
											name = L["Heal Prediction"],
											desc = L["Show a incomming heal prediction bar on the unitframe. Also display a slightly different colored bar for incoming overheals."],
										},
										threatEnabled = {
											order = 3,
											type = "toggle",
											name = L["Show Threat"],
										},
									}
								},
								layoutGroup = {
									order = 2,
									name = L["Layout Options"],
									type = "group",
									guiInline = true,
									set = function(key, value) MOD:ChangeDBVar(value, key[#key], "raidpet"); MOD:SetGroupFrame("raidpet", true) end,
									args = {
										common = {
											order = 1,
											name = L["General Layout"],
											type = "group",
											guiInline = true,
											args = {
												enable = {
													order = 1,
													name = L["Enable Grid Mode"],
													desc = L["Converts frames into symmetrical squares. Ideal for healers."],
													type = "toggle",
													get = function(key) return SV.db.UnitFrames["raidpet"].grid.enable end,
													set = function(key, value)
														MOD:ChangeDBVar(value, key[#key], "raidpet", "grid");
														MOD:SetGroupFrame("raidpet", true);
														SV.Options.args.UnitFrames.args.commonGroup.args.raidpet.args.general.args.layoutGroup.args.sizing = SVUIOptions:SetSizeConfigGroup(value, "raidpet");
													end,
												},
												invertGroupingOrder = {
													order = 2,
													type = "toggle",
													name = L["Invert Grouping Order"],
													desc = L["Enabling this inverts the grouping order."],
													disabled = function() return not SV.db.UnitFrames["raidpet"].customSorting end,
												},
											}
										},
										sizing = SVUIOptions:SetSizeConfigGroup(SV.db.UnitFrames.raidpet.grid.enable, "raidpet"),
										sorting = {
											order = 3,
											name = L["Sorting"],
											type = "group",
											guiInline = true,
											args = {
												gRowCol = {
													order = 1,
													type = "range",
													name = L["Groups Per Row / Column"],
													min = 1,
													max = 8,
													step = 1,
													width = 'full',
													set = function(key, value)
														MOD:ChangeDBVar(value, key[#key], "raidpet");
														MOD:SetGroupFrame("raidpet")
														if(_G["SVUI_Raid"] and _G["SVUI_Raid"].isForced) then
															MOD:ViewGroupFrames(_G["SVUI_Raid"])
															MOD:ViewGroupFrames(_G["SVUI_Raid"], true)
														end
													end,
												},
												showBy = {
													order = 2,
													name = L["Growth Direction"],
													desc = L["Growth direction from the first unitframe."],
													type = "select",
													values = {
														DOWN_RIGHT = format(L["%s and then %s"], L["Down"], L["Right"]),
														DOWN_LEFT = format(L["%s and then %s"], L["Down"], L["Left"]),
														UP_RIGHT = format(L["%s and then %s"], L["Up"], L["Right"]),
														UP_LEFT = format(L["%s and then %s"], L["Up"], L["Left"]),
														RIGHT_DOWN = format(L["%s and then %s"], L["Right"], L["Down"]),
														RIGHT_UP = format(L["%s and then %s"], L["Right"], L["Up"]),
														LEFT_DOWN = format(L["%s and then %s"], L["Left"], L["Down"]),
														LEFT_UP = format(L["%s and then %s"], L["Left"], L["Up"]),
													},
												},
												sortMethod = {
													order = 3,
													name = L["Group By"],
													desc = L["Set the order that the group will sort."],
													type = "select",
													values = {
														["CLASS"] = CLASS,
														["ROLE"] = ROLE.."(Tanks, Healers, DPS)",
														["ROLE_TDH"] = ROLE.."(Tanks, DPS, Healers)",
														["ROLE_HDT"] = ROLE.."(Healers, DPS, Tanks)",
														["ROLE_HTD"] = ROLE.."(Healers, Tanks, DPS)",
														["NAME"] = NAME,
														["MTMA"] = L["Main Tanks  /  Main Assist"],
														["GROUP"] = GROUP,
													},
												},
												sortDir = {
													order = 4,
													name = L["Sort Direction"],
													desc = L["Defines the sort order of the selected sort method."],
													type = "select",
													values = {
														["ASC"] = L["Ascending"],
														["DESC"] = L["Descending"],
													},
												},
											}
										}
									},
								},
							}
						},
						misc = SVUIOptions:SetMiscConfigGroup(true, MOD.SetGroupFrame, 'raidpet'),
						health = SVUIOptions:SetHealthConfigGroup(true, MOD.SetGroupFrame, 'raidpet'),
						name = SVUIOptions:SetNameConfigGroup(MOD.SetGroupFrame, 'raidpet'),
						buffs = SVUIOptions:SetAuraConfigGroup(true, 'buffs', true, MOD.SetGroupFrame, 'raidpet'),
						debuffs = SVUIOptions:SetAuraConfigGroup(true, 'debuffs', true, MOD.SetGroupFrame, 'raidpet'),
						auraWatch = {
							order = 600,
							type = 'group',
							name = L['Aura Watch'],
							args = {
								enable = {
									type = "toggle",
									name = L["Enable"],
									order = 1,
									get = function(l)return SV.db.UnitFrames["raidpet"].auraWatch.enable end,
									set = function(l, m)MOD:ChangeDBVar(m, "enable", "raidpet", "auraWatch");MOD:SetGroupFrame('raidpet')end,
								},
								size = {
									type = "range",
									name = L["Size"],
									desc = L["Size of the indicator icon."],
									order = 2,
									min = 4,
									max = 15,
									step = 1,
									get = function(l)return SV.db.UnitFrames["raidpet"].auraWatch.size end,
									set = function(l, m)MOD:ChangeDBVar(m, "size", "raidpet", "auraWatch");MOD:SetGroupFrame('raidpet')end,
								},
								configureButton = {
									type = 'execute',
									name = L['Configure Auras'],
									func = function()SVUIOptions:SetToFilterConfig('BuffWatch')end,
									order = 3,
								},
							},
						},
						rdebuffs = {
							order = 700,
							type = 'group',
							name = L['Raid Debuffs'],
							get = function(l)return
							SV.db.UnitFrames['raidpet']['rdebuffs'][l[#l]]end,
							set = function(l, m) MOD:ChangeDBVar(m, l[#l], "raidpet", "rdebuffs"); MOD:SetGroupFrame('raidpet')end,
							args = {
								enable = {
									type = "toggle",
									name = L["Enable"],
									order = 1,
								},
								configureToggle = {
									order = 2,
									type = "execute",
									name = L["Show Indicators"],
									func = function()
										local toggle = (not _G["SVUI_RaidPet"].forceShowAuras) or nil
										MOD:ViewGroupFrames(_G["SVUI_RaidPet"], true, toggle)
										MOD:SetGroupFrame('raidpet')
									end,
								},
								configureButton = {
									type = "execute",
									name = L["Configure Filters"],
									func = function() SVUIOptions:SetToFilterConfig("Raid") end,
									order = 3,
								},
								size = {
									type = "range",
									name = L["Size"],
									order = 4,
									min = 8,
									max = 35,
									step = 1,
								},
								fontSize = {
									type = "range",
									name = L["Font Size"],
									order = 5,
									min = 7,
									max = 22,
									step = 1,
								},
								xOffset = {
									order = 6,
									type = "range",
									name = L["xOffset"],
									min =  - 300,
									max = 300,
									step = 1,
								},
								yOffset = {
									order = 7,
									type = "range",
									name = L["yOffset"],
									min =  - 300,
									max = 300,
									step = 1,
								},
							},
						},
						icons = SVUIOptions:SetIconConfigGroup(MOD.SetGroupFrame, 'raidpet'),
					},
				},
				boss = {
					name = L["Boss"],
					type = "group",
					order = 13,
					childGroups = "select",
					get = function(l)return SV.db.UnitFrames["boss"][l[#l]]end,
					set = function(l, m)MOD:ChangeDBVar(m, l[#l], "boss");MOD:SetEnemyFrame("boss", MAX_BOSS_FRAMES)end,
					args = {
						enable = {type = "toggle", order = 1, name = L["Enable"]},
						displayFrames = {type = "execute", order = 2, name = L["Display Frames"], func = function()MOD:ViewEnemyFrames("boss", MAX_BOSS_FRAMES)end},
						resetSettings = {type = "execute", order = 3, name = L["Restore Defaults"], func = function(l, m)MOD:ResetUnitOptions("boss")SV:ResetAnchors("Boss Frames")end},
						spacer1 = {
							order = 4,
							name = "",
							type = "description",
							width = "full",
						},
						spacer2 = {
							order = 5,
							name = "",
							type = "description",
							width = "full",
						},
						commonGroup = {
							order = 6,
							type = "group",
							name = L["General Settings"],
							args = {
								baseGroup = {
									order = 1,
									type = "group",
									guiInline = true,
									name = L["Base Settings"],
									args = {
										showBy = {order = 1, name = L["Growth Direction"], type = "select", values = {["UP"] = L["Up"], ["DOWN"] = L["Down"]}},
										spacer1 = {
											order = 2,
											type = "description",
											name = "",
										},
										rangeCheck = {order = 3, name = L["Range Check"], desc = L["Check if you are in range to cast spells on this specific unit."], type = "toggle"},
										hideonnpc = {type = "toggle", order = 4, name = L["Text Toggle On NPC"], desc = L["Power text will be hidden on NPC targets, in addition the name text will be repositioned to the power texts anchor point."], get = function(l)return SV.db.UnitFrames["boss"]["power"].hideonnpc end, set = function(l, m)SV.db.UnitFrames["boss"]["power"].hideonnpc = m;MOD:SetEnemyFrame("boss")end},
										threatEnabled = {type = "toggle", order = 5, name = L["Show Threat"]}
									}
								},
								sizeGroup = {
									order = 2,
									guiInline = true,
									type = "group",
									name = L["Size Settings"],
									args = {
										width = {
											order = 1,
											name = L["Width"],
											type = "range",
											width = "full",
											min = 10,
											max = 500,
											step = 1,
										},
										height = {
											order = 2,
											name = L["Height"],
											type = "range",
											width = "full",
											min = 10,
											max = 500,
											step = 1
										},
									}
								},
							}
						},
						misc = SVUIOptions:SetMiscConfigGroup(false, MOD.SetEnemyFrame, "boss", MAX_BOSS_FRAMES),
						health = SVUIOptions:SetHealthConfigGroup(false, MOD.SetEnemyFrame, "boss", MAX_BOSS_FRAMES),
						power = SVUIOptions:SetPowerConfigGroup(false, MOD.SetEnemyFrame, "boss", MAX_BOSS_FRAMES),
						name = SVUIOptions:SetNameConfigGroup(MOD.SetEnemyFrame, "boss", MAX_BOSS_FRAMES),
						portrait = SVUIOptions:SetPortraitConfigGroup(MOD.SetEnemyFrame, "boss", MAX_BOSS_FRAMES),
						buffs = SVUIOptions:SetAuraConfigGroup(true, "buffs", false, MOD.SetEnemyFrame, "boss", MAX_BOSS_FRAMES),
						debuffs = SVUIOptions:SetAuraConfigGroup(true, "debuffs", false, MOD.SetEnemyFrame, "boss", MAX_BOSS_FRAMES),
						castbar = SVUIOptions:SetCastbarConfigGroup(MOD.SetEnemyFrame, "boss", MAX_BOSS_FRAMES),
						icons = SVUIOptions:SetIconConfigGroup(MOD.SetEnemyFrame, "boss", MAX_BOSS_FRAMES)
					}
				},
				arena = {
					name = L["Arena"],
					type = "group",
					order = 14,
					childGroups = "select",
					get = function(l)return SV.db.UnitFrames["arena"][l[#l]]end,
					set = function(l, m)MOD:ChangeDBVar(m, l[#l], "arena");MOD:SetEnemyFrame("arena", 5)end,
					args = {
						enable = {type = "toggle", order = 1, name = L["Enable"]},
						displayFrames = {type = "execute", order = 2, name = L["Display Frames"], func = function()MOD:ViewEnemyFrames("arena", 5)end},
						resetSettings = {type = "execute", order = 3, name = L["Restore Defaults"], func = function(l, m)MOD:ResetUnitOptions("arena")SV:ResetAnchors("Arena Frames")end},
						spacer1 = {
							order = 4,
							name = "",
							type = "description",
							width = "full",
						},
						spacer2 = {
							order = 5,
							name = "",
							type = "description",
							width = "full",
						},
						commonGroup = {
							order = 6,
							type = "group",
							name = L["General Settings"],
							args = {
								baseGroup = {
									order = 1,
									type = "group",
									guiInline = true,
									name = L["Base Settings"],
									args = {
										showBy = {order = 1, name = L["Growth Direction"], type = "select", values = {["UP"] = L["Up"], ["DOWN"] = L["Down"]}},
										spacer1 = {
											order = 2,
											type = "description",
											name = "",
										},
										predict = {order = 3, name = L["Heal Prediction"], desc = L["Show a incomming heal prediction bar on the unitframe. Also display a slightly different colored bar for incoming overheals."], type = "toggle"},
										rangeCheck = {order = 4, name = L["Range Check"], desc = L["Check if you are in range to cast spells on this specific unit."], type = "toggle"},
										hideonnpc = {type = "toggle", order = 5, name = L["Text Toggle On NPC"], desc = L["Power text will be hidden on NPC targets, in addition the name text will be repositioned to the power texts anchor point."], get = function(l)return SV.db.UnitFrames["arena"]["power"].hideonnpc end, set = function(l, m)SV.db.UnitFrames["arena"]["power"].hideonnpc = m;MOD:SetEnemyFrame("arena")end},
										threatEnabled = {type = "toggle", order = 6, name = L["Show Threat"]}
									}
								},
								sizeGroup = {
									order = 2,
									guiInline = true,
									type = "group",
									name = L["Size Settings"],
									args = {
										width = {
											order = 1,
											name = L["Width"],
											type = "range",
											width = "full",
											min = 10,
											max = 500,
											step = 1,
										},
										height = {
											order = 2,
											name = L["Height"],
											type = "range",
											width = "full",
											min = 10,
											max = 500,
											step = 1
										},
									}
								},
								pvp = {
									order = 3,
									guiInline = true,
									type = "group",
									name = L["PVP Indicators"],
									args = {
										enable = {
											type = "toggle",
											order = 1,
											name = L["Enable"],
											get = function(l)return SV.db.UnitFrames.arena.pvp.enable end,
											set = function(l, m)MOD:ChangeDBVar(m, "enable", "arena", "pvp");MOD:SetEnemyFrame("arena", 5)end,
										},
										trinketGroup = {
											order = 2,
											guiInline = true,
											type = "group",
											name = L["Trinkets"],
											get = function(l)return SV.db.UnitFrames.arena.pvp[l[#l]]end,
											set = function(l, m)MOD:ChangeDBVar(m, l[#l], "arena", "pvp");MOD:SetEnemyFrame("arena", 5)end,
											disabled = function() return not SV.db.UnitFrames.arena.pvp.enable end,
											args = {
												trinketPosition = {
													type = "select",
													order = 1,
													name = L["Position"],
													values = {
														["LEFT"] = L["Left"],
														["RIGHT"] = L["Right"]
													}
												},
												trinketSize = {
													order = 2,
													type = "range",
													name = L["Size"],
													min = 10,
													max = 60,
													step = 1
												},
												trinketX = {
													order = 3,
													type = "range",
													name = L["xOffset"],
													min = -60,
													max = 60,
													step = 1
												},
												trinketY = {
													order = 4,
													type = "range",
													name = L["yOffset"],
													min = -60,
													max = 60,
													step = 1
												}
											}
										},
										specGroup = {
											order = 3,
											guiInline = true,
											type = "group",
											name = L["Enemy Specs"],
											get = function(l)return SV.db.UnitFrames.arena.pvp[l[#l]]end,
											set = function(l, m)MOD:ChangeDBVar(m, l[#l], "arena", "pvp");MOD:SetEnemyFrame("arena", 5)end,
											disabled = function() return not SV.db.UnitFrames.arena.pvp.enable end,
											args = {
												specPosition = {
													type = "select",
													order = 1,
													name = L["Position"],
													values = {
														["LEFT"] = L["Left"],
														["RIGHT"] = L["Right"]
													}
												},
												specSize = {
													order = 2,
													type = "range",
													name = L["Size"],
													min = 10,
													max = 60,
													step = 1
												},
												specX = {
													order = 3,
													type = "range",
													name = L["xOffset"],
													min = -60,
													max = 60,
													step = 1
												},
												specY = {
													order = 4,
													type = "range",
													name = L["yOffset"],
													min = -60,
													max = 60,
													step = 1
												}
											}
										}
									}
								},
							}
						},
						misc = SVUIOptions:SetMiscConfigGroup(false, MOD.SetEnemyFrame, "arena", 5),
						health = SVUIOptions:SetHealthConfigGroup(false, MOD.SetEnemyFrame, "arena", 5),
						power = SVUIOptions:SetPowerConfigGroup(false, MOD.SetEnemyFrame, "arena", 5),
						name = SVUIOptions:SetNameConfigGroup(MOD.SetEnemyFrame, "arena", 5),
						portrait = SVUIOptions:SetPortraitConfigGroup(MOD.SetEnemyFrame, "arena", 5),
						buffs = SVUIOptions:SetAuraConfigGroup(false, "buffs", false, MOD.SetEnemyFrame, "arena", 5),
						debuffs = SVUIOptions:SetAuraConfigGroup(false, "debuffs", false, MOD.SetEnemyFrame, "arena", 5),
						castbar = SVUIOptions:SetCastbarConfigGroup(MOD.SetEnemyFrame, "arena", 5)
					}
				},
				tank = {
					name = L["Tank"],
					type = "group",
					order = 15,
					childGroups = "select",
					get = function(l)return SV.db.UnitFrames["tank"][l[#l]]end,
					set = function(l, m)MOD:ChangeDBVar(m, l[#l], "tank");MOD:SetGroupFrame("tank")end,
					args = {
						enable = {type = "toggle", order = 1, name = L["Enable"]},
						resetSettings = {type = "execute", order = 2, name = L["Restore Defaults"], func = function(l, m)MOD:ResetUnitOptions("tank")end},
						spacer1 = {
							order = 3,
							name = "",
							type = "description",
							width = "full",
						},
						spacer2 = {
							order = 4,
							name = "",
							type = "description",
							width = "full",
						},
						commonGroup = {
							order = 5,
							type = "group",
							name = L["General Layout"],
							args = {
								enable = {
									order = 1,
									name = L["Enable Grid Mode"],
									desc = L["Converts frames into symmetrical squares. Ideal for healers."],
									type = "toggle",
									get = function(key) return SV.db.UnitFrames["tank"].grid.enable end,
									set = function(key, value)
										MOD:ChangeDBVar(value, key[#key], "tank", "grid");
										MOD:SetGroupFrame("tank");
										SV.Options.args.UnitFrames.args.commonGroup.args.tank.args.commonGroup.args.sizing = SVUIOptions:SetSizeConfigGroup(value, "tank");
									end,
								},
								invertGroupingOrder = {
									order = 2,
									type = "toggle",
									name = L["Invert Grouping Order"],
									desc = L["Enabling this inverts the grouping order."],
									disabled = function() return not SV.db.UnitFrames["tank"].customSorting end,
								},
								sizing = SVUIOptions:SetSizeConfigGroup(SV.db.UnitFrames.tank.grid.enable, "tank"),
							}
						},
						name = SVUIOptions:SetNameConfigGroup(MOD.SetGroupFrame, "tank"),
						targetsGroup = {
							type = "group",
							name = L["Tank Target"],
							get = function(l)return SV.db.UnitFrames["tank"]["targetsGroup"][l[#l]]end,
							set = function(l, m)MOD:ChangeDBVar(m, l[#l], "tank", "targetsGroup");MOD:SetGroupFrame("tank")end,
							args = {
								enable = {type = "toggle", name = L["Enable"], order = 1},
								width = {order = 2, name = L["Width"], type = "range", min = 10, max = 500, step = 1},
								height = {order = 3, name = L["Height"], type = "range", min = 10, max = 250, step = 1},
								anchorPoint = {type = "select", order = 5, name = L["Anchor Point"], desc = L["What point to anchor to the frame you set to attach to."], values = {TOPLEFT = "TOPLEFT", LEFT = "LEFT", BOTTOMLEFT = "BOTTOMLEFT", RIGHT = "RIGHT", TOPRIGHT = "TOPRIGHT", BOTTOMRIGHT = "BOTTOMRIGHT", CENTER = "CENTER", TOP = "TOP", BOTTOM = "BOTTOM"}},
								xOffset = {order = 6, type = "range", name = L["xOffset"], desc = L["An X offset (in pixels) to be used when anchoring new frames."], min = -500, max = 500, step = 1},
								yOffset = {order = 7, type = "range", name = L["yOffset"], desc = L["An Y offset (in pixels) to be used when anchoring new frames."], min = -500, max = 500, step = 1}
							}
						}
					}
				},
				assist = {
					name = L["Assist"],
					type = "group",
					order = 16,
					childGroups = "select",
					get = function(l)return SV.db.UnitFrames["assist"][l[#l]]end,
					set = function(l, m)MOD:ChangeDBVar(m, l[#l], "assist");MOD:SetGroupFrame("assist")end,
					args = {
						enable = {type = "toggle", order = 1, name = L["Enable"]},
						resetSettings = {type = "execute", order = 2, name = L["Restore Defaults"], func = function(l, m)MOD:ResetUnitOptions("assist")end},
						spacer1 = {
							order = 3,
							name = "",
							type = "description",
							width = "full",
						},
						spacer2 = {
							order = 4,
							name = "",
							type = "description",
							width = "full",
						},
						commonGroup = {
							order = 5,
							type = "group",
							name = L["General Layout"],
							args = {
								enable = {
									order = 1,
									name = L["Enable Grid Mode"],
									desc = L["Converts frames into symmetrical squares. Ideal for healers."],
									type = "toggle",
									get = function(key) return SV.db.UnitFrames["assist"].grid.enable end,
									set = function(key, value)
										MOD:ChangeDBVar(value, key[#key], "assist", "grid");
										MOD:SetGroupFrame("assist");
										SV.Options.args.UnitFrames.args.commonGroup.args.assist.args.commonGroup.args.sizing = SVUIOptions:SetSizeConfigGroup(value, "assist");
									end,
								},
								invertGroupingOrder = {
									order = 2,
									type = "toggle",
									name = L["Invert Grouping Order"],
									desc = L["Enabling this inverts the grouping order."],
									disabled = function() return not SV.db.UnitFrames["assist"].customSorting end,
								},
								sizing = SVUIOptions:SetSizeConfigGroup(SV.db.UnitFrames.assist.grid.enable, "assist"),
							}
						},
						name = SVUIOptions:SetNameConfigGroup(MOD.SetGroupFrame, "assist"),
						targetsGroup = {
							type = "group",
							name = L["Assist Target"],
							get = function(l)return SV.db.UnitFrames["assist"]["targetsGroup"][l[#l]]end,
							set = function(l, m)MOD:ChangeDBVar(m, l[#l], "assist", "targetsGroup");MOD:SetGroupFrame("assist")end,
							args = {
								enable = {type = "toggle", name = L["Enable"], order = 1},
								width = {order = 2, name = L["Width"], type = "range", min = 10, max = 500, step = 1},
								height = {order = 3, name = L["Height"], type = "range", min = 10, max = 250, step = 1},
								anchorPoint = {type = "select", order = 5, name = L["Anchor Point"], desc = L["What point to anchor to the frame you set to attach to."], values = {TOPLEFT = "TOPLEFT", LEFT = "LEFT", BOTTOMLEFT = "BOTTOMLEFT", RIGHT = "RIGHT", TOPRIGHT = "TOPRIGHT", BOTTOMRIGHT = "BOTTOMRIGHT", CENTER = "CENTER", TOP = "TOP", BOTTOM = "BOTTOM"}},
								xOffset = {order = 6, type = "range", name = L["xOffset"], desc = L["An X offset (in pixels) to be used when anchoring new frames."], min = -500, max = 500, step = 1},
								yOffset = {order = 7, type = "range", name = L["yOffset"], desc = L["An Y offset (in pixels) to be used when anchoring new frames."], min = -500, max = 500, step = 1}
							}
						}
					}
				}
			},
		}
	},
}
