-- ######################################################
-- Project: AugFrames
-- File: AugFramesOptions.lib.lua
-- Author: Sion Duncan
-- File Version: v1.0 
-- File purpose: Contains the Options Menu configuration and code
-- ######################################################

-- ######################################################
-- This is my first addon, so it'll be heavily commented. Mostly for myself, but also to help others learn. 
-- ######################################################

AugFramesOptionsLibrary = {} -- Creating the global library variable

-- Init
function AugFramesOptionsLibrary:Init()
    -- Called when the addon is first loaded. This is where we set up our database and options.
    AugFramesOptionsLibrary.Config = LibStub("AceConfig-3.0")
    AugFramesOptionsLibrary.Dialog = LibStub("AceConfigDialog-3.0")
    AugFramesOptionsLibrary.Config:RegisterOptionsTable("AugFrames_options", AugFramesOptionsLibrary:DefaultOptions())
    AugFramesOptionsLibrary.optionsFrame = AugFramesOptionsLibrary.Dialog:AddToBlizOptions("AugFrames_options", "AugFrames")
end

function AugFramesOptionsLibrary:UpdateAreaSpellOptions(index, spellId)
    local tmpDB = AugFramesDBLibrary:GetDB() -- Get the DB
    local areaData = tmpDB.profile.areaData[index] -- Get the area data for the specified index
    local spellData = C_Spell.GetSpellInfo(spellId) -- Get the spell name and icon from the spell ID
    
    -- AugFramesLibrary:DumpTable(spellData)

    areaData.spell = spellId -- Update the spell ID in the DB
    areaData.name = spellData.name -- Update the spell name in the DB
    areaData.icon = spellData.iconID -- Update the spell icon in the DB

    tmpDB.profile.areaData[index] = areaData -- Update the area data in the DB
    
    AugFramesDBLibrary:SetDB(tmpDB)

    AugFramesLibrary:RebuildFrames() -- Rebuild the frames after an update
end

function AugFramesOptionsLibrary:SaveTarget(index, value)
    if InCombatLockdown() then return end -- Check if the player is in combat. If we are, do nothing so we don't taint
    
    local tmpDB = AugFramesDBLibrary:GetDB() -- Get the DB
    
    tmpDB.profile.areaData[index].unitRaid = value -- Update the target unit in the DB
    
    AugFramesDBLibrary:SetDB(tmpDB) -- Set the DB with the new target
    AugFramesLibrary:RebuildFrames() -- Rebuild the frames after an update
end

function AugFramesOptionsLibrary:GenerateAreaOption(index)
    local output = {}
    local areaData = AugFramesDBLibrary:GetDB().profile.areaData[index]
    output = {
        type = "group",
        name = AFL["Options" .. areaData.location .. "Name"],
        desc = AFL["Options" .. areaData.location .. "Desc"],
        order = index,
        args = {
            spellHeader = {
                type = "header",
                name = AFL["OptionsAreaConfigurationHeaderSpell"],
                order = 0,
            },
            spellDesc = {
                type = "description",
                name = AFL["OptionsAreaConfigurationSpellDesc"],
                order = 1,
            },
            spell = {
                type = "input",
                name = AFL["OptionsAreaConfigurationSpellName"],
                desc = AFL["OptionsAreaConfigurationSpellDesc"],
                order = 5,
                get = function(info) return areaData.spell end,
                set = function(info, value) AugFramesOptionsLibrary:UpdateAreaSpellOptions(index, value) end,
            },
            spacer = {
                type = "description",
                name = " ",
                order = 10,
            },
            unitHeader = {
                type = "header",
                name = AFL["OptionsAreaConfigurationHeaderUnit"],
                order = 15,
            },
            unitDesc = {
                type = "description",
                name = AFL["OptionsAreaConfigurationUnitDesc"],
                order = 20,
            },
            unit = {
                type = "input",
                name = AFL["OptionsAreaConfigurationUnitName"],
                desc = AFL["OptionsAreaConfigurationUnitDesc"],
                order = 25,
                get = function(info) return areaData.unitRaid end,
                set = function(info, value) AugFramesOptionsLibrary:SaveTarget(index, value) end,
            },
        },
    }
    return output
end

function AugFramesOptionsLibrary:DefaultOptions()
    -- Getting the DB
    local tmpDB = AugFramesDBLibrary:GetDB()
    -- Options menu
    local options = {
        name = AFL["AddonName"],
        handler = AugFrames,
        type = "group",
        args = {
            description = {
                type = "description",
                name = AFL["OptionsMainDesc"],
                order = 1,
            },
            smartPartyTargettingContainer = {
                type = "group",
                name = AFL["OptionsSmartPartyTargettingName"],
                desc = AFL["OptionsSmartPartyTargettingDesc"],
                order = 20,
                args = {
                    smartPartyTargettingHeader = {
                        type = "header",
                        name = AFL["OptionsSmartPartyTargettingName"],
                        order = 1,
                    },
                    smartPartyTargettingDesc = {
                        type = "description",
                        name = AFL["OptionsSmartPartyTargettingDesc"],
                        order = 2,
                    },
                    smartPartyTargetting = {
                        type = "toggle",
                        name = AFL["OptionsSmartPartyTargettingName"],
                        desc = AFL["OptionsSmartPartyTargettingDesc"],
                        order = 3,
                        get = function(info) return tmpDB.profile.smartPartyTargetting end,
                        set = function(info, value) 
                            tmpDB.profile.smartPartyTargetting = value
                            AugFramesDBLibrary:SetDB(tmpDB)
                        end,
                    },
                },
            },
            splitConfigurationContainer = {
                type = "group",
                name = AFL["OptionsSplitConfigurationName"],
                desc = AFL["OptionsSplitConfigurationDesc"],
                order = 30,
                args = {
                    splitConfigurationHeader = {
                        type = "header",
                        name = AFL["OptionsSplitConfigurationName"],
                        order = 1,
                    },
                    splitConfigurationDesc = {
                        type = "description",
                        name = AFL["OptionsSplitConfigurationDesc"],
                        order = 2,
                    },
                    splitConfigurationTargetting = {
                        type = "toggle",
                        name = AFL["OptionsSplitConfigurationName"],
                        desc = AFL["OptionsSplitConfigurationDesc"],
                        order = 3,
                        get = function(info) return tmpDB.profile.splitConfiguration end,
                        set = function(info, value)
                            tmpDB.profile.splitConfiguration = value
                            AugFramesDBLibrary:SetDB(tmpDB)
                        end,
                    },
                },
            },
            areaConfiguration = {
                type = "group",
                name = AFL["OptionsAreaConfigurationName"],
                desc = AFL["OptionsAreaConfigurationDesc"],
                order = 40,
                childGroups = "tree",
                args = {
                    topLeft = AugFramesOptionsLibrary:GenerateAreaOption(1),
                    topRight = AugFramesOptionsLibrary:GenerateAreaOption(2),
                    bottomLeft = AugFramesOptionsLibrary:GenerateAreaOption(3),
                    bottomRight = AugFramesOptionsLibrary:GenerateAreaOption(4),
                },
            }
        },
    }
    return options
end