-- initialize
local LibStub = LibStub
local ADDON_NAME, NS = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
if (not L or not NS.CommFlare) then return end

-- localize stuff
local _G                                          = _G
local CopyTable                                   = _G.CopyTable
local MapGetBestMapForUnit                        = _G.C_Map.GetBestMapForUnit
local PvPGetBattlefieldVehicles                   = _G.C_PvP.GetBattlefieldVehicles
local print                                       = _G.print
local tostring                                    = _G.tostring
local type                                        = _G.type
local strformat                                   = _G.string.format

-- get current vehicles
function NS:Get_Current_Vehicles()
	-- get map id
	NS.CommFlare.CF.MapID = MapGetBestMapForUnit("player")
	if (not NS.CommFlare.CF.MapID) then
		-- not found
		return nil
	end

	-- process any vehicles
	local vehicles = PvPGetBattlefieldVehicles(NS.CommFlare.CF.MapID)
	if (vehicles and (#vehicles > 0)) then
		-- display infos
		local list = {}
		for k,v in ipairs(vehicles) do
			-- insert
			tinsert(list, v)
		end

		-- return table
		return list
	end

	-- none
	return nil
end

-- list vehicles
function NS:List_Vehicles()
	-- get map id
	print(L["Dumping Vehicles:"])
	NS.CommFlare.CF.MapID = MapGetBestMapForUnit("player")
	if (not NS.CommFlare.CF.MapID) then
		-- not found
		print(L["Map ID: Not Found"])
		return
	end

	-- process any vehicles
	local vehicles = PvPGetBattlefieldVehicles(NS.CommFlare.CF.MapID)
	if (vehicles and (#vehicles > 0)) then
		-- display infos
		print(strformat(L["Count: %d"], #vehicles))
		for k,v in ipairs(vehicles) do
			-- display
			print(strformat("%s: %d; isAlive = %s; Position = %s, %s", v.name, k, tostring(v.isAlive), tostring(v.x), tostring(v.y)))
		end
	else
		-- none found
		print(strformat(L["Count: %d"], 0))
	end
end

-- update vehicles
function NS:UpdateVehicles()
	-- get map id
	local mapID = MapGetBestMapForUnit("player")
	if (not mapID) then
		-- not found
		return false
	end

	-- get vehicles
	NS.CommFlare.CF.VehicleList = {}
	local vehicles = PvPGetBattlefieldVehicles(mapID)
	if (not vehicles) then
		-- not found
		return false
	end

	-- process all
	local list = {}
	local count = 0
	for k,info in ipairs(vehicles) do
		-- get name
		local name = tostring(info.name)
		if ((name == nil) or (name == "")) then
			-- use atlas
			name = tostring(info.atlas)
		end

		-- new?
		local id = tonumber(k)
		if (not NS.CommFlare.CF.VehicleList[id]) then
			-- add vehicle
			NS.CommFlare.CF.VehicleList[id] = CopyTable(info)
			count = count + 1
		else
			-- check for table updates
			count = count + NS:CheckForTableUpdates("VEHICLE", name, info, NS.CommFlare.CF.VehicleList[id], nil)
		end

		-- always valid
		list[id] = true
	end

	-- check for deleted
	for k,info in pairs(NS.CommFlare.CF.VehicleList) do
		-- not in list?
		local id = tonumber(k)
		if (not list[id]) then
			-- get name
			local name = tostring(info.name)
			if ((name == nil) or (name == "")) then
				-- use atlas
				name = tostring(info.atlas)
			end

			-- delete
			NS.CommFlare.CF.VehicleList[id] = nil
			count = count + 1
		end
	end

	-- success
	return true
end
