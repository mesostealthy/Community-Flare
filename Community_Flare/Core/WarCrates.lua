-- initialize
local LibStub = LibStub
local ADDON_NAME, NS = ...
if (not NS.Loaded or not NS.Loaded["Vignettes"]) then return end
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
if (not L or not NS.CommFlare) then return end

-- localize stuff
local _G                                          = _G
local CopyTable                                   = _G.CopyTable
local FlashClientIcon                             = _G.FlashClientIcon
local IsInGroup                                   = _G.IsInGroup
local IsInInstance                                = _G.IsInInstance
local IsInRaid                                    = _G.IsInRaid
local RaidWarningFrame_OnEvent                    = _G.RaidWarningFrame_OnEvent
local MapClearUserWaypoint                        = _G.C_Map.ClearUserWaypoint
local MapGetUserWaypointHyperlink                 = _G.C_Map.GetUserWaypointHyperlink
local TimerAfter                                  = _G.C_Timer.After
local date                                        = _G.date
local next                                        = _G.next
local pairs                                       = _G.pairs
local print                                       = _G.print
local time                                        = _G.time
local tonumber                                    = _G.tonumber
local tostring                                    = _G.tostring
local type                                        = _G.type
local mabs                                        = _G.math.abs
local matan2                                      = _G.math.atan2
local mdeg                                        = _G.math.deg
local strformat                                   = _G.string.format
local strsplit                                    = _G.string.split
local strsub                                      = _G.string.sub
local tinsert                                     = _G.table.insert
local tremove                                     = _G.table.remove

-- check for invalid war crate position
function NS:Check_For_Invalid_War_Crate_Position(mapID, x, y)
	-- clean values
	local posX = tostring(x)
	local posY = tostring(y)

	-- process all
	for k,v in pairs(NS.WarCrateStartLocations) do
		-- location matches?
		if ((posX == v.x) and (posY == v.y)) then
			-- invalid
			return true
		end
	end

	-- valid
	return false
end

-- find war supply drop locations
function NS:FindWarSupplyCrateDropLocation(mapID, x, y, degree)
	-- has locations?
	if (NS.WarCrateStartLocations[mapID] and NS.WarCrateDropLocations[mapID]) then
		-- remove decimals
		degree = strsplit(".", tostring(degree))
		if (degree) then
			-- not starting location?
			local xString = tostring(x)
			local xPos = strsub(NS.WarCrateStartLocations[mapID].x, 1, 9)
			if (not xString:find(xPos)) then
				-- process drop locations
				degree = tonumber(degree)
				for k,v in pairs(NS.WarCrateDropLocations[mapID]) do
					-- matches range?
					if ((degree >= v.dl) and (degree <= v.dh)) then
						-- return drop location
						return v.x, v.y
					end
				end
			end
		end
	end

	-- failed
	return nil, nil
end

-- get war supply crate angle
function NS:GetWarSupplyCrateAngle(mapID, x2, y2)
	-- has location data?
	if (NS.WarCrateStartLocations[mapID]) then
		-- calculate angle degree
		local x1 = NS.WarCrateStartLocations[mapID].x * 100.0
		local y1 = NS.WarCrateStartLocations[mapID].y * 100.0
		local dx = (x2 * 100.0) - x1
		local dy = (y2 * 100.0) - y1
		local absX = mabs(dx)
		local absY = mabs(dy)
		if ((absX > 0.001) and (absY > 0.001)) then
			-- calculate angle degree
			return mdeg(matan2(dy, dx))
		end
	end

	-- failed
	return nil
end

-- has crate dropped?
function NS:HasWarSupplyCrateDropped(vignetteID)
	-- crate dropping in?
	if (vignetteID == 2967) then
		-- yes
		return true
	-- crate landed?
	elseif (vignetteID == 6066) then
		-- yes
		return true
	-- crate claimed alliance?
	elseif (vignetteID == 6067) then
		-- yes
		return true
	-- crate claimed horde?
	elseif (vignetteID == 6068) then
		-- yes
		return true
	end

	-- no
	return false
end


-- purge war supply crates
function NS:PurgeWarSupplyCrates()
	-- has war crate location data?
	local tbl = NS.CommFlare.CF.WarCrateLocations
	if (tbl and (#tbl > 0)) then
		-- purge day count?
		local days = 0
		if (NS.db.global.purgeWarCrateLocationsTime == 1) then
			-- 7 days
			days = 7
		elseif (NS.db.global.purgeWarCrateLocationsTime == 2) then
			-- 14 days
			days = 14
		elseif (NS.db.global.purgeWarCrateLocationsTime == 3) then
			-- 30 days
			days = 30
		end

		-- has days to purge?
		if (days > 0) then
			-- process all (in reverse)
			local currentTime = time()
			for i = #tbl, 1, -1 do
				-- empty?
				if (not tbl[i]) then
					-- remove
					tremove(tbl, i)
				-- no guid?
				elseif (not tbl[i].guid) then
					-- remove
					tremove(tbl, i)
				-- over 30 days ago?
				elseif ((currentTime - tbl[i].timestamp) > (days * 86400)) then
					-- remove
					tremove(tbl, i)
				end
			end
		end
	end

	-- process all (sanity checks)
	for k,v in pairs(NS.CommFlare.CF.WarCrateLocations) do
		-- has guid?
		if (v.guid) then
			-- check for proper fields
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

		-- has data to calculate degree?
		if (v.mapID and v.x and v.y) then
			-- no degree yet?
			if (not v.degree) then
				-- save degree
				NS.CommFlare.CF.WarCrateLocations[k].degree = NS:GetWarSupplyCrateAngle(v.mapID, v.x, v.y)
			end
		end
	end
end

-- find war supply crate data
function NS:FindWarSupplyCrateData(_zoneUID)
	-- string?
	if (type(_zoneUID) == "string") then
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
			-- check for proper fields
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

		-- has data to calculate degree?
		if (v.mapID and v.x and v.y) then
			-- no degree yet?
			if (not v.degree) then
				-- get war supply crate angle
				local degree = NS:GetWarSupplyCrateAngle(v.mapID, v.x, v.y)
				if (degree) then
					-- save degree
					NS.CommFlare.CF.WarCrateLocations[k].degree = tonumber(degree)
				end
			end
		end
	end

	-- return crates
	return crates
end

-- check for war supply crate alerts alerts
function NS:CheckForWarSupplyCrateAlerts(list)
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
								-- has crate dropped?
								local hasDropped = NS:HasWarSupplyCrateDropped(vignetteID)
								if (hasDropped) then
									-- not already dropped previously?
									if (not NS.CommFlare.CF.CrateHasDropped) then
										-- reset crate has dropped later
										NS.CommFlare.CF.CrateHasDropped = true
										TimerAfter(150, function()
											-- reset crate has dropped
											NS.CommFlare.CF.CrateHasDropped = false
										end)
									end
								end

								-- create location
								local creatureType, _, serverID, instanceID, zoneUID, vignetteID, spawnUID = strsplit("-", info.vignetteGUID)
								local location = {
									["from"] = NS.CommFlare.CF.PlayerFullName,
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

								-- get war supply crate angle
								local degree = NS:GetWarSupplyCrateAngle(mapID, info.x, info.y)
								if (degree) then
									-- save degree
									location.degree = tonumber(degree)
								end

								-- insert
								tinsert(NS.CommFlare.CF.WarCrateLocations, location)
							end

							-- notify when war crate is inbound?
							if (NS.db.global.notifyWarCrateInbound) then
								-- no ready crate tracker?
								if ((not NS.Libs.RCT) and (NS.CommFlare.CF.ExtCrateTracker == false)) then
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
										FlashClientIcon()
										local message = NS.WAR_SUPPLY_CRATES[vignetteID]
										RaidWarningFrame_OnEvent(RaidBossEmoteFrame, "CHAT_MSG_RAID_WARNING", message)

										-- notify group?
										if (NS.db.global.notifyGroupWarCrates) then
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
					end
				else
					-- crate has not dropped?
					if (not NS.CommFlare.CF.CrateHasDropped) then
						-- only found crate flying in currently?
						if ((count == 0) and (vignetteID == 3689)) then
							-- has coordinates?
							if (info.x and info.y) then
								-- notify when war crate is inbound?
								if (NS.db.global.notifyWarCrateInbound) then
									-- no ready crate tracker?
									if ((not NS.Libs.RCT) and (NS.CommFlare.CF.ExtCrateTracker == false)) then
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
				end

				-- increase
				count = count + 1
			end
		end
	end

	-- none found?
	if (count == 0) then
		-- no ready crate tracker?
		if ((not NS.Libs.RCT) and (NS.CommFlare.CF.ExtCrateTracker == false)) then
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

-- fully loaded
NS.LoadCount = NS.LoadCount + 1
NS.Loaded["WarCrates"] = NS.LoadCount
