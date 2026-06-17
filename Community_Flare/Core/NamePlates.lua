-- initialize
local LibStub = LibStub
local ADDON_NAME, NS = ...
if (not NS.Loaded or not NS.Loaded["Menus"]) then return end
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
if (not L or not NS.CommFlare) then return end

-- localize stuff
local _G                                          = _G
local CreateFrame                                 = _G.CreateFrame
local GetNamePlateForUnit                         = _G.C_NamePlate.GetNamePlateForUnit
local issecretvalue                               = _G.issecretvalue
local print                                       = _G.print
local wipe                                        = _G.wipe

-- global variables
NS.CommFlare.ActiveNamePlates = {}

-- BGE: dump all player details
function NS:BGE_Dump_Player_Details(unitToken, field)
	-- not installed?
	if (NS.faction ~= 0) then return end
	if (not BattleGroundEnemies or not BattleGroundEnemies.GetPlayerbuttonByUnitID) then
		-- failed
		return nil
	end

	-- get player button / details / field
	local playerButton = BattleGroundEnemies:GetPlayerbuttonByUnitID(unitToken, "Enemies")
	local playerDetails = playerButton and playerButton.PlayerDetails or nil
	if (playerDetails and playerDetails[field]) then
		-- display
		print(field, "=", playerDetails[field])
		DevTools_Dump(playerDetails)
	end
end

-- BGE: get player details
function NS:BGE_GetPlayerDetails(unitToken)
	-- not installed?
	if (NS.faction ~= 0) then return end
	if (not BattleGroundEnemies or not BattleGroundEnemies.GetPlayerbuttonByUnitID) then
		-- failed
		return nil
	end

	-- get player button / details / role
	local playerButton = BattleGroundEnemies:GetPlayerbuttonByUnitID(unitToken, "Enemies")
	return playerButton and playerButton.PlayerDetails or nil
end

-- is valid unit token
function NS:IsValidUnitToken(unitToken)
	-- not player?
	if (NS.faction ~= 0) then return nil end
	if (not NS:UnitIsPlayer(unitToken)) then
		-- failed
		return nil
	end

	-- not an enemy?
	if (not NS:UnitCanAttack("player", unitToken) or not NS:UnitIsEnemy("player", unitToken)) then
		-- failed
		return nil
	end

	-- unit is mind controlled?
	if (NS:UnitIsPossessed(unitToken)) then
		-- same faction as player?
		if (NS:UnitFactionGroup(unitToken) == NS.CommFlare.CF.PlayerFaction) then
			-- failed
			return nil
		end
	end

	-- success
	return true
end

-- get unit role
function NS:GetUnitRole(unitToken)
	-- check only damage classes first
	if (NS.faction ~= 0) then return nil end
	local className, classID = NS:UnitClassBase(unitToken)
	if ((className == "HUNTER") or (className == "MAGE") or (className == "ROGUE") or (className == "WARLOCK")) then
		-- damager
		return "DAMAGER"
	end

	-- get player details
	local playerDetails = NS:BGE_GetPlayerDetails(unitToken)
	if (playerDetails and playerDetails.PlayerName and not issecretvalue(playerDetails.PlayerName)) then
		-- found active name plate?
		if (NS.CommFlare.ActiveNamePlates[unitToken]) then
			-- save player details
			NS.CommFlare.ActiveNamePlates[unitToken].data = playerDetails
			NS.CommFlare.ActiveNamePlates[unitToken].name = playerDetails.PlayerName
		end

		-- found non-secret role?
		local playerRole = playerDetails and playerDetails.PlayerRole or nil
		if (not issecretvalue(playerRole)) then
			-- healer?
			if (playerRole == "HEALER") then
				-- return role
				return playerRole
			-- tank?
			elseif (playerRole == "TANK") then
				-- return role
				return playerRole
			-- damager?
			elseif (playerRole == "DAMAGER") then
				-- return role
				return playerRole
			end
		end
	end

	-- monk?
	if (className == "MONK") then
		-- check power type
		local powerType = NS:UnitPowerType(unitToken)
		if (powerType == 0) then
			-- healer
			return "HEALER"
		else
			-- check power max
			local powerMax = NS:UnitPowerMax(unitToken, 12)
			if (powerMax == 4) then
				-- tank
				return "TANK"
			end
		end
	-- priest?
	elseif (className == "PRIEST") then
		-- check power type
		local powerType = NS:UnitPowerType(unitToken)
		if (powerType ~= 13) then
			-- healer
			return "HEALER"
		end
	-- shaman?
	elseif (className == "SHAMAN") then
		-- check power type
		local powerType = NS:UnitPowerType(unitToken)
		if (powerType ~= 11) then
			-- healer
			return "HEALER"
		end
	end

	-- unknown
	return nil
end


-- update role icon
function NS:UpdateRoleIcon(unitToken, namePlate, role)
	-- no nameplate given?
	if (NS.faction ~= 0) then return nil end
	if (not namePlate) then
		-- has unitToken?
		if (unitToken) then
			-- get name plate for unit
			namePlate = GetNamePlateForUnit(unitToken)
			if (not namePlate) then
				-- finished
				return nil
			end
		end
	end

	-- role icon not created yet?
	if (not namePlate.roleIcon) then
		-- create texture
		namePlate.roleIcon = namePlate:CreateTexture(nil, "OVERLAY")
		namePlate.roleIcon:SetSize(50, 50)
		namePlate.roleIcon:SetPoint("BOTTOM", namePlate, "TOP", 0, 0)
	end

	-- is valid unit token
	if (NS:IsValidUnitToken(unitToken)) then
		-- no role yet?
		if (not role) then
			-- get unit role
			role = NS:GetUnitRole(unitToken)
		end

		-- found role now?
		if (role) then
			-- healer?
			if (role == "HEALER") then
				-- show healer
				namePlate.roleIcon:SetTexture("Interface\\AddOns\\Community_Flare\\Media\\healer.tga")
				namePlate.roleIcon:Show()
				return true
			-- tank?
			elseif (role == "TANK") then
				-- show tank
				namePlate.roleIcon:SetTexture("Interface\\AddOns\\Community_Flare\\Media\\tank.tga")
				namePlate.roleIcon:Show()
				return true
			-- damager?
			--[[elseif (role == "DAMAGER") then
				-- show dps
				namePlate.roleIcon:SetTexture("Interface\\AddOns\\Community_Flare\\Media\\damager.tga")
				namePlate.roleIcon:Show()
				return true]]--
			end
		end
	end

	-- hide
	namePlate.roleIcon:Hide() 
end

-- on event handler
local function OnEvent(self, event, ...)
	-- name plate unit added?
	if (NS.faction ~= 0) then return nil end
	if (event == "NAME_PLATE_UNIT_ADDED") then
		-- get name plate for unit
		local unitToken = ...
		local namePlate = GetNamePlateForUnit(unitToken)
		if (not namePlate) then return end
		NS.CommFlare.ActiveNamePlates[unitToken] = { namePlate = namePlate }
		NS:UpdateRoleIcon(unitToken, namePlate)
	-- name plate unit removed?
	elseif (event == "NAME_PLATE_UNIT_REMOVED") then
		-- get name plate for unit
		local unitToken = ...
		local namePlate = GetNamePlateForUnit(unitToken)
		if (not namePlate) then return end
		if (namePlate.roleIcon) then namePlate.roleIcon:Hide() end
		if (NS.CommFlare.ActiveNamePlates[unitToken]) then
			-- delete
			wipe(NS.CommFlare.ActiveNamePlates[unitToken])
			NS.CommFlare.ActiveNamePlates[unitToken] = nil
		end
	end
end

-- create event handler frame
local f = CreateFrame("Frame")
f:RegisterEvent("NAME_PLATE_UNIT_ADDED")
f:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
f:SetScript("OnEvent", OnEvent)

-- fully loaded
NS.LoadCount = NS.LoadCount + 1
NS.Loaded["NamePlates"] = NS.LoadCount
