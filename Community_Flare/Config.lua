local LibStub = LibStub
local ADDON_NAME, NS = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)

-- localize stuff
local _G                                        = _G
local StaticPopupDialogs                        = _G.StaticPopupDialogs
local UnitGetAvailableRoles                     = _G.UnitGetAvailableRoles
local ClubGetSubscribedClubs                    = _G.C_Club.GetSubscribedClubs
local ReloadUI                                  = _G.C_UI.Reload
local ipairs                                    = _G.ipairs
local next                                      = _G.next
local print                                     = _G.print
local strformat                                 = _G.string.format
local tinsert                                   = _G.table.insert

-- local variables
local settings_that_require_reload = {}

-- setup main community list
local function Setup_Main_Community_List(info)
	-- has info?
	local list = {}
	list[1] = L["None"]
	if (info) then
		-- verify default community setup
		NS:Verify_Default_Community_Setup()

		-- process all
		NS.CommFlare.CF.ClubCount = 0
		NS.CommFlare.CF.Clubs = ClubGetSubscribedClubs()
		for _,v in ipairs(NS.CommFlare.CF.Clubs) do
			-- only communities
			if (v.clubType == Enum.ClubType.Character) then
				-- add club
				list[v.clubId] = v.name
				NS.CommFlare.CF.ClubCount = NS.CommFlare.CF.ClubCount + 1
			end
		end
	end

	-- return list
	return list
end

-- set main community
local function Set_Main_Community(info, value)
	-- has club id to add for?
	if (value and (value > 1)) then
		-- add all club members
		NS:Add_All_Club_Members_By_ClubID(value)

		-- set default report ID
		NS.charDB.profile.communityReportID = value

		-- has value?
		if (value and (value > 1)) then
			-- enable community lists
			NS.charDB.profile.communityLogList[value] = true
			NS.charDB.profile.communityLeadersList[value] = true
		end

		-- readd community chat window
		NS:ReaddCommunityChatWindow(NS.charDB.profile.communityReportID, 1)
	else

		-- find main community club
		local clubs = {}
		if (NS.charDB.profile.communityMain > 0) then
			-- add club id
			tinsert(clubs, NS.charDB.profile.communityMain)
		end

		-- has community list?
		if (NS.charDB.profile.communityList and (next(NS.charDB.profile.communityList) ~= nil)) then
			-- process all lists
			for k,_ in pairs(NS.charDB.profile.communityList) do
				-- add club id
				tinsert(clubs, k)
			end
		end

		-- process clubs
		for _,clubId in ipairs(clubs) do
			-- remove all club members
			NS:Remove_All_Club_Members_By_ClubID(clubId)

			-- disable community lists
			NS.charDB.profile.communityLogList[clubId] = nil
			NS.charDB.profile.communityLeadersList[clubId] = nil
		end

		-- clear community report id
		NS.charDB.profile.communityReportID = 1

		-- disable community leaders list
		NS.charDB.profile.communityLeadersList[value] = nil
	end

	-- rebuild community leaders
	NS:Rebuild_Community_Leaders()

	-- save main community
	NS.charDB.profile.communityMain = value

	-- always clear community list
	NS.charDB.profile.communityList = {}
end

-- setup other community list
local function Setup_Other_Community_List(info)
	-- process all
	local list = {}
	NS.CommFlare.CF.ClubCount = 0
	NS.CommFlare.CF.Clubs = ClubGetSubscribedClubs()
	for _,v in ipairs(NS.CommFlare.CF.Clubs) do
		-- only communities
		if (v.clubType == Enum.ClubType.Character) then
			-- has main community?
			local add = true
			if (NS.charDB.profile.communityMain and (NS.charDB.profile.communityMain > 1)) then
				-- skip if matching
				if (v.clubId == NS.charDB.profile.communityMain) then
					-- do not add
					add = false
				end
			end

			-- add to list?
			if (add == true) then
				-- add club
				list[v.clubId] = v.name
				NS.CommFlare.CF.ClubCount = NS.CommFlare.CF.ClubCount + 1
			end
		end
	end

	-- no list found?
	if (next(list) == nil) then
		-- none
		list[1] = L["None"]
	end

	-- return list
	return list
end

-- other community disabled?
local function Other_Community_List_Disabled()
	-- main community set?
	if (NS.charDB.profile.communityMain > 1) then
		-- process all
		NS.CommFlare.CF.ClubCount = 0
		NS.CommFlare.CF.Clubs = ClubGetSubscribedClubs()
		for _,v in ipairs(NS.CommFlare.CF.Clubs) do
			-- only communities
			if (v.clubType == Enum.ClubType.Character) then
				-- not main?
				if (v.clubId ~= NS.charDB.profile.communityMain) then
					-- increase
					NS.CommFlare.CF.ClubCount = NS.CommFlare.CF.ClubCount + 1
				end
			end
		end

		-- none found?
		if (NS.CommFlare.CF.ClubCount == 0) then
			-- disabled
			return true
		end

		-- enabled
		return false
	else
		-- disabled
		NS.charDB.profile.communityReportID = 1
		return true
	end
end

-- other community get item
local function Other_Community_Get_Item(info, key)
	-- community list?
	if (info[#info] == "communityList") then
		-- not initialized?
		if (not NS.charDB.profile.communityList) then
			-- initialize
			NS.charDB.profile.communityList = {}
		end

		-- valid?
		if (NS.charDB.profile.communityList[key]) then
			-- return value
			return NS.charDB.profile.communityList[key]
		end
	end

	-- false
	return false
end

-- other community set item
local function Other_Community_Set_Item(info, key, value)
	-- community list?
	if (info[#info] == "communityList") then
		-- not initialized?
		if (not NS.charDB.profile.communityList) then
			-- initialize
			NS.charDB.profile.communityList = {}
		end

		-- true value?
		if (value == true) then
			-- set the value
			NS.charDB.profile.communityList[key] = value

			-- update members
			NS:Update_Club_Members(key, true)

			-- readd community chat window
			NS:ReaddCommunityChatWindow(key, 1)
		else
			-- clear the value
			NS.charDB.profile.communityList[key] = nil

			-- update members
			NS:Update_Club_Members(key, false)
		end
	end
end

-- setup community lists
local function Setup_Community_List(info)
	-- process all
	local list = {}
	local count = 0
	local clubs = ClubGetSubscribedClubs()
	for _,v in ipairs(clubs) do
		-- only communities
		if (v.clubType == Enum.ClubType.Character) then
			-- add club
			list[v.clubId] = v.name
			count = count + 1
		end
	end

	-- no list found?
	if (next(list) == nil) then
		-- none
		list[1] = L["None"]
	end

	-- return list
	return list
end

-- setup community leader list disabled?
local function Community_Leader_List_Disabled()
	-- has main community?
	if (NS.charDB.profile.communityMain > 1) then
		-- enabled
		return false
	end

	-- disabled
	return true
end

-- setup community log list disabled?
local function Community_Log_List_Disabled()
	-- has main community?
	if (NS.charDB.profile.communityMain > 1) then
		-- enabled
		return false
	end

	-- disabled
	return true
end

-- community list get item
local function Community_List_Get_Item(info, key)
	-- community leader list?
	if (info[#info] == "communityLeadersList") then
		-- not initialized?
		if (not NS.charDB.profile.communityLeadersList) then
			-- initialize
			NS.charDB.profile.communityLeadersList = {}
		end

		-- valid?
		if (NS.charDB.profile.communityLeadersList[key]) then
			-- return value
			return NS.charDB.profile.communityLeadersList[key]
		end
	-- community log list?
	elseif (info[#info] == "communityLogList") then
		-- not initialized?
		if (not NS.charDB.profile.communityLogList) then
			-- initialize
			NS.charDB.profile.communityLogList = {}
		end

		-- valid?
		if (NS.charDB.profile.communityLogList[key]) then
			-- return value
			return NS.charDB.profile.communityLogList[key]
		end
	end

	-- false
	return false
end

-- community list set item
local function Community_List_Set_Item(info, key, value)
	-- community leader list?
	if (info[#info] == "communityLeadersList") then
		-- not initialized?
		if (not NS.charDB.profile.communityLeadersList) then
			-- initialize
			NS.charDB.profile.communityLeadersList = {}
		end

		-- true value?
		if (value == true) then
			-- set the value
			NS.charDB.profile.communityLeadersList[key] = value
		else
			-- clear the value
			NS.charDB.profile.communityLeadersList[key] = nil
		end

		-- rebuild community leaders
		NS:Rebuild_Community_Leaders()

		-- count community leaders
		local count = 0
		for _,v in ipairs(NS.CommFlare.CF.CommunityLeaders) do
			-- next
			count = count + 1
		end

		-- display results
		print(strformat(L["%s: %d Community Leaders found."], NS.CommFlare.Title, count))
	-- community monitor list?
	elseif (info[#info] == "communityLogList") then
		-- not initialized?
		if (not NS.charDB.profile.communityLogList) then
			-- initialize
			NS.charDB.profile.communityLogList = {}
		end

		-- true value?
		if (value == true) then
			-- set the value
			NS.charDB.profile.communityLogList[key] = value
		else
			-- clear the value
			NS.charDB.profile.communityLogList[key] = nil
		end
	end
end

-- is disabled?
local function Check_ReportID_Disabled()
	-- main community set?
	if (NS.charDB.profile.communityMain > 1) then
		-- enabled
		return false
	else
		-- disabled
		NS.charDB.profile.communityReportID = 1
		return true
	end
end

-- set report id / setup channel
local function Set_ReportID(info, value)
	-- save new value
	NS.charDB.profile.communityReportID = value

	-- has report ID?
	if (NS.charDB.profile.communityReportID > 1) then
		-- readd community chat window
		NS:ReaddCommunityChatWindow(NS.charDB.profile.communityReportID, 1)
	end
end

-- is tank role available?
local function Check_Tank_Available()
	-- get available roles
	local hasTank, hasHealer, hasDPS = UnitGetAvailableRoles("player")
	if (hasTank == true) then
		-- enabled
		return false
	else
		-- disabled
		return true
	end
end

-- get force tank item
local function Get_Force_Tank_Item(info)
	-- enforce pvp roles
	NS:Enforce_PVP_Roles()

	-- return value
	return NS.charDB.profile.forceTank
end

-- set force tank item
local function Set_Force_Tank_Item(info, value)
	-- set value
	NS.charDB.profile.forceTank = value

	-- enforce pvp roles
	NS:Enforce_PVP_Roles()
end

-- is tank role available?
local function Set_Force_DPS_Item()
	-- get available roles
	local hasTank, hasHealer, hasDPS = UnitGetAvailableRoles("player")
	if (hasHealer == true) then
		-- enabled
		return false
	else
		-- disabled
		return true
	end
end

-- get force healer item
local function Get_Force_Healer_Item(info)
	-- enforce pvp roles
	NS:Enforce_PVP_Roles()

	-- return value
	return NS.charDB.profile.forceHealer
end

-- set force healer item
local function Set_Force_Healer_Item(info, value)
	-- set value
	NS.charDB.profile.forceHealer = value

	-- enforce pvp roles
	NS:Enforce_PVP_Roles()
end

-- get force dps item
local function Get_Force_DPS_Item(info)
	-- enforce pvp roles
	NS:Enforce_PVP_Roles()

	-- return value
	return NS.charDB.profile.forceDPS
end

-- set force dps item
local function Set_Force_DPS_Item(info, value)
	-- set value
	NS.charDB.profile.forceDPS = value

	-- enforce pvp roles
	NS:Enforce_PVP_Roles()
end

-- setup total database members
local function Total_Database_Members(info)
	-- process all members
	local count = 0
	for k,v in pairs(NS.globalDB.global.members) do
		-- increase
		count = count + 1
	end

	-- return count
	return strformat(L["Database members found: %s"], count)
end

-- refresh database members
local function Refresh_Database_Members()
	-- refresh database
	NS:Refresh_Database()
end

-- rebuild database members
local function Rebuild_Database_Members()
	-- clear lists
	NS.globalDB.global.members = {}
	NS.CommFlare.CF.CommunityLeaders = {}

	-- process club members again
	print(L["Rebuilding community database member list."])
	local status = NS:Process_Club_Members()
	if (status == true) then
		-- display members found
		print(NS:Total_Database_Members(nil))

		-- display leaders count
		local count = 0
		for _,v in ipairs(NS.CommFlare.CF.CommunityLeaders) do
			-- next
			count = count + 1
		end
		print(strformat(L["%d community leaders found."], count))
	else
		-- no subscribed clubs found
		print(strformat(L["%s: No subscribed clubs found."], NS.CommFlare.Title))
	end
end

-- rebuild database members confirmation
local function Rebuild_Database_Members_Confirmation()
	-- ask first
	NS:PopupBox("CommunityFlare_Rebuild_Members_Dialog")
end

-- setup report community to list
local function Setup_Report_Community_List(info)
	-- process all
	local list = {}
	list[1] = L["None"]
	NS.CommFlare.CF.ClubCount = 0
	NS.CommFlare.CF.Clubs = ClubGetSubscribedClubs()
	for _,v in ipairs(NS.CommFlare.CF.Clubs) do
		-- only communities
		if (v.clubType == Enum.ClubType.Character) then
			-- add club
			list[v.clubId] = v.name
		end
	end

	-- return list
	return list
end

-- rebuild members dialog box
StaticPopupDialogs["CommunityFlare_ReloadUI_Required_Dialog"] = {
	text = L["One or more of the changes you have made require a ReloadUI."],
	button1 = L["Yes"],
	button2 = L["No"],
	OnAccept = function(self, player)
		-- save settings
		for k,v in pairs(settings_that_require_reload) do
			-- block hotkeys?
			if (k == "blockGameMenuHotKeys") then
				-- save value
				NS.charDB.profile.blockGameMenuHotKeys = v
			end
		end

		-- reload UI
		ReloadUI()
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
}

-- set block game menu hot keys (reload when disabled)
local function BlockGameMenuHotKeys_Set(info, value)
	-- enabled?
	if (value == true) then
		-- save value
		NS.charDB.profile.blockGameMenuHotKeys = value

		-- enable block game menu hooks
		NS:Setup_BlockGameMenuHooks()
	else
		-- setting requires reload
		settings_that_require_reload["blockGameMenuHotKeys"] = value
		NS:PopupBox("CommunityFlare_ReloadUI_Required_Dialog", value)
	end
end

-- defaults
NS.defaults = {
	profile = {
		-- variables
		MatchStatus = 0,
		SavedTime = 0,

		-- profile only options
		adjustVehicleTurnSpeed = 0,
		alwaysAutoQueue = false,
		alwaysReaddChannels = false,
		blockGameMenuHotKeys = false,
		blockSharedQuests = 2,
		bnetAutoInvite = true,
		bnetAutoQueue = true,
		communityAutoAssist = 2,
		communityAutoInvite = true,
		communityAutoPassLead = true,
		communityAutoQueue = true,
		communityDisplayNames = true,
		communityPartyLeader = false,
		communityReporter = true,
		debugMode = false,
		displayPoppedGroups = false,
		forceDPS = false,
		forceHealer = false,
		forceTank = false,
		maxPartySize  = 5,
		partyLeaderNotify = 2,
		popupQueueWindow = false,
		printDebugInfo = false,
		pvpCombatLogging = false,
		restrictPings = 0,
		uninvitePlayersAFK = 0,
		warningLeavingBG = 2,
		warningQueuePaused = true,

		-- community stuff
		communityMain = 0,
		communityList = {},
		communityReportID = 0,
		communityRefreshed = 0,
		membersCount = "",

		-- tables
		ASH = {},
		AV = {},
		IOC = {},
		WG = {},
		communityLeadersList = {},
		communityLogList = {},
		Queues = {},
	},
}

-- options
NS.options = {
	name = NS.CommFlare.Title_Full,
	handler = NS.CommFlare,
	type = "group",
	args = {
		community = {
			type = "group",
			order = 1,
			name = L["Community Options"],
			inline = true,
			args = {
				communityMain = {
					type = "select",
					order = 1,
					name = L["Main Community?"],
					desc = L["Choose the main community from your subscribed list."],
					values = Setup_Main_Community_List,
					get = function(info) return NS.charDB.profile.communityMain end,
					set = Set_Main_Community,
				},
				communityList = {
					type = "multiselect",
					order = 2,
					name = L["Other Communities?"],
					desc = L["Choose the other communities from your subscribed list."],
					values = Setup_Other_Community_List,
					disabled = Other_Community_List_Disabled,
					get = Other_Community_Get_Item,
					set = Other_Community_Set_Item,
				},
				communityLeadersList = {
					type = "multiselect",
					order = 3,
					name = L["Community Leaders?"],
					desc = L["Choose the communities that you want to build the leaders list from."],
					values = Setup_Community_List,
					disabled = Community_Leader_List_Disabled,
					get = Community_List_Get_Item,
					set = Community_List_Set_Item,
				},
				membersCount = {
					type = "description",
					order = 4,
					name = Total_Database_Members,
				},
				refreshMembers = {
					type = "execute",
					order = 5,
					name = L["Refresh Members?"],
					desc = L["Use this to refresh the members database from currently selected communities."],
					func = Refresh_Database_Members,
				},
				rebuildMembers = {
					type = "execute",
					order = 6,
					name = L["Rebuild Members?"],
					desc = L["Use this to totally rebuild the members database from currently selected communities."],
					func = Rebuild_Database_Members_Confirmation,
				},
				alwaysReaddChannels = {
					type = "toggle",
					order = 7,
					name = L["Always remove, then re-add community channels to general? *EXPERIMENTAL*"],
					desc = L["This will automatically delete communities channels from general and re-add them upon login."],
					width = "full",
					get = function(info) return NS.charDB.profile.alwaysReaddChannels end,
					set = function(info, value) NS.charDB.profile.alwaysReaddChannels = value end,
				},
			},
		},
		invite = {
			type = "group",
			order = 2,
			name = L["Invite Options"],
			inline = true,
			args = {
				bnetAutoInvite = {
					type = "toggle",
					order = 1,
					name = L["Automatically accept invites from Battle.NET friends?"],
					desc = L["This will automatically accept group/party invites from Battle.NET friends."],
					width = "full",
					get = function(info) return NS.charDB.profile.bnetAutoInvite end,
					set = function(info, value) NS.charDB.profile.bnetAutoInvite = value end,
				},
				communityAutoInvite = {
					type = "toggle",
					order = 2,
					name = L["Automatically accept invites from community members?"],
					desc = L["This will automatically accept group/party invites from community members."],
					width = "full",
					get = function(info) return NS.charDB.profile.communityAutoInvite end,
					set = function(info, value) NS.charDB.profile.communityAutoInvite = value end,
				},
			},
		},
		queue = {
			type = "group",
			order = 3,
			name = L["Queue Options"],
			inline = true,
			args = {
				alwaysAutoQueue = {
					type = "toggle",
					order = 1,
					name = L["Always automatically queue?"],
					desc = L["This will always automatically accept all queues for you."],
					width = "full",
					get = function(info) return NS.charDB.profile.alwaysAutoQueue end,
					set = function(info, value) NS.charDB.profile.alwaysAutoQueue = value end,
				},
				bnetAutoQueue = {
					type = "toggle",
					order = 2,
					name = L["Automatically queue if your group leader is your Battle.Net friend?"],
					desc = L["This will automatically queue if your group leader is your Battle.Net friend."],
					width = "full",
					get = function(info) return NS.charDB.profile.bnetAutoQueue end,
					set = function(info, value) NS.charDB.profile.bnetAutoQueue = value end,
				},
				communityAutoQueue = {
					type = "toggle",
					order = 3,
					name = L["Automatically queue if your group leader is in community?"],
					desc = L["This will automatically queue if your group leader is in community."],
					width = "full",
					get = function(info) return NS.charDB.profile.communityAutoQueue end,
					set = function(info, value) NS.charDB.profile.communityAutoQueue = value end,
				},
				displayPoppedGroups = {
					type = "toggle",
					order = 3,
					name = L["Display notification for popped groups?"],
					desc = L["This will display a notification in your General chat window when groups pop."],
					width = "full",
					get = function(info) return NS.charDB.profile.displayPoppedGroups end,
					set = function(info, value) NS.charDB.profile.displayPoppedGroups = value end,
				},
				popupQueueWindow = {
					type = "toggle",
					order = 4,
					name = L["Popup PVP queue window upon leaders queing up? (Only for group leaders.)"],
					desc = L["This will open up the PVP queue window if a leader is queing up for PVP so you can queue up too."],
					width = "full",
					get = function(info) return NS.charDB.profile.popupQueueWindow end,
					set = function(info, value) NS.charDB.profile.popupQueueWindow = value end,
				},
				warningQueuePaused = {
					type = "toggle",
					order = 5,
					name = L["Warn if/when queues become paused?"],
					desc = L["This will provide a warning message or popup message for Group Leaders, if/when their queue becomes paused."],
					width = "full",
					get = function(info) return NS.charDB.profile.warningQueuePaused end,
					set = function(info, value) NS.charDB.profile.warningQueuePaused = value end,
				},
				communityReporter = {
					type = "toggle",
					order = 6,
					name = L["Report queues to main community? (Requires community channel to have /# assigned.)"],
					desc = L["This will provide a quick popup message for you to send your queue status to the Community chat."],
					width = "full",
					get = function(info) return NS.charDB.profile.communityReporter end,
					set = function(info, value) NS.charDB.profile.communityReporter = value end,
				},
				communityReportID = {
					type = "select",
					order = 7,
					name = L["Community to report to?"],
					desc = L["Choose the community that you want to report queues to."],
					values = Setup_Report_Community_List,
					disabled = Check_ReportID_Disabled,
					get = function(info) return NS.charDB.profile.communityReportID end,
					set = Set_ReportID,
				},
				uninvitePlayersAFK = {
					type = "select",
					order = 8,
					name = L["Uninvite any players that are AFK?"],
					desc = L["Pops up a box to uninvite any users that are AFK at the time of queuing."],
					values = {
						[0] = L["Disabled"],
						[3] = L["3 Seconds"],
						[4] = L["4 Seconds"],
						[5] = L["5 Seconds"],
						[6] = L["6 Seconds"],
					},
					get = function(info) return NS.charDB.profile.uninvitePlayersAFK end,
					set = function(info, value) NS.charDB.profile.uninvitePlayersAFK = value end,
				},
				forcedRoles = {
					type = "group",
					order = 9,
					name = "Force PVP Role?",
					inline = true,
					args = {
						forceTank = {
							type = "toggle",
							order = 1,
							name = "Tank",
							desc = "This will always enable the Tank role for PVP Queues.",
							disabled = Check_Tank_Available,
							get = Get_Force_Tank_Item,
							set = Set_Force_Tank_Item,
						},
						forceHealer = {
							type = "toggle",
							order = 2,
							name = "Healer",
							desc = "This will always enable the Healer role for PVP Queues.",
							disabled = Set_Force_DPS_Item,
							get = Get_Force_Healer_Item,
							set = Set_Force_Healer_Item,
						},
						forceDPS = {
							type = "toggle",
							order = 3,
							name = "DPS",
							desc = "This will always enable the DPS role for PVP Queues.",
							get = Get_Force_DPS_Item,
							set = Set_Force_DPS_Item,
						},
					},
				},
			},
		},
		party = {
			type = "group",
			order = 4,
			name = L["Party Options"],
			inline = true,
			args = {
				maxPartySize = {
					type = "select",
					order = 1,
					name = L["Max Party Size?"],
					desc = L["This will set the maximum party members you want in your group."],
					values = {
						[1] = L["1 Member"],
						[2] = L["2 Members"],
						[3] = L["3 Members"],
						[4] = L["4 Members"],
						[5] = L["5 Members"],
					},
					get = function(info) return NS.charDB.profile.maxPartySize end,
					set = function(info, value) NS.charDB.profile.maxPartySize = value end,
				},
				partyLeaderNotify = {
					type = "select",
					order = 1,
					name = L["Notify you upon given party leadership?"],
					desc = L["This will show a raid warning to you when you are given leadership of your party."],
					values = {
						[1] = L["None"],
						[2] = L["Raid Warning"],
					},
					get = function(info) return NS.charDB.profile.partyLeaderNotify end,
					set = function(info, value) NS.charDB.profile.partyLeaderNotify = value end,
				},
			},
		},
		battleground = {
			type = "group",
			order = 5,
			name = L["Battleground Options"],
			inline = true,
			args = {
				communityAutoAssist = {
					type = "select",
					order = 1,
					name = L["Auto assist community members?"],
					desc = L["Automatically promotes community members to raid assist in matches."],
					values = {
						[1] = L["None"],
						[2] = L["Leaders Only"],
						[3] = L["All Community Members"],
					},
					get = function(info) return NS.charDB.profile.communityAutoAssist end,
					set = function(info, value) NS.charDB.profile.communityAutoAssist = value end,
				},
				blockSharedQuests = {
					type = "select",
					order = 2,
					name = L["Block shared quests?"],
					desc = L["Automatically blocks shared quests during a battleground."],
					values = {
						[1] = L["None"],
						[2] = L["Irrelevant"],
						[3] = L["All"],
					},
					get = function(info) return NS.charDB.profile.blockSharedQuests end,
					set = function(info, value) NS.charDB.profile.blockSharedQuests = value end,
				},
				adjustVehicleTurnSpeed = {
					type = "select",
					order = 3,
					name = L["Adjust vehicle turn speed?"],
					desc = L["This will adjust your turn speed while inside of a vehicle to make them turn faster during a battleground."],
					values = {
						[0] = L["Disabled"],
						[1] = L["Default (180)"],
						[2] = L["Fast (360)"],
						[3] = L["Max (540)"],
					},
					get = function(info) return NS.charDB.profile.adjustVehicleTurnSpeed end,
					set = function(info, value) NS.charDB.profile.adjustVehicleTurnSpeed = value end,
				},
				restrictPings = {
					type = "select",
					order = 4,
					name = L["Restrict /ping system to?"],
					desc = L["This will block players from using the /ping system if they do not have raid assist or raid lead."],
					values = {
						[0] = L["None"],
						[1] = L["Leaders Only"],
						[2] = L["Assistants Only"],
						[3] = L["Tanks & Healers Only"],
					},
					get = function(info) return NS.charDB.profile.restrictPings end,
					set = function(info, value) NS.charDB.profile.restrictPings = value end,
				},
				warningLeavingBG = {
					type = "select",
					order = 5,
					name = L["Warn before hearth stoning or teleporting inside a battleground?"],
					desc = L["Performs an action if you are about to hearth stone or teleport out of an active battleground."],
					values = {
						[1] = L["None"],
						[2] = L["Raid Warning"],
					},
					get = function(info) return NS.charDB.profile.warningLeavingBG end,
					set = function(info, value) NS.charDB.profile.warningLeavingBG = value end,
				},
				communityLogList = {
					type = "multiselect",
					order = 6,
					name = L["Log roster list for matches from these communities?"],
					desc = L["Choose the communities that you want to save a roster list upon the gate opening in battlegrounds."],
					values = Setup_Community_List,
					disabled = Community_Log_List_Disabled,
					get = Community_List_Get_Item,
					set = Community_List_Set_Item,
				},
				communityAutoPassLead = {
					type = "toggle",
					order = 7,
					name = L["Always pass Raid Leadership to Community Leaders?"],
					desc = L["This will automatically pass Raid Leadership inside Battlegrounds to Community Leaders by priority levels."],
					width = "full",
					get = function(info) return NS.charDB.profile.communityAutoPassLead end,
					set = function(info, value) NS.charDB.profile.communityAutoPassLead = value end,
				},
				communityDisplayNames = {
					type = "toggle",
					order = 8,
					name = L["Display community member names when running /comf command?"],
					desc = L["This will automatically display all community members found in the battleground when the /comf command is run."],
					width = "full",
					get = function(info) return NS.charDB.profile.communityDisplayNames end,
					set = function(info, value) NS.charDB.profile.communityDisplayNames = value end,
				},
				pvpCombatLogging = {
					type = "toggle",
					order = 9,
					name = L["Always save Combat Log inside PVP content?"],
					desc = L["This will automatically enable the combat logging to WowCombatLog while inside an arena or battleground."],
					width = "full",
					get = function(info) return NS.charDB.profile.pvpCombatLogging end,
					set = function(info, value) NS.charDB.profile.pvpCombatLogging = value end,
				},
				blockGameMenuHotKeys = {
					type = "toggle",
					order = 10,
					name = L["Block game menu hotkeys inside PVP content?"],
					desc = L["This will block the game menus from coming up inside an arena or battleground from pressing their hot keys. (To block during recording videos for example.)"],
					width = "full",
					get = function(info) return NS.charDB.profile.blockGameMenuHotKeys end,
					set = BlockGameMenuHotKeys_Set,
				},
			},
		},
		debug = {
			type = "group",
			order = 6,
			name = L["Debug Options"],
			inline = true,
			args = {
				debugMode = {
					type = "toggle",
					order = 1,
					name = L["Enable debug mode to help debug issues?"],
					desc = L["This will do various things to help with debugging bugs in the addon to help MESO fix bugs."],
					width = "full",
					get = function(info) return NS.charDB.profile.debugMode end,
					set = function(info, value) NS.charDB.profile.debugMode = value end,
				},
				printDebugInfo = {
					type = "toggle",
					order = 2,
					name = L["Enable some debug printing to general window to help debug issues?"],
					desc = L["This will print some extra data to your general window that will help MESO debug anything to help fix bugs."],
					width = "full",
					get = function(info) return NS.charDB.profile.printDebugInfo end,
					set = function(info, value) NS.charDB.profile.printDebugInfo = value end,
				},
			},
		},
	},
}

-- reset default settings
function NS:Reset_Default_Settings()
	-- process all defaults
	local count = 0
	for k,v in pairs(NS.defaults.profile) do
		-- not default?
		if (NS.charDB.profile[k] ~= v) then
			-- set default
			NS.charDB.profile[k] = v

			-- increase
			count = count + 1
		end
	end

	-- return count
	return count
end
