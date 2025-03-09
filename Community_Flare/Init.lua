-- initialize
local LibStub = LibStub
local ADDON_NAME, NS = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
if (not L or not NS.CommFlare) then return end
 
-- localize stuff
local _G                                          = _G
local BNGetFriendAccountInfo                      = _G.C_BattleNet.GetFriendAccountInfo
local BNGetFriendIndex                            = _G.BNGetFriendIndex
local BNGetNumFriends                             = _G.BNGetNumFriends
local BNSendWhisper                               = _G.BNSendWhisper
local Chat_GetCommunitiesChannelName              = _G.Chat_GetCommunitiesChannelName
local ChatEdit_FocusActiveWindow                  = _G.ChatEdit_FocusActiveWindow
local ChatFrame_AddNewCommunitiesChannel          = _G.ChatFrame_AddNewCommunitiesChannel
local ChatFrame_ContainsChannel                   = _G.ChatFrame_ContainsChannel
local ChatFrame_RemoveCommunitiesChannel          = _G.ChatFrame_RemoveCommunitiesChannel
local FCF_IsChatWindowIndexReserved               = _G.FCF_IsChatWindowIndexReserved
local FCF_IterateActiveChatWindows                = _G.FCF_IterateActiveChatWindows
local GetChannelName                              = _G.GetChannelName
local GetLFGRoleUpdate                            = _G.GetLFGRoleUpdate
local GetNumGroupMembers                          = _G.GetNumGroupMembers
local GetNumSubgroupMembers                       = _G.GetNumSubgroupMembers
local GetTime                                     = _G.GetTime
local IsInGroup                                   = _G.IsInGroup
local IsInGuild                                   = _G.IsInGuild
local IsInRaid                                    = _G.IsInRaid
local PromoteToLeader                             = _G.PromoteToLeader
local RaidWarningFrame_OnEvent                    = _G.RaidWarningFrame_OnEvent
local SendChatMessage                             = _G.SendChatMessage
local SetPVPRoles                                 = _G.SetPVPRoles
local StaticPopupDialogs                          = _G.StaticPopupDialogs
local StaticPopup_Show                            = _G.StaticPopup_Show
local StaticPopup_StandardEditBoxOnEscapePressed  = _G.StaticPopup_StandardEditBoxOnEscapePressed
local UninviteUnit                                = _G.UninviteUnit
local UnitExists                                  = _G.UnitExists
local UnitFullName                                = _G.UnitFullName
local UnitGUID                                    = _G.UnitGUID
local UnitIsConnected                             = _G.UnitIsConnected
local UnitIsDeadOrGhost                           = _G.UnitIsDeadOrGhost
local UnitInParty                                 = _G.UnitInParty
local UnitIsGroupLeader                           = _G.UnitIsGroupLeader
local UnitName                                    = _G.UnitName
local UnitRealmRelationship                       = _G.UnitRealmRelationship
local AuraUtilForEachAura                         = _G.AuraUtil.ForEachAura
local AddOnProfilerGetAddOnMetric                 = _G.C_AddOnProfiler.GetAddOnMetric
local BattleNetGetAccountInfoByGUID               = _G.C_BattleNet.GetAccountInfoByGUID
local BattleNetGetFriendAccountInfo               = _G.C_BattleNet.GetFriendAccountInfo
local BattleNetGetFriendGameAccountInfo           = _G.C_BattleNet.GetFriendGameAccountInfo
local BattleNetGetFriendNumGameAccounts           = _G.C_BattleNet.GetFriendNumGameAccounts
local ClubGetClubMembers                          = _G.C_Club.GetClubMembers
local ClubGetMemberInfo                           = _G.C_Club.GetMemberInfo
local ClubGetStreamInfo                           = _G.C_Club.GetStreamInfo
local ClubGetSubscribedClubs                      = _G.C_Club.GetSubscribedClubs
local DelvesUIHasActiveDelve                      = _G.C_DelvesUI.HasActiveDelve
local MapCanSetUserWaypointOnMap                  = _G.C_Map.CanSetUserWaypointOnMap
local MapGetBestMapForUnit                        = _G.C_Map.GetBestMapForUnit
local MapGetMapInfo                               = _G.C_Map.GetMapInfo
local MapGetUserWaypointHyperlink                 = _G.C_Map.GetUserWaypointHyperlink
local MapSetUserWaypoint                          = _G.C_Map.SetUserWaypoint
local PartyInfoGetRestrictPings                   = _G.C_PartyInfo.GetRestrictPings
local PartyInfoIsDelveComplete                    = _G.C_PartyInfo.IsDelveComplete
local PartyInfoIsDelveInProgress                  = _G.C_PartyInfo.IsDelveInProgress
local PartyInfoSetRestrictPings                   = _G.C_PartyInfo.SetRestrictPings
local PvPIsBattleground                           = _G.C_PvP.IsBattleground
local PvPIsRatedBattleground                      = _G.C_PvP.IsRatedBattleground
local PvPIsRatedSoloRBG                           = _G.C_PvP.IsRatedSoloRBG
local PvPIsWarModeFeatureEnabled                  = _G.C_PvP.IsWarModeFeatureEnabled
local SocialQueueGetGroupForPlayer                = _G.C_SocialQueue.GetGroupForPlayer
local SuperTrackSetSuperTrackedUserWaypoint       = _G.C_SuperTrack.SetSuperTrackedUserWaypoint
local TimerAfter                                  = _G.C_Timer.After
local ipairs                                      = _G.ipairs
local pairs                                       = _G.pairs
local print                                       = _G.print
local securecallfunction                          = _G.securecallfunction
local time                                        = _G.time
local tonumber                                    = _G.tonumber
local tostring                                    = _G.tostring
local type                                        = _G.type
local mfloor                                      = _G.math.floor
local strformat                                   = _G.string.format
local strgmatch                                   = _G.string.gmatch
local strgsub                                     = _G.string.gsub
local strmatch                                    = _G.string.match
local strsplit                                    = _G.string.split
local strsub                                      = _G.string.sub
local tinsert                                     = _G.table.insert

-- hearth stone spells
NS.CommFlare.HearthStoneSpells = {
	[8690] = "Hearthstone",
	[39937] = "There's No Place Like Home",
	[75136] = "Ethereal Portal",
	[94719] = "The Innkeeper's Daughter",
	[136508] = "Dark Portal",
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
	[342122] = "Venthyr Sinstone",
	[345393] = "Kyrian Hearthstone",
	[346060] = "Necrolord Hearthstone",
	[363799] = "Dominated Hearthstone",
	[366945] = "Enlightened Hearthstone",
	[367013] = "Broker Translocation Matrix",
	[375357] = "Timewalker's Hearthstone",
	[391042] = "Ohn'ir Windsage's Hearthstone",
	[412555] = "Path of the Naaru",
	[420418] = "Deepdweller's Earthen Hearthstone",
	[422284] = "Hearthstone of the Flame",
	[431644] = "Stone of the Hearth",
	[438606] = "Draenic Hologem",
	[463481] = "Notorious Thread's Hearthstone",
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
	[32271] = "Teleport: Exodar",
	[32272] = "Teleport: Silvermoon",
	[33690] = "Teleport: Shattrath",
	[35715] = "Teleport: Shattrath",
	[36890] = "Dimensional Ripper - Area 52",
	[36941] = "Ultrasafe Transporter: Toshley's Station",
	[41234] = "Teleport: Black Temple",
	[49358] = "Teleport: Stonard",
	[49359] = "Teleport: Theramore",
	[53140] = "Teleport: Dalaran - Northrend",
	[54406] = "Teleport: Dalaran",
	[66238] = "Teleport: Argent Tournament",
	[71436] = "Teleport: Booty Bay",
	[88342] = "Teleport: Tol Borad",
	[88344] = "Teleport: Tol Borad",
	[89157] = "Teleport: Stormwind",
	[89158] = "Teleport: Orgrimmar",
	[89597] = "Teleport: Tol Borad",
	[89598] = "Teleport: Tol Borad",
	[126755] = "Wormhole Generator: Pandaria",
	[132621] = "Teleport: Vale of Eternal Blossoms",
	[132627] = "Teleport: Vale of Eternal Blossoms",
	[145430] = "Call of the Mists",
	[175604] = "Bladespire Relic",
	[175608] = "Relic of Karabor",
	[176242] = "Teleport: Warspear",
	[176248] = "Teleport: Stormshield",
	[189838] = "Admiral's Compass",
	[193669] = "Beginner's Guide to Dimensional Rifting",
	[193759] = "Teleport: Hall of the Guardian",
	[216138] = "Emblem of Margoss",
	[220746] = "Scroll of Teleport: Ravenholdt",
	[220989] = "Teleport: Dalaran",
	[223805] = "Adept's Guide to Dimensional Rifting",
	[224869] = "Teleport: Dalaran - Broken Isles",
	[231054] = "Violet Seal of the Grand Magus",
	[250796] = "Wormhole Generator: Argus",
	[281403] = "Teleport: Boralus",
	[281404] = "Teleport: Dazar'alor",
	[289283] = "Teleport: Dazar'alor",
	[289284] = "Teleport: Boralus",
	[299083] = "Wormhome Generator: Kul Tiras",
	[299084] = "Wormhome Generator: Zandalar",
	[300047] = "Mountebank's Colorful Cloak",
	[335671] = "Scroll of Teleport: Theater of Pain",
	[344587] = "Teleport: Oribos",
	[395277] = "Teleport: Valdrakken",
	[406714] = "Scroll of Teleport: Zskera Vaults",
	[446540] = "Teleport: Dornogal",
}

-- global function (send variables to other addons)
function CommunityFlare_GetVar(name)
	-- not loaded?
	if (not NS.CommFlare or not NS.db) then
		-- failed
		return nil
	end

	-- version?
	if (name == "Version") then
		-- return community flare version
		return strformat("%s: %s (%s)", NS.CommFlare.Title, NS.CommFlare.Version, NS.CommFlare.Build)
	end

	-- nothing
	return nil
end

-- compare versions
function NS:Compare_Version(version2)
	-- get version parts
	local major2, minor2, build2 = strsplit(".", version2)
	local major1, minor1, build1 = strsplit(".", NS.CommFlare.Version)

	-- remove all letters
	major1 = strgsub(major1, "[a-zA-z]", "")
	minor1 = strgsub(minor1, "[a-zA-z]", "")
	build1 = strgsub(build1, "[a-zA-z]", "")
	major2 = strgsub(major2, "[a-zA-z]", "")
	minor2 = strgsub(minor2, "[a-zA-z]", "")
	build2 = strgsub(build2, "[a-zA-z]", "")

	-- major version updated?
	local updated = nil
	if (major1 ~= major2) then
		-- newer version?
		if (tonumber(major2) > tonumber(major1)) then
			-- newer
			updated = true
		else
			-- older
			updated = false
		end
	end

	-- needs further checking?
	if (updated == nil) then
		-- minor version updated?
		if (minor1 ~= minor2) then
			--- newer version?
			if (tonumber(minor2) > tonumber(minor1)) then
				-- newer
				updated = true
			else
				-- older
				updated = false
			end
		end
	end

	-- needs further checking?
	if (updated == nil) then
		-- build version updated?
		if (build1 ~= build2) then
			-- newer version?
			if (tonumber(build2) > tonumber(build1)) then
				-- newer
				updated = true
			else
				-- older
				updated = false
			end
		end
	end

	-- not updated?
	if (not updated and (updated ~= true)) then
		-- older
		return false
	else
		-- newer
		return true
	end
end

-- format number (K/M/B with 2 decimals)
function NS:Format_Number(...)
	local number, decimals = ...
	if (not decimals) then
		-- force two
		decimals = 2
	elseif (decimals > 9) then
		-- force two
		decimals = 2
	end

	-- trillions?
	local fmt = strformat("%%.%df", decimals)
	if (number > 999999999999) then
		-- divide by 1 trillion
		return strformat(fmt, number / 1000000000000) .. "T"
	-- billions?
	elseif (number > 999999999) then
		-- divide by 1 billion
		return strformat(fmt, number / 1000000000) .. "B"
	-- millions?
	elseif (number > 999999) then
		-- divide by 1 million
		return strformat(fmt, number / 1000000) .. "M"
	-- thousands?
	elseif (number > 999) then
		-- divide by 1 thousand
		return strformat(fmt, number / 1000) .. "K"
	else
		-- full number
		return strformat("%d", number)
	end
end

-- sanity check
function NS:Sanity_Checks()
	-- local data?
	if (not NS.CommFlare.CF.LocalData) then
		-- initialize
		NS.CommFlare.CF.LocalData = {
			["NumTanks"] = 0,
			["NumHealers"] = 0,
			["NumDPS"] = 0,
		}
	end

	-- num tanks?
	if (not NS.CommFlare.CF.LocalData.NumTanks) then
		-- initialize
		NS.CommFlare.CF.LocalData.NumTanks = 0
	end

	-- num healers?
	if (not NS.CommFlare.CF.LocalData.NumHealers) then
		-- initialize
		NS.CommFlare.CF.LocalData.NumHealers = 0
	end

	-- num dps?
	if (not NS.CommFlare.CF.LocalData.NumDPS) then
		-- initialize
		NS.CommFlare.CF.LocalData.NumDPS = 0
	end
end

-- convert table to string
function NS:TableToString(method, table)
	-- all loaded?
	if (method and NS.Libs.AceSerializer) then
		-- LibDeflate
		if (method == "LibDeflate") then
			-- has lib deflate?
			if (NS.Libs.LibDeflate) then
				-- serialize and compress
				local one = NS.Libs.AceSerializer:Serialize(table)
				local two = NS.Libs.LibDeflate:CompressDeflate(one, {level = 9})
				local final = NS.Libs.LibDeflate:EncodeForPrint(two)

				-- return final
				return final
			end
		-- LibCompressHuffman?
		elseif (method == "LibCompressHuffman") then
			-- serialize and compress
			local one = NS.Libs.AceSerializer:Serialize(table)
			local two = NS.Libs.LibCompress:CompressHuffman(one)
			local final = NS.Libs.LibCompress.Encoder:Encode(two)

			-- return final
			return final
		end
	end

	-- failed
	return nil
end

-- convert string to table
function NS:StringToTable(method, string)
	-- all loaded?
	if (method and NS.Libs.AceSerializer) then
		-- LibDeflate
		if (method == "LibDeflate") then
			-- has lib deflate?
			if (NS.Libs.LibDeflate) then
				-- decode, decompress, deserialize
				local one = NS.Libs.LibDeflate:DecodeForPrint(string)
				local two = NS.Libs.LibDeflate:DecompressDeflate(one)
				local status, final = NS.Libs.AceSerializer:Deserialize(two)

				-- success?
				if (status == true) then
					-- return final
					return final
				end
			end
		-- LibCompressHuffman?
		elseif (method == "LibCompressHuffman") then
			-- decode, decompress, deserialize
			local one = NS.Libs.LibCompress.Encoder:Decode(string)
			local two = NS.Libs.LibCompress:Decompress(one)
			local status, final = NS.Libs.AceSerializer:Deserialize(two)

			-- success?
			if (status == true) then
				-- return final
				return final
			end
		end
	end

	-- failed
	return nil
end

-- parse command
function NS:ParseCommand(text)
	local table = {}
	local params = strgmatch(text, "([^@]+)");
	for param in params do
		tinsert(table, param)
	end
	return table
end

-- is in battleground?
function NS:IsInBattleground()
	-- in battleground?
	if (PvPIsBattleground() == true) then
		-- yup
		return true
	-- rated battleground?
	elseif (PvPIsRatedBattleground() == true) then
		-- yup
		return true
	-- solo rated battleground?
	elseif (PvPIsRatedSoloRBG() == true) then
		-- yup
		return true
	end

	-- nope
	return false
end

-- is in delve?
function NS:IsInDelve()
	-- in active delve?
	if (NS.CommFlare.CF.InActiveDelve == true) then
		-- yup
		return true
	end

	-- delve in progress?
	local active = PartyInfoIsDelveInProgress()
	if (active == true) then
		-- yup
		return true
	end

	-- delve completed?
	local complete = PartyInfoIsDelveComplete()
	if (complete == true) then
		-- yup
		return true
	end

	-- has active delve?
	local active = DelvesUIHasActiveDelve()
	if (active == true) then
		-- yup
		return true
	end

	-- nope
	return false
end

-- is player appearing offline?
function NS:IsInvisible()
	-- check Battle.NET account - has focus?
	local accountInfo = BattleNetGetAccountInfoByGUID(UnitGUID("player"))
	if (accountInfo and accountInfo.gameAccountInfo and accountInfo.gameAccountInfo.hasFocus) then
		-- has focus?
		if (accountInfo.gameAccountInfo.hasFocus == true) then
			-- visible
			NS.CommFlare.CF.Invisible = false
			return false
		else
			-- invisible
			NS.CommFlare.CF.Invisible = true
			return true
		end
	end

	-- process all clubs
	local player = NS:GetPlayerName("short")
	local clubs = ClubGetSubscribedClubs()
	for _,v in ipairs(clubs) do
		-- community?
		if (v.clubType == Enum.ClubType.Character) then
			-- process members
			local clubId = v.clubId
			local members = ClubGetClubMembers(clubId)
			for _,v2 in ipairs(members) do
				local mi = ClubGetMemberInfo(clubId, v2)
				if ((mi ~= nil) and (mi.name ~= nil)) then
					-- found player?
					if (mi.name == player) then
						-- offline?
						if (mi.presence == Enum.ClubMemberPresence.Offline) then
							-- invisible
							NS.CommFlare.CF.Invisible = true
							return true
						else
							-- visible
							NS.CommFlare.CF.Invisible = false
							return false
						end
					end
				end
			end
		end 
	end

	-- no communities? (assume invisible)
	return true
end

-- promote player to party leader
function NS:PromoteToPartyLeader(player)
	-- is player full name in party?
	if (UnitInParty(player) == true) then
		PromoteToLeader(player)
		return true
	end

	-- try using short name
	local name, realm = strsplit("-", player)
	if (realm == NS.CommFlare.CF.PlayerServerName) then
		player = name
	end

	-- unit is in party?
	if (UnitInParty(player) == true) then
		PromoteToLeader(player)
		return true
	end
	return false
end

-- load session variables
function NS:LoadSession()
	-- load global stuff
	NS.CommFlare.CF.KosList = NS.db.global.KosList or {}
	NS.CommFlare.CF.SocialQueues = NS.db.global.SocialQueues or {}

	-- load profile stuff
	NS.CommFlare.CF.PartyGUID = NS.charDB.profile.PartyGUID
	NS.CommFlare.CF.MatchStatus = NS.charDB.profile.MatchStatus
	NS.CommFlare.CF.LocalQueues = NS.charDB.profile.LocalQueues or {}
	NS.CommFlare.CF.InActiveDelve = NS.charDB.profile.InActiveDelve or false

	-- load match log stuff
	NS.CommFlare.CF.LogListCount = NS.charDB.profile.LogListCount
	NS.CommFlare.CF.MatchEndTime = NS.charDB.profile.MatchEndTime
	NS.CommFlare.CF.MatchStartDate = NS.charDB.profile.MatchStartDate
	NS.CommFlare.CF.MatchStartTime = NS.charDB.profile.MatchStartTime
	NS.CommFlare.CF.MatchStartLogged = NS.charDB.profile.MatchStartLogged

	-- load battleground specific data
	NS.CommFlare.CF.AB = NS.charDB.profile.AB or {}
	NS.CommFlare.CF.ASH = NS.charDB.profile.ASH or {}
	NS.CommFlare.CF.AV = NS.charDB.profile.AV or {}
	NS.CommFlare.CF.BFG = NS.charDB.profile.BFG or {}
	NS.CommFlare.CF.DHR = NS.charDB.profile.DHR or {}
	NS.CommFlare.CF.DWG = NS.charDB.profile.DWG or {}
	NS.CommFlare.CF.EOTS = NS.charDB.profile.EOTS or {}
	NS.CommFlare.CF.IOC = NS.charDB.profile.IOC or {}
	NS.CommFlare.CF.SSH = NS.charDB.profile.SSH or {}
	NS.CommFlare.CF.SSM = NS.charDB.profile.SSM or {}
	NS.CommFlare.CF.SSvTM = NS.charDB.profile.SSvTM or {}
	NS.CommFlare.CF.WG = NS.charDB.profile.WG or {}
	NS.CommFlare.CF.TOK = NS.charDB.profile.TOK or {}
	NS.CommFlare.CF.TWP = NS.charDB.profile.TWP or {}
	NS.CommFlare.CF.WSG = NS.charDB.profile.WSG or {}

	-- get MapID
	NS.CommFlare.CF.MapID = MapGetBestMapForUnit("player")
	if (NS.CommFlare.CF.MapID) then
		-- get map info
		NS.CommFlare.CF.MapInfo = MapGetMapInfo(NS.CommFlare.CF.MapID)
	end
end

-- save session variables
function NS:SaveSession()
	-- save global stuff
	NS.db.global.KosList = NS.CommFlare.CF.KosList or {}
	NS.db.global.SocialQueues = NS.CommFlare.CF.SocialQueues or {}

	-- save profile stuff
	NS.charDB.profile.SavedTime = time()
	NS.charDB.profile.PartyGUID = NS.CommFlare.CF.PartyGUID
	NS.charDB.profile.MatchStatus = NS.CommFlare.CF.MatchStatus
	NS.charDB.profile.LocalQueues = NS.CommFlare.CF.LocalQueues or {}
	NS.charDB.profile.InActiveDelve = NS.CommFlare.CF.InActiveDelve or false

	-- in battleground?
	if (NS:IsInBattleground() == true) then
		-- save any settings
		NS.charDB.profile.AB = NS.CommFlare.CF.AB or {}
		NS.charDB.profile.ASH = NS.CommFlare.CF.ASH or {}
		NS.charDB.profile.AV = NS.CommFlare.CF.AV or {}
		NS.charDB.profile.BFG = NS.CommFlare.CF.BFG or {}
		NS.charDB.profile.DHR = NS.CommFlare.CF.DHR or {}
		NS.charDB.profile.DWG = NS.CommFlare.CF.DWG or {}
		NS.charDB.profile.EOTS = NS.CommFlare.CF.EOTS or {}
		NS.charDB.profile.IOC = NS.CommFlare.CF.IOC or {}
		NS.charDB.profile.SSH = NS.CommFlare.CF.SSH or {}
		NS.charDB.profile.SSM = NS.CommFlare.CF.SSM or {}
		NS.charDB.profile.SSvTM = NS.CommFlare.CF.SSvTM or {}
		NS.charDB.profile.TOK = NS.CommFlare.CF.TOK or {}
		NS.charDB.profile.TWP = NS.CommFlare.CF.TWP or {}
		NS.charDB.profile.WG = NS.CommFlare.CF.WG or {}
		NS.charDB.profile.WSG = NS.CommFlare.CF.WSG or {}

		-- save match log stuff
		NS.charDB.profile.LogListCount = NS.CommFlare.CF.LogListCount
		NS.charDB.profile.MatchEndTime = NS.CommFlare.CF.MatchEndTime
		NS.charDB.profile.MatchStartDate = NS.CommFlare.CF.MatchStartDate
		NS.charDB.profile.MatchStartTime = NS.CommFlare.CF.MatchStartTime
		NS.charDB.profile.MatchStartLogged = NS.CommFlare.CF.MatchStartLogged
	else
		-- reset settings
		NS.charDB.profile.AB = {}
		NS.charDB.profile.ASH = {}
		NS.charDB.profile.AV = {}
		NS.charDB.profile.BFG = {}
		NS.charDB.profile.IOC = {}
		NS.charDB.profile.SSvTM = {}
		NS.charDB.profile.WG = {}
		NS.charDB.profile.WSG = {}

		-- reset match log stuff
		NS.charDB.profile.LogListCount = 0
		NS.charDB.profile.MatchEndTime = 0
		NS.charDB.profile.MatchStartDate = 0
		NS.charDB.profile.MatchStartTime = 0
		NS.charDB.profile.MatchStartLogged = false
	end

	-- debug mode?
	if (NS.db.global.debugMode == true) then
		-- save CF
		NS.charDB.profile.CF = NS.CommFlare.CF
	end
end

-- send to party, whisper, or Battle.NET message
function NS:SendMessage(sender, msg)
	-- party?
	if (not sender) then
		-- are you in local party?
		if (IsInGroup(LE_PARTY_CATEGORY_HOME) and not IsInRaid()) then
			-- send to party
			SendChatMessage(msg, "PARTY")
		end
	-- string?
	elseif (type(sender) == "string") then
		-- guild?
		if (sender == "GUILD") then
			-- are you in a guild?
			if (IsInGuild()) then
				-- send to guild
				SendChatMessage(msg, "GUILD")
			end
		-- instance?
		elseif (sender == "INSTANCE") then
			-- send to instance chat
			SendChatMessage(msg, "INSTANCE_CHAT")
		-- party?
		elseif (sender == "PARTY") then
			-- are you in local party?
			if (IsInGroup(LE_PARTY_CATEGORY_HOME) and not IsInRaid()) then
				-- send to party
				SendChatMessage(msg, "PARTY")
			end
		-- raid?
		elseif (sender == "RAID") then
			-- are you in raid?
			if (IsInRaid() == true) then
				-- send to raid
				SendChatMessage(msg, "RAID")
			end
		-- raid warning?
		elseif (sender == "RAID_WARNING") then
			-- are you in raid?
			if (IsInRaid() == true) then
				-- send to raid warning
				SendChatMessage(msg, "RAID_WARNING")
			end
		else
			-- send to target whisper
			SendChatMessage(msg, "WHISPER", nil, sender)
		end
	-- number?
	elseif (type(sender) == "number") then
		-- send to Battle.NET
		BNSendWhisper(sender, msg)
	end
end

-- add community chat window (also removes first if already added)
function NS:AddCommunityChatWindow(clubId, streamId)
	-- no stream info?
	local streamInfo = ClubGetStreamInfo(clubId, streamId)
	if (not streamInfo) then
		-- finished
		return
	end

	-- get channel chat name
	local channelName = Chat_GetCommunitiesChannelName(clubId, streamId)
	if (channelName and (channelName ~= "")) then
		-- process active chat windows
		FCF_IterateActiveChatWindows(function(chatWindow, chatWindowIndex)
			-- only reserved channel allowed for communities is general
			if (FCF_IsChatWindowIndexReserved(chatWindowIndex) and (chatWindowIndex ~= 1)) then
				-- finished
				return
			end

			-- not guild stream and general window?
			local isGuildStream = streamInfo.streamType == Enum.ClubStreamType.Guild or streamInfo.streamType == Enum.ClubStreamType.Officer
			if ((isGuildStream ~= true) and (chatWindowIndex == 1)) then
				-- checked?
				local isChecked = ChatFrame_ContainsChannel(chatWindow, channelName)
				if (isChecked == true) then
					-- remove communities channel from chat frame
					ChatFrame_RemoveCommunitiesChannel(chatWindow, clubId, streamId)
				end

				-- has main community?
				local setEditBoxToChannel = false
				if (NS.charDB.profile.communityMain > 1) then
					-- matches club id?
					if (NS.charDB.profile.communityMain == clubId) then
						-- update edit box
						setEditBoxToChannel = true
					end
				end

				-- add communities chat to chat frame
				ChatFrame_AddNewCommunitiesChannel(chatWindowIndex, clubId, streamId, setEditBoxToChannel)
			end
		end)
	end
end

-- remove community chat window
function NS:RemoveCommunityChatWindow(clubId, streamId)
	-- no stream info?
	local streamInfo = ClubGetStreamInfo(clubId, streamId)
	if (not streamInfo) then
		-- finished
		return
	end

	-- get channel chat name
	local channelName = Chat_GetCommunitiesChannelName(clubId, streamId)
	if (channelName and (channelName ~= "")) then
		-- process active chat windows
		FCF_IterateActiveChatWindows(function(chatWindow, chatWindowIndex)
			-- only reserved channel allowed for communities is general
			if (FCF_IsChatWindowIndexReserved(chatWindowIndex) and (chatWindowIndex ~= 1)) then
				-- finished
				return
			end

			-- not guild stream and general window?
			local isGuildStream = streamInfo.streamType == Enum.ClubStreamType.Guild or streamInfo.streamType == Enum.ClubStreamType.Officer
			if ((isGuildStream ~= true) and (chatWindowIndex == 1)) then
				-- checked?
				local isChecked = ChatFrame_ContainsChannel(chatWindow, channelName)
				if (isChecked == true) then
					-- remove communities channel from chat frame
					ChatFrame_RemoveCommunitiesChannel(chatWindow, clubId, streamId)
				end
			end
		end)
	end
end

-- readd community chat window
function NS:ReaddCommunityChatWindow(clubId, streamId)
	-- not given?
	if (not clubId or not streamId) then
		-- failed
		return false
	end

	-- verify types
	if ((type(clubId) ~= "number") or (type(streamId) ~= "number")) then
		-- failed
		return false
	end

	-- sanity check
	if ((clubId <= 1) or (streamId < 1)) then
		-- failed
		return false
	end

	-- add community chat window
	NS:AddCommunityChatWindow(clubId, streamId)
	return true
end

-- re-add community channels on initial load
function NS:ReaddChannelsInitialLoad()
	-- has main community?
	if (NS.charDB.profile.communityMain > 1) then
		-- readd community chat window
		NS:ReaddCommunityChatWindow(NS.charDB.profile.communityMain, 1)
	end

	-- has other communities?
	if (next(NS.charDB.profile.communityList)) then
		-- process all
		for k,v in pairs(NS.charDB.profile.communityList) do
			-- only process true
			if (v == true) then
				-- readd community chat window
				NS:ReaddCommunityChatWindow(k, 1)
			end
		end
	end
end

-- is specialization healer?
function NS:IsHealer(spec)
	if (spec == L["Discipline"]) then
		return true
	elseif (spec == L["Holy"]) then
		return true
	elseif (spec == L["Mistweaver"]) then
		return true
	elseif (spec == L["Preservation"]) then
		return true
	elseif (spec == L["Restoration"]) then
		return true
	end
	return false
end

-- is specialization tank?
function NS:IsTank(spec)
	if (spec == L["Blood"]) then
		return true
	elseif (spec == L["Brewmaster"]) then
		return true
	elseif (spec == L["Guardian"]) then
		return true
	elseif (spec == L["Protection"]) then
		return true
	elseif (spec == L["Vengeance"]) then
		return true
	end
	return false
end

-- enforce pvp roles
function NS:Enforce_PVP_Roles()
	-- force tank role?
	local isTank = false
	if (NS.charDB.profile.forceTank == true) then
		-- enable
		isTank = true
	end

	-- force healer role?
	local isHealer = false
	if (NS.charDB.profile.forceHealer == true) then
		-- enable
		isHealer = true
	end

	-- force dps role?
	local isDPS = false
	if (NS.charDB.profile.forceDPS == true) then
		-- enable
		isDPS = true
	end

	-- any roles forced?
	if ((isTank == true) or (isHealer == true) or (isDPS == true)) then
		-- set pvp roles
		SetPVPRoles(isTank, isHealer, isDPS)
	end
end

-- get full player name
function NS:GetFullName(player)
	-- force name-realm format
	if (not strmatch(player, "-")) then
		-- add realm name
		player = player .. "-" .. NS.CommFlare.CF.PlayerServerName
	end
	return player
end

-- get proper player name by type
function NS:GetPlayerName(type)
	local name, realm = UnitFullName("player")
	if (type == "full") then
		-- no realm name?
		if (not realm or (realm == "")) then
			realm = NS.CommFlare.CF.PlayerServerName
		end
		return strformat("%s-%s", name, realm)
	end
	return name
end

-- get map info
function NS:GetCurrentMapInfo()
	-- get map id
	NS.CommFlare.CF.MapID = MapGetBestMapForUnit("player")
	if (not NS.CommFlare.CF.MapID) then
		-- not found
		return false
	end

	-- get map info
	local mapID = NS.CommFlare.CF.MapID
	NS.CommFlare.CF.MapInfo = MapGetMapInfo(NS.CommFlare.CF.MapID)
	if (not NS.CommFlare.CF.MapInfo) then
		-- not found
		return false
	end

	-- success
	return true
end

-- is currently group leader?
function NS:IsGroupLeader()
	-- has sub group members?
	if (GetNumSubgroupMembers() == 0) then
		return true
	-- is group leader?
	elseif (UnitIsGroupLeader("player")) then
		return true
	end
	return false
end

-- get party guid
function NS:GetPartyGUID()
	-- in group and not in raid?
	if (IsInGroup() and not IsInRaid()) then
		-- process all group members
		for i=1, GetNumGroupMembers() do
			-- unit exists?
			local unit = "party" .. i
			if (not UnitExists(unit)) then
				-- player
				unit = "player"
			end

			-- get group for player
			local playerGUID = UnitGUID(unit)
			if (playerGUID and (playerGUID ~= "")) then
				-- get group for player
				local partyGUID = SocialQueueGetGroupForPlayer(playerGUID)
				if (partyGUID and (partyGUID ~= "")) then
					-- return party guid
					return partyGUID
				end
			end
		end
	end

	-- has party GUID?
	local partyGUID = "none"
	if (NS.CommFlare.CF.PartyGUID and (NS.CommFlare.CF.PartyGUID ~= "")) then
		-- use party GUID
		partyGUID = NS.CommFlare.CF.PartyGUID
	end

	-- return party guid
	return partyGUID
end

-- get party unit
function NS:GetPartyUnit(player)
	-- in group and not in raid?
	if (IsInGroup() and not IsInRaid()) then
		-- force name-realm format
		if (not strmatch(player, "-")) then
			-- add realm name
			player = player .. "-" .. NS.CommFlare.CF.PlayerServerName
		end

		-- process all group members
		for i=1, GetNumGroupMembers() do
			-- unit exists?
			local unit = "party" .. i
			if (not UnitExists(unit)) then
				-- player
				unit = "player"
			end

			-- get unit name / realm (if available)
			local name, realm = UnitName(unit)
			if (name and (name ~= "")) then
				-- no realm name?
				if (not realm or (realm == "")) then
					-- get realm name
					realm = NS.CommFlare.CF.PlayerServerName
				end

				-- matches?
				name = strformat("%s-%s", name, realm)
				if (player == name) then
					-- return unit
					return unit
				end
			end
		end
	end

	-- failed
	return nil
end

-- get current party leader
function NS:GetPartyLeader()
	-- in group and not in raid?
	if (IsInGroup() and not IsInRaid()) then
		-- process all group members
		for i=1, GetNumGroupMembers() do
			-- unit exists?
			local unit = "party" .. i
			if (not UnitExists(unit)) then
				-- player
				unit = "player"
			end

			-- is group leader?
			if (UnitIsGroupLeader(unit)) then 
				-- get unit name / realm (if available)
				local name, realm = UnitName(unit)
				if (name and (name ~= "")) then
					-- no realm name?
					if (not realm or (realm == "")) then
						-- get realm name
						realm = NS.CommFlare.CF.PlayerServerName
					end

					-- leader found
					return strformat("%s-%s", name, realm)
				end
			end
		end
	end

	-- solo atm
	return NS:GetPlayerName("full")
end

-- get party guid
function NS:GetPartyLeaderGUID()
	-- in group and not in raid?
	if (IsInGroup() and not IsInRaid()) then
		-- process all group members
		for i=1, GetNumGroupMembers() do 
			-- unit exists?
			local unit = "party" .. i
			if (not UnitExists(unit)) then
				-- player
				unit = "player"
			end

			-- is group leader?
			if (UnitIsGroupLeader(unit)) then
				-- return guid
				return UnitGUID(unit)
			end
		end
	end

	-- solo atm
	return UnitGUID("player")
end

-- get party members
function NS:GetPartyMembers()
	-- in group and not in raid?
	local members = {}
	if (IsInGroup() and not IsInRaid()) then
		-- process all group members
		for i=1, GetNumGroupMembers() do
			-- unit exists?
			local unit = "party" .. i
			if (not UnitExists(unit)) then
				-- player
				unit = "player"
			end

			-- get unit name / realm (if available)
			local name, realm = UnitName(unit)
			if (name and (name ~= "")) then
				-- no realm name?
				if (not realm or (realm == "")) then
					-- get realm name
					realm = NS.CommFlare.CF.PlayerServerName
				end

				-- add member
				name = strformat("%s-%s", name, realm)
				members[name] = true
			end
		end
	end

	-- return members
	return members
end

-- get max party count
function NS:GetMaxPartyCount()
	-- get max count
	local maxCount = NS.charDB.profile.maxPartySize
	if (not maxCount or (type(maxCount) ~= "number")) then
		-- force 5
		maxCount = 5
	elseif ((maxCount < 1) or (maxCount > 5)) then
		-- reset max party size
		NS.charDB.profile.maxPartySize = 5
		maxCount = NS.charDB.profile.maxPartySize
	end

	-- return maxCount
	return maxCount
end

-- get party count
function NS:GetPartyCount()
	-- in group and not in raid?
	NS.CommFlare.CF.Count = 1
	if (IsInGroup() and not IsInRaid()) then
		-- get num group members
		NS.CommFlare.CF.Count = GetNumGroupMembers()
	end

	-- no members? (solo)
	if (NS.CommFlare.CF.Count == 0) then
		-- solo
		NS.CommFlare.CF.Count = 1
	end

	-- return count
	return NS.CommFlare.CF.Count
end

-- get max group count
function NS:GetMaxGroupCount()
	local maxCount = 5
	if (IsInRaid()) then
		-- set to 40
		maxCount = 40
	elseif (IsInGroup()) then
		-- get max count
		maxCount = NS.charDB.profile.maxPartySize
		if (not maxCount or (type(maxCount) ~= "number")) then
			-- force 5
			maxCount = 5
		elseif ((maxCount < 1) or (maxCount > 5)) then
			-- reset max party size
			NS.charDB.profile.maxPartySize = 5
			maxCount = NS.charDB.profile.maxPartySize
		end
	end

	-- return max count
	return maxCount
end

-- get group count text
function NS:GetGroupCountText()
	-- in group and not in raid?
	NS.CommFlare.CF.Count = 1
	if (IsInGroup()) then
		-- get num group members
		NS.CommFlare.CF.Count = GetNumGroupMembers()
	end

	-- no members? (solo)
	if (NS.CommFlare.CF.Count == 0) then
		-- solo
		NS.CommFlare.CF.Count = 1
	end

	-- get max count
	local maxCount = NS:GetMaxPartyCount()
	if (IsInGroup() and IsInRaid()) then
		-- use max raid size
		maxCount = 40
	end

	-- return x/y count
	return strformat("%d/%d", NS.CommFlare.CF.Count, maxCount)
end

-- get group members
function NS:GetGroupMembers()
	-- in group and not in raid?
	local players = {}
	if (IsInGroup() and not IsInRaid()) then
		-- process all group members
		for i=1, GetNumGroupMembers() do
			-- unit exists?
			local unit = "party" .. i
			if (not UnitExists(unit)) then
				-- player
				unit = "player"
			end

			-- get unit name / realm (if available)
			local name, realm = UnitName(unit)
			if (name and (name ~= "")) then
				-- no realm name?
				if (not realm or (realm == "")) then
					-- get realm name
					realm = NS.CommFlare.CF.PlayerServerName
				end

				-- add party member
				local player = strformat("%s-%s", name, realm)
				players[i] = {
					["guid"] = UnitGUID(unit),
					["name"] = name,
					["realm"] = realm,
					["player"] = player,
				}
			end
		end
	else
		-- add yourself
		players[1] = {
			["guid"] = UnitGUID("player"),
			["player"] = NS:GetPlayerName("full"),
		}
	end

	-- return players
	return players
end

-- get member count
function NS:GetMemberCount()
	-- process all
	local count = 0
	for k,v in pairs(NS.db.global.members) do
		-- increase
		count = count + 1
	end

	-- success
	return count
end

-- get Battle.NET character
function NS:GetBNetFriendName(bnSenderID)
	-- not number?
	if (type(bnSenderID) ~= "number") then
		-- failed
		return nil
	end

	-- get Battle.NET friend index
	local index = BNGetFriendIndex(bnSenderID)
	if (index ~= nil) then
		-- process all Battle.NET accounts logged in
		local numGameAccounts = BattleNetGetFriendNumGameAccounts(index)
		for i=1, numGameAccounts do
			-- retail client?
			local gameAccountInfo = BattleNetGetFriendGameAccountInfo(index, i)
			if (gameAccountInfo and (gameAccountInfo.clientProgram == BNET_CLIENT_WOW) and (gameAccountInfo.wowProjectID == 1)) then
				-- has character and realm names?
				if (gameAccountInfo.characterName and gameAccountInfo.realmName) then
					-- build full player-realm
					return strformat("%s-%s", gameAccountInfo.characterName, gameAccountInfo.realmName)
				end
			end
		end
	end

	-- failed
	return nil
end

-- get Battle.NET presenceID by name-server
function NS:GetBNetPresenceIDByName(player)
	-- split name / realm
	local name, realm = strsplit("-", player)
	if (not realm or (realm == "")) then
		-- same realm name
		realm = NS.CommFlare.CF.PlayerServerNam
	end

	-- process all friends
	for i=1, BNGetNumFriends() do
		-- player online?
		local accountInfo = BattleNetGetFriendAccountInfo(i)
		if (accountInfo and accountInfo.gameAccountInfo) then
			-- retail client?
			local gameAccountInfo = accountInfo.gameAccountInfo
			if (gameAccountInfo and (gameAccountInfo.clientProgram == BNET_CLIENT_WOW) and (gameAccountInfo.wowProjectID == 1)) then
				-- has character and realm names?
				if (gameAccountInfo.characterName and gameAccountInfo.realmName) then
					-- matches name and realm?
					if ((gameAccountInfo.characterName == name) and (gameAccountInfo.realmName == realm)) then
						-- found
						return i
					end
				end
			end
		end
	end

	-- failed
	return nil
end

-- check if a unit has type aura active
function NS:CheckForAura(unit, type, auraName)
	-- save global variable if aura is active
	NS.CommFlare.CF.HasAura = false
	AuraUtilForEachAura(unit, type, nil, function(...)
		-- this aura?
		local name, icon, count, debuffType, duration, expirationTime = ...
		if (name == auraName) then
			-- not created?
			if (not NS.CommFlare.CF.AuraData) then
				-- initialize
				NS.CommFlare.CF.AuraData = {}
			end

			-- found aura / save data
			NS.CommFlare.CF.HasAura = true
			NS.CommFlare.CF.AuraData.name = name
			NS.CommFlare.CF.AuraData.duration = duration
			NS.CommFlare.CF.AuraData.expirationTime = expirationTime
			NS.CommFlare.CF.AuraData.timeLeft = expirationTime - GetTime()
			return true
		end
	end)
end

-- popup box
function NS:PopupBox(dlg, message)
	-- requires community id?
	local showPopup = true
	if (dlg == "CommunityFlare_Send_Community_Dialog") then
		-- setup report channels
		showPopup = false
		local count = NS:Setup_Report_Channels()
		if (count > 0) then
			-- show
			showPopup = true
		end
	end

	-- show popup?
	if (showPopup == true) then
		-- popup box setup
		local popup = StaticPopupDialogs[dlg]

		-- show the popup box
		NS.CommFlare.CF.PopupMessage = message
		local dialog = StaticPopup_Show(dlg, message)
		if (dialog) then
			dialog.data = NS.CommFlare.CF.PopupMessage
		end

		-- restore popup
		StaticPopupDialogs[dlg] = popup
	end
end

-- process version check
function NS:Process_Version_Check(sender)
	-- no shared community?
	if (NS:Has_Shared_Community(sender) == false) then
		-- finished
		return
	end

	-- send community flare version number
	NS:SendMessage(sender, strformat("%s: %s (%s)", NS.CommFlare.Title, NS.CommFlare.Version, NS.CommFlare.Build))
end

-- kick dialog box
StaticPopupDialogs["CommunityFlare_Kick_Dialog"] = {
	text = L["Kick: %s?"],
	button1 = L["Yes"],
	button2 = L["No"],
	OnAccept = function(self, player)
		-- uninvite user
		print(L["Uninviting ..."])
		UninviteUnit(player, L["AFK"])

		-- community auto invite enabled?
		local text = L["You've been removed from the party for being AFK."]
		if (NS.charDB.profile.communityAutoInvite == true) then
			-- update text for info about being reinvited
			text = strformat("%s %s", text, L["Whisper me INV and if a spot is still available, you'll be readded to the party."])
		end

		-- send message
		NS:SendMessage(player, text)
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
}

-- setup report channels
function NS:Setup_Report_Channels()
	-- not created?
	if (not NS.CommFlare.CF.ReportChannels) then
		-- initialize
		NS.CommFlare.CF.ReportChannels = {}
	end

	-- not created?
	if (not NS.charDB.profile.communityReportList) then
		-- copy community list
		NS.charDB.profile.communityReportList = CopyTable(NS.charDB.profile.communityList)

		-- has main community?
		if (NS.charDB.profile.communityMain > 1) then
			-- enable main community
			NS.charDB.profile.communityReportList[NS.charDB.profile.communityMain] = true
		end
	end

	-- has main community?
	local count = 0
	if (NS.charDB.profile.communityMain > 1) then
		-- process all report list
		for k,v in pairs(NS.charDB.profile.communityReportList) do
			-- verify channel setup
			local streamId = 1
			local channelName = Chat_GetCommunitiesChannelName(k, streamId)
			local id, name = GetChannelName(channelName)
			if ((id > 0) and (name ~= nil)) then
				-- enable report channel
				NS.CommFlare.CF.ReportChannels[k] = id

				-- increase
				count = count + 1
			else
				-- disable report channel
				NS.CommFlare.CF.ReportChannels[k] = nil
			end
		end

		-- no count?
		if (count == 0) then
			-- main community not inserted?
			local clubId = NS.charDB.profile.communityMain
			NS.charDB.profile.communityReportList[clubId] = true
		end
	end

	-- return count
	return count
end

-- send report messages
function NS:Send_Report_Messages(message)
	-- has message?
	if (message) then
		-- count report channels
		local count = 0
		for k,v in pairs(NS.CommFlare.CF.ReportChannels) do
			-- increase
			count = count + 1
		end

		-- has channels to report to?
		if (count > 0) then
			-- process all
			for k,v in pairs(NS.CommFlare.CF.ReportChannels) do
				-- send channel messsage (hardware click acquired)
				SendChatMessage(message, "CHANNEL", nil, v)
			end

			-- treat guild as community?
			if (NS.charDB.profile.addGuildMembers == true) then
				-- are you in a guild?
				if (IsInGuild()) then
					-- send message
					NS:SendMessage("GUILD", message)
				end
			end
		end
	end
end

-- send community dialog box
StaticPopupDialogs["CommunityFlare_Send_Community_Dialog"] = {
	text = L["Send: %s?"],
	button1 = L["Send"],
	button2 = L["No"],
	OnAccept = function(self, message)
		-- setup report channels
		local count = NS:Setup_Report_Channels()
		if (count > 0) then
			-- send report messages
			NS:Send_Report_Messages(message)
		end
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
}

-- set player note dialog box 
StaticPopupDialogs["CommunityFlare_Set_Player_Note_Dialog"] = {
	text = L["Set Player Note for %s:"],
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 31,
	editBoxWidth = 260,
	OnAccept = function(self, data)
		-- member notes created?
		local text = self.editBox:GetText()
		if (NS.db and NS.db.global and NS.db.global.MemberNotes) then
			-- update member note
			NS.db.global.MemberNotes[data.guid] = text
		end
	end,
	OnShow = function(self, data)
		-- has member note?
		if (NS.db and NS.db.global and NS.db.global.MemberNotes and NS.db.global.MemberNotes[data.guid]) then
			-- set current note
			self.editBox:SetText(NS.db.global.MemberNotes[data.guid])
			self.editBox:SetFocus()
		end
	end,
	OnHide = function(self)
		-- hide dialog
		ChatEdit_FocusActiveWindow();
		self.editBox:SetText("");
	end,
	EditBoxOnEnterPressed = function(self, data)
		-- member notes created?
		local text = self:GetText()
		if (NS.db and NS.db.global and NS.db.global.MemberNotes) then
			-- update member note
			NS.db.global.MemberNotes[data.guid] = text
		end

		-- hide dialog
		local parent = self:GetParent();
		parent:Hide();
	end,
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
}

-- copy player name dialog box 
StaticPopupDialogs["CommunityFlare_Copy_Player_Name_Dialog"] = {
	text = L["Copy Player Name for %s [Use Ctrl+c]:"],
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 31,
	editBoxWidth = 260,
	OnShow = function(self, data)
		-- has player?
		if (data.player and (data.player ~= "")) then
			-- set current player
			self.editBox:SetText(data.player)
			self.editBox:HighlightText()
			self.editBox:SetFocus()
		end
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
}

-- rebuild database members
function NS:Rebuild_Database_Members()
	-- clear lists
	NS.db.global.members = {}
	NS.CommFlare.CF.CommunityLeaders = {}

	-- process club members again
	print(L["Rebuilding community database member list."])
	local status = NS:Process_Club_Members()
	if (status == true) then
		-- display members found
		print(NS:Total_Database_Members(nil))

		-- display leaders count
		local count = 0
		for _,v in ipairs(NS.CommFlare.CF.CommunityLeaders) do
			-- next
			count = count + 1
		end
		print(strformat(L["%d community leaders found."], count))
	else
		-- no subscribed clubs found
		print(strformat(L["%s: No subscribed clubs found."], NS.CommFlare.Title))
	end
end


-- rebuild members dialog box
StaticPopupDialogs["CommunityFlare_Rebuild_Members_Dialog"] = {
	text = L["Are you sure you want to wipe the members database and totally rebuild from scratch?"],
	button1 = L["Yes"],
	button2 = L["No"],
	OnAccept = function(self, player)
		-- rebuild database
		NS:Rebuild_Database_Members()
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
}

-- process party states
function NS:Process_Party_States(isDead, isOffline)
	-- process all
	for i=1, GetNumGroupMembers() do
		local kickPlayer = false
		local unit = "party" .. i
		local player, realm = UnitName(unit)
		if (player and (player ~= "")) then
			-- realm name was given?
			if (realm and (realm ~= "")) then
				player = player .. "-" .. realm
			end

			-- are they dead/ghost?
			if ((isDead == true) and (UnitIsDeadOrGhost(unit) == true)) then
				-- kick them
				kickPlayer = true
			end

			-- are they offline?
			if ((isOffline == true) and (UnitIsConnected(unit) ~= true)) then
				-- kick them
				kickPlayer = true
			end

			-- should kick?
			if (kickPlayer == true) then
				-- are you leader?
				if (NS:IsGroupLeader() == true) then
					-- ask to kick?
					NS:PopupBox("CommunityFlare_Kick_Dialog", player)
				end
			end
		end
	end
end

-- queue check role chosen
function NS:Queue_Check_Role_Chosen()
	local inProgress, slots, members, category, lfgID, bgQueue = GetLFGRoleUpdate()

	-- not in progress?
	if (inProgress ~= true) then
		-- finished
		return
	end

	-- not in a group?
	if (not IsInGroup()) then
		-- finished
		return
	end

	-- in a raid?
	if (IsInRaid()) then
		-- finished
		return
	end

	-- process all
	for i=1, GetNumGroupMembers() do
		local unit = "party" .. i
		local player, realm = UnitName(unit)
		if (player and (player ~= "")) then
			-- check relationship
			local realmRelationship = UnitRealmRelationship(unit)
			if (realmRelationship == LE_REALM_RELATION_SAME) then
				-- player with same realm
				player = player .. "-" .. NS.CommFlare.CF.PlayerServerName
			else
				-- player with different realm
				player = player .. "-" .. realm
			end

			-- role not chosen?
			if (not NS.CommFlare.CF.RoleChosen[player] or (NS.CommFlare.CF.RoleChosen[player] ~= true)) then
				-- are you leader?
				if (NS:IsGroupLeader() == true) then
					-- ask to kick?
					NS:PopupBox("CommunityFlare_Kick_Dialog", player)
				end
			end
		end
	end
end

-- remove tom tom way points
function NS:TomTomRemoveWaypoints(title)
	-- sanity check
	if (not title) then
		-- finished
		return
	end

	-- has tom tom?
	local TT = TomTom
	if (TT and TT.RemoveWaypoint and TT.waypoints) then
		-- process all waypoints
		for mapID, entries in pairs(TT.waypoints) do
			-- process zone waypoints
			for _, waypoint in pairs(entries) do
				-- title matches?
				if (waypoint.title and (waypoint.title == title)) then
					-- remove waypoint
					securecallfunction(TT.RemoveWaypoint, TT, waypoint)
				end
			end
		end
	end
end

-- add tom tom way point
function NS:TomTomAddWaypoint(title, x, y)
	-- sanity checks
	if (not title or not x or not y) then
		-- finished
		return nil
	end

	-- has tom tom?
	local TT = TomTom
	if (TT and TT.AddWaypoint) then
		-- setup options
		local options =
		{
			desc = tostring(title),
			title = tostring(title),
			persistent = true,
			minimap = true,
			world = true,
			callbacks = nil,
			silent = true,
			from = "CommFlare",
		}

		-- add way point
		return securecallfunction(TT.AddWaypoint, TT, NS.CommFlare.CF.MapID, tonumber(x), tonumber(y), options)
	end

	-- not enabled
	return nil
end

-- verify ping status
function NS:VerifyPingStatus()
	-- restrict pings?
	if (NS.db.global.restrictPings and (NS.db.global.restrictPings >= 0)) then
		-- check current ping status
		local status = PartyInfoGetRestrictPings()
		if (status ~= NS.db.global.restrictPings) then
			-- do you have lead?
			local player = NS:GetPlayerName("full")
			NS.CommFlare.CF.PlayerRank = NS:GetRaidRank(UnitName("player"))
			if (NS.CommFlare.CF.PlayerRank ~= 0) then
				-- none?
				if (NS.db.global.restrictPings == 0) then
					-- none
					PartyInfoSetRestrictPings(Enum.RestrictPingsTo.None)
				elseif (NS.db.global.restrictPings == 1) then
					-- leader
					PartyInfoSetRestrictPings(Enum.RestrictPingsTo.Lead)
				elseif (NS.db.global.restrictPings == 2) then
					-- assist
					PartyInfoSetRestrictPings(Enum.RestrictPingsTo.Assist)
				elseif (NS.db.global.restrictPings == 3) then
					-- tank/healer
					PartyInfoSetRestrictPings(Enum.RestrictPingsTo.TankHealer)
				end
			end
		end
	end
end

-- vignette check for alerts
function NS:VignetteCheckForAlerts(list)
	-- flying in?
	local timer = 300
	local message = nil
	local createPin = false
	local vignetteID = nil
	if (list[2967]) then
		-- war supply create is dropping in nows
		createPin = true
		vignetteID = 2967
		message = L["War Supply Crate is dropping in now!"]
	-- war supply crate flying in?
	elseif (list[3689]) then
		-- war supply crate is flying in now
		vignetteID = 3689
		message = L["War Supply Crate is flying in now!"]
	-- war chest has fully dropped?
	elseif (list[6066]) then
		-- war supply crate has fully dropped to the ground
		timer = 600
		createPin = true
		vignetteID = 6066
		message = L["War Supply Crate has fully dropped to the ground!"]
	-- war chest looted for the horde
	elseif (list[6067]) then
		-- war supply looted has been looted for the alliance
		createPin = true
		vignetteID = 6067
		message = L["War Supply Crate has been looted for the Alliance!"]
	-- war chest looted for the horde
	elseif (list[6068]) then
		-- war supply looted has been looted for the horde
		createPin = true
		vignetteID = 6068
		message = L["War Supply Crate has been looted for the Horde!"]
	end

	-- found vignette?
	if (vignetteID and message) then
		-- has coordinates?
		local info = list[vignetteID]
		if (info and info.vignetteGUID) then
			-- needs to issue raid warning?
			local guid = info.vignetteGUID
			if (not NS.CommFlare.CF.VignetteWarnings[guid]) then
				-- has coordinates?
				if (info.x and info.y) then
					-- issue raid warning
					NS.CommFlare.CF.VignetteWarnings[guid] = time()
					TimerAfter(timer, function()
						-- clear last raid warning
						NS.CommFlare.CF.VignetteWarnings[guid] = nil

						-- remove all war supply crate waypoints
						NS:TomTomRemoveWaypoints("War Supply Crate")
					end)

					-- add tom tom way point
					local uid = NS:TomTomAddWaypoint(info.name, info.x, info.y)

					-- create pin?
					local hyperLink = nil
					if (createPin == true) then
						-- get MapID
						local mapID = MapGetBestMapForUnit("player")
						if (mapID) then
							-- can set user waypoint?
							if (MapCanSetUserWaypointOnMap(mapID)) then
								-- create position from x/y
								local point = UiMapPoint.CreateFromCoordinates(mapID, info.x, info.y)
								MapSetUserWaypoint(point)
								hyperLink = MapGetUserWaypointHyperlink()

								-- not already tracked?
								if (not uid) then
									-- set super tracked
									SuperTrackSetSuperTrackedUserWaypoint(true)
								end
							end
						end
					end

					-- issue local raid warning (with raid warning audio sound)
					RaidWarningFrame_OnEvent(RaidBossEmoteFrame, "CHAT_MSG_RAID_WARNING", message)

					-- has hyper link?
					if (hyperLink) then
						-- add to message
						message = strformat("%s %s", message, hyperLink)
					end

					-- in raid?
					if (IsInRaid()) then
						-- display raid message
						NS:SendMessage("RAID", message)
					-- in party?
					elseif (IsInGroup()) then
						-- display party message
						NS:SendMessage("PARTY", message)
					end
				else
					-- try again
					TimerAfter(2, function()
						-- call recursively
						NS:VignetteCheckForAlerts(list)
					end)
				end
			end
		end
	end
end

-- run performance tests
function NS:Run_Performance_Tests()
	-- process all tests
	for k,v in pairs(Enum.AddOnProfilerMetric) do
		-- get addon metric
		local metric = AddOnProfilerGetAddOnMetric(ADDON_NAME, v)
		print(strformat("%s: %s = %s", NS.CommFlare.Title, tostring(k), tostring(metric)))
	end
end

-- build battle ground commander sync data
function NS:Build_Battleground_Commander_Sync_Data()
	-- build sync data
	local syncData = {
		addonVersion = NS.CommFlare.Version,
		remainingMercenary = -1,
		remainingDeserter = -1,
		autoAcceptRole = true,
		wantLead = true,
	}

	-- return string
	return NS:TableToString("LibCompressHuffman", syncData)
end
