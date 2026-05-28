-- ######################################################
-- Project: AugFrames
-- File: enUS.lua
-- Author: Sion Duncan
-- File Version: v1.4
-- File purpose: Contains the English US variables
-- ######################################################

local L = LibStub("AceLocale-3.0"):NewLocale("AugFrames", "enUS", true)

if L then
	L["AddonName"] = "AugFrames"
	L["AddonVersionShort"] = "v1.4"
	L["AddonVersionLong"] = "Addon Version: v1.4"
	L["AddonDBVersion"] = "Database Version:"
	L["AddonEnabled"] = "Enabled"
	L["AddonDisabled"] = "Disabled"

	L["None"] = "None"
	L["RelativePoint"] = "Relative Point"
	L["RelativeTo"] = "Relative To"
	L["PoSFrameLiveLocation"] = "LIVE POS Frame Position: Point"
	L["PoSFrameDBLocation"] = "DB POS Frame Position: Point"

	L["SlashHelp"] = "Slash Commands:\n/af status or /augframes status - Shows the weather AugFrames is enabled or disabled.\n/af pos or /augframes pos - This will show you the current position of the main window of AugFrames.\n/af resetdb or /augframes resetdb - Reset the addon to default configuration.\n /af resetpos or /augframes resetpos - Reset the frame position to the center of the screen.\n"
	L["SlashCurrentSpecID"] = "Current SpecID"

	L["SpellPrescience"] = "Prescience"

	L["SpellPrescienceKeybind1"] = "Cast Prescience on Target 1"
	L["SpellPrescienceKeybind2"] = "Cast Prescience on Target 2"

	L["EditModeOnlyShowPrescienceName"] = "Only Show Prescience Frames"
	L["EditModeOnlyShowPrescienceTooltip"] = "Enable or disable only showing the Prescience Frames.\n\nWhen enabled, only the Prescience will be shown. This is for players who don't want the to show Blistering Scales and Spatial Vortex."

	L["SpellBlisteringScales"] = "Blistering Scales"
	L["SpellSpatialVortex"] = "Spatial Vortex"

	L["ContextMenuSetTarget"] = "Set as Target"

	L["TargetingFrameTANK"] = "Tank"
	L["TargetingFrameHEALER"] = "Healer"
	L["TargetingFrameDAMAGER"] = "DPS"

	L["TargetingFrameTitle"] = "AugFrames Targeting"

	L["DropDownMenuSelectTarget"] = "Select Target"

	L["Targets"] = "targets"

	L["TargettingCheckPlayerTargetted"] = " is currently targetting you!"

	L["DBVersionCurrent"] = "Up to date!"
	L["DBVersionOld"] = "Your database is outdated. Please reset your database by entering one of the following commands into chat:\n/af reset\n/augframes reset."
	L["DBReset"] = "Your database has been reset to default values!"

	L["PositionMoveInstructions"] = "Hold down ALT and drag the frame to move it. Hold down SHIFT and drag the bottom right corner to resize it.\n\nOnce finished: Type /af save to save the new position and size, or /af reset to reset to default values."
	L["PositionSaveComplete"] = "Position and size saved!"
	L["PositionResetComplete"] = "AugFrames reset to default location!"

	L["EditModePartyAutoTargettingName"] = "Automatic Party Targetting"
	L["EditModePartyAutoTargettingTooltip"] = "Enable or disable smart party targetting.\n\nWhen enabled, the addon will attempt to cast Blistering Scales on the tank, Spatial Vortex on the Healer, and a Prescience on the other DPS when you are in a party. Only applies to group play (not raids)."
	L["EditModeSupressTargettingName"] = "Suppress Targetting Warning"
	L["EditModeSupressTargettingTooltip"] = "Enable or disable the warnings that appear when a spell is targetting you."
	L["EditModeFrameSizeName"] = "Frame Size"
	L["EditModeFrameSizeTooltip"] = "Use the slider, or input box to change the size of the frame. Since the frame is a square, only one value is needed."


	L["ContextMenuSetTank"] = "Set as Blistering Scales Target"
	L["ContextMenuSetHealer"] = "Set as Spatial Vortex Target"
	L["ContextMenuSetDPS"] = "Set as Prescience Target"
	L["ContextMenuSetNone"] = "No Role Found!"

end