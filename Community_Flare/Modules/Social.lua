-- initialize
local LibStub = LibStub
local ADDON_NAME, NS = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
if (not L or not NS.CommFlare) then return end

-- localize stuff
local _G                                          = _G
local GetBattlefieldStatus                        = _G.GetBattlefieldStatus
local GetBattlefieldTimeWaited                    = _G.GetBattlefieldTimeWaited
local GetMaxBattlefieldID                         = _G.GetMaxBattlefieldID
local GetNumGroupMembers                          = _G.GetNumGroupMembers
local GetPlayerInfoByGUID                         = _G.GetPlayerInfoByGUID
local IsInGroup                                   = _G.IsInGroup
local IsInRaid                                    = _G.IsInRaid
local UnitExists                                  = _G.UnitExists
local UnitGUID                                    = _G.UnitGUID
local UnitName                                    = _G.UnitName
local SocialQueueGetGroupInfo                     = _G.C_SocialQueue.GetGroupInfo
local SocialQueueGetGroupMembers                  = _G.C_SocialQueue.GetGroupMembers
local SocialQueueGetGroupQueues                   = _G.C_SocialQueue.GetGroupQueues
local TimerAfter                                  = _G.C_Timer.After
local ipairs                                      = _G.ipairs
local pairs                                       = _G.pairs
local print                                       = _G.print
local select                                      = _G.select
local time                                        = _G.time
local mfloor                                      = _G.math.floor
local strformat                                   = _G.string.format

-- initialize group
function NS:Initialize_Group(groupGUID)
	-- initialize
	NS.CommFlare.CF.SocialQueues[groupGUID] = {
		guid = "",
		created = 0,
		popped = 0,
		numQueues = 0,
		leader = nil,
		members = {},
		queues = {},
		stale = false,
	}
end

-- add group leader
function NS:Add_Group_Leader(groupGUID, playerGUID, playerName, playerRealm)
	-- invalid realm?
	if (not playerRealm or (playerRealm == "")) then
		playerRealm = NS.CommFlare.CF.PlayerServerName
	end

	-- set leader
	NS.CommFlare.CF.SocialQueues[groupGUID].leader = {}
	NS.CommFlare.CF.SocialQueues[groupGUID].leader.guid = playerGUID
	NS.CommFlare.CF.SocialQueues[groupGUID].leader.name = playerName
	NS.CommFlare.CF.SocialQueues[groupGUID].leader.realm = playerRealm
end

-- add group member
function NS:Add_Group_Member(groupGUID, index, playerGUID, playerName, playerRealm)
	-- invalid realm?
	if (not playerRealm or (playerRealm == "")) then
		playerRealm = NS.CommFlare.CF.PlayerServerName
	end

	-- set member
	NS.CommFlare.CF.SocialQueues[groupGUID].members[index] = {}
	NS.CommFlare.CF.SocialQueues[groupGUID].members[index].guid = playerGUID
	NS.CommFlare.CF.SocialQueues[groupGUID].members[index].name = playerName
	NS.CommFlare.CF.SocialQueues[groupGUID].members[index].realm = playerRealm
end

-- has queue popped?
function NS:HasQueuePopped(groupGUID)
	-- community queue exists?
	if (NS.CommFlare.CF.SocialQueues[groupGUID]) then
		-- popped?
		if (NS.CommFlare.CF.SocialQueues[groupGUID].popped > 0) then
			-- popped
			return true
		end
	end

	-- not popped
	return false
end

-- clean up groups
function NS:Cleanup_Groups()
	-- process all
	for k,v in pairs(NS.CommFlare.CF.SocialQueues) do
		-- local?
		if (k == "local") then
			-- update local group
			NS:Update_Group("local")
		else
			-- queue exists?
			if (NS.CommFlare.CF.SocialQueues[k]) then
				-- check for queues
				local queues = SocialQueueGetGroupQueues(k)
				if (not queues) then
					-- clear social queue 30 seconds later
					NS.CommFlare.CF.SocialQueues[k].stale = true
					TimerAfter(30, function()
						-- group has no queues
						NS.CommFlare.CF.SocialQueues[k] = nil
					end)
				end
			end
		end
	end
end

-- process popped
function NS:Process_Popped(groupGUID)
	-- setup stuff
	local popped = NS.CommFlare.CF.SocialQueues[groupGUID].popped
	local members = NS.CommFlare.CF.SocialQueues[groupGUID].members

	-- add popped grouped members
	local index = popped - (popped % 3)
	if (not NS.CommFlare.CF.PoppedGroups[index]) then
		-- initialize
		NS.CommFlare.CF.PoppedGroups[index] = 0
	end

	-- add member count
	NS.CommFlare.CF.PoppedGroups[index] = NS.CommFlare.CF.PoppedGroups[index] + #members

	-- timer activated?
	if (NS.CommFlare.CF.Popped ~= true) then
		-- set popped
		NS.CommFlare.CF.Popped = true

		-- display results in 2.5 seconds
		local mapName = NS.CommFlare.CF.SocialQueues[groupGUID].name
		TimerAfter(2.5, function()
			-- process all
			local count = 0
			local index = 1
			for k,v in pairs(NS.CommFlare.CF.PoppedGroups) do
				-- display popped group totals?
				if (NS.db.global.displayPoppedGroups == true) then
					-- print group / member totals
					print(strformat("%s: Group%d = %d Members", L["POPPED"], index, v))
				end

				-- next
				count = count + v
				index = index + 1
			end

			-- reset
			NS.CommFlare.CF.PoppedGroups = {}
			NS.CommFlare.CF.Popped = false

			-- clean up groups
			NS:Cleanup_Groups()
		end)
	end
end

-- update group
function NS:Update_Group(groupGUID)
	-- no group id?
	if (not groupGUID) then
		-- finished
		return
	end

	-- local?
	if (groupGUID == "local") then
		-- no local group?
		if (not NS.CommFlare.CF.SocialQueues[groupGUID]) then
			-- initialize
			NS:Initialize_Group(groupGUID)
		end

		-- check if currently in queue
		local seconds = 0
		local numQueues = 0
		local numTrackedQueues = 0
		for i=1, GetMaxBattlefieldID() do
			-- trackable?
			local status, mapName = GetBattlefieldStatus(i)
			local isTracked, isEpicBattleground, isRandomBattleground, isBrawl = NS:IsTrackedPVP(mapName)
			if (isTracked == true) then
				-- update queue
				NS.CommFlare.CF.SocialQueues[groupGUID].queues[i] = {
					["name"] = mapName,
					["status"] = status,
				}

				-- get time in queue
				local msecs = GetBattlefieldTimeWaited(i)
				seconds = mfloor(msecs / 1000)

				-- increase
				numTrackedQueues = numTrackedQueues + 1
			end

			-- increase
			numQueues = numQueues + 1
		end

		-- no tracked queues?
		if (numTrackedQueues == 0) then
			-- initialize
			NS:Initialize_Group(groupGUID)
			return
		end

		-- update local queue
		NS.CommFlare.CF.SocialQueues[groupGUID].guid = groupGUID
		NS.CommFlare.CF.SocialQueues[groupGUID].numQueues = numQueues
		NS.CommFlare.CF.SocialQueues[groupGUID].numTrackedQueues = numTrackedQueues
		if (NS.CommFlare.CF.SocialQueues[groupGUID].created == 0) then
			-- save created
			NS.CommFlare.CF.SocialQueues[groupGUID].created = time() - seconds
		end

		-- always at least 1
		local count = 1
		if (IsInGroup()) then
			if (not IsInRaid()) then
				-- update count
				count = GetNumGroupMembers()
			end
		end

		-- only yourself?
		if (count == 1) then
			-- add leader + member
			local playerGUID = UnitGUID("player")
			local playerName, playerRealm = UnitName("player")
			NS.CommFlare.CF.SocialQueues[groupGUID].numMembers = 1
			NS:Add_Group_Leader(groupGUID, playerGUID, playerName, playerRealm)
			NS:Add_Group_Member(groupGUID, 1, playerGUID, playerName, playerRealm)
		else
			-- process all members
			NS.CommFlare.CF.SocialQueues[groupGUID].members = {}
			NS.CommFlare.CF.SocialQueues[groupGUID].numMembers = GetNumGroupMembers()
			for i=1, GetNumGroupMembers() do
				-- unit exists?
				local unit = ""
				if (UnitExists("party" .. i)) then
					-- partyX
					unit = "party" .. i
				else
					-- player
					unit = "player"
				end

				-- party leader?
				local playerGUID = UnitGUID(unit)
				local playerName, playerRealm = UnitName(unit)
				if (UnitIsGroupLeader(unit)) then
					-- add leader
					NS:Add_Group_Leader(groupGUID, playerGUID, playerName, playerRealm)
				end

				-- add member
				NS:Add_Group_Member(groupGUID, i, playerGUID, playerName, playerRealm)
			end
		end
	else
		-- no leader detected?
		local canJoin, _, _, _, _, isSoloQueueParty, _, leaderGUID = SocialQueueGetGroupInfo(groupGUID)
		if (not leaderGUID) then
			-- clear group
			NS.CommFlare.CF.SocialQueues[groupGUID] = nil
			return
		end

		-- get leader name / realm
		local leaderName, leaderRealm = select(6, GetPlayerInfoByGUID(leaderGUID))
		if (not leaderName) then
			-- display results in 1.5 seconds
			TimerAfter(1.5, function()
				-- try again
				NS:Update_Group(groupGUID)
			end)

			-- clear group
			NS.CommFlare.CF.SocialQueues[groupGUID] = nil
			return
		end

		-- no realm detected?
		if (not leaderRealm or (leaderRealm == "")) then
			leaderRealm = NS.CommFlare.CF.PlayerServerName
		end

		-- process current queues
		local numQueues = 0
		local CurrentQueues = {}
		local mapName = L["N/A"]
		local numTrackedQueues = 0
		local queues = SocialQueueGetGroupQueues(groupGUID)
		if (queues and (#queues > 0)) then
			-- process all queues
			for i=1, #queues do
				-- tracked map?
				mapName = queues[i].queueData.mapName
				local isTracked, isEpicBattleground, isRandomBattleground, isBrawl = NS:IsTrackedPVP(mapName)
				if (isTracked == true) then
					-- increase
					numTrackedQueues = numTrackedQueues + 1

					-- add to current queues
					CurrentQueues[mapName] = true
				end

				-- increase
				numQueues = numQueues + 1
			end
		end

		-- not previously in queue?
		local leader = strformat("%s-%s", leaderName, leaderRealm)
		if (not NS.CommFlare.CF.SocialQueues[groupGUID]) then
			-- any trackable queues?
			if (numTrackedQueues > 0) then
				-- create
				NS:Initialize_Group(groupGUID)
				NS.CommFlare.CF.SocialQueues[groupGUID].guid = groupGUID
				NS.CommFlare.CF.SocialQueues[groupGUID].created = time()
				NS.CommFlare.CF.SocialQueues[groupGUID].numQueues = numQueues
				NS.CommFlare.CF.SocialQueues[groupGUID].numTrackedQueues = numTrackedQueues

				-- has leader info?
				if (leaderGUID and leaderName and leaderRealm) then
					-- add leader
					NS:Add_Group_Leader(groupGUID, leaderGUID, leaderName, leaderRealm)
				end
			end
		-- created / not popped?
		elseif ((NS.CommFlare.CF.SocialQueues[groupGUID].created > 0) and (NS.CommFlare.CF.SocialQueues[groupGUID].popped == 0)) then
			-- update queue counts
			NS.CommFlare.CF.SocialQueues[groupGUID].numQueues = numQueues
			NS.CommFlare.CF.SocialQueues[groupGUID].numTrackedQueues = numTrackedQueues

			-- popped?
			if ((numQueues == 0) or (numTrackedQueues < NS.CommFlare.CF.SocialQueues[groupGUID].numTrackedQueues)) then
				-- popped
				NS:Add_Group_Leader(groupGUID, leaderGUID, leaderName, leaderRealm)
				NS.CommFlare.CF.SocialQueues[groupGUID].popped = time()

				-- process all queues
				for k,v in ipairs(NS.CommFlare.CF.SocialQueues[groupGUID].queues) do
					-- not in current queues?
					local mapName = v.queueData.mapName
					if (mapName and not CurrentQueues[mapName]) then
						-- save map name
						NS.CommFlare.CF.SocialQueues[groupGUID].name = mapName
					end
				end

				-- process popped
				NS:Process_Popped(groupGUID)
			end
		-- popped?
		elseif (NS:HasQueuePopped(groupGUID)) then
			-- no trackable queues?
			if (numTrackedQueues == 0) then
				-- clear group
				NS.CommFlare.CF.SocialQueues[groupGUID] = nil
				return
			end
		end

		-- still has group?
		if (NS.CommFlare.CF.SocialQueues[groupGUID]) then
			-- save queues
			NS.CommFlare.CF.SocialQueues[groupGUID].queues = queues

			-- no leader yet?
			if (not NS.CommFlare.CF.SocialQueues[groupGUID].leader) then
				-- has leader info?
				if (leaderGUID and leaderName and leaderRealm) then
					-- add leader
					NS:Add_Group_Leader(groupGUID, leaderGUID, leaderName, leaderRealm)
				end
			-- leader changed?
			elseif (NS.CommFlare.CF.SocialQueues[groupGUID].leader.guid ~= leaderGUID) then
				-- update leader
				NS:Add_Group_Leader(groupGUID, leaderGUID, leaderName, leaderRealm)
			end

			-- has group members?
			local members = SocialQueueGetGroupMembers(groupGUID)
			if (members and (#members > 0)) then
				-- process all members
				NS.CommFlare.CF.SocialQueues[groupGUID].members = {}
				NS.CommFlare.CF.SocialQueues[groupGUID].numMembers = #members
				for i=1, #members do
					-- get player info
					local playerGUID = members[i].guid
					local playerName, playerRealm = select(6, GetPlayerInfoByGUID(playerGUID))
					if (playerName) then
						-- has no player realm?
						if (not playerRealm or (playerRealm == "")) then
							playerRealm = NS.CommFlare.CF.PlayerServerName
						end

						-- add group member
						NS:Add_Group_Member(groupGUID, i, playerGUID, playerName, playerRealm)
					end
				end
			else
				-- group no longer exists
				NS.CommFlare.CF.SocialQueues[groupGUID] = nil
			end
		end
	end
end
