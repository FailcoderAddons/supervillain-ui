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
POSTAL
##########################################################
]]--
local function StylePostal()
	assert(PostalOpenAllButton, "AddOn Not Loaded")

	InboxPrevPageButton:SetPoint("CENTER", InboxFrame, "BOTTOMLEFT", 45, 112)
	InboxNextPageButton:SetPoint("CENTER", InboxFrame, "BOTTOMLEFT", 295, 112)

	for i = 1, INBOXITEMS_TO_DISPLAY do
		local b = _G["MailItem"..i.."ExpireTime"]
		b:SetPoint("TOPRIGHT", "MailItem"..i, "TOPRIGHT", -5, -10)
		if b.returnicon then
			b.returnicon:SetPoint("TOPRIGHT", b, "TOPRIGHT", 20, 0)
		end
		if _G['PostalInboxCB'..i] and not _G['PostalInboxCB'..i].handled then
			_G['PostalInboxCB'..i]:SetStyle("CheckButton")
			_G['PostalInboxCB'..i].handled = true
		end
	end
	if PostalSelectOpenButton and not PostalSelectOpenButton.handled then
		PostalSelectOpenButton:SetStyle("Button")
		PostalSelectOpenButton.handled = true
		PostalSelectOpenButton:SetPoint("RIGHT", InboxFrame, "TOP", -41, -48)
	end
	if Postal_OpenAllMenuButton and not Postal_OpenAllMenuButton.handled then
		SV.API:Set("PageButton", Postal_OpenAllMenuButton, true)
		Postal_OpenAllMenuButton:SetPoint('LEFT', PostalOpenAllButton, 'RIGHT', 5, 0)
		Postal_OpenAllMenuButton.handled = true
	end
	if PostalOpenAllButton and not PostalOpenAllButton.handled then
		PostalOpenAllButton:SetStyle("Button")
		PostalOpenAllButton.handled = true
		PostalOpenAllButton:SetPoint("CENTER", InboxFrame, "TOP", -34, -400)
	end
	if PostalSelectReturnButton and not PostalSelectReturnButton.handled then
		PostalSelectReturnButton:SetStyle("Button")
		PostalSelectReturnButton.handled = true
		PostalSelectReturnButton:SetPoint("LEFT", InboxFrame, "TOP", -5, -48)
	end
	if Postal_PackageMenuButton and not Postal_PackageMenuButton.handled then
		SV.API:Set("PageButton", Postal_PackageMenuButton, true)
		Postal_PackageMenuButton.handled = true
		Postal_PackageMenuButton:SetPoint('TOPRIGHT', MailFrame, -53, -6)
	end
	if Postal_BlackBookButton and not Postal_BlackBookButton.handled then
		SV.API:Set("PageButton", Postal_BlackBookButton, true)
		Postal_BlackBookButton.handled = true
		Postal_BlackBookButton:SetPoint('LEFT', SendMailNameEditBox, 'RIGHT', 5, 2)
	end
end
MOD:SaveAddonStyle("Postal", StylePostal, nil, nil, 'MAIL_SHOW')