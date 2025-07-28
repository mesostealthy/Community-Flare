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
				-- vehicle death not already detected?
				local timestamp, guid, name, flags = {strsplit(",", args[4])}
				if (not NS.CommFlare.CF.VehicleDeaths[guid] and timestamp and guid and name and flags) then
					-- save time glaive died
					NS.CommFlare.CF.VehicleDeaths[destGUID] = timestamp

					-- is hostile?
					local hostile = false
					flags = tonumber(flags)
					if (bitband(flags, COMBATLOG_OBJECT_REACTION_HOSTILE) == COMBATLOG_OBJECT_REACTION_HOSTILE) then
						-- hostile
						hostile = true
					end

					-- initialize active timer
					NS.CommFlare.CF.ActiveTimers[guid] = {
						["timestamp"] = timestamp,
						["guid"] = guid,
						["name"] = name,
						["flags"] = flags,
						["hostile"] = hostile,
						["timer"] = {},
					}

					-- alert system enabled?
					if (NS.db.global.iocVehicleAlertSystem == true) then
						-- hostile?
						if (hostile == true) then
							-- display message
							print(strformat("ENEMY VEHICLE DEAD: %s; %s; %s; %s", tostring(timestamp), tostring(guid), tostring(name), tostring(flags)))
						else
							-- display message
							print(strformat("FRIENDLY VEHICLE DEAD: %s; %s; %s; %s", tostring(timestamp), tostring(guid), tostring(name), tostring(flags)))
						end
					end

					-- catapult?
					local respawn_time = 180
					if (destName == L["Catapult"]) then
						-- 1 minute
						respawn_time = 60
					elseif (destName == L["Demolisher"]) then
						-- 5-minute
						respawn_time = 300
					end

					-- enable respawn timer
					NS.CommFlare.CF.ActiveTimers[guid].timer = TimerNewTimer(respawn_time, function()
						-- alert system enabled?
						if (NS.db.global.iocVehicleAlertSystem == true) then
							-- hostile?
							local name = NS.CommFlare.CF.ActiveTimers[guid].name
							if (NS.CommFlare.CF.ActiveTimers[guid].hostile == true) then
								-- display message
								print(strformat("NEW ENEMY VEHICLE: %s should be spawned/spawning now!", name))
							else
								-- display message
								print(strformat("NEW FRIENDLY VEHICLE: %s should be spawned/spawning now!", name))
							end
						end

						-- remove active timer
						NS.CommFlare.CF.ActiveTimers[guid] = nil
					end)
				end
			-- version checked?
			elseif (args[3] == "VERSION_CHECK") then
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
