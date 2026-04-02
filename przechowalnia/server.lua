-- Wejście (pod przechowalnią)
local entryX, entryY, entryZ = 1769.24, -1704.88, 13.50
createBlip(entryX, entryY, entryZ, 38, 2, 255, 0, 0, 255, 0, 500)

-- Środek garażu 
local garageX, garageY, garageZ = -646.7, -1280.7, 11361.7

local entryMarker = createMarker(entryX, entryY, entryZ - 1, "cylinder", 1.5, 255, 255, 0, 150)

addEventHandler("onMarkerHit", entryMarker, function(hitElement)
    if getElementType(hitElement) == "player" and not isPedInVehicle(hitElement) then
        setElementPosition(hitElement, garageX, garageY, garageZ + 1.5)
    end
end)

local exitMarker = createMarker(garageX, garageY + 5, garageZ - 1, "cylinder", 1.5, 255, 0, 0, 150)

addEventHandler("onMarkerHit", exitMarker, function(hitElement)
    if getElementType(hitElement) == "player" then
        setElementPosition(hitElement, entryX + 2, entryY, entryZ)
    end
end)

addCommandHandler("tpp", function(player)
    setElementPosition(player, 1795.98,-1725.39, 13.55)
end)