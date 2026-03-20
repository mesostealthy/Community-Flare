-- initialize
local LibStub = LibStub
local ADDON_NAME, NS = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
if (not L or not NS.CommFlare) then return end

-- localize stuff
local _G                                          = _G
local GetLFGDungeonInfo                           = _G.GetLFGDungeonInfo
local GetLFGInfoServer                            = _G.GetLFGInfoServer
local GetLFGMode                                  = _G.GetLFGMode
local IsInGroup                                   = _G.IsInGroup
local IsInRaid                                    = _G.IsInRaid
local RaidWarningFrame_OnEvent                    = _G.RaidWarningFrame_OnEvent
local PvPGetActiveBrawlInfo                       = _G.C_PvP.GetActiveBrawlInfo
local PvPGetAvailableBrawlInfo                    = _G.C_PvP.GetAvailableBrawlInfo
local PvPIsInBrawl                                = _G.C_PvP.IsInBrawl
local TimerAfter                                  = _G.C_Timer.After
local time                                        = _G.time
local strformat                                   = _G.string.format

-- should report queue?
function NS:Should_Report_Queue(category)
	-- community reporter enabled?
	if (NS.charDB.profile.communityReporter == true) then
		-- dungeon?
		if (category and (category == LE_LFG_CATEGORY_LFD)) then
			-- enabled?
			if (NS.db.global.communityReportDungeons == true) then
				-- yes
				return true
			end
		else
			-- yes
			return true
		end
	end

	-- no
	return false
end

-- update queue status
function NS:Update_Queue_Status(typeCategory)
	-- get proper index
	local index = nil
	if (typeCategory == LE_LFG_CATEGORY_LFD) then
		-- dungeon
		index = "Dungeon"
	elseif (typeCategory == LE_LFG_CATEGORY_BATTLEFIELD) then
		-- brawl
		index = "Brawl"
	end

	-- no index?
	if (not index) then
		-- finished
		return
	end

	-- queued for dungeon?
	local inParty, joined, queued, _, _, _, slotCount, category, leader, tank, healer, dps = GetLFGInfoServer(typeCategory)
	if (category == typeCategory) then
		-- found dungeon queue?
		local instanceName = nil
		local mode, submode = GetLFGMode(typeCategory)
		if (mode) then
			-- process all
			local entryIDs = NS:GetAllEntriesForCategory(typeCategory)
			for _, entryID in ipairs(entryIDs) do
				-- not hidden?
				if not NS:HideNameFromUI(entryID) then
					-- get lfg dungeon info
					instanceName = GetLFGDungeonInfo(entryID)
				end
			end
		end

		-- instance name not found yet?
		if (not instanceName) then
			-- get brawl info
			local brawlInfo
			if (PvPIsInBrawl() == true) then
				brawlInfo = PvPGetActiveBrawlInfo()
			else
				brawlInfo = PvPGetAvailableBrawlInfo()
			end

			-- use brawl name
			instanceName = brawlInfo.name
		end

		-- instance name found now?
		if (instanceName) then
			-- joined?
			if (joined == true) then
				-- queued?
				if (queued == true) then
					-- just entering queue?
					if (not NS.CommFlare.CF.LocalQueues[index] or not NS.CommFlare.CF.LocalQueues[index].name or (NS.CommFlare.CF.LocalQueues[index].name == "")) then
						-- add to queues
						local timestamp = time()
						NS.CommFlare.CF.LocalQueues[index] = {
							["name"] = instanceName,
							["category"] = category,
							["created"] = timestamp,
							["entered"] = false,
							["joined"] = true,
							["popped"] = 0,
							["status"] = "queued",
							["suspended"] = false,
							["type"] = index,
						}

						-- update local group
						NS:Update_Group("local")

						-- brawl?
						if (index == "Brawl") then
							-- warn when honor capped?
							if (NS.db.global.warningHonorCapped == true) then
								-- get honor info
								local info = NS:GetCurrencyInfo(1792)
								if (info and info.quantity and info.maxQuantity) then
									-- close to capping?
									local diff = info.maxQuantity - info.quantity
									if (diff) then
										-- capped?
										if (diff == 0) then
											-- issue local raid warning (with raid warning audio sound)
											RaidWarningFrame_OnEvent(RaidBossEmoteFrame, "CHAT_MSG_RAID_WARNING", L["WARNING: Honor capped! Please spend some!"])
										-- close to capping?
										elseif (diff < 2500) then
											-- issue local raid warning (with raid warning audio sound)
											RaidWarningFrame_OnEvent(RaidBossEmoteFrame, "CHAT_MSG_RAID_WARNING", L["WARNING: Close to Honor capped! Please spend some!"])
										end
									end
								end
							end
						end

						-- should report queue?
						if (NS:Should_Report_Queue(category)) then
							-- are you group leader?
							if (NS:IsGroupLeader() == true) then
								-- delay some
								TimerAfter(0.5, function()
									-- report joined queue with estimated time
									NS.CommFlare.CF.EstimatedWaitTime = 0
									NS:Report_Joined_With_Estimated_Time(index)
								end)
							end
						end
					end
				-- queue exists?
				elseif (NS.CommFlare.CF.LocalQueues[index]) then
					-- popped?
					if ((NS.CommFlare.CF.LocalQueues[index].status == "popped") and NS.CommFlare.CF.LocalQueues[index].popped and (NS.CommFlare.CF.LocalQueues[index].popped == 0)) then
						-- update popped time
						NS.CommFlare.CF.LocalQueues[index].popped = time()
						NS.CommFlare.CF.SocialQueues["local"].name = instanceName
						NS.CommFlare.CF.SocialQueues["local"].popped = NS.CommFlare.CF.LocalQueues[index].popped

						-- update group / process popped
						NS:Update_Group("local")
						NS:Process_Popped("local")

						-- should report queue?
						if (NS:Should_Report_Queue(category)) then
							-- are you group leader?
							if (NS:IsGroupLeader() == true) then
								-- finalize text
								local text = nil
								local count = NS:GetGroupCountText()
								local level = NS:UnitLevel("player")
								if (level < GetMaxLevelForLatestExpansion()) then
									-- add with level
									text = strformat("[%s %d] %s %s %s!", L["Level"], level, count, L["Queue Popped for"], instanceName)
								else
									-- add without level
									text = strformat("%s %s %s!", count, L["Queue Popped for"], instanceName)
								end

								-- add tanks / heals / dps counts
								if ((NS.CommFlare.CF.LocalData.NumTanks > 0) or (NS.CommFlare.CF.LocalData.NumHealers > 0) or (NS.CommFlare.CF.LocalData.NumDPS > 0)) then
									-- add counts
									text = strformat(L["%s [%d Tanks, %d Healers, %d DPS]"], text, NS.CommFlare.CF.LocalData.NumTanks, NS.CommFlare.CF.LocalData.NumHealers, NS.CommFlare.CF.LocalData.NumDPS)
								end

								-- send to community
								NS:PopupBox("CommunityFlare_Send_Community_Dialog", text)
							end
						end
					end
				end
			else
				-- clear local queue
				NS.CommFlare.CF.LocalQueues[index] = nil
			end
		end
	else
		-- queue created?
		if (NS.CommFlare.CF.LocalQueues[index] and NS.CommFlare.CF.LocalQueues[index].created and (NS.CommFlare.CF.LocalQueues[index].created > 0)) then
			-- has name?
			if (NS.CommFlare.CF.LocalQueues[index].name and (NS.CommFlare.CF.LocalQueues[index].name ~= "")) then
				-- dropped?
				local category = NS.CommFlare.CF.LocalQueues[index].category
				local instanceName = NS.CommFlare.CF.LocalQueues[index].name
				if (NS.CommFlare.CF.LocalQueues[index].status == "queued") then
					-- should report queue?
					if (NS:Should_Report_Queue(category)) then
						-- are you group leader?
						if (NS:IsGroupLeader() == true) then
							-- player is horde?
							local faction = L["N/A"]
							if (NS.faction == Enum.PvPFaction.Horde) then
								-- horde
								faction = FACTION_HORDE
							else
								-- alliance
								faction = FACTION_ALLIANCE
							end

							-- dropped
							local text = nil
							local count = NS:GetGroupCountText()
							local level = NS:UnitLevel("player")
							if (level < GetMaxLevelForLatestExpansion()) then
								-- add with level
								text = strformat("[%s %d] %s %s %s %s!", L["Level"], level, count, faction, L["Dropped Queue for"], instanceName)
							else
								-- add without level
								text = strformat("%s %s %s %s!", count, faction, L["Dropped Queue for"], instanceName)
							end

							-- send to community
							NS:PopupBox("CommunityFlare_Send_Community_Dialog", text)
						end
					end
				-- failed?
				elseif (NS.CommFlare.CF.LocalQueues[index].status == "failed") then
					-- should report queue?
					if (NS:Should_Report_Queue(category)) then
						-- are you group leader?
						if (NS:IsGroupLeader() == true) then
							-- player is horde?
							local faction = L["N/A"]
							if (NS.faction == Enum.PvPFaction.Horde) then
								-- horde
								faction = FACTION_HORDE
							else
								-- alliance
								faction = FACTION_ALLIANCE
							end

							-- missed
							local text = nil
							local level = NS:UnitLevel("player")
							if (level < GetMaxLevelForLatestExpansion()) then
								-- add with level
								text = strformat("[%s %d] %s %s %s!", L["Level"], level, faction, L["Missed Queue for Popped"], instanceName)
							else
								-- add without level
								text = strformat("%s %s %s!", faction, L["Missed Queue for Popped"], instanceName)
							end

							-- send to community
							NS:PopupBox("CommunityFlare_Send_Community_Dialog", text)
						end
					end
				-- entered?
				elseif (NS.CommFlare.CF.LocalQueues[index].status == "entered") then
					-- are you in a party / raid?
					local text = strformat(L["Entered Queue For Popped %s!"], instanceName)
					if (IsInGroup()) then
						-- are you in a raid?
						if (IsInRaid()) then
							-- send raid message
							NS:SendMessage("RAID", text)
						else
							-- send party message
							NS:SendMessage("PARTY", text)
						end
					end

					-- save stuff
					NS.CommFlare.CF.LeftTime = 0
					NS.CommFlare.CF.Expiration = 0
					NS.CommFlare.CF.EnteredTime = time()
				-- rejected?
				elseif (NS.CommFlare.CF.LocalQueues[index].status == "rejected") then
					-- should report queue?
					if (NS:Should_Report_Queue(category)) then
						-- player is horde?
						local faction = L["N/A"]
						if (NS.faction == Enum.PvPFaction.Horde) then
							-- horde
							faction = FACTION_HORDE
						else
							-- alliance
							faction = FACTION_ALLIANCE
						end

						-- left queue
						local text = nil
						local level = NS:UnitLevel("player")
						if (level < GetMaxLevelForLatestExpansion()) then
							-- add with level
							text = strformat("[%s %d] %s %s %s!", L["Level"], level, faction, L["Left Queue for Popped"], instanceName)
						else
							-- add without level
							text = strformat("%s %s %s!", faction, L["Left Queue for Popped"], instanceName)
						end

						-- are you in a party / raid?
						if (IsInGroup()) then
							-- are you in a raid?
							if (IsInRaid()) then
								-- send raid message
								NS:SendMessage("RAID", text)
							else
								-- send party message
								NS:SendMessage("PARTY", text)
							end
						end

						-- send to community
						NS:PopupBox("CommunityFlare_Send_Community_Dialog", text)
					end

					-- has social queue?
					if (NS.CommFlare.CF.SocialQueues["local"].queues and NS.CommFlare.CF.SocialQueues["local"].queues[index]) then
						-- clear queue
						NS.CommFlare.CF.SocialQueues["local"].queues[index] = nil
					end
				end
			end
		end

		-- clear local queue
		NS.CommFlare.CF.LocalQueues[index] = nil
	end
end

-- update lfg status
function NS:Update_LFG_Status()
	-- update brawl / dungeon queues
	NS:Update_Queue_Status(LE_LFG_CATEGORY_BATTLEFIELD)
	NS:Update_Queue_Status(LE_LFG_CATEGORY_LFD)
end
