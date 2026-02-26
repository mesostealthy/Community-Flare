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
local date                                        = _G.date
local ipairs                                      = _G.ipairs
local pairs                                       = _G.pairs
local print                                       = _G.print
local select                                      = _G.select
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
CF_CommunityListFrameMixin = CreateFromMixins(CallbackRegistryMixin)

-- on load
function CF_CommunityListFrameMixin:OnLoad()
	-- update header text
	self.HeaderFrame.Title:SetText(strformat("CF %s", L["Community List Manager"]))

	-- register left button for dragging
	self:SetResizeBounds(250, 250)
	self:RegisterForDrag("LeftButton")
	self:EnableKeyboard(true)

	-- closes when you press Escape
	--tinsert(UISpecialFrames, self:GetName())
end

-- on key down
function CF_CommunityListFrameMixin:OnKeyDown(key)
	-- propagate keyboard input enabled
	self:SetPropagateKeyboardInput(true)

	-- END?
	if (key == "END") then
		-- has scroll box?
		local scrollBox = self.CommunityListFrame.CommunityList.ScrollBox
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
		local scrollBox = self.CommunityListFrame.CommunityList.ScrollBox
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
		local scrollBox = self.CommunityListFrame.CommunityList.ScrollBox
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
		local scrollBox = self.CommunityListFrame.CommunityList.ScrollBox
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
function CF_CommunityListFrameMixin:OnShow()
end

-- on drag start
function CF_CommunityListFrameMixin:OnDragStart()
	-- start moving
	self:StartMoving()
	self.moving = true
end

-- on drag stop
function CF_CommunityListFrameMixin:OnDragStop()
	-- stop moving
	self:StopMovingOrSizing()
	self.moving = nil
end

-- update list
function CF_CommunityListFrameMixin:UpdateList()
	-- update
	self.CommunityListFrame.CommunityList:UpdateCommunityList()
end

-- refresh list
function CF_CommunityListFrameMixin:RefreshList()
	-- update / refresh
	self.CommunityListFrame.CommunityList:UpdateCommunityList()
	self.CommunityListFrame.CommunityList:RefreshListDisplay()
end

-- create table
CF_CommunityListCloseButtonMixin = {}

-- get parent frame
function CF_CommunityListCloseButtonMixin:GetParentFrame()
	-- get frame
	return self:GetParent():GetParent()
end

-- close button on click
function CF_CommunityListCloseButtonMixin:OnClick(button)
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
function CF_CommunityListCloseButtonMixin:OnEnter()
	-- show tooltip
	GameTooltip:SetOwner(self)
	GameTooltip:AddLine("Close")
	GameTooltip:AddLine("-Left Click: Close Window", 1, 1, 1)
	GameTooltip:Show()
end

-- close button on leave
function CF_CommunityListCloseButtonMixin:OnLeave()
	-- hide tooltip
	GameTooltip:Hide()
end

-- create table
CF_CommunityListRefreshButtonMixin = {}

-- get parent frame
function CF_CommunityListRefreshButtonMixin:GetParentFrame()
	-- get frame
	return self:GetParent():GetParent()
end

-- refresh button on click
function CF_CommunityListRefreshButtonMixin:OnClick(button)
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
function CF_CommunityListRefreshButtonMixin:OnEnter()
	-- show tooltip
	GameTooltip:SetOwner(self)
	GameTooltip:AddLine("Refresh")
	GameTooltip:AddLine("-Left Click: Refresh All Players", 1, 1, 1)
	GameTooltip:Show()
end

-- refresh button on leave
function CF_CommunityListRefreshButtonMixin:OnLeave()
	-- hide tooltip
	GameTooltip:Hide()
end

-- create table
CF_CommunityListMixin = {}

-- get parent frame
function CF_CommunityListMixin:GetParentFrame()
	-- get frame
	return self:GetParent():GetParent()
end

-- refresh list display
function CF_CommunityListMixin:RefreshListDisplay()
	-- found parent frame?
	local frame = self:GetParentFrame()
	if (frame:IsShown() == true) then
		-- create data provider
		local dataProvider = CreateDataProvider()

		-- has community list?
		if (self.CommunityList and (#self.CommunityList > 0)) then
			-- process list
			local index = 1
			for k,v in ipairs(self.CommunityList) do
				-- has guid?
				local info = nil
				local name, clubId = strsplit("@", v)
				if (name and clubId) then
					-- insert
					info = { index = index, name = name, clubId = tonumber(clubId) }
					dataProvider:Insert({info=info})
					index = index + 1
				end
			end
		end

		-- update counts
		self.CommunityCount:SetText(strformat(L["%d Communities"], #self.CommunityList))

		-- update scroll box
		self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition)
		self.ScrollBox:ForEachFrame(function(button, elementData)
			-- update name frame
			button:UpdateCommunityFrame()
		end)
	end
end

-- update community list
function CF_CommunityListMixin:UpdateCommunityList()
	-- initialize
	self.CommunityList = {}

	-- has clubs?
	if (NS.db.global.clubs) then
		-- process all
		for k,v in pairs(NS.db.global.clubs) do
			-- check for guild
			local name = v.name or "N/A"
			if (v.clubType == Enum.ClubType.Guild) then
				-- update name
				name = strformat("%s (Guild)", name)
			end

			-- has search text?
			local display = true
			if (searchText and (searchText ~= "")) then
				-- lower case
				local lower = strlower(name)
				if (not lower:find(searchText)) then
					-- has short name?
					if (v.shortName) then
						-- check short name
						lower = strlower(v.shortName)
						if (not lower:find(searchText)) then
							-- hide
							display = false
						end
					else
						-- hide
						display = false
					end
				end
			end

			-- displayed?
			if (display == true) then
				-- insert
				local data = strformat("%s@%d", name, tonumber(k))
				tinsert(self.CommunityList, data)
			end
		end
	end

	-- sort
	tsort(self.CommunityList)

	-- update
	self:UpdateCount()
	self:Update()
end

-- update count
function CF_CommunityListMixin:UpdateCount()
	-- find community count
	local communityCount = 0
	if (NS.db.global.MemberGUIDs) then
		-- process all
		for k,v in pairs(NS.db.global.MemberGUIDs) do
			-- increase
			communityCount = communityCount + 1
		end
	end

	-- set text
	self.CommunityCount:SetText(strformat("%d Communities", communityCount))
end

-- update
function CF_CommunityListMixin:Update()
	-- refresh list display
	self:RefreshListDisplay()
end

-- on load
function CF_CommunityListMixin:OnLoad()
	-- setup the scroll box
	local view = CreateScrollBoxListLinearView()
	view:SetElementInitializer("CF_CommunityListEntryTemplate", function(button, elementData)
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
function CF_CommunityListMixin:OnShow()
	-- update community list
	self:UpdateCommunityList()
end

-- on update
local scrollPercentage = nil
function CF_CommunityListMixin:OnUpdate()
	-- community list dirty?
	if (self:IsCommunityListDirty()) then
		-- update community list
		self:UpdateCommunityList()
		self:ClearCommunityListDirty()
	else
		-- no mouse buttons down?
		if (IsMouseButtonDown() == false) then
			-- updated
			if (self.ScrollBar.scrollPercentage ~= scrollPercentage) then
				-- updated
				scrollPercentage = self.ScrollBar.scrollPercentage
			end
		end
	end

	-- updated?
	if (NS.CommFlare.CF.CommunityListUpdated == true) then
		-- update list
		NS.CommFlare.CF.CommunityListUpdated = false
		CF_CommunityListFrame:UpdateList()
	end
end

-- get selected entry for drop down
function CF_CommunityListMixin:GetSelectedEntryForDropDown()
	-- return selected entry
	return self.selectedEntryForDropDown
end

-- set selected entry for drop down
function CF_CommunityListMixin:SetSelectedEntryForDropDown(entry)
	-- save selected entry
	self.selectedEntryForDropDown = entry
end

-- mark community list dirty
function CF_CommunityListMixin:MarkCommunityListDirty()
	-- mark community list dirty
	self.communityListDirty = true
end

-- is community list dirty?
function CF_CommunityListMixin:IsCommunityListDirty()
	-- return community list dirty
	return self.communityListDirty
end

-- clear community list dirty
function CF_CommunityListMixin:ClearCommunityListDirty()
	-- clear community list dirty
	self.communityListDirty = nil
end

-- create table
CF_CommunityListEntryMixin = {}

-- get parent frame
function CF_CommunityListEntryMixin:GetParentFrame()
	-- get frame
	return self:GetParent():GetParent():GetParent()
end

-- on click
function CF_CommunityListEntryMixin:OnClick(button)
	-- right click?
	if (button == "RightButton") then
		-- has community?
		local text = "Community"
		if (self.info.community and (self.info.community ~= "")) then
			-- save community
			text = self.info.community
		end

		-- setup context data
		local parent = self:GetParentFrame()
		local contextData = {
			name = text,
			clubId = self.clubId,
			info = self.info,
			parent = parent,
		}

		-- open menu
		UnitPopup_OpenMenu("CF_COMMUNITY_LIST", contextData)
	end
end

-- on enter
local show_tooltip = false
function CF_CommunityListEntryMixin:OnEnter()
	-- has clubs?
	if (NS.db.global.clubs) then
		-- get club info by clubId
		local club = NS.db.global.clubs[self.clubId]
		if (club) then
			-- start tooltip
			GameTooltip:SetOwner(self)
			GameTooltip:AddLine(club.name)

			-- has faction?
			if (club.faction) then
				-- add faction
				GameTooltip:AddLine(strformat("Faction: %s", tostring(club.faction)), 1, 1, 1)
			end

			-- has club id?
			if (self.clubId and (self.clubId > 0)) then
				-- add club id
				GameTooltip:AddLine(strformat("Club ID: %d", tonumber(self.clubId)), 1, 1, 1)
			end

			-- has member count?
			if (club.memberCount) then
				-- add member count
				GameTooltip:AddLine(strformat("Member Count: %d", tonumber(club.memberCount)), 1, 1, 1)
			end

			-- has cross faction
			if (club.crossFaction == true) then
				-- add cross faction
				GameTooltip:AddLine("Cross Faction: Yes", 1, 1, 1)
			end

			-- has description?
			if (club.description) then
				-- add short name
				GameTooltip:AddLine(strformat("Description: %s", club.description), 1, 1, 1)
			end

			-- has short name?
			if (club.shortName) then
				-- add short name
				GameTooltip:AddLine(strformat("Short Name: %s", club.shortName), 1, 1, 1)
			end

			-- has join time?
			if (club.joinTime) then
				-- add short name
				local text = date("%Y-%m-%d %H:%M:%S", club.joinTime / 1000000)
				GameTooltip:AddLine(strformat("Joined: %s", text), 1, 1, 1)
			end

			-- has note?
			if (club.note) then
				-- add note
				GameTooltip:AddLine(strformat("Note: %s", club.note), 1, 1, 1)
			end

			-- show tooltip
			show_tooltip = true
			GameTooltip:Show()
		end
	end
end

-- on leave
function CF_CommunityListEntryMixin:OnLeave()
	-- hide tooltip
	show_tooltip = false
	GameTooltip:Hide()
end

-- set community
function CF_CommunityListEntryMixin:SetCommunity(info)
	-- has community info?
	if (info and info.clubId and info.name) then
		-- save community info / text
		self.info = info
		self.clubId = info.clubId
		self.CommunityFrame.Name:SetText(strformat("%s", info.name))

		-- white
		self.CommunityFrame.Name:SetTextColor(1, 1, 1)
	else
		-- delete member info / text
		self.info = nil
		self.CommunityFrame.Name:SetText(nil)
	end

	-- update name frame
	self:UpdateCommunityFrame()
end

-- init
function CF_CommunityListEntryMixin:Init(elementData)
	-- update name frame
	self:UpdateCommunityFrame()

	-- has community info?
	if (elementData.info) then
		-- set community data
		local info = elementData.info
		self.clubId = info.clubId
		self:SetCommunity(info)
	end
end

-- update name frame
function CF_CommunityListEntryMixin:UpdateCommunityFrame()
	-- update name frame
	local communityFrame = self.CommunityFrame
	communityFrame.Name:ClearAllPoints()
	communityFrame.Name:SetPoint("LEFT", communityFrame, "LEFT", 0, 0)
	communityFrame:ClearAllPoints()
	communityFrame:SetPoint("LEFT", 4, 0)
	communityFrame:SetWidth(130)
end

-- create view member list mixin
UnitPopupCFViewMemberListButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin)

-- get parent frame
function UnitPopupCFViewMemberListButtonMixin:GetParentFrame()
	-- get frame
	return self:GetParent():GetParent()
end

-- get view member list text
function UnitPopupCFViewMemberListButtonMixin:GetText()
	-- return text
	return L["View Member List"]
end

-- view member list on click
function UnitPopupCFViewMemberListButtonMixin:OnClick(contextData)
	-- find proper dropdown menu
	if (contextData and contextData.info) then
		-- show set community note dialog
		local status = CF_MemberListFrame:SetClubID(contextData.info.clubId)
		if (status == true) then
			-- already shown?
			if (CF_MemberListFrame:IsShown()) then
				-- refresh member list
				CF_MemberListFrame:RefreshList()
			else
				-- show member list
				CF_MemberListFrame:Show()
			end
		end
	end
end

-- create set community note mixin
UnitPopupCFSetCommunityNoteButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin)

-- get parent frame
function UnitPopupCFSetCommunityNoteButtonMixin:GetParentFrame()
	-- get frame
	return self:GetParent():GetParent()
end

-- get set community note text
function UnitPopupCFSetCommunityNoteButtonMixin:GetText()
	-- return text
	return L["Set Community Note"]
end

-- set community note on click
function UnitPopupCFSetCommunityNoteButtonMixin:OnClick(contextData)
	-- find proper dropdown menu
	if (contextData and contextData.info) then
		-- create context data
		local data = { 
			info = contextData.info,
			clubId = contextData.info.clubId,
			name = contextData.info.name,
		}

		-- show set community note dialog
		StaticPopup_Show("CommunityFlare_Set_Community_Note_Dialog", data.name, nil, data)
	end
end

-- create delete community mixin
UnitPopupCFDeleteCommunityButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin)

-- get parent frame
function UnitPopupCFDeleteCommunityButtonMixin:GetParentFrame()
	-- get frame
	return self:GetParent():GetParent()
end

-- get delete community text
function UnitPopupCFDeleteCommunityButtonMixin:GetText()
	-- return text
	return L["Delete Community"]
end

-- delete community on click
function UnitPopupCFDeleteCommunityButtonMixin:OnClick(contextData)
	-- find proper dropdown menu
	if (contextData and contextData.info) then
		-- create context data
		local data = { 
			info = contextData.info,
			clubId = contextData.info.clubId,
			name = contextData.info.name,
		}

		-- show delete community dialog
		StaticPopup_Show("CommunityFlare_Delete_Community_Dialog", data.name, nil, data)
	end
end

-- register drop down menu for communitys
UnitPopupMenuCFCommunities = CreateFromMixins(UnitPopupTopLevelMenuMixin)
UnitPopupManager:RegisterMenu("CF_COMMUNITY_LIST", UnitPopupMenuCFCommunities)

-- get entries
function UnitPopupMenuCFCommunities:GetEntries()
	-- return menu buttons
	return {
		UnitPopupCFViewMemberListButtonMixin,
		UnitPopupCFSetCommunityNoteButtonMixin,
		UnitPopupCFDeleteCommunityButtonMixin,
	}
end

-- search box on escape pressed
function CF_CommunityListSearchBox_OnEscapePressed(self)
	-- clear text
	self:SetText("")
	self:ClearFocus()
	scrollPercentage = nil
end

-- search box on enter pressed
function CF_CommunityListSearchBox_OnEnterPressed(self)
	-- refresh list
	self:ClearFocus()
	CF_CommunityListFrame:RefreshList()
	scrollPercentage = nil
end

-- search box on edited focus lost
function CF_CommunityListSearchBox_OnEditFocusLost(self)
	-- text cleared?
	if (self:GetText() == "") then
		-- hide clear button
		searchText = ""
		self.Instructions:SetText("Search")
		self.searchIcon:SetVertexColor(0.6, 0.6, 0.6);
		self.clearButton:Hide();

		-- refresh list
		CF_CommunityListFrame:RefreshList()
		scrollPercentage = nil
	end
end

-- search box on edit focus gained
function CF_CommunityListSearchBox_OnEditFocusGained(self)
	-- gained
	self.Instructions:SetText("")
	self.searchIcon:SetVertexColor(1.0, 1.0, 1.0)
	self.clearButton:Show()
end

-- search box on text changed
function CF_CommunityListSearchBox_OnTextChanged(self)
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
			CF_CommunityListFrame:RefreshList()
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
CF_CommunityListResizeBottomLeftButtonMixin = {}

-- on mouse down
function CF_CommunityListResizeBottomLeftButtonMixin:OnMouseDown(button)
	-- left button?
	if (button == "LeftButton") then
		-- start sizing
		CF_CommunityListFrame:StartSizing("BOTTOMLEFT")
	end
end

-- on mouse up
function CF_CommunityListResizeBottomLeftButtonMixin:OnMouseUp(button)
	-- left button?
	if (button == "LeftButton") then
		-- stop sizing
		CF_CommunityListFrame:StopMovingOrSizing("BOTTOMRIGHT")
	end
end

-- create table
CF_CommunityListResizeBottomRightButtonMixin = {}

-- on mouse down
function CF_CommunityListResizeBottomRightButtonMixin:OnMouseDown(button)
	-- left button?
	if (button == "LeftButton") then
		-- start sizing
		CF_CommunityListFrame:StartSizing("BOTTOMRIGHT")
	end
end

-- on mouse up
function CF_CommunityListResizeBottomRightButtonMixin:OnMouseUp(button)
	-- left button?
	if (button == "LeftButton") then
		-- stop sizing
		CF_CommunityListFrame:StopMovingOrSizing("BOTTOMRIGHT")
	end
end
