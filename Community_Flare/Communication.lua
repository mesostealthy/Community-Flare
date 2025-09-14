-- initialize
local LibStub = LibStub
local ADDON_NAME, NS = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
if (not L or not NS.CommFlare) then return end

-- localize stuff
local _G                                        = _G
local IsInInstance                              = _G.IsInInstance
local IsInRaid                                  = _G.IsInRaid
local RaidWarningFrame_OnEvent                  = _G.RaidWarningFrame_OnEvent
local UnitName                                  = _G.UnitName
local MapGetMapInfo                             = _G.C_Map.GetMapInfo
local MinimapGetPOITextureCoords                = _G.C_Minimap.GetPOITextureCoords
local TimerAfter                                = _G.C_Timer.After
local TimerNewTimer                             = _G.C_Timer.NewTimer
local print                                     = _G.print
local time                                      = _G.time
local tonumber                                  = _G.tonumber
local bitband                                   = _G.bit.band
local strformat                                 = _G.string.format
local strsplit                                  = _G.string.split

-- process on communication received
function NS:Process_OnCommReceived(prefix, message, distribution, sender)
	-- get player name
	local player = UnitName("player")
	if (player == sender) then
		-- finished
		return
	end

	-- verify prefix
	if (prefix == ADDON_NAME) then
		-- community flare message?
		if (message:find("!CommFlare@")) then
			-- split args
			local args = {strsplit("@", message)}
			if (not args) then
				-- finished
				return
			end

			-- no version?
			if (not args[2] or (args[2] == "")) then
				-- finished
				return
			end

			-- no command
			if (not args[3] or (args[3] == "")) then
				-- finished
				return
			end

			-- boss attacked & has npc name?
			if (args[3] == "BOSS_ATTACKED") then
				-- instance chat message?
				if (distribution == "INSTANCE_CHAT") then
					-- has npc name?
					local npc_name = args[4]
					if (npc_name and (npc_name ~= "")) then
						-- debug print enabled?
						if (NS.db.global.debugPrint == true) then
							-- debug print
							NS:Debug_Print(strformat("%s: BOSS_ATTACKED = %s; %s", NS.CommFlare.Title, tostring(sender), tostring(npc_name)))
						end

						-- needs to issue raid warning?
						if (NS.CommFlare.CF.LastBossRW == 0) then
							-- update last raid warning
							local timer = 15
							NS.CommFlare.CF.LastBossRW = time()
							TimerAfter(timer, function()
								-- clear last raid warning
								NS.CommFlare.CF.LastBossRW = 0
							end)

							-- issue local raid warning (with raid warning audio sound)
							RaidWarningFrame_OnEvent(RaidBossEmoteFrame, "CHAT_MSG_RAID_WARNING", strformat(L["%s is under attack!"], npc_name))
						end
					end
				end
			-- vehicle dead?
			elseif (args[3] == "VEHICLE_DEAD") then
				-- get parameters
				local timestamp, destGUID, destName, destFlags = strsplit(",", args[4])

				-- vehicle death not already detected?
				if (not NS.CommFlare.CF.VehicleDeaths[destGUID] and timestamp and destGUID and destName and destFlags) then
					-- save time glaive died
					NS.CommFlare.CF.VehicleDeaths[destGUID] = timestamp

					-- is hostile?
					local hostile = false
					destFlags = tonumber(destFlags)
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

					-- catapult?
					local respawn_time = 180
					if (destName == L["Catapult"]) then
						-- 1 minute
						respawn_time = 60
					-- glaive thrower?
					elseif (destName == L["Glaive Thrower"]) then
						-- alert system enabled?
						if (NS.db.global.iocVehicleAlertSystem == true) then
							-- has player faction?
							if (NS.CommFlare.CF.PlayerInfo and NS.CommFlare.CF.PlayerInfo.faction) then
								-- player alliance?
								local name = nil
								local path = {136441}
								local factionColor = nil
								if (NS.CommFlare.CF.PlayerInfo.faction == 1) then
									-- hostile glaive?
									if (hostile == true) then
										-- setup stuff
										factionColor = "colorHorde"
										NS.CommFlare.CF.NumHordeGlaives = NS.CommFlare.CF.NumHordeGlaives + 1
										path[2], path[3], path[4], path[5] = MinimapGetPOITextureCoords(40) -- horde horse icon
										name = strformat("%s %d", L["Glaive Thrower"], NS.CommFlare.CF.NumHordeGlaives)
									else
										-- increase
										factionColor = "colorAlliance"
										NS.CommFlare.CF.NumAllyGlaives = NS.CommFlare.CF.NumAllyGlaives + 1
										path[2], path[3], path[4], path[5] = MinimapGetPOITextureCoords(38) -- alliance horse icon
										name = strformat("%s %d", L["Glaive Thrower"], NS.CommFlare.CF.NumAllyGlaives)
									end
								else
									-- hostile glaive?
									if (hostile == true) then
										-- increase
										factionColor = "colorAlliance"
										NS.CommFlare.CF.NumAllyGlaives = NS.CommFlare.CF.NumAllyGlaives + 1
										path[2], path[3], path[4], path[5] = MinimapGetPOITextureCoords(38) -- alliance horse icon
										name = strformat("%s %d", L["Glaive Thrower"], NS.CommFlare.CF.NumAllyGlaives)
									else
										-- setup stuff
										factionColor = "colorHorde"
										NS.CommFlare.CF.NumHordeGlaives = NS.CommFlare.CF.NumHordeGlaives + 1
										path[2], path[3], path[4], path[5] = MinimapGetPOITextureCoords(40) -- horde horse icon
										name = strformat("%s %d", L["Glaive Thrower"], NS.CommFlare.CF.NumHordeGlaives)
									end
								end

								-- add new capping bar
								NS:Capping_Add_New_Bar(name, respawn_time, factionColor, path)
							end
						end
					-- demolisher?
					elseif (destName == L["Demolisher"]) then
						-- 5-minute
						respawn_time = 300
					end

					-- alert system enabled?
					if (NS.db.global.iocVehicleAlertSystem == true) then
						-- hostile?
						if (hostile == true) then
							-- display message
							print(strformat("ENEMY VEHICLE DEAD: %s; %s; %s; %s", tostring(timestamp), tostring(destGUID), tostring(destName), tostring(destFlags)))
						else
							-- display message
							print(strformat("FRIENDLY VEHICLE DEAD: %s; %s; %s; %s", tostring(timestamp), tostring(destGUID), tostring(destName), tostring(destFlags)))
						end
					end

					-- enable respawn timer
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
			-- version checked?
			elseif (args[3] == "VERSION_CHECK") then
				-- debug print enabled?
				if (NS.db.global.debugPrint == true) then
					-- debug print
					NS:Debug_Print(strformat("%s: VERSION_CHECK = %s; %s", NS.CommFlare.Title, tostring(sender), tostring(distribution)))
				end

				-- guild or instance chat message?
				if ((distribution == "GUILD") or (distribution == "INSTANCE_CHAT")) then
					-- not already displayed?
					if (NS.CommFlare.CF.UpgradeDisplayed == false) then
						-- updated version?
						local updated = NS:Compare_Version(args[2])
						if (updated == true) then
							-- updated version
							print(strformat(L["%s version %s update available. Download the latest version from curseforge!"], NS.CommFlare.Title, args[2]))

							-- displayed
							NS.CommFlare.CF.UpgradeDisplayed = true
						end
					end
				end
			-- zone changed new area?
			elseif (args[3] == "ZONE_CHANGED_NEW_AREA") then
				-- party or raid message?
				if ((distribution == "PARTY") or (distribution == "RAID")) then
					-- notified when party member changes zones?
					if (NS.db.global.notifyPartyZoneChanges == true) then
						-- are you in a party?
						if (IsInGroup()) then
							-- are you group leader?
							if (NS:IsGroupLeader() == true) then
								-- has map name?
								local mapID, mapName = strsplit(":", message)
								if (not mapName) then
									-- get map info by id
									local info = MapGetMapInfo(tonumber(message))
									if (info and info.name) then
										-- set map name
										mapName = info.name
									else
										-- use full message (fall back)
										mapName = message
									end
								end

								-- debug print enabled?
								if (NS.db.global.debugPrint == true) then
									-- debug print
									NS:Debug_Print(strformat("%s: ZONE_CHANGED_NEW_AREA = %s; %s = %s", NS.CommFlare.Title, tostring(sender), tostring(distribution), tostring(mapName)))
								end

								-- display zone change message
								print(strformat(L["%s has changed zones to %s."], sender, mapName))
							end
						end
					end
				end
			end
		else
			-- group joined?
			if (message:find("GROUP_ROSTER_UPDATE")) then
				-- party message?
				if (distribution == "PARTY") then
					-- are you not group leader?
					if (NS:IsGroupLeader() ~= true) then
						-- community member?
						if (message:find("YES")) then
							-- enable community party leader
							NS.charDB.profile.communityPartyLeader = true
						end
					end
				end
			-- ready check?
			elseif (message:find("READY_CHECK")) then
				-- party or raid message?
				if ((distribution == "PARTY") or (distribution == "RAID")) then
					-- reply?
					if (message:find("READY_CHECK:")) then
						-- get unit for sender
						local unit = NS:GetPartyUnit(sender)
						player = NS:GetFullName(sender)
						if (unit and player) then
							-- split message
							local title, version, build = strsplit(":", message)
							if (not build) then
								-- not available
								build = L["N/A"]
							end

							-- save version number
							NS.CommFlare.CF.PartyVersions[unit] = version

							-- display player's community flare version / build
							print(strformat(L["%s has %s %s (%s)"], player, NS.CommFlare.Title, version, build))
						end
					else
						-- are you in a party / raid?
						if (IsInGroup()) then
							-- are you in a raid?
							local message = strformat("READY_CHECK:%s:%s", NS.CommFlare.Version, NS.CommFlare.Build)
							if (IsInRaid()) then
								-- send raid addon message
								NS.CommFlare:SendCommMessage(ADDON_NAME, message, "RAID")
							else
								-- send party addon message
								NS.CommFlare:SendCommMessage(ADDON_NAME, message, "PARTY")
							end
						end
					end
				end
			-- request party lead?
			elseif (message:find("REQUEST_PARTY_LEAD")) then
				-- instance chat, party or raid message?
				if ((distribution == "INSTANCE_CHAT") or (distribution == "PARTY") or (distribution == "RAID")) then
					-- process pass leadership
					NS:Process_Pass_Leadership(sender)
				end
			end
		end
	else
		-- zRdyCrate?
		if (prefix == "zRdyCrate") then
			-- not in instance?
			local inInstance, instanceType = IsInInstance()
			if (inInstance ~= true) then
				-- inside raid?
				if (IsInRaid() == true) then
					-- assume rdy war crate tracker being used
					NS.CommFlare.CF.RdyCrate = true
				end
			end
		end
	end
end
