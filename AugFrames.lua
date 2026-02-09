-- ######################################################
-- Project: AugFrames
-- File: AugFrames.lua
-- Author: Sion Duncan
-- File Version: v1.0 
-- File purpose: Primary lua file. I did write this in raw lua to start with,
--               but I swapped to the Ace3 framework for ease.
-- ######################################################

-- ######################################################
-- This is my first addon, so it'll be heavily commented. Mostly for myself, but also to help others learn. 
-- You'll notice I swap between "standard" before line comments and inline comments, don't ask me why...
-- Tidier I guess?
-- Github CoPilot decided to write most of the comments. I just let it do it's thing since it was mostly correct
-- ######################################################

-- 
-- TODO List:
-- 
-- Add the DB Upgrade stuff
-- Change the way the addon reads/writes to the DB. It's crap just now, need to make it cleaner and less entire db saving/writing
-- Fix the moving of the frame (Alt + Left click and drag instead of slash commands)
-- Add resizing of the frame (Since it didn't work the first time I wrote it. Shift + left click drag)
-- Add the ability to store group and raid targetting at the same time and swap between them based on group size


-- Initialise the addon using Ace3. Create a global called AugFrames to hold it
AugFrames = LibStub("AceAddon-3.0"):NewAddon("AugFrames", "AceConsole-3.0", "AceEvent-3.0")

-- Setup the localization library
AFL = LibStub("AceLocale-3.0"):GetLocale("AugFrames")

AugFramesLibrary = AugFramesLibrary or {} -- Make sure the library is global and can be accessed by other files.
AugFramesDBLibrary = AugFramesDBLibrary or {} -- Make sure the library is global and can be accessed by other files.
AugFramesOptionsLibrary = AugFramesOptionsLibrary or {} -- Make sure the library is global and can be accessed by other files.

function AugFrames:OnInitialize()
    -- Initialise and sanity check our DB
    AugFramesDBLibrary:Init()
    AugFramesDBLibrary:CheckDatabase()

    -- Initialise our options menu
    AugFramesOptionsLibrary:Init()

    -- Registering the slash commands
    AugFrames:RegisterChatCommand("augframes", function(msg) AugFramesLibrary:SlashCommand(msg) end) -- Registering the slash command. Took me a while to figure out how to pass this directly to the library function...
    AugFrames:RegisterChatCommand("af",  function(msg) AugFramesLibrary:SlashCommand(msg) end) -- Registering the shorter slash command. See above...
end

 -- Called when the addon is enabled. This is where we register events and set up our frames.
function AugFrames:OnEnable()
    AugFrames:RegisterEvent("PLAYER_ENTERING_WORLD", function() AugFramesLibrary:SpecCheck("player") end) -- Register for the entering world event
    AugFrames:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", function() AugFramesLibrary:SpecCheck("player") end) -- Register for the specialization change event
    AugFrames:RegisterEvent("GROUP_ROSTER_UPDATE", function() AugFramesLibrary:TargettingUpdate() end) -- Register for the group roster update event
end

-- Called when the addon is disabled. This is where we clean up any frames or events.
function AugFrames:OnDisable()
    AugFrames:DeregisterEvent("PLAYER_SPECIALIZATION_CHANGED") -- Deregister the specialization change event
    AugFrames:DeregisterEvent("PLAYER_ENTERING_WORLD") -- Deregister the entering world event
    AugFrames:DeregisterEvent("GROUP_ROSTER_UPDATE") -- Deregister the group roster update event
    AugFramesLibrary:TeardownFrames() -- Remove the frames from the screen and clean up memory
end