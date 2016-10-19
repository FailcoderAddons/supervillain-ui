--[[
##############################################################################
S V U I   By: Failcoder
##############################################################################
]]--

--[[ GLOBALS ]]--

local _G = _G;
local table = _G.table;
local math = _G.math;
local concat = table.concat;
local random = math.random;
--[[ ADDON ]]--

local SV = _G["SVUI"];
local L = SV.L;

local PRINTED_TEMPLATE = [[
|cffff9900SUPERVILLAIN CREDITS:|r
|cff4f4f4f---------------------------------------------|r
|cffff9900CREATED BY:|r  Failcoder
|cffff9900MAINTAINED BY:|r  joev
|cff4f4f4f---------------------------------------------|r
|cffff9900CODE GRANTS BY:|r  Azilroka, Sortokk, Kkthnx
|cff4f4f4f---------------------------------------------|r

|cffff9900SPECIAL THANKS TO:
|r|cfff81422Cairenn|r |cff2288cc(@WowInterface.com)|r  ..the most patient and accomodating person I know!
|r|cfff81422Panser|r |cff2288cc(@TradeChat)|r  ..for all the re-tweets and favorites! |cff555555(now if I can get you to actually use this UI...)|r
|r|cfff81422Synnistry|r and |cfff81422MetaGoblin|r  ..for giving this project life in your videos!
|r|cfff81422Panda Co Live!|r and |cfff81422WoWProfitz|r ..for giving this project life in your streams!

|cffff9900A VERY SPECIAL THANKS TO:  |r|cffffff00Movster|r  ..who inspired me to bring this project back to life!
|cff4f4f4f---------------------------------------------|r

|cffFFFF00THE HIGH COUNCIL  (aka EXECUTIVES):|r
|cff33FF33SINNISTERR|r - (My wife, the MOST ruthless Warlock you will ever meet!)
|cff33FF33PENGUINSANE|r - (The ace up my sleeve)
|cff33FF33BLOODEAGLE|r - (The artisan tester)
|cff33FF33HOTLUCK|r - (The profiler)
|cff33FF33CROMAX|r - (The relentless)
|cff33FF33DOONGA|r - (The man who keeps me busy)
|cff33FF33DAIGAN|r - (Quality control with NO MERCY!)
|cff33FF33FAOLANKING|r - (King of the bug report portal)
|cff4f4f4f---------------------------------------------|r

|cff99ff33KINGPINS  (aka INVESTORS):|r
%s
Other Silent Partners.. (Let me know if I have forgotten you)
|cff4f4f4f---------------------------------------------|r

|cff3399ffCODE MONKEYS  (aka CONTRIBUTORS):|r
%s
|cff4f4f4f---------------------------------------------|r

|cffaa33ffMINIONS  (aka COMMUNITY TESTERS):|r
%s
The Wowinterface and Curse Community
|cff4f4f4f---------------------------------------------|r

|cff00ccffTheme Song By: Fingathing [taken from the song: SuperHero Music]|r
]];

local CreditFrame = _G["SVUI_CreditFrame"];
CreditFrame.Title = _G["SVUI_CreditFrameTitle"];
CreditFrame.List  = _G["SVUI_CreditFrameList"];
local TitleFrame = _G["SVUI_SuperTitleFrame"];
TitleFrame.Title = _G["SVUI_SuperTitleFrameTitle"];
TitleFrame.List  = _G["SVUI_SuperTitleFrameList"];
local playerName = UnitName("player");
local playerClass = UnitClass("player");

SV.Credits = {};

SV.Credits["author"] = {
  playerName,
};

SV.Credits["council"] = {
  "Sinnisterr",
  "Penguinsane",
  "BloodEagle",
  "Hotluck",
  "Cromax",
  "Doonga",
  "Daigan",
  "FaolanKing"
};

SV.Credits["investors"] = {
  "Movster", "Meggalo", "Penguinsane", "FaolanKing", "Doonga",
  "Cazart506", "Moondoggy", "Necroo", "Chief Pullin", "lkj61",
  "BloodEagle", "Egbert", "Jerry Ferguson", "Hyti", "Elton",
  "James Watson", "Lathron", "Adam Vargas", "Daphne", "Dave (Naméra)",
  "Soulkrusher-Shu-Halo", "Talirrine", "Gaeline", "Malinche", "StealthyMangos",
  "Monger", "JoeyMagz", "joev",
  "Cherep2267", "Ravensongs", "Huggiedabear", "Titatotemaar", "Mahga"
};

SV.Credits["contributors"] = {
  "Azilroka", "Sortokk", "Kkthnx", "Vyntrox", "Mydraal", "Profitz",
  "AlleyKat", "Quokka", "Duugu", "Zork", "Haleth", "P3lim",
  "Haste", "Totalpackage", "Kryso", "Thepilli", "Phanx", "Abu"
};

SV.Credits["community"] = {
  "Movster", "Judicate", "Cazart506", "MuffinMonster", "Joelsoul",
  "Trendkill09", "Luamar", "Zharooz", "Lyn3x5", "Madh4tt3r",
  "Xarioth", "AtomicKiller", "Meljen", "Moondoggy", "Stormblade",
  "Schreibstift", "Anj", "Risien", "Cromax", "Nitro_Turtle",
  "Shinzou", "Autolykus", "Taotao", "ColorsGaming", "Necroo", "Panser (TradeChat)",
  "Synnistry", "MetaGoblin", "Panda Co Live!", "klepp0906"
};

local LIST_PATTERN = "    %s\n        %s\n            %s\n                %s";
local EPISODE_TEXT;
local ROLLED_CREDITS = 0;
local DELAY = 0;
local CREDITS_DATA = {
  {"Produced By: ", "council"},
  {"Sponsored In Part By: ", "investors"},
  {"Contributions Provided By: ", "contributors"},
  {"Community Support From: ", "community"},
  {"Written and Directed By: ", "author"},
};

local FLAVOR_TITLES = {
  "The Adventures Of...", "The Legend Of...", "They Call Me...", "The Amazing...", "Tales Of..."
};

local FLAVOR_TEXTS = {
  {"%s Of Legend", "The Notorious %s", "Do The %s Dance", "%s: 1, Everyone else: 0", "Chronicles of the %s"},
  {"Chronicles of the %s %s", "Super %s %s", "The Notorious %s %s"}
};

local function RollCredits()
  ROLLED_CREDITS = 1;
  CreditFrame:CallBack()
end

local function ShowIssueString()
  local WEEKDAY, MONTHNUM, DAYNUM, YEARNUM = CalendarGetDate();
  local ISSUE_TEXT = ("Issue: #%d, Volume: #%d"):format(DAYNUM, MONTHNUM);
  local flavorKey = random(1,2);
  local flavorList = FLAVOR_TEXTS[flavorKey];
  local flavorPattern = flavorList[random(1, #flavorList)]
  if(flavorKey == 1) then
    EPISODE_TEXT = flavorPattern:format(playerClass)
  else
    local currentGroup = GetActiveSpecGroup()
    local currentSpec = GetSpecialization(false, false, currentGroup);
    local specText = currentSpec and select(2, GetSpecializationInfo(currentSpec)) or nil
    if(not specText) then
      EPISODE_TEXT = "A Day In The Life..."
    else
      EPISODE_TEXT = flavorPattern:format(specText, playerClass)
    end
  end
  CreditFrame:SetAlpha(0);
  CreditFrame:Show();
  CreditFrame.Title:SetText(ISSUE_TEXT);
  CreditFrame.List:SetText(EPISODE_TEXT);
  CreditFrame:FadeIn(1);
end

local function KillCredits()
  TitleFrame:SetScript("OnUpdate", nil)
  TitleFrame:Hide()
  CreditFrame:SetScript("OnUpdate", nil)
  CreditFrame:Hide()
end

local function TitleFrame_OnUpdate(self, elapsed)
  DELAY = DELAY + elapsed
  if(DELAY < 3) then return end
  if(DELAY <= 3.5) then
    self:FadeOut(1);
  elseif(DELAY >= 7) then
    DELAY = 0
    self:SetScript("OnUpdate", nil)
  end
end

local function InitTitleFrame_OnUpdate(self, elapsed)
  DELAY = DELAY + elapsed
  if(DELAY < 3) then return end
  if(DELAY <= 3.5) then
    self:FadeOut(1);
  elseif(DELAY > 6 and DELAY <= 7) then
    DELAY = 7.1
    ShowIssueString()
  elseif(DELAY > 9.5 and DELAY <= 10.5) then
    CreditFrame:FadeOut(1);
  elseif(DELAY > 14) then
    DELAY = 0
    self:SetScript("OnUpdate", nil)
    RollCredits()
  end
end

local function CreditFrame_OnUpdate(self, elapsed)
  DELAY = DELAY + elapsed
  if(DELAY < 3) then return end
  if(DELAY <= 3.5) then
    self:FadeOut(1);
  elseif(DELAY >= 7) then
    DELAY = 0
    self:SetScript("OnUpdate", nil)
    self:CallBack()
  end
end

function TitleFrame:ShowTitle(title, text)
  self:SetAlpha(0);
  self:Show();
  self.Title:SetText(title);
  self.List:SetText(text);
  self:FadeIn(1);
  DELAY = 0;
  self:SetScript("OnUpdate", TitleFrame_OnUpdate)
end

function CreditFrame:ShowCredit(title, text)
  self:SetAlpha(0);
  self:Show();
  self.Title:SetText(title);
  self.List:SetText(text);
  self:FadeIn(1);
  DELAY = 0;
  self:SetScript("OnUpdate", CreditFrame_OnUpdate)
end

local All_Credits = function(self)
  local title, list = "", "";
  if(ROLLED_CREDITS < 5) then
    title = "Thank You"
    local council = SV.Credits['council'][random(1, #SV.Credits['council'])]
    local investors = SV.Credits['investors'][random(1, #SV.Credits['investors'])]
    local contributors = SV.Credits['contributors'][random(1, #SV.Credits['contributors'])]
    local community = SV.Credits['community'][random(1, #SV.Credits['community'])]
    list = LIST_PATTERN:format(council, investors, contributors, community);
    ROLLED_CREDITS = ROLLED_CREDITS + 1;
    self:ShowCredit(title, list);
  else
    KillCredits()
  end
end

local Intro_Credits = function(self)
  local title, list = "", "";
  if(ROLLED_CREDITS == 1) then
    title = "Produced By"
    local council = SV.Credits['council'][random(1, #SV.Credits['council'])]
    local investors = SV.Credits['investors'][random(1, #SV.Credits['investors'])]
    local contributors = SV.Credits['contributors'][random(1, #SV.Credits['contributors'])]
    local community = SV.Credits['community'][random(1, #SV.Credits['community'])]
    list = LIST_PATTERN:format(council, investors, contributors, community);
    ROLLED_CREDITS = 2;
    self:ShowCredit(title, list);
  elseif(ROLLED_CREDITS == 2) then
    title = "Written and Directed By"
    list = playerName
    ROLLED_CREDITS = 0;
    self:ShowCredit(title, list);
  else
    KillCredits()
  end
end

function SV:PrintCredits()
  local investors, contributors, community;
  investors = concat(self.Credits["investors"], ", ");
  contributors = concat(self.Credits["contributors"], ", ");
  community = concat(self.Credits["community"], ", ");
  return PRINTED_TEMPLATE:format(investors, contributors, community)
end

function SV:RollCredits()
  CreditFrame.CallBack = Intro_Credits
  CreditFrame:SetScript("OnMouseDown", KillCredits);
  TitleFrame:SetScript("OnMouseDown", KillCredits);
  DELAY = 0;
  SV.Events:On("SPECIAL_FRAMES_CLOSED", KillCredits, true);
  TitleFrame:SetAlpha(0);
  TitleFrame:Show();
  local titleKey = random(1,#FLAVOR_TITLES)
  local titlePattern = FLAVOR_TITLES[titleKey]
  TitleFrame:ShowTitle(titlePattern, playerName);
  TitleFrame.List:SetText(playerName);
  TitleFrame:FadeIn(1);
  TitleFrame:SetScript("OnUpdate", InitTitleFrame_OnUpdate);
end

function SV:FlashTitle(text1, text2)
  TitleFrame:ShowTitle(text1, text2);
end

SV:AddSlashCommand("credits", "Display some randomly selected SVUI credits", function() CreditFrame.CallBack = All_Credits; RollCredits() end);
