

addCommandHandler('flycar', function ()
    local vehicle = getPedOccupiedVehicle(localPlayer)
    if not vehicle then
        outputChatBox('You are not in a vehicle.', 255, 100, 100)
    end
    
    setWorldSpecialPropertyEnabled('aircars', true)
end)

addCommandHandler('repair', function()
    local vehicle = getPedOccupiedVehicle(localPlayer)
    if not vehicle then
        outputChatBox('You are not in a vehicle.', 255, 100, 100)
    end

    fixVehicle(vehicle)
    outputChatBox('Your vehicle has been repaired!', 100, 255, 100)
end)


