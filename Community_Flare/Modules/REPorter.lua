-- initialize
local LibStub = LibStub
local ADDON_NAME, NS = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
if (not L or not NS.CommFlare) then return end

-- localize stuff
local _G                                          = _G
local CreateFrame                                 = _G.CreateFrame

-- add new overlay
function NS:REPorter_Add_New_Overlay(name)
	-- has REPorter node?
	if (REPorter.POINodes and REPorter.POINodes[name]) then
		-- found info?
		local info = REPorter.POINodes[name]
		if (info and info.id and info.name and info.x and info.y) then
			-- create button
			local frame = _G["REPorterFrameCorePOI" .. info.id]
			if (not frame.Overlay) then
				-- create button
				frame.Overlay = CreateFrame("Button", "REPorterFrameCorePOI" .. info.id .. "Overlay", REPorterFrame, "SecureActionButtonTemplate")
				frame.Overlay:SetFrameLevel(128)
				frame.Overlay:RegisterForClicks("AnyDown", "AnyUp")
				frame.Overlay:SetPoint("CENTER", "REPorterFrameCorePOI", "TOPLEFT", info.x, info.y)
				frame.Overlay:SetWidth(REPorter.POIIconSize)
				frame.Overlay:SetHeight(REPorter.POIIconSize)
				frame.Overlay:SetAttribute("type1", "macro")
				frame.Overlay:SetAttribute("macrotext1", "/s INCOMING " .. info.name)
				frame.Overlay:SetAttribute("type2", "macro")
				frame.Overlay:SetAttribute("macrotext2", "/s CLEAR " .. info.name)
				frame.Overlay:SetScript("OnEnter", function(self) REPorter:UnitOnEnterPOI(frame) end)
				frame.Overlay:SetScript("OnLeave", function() GameTooltip:Hide() end)
			end
		end
	end
end
