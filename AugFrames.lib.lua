-- ######################################################
-- Project: AugFrames
-- File: AugFrames.lib.lua
-- Author: Sion Duncan
-- File Version: v1.1 
-- File purpose: Contains various functions used in other parts of the addon
-- ######################################################

-- ######################################################
-- This is my first addon, so it'll be heavily commented. Mostly for myself, but also to help others learn. 
-- ######################################################

AugFramesLibrary = {} -- Creating the global library variable

function AugFramesLibrary:DumpTable(tbl, indent)
    -- Handy debug function. Thanks Github CoPilot for this.
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

function AugFramesLibrary:SlashCommand(msg)
    -- Handles all slash commands
	-- I "acquired" this trim function from WillsCDM. Utterly no idea how it works, I don't do regex... <3 Will
	local function trim(str)
		if str == nil then
            return ""
        end
        return (str:gsub("^%s+", ""):gsub("%s+$", ""))
	end

	local cleanMessage = string.lower(trim(msg)) -- Clean any extra spacing from the message
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
    elseif (cleanMessage == "version" or cleanMessage == "dbversion") then
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
    elseif cleanMessage == "dumptargeting" or cleanMessage == "dumptargets" or cleanMessage == "targets" or cleanMessage == "dumptargets" then
        for i = 1, 4 do
            local areaDBSettings = tmpDB.profile.areaData[i] -- Get the settings for this area from the DB
            print("|cff33937F" .. AFL["AddonName"] .. ":|r " .. areaDBSettings.name .. " " .. AFL["Targets"] .. ": " .. areaDBSettings.unit .. " (" .. areaDBSettings.playerName .. ")") -- Print the targetting info for this clickable area to the user
        end
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

function AugFramesLibrary:CreateClickableArea(areaIndex)
    -- Clickable area creation function
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
                areaFrame:SetAttribute("unit", "player") -- This should NEVER be triggered, but rather have it than not incase something goes horribly wrong
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

    -- I can't think of any other way of doing this, I'm sure there will be however...
    local lastUpdateTimestamp = 0
    local lastUpdateInterval = 0.1 -- Basically 10fps, or 0.1ms
    areaFrame:SetScript("OnUpdate", function(self, elapsed)
        lastUpdateTimestamp = lastUpdateTimestamp + elapsed
        if lastUpdateTimestamp >= lastUpdateInterval then
            if C_Spell.IsSpellInRange(areaDBSettings.spell, areaDBSettings.unit) == false then
                -- In range
                areaFrame.Icon:SetDesaturated(false)
            else
                -- Out of range
                areaFrame.Icon:SetDesaturated(true)
            end
        end
    end)

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

function AugFramesLibrary:GetFixedName(unit)
    local playerRealm = GetNormalizedRealmName() -- Get the players realm
    local name, realm = UnitFullName(unit) -- Get the unit's name and realm
    if not realm then realm = playerRealm end -- If not realm is present, it's the same as the players realm, set it.
    return name .. "-" .. realm
end

function AugFramesLibrary:UpdateTargetting(unit, role)
    local tmpDB = AugFramesDBLibrary:GetDB() -- Get the DB
    local unitName = AugFramesLibrary:GetFixedName(unit) -- Get the fixed name of the unit

    if role == "TANK" then
        -- Tank Role
        tmpDB.profile.areaData[3].unit = unit -- Set the target for Blisting Scales to the selected unit
        tmpDB.profile.areaData[3].playerName = unitName -- Set the player name for Blistering Scales
    elseif role == "HEALER" then
        -- Healer
        tmpDB.profile.areaData[4].unit = unit -- Set the target for Spatial Vortex to the selected unit
        tmpDB.profile.areaData[4].playerName = unitName -- Set the player name for Spatial Vortex
    elseif role == "DAMAGER" then
        -- DPS
        if tmpDB.profile.areaData[1].unit == unit then
            tmpDB.profile.areaData[2].unit = unit -- Set the target for the first Prescience to the selected unit
            tmpDB.profile.areaData[2].playerName = unitName -- Set the player name for the second Prescience
        elseif tmpDB.profile.areaData[2].unit == unit then
            tmpDB.profile.areaData[1].unit = unit -- Set the target for the second Prescience to the selected unit
            tmpDB.profile.areaData[1].playerName = unitName -- Set the player name for the first Prescience
        else
            tmpDB.profile.areaData[1].unit = unit -- Set the target for the second Prescience to the selected unit
            tmpDB.profile.areaData[1].playerName = unitName -- Set the player name for the first Prescience
        end
    end

    AugFramesDBLibrary:SetDB(tmpDB) -- Set the DB with the new targetting info
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

function AugFramesLibrary:RosterUpdate()
    if AugFramesDBLibrary:IsEnabled() == false then return end -- If the addon is not enabled, do nothing

    local tmpDB = AugFramesDBLibrary:GetDB() -- Get the DB

    if IsInGroup() then
        if tmpDB.profile.partyAutoTargetting == true then -- If the Auto/Smart Party Targetting is enabled, then update the targetting for the party members
            for i = 1, GetNumGroupMembers()  do
                local unit = "PARTY" .. i -- Get the unit ID for this party member
                if UnitExists(unit) then
                    AugFramesLibrary:UpdateTargetting(unit, UnitGroupRolesAssigned(unit)) -- Set the target for Blisting Scales to the tank in the group
                    AugFramesLibrary:CheckTargetting()
                end
            end
        else
            AugFramesLibrary:CheckTargetting()
        end
    else
        AugFramesLibrary:CheckTargetting()
    end
end

function AugFramesLibrary:CheckTargetting()
    local tmpDB = AugFramesDBLibrary:GetDB() -- Get the DB

    for i = 1, 4 do
        local targetUnitDB = tmpDB.profile.areaData[i].unit -- Get the unit assigned
        local targetNameDB = tmpDB.profile.areaData[i].playerName -- Get the player name assigned

        local playerRealm = GetNormalizedRealmName() -- Get the players realm
        local targetName, targetRealm = UnitFullName(targetUnitDB) -- Get the name of the assigned unit

        if not targetRealm then targetRealm = playerRealm end -- If the target realm is nil, set it to the players realm (This should only happen for player units)

        if targetNameDB ~= targetName .. targetRealm then
            -- The unit that is stored in the DB is incorrect, lets find the correct unitID
            if IsInGroup() then
                for j = 1, GetNumGroupMembers() do
                    local unit = "PARTY" .. j -- Get the unit ID for this party member
                    if UnitExists(unit) then
                        local unitName = AugFramesLibrary:GetFixedName(unit) -- Get the fixed name of the unit
                        if unitName == targetNameDB then
                            tmpDB.profile.areaData[i].unit = unit -- Update the DB with the correct unit ID
                            break
                        end
                    end
                end
            elseif IsInRaid() then
                for j = 1, GetNumGroupMembers() do
                    local unit = "RAID" .. j -- Get the unit ID for this raid member
                    if UnitExists(unit) then
                        local unitName = AugFramesLibrary:GetFixedName(unit) -- Get the fixed name of the unit
                        if unitName == targetNameDB then
                            tmpDB.profile.areaData[i].unit = unit -- Update the DB with the correct unit ID
                            break
                        end
                    end
                end
            else
                -- Player is solo, so we can just set the unit to player if the names don't match, since that's the only option.
                tmpDB.profile.areaData[i].unit = "player" -- Update the DB with the correct unit ID
            end
        end
    end

    AugFramesDBLibrary:SetDB(tmpDB) -- Set the DB with the new unit ID
end

function AugFramesLibrary:Main()
    -- This is the "main loop", it'll handle the frame setup/teardown based on the players spec
    if AugFramesDBLibrary:IsEnabled() == true then
        AugFramesDBLibrary:SetContextMenuStatus(false) -- Set this to false so we can generate the context menu
        AugFramesLibrary:SetupFrames() -- If the addon is enabled, set up the frames
    else
        AugFramesLibrary:TeardownFrames() -- If the addon is disabled, tear down the frames
    end
end

function AugFramesLibrary:GenerateContextMenus()
    local tmpDB = AugFramesDBLibrary:GetDB() -- Get the DB
    if tmpDB.profile.generatedContextMenus == true then return end -- If we've already generated the context menu options, do nothing to avoid generating them multiple times
    local function InsertMenu(unit)
        unit = string.upper(unit) -- Better safe than sorry with this
        Menu.ModifyMenu("MENU_UNIT_" .. unit, function(owner, rootDescription, contextData)
            rootDescription:CreateDivider() -- Create a divider in the context menu to separate our options from the default options
            rootDescription:CreateTitle(AFL["AddonName"]) -- Create a title for our options in the context menu with the addon name
            rootDescription:CreateButton(AFL["ContextMenuSetTarget"], function() AugFramesLibrary:TargettingFrame() end) -- Create a button in the context menu with the generated text and run the targetting for that button text
        end)
    end

    -- Creating the player context menu first
    InsertMenu("SELF")

    -- I feel dirty for doing it like this, but I could not get the context menus to work any other way....
    for i = 1, 4 do
        local unit = "PARTY" .. i
        if UnitExists(unit) then
            InsertMenu(unit)
        end
    end

    for i = 1, 40 do
        local unit = "RAID" .. i
        if UnitExists(unit) then
            InsertMenu(unit)
        end
    end

    AugFramesDBLibrary:SetContextMenuStatus(true) -- Set this to true so we don't generate the context menu options multiple times
    AugFramesDBLibrary:SetDB(tmpDB) -- Set the DB with the new generatedContextMenus value
end

function AugFramesLibrary:TargettingFrame()
    -- This is a frame that will contain 4 drop down boxes, one for each of the clickable areas.
    -- The player will pick what target (via player name) they want each spell to target.
    -- Since this code is not needed anywhere out than this function, we're adding it as a local function
    local function DraggingFrameStart(TargetingFrame) -- Used to start dragging the frame
            TargetingFrame:StartMoving()
    end

    local function DraggingFrameStop(TargetingFrame) -- Used to stop dragging the frame, and saving it's location
        TargetingFrame:StopMovingOrSizing()
        local point, relativeTo, relativePoint, axisX, axisY = TargetingFrame:GetPoint() -- Get the new position of the frame
        local tmpDB = AugFramesDBLibrary:GetDB() -- Get the DB
        tmpDB.profile.targetinglocation = {point, "UIParent", relativePoint, axisX, axisY} -- Save the new position to the DB
        AugFramesDBLibrary:SetDB(tmpDB) -- Set the DB with the new position
    end

    local function DestroyFrame(TargetingFrame) -- Used to destroy the frame when we're done with it
        TargetingFrame:Hide() -- Hide the frame
        TargetingFrame:SetParent(nil) -- Detach the frame from its parent
        _G["AugFramesTargettingFrame"] = nil -- Set the frame to nil to free up memory
    end

    local function GenerateDropdown(parentFrame, labelText, offsetY)
        local dropdownLabel = parentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal") -- Creating the text label for the dropdown
        dropdownLabel:SetPoint("TOPLEFT", 20, offsetY) -- Setting the title location
        dropdownLabel:SetText(AFL["TargetingFrame".. labelText]) -- Setting the title text

        local dropdownFrame = CreateFrame("Frame", nil, parentFrame, "UIDropDownMenuTemplate") -- Creating the frame to hold the dropdown menu
        dropdownFrame:SetPoint("LEFT", dropdownLabel, "LEFT", 60, -3) -- Setting the dropdown location

        UIDropDownMenu_SetWidth(dropdownFrame, 150) -- Setting the width of the dropdown menu
        UIDropDownMenu_SetText(dropdownFrame, AFL["DropDownMenuSelectTarget"]) -- Setting the default text of the dropdown menu

        UIDropDownMenu_Initialize(dropdownFrame, function() -- Generate the content of the dropdown menu

            local function addUnitToDropdown(unit, unitType) -- Local function, since we only use it in this function in this function, we create it locally
                if UnitExists(unit) then -- Check if the unit exists, should be player, party or raid. 
                    local tmpDB = AugFramesDBLibrary:GetDB() -- Get the DB
                    local fullName = AugFramesLibrary:GetFixedName(unit) -- Get the fixed name of the unit to compare against the DB and display in the dropdown menu

                    local info = UIDropDownMenu_CreateInfo() -- Creating dropdown item

                    -- Messy way to do this, but theres no switch in lua apparently...
                    if unitType == "TANK" then
                        if tmpDB.profile.areaData[3].playerName == fullName then -- Set the player name for Blisting Scales
                            info.checked = true
                        end
                    elseif unitType == "HEALER" then
                        if tmpDB.profile.areaData[4].playerName == fullName then -- Set the player name for Spatial Vortex
                            info.checked = true
                        end
                    elseif unitType == "DAMAGER" then
                        if tmpDB.profile.areaData[1].playerName == fullName then
                            info.checked = true
                        elseif tmpDB.profile.areaData[2].playerName == fullName then
                            info.checked = true
                        else
                            info.checked = false
                        end
                    end

                    info.text = fullName -- Setting the text of the dropdown item
                    info.func = function() -- Setting what happens when the player clicks the meny item
                        UIDropDownMenu_SetText(dropdownFrame, fullName)
                        AugFramesLibrary:UpdateTargetting(unit, unitType) -- Update the targetting for this area with the selected unit and role
                    end
                    UIDropDownMenu_AddButton(info)
                end
            end

            addUnitToDropdown("player", labelText) -- Add the player to the dropdown first

            if IsInGroup() then
                for i = 1, GetNumGroupMembers() do
                    addUnitToDropdown("PARTY" .. i, labelText) -- Add party members to the dropdown
                end
            elseif IsInRaid() then
                for i = 1, GetNumGroupMembers() do
                    addUnitToDropdown("RAID" .. i, labelText) -- Add raid members to the dropdown
                end
            end
        end)
    end

    local tmpDB = AugFramesDBLibrary:GetDB() -- Get the DB
    local TargetingFrame = CreateFrame("Frame", "AugFramesTargettingFrame", UIParent, "BackdropTemplate") -- Create the frame for the targetting options
    TargetingFrame:SetPoint(unpack(tmpDB.profile.targetinglocation)) -- Set the position of the frame to the center of the screen
    TargetingFrame:SetSize(290, 230) -- Set the size of the frame
    TargetingFrame:SetMovable(true) -- Setting the frame ot be movable
    TargetingFrame:EnableMouse(true) -- Setting the frame to interact with the mouse
    TargetingFrame:RegisterForDrag("LeftButton") -- Setting the frame to be draggable with the left mouse button
    TargetingFrame:SetScript("OnDragStart", function() DraggingFrameStart(TargetingFrame) end) -- Set the script to start dragging the frame when the player starts dragging
    TargetingFrame:SetScript("OnDragStop", function() DraggingFrameStop(TargetingFrame) end) -- Set the script to stop dragging the frame when the player stops dragging
    TargetingFrame:SetScript("OnHide", function() DestroyFrame(TargetingFrame) end) -- Set the script to destroy the frame when it's hidden
    TargetingFrame:SetBackdrop({ -- Setting the backdrop of the frame to make it look like a standard WoW dialog
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", -- Background texture
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", -- Border texture
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 8, right = 8, top = 8, bottom = 8 },
    })

    local closeButton = CreateFrame("Button", nil, TargetingFrame, "UIPanelCloseButton") -- Creating the close button frame
    closeButton:SetPoint("TOPRIGHT", TargetingFrame, "TOPRIGHT", -5, -5) -- Setting it to the top right of the frame
    closeButton:SetScript("OnClick", function() DestroyFrame(TargetingFrame) end) -- When clicked, destroy the frame

    local TargetingFrameTitle = TargetingFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge") -- Creating the title for the frame
    TargetingFrameTitle:SetPoint("TOP", 0, -12) -- Setting the position of the title to the top of the frame
    TargetingFrameTitle:SetText(AFL["TargetingFrameTitle"]) -- Setting the title text

    NineSliceUtil.ApplyLayout(TargetingFrame, NineSliceLayouts.Dialog) -- Applying the default dialog nine slice layout to the frame to make it look like a standard WoW dialog
    GenerateDropdown(TargetingFrame, "TANK", -40) -- Blisting Scales Drowndown
    GenerateDropdown(TargetingFrame, "HEALER", -90) -- Spatial Vortex Dropdown
    GenerateDropdown(TargetingFrame, "DAMAGER", -140) -- Prescience Dropdown (Since we have 2 prescience areas, they will both be updated when the player selects a target for either of them, so we don't need 2 separate dropdowns for them)
    GenerateDropdown(TargetingFrame, "DAMAGER", -190) -- Prescience Dropdown (Since we have 2 prescience areas, they will both be updated when the player selects a target for either of them, so we don't need 2 separate dropdowns for them)

    tinsert(UISpecialFrames, "AugFramesTargettingFrame") -- Inserting the frame into the SpecialFrames table, this lets the frame be closed using the escape key like any other blizzard frame
end