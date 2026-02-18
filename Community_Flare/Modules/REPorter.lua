-- initialize
local LibStub = LibStub
local ADDON_NAME, NS = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
if (not L or not NS.CommFlare) then return end

-- localize stuff
local _G                                          = _G
local CreateFrame                                 = _G.CreateFrame
local InCombatLockdown                            = _G.InCombatLockdown

-- local variables
NS.REPorterOverlayCache = {}
local hook_REPorter_OnPOIUpdate_installed = false

-- add new overlay
function NS:REPorter_Add_New_Overlay(name)
	-- REPorter not loaded?
	if (NS.faction ~= 0) then return end
	if (not REPorter) then
		-- failed
		return false
	end

	-- not in combat lockdown?
	if (not InCombatLockdown()) then
		-- has REPorter POINodes?
		if (REPorter.POINodes and REPorter.POINodes[name]) then
			-- found info?
			local info = REPorter.POINodes[name]
			if (info and info.id and info.name and info.x and info.y) then
				-- check scale
				local scale = REPorterFrameCore:GetScale()
				if (scale ~= 1) then
					-- force 1
					REPorterFrameCore:SetScale(1)
				end

				-- create button
				local frame = _G["REPorterFrameCorePOI" .. info.id]
				local overlayName = "REPorterFrameCorePOI" .. info.id .. "Overlay"
				frame.Overlay = frame.Overlay or CreateFrame("Button", overlayName, REPorterFrame, "SecureActionButtonTemplate")
			        frame.Overlay:SetFrameLevel(128)
			        frame.Overlay:RegisterForClicks("AnyUp", "AnyDown")
			        frame.Overlay:SetHeight(REPorter.POIIconSize)
			        frame.Overlay:SetWidth(REPorter.POIIconSize)
				frame.Overlay:SetPoint("CENTER", "REPorterFrameCorePOI", "TOPLEFT", info.x, info.y)
			        frame.Overlay:SetAttribute("type1", "macro")
				local macrotext1 = "/i INCOMING " .. info.name
			        frame.Overlay:SetAttribute("macrotext1", macrotext1)
			        frame.Overlay:SetAttribute("type2", "macro")
				local macrotext2 = "/i CLEAR " .. info.name
			        frame.Overlay:SetAttribute("macrotext2", macrotext2)
			        frame.Overlay:SetAttribute("shift-type1", "macro")
				local macrotext3 = "/i ATTACK " .. info.name
			        frame.Overlay:SetAttribute("shift-macrotext1", macrotext3)
			        frame.Overlay:SetAttribute("shift-type2", "macro")
				local macrotext4 = "/i DEFEND " .. info.name
			        frame.Overlay:SetAttribute("shift-macrotext2", macrotext4)
			        frame.Overlay:SetAttribute("alt-type2", "macro")
				local macrotext5 = "/i ON MY WAY " .. info.name
			        frame.Overlay:SetAttribute("alt-macrotext2", macrotext5)
			        frame.Overlay:SetScript("OnEnter", function(self)
					REPorter:UnitOnEnterPOI(frame)
					GameTooltip:AddLine("Left Click: INCOMING", 1, 1, 1)
					GameTooltip:AddLine("Right Click: CLEAR", 1, 1, 1)
					GameTooltip:AddLine("Shift+Left Click: ATTACK", 1, 1, 1)
					GameTooltip:AddLine("Shift+Right Click: DEFEND", 1, 1, 1)
					GameTooltip:AddLine("Alt+Right Click: ON MY WAY", 1, 1, 1)
					GameTooltip:Show()
				end)
			        frame.Overlay:SetScript("OnLeave", function() GameTooltip:Hide() end)
				NS.REPorterOverlayCache[name] = frame
				return true
			end
		end
	end

	-- failed
	return false
end

-- hook REPorter:OnPOIUpdate
local function hook_REPorter_OnPOIUpdate()
	-- has REPorter?
	if (NS.faction ~= 0) then return end
	if (REPorter) then
		-- no map?
		if (REPorter.CurrentMap == -1) then
			-- reset
			NS.REPorterOverlayCache = {}
		else
			-- alterac valley?
			if (REPorter.CurrentMap == 91) then
				-- add callouts
				NS:REPorter_AlteracValley_Add_Callouts()
			-- eye of the storm?
			elseif (REPorter.CurrentMap == 112) then
				-- add callouts
				NS:REPorter_EyeOfTheStorm_Add_Callouts()
			-- isle of conquest?
			elseif (REPorter.CurrentMap == 169) then
				-- add callouts
				NS:REPorter_IsleOfConquest_Add_Callouts()
			-- battle for gilneas?
			elseif (REPorter.CurrentMap == 275) then
				-- add callouts
				NS:REPorter_Gilneas_Add_Callouts()
			-- battle for wintergrasp?
			elseif (REPorter.CurrentMap == 1334) then
				-- add callouts
				NS:REPorter_Wintergrasp_Add_Callouts()
			-- arathi basin?
			elseif (REPorter.CurrentMap == 1366) then
				-- add callouts
				NS:REPorter_ArathiBasin_Add_Callouts()
				-- ashran?
			elseif (REPorter.CurrentMap == 1478) then
				-- add callouts
				NS:REPorter_Ashran_Add_Callouts()
			-- deepwind gorge?
			elseif (REPorter.CurrentMap == 1576) then
				-- add callouts
				NS:REPorter_DeepwindGorge_Add_Callouts()
			end
		end
	end
end

-- setup hooks
function NS:REPorter_SetupHooks()
	-- has REPorter?
	if (NS.faction ~= 0) then return end
	if (REPorter) then
		-- REPorter:OnPOIUpdate() not hooked?
		if (hook_REPorter_OnPOIUpdate_installed ~= true) then
			-- hook REPorter:OnPOIUpdate
			hooksecurefunc(REPorter, "OnPOIUpdate", hook_REPorter_OnPOIUpdate)
			hook_REPorter_OnPOIUpdate_installed = true
		end
	end
end
