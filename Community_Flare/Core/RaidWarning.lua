-- initialize
local LibStub = LibStub
local ADDON_NAME, NS = ...
if (not NS.Loaded or not NS.Loaded["Quests"]) then return end
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
if (not L or not NS.CommFlare) then return end

-- localize stuff
local _G                                          = _G
local CreateFrame                                 = _G.CreateFrame
local PlaySound                                   = _G.PlaySound

-- create frame
local frame = CreateFrame("ScrollingMessageFrame", nil, UIParent)
frame:SetSize(600, 120)
frame:SetPoint("TOP", UIParent, "TOP", 0, -100)
frame:SetJustifyH("CENTER")
frame:SetFont("Fonts\\FRIZQT__.TTF", 20, "OUTLINE")
frame:SetShadowColor(0, 0, 0, 1) 
frame:SetShadowOffset(2, -2) 

-- configure frame
frame:SetMaxLines(3)
frame:SetTimeVisible(5.0)
frame:SetFadeDuration(1.0)
frame:SetFading(true)
frame:SetInsertMode("TOP")

-- show message and souind
function NS:RaidWarning(msg)
	-- add message to frame
	local rwColor = ChatTypeInfo["RAID_WARNING"]
	frame:AddMessage(msg, rwColor.r, rwColor.g, rwColor.b) 
    
	-- play raid warning sound
	PlaySound(SOUNDKIT.RAID_WARNING, "Master") 
end

-- fully loaded
NS.LoadCount = NS.LoadCount + 1
NS.Loaded["RaidWarning"] = NS.LoadCount
