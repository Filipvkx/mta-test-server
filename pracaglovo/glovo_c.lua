local jobMarker = createMarker(213.20, -183.17, 0.55, "cylinder", 1, 255, 100, 0, 30)
local jobBlip = createBlip(213.20, -183.17, 0.55, 29, 2, 255, 0, 0, 255, 0, 230)
setElementData(jobBlip, "tooltipText", "Praca dostawcy pizzy")

local currentMarker = nil
local currentBlip = nil
local jobWindow = nil

function showJobDialog()
    if isElement(jobWindow) then
        destroyElement(jobWindow)
        jobWindow = nil
    end
    
    jobWindow = guiCreateWindow(0.35, 0.4, 0.3, 0.2, "Praca dostawcy pizzy", true)
    guiCreateLabel(0.1, 0.2, 0.8, 0.3, "Chcesz rozpocząć zmianę?", true, jobWindow)

    local acceptBtn = guiCreateButton(0.1, 0.5, 0.35, 0.3, "Zacznij pracę", true, jobWindow)
    local cancelBtn = guiCreateButton(0.55, 0.5, 0.35, 0.3, "Anuluj", true, jobWindow)

    showCursor(true)
    guiSetInputMode("no_binds")

    local function closeJobWindow()
        if isElement(jobWindow) then
            destroyElement(jobWindow)
            jobWindow = nil
        end
        guiSetInputMode("allow_binds")
        showCursor(false)  
    end

    addEventHandler('onClientGUIClick', acceptBtn, function()
        closeJobWindow()
        triggerServerEvent('startPizzaJob', localPlayer)
    end, false)

    addEventHandler('onClientGUIClick', cancelBtn, function()
        closeJobWindow()
    end, false)
end

addEventHandler("onClientMarkerHit", jobMarker, function(player)
    if player == localPlayer then
        bindKey("e", "down", showJobDialog)
        outputChatBox("Naciśnij [E] aby rozpocząć pracę.", 255, 255, 0)
    end
end)

addEventHandler("onClientMarkerLeave", jobMarker, function(player)
    if player == localPlayer then
        unbindKey("e", "down", showJobDialog)
        if isElement(jobWindow) then
            destroyElement(jobWindow)
            jobWindow = nil
        end
        showCursor(false)
    end
end)

addEvent("startDeliveryRoute", true)
addEventHandler("startDeliveryRoute", localPlayer, function(firstPoint)
    if currentMarker and isElement(currentMarker) then destroyElement(currentMarker) end
    if currentBlip and isElement(currentBlip) then destroyElement(currentBlip) end
    
    currentMarker = createMarker(firstPoint[1], firstPoint[2], firstPoint[3]-1, "cylinder", 2, 255, 0, 0, 150)
    currentBlip = createBlip(firstPoint[1], firstPoint[2], firstPoint[3], 0, 2, 255, 0, 0, 255, 0, 99999)
    setElementData(currentBlip, "tooltipText", "Punkt dostawy")
    
    addEventHandler("onClientMarkerHit", currentMarker, function(hitPlayer, matchingDimension)
        if hitPlayer == localPlayer and matchingDimension then
            if isPedInVehicle(localPlayer) and getElementModel(getPedOccupiedVehicle(localPlayer)) == 462 then
                triggerServerEvent("deliveryPointReached", localPlayer)
                destroyElement(currentMarker)
                destroyElement(currentBlip)
            else
                outputChatBox("Musisz być na skuterze firmy!", 255, 0, 0)
            end
        end
    end)
end)

addEvent("nextDeliveryPoint", true)
addEventHandler("nextDeliveryPoint", localPlayer, function(point)
    if currentMarker and isElement(currentMarker) then destroyElement(currentMarker) end
    if currentBlip and isElement(currentBlip) then destroyElement(currentBlip) end
    
    currentMarker = createMarker(point[1], point[2], point[3]-1, "cylinder", 2, 255, 0, 0, 150)
    currentBlip = createBlip(point[1], point[2], point[3], 0, 2, 255, 0, 0, 255, 0, 99999)
    setElementData(currentBlip, "tooltipText", "Punkt dostawy")
    
    addEventHandler("onClientMarkerHit", currentMarker, function(hitPlayer, matchingDimension)
        if hitPlayer == localPlayer and matchingDimension then
            if isPedInVehicle(localPlayer) and getElementModel(getPedOccupiedVehicle(localPlayer)) == 462 then
                triggerServerEvent("deliveryPointReached", localPlayer)
                destroyElement(currentMarker)
                destroyElement(currentBlip)
            else
                outputChatBox("Musisz być na skuterze firmy!", 255, 0, 0)
            end
        end
    end)
end)

addEvent("returnToBase", true)
addEventHandler("returnToBase", localPlayer, function(base)
    if currentMarker and isElement(currentMarker) then destroyElement(currentMarker) end
    if currentBlip and isElement(currentBlip) then destroyElement(currentBlip) end
    
    currentMarker = createMarker(base[1], base[2], base[3]-1, "cylinder", 2, 0, 255, 0, 150)
    currentBlip = createBlip(base[1], base[2], base[3], 58, 2, 0, 255, 0, 255, 0, 99999)
    setElementData(currentBlip, "tooltipText", "Powrót do bazy")
    
    addEventHandler("onClientMarkerHit", currentMarker, function(hitPlayer, matchingDimension)
        if hitPlayer == localPlayer and matchingDimension then
            if isPedInVehicle(localPlayer) and getElementModel(getPedOccupiedVehicle(localPlayer)) == 462 then
                triggerServerEvent("jobCompleted", localPlayer)
                destroyElement(currentMarker)
                destroyElement(currentBlip)
            else
                outputChatBox("Musisz być na skuterze firmy!", 255, 0, 0)
            end
        end
    end)
end)

