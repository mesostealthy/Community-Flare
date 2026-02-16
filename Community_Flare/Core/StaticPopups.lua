-- initialize
local LibStub = LibStub
local ADDON_NAME, NS = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
if (not L or not NS.CommFlare) then return end
 
-- localize stuff
local _G                                          = _G
local FocusActiveWindow                           = _G.ChatFrameUtil.FocusActiveWindow
local UninviteUnit                                = _G.UninviteUnit
local StaticPopup_StandardEditBoxOnEscapePressed  = _G.StaticPopup_StandardEditBoxOnEscapePressed
local pairs                                       = _G.pairs
local print                                       = _G.print
local strformat                                   = _G.string.format

------------------------------------------------------
-- Static Popup Dialog Boxes
------------------------------------------------------

-- copy player name dialog box 
StaticPopupDialogs["CommunityFlare_Copy_Player_Name_Dialog"] = {
	text = L["Copy Player Name for %s [Use Ctrl+c]:"],
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 31,
	editBoxWidth = 260,
	OnAccept = function(dialog, data)
		-- hide dialog
		FocusActiveWindow()
		dialog:GetEditBox():SetText("")
	end,
	OnShow = function(dialog, data)
		-- has player?
		if (data.player and (data.player ~= "")) then
			-- set current player
			local editBox = dialog:GetEditBox()
			editBox:SetText(data.player)
			editBox:HighlightText()
			editBox:SetFocus()
		end
	end,
	EditBoxOnEnterPressed = function(editBox, data)
		-- hide dialog
		editBox:GetParent():Hide()
	end,
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
	timeout = 0,
	exclusive = 1,
	whileDead = true,
	hideOnEscape = true
}

-- delete community dialog box
StaticPopupDialogs["CommunityFlare_Delete_Community_Dialog"] = {
	text = L["Are you sure you delete %s Community?"],
	button1 = L["Yes"],
	button2 = L["No"],
	OnAccept = function(dialog, data)
		-- has club?
		if (NS.db.global.clubs and NS.db.global.clubs[data.clubId]) then
			-- process all
			for k,v in pairs(NS.db.global.members) do
				-- has club?
				if (v.clubs and v.clubs[data.clubId]) then
					-- delete
					v.clubs[data.clubId] = nil

					-- count
					local count = 0
					for k,v in pairs(v.clubs) do
						-- increase
						count = count + 1
					end

					-- none left?
					if (count == 0) then
						-- delete
						v.clubs = nil
					end
				end
			end

			-- delete
			NS.db.global.clubs[data.clubId] = nil

			-- refresh list
			CF_CommunityListFrame:RefreshList()
		end
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
}

-- delete member dialog box
StaticPopupDialogs["CommunityFlare_Delete_Member_Dialog"] = {
	text = L["Are you sure you delete %s Member?"],
	button1 = L["Yes"],
	button2 = L["No"],
	OnAccept = function(dialog, data)
		-- has member?
		if (NS.db.global.members and NS.db.global.members[data.name]) then
			-- has history?
			if (NS.db.global.history and NS.db.global.history[data.name]) then
				-- delete
				NS.db.global.history[data.name] = nil
			end

			-- delete
			NS.db.global.members[data.name] = nil

			-- refresh list
			CF_MemberListFrame:RefreshList()
		end
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
}

-- kick dialog box
StaticPopupDialogs["CommunityFlare_Kick_Dialog"] = {
	text = L["Kick: %s?"],
	button1 = L["Yes"],
	button2 = L["No"],
	OnAccept = function(dialog, player)
		-- uninvite user
		print(strformat("%s %s", L["Uninviting ..."], player))
		UninviteUnit(player, L["AFK"])

		-- community auto invite enabled?
		local text = L["You've been removed from the party for being AFK."]
		if (NS.charDB.profile.communityAutoInvite == true) then
			-- update text for info about being reinvited
			text = strformat("%s %s", text, L["Whisper me INV and if a spot is still available, you'll be readded to the party."])
		end

		-- send message
		NS:SendMessage(player, text)
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
}

-- send community dialog box
StaticPopupDialogs["CommunityFlare_Send_Community_Dialog"] = {
	text = L["Send: %s?"],
	button1 = L["Send"],
	button2 = L["No"],
	OnAccept = function(dialog, message)
		-- setup report channels
		local count = NS:Setup_Report_Channels()
		if (count > 0) then
			-- send report messages
			NS:Send_Report_Messages(message)
		end
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
}

-- set community note dialog box 
StaticPopupDialogs["CommunityFlare_Set_Community_Note_Dialog"] = {
	text = L["Set Community Note for %s:"],
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 128,
	editBoxWidth = 260,
	OnAccept = function(dialog, data)
		-- has club?
		if (NS.db.global.clubs and NS.db.global.clubs[data.clubId]) then
			-- invalid text?
			local club = NS.db.global.clubs[data.clubId]
			local text = dialog:GetEditBox():GetText()
			if (not text or (text == "")) then
				-- delete note
				club.note = nil
			else
				-- update note
				club.note = text
			end
		end
	end,
	OnShow = function(dialog, data)
		-- has club?
		if (NS.db.global.clubs and NS.db.global.clubs[data.clubId]) then
			-- has note?
			local club = NS.db.global.clubs[data.clubId]
			if (club.note) then
				-- set current note
				local editBox = dialog:GetEditBox()
				editBox:SetText(club.note)
				editBox:SetFocus()
			end
		end
	end,
	OnHide = function(dialog, data)
		-- hide dialog
		FocusActiveWindow()
		dialog:GetEditBox():SetText("")
	end,
	EditBoxOnEnterPressed = function(editBox, data)
		-- has club?
		if (NS.db.global.clubs and NS.db.global.clubs[data.clubId]) then
			-- invalid text?
			local club = NS.db.global.clubs[data.clubId]
			local text = editBox:GetText()
			if (not text or (text == "")) then
				-- delete note
				club.note = nil
			else
				-- update note
				club.note = text
			end
		end

		-- hide dialog
		editBox:GetParent():Hide()
	end,
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
	timeout = 0,
	exclusive = 1,
	whileDead = true,
	hideOnEscape = true
}

-- set member note dialog box 
StaticPopupDialogs["CommunityFlare_Set_Member_Note_Dialog"] = {
	text = L["Set Member Note for %s:"],
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 128,
	editBoxWidth = 260,
	OnAccept = function(dialog, data)
		-- has member?
		if (NS.db.global.members and NS.db.global.members[data.name]) then
			-- has club?
			local member = NS.db.global.members[data.name]
			if (member and member.clubs and member.clubs[data.clubId]) then
				-- invalid text?
				local text = dialog:GetEditBox():GetText()
				if (not text or (text == "")) then
					-- delete note
					member.note = nil
				else
					-- update note
					member.note = text
				end
			end
		end
	end,
	OnShow = function(dialog, data)
		-- has member?
		if (NS.db.global.members and NS.db.global.members[data.name]) then
			-- has club?
			local member = NS.db.global.members[data.name]
			if (member and member.clubs and member.clubs[data.clubId]) then
				-- has member note?
				if (member.note and (member.note ~= "")) then
					-- set current note
					local editBox = dialog:GetEditBox()
					editBox:SetText(member.note)
					editBox:SetFocus()
				else
					-- has community note?
					local club = member.clubs[data.clubId]
					if (club and club.memberNote) then
						-- set current note
						local editBox = dialog:GetEditBox()
						editBox:SetText(club.memberNote)
						editBox:SetFocus()
					end
				end
			end
		end
	end,
	OnHide = function(dialog, data)
		-- hide dialog
		FocusActiveWindow()
		dialog:GetEditBox():SetText("")
	end,
	EditBoxOnEnterPressed = function(editBox, data)
		-- has member?
		if (NS.db.global.members and NS.db.global.members[data.name]) then
			-- has club?
			local member = NS.db.global.members[data.name]
			if (member and member.clubs and member.clubs[data.clubId]) then
				-- invalid text?
				local text = editBox:GetText()
				if (not text or (text == "")) then
					-- delete note
					member.note = nil
				else
					-- update note
					member.note = text
				end
			end
		end

		-- hide dialog
		editBox:GetParent():Hide()
	end,
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
	timeout = 0,
	exclusive = 1,
	whileDead = true,
	hideOnEscape = true
}

-- set player note dialog box 
StaticPopupDialogs["CommunityFlare_Set_Player_Note_Dialog"] = {
	text = L["Set Player Note for %s:"],
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 128,
	editBoxWidth = 260,
	OnAccept = function(dialog, data)
		-- member notes created?
		if (NS.db and NS.db.global and NS.db.global.MemberNotes) then
			-- invalid text?
			local text = dialog:GetEditBox():GetText()
			if (not text or (text == "")) then
				-- delete note
				NS.db.global.MemberNotes[data.guid] = nil
			else
				-- update member note
				NS.db.global.MemberNotes[data.guid] = text
			end
		end
	end,
	OnShow = function(dialog, data)
		-- has member note?
		if (NS.db and NS.db.global and NS.db.global.MemberNotes and NS.db.global.MemberNotes[data.guid]) then
			-- set current note
			local editBox = dialog:GetEditBox()
			editBox:SetText(NS.db.global.MemberNotes[data.guid])
			editBox:SetFocus()
		end
	end,
	OnHide = function(dialog, data)
		-- hide dialog
		FocusActiveWindow()
		dialog:GetEditBox():SetText("")
	end,
	EditBoxOnEnterPressed = function(editBox, data)
		-- member notes created?
		local text = editBox:GetText()
		if (NS.db and NS.db.global and NS.db.global.MemberNotes) then
			-- invalid text?
			if (not text or (text == "")) then
				-- delete note
				NS.db.global.MemberNotes[data.guid] = nil
			else
				-- update member note
				NS.db.global.MemberNotes[data.guid] = text
			end
		end

		-- hide dialog
		editBox:GetParent():Hide()
	end,
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
	timeout = 0,
	exclusive = 1,
	whileDead = true,
	hideOnEscape = true
}
