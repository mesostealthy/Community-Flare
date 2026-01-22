-- initialize
local LibStub = LibStub
local ADDON_NAME, NS = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
if (not L or not NS.CommFlare) then return end

-- localize stuff
local _G                                          = _G
local GetSpellName                                = _G.C_Spell.GetSpellName
local pairs                                       = _G.pairs
local tinsert                                     = _G.table.insert

-- epic battlegrounds
NS.CommFlare.EpicBattlegrounds = {}
tinsert(NS.CommFlare.EpicBattlegrounds, { name = L["Random Epic Battleground"], id = 1, prefix = "EPIC" })
tinsert(NS.CommFlare.EpicBattlegrounds, { name = L["Alterac Valley"], id = 2, prefix = "AV" })
tinsert(NS.CommFlare.EpicBattlegrounds, { name = L["Ashran"], id = 3, prefix = "ASH" })
tinsert(NS.CommFlare.EpicBattlegrounds, { name = L["Battle for Wintergrasp"], id = 4, prefix = "WG" })
tinsert(NS.CommFlare.EpicBattlegrounds, { name = L["Isle of Conquest"], id = 5, prefix = "IOC" })
tinsert(NS.CommFlare.EpicBattlegrounds, { name = L["Korrak's Revenge"], id = 6, prefix = "KR" })

-- random battlegrounds
NS.CommFlare.RandomBattlegrounds = {}
tinsert(NS.CommFlare.RandomBattlegrounds, { name = RANDOM_BATTLEGROUND, id = 1, prefix = "RBG" })
tinsert(NS.CommFlare.RandomBattlegrounds, { name = L["Warsong Gulch"], id = 2, prefix = "WSG" })
tinsert(NS.CommFlare.RandomBattlegrounds, { name = L["Arathi Basin"], id = 3, prefix = "AB" })
tinsert(NS.CommFlare.RandomBattlegrounds, { name = L["Deephaul Ravine"], id = 4, prefix = "DHR" })
tinsert(NS.CommFlare.RandomBattlegrounds, { name = L["Eye of the Storm"], id = 5, prefix = "EOTS" })
tinsert(NS.CommFlare.RandomBattlegrounds, { name = L["The Battle for Gilneas"], id = 6, prefix = "BFG" })
tinsert(NS.CommFlare.RandomBattlegrounds, { name = L["Twin Peaks"], id = 7, prefix = "TWP" })
tinsert(NS.CommFlare.RandomBattlegrounds, { name = L["Silvershard Mines"], id = 8, prefix = "SSM" })
tinsert(NS.CommFlare.RandomBattlegrounds, { name = L["Temple of Kotmogu"], id = 9, prefix = "TOK" })
tinsert(NS.CommFlare.RandomBattlegrounds, { name = L["Seething Shore"], id = 10, prefix = "SSH" })
tinsert(NS.CommFlare.RandomBattlegrounds, { name = L["Deepwind Gorge"], id = 11, prefix = "DWG" })

-- brawls
NS.CommFlare.Brawls = {
	-- player queued strings?
	["Arathi Basin Winter"] = { id = 1, prefix = "BLIZZ" },
	["Classic Ashran"] = { id = 2, prefix = "CLASH" },
	["Comp Stomp"] = { id = 3, prefix = "COMP" },
	["Cooking: Impossible"] = { id = 4, prefix = "COOK" },
	["Deep Six"] = { id = 5, prefix = "DEEP" },
	["Gravity Lapse"] = { id = 7, prefix = "GRAV" },
	["Packed House"] = { id = 8, prefix = "PACK" },
	["All Arenas"] = { id = 8, prefix = "PACK" },
	["Shado-Pan Showdown"] = { id = 9, prefix = "SHAD" },
	["Temple of Hotmogu"] = { id = 11, prefix = "BRTOH" },
	["Warsong Scramble"] = { id = 12, prefix = "BRWSG" },
}
tinsert(NS.CommFlare.Brawls, { name = L["Brawl: Arathi Blizzard"], id = 1, prefix = "BLIZZ" })
tinsert(NS.CommFlare.Brawls, { name = L["Brawl: Classic Ashran"], id = 2, prefix = "CLASH" })
tinsert(NS.CommFlare.Brawls, { name = L["Brawl: Comp Stomp"], id = 3, prefix = "COMP" })
tinsert(NS.CommFlare.Brawls, { name = L["Brawl: Cooking: Impossible"], id = 4, prefix = "COOK" })
tinsert(NS.CommFlare.Brawls, { name = L["Brawl: Deep Six"], id = 5, prefix = "DEEP" })
tinsert(NS.CommFlare.Brawls, { name = L["Brawl: Deepwind Dunk"], id = 6, prefix = "DUNK" })
tinsert(NS.CommFlare.Brawls, { name = L["Brawl: Gravity Lapse"], id = 7, prefix = "GRAV" })
tinsert(NS.CommFlare.Brawls, { name = L["Brawl: Packed House"], id = 8, prefix = "PACK" })
tinsert(NS.CommFlare.Brawls, { name = L["Brawl: Shado-Pan Showdown"], id = 9, prefix = "SHAD" })
tinsert(NS.CommFlare.Brawls, { name = L["Brawl: Southshore vs. Tarren Mill"], id = 10, prefix = "SSvTM" })
tinsert(NS.CommFlare.Brawls, { name = L["Brawl: Temple of Hotmogu"], id = 11, prefix = "BRTOH" })
tinsert(NS.CommFlare.Brawls, { name = L["Brawl: Warsong Scramble"], id = 12, prefix = "BRWSG" })
tinsert(NS.CommFlare.Brawls, { name = L["Random Training Grounds"], id = 13, prefix = "RTG" })
tinsert(NS.CommFlare.Brawls, { name = "Arathi Basin Training Grounds", id = 14, prefix = "TGAB" })		-- TODO: localize
tinsert(NS.CommFlare.Brawls, { name = "Silvershard Mines Training Grounds", id = 15, prefix = "TGSSM" })	-- TODO: localize
tinsert(NS.CommFlare.Brawls, { name = "The Battle for Gilneas Training Grounds", id = 16, prefix = "TGBFG" })	-- TODO: localize

-- hearth stone spells
NS.CommFlare.HearthStoneSpells = {
	[8690] = "Hearthstone",
	[39937] = "There's No Place Like Home",
	[59317] = "Teleporting",
	[60321] = "Scroll of Recall",
	[75136] = "Ethereal Portal",
	[94719] = "The Innkeeper's Daughter",
	[136508] = "Dark Portal",
	[139432] = "Teleport: Brawl'gar Arena",
	[171253] = "Garrison Hearthstone",
	[222695] = "Dalaran Hearthstone",
	[231504] = "Tome of Town Portal",
	[278244] = "Greatfather Winter's Hearthstone",
	[278559] = "Headless Horseman's Hearthstone",
	[285362] = "Lunar Elder's Hearthstone",
	[285424] = "Peddlefeet's Lovely Hearthstone",
	[286031] = "Noble Gardener's Hearthstone",
	[286331] = "Fire Eater's Hearthstone",
	[286353] = "Brewfest Reveler's Hearthstone",
	[298068] = "Holographic Digitalization Hearthstone",
	[308742] = "Eternal Traveler's Hearthstone",
	[326064] = "Night Fae Hearthstone",
	[340200] = "Necrolord Hearthstone",
	[342122] = "Venthyr Sinstone",
	[345393] = "Kyrian Hearthstone",
	[346060] = "Necrolord Hearthstone",
	[363799] = "Dominated Hearthstone",
	[366945] = "Enlightened Hearthstone",
	[367013] = "Broker Translocation Matrix",
	[375357] = "Timewalker's Hearthstone",
	[391042] = "Ohn'ir Windsage's Hearthstone",
	[401802] = "Stone of the Hearth",
	[412555] = "Path of the Naaru",
	[420418] = "Deepdweller's Earthen Hearthstone",
	[422284] = "Hearthstone of the Flame",
	[431644] = "Stone of the Hearth",
	[438606] = "Draenic Hologem",
	[463481] = "Notorious Thread's Hearthstone",
	[1220729] = "Explosive Hearthstone",
	[1240219] = "P.O.S.T. Master's Express Hearthstone",
	[1242509] = "Cosmic Hearthstone",
}

-- teleport spells
NS.CommFlare.TeleportSpells = {
	[556] = "Astral Recall",
	[3561] = "Teleport: Stormwind",
	[3562] = "Teleport: Ironforge",
	[3563] = "Teleport: Undercity",
	[3565] = "Teleport: Darnassus",
	[3566] = "Teleport: Thunder Bluff",
	[3567] = "Teleport: Orgrimmar",
	[23442] = "Dimensional Ripper - Everlook",
	[23453] = "Ultrasafe Transporter: Gadgetzan",
	[26373] = "Lunar Invitation",
	[28148] = "Portal: Karazhan",
	[32271] = "Teleport: Exodar",
	[32272] = "Teleport: Silvermoon",
	[33690] = "Teleport: Shattrath",
	[35715] = "Teleport: Shattrath",
	[36890] = "Area 52 Transporter",
	[36941] = "Toshley's Station Transporter",
	[41234] = "Teleport: Black Temple",
	[49358] = "Teleport: Stonard",
	[49359] = "Teleport: Theramore",
	[49844] = "Using Direbrew's Remote",
	[53140] = "Teleport: Dalaran - Northrend",
	[54406] = "Teleport: Dalaran",
	[66238] = "Teleport: Argent Tournament",
	[67833] = "Wormhole Generator: Northrend",
	[71436] = "Teleport: Booty Bay",
	[73324] = "Portal: Dalaran",
	[80256] = "Teleport: Deepholm",
	[82674] = "Teleport With Error",
	[88342] = "Teleport: Tol Borad",
	[88344] = "Teleport: Tol Borad",
	[89157] = "Teleport: Stormwind",
	[89158] = "Teleport: Orgrimmar",
	[89597] = "Teleport: Tol Borad",
	[89598] = "Teleport: Tol Borad",
	[120146] = "Ancient Portal: Dalaran",
	[126755] = "Wormhole: Pandaria",
	[126956] = "Lorewalker's Lodestone",
	[132621] = "Teleport: Vale of Eternal Blossoms",
	[132627] = "Teleport: Vale of Eternal Blossoms",
	[139437] = "Teleport: Bizmo's Brewpub",
	[145430] = "Call of the Mists",
	[163830] = "Wormhole Centrifuge",
	[175604] = "Ascend to Bladespire",
	[175608] = "Ascend to Karabor",
	[176242] = "Teleport: Warspear",
	[176248] = "Teleport: Stormshield",
	[189838] = "Teleport to Shipyard",
	[193669] = "Beginner's Guide to Dimensional Rifting",
	[193759] = "Teleport: Hall of the Guardian",
	[216138] = "Emblem of Margoss",
	[220746] = "Scroll of Teleport: Ravenholdt",
	[220989] = "Teleport: Dalaran",
	[223805] = "Advanced Dimensional Rifting",
	[224869] = "Teleport: Dalaran - Broken Isles",
	[231054] = "Teleport: Karazhan",
	[250796] = "Wormhole Generator: Argus",
	[281403] = "Teleport: Boralus",
	[281404] = "Teleport: Dazar'alor",
	[289283] = "Teleport: Dazar'alor",
	[289284] = "Teleport: Boralus",
	[299083] = "Wormhome Generator: Kul Tiras",
	[299084] = "Wormhome Generator: Zandalar",
	[300047] = "Mountebank's Colorful Cloak",
	[324031] = "Wormhole Generator: Shadowlands",
	[335671] = "Scroll of Teleport: Theater of Pain",
	[344587] = "Teleport: Oribos",
	[386379] = "Wormhole Generator: Dragon Isles",
	[395277] = "Teleport: Valdrakken",
	[406714] = "Scroll of Teleport: Zskera Vaults",
	[446540] = "Teleport: Dornogal",
	[448126] = "Wormhole Generator: Khaz Algar",
	[1221356] = "Teleport: Orgrimmar",
	[1221357] = "Teleport: Orgrimmar",
	[1221359] = "Teleport: Stormwind",
	[1221360] = "Teleport: Stormwind",
}

-- hero talent specs
NS.CommFlare.HeroTalentSpecs = {
	-- Death Knight
	[31] = "San'layn",
	[32] = "Rider of the Apocalypse",
	[33] = "Deathbringer",

	-- Demon Hunter
	[34] = "Fel-Scarred",
	[35] = "Aldrachi Reaver",

	-- Druid
	[21] = "Druid of the Claw",
	[22] = "Wildstalker",
	[23] = "Keeper of the Grove",
	[24] = "Elune's Chosen",

	-- Evoker
	[36] = "Scalecommander",
	[37] = "Flameshaper",
	[38] = "Chronowarden",

	-- Hunter
	[42] = "Sentinel",
	[43] = "Pack Leader",
	[44] = "Dark Ranger",
 		
	-- Mage
	[39] = "Sunfury",
	[40] = "Spellslinger",
	[41] = "Frostfire",

	-- Monk
	[64] = "Conduit of the Celestials",
	[65] = "Shado-pan",
	[66] = "Master of Harmony",

	-- Paladin
	[48] = "Templar",
	[49] = "Lightsmith",
	[50] = "Herald of the Sun",

	-- Priest
	[18] = "Voidweaver",
	[19] = "Archon",
	[20] = "Oracle", 		

	-- Rogue
	[51] = "Trickster",
	[52] = "Fatebound",
	[53] = "Deathstalker",

	-- Shaman
	[54] = "Totemic",
	[55] = "Stormbringer",
	[56] = "Farseer",

	-- Warlock
	[57] = "Soul Harvester",
	[58] = "Hellcaller",
	[59] = "Diabolist",

	-- Warrior
	[60] = "Slayer",
	[61] = "Mountain Thane",
	[62] = "Colossus",
}

-- report times left
NS.CommFlare.ReportTimesLeft = {
	[0] = true,
	[5] = true,
	[10] = true,
	[15] = true,
	[20] = true,
	[25] = true,
	[30] = true,
	[45] = true,
	[60] = true,
}

-- build spells
function NS:Build_Spells()
	-- process hearth stone spells
	for k,v in pairs(NS.CommFlare.HearthStoneSpells) do
		-- get name
		local name = GetSpellName(k)
		if (name) then
			-- update name
			NS.CommFlare.HearthStoneSpells[k] = name
		end
	end

	-- process teleport spells
	for k,v in pairs(NS.CommFlare.TeleportSpells) do
		-- get name
		local name = GetSpellName(k)
		if (name) then
			-- update name
			NS.CommFlare.TeleportSpells[k] = name
		end
	end
end
