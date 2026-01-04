addEventHandler('onPlayerJoin', root, function ()
    triggerClientEvent(source, 'login-menu:open', source)
end)