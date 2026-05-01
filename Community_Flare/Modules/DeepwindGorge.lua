-- initialize
local LibStub = LibStub
local ADDON_NAME, NS = ...
if (not NS.Loaded or not NS.Loaded["TomTom"]) then return end
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
if (not L or not NS.CommFlare) then return end

-- localize stuff
local _G                                          = _G

-- add REPorter callouts
function NS:REPorter_DeepwindGorge_Add_Callouts()
	-- add new overlays
	if (NS.faction ~= 0) then return end
	NS:REPorter_Add_New_Overlay("Farm")
	NS:REPorter_Add_New_Overlay("Market")
	NS:REPorter_Add_New_Overlay("Quarry")
	NS:REPorter_Add_New_Overlay("Ruins")
	NS:REPorter_Add_New_Overlay("Shrine")
end

-- fully loaded
NS.LoadCount = NS.LoadCount + 1
NS.Loaded["DeepwindGorge"] = NS.LoadCount
