-- initialize
local LibStub = LibStub
local ADDON_NAME, NS = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
if (not L or not NS.CommFlare) then return end

-- localize stuff
local _G                                          = _G
local CopyTable                                   = _G.CopyTable
local IsInGroup                                   = _G.IsInGroup
local IsInInstance                                = _G.IsInInstance
local IsInRaid                                    = _G.IsInRaid
local RaidWarningFrame_OnEvent                    = _G.RaidWarningFrame_OnEvent
local MapClearUserWaypoint                        = _G.C_Map.ClearUserWaypoint
local MapGetUserWaypointHyperlink                 = _G.C_Map.GetUserWaypointHyperlink
local TimerAfter                                  = _G.C_Timer.After
local VignetteInfoGetVignettes                    = _G.C_VignetteInfo.GetVignettes
local date                                        = _G.date
local issecretvalue                               = _G.issecretvalue
local print                                       = _G.print
local time                                        = _G.time
local tonumber                                    = _G.tonumber
local tostring                                    = _G.tostring
local type                                        = _G.type
local strformat                                   = _G.string.format
local strsplit                                    = _G.string.split
local tinsert                                     = _G.table.insert

-- check for invalid war crate position
function NS:Check_For_Invalid_War_Crate_Position(mapID, x, y)
	-- clean values
	local posX = tostring(x)
	local posY = tostring(y)

	-- process all
	for k,v in pairs(NS.WarCrateLocations) do
		-- location matches?
		if ((posX == v.x) and (posY == v.y)) then
			-- invalid
			return true
		end
	end

	-- valid
	return false
end

-- get current vignettes
function NS:Get_Current_Vignettes(name)
	-- get map id
	NS.CommFlare.CF.MapID = NS:GetBestMapForUnit("player")
	if (not NS.CommFlare.CF.MapID) then
		-- not found
		return nil
	end

	-- process any vignettes
	local guids = VignetteInfoGetVignettes()
	if (guids and (#guids > 0)) then
		-- display infos
		local count = 0
		local vignettes = {}
		for _,v in ipairs(guids) do
			-- get vignette info
			local info = NS:GetVignetteInfo(v)
			if (info and info.vignetteID) then
				-- get zone specific data
				local creatureType, _, serverID, instanceID, zoneUID, vignetteID, spawnUID = strsplit("-", info.vignetteGUID)
				if (spawnUID) then
					-- save data specific data
					NS.CommFlare.CF.serverID = tonumber(serverID)
					NS.CommFlare.CF.instanceID = tonumber(instanceID)
					NS.CommFlare.CF.zoneUID = tonumber(zoneUID)
				end

				-- has name?
				local logged = true
				if (name and not issecretvalue(name) and (name ~= "")) then
					-- name does not match?
					if (not info.name:find(name)) then
						-- not logged
						logged = false
					end
				end

				-- logged?
				if (logged) then
					-- get position
					local pos = NS:GetVignettePosition(v, NS.CommFlare.CF.MapID)
					if (pos) then
						-- get x/y
						local x, y = pos:GetXY()
						if (x and y) then
							-- save position
							info.x = x
							info.y = y

							-- debug print enabled?
							if (NS.db.global.debugPrint == true) then
								-- debug War Supply Crate only
								if (info.name == NS.WAR_SUPPLY_CRATE) then
									-- debug print
									NS:Debug_Print(strformat("%s (%d) [%s]: %s, %s", tostring(info.name), tonumber(info.vignetteID), tostring(v), tostring(info.x), tostring(info.y)))
								end
							end
						end
					end

					-- add to table
					local id = info.vignetteID
					vignettes[id] = info
					count = count + 1
				end
			end
		end

		-- found some?
		if (count > 0) then
			-- return table
			return vignettes
		end
	end

	-- none
	return nil
end

-- list current vignettes
function NS:List_Vignettes(list)
	-- get map id
	print(L["Dumping Vignettes:"])
	NS.CommFlare.CF.MapID = NS:GetBestMapForUnit("player")
	if (not NS.CommFlare.CF.MapID) then
		-- not found
		print(L["Map ID: Not Found"])
		return
	end

	-- get map info
	print(strformat(L["Map ID: %d"], NS.CommFlare.CF.MapID))
	NS.CommFlare.CF.MapInfo = NS:GetMapInfo(NS.CommFlare.CF.MapID)
	if (not NS.CommFlare.CF.MapInfo) then
		-- not found
		print(L["Map ID: Not Found"])
		return
	end

	-- process any vignettes
	local count = 0
	print(strformat("Map Name: %s", NS.CommFlare.CF.MapInfo.name))
	if (list and next(list)) then
		-- process all
		for id,info in pairs(list) do
			-- sanity check
			if (info and info.vignetteID) then
				-- has x/y?
				if (info.x and info.y) then
					-- display
					print(strformat("%s: ID = %d; GUID = %s; Position = %s, %s", info.name, info.vignetteID, info.vignetteGUID, info.x, info.y))
				else
					-- display
					print(strformat("%s: ID = %d; GUID = %s", info.name, info.vignetteID, info.vignetteGUID))
				end

				-- increase
				count = count + 1
			end			
		end
	else
		-- get vignettes
		local guids = VignetteInfoGetVignettes()
		if (guids and (#guids > 0)) then
			-- display infos
			for _,v in ipairs(guids) do
				-- get vignette info
				local info = NS:GetVignetteInfo(v)
				if (info and info.vignetteID) then
					-- get zone specific data
					local creatureType, _, serverID, instanceID, zoneUID, vignetteID, spawnUID = strsplit("-", info.vignetteGUID)
					if (spawnUID) then
						-- save data specific data
						NS.CommFlare.CF.serverID = tonumber(serverID)
						NS.CommFlare.CF.instanceID = tonumber(instanceID)
						NS.CommFlare.CF.zoneUID = tonumber(zoneUID)
					end

					-- get position
					local pos = NS:GetVignettePosition(v, NS.CommFlare.CF.MapID)
					if (pos) then
						-- get x/y
						local x, y = pos:GetXY()
						if (x and y) then
							-- add position
							info.x = strformat("%0.02f", x * 100.0)
							info.y = strformat("%0.02f", y * 100.0)
						end
					end

					-- has x/y?
					if (info.x and info.y) then
						-- display
						print(strformat("%s: ID = %d; GUID = %s; Position = %s, %s", info.name, info.vignetteID, info.vignetteGUID, info.x, info.y))
					else
						-- display
						print(strformat("%s: ID = %d; GUID = %s", info.name, info.vignetteID, info.vignetteGUID))
					end

					-- increase
					count = count + 1
				end			
			end
		end
	end

	-- display count
	print(strformat(L["Count: %d"], count))
end

-- vignette check for alerts
function NS:VignetteCheckForAlerts(list)
	-- in instance?
	local inInstance, instanceType = IsInInstance()
	if (inInstance == true) then
		-- finished
		return
	end

	-- has list?
	local count = 0
	local mapID = NS:GetBestMapForUnit("player")
	if (list and next(list)) then
		-- process all
		for vignetteID,info in pairs(list) do
			-- war supply crate?
			if (NS.WAR_SUPPLY_CRATES[vignetteID]) then
				-- needs to issue raid warning?
				if (not NS.CommFlare.CF.VignetteWarnings[vignetteID]) then
					-- has coordinates?
					if (info.x and info.y) then
						-- not invalid location?
						NS:Debug_Print(strformat("War Crate: %d = %s, %s", mapID, tostring(info.x), tostring(info.y)))
						if (not NS:Check_For_Invalid_War_Crate_Position(mapID, info.x, info.y)) then
							-- logging war crate locations?
							NS.CommFlare.CF.VignetteWarnings[vignetteID] = time()
							if (NS.db.global.logWarCrateLocations == true) then
								-- create location
								local creatureType, _, serverID, instanceID, zoneUID, vignetteID, spawnUID = strsplit("-", info.vignetteGUID)
								local location = {
									["mapID"] = mapID,
									["serverID"] = tonumber(serverID),
									["instanceID"] = tonumber(instanceID),
									["zoneUID"] = tonumber(zoneUID),
									["vignetteID"] = tonumber(vignetteID),
									["spawnUID"] = tonumber(spawnUID, 16),
									["guid"] = tostring(info.vignetteGUID),
									["x"] = tonumber(info.x),
									["y"] = tonumber(info.y),
									["datetamp"] = date(),
									["timestamp"] = time(),
								}

								-- insert
								tinsert(NS.CommFlare.CF.WarCrateLocations, location)
							end

							-- notify when war crate is inbound?
							if (NS.db.global.notifyWarCrateInbound == true) then
								-- no ready crate tracker?
								if (not NS.Libs.RCT) then
									-- needs 10 minutes?
										local timer = 300
									if (vignetteID == 6066) then
										-- set 10-minute timer
										timer = 600
									end

									-- remove waypoints later
									TimerAfter(timer, function()
										-- clear last raid warning
										NS.CommFlare.CF.VignetteWarnings[vignetteID] = nil

										-- remove all war supply crate waypoints
										NS:TomTomRemoveWaypoints(NS.WAR_SUPPLY_CRATE)

										-- can set user waypoint?
										if (NS:CanSetUserWaypointOnMap(mapID)) then
											-- clear user waypoint
											MapClearUserWaypoint()
										end
									end)

									-- remove all war supply crate waypoints
									NS:TomTomRemoveWaypoints(NS.WAR_SUPPLY_CRATE)

									-- add tom tom way point
									local name = strformat("%s (%d)", info.name, vignetteID)
									local uid = NS:TomTomAddWaypoint(name, info.x, info.y)

									-- can set user waypoint?
									local hyperLink = nil
									if (NS:CanSetUserWaypointOnMap(mapID)) then
										-- create position from x/y
										local point = UiMapPoint.CreateFromCoordinates(mapID, info.x, info.y)
										NS:SetUserWaypoint(point)
										hyperLink = MapGetUserWaypointHyperlink()

										-- not already tracked?
										if (not uid) then
											-- set super tracked
											NS:SetSuperTrackedUserWaypoint(true)
										end
									end

									-- not announced yet?
									local crateID = strformat("%s:%d", NS.WAR_SUPPLY_CRATE, tonumber(vignetteID))
									if (not NS.CommFlare.CF.Announcements[crateID]) then
										-- save announcement time
										NS.CommFlare.CF.Announcements[crateID] = timestamp

										-- clear announcement later
										TimerAfter(150, function()
											-- clear last raid warning
											NS.CommFlare.CF.Announcements[crateID] = nil
										end)

										-- issue local raid warning (with raid warning audio sound)
										local message = NS.WAR_SUPPLY_CRATES[vignetteID]
										RaidWarningFrame_OnEvent(RaidBossEmoteFrame, "CHAT_MSG_RAID_WARNING", message)

										-- has hyper link?
										if (hyperLink) then
											-- add to message
											message = strformat("%s %s", message, hyperLink)
										end

										-- in raid?
										if (IsInRaid()) then
											-- display raid message
											NS:SendMessage("RAID", message)
										-- in party?
										elseif (IsInGroup()) then
											-- display party message
											NS:SendMessage("PARTY", message)
										end
									end
								end
							end
						end
					end
				else
					-- only found crate flying in currently?
					if ((count == 0) and (vignetteID == 3689)) then
						-- has coordinates?
						if (info.x and info.y) then
							-- notify when war crate is inbound?
							if (NS.db.global.notifyWarCrateInbound == true) then
								-- no ready crate tracker?
								if (not NS.Libs.RCT) then
									-- remove all war supply crate waypoints
									NS:TomTomRemoveWaypoints(NS.WAR_SUPPLY_CRATE)

									-- add tom tom way point
									local name = strformat("%s (%d)", info.name, vignetteID)
									local uid = NS:TomTomAddWaypoint(name, info.x, info.y)

									-- can set user waypoint?
									local mapID = NS:GetBestMapForUnit("player")
									if (NS:CanSetUserWaypointOnMap(mapID)) then
										-- create position from x/y
										local point = UiMapPoint.CreateFromCoordinates(mapID, info.x, info.y)
										NS:SetUserWaypoint(point)

										-- not already tracked?
										if (not uid) then
											-- set super tracked
											NS:SetSuperTrackedUserWaypoint(true)
										end
									end
								end
							end
						end
					end
				end

				-- increase
				count = count + 1
			end
		end
	end

	-- none found?
	if (count == 0) then
		-- no ready crate tracker?
		if (not NS.Libs.RCT) then
			-- clear all raid warnings
			NS.CommFlare.CF.VignetteWarnings = {}

			-- remove all war supply crate waypoints
			NS:TomTomRemoveWaypoints(NS.WAR_SUPPLY_CRATE)

			-- can set user waypoint?
			if (NS:CanSetUserWaypointOnMap(mapID)) then
				-- clear user waypoint
				MapClearUserWaypoint()
			end
		end
	end
end

-- purge war supply crates
function NS:PurgeWarSupplyCrates()
	-- process all
	local currentTime = time()
	for k,v in pairs(NS.CommFlare.CF.WarCrateLocations) do
		-- over 7 days ago?
		if ((currentTime - v.timestamp) > (7 * 86400)) then
			-- delete
			NS.CommFlare.CF.WarCrateLocations[k] = nil
		-- has guid?
		elseif (v.guid) then
			-- check vignetteID
			local _, _, serverID, instanceID, zoneUID, vignetteID, spawnUID = strsplit("-", v.guid)
			if (not v.serverID) then
				-- save serverID
				NS.CommFlare.CF.WarCrateLocations[k].serverID = tonumber(serverID)
			end
			if (not v.instanceID) then
				-- save instanceID
				NS.CommFlare.CF.WarCrateLocations[k].instanceID = tonumber(instanceID)
			end
			if (not v.zoneUID) then
				-- save zoneUID
				NS.CommFlare.CF.WarCrateLocations[k].zoneUID = tonumber(zoneUID)
			end
			if (not v.vignetteID) then
				-- save vignetteID
				NS.CommFlare.CF.WarCrateLocations[k].vignetteID = tonumber(vignetteID)
			end
			if (not v.spawnUID) then
				-- save spawnUID
				NS.CommFlare.CF.WarCrateLocations[k].spawnUID = tonumber(spawnUID, 16)
			end
		end
	end
end

-- find war supply crate data
function NS:FindWarSupplyCrateData(_zoneUID)
	-- string?
	if (type(_zoneUID)) then
		-- convert
		_zoneUID = tonumber(_zoneUID)
	end

	-- process all
	local count = 0
	local crates = {}
	local mapID = NS:GetBestMapForUnit("player")
	print(strformat(L["Map ID: %d"], mapID))
	print(strformat(L["Instance ID: %d"], NS.CommFlare.CF.instanceID))
	print(strformat(L["Zone UID: %d"], NS.CommFlare.CF.zoneUID))
	for k,v in pairs(NS.CommFlare.CF.WarCrateLocations) do
		-- no timestamp?
		if (v.timestamp == 0) then
			-- delete
			NS.CommFlare.CF.WarCrateLocations[k] = nil
		-- has guid?
		elseif (v.guid) then
			-- check vignetteID
			local _, _, serverID, instanceID, zoneUID, vignetteID, spawnUID = strsplit("-", v.guid)
			if (not v.serverID) then
				-- save serverID
				NS.CommFlare.CF.WarCrateLocations[k].serverID = tonumber(serverID)
			end
			if (not v.instanceID) then
				-- save instanceID
				NS.CommFlare.CF.WarCrateLocations[k].instanceID = tonumber(instanceID)
			end
			if (not v.zoneUID) then
				-- save zoneUID
				NS.CommFlare.CF.WarCrateLocations[k].zoneUID = tonumber(zoneUID)
			end
			if (not v.vignetteID) then
				-- save vignetteID
				NS.CommFlare.CF.WarCrateLocations[k].vignetteID = tonumber(vignetteID)
			end
			if (not v.spawnUID) then
				-- save spawnUID
				NS.CommFlare.CF.WarCrateLocations[k].spawnUID = tonumber(spawnUID, 16)
			end

			-- matches mapID + vignetteID?
			if ((v.mapID == mapID) and (v.vignetteID == 3689)) then
				-- matching specific?
				local matched = false
				if (_zoneUID) then
					-- matches?
					if (v.zoneUID == _zoneUID) then
						-- matched
						matched = true
					end
				else
					-- matches current?
					if ((v.serverID == NS.CommFlare.CF.serverID) and (v.instanceID == NS.CommFlare.CF.instanceID) and (v.zoneUID == NS.CommFlare.CF.zoneUID)) then
						-- matched
						matched = true
					end
				end

				-- matched?
				if (matched) then
					-- add to crates
					tinsert(crates, v)
					count = count + 1
				end
			end
		end
	end

	-- return crates
	return crates
end
