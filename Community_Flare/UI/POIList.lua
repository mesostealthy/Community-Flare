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
local AreaPoiInfoGetAreaPOIForMap               = _G.C_AreaPoiInfo.GetAreaPOIForMap
local AreaPoiInfoGetAreaPOIInfo                 = _G.C_AreaPoiInfo.GetAreaPOIInfo
local MapGetBestMapForUnit                      = _G.C_Map.GetBestMapForUnit
local date                                      = _G.date
local ipairs                                    = _G.ipairs
local pairs                                     = _G.pairs
local print                                     = _G.print
local select                                    = _G.select
local sort                                      = _G.sort
local time                                      = _G.time
local tonumber                                  = _G.tonumber
local tostring                                  = _G.tostring
local strformat                                 = _G.string.format
local strlower                                  = _G.string.lower
local strsplit                                  = _G.string.split
local tinsert                                   = _G.table.insert
local tsort                                     = _G.table.sort

-- local variables
local searchText = ""

-- create mixin
CF_POIListFrameMixin = CreateFromMixins(CallbackRegistryMixin)

-- on load
function CF_POIListFrameMixin:OnLoad()
	-- update header text
	local title = strformat("CF %s", L["POI List Manager"])
	self.HeaderFrame.Title:SetText(title)

	-- register stuff
	self:SetResizeBounds(250, 250)
	self:RegisterForDrag("LeftButton")
	self:RegisterEvent("AREA_POIS_UPDATED")

	-- closes when you press Escape
	--tinsert(UISpecialFrames, self:GetName())
end

-- on show
function CF_POIListFrameMixin:OnShow()
	-- refresh list
	self:RefreshList()
end

-- on drag start
function CF_POIListFrameMixin:OnDragStart()
	-- start moving
	self:StartMoving()
	self.moving = true
end

-- on drag stop
function CF_POIListFrameMixin:OnDragStop()
	-- stop moving
	self:StopMovingOrSizing()
	self.moving = nil
end

-- on event
function CF_POIListFrameMixin:OnEvent(event, ...)
	-- area pois updated?
	if (event == "AREA_POIS_UPDATED") then
		-- refresh list
		self:RefreshList()
	end
end

-- refresh list
function CF_POIListFrameMixin:RefreshList()
	-- update / refresh
	self.POIListFrame.POIList:UpdatePOIList()
	self.POIListFrame.POIList:RefreshListDisplay()
end

-- create table
CF_POIListCloseButtonMixin = {}

-- get parent frame
function CF_POIListCloseButtonMixin:GetParentFrame()
	-- get frame
	return self:GetParent():GetParent()
end

-- close button on click
function CF_POIListCloseButtonMixin:OnClick(button)
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
function CF_POIListCloseButtonMixin:OnEnter()
	-- show tooltip
	GameTooltip:SetOwner(self)
	GameTooltip:AddLine("Close")
	GameTooltip:AddLine("-Left Click: Close Window", 1, 1, 1)
	GameTooltip:Show()
end

-- close button on leave
function CF_POIListCloseButtonMixin:OnLeave()
	-- hide tooltip
	GameTooltip:Hide()
end

-- create table
CF_POIListRefreshButtonMixin = {}

-- get parent frame
function CF_POIListRefreshButtonMixin:GetParentFrame()
	-- get frame
	return self:GetParent():GetParent()
end

-- refresh button on click
function CF_POIListRefreshButtonMixin:OnClick(button)
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
function CF_POIListRefreshButtonMixin:OnEnter()
	-- show tooltip
	GameTooltip:SetOwner(self)
	GameTooltip:AddLine("Refresh")
	GameTooltip:AddLine("-Left Click: Refresh All POIs", 1, 1, 1)
	GameTooltip:Show()
end

-- refresh button on leave
function CF_POIListRefreshButtonMixin:OnLeave()
	-- hide tooltip
	GameTooltip:Hide()
end

-- create table
CF_POIListMixin = {}

-- get parent frame
function CF_POIListMixin:GetParentFrame()
	-- get frame
	return self:GetParent():GetParent()
end

-- refresh list display
function CF_POIListMixin:RefreshListDisplay()
	-- found parent frame?
	local frame = self:GetParentFrame()
	if (frame:IsShown() == true) then
		-- create data provider
		local dataProvider = CreateDataProvider()

		-- has poi list?
		if (self.POIList and (#self.POIList > 0)) then
			-- process names
			for k,v in pairs(self.POINames) do
				local name, id = strsplit("@", v)
				id = tonumber(id)
				local info = { id = id, name = name, data = self.POIList[id] }
				dataProvider:Insert({info=info})
			end
		end

		-- update count
		self.POICount:SetText(strformat(L["%d POIs"], #self.POIList))

		-- update scroll box
		self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition)
		self.ScrollBox:ForEachFrame(function(button, elementData)
			-- update frame
			button:UpdateFrame()
		end)
	end
end

-- update queue list
function CF_POIListMixin:UpdatePOIList()
	-- initialize
	self.POIList = {}
	self.POINames = {}

	-- get map id
	local mapID = MapGetBestMapForUnit("player")
	if (mapID) then
		-- get pois for map
		local pois = AreaPoiInfoGetAreaPOIForMap(mapID)
		if (pois and (#pois > 0)) then
			-- process pois
			local count = 0
			for _,v in ipairs(pois) do
				-- get area poi info
				local info = AreaPoiInfoGetAreaPOIInfo(mapID, v)
				if (info and info.areaPoiID) then
					-- has position?
					if (info.position) then
						-- validate position
						local x, y = info.position:GetXY()
						if (x and y) then
							-- add position
							info.x = x
							info.y = y
						end
					end

					-- get name
					count = count + 1
					local name = tostring(info.name)
					if (not name or (name == "")) then name = tostring(info.atlasName) end
					name = strformat("%s@%d", name, count)

					-- add to list
					tinsert(self.POINames, name)
					tinsert(self.POIList, info)
				end
			end

			-- sort
			tsort(self.POINames)
		end
	end

	-- update
	self:UpdateCount()
	self:Update()
end

-- update count
function CF_POIListMixin:UpdateCount()
	-- update count
	self.POICount:SetText(strformat("%d POIs", #self.POIList))
end

-- update
function CF_POIListMixin:Update()
	-- refresh list display
	self:RefreshListDisplay()
end

-- on load
function CF_POIListMixin:OnLoad()
	-- setup the scroll box
	local view = CreateScrollBoxListLinearView()
	view:SetElementInitializer("CF_POIListEntryTemplate", function(button, elementData)
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
function CF_POIListMixin:OnShow()
	-- update queue list
	self:UpdatePOIList()
end

-- on update
function CF_POIListMixin:OnUpdate()
end

-- get selected entry for drop down
function CF_POIListMixin:GetSelectedEntryForDropDown()
	-- return selected entry
	return self.selectedEntryForDropDown
end

-- set selected entry for drop down
function CF_POIListMixin:SetSelectedEntryForDropDown(entry)
	-- save selected entry
	self.selectedEntryForDropDown = entry
end

-- create table
CF_POIListEntryMixin = {}

-- get parent frame
function CF_POIListEntryMixin:GetParentFrame()
	-- get frame
	return self:GetParent():GetParent():GetParent()
end

-- on click
function CF_POIListEntryMixin:OnClick(button)
	-- left button?
	if (button == "LeftButton") then
		-- display info
		local info = self.info.data
		print(strformat("%s: %s", L["Name"], self.info.name))
		print(strformat("%s %s: ", L["Area POI"], L["ID"], info.areaPoiID))
		if (info.description and (info.description ~= "")) then
			-- display description
			print(strformat("%s: %s", L["Description"], info.description))
		end
		print(strformat("%s: %s, %s", L["Position"], tostring(info.x), tostring(info.y)))
	end
end

-- on enter
function CF_POIListEntryMixin:OnEnter()
	-- start tooltip
	local info = self.info.data
	GameTooltip:SetOwner(self)

	-- add header
	local name = info.name
	if (not name or (name == "")) then name = tostring(info.atlasName) end
	GameTooltip:AddLine(name)

	-- add area poi ID
	GameTooltip:AddLine(strformat("Area POI ID: %d", tonumber(info.areaPoiID)), 1, 1, 1)

	-- has position?
	if (info.position and info.position.x and info.position.y) then
		-- add position
		GameTooltip:AddLine(strformat("Position: %s, %s", tostring(info.position.x), tostring(info.position.y)), 1, 1, 1)
	end

	-- has description?
	if (info.description and (info.description ~= "")) then
		-- add description
		GameTooltip:AddLine(strformat("Description: %s", tostring(info.description)), 1, 1, 1)
	end

	-- has textureIndex?
	if (info.textureIndex) then
		-- add texture index
		GameTooltip:AddLine(strformat("Texture Index: %d", tonumber(info.textureIndex)), 1, 1, 1)
	end

	-- has factionID?
	if (info.factionID) then
		-- add faction id
		GameTooltip:AddLine(strformat("Faction ID: %d", tonumber(info.factionID)), 1, 1, 1)
	end

	-- show tooltip
	GameTooltip:Show()
end

-- on leave
function CF_POIListEntryMixin:OnLeave()
	-- hide tooltip
	GameTooltip:Hide()
end

-- set queue
function CF_POIListEntryMixin:SetQueue(info)
	-- has queue info?
	if (info) then
		-- save queue info / text
		self.info = info
		self.guid = info.guid
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
function CF_POIListEntryMixin:Init(elementData)
	-- update frame
	self:UpdateFrame()

	-- has queue info?
	if (elementData.info) then
		-- set queue data
		local info = elementData.info
		self.guid = info.guid
		self:SetQueue(info)
	end
end

-- update frame
function CF_POIListEntryMixin:UpdateFrame()
	-- update frame
	local queueFrame = self.QueueFrame
	queueFrame.Name:ClearAllPoints()
	queueFrame.Name:SetPoint("LEFT", queueFrame, "LEFT", 0, 0)
	queueFrame:ClearAllPoints()
	queueFrame:SetPoint("LEFT", 4, 0)
	queueFrame:SetWidth(130)
end

-- create table
CF_POIListResizeBottomLeftButtonMixin = {}

-- on mouse down
function CF_POIListResizeBottomLeftButtonMixin:OnMouseDown(button)
	-- left button?
	if (button == "LeftButton") then
		-- start sizing
		CF_POIListFrame:StartSizing("BOTTOMLEFT")
	end
end

-- on mouse up
function CF_POIListResizeBottomLeftButtonMixin:OnMouseUp(button)
	-- left button?
	if (button == "LeftButton") then
		-- stop sizing
		CF_POIListFrame:StopMovingOrSizing("BOTTOMRIGHT")
	end
end

-- create table
CF_POIListResizeBottomRightButtonMixin = {}

-- on mouse down
function CF_POIListResizeBottomRightButtonMixin:OnMouseDown(button)
	-- left button?
	if (button == "LeftButton") then
		-- start sizing
		CF_POIListFrame:StartSizing("BOTTOMRIGHT")
	end
end

-- on mouse up
function CF_POIListResizeBottomRightButtonMixin:OnMouseUp(button)
	-- left button?
	if (button == "LeftButton") then
		-- stop sizing
		CF_POIListFrame:StopMovingOrSizing("BOTTOMRIGHT")
	end
end
