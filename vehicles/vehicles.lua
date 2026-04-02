function createVehicleForPlayer(player, command, model)
    local account = getPlayerAccount(player)
    if not account or isGuestAccount(account) then
        outputChatBox("#533b70[SYSTEM]#ffffff Nie przyznano dostępu.", 255, 255, 255, true)
        return
    end

    local in_garage = 0
    local owner = getAccountName(account)

    local db = exports.db:getConnection()
    local x, y, z = getElementPosition(player)
    local rx, ry, rz = getElementRotation(player)
    rz = rz + 90
    y = y + 5

    dbExec(db, 'INSERT INTO vehicles (model, x, y, z, rx, ry, rz, owner, in_garage) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)', model, x, y, z, rx, ry, rz, owner, in_garage)

    local vehicleObject = createVehicle(model, x, y, z, rx, ry, rz)

    dbQuery(function (queryHandle) 
        local results = dbPoll(queryHandle, 0)
        local vehicle = results[1]

        setElementData(vehicleObject, 'id', vehicle.id)
        setElementData(vehicleObject, 'owner', owner)
        setElementData(vehicleObject, 'in_garage', in_garage)
        
    end, db, 'SELECT id FROM vehicles ORDER BY id DESC LIMIT 1')
end
addCommandHandler('createvehicle', createVehicleForPlayer, false, false)
addCommandHandler('crvhc', createVehicleForPlayer, false, false)

function loadAllVehicles(queryHandle)
    local results = dbPoll(queryHandle, 0)

    for index, vehicle in pairs(results) do
        if vehicle.in_garage == 0 then
            local vehicleObject = createVehicle(vehicle.model, vehicle.x, vehicle.y, vehicle.z, vehicle.rx, vehicle.ry, vehicle.rz)

            if vehicleObject then
                if vehicle.rx and vehicle.ry and vehicle.rz then
                    setElementRotation(vehicleObject, vehicle.rx, vehicle.ry, vehicle.rz)
                end

                setElementData(vehicleObject, "id", vehicle.id)
                setElementData(vehicleObject, "owner", vehicle.owner)
                setElementData(vehicleObject, "in_garage", vehicle.in_garage)
            end
        end
    end
end

addEventHandler('onResourceStart', resourceRoot, function ()
    local db = exports.db:getConnection()
    dbQuery(loadAllVehicles, db, 'SELECT * FROM vehicles')
end)

addEventHandler('onResourceStop', resourceRoot, function ()
    local db = exports.db:getConnection()
    local vehicles = getElementsByType('vehicle')

    for index, vehicle in pairs(vehicles) do
        local id = getElementData(vehicle, 'id')
        local x, y, z = getElementPosition(vehicle)
        local rx, ry, rz = getElementRotation(vehicle)

        dbExec(db, 'UPDATE vehicles SET x = ?, y = ?, z = ?, rx = ?, ry = ?, rz = ? WHERE id = ?', x, y, z, rx, ry, rz, id)
    end
end)

addEventHandler('onVehicleStartEnter', root, function (enteringPlayer, seat, jacked, door)
    local owner = getElementData(source, "owner")
    
    if owner and seat == 0 then
        local account = getPlayerAccount(enteringPlayer)
        if not account or isGuestAccount(account) then
            cancelEvent()
            outputChatBox("#533b70[SYSTEM]#ffffff Musisz być zalogowany, aby prowadzić prywatne pojazdy.", enteringPlayer, 255, 255, 255, true)
            return
        end

        local accountName = getAccountName(account)
        if accountName ~= owner then
            cancelEvent()
            outputChatBox("#533b70[SYSTEM]#ffffff Nie masz dostępu do tego pojazdu!", enteringPlayer, 255, 255, 255, true)
        end
    end
end)
