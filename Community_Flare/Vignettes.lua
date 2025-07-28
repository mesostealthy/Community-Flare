-- initialize
local LibStub = LibStub
local ADDON_NAME, NS = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
if (not L or not NS.CommFlare) then return end

-- localize stuff
local _G                                        = _G
local CopyTable                                 = _G.CopyTable
local MapGetBestMapForUnit                      = _G.C_Map.GetBestMapForUnit
local VignetteInfoGetVignetteInfo               = _G.C_VignetteInfo.GetVignetteInfo
local VignetteInfoGetVignettePosition           = _G.C_VignetteInfo.GetVignettePosition
local VignetteInfoGetVignettes                  = _G.C_VignetteInfo.GetVignettes
local print                                     = _G.print
local tostring                                  = _G.tostring
local type                                      = _G.type
local strformat                                 = _G.string.format

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

	-- process any vignettes
	local guids = VignetteInfoGetVignettes()
	if (guids and (#guids > 0)) then
		-- display infos
		print(strformat(L["Count: %d"], #guids))
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
						-- has name?
						if (info.name) then
							-- add tom tom way point
							NS:TomTomAddWaypoint(info.name, x, y)
						end

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
			end			
		end
	else
		-- none found
		print(strformat(L["Count: %d"], 0))
	end
end

-- update vignette's
function NS:UpdateVignettes()
	-- get map id
	local mapID = MapGetBestMapForUnit("player")
	if (not mapID) then
		-- not found
		return false
	end

	-- get vignettes
	local guids = VignetteInfoGetVignettes()
	if (not guids) then
		-- not found
		return false
	end

	-- process all
	local count = 0
	local list = {}
	for i=1, #guids do
		-- get vignette info
		local id = tostring(guids[i])
		local info = VignetteInfoGetVignetteInfo(id)
		if (not info) then
			-- removed
			NS.CommFlare.CF.VignetteList[id] = nil
		else
			-- get name
			list[id] = true
			local name = tostring(info.name)
			if ((name == nil) or (name == "")) then
				-- use atlasName
				name = tostring(info.atlasName)
			end

			-- vignette not added yet?
			if (not NS.CommFlare.CF.VignetteList[id]) then
				-- add vignette
				NS.CommFlare.CF.VignetteList[id] = CopyTable(info)
				count = count + 1
			else
				-- check for table updates
				count = count + NS:CheckForTableUpdates("VIGNETTE", name, info, NS.CommFlare.CF.VignetteList[id], nil)
			end
		end
	end

	-- check for deleted
	for k,info in pairs(NS.CommFlare.CF.VignetteList) do
		-- not in list?
		local id = tostring(k)
		if (not list[id]) then
			-- get name
			local name = tostring(info.name)
			if ((name == nil) or (name == "")) then
				-- use atlasName
				name = tostring(info.atlasName)
			end

			-- delete vignette
			NS.CommFlare.CF.VignetteList[id] = nil
			count = count + 1
		end
	end

	-- success
	return true
end
