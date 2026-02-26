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
CF_MemberListFrameMixin = CreateFromMixins(CallbackRegistryMixin)

-- on load
function CF_MemberListFrameMixin:OnLoad()
	-- update header text
	self.HeaderFrame.Title:SetText(strformat("CF %s", "Member List Manager"))

	-- register left button for dragging
	self:SetResizeBounds(250, 250)
	self:RegisterForDrag("LeftButton")
	self:EnableKeyboard(true)

	-- closes when you press Escape
	--tinsert(UISpecialFrames, self:GetName())
end

-- on key down
function CF_MemberListFrameMixin:OnKeyDown(key)
	-- propagate keyboard input enabled
	self:SetPropagateKeyboardInput(true)

	-- END?
	if (key == "END") then
		-- has scroll box?
		local scrollBox = self.MemberListFrame.MemberList.ScrollBox
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
		local scrollBox = self.MemberListFrame.MemberList.ScrollBox
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
		local scrollBox = self.MemberListFrame.MemberList.ScrollBox
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
		local scrollBox = self.MemberListFrame.MemberList.ScrollBox
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
function CF_MemberListFrameMixin:OnShow()
end

-- on drag start
function CF_MemberListFrameMixin:OnDragStart()
	-- start moving
	self:StartMoving()
	self.moving = true
end

-- on drag stop
function CF_MemberListFrameMixin:OnDragStop()
	-- stop moving
	self:StopMovingOrSizing()
	self.moving = nil
end

-- update list
function CF_MemberListFrameMixin:UpdateList()
	-- update
	self.MemberListFrame.MemberList:UpdateMemberList()
end

-- get club id
function CF_MemberListFrameMixin:GetClubID()
	-- return club id
	return self.clubId
end

-- set club id
function CF_MemberListFrameMixin:SetClubID(clubId)
	-- verify club id
	if (NS.db.global.clubs[clubId]) then
		-- save club id
		self.clubId = clubId

		-- success
		return true
	end

	-- failed
	return false
end

-- refresh list
function CF_MemberListFrameMixin:RefreshList()
	-- update / refresh
	self.MemberListFrame.MemberList:UpdateMemberList()
	self.MemberListFrame.MemberList:RefreshListDisplay()
end

-- create table
CF_MemberListCloseButtonMixin = {}

-- get parent frame
function CF_MemberListCloseButtonMixin:GetParentFrame()
	-- get frame
	return self:GetParent():GetParent()
end

-- close button on click
function CF_MemberListCloseButtonMixin:OnClick(button)
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
function CF_MemberListCloseButtonMixin:OnEnter()
	-- show tooltip
	GameTooltip:SetOwner(self)
	GameTooltip:AddLine("Close")
	GameTooltip:AddLine("-Left Click: Close Window", 1, 1, 1)
	GameTooltip:Show()
end

-- close button on leave
function CF_MemberListCloseButtonMixin:OnLeave()
	-- hide tooltip
	GameTooltip:Hide()
end

-- create table
CF_MemberListRefreshButtonMixin = {}

-- get parent frame
function CF_MemberListRefreshButtonMixin:GetParentFrame()
	-- get frame
	return self:GetParent():GetParent()
end

-- refresh button on click
function CF_MemberListRefreshButtonMixin:OnClick(button)
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
function CF_MemberListRefreshButtonMixin:OnEnter()
	-- show tooltip
	GameTooltip:SetOwner(self)
	GameTooltip:AddLine("Refresh")
	GameTooltip:AddLine("-Left Click: Refresh All Players", 1, 1, 1)
	GameTooltip:Show()
end

-- refresh button on leave
function CF_MemberListRefreshButtonMixin:OnLeave()
	-- hide tooltip
	GameTooltip:Hide()
end

-- create table
CF_MemberListMixin = {}

-- get parent frame
function CF_MemberListMixin:GetParentFrame()
	-- get frame
	return self:GetParent():GetParent()
end

-- refresh list display
function CF_MemberListMixin:RefreshListDisplay()
	-- found parent frame?
	local frame = self:GetParentFrame()
	if (frame:IsShown() == true) then
		-- create data provider
		local dataProvider = CreateDataProvider()

		-- has member list?
		if (self.MemberList and (#self.MemberList > 0)) then
			-- process list
			local index = 1
			local clubId = self:GetParentFrame():GetClubID()
			for k,v in ipairs(self.MemberList) do
				-- has guid?
				local name, guid = strsplit("@", v)
				if (name and guid) then
					-- insert
					local info = { index = index, name = name, guid = guid, clubId = clubId }
					dataProvider:Insert({info=info})
					index = index + 1
				end
			end
		end

		-- update counts
		self.MemberCount:SetText(strformat(L["%d Members"], #self.MemberList))

		-- update scroll box
		self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition)
		self.ScrollBox:ForEachFrame(function(button, elementData)
			-- update name frame
			button:UpdateMemberFrame()
		end)
	end
end

-- update member list
function CF_MemberListMixin:UpdateMemberList()
	-- initialize
	self.MemberList = {}

	-- has members?
	if (NS.db.global.members) then
		-- process all
		local clubId = self:GetParentFrame():GetClubID()
		for k,v in pairs(NS.db.global.members) do
			-- has clubs?
			if (v.clubs and v.clubs[clubId]) then
				-- has search text?
				local display = true
				if (searchText and (searchText ~= "")) then
					-- lower case
					local lower = strlower(k)
					if (not lower:find(searchText)) then
						-- has member note?
						if (v.memberNote) then
							-- check member note
							lower = strlower(v.memberNote)
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
					local data = strformat("%s@%s", tostring(k), tostring(v.guid))
					tinsert(self.MemberList, data)
				end
			end
		end
	end

	-- sort
	tsort(self.MemberList)

	-- update
	self:UpdateCount()
	self:Update()
end

-- update count
function CF_MemberListMixin:UpdateCount()
	-- has members?
	local memberCount = 0
	if (NS.db.global.members) then
		-- process all
		local clubId = self:GetParentFrame():GetClubID()
		for k,v in pairs(NS.db.global.members) do
			-- has clubs?
			if (v.clubs and v.clubs[clubId]) then
				-- increase
				memberCount = memberCount + 1
			end
		end
	end

	-- set text
	self.MemberCount:SetText(strformat("%d Members", memberCount))
end

-- update
function CF_MemberListMixin:Update()
	-- refresh list display
	self:RefreshListDisplay()
end

-- on load
function CF_MemberListMixin:OnLoad()
	-- setup the scroll box
	local view = CreateScrollBoxListLinearView()
	view:SetElementInitializer("CF_MemberListEntryTemplate", function(button, elementData)
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
function CF_MemberListMixin:OnShow()
	-- update member list
	self:UpdateMemberList()
end

-- on update
local scrollPercentage = nil
function CF_MemberListMixin:OnUpdate()
	-- member list dirty?
	if (self:IsMemberListDirty()) then
		-- update member list
		self:UpdateMemberList()
		self:ClearMemberListDirty()
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
					-- has GUID?
					if (v.guid) then
						-- verify member GUID
						NS:Verify_MemberGUID(v.guid)
					end
				end
			end
		end
	end

	-- updated?
	if (NS.CommFlare.CF.MemberListUpdated == true) then
		-- update list
		NS.CommFlare.CF.MemberListUpdated = false
		CF_MemberListFrame:UpdateList()
	end
end

-- get selected entry for drop down
function CF_MemberListMixin:GetSelectedEntryForDropDown()
	-- return selected entry
	return self.selectedEntryForDropDown
end

-- set selected entry for drop down
function CF_MemberListMixin:SetSelectedEntryForDropDown(entry)
	-- save selected entry
	self.selectedEntryForDropDown = entry
end

-- mark member list dirty
function CF_MemberListMixin:MarkMemberListDirty()
	-- mark member list dirty
	self.memberListDirty = true
end

-- is member list dirty?
function CF_MemberListMixin:IsMemberListDirty()
	-- return member list dirty
	return self.memberListDirty
end

-- clear member list dirty
function CF_MemberListMixin:ClearMemberListDirty()
	-- clear member list dirty
	self.memberListDirty = nil
end

-- create table
CF_MemberListEntryMixin = {}

-- get parent frame
function CF_MemberListEntryMixin:GetParentFrame()
	-- get frame
	return self:GetParent():GetParent():GetParent()
end

-- on click
function CF_MemberListEntryMixin:OnClick(button)
	-- right click?
	if (button == "RightButton") then
		-- has member?
		local text = "Member"
		if (self.info.name and (self.info.name ~= "")) then
			-- save member
			text = self.info.name
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
		UnitPopup_OpenMenu("CF_MEMBER_LIST", contextData)
	end
end

-- on enter
local show_tooltip = false
function CF_MemberListEntryMixin:OnEnter()
	-- has members?
	if (NS.db.global.members) then
		-- get member info by name
		local member = NS.db.global.members[self.name]
		if (member) then
			-- start tooltip
			GameTooltip:SetOwner(self)
			GameTooltip:AddLine(self.name)

			-- has guid?
			if (member.guid) then
				-- add guid
				GameTooltip:AddLine(strformat("GUID: %s", tostring(member.guid)), 1, 1, 1)
			end

			-- has honor level?
			if (member.hl) then
				-- add honor level
				GameTooltip:AddLine(strformat("Honor Level: %d", tonumber(member.hl)), 1, 1, 1)
			end

			-- has member note?
			if (member.note) then
				-- add member note
				GameTooltip:AddLine(strformat("Member Note: %s", member.note), 1, 1, 1)
			end

			-- has community note?
			local clubId = self.clubId
			if (clubId and member.clubs and member.clubs[clubId] and member.clubs[clubId].memberNote) then
				-- add community note
				local text = member.clubs[clubId].memberNote
				GameTooltip:AddLine(strformat("Community Note: %s", text), 1, 1, 1)
			end

			-- show tooltip
			show_tooltip = true
			GameTooltip:Show()
		end
	end
end

-- on leave
function CF_MemberListEntryMixin:OnLeave()
	-- hide tooltip
	show_tooltip = false
	GameTooltip:Hide()
end

-- set name
function CF_MemberListEntryMixin:SetMember(info)
	-- has name info?
	if (info and info.guid and info.name) then
		-- save name info / text
		self.info = info
		self.guid = info.guid
		self.name = info.name
		self.clubId = info.clubId
		self.MemberFrame.Name:SetText(strformat("%s", info.name))

		-- white
		self.MemberFrame.Name:SetTextColor(1, 1, 1)
	else
		-- delete member info / text
		self.info = nil
		self.MemberFrame.Name:SetText(nil)
	end

	-- update name frame
	self:UpdateMemberFrame()
end

-- init
function CF_MemberListEntryMixin:Init(elementData)
	-- update name frame
	self:UpdateMemberFrame()

	-- has member info?
	if (elementData.info) then
		-- set member data
		self:SetMember(elementData.info)
	end
end

-- update name frame
function CF_MemberListEntryMixin:UpdateMemberFrame()
	-- update name frame
	local memberFrame = self.MemberFrame
	memberFrame.Name:ClearAllPoints()
	memberFrame.Name:SetPoint("LEFT", memberFrame, "LEFT", 0, 0)
	memberFrame:ClearAllPoints()
	memberFrame:SetPoint("LEFT", 4, 0)
	memberFrame:SetWidth(130)
end

-- create set member note mixin
UnitPopupCFSetMemberNoteButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin)

-- get parent frame
function UnitPopupCFSetMemberNoteButtonMixin:GetParentFrame()
	-- get frame
	return self:GetParent():GetParent()
end

-- get set member note text
function UnitPopupCFSetMemberNoteButtonMixin:GetText()
	-- return text
	return L["Set Member Note"]
end

-- set member note on click
function UnitPopupCFSetMemberNoteButtonMixin:OnClick(contextData)
	-- find proper dropdown menu
	if (contextData and contextData.info) then
		-- create context data
		local data = { 
			info = contextData.info,
			clubId = contextData.info.clubId,
			name = contextData.info.name,
			guid = contextData.info.guid,
		}

		-- show set member note dialog
		StaticPopup_Show("CommunityFlare_Set_Member_Note_Dialog", data.name, nil, data)
	end
end

-- create delete member mixin
UnitPopupCFDeleteMemberButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin)

-- get parent frame
function UnitPopupCFDeleteMemberButtonMixin:GetParentFrame()
	-- get frame
	return self:GetParent():GetParent()
end

-- get delete member text
function UnitPopupCFDeleteMemberButtonMixin:GetText()
	-- return text
	return L["Delete Member"]
end

-- delete member on click
function UnitPopupCFDeleteMemberButtonMixin:OnClick(contextData)
	-- find proper dropdown menu
	if (contextData and contextData.info) then
		-- create context data
		local data = { 
			info = contextData.info,
			clubId = contextData.info.clubId,
			name = contextData.info.name,
			guid = contextData.info.guid,
		}

		-- show delete member dialog
		StaticPopup_Show("CommunityFlare_Delete_Member_Dialog", data.name, nil, data)
	end
end

-- register drop down menu for members
UnitPopupMenuCFMembers = CreateFromMixins(UnitPopupTopLevelMenuMixin)
UnitPopupManager:RegisterMenu("CF_MEMBER_LIST", UnitPopupMenuCFMembers)

-- get entries
function UnitPopupMenuCFMembers:GetEntries()
	-- return menu buttons
	return {
		UnitPopupCFSetMemberNoteButtonMixin,
		UnitPopupCFDeleteMemberButtonMixin,
	}
end

-- search box on escape pressed
function CF_MemberListSearchBox_OnEscapePressed(self)
	-- clear text
	self:SetText("")
	self:ClearFocus()
	scrollPercentage = nil
end

-- search box on enter pressed
function CF_MemberListSearchBox_OnEnterPressed(self)
	-- refresh list
	self:ClearFocus()
	CF_MemberListFrame:RefreshList()
	scrollPercentage = nil
end

-- search box on edited focus lost
function CF_MemberListSearchBox_OnEditFocusLost(self)
	-- text cleared?
	if (self:GetText() == "") then
		-- hide clear button
		searchText = ""
		self.Instructions:SetText("Search")
		self.searchIcon:SetVertexColor(0.6, 0.6, 0.6);
		self.clearButton:Hide();

		-- refresh list
		CF_MemberListFrame:RefreshList()
		scrollPercentage = nil
	end
end

-- search box on edit focus gained
function CF_MemberListSearchBox_OnEditFocusGained(self)
	-- gained
	self.Instructions:SetText("")
	self.searchIcon:SetVertexColor(1.0, 1.0, 1.0)
	self.clearButton:Show()
end

-- search box on text changed
function CF_MemberListSearchBox_OnTextChanged(self)
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
			CF_MemberListFrame:RefreshList()
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
CF_MemberListResizeBottomLeftButtonMixin = {}

-- on mouse down
function CF_MemberListResizeBottomLeftButtonMixin:OnMouseDown(button)
	-- left button?
	if (button == "LeftButton") then
		-- start sizing
		CF_MemberListFrame:StartSizing("BOTTOMLEFT")
	end
end

-- on mouse up
function CF_MemberListResizeBottomLeftButtonMixin:OnMouseUp(button)
	-- left button?
	if (button == "LeftButton") then
		-- stop sizing
		CF_MemberListFrame:StopMovingOrSizing("BOTTOMRIGHT")
	end
end

-- create table
CF_MemberListResizeBottomRightButtonMixin = {}

-- on mouse down
function CF_MemberListResizeBottomRightButtonMixin:OnMouseDown(button)
	-- left button?
	if (button == "LeftButton") then
		-- start sizing
		CF_MemberListFrame:StartSizing("BOTTOMRIGHT")
	end
end

-- on mouse up
function CF_MemberListResizeBottomRightButtonMixin:OnMouseUp(button)
	-- left button?
	if (button == "LeftButton") then
		-- stop sizing
		CF_MemberListFrame:StopMovingOrSizing("BOTTOMRIGHT")
	end
end
