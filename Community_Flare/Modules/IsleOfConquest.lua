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
local pairs                                       = _G.pairs
local print                                       = _G.print
local time                                        = _G.time
local tonumber                                    = _G.tonumber
local strformat                                   = _G.string.format

-- pois
NS.IOCActivePOIs = {}
NS.IOCTrackedPOIs = {} -- none for now

-- initialize
function NS:IOC_Initialize()
	-- reset stuff
	NS.IOCActivePOIs = {}
	NS.CommFlare.CF.IOC.AllianceGlaivesUp = 0
	NS.CommFlare.CF.IOC.HordeGlaivesUp = 0
	NS.CommFlare.CF.IOC.LeftGained = 0
	NS.CommFlare.CF.IOC.PrevLeftScore = -1
	NS.CommFlare.CF.IOC.PrevRightScore = -1
	NS.CommFlare.CF.IOC.RightGained = 0

	-- Docks: Uncontrolled initially
	NS.CommFlare.CF.IOC.DocksFlag = 2360
end

-- process isle of conquest pois
function NS:Process_IsleOfConquest_POIs(mapID)
	-- found POIs?
	if (NS.faction ~= 0) then return end
	local ids = NS:GetAreaPOIForMap(mapID)
	if (ids and (#ids > 0)) then
		-- check for additions
		local list = {}
		for _, id in pairs(ids) do
			-- get info
			local info = NS:GetAreaPOIInfo(mapID, id)
			if (info and info.name and info.areaPoiID) then
				-- currently active
				list[id] = CopyTable(info)

				-- not active?
				if (not NS.IOCActivePOIs[id]) then
					-- save spawn time
					NS.IOCActivePOIs[id] = time()

					-- Docks = Horde Controlled?
					if (id == 2357) then
						-- all glaives up
						NS.CommFlare.CF.IOC.HordeGlaivesUp = 3
						NS.CommFlare.CF.IOC.AllianceGlaivesUp = 0 -- reset zero
						NS.CommFlare.CF.IOC.DocksFlag = id
					-- Docks = Alliance Controlled?
					elseif (id == 2358) then
						-- all glaives up
						NS.CommFlare.CF.IOC.HordeGlaivesUp = 0 -- reset zero
						NS.CommFlare.CF.IOC.AllianceGlaivesUp = 3
						NS.CommFlare.CF.IOC.DocksFlag = id
					-- Docks = Tapped?
					elseif ((id == 2356) or (id == 2359)) then
						-- cancel glaives stuff
						NS.CommFlare.CF.IOC.HordeGlaivesUp = 0 -- reset zero
						NS.CommFlare.CF.IOC.AllianceGlaivesUp = 0 -- reset zero
						NS.CommFlare.CF.IOC.DocksFlag = id
						NS:Cancel_Active_Timers(L["Glaive Thrower"])
						NS:Capping_Stop_Bars(L["Glaive Thrower"])
					end

				end
			end
		end

		-- check for deletions
		for id, v in pairs(NS.IOCTrackedPOIs) do
			-- active?
			if (NS.IOCActivePOIs[id]) then
				-- no longer exists?
				if (not list[id]) then
					-- delete spawn time
					NS.IOCActivePOIs[id] = nil
				end
			end
		end
	end
end

-- process isle of conquest vehicles
function NS:Process_IsleOfConquest_Vehicles(mapID)
	-- get all battlefield vehicles
	if (NS.faction ~= 0) then return end
	local numGlaives = 0
	local list = NS:GetBattlefieldVehicles(mapID)
	if (list and (#list > 0)) then
		-- process all
		for k,v in pairs(list) do
			-- glaive thrower?
			if (v.name == L["Glaive Thrower"]) then
				-- is alive?
				if (v.isAlive == true) then
					-- increase
					numGlaives = numGlaives + 1
				end
			end
		end
	end

	-- Docks = Horde?
	if (NS.CommFlare.CF.IOC.DocksFlag == 2357) then
		-- initializing?
		if (NS.CommFlare.CF.IOC.HordeGlaivesUp < 0) then
			-- use this
			NS.CommFlare.CF.IOC.HordeGlaivesUp = numGlaives
		end

		-- glaive thrower down?
		if (numGlaives < NS.CommFlare.CF.IOC.HordeGlaivesUp) then
			-- player alliance?
			local path = {136441}
			local factionColor = "colorHorde"
			NS.CommFlare.CF.NumHordeGlaives = NS.CommFlare.CF.NumHordeGlaives + 1
			path[2], path[3], path[4], path[5] = NS:GetPOITextureCoords(40) -- horde horse icon
			local name = strformat("%s %d", L["Glaive Thrower"], NS.CommFlare.CF.NumHordeGlaives)

			-- add new capping bar
			NS:Capping_Add_New_Bar(name, 180, factionColor, path)
		elseif (numGlaives > NS.CommFlare.CF.IOC.HordeGlaivesUp) then
			-- display message
			print(strformat("NEW HORDE VEHICLE: %s should be spawned/spawning now!", L["Glaive Thrower"]))
		end

		-- update
		NS.CommFlare.CF.IOC.HordeGlaivesUp = numGlaives
	-- Docks = Alliance?
	elseif (NS.CommFlare.CF.IOC.DocksFlag == 2358) then
		-- initializing?
		if (NS.CommFlare.CF.IOC.AllianceGlaivesUp < 0) then
			-- use this
			NS.CommFlare.CF.IOC.AllianceGlaivesUp = numGlaives
		end

		-- glaive thrower down?
		if (numGlaives < NS.CommFlare.CF.IOC.AllianceGlaivesUp) then
			-- player alliance?
			local path = {136441}
			local factionColor = "colorAlliance"
			NS.CommFlare.CF.NumAllyGlaives = NS.CommFlare.CF.NumAllyGlaives + 1
			path[2], path[3], path[4], path[5] = NS:GetPOITextureCoords(38) -- alliance horse icon
			local name = strformat("%s %d", L["Glaive Thrower"], NS.CommFlare.CF.NumAllyGlaives)

			-- add new capping bar
			NS:Capping_Add_New_Bar(name, 180, factionColor, path)
		elseif (numGlaives > NS.CommFlare.CF.IOC.AllianceGlaivesUp) then
			-- display message
			print(strformat("NEW ALLIANCE VEHICLE: %s should be spawned/spawning now!", L["Glaive Thrower"]))
		end

		-- update
		NS.CommFlare.CF.IOC.AllianceGlaivesUp = numGlaives
	end
end

-- process isle of conquest widget
function NS:Process_IsleOfConquest_Widget(info)
	-- get widget data
	if (NS.faction ~= 0) then return end
	local data = NS:GetWidgetData(info)
	if (data) then
		-- score remaining?
		if (data.widgetID == 1685) then
			-- first left score?
			if (NS.CommFlare.CF.IOC.PrevLeftScore < 0) then
				-- initialize
				NS.CommFlare.CF.IOC.PrevLeftScore = tonumber(data.leftBarValue)
			else
				-- increased?
				if (data.leftBarValue > NS.CommFlare.CF.IOC.PrevLeftScore) then
					-- increase
					NS.CommFlare.CF.IOC.LeftGained = NS.CommFlare.CF.IOC.LeftGained + 1
				end

				-- update
				NS.CommFlare.CF.IOC.PrevLeftScore = tonumber(data.leftBarValue)
			end

			-- first right scorie?
			if (NS.CommFlare.CF.IOC.PrevRightScore < 0) then
				-- initialize
				NS.CommFlare.CF.IOC.PrevRightScore = tonumber(data.rightBarValue)
			else
				-- increased?
				if (data.rightBarValue > NS.CommFlare.CF.IOC.PrevRightScore) then
					-- increase
					NS.CommFlare.CF.IOC.RightGained = NS.CommFlare.CF.IOC.RightGained + 1
				end

				-- update
				NS.CommFlare.CF.IOC.PrevRightScore = tonumber(data.rightBarValue)
			end
		end
	end
end

-- add REPorter callouts
function NS:REPorter_IsleOfConquest_Add_Callouts()
	-- in combat lockdown?
	if (NS.faction ~= 0) then return end
	if (InCombatLockdown()) then
		-- update last raid warning
		TimerAfter(5, function()
			-- call again
			NS:REPorter_IsleOfConquest_Add_Callouts()
		end)

		-- finished
		return
	end

	-- add new overlays
	NS:REPorter_Add_New_Overlay("Docks")
	NS:REPorter_Add_New_Overlay("Hangar")
	NS:REPorter_Add_New_Overlay("Quarry")
	NS:REPorter_Add_New_Overlay("Refinery")
	NS:REPorter_Add_New_Overlay("Workshop")
end
