ESX = exports['es_extended']:getSharedObject()

local HasTask = false
local trailer

Citizen.CreateThread(function()
    for i, blipData in ipairs(C.Blips) do
        CreateBlip(blipData.pos, blipData.sprite, blipData.color, blipData.size, blipData.label)
    end

    loadModel(C.Ped.model)
    spawnPed(C.Ped.model, C.Ped.pos)
    AddTargetZone("fun-transport:target:taketask", vec3(C.Ped.pos.x, C.Ped.pos.y, C.Ped.pos.z), C.Ped.target.size, C.Ped.pos.w, C.Ped.target.icon, C.Ped.target.label, function()
        StartJob()
    end, C.Ped.target.distance)
end)

function StartJob()
    if not HasTask then
        local spawnFound = false
        for i, spawn in ipairs(C.Garage.spawns) do
            if ESX.Game.IsSpawnPointClear(vector3(spawn.pos[1], spawn.pos[2], spawn.pos[3]), 2) then
                CreateVehicle(C.Garage.models[math.random(1, #C.Garage.models)], spawn)
                Notify(S.info, S.vehicle_spawned, "success")
                spawnFound = true
                TriggerServerEvent("fun-transport:server:startTask")
                break
            end
        end
        if not spawnFound then
            Notify(S.info, S.cant_spawn_vehicle, "error")
        end
    end
end

RegisterNetEvent("fun-transport:client:startTask")
AddEventHandler("fun-transport:client:startTask", function()
    startTask()
end)

function startTask()
    local notified = false
    local notified2 = false
    local spawned = false
    local trailerPosIndex = math.random(1, #Config.Trailers.Locations)
    local trailerPos = Config.Trailers.Locations[trailerPosIndex]
    local trailerModel = Config.Trailers.Models[math.random(1, #Config.Trailers.Models)]
    local Task = C.Delivery[math.random(1, #C.Delivery)]

    ESX.TriggerServerCallback('fun-transport:server:getLockedPositions', function(status)
        if not status then
            TriggerServerEvent("fun-transport:server:lockpos", trailerPosIndex)
            SetNewWaypoint(trailerPos.pos[1], trailerPos.pos[2])
            Citizen.CreateThread(function()
                while true do 
                    Citizen.Wait(0)
                    local ped = PlayerPedId()
                    local pedCo = GetEntityCoords(ped)
                    local dist = #(pedCo - vec3(trailerPos.pos[1], trailerPos.pos[2], trailerPos.pos[3]))
                    if dist <= 90.0 then
                        if not spawned then
                            if ESX.Game.IsSpawnPointClear(vector3(trailerPos.pos[1], trailerPos.pos[2], trailerPos.pos[3]), 2) then
                                loadModel(trailerModel)
                                trailer = CreateTrailer(trailerModel, trailerPos)
                                Notify(S.info, S.connect_to_trailer, "info")
                                spawned = true
                            end
                        end
                    end
                    if spawned then
                        if IsPedInAnyVehicle(ped, false) then
                            local vehicle = GetVehiclePedIsIn(ped, false)
                            local isTrailerAttached, attachedTrailer = GetVehicleTrailerVehicle(vehicle)
                            if isTrailerAttached then
                                if not notified then
                                    Notify(S.info, S.deliver_trailer_to_point, "info")
                                    notified = true
                                end
                                SetNewWaypoint(Task.pos[1], Task.pos[2])
                                local taskDist = #(pedCo - vec3(Task.pos[1], Task.pos[2], Task.pos[3]))
                                local trailerDist = #(GetEntityCoords(attachedTrailer) - vec3(Task.pos[1], Task.pos[2], Task.pos[3]))
                                if taskDist <= 90.0 then
                                    DrawMarker(0, Task.pos[1], Task.pos[2], Task.pos[3], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, 0, 0, 200, false, true, 2, nil, nil, false)
                                    if trailerDist <= 5.0 then
                                        if not notified2 then
                                            Notify(S.info, S.task_complete, "info")
                                            notified2 = true
                                        end
                                        if IsControlJustPressed(0, 38) then
                                            DeleteEntity(attachedTrailer)
                                            DeleteEntity(trailer)
                                            SetEntityAsNoLongerNeeded(trailer)
                                            ESX.TriggerServerCallback('fun-transport:server:getRandomNumber', function(randomNumber)
                                                if randomNumber then
                                                    TriggerServerEvent("fun-transport:server:reward", randomNumber)
                                                else
                                                    print("ERR randomNumber generate")
                                                end
                                            end)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        else
            startTask()
        end
    end, trailerPosIndex)
end
