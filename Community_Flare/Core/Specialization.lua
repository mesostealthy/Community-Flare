-- initialize
local LibStub = LibStub
local ADDON_NAME, NS = ...
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME, false)
if (not L or not NS.CommFlare) then return end

-- localize stuff
local _G                                          = _G
local GetClassInfo                                = _G.GetClassInfo
local GetNumClasses                               = _G.GetNumClasses
local GetNumSpecializationsForClassID             = _G.C_SpecializationInfo and _G.C_SpecializationInfo.GetNumSpecializationsForClassID or _G.GetNumSpecializationsForClassID
local GetSpecializationInfoForClassID             = _G.GetSpecializationInfoForClassID
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
		local className, classFile = GetClassInfo(classID)
		if (not NS.CommFlare.Classes[className]) then
			-- initialize
			NS.CommFlare.Classes[className] = {}
		end

		-- add class info
		NS.CommFlare.Classes[className].classID = classID
		NS.CommFlare.Classes[className].className = className
		NS.CommFlare.Classes[className].classFile = classFile
		NS.CommFlare.Classes[className].specs = {}

		-- process all specializations
		for specIndex=1, GetNumSpecializationsForClassID(classID) do
			-- getr specialization info / create specialization
			local specID, specName, specDescription, specIcon, role = GetSpecializationInfoForClassID(classID, specIndex)
			if (not NS.CommFlare.Classes[className].specs[specName]) then
				-- initialize
				NS.CommFlare.Classes[className].specs[specName] = {}
			end

			-- add specialization info
			NS.CommFlare.Classes[className].specs[specName].specID = specID
			NS.CommFlare.Classes[className].specs[specName].specName = specName
			NS.CommFlare.Classes[className].specs[specName].specIndex = specIndex
			NS.CommFlare.Classes[className].specs[specName].specDescription = specDescription
			NS.CommFlare.Classes[className].specs[specName].specIcon = specIcon
			NS.CommFlare.Classes[className].specs[specName].role = role

			-- increase
			count = count + 1
		end
	end

	-- return count
	return count
end

-- get specID from className & specName
function NS:Get_SpecID(className, specName)
	-- spec name exists?
	if (NS.CommFlare.Classes[className] and NS.CommFlare.Classes[className].specs and NS.CommFlare.Classes[className].specs[specName] and NS.CommFlare.Classes[className].specs[specName].specID) then
		-- return specID
		return NS.CommFlare.Classes[className].specs[specName].specID
	end

	-- failed
	return 0
end
