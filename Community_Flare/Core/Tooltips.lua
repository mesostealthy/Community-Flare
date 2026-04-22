-- initialize
local LibStub = LibStub
local ADDON_NAME, NS = ...
if (not NS.Loaded or not NS.Loaded["StaticPopups"]) then return end
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
if (not L or not NS.CommFlare) then return end
 
-- localize stuff
local _G                                          = _G
local CreateFrame                                 = _G.CreateFrame
local UnitPercentHealthFromGUID                   = _G.UnitPercentHealthFromGUID
local hooksecurefunc                              = _G.hooksecurefunc
local issecretvalue                               = _G.issecretvalue

-- create tooltip frame
local hook_GameTooltipStatusBar_UpdateUnitHealth_installed = false
function NS:CreateTooltipFrame()
	-- already installed?
	if (hook_GameTooltipStatusBar_UpdateUnitHealth_installed) then
		-- finished
		return
	end

	-- create frame
	local frame = CreateFrame("Frame", nil, GameTooltipStatusBar)
	frame.Text = frame:CreateFontString(nil, "ARTWORK", nil, 2)
	frame.Text:SetFont(NS.Libs.LibSharedMedia:Fetch("font", "Roboto Condensed BoldItalic"), 12, "OUTLINE")
	frame.Text:SetPoint("CENTER", GameTooltipStatusBar, "CENTER", 0, 0)
	frame.Text:SetSize(150, 20)
	frame.Text:SetTextColor(1, 1, 1, 1)
	frame.Text:SetJustifyH("CENTER")
	frame.Text:SetText("")

	-- hook GameTooltipStatusBar:UpdateUnitHealth()
	hooksecurefunc(GameTooltipStatusBar, "UpdateUnitHealth", function()
		-- clear text
		frame.Text:SetText("")

		-- check guid
		local guid = GameTooltipStatusBar:GetAttribute("guid");
		if (guid and not issecretvalue(guid) and guid:find("GameObject")) then
			-- update text
			local hpPercent = UnitPercentHealthFromGUID(guid)
			if (hpPercent) then
				-- set text
				hpPercent = NS:AbbreviateFloatPercentage(hpPercent)
				frame.Text:SetText(hpPercent)
			end
		end
	end)

	-- installed
	hook_GameTooltipStatusBar_UpdateUnitHealth_installed = true
end

-- fully loaded
NS.LoadCount = NS.LoadCount + 1
NS.Loaded["Tooltips"] = NS.LoadCount
