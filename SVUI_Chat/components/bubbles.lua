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
local ipairs 	= _G.ipairs;
local type 		= _G.type;
--[[
##########################################################
GET ADDON DATA
##########################################################
]]--
local SV = _G['SVUI']
local L = SV.L;
local MOD = SV.Chat;
local bubbles = SV.db.Chat.bubbles;
--[[
##########################################################
CHAT BUBBLES
##########################################################
]]--
function MOD:LoadChatBubbles()
	local inInstance, instanceType = IsInInstance();
    local cmap = C_Map.GetBestMapForUnit("player")
    local position = C_Map.GetPlayerMapPosition(cmap, "player");
    local posX = position.x
    local posY = position.y
	if (posX == 0 and posY == 0) or inInstance then
		SV.db.Chat.bubbles = false
	end
	
	if(SV.db.Chat.bubbles == true) then
		local ChatBubbleHandler = CreateFrame("Frame", nil, UIParent)

		local function _style(frame)
			if(frame:GetName() or (not frame:GetRegions())) then return end
			local backdrop = frame:GetBackdrop()
			if((not backdrop) or (not backdrop.bgFile) or (not backdrop.bgFile:find('ChatBubble'))) then return end
			local needsUpdate = true;
			for i = 1, frame:GetNumRegions() do
				local region = select(i, frame:GetRegions())
				if region:GetObjectType() == "Texture" then
					if(region:GetTexture() == [[Interface\Tooltips\ChatBubble-Background]]) then
						region:SetTexture([[Interface\AddOns\SVUI_Chat\assets\CHATBUBBLE-BG]])
						needsUpdate = false
					elseif(region:GetTexture() == [[Interface\Tooltips\ChatBubble-Backdrop]]) then
						region:SetTexture([[Interface\AddOns\SVUI_Chat\assets\CHATBUBBLE-BACKDROP]])
						needsUpdate = false
					elseif(region:GetTexture() == [[Interface\Tooltips\ChatBubble-Tail]]) then
						region:SetTexture([[Interface\AddOns\SVUI_Chat\assets\CHATBUBBLE-TAIL]])
						needsUpdate = false
					else
						region:SetTexture("")
					end
				elseif(region:GetObjectType() == "FontString" and not frame.text) then
					frame.text = region
				end
			end
			if needsUpdate then
				frame:SetBackdrop(nil);
				frame:SetClampedToScreen(false)
				frame:SetFrameStrata("BACKGROUND")
			end
			if(frame.text) then
				frame.text:SetFontObject(SVUI_Font_Default)
				frame.text:SetShadowColor(0,0,0,1)
				frame.text:SetShadowOffset(1,-1)
			end
		end

		local timer,total = 0,0;
		ChatBubbleHandler:SetScript("OnUpdate", function(self, elapsed)
			timer = timer + elapsed
			if timer > 0.1 then
				timer = 0
				local current = WorldFrame:GetNumChildren();
				if current ~= total then
					for i = total + 1, current do _style(select(i, WorldFrame:GetChildren())) end
					total = current
				end
			end
		end)
	end
end
