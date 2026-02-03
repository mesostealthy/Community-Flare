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
local MapCanSetUserWaypointOnMap                  = _G.C_Map.CanSetUserWaypointOnMap
local MapGetBestMapForUnit                        = _G.C_Map.GetBestMapForUnit
local MapGetMapInfo                               = _G.C_Map.GetMapInfo
local MapGetUserWaypointHyperlink                 = _G.C_Map.GetUserWaypointHyperlink
local MapSetUserWaypoint                          = _G.C_Map.SetUserWaypoint
local SuperTrackSetSuperTrackedUserWaypoint       = _G.C_SuperTrack.SetSuperTrackedUserWaypoint
local TimerAfter                                  = _G.C_Timer.After
local VignetteInfoGetVignetteInfo                 = _G.C_VignetteInfo.GetVignetteInfo
local VignetteInfoGetVignettePosition             = _G.C_VignetteInfo.GetVignettePosition
local VignetteInfoGetVignettes                    = _G.C_VignetteInfo.GetVignettes
local print                                       = _G.print
local time                                        = _G.time
local tonumber                                    = _G.tonumber
local tostring                                    = _G.tostring
local type                                        = _G.type
local strformat                                   = _G.string.format
local tinsert                                     = _G.table.insert

-- check for invalid war crate position
function NS:Check_For_Invalid_War_Crate_Position(x, y)
	-- Azh-Kahet
	local posX = tostring(x)
	local posY = tostring(y)
	if ((posX == "0.62041199207306") and (posY == "0.86914432048798")) then
		-- invalid
		return true
	-- Hallowfall
	elseif ((posX == "0.32797354459763") and (posY == "0.21520841121674")) then
		-- invalid
		return true
	-- Isle of Dorn
	elseif ((posX == "0.69920414686203") and (posY == "0.75819730758667")) then
		-- invalid
		return true
	-- K'aresh
	elseif ((posX == "0.69890224933624") and (posY == "0.051990866661072")) then
		-- invalid
		return true
	-- Ringing Deeps
	elseif ((posX == "0.62094902992249") and (posY == "0.97968757152557")) then
		-- invalid
		return true
	-- Siren Isle
	elseif ((posX == "0.95618790388107") and (posY == "0.53979897499084")) then
		-- invalid
		return true
	-- Undermine
	elseif ((posX == "0.22974973917007") and (posY == "0.50090676546097")) then
		-- invalid
		return true
	end

	-- valid
	return false
end

-- vignette check for alerts
function NS:VignetteCheckForAlerts(list)
	-- in instance?
	local inInstance, instanceType = IsInInstance()
	if (inInstance == true) then
		-- finished
		return
	end

	-- flying in?
	local timer = 300
	local message = nil
	local createPin = false
	local vignetteID = nil
	if (list[2967]) then
		-- war supply create is dropping in nows
		createPin = true
		vignetteID = 2967
		message = L["War Supply Crate is dropping in now!"]
	-- war supply crate flying in?
	elseif (list[3689]) then
		-- war supply crate is flying in now
		vignetteID = 3689
		message = L["War Supply Crate is flying in now!"]
	-- war chest has fully dropped?
	elseif (list[6066]) then
		-- war supply crate has fully dropped to the ground
		timer = 600
		createPin = true
		vignetteID = 6066
		message = L["War Supply Crate has fully dropped to the ground!"]
	-- war chest looted for the alliance
	elseif (list[6067]) then
		-- war supply looted has been looted for the alliance
		createPin = true
		vignetteID = 6067
		message = L["War Supply Crate has been looted for the Alliance!"]
	-- war chest looted for the horde
	elseif (list[6068]) then
		-- war supply looted has been looted for the horde
		createPin = true
		vignetteID = 6068
		message = L["War Supply Crate has been looted for the Horde!"]
	end

	-- found vignette?
	if (vignetteID and message) then
		-- has coordinates?
		local info = list[vignetteID]
		if (info and info.vignetteGUID) then
			-- needs to issue raid warning?
			local guid = info.vignetteGUID
			if (not NS.CommFlare.CF.VignetteWarnings[guid]) then
				-- has coordinates?
				if (info.x and info.y) then
					-- check for invalid locations
					if (NS:Check_For_Invalid_War_Crate_Position(info.x, info.y) == true) then
						-- finished
						return
					end
	
					-- issue raid warning
					NS.CommFlare.CF.VignetteWarnings[guid] = time()
					TimerAfter(timer, function()
						-- clear last raid warning
						NS.CommFlare.CF.VignetteWarnings[guid] = nil

						-- remove all war supply crate waypoints
						NS:TomTomRemoveWaypoints("War Supply Crate")
					end)

					-- add tom tom way point
					local uid = NS:TomTomAddWaypoint(info.name, info.x, info.y)

					-- create pin?
					local hyperLink = nil
					if (createPin == true) then
						-- get MapID
						local mapID = MapGetBestMapForUnit("player")
						if (mapID) then
							-- can set user waypoint?
							if (MapCanSetUserWaypointOnMap(mapID)) then
								-- create position from x/y
								local point = UiMapPoint.CreateFromCoordinates(mapID, info.x, info.y)
								MapSetUserWaypoint(point)
								hyperLink = MapGetUserWaypointHyperlink()

								-- not already tracked?
								if (not uid) then
									-- set super tracked
									SuperTrackSetSuperTrackedUserWaypoint(true)
								end
							end
						end
					end

					-- issue local raid warning (with raid warning audio sound)
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
				else
					-- try again
					TimerAfter(2, function()
						-- get current vignettes
						local list = NS:Get_Current_Vignettes()
						if (list) then
							-- call recursively
							NS:VignetteCheckForAlerts(list)
						end
					end)
					return
				end
			end
		end
	end
end

-- get current vignettes
function NS:Get_Current_Vignettes()
	-- get map id
	NS.CommFlare.CF.MapID = MapGetBestMapForUnit("player")
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
			local info = VignetteInfoGetVignetteInfo(v)
			if (info and info.vignetteID) then
				-- get position
				local pos = VignetteInfoGetVignettePosition(v, NS.CommFlare.CF.MapID)
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
							if (info.name == "War Supply Crate") then
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

		-- return table
		return vignettes
	end

	-- none
	return nil
end

-- list current vignettes
function NS:List_Vignettes()
	-- get map id
	print(L["Dumping Vignettes:"])
	NS.CommFlare.CF.MapID = MapGetBestMapForUnit("player")
	if (not NS.CommFlare.CF.MapID) then
		-- not found
		print(L["Map ID: Not Found"])
		return
	end

	-- get map info
	print(strformat("MapID: %d", NS.CommFlare.CF.MapID))
	NS.CommFlare.CF.MapInfo = MapGetMapInfo(NS.CommFlare.CF.MapID)
	if (not NS.CommFlare.CF.MapInfo) then
		-- not found
		print(L["Map ID: Not Found"])
		return
	end

	-- process any vignettes
	local count = 0
	print(strformat("Map Name: %s", NS.CommFlare.CF.MapInfo.name))
	local guids = VignetteInfoGetVignettes()
	if (guids and (#guids > 0)) then
		-- display infos
		for _,v in ipairs(guids) do
			-- get vignette info
			local info = VignetteInfoGetVignetteInfo(v)
			if (info and info.vignetteID) then
				-- get position
				local pos = VignetteInfoGetVignettePosition(v, NS.CommFlare.CF.MapID)
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

	-- display count
	print(strformat(L["Count: %d"], count))
end
