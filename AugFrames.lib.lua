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
    elseif cleanMessage == "move" then 
        -- I did have the move AND resize done elegantly inframe. But for some reason the resize frame/icon never showed up :(
        print("|cff33937F" .. AFL["AddonName"] .. ":|r " .. AFL["PositionMoveInstructions"] ) -- Instructions for moving the frame
        AugFramesLibrary:SlashMove()
    elseif cleanMessage == "save" then
        AugFramesLibrary:SlashSave()
        print("|cff33937F" .. AFL["AddonName"] .. ":|r " .. AFL["PositionSaveComplete"]) -- Let the user know the position has been saved
    elseif cleanMessage == "resetpos" then
        AugFramesLibrary:ResetFramePosition()
        print("|cff33937F" .. AFL["AddonName"] .. ":|r " .. AFL["PositionResetComplete"]) -- Let the user know the position has been reset
	elseif cleanMessage == "spec" then
		print("|cff33937F" .. AFL["AddonName"] .. ":|r Current SpecID: " .. (C_SpecializationInfo.GetSpecializationInfo(C_SpecializationInfo.GetSpecialization()) or "None")) -- Tells the user what their current specID is, or none if they are not in a spec (Pre-lvl 10)
    elseif (cleanMessage == "version" or cleanMessage == "dbVersion") then
        print("|cff33937F" .. AFL["AddonName"] .. ":|r" .. AFL["AddonVersionLong"] .. " -- " .. AFL["AddonDBVersion"] .. " " .. tmpDB.profile.dbVersion) -- Tells the user the addon version. Useful for debugging and support. 
    elseif cleanMessage == "resetdb" then
        AugFramesDBLibrary:ResetDB() -- Resets the DB to default values
        AugFramesLibrary:RebuildFrames() -- Rebuild the frames after resetting the DB
        print("|cff33937F" .. AFL["AddonName"] .. ":|r" .. AFL["DBReset"]) -- Let the user know the DB has been reset
    elseif cleanMessage == "pos" then -- For Debugging. Leaving in live incase the user wants to see
        local point, relativeTo, relativePoint, axisX, axisY = AugFramesMain:GetPoint() -- Get the current position of the main frame
        print("|cff33937F" .. AFL["AddonName"] .. ":|r LIVE POS Frame Position: Point: " .. point .. ", RelativeTo: " .. (relativeTo and relativeTo:GetName() or "nil") .. ", RelativePoint: " .. relativePoint .. ", X: " .. axisX .. ", Y: " .. axisY) -- Print the position to the user
    elseif cleanMessage == "posdb" then -- For Debugging. Leaving in live incase the user wants to see
        local point, relativeTo, relativePoint, axisX, axisY = unpack(tmpDB.profile.location) -- Get the saved location from the DB
        print("|cff33937F" .. AFL["AddonName"] .. ":|r DB POS Frame Position: Point: " .. point .. ", RelativeTo: " .. relativeTo .. ", RelativePoint: " .. relativePoint .. ", X: " .. axisX .. ", Y: " .. axisY) -- Print the position to the user
    elseif cleanMessage == "dumpdb" then
        AugFramesLibrary:DumpTable(tmpDB) -- Dump the DB to the user for debugging
    elseif cleanMessage == "resetst" then
        AugFramesLibrary:SmartTargettingUpdate() -- Update the smart targetting
    elseif cleanMessage == "status" then
        -- Displays the addon status from the DB
        if(tmpDB.profile.enabled) then
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

function AugFramesLibrary:TargettingUpdate()
    if InCombatLockdown() then return end -- Check if the player is in combat. If we are, do nothing so we don't taint

    local tmpDB = AugFramesDBLibrary:GetDB() -- Get the DB

    if AugFramesDBLibrary:GetSplitConfiguration() then
        -- Split Configuration enabled
        -- Check if Smart Targetting is enabled
        if tmpDB.profile.smartPartyTargetting and not IsInRaid() then -- Check if SmartTargetting is enabled and we're not in a raid group.
            -- Setting these all to player incase the roles are not in the group. 
            local tank = "player"
            local healer = "player"
            local dpsOne = "player"
            local dpsTwo = "player"
            local dpsCheck = true
            local setCheck = true

            -- Let's get the party members roles sorted
            for i = 1, GetNumGroupMembers() do
                local partyUnit = "party"..i
                if UnitGroupRolesAssigned(partyUnit) == "TANK" then
                    tank =  partyUnit -- Set Blistering Scales to target the tank
                elseif UnitGroupRolesAssigned(partyUnit) == "HEALER" then
                    healer =  partyUnit -- Set Spatial Vortex to target the healer
                elseif UnitGroupRolesAssigned(partyUnit) == "DAMAGER" then
                    if dpsCheck then
                        dpsOne = partyUnit -- Set Prescience to target the first DPS
                        dpsCheck = false -- Set the check to false so the next DPS gets set to dpsTwo
                    else
                        dpsTwo = partyUnit -- Set Prescience to target the second DPS
                    end
                end
            end

            -- Now we have the roles sorted, let's update the DB with the new targetting info
            for i = 1, 4 do
                local areaData = tmpDB.profile.areaData[i] -- Get the area data for this index
                if areaData.spell == "360827" then -- Blistering Scales
                    areaData.unit = tank -- Set to tank
                elseif areaData.spell == "406732" then -- Spatial Vortex
                    areaData.unit = healer -- Set to healer
                elseif areaData.spell == "409311" then -- Prescience
                    if setCheck then
                        areaData.unit = dpsOne -- Set to the first DPS
                        setCheck = false -- Set the check to false so the next Prescience gets set to dpsTwo
                    else 
                        areaData.unit = dpsTwo -- Set to the second DPS
                    end
                end

                tmpDB.profile.areaData[i] = areaData -- Save the updated area data back to the tmpDB
            end

            setCheck = true -- Resetting for next use
            dpsCheck = true -- Resetting for next use
        end
    else
        -- Split Configuration disabled, set all to raid targets
        for i = 1, 4 do
            local areaData = tmpDB.profile.areaData[i] -- Get the area data for this index
            areaData.unit = areaData.unitRaid -- Set the party target to be the same as the raid target
            tmpDB.profile.areaData[i] = areaData -- Save the updated area data back to the tmpDB
        end
    end

    AugFramesDBLibrary:SetDB(tmpDB) -- Set the DB with the new targetting info
    AugFramesLibrary:RebuildFrames() -- Rebuild the frames after an update
end

function AugFramesLibrary:FixTargetName(name, playerRealm)
    local target, realm = name:match("(.+)%-(.+)") -- ChatGPT did this line. I don't do regex...
    if realm == nil then name = target .. "-" .. playerRealm end -- If no realm is present, assume player's own realm
    return name -- Return the fixed name
end

function AugFramesLibrary:GetSpellTarget(areaDBSettings)
    if type(areaDBSettings) ~= "table" then return "player" end -- Sanity check to make sure the spellID is a number, if it's not a number somethings gone wrong
    if type(areaDBSettings.unit) ~= "string" then return "player" end -- Sanity check to make sure the unit is a string, if it's not a string somethings gone wrong
    if type(areaDBSettings.spell) ~= "number" then return "player" end -- Sanity check to make sure the spellID is a number, if it's not a number somethings gone wrong
    if GetNumGroupMembers() == 0 then return "player" end -- If we're not in a group/raid, cast on player

    -- Now all our sanity checking is done, lets set the targetting
    local spellID = areaDBSettings.spell -- Putting the spellID into a local
    local _, playerRealm = UnitFullName("player") -- Getting the players realm, will be used later in case the player they've selected doesn't have one (We're just going to assume it's the same realm)
    local uncleanUnit = nil
    local selectedUnit = nil -- Blanking the selectedUnit

    -- Are we in a raid, group or solo? Figure it out then find the right unit
    if areaDBSettings.unit == "player" then
        selectedUnit = "player" -- The player is the target, no need to get fancy
    else
        -- The player is not the target, time to get fancy
        if IsInGroup() and AugFramesDBLibrary:GetSplitConfiguration() then
            -- Split configuration is enabled. The targetting as been done already in the TargettingUpdate function
            selectedUnit = areaDBSettings.unitParty -- If split configuration is enabled, use the party target
        elseif IsInGroup() then
            -- Split configuration is disabled, but we're in a group. Use the raid target since we treat party and raid the same when split configuration is disabled
            uncleanUnit = areaDBSettings.unitRaid -- If split configuration is disabled, use the raid target (Since party and raid targets are the same when split configuration is disabled)

            selectedUnit = AugFramesLibrary:FixTargetName(uncleanUnit, playerRealm) -- Fix the name in case the realm is missing

            for i = 1, GetNumGroupMembers() do
                local partyUnit = "party"..i
                if not UnitIsDeadOrGhost(partyUnit) and C_Spell.IsSpellInRange(spellID, partyUnit) and UnitExists(partyUnit) and UnitName(partyUnit) == selectedUnit then
                    selectedUnit = partyUnit
                else
                    selectedUnit = "player" -- This should never be returned, but I'd rather be safe
                end
            end
        elseif IsInRaid() then
             -- Split configuration is disabled, but we're in a group. Use the raid target since we treat party and raid the same when split configuration is disabled
            uncleanUnit = areaDBSettings.unitRaid -- If split configuration is disabled, use the raid target (Since party and raid targets are the same when split configuration is disabled)

            selectedUnit = AugFramesLibrary:FixTargetName(uncleanUnit, playerRealm) -- Fix the name in case the realm is missing

            for i = 1, GetNumGroupMembers() do
                local raidUnit = "raid"..i
                if not UnitIsDeadOrGhost(raidUnit) and C_Spell.IsSpellInRange(spellID, raidUnit) and UnitExists(raidUnit) and UnitName(raidUnit) == selectedUnit then
                    selectedUnit = raidUnit
                else
                    selectedUnit = "player" -- This should never be returned, but I'd rather be safe
                end
            end
        else
            selectedUnit = "player" -- This should NEVER be executed, but you never know....
        end


    end

    return selectedUnit -- Return the selected unit
end

-- Clickable area creation function
function AugFramesLibrary:CreateClickableArea(areaIndex, areaLocation)
    if areaIndex < 1 or areaIndex > 4 then return end -- Sanity check to make sure the area index is between 1 and 4
    if areaLocation ~= "TOPLEFT" and areaLocation ~= "TOPRIGHT" and areaLocation ~= "BOTTOMLEFT" and areaLocation ~= "BOTTOMRIGHT" then return end -- Sanity check to make sure the area location is valid

    -- Getting the setting for this area from the DB
    local AugFramesMain = _G["AugFramesMainFrame"] -- Get the main frame to use as the parent for the clickable areas
    local tmpDB = AugFramesDBLibrary:GetDB() -- Get the DB
    local areaDBSettings = tmpDB.profile.areaData[areaIndex] -- Get the settings for this area from the DB

    -- Quick check to make sure the player knows the spell in this area. If not, don't generate the area
    if(C_SpellBook.IsSpellInSpellBook(areaDBSettings.spell) == nil) then return end

    -- Creating the clickable area
    local areaFrame = CreateFrame("Button", "AugFramesClickableArea" .. areaIndex, AugFramesMain, "SecureActionButtonTemplate") -- Create the secure clickable area

    -- Configuring the clickable area
    areaFrame:SetPoint(areaLocation, AugFramesMain, areaLocation, 0, 0) -- Set the position of the clickable area
    areaFrame:SetSize(AugFramesMain:GetWidth() / 2, AugFramesMain:GetHeight() / 2) -- Set the size of the clickable area to be a quarter of the main frame (Since it's a square, we can just divide by 2)
    areaFrame:RegisterForClicks("AnyUp", "AnyDown") -- Massive thank you to "Cladhaire" on the WoW UI Dev Discord for the help with the click-casting issue!
    areaFrame:SetFrameStrata("HIGH") -- Set the frame strata to high so it appears above the main frame

    -- Looping through the saved settings, setting them
    for k, v in pairs(areaDBSettings) do
        if k ~= "icon" then -- We don't want to set the icon as an attribute
            areaFrame:SetAttribute(k, v) -- Set the attribute on the clickable area
        elseif k == "unitParty" or k == "unitRaid" then
            areaFrame:SetAttribute("unit", function() AugFramesLibrary:GetSpellTarget(areaDBSettings) end) -- Smart Targetting the spell
        end

    end

    --[[
    -- Debug: Dump attributes to chat
    local keysToCheck = {"type", "spell", "unit"}
    for _, key in ipairs(keysToCheck) do
        print("AreaFrame[" .. areaIndex .. "] attribute '" .. key .. "':", areaFrame:GetAttribute(key))
    end
    ]]

    -- Setting the icon
    areaFrame.Icon = areaFrame:CreateTexture(nil, "BACKGROUND") -- Setting the background to the icon of the spell
    areaFrame.Icon:SetAllPoints() -- Setting the icon to cover the entire clickable area
    areaFrame.Icon:SetTexture(areaDBSettings.icon) -- Setting the texture of the icon to the saved texture in the DB

    local statusHighlight = areaFrame:CreateTexture(nil, "HIGHLIGHT") -- Highlighted state texture
    statusHighlight:SetAllPoints() -- Setting the icon to cover the entire clickable area
    statusHighlight:SetTexture("Interface\\Buttons\\ButtonHilight-square") -- Setting the highlighted state texture to the default WoW square highlight texture
    statusHighlight:SetBlendMode("ADD") -- Setting the blend mode to add so it looks like a highlight
    areaFrame:SetHighlightTexture(statusHighlight) -- Setting the highlight texture of the clickable area
    areaFrame.textureHighlight = statusHighlight -- Saving the highlight texture to the frame for later

    local statusPressed = areaFrame:CreateTexture(nil, "ARTWORK") -- Pressed state texture
    statusPressed:SetAllPoints() -- Setting the icon to cover the entire clickable area
    statusPressed:SetTexture("Interface\\Buttons\\UI-Quickslot-Depress") -- Setting the pressed state texture to the default WoW quickslot pressed texture
    areaFrame:SetPushedTexture(statusPressed) -- Setting the pressed texture of the clickable area
    areaFrame.texturePressed = statusPressed -- Saving the pressed texture to the frame for later

    return areaFrame -- Return the created clickable area frame
end

-- This is where we do the main frame moving stuff
function AugFramesLibrary:MainFrameMove()
    if InCombatLockdown() then return end -- Check if the player is in combat. If we are, do nothing so we don't taint
    local frameMain = _G["AugFramesMainFrame"] -- Get the main frame

    if IsAltKeyDown() then -- Check if alt is being held down. No alt, no movey
        frameMain:StartMoving() -- Start moving the frame
    end
end

function AugFramesLibrary:SlashMove()
    if InCombatLockdown() then return end -- Check if the player is in combat. If we are, do nothing so we don't taint

    local AugFramesMain = _G["AugFramesMainFrame"] -- Get the main frame

    if AugFramesMain then
        for i = 1, 4 do
            local areaFrame = _G["AugFramesClickableArea" .. i] -- Get the clickable area frame
            if areaFrame then
                areaFrame:Hide() -- Hide the clickable area frame so it doesn't get in the way of moving
            end
        end
        AugFramesLibrary:MainFrameMove() -- Call the main frame move function with the main frame as an argument
    end
end

function AugFramesLibrary:SlashSave()
    if InCombatLockdown() then return end -- Check if the player is in combat. If we are, do nothing so we don't taint

    local AugFramesMain = _G["AugFramesMainFrame"] -- Get the main frame

    if AugFramesMain then
        for i = 1, 4 do
            local areaFrame = _G["AugFramesClickableArea" .. i] -- Get the clickable area frame
            if areaFrame then
                areaFrame:Show() -- Show the clickable area frame again now we're done moving
            end
        end
        AugFramesLibrary:MainFrameStop() -- Call the main frame stop function with the main frame as an argument to save the new position
    end
end

-- This is where handle the frame moving stop and saving
function AugFramesLibrary:MainFrameStop()
    if InCombatLockdown() then return end -- Check if the player is in combat. If we are, do nothing so we don't taint

    local frameMain = _G["AugFramesMainFrame"] -- Get the main frame
    frameMain:StopMovingOrSizing() -- Stop moving the frame

    local point, _, relativePoint, axisX, axisY = frameMain:GetPoint() -- Get the new position of the frame
    
    local tmpDB = AugFramesDBLibrary:GetDB() -- Get the DB
    tmpDB.profile.location = {point, "UIParent", relativePoint, axisX, axisY} -- Save the new position to the DB
    AugFramesDBLibrary:SetDB(tmpDB) -- Set the DB with the new position
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

-- This setups the frames
function AugFramesLibrary:SetupFrames()
    if InCombatLockdown() then return end -- Check if the player is in combat. If we are, do nothing so we don't taint
    if _G["AugFramesMainFrame"] then return end -- Check if the main frame already exists. If so, do nothing so we don't create infite frames
    
    local tmpDB = AugFramesDBLibrary:GetDB() -- Get the DB
    local quadData = tmpDB.profile.areaData
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
    frameMain:SetFrameStrata("MEDIUM") -- Setting the frame strata to medium so it appears above most UI elements but below important ones like the player frame and boss frames
    -- Frame Background
    frameMain.Background = frameMain:CreateTexture(nil, "BACKGROUND") -- Creating the background texture for the frame
    frameMain.Background:SetAllPoints() -- Setting the background to cover the entire frame
    frameMain.Background:SetColorTexture(0, 0, 0, 0.5) -- Setting the background color to black with 50% opacity

    -- Scripts for the main frame
    frameMain:SetScript("OnDragStart", function() AugFramesLibrary:MainFrameMove() end)
    frameMain:SetScript("OnDragStop", function() AugFramesLibrary:MainFrameStop() end)

   -- Now we have our "container" frame set up, we can start creating the clickable areas and attaching them to the main frame
    for i = 1, 4 do
        -- print("Creating Clickable Area " .. i .. " at " .. quadData[i].location .. " -- SpellID " .. quadData[i].spell .. " -- Name " .. quadData[i].name .. " -- Target " .. quadData[i].unit) -- Debug print to let us know which area is being created
        AugFramesLibrary:CreateClickableArea(i, quadData[i].location) -- Create the clickable area and attach it to the main frame
    end
end

-- This is the "main loop", it'll handle the frame setup/teardown based on the players spec
function AugFramesLibrary:Main()
    local tmpDB = AugFramesDBLibrary:GetDB() -- Get the DB
    if tmpDB.profile.enabled == true then
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
	end
    AugFramesDBLibrary:SetDB(tmpDB) -- Set the DB with the new enabled/disabled value

    -- Run the main loop
    AugFramesLibrary:Main()
end