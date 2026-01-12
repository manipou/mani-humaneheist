local Config = lib.load('config')

local Objects, Particles, Heist = {}, {}, {}

local GasPoints = {
    { Light = vec3(3833.42, 3665.39, -22.11), Vertical = false, Pos = vec3(-0.645, -0.03, 0.90), Axis = {0.215, 0.92} },
    { Light = vec3(3833.20, 3665.51, -22.11), Vertical = false, Pos = vec3(-0.375, -0.03, 0.90), Axis = {0.355, 0.92} },
    { Light = vec3(3832.98, 3665.64, -22.11), Vertical = false, Pos = vec3(-0.125, -0.03, 0.90), Axis = {0.465, 0.92} },
    { Light = vec3(3832.76, 3665.77, -22.11), Vertical = false, Pos = vec3(0.125, -0.03, 0.90), Axis = {0.59, 0.92} },
    { Light = vec3(3832.54, 3665.90, -22.11), Vertical = false, Pos = vec3(0.375, -0.03, 0.90), Axis = {0.715, 0.92} },
    { Light = vec3(3832.32, 3666.03, -22.11), Vertical = false, Pos = vec3(0.625, -0.03, 0.90), Axis = {0.83, 0.92} },
    { Light = vec3(3833.57, 3665.35, -22.230), Vertical = true, Pos = vec3(-0.775, -0.03, 0.77), Axis = {0.145, 0.88} },
    { Light = vec3(3833.57, 3665.35, -22.489), Vertical = true, Pos = vec3(-0.775, -0.03, 0.52), Axis = {0.145, 0.74} },
    { Light = vec3(3833.57, 3665.35, -22.748), Vertical = true, Pos = vec3(-0.775, -0.03, 0.27), Axis = {0.145, 0.62} },
    { Light = vec3(3833.57, 3665.35, -23.007), Vertical = true, Pos = vec3(-0.775, -0.03, 0.02), Axis = {0.145, 0.5} },
    { Light = vec3(3833.57, 3665.35, -23.266), Vertical = true, Pos = vec3(-0.775, -0.03, -0.25), Axis = {0.145, 0.375} },
    { Light = vec3(3833.57, 3665.35, -23.525), Vertical = true, Pos = vec3(-0.775, -0.03, -0.52), Axis = {0.145, 0.24} },
    { Light = vec3(3833.57, 3665.35, -23.784), Vertical = true, Pos = vec3(-0.775, -0.03, -0.77), Axis = {0.145, 0.12} },
    { Light = vec3(3833.42, 3665.39, -23.900), Vertical = false, Pos = vec3(-0.645, -0.03, -0.90), Axis = {0.215, 0.065} },
    { Light = vec3(3833.20, 3665.51, -23.900), Vertical = false, Pos = vec3(-0.375, -0.03, -0.90), Axis = {0.355, 0.065} },
    { Light = vec3(3832.98, 3665.64, -23.900), Vertical = false, Pos = vec3(-0.125, -0.03, -0.90), Axis = {0.465, 0.065} },
    { Light = vec3(3832.76, 3665.77, -23.900), Vertical = false, Pos = vec3(0.125, -0.03, -0.90), Axis = {0.59, 0.065} },
    { Light = vec3(3832.54, 3665.90, -23.900), Vertical = false, Pos = vec3(0.375, -0.03, -0.90), Axis = {0.715, 0.065} },
    { Light = vec3(3832.32, 3666.03, -23.900), Vertical = false, Pos = vec3(0.625, -0.03, -0.90), Axis = {0.83, 0.065} },
    { Light = vec3(3832.21, 3666.14, -22.230), Vertical = true, Pos = vec3(0.775, -0.03, 0.77), Axis = {0.895, 0.88} },
    { Light = vec3(3832.21, 3666.14, -22.489), Vertical = true, Pos = vec3(0.775, -0.03, 0.52), Axis = {0.895, 0.74} },
    { Light = vec3(3832.21, 3666.14, -22.748), Vertical = true, Pos = vec3(0.775, -0.03, 0.27), Axis = {0.895, 0.62} },
    { Light = vec3(3832.21, 3666.14, -23.007), Vertical = true, Pos = vec3(0.775, -0.03, 0.02), Axis = {0.895, 0.5} },
    { Light = vec3(3832.21, 3666.14, -23.266), Vertical = true, Pos = vec3(0.775, -0.03, -0.25), Axis = {0.895, 0.375} },
    { Light = vec3(3832.21, 3666.14, -23.525), Vertical = true, Pos = vec3(0.775, -0.03, -0.52), Axis = {0.895, 0.24} },
    { Light = vec3(3832.21, 3666.14, -23.784), Vertical = true, Pos = vec3(0.775, -0.03, -0.77), Axis = {0.895, 0.12} },
}

local function AlmostEqual(v1, v2, threshold)
    return math.abs(v1 - v2) <= threshold
end

local function MinigameLoop(var1, var2)
    for i = 1, #GasPoints do
        local Point = GasPoints[i]
        if not Point.Cracked then
            DrawLightWithRange(Point.Light.x, Point.Light.y, Point.Light.z, 0, 255, 0, 0.03, 100.0)

            if AlmostEqual(var1, Point.Axis[1], 0.025) and AlmostEqual(var2, Point.Axis[2], 0.025) then
                UseParticleFxAssetNextCall('scr_fbi5a')
                local ParticleFX = StartParticleFxLoopedOnEntity('scr_bio_grille_cutting', Heist['GasTorch'], -0.344, 0.0, 0.093, 0.0, 0.0, 0.0, 1.0, false, false, false)
                Wait(2500)
                StopParticleFxLooped(ParticleFX, false)
                Point.Cracked = true
                Heist.Count = (Heist.Count or 0) + 1

                UseParticleFxAssetNextCall('scr_fbi5a')
                local Rotation = Point.Vertical and 0.0 or 90.0
                Particles[i] = StartParticleFxLoopedOnEntity('scr_bio_grille_break', Heist['GrillBit'], Point.Pos, 0.0, Rotation, 0.0, 1.2, false, false, false)

                if Heist.Count == #GasPoints then
                    Heist.GrillLoop = false
                    print('Done')
                end
            end
        end
    end
end

local function CutGrill()
    local PlayerPed = cache.ped
    local PedCoords = GetEntityCoords(PlayerPed)

    SetEntityHeading(PlayerPed, 150.0)

    SetPedResetFlag(PlayerPed, 197, true)
    SetPedCanLegIk(PlayerPed, false)
    SetPedCanHeadIk(PlayerPed, false)

    lib.requestAnimDict('mini@biotech@blowtorch_str')
    lib.requestAnimDict('mini@biotech@blowtorch_def')
    lib.requestAnimDict('missheistchem2')
    RequestNamedPtfxAsset('scr_fbi5a')
    local GasTorchHash = GetHashKey('prop_cs_gascutter_1')
    TaskMoveNetworkAdvancedByName(PlayerPed, 'minigame_BLOWTORCH', 3832.896, 3665.742, -23.9975, 0.0, 0.0, 150.0, 2, 0.0, false, 0, 0)
    ForcePedAiAndAnimationUpdate(PlayerPed, false, false)

    local GasTorch = exports['mani-bridge']:CreateObj(GasTorchHash, PedCoords)
    AttachEntityToEntity(GasTorch, PlayerPed, GetPedBoneIndex(PlayerPed, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)

    Objects[#Objects + 1] = GasTorch
    Heist['GasTorch'] = GasTorch

    local Cam = CreateCam('DEFAULT_ANIMATED_CAMERA', true)
    SetCamActive(Cam, true)
    RenderScriptCams(true, false, 3000, true, false)

    PlayCamAnim(Cam, 'cam_blowtorch_intro', 'mini@biotech@blowtorch_def', vec3(3832.8, 3665.63, -24.14), vec3(0.0, 0.0, 150.0), 0, 2)

    Wait(6000)
    RenderScriptCams(false, false, 0, 1, 0)
    DestroyCam(Cam, false)

    if IsTaskMoveNetworkReadyForTransition(PlayerPed) then
        RequestTaskMoveNetworkStateTransition(PlayerPed, 'Cutting')
        Wait(100)

        local X = 0.15
        local Y = 0.8

        Heist.GrillLoop = true

        while Heist.GrillLoop do
            if IsControlPressed(0, 31) then
                Y = Y - 0.005
            elseif IsControlPressed(0, 32) then
                Y = Y + 0.005
            elseif IsControlPressed(0, 34) then
                X = X - 0.005
            elseif IsControlPressed(0, 35) then
                X = X + 0.005
            end

            X = math.max(0.0, math.min(1.0, X))
            Y = math.max(0.0, math.min(1.0, Y))

            Citizen.InvokeNative(0xD5BB4025AE449A4E, PlayerPed, 'x_axis', X)
            Citizen.InvokeNative(0xD5BB4025AE449A4E, PlayerPed, 'y_axis', Y)
            MinigameLoop(X, Y)
            
            Wait(1)
        end

        RemoveAnimDict('mini@biotech@blowtorch_str')
        RemoveAnimDict('mini@biotech@blowtorch_def')
        RemoveAnimDict('missheistchem2')
    end
end

local function CreateGrill()
    local GrillHash = GetHashKey('prop_chem_grill')
    local GrillBitHash = GetHashKey('prop_chem_grill_bit')
    local GrillPos = vec4(3832.85, 3665.67, -23.0, 150.0)

    local Grill = exports['mani-bridge']:CreateObj(GrillHash, GrillPos)
    local GrillBit = exports['mani-bridge']:CreateObj(GrillBitHash, GrillPos)

    Objects[#Objects + 1] = Grill
    Objects[#Objects + 1] = GrillBit
    Heist.GrillBit = GrillBit

    FreezeEntityPosition(Grill, true)
    FreezeEntityPosition(GrillBit, true)

    return { Main = Grill, Bit = GrillBit }
end

local function StartHeist()
    local Grills = CreateGrill()

    exports['ox_target']:addLocalEntity(Grills.Bit, {
        label = 'Brug Gas Cutter',
        name = 'humane_heist_grill_bit',
        icon = 'fa-solid fa-scissors',
        distance = 2.5,
        onSelect = function()
            CutGrill()
        end,
    })
end

CreateThread(StartHeist)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end

    for i = 1, #Objects do
        DeleteObject(Objects[i])
    end
end)