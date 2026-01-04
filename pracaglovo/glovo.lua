local playerJobVehicles = {}
local playerJobData = {}

local deliveryPoints = {
    {208.52, -102.60, 1.56},
    {254.48, -63.78, 1.58},
    {342.55, -71.45, 1.46},
    {273.19, -158.11, 1.74},
    {211.52, -161.47, 1.58}
}

local baseLocation = {203.44, -182.54, 1.58}

addEventHandler("onResourceStart", resourceRoot, function()
    local x, y, z = 213.20, -183.17, 1.58
    local rot = 360
    local skinID = 167
    local npc = createPed(skinID, x, y, z, rot)
    setElementFrozen(npc, true)
    setElementData(npc, "npc.name", "Tony (Manager Pizzerii)")
    setElementData(npc, "nametag", true)
    setElementData(npc, "name", "Tony")
end)

addEvent("startPizzaJob", true)
addEventHandler("startPizzaJob", root, function()
    if isElement(playerJobVehicles[client]) then
        outputChatBox("Masz już przypisany pojazd!", client, 255, 0, 0)
        return
    end

    if playerJobData[client] then return end

    local x, y, z = 203.32, -182.46, 1.58
    local vehicle = createVehicle(462, x, y, z, 0, 0, 360)
    warpPedIntoVehicle(client, vehicle)
    setElementData(vehicle, "pizza.job.vehicle", true)

    playerJobVehicles[client] = vehicle
    playerJobData[client] = {
        currentPoint = 1,
        delivered = 0,
        markers = {},
        blips = {}
    }

    triggerClientEvent(client, "startDeliveryRoute", client, deliveryPoints[1])
    outputChatBox("Rozpocząłeś pracę dostawcy jedzenia [Glovo]!", client, 0, 255, 0)
    outputChatBox("Udaj się do pierwszego punktu dostawy oznaczonego na mapie.", client, 255, 255, 0)
    playSoundFrontEnd(client, 43)
end)

addCommandHandler("anulujprace", function(player)
    if playerJobData[player] then
        cleanUpPlayerJob(player)
        outputChatBox("Praca anulowana.", player, 255, 0, 0)
    else
        outputChatBox("Nie masz aktywnych zleceń.", player, 255, 255, 0)
    end
end)

function cleanUpPlayerJob(player)
    if isElement(playerJobVehicles[player]) then
        destroyElement(playerJobVehicles[player])
    end
    
    if playerJobData[player] then
        for _, marker in pairs(playerJobData[player].markers) do
            if isElement(marker) then destroyElement(marker) end
        end
        for _, blip in pairs(playerJobData[player].blips) do
            if isElement(blip) then destroyElement(blip) end
        end
    end
    
    playerJobVehicles[player] = nil
    playerJobData[player] = nil
end

addEvent("deliveryPointReached", true)
addEventHandler("deliveryPointReached", root, function()
    if not playerJobData[client] then return end

    playerJobData[client].delivered = playerJobData[client].delivered + 1

    if playerJobData[client].delivered >= 5 then
        triggerClientEvent(client, "returnToBase", client, baseLocation)
        outputChatBox("Dostarczyłeś wszystkie pizze! Wróć do bazy.", client, 0, 255, 0)
    else
        playerJobData[client].currentPoint = playerJobData[client].currentPoint + 1
        triggerClientEvent(client, "nextDeliveryPoint", client, deliveryPoints[playerJobData[client].currentPoint])
    end
end)

addEvent("jobCompleted", true)
addEventHandler("jobCompleted", root, function()
    if playerJobData[client] then
        outputChatBox("Gratulacje! Ukończyłeś pracę. Zarobiłeś $5000", client, 0, 255, 0)
        givePlayerMoney(client, 5000)
        cleanUpPlayerJob(client)
    end
end)