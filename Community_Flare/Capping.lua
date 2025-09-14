-- initialize
local LibStub = LibStub
local ADDON_NAME, NS = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
if (not L or not NS.CommFlare) then return end

-- localize stuff
local _G                                        = _G
local pairs                                     = _G.pairs
local print                                     = _G.print
local type                                      = _G.type
local unpack                                    = _G.unpack
local strformat                                 = _G.string.format
local tsort                                     = _G.table.sort

-- list bars
function NS:Capping_List_Bars()
	-- has capping?
	if (CappingFrame) then
		-- process all
		for bar,_ in pairs(CappingFrame.bars) do
			-- print label
			print(strformat("Bar: %s", bar:GetLabel()))
		end
	end
end

-- refresh bars
function NS:Capping_Refresh_Bars()
	-- has capping?
	if (CappingFrame) then
		-- rearrange bars
		CappingFrame.RearrangeBars()
	end
end

-- find bar
function NS:Capping_Find_Bar(name, exact)
	-- has capping?
	if (CappingFrame) then
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
	if (CappingFrame) then
		-- process all
		local refresh = false
		for bar,_ in pairs(CappingFrame.bars) do
			-- get label
			local label = bar:GetLabel()
			if (label) then
				-- matches?
				if (label:find(name)) then
					-- stop
					refresh = true
					bar:Stop()
				end
			end
		end

		-- should refresh?
		if (refresh == true) then
			-- rearrange bars
			CappingFrame.RearrangeBars()
		end
	end
end

-- report bar
local function ReportBar(bar, channel)
	-- sanity checks
	if (not bar) then return end
	if ((channel == "INSTANCE_CHAT") and not IsInGroup(2)) then channel = "RAID" end -- LE_PARTY_CATEGORY_INSTANCE = 2

	-- no custom chat message?
	local custom = bar:Get("capping:customchat")
	if (not custom) then
		-- send chat message
		local colorid = bar:Get("capping:colorid")
		local faction = colorid == "colorHorde" and _G.FACTION_HORDE or colorid == "colorAlliance" and _G.FACTION_ALLIANCE or ""
		local timeLeft = bar.candyBarDuration:GetText()
		if (not timeLeft:find("[:%.]")) then timeLeft = "0:" .. timeLeft end
		SendChatMessage(strformat("CommFlare: %s - %s %s", bar:GetLabel(), timeLeft, faction == "" and faction or "(" .. faction .. ")"), channel)
	else
		-- get custom message
		local msg = custom(bar)
		if (msg) then
			-- send chat message
			SendChatMessage(format("CommFlare: %s", msg), channel)
		end
	end
end

-- bar clicked script
local function BarOnClick(bar)
	-- has capping?
	if (CappingFrame) then
		-- shift key pressed / allowed?
		if (IsShiftKeyDown() and (CappingFrame.db.profile.barOnShift ~= "NONE")) then
			ReportBar(bar, CappingFrame.db.profile.barOnShift)
		-- control key pressed / allowed?
		elseif (IsControlKeyDown() and (CappingFrame.db.profile.barOnControl ~= "NONE")) then
			ReportBar(bar, CappingFrame.db.profile.barOnControl)
		-- alt key pressed / allowed?
		elseif (IsAltKeyDown() and (CappingFrame.db.profile.barOnAlt ~= "NONE")) then
			ReportBar(bar, CappingFrame.db.profile.barOnAlt)
		end
	end
end

-- add new bar
function NS:Capping_Add_New_Bar(name, remaining, colorid, icon, priority, maxBarTime)
	-- no name given?
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
	if (CappingFrame) then
		-- get settings
		local height = CappingFrame.db.profile.height or 200
		local width = CappingFrame.db.profile.width or 20

		-- create new bar
		local texture = "Interface\\RAIDFRAME\\Raid-Bar-Hp-Fill.blp"
		local bar = NS.Libs.LibCandyBar:New(texture, width, height)
		if (not bar) then
			-- finished
			return
		end

		-- add into active bars
		local activeBars = CappingFrame.bars
		activeBars[bar] = true

		-- has colorid?
		if (colorid) then
			-- save colorid
			bar:Set("capping:colorid", colorid)

			-- has color value?
			if (CappingFrame.db.profile[colorid]) then
				-- set colors
				bar:SetColor(unpack(CappingFrame.db.profile[colorid]))
				bar.candyBarBackground:SetVertexColor(unpack(CappingFrame.db.profile.colorBarBackground))
				bar:SetTextColor(unpack(CappingFrame.db.profile.colorText))
			end
		end

		-- has priority?
		if (priority) then
			-- save priority
			bar:Set("capping:priority", priority)
		end

		-- set parent / label / duration
		bar:SetParent(CappingFrame)
		bar:SetLabel(name)
		bar.candyBarLabel:SetJustifyH(CappingFrame.db.profile.alignText)
		bar:SetDuration(remaining)
		bar.candyBarDuration:SetJustifyH(CappingFrame.db.profile.alignTime)

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

		-- setup bar click script
		bar:SetScript("OnMouseUp", BarOnClick)
		if ((CappingFrame.db.profile.barOnShift ~= "NONE") or (CappingFrame.db.profile.barOnControl ~= "NONE") or (CappingFrame.db.profile.barOnAlt ~= "NONE")) then
			-- enable mouse
			bar:EnableMouse(true)
		else
			-- disable mouse
			bar:EnableMouse(false)
		end

		-- start
		bar:Start(maxBarTime)

		-- rearrange bars
		CappingFrame.RearrangeBars()
	end
end
