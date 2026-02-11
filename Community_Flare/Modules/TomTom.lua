-- initialize
local LibStub = LibStub
local ADDON_NAME, NS = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
if (not L or not NS.CommFlare) then return end

-- localize stuff
local _G                                          = _G
local MapCanSetUserWaypointOnMap                  = _G.C_Map.CanSetUserWaypointOnMap
local MapGetBestMapForUnit                        = _G.C_Map.GetBestMapForUnit
local MapSetUserWaypoint                          = _G.C_Map.SetUserWaypoint
local SuperTrackSetSuperTrackedUserWaypoint       = _G.C_SuperTrack.SetSuperTrackedUserWaypoint
local pairs                                       = _G.pairs
local securecallfunction                          = _G.securecallfunction
local tonumber                                    = _G.tonumber
local tostring                                    = _G.tostring

-- remove tom tom way points
function NS:TomTomRemoveWaypoints(title)
	-- sanity check
	if (not title) then
		-- finished
		return
	end

	-- has tom tom?
	local TT = TomTom
	if (TT and TT.RemoveWaypoint and TT.waypoints) then
		-- process all waypoints
		for mapID, entries in pairs(TT.waypoints) do
			-- process zone waypoints
			for _, waypoint in pairs(entries) do
				-- title matches?
				if (waypoint.title and (waypoint.title == title)) then
					-- remove waypoint
					securecallfunction(TT.RemoveWaypoint, TT, waypoint)
				end
			end
		end
	end
end

-- add tom tom way point
function NS:TomTomAddWaypoint(title, x, y)
	-- sanity checks
	if (not title or not x or not y) then
		-- finished
		return nil
	end

	-- has tom tom?
	local TT = TomTom
	if (TT and TT.AddWaypoint) then
		-- setup options
		local options =
		{
			desc = tostring(title),
			title = tostring(title),
			persistent = true,
			minimap = true,
			world = true,
			callbacks = nil,
			silent = true,
			from = "CommFlare",
		}

		-- add way point
		return securecallfunction(TT.AddWaypoint, TT, NS.CommFlare.CF.MapID, tonumber(x), tonumber(y), options)
	else
		-- get MapID
		local mapID = MapGetBestMapForUnit("player")
		if (mapID) then
			-- can set user waypoint?
			if (MapCanSetUserWaypointOnMap(mapID)) then
				-- set user way point
				local point = UiMapPoint.CreateFromCoordinates(mapID, tonumber(x), tonumber(y))
				MapSetUserWaypoint(point)

				-- set super tracked
				SuperTrackSetSuperTrackedUserWaypoint(true)
			end
		end
	end

	-- not enabled
	return nil
end

-- add tom tom way point
function NS:TomTomAddWaypointByMapID(mapID, title, x, y)
	-- sanity checks
	if (not mapID or not title or not x or not y) then
		-- finished
		return nil
	end

	-- has tom tom?
	local TT = TomTom
	if (TT and TT.AddWaypoint) then
		-- setup options
		local options =
		{
			desc = tostring(title),
			title = tostring(title),
			persistent = true,
			minimap = true,
			world = true,
			callbacks = nil,
			silent = true,
			from = "CommFlare",
		}

		-- add way point
		return securecallfunction(TT.AddWaypoint, TT, mapID, tonumber(x), tonumber(y), options)
	end

	-- not enabled
	return nil
end
