-- initialize
local LibStub = LibStub
local ADDON_NAME, NS = ...
if (not NS.Loaded or not NS.Loaded["Timers"]) then return end
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
if (not L or not NS.CommFlare) then return end

-- localize stuff
local _G                                          = _G
local CreateFrame                                 = _G.CreateFrame
local InCombatLockdown                            = _G.InCombatLockdown
local IsShiftKeyDown                              = _G.IsShiftKeyDown
local next                                        = _G.next
local pairs                                       = _G.pairs
local print                                       = _G.print
local type                                        = _G.type
local wipe                                        = _G.wipe
local strformat                                   = _G.string.format

-- local variables
local createOverlays = {}

-- find bar
function NS:Capping_Find_Bar(name, exact)
	-- has capping?
	if (NS.faction ~= 0) then return end
	if (CappingFrame and CappingFrame.bars) then
		-- process all
		for bar,_ in pairs(CappingFrame.bars) do
			-- get label
			local label = bar:GetLabel()
			if (label) then
				-- exact match?
				if (exact == true) then
					-- matches?
					if (label == name) then
						-- return bar
						return bar
					end
				else
					-- matches?
					if (label:find(name)) then
						-- return bar
						return bar
					end
				end
			end
		end
	end

	-- failed
	return nil
end

-- stop bars
function NS:Capping_Stop_Bars(name)
	-- has capping?
	if (NS.faction ~= 0) then return end
	if (CappingFrame and CappingFrame.bars) then
		-- process all
		for bar,_ in pairs(CappingFrame.bars) do
			-- get label
			local label = bar:GetLabel()
			if (label) then
				-- matches?
				if (label:find(name)) then
					-- stop
					bar:Stop()
				end
			end
		end
	end
end

-- create bar overlay
function NS:Create_Bar_Overlay(bar)
	-- not created yet?
	if (not bar.Overlay) then
		-- create frame
		bar.Overlay = CreateFrame("Button", nil, bar, "SecureActionButtonTemplate")
		if (not bar.Overlay) then
			-- failed
			return nil
		end

		-- handle tooltip
		bar.Overlay:SetScript("OnEnter", function(self, bar)
			-- in combat lockdown?
			if (InCombatLockdown()) then
				-- disable mouse
				self:EnableMouse(false)
			else
				-- enable mouse
				self:EnableMouse(true)

				-- show tooltip
				GameTooltip:SetOwner(self)
				GameTooltip:AddLine("Left Click: Send Status", 1, 1, 1)
				GameTooltip:AddLine("Shift+Left Click: Say Status", 1, 1, 1)
				GameTooltip:AddLine("Right Click: Hide Bar", 1, 1, 1)
				GameTooltip:Show()
			end
		end)
		bar.Overlay:SetScript("OnLeave", function(self)
			-- hide tooltip
			GameTooltip:Hide()
		end)

		-- preclick handler
		bar.Overlay:SetScript("PreClick", function(self, button, down)
			-- not in combat lockdown?
			if (not InCombatLockdown()) then
				-- left button?
				if (button == "LeftButton") then
					-- button down?
					if (down) then
						-- build macrotext
						local macrotext = nil
						local timeLeft = bar.candyBarDuration:GetText()
						if not timeLeft:find("[:%.]") then timeLeft = "0:"..timeLeft end
						local text = strformat("Report: %s - %s", bar:GetLabel(), timeLeft)
						if (IsShiftKeyDown()) then
							-- say
							macrotext = strformat("/s %s", text)
						else
							-- pvp instance?
							local inInstance, instanceType = IsInInstance()
							if (instanceType == "pvp") then
								-- instance chat
								macrotext = strformat("/i %s", text)
							else
								-- say
								macrotext = strformat("/s %s", text)
							end
						end

						-- set macrotext
						self:SetAttribute("*type1", "macro")
						self:SetAttribute("*macrotext1", macrotext)
					end
				end
			end
		end)

		-- postclick handler
		bar.Overlay:SetScript("PostClick", function(self, button, down)
			-- not in combat lockdown?
			if (not InCombatLockdown()) then
				-- left button?
				if (button == "LeftButton") then
					-- button not down?
					if (not down) then
						-- clear macrotext
						self:SetAttribute("*type1", "macro")
						self:SetAttribute("*macrotext1", "")
					end
				-- right button?
				elseif (button == "RightButton") then
					-- hide / stop
					self:Hide()
					bar:Stop()
				end
			end
		end)

		-- register callback
		NS.Libs.LibCandyBar.RegisterCallback(NS, "LibCandyBar_Stop", function(self, bar)
			-- has overlay?
			if (bar.Overlay) then
				-- disable mouse
				bar.Overlay:EnableMouse(false)

				-- not in combat lockdown?
				if (not InCombatLockdown()) then
					-- hide
					bar.Overlay:Hide()
				end
			end
		end)
	end

	-- finish setup
	local width = bar:GetWidth()
	local height = bar:GetHeight()
	bar.Overlay:SetParent(bar)
        bar.Overlay:RegisterForClicks("AnyUp", "AnyDown")
       	bar.Overlay:SetFrameLevel(128)
        bar.Overlay:SetSize(width, height)
	bar.Overlay:ClearAllPoints()
	bar.Overlay:SetPoint("CENTER", bar, "CENTER", 0, 0)
	bar.Overlay:Show()
	return bar.Overlay
end

-- add new bar
function NS:Capping_Add_New_Bar(name, remaining, icon, colorid, priority, maxBarTime)
	-- no name given?
	if (NS.faction ~= 0) then return end
	if (not name or (name == "")) then
		-- finished
		return
	end

	-- invalid remaining?
	if (not remaining or (type(remaining) ~= "number")) then
		-- finished
		return
	end

	-- has capping?
	if (CappingFrame and CappingFrame.db and CappingFrame.db.profile) then
		-- create new bar
		local width = CappingFrame.db.profile.width or 20
		local height = CappingFrame.db.profile.height or 200
		local texture = NS.Libs.LibSharedMedia:Fetch("statusbar", CappingFrame.db.profile.barTexture) or "Interface\\RAIDFRAME\\Raid-Bar-Hp-Fill.blp"
		local bar = NS.Libs.LibCandyBar:New(texture, width, height)
		if (not bar) then
			-- finished
			return
		end

		-- add into active bars
		local activeBars = CappingFrame.bars
		activeBars[bar] = true

		-- has priority?
		if (priority) then
			-- save priority
			bar:Set("capping:priority", priority)
		end

		-- has colorid?
		if (colorid) then
			-- save colorid
			bar:Set("capping:colorid", colorid)
		end

		-- set parent / label
		bar:SetParent(CappingFrame)
		bar:SetLabel(name)
		bar.candyBarLabel:SetJustifyH(CappingFrame.db.profile.alignText)

		-- set duration
		bar.candyBarDuration:SetJustifyH(CappingFrame.db.profile.alignTime)
		bar:SetDuration(remaining)

		-- has color value?
		if (CappingFrame.db.profile[colorid]) then
			-- set colors
			bar:SetColor(unpack(CappingFrame.db.profile[colorid]))
			bar.candyBarBackground:SetVertexColor(unpack(CappingFrame.db.profile.colorBarBackground))
			bar:SetTextColor(unpack(CappingFrame.db.profile.colorText))
		end

		-- has icon and using them?
		if (CappingFrame.db.profile.icon and icon) then
			-- table?
			if (type(icon) == "table") then
				-- set icon
				bar:SetIcon(icon[1], icon[2], icon[3], icon[4], icon[5])
			else
				-- set icon
				bar:SetIcon(icon)
			end

			-- set icon position
			bar:SetIconPosition(CappingFrame.db.profile.alignIcon)
		end

		-- set visiblity / fill
		bar:SetTimeVisibility(CappingFrame.db.profile.timeText)
		bar:SetFill(CappingFrame.db.profile.fill)

		-- get font settings
		local flags = nil
		local fontStr = NS.Libs.LibSharedMedia:Fetch("font", CappingFrame.db.profile.font) or "Fonts\\FRIZQT__.TTF"
		if (CappingFrame.db.profile.monochrome and (CappingFrame.db.profile.outline ~= "NONE")) then
			flags = "MONOCHROME," .. CappingFrame.db.profile.outline
		elseif (CappingFrame.db.profile.monochrome) then
			flags = "MONOCHROME"
		elseif (CappingFrame.db.profile.outline ~= "NONE") then
			flags = CappingFrame.db.profile.outline
		end

		-- set font
		bar.candyBarLabel:SetFont(fontStr, CappingFrame.db.profile.fontSize, flags)
		bar.candyBarDuration:SetFont(fontStr, CappingFrame.db.profile.fontSize, flags)

		-- start
		bar:Start(maxBarTime)

		-- rearrange bars
		CappingFrame.RearrangeBars()

		-- in combat lockdown?
		if (InCombatLockdown()) then
			-- create overlays later
			createOverlays[bar] = true
		else
			-- create bar overlay
			NS:Create_Bar_Overlay(bar)
		end
	end
end

-- add / update bar
function NS:Capping_Add_Update_Bar(name, remaining, icon, colorid, priority, maxBarTime)
	-- stop previous bars
	NS:Capping_Stop_Bars(name)

	-- add new bar
	NS:Capping_Add_New_Bar(name, remaining, icon, colorid, priority, maxBarTime)
end

-- event handler
local function OnEvent(self, event, ...)
	-- PLAYER_REGEN_ENABLED?
	if (event == "PLAYER_REGEN_ENABLED") then
		-- has overlays to create?
		if (next(createOverlays)) then
			-- process all
			for bar,v in pairs(createOverlays) do
				-- still shown?
				if (bar:IsShown()) then
					-- create bar overlay
					NS:Create_Bar_Overlay(bar)
				end
			end

			-- reset
			wipe(createOverlays)
		end
	end
end

-- event frame
local f = CreateFrame("Frame", nil, UIParent)
f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:SetScript("OnEvent", OnEvent)

-- fully loaded
NS.LoadCount = NS.LoadCount + 1
NS.Loaded["Capping"] = NS.LoadCount
