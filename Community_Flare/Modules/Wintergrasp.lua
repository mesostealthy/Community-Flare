-- initialize
local LibStub = LibStub
local ADDON_NAME, NS = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
if (not L or not NS.CommFlare) then return end

-- localize stuff
local _G                                          = _G
local InCombatLockdown                            = _G.InCombatLockdown
local TimerAfter                                  = _G.C_Timer.After

-- add REPorter callouts
function NS:REPorter_Wintergrasp_Add_Callouts()
	-- in combat lockdown?
	if (InCombatLockdown()) then
		-- update last raid warning
		TimerAfter(5, function()
			-- call again
			NS:REPorter_Wintergrasp_Add_Callouts()
		end)

		-- finished
		return
	end

	-- add new overlays
	NS:REPorter_Add_New_Overlay("Broken Temple Vehicle Workshop")
	NS:REPorter_Add_New_Overlay("Eastspark Vehicle Workshop")
	NS:REPorter_Add_New_Overlay("Sunken Ring Vehicle Workshop")
	NS:REPorter_Add_New_Overlay("Westspark Vehicle Workshop")
end
