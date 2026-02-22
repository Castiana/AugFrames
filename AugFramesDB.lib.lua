-- ######################################################
-- Project: AugFrames
-- File: AugFrames.lib.lua
-- Author: Sion Duncan
-- File Version: v1.0 
-- File purpose: Contains various functions used in other parts of the addon
-- ######################################################

-- ######################################################
-- This is my first addon, so it'll be heavily commented. Mostly for myself, but also to help others learn.  
-- ######################################################

AugFramesDBLibrary = {} -- Creating the global library variable

-- Init
function AugFramesDBLibrary:Init()
    -- Called when the addon is first loaded. This is where we set up our database and options.
    AugFramesDBLibrary.AugFramesDB = LibStub("AceDB-3.0"):New("AugFramesDB", AugFramesDBLibrary:GetAugFramesDBDefaults(), true)
end

-- Getter
function AugFramesDBLibrary:GetDB()
    return AugFramesDBLibrary.AugFramesDB
end

-- Setter
function AugFramesDBLibrary:SetDB(newDB)
    AugFramesDBLibrary.AugFramesDB = newDB
end

-- Is Enabled check, creating it's own function to save time later
function AugFramesDBLibrary:IsEnabled()
    return AugFramesDBLibrary:GetDB().profile.enabled
end

-- Reset the DB
function AugFramesDBLibrary:ResetDB()
    local blankDB = {}
    AugFramesDBLibrary:SetDB(nil)
    AugFramesDBLibrary:SetDB(blankDB)
    AugFramesDBLibrary:SetDB(AugFramesDBLibrary:GetAugFramesDBDefaults())
end

-- Creating an array of defaults incase we have no existing DB
function AugFramesDBLibrary:GetAugFramesDBDefaults()
	return {
        profile = {
            enabled = false, -- This is set automagically to true ONLY if the players current spec is Aug
            dbVersion = 1, -- Used to track what version of the DB has been loaded
            size = 100, -- Size of one side of the frame, since it's a square, that's all we need
            location = { "CENTER", "UIParent", "CENTER", 0, 0 }, -- Parent Frame Location
            targetinglocation = { "CENTER", "UIParent", "CENTER", 0, 0 }, -- Targeting Frame Location
            partyAutoTargetting = true, -- This is to control SmartTargetting when in a party
            supressTargettingWarning = false, -- Supress warnings when the player is the target
            generatedContextMenus = false, -- Used to track if we've generated our context menu options yet or not, so we don't generate them multiple times
            areaData = { -- This holds the configuration for the 4 clickable areas
                [1] = { type = "spell", spell = "409311", name = AFL["SpellPrescience"] , unit = "player", playerName = "player", icon = 5199639, location = "TOPLEFT"}, -- Top Left
                [2] = { type = "spell", spell = "409311", name = AFL["SpellPrescience"] , unit = "player", playerName = "player", icon = 5199639, location = "TOPRIGHT"}, -- Top Right
                [3] = { type = "spell", spell = "360827", name = AFL["SpellBlisteringScales"] , unit = "player", playerName = "player", icon = 5199621, location = "BOTTOMLEFT"}, -- Bottom Left
                [4] = { type = "spell", spell = "406732", name = AFL["SpellSpatialVortex"] , unit = "player", playerName = "player", icon = 5199645, location = "BOTTOMRIGHT"}, -- Bottom Right
            },
        },
	}
end

-- Setting defaults for any missing settings
function AugFramesDBLibrary:CheckDatabase()
    -- Simple 1 liner here. Check if AugFramesDB is already an array if not. Create a new one.
	if type(AugFramesDBLibrary:GetDB().profile.dbVersion) ~= "number" then AugFramesDBLibrary:SetDB(AugFramesDBLibrary:GetAugFramesDBDefaults()) end

    -- Let's check if we need to update the DB version
    if(AugFramesDBLibrary:GetDB().profile.dbVersion ~= AugFramesDBLibrary:GetAugFramesDBDefaults().profile.dbVersion) then
        print("|cff33937F" .. AFL["AddonName"] .. ":|r " .. AFL["DBVersionOld"]) -- Tell the user the DB is outdated
        
        --
        -- TODO: Add DB Update code here. 
        --
    end
end