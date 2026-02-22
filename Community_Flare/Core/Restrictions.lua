-- initialize
local LibStub = LibStub
local ADDON_NAME, NS = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
if (not L or not NS.CommFlare) then return end
 
-- localize stuff
local _G                                          = _G
local GetSpecializationInfoForClassID             = _G.GetSpecializationInfoForClassID
local IsInGroup                                   = _G.IsInGroup
local IsInRaid                                    = _G.IsInRaid
local UnitExists                                  = _G.UnitExists
local UnitFactionGroup                            = _G.UnitFactionGroup
local UnitFullName                                = _G.UnitFullName
local UnitGetAvailableRoles                       = _G.UnitGetAvailableRoles
local UnitGUID                                    = _G.UnitGUID
local UnitHonorLevel                              = _G.UnitHonorLevel
local UnitInParty                                 = _G.UnitInParty
local UnitInRaid                                  = _G.UnitInRaid
local UnitInVehicle                               = _G.UnitInVehicle
local UnitIsConnected                             = _G.UnitIsConnected
local UnitIsDeadOrGhost                           = _G.UnitIsDeadOrGhost
local UnitIsGroupLeader                           = _G.UnitIsGroupLeader
local UnitIsPlayer                                = _G.UnitIsPlayer
local UnitLevel                                   = _G.UnitLevel
local UnitRealmRelationship                       = _G.UnitRealmRelationship
local GetAreaPOIForMap                            = _G.C_AreaPoiInfo.GetAreaPOIForMap
local GetAreaPOIInfo                              = _G.C_AreaPoiInfo.GetAreaPOIInfo
local GetAccountInfoByGUID                        = _G.C_BattleNet.GetAccountInfoByGUID
local GetFriendAccountInfo                        = _G.C_BattleNet.GetFriendAccountInfo
local GetFriendGameAccountInfo                    = _G.C_BattleNet.GetFriendGameAccountInfo
local GetFriendNumGameAccounts                    = _G.C_BattleNet.GetFriendNumGameAccounts
local SendWhisper                                 = _G.C_BattleNet.SendWhisper
local InChatMessagingLockdown                     = _G.C_ChatInfo.InChatMessagingLockdown
local SendChatMessage                             = _G.C_ChatInfo.SendChatMessage
local AreMembersReady                             = _G.C_Club.AreMembersReady
local GetClubInfo                                 = _G.C_Club.GetClubInfo
local GetClubMembers                              = _G.C_Club.GetClubMembers
local FocusMembers                                = _G.C_Club.FocusMembers
local GetMemberInfo                               = _G.C_Club.GetMemberInfo
local GetSubscribedClubs                          = _G.C_Club.GetSubscribedClubs
local GetStreamInfo                               = _G.C_Club.GetStreamInfo
local GetStreams                                  = _G.C_Club.GetStreams
local ReturnClubApplicantList                     = _G.C_ClubFinder.ReturnClubApplicantList
local GetFactionInfo                              = _G.C_CreatureInfo.GetFactionInfo
local GetCurrencyInfo                             = _G.C_CurrencyInfo.GetCurrencyInfo
local HasActiveDelve                              = _G.C_DelvesUI.HasActiveDelve
local GetEquipmentSetInfo                         = _G.C_EquipmentSet.GetEquipmentSetInfo
local UseEquipmentSet                             = _G.C_EquipmentSet.UseEquipmentSet
local GetItemCount                                = _G.C_Item.GetItemCount
local GetAllEntriesForCategory                    = _G.C_LFGInfo.GetAllEntriesForCategory
local HideNameFromUI                              = _G.C_LFGInfo.HideNameFromUI
local GetBestMapForUnit                           = _G.C_Map.GetBestMapForUnit
local GetMapInfo                                  = _G.C_Map.GetMapInfo
local CanSetUserWaypointOnMap                     = _G.C_Map.CanSetUserWaypointOnMap
local SetUserWaypoint                             = _G.C_Map.SetUserWaypoint
local GetPOITextureCoords                         = _G.C_Minimap.GetPOITextureCoords
local GetInviteReferralInfo                       = _G.C_PartyInfo.GetInviteReferralInfo
local InviteUnit                                  = _G.C_PartyInfo.InviteUnit
local IsPartyFull                                 = _G.C_PartyInfo.IsPartyFull
local LeaveParty                                  = _G.C_PartyInfo.LeaveParty
local SetRestrictPings                            = _G.C_PartyInfo.SetRestrictPings
local PlayerInfoGetRace                           = _G.C_PlayerInfo.GetRace
local GetBattlefieldVehicles                      = _G.C_PvP.GetBattlefieldVehicles
local GetBattlegroundInfo                         = _G.C_PvP.GetBattlegroundInfo
local GetScoreInfo                                = _G.C_PvP.GetScoreInfo
local GetScoreInfoByPlayerGuid                    = _G.C_PvP.GetScoreInfoByPlayerGuid
local GetGroupForPlayer                           = _G.C_SocialQueue.GetGroupForPlayer
local GetGroupInfo                                = _G.C_SocialQueue.GetGroupInfo
local GetGroupMembers                             = _G.C_SocialQueue.GetGroupMembers
local GetGroupQueues                              = _G.C_SocialQueue.GetGroupQueues
local SetSuperTrackedUserWaypoint                 = _G.C_SuperTrack.SetSuperTrackedUserWaypoint
local GenerateImportString                        = _G.C_Traits.GenerateImportString
local GetConfigIDByTreeID                         = _G.C_Traits.GetConfigIDByTreeID
local GetTreeCurrencyInfo                         = _G.C_Traits.GetTreeCurrencyInfo
local GetUnitAuras                                = _G.C_UnitAuras.GetUnitAuras
local GetVignetteInfo                             = _G.C_VignetteInfo.GetVignetteInfo
local GetVignettePosition                         = _G.C_VignetteInfo.GetVignettePosition
local issecretvalue                               = _G.issecretvalue
local type                                        = _G.type

-- unit exists
function NS:GetSpecializationInfoForClassID(classID, index, ...)
	-- sanity checks
	if (not classID or not index or issecretvalue(classID) or issecretvalue(index)) then
		-- failed
		return nil
	end

	-- success
	return GetSpecializationInfoForClassID(classID, index, ...)
end

-- unit exists
function NS:UnitExists(unitToken)
	-- sanity checks
	if (not unitToken or issecretvalue(unitToken)) then
		-- failed
		return nil
	end

	-- success
	return UnitExists(unitId)
end

-- unit full name
function NS:UnitFullName(unitToken)
	-- sanity checks
	if (not unitToken or issecretvalue(unitToken)) then
		-- failed
		return nil
	end

	-- success
	return UnitFullName(unitId)
end

-- unit faction group
function NS:UnitFactionGroup(unitId)
	-- sanity checks
	if (not unitId or issecretvalue(unitId)) then
		-- failed
		return nil
	end

	-- success
	return UnitFactionGroup(unitId)
end

-- unit get available roles
function NS:UnitGetAvailableRoles(unitId)
	-- sanity checks
	if (not unitId or issecretvalue(unitId)) then
		-- failed
		return nil
	end

	-- success
	return UnitGetAvailableRoles(unitId)
end

-- unit guid
function NS:UnitGUID(unitToken)
	-- sanity checks
	if (not unitToken or issecretvalue(unitToken)) then
		-- failed
		return nil
	end

	-- blizzard bugfix
	if (not UnitExists(unitToken)) then
		-- failed
		return nil
	end

	-- success
	return UnitGUID(unitToken)
end

-- unit honor level
function NS:UnitHonorLevel(unitToken)
	-- sanity checks
	if (not unitToken or issecretvalue(unitToken)) then
		-- failed
		return nil
	end

	-- success
	return UnitHonorLevel(unitToken)
end

-- unit in party
function NS:UnitInParty(unitToken)
	-- sanity checks
	if (not unitToken or issecretvalue(unitToken)) then
		-- failed
		return nil
	end

	-- success
	return UnitInParty(unitToken)
end

-- unit in raid
function NS:UnitInRaid(unitToken)
	-- sanity checks
	if (not unitToken or issecretvalue(unitToken)) then
		-- failed
		return nil
	end

	-- success
	return UnitInRaid(unitToken)
end

-- unit in vehicle
function NS:UnitInVehicle(unitToken)
	-- sanity checks
	if (not unitToken or issecretvalue(unitToken)) then
		-- failed
		return nil
	end

	-- success
	return UnitInVehicle(unitToken)
end

-- unit is connected
function NS:UnitIsConnected(unitId)
	-- sanity checks
	if (not unitId or issecretvalue(unitId)) then
		-- failed
		return nil
	end

	-- success
	return UnitIsConnected(unitId)
end

-- unit is dead or ghost
function NS:UnitIsDeadOrGhost(unitToken)
	-- sanity checks
	if (not unitToken or issecretvalue(unitToken)) then
		-- failed
		return nil
	end

	-- success
	return UnitIsDeadOrGhost(unitToken)
end

-- unit is group leader
function NS:UnitIsGroupLeader(unitId, ...)
	-- sanity checks
	if (not unitId or issecretvalue(unitId)) then
		-- failed
		return nil
	end

	-- success
	return UnitIsGroupLeader(unitId, ...)
end

-- unit is player
function NS:UnitIsPlayer(unitToken)
	-- sanity checks
	if (not unitToken or issecretvalue(unitToken)) then
		-- failed
		return nil
	end

	-- success
	return UnitIsPlayer(unitToken)
end

-- unit level
function NS:UnitLevel(unitId)
	-- sanity checks
	if (not unitId or issecretvalue(unitId)) then
		-- failed
		return nil
	end

	-- success
	return UnitLevel(unitId)
end

-- unit realm relationship
function NS:UnitRealmRelationship(unitToken)
	-- sanity checks
	if (not unitToken or issecretvalue(unitToken)) then
		-- failed
		return nil
	end

	-- success
	return UnitRealmRelationship(unitToken)
end

----------------------------------------------------------------------------------------------------------
-- C_AreaPoiInfo
----------------------------------------------------------------------------------------------------------

-- get area poi for map
function NS:GetAreaPOIForMap(uiMapID)
	-- sanity checks
	if (not uiMapID or issecretvalue(uiMapID)) then
		-- failed
		return nil
	end

	-- success
	return GetAreaPOIForMap(uiMapID)
end

-- get area poi info
function NS:GetAreaPOIInfo(uiMapID, areaPoiID)
	-- sanity checks
	if (not uiMapID or not areaPoiID or issecretvalue(uiMapID) or issecretvalue(areaPoiID)) then
		-- failed
		return nil
	end

	-- success
	return GetAreaPOIInfo(uiMapID, areaPoiID)
end

----------------------------------------------------------------------------------------------------------
-- C_BattleNet
----------------------------------------------------------------------------------------------------------

-- get account info by guid
function NS:GetAccountInfoByGUID(unitGUID)
	-- sanity checks
	if (not unitGUID or issecretvalue(unitGUID)) then
		-- failed
		return nil
	end

	-- success
	return GetAccountInfoByGUID(unitGUID)
end

-- get friend account info
function NS:GetFriendAccountInfo(friendIndex)
	-- sanity checks
	if (not friendIndex or issecretvalue(friendIndex)) then
		-- failed
		return nil
	end

	-- success
	return GetFriendAccountInfo(friendIndex)
end

-- get friend game account info
function NS:GetFriendGameAccountInfo(friendIndex, accountIndex)
	-- sanity checks
	if (not friendIndex or not accountIndex or issecretvalue(friendIndex) or issecretvalue(accountIndex)) then
		-- failed
		return nil
	end

	-- success
	return GetFriendGameAccountInfo(friendIndex, accountIndex)
end

-- get friend num game accounts
function NS:GetFriendNumGameAccounts(friendIndex)
	-- sanity checks
	if (not friendIndex or issecretvalue(friendIndex)) then
		-- failed
		return nil
	end

	-- success
	return GetFriendNumGameAccounts(friendIndex)
end

----------------------------------------------------------------------------------------------------------
-- C_Club
----------------------------------------------------------------------------------------------------------

-- are members ready
function NS:AreMembersReady(clubId)
	-- sanity checks
	if (not clubId or issecretvalue(clubId)) then
		-- failed
		return nil
	end

	-- success
	return AreMembersReady(clubId)
end

-- get club info
function NS:GetClubInfo(clubId)
	-- in chat messaging lockdown?
	if (InChatMessagingLockdown()) then
		-- finished
		return nil
	end

	-- sanity checks
	if (not clubId or issecretvalue(clubId)) then
		-- failed
		return nil
	end

	-- success
	return GetClubInfo(clubId)
end

-- get club members
function NS:GetClubMembers(clubId)
	-- in chat messaging lockdown?
	if (InChatMessagingLockdown()) then
		-- finished
		return nil
	end

	-- sanity checks
	if (not clubId or issecretvalue(clubId)) then
		-- failed
		return nil
	end

	-- success
	return GetClubMembers(clubId)
end

-- focus members
function NS:FocusMembers(clubId)
	-- sanity checks
	if (not clubId or issecretvalue(clubId)) then
		-- failed
		return nil
	end

	-- success
	return FocusMembers(clubId)
end

-- get member info
function NS:GetMemberInfo(clubId, memberId)
	-- in chat messaging lockdown?
	if (InChatMessagingLockdown()) then
		-- finished
		return nil
	end

	-- sanity checks
	if (not clubId or not memberId or issecretvalue(clubId) or issecretvalue(memberId)) then
		-- failed
		return nil
	end

	-- success
	return GetMemberInfo(clubId, memberId)
end

-- get subscribed clubs
function NS:GetSubscribedClubs()
	-- in chat messaging lockdown?
	if (InChatMessagingLockdown()) then
		-- finished
		return nil
	end

	-- success
	return GetSubscribedClubs()
end

-- get stream info
function NS:GetStreamInfo(clubId, streamId)
	-- in chat messaging lockdown?
	if (InChatMessagingLockdown()) then
		-- finished
		return nil
	end

	-- sanity checks
	if (not clubId or not streamId or issecretvalue(clubId) or issecretvalue(streamId)) then
		-- failed
		return nil
	end

	-- success
	return GetStreamInfo(clubId, streamId)
end

-- get streams
function NS:GetStreams(clubId)
	-- in chat messaging lockdown?
	if (InChatMessagingLockdown()) then
		-- finished
		return nil
	end

	-- sanity checks
	if (not clubId or issecretvalue(clubId)) then
		-- failed
		return nil
	end

	-- success
	return GetStreams(clubId)
end

----------------------------------------------------------------------------------------------------------
-- C_ClubFinder
----------------------------------------------------------------------------------------------------------

-- return club applicant list
function NS:ReturnClubApplicantList(clubId)
	-- sanity checks
	if (not clubId or issecretvalue(clubId)) then
		-- failed
		return nil
	end

	-- success
	return ReturnClubApplicantList(clubId)
end

----------------------------------------------------------------------------------------------------------
-- C_CreatureInfo
----------------------------------------------------------------------------------------------------------

-- get faction info
function NS:GetFactionInfo(raceID)
	-- sanity checks
	if (not raceID or issecretvalue(raceID)) then
		-- failed
		return nil
	end

	-- success
	return GetFactionInfo(raceID)
end

----------------------------------------------------------------------------------------------------------
-- C_CurrencyInfo
----------------------------------------------------------------------------------------------------------

-- get currency info
function NS:GetCurrencyInfo(currencyID)
	-- sanity checks
	if (not currencyID or issecretvalue(currencyID)) then
		-- failed
		return nil
	end

	-- success
	return GetCurrencyInfo(currencyID)
end

----------------------------------------------------------------------------------------------------------
-- C_DelvesUI
----------------------------------------------------------------------------------------------------------

-- has active delve
function NS:HasActiveDelve(mapID)
	-- sanity checks
	if (not mapID or issecretvalue(mapID)) then
		-- failed
		return nil
	end

	-- success
	return HasActiveDelve(mapID)
end

----------------------------------------------------------------------------------------------------------
-- C_EquipmentSet
----------------------------------------------------------------------------------------------------------

-- get equipment set info
function NS:GetEquipmentSetInfo(equipmentSetID)
	-- sanity checks
	if (not equipmentSetID or issecretvalue(equipmentSetID)) then
		-- failed
		return nil
	end

	-- success
	return GetEquipmentSetInfo(equipmentSetID)
end

-- use equipment set
function NS:UseEquipmentSet(equipmentSetID)
	-- sanity checks
	if (not equipmentSetID or issecretvalue(equipmentSetID)) then
		-- failed
		return nil
	end

	-- success
	return UseEquipmentSet(equipmentSetID)
end

----------------------------------------------------------------------------------------------------------
-- C_Item
----------------------------------------------------------------------------------------------------------

-- get item count
function NS:GetItemCount(itemInfo, ...)
	-- sanity checks
	if (not itemInfo or issecretvalue(itemInfo)) then
		-- failed
		return nil
	end

	-- success
	return GetItemCount(itemInfo, ...)
end

----------------------------------------------------------------------------------------------------------
-- C_LFGInfo
----------------------------------------------------------------------------------------------------------

-- get all entries for category
function NS:GetAllEntriesForCategory(category)
	-- sanity checks
	if (not category or issecretvalue(category)) then
		-- failed
		return nil
	end

	-- success
	return GetAllEntriesForCategory(category)
end

-- hide name from ui
function NS:HideNameFromUI(dungeonID)
	-- sanity checks
	if (not dungeonID or issecretvalue(dungeonID)) then
		-- failed
		return nil
	end

	-- success
	return HideNameFromUI(dungeonID)
end

----------------------------------------------------------------------------------------------------------
-- C_Map
----------------------------------------------------------------------------------------------------------

-- get best map for unit
function NS:GetBestMapForUnit(unitToken)
	-- sanity checks
	if (not unitToken or issecretvalue(unitToken)) then
		-- failed
		return nil
	end

	-- success
	return GetBestMapForUnit(unitToken)
end

-- get map info
function NS:GetMapInfo(uiMapID)
	-- sanity checks
	if (not uiMapID or issecretvalue(uiMapID)) then
		-- failed
		return nil
	end

	-- success
	return GetMapInfo(uiMapID)
end

-- can set user waypoint on map
function NS:CanSetUserWaypointOnMap(uiMapID)
	-- sanity checks
	if (not uiMapID or issecretvalue(uiMapID)) then
		-- failed
		return nil
	end

	-- success
	return CanSetUserWaypointOnMap(uiMapID)
end

-- set user waypoint
function NS:SetUserWaypoint(point)
	-- sanity checks
	if (not point or issecretvalue(point)) then
		-- failed
		return nil
	end

	-- success
	return SetUserWaypoint(point)
end

----------------------------------------------------------------------------------------------------------
-- C_Minimap
----------------------------------------------------------------------------------------------------------

-- get poi texture coords
function NS:GetPOITextureCoords(index)
	-- sanity checks
	if (issecretvalue(index)) then
		-- failed
		return nil
	end

	-- success
	return GetPOITextureCoords(index)
end

----------------------------------------------------------------------------------------------------------
-- C_PartyInfo
----------------------------------------------------------------------------------------------------------

-- get invite referral info
function NS:GetInviteReferralInfo(inviteGUID)
	-- sanity checks
	if (not inviteGUID or issecretvalue(inviteGUID)) then
		-- failed
		return nil
	end

	-- success
	return GetInviteReferralInfo(inviteGUID)
end

-- invite unit
function NS:InviteUnit(name)
	-- sanity checks
	if (not name or issecretvalue(name)) then
		-- failed
		return nil
	end

	-- success
	return InviteUnit(name)
end

-- is party full
function NS:IsPartyFull(category)
	-- sanity checks
	if (issecretvalue(category)) then
		-- failed
		return nil
	end

	-- success
	return IsPartyFull(category)
end

-- leave party
function NS:LeaveParty(category)
	-- sanity checks
	if (issecretvalue(category)) then
		-- failed
		return nil
	end

	-- success
	return LeaveParty(category)
end

-- set restrict pings
function NS:SetRestrictPings(restrictTo)
	-- sanity checks
	if (not restrictTo or issecretvalue(restrictTo)) then
		-- failed
		return nil
	end

	-- success
	return SetRestrictPings(restrictTo)
end

----------------------------------------------------------------------------------------------------------
-- C_PlayerInfo
----------------------------------------------------------------------------------------------------------

-- player info get race
function NS:PlayerInfoGetRace(playerLocation)
	-- sanity checks
	if (not playerLocation or issecretvalue(playerLocation)) then
		-- failed
		return nil
	end

	-- success
	return PlayerInfoGetRace(playerLocation)
end

----------------------------------------------------------------------------------------------------------
-- C_PvP
----------------------------------------------------------------------------------------------------------

-- get battlefield vehicles
function NS:GetBattlefieldVehicles(uiMapID)
	-- sanity checks
	if (not uiMapID or issecretvalue(uiMapID)) then
		-- failed
		return nil
	end

	-- success
	return GetBattlefieldVehicles(uiMapID)
end

-- get battleground info
function NS:GetBattlegroundInfo(battlegroundIndex)
	-- sanity checks
	if (not battlegroundIndex or issecretvalue(battlegroundIndex)) then
		-- failed
		return nil
	end

	-- success
	return GetBattlegroundInfo(battlegroundIndex)
end

-- get score info
function NS:GetScoreInfo(offsetIndex)
	-- sanity checks
	if (not offsetIndex or issecretvalue(offsetIndex)) then
		-- failed
		return nil
	end

	-- success
	return GetScoreInfo(offsetIndex)
end

-- get score info by player guid
function NS:GetScoreInfoByPlayerGuid(guid)
	-- sanity checks
	if (not guid or issecretvalue(guid)) then
		-- failed
		return nil
	end

	-- success
	return GetScoreInfoByPlayerGuid(guid)
end

----------------------------------------------------------------------------------------------------------
-- C_SocialQueue
----------------------------------------------------------------------------------------------------------

-- get group for player
function NS:GetGroupForPlayer(playerGUID)
	-- sanity checks
	if (not playerGUID or issecretvalue(playerGUID)) then
		-- failed
		return nil
	end

	-- success
	return GetGroupForPlayer(playerGUID)
end

-- get group info
function NS:GetGroupInfo(groupGUID)
	-- sanity checks
	if (not groupGUID or issecretvalue(groupGUID)) then
		-- failed
		return nil
	end

	-- success
	return GetGroupInfo(groupGUID)
end

-- get group members
function NS:GetGroupMembers(groupGUID)
	-- sanity checks
	if (not groupGUID or issecretvalue(groupGUID)) then
		-- failed
		return nil
	end

	-- success
	return GetGroupMembers(groupGUID)
end

-- get group queues
function NS:GetGroupQueues(groupGUID)
	-- sanity checks
	if (not groupGUID or issecretvalue(groupGUID)) then
		-- failed
		return nil
	end

	-- success
	return GetGroupQueues(groupGUID)
end

----------------------------------------------------------------------------------------------------------
-- C_SuperTrack
----------------------------------------------------------------------------------------------------------

-- set super tracked user waypoint
function NS:SetSuperTrackedUserWaypoint(superTracked)
	-- sanity checks
	if (not superTracked or issecretvalue(superTracked)) then
		-- failed
		return nil
	end

	-- success
	return SetSuperTrackedUserWaypoint(superTracked)
end

----------------------------------------------------------------------------------------------------------
-- C_Traits
----------------------------------------------------------------------------------------------------------

-- generate import string
function NS:GenerateImportString(configID)
	-- sanity checks
	if (not configID or issecretvalue(configID)) then
		-- failed
		return nil
	end

	-- success
	return GenerateImportString(configID)
end

-- get config id by tree id
function NS:GetConfigIDByTreeID(treeID)
	-- sanity checks
	if (not treeID or issecretvalue(treeID)) then
		-- failed
		return nil
	end

	-- success
	return GetConfigIDByTreeID(treeID)
end

-- get tree currency info
function NS:GetTreeCurrencyInfo(configID, treeID, excludeStagedChanges)
	-- sanity checks
	if (not configID or not treeID or not excludeStagedChanges or issecretvalue(configID) or issecretvalue(treeID) or issecretvalue(excludeStagedChanges)) then
		-- failed
		return nil
	end

	-- success
	return GetTreeCurrencyInfo(configID, treeID, excludeStagedChanges)
end

----------------------------------------------------------------------------------------------------------
-- C_UnitAuras
----------------------------------------------------------------------------------------------------------

-- get unit auras
function NS:GetUnitAuras(unit, filter, ...)
	-- sanity checks
	if (not unit or not filter or issecretvalue(unit) or issecretvalue(filter)) then
		-- failed
		return nil
	end

	-- success
	return GetUnitAuras(unit, filter, ...)
end


----------------------------------------------------------------------------------------------------------
-- C_VignetteInfo
----------------------------------------------------------------------------------------------------------

-- get vignette info
function NS:GetVignetteInfo(vignetteGUID)
	-- sanity checks
	if (not vignetteGUID or issecretvalue(vignetteGUID)) then
		-- failed
		return nil
	end

	-- success
	return GetVignetteInfo(vignetteGUID)
end

-- get vignette position
function NS:GetVignettePosition(vignetteGUID, uiMapID)
	-- sanity checks
	if (not vignetteGUID or not uiMapID or issecretvalue(vignetteGUID) or issecretvalue(uiMapID)) then
		-- failed
		return nil
	end

	-- success
	return GetVignettePosition(vignetteGUID, uiMapID)
end

-- send to party, whisper, or Battle.NET message
function NS:SendMessage(sender, msg, channel)
	-- in chat messaging lockdown?
	if (InChatMessagingLockdown()) then
		-- finished
		return
	end

	-- sanity checks
	if (not sender or not msg or issecretvalue(sender) or issecretvalue(msg) or issecretvalue(channel)) then
		-- failed
		return nil
	end

	-- string?
	if (type(sender) == "string") then
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
		SendWhisper(sender, msg)
	end
end
