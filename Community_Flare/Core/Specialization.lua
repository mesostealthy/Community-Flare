-- initialize
local LibStub = LibStub
local ADDON_NAME, NS = ...
if (not NS.Loaded or not NS.Loaded["Social"]) then return end
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
if (not L or not NS.CommFlare) then return end

-- localize stuff
local _G                                          = _G
local GetClassInfo                                = _G.GetClassInfo
local GetNumClasses                               = _G.GetNumClasses
local GetNumSpecializationsForClassID             = _G.C_SpecializationInfo.GetNumSpecializationsForClassID
local tonumber                                    = _G.tonumber
local tostring                                    = _G.tostring
local strformat                                   = _G.string.format

-- build classes
NS.CommFlare.Classes = {}
function NS:Build_Classes()
	-- process all classes
	local count = 0
	for classID=1, GetNumClasses() do
		-- get class info / create class
		local className, classToken = GetClassInfo(classID)
		if (not NS.CommFlare.Classes[classToken]) then
			-- initialize
			NS.CommFlare.Classes[classToken] = {}
		end

		-- add class info
		NS.CommFlare.Classes[classToken].classID = classID
		NS.CommFlare.Classes[classToken].className = className
		NS.CommFlare.Classes[classToken].classToken = classToken
		NS.CommFlare.Classes[classToken].specs = {}

		-- process all specializations
		for specIndex=1, GetNumSpecializationsForClassID(classID) do
			-- getr specialization info / create specialization
			local specID, specName, specDescription, specIcon, role = NS:GetSpecializationInfoForClassID(classID, specIndex)
			if (not NS.CommFlare.Classes[classToken].specs[specName]) then
				-- initialize
				NS.CommFlare.Classes[classToken].specs[specName] = {}
			end

			-- add specialization info
			NS.CommFlare.Classes[classToken].specs[specName].specID = specID
			NS.CommFlare.Classes[classToken].specs[specName].specName = specName
			NS.CommFlare.Classes[classToken].specs[specName].specIndex = specIndex
			NS.CommFlare.Classes[classToken].specs[specName].specDescription = specDescription
			NS.CommFlare.Classes[classToken].specs[specName].specIcon = specIcon
			NS.CommFlare.Classes[classToken].specs[specName].role = role

			-- increase
			count = count + 1
		end
	end

	-- return count
	return count
end

-- get classID from classToken
function NS:Get_Class(classToken)
	-- class exists?
	if (NS.CommFlare.Classes[classToken]) then
		-- found
		return NS.CommFlare.Classes[classToken].classID, NS.CommFlare.Classes[classToken]
	end

	-- failed
	return nil
end

-- get specID from classToken & specName
function NS:Get_SpecID(classToken, specName)
	-- class/spec name exists?
	if (NS.CommFlare.Classes[classToken] and NS.CommFlare.Classes[classToken].specs and NS.CommFlare.Classes[classToken].specs[specName] and NS.CommFlare.Classes[classToken].specs[specName].specID) then
		-- return specID
		return NS.CommFlare.Classes[classToken].specs[specName].specID
	end

	-- failed
	return nil
end

-- fully loaded
NS.LoadCount = NS.LoadCount + 1
NS.Loaded["Specialization"] = NS.LoadCount
