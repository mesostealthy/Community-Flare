-- initialize
local LibStub = LibStub
local ADDON_NAME, NS = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
if (not L or not NS.CommFlare) then return end

-- localize stuff
local _G                                          = _G
local CreateDataProvider                          = _G.CreateDataProvider
local CreateFromMixins                            = _G.CreateFromMixins
local CreateScrollBoxListLinearView               = _G.CreateScrollBoxListLinearView
local DevTools_Dump                               = _G.DevTools_Dump
local GetPlayerInfoByGUID                         = _G.GetPlayerInfoByGUID
local IsMouseButtonDown                           = _G.IsMouseButtonDown
local PlayerLocation                              = _G.PlayerLocation
local StaticPopup_Show                            = _G.StaticPopup_Show
local TimerAfter                                  = _G.C_Timer.After
local date                                        = _G.date
local ipairs                                      = _G.ipairs
local pairs                                       = _G.pairs
local print                                       = _G.print
local select                                      = _G.select
local sort                                        = _G.sort
local time                                        = _G.time
local tonumber                                    = _G.tonumber
local strformat                                   = _G.string.format
local strlower                                    = _G.string.lower
local strsplit                                    = _G.string.split
local tinsert                                     = _G.table.insert
local tsort                                       = _G.table.sort

-- local variables
local searchText = ""

-- create mixin
CF_PlayerListFrameMixin = CreateFromMixins(CallbackRegistryMixin)

-- on load
function CF_PlayerListFrameMixin:OnLoad()
	-- update header text
	local title = strformat("CF %s", L["Player List Manager"])
	self.HeaderFrame.Title:SetText(title)

	-- register left button for dragging
	self:SetResizeBounds(250, 250)
	self:RegisterForDrag("LeftButton")
	self:EnableKeyboard(true)

	-- closes when you press Escape
	--tinsert(UISpecialFrames, self:GetName())
end

-- on key down
function CF_PlayerListFrameMixin:OnKeyDown(key)
	-- propagate keyboard input enabled
	self:SetPropagateKeyboardInput(true)

	-- END?
	if (key == "END") then
		-- has scroll box?
		local scrollBox = self.PlayerListFrame.PlayerList.ScrollBox
		if (scrollBox) then
			-- has scroll range?
			local scrollRange = scrollBox:GetDerivedScrollRange()
			if (scrollRange > 0) then
				-- scroll to percentage
				self:SetPropagateKeyboardInput(false)
				scrollBox:SetScrollPercentage(1)
				return
			end
		end
	-- HOME?
	elseif (key == "HOME") then
		-- has scroll box?
		local scrollBox = self.PlayerListFrame.PlayerList.ScrollBox
		if (scrollBox) then
			-- has scroll range?
			local scrollRange = scrollBox:GetDerivedScrollRange()
			if (scrollRange > 0) then
				-- scroll to percentage
				self:SetPropagateKeyboardInput(false)
				scrollBox:SetScrollPercentage(0)
				return
			end
		end
	-- PAGEDOWN?
	elseif (key == "PAGEDOWN") then
		-- has scroll box?
		local scrollBox = self.PlayerListFrame.PlayerList.ScrollBox
		if (scrollBox) then
			-- has scroll range?
			local scrollRange = scrollBox:GetDerivedScrollRange()
			if (scrollRange > 0) then
				-- calculate offset
				local offset = tonumber(scrollBox.scrollPercentage) + tonumber(scrollBox:GetVisibleExtentPercentage())
				if (offset > 1) then
					-- set max
					offset = 1
				end

				-- scroll to percentage
				self:SetPropagateKeyboardInput(false)
				scrollBox:SetScrollPercentage(offset)
				return
			end
		end
	-- PAGEUP?
	elseif (key == "PAGEUP") then
		-- has scroll box?
		local scrollBox = self.PlayerListFrame.PlayerList.ScrollBox
		if (scrollBox) then
			-- has scroll range?
			local scrollRange = scrollBox:GetDerivedScrollRange()
			if (scrollRange > 0) then
				-- calculate offset
				local offset = tonumber(scrollBox.scrollPercentage) - tonumber(scrollBox:GetVisibleExtentPercentage())
				if (offset < 0) then
					-- set min
					offset = 0
				end

				-- scroll to percentage
				self:SetPropagateKeyboardInput(false)
				scrollBox:SetScrollPercentage(offset)
				return
			end
		end
	end
end

-- on show
function CF_PlayerListFrameMixin:OnShow()
end

-- on drag start
function CF_PlayerListFrameMixin:OnDragStart()
	-- start moving
	self:StartMoving()
	self.moving = true
end

-- on drag stop
function CF_PlayerListFrameMixin:OnDragStop()
	-- stop moving
	self:StopMovingOrSizing()
	self.moving = nil
end

-- update list
function CF_PlayerListFrameMixin:UpdateList()
	-- update
	self.PlayerListFrame.PlayerList:UpdatePlayerList()
end

-- refresh list
function CF_PlayerListFrameMixin:RefreshList()
	-- update / refresh
	self.PlayerListFrame.PlayerList:UpdatePlayerList()
	self.PlayerListFrame.PlayerList:RefreshListDisplay()
end

-- create table
CF_PlayerListCloseButtonMixin = {}

-- get parent frame
function CF_PlayerListCloseButtonMixin:GetParentFrame()
	-- get frame
	return self:GetParent():GetParent()
end

-- close button on click
function CF_PlayerListCloseButtonMixin:OnClick(button)
	-- left button?
	if (button == "LeftButton") then
		-- found parent frame?
		local parent = self:GetParentFrame()
		if (parent) then
			-- currently shown?
			if (parent:IsShown() == true) then
				-- hide
				parent:Hide()
			end
		end
	end
end

-- close button on enter
function CF_PlayerListCloseButtonMixin:OnEnter()
	-- show tooltip
	GameTooltip:SetOwner(self)
	GameTooltip:AddLine("Close")
	GameTooltip:AddLine("-Left Click: Close Window", 1, 1, 1)
	GameTooltip:Show()
end

-- close button on leave
function CF_PlayerListCloseButtonMixin:OnLeave()
	-- hide tooltip
	GameTooltip:Hide()
end

-- create table
CF_PlayerListRefreshButtonMixin = {}

-- get parent frame
function CF_PlayerListRefreshButtonMixin:GetParentFrame()
	-- get frame
	return self:GetParent():GetParent()
end

-- refresh button on click
function CF_PlayerListRefreshButtonMixin:OnClick(button)
	-- left button?
	if (button == "LeftButton") then
		-- found parent frame?
		local parent = self:GetParentFrame()
		if (parent) then
			-- refresh list
			parent:RefreshList()
		end
	end
end

-- refresh button on enter
function CF_PlayerListRefreshButtonMixin:OnEnter()
	-- show tooltip
	GameTooltip:SetOwner(self)
	GameTooltip:AddLine("Refresh")
	GameTooltip:AddLine("-Left Click: Refresh All Players", 1, 1, 1)
	GameTooltip:Show()
end

-- refresh button on leave
function CF_PlayerListRefreshButtonMixin:OnLeave()
	-- hide tooltip
	GameTooltip:Hide()
end

-- create table
CF_PlayerListAddKosButtonMixin = {}

-- get parent frame
function CF_PlayerListAddKosButtonMixin:GetParentFrame()
	-- get frame
	return self:GetParent():GetParent()
end

-- report button on click
function CF_PlayerListAddKosButtonMixin:OnClick(button)
	-- left button?
	if (button == "LeftButton") then
		-- check target for player
		local guid = UnitGUID("target")
		if (guid and guid:find("Player-")) then
			-- get name / realm
			local name, realm = UnitFullName("target")
			if (name) then
				-- no realm?
				if (not realm) then
					-- use player realm
					realm = GetRealmName()
				end

				-- not added to MemberGUIDs?
				local player = strformat("%s-%s", name, realm)
				if (NS.db.global.MemberGUIDs and not NS.db.global.MemberGUIDs[guid]) then
					-- add user to MemberGUIDs
					NS.db.global.MemberGUIDs[guid] = player
				end

				-- add user to kos list
				NS.db.global.KosList[guid] = player
			end
		end

		-- found parent frame?
		local parent = self:GetParentFrame()
		if (parent) then
			-- refresh list
			parent:RefreshList()
		end
	end
end

-- add kos button on enter
function CF_PlayerListAddKosButtonMixin:OnEnter()
	-- show tooltip
	GameTooltip:SetOwner(self)
	GameTooltip:AddLine("Add KOS")
	GameTooltip:AddLine("-Left Click: Add Target to KOS", 1, 1, 1)
	GameTooltip:Show()
end

-- add kos button on leave
function CF_PlayerListAddKosButtonMixin:OnLeave()
	-- hide tooltip
	GameTooltip:Hide()
end

-- create table
CF_PlayerListMixin = {}

-- get parent frame
function CF_PlayerListMixin:GetParentFrame()
	-- get frame
	return self:GetParent():GetParent()
end

-- refresh list display
function CF_PlayerListMixin:RefreshListDisplay()
	-- found parent frame?
	local frame = self:GetParentFrame()
	if (frame:IsShown() == true) then
		-- create data provider
		local dataProvider = CreateDataProvider()

		-- has kos list?
		if (self.KosList and (#self.KosList > 0)) then
			-- process list
			local index = 1
			for k,v in ipairs(self.KosList) do
				-- has player and guid?
				local player, guid = strsplit("@", v)
				if (player and guid) then
					-- insert
					local info = { index = index, guid = guid, player = player, kos = true}
					dataProvider:Insert({info=info})
					index = index + 1
				end
			end
		end

		-- has player list?
		if (self.PlayerList and (#self.PlayerList > 0)) then
			-- process list
			local index = 1
			for k,v in ipairs(self.PlayerList) do
				-- has guid?
				local info = nil
				local player, guid = strsplit("@", v)
				if (player and guid) then
					-- insert
					info = { index = index, guid = guid, player = player}
					dataProvider:Insert({info=info})
					index = index + 1
				end
			end
		end

		-- update counts
		self.PlayerCount:SetText(strformat(L["%d KOS, %d Players"], #self.KosList, #self.PlayerList))

		-- update scroll box
		self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition)
		self.ScrollBox:ForEachFrame(function(button, elementData)
			-- update name frame
			button:UpdatePlayerFrame()
		end)
	end
end

-- update player list
function CF_PlayerListMixin:UpdatePlayerList()
	-- initialize
	self.KosList = {}
	self.PlayerList = {}

	-- find count
	if (NS.db.global.MemberGUIDs) then
		-- process all
		for k,v in pairs(NS.db.global.MemberGUIDs) do
			-- has search text?
			local display = true
			if (searchText and (searchText ~= "")) then
				-- lower case
				local lower = strlower(v)
				if (not lower:find(searchText)) then
					-- hide
					display = false
				end
			end

			-- displayed?
			if (display == true) then
				-- kos target?
				local player = v .. "@" .. k
				if (NS.db.global.KosList and NS.db.global.KosList[k]) then
					-- insert
					tinsert(self.KosList, player)
				else
					-- insert
					tinsert(self.PlayerList, player)
				end
			end
		end
	end

	-- sort
	tsort(self.KosList)
	tsort(self.PlayerList)

	-- update
	self:UpdateCount()
	self:Update()
end

-- update count
function CF_PlayerListMixin:UpdateCount()
	-- find kos count
	local kosCount = 0
	if (NS.db.global.KosList) then
		-- process all
		for k,v in pairs(NS.db.global.KosList) do
			-- increase
			kosCount = kosCount + 1
		end
	end

	-- find player count
	local playerCount = 0
	if (NS.db.global.MemberGUIDs) then
		-- process all
		for k,v in pairs(NS.db.global.MemberGUIDs) do
			-- increase
			playerCount = playerCount + 1
		end
	end

	-- set text
	self.PlayerCount:SetText(strformat("%d KOS, %d Players", kosCount, playerCount))
end

-- update
function CF_PlayerListMixin:Update()
	-- refresh list display
	self:RefreshListDisplay()
end

-- on load
function CF_PlayerListMixin:OnLoad()
	-- setup the scroll box
	local view = CreateScrollBoxListLinearView()
	view:SetElementInitializer("CF_PlayerListEntryTemplate", function(button, elementData)
		-- initialize
		button:Init(elementData)
	end)
	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view)

	-- remove scroll bar track
	local track = self.ScrollBar.Track
	if (track) then
		-- disable artwork layer
		track:DisableDrawLayer("ARTWORK")
	end
end

-- on show
function CF_PlayerListMixin:OnShow()
	-- update player list
	self:UpdatePlayerList()
end

-- on update
local scrollPercentage = nil
function CF_PlayerListMixin:OnUpdate()
	-- player list dirty?
	if (self:IsPlayerListDirty()) then
		-- update player list
		self:UpdatePlayerList()
		self:ClearPlayerListDirty()
	else
		-- no mouse buttons down?
		if (IsMouseButtonDown() == false) then
			-- updated
			if (self.ScrollBar.scrollPercentage ~= scrollPercentage) then
				-- updated
				scrollPercentage = self.ScrollBar.scrollPercentage

				-- get frames
				local frames = self.ScrollBox:GetFrames()
				for k,v in pairs(frames) do
					-- verify member GUID
					NS:Verify_MemberGUID(v.guid)
				end
			end
		end
	end

	-- updated?
	if (NS.CommFlare.CF.PlayerListUpdated == true) then
		-- update list
		NS.CommFlare.CF.PlayerListUpdated = false
		CF_PlayerListFrame:UpdateList()
	end
end

-- get selected entry for drop down
function CF_PlayerListMixin:GetSelectedEntryForDropDown()
	-- return selected entry
	return self.selectedEntryForDropDown
end

-- set selected entry for drop down
function CF_PlayerListMixin:SetSelectedEntryForDropDown(entry)
	-- save selected entry
	self.selectedEntryForDropDown = entry
end

-- mark player list dirty
function CF_PlayerListMixin:MarkPlayerListDirty()
	-- mark player list dirty
	self.playerListDirty = true
end

-- is player list dirty?
function CF_PlayerListMixin:IsPlayerListDirty()
	-- return player list dirty
	return self.playerListDirty
end

-- clear player list dirty
function CF_PlayerListMixin:ClearPlayerListDirty()
	-- clear player list dirty
	self.playerListDirty = nil
end

-- create table
CF_PlayerListEntryMixin = {}

-- get parent frame
function CF_PlayerListEntryMixin:GetParentFrame()
	-- get frame
	return self:GetParent():GetParent():GetParent()
end

-- on click
function CF_PlayerListEntryMixin:OnClick(button)
	-- left button?
	if (button == "LeftButton") then
		-- display info
		print(strformat("%s: %s", L["GUID"], self.guid))

		-- has member note?
		if (NS.db.global.MemberNotes and NS.db.global.MemberNotes[self.guid]) then
			-- display member note
			print(strformat("Note: %s", NS.db.global.MemberNotes[self.guid]))
		end
	-- right click?
	elseif (button == "RightButton") then
		-- toggle drop down menu
		--local playersList = self:GetParentFrame()
		--playersList:SetSelectedEntryForDropDown(self)
		--ToggleDropDownMenu(1, nil, playersList.EntryDropDown, self, 0, 0)


		-- has player?
		local text = "Player"
		if (self.info.player and (self.info.player ~= "")) then
			-- save player
			text = self.info.player
		end

		-- setup context data
		local parent = self:GetParentFrame()
		local contextData = {
			name = text,
			guid = self.guid,
			info = self.info,
			parent = parent,
		}

		-- open menu
		UnitPopup_OpenMenu("CF_PLAYER_LIST", contextData)
	end
end

-- on enter
local show_tooltip = false
function CF_PlayerListEntryMixin:OnEnter()
	-- has member guid?
	if (NS.db.global.MemberGUIDs) then
		-- get player info by GUID
		local localizedClass, englishClass, localizedRace, englishRace, sex, name, realm = GetPlayerInfoByGUID(self.guid)
		if (name) then
			-- has realm?
			local player = nil
			if ((name == "") and (realm == "")) then
				-- character no longer exists?
				if ((localizedClass == "Warrior") and (englishClass == "WARRIOR") and not localizedRace and (englishRace == "") and (sex == 1)) then
					-- check for old member?
					local old_player = NS.db.global.MemberGUIDs[self.guid]
					if (NS.db.global.members[old_player]) then
						-- delete
						NS.db.global.members[old_player] = nil
					end

					-- check for old history?
					if (NS.db.global.history[old_player]) then
						-- delete
						NS.db.global.members[old_player] = nil
					end

					-- has member note?
					if (NS.db.global.MemberNotes and NS.db.global.MemberNotes[self.guid]) then
						-- delete
						NS.db.global.MemberNotes[self.guid] = nil
					end

					-- kos target?
					if (NS.db.global.KosList and NS.db.global.KosList[self.guid]) then
						-- delete
						NS.db.global.KosList[self.guid] = nil
					end

					-- refresh list
					CF_PlayerListFrame:RefreshList()
					return
				else
					-- use from MemberGUIDs
					player = NS.db.global.MemberGUIDs[self.guid]
				end
			elseif (not realm or (realm == "")) then
				-- use player realm
				player = strformat("%s-%s", name, NS.CommFlare.CF.PlayerServerName)
			else
				-- use proper realm
				player = strformat("%s-%s", name, realm)
			end
	
			-- sanity check
			if (not player) then
				-- finished
				return
			end

			-- updated?
			if (NS.db.global.MemberGUIDs[self.guid] and (NS.db.global.MemberGUIDs[self.guid] ~= player)) then
				-- check for old member?
				NS:Process_MemberGUID(self.guid, player)

				-- refresh list
				CF_PlayerListFrame:RefreshList()
				return
			else
				-- start tooltip
				GameTooltip:SetOwner(self)
				GameTooltip:AddLine(self.guid)

				-- display stuff
				GameTooltip:AddLine(strformat("Player: %s", player), 1, 1, 1)

				-- has localized class?
				if (localizedClass and (localizedClass ~= "")) then
					-- add localized class
					GameTooltip:AddLine(strformat("Class: %s", localizedClass), 1, 1, 1)
				end

				-- has localized race?
				if (localizedRace and (localizedRace ~= "")) then
					-- add localized race
					GameTooltip:AddLine(strformat("Race: %s", localizedRace), 1, 1, 1)
				end

				-- create player location from guid
				local playerLocation = PlayerLocation:CreateFromGUID(self.guid)
				if (playerLocation) then
					-- get race id
					local raceID = NS:PlayerInfoGetRace(playerLocation)
					if (raceID) then
						-- get faction
						local factionInfo = NS:GetFactioninfo(raceID)
						if (factionInfo and factionInfo.name and (factionInfo.name ~= "")) then
							-- display faction
							GameTooltip:AddLine(strformat("Faction: %s", factionInfo.name), 1, 1, 1)
						end
					end
				end

				-- has community member info?
				local member = NS:Get_Community_Member(NS.db.global.MemberGUIDs[self.guid])
				if (member and member.clubs) then
					-- process all clubs
					for k,v in pairs(member.clubs) do
						-- has club info?
						if (NS.db.global.clubs and NS.db.global.clubs[k]) then
							-- guild?
							local club = NS.db.global.clubs[k]
							if (club.clubType == Enum.ClubType.Guild) then
								-- display guild note
								GameTooltip:AddLine(strformat("Guild Member: %s", club.name), 1, 1, 1)
							else
								-- display club note
								GameTooltip:AddLine(strformat("Club Member: %s", club.name), 1, 1, 1)
							end
						end
					end
				end

				-- has member note?
				if (NS.db.global.MemberNotes and NS.db.global.MemberNotes[self.guid]) then
					-- display member note
					GameTooltip:AddLine(strformat("Member Note: %s", NS.db.global.MemberNotes[self.guid]), 1, 1, 1)
				end

				-- show tooltip
				show_tooltip = true
				GameTooltip:Show()
			end
		else
			-- start tooltip
			GameTooltip:SetOwner(self)
			GameTooltip:AddLine(self.guid)

			-- display guild note
			GameTooltip:AddLine(strformat("Querying Server ..."), 1, 1, 1)

			-- show tooltip
			show_tooltip = true
			GameTooltip:Show()

			-- refresh 1 second
			TimerAfter(1, function()
				-- tooltip shown?
				if (show_tooltip == true) then
					-- call again
					self:OnEnter()
				end
			end)
		end
	end
end

-- on leave
function CF_PlayerListEntryMixin:OnLeave()
	-- hide tooltip
	show_tooltip = false
	GameTooltip:Hide()
end

-- set player
function CF_PlayerListEntryMixin:SetPlayer(info)
	-- has player info?
	if (info) then
		-- save player info / text
		self.info = info
		self.guid = info.guid
		local text = strformat("%s", info.player)
		self.PlayerFrame.Name:SetText(text)

		-- kos?
		if (info.kos and (info.kos == true)) then
			-- green
			self.PlayerFrame.Name:SetTextColor(0, 1, 0)
		else
			-- white
			self.PlayerFrame.Name:SetTextColor(1, 1, 1)
		end
	else
		-- delete member info / text
		self.info = nil
		self.PlayerFrame.Name:SetText(nil)
	end

	-- update name frame
	self:UpdatePlayerFrame()
end

-- init
function CF_PlayerListEntryMixin:Init(elementData)
	-- update name frame
	self:UpdatePlayerFrame()

	-- has player info?
	if (elementData.info) then
		-- set player data
		local info = elementData.info
		self.guid = info.guid
		self:SetPlayer(info)
	end
end

-- update name frame
function CF_PlayerListEntryMixin:UpdatePlayerFrame()
	-- update name frame
	local playerFrame = self.PlayerFrame
	playerFrame.Name:ClearAllPoints()
	playerFrame.Name:SetPoint("LEFT", playerFrame, "LEFT", 0, 0)
	playerFrame:ClearAllPoints()
	playerFrame:SetPoint("LEFT", 4, 0)
	playerFrame:SetWidth(130)
end

-- create add kos mixin
UnitPopupCFAddKosButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin)

-- get parent frame
function UnitPopupCFAddKosButtonMixin:GetParentFrame()
	-- get frame
	return self:GetParent():GetParent()
end

-- can show add kos?
function UnitPopupCFAddKosButtonMixin:CanShow(contextData)
	-- has context data?
	if (contextData and contextData.info) then
		-- found guid?
		local info = contextData.info
		if (info.guid) then
			-- kos target?
			if (NS.db.global.KosList and NS.db.global.KosList[info.guid]) then
				-- hide
				return false
			end
		end
	end

	-- show
	return true
end

-- get add kos text
function UnitPopupCFAddKosButtonMixin:GetText()
	-- return text
	return L["Add KOS"]
end

-- add kos on click
function UnitPopupCFAddKosButtonMixin:OnClick(contextData)
	-- has context data?
	if (contextData and contextData.info) then
		-- kos list not created yet?
		if (not NS.db.global.KosList) then
			-- initialize
			NS.db.global.KosList = {}
		end

		-- not already added?
		local guid = contextData.info.guid
		if (not NS.db.global.KosList[guid]) then
			-- add to kos list
			player = contextData.info.player
			NS.db.global.KosList[guid] = player
		end

		-- refresh list
		CF_PlayerListFrame:RefreshList()
	end
end

-- create remove kos mixin
UnitPopupCFRemoveKosButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin)

-- get parent frame
function UnitPopupCFRemoveKosButtonMixin:GetParentFrame()
	-- get frame
	return self:GetParent():GetParent()
end

-- can show remove kos?
function UnitPopupCFRemoveKosButtonMixin:CanShow(contextData)
	-- has context data?
	if (contextData and contextData.info) then
		-- found guid?
		local info = contextData.info
		if (info.guid) then
			-- kos target?
			if (NS.db.global.KosList and NS.db.global.KosList[info.guid]) then
				-- show
				return true
			end
		end
	end

	-- hide
	return false
end

-- get remove kos text
function UnitPopupCFRemoveKosButtonMixin:GetText()
	-- return text
	return L["Remove KOS"]
end

-- remove kos on click
function UnitPopupCFRemoveKosButtonMixin:OnClick(contextData)
	-- has context data?
	if (contextData and contextData.info) then
		-- kos list not created yet?
		if (not NS.db.global.KosList) then
			-- create
			NS.db.global.KosList = {}
		end

		-- already added?
		local guid = contextData.info.guid
		if (NS.db.global.KosList[guid]) then
			-- remove from kos list
			NS.db.global.KosList[guid] = nil
		end

		-- refresh list
		CF_PlayerListFrame:RefreshList()
	end
end

-- create delete player mixin
UnitPopupCFDeletePlayerButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin)

-- get parent frame
function UnitPopupCFDeletePlayerButtonMixin:GetParentFrame()
	-- get frame
	return self:GetParent():GetParent()
end

-- get delete player text
function UnitPopupCFDeletePlayerButtonMixin:GetText()
	-- return text
	return L["Delete Player"]
end

-- delete player on click
function UnitPopupCFDeletePlayerButtonMixin:OnClick(contextData)
	-- has context data?
	if (contextData and contextData.info) then
		-- kos list not created yet?
		if (not NS.db.global.KosList) then
			-- create
			NS.db.global.KosList = {}
		end

		-- already added?
		local guid = contextData.info.guid
		if (NS.db.global.KosList[guid]) then
			-- delete
			NS.db.global.KosList[guid] = nil
		end

		-- added to MemberGUIDs?
		if (NS.db.global.MemberGUIDs and NS.db.global.MemberGUIDs[guid]) then
			-- delete
			NS.db.global.MemberGUIDs[guid] = nil
		end

		-- refresh list
		CF_PlayerListFrame:RefreshList()
	end
end

-- create set player note mixin
UnitPopupCFSetPlayerNoteButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin)

-- get parent frame
function UnitPopupCFSetPlayerNoteButtonMixin:GetParentFrame()
	-- get frame
	return self:GetParent():GetParent()
end

-- get set player note text
function UnitPopupCFSetPlayerNoteButtonMixin:GetText()
	-- return text
	return L["Set Player Note"]
end

-- set player note on click
function UnitPopupCFSetPlayerNoteButtonMixin:OnClick(contextData)
	-- has context data?
	if (contextData and contextData.info) then
		-- create context data
		local data = { 
			guid = contextData.guid,
			info = contextData.info,
			player = contextData.info.player
		}

		-- show set player note dialog
		StaticPopup_Show("CommunityFlare_Set_Player_Note_Dialog", data.player, nil, data)
	end
end

-- register drop down menu for players
UnitPopupMenuCFPlayers = CreateFromMixins(UnitPopupTopLevelMenuMixin)
UnitPopupManager:RegisterMenu("CF_PLAYER_LIST", UnitPopupMenuCFPlayers)

-- copy player name mixin
UnitPopupCFCopyPlayerNameMixin = CreateFromMixins(UnitPopupButtonBaseMixin)

-- get parent frame
function UnitPopupCFCopyPlayerNameMixin:GetParentFrame()
	-- get frame
	return self:GetParent():GetParent()
end

-- get set player note text
function UnitPopupCFCopyPlayerNameMixin:GetText()
	-- return text
	return L["Copy Player Name"]
end

-- copy player note on click
function UnitPopupCFCopyPlayerNameMixin:OnClick(contextData)
	-- has context data?
	if (contextData and contextData.info) then
		-- create context data
		local data = { 
			guid = contextData.guid,
			info = contextData.info,
			player = contextData.info.player,
		}

		-- show set player note dialog
		StaticPopup_Show("CommunityFlare_Copy_Player_Name_Dialog", data.player, nil, data)
	end
end

-- copy player name mixin
UnitPopupCFRefreshPlayerNameMixin = CreateFromMixins(UnitPopupButtonBaseMixin)

-- get parent frame
function UnitPopupCFRefreshPlayerNameMixin:GetParentFrame()
	-- get frame
	return self:GetParent():GetParent()
end

-- get set player note text
function UnitPopupCFRefreshPlayerNameMixin:GetText()
	-- return text
	return L["Refresh Player Name"]
end

-- refresh player name
local refresh_retries = 0
local function RefreshPlayerName(guid, old_player)
	-- invalid old player?
	if (not old_player) then
		-- finished
		return
	end

	-- get player info by GUID
	local name, realm = select(6, GetPlayerInfoByGUID(guid))
	if (not name or (name == "")) then
		-- increase
		refresh_retries = refresh_retries + 1
		if (refresh_retries >= 5) then
			-- finished
			return
		end

		-- try again
		TimerAfter(1, function()
			-- call recursively
			RefreshPlayerName(guid, old_player)
		end)
		return
	end

	-- check for old member?
	local player = nil
	if (not realm or (realm == "")) then
		-- add realm name
		player = strformat("%s-%s", name, NS.CommFlare.CF.PlayerServerName)
	else
		-- use realm name
		player = strformat("%s-%s", name, realm)
	end

	-- has name updated?
	if (player and (player ~= old_player)) then
		-- kos target?
		local updated = false
		if (NS.db.global.MemberGUIDs and NS.db.global.MemberGUIDs[guid]) then
			-- update player
			NS.db.global.MemberGUIDs[guid] = player
			NS.db.global.KosList[guid] = player
			updated = true
		end

		-- check for old member
		if (NS.db.global.members[old_player]) then
			-- move member
			NS.db.global.members[player] = CopyTable(NS.db.global.members[old_player])
			NS.db.global.members[old_player] = nil
			updated = true
		end

		-- check for old history
		if (NS.db.global.history[old_player]) then
			-- move history
			NS.db.global.history[player] = CopyTable(NS.db.global.history[old_player])
			NS.db.global.history[old_player] = nil
			updated = true
		end

		-- updated?
		if (updated == true) then
			-- refresh list
			CF_PlayerListFrame:RefreshList()
		end
	end
end

-- copy player note on click
function UnitPopupCFRefreshPlayerNameMixin:OnClick(contextData)
	-- has context data?
	if (contextData and contextData.info) then
		-- refresh player name
		refresh_retries = 0
		local guid = contextData.guid
		local player = contextData.info.player
		RefreshPlayerName(guid, player)
	end
end

-- get entries
function UnitPopupMenuCFPlayers:GetEntries()
	-- return menu buttons
	return {
		UnitPopupCFAddKosButtonMixin,
		UnitPopupCFRemoveKosButtonMixin,
		UnitPopupCFDeletePlayerButtonMixin,
		UnitPopupCFSetPlayerNoteButtonMixin,
		UnitPopupCFCopyPlayerNameMixin,
		UnitPopupCFRefreshPlayerNameMixin,
	}
end

-- search box on escape pressed
function CF_PlayerListSearchBox_OnEscapePressed(self)
	-- clear text
	self:SetText("")
	self:ClearFocus()
	scrollPercentage = nil
end

-- search box on enter pressed
function CF_PlayerListSearchBox_OnEnterPressed(self)
	-- refresh list
	self:ClearFocus()
	CF_PlayerListFrame:RefreshList()
	scrollPercentage = nil
end

-- search box on edited focus lost
function CF_PlayerListSearchBox_OnEditFocusLost(self)
	-- text cleared?
	if (self:GetText() == "") then
		-- hide clear button
		searchText = ""
		self.Instructions:SetText("Search")
		self.searchIcon:SetVertexColor(0.6, 0.6, 0.6);
		self.clearButton:Hide();

		-- refresh list
		CF_PlayerListFrame:RefreshList()
		scrollPercentage = nil
	end
end

-- search box on edit focus gained
function CF_PlayerListSearchBox_OnEditFocusGained(self)
	-- gained
	self.Instructions:SetText("")
	self.searchIcon:SetVertexColor(1.0, 1.0, 1.0)
	self.clearButton:Show()
end

-- search box on text changed
function CF_PlayerListSearchBox_OnTextChanged(self)
	-- save search text
	searchText = self:GetText()
	if (searchText) then
		-- force lower case
		searchText = strlower(searchText)
	end

	-- hide / show clear button
	if (not self:HasFocus() and self:GetText() == "") then
		-- text cleared?
		if (self:GetText() == "") then
			-- hide clear button
			searchText = ""
			self.Instructions:SetText("Search")
			self.searchIcon:SetVertexColor(0.6, 0.6, 0.6);
			self.clearButton:Hide();

			-- refresh list
			CF_PlayerListFrame:RefreshList()
			scrollPercentage = nil
		end

		-- hide clear button
		self.searchIcon:SetVertexColor(0.6, 0.6, 0.6);
		self.clearButton:Hide();
	else
		-- show clear button
		self.searchIcon:SetVertexColor(1.0, 1.0, 1.0);
		self.clearButton:Show();
	end
end

-- create table
CF_PlayerListResizeBottomLeftButtonMixin = {}

-- on mouse down
function CF_PlayerListResizeBottomLeftButtonMixin:OnMouseDown(button)
	-- left button?
	if (button == "LeftButton") then
		-- start sizing
		CF_PlayerListFrame:StartSizing("BOTTOMLEFT")
	end
end

-- on mouse up
function CF_PlayerListResizeBottomLeftButtonMixin:OnMouseUp(button)
	-- left button?
	if (button == "LeftButton") then
		-- stop sizing
		CF_PlayerListFrame:StopMovingOrSizing("BOTTOMRIGHT")
	end
end

-- create table
CF_PlayerListResizeBottomRightButtonMixin = {}

-- on mouse down
function CF_PlayerListResizeBottomRightButtonMixin:OnMouseDown(button)
	-- left button?
	if (button == "LeftButton") then
		-- start sizing
		CF_PlayerListFrame:StartSizing("BOTTOMRIGHT")
	end
end

-- on mouse up
function CF_PlayerListResizeBottomRightButtonMixin:OnMouseUp(button)
	-- left button?
	if (button == "LeftButton") then
		-- stop sizing
		CF_PlayerListFrame:StopMovingOrSizing("BOTTOMRIGHT")
	end
end
