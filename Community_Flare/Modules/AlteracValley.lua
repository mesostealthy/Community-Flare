-- initialize
local LibStub = LibStub
local ADDON_NAME, NS = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
if (not L or not NS.CommFlare) then return end

-- localize stuff
local _G                                          = _G
local CopyTable                                   = _G.CopyTable
local InCombatLockdown                            = _G.InCombatLockdown
local RaidWarningFrame_OnEvent                    = _G.RaidWarningFrame_OnEvent
local TimerAfter                                  = _G.C_Timer.After
local VignetteInfoGetVignettes                    = _G.C_VignetteInfo.GetVignettes
local pairs                                       = _G.pairs
local tonumber                                    = _G.tonumber
local strformat                                   = _G.string.format

-- pois
NS.AlteracValleyActivePOIs = {}
NS.AlteracValleyTrackedPOIs = {
	[1352] = 1, -- Dun Baldur North Bunker (Alliance)
	[1355] = 1, -- Dun Baldur South Bunker (Alliance)
	[1362] = 0, -- East Frostwolf Tower (Horde)
	[1377] = 0, -- Iceblood Tower (Horde)
	[1380] = 1, -- Icewing Bunker (Alliance)
	[1389] = 1, -- Stonehearth Bunker (Alliance)
	[1405] = 0, -- Tower Point (Horde)
	[1528] = 0, -- West Frostwolf Tower (Horde)
}

-- vignettes
NS.AlteracValleyActiveVignettes = {}
NS.AlteracValleyTrackedVignettes = {
	[3694] = {
		["name"] = L["Primalist Thurloga"],
		["AlertDeath"] = true,
	},
}

-- initialize
function NS:AlteracValley_Initialize()
	-- reset stuff
	NS.AlteracValleyActivePOIs = {}
	NS.CommFlare.CF.AV.BunkersDestroyed = 0
	NS.CommFlare.CF.AV.TowersDestroyed = 0
	NS.CommFlare.CF.AV.LeftGained = 0
	NS.CommFlare.CF.AV.RightGained = 0
	NS.CommFlare.CF.AV.PrevLeftScore = -1
	NS.CommFlare.CF.AV.PrevRightScore = -1

	-- get initial scores
	local data = NS:GetDoubleStatusBarWidgetVisualizationInfo(1684)
	if (data and data.leftBarValue and data.rightBarValue) then
		-- setup previous scores
		NS.CommFlare.CF.AV.PrevLeftScore = tonumber(data.leftBarValue)
		NS.CommFlare.CF.AV.PrevRightScore = tonumber(data.rightBarValue)
	end
end

-- count bunkers / towers destroyed
function NS:Count_AlteracValley_BunkersTowers_Destroyed()
	-- found POIs?
	if (NS.faction ~= 0) then return end
	local mapID = NS.CommFlare.CF.MapID
	local ids = NS:GetAreaPOIForMap(mapID)
	if (ids and (#ids > 0)) then
		-- process ids
		local list = {}
		local TowersDestroyed = 0
		local BunkersDestroyed = 0
		for _, id in pairs(ids) do
			-- get info
			local info = NS:GetAreaPOIInfo(mapID, id)
			if (info and info.areaPoiID and info.textureIndex) then
				-- destroyed?
				if (info.textureIndex == 6) then
					-- tracked POI?
					if (NS.AlteracValleyTrackedPOIs[info.areaPoiID]) then
						-- horde?
						local factionID = NS.AlteracValleyTrackedPOIs[info.areaPoiID]
						if (factionID == 0) then
							-- increase towers destroyed
							TowersDestroyed = TowersDestroyed + 1
						-- alliance?
						elseif (factionID == 1) then
							-- increase bunkers destroyed
							BunkersDestroyed = BunkersDestroyed + 1
						end
					end
				end
			end
		end

		-- return counts
		return BunkersDestroyed, TowersDestroyed
	end

	-- none
	return 0, 0
end

-- process alterac valley pois
function NS:Process_AlteracValley_POIs()
	-- found POIs?
	if (NS.faction ~= 0) then return end
	local mapID = NS.CommFlare.CF.MapID
	local ids = NS:GetAreaPOIForMap(mapID)
	if (ids and (#ids > 0)) then
		-- process ids
		local list = {}
		for _, id in pairs(ids) do
			-- get info
			local info = NS:GetAreaPOIInfo(mapID, id)
			if (info and info.name and info.areaPoiID) then
				-- add to list
				list[info.name] = CopyTable(info)
			end
		end

		-- process list
		NS.CommFlare.CF.AV.BunkersDestroyed = 0
		NS.CommFlare.CF.AV.TowersDestroyed = 0
		for name, info in pairs(list) do
			-- not tracked yet?
			if (not NS.AlteracValleyActivePOIs[name]) then
				-- initialize
				NS.AlteracValleyActivePOIs[name] = {
					areaPoiID = info.areaPoiID,
					description = info.description,
					textureIndex = info.textureIndex
				}
			else
				-- active POI?
				local data = NS.AlteracValleyActivePOIs[name]
				if (data and data.textureIndex and info.textureIndex) then
					-- previously not destroyed?
					if (data.textureIndex ~= 6) then
						-- currently destroyed?
						if (info.textureIndex == 6) then
							-- horde?
							local factionID = NS.AlteracValleyTrackedPOIs[info.areaPoiID]
							if (factionID == 0) then
								-- valid previous right score?
								if (NS.CommFlare.CF.AV.PrevRightScore) then
									-- last points for match?
									if (NS.CommFlare.CF.AV.PrevRightScore < 100) then
										-- set zero
										NS.CommFlare.CF.AV.PrevRightScore = 0
									elseif (NS.CommFlare.CF.AV.PrevRightScore >= 100) then
										-- decrease by 100
										NS.CommFlare.CF.AV.PrevRightScore = NS.CommFlare.CF.AV.PrevRightScore - 100
									end
								end
							-- alliance?					
							elseif (factionID == 1) then
								-- valid previous left score?
								if (NS.CommFlare.CF.AV.PrevLeftScore) then
									-- last points for match?
									if (NS.CommFlare.CF.AV.PrevLeftScore < 100) then
										-- set zero
										NS.CommFlare.CF.AV.PrevLeftScore = 0
									elseif (NS.CommFlare.CF.AV.PrevLeftScore >= 100) then
										-- decrease by 100
										NS.CommFlare.CF.AV.PrevLeftScore = NS.CommFlare.CF.AV.PrevLeftScore - 100
									end
								end							
							end
						end
					end
				end

				-- update
				data.areaPoiID = info.areaPoiID
				data.description = info.description
				data.textureIndex = info.textureIndex
			end

			-- currently destroyed?
			if (info.textureIndex == 6) then
				-- tracked POI?
				if (NS.AlteracValleyTrackedPOIs[info.areaPoiID]) then
					-- horde?
					local factionID = NS.AlteracValleyTrackedPOIs[info.areaPoiID]
					if (factionID == 0) then
						-- increase towers destroyed
						NS.CommFlare.CF.AV.TowersDestroyed = NS.CommFlare.CF.AV.TowersDestroyed + 1
					-- alliance?
					elseif (factionID == 1) then
						-- increase bunkers destroyed
						NS.CommFlare.CF.AV.BunkersDestroyed = NS.CommFlare.CF.AV.BunkersDestroyed + 1
					end
				end
			end
		end
	end
end

-- process alterac valley vignettes
function NS:Process_AlteracValley_Vignettes()
	-- found vignettes?
	if (NS.faction ~= 0) then return end
	local mapID = NS.CommFlare.CF.MapID
	local ids = VignetteInfoGetVignettes()
	if (ids and (#ids > 0)) then
		-- check for additions
		local list = {}
		for _, guid in pairs(ids) do
			-- get info
			local info = NS:GetVignetteInfo(guid)
			if (info and info.name and info.vignetteID) then
				-- add to list
				local id = info.vignetteID
				list[id] = CopyTable(info)

				-- tracked?
				local data = NS.AlteracValleyTrackedVignettes[id]
				if (data) then
					-- not active?
					if (not NS.AlteracValleyActiveVignettes[id]) then
						-- save spawn time
						NS.AlteracValleyActiveVignettes[id] = time()
					end
				end
			end
		end

		-- check for deletions
		for id, info in pairs(NS.AlteracValleyTrackedVignettes) do
			-- active?
			if (NS.AlteracValleyActiveVignettes[id]) then
				-- no longer exists?
				if (not list[id]) then
					-- delete spawn time
					NS.AlteracValleyActiveVignettes[id] = nil

					-- has capping data?
					if (info.CappingDeath and info.IconID and info.RespawnTime) then
						-- add new capping bar
						local path = {136441}
						path[2], path[3], path[4], path[5] = NS:GetPOITextureCoords(info.IconID)
						NS:Capping_Add_New_Bar(info.name, info.RespawnTime, info.BarColor, path)
					end

					-- alert death?
					if (info.AlertDeath) then
						-- notifications enabled?
						if (NS.db.global.ashranNotifications ~= 1) then
							-- issue local raid warning (with raid warning audio sound)
							local message = strformat(L["%s has been killed."], info.name)
							RaidWarningFrame_OnEvent(RaidBossEmoteFrame, "CHAT_MSG_RAID_WARNING", message)
						end
					end
				end
			end
		end
	end
end

-- process alterac valley widget
function NS:Process_AlteracValley_Widget(info)
	-- scores widget?
	if (NS.faction ~= 0) then return end
	if (info.widgetID == 1684) then
		-- give time for Bunkers/Towers to burn
		TimerAfter(0.5, function()
			-- match completed?
			if (NS.CommFlare.CF.MatchStatus == 3) then
				-- finished
				return
			end

			-- get widget data
			local data = NS:GetWidgetData(info)
			if (data) then
				-- invalid previous left score?
				local leftBarValue = tonumber(data.leftBarValue)
				if (not NS.CommFlare.CF.AV.PrevLeftScore or (NS.CommFlare.CF.AV.PrevLeftScore < 0)) then
					-- initialize
					NS.CommFlare.CF.AV.PrevLeftScore = leftBarValue
				end
				
				-- valid left score?
				if (NS.CommFlare.CF.AV.PrevLeftScore > 0) then
					-- decreased by 100+?
					local diff = NS.CommFlare.CF.AV.PrevLeftScore - leftBarValue
					if (diff >= 100) then
						-- notifications enabled?
						if (NS.db.global.avNotifications ~= 1) then
							-- issue local raid warning (with raid warning audio sound)
							local message = strformat(L["%s has been killed."], L["Captain Balinda Stonehearth"])
							RaidWarningFrame_OnEvent(RaidBossEmoteFrame, "CHAT_MSG_RAID_WARNING", message)
						end
					-- increased?
					elseif (leftBarValue > NS.CommFlare.CF.AV.PrevLeftScore) then
						-- not initialized?
						if (not NS.CommFlare.CF.AV.LeftGained) then
							-- initialize
							NS.CommFlare.CF.AV.LeftGained = 0
						end

						-- increase
						NS.CommFlare.CF.AV.LeftGained = NS.CommFlare.CF.AV.LeftGained + 1
					end
				end

				-- invalid previous right score?
				local rightBarValue = tonumber(data.rightBarValue)
				if (not NS.CommFlare.CF.AV.PrevRightScore or (NS.CommFlare.CF.AV.PrevRightScore < 0)) then
					-- initialize
					NS.CommFlare.CF.AV.PrevRightScore = rightBarValue
				end

				-- valid right score?
				if (NS.CommFlare.CF.AV.PrevRightScore > 0) then
					-- decreased by 100+?
					local diff = NS.CommFlare.CF.AV.PrevRightScore - rightBarValue
					if (diff >= 100) then
						-- notifications enabled?
						if (NS.db.global.avNotifications ~= 1) then
							-- issue local raid warning (with raid warning audio sound)
							local message = strformat(L["%s has been killed."], L["Captain Galvangar"])
							RaidWarningFrame_OnEvent(RaidBossEmoteFrame, "CHAT_MSG_RAID_WARNING", message)
						end
					-- increased?
					elseif (rightBarValue > NS.CommFlare.CF.AV.PrevRightScore) then
						-- not initialized?
						if (not NS.CommFlare.CF.AV.RightGained) then
							-- initialize
							NS.CommFlare.CF.AV.RightGained = 0
						end

						-- increase
						NS.CommFlare.CF.AV.RightGained = NS.CommFlare.CF.AV.RightGained + 1
					end
				end

				-- update previous
				NS.CommFlare.CF.AV.PrevLeftScore = leftBarValue
				NS.CommFlare.CF.AV.PrevRightScore = rightBarValue
			end
		end)
	end
end

-- add REPorter callouts
function NS:REPorter_AlteracValley_Add_Callouts()
	-- in combat lockdown?
	if (NS.faction ~= 0) then return end
	if (InCombatLockdown()) then
		-- update last raid warning
		TimerAfter(5, function()
			-- call again
			NS:REPorter_AlteracValley_Add_Callouts()
		end)

		-- finished
		return
	end

	-- add remaining overlays
	NS:REPorter_Add_New_Overlay("Coldtooth Mine")
	NS:REPorter_Add_New_Overlay("Dun Baldar North Bunker")
	NS:REPorter_Add_New_Overlay("Dun Baldar South Bunker")
	NS:REPorter_Add_New_Overlay("East Frostwolf Tower")
	NS:REPorter_Add_New_Overlay("Frostwolf Graveyard")
	NS:REPorter_Add_New_Overlay("Frostwolf Relief Hut")
	NS:REPorter_Add_New_Overlay("Iceblood Graveyard")
	NS:REPorter_Add_New_Overlay("Iceblood Tower")
	NS:REPorter_Add_New_Overlay("Icewing Bunker")
	NS:REPorter_Add_New_Overlay("Irondeep Mine")
	NS:REPorter_Add_New_Overlay("Snowfall Graveyard")
	NS:REPorter_Add_New_Overlay("Stonehearth Bunker")
	NS:REPorter_Add_New_Overlay("Stonehearth Graveyard")
	NS:REPorter_Add_New_Overlay("Stormpike Aid Station")
	NS:REPorter_Add_New_Overlay("Stormpike Graveyard")
	NS:REPorter_Add_New_Overlay("Tower Point")
	NS:REPorter_Add_New_Overlay("West Frostwolf Tower")
end
