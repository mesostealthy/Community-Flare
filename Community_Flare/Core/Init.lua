-- initialize
local LibStub = LibStub
local ADDON_NAME, NS = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
if (not L or not NS.CommFlare) then return end
 
-- localize stuff
local _G                                          = _G
local AddNewCommunitiesChannel                    = _G.ChatFrameUtil.AddNewCommunitiesChannel
local BNGetFriendAccountInfo                      = _G.C_BattleNet.GetFriendAccountInfo
local BNGetFriendIndex                            = _G.BNGetFriendIndex
local BNGetNumFriends                             = _G.BNGetNumFriends
local BNSendWhisper                               = _G.C_BattleNet and _G.C_BattleNet.SendWhisper or _G.BNSendWhisper
local ContainsChannel                             = _G.ChatFrameMixin.ContainsChannel
local CopyTable                                   = _G.CopyTable
local FCF_IsChatWindowIndexReserved               = _G.FCF_IsChatWindowIndexReserved
local FCF_IterateActiveChatWindows                = _G.FCF_IterateActiveChatWindows
local GetBindingAction                            = _G.GetBindingAction
local GetBindingKey                               = _G.GetBindingKey
local GetChannelName                              = _G.GetChannelName
local GetCommunitiesChannelName                   = _G.ChatFrameUtil and _G.ChatFrameUtil.GetCommunitiesChannelName or _G.Chat_GetCommunitiesChannelName
local GetCurrentBindingSet                        = _G.GetCurrentBindingSet
local GetLFGRoles                                 = _G.GetLFGRoles
local GetLFGRoleUpdate                            = _G.GetLFGRoleUpdate
local GetNumGroupMembers                          = _G.GetNumGroupMembers
local GetNumSubgroupMembers                       = _G.GetNumSubgroupMembers
local GetTime                                     = _G.GetTime
local InCombatLockdown                            = _G.InCombatLockdown
local IsInGroup                                   = _G.IsInGroup
local IsInGuild                                   = _G.IsInGuild
local IsInInstance                                = _G.IsInInstance
local IsInRaid                                    = _G.IsInRaid
local PromoteToLeader                             = _G.PromoteToLeader
local RaidWarningFrame_OnEvent                    = _G.RaidWarningFrame_OnEvent
local RemoveCommunitiesChannel                    = _G.ChatFrameUtil.RemoveCommunitiesChannel
local SaveBindings                                = _G.SaveBindings
local SendChatMessage                             = _G.C_ChatInfo and _G.C_ChatInfo.SendChatMessage or _G.SendChatMessage
local SetBinding                                  = _G.SetBinding
local SetLFGRoles                                 = _G.SetLFGRoles
local SetPVPRoles                                 = _G.SetPVPRoles
local StaticPopup_Show                            = _G.StaticPopup_Show
local UnitExists                                  = _G.UnitExists
local UnitFullName                                = _G.UnitFullName
local UnitGUID                                    = _G.UnitGUID
local UnitIsConnected                             = _G.UnitIsConnected
local UnitIsDeadOrGhost                           = _G.UnitIsDeadOrGhost
local UnitIsGroupLeader                           = _G.UnitIsGroupLeader
local UnitInParty                                 = _G.UnitInParty
local UnitName                                    = _G.UnitName
local UnitRealmRelationship                       = _G.UnitRealmRelationship
local AddOnProfilerGetAddOnMetric                 = _G.C_AddOnProfiler.GetAddOnMetric
local BattleNetGetAccountInfoByGUID               = _G.C_BattleNet.GetAccountInfoByGUID
local BattleNetGetFriendAccountInfo               = _G.C_BattleNet.GetFriendAccountInfo
local BattleNetGetFriendGameAccountInfo           = _G.C_BattleNet.GetFriendGameAccountInfo
local BattleNetGetFriendNumGameAccounts           = _G.C_BattleNet.GetFriendNumGameAccounts
local ChatInfoInChatMessagingLockdown             = _G.C_ChatInfo.InChatMessagingLockdown
local ClassTalentsGetActiveConfigID               = _G.C_ClassTalents.GetActiveConfigID
local ClassTalentsGetActiveHeroTalentSpec         = _G.C_ClassTalents.GetActiveHeroTalentSpec
local ClubGetClubMembers                          = _G.C_Club.GetClubMembers
local ClubGetMemberInfo                           = _G.C_Club.GetMemberInfo
local ClubGetStreamInfo                           = _G.C_Club.GetStreamInfo
local ClubGetSubscribedClubs                      = _G.C_Club.GetSubscribedClubs
local CVarGetCVar                                 = _G.C_CVar.GetCVar
local CVarSetCVar                                 = _G.C_CVar.SetCVar
local DelvesUIHasActiveDelve                      = _G.C_DelvesUI.HasActiveDelve
local MapGetBestMapForUnit                        = _G.C_Map.GetBestMapForUnit
local MapGetMapInfo                               = _G.C_Map.GetMapInfo
local PartyInfoGetRestrictPings                   = _G.C_PartyInfo.GetRestrictPings
local PartyInfoIsDelveComplete                    = _G.C_PartyInfo.IsDelveComplete
local PartyInfoIsDelveInProgress                  = _G.C_PartyInfo.IsDelveInProgress
local PartyInfoIsPartyWalkIn                      = _G.C_PartyInfo.IsPartyWalkIn
local PartyInfoSetRestrictPings                   = _G.C_PartyInfo.SetRestrictPings
local PvPIsBattleground                           = _G.C_PvP.IsBattleground
local PvPIsRatedBattleground                      = _G.C_PvP.IsRatedBattleground
local PvPIsRatedSoloRBG                           = _G.C_PvP.IsRatedSoloRBG
local PvPIsWarModeFeatureEnabled                  = _G.C_PvP.IsWarModeFeatureEnabled
local SocialQueueGetGroupForPlayer                = _G.C_SocialQueue.GetGroupForPlayer
local TimerAfter                                  = _G.C_Timer.After
local TraitsGenerateImportString                  = _G.C_Traits.GenerateImportString
local UnitAuras_GetAuraDataBySpellName            = _G.C_UnitAuras.GetAuraDataBySpellName
local ipairs                                      = _G.ipairs
local pairs                                       = _G.pairs
local print                                       = _G.print
local select                                      = _G.select
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

-- global: Get Variables (only Version atm)
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

-- check for table additions
function NS:CheckForTableAdditions(tabletype, name, table1, table2, basename)
	-- check for added fields
	local count = 0
	for k,v in pairs(table1) do
		-- build proper field
		local field = tostring(k)
		if (basename) then
			-- sub field
			field = strformat("%s.%s", basename, field)
		end

		-- not in table2?
		if (table2[k] == nil) then
			-- table?
			if (type(table1[k]) == "table") then
				-- copy table
				table2[k] = CopyTable(table1[k])
			else
				-- copy value
				table2[k] = table1[k]
			end

			-- added
			count = count + 1
		-- table?
		elseif (type(table1[k]) == "table") then
			-- call recursively
			count = count + NS:CheckForTableAdditions(tabletype, name, table1[k], table2[k], field)
		end
	end

	-- return count
	return count
end

-- check for table deletions
function NS:CheckForTableDeletions(tabletype, name, table1, table2, basename)
	-- check for added fields
	local count = 0
	for k,v in pairs(table2) do
		-- build proper field
		local field = tostring(k)
		if (basename) then
			-- sub field
			field = strformat("%s.%s", basename, field)
		end

		-- not in table1?
		if (table1[k] == nil) then
			-- deleted
			table2[k] = nil
			count = count + 1
		-- table?
		elseif (type(table1[k]) == "table") then
			-- call recursively
			count = count + NS:CheckForTableDeletions(tabletype, name, table1[k], table2[k], field)
		end
	end

	-- return count
	return count
end

-- check for table updates
function NS:CheckForTableUpdates(tabletype, name, table1, table2, basename)
	-- invalid tables?
	local count = 0
	if (not table1 or not table2) then
		-- return 1
		return 1
	end

	-- check for table additions
	count = count + NS:CheckForTableAdditions(tabletype, name, table1, table2, basename)

	-- check for updated fields
	for k,v in pairs(table1) do
		-- build proper field
		local field = tostring(k)
		if (basename) then
			-- sub field
			field = strformat("%s.%s", basename, field)
		end

		-- updated?
		if (table1[k] ~= table2[k]) then
			-- table?
			if (type(table1[k]) == "table") then
				-- call recursively
				local count2 = NS:CheckForTableUpdates(tabletype, name, table1[k], table2[k], field)
				if (count2 > 0) then
					-- add to count
					count = count + count2
				else
					-- updated
					count = count + 1
				end
			else
				-- updated
				count = count + 1
			end

			-- update field
			table2[k] = table1[k]
		end
	end

	-- check for table deletions
	count = count + NS:CheckForTableDeletions(tabletype, name, table1, table2, basename)

	-- return count
	return count
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

-- get club member info
function NS:GetClubMemberInfo(clubId, memberId)
	-- in chat messaging lockdown?
	if (ChatInfoInChatMessagingLockdown()) then
		-- finished
		return nil
	end

	-- found member?
	local mi = ClubGetMemberInfo(clubId, memberId)
	if (not mi or not mi.name) then
		-- failed
		return nil
	end

	-- has name only?
	local player = mi.name
	local _, c = player:gsub("-", "")
	if (c == 0) then
		-- update name
		mi.name = strformat("%s-%s", player, NS.CommFlare.CF.PlayerServerName)
	-- has extra data?
	elseif (c > 1) then
		-- has extra?
		local name, realm, extra = strsplit("-", player)
		if (extra) then
			-- update name
			mi.name = strformat("%s-%s", name, realm)
		end
	end

	-- return member info
	return mi
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

	-- is party walk in?
	local walkin = PartyInfoIsPartyWalkIn()
	if (walkin == true) then
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
	-- in chat messaging lockdown?
	if (ChatInfoInChatMessagingLockdown()) then
		-- finished
		return nil
	end

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
	local player = UnitName("player")
	local clubs = ClubGetSubscribedClubs()
	for _,v in ipairs(clubs) do
		-- community?
		if (v.clubType == Enum.ClubType.Character) then
			-- process members
			local clubId = v.clubId
			local members = ClubGetClubMembers(clubId)
			for _,v2 in ipairs(members) do
				local mi = NS:GetClubMemberInfo(clubId, v2)
				if (mi and mi.name) then
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
	NS.CommFlare.CF.SocialQueues = NS.db.global.SocialQueues or {}
	NS.CommFlare.CF.WarCrateLocations = NS.db.global.WarCrateLocations or {}

	-- load profile stuff
	NS.CommFlare.CF.PartyGUID = NS.charDB.profile.PartyGUID or nil
	NS.CommFlare.CF.MatchStatus = NS.charDB.profile.MatchStatus or 0
	NS.CommFlare.CF.ActiveTimers = NS.charDB.profile.ActiveTimers or {}
	NS.CommFlare.CF.LocalQueues = NS.charDB.profile.LocalQueues or {}
	NS.CommFlare.CF.VehicleDeaths = NS.charDB.profile.VehicleDeaths or {}
	NS.CommFlare.CF.InActiveDelve = NS.charDB.profile.InActiveDelve or false

	-- load match log stuff
	NS.CommFlare.CF.LogListCount = NS.charDB.profile.LogListCount or 0
	NS.CommFlare.CF.MatchEndDate = NS.charDB.profile.MatchEndDate or ""
	NS.CommFlare.CF.MatchEndTime = NS.charDB.profile.MatchEndTime or 0
	NS.CommFlare.CF.MatchStartDate = NS.charDB.profile.MatchStartDate or ""
	NS.CommFlare.CF.MatchStartTime = NS.charDB.profile.MatchStartTime or 0
	NS.CommFlare.CF.NumAllyGlaives = NS.charDB.profile.NumAllyGlaives or 0
	NS.CommFlare.CF.NumHordeGlaives = NS.charDB.profile.NumHordeGlaives or 0

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
	NS.CommFlare.CF.TOK = NS.charDB.profile.TOK or {}
	NS.CommFlare.CF.TWP = NS.charDB.profile.TWP or {}
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
	NS.db.global.SocialQueues = NS.CommFlare.CF.SocialQueues or {}
	NS.db.global.WarCrateLocations = NS.CommFlare.CF.WarCrateLocations or {}

	-- save profile stuff
	NS.charDB.profile.SavedTime = time()
	NS.charDB.profile.PartyGUID = NS.CommFlare.CF.PartyGUID
	NS.charDB.profile.MatchStatus = NS.CommFlare.CF.MatchStatus
	NS.charDB.profile.ActiveTimers = NS.CommFlare.CF.ActiveTimers or {}
	NS.charDB.profile.LocalQueues = NS.CommFlare.CF.LocalQueues or {}
	NS.charDB.profile.VehicleDeaths = NS.CommFlare.CF.VehicleDeaths or {}
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
		NS.charDB.profile.MatchEndDate = NS.CommFlare.CF.MatchEndDate or ""
		NS.charDB.profile.MatchEndTime = NS.CommFlare.CF.MatchEndTime or 0
		NS.charDB.profile.MatchStartDate = NS.CommFlare.CF.MatchStartDate or ""
		NS.charDB.profile.MatchStartTime = NS.CommFlare.CF.MatchStartTime or 0
		NS.charDB.profile.NumAllyGlaives = NS.CommFlare.CF.NumAllyGlaives
		NS.charDB.profile.NumHordeGlaives = NS.CommFlare.CF.NumHordeGlaives
	end

	-- debug mode?
	if (NS.db.global.debugMode == true) then
		-- save CF
		NS.charDB.profile.CF = NS.CommFlare.CF
	end
end

-- send addon message
function NS:SendAddonMessage(prefix, text, distribution, target)
	-- in chat messaging lockdown?
	if (ChatInfoInChatMessagingLockdown()) then
		-- finished
		return
	end

	-- send addon message
	NS.CommFlare:SendCommMessage(prefix, text, distribution, target)
end

-- send to party, whisper, or Battle.NET message
function NS:SendMessage(sender, msg, channel)
	-- in chat messaging lockdown?
	if (ChatInfoInChatMessagingLockdown()) then
		-- finished
		return
	end

	-- party?
	if (not sender) then
		-- in local party?
		if (IsInGroup(LE_PARTY_CATEGORY_HOME) and not IsInRaid()) then
			-- send to party
			SendChatMessage(msg, "PARTY")
		end
	-- string?
	elseif (type(sender) == "string") then
		-- channel?
		if (sender == "CHANNEL") then
			-- send to channel (hardware click required)
			SendChatMessage(msg, "CHANNEL", nil, channel)
		-- guild?
		elseif (sender == "GUILD") then
			-- in guild?
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
			-- in local party?
			if (IsInGroup(LE_PARTY_CATEGORY_HOME) and not IsInRaid()) then
				-- send to party
				SendChatMessage(msg, "PARTY")
			end
		-- raid?
		elseif (sender == "RAID") then
			-- in raid?
			if (IsInRaid() == true) then
				-- send to raid
				SendChatMessage(msg, "RAID")
			end
		-- raid warning?
		elseif (sender == "RAID_WARNING") then
			-- in raid?
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
	-- in chat messaging lockdown?
	if (ChatInfoInChatMessagingLockdown()) then
		-- finished
		return
	end

	-- no stream info?
	local streamInfo = ClubGetStreamInfo(clubId, streamId)
	if (not streamInfo) then
		-- finished
		return
	end

	-- get channel chat name
	local channelName = GetCommunitiesChannelName(clubId, streamId)
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
				local isChecked = ContainsChannel(chatWindow, channelName)
				if (isChecked == true) then
					-- remove communities channel from chat frame
					RemoveCommunitiesChannel(chatWindow, clubId, streamId)
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
				AddNewCommunitiesChannel(chatWindowIndex, clubId, streamId, setEditBoxToChannel)
			end
		end)
	end
end

-- remove community chat window
function NS:RemoveCommunityChatWindow(clubId, streamId)
	-- in chat messaging lockdown?
	if (ChatInfoInChatMessagingLockdown()) then
		-- finished
		return
	end

	-- no stream info?
	local streamInfo = ClubGetStreamInfo(clubId, streamId)
	if (not streamInfo) then
		-- finished
		return
	end

	-- get channel chat name
	local channelName = GetCommunitiesChannelName(clubId, streamId)
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
				local isChecked = ContainsChannel(chatWindow, channelName)
				if (isChecked == true) then
					-- remove communities channel from chat frame
					RemoveCommunitiesChannel(chatWindow, clubId, streamId)
				end
			end
		end)
	end
end

-- readd community chat window
function NS:ReaddCommunityChatWindow(clubId, streamId)
	-- in chat messaging lockdown?
	if (ChatInfoInChatMessagingLockdown()) then
		-- finished
		return false
	end

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
		-- force enable roles
		local isLeader = GetLFGRoles()
		SetLFGRoles(isLeader, isTank, isHealer, isDPS)
		SetPVPRoles(isTank, isHealer, isDPS)

		-- lfg invite popup shown?
		if (LFGInvitePopup:IsShown()) then
			-- set checked boxes
			LFGRole_SetChecked(LFGInvitePopupRoleButtonTank, isTank)
			LFGRole_SetChecked(LFGInvitePopupRoleButtonHealer, isHealer)
			LFGRole_SetChecked(LFGInvitePopupRoleButtonDPS, isDPS)
			LFGInvitePopup_UpdateAcceptButton()
		end

		-- quick join role selection shown?
		if (QuickJoinRoleSelectionFrame:IsShown()) then
			-- is tank?
			if (isTank == true) then
				-- not checked?
				if (QuickJoinRoleSelectionFrame.RoleButtonTank.CheckButton:GetChecked() ~= true) then
					-- click button
					QuickJoinRoleSelectionFrame.RoleButtonTank.CheckButton:Click()
				end
			end

			-- is healer?
			if (isHealer == true) then
				-- not checked?
				if (QuickJoinRoleSelectionFrame.RoleButtonHealer.CheckButton:GetChecked() ~= true) then
					-- click button
					QuickJoinRoleSelectionFrame.RoleButtonHealer.CheckButton:Click()
				end
			end

			-- is dps?
			if (isDPS == true) then
				-- not checked?
				if (QuickJoinRoleSelectionFrame.RoleButtonDPS.CheckButton:GetChecked() ~= true) then
					-- click button
					QuickJoinRoleSelectionFrame.RoleButtonDPS.CheckButton:Click()
				end
			end
		end
	end
end

-- get full player name
function NS:GetFullName(player)
	-- force name-realm format
	if (not strmatch(player, "-")) then
		-- add realm name
		player = strformat("%s-%s", player, NS.CommFlare.CF.PlayerServerName)
	end
	return player
end

-- is currently group leader?
function NS:IsGroupLeader()
	-- is group leader?
	if (UnitIsGroupLeader("player")) then
		-- yes
		return true
	-- has no group members?
	elseif (GetNumGroupMembers() == 0) then
		-- yes
		return true
	end

	-- no 
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
			player = strformat("%s-%s", player, NS.CommFlare.CF.PlayerServerName)
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
	return NS.CommFlare.CF.PlayerFullName
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

-- get max party count
function NS:GetMaxPartyCount()
	-- get max count
	local maxCount = NS.charDB.profile.maxPartySize
	if (not maxCount or (type(maxCount) ~= "number")) then
		-- force 5
		maxCount = 5
	-- invalid max count?
	elseif ((maxCount < 1) or (maxCount > 5)) then
		-- reset max party size
		NS.charDB.profile.maxPartySize = 5
		maxCount = NS.charDB.profile.maxPartySize
	end

	-- return maxCount
	return maxCount
end

-- get max group count
function NS:GetMaxGroupCount()
	-- in raid?
	local maxCount = 5
	if (IsInRaid()) then
		-- set to 40
		maxCount = 40
	-- in group?
	elseif (IsInGroup()) then
		-- get max count
		maxCount = NS:GetMaxPartyCount()
	end

	-- return max count
	return maxCount
end

-- get group count text
function NS:GetGroupCountText()
	-- in group?
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
	local info = UnitAuras_GetAuraDataBySpellName(unit, auraName, type)
	if (info and info[1]) then
		-- not created?
		if (not NS.CommFlare.CF.AuraData) then
			-- initialize
			NS.CommFlare.CF.AuraData = {}
		end

		-- found aura / save data
		NS.CommFlare.CF.HasAura = true
		NS.CommFlare.CF.AuraData.name = info[1].name
		NS.CommFlare.CF.AuraData.duration = info[1].duration
		NS.CommFlare.CF.AuraData.expirationTime = info[1].expirationTime
		NS.CommFlare.CF.AuraData.timeLeft = info[1].expirationTime - GetTime()
	end
end

-- popup box
function NS:PopupBox(dlg, ...)
	-- requires community id?
	local args = ...
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
		-- show the popup box
		local dialog = StaticPopup_Show(dlg, args)
		if (dialog) then
			-- save args
			dialog.data = args
		end
	end
end

-- process talents check
function NS:Process_Talents_Check(sender)
	-- no shared community?
	if (NS:Has_Shared_Community(sender) == false) then
		-- finished
		return
	end

	-- get active config id
	local configID = ClassTalentsGetActiveConfigID()
	if (configID) then
		-- get current specialization info
		local specID, specName = PlayerUtil.GetCurrentSpecID()
		if (specID and specName) then
			-- get hero spec id
			local text = strformat("%s", specName)
			local heroSpecID = ClassTalentsGetActiveHeroTalentSpec()
			if (heroSpecID and NS.CommFlare.HeroTalentSpecs[heroSpecID]) then
				-- add hero talent
				text = strformat("%s (%s)", text, NS.CommFlare.HeroTalentSpecs[heroSpecID])
			end

			-- get import string
			local data = TraitsGenerateImportString(configID)
			if (data) then
				-- finalize text
				text = strformat("%s: %s", text, data)
			end

			-- send talents data
			NS:SendMessage(sender, text)
			return
		end
	end

	-- send community flare version number
	NS:SendMessage(sender, strformat("%s: %s (%s)", NS.CommFlare.Title, NS.CommFlare.Version, NS.CommFlare.Build))
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
		NS.CommFlare.CF.ReportChannels = {}
		for k,v in pairs(NS.charDB.profile.communityReportList) do
			-- verify channel setup
			local streamId = 1
			local channelName = GetCommunitiesChannelName(k, streamId)
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
				NS:SendMessage("CHANNEL", message, v)
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
		print(NS:Total_Database_Members())

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
				player = strformat("%s-%s", player, realm)
			end

			-- are they dead/ghost?
			if ((isDead == true) and (UnitIsDeadOrGhost(unit) == true)) then
				-- kick them
				kickPlayer = true
			-- are they offline?
			elseif ((isOffline == true) and (UnitIsConnected(unit) ~= true)) then
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
				player = strformat("%s-%s", player, NS.CommFlare.CF.PlayerServerName)
			else
				-- player with different realm
				player = strformat("%s-%s", player, realm)
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

-- verify ping status
function NS:VerifyPingStatus()
	-- already been restricted?
	local next_restrict = 0
	if (NS.CommFlare.CF.LastRestrictPingTime > 0) then
		-- refresh in 30 seconds
		next_restrict = NS.CommFlare.CF.LastRestrictPingTime + 30
	end

	-- should restrict?
	if (time() > next_restrict) then
		-- restrict pings?
		local status = PartyInfoGetRestrictPings()
		if (NS.db.global.restrictPings and (NS.db.global.restrictPings >= 0)) then
			-- check current ping status
			if (status ~= NS.db.global.restrictPings) then
				-- do you have lead?
				local player = NS.CommFlare.CF.PlayerFullName
				NS.CommFlare.CF.PlayerRank = NS:GetRaidRank(UnitName("player"))
				if (NS.CommFlare.CF.PlayerRank == 2) then
					-- none?
					if (NS.db.global.restrictPings == 0) then
						-- none
						PartyInfoSetRestrictPings(Enum.RestrictPingsTo.None)
					-- leaders?
					elseif (NS.db.global.restrictPings == 1) then
						-- leader
						PartyInfoSetRestrictPings(Enum.RestrictPingsTo.Lead)
					-- assistants?
					elseif (NS.db.global.restrictPings == 2) then
						-- assist
						PartyInfoSetRestrictPings(Enum.RestrictPingsTo.Assist)
					-- tank/healers?
					elseif (NS.db.global.restrictPings == 3) then
						-- tank/healer
						PartyInfoSetRestrictPings(Enum.RestrictPingsTo.TankHealer)
					end
				-- do you have assist?
				elseif (NS.CommFlare.CF.PlayerRank == 1) then
					-- assistants?
					if (NS.db.global.restrictPings == 2) then
						-- assist
						PartyInfoSetRestrictPings(Enum.RestrictPingsTo.Assist)
					end
				end
			end
		end

		-- last restrict pings time
		NS.CommFlare.CF.LastRestrictPingTime = time()
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

-- enforce binding rules
function NS:Enforce_Binding_Rules()
	-- get current binding set
	local which = GetCurrentBindingSet()
	if ((which ~= Enum.BindingSet.Account) and (which ~= Enum.BindingSet.Character)) then
		-- finished
		return
	end

	-- target nearest enemy key not found yet?
	if (not NS.CommFlare.CF.TargetNearestEnemy) then
		-- try getting binding for target nearest enemy player first
		NS.CommFlare.CF.TargetNearestEnemy = GetBindingKey("TARGETNEARESTENEMYPLAYER")
		if (not NS.CommFlare.CF.TargetNearestEnemy) then
			-- next try getting binding for target nearest enemy
			NS.CommFlare.CF.TargetNearestEnemy = GetBindingKey("TARGETNEARESTENEMY")
		end

		-- still not found?
		if (not NS.CommFlare.CF.TargetNearestEnemy) then
			-- default TAB
			NS.CommFlare.CF.TargetNearestEnemy = "TAB"
		end
	end

	-- target previous enemy key not found yet?
	if (not NS.CommFlare.CF.TargetPreviousEnemy) then
		-- try getting binding for target previous enemy player first
		NS.CommFlare.CF.TargetPreviousEnemy = GetBindingKey("TARGETPREVIOUSENEMYPLAYER")
		if (not NS.CommFlare.CF.TargetPreviousEnemy) then
			-- next try getting binding for target previous enemy
			NS.CommFlare.CF.TargetPreviousEnemy = GetBindingKey("TARGETPREVIOUSENEMY")
		end

		-- still not found?
		if (not NS.CommFlare.CF.TargetPreviousEnemy) then
			-- default TAB
			NS.CommFlare.CF.TargetPreviousEnemy = "SHIFT-TAB"
		end
	end

	-- rebind target keys not enabled?
	if (NS.charDB.profile.rebindTargetKeys ~= true) then
		-- finished
		return
	end

	-- not in combat lockdown?
	if (InCombatLockdown() ~= true) then
		-- in battleground?
		local action, changes, status = nil, 0, nil
		if (NS:IsInBattleground() == true) then
			-- has target nearest enemy key?
			if (NS.CommFlare.CF.TargetNearestEnemy) then
				-- binding action for target nearest enemy not target nearest enemy?
				action = GetBindingAction(NS.CommFlare.CF.TargetNearestEnemy)
				if (action ~= "TARGETNEARESTENEMYPLAYER") then
					-- save
					status = SetBinding(NS.CommFlare.CF.TargetNearestEnemy, "TARGETNEARESTENEMYPLAYER")
					if (status == true) then
						-- increase
						changes = changes + 1
					end
				end

				-- binding action for target previous enemy not target previous enemy?
				action = GetBindingAction(NS.CommFlare.CF.TargetPreviousEnemy)
				if (action ~= "TARGETPREVIOUSENEMYPLAYER") then
					-- save
					status = SetBinding(NS.CommFlare.CF.TargetPreviousEnemy, "TARGETPREVIOUSENEMYPLAYER")
					if (status == true) then
						-- increase
						changes = changes + 1
					end
				end

				-- found changes?
				if (changes > 0) then
					-- save bindings
					SaveBindings(which)
					print(strformat(L["%s: Key Bindings updated for PVP mode."], NS.CommFlare.Title))
				end
			end
		else
			-- has target nearest enemy key?
			if (NS.CommFlare.CF.TargetNearestEnemy) then
				-- binding action for target nearest enemy not target nearest enemy?
				action = GetBindingAction(NS.CommFlare.CF.TargetNearestEnemy)
				if (action ~= "TARGETNEARESTENEMY") then
					-- save
					status = SetBinding(NS.CommFlare.CF.TargetNearestEnemy, "TARGETNEARESTENEMY")
					if (status == true) then
						-- increase
						changes = changes + 1
					end
				end

				-- binding action for target previous enemy not target previous enemy?
				action = GetBindingAction(NS.CommFlare.CF.TargetPreviousEnemy)
				if (action ~= "TARGETPREVIOUSENEMY") then
					-- save
					status = SetBinding(NS.CommFlare.CF.TargetPreviousEnemy, "TARGETPREVIOUSENEMY")
					if (status == true) then
						-- increase
						changes = changes + 1
					end
				end

				-- found changes?
				if (changes > 0) then
					-- save bindings
					SaveBindings(which)
					print(strformat(L["%s: Key Bindings updated for non-PVP mode."], NS.CommFlare.Title))
					
				end
			end
		end
	end
end

-- add spell for GetRangeCheck3.0
function NS:AddRangeCheckSpell(classType, spellType, spellID)
	-- not loaded?
	if (not NS.Libs.LibRangeCheck) then
		-- not loaded
		return
	end

	-- not patched?
	if (not NS.Libs.LibRangeCheck.GetSpellTables) then
		-- not patched
		return
	end

	-- get spell tables
	local FriendSpells, HarmSpells, ResSpells, PetSpells = NS.Libs.LibRangeCheck:GetSpellTables()
	if (FriendSpells and HarmSpells and ResSpells and PetSpells) then
		-- friend spell?
		if (spellType == "Friend") then
			-- find class type table
			local list = FriendSpells[classType]
			if (list and (type(list) == "table")) then
				-- search if already added
				for k,v in ipairs(list) do
					-- matches?
					if (spellID == v) then
						-- added already
						return
					end
				end

				-- add spell
				tinsert(FriendSpells[classType], spellID)
			end
		-- harm spell?
		elseif (spellType == "Harm") then
			-- find class type table
			local list = HarmSpells[classType]
			if (list and (type(list) == "table")) then
				-- search if already added
				for k,v in ipairs(list) do
					-- matches?
					if (spellID == v) then
						-- added already
						return
					end
				end

				-- add spell
				tinsert(HarmSpells[classType], spellID)
			end
		-- res spell?
		elseif (spellType == "Res") then
			-- find class type table
			local list = ResSpells[classType]
			if (list and (type(list) == "table")) then
				-- search if already added
				for k,v in ipairs(list) do
					-- matches?
					if (spellID == v) then
						-- added already
						return
					end
				end

				-- add spell
				tinsert(ResSpells[classType], spellID)
			end
		-- pet spell?
		elseif (spellType == "Pet") then
			-- find class type table
			local list = PetSpells[classType]
			if (list and (type(list) == "table")) then
				-- search if already added
				for k,v in ipairs(list) do
					-- matches?
					if (spellID == v) then
						-- added already
						return
					end
				end

				-- add spell
				tinsert(PetSpells[classType], spellID)
			end
		end
	end
end
 
-- remove spell for GetRangeCheck3.0
function NS:RemoteRangeCheckSpell(classType, spellType, spellID)
	-- not loaded?
	if (not NS.Libs.LibRangeCheck) then
		-- not loaded
		return
	end

	-- not patched?
	if (not NS.Libs.LibRangeCheck.GetSpellTables) then
		-- not patched
		return
	end

	-- get spell tables
	local FriendSpells, HarmSpells, ResSpells, PetSpells = NS.Libs.LibRangeCheck:GetSpellTables()
	if (FriendSpells and HarmSpells and ResSpells and PetSpells) then
		-- friend spell?
		if (spellType == "Friend") then
			-- find class type table
			local list = FriendSpells[classType]
			if (list and (type(list) == "table")) then
				-- search if already added
				for k,v in ipairs(list) do
					-- matches?
					if (spellID == v) then
						-- remove spell
						list[k] = nil
						return
					end
				end
			end
		-- harm spell?
		elseif (spellType == "Harm") then
			-- find class type table
			local list = HarmSpells[classType]
			if (list and (type(list) == "table")) then
				-- search if already added
				for k,v in ipairs(list) do
					-- matches?
					if (spellID == v) then
						-- remove spell
						list[k] = nil
						return
					end
				end
			end
		-- res spell?
		elseif (spellType == "Res") then
			-- find class type table
			local list = ResSpells[classType]
			if (list and (type(list) == "table")) then
				-- search if already added
				for k,v in ipairs(list) do
					-- matches?
					if (spellID == v) then
						-- remove spell
						list[k] = nil
						return
					end
				end
			end
		-- pet spell?
		elseif (spellType == "Pet") then
			-- find class type table
			local list = PetSpells[classType]
			if (list and (type(list) == "table")) then
				-- search if already added
				for k,v in ipairs(list) do
					-- matches?
					if (spellID == v) then
						-- remove spell
						list[k] = nil
						return
					end
				end
			end
		end
	end
end

-- cancel active timers
function NS:Cancel_Active_Timers(name)
	-- has active timers?
	if (NS.CommFlare.CF.ActiveTimers and next(NS.CommFlare.CF.ActiveTimers)) then
		-- process all timers
		for k,v in pairs(NS.CommFlare.CF.ActiveTimers) do
			-- no name?
			local shouldCancel = false
			if (not name) then
				-- cancel
				shouldCancel = true
			-- name matches?
			elseif (v.name == name) then
				-- cancel
				shouldCancel = true
			end

			-- should cancel?
			if (shouldCancel == true) then
				-- timer exists?
				if (v.timer) then
					-- cancel timer
					v.timer:Cancel()
				end

				-- clear active timer
				NS.CommFlare.CF.ActiveTimers[k] = nil
			end
		end
	end
end

-- hide stuff in vehicles
function NS:HideStuffInVehicles(type)
	-- all or cdm?
	if ((type == "all") or (type == "cdm")) then
		-- hide CDM while inside vehicles?
		if (NS.db.global.cdmHideInVehiclesPvP == true) then
			-- cooldown manager enabled?
			NS.CommFlare.CF.CDMEnabled = CVarGetCVar("cooldownViewerEnabled")
			if (NS.CommFlare.CF.CDMEnabled) then
				-- disable cooldown manager
				CVarSetCVar("cooldownViewerEnabled", 0)
			end
		end
	end
end

-- show stuff in vehicles
function NS:ShowStuffInVehicles(type)
	-- all or cdm?
	print("ShowStuffInVehicles:", type)
	if ((type == "all") or (type == "cdm")) then
		-- hide CDM while inside vehicles?
		if (NS.db.global.cdmHideInVehiclesPvP == true) then
			-- cooldown manager enabled?
			if (NS.CommFlare.CF.CDMEnabled) then
				-- enable cooldown manager
				CVarSetCVar("cooldownViewerEnabled", 1)
			end
		end
	end
end
