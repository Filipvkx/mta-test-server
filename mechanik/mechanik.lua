local playerJobVehicles = {}

addEvent("startWyjazdHurtownia", true)
addEventHandler("startWyjazdHurtownia", root, function()
    if isElement(playerJobVehicles[client]) then
        outputChatBox("Masz już przypisane auto! Czeka na zewnątrz.", client, 255, 0, 0)
        return
    end

    local x, y, z = 306.1, -238.15, 1.6
    local xr, yr, zr = 0, 0, 270
    
    local vehicle = createVehicle(413, x, y, z, 0, 0, 0)
    setElementRotation(vehicle, xr, yr, zr)
    setElementInterior(vehicle, 0)
    setElementDimension(vehicle, 0)
    
    setElementFrozen(vehicle, true) 
    
    playerJobVehicles[client] = vehicle

    outputChatBox("#533b70[MECHANIK]#ffffff Auto służbowe (Pony) czeka na zewnątrz! Wyjdź z warsztatu i do niego wsiądź.", client, 255, 255, 255, true)
end)

addEventHandler("onVehicleEnter", root, function(thePlayer, seat)
    if seat == 0 then 
        if playerJobVehicles[thePlayer] == source then
            setElementFrozen(source, false)
            
            if not getElementData(source, "trasaZacznieta") then
                setElementData(source, "trasaZacznieta", true)
                outputChatBox("#533b70[MECHANIK]#ffffff Ruszaj do hurtowni w Dilmore! Trasa została zaznaczona na radarze.", thePlayer, 255, 255, 255, true)
                triggerClientEvent(thePlayer, "startHurtowniaRoute", thePlayer)
            end
        end
    end
end)

addEvent("zakonczWyjazdHurtownia", true)
addEventHandler("zakonczWyjazdHurtownia", root, function()
    if isElement(playerJobVehicles[client]) then
        destroyElement(playerJobVehicles[client])
        playerJobVehicles[client] = nil
    end
end)

addEventHandler("onPlayerQuit", root, function()
    if isElement(playerJobVehicles[source]) then
        destroyElement(playerJobVehicles[source])
        playerJobVehicles[source] = nil
    end
end)

addCommandHandler("dajkase", function(player, command, ilosc)
    local kwota = tonumber(ilosc) or 50000 
    
    givePlayerMoney(player, kwota)
    outputChatBox("Dodano $" .. kwota .. " do testów HUD-a!", player, 0, 255, 100)
end)