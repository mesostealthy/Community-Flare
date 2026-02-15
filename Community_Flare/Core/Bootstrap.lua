-- initialize
local LibStub = LibStub
local ADDON_NAME, NS = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
if (not L) then return end

-- localize stuff
local _G                                          = _G
local GetAddOnMetadata                            = _G.C_AddOns.GetAddOnMetadata
local GetBuildInfo                                = _G.GetBuildInfo
local GetInviteConfirmationInfo                   = _G.GetInviteConfirmationInfo
local GetNextPendingInviteConfirmation            = _G.GetNextPendingInviteConfirmation
local RespondToInviteConfirmation                 = _G.RespondToInviteConfirmation
local Settings_OpenToCategory                     = _G.Settings.OpenToCategory
local SocialQueueUtil_GetRelationshipInfo         = _G.SocialQueueUtil_GetRelationshipInfo
local StaticPopup_FindVisible                     = _G.StaticPopup_FindVisible
local StaticPopup_Hide                            = _G.StaticPopup_Hide
local UnitFactionGroup                            = _G.UnitFactionGroup
local issecretvalue                               = _G.issecretvalue
local select                                      = _G.select
local tonumber                                    = _G.tonumber
local type                                        = _G.type
local strformat                                   = _G.string.format
local strmatch                                    = _G.string.match

-- initialize libraries
NS.Libs = {
	AceAddon = LibStub("AceAddon-3.0"),
	AceGUI = LibStub("AceGUI-3.0"),
	AceConfig = LibStub("AceConfig-3.0"),
	AceConfigDialog = LibStub('AceConfigDialog-3.0'),
	AceDB = LibStub("AceDB-3.0"),
	AceDBOptions = LibStub("AceDBOptions-3.0"),
	AceSerializer = LibStub("AceSerializer-3.0"),
	LibCompress = LibStub("LibCompress"),
	LibDeflate = LibStub("LibDeflate"),
	LibCandyBar = LibStub("LibCandyBar-3.0"),
	LibSharedMedia = LibStub("LibSharedMedia-3.0"),
}

-- initialize
NS.faction = (UnitFactionGroup("player") == FACTION_HORDE) and 0 or 1
NS.CommFlare = NS.Libs.AceAddon:NewAddon(ADDON_NAME, "AceComm-3.0", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")
if (not NS.CommFlare) then return end
NS.CommFlare.CF = {
	-- booleans
	AutoQueueable = false,
	CDMEnabled = false,
	CDMPersistent = false,
	ChannelStreamsLoaded = false,
	DefaultVerified = false,
	Disabled = false,
	InActiveDelve = false,
	InitialLogin = false,
	Invisible = false,
	HasAura = false,
	NewZoneWarning = false,
	PlayerListUpdated = false,
	PlayerMercenary = false,
	Popped = false,
	PvpLoggingCombat = false,
	QueuePopped = false,
	RaidLeadPassed = false,
	Reloaded = false,
	RunOnce = false,
	UpgradeDisplayed = false,
	VersionSent = false,

	-- misc
	Leader = nil,
	LeaderGUID = nil,
	Options = nil,
	PartyGUID = nil,
	TargetNearestEnemy = nil,
	TargetPreviousEnemy = nil,
	Winner = nil,

	-- numbers
	ClubCount = 0,
	Count = 0,
	CountDown = 0,
	CommCount = 0,
	EnteredTime = 0,
	EstimatedWaitTime = 0,
	Expiration = 0,
	GuildID = 0,
	HideIndex = 0,
	IsHealer = 0,
	IsTank = 0,
	LastRaidWarning = 0,
	LastRestrictPingTime = 0,
	LeftTime = 0,
	LogListCount = 0,
	MapID = 0,
	MatchEndTime = 0,
	MatchStartTime = 0,
	MatchStatus = 0,
	MaxPriority = 999,
	MercCount = 0,
	NumAllyGlaives = 0,
	NumHordeGlaives = 0,
	NumScores = 0,
	PassLeadWarning = 0,
	PlayerRank = 0,
	Position = 0,
	PreviousCount = 0,
	RegenOptions = 0,
	QuestID = 0,
	ScoreRequested = 0,
	StreamsRetryCount = 0,
	SavedTime = 0,

	-- strings
	MapName = L["N/A"],
	MatchEndDate = "",
	MatchStartDate = "",
	PlayerFullName = "",
	PlayerServerName = "",
	RaidLeader = L["N/A"],
	TurnSpeed = "",

	-- tables
	ActiveWidgets = {},
	ActiveTimers = {},
	AuraData = {},
	CappingBars = {},
	Clubs = {},
	ClubList = {},
	ClubMembers = {},
	CommCounts = {},
	CommCountsList = {},
	CommNames = {},
	CommNamesList = {},
	CommunityLeaders = {},
	DisplayedLists = {},
	FullRoster = {},
	KosAlerted = {},
	KosList = {},
	LocalData = {},
	LocalQueues = {},
	LogListNamesList = {},
	LogListPlayers = {},
	MapInfo = {},
	MemberInfo = {},
	MercCounts = {},
	MercCountsList = {},
	MercNames = {},
	MercNamesList = {},
	PartyVersions = {},
	PlayerInfo = {},
	POIInfo = {},
	PoppedGroups = {},
	ReadyCheck = {},
	RegenJobs = {},
	RoleChosen = {},
	RoleCounts = {},
	RosterList = {},
	SocialQueues = {},
	StatusCheck = {},
	StreamsLoaded = {},
	TeamUnits = {},
	TransmissionCheck = {},
	VehicleDeaths = {},
	VehicleList = {},
	VignetteWarnings = {},
	WaitForUpdate = {},
	WarCrateLocations = {},
	WidgetInfo = {},

	-- misc tables
	Alliance = { Count = 0, Healers = 0, Tanks = 0 },
	Horde = { Count = 0, Healers = 0, Tanks = 0 },
	Timer = { Minutes = 0, MilliSeconds = 0, Seconds = 0 },

	-- battlegrounds
	AB = {},
	ASH = {},
	AV = {},
	BFG = {},
	DHR = {},
	DWG = {},
	EOTS = {},
	IOC = {},
	SSH = {},
	SSM = {},
	SSvTM = {},
	TOK = {},
	TWP = {},
	WG = {},
	WSG = {},
}

-- updated during lockdown
NS.CommFlare.Updated = {
	Club_Added = {},
	Club_Member_Added = {},
	Club_Member_Presence_Updated = {},
	Club_Members_Updated = {},
	Club_Streams_Loaded = {},
}

-- setup version stuff
NS.CommFlare.Name = ADDON_NAME
NS.CommFlare.Build = GetAddOnMetadata(ADDON_NAME, "X-Build") or "unspecified"
NS.CommFlare.Title = GetAddOnMetadata(ADDON_NAME, "Title") or "unspecified"
NS.CommFlare.Version = GetAddOnMetadata(ADDON_NAME, "Version") or "unspecified"
NS.CommFlare.Title_Full = strformat("%s %s (%s)", NS.CommFlare.Title, NS.CommFlare.Version, NS.CommFlare.Build)
NS.CommFlare.InterfaceVersion = select(4, GetBuildInfo())

-- is outdated version?
function NS:IsOutdatedVersion()
	-- past supported version?
	if (NS.CommFlare.InterfaceVersion > 120001) then
		-- TODO: localize warning
		print(strformat("%s: WoW Interface Version beyond %d detected! Please UPGRADE from Curseforge or Wago!", NS.CommFlare.Title, NS.CommFlare.InterfaceVersion))
		return true
	end
	return false
end

-- handle pending invite confirmations
local function hook_HandlePendingInviteConfirmation(invite)
	-- mercenary queued?
	if (NS:Battleground_IsMercenaryQueued() == true) then
		-- get next pending invite
		local invite = GetNextPendingInviteConfirmation()
		if (invite) then
			-- get invite confirmation info
			local confirmationType, sender, guid, rolesInvalid, willConvertToRaid, level, spec, itemLevel = GetInviteConfirmationInfo(invite)
			local referredByGuid, referredByName, relationType, isQuickJoin, clubId = NS:GetInviteReferralInfo(invite)
			local playerName, color, selfRelationship = SocialQueueUtil_GetRelationshipInfo(guid, name, clubId)

			-- cancel invite
			RespondToInviteConfirmation(invite, false)

			-- hide popup
			if (StaticPopup_FindVisible("GROUP_INVITE_CONFIRMATION")) then
				-- hide
				StaticPopup_Hide("GROUP_INVITE_CONFIRMATION")
			end

			-- battle net friend?
			if (selfRelationship == "bnfriend") then
				local accountInfo = NS:GetAccountInfoByGUID(guid)
				if (accountInfo and accountInfo.gameAccountInfo and accountInfo.gameAccountInfo.playerGuid) then
					-- send battle net message
					NS:SendMessage(accountInfo.bnetAccountID, L["Sorry, can not accept invites while currently queued as a mercenary."])
				end
			else
				-- send message
				NS:SendMessage(sender, L["Sorry, can not accept invites while currently queued as a mercenary."])
			end
		end
	else
		-- call original
		NS.CommFlare.hooks["HandlePendingInviteConfirmation"](invite)
	end
end

-- on initialize
function NS.CommFlare:OnInitialize()
	-- get interface version
	NS.CommFlare.isMidnight = false
	if (NS.CommFlare.InterfaceVersion >= 120000) then
		-- midnight
		NS.CommFlare.isMidnight = true
	end

	-- load libraries
	NS.Libs.LibRangeCheck = LibStub("LibRangeCheck-3.0")
	NS.Libs.LibCompress.Encoder = NS.Libs.LibCompress:GetAddonEncodeTable()

	-- create config options
	NS:CreateConfigOptions()

	-- build stuff
	NS:Build_Battlegrounds()
	NS:Build_Classes()
	NS:Build_Spells()
	NS:Build_Training_Grounds()

	-- setup hook
	NS.CommFlare:RawHook("HandlePendingInviteConfirmation", hook_HandlePendingInviteConfirmation, true)

	-- create assist button
	NS:CreateAssistButton()
end

-- addon compartment on click
function CommunityFlare_AddonCompartmentOnClick(addonName, buttonName)
	-- already opened?
	if (SettingsPanel:IsShown()) then
		-- hide
		SettingsPanel:Hide()
	else
		-- open settings
		Settings_OpenToCategory(NS.optionsID)
	end
end
