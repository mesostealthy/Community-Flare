-- initialize
local LibStub = LibStub
local ADDON_NAME, NS = ...
if (not NS.Loaded or not NS.Loaded["TomTom"]) then return end
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
if (not L or not NS.CommFlare) then return end

-- localize stuff
local _G                                          = _G
local CopyTable                                   = _G.CopyTable
local RaidWarningFrame_OnEvent                    = _G.RaidWarningFrame_OnEvent
local VignetteInfoGetVignettes                    = _G.C_VignetteInfo.GetVignettes
local issecretvalue                               = _G.issecretvalue
local pairs                                       = _G.pairs
local time                                        = _G.time
local wipe                                        = _G.wipe
local strformat                                   = _G.string.format
local strlower                                    = _G.string.lower

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

-- process slayer's rise messages
function NS:Process_SlayersRise_Messages(text)
	-- secret?
	if (issecretvalue(text)) then
		-- finished
		return
	end

	-- assaulted shadowridge outpost?
	local path = {136441}
	local lower = strlower(text)
	if (lower:find("assaulted shadowridge outpost")) then
		-- add new capping bar
		path[2], path[3], path[4], path[5] = NS:GetPOITextureCoords(72)
		NS:Capping_Add_New_Bar("Shadowridge Outpost [H]", 60, path, "colorHorde") -- name does not match AreaPOI on purpose!
	-- assaulted stareater pavilion?
	elseif (lower:find("assaulted stareater pavilion")) then
		-- add new capping bar
		path[2], path[3], path[4], path[5] = NS:GetPOITextureCoords(68)
		NS:Capping_Add_New_Bar("Stareater Pavilion [A]", 60, path, "colorAlliance") -- name does not match AreaPOI on purpose!
	-- defended shadowridge outpost?
	elseif (lower:find("defended shadowridge outpost")) then
		-- stop bars
		NS:Capping_Stop_Bars("Shadowridge Outpost")
	-- defended stareater pavilion?
	elseif (lower:find("defended stareater pavilion")) then
		-- stop bars
		NS:Capping_Stop_Bars("Stareater Pavilion")
	-- destroyed shadowridge outpost?
	elseif (lower:find("destroyed shadowridge outpost")) then
		-- stop bars
		NS:Capping_Stop_Bars("Shadowridge Outpost")
	-- destroyed stareater pavilion?
	elseif (lower:find("destroyed stareater pavilion")) then
		-- stop bars
		NS:Capping_Stop_Bars("Stareater Pavilion")
	end
end

-- process slayer's rise vignettes
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
	-- add new overlays
	if (NS.faction ~= 0) then return end
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

-- fully loaded
NS.LoadCount = NS.LoadCount + 1
NS.Loaded["SlayersRise"] = NS.LoadCount
