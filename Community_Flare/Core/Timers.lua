-- initialize
local LibStub = LibStub
local ADDON_NAME, NS = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
if (not L or not NS.CommFlare) then return end
 
-- localize stuff
local _G                                          = _G
local TimerNewTimer                               = _G.C_Timer.NewTimer
local next                                        = _G.next
local pairs                                       = _G.pairs
local print                                       = _G.print
local time                                        = _G.time
local strformat                                   = _G.string.format

-- refresh active timers
function NS:Refresh_Active_Timers()
	-- has active timers?
	if (NS.CommFlare.CF.ActiveTimers and next(NS.CommFlare.CF.ActiveTimers)) then
		-- process all timers
		for k,v in pairs(NS.CommFlare.CF.ActiveTimers) do
			-- sanity checks
			if (v.name and v.death_time and v.respawn_time and v.factionColor and v.path) then
				-- calculate seconds left
				local seconds = time() - v.death_time
				if ((seconds > 0) and (seconds < v.respawn_time)) then
					-- add new capping bar
					local respawn_time = v.respawn_time - seconds
					NS:Capping_Add_New_Bar(v.name, respawn_time, v.factionColor, v.path)

					-- start timer for respawn
					NS.CommFlare.CF.ActiveTimers[k].timer = TimerNewTimer(respawn_time, function()
						-- alert system enabled?
						if (NS.db.global.iocVehicleAlertSystem == true) then
							-- hostile?
							local name = NS.CommFlare.CF.ActiveTimers[k].name
							if (NS.CommFlare.CF.ActiveTimers[k].hostile == true) then
								-- display message
								print(strformat("NEW ENEMY VEHICLE: %s should be spawned/spawning now!", name))
							else
								-- display message
								print(strformat("NEW FRIENDLY VEHICLE: %s should be spawned/spawning now!", name))
							end
						end

						-- remove active timer
						NS.CommFlare.CF.ActiveTimers[k] = nil
					end)
				end
			end
		end
	end
end
