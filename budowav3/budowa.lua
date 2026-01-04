addEventHandler("onResourceStart", resourceRoot, function()
    local x, y, z = 369.44, -122.76, 1.28
    local rot = 360
    local skinID = 16
    local pracownik1npc = createPed(skinID, x, y, z, rot)
    setElementFrozen(pracownik1npc, true)
    setElementData(pracownik1npc, "nametag", true)
    setElementData(pracownik1npc, "name", "Kasjusz (Konfident)")
end)

addEventHandler("onResourceStart", resourceRoot, function()
    local x, y, z = 351.22, -87.01, 1.35
    local rot = 360
    local skinID = 24
    local pracownik2npc = createPed(skinID, x, y, z, rot)
    setElementFrozen(pracownik2npc, true)
    setElementData(pracownik2npc, "nametag", true)
    setElementData(pracownik2npc, "name", "Walduś (Kieras)")
    setElementID(pracownik2npc, "jobNPC")
end)

addEventHandler("onResourceStart", resourceRoot, function()
    local x, y, z = 346.51, -106.01, 1.32
    local rot = 180
    local skinID = 135
    local pracownik3npc = createPed(skinID, x, y, z, rot)
    setElementFrozen(pracownik3npc, true)
    setElementData(pracownik3npc, "nametag", true)
    setElementData(pracownik3npc, "name", "Piter (Alkoholik)")
end)

addEventHandler("onResourceStart", resourceRoot, function()
    local x, y, z = 373.40, -80.82, 1.38
    local rot = 180
    local skinID = 268
    local pracownik4npc = createPed(skinID, x, y, z, rot)
    setElementFrozen(pracownik4npc, true)
    setElementData(pracownik4npc, "nametag", true)
    setElementData(pracownik4npc, "name", "Michał (Młody)")
end)

local playerJobData = {}
local CementPoints = {
    {208.52, -102.60, 1.56},
    {254.48, -63.78, 1.58},
    {342.55, -71.45, 1.46},
    {273.19, -158.11, 1.74},
    {211.52, -161.47, 1.58}
}

addEvent("startBudowaJob", true)
addEventHandler("startBudowaJob", root, function()
    if playerJobData[client] then 
        outputChatBox("#FF0000[ERROR] #FFFFFFMasz już aktywną pracę!", client, 255, 255, 255, true)
        return 
    end
    
    playerJobData[client] = true
    outputChatBox("#00FF00[PRACA] #FFFFFFRozpocząłeś pracę budowlańca!", client, 255, 255, 255, true)

    triggerClientEvent(client, "onJobStarted", resourceRoot)
end)

addCommandHandler("anulujprace", function(player)
    if not playerJobData[player] then
        outputChatBox("#FF0000[ERROR] #FFFFFFNie masz aktywnej pracy do anulowania!", player, 255, 255, 255, true)
        return
    end
end)