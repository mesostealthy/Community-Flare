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
local IsInInstance                                = _G.IsInInstance
local IsInRaid                                    = _G.IsInRaid
local PvPGetActiveMatchState                      = _G.C_PvP.GetActiveMatchState
local PvPGetActiveMatchDuration                   = _G.C_PvP.GetActiveMatchDuration
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

-- update assist button
function NS:UpdateAssistButton()
	-- show appropriate stuff
	if (NS.faction ~= 0) then return end
	if (NS.db.global.AssistFrame.locked) then
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

-- create assist button
function NS:CreateAssistButton()
	-- already initialized?
	if (NS.faction ~= 0) then return end
	if (NS.AssistButton.initialized) then
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
			if (NS.db.global.AssistFrame.locked) then
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
			if (NS.db.global.AssistFrame.locked) then
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
			if (NS.db.global.AssistFrame.locked) then
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
				if (NS.db.global.AssistFrame.locked) then
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
	NS.AssistButton.Header.Text = NS.AssistButton:CreateFontString(nil, "ARTWORK", nil)
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
		if (inInstance) then
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

-- on event handler
local function OnEvent(self, event, ...)
	-- player entering world?
	if (event == "PLAYER_ENTERING_WORLD") then
		local isInitialLogin, isReloadingUi = ...

		-- initial login or reloading?
		if (isInitialLogin or isReloadingUi) then
			-- create assist button
			NS:CreateAssistButton()

			-- assist button enabled?
			if (NS.db.global.assistButtonEnabled) then
				-- in battleground?
				if (NS:IsInBattleground()) then
					-- match state is active?
					local duration = PvPGetActiveMatchDuration()
					if (PvPGetActiveMatchState() == Enum.PvPMatchState.Engaged) then
						-- show assist button
						NS:ShowAssistButton()
					end
				end
			end
		end
	-- player regen enabled?
	elseif (event == "PLAYER_REGEN_ENABLED") then
		-- assist button enabled?
		if (NS.db.global.assistButtonEnabled) then
			-- hide assist button?
			if (NS.CommFlare.CF.RegenJobs["HideAssistButton"]) then
				-- hide
				NS.CommFlare.CF.RegenJobs["HideAssistButton"] = nil
				NS:HideAssistButton()
			elseif (NS.CommFlare.CF.RegenJobs["ShowAssistButton"]) then
				-- show
				NS.CommFlare.CF.RegenJobs["ShowAssistButton"] = nil
				NS:ShowAssistButton()
			end
		end
	-- player roles assigned?
	elseif (event == "PLAYER_ROLES_ASSIGNED") then
		-- assist button enabled?
		if (NS.db.global.assistButtonEnabled) then
			-- in battleground?
			if (NS:IsInBattleground()) then
				-- match state is not complete?
				if (PvPGetActiveMatchState() ~= Enum.PvPMatchState.Complete) then
					-- show assist button
					NS:ShowAssistButton()
				end
			end
		end
	-- pvp match complete?
	elseif (event == "PVP_MATCH_COMPLETE") then
		-- assist button enabled?
		if (NS.db.global.assistButtonEnabled) then
			-- assist button shown?
			if (NS.AssistButton:IsShown()) then
				-- hide assist button
				NS:HideAssistButton()
			end
		end
	-- zone changed new area?
	elseif (event == "ZONE_CHANGED_NEW_AREA") then
		-- assist button enabled?
		if (NS.db.global.assistButtonEnabled) then
			-- assist button shown?
			if (NS.AssistButton:IsShown()) then
				-- check zone type
				local inInstance, instanceType = IsInInstance()
				if (instanceType ~= "pvp") then
					-- hide assist button
					NS:HideAssistButton()
				end
			end
		end
	end
end

-- create event handler frame
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:RegisterEvent("PLAYER_ROLES_ASSIGNED")
f:RegisterEvent("PVP_MATCH_COMPLETE")
f:RegisterEvent("ZONE_CHANGED_NEW_AREA")
f:SetScript("OnEvent", OnEvent)

-- fully loaded
NS.LoadCount = NS.LoadCount + 1
NS.Loaded["Assist"] = NS.LoadCount
