-- initialize
local LibStub = LibStub
local ADDON_NAME, NS = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
if (not L or not NS.CommFlare) then return end

-- localize stuff
local _G                                          = _G
local FCF_DockFrame                               = _G.FCF_DockFrame
local FCF_FadeInChatFrame                         = _G.FCF_FadeInChatFrame
local FCF_SetWindowName                           = _G.FCF_SetWindowName
local FCFDock_GetChatFrames                       = _G.FCFDock_GetChatFrames
local FCFDock_GetSelectedWindow                   = _G.FCFDock_GetSelectedWindow
local GetChatWindowInfo                           = _G.GetChatWindowInfo
local ReceiveAllPrivateMessages                   = _G.ChatFrameMixin and _G.ChatFrameMixin.ReceiveAllPrivateMessages or _G.ChatFrame_ReceiveAllPrivateMessages
local RemoveAllChannels                           = _G.ChatFrameMixin and _G.ChatFrameMixin.ReceiveAllPrivateMessages or _G.ChatFrame_RemoveAllChannels
local RemoveAllMessageGroups                      = _G.ChatFrameMixin and _G.ChatFrameMixin.ReceiveAllPrivateMessages or _G.ChatFrame_RemoveAllMessageGroups
local SetChatWindowLocked                         = _G.SetChatWindowLocked
local SetChatWindowShown                          = _G.SetChatWindowShown
local SetLastActiveWindow                         = _G.ChatFrameUtil and _G.ChatFrameUtil.SetLastActiveWindow or _G.ChatEdit_SetLastActiveWindow

-- local variables
local debugTab = nil
local debugFrame = nil

-- find free chat frame
function NS:Find_Free_Chat_Frame()
	-- process all
	for i=5, NUM_CHAT_WINDOWS do
		local name = GetChatWindowInfo(i)
		if (not name or (name == "")) then
			-- return index
			return i
		end
	end

	-- not found
	return nil
end

-- find debug window
function NS:Find_Chat_Frame(windowName)
	-- process all
	for i=5, NUM_CHAT_WINDOWS do
		local name = GetChatWindowInfo(i)
		if (name == windowName) then
			-- return index
			return i
		end
	end

	-- not found
	return nil
end

-- debug print
function NS:Debug_Print(text)
	-- find debug chat frame
	local index = NS:Find_Chat_Frame("Debug")
	if (not index) then
		-- get free chat frame index
		index = NS:Find_Free_Chat_Frame()
		if (index) then
			-- setup chat frame
			debugFrame = _G["ChatFrame" .. index]
			debugTab = _G["ChatFrame" .. index .. "Tab"]
			FCF_SetWindowName(debugFrame, "Debug")
			SetChatWindowLocked(index, false)
			debugFrame:Clear()

			-- listen to standard messages
			RemoveAllMessageGroups(debugFrame)
			RemoveAllChannels(debugFrame)
			ReceiveAllPrivateMessages(debugFrame)

			-- clear editbox history
			debugFrame.editBox:ClearHistory()
		end
	end

	-- found index?
	if (index and (index >= 5)) then
		-- setup chat frame
		debugFrame = _G["ChatFrame" .. index]
		debugTab = _G["ChatFrame" .. index .. "Tab"]

		-- not shown?
		if (debugTab:IsShown() == false) then
			-- show frame and tab
			debugFrame:Show()
			debugTab:Show()
			SetChatWindowShown(index, true)

			-- dock frame by default
			FCF_DockFrame(debugFrame, (#FCFDock_GetChatFrames(GENERAL_CHAT_DOCK)+1), true)
			FCF_FadeInChatFrame(FCFDock_GetSelectedWindow(GENERAL_CHAT_DOCK))
			SetLastActiveWindow(debugFrame.editBox)
		end

		-- found debug chat frame?
		if (debugFrame and debugTab) then
			-- add message
			debugFrame:AddMessage(text)
		end
	end
end
