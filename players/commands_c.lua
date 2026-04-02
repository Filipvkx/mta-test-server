

addCommandHandler("clearchat", function()
    for i = 1, 20 do
        outputChatBox(" ")
    end   
end)


addCommandHandler("pos", function()
    local x, y, z = getElementPosition(localPlayer)
    outputChatBox(string.format("Twoje kordy to: X=%.2f, Y=%.2f, Z=%.2f", x, y, z), 255, 255, 0)
end)

addCommandHandler("tpprzed", function()
    setElementInterior(localPlayer, 0)
    setElementDimension(localPlayer, 0)
    setElementPosition(localPlayer, 305.88, -242.40, 1.58)
    setCameraTarget(localPlayer)
    outputChatBox("Przeniesiono pod warsztat!", 0, 255, 0)
end)

addCommandHandler("tpdo", function()
    setElementInterior(localPlayer, 3)
    setElementDimension(localPlayer, 0)
    setElementPosition(localPlayer, 620.19, -121.63, 998.85)
    setCameraTarget(localPlayer)
    outputChatBox("Przeniesiono do warsztatu!", 0, 255, 0)
end)

addCommandHandler("cam", function()
    camOn = not camOn
    if camOn then
        camX, camY, camZ, _, _, _ = getCameraMatrix()
        showCursor(true)
        addEventHandler("onClientPreRender", root, moveCam)
        outputChatBox("#533b70[KAMERA]#ffffff Tryb ustawiania włączony. WSAD - ruch, Myszka - obrót, ALT - kordy pod F8.", 255, 255, 255, true)
    else
        removeEventHandler("onClientPreRender", root, moveCam)
        setCameraTarget(localPlayer)
        showCursor(false)
        outputChatBox("#533b70[KAMERA]#ffffff Wyłączono.", 255, 255, 255, true)
    end
end)

function moveCam()
    if not isCursorShowing() then return end
    local mx, my = getCursorPosition()
    rotX = rotX - (mx - 0.5) * 5
    rotY = rotY - (my - 0.5) * 5
    setCursorPosition(sx/2, sy/2)

    local rz = math.rad(rotX)
    local rx = math.rad(rotY)
    
    if getKeyState("w") then camX = camX + math.sin(rz) * speed camY = camY + math.cos(rz) * speed end
    if getKeyState("s") then camX = camX - math.sin(rz) * speed camY = camY - math.cos(rz) * speed end
    if getKeyState("d") then camX = camX + math.cos(rz) * speed camY = camY - math.sin(rz) * speed end
    if getKeyState("a") then camX = camX - math.cos(rz) * speed camY = camY + math.sin(rz) * speed end

    local lx = camX + math.sin(rz) * math.cos(rx)
    local ly = camY + math.cos(rz) * math.cos(rx)
    local lz = camZ + math.sin(rx)

    setCameraMatrix(camX, camY, camZ, lx, ly, lz)
    
    if getKeyState("lalt") then
        outputConsole(string.format("setCameraMatrix(%.3f, %.3f, %.3f, %.3f, %.3f, %.3f)", camX, camY, camZ, lx, ly, lz))
    end
end