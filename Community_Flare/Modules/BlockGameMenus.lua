-- initialize
local LibStub = LibStub
local ADDON_NAME, NS = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
if (not L or not NS.CommFlare) then return end

-- localize stuff
local _G                                          = _G
local AchievementFrame_LoadUI                     = _G.AchievementFrame_LoadUI
local CollectionsJournal_LoadUI                   = _G.CollectionsJournal_LoadUI
local Communities_LoadUI                          = _G.Communities_LoadUI
local EncounterJournal_LoadUI                     = _G.EncounterJournal_LoadUI
local HideUIPanel                                 = _G.HideUIPanel
local InCombatLockdown                            = _G.InCombatLockdown
local PlayerSpellsFrame_LoadUI                    = _G.PlayerSpellsFrame_LoadUI
local ProfessionsBook_LoadUI                      = _G.ProfessionsBook_LoadUI
local AddOnsLoadAddOn                             = _G.C_AddOns.LoadAddOn
local PvPIsArena                                  = _G.C_PvP.IsArena
local PvPIsInBrawl                                = _G.C_PvP.IsInBrawl
local print                                       = _G.print

-- local variables
local hook_GroupFinder_installed = false
local hook_MainMenuMicroButton_installed = false
local hook_ToggleAchievementFrame_installed = false
local hook_ToggleCharacter_installed = false
local hook_ToggleCollectionsJournal_installed = false
local hook_ToggleEncounterJournal_installed = false
local hook_ToggleFriendsFrame_installed = false
local hook_ToggleGuildFrame_installed = false
local hook_ToggleHousingDashboard_installed = false
local hook_TogglePlayerSpellsFrame_installed = false
local hook_ToggleProfessionsBook_installed = false

-- process group finder micro button clicked
local function hook_LFDMicroButton_OnClick(self, ...)
	-- block game menu hot keys enabled?
	if (NS.charDB.profile.blockGameMenuHotKeys == true) then
		-- allowed
		NS.CommFlare.CF.AllowGroupFinderFrame = true
	end

	-- not in combat lockdown?
	if (InCombatLockdown() ~= true) then
		-- call original
		NS.CommFlare.hooks[LFDMicroButton].OnClick(self, ...)
	else
		-- always normal
		LFDMicroButton:SetNormal()
	end
end

-- process group finder toggle
local function hook_PVEFrame_ToggleFrame(sidePanelName, selection)
	-- block game menu hot keys enabled?
	if (NS.charDB.profile.blockGameMenuHotKeys == true) then
		-- not shown?
		local isShown = PVEFrame:IsShown()
		if (isShown == false) then
			-- not allowed?
			if (NS.CommFlare.CF.AllowGroupFinderFrame == false) then
				-- inside pvp content?
				local isArena = PvPIsArena()
				local isBrawl = PvPIsInBrawl()
				local isBattleground = NS:IsInBattleground()
				if (isArena or isBattleground or isBrawl) then
					-- finished
					return
				end
			end
		end	

		-- disabled
		NS.CommFlare.CF.AllowGroupFinderFrame = false
	end

	-- not in combat lockdown?
	if (InCombatLockdown() ~= true) then
		-- call original
		NS.CommFlare.hooks["PVEFrame_ToggleFrame"](sidePanelName, selection)
	end
end

-- process main menu micro button on mouse down
local function hook_MainMenuMicroButton_OnMouseDown()
	-- block game menu hot keys enabled?
	if (NS.charDB.profile.blockGameMenuHotKeys == true) then
		-- inside pvp content?
		local isArena = PvPIsArena()
		local isBrawl = PvPIsInBrawl()
		local isBattleground = NS:IsInBattleground()
		if (isArena or isBattleground or isBrawl) then
			-- enabled
			NS.CommFlare.CF.AllowMainMenu = true
		else
			-- disabled
			NS.CommFlare.CF.AllowMainMenu = false
		end
	end
end

-- process game menu on show
local function hook_GameMenuFrame_OnShow()
	-- block game menu hot keys enabled?
	if (NS.charDB.profile.blockGameMenuHotKeys == true) then
		-- inside pvp content?
		local isArena = PvPIsArena()
		local isBrawl = PvPIsInBrawl()
		local isBattleground = NS:IsInBattleground()
		if (isArena or isBattleground or isBrawl) then
			-- blocked?
			if (NS.CommFlare.CF.AllowMainMenu ~= true) then
				-- not in combat?
				if (InCombatLockdown() ~= true) then
					-- hide
					HideUIPanel(GameMenuFrame)
				end
			end
		end

		-- disabled
		NS.CommFlare.CF.AllowMainMenu = false
	end
end

-- process game menu on hide
local function hook_GameMenuFrame_OnHide()
	-- block game menu hot keys enabled?
	if (NS.charDB.profile.blockGameMenuHotKeys == true) then
		-- disabled
		NS.CommFlare.CF.AllowMainMenu = false
	end
end

-- process achievement micro button clicked
local function hook_AchievementMicroButton_OnClick(self, ...)
	-- block game menu hot keys enabled?
	if (NS.charDB.profile.blockGameMenuHotKeys == true) then
		-- allowed
		NS.CommFlare.CF.AllowAchievementFrame = true
	end

	-- not in combat lockdown?
	if (InCombatLockdown() ~= true) then
		-- call original
		NS.CommFlare.hooks[AchievementMicroButton].OnClick(self, ...)
	else
		-- always normal
		AchievementMicroButton:SetNormal()
	end
end

-- process achievement toggle
local function hook_ToggleAchievementFrame(stats)
	-- block game menu hot keys enabled?
	if (NS.charDB.profile.blockGameMenuHotKeys == true) then
		-- not loaded yet?
		if (not AchievementFrame) then
			-- load achievement framework
			AchievementFrame_LoadUI()
		end

		-- not shown?
		local isShown = AchievementFrame:IsShown()
		if (isShown == false) then
			-- not allowed?
			if (NS.CommFlare.CF.AllowAchievementFrame == false) then
				-- inside pvp content?
				local isArena = PvPIsArena()
				local isBrawl = PvPIsInBrawl()
				local isBattleground = NS:IsInBattleground()
				if (isArena or isBattleground or isBrawl) then
					-- finished
					return
				end
			end
		end	

		-- disabled
		NS.CommFlare.CF.AllowAchievementFrame = false
	end

	-- not in combat lockdown?
	if (InCombatLockdown() ~= true) then
		-- call original
		NS.CommFlare.hooks["ToggleAchievementFrame"](stats)
	end
end

-- process character micro button clicked
local function hook_CharacterMicroButton_OnClick(self, ...)
	-- block game menu hot keys enabled?
	if (NS.charDB.profile.blockGameMenuHotKeys == true) then
		-- allowed
		NS.CommFlare.CF.AllowCharacterFrame = true
	end

	-- not in combat lockdown?
	if (InCombatLockdown() ~= true) then
		-- call original
		NS.CommFlare.hooks[CharacterMicroButton].OnClick(self, ...)
	else
		-- always normal
		CharacterMicroButton:SetNormal()
	end
end

-- process character toggle
local function hook_ToggleCharacter(tab, onlyShow)
	-- block game menu hot keys enabled?
	if (NS.charDB.profile.blockGameMenuHotKeys == true) then
		-- not shown?
		local isShown = CharacterFrame:IsShown()
		if (isShown == false) then
			-- not allowed?
			if (NS.CommFlare.CF.AllowCharacterFrame == false) then
				-- inside pvp content?
				local isArena = PvPIsArena()
				local isBrawl = PvPIsInBrawl()
				local isBattleground = NS:IsInBattleground()
				if (isArena or isBattleground or isBrawl) then
					-- finished
					return
				end
			end
		end	

		-- disabled
		NS.CommFlare.CF.AllowCharacterFrame = false
	end

	-- not in combat lockdown?
	if (InCombatLockdown() ~= true) then
		-- call original
		NS.CommFlare.hooks["ToggleCharacter"](tab, onlyShow)
	end
end

-- process collections micro button clicked
local function hook_CollectionsMicroButton_OnClick(self, ...)
	-- block game menu hot keys enabled?
	if (NS.charDB.profile.blockGameMenuHotKeys == true) then
		-- allowed
		NS.CommFlare.CF.AllowCollectionsFrame = true
	end

	-- not in combat lockdown?
	if (InCombatLockdown() ~= true) then
		-- call original
		NS.CommFlare.hooks[CollectionsMicroButton].OnClick(self, ...)
	else
		-- always normal
		CollectionsMicroButton:SetNormal()
	end
end

-- process collections toggle
local function hook_ToggleCollectionsJournal(tabIndex)
	-- block game menu hot keys enabled?
	if (NS.charDB.profile.blockGameMenuHotKeys == true) then
		-- not loaded yet?
		if (not CollectionsJournal) then
			-- load collections framework
			CollectionsJournal_LoadUI()
		end

		-- not shown?
		local isShown = CollectionsJournal:IsShown()
		if (isShown == false) then
			-- not allowed?
			if (NS.CommFlare.CF.AllowCollectionsFrame == false) then
				-- inside pvp content?
				local isArena = PvPIsArena()
				local isBrawl = PvPIsInBrawl()
				local isBattleground = NS:IsInBattleground()
				if (isArena or isBattleground or isBrawl) then
					-- finished
					return
				end
			end
		end	

		-- disabled
		NS.CommFlare.CF.AllowCollectionsFrame = false
	end

	-- not in combat lockdown?
	if (InCombatLockdown() ~= true) then
		-- call original
		NS.CommFlare.hooks["ToggleCollectionsJournal"](tabIndex)
	end
end

-- process adventure guide micro button clicked
local function hook_EJMicroButton_OnClick(self, ...)
	-- block game menu hot keys enabled?
	if (NS.charDB.profile.blockGameMenuHotKeys == true) then
		-- allowed
		NS.CommFlare.CF.AllowAdvGuideFrame = true
	end

	-- not in combat lockdown?
	if (InCombatLockdown() ~= true) then
		-- call original
		NS.CommFlare.hooks[EJMicroButton].OnClick(self, ...)
	else
		-- always normal
		EJMicroButton:SetNormal()
	end
end

-- process adventure guide toggle
local function hook_ToggleEncounterJournal(tabIndex)
	-- block game menu hot keys enabled?
	if (NS.charDB.profile.blockGameMenuHotKeys == true) then
		-- not loaded yet?
		if (not EncounterJournal) then
			-- load adventure guide framework
			EncounterJournal_LoadUI()
		end

		-- not shown?
		local isShown = EncounterJournal:IsShown()
		if (isShown == false) then
			-- not allowed?
			if (NS.CommFlare.CF.AllowAdvGuideFrame == false) then
				-- inside pvp content?
				local isArena = PvPIsArena()
				local isBrawl = PvPIsInBrawl()
				local isBattleground = NS:IsInBattleground()
				if (isArena or isBattleground or isBrawl) then
					-- finished
					return
				end
			end
		end

		-- disabled
		NS.CommFlare.CF.AllowAdvGuideFrame = false
	end

	-- not in combat lockdown?
	if (InCombatLockdown() ~= true) then
		-- call original
		NS.CommFlare.hooks["ToggleEncounterJournal"](tabIndex)
	end
end

-- process friends toggle
local function hook_ToggleFriendsFrame(tab)
	-- block game menu hot keys enabled?
	if (NS.charDB.profile.blockGameMenuHotKeys == true) then
		-- not shown?
		local isShown = FriendsFrame:IsShown()
		if (isShown == false) then
			-- not allowed?
			if (NS.CommFlare.CF.AllowFriendsFrame == false) then
				-- inside pvp content?
				local isArena = PvPIsArena()
				local isBrawl = PvPIsInBrawl()
				local isBattleground = NS:IsInBattleground()
				if (isArena or isBattleground or isBrawl) then
					-- finished
					return
				end
			end
		end	

		-- disabled
		NS.CommFlare.CF.AllowFriendsFrame = false
	end

	-- not in combat lockdown?
	if (InCombatLockdown() ~= true) then
		-- call original
		NS.CommFlare.hooks["ToggleFriendsFrame"](tab)
	end
end

-- process guild micro button clicked
local function hook_GuildMicroButton_OnClick(self, ...)
	-- block game menu hot keys enabled?
	if (NS.charDB.profile.blockGameMenuHotKeys == true) then
		-- allowed
		NS.CommFlare.CF.AllowGuildFrame = true
	end

	-- not in combat lockdown?
	if (InCombatLockdown() ~= true) then
		-- call original
		NS.CommFlare.hooks[GuildMicroButton].OnClick(self, ...)
	else
		-- always normal
		GuildMicroButton:SetNormal()
	end
end

-- process guild toggle
local function hook_ToggleGuildFrame()
	-- block game menu hot keys enabled?
	if (NS.charDB.profile.blockGameMenuHotKeys == true) then
		-- not loaded yet?
		if (not CommunitiesFrame) then
			-- load communities framework
			Communities_LoadUI()
		end

		-- not shown?
		local isShown = CommunitiesFrame:IsShown()
		if (isShown == false) then
			-- not allowed?
			if (NS.CommFlare.CF.AllowGuildFrame == false) then
				-- inside pvp content?
				local isArena = PvPIsArena()
				local isBrawl = PvPIsInBrawl()
				local isBattleground = NS:IsInBattleground()
				if (isArena or isBattleground or isBrawl) then
					-- finished
					return
				end
			end
		end	

		-- disabled
		NS.CommFlare.CF.AllowGuildFrame = false
	end

	-- not in combat lockdown?
	if (InCombatLockdown() ~= true) then
		-- call original
		NS.CommFlare.hooks["ToggleGuildFrame"]()
	end
end

-- process housing micro button clicked
local function hook_HousingMicroButton_OnClick(self, ...)
	-- block game menu hot keys enabled?
	if (NS.charDB.profile.blockGameMenuHotKeys == true) then
		-- allowed
		NS.CommFlare.CF.AllowHousingFrame = true
	end

	-- not in combat lockdown?
	if (InCombatLockdown() ~= true) then
		-- call original
		NS.CommFlare.hooks[HousingMicroButton].OnClick(self, ...)
	else
		-- always normal
		HousingMicroButton:SetNormal()
	end
end

-- process housing dashboard toggle
local function hook_HousingFramesUtil_ToggleHousingDashboard()
	-- block game menu hot keys enabled?
	if (NS.charDB.profile.blockGameMenuHotKeys == true) then
		-- not shown?
		local isShown = HousingDashboardFrame:IsShown()
		if (isShown == false) then
			-- not allowed?
			if (NS.CommFlare.CF.AllowHousingFrame == false) then
				-- inside pvp content?
				local isArena = PvPIsArena()
				local isBrawl = PvPIsInBrawl()
				local isBattleground = NS:IsInBattleground()
				if (isArena or isBattleground or isBrawl) then
					-- finished
					return
				end
			end
		end	

		-- disabled
		NS.CommFlare.CF.AllowHousingFrame = false
	end

	-- not in combat lockdown?
	if (InCombatLockdown() ~= true) then
		-- call original
		NS.CommFlare.hooks[HousingFramesUtil].ToggleHousingDashboard()
	end
end

-- process player spells micro button clicked
local function hook_PlayerSpellsMicroButton_OnClick(self, ...)
	-- block game menu hot keys enabled?
	if (NS.charDB.profile.blockGameMenuHotKeys == true) then
		-- allowed
		NS.CommFlare.CF.AllowPlayerSpellsFrame = true
	end

	-- not in combat lockdown?
	if (InCombatLockdown() ~= true) then
		-- call original
		NS.CommFlare.hooks[PlayerSpellsMicroButton].OnClick(self, ...)
	else
		-- always normal
		PlayerSpellsMicroButton:SetNormal()
	end
end

-- process player spells toggle
local function hook_PlayerSpellsUtil_TogglePlayerSpellsFrame(suggestedTab, inspectUnit)
	-- block game menu hot keys enabled?
	if (NS.charDB.profile.blockGameMenuHotKeys == true) then
		-- not shown?
		local isShown = PlayerSpellsFrame:IsShown()
		if (isShown == false) then
			-- not allowed?
			if (NS.CommFlare.CF.AllowPlayerSpellsFrame == false) then
				-- inside pvp content?
				local isArena = PvPIsArena()
				local isBrawl = PvPIsInBrawl()
				local isBattleground = NS:IsInBattleground()
				if (isArena or isBattleground or isBrawl) then
					-- finished
					return
				end
			end
		end	

		-- disabled
		NS.CommFlare.CF.AllowPlayerSpellsFrame = false
	end

	-- not in combat lockdown?
	if (InCombatLockdown() ~= true) then
		-- call original
		return NS.CommFlare.hooks[PlayerSpellsUtil].TogglePlayerSpellsFrame(suggestedTab, inspectUnit)
	end
end

-- process spell book toggle
local function hook_PlayerSpellsUtil_ToggleSpellBookFrame(spellBookCategory)
	-- block game menu hot keys enabled?
	if (NS.charDB.profile.blockGameMenuHotKeys == true) then
		-- not shown?
		local isShown = PlayerSpellsFrame:IsShown()
		if (isShown == false) then
			-- not allowed?
			if (NS.CommFlare.CF.AllowPlayerSpellsFrame == false) then
				-- inside pvp content?
				local isArena = PvPIsArena()
				local isBrawl = PvPIsInBrawl()
				local isBattleground = NS:IsInBattleground()
				if (isArena or isBattleground or isBrawl) then
					-- finished
					return
				end
			end
		end	

		-- disabled
		NS.CommFlare.CF.AllowPlayerSpellsFrame = false
	end

	-- not in combat lockdown?
	if (InCombatLockdown() ~= true) then
		-- call original
		NS.CommFlare.hooks[PlayerSpellsUtil].ToggleSpellBookFrame(spellBookCategory)
	end
end

-- process class talent or spec toggle
local function hook_PlayerSpellsUtil_ToggleClassTalentOrSpecFrame()
	-- block game menu hot keys enabled?
	if (NS.charDB.profile.blockGameMenuHotKeys == true) then
		-- not shown?
		local isShown = PlayerSpellsFrame:IsShown()
		if (isShown == false) then
			-- not allowed?
			if (NS.CommFlare.CF.AllowPlayerSpellsFrame == false) then
				-- inside pvp content?
				local isArena = PvPIsArena()
				local isBrawl = PvPIsInBrawl()
				local isBattleground = NS:IsInBattleground()
				if (isArena or isBattleground or isBrawl) then
					-- finished
					return
				end
			end
		end	

		-- disabled
		NS.CommFlare.CF.AllowPlayerSpellsFrame = false
	end

	-- not in combat lockdown?
	if (InCombatLockdown() ~= true) then
		-- call original
		NS.CommFlare.hooks[PlayerSpellsUtil].ToggleClassTalentOrSpecFrame()
	end
end

-- process profession micro button clicked
local function hook_ProfessionMicroButton_OnClick(self, ...)
	-- block game menu hot keys enabled?
	if (NS.charDB.profile.blockGameMenuHotKeys == true) then
		-- allowed
		NS.CommFlare.CF.AllowProfessionsBookFrame = true
	end

	-- not in combat lockdown?
	if (InCombatLockdown() ~= true) then
		-- call original
		NS.CommFlare.hooks[ProfessionMicroButton].OnClick(self, ...)
	else
		-- always normal
		ProfessionMicroButton:SetNormal()
	end
end

-- process professions toggle
local function hook_ToggleProfessionsBook(bookType)
	-- block game menu hot keys enabled?
	if (NS.charDB.profile.blockGameMenuHotKeys == true) then
		-- not loaded yet?
		if (not ProfessionsBookFrame) then
			-- load talent framework
			ProfessionsBook_LoadUI()
		end

		-- not shown?
		local isShown = ProfessionsBookFrame:IsShown()
		if (isShown == false) then
			-- not allowed?
			if (NS.CommFlare.CF.AllowProfessionsBookFrame == false) then
				-- inside pvp content?
				local isArena = PvPIsArena()
				local isBrawl = PvPIsInBrawl()
				local isBattleground = NS:IsInBattleground()
				if (isArena or isBattleground or isBrawl) then
					-- finished
					return
				end
			end
		end	

		-- disabled
		NS.CommFlare.CF.AllowProfessionsBookFrame = false
	end

	-- not in combat lockdown?
	if (InCombatLockdown() ~= true) then
		-- call original
		NS.CommFlare.hooks["ToggleProfessionsBook"](bookType)
	end
end

-- block game menu hooks
function NS:Setup_BlockGameMenuHooks()
	-- housing frame not loaded?
	if (not HousingDashboardFrame) then
		-- load housing frame
		AddOnsLoadAddOn("Blizzard_HousingDashboard");
	end

	-- player spells frame not loaded?
	if (not PlayerSpellsFrame) then
		-- load player spells frame
		PlayerSpellsFrame_LoadUI()
	end

	-- not installed?
	if (hook_GroupFinder_installed == false) then
		-- hooks to block group finder frame inside pvp content
		NS.CommFlare.CF.AllowGroupFinderFrame = false
		NS.CommFlare:RawHook("PVEFrame_ToggleFrame", hook_PVEFrame_ToggleFrame, true)
		NS.CommFlare:RawHookScript(LFDMicroButton, "OnClick", hook_LFDMicroButton_OnClick, true)
		hook_GroupFinder_installed = true
	end

	-- not installed?
	if (hook_MainMenuMicroButton_installed == false) then
		-- hooks for blocking escape key menu inside a battleground
		NS.CommFlare.CF.AllowMainMenu = false
		MainMenuMicroButton:HookScript("OnMouseDown", hook_MainMenuMicroButton_OnMouseDown)
		GameMenuFrame:HookScript("OnShow", hook_GameMenuFrame_OnShow)
		GameMenuFrame:HookScript("OnHide", hook_GameMenuFrame_OnHide)
		hook_MainMenuMicroButton_installed = true
	end

	-- not installed?
	if (hook_ToggleAchievementFrame_installed == false) then
		-- hooks to block achievement frame inside pvp content
		NS.CommFlare.CF.AllowAchievementFrame = false
		NS.CommFlare:RawHook("ToggleAchievementFrame", hook_ToggleAchievementFrame, true)
		NS.CommFlare:RawHookScript(AchievementMicroButton, "OnClick", hook_AchievementMicroButton_OnClick, true)
		hook_ToggleAchievementFrame_installed = true
	end

	-- not installed?
	if (hook_ToggleCharacter_installed == false) then
		-- hooks to block character frame inside pvp content
		NS.CommFlare.CF.AllowCharacterFrame = false
		NS.CommFlare:RawHook("ToggleCharacter", hook_ToggleCharacter, true)
		NS.CommFlare:RawHookScript(CharacterMicroButton, "OnClick", hook_CharacterMicroButton_OnClick, true)
		hook_ToggleCharacter_installed = true
	end

	-- not installed?
	if (hook_ToggleCollectionsJournal_installed == false) then
		-- hooks to block collections frame inside pvp content
		NS.CommFlare.CF.AllowCollectionsFrame = false
		NS.CommFlare:RawHook("ToggleCollectionsJournal", hook_ToggleCollectionsJournal, true)
		NS.CommFlare:RawHookScript(CollectionsMicroButton, "OnClick", hook_CollectionsMicroButton_OnClick, true)
		hook_ToggleCollectionsJournal_installed = true
	end

	-- not installed?
	if (hook_ToggleEncounterJournal_installed == false) then
		-- hooks to block adventure guide frame inside pvp content
		NS.CommFlare.CF.AllowAdvGuideFrame = false
		NS.CommFlare:RawHook("ToggleEncounterJournal", hook_ToggleEncounterJournal, true)
		NS.CommFlare:RawHookScript(EJMicroButton, "OnClick", hook_EJMicroButton_OnClick, true)
		hook_ToggleEncounterJournal_installed = true
	end

	-- not installed?
	if (hook_ToggleFriendsFrame_installed == false) then
		-- hooks to block friends frame inside pvp content
		NS.CommFlare.CF.AllowFriendsFrame = false
		NS.CommFlare:RawHook("ToggleFriendsFrame", hook_ToggleFriendsFrame, true)
		hook_ToggleFriendsFrame_installed = true
	end

	-- not installed?
	if (hook_ToggleGuildFrame_installed == false) then
		-- hooks to block guild frame inside pvp content
		NS.CommFlare.CF.AllowGuildFrame = false
		NS.CommFlare:RawHook("ToggleGuildFrame", hook_ToggleGuildFrame, true)
		NS.CommFlare:RawHookScript(GuildMicroButton, "OnClick", hook_GuildMicroButton_OnClick, true)
		hook_ToggleGuildFrame_installed = true
	end

	-- not installed?
	if (hook_ToggleHousingDashboard_installed == false) then
		-- hooks to block housing frame inside pvp content
		NS.CommFlare.CF.AllowHousingFrame = false
		NS.CommFlare:RawHook(HousingFramesUtil, "ToggleHousingDashboard", hook_HousingFramesUtil_ToggleHousingDashboard, true)
		NS.CommFlare:RawHookScript(HousingMicroButton, "OnClick", hook_HousingMicroButton_OnClick, true)
		hook_ToggleHousingDashboard_installed = true
	end

	-- not installed?
	if (hook_TogglePlayerSpellsFrame_installed == false) then
		-- hooks to block player spells frame inside pvp content
		NS.CommFlare.CF.AllowPlayerSpellsFrame = false
		NS.CommFlare:RawHook(PlayerSpellsUtil, "TogglePlayerSpellsFrame", hook_PlayerSpellsUtil_TogglePlayerSpellsFrame, true)
		NS.CommFlare:RawHook(PlayerSpellsUtil, "ToggleSpellBookFrame", hook_PlayerSpellsUtil_ToggleSpellBookFrame, true)
		NS.CommFlare:RawHook(PlayerSpellsUtil, "ToggleClassTalentOrSpecFrame", hook_PlayerSpellsUtil_ToggleClassTalentOrSpecFrame, true)
		NS.CommFlare:RawHookScript(PlayerSpellsMicroButton, "OnClick", hook_PlayerSpellsMicroButton_OnClick, true)
		hook_TogglePlayerSpellsFrame_installed = true
	end

	-- not installed?
	if (hook_ToggleProfessionsBook_installed == false) then
		-- hooks to block professions book frame inside pvp content
		NS.CommFlare.CF.AllowProfessionsBookFrame = false
		NS.CommFlare:RawHook("ToggleProfessionsBook", hook_ToggleProfessionsBook, true)
		NS.CommFlare:RawHookScript(ProfessionMicroButton, "OnClick", hook_ProfessionMicroButton_OnClick, true)
		hook_ToggleProfessionsBook_installed = true
	end
end
