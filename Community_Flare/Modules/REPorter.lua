-- initialize
local LibStub = LibStub
local ADDON_NAME, NS = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
if (not L or not NS.CommFlare) then return end

-- localize stuff
local _G                                          = _G
local CreateFrame                                 = _G.CreateFrame
local InCombatLockdown                            = _G.InCombatLockdown

-- add new overlay
function NS:REPorter_Add_New_Overlay(name)
	-- not in combat lockdown?
	if (not InCombatLockdown()) then
		-- has REPorter node?
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
			        frame.Overlay:SetScript("OnEnter", function(self) REPorter:UnitOnEnterPOI(frame) end)
			        frame.Overlay:SetScript("OnLeave", function() GameTooltip:Hide() end)
				return true
			end
		end
	end

	-- failed
	return false
end
