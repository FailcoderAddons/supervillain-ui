--[[
Librarian is a library used to manage localization, packages, scripts, animations and data embedded
into the SVUI core addon.

It's main purpose is to keep all methods and logic needed to properly keep
core add-ins functioning outside of the core object.

It is also modifyiing LibStub to give me dominating control over which libraries are
allowed to be created and loaded regardless of versioning or timing.

The reasoning for this is due to the potential for other addon to get loaded earlier
and embed newer versions of lib dependencies which can be devastating.
--]]
local _G              = getfenv(0)
local select          = _G.select;
local assert          = _G.assert;
local type            = _G.type;
local error           = _G.error;
local pairs           = _G.pairs;
local next            = _G.next;
local ipairs          = _G.ipairs;
local loadstring      = _G.loadstring;
local setmetatable    = _G.setmetatable;
local rawset          = _G.rawset;
local rawget          = _G.rawget;
local tostring        = _G.tostring;
local tonumber        = _G.tonumber;
local tostring        = _G.tostring;
local xpcall          = _G.xpcall;
local table           = _G.table;
local tconcat         = table.concat;
local tremove         = table.remove;
local strmatch        = _G.strmatch;
local table_sort      = table.sort;
local bit             = _G.bit;
local band            = bit.band;
local math            = _G.math;
local min,max,abs     = math.min,math.max,math.abs;
local LibStub         = _G.LibStub;
local UIParent        = _G.UIParent;
local GetScreenWidth  = _G.GetScreenWidth;
local GetScreenHeight = _G.GetScreenHeight;
local IsAltKeyDown    = _G.IsAltKeyDown;
--[[
The following are private and compressed versions of dependancy libraries
--]]
local MAX_MINOR         = 999999999;
local WINDOW_MAJOR = "LibWindow-1.1";
local WINDOW = LibStub:NewLibrary(WINDOW_MAJOR, MAX_MINOR, true);
if(WINDOW) then
    WINDOW.utilFrame = WINDOW.utilFrame or CreateFrame("Frame")
    WINDOW.delayedSavePosition = WINDOW.delayedSavePosition or {}
    WINDOW.windowData = WINDOW.windowData or {}
    WINDOW.embeds = WINDOW.embeds or {}
    local mixins = {}
    local function a(b,c)local names=WINDOW.windowData[b].names;if names then if names[c]then return names[c]end;if names.prefix then return names.prefix..c end end;return c end;
    local function d(b,c,e)WINDOW.windowData[b].storage[a(b,c)]=e end;
    local function f(b,c)return WINDOW.windowData[b].storage[a(b,c)]end;
    WINDOW.utilFrame:SetScript("OnUpdate",function(g)g:Hide()for b,h in pairs(WINDOW.delayedSavePosition)do WINDOW.delayedSavePosition[b]=nil;WINDOW.SavePosition(b)end end)
    local function i(b)WINDOW.delayedSavePosition[b]=true;WINDOW.utilFrame:Show()end;
    mixins["RegisterConfig"]=true;
    function WINDOW.RegisterConfig(b,storage,names)if not WINDOW.windowData[b]then WINDOW.windowData[b]={}end;WINDOW.windowData[b].names=names;WINDOW.windowData[b].storage=storage end;local j={GetWidth=function()return GetScreenWidth()*UIParent:GetScale()end,GetHeight=function()return GetScreenHeight()*UIParent:GetScale()end,GetScale=function()return 1 end}mixins["SavePosition"]=true;
    function WINDOW.SavePosition(b)local k=b:GetParent()if not k then k=j elseif k~=UIParent then return end;local l=b:GetScale()local m,n=b:GetLeft()*l,b:GetTop()*l;local o,p=b:GetRight()*l,b:GetBottom()*l;local q,r=k:GetWidth(),k:GetHeight()local s,t,u;if m<q-o and m<abs((m+o)/2-q/2)then s=m;u="LEFT"elseif q-o<abs((m+o)/2-q/2)then s=o-q;u="RIGHT"else s=(m+o)/2-q/2;u=""end;if p<r-n and p<abs((p+n)/2-r/2)then t=p;u="BOTTOM"..u elseif r-n<abs((p+n)/2-r/2)then t=n-r;u="TOP"..u else t=(p+n)/2-r/2 end;if u==""then u="CENTER"end;d(b,"x",s)d(b,"y",t)d(b,"point",u)d(b,"scale",l)b:ClearAllPoints()b:SetPoint(u,b:GetParent(),u,s/l,t/l)end;mixins["RestorePosition"]=true;
    function WINDOW.RestorePosition(b)local s=f(b,"x")local t=f(b,"y")local u=f(b,"point")local l=f(b,"scale")if l then (b.lw11origSetScale or b.SetScale)(b,l)else l=b:GetScale()end;if not s or not t then s=0;t=0;u="CENTER"end;s=s/l;t=t/l;b:ClearAllPoints()if not u and t==0 then u="CENTER"end;if not u then b:SetPoint("TOPLEFT",b:GetParent(),"BOTTOMLEFT",s,t)i(b)return end;b:SetPoint(u,b:GetParent(),u,s,t)end;mixins["SetScale"]=true;
    function WINDOW.SetScale(b,v)d(b,"scale",v)(b.lw11origSetScale or b.SetScale)(b,v)WINDOW.RestorePosition(b)end;
    function WINDOW.OnDragStart(b)WINDOW.windowData[b].isDragging=true;b:StartMoving()end;
    function WINDOW.OnDragStop(b)b:StopMovingOrSizing()WINDOW.SavePosition(b)WINDOW.windowData[b].isDragging=false;if WINDOW.windowData[b].altEnable and not IsAltKeyDown()then b:EnableMouse(false)end end;local function w(...)return WINDOW.OnDragStart(...)end;
    local function x(...)return WINDOW.OnDragStop(...)end;mixins["MakeDraggable"]=true;
    function WINDOW.MakeDraggable(b)assert(WINDOW.windowData[b])b:SetMovable(true)b:SetScript("OnDragStart",w)b:SetScript("OnDragStop",x)b:RegisterForDrag("LeftButton")end;
    function WINDOW.OnMouseWheel(b,y)local v=f(b,"scale")if y<0 then v=max(v*0.9,0.1)else v=min(v/0.9,3)end;WINDOW.SetScale(b,v)end;
    local function z(...)return WINDOW.OnMouseWheel(...)end;
    mixins["EnableMouseWheelScaling"]=true;
    function WINDOW.EnableMouseWheelScaling(b)b:SetScript("OnMouseWheel",z)end;WINDOW.utilFrame:SetScript("OnEvent",function(g,A,B,C)if A=="MODIFIER_STATE_CHANGED"then if B=="LALT"or B=="RALT"then for b,h in pairs(WINDOW.altEnabledFrames)do if not WINDOW.windowData[b].isDragging then b:EnableMouse(C==1)end end end end end)mixins["EnableMouseOnAlt"]=true;
    function WINDOW.EnableMouseOnAlt(b)assert(WINDOW.windowData[b])WINDOW.windowData[b].altEnable=true;b:EnableMouse(not not IsAltKeyDown())if not WINDOW.altEnabledFrames then WINDOW.altEnabledFrames={}WINDOW.utilFrame:RegisterEvent("MODIFIER_STATE_CHANGED")end;WINDOW.altEnabledFrames[b]=true end;
    function WINDOW:Embed(D)if not D or not D[0]or not D.GetObjectType then error("Usage: WINDOW:Embed(frame)",1)end;D.lw11origSetScale=D.SetScale;for c,h in pairs(mixins)do D[c]=self[c]end;WINDOW.embeds[D]=true;return D end;for D,h in pairs(WINDOW.embeds)do WINDOW:Embed(D)end
end
