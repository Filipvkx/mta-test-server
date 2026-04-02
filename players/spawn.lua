addEvent("teleportujNaSpawn", true)
addEventHandler("teleportujNaSpawn", root, function(miasto)
    local x, y, z
    local skin = getElementModel(client)
    if skin == 0 then skin = 0 end 

    if miasto == "LS" then
        x, y, z = 1760.0, -1888.0, 13.5 
    elseif miasto == "SF" then
        x, y, z = -2240.0, 137.0, 35.0 
    elseif miasto == "LV" then
        x, y, z = 1690.0, 1445.0, 10.5 
    end

    spawnPlayer(client, x, y, z, 0, skin)
    fadeCamera(client, true)
    setCameraTarget(client, client)
    
end)