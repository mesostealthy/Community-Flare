local LibStub = LibStub
local ADDON_NAME, NS = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
 
-- localize stuff
local _G                                        = _G
local BNGetFriendAccountInfo                    = _G.C_BattleNet.GetFriendAccountInfo
local BNGetFriendIndex                          = _G.BNGetFriendIndex
local BNGetNumFriends                           = _G.BNGetNumFriends
local BNSendGameData                            = _G.BNSendGameData
local BNSendWhisper                             = _G.BNSendWhisper
local Chat_GetCommunitiesChannel                = _G.Chat_GetCommunitiesChannel
local Chat_GetCommunitiesChannelName            = _G.Chat_GetCommunitiesChannelName
local ChatFrame_AddChannel                      = _G.ChatFrame_AddChannel
local ChatFrame_AddNewCommunitiesChannel        = _G.ChatFrame_AddNewCommunitiesChannel
local ChatFrame_RemoveChannel                   = _G.ChatFrame_RemoveChannel
local ChatFrame_RemoveCommunitiesChannel        = _G.ChatFrame_RemoveCommunitiesChannel
local GetChannelName                            = _G.GetChannelName
local GetLFGRoleUpdate                          = _G.GetLFGRoleUpdate
local GetNumGroupMembers                        = _G.GetNumGroupMembers
local GetNumSubgroupMembers                     = _G.GetNumSubgroupMembers
local GetTime                                   = _G.GetTime
local IsInGroup                                 = _G.IsInGroup
local IsInRaid                                  = _G.IsInRaid
local PromoteToLeader                           = _G.PromoteToLeader
local SendChatMessage                           = _G.SendChatMessage
local SetPVPRoles                               = _G.SetPVPRoles
local StaticPopupDialogs                        = _G.StaticPopupDialogs
local StaticPopup_Show                          = _G.StaticPopup_Show
local UninviteUnit                              = _G.UninviteUnit
local UnitExists                                = _G.UnitExists
local UnitFullName                              = _G.UnitFullName
local UnitGUID                                  = _G.UnitGUID
local UnitIsConnected                           = _G.UnitIsConnected
local UnitIsDeadOrGhost                         = _G.UnitIsDeadOrGhost
local UnitInParty                               = _G.UnitInParty
local UnitIsGroupLeader                         = _G.UnitIsGroupLeader
local UnitName                                  = _G.UnitName
local UnitRealmRelationship                     = _G.UnitRealmRelationship
local AuraUtilForEachAura                       = _G.AuraUtil.ForEachAura
local BattleNetGetAccountInfoByGUID             = _G.C_BattleNet.GetAccountInfoByGUID
local BattleNetGetFriendAccountInfo             = _G.C_BattleNet.GetFriendAccountInfo
local BattleNetGetFriendGameAccountInfo         = _G.C_BattleNet.GetFriendGameAccountInfo
local BattleNetGetFriendNumGameAccounts         = _G.C_BattleNet.GetFriendNumGameAccounts
local ClubGetClubMembers                        = _G.C_Club.GetClubMembers
local ClubGetMemberInfo                         = _G.C_Club.GetMemberInfo
local ClubGetSubscribedClubs                    = _G.C_Club.GetSubscribedClubs
local MapGetBestMapForUnit                      = _G.C_Map.GetBestMapForUnit
local MapGetMapInfo                             = _G.C_Map.GetMapInfo
local PvPIsBattleground                         = _G.C_PvP.IsBattleground
local SocialQueueGetGroupForPlayer              = _G.C_SocialQueue.GetGroupForPlayer
local TimerAfter                                = _G.C_Timer.After
local pairs                                     = _G.pairs
local time                                      = _G.time
local type                                      = _G.type
local mfloor                                    = _G.math.floor
local strformat                                 = _G.string.format
local strgmatch                                 = _G.string.gmatch
local strmatch                                  = _G.string.match
local strsub                                    = _G.string.sub
local tinsert                                   = _G.table.insert

-- hearth stone spells
NS.HearthStoneSpells = {
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
	[420418] = "Deepdweller's Earthen Hearthstone",
	[422284] = "Hearthstone of the Flame",
	[431644] = "Stone of the Hearth",
}

-- teleport spells
NS.TeleportSpells = {
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
}

-- global function (check if dragon riding available)
function IsDragonFlyable()
	local m = MapGetBestMapForUnit("player")
	if ((m >= 2022) and (m <= 2025) or (m == 2085) or (m == 2112)) then
		-- dragon flyable
		return true
	else
		-- not available
		return false
	end
end

-- global function (send variables to other addons)
function CommunityFlare_GetVar(name)
	-- not loaded?
	if (not NS.CommFlare or not NS.globalDB) then
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
function NS:TableToString(table)
	-- all loaded?
	if (NS.Libs.AceSerializer and NS.Libs.LibDeflate) then
		-- serialize and compress
		local one = NS.Libs.AceSerializer:Serialize(table)
		local two = NS.Libs.LibDeflate:CompressDeflate(one, {level = 9})
		local final = NS.Libs.LibDeflate:EncodeForPrint(two)

		-- return final
		return final
	end

	-- failed
	return nil
end

-- convert string to table
function NS:StringToTable(string)
	-- all loaded?
	if (NS.Libs.AceSerializer and NS.Libs.LibDeflate) then
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

-- is player appearing offline?
function NS:IsInvisible()
	-- check Battle.NET account - has focus?
	local accountInfo = BattleNetGetAccountInfoByGUID(UnitGUID("player"))
	if (accountInfo and accountInfo.gameAccountInfo and accountInfo.gameAccountInfo.hasFocus) then
		-- has focus?
		if (accountInfo.gameAccountInfo.hasFocus == true) then
			-- visible
			NS.CommFlare.CF.Invisble = false
			return false
		else
			-- invisible
			NS.CommFlare.CF.Invisble = true
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
							NS.CommFlare.CF.Invisble = true
							return true
						else
							-- visible
							NS.CommFlare.CF.Invisble = false
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
	NS.CommFlare.CF.SocialQueues = NS.globalDB.global.SocialQueues or {}

	-- load profile stuff
	NS.CommFlare.CF.PartyGUID = NS.charDB.profile.PartyGUID
	NS.CommFlare.CF.MatchStatus = NS.charDB.profile.MatchStatus
	NS.CommFlare.CF.LocalQueues = NS.charDB.profile.LocalQueues or {}

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
	NS.CommFlare.CF.IOC = NS.charDB.profile.IOC or {}
	NS.CommFlare.CF.SSvTM = NS.charDB.profile.SSvTM or {}
	NS.CommFlare.CF.WG = NS.charDB.profile.WG or {}
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
	NS.globalDB.global.SocialQueues = NS.CommFlare.CF.SocialQueues or {}

	-- save profile stuff
	NS.charDB.profile.SavedTime = time()
	NS.charDB.profile.PartyGUID = NS.CommFlare.CF.PartyGUID
	NS.charDB.profile.MatchStatus = NS.CommFlare.CF.MatchStatus
	NS.charDB.profile.LocalQueues = NS.CommFlare.CF.LocalQueues or {}

	-- currently in battleground?
	if (PvPIsBattleground() == true) then
		-- save any settings
		NS.charDB.profile.AB = NS.CommFlare.CF.AB or {}
		NS.charDB.profile.ASH = NS.CommFlare.CF.ASH or {}
		NS.charDB.profile.AV = NS.CommFlare.CF.AV or {}
		NS.charDB.profile.BFG = NS.CommFlare.CF.BFG or {}
		NS.charDB.profile.IOC = NS.CommFlare.CF.IOC or {}
		NS.charDB.profile.SSvTM = NS.CommFlare.CF.SSvTM or {}
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
	if (NS.charDB.profile.debugMode == true) then
		-- save CF
		NS.charDB.profile.CF = NS.CommFlare.CF
	end
end

-- send to party, whisper, or Battle.NET message
function NS:SendMessage(sender, msg)
	-- party?
	if (not sender) then
		-- send to party chat
		SendChatMessage(msg, "PARTY")
	-- string?
	elseif (type(sender) == "string") then
		-- raid warning?
		if (sender == "RAID_WARNING") then
			-- send to raid warning
			SendChatMessage(msg, "RAID_WARNING")
		else
			-- send to target whisper
			SendChatMessage(msg, "WHISPER", nil, sender)
		end
	elseif (type(sender) == "number") then
		-- send to Battle.NET whisper
		BNSendWhisper(sender, msg)
	end
end

-- readd community chat window
function NS:ReaddCommunityChatWindow(clubId, streamId)
	-- remove channel
	local channel, chatFrameID = Chat_GetCommunitiesChannel(clubId, streamId)
	if (not channel and not chatFrameID) then
		-- failed
		return
	elseif (not channel) then
		-- add channel
		ChatFrame_AddNewCommunitiesChannel(1, clubId, streamId, nil)
	elseif (not chatFrameID or (chatFrameID == 0)) then
		-- remove channel (twice)
		ChatFrame_RemoveCommunitiesChannel(ChatFrame1, clubId, streamId, false)
		ChatFrame_RemoveCommunitiesChannel(ChatFrame1, clubId, streamId, false)

		-- add channel
		ChatFrame_AddNewCommunitiesChannel(1, clubId, streamId, nil)
	else
		-- remove channel
		local channelName = Chat_GetCommunitiesChannelName(clubId, streamId)
		ChatFrame_RemoveChannel(ChatFrame1, channelName)

		-- add channel
		ChatFrame_AddChannel(ChatFrame1, channelName)
	end
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
		local timer = 0.2
		for k,v in pairs(NS.charDB.profile.communityList) do
			-- only process true
			if (v == true) then
				-- stagger readding
				TimerAfter(timer, function ()
					-- readd community chat window
					NS:ReaddCommunityChatWindow(k, 1)
				end)

				-- next
				timer = timer + 0.2
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

-- get total group count
function NS:GetGroupCount()
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

	-- return x/y count
	local maxCount = NS:GetMaxPartyCount()
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
	for k,v in pairs(NS.globalDB.global.members) do
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

-- send Battle.NET data
function NS:BNSendData(player, data)
	-- no player given?
	if (not player) then
		-- finished
		return
	end

	-- string?
	local presenceID = nil
	if (type(player) == "string") then
		-- realm not found?
		if (not strmatch(player, "-")) then
			-- add realm name
			player = player .. "-" .. NS.CommFlare.CF.PlayerServerName
		end

		-- get presenceID
		presenceID = NS:GetBNetPresenceIDByName(player)
	-- number?
	elseif (type(player) == "number") then
		-- this is presenceID
		presenceID = player
	end

	-- found presenceID?
	if (presenceID and (presenceID > 0)) then
		-- send data
		BNSendGameData(presenceID, "CommFlare", data)
	end
end

-- push Battle.NET data
function NS:BNPushData(data)
	-- is player invisible?
	local isInvisible = NS:IsInvisible()
	if (isInvisible and (isInvisible == true)) then
		-- finished
		return
	end

	-- process all friends
	local members = NS:GetPartyMembers()
	for i=1, BNGetNumFriends() do
		-- player online?
		local accountInfo = BattleNetGetFriendAccountInfo(i)
		if (accountInfo and accountInfo.gameAccountInfo) then
			-- retail client?
			local gameAccountInfo = accountInfo.gameAccountInfo
			if (gameAccountInfo and (gameAccountInfo.clientProgram == BNET_CLIENT_WOW) and (gameAccountInfo.wowProjectID == 1)) then
				-- has character and realm names?
				if (gameAccountInfo.characterName and gameAccountInfo.realmName) then
					-- not in party?
					local player = strformat("%s-%s", gameAccountInfo.characterName, gameAccountInfo.realmName)
					if (not members[player]) then
						-- send data
						local presenceID = gameAccountInfo.gameAccountID
						NS:BNSendData(presenceID, data)
					end
				end
			end
		end
	end
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
		-- report ID set?
		local clubId = 0
		showPopup = false
		if (NS.charDB.profile.communityReportID and (NS.charDB.profile.communityReportID > 1)) then
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

-- send community dialog box
StaticPopupDialogs["CommunityFlare_Send_Community_Dialog"] = {
	text = L["Send: %s?"],
	button1 = L["Send"],
	button2 = L["No"],
	OnAccept = function(self, message)
		-- report ID set?
		if (NS.charDB.profile.communityReportID and (NS.charDB.profile.communityReportID > 1)) then
			-- club id found?
			local clubId = NS.charDB.profile.communityReportID
			if (clubId > 0) then
				local streamId = 1
				local channelName = Chat_GetCommunitiesChannelName(clubId, streamId)
				local id, name = GetChannelName(channelName)
				if ((id > 0) and (name ~= nil)) then
					-- send channel messsage (hardware click acquired)
					SendChatMessage(message, "CHANNEL", nil, id)
				end
			end
		end
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
}

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
