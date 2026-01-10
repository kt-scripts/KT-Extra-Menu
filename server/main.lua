local resourceName = GetCurrentResourceName()

RegisterNetEvent('vehicle_customizer:log', function(action, data)
    local source = source
    local identifier = nil
    
    if Config.Framework == 'esx' then
        local ESX = exports['es_extended']:getSharedObject()
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            identifier = xPlayer.identifier
        end
    elseif Config.Framework == 'qbcore' or Config.Framework == 'qbox' then
        local QBCore = exports['qb-core']:GetCoreObject()
        local Player = QBCore.Functions.GetPlayer(source)
        if Player then
            identifier = Player.PlayerData.citizenid
        end
    end
    
    print(string.format('[' .. resourceName .. '] Player: %s | Action: %s | Data: %s', 
        identifier or source, 
        action, 
        json.encode(data)
    ))
end)