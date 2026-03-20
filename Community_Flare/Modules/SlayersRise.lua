-- initialize
local LibStub = LibStub
local ADDON_NAME, NS = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
if (not L or not NS.CommFlare) then return end

-- localize stuff
local _G                                          = _G
local CopyTable                                   = _G.CopyTable
local InCombatLockdown                            = _G.InCombatLockdown
local RaidWarningFrame_OnEvent                    = _G.RaidWarningFrame_OnEvent
local TimerAfter                                  = _G.C_Timer.After
local VignetteInfoGetVignettes                    = _G.C_VignetteInfo.GetVignettes
local pairs                                       = _G.pairs
local time                                        = _G.time
local wipe                                        = _G.wipe
local strformat                                   = _G.string.format

-- vignettes
NS.SlayersRiseActiveVignettes = {}
NS.SlayersRiseTrackedVignettes = {
	[7528] = {
		["name"] = L["Hatecrusher Ultradon"],
		["AlertDeath"] = true,
	},
	[7529] = {
		["name"] = L["Griefspine Ultradon"],
		["AlertDeath"] = true,
	},
}

-- initialize
function NS:SlayersRise_Initialize()
	-- reset stuff
	NS.SlayersRiseActiveVignettes = {}
	NS.CommFlare.CF.SLR.PrevLeftScore = -1
	NS.CommFlare.CF.SLR.PrevRightScore = -1

	-- get initial scores
	local data = NS:GetDoubleStatusBarWidgetVisualizationInfo(7002)
	if (data and data.leftBarValue and data.rightBarValue) then
		-- setup previous scores
		NS.CommFlare.CF.SLR.PrevLeftScore = tonumber(data.leftBarValue)
		NS.CommFlare.CF.SLR.PrevRightScore = tonumber(data.rightBarValue)
	end
end

-- process slayers rise vignettes
function NS:Process_SlayersRise_Vignettes()
	-- found vignettes?
	if (NS.faction ~= 0) then return end
	local mapID = NS.CommFlare.CF.MapID
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
				wipe(info)

				-- tracked?
				local data = NS.SlayersRiseTrackedVignettes[id]
				if (data) then
					-- not active?
					if (not NS.SlayersRiseActiveVignettes[id]) then
						-- save spawn time
						NS.SlayersRiseActiveVignettes[id] = time()
					end
				end
			end
		end

		-- check for deletions
		for id, info in pairs(NS.SlayersRiseTrackedVignettes) do
			-- active?
			if (NS.SlayersRiseActiveVignettes[id]) then
				-- no longer exists?
				if (not list[id]) then
					-- delete spawn time
					NS.SlayersRiseActiveVignettes[id] = nil

					-- alert death?
					if (info.AlertDeath) then
						-- notifications enabled?
						if (NS.db.global.slrNotifications ~= 1) then
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

-- add REPorter callouts
function NS:REPorter_SlayersRise_Add_Callouts()
	-- in combat lockdown?
	if (NS.faction ~= 0) then return end
	if (InCombatLockdown()) then
		-- update last raid warning
		TimerAfter(5, function()
			-- call again
			NS:REPorter_SlayersRise_Add_Callouts()
		end)

		-- finished
		return
	end

	-- add new overlays
	NS:REPorter_Add_New_Overlay("Bastion of Might")
	NS:REPorter_Add_New_Overlay("Bastion of Valor")
	NS:REPorter_Add_New_Overlay("Gates of Might")
	NS:REPorter_Add_New_Overlay("Gates of Valor")
	NS:REPorter_Add_New_Overlay("Grief Spire")
	NS:REPorter_Add_New_Overlay("Hate Spire")
	NS:REPorter_Add_New_Overlay("Path of Predation")
	NS:REPorter_Add_New_Overlay("Shadowridge Outpost")
	NS:REPorter_Add_New_Overlay("Shenzar Refinery")
	NS:REPorter_Add_New_Overlay("Sparring Grounds")
	NS:REPorter_Add_New_Overlay("Stareater Pavilion")
	NS:REPorter_Add_New_Overlay("The Husk")
end
