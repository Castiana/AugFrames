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

AugFramesLibrary = {} -- Creating the global library variable

-- Handy debug function. Thanks Github CoPilot for this.
function AugFramesLibrary:DumpTable(tbl, indent)
    indent = indent or ""
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            print(indent .. tostring(k) .. ":")
            AugFramesLibrary:DumpTable(v, indent .. "  ")
        else
            print(indent .. tostring(k) .. ": " .. tostring(v))
        end
    end
end

-- Handles all slash commands
function AugFramesLibrary:SlashCommand(msg)
	-- I "acquired" this trim function from WillsCDM. Utterly no idea how it works, I don't do regex... <3 Will
	local function trim(str)
		if str == nil then
            return ""
        end
        return (str:gsub("^%s+", ""):gsub("%s+$", ""))
	end

	local cleanMessage = trim(msg) -- Clean any extra spacing from the message
    local tmpDB = AugFramesDBLibrary:GetDB() -- Get the DB
    local AugFramesMain = _G["AugFramesMainFrame"] -- Get the main frame

    -- Main slash command handler. Since lua doesn't have a swtich, we're using if/elsif's
	if cleanMessage == "ping" then
		print("|cff33937F" .. AFL["AddonName"] .. ":|r Pong? I guess?") -- Simple test command to make sure the slash command is working
    elseif cleanMessage == "rl" or cleanMessage == "reload" then
        ReloadUI() -- Reloads the UI when the user types /af reload or /af rl
    elseif cleanMessage == "resetpos" then
        AugFramesLibrary:ResetFramePosition()
        print("|cff33937F" .. AFL["AddonName"] .. ":|r " .. AFL["PositionResetComplete"]) -- Let the user know the position has been reset
	elseif cleanMessage == "spec" then
		print("|cff33937F" .. AFL["AddonName"] .. ":|r " .. AFL["SlashCurrentSpecID"] .. ": " .. (C_SpecializationInfo.GetSpecializationInfo(C_SpecializationInfo.GetSpecialization()) or AFL["None"])) -- Tells the user what their current specID is, or none if they are not in a spec (Pre-lvl 10)
    elseif (cleanMessage == "version" or cleanMessage == "dbVersion") then
        print("|cff33937F" .. AFL["AddonName"] .. ":|r" .. AFL["AddonVersionLong"] .. " -- " .. AFL["AddonDBVersion"] .. " " .. tmpDB.profile.dbVersion) -- Tells the user the addon version. Useful for debugging and support. 
    elseif cleanMessage == "resetdb" then
        AugFramesDBLibrary:ResetDB() -- Resets the DB to default values
        AugFramesLibrary:RebuildFrames() -- Rebuild the frames after resetting the DB
        print("|cff33937F" .. AFL["AddonName"] .. ":|r" .. AFL["DBReset"]) -- Let the user know the DB has been reset
    elseif cleanMessage == "pos" then -- For Debugging. Leaving in live incase the user wants to see
        local point, relativeTo, relativePoint, axisX, axisY = AugFramesMain:GetPoint() -- Get the current position of the main frame
        print("|cff33937F" .. AFL["AddonName"] .. ":|r " .. AFL["PoSFrameLiveLocation"] .. ": " .. point .. ", " .. AFL["RelativeTo"] .. ": " .. (relativeTo and relativeTo:GetName() or "nil") .. ", " .. AFL["RelativePoint"] .. ": " .. relativePoint .. ", X: " .. axisX .. ", Y: " .. axisY) -- Print the position to the user
    elseif cleanMessage == "posdb" then -- For Debugging. Leaving in live incase the user wants to see
        local point, relativeTo, relativePoint, axisX, axisY = unpack(tmpDB.profile.location) -- Get the saved location from the DB
        print("|cff33937F" .. AFL["AddonName"] .. ":|r " .. AFL["PoSFrameDBLocation"] .. ": " .. point .. ", " .. AFL["RelativeTo"] .. ": " .. relativeTo .. ", " .. AFL["RelativePoint"] .. ": " .. relativePoint .. ", X: " .. axisX .. ", Y: " .. axisY) -- Print the position to the user
    elseif cleanMessage == "dumpdb" then
        AugFramesLibrary:DumpTable(tmpDB) -- Dump the DB to the user for debugging
    elseif cleanMessage == "status" then
        -- Displays the addon status from the DB
        if AugFramesDBLibrary:IsEnabled() then
            print("|cff33937F" .. AFL["AddonName"] .. ":|r status: " .. AFL["AddonEnabled"])
        else
            print("|cff33937F" .. AFL["AddonName"] .. ":|r status: " .. AFL["AddonDisabled"])
        end
    else
        print("|cff33937F" .. AFL["AddonName"] .. ":|r " .. AFL["SlashHelp"]) -- If the user types anything else, show them the main options description to help them out
	end
end

function AugFramesLibrary:ResetFramePosition()
    if InCombatLockdown() then return end -- Check if the player is in combat. If we are, do nothing so we don't taint

    local AugFramesMain = _G["AugFramesMainFrame"] -- Get the main frame

    AugFramesMain:SetPoint("CENTER", "UIParent", "CENTER", 0, 0) -- Reset the frame position to the default position

    local point, relativeTo, relativePoint, axisX, axisY = AugFramesMain:GetPoint() -- Get the new position of the frame
    local tmpDB = AugFramesDBLibrary:GetDB() -- Get the DB

    tmpDB.profile.location = {point, "UIParent", relativePoint, axisX, axisY} -- Save the new position to the DB
    AugFramesDBLibrary:SetDB(tmpDB) -- Set the DB with the new position
end

-- Clickable area creation function
function AugFramesLibrary:CreateClickableArea(areaIndex)
    if areaIndex < 1 or areaIndex > 4 then return end -- Sanity check to make sure the area index is between 1 and 4

    local AugFramesMain = _G["AugFramesMainFrame"] -- Get the main frame to use as the parent for the clickable areas
    local tmpDB = AugFramesDBLibrary:GetDB() -- Get the DB
    local areaDBSettings = tmpDB.profile.areaData[areaIndex] -- Get the settings for this area from the DB

    if areaDBSettings.location ~= "TOPLEFT" and areaDBSettings.location ~= "TOPRIGHT" and areaDBSettings.location ~= "BOTTOMLEFT" and areaDBSettings.location ~= "BOTTOMRIGHT" then return end -- Sanity check to make sure the area location is valid   

    -- Creating the clickable area
    local areaFrame = CreateFrame("Button", "AugFramesClickableArea" .. areaIndex, AugFramesMain, "SecureActionButtonTemplate") -- Create the secure clickable area

    -- Configuring the clickable area
    areaFrame:SetPoint(areaDBSettings.location, AugFramesMain, areaDBSettings.location, 0, 0) -- Set the position of the clickable area
    areaFrame:SetSize(AugFramesMain:GetWidth() / 2, AugFramesMain:GetHeight() / 2) -- Set the size of the clickable area to be a quarter of the main frame (Since it's a square, we can just divide by 2)
    areaFrame:RegisterForClicks("LeftButtonDown", "LeftButtonUp") -- Massive thank you to "Cladhaire" on the WoW UI Dev Discord for the help with the click-casting issue!
    areaFrame:SetFrameStrata("MEDIUM") -- Set the frame strata to high so it appears above the main frame

    -- Looping through the saved settings, setting them
    for k, v in pairs(areaDBSettings) do
        if k ~= "icon" then -- We don't want to set the icon as an attribute
            areaFrame:SetAttribute(k, v) -- Set the attribute on the clickable area
        elseif k == "unit" then
            if v == "" or v == nil then
                areaFrame:SetAttribute("unit", areaDBSettings.unitDefault) -- This should NEVER be triggered, but rather have it than not incase something goes horribly wrong
            else
                areaFrame:SetAttribute("unit", areaDBSettings.unit) -- Targetting the spell
            end
        end
    end

    -- Setting the icon
    areaFrame.Icon = areaFrame:CreateTexture(nil, "BACKGROUND") -- Setting the background to the icon of the spell
    areaFrame.Icon:SetAllPoints() -- Setting the icon to cover the entire clickable area
    areaFrame.Icon:SetTexture(areaDBSettings.icon) -- Setting the texture of the icon to the saved texture in the DB

    areaFrame:SetNormalTexture(C_Spell.GetSpellTexture(areaDBSettings.spell)) -- Setting the normal texture, we need this for the cooldown/swipe to work

    local statusHighlight = areaFrame:CreateTexture(nil, "HIGHLIGHT") -- Highlighted state texture
    statusHighlight:SetAllPoints() -- Setting the icon to cover the entire clickable area
    statusHighlight:SetTexture("Interface\\Buttons\\ButtonHilight-square") -- Setting the highlighted state texture to the default WoW square highlight texture
    statusHighlight:SetBlendMode("ADD") -- Setting the blend mode to add so it looks like a highlight
    areaFrame:SetHighlightTexture(statusHighlight) -- Setting the highlight texture of the clickable area

    local statusPressed = areaFrame:CreateTexture(nil, "ARTWORK") -- Pressed state texture
    statusPressed:SetAllPoints() -- Setting the icon to cover the entire clickable area
    statusPressed:SetTexture("Interface\\Buttons\\UI-Quickslot-Depress") -- Setting the pressed state texture to the default WoW quickslot pressed texture
    areaFrame:SetPushedTexture(statusPressed) -- Setting the pressed texture of the clickable area
end

function AugFramesLibrary:SetupFrames()
    if InCombatLockdown() then return end -- Check if the player is in combat. If we are, do nothing so we don't taint
    if _G["AugFramesMainFrame"] then return end -- Check if the main frame already exists. If so, do nothing so we don't create infite frames

    local tmpDB = AugFramesDBLibrary:GetDB() -- Get the DB
    local size = tmpDB.profile.size
    local location = tmpDB.profile.location

    -- Setup the frame
    local frameMain = CreateFrame("Frame", "AugFramesMainFrame", UIParent)
    frameMain:Show() -- Show the main frame
    frameMain:SetMovable(true) -- Seting the frame to be movable
    frameMain:EnableMouse(true) -- Setting the frame to interact with the mouse
    frameMain:SetResizable(true) -- Setting the frame to be resizeable
    frameMain:SetPoint(unpack(location)) -- Setting the frame position to the saved position in the DB
    frameMain:SetSize(size + 10, size + 10) -- Setting the frame size to the saved size in the DB (Since it's a square, we only need the one value)
    frameMain:RegisterForDrag("LeftButton") -- Setting the frame to be draggable with the left mouse button (Will also need alt to be held down, that's handled below)
    frameMain:SetFrameStrata("LOW") -- Setting the frame strata to low so it appears below the clickable areas
    -- Frame Background
    frameMain.Background = frameMain:CreateTexture(nil, "BACKGROUND") -- Creating the background texture for the frame
    frameMain.Background:SetAllPoints() -- Setting the background to cover the entire frame
    frameMain.Background:SetColorTexture(0, 0, 0, 0.5) -- Setting the background color to black with 50% opacity

   -- Now we have our "container" frame set up, we can start creating the clickable areas and attaching them to the main frame
    for i = 1, 4 do
        AugFramesLibrary:CreateClickableArea(i) -- Create the clickable area and attach it to the main frame
    end

    -- We can't initalise the EditMode configuration until we have our main frame. So we're doing that now.
    AugFramesOptionsLibrary:Init()
end

function AugFramesLibrary:RebuildFrames()
    AugFramesLibrary:TeardownFrames() -- Tear down the existing frames
    AugFramesLibrary:SetupFrames() -- Set up the frames again with the new settings
end

function AugFramesLibrary:TeardownFrames()
    if InCombatLockdown() then return end -- Check if the player is in combat. If we are, do nothing so we don't taint

    local AugFramesMain = _G["AugFramesMainFrame"] -- Get the main frame

    if AugFramesMain then -- Check if the main frame exists
        AugFramesMain:Hide() -- Hide the main frame
        for i = 1, 4 do
            local areaFrame = _G["AugFramesClickableArea" .. i] -- Get the clickable area frame
            if areaFrame then
                areaFrame:Hide() -- Hide the clickable area frame
                areaFrame:SetParent(nil) -- Detach the clickable area frame from its parent
                _G["AugFramesClickableArea" .. i] = nil -- Set the clickable area frame to nil to free up memory
            end
        end
        AugFramesMain:SetParent(nil) -- Detach the main frame from its parent
        _G["AugFramesMainFrame"] = nil -- Set the main frame to nil to free up memory
    end
end

function AugFramesLibrary:UpdateTargetting(unit, role)
    local tmpDB = AugFramesDBLibrary:GetDB() -- Get the DB

    if role == "TANK" then
        -- Tank Role
        tmpDB.profile.areaData[3].unit = unit -- Set the target for Blisting Scales to the selected unit
    elseif role == "HEALER" then
        -- Healer
        tmpDB.profile.areaData[4].unit = unit -- Set the target for Spatial Vortex to the selected unit
    elseif role == "DAMAGER" then
        -- DPS
        if tmpDB.profile.areaData[1].unit == unit then
            tmpDB.profile.areaData[2].unit = unit -- Set the target for the first Prescience to the selected unit
        elseif tmpDB.profile.areaData[2].unit == unit then
            tmpDB.profile.areaData[1].unit = unit -- Set the target for the second Prescience to the selected unit
        else
            -- This is just a catch all. Should never really be reached. But better safe than sorry.
            tmpDB.profile.areaData[1].unit = "player" -- Set the target for the first Prescience to the selected unit
            tmpDB.profile.areaData[2].unit = "player" -- Set the target for the second Prescience to the selected unit
        end
    end

    AugFramesDBLibrary:SetDB(tmpDB) -- Set the DB with the new targetting info
end

function AugFramesLibrary:GenerateContextMenuText(unit)
    -- Since "player" isn't a valid menu option we need to convert it to "SELF". This is REALLY dumb...
    if unit == "SELF" then unit = "player" end

    if not unit or not UnitExists(unit) then return "" end -- Sanity check to make sure the unit exists, if it doesn't exist somethings gone wrong

    local role = "NONE"
    if unit == "player" and not IsInGroup() and not IsInRaid() then
        role = GetSpecializationRole(C_SpecializationInfo.GetSpecialization()) -- If the player is solo, get there role based on their specializationID
    else
        role = UnitGroupRolesAssigned(unit) -- Get the role assigned to the unit by the game (TANK, HEALER, DAMAGER or NONE)
    end

    local outputText = ""

    if role == "TANK" then
        -- Tank Role
        outputText = AFL["ContextMenuSetTank"]
    elseif role == "HEALER" then 
        -- Healer
        outputText = AFL["ContextMenuSetHealer"]
    elseif role == "DAMAGER" then
        -- DPS
        outputText = AFL["ContextMenuSetDPS"]
    else
        -- No Role, player is not in a group
        outputText = AFL["ContextMenuSetNone"]
    end

    return outputText, role -- Return the generated text and the role for use in the context menu
end

function AugFramesLibrary:GenerateContextMenu()
    -- Inserting the context menu into the player context menu
    AugFramesLibrary:InsertContextMenuItem("SELF")

    if IsInGroup() then
        -- Group Context Menu
        local groupMembers = GetNumGroupMembers() -- Get the number of members in the group
        for i = 1, groupMembers do
            local unit = "party" .. i -- Get the unit ID for this party member
            if UnitExists(unit) then
                AugFramesLibrary:InsertContextMenuItem(unit) -- Insert the context menu item for this party member
            end
        end
    elseif IsInRaid() then
        -- Raid Context Menu
        local groupMembers = GetNumGroupMembers() -- Get the number of members in the group
        for i = 1, groupMembers do
            local unit = "raid" .. i -- Get the unit ID for this raid member
            if UnitExists(unit) then
                AugFramesLibrary:InsertContextMenuItem(unit) -- Insert the context menu item for this raid member
            end
        end
    end
end

function AugFramesLibrary:InsertContextMenuItem(unit)
    if not unit then return end -- Sanity check to make sure the unit exists, if it doesn't exist somethings gone wrong

    local menuText, role = AugFramesLibrary:GenerateContextMenuText(unit) -- Generate the context menu text for this unit

    Menu.ModifyMenu("MENU_UNIT_"..unit, function(owner, rootDescription, contextData)
        rootDescription:CreateDivider() -- Create a divider in the context menu to separate our options from the default options
        rootDescription:CreateTitle(AFL["AddonName"]) -- Create a title for our options in the context menu with the addon name
        rootDescription:CreateButton(menuText, function() AugFramesLibrary:UpdateTargetting(contextData.unit, role) end) -- Create a button in the context menu with the generated text and run the targetting for that button text
    end)
end

function AugFramesLibrary:RosterUpdate()
    if AugFramesDBLibrary:IsEnabled() == false then return end -- If the addon is not enabled, do nothing

    if IsInGroup() then
        local tmpDB = AugFramesDBLibrary:GetDB() -- Get the DB
        if tmpDB.profile.partyAutoTargetting == true then -- If the Auto/Smart Party Targetting is enabled, then update the targetting for the party members
            for i = 1, GetNumGroupMembers()  do
                local unit = "party" .. i -- Get the unit ID for this party member
                if UnitExists(unit) then
                    AugFramesLibrary:UpdateTargetting(unit, UnitGroupRolesAssigned(unit)) -- Set the target for Blisting Scales to the tank in the group
                end
            end
        end
    elseif IsInRaid() then
        AugFramesLibrary:GenerateContextMenu() -- Regenerate the context menu to include/remove 
    end
end

function AugFramesLibrary:CheckTargetting()
    local tmpDB = AugFramesDBLibrary:GetDB() -- Get the DB

    for i = 1, 4 do
        local targetUnit = tmpDB.profile.areaData[i].unit -- Get the unit assigned to this area
        if targetUnit ~= "player" then
            if tmpDB.profile.supressTargettingWarning ~= false then
                print("|cff33937F" .. AFL["AddonName"] .. ":|r " .. tmpDB.profile.areaData[i].name ..  AFL["TargettingCheckPlayerTargetted"]) -- Let the user know we're checking the targetting for this unit
            end
        end
    end
end

-- This is the "main loop", it'll handle the frame setup/teardown based on the players spec
function AugFramesLibrary:Main()
    if AugFramesDBLibrary:IsEnabled() == true then
        AugFramesLibrary:GenerateContextMenu() -- Generate the context menu options
        AugFramesLibrary:SetupFrames() -- If the addon is enabled, set up the frames
    else
        AugFramesLibrary:TeardownFrames() -- If the addon is disabled, tear down the frames
    end
end

function AugFramesLibrary:SpecCheck(unit)
	if unit and unit ~= "player" then return end -- Simple 1 liner, if the unit passed is not the player, then do nothing 

	local specIndex = C_SpecializationInfo.GetSpecialization() -- Getting the player spec
	if not specIndex then return end -- Another 1 liner, if the spec index is nil/blank then return. The player is not in a spec (Pre-lvl 10)

	local specID, _, _, _, _, _, _, _, _, _ = C_SpecializationInfo.GetSpecializationInfo(specIndex) -- Getting the spec specifics

	-- If the player is in Augmentation spec, set the addon to load. Otherwise, dont.
    local tmpDB = AugFramesDBLibrary:GetDB()
	if specID == 1473 then
        tmpDB.profile.enabled = true
	else
        tmpDB.profile.enabled = false
        AugFramesLibrary:TeardownFrames() -- If the player is not in Augmentation, destroy the frames to save memory.
	end
    AugFramesDBLibrary:SetDB(tmpDB) -- Set the DB with the new enabled/disabled value

    -- Run the main loop
    AugFramesLibrary:Main()
end