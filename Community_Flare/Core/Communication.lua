-- initialize
local LibStub = LibStub
local ADDON_NAME, NS = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
if (not L or not NS.CommFlare) then return end

-- localize stuff
local _G                                          = _G
local IsGuildMember                               = _G.IsGuildMember
local IsInGroup                                   = _G.IsInGroup
local IsInRaid                                    = _G.IsInRaid
local MergeTable                                  = _G.MergeTable
local UnitClass                                   = _G.UnitClass
local UnitName                                    = _G.UnitName
local print                                       = _G.print
local time                                        = _G.time
local tonumber                                    = _G.tonumber
local strformat                                   = _G.string.format
local strsplit                                    = _G.string.split
local tinsert                                     = _G.table.insert

-- process on communication received
function NS:Process_OnCommReceived(prefix, message, distribution, sender)
	-- get player name
	local player = UnitName("player")
	if (player == sender) then
		-- debug mode disabled?
		if (NS.db.global.debugMode == false) then
			-- finished
			return
		end
	end

	-- verify prefix
	if (prefix == ADDON_NAME) then
		-- community flare message?
		if (message:find("!CommFlare@")) then
			-- split args
			local args = {strsplit("@", message)}
			if (not args) then
				-- finished
				return
			end

			-- no version?
			if (not args[2] or (args[2] == "")) then
				-- finished
				return
			end

			-- no command
			if (not args[3] or (args[3] == "")) then
				-- finished
				return
			end

			-- version checked?
			if (args[3] == "VERSION_CHECK") then
				-- debug print enabled?
				if (NS.db.global.debugPrint == true) then
					-- debug print
					NS:Debug_Print(strformat("%s: VERSION_CHECK = %s; %s", NS.CommFlare.Title, tostring(sender), tostring(distribution)))
				end

				-- guild or instance chat message?
				if ((distribution == "GUILD") or (distribution == "INSTANCE_CHAT")) then
					-- not already displayed?
					if (NS.CommFlare.CF.UpgradeDisplayed == false) then
						-- updated version?
						local updated = NS:Compare_Version(args[2])
						if (updated == true) then
							-- updated version
							print(strformat(L["%s version %s update available. Download the latest version from Curseforge or Wago!"], NS.CommFlare.Title, args[2]))

							-- displayed
							NS.CommFlare.CF.UpgradeDisplayed = true
						end
					end
				end
			-- war supply crate?
			elseif (args[3] == "WAR_SUPPLY_CRATE") then
				-- debug print enabled?
				if (NS.db.global.debugPrint == true) then
					-- debug print
					NS:Debug_Print(strformat("%s: WAR_SUPPLY_CRATE = %s; %s = %s", NS.CommFlare.Title, tostring(sender), tostring(distribution), tostring(args[4])))
				end

				-- logging war crate locations?
				if (NS.db.global.logWarCrateLocations == true) then
					-- found all data?
					local mapID, timestamp, vignetteGUID, x, y = strsplit(",", args[4])
					if (mapID and timestamp and vignetteGUID and x and y) then
						-- clean values
						mapID = tonumber(mapID)
						timestamp = tonumber(timestamp)
						vignetteGUID = tostring(vignetteGUID)
						x = tonumber(x)
						y = tonumber(y)

						-- extract zoneUID / vignetteID
						local creatureType, _, serverID, instanceID, zoneUID, vignetteID, spawnUID = strsplit("-", vignetteGUID)
						serverID = tonumber(serverID)
						instanceID = tonumber(instanceID)
						zoneUID = tonumber(zoneUID)
						vignetteID = tonumber(vignetteID)
						spawnUID = tonumber(spawnUID, 16)

						-- process all
						local logged = false
						for k,v in pairs(NS.CommFlare.CF.WarCrateLocations) do
							-- already logged?
							if ((v.mapID == mapID) and (v.serverID == serverID) and (v.instanceID == instanceID) and (v.zoneUID == zoneUID) and (v.vignetteID and vignetteID) and (v.spawnUID == spawnUID)) then
								-- finished
								logged = true
								break
							end
						end

						-- not logged?
						if (not logged) then
							-- create location
							local location = {
								["mapID"] = mapID,
								["serverID"] = serverID,
								["instanceID"] = instanceID,
								["zoneUID"] = zoneUID,
								["vignetteID"] = vignetteID,
								["spawnUID"] = spawnUID,
								["guid"] = vignetteGUID,
								["x"] = x,
								["y"] = y,
								["datetamp"] = date(nil, timestamp),
								["timestamp"] = timestamp,
							}

							-- only actually log for other players
							if (player ~= sender) then
								-- insert
								tinsert(NS.CommFlare.CF.WarCrateLocations, location)
							end
						end
					end
				end
			-- zone changed new area?
			elseif (args[3] == "ZONE_CHANGED_NEW_AREA") then
				-- party or raid message?
				if ((distribution == "PARTY") or (distribution == "RAID")) then
					-- notified when party member changes zones?
					if (NS.db.global.notifyPartyZoneChanges == true) then
						-- are you in a party?
						if (IsInGroup()) then
							-- are you group leader?
							if (NS:IsGroupLeader() == true) then
								-- has map name?
								local mapID, mapName = strsplit(":", message)
								if (not mapName) then
									-- get map info by id
									local info = NS:GetMapInfo(tonumber(message))
									if (info and info.name) then
										-- set map name
										mapName = info.name
									else
										-- use full message (fall back)
										mapName = message
									end
								end

								-- debug print enabled?
								if (NS.db.global.debugPrint == true) then
									-- debug print
									NS:Debug_Print(strformat("%s: ZONE_CHANGED_NEW_AREA = %s; %s = %s", NS.CommFlare.Title, tostring(sender), tostring(distribution), tostring(mapName)))
								end

								-- display zone change message
								print(strformat(L["%s has changed zones to %s."], sender, mapName))
							end
						end
					end
				end
			end
		else
			-- group joined?
			if (message:find("GROUP_ROSTER_UPDATE")) then
				-- party message?
				if (distribution == "PARTY") then
					-- are you not group leader?
					if (NS:IsGroupLeader() ~= true) then
						-- community member?
						if (message:find("YES")) then
							-- enable community party leader
							NS.charDB.profile.communityPartyLeader = true
						end
					end
				end
			-- ready check?
			elseif (message:find("READY_CHECK")) then
				-- party or raid message?
				if ((distribution == "PARTY") or (distribution == "RAID")) then
					-- reply?
					if (message:find("READY_CHECK:")) then
						-- get unit for sender
						local unit = NS:GetPartyUnit(sender)
						player = NS:GetFullName(sender)
						if (unit and player) then
							-- split message
							local title, version, build = strsplit(":", message)
							if (not build) then
								-- not available
								build = L["N/A"]
							end

							-- save version number
							NS.CommFlare.CF.PartyVersions[unit] = version

							-- display player's community flare version / build
							print(strformat(L["%s has %s %s (%s)"], player, NS.CommFlare.Title, version, build))
						end
					else
						-- are you in a party / raid?
						if (IsInGroup()) then
							-- are you in a raid?
							local message = strformat("READY_CHECK:%s:%s", NS.CommFlare.Version, NS.CommFlare.Build)
							if (IsInRaid()) then
								-- send raid addon message
								NS:SendAddonMessage(ADDON_NAME, message, "RAID")
							else
								-- send party addon message
								NS:SendAddonMessage(ADDON_NAME, message, "PARTY")
							end
						end
					end
				end
			-- request party lead?
			elseif (message:find("REQUEST_PARTY_LEAD")) then
				-- instance chat, party or raid message?
				if ((distribution == "INSTANCE_CHAT") or (distribution == "PARTY") or (distribution == "RAID")) then
					-- process pass leadership
					NS:Process_Pass_Leadership(sender)
				end
			end
		end
	end
end

-- send transmission
function NS:SendTransmission(message)
	-- send guild addon message
	NS:SendAddonMessage(ADDON_NAME, message, "GUILD")

	-- are you in a party / raid?
	if (IsInGroup()) then
		-- are you in a raid?
		if (IsInRaid()) then
			-- send raid addon message
			NS:SendAddonMessage(ADDON_NAME, message, "RAID")
		else
			-- send party addon message
			NS:SendAddonMessage(ADDON_NAME, message, "PARTY")
		end
	end

	-- setup report channels
	local count = NS:Setup_Report_Channels()
	if (count > 0) then
		-- get owner + leaders online
		local players = {}
		for clubId,_ in pairs(NS.CommFlare.CF.ReportChannels) do
			-- get online community members
			local members = NS:GetOnlineCommunityMembers(clubId)
			if (members) then
				-- merge tables
				MergeTable(players, members)
			end
		end

		-- process all
		for player,guid in pairs(players) do
			-- found yourself?
			if (player == NS.CommFlare.CF.PlayerFullName) then
				-- delete
				players[player] = nil
			else
				-- player in your guild?
				if (IsGuildMember(guid)) then
					-- delete
					players[player] = nil
				else
					-- get unit class
					local className, classFilename, classId = UnitClass(player)
					if (className and classId) then
						-- delete
						players[player] = nil
					end
				end
			end
		end

		-- process all
		for player,guid in pairs(players) do
			-- send whisper addon message
			NS:SendAddonMessage(ADDON_NAME, message, "WHISPER", player)
		end
	end
end
