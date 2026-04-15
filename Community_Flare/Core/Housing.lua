-- initialize
local LibStub = LibStub
local ADDON_NAME, NS = ...
if (not NS.Loaded or not NS.Loaded["History"]) then return end
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
if (not L or not NS.CommFlare) then return end

-- localize stuff
local _G                                          = _G
local CreateFrame                                 = _G.CreateFrame
local strformat                                   = _G.string.format

-- create member count frame
local member_count_frame = nil
local function CreateMemberCountFrame()
	-- not created yet?
	if (not member_count_frame) then
		-- create frame
		member_count_frame = CreateFrame("Frame", nil, HousingBulletinBoardFrame)
		member_count_frame.Text = member_count_frame:CreateFontString(nil, "ARTWORK", nil, 2)
		member_count_frame.Text:SetFont(NS.Libs.LibSharedMedia:Fetch("font", "Roboto Condensed BoldItalic"), 12, "OUTLINE")
		member_count_frame.Text:SetPoint("TOPLEFT", HousingBulletinBoardFrame, "TOPLEFT", -10, -10)
		member_count_frame.Text:SetSize(150, 20)
		member_count_frame.Text:SetTextColor(1, 1, 1, 1)
		member_count_frame.Text:SetJustifyH("CENTER")
	end
end

-- event handler
local function OnEvent(self, event, ...)
	-- PLAYER_INTERACTION_MANAGER_FRAME_SHOW?
	if (event == "PLAYER_INTERACTION_MANAGER_FRAME_SHOW") then
		local frameType = ...

		-- housing bulletin board?
		if (frameType == Enum.PlayerInteractionType.HousingBulletinBoard) then
			-- create member count frame
			CreateMemberCountFrame()

			-- has member count frame?
			if (member_count_frame) then
				-- get neighborhood data
				local mapData = C_HousingNeighborhood.GetNeighborhoodMapData()
				if (mapData and (#mapData > 0)) then
					-- update text
					local text = strformat("Total Members: %d", #mapData)
					member_count_frame.Text:SetText(text)
				end
			end
		end
	end
end

-- create frame
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_SHOW")
frame:SetScript("OnEvent", OnEvent)

-- fully loaded
NS.LoadCount = NS.LoadCount + 1
NS.Loaded["Housing"] = NS.LoadCount
