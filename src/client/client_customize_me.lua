function GetCurrentJob()
    return exports["SDC_Core"]:GetCurrentJob()
end

RegisterNetEvent("SDAS:Client:Notification")
AddEventHandler("SDAS:Client:Notification", function(msg, extra)
    exports["SDC_Core"]:ShowNotification(msg, extra)
end)