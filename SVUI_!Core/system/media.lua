--- Handlers for media functions
-- @submodule SVUI_Core

local _G = _G;
local select  = _G.select;
local unpack  = _G.unpack;
local pairs   = _G.pairs;
local ipairs  = _G.ipairs;
local type    = _G.type;
local print   = _G.print;
local string  = _G.string;
local math    = _G.math;
local table   = _G.table;
local GetTime = _G.GetTime;
local format = string.format;
local floor, modf = math.floor, math.modf;
local twipe, tsort = table.wipe, table.sort;
local NAMEPLATE_FONT      = _G.NAMEPLATE_FONT
local CHAT_FONT_HEIGHTS   = _G.CHAT_FONT_HEIGHTS
local STANDARD_TEXT_FONT  = _G.STANDARD_TEXT_FONT
local UNIT_NAME_FONT      = _G.UNIT_NAME_FONT
local CUSTOM_CLASS_COLORS = _G.CUSTOM_CLASS_COLORS
local RAID_CLASS_COLORS   = _G.RAID_CLASS_COLORS
local UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT  = _G.UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT
---- GET ADDON DATA ----
local SV = select(2, ...)
local SVUILib = Librarian("Registry")
local L = SV.L
local classToken = select(2,UnitClass("player"))
SV.MaxBackdrops = {Pattern = 14, Art = 5, Unit = 17}
---- DEFINE SOUND EFFECTS ----
local SOUND = SV.Sounds;

SOUND:Register("Buttons", [[sound\interface\uchatscrollbutton.ogg]])
SOUND:Register("Levers", [[sound\interface\ui_blizzardstore_buynow.ogg]])
SOUND:Register("Levers", [[sound\doodad\g_levermetalcustom0.ogg]])
SOUND:Register("Levers", [[sound\item\weapons\gun\gunload01.ogg]])
SOUND:Register("Levers", [[sound\item\weapons\gun\gunload02.ogg]])
SOUND:Register("Levers", [[sound\creature\gyrocopter\gyrocoptergearshift2.ogg]])
SOUND:Register("Gears", [[sound\creature\gyrocopter\gyrocoptergearshift3.ogg]])
SOUND:Register("Gears", [[sound\doodad\g_buttonbigredcustom0.ogg]])
SOUND:Register("Sparks", [[sound\doodad\fx_electricitysparkmedium_02.ogg]])
SOUND:Register("Sparks", [[sound\doodad\fx_electrical_zaps01.ogg]])
SOUND:Register("Sparks", [[sound\doodad\fx_electrical_zaps02.ogg]])
SOUND:Register("Sparks", [[sound\doodad\fx_electrical_zaps03.ogg]])
SOUND:Register("Sparks", [[sound\doodad\fx_electrical_zaps04.ogg]])
SOUND:Register("Sparks", [[sound\doodad\fx_electrical_zaps05.ogg]])
SOUND:Register("Static", [[sound\spells\uni_fx_radiostatic_01.ogg]])
SOUND:Register("Static", [[sound\spells\uni_fx_radiostatic_02.ogg]])
SOUND:Register("Static", [[sound\spells\uni_fx_radiostatic_03.ogg]])
SOUND:Register("Static", [[sound\spells\uni_fx_radiostatic_04.ogg]])
SOUND:Register("Static", [[sound\spells\uni_fx_radiostatic_05.ogg]])
SOUND:Register("Static", [[sound\spells\uni_fx_radiostatic_06.ogg]])
SOUND:Register("Static", [[sound\spells\uni_fx_radiostatic_07.ogg]])
SOUND:Register("Static", [[sound\spells\uni_fx_radiostatic_08.ogg]])
SOUND:Register("Wired", [[sound\doodad\goblin_christmaslight_green_01.ogg]])
SOUND:Register("Wired", [[sound\doodad\goblin_christmaslight_green_02.ogg]])
SOUND:Register("Wired", [[sound\doodad\goblin_christmaslight_green_03.ogg]])
SOUND:Register("Phase", [[sound\doodad\be_scryingorb_explode.ogg]])
---- DEFINE SHARED MEDIA ----
local LSM = _G.LibStub("LibSharedMedia-3.0")

LSM:Register("background", "SVUI Default BG", [[Interface\AddOns\SVUI_!Core\assets\backgrounds\DEFAULT]])
LSM:Register("background", "SVUI Transparent BG", [[Interface\AddOns\SVUI_!Core\assets\backgrounds\TRANSPARENT]])
LSM:Register("background", "SVUI Button BG", [[Interface\AddOns\SVUI_!Core\assets\backgrounds\BUTTON]])
LSM:Register("background", "SVUI Model BG", [[Interface\AddOns\SVUI_!Core\assets\backgrounds\MODEL]])

for i = 1, SV.MaxBackdrops.Pattern do
	LSM:Register("background", "SVUI Backdrop "..i, [[Interface\AddOns\SVUI_!Core\assets\backgrounds\pattern\PATTERN]]..i)
end

for i = 1, SV.MaxBackdrops.Art do
	LSM:Register("background", "SVUI Artwork "..i, [[Interface\AddOns\SVUI_!Core\assets\backgrounds\art\ART]]..i)
end

for i = 1, SV.MaxBackdrops.Unit do
	LSM:Register("background", "SVUI UnitBG "..i, [[Interface\AddOns\SVUI_!Core\assets\backgrounds\unit\UNIT-BG]]..i)
	LSM:Register("background", "SVUI SmallUnitBG "..i, [[Interface\AddOns\SVUI_!Core\assets\backgrounds\unit\UNIT-SMALL-BG]]..i)
end

LSM:Register("border", "SVUI Border", [[Interface\AddOns\SVUI_!Core\assets\borders\DEFAULT]])
LSM:Register("border", "SVUI Border 2", [[Interface\BUTTONS\WHITE8X8]])
LSM:Register("border", "SVUI Textured Border", [[Interface\AddOns\SVUI_!Core\assets\borders\TEXTURED]])
LSM:Register("border", "SVUI Inset Shadow", [[Interface\AddOns\SVUI_!Core\assets\borders\INSET]])
LSM:Register("border", "SVUI Shadow Border", [[Interface\AddOns\SVUI_!Core\assets\borders\SHADOW]])

LSM:Register("statusbar", "SVUI BasicBar", [[Interface\AddOns\SVUI_!Core\assets\statusbars\DEFAULT]])
LSM:Register("statusbar", "SVUI MultiColorBar", [[Interface\AddOns\SVUI_!Core\assets\statusbars\GRADIENT]])
LSM:Register("statusbar", "SVUI SmoothBar", [[Interface\AddOns\SVUI_!Core\assets\statusbars\SMOOTH]])
LSM:Register("statusbar", "SVUI PlainBar", [[Interface\AddOns\SVUI_!Core\assets\statusbars\FLAT]])
LSM:Register("statusbar", "SVUI FancyBar", [[Interface\AddOns\SVUI_!Core\assets\statusbars\TEXTURED]])
LSM:Register("statusbar", "SVUI GlossBar", [[Interface\AddOns\SVUI_!Core\assets\statusbars\GLOSS]])
LSM:Register("statusbar", "SVUI GlowBar", [[Interface\AddOns\SVUI_!Core\assets\statusbars\GLOWING]])
LSM:Register("statusbar", "SVUI LazerBar", [[Interface\AddOns\SVUI_!Core\assets\statusbars\LAZER]])

LSM:Register("sound", "Whisper Alert", [[Interface\AddOns\SVUI_!Core\assets\sounds\whisper.mp3]])
LSM:Register("sound", "Mention Alert", [[Interface\AddOns\SVUI_!Core\assets\sounds\whisper.mp3]])
LSM:Register("sound", "Toasty", [[Interface\AddOns\SVUI_!Core\assets\sounds\toasty.mp3]])

LSM:Register("font", "SVUI Default Font", [[Interface\AddOns\SVUI_!Core\assets\fonts\Default.ttf]],LSM.LOCALE_BIT_ruRU+LSM.LOCALE_BIT_western)
LSM:Register("font", "SVUI Pixel Font", [[Interface\AddOns\SVUI_!Core\assets\fonts\Pixel.ttf]],LSM.LOCALE_BIT_ruRU+LSM.LOCALE_BIT_western)
LSM:Register("font", "SVUI Caps Font", [[Interface\AddOns\SVUI_!Core\assets\fonts\Caps.ttf]],LSM.LOCALE_BIT_ruRU+LSM.LOCALE_BIT_western)
LSM:Register("font", "SVUI Classic Font", [[Interface\AddOns\SVUI_!Core\assets\fonts\Classic.ttf]])
LSM:Register("font", "SVUI Combat Font", [[Interface\AddOns\SVUI_!Core\assets\fonts\Combat.ttf]])
LSM:Register("font", "SVUI Dialog Font", [[Interface\AddOns\SVUI_!Core\assets\fonts\Dialog.ttf]])
LSM:Register("font", "SVUI Number Font", [[Interface\AddOns\SVUI_!Core\assets\fonts\Numbers.ttf]])
LSM:Register("font", "SVUI Zone Font", [[Interface\AddOns\SVUI_!Core\assets\fonts\Zone.ttf]])
LSM:Register("font", "SVUI Flash Font", [[Interface\AddOns\SVUI_!Core\assets\fonts\Flash.ttf]])
LSM:Register("font", "SVUI Alert Font", [[Interface\AddOns\SVUI_!Core\assets\fonts\Alert.ttf]])
LSM:Register("font", "SVUI Narrator Font", [[Interface\AddOns\SVUI_!Core\assets\fonts\Narrative.ttf]])
LSM:Register("font", "Open-Dyslexic", [[Interface\AddOns\SVUI_!Core\assets\fonts\Dyslexic.ttf]])
---- CREATE AND POPULATE MEDIA DATA ----
do
	local cColor = RAID_CLASS_COLORS[classToken]
	local r1,g1,b1 = cColor.r,cColor.g,cColor.b
	local r2,g2,b2 = cColor.r*.25, cColor.g*.25, cColor.b*.25
	local ir1,ig1,ib1 = (1 - r1), (1 - g1), (1 - b1)
	local ir2,ig2,ib2 = (1 - cColor.r)*.25, (1 - cColor.g)*.25, (1 - cColor.b)*.25

	SV.mediadefaults = {
		["extended"] = {},
		["shared"] = {
			["font"] = {
				["default"]     = {file = "SVUI Default Font",  size = 12,  outline = "OUTLINE"},
				["dialog"]      = {file = "SVUI Default Font",  size = 12,  outline = "OUTLINE"},
				["title"]       = {file = "SVUI Default Font",  size = 16,  outline = "OUTLINE"},
				["number"]      = {file = "SVUI Number Font",   size = 11,  outline = "OUTLINE"},
				["number_big"]  = {file = "SVUI Number Font",   size = 18,  outline = "OUTLINE"},
				["header"]      = {file = "SVUI Number Font",   size = 18,  outline = "OUTLINE"},
				["combat"]      = {file = "SVUI Combat Font",   size = 64,  outline = "OUTLINE"},
				["alert"]       = {file = "SVUI Alert Font",    size = 20,  outline = "OUTLINE"},
				["flash"]      	= {file = "SVUI Flash Font",    size = 18,  outline = "OUTLINE"},
				["zone"]      	= {file = "SVUI Zone Font",     size = 16,  outline = "OUTLINE"},
				["caps"]      	= {file = "SVUI Caps Font",     size = 12,  outline = "OUTLINE"},
				["aura"]      	= {file = "SVUI Number Font",   size = 10,  outline = "OUTLINE"},
				["data"]      	= {file = "SVUI Number Font",   size = 11,  outline = "OUTLINE"},
				["narrator"]    = {file = "SVUI Narrator Font", size = 12,  outline = "OUTLINE"},
				["lootdialog"]  = {file = "SVUI Default Font",  size = 14,  outline = "OUTLINE"},
				["lootnumber"]  = {file = "SVUI Number Font",   size = 11,  outline = "OUTLINE"},
				["rolldialog"]  = {file = "SVUI Default Font",  size = 14,  outline = "OUTLINE"},
				["rollnumber"]  = {file = "SVUI Number Font",   size = 11,  outline = "OUTLINE"},
				["tipdialog"]   = {file = "SVUI Default Font",  size = 12,  outline = "NONE"},
				["tipheader"]   = {file = "SVUI Default Font",  size = 14,  outline = "NONE"},
				["pixel"]       = {file = "SVUI Pixel Font",    size = 8,   outline = "MONOCHROMEOUTLINE"},
			},
			["statusbar"] = {
				["default"]   	= {file = "SVUI BasicBar",  	offset = 0},
				["gradient"]  	= {file = "SVUI MultiColorBar", offset = 0},
				["smooth"]    	= {file = "SVUI SmoothBar",  	offset = 0},
				["flat"]      	= {file = "SVUI PlainBar",  	offset = 0},
				["textured"]  	= {file = "SVUI FancyBar",  	offset = 0},
				["gloss"]     	= {file = "SVUI GlossBar",  	offset = 0},
				["glow"]      	= {file = "SVUI GlowBar",  		offset = 2},
				["lazer"]     	= {file = "SVUI LazerBar",  	offset = 10},
			},
			["background"] = {
				["default"]     = {file = "SVUI Default BG",  		size = 0, tiled = false},
				["transparent"] = {file = "SVUI Transparent BG",	size = 0, tiled = false},
				["button"]      = {file = "SVUI Button BG",  		size = 0, tiled = false},
				["pattern"]     = {file = "SVUI Backdrop 1",  		size = 0, tiled = false},
				["premium"]     = {file = "SVUI Artwork 1",  		size = 0, tiled = false},
				["model"]     	= {file = "SVUI Model BG",  		size = 0, tiled = false},
				["unitlarge"]   = {file = "SVUI UnitBG 1",  		size = 0, tiled = false},
				["unitsmall"]   = {file = "SVUI SmallUnitBG 1",  	size = 0, tiled = false},
			},
			["border"] = {
				["default"] 	= {file = "SVUI Border", 		  	size = 1},
				["transparent"] = {file = "SVUI Border", 			size = 1},
				["button"]      = {file = "SVUI Border 2", 			size = 1},
				["pattern"]     = {file = "SVUI Border", 		size = 1},
				["premium"]     = {file = "SVUI Textured Border", 	size = 15},
				["model"]     	= {file = "SVUI Border", 		size = 1},
				["shadow"]      = {file = "SVUI Shadow Border",   	size = 3},
				["inset"]       = {file = "SVUI Inset Shadow",   	size = 6},
				["unitlarge"]   = {file = "SVUI Border 2",  		size = 0},
				["unitsmall"]   = {file = "SVUI Border 2",  		size = 0},
			},
		},
		["font"] = {
			["default"]   	= [[Interface\AddOns\SVUI_!Core\assets\fonts\Default.ttf]],
			["dialog"]    	= [[Interface\AddOns\SVUI_!Core\assets\fonts\Default.ttf]],
			["number"]    	= [[Interface\AddOns\SVUI_!Core\assets\fonts\Numbers.ttf]],
			["combat"]    	= [[Interface\AddOns\SVUI_!Core\assets\fonts\Combat.ttf]],
			["zone"]      	= [[Interface\AddOns\SVUI_!Core\assets\fonts\Zone.ttf]],
			["alert"]     	= [[Interface\AddOns\SVUI_!Core\assets\fonts\Alert.ttf]],
			["caps"]      	= [[Interface\AddOns\SVUI_!Core\assets\fonts\Caps.ttf]],
			["narrator"]  	= [[Interface\AddOns\SVUI_!Core\assets\fonts\Narrative.ttf]],
			["flash"]     	= [[Interface\AddOns\SVUI_!Core\assets\fonts\Flash.ttf]],
			["pixel"]     	= [[Interface\AddOns\SVUI_!Core\assets\fonts\Pixel.ttf]],
		},
		["statusbar"] = {
			["default"]   	= [[Interface\AddOns\SVUI_!Core\assets\statusbars\DEFAULT]],
			["gradient"]  	= [[Interface\AddOns\SVUI_!Core\assets\statusbars\GRADIENT]],
			["smooth"]    	= [[Interface\AddOns\SVUI_!Core\assets\statusbars\SMOOTH]],
			["flat"]      	= [[Interface\AddOns\SVUI_!Core\assets\statusbars\FLAT]],
			["textured"]  	= [[Interface\AddOns\SVUI_!Core\assets\statusbars\TEXTURED]],
			["gloss"]     	= [[Interface\AddOns\SVUI_!Core\assets\statusbars\GLOSS]],
			["glow"]      	= [[Interface\AddOns\SVUI_!Core\assets\statusbars\GLOWING]],
			["lazer"]     	= [[Interface\AddOns\SVUI_!Core\assets\statusbars\LAZER]],
		},
		["background"] = {
			["default"] 	= [[Interface\AddOns\SVUI_!Core\assets\backgrounds\DEFAULT]],
			["transparent"] = [[Interface\AddOns\SVUI_!Core\assets\backgrounds\TRANSPARENT]],
			["button"]      = [[Interface\AddOns\SVUI_!Core\assets\backgrounds\BUTTON]],
			["pattern"]     = [[Interface\AddOns\SVUI_!Core\assets\backgrounds\pattern\PATTERN1]],
			["premium"]     = [[Interface\AddOns\SVUI_!Core\assets\backgrounds\art\ART1]],
			["model"]     	= [[Interface\AddOns\SVUI_!Core\assets\backgrounds\MODEL]],
			["unitlarge"] 	= [[Interface\AddOns\SVUI_!Core\assets\backgrounds\unit\UNIT-BG1]],
			["unitsmall"] 	= [[Interface\AddOns\SVUI_!Core\assets\backgrounds\unit\UNIT-SMALL-BG1]],
			["checkbox"]    = [[Interface\AddOns\SVUI_!Core\assets\buttons\CHECK-BG]],
			["dark"]    	= [[Interface\AddOns\SVUI_!Core\assets\backgrounds\DARK]],
		},
		["border"] = {
			["default"] 	= [[Interface\AddOns\SVUI_!Core\assets\borders\DEFAULT]],
			["button"]      = [[Interface\AddOns\SVUI_!Core\assets\borders\DEFAULT]],
			["pattern"]     = [[Interface\AddOns\SVUI_!Core\assets\borders\DEFAULT]],
			["premium"]     = [[Interface\AddOns\SVUI_!Core\assets\borders\TEXTURED]],
			["model"]     	= [[Interface\AddOns\SVUI_!Core\assets\borders\DEFAULT]],
			["shadow"]      = [[Interface\AddOns\SVUI_!Core\assets\borders\SHADOW]],
			["inset"]       = [[Interface\AddOns\SVUI_!Core\assets\borders\INSET]],
			["unitlarge"] 	= [[Interface\BUTTONS\WHITE8X8]],
			["unitsmall"] 	= [[Interface\BUTTONS\WHITE8X8]],
			["checkbox"] 	= [[Interface\AddOns\SVUI_!Core\assets\borders\DEFAULT]],
		},
		["color"] = {
			["default"]     = {0.15, 0.15, 0.15, 1},
			["secondary"]   = {0.2, 0.2, 0.2, 1},
			["button"]      = {0.2, 0.2, 0.2, 1},
			["special"]     = {0.37, 0.32, 0.29, 1},
			["specialdark"] = {.23, .22, .21, 1},
			["unique"]      = {0.32, 0.258, 0.21, 1},
			["paper"]     	= {0.77, 0.72, 0.69, 1},
			["dusty"]   	= {.28, .27, .26, 1},
			["class"]       = {r1, g1, b1, 1},
			["bizzaro"]     = {ir1, ig1, ib1, 1},
			["medium"]      = {0.47, 0.47, 0.47},
			["dark"]        = {0.1, 0.1, 0.1, 1},
			["darkest"]     = {0, 0, 0, 1},
			["light"]       = {0.95, 0.95, 0.95, 1},
			["light2"]      = {0.65, 0.65, 0.65, 1},
			["lightgrey"]   = {0.32, 0.35, 0.38, 1},
			["highlight"]   = {0.28, 0.75, 1, 1},
			["checked"]     = {0.25, 0.9, 0.08, 1},
			["green"]       = {0.25, 0.9, 0.08, 1},
			["blue"]        = {0.08, 0.25, 0.82, 1},
			["tan"]         = {0.4, 0.32, 0.23, 1},
			["red"]         = {0.9, 0.08, 0.08, 1},
			["yellow"]      = {1, 1, 0, 1},
			["gold"]        = {1, 0.68, 0.1, 1},
			["transparent"] = {0, 0, 0, 0.5},
			["hinted"]      = {0, 0, 0, 0.35},
			["invisible"]   = {0, 0, 0, 0},
			["white"]       = {1, 1, 1, 1},
		},
		["bordercolor"] = {
			["default"]     = {0, 0, 0, 1},
			["class"]       = {r1, g1, b1, 1},
			["checkbox"]    = {0.1, 0.1, 0.1, 1},
		},
		["gradient"]  = {
			["default"]   	= {"VERTICAL", 0.08, 0.08, 0.08, 0.22, 0.22, 0.22},
			["secondary"]  	= {"VERTICAL", 0.08, 0.08, 0.08, 0.22, 0.22, 0.22},
			["button"]   	= {"VERTICAL", 0.08, 0.08, 0.08, 0.22, 0.22, 0.22},
			["special"]   	= {"VERTICAL", 0.33, 0.25, 0.13, 0.47, 0.39, 0.27},
			["specialdark"] = {"VERTICAL", 0.23, 0.15, 0.03, 0.33, 0.25, 0.13},
			["paper"]   	= {"VERTICAL", 0.53, 0.45, 0.33, 0.77, 0.72, 0.69},
			["dusty"] 		= {"VERTICAL", 0.12, 0.11, 0.1, 0.22, 0.21, 0.2},
			["class"]     	= {"VERTICAL", r2, g2, b2, r1, g1, b1},
			["bizzaro"]   	= {"VERTICAL", ir2, ig2, ib2, ir1, ig1, ib1},
			["medium"]    	= {"VERTICAL", 0.22, 0.22, 0.22, 0.47, 0.47, 0.47},
			["dark"]      	= {"VERTICAL", 0.02, 0.02, 0.02, 0.22, 0.22, 0.22},
			["darkest"]   	= {"VERTICAL", 0.15, 0.15, 0.15, 0, 0, 0},
			["darkest2"]  	= {"VERTICAL", 0, 0, 0, 0.12, 0.12, 0.12},
			["light"]     	= {"VERTICAL", 0.65, 0.65, 0.65, 0.95, 0.95, 0.95},
			["light2"]    	= {"VERTICAL", 0.95, 0.95, 0.95, 0.65, 0.65, 0.65},
			["highlight"] 	= {"VERTICAL", 0.3, 0.8, 1, 0.1, 0.9, 1},
			["checked"]   	= {"VERTICAL", 0.08, 0.9, 0.25, 0.25, 0.9, 0.08},
			["green"]     	= {"VERTICAL", 0.08, 0.9, 0.25, 0.25, 0.9, 0.08},
			["red"]       	= {"VERTICAL", 0.5, 0, 0, 0.9, 0.08, 0.08},
			["yellow"]    	= {"VERTICAL", 1, 0.3, 0, 1, 1, 0},
			["tan"]       	= {"VERTICAL", 0.15, 0.08, 0, 0.37, 0.22, 0.1},
			["inverse"]   	= {"VERTICAL", 0.25, 0.25, 0.25, 0.12, 0.12, 0.12},
			["icon"]      	= {"VERTICAL", 0.5, 0.53, 0.55, 0.8, 0.8, 1},
			["white"]     	= {"VERTICAL", 0.75, 0.75, 0.75, 1, 1, 1},
		},
		["button"] = {
			["check"]     	= [[Interface\AddOns\SVUI_!Core\assets\buttons\CHECK]],
			["checkbg"]     = [[Interface\AddOns\SVUI_!Core\assets\buttons\CHECK-BG]],
			["uncheck"]     = [[Interface\AddOns\SVUI_!Core\assets\buttons\CHECK-DISABLED]],
			["round"]     	= [[Interface\AddOns\SVUI_!Core\assets\buttons\ROUND-BORDER]],
			["roundbg"]     = [[Interface\AddOns\SVUI_!Core\assets\buttons\ROUND-BG]],
			["scrollup"]    = [[Interface\AddOns\SVUI_!Core\assets\buttons\SCROLLBAR-UP]],
			["scrolldown"]  = [[Interface\AddOns\SVUI_!Core\assets\buttons\SCROLLBAR-DOWN]],
			["knob"]     	= [[Interface\AddOns\SVUI_!Core\assets\buttons\SCROLLBAR-KNOB]],
			["option"] 		= [[Interface\AddOns\SVUI_!Core\assets\buttons\SETUP-OPTION]],
			["arrow"] 		= [[Interface\AddOns\SVUI_!Core\assets\buttons\SETUP-ARROW]],
			["radio"] 		= [[Interface\AddOns\SVUI_!Core\assets\buttons\RADIO]],
		},
		["icon"] = {
			["default"]     = [[Interface\AddOns\SVUI_!Core\assets\icons\SVUI]],
			["theme"]       = [[Interface\AddOns\SVUI_!Core\assets\icons\THEME]],
			["vs"]          = [[Interface\AddOns\SVUI_!Core\assets\icons\VS]],
			["close"]       = [[Interface\AddOns\SVUI_!Core\assets\icons\CLOSE]],
			["star"]        = [[Interface\AddOns\SVUI_!Core\assets\icons\FAVORITE-STAR]],
			["info"]        = [[Interface\AddOns\SVUI_!Core\assets\icons\FAVORITE-STAR]],
			["move_up"]     = [[Interface\AddOns\SVUI_!Core\assets\icons\MOVE-UP]],
			["move_down"]   = [[Interface\AddOns\SVUI_!Core\assets\icons\MOVE-DOWN]],
			["move_left"]   = [[Interface\AddOns\SVUI_!Core\assets\icons\MOVE-LEFT]],
			["move_right"]  = [[Interface\AddOns\SVUI_!Core\assets\icons\MOVE-RIGHT]],
			["exitIcon"] 	= [[Interface\AddOns\SVUI_!Core\assets\icons\EXIT]]
		},
		["dock"] = {
			["durabilityLabel"] 	= [[Interface\AddOns\SVUI_!Core\assets\textures\Dock\LABEL-DUR]],
			["reputationLabel"] 	= [[Interface\AddOns\SVUI_!Core\assets\textures\Dock\LABEL-REP]],
			["experienceLabel"] 	= [[Interface\AddOns\SVUI_!Core\assets\textures\Dock\LABEL-XP]],
			["artifactLabel"] 		= [[Interface\AddOns\SVUI_!Core\assets\textures\Dock\LABEL-ART]],
            ["azeriteLabel"] 		= [[Interface\AddOns\SVUI_!Core\assets\textures\Dock\LABEL-ART]],	
			["sizeIcon"] 			= [[Interface\AddOns\SVUI_!Core\assets\textures\Dock\DOCK-ICON-SIZE]],
			["optionsIcon"] 		= [[Interface\AddOns\SVUI_!Core\assets\textures\Dock\DOCK-ICON-OPTIONS]],
			["breakStuffIcon"] 		= [[Interface\AddOns\SVUI_!Core\assets\textures\Dock\DOCK-ICON-BREAKSTUFF]],
			["hearthIcon"] 			= [[Interface\AddOns\SVUI_!Core\assets\textures\Dock\DOCK-ICON-HEARTH]],
			["raidToolIcon"] 		= [[Interface\AddOns\SVUI_!Core\assets\textures\Dock\DOCK-ICON-RAIDTOOL]],
			["garrisonToolIcon"] 	= [[Interface\AddOns\SVUI_!Core\assets\textures\Dock\DOCK-ICON-GARRISON]],
			["specSwapIcon"] 		= [[Interface\AddOns\SVUI_!Core\assets\textures\Dock\DOCK-ICON-SPECSWAP]],
			["powerIcon"] 			= [[Interface\AddOns\SVUI_!Core\assets\textures\Dock\DOCK-ICON-POWER]],
			["professionIconFile"] 	= [[Interface\AddOns\SVUI_!Core\assets\textures\Dock\PROFESSIONS]],
			["professionIconCoords"]= {
				[171] 	= {0,0.25,0,0.25}, 				-- PRO-ALCHEMY
			    [794] 	= {0.25,0.5,0,0.25,80451}, 		-- PRO-ARCHAELOGY
			    [164] 	= {0.5,0.75,0,0.25}, 			-- PRO-BLACKSMITH
			    [185] 	= {0.75,1,0,0.25,818,67097}, 	-- PRO-COOKING
			    [333] 	= {0,0.25,0.25,0.5,13262}, 		-- PRO-ENCHANTING
			    [202] 	= {0.25,0.5,0.25,0.5}, 			-- PRO-ENGINEERING
			    [129] 	= {0.5,0.75,0.25,0.5}, 			-- PRO-FIRSTAID
			    [773] 	= {0,0.25,0.5,0.75,51005}, 		-- PRO-INSCRIPTION
			    [755] 	= {0.25,0.5,0.5,0.75,31252},	-- PRO-JEWELCRAFTING
			    [165] 	= {0.5,0.75,0.5,0.75}, 			-- PRO-LEATHERWORKING
			    [186] 	= {0.75,1,0.5,0.75}, 			-- PRO-MINING
			    [197] 	= {0.25,0.5,0.75,1}, 			-- PRO-TAILORING
			},
			["sparks"] = {
				[[Interface\AddOns\SVUI_!Core\assets\textures\Dock\DOCK-SPARKS-1]],
				[[Interface\AddOns\SVUI_!Core\assets\textures\Dock\DOCK-SPARKS-2]],
				[[Interface\AddOns\SVUI_!Core\assets\textures\Dock\DOCK-SPARKS-3]],
			},
		},
		["backdrop"] = {
			["default"] = {
				bgFile = [[Interface\AddOns\SVUI_!Core\assets\backgrounds\DEFAULT]],
			    tile = false,
			    tileSize = 0,
			    edgeFile = [[Interface\AddOns\SVUI_!Core\assets\borders\DEFAULT]],
			    edgeSize = 1,
			    insets =
			    {
			        left = 0,
			        right = 0,
			        top = 0,
			        bottom = 0,
			    },
			},
			["button"] = {
				bgFile = [[Interface\AddOns\SVUI_!Core\assets\backgrounds\BUTTON]],
			    tile = false,
			    tileSize = 0,
			    edgeFile = [[Interface\BUTTONS\WHITE8X8]],
			    edgeSize = 1,
			    insets =
			    {
			        left = 0,
			        right = 0,
			        top = 0,
			        bottom = 0,
			    },
			},
			["pattern"] = {
				bgFile = [[Interface\AddOns\SVUI_!Core\assets\backgrounds\pattern\PATTERN1]],
			    tile = false,
			    tileSize = 0,
			    edgeFile = [[Interface\AddOns\SVUI_!Core\assets\borders\TEXTURED]],
					edgeSize = 1,
			    insets =
			    {
			        left = 0,
			        right = 0,
			        top = 0,
			        bottom = 0,
			    },
			},
			["premium"] = {
				bgFile = [[Interface\AddOns\SVUI_!Core\assets\backgrounds\art\ART1]],
			    tile = false,
			    tileSize = 0,
			    edgeFile = [[Interface\AddOns\SVUI_!Core\assets\borders\TEXTURED]],
			    edgeSize = 15,
			    insets =
			    {
							left = 3,
							right = 3,
							top = 3,
							bottom = 3,
			    },
			},
			["model"] = {
				bgFile = [[Interface\AddOns\SVUI_!Core\assets\backgrounds\MODEL]],
			    tile = false,
			    tileSize = 0,
			    edgeFile = [[Interface\AddOns\SVUI_!Core\assets\borders\DEFAULT]],
					edgeSize = 1,
			    insets =
			    {
			        left = 0,
			        right = 0,
			        top = 0,
			        bottom = 0,
			    },
			},
			["buttonred"] = {
				bgFile = [[Interface\AddOns\SVUI_!Core\assets\backgrounds\BUTTON]],
			    tile = false,
			    tileSize = 0,
			    edgeFile = [[Interface\AddOns\SVUI_!Core\assets\borders\DEFAULT]],
			    edgeSize = 1,
			    insets =
			    {
			        left = 0,
			        right = 0,
			        top = 0,
			        bottom = 0,
			    },
			},
			["aura"] = {
				bgFile = [[Interface\BUTTONS\WHITE8X8]],
			    tile = false,
			    tileSize = 0,
			    edgeFile = [[Interface\AddOns\SVUI_!Core\assets\borders\SHADOW]],
			    edgeSize = 1,
			    insets =
			    {
			        left = 1,
			        right = 1,
			        top = 1,
			        bottom = 1,
			    },
			},
			["glow"] = {
				bgFile = [[Interface\BUTTONS\WHITE8X8]],
			    tile = false,
			    tileSize = 0,
			    edgeFile = [[Interface\AddOns\SVUI_!Core\assets\borders\SHADOW]],
			    edgeSize = 3,
			    insets =
			    {
			        left = 0,
			        right = 0,
			        top = 0,
			        bottom = 0,
			    },
			},
			["tooltip"] = {
				bgFile = [[Interface\DialogFrame\UI-DialogBox-Background]],
			    tile = false,
			    tileSize = 0,
			    edgeFile = [[Interface\AddOns\SVUI_!Core\assets\textures\EMPTY]],
			    edgeSize = 1,
			    insets =
			    {
			        left = 0,
			        right = 0,
			        top = 0,
			        bottom = 0,
			    },
			},
			["outline"] = {
				bgFile = [[Interface\AddOns\SVUI_!Core\assets\textures\EMPTY]],
			    tile = false,
			    tileSize = 0,
			    edgeFile = [[Interface\AddOns\SVUI_!Core\assets\borders\DEFAULT]],
			    edgeSize = 1,
			    insets =
			    {
			        left = 0,
			        right = 0,
			        top = 0,
			        bottom = 0,
			    },
			},
			["shadowoutline"] = {
				bgFile = [[Interface\AddOns\SVUI_!Core\assets\textures\EMPTY]],
			    tile = false,
			    tileSize = 0,
			    edgeFile = [[Interface\AddOns\SVUI_!Core\assets\borders\SHADOW]],
			    edgeSize = 3,
			    insets =
			    {
			        left = 0,
			        right = 0,
			        top = 0,
			        bottom = 0,
			    },
			},
			["darkened"] = {
				bgFile = [[Interface\AddOns\SVUI_!Core\assets\backgrounds\DARK]],
			    tile = false,
			    tileSize = 0,
			    edgeFile = [[Interface\AddOns\SVUI_!Core\assets\borders\SHADOW]],
			    edgeSize = 3,
			    insets =
			    {
			        left = 0,
			        right = 0,
			        top = 0,
			        bottom = 0,
			    },
			},
		}
	};
end
---- SOME CORE VARS ----
SV.DialogFontDefault = "SVUI Dialog Font";
if(GetLocale() ~= "enUS") then
	SV.DialogFontDefault = "SVUI Default Font";
end
SV.SplashImage 	= [[Interface\AddOns\SVUI_!Core\assets\textures\SPLASH]];
SV.BaseTexture 	= [[Interface\AddOns\SVUI_!Core\assets\backgrounds\DEFAULT]];
SV.NoTexture 	  = [[Interface\AddOns\SVUI_!Core\assets\textures\EMPTY]];

---------------------------------------------------------------------
-- Returns a color value based on percentages.
-- @function ColorGradient
-- @tparam number percentage The needed gradient percent.
-- @param ... (vararg) remaining arguments are up to 3 sets of numeric color values (r,g,b).
-- @return red value, green value, blue value
-- @usage SV:ColorGradient(50,1,0,0,1,1,0,0,1,0)
---------------------------------------------------------------------

function SV:ColorGradient(percentage, ...)
	if percentage >= 1 then
		return select(select('#', ...) - 2, ...)
	elseif percentage <= 0 then
		return ...
	end
	local num = select('#', ...) / 3
	local segment, relative = modf(percentage*(num-1))
	local r1, g1, b1, r2, g2, b2 = select((segment*3)+1, ...)
	local rOut = r1 + (r2-r1)*relative;
	local gOut = g1 + (g2-g1)*relative;
	local bOut = b1 + (b2-b1)*relative;
	return rOut, gOut, bOut
end

---------------------------------------------------------------------
-- Returns a hexadecimal color value.
-- @function HexColor
-- @tparam number red Color, red value.
-- @tparam number green Color, green value.
-- @tparam number blue Color, blue value.
-- @return Hexadecimal string color
-- @usage SV:HexColor(0.1, 0.2, 0.3)
---------------------------------------------------------------------

function SV:HexColor(red, green, blue)
	local r,g,b;
	if red and type(red) == "string" then
		local t
		if(self.media) then
			t = self.media.color[red]
			if((not t) and (self.media.extended and self.media.extended.unitframes)) then
				t = self.media.extended.unitframes[red]
			end
		end
		if t then
			r,g,b = t[1],t[2],t[3]
		else
			r,g,b = 0,0,0
		end
	else
		r = type(red) == "number" and red or 0;
		g = type(green) == "number" and green or 0;
		b = type(blue) == "number" and blue or 0;
	end
	r = (r < 0 or r > 1) and 0 or (r * 255)
	g = (g < 0 or g > 1) and 0 or (g * 255)
	b = (b < 0 or b > 1) and 0 or (b * 255)
	local hexString = ("%02x%02x%02x"):format(r,g,b)
	return hexString
end

---- ALTERING GLOBAL FONTS ----

local function UpdateChatFontSizes()
	_G.CHAT_FONT_HEIGHTS[1] = 8
	_G.CHAT_FONT_HEIGHTS[2] = 9
	_G.CHAT_FONT_HEIGHTS[3] = 10
	_G.CHAT_FONT_HEIGHTS[4] = 11
	_G.CHAT_FONT_HEIGHTS[5] = 12
	_G.CHAT_FONT_HEIGHTS[6] = 13
	_G.CHAT_FONT_HEIGHTS[7] = 14
	_G.CHAT_FONT_HEIGHTS[8] = 15
	_G.CHAT_FONT_HEIGHTS[9] = 16
	_G.CHAT_FONT_HEIGHTS[10] = 17
	_G.CHAT_FONT_HEIGHTS[11] = 18
	_G.CHAT_FONT_HEIGHTS[12] = 19
	_G.CHAT_FONT_HEIGHTS[13] = 20
end

hooksecurefunc("FCF_ResetChatWindows", UpdateChatFontSizes)

local function ChangeGlobalFonts()
	local fontsize = SV.media.shared.font.default.size;
	STANDARD_TEXT_FONT = LSM:Fetch("font", SV.media.shared.font.default.file);
	UNIT_NAME_FONT = LSM:Fetch("font", SV.media.shared.font.caps.file);
	NAMEPLATE_FONT = STANDARD_TEXT_FONT
	UpdateChatFontSizes()
	UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT = fontsize
end

---- FONT TEMPLATING METHODS ----

local ManagedFonts = {};

---------------------------------------------------------------------
-- Adds a font object to the custom SVUI font manager.
-- @function FontManager
-- @param obj Font object.
-- @tparam string template Internal name of the media-font to be assigned.
-- @param abstract A multi-use flag.
-- @param sizeMod Font size override.
-- @param styleOverride Outline override.
-- @tparam number red Color, red value.
-- @tparam number green Color, green value.
-- @tparam number blue Color, blue value.
-- @usage SV:FontManager(FontObject, 'default', false, false, 'OUTLINE', 1, 1, 1)
---------------------------------------------------------------------

function SV:FontManager(obj, template, abstract, sizeMod, styleOverride, red, green, blue)
	-- @todo document this better
	if not obj then return end
	template = template or "default";
	local info = SV.media.shared.font[template] or SV.media.shared.font.default;
	if(not info) then return end

	local isSystemFont = false;
	if(abstract and (abstract == 'SYSTEM')) then
		isSystemFont = true;
	end

	local file = SV.media.font[template] or SV.media.font.default;
	local size = info.size;
	local outline = info.outline;

	if(styleOverride) then
		obj.___fontOutline = styleOverride;
		outline = styleOverride;
	end

	obj.___fontSizeMod = sizeMod or 0;
	obj:SetFont(file, (size + obj.___fontSizeMod), outline)

	if(abstract == 'SHADOW') then
		obj:SetShadowColor(0, 0, 0, 0.75)
		obj:SetShadowOffset(2, -2)
	elseif(not isSystemFont) then
		if((not info.outline) or info.outline ~= "NONE") then
			obj:SetShadowColor(0, 0, 0, 0)
		elseif(info.outline and info.outline == "NONE") then
			obj:SetShadowColor(0, 0, 0, 0.75)
		else
			obj:SetShadowColor(0, 0, 0, 0.2)
		end
		if(not obj.noShadowOffset) then
			obj:SetShadowOffset(1, -1)
		else
			obj:SetShadowOffset(0, 0)
		end
		obj:SetJustifyH(abstract or "CENTER")
		obj:SetJustifyV("MIDDLE")
	end

	if(red and green and blue) then
		obj:SetTextColor(red, green, blue);
	end

	if(not ManagedFonts[template]) then
		ManagedFonts[template] = {}
	end

	ManagedFonts[template][obj] = true
end

local function _shadowFont(globalName, template, sizeMod, styleOverride, cR, cG, cB)
	if(not template) then return end
	if(not _G[globalName]) then return end
	styleOverride = styleOverride or "NONE"
	SV:FontManager(_G[globalName], template, "SHADOW", sizeMod, styleOverride, cR, cG, cB);
end

local function _alterFont(globalName, template, sizeMod, styleOverride, cR, cG, cB)
	if(not template) then return end
	if(not _G[globalName]) then return end
	styleOverride = styleOverride or "NONE"
	SV:FontManager(_G[globalName], template, "SYSTEM", sizeMod, styleOverride, cR, cG, cB);
end

local function ChangeSystemFonts()
	_shadowFont("GameFontNormal", "default", 0, "NONE")
	_alterFont("GameFontWhite", "default", 0, 'OUTLINE', 1, 1, 1)
	_alterFont("GameFontWhiteSmall", "default", 0, 'NONE', 1, 1, 1)
	_alterFont("GameFontBlack", "default", 0, 'NONE', 0, 0, 0)
	_alterFont("GameFontBlackSmall", "default", -1, 'NONE', 0, 0, 0)
	_alterFont("GameFontNormalMed2", "default", 2)
	_alterFont("Game15Font_o1", "number", 1, "OUTLINE")
	_alterFont("GameFontNormalLarge", "default")
	_alterFont("GameFontNormalLargeOutline", "default")
	_alterFont("GameFontHighlightSmall", "default")
	_alterFont("GameFontHighlight", "default", 1)
	_alterFont("GameFontHighlightLeft", "default", 1)
	_alterFont("GameFontHighlightRight", "default", 1)
	_alterFont("GameFontHighlightLarge2", "default", 2)
	_alterFont("MailFont_Large", "default", 3)
	_alterFont("SystemFont_Med1", "default")
	_alterFont("SystemFont_Med3", "default")
	_alterFont("SystemFont_Outline_Small", "default", 0, "OUTLINE")
	_alterFont("FriendsFont_Normal", "default")
	_alterFont("FriendsFont_Small", "default")
	_alterFont("FriendsFont_Large", "default", 3)
	_alterFont("FriendsFont_UserText", "default", -1)
	_alterFont("SystemFont_Small", "default", -1)
	_alterFont("GameFontNormalSmall", "default", -1)
	_alterFont("GameFontNormalSmall2", "default")
	_alterFont("NumberFont_Shadow_Med", "default", -1, "OUTLINE")
	_alterFont("NumberFont_Shadow_Small", "default", -1, "OUTLINE")
	_alterFont("SystemFont_Tiny", "default", -1)
	_alterFont("SystemFont_Shadow_Med1", "default")
	_alterFont("SystemFont_Shadow_Med1_Outline", "default")
	_alterFont("SystemFont_Shadow_Med2", "default")
	_alterFont("SystemFont_Shadow_Med3", "default")
	_alterFont("SystemFont_Large", "default")
	_alterFont("SystemFont_Huge1", "default", 4)
	_alterFont("SystemFont_Huge1_Outline", "default", 4)
	_alterFont("SystemFont_Shadow_Small", "default")
	_alterFont("SystemFont_Shadow_Large", "default", 3)
	_alterFont("QuestFont", "dialog");
	_alterFont("QuestFont_Enormous", "zone", 15, "OUTLINE");
	_alterFont("SpellFont_Small", "dialog", 0, "OUTLINE", 1, 1, 1);
	_alterFont("SystemFont_Shadow_Outline_Large", "title", 0, "OUTLINE");
	_alterFont("SystemFont_Shadow_Outline_Huge2", "title", 8, "OUTLINE");
	_alterFont("GameFont_Gigantic", "alert", 0, "OUTLINE", 32)
	_alterFont("SystemFont_Shadow_Huge1", "alert", 0, "OUTLINE")
	_alterFont("SystemFont_OutlineThick_Huge4", "zone", 6, "OUTLINE");
	_alterFont("SystemFont_OutlineThick_WTF", "zone", 9, "OUTLINE");
	_alterFont("SystemFont_OutlineThick_WTF2", "zone", 15, "OUTLINE");
	_alterFont("QuestFont_Large", "zone", -3);
	_alterFont("QuestFont_Huge", "zone", -2);
	_alterFont("QuestFont_Super_Huge", "zone");
	_alterFont("QuestFont_Shadow_Huge", "zone");
	_alterFont("SystemFont_OutlineThick_Huge2", "zone", 2, "OUTLINE");
	_alterFont("Game18Font", "number", 1)
	_alterFont("Game24Font", "number", 3)
	_alterFont("Game27Font", "number", 5)
	_alterFont("Game30Font", "number_big")
	_alterFont("Game32Font", "number_big", 1)
	_alterFont("NumberFont_OutlineThick_Mono_Small", "number", 0, "OUTLINE")
	_alterFont("NumberFont_Outline_Huge", "number_big", 0, "OUTLINE")
	_shadowFont("NumberFont_Outline_Large", "number", 2, "OUTLINE")
	_alterFont("NumberFont_Outline_Med", "number", 1, "OUTLINE")
	_alterFont("NumberFontNormal", "number", 0, "OUTLINE")
	_alterFont("NumberFont_GameNormal", "number", 0, "OUTLINE")
	_alterFont("NumberFontNormalRight", "number", 0, "OUTLINE")
	_alterFont("NumberFontNormalRightRed", "number", 0, "OUTLINE")
	_alterFont("NumberFontNormalRightYellow", "number", 0, "OUTLINE")
	_alterFont("GameTooltipHeader", "tipheader")
	_alterFont("Tooltip_Med", "tipdialog")
	_alterFont("Tooltip_Small", "tipdialog", -1)
	_alterFont("SystemFont_Shadow_Huge3", "combat", -10, "OUTLINE")
	_alterFont("CombatTextFont", "combat", 64, "OUTLINE")
end

local function _defineFont(globalName, template)
	if(not template) then return end
	if(not _G[globalName]) then return end
	SV:FontManager(_G[globalName], template);
end

local function UpdateFontTemplate(template)
	template = template or "default";
	local info = SV.media.shared.font[template];
	if(not info) then return end
	local file = LSM:Fetch("font", info.file);
	local size = info.size;
	local line = info.outline;
	local list = ManagedFonts[template];
	if(not list) then return end
	for object in pairs(list) do
		if object then
			if(object.___fontOutline) then
				object:SetFont(file, (size + object.___fontSizeMod), object.___fontOutline);
			else
				object:SetFont(file, (size + object.___fontSizeMod), line);
			end
		else
			ManagedFonts[template][object] = nil;
		end
	end
end

local function UpdateAllFontTemplates()
	for template, _ in pairs(ManagedFonts) do
		UpdateFontTemplate(template)
	end
	ChangeGlobalFonts();
end

local function UpdateFontGroup(...)
	for i = 1, select('#', ...) do
		local template = select(i, ...)
		if not template then break end
		UpdateFontTemplate(template)
	end
end

SV.Events:On("ALL_FONTS_UPDATED", UpdateAllFontTemplates, true);
SV.Events:On("FONT_GROUP_UPDATED", UpdateFontGroup, true);

---------------------------------------------------------------------
-- Create an add-in set of specific font configuration options.
-- @function GenerateFontOptionGroup
-- @tparam string groupName Options group to insert into.
-- @tparam number groupCount Option order for this option.
-- @tparam string groupOverview Option group name for this option.
-- @tparam table groupList Array of relevant font data.
-- @usage SV:GenerateFontOptionGroup(groupName, groupCount, groupOverview, groupList)
---------------------------------------------------------------------

function SV:GenerateFontOptionGroup(groupName, groupCount, groupOverview, groupList)
    self.Options.args.Fonts.args.fontGroup.args[groupName] = {
        order = groupCount,
        type = "group",
        name = groupName,
        args = {
            overview = {
                order = 1,
                name = groupOverview,
                type = "description",
                width = "full",
            },
            spacer0 = {
                order = 2,
                name = "",
                type = "description",
                width = "full",
            },
        },
    };

    local orderCount = 3;
    for template, info in pairs(groupList) do
        self.Options.args.Fonts.args.fontGroup.args[groupName].args[template] = {
            order = orderCount + info.order,
            type = "group",
            guiInline = true,
            name = info.name,
            get = function(key)
                return self.media.shared.font[template][key[#key]]
            end,
            set = function(key,value)
                self.media.shared.font[template][key[#key]] = value;
                if(groupCount == 1) then
                    self:StaticPopup_Show("RL_CLIENT")
                else
                    self.Events:Trigger("FONT_GROUP_UPDATED", template);
                end
            end,
            args = {
                description = {
                    order = 1,
                    name = info.desc,
                    type = "description",
                    width = "full",
                },
                spacer1 = {
                    order = 2,
                    name = "",
                    type = "description",
                    width = "full",
                },
                spacer2 = {
                    order = 3,
                    name = "",
                    type = "description",
                    width = "full",
                },
                file = {
                    type = "select",
                    dialogControl = 'LSM30_Font',
                    order = 4,
                    name = self.L["Font File"],
                    desc = self.L["Set the font file to use with this font-type."],
                    values = _G.AceVillainWidgets.font,
                },
                outline = {
                    order = 5,
                    name = self.L["Font Outline"],
                    desc = self.L["Set the outlining to use with this font-type."],
                    type = "select",
                    values = {
                        ["NONE"] = self.L["None"],
                        ["OUTLINE"] = "OUTLINE",
                        ["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
                        ["THICKOUTLINE"] = "THICKOUTLINE"
                    },
                },
                size = {
                    order = 6,
                    name = self.L["Font Size"],
                    desc = self.L["Set the font size to use with this font-type."],
                    type = "range",
                    min = 6,
                    max = 64,
                    step = 1,
                },
            }
        }
    end
end

---- MEDIA CORE ----

local function tablesplice(mergeTable, targetTable)
    if type(targetTable) ~= "table" then targetTable = {} end
    if type(mergeTable) == 'table' then
	    for key,val in pairs(mergeTable) do
	        if type(val) == "table" then
	            targetTable[key] = tablesplice(val, targetTable[key])
	        else
	            targetTable[key] = val
	        end
	    end
    end
    return targetTable
end

SV.media = tablesplice(SV.mediadefaults, {});

local GLOBAL_SVUI_FONTS = {
	["SVUI_Font_Default"] = "default",
	["SVUI_Font_Aura"] = "aura",
	["SVUI_Font_Number"] = "number",
	["SVUI_Font_Number_Huge"] = "number_big",
	["SVUI_Font_Header"] = "header",
	["SVUI_Font_Data"] = "data",
	["SVUI_Font_Caps"] = "caps",
	["SVUI_Font_Narrator"] = "narrator",
	["SVUI_Font_Pixel"] = "pixel",
	["SVUI_Font_Roll"] = "rolldialog",
	["SVUI_Font_Roll_Number"] = "rollnumber",
	["SVUI_Font_Loot"] = "lootdialog",
	["SVUI_Font_Loot_Number"] = "lootnumber",
};

function SV:AssignMedia(mediaType, id, ...)
	if((not mediaType) or (not id)) then return end

	if(mediaType == "globalfont") then
		local globalName = ...;
		if(globalName) then
			GLOBAL_SVUI_FONTS[globalName] = id;
		end
		return
	end

	if(mediaType == "template") then
		local globalName = ...;
		if(globalName) then
			self.API.Templates[id] = globalName;
		end
		return
	end

	local settings = self.mediadefaults.shared[mediaType];
	if(settings) then
		if(mediaType == "font") then
			local file, size, outline = ...
			if(settings[id]) then
				if(file) then settings[id].file = file end
				if(size) then settings[id].size = size end
				if(outline) then settings[id].outline = outline end
			else
				file = file or "SVUI Default Font";
				size = size or 12;
				outline = outline or "OUTLINE";
				settings[id] = {file = file, size = size, outline = outline}
			end
		elseif(mediaType == "statusbar") then
			local file, offset = ...
			if(settings[id]) then
				if(file) then settings[id].file = file end
				if(offset) then settings[id].offset = offset end
			else
				file = file or "SVUI BasicBar";
				offset = offset or 0;
				settings[id] = {file = file, offset = offset}
			end
		elseif(mediaType == "background") then
			local file, size, tiled = ...
			if(settings[id]) then
				if(file) then settings[id].file = file end
				if(size) then settings[id].size = size end
				if(tiled) then settings[id].tiled = tiled end
			else
				file = file or "SVUI Default BG";
				size = size or 0;
				tiled = tiled or false;
				settings[id] = {file = file, size = size, tiled = tiled}
			end
		elseif(mediaType == "border") then
			local file, size = ...
			if(settings[id]) then
				if(file) then settings[id].file = file end
				if(size) then settings[id].size = size end
			else
				file = file or "SVUI Border";
				size = size or 1;
				settings[id] = {file = file, size = size}
			end
		end
	else
		settings = self.mediadefaults[mediaType];
		if(settings) then
			if(settings[id]) then
				if(type(settings[id]) == "table") then
					for i = 1, select('#', ...) do
						local v = select(i, ...)
						if(not v) then break end
						if(type(v) == "table") then
							settings[id] = tablesplice(v, settings[id]);
						else
							settings[id][i] = v;
						end
					end
				else
					local newMedia = ...;
					if(newMedia) then
						settings[id] = newMedia;
					end
				end
			else
				local valueCount = select('#', ...)
				if(valueCount > 1) then
					settings[id] = {};
					for i = 1, select('#', ...) do
						local v = select(i, ...)
						if(not v) then break end
						if(type(v) == "table") then
							settings[id] = tablesplice(v, settings[id]);
						else
							settings[id][i] = v;
						end
					end
				else
					local newMedia = ...;
					if(newMedia) then
						settings[id] = newMedia;
					end
				end
			end
		end
	end
end

function SV:UpdateSharedMedia()
	local settings = self.media.shared
	for mediaType, mediaData in pairs(settings) do
		if(self.media[mediaType]) then
			for name,userSettings in pairs(mediaData) do
				if(userSettings.file) then
					self.media[mediaType][name] = LSM:Fetch(mediaType, userSettings.file)
				end
			end
		end
	end

	for name, bd in pairs(self.media.backdrop) do
		if(self.media.background[name] and self.media.border[name]) then
			local bordersetup = self.media.shared.border[name];
			local bgsetup = self.media.shared.background[name];
			bd.bgFile = self.media.background[name];
		  bd.tile = bgsetup.tiled;
		  bd.tileSize = bgsetup.size;
			bd.edgeFile = self.media.border[name];
			bd.edgeSize = bordersetup.size;
			local offset = bordersetup.size * 0.2;
			bd.insets = {
				left = offset,
				right = offset,
				top = offset,
				bottom = offset,
			}
		end
	end

	local default = self.media.color.default
	self.media.gradient.default = {"VERTICAL", default[1]*.25, default[2]*.25, default[3]*.25, default[1], default[2], default[3]}

	local secondary = self.media.color.secondary
	self.media.gradient.secondary = {"VERTICAL", secondary[1]*.25, secondary[2]*.25, secondary[3]*.25, secondary[1], secondary[2], secondary[3]}

	local cColor1 = CUSTOM_CLASS_COLORS[classToken]
	local cColor2 = RAID_CLASS_COLORS[classToken]
    if(not self.db.general.customClassColor or not CUSTOM_CLASS_COLORS[classToken]) then
        cColor1 = RAID_CLASS_COLORS[classToken]
    end
	local r1,g1,b1 = cColor1.r,cColor1.g,cColor1.b
	local r2,g2,b2 = cColor2.r*.25, cColor2.g*.25, cColor2.b*.25
	local ir1,ig1,ib1 = (1 - r1), (1 - g1), (1 - b1)
	local ir2,ig2,ib2 = (1 - cColor2.r)*.25, (1 - cColor2.g)*.25, (1 - cColor2.b)*.25
	self.media.color.class = {r1, g1, b1, 1}
	self.media.color.bizzaro = {ir1, ig1, ib1, 1}
	self.media.bordercolor.class = {r1, g1, b1, 1}
	self.media.gradient.class = {"VERTICAL", r2, g2, b2, r1, g1, b1}
	self.media.gradient.bizzaro = {"VERTICAL", ir2, ig2, ib2, ir1, ig1, ib1}

	local special = self.media.color.special
	---- self.media.gradient.special = {"VERTICAL", special[1], special[2], special[3], r1, g1, b1} ----
	---- self.media.color.special = {r1*.5, g1*.5, b1*.5, 1} ----
	self.media.gradient.special = {"VERTICAL", special[1]*.25, special[2]*.25, special[3]*.25, special[1], special[2], special[3]}
	---- self.media.gradient.special = {"VERTICAL",special[1], special[2], special[3], default[1], default[2], default[3]} ----

	self.Events:Trigger("SHARED_MEDIA_UPDATED");
	if(not InCombatLockdown()) then
		collectgarbage("collect");
	end
end

function SV:RefreshAllMedia()
	self:UpdateSharedMedia();

	ChangeGlobalFonts();
	ChangeSystemFonts();

	for globalName, id in pairs(GLOBAL_SVUI_FONTS) do
		local obj = _G[globalName];
		if(obj) then
			self:FontManager(obj, id);
		end
	end

	self.Events:Trigger("ALL_FONTS_UPDATED");
	self.MediaInitialized = true;
end
