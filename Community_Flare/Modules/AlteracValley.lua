-- initialize
local LibStub = LibStub
local ADDON_NAME, NS = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
if (not L or not NS.CommFlare) then return end

-- localize stuff
local _G                                          = _G
local InCombatLockdown                            = _G.InCombatLockdown
local RaidWarningFrame_OnEvent                    = _G.RaidWarningFrame_OnEvent
local TimerAfter                                  = _G.C_Timer.After
local tonumber                                    = _G.tonumber
local strformat                                   = _G.string.format

-- initialize
function NS:AV_Initialize()
	-- reset stuff
	NS.CommFlare.CF.AV.LeftGained = 0
	NS.CommFlare.CF.AV.PrevLeftScore = -1
	NS.CommFlare.CF.AV.PrevRightScore = -1
	NS.CommFlare.CF.AV.RightGained = 0
end

-- process alterac valley widget
function NS:Process_AlteracValley_Widget(info)
	-- get widget data
	if (NS.faction ~= 0) then return end
	local data = NS:GetWidgetData(info)
	if (data) then
		-- score remaining?
		if (data.widgetID == 1684) then
			-- first left score?
			if (NS.CommFlare.CF.AV.PrevLeftScore < 0) then
				-- initialize
				NS.CommFlare.CF.AV.PrevLeftScore = data.leftBarValue
			else
				-- increased?
				if (data.leftBarValue > NS.CommFlare.CF.AV.PrevLeftScore) then
					-- increase
					NS.CommFlare.CF.AV.LeftGained = NS.CommFlare.CF.AV.LeftGained + 1
				end

				-- decreased by 100+?
				local diff = NS.CommFlare.CF.AV.PrevLeftScore - tonumber(data.leftBarValue)
				if (diff >= 100) then
					-- notifications enabled?
					if (NS.db.global.avNotifications ~= 1) then
						-- issue local raid warning (with raid warning audio sound)
						local message = strformat(L["%s has been killed."], L["Captain Balinda Stonehearth"])
						RaidWarningFrame_OnEvent(RaidBossEmoteFrame, "CHAT_MSG_RAID_WARNING", message)
					end
				end

				-- update
				NS.CommFlare.CF.AV.PrevLeftScore = data.leftBarValue
			end

			-- first right score?
			if (NS.CommFlare.CF.AV.PrevRightScore < 0) then
				-- initialize
				NS.CommFlare.CF.AV.PrevRightScore = data.rightBarValue
			else
				-- increased?
				if (data.rightBarValue > NS.CommFlare.CF.AV.PrevRightScore) then
					-- increase
					NS.CommFlare.CF.AV.RightGained = NS.CommFlare.CF.AV.RightGained + 1
				end

				-- decreased by 100+?
				local diff = NS.CommFlare.CF.AV.PrevRightScore - tonumber(data.rightBarValue)
				if (diff >= 100) then
					-- notifications enabled?
					if (NS.db.global.avNotifications ~= 1) then
						-- issue local raid warning (with raid warning audio sound)
						local message = strformat(L["%s has been killed."], L["Captain Galvangar"])
						RaidWarningFrame_OnEvent(RaidBossEmoteFrame, "CHAT_MSG_RAID_WARNING", message)
					end
				end

				-- update
				NS.CommFlare.CF.AV.PrevRightScore = data.rightBarValue
			end
		end
	end
end

-- add REPorter callouts
function NS:REPorter_AlteracValley_Add_Callouts()
	-- in combat lockdown?
	if (InCombatLockdown()) then
		-- update last raid warning
		TimerAfter(5, function()
			-- call again
			NS:REPorter_AlteracValley_Add_Callouts()
		end)

		-- finished
		return
	end

	-- add new overlays
	NS:REPorter_Add_New_Overlay("Dun Baldar North Bunker")
	NS:REPorter_Add_New_Overlay("Dun Baldar South Bunker")
	NS:REPorter_Add_New_Overlay("East Frostwolf Tower")
	NS:REPorter_Add_New_Overlay("Frostwolf Graveyard")
	NS:REPorter_Add_New_Overlay("Frostwolf Relief Hut")
	NS:REPorter_Add_New_Overlay("Iceblood Graveyard")
	NS:REPorter_Add_New_Overlay("Iceblood Tower")
	NS:REPorter_Add_New_Overlay("Icewing Bunker")
	NS:REPorter_Add_New_Overlay("Snowfall Graveyard")
	NS:REPorter_Add_New_Overlay("Stonehearth Bunker")
	NS:REPorter_Add_New_Overlay("Stonehearth Graveyard")
	NS:REPorter_Add_New_Overlay("Stormpike Aid Station")
	NS:REPorter_Add_New_Overlay("Stormpike Graveyard")
	NS:REPorter_Add_New_Overlay("Tower Point")
	NS:REPorter_Add_New_Overlay("West Frostwolf Tower")
end
