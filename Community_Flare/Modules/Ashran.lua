-- initialize
local LibStub = LibStub
local ADDON_NAME, NS = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
if (not L or not NS.CommFlare) then return end

-- localize stuff
local _G                                          = _G
local CopyTable                                   = _G.CopyTable
local RaidWarningFrame_OnEvent                    = _G.RaidWarningFrame_OnEvent
local VignetteInfoGetVignettes                    = _G.C_VignetteInfo.GetVignettes
local pairs                                       = _G.pairs
local time                                        = _G.time
local tonumber                                    = _G.tonumber
local strformat                                   = _G.string.format

-- pois
NS.AshranActivePOIs = {}
NS.AshranTrackedPOIs = {
	[6493] = {
		["name"] = L["Ancient Inferno"],
		["AlertDeath"] = true,
		["AlertSpawn"] = true,
		["BarColor"] = "colorHorde",
		["CappingDeath"] = true,
		["IconID"] = 41,
		["RespawnTime"] = 1800,
	},
}

-- vignettes
NS.AshranActiveVignettes = {}
NS.AshranTrackedVignettes = {
	[4915] = {
		["name"] = L["Narduke"],
		["AlertDeath"] = true,
	},
}

-- initialize
function NS:Ashran_Initialize()
	-- reset stuff
	NS.AshranActivePOIs = {}
	NS.AshranActiveVignettes = {}
	NS.CommFlare.CF.ASH.PrevLeftScore = -1
	NS.CommFlare.CF.ASH.PrevRightScore = -1
end

-- process ashran pois
function NS:Process_Ashran_POIs(mapID)
	-- found POIs?
	if (NS.faction ~= 0) then return end
	local ids = NS:GetAreaPOIForMap(mapID)
	if (ids and (#ids > 0)) then
		-- check for additions
		local list = {}
		for _, id in pairs(ids) do
			-- get info
			local info = NS:GetAreaPOIInfo(mapID, id)
			if (info and info.name and info.areaPoiID) then
				-- currently active
				list[id] = CopyTable(info)

				-- tracked?
				local data = NS.AshranTrackedPOIs[id]
				if (data) then
					-- not active?
					if (not NS.AshranActivePOIs[id]) then
						-- save spawn time
						NS.AshranActivePOIs[id] = time()

						-- alert spawn?
						if (data.AlertSpawn) then
							-- notifications enabled?
							if (NS.db.global.ashranNotifications ~= 1) then
								-- issue local raid warning (with raid warning audio sound)
								local message = strformat(L["%s has spawned."], data.name)
								RaidWarningFrame_OnEvent(RaidBossEmoteFrame, "CHAT_MSG_RAID_WARNING", message)
							end
						end
					end
				end
			end
		end

		-- check for deletions
		for id, info in pairs(NS.AshranTrackedPOIs) do
			-- active?
			if (NS.AshranActivePOIs[id]) then
				-- no longer exists?
				if (not list[id]) then
					-- delete spawn time
					NS.AshranActivePOIs[id] = nil

					-- has capping data?
					if (info.CappingDeath and info.IconID and info.RespawnTime) then
						-- add new capping bar
						local path = {136441}
						path[2], path[3], path[4], path[5] = NS:GetPOITextureCoords(info.IconID)
						NS:Capping_Add_New_Bar(info.name, info.RespawnTime, info.BarColor, path)
					end

					-- alert death?
					if (info.AlertDeath) then
						-- notifications enabled?
						if (NS.db.global.ashranNotifications ~= 1) then
							-- issue local raid warning (with raid warning audio sound)
							local message = strformat(L["%s has been killed."], info.name)
							RaidWarningFrame_OnEvent(RaidBossEmoteFrame, "CHAT_MSG_RAID_WARNING", message)
						end
					end
				end
			end
		end
	end
end

-- process ashran vignettes
function NS:Process_Ashran_Vignettes(mapID)
	-- found vignettes?
	if (NS.faction ~= 0) then return end
	local ids = VignetteInfoGetVignettes()
	if (ids and (#ids > 0)) then
		-- check for additions
		local list = {}
		for _, guid in pairs(ids) do
			-- get info
			local info = NS:GetVignetteInfo(guid)
			if (info and info.name and info.vignetteID) then
				-- add to list
				local id = info.vignetteID
				list[id] = CopyTable(info)

				-- tracked?
				local data = NS.AshranTrackedVignettes[id]
				if (data) then
					-- not active?
					if (not NS.AshranActiveVignettes[id]) then
						-- save spawn time
						NS.AshranActiveVignettes[id] = time()
					end
				end
			end
		end

		-- check for deletions
		for id, info in pairs(NS.AshranTrackedVignettes) do
			-- active?
			if (NS.AshranActiveVignettes[id]) then
				-- no longer exists?
				if (not list[id]) then
					-- delete spawn time
					NS.AshranActiveVignettes[id] = nil

					-- has capping data?
					if (info.CappingDeath and info.IconID and info.RespawnTime) then
						-- add new capping bar
						local path = {136441}
						path[2], path[3], path[4], path[5] = NS:GetPOITextureCoords(info.IconID)
						NS:Capping_Add_New_Bar(info.name, info.RespawnTime, info.BarColor, path)
					end

					-- alert death?
					if (info.AlertDeath) then
						-- notifications enabled?
						if (NS.db.global.ashranNotifications ~= 1) then
							-- issue local raid warning (with raid warning audio sound)
							local message = strformat(L["%s has been killed."], info.name)
							RaidWarningFrame_OnEvent(RaidBossEmoteFrame, "CHAT_MSG_RAID_WARNING", message)
						end
					end
				end
			end
		end
	end
end

-- process ashran widget
function NS:Process_Ashran_Widget(info)
	-- get widget data
	if (NS.faction ~= 0) then return end
	local data = NS:GetWidgetData(info)
	if (data) then
		-- score remaining?
		if (data.widgetID == 1997) then
			-- first left score?
			if (NS.CommFlare.CF.ASH.PrevLeftScore < 0) then
				-- initialize
				NS.CommFlare.CF.ASH.PrevLeftScore = tonumber(data.leftBarValue)
			else
				-- decreased by 30+?
				local diff = NS.CommFlare.CF.ASH.PrevLeftScore - tonumber(data.leftBarValue)
				if (diff >= 30) then
					-- add new capping bar
					local path = {136441}
					path[2], path[3], path[4], path[5] = NS:GetPOITextureCoords(157)
					NS:Capping_Add_New_Bar(L["Jeron Emberfall"], 3600, "colorAlliance", path)

					-- notifications enabled?
					if (NS.db.global.ashranNotifications ~= 1) then
						-- issue local raid warning (with raid warning audio sound)
						local message = strformat(L["%s has been killed."], L["Rylai Crestfall"])
						RaidWarningFrame_OnEvent(RaidBossEmoteFrame, "CHAT_MSG_RAID_WARNING", message)
					end

				end

				-- update
				NS.CommFlare.CF.ASH.PrevLeftScore = tonumber(data.leftBarValue)
			end

			-- first right score?
			if (NS.CommFlare.CF.ASH.PrevRightScore < 0) then
				-- initialize
				NS.CommFlare.CF.ASH.PrevRightScore = tonumber(data.rightBarValue)
			else
				-- decreased by 30+?
				local diff = NS.CommFlare.CF.ASH.PrevRightScore - tonumber(data.rightBarValue)
				if (diff >= 30) then
					-- add new capping bar
					local path = {136441}
					path[2], path[3], path[4], path[5] = NS:GetPOITextureCoords(158)
					NS:Capping_Add_New_Bar(L["Jeron Emberfall"], 3600, "colorHorde", path)

					-- notifications enabled?
					if (NS.db.global.ashranNotifications ~= 1) then
						-- issue local raid warning (with raid warning audio sound)
						local message = strformat(L["%s has been killed."], L["Jeron Emberfall"])
						RaidWarningFrame_OnEvent(RaidBossEmoteFrame, "CHAT_MSG_RAID_WARNING", message)
					end
				end

				-- update
				NS.CommFlare.CF.ASH.PrevRightScore = tonumber(data.rightBarValue)
			end
		end
	end
end

-- add REPorter callouts
function NS:REPorter_Ashran_Add_Callouts()
	-- in combat lockdown?
	if (NS.faction ~= 0) then return end
	if (InCombatLockdown()) then
		-- update last raid warning
		TimerAfter(5, function()
			-- call again
			NS:REPorter_Ashran_Add_Callouts()
		end)

		-- finished
		return
	end

	-- add new overlays
	NS:REPorter_Add_New_Overlay("Archmage Overwatch")
	NS:REPorter_Add_New_Overlay("Crossroads")
	NS:REPorter_Add_New_Overlay("Emberfall Tower")
	NS:REPorter_Add_New_Overlay("Tremblade's Vanguard")
	NS:REPorter_Add_New_Overlay("Volrath's Advance")
	NS:REPorter_Add_New_Overlay("Warspear Outpost")
end
