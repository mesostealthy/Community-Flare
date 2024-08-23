local LibStub = LibStub
local ADDON_NAME, NS = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)

-- localize stuff
local _G                                        = _G
local GetBattlefieldEstimatedWaitTime           = _G.GetBattlefieldEstimatedWaitTime
local GetBattlefieldInstanceRunTime             = _G.GetBattlefieldInstanceRunTime
local GetBattlefieldPortExpiration              = _G.GetBattlefieldPortExpiration
local GetBattlefieldStatus                      = _G.GetBattlefieldStatus
local GetBattlefieldTimeWaited                  = _G.GetBattlefieldTimeWaited
local GetMaxBattlefieldID                       = _G.GetMaxBattlefieldID
local GetNumGroupMembers                        = _G.GetNumGroupMembers
local GetNumSubgroupMembers                     = _G.GetNumSubgroupMembers
local GetPlayerInfoByGUID                       = _G.GetPlayerInfoByGUID
local GetRaidRosterInfo                         = _G.GetRaidRosterInfo
local IsInGroup                                 = _G.IsInGroup
local IsInRaid                                  = _G.IsInRaid
local RequestBattlefieldScoreData               = _G.RequestBattlefieldScoreData
local SetBattlefieldScoreFaction                = _G.SetBattlefieldScoreFaction
local UnitGUID                                  = _G.UnitGUID
local UnitName                                  = _G.UnitName
local ClubGetClubMembers                        = _G.C_Club.GetClubMembers
local ClubGetMemberInfo                         = _G.C_Club.GetMemberInfo
local ClubGetSubscribedClubs                    = _G.C_Club.GetSubscribedClubs
local MapGetBestMapForUnit                      = _G.C_Map.GetBestMapForUnit
local MapGetMapInfo                             = _G.C_Map.GetMapInfo
local PvPGetActiveMatchDuration                 = _G.C_PvP.GetActiveMatchDuration
local PvPIsBattleground                         = _G.C_PvP.IsBattleground
local SocialQueueGetGroupForPlayer              = _G.C_SocialQueue.GetGroupForPlayer
local SocialQueueGetGroupInfo                   = _G.C_SocialQueue.GetGroupInfo
local SocialQueueGetGroupMembers                = _G.C_SocialQueue.GetGroupMembers
local SocialQueueGetGroupQueues                 = _G.C_SocialQueue.GetGroupQueues
local TimerAfter                                = _G.C_Timer.After
local date                                      = _G.date
local ipairs                                    = _G.ipairs
local pairs                                     = _G.pairs
local print                                     = _G.print
local time                                      = _G.time
local tonumber                                  = _G.tonumber
local tostring                                  = _G.tostring
local type                                      = _G.type
local mfloor                                    = _G.math.floor
local strformat                                 = _G.string.format
local strlen                                    = _G.string.len
local strlower                                  = _G.string.lower
local strsplit                                  = _G.string.split
local tinsert                                   = _G.table.insert

-- log command
function NS:CommunityFlare_Log_Command(event, sender, text)
	-- purge older
	local timestamp = time()
	for k,v in pairs(NS.globalDB.global.commandsLog) do
		-- older found?
		if (not v.timestamp or (k > 1000000)) then
			-- delete
			NS.globalDB.global.commandsLog[k] = nil
		else
			-- older than 7 days?
			local older = v.timestamp + (7 * 86400)
			if (timestamp > older) then
				-- delete
				NS.globalDB.global.commandsLog[k] = nil
			end
		end
	end

	-- Battle.NET?
	if (type(sender) == "number") then
		-- get from battle net
		sender = NS:GetBNetFriendName(sender)
	-- no realm name?
	elseif (not strmatch(sender, "-")) then
		-- add realm name
		sender = sender .. "-" .. NS.CommFlare.CF.PlayerServerName
	end

	-- build entry
	local datestamp = date()
	local entry = {
		["timestamp"] = timestamp,
		["message"] = strformat("%s: %s = %s at %s", event, sender, text, datestamp),
	}

	-- insert
	tinsert(NS.globalDB.global.commandsLog, entry)
end

-- process battleground commands
function NS:Process_Battleground_Commands(event, sender, command, subcommand, result)
	-- sanity check
	if ((subcommand ~= "check") and (subcommand ~= "status")) then
		-- finished
		return true
	end

	-- check?
	if (subcommand == "check") then
		-- find active battleground
		local text = ""
		for i=1, GetMaxBattlefieldID() do
			-- has status to send?
			local status, mapName = GetBattlefieldStatus(i)
			if ((status == "active") or (status == "confirm") or (status == "queued")) then
				-- already has text?
				if (text ~= "") then
					-- add separator
					text = text .. ";"
				end

				-- active?
				if (status == "active") then
					-- add bg info
					local runtime = GetBattlefieldInstanceRunTime()
					local duration = PvPGetActiveMatchDuration() * 1000
					text = text .. strformat("A,%s,%d,%d", mapName, duration, runtime)
				-- confirm?
				elseif (status == "confirm") then
					-- add pop info
					local count = NS:GetGroupCount()
					local expiration = GetBattlefieldPortExpiration(i) * 1000
					text = text .. strformat("C,%s,%d,%s", mapName, expiration, count)
				-- queued?
				elseif (status == "queued") then
					-- add queue info
					local waited = GetBattlefieldTimeWaited(i)
					local estimated = GetBattlefieldEstimatedWaitTime(i)
					text = text .. strformat("Q,%s,%d,%d", mapName, waited, estimated)
				end
			end
		end

		-- nothing?
		if (text == "") then
			-- none
			text = "none"
		end

		-- send message
		NS:SendMessage(sender, strformat("!CF@Battleground@Status@%s", text))

		-- log command
		NS:CommunityFlare_Log_Command(event, sender, "Battleground")
	-- status?
	elseif ((subcommand == "status") and result) then
		-- Battle.NET?
		if (type(sender) == "number") then
			-- get from battle net
			sender = NS:GetBNetFriendName(sender)
		-- no realm name?
		elseif (not strmatch(sender, "-")) then
			-- add realm name
			sender = sender .. "-" .. NS.CommFlare.CF.PlayerServerName
		end

		-- none?
		if (result == "none") then
			-- display sender is not in queue
			print(strformat(L["%s: %s is not in queue."], NS.CommFlare.Title, sender))
		else
			-- split arguments
			local queues = {strsplit(";", result)}
			for k,v in ipairs(queues) do
				-- active?
				local status, mapName, arg1, arg2 = strsplit(",", v)
				if (status == "A") then
					-- calculate times
					local msecs = { tonumber(arg1), tonumber(arg2) }
					local seconds = { mfloor(msecs[1] / 1000), mfloor(msecs[2] / 1000) }
					local minutes = { mfloor(seconds[1] / 60), mfloor(seconds[2] / 60) }
					seconds[1] = seconds[1] - (minutes[1] * 60)
					seconds[2] = seconds[2] - (minutes[2] * 60)

					-- display bg info
					print(strformat(L["%s: %s is in %s for %d minutes, %d seconds. (Active Time: %d minutes, %d seconds.)"],
						NS.CommFlare.Title, sender, mapName, minutes[1], seconds[1], minutes[2], seconds[2]))
				-- confirm?
				elseif (status == "C") then
					-- calculate times
					local msecs = { tonumber(arg1) }
					local seconds = { mfloor(msecs[1] / 1000) }
					local minutes = { mfloor(seconds[1] / 60) }
					seconds[1] = seconds[1] - (minutes[1] * 60)

					-- display pop info
					print(strformat(L["%s: %s is popped for %s for %d minutes, %d seconds. (Count: %s.)"],
						NS.CommFlare.Title, sender, mapName, minutes[1], seconds[1], arg2))
				-- queued?
				elseif (status == "Q") then
					-- calculate times
					local msecs = { tonumber(arg1), tonumber(arg2) }
					local seconds = { mfloor(msecs[1] / 1000), mfloor(msecs[2] / 1000) }
					local minutes = { mfloor(seconds[1] / 60), mfloor(seconds[2] / 60) }
					seconds[1] = seconds[1] - (minutes[1] * 60)
					seconds[2] = seconds[2] - (minutes[2] * 60)

					-- display queue info
					print(strformat(L["%s: %s is queued for %s for %d minutes, %d seconds. (Estimated Wait: %d minutes, %d seconds.)"],
						NS.CommFlare.Title, sender, mapName, minutes[1], seconds[1], minutes[2], seconds[2]))
				end
			end
		end
	end

	-- finished
	return true
end

-- process deserter commands
function NS:Process_Deserter_Commands(event, sender, command, subcommand, result)
	-- sanity check
	if ((subcommand ~= "check") and (subcommand ~= "status")) then
		-- finished
		return true
	end

	-- check?
	if (subcommand == "check") then
		-- check for deserter
		NS:CheckForAura("player", "HARMFUL", L["Deserter"])
		if (NS.CommFlare.CF.HasAura == true) then
			-- send message
			NS:SendMessage(sender, strformat("!CF@Deserter@Status@%s", "true"))
		else
			-- send message
			NS:SendMessage(sender, strformat("!CF@Deserter@Status@%s", "false"))
		end

		-- log command
		NS:CommunityFlare_Log_Command(event, sender, "Deserter")
	-- status?
	elseif ((subcommand == "status") and result) then
		-- Battle.NET?
		if (type(sender) == "number") then
			-- get from battle net
			sender = NS:GetBNetFriendName(sender)
		-- no realm name?
		elseif (not strmatch(sender, "-")) then
			-- add realm name
			sender = sender .. "-" .. NS.CommFlare.CF.PlayerServerName
		end

		-- is mercenary?
		if (result == "true") then
			-- mercenary enabled
			print(strformat(L["%s: %s has the Deserter debuff."], NS.CommFlare.Title, sender))
		elseif (result == "false") then
			-- mercenary disabled
			print(strformat(L["%s: %s does not have the Deserter debuff."], NS.CommFlare.Title, sender))
		end
	end

	-- finished
	return true
end

-- process map commands
function NS:Process_Map_Commands(event, sender, command, subcommand, result)
	-- sanity check
	if ((subcommand ~= "check") and (subcommand ~= "status")) then
		-- finished
		return true
	end

	-- check?
	if (subcommand == "check") then
		-- send map info
		local mapID = MapGetBestMapForUnit("player")
		local info = MapGetMapInfo(mapID)
		NS:SendMessage(sender, strformat("!CF@Map@Status@%d,%s", mapID, info.name))

		-- log command
		NS:CommunityFlare_Log_Command(event, sender, "Map")
	-- status?
	elseif ((subcommand == "status") and result) then
		-- Battle.NET?
		if (type(sender) == "number") then
			-- get from battle net
			sender = NS:GetBNetFriendName(sender)
		-- no realm name?
		elseif (not strmatch(sender, "-")) then
			-- add realm name
			sender = sender .. "-" .. NS.CommFlare.CF.PlayerServerName
		end

		-- display map info
		local mapID, mapName = strsplit(",", result)
		print(strformat(L["%s: %s is in %s. (Map ID = %s)"], NS.CommFlare.Title, sender, mapName, mapID))
	end

	-- finished
	return true
end

-- process mercenary commands
function NS:Process_Mercenary_Commands(event, sender, command, subcommand, result)
	-- sanity check
	if ((subcommand ~= "check") and (subcommand ~= "status")) then
		-- finished
		return true
	end

	-- check?
	if (subcommand == "check") then
		-- check for mercenary buff
		NS:CheckForAura("player", "HELPFUL", L["Mercenary Contract"])
		if (NS.CommFlare.CF.HasAura == true) then
			-- send message
			NS:SendMessage(sender, strformat("!CF@Mercenary@Status@%s", "true"))
		else
			-- send message
			NS:SendMessage(sender, strformat("!CF@Mercenary@Status@%s", "false"))
		end

		-- log command
		NS:CommunityFlare_Log_Command(event, sender, "Mercenary")
	-- status?
	elseif ((subcommand == "status") and result) then
		-- Battle.NET?
		if (type(sender) == "number") then
			-- get from battle net
			sender = NS:GetBNetFriendName(sender)
		-- no realm name?
		elseif (not strmatch(sender, "-")) then
			-- add realm name
			sender = sender .. "-" .. NS.CommFlare.CF.PlayerServerName
		end

		-- is mercenary?
		if (result == "true") then
			-- mercenary enabled
			print(strformat(L["%s: %s has Mercenary Contract enabled."], NS.CommFlare.Title, sender))
		elseif (result == "false") then
			-- mercenary disabled
			print(strformat(L["%s: %s has Mercenary Contract disabled."], NS.CommFlare.Title, sender))
		end
	end

	-- finished
	return true
end

-- process party commands
function NS:Process_Party_Commands(event, sender, command, subcommand, result)
	-- sanity check
	if ((subcommand ~= "check") and (subcommand ~= "status")) then
		-- finished
		return true
	end

	-- check?
	if (subcommand == "check") then
		-- send party info
		local isRaid = IsInRaid() and "true" or "false"
		local isGroup = IsInGroup() and "true" or "false"
		local numGroupMembers = GetNumGroupMembers()
		local numSubgroupMembers = GetNumSubgroupMembers()
		NS:SendMessage(sender, strformat("!CF@Party@Status@%s,%s,%d,%d", isRaid, isGroup, numGroupMembers, numSubgroupMembers))

		-- log command
		NS:CommunityFlare_Log_Command(event, sender, "Party")
	-- status?
	elseif ((subcommand == "status") and result) then
		-- Battle.NET?
		if (type(sender) == "number") then
			-- get from battle net
			sender = NS:GetBNetFriendName(sender)
		-- no realm name?
		elseif (not strmatch(sender, "-")) then
			-- add realm name
			sender = sender .. "-" .. NS.CommFlare.CF.PlayerServerName
		end

		-- check status
		local isRaid, isGroup, numGroupMembers, numSubGroupMembers = strsplit(",", result)
		if (isRaid == "true") then
			-- raid group
			print(strformat(L["%s: %s is in raid with %d players."], NS.CommFlare.Title, sender, numGroupMembers))
		elseif (isGroup == "true") then
			-- party group
			print(strformat(L["%s: %s is in party with %d players."], NS.CommFlare.Title, sender, numGroupMembers))
		else
			-- no group
			print(strformat(L["%s: %s is not in any party or raid."], NS.CommFlare.Title, sender))
		end
 	end

	-- finished
	return true
end

-- process pop commands
function NS:Process_Pop_Commands(event, sender, command, subcommand, result)
	-- sanity check
	if ((subcommand ~= "check") and (subcommand ~= "status")) then
		-- finished
		return true
	end

	-- check?
	if (subcommand == "check") then
		-- entered queue?
		local numMembers = 0
		local action = "none"
		local queueMapName = "none"
		if (NS.CommFlare.CF.EnteredTime > 0) then
			-- entered
			action = "entered"
		-- left queue?
		elseif (NS.CommFlare.CF.LeftTime > 0) then
			-- left
			action = "left"
		else
			-- search battlefield queues
			for i=1, GetMaxBattlefieldID() do
				-- get battleground types by name
				local status, mapName = GetBattlefieldStatus(i)
				if (status ~= "none") then
					-- tracked pvp?
					local isTracked, isEpicBattleground, isRandomBattleground, isBrawl = NS:IsTrackedPVP(mapName)
					if (isTracked == true) then
						-- entered?
						if (status == "active") then
							-- entered
							queueMapName = mapName
							action = "entered"
							break
						-- popped?
						elseif (status == "confirm") then
							-- popped
							queueMapName = mapName
							action = "popped"
							break
						-- queued?
						elseif (status == "queued") then
							-- queued
							queueMapName = mapName
							action = "queued"

							-- get number of members in queue not popped
							numMembers = NS:Social_Queues_Count_All_Members_Not_Popped()
						end
					end
				end
			end
		end

		-- is player mercenary?
		local mercenary = "false"
		NS:CheckForAura("player", "HELPFUL", L["Mercenary Contract"])
		if (NS.CommFlare.CF.HasAura == true) then
			-- mercenary
			mercenary = "true"
		end

		-- has popped?
		local popped = "none"
		if (NS.CommFlare.CF.CurrentPopped["popped"]) then
			-- convert to string
			popped = tostring(NS.CommFlare.CF.CurrentPopped["popped"])
		end

		-- still in queue?
		local count = tostring(NS:GetPartyCount())
		if (action == "queued") then
			-- update count
			count = tostring(NS:Social_Queues_Count_All_Members_Not_Popped())
		-- has count?
		elseif (NS.CommFlare.CF.CurrentPopped["count"]) then
			-- convert to string
			count = tostring(NS.CommFlare.CF.CurrentPopped["count"])
		end

		-- no map name yet?
		if (queueMapName == "none") then
			-- has map name?
			if (NS.CommFlare.CF.CurrentPopped["mapName"]) then
				-- use this map name
				queueMapName = NS.CommFlare.CF.CurrentPopped["mapName"]
			end
		end

		-- send pop info
		NS:SendMessage(sender, strformat("!CF@Pop@Status@%s,%s,%s,%s,%s", action, popped, count, queueMapName, mercenary))

		-- log command
		NS:CommunityFlare_Log_Command(event, sender, "Pop")
	-- status?
	elseif ((subcommand == "status") and result) then
		-- Battle.NET?
		if (type(sender) == "number") then
			-- get from battle net
			sender = NS:GetBNetFriendName(sender)
		-- no realm name?
		elseif (not strmatch(sender, "-")) then
			-- add realm name
			sender = sender .. "-" .. NS.CommFlare.CF.PlayerServerName
		end

		-- is player mercenary?
		local action, popped, count, mapName, mercenary = strsplit(",", result)
		if (mercenary == "true") then
			-- mercenary enabled
			print(strformat(L["%s: %s has Mercenary Contract enabled."], NS.CommFlare.Title, sender))
		end

		-- entered?
		if (action == "entered") then
			-- entered popped queue
			print(strformat(L["%s: %s has entered popped queue for %s with %s members."], NS.CommFlare.Title, sender, mapName, count))
		-- left?
		elseif (action == "left") then
			-- left popped queue
			local text = strformat(L["Left Queue For Popped %s!"], mapName)
			print(strformat(L["%s: %s has left popped queue for %s with %s members."], NS.CommFlare.Title, sender, mapName, count))
		-- popped?
		elseif (action == "popped") then
			-- has queue pop
			print(strformat(L["%s: %s has queue pop for %s with %s members."], NS.CommFlare.Title, sender, mapName, count))
		-- queued?
		elseif (action == "queued") then
			-- has no queue pop
			print(strformat(L["%s: %s is still queued for %s with %s members."], NS.CommFlare.Title, sender, mapName, count))
		-- none?
		else
			-- not in queue
			print(strformat(L["%s: %s is not in queue."], NS.CommFlare.Title, sender))
		end
 	end

	-- finished
	return true
end

-- process queues commands
function NS:Process_Queues_Commands(event, sender, command, subcommand, result)
	-- sanity check
	if ((subcommand ~= "check") and (subcommand ~= "status")) then
		-- finished
		return true
	end

	-- check?
	if (subcommand == "check") then
		-- process all social queues
		local text = ""
		local lines = {}
		for k,v in pairs (NS.CommFlare.CF.SocialQueues) do
			-- has queues and members?
			if (v.numQueues and (v.numQueues > 0) and v.numMembers and (v.numMembers > 0)) then
				-- local?
				local guid = k
				if (guid == "local") then
					-- replace with player guid
					guid = UnitGUID("player")
				end

				-- get length of guid
				guid = strformat("%s,%d", guid, v.numMembers)
				local length = strlen(guid)
				local textlength = strlen(text)
				if ((length + textlength + 1) > 235) then
					-- insert line
					tinsert(lines, text)

					-- reset text
					text = strformat("%s", guid)
				else
					-- no text?
					if (text == "") then
						-- no separator
						text = strformat("%s", guid)
					else
						-- add separator
						text = strformat("%s;%s", text, guid)
					end
				end
			end
		end

		-- none found?
		if (text == "") then
			-- send queues info
			NS:SendMessage(sender, strformat("!CF@Queues@Status@none"))
		else
			-- insert last text
			tinsert(lines, text)

			-- process all lines
			local timer = 0.0
			for k,v in ipairs(lines) do
				-- throttle
				TimerAfter(timer, function()
					-- send queues info
					NS:SendMessage(sender, strformat("!CF@Queues@Status@%s", v))
				end)

				-- next
				timer = timer + 0.1
			end
		end

		-- log command
		NS:CommunityFlare_Log_Command(event, sender, "Queues")
	-- status?
	elseif ((subcommand == "status") and result) then
		-- Battle.NET?
		if (type(sender) == "number") then
			-- get from battle net
			sender = NS:GetBNetFriendName(sender)
		-- no realm name?
		elseif (not strmatch(sender, "-")) then
			-- add realm name
			sender = sender .. "-" .. NS.CommFlare.CF.PlayerServerName
		end

		-- no queues?
		if (result == "none") then
			-- no queues found
			print(strformat(L["%s: %s has no queues found."], NS.CommFlare.Title, sender))
		else
			-- split queues
			local count = 0
			local partyGUIDs = {strsplit(";", result)}
			for k,v in ipairs(partyGUIDs) do
				local groupGUID, numMembers = strsplit(",", v)
				if (v:find("Player")) then
					-- attempt to find group for player
					groupGUID = SocialQueueGetGroupForPlayer(v)
				end

				-- has group guid?
				if (groupGUID) then
					-- get queue info
					local canJoin, numQueues, _, _, _, isSoloQueueParty, _, leaderGUID = SocialQueueGetGroupInfo(groupGUID)
					if (leaderGUID) then
						-- found leader?
						local leaderName, leaderRealm = select(6, GetPlayerInfoByGUID(leaderGUID))
						if (leaderName) then
							-- no realm detected?
							if (not leaderRealm or (leaderRealm == "")) then
								leaderRealm = NS.CommFlare.CF.PlayerServerName
							end

							-- not found member count?
							if (not numMembers) then
								-- get member count
								local members = SocialQueueGetGroupMembers(groupGUID)
								numMembers = #members
								if (not numMembers) then
									-- at least 1
									numMembers = 1
								end
							end

							-- still has queues?
							local queues = SocialQueueGetGroupQueues(groupGUID)
							if (queues and (#queues > 0)) then
								-- process all queues
								for k2,v2 in ipairs(queues) do
									-- has queueData?
									if (v2.queueData and v2.queueData.mapName) then
										-- display queue info
										print(strformat(L["%s: %s has queue for %s-%s for %s with %d/5 members."],
											NS.CommFlare.Title, sender, leaderName, leaderRealm, v2.queueData.mapName, numMembers))

										-- increase
										count = count + 1
									end
								end
							end
						end
					end
				end
			end

			-- none found?
			if (count == 0) then
				-- no queues found
				print(strformat(L["%s: %s has no queues found."], NS.CommFlare.Title, sender))
			end
		end
 	end

	-- finished
	return true
end

-- process version commands
function NS:Process_Version_Commands(event, sender, command, subcommand, result)
	-- sanity check
	if ((subcommand ~= "check") and (subcommand ~= "status")) then
		-- finished
		return true
	end

	-- check?
	if (subcommand == "check") then
		-- send version info
		NS:SendMessage(sender, strformat("!CF@Version@Status@%s,%s", NS.CommFlare.Version, NS.CommFlare.Build))

		-- log command
		NS:CommunityFlare_Log_Command(event, sender, "Version")
	-- status?
	elseif ((subcommand == "status") and result) then
		-- Battle.NET?
		if (type(sender) == "number") then
			-- get from battle net
			sender = NS:GetBNetFriendName(sender)
		-- no realm name?
		elseif (not strmatch(sender, "-")) then
			-- add realm name
			sender = sender .. "-" .. NS.CommFlare.CF.PlayerServerName
		end

		-- display version info
		local version, build = strsplit(",", result)
		print(strformat(L["%s: %s has version %s (%s)"], NS.CommFlare.Title, sender, version, build))
	end

	-- finished
	return true
end

-- handle internal commands
function NS:Handle_Internal_Commands(event, sender, text, ...)
	-- no shared community?
	if (NS:Has_Shared_Community(sender) == false) then
		-- log command from non shared community sender
		NS:CommunityFlare_Log_Command(event, sender, strformat("Non Shared: %s", text))

		-- finished
		return true
	end

	-- not initialized?
	if (not NS.CommFlare.CF.InternalCommands[sender]) then
		-- initialize
		NS.CommFlare.CF.InternalCommands[sender] = {}
	end

	-- split text
	local args = {strsplit("@", text)}
	if (args and args[1] and args[2] and args[3]) then
		-- verify args[1]
		if (args[1] == "!CF") then
			-- setup command / subcommand
			local command = strlower(args[2])
			local subcommand = strlower(args[3])
			if (not subcommand) then
				-- finished
				return true
			end

			-- battleground?
			if (command == "battleground") then
				-- process battleground commands
				NS:Process_Battleground_Commands(event, sender, command, subcommand, args[4])
			-- deserter?
			elseif (command == "deserter") then
				-- process mercenary commands
				NS:Process_Deserter_Commands(event, sender, command, subcommand, args[4])
			-- map?
			elseif (command == "map") then
				-- process map commands
				NS:Process_Map_Commands(event, sender, command, subcommand, args[4])
			-- mercenary?
			elseif (command == "mercenary") then
				-- process mercenary commands
				NS:Process_Mercenary_Commands(event, sender, command, subcommand, args[4])
			-- party?
			elseif (command == "party") then
				-- process party commands
				NS:Process_Party_Commands(event, sender, command, subcommand, args[4])
			-- pop?
			elseif (command == "pop") then
				-- process pop commands
				NS:Process_Pop_Commands(event, sender, command, subcommand, args[4])
			-- queues?
			elseif (command == "queues") then
				-- process queue commands
				NS:Process_Queues_Commands(event, sender, command, subcommand, args[4])
			-- version?
			elseif (command == "version") then
				-- process version commands
				NS:Process_Version_Commands(event, sender, command, subcommand, args[4])
			end
		end
	end

	-- finished
	return true
end

-- get deserter text
function NS:Get_Deserter_Text()
	-- check for deserter buff
	local text = "false"
	NS:CheckForAura("player", "HARMFUL", L["Deserter"])
	if (NS.CommFlare.CF.HasAura == true) then
		-- has deserter
		text = "true"
	end

	-- has time left?
	if (NS.CommFlare.CF.AuraData.timeLeft) then
		-- append time left
		text = strformat("%s,%s", text, tostring(NS.CommFlare.CF.AuraData.timeLeft))
	end

	-- return text
	return text
end

-- get leaders text
function NS:Get_Leaders_Text()
	-- inside battleground?
	local leaders = {}
	local type = "Community"
	if (PvPIsBattleground() == true) then
		-- process all raid members
		for i=1, MAX_RAID_MEMBERS do
			-- force name-realm format
			local player, rank = GetRaidRosterInfo(i)
			if (not strmatch(player, "-")) then
				-- add realm name
				player = player .. "-" .. NS.CommFlare.CF.PlayerServerName
			end

			-- leader or assistant?
			if (rank and (rank > 0)) then
				-- add rank
				player = strformat("%s:%d", player, tonumber(rank))

				-- insert
				tinsert(leaders, player)
			end
		end

		-- set type
		type = "Battleground"
	end

	-- has leaders?
	if (#leaders > 0) then
		-- sort
		tsort(leaders)

		-- process all
		local text = nil
		for k,v in ipairs(leaders) do
			-- first?
			if (not text) then
				-- add first
				text = v
			else
				-- append
				text = strformat("%s;%s", text, v)
			end
		end

		-- return text
		return strformat("%s@%s", type, text)
	else
		-- none
		return strformat("%s@None", type)
	end
end

-- get members text
function NS:Get_Members_Text(senderID, input)
	-- number?
	local clubId = nil
	if (type(input) == "number") then
		-- set clubId
		clubId = tonumber(input)
	elseif (type(input) == "string") then
		-- command?
		if (input:find("!CommFlare@")) then
			-- split arguments
			local args = {strsplit(",", input)}
			if (args[2]) then
				-- update input
				input = args[2]
			end
		end

		-- process all
		local lower = strlower(input)
		for k,v in pairs(NS.globalDB.global.clubs) do
			-- matches short name?
			local shortName = strlower(v.shortName)
			if ((v.shortName == input) or (shortName == lower)) then
				-- found
				clubId = k
				break
			end

			-- matches full name?
			local fullName = strlower(v.name)
			if (fullName == lower) then
				-- found
				clubId = k
				break
			end
		end

		-- no club id found?
		if (not clubId) then
			-- count eligible communities
			NS.CommFlare.CF.Clubs = ClubGetSubscribedClubs()
			for k,v in ipairs(NS.CommFlare.CF.Clubs) do
				-- has short name?
				if (v.shortName and (v.shortName ~= "")) then
					-- matches short name?
					local shortName = strlower(v.shortName)
					if ((v.shortName == input) or (shortName == lower)) then
						-- found
						clubId = v.clubId
						break
					end
				end

				-- has full name?
				if (v.name and (v.name ~= "")) then
					-- matches full name?
					local fullName = strlower(v.name)
					if (fullName == lower) then
						-- found
						clubId = v.clubId
						break
					end
				end
			end
		end
	end

	-- no clubId?
	if (not clubId) then
		-- send data
		NS:BNSendData(senderID, strformat("!CommFlare@Members@%Invalid Club ID"))
		return
	end

	-- get club members
	local text = nil
	local members = ClubGetClubMembers(clubId)
	if (not members) then
		-- send data
		NS:BNSendData(senderID, strformat("!CommFlare@Members@%Invalid Club Members"))
		return
	end

	-- process all members
	local count = 0
	local lines = {}
	local text = strformat("ClubID:%d@", tonumber(clubId))
	for _,v in ipairs(members) do
		-- get member info
		local mi = ClubGetMemberInfo(clubId, v)
		if (mi.name and mi.guid) then
			-- no server?
			local name, realm = nil, nil
			if (strmatch(mi.name, "-")) then
				-- split
				name, realm = strsplit("-", mi.name)
			else
				-- use player server
				name = mi.name
				realm = NS.CommFlare.CF.PlayerServerName
			end

			-- found both?
			if (name and realm) then
				-- build new player
				local player = strformat("%s-%s:%s", name, realm, mi.guid)
				local playerlength = strlen(player)
				local textlength = strlen(text)
				if ((textlength + playerlength + 1) > 4032) then
					-- insert
					tinsert(lines, text)

					-- restart text
					text = strformat("ClubID:%d@%s;", tonumber(clubId), player)
				else
					-- append player
					text = strformat("%s%s;", text, player)
				end

				-- increase
				count = count + 1
			end
		end
	end

	-- still more?
	local textlength = strlen(text)
	if (textlength > 0) then
		-- insert
		tinsert(lines, text)
	end

	-- none found?
	if (count == 0) then
		-- send data
		NS:BNSendData(senderID, strformat("!CommFlare@Members@%No Club Members Found"))
	else
		-- process all
		local timer = 0.0
		for k,v in ipairs(lines) do
			-- send data
			TimerAfter(timer, function()
				-- send localized data
				NS:BNSendData(senderID, strformat("!CommFlare@Members@%s", tostring(v)))
			end)

			-- next
			timer = timer + 0.5
		end
	end
end

-- get mercenary text
function NS:Get_Mercenary_Text()
	-- check for mercenary buff
	local text = "false"
	NS:CheckForAura("player", "HELPFUL", L["Mercenary Contract"])
	if (NS.CommFlare.CF.HasAura == true) then
		-- has mercenary
		text = "true"
	end

	-- has time left?
	if (NS.CommFlare.CF.AuraData.timeLeft) then
		-- append time left
		text = strformat("%s,%s", text, tostring(NS.CommFlare.CF.AuraData.timeLeft))
	end

	-- return text
	return text
end

-- get party text
function NS:Get_Party_Text()
	-- build party info
	local text = NS:GetGroupCount()
	local isRaid = IsInRaid() and "true" or "false"
	local isGroup = IsInGroup() and "true" or "false"
	local numGroupMembers = GetNumGroupMembers()
	local numSubgroupMembers = GetNumSubgroupMembers()
	text = strformat("%s,%s,%s,%d,%d", text, isRaid, isGroup, numGroupMembers, numSubgroupMembers)

	-- process all group members
	local players = {}
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

			-- player found
			local guid = UnitGUID(unit)
			name = strformat("%s-%s;%s", name, realm, guid)
			tinsert(players, name)
		end
	end

	-- players found?
	if (#players > 0) then
		-- finalize text
		text = strformat("%s@", text)
		for k,v in ipairs(players) do
			-- not first?
			if (k > 1) then
				-- add comma
				text = strformat("%s,", text)
			end

			-- append player
			text = strformat("%s%s", text, v)				
		end
	else
		-- just you
		local name, realm = UnitName("player")
		if (not realm or (realm == "")) then
			-- get realm name
			realm = NS.CommFlare.CF.PlayerServerName
		end

		-- finalize text
		local guid = UnitGUID("player")
		text = strformat("%s@%s-%s;%s", text, name, realm, guid)
	end

	-- return text
	return text
end

-- get popped text
function NS:Get_Popped_Text()
	-- process all
	local list = {}
	for k,v in pairs (NS.CommFlare.CF.SocialQueues) do
		-- has all needed info?
		if (v.leader and v.leader.name and v.leader.realm and v.leader.guid and v.members) then
			-- popped?
			if (NS:HasQueuePopped(k)) then
				-- stale?
				local timestamp = v.popped + 30
				if (time() < timestamp) then
					-- build party string
					local count = strformat("%d/5", #v.members)
					local mapName = NS.CommFlare.CF.SocialQueues[k].name
					local text = strformat("%s,%s,%s,%s-%s,%s", mapName, k, v.leader.guid, v.leader.name, v.leader.realm, count)
					tinsert(list, text)
				else
					-- update group
					NS:Update_Group(k)
				end
			end
		end
	end

	-- process all lists
	local text = nil
	for k,v in pairs(list) do
		-- first?
		if (not text) then
			-- start queues
			text = strformat("%s", v)
		else
			-- append queues
			text = strformat("%s;%s", text, v)
		end
	end

	-- no text?
	if (not text) then
		-- none
		text = "None"
	end

	-- return text
	return text
end

-- get status text
function NS:Get_Status_Text()
	-- get battleground status
	local text = NS:Get_Battleground_Status()
	if (text) then
		-- still in queue?
		if (type(text) == "table") then
			-- process all
			local status = nil
			for k,v in pairs(text) do
				-- none yet?
				if (not status) then
					-- initialize
					status = v
				else
					-- append
					status = strformat("%s@%s", status, v)
				end
			end

			-- none found?
			if (not status) then
				-- not currently in queue
				status = L["Not currently in an epic battleground or queue!"]
			end

			-- copy status
			text = status
		end
	end

	-- return text
	return text
end

-- process battle net commands
function NS:Process_BattleNET_Commands(senderID, text)
	-- get clubs?
	if (text:find("GetClubs")) then
		-- get clubs text
		local clubs = NS:Get_Clubs_Text()
		if (clubs) then
			-- send data
			NS:BNSendData(senderID, strformat("!CommFlare@Clubs@%s", tostring(clubs)))
		end
	-- get deserter?
	elseif (text:find("GetDeserter")) then
		-- get deserter text
		local deserter = NS:Get_Deserter_Text()
		if (deserter) then
			-- send data
			NS:BNSendData(senderID, strformat("!CommFlare@Deserter@%s", tostring(deserter)))
		end
	-- get history?
	elseif (text:find("GetHistory")) then
		-- get history list text
		local history = NS:Get_History_List_Text(text)
		if (history) then
			-- send data
			NS:BNSendData(senderID, strformat("!CommFlare@History@%s", tostring(history)))
		end
	-- get leaders?
	elseif (text:find("GetLeaders")) then
		-- get leaders text
		local leaders = NS:Get_Leaders_Text()
		if (leaders) then
			-- send data
			NS:BNSendData(senderID, strformat("!CommFlare@Leaders@%s", tostring(leaders)))
		end
	-- get members?
	elseif (text:find("GetMembers")) then
		-- get members text
		NS:Get_Members_Text(senderID, text)
	-- get mercenary?
	elseif (text:find("GetMercenary")) then
		-- get mercenary text
		local mercenary = NS:Get_Mercenary_Text()
		if (mercenary) then
			-- send data
			NS:BNSendData(senderID, strformat("!CommFlare@Mercenary@%s", tostring(mercenary)))
		end
	-- get party?
	elseif (text:find("GetParty")) then
		-- get party text
		local party = NS:Get_Party_Text()
		if (party) then
			-- send data
			NS:BNSendData(senderID, strformat("!CommFlare@Party@%s", tostring(party)))
		end
	-- get pops?
	elseif (text:find("GetPopped")) then
		-- get popped text
		local popped = NS:Get_Popped_Text()
		if (popped) then
			-- send data
			NS:BNSendData(senderID, strformat("!CommFlare@Popped@%s", tostring(popped)))
		end
	-- get queues?
	elseif (text:find("GetQueues")) then
		-- refresh all social queues
		NS:RefreshAllSocialQueues()

		-- find social queues by map name
		local queues = NS:Find_Social_Queues_By_MapName(text)
		if (queues) then
			-- send data
			NS:BNSendData(senderID, strformat("!CommFlare@Queues@%s", tostring(queues)))
		end
	-- get roster?
	elseif (text:find("GetRoster")) then
		-- inside battleground?
		local timer = 0.0
		if (PvPIsBattleground() == true) then
			-- battlefield score needs updating?
			if (PVPMatchScoreboard.selectedTab ~= 1) then
				-- request battlefield score
				SetBattlefieldScoreFaction(-1)
				RequestBattlefieldScoreData()

				-- delay 0.5 seconds
				timer = 0.5
			end
		end

		-- start processing
		TimerAfter(timer, function()
			-- get current roster
			local roster = NS:Battlefield_Get_Current_Roster(text)
			if (roster) then
				-- send data
				NS:BNSendData(senderID, strformat("!CommFlare@Roster@%s", tostring(roster)))
			end
		end)
	-- get status?
	elseif (text:find("GetStatus")) then
		-- inside battleground?
		local timer = 0.0
		if (PvPIsBattleground() == true) then
			-- battlefield score needs updating?
			if (PVPMatchScoreboard.selectedTab ~= 1) then
				-- request battlefield score
				SetBattlefieldScoreFaction(-1)
				RequestBattlefieldScoreData()

				-- delay 0.5 seconds
				timer = 0.5
			end
		end

		-- start processing
		TimerAfter(timer, function()
			-- get status
			local status = NS:Get_Status_Text()
			if (status) then
				-- send data
				NS:BNSendData(senderID, strformat("!CommFlare@Status@%s", tostring(status)))
			end
		end)
	-- get version?
	elseif (text:find("GetVersion")) then
		-- send data
		NS:BNSendData(senderID, strformat("!CommFlare@Version@%s,%s", tostring(NS.CommFlare.Version), tostring(NS.CommFlare.Build)))
	end
end
