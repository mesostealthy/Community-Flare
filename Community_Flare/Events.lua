-- initialize
local LibStub = LibStub
local ADDON_NAME, NS = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
if (not L or not NS.CommFlare) then return end

-- localize stuff
local _G                                        = _G
local AcceptGroup                               = _G.AcceptGroup
local AchievementFrame_LoadUI                   = _G.AchievementFrame_LoadUI
local ChatFrame_AddMessageEventFilter           = _G.ChatFrame_AddMessageEventFilter
local CollectionsJournal_LoadUI                 = _G.CollectionsJournal_LoadUI
local CombatLogGetCurrentEventInfo              = _G.CombatLogGetCurrentEventInfo
local Communities_LoadUI                        = _G.Communities_LoadUI
local DeclineQuest                              = _G.DeclineQuest
local EncounterJournal_LoadUI                   = _G.EncounterJournal_LoadUI
local GetAddOnCPUUsage                          = _G.GetAddOnCPUUsage
local GetAddOnMemoryUsage                       = _G.GetAddOnMemoryUsage
local GetAutoCompletePresenceID                 = _G.GetAutoCompletePresenceID
local GetBattlefieldPortExpiration              = _G.GetBattlefieldPortExpiration
local GetBattlefieldStatus                      = _G.GetBattlefieldStatus
local GetBattlefieldWinner                      = _G.GetBattlefieldWinner
local GetHomePartyInfo                          = _G.GetHomePartyInfo
local GetInviteConfirmationInfo                 = _G.GetInviteConfirmationInfo
local GetLFGRoleUpdate                          = _G.GetLFGRoleUpdate
local GetLFGRoleUpdateBattlegroundInfo          = _G.GetLFGRoleUpdateBattlegroundInfo
local GetMaxBattlefieldID                       = _G.GetMaxBattlefieldID
local GetNextPendingInviteConfirmation          = _G.GetNextPendingInviteConfirmation
local GetNumGroupMembers                        = _G.GetNumGroupMembers
local GetNumSubgroupMembers                     = _G.GetNumSubgroupMembers
local GetQuestID                                = _G.GetQuestID
local GetRealmName                              = _G.GetRealmName
local HideUIPanel                               = _G.HideUIPanel
local InCombatLockdown                          = _G.InCombatLockdown
local IsInGroup                                 = _G.IsInGroup
local IsInInstance                              = _G.IsInInstance
local IsInRaid                                  = _G.IsInRaid
local LoggingCombat                             = _G.LoggingCombat
local PlayerSpellsFrame_LoadUI                  = _G.PlayerSpellsFrame_LoadUI
local PromoteToAssistant                        = _G.PromoteToAssistant
local PVPMatchScoreboard                        = _G.PVPMatchScoreboard
local RaidWarningFrame_OnEvent                  = _G.RaidWarningFrame_OnEvent
local RequestBattlefieldScoreData               = _G.RequestBattlefieldScoreData
local RespondToInviteConfirmation               = _G.RespondToInviteConfirmation
local SetBattlefieldScoreFaction                = _G.SetBattlefieldScoreFaction
local SocialQueueUtil_GetRelationshipInfo       = _G.SocialQueueUtil_GetRelationshipInfo
local StaticPopup_FindVisible                   = _G.StaticPopup_FindVisible
local StaticPopup_Hide                          = _G.StaticPopup_Hide
local StaticPopup1Text                          = _G.StaticPopup1Text
local UnitFactionGroup                          = _G.UnitFactionGroup
local UnitGUID                                  = _G.UnitGUID
local UnitInRaid                                = _G.UnitInRaid
local UnitName                                  = _G.UnitName
local AreaPoiInfoGetAreaPOIForMap               = _G.C_AreaPoiInfo.GetAreaPOIForMap
local AreaPoiInfoGetAreaPOIInfo                 = _G.C_AreaPoiInfo.GetAreaPOIInfo
local BattleNetGetAccountInfoByGUID             = _G.C_BattleNet.GetAccountInfoByGUID
local ClubGetClubInfo                           = _G.C_Club.GetClubInfo
local ClubGetMemberInfo                         = _G.C_Club.GetMemberInfo
local GetCVar                                   = _G.C_CVar.GetCVar
local GetCVarDefault                            = _G.C_CVar.GetCVarDefault
local SetCVar                                   = _G.C_CVar.SetCVar
local DelvesUIHasActiveDelve                    = _G.C_DelvesUI.HasActiveDelve
local MapGetBestMapForUnit                      = _G.C_Map.GetBestMapForUnit
local MapGetMapInfo                             = _G.C_Map.GetMapInfo
local MapCanSetUserWaypointOnMap                = _G.C_Map.CanSetUserWaypointOnMap
local PartyInfoGetInviteReferralInfo            = _G.C_PartyInfo.GetInviteReferralInfo
local PartyInfoIsPartyFull                      = _G.C_PartyInfo.IsPartyFull
local PartyInfoLeaveParty                       = _G.C_PartyInfo.LeaveParty
local PartyInfoSetRestrictPings                 = _G.C_PartyInfo.SetRestrictPings
local PvPGetActiveMatchState                    = _G.C_PvP.GetActiveMatchState
local PvPGetActiveMatchDuration                 = _G.C_PvP.GetActiveMatchDuration
local PvPGetScoreInfo                           = _G.C_PvP.GetScoreInfo
local PvPGetScoreInfoByPlayerGuid               = _G.C_PvP.GetScoreInfoByPlayerGuid
local PvPIsArena                                = _G.C_PvP.IsArena
local PvPIsInBrawl                              = _G.C_PvP.IsInBrawl
local VignetteInfoGetVignettes                  = _G.C_VignetteInfo.GetVignettes
local VignetteInfoGetVignetteInfo               = _G.C_VignetteInfo.GetVignetteInfo
local Settings_OpenToCategory                   = _G.Settings.OpenToCategory
local SocialQueueGetGroupInfo                   = _G.C_SocialQueue.GetGroupInfo
local TimerAfter                                = _G.C_Timer.After
local date                                      = _G.date
local hooksecurefunc                            = _G.hooksecurefunc
local ipairs                                    = _G.ipairs
local math                                      = _G.math
local next                                      = _G.next
local pairs                                     = _G.pairs
local print                                     = _G.print
local time                                      = _G.time
local tonumber                                  = _G.tonumber
local tostring                                  = _G.tostring
local bitband                                   = _G.bit.band
local strfind                                   = _G.string.find
local strformat                                 = _G.string.format
local strgsub                                   = _G.string.gsub
local strlower                                  = _G.string.lower
local strmatch                                  = _G.string.match
local strsplit                                  = _G.string.split
local tinsert                                   = _G.table.insert

-- list current POI's
function NS:List_POIs()
	-- get map id
	print(L["Dumping POIs:"])
	NS.CommFlare.CF.MapID = MapGetBestMapForUnit("player")
	if (not NS.CommFlare.CF.MapID) then
		-- not found
		print(L["Map ID: Not Found"])
		return
	end

	-- get map info
	print(strformat("MapID: %d", NS.CommFlare.CF.MapID))
	NS.CommFlare.CF.MapInfo = MapGetMapInfo(NS.CommFlare.CF.MapID)
	if (not NS.CommFlare.CF.MapInfo) then
		-- not found
		print(L["Map ID: Not Found"])
		return
	end

	-- process any POI's
	print(strformat("Map Name: %s", NS.CommFlare.CF.MapInfo.name))
	local pois = AreaPoiInfoGetAreaPOIForMap(NS.CommFlare.CF.MapID)
	if (pois and (#pois > 0)) then
		-- display infos
		print(strformat(L["Count: %d"], #pois))
		for _,v in ipairs(pois) do
			NS.CommFlare.CF.POIInfo = AreaPoiInfoGetAreaPOIInfo(NS.CommFlare.CF.MapID, v)
			if (NS.CommFlare.CF.POIInfo) then
				if ((not NS.CommFlare.CF.POIInfo.description) or (NS.CommFlare.CF.POIInfo.description == "")) then
					-- display info (no description)
					print(strformat("%s: ID = %d, textureIndex = %d", NS.CommFlare.CF.POIInfo.name, NS.CommFlare.CF.POIInfo.areaPoiID, NS.CommFlare.CF.POIInfo.textureIndex))
				else
					-- display info (with description)
					print(strformat("%s: ID = %d, textureIndex = %d, Description = %s", NS.CommFlare.CF.POIInfo.name, NS.CommFlare.CF.POIInfo.areaPoiID, NS.CommFlare.CF.POIInfo.textureIndex, NS.CommFlare.CF.POIInfo.description))
				end
			end
		end
	else
		-- none found
		print(strformat(L["Count: %d"], 0))
	end
end

-- list current vignettes
function NS:List_Vignettes()
	-- process any vignettes
	print(L["Dumping Vignettes:"])
	local vignetteGUIDs = VignetteInfoGetVignettes()
	if (vignetteGUIDs and (#vignetteGUIDs > 0)) then
		-- display infos
		print(strformat(L["Count: %d"], #vignetteGUIDs))
		for _,v in ipairs(vignetteGUIDs) do
			local vignetteInfo = VignetteInfoGetVignetteInfo(v)
			print(strformat("%s: ID = %d, GUID = %s", vignetteInfo.name, vignetteInfo.vignetteID, vignetteInfo.vignetteGUID))
		end
	else
		-- none found
		print(strformat(L["Count: %d"], 0))
	end
end

-- securely hook accept battlefield port
local function hook_AcceptBattlefieldPort(index, acceptFlag)
	-- invalid index?
	if (not index or (index < 1) or (index > GetMaxBattlefieldID())) then
		-- finished
		return
	end

	-- is tracked pvp?
	local status, mapName = GetBattlefieldStatus(index)
	local isTracked, isEpicBattleground, isRandomBattleground, isBrawl = NS:IsTrackedPVP(mapName)
	if (isTracked == true) then
		-- confirm?
		if (status == "confirm") then
			-- has queue popped?
			if (NS.CommFlare.CF.LocalQueues[index] and NS.CommFlare.CF.LocalQueues[index].popped and (NS.CommFlare.CF.LocalQueues[index].popped > 0)) then
				-- get count
				local count = NS:GetGroupCount()
				if (NS.CommFlare.CF.CurrentPopped["count"]) then
					-- use popped count
					count = strformat("%s,%d", count, NS.CommFlare.CF.CurrentPopped["count"])
				end

				-- has leader GUID?
				local leaderGUID = NS.CommFlare.CF.LeaderGUID
				if (not leaderGUID) then
					-- use player
					leaderGUID = UnitGUID("player")
				end

				-- accepted queue?
				local text = ""
				local partyGUID = NS:GetPartyGUID()
				if (acceptFlag == true) then
					-- mercenary?
					if (NS.CommFlare.CF.LocalQueues[index].mercenary == true) then
						-- finalize text
						text = strformat(L["Entered Mercenary Queue For Popped %s!"], mapName)
					else
						-- finalize text
						text = strformat(L["Entered Queue For Popped %s!"], mapName)
					end

					-- save stuff
					NS.CommFlare.CF.LeftTime = 0
					NS.CommFlare.CF.EnteredTime = time()

					-- push data
					local guids = strformat("%s,%s", leaderGUID, partyGUID)
					NS:BNPushData(strformat("!CF@%s@%s@Queue@Entered@%s@%d@%s@%s", NS.CommFlare.Version, NS.CommFlare.Build, mapName, NS.CommFlare.CF.EnteredTime, count, guids))
				else
					-- mercenary?
					if (NS.CommFlare.CF.LocalQueues[index].mercenary == true) then
						-- finalize text
						text = strformat(L["Left Mercenary Queue For Popped %s!"], mapName)
					else
						-- finalize text
						text = strformat(L["Left Queue For Popped %s!"], mapName)
					end

					-- are you group leader?
					if (NS:IsGroupLeader() == true) then
						-- community reporter enabled?
						if (NS.charDB.profile.communityReporter == true) then
							-- send to community
							NS:PopupBox("CommunityFlare_Send_Community_Dialog", text)
						end
					end

					-- reset stuff
					NS.CommFlare.CF.LeftTime = time()
					NS.CommFlare.CF.EnteredTime = 0

					-- push data
					local guids = strformat("%s,%s", leaderGUID, partyGUID)
					NS:BNPushData(strformat("!CF@%s@%s@Queue@Left@%s@%d@%s@%s", NS.CommFlare.Version, NS.CommFlare.Build, mapName, NS.CommFlare.CF.LeftTime, count, guids))

					-- has social queue?
					if (NS.CommFlare.CF.SocialQueues["local"].queues and NS.CommFlare.CF.SocialQueues["local"].queues[index]) then
						-- clear queue
						NS.CommFlare.CF.SocialQueues["local"].queues[index] = nil
					end

					-- update after 2 seconds
					TimerAfter(2, function()
						-- update local group
						NS:Update_Group("local")
					end)

					-- clear after 30 seconds
					TimerAfter(30, function()
						-- reset stuff
						NS.CommFlare.CF.LeftTime = 0
						NS.CommFlare.CF.CurrentPopped = {}
					end)
				end

				-- are you in a party?
				if (IsInGroup() and not IsInRaid()) then
					-- send party message
					NS:SendMessage(nil, text)
				end

				-- clear local / update social queues
				NS.CommFlare.CF.LocalQueues[index] = nil
			end
		end
	end
end

-- securely hook accept proposal
local function hook_AcceptProposal()
	-- has queue popped?
	local index = "Brawl"
	if (NS.CommFlare.CF.LocalQueues[index] and NS.CommFlare.CF.LocalQueues[index].popped and (NS.CommFlare.CF.LocalQueues[index].popped > 0)) then
		-- has name?
		if (NS.CommFlare.CF.LocalQueues[index].name and (NS.CommFlare.CF.LocalQueues[index].name ~= "")) then
			-- are you in a party?
			if (IsInGroup() and not IsInRaid()) then
				-- send party message
				local mapName = NS.CommFlare.CF.LocalQueues[index].name
				NS:SendMessage(nil, strformat(L["Accepted Queue For Popped %s!"], mapName))
			end
		end
	end
end

-- securely hook leave battlefield
local function hook_LeaveBattlefield()
	-- inside pvp content?
	local isArena = PvPIsArena()
	local isBrawl = PvPIsInBrawl()
	local isBattleground = NS:IsInBattleground()
	if (isArena or isBattleground or isBrawl) then
		-- in home party?
		if (IsInGroup(LE_PARTY_CATEGORY_HOME) == true) then
			-- match completed?
			local text = ""
			if (GetBattlefieldWinner()) then
				-- finalize text
				text = L["Exited the current match after it concluded."]
			else
				-- finalize text
				text = L["Exited the current match before it concluded."]
			end

			-- send party message
			NS:SendMessage(nil, text)
		end
	end
end

-- securely hook reject proposal
local function hook_RejectProposal()
	-- has brawl queue?
	local index = "Brawl"
	if (NS.CommFlare.CF.LocalQueues[index] and NS.CommFlare.CF.LocalQueues[index].popped and (NS.CommFlare.CF.LocalQueues[index].popped > 0)) then
		-- update brawl status
		NS.CommFlare.CF.LocalQueues[index].status = "rejected"
		NS:Update_Brawl_Status()
	end
end

-- process main menu micro button on mouse down
local function hook_MainMenuMicroButton_OnMouseDown()
	-- block game menu hot keys enabled?
	if (NS.charDB.profile.blockGameMenuHotKeys == true) then
		-- inside pvp content?
		local isArena = PvPIsArena()
		local isBrawl = PvPIsInBrawl()
		local isBattleground = NS:IsInBattleground()
		if (isArena or isBattleground or isBrawl) then
			-- enabled
			NS.CommFlare.CF.AllowMainMenu = true
		else
			-- disabled
			NS.CommFlare.CF.AllowMainMenu = false
		end
	end
end

-- process game menu on show
local function hook_GameMenuFrame_OnShow()
	-- block game menu hot keys enabled?
	if (NS.charDB.profile.blockGameMenuHotKeys == true) then
		-- inside pvp content?
		local isArena = PvPIsArena()
		local isBrawl = PvPIsInBrawl()
		local isBattleground = NS:IsInBattleground()
		if (isArena or isBattleground or isBrawl) then
			-- blocked?
			if (NS.CommFlare.CF.AllowMainMenu ~= true) then
				-- not in combat?
				if (InCombatLockdown() ~= true) then
					-- hide
					HideUIPanel(GameMenuFrame)
				end
			end
		end

		-- disabled
		NS.CommFlare.CF.AllowMainMenu = false
	end
end

-- process game menu on hide
local function hook_GameMenuFrame_OnHide()
	-- block game menu hot keys enabled?
	if (NS.charDB.profile.blockGameMenuHotKeys == true) then
		-- disabled
		NS.CommFlare.CF.AllowMainMenu = false
	end
end

-- securely hook honor frame queue queue button hover
local function hook_HonorFrameQueueButton_OnEnter(self)
	-- not in a group?
	if (not IsInGroup()) then
		-- finished
		return
	end

	-- in a raid?
	if (IsInRaid()) then
		-- finished
		return
	end

	-- check for dead / offline players
	NS:Process_Party_States(true, true)
end

-- process character micro button clicked
local function hook_CharacterMicroButton_OnClick(self, ...)
	-- block game menu hot keys enabled?
	if (NS.charDB.profile.blockGameMenuHotKeys == true) then
		-- allowed
		NS.CommFlare.CF.AllowCharacterFrame = true
	end

	-- not in combat lockdown?
	if (InCombatLockdown() ~= true) then
		-- call original
		NS.CommFlare.hooks[CharacterMicroButton].OnClick(self, ...)
	else
		-- always normal
		CharacterMicroButton:SetNormal()
	end
end

-- process character toggle
local function hook_ToggleCharacter(tab, onlyShow)
	-- block game menu hot keys enabled?
	if (NS.charDB.profile.blockGameMenuHotKeys == true) then
		-- not shown?
		local isShown = CharacterFrame:IsShown()
		if (isShown == false) then
			-- not allowed?
			if (NS.CommFlare.CF.AllowCharacterFrame == false) then
				-- inside pvp content?
				local isArena = PvPIsArena()
				local isBrawl = PvPIsInBrawl()
				local isBattleground = NS:IsInBattleground()
				if (isArena or isBattleground or isBrawl) then
					-- finished
					return
				end
			end
		end	

		-- disabled
		NS.CommFlare.CF.AllowCharacterFrame = false
	end

	-- not in combat lockdown?
	if (InCombatLockdown() ~= true) then
		-- call original
		NS.CommFlare.hooks["ToggleCharacter"](tab, onlyShow)
	end
end

-- process profession micro button clicked
local function hook_ProfessionMicroButton_OnClick(self, ...)
	-- block game menu hot keys enabled?
	if (NS.charDB.profile.blockGameMenuHotKeys == true) then
		-- allowed
		NS.CommFlare.CF.AllowProfessionsBookFrame = true
	end

	-- not in combat lockdown?
	if (InCombatLockdown() ~= true) then
		-- call original
		NS.CommFlare.hooks[ProfessionMicroButton].OnClick(self, ...)
	else
		-- always normal
		ProfessionMicroButton:SetNormal()
	end
end

-- process professions toggle
local function hook_ToggleProfessionsBook(bookType)
	-- block game menu hot keys enabled?
	if (NS.charDB.profile.blockGameMenuHotKeys == true) then
		-- not loaded yet?
		if (not ProfessionsBookFrame) then
			-- load talent framework
			ProfessionsBook_LoadUI()
		end

		-- not shown?
		local isShown = ProfessionsBookFrame:IsShown()
		if (isShown == false) then
			-- not allowed?
			if (NS.CommFlare.CF.AllowProfessionsBookFrame == false) then
				-- inside pvp content?
				local isArena = PvPIsArena()
				local isBrawl = PvPIsInBrawl()
				local isBattleground = NS:IsInBattleground()
				if (isArena or isBattleground or isBrawl) then
					-- finished
					return
				end
			end
		end	

		-- disabled
		NS.CommFlare.CF.AllowProfessionsBookFrame = false
	end

	-- not in combat lockdown?
	if (InCombatLockdown() ~= true) then
		-- call original
		NS.CommFlare.hooks["ToggleProfessionsBook"](bookType)
	end
end

-- process player spells micro button clicked
local function hook_PlayerSpellsMicroButton_OnClick(self, ...)
	-- block game menu hot keys enabled?
	if (NS.charDB.profile.blockGameMenuHotKeys == true) then
		-- allowed
		NS.CommFlare.CF.AllowPlayerSpellsFrame = true
	end

	-- not in combat lockdown?
	if (InCombatLockdown() ~= true) then
		-- call original
		NS.CommFlare.hooks[PlayerSpellsMicroButton].OnClick(self, ...)
	else
		-- always normal
		PlayerSpellsMicroButton:SetNormal()
	end
end

-- process player spells toggle
local function hook_PlayerSpellsUtil_TogglePlayerSpellsFrame(suggestedTab, inspectUnit)
	-- block game menu hot keys enabled?
	if (NS.charDB.profile.blockGameMenuHotKeys == true) then
		-- not shown?
		local isShown = PlayerSpellsFrame:IsShown()
		if (isShown == false) then
			-- not allowed?
			if (NS.CommFlare.CF.AllowPlayerSpellsFrame == false) then
				-- inside pvp content?
				local isArena = PvPIsArena()
				local isBrawl = PvPIsInBrawl()
				local isBattleground = NS:IsInBattleground()
				if (isArena or isBattleground or isBrawl) then
					-- finished
					return
				end
			end
		end	

		-- disabled
		NS.CommFlare.CF.AllowPlayerSpellsFrame = false
	end

	-- not in combat lockdown?
	if (InCombatLockdown() ~= true) then
		-- call original
		return NS.CommFlare.hooks[PlayerSpellsUtil].TogglePlayerSpellsFrame(suggestedTab, inspectUnit)
	end
end

-- process spell book toggle
local function hook_PlayerSpellsUtil_ToggleSpellBookFrame(spellBookCategory)
	-- block game menu hot keys enabled?
	if (NS.charDB.profile.blockGameMenuHotKeys == true) then
		-- not shown?
		local isShown = PlayerSpellsFrame:IsShown()
		if (isShown == false) then
			-- not allowed?
			if (NS.CommFlare.CF.AllowPlayerSpellsFrame == false) then
				-- inside pvp content?
				local isArena = PvPIsArena()
				local isBrawl = PvPIsInBrawl()
				local isBattleground = NS:IsInBattleground()
				if (isArena or isBattleground or isBrawl) then
					-- finished
					return
				end
			end
		end	

		-- disabled
		NS.CommFlare.CF.AllowPlayerSpellsFrame = false
	end

	-- not in combat lockdown?
	if (InCombatLockdown() ~= true) then
		-- call original
		NS.CommFlare.hooks[PlayerSpellsUtil].ToggleSpellBookFrame(spellBookCategory)
	end
end

-- process class talent or spec toggle
local function hook_PlayerSpellsUtil_ToggleClassTalentOrSpecFrame()
	-- block game menu hot keys enabled?
	if (NS.charDB.profile.blockGameMenuHotKeys == true) then
		-- not shown?
		local isShown = PlayerSpellsFrame:IsShown()
		if (isShown == false) then
			-- not allowed?
			if (NS.CommFlare.CF.AllowPlayerSpellsFrame == false) then
				-- inside pvp content?
				local isArena = PvPIsArena()
				local isBrawl = PvPIsInBrawl()
				local isBattleground = NS:IsInBattleground()
				if (isArena or isBattleground or isBrawl) then
					-- finished
					return
				end
			end
		end	

		-- disabled
		NS.CommFlare.CF.AllowPlayerSpellsFrame = false
	end

	-- not in combat lockdown?
	if (InCombatLockdown() ~= true) then
		-- call original
		NS.CommFlare.hooks[PlayerSpellsUtil].ToggleClassTalentOrSpecFrame()
	end
end

-- process achievement micro button clicked
local function hook_AchievementMicroButton_OnClick(self, ...)
	-- block game menu hot keys enabled?
	if (NS.charDB.profile.blockGameMenuHotKeys == true) then
		-- allowed
		NS.CommFlare.CF.AllowAchievementFrame = true
	end

	-- not in combat lockdown?
	if (InCombatLockdown() ~= true) then
		-- call original
		NS.CommFlare.hooks[AchievementMicroButton].OnClick(self, ...)
	else
		-- always normal
		AchievementMicroButton:SetNormal()
	end
end

-- process achievement toggle
local function hook_ToggleAchievementFrame(stats)
	-- block game menu hot keys enabled?
	if (NS.charDB.profile.blockGameMenuHotKeys == true) then
		-- not loaded yet?
		if (not AchievementFrame) then
			-- load achievement framework
			AchievementFrame_LoadUI()
		end

		-- not shown?
		local isShown = AchievementFrame:IsShown()
		if (isShown == false) then
			-- not allowed?
			if (NS.CommFlare.CF.AllowAchievementFrame == false) then
				-- inside pvp content?
				local isArena = PvPIsArena()
				local isBrawl = PvPIsInBrawl()
				local isBattleground = NS:IsInBattleground()
				if (isArena or isBattleground or isBrawl) then
					-- finished
					return
				end
			end
		end	

		-- disabled
		NS.CommFlare.CF.AllowAchievementFrame = false
	end

	-- not in combat lockdown?
	if (InCombatLockdown() ~= true) then
		-- call original
		NS.CommFlare.hooks["ToggleAchievementFrame"](stats)
	end
end

-- process guild micro button clicked
local function hook_GuildMicroButton_OnClick(self, ...)
	-- block game menu hot keys enabled?
	if (NS.charDB.profile.blockGameMenuHotKeys == true) then
		-- allowed
		NS.CommFlare.CF.AllowGuildFrame = true
	end

	-- not in combat lockdown?
	if (InCombatLockdown() ~= true) then
		-- call original
		NS.CommFlare.hooks[GuildMicroButton].OnClick(self, ...)
	else
		-- always normal
		GuildMicroButton:SetNormal()
	end
end

-- process guild toggle
local function hook_ToggleGuildFrame()
	-- block game menu hot keys enabled?
	if (NS.charDB.profile.blockGameMenuHotKeys == true) then
		-- not loaded yet?
		if (not CommunitiesFrame) then
			-- load communities framework
			Communities_LoadUI()
		end

		-- not shown?
		local isShown = CommunitiesFrame:IsShown()
		if (isShown == false) then
			-- not allowed?
			if (NS.CommFlare.CF.AllowGuildFrame == false) then
				-- inside pvp content?
				local isArena = PvPIsArena()
				local isBrawl = PvPIsInBrawl()
				local isBattleground = NS:IsInBattleground()
				if (isArena or isBattleground or isBrawl) then
					-- finished
					return
				end
			end
		end	

		-- disabled
		NS.CommFlare.CF.AllowGuildFrame = false
	end

	-- not in combat lockdown?
	if (InCombatLockdown() ~= true) then
		-- call original
		NS.CommFlare.hooks["ToggleGuildFrame"]()
	end
end

-- process group finder micro button clicked
local function hook_LFDMicroButton_OnClick(self, ...)
	-- block game menu hot keys enabled?
	if (NS.charDB.profile.blockGameMenuHotKeys == true) then
		-- allowed
		NS.CommFlare.CF.AllowGroupFinderFrame = true
	end

	-- not in combat lockdown?
	if (InCombatLockdown() ~= true) then
		-- call original
		NS.CommFlare.hooks[LFDMicroButton].OnClick(self, ...)
	else
		-- always normal
		LFDMicroButton:SetNormal()
	end
end

-- process group finder toggle
local function hook_PVEFrame_ToggleFrame(sidePanelName, selection)
	-- block game menu hot keys enabled?
	if (NS.charDB.profile.blockGameMenuHotKeys == true) then
		-- not shown?
		local isShown = PVEFrame:IsShown()
		if (isShown == false) then
			-- not allowed?
			if (NS.CommFlare.CF.AllowGroupFinderFrame == false) then
				-- inside pvp content?
				local isArena = PvPIsArena()
				local isBrawl = PvPIsInBrawl()
				local isBattleground = NS:IsInBattleground()
				if (isArena or isBattleground or isBrawl) then
					-- finished
					return
				end
			end
		end	

		-- disabled
		NS.CommFlare.CF.AllowGroupFinderFrame = false
	end

	-- not in combat lockdown?
	if (InCombatLockdown() ~= true) then
		-- call original
		NS.CommFlare.hooks["PVEFrame_ToggleFrame"](sidePanelName, selection)
	end
end

-- process adventure guide micro button clicked
local function hook_EJMicroButton_OnClick(self, ...)
	-- block game menu hot keys enabled?
	if (NS.charDB.profile.blockGameMenuHotKeys == true) then
		-- allowed
		NS.CommFlare.CF.AllowAdvGuideFrame = true
	end

	-- not in combat lockdown?
	if (InCombatLockdown() ~= true) then
		-- call original
		NS.CommFlare.hooks[EJMicroButton].OnClick(self, ...)
	else
		-- always normal
		EJMicroButton:SetNormal()
	end
end

-- process adventure guide toggle
local function hook_ToggleEncounterJournal(tabIndex)
	-- block game menu hot keys enabled?
	if (NS.charDB.profile.blockGameMenuHotKeys == true) then
		-- not loaded yet?
		if (not EncounterJournal) then
			-- load adventure guide framework
			EncounterJournal_LoadUI()
		end

		-- not shown?
		local isShown = EncounterJournal:IsShown()
		if (isShown == false) then
			-- not allowed?
			if (NS.CommFlare.CF.AllowAdvGuideFrame == false) then
				-- inside pvp content?
				local isArena = PvPIsArena()
				local isBrawl = PvPIsInBrawl()
				local isBattleground = NS:IsInBattleground()
				if (isArena or isBattleground or isBrawl) then
					-- finished
					return
				end
			end
		end

		-- disabled
		NS.CommFlare.CF.AllowAdvGuideFrame = false
	end

	-- not in combat lockdown?
	if (InCombatLockdown() ~= true) then
		-- call original
		NS.CommFlare.hooks["ToggleEncounterJournal"](tabIndex)
	end
end

-- process collections micro button clicked
local function hook_CollectionsMicroButton_OnClick(self, ...)
	-- block game menu hot keys enabled?
	if (NS.charDB.profile.blockGameMenuHotKeys == true) then
		-- allowed
		NS.CommFlare.CF.AllowCollectionsFrame = true
	end

	-- not in combat lockdown?
	if (InCombatLockdown() ~= true) then
		-- call original
		NS.CommFlare.hooks[CollectionsMicroButton].OnClick(self, ...)
	else
		-- always normal
		CollectionsMicroButton:SetNormal()
	end
end

-- process collections toggle
local function hook_ToggleCollectionsJournal(tabIndex)
	-- block game menu hot keys enabled?
	if (NS.charDB.profile.blockGameMenuHotKeys == true) then
		-- not loaded yet?
		if (not CollectionsJournal) then
			-- load collections framework
			CollectionsJournal_LoadUI()
		end

		-- not shown?
		local isShown = CollectionsJournal:IsShown()
		if (isShown == false) then
			-- not allowed?
			if (NS.CommFlare.CF.AllowCollectionsFrame == false) then
				-- inside pvp content?
				local isArena = PvPIsArena()
				local isBrawl = PvPIsInBrawl()
				local isBattleground = NS:IsInBattleground()
				if (isArena or isBattleground or isBrawl) then
					-- finished
					return
				end
			end
		end	

		-- disabled
		NS.CommFlare.CF.AllowCollectionsFrame = false
	end

	-- not in combat lockdown?
	if (InCombatLockdown() ~= true) then
		-- call original
		NS.CommFlare.hooks["ToggleCollectionsJournal"](tabIndex)
	end
end

-- process friends toggle
local function hook_ToggleFriendsFrame(tab)
	-- block game menu hot keys enabled?
	if (NS.charDB.profile.blockGameMenuHotKeys == true) then
		-- not shown?
		local isShown = FriendsFrame:IsShown()
		if (isShown == false) then
			-- not allowed?
			if (NS.CommFlare.CF.AllowFriendsFrame == false) then
				-- inside pvp content?
				local isArena = PvPIsArena()
				local isBrawl = PvPIsInBrawl()
				local isBattleground = NS:IsInBattleground()
				if (isArena or isBattleground or isBrawl) then
					-- finished
					return
				end
			end
		end	

		-- disabled
		NS.CommFlare.CF.AllowFriendsFrame = false
	end

	-- not in combat lockdown?
	if (InCombatLockdown() ~= true) then
		-- call original
		NS.CommFlare.hooks["ToggleFriendsFrame"](tab)
	end
end

-- block game menu hooks
function NS:Setup_BlockGameMenuHooks()
	-- player spells frame not loaded?
	if (not PlayerSpellsFrame) then
		-- load player spells frame
		PlayerSpellsFrame_LoadUI()
	end

	-- hooks to block character frame inside pvp content
	NS.CommFlare.CF.AllowCharacterFrame = false
	NS.CommFlare:RawHook("ToggleCharacter", hook_ToggleCharacter, true)
	NS.CommFlare:RawHookScript(CharacterMicroButton, "OnClick", hook_CharacterMicroButton_OnClick, true)

	-- hooks to block spellbook frame inside pvp content
	NS.CommFlare.CF.AllowProfessionsBookFrame = false
	NS.CommFlare:RawHook("ToggleProfessionsBook", hook_ToggleProfessionsBook, true)
	NS.CommFlare:RawHookScript(ProfessionMicroButton, "OnClick", hook_ProfessionMicroButton_OnClick, true)

	-- hooks to block talent frame inside pvp content
	NS.CommFlare.CF.AllowPlayerSpellsFrame = false
	NS.CommFlare:RawHook(PlayerSpellsUtil, "TogglePlayerSpellsFrame", hook_PlayerSpellsUtil_TogglePlayerSpellsFrame, true)
	NS.CommFlare:RawHook(PlayerSpellsUtil, "ToggleSpellBookFrame", hook_PlayerSpellsUtil_ToggleSpellBookFrame, true)
	NS.CommFlare:RawHook(PlayerSpellsUtil, "ToggleClassTalentOrSpecFrame", hook_PlayerSpellsUtil_ToggleClassTalentOrSpecFrame, true)
	NS.CommFlare:RawHookScript(PlayerSpellsMicroButton, "OnClick", hook_PlayerSpellsMicroButton_OnClick, true)

	-- hooks to block achievement frame inside pvp content
	NS.CommFlare.CF.AllowAchievementFrame = false
	NS.CommFlare:RawHook("ToggleAchievementFrame", hook_ToggleAchievementFrame, true)
	NS.CommFlare:RawHookScript(AchievementMicroButton, "OnClick", hook_AchievementMicroButton_OnClick, true)

	-- hooks to block guild frame inside pvp content
	NS.CommFlare.CF.AllowGuildFrame = false
	NS.CommFlare:RawHook("ToggleGuildFrame", hook_ToggleGuildFrame, true)
	NS.CommFlare:RawHookScript(GuildMicroButton, "OnClick", hook_GuildMicroButton_OnClick, true)

	-- hooks to block group finder frame inside pvp content
	NS.CommFlare.CF.AllowGroupFinderFrame = false
	NS.CommFlare:RawHook("PVEFrame_ToggleFrame", hook_PVEFrame_ToggleFrame, true)
	NS.CommFlare:RawHookScript(LFDMicroButton, "OnClick", hook_LFDMicroButton_OnClick, true)

	-- hooks to block adventure guide frame inside pvp content
	NS.CommFlare.CF.AllowAdvGuideFrame = false
	NS.CommFlare:RawHook("ToggleEncounterJournal", hook_ToggleEncounterJournal, true)
	NS.CommFlare:RawHookScript(EJMicroButton, "OnClick", hook_EJMicroButton_OnClick, true)

	-- hooks to block collections frame inside pvp content
	NS.CommFlare.CF.AllowCollectionsFrame = false
	NS.CommFlare:RawHook("ToggleCollectionsJournal", hook_ToggleCollectionsJournal, true)
	NS.CommFlare:RawHookScript(CollectionsMicroButton, "OnClick", hook_CollectionsMicroButton_OnClick, true)

	-- hooks to block friends frame inside pvp content
	NS.CommFlare.CF.AllowFriendsFrame = false
	NS.CommFlare:RawHook("ToggleFriendsFrame", hook_ToggleFriendsFrame, true)

	-- TODO: REDO BELOW WITH RAW HOOKS!
	-- hooks for blocking escape key menu inside a battleground
	NS.CommFlare.CF.AllowMainMenu = false
	MainMenuMicroButton:HookScript("OnMouseDown", hook_MainMenuMicroButton_OnMouseDown)
	GameMenuFrame:HookScript("OnShow", hook_GameMenuFrame_OnShow)
	GameMenuFrame:HookScript("OnHide", hook_GameMenuFrame_OnHide)
end

-- setup hooks
function NS:SetupHooks()
	-- hook stuff
	hooksecurefunc("AcceptBattlefieldPort", hook_AcceptBattlefieldPort)
	hooksecurefunc("LeaveBattlefield", hook_LeaveBattlefield)
	hooksecurefunc("AcceptProposal", hook_AcceptProposal)
	hooksecurefunc("RejectProposal", hook_RejectProposal)

	-- block game menu hot keys enabled?
	if (NS.charDB.profile.blockGameMenuHotKeys == true) then
		-- enable block game menu hooks
		NS:Setup_BlockGameMenuHooks()
	end
end

-- handle chat whisper filtering
local function hook_Chat_Whisper_Filter(self, event, text, sender, ...)
	-- found internal message?
	if (text:find("!CF@")) then
		-- suppress
		return true
	end

	-- normal
	return false
end

-- process addon loaded
function NS.CommFlare:ADDON_LOADED(msg, ...)
	local addOnName = ...

	-- Blizzard_PVPUI?
	if (addOnName == "Blizzard_PVPUI") then
		-- enforce pvp roles
		NS:Enforce_PVP_Roles()

		-- hook queue button mouse over
		HonorFrameQueueButton:HookScript("OnEnter", hook_HonorFrameQueueButton_OnEnter)
	end
end

-- process Battle.NET chat message addon
function NS.CommFlare:BN_CHAT_MSG_ADDON(msg, ...)
	local prefix, text, channel, senderID = ...

	-- community flare?
	if (prefix == "CommFlare") then
		-- process battle net command
		NS:Process_BattleNET_Commands(senderID, text)
	end
end

-- process chat message addon
function NS.CommFlare:CHAT_MSG_ADDON(msg, ...)
	local prefix, text, channel, sender, target, zoneChannelID, localID, name, instanceID = ...

	-- sanity checks
	if (not prefix or not text or not sender) then
		-- finished
		return
	end

	-- community flare?
	if (prefix == ADDON_NAME) then
		-- requesting raid leader?
		text = tostring(text)
		if (text:find("REQUEST_RAID_LEADER")) then
			-- are you raid leader?
			NS.CommFlare.CF.PlayerRank = NS:GetRaidRank(UnitName("player"))
			if (NS.CommFlare.CF.PlayerRank == 2) then
				-- has shared community?
				sender = NS:GetFullName(tostring(sender))
				if (NS:Has_Shared_Community(sender) == true) then
					-- is sender community leader?
					if (NS:Is_Community_Leader(sender) == true) then
						-- promote
						NS:PromoteToRaidLeader(sender)
					end
				end
			end
		end
	else
		-- does not need addon data
		if (NS.CommFlare.CF.NeedAddonData ~= true) then
			-- finished
			return
		end

		-- capping?
		if (prefix == "Capping") then
			-- isle of conquest?
			if (NS.CommFlare.CF.MapID == 169) then
				-- skip these messages
				if ((text == "gr") or (text == "rb") or (text == "rbh")) then
					-- finished
					return
				end

				-- sanity check?
				local h1, h1hp, h2, h2hp, h3, h3hp, a1, a1hp, a2, a2hp, a3, a3hp = strsplit(":", text)
				local hGate1, hGate2, hGate3, aGate1, aGate2, aGate3 = tonumber(h1hp), tonumber(h2hp), tonumber(h3hp), tonumber(a1hp), tonumber(a2hp), tonumber(a3hp)
				if (hGate1 and hGate2 and hGate3 and aGate1 and aGate2 and aGate3) then
					-- find lowest gates
					local allyLowest = math.min(aGate1, aGate2, aGate3) / 2400000 * 100
					local hordeLowest = math.min(hGate1, hGate2, hGate3) / 2400000 * 100

					-- report to anyone?
					local text = strformat(L["%s: Alliance Gate = %.1f, Horde Gate = %.1f"], L["Isle of Conquest"], allyLowest, hordeLowest)
					if (NS.CommFlare.CF.StatusCheck and next(NS.CommFlare.CF.StatusCheck)) then
						-- process all
						local timer = 0.0
						for k,v in pairs(NS.CommFlare.CF.StatusCheck) do
							-- send replies staggered
							TimerAfter(timer, function()
								-- send message
								NS:SendMessage(k, text)
							end)

							-- next
							timer = timer + 0.2
						end
					end

					-- finished
					NS.CommFlare.CF.NeedAddonData = false
				end
			end
		end
	end
end

-- process chat battle net whisper
function NS.CommFlare:CHAT_MSG_BN_WHISPER(msg, ...)
	local text, sender, _, _, _, _, _, _, _, _, _, _, bnSenderID = ...

	-- invalid sender id?
	if (not bnSenderID) then
		-- no sender?
		if (not sender or (sender == "")) then
			-- failed
			return
		end

		-- find presense id from sender name
		bnSenderID = GetAutoCompletePresenceID(sender)
		if (not bnSenderID) then
			-- failed
			return
		end
	end

	-- version check?
	local lower = strlower(text)
	if (lower == "!cf") then
		-- process version check
		NS:Process_Version_Check(bnSenderID)
	-- pass leadership?
	elseif (lower == "!pl") then
		-- process pass leadership
		NS:Process_Pass_Leadership(bnSenderID)
	-- status check?
	elseif (lower == "!status") then
		-- in battleground?
		local timer = 0.0
		if (NS:IsInBattleground() == true) then
			-- battlefield score needs updating?
			if (PVPMatchScoreboard.selectedTab ~= 1) then
				-- request battlefield score
				SetBattlefieldScoreFaction(-1)
				RequestBattlefieldScoreData()

				-- delay 0.5 seconds
				timer = 0.5
			end
		end

		-- start processing
		TimerAfter(timer, function()
			-- process status check
			NS:Process_Status_Check(bnSenderID)
		end)
	else
		-- asking for invite?
		local args = {strsplit(" ", text)}
		local command = strlower(args[1])
		if ((command == "inv") or (command == "invite")) then
			-- process auto invite
			NS:Process_Auto_Invite(bnSenderID)
		-- !debug?
		elseif (command:find("!debug")) then
			-- process debug command
			NS:Process_Debug_Command(bnSenderID, args)
		end
	end
end

-- process chat communities channel message
function NS.CommFlare:CHAT_MSG_COMMUNITIES_CHANNEL(msg, ...)
	local text, sender, _, _, _, _, _, _, channelBaseName, _, _, bnSenderID = ...
	if (channelBaseName) then
		-- split up
		local name, clubId, streamId = strsplit(":", channelBaseName)
		if (name and clubId and streamId) then
			-- get player
			clubId = tonumber(clubId)
			local player = NS:GetPlayerName("full")
			local member = NS:Get_Community_Member(player)
			if (member and member.clubs and member.clubs[clubId]) then
				-- update chat message data history
				NS:Update_Chat_Message_Data(sender)
			end
		end
	end
end

-- handle chat party message events
function NS:Event_Chat_Message_Party(...)
	local text, sender = ...

	-- skip messages from yourself
	if (NS:GetPlayerName("full") ~= sender) then
		-- version check?
		local lower = strlower(text)
		if (lower:find("!cf")) then
			-- strip (name2chat):
			lower = strgsub(lower, "[\(](.+)[\)\:] ", "")

			-- exact matches only
			if (lower == "!cf") then
				-- send community flare version number
				NS:SendMessage(nil, strformat("%s: %s (%s)", NS.CommFlare.Title, NS.CommFlare.Version, NS.CommFlare.Build))
			end
		-- status check?
		elseif (lower:find("!status")) then
			-- strip (name2chat):
			lower = strgsub(lower, "[\(](.+)[\)\:] ", "")

			-- exact matches only
			if (lower == "!status") then
				-- are you group leader?
				if (NS:IsGroupLeader() == true) then
					-- in battleground?
					local timer = 0.0
					if (NS:IsInBattleground() == true) then
						-- battlefield score needs updating?
						if (PVPMatchScoreboard.selectedTab ~= 1) then
							-- request battlefield score
							SetBattlefieldScoreFaction(-1)
							RequestBattlefieldScoreData()

							-- delay 0.5 seconds
							timer = 0.5
						end
					end

					-- start processing
					TimerAfter(timer, function()
						-- process status check
						NS:Process_Status_Check(nil)
					end)
				end
			end
		end
	end
end

-- process chat monster yell message
function NS.CommFlare:CHAT_MSG_MONSTER_YELL(msg, ...)
	local text, sender = ...

	-- no text?
	if (not text or (text == "")) then
		-- failed
		return
	end

	-- Ashran, jeron killed?
	local lower = strlower(text)
	if (lower:find(L["jeron emberfall has been slain"])) then
		-- jeron emberfall killed
		NS.CommFlare.CF.ASH.Jeron = L["Killed"]
	-- Ashran, rylai killed?
	elseif (lower:find(L["rylai crestfall has been slain"])) then
		-- rylai crestfall killed
		NS.CommFlare.CF.ASH.Rylai = L["Killed"]
	end

	-- use player guid
	local faction = nil
	local guid = UnitGUID("player")
	if (guid) then
		-- get player score info by guid
		local info = PvPGetScoreInfoByPlayerGuid(guid)
		if (info and info.faction) then
			-- alliance faction?
			if (info.faction == 1) then
				-- set alliance
				faction = L["Alliance"]
			else
				-- set horde
				faction = L["Horde"]
			end
		end
	end

	-- faction not found?
	if (not faction) then
		-- use player faction
		faction = UnitFactionGroup("player")
	end

	-- alliance faction?
	if (faction == L["Alliance"]) then
		-- captain balinda stonehearth?
		if (sender == L["Captain Balinda Stonehearth"]) then
			-- engaged?
			if (lower:find(L["begone, uncouth scum!"])) then
				-- needs to issue raid warning?
				if (NS.CommFlare.CF.LastBossRW == 0) then
					-- update last raid warning
					NS.CommFlare.CF.LastBossRW = time()
					TimerAfter(15, function()
						-- clear last raid warning
						NS.CommFlare.CF.LastBossRW = 0
					end)

					-- do you have lead?
					local player = NS:GetPlayerName("full")
					NS.CommFlare.CF.PlayerRank = NS:GetRaidRank(UnitName("player"))
					if (NS.CommFlare.CF.PlayerRank == 2) then
						-- issue global raid warning
						NS:SendMessage("RAID_WARNING", strformat(L["%s is under attack!"], L["Captain Balinda Stonehearth"]))
					else
						-- issue local raid warning (with raid warning audio sound)
						RaidWarningFrame_OnEvent(RaidBossEmoteFrame, "CHAT_MSG_RAID_WARNING", strformat(L["%s is under attack!"], L["Captain Balinda Stonehearth"]))
					end
				end
			end
		end
	-- horde faction?
	elseif (faction == L["Horde"]) then
		-- captain galvangar?
		if (sender == L["Captain Galvangar"]) then
			-- engaged?
			if (lower:find(L["your kind has no place in alterac valley"])) then
				-- needs to issue raid warning?
				if (NS.CommFlare.CF.LastBossRW == 0) then
					-- update last raid warning
					NS.CommFlare.CF.LastBossRW = time()
					TimerAfter(15, function()
						-- clear last raid warning
						NS.CommFlare.CF.LastBossRW = 0
					end)

					-- do you have lead?
					local player = NS:GetPlayerName("full")
					NS.CommFlare.CF.PlayerRank = NS:GetRaidRank(UnitName("player"))
					if (NS.CommFlare.CF.PlayerRank == 2) then
						-- issue global raid warning
						NS:SendMessage("RAID_WARNING", strformat(L["%s is under attack!"], L["Captain Galvangar"]))
					else
						-- issue local raid warning (with raid warning audio sound)
						RaidWarningFrame_OnEvent(RaidBossEmoteFrame, "CHAT_MSG_RAID_WARNING", strformat(L["%s is under attack!"], L["Captain Galvangar"]))
					end
				end
			end
		end
	end
end

-- process chat party message
function NS.CommFlare:CHAT_MSG_PARTY(msg, ...)
	-- process chat message party event
	NS:Event_Chat_Message_Party(...)
end

-- process chat party leader message
function NS.CommFlare:CHAT_MSG_PARTY_LEADER(msg, ...)
	-- process chat message party event
	NS:Event_Chat_Message_Party(...)
end

-- process system message
function NS.CommFlare:CHAT_MSG_SYSTEM(msg, ...)
	local text, sender = ...

	-- joined the queue for?
	local lower = strlower(text)
	if (lower:find(L["joined the queue for"])) then
		-- update local group
		NS:Update_Group("local")
	-- notify system has been enabled?
	elseif (text == PVP_REPORT_AFK_SYSTEM_ENABLED) then
		-- restrict pings?
		if (NS.charDB.profile.restrictPings and (NS.charDB.profile.restrictPings > 0)) then
			-- does player have raid leadership or assistant?
			NS.CommFlare.CF.PlayerRank = NS:GetRaidRank(UnitName("player"))
			if (NS.CommFlare.CF.PlayerRank > 0) then
				-- set restrict pings
				PartyInfoSetRestrictPings(NS.charDB.profile.restrictPings)
			end
		end

		-- display battleground setup
		NS.CommFlare.CF.MatchStatus = 2
		NS.CommFlare.CF.MatchEndTime = 0
		NS.CommFlare.CF.MatchEndDate = ""
		NS.CommFlare.CF.MatchStartDate = date()
		NS.CommFlare.CF.MatchStartTime = time()
		NS.CommFlare.CF.MatchStartLogged = false

		-- in battleground?
		local timer = 0.0
		if (NS:IsInBattleground() == true) then
			-- battlefield score needs updating?
			if (PVPMatchScoreboard.selectedTab ~= 1) then
				-- request battlefield score
				SetBattlefieldScoreFaction(-1)
				RequestBattlefieldScoreData()

				-- delay 0.5 seconds
				timer = 0.5
			end
		end

		-- start processing
		TimerAfter(timer, function()
			-- update battleground / member / roster stuff
			NS:Update_Battleground_Stuff(true, true)
			NS:Update_Member_Statistics("started")
			NS:Match_Started_Log_Roster()
		end)
	end
end

-- process chat whisper message
function NS.CommFlare:CHAT_MSG_WHISPER(msg, ...)
	local text, sender = ...

	-- version check?
	local lower = strlower(text)
	if (lower == "!cf") then
		-- process version check
		NS:Process_Version_Check(sender)
	-- pass leadership?
	elseif (lower == "!pl") then
		-- process pass leadership
		NS:Process_Pass_Leadership(sender)
	-- status check?
	elseif (lower == "!status") then
		-- in battleground?
		local timer = 0.0
		if (NS:IsInBattleground() == true) then
			-- battlefield score needs updating?
			if (PVPMatchScoreboard.selectedTab ~= 1) then
				-- request battlefield score
				SetBattlefieldScoreFaction(-1)
				RequestBattlefieldScoreData()

				-- delay 0.5 seconds
				timer = 0.5
			end
		end

		-- start processing
		TimerAfter(timer, function()
			-- process status check
			NS:Process_Status_Check(sender)
		end)
	else
		-- asking for invite?
		local args = {strsplit(" ", text)}
		local command = strlower(args[1])
		if ((command == "inv") or (command == "invite")) then
			-- process auto invite
			NS:Process_Auto_Invite(sender)
		-- !debug?
		elseif (command:find("!debug")) then
			-- process debug command
			NS:Process_Debug_Command(sender, args)
		end
	end
end

-- process club member added
function NS.CommFlare:CLUB_MEMBER_ADDED(msg, ...)
	local clubId, memberId = ...

	-- find player in database
	local player = NS:GetPlayerName("full")
	local member = NS:Get_Community_Member(player)
	if (member and member.clubs and member.clubs[clubId]) then
		-- add club member
		NS:Club_Member_Added(clubId, memberId)
	-- main community?
	elseif (NS.charDB.profile.communityMain == clubId) then
		-- add club member
		NS:Club_Member_Added(clubId, memberId)
	-- has community list?
	elseif (NS.charDB.profile.communityList and (next(NS.charDB.profile.communityList) ~= nil)) then
		-- process all lists
		local count = 0
		for k,_ in pairs(NS.charDB.profile.communityList) do
			-- matches?
			if (clubId == k) then
				-- increase
				count = count + 1
			end
		end

		-- found?
		if (count > 0) then
			-- add club member
			NS:Club_Member_Added(clubId, memberId)
		end
	end
end

-- process club member presense updated
function NS.CommFlare:CLUB_MEMBER_PRESENCE_UPDATED(msg, ...)
	local clubId, memberId, presence = ...

	-- always update, except on mobile
	if ((presence > 0) and (presense ~= Enum.ClubMemberPresence.OnlineMobile)) then
		-- only communities
		local club = ClubGetClubInfo(clubId)
		if (club.clubType == Enum.ClubType.Character) then
			-- get member info
			local mi = ClubGetMemberInfo(clubId, memberId)
			if (mi and mi.name and (mi.name ~= "")) then
				-- build proper name
				local player = mi.name
				if (not strmatch(player, "-")) then
					-- add realm name
					player = player .. "-" .. NS.CommFlare.CF.PlayerServerName
				end

				-- get community member
				local member = NS:Get_Community_Member(player)
				if (member ~= nil) then
					-- update last seen
					NS:Update_Last_Seen(member.name)
				end
			end
		end
	end
end

-- process club member removed
function NS.CommFlare:CLUB_MEMBER_REMOVED(msg, ...)
	local clubId, memberId = ...

	-- main community?
	if (NS.charDB.profile.communityMain == clubId) then
		-- remove club member
		NS:Club_Member_Removed(clubId, memberId)
	end
end

-- process club member role updated
function NS.CommFlare:CLUB_MEMBER_ROLE_UPDATED(msg, ...)
	local clubId, memberId, roleId = ...

	-- update club member
	NS:Club_Member_Updated(clubId, memberId)
end

-- process club member updated
function NS.CommFlare:CLUB_MEMBER_UPDATED(msg, ...)
	local clubId, memberId = ...

	-- update club member
	NS:Club_Member_Updated(clubId, memberId)
end

-- process club streams loaded
function NS.CommFlare:CLUB_STREAMS_LOADED(msg, ...)
	local clubId = ...

	-- get club info
	local info = ClubGetClubInfo(clubId)
	if (info) then
		-- stream loaded
		NS.CommFlare.CF.StreamsLoaded[clubId] = true
	end
end

-- process combat log event unfiltered
function NS.CommFlare:COMBAT_LOG_EVENT_UNFILTERED(msg)
	-- ashran?
	if (NS.CommFlare.CF.MapID == 1478) then
		-- SPELL_CAST_SUCCESS?
		local timedate, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlag = CombatLogGetCurrentEventInfo()
		if (event == "SPELL_CAST_SUCCESS") then
			-- horde faction?
			if (NS.CommFlare.CF.PlayerFaction == L["Horde"]) then
				-- boss performing action?
				local timer = 15
				local npc_name = nil
				local npc_type = "boss"
				local should_warn = false
				sourceFlags = tonumber(sourceFlags)
				if (sourceName == "High Warlord Volrath") then
					-- setup npc name
					npc_name = L["High Warlord Volrath"]

					-- always warn
					should_warn = true
				-- action performed on boss?
				elseif (destName == "High Warlord Volrath") then
					-- setup npc name
					npc_name = L["High Warlord Volrath"]

					-- is source hostile?
					if (bitband(sourceFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) == COMBATLOG_OBJECT_REACTION_HOSTILE) then
						-- should warn
						should_warn = true
					end
				-- action performed on mage?
				elseif (destName == "Jeron Emberfall") then
					-- setup npc name
					npc_name = L["Jeron Emberfall"]

					-- is source hostile?
					if (bitband(sourceFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) == COMBATLOG_OBJECT_REACTION_HOSTILE) then
						-- should warn
						should_warn = true
						npc_type = "mage"
						timer = 30
					end
				end

				-- should warn?
				if ((should_warn == true) and npc_name) then
					-- boss?
					local issue_warning = false
					if (npc_type == "boss") then
						-- needs to issue raid warning?
						if (NS.CommFlare.CF.LastBossRW == 0) then
							-- update last raid warning
							NS.CommFlare.CF.LastBossRW = time()
							TimerAfter(timer, function()
								-- clear last raid warning
								NS.CommFlare.CF.LastBossRW = 0
							end)

							-- has npc name?
							if (npc_name and (npc_name ~= "")) then
								-- send addon message to instance chat
								local message = strformat("!CommFlare@%s@BOSS_ATTACKED@%s", NS.CommFlare.Version, npc_name)
								NS.CommFlare:SendCommMessage(ADDON_NAME, message, "INSTANCE_CHAT")
							end

							-- issue warning
							issue_warning = true
						end
					-- mage?
					elseif (npc_type == "mage") then
						-- needs to issue raid warning?
						if (NS.CommFlare.CF.LastMageRW == 0) then
							-- update last raid warning
							NS.CommFlare.CF.LastMageRW = time()
							TimerAfter(timer, function()
								-- clear last raid warning
								NS.CommFlare.CF.LastMageRW = 0
							end)

							-- issue warning
							issue_warning = true
						end
					end

					-- should issue warning?
					if (issue_warning == true) then
						-- do you have lead?
						local player = NS:GetPlayerName("full")
						NS.CommFlare.CF.PlayerRank = NS:GetRaidRank(UnitName("player"))
						if (NS.CommFlare.CF.PlayerRank == 2) then
							-- issue global raid warning
							NS:SendMessage("RAID_WARNING", strformat(L["%s is under attack!"], npc_name))
						else
							-- issue local raid warning (with raid warning audio sound)
							RaidWarningFrame_OnEvent(RaidBossEmoteFrame, "CHAT_MSG_RAID_WARNING", strformat(L["%s is under attack!"], npc_name))
						end
					end
				end
			end
		end
	end
end

-- process group formed
function NS.CommFlare:GROUP_FORMED(msg, ...)
	local category, partyGUID = ...

	-- save partyGUID
	NS.CommFlare.CF.PartyGUID = partyGUID
end

-- process group invite confirmation
function NS.CommFlare:GROUP_INVITE_CONFIRMATION(msg)
	-- check for auto invites?
	local autoInvite = false
	if (not IsInGroup()) then
		-- yes
		autoInvite = true
	elseif (not IsInRaid() and IsInGroup()) then
		-- yes
		autoInvite = true
	end

	-- mercenary queued?
	if (NS:Battleground_IsMercenaryQueued() == true) then
		-- get next pending invite
		local invite = GetNextPendingInviteConfirmation()
		if (invite) then
			-- cancel invite
			RespondToInviteConfirmation(invite, false)

			-- hide popup
			if (StaticPopup_FindVisible("GROUP_INVITE_CONFIRMATION")) then
				-- hide
				StaticPopup_Hide("GROUP_INVITE_CONFIRMATION")
			end
		end
	end

	-- check for auto invites?
	if (autoInvite == true) then
		-- read the text
		local text = StaticPopup1Text["text_arg1"]
		if (text and (text ~= "")) then
			-- you will be removed from?
			text = strlower(text)
			if (strfind(text, L["you will be removed from"])) then
				local invite = GetNextPendingInviteConfirmation()
				if (invite) then
					-- cancel invite
					RespondToInviteConfirmation(invite, false)

					-- hide popup
					if (StaticPopup_FindVisible("GROUP_INVITE_CONFIRMATION")) then
						-- hide
						StaticPopup_Hide("GROUP_INVITE_CONFIRMATION")
					end
				end
			-- has requested to join your group?
			elseif (strfind(text, L["has requested to join your group"])) then
				-- get next pending invite
				local invite = GetNextPendingInviteConfirmation()
				if (invite) then
					-- get invite confirmation info
					local confirmationType, name, guid, rolesInvalid, willConvertToRaid, level, spec, itemLevel = GetInviteConfirmationInfo(invite)
					local referredByGuid, referredByName, relationType, isQuickJoin, clubId = PartyInfoGetInviteReferralInfo(invite)
					local playerName, color, selfRelationship = SocialQueueUtil_GetRelationshipInfo(guid, name, clubId)

					-- will invite cause conversion to raid?
					if (willConvertToRaid or (GetNumGroupMembers() > 4) or PartyInfoIsPartyFull()) then
						-- cancel invite
						RespondToInviteConfirmation(invite, false)

						-- hide popup
						if (StaticPopup_FindVisible("GROUP_INVITE_CONFIRMATION")) then
							-- hide
							StaticPopup_Hide("GROUP_INVITE_CONFIRMATION")
						end

						-- battle net friend?
						if (selfRelationship == "bnfriend") then
							local accountInfo = BattleNetGetAccountInfoByGUID(guid)
							if (accountInfo and accountInfo.gameAccountInfo and accountInfo.gameAccountInfo.playerGuid) then
								-- send battle net message
								NS:SendMessage(accountInfo.bnetAccountID, L["Sorry, group is currently full."])
							end
						else
							-- send message
							NS:SendMessage(name, L["Sorry, group is currently full."])
						end
					else
						-- has proper name?
						local player = ""
						if (name and (name ~= "")) then
							-- force name-realm format
							player = name
							if (not strmatch(player, "-")) then
								-- add realm name
								player = player .. "-" .. NS.CommFlare.CF.PlayerServerName
							end
						end

						-- battle net friend?
						NS.CommFlare.CF.AutoInvite = false
						if (selfRelationship == "bnfriend") then
							-- battle net auto invite enabled?
							if (NS.charDB.profile.bnetAutoInvite == true) then
								-- auto invite enabled
								NS.CommFlare.CF.AutoInvite = true
							end
						end

						-- community auto invite enabled?
						if ((NS.CommFlare.CF.AutoInvite == false) and (NS.charDB.profile.communityAutoInvite == true)) then
							-- is sender a community member?
							NS.CommFlare.CF.AutoInvite = NS:Is_Community_Member(player)
						end

						-- auto invite?
						if (NS.CommFlare.CF.AutoInvite == true) then
							-- accept invite
							RespondToInviteConfirmation(invite, true)

							-- hide popup
							if (StaticPopup_FindVisible("GROUP_INVITE_CONFIRMATION")) then
								-- hide
								StaticPopup_Hide("GROUP_INVITE_CONFIRMATION")
							end
						end
					end
				end
			end
		end
	end
end

-- process group joined
function NS.CommFlare:GROUP_JOINED(msg, ...)
	local category, partyGUID = ...

	-- save partyGUID
	NS.CommFlare.CF.PartyGUID = partyGUID

	-- not in raid?
	if (not IsInRaid()) then
		-- queue exists?
		if (NS.CommFlare.CF.SocialQueues[partyGUID] and NS.CommFlare.CF.SocialQueues[partyGUID].guid and NS.CommFlare.CF.SocialQueues[partyGUID].created and (NS.CommFlare.CF.SocialQueues[partyGUID].created > 0)) then
			-- copy party queue to local
			NS.CommFlare.CF.SocialQueues["local"] = NS.CommFlare.CF.SocialQueues[partyGUID]
			NS.CommFlare.CF.SocialQueues[partyGUID] = nil

			-- update local group
			NS:Update_Group("local")
		end
	end
end

-- process group left
function NS.CommFlare:GROUP_LEFT(msg, ...)
	local category, partyGUID = ...

	-- disable community party leader
	NS.charDB.profile.communityPartyLeader = false

	-- delete partyGUID
	NS.CommFlare.CF.PartyGUID = nil

	-- not in raid?
	if (not IsInRaid()) then
		-- queue exists?
		if (NS.CommFlare.CF.SocialQueues["local"] and NS.CommFlare.CF.SocialQueues["local"].guid and NS.CommFlare.CF.SocialQueues["local"].created and (NS.CommFlare.CF.SocialQueues["local"].created > 0)) then
			-- copy local to party queues
			NS.CommFlare.CF.SocialQueues[partyGUID] = NS.CommFlare.CF.SocialQueues["local"]
			NS:Initialize_Group("local")

			-- update party group
			NS:Update_Group(partyGUID)
		end
	end
end

-- process group roster update
function NS.CommFlare:GROUP_ROSTER_UPDATE(msg)
	-- skip for arena
	local isArena = PvPIsArena()
	if (isArena == true) then
		-- finished
		return
	end

	-- skip for delves
	local isDelve = DelvesUIHasActiveDelve()
	if (isDelve == true) then
		-- finished
		return
	end

	-- in battleground?
	if (NS:IsInBattleground() == true) then
		-- prematch gate open
		if (NS.CommFlare.CF.MatchStatus == 1) then
			-- do you have lead?
			local player = NS:GetPlayerName("full")
			NS.CommFlare.CF.PlayerRank = NS:GetRaidRank(UnitName("player"))
			if (NS.CommFlare.CF.PlayerRank == 2) then
				-- process all raid members
				for i=1, MAX_RAID_MEMBERS do
					-- only process members not already promoted
					local name, rank = GetRaidRosterInfo(i)
					if (name and rank and (rank == 0)) then
						-- force name-realm format
						local full_name = name
						if (not strmatch(full_name, "-")) then
							-- add realm name
							full_name = full_name .. "-" .. NS.CommFlare.CF.PlayerServerName
						end

						-- get community member
						local member = NS:Get_Community_Member(full_name)
						if (member and member.name and member.clubs) then
							-- not already processed?
							if (not NS.CommFlare.CF.RosterList[full_name]) then
								-- should log list / i.e. has shared community?
								if (NS:Get_LogList_Status(full_name) == true) then
									-- only allow leaders?
									NS.CommFlare.CF.AutoPromote = false
									if (NS.charDB.profile.communityAutoAssist == 2) then
										-- player is community leader?
										if (NS:Is_Community_Leader(full_name) == true) then
											-- auto promote
											NS.CommFlare.CF.AutoPromote = true
										end
									-- allow all members?
									elseif (NS.charDB.profile.communityAutoAssist == 3) then
										-- auto promote
										NS.CommFlare.CF.AutoPromote = true
									end

									-- auto promote?
									if (NS.CommFlare.CF.AutoPromote == true) then
										-- promote
										PromoteToAssistant(name)
									end

									-- processed
									NS.CommFlare.CF.RosterList[full_name] = time()
								end
							end
						end
					end
				end

				-- auto pass raid leader?
				if (NS.charDB.profile.communityAutoPassLead == true) then
					-- process all community leaders
					for _,v in ipairs(NS.CommFlare.CF.CommunityLeaders) do
						-- already leader?
						if (player == v) then
							-- success
							break
						end

						-- promote this leader
						if (NS:PromoteToRaidLeader(v) == true) then
							-- success
							break
						end
					end
				end
			end
		end
	-- are you in local party?
	elseif (IsInGroup(LE_PARTY_CATEGORY_HOME)) then
		-- not in a raid?
		if (not IsInRaid()) then
			-- are you group leader?
			if (NS:IsGroupLeader() == true) then
				-- not in instance?
				local inInstance, instanceType = IsInInstance()
				if (inInstance ~= true) then
					-- community member?
					local message = "GROUP_ROSTER_UPDATE"
					if (NS.charDB.profile.communityMain > 1) then
						-- append YES
						message = message .. ":YES"
					else
						-- append NO
						message = message .. ":NO"
					end

					-- send party that leader has community flare
					NS.CommFlare:SendCommMessage(ADDON_NAME, message, "PARTY")
				end

				-- check current players in home party
				local count = 1
				local players = GetHomePartyInfo()
				if (players ~= nil) then
					-- has group size changed?
					local text = NS:GetGroupCount()
					count = #players + count
					local maxCount = NS:GetMaxPartyCount()
					if ((NS.CommFlare.CF.PreviousCount > 0) and (NS.CommFlare.CF.PreviousCount < maxCount) and (count == maxCount)) then
						-- community reporter enabled?
						if (NS.charDB.profile.communityReporter == true) then
							-- finalize text
							text = strformat("%s %s!", text, L["Full Now"])

							-- send to community
							NS:PopupBox("CommunityFlare_Send_Community_Dialog", text)
						end
					end
				end

				-- save previous count
				NS.CommFlare.CF.PreviousCount = count
			else
				-- clear previous count
				NS.CommFlare.CF.PreviousCount = 0
			end

			-- update local group
			NS:Update_Group("local")
		else
			-- clear previous count
			NS.CommFlare.CF.PreviousCount = 0
		end
	end
end

-- process initial clubs loaded
function NS.CommFlare:INITIAL_CLUBS_LOADED(msg)
	-- initial login?
	if (NS.CommFlare.CF.InitialLogin == false) then
		-- refresh club members
		NS:Refresh_Club_Members()

		-- initialized
		NS.CommFlare.CF.InitialLogin = true
	end
end

-- process lfg proposal done
function NS.CommFlare:LFG_PROPOSAL_DONE(msg)
	-- brawl queue exists?
	local index = "Brawl"
	if (NS.CommFlare.CF.LocalQueues[index]) then
		-- not rejected?
		if (NS.CommFlare.CF.LocalQueues[index].status ~= "rejected") then
			-- entered queue pop
			NS.CommFlare.CF.LocalQueues[index].status = "entered"
		end

		-- update brawl status
		NS:Update_Brawl_Status()
	end
end

-- process lfg proposal failed
function NS.CommFlare:LFG_PROPOSAL_FAILED(msg)
	-- brawl queue exists?
	local index = "Brawl"
	if (NS.CommFlare.CF.LocalQueues[index]) then
		-- not rejected?
		if (NS.CommFlare.CF.LocalQueues[index].status ~= "rejected") then
			-- missed queue pop
			NS.CommFlare.CF.LocalQueues[index].status = "failed"
		end

		-- update brawl status
		NS:Update_Brawl_Status()
	end
end

-- process lfg proposal show
function NS.CommFlare:LFG_PROPOSAL_SHOW(msg)
	-- brawl queue exists?
	local index = "Brawl"
	if (NS.CommFlare.CF.LocalQueues[index]) then
		-- update brawl status
		NS.CommFlare.CF.LocalQueues[index].status = "popped"
		NS:Update_Brawl_Status()
	end
end

-- process lfg proposal succeeded
function NS.CommFlare:LFG_PROPOSAL_SUCCEEDED(msg)
	-- brawl queue exists?
	local index = "Brawl"
	if (NS.CommFlare.CF.LocalQueues[index]) then
		-- update brawl status
		NS.CommFlare.CF.LocalQueues[index].status = "entered"
		NS:Update_Brawl_Status()
	end
end

-- process lfg role check role chosen
function NS.CommFlare:LFG_ROLE_CHECK_ROLE_CHOSEN(msg, ...)
	local name, isTank, isHealer, isDamage = ...
	local inProgress, slots, members, category, lfgID, bgQueue = GetLFGRoleUpdate()

	-- build proper name
	local player = name
	if (not strmatch(player, "-")) then
		-- add realm name
		player = player .. "-" .. NS.CommFlare.CF.PlayerServerName
	end

	-- are you group leader?
	if (NS:IsGroupLeader() == true) then
		-- is this your role?
		if (name == UnitName("player")) then
			-- reset counts
			NS.CommFlare.CF.LocalData.NumDPS = 0
			NS.CommFlare.CF.LocalData.NumHealers = 0
			NS.CommFlare.CF.LocalData.NumTanks = 0

			-- initialize queue session
			NS:Initialize_Queue_Session()
		end
	end

	-- is battleground queue?
	if (bgQueue) then
		-- is tracked pvp?
		local mapName = GetLFGRoleUpdateBattlegroundInfo()
		local isTracked, isEpicBattleground, isRandomBattleground, isBrawl = NS:IsTrackedPVP(mapName)
		if (isTracked == true) then
			-- first role chosen?
			if (not NS.CommFlare.CF.RoleChosen[player]) then
				-- is damage?
				if (isDamage == true) then
					-- increase
					NS.CommFlare.CF.LocalData.NumDPS = NS.CommFlare.CF.LocalData.NumDPS + 1
				end

				-- is healer?
				if (isHealer == true) then
					-- increase
					NS.CommFlare.CF.LocalData.NumHealers = NS.CommFlare.CF.LocalData.NumHealers + 1
				end

				-- is tank?
				if (isTank == true) then
					-- increase
					NS.CommFlare.CF.LocalData.NumTanks = NS.CommFlare.CF.LocalData.NumTanks + 1
				end
			end

			-- role chosen
			NS.CommFlare.CF.RoleChosen[player] = true
		end
	end
end

-- process lfg role check show
function NS.CommFlare:LFG_ROLE_CHECK_SHOW(msg, ...)
	local isRequeue = ...
	local inProgress, slots, members, category, lfgID, bgQueue = GetLFGRoleUpdate()

	-- is battleground queue?
	if (bgQueue) then
		-- is tracked pvp?
		local mapName = GetLFGRoleUpdateBattlegroundInfo()
		local isTracked, isEpicBattleground, isRandomBattleground, isBrawl = NS:IsTrackedPVP(mapName)
		if (isTracked == true) then
			-- capable of auto queuing?
			NS.CommFlare.CF.AutoQueueable = false
			if (not IsInRaid()) then
				NS.CommFlare.CF.AutoQueueable = true
			else
				-- larger than rated battleground count?
				if (GetNumGroupMembers() > 10) then
					NS.CommFlare.CF.AutoQueueable = true
				end
			end

			-- auto queueable?
			NS.CommFlare.CF.AutoQueue = false
			if (NS.CommFlare.CF.AutoQueueable == true) then
				-- party leader is community?
				if (NS.charDB.profile.communityPartyLeader == true) then
					-- auto queue enabled
					NS.CommFlare.CF.AutoQueue = true
				end

				-- always auto queue?
				if ((NS.CommFlare.CF.AutoQueue == false) and (NS.charDB.profile.alwaysAutoQueue == true)) then
					-- auto queue enabled
					NS.CommFlare.CF.AutoQueue = true
				end

				-- battle net auto queue enabled?
				if ((NS.CommFlare.CF.AutoQueue == false) and (NS.charDB.profile.bnetAutoQueue == true)) then
					local guid = NS:GetPartyLeaderGUID()
					local info = BattleNetGetAccountInfoByGUID(guid)
					if (info and (info.isFriend == true)) then
						-- auto invite enabled
						NS.CommFlare.CF.AutoQueue = true
					end
				end

				-- community auto queue?
				if ((NS.CommFlare.CF.AutoQueue == false) and (NS.charDB.profile.communityAutoQueue == true)) then
					-- is party leader a community member?
					local leader = NS:GetPartyLeader()
					NS.CommFlare.CF.AutoQueue = NS:Is_Community_Member(leader)
				end
			end

			-- auto queue enabled?
			if (NS.CommFlare.CF.AutoQueue == true) then
				-- check for deserter
				NS:CheckForAura("player", "HARMFUL", L["Deserter"])
				if (NS.CommFlare.CF.HasAura == false) then
					-- is shown?
					if (LFDRoleCheckPopupAcceptButton:IsShown()) then
						-- click accept button
						LFDRoleCheckPopupAcceptButton:Click()
					end
				else
					-- have deserter / leave party
					NS:SendMessage(nil, strformat("%s! %s!", L["Sorry, I currently have deserter"], L["Leaving party to avoid interrupting the queue"]))
					PartyInfoLeaveParty()
				end
			end
		end
	end
end

-- process lfg update
function NS.CommFlare:LFG_UPDATE(msg)
	-- update brawl status
	NS:Update_Brawl_Status()
end

-- process notify pvp afk result
function NS.CommFlare:NOTIFY_PVP_AFK_RESULT(msg, ...)
	local offender, numBlackMarksOnOffender, numPlayersIHaveReported = ...

	-- hmmm, what is this?
	print(strformat("NOTIFY_PVP_AFK_RESULT: %s = %s, %s", offender, numBlackMarksOnOffender, numPlayersIHaveReported))
end

-- process party invite request
function NS.CommFlare:PARTY_INVITE_REQUEST(msg, ...)
	local sender, _, _, _, _, _, guid, questSessionActive = ...

	-- enforce pvp roles
	NS:Enforce_PVP_Roles()

	-- verify player does not have deserter debuff
	NS:CheckForAura("player", "HARMFUL", L["Deserter"])
	if (NS.CommFlare.CF.HasAura == false) then
		-- battle net auto invite enabled?
		NS.CommFlare.CF.AutoInvite = false
		if (NS.charDB.profile.bnetAutoInvite == true) then
			local info = BattleNetGetAccountInfoByGUID(guid)
			if (info and (info.isFriend == true)) then
				-- auto invite enabled
				NS.CommFlare.CF.AutoInvite = true
			end
		end

		-- community auto invite enabled?
		if ((NS.CommFlare.CF.AutoInvite == false) and (NS.charDB.profile.communityAutoInvite == true)) then
			-- is sender a community member?
			NS.CommFlare.CF.AutoInvite = NS:Is_Community_Member(sender)
		end

		-- should auto invite?
		if (NS.CommFlare.CF.AutoInvite == true) then
			-- lfg invite popup shown?
			if (LFGInvitePopup:IsShown()) then
				-- force tank?
				local timer = nil
				if (NS.charDB.profile.forceTank == true) then
					-- wait some
					timer = 0.5
					TimerAfter(timer, function()
						-- click tank button
						LFGInvitePopupRoleButtonTank:Click()
					end)
				end

				-- force healer?
				if (NS.charDB.profile.forceHealer == true) then
					-- wait some
					timer = 0.5
					TimerAfter(timer, function()
						-- click healer button
						LFGInvitePopupRoleButtonHealer:Click()
					end)
				end

				-- force healer?
				if (NS.charDB.profile.forceDPS == true) then
					-- wait some
					timer = 0.5
					TimerAfter(timer, function()
						-- click dps button
						LFGInvitePopupRoleButtonDPS:Click()
					end)
				end

				-- no wait?
				if (not timer) then
					-- click accept button
					LFGInvitePopupAcceptButton:Click()
				else
					-- wait some
					timer = 0.5
					TimerAfter(timer, function()
						-- click accept button
						LFGInvitePopupAcceptButton:Click()
					end)
				end
			-- static popup shown?
			elseif (StaticPopup_FindVisible("PARTY_INVITE")) then
				-- accept party
				AcceptGroup()

				-- hide
				StaticPopup_Hide("PARTY_INVITE")
			end
		end
	else
		-- send whisper back that you have deserter
		NS:SendMessage(sender, strformat("%s!", L["Sorry, I currently have deserter"]))
		if (LFGInvitePopup:IsShown()) then
			-- click decline button
			LFGInvitePopupDeclineButton:Click()
		end
	end
end

-- process party leader changed
function NS.CommFlare:PARTY_LEADER_CHANGED(msg)
	-- update leader GUID
	NS.CommFlare.CF.LeaderGUID = NS:GetPartyLeaderGUID()

	-- notify enabled?
	if (NS.charDB.profile.partyLeaderNotify > 1) then
		-- are you in a party?
		if (IsInGroup() and not IsInRaid()) then
			-- has more than 1 member?
			if (GetNumSubgroupMembers() > 0) then
				-- are you group leader?
				if (NS:IsGroupLeader() == true) then
					-- you are the new party leader
					RaidWarningFrame_OnEvent(RaidBossEmoteFrame, "CHAT_MSG_RAID_WARNING", L["YOU ARE CURRENTLY THE NEW GROUP LEADER"])
				end
			end
		end
	end

	-- in a group?
	if (IsInGroup()) then
		-- not in a raid?
		if (not IsInRaid()) then
			-- update local group
			NS:Update_Group("local")
		end
	end
end

-- process player entering world
function NS.CommFlare:PLAYER_ENTERING_WORLD(msg, ...)
	local isInitialLogin, isReloadingUi = ...

	-- has old settings?
	if (NS.globalDB.profile) then
		-- process all values
		for k,v in pairs(NS.globalDB.profile) do
			-- save per character
			NS.charDB.profile[k] = NS.globalDB.profile[k]
			NS.globalDB.profile[k] = nil
		end
	end

	-- setup stuff
	NS.CommFlare.CF.VersionSent = false
	NS.CommFlare.CF.PlayerFaction = UnitFactionGroup("player")
	NS.CommFlare.CF.PlayerServerName = strgsub(GetRealmName(), "%s+", "")

	-- initial login or reloading?
	if ((isInitialLogin == true) or (isReloadingUi == true)) then
		-- display version
		local version, subversion = strsplit("-", NS.CommFlare.Version)
		local major, minor = strsplit(".", version)
		print(strformat("%s: %s", NS.CommFlare.Title, NS.CommFlare.Version))

		-- remove unused stuff
		NS.charDB.profile.communities = nil
		NS.charDB.profile.matchLogList = nil
		NS.charDB.profile.communityMainName = nil

		-- add chat whisper filtering
		ChatFrame_AddMessageEventFilter("CHAT_MSG_AFK", hook_Chat_Whisper_Filter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER", hook_Chat_Whisper_Filter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER_INFORM", hook_Chat_Whisper_Filter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", hook_Chat_Whisper_Filter)
		ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", hook_Chat_Whisper_Filter)

		-- has main community?
		if (NS.charDB.profile.communityMain > 1) then
			-- force enabled
			NS.charDB.profile.communityLeadersList[NS.charDB.profile.communityMain] = true
		end

		-- fix setting
		if (NS.charDB.profile.communityReportID == 0) then
			-- set default report ID
			NS.charDB.profile.communityReportID = NS.charDB.profile.communityMain
		end

		-- process queue stuff
		NS:SetupHooks()

		-- enforce pvp roles
		NS:Enforce_PVP_Roles()

		-- initialize login?
		if (isInitialLogin == true) then
			-- not reloaded
			NS.CommFlare.CF.Reloaded = false

			-- disable community party leader
			NS.charDB.profile.communityPartyLeader = false
		-- reloading?
		elseif (isReloadingUi == true) then
			-- reloaded
			NS.CommFlare.CF.Reloaded = true

			-- load previous session
			NS:LoadSession()

			-- update local group
			NS:Update_Group("local")

			-- in battleground?
			NS.CommFlare.CF.MatchStatus = 0
			if (NS:IsInBattleground() == true) then
				-- match state is active?
				if (PvPGetActiveMatchState() == Enum.PvPMatchState.Active) then
					-- match is active state?
					NS.CommFlare.CF.MatchStatus = 1
					if (PvPGetActiveMatchDuration() > 0) then
						-- match started
						NS.CommFlare.CF.MatchStatus = 2
					end
				end
			end

			-- refresh club members
			NS:Refresh_Club_Members()
		end
	end

	-- sanity checks
	NS:Sanity_Checks()

	-- initial login or reloading?
	if ((isInitialLogin == true) or (isReloadingUi == true)) then
		-- verify club streams
		NS.CommFlare.CF.StreamsRetryCount = 0
		local clubs = NS:Get_Enabled_Clubs()
		NS:Verify_Club_Streams(clubs)
	end
end

-- process player login
function NS.CommFlare:PLAYER_LOGIN(msg)
	-- verify default community setup
	NS:Verify_Default_Community_Setup()

	-- load previous session
	NS:LoadSession()
end

-- process player logout
function NS.CommFlare:PLAYER_LOGOUT(msg)
	-- enforce pvp roles
	NS:Enforce_PVP_Roles()

	-- save session variables
	NS:SaveSession()
end

-- process pvp match active
function NS.CommFlare:PVP_MATCH_ACTIVE(msg)
	-- initialize
	NS.CommFlare.CF.FullRoster = {}
	NS.CommFlare.CF.RosterList = {}
	NS:Initialize_Battleground_Status()

	-- always reset ashran mages
	NS.CommFlare.CF.ASH.Jeron = L["Up"]
	NS.CommFlare.CF.ASH.Rylai = L["Up"]

	-- active status
	NS.CommFlare.CF.LastBossRW = 0
	NS.CommFlare.CF.LastMageRW = 0
	NS.CommFlare.CF.MatchStatus = 1
	NS.CommFlare.CF.PlayerFaction = UnitFactionGroup("player")

	-- process club members
	NS:Process_Club_Members()

	-- should log pvp combat?
	if (NS.charDB.profile.pvpCombatLogging == true) then
		-- save old value
		NS.CommFlare.CF.PvpLoggingCombat = LoggingCombat()

		-- not enabled?
		if (NS.CommFlare.CF.PvpLoggingCombat ~= true) then
			-- enable combat logging
			LoggingCombat(true)
		end
	end
end

-- process pvp match complete
function NS.CommFlare:PVP_MATCH_COMPLETE(msg, ...)
	local winner, duration = ...

	-- enabled vehicle turn speed?
	if (NS.charDB.profile.adjustVehicleTurnSpeed > 0) then
		-- reset default speed
		NS.CommFlare.CF.TurnSpeed = GetCVarDefault("TurnSpeed")
		SetCVar("TurnSpeed", NS.CommFlare.CF.TurnSpeed)
	end

	-- match finished
	NS.CommFlare.CF.LeftTime = 0
	NS.CommFlare.CF.LastBossRW = 0
	NS.CommFlare.CF.LastMageRW = 0
	NS.CommFlare.CF.EnteredTime = 0
	NS.CommFlare.CF.MatchStatus = 3
	NS.CommFlare.CF.MatchEndDate = date()
	NS.CommFlare.CF.MatchEndTime = time()
	NS.CommFlare.CF.Winner = GetBattlefieldWinner()
	NS.CommFlare.CF.PlayerFaction = UnitFactionGroup("player")
	NS.CommFlare.CF.PlayerInfo = PvPGetScoreInfoByPlayerGuid(UnitGUID("player"))

	-- update battleground status
	local status = NS:Get_Current_Battleground_Status()
	if (status == true) then
		-- in battleground?
		local timer = 0.0
		if (NS:IsInBattleground() == true) then
			-- battlefield score needs updating?
			if (PVPMatchScoreboard.selectedTab ~= 1) then
				-- request battlefield score
				SetBattlefieldScoreFaction(-1)
				RequestBattlefieldScoreData()

				-- delay 0.5 seconds
				timer = 0.5
			end
		end

		-- start processing
		TimerAfter(timer, function()
			-- update battleground / member / roster stuff
			NS:Update_Battleground_Stuff(true, false)
			NS:Update_Member_Statistics("completed")
			NS:Match_Started_Log_Roster()
		end)
	end


	-- get MapID
	NS.CommFlare.CF.MapID = MapGetBestMapForUnit("player")
	if (NS.CommFlare.CF.MapID) then
		-- get map info
		NS.CommFlare.CF.MapInfo = MapGetMapInfo(NS.CommFlare.CF.MapID)
		if (NS.CommFlare.CF.MapInfo and NS.CommFlare.CF.MapInfo.name) then
			-- tracked pvp?
			local mapName = NS.CommFlare.CF.MapInfo.name
			local isTracked, isEpicBattleground, isRandomBattleground, isBrawl = NS:IsTrackedPVP(mapName)
			if (isTracked == true) then
				-- won the match?
				if (NS.CommFlare.CF.PlayerInfo.faction == NS.CommFlare.CF.Winner) then
					-- victory
					status = "Victory"
				else
					-- victory
					status = "Loss"
				end

				-- has leader GUID?
				local leaderGUID = NS.CommFlare.CF.LeaderGUID
				if (not leaderGUID) then
					-- use player
					leaderGUID = UnitGUID("player")
				end

				-- push data
				local timestamp = time()
				local partyGUID = NS:GetPartyGUID()
				local guids = strformat("%s,%s", leaderGUID, partyGUID)
				NS:BNPushData(strformat("!CF@%s@%s@Queue@Finished@%s,%s@%d@%d@%s", NS.CommFlare.Version, NS.CommFlare.Build, mapName, status, timestamp, NS.CommFlare.CF.CommCount, guids))
			end
		end
	end

	-- report to anyone?
	if (NS.CommFlare.CF.StatusCheck and next(NS.CommFlare.CF.StatusCheck)) then
		-- process all
		local timer = 0.0
		for k,v in pairs(NS.CommFlare.CF.StatusCheck) do
			-- send replies staggered
			TimerAfter(timer, function()
				-- won the match?
				if (NS.CommFlare.CF.PlayerInfo.faction == NS.CommFlare.CF.Winner) then
					-- victory
					text = strformat("%s %s!", L["Epic battleground has completed with a"], L["victory"])
				else
					-- loss
					text = strformat("%s %s!", L["Epic battleground has completed with a"], L["loss"])
				end

				-- send message
				NS:SendMessage(k, strformat("%s (%d %s)", text, NS.CommFlare.CF.CommCount, L["Community Members"]))
			end)

			-- next
			timer = timer + 0.2
		end
	end

	-- clear
	NS.CommFlare.CF.StatusCheck = {}

	-- should log pvp combat?
	if (NS.charDB.profile.pvpCombatLogging == true) then
		-- reset combat logging
		LoggingCombat(NS.CommFlare.CF.PvpLoggingCombat)
	end
end

-- process pvp match inactive
function NS.CommFlare:PVP_MATCH_INACTIVE(msg)
	-- reset battleground status
	NS.CommFlare.CF.MatchStatus = 0
	NS:Reset_Battleground_Status()
end

-- process quest detail
function NS.CommFlare:QUEST_DETAIL(msg, ...)
	local questStartItemID = ...

	-- verify quest giver
	local player, realm = UnitName("questnpc")
	if (player and (player ~= "")) then
		-- has realm?
		if (realm and (realm ~= "")) then
			-- add realm
			player = player .. "-" .. realm
		end

		-- unit in raid?
		if (UnitInRaid(player) ~= nil) then
			-- in battleground?
			if (NS:IsInBattleground() == true) then
				-- block all shared quests?
				local decline = false
				if (NS.charDB.profile.blockSharedQuests == 3) then
					-- always decline
					decline = true
				-- block irrelevant quests?
				elseif (NS.charDB.profile.blockSharedQuests == 2) then
					-- get MapID
					NS.CommFlare.CF.MapID = MapGetBestMapForUnit("player")
					if (NS.CommFlare.CF.MapID and (NS.CommFlare.CF.MapID > 0)) then
						-- initialize
						decline = true
						local epicBG = false
						NS.CommFlare.CF.QuestID = GetQuestID()

						-- alterac valley or korrak's revenge?
						if ((NS.CommFlare.CF.MapID == 91) or (NS.CommFlare.CF.MapID == 1537)) then
							-- list of allowed quests
							local allowedQuests = {
								[56256] = true, -- The Battle for Alterac [A] (Seasonal)
								[56257] = true, -- The Battle for Alterac [H] (Seasonal)
								[56258] = true, -- Ivus the Forest Lord [A] (Seasonal)
								[56259] = true, -- Lokholar the Ice Lord [H] (Seasonal)
							}

							-- allowed quest?
							epicBG = true
							if (allowedQuests[NS.CommFlare.CF.QuestID] and (allowedQuests[NS.CommFlare.CF.QuestID] == true)) then
								-- allowed
								decline = false
							end
						-- isle of conquest?
						elseif (NS.CommFlare.CF.MapID == 169) then
							-- epic battleground
							epicBG = true
						-- battle for wintergrasp?
						elseif (NS.CommFlare.CF.MapID == 1334) then
							-- list of allowed quests
							local allowedQuests = {
								[13177] = true, -- No Mercy for the Merciless [A]
								[13178] = true, -- Slay them all! [H]
								[13178] = true, -- No Mercy for the Merciless [A]
								[13180] = true, -- Slay them all! [H]
								[13181] = true, -- Victory in Wintergrasp [A]
								[13183] = true, -- Victory in Wintergrasp [H]
								[13185] = true, -- Stop the Siege [H]
								[13186] = true, -- Stop the Siege [A]
								[13222] = true, -- Defend the Siege [A]
								[13223] = true, -- Defend the Siege [H]
								[13538] = true, -- Southern Sabotage [A]
								[13539] = true, -- Toppling the Towers [H]
								[55508] = true, -- Victory in Wintergrasp [A] (Seasonal)
								[55509] = true, -- Victory in Wintergrasp [H] (Seasonal)
								[55510] = true, -- No Mercy for the Merciless [A] (Seasonal)
								[55511] = true, -- Slay them all! [H] (Seasonal)
							}

							-- allowed quest?
							epicBG = true
							if (allowedQuests[NS.CommFlare.CF.QuestID] and (allowedQuests[NS.CommFlare.CF.QuestID] == true)) then
								-- allowed
								decline = false
							end
						-- ashran?
						elseif (NS.CommFlare.CF.MapID == 1478) then
							-- list of allowed quests
							local allowedQuests = {
								[56336] = true, -- Uncovering the Artifact Fragments [A] (Seasonal)
								[56337] = true, -- Uncovering the Artifact Fragments [H] (Seasonal)
								[56338] = true, -- Volrath Must Die [A] (Seasonal)
								[56339] = true, -- Tremblade Must Die [H] (Seasonal)
							}

							-- allowed quest?
							epicBG = true
							if (allowedQuests[NS.CommFlare.CF.QuestID] and (allowedQuests[NS.CommFlare.CF.QuestID] == true)) then
								-- allowed
								decline = false
							end
						end

						-- epic battleground?
						if (epicBG == true) then
							-- list of allowed quests
							local allowedQuests = {
								[72166] = true, -- Proving in Battle [A]
								[72167] = true, -- Proving in War [H]
								[72723] = true, -- A Call to Battle
								[80186] = true, -- Preserving in War
							}

							-- allowed quest?
							if (allowedQuests[NS.CommFlare.CF.QuestID] and (allowedQuests[NS.CommFlare.CF.QuestID] == true)) then
								-- allowed
								decline = false
							end
						else
							-- list of allowed quests
							local allowedQuests = {
								[47148] = true, -- Something Different (Seasonal)
							}

							-- allowed quest?
							if (allowedQuests[NS.CommFlare.CF.QuestID] and (allowedQuests[NS.CommFlare.CF.QuestID] == true)) then
								-- allowed
								decline = false
							end
						end
					end
				end

				-- decline?
				if (decline == true) then
					-- decline quest
					DeclineQuest()
					print(strformat("%s %s", L["Auto declined quest from"], player))
				end
			end
		end
	end
end

-- process ready check
function NS.CommFlare:READY_CHECK(msg, ...)
	local sender, timeleft = ...

	-- are you in a party?
	NS.CommFlare.CF.ReadyCheck = {}
	NS.CommFlare.CF.PartyVersions = {}
	if (IsInGroup() and not IsInRaid()) then
		-- are you group leader?
		if (NS:IsGroupLeader() == true) then
			-- send ready check message
			NS.CommFlare:SendCommMessage(ADDON_NAME, "READY_CHECK", "PARTY")
		end
	end

	-- does the player have the mercenary buff?
	NS:CheckForAura("player", "HELPFUL", L["Mercenary Contract"])
	if (NS.CommFlare.CF.HasAura == true) then
		-- send party message
		NS:SendMessage(nil, strformat(L["I currently have the %s buff! (Are we mercing?)"], L["Mercenary Contract"]))
	end

	-- capable of auto queuing?
	NS.CommFlare.CF.AutoQueueable = false
	if (not IsInRaid()) then
		-- auto queue
		NS.CommFlare.CF.AutoQueueable = true
	else
		-- larger than rated battleground count?
		if (GetNumGroupMembers() > 10) then
			-- auto queue
			NS.CommFlare.CF.AutoQueueable = true
		end
	end

	-- auto queueable?
	NS.CommFlare.CF.AutoQueue = false
	if (NS.CommFlare.CF.AutoQueueable == true) then
		-- party leader is community?
		if (NS.charDB.profile.communityPartyLeader == true) then
			-- auto queue enabled
			NS.CommFlare.CF.AutoQueue = true
		end

		-- always auto queue?
		if ((NS.CommFlare.CF.AutoQueue == false) and (NS.charDB.profile.alwaysAutoQueue == true)) then
			-- auto queue enabled
			NS.CommFlare.CF.AutoQueue = true
		end

		-- battle net auto queue enabled?
		if ((NS.CommFlare.CF.AutoQueue == false) and (NS.charDB.profile.bnetAutoQueue == true)) then
			local guid = NS:GetPartyLeaderGUID()
			local info = BattleNetGetAccountInfoByGUID(guid)
			if (info and (info.isFriend == true)) then
				-- auto queue enabled
				NS.CommFlare.CF.AutoQueue = true
			end
		end

		-- community auto queue?
		if ((NS.CommFlare.CF.AutoQueue == false) and (NS.charDB.profile.communityAutoQueue == true)) then
			-- is sender a community member?
			NS.CommFlare.CF.AutoQueue = NS:Is_Community_Member(sender)
		end
	end

	-- auto queue enabled?
	if (NS.CommFlare.CF.AutoQueue == true) then
		-- verify player does not have deserter debuff
		NS:CheckForAura("player", "HARMFUL", L["Deserter"])
		if (NS.CommFlare.CF.HasAura == false) then
			if (ReadyCheckFrame:IsShown()) then
				-- click yes button
				ReadyCheckFrameYesButton:Click()
			end

			-- ready
			NS.CommFlare.CF.ReadyCheck["player"] = true
			NS.CommFlare.CF.PartyVersions["player"] = NS.CommFlare.Version
		else
			-- send back to party that you have deserter
			NS:SendMessage(nil, strformat("%s!", L["Sorry, I currently have deserter"]))
			if (ReadyCheckFrame:IsShown()) then
				-- click no button
				ReadyCheckFrameNoButton:Click()
			end

			-- not ready
			NS.CommFlare.CF.ReadyCheck["player"] = false
			NS.CommFlare.CF.PartyVersions["player"] = NS.CommFlare.Version
		end
	end
end

-- process ready check confirm
function NS.CommFlare:READY_CHECK_CONFIRM(msg, ...)
	local unit, isReady = ...

	-- auto queueable?
	if (NS.CommFlare.CF.AutoQueueable == true) then
		-- save unit ready check status
		NS.CommFlare.CF.ReadyCheck[unit] = isReady
	end
end

-- process ready check finished
function NS.CommFlare:READY_CHECK_FINISHED(msg, ...)
	local preempted = ...
	if (preempted == true) then
		-- clear ready check
		NS.CommFlare.CF.ReadyCheck = {}
		return
	end

	-- auto queueable?
	if (NS.CommFlare.CF.AutoQueueable == true) then
		-- are you in a party?
		if (IsInGroup() and not IsInRaid()) then
			-- process all ready checks
			local isEveryoneReady = true
			for k,v in pairs(NS.CommFlare.CF.ReadyCheck) do
				-- unit not ready?
				if (v ~= true) then
					-- everyone not ready
					isEveryoneReady = false
				end
			end

			-- is everyone ready?
			if (isEveryoneReady == true) then
				-- community reporter enabled?
				if (NS.charDB.profile.communityReporter == true) then
					-- are you group leader?
					if (NS:IsGroupLeader() == true) then
						-- alliance faction?
						local text = ""
						local faction = UnitFactionGroup("player")
						if (faction == L["Alliance"]) then
							-- alliance ready
							text = strformat(L["%s Alliance Ready!"], NS:GetGroupCount())
						-- horde faction?
						elseif (faction == L["Horde"]) then
							-- horde ready
							text = strformat(L["%s Horde Ready!"], NS:GetGroupCount())
						else
							-- unknown faction?
							text = strformat("%s %s!", NS:GetGroupCount(), L["Ready"])
						end

						-- does the player have the mercenary buff?
						NS:CheckForAura("player", "HELPFUL", L["Mercenary Contract"])
						if (NS.CommFlare.CF.HasAura == true) then
							-- add mercenary contract
							text = strformat("%s [%s]", text, L["Mercenary Contract"])
						end

						-- check if group has room for more
						local maxCount = NS:GetMaxPartyCount()
						if (NS.CommFlare.CF.Count < maxCount) then
							-- community auto invite enabled
							if (NS.charDB.profile.communityAutoInvite == true) then
								-- update text
								text = strformat("%s (%s)", text, L["For auto invite, whisper me INV"])
							end
						end

						-- send to community
						NS:PopupBox("CommunityFlare_Send_Community_Dialog", text)
					end
				end
			end
		end
	end

	-- clear ready check
	NS.CommFlare.CF.ReadyCheck = {}
end

-- process social queue update
function NS.CommFlare:SOCIAL_QUEUE_UPDATE(msg, ...)
	local groupGUID, numAddedItems = ...

	-- nothing added?
	local canJoin, numQueues, needTank, needHealer, needDamage, isSoloQueueParty, questSessionActive, leaderGUID = SocialQueueGetGroupInfo(groupGUID)
	if ((not groupGUID) or (not numAddedItems) or (not leaderGUID)) then
		-- finished
		return
	end

	-- update group
	NS:Update_Group(groupGUID)
end

-- process ui info message
function NS.CommFlare:UI_INFO_MESSAGE(msg, ...)
	local type, text = ...

	-- someone has deserter?
	text = strlower(text)
	if (text:find("deserter")) then
		print(strformat("%s!", L["Someone has deserter debuff"]))
	end
end

-- process unit aura
function NS.CommFlare:UNIT_AURA(msg, ...)
	local unitTarget, updateInfo = ...

	-- check for player
	if (unitTarget == "player") then
		-- in battleground?
		if (NS:IsInBattleground() == true) then
			-- any added auras?
			if (updateInfo.addedAuras) then
				-- process all added auras
				for k,v in ipairs(updateInfo.addedAuras) do
					-- reported for inactive?
					if (v.spellId == 94028) then
						-- issue local raid warning (with raid warning audio sound)
						RaidWarningFrame_OnEvent(RaidBossEmoteFrame, "CHAT_MSG_RAID_WARNING", L["WARNING: REPORTED INACTIVE!\nGet into combat quickly!"])
					-- mercenary contract?
					elseif ((v.spellId == 193472) or (v.spellId == 193475)) then
						-- are you in a party?
						if (IsInGroup() and not IsInRaid()) then
							-- send party message
							NS:SendMessage(nil, strformat(L["I currently have the %s buff! (Are we mercing?)"], L["Mercenary Contract"]))
						end
					-- shadow rift?
					elseif (v.spellId == 353293) then
						-- issue local raid warning (with raid warning audio sound)
						RaidWarningFrame_OnEvent(RaidBossEmoteFrame, "CHAT_MSG_RAID_WARNING", L["WARNING: SHADOW RIFT!\nCast immunity or run out of the circle!"])
					end
				end
			end
		end
	end
end

-- process unit entered vehicle
function NS.CommFlare:UNIT_ENTERED_VEHICLE(msg, ...)
	local unitTarget, showVehicleFrame, isControlSeat, vehicleUIIndicatorID, vehicleGUID, mayChooseExit, hasPitch = ...

	-- check for player
	if (unitTarget == "player") then
		-- in battleground?
		if (NS:IsInBattleground() == true) then
			-- sanity check
			if ((NS.charDB.profile.adjustVehicleTurnSpeed < 1) or (NS.charDB.profile.adjustVehicleTurnSpeed > 3)) then
				-- force default
				NS.charDB.profile.adjustVehicleTurnSpeed = 1
			end

			-- save old speed
			NS.CommFlare.CF.TurnSpeed = GetCVar("TurnSpeed")

			-- set new speed
			local speed = NS.charDB.profile.adjustVehicleTurnSpeed * 180
			SetCVar("TurnSpeed", speed)
		end
	end
end

-- process unit exited vehicle
function NS.CommFlare:UNIT_EXITED_VEHICLE(msg, ...)
	local unitTarget = ...

	-- check for player
	if (unitTarget == "player") then
		-- in battleground?
		if (NS:IsInBattleground() == true) then
			-- default?
			if (NS.charDB.profile.adjustVehicleTurnSpeed == 1) then
				-- reset default speed?
				NS.CommFlare.CF.TurnSpeed = GetCVarDefault("TurnSpeed")
			end

			-- set default or previous speed
			SetCVar("TurnSpeed", NS.CommFlare.CF.TurnSpeed)
		end
	end
end

-- process unit spellcast start
function NS.CommFlare:UNIT_SPELLCAST_START(msg, ...)
	local unitTarget, castGUID, spellID = ...

	-- only check player
	if (unitTarget == "player") then
		-- has warning setting enabled?
		if (NS.charDB.profile.warningLeavingBG > 1) then
			-- in battleground?
			if (NS:IsInBattleground() == true) then
				-- hearthstone?
				if (NS.CommFlare.HearthStoneSpells[spellID]) then
					-- raid warning?
					if (NS.charDB.profile.warningLeavingBG == 2) then
						-- issue local raid warning (with raid warning audio sound)
						RaidWarningFrame_OnEvent(RaidBossEmoteFrame, "CHAT_MSG_RAID_WARNING", L["Are you really sure you want to hearthstone?"])
					end
				-- teleporting?
				elseif (NS.CommFlare.TeleportSpells[spellID]) then
					-- raid warning?
					if (NS.charDB.profile.warningLeavingBG == 2) then
						-- issue local raid warning (with raid warning audio sound)
						RaidWarningFrame_OnEvent(RaidBossEmoteFrame, "CHAT_MSG_RAID_WARNING", L["Are you really sure you want to teleport?"])
					end
				end
			end
		end
	end
end

-- process update battlefield score
function NS.CommFlare:UPDATE_BATTLEFIELD_SCORE(msg)
	-- match still going?
	if (NS.CommFlare.CF.MatchStatus < 3) then
		-- process all scores
		for i=1, GetNumBattlefieldScores() do
			local info = PvPGetScoreInfo(i)
			if (info) then
				-- force name-realm format
				local player = info.name
				if (not strmatch(player, "-")) then
					-- add realm name
					player = player .. "-" .. NS.CommFlare.CF.PlayerServerName
				end

				-- add to full roster
				NS.CommFlare.CF.FullRoster[player] = info
			end
		end
	end
end

-- process update battlefield status
function NS.CommFlare:UPDATE_BATTLEFIELD_STATUS(msg, ...)
	-- sanity check
	local index = ...
	if (not index or (index < 1) or (index > GetMaxBattlefieldID())) then
		-- finished
		return
	end

	-- update battlefield status
	NS:Update_Battlefield_Status(index)
end

-- process zone changed new area
function NS.CommFlare:ZONE_CHANGED_NEW_AREA(msg)
	-- version already sent?
	if (NS.CommFlare.CF.VersionSent == true) then
		-- clear version sent
		NS.CommFlare.CF.VersionSent = false
		return
	end

	-- get map id
	NS.CommFlare.CF.MapID = MapGetBestMapForUnit("player")
	if (not NS.CommFlare.CF.MapID) then
		-- not found
		return
	end

	-- get map info
	NS.CommFlare.CF.MapInfo = MapGetMapInfo(NS.CommFlare.CF.MapID)
	if (not NS.CommFlare.CF.MapInfo) then
		-- not found
		return
	end

	-- is tracked pvp?
	local mapName = NS.CommFlare.CF.MapInfo.name
	local isTracked, isEpicBattleground, isRandomBattleground, isBrawl = NS:IsTrackedPVP(mapName)
	if (isTracked == true) then
		-- has main community?
		local mainID = 1
		if (NS.charDB.profile.communityMain and (NS.charDB.profile.communityMain > 1)) then
			-- set mainID
			mainID = NS.charDB.profile.communityMain
		end

		-- send addon message to instance chat
		local message = strformat("!CommFlare@%s@VERSION_CHECK@%s", NS.CommFlare.Version, tostring(mainID))
		NS.CommFlare:SendCommMessage(ADDON_NAME, message, "INSTANCE_CHAT")

		-- in a guild?
		if (IsInGuild() == true) then
			-- send addon message to guild
			NS.CommFlare:SendCommMessage(ADDON_NAME, message, "GUILD")
		end

		-- set version sent
		NS.CommFlare.CF.VersionSent = true
	else
		-- clear version sent
		NS.CommFlare.CF.VersionSent = false
	end
end

-- enabled
function NS.CommFlare:OnEnable()
	-- register events
	self:RegisterEvent("ADDON_LOADED")
	self:RegisterEvent("BN_CHAT_MSG_ADDON")
	self:RegisterEvent("CHAT_MSG_ADDON")
	self:RegisterEvent("CHAT_MSG_BN_WHISPER")
	self:RegisterEvent("CHAT_MSG_COMMUNITIES_CHANNEL")
	self:RegisterEvent("CHAT_MSG_PARTY")
	self:RegisterEvent("CHAT_MSG_PARTY_LEADER")
	self:RegisterEvent("CHAT_MSG_SYSTEM")
	self:RegisterEvent("CHAT_MSG_WHISPER")
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterEvent("CLUB_MEMBER_ADDED")
	self:RegisterEvent("CLUB_MEMBER_PRESENCE_UPDATED")
	self:RegisterEvent("CLUB_MEMBER_REMOVED")
	self:RegisterEvent("CLUB_MEMBER_ROLE_UPDATED")
	self:RegisterEvent("CLUB_MEMBER_UPDATED")
	self:RegisterEvent("CLUB_STREAMS_LOADED")
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	self:RegisterEvent("GROUP_FORMED")
	self:RegisterEvent("GROUP_INVITE_CONFIRMATION")
	self:RegisterEvent("GROUP_JOINED")
	self:RegisterEvent("GROUP_LEFT")
	self:RegisterEvent("GROUP_ROSTER_UPDATE")
	self:RegisterEvent("INITIAL_CLUBS_LOADED")
	self:RegisterEvent("LFG_PROPOSAL_DONE")
	self:RegisterEvent("LFG_PROPOSAL_FAILED")
	self:RegisterEvent("LFG_PROPOSAL_SHOW")
	self:RegisterEvent("LFG_PROPOSAL_SUCCEEDED")
	self:RegisterEvent("LFG_ROLE_CHECK_ROLE_CHOSEN")
	self:RegisterEvent("LFG_ROLE_CHECK_SHOW")
	self:RegisterEvent("LFG_UPDATE")
	self:RegisterEvent("NOTIFY_PVP_AFK_RESULT")
	self:RegisterEvent("PARTY_INVITE_REQUEST")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PARTY_LEADER_CHANGED")
	self:RegisterEvent("PLAYER_LOGIN")
	self:RegisterEvent("PLAYER_LOGOUT")
	self:RegisterEvent("PVP_MATCH_ACTIVE")
	self:RegisterEvent("PVP_MATCH_COMPLETE")
	self:RegisterEvent("PVP_MATCH_INACTIVE")
	self:RegisterEvent("QUEST_DETAIL")
	self:RegisterEvent("READY_CHECK")
	self:RegisterEvent("READY_CHECK_CONFIRM")
	self:RegisterEvent("READY_CHECK_FINISHED")
	self:RegisterEvent("SOCIAL_QUEUE_UPDATE")
	self:RegisterEvent("UI_INFO_MESSAGE")
	self:RegisterEvent("UNIT_AURA")
	self:RegisterEvent("UNIT_ENTERED_VEHICLE")
	self:RegisterEvent("UNIT_EXITED_VEHICLE")
	self:RegisterEvent("UNIT_SPELLCAST_START")
	self:RegisterEvent("UPDATE_BATTLEFIELD_SCORE")
	self:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
end

-- disabled
function NS.CommFlare:OnDisable()
	-- unregister events
	self:UnregisterEvent("ADDON_LOADED")
	self:UnregisterEvent("BN_CHAT_MSG_ADDON")
	self:UnregisterEvent("CHAT_MSG_ADDON")
	self:UnregisterEvent("CHAT_MSG_BN_WHISPER")
	self:UnregisterEvent("CHAT_MSG_COMMUNITIES_CHANNEL")
	self:UnregisterEvent("CHAT_MSG_PARTY")
	self:UnregisterEvent("CHAT_MSG_PARTY_LEADER")
	self:UnregisterEvent("CHAT_MSG_SYSTEM")
	self:UnregisterEvent("CHAT_MSG_WHISPER")
	self:UnregisterEvent("CHAT_MSG_MONSTER_YELL")
	self:UnregisterEvent("CLUB_MEMBER_ADDED")
	self:UnregisterEvent("CLUB_MEMBER_PRESENCE_UPDATED")
	self:UnregisterEvent("CLUB_MEMBER_REMOVED")
	self:UnregisterEvent("CLUB_MEMBER_ROLE_UPDATED")
	self:UnregisterEvent("CLUB_MEMBER_UPDATED")
	self:UnregisterEvent("CLUB_STREAMS_LOADED")
	self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	self:UnregisterEvent("GROUP_FORMED")
	self:UnregisterEvent("GROUP_INVITE_CONFIRMATION")
	self:UnregisterEvent("GROUP_JOINED")
	self:UnregisterEvent("GROUP_LEFT")
	self:UnregisterEvent("GROUP_ROSTER_UPDATE")
	self:UnregisterEvent("INITIAL_CLUBS_LOADED")
	self:UnregisterEvent("LFG_PROPOSAL_DONE")
	self:UnregisterEvent("LFG_PROPOSAL_FAILED")
	self:UnregisterEvent("LFG_PROPOSAL_SHOW")
	self:UnregisterEvent("LFG_PROPOSAL_SUCCEEDED")
	self:UnregisterEvent("LFG_ROLE_CHECK_ROLE_CHOSEN")
	self:UnregisterEvent("LFG_ROLE_CHECK_SHOW")
	self:UnregisterEvent("LFG_UPDATE")
	self:UnregisterEvent("NOTIFY_PVP_AFK_RESULT")
	self:UnregisterEvent("PARTY_INVITE_REQUEST")
	self:UnregisterEvent("PARTY_LEADER_CHANGED")
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	self:UnregisterEvent("PLAYER_LOGIN")
	self:UnregisterEvent("PLAYER_LOGOUT")
	self:UnregisterEvent("PVP_MATCH_ACTIVE")
	self:UnregisterEvent("PVP_MATCH_COMPLETE")
	self:UnregisterEvent("PVP_MATCH_INACTIVE")
	self:UnregisterEvent("QUEST_DETAIL")
	self:UnregisterEvent("READY_CHECK")
	self:UnregisterEvent("READY_CHECK_CONFIRM")
	self:UnregisterEvent("READY_CHECK_FINISHED")
	self:UnregisterEvent("SOCIAL_QUEUE_UPDATE")
	self:UnregisterEvent("UI_INFO_MESSAGE")
	self:UnregisterEvent("UNIT_AURA")
	self:UnregisterEvent("UNIT_ENTERED_VEHICLE")
	self:UnregisterEvent("UNIT_EXITED_VEHICLE")
	self:UnregisterEvent("UNIT_SPELLCAST_START")
	self:UnregisterEvent("UPDATE_BATTLEFIELD_SCORE")
	self:UnregisterEvent("UPDATE_BATTLEFIELD_STATUS")
	self:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
end

-- communication received
function NS.CommFlare:Community_Flare_OnCommReceived(prefix, message, distribution, sender)
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
				-- has npc name?
				if (args[4] and (args[4] ~= "")) then
					-- do you have lead?
					player = NS:GetPlayerName("full")
					NS.CommFlare.CF.PlayerRank = NS:GetRaidRank(UnitName("player"))
					if (NS.CommFlare.CF.PlayerRank and (NS.CommFlare.CF.PlayerRank ~= 2)) then
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
							RaidWarningFrame_OnEvent(RaidBossEmoteFrame, "CHAT_MSG_RAID_WARNING", strformat(L["%s is under attack!"], args[4]))
						end
					end
				end
			-- version checked?
			elseif (args[3] == "VERSION_CHECK") then
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
		else
			-- group joined?
			if (message:find("GROUP_ROSTER_UPDATE")) then
				-- are you not group leader?
				if (NS:IsGroupLeader() ~= true) then
					-- community member?
					if (message:find("YES")) then
						-- enable community party leader
						NS.charDB.profile.communityPartyLeader = true
					end
				end
			-- ready check?
			elseif (message:find("READY_CHECK")) then
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
					-- send back community flare version
					local message = strformat("READY_CHECK:%s:%s", NS.CommFlare.Version, NS.CommFlare.Build)
					NS.CommFlare:SendCommMessage(ADDON_NAME, message, "PARTY")
				end
			-- request party lead?
			elseif (message:find("REQUEST_PARTY_LEAD")) then
				-- are you group leader?
				if (NS:IsGroupLeader() == true) then
					-- always use full names
					player = NS:GetFullName(player)
					sender = NS:GetFullName(sender)
					local member1 = NS:Get_Community_Member(player)
					local member2 = NS:Get_Community_Member(sender)

					-- player not found?
					if (not member1) then
						-- force max priority
						member1 = { ["priority"] = NS.CommFlare.CF.MaxPriority }
					-- no priority?
					elseif (not member1.priority) then
						-- force max priority
						member1.priority = NS.CommFlare.CF.MaxPriority
					end

					-- sender not found?
					if (not member2) then
						-- force max priority
						member2 = { ["priority"] = NS.CommFlare.CF.MaxPriority }
					-- no priority?
					elseif (not member2.priority) then
						-- force max priority
						member2.priority = NS.CommFlare.CF.MaxPriority
					end

					-- priority in check?
					if (member1 and member1.priority and member2 and member2.priority) then
						-- sender has equal or better priority?
						if (member1.priority >= member2.priority) then
							-- process pass leadership
							NS:Process_Pass_Leadership(sender)
						end
					end
				end
			end
		end
	end
end

-- register addon communication
NS.CommFlare:RegisterComm(ADDON_NAME, "Community_Flare_OnCommReceived")

-- process slash command
function NS.CommFlare:Community_Flare_Slash_Command(input)
	-- force input to lowercase
	local lower = strlower(input)
	if (lower == "debug") then
		-- debug mode enabled?
		if (NS.charDB.profile.debugMode == true) then
			-- expose local tables for debug purposes
			CommFlare_CF = NS.CommFlare.CF
			CommFlare_LocalQueues = NS.CommFlare.CF.LocalQueues
			CommFlare_SocialQueues = NS.CommFlare.CF.SocialQueues
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
	elseif (lower == "inactive") then
		-- check for inactive players
		print(strformat(L["%s: Checking for inactive players."], NS.CommFlare.Title))

		-- in battleground?
		local timer = 0.0
		if (NS:IsInBattleground() == true) then
			-- battlefield score needs updating?
			if (PVPMatchScoreboard.selectedTab ~= 1) then
				-- request battlefield score
				SetBattlefieldScoreFaction(-1)
				RequestBattlefieldScoreData()

				-- delay 0.5 seconds
				timer = 0.5
			end
		end

		-- start processing
		TimerAfter(timer, function()
			-- check for inactive players
			NS:Check_For_Inactive_Players()
		end)
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
	elseif (lower == "options") then
		-- open options to Community Flare
		Settings_OpenToCategory(NS.CommFlare.Title)
		Settings_OpenToCategory(NS.CommFlare.Title) -- open options again (wow bug workaround)
	elseif (lower == "pois") then
		-- list all POI's
		NS:List_POIs()
	elseif (lower == "popped") then
		-- get popped text
		local popped = NS:Get_Popped_Text()
		if (popped == "None") then
			-- no subscribed clubs found
			print(strformat(L["%s: No Groups have popped recently."], NS.CommFlare.Title))
		else
			-- split groups
			local groups = strsplit(";", popped)
			for k,v in pairs(groups) do
				-- display group
				local mapName, partyGUID, leaderGUID, leaderName, leaderRealm, count = strsplit(",", v)
				print(strformat("%s: %s-%s (%s) [%s]", L["POPPED"], leaderName, leaderRealm, count, mapName))
			end
		end
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
	elseif (lower == "reset") then
		-- reset members database
		NS.globalDB.global.members = {}
		print(L["Cleared members database!"])
	elseif (lower == "usage") then
		-- display usages
		print(strformat("%s: %s = %d", NS.CommFlare.Title, L["CPU Usage"], GetAddOnCPUUsage(ADDON_NAME)))
		print(strformat("%s: %s = %d", NS.CommFlare.Title, L["Memory Usage"], GetAddOnMemoryUsage(ADDON_NAME)))
	elseif (lower == "vignettes") then
		-- list all Vignette's
		NS:List_Vignettes()
	else
		-- split words
		local first, second, third = strsplit(" ", input)
		first = strlower(first)
		if (first == "find") then
			-- has third?
			local clubId = NS.charDB.profile.communityMain
			if (third and (third ~= "")) then
				-- process all
				third = strlower(third)
				for k,v in pairs(NS.globalDB.global.clubs) do
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
				print(L["Checking for older members"])
				NS:Find_ExCommunity_Members(clubId)
			-- inactive?
			elseif (second == "inactive") then
				-- find inactive members
				NS:Find_Community_Members(second, clubId)
			-- inactivity?
			elseif (second == "inactivity") then
				-- find inactive members
				NS:Find_Community_Members(second, clubId)
			-- noplay?
			elseif (second == "nocompleted") then
				-- find nocomplete members
				NS:Find_Community_Members(second, clubId)
			-- nogroup?
			elseif (second == "nogrouped") then
				-- find nogroup members
				NS:Find_Community_Members(second, clubId)
			end
		else
			-- in battleground?
			local timer = 0.0
			if (NS:IsInBattleground() == true) then
				-- battlefield score needs updating?
				if (PVPMatchScoreboard.selectedTab ~= 1) then
					-- update battlefield score
					SetBattlefieldScoreFaction(-1)

					-- delay 0.5 seconds
					timer = 0.5
				end
			end

			-- start processing
			TimerAfter(timer, function()
				-- display full battleground setup
				NS:Update_Battleground_Stuff(true, true)
			end)
		end
	end
end

-- register slash command
NS.CommFlare:RegisterChatCommand("comf", "Community_Flare_Slash_Command")
