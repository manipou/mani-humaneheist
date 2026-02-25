local Open = {}

function Open.Dispatch()
    local PlayerPed = cache.ped
    local DispatchCoords = vec3(3539.90, 3739.68, 35.68)
    exports['tk_dispatch']:addCall({
        title = 'Humane Labs Indbrud',
        code = 'Alarm',
        priority = 'Priority 3',
        coords = DispatchCoords,
        message = 'Alarm er gået igang hos Humane Labs!',
        showLocation = true,
        showDirection = false,
        showGender = false,
        showVehicle = false,
        showWeapon = false,
        showPerson = false,
        showNumber = false,
        color = 'red',
        flash = true,
        playSound = true,
        removeTime = 1000 * 60 * 10, -- will be removed after 10 minutes
        showTime = 10000, -- will be shown on screen (as notification) for 10 seconds
        blip = {
            color = 1,
            sprite = 499,
            scale = 1.0,
        },
        jobs = { 'police' }
    })
end

return Open