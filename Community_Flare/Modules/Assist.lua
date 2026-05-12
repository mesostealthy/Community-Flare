-- initialize
local LibStub = LibStub
local ADDON_NAME, NS = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
if (not L or not NS.CommFlare) then return end
if (UnitFactionGroup("player") == FACTION_ALLIANCE) then return end

-- localize stuff
local _G                                          = _G
local CreateFrame                                 = _G.CreateFrame
local GetScreenHeight                             = _G.GetScreenHeight
local GetScreenWidth                              = _G.GetScreenWidth
local InCombatLockdown                            = _G.InCombatLockdown
local IsInRaid                                    = _G.IsInRaid
local UnitCanAttack                               = _G.UnitCanAttack
local UnitClassBase                               = _G.UnitClassBase
local UnitIsEnemy                                 = _G.UnitIsEnemy
local UnitIsPlayer                                = _G.UnitIsPlayer
local UnitIsPossessed                             = _G.UnitIsPossessed
local UnitPowerMax                                = _G.UnitPowerMax
local UnitPowerType                               = _G.UnitPowerType
local GetNamePlates                               = _G.C_NamePlate.GetNamePlates
local mfloor                                      = _G.math.floor
local strsplit                                    = _G.string.split

-- create frames
NS.AssistButton = CreateFrame("Frame", nil, UIParent)
NS.AssistButton.initialized = false
NS.AssistButton:Hide()

-- global: get main assist
function CommunityFlare_GetMainAssist()
	-- in raid?
	if (NS.faction ~= 0) then return end
	if (IsInRaid()) then
		-- process all
		for i=1, MAX_RAID_MEMBERS do
			-- get player / role
			local player, _, _, _, _, _, _, _, _, role = NS:GetRaidRosterInfo(i)
			if (player and ((role == "mainassist") or (role == "MAINASSIST"))) then
				-- return name
				local name, realm = strsplit("-", player)
				return name, i
			end
		end
	end
	return nil
end

-- global: get main tank
function CommunityFlare_GetMainTank()
	-- in raid?
	if (NS.faction ~= 0) then return end
	if (IsInRaid()) then
		-- process all
		for i=1, MAX_RAID_MEMBERS do
			-- get player / roled
			local name, _, _, _, _, _, _, _, _, role = NS:GetRaidRosterInfo(i)
			if (player and ((role == "maintank") or (role == "MAINTANK"))) then
				-- return name
				local name, realm = strsplit("-", player)
				return name, i
			end
		end
	end
	return nil
end

-- get player details from battleground enemies
function NS:BattleGroundEnemies_GetPlayerDetails(unitToken)
	-- not installed?
	if (NS.faction ~= 0) then return end
	if (not BattleGroundEnemies or not BattleGroundEnemies.GetPlayerbuttonByUnitID) then
		-- failed
		return nil
	end

	-- get player button by unit
	local playerButton = BattleGroundEnemies:GetPlayerbuttonByUnitID(unitToken, "Enemies")
	if (not playerButton or not playerButton.PlayerDetails) then
		-- failed
		return nil
	end

	-- no player role?
	local playerDetails = playerButton.PlayerDetails
	if (not playerDetails or not playerDetails.PlayerRole) then
		-- failed
		return nil
	end

	-- return player role
	return playerDetails.PlayerRole
end

-- update assist button
function NS:UpdateAssistButton()
	-- show appropriate stuff
	if (NS.faction ~= 0) then return end
	if (NS.db.global.AssistFrame.locked == true) then
		-- disable
		NS.AssistButton.Background:SetAlpha(0)
		NS.AssistButton.Header.Background:SetAlpha(0)
		NS.AssistButton.Header.Text:SetAlpha(0)
		NS.AssistButton.ResizeButton:SetEnabled(false)
		NS.AssistButton.ResizeButton:SetAlpha(0)
	else
		-- enable
		NS.AssistButton.Background:SetAlpha(1)
		NS.AssistButton.Header.Background:SetAlpha(1)
		NS.AssistButton.Header.Text:SetAlpha(1)
		NS.AssistButton.ResizeButton:SetEnabled(true)
		NS.AssistButton.ResizeButton:SetAlpha(1)
	end
end

-- save button position
function NS:SaveButtonPosition()
	-- not initialized?
	if (NS.faction ~= 0) then return end
	if (not NS.db.global.AssistFrame) then
		-- initialize
		NS.db.global.AssistFrame = {}
	end

	-- sanity checks
	local scale = NS.AssistButton:GetScale()
	local maxheight = mfloor(GetScreenHeight())
	local maxwidth = mfloor(GetScreenWidth())
	local width = NS.AssistButton:GetWidth()
	local height = NS.AssistButton:GetHeight() + width
	local left, top = NS.AssistButton:GetLeft() * scale, NS.AssistButton:GetTop() * scale

	-- sanity check for x position
	if (left < 0) then
		-- reset
		left = 0
	elseif ((left + width) > maxwidth) then
		-- reset
		left = maxwidth - width
	end

	-- sanity check for y position
	if ((top - height) < 0) then
		-- reset
		top = height
	elseif (top > maxheight) then
		-- reset
		top = maxheight
	end

	-- save positions
	NS.db.global.AssistFrame.left = left
	NS.db.global.AssistFrame.top = top
	NS.db.global.AssistFrame.width = width

	-- move assist button
	NS.AssistButton:ClearAllPoints()
	NS.AssistButton:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left, top)
end

-- is valid unit token
function NS:IsValidUnitToken(unitToken)
	-- not player?
	if (NS.faction ~= 0) then return nil end
	if (not UnitIsPlayer(unitToken)) then
		-- failed
		return nil
	end

	-- not an enemy?
	if (not (UnitCanAttack("player", unitToken) or UnitIsEnemy("player", unitToken))) then
		-- failed
		return nil
	end

	-- unit is mind controlled?
	if (UnitIsPossessed(unitToken)) then
		-- : same faction as player?
		if (UnitFactionGroup(unitToken) == NS.CommFlare.CF.PlayerFaction) then
			-- failed
			return nil
		end
	end

	-- success
	return true
end

-- get unit role
function NS:GetUnitRole(unitToken)
	-- check class base
	if (NS.faction ~= 0) then return nil end
	local className, classID = UnitClassBase(unitToken)
	if ((className == "HUNTER") or (className == "MAGE") or (className == "ROGUE") or (className == "WARLOCK")) then
		-- damager
		return "DAMAGER"
	elseif (className == "MONK") then
		-- check power type
		local powerType = UnitPowerType(unitToken)
		if (powerType == 0) then
			-- healer
			return "HEALER"
		else
			-- check power max
			local powerMax = UnitPowerMax(unitToken, 12)
			if (powerMax == 4) then
				-- tank
				return "TANK"
			end
		end
	elseif (className == "PRIEST") then
		-- check power type
		local powerType = UnitPowerType(unitToken)
		if (powerType ~= 13) then
			-- healer
			return "HEALER"
		end
	end

	-- try getting from battleground enemies
	local role = NS:BattleGroundEnemies_GetPlayerDetails(unitToken)
	if (role) then
		-- healer?
		if (role == "HEALER") then
			-- return role
			return role
		-- tank?
		elseif (role == "TANK") then
			-- return role
			return role
		-- damager?
		elseif (role == "DAMAGER") then
			-- return role
			return role
		end
	end

	-- last resort shaman check
	if (className == "SHAMAN") then
		-- check power type
		local powerType = UnitPowerType(unitToken)
		if (powerType ~= 11) then
			-- healer
			return "HEALER"
		end
	end

	-- unknown
	return nil
end

-- name plate added
function NS:AssistButtonNamePlateAdded(unitToken)
	-- get name plate for unit
	if (NS.faction ~= 0) then return end
	local namePlate = NS:GetNamePlateForUnit(unitToken)
	if (not namePlate) then
		-- finished
		return
	end

	-- has unit frame?
	local unitFrame = namePlate.UnitFrame
	if (not unitFrame) then
		-- finished
		return
	end

	-- texture not created yet?
	if (not unitFrame.CFTexture) then
		-- create / setup texture
		unitFrame.CFTexture = unitFrame:CreateTexture(nil, "OVERLAY")
		unitFrame.CFTexture:SetSize(50, 50)
		unitFrame.CFTexture:SetPoint("BOTTOM", namePlate, "TOP", 0, 0)
	end

	-- valid token?
	if (NS:IsValidUnitToken(unitToken)) then
		-- get unit role
		local role = NS:GetUnitRole(unitToken)
		if (role == "HEALER") then
			-- set healer
			unitFrame.CFTexture:SetTexture("Interface\\AddOns\\Community_Flare\\Media\\healer.tga")
			unitFrame.CFTexture:Show()
			return
		elseif (role == "TANK") then
			-- set healer
			unitFrame.CFTexture:SetTexture("Interface\\AddOns\\Community_Flare\\Media\\tank.tga")
			unitFrame.CFTexture:Show()
			return
		end
	end

	-- hide texture
	unitFrame.CFTexture:Hide()
end

-- name plate removed
function NS:AssistButtonNamePlateRemoved(unitToken)
	-- has nameplate, unit frame and texture?
	if (NS.faction ~= 0) then return end
	local namePlate = C_NamePlate.GetNamePlateForUnit(unit)
	if (namePlate and namePlate.UnitFrame and namePlate.UnitFrame.CFTexture) then
		-- hide texture
		namePlate.UnitFrame.CFTexture:Hide()
	end
end

-- create assist button
function NS:CreateAssistButton()
	-- already initialized?
	if (NS.faction ~= 0) then return end
	if (NS.AssistButton.initialized == true) then
		-- finished
		return
	end

	-- setup frame
	local top = NS.db.global.AssistFrame.top or 0
	local left = NS.db.global.AssistFrame.left or 0
	local width = NS.db.global.AssistFrame.width or 120
	NS.AssistButton:ClearAllPoints()
	NS.AssistButton:EnableMouse(true)
	NS.AssistButton:RegisterForDrag("LeftButton")
	NS.AssistButton:SetMovable(true)
	NS.AssistButton:SetSize(width, 20)
	if ((left > 0) and (top > 0)) then
		-- position window properly
		NS.AssistButton:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left, top)
	else
		-- center window (default)
		NS.AssistButton:SetPoint("CENTER", 150, 0)
	end
	NS.AssistButton:SetResizable(true)
	NS.AssistButton:SetResizeBounds(50, 50, 250, 250)
	NS.AssistButton:SetScript("OnShow", function(self)
		-- not in combat?
		if (not InCombatLockdown()) then
			-- has position?
			if (NS.db.global.AssistFrame and NS.db.global.AssistFrame.left and NS.db.global.AssistFrame.top and NS.db.global.AssistFrame.width) then
				-- move window
				local width = NS.db.global.AssistFrame.width or 120
				self:ClearAllPoints()
				self:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", NS.db.global.AssistFrame.left, NS.db.global.AssistFrame.top)
				self:SetSize(width, 20)

				-- update assist button
				NS:UpdateAssistButton()
			end

			-- shown
			self.shown = true
		end
	end)
	NS.AssistButton:SetScript("OnHide", function(self)
		-- not in combat?
		if (not InCombatLockdown()) then
			-- hidden
			self.shown = nil
		end
	end)
	NS.AssistButton:SetScript("OnDragStart", function(self)
		-- not in combat?
		if (not InCombatLockdown()) then
			-- locked?
			if (NS.db.global.AssistFrame.locked == true) then
				-- finished
				return
			end

			-- start moving
			self.moving = true
			self:StartMoving()
		end
	end)
	NS.AssistButton:SetScript("OnDragStop", function(self)
		-- not in combat?
		if (not InCombatLockdown()) then
			-- stop moving or sizing
			self:StopMovingOrSizing()

			-- save button position
			NS:SaveButtonPosition()
			self.moving = nil
		end
	end)
	NS.AssistButton:SetScript("OnEnter", function(self)
		-- not in combat?
		if (not InCombatLockdown()) then
			-- locked?
			if (NS.db.global.AssistFrame.locked == true) then
				-- show header background
				self.Header.Background:SetAlpha(1)
				self.Header.Text:SetAlpha(1)
			end

			-- show tooltip
			GameTooltip:SetOwner(self)
			GameTooltip:AddLine("Main Assist Button")
			GameTooltip:AddLine("-Right Click: Lock / Unlock Window Position", 1, 1, 1)
			GameTooltip:Show()
		end
	end)
	NS.AssistButton:SetScript("OnLeave", function(self)
		-- not in combat?
		if (not InCombatLockdown()) then
			-- locked?
			if (NS.db.global.AssistFrame.locked == true) then
				-- show header background
				self.Header.Background:SetAlpha(0)
				self.Header.Text:SetAlpha(0)
			end

			-- hide tooltip
			GameTooltip:Hide()
		end
	end)
	NS.AssistButton:SetScript("OnMouseUp", function(self, button)
		-- not in combat?
		if (not InCombatLockdown()) then
			-- right click?
			if (button == "RightButton") then
				-- toggle lock
				if (NS.db.global.AssistFrame.locked == true) then
					-- enable
					NS.db.global.AssistFrame.locked = nil
				else
					-- disable
					NS.db.global.AssistFrame.locked = true
				end

				-- update assist button
				NS:UpdateAssistButton()
			end
		end
	end)
	NS.AssistButton:SetScript("OnSizeChanged", function(self, width, height)
		-- not in combat?
		if (not InCombatLockdown()) then
			-- not locked?
			if (NS.db.global.AssistFrame.locked ~= true) then
				-- always use same
				self:SetSize(width, 20)
				self.Button:SetSize(width, width)
				self.Header.Text:SetWidth(width)
			end
		end
	end)
	NS.AssistButton.Background = NS.AssistButton:CreateTexture(nil, "BACKGROUND")
	NS.AssistButton.Background:SetAllPoints()
	NS.AssistButton.Background:SetColorTexture(0, 0, 0, 1)
	NS.AssistButton.Header = CreateFrame("Frame", nil, NS.AssistButton)
	NS.AssistButton.Header:SetPoint("TOPLEFT", NS.AssistButton, "TOPLEFT", 0, 0)
	NS.AssistButton.Header:SetSize(width, 20)
	NS.AssistButton.Header.Background = NS.AssistButton:CreateTexture(nil, "BACKGROUND")
	NS.AssistButton.Header.Background:SetAllPoints()
	NS.AssistButton.Header.Background:SetColorTexture(0, 255, 0, 1)
	NS.AssistButton.Header.Text = NS.AssistButton:CreateFontString(nil, "ARTWORK", nil, 2)
	NS.AssistButton.Header.Text:SetFont(NS.Libs.LibSharedMedia:Fetch("font", "Roboto Condensed BoldItalic"), 12, "OUTLINE")
	NS.AssistButton.Header.Text:SetPoint("TOPLEFT", NS.AssistButton, "TOPLEFT", 2, 0)
	NS.AssistButton.Header.Text:SetSize(width, 20)
	NS.AssistButton.Header.Text:SetText("Right Click to Lock")
	NS.AssistButton.Header.Text:SetTextColor(1, 1, 1, 1)
	NS.AssistButton.Header.Text:SetJustifyH("CENTER")
	NS.AssistButton.Button = CreateFrame("Button", nil, NS.AssistButton, "SecureActionButtonTemplate")
	NS.AssistButton.Button:RegisterForClicks("AnyUp", "AnyDown")
	NS.AssistButton.Button:SetPoint("TOPLEFT", NS.AssistButton, "TOPLEFT", 0, -20)
	NS.AssistButton.Button:SetSize(width, width)
	NS.AssistButton.Button.texture = NS.AssistButton.Button:CreateTexture(nil, "OVERLAY")
	NS.AssistButton.Button.texture:SetAllPoints()
	NS.AssistButton.Button.texture:SetTexture("Interface\\AddOns\\Community_Flare\\Media\\kos.tga")
	NS.AssistButton.ResizeButton = CreateFrame("Button", nil, NS.AssistButton, "PanelResizeButtonTemplate")
	NS.AssistButton.ResizeButton:RegisterForClicks("AnyUp", "AnyDown")
	NS.AssistButton.ResizeButton:SetFrameLevel(10)
	NS.AssistButton.ResizeButton:SetPoint("BOTTOMRIGHT", NS.AssistButton.Button, "BOTTOMRIGHT")
	NS.AssistButton.ResizeButton:SetScript("OnMouseDown", function(self)
		-- not in combat?
		if (not InCombatLockdown()) then
			-- start sizing
			NS.AssistButton:StartSizing("BOTTOMRIGHT")
		end
	end)
	NS.AssistButton.ResizeButton:SetScript("OnMouseUp", function(self)
		-- not in combat?
		if (not InCombatLockdown()) then
			-- stop moving or sizing
			NS.AssistButton:StopMovingOrSizing()

			-- get / save position
			local parent = self:GetParent()
			local scale = parent:GetScale()
			local width = parent:GetWidth() * scale
			if (not NS.db.global.AssistFrame) then
				-- initialize
				NS.db.global.AssistFrame = {}
			end

			-- save positions
			NS.db.global.AssistFrame.width = width
		end
	end)

	-- event handler
	NS.AssistButton:RegisterEvent("NAME_PLATE_UNIT_ADDED")
	NS.AssistButton:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
	NS.AssistButton:RegisterEvent("PLAYER_LEAVING_WORLD")
	NS.AssistButton:SetScript("OnEvent", function(self, event, ...)
		-- name plate unit added?
		if (event == "NAME_PLATE_UNIT_ADDED") then
			local unitToken = ...
			NS:AssistButtonNamePlateAdded(unitToken)
		-- name plate unit removed?
		elseif (event == "NAME_PLATE_UNIT_REMOVED") then
			local unitToken = ...
		end
	end)

	-- initialized
	NS.AssistButton.initialized = true
end

-- hide assist button
function NS:HideAssistButton()
	-- not in combat?
	if (NS.faction ~= 0) then return end
	if (not InCombatLockdown()) then
		-- created?
		if (NS.AssistButton) then
			-- hide
			NS.AssistButton:Hide()
		end
	else
		-- hide later
		NS.CommFlare.CF.RegenJobs["HideAssistButton"] = true
	end
end

-- show assist button
function NS:ShowAssistButton()
	-- in combat lockdown?
	if (NS.faction ~= 0) then return end
	if (InCombatLockdown()) then
		-- show later
		NS.CommFlare.CF.RegenJobs["ShowAssistButton"] = true
	else
		-- in instance?
		local inInstance, instanceType = IsInInstance()
		if (inInstance == true) then
			-- pvp?
			if (instanceType == "pvp") then
				-- get main assist
				local player1, unitToken1 = CommunityFlare_GetMainAssist()
				if (player1) then
					-- setup macrotext
					NS.AssistButton.Button.macrotext1 = "/assist [nodead] " .. player1
					NS.AssistButton.Button.unitToken1 = "raid" .. unitToken1
					NS.AssistButton.Button:SetAttribute("type1", "macro")
					NS.AssistButton.Button:SetAttribute("macrotext1", NS.AssistButton.Button.macrotext1)

					-- get main tank?
					local player2, unitToken2 = CommunityFlare_GetMainTank()
					if (player2) then
						-- setup macrotext
						NS.AssistButton.Button.macrotext2 = "/assist [nodead] " .. player2
						NS.AssistButton.Button.unitToken2 = "raid" .. unitToken2
						NS.AssistButton.Button:SetAttribute("type2", "macro")
						NS.AssistButton.Button:SetAttribute("macrotext2", NS.AssistButton.Button.macrotext2)
					end

					-- not shown?
					if (not NS.AssistButton:IsShown()) then
						-- show
						NS.AssistButton:Show()
					end
				end
			end
		else
			-- not shown?
			if (not NS.AssistButton:IsShown()) then
				-- show
				NS.AssistButton:Show()
			end
		end
	end
end

-- toggle assist button
function NS:ToggleAssistButton()
	-- shown?
	if (NS.faction ~= 0) then return end
	if (NS.AssistButton:IsShown()) then
		-- not in combat?
		if (not InCombatLockdown()) then
			-- hide
			NS.AssistButton:Hide()
		else
			-- hide later
			NS.CommFlare.CF.RegenJobs["HideAssistButton"] = true
		end
	else
		-- not in combat?
		if (not InCombatLockdown()) then
			-- show
			NS.AssistButton:Show()
		else
			-- show later
			NS.CommFlare.CF.RegenJobs["ShowAssistButton"] = true
		end
	end
end

-- fully loaded
NS.LoadCount = NS.LoadCount + 1
NS.Loaded["Assist"] = NS.LoadCount
