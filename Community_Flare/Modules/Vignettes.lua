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
		local vignettes = {}
		for _,v in ipairs(guids) do
			-- get vignette info
			local info = NS:GetVignetteInfo(v)
			if (info and info.vignetteID) then
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
				end
			end
		end

		-- return table
		return vignettes
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
	print(strformat("MapID: %d", NS.CommFlare.CF.MapID))
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

	-- process all
	local count = 0
	for vignetteID,info in pairs(list) do
		-- war supply crate?
		if (NS.WAR_SUPPLY_CRATES[vignetteID]) then
			-- needs to issue raid warning?
			if (not NS.CommFlare.CF.VignetteWarnings[vignetteID]) then
				-- create pin?
				if (vignetteID ~= 3689) then
					-- create pin
					createPin = true
				end

				-- has coordinates?
				if (info.x and info.y) then
					-- not invalid location?
					local mapID = NS:GetBestMapForUnit("player")
					NS:Debug_Print(strformat("War Crate: %d = %s, %s", mapID, tostring(info.x), tostring(info.y)))
					if (not NS:Check_For_Invalid_War_Crate_Position(mapID, info.x, info.y)) then
						-- logging war crate locations?
						NS.CommFlare.CF.VignetteWarnings[vignetteID] = time()
						if (NS.db.global.logWarCrateLocations == true) then
							-- new war crate detection?
							local datestamp = date()
							if (not NS.CommFlare.CF.WarCrateLocations[datestamp]) then
								-- save location
								NS.CommFlare.CF.WarCrateLocations[datestamp] = {}
								NS.CommFlare.CF.WarCrateLocations[datestamp].mapID = mapID
								NS.CommFlare.CF.WarCrateLocations[datestamp].guid = info.vignetteGUID
								NS.CommFlare.CF.WarCrateLocations[datestamp].x = info.x
								NS.CommFlare.CF.WarCrateLocations[datestamp].y = info.y
								NS.CommFlare.CF.WarCrateLocations[datestamp].datetamp = datestamp
								NS.CommFlare.CF.WarCrateLocations[datestamp].timestamp = time()
							end
						end

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
							end)

							-- remove all war supply crate waypoints
							NS:TomTomRemoveWaypoints(NS.WAR_SUPPLY_CRATE)

							-- add tom tom way point
							local name = strformat("%s (%d)", info.name, vignetteID)
							local uid = NS:TomTomAddWaypoint(name, info.x, info.y)

							-- create pin?
							local hyperLink = nil
							if (createPin == true) then
								-- can set user waypoint?
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
			else
				-- only found crate flying in currently?
				if ((count == 0) and (vignetteID == 3689)) then
					-- has coordinates?
					if (info.x and info.y) then
						-- no ready crate tracker?
						if (not NS.Libs.RCT) then
							-- no create pin?
							if (createPin ~= true) then
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
