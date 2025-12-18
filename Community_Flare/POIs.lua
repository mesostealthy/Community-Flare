-- initialize
local LibStub = LibStub
local ADDON_NAME, NS = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
if (not L or not NS.CommFlare) then return end

-- localize stuff
local _G                                        = _G
local CopyTable                                 = _G.CopyTable
local AreaPoiInfoGetAreaPOIForMap               = _G.C_AreaPoiInfo.GetAreaPOIForMap
local AreaPoiInfoGetAreaPOIInfo                 = _G.C_AreaPoiInfo.GetAreaPOIInfo
local MapGetBestMapForUnit                      = _G.C_Map.GetBestMapForUnit
local MapGetMapInfo                             = _G.C_Map.GetMapInfo
local print                                     = _G.print
local tonumber                                  = _G.tonumber
local tostring                                  = _G.tostring
local type                                      = _G.type
local strformat                                 = _G.string.format

-- get current POI's
function NS:Get_Current_POIs()
	-- get map id
	NS.CommFlare.CF.MapID = MapGetBestMapForUnit("player")
	if (not NS.CommFlare.CF.MapID) then
		-- not found
		return nil
	end

	-- process any POI's
	local pois = AreaPoiInfoGetAreaPOIForMap(NS.CommFlare.CF.MapID)
	if (pois and (#pois > 0)) then
		-- display infos
		local list  = {}
		for _,v in ipairs(pois) do
			-- get area poi info
			local info = AreaPoiInfoGetAreaPOIInfo(NS.CommFlare.CF.MapID, v)
			if (info and info.areaPoiID) then
				-- has position?
				if (info.position) then
					-- validate position
					local x, y = info.position:GetXY()
					if (x and y) then
						-- add position
						info.x = x
						info.y = y
					end
				end

				-- save poi info
				list[info.areaPoiID] = info
			end
		end

		-- return list
		return list 
	end

	-- none
	return nil
end

-- list current POI's
function NS:List_POIs()
	-- get map id
	print(L["Dumping POIs:"])
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

	-- process any POI's
	local count = 0
	print(strformat("Map Name: %s", NS.CommFlare.CF.MapInfo.name))
	local pois = AreaPoiInfoGetAreaPOIForMap(NS.CommFlare.CF.MapID)
	if (pois and (#pois > 0)) then
		-- display infos
		for _,v in ipairs(pois) do
			NS.CommFlare.CF.POIInfo = AreaPoiInfoGetAreaPOIInfo(NS.CommFlare.CF.MapID, v)
			if (NS.CommFlare.CF.POIInfo and NS.CommFlare.CF.POIInfo.areaPoiID) then
				-- has texture index?
				local text = strformat("%s: ID = %d", NS.CommFlare.CF.POIInfo.name, NS.CommFlare.CF.POIInfo.areaPoiID)
				if (NS.CommFlare.CF.POIInfo.textureIndex) then
					-- add texture index
					text = strformat("%s; textureIndex = %d", text, NS.CommFlare.CF.POIInfo.textureIndex)
				end

				-- has position?
				if (NS.CommFlare.CF.POIInfo.position) then
					-- validate position
					local x, y = NS.CommFlare.CF.POIInfo.position:GetXY()
					if (x and y) then
						-- add position
						text = strformat("%s; x = %s; y = %s", text, tostring(x), tostring(y))
					end
				end

				-- has description?
				if (NS.CommFlare.CF.POIInfo.description and (NS.CommFlare.CF.POIInfo.description ~= "")) then
					-- add description
					text = strformat("%s; Description = %s", text, NS.CommFlare.CF.POIInfo.description)
				end

				-- display info
				print(text)

				-- increase
				count = count + 1
			end
		end
	end

	-- display count
	print(strformat(L["Count: %d"], count))
end

-- cancel active timers
function NS:Cancel_Active_Timers(name)
	-- has active timers?
	if (NS.CommFlare.CF.ActiveTimers and next(NS.CommFlare.CF.ActiveTimers)) then
		-- process all timers
		for k,v in pairs(NS.CommFlare.CF.ActiveTimers) do
			-- name matches?
			if (v.name == name) then
				-- timer exists?
				if (v.timer) then
					-- cancel timer
					v.timer:Cancel()
				end

				-- clear active timer
				NS.CommFlare.CF.ActiveTimers[k] = nil
			end
		end
	end
end

-- process IOC nodes capped
function NS:Process_IOC_Nodes_Capped(id)
	-- docks in conflict?
	if ((id == 2356) or (id == 2359)) then
		-- cancel docks related timers
		NS:Cancel_Active_Timers(L["Catapult"])
		NS:Cancel_Active_Timers(L["Glaive Thrower"])

		-- stop any glaive thrower capping bars
		NS:Capping_Stop_Bars(L["Glaive Thrower"])
	-- workshop in conflict?
	elseif ((id == 2347) or (id == 2348)) then
		-- cancel workshop related timers
		NS:Cancel_Active_Timers(L["Demolisher"])
		NS:Cancel_Active_Timers(L["Siege Engine"])
	end
end

-- update poi's
function NS:UpdatePOIs()
	-- get map id
	local mapID = MapGetBestMapForUnit("player")
	if (not mapID) then
		-- not found
		return false
	end

	-- get area pois
	local pois = AreaPoiInfoGetAreaPOIForMap(mapID)
	if (not pois) then
		-- not found
		return false
	end

	-- process all
	local list = {}
	local count = 0
	for i=1, #pois do
		-- get info
		local id = tonumber(pois[i])
		local info = AreaPoiInfoGetAreaPOIInfo(mapID, id)
		if (not info) then
			-- removed
			NS.CommFlare.CF.POIList[id] = nil
		else
			-- get name
			list[id] = true
			local name = tostring(info.name)
			if ((name == nil) or (name == "")) then
				-- use atlasName
				name = tostring(info.atlasName)
			end

			-- new?
			if (not NS.CommFlare.CF.POIList[id]) then
				-- add poi
				NS.CommFlare.CF.POIList[id] = CopyTable(info)
				count = count + 1

				-- isle of conquest?
				if (mapID == 169) then
					-- process IOC nodes capped
					NS:Process_IOC_Nodes_Capped(id)
				end
			else
				-- check for table updates
				count = count + NS:CheckForTableUpdates("POI", name, info, NS.CommFlare.CF.POIList[id], nil)
			end
		end
	end

	-- check for deleted
	for k,info in pairs(NS.CommFlare.CF.POIList) do
		-- not in list?
		local id = tonumber(k)
		if (not list[id]) then
			-- get name
			local name = tostring(info.name)
			if ((name == nil) or (name == "")) then
				-- use atlasName
				name = tostring(info.atlasName)
			end

			-- delete poi
			NS.CommFlare.CF.POIList[id] = nil
			count = count + 1
		end
	end

	-- success
	return true
end
