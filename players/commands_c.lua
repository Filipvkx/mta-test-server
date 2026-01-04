-- czyszczenie chatu

addCommandHandler("clearchat", function()
    for i = 1, 20 do
        outputChatBox(" ")
    end   
end)

-- pokaz kordy

addCommandHandler("pos", function()
    local x, y, z = getElementPosition(localPlayer)
    outputChatBox(string.format("Twoje kordy to: X=%.2f, Y=%.2f, Z=%.2f", x, y, z), 255, 255, 0)
end)
