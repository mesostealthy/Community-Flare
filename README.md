Community Flare is a project dedicated to making life easier to be able to sync up and play Battlegrounds with your friends easier.

The core features include:

- Community Database Member tracking, matches played, last online, etc.
- Auto Queue settings when your party leader queues up for Battlegrounds.
- Block Shared Quests inside Battlegrounds. (That is so annoying, stop it!)
- Easily selectable Community boxes for Main and Other Communities.
- Automatically accept invites from Battle.NET friends or Community members.
- Report Queue status, i.e. Joined, Left, Drop, Popped to Community.
- Uninvite Players that are AFK when you are Queing up.
- Automatically give out Raid Assist to your Community members. (Requires Raid Leadership.)
- Slash commands for various stuff, like /comf to check some counts inside a Battleground.
- Warning before accidentically casting a Hearthstone or Teleporting out of a Battleground.
- Restrict users from using the PING system without being Raid Leader or Assistant.
- Base code for different Locales, so far, only enUS added for support. (If you want to translate to others, please contact Mesostealthy in Alterac Valley Maniacs, or comment down below.)

Quite a few other Quality of Life features and/or parts of the above core that improve your Community Battleground queuing experience.

-----------------------
Latest Updates:
-----------------------
v1.20.003
-Auto Invite feature now working when in a Raid, for example for Korrak's Revenge.
-NEW Queue Setting: Warn when Honor capped or close to it upon queuing?
-Removed some more debug code.

v1.19.001
-NEW Party Setting: Notify you upon party member zone changes? (Only visible for Group Leaders.)
-NEW World Options Category: Notify you when a War Supply Crate is inbound. (Also adds starting TomTom map pin.)
-NEW Ashran Settings: Notify when Mage is under attack & set Frequency for repeat warnings.
-NEW Ashran Settings: Notify when Ancient Inferno spawns at the Ring of Conquest.
-Korrak's Revenge: Relevant Quests are now shareable with Irrelevant setting in Korrak's Revenge.
-Reporting Queues/Pops/Joins/Missed/Left will now only show Level X for less than 80.
-BUGFIX: Invited to a party already in queue will now auto select role and accept properly.
-REWORK: Addon Settings GUI redone a la more weizPVP style! A lot of the settings are global now.
-Bumped TOC to v11.0.5

v1.18.001
-FEATURE: Reports to your party when you exit a Battleground. (If you're in a party.)
-BUGFIX: You are no longer spammed with "You aren't in a party" after Delve has been completed!

v1.17.002
-FEATURE: Show Raid Warning if you try casting Notorious Thread's Hearthstone inside a Battleground.
-FEATURE: Show Raid Warning if you try casting Teleport: Dornogal inside a Battleground.
-New setting to treat your Guild Members as if they are Community Members.
-Block game menu hotkeys inside PVP content will now block inside Brawls.
-Community Counts displayed are now sorted alphabetically.
-BUGFIX: You are no longer spammed with "You aren't in a party" while performing Delves in a solo group!

v1.16.002 features:
-BUGFIX: Fixed some more LUA bugs found, this time relating to Brawls.

v1.16.001 features:
-New Version Check Feature: Shows a message if it detects someone with a newer version of Community Flare.
-New /comf find inactivity to search Community Member database for members not active more than 60 days.
-BUGFIX: Fixed lua error with mercenary text.
-Bumped TOC to v11.0.2

v1.15.001 features:
-New Option: Always pass Raid Leadership to Community Leaders? (Passes Raid Leadership to Community Leaders by priority if enabled.)
-New Debug Command: /comf pois to view all points of interest in your current location.
-New Debug Command: /comf popped to view all currently popped groups, if there are any.
-New Debug Command: /comf vignettes to view all vignettes in your current location.

v1.14.003 features:
-!status check now reports number of Community Members in the Battleground for all maps.
-BUGFIX: Restrict /ping system to? updated to new system. (None, Leaders Only, Assistants Only, Tanks & Healers Only)
-BUGFIX: Some more LUA bugs found due to various new systems.

v1.14.002 features:
-BUGFIX: Fix some LUA bugs found due to various new systems.

v1.14 features:
-New Command: /comf report added to send your current queues to community, with auto INV message if enabled & party has room.
-!status check for Battle for Wintergrasp now reports Vehicle counts.
-!status check now reports status for Arathi Basin.
-!status check now reports status for Brawl: Southshore vs. Tarren Mill.
-!status check now reports status for Deep Wind Gorge.
-!status check now reports status for Eye of the Storm.
-!status check now reports status for Seething Shore.
-!status check now reports status for Silvershard Mines.
-!status check now reports status for Temple of Kotmogu.
-!status check now reports status for The Battle for Gilneas.
-!status check now reports status for Twin Peaks Gulch.
-!status check now reports status for Warsong Gulch.
--Player you message !status must have v1.14 or higher for these to report back!
-BUGFIX: Fixed Block game menu hotkeys inside PVP content. (This is disabled by default, only enable if you know what it's doing!)
-BUGFIX: Fixed the Context Menus to work with the new UIDropDownMenu system.
-Bumped TOC to v11.0.0

v1.13 features:
-New Command: /comf debug added to better help with debugging issues for Mesostealthy & others to report. (Must have Debug Mode enabled to utilize.)
-New Option: Always save Combat Log inside PVP content, will always save combat logs for PVP matches.
-When joining tracked PVP Queues, it will now report your current faction when reporting.
-BUGFIX: If /reload used during Battleground, match data/roster was not saved into the match log list.
-Bumped TOC to v10.2.7

v1.12 features:
-New Feature: Right click on your Party Members to "Request Party Lead". (They must have Community Flare v1.12+ as well.)
-BUGFIX: Fixed some issues with the Community Leaders priority being updated properly.
-Bumped TOC to v10.2.6

v1.11 features:
-History: Added more stuff to track, like first seen, last channel message time, channel message count, etc.
-New /comf find <x> <y> commands to search Community Member database for various stuff.
--x = inactive to search for members who you have never seen online.
--x = nocompleted to search for members who have never completed a match with you.
--x = nogrouped to search for members who have never grouped with you.
---y = Short name for Communities to search from a specific Community.
-BUGFIX: Notification now shows properly when someone is removed from a Community.
-Old Command: /comf findold is now /comf find old

v1.10 features:
-Only group leaders can report to community when they leave a queue.
-Auto group invite now auto invites if the first word whispered is inv or invite. (Not case sensitive.)
-BUGFIX: Last Seen now works again properly when right clicking on a Community Member.

v1.09 features:
-Last Seen Around option only shows for community member list now.
-Bumped TOC to v10.2.5

v1.08 features:
-!status check while inside Isle of Conquest should now report Gate Percentages.
-BUGFIX: Fixed !status reporting a win/loss properly as a Mercenary.

v1.07 features:
-New /comf deployed command to check if you still have people in community deployed in PVP.
-New setting to allow Community Leaders list to only build from selected Communities.
-Block game menu hotkeys inside PVP content reworked a bit with raw hooks.

v1.06 features:
-New setting to force Tank/Healer/DPS specialization for PVP in Queue Options.
--This setting forces a role if you are invited to a party that is already in queue!

v1.05 features:
-Match Logs are kept for previous 7 days only to avoid super large settings files.
-/comf options will open the Community Flare options.

v1.04 features:
-Block group invites if you are currently queued for a Battleground as a mercenary.
--This normally would auto accept the invite and drop your queue!

v1.03 features:
-No Subscribed clubs found message will only show up once per character that does not have any club selected.
-Can Report Queue Joins/Drops/Pops/etc for Brawl: Comp Stomp.
-Log Names List now stores properly if you are a Mercenary.
-New Setting: Display notification for popped groups?
--If enabled, will show popped groups and member counts.
-frFR Locale language has first been added.
-Added better queue tracking stuff.

v1.02 features:
-Removed esMX language from Locales loading, was just there for testing purposes before.
-When gates open, Mercenary names will show counts from communities now.

v1.01 features:
-Added ability to obtain CF data to other CF users in the same Main Community.
-Updated some Locales strings and converted some more.
