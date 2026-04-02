local screenW, screenH = guiGetScreenSize()
local spawnWindow = nil

addEvent("pokazMenuSpawnu", true)
addEventHandler("pokazMenuSpawnu", root, function()
    if isElement(spawnWindow) then return end

    showCursor(true)
    
    setPlayerHudComponentVisible("radar", false)
    showChat(false)

    spawnWindow = guiCreateBrowser(0, 0, screenW, screenH, true, true, false)
    local b = guiGetBrowser(spawnWindow)
    addEventHandler("onClientBrowserCreated", b, function()
        loadBrowserURL(source, "http://mta/local/spawn.html")
    end)
end)

addEvent("wybierzSpawn", true)
addEventHandler("wybierzSpawn", root, function(miasto)
    if isElement(spawnWindow) then destroyElement(spawnWindow) end
    showCursor(false)
    
    setPlayerHudComponentVisible("radar", true)
    showChat(true)
    
    triggerServerEvent("teleportujNaSpawn", localPlayer, miasto)
end)