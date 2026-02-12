-- initialize
local LibStub = LibStub
local ADDON_NAME, NS = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
if (not L or not NS.CommFlare) then return end

-- localize stuff
local _G                                          = _G
local AcceptGroup                                 = _G.AcceptGroup
local CreateDataProvider                          = _G.CreateDataProvider
local DeclineQuest                                = _G.DeclineQuest
local FlashClientIcon                             = _G.FlashClientIcon
local GenericTraitUI_LoadUI                       = _G.GenericTraitUI_LoadUI
local GetAddOnCPUUsage                            = _G.GetAddOnCPUUsage
local GetAddOnMemoryUsage                         = _G.GetAddOnMemoryUsage
local GetAutoCompletePresenceID                   = _G.GetAutoCompletePresenceID
local GetBattlefieldWinner                        = _G.GetBattlefieldWinner
local GetHomePartyInfo                            = _G.GetHomePartyInfo
local GetInviteConfirmationInfo                   = _G.GetInviteConfirmationInfo
local GetLFGQueueStats                            = _G.GetLFGQueueStats
local GetLFGRoleUpdate                            = _G.GetLFGRoleUpdate
local GetLFGRoleUpdateBattlegroundInfo            = _G.GetLFGRoleUpdateBattlegroundInfo
local GetMaxBattlefieldID                         = _G.GetMaxBattlefieldID
local GetNextPendingInviteConfirmation            = _G.GetNextPendingInviteConfirmation
local GetNumBattlefieldScores                     = _G.GetNumBattlefieldScores
local GetNumGroupMembers                          = _G.GetNumGroupMembers
local GetNumSubgroupMembers                       = _G.GetNumSubgroupMembers
local GetPlayerInfoByGUID                         = _G.GetPlayerInfoByGUID
local GetRaidRosterInfo                           = _G.GetRaidRosterInfo
local GetQuestID                                  = _G.GetQuestID
local GetRealmName                                = _G.GetRealmName
local HideUIPanel                                 = _G.HideUIPanel
local InCombatLockdown                            = _G.InCombatLockdown
local IsInGroup                                   = _G.IsInGroup
local IsInInstance                                = _G.IsInInstance
local IsMounted                                   = _G.IsMounted
local IsInRaid                                    = _G.IsInRaid
local LoggingCombat                               = _G.LoggingCombat
local PromoteToAssistant                          = _G.PromoteToAssistant
local PVPMatchScoreboard                          = _G.PVPMatchScoreboard
local RaidWarningFrame_OnEvent                    = _G.RaidWarningFrame_OnEvent
local RequestBattlefieldScoreData                 = _G.RequestBattlefieldScoreData
local RespondToInviteConfirmation                 = _G.RespondToInviteConfirmation
local SetBattlefieldScoreFaction                  = _G.SetBattlefieldScoreFaction
local SocialQueueUtil_GetRelationshipInfo         = _G.SocialQueueUtil_GetRelationshipInfo
local StaticPopup_FindVisible                     = _G.StaticPopup_FindVisible
local StaticPopup_Hide                            = _G.StaticPopup_Hide
local StaticPopup1Text                            = _G.StaticPopup1Text
local ToggleFrame                                 = _G.ToggleFrame
local UnitFactionGroup                            = _G.UnitFactionGroup
local UnitGUID                                    = _G.UnitGUID
local UnitHonorLevel                              = _G.UnitHonorLevel
local UnitIsGroupLeader                           = _G.UnitIsGroupLeader
local UnitIsPlayer                                = _G.UnitIsPlayer
local UnitInRaid                                  = _G.UnitInRaid
local UnitName                                    = _G.UnitName
local AddOnsIsAddOnLoaded                         = _G.C_AddOns.IsAddOnLoaded
local AddOnsLoadAddOn                             = _G.C_AddOns.LoadAddOn
local AreaPoiInfoGetAreaPOIForMap                 = _G.C_AreaPoiInfo.GetAreaPOIForMap
local AreaPoiInfoGetAreaPOIInfo                   = _G.C_AreaPoiInfo.GetAreaPOIInfo
local BattleNetGetAccountInfoByGUID               = _G.C_BattleNet.GetAccountInfoByGUID
local ChatInfoInChatMessagingLockdown             = _G.C_ChatInfo.InChatMessagingLockdown
local ClubGetClubInfo                             = _G.C_Club.GetClubInfo
local ClubAreMembersReady                         = _G.C_Club.AreMembersReady
local ClubFinderReturnClubApplicantList           = _G.C_ClubFinder.ReturnClubApplicantList
local GetCVar                                     = _G.C_CVar.GetCVar
local GetCVarDefault                              = _G.C_CVar.GetCVarDefault
local SetCVar                                     = _G.C_CVar.SetCVar
local DelvesUIHasActiveDelve                      = _G.C_DelvesUI.HasActiveDelve
local EquipmentSetCanUseEquipmentSets             = _G.C_EquipmentSet.CanUseEquipmentSets
local EquipmentSetGetEquipmentSetInfo             = _G.C_EquipmentSet.GetEquipmentSetInfo
local EquipmentSetUseEquipmentSet                 = _G.C_EquipmentSet.UseEquipmentSet
local MapGetBestMapForUnit                        = _G.C_Map.GetBestMapForUnit
local MapGetMapInfo                               = _G.C_Map.GetMapInfo
local MapCanSetUserWaypointOnMap                  = _G.C_Map.CanSetUserWaypointOnMap
local MinimapGetPOITextureCoords                  = _G.C_Minimap.GetPOITextureCoords
local PartyInfoGetInviteReferralInfo              = _G.C_PartyInfo.GetInviteReferralInfo
local PartyInfoIsPartyFull                        = _G.C_PartyInfo.IsPartyFull
local PartyInfoLeaveParty                         = _G.C_PartyInfo.LeaveParty
local PvPGetActiveMatchState                      = _G.C_PvP.GetActiveMatchState
local PvPGetActiveMatchDuration                   = _G.C_PvP.GetActiveMatchDuration
local PvPGetBattlefieldVehicles                   = _G.C_PvP.GetBattlefieldVehicles
local PvPGetCustomVictoryStatID                   = _G.C_PvP.GetCustomVictoryStatID
local PvPGetScoreInfo                             = _G.C_PvP.GetScoreInfo
local PvPGetScoreInfoByPlayerGuid                 = _G.C_PvP.GetScoreInfoByPlayerGuid
local PvPIsActiveBattlefield                      = _G.C_PvP.IsActiveBattlefield
local PvPIsArena                                  = _G.C_PvP.IsArena
local PvPIsInBrawl                                = _G.C_PvP.IsInBrawl
local PvPIsMatchFactional                         = _G.C_PvP.IsMatchFactional
local PvPIsWarModeFeatureEnabled                  = _G.C_PvP.IsWarModeFeatureEnabled
local TraitsGetConfigIDByTreeID                   = _G.C_Traits.GetConfigIDByTreeID
local TraitsGetTreeCurrencyInfo                   = _G.C_Traits.GetTreeCurrencyInfo
local SocialQueueGetGroupInfo                     = _G.C_SocialQueue.GetGroupInfo
local TimerAfter                                  = _G.C_Timer.After
local date                                        = _G.date
local hooksecurefunc                              = _G.hooksecurefunc
local ipairs                                      = _G.ipairs
local issecretvalue                               = _G.issecretvalue
local next                                        = _G.next
local pairs                                       = _G.pairs
local print                                       = _G.print
local time                                        = _G.time
local tonumber                                    = _G.tonumber
local tostring                                    = _G.tostring
local bitband                                     = _G.bit.band
local bitbnot                                     = _G.bit.bnot
local mfloor                                      = _G.math.floor
local mmin                                        = _G.math.min
local strfind                                     = _G.string.find
local strformat                                   = _G.string.format
local strgsub                                     = _G.string.gsub
local strlower                                    = _G.string.lower
local strmatch                                    = _G.string.match
local strsplit                                    = _G.string.split
local tinsert                                     = _G.table.insert
local tsort                                       = _G.table.sort

-- process active delve data update
function NS.CommFlare:ACTIVE_DELVE_DATA_UPDATE(msg)
	-- in active delve
	NS.CommFlare.CF.InActiveDelve = true
end

-- process addon loaded
function NS.CommFlare:ADDON_LOADED(msg, ...)
	local addOnName = ...

	-- Blizzard_PVPUI?
	if (addOnName == "Blizzard_PVPUI") then
		-- enforce pvp roles
		NS:Enforce_PVP_Roles()

		-- setup hooks
		NS:SetupHooks()
	end
end

-- process area pois updated
function NS.CommFlare:AREA_POIS_UPDATED(msg)
	-- in battleground?
	if (NS:IsInBattleground() == true) then
		-- isle of conquest?
		if (NS.CommFlare.CF.MapID == 169) then
			-- process isle of conquest POIs
			NS:Process_IsleOfConquest_POIs(NS.CommFlare.CF.MapID)
		-- ashran?
		elseif (NS.CommFlare.CF.MapID == 1478) then
			-- process ashran POIs
			NS:Process_Ashran_POIs(NS.CommFlare.CF.MapID)
		end
	end
end

-- process chat message addon
function NS.CommFlare:CHAT_MSG_ADDON(msg, ...)
	local prefix, text, channel, sender, target, zoneChannelID, localID, name, instanceID = ...

	-- in chat messaging lockdown?
	if (ChatInfoInChatMessagingLockdown()) then
		-- finished
		return
	end

	-- sanity checks
	if (not prefix or not text or not sender) then
		-- finished
		return
	end

	-- community flare?
	if (prefix == ADDON_NAME) then
		-- requesting raid leader?
		text = tostring(text)
		if (text:find("REQUEST_RAID_LEADER")) then
			-- are you raid leader?
			NS.CommFlare.CF.PlayerRank = NS:GetRaidRank(UnitName("player"))
			if (NS.CommFlare.CF.PlayerRank == 2) then
				-- has shared community?
				sender = NS:GetFullName(tostring(sender))
				if (NS:Has_Shared_Community(sender) == true) then
					-- is sender community leader?
					if (NS:Is_Community_Leader(sender) == true) then
						-- promote
						NS:PromoteToRaidLeader(sender)
					end
				end
			end
		end
	end
end

-- process chat battle net whisper
function NS.CommFlare:CHAT_MSG_BN_WHISPER(msg, ...)
	local text, sender, _, _, _, _, _, _, _, _, _, _, bnSenderID = ...

	-- in chat messaging lockdown?
	if (ChatInfoInChatMessagingLockdown()) then
		-- finished
		return
	end

	-- invalid sender id?
	if (not bnSenderID) then
		-- no sender?
		if (not sender or (sender == "")) then
			-- failed
			return
		end

		-- find presense id from sender name
		bnSenderID = GetAutoCompletePresenceID(sender)
		if (not bnSenderID) then
			-- failed
			return
		end
	end

	-- version check?
	local lower = strlower(text)
	if (lower == "!cf") then
		-- process version check
		NS:Process_Version_Check(bnSenderID)
	-- pass leadership?
	elseif (lower == "!pl") then
		-- process pass leadership
		NS:Process_Pass_Leadership(bnSenderID)
	-- status check?
	elseif (lower == "!status") then
		-- in battleground?
		local timer = 0
		if (NS:IsInBattleground() == true) then
			-- battlefield score needs updating?
			if (PVPMatchScoreboard.selectedTab ~= 1) then
				-- request battlefield score
				NS.CommFlare.CF.WaitForUpdate = NS.CommFlare.CF.WaitForUpdate or {}
				NS.CommFlare.CF.WaitForUpdate["sender"] = bnSenderID
				NS.CommFlare.CF.WaitForUpdate["whisper"] = true
				SetBattlefieldScoreFaction()
				RequestBattlefieldScoreData()

				-- delay 0.5 seconds
				timer = 0.5
			end
		end

		-- run immediately?
		if (timer == 0) then
			-- process status check
			NS:Process_Status_Check(bnSenderID)
		end
	-- talents check?
	elseif (lower == "!talents") then
		-- process talents check
		NS:Process_Talents_Check(bnSenderID)
	else
		-- asking for invite?
		local args = {strsplit(" ", text)}
		local command = strlower(args[1])
		if ((command == "inv") or (command == "invite")) then
			-- process auto invite
			NS:Process_Auto_Invite(bnSenderID)
		end
	end
end

-- process chat communities channel message
function NS.CommFlare:CHAT_MSG_COMMUNITIES_CHANNEL(msg, ...)
	local text, sender, _, _, _, _, _, _, channelBaseName, _, _, _, bnSenderID = ...

	-- in chat messaging lockdown?
	if (ChatInfoInChatMessagingLockdown()) then
		-- finished
		return
	end

	-- has channel base name?
	if (channelBaseName) then
		-- split up
		local name, clubId, streamId = strsplit(":", channelBaseName)
		if (name and clubId and streamId) then
			-- get player
			clubId = tonumber(clubId)
			local player = NS.CommFlare.CF.PlayerFullName
			local member = NS:Get_Community_Member(player)
			if (member and member.clubs and member.clubs[clubId]) then
				-- update chat message data history
				NS:Update_Chat_Message_Data(sender)
			end
		end
	end
end

-- process chat monster say message
function NS.CommFlare:CHAT_MSG_MONSTER_SAY(msg, ...)
	local text, sender = ...

	-- in chat messaging lockdown?
	if (ChatInfoInChatMessagingLockdown()) then
		-- finished
		return
	end

	-- ruffious?
	if (sender == "Ruffious") then
		-- notify when war crate is inbound?
		if (NS.db.global.notifyWarCrateInbound == true) then
			-- war mode enabled?
			if (PvPIsWarModeFeatureEnabled() == true) then
				-- crate incoming message?
				local incoming = false
				if (text:find("cache of resources nearby")) then
					-- incoming
					incoming = true
				elseif (text:find("that means treasure hunters")) then
					-- incoming
					incoming = true
				elseif (text:find("valuable resources in the area")) then
					-- incoming
					incoming = true
				elseif (text:find("valuables waiting to be won")) then
					-- incoming
					incoming = true
				end

				-- incoming?
				if (incoming == true) then
					-- needs to issue raid warning?
					if (NS.CommFlare.CF.LastRaidWarning == 0) then
						-- update last raid warning
						NS.CommFlare.CF.LastRaidWarning = time()
						TimerAfter(150, function()
							-- clear last raid warning
							NS.CommFlare.CF.LastRaidWarning = 0
						end)

						-- issue local raid warning (with raid warning audio sound)
						RaidWarningFrame_OnEvent(RaidBossEmoteFrame, "CHAT_MSG_RAID_WARNING", L["War Supply Crate is flying in now!"])
					end
				end
			end
		end
	end
end

-- handle chat party message events
function NS:Event_Chat_Message_Party(...)
	local text, sender = ...

	-- in chat messaging lockdown?
	if (ChatInfoInChatMessagingLockdown()) then
		-- finished
		return
	end

	-- skip messages from yourself
	if (NS.CommFlare.CF.PlayerFullName ~= sender) then
		-- version check?
		local lower = strlower(text)
		if (lower:find("!cf")) then
			-- strip (name2chat):
			lower = strgsub(lower, "[\(](.+)[\)\:] ", "")

			-- exact matches only
			if (lower == "!cf") then
				-- send community flare version number
				NS:SendMessage(nil, strformat("%s: %s (%s)", NS.CommFlare.Title, NS.CommFlare.Version, NS.CommFlare.Build))
			end
		-- status check?
		elseif (lower:find("!status")) then
			-- strip (name2chat):
			lower = strgsub(lower, "[\(](.+)[\)\:] ", "")

			-- exact matches only
			if (lower == "!status") then
				-- in battleground?
				local timer = 0
				if (NS:IsInBattleground() == true) then
					-- battlefield score needs updating?
					if (PVPMatchScoreboard.selectedTab ~= 1) then
						-- request battlefield score
						NS.CommFlare.CF.WaitForUpdate = NS.CommFlare.CF.WaitForUpdate or {}
						NS.CommFlare.CF.WaitForUpdate["party"] = true
						SetBattlefieldScoreFaction()
						RequestBattlefieldScoreData()

						-- delay 0.5 seconds
						timer = 0.5
					end
				end

				-- run immediately?
				if (timer == 0) then
					-- process status check
					NS:Process_Status_Check(sender)
				end
			end
		end
	end
end

-- process chat party message
function NS.CommFlare:CHAT_MSG_PARTY(msg, ...)
	-- process chat message party event
	NS:Event_Chat_Message_Party(...)
end

-- process chat party leader message
function NS.CommFlare:CHAT_MSG_PARTY_LEADER(msg, ...)
	-- process chat message party event
	NS:Event_Chat_Message_Party(...)
end

-- process chat whisper message
function NS.CommFlare:CHAT_MSG_WHISPER(msg, ...)
	local text, sender = ...

	-- in chat messaging lockdown?
	if (ChatInfoInChatMessagingLockdown()) then
		-- finished
		return
	end

	-- version check?
	local lower = strlower(text)
	if (lower == "!cf") then
		-- process version check
		NS:Process_Version_Check(sender)
	-- pass leadership?
	elseif (lower == "!pl") then
		-- process pass leadership
		NS:Process_Pass_Leadership(sender)
	-- status check?
	elseif (lower == "!status") then
		-- in battleground?
		local timer = 0
		if (NS:IsInBattleground() == true) then
			-- battlefield score needs updating?
			if (PVPMatchScoreboard.selectedTab ~= 1) then
				-- request battlefield score
				NS.CommFlare.CF.WaitForUpdate = NS.CommFlare.CF.WaitForUpdate or {}
				NS.CommFlare.CF.WaitForUpdate["sender"] = sender
				NS.CommFlare.CF.WaitForUpdate["whisper"] = true
				SetBattlefieldScoreFaction()
				RequestBattlefieldScoreData()

				-- delay 0.5 seconds
				timer = 0.5
			end
		end

		-- run immediately?
		if (timer == 0) then
			-- process status check
			NS:Process_Status_Check(sender)
		end
	-- talents check?
	elseif (lower == "!talents") then
		-- process talents check
		NS:Process_Talents_Check(sender)
	else
		-- asking for invite?
		local args = {strsplit(" ", text)}
		local command = strlower(args[1])
		if ((command == "inv") or (command == "invite")) then
			-- process auto invite
			NS:Process_Auto_Invite(sender)
		end
	end
end

-- process club added
function NS.CommFlare:CLUB_ADDED(msg, ...)
	local clubId = ...

	-- in chat messaging lockdown?
	if (ChatInfoInChatMessagingLockdown()) then
		-- update club member later
		tinsert(NS.CommFlare.Updated.Club_Added, { clubId = clubId, timestamp = time() })
		return
	end

	-- found club?
	local info = ClubGetClubInfo(clubId)
	if (info) then
		-- guild?
		local shouldProcess = false
		if (info.clubType == Enum.ClubType.Guild) then
			-- treat guild as community?
			NS.CommFlare.CF.GuildID = clubId
			if (NS.charDB.profile.addGuildMembers == true) then
				-- process
				shouldProcess = true
			end
		elseif (info.clubType == Enum.ClubType.Character) then
			-- always process
			shouldProcess = true
		end

		-- should process?
		if (shouldProcess == true) then
			-- add community
			NS:Add_Community(clubId, info)
		end
	end
end

-- process club invitations received for club
function NS.CommFlare:CLUB_INVITATIONS_RECEIVED_FOR_CLUB(msg, ...)
	local clubId = ...

	-- cache player guid's
	local list = ClubFinderReturnClubApplicantList(clubId)
	for k,v in ipairs(list) do
		-- get name / server
		local name, realm = select(6, GetPlayerInfoByGUID(v.playerGUID))
		if (name) then
			-- no realm?
			if (not realm or (realm == "")) then
				-- use player server
				realm = NS.CommFlare.CF.PlayerServerName
			end

			-- build proper name
			local player = name
			if (not strmatch(player, "-")) then
				-- add realm name
				player = strformat("%s-%s", player, realm)
			end
		end
	end
end

-- process club member added
function NS.CommFlare:CLUB_MEMBER_ADDED(msg, ...)
	local clubId, memberId = ...

	-- in chat messaging lockdown?
	if (ChatInfoInChatMessagingLockdown()) then
		-- update club member later
		tinsert(NS.CommFlare.Updated.Club_Member_Added, { clubId = clubId, memberId = memberId, timestamp = time() })
		return
	end

	-- get enabled clubs
	local clubs = NS:Get_Enabled_Clubs()
	if (clubs and clubs[clubId]) then
		-- add club member
		NS:Club_Member_Added(clubId, memberId)
	end
end

-- process club member presense updated
function NS.CommFlare:CLUB_MEMBER_PRESENCE_UPDATED(msg, ...)
	local clubId, memberId, presence = ...

	-- in chat messaging lockdown?
	if (ChatInfoInChatMessagingLockdown()) then
		-- update club member later
		tinsert(NS.CommFlare.Updated.Club_Member_Presence_Updated, { clubId = clubId, memberId = memberId, presence = presence, timestamp = time() })
		return
	end

	-- always update, except on mobile
	if ((presence > 0) and (presense ~= Enum.ClubMemberPresence.OnlineMobile)) then
		-- only communities
		local club = ClubGetClubInfo(clubId)
		if (club.clubType == Enum.ClubType.Character) then
			-- get member info
			local mi = NS:GetClubMemberInfo(clubId, memberId)
			if (mi and mi.name and (mi.name ~= "")) then
				-- build proper name
				local player = mi.name
				if (not strmatch(player, "-")) then
					-- add realm name
					player = strformat("%s-%s", player, NS.CommFlare.CF.PlayerServerName)
				end

				-- get community member
				local member = NS:Get_Community_Member(player)
				if (member) then
					-- update last seen
					NS:Update_Last_Seen(player)
				end
			end
		end
	end
end

-- process club member removed
function NS.CommFlare:CLUB_MEMBER_REMOVED(msg, ...)
	local clubId, memberId = ...

	-- get enabled clubs
	local clubs = NS:Get_Enabled_Clubs()
	if (clubs and clubs[clubId]) then
		-- remove club member
		NS:Club_Member_Removed(clubId, memberId)
	end
end

-- process club member role updated
function NS.CommFlare:CLUB_MEMBER_ROLE_UPDATED(msg, ...)
	local clubId, memberId, roleId = ...

	-- update club member
	NS:Club_Member_Updated(clubId, memberId)
end

-- process club member updated
function NS.CommFlare:CLUB_MEMBER_UPDATED(msg, ...)
	local clubId, memberId = ...

	-- update club member
	NS:Club_Member_Updated(clubId, memberId)
end

-- process club members updated
function NS.CommFlare:CLUB_MEMBERS_UPDATED(msg, ...)
	local clubId = ...

	-- in chat messaging lockdown?
	if (ChatInfoInChatMessagingLockdown()) then
		-- update club member later
		tinsert(NS.CommFlare.Updated.Club_Members_Updated, { clubId = clubId, timestamp = time() })
		return
	end

	-- are members ready?
	if (ClubAreMembersReady(clubId) == true) then
		-- update last seen
		local members = CommunitiesUtil.GetAndSortMemberInfo(clubId)
		for k,v in ipairs(members) do
			-- online?
			if (v.presence and (v.presence == Enum.ClubMemberPresence.Online)) then
				-- get community member
				local member = NS:Get_Community_Member(v.name)
				if (member ~= nil) then
					-- update last seen
					NS:Update_Last_Seen(v.name)
				end
			end
		end

		-- has club data?
		if (NS.db.global.clubs[clubId]) then
			-- verify refreshed
			local last_refresh = NS.db.global.clubs[clubId].refreshed
			if (not last_refresh) then
				-- set zero
				last_refresh = 0
			end

			-- needs refreshing?
			local refresh = false
			if (last_refresh == 0) then
				-- refresh
				refresh = true
			elseif (last_refresh > 0) then
				-- refreshed more than 7 days ago?
				local next_refresh = last_refresh + (7 * 86400)
				if (time() > next_refresh) then
					-- refresh
					refresh = true
				end
			end

			-- should refresh?
			if (refresh == true) then
				-- process after 5 seconds
				TimerAfter(5, function()
					-- remove all club members
					NS:Remove_All_Club_Members_By_ClubID(clubId)

					-- add all club members
					NS:Add_All_Club_Members_By_ClubID(clubId)

					-- save time
					NS.db.global.clubs[clubId].refreshed = time()
				end)
			end
		end
	end
end

-- process club streams loaded
function NS.CommFlare:CLUB_STREAMS_LOADED(msg, ...)
	local clubId = ...

	-- in chat messaging lockdown?
	if (ChatInfoInChatMessagingLockdown()) then
		-- update club member later
		tinsert(NS.CommFlare.Updated.Club_Streams_Loaded, { clubId = clubId, timestamp = time() })
		return
	end

	-- get club info
	local info = ClubGetClubInfo(clubId)
	if (info) then
		-- stream loaded
		NS.CommFlare.CF.StreamsLoaded[clubId] = true
	end
end

-- process currency display update
function NS.CommFlare:CURRENCY_DISPLAY_UPDATE(msg, ...)
	local currencyType, quantity, quantityChange, quantityGainSource, destroyReason = ...

	-- conquest?
	if (currencyType == 1602) then
		-- notify when war crate is inbound?
		if (NS.db.global.notifyWarCrateInbound == true) then
			-- war mode enabled?
			if (PvPIsWarModeFeatureEnabled() == true) then
				-- remove all war supply crate waypoints
				NS:TomTomRemoveWaypoints("War Supply Crate")
			end
		end
	end
end

-- process cvar update
function NS.CommFlare:CVAR_UPDATE(msg, ...)
	local cvarName, value = ...

	-- cooldownViewerEnabled?
	if ((cvarName == "cooldownViewerEnabled") and (value == "1")) then
		-- hide cooldown manage while mounted?
		if (NS.db.global.cdmHideWhileMounted == true) then
			-- persistent?
			if (NS.CommFlare.CF.CDMPersistent == true) then
				-- is mounted?
				if (IsMounted()) then
					-- cooldown manager enabled?
					NS.CommFlare.CF.CDMEnabled = GetCVar("cooldownViewerEnabled")
					if (NS.CommFlare.CF.CDMEnabled) then
						-- disable cooldown manager
						SetCVar("cooldownViewerEnabled", 0)
					end
				end
			end
		end
	end
end

-- process group formed
function NS.CommFlare:GROUP_FORMED(msg, ...)
	local category, partyGUID = ...

	-- save partyGUID
	NS.CommFlare.CF.PartyGUID = partyGUID
end

-- process group invite confirmation
function NS.CommFlare:GROUP_INVITE_CONFIRMATION(msg)
	-- check for auto invites?
	local autoInvite = false
	if (not IsInGroup()) then
		-- yes
		autoInvite = true
	elseif (not IsInRaid() and IsInGroup()) then
		-- yes
		autoInvite = true
	end

	-- get next pending invite
	local invite = GetNextPendingInviteConfirmation()
	if (invite) then
		-- mercenary queued?
		if (NS:Battleground_IsMercenaryQueued() == true) then
			-- cancel invite
			RespondToInviteConfirmation(invite, false)

			-- hide popup
			if (StaticPopup_FindVisible("GROUP_INVITE_CONFIRMATION")) then
				-- hide
				StaticPopup_Hide("GROUP_INVITE_CONFIRMATION")
			end
		end

		-- check for auto invites?
		if (autoInvite == true) then
			-- get last show dialog
			local text = StaticPopup1Text["text_arg1"]
			local dialog = StaticPopup_FindVisible("GROUP_INVITE_CONFIRMATION")
			if (dialog) then
				-- get proper text
				text = dialog:GetText()
			end

			-- found text?
			local text = strlower(text)
			if (text and (text ~= "")) then
				-- you will be removed from?
				local lower = strlower(text)
				if (strfind(lower, L["you will be removed from"])) then
					-- get invite confirmation info
					local confirmationType, name, guid, rolesInvalid, willConvertToRaid, level, spec, itemLevel, isCrossFaction, playerFactionGroup, localizedFaction = GetInviteConfirmationInfo(invite)
					local referredByGuid, referredByName, relationType, isQuickJoin, clubId = PartyInfoGetInviteReferralInfo(invite)
					local playerName, color, selfRelationship = SocialQueueUtil_GetRelationshipInfo(guid, name, clubId)

					-- has proper name?
					local player = ""
					if (name and (name ~= "")) then
						-- force name-realm format
						player = name
						if (not strmatch(player, "-")) then
							-- add realm name
							player = strformat("%s-%s", player, NS.CommFlare.CF.PlayerServerName)
						end
					end

					-- cancel invite
					RespondToInviteConfirmation(invite, false)

					-- hide popup
					if (StaticPopup_FindVisible("GROUP_INVITE_CONFIRMATION")) then
						-- hide
						StaticPopup_Hide("GROUP_INVITE_CONFIRMATION")
					end

					-- battle net friend?
					if (selfRelationship == "bnfriend") then
						local accountInfo = BattleNetGetAccountInfoByGUID(guid)
						if (accountInfo and accountInfo.gameAccountInfo and accountInfo.gameAccountInfo.playerGuid) then
							-- send battle net message
							NS:SendMessage(accountInfo.bnetAccountID, L["Sorry, group is currently full."])
						end
					else
						-- send message
						NS:SendMessage(name, L["Sorry, group is currently full."])
					end

					-- display message
					print(strformat(L["%s: Inviting %s will remove you from queue!"], NS.CommFlare.Title, player))
				-- has requested to join your group?
				elseif (strfind(lower, L["has requested to join your group"])) then
					-- get invite confirmation info
					local confirmationType, name, guid, rolesInvalid, willConvertToRaid, level, spec, itemLevel, isCrossFaction, playerFactionGroup, localizedFaction = GetInviteConfirmationInfo(invite)
					local referredByGuid, referredByName, relationType, isQuickJoin, clubId = PartyInfoGetInviteReferralInfo(invite)
					local playerName, color, selfRelationship = SocialQueueUtil_GetRelationshipInfo(guid, name, clubId)

					-- will invite cause conversion to raid?
					local cancelInvite = false
					if (willConvertToRaid or (GetNumGroupMembers() > 4) or PartyInfoIsPartyFull()) then
						-- cancel invite
						cancelInvite = true
					else
						-- get count / maxCount
						local count = GetNumGroupMembers()
						local maxCount = NS:GetMaxGroupCount()
						if (count == 0) then
							-- at least 1
							count = 1
						end

						-- group is already full?
						if (count >= maxCount) then
							-- cancel invite
							cancelInvite = true
						end
					end

					-- cancel invite?
					if (cancelInvite == true) then
						-- cancel invite
						RespondToInviteConfirmation(invite, false)

						-- hide popup
						if (StaticPopup_FindVisible("GROUP_INVITE_CONFIRMATION")) then
							-- hide
							StaticPopup_Hide("GROUP_INVITE_CONFIRMATION")
						end

						-- battle net friend?
						if (selfRelationship == "bnfriend") then
							local accountInfo = BattleNetGetAccountInfoByGUID(guid)
							if (accountInfo and accountInfo.gameAccountInfo and accountInfo.gameAccountInfo.playerGuid) then
								-- send battle net message
								NS:SendMessage(accountInfo.bnetAccountID, L["Sorry, group is currently full."])
							end
						else
							-- send message
							NS:SendMessage(name, L["Sorry, group is currently full."])
						end
					else
						-- has proper name?
						local player = ""
						if (name and (name ~= "")) then
							-- force name-realm format
							player = name
							if (not strmatch(player, "-")) then
								-- add realm name
								player = strformat("%s-%s", player, NS.CommFlare.CF.PlayerServerName)
							end
						end

						-- battle net friend?
						NS.CommFlare.CF.AutoInvite = false
						if (selfRelationship == "bnfriend") then
							-- battle net auto invite enabled?
							if (NS.db.global.bnetAutoInvite == true) then
								-- auto invite enabled
								NS.CommFlare.CF.AutoInvite = true
							end
						end

						-- community auto invite enabled?
						if ((NS.CommFlare.CF.AutoInvite == false) and (NS.charDB.profile.communityAutoInvite == true)) then
							-- is sender a community member?
							NS.CommFlare.CF.AutoInvite = NS:Is_Community_Member(player)
						end

						-- auto invite?
						if (NS.CommFlare.CF.AutoInvite == true) then
							-- accept invite
							RespondToInviteConfirmation(invite, true)

							-- hide popup
							if (StaticPopup_FindVisible("GROUP_INVITE_CONFIRMATION")) then
								-- hide
								StaticPopup_Hide("GROUP_INVITE_CONFIRMATION")
							end
						end
					end
				end
			end
		end
	end
end

-- process group joined
function NS.CommFlare:GROUP_JOINED(msg, ...)
	local category, partyGUID = ...

	-- save partyGUID
	NS.CommFlare.CF.PartyGUID = partyGUID

	-- are you in a party?
	if (IsInGroup()) then
		-- is not group leader?
		if (UnitIsGroupLeader("player") == false) then
			-- always request party leadership?
			if (NS.db.global.alwaysRequestPartyLead == true) then
				-- player is community leader?
				local player = NS.CommFlare.CF.PlayerFullName
				if (NS:Is_Community_Leader(player) == true) then
					-- start processing
					TimerAfter(0.5, function()
						-- are you in a raid?
						if (IsInRaid()) then
							-- send addon message to raid
							NS:SendAddonMessage(ADDON_NAME, "REQUEST_PARTY_LEAD", "RAID")
						else
							-- send addon message to party
							NS:SendAddonMessage(ADDON_NAME, "REQUEST_PARTY_LEAD", "PARTY")
						end
					end)
				end
			end
		end

		-- queue exists?
		if (NS.CommFlare.CF.SocialQueues[partyGUID] and NS.CommFlare.CF.SocialQueues[partyGUID].guid and NS.CommFlare.CF.SocialQueues[partyGUID].created and (NS.CommFlare.CF.SocialQueues[partyGUID].created > 0)) then
			-- copy party queue to local
			NS.CommFlare.CF.SocialQueues["local"] = NS.CommFlare.CF.SocialQueues[partyGUID]
			NS.CommFlare.CF.SocialQueues[partyGUID] = nil

			-- update local group
			NS:Update_Group("local")
		end
	end
end

-- process group left
function NS.CommFlare:GROUP_LEFT(msg, ...)
	local category, partyGUID = ...

	-- disable community party leader
	NS.charDB.profile.communityPartyLeader = false

	-- delete partyGUID
	NS.CommFlare.CF.PartyGUID = nil

	-- not in raid?
	if (not IsInRaid()) then
		-- queue exists?
		if (NS.CommFlare.CF.SocialQueues["local"] and NS.CommFlare.CF.SocialQueues["local"].guid and NS.CommFlare.CF.SocialQueues["local"].created and (NS.CommFlare.CF.SocialQueues["local"].created > 0)) then
			-- copy local to party queues
			NS.CommFlare.CF.SocialQueues[partyGUID] = NS.CommFlare.CF.SocialQueues["local"]
			NS:Initialize_Group("local")

			-- update party group
			NS:Update_Group(partyGUID)
		end
	end
end

-- process group roster update
function NS.CommFlare:GROUP_ROSTER_UPDATE(msg)
	-- in arena?
	if (PvPIsArena() == true) then
		-- finished
		return
	end

	-- in delve?
	if (NS:IsInDelve() == true) then
		-- finished
		return
	end

	-- in battleground?
	if (NS:IsInBattleground() == true) then
		-- prematch gate open
		if (NS.CommFlare.CF.MatchStatus == 1) then
			-- do you have lead?
			local player = NS.CommFlare.CF.PlayerFullName
			NS.CommFlare.CF.PlayerRank = NS:GetRaidRank(UnitName("player"))
			if (NS.CommFlare.CF.PlayerRank == 2) then
				-- process all raid members
				for i=1, MAX_RAID_MEMBERS do
					-- only process members not already promoted
					local name, rank = GetRaidRosterInfo(i)
					if (name and rank and (rank == 0)) then
						-- force name-realm format
						local full_name = name
						if (not strmatch(full_name, "-")) then
							-- add realm name
							full_name = strformat("%s-%s", full_name, NS.CommFlare.CF.PlayerServerName)
						end

						-- get community member
						local member = NS:Get_Community_Member(full_name)
						if (member and member.clubs) then
							-- not already processed?
							if (not NS.CommFlare.CF.RosterList[full_name]) then
								-- should log list / i.e. has shared community?
								if (NS:Get_LogList_Status(full_name) == true) then
									-- only allow leaders?
									NS.CommFlare.CF.AutoPromote = false
									if (NS.charDB.profile.communityAutoAssist == 2) then
										-- player is community leader?
										if (NS:Is_Community_Leader(full_name) == true) then
											-- auto promote
											NS.CommFlare.CF.AutoPromote = true
										end
									-- allow all members?
									elseif (NS.charDB.profile.communityAutoAssist == 3) then
										-- auto promote
										NS.CommFlare.CF.AutoPromote = true
									end

									-- auto promote?
									if (NS.CommFlare.CF.AutoPromote == true) then
										-- promote
										PromoteToAssistant(name)
									end

									-- processed
									NS.CommFlare.CF.RosterList[full_name] = time()
								end
							end
						end
					end
				end

				-- auto pass raid leader?
				if (NS.charDB.profile.communityAutoPassLead == true) then
					-- process all community leaders
					for _,v in ipairs(NS.CommFlare.CF.CommunityLeaders) do
						-- already leader?
						if (player == v) then
							-- success
							break
						end

						-- higher or equal priority for leader?
						local compare = NS:Compare_Community_Priority(player, v)
						if (compare <= 0) then
							-- process pass leadership
							NS:PromoteToRaidLeader(v)
							break
						end
					end
				end
			end
		end

		-- verify ping status
		NS:VerifyPingStatus()
	-- are you in local party?
	elseif (IsInGroup(LE_PARTY_CATEGORY_HOME) and not IsInRaid()) then
		-- are you group leader?
		if (NS:IsGroupLeader() == true) then
			-- not in instance?
			local inInstance, instanceType = IsInInstance()
			if (inInstance ~= true) then
				-- community member?
				local message = "GROUP_ROSTER_UPDATE"
				if (NS.charDB.profile.communityMain > 1) then
					-- append YES
					message = message .. ":YES"
				else
					-- append NO
					message = message .. ":NO"
				end

				-- send party addon message
				NS:SendAddonMessage(ADDON_NAME, message, "PARTY")
			end

			-- check current players in home party
			local count = 1
			local players = GetHomePartyInfo()
			if (players ~= nil) then
				-- has group size changed?
				count = #players + count
				local text = NS:GetGroupCountText()
				local maxCount = NS:GetMaxGroupCount()
				if ((NS.CommFlare.CF.PreviousCount > 0) and (NS.CommFlare.CF.PreviousCount < maxCount) and (count == maxCount)) then
					-- community reporter enabled?
					if (NS.charDB.profile.communityReporter == true) then
						-- finalize text
						text = strformat("%s %s!", text, L["Full Now"])

						-- send to community
						NS:PopupBox("CommunityFlare_Send_Community_Dialog", text)
					end
				end
			end

			-- save previous count
			NS.CommFlare.CF.PreviousCount = count
		else
			-- clear previous count
			NS.CommFlare.CF.PreviousCount = 0
		end

		-- update local group
		NS:Update_Group("local")
	else
		-- clear previous count
		NS.CommFlare.CF.PreviousCount = 0
	end
end

-- process initial clubs loaded
function NS.CommFlare:INITIAL_CLUBS_LOADED(msg)
	-- initial login?
	if (NS.CommFlare.CF.InitialLogin == false) then
		-- verify default community setup
		NS:Verify_Default_Community_Setup()

		-- refresh club members
		NS:Refresh_Club_Members()

		-- initialized
		NS.CommFlare.CF.InitialLogin = true
	end
end

-- process lfg proposal done
function NS.CommFlare:LFG_PROPOSAL_DONE(msg)
	-- brawl queue exists?
	local index = "Brawl"
	if (NS.CommFlare.CF.LocalQueues[index]) then
		-- not rejected?
		if (NS.CommFlare.CF.LocalQueues[index].status ~= "rejected") then
			-- entered queue pop
			NS.CommFlare.CF.LocalQueues[index].status = "entered"
		end

		-- update brawl status
		NS:Update_Brawl_Status()
	end
end

-- process lfg proposal failed
function NS.CommFlare:LFG_PROPOSAL_FAILED(msg)
	-- brawl queue exists?
	local index = "Brawl"
	if (NS.CommFlare.CF.LocalQueues[index]) then
		-- not rejected?
		if (NS.CommFlare.CF.LocalQueues[index].status ~= "rejected") then
			-- missed queue pop
			NS.CommFlare.CF.LocalQueues[index].status = "failed"
		end

		-- update brawl status
		NS:Update_Brawl_Status()
	end
end

-- process lfg proposal show
function NS.CommFlare:LFG_PROPOSAL_SHOW(msg)
	-- brawl queue exists?
	local index = "Brawl"
	if (NS.CommFlare.CF.LocalQueues[index]) then
		-- update brawl status
		NS.CommFlare.CF.LocalQueues[index].status = "popped"
		NS:Update_Brawl_Status()
	end
end

-- process lfg proposal succeeded
function NS.CommFlare:LFG_PROPOSAL_SUCCEEDED(msg)
	-- brawl queue exists?
	local index = "Brawl"
	if (NS.CommFlare.CF.LocalQueues[index]) then
		-- update brawl status
		NS.CommFlare.CF.LocalQueues[index].status = "entered"
		NS:Update_Brawl_Status()
	end
end

-- process lfg queue status update
function NS.CommFlare:LFG_QUEUE_STATUS_UPDATE(msg)
	-- update brawl status
	NS:Update_Brawl_Status()
end

-- process lfg role check role chosen
function NS.CommFlare:LFG_ROLE_CHECK_ROLE_CHOSEN(msg, ...)
	local name, isTank, isHealer, isDamage = ...

	-- build proper name
	local player = name
	if (not strmatch(player, "-")) then
		-- add realm name
		player = strformat("%s-%s", player, NS.CommFlare.CF.PlayerServerName)
	end

	-- are you group leader?
	if (NS:IsGroupLeader() == true) then
		-- is this your role?
		if (name == UnitName("player")) then
			-- reset counts
			NS.CommFlare.CF.LocalData.NumDPS = 0
			NS.CommFlare.CF.LocalData.NumHealers = 0
			NS.CommFlare.CF.LocalData.NumTanks = 0

			-- initialize queue session
			NS:Initialize_Queue_Session()
		end
	end

	-- is battleground queue?
	local inProgress, slots, members, category, lfgID, bgQueue = GetLFGRoleUpdate()
	if (bgQueue) then
		-- is tracked pvp?
		local mapName = GetLFGRoleUpdateBattlegroundInfo()
		local isTracked, isEpicBattleground, isRandomBattleground, isBrawl = NS:IsTrackedPVP(mapName)
		if (isTracked == true) then
			-- first role chosen?
			if (not NS.CommFlare.CF.RoleChosen[player]) then
				-- is damage?
				if (isDamage == true) then
					-- increase
					NS.CommFlare.CF.LocalData.NumDPS = NS.CommFlare.CF.LocalData.NumDPS + 1
				end

				-- is healer?
				if (isHealer == true) then
					-- increase
					NS.CommFlare.CF.LocalData.NumHealers = NS.CommFlare.CF.LocalData.NumHealers + 1
				end

				-- is tank?
				if (isTank == true) then
					-- increase
					NS.CommFlare.CF.LocalData.NumTanks = NS.CommFlare.CF.LocalData.NumTanks + 1
				end
			end

			-- role chosen
			NS.CommFlare.CF.RoleChosen[player] = true
		end
	end
end

-- process lfg role check show
function NS.CommFlare:LFG_ROLE_CHECK_SHOW(msg, ...)
	local isRequeue = ...

	-- is battleground queue?
	local inProgress, slots, members, category, lfgID, bgQueue = GetLFGRoleUpdate()
	if (bgQueue) then
		-- is tracked pvp?
		local mapName = GetLFGRoleUpdateBattlegroundInfo()
		local isTracked, isEpicBattleground, isRandomBattleground, isBrawl = NS:IsTrackedPVP(mapName)
		if (isTracked == true) then
			-- capable of auto queuing?
			NS.CommFlare.CF.AutoQueueable = false
			if (not IsInRaid()) then
				-- auto queueable
				NS.CommFlare.CF.AutoQueueable = true
			else
				-- larger than rated battleground count?
				if (GetNumGroupMembers() > 10) then
					-- auto queueable
					NS.CommFlare.CF.AutoQueueable = true
				end
			end

			-- auto queueable?
			NS.CommFlare.CF.AutoQueue = false
			if (NS.CommFlare.CF.AutoQueueable == true) then
				-- party leader is community?
				if (NS.charDB.profile.communityPartyLeader == true) then
					-- auto queue enabled
					NS.CommFlare.CF.AutoQueue = true
				end

				-- always auto queue?
				if ((NS.CommFlare.CF.AutoQueue == false) and (NS.charDB.profile.alwaysAutoQueue == true)) then
					-- auto queue enabled
					NS.CommFlare.CF.AutoQueue = true
				end

				-- battle net auto queue enabled?
				if ((NS.CommFlare.CF.AutoQueue == false) and (NS.db.global.bnetAutoQueue == true)) then
					local guid = NS:GetPartyLeaderGUID()
					local info = BattleNetGetAccountInfoByGUID(guid)
					if (info and (info.isFriend == true)) then
						-- auto invite enabled
						NS.CommFlare.CF.AutoQueue = true
					end
				end

				-- community auto queue?
				if ((NS.CommFlare.CF.AutoQueue == false) and (NS.charDB.profile.communityAutoQueue == true)) then
					-- is party leader a community member?
					local leader = NS:GetPartyLeader()
					NS.CommFlare.CF.AutoQueue = NS:Is_Community_Member(leader)
				end
			end

			-- auto queue enabled?
			if (NS.CommFlare.CF.AutoQueue == true) then
				-- check for deserter
				NS:CheckForAura("player", "HARMFUL", L["Deserter"])
				if (NS.CommFlare.CF.HasAura == false) then
					-- is shown?
					if (LFDRoleCheckPopupAcceptButton:IsShown()) then
						-- click accept button
						LFDRoleCheckPopupAcceptButton:Click()
					end
				else
					-- have deserter / leave party
					NS:SendMessage(nil, strformat("%s! %s!", L["Sorry, I currently have deserter"], L["Leaving party to avoid interrupting the queue"]))
					PartyInfoLeaveParty()
				end
			end
		end
	end
end

-- process lfg update
function NS.CommFlare:LFG_UPDATE(msg)
	-- update brawl status
	NS:Update_Brawl_Status()
end

-- process name plate unit added
function NS.CommFlare:NAME_PLATE_UNIT_ADDED(msg, ...)
	local unit = ...

	-- player unit?
	if (UnitIsPlayer(unit)) then
		-- midnight?
		local guid = UnitGUID(unit)
		if (NS.CommFlare.isMidnight == true) then
			-- has secret value?
			if (issecretvalue(guid)) then
				-- delete
				guid = nil
			end
		end

		-- has guid?
		if (guid) then
			-- cached memberGUID?
			if (NS.db.global.MemberGUIDs[guid]) then
				-- cached member?
				local player = NS.db.global.MemberGUIDs[guid]
				if (NS.db.global.members[player]) then
					-- honor level updated?
					local honorLevel = UnitHonorLevel(unit)
					if (honorLevel and (NS.db.global.members[player].hl ~= honorLevel)) then
						-- save honor level
						NS.db.global.members[player].hl = honorLevel
					end
				end
			end
		end
	end
end

-- process notify pvp afk result
function NS.CommFlare:NOTIFY_PVP_AFK_RESULT(msg, ...)
	local offender, numBlackMarksOnOffender, numPlayersIHaveReported = ...

	-- hmmm, what is this?
	print(strformat("NOTIFY_PVP_AFK_RESULT: %s = %s, %s", offender, numBlackMarksOnOffender, numPlayersIHaveReported))
end

-- process party invite request
function NS.CommFlare:PARTY_INVITE_REQUEST(msg, ...)
	local sender, _, _, _, _, _, guid, questSessionActive = ...

	-- enforce pvp roles
	NS:Enforce_PVP_Roles()

	-- verify player does not have deserter debuff
	NS:CheckForAura("player", "HARMFUL", L["Deserter"])
	if (NS.CommFlare.CF.HasAura == false) then
		-- battle net auto invite enabled?
		NS.CommFlare.CF.AutoInvite = false
		if (NS.db.global.bnetAutoInvite == true) then
			local info = BattleNetGetAccountInfoByGUID(guid)
			if (info and (info.isFriend == true)) then
				-- auto invite enabled
				NS.CommFlare.CF.AutoInvite = true
			end
		end

		-- community auto invite enabled?
		if ((NS.CommFlare.CF.AutoInvite == false) and (NS.charDB.profile.communityAutoInvite == true)) then
			-- is sender a community member?
			NS.CommFlare.CF.AutoInvite = NS:Is_Community_Member(sender)
		end

		-- should auto invite?
		if (NS.CommFlare.CF.AutoInvite == true) then
			-- lfg invite popup shown?
			if (LFGInvitePopup:IsShown()) then
				-- click accept button
				LFGInvitePopupAcceptButton:Click()
			-- static popup shown?
			elseif (StaticPopup_FindVisible("PARTY_INVITE")) then
				-- accept party
				AcceptGroup()

				-- hide
				StaticPopup_Hide("PARTY_INVITE")
			end
		end
	else
		-- send whisper back that you have deserter
		NS:SendMessage(sender, strformat("%s!", L["Sorry, I currently have deserter"]))
		if (LFGInvitePopup:IsShown()) then
			-- click decline button
			LFGInvitePopupDeclineButton:Click()
		end
	end
end

-- process party kill
function NS.CommFlare:PARTY_KILL(msg, ...)
	local attackerGUID, targetGUID = ...

	-- has attacker name?
	local message = nil
	local attackerName, attackerRealm = select(6, GetPlayerInfoByGUID(attackerGUID))
	local targetName, targetRealm = select(6, GetPlayerInfoByGUID(targetGUID))
	if (attackerName) then
		-- debug print enabled?
		if (NS.db.global.debugPrint == true) then
			-- has target name?
			if (targetName) then
				-- build message
				message = NS.CommFlare.Title .. ": PARTY_KILL; Player " .. attackerName .. " (" .. attackerGUID .. ") killed Player " .. targetName .. "(" .. targetGUID .. ")"
			else
				-- build message
				message = NS.CommFlare.Title .. ": PARTY_KILL; Player " .. attackerName .. " (" .. attackerGUID .. ") killed Non-Player (" .. targetGUID .. ")"
			end
		end
	else
		-- debug print enabled?
		if (NS.db.global.debugPrint == true) then
			-- has target name?
			if (targetName) then
				-- build message
				message = NS.CommFlare.Title .. ": PARTY_KILL; Non-Player (" .. attackerGUID .. ") killed Player " .. targetName .. "(" .. targetGUID .. ")"
			else
				-- build message
				message = NS.CommFlare.Title .. ": PARTY_KILL; Non-Player (" .. attackerGUID .. ") killed Non-Player (" .. targetGUID .. ")"
			end
		end		
	end

	-- has message?
	if (message) then
		-- debug print
		NS:Debug_Print(message)
	end
end

-- process party leader changed
function NS.CommFlare:PARTY_LEADER_CHANGED(msg)
	-- update leader GUID
	NS.CommFlare.CF.LeaderGUID = NS:GetPartyLeaderGUID()

	-- notify enabled?
	if (NS.db.global.partyLeaderNotify > 1) then
		-- are you in a party / raid?
		if (IsInGroup()) then
			-- has more than 1 member?
			if (GetNumSubgroupMembers() > 0) then
				-- in battleground?
				local shouldWarn = false
				if (NS:IsInBattleground() == true) then
					-- match not completed?
					if (NS.CommFlare.CF.MatchStatus < 3) then
						-- not displayed warning yet?
						if (NS.CommFlare.CF.PassLeadWarning == 0) then
							-- are you group leader?
							if (NS:IsGroupLeader() == true) then
								-- should warn
								shouldWarn = true
							end

							-- save time when lead was passed
							NS.CommFlare.CF.PassLeadWarning = time()
						end
					end
				else
					-- are you group leader?
					if (NS:IsGroupLeader() == true) then
						-- should warn
						shouldWarn = true
					end

					-- reset pass lead warning
					NS.CommFlare.CF.PassLeadWarning = 0
				end

				-- should warn?
				if (shouldWarn == true) then
					-- you are the new party leader
					RaidWarningFrame_OnEvent(RaidBossEmoteFrame, "CHAT_MSG_RAID_WARNING", L["YOU ARE CURRENTLY THE NEW GROUP LEADER"])
				end
			end
		end
	end

	-- in battleground?
	if (NS:IsInBattleground() == true) then
		-- verify ping status
		NS:VerifyPingStatus()
	else
		-- update local group
		NS:Update_Group("local")
	end
end

-- process player entering world
function NS.CommFlare:PLAYER_ENTERING_WORLD(msg, ...)
	local isInitialLogin, isReloadingUi = ...

	-- has old settings?
	if (NS.db.profile) then
		-- process all values
		for k,v in pairs(NS.db.profile) do
			-- save per character
			NS.charDB.profile[k] = NS.db.profile[k]
			NS.db.profile[k] = nil
		end
	end

	-- setup player
	NS.CommFlare.CF.PlayerFaction = UnitFactionGroup("player")
	NS.CommFlare.CF.PlayerServerName = strgsub(GetRealmName(), "%s+", "")
	NS.CommFlare.CF.PlayerFullName = strformat("%s-%s", UnitName("player"), NS.CommFlare.CF.PlayerServerName)

	-- setup hooks
	NS:SetupHooks()

	-- hide cooldown manage while mounted?
	if (NS.db.global.cdmHideWhileMounted == true) then
		-- is mounted?
		if (IsMounted()) then
			-- cooldown manager enabled?
			NS.CommFlare.CF.CDMPersistent = true
			NS.CommFlare.CF.CDMEnabled = GetCVar("cooldownViewerEnabled")
			if (NS.CommFlare.CF.CDMEnabled) then
				-- disable cooldown manager
				SetCVar("cooldownViewerEnabled", 0)
			end

			-- disable later
			TimerAfter(5, function()
				-- disable
				NS.CommFlare.CF.CDMPersistent = false
			end)
		end
	end

	-- add get range check spell/s
	NS:AddRangeCheckSpell("DEATHKNIGHT", "Friend", 410358)

	-- initial login or reloading?
	if ((isInitialLogin == true) or (isReloadingUi == true)) then
		-- display version
		local version, subversion = strsplit("-", NS.CommFlare.Version)
		local major, minor = strsplit(".", version)
		print(strformat("%s: %s", NS.CommFlare.Title, NS.CommFlare.Version))
		NS.CommFlare.CF.VersionSent = false

		-- remove unused stuff
		NS.charDB.profile.communities = nil
		NS.charDB.profile.matchLogList = nil
		NS.charDB.profile.communityMainName = nil

		-- has main community?
		if (NS.charDB.profile.communityMain > 1) then
			-- force enabled
			NS.charDB.profile.communityLeadersList[NS.charDB.profile.communityMain] = true
		end

		-- enforce pvp roles
		NS:Enforce_PVP_Roles()

		-- enforce binding rules
		NS:Enforce_Binding_Rules()

		-- in battleground?
		NS.CommFlare.CF.MatchStatus = 0
		if (NS:IsInBattleground() == true) then
			-- match state is active?
			if (PvPGetActiveMatchState() == Enum.PvPMatchState.Active) then
				-- match is active state?
				NS.CommFlare.CF.MatchStatus = 1
				NS.CommFlare.CF.PassLeadWarning = 0
				if (PvPGetActiveMatchDuration() > 0) then
					-- match started
					NS.CommFlare.CF.MatchStatus = 2
				end

				-- available?
				if (NS.ShowAssistButton) then
					-- show assist button
					NS:ShowAssistButton()
				end
			end

			-- isle of conquest?
			if (NS.CommFlare.CF.MapID == 169) then
				-- process isle of conquest stuff
				NS:Process_IsleOfConquest_POIs(NS.CommFlare.CF.MapID)

				-- REPorter isle of conquest add callouts
				NS:REPorter_IsleOfConquest_Add_Callouts()
			-- ashran?
			elseif (NS.CommFlare.CF.MapID == 1478) then
				-- process ashran stuff
				NS:Process_Ashran_POIs(NS.CommFlare.CF.MapID)
				NS:Process_Ashran_Vignettes(NS.CommFlare.CF.MapID)
			end

			-- block game menu hot keys enabled?
			if (NS.charDB.profile.blockGameMenuHotKeys == true) then
				-- enable block game menu hooks
				NS:Setup_BlockGameMenuHooks()
			end
		end

		-- initialize login?
		if (isInitialLogin == true) then
			-- not reloaded
			NS.CommFlare.CF.Reloaded = false

			-- disable community party leader
			NS.charDB.profile.communityPartyLeader = false

			-- get config ID for Reshii Wraps
			local treeID = 1115
			local configID = TraitsGetConfigIDByTreeID(treeID)
			if (configID) then
				-- get currency info
				local currencyInfo = TraitsGetTreeCurrencyInfo(configID, treeID, true)
				if (currencyInfo and currencyInfo[1]) then
					-- found currency info?
					local info = currencyInfo[1]
					if (info and info.quantity and info.maxQuantity and info.spent) then
						-- has upgrades available?
						if ((info.quantity > 2) and (info.spent ~= info.maxQuantity)) then
							-- not loaded?
							if (not GenericTraitFrame) then
								-- initialize
								GenericTraitUI_LoadUI()
							end

							-- not in combat lockdown?
							if (InCombatLockdown() ~= true) then
								-- not shown?
								GenericTraitFrame:SetTreeID(1115)
								if (GenericTraitFrame:IsShown() ~= true) then
									-- toggle frame
									ToggleFrame(GenericTraitFrame)
								end
							else
								-- set cloak toggle
								NS.CommFlare.CF.RegenOptions = bitbor(NS.CommFlare.CF.RegenOptions, 2)
							end
						end
					end
				end
			end

			-- purge match list
			NS:Purge_Match_List()
		-- reloading?
		elseif (isReloadingUi == true) then
			-- reloaded
			NS.CommFlare.CF.Reloaded = true

			-- load previous session
			NS:LoadSession()

			-- update local group
			NS:Update_Group("local")

			-- initial clubs loaded
			self:INITIAL_CLUBS_LOADED()

			-- refresh active timers
			NS:Refresh_Active_Timers()
		end

		-- TODO: verify club streams
		--NS.CommFlare.CF.StreamsRetryCount = 0
		--local clubs = NS:Get_Enabled_Clubs()
		--NS:Verify_Club_Streams(clubs)
	else
		-- match is active state?
		if (PvPGetActiveMatchDuration() > 0) then
			-- match started
			NS.CommFlare.CF.MatchStatus = 2
		end
	end

	-- sanity checks
	NS:Sanity_Checks()

	-- run once only?
	if (NS.CommFlare.CF.RunOnce == false) then
		-- setup context menus
		NS:Setup_Context_Menus()

		-- has now run once
		NS.CommFlare.CF.RunOnce = true
	end
end

-- process player login
function NS.CommFlare:PLAYER_LOGIN(msg)
	-- load previous session
	NS:LoadSession()

	-- cooldown manager enabled?
	if (NS.CommFlare.CF.CDMEnabled) then
		-- enable cooldown manager
		SetCVar("cooldownViewerEnabled", 1)
	end
end

-- process player logout
function NS.CommFlare:PLAYER_LOGOUT(msg)
	-- enforce pvp roles
	NS:Enforce_PVP_Roles()

	-- save session variables
	NS:SaveSession()
end

-- process player map changed
function NS.CommFlare:PLAYER_MAP_CHANGED(msg, ...)
	local oldMapID, newMapID = ...

	-- in active delve?
	if (NS.CommFlare.CF.InActiveDelve == true) then
		-- exited
		NS.CommFlare.CF.InActiveDelve = false
	end
end

-- process player mount display changed
function NS.CommFlare:PLAYER_MOUNT_DISPLAY_CHANGED(msg)
	-- hide cooldown manage while mounted?
	if (NS.db.global.cdmHideWhileMounted == true) then
		-- is mounted?
		if (IsMounted()) then
			-- cooldown manager enabled?
			NS.CommFlare.CF.CDMEnabled = GetCVar("cooldownViewerEnabled")
			if (NS.CommFlare.CF.CDMEnabled) then
				-- disable cooldown manager
				SetCVar("cooldownViewerEnabled", 0)
			end
		else
			-- cooldown manager enabled?
			if (NS.CommFlare.CF.CDMEnabled) then
				-- enable cooldown manager
				SetCVar("cooldownViewerEnabled", 1)
			end
		end
	end
end

-- process player regen enabled
function NS.CommFlare:PLAYER_REGEN_ENABLED(msg)
	-- has regen options?
	if (NS.CommFlare.CF.RegenOptions > 0) then
		-- change equipment set?
		if (bitband(NS.CommFlare.CF.RegenOptions, 1)) then
			-- equip pvp gear equipment set
			EquipmentSetUseEquipmentSet(NS.charDB.profile.pvpGearEquipmentSet)

			-- clear regen options bit
			NS.CommFlare.CF.RegenOptions = bitband(NS.CommFlare.CF.RegenOptions, bitbnot(1))
		-- toggle cloak upgrade?
		elseif (bitband(NS.CommFlare.CF.RegenOptions, 2)) then
			-- not shown?
			GenericTraitFrame:SetTreeID(1115)
			if (GenericTraitFrame:IsShown() ~= true) then
				-- toggle frame
				ToggleFrame(GenericTraitFrame)
			end

			-- clear regen options bit
			NS.CommFlare.CF.RegenOptions = bitband(NS.CommFlare.CF.RegenOptions, bitbnot(2))
		else
			-- reset
			NS.CommFlare.CF.RegenOptions = 0
		end

		-- available?
		if (NS.AssistButton and NS.AssistButton.Button and NS.HideAssistButton and NS.ShowAssistButton) then
			-- hide assist button?
			if (NS.CommFlare.CF.RegenJobs["HideAssistButton"] == true) then
				-- hide
				NS.CommFlare.CF.RegenJobs["HideAssistButton"] = nil
				NS:HideAssistButton()
			elseif (NS.CommFlare.CF.RegenJobs["ShowAssistButton"] == true) then
				-- show
				NS.CommFlare.CF.RegenJobs["ShowAssistButton"] = nil
				NS:ShowAssistButton()
			end
		end
	end
end

-- process player roles assigned
function NS.CommFlare:PLAYER_ROLES_ASSIGNED(msg)
	-- available?
	if (NS.ShowAssistButton) then
		-- in battleground?
		if (NS:IsInBattleground() == true) then
			-- match state is not complete?
			if (PvPGetActiveMatchState() ~= Enum.PvPMatchState.Complete) then
				-- show assist button
				NS:ShowAssistButton()
			end
		end
	end
end

-- process pvp match active
function NS.CommFlare:PVP_MATCH_ACTIVE(msg)
	-- debug print enabled?
	local status = PvPGetActiveMatchState()
	if (NS.db.global.debugPrint == true) then
		-- debug print
		NS:Debug_Print(strformat("%s: PVP_MATCH_ACTIVE = %d", NS.CommFlare.Title, tonumber(status)))
	end

	-- initialize
	NS:Initialize_Battleground_Status()

	-- match is active state?
	if (PvPGetActiveMatchDuration() > 0) then
		-- match started
		NS.CommFlare.CF.MatchStatus = 2

		-- reload variables
		NS.CommFlare.CF.MatchEndTime = NS.charDB.profile.MatchEndTime or 0
		NS.CommFlare.CF.MatchStartDate = NS.charDB.profile.MatchStartDate or ""
		NS.CommFlare.CF.MatchStartTime = NS.charDB.profile.MatchStartTime or 0
	end

	-- display queue entry time left enabled?
	if (NS.db.global.displayQueueEntryTimeLeft == true) then
		-- match started?
		if (NS.CommFlare.CF.MatchStatus ~= 1) then
			-- report queue entry time left
			NS:Report_Queue_Entry_Time_Left()
		end
	end

	-- process club members
	NS:Process_Club_Members()

	-- should log pvp combat?
	if (NS.db.global.pvpCombatLogging == true) then
		-- save old value
		NS.CommFlare.CF.PvpLoggingCombat = LoggingCombat()

		-- not enabled?
		if (NS.CommFlare.CF.PvpLoggingCombat ~= true) then
			-- enable combat logging
			LoggingCombat(true)
		end
	end

	-- has pvp equipment set?
	if (NS.charDB.profile.pvpGearEquipmentSet ~= -1) then
		-- can use equipment sets?
		if (EquipmentSetCanUseEquipmentSets() == true) then
			local name, iconFileID, setID, isEquipped = EquipmentSetGetEquipmentSetInfo(NS.charDB.profile.pvpGearEquipmentSet)
			if (name and (isEquipped == false)) then
				-- not in combat lockdown?
				if (InCombatLockdown() ~= true) then
					-- equip pvp gear equipment set
					EquipmentSetUseEquipmentSet(NS.charDB.profile.pvpGearEquipmentSet)
				else
					-- set regen options bit
					NS.CommFlare.CF.RegenOptions = bitbor(NS.CommFlare.CF.RegenOptions, 1)
				end
			end
		end
	end

	-- block game menu hot keys enabled?
	if (NS.charDB.profile.blockGameMenuHotKeys == true) then
		-- enable block game menu hooks
		NS:Setup_BlockGameMenuHooks()
	end
end

-- process pvp match complete
function NS.CommFlare:PVP_MATCH_COMPLETE(msg, ...)
	local winner, duration = ...

	-- debug print enabled?
	local status = PvPGetActiveMatchState()
	if (NS.db.global.debugPrint == true) then
		-- debug print
		NS:Debug_Print(strformat("%s: PVP_MATCH_COMPLETE = %d, %d, %d", NS.CommFlare.Title, tonumber(status), tonumber(winner), tonumber(duration)))
	end

	-- enabled vehicle turn speed?
	if (NS.db.global.adjustVehicleTurnSpeed > 0) then
		-- reset default speed
		NS.CommFlare.CF.TurnSpeed = GetCVarDefault("TurnSpeed")
		SetCVar("TurnSpeed", NS.CommFlare.CF.TurnSpeed)
	end

	-- match finished
	NS.CommFlare.CF.LeftTime = 0
	NS.CommFlare.CF.EnteredTime = 0
	NS.CommFlare.CF.MatchStatus = 3
	NS.CommFlare.CF.PassLeadWarning = 0
	NS.CommFlare.CF.MatchEndDate = date()
	NS.CommFlare.CF.MatchEndTime = time()
	NS.CommFlare.CF.Winner = GetBattlefieldWinner()
	NS.CommFlare.CF.PlayerInfo = PvPGetScoreInfoByPlayerGuid(UnitGUID("player"))

	-- update battleground status
	local status = NS:Get_Current_Battleground_Status()
	if (status == true) then
		-- in battleground?
		if (NS:IsInBattleground() == true) then
			-- request battlefield score
			NS.CommFlare.CF.ScoreRequested = 2
			SetBattlefieldScoreFaction()
			RequestBattlefieldScoreData()
		end
	end

	-- use proper count
	local count = 0
	if (NS.CommFlare.CF.PlayerMercenary == true) then
		-- mercenary count
		count = NS.CommFlare.CF.MercCount
	else
		-- community count
		count = NS.CommFlare.CF.CommCount
	end

	-- get MapID
	NS.CommFlare.CF.MapID = MapGetBestMapForUnit("player")
	if (NS.CommFlare.CF.MapID) then
		-- get map info
		NS.CommFlare.CF.MapInfo = MapGetMapInfo(NS.CommFlare.CF.MapID)
	end

	-- has active timers?
	if (NS.CommFlare.CF.ActiveTimers and next(NS.CommFlare.CF.ActiveTimers)) then
		-- process all timers
		for k,v in pairs(NS.CommFlare.CF.ActiveTimers) do
			-- timer exists?
			if (v.timer) then
				-- cancel timer
				v.timer:Cancel()
			end
		end
	end

	-- report to anyone?
	if (NS.CommFlare.CF.StatusCheck and next(NS.CommFlare.CF.StatusCheck)) then
		-- process all
		local timer = 0.0
		for k,v in pairs(NS.CommFlare.CF.StatusCheck) do
			-- send replies staggered
			TimerAfter(timer, function()
				-- won the match?
				local text = nil
				if (NS.CommFlare.CF.PlayerInfo.faction == NS.CommFlare.CF.Winner) then
					-- victory
					text = strformat("%s = %d %s, %d %s; %s %s!", L["Time Elapsed"],
						NS.CommFlare.CF.Timer.Minutes, L["minutes"],
						NS.CommFlare.CF.Timer.Seconds, L["seconds"],
						L["Epic battleground has completed with a"], L["victory"])
				else
					-- loss
					text = strformat("%s = %d %s, %d %s; %s %s!", L["Time Elapsed"],
						NS.CommFlare.CF.Timer.Minutes, L["minutes"],
						NS.CommFlare.CF.Timer.Seconds, L["seconds"],
						L["Epic battleground has completed with a"], L["loss"])
				end

				-- send message
				NS:SendMessage(k, strformat("%s (%d %s)", text, count, L["Community Members"]))
			end)

			-- next
			timer = timer + 0.2
		end
	end

	-- clear
	NS.CommFlare.CF.StatusCheck = {}

	-- should log pvp combat?
	if (NS.db.global.pvpCombatLogging == true) then
		-- reset combat logging
		LoggingCombat(NS.CommFlare.CF.PvpLoggingCombat)
	end

	-- inside vehicle?
	if (UnitInVehicle("player")) then
		-- show stuff in vehicles
		NS:ShowStuffInVehicles("all")
	end

	-- available?
	if (NS.AssistButton and NS.HideAssistButton) then
		-- assist button shown?
		if (NS.AssistButton:IsShown()) then
			-- hide assist button
			NS:HideAssistButton()
		end
	end
end

-- process pvp match inactive
function NS.CommFlare:PVP_MATCH_INACTIVE(msg)
	-- debug print enabled?
	local status = PvPGetActiveMatchState()
	if (NS.db.global.debugPrint == true) then
		-- debug print
		NS:Debug_Print(strformat("%s: PVP_MATCH_INACTIVE = %d", NS.CommFlare.Title, tonumber(status)))
	end

	-- reset battleground status
	NS.CommFlare.CF.MatchStatus = 0
	NS:Reset_Battleground_Status()
end

-- process pvp match state changed
function NS.CommFlare:PVP_MATCH_STATE_CHANGED(msg)
	-- debug print enabled?
	local status = PvPGetActiveMatchState()
	if (NS.db.global.debugPrint == true) then
		-- debug print
		NS:Debug_Print(strformat("%s: PVP_MATCH_STATE_CHANGED = %d", NS.CommFlare.Title, tonumber(status)))
	end

	-- in battleground?
	if (NS:IsInBattleground() == true) then
		-- match just started?
		if (status == Enum.PvPMatchState.Engaged) then
			-- verify ping status
			NS:VerifyPingStatus()

			-- display battleground setup
			NS.CommFlare.CF.MatchStatus = 2
			NS.CommFlare.CF.MatchEndTime = 0
			NS.CommFlare.CF.MatchEndDate = ""
			NS.CommFlare.CF.MatchStartDate = date()
			NS.CommFlare.CF.MatchStartTime = time()

			-- request battlefield score
			NS.CommFlare.CF.ScoreRequested = 1
			SetBattlefieldScoreFaction()
			RequestBattlefieldScoreData()

			-- isle of conquest?
			if (NS.CommFlare.CF.MapID == 169) then
				-- REPorter isle of conquest add callouts
				NS:REPorter_IsleOfConquest_Add_Callouts()
			end
		end
	end
end

-- process pvp vehicle info updated
function NS.CommFlare:PVP_VEHICLE_INFO_UPDATED(msg)
	-- update vehicles
	NS:UpdateVehicles()
end

-- process quest accepted
function NS.CommFlare:QUEST_ACCEPTED(msg, ...)
	local questID = ...

	-- process accepted quest
	NS:ProcessAcceptedQuest(questID)
end

-- process quest detail
function NS.CommFlare:QUEST_DETAIL(msg, ...)
	local questStartItemID = ...

	-- verify quest giver
	local player, realm = UnitName("questnpc")
	if (player and (player ~= "")) then
		-- has realm?
		if (realm and (realm ~= "")) then
			-- add realm
			player = strformat("%s-%s", player, realm)
		end

		-- unit in raid?
		if (UnitInRaid(player) ~= nil) then
			-- in battleground?
			if (NS:IsInBattleground() == true) then
				-- block all shared quests?
				local decline = false
				if (NS.db.global.blockSharedQuests == 3) then
					-- always decline
					decline = true
				-- block irrelevant quests?
				elseif (NS.db.global.blockSharedQuests == 2) then
					-- get MapID
					NS.CommFlare.CF.MapID = MapGetBestMapForUnit("player")
					if (NS.CommFlare.CF.MapID and (NS.CommFlare.CF.MapID > 0)) then
						-- initialize
						decline = true
						local epicBG = false
						NS.CommFlare.CF.QuestID = GetQuestID()

						-- alterac valley or korrak's revenge?
						if ((NS.CommFlare.CF.MapID == 91) or (NS.CommFlare.CF.MapID == 1537)) then
							-- list of allowed quests
							local allowedQuests = {
								[56256] = true, -- The Battle for Alterac [A] (Seasonal)
								[56257] = true, -- The Battle for Alterac [H] (Seasonal)
								[56258] = true, -- Ivus the Forest Lord [A] (Seasonal)
								[56259] = true, -- Lokholar the Ice Lord [H] (Seasonal)
								[57300] = true, -- Soldier of Time [A+H] (Anniversary)
								[57302] = true, -- The Graveyards of Alterac [A] (Anniversary)
								[57303] = true, -- The Quartermaster [A] (Anniversary)
								[57304] = true, -- Capture a mine [A] (Anniversary)
								[57305] = true, -- Armor Scraps [A] (Anniversary)
								[57307] = true, -- Towers and Bunkers [A] (Anniversary)
								[57312] = true, -- The Graveyards of Alterac [H] (Anniversary)
								[57313] = true, -- Speak with our Quartermaster [H] (Anniversary)
								[57314] = true, -- Capture a mine [H] (Anniversary)
								[57315] = true, -- Towers and Bunkers [H] (Anniversary)
								[57317] = true, -- Enemy Booty [H] (Anniversary)
							}

							-- allowed quest?
							epicBG = true
							if (allowedQuests[NS.CommFlare.CF.QuestID] and (allowedQuests[NS.CommFlare.CF.QuestID] == true)) then
								-- allowed
								decline = false
							end
						-- isle of conquest?
						elseif (NS.CommFlare.CF.MapID == 169) then
							-- epic battleground
							epicBG = true
						-- battle for wintergrasp?
						elseif (NS.CommFlare.CF.MapID == 1334) then
							-- list of allowed quests
							local allowedQuests = {
								[13177] = true, -- No Mercy for the Merciless [A]
								[13178] = true, -- Slay them all! [H]
								[13178] = true, -- No Mercy for the Merciless [A]
								[13180] = true, -- Slay them all! [H]
								[13181] = true, -- Victory in Wintergrasp [A]
								[13183] = true, -- Victory in Wintergrasp [H]
								[13185] = true, -- Stop the Siege [H]
								[13186] = true, -- Stop the Siege [A]
								[13222] = true, -- Defend the Siege [A]
								[13223] = true, -- Defend the Siege [H]
								[13538] = true, -- Southern Sabotage [A]
								[13539] = true, -- Toppling the Towers [H]
								[55508] = true, -- Victory in Wintergrasp [A] (Seasonal)
								[55509] = true, -- Victory in Wintergrasp [H] (Seasonal)
								[55510] = true, -- No Mercy for the Merciless [A] (Seasonal)
								[55511] = true, -- Slay them all! [H] (Seasonal)
							}

							-- allowed quest?
							epicBG = true
							if (allowedQuests[NS.CommFlare.CF.QuestID] and (allowedQuests[NS.CommFlare.CF.QuestID] == true)) then
								-- allowed
								decline = false
							end
						-- ashran?
						elseif (NS.CommFlare.CF.MapID == 1478) then
							-- list of allowed quests
							local allowedQuests = {
								[56336] = true, -- Uncovering the Artifact Fragments [A] (Seasonal)
								[56337] = true, -- Uncovering the Artifact Fragments [H] (Seasonal)
								[56338] = true, -- Volrath Must Die [A] (Seasonal)
								[56339] = true, -- Tremblade Must Die [H] (Seasonal)
							}

							-- allowed quest?
							epicBG = true
							if (allowedQuests[NS.CommFlare.CF.QuestID] and (allowedQuests[NS.CommFlare.CF.QuestID] == true)) then
								-- allowed
								decline = false
							end
						end

						-- epic battleground?
						if (epicBG == true) then
							-- list of allowed quests
							local allowedQuests = {
								[39040] = true, -- A Call to Battle (Weekend Event)
								[47148] = true, -- Something Different (Seasonal)
								[72166] = true, -- Proving in Battle [A]
								[72167] = true, -- Proving in War [H]
								[72723] = true, -- A Call to Battle
								[80186] = true, -- Preserving in War
								[83345] = true, -- A Call to Battle (Weekend Event)
							}

							-- allowed quest?
							if (allowedQuests[NS.CommFlare.CF.QuestID] and (allowedQuests[NS.CommFlare.CF.QuestID] == true)) then
								-- allowed
								decline = false
							end
						else
							-- list of allowed quests
							local allowedQuests = {
								[39040] = true, -- A Call to Battle (Weekend Event)
								[47148] = true, -- Something Different (Seasonal)
								[83345] = true, -- A Call to Battle (Weekend Event)
							}

							-- allowed quest?
							if (allowedQuests[NS.CommFlare.CF.QuestID] and (allowedQuests[NS.CommFlare.CF.QuestID] == true)) then
								-- allowed
								decline = false
							end
						end
					end
				end

				-- decline?
				if (decline == true) then
					-- decline quest
					DeclineQuest()
					print(strformat("%s %s", L["Auto declined quest from"], player))
				end
			end
		end
	end
end

-- process ready check
function NS.CommFlare:READY_CHECK(msg, ...)
	local sender, timeleft = ...

	-- are you in a party / raid?
	NS.CommFlare.CF.ReadyCheck = {}
	NS.CommFlare.CF.PartyVersions = {}
	if (IsInGroup()) then
		-- are you in a raid?
		if (IsInRaid()) then
			-- are you group leader?
			if (NS:IsGroupLeader() == true) then
				-- send raid addon message
				NS:SendAddonMessage(ADDON_NAME, "READY_CHECK", "RAID")
			end

			-- still has popped battleground?
			local popped, mapName = NS:Has_Battleground_Popped()
			if ((popped == true) and mapName) then
				-- send raid message
				NS:SendMessage("RAID", strformat(L["I have not left the previously popped queue for %s."], mapName))
			end
		else
			-- are you group leader?
			if (NS:IsGroupLeader() == true) then
				-- send party addon message
				NS:SendAddonMessage(ADDON_NAME, "READY_CHECK", "PARTY")
			end

			-- still has popped battleground?
			local popped, mapName = NS:Has_Battleground_Popped()
			if ((popped == true) and mapName) then
				-- send party message
				NS:SendMessage(nil, strformat(L["I have not left the previously popped queue for %s."], mapName))
			end
		end
	end

	-- does the player have the mercenary buff?
	NS:CheckForAura("player", "HELPFUL", L["Mercenary Contract"])
	if (NS.CommFlare.CF.HasAura == true) then
		-- send party message
		NS:SendMessage(nil, strformat(L["I currently have the %s buff! (Are we mercing?)"], L["Mercenary Contract"]))
	end

	-- capable of auto queuing?
	NS.CommFlare.CF.AutoQueueable = false
	if (not IsInRaid()) then
		-- auto queue
		NS.CommFlare.CF.AutoQueueable = true
	else
		-- larger than rated battleground count?
		if (GetNumGroupMembers() > 10) then
			-- auto queue
			NS.CommFlare.CF.AutoQueueable = true
		end
	end

	-- auto queueable?
	NS.CommFlare.CF.AutoQueue = false
	if (NS.CommFlare.CF.AutoQueueable == true) then
		-- party leader is community?
		if (NS.charDB.profile.communityPartyLeader == true) then
			-- auto queue enabled
			NS.CommFlare.CF.AutoQueue = true
		end

		-- always auto queue?
		if ((NS.CommFlare.CF.AutoQueue == false) and (NS.charDB.profile.alwaysAutoQueue == true)) then
			-- auto queue enabled
			NS.CommFlare.CF.AutoQueue = true
		end

		-- battle net auto queue enabled?
		if ((NS.CommFlare.CF.AutoQueue == false) and (NS.db.global.bnetAutoQueue == true)) then
			local guid = NS:GetPartyLeaderGUID()
			local info = BattleNetGetAccountInfoByGUID(guid)
			if (info and (info.isFriend == true)) then
				-- auto queue enabled
				NS.CommFlare.CF.AutoQueue = true
			end
		end

		-- community auto queue?
		if ((NS.CommFlare.CF.AutoQueue == false) and (NS.charDB.profile.communityAutoQueue == true)) then
			-- is sender a community member?
			NS.CommFlare.CF.AutoQueue = NS:Is_Community_Member(sender)
		end
	end

	-- auto queue enabled?
	if (NS.CommFlare.CF.AutoQueue == true) then
		-- verify player does not have deserter debuff
		NS:CheckForAura("player", "HARMFUL", L["Deserter"])
		if (NS.CommFlare.CF.HasAura == false) then
			if (ReadyCheckFrame:IsShown()) then
				-- click yes button
				ReadyCheckFrameYesButton:Click()
			end

			-- ready
			NS.CommFlare.CF.ReadyCheck["player"] = true
			NS.CommFlare.CF.PartyVersions["player"] = NS.CommFlare.Version
		else
			-- has time left?
			local message = strformat("%s!", L["Sorry, I currently have deserter"])
			if (NS.CommFlare.CF.AuraData.timeLeft) then
				-- append time left
				local seconds = NS.CommFlare.CF.AuraData.timeLeft
				local minutes = mfloor(seconds / 60)
				seconds = seconds - (minutes * 60)
				local timeLeft = strformat(L["%d minutes, %d seconds"], minutes, seconds)
				message = strformat(L["%s (%s left.)"], message, timeLeft)
			end

			-- send back to party that you have deserter
			NS:SendMessage(nil, message)
			if (ReadyCheckFrame:IsShown()) then
				-- click no button
				ReadyCheckFrameNoButton:Click()
			end

			-- not ready
			NS.CommFlare.CF.ReadyCheck["player"] = false
			NS.CommFlare.CF.PartyVersions["player"] = NS.CommFlare.Version
		end
	end
end

-- process ready check confirm
function NS.CommFlare:READY_CHECK_CONFIRM(msg, ...)
	local unit, isReady = ...

	-- auto queueable?
	if (NS.CommFlare.CF.AutoQueueable == true) then
		-- save unit ready check status
		NS.CommFlare.CF.ReadyCheck[unit] = isReady
	end
end

-- process ready check finished
function NS.CommFlare:READY_CHECK_FINISHED(msg, ...)
	local preempted = ...

	-- preempted?
	if (preempted == true) then
		-- clear ready check
		NS.CommFlare.CF.ReadyCheck = {}
		return
	end

	-- auto queueable?
	if (NS.CommFlare.CF.AutoQueueable == true) then
		-- are you in a party?
		if (IsInGroup()) then
			-- process all ready checks
			local isEveryoneReady = true
			for k,v in pairs(NS.CommFlare.CF.ReadyCheck) do
				-- unit not ready?
				if (v ~= true) then
					-- everyone not ready
					isEveryoneReady = false
				end
			end

			-- is everyone ready?
			if (isEveryoneReady == true) then
				-- community reporter enabled?
				if (NS.charDB.profile.communityReporter == true) then
					-- are you group leader?
					if (NS:IsGroupLeader() == true) then
						-- alliance faction?
						local text = ""
						local count = NS:GetGroupCountText()
						local faction = UnitFactionGroup("player")
						if (faction == FACTION_ALLIANCE) then
							-- alliance ready
							text = strformat(L["%s Alliance Ready!"], count)
						-- horde faction?
						elseif (faction == FACTION_HORDE) then
							-- horde ready
							text = strformat(L["%s Horde Ready!"], count)
						else
							-- unknown faction?
							text = strformat("%s %s!", count, L["Ready"])
						end

						-- does the player have the mercenary buff?
						NS:CheckForAura("player", "HELPFUL", L["Mercenary Contract"])
						if (NS.CommFlare.CF.HasAura == true) then
							-- add mercenary contract
							text = strformat("%s [%s]", text, L["Mercenary Contract"])
						end

						-- check if group has room for more
						local maxCount = NS:GetMaxPartyCount()
						if (NS.CommFlare.CF.Count < maxCount) then
							-- community auto invite enabled
							if (NS.charDB.profile.communityAutoInvite == true) then
								-- update text
								text = strformat("%s (%s)", text, L["For auto invite, whisper me INV"])
							end
						end

						-- add tanks / heals / dps counts
						NS:Verify_Role_Counts()
						if ((NS.CommFlare.CF.LocalData.NumTanks > 0) or (NS.CommFlare.CF.LocalData.NumHealers > 0) or (NS.CommFlare.CF.LocalData.NumDPS > 0)) then
							-- add counts
							text = strformat(L["%s [%d Tanks, %d Healers, %d DPS]"], text, NS.CommFlare.CF.LocalData.NumTanks, NS.CommFlare.CF.LocalData.NumHealers, NS.CommFlare.CF.LocalData.NumDPS)
						end

						-- send to community
						NS:PopupBox("CommunityFlare_Send_Community_Dialog", text)
					end
				end
			end
		end
	end

	-- clear ready check
	NS.CommFlare.CF.ReadyCheck = {}
end

-- process social queue update
function NS.CommFlare:SOCIAL_QUEUE_UPDATE(msg, ...)
	local groupGUID, numAddedItems = ...

	-- nothing added?
	local canJoin, numQueues, needTank, needHealer, needDamage, isSoloQueueParty, questSessionActive, leaderGUID = SocialQueueGetGroupInfo(groupGUID)
	if ((not groupGUID) or (not numAddedItems) or (not leaderGUID)) then
		-- finished
		return
	end

	-- update group
	NS:Update_Group(groupGUID)
end

-- process ui info message
function NS.CommFlare:UI_INFO_MESSAGE(msg, ...)
	local type, text = ...

	-- someone has deserter?
	local lower = strlower(text)
	if (lower:find("deserter")) then
		print(strformat("%s!", L["Someone has deserter debuff"]))
	-- joined the queue for?
	elseif (lower:find(L["joined the queue for"])) then
		-- update local group
		NS:Update_Group("local")
	end
end

-- process unit aura
function NS.CommFlare:UNIT_AURA(msg, ...)
	local unitTarget, updateInfo = ...

	-- not midnight?
	if (NS.CommFlare.isMidnight == false) then
		-- check for player
		if (unitTarget == "player") then
			-- in battleground?
			if (NS:IsInBattleground() == true) then
				-- any added auras?
				if (updateInfo.addedAuras) then
					-- process all added auras
					for k,v in ipairs(updateInfo.addedAuras) do
						-- reported for inactive?
						if (v.spellId == 94028) then
							-- issue local raid warning (with raid warning audio sound)
							FlashClientIcon()
							RaidWarningFrame_OnEvent(RaidBossEmoteFrame, "CHAT_MSG_RAID_WARNING", L["WARNING: REPORTED INACTIVE!\nGet into combat quickly!"])
						-- mercenary contract?
						elseif ((v.spellId == 193472) or (v.spellId == 193475)) then
							-- are you in a party?
							if (IsInGroup() and not IsInRaid()) then
								-- send party message
								NS:SendMessage(nil, strformat(L["I currently have the %s buff! (Are we mercing?)"], L["Mercenary Contract"]))
							end
						-- shadow rift?
						elseif (v.spellId == 353293) then
							-- issue local raid warning (with raid warning audio sound)
							RaidWarningFrame_OnEvent(RaidBossEmoteFrame, "CHAT_MSG_RAID_WARNING", L["WARNING: SHADOW RIFT!\nCast immunity or run out of the circle!"])
						end
					end
				end
			end
		end
	end
end

-- process unit died
function NS.CommFlare:UNIT_DIED(msg, ...)
	local unitGUID = ...

	-- in battleground?
	if (NS:IsInBattleground() == true) then
		-- isle of conquest?
		if (NS.CommFlare.CF.MapID == 169) then
			-- non-player?
			local name = select(6, GetPlayerInfoByGUID(unitGUID))
			if (not name) then
				-- process IOC vehicles
				NS:Process_IsleOfConquest_Vehicles(NS.CommFlare.CF.MapID)
			end
		end
	end
end

-- process unit entered vehicle
function NS.CommFlare:UNIT_ENTERED_VEHICLE(msg, ...)
	local unitTarget, showVehicleFrame, isControlSeat, vehicleUIIndicatorID, vehicleGUID, mayChooseExit, hasPitch = ...

	-- check for player
	if (unitTarget == "player") then
		-- in battleground?
		if (NS:IsInBattleground() == true) then
			-- sanity check
			if ((NS.db.global.adjustVehicleTurnSpeed < 1) or (NS.db.global.adjustVehicleTurnSpeed > 3)) then
				-- force default
				NS.db.global.adjustVehicleTurnSpeed = 1
			end

			-- save old speed
			NS.CommFlare.CF.TurnSpeed = GetCVar("TurnSpeed")

			-- set new speed
			local speed = NS.db.global.adjustVehicleTurnSpeed * 180
			SetCVar("TurnSpeed", speed)

			-- hide stuff in vehicles
			NS:HideStuffInVehicles("all")
		end
	end
end

-- process unit exited vehicle
function NS.CommFlare:UNIT_EXITED_VEHICLE(msg, ...)
	local unitTarget = ...

	-- check for player
	if (unitTarget == "player") then
		-- in battleground?
		if (NS:IsInBattleground() == true) then
			-- default?
			if (NS.db.global.adjustVehicleTurnSpeed == 1) then
				-- reset default speed?
				NS.CommFlare.CF.TurnSpeed = GetCVarDefault("TurnSpeed")
			end

			-- set default or previous speed
			SetCVar("TurnSpeed", NS.CommFlare.CF.TurnSpeed)

			-- show stuff in vehicles
			NS:ShowStuffInVehicles("all")
		end
	end
end

-- process unit spellcast start
function NS.CommFlare:UNIT_SPELLCAST_START(msg, ...)
	local unitTarget, castGUID, spellID = ...

	-- only check player
	if (unitTarget == "player") then
		-- has warning setting enabled?
		if (NS.db.global.warningLeavingBG > 1) then
			-- in battleground?
			if (NS:IsInBattleground() == true) then
				-- hearthstone?
				if (NS.CommFlare.HearthStoneSpells[spellID]) then
					-- raid warning?
					if (NS.db.global.warningLeavingBG == 2) then
						-- issue local raid warning (with raid warning audio sound)
						RaidWarningFrame_OnEvent(RaidBossEmoteFrame, "CHAT_MSG_RAID_WARNING", L["Are you really sure you want to hearthstone?"])
					end
				-- teleporting?
				elseif (NS.CommFlare.TeleportSpells[spellID]) then
					-- raid warning?
					if (NS.db.global.warningLeavingBG == 2) then
						-- issue local raid warning (with raid warning audio sound)
						RaidWarningFrame_OnEvent(RaidBossEmoteFrame, "CHAT_MSG_RAID_WARNING", L["Are you really sure you want to teleport?"])
					end
				end
			end
		end
	end
end

-- process update battlefield score
function NS.CommFlare:UPDATE_BATTLEFIELD_SCORE(msg)
	-- match just started?
	if (NS.CommFlare.CF.ScoreRequested == 1) then
		-- update battleground / member / roster stuff
		NS.CommFlare.CF.ScoreRequested = 0
		NS:Update_Battleground_Stuff(true, true)
		NS:Update_Member_Statistics("started")
	-- match just ended?
	elseif (NS.CommFlare.CF.ScoreRequested == 2) then
		-- update battleground / member / roster stuff
		NS.CommFlare.CF.ScoreRequested = 0
		NS:Update_Battleground_Stuff(true, false)
		NS:Update_Member_Statistics("completed")
		NS:Log_Match_Roster()
	end

	-- inactive?
	if (NS.CommFlare.CF.WaitForUpdate["inactive"] == true) then
		-- check for inactive players
		NS:Check_For_Inactive_Players()

		-- clear inactive
		NS.CommFlare.CF.WaitForUpdate["inactive"] = nil
	end

	-- party?
	if (NS.CommFlare.CF.WaitForUpdate["party"] == true) then
		-- process status check
		NS:Process_Status_Check(nil)

		-- clear party
		NS.CommFlare.CF.WaitForUpdate["party"] = nil
	end

	-- update?
	if (NS.CommFlare.CF.WaitForUpdate["update"] == true) then
		-- display full battleground setup
		NS:Update_Battleground_Stuff(true, true)

		-- clear update
		NS.CommFlare.CF.WaitForUpdate["update"] = nil
	end

	-- whisper?
	if (NS.CommFlare.CF.WaitForUpdate["whisper"] == true) then
		-- process status check
		NS:Process_Status_Check(NS.CommFlare.CF.WaitForUpdate["sender"])

		-- clear sender / whisper
		NS.CommFlare.CF.WaitForUpdate["sender"] = nil
		NS.CommFlare.CF.WaitForUpdate["whisper"] = nil
	end

	-- match still going?
	if (NS.CommFlare.CF.MatchStatus < 3) then
		-- not displayed mercenary?
		if (NS.CommFlare.CF.DisplayedLists["mercenary"] ~= true) then
			-- update / display mercenary stuff
			NS:Update_Battleground_Stuff(false, false)

			-- match engaged?
			if (NS.CommFlare.CF.MatchStatus == 2) then
				-- print mercenary stuff
				NS:Print_Mercenary_Stuff(true, timer)
			end
		end

		-- not created?
		if (not NS.db.global.KosList) then
			-- initialize
			NS.db.global.KosList = {}
		end

		-- process all scores
		local kosAlerts = {}
		local numScores = GetNumBattlefieldScores()
		for i=1, numScores do
			local info = PvPGetScoreInfo(i)
			if (info and info.name and not issecretvalue(info.name)) then
				-- force name-realm format
				local player = info.name
				if (not strmatch(player, "-")) then
					-- player is NOT AI?
					if (info.honorLevel > 0) then
						-- add realm name
						player = strformat("%s-%s", player, NS.CommFlare.CF.PlayerServerName)
					end
				end

				-- add roster
				NS.CommFlare.CF.FullRoster[player] = info

				-- has guid?
				if (info.guid) then
					-- player is NOT AI?
					if (info.honorLevel > 0) then
						-- process member guid
						local guid = info.guid
						NS:Process_MemberGUID(guid, player)

						-- KOS target?
						if (NS.db.global.KosList[guid]) then
							-- not already alerted?
							if (not NS.CommFlare.CF.KosAlerted[guid]) then
								-- insert
								NS.CommFlare.CF.KosAlerted[guid] = player
								tinsert(kosAlerts, player)
							end
						end
					end
				end
			end
		end

		-- any alerts?
		if (#kosAlerts > 0) then
			-- sort
			tsort(kosAlerts)

			-- process all
			local text = nil
			for k,v in ipairs(kosAlerts) do
				-- first?
				if (not text) then
					-- initialize
					text = v
				else
					-- append
					text = strformat("%s, %s", text, v)
				end
			end

			-- has text?
			if (text) then
				-- issue local raid warning (with raid warning audio sound)
				RaidWarningFrame_OnEvent(RaidBossEmoteFrame, "CHAT_MSG_RAID_WARNING", strformat("KOS: %s", text))
			end
		end
	end
end

-- process update battlefield status
function NS.CommFlare:UPDATE_BATTLEFIELD_STATUS(msg, ...)
	local index = ...

	-- sanity check
	if (not index or (index < 1) or (index > GetMaxBattlefieldID())) then
		-- finished
		return
	end

	-- update battlefield status
	NS:Update_Battlefield_Status(index)
end

-- process update ui widget
function NS.CommFlare:UPDATE_UI_WIDGET(msg, ...)
	local widgetInfo = ...

	-- in battleground?
	if (NS:IsInBattleground() == true) then
		-- get widget type info
		local data = NS:GetWidgetData(widgetInfo)
		if (data) then
			-- update data
			NS.CommFlare.CF.ActiveWidgets[widgetInfo.widgetID] = data
		end

		-- alterac valley
		if (NS.CommFlare.CF.MapID == 91) then
			-- process alterac valley widget
			NS:Process_AlteracValley_Widget(widgetInfo)
		-- isle of conquest?
		elseif (NS.CommFlare.CF.MapID == 169) then
			-- process isle of conquest widget
			NS:Process_IsleOfConquest_Widget(widgetInfo)
		-- ashran?
		elseif (NS.CommFlare.CF.MapID == 1478) then
			-- process ashran widge
			NS:Process_Ashran_Widget(widgetInfo)
		end
	end
end

-- process vignettes updated
function NS.CommFlare:VIGNETTES_UPDATED(msg)
	-- in instance?
	local inInstance, instanceType = IsInInstance()
	if (inInstance == true) then
		-- in battleground?
		if (NS:IsInBattleground() == true) then
			-- ashran?
			if (NS.CommFlare.CF.MapID == 1478) then
				-- process ashran stuff
				NS:Process_Ashran_Vignettes(NS.CommFlare.CF.MapID)
			end
		end
	else
		-- notify when war crate is inbound?
		if (NS.db.global.notifyWarCrateInbound == true) then
			-- war mode enabled?
			if (PvPIsWarModeFeatureEnabled() == true) then
				-- get current vignettes
				local list = NS:Get_Current_Vignettes()
				if (list) then
					-- check for alerts
					NS:VignetteCheckForAlerts(list)
				end
			end
		end
	end
end

-- process zone changed new area
function NS.CommFlare:ZONE_CHANGED_NEW_AREA(msg)
	-- get map id
	NS.CommFlare.CF.MapID = MapGetBestMapForUnit("player")
	if (not NS.CommFlare.CF.MapID) then
		-- not found
		return
	end

	-- get map info
	NS.CommFlare.CF.MapInfo = MapGetMapInfo(NS.CommFlare.CF.MapID)
	if (not NS.CommFlare.CF.MapInfo) then
		-- not found
		return
	end

	-- enforce binding rules
	NS:Enforce_Binding_Rules()

	-- is tracked pvp?
	local mapName = NS.CommFlare.CF.MapInfo.name
	local isTracked, isEpicBattleground, isRandomBattleground, isBrawl = NS:IsTrackedPVP(mapName)
	if (isTracked == true) then
		-- version already sent?
		if (NS.CommFlare.CF.VersionSent == true) then
			-- clear version sent
			NS.CommFlare.CF.VersionSent = false
			return
		end

		-- has main community?
		local mainID = 1
		if (NS.charDB.profile.communityMain and (NS.charDB.profile.communityMain > 1)) then
			-- set mainID
			mainID = NS.charDB.profile.communityMain
		end

		-- send instance addon message
		local message = strformat("!CommFlare@%s@VERSION_CHECK@%s", NS.CommFlare.Version, tostring(mainID))
		NS:SendAddonMessage(ADDON_NAME, message, "INSTANCE_CHAT")

		-- in a guild?
		if (IsInGuild()) then
			-- send guild addon message
			NS:SendAddonMessage(ADDON_NAME, message, "GUILD")
		end

		-- set version sent
		NS.CommFlare.CF.VersionSent = true
	else
		-- are you in a party?
		if (IsInGroup()) then
			-- new zone warning not recently sent?
			if (NS.CommFlare.CF.NewZoneWarning == false) then
				-- new zone warning sent
				NS.CommFlare.CF.NewZoneWarning = true

				-- clear new zone warning after 5 seconds
				TimerAfter(5, function()
					-- clear new zone warning
					NS.CommFlare.CF.NewZoneWarning = false
				end)

				-- are you in a raid?
				local message = strformat("!CommFlare@%s@ZONE_CHANGED_NEW_AREA@%s:%s", NS.CommFlare.Version, tostring(NS.CommFlare.CF.MapID), tostring(mapName))
				if (IsInRaid()) then
					-- send raid addon message
					NS:SendAddonMessage(ADDON_NAME, message, "RAID")
				else
					-- send party addon message
					NS:SendAddonMessage(ADDON_NAME, message, "PARTY")
				end
			end
		end

		-- reset stuff
		NS.CommFlare.CF.VersionSent = false
		NS.CommFlare.CF.LastRaidWarning = 0
	end

	-- has assist button?
	if (NS.AssistButton and NS.HideAssistButton) then
		-- assist button shown?
		if (NS.AssistButton:IsShown()) then
			-- check zone type
			local inInstance, instanceType = IsInInstance()
			if (instanceType ~= "pvp") then
				-- hide assist button
				NS:HideAssistButton()
			end
		end
	end
end

-- enabled
function NS.CommFlare:OnEnable()
	-- version check?
	if (NS:IsOutdatedVersion() == true) then
		-- finished
		return
	end

	-- register events
	self:RegisterEvent("ACTIVE_DELVE_DATA_UPDATE")
	self:RegisterEvent("ADDON_LOADED")
	self:RegisterEvent("AREA_POIS_UPDATED")
	self:RegisterEvent("CHAT_MSG_ADDON")
	self:RegisterEvent("CHAT_MSG_BN_WHISPER")
	self:RegisterEvent("CHAT_MSG_COMMUNITIES_CHANNEL")
	self:RegisterEvent("CHAT_MSG_MONSTER_SAY")
	self:RegisterEvent("CHAT_MSG_PARTY")
	self:RegisterEvent("CHAT_MSG_PARTY_LEADER")
	self:RegisterEvent("CHAT_MSG_WHISPER")
	self:RegisterEvent("CLUB_ADDED")
	self:RegisterEvent("CLUB_INVITATIONS_RECEIVED_FOR_CLUB")
	self:RegisterEvent("CLUB_MEMBER_ADDED")
	self:RegisterEvent("CLUB_MEMBER_PRESENCE_UPDATED")
	self:RegisterEvent("CLUB_MEMBER_REMOVED")
	self:RegisterEvent("CLUB_MEMBER_ROLE_UPDATED")
	self:RegisterEvent("CLUB_MEMBER_UPDATED")
	self:RegisterEvent("CLUB_MEMBERS_UPDATED")
	self:RegisterEvent("CLUB_STREAMS_LOADED")
	self:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
	self:RegisterEvent("CVAR_UPDATE")
	self:RegisterEvent("GROUP_FORMED")
	self:RegisterEvent("GROUP_INVITE_CONFIRMATION")
	self:RegisterEvent("GROUP_JOINED")
	self:RegisterEvent("GROUP_LEFT")
	self:RegisterEvent("GROUP_ROSTER_UPDATE")
	self:RegisterEvent("INITIAL_CLUBS_LOADED")
	self:RegisterEvent("LFG_PROPOSAL_DONE")
	self:RegisterEvent("LFG_PROPOSAL_FAILED")
	self:RegisterEvent("LFG_PROPOSAL_SHOW")
	self:RegisterEvent("LFG_PROPOSAL_SUCCEEDED")
	self:RegisterEvent("LFG_QUEUE_STATUS_UPDATE")
	self:RegisterEvent("LFG_ROLE_CHECK_ROLE_CHOSEN")
	self:RegisterEvent("LFG_ROLE_CHECK_SHOW")
	self:RegisterEvent("LFG_UPDATE")
	self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
	self:RegisterEvent("NOTIFY_PVP_AFK_RESULT")
	self:RegisterEvent("PARTY_INVITE_REQUEST")
	self:RegisterEvent("PARTY_KILL")
	self:RegisterEvent("PARTY_LEADER_CHANGED")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PLAYER_LOGIN")
	self:RegisterEvent("PLAYER_LOGOUT")
	self:RegisterEvent("PLAYER_MAP_CHANGED")
	self:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("PLAYER_ROLES_ASSIGNED")
	self:RegisterEvent("PVP_MATCH_ACTIVE")
	self:RegisterEvent("PVP_MATCH_COMPLETE")
	self:RegisterEvent("PVP_MATCH_INACTIVE")
	self:RegisterEvent("PVP_MATCH_STATE_CHANGED")
	self:RegisterEvent("PVP_VEHICLE_INFO_UPDATED")
	self:RegisterEvent("QUEST_ACCEPTED")
	self:RegisterEvent("QUEST_DETAIL")
	self:RegisterEvent("READY_CHECK")
	self:RegisterEvent("READY_CHECK_CONFIRM")
	self:RegisterEvent("READY_CHECK_FINISHED")
	self:RegisterEvent("SOCIAL_QUEUE_UPDATE")
	self:RegisterEvent("UI_INFO_MESSAGE")
	self:RegisterEvent("UNIT_AURA")
	self:RegisterEvent("UNIT_DIED")
	self:RegisterEvent("UNIT_ENTERED_VEHICLE")
	self:RegisterEvent("UNIT_EXITED_VEHICLE")
	self:RegisterEvent("UNIT_SPELLCAST_START")
	self:RegisterEvent("UPDATE_BATTLEFIELD_SCORE")
	self:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
	self:RegisterEvent("UPDATE_UI_WIDGET")
	self:RegisterEvent("VIGNETTES_UPDATED")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
end

-- disabled
function NS.CommFlare:OnDisable()
	-- version check?
	if (NS:IsOutdatedVersion() == true) then
		-- finished
		return
	end

	-- unregister events
	self:UnregisterEvent("ACTIVE_DELVE_DATA_UPDATE")
	self:UnregisterEvent("ADDON_LOADED")
	self:UnregisterEvent("AREA_POIS_UPDATED")
	self:UnregisterEvent("CHAT_MSG_ADDON")
	self:UnregisterEvent("CHAT_MSG_BN_WHISPER")
	self:UnregisterEvent("CHAT_MSG_COMMUNITIES_CHANNEL")
	self:UnregisterEvent("CHAT_MSG_MONSTER_SAY")
	self:UnregisterEvent("CHAT_MSG_PARTY")
	self:UnregisterEvent("CHAT_MSG_PARTY_LEADER")
	self:UnregisterEvent("CHAT_MSG_WHISPER")
	self:UnregisterEvent("CLUB_ADDED")
	self:UnregisterEvent("CLUB_INVITATIONS_RECEIVED_FOR_CLUB")
	self:UnregisterEvent("CLUB_MEMBER_ADDED")
	self:UnregisterEvent("CLUB_MEMBER_PRESENCE_UPDATED")
	self:UnregisterEvent("CLUB_MEMBER_REMOVED")
	self:UnregisterEvent("CLUB_MEMBER_ROLE_UPDATED")
	self:UnregisterEvent("CLUB_MEMBER_UPDATED")
	self:UnregisterEvent("CLUB_MEMBERS_UPDATED")
	self:UnregisterEvent("CLUB_STREAMS_LOADED")
	self:UnregisterEvent("CURRENCY_DISPLAY_UPDATE")
	self:UnregisterEvent("CVAR_UPDATE")
	self:UnregisterEvent("GROUP_FORMED")
	self:UnregisterEvent("GROUP_INVITE_CONFIRMATION")
	self:UnregisterEvent("GROUP_JOINED")
	self:UnregisterEvent("GROUP_LEFT")
	self:UnregisterEvent("GROUP_ROSTER_UPDATE")
	self:UnregisterEvent("INITIAL_CLUBS_LOADED")
	self:UnregisterEvent("LFG_PROPOSAL_DONE")
	self:UnregisterEvent("LFG_PROPOSAL_FAILED")
	self:UnregisterEvent("LFG_PROPOSAL_SHOW")
	self:UnregisterEvent("LFG_PROPOSAL_SUCCEEDED")
	self:UnregisterEvent("LFG_QUEUE_STATUS_UPDATE")
	self:UnregisterEvent("LFG_ROLE_CHECK_ROLE_CHOSEN")
	self:UnregisterEvent("LFG_ROLE_CHECK_SHOW")
	self:UnregisterEvent("LFG_UPDATE")
	self:UnregisterEvent("NAME_PLATE_UNIT_ADDED")
	self:UnregisterEvent("NOTIFY_PVP_AFK_RESULT")
	self:UnregisterEvent("PARTY_INVITE_REQUEST")
	self:UnregisterEvent("PARTY_KILL")
	self:UnregisterEvent("PARTY_LEADER_CHANGED")
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	self:UnregisterEvent("PLAYER_LOGIN")
	self:UnregisterEvent("PLAYER_LOGOUT")
	self:UnregisterEvent("PLAYER_MAP_CHANGED")
	self:UnregisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED")
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	self:UnregisterEvent("PLAYER_ROLES_ASSIGNED")
	self:UnregisterEvent("PVP_MATCH_ACTIVE")
	self:UnregisterEvent("PVP_MATCH_COMPLETE")
	self:UnregisterEvent("PVP_MATCH_INACTIVE")
	self:UnregisterEvent("PVP_MATCH_STATE_CHANGED")
	self:UnregisterEvent("PVP_VEHICLE_INFO_UPDATED")
	self:UnregisterEvent("QUEST_ACCEPTED")
	self:UnregisterEvent("QUEST_DETAIL")
	self:UnregisterEvent("READY_CHECK")
	self:UnregisterEvent("READY_CHECK_CONFIRM")
	self:UnregisterEvent("READY_CHECK_FINISHED")
	self:UnregisterEvent("SOCIAL_QUEUE_UPDATE")
	self:UnregisterEvent("UI_INFO_MESSAGE")
	self:UnregisterEvent("UNIT_AURA")
	self:UnregisterEvent("UNIT_DIED")
	self:UnregisterEvent("UNIT_ENTERED_VEHICLE")
	self:UnregisterEvent("UNIT_EXITED_VEHICLE")
	self:UnregisterEvent("UNIT_SPELLCAST_START")
	self:UnregisterEvent("UPDATE_BATTLEFIELD_SCORE")
	self:UnregisterEvent("UPDATE_BATTLEFIELD_STATUS")
	self:UnregisterEvent("UPDATE_UI_WIDGET")
	self:UnregisterEvent("VIGNETTES_UPDATED")
	self:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
end

-- communication received
local function Community_Flare_OnCommReceived(prefix, message, distribution, sender)
	-- debug print enabled?
	if (NS.db.global.debugPrint == true) then
		-- debug print
		NS:Debug_Print(strformat("OnCommReceived: %s on %s by %s = %s", tostring(prefix), tostring(distribution), tostring(sender), tostring(message)))
	end

	-- process communication received
	NS:Process_OnCommReceived(prefix, message, distribution, sender)
end

-- register addon communication
NS.CommFlare:RegisterComm(ADDON_NAME, Community_Flare_OnCommReceived)
