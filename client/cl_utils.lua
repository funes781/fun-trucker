function AddTargetZone(name, coords, size, heading, icon, label, onSelect, distance)
    local zoneOptions = {
        coords = coords,
        size = size,
        rotation = heading,
        debug = Config.TargetDebugMode,
        drawSprite = Config.DrawTargetSprite,
        options = { {
            name = name,
            icon = icon,
            label = label,
            onSelect = onSelect,
            distance = distance or Config.TargetDefaultDistance,
        }},
    }
    local zone = exports.ox_target:addBoxZone(zoneOptions)
end

function CreateBlip(pos, sprite, color, size, label)
    local blip = AddBlipForCoord(pos.x, pos.y, pos.z)

    SetBlipSprite(blip, sprite)
    SetBlipColour(blip, color)
    SetBlipScale(blip, size)

    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(label)
    EndTextCommandSetBlipName(blip)
end

function spawnPed(model, pos)
    local ped = CreatePed(4, model, pos.x, pos.y, pos.z-1, pos.w, false, false)
    SetBlockingOfNonTemporaryEvents(ped, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
end

function CreateVehicle(model, spawn)
    ESX.Game.SpawnVehicle(model, vector3(spawn.pos[1], spawn.pos[2], spawn.pos[3]), spawn.pos[4], function(vehicle)
        if DoesEntityExist(vehicle) then
            return vehicle
        end
    end)
end

function CreateTrailer(model, spawn)
    ESX.Game.SpawnVehicle(model, vector3(spawn.pos[1], spawn.pos[2], spawn.pos[3]), spawn.pos[4], function(trailer)
        if DoesEntityExist(trailer) then
            return trailer
        end
    end)
end

function Notify(title, message, type)
    if Config.Notifications == "ox_lib" then
        if type == "success" then
            lib.notify({
                title = title,
                description = message,
                type = 'success',
                duration = 5000,
            })
        elseif type == "error" then
            lib.notify({
                title = title,
                description = message,
                type = 'error',
                duration = 5000,
            })
        elseif type == "info" then
            lib.notify({
                title = title,
                description = message,
                type = 'inform',
                duration = 5000,
            })
        end
    elseif Config.Notifications == "okokNotify" then
        if type == "success" then
            exports['okokNotify']:Alert(title, message, 5000, 'success')
        elseif type == "error" then
            exports['okokNotify']:Alert(title, message, 5000, 'error')
        elseif type == "info" then
            exports['okokNotify']:Alert(title, message, 5000, 'info')
        end
    elseif Config.Notifications == "esx" then
        ESX.ShowHelpNotification(message, false, false, -1)
    elseif Config.Notifications == "custom" then
        print('ADD CUSTOM NOTIFICATIONS')
    end
end

function loadAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Citizen.Wait(50)
    end
end

function loadModel(model)
    if type(model) == 'number' then
        model = model
    else
        model = GetHashKey(model)
    end
    while not HasModelLoaded(model) do
        RequestModel(model)
        Citizen.Wait(0)
    end
end