-- initialize
local LibStub = LibStub
local ADDON_NAME, NS = ...
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
		if (diff > 30) then
			-- refresh
			bRefresh = true
		end
	end

	-- should refresh?
	if (bRefresh == true) then
		-- match engaged?
		local kosAlerts = {}
		local status = PvPGetActiveMatchState()
		if (status == Enum.PvPMatchState.Engaged) then
			-- process all
			for guid, player in pairs(NS.db.global.KosList) do
				-- not already alerted?
				if (not NS.CommFlare.CF.KosAlerted[guid]) then
					-- get score info by guid
					local info = NS:GetScoreInfoByPlayerGuid(guid)
					if (info and info.name) then
						-- process member guid
						NS:Process_MemberGUID(guid, player)

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
					-- force name-realm format
					local player = info.name
					if (not strmatch(player, "-")) then
						-- player is NOT AI?
						if (info.honorLevel > 0) then
							-- add realm name
							player = strformat("%s-%s", player, NS.CommFlare.CF.PlayerServerName)
						end
					end

					-- add roster
					NS.CommFlare.CF.FullRoster[player] = info

					-- has guid?
					if (info.guid) then
						-- player is NOT AI?
						if (info.honorLevel > 0) then
							-- process member guid
							local guid = info.guid
							NS:Process_MemberGUID(guid, player)

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
					end
				end
			end
		end

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
