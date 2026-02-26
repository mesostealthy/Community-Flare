-- initialize
local LibStub = LibStub
local ADDON_NAME, NS = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
if (not L or not NS.CommFlare) then return end

-- localize stuff
local _G                                          = _G
local date                                        = _G.date
local next                                        = _G.next
local time                                        = _G.time
local type                                        = _G.type
local tonumber                                    = _G.tonumber
local strformat                                   = _G.string.format
local strgsub                                     = _G.string.gsub
local strmatch                                    = _G.string.match
local tinsert                                     = _G.table.insert

-- clean up history
function NS:Cleanup_History()
	-- process all
	local MON = { Jan = 1, Feb = 2, Mar = 3, Apr = 4, May = 5, Jun = 6, Jul = 7, Aug = 8, Sep = 9, Oct = 10, Nov = 11, Dec = 12 }
	for k,v in pairs(NS.db.global.history) do
		-- last seen = old string format?
		if (v.lastseen and (type(v.lastseen) == "string")) then
			-- calculate timestamp
			local str = strgsub(v.lastseen, "  ", " ")
			local pattern = "(%a+) (%a+) (%d+) (%d+):(%d+):(%d+) (%d+)"
			local _, month, day, hour, min, sec, year = str:match(pattern)
			month = MON[month]
			local timestamp = time({day=day,month=month,year=year,hour=hour,min=min,sec=sec})

			-- update
			NS.db.global.history[k].lastseen = timestamp
		end

		-- last grouped = old string format?
		if (v.lastgrouped and (type(v.lastgrouped) == "string")) then
			-- calculate timestamp
			local str = strgsub(v.lastgrouped, "  ", " ")
			local pattern = "(%a+) (%a+) (%d+) (%d+):(%d+):(%d+) (%d+)"
			local _, month, day, hour, min, sec, year = str:match(pattern)
			month = MON[month]
			local timestamp = time({day=day,month=month,year=year,hour=hour,min=min,sec=sec})

			-- update
			NS.db.global.history[k].lastgrouped = timestamp
		end

		-- last seen needs converted?
		if (NS.db.global.history[k].lastseen) then
			-- move variable: Completed Matches Count (cmc)
			NS.db.global.history[k].last = NS.db.global.history[k].lastseen
			NS.db.global.history[k].lastseen = nil
		end

		-- completed matches needs converted?
		if (v.completedmatches) then
			-- move variable: Completed Matches Count (cmc)
			NS.db.global.history[k].cmc = NS.db.global.history[k].completedmatches
			NS.db.global.history[k].completedmatches = nil
		end

		-- grouped matches needs converted?
		if (v.groupedmatches) then
			-- move variable: Grouped Matches Count (gmc)
			NS.db.global.history[k].gmc = NS.db.global.history[k].groupedmatches
			NS.db.global.history[k].groupedmatches = nil
		end

		-- no first seen?
		local updatefirst = false
		if (not NS.db.global.history[k].first) then
			-- update first seen
			NS.db.global.history[k].first = time()
		-- first seen after last seen?
		elseif (NS.db.global.history[k].first and NS.db.global.history[k].last and (NS.db.global.history[k].first > NS.db.global.history[k].last)) then
			-- update first seen
			NS.db.global.history[k].first = NS.db.global.history[k].last
		end
	end
end

-- get player history
function NS:Get_Player_History(player)
	-- invalid?
	if (not player or (player == "")) then
		-- failed
		return nil
	end

	-- build proper name
	if (not strmatch(player, "-")) then
		-- add realm name
		player = strformat("%s-%s", player, NS.CommFlare.CF.PlayerServerName)
	end

	-- player not found?
	if (not NS.db.global.history[player]) then
		-- failed
		return nil
	end

	-- return history
	return NS.db.global.history[player]
end

-- update first seen
function NS:Update_First_Seen(player)
	-- invalid?
	if (not player or (player == "")) then
		-- failed
		return false
	end

	-- build proper name
	if (not strmatch(player, "-")) then
		-- add realm name
		player = strformat("%s-%s", player, NS.CommFlare.CF.PlayerServerName)
	end

	-- player not initialized?
	if (not NS.db.global.history[player]) then
		-- initialize
		NS.db.global.history[player] = {}
	end

	-- no first seen?
	if (not NS.db.global.history[player].first) then
		-- update first seen
		NS.db.global.history[player].first = time()
		return true
	end

	-- failed
	return false
end

-- update completed matches
function NS:Update_Completed_Matches(player)
	-- invalid?
	if (not player or (player == "")) then
		-- failed
		return false
	end

	-- build proper name
	if (not strmatch(player, "-")) then
		-- add realm name
		player = strformat("%s-%s", player, NS.CommFlare.CF.PlayerServerName)
	end

	-- player not initialized?
	if (not NS.db.global.history[player]) then
		-- initialize
		NS.db.global.history[player] = {}
	end

	-- first completed match?
	if (not NS.db.global.history[player].cmc) then
		-- initialize
		NS.db.global.history[player].cmc = 1
	else
		-- increase
		NS.db.global.history[player].cmc = NS.db.global.history[player].cmc + 1
	end

	-- success
	return true
end

-- update grouped matches
function NS:Update_Grouped_Matches(player)
	-- invalid?
	if (not player or (player == "")) then
		-- failed
		return false
	end

	-- build proper name
	if (not strmatch(player, "-")) then
		-- add realm name
		player = strformat("%s-%s", player, NS.CommFlare.CF.PlayerServerName)
	end

	-- player not initialized?
	if (not NS.db.global.history[player]) then
		-- initialize
		NS.db.global.history[player] = {}
	end

	-- first grouped match?
	if (not NS.db.global.history[player].gmc) then
		-- initialize
		NS.db.global.history[player].gmc = 1
	else
		-- increase
		NS.db.global.history[player].gmc = NS.db.global.history[player].gmc + 1
	end

	-- success
	return true
end

-- update last grouped
function NS:Update_Last_Grouped(player)
	-- invalid?
	if (not player or (player == "")) then
		-- failed
		return false
	end

	-- build proper name
	if (not strmatch(player, "-")) then
		-- add realm name
		player = strformat("%s-%s", player, NS.CommFlare.CF.PlayerServerName)
	end

	-- player not initialized?
	if (not NS.db.global.history[player]) then
		-- initialize
		NS.db.global.history[player] = {}
	end

	-- save last grouped
	NS.db.global.history[player].lastgrouped = time()

	-- success
	return true
end

-- update last seen
function NS:Update_Last_Seen(player)
	-- invalid?
	if (not player or (player == "")) then
		-- failed
		return false
	end

	-- build proper name
	if (not strmatch(player, "-")) then
		-- add realm name
		player = strformat("%s-%s", player, NS.CommFlare.CF.PlayerServerName)
	end

	-- player not initialized?
	if (not NS.db.global.history[player]) then
		-- initialize
		NS.db.global.history[player] = {}
	end

	-- update last seen
	NS.db.global.history[player].last = time()

	-- success
	return true
end

-- update chat message data
function NS:Update_Chat_Message_Data(player)
	-- invalid?
	if (not player or (player == "")) then
		-- failed
		return false
	end

	-- build proper name
	if (not strmatch(player, "-")) then
		-- add realm name
		player = strformat("%s-%s", player, NS.CommFlare.CF.PlayerServerName)
	end

	-- player not initialized?
	if (not NS.db.global.history[player]) then
		-- initialize
		NS.db.global.history[player] = {}
	end

	-- first chat message?
	if (not NS.db.global.history[player].ncm) then
		-- initialize
		NS.db.global.history[player].ncm = 1
	else
		-- increase
		NS.db.global.history[player].ncm = NS.db.global.history[player].ncm + 1
	end

	-- update last message time
	NS.db.global.history[player].lcmt = time()

	-- success
	return true
end
