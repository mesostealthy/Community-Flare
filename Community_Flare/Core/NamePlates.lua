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

	-- success
	return true
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
		-- same realm as player?
		local player, realm = UnitName(unitToken)
		local realmRelationship = UnitRealmRelationship(unitToken)
		if (realmRelationship == LE_REALM_RELATION_SAME) then
			-- player with same realm
			player = player .. "-" .. NS.CommFlare.CF.PlayerServerName
		else
			-- player with different realm
			player = player .. "-" .. realm
		end

		-- found player role?
		if (NS.db.global.PlayerDB[player] and NS.db.global.PlayerDB[player].role) then
			-- healer?
			if (NS.db.global.PlayerDB[player].role == "HEALER") then
				-- show healer
				namePlate.roleIcon:SetTexture("Interface\\AddOns\\Community_Flare\\Media\\healer.tga")
				namePlate.roleIcon:Show()
				return true
			-- tank?
			elseif (NS.db.global.PlayerDB[player].role == "TANK") then
				-- show tank
				namePlate.roleIcon:SetTexture("Interface\\AddOns\\Community_Flare\\Media\\tank.tga")
				namePlate.roleIcon:Show()
				return true
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
