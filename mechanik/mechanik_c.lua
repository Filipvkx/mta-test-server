local jobBlip = createBlip(312.50, -239.00, 1.58, 27, 2, 255, 0, 0, 255, 0, 230)
local jobMarkerEntry = createMarker(303.32, -226.63, 0.58, "cylinder", 1, 124, 111, 191, 50)
local jobMarkerExit = createMarker(620.17, -119.77, 997.85, "cylinder", 1, 124, 111, 191, 50)
setElementInterior(jobMarkerExit, 3)

local hurtowniaX, hurtowniaY, hurtowniaZ = 854.56, -604.93, 18.42
local sx, sy = guiGetScreenSize()

local poprzedniSkin = nil
local przegladarkaTablicy = nil
local sklepBrowser = nil
local hudCzesciBrowser = nil
local maskaBrowser = nil
local silnikBrowser = nil
local minigraBrowser = nil

local currentBlip = nil
local strefaHurtowni = nil
local wejscieHurtowni = nil
local wyjscieZeSklepu = nil
local kasaSklepowa = nil

local mozliweUsterki = {
    "Olej silnikowy",
    "Filtr Kabinowy",
    "Filtr powietrza",
    "Akumulator",
    "Płyn do spryskiwaczy",
    "Wymiana ogumienia",
    "Wymiana klamek",
    "Wymiana zamka od bagażnika"
}

local aktualneZlecenie = {}
local statusCzesci = {}
local zlecenieAktywne = false
local zakupyZrobione = false
local etapNaprawy = false
local trybInterakcji = false

local tablicaMarker = createMarker(611.22, -120.07, 997.00, "cylinder", 1, 104, 154, 194, 50)
setElementInterior(tablicaMarker, 3)

local crashedCar = createVehicle(562, 615.5, -124.5, 997.55)
setElementRotation(crashedCar, 0, 0, 90)
setElementInterior(crashedCar, 3)
setElementFrozen(crashedCar, true)
setVehicleLocked(crashedCar, true)
setVehicleDamageProof(crashedCar, true)
setVehicleColor(crashedCar, 100, 100, 100)

addCommandHandler("kordy", function()
    local x, y, z = getElementPosition(localPlayer)
    outputChatBox("#00ff00[INFO]#ffffff Kordy zapisano w konsoli (F8)!", 255, 255, 255, true)
    outputConsole(x .. ", " .. y .. ", " .. z)
end)

addEventHandler("onClientResourceStart", resourceRoot, function()
    setPlayerHudComponentVisible("radar", true)
    showChat(true)
end)

local postepDodatkowy = {} 
local wybraneKolo = ""
local wybranaKlamka = ""

function generujNoweZlecenie()
    if #aktualneZlecenie > 0 then return end 
    
    aktualneZlecenie = {}
    statusCzesci = {}
    zakupyZrobione = false
    etapNaprawy = false

    postepDodatkowy = {
        koloLP = false, koloPP = false, koloLT = false, koloPT = false,
        klamkaL = false, klamkaP = false
    }

    local iloscZepsutychCzesci = math.random(4, 5) 
    local tymczasowaBaza = {unpack(mozliweUsterki)}

    for i = 1, iloscZepsutychCzesci do
        if #tymczasowaBaza > 0 then
            local wylosowanyIndex = math.random(1, #tymczasowaBaza)
            local usterka = tymczasowaBaza[wylosowanyIndex]
            
            table.insert(aktualneZlecenie, usterka)
            statusCzesci[usterka] = false
            
            table.remove(tymczasowaBaza, wylosowanyIndex)
        end
    end
    
    outputChatBox("#533b70[MECHANIK]#ffffff Nowe zlecenie! Liczba napraw: #ffb300" .. #aktualneZlecenie, 255, 255, 255, true)
end

function sprawdzKoniecZlecenia()
    local wszystkieZrobione = true
    for _, status in pairs(statusCzesci) do
        if not status then
            wszystkieZrobione = false
            break
        end
    end
    if wszystkieZrobione then
        outputChatBox("#00ff00[SUKCES]#ffffff Naprawiłeś wszystkie usterki! Zlecenie zakończone.", 255, 255, 255, true)
        aktualneZlecenie = {}
        statusCzesci = {}
        zakupyZrobione = false
        etapNaprawy = false
        zlecenieAktywne = false
        setVehicleDoorOpenRatio(crashedCar, 0, 0, 1000)
    end
end


bindKey("x", "down", function()
    if getElementInterior(localPlayer) ~= 3 then return end
    if isElement(przegladarkaTablicy) or isElement(silnikBrowser) or isElement(minigraBrowser) then return end
    
    trybInterakcji = not trybInterakcji
    showCursor(trybInterakcji)
    if trybInterakcji then
        outputChatBox("#533b70[MECHANIK]#ffffff Tryb interakcji włączony. Kliknij na auto.", 255, 255, 255, true)
    else
        if isElement(maskaBrowser) then destroyElement(maskaBrowser) end
    end
end)

addEventHandler("onClientClick", root, function(button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement)
    if not trybInterakcji then return end
    if button == "left" and state == "down" then
        if clickedElement == crashedCar then
            local px, py, pz = getElementPosition(localPlayer)
            local cx, cy, cz = getElementPosition(crashedCar)
            if getDistanceBetweenPoints3D(px, py, pz, cx, cy, cz) < 5 then
                if not isElement(maskaBrowser) and not isElement(silnikBrowser) then
                    maskaBrowser = guiCreateBrowser(absoluteX, absoluteY, 300, 80, true, true, false)
                    addEventHandler("onClientBrowserCreated", maskaBrowser, function()
                        loadBrowserURL(source, "http://mta/local/maska.html")
                    end)
                end
            end
        end
    end
end)

addEvent("akcjaMaska", true)
addEventHandler("akcjaMaska", root, function(akcja)
    if isElement(maskaBrowser) then
        destroyElement(maskaBrowser)
        maskaBrowser = nil
    end

    if akcja == "otworz" then
        trybInterakcji = false
        setVehicleDoorOpenRatio(crashedCar, 0, 1, 1000)
        setTimer(function()
            setCameraMatrix(612.569, -124.545, 999.974, 613.062, -124.549, 999.104, 0, 40)
            setPlayerHudComponentVisible("radar", false)
            setPlayerHudComponentVisible("all", false)

            silnikBrowser = guiCreateBrowser(0, 0, sx, sy, true, true, false)
            addEventHandler("onClientBrowserCreated", silnikBrowser, function()
                loadBrowserURL(source, "http://mta/local/silnik.html")
            end)
        end, 1000, 1)
    elseif akcja == "wyjdz" then
        trybInterakcji = false
        showCursor(false)
    end
end)

addEvent("kameraSilnikWyjscie", true)
addEventHandler("kameraSilnikWyjscie", root, function()
    if isElement(silnikBrowser) then destroyElement(silnikBrowser) end
    
    setCameraTarget(localPlayer)
    setPlayerHudComponentVisible("radar", true)
    setPlayerHudComponentVisible("all", true)
    
    showCursor(false)
    trybInterakcji = false
end)

local widoki = {
    { name = "Silnik",    cam = {612.569, -124.545, 999.974, 613.062, -124.549, 999.104, 0, 40}, html = "silnik.html" },
    
    { name = "Lewy bok",  cam = {615.5, -127.5, 998.5, 615.5, -124.5, 997.5, 0, 80}, html = "lewy_bok.html" },
    
    { name = "Tył",       cam = {618.5, -124.5, 998, 615.5, -124.5, 997.0, 0, 105}, html = "tyl.html" },
    
    { name = "Prawy bok", cam = {615.5, -121.5, 998.5, 615.5, -124.5, 997.5, 0, 80}, html = "prawy_bok.html" }
}

local aktualnyWidok = 1

function zmienWidok(direction)
    if not isElement(silnikBrowser) or isElement(minigraBrowser) then return end
    
    aktualnyWidok = aktualnyWidok + direction
    if aktualnyWidok > #widoki then aktualnyWidok = 1 end
    if aktualnyWidok < 1 then aktualnyWidok = #widoki end
    
    local v = widoki[aktualnyWidok]
    setCameraMatrix(unpack(v.cam))
    
    destroyElement(silnikBrowser)
    
    silnikBrowser = guiCreateBrowser(0, 0, sx, sy, true, true, false)
    addEventHandler("onClientBrowserCreated", silnikBrowser, function()
        loadBrowserURL(source, "http://mta/local/" .. v.html)
    end)
    
    outputChatBox("#533b70[MECHANIK]#ffffff Zmieniono stanowisko: " .. v.name, 255, 255, 255, true)
end

bindKey("arrow_l", "down", function() zmienWidok(-1) end)
bindKey("arrow_r", "down", function() zmienWidok(1) end)


addEventHandler("onClientMarkerHit", jobMarkerEntry, function(hitElement, matchingDimension)
    if hitElement == localPlayer and matchingDimension then
        setElementInterior(localPlayer, 3, 620.19, -121.63, 998.85)
        poprzedniSkin = getElementModel(localPlayer)
        setElementModel(localPlayer, 50)

        if zlecenieAktywne and zakupyZrobione then
            triggerServerEvent("zakonczWyjazdHurtownia", localPlayer)
            zlecenieAktywne = false
            etapNaprawy = true
            if isElement(currentBlip) then destroyElement(currentBlip) end
            outputChatBox("#533b70[MECHANIK]#ffffff Przywiozłeś części! Podejdź do tablicy sprawdzić status i użyj X na aucie.", 255, 255, 255, true)
        end
    end
end)

addEventHandler("onClientMarkerHit", jobMarkerExit, function(hitElement, matchingDimension)
    if hitElement == localPlayer and matchingDimension then
        setElementInterior(localPlayer, 0, 305.0, -226.63, 1.58) 
        if poprzedniSkin ~= nil then
            setElementModel(localPlayer, poprzedniSkin)
        end
    end
end)

addEventHandler("onClientMarkerHit", tablicaMarker, function(hitElement, matchingDimension)
    if hitElement == localPlayer and matchingDimension then
        if isElement(przegladarkaTablicy) then return end
        showCursor(true)

        if etapNaprawy then
            przegladarkaTablicy = guiCreateBrowser(0, 0, sx, sy, true, true, false)
            addEventHandler("onClientBrowserCreated", przegladarkaTablicy, function()
                loadBrowserURL(source, "http://mta/local/postep.html")
            end)
            addEventHandler("onClientBrowserDocumentReady", przegladarkaTablicy, function()
                local usterkiHTML = ""
                for _, usterka in ipairs(aktualneZlecenie) do
                    local icon = statusCzesci[usterka] and "<span style='color:#00ff66'>✔</span>" or "<span style='color:#ff4d4d'>✖</span>"
                    usterkiHTML = usterkiHTML .. "<div class='part-item'>" .. usterka .. " <span class='status-icon'>" .. icon .. "</span></div>"
                end
                local gotowyHTML = usterkiHTML:gsub("\n", ""):gsub("'", "\\'")
                executeBrowserJavascript(source, "document.getElementById('parts-list').innerHTML = '" .. gotowyHTML .. "';")
            end)
        else
            generujNoweZlecenie()
            przegladarkaTablicy = guiCreateBrowser(0, 0, sx, sy, true, true, false)
            addEventHandler("onClientBrowserCreated", przegladarkaTablicy, function()
                loadBrowserURL(source, "http://mta/local/tablica.html")
            end)
            addEventHandler("onClientBrowserDocumentReady", przegladarkaTablicy, function()
                local usterkiHTML = ""
                for _, usterka in ipairs(aktualneZlecenie) do
                    usterkiHTML = usterkiHTML .. "<div class='part-item'>- " .. usterka .. "</div>"
                end
                local gotowyHTML = usterkiHTML:gsub("\n", ""):gsub("'", "\\'")
                executeBrowserJavascript(source, "document.getElementById('parts-list').innerHTML = '" .. gotowyHTML .. "';")
            end)
        end
    end
end)

addEventHandler("onClientMarkerLeave", tablicaMarker, function(leaveElement)
    if leaveElement == localPlayer then
        if isElement(przegladarkaTablicy) then
            destroyElement(przegladarkaTablicy)
            przegladarkaTablicy = nil
            showCursor(false)
        end
    end
end)

addEvent("zamknijTabliceHTML", true)
addEventHandler("zamknijTabliceHTML", root, function()
    if isElement(przegladarkaTablicy) then
        destroyElement(przegladarkaTablicy)
        przegladarkaTablicy = nil
        showCursor(false)
    end
end)

addEvent("akcjaHurtownia", true)
addEventHandler("akcjaHurtownia", root, function()
    zlecenieAktywne = true
    triggerServerEvent("startWyjazdHurtownia", localPlayer)
    if isElement(przegladarkaTablicy) then
        destroyElement(przegladarkaTablicy)
        przegladarkaTablicy = nil
        showCursor(false)
    end
end)

addEvent("startHurtowniaRoute", true)
addEventHandler("startHurtowniaRoute", root, function()
    if isElement(currentBlip) then destroyElement(currentBlip) end
    if isElement(strefaHurtowni) then destroyElement(strefaHurtowni) end
    currentBlip = createBlip(hurtowniaX, hurtowniaY, hurtowniaZ, 41)
    strefaHurtowni = createMarker(hurtowniaX, hurtowniaY, hurtowniaZ, "cylinder", 15, 255, 0, 0, 0)
end)

addEventHandler("onClientMarkerHit", root, function(hitElement, matchingDimension)
    if hitElement == localPlayer and matchingDimension then
        if source == strefaHurtowni then
            destroyElement(strefaHurtowni)
            if isElement(currentBlip) then destroyElement(currentBlip) end
            
            outputChatBox("#533b70[MECHANIK]#ffffff Dojechałeś do hurtowni! Wejdź do środka (marker przed tobą).", 255, 255, 255, true)
            
            if isElement(wejscieHurtowni) then destroyElement(wejscieHurtowni) end
            wejscieHurtowni = createMarker(hurtowniaX, hurtowniaY, hurtowniaZ - 1, "cylinder", 1.5, 124, 111, 191, 50)
            currentBlip = createBlip(hurtowniaX, hurtowniaY, hurtowniaZ, 27)
        
        elseif source == wejscieHurtowni then
            setElementInterior(localPlayer, 18, -31.07, -89.00, 1003.55)
            if isElement(wyjscieZeSklepu) then destroyElement(wyjscieZeSklepu) end
            if isElement(kasaSklepowa) then destroyElement(kasaSklepowa) end
            
            wyjscieZeSklepu = createMarker(-31.07, -91.69, 1002.50, "cylinder", 1.5, 124, 111, 191, 50)
            setElementInterior(wyjscieZeSklepu, 18)
            setElementDimension(wyjscieZeSklepu, getElementDimension(localPlayer))
            
            kasaSklepowa = createMarker(-27.03, -89.93, 1002.50, "cylinder", 1.5, 255, 215, 0, 50)
            setElementInterior(kasaSklepowa, 18)
            setElementDimension(kasaSklepowa, getElementDimension(localPlayer))
            
            outputChatBox("#533b70[MECHANIK]#ffffff Podejdź do kasy (złoty marker), aby odebrać zamówienie.", 255, 255, 255, true)

        elseif source == wyjscieZeSklepu then
            setElementInterior(localPlayer, 0, hurtowniaX, hurtowniaY, hurtowniaZ)
        
        elseif source == kasaSklepowa then
            if zakupyZrobione then
                outputChatBox("#533b70[MECHANIK]#ffffff Już odebrałeś części! Wracaj do warsztatu.", 255, 255, 255, true)
                return
            end
            if isElement(sklepBrowser) then return end
            
            showCursor(true)
            sklepBrowser = guiCreateBrowser(0, 0, sx, sy, true, true, false)
            
            addEventHandler("onClientBrowserCreated", sklepBrowser, function()
                loadBrowserURL(source, "http://mta/local/sklep.html")
            end)

            addEventHandler("onClientBrowserDocumentReady", sklepBrowser, function()
                local html = ""
                for _, part in ipairs(mozliweUsterki) do
                    html = html .. "<label class='checkbox-label'><input type='checkbox' value='"..part.."'>"..part.."</label>"
                end
                executeBrowserJavascript(source, "document.getElementById('parts-list').innerHTML = \"" .. html .. "\";")
            end)
        end
    end
end)

addEvent("zamknijSklepHTML", true)
addEventHandler("zamknijSklepHTML", root, function()
    if isElement(sklepBrowser) then
        destroyElement(sklepBrowser)
        sklepBrowser = nil
        showCursor(false)
    end
end)

addEvent("weryfikujZakupy", true)
addEventHandler("weryfikujZakupy", root, function(zaznaczone)
    local zaznaczoneTabela = split(zaznaczone, ",")
    
    if #zaznaczoneTabela ~= #aktualneZlecenie then
        outputChatBox("#ff0000[BŁĄD]#ffffff Zaznaczyłeś błędną ilość części!", 255, 255, 255, true)
        return
    end
    
    local poprawne = 0
    for _, wymog in ipairs(aktualneZlecenie) do
        for _, zazn in ipairs(zaznaczoneTabela) do
            if wymog == zazn then
                poprawne = poprawne + 1
                break
            end
        end
    end
    
    if poprawne == #aktualneZlecenie then
        zakupyZrobione = true
        outputChatBox("#00ff00[SUKCES]#ffffff Odebrałeś odpowiednie części! Wracaj do warsztatu.", 255, 255, 255, true)
        triggerEvent("zamknijSklepHTML", localPlayer)
        
        if isElement(currentBlip) then destroyElement(currentBlip) end
        currentBlip = createBlip(303.32, -226.63, 0.58, 41)
        
        if isElement(wejscieHurtowni) then destroyElement(wejscieHurtowni) end
    else
        outputChatBox("#ff0000[BŁĄD]#ffffff To nie są części z Twojej listy! Sprawdź pod 'Z'.", 255, 255, 255, true)
    end
end)

function toggleListaCzesci()
    if not zlecenieAktywne and not etapNaprawy then return end
    if getElementInterior(localPlayer) ~= 0 and getElementInterior(localPlayer) ~= 18 then return end

    if isElement(hudCzesciBrowser) then
        destroyElement(hudCzesciBrowser)
        hudCzesciBrowser = nil
    else
        local w, h = 300, 400
        local x, y = sx - w - 20, sy - h - 20
        
        hudCzesciBrowser = guiCreateBrowser(x, y, w, h, true, true, false)
        
        addEventHandler("onClientBrowserCreated", hudCzesciBrowser, function()
            loadBrowserURL(source, "http://mta/local/lista.html")
        end)

        addEventHandler("onClientBrowserDocumentReady", hudCzesciBrowser, function()
            local htmlCzesci = ""
            for _, usterka in ipairs(aktualneZlecenie) do
                htmlCzesci = htmlCzesci .. "<div class='hud-item'>" .. usterka .. "</div>"
            end
            
            local gotowyHTML = htmlCzesci:gsub("\n", ""):gsub("'", "\\'")
            local naglowekText = zakupyZrobione and "Części kupione i gotowe:" or "Części do odebrania:"
            
            executeBrowserJavascript(source, "document.getElementById('hud-parts-list').innerHTML = '" .. gotowyHTML .. "';")
            executeBrowserJavascript(source, "document.querySelector('.description').innerText = '" .. naglowekText .. "';")
        end)
    end
end
bindKey("z", "down", toggleListaCzesci)

addEvent("zamknijMinigre", true)
addEventHandler("zamknijMinigre", root, function()
    if isElement(minigraBrowser) then 
        destroyElement(minigraBrowser) 
        minigraBrowser = nil
    end
    
    if isElement(silnikBrowser) then 
        destroyElement(silnikBrowser) 
    end
    
    silnikBrowser = guiCreateBrowser(0, 0, sx, sy, true, true, false)
    addEventHandler("onClientBrowserCreated", silnikBrowser, function()
        local v = widoki[aktualnyWidok]
        loadBrowserURL(source, "http://mta/local/" .. v.html)
    end)
end)


addEvent("odpalMinigreAkumulator", true)
addEventHandler("odpalMinigreAkumulator", root, function()
    if isElement(minigraBrowser) then return end
    
    local maUsterke = false
    for _, u in ipairs(aktualneZlecenie) do if u == "Akumulator" then maUsterke = true end end
    if not etapNaprawy or not maUsterke or statusCzesci["Akumulator"] then return end

    if isElement(silnikBrowser) then destroyElement(silnikBrowser) end
    minigraBrowser = guiCreateBrowser(0, 0, sx, sy, true, true, false)
    addEventHandler("onClientBrowserCreated", minigraBrowser, function()
        loadBrowserURL(source, "http://mta/local/akumulator.html")
    end)
end)

addEvent("odpalMinigreFiltrP", true)
addEventHandler("odpalMinigreFiltrP", root, function()
    if isElement(minigraBrowser) then return end
    
    local maUsterke = false
    for _, u in ipairs(aktualneZlecenie) do if u == "Filtr powietrza" then maUsterke = true end end
    if not etapNaprawy or not maUsterke or statusCzesci["Filtr powietrza"] then return end
    
    if isElement(silnikBrowser) then destroyElement(silnikBrowser) end
    minigraBrowser = guiCreateBrowser(0, 0, sx, sy, true, true, false)
    addEventHandler("onClientBrowserCreated", minigraBrowser, function()
        loadBrowserURL(source, "http://mta/local/filtrP.html")
    end)
end)

addEvent("odpalMinigreFiltrK", true)
addEventHandler("odpalMinigreFiltrK", root, function()
    if isElement(minigraBrowser) then return end
    
    local maUsterke = false
    for _, u in ipairs(aktualneZlecenie) do if u == "Filtr Kabinowy" then maUsterke = true end end
    if not etapNaprawy or not maUsterke or statusCzesci["Filtr Kabinowy"] then return end
    
    if isElement(silnikBrowser) then destroyElement(silnikBrowser) end
    minigraBrowser = guiCreateBrowser(0, 0, sx, sy, true, true, false)
    addEventHandler("onClientBrowserCreated", minigraBrowser, function()
        loadBrowserURL(source, "http://mta/local/filtrK.html")
    end)
end)

addEvent("odpalMinigreOlej", true)
addEventHandler("odpalMinigreOlej", root, function()
    if isElement(minigraBrowser) then return end
    
    local maUsterke = false
    for _, u in ipairs(aktualneZlecenie) do if u == "Olej silnikowy" then maUsterke = true end end
    if not etapNaprawy or not maUsterke or statusCzesci["Olej silnikowy"] then return end
    
    if isElement(silnikBrowser) then destroyElement(silnikBrowser) end
    minigraBrowser = guiCreateBrowser(0, 0, sx, sy, true, true, false)
    addEventHandler("onClientBrowserCreated", minigraBrowser, function()
        loadBrowserURL(source, "http://mta/local/olej.html")
    end)
end)

addEvent("odpalMinigrePlyn", true)
addEventHandler("odpalMinigrePlyn", root, function()
    if isElement(minigraBrowser) then return end
    
    local maUsterke = false
    for _, u in ipairs(aktualneZlecenie) do if u == "Płyn do spryskiwaczy" then maUsterke = true end end
    if not etapNaprawy or not maUsterke or statusCzesci["Płyn do spryskiwaczy"] then return end
    
    if isElement(silnikBrowser) then destroyElement(silnikBrowser) end
    minigraBrowser = guiCreateBrowser(0, 0, sx, sy, true, true, false)
    addEventHandler("onClientBrowserCreated", minigraBrowser, function()
        loadBrowserURL(source, "http://mta/local/plyn.html")
    end)
end)


addEvent("zakonczAkumulator", true)
addEventHandler("zakonczAkumulator", root, function()
    if not isElement(minigraBrowser) then return end
    statusCzesci["Akumulator"] = true
    outputChatBox("#00ff00[SUKCES]#ffffff Akumulator wymieniony!", 255, 255, 255, true)
    triggerEvent("zamknijMinigre", root)
    sprawdzKoniecZlecenia()
end)

addEvent("zakonczMinigrePlyn", true)
addEventHandler("zakonczMinigrePlyn", root, function()
    if not isElement(minigraBrowser) then return end
    statusCzesci["Płyn do spryskiwaczy"] = true 
    outputChatBox("#00ff00[SUKCES]#ffffff Płyn do spryskiwaczy został uzupełniony!", 255, 255, 255, true)
    triggerEvent("zamknijMinigre", root)
    sprawdzKoniecZlecenia()
end)

addEvent("zakonczMinigreFiltrP", true)
addEventHandler("zakonczMinigreFiltrP", root, function()
    if not isElement(minigraBrowser) then return end
    statusCzesci["Filtr powietrza"] = true
    outputChatBox("#00ff00[SUKCES]#ffffff Filtr powietrza wymieniony!", 255, 255, 255, true)
    triggerEvent("zamknijMinigre", root)
    sprawdzKoniecZlecenia()
end)

addEvent("zakonczMinigreFiltrK", true)
addEventHandler("zakonczMinigreFiltrK", root, function()
    if not isElement(minigraBrowser) then return end
    statusCzesci["Filtr Kabinowy"] = true
    outputChatBox("#00ff00[SUKCES]#ffffff Filtr kabinowy wymieniony!", 255, 255, 255, true)
    triggerEvent("zamknijMinigre", root)
    sprawdzKoniecZlecenia()
end)

addEvent("zakonczMinigreOlej", true)
addEventHandler("zakonczMinigreOlej", root, function()
    if not isElement(minigraBrowser) then return end
    statusCzesci["Olej silnikowy"] = true
    outputChatBox("#00ff00[SUKCES]#ffffff Olej silnikowy wymieniony!", 255, 255, 255, true)
    triggerEvent("zamknijMinigre", root)
    sprawdzKoniecZlecenia()
end)

addEvent("odpalMinigreKola", true)
addEventHandler("odpalMinigreKola", root, function(id)
    if isElement(minigraBrowser) then return end
    
    local maUsterke = false
    for _, u in ipairs(aktualneZlecenie) do if u == "Wymiana ogumienia" then maUsterke = true end end
    if not etapNaprawy or not maUsterke then return end

    if postepDodatkowy[id] then
        outputChatBox("#ff0000[BŁĄD]#ffffff To koło zostało już wymienione!", 255, 255, 255, true)
        return
    end

    wybraneKolo = id 
    if isElement(silnikBrowser) then destroyElement(silnikBrowser) end
    minigraBrowser = guiCreateBrowser(0, 0, sx, sy, true, true, false)
    addEventHandler("onClientBrowserCreated", minigraBrowser, function()
        loadBrowserURL(source, "http://mta/local/kola.html")
    end)
end)

addEvent("zakonczMinigreKola", true)
addEventHandler("zakonczMinigreKola", root, function()
    if not isElement(minigraBrowser) then return end
    
    postepDodatkowy[wybraneKolo] = true
    outputChatBox("#00ff00[SUKCES]#ffffff Wymieniono koło!", 255, 255, 255, true)
    
    if postepDodatkowy.koloLP and postepDodatkowy.koloPP and postepDodatkowy.koloLT and postepDodatkowy.koloPT then
        statusCzesci["Wymiana ogumienia"] = true
        outputChatBox("#00ff00[SUKCES]#ffffff Komplet opon został wymieniony!", 255, 255, 255, true)
    else
        outputChatBox("#533b70[MECHANIK]#ffffff Zostały jeszcze inne koła do wymiany.", 255, 255, 255, true)
    end
    
    triggerEvent("zamknijMinigre", root)
    sprawdzKoniecZlecenia()
end)

addEvent("odpalMinigreKlamki", true)
addEventHandler("odpalMinigreKlamki", root, function(id)
    if isElement(minigraBrowser) then return end
    
    local maUsterke = false
    for _, u in ipairs(aktualneZlecenie) do if u == "Wymiana klamek" then maUsterke = true end end
    if not etapNaprawy or not maUsterke then return end

    if postepDodatkowy[id] then
        outputChatBox("#ff0000[BŁĄD]#ffffff Ta klamka została już wymieniona!", 255, 255, 255, true)
        return
    end

    wybranaKlamka = id
    if isElement(silnikBrowser) then destroyElement(silnikBrowser) end
    minigraBrowser = guiCreateBrowser(0, 0, sx, sy, true, true, false)
    addEventHandler("onClientBrowserCreated", minigraBrowser, function()
        loadBrowserURL(source, "http://mta/local/klamki.html")
    end)
end)

addEvent("zakonczMinigreKlamki", true)
addEventHandler("zakonczMinigreKlamki", root, function()
    if not isElement(minigraBrowser) then return end
    
    postepDodatkowy[wybranaKlamka] = true
    outputChatBox("#00ff00[SUKCES]#ffffff Wymieniono klamkę!", 255, 255, 255, true)
    
    if postepDodatkowy.klamkaL and postepDodatkowy.klamkaP then
        statusCzesci["Wymiana klamek"] = true
        outputChatBox("#00ff00[SUKCES]#ffffff Obie klamki zostały wymienione!", 255, 255, 255, true)
    else
        outputChatBox("#533b70[MECHANIK]#ffffff Została jeszcze druga klamka do wymiany.", 255, 255, 255, true)
    end
    
    triggerEvent("zamknijMinigre", root)
    sprawdzKoniecZlecenia()
end)

addEvent("odpalMinigreZamek", true)
addEventHandler("odpalMinigreZamek", root, function()
    if isElement(minigraBrowser) then return end
    
    local maUsterke = false
    for _, u in ipairs(aktualneZlecenie) do if u == "Wymiana zamka od bagażnika" then maUsterke = true end end
    if not etapNaprawy or not maUsterke or statusCzesci["Wymiana zamka od bagażnika"] then return end

    if isElement(silnikBrowser) then destroyElement(silnikBrowser) end
    minigraBrowser = guiCreateBrowser(0, 0, sx, sy, true, true, false)
    addEventHandler("onClientBrowserCreated", minigraBrowser, function()
        loadBrowserURL(source, "http://mta/local/zamek.html")
    end)
end)

addEvent("zakonczMinigreZamek", true)
addEventHandler("zakonczMinigreZamek", root, function()
    if not isElement(minigraBrowser) then return end
    
    statusCzesci["Wymiana zamka od bagażnika"] = true
    outputChatBox("#00ff00[SUKCES]#ffffff Wymieniono zamek w bagażniku!", 255, 255, 255, true)
    
    triggerEvent("zamknijMinigre", root)
    sprawdzKoniecZlecenia()
end)

addCommandHandler("testmechanik", function()
    aktualneZlecenie = {
        "Olej silnikowy", "Filtr Kabinowy", "Filtr powietrza", "Akumulator", 
        "Płyn do spryskiwaczy", "Wymiana ogumienia", "Wymiana klamek", "Wymiana zamka od bagażnika"
    }
    
    statusCzesci = {}
    for _, u in ipairs(aktualneZlecenie) do 
        statusCzesci[u] = false 
    end

    postepDodatkowy = {
        koloLP = false, koloPP = false, koloLT = false, koloPT = false,
        klamkaL = false, klamkaP = false
    }

    zakupyZrobione = true
    etapNaprawy = true
    zlecenieAktywne = false

    outputChatBox("#00ff66[DEV-MODE]#ffffff Tryb testowy włączony! Masz wszystkie części i odblokowane auto.", 255, 255, 255, true)
end)