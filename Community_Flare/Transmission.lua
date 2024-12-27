-- initialize
local LibStub = LibStub
local ADDON_NAME, NS = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
if (not L or not NS.CommFlare) then return end

-- localize stuff
local _G                                        = _G
local GetNumBattlefieldScores                   = _G.GetNumBattlefieldScores
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
local ClubGetGuildClubId                        = _G.C_Club.GetGuildClubId
local ClubGetMemberInfo                         = _G.C_Club.GetMemberInfo
local ClubGetSubscribedClubs                    = _G.C_Club.GetSubscribedClubs
local PvPGetScoreInfo                           = _G.C_PvP.GetScoreInfo
local PvPIsBattleground                         = _G.C_PvP.IsBattleground
local PvPIsRatedBattleground                    = _G.C_PvP.IsRatedBattleground
local PvPIsRatedSoloRBG                         = _G.C_PvP.IsRatedSoloRBG
local PvPIsInBrawl                              = _G.C_PvP.IsInBrawl
local TimerAfter                                = _G.C_Timer.After
local date                                      = _G.date
local ipairs                                    = _G.ipairs
local next                                      = _G.next
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
function NS:Get_Clubs_Text(senderID)
	-- count eligible communities
	local count = 0
	local text = ""
	local lines = {}
	local player_faction = UnitFactionGroup("player")
	NS.CommFlare.CF.Clubs = ClubGetSubscribedClubs()
	for k,v in ipairs(NS.CommFlare.CF.Clubs) do
		-- community?
		if (v.clubType) then
			-- community / guild?
			if ((v.clubType == Enum.ClubType.Character) or (v.clubType == Enum.ClubType.Guild)) then
				-- no cross faction?
				if (v.crossFaction == nil) then
					-- assume not
					v.crossFaction = false
				end

				-- has everything?
				if (v.clubId and v.name and v.memberCount) then
					-- not cross faction?
					local faction = nil
					if (v.crossFaction == false) then
						-- assume same faction as player with club
						faction = player_faction
					end

					-- build new club
					local club = strformat("%s,%s,%s,%s,%s,%s,%s", tostring(v.clubId), tostring(v.name), tostring(v.shortName), tostring(v.memberCount), tostring(v.crossFaction), tostring(faction), tostring(v.clubType))
					local clublength = strlen(club)
					local textlength = strlen(text)
					if ((textlength + clublength + 1) > 4032) then
						-- insert
						tinsert(lines, text)

						-- restart text
						text = strformat("DB:%d@%s;", tonumber(clubId), club)
					else
						-- append club
						text = strformat("%s%s;", text, club)
					end

					-- increase
					count = count + 1

				end
			end
		end 
	end

	-- has text?
	if (text) then
		-- still more?
		local textlength = strlen(text)
		if (textlength > 0) then
			-- insert
			tinsert(lines, text)
		end
	end

	-- none found?
	if (count == 0) then
		-- none
		tinsert(lines, "None")
	end

	-- process all
	local timer = 0.0
	for k,v in ipairs(lines) do
		-- send data
		TimerAfter(timer, function()
			-- send localized data
			NS:BNSendData(senderID, strformat("!CommFlare@Clubs@%s", tostring(v)))
		end)

		-- next
		timer = timer + 0.5
	end
end

-- get deserter text
function NS:Get_Deserter_Text(senderID)
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

	-- send data
	NS:BNSendData(senderID, strformat("!CommFlare@Deserter@%s", tostring(text)))
end

-- get history list text
function NS:Get_History_List_Text(senderID, names)
	local text = nil
	local first, second = strsplit("@", names)
	if (first == "GetHistory") then
		-- multiple members?
		local members = {}
		if (strmatch(second, ",")) then
			-- get all members
			members = {strsplit(",", second)}
		else
			-- only one member
			tinsert(members, second)
		end

		-- has members?
		local list = nil
		if (members and next(members)) then
			-- process all
			list = {}
			for k,v in ipairs(members) do
				-- get player history
				local history = NS:Get_Player_History(v)
				if (history) then
					-- insert
					local firstseen = tonumber(history.first) or 0
					local lastseen = tonumber(history.last) or 0
					local lastgrouped = tonumber(history.lastgrouped) or 0
					local gmc = tonumber(history.gmc) or 0
					local cmc = tonumber(history.cmc) or 0
					local ncm = tonumber(history.ncm) or 0
					local lcmt = tonumber(history.lcmt) or 0
					tinsert(list, strformat("%s,%d,%d,%d,%d,%d,%d,%d", v, firstseen, lastseen, lastgrouped, gmc, cmc, ncm, lcmt))
				else
					-- insert
					tinsert(list, strformat("%s,nil", v))
				end
			end
		end

		-- found list?
		if (list and next(list)) then
			-- process all
			for k,v in ipairs(list) do
				-- first?
				if (not text) then
					-- initialize
					text = v
				else
					-- add text
					text = strformat("%s;%s", text, v)
				end
			end
		end
	end

	-- no text?
	if (not text) then
		-- none
		text = "None"
	end

	-- send data
	NS:BNSendData(senderID, strformat("!CommFlare@History@%s", tostring(text)))
end

-- get leaders text
function NS:Get_Leaders_Text(senderID)
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
	local text = nil
	if (#leaders == 0) then
		-- none
		text = "None"
	else
		-- sort
		tsort(leaders)

		-- process all
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
	end

	-- send data
	NS:BNSendData(senderID, strformat("!CommFlare@Leaders@%s@%s", tostring(type), tostring(text)))
end

-- get members text
function NS:Get_Members_Text(senderID, input)
	-- number?
	local clubId = nil
	if (type(input) == "number") then
		-- set clubId
		clubId = tonumber(input)
	-- string?
	elseif (type(input) == "string") then
		-- command?
		if (input:find("!CommFlare@")) then
			-- split arguments
			local args = {strsplit(",", input)}
			if (args[2]) then
				-- update input
				input = args[2]
			end
		else
			-- send data
			NS:BNSendData(senderID, strformat("!CommFlare@Members@Invalid Command"))
			return
		end

		-- no input?
		if (not input or (strlen(input) == 0)) then
			-- send data
			NS:BNSendData(senderID, strformat("!CommFlare@Members@Invalid Input"))
			return
		end

		-- guild?
		if (input == "nil") then
			-- get guild club id
			clubId = ClubGetGuildClubId()
		end

		-- no club id found?
		if (not clubId) then
			-- process all
			local lower = strlower(input)
			for k,v in pairs(NS.db.global.clubs) do
				-- has short name?
				if (v.shortName and (v.shortName ~= "")) then
					-- matches short name?
					local shortName = strlower(v.shortName)
					if ((v.shortName == input) or (shortName == lower)) then
						-- found
						clubId = k
						break
					end
				end

				-- has full name?
				if (v.name and (v.name ~= "")) then
					-- matches full name?
					local fullName = strlower(v.name)
					if ((v.name == input) or (fullName == lower)) then
						-- found
						clubId = k
						break
					end
				end

				-- has club id?
				if (v.clubId and (v.clubId > 1)) then
					-- matches clubId?
					local strClubID = tostring(v.clubId)
					if (strClubID == lower) then
						-- found
						clubId = k
						break
					end
				end
			end
		end

		-- no club id found?
		if (not clubId) then
			-- process subscribed clubs
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
					if ((v.name == input) or (fullName == lower)) then
						-- found
						clubId = v.clubId
						break
					end
				end

				-- has club id?
				if (v.clubId and (v.clubId > 1)) then
					-- matches clubId?
					local strClubID = tostring(v.clubId)
					if (strClubID == lower) then
						-- found
						clubId = k
						break
					end
				end
			end
		end
	end

	-- no clubId?
	if (not clubId) then
		-- send data
		NS:BNSendData(senderID, strformat("!CommFlare@Members@Invalid Club ID"))
		return
	end

	-- get club members
	local text = nil
	local members = ClubGetClubMembers(clubId)
	if (not members) then
		-- send data
		NS:BNSendData(senderID, strformat("!CommFlare@Members@Invalid Club Members"))
		return
	end

	-- none found?
	local count = 0
	local text = nil
	local lines = {}
	if (#members == 0) then
		-- try local database
		if (NS.db.global.members) then
			-- process local
			text = strformat("DB:%d@", tonumber(clubId))
			for k,v in pairs(NS.db.global.members) do
				-- has clubs and is member?
				if (v.clubs and v.clubs[clubId]) then
					-- no server?
					local name, realm = nil, nil
					if (strmatch(v.name, "-")) then
						-- split
						name, realm = strsplit("-", v.name)
					else
						-- use player server
						name = v.name
						realm = NS.CommFlare.CF.PlayerServerName
					end

					-- found both?
					if (name and realm and v.guid) then
						-- build new player
						local player = strformat("%s-%s:%s", name, realm, v.guid)
						local playerlength = strlen(player)
						local textlength = strlen(text)
						if ((textlength + playerlength + 1) > 4032) then
							-- insert
							tinsert(lines, text)

							-- restart text
							text = strformat("DB:%d@%s;", tonumber(clubId), player)
						else
							-- append player
							text = strformat("%s%s;", text, player)
						end

						-- increase
						count = count + 1
					end
				end
			end
		end
	else
		-- process all members
		text = strformat("ID:%d@", tonumber(clubId))
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
						text = strformat("ID:%d@%s;", tonumber(clubId), player)
					else
						-- append player
						text = strformat("%s%s;", text, player)
					end

					-- increase
					count = count + 1
				end
			end
		end
	end

	-- has text?
	if (text) then
		-- still more?
		local textlength = strlen(text)
		if (textlength > 0) then
			-- insert
			tinsert(lines, text)
		end
	end

	-- none found?
	if (count == 0) then
		-- none
		tinsert(lines, "None")
	end

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

-- get mercenary text
function NS:Get_Mercenary_Text(senderID)
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

	-- send data
	NS:BNSendData(senderID, strformat("!CommFlare@Mercenary@%s", tostring(text)))
end

-- get party text
function NS:Get_Party_Text(senderID)
	-- build party info
	local text = NS:GetGroupCountText()
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

	-- send data
	NS:BNSendData(senderID, strformat("!CommFlare@Party@%s", tostring(text)))
end

-- get popped text
function NS:Get_Popped_Text(senderID)
	-- process all
	local count = 0
	local text = ""
	local lines = {}
	for k,v in pairs (NS.CommFlare.CF.SocialQueues) do
		-- has all needed info?
		if (v.leader and v.leader.name and v.leader.realm and v.leader.guid and v.members) then
			-- popped?
			if (NS:HasQueuePopped(k)) then
				-- stale?
				local timestamp = v.popped + 30
				if (time() < timestamp) then
					-- build new party
					local numMembers = strformat("%d/5", #v.members)
					local mapName = NS.CommFlare.CF.SocialQueues[k].name
					local party = strformat("%s,%s,%s,%s-%s,%s", mapName, k, v.leader.guid, v.leader.name, v.leader.realm, numMembers)
					local partylength = strlen(party)
					local textlength = strlen(text)
					if ((textlength + partylength + 1) > 4032) then
						-- insert
						tinsert(lines, text)

						-- restart text
						text = strformat("ID:%d@%s;", tonumber(clubId), party)
					else
						-- append party
						text = strformat("%s%s;", text, party)
					end

					-- increase
					count = count + 1
				else
					-- update group
					NS:Update_Group(k)
				end
			end
		end
	end

	-- has text?
	if (text) then
		-- still more?
		local textlength = strlen(text)
		if (textlength > 0) then
			-- insert
			tinsert(lines, text)
		end
	end

	-- none found?
	if (count == 0) then
		-- none
		tinsert(lines, "None")
	end

	-- process all
	local timer = 0.0
	for k,v in ipairs(lines) do
		-- send data
		TimerAfter(timer, function()
			-- send localized data
			NS:BNSendData(senderID, strformat("!CommFlare@Popped@%s", tostring(v)))
		end)

		-- next
		timer = timer + 0.5
	end
end

-- get roster text
function NS:Get_Roster_Text(senderID, type)
	-- in battleground?
	local roster = {}
	if (NS:IsInBattleground() == true) then
		-- horde only?
		if (type:find("Horde")) then
			-- get horde roster
			type = 0
		-- alliance only?
		elseif (type:find("Alliance")) then
			-- get alliance roster
			type = 1
		-- all roster
		else
			-- unset
			type = nil
		end

		-- process all scores
		for i=1, GetNumBattlefieldScores() do
			local info = PvPGetScoreInfo(i)
			if (info) then
				-- should log player?
				if (not type or (info.faction == type)) then
					-- force name-realm format
					local player = info.name
					if (not strmatch(player, "-")) then
						-- add realm name
						player = player .. "-" .. NS.CommFlare.CF.PlayerServerName
					end

					-- get specID
					local specID = NS:Get_SpecID(info.className, info.talentSpec)
					if (specID and (specID > 0)) then
						-- append specID
						player = strformat("%s:%d", player, tonumber(specID))
					end

					-- insert
					tinsert(roster, player)
				end
			end
		end
	
		-- setup type
		if (type == 0) then
			-- horde
			type = "Horde"
		elseif (type == 1) then
			-- alliance
			type = "Alliance"
		else
			-- full
			type = "Full"
		end
	else
		-- process all
		for k,v in pairs(NS.CommFlare.CF.SocialQueues) do
			-- process queues
			local found = false
			for k2,v2 in ipairs(v.queues) do
				-- has queue data?
				local mapName = nil
				if (v2.queueData and v2.queueData.mapName) then
					-- save map name
					mapName = v2.queueData.mapName
				-- local queue?
				elseif (v2.name) then
					-- save map name
					mapName = v2.name
				end

				-- found map?
				if (mapName) then
					-- is tracked pvp?
					local isTracked, isEpicBattleground, isRandomBattleground, isBrawl = NS:IsTrackedPVP(mapName)
					if (isTracked == true) then
						-- found
						found = true
					end
				end
			end

			-- found tracked queue?
			if (found == true) then
				-- get members
				for k2,v2 in ipairs(v.members) do
					-- insert player
					local player = strformat("%s-%s", v2.name, v2.realm)
					tinsert(roster, player)
				end
			end
		end

		-- setup type
		type = "Queued"
	end

	-- no roster?
	if (#roster == 0) then
		-- none
		text = "None"
	else
		-- sort
		tsort(roster)

		-- process all
		local text = nil
		for k,v in ipairs(roster) do
			-- first?
			if (not text) then
				-- add first
				text = v
			else
				-- append
				text = strformat("%s;%s", text, v)
			end
		end
	end

	-- send data
	NS:BNSendData(senderID, strformat("!CommFlare@Roster@%s@%s", tostring(type), tostring(text)))
end

-- get status text
function NS:Get_Status_Text(senderID)
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
		else
			-- isle of conquest?
			if (NS.CommFlare.CF.MapID == 169) then
				-- issue capping gate request command
				NS.CommFlare.CF.NeedTransmissionData = true
				NS.CommFlare.CF.TransmissionCheck[senderID] = time()
				NS.CommFlare:SendCommMessage("Capping", "gr", "INSTANCE_CHAT")
			end
		end

		-- send data
		NS:BNSendData(senderID, strformat("!CommFlare@Status@%s", tostring(text)))
	end
end

-- process battle net commands
function NS:Process_BattleNET_Commands(senderID, text)
	-- get clubs?
	if (text:find("GetClubs")) then
		-- get clubs text
		NS:Get_Clubs_Text(senderID)
	-- get deserter?
	elseif (text:find("GetDeserter")) then
		-- get deserter text
		NS:Get_Deserter_Text(senderID)
	-- get history?
	elseif (text:find("GetHistory")) then
		-- get history list text
		NS:Get_History_List_Text(senderID, text)
	-- get leaders?
	elseif (text:find("GetLeaders")) then
		-- get leaders text
		NS:Get_Leaders_Text(senderID)
	-- get members?
	elseif (text:find("GetMembers")) then
		-- get members text
		NS:Get_Members_Text(senderID, text)
	-- get mercenary?
	elseif (text:find("GetMercenary")) then
		-- get mercenary text
		NS:Get_Mercenary_Text(senderID)
	-- get party?
	elseif (text:find("GetParty")) then
		-- get party text
		NS:Get_Party_Text(senderID)
	-- get pops?
	elseif (text:find("GetPopped")) then
		-- get popped text
		NS:Get_Popped_Text(senderID)
	-- get queues?
	elseif (text:find("GetQueues")) then
		-- find social queues by map name
		NS:Find_Social_Queues_By_MapName(senderID, text)
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
			-- get roster text
			NS:Get_Roster_Text(senderID, text)
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
			-- get status text
			NS:Get_Status_Text(senderID)
		end)
	-- get version?
	elseif (text:find("GetVersion")) then
		-- send data
		NS:BNSendData(senderID, strformat("!CommFlare@Version@%s,%s", tostring(NS.CommFlare.Version), tostring(NS.CommFlare.Build)))
	end
end

-- create frame for events
local f = CreateFrame("Frame")
f:RegisterEvent("CHAT_MSG_ADDON")
f:SetScript("OnEvent", function(self, event, ...)
	-- chat message addon?
	if (event == "CHAT_MSG_ADDON") then
		-- does not need addon data
		local prefix, text, channel, sender, target, zoneChannelID, localID, name, instanceID = ...
		if (NS.CommFlare.CF.NeedTransmissionData ~= true) then
			-- finished
			return
		end

		-- capping?
		print(prefix, "-", channel, "-", sender, "-", text, "-", target)
		if (prefix == "Capping") then
			-- isle of conquest?
			if (NS.CommFlare.CF.MapID == 169) then
				-- skip these messages
				if ((text == "gr") or (text == "rb") or (text == "rbh")) then
					-- finished
					return
				end
			end

			-- sanity check?
			local h1, h1hp, h2, h2hp, h3, h3hp, a1, a1hp, a2, a2hp, a3, a3hp = strsplit(":", text)
			local hGate1, hGate2, hGate3, aGate1, aGate2, aGate3 = tonumber(h1hp), tonumber(h2hp), tonumber(h3hp), tonumber(a1hp), tonumber(a2hp), tonumber(a3hp)
			if (hGate1 and hGate2 and hGate3 and aGate1 and aGate2 and aGate3) then
				-- find lowest gates
				local allyLowest = math.min(aGate1, aGate2, aGate3) / 2400000 * 100
				local hordeLowest = math.min(hGate1, hGate2, hGate3) / 2400000 * 100

				-- report to anyone?
				local text = strformat(L["%s: Alliance Gate = %.1f, Horde Gate = %.1f"], L["Isle of Conquest"], allyLowest, hordeLowest)
				if (NS.CommFlare.CF.TransmissionCheck and next(NS.CommFlare.CF.TransmissionCheck)) then
					-- process all
					local timer = 0.0
					for k,v in pairs(NS.CommFlare.CF.TransmissionCheck) do
						-- send replies staggered
						TimerAfter(timer, function()
							-- send message
							NS:SendMessage(k, text)
						end)

						-- next
						timer = timer + 0.2
					end
				end

				-- finished
				NS.CommFlare.CF.TransmissionCheck = {}
				NS.CommFlare.CF.NeedTransmissionData = false
			end
		end
	end
end)
