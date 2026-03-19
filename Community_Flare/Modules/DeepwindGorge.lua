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
function NS:REPorter_DeepwindGorge_Add_Callouts()
	-- in combat lockdown?
	if (NS.faction ~= 0) then return end
	if (InCombatLockdown()) then
		-- update last raid warning
		TimerAfter(5, function()
			-- call again
			NS:REPorter_DeepwindGorge_Add_Callouts()
		end)

		-- finished
		return
	end

	-- add new overlays
	NS:REPorter_Add_New_Overlay("Farm")
	NS:REPorter_Add_New_Overlay("Market")
	NS:REPorter_Add_New_Overlay("Quarry")
	NS:REPorter_Add_New_Overlay("Ruins")
	NS:REPorter_Add_New_Overlay("Shrine")
end
