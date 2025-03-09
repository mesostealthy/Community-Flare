local ADDON_NAME, NS = ...
local L = LibStub("AceLocale-3.0"):NewLocale(ADDON_NAME, "enUS", true)

-- Battlegrounds.lua
L["%d minutes, %d seconds"] = true
L["%s: AFK after %d minutes, %d seconds?"] = true
L["%s: Healers = %d, Tanks = %d"] = true
L["%s: Not an epic battleground to track."] = true
L["%s: Not currently in an active match."] = true
L["%s: Not in battleground yet."] = true
L["%s has been queued for %d %s and %d %s for %s."] = true
L["%s Alliance Ready!"] = true
L["%s Currently Queued For %s."] = true
L["%s Dropped Mercenary Queue For %s!"] = true
L["%s Dropped Queue For %s!"] = true
L["%s Horde Ready!"] = true
L["%s Joined Queue For %s! Estimated Wait: %s!"] = true
L["%s Joined Mercenary Queue For %s! Estimated Wait: %s!"] = true
L["%s Mercenary Queue Popped For %s!"] = true
L["%s Queue Popped For %s!"] = true
L["%s [%d Tanks, %d Healers, %d DPS]"] = true
L["Accepted Queue For Popped %s!"] = true
L["Alliance"] = true
L["Alterac Valley"] = true
L["Arathi Basin"] = true
L["Ashran"] = true
L["Ashran Options"] = true
L["Battle for Wintergrasp"] = true
L["Bunkers Left"] = true
L["Community Counts: %s"] = true
L["Community Members"] = true
L["Community Members: %s"] = true
L["Community Mercenaries: %s"] = true
L["Currently Queued for"] = true
L["Date: %s; MapName: %s; Raid Leader: %s; Player: %s; Roster: %s"] = true
L["Deepwind Gorge"] = true
L["Defense"] = true
L["Destroyed"] = true
L["Dropped Queue for"] = true
L["East"] = true
L["Entered Mercenary Queue For Popped %s!"] = true
L["Entered Queue For Popped %s!"] = true
L["Estimated Wait"] = true
L["Eye of the Storm"] = true
L["For auto invite, whisper me INV"] = true
L["Front"] = true
L["Gates Destroyed"] = true
L["Horde"] = true
L["IBT"] = true
L["Isle of Conquest"] = true
L["IWB"] = true
L["Jeron"] = true
L["Joined Queue for"] = true
L["joined the queue for"] = true
L["Just entered match. Gates not opened yet!"] = true
L["Korrak's Revenge"] = true
L["Left Mercenary Queue For Popped %s!"] = true
L["Left Queue For Popped %s!"] = true
L["Left Queue for Popped"] = true
L["Level"] = true
L["Mercenary"] = true
L["Mercenary Counts: %s"] = true
L["minutes"] = true
L["Missed Mercenary Queue For Popped %s!"] = true
L["Missed Queue For Popped %s!"] = true
L["Missed Queue for Popped"] = true
L["N/A"] = true
L["North"] = true
L["Not currently in an epic battleground or queue!"] = true
L["Offense"] = true
L["Port Expired"] = true
L["Queue for %s has paused!"] = true
L["Queue for %s has resumed!"] = true
L["Queue Popped for"] = true
L["Raid Leader"] = true
L["Random Battleground"] = true
L["Random Epic Battleground"] = true
L["Rylai"] = true
L["seconds"] = true
L["Seething Shore"] = true
L["SHB"] = true
L["Silvershard Mines"] = true
L["Sorry, Battle.NET auto invite not enabled."] = true
L["Sorry, community auto invite not enabled."] = true
L["Sorry, currently in a battleground now."] = true
L["Sorry, currently in a brawl now."] = true
L["Sorry, group is currently full."] = true
L["South"] = true
L["Temple of Kotmogu"] = true
L["The Battle for Gilneas"] = true
L["Time Elapsed"] = true
L["Total Members: %d"] = true
L["Total Mercenaries: %d"] = true
L["Towers Destroyed"] = true
L["Towers Left"] = true
L["TP"] = true
L["Twin Peaks"] = true
L["Up"] = true
L["Warsong Gulch"] = true
L["West"] = true
L["Wintergrasp"] = true

-- Bootstrap.lua
L["Sorry, can not accept invites while currently queued as a mercenary."] = true

-- Config.lua
L["%d community leaders found."] = true
L["1 Member"] = true
L["2 Members"] = true
L["3 Seconds"] = true
L["3 Members"] = true
L["4 Seconds"] = true
L["4 Members"] = true
L["5 Seconds"] = true
L["5 Members"] = true
L["6 Seconds"] = true
L["7 Days"] = true
L["14 Days"] = true
L["15 Seconds"] = true
L["30 Days"] = true
L["30 Seconds"] = true
L["60 Seconds"] = true
L["Adjust vehicle turn speed?"] = true
L["All"] = true
L["All Community Members"] = true
L["Always automatically queue?"] = true
L["Always pass Raid Leadership to Community Leaders?"] = true
L["Always remove, then re-add community channels to general?"] = true
L["Always request party leadership? (Community Leaders Only)"] = true
L["Always save Combat Log inside PVP content?"] = true
L["Assistants Only"] = true
L["Automatically accept invites from Battle.NET friends?"] = true
L["Automatically accept invites from community members?"] = true
L["Automatically blocks shared quests during a battleground."] = true
L["Auto assist community members?"] = true
L["Automatically promotes community members to raid assist in matches."] = true
L["Automatically queue if your group leader is in community?"] = true
L["Automatically queue if your group leader is your Battle.Net friend?"] = true
L["Battleground Options"] = true
L["Block game menu hotkeys inside PVP content?"] = true
L["Block shared quests?"] = true
L["Choose the communities that you want to build the leaders list from."] = true
L["Choose the communities that you want to report info to."] = true
L["Choose the communities that you want to save a roster list upon the gate opening in battlegrounds."] = true
L["Choose the community that you want to report queues to."] = true
L["Choose the main community from your subscribed list."] = true
L["Choose the other communities from your subscribed list."] = true
L["Communities to Report to?"] = true
L["Community Leaders?"] = true
L["Community Options"] = true
L["Community Right Click Menu?"] = true
L["Community to report to?"] = true
L["Database members found: %s"] = true
L["Database Options"] = true
L["Debug Options"] = true
L["Default (180)"] = true
L["Disabled"] = true
L["Display community member names when running /comf command?"] = true
L["Display notification for popped groups?"] = true
L["Enable debug mode to help debug issues?"] = true
L["Enable the right click menu for community member list?"] = true
L["Fast (360)"] = true
L["Frequency?"] = true
L["Guild Members?"] = true
L["Instance Chat Warning"] = true
L["Invite Options"] = true
L["Irrelevant"] = true
L["Leaders Only"] = true
L["Local Warning Only"] = true
L["Log roster list for matches from these communities?"] = true
L["Main Community?"] = true
L["Max (540)"] = true
L["Max Party Size?"] = true
L["Mercenary Contract"] = true
L["None"] = true
L["Notify you upon given party leadership?"] = true
L["Notify you upon party member zone changes?"] = true
L["Notify you when a War Supply Crate is inbound?"] = true
L["Notify you when the Ancient Inferno has spawned?"] = true
L["Notify you when your Mage is under attack?"] = true
L["One or more of the changes you have made require a ReloadUI."] = true
L["Other Communities?"] = true
L["Party Options"] = true
L["Performs an action if you are about to hearth stone or teleport out of an active battleground."] = true
L["Player List Manager?"] = true
L["Pops up a box to uninvite any users that are AFK at the time of queuing."] = true
L["Popup PVP queue window upon leaders queing up? (Only for group leaders.)"] = true
L["Purge logged roster matches timeframe?"] = true
L["Queue Options"] = true
L["Raid Warning"] = true
L["Rebuilding community database member list."] = true
L["Rebuild Members?"] = true
L["Refresh Members?"] = true
L["Report Options"] = true
L["Report queue status to communities?"] = true
L["Restrict /ping system to?"] = true
L["Tanks & Healers Only"] = true
L["This is the amount of time before it starts purging logged roster list for matches."] = true
L["This is the amount of time delayed between Mage attacks in Ashran."] = true
L["This will adjust your turn speed while inside of a vehicle to make them turn faster during a battleground."] = true
L["This will always attempt to request party leadership upon joining a new party. (Only for Community Leaders!)"] = true
L["This will always automatically accept all queues for you."] = true
L["This will automatically accept group/party invites from Battle.NET friends."] = true
L["This will automatically accept group/party invites from community members."] = true
L["This will automatically delete communities channels from general and re-add them upon login."] = true
L["This will automatically display all community members found in the battleground when the /comf command is run."] = true
L["This will automatically enable the combat logging to WowCombatLog while inside an arena or battleground."] = true
L["This will automatically pass Raid Leadership inside Battlegrounds to Community Leaders by priority levels."] = true
L["This will automatically queue if your group leader is in community."] = true
L["This will automatically queue if your group leader is your Battle.Net friend."] = true
L["This will block players from using the /ping system if they do not have raid assist or raid lead."] = true
L["This will block the game menus from coming up inside an arena or battleground from pressing their hot keys. (To block during recording videos for example.)"] = true
L["This will display a notification in your General chat window when groups pop."] = true
L["This will do various things to help with debugging bugs in the addon to help MESO fix bugs."] = true
L["This will open up the PVP queue window if a leader is queing up for PVP so you can queue up too."] = true
L["This will provide a quick popup message for you to send your queue status to the Community chat."] = true
L["This will provide a warning message or popup message for Group Leaders, if/when their queue becomes paused."] = true
L["This will provide a warning message when you are honor capped, or close to it when queuing."] = true
L["This will set the maximum party members you want in your group."] = true
L["This will show a raid warning to you when a War Supply Crate is coming in."] = true
L["This will show a raid warning to you when you are given leadership of your party."] = true
L["This will show a raid warning to you when the Ancient Inferno has spawned in Ashran."] = true
L["This will show a raid warning to you when your Mage is under attack in Ashran."] = true
L["This will show you a message when a party member changes zones."] = true
L["This will treat your Guild Members as Community Members."] = true
L["Uninvite any players that are AFK?"] = true
L["Use this to manage the Players and KOS in the Member GUIDs list."] = true
L["Use this to refresh the members database from currently selected communities."] = true
L["Use this to totally rebuild the members database from currently selected communities."] = true
L["Warn before hearth stoning or teleporting inside a battleground?"] = true
L["Warn if/when queues become paused?"] = true
L["Warn when Honor capped or close to it?"] = true
L["WARNING: Close to Honor capped! Please spend some!"] = true
L["WARNING: Honor capped! Please spend some!"] = true
L["World Options"] = true
L["You are not currently in a Guild."] = true

-- Database.lua
L["-%s = %d member/s"] = true
L["%s: %s Deployed Members."] = true
L["%s: %s (%d, %d) added to community %s."] = true
L["%s: %s (%d, %d) added to guild %s."] = true
L["%s: %s (%d, %d) removed from community %s."] = true
L["%s: %s (%d, %d) removed from guild %s."] = true
L["%s: Added %d %s members to the database."] = true
L["%s: No members are deployed."] = true
L["%s: No members are deployed for %s."] = true
L["%s: No subscribed clubs found."] = true
L["%s: Removed %d %s members from the database."] = true
L["Around"] = true
L["Count: %d"] = true
L["Inactive: %s"] = true
L["Inactive: %s; Last Active: %s"] = true
L["is NOT in the Database."] = true
L["Moved: %s to %s"] = true
L["No Completed Matches: %s"] = true
L["No Grouped Matches: %s"] = true
L["Not Member: %s"] = true
L["Not seen recently."] = true

-- Events.lua
L["%s: %d Community Leaders found."] = true
L["%s: Alliance Gate = %.1f, Horde Gate = %.1f"] = true
L["%s: Checking for inactive players."] = true
L["%s: Listing Community Leaders"] = true
L["%s: Local variables have been exposed globally for examination."] = true
L["%s: No Groups have popped recently."] = true
L["%s: Not currently in queue."] = true
L["%s: Refreshed members database! %d members found."] = true
L["%s: Reset %d profile settings to default."] = true
L["%s: You must enable Debug Mode in Community Flare Addon settings to use this feature."] = true
L["%s has %s %s (%s)"] = true
L["%s has changed zones to %s."] = true
L["%s is under attack!"] = true
L["%s (%s left.)"] = true
L["%s version %s update available. Download the latest version from curseforge!"] = true
L["Ancient Inferno has spawned at the Ring of Conquest!"] = true
L["Are you really sure you want to hearthstone?"] = true
L["Are you really sure you want to teleport?"] = true
L["Auto declined quest from"] = true
L["begone, uncouth scum!"] = true
L["Checking for inactive members"] = true
L["Checking for members not seen recently"] = true
L["Checking for members who never have completed a match with you"] = true
L["Checking for members who you've never grouped with"] = true
L["Checking for older members"] = true
L["Cleared clubs database!"] = true
L["Cleared members database!"] = true
L["Count: %d"] = true
L["CPU Usage"] = true
L["Deserter"] = true
L["deserter"] = true
L["Dumping POIs:"] = true
L["Dumping Vehicles:"] = true
L["Dumping Vignettes:"] = true
L["Epic battleground has completed with a"] = true
L["Entered"] = true
L["Exited the current match after it concluded."] = true
L["Exited the current match before it concluded."] = true
L["Frame positions have been reset."] = true
L["Full Now"] = true
L["has requested to join your group"] = true
L["High Warlord Volrath"] = true
L["I currently have the %s buff! (Are we mercing?)"] = true
L["I have not left the previously popped queue for %s."] = true
L["Jeron Emberfall"] = true
L["jeron emberfall has been slain"] = true
L["Killed"] = true
L["Leaving party to avoid interrupting the queue"] = true
L["Listing"] = true
L["loss"] = true
L["Map ID: Not Found"] = true
L["Memory Usage"] = true
L["Ready"] = true
L["%s: Reset %d profile settings to default."] = true
L["rylai crestfall has been slain"] = true
L["Someone has deserter debuff"] = true
L["Sorry, I currently have deserter"] = true
L["victory"] = true
L["War Supply Crate is flying in now!"] = true
L["WARNING: REPORTED INACTIVE!\nGet into combat quickly!"] = true
L["WARNING: SHADOW RIFT!\nCast immunity or run out of the circle!"] = true
L["YOU ARE CURRENTLY THE NEW GROUP LEADER"] = true
L["you will be removed from"] = true
L["your kind has no place in alterac valley"] = true

-- Init.lua
L["AFK"] = true
L["Are you sure you want to wipe the members database and totally rebuild from scratch?"] = true
L["Blood"] = true
L["Brewmaster"] = true
L["Discipline"] = true
L["Guardian"] = true
L["Holy"] = true
L["Kick: %s?"] = true
L["Mistweaver"] = true
L["No"] = true
L["Preservation"] = true
L["Protection"] = true
L["Restoration"] = true
L["Send"] = true
L["Send: %s?"] = true
L["Set Player Note for %s:"] = true
L["Uninviting ..."] = true
L["Vengeance"] = "Venganza"
L["War Supply Crate has been looted for the Alliance!"] = true
L["War Supply Crate has been looted for the Horde!"] = true
L["War Supply Crate has fully dropped to the ground!"] = true
L["War Supply Crate is dropping in now!"] = true
L["Whisper me INV and if a spot is still available, you'll be readded to the party."] = true
L["Yes"] = true
L["You've been removed from the party for being AFK."] = true

-- Menus.lua
L["Community Messages Sent"] = true
L["Completed Match Count"] = true
L["First Seen"] = true
L["Grouped Match Count"] = true
L["Last Community Message Sent"] = true
L["Last Grouped"] = true
L["Last Seen"] = true
L["Last Seen Around?"] = true
L["Request Party Leader"] = true

-- Social.lua
L["POPPED"] = true

-- UI/PlayerListFrame.lua
L["Add KOS"] = true
L["Copy Player Name"] = true
L["Copy Player Name for %s [Use Ctrl+c]:"] = true
L["Delete Player"] = true
L["Player List Manager"] = true
L["Remove KOS"] = true
L["Set Player Note"] = true

-- blizzard translated strings
L["Captain Balinda Stonehearth"] = true		-- https://nether.wowhead.com/tooltip/npc/11949?dataEnv=1&locale=enUS
L["Captain Galvangar"] = true			-- https://nether.wowhead.com/tooltip/npc/11947?dataEnv=1&locale=enUS
