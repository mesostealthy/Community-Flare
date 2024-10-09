-- initialize
local LibStub = LibStub
local ADDON_NAME, NS = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
if (not L or not NS.CommFlare) then return end

-- localize stuff
local _G                                        = _G
local GetNumGroupMembers                        = _G.GetNumGroupMembers
local GetNumSubgroupMembers                     = _G.GetNumSubgroupMembers
local GetRaidRosterInfo                         = _G.GetRaidRosterInfo
local IsInGroup                                 = _G.IsInGroup
local IsInRaid                                  = _G.IsInRaid
local RequestBattlefieldScoreData               = _G.RequestBattlefieldScoreData
local SetBattlefieldScoreFaction                = _G.SetBattlefieldScoreFaction
local UnitFactionGroup                          = _G.UnitFactionGroup
local UnitGUID                                  = _G.UnitGUID
local UnitName                                  = _G.UnitName
local ClubGetClubMembers                        = _G.C_Club.GetClubMembers
local ClubGetMemberInfo                         = _G.C_Club.GetMemberInfo
local ClubGetSubscribedClubs                    = _G.C_Club.GetSubscribedClubs
local PvPIsBattleground                         = _G.C_PvP.IsBattleground
local PvPIsRatedBattleground                    = _G.C_PvP.IsRatedBattleground
local PvPIsRatedSoloRBG                         = _G.C_PvP.IsRatedSoloRBG
local PvPIsInBrawl                              = _G.C_PvP.IsInBrawl
local TimerAfter                                = _G.C_Timer.After
local date                                      = _G.date
local ipairs                                    = _G.ipairs
local pairs                                     = _G.pairs
local print                                     = _G.print
local time                                      = _G.time
local tonumber                                  = _G.tonumber
local tostring                                  = _G.tostring
local type                                      = _G.type
local strformat                                 = _G.string.format
local strlen                                    = _G.string.len
local strlower                                  = _G.string.lower
local strmatch                                  = _G.string.match
local strsplit                                  = _G.string.split
local tinsert                                   = _G.table.insert
local tsort                                     = _G.table.sort

-- get clubs
function NS:Get_Clubs_Text()
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
	-- is battleground?
	local type = nil
	local leaders = {}
	if (PvPIsBattleground() == true) then
		-- battleground
		type = "Battleground"
	-- is rated battleground?
	elseif (PvPIsRatedBattleground() == true) then
		-- rated battleground
		type = "Rated Battleground"
	-- is rated solo battleground?
	elseif (PvPIsRatedSoloRBG() == true) then
		-- rated solo battleground
		type = "Rated Solo Battleground"
	-- is brawl?
	elseif (PvPIsInBrawl() == true) then
		-- brawl
		type = "Brawl"
	end

	-- not in battleground / brawl?
	if (not type) then
		-- process all leaders
		type = "Community"
		for _,v in ipairs(NS.CommFlare.CF.CommunityLeaders) do
			-- insert
			tinsert(leaders, v)
		end
	else
		-- process all raid members
		for i=1, MAX_RAID_MEMBERS do
			-- get player / rank
			local player, rank = GetRaidRosterInfo(i)
			if (player and rank and (player ~= "")) then
				-- force name-realm format
				if (not strmatch(player, "-")) then
					-- add realm name
					player = player .. "-" .. NS.CommFlare.CF.PlayerServerName
				end

				-- leader or assistant?
				if (rank > 0) then
					-- add rank
					player = strformat("%s:%d", player, tonumber(rank))

					-- insert
					tinsert(leaders, player)
				end
			end
		end
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
	for i=1, GetNumGroupMembers(LE_PARTY_CATEGORY_HOME) do
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
		-- in battleground?
		local timer = 0.0
		if (NS:IsInBattleground() == true) then
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
		-- in battleground?
		local timer = 0.0
		if (NS:IsInBattleground() == true) then
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
