-- initialize
local LibStub = LibStub
local ADDON_NAME, NS = ...
if (not NS.Loaded or not NS.Loaded["Widgets"]) then return end
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
if (not L or not NS.CommFlare) then return end

-- localize stuff
local _G                                          = _G
local RequestBattlefieldScoreData                 = _G.RequestBattlefieldScoreData
local SetBattlefieldScoreFaction                  = _G.SetBattlefieldScoreFaction
local Settings_OpenToCategory                     = _G.Settings.OpenToCategory
local DateAndTimeGetServerTimeLocal               = _G.C_DateAndTime.GetServerTimeLocal
local ipairs                                      = _G.ipairs
local pairs                                       = _G.pairs
local print                                       = _G.print
local bitband                                     = _G.bit.band
local strformat                                   = _G.string.format
local strlower                                    = _G.string.lower
local strsplit                                    = _G.string.split

-- process slash command
local function Community_Flare_Slash_Command(input)
	-- version check?
	if (NS:IsOutdatedVersion() == true) then
		-- finished
		return
	end

	-- force input to lowercase
	local lower = strlower(input)
	if (lower == "assist") then
		-- available?
		if (NS.AssistButton and NS.ToggleAssistButton) then
			-- toggle assist button
			NS.ToggleAssistButton()
		end
	elseif (lower == "auras") then
		-- list helpful auras for target
		local helpful = NS:GetUnitAuras("target", "HELPFUL")
		if (helpful) then
			-- display helpful auras
			local numauras = 0
			print(L["Helpful Auras:"])
			for k,v in ipairs(helpful) do
				-- found name?
				if (v.name) then
					-- display aura
					print(strformat("%s: %s", L["Aura"], v.name))
					numauras = numauras + 1
				end
			end
			print(strformat(L["Found %d Auras."], numauras))
		end

		-- list harmful auras for target
		local harmful = NS:GetUnitAuras("target", "HARMFUL")
		if (harmful) then
			-- display helpful auras
			local numauras = 0
			print(L["Harmful Auras:"])
			for k,v in ipairs(harmful) do
				-- found name?
				if (v.name) then
					-- display aura
					print(strformat("%s: %s", L["Aura"], v.name))
					numauras = numauras + 1
				end
			end
			print(strformat(L["Found %d Auras."], numauras))
		end
	elseif (lower == "clm") then
		-- toggle community list
		NS:ToggleCommunityList()
	elseif (lower == "debug") then
		-- debug mode enabled?
		if (NS.db.global.debugMode == true) then
			-- expose local tables for debug purposes
			CommFlare_DB = NS.db
			CommFlare_CF = NS.CommFlare.CF
			CommFlare_LocalQueues = NS.CommFlare.CF.LocalQueues
			CommFlare_SocialQueues = NS.CommFlare.CF.SocialQueues
			if (NS.faction == 0) then CommFlare_NS = NS end
			print(strformat(L["%s: Local variables have been exposed globally for examination."], NS.CommFlare.Title))
		else
			-- debug mode not enabled
			print(strformat(L["%s: You must enable Debug Mode in Community Flare Addon settings to use this feature."], NS.CommFlare.Title))
		end
	elseif (lower == "defaults") then
		-- reset default settings
		local count = NS:Reset_Default_Settings()
		print(strformat(L["%s: Reset %d profile settings to default."], NS.CommFlare.Title, count))
	elseif (lower == "deployed") then
		-- check for deployed members
		NS:Check_For_Deployed_Members()
	elseif (lower == "demote") then
		-- do you have lead?
		local player = NS.CommFlare.CF.PlayerFullName
		NS.CommFlare.CF.PlayerRank = NS:GetRaidRank(NS.CommFlare.CF.PlayerName)
		if (NS.CommFlare.CF.PlayerRank == 2) then
			-- process all raid members
			for i=1, MAX_RAID_MEMBERS do
				-- player has assistant?
				local name, rank = NS:GetRaidRosterInfo(i)
				if (name and rank and (rank == 1)) then
					-- demote
					NS:DemoteAssistant(name)
				end
			end
		end
	elseif (lower == "leaders") then
		-- rebuild leaders
		NS:Rebuild_Community_Leaders()

		-- count community leaders
		local count = 0
		print(strformat(L["%s: Listing Community Leaders"], NS.CommFlare.Title))
		for _,v in ipairs(NS.CommFlare.CF.CommunityLeaders) do
			-- display
			print(v)

			-- next
			count = count + 1
		end

		-- display results
		print(strformat(L["%s: %d Community Leaders found."], NS.CommFlare.Title, count))
	elseif (lower == "mapid") then
		-- get map id
		local mapID = NS:GetBestMapForUnit("player")
		print(strformat(L["Map ID: %d"], mapID))
	elseif (lower == "options") then
		-- open settings
		Settings_OpenToCategory(NS.optionsID)
	elseif (lower == "perf") then
		-- run performance tests
		NS:Run_Performance_Tests()
	elseif (lower == "plm") then
		-- toggle player list
		NS:TogglePlayerList()
	elseif (lower == "pois") then
		-- toggle poi list
		NS:TogglePOIList()
	elseif (lower == "prune") then
		-- prune database
		local count = NS.CommFlare:Prune_Database()
		print(strformat(L["%s: Pruned %d Member GUIDs."], NS.CommFlare.Title, count))
	elseif (lower == "report") then
		-- get current queues text
		local text = NS:Get_Current_Queues_Text()
		if (text and (text ~= "")) then
			-- send to community
			NS:PopupBox("CommunityFlare_Send_Community_Dialog", text)
		else
			-- not currently in queue
			print(strformat(L["%s: Not currently in queue."], NS.CommFlare.Title))
		end
	elseif (lower == "refresh") then
		-- process club members
		local status = NS:Process_Club_Members()
		if (status == true) then
			-- refreshed database
			print(strformat(L["%s: Refreshed members database! %d members found."], NS.CommFlare.Title, NS:GetMemberCount()))
		else
			-- no subscribed clubs found
			print(strformat(L["%s: No subscribed clubs found."], NS.CommFlare.Title))
		end
	elseif (lower == "usage") then
		-- display usages
		print(strformat("%s: %s = %d", NS.CommFlare.Title, L["CPU Usage"], GetAddOnCPUUsage(ADDON_NAME)))
		print(strformat("%s: %s = %d", NS.CommFlare.Title, L["Memory Usage"], GetAddOnMemoryUsage(ADDON_NAME)))
	elseif (lower == "vehicles") then
		-- toggle vehicle list
		NS:ToggleVehicleList()
	elseif (lower == "vignettes") then
		-- toggle vignette list
		NS:ToggleVignetteList()
	else
		-- split words
		local first, second, third, fourth, fifth = strsplit(" ", input)
		first = strlower(first)
		if (first == "find") then
			-- has third?
			local clubId = NS.charDB.profile.communityMain
			if (third and (third ~= "")) then
				-- process all
				third = strlower(third)
				for k,v in pairs(NS.db.global.clubs) do
					-- matches short name?
					local shortName = strlower(v.shortName)
					if (shortName == third) then
						-- found
						clubId = k
						break
					end
				end
			end

			-- old?
			if (second == "old") then
				-- check for older members
				print(strformat("%s: %s ...", NS.CommFlare.Title, L["Checking for older members"]))
				NS:Find_ExCommunity_Members(clubId)
			-- inactive?
			elseif (second == "inactive") then
				-- find inactive members
				print(strformat("%s: %s ...", NS.CommFlare.Title, L["Checking for inactive members"]))
				NS:Find_Community_Members(second, clubId)
			-- inactivity?
			elseif (second == "inactivity") then
				-- find members not seen recently
				print(strformat("%s: %s ...", NS.CommFlare.Title, L["Checking for members not seen recently"]))
				NS:Find_Community_Members(second, clubId)
			-- noplay?
			elseif (second == "nocompleted") then
				-- find members who have never completed a match with you
				print(strformat("%s: %s ...", NS.CommFlare.Title, L["Checking for members who never have completed a match with you"]))
				NS:Find_Community_Members(second, clubId)
			-- nogroup?
			elseif (second == "nogrouped") then
				-- find members who have never grouped with you
				print(strformat("%s: %s ...", NS.CommFlare.Title, L["Checking for members who you've never grouped with"]))
				NS:Find_Community_Members(second, clubId)
			end
		-- reset?
		elseif (first == "reset") then
			-- clubs?
			if (second == "clubs") then
				-- reset clubs database
				NS.db.global.clubs = {}
				print(strformat("%s: %s", NS.CommFlare.Title, L["Cleared clubs database!"]))
			-- members?
			elseif (second == "members") then
				-- reset members database
				NS.db.global.members = {}
				print(strformat("%s: %s", NS.CommFlare.Title, L["Cleared members database!"]))
			-- positions?
			elseif (second == "positions") then
				-- reset player list frame position
				CF_PlayerListFrame:ClearAllPoints()
				CF_PlayerListFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
			end
		-- crate?
		elseif (first == "crate") then
			-- list?
			if (second == "list") then
				-- zone?
				local mapID = nil
				if (third == "mapid") then
					-- get mapID
					mapID = tonumber(fourth)
				else
					-- use current
					mapID = NS:GetBestMapForUnit("player")
				end

				-- has fifth?
				if (fifth) then
					-- force number
					fifth = tonumber(fifth)
				end

				-- process all
				local count = 0
				print(strformat(L["Map ID: %d"], mapID))
				for k,v in pairs(NS.CommFlare.CF.WarCrateLocations) do
					-- matching all?
					local matched = false
					if (third == "all") then
						-- matches mapID?
						if (v.mapID == mapID) then
							-- matched
							matched = true
						end
					-- matches mapID
					elseif (v.mapID == mapID) then
						-- has fifth?
						if (fifth) then
							-- matches vignetteID?
							if (v.vignetteID == fifth) then
								-- flying in?
								if (v.vignetteID == 3689) then
									-- has degree?
									if (v.degree) then
										-- matched
										matched = true
									end
								else
									-- matched
									matched = true
								end
							end
						else
							-- matches dropped location?
							if (v.vignetteID == 6066) then
								-- matched
								matched = true
							end
						end
					end

					-- matched?
					if (matched) then
						-- display
						print(strformat("vignetteID: %s, X: %s, Y: %s; Degree: %s", tostring(v.vignetteID), tostring(v.x), tostring(v.y), tostring(v.degree)))
						count = count + 1
					end
				end

				-- display count
				print(strformat(L["Found: %d War Supply Crate Locations."], count))
				return
			end

			-- found crates?
			local lastDropTime = nil
			local crates = NS:FindWarSupplyCrateData(second)
			local spawnUID = nil
			if (crates and (#crates > 0)) then
				-- process all
				crates = NS:SortTableValueKey(crates, "timestamp")
				for k,v in pairs(crates) do
					-- first?
					if (not spawnUID) then
						-- initialize
						spawnUID = v.spawnUID
					else
						-- newer?
						if (v.spawnUID > spawnUID) then
							-- debug print enabled?
							if (NS.db.global.debugPrint == true) then
								-- display time between crates
								print(strformat("%s: %d", L["Time Between"], v.spawnUID - spawnUID))
							end

							-- update
							lastDropTime = v.timestamp
							spawnUID = v.spawnUID
						end
					end
				end
			end

			-- has spawnUID?
			local timestamp = nil
			local currentTime = time()
			if (spawnUID) then
				-- calulate current
				currentTime = bitband(currentTime, -8388608)
				timestamp = currentTime + bitband(spawnUID, 8388607) + 1100
			end
	
			-- found?
			if (timestamp) then
				-- calculate next crate time
				while (timestamp < currentTime) do
					-- increase
					timestamp = timestamp + 1100
				end

				-- display
				print(strformat(L["Last Recorded Spawn Time: %s"], date(nil, lastDropTime)))
				print(strformat(L["Next Estimated Spawn Time: %s"], date(nil, timestamp)))
			else
				-- has spawnUID?
				if ((NS.faction == 0) and (NS.CommFlare.CF.spawnUID)) then
					-- calulate spawn time
					timestamp = DateAndTimeGetServerTimeLocal()
					timestamp = bitband(timestamp, -8388608) + bitband(NS.CommFlare.CF.spawnUID, 8388607)

					-- calculate next crate time
					while (timestamp < currentTime) do
						-- increase
						timestamp = timestamp + 1100
					end

					-- display
					print(strformat(L["Last Estimated Spawn Time: %s"], date(nil, timestamp - 1100)))
					print(strformat(L["Next Estimated Spawn Time: %s"], date(nil, timestamp)))
				else
					-- display
					print(strformat(L["Last Recorded Spawn Time: %s"], L["N/A"]))
				end
			end
		else
			-- in battleground?
			local timer = 0
			if (NS:IsInBattleground() == true) then
				-- battlefield score needs updating?
				if (PVPMatchScoreboard.selectedTab ~= 1) then
					-- update battlefield score
					NS.CommFlare.CF.WaitForUpdate = NS.CommFlare.CF.WaitForUpdate or {}
					NS.CommFlare.CF.WaitForUpdate["update"] = true
					SetBattlefieldScoreFaction(-1)

					-- delay 0.5 seconds
					timer = 0.5
				end
			end

			-- run immediately?
			if (timer == 0) then
				-- display full battleground setup
				NS:Update_Battleground_Stuff(true, true)
			end
		end
	end
end

-- register slash command
NS.CommFlare:RegisterChatCommand("comf", Community_Flare_Slash_Command)

-- fully loaded
NS.LoadCount = NS.LoadCount + 1
NS.Loaded["SlashCmd"] = NS.LoadCount
