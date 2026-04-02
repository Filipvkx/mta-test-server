local MINIMUM_PASSWORD_LENGTH = 6

local function isPasswordValid(password)
    return string.len(password) >= MINIMUM_PASSWORD_LENGTH
end

local function isPasswordRepeat(password, repeatpassword)
    return password == repeatpassword
end    

addEvent('auth:register-attempt', true)
addEventHandler('auth:register-attempt', root, function(username, password, repeatpassword)
    local player = source
    if not isPasswordRepeat(password, repeatpassword) then
        outputChatBox('Password are not the same', player, 255, 100, 100)
        return
    end
    if getAccount(username) then
        return outputChatBox('An account already exists with that name.', player, 255, 100, 100)
    end

    if not isPasswordValid(password) then
        return outputChatBox('The password supplied was not valid', player, 255, 100, 100)
    end
    passwordHash(password, 'bcrypt', {}, function (hashedPassword)
        local account = addAccount(username, hashedPassword)
        setAccountData(account, 'hashedPassword', hashedPassword)

        outputChatBox('Your account has been successfully created! You may now login with /accountLogin', player, 100, 255, 100)
    end)
end)

addEvent('auth:login-attempt', true)
addEventHandler('auth:login-attempt', root, function(username, password)
    
    local account = getAccount(username)

    if not account then
        return outputChatBox('No such account could be found with that username or password', source, 255, 100, 100)
    end

    local hashedPassword = getAccountData(account, 'hashedPassword')
    local player = source
    passwordVerify(password, hashedPassword, function (isValid)
        if not isValid then
            return outputChatBox('No such account could be found with that username or password', player, 255, 100, 100)
        end   

        if logIn(player, account, hashedPassword) then
            triggerClientEvent(player, 'login-menu:close', player)
            
            triggerClientEvent(player, 'pokazMenuSpawnu', player)
            return
        end

        return outputChatBox('An unkown error occured while attempting to authenticate.', player, 255, 100, 100)
    end)

end)

addCommandHandler('accountLogout', function(player)
    logOut(player)
end)