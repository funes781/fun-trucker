ESX = exports['es_extended']:getSharedObject()

local LockedTrailersSpawns = {}

local playerRandomNumbers = {} -- antycheat

ESX.RegisterServerCallback('fun-transport:server:getRandomNumber', function(source, cb)
    local randomNumber = math.random(111111, 999999)
    local xPlayer = ESX.GetPlayerFromId(source)
    playerRandomNumbers[xPlayer.identifier] = randomNumber
    cb(randomNumber)
end)

ESX.RegisterServerCallback('fun-transport:server:getLockedPositions', function(source, cb, trailerIndex)
    if trailerIndex then
        local found = false
        for _, entry in ipairs(LockedTrailersSpawns) do
            if entry.index == trailerIndex then
                found = true
                break
            end
        end
        if found then
            cb(true)
        else
            cb(false)
        end
    end
end)

RegisterServerEvent("fun-transport:server:startTask")
AddEventHandler("fun-transport:server:startTask", function()
    local src = source 
    if src then
        TriggerClientEvent("fun-transport:client:startTask", src)
    end
end)

RegisterServerEvent("fun-transport:server:lockpos")
AddEventHandler("fun-transport:server:lockpos", function(index)
    local src = source
    if src then
        table.insert(LockedTrailersSpawns, { source = src, index = index })
    end
end)

RegisterServerEvent('fun-transport:server:reward')
AddEventHandler('fun-transport:server:reward', function(receivedNumber)
    local xPlayer = ESX.GetPlayerFromId(source)
    local storedNumber = playerRandomNumbers[xPlayer.identifier]

    if storedNumber and storedNumber == receivedNumber then
        if xPlayer then
            xPlayer.addInventoryItem(Config.RewardItem, math.random(Config.RewardCount.min, Config.RewardCount.max))
            playerRandomNumbers[xPlayer.identifier] = nil
        else
            playerRandomNumbers[xPlayer.identifier] = nil
        end
    else
        print("Number mismatch or no stored number")
    end
end)

AddEventHandler('playerDropped', function(reason)
    local src = source
    for i, entry in ipairs(LockedTrailersSpawns) do
        if entry.source == src then
            table.remove(LockedTrailersSpawns, i)
            break
        end
    end
end)