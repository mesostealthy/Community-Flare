-- initialize
local LibStub = LibStub
local ADDON_NAME, NS = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
if (not L or not NS.CommFlare) then return end

-- localize stuff
local _G                                        = _G
local AddChatWindowChannel                      = _G.AddChatWindowChannel
local Chat_GetCommunitiesChannel                = _G.Chat_GetCommunitiesChannel
local Chat_GetCommunitiesChannelName            = _G.Chat_GetCommunitiesChannelName
local CopyTable                                 = _G.CopyTable
local GetChannelName                            = _G.GetChannelName
local GetPlayerInfoByGUID                       = _G.GetPlayerInfoByGUID
local IsInGuild                                 = _G.IsInGuild
local UnitFactionGroup                          = _G.UnitFactionGroup
local UnitName                                  = _G.UnitName
local ClubGetGuildClubId                        = _G.C_Club.GetGuildClubId
local ClubGetClubInfo                           = _G.C_Club.GetClubInfo
local ClubGetClubMembers                        = _G.C_Club.GetClubMembers
local ClubGetMemberInfo                         = _G.C_Club.GetMemberInfo
local ClubGetStreamInfo                         = _G.C_Club.GetStreamInfo
local ClubGetStreams                            = _G.C_Club.GetStreams
local ClubGetSubscribedClubs                    = _G.C_Club.GetSubscribedClubs
local PvPIsArena                                = _G.C_PvP.IsArena
local PvPIsInBrawl                              = _G.C_PvP.IsInBrawl
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

-- verify default community setup
function NS:Verify_Default_Community_Setup()
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
					print(strformat(L["%s: No subscribed clubs found."], NS.CommFlare.Title))
				end
			end
		-- only one found?
		elseif (count == 1) then
			-- setup stuff
			NS.charDB.profile.communityList = {}
			NS.charDB.profile.communityMain = clubId

			-- remove all members
			NS:Remove_All_Club_Members_By_ClubID(clubId)

			-- add all members
			NS:Add_All_Club_Members_By_ClubID(clubId)

			-- setup report channels
			NS:Setup_Report_Channels()

			-- save refresh date
			NS.charDB.profile.communityRefreshed = time()
		end
	end

	-- return count
	return count
end

-- get club list
function NS:Get_Clubs_List(bIgnoreGuild)
	-- not created yet?
	if (not NS.CommFlare.CF.ClubList) then
		-- initialize
		NS.CommFlare.CF.ClubList = {}
	end

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
			NS.CommFlare.CF.ClubList[clubId] = true
			tinsert(clubs, clubId)
			count = count + 1
		end
	end

	-- has community list?
	if (NS.charDB.profile.communityList and (next(NS.charDB.profile.communityList) ~= nil)) then
		-- process all lists
		for k,_ in pairs(NS.charDB.profile.communityList) do
			-- valid?
			if (k > 1) then
				-- add club id
				NS.CommFlare.CF.ClubList[k] = true
				tinsert(clubs, k)
				count = count + 1
			end
		end
	end

	-- not ignoring guild?
	if (bIgnoreGuild ~= true) then
		-- treat guild as community?
		if (NS.charDB.profile.addGuildMembers == true) then
			-- get guild club id
			clubId = ClubGetGuildClubId()
			if (clubId and (clubId > 1)) then
				-- add guild club id
				NS.CommFlare.CF.ClubList[clubId] = true
				tinsert(clubs, clubId)
				count = count + 1
			end
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

-- get enabled clubs
function NS:Get_Enabled_Clubs()
	-- find main community club
	local count = 0
	local clubs = {}
	local clubId = NS.charDB.profile.communityMain
	if (clubId > 1) then
		-- enabled
		clubs[clubId] = true
		count = count + 1
	end

	-- has community list?
	if (NS.charDB.profile.communityList and (next(NS.charDB.profile.communityList) ~= nil)) then
		-- process all lists
		for k,_ in pairs(NS.charDB.profile.communityList) do
			-- enabled
			clubs[k] = true
			count = count + 1
		end
	end

	-- none found?
	if (count == 0) then
		-- none
		return nil
	end

	-- return enabled clubs
	return clubs
end

-- verify club streams
function NS:Verify_Club_Streams(clubs)
	-- inside pvp content?
	local isArena = PvPIsArena()
	local isBrawl = PvPIsInBrawl()
	local isBattleground = NS:IsInBattleground()
	if (isArena or isBattleground or isBrawl) then
		-- finished
		return
	end

	-- no clubs?
	if (not clubs) then
		-- finished
		return
	end

	-- count clubs
	local count = 0
	for k,v in pairs(clubs) do
		-- increase
		count = count + 1
	end

	-- no count?
	if (count == 0) then
		-- finished
		return
	end

	-- display
	local verify = false
	for i=1, MAX_WOW_CHAT_CHANNELS do
		-- found channel name?
		local channelID, channelName = GetChannelName(i)
		if ((channelID > 0) and channelName) then
			-- non community?
			if (not strmatch(channelName, "Community")) then
				-- verify
				verify = true
			end
		end
	end

	-- increase
	NS.CommFlare.CF.StreamsRetryCount = NS.CommFlare.CF.StreamsRetryCount + 1
	if (NS.CommFlare.CF.StreamsRetryCount > 60) then
		-- finished
		return
	end

	-- can not verify yet?
	if (verify == false) then
		-- try again, 1 second later
		TimerAfter(1, function()
			-- call recursively
			NS:Verify_Club_Streams(clubs)
		end)
		return
	end

	-- process all clubs
	local loaded = true
	for clubId,_ in pairs(clubs) do
		-- not loaded?
		local streams = ClubGetStreams(clubId)
		if (not streams or (#streams < 1)) then
			-- failed
			loaded = false
		end
	end

	-- still not loaded?
	if (loaded == false) then
		-- try again, 1 second later
		TimerAfter(1, function()
			-- call recursively
			NS:Verify_Club_Streams(clubs)
		end)
		return
	end

	-- process all clubs
	for clubId,_ in pairs(clubs) do
		-- has streams?
		local streams = ClubGetStreams(clubId)
		if (streams) then
			-- process all
			for _,v in ipairs(streams) do
				-- has stream info?
				local streamInfo = ClubGetStreamInfo(clubId, v.streamId)
				if (streamInfo and streamInfo.streamType) then
					-- general?
					if (streamInfo.streamType == Enum.ClubStreamType.General) then
						-- verify channel is added for proper reporting
						local channel = Chat_GetCommunitiesChannel(clubId, v.streamId)
						if (not channel or (NS.charDB.profile.alwaysReaddChannels == true)) then
							-- readd community chat window
							NS:ReaddCommunityChatWindow(clubId, v.streamId)
						end

						-- AddChatWindowChannel available?
						if (AddChatWindowChannel) then
							-- add chat window to general
							local channelName = Chat_GetCommunitiesChannelName(clubId, v.streamId)
							AddChatWindowChannel(1, channelName)
						end
					end
				end
			end
		end
	end

	-- reset
	NS.CommFlare.CF.StreamsRetryCount = 0
	NS.CommFlare.CF.ChannelStreamsLoaded = true

	-- setup report channels
	NS:Setup_Report_Channels()
end

-- is community leader?
function NS:Is_Community_Leader(name)
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

-- process member guid
function NS:Process_MemberGUID(guid, player)
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
	if (NS.db.global and NS.db.global.MemberGUIDs) then
		-- new / updated?
		if (not NS.db.global.MemberGUIDs[guid] or (NS.db.global.MemberGUIDs[guid] ~= player)) then
			-- check for old member?
			local old_player = NS.db.global.MemberGUIDs[guid]
			if (NS.db.global.members[old_player]) then
				-- move member
				NS.db.global.members[old_player].name = player
				NS.db.global.members[player] = CopyTable(NS.db.global.members[old_player])
				NS.db.global.members[old_player] = nil
			end

			-- check for old history?
			if (NS.db.global.history[old_player]) then
				-- no new history?
				if (not NS.db.global.history[player]) then
					-- move history
					NS.db.global.history[player] = CopyTable(NS.db.global.history[old_player])
				-- has old history?
				elseif (NS.db.global.history[player]) then
					-- first seen updated?
					if (not NS.db.global.history[player].first) then
						-- update first
						NS.db.global.history[player].first = NS.db.global.history[old_player].last
					elseif (NS.db.global.history[old_player].first and (NS.db.global.history[old_player].first < NS.db.global.history[player].first)) then
						-- update first
						NS.db.global.history[player].first = NS.db.global.history[old_player].last
					end

					-- last seen updated?
					if (not NS.db.global.history[player].last) then
						-- update first
						NS.db.global.history[player].last = NS.db.global.history[old_player].last
					elseif (NS.db.global.history[old_player].last and (NS.db.global.history[old_player].last > NS.db.global.history[player].last)) then
						-- update first
						NS.db.global.history[player].last = NS.db.global.history[old_player].last
					end

					-- last grouped updated?
					if (not NS.db.global.history[player].lastgrouped) then
						-- update first
						NS.db.global.history[player].lastgrouped = NS.db.global.history[old_player].lastgrouped
					elseif (NS.db.global.history[old_player].lastgrouped and (NS.db.global.history[old_player].lastgrouped > NS.db.global.history[player].lastgrouped)) then
						-- update first
						NS.db.global.history[player].lastgrouped = NS.db.global.history[old_player].lastgrouped
					end

					-- no chat message count?
					if (not NS.db.global.history[player].cmc) then
						-- initialize
						NS.db.global.history[player].cmc = 0
					end

					-- no grouped matches count?
					if (not NS.db.global.history[player].gmc) then
						-- initialize
						NS.db.global.history[player].gmc = 0
					end

					-- has chat message count to update?
					if (NS.db.global.history[old_player].cmc and (NS.db.global.history[old_player].cmc > 0)) then
						-- add to chat message count
						NS.db.global.history[player].cmc = NS.db.global.history[player].cmc + NS.db.global.history[old_player].cmc
					end

					-- has grouped matches count to update?
					if (NS.db.global.history[old_player].gmc and (NS.db.global.history[old_player].gmc > 0)) then
						-- add to grouped matches count
						NS.db.global.history[player].gmc = NS.db.global.history[player].gmc + NS.db.global.history[old_player].gmc
					end
				end

				-- clear old history
				NS.db.global.history[old_player] = nil
			end

			-- update member guid
			NS.db.global.MemberGUIDs[guid] = player
			return true
		end
	end

	-- failed
	return false
end


-- get community member
function NS:Get_Community_Member(name)
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
	if (player and (player ~= "") and NS.db.global and NS.db.global.members and NS.db.global.members[player]) then
		-- success
		return NS.db.global.members[player]
	end

	-- failed
	return nil
end

-- get loglist status
function NS:Get_LogList_Status(player)
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
	if (player and (player ~= "") and NS.db.global and NS.db.global.members and NS.db.global.members[player]) then
		-- not setup yet?
		if (not NS.charDB.profile.communityLogList) then
			-- initialize
			NS.charDB.profile.communityLogList = {}
		end

		-- process clubs
		for k,v in pairs(NS.db.global.members[player].clubs) do
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
function NS:Cleanup_Members()
	-- process all members
	for k,v in pairs(NS.db.global.members) do
		-- has space?
		if (strmatch(k, " ")) then
			-- fix player in database
			local player = strgsub(k, "%s+", "")
			NS.db.global.members[player] = v
			NS.db.global.members[player].name = player
			NS.db.global.members[k] = nil
			print(strformat(L["Moved: %s to %s"], k, player))
		end
	end

	-- process all members
	local removed = 0
	NS.CommFlare.CF.KosList = NS.CommFlare.CF.KosList or {}
	NS.db.global.MemberGUIDs = NS.db.global.MemberGUIDs or {}
	for k,v in pairs(NS.db.global.members) do
		-- check for leader / owner
		local player = v.name
		for k2,v2 in pairs(NS.db.global.members[player].clubs) do
			-- owner?
			if (v2.role == Enum.ClubRoleIdentifier.Owner) then
				-- leader
				NS.db.global.members[player].owner = true
				v.owner = true
			-- leader?
			elseif (v2.role == Enum.ClubRoleIdentifier.Leader) then
				-- leader
				NS.db.global.members[player].leader = true
				v.leader = true
			-- moderator?
			elseif (v2.role == Enum.ClubRoleIdentifier.Moderator) then
				-- leader
				NS.db.global.members[player].moderator = true
				v.moderator = true
			end

			-- still has id?
			if (NS.db.global.members[player].clubs[k2].id) then
				-- delete id
				NS.db.global.members[player].clubs[k2].id = nil
			end
		end

		-- not leader or owner?
		if ((not v.leader or (v.leader == false)) and (not v.owner or (v.owner == false)) and (not v.moderator or (v.moderator == false))) then
			-- reset priority
			NS.db.global.members[player].priority = NS.CommFlare.CF.MaxPriority
		end

		-- has added?
		if (v.added) then
			-- delete added
			NS.db.global.members[player].added = nil
		end

		-- has updated?
		if (v.updated) then
			-- delete updated
			NS.db.global.members[player].updated = nil
		end

		-- has lastgrouped?
		if (v.lastgrouped) then
			-- move to history
			NS.db.global.history[player].lastgrouped = v.lastgrouped
			NS.db.global.members[player].lastgrouped = nil
		end

		-- updated?
		if (not NS.db.global.MemberGUIDs[v.guid] or (NS.db.global.MemberGUIDs[v.guid] ~= player)) then
			-- save / update member guid / name
			NS.db.global.MemberGUIDs[v.guid] = player
		end
	end

	-- process all member GUIDs
	for k,v in pairs(NS.db.global.MemberGUIDs) do
		-- KOS?
		if (NS.CommFlare.CF.KosList[k]) then
			-- has player and needs updating?
			if (NS.CommFlare.CF.KosList[k].player and (NS.CommFlare.CF.KosList[k].player ~= v)) then
				-- update player
				NS.CommFlare.CF.KosList[k].player = v
			end
		end
	end
end

-- check for deployed members
function NS:Check_For_Deployed_Members()
	-- get clubs
	local clubs = NS:Get_Clubs_List(false)
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
						local isTracked, isEpicBattleground, isRandomBattleground, isBrawl = NS:IsTrackedPVP(mi.zone)
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
				print(strformat(L["%s: %s Deployed Members."], NS.CommFlare.Title, club.name))
				for k,v in pairs(deployed) do
					-- display result
					print(strformat(L["-%s = %d member/s"], k, v))
				end

				-- increase
				deployed_count = deployed_count + 1
			else
				-- display message
				print(strformat(L["%s: No members are deployed for %s."], NS.CommFlare.Title, club.name))
			end
		end

		-- noone deployed?
		if (deployed_count == 0) then
			-- display message
			print(strformat(L["%s: No members are deployed."], NS.CommFlare.Title))
		end
	else
		-- display message
		print(strformat(L["%s: No subscribed clubs found."], NS.CommFlare.Title))
	end
end

-- rebuild community leaders
function NS:Rebuild_Community_Leaders()
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
	for k,v in pairs(NS.db.global.members) do
		-- owner?
		if (v.owner) then
			-- always verify leader status
			local player = v.name
			local sharesLeaderCommunity = false
			NS.db.global.members[player].owner = nil
			for k2,v2 in pairs(NS.db.global.members[player].clubs) do
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
					NS.db.global.members[player].owner = true
				end
			end

			-- currently has owner role somewhere?
			if (NS.db.global.members[player].owner == true) then
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
			NS.db.global.members[player].leader = nil
			for k2,v2 in pairs(NS.db.global.members[player].clubs) do
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
					NS.db.global.members[player].leader = true
				end
			end

			-- currently has leader role somewhere?
			if (NS.db.global.members[player].leader == true) then
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
			NS.db.global.members[player].moderator = nil
			for k2,v2 in pairs(NS.db.global.members[player].clubs) do
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
					NS.db.global.members[player].moderator = true
				end
			end

			-- currently has moderator role somewhere?
			if (NS.db.global.members[player].moderator == true) then
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
function NS:Get_Member_Priority(info)
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
function NS:Add_Community(clubId, info)
	-- add to clubs
	NS.db.global.clubs[clubId] = info

	-- not cross faction?
	if (info.crossFaction == false) then
		-- assume same faction as player with club
		NS.db.global.clubs[clubId].faction = UnitFactionGroup("player")
	end
end

-- add member
function NS:Add_Member(clubId, info, rebuild)
	-- build proper name
	local player = info.name
	if (not strmatch(player, "-")) then
		-- get player info by guid
		local name, realm = select(6, GetPlayerInfoByGUID(info.guid))
		if (name and realm and (realm ~= "")) then
			-- rebuild full
			player = name .. "-" .. realm
		else
			-- add realm name
			player = player .. "-" .. NS.CommFlare.CF.PlayerServerName
		end
	end

	-- sanity check
	local name, server = strsplit("-", player)
	if (not name or (name == "") or not server or (server == "")) then
		-- failed
		return
	end

	-- member exists?
	local priority = NS:Get_Member_Priority(info)
	if (NS.db.global.members[player]) then
		-- remove old fields
		NS.db.global.members[player].role = nil
		NS.db.global.members[player].clubId = nil
		NS.db.global.members[player].memberNote = nil

		-- guid updated?
		if (not NS.db.global.members[player].guid or (NS.db.global.members[player].guid ~= info.guid)) then
			-- update guid
			NS.db.global.members[player].guid = info.guid
		end

		-- class updated?
		if (not NS.db.global.members[player].classID or (NS.db.global.members[player].classID ~= info.classID)) then
			-- update class
			NS.db.global.members[player].classID = info.classID
		end

		-- race updated?
		if (not NS.db.global.members[player].race or (NS.db.global.members[player].race ~= info.race)) then
			-- update race
			NS.db.global.members[player].race = info.race
		end

		-- faction updated?
		if (not NS.db.global.members[player].faction or (NS.db.global.members[player].faction ~= info.faction)) then
			-- update faction
			NS.db.global.members[player].faction = info.faction
		end

		-- always has some priority number?
		if (not NS.db.global.members[player].priority) then
			-- set max
			NS.db.global.members[player].priority = NS.CommFlare.CF.MaxPriority
		end

		-- empty?
		if (not NS.db.global.members[player].clubs) then
			-- initialize
			NS.db.global.members[player].clubs = {}
		end
		if (not NS.db.global.members[player].clubs[clubId]) then
			-- initialize
			NS.db.global.members[player].clubs[clubId] = {}
		end

		-- has clubs loaded?
		if (NS.db.global.members[player].clubs and NS.db.global.members[player].clubs[clubId]) then
			-- role updated?
			if (not NS.db.global.members[player].clubs[clubId].role or (NS.db.global.members[player].clubs[clubId].role ~= info.role)) then
				-- update role
				NS.db.global.members[player].clubs[clubId].role = info.role
			end

			-- member role updated?
			if (not NS.db.global.members[player].clubs[clubId].memberNote or (NS.db.global.members[player].clubs[clubId].memberNote ~= info.memberNote)) then
				-- update member note
				NS.db.global.members[player].clubs[clubId].memberNote = info.memberNote
			end

			-- priority updated?
			if (not NS.db.global.members[player].clubs[clubId].priority or (NS.db.global.members[player].clubs[clubId].priority ~= priority)) then
				-- update priority
				NS.db.global.members[player].clubs[clubId].priority = priority
			end

			-- process all clubs
			for k,v in pairs(NS.db.global.members[player].clubs) do
				-- owner?
				if (v.role == Enum.ClubRoleIdentifier.Owner) then
					-- owner
					NS.db.global.members[player].owner = true
				end

				-- leader?
				if (v.role == Enum.ClubRoleIdentifier.Leader) then
					-- leader
					NS.db.global.members[player].leader = true
				end

				-- moderator?
				if (v.role == Enum.ClubRoleIdentifier.Moderator) then
					-- leader
					NS.db.global.members[player].moderator = true
				end

				-- higher priority (lesser number)?
				if (v.priority and NS.db.global.members[player].priority and (v.priority > 0) and (v.priority < NS.db.global.members[player].priority)) then
					-- update priority
					NS.db.global.members[player].priority = v.priority
				end
			end
		end
	else
		-- add to members
		NS.db.global.members[player] = {
			["name"] = player,
			["guid"] = info.guid,
			["classID"] = info.classID,
			["race"] = info.race,
			["faction"] = info.faction,
			["priority"] = priority,
			["clubs"] = {},
		}

		-- add to clubs
		NS.db.global.members[player].clubs[clubId] = {
			["id"] = clubId,
			["role"] = info.role,
			["memberNote"] = info.memberNote,
			["priority"] = priority,
		}

		-- owner?
		if (info.role == Enum.ClubRoleIdentifier.Owner) then
			-- owner
			NS.db.global.members[player].owner = true
		end

		-- leader?
		if (info.role == Enum.ClubRoleIdentifier.Leader) then
			-- leader
			NS.db.global.members[player].leader = true
		end

		-- moderator?
		if (info.role == Enum.ClubRoleIdentifier.Moderator) then
			-- leader
			NS.db.global.members[player].moderator = true
		end

		-- update first seen
		NS:Update_First_Seen(player)
	end

	-- process member guid
	NS:Process_MemberGUID(info.guid, player)

	-- rebuild leaders?
	if (rebuild == true) then
		-- rebuild community leaders
		NS:Rebuild_Community_Leaders()
	end
end

-- remove member
function NS:Remove_Member(clubId, info)
	-- build proper name
	local player = info.name
	if (not strmatch(player, "-")) then
		-- get player info by guid
		local name, realm = select(6, GetPlayerInfoByGUID(info.guid))
		if (name and realm and (realm ~= "")) then
			-- rebuild full
			player = name .. "-" .. realm
		else
			-- add realm name
			player = player .. "-" .. NS.CommFlare.CF.PlayerServerName
		end
	end

	-- member exists?
	if (NS.db.global.members[player]) then
		-- empty?
		if (not NS.db.global.members[player].clubs) then
			-- initialize
			NS.db.global.members[player].clubs = {}
		end
		if (not NS.db.global.members[player].clubs[clubId]) then
			-- initialize
			NS.db.global.members[player].clubs[clubId] = {}
		end

		-- valid club?
		if (NS.db.global.members[player].clubs and NS.db.global.members[player].clubs[clubId]) then
			-- clear
			NS.db.global.members[player].clubs[clubId] = nil

			-- process all clubs
			local count = 0
			for k,v in pairs(NS.db.global.members[player].clubs) do
				-- increase
				count = count + 1
			end

			-- none left?
			if (count == 0) then
				-- delete
				NS.db.global.members[player] = nil
				return true
			end
		end
	end

	-- not found
	return false
end

-- add all club members from club id
function NS:Add_All_Club_Members_By_ClubID(clubId)
	-- has guild?
	if (not clubId) then
		-- not in guild
		print(L["You are not currently in a Guild."])
		return
	end

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
				NS:Add_Member(clubId, mi, false)

				-- increase
				added = added + 1
			end
		end

		-- rebuild community leaders
		NS:Rebuild_Community_Leaders()

		-- guild?
		if (info.clubType == Enum.ClubType.Guild) then
			-- add guild
			info.name = strformat("%s (Guild)", info.name)
		end

		-- any added?
		if (added > 0) then
			-- display amount added
			print(strformat(L["%s: Added %d %s members to the database."], NS.CommFlare.Title, added, info.name))
		end
	end
end

-- remove all club members from club id
function NS:Remove_All_Club_Members_By_ClubID(clubId)
	-- get club info
	local info = ClubGetClubInfo(clubId)
	if (info and info.name and (info.name ~= "")) then
		-- process all members
		local removed = 0
		for k,v in pairs(NS.db.global.members) do
			-- valid club?
			if (NS.db.global.members[k].clubs and NS.db.global.members[k].clubs[clubId]) then
				-- clear
				NS.db.global.members[k].clubs[clubId] = nil
			end

			-- any clubs?
			local count = 0
			if (NS.db.global.members[k].clubs and next(NS.db.global.members[k].clubs)) then
				-- process all clubs
				for k2,v2 in pairs(NS.db.global.members[k].clubs) do
					-- increase
					count = count + 1
				end
			end

			-- none left?
			if (count == 0) then
				-- remove
				NS.db.global.members[k] = nil

				-- increase
				removed = removed + 1
			end
		end

		-- rebuild community leaders
		NS:Rebuild_Community_Leaders()

		-- guild?
		if (info.clubType == Enum.ClubType.Guild) then
			-- add guild
			info.name = strformat("%s (Guild)", info.name)
		end

		-- any removed?
		if (removed > 0) then
			-- display amount removed
			print(strformat(L["%s: Removed %d %s members from the database."], NS.CommFlare.Title, removed, info.name))
		end
	end
end

-- update statistics for members
function NS:Update_Member_Statistics(type)
	-- process all members found
	for k,v in ipairs(NS.CommFlare.CF.CommNamesList) do
		-- found member?
		if (NS.db.global.members[v]) then
			-- match complete?
			if (type == "completed") then
				-- update completed matches
				NS:Update_Completed_Matches(v)
			else
				-- update grouped matches
				NS:Update_Grouped_Matches(v)

				-- update last grouped
				NS:Update_Last_Grouped(v)
			end
		end
	end
end

-- update member database
function NS:Update_Club_Members(clubId, type)
	-- adding?
	if (type == true) then
		-- add all club members
		NS:Add_All_Club_Members_By_ClubID(clubId)
	else
		-- remove all club members
		NS:Remove_All_Club_Members_By_ClubID(clubId)
	end
end

-- process club members
function NS:Process_Club_Members()
	-- get clubs list
	local clubs = NS:Get_Clubs_List(false)
	if (not clubs) then
		-- no subscribed clubs found
		return false
	end

	-- process clubs
	for _,clubId in ipairs(clubs) do
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

				-- process all members
				local members = ClubGetClubMembers(clubId)
				for k,v in ipairs(members) do
					local mi = ClubGetMemberInfo(clubId, v)
					if ((mi ~= nil) and (mi.name ~= nil)) then
						-- add member
						NS:Add_Member(clubId, mi, false)
					end

					-- online?
					if (mi.presence == Enum.ClubMemberPresence.Online) then
						-- get community member
						local member = NS:Get_Community_Member(mi.name)
						if (member ~= nil) then
							-- update last seen
							NS:Update_Last_Seen(member.name)
						end
					end
				end
			end
		end
	end

	-- rebuild community leaders
	NS:Rebuild_Community_Leaders()
	return true
end

-- refresh club members
function NS:Refresh_Club_Members()
	-- update invisible status
	NS.CommFlare.CF.Invisible = NS:IsInvisible()

	-- process club members
	local status = NS:Process_Club_Members()
	if (status == false) then
		-- finished
		return
	end

	-- find player in database
	local player = NS:GetPlayerName("full")
	local member = NS:Get_Community_Member(player)
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
			NS:Remove_All_Club_Members_By_ClubID(k)

			-- add all club members
			NS:Add_All_Club_Members_By_ClubID(k)
		end

		-- save refresh date
		NS.charDB.profile.communityRefreshed = time()
	end

	-- setup days purged
	local days_purged = 7
	if (NS.db.global.purgeLogTime == 2) then
		-- 14 days
		days_purged = 14
	elseif (NS.db.global.purgeLogTime == 3) then
		-- 30 days
		days_purged = 30
	end

	-- purge older
	local timestamp = time()
	for k,v in pairs(NS.db.global.matchLogList) do
		-- older found?
		if (not v.timestamp or (k > 1000000)) then
			-- delete
			NS.db.global.matchLogList[k] = nil
		else
			-- older than x days?
			local older = v.timestamp + (days_purged * 86400)
			if (timestamp > older) then
				-- delete
				NS.db.global.matchLogList[k] = nil
			end
		end
	end

	-- clean up members
	NS:Cleanup_Members()

	-- clean up history
	NS:Cleanup_History()
end

-- club member added
function NS:Club_Member_Added(clubId, memberId)
	-- get member info
	NS.CommFlare.CF.MemberInfo = ClubGetMemberInfo(clubId, memberId)
	if (NS.CommFlare.CF.MemberInfo ~= nil) then
		-- found community info?
		local info = ClubGetClubInfo(clubId)
		if (info and info.name) then
			-- name not found?
			if (not NS.CommFlare.CF.MemberInfo.name) then
				-- try again, 2 seconds later
				TimerAfter(2, function()
					-- get member info
					NS.CommFlare.CF.MemberInfo = ClubGetMemberInfo(clubId, memberId)

					-- name not found?
					if ((NS.CommFlare.CF.MemberInfo ~= nil) and (NS.CommFlare.CF.MemberInfo.name ~= nil)) then
						-- guild?
						if (info.clubType == Enum.ClubType.Guild) then
							-- display
							print(strformat(L["%s: %s (%d, %d) added to guild %s."], NS.CommFlare.Title, NS.CommFlare.CF.MemberInfo.name, clubId, memberId, info.name))
						else
							-- display
							print(strformat(L["%s: %s (%d, %d) added to community %s."], NS.CommFlare.Title, NS.CommFlare.CF.MemberInfo.name, clubId, memberId, info.name))
						end

						-- add member
						NS:Add_Member(clubId, NS.CommFlare.CF.MemberInfo, true)
					end
				end)
			else
				-- display
				print(strformat(L["%s: %s (%d, %d) added to community %s."], NS.CommFlare.Title, NS.CommFlare.CF.MemberInfo.name, clubId, memberId, info.name))

				-- add member
				NS:Add_Member(clubId, NS.CommFlare.CF.MemberInfo, true)
			end
		end
	end
end

-- club member removed
function NS:Club_Member_Removed(clubId, memberId)
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
			-- get player info by guid
			local name, realm = select(6, GetPlayerInfoByGUID(NS.CommFlare.CF.MemberInfo.guid))
			if (name and realm and (realm ~= "")) then
				-- rebuild full
				player = name .. "-" .. realm
			else
				-- add realm name
				player = player .. "-" .. NS.CommFlare.CF.PlayerServerName
			end
		end

		-- has clubs?
		if (NS.db.global.members[player] and NS.db.global.members[player].clubs) then
			-- process all
			local count = 0
			for k,v in pairs(NS.db.global.members[player].clubs) do
				-- matches?
				if (k == clubId) then
					-- delete club
					NS.db.global.members[player].clubs[k] = nil
				else
					-- increase
					count = count + 1
				end
			end

			-- no clubs left?
			if (count == 0) then
				-- delete member
				NS.db.global.members[player] = nil
			end
		end

		-- found community info?
		local info = ClubGetClubInfo(clubId)
		if (info and info.name) then
			-- found member name?
			if (NS.CommFlare.CF.MemberInfo.name ~= nil) then
				-- guild?
				if (info.clubType == Enum.ClubType.Guild) then
					-- display
					print(strformat(L["%s: %s (%d, %d) removed from guild %s."], NS.CommFlare.Title, player, clubId, memberId, info.name))
				else
					-- display
					print(strformat(L["%s: %s (%d, %d) removed from community %s."], NS.CommFlare.Title, player, clubId, memberId, info.name))
				end
			end
		end
	end
end

-- club member updated
function NS:Club_Member_Updated(clubId, memberId)
	-- get member info
	NS.CommFlare.CF.MemberInfo = ClubGetMemberInfo(clubId, memberId)
	if (NS.CommFlare.CF.MemberInfo and NS.CommFlare.CF.MemberInfo.name and (NS.CommFlare.CF.MemberInfo.name ~= "")) then
		-- build proper name
		local player = NS.CommFlare.CF.MemberInfo.name
		if (not strmatch(player, "-")) then
			-- get player info by guid
			local name, realm = select(6, GetPlayerInfoByGUID(NS.CommFlare.CF.MemberInfo.guid))
			if (name and realm and (realm ~= "")) then
				-- rebuild full
				player = name .. "-" .. realm
			else
				-- add realm name
				player = player .. "-" .. NS.CommFlare.CF.PlayerServerName
			end
		end

		-- member exists?
		if (NS.db.global.members[player]) then
			-- no priority?
			if (not NS.db.global.members[player].priority) then
				-- save default priority
				NS.db.global.members[player].priority = 999
			end

			-- valid club?
			local rebuild = false
			if (NS.db.global.members[player].clubs and NS.db.global.members[player].clubs[clubId]) then
				-- role updated?
				if (not NS.db.global.members[player].clubs[clubId].role or (NS.db.global.members[player].clubs[clubId].role ~= NS.CommFlare.CF.MemberInfo.role)) then
					-- update role
					NS.db.global.members[player].clubs[clubId].role = NS.CommFlare.CF.MemberInfo.role

					-- rebuild
					rebuild = true
				end

				-- member note updated?
				if (not NS.db.global.members[player].clubs[clubId].memberNote or (NS.db.global.members[player].clubs[clubId].memberNote ~= NS.CommFlare.CF.MemberInfo.memberNote)) then
					-- update member note
					NS.db.global.members[player].clubs[clubId].memberNote = NS.CommFlare.CF.MemberInfo.memberNote
				end

				-- priority updated?
				local priority = NS:Get_Member_Priority(NS.CommFlare.CF.MemberInfo)
				if (not NS.db.global.members[player].clubs[clubId].priority or (NS.db.global.members[player].clubs[clubId].priority ~= priority)) then
					-- update priority
					NS.db.global.members[player].clubs[clubId].priority = priority

					-- find lowest priority
					local lowest = 999
					for k,v in pairs(NS.db.global.members[player].clubs) do
						-- higher priority (lesser number)?
						if (v.priority and (v.priority > 0) and (v.priority < lowest)) then
							-- update lowest
							lowest = v.priority
						end
					end

					-- update player priority?
					if (NS.db.global.members[player].priority ~= lowest) then
						-- update priority
						NS.db.global.members[player].priority = lowest

						-- rebuild
						rebuild = true
					end
				end
			end

			-- rebuild leaders?
			if (rebuild == true) then
				-- rebuild community leaders
				NS:Rebuild_Community_Leaders()
			end
		end
	end
end

-- find community members who left?
function NS:Find_ExCommunity_Members(clubId)
	local count = 0
	local current = {}
	local members = ClubGetClubMembers(clubId)
	for _,v in ipairs(members) do
		local info = ClubGetMemberInfo(clubId, v)
		if ((info ~= nil) and (info.guid ~= nil) and (info.name ~= nil)) then
			-- build proper name
			local player = info.name
			if (not strmatch(player, "-")) then
				-- get player info by guid
				local name, realm = select(6, GetPlayerInfoByGUID(info.guid))
				if (name and realm and (realm ~= "")) then
					-- rebuild full
					player = name .. "-" .. realm
				else
					-- add realm name
					player = player .. "-" .. NS.CommFlare.CF.PlayerServerName
				end
			end

			-- add to current
			current[player] = info
		end
	end

	-- process all
	local removed = {}
	for k,v in pairs(NS.db.global.members) do
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
	NS.db.global.removed = removed

	-- wipe old
	wipe(current)

	-- display count
	print(strformat(L["Count: %d"], count))
end

-- find community members
function NS:Find_Community_Members(type, clubId)
	-- process all
	local count = 0
	for k,v in pairs(NS.db.global.members) do
		-- has club membership?
		if (v.clubs and v.clubs[clubId]) then
			-- get player history?
			local history = NS:Get_Player_History(k)
			if (type == "inactive") then
				-- inactive?
				if (not history or not history.last) then
					-- display player name
					print(strformat(L["Inactive: %s"], k))
					count = count + 1
				end
			-- inactivity?
			elseif (type == "inactivity") then
				-- has last seen?
				if (history and history.last) then
					-- more than 60 days?
					if ((time() - history.last) > (60 * 86400)) then
						-- display player name / last seen
						local lastseen = date("%Y-%m-%d %H:%M:%S", history.last)
						print(strformat(L["Inactive: %s; Last Active: %s"], k, lastseen))
						count = count + 1
					end
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
function NS:Is_Community_Member(name)
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
	if (player and (player ~= "") and NS.db.global and NS.db.global.members and NS.db.global.members[player]) then
		-- success
		return true
	end

	-- failed
	return false
end

-- compare community priority
function NS:Compare_Community_Priority(player1, player2)
	-- always use full names
	player1 = NS:GetFullName(player1)
	player2 = NS:GetFullName(player2)

	-- find player1 priority
	local member1 = NS:Get_Community_Member(player1)
	if (not member1) then
		-- force max priority
		member1 = { ["priority"] = NS.CommFlare.CF.MaxPriority }
	-- no priority?
	elseif (not member1.priority or (member1.priority == 0)) then
		-- force max priority
		member1.priority = NS.CommFlare.CF.MaxPriority
	end

	-- find player2 priority
	local member2 = NS:Get_Community_Member(player2)
	if (not member2) then
		-- force max priority
		member2 = { ["priority"] = NS.CommFlare.CF.MaxPriority }
	-- no priority?
	elseif (not member2.priority or (member2.priority == 0)) then
		-- force max priority
		member2.priority = NS.CommFlare.CF.MaxPriority
	end

	-- compare priorities
	if (member1.priority < member2.priority) then
		-- higher priority
		return 1
	elseif (member1.priority > member2.priority) then
		-- lesser priority
		return -1
	end

	-- assume equal
	return 0
end

-- has shared community?
function NS:Has_Shared_Community(sender)
	-- not loaded?
	if (not NS.CommFlare or not NS.db) then
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
		sender = NS:GetBNetFriendName(sender)
		if (not sender) then
			-- failed
			return false
		end
	end

	-- find sender in database
	local member2 = NS:Get_Community_Member(sender)
	if (not member2 or not member2.clubs) then
		-- failed
		return false
	end

	-- find player in database
	local player = NS:GetPlayerName("full")
	local member1 = NS:Get_Community_Member(player)
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

-- find member by guid
function NS:Find_Community_Member_By_GUID(guid)
	-- sanity checks?
	if (not NS.CommFlare or not NS.db) then
		-- failed
		return nil
	end

	-- invalid guid?
	if (not guid or (guid == "")) then
		-- failed
		return nil
	end

	-- check inside database
	if (NS.db.global.MemberGUIDs and NS.db.global.MemberGUIDs[guid]) then
		-- check inside database
		local player = NS.db.global.MemberGUIDs[guid]
		if (player and (player ~= "") and NS.db.global and NS.db.global.members and NS.db.global.members[player]) then
			-- success
			return NS.db.global.members[player]
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
	if (player and (player ~= "") and NS.db.global and NS.db.global.members and NS.db.global.members[player]) then
		-- success
		return NS.db.global.members[player]
	end

	-- process all
	for k,v in pairs(NS.db.global.members) do
		-- matches?
		if (v.guid == guid) then
			-- success
			return v
		end
	end

	-- failed
	return nil
end
