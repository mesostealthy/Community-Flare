local LibStub = LibStub
local ADDON_NAME, NS = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)

-- localize stuff
local _G                                        = _G
local GetBattlefieldInstanceRunTime             = _G.GetBattlefieldInstanceRunTime
local GetNumBattlefieldScores                   = _G.GetNumBattlefieldScores
local PVPMatchScoreboard                        = _G.PVPMatchScoreboard
local RequestBattlefieldScoreData               = _G.RequestBattlefieldScoreData
local SetBattlefieldScoreFaction                = _G.SetBattlefieldScoreFaction
local PvPGetActiveMatchState                    = _G.C_PvP.GetActiveMatchState
local PvPGetScoreInfo                           = _G.C_PvP.GetScoreInfo
local TimerAfter                                = _G.C_Timer.After
local tonumber                                  = _G.tonumber
local type                                      = _G.type
local strformat                                 = _G.string.format
local strlower                                  = _G.string.lower

-- process debug args
function NS:Process_Debug_Command(sender, args)
	-- not debug mode?
	if (NS.charDB.profile.debugMode ~= true) then
		-- not enabled
		return
	end

	-- no shared community?
	if (NS:Has_Shared_Community(sender) == false) then
		-- finished
		return
	end

	-- verify debug!
	local command = strlower(args[1])
	if (command ~= "!debug") then
		-- finished
		return
	end

	-- process sub command
	local subcommand = strlower(args[2])
	if (subcommand == "numscores") then
		-- not active match?
		subcommand = "NumScores"
		if (PvPGetActiveMatchState() == Enum.PvPMatchState.Inactive) then
			-- send not in active match
			NS:SendMessage(sender, strformat(L["%s: Not currently in an active match."], subcommand))
			return
		end

		-- battlefield score needs updating?
		local timer = 0.0
		if (PVPMatchScoreboard.selectedTab ~= 1) then
			-- request battlefield score
			SetBattlefieldScoreFaction(-1)
			RequestBattlefieldScoreData()

			-- delay 0.5 seconds
			timer = 0.5
		end

		-- start processing
		TimerAfter(timer, function()
			-- send message
			local scores = GetNumBattlefieldScores()
			NS:SendMessage(sender, strformat("%s: %d", subcommand, scores))
		end)
	elseif (subcommand == "runtime") then
		-- not active match?
		subcommand = "RunTime"
		if (PvPGetActiveMatchState() == Enum.PvPMatchState.Inactive) then
			-- send not in active match
			NS:SendMessage(sender, strformat(L["%s: Not currently in an active match."], subcommand))
			return
		end

		-- send battlefield run time
		local runtime = GetBattlefieldInstanceRunTime()
		NS:SendMessage(sender, strformat("%s: %d", subcommand, runtime))
	elseif (subcommand == "scoreinfo") then
		-- not active match?
		subcommand = "ScoreInfo"
		if (PvPGetActiveMatchState() == Enum.PvPMatchState.Inactive) then
			-- send not in active match
			NS:SendMessage(sender, strformat(L["%s: Not currently in an active match."], subcommand))
			return
		end

		-- string value?
		if (type(args[3]) == "string") then
			-- convert to number
			args[3] = tonumber(args[3])
		end

		-- still not number?
		if (type(args[3]) ~= "number") then
			-- invalid index
			NS:SendMessage(sender, strformat(L["%s: Invalid index!"], subcommand))
			return
		end

		-- get score info
		local info = PvPGetScoreInfo(args[3])
		if (not info) then
			-- not found
			NS:SendMessage(sender, strformat(L["%s: Info not found!"], subcommand))
		else
			-- send score info
			NS:SendMessage(sender, strformat("%s: %s = %s; %s: %s; %s = %d; %s: %s", subcommand, L["Player"], info.name, L["GUID"], info.guid, L["Faction"], info.faction, L["Specialization"], info.talentSpec))
		end
	elseif (subcommand == "state") then
		-- not active match?
		subcommand = "State"
		if (PvPGetActiveMatchState() == Enum.PvPMatchState.Inactive) then
			-- send not in active match
			NS:SendMessage(sender, strformat(L["%s: Not currently in an active match."], subcommand))
			return
		end

		-- send active state
		local state = PvPGetActiveMatchState()
		NS:SendMessage(sender, strformat("%s: %d", subcommand, state))
	end
end
