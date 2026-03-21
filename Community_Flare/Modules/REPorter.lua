-- initialize
local LibStub = LibStub
local ADDON_NAME, NS = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
if (not L or not NS.CommFlare) then return end

-- localize stuff
local _G                                          = _G
local CreateFrame                                 = _G.CreateFrame
local InCombatLockdown                            = _G.InCombatLockdown

-- local variables
NS.REPorterOverlayCache = {}
local hook_REPorter_OnPOIUpdate_installed = false

-- add new overlay
function NS:REPorter_Add_New_Overlay(name)
	-- REPorter not loaded?
	if (NS.faction ~= 0) then return end
	if (not REPorter) then
		-- failed
		return false
	end

	-- not in combat lockdown?
	if (not InCombatLockdown()) then
		-- has REPorter POINodes?
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

				-- has frame + Overlay?
				local frame = _G["REPorterFrameCorePOI" .. info.id]
				if (frame and frame.Overlay) then
					-- finalize overlay setup
					frame.Overlay:ClearAllPoints()
					frame.Overlay:SetPoint("CENTER", "REPorterFrameCorePOI", "TOPLEFT", info.x, info.y)
				        frame.Overlay:SetAttribute("type1", "macro")
					local macrotext1 = "/i INCOMING: " .. info.name
				        frame.Overlay:SetAttribute("macrotext1", macrotext1)
				        frame.Overlay:SetAttribute("type2", "macro")
					local macrotext2 = "/i CLEAR: " .. info.name
				        frame.Overlay:SetAttribute("macrotext2", macrotext2)
				        frame.Overlay:SetAttribute("shift-type1", "macro")
					local macrotext3 = "/i ATTACK: " .. info.name
				        frame.Overlay:SetAttribute("shift-macrotext1", macrotext3)
				        frame.Overlay:SetAttribute("shift-type2", "macro")
					local macrotext4 = "/i DEFEND: " .. info.name
				        frame.Overlay:SetAttribute("shift-macrotext2", macrotext4)
				        frame.Overlay:SetAttribute("alt-type1", "macro")
					local macrotext5 = "/i HELP: " .. info.name
				        frame.Overlay:SetAttribute("alt-macrotext1", macrotext5)
				        frame.Overlay:SetAttribute("alt-type2", "macro")
					local macrotext6 = "/i ON MY WAY: " .. info.name
				        frame.Overlay:SetAttribute("alt-macrotext2", macrotext6)
				        frame.Overlay:SetScript("OnEnter", function(self)
						-- has reporter + frame + IsShown + has node?
						if (REPorter and frame and frame.name and frame:IsShown() and REPorter.POINodes[frame.name]) then
							-- show tooltip
							REPorter:UnitOnEnterPOI(frame)
							GameTooltip:AddLine("Left Click: INCOMING", 1, 1, 1)
							GameTooltip:AddLine("Right Click: CLEAR", 1, 1, 1)
							GameTooltip:AddLine("Shift+Left Click: ATTACK", 1, 1, 1)
							GameTooltip:AddLine("Shift+Right Click: DEFEND", 1, 1, 1)
							GameTooltip:AddLine("Alt+Left Click: HELP", 1, 1, 1)
							GameTooltip:AddLine("Alt+Right Click: ON MY WAY", 1, 1, 1)
							GameTooltip:Show()
						end
					end)
				        frame.Overlay:SetScript("OnLeave", function() GameTooltip:Hide() end)
					NS.REPorterOverlayCache[name] = frame
					frame.Overlay:Show()
					return true
				end
			end
		end
	end

	-- failed
	return false
end

-- hook REPorter:OnPOIUpdate
local function hook_REPorter_OnPOIUpdate()
	-- has REPorter?
	if (NS.faction ~= 0) then return end
	if (REPorter) then
		-- no map?
		if (REPorter.CurrentMap == -1) then
			-- reset
			NS.REPorterOverlayCache = {}
		else
			-- alterac valley?
			if (REPorter.CurrentMap == 91) then
				-- add callouts
				NS:REPorter_AlteracValley_Add_Callouts()
			-- eye of the storm?
			elseif (REPorter.CurrentMap == 112) then
				-- add callouts
				NS:REPorter_EyeOfTheStorm_Add_Callouts()
			-- isle of conquest?
			elseif (REPorter.CurrentMap == 169) then
				-- add callouts
				NS:REPorter_IsleOfConquest_Add_Callouts()
			-- battle for gilneas?
			elseif (REPorter.CurrentMap == 275) then
				-- add callouts
				NS:REPorter_Gilneas_Add_Callouts()
			-- battle for wintergrasp?
			elseif (REPorter.CurrentMap == 1334) then
				-- add callouts
				NS:REPorter_Wintergrasp_Add_Callouts()
			-- arathi basin?
			elseif (REPorter.CurrentMap == 1366) then
				-- add callouts
				NS:REPorter_ArathiBasin_Add_Callouts()
				-- ashran?
			elseif (REPorter.CurrentMap == 1478) then
				-- add callouts
				NS:REPorter_Ashran_Add_Callouts()
			-- deepwind gorge?
			elseif (REPorter.CurrentMap == 1576) then
				-- add callouts
				NS:REPorter_DeepwindGorge_Add_Callouts()
			-- slayers rise?
			elseif (REPorter.CurrentMap == 2397) then
				-- add callouts
				NS:REPorter_SlayersRise_Add_Callouts()
			end
		end
	end
end

-- setup hooks
local REPorter_hooks_installed = nil
function NS:REPorter_SetupHooks()
	-- has REPorter?
	if (NS.faction ~= 0) then return end
	if (REPorter) then
		-- not installed yet?
		if (not REPorter_hooks_installed) then
			-- process all
			for i=1, REPorter.POINumber do
				-- disable REPorter default tooltip
				local frame = _G["REPorterFrameCorePOI" .. i]
				frame:SetScript("OnEnter", function(self) end)
				frame:SetScript("OnLeave", function() end)

				-- create overlay frame
				frame.Overlay = CreateFrame("Button", nil, REPorterFrame, "SecureActionButtonTemplate")
			        frame.Overlay:SetFrameLevel(128)
			        frame.Overlay:RegisterForClicks("AnyUp", "AnyDown")
			        frame.Overlay:SetHeight(REPorter.POIIconSize)
			        frame.Overlay:SetWidth(REPorter.POIIconSize)
			end

			-- REPorter:OnPOIUpdate() not hooked?
			if (hook_REPorter_OnPOIUpdate_installed ~= true) then
				-- hook REPorter:OnPOIUpdate
				hooksecurefunc(REPorter, "OnPOIUpdate", hook_REPorter_OnPOIUpdate)
				hook_REPorter_OnPOIUpdate_installed = true
			end

			-- installed
			REPorter_hooks_installed = true
		end

		-- process all
		for i=1, REPorter.POINumber do
			-- valid frame?
			local frame = _G["REPorterFrameCorePOI" .. i]
			if (frame) then
				-- not shown?
				if (not frame:IsShown()) then
					-- has overlay?
					if (frame.Overlay) then
						-- disable + hide
						frame.Overlay:SetScript("OnEnter", nil)
						frame.Overlay:SetScript("OnLeave", nil)
						frame.Overlay:Hide()
					end
				else
					-- show
					frame.Overlay:Show()
				end
			end
		end

	end
end
