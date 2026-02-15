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
local date                                        = _G.date
local ipairs                                      = _G.ipairs
local pairs                                       = _G.pairs
local print                                       = _G.print
local select                                      = _G.select
local sort                                        = _G.sort
local time                                        = _G.time
local strformat                                   = _G.string.format
local strlower                                    = _G.string.lower
local strsplit                                    = _G.string.split
local tinsert                                     = _G.table.insert
local tsort                                       = _G.table.sort

-- local variables
local searchText = ""

-- create mixin
CF_VehicleListFrameMixin = CreateFromMixins(CallbackRegistryMixin)

-- on load
function CF_VehicleListFrameMixin:OnLoad()
	-- update header text
	local title = strformat("CF %s", L["Vehicle List Manager"])
	self.HeaderFrame.Title:SetText(title)

	-- register stuff
	self:SetResizeBounds(250, 250)
	self:RegisterForDrag("LeftButton")
	self:RegisterEvent("PVP_VEHICLE_INFO_UPDATED")

	-- closes when you press Escape
	--tinsert(UISpecialFrames, self:GetName())
end

-- on show
function CF_VehicleListFrameMixin:OnShow()
	-- refresh list
	self:RefreshList()
end

-- on drag start
function CF_VehicleListFrameMixin:OnDragStart()
	-- start moving
	self:StartMoving()
	self.moving = true
end

-- on drag stop
function CF_VehicleListFrameMixin:OnDragStop()
	-- stop moving
	self:StopMovingOrSizing()
	self.moving = nil
end

-- on event
function CF_VehicleListFrameMixin:OnEvent(event, ...)
	-- pvp vehicle info updated?
	if (event == "PVP_VEHICLE_INFO_UPDATED") then
		-- refresh list
		self:RefreshList()
	end
end

-- refresh list
function CF_VehicleListFrameMixin:RefreshList()
	-- update / refresh
	self.VehicleListFrame.VehicleList:UpdateVehicleList()
	self.VehicleListFrame.VehicleList:RefreshListDisplay()
end

-- create table
CF_VehicleListCloseButtonMixin = {}

-- get parent frame
function CF_VehicleListCloseButtonMixin:GetParentFrame()
	-- get frame
	return self:GetParent():GetParent()
end

-- close button on click
function CF_VehicleListCloseButtonMixin:OnClick(button)
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
function CF_VehicleListCloseButtonMixin:OnEnter()
	-- show tooltip
	GameTooltip:SetOwner(self)
	GameTooltip:AddLine("Close")
	GameTooltip:AddLine("-Left Click: Close Window", 1, 1, 1)
	GameTooltip:Show()
end

-- close button on leave
function CF_VehicleListCloseButtonMixin:OnLeave()
	-- hide tooltip
	GameTooltip:Hide()
end

-- create table
CF_VehicleListRefreshButtonMixin = {}

-- get parent frame
function CF_VehicleListRefreshButtonMixin:GetParentFrame()
	-- get frame
	return self:GetParent():GetParent()
end

-- refresh button on click
function CF_VehicleListRefreshButtonMixin:OnClick(button)
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
function CF_VehicleListRefreshButtonMixin:OnEnter()
	-- show tooltip
	GameTooltip:SetOwner(self)
	GameTooltip:AddLine("Refresh")
	GameTooltip:AddLine("-Left Click: Refresh All Vehicles", 1, 1, 1)
	GameTooltip:Show()
end

-- refresh button on leave
function CF_VehicleListRefreshButtonMixin:OnLeave()
	-- hide tooltip
	GameTooltip:Hide()
end

-- create table
CF_VehicleListMixin = {}

-- get parent frame
function CF_VehicleListMixin:GetParentFrame()
	-- get frame
	return self:GetParent():GetParent()
end

-- refresh list display
function CF_VehicleListMixin:RefreshListDisplay()
	-- found parent frame?
	local frame = self:GetParentFrame()
	if (frame:IsShown() == true) then
		-- create data provider
		local dataProvider = CreateDataProvider()

		-- has vehicle list?
		if (self.VehicleList and (#self.VehicleList > 0)) then
			-- process names
			for k,v in pairs(self.VehicleNames) do
				local name, id = strsplit("@", v)
				id = tonumber(id)
				local info = { id = id, name = name, data = self.VehicleList[id] }
				dataProvider:Insert({info=info})
			end
		end

		-- update count
		self.VehicleCount:SetText(strformat(L["%d Vehicles"], #self.VehicleList))

		-- update scroll box
		self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition)
		self.ScrollBox:ForEachFrame(function(button, elementData)
			-- update frame
			button:UpdateFrame()
		end)
	end
end

-- update queue list
function CF_VehicleListMixin:UpdateVehicleList()
	-- initialize
	self.VehicleList = {}
	self.VehicleNames = {}

	-- get map id
	local mapID = NS:GetBestMapForUnit("player")
	if (mapID) then
		-- process any vehicles
		local list = NS:GetBattlefieldVehicles(mapID)
		if (list and (#list > 0)) then
			-- process list
			local count = 0
			for _,info in pairs(list) do
				-- get name
				count = count + 1
				local name = tostring(info.name)
				if (not name or (name == "")) then name = tostring(info.atlas) end
				name = strformat("%s@%d", name, count)

				-- add to list
				tinsert(self.VehicleNames, name)
				tinsert(self.VehicleList, info)
			end

			-- sort
			tsort(self.VehicleNames)
		end
	end

	-- update
	self:UpdateCount()
	self:Update()
end

-- update count
function CF_VehicleListMixin:UpdateCount()
	-- update count
	self.VehicleCount:SetText(strformat("%d Vehicles", #self.VehicleList))
end

-- update
function CF_VehicleListMixin:Update()
	-- refresh list display
	self:RefreshListDisplay()
end

-- on load
function CF_VehicleListMixin:OnLoad()
	-- setup the scroll box
	local view = CreateScrollBoxListLinearView()
	view:SetElementInitializer("CF_VehicleListEntryTemplate", function(button, elementData)
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
function CF_VehicleListMixin:OnShow()
	-- update queue list
	self:UpdateVehicleList()
end

-- on update
function CF_VehicleListMixin:OnUpdate()
end

-- get selected entry for drop down
function CF_VehicleListMixin:GetSelectedEntryForDropDown()
	-- return selected entry
	return self.selectedEntryForDropDown
end

-- set selected entry for drop down
function CF_VehicleListMixin:SetSelectedEntryForDropDown(entry)
	-- save selected entry
	self.selectedEntryForDropDown = entry
end

-- create table
CF_VehicleListEntryMixin = {}

-- get parent frame
function CF_VehicleListEntryMixin:GetParentFrame()
	-- get frame
	return self:GetParent():GetParent():GetParent()
end

-- on click
function CF_VehicleListEntryMixin:OnClick(button)
	-- left button?
	local info = self.info.data
	if (button == "LeftButton") then
		-- add header
		local name = info.name
		if (not name or (name == "")) then name = tostring(info.atlas) end
		print(strformat("%s: %s", L["Name"], name))
		if (info.description and (info.description ~= "")) then
			-- display description
			print(strformat("%s: %s", L["Description"], info.description))
		end
		print(strformat("%s: %s, %s", L["Position"], tostring(info.x), tostring(info.y)))
	end
end

-- on enter
function CF_VehicleListEntryMixin:OnEnter()
	-- start tooltip
	local info = self.info.data
	GameTooltip:SetOwner(self)

	-- add header
	local name = info.name
	if (not name or (name == "")) then name = tostring(info.atlas) end
	GameTooltip:AddLine(name)

	-- has position?
	if (info.x and info.y) then
		-- add position
		GameTooltip:AddLine(strformat("Position: %s, %s", tostring(info.x), tostring(info.y)), 1, 1, 1)
	end

	-- show tooltip
	GameTooltip:Show()
end

-- on leave
function CF_VehicleListEntryMixin:OnLeave()
	-- hide tooltip
	GameTooltip:Hide()
end

-- set queue
function CF_VehicleListEntryMixin:SetQueue(info)
	-- has queue info?
	if (info) then
		-- save queue info / text
		self.info = info
		local text = strformat("%s", info.name)
		self.QueueFrame.Name:SetText(text)

		-- white
		self.QueueFrame.Name:SetTextColor(1, 1, 1)
	else
		-- delete member info / text
		self.info = nil
		self.QueueFrame.Name:SetText(nil)
	end

	-- update frame
	self:UpdateFrame()
end

-- init
function CF_VehicleListEntryMixin:Init(elementData)
	-- update frame
	self:UpdateFrame()

	-- has queue info?
	if (elementData.info) then
		-- set queue data
		local info = elementData.info
		self:SetQueue(info)
	end
end

-- update frame
function CF_VehicleListEntryMixin:UpdateFrame()
	-- update frame
	local queueFrame = self.QueueFrame
	queueFrame.Name:ClearAllPoints()
	queueFrame.Name:SetPoint("LEFT", queueFrame, "LEFT", 0, 0)
	queueFrame:ClearAllPoints()
	queueFrame:SetPoint("LEFT", 4, 0)
	queueFrame:SetWidth(130)
end

-- create table
CF_VehicleListResizeBottomLeftButtonMixin = {}

-- on mouse down
function CF_VehicleListResizeBottomLeftButtonMixin:OnMouseDown(button)
	-- left button?
	if (button == "LeftButton") then
		-- start sizing
		CF_VehicleListFrame:StartSizing("BOTTOMLEFT")
	end
end

-- on mouse up
function CF_VehicleListResizeBottomLeftButtonMixin:OnMouseUp(button)
	-- left button?
	if (button == "LeftButton") then
		-- stop sizing
		CF_VehicleListFrame:StopMovingOrSizing("BOTTOMRIGHT")
	end
end

-- create table
CF_VehicleListResizeBottomRightButtonMixin = {}

-- on mouse down
function CF_VehicleListResizeBottomRightButtonMixin:OnMouseDown(button)
	-- left button?
	if (button == "LeftButton") then
		-- start sizing
		CF_VehicleListFrame:StartSizing("BOTTOMRIGHT")
	end
end

-- on mouse up
function CF_VehicleListResizeBottomRightButtonMixin:OnMouseUp(button)
	-- left button?
	if (button == "LeftButton") then
		-- stop sizing
		CF_VehicleListFrame:StopMovingOrSizing("BOTTOMRIGHT")
	end
end
