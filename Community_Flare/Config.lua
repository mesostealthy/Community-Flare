-- initialize
local LibStub = LibStub
local ADDON_NAME, NS = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
if (not L or not NS.CommFlare) then return end

-- localize stuff
local _G                                        = _G
local Chat_GetCommunitiesChannel                = _G.Chat_GetCommunitiesChannel
local StaticPopupDialogs                        = _G.StaticPopupDialogs
local UnitGetAvailableRoles                     = _G.UnitGetAvailableRoles
local ClubGetGuildClubId                        = _G.C_Club.GetGuildClubId
local ClubGetSubscribedClubs                    = _G.C_Club.GetSubscribedClubs
local ipairs                                    = _G.ipairs
local next                                      = _G.next
local pairs                                     = _G.pairs
local print                                     = _G.print
local strformat                                 = _G.string.format
local tinsert                                   = _G.table.insert

-- local variables
local settings_that_require_reload = {}

-- add / remove guild
local function Set_Add_Guild_Members(info, value)
	-- has guild?
	local clubId = ClubGetGuildClubId()
	if (not clubId) then
		-- not in guild
		print(L["You are not currently in a Guild."])
		return
	end

	-- save guild id
	NS.CommFlare.CF.GuildID = clubId

	-- save value
	NS.charDB.profile.addGuildMembers = value

	-- add members?
	if (NS.charDB.profile.addGuildMembers == true) then
		-- add all members
		NS:Add_All_Club_Members_By_ClubID(clubId)
	-- remove members?
	else
		-- remove all members
		NS:Remove_All_Club_Members_By_ClubID(clubId)
	end
end

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

		-- has value?
		if (value and (value > 1)) then
			-- enable community lists
			NS.charDB.profile.communityLogList[value] = true
			NS.charDB.profile.communityLeadersList[value] = true
		end
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

		-- disable community leaders list
		NS.charDB.profile.communityLeadersList[value] = nil
	end

	-- rebuild community leaders
	NS:Rebuild_Community_Leaders()

	-- save main community
	NS.charDB.profile.communityMain = value
	if (NS.charDB.profile.communityMain > 1) then
		-- setup report channels
		NS:Setup_Report_Channels()
	end

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

-- setup community report list disabled?
local function Community_Report_List_Disabled()
	-- not enabled?
	if (NS.charDB.profile.communityReporter == false) then
		-- disabled
		return true
	end

	-- has main community?
	if (NS.charDB.profile.communityMain > 1) then
		-- enabled
		return false
	end

	-- disabled
	return true
end

-- community set reporter
local function Community_Set_Reporter(info, value)
	-- save community reporter value
	NS.charDB.profile.communityReporter = value

	-- enabled?
	if (NS.charDB.profile.communityReporter == true) then
		-- update report list enabled / disabled status
		Community_Report_List_Disabled()
	end
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
	-- community report list?
	elseif (info[#info] == "communityReportList") then
		-- not initialized?
		if (not NS.charDB.profile.communityReportList) then
			-- copy community list
			NS.charDB.profile.communityReportList = CopyTable(NS.charDB.profile.communityList)

			-- has main community?
			if (NS.charDB.profile.communityMain > 1) then
				-- enable main community
				NS.charDB.profile.communityReportList[NS.charDB.profile.communityMain] = true
			end
		end

		-- valid?
		if (NS.charDB.profile.communityReportList[key]) then
			-- return value
			return NS.charDB.profile.communityReportList[key]
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
	-- community report list?
	elseif (info[#info] == "communityReportList") then
		-- not initialized?
		if (not NS.charDB.profile.communityReportList) then
			-- copy community list
			NS.charDB.profile.communityReportList = CopyTable(NS.charDB.profile.communityList)

			-- has main community?
			if (NS.charDB.profile.communityMain > 1) then
				-- enable main community
				NS.charDB.profile.communityReportList[NS.charDB.profile.communityMain] = true
			end
		end

		-- true value?
		if (value == true) then
			-- set the value
			NS.charDB.profile.communityReportList[key] = value

			-- verify channel is added for proper reporting
			local channel, chatFrameID = Chat_GetCommunitiesChannel(key, 1)
			if (not channel or not chatFrameID) then
				-- readd community chat window
				NS:ReaddCommunityChatWindow(key, 1)
			end
		else
			-- clear the value
			NS.charDB.profile.communityReportList[key] = nil
		end

		-- setup report channels
		NS:Setup_Report_Channels()
	end
end

-- setup total database members
local function Total_Database_Members(info)
	-- process all members
	local count = 0
	for k,v in pairs(NS.db.global.members) do
		-- increase
		count = count + 1
	end

	-- return count
	return strformat(L["Database members found: %s"], count)
end

-- refresh database
local function Refresh_Database_Members()
	-- get clubs list
	local clubs = NS:Get_Clubs_List(false)
	if (not clubs) then
		-- none
		print(strformat("%s: No subscribed clubs found.", NS.CommFlare.Title))
	else
		-- process clubs
		for _,clubId in ipairs(clubs) do
			-- club type is a community?
			local info = ClubGetClubInfo(clubId)
			if (info and (info.clubType == Enum.ClubType.Character)) then
				-- add community
				NS:Add_Community(clubId, info)

				-- remove all club members
				NS:Remove_All_Club_Members_By_ClubID(clubId)

				-- add all club members
				NS:Add_All_Club_Members_By_ClubID(clubId)
			end
		end

		-- rebuild community leaders
		NS:Rebuild_Community_Leaders()
	end
end

-- player list manager database
local function Toggle_Player_List_Manager()
	-- shown?
	if (CF_PlayerListFrame:IsShown()) then
		-- hide
		CF_PlayerListFrame:Hide()
	else
		-- show
		CF_PlayerListFrame:Show()
	end
end

-- rebuild database members confirmation
local function Rebuild_Database_Members_Confirmation()
	-- ask first
	NS:PopupBox("CommunityFlare_Rebuild_Members_Dialog")
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

-- set community right menu click
local function Community_Right_Click_Menu_Set(info, value)
	-- save value
	NS.charDB.profile.communityRightClickMenu = value

	-- setup context menus
	NS:Setup_Context_Menus()
end

-- set block game menu hot keys (reload when disabled)
local function Block_Game_Menu_Hot_Keys_Set(info, value)
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

-- is disabled?
local function Ashran_Mage_Warning_Frequency_Disabled()
	-- disabled?
	if (NS.db.global.ashranMageWarnAttacked == 1) then
		-- disabled
		return true
	else
		-- enabled
		return false
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

-- is healer role available?
local function Check_Healer_Available()
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

-- battleground group
local BattlegroundGroup = {
	name = L["Battleground Options"],
	type = "group",
	order = 2,
	args = {
		battlegroundTitle = {
			name = L["Battleground Options"],
			type = "header",
			order = 1,
			width = "full",
		},
		communityAutoAssist = {
			type = "select",
			order = 2,
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
			order = 3,
			name = L["Block shared quests?"],
			desc = L["Automatically blocks shared quests during a battleground."],
			values = {
				[1] = L["None"],
				[2] = L["Irrelevant"],
				[3] = L["All"],
			},
			get = function(info) return NS.db.global.blockSharedQuests end,
			set = function(info, value) NS.db.global.blockSharedQuests = value end,
		},
		adjustVehicleTurnSpeed = {
			type = "select",
			order = 4,
			name = L["Adjust vehicle turn speed?"],
			desc = L["This will adjust your turn speed while inside of a vehicle to make them turn faster during a battleground."],
			values = {
				[0] = L["Disabled"],
				[1] = L["Default (180)"],
				[2] = L["Fast (360)"],
				[3] = L["Max (540)"],
			},
			get = function(info) return NS.db.global.adjustVehicleTurnSpeed end,
			set = function(info, value) NS.db.global.adjustVehicleTurnSpeed = value end,
		},
		restrictPings = {
			type = "select",
			order = 5,
			name = L["Restrict /ping system to?"],
			desc = L["This will block players from using the /ping system if they do not have raid assist or raid lead."],
			values = {
				[0] = L["None"],
				[1] = L["Leaders Only"],
				[2] = L["Assistants Only"],
				[3] = L["Tanks & Healers Only"],
			},
			get = function(info) return NS.db.global.restrictPings end,
			set = function(info, value) NS.db.global.restrictPings = value end,
		},
		warningLeavingBG = {
			type = "select",
			order = 6,
			name = L["Warn before hearth stoning or teleporting inside a battleground?"],
			desc = L["Performs an action if you are about to hearth stone or teleport out of an active battleground."],
			values = {
				[1] = L["None"],
				[2] = L["Local Warning Only"],
			},
			get = function(info) return NS.db.global.warningLeavingBG end,
			set = function(info, value) NS.db.global.warningLeavingBG = value end,
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
			get = function(info) return NS.db.global.pvpCombatLogging end,
			set = function(info, value) NS.db.global.pvpCombatLogging = value end,
		},
		blockGameMenuHotKeys = {
			type = "toggle",
			order = 10,
			name = L["Block game menu hotkeys inside PVP content?"],
			desc = L["This will block the game menus from coming up inside an arena or battleground from pressing their hot keys. (To block during recording videos for example.)"],
			width = "full",
			get = function(info) return NS.charDB.profile.blockGameMenuHotKeys end,
			set = Block_Game_Menu_Hot_Keys_Set,
		},
		rebindTargetKeys = {
			type = "toggle",
			order = 11,
			name = L["Always target nearest/previous enemy players inside PVP content?"],
			desc = L["This will automatically bind your tab and shift+tab keys to only target enemy players inside PVP content."],
			width = "full",
			get = function(info) return NS.charDB.profile.rebindTargetKeys end,
			set = function(info, value) NS.charDB.profile.rebindTargetKeys = value end,
		},
		displayQueueEntryTimeLeft = {
			type = "toggle",
			order = 12,
			name = L["Display how much time left for people in your group to enter the queue?"],
			desc = L["This will periodically display a message showing how many seconds players in your party have left to enter the match, upon entering the match."],
			width = "full",
			get = function(info) return NS.db.global.displayQueueEntryTimeLeft end,
			set = function(info, value) NS.db.global.displayQueueEntryTimeLeft = value end,
		},
		communityLogList = {
			type = "multiselect",
			order = 13,
			name = L["Log roster list for matches from these communities?"],
			desc = L["Choose the communities that you want to save a roster list upon the gate opening in battlegrounds."],
			values = Setup_Community_List,
			disabled = Community_Log_List_Disabled,
			get = Community_List_Get_Item,
			set = Community_List_Set_Item,
		},
		purgeLogTime = {
			type = "select",
			order = 14,
			name = L["Purge logged roster matches timeframe?"],
			desc = L["This is the amount of time before it starts purging logged roster list for matches."],
			values = {
				[1] = L["7 Days"],
				[2] = L["14 Days"],
				[3] = L["30 Days"],
			},
			get = function(info) return NS.db.global.purgeLogTime end,
			set = function(info, value) NS.db.global.purgeLogTime = value end,
		},
		ashranTitle = {
			name = L["Ashran Options"],
			type = "header",
			order = 15,
			width = "full",
		},
		ashranMageWarnAttacked = {
			type = "select",
			order = 16,
			width = 1.20,
			name = L["Notify you when your Mage is under attack?"],
			desc = L["This will show a raid warning to you when your Mage is under attack in Ashran."],
			values = {
				[1] = L["None"],
				[2] = L["Raid Warning"],
				[3] = L["Local Warning Only"],
			},
			get = function(info) return NS.db.global.ashranMageWarnAttacked end,
			set = function(info, value) NS.db.global.ashranMageWarnAttacked = value end,
		},
		ashranMageWarnFreq = {
			type = "select",
			order = 17,
			name = L["Frequency?"],
			desc = L["This is the amount of time delayed between Mage attacks in Ashran."],
			values = {
				[1] = L["15 Seconds"],
				[2] = L["30 Seconds"],
				[3] = L["60 Seconds"],
			},
			disabled = Ashran_Mage_Warning_Frequency_Disabled,
			get = function(info) return NS.db.global.ashranMageWarnFreq end,
			set = function(info, value) NS.db.global.ashranMageWarnFreq = value end,
		},
		ashranAncientInfernoSpawned = {
			type = "select",
			order = 18,
			name = L["Notify you when the Ancient Inferno has spawned?"],
			desc = L["This will show a raid warning to you when the Ancient Inferno has spawned in Ashran."],
			values = {
				[1] = L["None"],
				[2] = L["Raid Warning"],
				[3] = L["Local Warning Only"],
				[4] = L["Instance Chat Warning"],
			},
			get = function(info) return NS.db.global.ashranAncientInfernoSpawned end,
			set = function(info, value) NS.db.global.ashranAncientInfernoSpawned = value end,
		},
	}
}

-- community group
local CommunityGroup = {
	name = L["Community Options"],
	type = "group",
	order = 1,
	args = {
		generalTitle = {
			name = L["Community Options"],
			type = "header",
			order = 1,
			width = "full",
		},
		addGuildMembers = {
			type = "toggle",
			order = 2,
			name = L["Guild Members?"],
			desc = L["This will treat your Guild Members as Community Members."],
			width = "full",
			get = function(info) return NS.charDB.profile.addGuildMembers end,
			set = Set_Add_Guild_Members,
		},
		communityMain = {
			type = "select",
			order = 3,
			name = L["Main Community?"],
			desc = L["Choose the main community from your subscribed list."],
			values = Setup_Main_Community_List,
			get = function(info) return NS.charDB.profile.communityMain end,
			set = Set_Main_Community,
		},
		communityList = {
			type = "multiselect",
			order = 4,
			name = L["Other Communities?"],
			desc = L["Choose the other communities from your subscribed list."],
			values = Setup_Other_Community_List,
			disabled = Other_Community_List_Disabled,
			get = Other_Community_Get_Item,
			set = Other_Community_Set_Item,
		},
		communityLeadersList = {
			type = "multiselect",
			order = 5,
			name = L["Community Leaders?"],
			desc = L["Choose the communities that you want to build the leaders list from."],
			values = Setup_Community_List,
			disabled = Community_Leader_List_Disabled,
			get = Community_List_Get_Item,
			set = Community_List_Set_Item,
		},
		membersCount = {
			type = "description",
			order = 6,
			name = Total_Database_Members,
		},
		refreshMembers = {
			type = "execute",
			order = 7,
			name = L["Refresh Members?"],
			desc = L["Use this to refresh the members database from currently selected communities."],
			func = Refresh_Database_Members,
		},
		rebuildMembers = {
			type = "execute",
			order = 8,
			name = L["Rebuild Members?"],
			desc = L["Use this to totally rebuild the members database from currently selected communities."],
			func = Rebuild_Database_Members_Confirmation,
		},
		alwaysReaddChannels = {
			type = "toggle",
			order = 10,
			name = L["Always remove, then re-add community channels to general?"],
			desc = L["This will automatically delete communities channels from general and re-add them upon login."],
			width = "full",
			get = function(info) return NS.charDB.profile.alwaysReaddChannels end,
			set = function(info, value) NS.charDB.profile.alwaysReaddChannels = value end,
		},
		communityRightClickMenu = {
			type = "toggle",
			order = 10,
			name = L["Community Right Click Menu?"],
			desc = L["Enable the right click menu for community member list?"],
			width = "full",
			get = function(info) return NS.charDB.profile.communityRightClickMenu end,
			set = Community_Right_Click_Menu_Set,
		},
	}
}

-- database group
local DatabaseGroup = {
	name = L["Database Options"],
	type = "group",
	order = 3,
	args = {
		generalTitle = {
			name = L["Database Options"],
			type = "header",
			order = 1,
			width = "full",
		},
		playerListManager = {
			type = "execute",
			order = 2,
			name = L["Player List Manager?"],
			desc = L["Use this to manage the Players and KOS in the Member GUIDs list."],
			func = Toggle_Player_List_Manager,
		},
	}
}

-- debug group
local DebugGroup = {
	name = L["Debug Options"],
	type = "group",
	order = 9,
	args = {
		debugTitle = {
			name = L["Debug Options"],
			type = "header",
			order = 1,
			width = "full",
		},
		debugMode = {
			type = "toggle",
			order = 2,
			name = L["Enable debug mode to help debug issues?"],
			desc = L["This will do various things to help with debugging bugs in the addon to help MESO fix bugs."],
			width = "full",
			get = function(info) return NS.db.global.debugMode end,
			set = function(info, value) NS.db.global.debugMode = value end,
		},
		debugPrint = {
			type = "toggle",
			order = 3,
			name = L["Enable debug print chat window to log debug events?"],
			desc = L["This will log some debug event messages into a debug window to help MESO fix bugs."],
			width = "full",
			get = function(info) return NS.db.global.debugPrint end,
			set = function(info, value) NS.db.global.debugPrint = value end,
		},
	}
}

-- invite group
local InviteGroup = {
	name = L["Invite Options"],
	type = "group",
	order = 4,
	args = {
		inviteTitle = {
			name = L["Invite Options"],
			type = "header",
			order = 1,
			width = "full",
		},
		bnetAutoInvite = {
			type = "toggle",
			order = 2,
			name = L["Automatically accept invites from Battle.NET friends?"],
			desc = L["This will automatically accept group/party invites from Battle.NET friends."],
			width = "full",
			get = function(info) return NS.db.global.bnetAutoInvite end,
			set = function(info, value) NS.db.global.bnetAutoInvite = value end,
		},
		communityAutoInvite = {
			type = "toggle",
			order = 3,
			name = L["Automatically accept invites from community members?"],
			desc = L["This will automatically accept group/party invites from community members."],
			width = "full",
			get = function(info) return NS.charDB.profile.communityAutoInvite end,
			set = function(info, value) NS.charDB.profile.communityAutoInvite = value end,
		},
	}
}

-- party group
local PartyGroup = {
	name = L["Party Options"],
	type = "group",
	order = 5,
	args = {
		partyTitle = {
			name = L["Party Options"],
			type = "header",
			order = 1,
			width = "full",
		},
		maxPartySize = {
			type = "select",
			order = 2,
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
			order = 3,
			name = L["Notify you upon given party leadership?"],
			desc = L["This will show a raid warning to you when you are given leadership of your party."],
			values = {
				[1] = L["None"],
				[2] = L["Local Warning Only"],
			},
			get = function(info) return NS.db.global.partyLeaderNotify end,
			set = function(info, value) NS.db.global.partyLeaderNotify = value end,
		},
		alwaysRequestPartyLead = {
			type = "toggle",
			order = 4,
			name = L["Always request party leadership? (Community Leaders Only)"],
			desc = L["This will always attempt to request party leadership upon joining a new party. (Only for Community Leaders!)"],
			width = "full",
			get = function(info) return NS.db.global.alwaysRequestPartyLead end,
			set = function(info, value) NS.db.global.alwaysRequestPartyLead = value end,
		},
		notifyPartyZoneChanges = {
			type = "toggle",
			order = 5,
			name = L["Notify you upon party member zone changes?"],
			desc = L["This will show you a message when a party member changes zones."],
			width = "full",
			get = function(info) return NS.db.global.notifyPartyZoneChanges end,
			set = function(info, value) NS.db.global.notifyPartyZoneChanges = value end,
		},
	}
}

-- queue group
local QueueGroup = {
	name = L["Queue Options"],
	type = "group",
	order = 6,
	args = {
		queueTitle = {
			name = L["Queue Options"],
			type = "header",
			order = 1,
			width = "full",
		},
		alwaysAutoQueue = {
			type = "toggle",
			order = 2,
			name = L["Always automatically queue?"],
			desc = L["This will always automatically accept all queues for you."],
			width = "full",
			get = function(info) return NS.charDB.profile.alwaysAutoQueue end,
			set = function(info, value) NS.charDB.profile.alwaysAutoQueue = value end,
		},
		bnetAutoQueue = {
			type = "toggle",
			order = 3,
			name = L["Automatically queue if your group leader is your Battle.Net friend?"],
			desc = L["This will automatically queue if your group leader is your Battle.Net friend."],
			width = "full",
			get = function(info) return NS.db.global.bnetAutoQueue end,
			set = function(info, value) NS.db.global.bnetAutoQueue = value end,
		},
		communityAutoQueue = {
			type = "toggle",
			order = 4,
			name = L["Automatically queue if your group leader is in community?"],
			desc = L["This will automatically queue if your group leader is in community."],
			width = "full",
			get = function(info) return NS.charDB.profile.communityAutoQueue end,
			set = function(info, value) NS.charDB.profile.communityAutoQueue = value end,
		},
		displayPoppedGroups = {
			type = "toggle",
			order = 5,
			name = L["Display notification for popped groups?"],
			desc = L["This will display a notification in your General chat window when groups pop."],
			width = "full",
			get = function(info) return NS.db.global.displayPoppedGroups end,
			set = function(info, value) NS.db.global.displayPoppedGroups = value end,
		},
		warningQueuePaused = {
			type = "toggle",
			order = 6,
			name = L["Warn if/when queues become paused?"],
			desc = L["This will provide a warning message or popup message for Group Leaders, if/when their queue becomes paused."],
			width = "full",
			get = function(info) return NS.db.global.warningQueuePaused end,
			set = function(info, value) NS.db.global.warningQueuePaused = value end,
		},
		warningHonorCapped = {
			type = "toggle",
			order = 7,
			name = L["Warn when Honor capped or close to it?"],
			desc = L["This will provide a warning message when you are honor capped, or close to it when queuing."],
			width = "full",
			get = function(info) return NS.db.global.warningHonorCapped end,
			set = function(info, value) NS.db.global.warningHonorCapped = value end,
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
			get = function(info) return NS.db.global.uninvitePlayersAFK end,
			set = function(info, value) NS.db.global.uninvitePlayersAFK = value end,
		},
		forcedRoles = {
			type = "group",
			order = 9,
			name = "Force PVP Role?",
			inline = true,
			args = {
				forceTank = {
					name = "Tank",
					type = "toggle",
					order = 1,
					width = 0.5,
					desc = "This will always5enable the Tank role for PVP Queues.",
					disabled = Check_Tank_Available,
					get = Get_Force_Tank_Item,
					set = Set_Force_Tank_Item,
				},
				forceHealer = {
					name = "Healer",
					type = "toggle",
					order = 2,
					width = 0.5,
					desc = "This will always enable the Healer role for PVP Queues.",
					disabled = Check_Healer_Available,
					get = Get_Force_Healer_Item,
					set = Set_Force_Healer_Item,
				},
				forceDPS = {
					name = "DPS",
					type = "toggle",
					order = 3,
					width = 0.5,
					desc = "This will always enable the DPS role for PVP Queues.",
					get = Get_Force_DPS_Item,
					set = Set_Force_DPS_Item,
				},
			},
		},
	}
}

-- report group
local ReportGroup = {
	name = L["Report Options"],
	type = "group",
	order = 7,
	args = {
		generalTitle = {
			name = L["Report Options"],
			type = "header",
			order = 1,
			width = "full",
		},
		communityReporter = {
			type = "toggle",
			order = 2,
			name = L["Report queue status to communities?"],
			desc = L["This will provide a quick popup message for you to send your queue status to the Community chat."],
			width = "full",
			get = function(info) return NS.charDB.profile.communityReporter end,
			set = Community_Set_Reporter,
		},
		communityReportList = {
			type = "multiselect",
			order = 3,
			name = L["Communities to Report to?"],
			desc = L["Choose the communities that you want to report info to."],
			values = Setup_Community_List,
			disabled = Community_Report_List_Disabled,
			get = Community_List_Get_Item,
			set = Community_List_Set_Item,
		},
	}
}

-- world group
local WorldGroup = {
	name = L["World Options"],
	type = "group",
	order = 8,
	args = {
		worldTitle = {
			name = L["World Options"],
			type = "header",
			order = 1,
			width = "full",
		},
		notifyWarCrateInbound = {
			type = "toggle",
			order = 2,
			name = L["Notify you when a War Supply Crate is inbound?"],
			desc = L["This will show a raid warning to you when a War Supply Crate is coming in."],
			width = "full",
			get = function(info) return NS.db.global.notifyWarCrateInbound end,
			set = function(info, value) NS.db.global.notifyWarCrateInbound = value end,
		},
	}
}

-- global defaults
local GlobalDefaults = {
	-- global
	global = {
		-- tables
		clubs = {},
		history = {},
		KosList = {},
		matchLogList = {},
		MemberGUIDs = {},
		MemberNotes = {},
		members = {},
		SocialQueues = {},

		-- booleans
		alwaysRequestPartyLead = false,
		bnetAutoInvite = true,
		bnetAutoQueue = true,
		debugMode = false,
		debugPrint = false,
		displayPoppedGroups = false,
		displayQueueEntryTimeLeft = false,
		notifyPartyZoneChanges = false,
		notifyWarCrateInbound = false,
		pvpCombatLogging = false,
		warningHonorCapped = true,
		warningQueuePaused = true,

		-- numbers
		adjustVehicleTurnSpeed = 0,
		ashranAncientInfernoSpawned = 1,
		ashranMageWarnAttacked = 1,
		ashranMageWarnFreq = 2,
		blockSharedQuests = 2,
		partyLeaderNotify = 2,
		purgeLogTime = 2,
		restrictPings = 0,
		uninvitePlayersAFK = 0,
		warningLeavingBG = 2,
	},
}

-- character defaults
local CharDefaults = {
	profile = {
		-- variables
		MatchStatus = 0,
		SavedTime = 0,

		-- profile only options
		alwaysAutoQueue = false,
		alwaysReaddChannels = false,
		blockGameMenuHotKeys = false,
		communityAutoAssist = 3,
		communityAutoInvite = true,
		communityAutoPassLead = true,
		communityAutoQueue = true,
		communityDisplayNames = true,
		communityPartyLeader = false,
		communityReporter = true,
		communityRightClickMenu = false,
		forceDPS = false,
		forceHealer = false,
		forceTank = false,
		maxPartySize = 5,
		rebindTargetKeys = false,

		-- community stuff
		communityMain = 0,
		communityList = {},
		communityRefreshed = 0,
		communityReportList = nil,
		membersCount = "",

		-- tables
		communityLeadersList = {},
		communityLogList = {},
		Queues = {},
	},
}

-- refresh config
local function RefreshConfig()
	-- setup community lists
	NS:Setup_Main_Community_List(nil)
	NS:Setup_Other_Community_List(nil)
end

-- migrate settings
function NS:MigrateSettings()
	-- migrate any old settings
	if (NS.charDB and NS.charDB.profile) then
		-- process all old settings
		local updated = false
		for k,v in pairs(NS.charDB.profile) do
			-- setting moved?
			if (NS.db.global[k]) then
				-- copy setting
				NS.db.global[k] = v

				-- delete old setting
				NS.charDB.profile[k] = nil

				-- updated
				updated = true
			end
		end

		-- updated?
		if (updated == true) then
			-- update database
			NS.charDB.profile.LastMigrate = time()
		end

		-- check for old string values?
		if (type(NS.charDB.profile.communityAutoAssist) == "string") then
			-- convert to number
			NS.charDB.profile.communityAutoAssist = tonumber(NS.charDB.profile.communityAutoAssist)
		end
	end
end

-- create config options
function NS:CreateConfigOptions()
	-- create options table
	local OptionsTable = {
		name = NS.CommFlare.Title_Full,
		type = "group",
		args = {
			BattlegroundGroup = BattlegroundGroup,
			CommunityGroup = CommunityGroup,
			DatabaseGroup = DatabaseGroup,
			DebugGroup = DebugGroup,
			InviteGroup = InviteGroup,
			PartyGroup = PartyGroup,
			QueueGroup = QueueGroup,
			ReportGroup = ReportGroup,
			WorldGroup = WorldGroup,
		}
	}

	-- initialize global / profile settings
	NS.db = NS.Libs.AceDB:New("CommunityFlareDB", GlobalDefaults)
	NS.charDB = NS.Libs.AceDB:New("CommFlareCharDB", CharDefaults)
	NS.charDB.RegisterCallback(self, "OnProfileChanged", RefreshConfig)
	NS.charDB.RegisterCallback(self, "OnProfileCopied", RefreshConfig)
	NS.charDB.RegisterCallback(self, "OnProfileReset", RefreshConfig)
	NS:MigrateSettings()

	-- register options table
	NS.Libs.AceConfig:RegisterOptionsTable("Community_Flare", OptionsTable)
	NS.optionsFrame = NS.Libs.AceConfigDialog:AddToBlizOptions("Community_Flare", NS.CommFlare.Title)

	-- register profiles table
	NS.profiles = NS.Libs.AceDBOptions:GetOptionsTable(NS.charDB)
	NS.Libs.AceConfig:RegisterOptionsTable("Community_Flare_Profiles", NS.profiles)
	NS.profilesFrame = NS.Libs.AceConfigDialog:AddToBlizOptions("Community_Flare_Profiles", "Profiles", NS.CommFlare.Title)

	-- load previous session
	NS:LoadSession()
end
