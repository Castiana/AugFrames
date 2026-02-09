-- ######################################################
-- Project: AugFrames
-- File: enUS.lua
-- Author: Sion Duncan
-- File Version: v1.0 
-- File purpose: Contains the English US variables
-- ######################################################

local L = LibStub("AceLocale-3.0"):NewLocale("AugFrames", "enUS", true)

if L then
	L["AddonName"] = "AugFrames"
	L["AddonVersionShort"] = "v1.0"
	L["AddonVersionLong"] = "Addon Version: v1.0"
	L["AddonDBVersion"] = "Database Version:"
	L["AddonEnabled"] = "Enabled"
	L["AddonDisabled"] = "Disabled"
	L["DBVersionCurrent"] = "Up to date!"
	L["DBVersionOld"] = "Your database is outdated. Please reset your database by entering one of the following commands into chat:\n/af reset\n/augframes reset."
	L["DBReset"] = "Your database has been reset to default values!"
	L["PositionMoveInstructions"] = "Hold down ALT and drag the frame to move it. Hold down SHIFT and drag the bottom right corner to resize it.\n\nOnce finished: Type /af save to save the new position and size, or /af reset to reset to default values."
	L["PositionSaveComplete"] = "Position and size saved!"
	L["PositionResetComplete"] = "Position reset to default values!"
	L["OptionsAddonEnableName"] = "Enable/Disable Addon"
	L["OptionsAddonEnableDesc"] = "Enable or disable the addon. This is usually set automatically by your active specialization This will not change any of your settings, just whether the addon is active or not."
	L["OptionsAreaConfigurationName"] = "Area Configuration"
	L["OptionsAreaConfigurationDesc"] = "Configure the spells and targets for each area."
	L["OptionsMainDesc"] = "Welcome to the AugFrames options menu!\n\nHere you can configure the spells and targets for each area. You can also move and resize the frame using /af move and /af save!\n\nIf you have any suggestions or find any bugs, please let me know on the issue tracker!"

	L["SlashHelp"] = "Slash Commands:\n/af move or /augframes move - Show instructions for moving and resizing the frame\n/af save or /augframes save - Save the current position and size of the frame\n/af resetdb or /augframes resetdb - Reset the addon to default configuration."

	L["OptionsSmartPartyTargettingName"] = "Smart Party Targetting"
    L["OptionsSmartPartyTargettingDesc"] = "Enable or disable smart party targetting.\n\nWhen enabled, the addon will attempt to cast Blistering Scales on the tank, Spatial Vortex on the Healer, and a Prescience on the other DPS when you are in a party. Enabling this will over-ride your other target settings.\n\nOnly applies to group play (not raids)."

	L["OptionsSplitConfigurationName"] = "Split Configuration"
    L["OptionsSplitConfigurationDesc"] = "Enable or disable split configuration.\n\nWhen enabled, the addon will allow Party and Raid to have different targets. When disabled, the addon will only use the configured raid targets."

	L["OptionsTOPLEFTName"] = "Top Left Area"
	L["OptionsTOPLEFTDesc"] = "Configuration for the Top Left area."
	L["OptionsTOPRIGHTName"] = "Top Right Area"
	L["OptionsTOPRIGHTDesc"] = "Configuration for the Top Right area."
	L["OptionsBOTTOMLEFTName"] = "Bottom Left Area"
	L["OptionsBOTTOMLEFTDesc"] = "Configuration for the Bottom Left area."
	L["OptionsBOTTOMRIGHTName"] = "Bottom Right Area"
	L["OptionsBOTTOMRIGHTDesc"] = "Configuration for the Bottom Right area."

	L["OptionsAreaConfigurationSpellDesc"] = "Enter the spell to cast when the area is clicked. You can use either the spell name or the spell ID.\n\nFor example, you could enter 'Prescience' or '409311'."
	L["OptionsAreaConfigurationUnitDesc"] = "Enter the target to cast the spell on when the area is clicked.\n\nPlease use the following format: PlayerName-RealmName (If the realm has a space in it, for example, Kul Tiras. Please enter it as KulTiras).\n\nIf the addon can't find the target, it will default to you."
	L["OptionsAreaConfigurationUnitName"] = "Unit to Target"
	L["OptionsAreaConfigurationSpellName"] = "Spell to Cast"
	L["OptionsAreaConfigurationHeaderSpell"] = "Spell Configuration"
	L["OptionsAreaConfigurationHeaderUnit"] = "Target Configuration"
end