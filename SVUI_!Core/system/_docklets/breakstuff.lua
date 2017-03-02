--[[
##########################################################
S V U I   By: Failcoder
##########################################################
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local unpack  = _G.unpack;
local select  = _G.select;
local pairs   = _G.pairs;
local ipairs  = _G.ipairs;
local print   = _G.print;
local table   = _G.table;
local match   = string.match;
--[[ TABLE METHODS ]]--
local tremove, tcopy, twipe, tsort, tcat = table.remove, table.copy, table.wipe, table.sort, table.concat;
--BLIZZARD API
local CreateFrame           = _G.CreateFrame;
local InCombatLockdown      = _G.InCombatLockdown;
local GameTooltip           = _G.GameTooltip;
local ReloadUI              = _G.ReloadUI;
local hooksecurefunc        = _G.hooksecurefunc;
local GetItemInfo      		= _G.GetItemInfo;
local GetItemCount          = _G.GetItemCount;
local GetSpellInfo      	= _G.GetSpellInfo;
local IsSpellKnown      	= _G.IsSpellKnown;
local IsEquippableItem  	= _G.IsEquippableItem;
local GetSpellBookItemInfo  = _G.GetSpellBookItemInfo;
local ERR_NOT_IN_COMBAT     = _G.ERR_NOT_IN_COMBAT;
local ITEM_MILLABLE     	= _G.ITEM_MILLABLE;
local ITEM_PROSPECTABLE   	= _G.ITEM_PROSPECTABLE;

local GetMouseFocus  				= _G.GetMouseFocus;
local GetContainerItemLink  		= _G.GetContainerItemLink;
local AutoCastShine_AutoCastStart  	= _G.AutoCastShine_AutoCastStart;
local AutoCastShine_AutoCastStop  	= _G.AutoCastShine_AutoCastStop;
--[[
##########################################################
GET ADDON DATA
##########################################################
]]--
local SV = select(2, ...)
local L = SV.L;
local MOD = SV.Dock;
--[[
##########################################################
LOCAL VARS
##########################################################
]]--
local BreakStuff_Cache = {}
local DE, PICK, SMITH, BreakStuffParser;

local BreakStuffButton = CreateFrame("Button", "BreakStuffButton", UIParent);
BreakStuffButton.icon = BreakStuffButton:CreateTexture(nil,"OVERLAY")
BreakStuffButton.icon:InsetPoints(BreakStuffButton,2,2)
BreakStuffButton.icon:SetGradient("VERTICAL", 0.5, 0.53, 0.55, 0.8, 0.8, 1)
BreakStuffButton.ttText = "BreakStuff : OFF";
BreakStuffButton.subText = "";

local BreakStuffHandler = CreateFrame('Button', "BreakStuffHandler", UIParent, 'SecureActionButtonTemplate, AutoCastShineTemplate')
BreakStuffHandler:SetScript('OnEvent', function(self, event, ...) self[event](self, ...) end)
BreakStuffHandler:SetPoint("LEFT",UIParent,"RIGHT",500)
BreakStuffHandler.TipLines = {}
BreakStuffHandler.TTextLeft = ""
BreakStuffHandler.TTextRight = ""
BreakStuffHandler.ReadyToSmash = false;
--[[
##########################################################
ITEM PARSING
##########################################################
]]--
do
  local SkellyKeys = {
	[GetSpellInfo(195881)] = true, -- Jeweled Lockpick
	[GetSpellInfo(130100)] = true, -- Ghostly Skeleton Key
	[GetSpellInfo(94574)] = true, -- Obsidium Skeleton Key
	[GetSpellInfo(59403)] = true, -- Titanium Skeleton Key
	[GetSpellInfo(59404)] = true, -- Colbat Skeleton Key
	[GetSpellInfo(20709)] = true, -- Arcanite Skeleton Key
	[GetSpellInfo(19651)] = true, -- Truesilver Skeleton Key
	[GetSpellInfo(19649)] = true, -- Golden Skeleton Key
	[GetSpellInfo(19646)] = true, -- Silver Skeleton Key
  }
  local BreakableFilter = {
	["Pickables"]={['68729']=true,['63349']=true,['45986']=true,['43624']=true,['43622']=true,['43575']=true,['31952']=true,['12033']=true,['29569']=true,['5760']=true,['13918']=true,['5759']=true,['16885']=true,['5758']=true,['13875']=true,['4638']=true,['16884']=true,['4637']=true,['4636']=true,['6355']=true,['16883']=true,['4634']=true,['4633']=true,['6354']=true,['16882']=true,['4632']=true,['88165']=true,['88567']=true},["SafeItems"]={['89392']=true,['89393']=true,['89394']=true,['89395']=true,['89396']=true,['89397']=true,['89398']=true,['89399']=true,['89400']=true,['83260']=true,['83261']=true,['83262']=true,['83263']=true,['83264']=true,['83265']=true,['83266']=true,['83267']=true,['83268']=true,['83269']=true,['83270']=true,['83271']=true,['83274']=true,['83275']=true,['82706']=true,['82707']=true,['82708']=true,['82709']=true,['82710']=true,['82711']=true,['82712']=true,['82713']=true,['82714']=true,['82715']=true,['82716']=true,['82717']=true,['82720']=true,['82721']=true,['81671']=true,['81672']=true,['81673']=true,['81674']=true,['81675']=true,['81676']=true,['81677']=true,['81678']=true,['81679']=true,['81680']=true,['81681']=true,['81682']=true,['81685']=true,['81686']=true,['64377']=true,['64489']=true,['64880']=true,['64885']=true,['62454']=true,['62455']=true,['62456']=true,['62457']=true,['62458']=true,['62459']=true,['62460']=true,['68740']=true,['49888']=true,['49497']=true,['49301']=true,['72980']=true,['72981']=true,['72989']=true,['72990']=true,['72991']=true,['72992']=true,['72993']=true,['72994']=true,['72995']=true,['72996']=true,['72997']=true,['72998']=true,['72999']=true,['73000']=true,['73001']=true,['73002']=true,['73003']=true,['73006']=true,['73007']=true,['73008']=true,['73009']=true,['73010']=true,['73011']=true,['73012']=true,['73325']=true,['73326']=true,['73336']=true,['88622']=true,['88648']=true,['88649']=true,['64460']=true,['44050']=true,['44173']=true,['44174']=true,['44192']=true,['44193']=true,['44199']=true,['44244']=true,['44245']=true,['44249']=true,['44250']=true,['44051']=true,['44052']=true,['44053']=true,['44108']=true,['44166']=true,['44187']=true,['44214']=true,['44241']=true,['38454']=true,['38455']=true,['38456']=true,['38457']=true,['38460']=true,['38461']=true,['38464']=true,['38465']=true,['29115']=true,['29130']=true,['29133']=true,['29137']=true,['29138']=true,['29166']=true,['29167']=true,['29185']=true,['34665']=true,['34666']=true,['34667']=true,['34670']=true,['34671']=true,['34672']=true,['34673']=true,['34674']=true,['29121']=true,['29124']=true,['29125']=true,['29151']=true,['29152']=true,['29153']=true,['29155']=true,['29156']=true,['29165']=true,['29171']=true,['29175']=true,['29182']=true,['30830']=true,['30832']=true,['29456']=true,['29457']=true,['25835']=true,['25836']=true,['25823']=true,['25825']=true,['77559']=true,['77570']=true,['77583']=true,['77586']=true,['77587']=true,['77588']=true,['21392']=true,['21395']=true,['21398']=true,['21401']=true,['21404']=true,['21407']=true,['21410']=true,['21413']=true,['21416']=true,['38632']=true,['38633']=true,['38707']=true,['34661']=true,['11290']=true,['11289']=true,['45858']=true,['84661']=true,['11288']=true,['28164']=true,['11287']=true,['44180']=true,['44202']=true,['44302']=true,['44200']=true,['44256']=true,['44104']=true,['44116']=true,['44196']=true,['44061']=true,['44062']=true,['29117']=true,['29129']=true,['29174']=true,['30836']=true,['35328']=true,['35329']=true,['35330']=true,['35331']=true,['35332']=true,['35333']=true,['35334']=true,['35335']=true,['35336']=true,['35337']=true,['35338']=true,['35339']=true,['35340']=true,['35341']=true,['35342']=true,['35343']=true,['35344']=true,['35345']=true,['35346']=true,['35347']=true,['35464']=true,['35465']=true,['35466']=true,['35467']=true,['30847']=true,['29122']=true,['29183']=true,['90079']=true,['90080']=true,['90081']=true,['90082']=true,['90083']=true,['90084']=true,['90085']=true,['90086']=true,['90110']=true,['90111']=true,['90112']=true,['90113']=true,['90114']=true,['90115']=true,['90116']=true,['90117']=true,['90136']=true,['90137']=true,['90138']=true,['90139']=true,['90140']=true,['90141']=true,['90142']=true,['90143']=true,['64643']=true,['77678']=true,['77679']=true,['77682']=true,['77692']=true,['77694']=true,['77695']=true,['77709']=true,['77710']=true,['77712']=true,['77886']=true,['77889']=true,['77890']=true,['77899']=true,['77900']=true,['77901']=true,['77917']=true,['77919']=true,['77920']=true,['77680']=true,['77681']=true,['77683']=true,['77690']=true,['77691']=true,['77693']=true,['77708']=true,['77711']=true,['77713']=true,['77887']=true,['77888']=true,['77891']=true,['77898']=true,['77902']=true,['77903']=true,['77916']=true,['77918']=true,['77921']=true,['77778']=true,['77779']=true,['77784']=true,['77795']=true,['77796']=true,['77800']=true,['77801']=true,['77844']=true,['77845']=true,['77846']=true,['77850']=true,['77777']=true,['77781']=true,['77782']=true,['77785']=true,['77797']=true,['77798']=true,['77799']=true,['77802']=true,['77847']=true,['77848']=true,['77851']=true,['77852']=true,['77724']=true,['77725']=true,['77728']=true,['77729']=true,['77732']=true,['77733']=true,['77773']=true,['77783']=true,['77803']=true,['77804']=true,['77843']=true,['77849']=true,['77614']=true,['77615']=true,['77616']=true,['77617']=true,['77618']=true,['77619']=true,['77620']=true,['77627']=true,['77628']=true,['77629']=true,['77630']=true,['77631']=true,['77632']=true,['77647']=true,['77648']=true,['77649']=true,['77650']=true,['77651']=true,['77652']=true,['77770']=true,['77771']=true,['77772']=true,['77774']=true,['77775']=true,['77776']=true,['77786']=true,['77789']=true,['77790']=true,['77791']=true,['77792']=true,['77793']=true,['77794']=true,['77837']=true,['77838']=true,['77839']=true,['77840']=true,['77841']=true,['77842']=true,['20406']=true,['20407']=true,['20408']=true,['77787']=true,['77788']=true,['28155']=true,['22986']=true,['22991']=true,['33292']=true,['86566']=true,['95517']=true,['95518']=true,['95523']=true,['95526']=true,['95527']=true,['95532']=true,['83158']=true,['83162']=true,['83167']=true,['83171']=true,['83176']=true,['83180']=true,['83185']=true,['83189']=true,['83194']=true,['83198']=true,['83203']=true,['83207']=true,['83212']=true,['83216']=true,['83221']=true,['83225']=true,['82614']=true,['82618']=true,['82623']=true,['82627']=true,['82632']=true,['82636']=true,['82641']=true,['82645']=true,['82650']=true,['82654']=true,['82659']=true,['82663']=true,['82668']=true,['82672']=true,['82677']=true,['82681']=true,['81579']=true,['81583']=true,['81588']=true,['81592']=true,['81597']=true,['81601']=true,['81606']=true,['81610']=true,['81615']=true,['81619']=true,['81624']=true,['81628']=true,['81633']=true,['81637']=true,['81642']=true,['81646']=true,['70118']=true,['62364']=true,['62386']=true,['62450']=true,['62441']=true,['62356']=true,['62406']=true,['62424']=true,['72621']=true,['72622']=true,['72623']=true,['72624']=true,['72625']=true,['72626']=true,['72627']=true,['72628']=true,['72638']=true,['72639']=true,['72640']=true,['72641']=true,['72642']=true,['72643']=true,['72644']=true,['72645']=true,['72646']=true,['72647']=true,['72648']=true,['72649']=true,['72650']=true,['72651']=true,['72652']=true,['72653']=true,['72655']=true,['72656']=true,['72657']=true,['72658']=true,['72659']=true,['72660']=true,['72661']=true,['72662']=true,['44180']=true,['44202']=true,['44302']=true,['44200']=true,['44256']=true,['44181']=true,['44203']=true,['44297']=true,['44303']=true,['44179']=true,['44194']=true,['44258']=true,['44106']=true,['44170']=true,['44190']=true,['44117']=true,['44054']=true,['44055']=true,['29116']=true,['29131']=true,['29141']=true,['29142']=true,['29147']=true,['29148']=true,['35356']=true,['35357']=true,['35358']=true,['35359']=true,['35360']=true,['35361']=true,['35362']=true,['35363']=true,['35364']=true,['35365']=true,['35366']=true,['35367']=true,['35368']=true,['35369']=true,['35370']=true,['35371']=true,['35372']=true,['35373']=true,['35374']=true,['35375']=true,['35468']=true,['35469']=true,['35470']=true,['35471']=true,['25838']=true,['90059']=true,['90060']=true,['90061']=true,['90062']=true,['90063']=true,['90064']=true,['90065']=true,['90066']=true,['90088']=true,['90089']=true,['90090']=true,['90091']=true,['90092']=true,['90093']=true,['90094']=true,['90095']=true,['90119']=true,['90120']=true,['90121']=true,['90122']=true,['90123']=true,['90124']=true,['90125']=true,['90126']=true,['77667']=true,['77670']=true,['77671']=true,['77697']=true,['77700']=true,['77701']=true,['77874']=true,['77876']=true,['77878']=true,['77907']=true,['77908']=true,['77909']=true,['77666']=true,['77668']=true,['77669']=true,['77696']=true,['77698']=true,['77699']=true,['77875']=true,['77877']=true,['77879']=true,['77904']=true,['77905']=true,['77906']=true,['77742']=true,['77746']=true,['77748']=true,['77752']=true,['77813']=true,['77815']=true,['77819']=true,['77820']=true,['77744']=true,['77745']=true,['77749']=true,['77811']=true,['77812']=true,['77818']=true,['77821']=true,['77720']=true,['77721']=true,['77730']=true,['77731']=true,['77747']=true,['77750']=true,['77816']=true,['77817']=true,['77598']=true,['77599']=true,['77600']=true,['77601']=true,['77602']=true,['77603']=true,['77604']=true,['77633']=true,['77634']=true,['77635']=true,['77636']=true,['77637']=true,['77638']=true,['77639']=true,['77736']=true,['77737']=true,['77738']=true,['77739']=true,['77740']=true,['77741']=true,['77743']=true,['77805']=true,['77806']=true,['77807']=true,['77808']=true,['77809']=true,['77810']=true,['77814']=true,['77605']=true,['77640']=true,['77753']=true,['77822']=true,['28158']=true,['22987']=true,['22992']=true,['95519']=true,['95521']=true,['95528']=true,['95530']=true,['83159']=true,['83163']=true,['83168']=true,['83172']=true,['83177']=true,['83181']=true,['83186']=true,['83190']=true,['83195']=true,['83199']=true,['83204']=true,['83208']=true,['83213']=true,['83217']=true,['83222']=true,['83226']=true,['82615']=true,['82619']=true,['82624']=true,['82628']=true,['82633']=true,['82637']=true,['82642']=true,['82646']=true,['82651']=true,['82655']=true,['82660']=true,['82664']=true,['82669']=true,['82673']=true,['82678']=true,['82682']=true,['81580']=true,['81584']=true,['81589']=true,['81593']=true,['81598']=true,['81602']=true,['81607']=true,['81611']=true,['81616']=true,['81620']=true,['81625']=true,['81629']=true,['81634']=true,['81638']=true,['81643']=true,['81647']=true,['70114']=true,['70122']=true,['62417']=true,['62420']=true,['62431']=true,['62433']=true,['62358']=true,['62381']=true,['62446']=true,['62374']=true,['62404']=true,['62405']=true,['62425']=true,['62426']=true,['72664']=true,['72665']=true,['72666']=true,['72667']=true,['72668']=true,['72669']=true,['72670']=true,['72671']=true,['72672']=true,['72673']=true,['72674']=true,['72675']=true,['72676']=true,['72677']=true,['72678']=true,['72679']=true,['72681']=true,['72682']=true,['72683']=true,['72684']=true,['72685']=true,['72686']=true,['72687']=true,['72688']=true,['72689']=true,['72690']=true,['72691']=true,['72692']=true,['72693']=true,['72694']=true,['72695']=true,['72696']=true,['88614']=true,['88615']=true,['88616']=true,['88617']=true,['88618']=true,['88619']=true,['88620']=true,['88621']=true,['88623']=true,['88624']=true,['88625']=true,['88626']=true,['88627']=true,['88628']=true,['88629']=true,['88630']=true,['44181']=true,['44203']=true,['44297']=true,['44303']=true,['44179']=true,['44194']=true,['44258']=true,['44182']=true,['44204']=true,['44295']=true,['44305']=true,['44248']=true,['44257']=true,['44109']=true,['44110']=true,['44122']=true,['44171']=true,['44189']=true,['44059']=true,['44060']=true,['29135']=true,['29136']=true,['29180']=true,['30835']=true,['35376']=true,['35377']=true,['35378']=true,['35379']=true,['35380']=true,['35381']=true,['35382']=true,['35383']=true,['35384']=true,['35385']=true,['35386']=true,['35387']=true,['35388']=true,['35389']=true,['35390']=true,['35391']=true,['35392']=true,['35393']=true,['35394']=true,['35395']=true,['35472']=true,['35473']=true,['35474']=true,['35475']=true,['64644']=true,['90068']=true,['90069']=true,['90070']=true,['90071']=true,['90072']=true,['90073']=true,['90074']=true,['90075']=true,['90127']=true,['90128']=true,['90129']=true,['90130']=true,['90131']=true,['90132']=true,['90133']=true,['90134']=true,['77673']=true,['77674']=true,['77676']=true,['77704']=true,['77705']=true,['77707']=true,['77880']=true,['77882']=true,['77883']=true,['77910']=true,['77913']=true,['77914']=true,['77672']=true,['77675']=true,['77677']=true,['77702']=true,['77703']=true,['77706']=true,['77881']=true,['77884']=true,['77885']=true,['77911']=true,['77912']=true,['77915']=true,['77642']=true,['77645']=true,['77762']=true,['77763']=true,['77765']=true,['77766']=true,['77831']=true,['77832']=true,['77641']=true,['77643']=true,['77760']=true,['77761']=true,['77768']=true,['77769']=true,['77829']=true,['77834']=true,['77644']=true,['77646']=true,['77722']=true,['77723']=true,['77764']=true,['77767']=true,['77830']=true,['77833']=true,['77606']=true,['77607']=true,['77608']=true,['77609']=true,['77610']=true,['77611']=true,['77612']=true,['77754']=true,['77755']=true,['77756']=true,['77757']=true,['77758']=true,['77759']=true,['77823']=true,['77824']=true,['77825']=true,['77826']=true,['77827']=true,['77828']=true,['77835']=true,['28162']=true,['22985']=true,['22993']=true,['95522']=true,['95525']=true,['95531']=true,['95534']=true,['83160']=true,['83164']=true,['83169']=true,['83173']=true,['83178']=true,['83182']=true,['83187']=true,['83191']=true,['83196']=true,['83200']=true,['83205']=true,['83209']=true,['83214']=true,['83218']=true,['83223']=true,['83227']=true,['82616']=true,['82620']=true,['82625']=true,['82629']=true,['82634']=true,['82638']=true,['82643']=true,['82647']=true,['82652']=true,['82656']=true,['82661']=true,['82665']=true,['82670']=true,['82674']=true,['82679']=true,['82683']=true,['81581']=true,['81585']=true,['81590']=true,['81594']=true,['81599']=true,['81603']=true,['81608']=true,['81612']=true,['81617']=true,['81621']=true,['81626']=true,['81630']=true,['81635']=true,['81639']=true,['81644']=true,['81648']=true,['70115']=true,['70123']=true,['62363']=true,['62385']=true,['62380']=true,['62409']=true,['62429']=true,['62445']=true,['62353']=true,['62407']=true,['62423']=true,['62439']=true,['72698']=true,['72699']=true,['72700']=true,['72701']=true,['72702']=true,['72703']=true,['72704']=true,['72705']=true,['72889']=true,['72890']=true,['72891']=true,['72892']=true,['72893']=true,['72894']=true,['72895']=true,['72896']=true,['72902']=true,['72903']=true,['72904']=true,['72905']=true,['72906']=true,['72907']=true,['72908']=true,['72909']=true,['72910']=true,['72911']=true,['72912']=true,['72913']=true,['72914']=true,['72915']=true,['72916']=true,['72917']=true,['44182']=true,['44204']=true,['44295']=true,['44305']=true,['44248']=true,['44257']=true,['44183']=true,['44205']=true,['44296']=true,['44306']=true,['44176']=true,['44195']=true,['44198']=true,['44201']=true,['44247']=true,['44111']=true,['44112']=true,['44120']=true,['44121']=true,['44123']=true,['44197']=true,['44239']=true,['44240']=true,['44243']=true,['44057']=true,['44058']=true,['40440']=true,['40441']=true,['40442']=true,['40443']=true,['40444']=true,['29127']=true,['29134']=true,['29184']=true,['35402']=true,['35403']=true,['35404']=true,['35405']=true,['35406']=true,['35407']=true,['35408']=true,['35409']=true,['35410']=true,['35411']=true,['35412']=true,['35413']=true,['35414']=true,['35415']=true,['35416']=true,['35476']=true,['35477']=true,['35478']=true,['90049']=true,['90050']=true,['90051']=true,['90052']=true,['90053']=true,['90054']=true,['90055']=true,['90056']=true,['90096']=true,['90097']=true,['90098']=true,['90099']=true,['90100']=true,['90101']=true,['90102']=true,['90103']=true,['90147']=true,['90148']=true,['90149']=true,['90150']=true,['90151']=true,['90152']=true,['90153']=true,['90154']=true,['77687']=true,['77688']=true,['77689']=true,['77714']=true,['77715']=true,['77718']=true,['77892']=true,['77894']=true,['77897']=true,['77923']=true,['77924']=true,['77927']=true,['77684']=true,['77685']=true,['77686']=true,['77716']=true,['77717']=true,['77719']=true,['77893']=true,['77895']=true,['77896']=true,['77922']=true,['77925']=true,['77926']=true,['77664']=true,['77665']=true,['77859']=true,['77867']=true,['77868']=true,['77869']=true,['77871']=true,['77872']=true,['38661']=true,['38663']=true,['38665']=true,['38666']=true,['38667']=true,['38668']=true,['38669']=true,['38670']=true,['77661']=true,['77662']=true,['77663']=true,['77858']=true,['77864']=true,['77865']=true,['77866']=true,['77873']=true,['77726']=true,['77727']=true,['77734']=true,['77735']=true,['77862']=true,['77863']=true,['77928']=true,['77929']=true,['77621']=true,['77622']=true,['77623']=true,['77624']=true,['77625']=true,['77626']=true,['77653']=true,['77654']=true,['77655']=true,['77656']=true,['77657']=true,['77658']=true,['77659']=true,['77853']=true,['77854']=true,['77855']=true,['77856']=true,['77857']=true,['77860']=true,['77861']=true,['34648']=true,['34649']=true,['34650']=true,['34651']=true,['34652']=true,['34653']=true,['34655']=true,['34656']=true,['77660']=true,['95520']=true,['95524']=true,['95529']=true,['95533']=true,['83161']=true,['83165']=true,['83166']=true,['83170']=true,['83174']=true,['83175']=true,['83179']=true,['83183']=true,['83184']=true,['83188']=true,['83192']=true,['83193']=true,['83197']=true,['83201']=true,['83202']=true,['83206']=true,['83210']=true,['83211']=true,['83215']=true,['83219']=true,['83220']=true,['83224']=true,['83228']=true,['83229']=true,['82617']=true,['82621']=true,['82622']=true,['82626']=true,['82630']=true,['82631']=true,['82635']=true,['82639']=true,['82640']=true,['82644']=true,['82648']=true,['82649']=true,['82653']=true,['82657']=true,['82658']=true,['82662']=true,['82666']=true,['82667']=true,['82671']=true,['82675']=true,['82676']=true,['82680']=true,['82684']=true,['82685']=true,['81582']=true,['81586']=true,['81587']=true,['81591']=true,['81595']=true,['81596']=true,['81600']=true,['81604']=true,['81605']=true,['81609']=true,['81613']=true,['81614']=true,['81618']=true,['81622']=true,['81623']=true,['81627']=true,['81631']=true,['81632']=true,['81636']=true,['81640']=true,['81641']=true,['81645']=true,['81649']=true,['81650']=true,['70108']=true,['70116']=true,['70117']=true,['70120']=true,['70121']=true,['62365']=true,['62384']=true,['62418']=true,['62432']=true,['62448']=true,['62449']=true,['62359']=true,['62382']=true,['62408']=true,['62410']=true,['62428']=true,['62430']=true,['62355']=true,['62438']=true,['72918']=true,['72919']=true,['72920']=true,['72921']=true,['72922']=true,['72923']=true,['72924']=true,['72925']=true,['72929']=true,['72930']=true,['72931']=true,['72932']=true,['72933']=true,['72934']=true,['72935']=true,['72936']=true,['72937']=true,['72938']=true,['72939']=true,['72940']=true,['72941']=true,['72942']=true,['72943']=true,['72944']=true,['72945']=true,['72946']=true,['72947']=true,['72948']=true,['72949']=true,['72950']=true,['72951']=true,['72952']=true,['72955']=true,['72956']=true,['72957']=true,['72958']=true,['72959']=true,['72960']=true,['72961']=true,['72962']=true,['72963']=true,['72964']=true,['72965']=true,['72966']=true,['72967']=true,['72968']=true,['72969']=true,['72970']=true,['72971']=true,['72972']=true,['72973']=true,['72974']=true,['72975']=true,['72976']=true,['72977']=true,['72978']=true,['44183']=true,['44205']=true,['44296']=true,['44306']=true,['44176']=true,['44195']=true,['44198']=true,['44201']=true,['44247']=true,['29278']=true,['29282']=true,['29286']=true,['29291']=true,['31113']=true,['34675']=true,['34676']=true,['34677']=true,['34678']=true,['34679']=true,['34680']=true,['29128']=true,['29132']=true,['29139']=true,['29140']=true,['29145']=true,['29146']=true,['29168']=true,['29169']=true,['29173']=true,['29179']=true,['29276']=true,['29280']=true,['29284']=true,['29288']=true,['30841']=true,['32538']=true,['32539']=true,['29277']=true,['29281']=true,['29285']=true,['29289']=true,['32864']=true,['31341']=true,['29119']=true,['29123']=true,['29126']=true,['29170']=true,['29172']=true,['29176']=true,['29177']=true,['29181']=true,['32770']=true,['32771']=true,['30834']=true,['25824']=true,['25826']=true,['21200']=true,['21205']=true,['21210']=true,['52252']=true,['21199']=true,['21204']=true,['21209']=true,['49052']=true,['49054']=true,['21198']=true,['21203']=true,['21208']=true,['32695']=true,['38662']=true,['38664']=true,['38671']=true,['38672']=true,['38674']=true,['38675']=true,['39320']=true,['39322']=true,['32694']=true,['21394']=true,['21397']=true,['21400']=true,['21403']=true,['21406']=true,['21409']=true,['21412']=true,['21415']=true,['21418']=true,['21197']=true,['21202']=true,['21207']=true,['21393']=true,['21396']=true,['21399']=true,['21402']=true,['21405']=true,['21408']=true,['21411']=true,['21414']=true,['21417']=true,['17904']=true,['17909']=true,['21196']=true,['21201']=true,['21206']=true,['65274']=true,['65360']=true,['17902']=true,['17903']=true,['17907']=true,['17908']=true,['40476']=true,['40477']=true,['17690']=true,['17691']=true,['17900']=true,['17901']=true,['17905']=true,['17906']=true,['34657']=true,['34658']=true,['34659']=true,['38147']=true,['21766']=true,['64886']=true,['64887']=true,['64888']=true,['64889']=true,['64890']=true,['64891']=true,['64892']=true,['64893']=true,['64894']=true,['64895']=true,['64896']=true,['64897']=true,['64898']=true,['64899']=true,['64900']=true,['64901']=true,['64902']=true,['64903']=true,['64905']=true,['64906']=true,['64907']=true,['64908']=true,['64909']=true,['64910']=true,['64911']=true,['64912']=true,['64913']=true,['64914']=true,['64915']=true,['64916']=true,['64917']=true,['64918']=true,['64919']=true,['64920']=true,['64921']=true,['64922']=true,['4614']=true,['22990']=true,['34484']=true,['34486']=true,['23705']=true,['23709']=true,['38309']=true,['38310']=true,['38311']=true,['38312']=true,['38313']=true,['38314']=true,['40643']=true,['43300']=true,['43348']=true,['43349']=true,['98162']=true,['35279']=true,['35280']=true,['40483']=true,['46874']=true,['89401']=true,['89784']=true,['89795']=true,['89796']=true,['89797']=true,['89798']=true,['89799']=true,['89800']=true,['95591']=true,['95592']=true,['97131']=true,['50384']=true,['50386']=true,['50387']=true,['50388']=true,['52570']=true,['50375']=true,['50376']=true,['50377']=true,['50378']=true,['52569']=true,['72982']=true,['72983']=true,['72984']=true,['73004']=true,['73005']=true,['73013']=true,['73014']=true,['73015']=true,['73016']=true,['73017']=true,['73018']=true,['73019']=true,['73020']=true,['73021']=true,['73022']=true,['73023']=true,['73024']=true,['73025']=true,['73026']=true,['73027']=true,['73042']=true,['73060']=true,['73061']=true,['73062']=true,['73063']=true,['73064']=true,['73065']=true,['73066']=true,['73067']=true,['73068']=true,['73101']=true,['73102']=true,['73103']=true,['73104']=true,['73105']=true,['73106']=true,['73107']=true,['73108']=true,['73109']=true,['73110']=true,['73111']=true,['73112']=true,['73113']=true,['73114']=true,['73115']=true,['73116']=true,['73117']=true,['73118']=true,['73119']=true,['73120']=true,['73121']=true,['73122']=true,['73123']=true,['73124']=true,['73125']=true,['73126']=true,['73127']=true,['73128']=true,['73129']=true,['73130']=true,['73131']=true,['73132']=true,['73133']=true,['73134']=true,['73135']=true,['73136']=true,['73137']=true,['73138']=true,['73139']=true,['73140']=true,['73141']=true,['73142']=true,['73143']=true,['73144']=true,['73145']=true,['73146']=true,['73147']=true,['73148']=true,['73149']=true,['73150']=true,['73151']=true,['73152']=true,['73153']=true,['73154']=true,['73155']=true,['73156']=true,['73157']=true,['73158']=true,['73159']=true,['73160']=true,['73161']=true,['73162']=true,['73163']=true,['73164']=true,['73165']=true,['73166']=true,['73167']=true,['73168']=true,['73169']=true,['73170']=true,['73306']=true,['73307']=true,['73308']=true,['73309']=true,['73310']=true,['73311']=true,['73312']=true,['73313']=true,['73314']=true,['73315']=true,['73316']=true,['73317']=true,['73318']=true,['73319']=true,['73320']=true,['73321']=true,['73322']=true,['73323']=true,['73324']=true,['88632']=true,['88633']=true,['88634']=true,['88635']=true,['88636']=true,['88637']=true,['88638']=true,['88639']=true,['88640']=true,['88641']=true,['88642']=true,['88643']=true,['88644']=true,['88645']=true,['88646']=true,['88647']=true,['88667']=true,['44073']=true,['44074']=true,['44283']=true,['44167']=true,['44188']=true,['44216']=true,['44242']=true,['38452']=true,['38453']=true,['38458']=true,['38459']=true,['38462']=true,['38463']=true,['29297']=true,['29301']=true,['29305']=true,['29309']=true,['29296']=true,['29308']=true,['32485']=true,['32486']=true,['32487']=true,['32488']=true,['32489']=true,['32490']=true,['32491']=true,['32492']=true,['32493']=true,['32649']=true,['32757']=true,['29295']=true,['29299']=true,['29303']=true,['29306']=true,['29300']=true,['29304']=true,['29279']=true,['29283']=true,['29287']=true,['29290']=true,['29294']=true,['29298']=true,['29302']=true,['29307']=true,['29278']=true,['29282']=true,['29286']=true,['29291']=true,['98146']=true,['98147']=true,['98148']=true,['98149']=true,['98150']=true,['98335']=true,['92782']=true,['92783']=true,['92784']=true,['92785']=true,['92786']=true,['92787']=true,['93391']=true,['93392']=true,['93393']=true,['93394']=true,['93395']=true,['95425']=true,['95427']=true,['95428']=true,['95429']=true,['95430']=true,['88166']=true,['88167']=true,['88168']=true,['88169']=true,['75274']=true,['83230']=true,['83231']=true,['83232']=true,['83233']=true,['83234']=true,['83235']=true,['83236']=true,['83237']=true,['83238']=true,['83239']=true,['83245']=true,['83246']=true,['83247']=true,['83248']=true,['83249']=true,['83255']=true,['83256']=true,['83257']=true,['83258']=true,['83259']=true,['83272']=true,['83273']=true,['86567']=true,['86570']=true,['86572']=true,['86576']=true,['86579']=true,['86585']=true,['86587']=true,['87780']=true,['82686']=true,['82687']=true,['82688']=true,['82689']=true,['82690']=true,['82691']=true,['82692']=true,['82693']=true,['82694']=true,['82695']=true,['82696']=true,['82697']=true,['82698']=true,['82699']=true,['82700']=true,['82701']=true,['82702']=true,['82703']=true,['82704']=true,['82705']=true,['82718']=true,['82719']=true,['81651']=true,['81652']=true,['81653']=true,['81654']=true,['81655']=true,['81656']=true,['81657']=true,['81658']=true,['81659']=true,['81660']=true,['81661']=true,['81662']=true,['81663']=true,['81664']=true,['81665']=true,['81666']=true,['81667']=true,['81668']=true,['81669']=true,['81670']=true,['81683']=true,['81684']=true,['70105']=true,['70106']=true,['70107']=true,['70110']=true,['70112']=true,['70113']=true,['70119']=true,['70124']=true,['70126']=true,['70127']=true,['70141']=true,['70142']=true,['70143']=true,['70144']=true,['58483']=true,['62362']=true,['62383']=true,['62416']=true,['62434']=true,['62447']=true,['62463']=true,['62464']=true,['62465']=true,['62466']=true,['62467']=true,['64645']=true,['64904']=true,['68775']=true,['68776']=true,['68777']=true,['69764']=true,['62348']=true,['62350']=true,['62351']=true,['62352']=true,['62357']=true,['62361']=true,['62378']=true,['62415']=true,['62427']=true,['62440']=true,['62354']=true,['62375']=true,['62376']=true,['62377']=true,['62436']=true,['62437']=true,['65175']=true,['65176']=true,['50398']=true,['50400']=true,['50402']=true,['50404']=true,['52572']=true,['50397']=true,['50399']=true,['50401']=true,['50403']=true,['52571']=true}
	}

	local AllowedItemIDs = {
		['109129']='OVERRIDE_MILLABLE',
		['109128']='OVERRIDE_MILLABLE',
		['109127']='OVERRIDE_MILLABLE',
		['109126']='OVERRIDE_MILLABLE',
		['109125']='OVERRIDE_MILLABLE',
		['109124']='OVERRIDE_MILLABLE',
		['123918']='OVERRIDE_PROSPECTABLE',
		['123919']='OVERRIDE_PROSPECTABLE',
	}

	local function IsThisBreakable(link)
		local _, _, quality = GetItemInfo(link)
		if(IsEquippableItem(link) and quality and quality > 1 and quality < 5) then
			return not BreakableFilter["SafeItems"][match(link, 'item:(%d+):')]
		end
	end

	local function IsThisOpenable(link)
		return BreakableFilter["Pickables"][match(link, 'item:(%d+)')]
	end

	local function ScanTooltip(self, itemLink)
		for index = 1, self:NumLines() do
			local info = BreakStuff_Cache[_G['GameTooltipTextLeft' .. index]:GetText()]
			if(info) then
				return unpack(info)
			end
		end
		local itemID = itemLink:match(":(%w+)")
		local override = AllowedItemIDs[itemID]
		if(override and BreakStuff_Cache[override]) then
			return unpack(BreakStuff_Cache[override])
		end
	end

	local function CloneTooltip()
		twipe(BreakStuffHandler.TipLines)
		for index = 1, GameTooltip:NumLines() do
			local text = _G['GameTooltipTextLeft' .. index]:GetText()
			if(text) then
				BreakStuffHandler.TipLines[#BreakStuffHandler.TipLines+1] = text
			end
		end
	end

	local function DoIHaveAKey()
		for key in pairs(SkellyKeys) do
			if(GetItemCount(key) > 0) then
				return key
			end
		end
	end

	local function ApplyButton(itemLink, spell, r, g, b)
		local slot = GetMouseFocus()
		local bag = slot:GetParent():GetID()

		if(GetContainerItemLink(bag, slot:GetID()) == itemLink) then
			--CloneTooltip()
			BreakStuffHandler:SetAttribute('spell', spell)
			BreakStuffHandler:SetAttribute('target-bag', bag)
			BreakStuffHandler:SetAttribute('target-slot', slot:GetID())
			BreakStuffHandler:SetAllPoints(slot)
			BreakStuffHandler:Show()

			AutoCastShine_AutoCastStart(BreakStuffHandler, r, g, b)
		end
	end

	function BreakStuffParser(self)
		local item, link = self:GetItem()
		if(item and not InCombatLockdown() and (BreakStuffHandler.ReadyToSmash == true)) then
			local spell, r, g, b = ScanTooltip(self, link)
			local rr, gg, bb = 1, 1, 1
			if(spell) then
				ApplyButton(link, spell, r, g, b)
			else
				spell = "Open"
				if(DE and IsThisBreakable(link)) then
					rr, gg, bb = 0.5, 0.5, 1
					ApplyButton(link, DE, rr, gg, bb)
				elseif(PICK and IsThisOpenable(link)) then
					rr, gg, bb = 0, 1, 1
					ApplyButton(link, PICK, rr, gg, bb)
				elseif(SMITH and IsThisOpenable(link)) then
					rr, gg, bb = 0, 1, 1
					local hasKey = DoIHaveAKey()
					ApplyButton(link, hasKey, rr, gg, bb)
				end
			end
			BreakStuffHandler.TTextLeft = spell
			BreakStuffHandler.TTextRight = item
		end
	end
end
--[[
##########################################################
BUILD FOR PACKAGE
##########################################################
]]--
local BreakStuff_OnModifier = function(self, arg)
	if(not self:IsShown() and not arg and (self.ReadyToSmash == false)) then return; end
	if(InCombatLockdown()) then
		self:SetAlpha(0)
		self:RegisterEvent('PLAYER_REGEN_ENABLED')
	else
		self:ClearAllPoints()
		self:SetAlpha(1)
		self:Hide()
		AutoCastShine_AutoCastStop(self)
	end
end

BreakStuffHandler.MODIFIER_STATE_CHANGED = BreakStuff_OnModifier;

local BreakStuff_OnHide = function()
	BreakStuffHandler.ReadyToSmash = false
	BreakStuffButton.ttText = "BreakStuff : OFF";
end

local BreakStuff_OnEnter = function(self)
	GameTooltip:SetOwner(self,"ANCHOR_TOP",0,4)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(self.ttText)
	GameTooltip:AddLine(self.subText)
	if self.ttText2 then
		GameTooltip:AddLine(' ')
		GameTooltip:AddDoubleLine(self.ttText2,self.ttText2desc,1,1,1)
	end
	if BreakStuffHandler.ReadyToSmash ~= true then
		self:SetPanelColor("class")
		self.icon:SetGradient(unpack(SV.media.gradient.highlight))
	end
	GameTooltip:Show()
end

local BreakStuff_OnLeave = function(self)
	if BreakStuffHandler.ReadyToSmash ~= true then
		self:SetPanelColor("default")
		self.icon:SetGradient("VERTICAL", 0.5, 0.53, 0.55, 0.8, 0.8, 1)
		GameTooltip:Hide()
	end
end

local BreakStuff_OnClick = function(self)
	if InCombatLockdown() then print(ERR_NOT_IN_COMBAT) return end
	if BreakStuffHandler.ReadyToSmash == true then
		BreakStuffHandler:MODIFIER_STATE_CHANGED()
		BreakStuffHandler.ReadyToSmash = false
		self.ttText = "BreakStuff : OFF";
		self:SetPanelColor("default")
		self.icon:SetGradient("VERTICAL", 0.5, 0.53, 0.55, 0.8, 0.8, 1)
	else
		BreakStuffHandler.ReadyToSmash = true
		self.ttText = "BreakStuff : ON";
		self:SetPanelColor("green")
		self.icon:SetGradient(unpack(SV.media.gradient.green))
		if(SV.Inventory and SV.Inventory.MasterFrame) then
			if(not SV.Inventory.MasterFrame:IsShown()) then
				GameTooltip:Hide()
				SV.Inventory.MasterFrame:Show()
				SV.Inventory.MasterFrame:RefreshBags()
				if(SV.Tooltip) then
					SV.Tooltip.GameTooltip_SetDefaultAnchor(GameTooltip,self)
				end
			end
		end
	end
	GameTooltip:ClearLines()
	GameTooltip:AddLine(self.ttText)
	GameTooltip:AddLine(self.subText)
end

function BreakStuffHandler:PLAYER_REGEN_ENABLED()
	self:UnregisterEvent('PLAYER_REGEN_ENABLED')
	BreakStuff_OnModifier(self)
end

function MOD:PLAYER_REGEN_ENABLED()
	self:UnregisterEvent('PLAYER_REGEN_ENABLED')
	self:LoadBreakStuff()
end

local SetClonedTip = function(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 4)
	GameTooltip:ClearLines()
	GameTooltip:AddDoubleLine(self.TTextLeft, self.TTextRight, 0,1,0,1,1,1)
	-- for index = 1, #self.TipLines do
	-- 	GameTooltip:AddLine(self.TipLines[index])
	-- end

	GameTooltip:Show()
end

local function LoadToolBreakStuff()
	if(InCombatLockdown()) then MOD:RegisterEvent("PLAYER_REGEN_ENABLED"); return end
	local allowed, spellListing, spellName, _ = false, {};

	if(IsSpellKnown(51005)) then
		--print("Milling")
		allowed = true
		spellName,_ = GetSpellInfo(51005)
		BreakStuff_Cache[ITEM_MILLABLE] = {spellName, 0.5, 1, 0.5}
		BreakStuff_Cache['OVERRIDE_MILLABLE'] = {spellName, 0.5, 1, 0.5}
    local count = #spellListing + 1;
    spellListing[count] = spellName;
	end

	if(IsSpellKnown(31252)) then
		--print("Prospecting")
		allowed = true
		spellName,_ = GetSpellInfo(31252)
		BreakStuff_Cache[ITEM_PROSPECTABLE] = {spellName, 1, 0.33, 0.33}
		BreakStuff_Cache['OVERRIDE_PROSPECTABLE'] = {spellName, 1, 0.33, 0.33}
    local count = #spellListing + 1;
    spellListing[count] = spellName;
	end

	if(IsSpellKnown(13262)) then
		--print("Enchanting")
		allowed = true
		DE,_ = GetSpellInfo(13262)
    local count = #spellListing + 1;
    spellListing[count] = DE;
	end

	if(IsSpellKnown(1804)) then
		--print("Lockpicking")
		allowed = true
		PICK,_ = GetSpellInfo(1804)
    local count = #spellListing + 1;
    spellListing[count] = PICK;
	end

	if(IsSpellKnown(2018)) then
		--print("Blacksmithing")
		allowed = true
		SMITH,_ = GetSpellBookItemInfo((GetSpellInfo(2018)))
    local count = #spellListing + 1;
    spellListing[count] = SMITH;
	end

	MOD.BreakStuffLoaded = true;

	if not allowed then return end

	BreakStuffButton:SetParent(MOD.BottomRight.Bar.ToolBar)
	local size = MOD.BottomRight.Bar.ToolBar:GetHeight()
	BreakStuffButton:SetSize(size, size)
	BreakStuffButton:SetPoint("RIGHT", MOD.BottomRight.Bar.ToolBar, "LEFT", -6, 0)
	BreakStuffButton.icon:SetTexture(SV.media.dock.breakStuffIcon)
	BreakStuffButton:Show();
	BreakStuffButton:SetStyle("DockButton")

	BreakStuffButton:SetScript("OnEnter", BreakStuff_OnEnter);
	BreakStuffButton:SetScript("OnLeave", BreakStuff_OnLeave);
	BreakStuffButton:SetScript("OnClick", BreakStuff_OnClick);
	BreakStuffButton:SetScript("OnHide", BreakStuff_OnHide)
	BreakStuffButton.subText = tcat(spellListing,"\n");

	BreakStuffHandler:RegisterForClicks('AnyUp')
	BreakStuffHandler:SetFrameStrata("TOOLTIP")
	BreakStuffHandler:SetAttribute("type1","spell")
	BreakStuffHandler:SetScript("OnEnter", SetClonedTip)
	BreakStuffHandler:SetScript("OnLeave", BreakStuff_OnModifier)
	BreakStuffHandler:RegisterEvent("MODIFIER_STATE_CHANGED")
	BreakStuffHandler:Hide()

	GameTooltip:HookScript('OnTooltipSetItem', BreakStuffParser)

	for _, sparks in pairs(BreakStuffHandler.sparkles) do
		sparks:SetHeight(sparks:GetHeight() * 3)
		sparks:SetWidth(sparks:GetWidth() * 3)
	end
end

function MOD:CloseBreakStuff()
	if((not SV.db.Dock.dockTools.breakstuff) or self.BreakStuffLoaded) then return end
	BreakStuffHandler:MODIFIER_STATE_CHANGED()
	BreakStuffHandler.ReadyToSmash = false
	BreakStuffButton.ttText = "BreakStuff : OFF";
	BreakStuffButton.icon:SetGradient("VERTICAL", 0.5, 0.53, 0.55, 0.8, 0.8, 1)
end

function MOD:LoadBreakStuff()
	if((not SV.db.Dock.dockTools.breakstuff) or self.BreakStuffLoaded) then return end
	SV.Timers:ExecuteTimer(LoadToolBreakStuff, 5)
end
