-- initialize
local LibStub = LibStub
local ADDON_NAME, NS = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
if (not L or not NS.CommFlare) then return end

-- localize stuff
local _G                                        = _G
local CombatLogGetCurrentEventInfo              = _G.CombatLogGetCurrentEventInfo
local RaidWarningFrame_OnEvent                  = _G.RaidWarningFrame_OnEvent
local TimerAfter                                = _G.C_Timer.After
local TimerNewTimer                             = _G.C_Timer.NewTimer
local print                                     = _G.print
local time                                      = _G.time
local tostring                                  = _G.tostring
local bitband                                   = _G.bit.band
local strformat                                 = _G.string.format

-- process ashran events
function NS:Process_Ashran_Events()
	-- SPELL_CAST_SUCCESS?
	local timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlag = CombatLogGetCurrentEventInfo()
	if (event == "SPELL_CAST_SUCCESS") then
		-- horde faction?
		if (NS.CommFlare.CF.PlayerFaction == L["Horde"]) then
			-- boss performing action?
			local timer = 15
			local npc_name = nil
			local npc_type = "boss"
			sourceFlags = tonumber(sourceFlags)
			if (sourceName == L["High Warlord Volrath"]) then
				-- needs to issue raid warning?
				if (NS.CommFlare.CF.LastBossRW == 0) then
					-- always warn
					npc_name = L["High Warlord Volrath"]
				end
			-- action performed on boss?
			elseif (destName == L["High Warlord Volrath"]) then
				-- needs to issue raid warning?
				if (NS.CommFlare.CF.LastBossRW == 0) then
					-- is source hostile?
					if (bitband(sourceFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) == COMBATLOG_OBJECT_REACTION_HOSTILE) then
						-- should warn
						npc_name = L["High Warlord Volrath"]
					end
				end
			-- action performed on mage?
			elseif (destName == L["Jeron Emberfall"]) then
				-- warn when mage is under attack?
				if (NS.db.global.ashranMageWarnAttacked > 1) then
					-- needs to issue raid warning?
					if (NS.CommFlare.CF.LastMageRW == 0) then
						-- is source hostile?
						if (bitband(sourceFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) == COMBATLOG_OBJECT_REACTION_HOSTILE) then
							-- should warn
							npc_name = L["Jeron Emberfall"]
							npc_type = "mage"
							timer = 30

							-- different frequency set?
							if (NS.db.global.ashranMageWarnFreq == 1) then
								-- 15 seconds
								timer = 15
							elseif (NS.db.global.ashranMageWarnFreq == 3) then
								-- 60 seconds
								timer = 60
							end
						end
					end
				end
			end

			-- npc found?
			if (npc_name) then
				-- boss?
				local issue_warning = false
				if (npc_type == "boss") then
					-- needs to issue raid warning?
					if (NS.CommFlare.CF.LastBossRW == 0) then
						-- update last raid warning
						NS.CommFlare.CF.LastBossRW = time()
						TimerAfter(timer, function()
							-- clear last raid warning
							NS.CommFlare.CF.LastBossRW = 0
						end)

						-- has npc name?
						if (npc_name and (npc_name ~= "")) then
							-- send instance addon message
							local message = strformat("!CommFlare@%s@BOSS_ATTACKED@%s", NS.CommFlare.Version, npc_name)
							NS.CommFlare:SendCommMessage(ADDON_NAME, message, "INSTANCE_CHAT")
						end

						-- issue warning
						issue_warning = true
					end
				-- mage?
				elseif (npc_type == "mage") then
					-- needs to issue raid warning?
					if (NS.CommFlare.CF.LastMageRW == 0) then
						-- update last raid warning
						NS.CommFlare.CF.LastMageRW = time()
						TimerAfter(timer, function()
							-- clear last raid warning
							NS.CommFlare.CF.LastMageRW = 0
						end)

						-- issue warning
						issue_warning = true
					end
				end

				-- should issue warning?
				if (issue_warning == true) then
					-- issue local raid warning (with raid warning audio sound)
					RaidWarningFrame_OnEvent(RaidBossEmoteFrame, "CHAT_MSG_RAID_WARNING", strformat(L["%s is under attack!"], npc_name))
				end
			end
		end
	end
end

-- process IOC events
function NS:Process_IOC_Events()
	-- UNIT_DIED?
	local timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlag = CombatLogGetCurrentEventInfo()
	if (event == "UNIT_DIED") then
		-- catapult?
		local should_log = false
		local respawn_time = 180
		if (destName == L["Catapult"]) then
			-- log this
			should_log = true
			respawn_time = 60	-- 1 minute
		elseif (destName == L["Demolisher"]) then
			-- log this
			should_log = true
			respawn_time = 300	-- 5 minutes
		-- glaive thrower?
		elseif (destName == L["Glaive Thrower"]) then
			-- log this
			should_log = true
		-- siege engine?
		elseif (destName == L["Siege Engine"]) then
			-- log this
			should_log = true
		end

		-- should log?
		if (should_log == true) then
			-- vehicle death not already detected?
			if (not NS.CommFlare.CF.VehicleDeaths[destGUID]) then
				-- save time glaive died
				NS.CommFlare.CF.VehicleDeaths[destGUID] = timestamp

				-- send instance addon message
				local message = strformat("!CommFlare@%s@VEHICLE_DEAD@%s,%s,%s,%s", NS.CommFlare.Version, tostring(timestamp), tostring(destGUID), tostring(destName), tostring(destFlags))
				NS.CommFlare:SendCommMessage(ADDON_NAME, message, "INSTANCE_CHAT")

				-- is hostile?
				local hostile = false
				if (bitband(destFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) == COMBATLOG_OBJECT_REACTION_HOSTILE) then
					-- hostile
					hostile = true
				end

				-- initialize active timer
				NS.CommFlare.CF.ActiveTimers[destGUID] = {
					["timestamp"] = timestamp,
					["guid"] = destGUID,
					["name"] = destName,
					["flags"] = destFlags,
					["hostile"] = hostile,
					["timer"] = {},
				}

				-- alert system enabled?
				if (NS.db.global.iocVehicleAlertSystem == true) then
					-- hostile?
					if (hostile == true) then
						-- display message
						print(strformat("ENEMY VEHICLE DEAD: %s; %s; %s", tostring(timestamp), tostring(destGUID), tostring(destName), tostring(destFlags)))
					else
						-- display message
						print(strformat("FRIENDLY VEHICLE DEAD: %s; %s; %s", tostring(timestamp), tostring(destGUID), tostring(destName), tostring(destFlags)))
					end
				end

				-- start timer for respawn
				NS.CommFlare.CF.ActiveTimers[destGUID].timer = TimerNewTimer(respawn_time, function()
					-- alert system enabled?
					if (NS.db.global.iocVehicleAlertSystem == true) then
						-- hostile?
						local name = NS.CommFlare.CF.ActiveTimers[destGUID].name
						if (NS.CommFlare.CF.ActiveTimers[destGUID].hostile == true) then
							-- display message
							print(strformat("NEW ENEMY VEHICLE: %s should be spawned/spawning now!", name))
						else
							-- display message
							print(strformat("NEW FRIENDLY VEHICLE: %s should be spawned/spawning now!", name))
						end
					end

					-- remove active timer
					NS.CommFlare.CF.ActiveTimers[destGUID] = nil
				end)
			end
		end
	end
end

-- process combat log event unfiltered
function NS:Process_Combat_Log_Event_Unfiltered()
	-- ashran?
	if (NS.CommFlare.CF.MapID == 1478) then
		-- process ashran events
		NS:Process_Ashran_Events()
	-- isle of conquest?
	elseif (NS.CommFlare.CF.MapID == 169) then
		-- process IOC events
		NS:Process_IOC_Events()
	end
end
