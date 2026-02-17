-- ######################################################
-- Project: AugFrames
-- File: AugFramesOptions.lib.lua
-- Author: Sion Duncan
-- File Version: v2.0 
-- File purpose: Contains the Options Menu configuration and code
-- ######################################################

-- ######################################################
-- This is my first addon, so it'll be heavily commented. Mostly for myself, but also to help others learn. 
-- ######################################################

AugFramesOptionsLibrary = {} -- Creating the global library variable

-- Init
function AugFramesOptionsLibrary:Init()
    -- Setting up Edit Mode
    AugFramesOptionsLibrary.EditMode = LibStub("LibEQOLEditMode-1.0")

    local tmpDB = AugFramesDBLibrary:GetDB() -- Get the DB
    local pointCurrent, _, _, axisX, axisY = unpack(tmpDB.profile.location) -- Get the saved location from the DB
    local AugFramesMainFrame = _G["AugFramesMainFrame"]
    AugFramesMainFrame.editModeName = "AugFrames Configuration" -- Sets the title of the EditMode configuration window

    AugFramesOptionsLibrary.EditMode:AddFrame(AugFramesMainFrame, function(frame, _, point, x, y)
        frame:ClearAllPoints()
        frame:SetPoint(point, UIParent, point, x, y)
        AugFramesOptionsLibrary:SaveEditModeLocation(point, x, y)
     end, {
        point = pointCurrent,
        x = axisX,
        y = axisY,
        allowDrag = true,
        dragEnabled = true,
    })

    AugFramesOptionsLibrary.EditMode:AddFrameSettings(AugFramesMainFrame, AugFramesOptionsLibrary:GenerateEditModeSettings())
end

function AugFramesOptionsLibrary:GenerateEditModeSettings()
    local tmpDB = AugFramesDBLibrary:GetDB() -- Get the DB

    return  {
        {
            name = AFL["EditModePartyAutoTargettingName"],
            tooltip = AFL["EditModePartyAutoTargettingTooltip"],
            kind = AugFramesOptionsLibrary.EditMode.SettingType.Checkbox,
            default = true,
            get = function() return tmpDB.profile.smartPartyTargetting end,
            set = function(info, value)
                tmpDB.profile.smartPartyTargetting = value
                AugFramesDBLibrary:SetDB(tmpDB)
            end,
        },
        {
            name = AFL["EditModeSupressTargettingName"],
            tooltip = AFL["EditModeSupressTargettingTooltip"],
            kind = AugFramesOptionsLibrary.EditMode.SettingType.Checkbox,
            default = false,
            get = function() return tmpDB.profile.supressTargettingWarning end,
            set = function(info, value)
                tmpDB.profile.supressTargettingWarning = value
                AugFramesDBLibrary:SetDB(tmpDB)
            end,
        },
        {
            name = AFL["EditModeFrameSizeName"],
            tooltip = AFL["EditModeFrameSizeTooltip"],
            kind = AugFramesOptionsLibrary.EditMode.SettingType.Slider,
            defaults = { slider = 50 },
            field = "size",
            minValue = 1,
            maxValue = 700,
            step = 10,
            allowInput = true,
            get = function() return tmpDB.profile.size end,
            set = function(_, value)
                AugFramesOptionsLibrary:SaveEditModeSize(value)
            end,
        },
    }
end

function AugFramesOptionsLibrary:SaveEditModeSize(size)
    local tmpDB = AugFramesDBLibrary:GetDB() -- Get the DB
    tmpDB.profile.size = size -- Update the size
    AugFramesDBLibrary:SetDB(tmpDB) -- Save the DB Back
    AugFramesLibrary:RebuildFrames() -- Rebuild the frames after an update
end

function AugFramesOptionsLibrary:SaveEditModeLocation(point, x, y)
    local tmpDB = AugFramesDBLibrary:GetDB() -- Get the DB
    tmpDB.profile.location = { point, "UIParent", point, x, y } -- Create a new location table with the updated coordinates and anchor point
    AugFramesDBLibrary:SetDB(tmpDB) -- Set the DB with the new location data
end