--[[
##############################################################################
S V U I   By: Failcoder
############################################################################## ]]--
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
local rawset            = _G.rawset;
local rawget            = _G.rawget;
local tostring          = _G.tostring;
local tonumber          = _G.tonumber;
local getmetatable      = _G.getmetatable;
local setmetatable      = _G.setmetatable;
local collectgarbage    = _G.collectgarbage;
local string    = _G.string;
local math      = _G.math;
local table     = _G.table;
local wipe      = _G.wipe;
--[[ STRING METHODS ]]--
local format, find, lower, match, gsub = string.format, string.find, string.lower, string.match, string.gsub;
--[[ MATH METHODS ]]--
local floor, abs, min, max = math.floor, math.abs, math.min, math.max;
--[[ TABLE METHODS ]]--
local tremove, tcopy, twipe, tsort, tconcat = table.remove, table.copy, table.wipe, table.sort, table.concat;
local tprint = table.tostring;
--[[
##########################################################
GET ADDON DATA
##########################################################
]]--
local SV = _G["SVUI"];
local L = SV.L;
local SVUILib = Librarian("Registry");

SV.ProfileInterface = _G["SVUI_ProfileInterface"];
local ProfileInterfaceDialog = _G["SVUI_ProfileInterfaceDialog"];
local ProfileInterfaceHelp = _G["SVUI_ProfileInterfaceHelp"];
local ProfileInterfaceScrollBar = _G["SVUI_ProfileInterfaceDialogScrollBar"];
--[[
##########################################################
CUSTOM MESSAGE WINDOW
##########################################################
]]--
local exportHelpText = "TO EXPORT: First click the 'Generate Export Key' button. Once your key has been generated, you will want to select and copy the entire code and paste it into a NEW (.txt) document. Save your new document and share the hell out of it!";
local importHelpText = "TO IMPORT: First click the 'Clear' button, then simply copy any profile key from its saved document, paste it into this window, then click the 'Import From Key' button. After confirming the import, your UI will be reloaded. Your current profile will have now been changed with the encoded settings!";
local completeHelpText = exportHelpText .. "\n\n" .. importHelpText;

local ProfileInterface_OnTextChanged = function(self, userInput)
  if userInput then
    --ProfileInterfaceHelp.Text:SetText(completeHelpText);
  else
    local _, max = ProfileInterfaceScrollBar:GetMinMaxValues()
    for i = 1, max do
      ScrollFrameTemplate_OnMouseWheel(ProfileInterfaceDialog, -1)
    end
  end
end

function SV.ProfileInterface:Toggle()
  local aceConfig = LibStub("AceConfigDialog-3.0")
  if(aceConfig and SV.OptionsLoaded) then
    aceConfig:Close(SV.NameID)
    GameTooltip:Hide()
  end
  if not SV.ProfileInterface:IsShown() then
    SV.ProfileInterface:Show()
  else
    SV.ProfileInterface:Hide()
  end
end

function SV:LinkProfile(key)
    self.SystemAlert["COPY_PROFILE_PROMPT"].text = "Are you sure you want to use the shared profile '" .. key .. "'?"
    self.SystemAlert["COPY_PROFILE_PROMPT"].OnAccept = function() SVUILib:CopyDatabase(key, true) end
    self:StaticPopup_Show("COPY_PROFILE_PROMPT")
end

function SV:CopyProfile(key)
    self.SystemAlert["COPY_PROFILE_PROMPT"].text = "Are you sure you want to copy from the profile '" .. key .. "'?"
    self.SystemAlert["COPY_PROFILE_PROMPT"].OnAccept = function() SVUILib:CopyDatabase(key) end
    self:StaticPopup_Show("COPY_PROFILE_PROMPT")
end

local ProfileInterface_ExportProfile = function(self)
    local t = SVUILib:ExportDatabase();
    ProfileInterfaceDialog.Input:SetText(t);
    ProfileInterfaceDialog.Input:HighlightText(0);
    ProfileInterfaceHelp.Text:SetText(exportHelpText);
end

local ProfileInterface_ImportProfile = function(self)
    ProfileInterfaceHelp.Text:SetText(importHelpText);
    SV.SystemAlert["IMPORT_PROFILE_PROMPT"].OnAccept = function()
        local input = ProfileInterfaceDialog.Input:GetText()
        if(input and input ~= '') then
            SVUILib:ImportDatabase(input)
        else
            ProfileInterfaceHelp.Text:SetText('You did not enter a profile key.');
        end
    end
    SV:StaticPopup_Show("IMPORT_PROFILE_PROMPT")
end

local ProfileInterface_ClearProfile = function(self)
    ProfileInterfaceDialog.Input:SetText('');
    ProfileInterfaceHelp.Text:SetText(completeHelpText);
end

local function InitializeProfileInterface()
    SV.ProfileInterface:SetParent(SV.Screen)
    SV.ProfileInterface.Source = "";
    SV.ProfileInterface:SetStyle("Frame", "Container")
    SV.ProfileInterface.Export:SetStyle("Button")
    SV.ProfileInterface.Export:SetScript("OnClick", ProfileInterface_ExportProfile)
    SV.ProfileInterface.Import:SetStyle("Button")
    SV.ProfileInterface.Import:SetScript("OnClick", ProfileInterface_ImportProfile)
    SV.ProfileInterface.Clear:SetStyle("Button")
    SV.ProfileInterface.Clear:SetScript("OnClick", ProfileInterface_ClearProfile)
    SV.API:Set("CloseButton", SV.ProfileInterface.Close)
    --ProfileInterfaceDialog:SetStyle("Frame", "Transparent")
    ProfileInterfaceDialog.Input:SetScript("OnTextChanged", ProfileInterface_OnTextChanged)
    SV.ProfileInterface:RegisterForDrag("LeftButton");
    ProfileInterfaceHelp:SetStyle("Frame", "Default")
    ProfileInterfaceHelp.Text:SetText(completeHelpText);
end

SV.Events:On("LOAD_ALL_ESSENTIALS", InitializeProfileInterface);

function SV:GenerateSharedProfileOptions()
    local sharedGroup = {};

    sharedGroup.spacer1 = {
        order = 1,
        type = "description",
        name = "Shared settings allow you to transfer even more options from enabled modules.".."\n",
        width = "full",
    }

    local currentCount = 2;
    for schema,data in pairs(self.private.SAFEDATA.SHARED) do
        local obj = self[schema];
        if(obj and obj.___canShare) then
            sharedGroup[schema] = {
                order = currentCount,
                type = "toggle",
                name = L["Shared " .. schema .. " Settings"],
                desc = L["Do you want all " .. schema .. " settings available when copying the current profile?"],
                get = function(a) return obj:IsSharingEnabled(); end,
                set = function(a,b) obj:ToggleSharedData(b); end,
            };
            currentCount = currentCount + 1;
        end
    end

    return sharedGroup;
end
