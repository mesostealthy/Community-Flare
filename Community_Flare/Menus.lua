local LibStub = LibStub
local ADDON_NAME, NS = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)

-- localize stuff
local _G                                        = _G
local date                                      = _G.date
local print                                     = _G.print
local tostring                                  = _G.tostring
local type                                      = _G.type
local strformat                                 = _G.string.format

-- show history
function NS:Show_History(owner, rootDescription, contextData)
	-- find member
	local player = strformat("%s-%s", contextData.name, contextData.server)
	local member = NS:Get_Community_Member(player)
	if (member) then
		-- get player history
		print(strformat("%s: %s", NS.CommFlare.Title, member.name))
		local history = NS:Get_Player_History(player)
		if (history) then
			-- has first seen?
			if (history.first) then
				-- show first seen time
				local firstseen = date("%Y-%m-%d %H:%M:%S", history.first)
				print(strformat("%s: %s %s", L["First Seen"], L["Around"], firstseen))
			end

			-- has last seen?
			if (history.last) then
				-- string?
				if (type(history.last) == "string") then
					-- show last seen time
					print(strformat("%s: %s %s", L["Last Seen"], L["Around"], history.last))
				else
					-- show last seen time
					local lastseen = date("%Y-%m-%d %H:%M:%S", history.last)
					print(strformat("%s: %s %s", L["Last Seen"], L["Around"], lastseen))
				end
			else
				-- not seen recently
				print(strformat("%s: %s", L["Last Seen"], L["Not seen recently."]))
			end

			-- has last grouped?
			if (history.lastgrouped) then
				-- string?
				if (type(history.lastgrouped) == "string") then
					-- display last grouped
					print(strformat("%s: %s", L["Last Grouped"], history.lastgrouped))
				else
					-- display last grouped
					local lastgrouped = date("%Y-%m-%d %H:%M:%S", history.lastgrouped)
					print(strformat("%s: %s", L["Last Grouped"], lastgrouped))
				end
			end

			-- has grouped matches?
			if (history.gmc) then
				-- display grouped matches count
				print(strformat("%s: %d", L["Grouped Match Count"], history.gmc))
			end

			-- has completed matches?
			if (history.cmc) then
				-- display completed matches count
				print(strformat("%s: %d", L["Completed Match Count"], history.cmc))
			end

			-- has community message count?
			if (history.ncm) then
				-- display community messages sent
				print(strformat("%s: %d", L["Community Messages Sent"], history.ncm))
			end

			-- has last community message time?
			if (history.lcmt) then
				-- display last grouped
				local timestamp = date("%Y-%m-%d %H:%M:%S", history.lcmt)
				print(strformat("%s: %s", L["Last Community Message Sent"], timestamp))
			end
		end
	else
		-- not in database yet
		print(strformat("%s: %s %s", L["Last Seen"], tostring(player), L["is NOT in the Database."]))
	end
end

-- request party lead
function NS:Request_Party_Leader(owner, rootDescription, contextData)
	-- send addon message to party
	NS.CommFlare:SendCommMessage(ADDON_NAME, "REQUEST_PARTY_LEAD", "PARTY")
end

-- add community context menu
Menu.ModifyMenu("MENU_UNIT_COMMUNITIES_WOW_MEMBER", function(owner, rootDescription, contextData)
	-- display context menu
	rootDescription:CreateDivider()
	rootDescription:CreateTitle(NS.CommFlare.Title)
	rootDescription:CreateButton(L["Last Seen Around?"], function() NS:Show_History(owner, rootDescription, contextData) end)
end)

-- add party context menu
Menu.ModifyMenu("MENU_UNIT_PARTY", function(owner, rootDescription, contextData)
	-- are you not group leader currently?
	if (NS:IsGroupLeader() == false) then
		-- display context menu
		rootDescription:CreateDivider()
		rootDescription:CreateTitle(NS.CommFlare.Title)
		rootDescription:CreateButton(L["Request Party Leader"], function() NS:Request_Party_Leader(owner, rootDescription, contextData) end)
	end
end)
