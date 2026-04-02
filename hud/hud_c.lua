local screenW, screenH = guiGetScreenSize()
local hudWindow = nil
local hudBrowser = nil 

local elementsToHide = {
    "weapon", "ammo", "health", "clock", "money", "breath", "armour", "vehicle_name"
}

addEventHandler("onClientResourceStart", resourceRoot, function()
    for _, component in ipairs(elementsToHide) do
        setPlayerHudComponentVisible(component, false)
    end

    hudWindow = guiCreateBrowser(0, 0, screenW, screenH, true, true, true)
    
    hudBrowser = guiGetBrowser(hudWindow)
    
    addEventHandler("onClientBrowserCreated", hudBrowser, function()
        loadBrowserURL(source, "http://mta/local/hud.html")
    end)
end)

local lastMoney = -1
local lastHealth = -1

setTimer(function()
    if not isElement(hudWindow) or not hudBrowser then return end
    
    local myMoney = getPlayerMoney()
    local myHealth = math.floor(getElementHealth(localPlayer))
    if myHealth < 0 then myHealth = 0 end

    if myMoney ~= lastMoney or myHealth ~= lastHealth then
        executeBrowserJavascript(hudBrowser, string.format("updateHud(%d, %d)", myHealth, myMoney))
        
        lastMoney = myMoney
        lastHealth = myHealth
    end
end, 200, 0)

addEventHandler("onClientResourceStop", resourceRoot, function()
    for _, component in ipairs(elementsToHide) do
        setPlayerHudComponentVisible(component, true)
    end
end)