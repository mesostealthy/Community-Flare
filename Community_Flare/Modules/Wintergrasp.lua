-- initialize
local LibStub = LibStub
local ADDON_NAME, NS = ...
if (not NS.Loaded or not NS.Loaded["TomTom"]) then return end
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
if (not L or not NS.CommFlare) then return end

-- localize stuff
local _G                                          = _G

-- add REPorter callouts
function NS:REPorter_Wintergrasp_Add_Callouts()
	-- add new overlays
	if (NS.faction ~= 0) then return end
	NS:REPorter_Add_New_Overlay("Broken Temple Vehicle Workshop")
	NS:REPorter_Add_New_Overlay("Eastspark Vehicle Workshop")
	NS:REPorter_Add_New_Overlay("Flamewatch Tower")
	NS:REPorter_Add_New_Overlay("Shadowsight Tower")
	NS:REPorter_Add_New_Overlay("Sunken Ring Vehicle Workshop")
	NS:REPorter_Add_New_Overlay("Westspark Vehicle Workshop")
	NS:REPorter_Add_New_Overlay("Winter's Edge Tower")
end

-- fully loaded
NS.LoadCount = NS.LoadCount + 1
NS.Loaded["Wintergrasp"] = NS.LoadCount
