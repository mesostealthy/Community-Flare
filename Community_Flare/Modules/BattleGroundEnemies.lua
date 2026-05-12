-- initialize
local LibStub = LibStub
local ADDON_NAME, NS = ...
if (not NS.Loaded or not NS.Loaded["Timers"]) then return end
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
if (not L or not NS.CommFlare) then return end

-- localize stuff
local _G                                          = _G
local hooksecurefunc                              = _G.hooksecurefunc
local issecretvalue                               = _G.issecretvalue

-- setup hooks
local hooks_BattleGroundEnemies_installed = nil
function NS:BattleGroundEnemies_SetupHooks()
	-- BattleGroundEnemies installed?
	if (BattleGroundEnemies and BattleGroundEnemies.Enemies and BattleGroundEnemies.Enemies.PlayerList) then
		-- already installed?
		if (hooks_BattleGroundEnemies_installed) then
			-- finished
			return
		end

		-- hook BattleGroundEnemies.Enemies:AfterPlayerSourceUpdate()
		hooksecurefunc(BattleGroundEnemies.Enemies, "AfterPlayerSourceUpdate", function(self)
			-- has player list?
			if (BattleGroundEnemies.Enemies.PlayerList) then
				-- process all
				local numEnemies = #BattleGroundEnemies.Enemies.PlayerList
				for i = 1, numEnemies do
					-- sanity check
					local playerBar = BattleGroundEnemies.Enemies.PlayerList[i]
					if (playerBar) then
						-- sanity check
						local playerDetails = playerBar.PlayerDetails
						if (playerDetails and playerDetails.PlayerName and not issecretvalue(playerDetails.PlayerName)) then
							local player = playerDetails.PlayerName
						end
					end
				end
			end
		end)

		-- installed
		hooks_BattleGroundEnemies_installed = true
	end
end

-- fully loaded
NS.LoadCount = NS.LoadCount + 1
NS.Loaded["BattleGroundEnemies"] = NS.LoadCount
