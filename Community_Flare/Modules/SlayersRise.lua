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
local ipairs                                      = _G.ipairs
local issecretvalue                               = _G.issecretvalue
local pairs                                       = _G.pairs
local time                                        = _G.time
local tonumber                                    = _G.tonumber
local wipe                                        = _G.wipe
local strformat                                   = _G.string.format
local strlower                                    = _G.string.lower

-- constant values
NS.SlayerRiseScoreBar = 7002

-- local variables
NS.LeftFrame = nil
NS.RightFrame = nil

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

-- create widget frames
function NS:SlayersRise_Create_WidgetFrames()
	-- create left frame
	if (NS.faction ~= 0) then return end
	NS.LeftFrame = NS.LeftFrame or UIParent:CreateFontString(nil, "ARTWORK", nil)
	NS.LeftFrame:SetFont(NS.Libs.LibSharedMedia:Fetch("font", "Roboto Condensed BoldItalic"), 12, "OUTLINE")
	NS.LeftFrame:SetSize(150, 20)
	NS.LeftFrame:SetTextColor(1, 1, 1, 1)
	NS.LeftFrame:SetJustifyH("CENTER")
	NS.LeftFrame:Hide()

	-- create right frame
	NS.RightFrame = NS.RightFrame or UIParent:CreateFontString(nil, "ARTWORK", nil)
	NS.RightFrame:SetFont(NS.Libs.LibSharedMedia:Fetch("font", "Roboto Condensed BoldItalic"), 12, "OUTLINE")
	NS.RightFrame:SetSize(150, 20)
	NS.RightFrame:SetTextColor(1, 1, 1, 1)
	NS.RightFrame:SetJustifyH("CENTER")
	NS.RightFrame:Hide()

	-- has widget frames?
	if (UIWidgetTopCenterContainerFrame and UIWidgetTopCenterContainerFrame.widgetFrames) then
		-- has score widget?
		if (UIWidgetTopCenterContainerFrame.widgetFrames[NS.SlayerRiseScoreBar]) then
			-- has LeftBar / RightBar?
			local widgetFrame = UIWidgetTopCenterContainerFrame.widgetFrames[NS.SlayerRiseScoreBar]
			if (widgetFrame.LeftBar and widgetFrame.RightBar) then
				-- update left bar
				NS.LeftFrame:ClearAllPoints()
				NS.LeftFrame:SetPoint("CENTER", widgetFrame.LeftBar, "CENTER", 0, -22)
				NS.LeftFrame:SetText("Bleeding: 0")
				NS.LeftFrame:Show()

				-- update right bar
				NS.RightFrame:ClearAllPoints()
				NS.RightFrame:SetPoint("CENTER", widgetFrame.RightBar, "CENTER", 0, -22)
				NS.RightFrame:SetText("Bleeding: 0")
				NS.RightFrame:Show()
			end
		end
	end
end

-- hide widget frames
function NS:SlayersRise_Hide_WidgetFrames()
	-- hide frames
	if (NS.faction ~= 0) then return end
	if (NS.LeftFrame and NS.RightFrame) then
		-- hide
		NS.LeftFrame:Hide()
		NS.RightFrame:Hide()
	end
end

-- update widget frames
function NS:SlayersRise_Update_WidgetFrames()
	-- sanity check
	if (NS.faction ~= 0) then return end
	if (NS.LeftFrame and NS.RightFrame) then
		-- update
		NS.LeftFrame:SetText(strformat("Bleeding: %d", NS.CommFlare.CF.SLR.AlliancePointsBleed))
		NS.RightFrame:SetText(strformat("Bleeding: %d", NS.CommFlare.CF.SLR.HordePointsBleed))
	else
		-- create widget frames
		NS:SlayersRise_Create_WidgetFrames()
	end
end

-- initialize
function NS:SlayersRise_Initialize()
	-- reset stuff
	if (NS.faction ~= 0) then return end
	NS.CommFlare.CF.SLR.PrevLeftScore = -1
	NS.CommFlare.CF.SLR.PrevRightScore = -1
	NS.CommFlare.CF.SLR.HordePointsBleed = 0
	NS.CommFlare.CF.SLR.AlliancePointsBleed = 0
	NS.CommFlare.CF.SLR.PrevHordePointsBleed = 0
	NS.CommFlare.CF.SLR.PrevAlliancePointsBleed = 0
	NS.CommFlare.CF.SLR.ShadowRidgeOutpostDestroyed = false
	NS.CommFlare.CF.SLR.StareaterPavilionDestroyed = false
	NS.CommFlare.CF.SLR.AllianceSparringGrounds = false
	NS.CommFlare.CF.SLR.HordeSparringGrounds = false
	NS.CommFlare.CF.SLR.AllianceTheHusk = false
	NS.CommFlare.CF.SLR.HordeTheHusk = false

	-- get initial scores
	local data = NS:GetDoubleStatusBarWidgetVisualizationInfo(NS.SlayerRiseScoreBar)
	if (data and data.leftBarValue and data.rightBarValue) then
		-- setup previous scores
		NS.CommFlare.CF.SLR.PrevLeftScore = tonumber(data.leftBarValue)
		NS.CommFlare.CF.SLR.PrevRightScore = tonumber(data.rightBarValue)
	end

	-- update widget frames
	NS:SlayersRise_Update_WidgetFrames()
end

-- process slayer's rise messages
function NS:Process_SlayersRise_Messages(text)
	-- secret?
	if (NS.faction ~= 0) then return end
	if (issecretvalue(text)) then
		-- finished
		return
	end

	-- assaulted shadowridge outpost?
	local path = {136441}
	local lower = strlower(text)
	if (lower:find("alliance has taken shenzar refinery")) then
		-- not destroyed?
		if (not NS.CommFlare.CF.SLR.StareaterPavilionDestroyed) then
			-- stop / start bar
			local path = {136441}
			path[2], path[3], path[4], path[5] = NS:GetPOITextureCoords(43)
			NS:Capping_Add_Update_Bar("Overcharged Manacell [A]", 20, path, "colorAlliance")
		end
	elseif (lower:find("assaulted shadowridge outpost")) then
		-- add new capping bar
		path[2], path[3], path[4], path[5] = NS:GetPOITextureCoords(72)
		NS:Capping_Add_New_Bar("Shadowridge Outpost [H]", 60, path, "colorHorde")
	-- assaulted stareater pavilion?
	elseif (lower:find("assaulted stareater pavilion")) then
		-- add new capping bar
		path[2], path[3], path[4], path[5] = NS:GetPOITextureCoords(68)
		NS:Capping_Add_New_Bar("Stareater Pavilion [A]", 60, path, "colorAlliance")
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
		-- destroyed / stop bars
		NS.CommFlare.CF.SLR.ShadowRidgeOutpostDestroyed = true
		NS:Capping_Stop_Bars("Shadowridge Outpost")
	-- destroyed stareater pavilion?
	elseif (lower:find("destroyed stareater pavilion")) then
		-- destroyed / stop bars
		NS.CommFlare.CF.SLR.StareaterPavilionDestroyed = true
		NS:Capping_Stop_Bars("Stareater Pavilion")
	-- horde has taken shenzar refinery?
	elseif (lower:find("horde has taken shenzar refinery")) then
		-- not destroyed?
		if (not NS.CommFlare.CF.SLR.ShadowRidgeOutpostDestroyed) then
			-- stop / start bar
			local path = {136441}
			path[2], path[3], path[4], path[5] = NS:GetPOITextureCoords(44)
			NS:Capping_Add_Update_Bar("Overcharged Manacell [H]", 20, path, "colorHorde")
		end
	end
end

-- process alterac valley pois
function NS:Process_SlayersRise_POIs()
	-- get area poi's for map
	if (NS.faction ~= 0) then return end
	local list = NS:GetAreaPOIForMap(NS.CommFlare.CF.MapID)
	if (list and (#list > 0)) then
		-- process all
		NS.CommFlare.CF.SLR.HordePointsBleed = 0
		NS.CommFlare.CF.SLR.AlliancePointsBleed = 0
		for _,id in ipairs(list) do
			-- get area poi info
			local info = NS:GetAreaPOIInfo(NS.CommFlare.CF.MapID, id)
			if (info) then
				-- bastion of valor?
				if (info.areaPoiID == 8378) then
					-- horde controlled?
					if (info.atlasName == "capPts-bastion-horde") then
						-- 2 ALLIANCE points bleed
						NS.CommFlare.CF.SLR.AlliancePointsBleed = NS.CommFlare.CF.SLR.AlliancePointsBleed + 2
					end
				-- bastion of might?
				elseif (info.areaPoiID == 8379) then
					-- alliance controlled?
					if (info.atlasName == "capPTs-bastion-alliance") then
						-- 2 HORDE points bleed
						NS.CommFlare.CF.SLR.HordePointsBleed = NS.CommFlare.CF.SLR.HordePointsBleed + 2
					end
				-- the husk?
				elseif (info.areaPoiID == 8380) then
					-- alliance controlled?
					if (info.atlasName == "capPTs-stadium-alliance") then
						-- 1 HORDE point bleed
						NS.CommFlare.CF.SLR.HordePointsBleed = NS.CommFlare.CF.SLR.HordePointsBleed + 1
						NS.CommFlare.CF.SLR.AllianceTheHusk = true
					-- horde controlled?
					elseif (info.atlasName == "capPts-stadium-horde") then
						-- 1 ALLIANCE point bleed
						NS.CommFlare.CF.SLR.AlliancePointsBleed = NS.CommFlare.CF.SLR.AlliancePointsBleed + 1
						NS.CommFlare.CF.SLR.HordeTheHusk = true
					end
				-- sparring grounds?
				elseif (info.areaPoiID == 8381) then
					-- alliance controlled?
					if (info.atlasName == "capPTs-stadium-alliance") then
						-- 1 HORDE point bleed
						NS.CommFlare.CF.SLR.HordePointsBleed = NS.CommFlare.CF.SLR.HordePointsBleed + 1
						NS.CommFlare.CF.SLR.AllianceSparringGrounds = true
					-- horde controlled?
					elseif (info.atlasName == "capPts-stadium-horde") then
						-- 1 ALLIANCE point bleed
						NS.CommFlare.CF.SLR.AlliancePointsBleed = NS.CommFlare.CF.SLR.AlliancePointsBleed + 1
						NS.CommFlare.CF.SLR.HordeSparringGrounds = true
					end
				-- shenzar refinery?
				elseif (info.areaPoiID == 8382) then
					-- alliance controlled?
					if (info.atlasName == "capPTs-refinery-alliance") then
						-- 1 HORDE point bleed
						NS.CommFlare.CF.SLR.HordePointsBleed = NS.CommFlare.CF.SLR.HordePointsBleed + 1
					-- horde controlled?
					elseif (info.atlasName == "capPts-refinery-horde") then
						-- 1 ALLIANCE point bleed
						NS.CommFlare.CF.SLR.AlliancePointsBleed = NS.CommFlare.CF.SLR.AlliancePointsBleed + 1
					end
				-- stareater pavilion?
				elseif (info.areaPoiID == 8620) then
					-- destroyed?
					if (info.description == "Destroyed") then
						-- destroyed
						NS.CommFlare.CF.SLR.StareaterPavilionDestroyed = true
					end
				-- shadowridge outpost?
				elseif (info.areaPoiID == 8621) then
					-- destroyed?
					if (info.description == "Destroyed") then
						-- destroyed
						NS.CommFlare.CF.SLR.ShadowRidgeOutpostDestroyed = true
					end
				-- gates of might?
				elseif (info.areaPoiID == 8645) then
					-- alliance controlled?
					if (info.textureIndex == 11) then
						-- 1 HORDE point bleed
						NS.CommFlare.CF.SLR.HordePointsBleed = NS.CommFlare.CF.SLR.HordePointsBleed + 1
					end
				-- gates of valor?
				elseif (info.areaPoiID == 8646) then
					-- horde controlled?
					if (info.textureIndex == 10) then
						-- 1 ALLIANCE point bleed
						NS.CommFlare.CF.SLR.AlliancePointsBleed = NS.CommFlare.CF.SLR.AlliancePointsBleed + 1
					end
				end
			end
		end

		-- update previous
		NS.CommFlare.CF.SLR.PrevHordePointsBleed = NS.CommFlare.CF.SLR.HordePointsBleed
		NS.CommFlare.CF.SLR.PrevAlliancePointsBleed = NS.CommFlare.CF.SLR.AlliancePointsBleed

		-- update widget frames
		NS:SlayersRise_Update_WidgetFrames()
	end
end

-- process slayer's rise vignettes
function NS:Process_SlayersRise_Vignettes()
	-- found vignettes?
	if (NS.faction ~= 0) then return end
	local ids = VignetteInfoGetVignettes()
	if (ids and (#ids > 0)) then
		-- check for additions
		local list = {}
		for _,guid in pairs(ids) do
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
		for id,info in pairs(NS.SlayersRiseTrackedVignettes) do
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

-- process slayer's rise widget
function NS:Process_SlayersRise_Widget(widgetInfo)
	-- score remaining?
	if (NS.faction ~= 0) then return end
	if (widgetInfo.widgetID == NS.SlayerRiseScoreBar) then
		-- get double status bar info
		local data = NS:GetDoubleStatusBarWidgetVisualizationInfo(NS.SlayerRiseScoreBar)
		if (data and data.leftBarValue and data.rightBarValue) then
			-- update
			NS.CommFlare.CF.SLR.PrevLeftScore = tonumber(data.leftBarValue)
			NS.CommFlare.CF.SLR.PrevRightScore = tonumber(data.rightBarValue)
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
