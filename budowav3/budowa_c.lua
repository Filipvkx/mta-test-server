local isWorking = false
local startTick = nil


local jobMarker = createMarker(351.22, -87.01, 0.35, "cylinder", 1, 255, 100, 0, 30)
local jobBlip = createBlip(374.96, -97.58, 1.51, 11, 2, 255, 0, 0, 255, 0, 230)
setElementData(jobBlip, "tooltipText", "Początek pracy (kierownik)")

local jobWindow = nil

local screenW, screenH = guiGetScreenSize()
local font = "sans" 

addEventHandler("onClientRender", root, function()
    for _, ped in ipairs(getElementsByType("ped")) do
        if getElementData(ped, "nametag") == true then
            local px, py, pz = getElementPosition(localPlayer)
            local x, y, z = getElementPosition(ped)

            if getDistanceBetweenPoints3D(x, y, z, px, py, pz) < 10 then
                z = z + 1.2 
                
                local sx, sy = getScreenFromWorldPosition(x, y, z)
                if sx and sy then
                    local name = getElementData(ped, "name") or "NPC"             
                    dxDrawText(name, sx+1, sy+1, sx+1, sy+1, tocolor(0, 0, 0, 255), 1, "default-bold", "center", "bottom")
                    dxDrawText(name, sx, sy, sx, sy, tocolor(255, 255, 255, 255), 1, "default-bold", "center", "bottom")
                end
            end
        end
    end
end)

function showJobDialog()
    if isElement(jobWindow) then
        destroyElement(jobWindow)
        jobWindow = nil
    end
    
    jobWindow = guiCreateWindow(0.35, 0.4, 0.3, 0.25, "Praca budowa", true)
    guiCreateLabel(0.1, 0.2, 0.8, 0.3, "Chcesz rozpocząć zmianę?", true, jobWindow)

    local acceptBtn = guiCreateButton(0.1, 0.3, 0.35, 0.25, "Zacznij pracę", true, jobWindow)
    local cancelBtn = guiCreateButton(0.55, 0.3, 0.35, 0.25, "Anuluj", true, jobWindow)
    local infoBtn = guiCreateButton(0.55, 0.6, 0.35, 0.25, "Informacje o pracy", true, jobWindow)
    local lvlBtn = guiCreateButton(0.1, 0.6, 0.35, 0.25, "Informacje o doświadczeniu", true, jobWindow)

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
        triggerServerEvent('startBudowaJob', localPlayer)

    end, false)

    addEventHandler('onClientGUIClick', cancelBtn, function()
        closeJobWindow()
    end, false)

    addEventHandler('onClientGUIClick', infoBtn, function()
        closeJobWindow()      

        local infoWindow = guiCreateWindow(0.4, 0.4, 0.2, 0.3, "Informację o pracy", true)
        guiWindowIsSizable(infoWindow, false)

        local infoText = [[
            Praca budowlana 

            Wymagania: 
            - Prawo jazdy kat. B 
            - 100 RP 

            Wynagrodzenie:
            - Pierwszy poziom ok 4500/h

            Opis pracy:
            - Dostarczanie materiałów budowlanych
            - Pomoc przy konstrukcji
            - Wykonywanie poleceń kierownika
        ]]
        
        guiCreateLabel(0.05, 0.1, 0.9, 0.7, infoText, true, infoWindow)
        guiLabelSetHorizontalAlign(infoWindow, "left", true)
        showCursor(true)
        guiSetInputMode("no_binds")

        local closeInfoBtn = guiCreateButton(0.15, 0.85, 0.3, 0.1, "Zamknij", true, infoWindow)

        addEventHandler('onClientGUIClick', closeInfoBtn, function ()
            if isElement(infoWindow) then
                destroyElement(infoWindow)
                showCursor(false)
                guiSetInputMode("allow_binds")
            end
        end, false)
    end, false)

    addEventHandler('onClientGUIClick', lvlBtn, function()
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

function playJobCutscene()
    local npc = getElementByID("jobNPC")
    if not npc or not isElement(npc) then
        outputDebugString("NPC not found!")
        return
    end
    
    local nx, ny, nz = getElementPosition(npc)
    setCameraMatrix(
        nx - 2, ny + 2, nz + 1.5,
        nx, ny, nz + 1
    )
      
    local dialogs = {
        {
            speaker = npc,
            name = "Kierownik",
            text = "Siemasz młody w sam raz na czas!",
            color = "#FFA500",
            duration = 3000
        },
        {
            speaker = npc,
            name = "Kierownik",
            text = "No dobra słuchaj ja jadę do hurtowni, a ty sobie tu dziubaj na spokojnie..",
            color = "#FFA500",
            duration = 4000
        },
        {
            speaker = localPlayer,
            name = "Młody",
            text = "Ale co ja mam właściwie robić?",
            color = "#FFD700",
            duration = 3000
        },
        {
            speaker = npc,
            name = "Kierownik",
            text = "Zapytaj się Pitera, pokaże ci wszystko",
            color = "#FFA500",
            duration = 4000
        }
    }

    for i, dialog in ipairs(dialogs) do
        setTimer(function()
            outputChatBox(dialog.color.."["..dialog.name.."]#FFFFFF "..dialog.text, 255, 255, 255, true)
            
            showDialogBubble(dialog.speaker, dialog.text, dialog.duration)
            
            setPedAnimation(dialog.speaker, "ped", "IDLE_CHAT", -1, true, false, false)
            
            if i == #dialogs then
                setTimer(function()
                    setPedAnimation(npc)
                    setPedAnimation(localPlayer)
                    setCameraTarget(localPlayer)
                end, dialog.duration, 1)
            end
        end, calculateDelay(dialogs, i), 1)
    end
end

function calculateDelay(dialogs, currentIndex)
    local delay = 0
    for i = 1, currentIndex-1 do
        delay = delay + dialogs[i].duration
    end
    return delay
end

addEvent("onJobStarted", true)
addEventHandler("onJobStarted", resourceRoot, function()
    isWorking = true
    playJobCutscene()
end)

local cameraPoints = {
    {x=351.2, y=-87.0, z=15.0, lookX=350.0, lookY=-85.0, lookZ=1.0}, 
    {x=355.0, y=-90.0, z=5.0, lookX=351.0, lookY=-87.0, lookZ=1.0},  
}

function playAdvancedCutscene()
    setCameraMatrix(
        cameraPoints[1].x, cameraPoints[1].y, cameraPoints[1].z,
        cameraPoints[1].lookX, cameraPoints[1].lookY, cameraPoints[1].lookZ
    )
    
    setTimer(function()
        smoothMoveCamera(
            cameraPoints[1].x, cameraPoints[1].y, cameraPoints[1].z, cameraPoints[1].lookX, cameraPoints[1].lookY, cameraPoints[1].lookZ,
            cameraPoints[2].x, cameraPoints[2].y, cameraPoints[2].z, cameraPoints[2].lookX, cameraPoints[2].lookY, cameraPoints[2].lookZ,
            3000 -- czas przejścia w ms
        )
    end, 3000, 1)
    
    setTimer(setCameraTarget, 6000, 1, localPlayer)
end

function smoothMoveCamera(x1,y1,z1,x1t,y1t,z1t, x2,y2,z2,x2t,y2t,z2t, time)
    local cam = {x=x1,y=y1,z=z1,xt=x1t,yt=y1t,zt=z1t}
    addEventHandler("onClientPreRender", root, function()
        local progress = (getTickCount() - startTick) / time
        if progress > 1 then
            removeEventHandler("onClientPreRender", root, smoothMoveCamera)
            return
        end
        cam.x = interpolateBetween(x1,0,0, x2,0,0, progress, "InOutQuad")
        cam.y = interpolateBetween(y1,0,0, y2,0,0, progress, "InOutQuad")
        cam.z = interpolateBetween(z1,0,0, z2,0,0, progress, "InOutQuad")
        cam.xt = interpolateBetween(x1t,0,0, x2t,0,0, progress, "InOutQuad")
        cam.yt = interpolateBetween(y1t,0,0, y2t,0,0, progress, "InOutQuad")
        cam.zt = interpolateBetween(z1t,0,0, z2t,0,0, progress, "InOutQuad")
        setCameraMatrix(cam.x, cam.y, cam.z, cam.xt, cam.yt, cam.zt)
    end)
end

function showDialogBubble(element, text, duration)
    if not isElement(element) then return end
    
    local startTime = getTickCount()
    local endTime = startTime + duration
    
    addEventHandler("onClientRender", root, 
        function()
            if getTickCount() > endTime then
                removeEventHandler("onClientRender", root, showDialogBubble)
                return
            end
            
            local x, y, z = getElementPosition(element)
            z = z + 1  
            if isElementOnScreen(element) then
                local sx, sy = getScreenFromWorldPosition(x, y, z)
                if sx and sy then
                    local textWidth = dxGetTextWidth(text, 1, "sans") + 20
                    dxDrawRectangle(sx - textWidth/2, sy - 30, textWidth, 25, tocolor(0, 0, 0, 80))
                    dxDrawText(text, sx, sy - 30, sx, sy - 5, tocolor(255, 255, 255, 255), 1, "sans", "center", "center")
                    dxDrawRectangle(sx - 5, sy - 5, 10, 10, tocolor(0, 0, 0, 80))
                end
            end
        end
    )
end