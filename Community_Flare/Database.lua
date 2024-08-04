local ADDON_NAME, NS = ...

-- get locale
assert(NS.Libs)
local L = NS.Libs.AceLocale:GetLocale(ADDON_NAME)
if (not L) then
	-- finished
	return
end

-- localize stuff
local _G                                        = _G
local GetPlayerInfoByGUID                       = _G.GetPlayerInfoByGUID
local UnitFactionGroup                          = _G.UnitFactionGroup
local ClubGetClubInfo                           = _G.C_Club.GetClubInfo
local ClubGetClubMembers                        = _G.C_Club.GetClubMembers
local ClubGetMemberInfo                         = _G.C_Club.GetMemberInfo
local ClubGetSubscribedClubs                    = _G.C_Club.GetSubscribedClubs
local TimerAfter                                = _G.C_Timer.After
local date                                      = _G.date
local ipairs                                    = _G.ipairs
local next                                      = _G.next
local pairs                                     = _G.pairs
local print                                     = _G.print
local select                                    = _G.select
local time                                      = _G.time
local tonumber                                  = _G.tonumber
local tostring                                  = _G.tostring
local type                                      = _G.type
local wipe                                      = _G.wipe
local strformat                                 = _G.string.format
local strgsub                                   = _G.string.gsub
local strmatch                                  = _G.string.match
local strsplit                                  = _G.string.split
local tinsert                                   = _G.table.insert
local tsort                                     = _G.table.sort

-- get clubs
function NS.CommunityFlare_Get_Clubs()
	-- count eligible communities
	local text = nil
	local player_faction = UnitFactionGroup("player")
	NS.CommFlare.CF.Clubs = ClubGetSubscribedClubs()
	for k,v in ipairs(NS.CommFlare.CF.Clubs) do
		-- community?
		if (v.clubType == Enum.ClubType.Character) then
			-- not cross faction?
			local faction = nil
			if (v.crossFaction == false) then
				-- assume same faction as player with club
				faction = player_faction
			end
	
			-- first?
			local current = strformat("%s,%s,%s,%s,%s,%s", tostring(v.clubId), tostring(v.name), tostring(v.shortName), tostring(v.memberCount), tostring(v.crossFaction), tostring(faction))
			if (not text) then
				-- initialize
				text = current
			else
				-- append
				text = strformat("%s;%s", text, current)
			end
		end 
	end

	-- return text
	return text
end

-- verify default community setup
function NS.CommunityFlare_VerifyDefaultCommunitySetup()
	-- default not set?
	local count = 0
	if (NS.charDB.profile.communityMain == 0) then
		-- count eligible communities
		local clubId = nil
		NS.CommFlare.CF.Clubs = ClubGetSubscribedClubs()
		for k,v in ipairs(NS.CommFlare.CF.Clubs) do
			-- community?
			if (v.clubType == Enum.ClubType.Character) then
				-- save clubId
				clubId = v.clubId

				-- increase
				count = count + 1
			end 
		end

		-- none found?
		if (count == 0) then
			-- initialized as none?
			if (not NS.charDB.profile.communityMain or (NS.charDB.profile.communityMain == 0)) then
				-- force 1 for none
				NS.charDB.profile.communityMain = 1

				-- first time verifying?
				if (NS.CommFlare.CF.DefaultVerified == false) then
					-- default verified
					NS.CommFlare.CF.DefaultVerified = true

					-- display message
					print(strformat(L["%s: No subscribed clubs found."], NS.CommunityFlare_Title))
				end
			end
		-- only one found?
		elseif (count == 1) then
			-- setup stuff
			NS.charDB.profile.communityList = {}
			NS.charDB.profile.communityMain = clubId

			-- remove all members
			NS.CommunityFlare_RemoveAllClubMembersByClubID(clubId)

			-- add all members
			NS.CommunityFlare_AddAllClubMembersByClubID(clubId)

			-- set default report ID
			NS.charDB.profile.communityReportID = clubId

			-- readd community chat window
			NS.CommunityFlare_ReaddCommunityChatWindow(NS.charDB.profile.communityReportID, 1)

			-- save refresh date
			NS.charDB.profile.communityRefreshed = time()
		end
	end

	-- return count
	return count
end

-- verify report channel added
function NS.CommunityFlare_VerifyReportChannelAdded()
	-- has report ID?
	if (NS.charDB.profile.communityReportID > 1) then
		-- verify channel is added for proper reporting
		local channel, chatFrameID = Chat_GetCommunitiesChannel(NS.charDB.profile.communityReportID, 1)
		if (not channel or not chatFrameID) then
			-- readd community chat window
			NS.CommunityFlare_ReaddCommunityChatWindow(NS.charDB.profile.communityReportID, 1)
		end
	end
end

-- get club list
function NS.CommunityFlare_GetClubsList()
	-- find main community club
	local count = 0
	local clubs = {}
	local clubId = NS.charDB.profile.communityMain
	if (clubId > 1) then
		-- not still in main community?
		local info = ClubGetClubInfo(clubId)
		if (not info) then
			-- invalid club
			NS.charDB.profile.communityMain = 0
		-- club type is not a community?
		elseif (info and (info.clubType ~= Enum.ClubType.Character)) then
			-- invalid club
			NS.charDB.profile.communityMain = 0
		-- valid community still found!
		else
			-- main community not set?
			if (NS.charDB.profile.communityMain and (NS.charDB.profile.communityMain == 0)) then
				-- update community main
				NS.charDB.profile.communityMain = clubId
			end

			-- add club id
			tinsert(clubs, clubId)
			count = count + 1
		end
	end

	-- has community list?
	if (NS.charDB.profile.communityList and (next(NS.charDB.profile.communityList) ~= nil)) then
		-- process all lists
		for k,_ in pairs(NS.charDB.profile.communityList) do
			-- add club id
			tinsert(clubs, k)
			count = count + 1
		end
	end

	-- none found?
	if (count == 0) then
		-- none
		return nil
	end

	-- return found clubs
	return clubs
end

-- is community leader?
function NS.CommunityFlare_IsCommunityLeader(name)
	-- invalid name?
	local player = name
	if (not player or (player == "")) then
		-- failed
		return false
	end

	-- build proper name
	if (not strmatch(player, "-")) then
		-- add realm name
		player = player .. "-" .. NS.CommFlare.CF.PlayerServerName
	end

	-- process all leaders
	for _,v in ipairs(NS.CommFlare.CF.CommunityLeaders) do
		-- matches?
		if (player == v) then
			-- success
			return true
		end
	end

	-- failed
	return false
end

-- get community member
function NS.CommunityFlare_GetCommunityMember(name)
	-- invalid name?
	local player = name
	if (not player or (player == "")) then
		-- failed
		return nil
	end

	-- build proper name
	if (not strmatch(player, "-")) then
		-- add realm name
		player = player .. "-" .. NS.CommFlare.CF.PlayerServerName
	end

	-- check inside database first
	if (player and (player ~= "") and NS.globalDB.global and NS.globalDB.global.members and NS.globalDB.global.members[player]) then
		-- success
		return NS.globalDB.global.members[player]
	end

	-- failed
	return nil
end

-- get loglist status
function NS.CommunityFlare_Get_LogList_Status(player)
	-- invalid name?
	if (not player or (player == "")) then
		-- failed
		return false
	end

	-- build proper name
	if (not strmatch(player, "-")) then
		-- add realm name
		player = player .. "-" .. NS.CommFlare.CF.PlayerServerName
	end

	-- check inside database first
	if (player and (player ~= "") and NS.globalDB.global and NS.globalDB.global.members and NS.globalDB.global.members[player]) then
		-- not setup yet?
		if (not NS.charDB.profile.communityLogList) then
			-- initialize
			NS.charDB.profile.communityLogList = {}
		end

		-- process clubs
		for k,v in pairs(NS.globalDB.global.members[player].clubs) do
			-- log list enabled?
			if (NS.charDB.profile.communityLogList[k] == true) then
				-- success
				return true
			end
		end
	end

	-- failed
	return false
end

-- clean up members
function NS.CommunityFlare_CleanUpMembers()
	-- process all members
	for k,v in pairs(NS.globalDB.global.members) do
		-- has space?
		if (strmatch(k, " ")) then
			-- fix player in database
			local player = strgsub(k, "%s+", "")
			NS.globalDB.global.members[player] = v
			NS.globalDB.global.members[player].name = player
			NS.globalDB.global.members[k] = nil
			print(strformat(L["Moved: %s to %s"], k, player))
		end
	end

	-- process all members
	local removed = 0
	for k,v in pairs(NS.globalDB.global.members) do
		-- check for leader / owner
		local player = v.name
		for k2,v2 in pairs(NS.globalDB.global.members[player].clubs) do
			-- owner?
			if (v2.role == Enum.ClubRoleIdentifier.Owner) then
				-- leader
				NS.globalDB.global.members[player].owner = true
				v.owner = true
			-- leader?
			elseif (v2.role == Enum.ClubRoleIdentifier.Leader) then
				-- leader
				NS.globalDB.global.members[player].leader = true
				v.leader = true
			-- moderator?
			elseif (v2.role == Enum.ClubRoleIdentifier.Moderator) then
				-- leader
				NS.globalDB.global.members[player].moderator = true
				v.moderator = true
			end

			-- still has id?
			if (NS.globalDB.global.members[player].clubs[k2].id) then
				-- delete id
				NS.globalDB.global.members[player].clubs[k2].id = nil
			end
		end

		-- not leader or owner?
		if ((not v.leader or (v.leader == false)) and (not v.owner or (v.owner == false)) and (not v.moderator or (v.moderator == false))) then
			-- reset priority
			NS.globalDB.global.members[player].priority = NS.CommFlare.CF.MaxPriority
		end

		-- has added?
		if (v.added) then
			-- delete added
			NS.globalDB.global.members[player].added = nil
		end

		-- has updated?
		if (v.updated) then
			-- delete updated
			NS.globalDB.global.members[player].updated = nil
		end

		-- has lastgrouped?
		if (v.lastgrouped) then
			-- move to history
			NS.globalDB.global.history[player].lastgrouped = v.lastgrouped
			NS.globalDB.global.members[player].lastgrouped = nil
		end
	end
end

-- check for deployed players
function NS.CommunityFlare_Check_For_Deployed_Players()
	-- get clubs
	local clubs = NS.CommunityFlare_GetClubsList()
	if (clubs) then
		-- process all clubs
		local deployed_count = 0
		for _,clubId in ipairs(clubs) do
			-- process all members
			local count = 0
			local deployed = {}
			local club = ClubGetClubInfo(clubId)
			local members = ClubGetClubMembers(clubId)
			for _,v in ipairs(members) do
				local mi = ClubGetMemberInfo(clubId, v)
				if ((mi ~= nil) and (mi.name ~= nil)) then
					-- online?
					if (mi.presence == Enum.ClubMemberPresence.Online) then
						-- is tracked pvp?
						local isTracked, isEpicBattleground, isRandomBattleground, isBrawl = NS.CommunityFlare_IsTrackedPVP(mi.zone)
						if (isTracked == true) then
							-- not initialized?
							if (not deployed[mi.zone]) then
								-- initialize
								deployed[mi.zone] = 0
							end

							-- increase
							deployed[mi.zone] = deployed[mi.zone] + 1
							count = count + 1
						end
					end
				end
			end

			-- any deployed?
			if (deployed and next(deployed)) then
				-- process all deployed
				print(strformat(L["%s: %s Deployed Members."], NS.CommunityFlare_Title, club.name))
				for k,v in pairs(deployed) do
					-- display result
					print(strformat(L["-%s = %d member/s"], k, v))
				end

				-- increase
				deployed_count = deployed_count + 1
			else
				-- display message
				print(strformat(L["%s: No members are deployed for %s."], NS.CommunityFlare_Title, club.name))
			end
		end

		-- noone deployed?
		if (deployed_count == 0) then
			-- display message
			print(strformat(L["%s: No members are deployed."], NS.CommunityFlare_Title))
		end
	else
		-- display message
		print(strformat(L["%s: No subscribed clubs found."], NS.CommunityFlare_Title))
	end
end

-- rebuild community leaders
function NS.CommunityFlare_RebuildCommunityLeaders()
	-- not initialized?
	if (not NS.charDB.profile.communityLeadersList) then
		-- initialize
		NS.charDB.profile.communityLeadersList = {}
	end

	-- has community leaders list?
	local numLeaders = 0
	for k,v in pairs(NS.charDB.profile.communityLeadersList) do
		-- enabled?
		if (v == true) then
			-- increase
			numLeaders = numLeaders + 1
		end
	end

	-- process all
	local count = 1
	local orderedList = {}
	local orderedLeaders = {}
	local unorderedLeaders = {}
	local orderedModerators = {}
	local unorderedModerators = {}
	NS.CommFlare.CF.CommunityLeaders = {}
	for k,v in pairs(NS.globalDB.global.members) do
		-- owner?
		if (v.owner) then
			-- always verify leader status
			local player = v.name
			local sharesLeaderCommunity = false
			NS.globalDB.global.members[player].owner = nil
			for k2,v2 in pairs(NS.globalDB.global.members[player].clubs) do
				-- owner?
				if (v2.role == Enum.ClubRoleIdentifier.Owner) then
					-- has community leaders list?
					if (numLeaders > 0) then
						-- has community from leaders list?
						if (NS.charDB.profile.communityLeadersList[k2] == true) then
							-- shares leader community
							sharesLeaderCommunity = true
						end
					end

					-- owner
					NS.globalDB.global.members[player].owner = true
				end
			end

			-- currently has owner role somewhere?
			if (NS.globalDB.global.members[player].owner == true) then
				-- has community leaders list?
				local allowed = true
				if (numLeaders > 0) then
					-- no shared leader community?
					if (sharesLeaderCommunity == false) then
						-- not allowed
						allowed = false
					end
				end

				-- allowed?
				if (allowed == true) then
					-- add first
					NS.CommFlare.CF.CommunityLeaders[count] = v.name

					-- next
					count = count + 1
				end
			end
		-- leader?
		elseif (v.leader) then
			-- always verify leader status
			local player = v.name
			local sharesLeaderCommunity = false
			NS.globalDB.global.members[player].leader = nil
			for k2,v2 in pairs(NS.globalDB.global.members[player].clubs) do
				-- leader?
				if (v2.role == Enum.ClubRoleIdentifier.Leader) then
					-- has community leaders list?
					if (numLeaders > 0) then
						-- has community from leaders list?
						if (NS.charDB.profile.communityLeadersList[k2] == true) then
							-- shares leader community
							sharesLeaderCommunity = true
						end
					end

					-- leader
					NS.globalDB.global.members[player].leader = true
				end
			end

			-- currently has leader role somewhere?
			if (NS.globalDB.global.members[player].leader == true) then
				-- has community leaders list?
				local allowed = true
				if (numLeaders > 0) then
					-- no shared leader community?
					if (sharesLeaderCommunity ~= true) then
						-- not allowed
						allowed = false
					end
				end

				-- allowed?
				if (allowed == true) then
					-- has priority?
					if (v.priority and (v.priority > 0) and (v.priority < NS.CommFlare.CF.MaxPriority)) then
						-- not created?
						if (not orderedLeaders[v.priority]) then
							-- create table
							orderedLeaders[v.priority] = {}
						end

						-- add to ordered leaders
						tinsert(orderedLeaders[v.priority], v.name)
					else
						-- add to unordered leaders
						tinsert(unorderedLeaders, v.name)
					end
				end
			end
		-- moderator?
		elseif (v.moderator) then
			-- always verify leader status
			local player = v.name
			local sharesLeaderCommunity = false
			NS.globalDB.global.members[player].moderator = nil
			for k2,v2 in pairs(NS.globalDB.global.members[player].clubs) do
				-- moderator?
				if (v2.role == Enum.ClubRoleIdentifier.Moderator) then
					-- has community leaders list?
					if (numLeaders > 0) then
						-- has community from leaders list?
						if (NS.charDB.profile.communityLeadersList[k2] == true) then
							-- shares leader community
							sharesLeaderCommunity = true
						end
					end

					-- moderator
					NS.globalDB.global.members[player].moderator = true
				end
			end

			-- currently has moderator role somewhere?
			if (NS.globalDB.global.members[player].moderator == true) then
				-- has community leaders list?
				local allowed = true
				if (numLeaders > 0) then
					-- no shared leader community?
					if (sharesLeaderCommunity ~= true) then
						-- not allowed
						allowed = false
					end
				end

				-- allowed?
				if (allowed == true) then
					-- has priority?
					if (v.priority and (v.priority > 0) and (v.priority < NS.CommFlare.CF.MaxPriority)) then
						-- not created?
						if (not orderedModerators[v.priority]) then
							-- create table
							orderedModerators[v.priority] = {}
						end

						-- add to ordered moderators
						tinsert(orderedModerators[v.priority], v.name)
					else
						-- add to unordered moderators
						tinsert(unorderedModerators, v.name)
					end	
				end
			end
		end
	end

	-- build proper order list
	for k,v in pairs(orderedLeaders) do
		tinsert(orderedList, k)
		tsort(orderedLeaders[k])
	end

	-- add ordered leaders in proper list order
	tsort(orderedList)
	for k,v in ipairs(orderedList) do
		-- add all found ordered leaders
		for k2,v2 in pairs(orderedLeaders[v]) do
			-- add leader
			NS.CommFlare.CF.CommunityLeaders[count] = v2

			-- next
			count = count + 1
		end
	end
	wipe(orderedList)
	wipe(orderedLeaders)

	-- process unordered leaders
	tsort(unorderedLeaders)
	for k,v in pairs(unorderedLeaders) do
		-- add leader
		NS.CommFlare.CF.CommunityLeaders[count] = v

		-- next
		count = count + 1
	end
	wipe(unorderedLeaders)

	-- build proper order list
	for k,v in pairs(orderedModerators) do
		tinsert(orderedList, k)
		tsort(orderedModerators[k])
	end

	-- add ordered moderators in proper list order
	tsort(orderedList)
	for k,v in ipairs(orderedList) do
		-- add all found ordered leaders
		for k2,v2 in pairs(orderedModerators[v]) do
			-- add leader
			NS.CommFlare.CF.CommunityLeaders[count] = v2

			-- next
			count = count + 1
		end
	end
	wipe(orderedList)
	wipe(orderedModerators)

	-- process unordered moderators
	tsort(unorderedModerators)
	for k,v in pairs(unorderedModerators) do
		-- add leader
		NS.CommFlare.CF.CommunityLeaders[count] = v

		-- next
		count = count + 1
	end
	wipe(unorderedModerators)
end

-- get priority from member note
function NS.CommunityFlare_GetMemberPriority(info)
	-- leader / moderator rank?
	if ((info.role == Enum.ClubRoleIdentifier.Leader) or (info.role == Enum.ClubRoleIdentifier.Moderator)) then
		-- has member note?
		if (info.memberNote and (info.memberNote ~= "")) then
			-- find priority [ start
			local left, right = strsplit("[", info.memberNote)
			if (right and right:find("]")) then
				local priority = strsplit("]", right)
				if (priority and (type(priority) == "string")) then
					-- return number
					priority = tonumber(priority)
					return priority
				end
			end
		end
	-- owner rank?
	elseif (info.role == Enum.ClubRoleIdentifier.Owner) then
		-- always 1st priority
		return 1
	end

	-- none
	return NS.CommFlare.CF.MaxPriority
end

-- add community
function NS.CommunityFlare_AddCommunity(clubId, info)
	-- add to clubs
	NS.globalDB.global.clubs[clubId] = info

	-- not cross faction?
	if (info.crossFaction == false) then
		-- assume same faction as player with club
		NS.globalDB.global.clubs[clubId].faction = UnitFactionGroup("player")
	end
end

-- add member
function NS.CommunityFlare_AddMember(clubId, info, rebuild)
	-- build proper name
	local player = info.name
	if (not strmatch(player, "-")) then
		-- add realm name
		player = player .. "-" .. NS.CommFlare.CF.PlayerServerName
	end

	-- sanity check
	local name, server = strsplit("-", player)
	if (not name or (name == "") or not server or (server == "")) then
		-- failed
		return
	end

	-- member exists?
	local priority = NS.CommunityFlare_GetMemberPriority(info)
	if (NS.globalDB.global.members[player]) then
		-- remove old fields
		NS.globalDB.global.members[player].role = nil
		NS.globalDB.global.members[player].clubId = nil
		NS.globalDB.global.members[player].memberNote = nil

		-- guid updated?
		if (not NS.globalDB.global.members[player].guid or (NS.globalDB.global.members[player].guid ~= info.guid)) then
			-- update guid
			NS.globalDB.global.members[player].guid = info.guid
		end

		-- class updated?
		if (not NS.globalDB.global.members[player].classID or (NS.globalDB.global.members[player].classID ~= info.classID)) then
			-- update class
			NS.globalDB.global.members[player].classID = info.classID
		end

		-- race updated?
		if (not NS.globalDB.global.members[player].race or (NS.globalDB.global.members[player].race ~= info.race)) then
			-- update race
			NS.globalDB.global.members[player].race = info.race
		end

		-- faction updated?
		if (not NS.globalDB.global.members[player].faction or (NS.globalDB.global.members[player].faction ~= info.faction)) then
			-- update faction
			NS.globalDB.global.members[player].faction = info.faction
		end

		-- always has some priority number?
		if (not NS.globalDB.global.members[player].priority) then
			-- set max
			NS.globalDB.global.members[player].priority = NS.CommFlare.CF.MaxPriority
		end

		-- empty?
		if (not NS.globalDB.global.members[player].clubs) then
			-- initialize
			NS.globalDB.global.members[player].clubs = {}
		end
		if (not NS.globalDB.global.members[player].clubs[clubId]) then
			-- initialize
			NS.globalDB.global.members[player].clubs[clubId] = {}
		end

		-- has clubs loaded?
		if (NS.globalDB.global.members[player].clubs and NS.globalDB.global.members[player].clubs[clubId]) then
			-- role updated?
			if (not NS.globalDB.global.members[player].clubs[clubId].role or (NS.globalDB.global.members[player].clubs[clubId].role ~= info.role)) then
				-- update role
				NS.globalDB.global.members[player].clubs[clubId].role = info.role
			end

			-- member role updated?
			if (not NS.globalDB.global.members[player].clubs[clubId].memberNote or (NS.globalDB.global.members[player].clubs[clubId].memberNote ~= info.memberNote)) then
				-- update member note
				NS.globalDB.global.members[player].clubs[clubId].memberNote = info.memberNote
			end

			-- priority updated?
			if (not NS.globalDB.global.members[player].clubs[clubId].priority or (NS.globalDB.global.members[player].clubs[clubId].priority ~= priority)) then
				-- update priority
				NS.globalDB.global.members[player].clubs[clubId].priority = priority
			end

			-- process all clubs
			for k,v in pairs(NS.globalDB.global.members[player].clubs) do
				-- owner?
				if (v.role == Enum.ClubRoleIdentifier.Owner) then
					-- owner
					NS.globalDB.global.members[player].owner = true
				end

				-- leader?
				if (v.role == Enum.ClubRoleIdentifier.Leader) then
					-- leader
					NS.globalDB.global.members[player].leader = true
				end

				-- moderator?
				if (v.role == Enum.ClubRoleIdentifier.Moderator) then
					-- leader
					NS.globalDB.global.members[player].moderator = true
				end

				-- higher priority (lesser number)?
				if (v.priority and NS.globalDB.global.members[player].priority and (v.priority > 0) and (v.priority < NS.globalDB.global.members[player].priority)) then
					-- update priority
					NS.globalDB.global.members[player].priority = v.priority
				end
			end
		end
	else
		-- add to members
		NS.globalDB.global.members[player] = {
			["name"] = player,
			["guid"] = info.guid,
			["classID"] = info.classID,
			["race"] = info.race,
			["faction"] = info.faction,
			["priority"] = priority,
			["clubs"] = {},
		}

		-- add to clubs
		NS.globalDB.global.members[player].clubs[clubId] = {
			["id"] = clubId,
			["role"] = info.role,
			["memberNote"] = info.memberNote,
			["priority"] = priority,
		}

		-- owner?
		if (info.role == Enum.ClubRoleIdentifier.Owner) then
			-- owner
			NS.globalDB.global.members[player].owner = true
		end

		-- leader?
		if (info.role == Enum.ClubRoleIdentifier.Leader) then
			-- leader
			NS.globalDB.global.members[player].leader = true
		end

		-- moderator?
		if (info.role == Enum.ClubRoleIdentifier.Moderator) then
			-- leader
			NS.globalDB.global.members[player].moderator = true
		end

		-- update first seen
		NS.CommunityFlare_History_Update_First(player)
	end

	-- rebuild leaders?
	if (rebuild == true) then
		-- rebuild community leaders
		NS.CommunityFlare_RebuildCommunityLeaders()
	end
end

-- remove member
function NS.CommunityFlare_RemoveMember(clubId, info)
	-- build proper name
	local player = info.name
	if (not strmatch(player, "-")) then
		-- add realm name
		player = player .. "-" .. NS.CommFlare.CF.PlayerServerName
	end

	-- member exists?
	if (NS.globalDB.global.members[player]) then
		-- empty?
		if (not NS.globalDB.global.members[player].clubs) then
			-- initialize
			NS.globalDB.global.members[player].clubs = {}
		end
		if (not NS.globalDB.global.members[player].clubs[clubId]) then
			-- initialize
			NS.globalDB.global.members[player].clubs[clubId] = {}
		end

		-- valid club?
		if (NS.globalDB.global.members[player].clubs and NS.globalDB.global.members[player].clubs[clubId]) then
			-- clear
			NS.globalDB.global.members[player].clubs[clubId] = nil

			-- process all clubs
			local count = 0
			for k,v in pairs(NS.globalDB.global.members[player].clubs) do
				-- increase
				count = count + 1
			end

			-- none left?
			if (count == 0) then
				-- delete
				NS.globalDB.global.members[player] = nil
				return true
			end
		end
	end

	-- not found
	return false
end

-- add all club members from club id
function NS.CommunityFlare_AddAllClubMembersByClubID(clubId)
	-- get club info
	local info = ClubGetClubInfo(clubId)
	if (info and info.name and (info.name ~= "")) then
		-- process all members
		local added = 0
		local members = ClubGetClubMembers(clubId)
		for _,v in ipairs(members) do
			local mi = ClubGetMemberInfo(clubId, v)
			if ((mi ~= nil) and (mi.name ~= nil)) then
				-- add member
				NS.CommunityFlare_AddMember(clubId, mi, false)

				-- increase
				added = added + 1
			end
		end

		-- rebuild community leaders
		NS.CommunityFlare_RebuildCommunityLeaders()

		-- any added?
		if (added > 0) then
			-- display amount added
			print(strformat(L["%s: Added %d %s members to the database."], NS.CommunityFlare_Title, added, info.name))
		end
	end
end

-- remove all club members from club id
function NS.CommunityFlare_RemoveAllClubMembersByClubID(clubId)
	-- get club info
	local info = ClubGetClubInfo(clubId)
	if (info and info.name and (info.name ~= "")) then
		-- process all members
		local removed = 0
		for k,v in pairs(NS.globalDB.global.members) do
			-- valid club?
			if (NS.globalDB.global.members[k].clubs and NS.globalDB.global.members[k].clubs[clubId]) then
				-- clear
				NS.globalDB.global.members[k].clubs[clubId] = nil
			end

			-- any clubs?
			local count = 0
			if (NS.globalDB.global.members[k].clubs and next(NS.globalDB.global.members[k].clubs)) then
				-- process all clubs
				for k2,v2 in pairs(NS.globalDB.global.members[k].clubs) do
					-- increase
					count = count + 1
				end
			end

			-- none left?
			if (count == 0) then
				-- remove
				NS.globalDB.global.members[k] = nil

				-- increase
				removed = removed + 1
			end
		end

		-- rebuild community leaders
		NS.CommunityFlare_RebuildCommunityLeaders()

		-- any removed?
		if (removed > 0) then
			-- display amount removed
			print(strformat(L["%s: Removed %d %s members from the database."], NS.CommunityFlare_Title, removed, info.name))
		end
	end
end

-- update statistics for members
function NS.CommunityFlare_Update_Member_Statistics(type)
	-- process all members found
	for k,v in ipairs(NS.CommFlare.CF.CommNamesList) do
		-- found member?
		if (NS.globalDB.global.members[v]) then
			-- match complete?
			if (type == "completed") then
				-- update completed matches
				NS.CommunityFlare_History_Update_Completed_Matches(v)
			else
				-- update grouped matches
				NS.CommunityFlare_History_Update_Grouped_Matches(v)

				-- update last grouped
				NS.CommunityFlare_History_Update_Last_Grouped(v)
			end
		end
	end
end

-- update member database
function NS.CommunityFlare_UpdateMembers(clubId, type)
	-- adding?
	if (type == true) then
		-- add all club members
		NS.CommunityFlare_AddAllClubMembersByClubID(clubId)
	else
		-- remove all club members
		NS.CommunityFlare_RemoveAllClubMembersByClubID(clubId)
	end
end

-- process club members
function NS.CommunityFlare_Process_Club_Members()
	-- get clubs list
	local clubs = NS.CommunityFlare_GetClubsList()
	if (not clubs) then
		-- no subscribed clubs found
		return false
	end

	-- process clubs
	for _,clubId in ipairs(clubs) do
		-- club type is a community?
		local info = ClubGetClubInfo(clubId)
		if (info and (info.clubType == Enum.ClubType.Character)) then
			-- add community
			NS.CommunityFlare_AddCommunity(clubId, info)

			-- process all members
			local members = ClubGetClubMembers(clubId)
			for k,v in ipairs(members) do
				local mi = ClubGetMemberInfo(clubId, v)
				if ((mi ~= nil) and (mi.name ~= nil)) then
					-- add member
					NS.CommunityFlare_AddMember(clubId, mi, false)
				end

				-- online?
				if (mi.presence == Enum.ClubMemberPresence.Online) then
					-- get community member
					local member = NS.CommunityFlare_GetCommunityMember(mi.name)
					if (member ~= nil) then
						-- update last seen
						NS.CommunityFlare_History_Update_Last_Seen(member.name)
					end
				end
			end
		end
	end

	-- rebuild community leaders
	NS.CommunityFlare_RebuildCommunityLeaders()

	-- verify report channel added
	NS.CommunityFlare_VerifyReportChannelAdded()
	return true
end

-- process member guid
function NS.CommunityFlare_Process_MemberGUID(guid, player)
	-- no guid?
	if (not guid or (guid == "")) then
		-- failed
		return false
	end

	-- no player?
	if (not player or (player == "")) then
		-- failed
		return false
	end

	-- database created?
	if (NS.globalDB.global and NS.globalDB.global.MemberGUIDs) then
		-- new / updated?
		if (not NS.globalDB.global.MemberGUIDs[guid] or (NS.globalDB.global.MemberGUIDs[guid] ~= player)) then
			-- update member
			NS.globalDB.global.MemberGUIDs[guid] = player
			return true
		end
	end

	-- failed
	return false
end

-- refresh club members
function NS.CommunityFlare_Refresh_Club_Members()
	-- update invisible status
	NS.CommFlare.CF.Invisble = NS.CommunityFlare_IsInvisible()

	-- process club members
	local status = NS.CommunityFlare_Process_Club_Members()
	if (status == false) then
		-- finished
		return
	end

	-- find player in database
	local player = NS.CommunityFlare_GetPlayerName("full")
	local member = NS.CommunityFlare_GetCommunityMember(player)
	if (not member or not member.clubs) then
		-- finished
		return
	end

	-- needs refreshing?
	local refresh = false
	if (NS.charDB.profile.communityRefreshed == 0) then
		-- refresh
		refresh = true
	elseif (NS.charDB.profile.communityRefreshed > 0) then
		-- refreshed more than 7 days ago?
		local next_refresh = NS.charDB.profile.communityRefreshed + (7 * 86400)
		if (time() > next_refresh) then
			-- refresh
			refresh = true
		end
	end

	-- needs refreshing?
	if (refresh == true) then
		-- process all clubs
		for k,v in pairs(member.clubs) do
			-- remove all club members
			NS.CommunityFlare_RemoveAllClubMembersByClubID(k)

			-- add all club members
			NS.CommunityFlare_AddAllClubMembersByClubID(k)
		end

		-- save refresh date
		NS.charDB.profile.communityRefreshed = time()
	end

	-- purge older
	local timestamp = time()
	for k,v in pairs(NS.globalDB.global.matchLogList) do
		-- older found?
		if (not v.timestamp or (k > 1000000)) then
			-- delete
			NS.globalDB.global.matchLogList[k] = nil
		else
			-- older than 7 days?
			local older = v.timestamp + (7 * 86400)
			if (timestamp > older) then
				-- delete
				NS.globalDB.global.matchLogList[k] = nil
			end
		end
	end

	-- clean up members
	NS.CommunityFlare_CleanUpMembers()

	-- build member guids list / update if already created
	local updated = 0
	NS.globalDB.global.MemberGUIDs = NS.globalDB.global.MemberGUIDs or {}
	for k,v in pairs(NS.globalDB.global.members) do
		-- updated?
		if (not NS.globalDB.global.MemberGUIDs[v.guid] or (NS.globalDB.global.MemberGUIDs[v.guid] ~= v.name)) then
			-- save / update member guid / name
			NS.globalDB.global.MemberGUIDs[v.guid] = v.name
			updated = updated + 1
		end
	end

	-- updated?
	if (updated > 0) then
		-- flush members / guids
		CommunityFlareDB.global.members = NS.globalDB.global.members
		CommunityFlareDB.global.MemberGUIDs = NS.globalDB.global.MemberGUIDs
	end

	-- clean up history
	NS.CommunityFlare_CleanUpHistory()
end

-- club member added
function NS.CommunityFlare_ClubMemberAdded(clubId, memberId)
	-- get member info
	NS.CommFlare.CF.MemberInfo = ClubGetMemberInfo(clubId, memberId)
	if (NS.CommFlare.CF.MemberInfo ~= nil) then
		-- name not found?
		local info = ClubGetClubInfo(clubId)
		if (not NS.CommFlare.CF.MemberInfo.name) then
			-- try again, 2 seconds later
			TimerAfter(2, function()
				-- get member info
				NS.CommFlare.CF.MemberInfo = ClubGetMemberInfo(clubId, memberId)

				-- name not found?
				if ((NS.CommFlare.CF.MemberInfo ~= nil) and (NS.CommFlare.CF.MemberInfo.name ~= nil)) then
					-- display
					print(strformat(L["%s: %s (%d, %d) added to community %s."], NS.CommunityFlare_Title, NS.CommFlare.CF.MemberInfo.name, clubId, memberId, info.name))

					-- add member
					NS.CommunityFlare_AddMember(clubId, NS.CommFlare.CF.MemberInfo, true)
				end
			end)
		else
			-- display
			print(strformat(L["%s: %s (%d, %d) added to community %s."], NS.CommunityFlare_Title, NS.CommFlare.CF.MemberInfo.name, clubId, memberId, info.name))

			-- add member
			NS.CommunityFlare_AddMember(clubId, NS.CommFlare.CF.MemberInfo, true)
		end
	end
end

-- club member removed
function NS.CommunityFlare_ClubMemberRemoved(clubId, memberId)
	-- get member info
	NS.CommFlare.CF.MemberInfo = ClubGetMemberInfo(clubId, memberId)
	if (not NS.CommFlare.CF.MemberInfo) then
		-- has community frame member list?
		if (CommunitiesFrame and CommunitiesFrame.MemberList and CommunitiesFrame.MemberList.allMemberList) then
			-- process all
			for k,v in ipairs(CommunitiesFrame.MemberList.allMemberList) do
				-- matches?
				if (v.memberId == memberId) then
					-- found
					NS.CommFlare.CF.MemberInfo = v
					break
				end
			end
		end
	end

	-- found member info?
	if (NS.CommFlare.CF.MemberInfo) then
		-- build proper name
		local player = NS.CommFlare.CF.MemberInfo.name
		if (not strmatch(player, "-")) then
			-- add realm name
			player = player .. "-" .. NS.CommFlare.CF.PlayerServerName
		end

		-- has clubs?
		if (NS.globalDB.global.members[player] and NS.globalDB.global.members[player].clubs) then
			-- process all
			local count = 0
			for k,v in pairs(NS.globalDB.global.members[player].clubs) do
				-- matches?
				if (k == clubId) then
					-- delete club
					NS.globalDB.global.members[player].clubs[k] = nil
				else
					-- increase
					count = count + 1
				end
			end

			-- no clubs left?
			if (count == 0) then
				-- delete member
				NS.globalDB.global.members[player] = nil
			end
		end

		-- found member name?
		local info = ClubGetClubInfo(clubId)
		if (NS.CommFlare.CF.MemberInfo.name ~= nil) then
			-- display
			print(strformat(L["%s: %s (%d, %d) removed from community %s."], NS.CommunityFlare_Title, player, clubId, memberId, info.name))
		end
	end
end

-- club member updated
function NS.CommunityFlare_ClubMemberUpdated(clubId, memberId)
	-- get member info
	NS.CommFlare.CF.MemberInfo = ClubGetMemberInfo(clubId, memberId)
	if (NS.CommFlare.CF.MemberInfo and NS.CommFlare.CF.MemberInfo.name and (NS.CommFlare.CF.MemberInfo.name ~= "")) then
		-- build proper name
		local player = NS.CommFlare.CF.MemberInfo.name
		if (not strmatch(player, "-")) then
			-- add realm name
			player = player .. "-" .. NS.CommFlare.CF.PlayerServerName
		end

		-- member exists?
		if (NS.globalDB.global.members[player]) then
			-- no priority?
			if (not NS.globalDB.global.members[player].priority) then
				-- save default priority
				NS.globalDB.global.members[player].priority = 999
			end

			-- valid club?
			local rebuild = false
			if (NS.globalDB.global.members[player].clubs and NS.globalDB.global.members[player].clubs[clubId]) then
				-- role updated?
				if (not NS.globalDB.global.members[player].clubs[clubId].role or (NS.globalDB.global.members[player].clubs[clubId].role ~= NS.CommFlare.CF.MemberInfo.role)) then
					-- update role
					NS.globalDB.global.members[player].clubs[clubId].role = NS.CommFlare.CF.MemberInfo.role

					-- rebuild
					rebuild = true
				end

				-- member note updated?
				if (not NS.globalDB.global.members[player].clubs[clubId].memberNote or (NS.globalDB.global.members[player].clubs[clubId].memberNote ~= NS.CommFlare.CF.MemberInfo.memberNote)) then
					-- update member note
					NS.globalDB.global.members[player].clubs[clubId].memberNote = NS.CommFlare.CF.MemberInfo.memberNote
				end

				-- priority updated?
				local priority = NS.CommunityFlare_GetMemberPriority(NS.CommFlare.CF.MemberInfo)
				if (not NS.globalDB.global.members[player].clubs[clubId].priority or (NS.globalDB.global.members[player].clubs[clubId].priority ~= priority)) then
					-- update priority
					NS.globalDB.global.members[player].clubs[clubId].priority = priority

					-- find lowest priority
					local lowest = 999
					for k,v in pairs(NS.globalDB.global.members[player].clubs) do
						-- higher priority (lesser number)?
						if (v.priority and (v.priority > 0) and (v.priority < lowest)) then
							-- update lowest
							lowest = v.priority
						end
					end

					-- update player priority?
					if (NS.globalDB.global.members[player].priority ~= lowest) then
						-- update priority
						NS.globalDB.global.members[player].priority = lowest

						-- rebuild
						rebuild = true
					end
				end
			end

			-- rebuild leaders?
			if (rebuild == true) then
				-- rebuild community leaders
				NS.CommunityFlare_RebuildCommunityLeaders()
			end
		end
	end
end

-- find community members who left?
function NS.CommunityFlare_FindExCommunityMembers(clubId)
	local count = 0
	local current = {}
	local members = ClubGetClubMembers(clubId)
	for _,v in ipairs(members) do
		local info = ClubGetMemberInfo(clubId, v)
		if ((info ~= nil) and (info.name ~= nil)) then
			-- build proper name
			local player = info.name
			if (not strmatch(player, "-")) then
				-- add realm name
				player = player .. "-" .. NS.CommFlare.CF.PlayerServerName
			end

			-- add to current
			current[player] = info
		end
	end

	-- process all
	local removed = {}
	for k,v in pairs(NS.globalDB.global.members) do
		-- process clubs
		local matched = false
		for k2,v2 in pairs(v.clubs) do
			-- matches?
			if (clubId == k2) then
				-- matched
				matched = true
			end
		end

		-- matched?
		if (matched == true) then
			-- not found in current?
			if (not current[k]) then
				-- add removed
				removed[k] = k
				count = count + 1
				print(strformat(L["Not Member: %s"], v.name))
			end
		end
	end

	-- save removed
	NS.globalDB.global.removed = removed

	-- wipe old
	wipe(current)

	-- display count
	print(strformat(L["Count: %d"], count))
end

-- find inactive members
function NS.CommunityFlare_FindCommunityMembers(type, clubId)
	-- process all
	local count = 0
	for k,v in pairs(NS.globalDB.global.members) do
		-- has club membership?
		if (v.clubs and v.clubs[clubId]) then
			-- inactive?
			local history = NS.CommunityFlare_History_Get(k)
			if (type == "inactive") then
				-- get history
				if (not history or not history.last or (time() - history.last) >= 60 * 24 * 60 * 60) then
					-- display player name
					local inactivityDate = date("%Y-%m-%d", history.last)
					print(strformat(L["Inactive: %s: Last active: %s"], k, inactivityDate))
					count = count + 1
				end
			-- nocompleted?
			elseif (type == "nocompleted") then
				-- has history, but no matches completed?
				if (history and not history.cmc) then
					-- display player name
					print(strformat(L["No Completed Matches: %s"], k))
					count = count + 1
				end
			-- nogrouped?
			elseif (type == "nogrouped") then
				-- has history, but no matches grouped?
				if (history and not history.gmc) then
					-- display player name
					print(strformat(L["No Grouped Matches: %s"], k))
					count = count + 1
				end
			end
		end
	end

	-- display count
	print(strformat(L["Count: %d"], count))
end

-- is community member?
function NS.CommunityFlare_IsCommunityMember(name)
	-- invalid name?
	local player = name
	if (not player or (player == "")) then
		-- failed
		return false
	end

	-- build proper name
	if (not strmatch(player, "-")) then
		-- add realm name
		player = player .. "-" .. NS.CommFlare.CF.PlayerServerName
	end

	-- check inside database first
	if (player and (player ~= "") and NS.globalDB.global and NS.globalDB.global.members and NS.globalDB.global.members[player]) then
		-- success
		return true
	end

	-- failed
	return false
end

-- has shared community?
function NS.CommunityFlare_HasSharedCommunity(sender)
	-- not loaded?
	if (not NS.CommFlare or not NS.globalDB) then
		-- failed
		return false
	end

	-- invalid sender?
	if (not sender) then
		-- failed
		return false
	end

	-- number?
	if (type(sender) == "number") then
		-- get battle net friend name
		sender = NS.CommunityFlare_GetBNetFriendName(sender)
		if (not sender) then
			-- failed
			return false
		end
	end

	-- find sender in database
	local member2 = NS.CommunityFlare_GetCommunityMember(sender)
	if (not member2 or not member2.clubs) then
		-- failed
		return false
	end

	-- find player in database
	local player = NS.CommunityFlare_GetPlayerName("full")
	local member1 = NS.CommunityFlare_GetCommunityMember(player)
	if (not member1 or not member1.clubs) then
		-- failed
		return false
	end

	-- process player clubs
	for k,v in pairs(member1.clubs) do
		-- club exists for sender?
		if (member2.clubs and member2.clubs[k]) then
			-- success
			return true
		end
	end

	-- failed
	return false
end

-- refresh database
function NS.CommunityFlare_Refresh_Database()
	-- get clubs list
	local clubs = NS.CommunityFlare_GetClubsList()
	if (not clubs) then
		-- none
		print(strformat("%s: No subscribed clubs found.", NS.CommunityFlare_Title))
		return
	end

	-- process clubs
	for _,clubId in ipairs(clubs) do
		-- club type is a community?
		local info = ClubGetClubInfo(clubId)
		if (info and (info.clubType == Enum.ClubType.Character)) then
			-- add community
			NS.CommunityFlare_AddCommunity(clubId, info)

			-- remove all club members
			NS.CommunityFlare_RemoveAllClubMembersByClubID(clubId)

			-- add all club members
			NS.CommunityFlare_AddAllClubMembersByClubID(clubId)
		end
	end

	-- rebuild community leaders
	NS.CommunityFlare_RebuildCommunityLeaders()

	-- verify report channel added
	NS.CommunityFlare_VerifyReportChannelAdded()
end

-- find member by guid
function NS.CommunityFlare_FindCommunityMemberByGUID(guid)
	-- sanity checks?
	if (not NS.CommFlare or not NS.globalDB) then
		-- failed
		return nil
	end

	-- invalid guid?
	if (not guid or (guid == "")) then
		-- failed
		return nil
	end

	-- check inside database
	if (NS.globalDB.global.MemberGUIDs and NS.globalDB.global.MemberGUIDs[guid]) then
		-- check inside database
		local player = NS.globalDB.global.MemberGUIDs[guid]
		if (player and (player ~= "") and NS.globalDB.global and NS.globalDB.global.members and NS.globalDB.global.members[player]) then
			-- success
			return NS.globalDB.global.members[player]
		end

		-- failed
		return nil
	end

	-- not found?
	local player, realm = select(6, GetPlayerInfoByGUID(guid))
	if (not player or (player == "")) then
		-- failed
		return nil
	end

	-- no realm found?
	if (not realm or (realm == "")) then
		-- add realm
		player = player .. "-" .. NS.CommFlare.CF.PlayerServerName
	else
		-- add realm
		player = player .. "-" .. realm
	end

	-- check inside database
	if (player and (player ~= "") and NS.globalDB.global and NS.globalDB.global.members and NS.globalDB.global.members[player]) then
		-- success
		return NS.globalDB.global.members[player]
	end

	-- process all
	for k,v in pairs(NS.globalDB.global.members) do
		-- matches?
		if (v.guid == guid) then
			-- success
			return v
		end
	end

	-- failed
	return nil
end
