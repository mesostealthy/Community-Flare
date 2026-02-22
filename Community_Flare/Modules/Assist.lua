-- initialize
local LibStub = LibStub
local ADDON_NAME, NS = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
if (not L or not NS.CommFlare) then return end
if (UnitFactionGroup("player") == FACTION_ALLIANCE) then return end

-- localize stuff
local _G                                          = _G
local CreateFrame                                 = _G.CreateFrame
local GetRaidRosterInfo                           = _G.GetRaidRosterInfo
local InCombatLockdown                            = _G.InCombatLockdown
local IsInRaid                                    = _G.IsInRaid
local UnitIsEnemy                                 = _G.UnitIsEnemy
local UnitIsPlayer                                = _G.UnitIsPlayer
local GetNamePlateForUnit                         = _G.C_NamePlate.GetNamePlateForUnit
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
			local player, _, _, _, _, _, _, _, _, role = GetRaidRosterInfo(i)
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
			-- get player / role
			local name, _, _, _, _, _, _, _, _, role = GetRaidRosterInfo(i)
			if (player and ((role == "maintank") or (role == "MAINTANK"))) then
				-- return name
				local name, realm = strsplit("-", player)
				return name, i
			end
		end
	end
	return nil
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
	local height = NS.AssistButton:GetHeight()
	local width = NS.AssistButton:GetWidth()
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

	-- move assist button
	NS.AssistButton:ClearAllPoints()
	NS.AssistButton:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left, top)
end

-- name plate added
function NS:AssistButtonNamePlateAdded(...)
	-- get main assist
	local unitToken = ...
	if (NS.faction ~= 0) then return end
	local player1, unitToken1 = CommunityFlare_GetMainAssist()
	if (player1) then
		-- nameplateX only
		if (unitToken:find("nameplate")) then
			-- enemy player?
			if (UnitIsEnemy(unitToken, "player")) then
				-- get name plate
				local namePlate = GetNamePlateForUnit(unitToken)
				if (not namePlate) then
					-- failed
					return nil
				end

				-- uninitialized?
				if (not namePlate.CF) then
					-- create frame
					namePlate.CF = {}
					namePlate.CF.frame = CreateFrame("Frame", nil, namePlate)
					namePlate.CF.frame:SetFrameStrata("HIGH")
					namePlate.CF.frame:SetSize(50, 50)
					namePlate.CF.frame:SetPoint("BOTTOM", namePlate, "TOP", 0, 10)
					namePlate.CF.frame.texture = namePlate.CF.frame:CreateTexture(nil, "OVERLAY")
					namePlate.CF.frame.texture:SetAllPoints()
					namePlate.CF.frame.texture:SetTexture("Interface\\AddOns\\Community_Flare_Details\\Media\\dps.tga")
				end

				-- show transparent
				namePlate.CF.frame:SetAlpha(0)
				namePlate.CF.frame:Show()
			end
		end
	end
end

-- name plate removed
function NS:AssistButtonNamePlateRemoved(...)
	-- nameplateX only
	local unitToken = ...
	if (NS.faction ~= 0) then return end
	if (unitToken:find("nameplate")) then
		-- get name plate
		local namePlate = GetNamePlateForUnit(unitToken)
		if (not namePlate) then
			-- failed
			return nil
		end

		-- frame created?
		if (namePlate.CF and namePlate.CF.frame and namePlate.CF.texture) then
			-- hide
			namePlate.CF.frame:SetAlpha(0)
			namePlate.CF.frame:Hide()
		end
	end
end

-- assist button update target
function NS:AssistButtonUpdateTarget(...)
	-- get main assist
	if (NS.faction ~= 0) then return end
	local player1, unitToken1 = CommunityFlare_GetMainAssist()
	if (player1) then
		-- process all
		local targetUnit = "raid" .. unitToken1 .. "target"
		for _, namePlate in ipairs(GetNamePlates()) do
			-- get unit
			local unit = namePlate:GetUnit()
			if (namePlate.CF and namePlate.CF.frame) then
				-- set alpha from boolean
				local isTarget = UnitIsUnit(targetUnit, unit)
				namePlate.CF.frame:SetAlphaFromBoolean(isTarget, 1, 0)
			end
		end
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
	NS.AssistButton:SetSize(width, width + 20)
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
			if (NS.db.global.AssistFrame and NS.db.global.AssistFrame.left and NS.db.global.AssistFrame.top) then
				-- move window
				local width = NS.db.global.AssistFrame.width or 120
				self:ClearAllPoints()
				self:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", NS.db.global.AssistFrame.left, NS.db.global.AssistFrame.top)
				self:SetWidth(width)
				self:SetHeight(width + 20)

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
	end)
	NS.AssistButton:SetScript("OnLeave", function(self)
		-- locked?
		if (NS.db.global.AssistFrame.locked == true) then
			-- show header background
			self.Header.Background:SetAlpha(0)
			self.Header.Text:SetAlpha(0)
		end

		-- hide tooltip
		GameTooltip:Hide()
	end)
	NS.AssistButton:SetScript("OnMouseUp", function(self, button)
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
	end)
	NS.AssistButton:SetScript("OnSizeChanged", function(self, width, height)
		-- not in combat?
		if (not InCombatLockdown()) then
			-- not locked?
			if (NS.db.global.AssistFrame.locked ~= true) then
				-- always use same
				self:SetSize(width, width + 20)
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
	NS.AssistButton.Button.texture:SetTexture("Interface\\AddOns\\Community_Flare\\Media\\assist.tga")
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
	NS.AssistButton:RegisterEvent("NAME_PLATE_UNIT_BEHIND_CAMERA_CHANGED")
	NS.AssistButton:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
	NS.AssistButton:RegisterEvent("UNIT_TARGET")
	NS.AssistButton:SetScript("OnEvent", function(self, event, ...)
		-- name plate unit added?
		if (event == "NAME_PLATE_UNIT_ADDED") then
			-- assist button name plate added
			NS:AssistButtonNamePlateAdded(...)
		elseif (event == "NAME_PLATE_UNIT_BEHIND_CAMERA_CHANGED") then
			-- assist button name plate added
			NS:AssistButtonNamePlateAdded(...)
		elseif (event == "NAME_PLATE_UNIT_REMOVED") then
			-- assist button name plate removed
			NS:AssistButtonNamePlateRemoved(...)
		elseif (event == "UNIT_TARGET") then
			-- assist button update target
			NS:AssistButtonUpdateTarget(...)
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
	-- get main assist
	if (NS.faction ~= 0) then return end
	local player1, unitToken1 = CommunityFlare_GetMainAssist()
	if (player1) then
		-- not in combat?
		if (not InCombatLockdown()) then
			-- setup macrotext
			NS.AssistButton.Button.macrotext1 = "/assist [nodead] " .. player1
			NS.AssistButton.Button.unitToken1 = "raid" .. unitToken1
			NS.AssistButton.Button:SetAttribute("type1", "macro")
			NS.AssistButton.Button:SetAttribute("macrotext1", NS.AssistButton.Button.macrotext1)
			if (not NS.AssistButton:IsShown()) then
				-- show
				NS.AssistButton:Show()
			end

			-- has main tank?
			local player2, unitToken2 = CommunityFlare_GetMainTank()
			if (player2) then
				-- setup macrotext
				NS.AssistButton.Button.macrotext2 = "/assist [nodead] " .. player2
				NS.AssistButton.Button.unitToken2 = "raid" .. unitToken2
				NS.AssistButton.Button:SetAttribute("type2", "macro")
				NS.AssistButton.Button:SetAttribute("macrotext2", NS.AssistButton.Button.macrotext2)
			end
		else
			-- show later
			NS.CommFlare.CF.RegenJobs["ShowAssistButton"] = true
		end
	else
		-- hide assist button
		NS:HideAssistButton()
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
