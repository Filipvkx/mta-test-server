local window

local function getWindowPosition(width, height)
    local screenWidth, screenHeight = guiGetScreenSize()
    local x = (screenWidth / 2) - (width / 2)
    local y = (screenHeight / 2) - (height / 2)
    return x, y, width, height
end

local function isUsernameValid(username)
    return type(username) == 'string' and string.len(username) > 1
end

local function isPasswordValid(password)
    return type(password) == 'string' and string.len(password) > 6
end

local function isRepeatPasswordValid(repeatPassword)
    return type(repeatPassword) == 'string' and string.len(repeatPassword) > 6
end

addEvent('register-menu:open', true)
addEventHandler('register-menu:open', root, function()
    -- fade their camera in
    setCameraMatrix(0, 0, 100, 0, 100, 50)
    fadeCamera(true)

    -- initialize the cursor
    showCursor(true, true)
    guiSetInputMode('no_binds')

    -- open our menu
    local x, y, width, height = getWindowPosition(400, 250)
    window = guiCreateWindow(x, y, width, height, 'Sign-Up to Our Server', false)
    guiWindowSetMovable(window, false)
    guiWindowSetSizable(window, false)

    -- Username elements
    local usernameLabel = guiCreateLabel(15, 30, width - 30, 20, 'Username:', false, window)

    local usernameErrorLabel = guiCreateLabel(width - 130, 30, 150, 20, 'Username is required', false, window)
    guiLabelSetColor(usernameErrorLabel, 255, 100, 100)
    guiSetVisible(usernameErrorLabel, false)

    local usernameInput = guiCreateEdit(10, 50, width - 20, 30, '', false, window)

    -- Password elements
    local passwordLabel = guiCreateLabel(15, 90, width - 30, 20, 'Password:', false, window)

    local passwordErrorLabel = guiCreateLabel(width - 125, 90, 150, 20, 'Password is required', false, window)
    guiLabelSetColor(passwordErrorLabel, 255, 100, 100)
    guiSetVisible(passwordErrorLabel, false)
    local passwordInput = guiCreateEdit(10, 110, width - 20, 30, '', false, window)

    guiEditSetMasked(passwordInput, true)

    -- Repeat Password elements
    local repeatPasswordLabel = guiCreateLabel(15, 150, width - 30, 20, 'Repeat Password:', false, window)

    local repeatPasswordErrorLabel = guiCreateLabel(width - 135, 150, 150, 20, 'Passwords must match', false, window)
    guiLabelSetColor(repeatPasswordErrorLabel, 255, 100, 100)
    guiSetVisible(repeatPasswordErrorLabel, false)
    local repeatPasswordInput = guiCreateEdit(10, 170, width - 20, 30, '', false, window)

    guiEditSetMasked(repeatPasswordInput, true)

    -- Buttons
    local SignUpButton = guiCreateButton(10, 210, (width / 2) - 15, 30, 'Sign Up', false, window)
    local BackButton = guiCreateButton(width / 2 + 5, 210, width / 2 - 15, 30, 'Back', false, window)

    -- Sign Up button handler
    addEventHandler('onClientGUIClick', SignUpButton, function(button, state)
        if button ~= 'left' or state ~= 'up' then
            return 
        end

        local username = guiGetText(usernameInput)
        local password = guiGetText(passwordInput)
        local repeatPassword = guiGetText(repeatPasswordInput)
        local inputValid = true

        -- Reset error labels
        guiSetVisible(usernameErrorLabel, false)
        guiSetVisible(passwordErrorLabel, false)
        guiSetVisible(repeatPasswordErrorLabel, false)

        -- Validate inputs
        if not isUsernameValid(username) then
            guiSetVisible(usernameErrorLabel, true)
            inputValid = false
        end

        if not isPasswordValid(password) then
            guiSetVisible(passwordErrorLabel, true)
            inputValid = false
        end

        if not isRepeatPasswordValid(repeatPassword) then
            guiSetVisible(repeatPasswordErrorLabel, true)
            inputValid = false
        end

        if password ~= repeatPassword then
            guiSetVisible(repeatPasswordErrorLabel, true)
            outputChatBox("Passwords don't match!", 255, 0, 0)
            inputValid = false
        end

        if not inputValid then
            return 
        end

        -- Send data to server
        triggerServerEvent('auth:register-attempt', localPlayer, username, password, repeatPassword)
        
        -- Close window after registration
        destroyElement(window)

        -- Reopen login menu hehe
        triggerEvent("login-menu:open", localPlayer)
        showCursor(false)
    end, false)

    -- Back button handler
    addEventHandler('onClientGUIClick', BackButton, function(button, state)
        if button ~= 'left' or state ~= 'up' then
            return 
        end
    
        -- Close registration window
        destroyElement(window)
    
        -- Reopen login menu
        triggerEvent("login-menu:open", localPlayer)
    end, false)
end)