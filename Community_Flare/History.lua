-- initialize
local LibStub = LibStub
local ADDON_NAME, NS = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
if (not L or not NS.CommFlare) then return end

-- localize stuff
local _G                                        = _G
local date                                      = _G.date
local next                                      = _G.next
local time                                      = _G.time
local type                                      = _G.type
local tonumber                                  = _G.tonumber
local strformat                                 = _G.string.format
local strgsub                                   = _G.string.gsub
local strmatch                                  = _G.string.match
local tinsert                                   = _G.table.insert

-- clean up history
function NS:Cleanup_History()
	-- process all
	local MON = { Jan = 1, Feb = 2, Mar = 3, Apr = 4, May = 5, Jun = 6, Jul = 7, Aug = 8, Sep = 9, Oct = 10, Nov = 11, Dec = 12 }
	for k,v in pairs(NS.globalDB.global.history) do
		-- last seen = old string format?
		if (v.lastseen and (type(v.lastseen) == "string")) then
			-- calculate timestamp
			local str = strgsub(v.lastseen, "  ", " ")
			local pattern = "(%a+) (%a+) (%d+) (%d+):(%d+):(%d+) (%d+)"
			local _, month, day, hour, min, sec, year = str:match(pattern)
			month = MON[month]
			local timestamp = time({day=day,month=month,year=year,hour=hour,min=min,sec=sec})

			-- update
			NS.globalDB.global.history[k].lastseen = timestamp
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
			NS.globalDB.global.history[k].lastgrouped = timestamp
		end

		-- last seen needs converted?
		if (NS.globalDB.global.history[k].lastseen) then
			-- move variable: Completed Matches Count (cmc)
			NS.globalDB.global.history[k].last = NS.globalDB.global.history[k].lastseen
			NS.globalDB.global.history[k].lastseen = nil
		end

		-- completed matches needs converted?
		if (v.completedmatches) then
			-- move variable: Completed Matches Count (cmc)
			NS.globalDB.global.history[k].cmc = NS.globalDB.global.history[k].completedmatches
			NS.globalDB.global.history[k].completedmatches = nil
		end

		-- grouped matches needs converted?
		if (v.groupedmatches) then
			-- move variable: Grouped Matches Count (gmc)
			NS.globalDB.global.history[k].gmc = NS.globalDB.global.history[k].groupedmatches
			NS.globalDB.global.history[k].groupedmatches = nil
		end

		-- no first seen?
		local updatefirst = false
		if (not NS.globalDB.global.history[k].first) then
			-- update first seen
			NS.globalDB.global.history[k].first = time()
		-- first seen after last seen?
		elseif (NS.globalDB.global.history[k].first and NS.globalDB.global.history[k].last and (NS.globalDB.global.history[k].first > NS.globalDB.global.history[k].last)) then
			-- update first seen
			NS.globalDB.global.history[k].first = NS.globalDB.global.history[k].last
		end
	end
end

-- get player history
function NS:Get_Player_History(player)
	-- build proper name
	if (not strmatch(player, "-")) then
		-- add realm name
		player = player .. "-" .. NS.CommFlare.CF.PlayerServerName
	end

	-- player not found?
	if (not NS.globalDB.global.history[player]) then
		-- failed
		return nil
	end

	-- return history
	return NS.globalDB.global.history[player]
end

-- update first seen
function NS:Update_First_Seen(player)
	-- build proper name
	if (not strmatch(player, "-")) then
		-- add realm name
		player = player .. "-" .. NS.CommFlare.CF.PlayerServerName
	end

	-- player not initialized?
	if (not NS.globalDB.global.history[player]) then
		-- initialize
		NS.globalDB.global.history[player] = {}
	end

	-- no first seen?
	if (not NS.globalDB.global.history[player].first) then
		-- update first seen
		NS.globalDB.global.history[player].first = time()
		return true
	end

	-- failed
	return false
end

-- update completed matches
function NS:Update_Completed_Matches(player)
	-- build proper name
	if (not strmatch(player, "-")) then
		-- add realm name
		player = player .. "-" .. NS.CommFlare.CF.PlayerServerName
	end

	-- player not initialized?
	if (not NS.globalDB.global.history[player]) then
		-- initialize
		NS.globalDB.global.history[player] = {}
	end

	-- first completed match?
	if (not NS.globalDB.global.history[player].cmc) then
		-- initialize
		NS.globalDB.global.history[player].cmc = 1
	else
		-- increase
		NS.globalDB.global.history[player].cmc = NS.globalDB.global.history[player].cmc + 1
	end

	-- success
	return true
end

-- update grouped matches
function NS:Update_Grouped_Matches(player)
	-- build proper name
	if (not strmatch(player, "-")) then
		-- add realm name
		player = player .. "-" .. NS.CommFlare.CF.PlayerServerName
	end

	-- player not initialized?
	if (not NS.globalDB.global.history[player]) then
		-- initialize
		NS.globalDB.global.history[player] = {}
	end

	-- first grouped match?
	if (not NS.globalDB.global.history[player].gmc) then
		-- initialize
		NS.globalDB.global.history[player].gmc = 1
	else
		-- increase
		NS.globalDB.global.history[player].gmc = NS.globalDB.global.history[player].gmc + 1
	end

	-- success
	return true
end

-- update last grouped
function NS:Update_Last_Grouped(player)
	-- build proper name
	if (not strmatch(player, "-")) then
		-- add realm name
		player = player .. "-" .. NS.CommFlare.CF.PlayerServerName
	end

	-- player not initialized?
	if (not NS.globalDB.global.history[player]) then
		-- initialize
		NS.globalDB.global.history[player] = {}
	end

	-- save last grouped
	NS.globalDB.global.history[player].lastgrouped = time()

	-- success
	return true
end

-- update last seen
function NS:Update_Last_Seen(player)
	-- build proper name
	if (not strmatch(player, "-")) then
		-- add realm name
		player = player .. "-" .. NS.CommFlare.CF.PlayerServerName
	end

	-- player not initialized?
	if (not NS.globalDB.global.history[player]) then
		-- initialize
		NS.globalDB.global.history[player] = {}
	end

	-- update last seen
	NS.globalDB.global.history[player].last = time()

	-- success
	return true
end

-- update chat message data
function NS:Update_Chat_Message_Data(player)
	-- build proper name
	if (not strmatch(player, "-")) then
		-- add realm name
		player = player .. "-" .. NS.CommFlare.CF.PlayerServerName
	end

	-- player not initialized?
	if (not NS.globalDB.global.history[player]) then
		-- initialize
		NS.globalDB.global.history[player] = {}
	end

	-- first chat message?
	if (not NS.globalDB.global.history[player].ncm) then
		-- initialize
		NS.globalDB.global.history[player].ncm = 1
	else
		-- increase
		NS.globalDB.global.history[player].ncm = NS.globalDB.global.history[player].ncm + 1
	end

	-- update last message time
	NS.globalDB.global.history[player].lcmt = time()

	-- success
	return true
end

-- get history list text
function NS:Get_History_List_Text(names)
	local text = nil
	local first, second = strsplit("@", names)
	if (first == "GetHistory") then
		-- multiple members?
		local members = {}
		if (strmatch(second, ",")) then
			-- get all members
			members = {strsplit(",", second)}
		else
			-- only one member
			tinsert(members, second)
		end

		-- has members?
		local list = nil
		if (members and next(members)) then
			-- process all
			list = {}
			for k,v in ipairs(members) do
				-- get player history
				local history = NS:Get_Player_History(v)
				if (history) then
					-- insert
					local firstseen = tonumber(history.first) or 0
					local lastseen = tonumber(history.last) or 0
					local lastgrouped = tonumber(history.lastgrouped) or 0
					local gmc = tonumber(history.gmc) or 0
					local cmc = tonumber(history.cmc) or 0
					local ncm = tonumber(history.ncm) or 0
					local lcmt = tonumber(history.lcmt) or 0
					tinsert(list, strformat("%s,%d,%d,%d,%d,%d,%d,%d", v, firstseen, lastseen, lastgrouped, gmc, cmc, ncm, lcmt))
				else
					-- insert
					tinsert(list, strformat("%s,nil", v))
				end
			end
		end

		-- found list?
		if (list and next(list)) then
			-- process all
			for k,v in ipairs(list) do
				-- first?
				if (not text) then
					-- initialize
					text = v
				else
					-- add text
					text = strformat("%s;%s", text, v)
				end
			end
		end
	end

	-- no text?
	if (not text) then
		-- none
		text = "None"
	end

	-- return text
	return text
end
