ESX = exports["es_extended"]:getSharedObject()

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    print('The resource ' .. resourceName .. ' has been started.')
    print('    ^2Pekeee-Sistemadehoras ha iniciado correctamente')
    print('=====^1 ESTE ES UN SCRIPT GRATUITO ^0=====')
    print('=====^2 VISITA PEKEEESHOP.COM PARA MAS ^0=====')
end)

-- Callback to get player hours information
ESX.RegisterServerCallback("pekehoras:obtenerinfo", function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer then
        exports.oxmysql:execute('SELECT horas FROM users WHERE identifier = ?', { xPlayer.identifier }, function(result)
            if result[1] and result[1].horas ~= nil then
                local data = {
                    playerName = xPlayer.getName(),
                    playerHoras = result[1].horas,
                }
                cb(data)
            else
                print("Error: Información de horas no disponible o es nula para el jugador " .. xPlayer.getName())
                cb(nil)
            end
        end)
    else
        print("No se pudo obtener el jugador con ID: " .. source)
        cb(nil)
    end
end)

-- Event to update player hours
RegisterServerEvent("pekehoras:actualizahoras")
AddEventHandler("pekehoras:actualizahoras", function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    if xPlayer then
        exports.oxmysql:execute('SELECT horas FROM users WHERE identifier = ?', { xPlayer.identifier }, function(result)
            if result[1] and result[1].horas ~= nil then
                local newHoras = result[1].horas + 1
                exports.oxmysql:execute('UPDATE users SET horas = ? WHERE identifier = ?', { newHoras, xPlayer.identifier }, function(affectedRows)
                    if affectedRows > 0 then
                        print("Horas incrementadas para el jugador " .. xPlayer.getName())
                    else
                        print("No se pudo incrementar las horas para el jugador " .. xPlayer.getName())
                    end
                end)
            else
                print("Error: Información de horas no disponible o es nula para el jugador " .. xPlayer.getName())
            end
        end)
    else
        print("No se pudo obtener el jugador con ID: " .. _source)
    end
end)

-- Callback to get player hours
ESX.RegisterServerCallback("pekehoras:obtenerhoras", function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer then
        exports.oxmysql:execute('SELECT horas FROM users WHERE identifier = ?', { xPlayer.identifier }, function(result)
            if result[1] and result[1].horas ~= nil then
                cb(result[1].horas)
            else
                print("No se encontró información de horas para el jugador " .. xPlayer.getName())
                cb(0)
            end
        end)
    else
        print("No se pudo obtener el jugador con ID: " .. source)
        cb(0)
    end
end)

-- Event to jail player if they have less than 5 hours
RegisterNetEvent("pekehoras:jailPlayer")
AddEventHandler("pekehoras:jailPlayer", function(jailTime)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    if xPlayer then
        exports.oxmysql:execute('SELECT horas FROM users WHERE identifier = ?', { xPlayer.identifier }, function(result)
            if result[1] and result[1].horas ~= nil then
                local playerHoras = result[1].horas

                if playerHoras < 5 then
                    -- Notificación al jugador
                    TriggerClientEvent('esx:showNotification', _source, 'Has sido encarcelado por no tener suficientes horas de juego. No puedes salir a zona caliente sin tener al menos 5 horas.')
                    
                    TriggerClientEvent('esx_jail:jailPlayer', _source, jailTime)
                    local jailLocation = { x = 417.94, y = -991.38, z = 29.34 }
                    TriggerClientEvent('esx:teleportPlayer', _source, jailLocation)
                    print('Player ' .. xPlayer.getName() .. ' (ID: ' .. _source .. ') has been jailed for ' .. jailTime .. ' minute(s) due to insufficient hours.')
                else
                    print('Player ' .. xPlayer.getName() .. ' (ID: ' .. _source .. ') has sufficient hours and will not be jailed.')
                end
            else
                print('Error fetching player hours for ' .. xPlayer.getName() .. ' (ID: ' .. _source .. ')')
            end
        end)
    else
        print("No se pudo obtener el jugador con ID: " .. _source)
    end
end)