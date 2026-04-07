-- initialize
local LibStub = LibStub
local ADDON_NAME, NS = ...
if (not NS.Loaded or not NS.Loaded["Vehicles"]) then return end
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
if (not L or not NS.CommFlare) then return end

-- localize stuff
local _G                                          = _G
local VignetteInfoGetVignettes                    = _G.C_VignetteInfo.GetVignettes
local issecretvalue                               = _G.issecretvalue
local next                                        = _G.next
local pairs                                       = _G.pairs
local print                                       = _G.print
local tonumber                                    = _G.tonumber
local tostring                                    = _G.tostring
local strformat                                   = _G.string.format
local strmatch                                    = _G.string.match
local strsplit                                    = _G.string.split

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
		local spawnUIDzone = nil
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

					-- no zone spawnUID yet?
					if (not spawnUIDzone) then
						-- quartermaster?
						if (strmatch(info.name, "Quartermaster")) then
							-- save spawnUID
							spawnUIDzone = tonumber(spawnUID, 16)
						end
					end
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
									-- found crate angle?
									local text = strformat("%s (%d-%d) [%s]: %s, %s", tostring(info.name), tonumber(NS.CommFlare.CF.MapID), tonumber(info.vignetteID), tostring(v), tostring(info.x), tostring(info.y))
									local degree = NS:GetWarSupplyCrateAngle(NS.CommFlare.CF.MapID, info.x, info.y)
									if (degree) then
										-- add degree
										text = strformat("%s (%s)", text, tostring(degree))
									end

									-- debug print
									NS:Debug_Print(text)
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

		-- found zone spawnUID?
		if (spawnUIDzone) then
			-- save spawnUID
			NS.CommFlare.CF.spawnUID = tonumber(spawnUIDzone)
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
			local spawnUIDzone = nil
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

						-- no zone spawn time yet?
						if (not spawnUIDzone) then
							-- quartermaster?
							if (strmatch(info.name, "Quartermaster")) then
								-- save spawnUID
								spawnUIDzone = tonumber(spawnUID, 16)
							end
						end
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

			-- found zone spawnUID?
			if (spawnUIDzone) then
				-- save spawnUID
				NS.CommFlare.CF.spawnUID = tonumber(spawnUIDzone)
			end
		end
	end

	-- display count
	print(strformat(L["Count: %d"], count))
end

-- fully loaded
NS.LoadCount = NS.LoadCount + 1
NS.Loaded["Vignettes"] = NS.LoadCount
