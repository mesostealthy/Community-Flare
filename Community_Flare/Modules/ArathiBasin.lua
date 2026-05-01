-- initialize
local LibStub = LibStub
local ADDON_NAME, NS = ...
if (not NS.Loaded or not NS.Loaded["TomTom"]) then return end
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
if (not L or not NS.CommFlare) then return end

-- localize stuff
local _G                                          = _G

-- add REPorter callouts
function NS:REPorter_ArathiBasin_Add_Callouts()
	-- add new overlays
	if (NS.faction ~= 0) then return end
	NS:REPorter_Add_New_Overlay("Blacksmith")
	NS:REPorter_Add_New_Overlay("Farm")
	NS:REPorter_Add_New_Overlay("Gold Mine")
	NS:REPorter_Add_New_Overlay("Lumber Mill")
	NS:REPorter_Add_New_Overlay("Stables")
end

-- fully loaded
NS.LoadCount = NS.LoadCount + 1
NS.Loaded["ArathiBasin"] = NS.LoadCount
