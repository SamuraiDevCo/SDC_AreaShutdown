local areas = {}

RegisterServerEvent("SDAS:Server:GrabAreas")
AddEventHandler("SDAS:Server:GrabAreas", function()
    local src = source

    TriggerClientEvent("SDAS:Client:UpdateAreas", src, areas)
end)


RegisterServerEvent("SDAS:Server:CreateNewArea")
AddEventHandler("SDAS:Server:CreateNewArea", function(coords, size)
    local src = source
    local theirJob = nil
    theirJob = GetPlayerJob(src)

    if theirJob and SDC.AllowedJobs[theirJob] then
        table.insert(areas, {Coords = coords, AreaSize = size, BlipColor = SDC.AllowedJobs[theirJob].BlipColor, Job = SDC.AllowedJobs[theirJob].Label, Creator = (GetPlayerJobGradeName(src).." "..GetPlayerFullName(src))})
        TriggerClientEvent("SDAS:Client:UpdateAreas", -1, areas, coords)
    else
        TriggerClientEvent("SDAS:Client:Notification", src, SDC.Lang.YouLackPermission, "error")
    end
end)

RegisterServerEvent("SDAS:Server:EditArea")
AddEventHandler("SDAS:Server:EditArea", function(coords, size)
    local src = source
    local theirJob = nil
    theirJob = GetPlayerJob(src)

    if theirJob and SDC.AllowedJobs[theirJob] then
        local found = nil
        for i=1, #areas do
            if areas[i].Coords == coords then
                found = i
            end
        end

        areas[found].AreaSize = size
        TriggerClientEvent("SDAS:Client:UpdateAreas", -1, areas, coords, size)
    else
        TriggerClientEvent("SDAS:Client:Notification", src, SDC.Lang.YouLackPermission, "error")
    end
end)

RegisterServerEvent("SDAS:Server:RemoveArea")
AddEventHandler("SDAS:Server:RemoveArea", function(coords)
    local src = source
    local theirJob = nil
    theirJob = GetPlayerJob(src)

    if theirJob and SDC.AllowedJobs[theirJob] then
        local found = nil
        for i=1, #areas do
            if areas[i].Coords == coords then
                found = i
            end
        end
        table.remove(areas, found)
        TriggerClientEvent("SDAS:Client:UpdateAreas", -1, areas, coords)
    else
        TriggerClientEvent("SDAS:Client:Notification", src, SDC.Lang.YouLackPermission, "error")
    end
end)