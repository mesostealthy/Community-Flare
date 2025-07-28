-- initialize
local LibStub = LibStub
local ADDON_NAME, NS = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
if (not L or not NS.CommFlare) then return end

-- localize stuff
local _G                                        = _G
local CreateDataProvider                        = _G.CreateDataProvider
local CreateFromMixins                          = _G.CreateFromMixins
local CreateScrollBoxListLinearView             = _G.CreateScrollBoxListLinearView
local DevTools_Dump                             = _G.DevTools_Dump
local GetPlayerInfoByGUID                       = _G.GetPlayerInfoByGUID
local StaticPopup_Show                          = _G.StaticPopup_Show
local StaticPopupDialogs                        = _G.StaticPopupDialogs
local UIDropDownMenu_GetCurrentDropDown         = _G.UIDropDownMenu_GetCurrentDropDown
local UIDropDownMenu_Initialize                 = _G.UIDropDownMenu_Initialize
local TimerAfter                                = _G.C_Timer.After
local date                                      = _G.date
local ipairs                                    = _G.ipairs
local pairs                                     = _G.pairs
local print                                     = _G.print
local select                                    = _G.select
local sort                                      = _G.sort
local time                                      = _G.time
local strformat                                 = _G.string.format
local strlower                                  = _G.string.lower
local tinsert                                   = _G.table.insert
local tsort                                     = _G.table.sort

-- local variables
local searchText = ""

-- create mixin
CF_PlayerListFrameMixin = CreateFromMixins(CallbackRegistryMixin)

-- on load
function CF_PlayerListFrameMixin:OnLoad()
	-- update header text
	local title = strformat("%s %s", NS.CommFlare.Title, L["Player List Manager"])
	self.HeaderFrame.Title:SetText(title)

	-- register left button for dragging
	self:SetResizeBounds(250, 250)
	self:RegisterForDrag("LeftButton")

	-- closes when you press Escape
	--tinsert(UISpecialFrames, self:GetName())
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
				if (NS.db and NS.db.global and NS.db.global.MemberGUIDs and not NS.db.global.MemberGUIDs[guid]) then
					-- add user to MemberGUIDs
					NS.db.global.MemberGUIDs[guid] = player
				end

				-- add user to kos list
				NS.CommFlare.CF.KosList[guid] = { guid = guid, player = player }
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
				-- has guid?
				local guid = self.PlayerNames[v]
				if (guid) then
					-- insert
					local info = { index = index, guid = guid, player = v, kos = true}
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
				local guid = self.PlayerNames[v]
				if (guid) then
					-- insert
					info = { index = index, guid = guid, player = v}
					dataProvider:Insert({info=info})
					index = index + 1
				end
			end
		end

		-- update counts
		self.PlayerCount:SetText(strformat("%d KOS, %d Players", #self.KosList, #self.PlayerList))

		-- update scroll box
		self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition)
		self.ScrollBox:ForEachFrame(function(button, elementData)
			-- update name frame
			button:UpdateQueueFrame()
		end)
	end
end

-- update queue list
function CF_PlayerListMixin:UpdatePlayerList()
	-- initialize
	self.KosList = {}
	self.PlayerList = {}
	self.PlayerNames = {}

	-- find count
	if (NS.db and NS.db.global and NS.db.global.MemberGUIDs) then
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
				if (NS.CommFlare and NS.CommFlare.CF and NS.CommFlare.CF.KosList and NS.CommFlare.CF.KosList[k]) then
					-- insert
					tinsert(self.KosList, v)
				else
					-- insert
					tinsert(self.PlayerList, v)
				end

				-- add to player names
				self.PlayerNames[v] = k
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
	if (NS.CommFlare.CF.KosList) then
		-- process all
		for k,v in pairs(NS.CommFlare.CF.KosList) do
			-- increase
			kosCount = kosCount + 1
		end
	end

	-- find player count
	local playerCount = 0
	if (NS.db and NS.db.global and NS.db.global.MemberGUIDs) then
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
	-- update queue list
	self:UpdatePlayerList()
end

-- on update
function CF_PlayerListMixin:OnUpdate()
	-- queue list dirty?
	if (self:IsKosListDirty()) then
		-- update queue list
		self:UpdatePlayerList()
		self:ClearKosListDirty()
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

-- mark queue list dirty
function CF_PlayerListMixin:MarkKosListDirty()
	-- mark queue list dirty
	self.queueListDirty = true
end

-- is queue list dirty?
function CF_PlayerListMixin:IsKosListDirty()
	-- return queue list dirty
	return self.queueListDirty
end

-- clear queue list dirty
function CF_PlayerListMixin:ClearKosListDirty()
	-- clear queue list dirty
	self.queueListDirty = nil
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
		if (NS.db and NS.db.global and NS.db.global.MemberNotes and NS.db.global.MemberNotes[self.guid]) then
			-- display member note
			print(strformat("Note: %s", NS.db.global.MemberNotes[self.guid]))
		end
	-- right click?
	elseif (button == "RightButton") then
		-- toggle drop down menu
		local queuesList = self:GetParentFrame()
		queuesList:SetSelectedEntryForDropDown(self)
		ToggleDropDownMenu(1, nil, queuesList.EntryDropDown, self, 0, 0)
	end
end

-- on enter
function CF_PlayerListEntryMixin:OnEnter()
	-- start tooltip
	GameTooltip:SetOwner(self)
	GameTooltip:AddLine(self.guid)

	-- has member guid?
	if (NS.db and NS.db.global and NS.db.global.MemberGUIDs) then
		-- has community member info?
		local member = NS:Get_Community_Member(NS.db.global.MemberGUIDs[self.guid])
		if (member and member.clubs) then
			-- process all clubs
			for k,v in pairs(member.clubs) do
				-- has club info?
				if (NS.db and NS.db.global and NS.db.global.clubs and NS.db.global.clubs[k]) then
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
	end

	-- has member note?
	if (NS.db and NS.db.global and NS.db.global.MemberNotes and NS.db.global.MemberNotes[self.guid]) then
		-- display member note
		GameTooltip:AddLine(strformat("Member Note: %s", NS.db.global.MemberNotes[self.guid]), 1, 1, 1)
	end

	-- show tooltip
	GameTooltip:Show()
end

-- on leave
function CF_PlayerListEntryMixin:OnLeave()
	-- hide tooltip
	GameTooltip:Hide()
end

-- set queue
function CF_PlayerListEntryMixin:SetQueue(info)
	-- has queue info?
	if (info) then
		-- save queue info / text
		self.info = info
		self.guid = info.guid
		local text = strformat("%s", info.player)
		self.QueueFrame.Name:SetText(text)

		-- kos?
		if (info.kos and (info.kos == true)) then
			-- green
			self.QueueFrame.Name:SetTextColor(0, 1, 0)
		else
			-- white
			self.QueueFrame.Name:SetTextColor(1, 1, 1)
		end
	else
		-- delete member info / text
		self.info = nil
		self.QueueFrame.Name:SetText(nil)
	end

	-- update name frame
	self:UpdateQueueFrame()
end

-- init
function CF_PlayerListEntryMixin:Init(elementData)
	-- update name frame
	self:UpdateQueueFrame()

	-- has queue info?
	if (elementData.info) then
		-- set queue data
		local info = elementData.info
		self.guid = info.guid
		self:SetQueue(info)
	end
end

-- update name frame
function CF_PlayerListEntryMixin:UpdateQueueFrame()
	-- update name frame
	local queueFrame = self.QueueFrame
	queueFrame.Name:ClearAllPoints()
	queueFrame.Name:SetPoint("LEFT", queueFrame, "LEFT", 0, 0)
	queueFrame:ClearAllPoints()
	queueFrame:SetPoint("LEFT", 4, 0)
	queueFrame:SetWidth(130)
end

-- create add kos mixin
UnitPopupCFAddKosButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin)

-- get parent frame
function UnitPopupCFAddKosButtonMixin:GetParentFrame()
	-- get frame
	return self:GetParent():GetParent()
end

-- can show add kos?
function UnitPopupCFAddKosButtonMixin:CanShow()
	-- find proper dropdown menu
	local dropdownMenu = UIDropDownMenu_GetCurrentDropDown()
	if (dropdownMenu and dropdownMenu.guid and dropdownMenu.info) then
		-- found guid?
		local info = dropdownMenu.info
		if (info.guid) then
			-- kos target?
			if (NS.CommFlare.CF.KosList and NS.CommFlare.CF.KosList[info.guid]) then
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
function UnitPopupCFAddKosButtonMixin:OnClick()
	-- find proper dropdown menu
	local dropdownMenu = UIDropDownMenu_GetCurrentDropDown()
	if (dropdownMenu and dropdownMenu.guid and dropdownMenu.info) then
		-- kos list not created yet?
		if (not NS.CommFlare.CF.KosList) then
			-- create
			NS.CommFlare.CF.KosList = {}
		end

		-- not already added?
		local guid = dropdownMenu.info.guid
		if (not NS.CommFlare.CF.KosList[guid]) then
			-- add to kos list
			player = dropdownMenu.info.player
			NS.CommFlare.CF.KosList[guid] = { guid = guid, player = player }
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
function UnitPopupCFRemoveKosButtonMixin:CanShow()
	-- find proper dropdown menu
	local dropdownMenu = UIDropDownMenu_GetCurrentDropDown()
	if (dropdownMenu and dropdownMenu.guid and dropdownMenu.info) then
		-- found guid?
		local info = dropdownMenu.info
		if (info.guid) then
			-- kos target?
			if (NS.CommFlare.CF.KosList and NS.CommFlare.CF.KosList[info.guid]) then
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
function UnitPopupCFRemoveKosButtonMixin:OnClick()
	-- find proper dropdown menu
	local dropdownMenu = UIDropDownMenu_GetCurrentDropDown()
	if (dropdownMenu and dropdownMenu.guid and dropdownMenu.info) then
		-- kos list not created yet?
		if (not NS.CommFlare.CF.KosList) then
			-- create
			NS.CommFlare.CF.KosList = {}
		end

		-- already added?
		local guid = dropdownMenu.info.guid
		if (NS.CommFlare.CF.KosList[guid]) then
			-- remove from kos list
			NS.CommFlare.CF.KosList[guid] = nil
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
function UnitPopupCFDeletePlayerButtonMixin:OnClick()
	-- find proper dropdown menu
	local dropdownMenu = UIDropDownMenu_GetCurrentDropDown()
	if (dropdownMenu and dropdownMenu.guid and dropdownMenu.info) then
		-- kos list not created yet?
		if (not NS.CommFlare.CF.KosList) then
			-- create
			NS.CommFlare.CF.KosList = {}
		end

		-- already added?
		local guid = dropdownMenu.info.guid
		if (NS.CommFlare.CF.KosList[guid]) then
			-- remove from kos list
			NS.CommFlare.CF.KosList[guid] = nil
		end

		-- added to MemberGUIDs?
		if (NS.db and NS.db.global and NS.db.global.MemberGUIDs and NS.db.global.MemberGUIDs[guid]) then
			-- delete user from MemberGUIDs
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
function UnitPopupCFSetPlayerNoteButtonMixin:OnClick()
	-- find proper dropdown menu
	local dropdownMenu = UIDropDownMenu_GetCurrentDropDown()
	if (dropdownMenu and dropdownMenu.guid and dropdownMenu.info) then
		-- create context data
		local data = { 
			guid = dropdownMenu.guid,
			info = dropdownMenu.info,
			player = dropdownMenu.info.player
		}

		-- show set player note dialog
		StaticPopup_Show("CommunityFlare_Set_Player_Note_Dialog", dropdownMenu.info.player, nil, data)
	end
end

-- register drop down menu for queues
UnitPopupMenuCFQueues = CreateFromMixins(UnitPopupTopLevelMenuMixin)
UnitPopupManager:RegisterMenu("CF_QUEUES", UnitPopupMenuCFQueues)

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
function UnitPopupCFCopyPlayerNameMixin:OnClick()
	-- find proper dropdown menu
	local dropdownMenu = UIDropDownMenu_GetCurrentDropDown()
	if (dropdownMenu and dropdownMenu.guid and dropdownMenu.info) then
		-- create context data
		local data = { 
			guid = dropdownMenu.guid,
			info = dropdownMenu.info,
			player = dropdownMenu.info.player
		}

		-- show set player note dialog
		StaticPopup_Show("CommunityFlare_Copy_Player_Name_Dialog", dropdownMenu.info.player, nil, data)
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
	local localizedClass, englishClass, localizedRace, englishRace, sex, name, realm = GetPlayerInfoByGUID(guid)
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
	local player = name
	if (not realm or (realm == "")) then
		-- add realm name
		player = player .. "-" .. NS.CommFlare.CF.PlayerServerName
	else
		-- use realm name
		player = player .. "-" .. realm
	end

	-- has name updated?
	if (player ~= old_player) then
		-- kos target?
		local updated = false
		if (NS.db.global.MemberGUIDs and NS.db.global.MemberGUIDs[guid]) then
			-- update player
			NS.db.global.MemberGUIDs[guid] = player
			NS.CommFlare.CF.KosList[guid].player = player
			updated = true
		end

		-- check for old player
		if (NS.db.global.members[old_player]) then
			-- move member
			NS.db.global.members[old_player].name = player
			NS.db.global.members[player] = CopyTable(NS.db.global.members[old_player])
			NS.db.global.members[old_player] = nil
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
function UnitPopupCFRefreshPlayerNameMixin:OnClick()
	-- find proper dropdown menu
	local dropdownMenu = UIDropDownMenu_GetCurrentDropDown()
	if (dropdownMenu and dropdownMenu.guid and dropdownMenu.info) then
		-- refresh player name
		refresh_retries = 0
		local guid = dropdownMenu.guid
		local player = dropdownMenu.info.player
		RefreshPlayerName(guid, player)
	end
end

-- get entries
function UnitPopupMenuCFQueues:GetEntries()
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

-- queue list drop down initialize
function CF_PlayerListEntryDropDown_Initialize(self, level)
	-- no selected entry?
	local queuesList = self:GetParent()
	local selectedKosListEntry = queuesList:GetSelectedEntryForDropDown()
	if (not selectedKosListEntry) then
		-- finished
		return
	end

	-- save queue stuff
	self.parent = queuesList
	self.guid = selectedKosListEntry.guid
	self.info = selectedKosListEntry.info

	-- has player?
	local text = "Player"
	if (self.info.player and (self.info.player ~= "")) then
		-- save player
		text = self.info.player
	end

	-- open popup menu
	local contextData = { parent = self.parent, guid = self.guid, name = text, info = self.info }
	UnitPopup_OpenMenu("CF_QUEUES", contextData)
end

-- queue list drop down on load
function CF_PlayerListEntryDropDown_OnLoad(self)
	-- initialize drop down menu
	UIDropDownMenu_Initialize(self, CF_PlayerListEntryDropDown_Initialize, "MENU")
end

-- queue list drop down on hide
function CF_PlayerListEntryDropDown_OnHide(self)
	-- remove selected entry
	local queuesList = self:GetParent()
	queuesList:SetSelectedEntryForDropDown(nil)
end

-- search box on escape pressed
function CF_PlayerListSearchBox_OnEscapePressed(self)
	-- clear text
	self:SetText("")
	self:ClearFocus()
end

-- search box on enter pressed
function CF_PlayerListSearchBox_OnEnterPressed(self)
	-- refresh list
	self:ClearFocus()
	CF_PlayerListFrame:RefreshList()
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
