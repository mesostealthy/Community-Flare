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
				return name
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
				return name
			end
		end
	end
	return nil
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
	local player = CommunityFlare_GetMainAssist()
	if (player) then
		-- not in combat?
		NS.AssistButton.Button.macrotext = "/assist [nodead] " .. player
		if (not InCombatLockdown()) then
			-- setup macrotext
			NS.AssistButton.Button:SetAttribute("type1", "macro")
			NS.AssistButton.Button:SetAttribute("macrotext1", NS.AssistButton.Button.macrotext)
			if (not NS.AssistButton:IsShown()) then
				-- show
				NS.AssistButton:Show()
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
		NS.AssistButton:SetPoint("CENTER")
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
				if (NS.db.global.AssistFrame.locked == true) then
					-- disable
					self.Background:SetAlpha(0)
					self.Header.Background:SetAlpha(0)
					self.Header.Text:SetAlpha(0)
					self.Header:SetAlpha(0)
					self.ResizeButton:SetEnabled(false)
					self.ResizeButton:SetAlpha(0)
				else
					-- enable
					self.Background:SetAlpha(1)
					self.Header.Background:SetAlpha(1)
					self.Header.Text:SetAlpha(1)
					self.Header:SetAlpha(1)
					self.ResizeButton:SetEnabled(true)
					self.ResizeButton:SetAlpha(1)
				end
			end

			-- shown
			NS.AssistButton.shown = true
		end
	end)
	NS.AssistButton:SetScript("OnHide", function(self)
		-- not in combat?
		if (not InCombatLockdown()) then
			-- hidden
			NS.AssistButton.shown = nil
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
			self:StartMoving()
		end
	end)
	NS.AssistButton:SetScript("OnDragStop", function(self)
		-- not in combat?
		if (not InCombatLockdown()) then
			-- stop moving or sizing
			self:StopMovingOrSizing()

			-- get / save position
			local scale = self:GetScale()
			local left, top = self:GetLeft() * scale, self:GetTop() * scale
			if (not NS.db.global.AssistFrame) then
				-- initialize
				NS.db.global.AssistFrame = {}
			end

			-- save positions
			NS.db.global.AssistFrame.left = left
			NS.db.global.AssistFrame.top = top
		end
	end)
	NS.AssistButton:SetScript("OnMouseUp", function(self, button)
		-- right click?
		if (button == "RightButton") then
			-- toggle alpha
			local alpha = self.Header.Background:GetAlpha()
			if (alpha == 1) then
				-- disable
				NS.db.global.AssistFrame.locked = true
				self.Background:SetAlpha(0)
				self.Header.Background:SetAlpha(0)
				self.Header.Text:SetAlpha(0)
				self.Header:SetAlpha(0)
				self.ResizeButton:SetEnabled(false)
				self.ResizeButton:SetAlpha(0)
			else
				-- enable
				NS.db.global.AssistFrame.locked = nil
				self.Background:SetAlpha(1)
				self.Header.Background:SetAlpha(1)
				self.Header.Text:SetAlpha(1)
				self.Header:SetAlpha(1)
				self.ResizeButton:SetEnabled(true)
				self.ResizeButton:SetAlpha(1)
			end
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
		-- start sizing
		NS.AssistButton:StartSizing("BOTTOMRIGHT")
	end)
	NS.AssistButton.ResizeButton:SetScript("OnMouseUp", function(self)
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
	end)

	-- initialized
	NS.AssistButton.initialized = true
end
