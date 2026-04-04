local parkingSlots = {
    {-667.54, -1285.59, 11361.26, 270}, -- Miejsce 1 (Prawa strona)
    {-667.48, -1282.35, 11361.26, 270}, -- Miejsce 2
    {-667.43, -1279.11, 11361.26, 270}, -- Miejsce 3
    {-667.37, -1275.86, 11361.26, 270}, -- Miejsce 4
    {-667.32, -1272.62, 11361.26, 270}, -- Miejsce 5
    {-667.26, -1269.38, 11361.26, 270}  -- Miejsce 6 (Lewa strona)
}

-- Dla gracza
local entryX, entryY, entryZ = 1769.24, -1704.88, 13.50
local EntrygarageX, EntrygarageY, EntrygarageZ = -647.18, -1267.13, 11361.74
local ExitgarageX, ExitgarageY, ExitgarageZ = -645.94, -1280.70, 11360.54

-- Wejście
local entryMarker = createMarker(entryX, entryY, entryZ - 1, "cylinder", 1.5, 255, 255, 0, 150)
addEventHandler("onMarkerHit", entryMarker, function(hitElement)
    if getElementType(hitElement) == "player" and not isPedInVehicle(hitElement) then
        setElementPosition(hitElement, EntrygarageX, EntrygarageY, EntrygarageZ)
    end
end)

-- Wyjście
local exitMarker = createMarker(ExitgarageX, ExitgarageY , ExitgarageZ, "cylinder", 1.5, 255, 0, 0, 150)
addEventHandler("onMarkerHit", exitMarker, function(hitElement)
    if getElementType(hitElement) == "player" and not isPedInVehicle(hitElement) then
        setElementPosition(hitElement, entryX + 2, entryY, entryZ)
    end
end)

-- Narzędzia i Blip
addCommandHandler("tpp", function(player)
    setElementPosition(player, 1795.98,-1725.39, 13.55)
end)

createBlip(entryX, entryY, entryZ, 38, 2, 255, 0, 0, 255, 0, 500)

-- Dla samochodu

local carEntryX, carEntryY, carEntryZ = 1774.84, -1704.93, 13.50
local carExitX, carExitY, carExitZ = 1782.90, -1703.76, 13.52
local carExitGarageX, carExitGarageY, carExitGarageZ = -646.70, -1274.96, 11361.74
local carEntryGarageX, carEntryGarageY, carEntryGarageZ = -670.40, -1274.83, 11361.74

function getVehiclesInGarage()
    local count = 0
    local vehicles = getElementsByType("vehicle")
    for _, veh in ipairs(vehicles) do
        local x, y, z = getElementPosition(veh)
        if getDistanceBetweenPoints3D(x, y, z, carEntryGarageX, carEntryGarageY, carEntryGarageZ) < 50 then
            count = count + 1
        end
    end
    return count
end

function getFreeParkingSlot()
    for i, slot in ipairs(parkingSlots) do
        local sx, sy, sz = slot[1], slot[2], slot[3]
        
        local vehiclesNearSlot = getElementsWithinRange(sx, sy, sz, 2, "vehicle")
        
        if #vehiclesNearSlot == 0 then
            return slot 
        end
    end
    
    return false 
end

--Wjazd
local entryCarMarker = createMarker(carEntryX, carEntryY, carEntryZ - 5, "cylinder", 7, 154, 187, 207, 30)
addEventHandler("onMarkerHit", entryCarMarker, function(hitElement)
    if getElementType(hitElement) == "player" and isPedInVehicle(hitElement) then
        local veh = getPedOccupiedVehicle(hitElement)
        
        if getVehicleController(veh) == hitElement then
            
            local freeSlot = getFreeParkingSlot()
            
            if freeSlot then
                local targetX, targetY, targetZ, targetRot = freeSlot[1], freeSlot[2], freeSlot[3], freeSlot[4]
                
                removePedFromVehicle(hitElement)
                
                setElementPosition(veh, targetX, targetY, targetZ - 0.1)
                setElementRotation(veh, 0, 0, targetRot)
                setElementPosition(hitElement, EntrygarageX, EntrygarageY, EntrygarageZ)
                
            else
                outputChatBox("#FF0000[GARAŻ]#FFFFFF Garaż jest pełny (brak wolnych miejsc)!", hitElement, 255, 255, 255, true)
            end
            
        end
    end
end)

function wyjazdZGarazu(player, key, keyState)
    local veh = getPedOccupiedVehicle(player)
    
    if veh and getVehicleController(veh) == player then
        unbindKey(player, "w", "down", wyjazdZGarazu)
        
        toggleControl(player, "accelerate", false)
        toggleControl(player, "brake_reverse", false)
        
        local _, _, rz = getElementRotation(veh)
        local angle = math.rad(rz)
        local crawlSpeed = 0.12 
        setElementVelocity(veh, -math.sin(angle) * crawlSpeed, math.cos(angle) * crawlSpeed, 0)
        
        fadeCamera(player, false, 1.0) 
        
        setTimer(function()
            setElementPosition(veh, carExitX, carExitY, carExitZ - 0.35)
            setElementRotation(veh, 0, 0, 360) 
            
            setElementFrozen(veh, true)
            
            local camX, camY, camZ = carExitX - 6, carExitY - 6, carExitZ + 3
            setCameraMatrix(player, camX, camY, camZ, carExitX, carExitY, carExitZ)
            
            fadeCamera(player, true, 1.0) 
            
            setTimer(function()
                setElementFrozen(veh, false)
                setCameraTarget(player, player)
                
                toggleControl(player, "accelerate", true)
                toggleControl(player, "brake_reverse", true)
                
            end, 3000, 1)
            
        end, 1000, 1)
    end
end

addEventHandler("onVehicleEnter", root, function(thePlayer, seat)
    if seat == 0 then
        local vx, vy, vz = getElementPosition(source) 
        
        if getDistanceBetweenPoints3D(vx, vy, vz, carEntryGarageX, carEntryGarageY, carEntryGarageZ) < 50 then
            
            bindKey(thePlayer, "w", "down", wyjazdZGarazu)
            outputChatBox("#00FF00[GARAŻ]#FFFFFF Wciśnij 'W', aby wyjechać z garażu.", thePlayer, 255, 255, 255, true)
            
        end
    end
end)
