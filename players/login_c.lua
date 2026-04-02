local screenWidth, screenHeight = guiGetScreenSize()
local loginBrowser = nil
local muzykaLogowania = nil 

addEvent('login-menu:open', true)
addEventHandler('login-menu:open', root, function()
    if isElement(loginBrowser) then return end

    setCameraMatrix(0, 0, 100, 0, 100, 50)
    fadeCamera(true)

    showCursor(true, true)
    guiSetInputMode('no_binds')

    muzykaLogowania = playSound("muzyka.mp3", true) 
    
    if isElement(muzykaLogowania) then
        setSoundVolume(muzykaLogowania, 0.3) 
    end

    loginBrowser = guiCreateBrowser(0, 0, screenWidth, screenHeight, true, true, false)
    
    addEventHandler('onClientBrowserCreated', loginBrowser, function()
        loadBrowserURL(source, "http://mta/local/login.html")
    end)
end)

addEvent('login-menu:close', true)
addEventHandler('login-menu:close', root, function()
    if isElement(loginBrowser) then
        destroyElement(loginBrowser)
        loginBrowser = nil
    end
    
    if isElement(muzykaLogowania) then
        destroyElement(muzykaLogowania)
        muzykaLogowania = nil
    end

    showCursor(false)
    guiSetInputMode('allow_binds')
end)


addEvent('auth:clientLogin', true)
addEventHandler('auth:clientLogin', root, function(username, password)
    triggerServerEvent('auth:login-attempt', localPlayer, username, password)
end)

addEvent('auth:clientRegister', true)
addEventHandler('auth:clientRegister', root, function(username, password, repeatPassword)
    triggerServerEvent('auth:register-attempt', localPlayer, username, password, repeatPassword)
end)