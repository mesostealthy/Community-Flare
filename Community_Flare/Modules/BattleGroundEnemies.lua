-- initialize
local LibStub = LibStub
local ADDON_NAME, NS = ...
if (not NS.Loaded or not NS.Loaded["Timers"]) then return end
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
if (not L or not NS.CommFlare) then return end

-- localize stuff
local _G                                          = _G
local CopyTable                                   = _G.CopyTable
local MergeTable                                  = _G.MergeTable
local UnitClass                                   = _G.UnitClass
local UnitExists                                  = _G.UnitExists
local UnitHonorLevel                              = _G.UnitHonorLevel
local UnitRace                                    = _G.UnitRace
local UnitSex                                     = _G.UnitSex
local GetNamePlateForUnit                         = _G.C_NamePlate.GetNamePlateForUnit
local hooksecurefunc                              = _G.hooksecurefunc
local issecretvalue                               = _G.issecretvalue
local print                                       = _G.print
local strformat                                   = _G.string.format

-- local varaibles
NS.PID_Cache = {}
local hooks_BattleGroundEnemies_installed = false

-- Collapse faction-variant race IDs to a single canonical ID
local RaceCollapseMap = {
	[24] = 25, -- Pandaren (Neutral)
	[26] = 25, -- Pandaren (Horde)
	[70] = 52, -- Dracthyr (Horde)
	[84] = 85, -- Earthen (Horde)
	[91] = 86, -- Harronir (Alt ID)
}

-- PID = Player ID (unique identifier using bit-shifting)
-- Gender:     × 2^32 - positions 33+
-- Race:       × 2^24 - positions 25-32
-- Class:      × 2^16 - positions 17-24
-- HonorLevel: × 2^0  - positions 0-15
-- Returns fullPID, basePID, corePID, classGenderPID, classPID
--   fullPID        = gender + race + class + honor (most specific)
--   basePID        = gender + race + class (honor stripped)
--   corePID        = race + class only (gender stripped)
--   classGenderPID = gender + class (race stripped, for when race is nil/mismatched)
--   classPID       = class only (race+gender stripped, broadest match)
local function EN_CalculatePID(raceID, classID, gender, honorLevel)
	if (not classID) then
		return 0, 0, 0, 0, 0
	end
	local classPID = classID * 65536
	local genderComponent = (gender or 0) * 4294967296
	local classGenderPID = genderComponent + classPID
	if (not raceID) then
		-- Race unavailable (combat secret) -- classGenderPID and classPID are usable
		return 0, 0, 0, classGenderPID, classPID
	end
	local collapsedRaceID = RaceCollapseMap[raceID] or raceID
	if not collapsedRaceID then
		return 0, 0, 0, classGenderPID, classPID
	end
	local corePID = (collapsedRaceID * 16777216) + classPID
	local basePID = genderComponent + corePID
	local honor = (honorLevel and honorLevel > 0) and honorLevel or 0
	return basePID + honor, basePID, corePID, classGenderPID, classPID
end

-- calculate PID from unit
local function EN_UnitPID(unit)
	-- does not exist?
	if (not UnitExists(unit)) then
		return 0, 0, 0, 0, 0
	end
	local _, _, raceID = UnitRace(unit)
	local _, _, classID = UnitClass(unit)
	local gender = UnitSex(unit)
	if (not classID) then
		return 0, 0, 0, 0, 0
	end
	local unitHonor = UnitHonorLevel(unit)
	-- Detect placeholder data: WARRIOR class (1) with no race suggests incomplete API data.
	-- WoW may return classID=1 as default before real data loads. Skip matching to avoid
	-- false positives; retry mechanisms will catch it once proper data is available.
	-- Only check for players (UnitIsPlayer) to avoid false positives from NPCs/objects.
	if ((classID == 1) and (not raceID or raceID == 0)) then
		return 0, 0, 0, 0, 0
	end
	return EN_CalculatePID(raceID, classID, gender, unitHonor)
end

-- find player bar by unit
function NS:BGE_Find_PlayerBar_By_Unit(unitToken)
	-- not installed?
	if (NS.faction ~= 0) then return end
	if (not BattleGroundEnemies or not BattleGroundEnemies.GetPlayerbuttonByUnitID) then
		-- failed
		return nil
	end

	-- return player bar
	return BattleGroundEnemies:GetPlayerbuttonByUnitID(unitToken, "Enemies")
end

-- get unit data
function NS:BGE_GetUnitData(unitToken)
	-- get name plate for unit
	if (NS.faction ~= 0) then return nil end
	local namePlate = GetNamePlateForUnit(unitToken)
	if (not namePlate) then
		-- failed
		return nil
	end

	-- find player bar
	local playerBar = NS:BGE_Find_PlayerBar_By_Unit(unitToken)
	if (not playerBar) then
		-- failed
		return nil
	end

	-- found player stuff?
	local player = playerBar.PlayerDetails and playerBar.PlayerDetails.PlayerName or nil
	if (not player) then
		-- failed
		return nil
	end

	-- cached?
	if (NS.PID_Cache[unitToken]) then
		-- found
		return NS.PID_Cache[unitToken]
	end

	-- calculate unit PID's
	local fullPID, basePID, corePID, classGenderPID, classPID = EN_UnitPID(unitToken)
	if (fullPID and (fullPID > 0)) then
		-- not found yet?
		if (not NS.CommFlare.CF.EnemyPlayerDetails[player]) then
			-- copy table
			NS.CommFlare.CF.EnemyPlayerDetails[player] = CopyTable(playerBar.PlayerDetails)
		else
			-- merge table
			MergeTable(NS.CommFlare.CF.EnemyPlayerDetails[player], playerBar.PlayerDetails)
		end

		-- save PID's
		NS.CommFlare.CF.EnemyPlayerDetails[player].fullPID = fullPID
		NS.CommFlare.CF.EnemyPlayerDetails[player].basePID = basePID
		NS.CommFlare.CF.EnemyPlayerDetails[player].corePID = corePID
		NS.CommFlare.CF.EnemyPlayerDetails[player].classGenderPID = classGenderPID
		NS.CommFlare.CF.EnemyPlayerDetails[player].classPID = classPID

		-- not found yet?
		if (not NS.CommFlare.CF.EnemyPlayerPIDs[fullPID]) then
			-- save player ID
			NS.CommFlare.CF.EnemyPlayerPIDs[fullPID] = player
		end
	end

	-- empty?
	if (fullPID == 0) then
		-- delete
		NS.PID_Cache[unitToken] = nil
	else
		-- save cache
		NS.PID_Cache[unitToken] = fullPID
	end

	-- success
	return fullPID
end

-- post click
local function BattleGroundEnemies_Enemies_PlayerBar_PostClick(frame, button)
	-- not pvp zone?
	if (NS.faction ~= 0) then return end
	if (NS.CommFlare.CF.InstanceType ~= "pvp") then
		-- finished
		return
	end

	-- sanity checks
	if (not frame) then return end
	local playerDetails = frame.PlayerDetails or nil
	local player = playerDetails and playerDetails.PlayerName or nil

	-- not already calculated?
	local unitToken = "target"
	if (not NS.CommFlare.CF.EnemyPlayerDetails[player].fullPID) then
		-- target exists?
		if (UnitExists(unitToken)) then
			-- get details / info
			local localizedRaceName, englishRaceName, raceID = UnitRace(unitToken)
			NS.CommFlare.CF.EnemyPlayerDetails[player].raceID = raceID
			local fullPID, basePID, corePID, classGenderPID, classPID = EN_UnitPID(unitToken)
			NS.CommFlare.CF.EnemyPlayerDetails[player].fullPID = fullPID
			NS.CommFlare.CF.EnemyPlayerDetails[player].basePID = basePID
			NS.CommFlare.CF.EnemyPlayerDetails[player].corePID = corePID
			NS.CommFlare.CF.EnemyPlayerDetails[player].classGenderPID = classGenderPID
			NS.CommFlare.CF.EnemyPlayerDetails[player].classPID = classPID

			-- valid PID?
			if (fullPID) then
				-- already found?
				if (NS.CommFlare.CF.EnemyPlayerPIDs[fullPID]) then
					-- TODO: collision
					print(strformat("TODO: Collision detected for %s (%s) with %s", player, fullPID, NS.CommFlare.CF.EnemyPlayerPIDs[fullPID]))
				else
					-- save player ID
					NS.CommFlare.CF.EnemyPlayerPIDs[fullPID] = player
					playerDetails.fullPID = fullPID
					playerDetails.basePID = basePID
					playerDetails.corePID = corePID
					playerDetails.classGenderPID = classGenderPID
					playerDetails.classPID = classPID
				end
			end
		end
	end

	-- has role?
	if (playerDetails and playerDetails.PlayerRole) then
		-- not secret role?
		if (not issecretvalue(playerDetails.PlayerRole)) then
			-- update role icon
			NS:UpdateRoleIcon(unitToken, nil, playerDetails.PlayerRole)
		end
	end
end

-- process enemies after player source update
function NS:BGE_Enemies_AfterPlayerSourceUpdate()
	-- has enemy players?
	if (NS.faction ~= 0) then return end
	if (BattleGroundEnemies.Enemies.PlayerList and (BattleGroundEnemies.Enemies.NumPlayers > 0)) then
		-- process all
		for i=1, BattleGroundEnemies.Enemies.NumPlayers do
			-- sanity check
			local playerBar = BattleGroundEnemies.Enemies.PlayerList[i]
			if (playerBar) then
				-- sanity check
				local playerDetails = playerBar.PlayerDetails or nil
				local player = playerDetails and playerDetails.PlayerName or nil
				if (not issecretvalue(player)) then
					-- new enemy player?
					if (not NS.CommFlare.CF.EnemyPlayerDetails[player]) then
						-- copy table
						NS.CommFlare.CF.EnemyPlayerDetails[player] = CopyTable(playerDetails)
					else
						-- merge table
						MergeTable(NS.CommFlare.CF.EnemyPlayerDetails[player], playerDetails)
					end

					-- save player details
					local classID = NS:Get_Class(playerDetails.PlayerClass)
					NS.CommFlare.CF.EnemyPlayerDetails[player].classID = classID
					NS.CommFlare.CF.EnemyPlayerDetails[player].bar = playerBar
				end

				-- playerBar:PostClick not hooked?
				if (not playerBar.hooked_CommFlare_PostClick) then
					-- hook playerBar:PostClick
					playerBar.hooked_CommFlare_PostClick = true
					playerBar:HookScript("PostClick", BattleGroundEnemies_Enemies_PlayerBar_PostClick)
				end
			end
		end
	end
end

-- setup hooks
function NS:BattleGroundEnemies_SetupHooks()
	-- BattleGroundEnemies installed?
	if (NS.faction ~= 0) then return end
	if (BattleGroundEnemies and BattleGroundEnemies.Enemies and BattleGroundEnemies.Enemies.PlayerList) then
		-- already installed?
		if (hooks_BattleGroundEnemies_installed) then
			-- finished
			return
		end

		-- hook BattleGroundEnemies.Enemies:AfterPlayerSourceUpdate()
		hooksecurefunc(BattleGroundEnemies.Enemies, "AfterPlayerSourceUpdate", function()
			-- process enemies after player source update
			NS:BGE_Enemies_AfterPlayerSourceUpdate()
		end)

		-- create event handler frame
		local f = CreateFrame("Frame")
		f:RegisterEvent("NAME_PLATE_UNIT_ADDED")
		f:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
		f:RegisterEvent("PLAYER_ENTERING_WORLD")
		f:RegisterEvent("PLAYER_TARGET_CHANGED")
		f:SetScript("OnEvent", function(self, event, ...)
			-- name plate unit added?
			if (NS.faction ~= 0) then return end
			if (event == "NAME_PLATE_UNIT_ADDED") then
				-- get name plate for unit
				local unitToken = ...
				NS:BGE_GetUnitData(unitToken)
			-- name plate unit removed?
			elseif (event == "NAME_PLATE_UNIT_REMOVED") then
				-- cached?
				local unitToken = ...
				if (NS.PID_Cache[unitToken]) then
					-- delete
					NS.PID_Cache[unitToken] = nil
				end
			-- player entering world?
			elseif (event == "PLAYER_ENTERING_WORLD") then
				-- reset
				NS.PID_Cache = {}
			-- player target changed?
			elseif (event == "PLAYER_TARGET_CHANGED") then
				-- get unit data
				NS:BGE_GetUnitData("target")
			end
		end)

		-- installed
		hooks_BattleGroundEnemies_installed = true
	end
end

-- fully loaded
NS.LoadCount = NS.LoadCount + 1
NS.Loaded["BattleGroundEnemies"] = NS.LoadCount
