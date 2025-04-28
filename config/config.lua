SDC = {}

---------------------------------------------------------------------------------
-------------------------------Important Configs---------------------------------
---------------------------------------------------------------------------------

SDC.AllowedJobs = { --All Jobs Allowed To Use Area Shutdown
    --EX: ["job_name"] = {BlipColor = 1, MaxAreaSize = 200}, --BlipColor = Color Of The Job's Blip, find colors on fivem docs | MaxAreaSize = The Max size they can set for the shutdown

    ["police"] = {BlipColor = 3, MaxAreaSize = 200, Label = "Police"},
    ["ambulance"] = {BlipColor = 6, MaxAreaSize = 150, Label = "EMS"},
    ["firefighter"] = {BlipColor = 1, MaxAreaSize = 200, Label = "LSFD"},
}

SDC.MenuCommand = {
    CommandName = "sdas:openmenu", --Command name to open menu when keybind is DISABLED
    Keybind = { --To enable keybind below set enabled to true and put the key you want the menu to open to (If enabled the command will not be the same as above)
        Enabled = true, --If you want the keybind to be enabled
        Key = "O" --Key For Menu To Open
    }
}

---------------------------------------------------------------------------------
-------------------------------Blip Configs--------------------------------------
---------------------------------------------------------------------------------
SDC.MarkerBlip = 163 --Blip on the inside of the circle for area shutdown
SDC.MarkerIsShortRange = false --If you want the blip to show only short range
SDC.AreaBlipColor = 5 --The circle around the blip's color

---------------------------------------------------------------------------------
--------------------------Blacklisted Vehicles Configs---------------------------
---------------------------------------------------------------------------------

SDC.BlacklistedVehicleClasses = { --Blacklisted vehicles for the area shutdown (DONT TOUCH UNLESS YOU KNOW WHAT YOURE DOING)
    ["1"] = false,
    ["2"] = false,
    ["3"] = false,
    ["4"] = false,
    ["5"] = false,
    ["6"] = false,
    ["7"] = false,
    ["8"] = false,
    ["9"] = false,
    ["10"] = false,
    ["11"] = false,
    ["12"] = false,
    ["13"] = false,
    ["14"] = true,
    ["15"] = true,
    ["16"] = true,
    ["17"] = false,
    ["18"] = false,
    ["19"] = true,
    ["20"] = false,
    ["21"] = false,
    ["22"] = false,
}