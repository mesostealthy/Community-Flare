-- initialize
local LibStub = LibStub
local ADDON_NAME, NS = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
if (not L or not NS.CommFlare) then return end
 
-- localize stuff
local _G                                          = _G
local GetBattlefieldPortExpiration                = _G.GetBattlefieldPortExpiration
local GetBattlefieldStatus                        = _G.GetBattlefieldStatus
local GetBattlefieldWinner                        = _G.GetBattlefieldWinner
local IsInGroup                                   = _G.IsInGroup
local IsInRaid                                    = _G.IsInRaid
local IsShiftKeyDown                              = _G.IsShiftKeyDown
local UnitGUID                                    = _G.UnitGUID
local PvPIsArena                                  = _G.C_PvP.IsArena
local PvPIsInBrawl                                = _G.C_PvP.IsInBrawl
local TimerAfter                                  = _G.C_Timer.After
local hooksecurefunc                              = _G.hooksecurefunc
local ipairs                                      = _G.ipairs
local pairs                                       = _G.pairs
local time                                        = _G.time
local tonumber                                    = _G.tonumber
local strformat                                   = _G.string.format

-- local variables
local hook_AcceptBattlefieldPort_installed = false
local hook_AcceptProposal_installed = false
local hook_LeaveBattlefield_installed = false
local hook_RejectProposal_installed = false
local hook_ClubFinderGuildFinderFrame_CommunityCards_RefreshLayout_installed = false
local hook_ClubFinderGuildFinderFrame_GuildCards_RefreshLayout_installed = false
local hook_HonorFrameQueueButton_OnEnter_installed = false
local hook_PVPMatchResults_OnUpdate_installed = false
local hook_PVPMatchResults_scrollBox_ScrollToBegin_installed = false
local hook_QuickJoinRoleSelectionFrame_OnShow_installed = false
local hook_GameTooltip_OnShow_installed = false

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
					NS.CommFlare.CF.Expiration = GetBattlefieldPortExpiration(index)
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
					end)
				end

				-- are you in a party / raid?
				if (IsInGroup()) then
					-- are you in a raid?
					if (IsInRaid()) then
						-- send raid message
						NS:SendMessage("RAID", text)
					else
						-- send party message
						NS:SendMessage(nil, text)
					end
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
			-- are you in a party / raid?
			if (IsInGroup()) then
				-- are you in a raid?
				local mapName = NS.CommFlare.CF.LocalQueues[index].name
				if (IsInRaid()) then
					-- send raid message
					NS:SendMessage("RAID", strformat(L["Accepted Queue For Popped %s!"], mapName))
				else
					-- send party message
					NS:SendMessage(nil, strformat(L["Accepted Queue For Popped %s!"], mapName))
				end
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
		-- are you in a party / raid?
		if (IsInGroup()) then
			-- match completed?
			local text = ""
			if (GetBattlefieldWinner()) then
				-- finalize text
				text = L["Exited the current match after it concluded."]
			else
				-- finalize text
				text = L["Exited the current match before it concluded."]
			end

			-- are you in a raid?
			if (IsInRaid()) then
				-- send raid message
				NS:SendMessage("RAID", text)
			else
				-- send party message
				NS:SendMessage(nil, text)
			end
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

-- securely hook community cards refresh layout
local function hook_ClubFinderGuildFinderFrame_CommunityCards_RefreshLayout()
	-- has community cards?
	if (ClubFinderCommunityAndGuildFinderFrame and ClubFinderCommunityAndGuildFinderFrame.CommunityCards) then
		-- has ScrollBox
		if (ClubFinderCommunityAndGuildFinderFrame.CommunityCards.ScrollBox) then
			-- process all
			local frames = ClubFinderCommunityAndGuildFinderFrame.CommunityCards.ScrollBox:GetFrames()
			for k,v in ipairs(frames) do
				-- not hooked?
				if (not v.CF_HOOKED) then
					-- hook on enter for tooltip
					v:HookScript("OnEnter", function(self)
						-- has card info and club id?
						if (self.cardInfo and self.cardInfo.clubId) then
							-- display club ID
							local text = strformat("Club ID: |cffffffff%d|r", tonumber(self.cardInfo.clubId))
							GameTooltip:AddLine(text)
							GameTooltip:Show()
						end
					end)

					-- hooked
					v.CF_HOOKED = true
				end
			end
		end
	end
end

-- securely hook guild cards refresh layout
local function hook_ClubFinderGuildFinderFrame_GuildCards_RefreshLayout()
	-- has community cards?
	if (ClubFinderGuildFinderFrame and ClubFinderGuildFinderFrame.GuildCards) then
		-- has Cards
		if (ClubFinderGuildFinderFrame.GuildCards.Cards) then
			-- process all
			local frames = ClubFinderGuildFinderFrame.GuildCards.Cards
			for k,v in ipairs(frames) do
				-- not hooked?
				if (not v.CF_HOOKED) then
					-- hook on enter for tooltip
					v:HookScript("OnEnter", function(self)
						-- has card info and club id?
						if (self.cardInfo and self.cardInfo.clubId) then
							-- display club ID
							local text = strformat("Club ID: |cffffffff%d|r", tonumber(self.cardInfo.clubId))
							GameTooltip:AddLine(text)
							GameTooltip:Show()
						end
					end)

					-- hooked
					v.CF_HOOKED = true
				end
			end
		end
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

-- securely hook PVPMatchResults OnUpdate
local function hook_PVPMatchResults_OnUpdate(self)
	-- PVPMatchResults.scrollBox:ScrollToBegin not hooked?
	if (hook_PVPMatchResults_scrollBox_ScrollToBegin_installed ~= true) then
		-- fix pvp match results scrolling
		if (PVPMatchResults and PVPMatchResults.scrollBox) then
			-- disable ScrollToBegin
			PVPMatchResults.scrollBox.ScrollToBegin = function(self) end
			hook_PVPMatchResults_scrollBox_ScrollToBegin_installed = true
		end
	end

	-- details button exists?
	if (DetailsOpenArenaSummaryButtonOnPVPMatchResults) then
		-- in battleground / brawl?
		local isBrawl = PvPIsInBrawl()
		local isBattleground = NS:IsInBattleground()
		if (isBattleground or isBrawl) then
			-- is shown?
			if (DetailsOpenArenaSummaryButtonOnPVPMatchResults:IsShown()) then
				-- hide
				DetailsOpenArenaSummaryButtonOnPVPMatchResults:Hide()
			end
		end
	end

	-- block game menu hot keys enabled?
	if (NS.charDB.profile.blockGameMenuHotKeys == true) then
		-- available?
		if (PVPMatchResults and PVPMatchResults.content and PVPMatchResults.content.scrollCategories) then
			-- disable tooltips for headers
			local children = {PVPMatchResults.content.scrollCategories:GetChildren()}
			for k,v in pairs(children) do
				if (v.tooltipText) then
					v.tooltipText = nil
				end
				if (v.tooltipTitle) then
					v.tooltipTitle = nil
				end
			end
		end
	end
end

-- securely hook quick join role selection frame on show
local function hook_QuickJoinRoleSelectionFrame_OnShow()
	-- enforce pvp roles
	NS:Enforce_PVP_Roles()

	-- quick join role selection shown?
	if (QuickJoinRoleSelectionFrame:IsShown()) then
		-- click accept button
		QuickJoinRoleSelectionFrame.AcceptButton:Click()
	end
end

-- secure hook game tooltip on show
local function hook_GameTooltip_OnShow()
	-- game tooltips blocked?
	if (NS.db.global.blockGameTooltips == true) then
		-- inside PVP content?
		if (NS.CommFlare.CF.MatchStatus > 0) then
			-- not holding shift?
			if (not IsShiftKeyDown()) then
				-- hide
				GameTooltip:Hide()
			end
		end
	end
end

-- setup hooks
function NS:SetupHooks()
	-- AcceptBattlefieldPort() not hooked?
	if (hook_AcceptBattlefieldPort_installed ~= true) then
		-- hook AcceptBattlefieldPort
		hooksecurefunc("AcceptBattlefieldPort", hook_AcceptBattlefieldPort)
		hook_AcceptBattlefieldPort_installed = true
	end

	-- AcceptProposal() not hooked?
	if (hook_AcceptProposal_installed ~= true) then
		-- hook AcceptProposal
		hooksecurefunc("AcceptProposal", hook_AcceptProposal)
		hook_AcceptProposal_installed = true
	end

	-- LeaveBattlefield() not hooked?
	if (hook_LeaveBattlefield_installed ~= true) then
		-- hook LeaveBattlefield
		hooksecurefunc("LeaveBattlefield", hook_LeaveBattlefield)
		hook_LeaveBattlefield_installed = true
	end

	-- RejectProposal() not hooked?
	if (hook_RejectProposal_installed ~= true) then
		-- hook RejectProposal
		hooksecurefunc("RejectProposal", hook_RejectProposal)
		hook_RejectProposal_installed = true
	end

	-- ClubFinderCommunityAndGuildFinderFrame.CommunityCards:RefreshLayout() not hooked?
	if (hook_ClubFinderGuildFinderFrame_CommunityCards_RefreshLayout_installed ~= true) then
		-- community cards loaded?
		if (ClubFinderCommunityAndGuildFinderFrame and ClubFinderCommunityAndGuildFinderFrame.CommunityCards) then
			-- hook ClubFinderCommunityAndGuildFinderFrame.CommunityCards:RefreshLayout
			hooksecurefunc(ClubFinderCommunityAndGuildFinderFrame.CommunityCards, "RefreshLayout", hook_ClubFinderGuildFinderFrame_CommunityCards_RefreshLayout)
			hook_ClubFinderGuildFinderFrame_CommunityCards_RefreshLayout_installed = true
		end
	end

	-- ClubFinderGuildFinderFrame.GuildCards:RefreshLayout() not hooked?
	if (hook_ClubFinderGuildFinderFrame_GuildCards_RefreshLayout_installed ~= true) then
		-- guild cards loaded?
		if (ClubFinderGuildFinderFrame and ClubFinderGuildFinderFrame.GuildCards) then
			-- hook ClubFinderGuildFinderFrame.GuildCards:RefreshLayout
			hooksecurefunc(ClubFinderGuildFinderFrame.GuildCards, "RefreshLayout", hook_ClubFinderGuildFinderFrame_GuildCards_RefreshLayout)
			hook_ClubFinderGuildFinderFrame_GuildCards_RefreshLayout_installed = true
		end
	end

	-- PVPMatchResults:OnUpdate() not hooked?
	if (hook_PVPMatchResults_OnUpdate_installed ~= true) then
		-- pvp match results loaded?
		if (PVPMatchResults) then
			-- hook PVPMatchResults:OnUpdate
			PVPMatchResults:HookScript("OnUpdate", hook_PVPMatchResults_OnUpdate)
			hook_PVPMatchResults_OnUpdate_installed = true
		end
	end

	-- HonorFrameQueueButton:OnEnter() not hooked?
	if (hook_HonorFrameQueueButton_OnEnter_installed ~= true) then
		-- honor frame loaded?
		if (HonorFrame and HonorFrameQueueButton) then
			-- hook queue button mouse over
			HonorFrameQueueButton:HookScript("OnEnter", hook_HonorFrameQueueButton_OnEnter)
			hook_HonorFrameQueueButton_OnEnter_installed = true
		end
	end

	-- QuickJoinRoleSelectionFrame:OnShow() not hooked?
	if (hook_QuickJoinRoleSelectionFrame_OnShow_installed ~= true) then
		-- quick join role selection frame loaded?
		if (QuickJoinRoleSelectionFrame) then
			-- hook quick join role selection on show
			QuickJoinRoleSelectionFrame:HookScript("OnShow", hook_QuickJoinRoleSelectionFrame_OnShow)
			hook_QuickJoinRoleSelectionFrame_OnShow_installed = true
		end
	end

	-- GameTooltip:OnShow() not hooked?
	if (hook_GameTooltip_OnShow_installed ~= true) then
		--- game tooltip loaded?
		if (GameTooltip) then
			-- hook game tooltip on show
			GameTooltip:HookScript("OnShow", hook_GameTooltip_OnShow)
			hook_GameTooltip_OnShow_installed = true
		end
	end
end
