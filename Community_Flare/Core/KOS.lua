-- initialize
local LibStub = LibStub
local ADDON_NAME, NS = ...
if (not NS.Loaded or not NS.Loaded["Housing"]) then return end
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
if (not L or not NS.CommFlare) then return end

-- localize stuff
local _G                                          = _G
local GetNumBattlefieldScores                     = _G.GetNumBattlefieldScores
local RaidWarningFrame_OnEvent                    = _G.RaidWarningFrame_OnEvent
local PvPGetActiveMatchState                      = _G.C_PvP.GetActiveMatchState
local ipairs                                      = _G.ipairs
local issecretvalue                               = _G.issecretvalue
local pairs                                       = _G.pairs
local time                                        = _G.time
local strformat                                   = _G.string.format
local strmatch                                    = _G.string.match
local tinsert                                     = _G.table.insert
local tsort                                       = _G.table.sort

-- local variables
local kosAlerts = {}
local playerScores = {}

-- check score board for KOS
function NS:CheckScoreBoardForKos()
	-- not created?
	if (not NS.db.global.KosList) then
		-- initialize
		NS.db.global.KosList = {}
	end

	-- should refresh?
	local bRefresh = false
	if (NS.CommFlare.CF.KosRefreshTime == 0) then
		-- refresh
		bRefresh = true
	else
		-- calculate difference
		local diff = time() - NS.CommFlare.CF.KosRefreshTime
		if (diff > 10) then
			-- refresh
			bRefresh = true
		end
	end

	-- should refresh?
	local numEnemies = 0
	if (bRefresh) then
		-- match engaged?
		wipe(kosAlerts)
		local status = PvPGetActiveMatchState()
		if (status == Enum.PvPMatchState.Engaged) then
			-- process all scores
			wipe(playerScores)
			local numScores = GetNumBattlefieldScores()
			for i=1, numScores do
				-- get score info
				local info = NS:GetScoreInfo(i)
				if (info and info.name and not issecretvalue(info.name)) then
					-- force name-realm format
					local player = info.name
					if (not strmatch(player, "-")) then
						-- add realm name
						player = strformat("%s-%s", player, NS.CommFlare.CF.PlayerServerName)
					end

					-- add player
					NS.CommFlare.FullRoster[player] = info
					playerScores[player] = true
				end
			end

			-- process all
			for guid,player in pairs(NS.db.global.KosList) do
				-- not already alerted?
				if (not NS.CommFlare.CF.KosAlerted[guid]) then
					-- player in match?
					if (playerScores[player]) then
						-- process player guid
						NS:Process_PlayerGUID(guid, player)

						-- insert
						NS.CommFlare.CF.KosAlerted[guid] = player
						tinsert(kosAlerts, player)
					end
				end
			end
		else
			-- process all scores
			local numScores = GetNumBattlefieldScores()
			for i=1, numScores do
				local info = NS:GetScoreInfo(i)
				if (info and info.name and not issecretvalue(info.name)) then
					-- has guid?
					local player = info.name
					if (info.guid and not issecretvalue(info.guid)) then
						-- player is NOT AI?
						if (info.honorLevel > 0) then
							-- force name-realm format
							if (not strmatch(player, "-")) then
								-- add realm name
								player = strformat("%s-%s", player, NS.CommFlare.CF.PlayerServerName)
							end

							-- process player guid
							local guid = info.guid
							NS:Process_PlayerGUID(guid, player)

							-- KOS target?
							if (NS.db.global.KosList[guid]) then
								-- not already alerted?
								if (not NS.CommFlare.CF.KosAlerted[guid]) then
									-- insert
									NS.CommFlare.CF.KosAlerted[guid] = player
									tinsert(kosAlerts, player)
								end
							end
						end

						-- enemy team?
						if (info.faction ~= NS.CommFlare.CF.PlayerFactionID) then
							-- increase
							numEnemies = numEnemies + 1
						end
					end

					-- add player
					NS.CommFlare.FullRoster[player] = info
				end
			end
		end

		-- found enemies?
		if (numEnemies > 0) then
			-- any alerts?
			if (#kosAlerts > 0) then
				-- sort
				tsort(kosAlerts)

				-- process all
				local text = nil
				for k,v in ipairs(kosAlerts) do
					-- first?
					if (not text) then
						-- initialize
						text = v
					else
						-- append
						text = strformat("%s, %s", text, v)
					end
				end

				-- has text?
				if (text) then
					-- issue local raid warning (with raid warning audio sound)
					RaidWarningFrame_OnEvent(RaidBossEmoteFrame, "CHAT_MSG_RAID_WARNING", strformat("KOS: %s", text))
				end
			end

			-- update time
			NS.CommFlare.CF.KosRefreshTime = time()
		end
	end
end

-- fully loaded
NS.LoadCount = NS.LoadCount + 1
NS.Loaded["KOS"] = NS.LoadCount
