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
local GetLFGQueuedList                            = _G.GetLFGQueuedList
local IsInGroup                                   = _G.IsInGroup
local IsInRaid                                    = _G.IsInRaid
local RaidWarningFrame_OnEvent                    = _G.RaidWarningFrame_OnEvent
local PvPGetActiveBrawlInfo                       = _G.C_PvP.GetActiveBrawlInfo
local PvPGetAvailableBrawlInfo                    = _G.C_PvP.GetAvailableBrawlInfo
local PvPIsInBrawl                                = _G.C_PvP.IsInBrawl
local TimerAfter                                  = _G.C_Timer.After
local ipairs                                      = _G.ipairs
local next                                        = _G.next
local pairs                                       = _G.pairs
local time                                        = _G.time
local tonumber                                    = _G.tonumber
local tostring                                    = _G.tostring
local strformat                                   = _G.string.format
local tinsert                                     = _G.table.insert

-- get queue type prefix
function NS:GetQueueTypePrefix(category)
	-- brawl?
	if (category == LE_LFG_CATEGORY_BATTLEFIELD) then
		-- brawl
		return "Brawl"
	-- dungeon?
	elseif (category == LE_LFG_CATEGORY_LFD) then
		-- dungeon
		return "LFD"
	-- raid finder?
	elseif (category == LE_LFG_CATEGORY_RF) then
		-- raid
		return "RF"
	-- flex raid?
	elseif (category == LE_LFG_CATEGORY_FLEXRAID) then
		-- raid
		return "FLEXRAID"
	-- raid?
	elseif (category == LE_LFG_CATEGORY_LFR) then
		-- raid
		return "LFR"
	end

	-- failed
	return nil
end

-- should report queue?
function NS:Should_Report_Queue(category)
	-- community reporter enabled?
	if (NS.charDB.profile.communityReporter == true) then
		-- battlefield?
		if (category and (category == LE_LFG_CATEGORY_BATTLEFIELD)) then
			--  yes
			return true
		-- dungeon?
		elseif (category and (category == LE_LFG_CATEGORY_LFD)) then
			-- enabled?
			if (NS.db.global.communityReportDungeons == true) then
				-- yes
				return true
			end
		-- raid finder?
		elseif (category and (category == LE_LFG_CATEGORY_RF)) then
			-- enabled?
			if (NS.db.global.communityReportRaids == true) then
				-- yes
				return true
			end
		-- flex raid?
		elseif (category and (category == LE_LFG_CATEGORY_FLEXRAID)) then
			-- enabled?
			if (NS.db.global.communityReportRaids == true) then
				-- yes
				return true
			end
		-- raid?
		elseif (category and (category == LE_LFG_CATEGORY_LFR)) then
			-- enabled?
			if (NS.db.global.communityReportRaids == true) then
				-- yes
				return true
			end
		end
	end

	-- no
	return false
end

-- update queue status
function NS:Update_Queue_Status(category, index)
	-- popped?
	if (NS.CommFlare.CF.LocalQueues[index]) then
		-- popped?
		local name = NS.CommFlare.CF.LocalQueues[index].name
		if ((NS.CommFlare.CF.LocalQueues[index].status == "popped") and NS.CommFlare.CF.LocalQueues[index].popped and (NS.CommFlare.CF.LocalQueues[index].popped == 0)) then
			-- update popped time
			NS.CommFlare.CF.LocalQueues[index].popped = time()
			NS.CommFlare.CF.SocialQueues["local"].name = name
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
						text = strformat("[%s %d] %s %s %s!", L["Level"], level, count, L["Queue Popped for"], name)
					else
						-- add without level
						text = strformat("%s %s %s!", count, L["Queue Popped for"], name)
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

			-- finished
			return true
		-- entered?
		elseif (NS.CommFlare.CF.LocalQueues[index].status == "entered") then
			-- are you in a party / raid?
			local text = strformat(L["Entered Queue For Popped %s!"], name)
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

			-- has social queue?
			if (NS.CommFlare.CF.SocialQueues["local"].queues and NS.CommFlare.CF.SocialQueues["local"].queues[index]) then
				-- clear queue
				NS.CommFlare.CF.SocialQueues["local"].queues[index] = nil
			end

			-- clear local queue
			NS.CommFlare.CF.LocalQueues[index] = nil
			return false
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
						text = strformat("[%s %d] %s %s %s!", L["Level"], level, faction, L["Missed Queue for Popped"], name)
					else
						-- add without level
						text = strformat("%s %s %s!", faction, L["Missed Queue for Popped"], name)
					end

					-- send to community
					NS:PopupBox("CommunityFlare_Send_Community_Dialog", text)
				end
			end

			-- has social queue?
			if (NS.CommFlare.CF.SocialQueues["local"].queues and NS.CommFlare.CF.SocialQueues["local"].queues[index]) then
				-- clear queue
				NS.CommFlare.CF.SocialQueues["local"].queues[index] = nil
			end

			-- clear local queue
			NS.CommFlare.CF.LocalQueues[index] = nil
			return false
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
					text = strformat("[%s %d] %s %s %s!", L["Level"], level, faction, L["Left Queue for Popped"], name)
				else
					-- add without level
					text = strformat("%s %s %s!", faction, L["Left Queue for Popped"], name)
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

			-- clear local queue
			NS.CommFlare.CF.LocalQueues[index] = nil
			return false
		-- dropped?
		elseif (NS.CommFlare.CF.LocalQueues[index].status == "dropped") then
			-- dropping all queues?
			if (NS.CommFlare.CF.LeftQueueCount > 0) then
				-- decrease
				NS.CommFlare.CF.LeftQueueCount = NS.CommFlare.CF.LeftQueueCount - 1
				if (NS.CommFlare.CF.LeftQueueCount < 0) then
					-- reset
					NS.CommFlare.CF.LeftQueueCount = 0
				end
			end

			-- last queue dropped?
			if (NS.CommFlare.CF.LeftQueueCount == 0) then
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
							text = strformat("[%s %d] %s %s %s %s!", L["Level"], level, count, faction, L["Dropped Queue for"], name)
						else
							-- add without level
							text = strformat("%s %s %s %s!", count, faction, L["Dropped Queue for"], name)
						end

						-- send to community
						NS:PopupBox("CommunityFlare_Send_Community_Dialog", text)
					end
				end
			end

			-- clear local queue
			NS.CommFlare.CF.LocalQueues[index] = nil
			return false
		end
	end

	-- category queued?
	local inParty, joined, queued, _, _, _, slotCount, _category, leader, tank, healer, dps = GetLFGInfoServer(category)
	if (joined) then
		-- found dungeon queue?
		local instanceName = nil
		local mode, submode = GetLFGMode(category)
		if (mode) then
			-- raid finder?
			local entries = {}
			local entryIDs = NS:GetAllEntriesForCategory(category)
			if (category == LE_LFG_CATEGORY_RF) then
				-- process all
				for _, entryID in ipairs(entryIDs) do
					-- not hidden?
					if not NS:HideNameFromUI(entryID) then
						-- get lfg dungeon info (assume last is current)
						instanceName = GetLFGDungeonInfo(entryID)
					end
				end
			else
				-- process all
				for _, entryID in ipairs(entryIDs) do
					-- not hidden?
					if not NS:HideNameFromUI(entryID) then
						-- get lfg dungeon info
						local name = GetLFGDungeonInfo(entryID)
						if (name and (name ~= "")) then
							-- add to entries
							entries[name] = true
						end
					end
				end

				-- finalize
				local sorted = NS:SortTableKeys(entries)
				for k,v in pairs(sorted) do
					-- first?
					if (not instanceName) then
						-- initialize
						instanceName = v
					else
						-- append
						instanceName = instanceName .. ";" .. v
					end
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

		-- queued?
		if (queued == true) then
			-- just entering queue?
			if (not NS.CommFlare.CF.LocalQueues[index] or not NS.CommFlare.CF.LocalQueues[index].name or (NS.CommFlare.CF.LocalQueues[index].name == "")) then
				-- add to queues
				local timestamp = time()
				local prefix = NS:GetQueueTypePrefix(category)
				NS.CommFlare.CF.LocalQueues[index] = {
					["name"] = instanceName,
					["category"] = category,
					["created"] = timestamp,
					["entered"] = false,
					["joined"] = true,
					["popped"] = 0,
					["status"] = "queued",
					["suspended"] = false,
					["type"] = false,
				}

				-- update local group
				NS:Update_Group("local")

				-- brawl?
				if (prefix == "Brawl") then
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
		end
	end

	-- success
	return true
end

-- update lfg status
function NS:Update_LFG_Status(event)
	-- queue status update?
	if (event == "LFG_QUEUE_STATUS_UPDATE") then
		-- process all
		for category=1, NUM_LE_LFG_CATEGORYS do
			-- get lfg mode
			local mode, submode = GetLFGMode(category)
			if (mode and (mode ~= "suspended")) then
				-- get queue type prefix
				local prefix = NS:GetQueueTypePrefix(category)
				if (prefix) then
					-- process all
					local list = GetLFGQueuedList(category)
					for index,_ in pairs(list) do
						-- update queue status
						NS:Update_Queue_Status(category, index)
					end
				end
			end
		end
	end

	-- dropping all?
	local bDropAll = false
	if (NS.CommFlare.CF.LeftQueueCount > 1) then
		-- dropping all
		bDropAll = true
	end

	-- process all
	for index,v in pairs(NS.CommFlare.CF.LocalQueues) do
		-- queued?
		if (v.status == "queued") then
			-- get lfg mode
			local mode, submode = GetLFGMode(v.category)
			if (not mode or (mode and (mode ~= "suspended"))) then
				-- not still queued?
				local inParty, joined, queued, _, _, _, slotCount, _category, leader, tank, healer, dps = GetLFGInfoServer(v.category, index)
				if (queued == false) then
					-- dungeons?
					if (v.category == LE_LFG_CATEGORY_LFD) then
						-- dropping all?
						if (bDropAll) then
							-- update name
							NS.CommFlare.CF.LocalQueues[index].name = "All Dungeons"
						end
					-- raid finder?
					elseif (v.category == LE_LFG_CATEGORY_RF) then
						-- dropping all?
						if (NS.CommFlare.CF.LeftQueueCount > 0) then
							-- update name
							NS.CommFlare.CF.LocalQueues[index].name = "All Raids"
						end
					end

					-- update queue status
					NS.CommFlare.CF.LocalQueues[index].status = "dropped"
					NS:Update_Queue_Status(v.category, index)
				end
			end
		end
	end
end
