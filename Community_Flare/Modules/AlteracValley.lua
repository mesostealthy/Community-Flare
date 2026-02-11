-- initialize
local LibStub = LibStub
local ADDON_NAME, NS = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
if (not L or not NS.CommFlare) then return end

-- localize stuff
local _G                                          = _G

-- initialize
function NS:AV_Initialize()
	-- reset stuff
	NS.CommFlare.CF.AV.LeftGained = 0
	NS.CommFlare.CF.AV.PrevLeftScore = -1
	NS.CommFlare.CF.AV.PrevRightScore = -1
	NS.CommFlare.CF.AV.RightGained = 0
end

-- process alterac valley widget
function NS:Process_AlteracValley_Widget(info)
	-- get widget data
	if (NS.faction ~= 0) then return end
	local data = NS:GetWidgetData(info)
	if (data) then
		-- score remaining?
		if (data.widgetID == 1684) then
			-- first left score?
			if (NS.CommFlare.CF.AV.PrevLeftScore < 0) then
				-- initialize
				NS.CommFlare.CF.AV.PrevLeftScore = data.leftBarValue
			else
				-- increased?
				if (data.leftBarValue > NS.CommFlare.CF.AV.PrevLeftScore) then
					-- increase
					NS.CommFlare.CF.AV.LeftGained = NS.CommFlare.CF.AV.LeftGained + 1
				end

				-- update
				NS.CommFlare.CF.AV.PrevLeftScore = data.leftBarValue
			end

			-- first right scorie?
			if (NS.CommFlare.CF.AV.PrevRightScore < 0) then
				-- initialize
				NS.CommFlare.CF.AV.PrevRightScore = data.rightBarValue
			else
				-- increased?
				if (data.rightBarValue > NS.CommFlare.CF.AV.PrevRightScore) then
					-- increase
					NS.CommFlare.CF.AV.RightGained = NS.CommFlare.CF.AV.RightGained + 1
				end

				-- update
				NS.CommFlare.CF.AV.PrevRightScore = data.rightBarValue
			end
		end
	end
end
