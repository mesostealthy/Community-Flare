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
local VignetteInfoGetVignettes                    = _G.C_VignetteInfo.GetVignettes
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
CF_VignetteListFrameMixin = CreateFromMixins(CallbackRegistryMixin)

-- on load
function CF_VignetteListFrameMixin:OnLoad()
	-- update header text
	local title = strformat("CF %s", L["Vignette List Manager"])
	self.HeaderFrame.Title:SetText(title)

	-- register stuff
	self:SetResizeBounds(250, 250)
	self:RegisterForDrag("LeftButton")
	self:RegisterEvent("VIGNETTES_UPDATED")

	-- closes when you press Escape
	--tinsert(UISpecialFrames, self:GetName())
end

-- on show
function CF_VignetteListFrameMixin:OnShow()
	-- refresh list
	self:RefreshList()
end

-- on drag start
function CF_VignetteListFrameMixin:OnDragStart()
	-- start moving
	self:StartMoving()
	self.moving = true
end

-- on drag stop
function CF_VignetteListFrameMixin:OnDragStop()
	-- stop moving
	self:StopMovingOrSizing()
	self.moving = nil
end

-- on event
function CF_VignetteListFrameMixin:OnEvent(event, ...)
	-- vignettes updated?
	if (event == "VIGNETTES_UPDATED") then
		-- refresh list
		self:RefreshList()
	end
end

-- refresh list
function CF_VignetteListFrameMixin:RefreshList()
	-- update / refresh
	self.VignetteListFrame.VignetteList:UpdateVignetteList()
	self.VignetteListFrame.VignetteList:RefreshListDisplay()
end

-- create table
CF_VignetteListCloseButtonMixin = {}

-- get parent frame
function CF_VignetteListCloseButtonMixin:GetParentFrame()
	-- get frame
	return self:GetParent():GetParent()
end

-- close button on click
function CF_VignetteListCloseButtonMixin:OnClick(button)
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
function CF_VignetteListCloseButtonMixin:OnEnter()
	-- show tooltip
	GameTooltip:SetOwner(self)
	GameTooltip:AddLine("Close")
	GameTooltip:AddLine("-Left Click: Close Window", 1, 1, 1)
	GameTooltip:Show()
end

-- close button on leave
function CF_VignetteListCloseButtonMixin:OnLeave()
	-- hide tooltip
	GameTooltip:Hide()
end

-- create table
CF_VignetteListRefreshButtonMixin = {}

-- get parent frame
function CF_VignetteListRefreshButtonMixin:GetParentFrame()
	-- get frame
	return self:GetParent():GetParent()
end

-- refresh button on click
function CF_VignetteListRefreshButtonMixin:OnClick(button)
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
function CF_VignetteListRefreshButtonMixin:OnEnter()
	-- show tooltip
	GameTooltip:SetOwner(self)
	GameTooltip:AddLine("Refresh")
	GameTooltip:AddLine("-Left Click: Refresh All Vignettes", 1, 1, 1)
	GameTooltip:Show()
end

-- refresh button on leave
function CF_VignetteListRefreshButtonMixin:OnLeave()
	-- hide tooltip
	GameTooltip:Hide()
end

-- create table
CF_VignetteListMixin = {}

-- get parent frame
function CF_VignetteListMixin:GetParentFrame()
	-- get frame
	return self:GetParent():GetParent()
end

-- refresh list display
function CF_VignetteListMixin:RefreshListDisplay()
	-- found parent frame?
	local frame = self:GetParentFrame()
	if (frame:IsShown() == true) then
		-- create data provider
		local dataProvider = CreateDataProvider()

		-- has vignette list?
		if (self.VignetteList and (#self.VignetteList > 0)) then
			-- process names
			for k,v in pairs(self.VignetteNames) do
				local name, id = strsplit("@", v)
				id = tonumber(id)
				local info = { id = id, name = name, data = self.VignetteList[id] }
				dataProvider:Insert({info=info})
			end
		end

		-- update count
		self.VignetteCount:SetText(strformat(L["%d Vignettes"], #self.VignetteList))

		-- update scroll box
		self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition)
		self.ScrollBox:ForEachFrame(function(button, elementData)
			-- update frame
			button:UpdateFrame()
		end)
	end
end

-- update queue list
function CF_VignetteListMixin:UpdateVignetteList()
	-- initialize
	self.VignetteList = {}
	self.VignetteNames = {}

	-- get map id
	local mapID = NS:GetBestMapForUnit("player")
	if (mapID) then
		-- process any vignettes
		local guids = VignetteInfoGetVignettes()
		if (guids and (#guids > 0)) then
			-- process guids
			local count = 0
			for _,v in ipairs(guids) do
				-- get vignette info
				local info = NS:GetVignetteInfo(v)
				if (info and info.vignetteID) then
					-- get position
					local pos = NS:GetVignettePosition(v, mapID)
					if (pos) then
						-- get x/y
						local x, y = pos:GetXY()
						if (x and y) then
							-- save position
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
					tinsert(self.VignetteNames, name)
					tinsert(self.VignetteList, info)
				end
			end

			-- sort
			tsort(self.VignetteNames)
		end
	end

	-- update
	self:UpdateCount()
	self:Update()
end

-- update count
function CF_VignetteListMixin:UpdateCount()
	-- update count
	self.VignetteCount:SetText(strformat("%d Vignettes", #self.VignetteList))
end

-- update
function CF_VignetteListMixin:Update()
	-- refresh list display
	self:RefreshListDisplay()
end

-- on load
function CF_VignetteListMixin:OnLoad()
	-- setup the scroll box
	local view = CreateScrollBoxListLinearView()
	view:SetElementInitializer("CF_VignetteListEntryTemplate", function(button, elementData)
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
function CF_VignetteListMixin:OnShow()
	-- update queue list
	self:UpdateVignetteList()
end

-- on update
function CF_VignetteListMixin:OnUpdate()
end

-- get selected entry for drop down
function CF_VignetteListMixin:GetSelectedEntryForDropDown()
	-- return selected entry
	return self.selectedEntryForDropDown
end

-- set selected entry for drop down
function CF_VignetteListMixin:SetSelectedEntryForDropDown(entry)
	-- save selected entry
	self.selectedEntryForDropDown = entry
end

-- create table
CF_VignetteListEntryMixin = {}

-- get parent frame
function CF_VignetteListEntryMixin:GetParentFrame()
	-- get frame
	return self:GetParent():GetParent():GetParent()
end

-- on click
function CF_VignetteListEntryMixin:OnClick(button)
	-- left button?
	local info = self.info.data
	if (button == "LeftButton") then
		-- add header
		local name = info.name
		if (not name or (name == "")) then name = tostring(info.atlasName) end
		print(strformat("%s: %s", L["Name"], name))
		print(strformat("%s %s: %d", L["Vignette"], L["ID"], tonumber(info.vignetteID)))
		print(strformat("%s %s: %s", L["Vignette"], L["GUID"], tostring(info.vignetteGUID)))
		if (info.description and (info.description ~= "")) then
			-- display description
			print(strformat("%s: %s", L["Description"], info.description))
		end
		print(strformat("%s: %s, %s", L["Position"], tostring(info.x), tostring(info.y)))
	end
end

-- on enter
function CF_VignetteListEntryMixin:OnEnter()
	-- start tooltip
	local info = self.info.data
	GameTooltip:SetOwner(self)

	-- add header
	local name = info.name
	if (not name or (name == "")) then name = tostring(info.atlasName) end
	GameTooltip:AddLine(name)

	-- add vignette ID
	GameTooltip:AddLine(strformat("Vignette ID: %d", tonumber(info.vignetteID)), 1, 1, 1)

	-- add vignette guid
	GameTooltip:AddLine(strformat("Vignette GUID: %s", tostring(info.vignetteGUID)), 1, 1, 1)

	-- has position?
	if (info.x and info.y) then
		-- add position
		GameTooltip:AddLine(strformat("Position: %s, %s", tostring(info.x), tostring(info.y)), 1, 1, 1)
	end

	-- show tooltip
	GameTooltip:Show()
end

-- on leave
function CF_VignetteListEntryMixin:OnLeave()
	-- hide tooltip
	GameTooltip:Hide()
end

-- set queue
function CF_VignetteListEntryMixin:SetQueue(info)
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
function CF_VignetteListEntryMixin:Init(elementData)
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
function CF_VignetteListEntryMixin:UpdateFrame()
	-- update frame
	local queueFrame = self.QueueFrame
	queueFrame.Name:ClearAllPoints()
	queueFrame.Name:SetPoint("LEFT", queueFrame, "LEFT", 0, 0)
	queueFrame:ClearAllPoints()
	queueFrame:SetPoint("LEFT", 4, 0)
	queueFrame:SetWidth(130)
end

-- create table
CF_VignetteListResizeBottomLeftButtonMixin = {}

-- on mouse down
function CF_VignetteListResizeBottomLeftButtonMixin:OnMouseDown(button)
	-- left button?
	if (button == "LeftButton") then
		-- start sizing
		CF_VignetteListFrame:StartSizing("BOTTOMLEFT")
	end
end

-- on mouse up
function CF_VignetteListResizeBottomLeftButtonMixin:OnMouseUp(button)
	-- left button?
	if (button == "LeftButton") then
		-- stop sizing
		CF_VignetteListFrame:StopMovingOrSizing("BOTTOMRIGHT")
	end
end

-- create table
CF_VignetteListResizeBottomRightButtonMixin = {}

-- on mouse down
function CF_VignetteListResizeBottomRightButtonMixin:OnMouseDown(button)
	-- left button?
	if (button == "LeftButton") then
		-- start sizing
		CF_VignetteListFrame:StartSizing("BOTTOMRIGHT")
	end
end

-- on mouse up
function CF_VignetteListResizeBottomRightButtonMixin:OnMouseUp(button)
	-- left button?
	if (button == "LeftButton") then
		-- stop sizing
		CF_VignetteListFrame:StopMovingOrSizing("BOTTOMRIGHT")
	end
end
