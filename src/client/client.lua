local loadedClient = false
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if NetworkIsSessionStarted() then
			Citizen.Wait(200)
			loadedClient = true
            TriggerServerEvent("SDAS:Server:GrabAreas")
			return -- break the loop
		end
	end
end)
-----------------------------------------------------------------------------------------

local hasJob = nil

local allAreas = {}
local blipedAreas = {}
local inmenu = nil
local nearVehs = {}

Citizen.CreateThread(function()
    while true do
        if loadedClient then
            if SDC.AllowedJobs[GetCurrentJob()] then
                hasJob = GetCurrentJob()
            else
                hasJob = nil
            end
        end
        Citizen.Wait(1000)
    end
end)
RegisterNetEvent("SDAS:Client:UpdateAreas")
AddEventHandler("SDAS:Client:UpdateAreas", function(tab, spec, edited)
    allAreas = tab

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    if edited then
        if blipedAreas[tostring(spec.x.."_"..spec.y.."_"..spec.z)] then
            RemoveBlip(blipedAreas[tostring(spec.x.."_"..spec.y.."_"..spec.z)].Circle)

            local circle = AddBlipForRadius(spec.x, spec.y, spec.z, edited+0.0)
            SetBlipColour(circle, SDC.AreaBlipColor)
            SetBlipAsShortRange(circle, true)
            SetBlipAlpha(circle, 100)

            blipedAreas[tostring(spec.x.."_"..spec.y.."_"..spec.z)].Circle = circle
        end
    end

    if inmenu and inmenu == "remove" then
        TriggerEvent("SDAS:Client:OpenRemoveMenu")
    elseif inmenu and inmenu == "edit" then
        TriggerEvent("SDAS:Client:OpenEditMenu")
    end
end)

RegisterNetEvent("SDAS:Client:OpenAreaMenu")
AddEventHandler("SDAS:Client:OpenAreaMenu", function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    if inmenu then
        lib.hideContext(true)
        inmenu = nil
    else
        inmenu = "main"
        lib.registerContext({
            id = 'sdas:mainmenu',
            title = SDC.Lang.AreaShutdown,
            onExit = function()
                inmenu = nil
            end,
            options = {
              {
                title = SDC.Lang.CreateNewArea,
                description = SDC.Lang.CreateNewArea2,
                icon = 'folder-plus',
                onSelect = function()
                    local areasClose = false
                    for i=1, #allAreas do
                        if GetDistanceBetweenCoords(allAreas[i].Coords.x, allAreas[i].Coords.y, allAreas[i].Coords.z, coords.x, coords.y, coords.z, false) <= math.ceil(allAreas[i].AreaSize/2) then
                            areasClose = true
                        end
                    end
                    if areasClose then
                        TriggerEvent("SDAS:Client:Notification", SDC.Lang.TooClose, "error")
                        lib.showContext('sdas:mainmenu')
                    else
                        local input = lib.inputDialog(SDC.Lang.SelectAreaSize, {
                            {type = 'slider', label = SDC.Lang.SelectAreaSize2, icon = 'expand', default = 25, min = 10, max = SDC.AllowedJobs[hasJob].MaxAreaSize},
                        })
    
                        if input and input[1] and tonumber(input[1]) then
                            TriggerEvent("SDAS:Client:Notification", SDC.Lang.AreaCreated, "success")
                            TriggerServerEvent("SDAS:Server:CreateNewArea", coords, tonumber(input[1]))
                            inmenu = nil
                        elseif input then
                            TriggerEvent("SDAS:Client:Notification", SDC.Lang.InvalidAreaSize, "error")
                            lib.showContext('sdas:mainmenu')
                        else
                            lib.showContext('sdas:mainmenu')
                        end
                    end
                end,
              },
              {
                title = SDC.Lang.EditArea,
                description = SDC.Lang.EditArea2,
                icon = 'file-pen',
                onSelect = function()
                    TriggerEvent("SDAS:Client:OpenEditMenu")
                end,
              },
              {
                title = SDC.Lang.RemoveArea,
                description = SDC.Lang.RemoveArea2,
                icon = 'trash-can',
                arrow = true,
                onSelect = function()
                    TriggerEvent("SDAS:Client:OpenRemoveMenu")
                end,
              }
            }
        })
         
        lib.showContext('sdas:mainmenu')
    end
end)

RegisterNetEvent("SDAS:Client:OpenEditMenu")
AddEventHandler("SDAS:Client:OpenEditMenu", function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    inmenu = "edit"

    local tabby = {}
    for i=1, #allAreas do
        local thedist = math.ceil(GetDistanceBetweenCoords(allAreas[i].Coords.x, allAreas[i].Coords.y, allAreas[i].Coords.z, coords.x, coords.y, coords.z, false))
        table.insert(tabby, {
            title = SDC.Lang.Area.." | "..allAreas[i].Job.." | "..thedist.."m "..SDC.Lang.Away,
            description = SDC.Lang.Size..": "..allAreas[i].AreaSize.."m | "..SDC.Lang.CreatedBy..": "..allAreas[i].Creator,
            icon = 'map-location',
            onSelect = function()
                local input = lib.inputDialog(SDC.Lang.SelectAreaSize, {
                    {type = 'slider', label = SDC.Lang.SelectAreaSize2, icon = 'expand', default = allAreas[i].AreaSize, min = 10, max = SDC.AllowedJobs[hasJob].MaxAreaSize},
                })

                if input and input[1] and tonumber(input[1]) then
                    TriggerEvent("SDAS:Client:Notification", SDC.Lang.AreaEdited, "success")
                    TriggerServerEvent("SDAS:Server:EditArea", allAreas[i].Coords, tonumber(input[1]))
                    inmenu = nil
                elseif input then
                    TriggerEvent("SDAS:Client:Notification", SDC.Lang.InvalidAreaSize, "error")
                    lib.showContext('sdas:editmenu')
                else
                    lib.showContext('sdas:editmenu')
                end
            end,
        })
    end

    if not tabby[1] then
        table.insert(tabby, {
            title = SDC.Lang.NoActiveAreas,
            icon = 'circle-minus',
            iconColor = "red"
        })
    end

    lib.registerContext({
        id = 'sdas:editmenu',
        title = SDC.Lang.EditArea,
        menu = "sdas:mainmenu",
        options = tabby,
        onExit = function()
            inmenu = nil
        end,
        onBack = function()
            inmenu = "main"
        end,
    })

    lib.showContext('sdas:editmenu')
end)

RegisterNetEvent("SDAS:Client:OpenRemoveMenu")
AddEventHandler("SDAS:Client:OpenRemoveMenu", function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    inmenu = "remove"

    local tabby = {}
    for i=1, #allAreas do
        local thedist = math.ceil(GetDistanceBetweenCoords(allAreas[i].Coords.x, allAreas[i].Coords.y, allAreas[i].Coords.z, coords.x, coords.y, coords.z, false))
        table.insert(tabby, {
            title = SDC.Lang.Area.." | "..allAreas[i].Job.." | "..thedist.."m "..SDC.Lang.Away,
            description = SDC.Lang.Size..": "..allAreas[i].AreaSize.."m | "..SDC.Lang.CreatedBy..": "..allAreas[i].Creator,
            icon = 'map-location',
            onSelect = function()
                TriggerServerEvent("SDAS:Server:RemoveArea", allAreas[i].Coords)
                inmenu = nil
                lib.showContext('sdas:mainmenu')
            end,
        })
    end

    if not tabby[1] then
        table.insert(tabby, {
            title = SDC.Lang.NoActiveAreas,
            icon = 'circle-minus',
            iconColor = "red"
        })
    end

    lib.registerContext({
        id = 'sdas:removemenu',
        title = SDC.Lang.RemoveArea,
        menu = "sdas:mainmenu",
        options = tabby,
        onExit = function()
            inmenu = nil
        end,
        onBack = function()
            inmenu = "main"
        end,
    })

    lib.showContext('sdas:removemenu')
end)


Citizen.CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

        if allAreas[1] then
            for i=1, #allAreas do
                if not blipedAreas[tostring(allAreas[i].Coords.x.."_"..allAreas[i].Coords.y.."_"..allAreas[i].Coords.z)] then
                    local circle = AddBlipForRadius(allAreas[i].Coords.x, allAreas[i].Coords.y, allAreas[i].Coords.z, allAreas[i].AreaSize+0.0)
                    SetBlipColour(circle, SDC.AreaBlipColor)
                    SetBlipAsShortRange(circle, true)
                    SetBlipAlpha(circle, 100)

                    local marker = AddBlipForCoord(allAreas[i].Coords.x, allAreas[i].Coords.y, allAreas[i].Coords.z)
                    SetBlipSprite(marker, SDC.MarkerBlip)
                    SetBlipScale(marker, 0.8)
                    SetBlipColour(marker, allAreas[i].BlipColor)
                    BeginTextCommandSetBlipName("STRING")
                    AddTextComponentString(SDC.Lang.AreaShutdown.." | "..allAreas[i].Job)
                    EndTextCommandSetBlipName(marker)
                    if SDC.MarkerIsShortRange then
                        SetBlipAsShortRange(marker, true)
                    end

                    blipedAreas[tostring(allAreas[i].Coords.x.."_"..allAreas[i].Coords.y.."_"..allAreas[i].Coords.z)] = {Circle = circle, Marker = marker, Coords = allAreas[i].Coords}
                end

                if GetDistanceBetweenCoords(coords.x, coords.y, coords.z, allAreas[i].Coords.x, allAreas[i].Coords.y, allAreas[i].Coords.z, false) <= 250 and nearVehs[1] then
                    for j=1, #nearVehs do
                        local vcoords = GetEntityCoords(nearVehs[j])

                        if GetDistanceBetweenCoords(allAreas[i].Coords.x, allAreas[i].Coords.y, allAreas[i].Coords.z, vcoords.x, vcoords.y, vcoords.z, false) <= allAreas[i].AreaSize and DoesEntityExist(nearVehs[j]) and not SDC.BlacklistedVehicleClasses[tostring(GetVehicleClass(nearVehs[j]))] then
                            local daped = GetPedInVehicleSeat(nearVehs[j], -1)
                            if daped ~= 0 and not IsPedAPlayer(daped) then
                                TaskVehicleTempAction(daped, nearVehs[j], 6, 2000)
                            end
                        end
                    end
                end
            end

            for k,v in pairs(blipedAreas) do
                local found = false
                for i=1, #allAreas do
                    if allAreas[i].Coords == v.Coords then
                        found = true
                    end
                end

                if not found then
                    if DoesBlipExist(v.Circle) then
                        RemoveBlip(v.Circle)
                    end
                    if DoesBlipExist(v.Marker) then
                        RemoveBlip(v.Marker)
                    end
                end
            end
        else
            for k,v in pairs(blipedAreas) do
                if DoesBlipExist(v.Circle) then
                    RemoveBlip(v.Circle)
                end
                if DoesBlipExist(v.Marker) then
                    RemoveBlip(v.Marker)
                end
            end
            blipedAreas = {}
        end
        Citizen.Wait(500)
    end
end)



Citizen.CreateThread(function()
    Citizen.Wait(2000)
    while true do
        if loadedClient then
            local nearVehs2 = {}
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            for veh in EnumerateVehicles() do
                local vcoords = GetEntityCoords(veh)
                if GetDistanceBetweenCoords(coords.x, coords.y, coords.z, vcoords.x, vcoords.y, vcoords.z, false) <= 150 then
                    table.insert(nearVehs2, veh)
                end
            end
    
            nearVehs = nearVehs2
        end
        Citizen.Wait(500)
    end
end)


if SDC.MenuCommand.Keybind.Enabled then
    RegisterKeyMapping('sdas:openmenu:'..SDC.MenuCommand.Keybind.Key, SDC.Lang.OpenAreaMenu, 'keyboard', SDC.MenuCommand.Keybind.Key)
    RegisterCommand('sdas:openmenu:'..SDC.MenuCommand.Keybind.Key, function()
        if hasJob and SDC.AllowedJobs[hasJob] then
            TriggerEvent("SDAS:Client:OpenAreaMenu")
        end
    end, false)
else
    RegisterCommand(SDC.MenuCommand.CommandName, function()
        if hasJob and SDC.AllowedJobs[hasJob] then
            TriggerEvent("SDAS:Client:OpenAreaMenu")
        else
            TriggerEvent("SDAS:Client:Notification", SDC.Lang.YouLackPermission, "error")
        end
    end, false)
end

















--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function EnumerateEntities(initFunc, moveFunc, disposeFunc)
	return coroutine.wrap(function()
		local iter, id = initFunc()
		if not id or id == 0 then
			disposeFunc(iter)
			return
		end

		local enum = {handle = iter, destructor = disposeFunc}
		setmetatable(enum, entityEnumerator)
		local next = true

		repeat
			coroutine.yield(id)
			next, id = moveFunc(iter)
		until not next

		enum.destructor, enum.handle = nil, nil
		disposeFunc(iter)
	end)
end

function EnumerateObjects()
	return EnumerateEntities(FindFirstObject, FindNextObject, EndFindObject)
end

function EnumeratePeds()
	return EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed)
end

function EnumerateVehicles()
	return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
end

function EnumeratePickups()
	return EnumerateEntities(FindFirstPickup, FindNextPickup, EndFindPickup)
end