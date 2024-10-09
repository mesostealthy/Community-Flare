-- initialize
local LibStub = LibStub
local ADDON_NAME, NS = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
if (not L) then return end

-- localize stuff
local _G                                        = _G
local GetAddOnMetadata                          = _G.C_AddOns and _G.C_AddOns.GetAddOnMetadata or _G.GetAddOnMetadata
local GetInviteConfirmationInfo                 = _G.GetInviteConfirmationInfo
local GetNextPendingInviteConfirmation          = _G.GetNextPendingInviteConfirmation
local RespondToInviteConfirmation               = _G.RespondToInviteConfirmation
local Settings_OpenToCategory                   = _G.Settings.OpenToCategory
local SocialQueueUtil_GetRelationshipInfo       = _G.SocialQueueUtil_GetRelationshipInfo
local StaticPopup_FindVisible                   = _G.StaticPopup_FindVisible
local StaticPopup_Hide                          = _G.StaticPopup_Hide
local BattleNetGetAccountInfoByGUID             = _G.C_BattleNet.GetAccountInfoByGUID
local PartyInfoGetInviteReferralInfo            = _G.C_PartyInfo.GetInviteReferralInfo
local tonumber                                  = _G.tonumber
local type                                      = _G.type
local strformat                                 = _G.string.format

-- initialize libraries
NS.Libs = {
	AceAddon = LibStub("AceAddon-3.0"),
	AceGUI = LibStub("AceGUI-3.0"),
	AceConfig = LibStub("AceConfig-3.0"),
	AceConfigDialog = LibStub('AceConfigDialog-3.0'),
	AceDB = LibStub("AceDB-3.0"),
	AceDBOptions = LibStub("AceDBOptions-3.0"),
	AceSerializer = LibStub("AceSerializer-3.0"),
	LibDeflate = LibStub("LibDeflate"),
}

-- initialize
NS.CommFlare = NS.Libs.AceAddon:NewAddon(ADDON_NAME, "AceComm-3.0", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")
if (not NS.CommFlare) then return end
NS.CommFlare.CF = {
	-- strings
	MapName = L["N/A"],
	MatchEndDate = "",
	MatchStartDate = "",
	PlayerFaction = "",
	PlayerServerName = "",
	RaidLeader = L["N/A"],
	TurnSpeed = "",

	-- booleans
	AutoInvite = false,
	AutoPromote = false,
	AutoQueue = false,
	AutoQueueable = false,
	DefaultVerified = false,
	Disabled = false,
	InitialLogin = false,
	Invisible = false,
	HasAura = false,
	MatchStartLogged = false,
	NeedAddonData = false,
	Popped = false,
	PvpLoggingCombat = false,
	QueuePopped = false,
	Reloaded = false,
	UpgradeDisplayed = false,
	VersionSent = false,

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
	LastBossRW = 0,
	LastMageRW = 0,
	LeftTime = 0,
	LogListCount = 0,
	MapID = 0,
	MatchEndTime = 0,
	MatchStartTime = 0,
	MatchStatus = 0,
	MaxPriority = 999,
	MercCount = 0,
	NumScores = 0,
	PlayerRank = 0,
	Position = 0,
	PreviousCount = 0,
	QuestID = 0,
	StreamsRetryCount = 0,
	SavedTime = 0,

	-- misc
	Category = nil,
	Field = nil,
	Header = nil,
	Leader = nil,
	LeaderGUID = nil,
	Options = nil,
	PartyGUID = nil,
	PopupMessage = nil,
	Winner = nil,

	-- tables
	AuraData = {},
	Clubs = {},
	ClubList = {},
	ClubMembers = {},
	CommCounts = {},
	CommCountsList = {},
	CommNames = {},
	CommNamesList = {},
	CommunityLeaders = {},
	CurrentPopped = {},
	FullRoster = {},
	LocalData = {},
	LocalQueues = {},
	LogListNamesList = {},
	MapInfo = {},
	MemberInfo = {},
	MenuData = {},
	MercCounts = {},
	MercCountsList = {},
	MercNames = {},
	MercNamesList = {},
	PartyVersions = {},
	PlayerInfo = {},
	POIInfo = {},
	PoppedGroups = {},
	ReadyCheck = {},
	RoleChosen = {},
	RoleCounts = {},
	RosterList = {},
	SocialQueues = {},
	StatusCheck = {},
	StreamsLoaded = {},
	TeamUnits = {},
	WidgetCache = {},
	WidgetInfo = {},

	-- misc stuff
	Alliance = { Count = 0, Healers = 0, Tanks = 0 },
	Horde = { Count = 0, Healers = 0, Tanks = 0 },
	Timer = { Minutes = 0, MilliSeconds = 0, Seconds = 0 },

	-- battleground specific data
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

-- setup version stuff
NS.CommFlare.Name = ADDON_NAME
NS.CommFlare.Build = GetAddOnMetadata(ADDON_NAME, "X-Build") or "unspecified"
NS.CommFlare.Title = GetAddOnMetadata(ADDON_NAME, "Title") or "unspecified"
NS.CommFlare.Version = GetAddOnMetadata(ADDON_NAME, "Version") or "unspecified"
NS.CommFlare.Title_Full = strformat("%s %s (%s)", NS.CommFlare.Title, NS.CommFlare.Version, NS.CommFlare.Build)

-- refresh config
function NS.CommFlare:RefreshConfig()
	-- setup community lists
	NS:Setup_Main_Community_List(nil)
	NS:Setup_Other_Community_List(nil)
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
			local referredByGuid, referredByName, relationType, isQuickJoin, clubId = PartyInfoGetInviteReferralInfo(invite)
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
				local accountInfo = BattleNetGetAccountInfoByGUID(guid)
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

-- global defaults
NS.GlobalDefaults = {
	-- global
	global = {
		-- tables
		clubs = {},
		history = {},
		matchLogList = {},
		members = {},
		SocialQueues = {},
	},
}

-- on initialize
function NS.CommFlare:OnInitialize()
	-- setup stuff
	NS.globalDB = NS.Libs.AceDB:New("CommunityFlareDB", NS.GlobalDefaults)
	NS.charDB = NS.Libs.AceDB:New("CommFlareCharDB", NS.defaults)
	NS.charDB.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
	NS.charDB.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
	NS.charDB.RegisterCallback(self, "OnProfileReset", "RefreshConfig")
	NS.Libs.AceConfig:RegisterOptionsTable("CommFlare_Options", NS.options)
	self.optionsFrame = NS.Libs.AceConfigDialog:AddToBlizOptions("CommFlare_Options", NS.CommFlare.Title)
	NS.profiles = NS.Libs.AceDBOptions:GetOptionsTable(NS.charDB)
	NS.Libs.AceConfig:RegisterOptionsTable("CommFlare_Profiles", NS.profiles)
	self.profilesFrame = NS.Libs.AceConfigDialog:AddToBlizOptions("CommFlare_Profiles", "Profiles", NS.CommFlare.Title)
	NS.CommFlare:RawHook("HandlePendingInviteConfirmation", hook_HandlePendingInviteConfirmation, true)

	-- check for old string values?
	if (type(NS.charDB.profile.blockSharedQuests) == "string") then
		-- convert to number
		NS.charDB.profile.blockSharedQuests = tonumber(NS.charDB.profile.blockSharedQuests)
	end
	if (type(NS.charDB.profile.communityAutoAssist) == "string") then
		-- convert to number
		NS.charDB.profile.communityAutoAssist = tonumber(NS.charDB.profile.communityAutoAssist)
	end
	if (type(NS.charDB.profile.uninvitePlayersAFK) == "string") then
		-- convert to number
		NS.charDB.profile.uninvitePlayersAFK = tonumber(NS.charDB.profile.uninvitePlayersAFK)
	end

	-- build classes
	NS:Build_Classes()
end

-- addon compartment on click
function CommunityFlare_AddonCompartmentOnClick(addonName, buttonName)
	-- already opened?
	if (SettingsPanel:IsShown()) then
		-- hide
		SettingsPanel:Hide()
	else
		-- open options to Community Flare
		Settings_OpenToCategory(NS.CommFlare.Title)
		Settings_OpenToCategory(NS.CommFlare.Title) -- open options again (wow bug workaround)
	end
end
