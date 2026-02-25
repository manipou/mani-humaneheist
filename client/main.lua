local Config = require 'config'
local Open = require 'open.client'

local Target = exports['ox_target']

local Objects, Particles, Heist, Doors, Blips = {}, {}, {}, {}, { Keypads = {}, Crates = {} }

local GasPoints = {
    { Light = vec3(3833.42, 3665.39, -22.11), Vertical = false, Offset = vec3(-0.645, -0.03, 0.90), Axis = {0.215, 0.92} },
    { Light = vec3(3833.20, 3665.51, -22.11), Vertical = false, Offset = vec3(-0.375, -0.03, 0.90), Axis = {0.355, 0.92} },
    { Light = vec3(3832.98, 3665.64, -22.11), Vertical = false, Offset = vec3(-0.125, -0.03, 0.90), Axis = {0.465, 0.92} },
    { Light = vec3(3832.76, 3665.77, -22.11), Vertical = false, Offset = vec3(0.125, -0.03, 0.90), Axis = {0.59, 0.92} },
    { Light = vec3(3832.54, 3665.90, -22.11), Vertical = false, Offset = vec3(0.375, -0.03, 0.90), Axis = {0.715, 0.92} },
    { Light = vec3(3832.32, 3666.03, -22.11), Vertical = false, Offset = vec3(0.625, -0.03, 0.90), Axis = {0.83, 0.92} },
    { Light = vec3(3833.57, 3665.35, -22.230), Vertical = true, Offset = vec3(-0.775, -0.03, 0.77), Axis = {0.145, 0.88} },
    { Light = vec3(3833.57, 3665.35, -22.489), Vertical = true, Offset = vec3(-0.775, -0.03, 0.52), Axis = {0.145, 0.74} },
    { Light = vec3(3833.57, 3665.35, -22.748), Vertical = true, Offset = vec3(-0.775, -0.03, 0.27), Axis = {0.145, 0.62} },
    { Light = vec3(3833.57, 3665.35, -23.007), Vertical = true, Offset = vec3(-0.775, -0.03, 0.02), Axis = {0.145, 0.5} },
    { Light = vec3(3833.57, 3665.35, -23.266), Vertical = true, Offset = vec3(-0.775, -0.03, -0.25), Axis = {0.145, 0.375} },
    { Light = vec3(3833.57, 3665.35, -23.525), Vertical = true, Offset = vec3(-0.775, -0.03, -0.52), Axis = {0.145, 0.24} },
    { Light = vec3(3833.57, 3665.35, -23.784), Vertical = true, Offset = vec3(-0.775, -0.03, -0.77), Axis = {0.145, 0.12} },
    { Light = vec3(3833.42, 3665.39, -23.900), Vertical = false, Offset = vec3(-0.645, -0.03, -0.90), Axis = {0.215, 0.065} },
    { Light = vec3(3833.20, 3665.51, -23.900), Vertical = false, Offset = vec3(-0.375, -0.03, -0.90), Axis = {0.355, 0.065} },
    { Light = vec3(3832.98, 3665.64, -23.900), Vertical = false, Offset = vec3(-0.125, -0.03, -0.90), Axis = {0.465, 0.065} },
    { Light = vec3(3832.76, 3665.77, -23.900), Vertical = false, Offset = vec3(0.125, -0.03, -0.90), Axis = {0.59, 0.065} },
    { Light = vec3(3832.54, 3665.90, -23.900), Vertical = false, Offset = vec3(0.375, -0.03, -0.90), Axis = {0.715, 0.065} },
    { Light = vec3(3832.32, 3666.03, -23.900), Vertical = false, Offset = vec3(0.625, -0.03, -0.90), Axis = {0.83, 0.065} },
    { Light = vec3(3832.21, 3666.14, -22.230), Vertical = true, Offset = vec3(0.775, -0.03, 0.77), Axis = {0.895, 0.88} },
    { Light = vec3(3832.21, 3666.14, -22.489), Vertical = true, Offset = vec3(0.775, -0.03, 0.52), Axis = {0.895, 0.74} },
    { Light = vec3(3832.21, 3666.14, -22.748), Vertical = true, Offset = vec3(0.775, -0.03, 0.27), Axis = {0.895, 0.62} },
    { Light = vec3(3832.21, 3666.14, -23.007), Vertical = true, Offset = vec3(0.775, -0.03, 0.02), Axis = {0.895, 0.5} },
    { Light = vec3(3832.21, 3666.14, -23.266), Vertical = true, Offset = vec3(0.775, -0.03, -0.25), Axis = {0.895, 0.375} },
    { Light = vec3(3832.21, 3666.14, -23.525), Vertical = true, Offset = vec3(0.775, -0.03, -0.52), Axis = {0.895, 0.24} },
    { Light = vec3(3832.21, 3666.14, -23.784), Vertical = true, Offset = vec3(0.775, -0.03, -0.77), Axis = {0.895, 0.12} },
}

local function AlmostEqual(V1, V2, Threshold) return math.abs(V1 - V2) <= Threshold end

local function CreateBlip(Data)
    local Blip = AddBlipForCoord(Data.Coords.x, Data.Coords.y, Data.Coords.z)
    SetBlipSprite(Blip, Data.Sprite or 499)
    SetBlipColour(Blip, Data.Color or 1)
    SetBlipAsShortRange(Blip, Data.ShortRange == nil or Data.ShortRange --[[@as boolean]])
    SetBlipScale(Blip, Data.Scale or 0.5)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(Data.Label or 'Humane Heist')
    EndTextCommandSetBlipName(Blip)

    return Blip
end

local function TakeChemical(Data)
    local Success, Error = Jet.Callback.Await('mani-humaneheist:server:VerifyChemical', false)
    if not Success then Jet.Notify({ title = 'Fejl', description = Error, type = 'error' } ) return end

    local PlayerPed = cache.ped
    local Dict = 'missfbi5ig_22'
    local SceneOffset = vec3(-1.636963, 5.204346, -1.382074)
    local Rotation = vec3(0.0, 0.0, 170.0)

    local TubeProp = Data.entity
    local VialProp = NetworkGetEntityFromNetworkId(Heist.Chemicals.Vial)

    local ScenePos = GetEntityCoords(TubeProp) + SceneOffset

    Jet.Request.AnimDict(Dict)

    local TakeScene = NetworkCreateSynchronisedScene(ScenePos, Rotation, 2, true, true, -1, 0, 1.0)
    NetworkAddPedToSynchronisedScene(PlayerPed, TakeScene, Dict, 'take_chemical_player0', 1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(VialProp, TakeScene, Dict, 'take_chemical_tube', 1.0, 1.0, 1)
    NetworkAddEntityToSynchronisedScene(TubeProp, TakeScene, Dict, 'take_chemical_vial', 1.0, 1.0, 1)

    NetworkStartSynchronisedScene(TakeScene)

    Wait(12766)
    
    RemoveAnimDict(Dict)

    Success, Error = Jet.Callback.Await('mani-humaneheist:server:TakeChemical', false)
    if not Success then Jet.Notify({ title = 'Fejl', description = Error, type = 'error' } ) return end
end

local function ExitMinigame()
    local PlayerPed = cache.ped

    Heist.GrillLoop = false

    ClearPedTasks(PlayerPed)
    DeleteObject(Heist['GasTorch'])

    for i = 1, #Particles do
        StopParticleFxLooped(Particles[i], false)
    end

    Open.Dispatch()

    TriggerServerEvent('mani-humaneheist:server:OpenGrill')
end

local function MinigameCheck(var1, var2)
    for i = 1, #GasPoints do
        local Point = GasPoints[i]
        if not Point.Cracked then
            DrawLightWithRange(Point.Light.x, Point.Light.y, Point.Light.z, 0, 255, 0, 0.03, 100.0)

            if AlmostEqual(var1, Point.Axis[1], 0.025) and AlmostEqual(var2, Point.Axis[2], 0.025) then
                UseParticleFxAssetNextCall('scr_fbi5a')
                local ParticleFX = StartParticleFxLoopedOnEntity('scr_bio_grille_cutting', Heist['GasTorch'], -0.344, 0.0, 0.093, 0.0, 0.0, 0.0, 1.0, false, false, false)
                Wait(Config.Debug and 100 or 2500)
                StopParticleFxLooped(ParticleFX, false)
                Point.Cracked = true
                Heist.GrillCount = Heist.GrillCount + 1

                UseParticleFxAssetNextCall('scr_fbi5a')
                local Rotation = Point.Vertical and 0.0 or 90.0
                local GrillBit = NetworkGetEntityFromNetworkId(Heist.Grill.Bit)
                Particles[i] = StartParticleFxLoopedOnEntity('scr_bio_grille_break', GrillBit, Point.Offset, 0.0, Rotation, 0.0, 1.2, false, false, false)

                if Heist.GrillCount == #GasPoints then
                    ExitMinigame()
                end
            end
        end
    end
end

local function CutGrill()
    local Success, Error = Jet.Callback.Await('mani-humaneheist:server:CutGrill', false)
    if not Success then Jet.Notify({ title = 'Fejl', description = Error, type = 'error' } ) return end

    local PlayerPed = cache.ped
    local PedCoords = GetEntityCoords(PlayerPed)

    SetPedResetFlag(PlayerPed, 197, true)
    SetPedCanLegIk(PlayerPed, false)
    SetPedCanHeadIk(PlayerPed, false)

    Jet.Request.AnimDict('mini@biotech@blowtorch_str')
    Jet.Request.AnimDict('mini@biotech@blowtorch_def')
    Jet.Request.AnimDict('missheistchem2')
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

            MinigameCheck(X, Y)

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

    local GrillEntity, Grill = exports['mani-bridge']:CreateObj(GrillHash, GrillPos)
    local GrillBitEntity, GrillBit = exports['mani-bridge']:CreateObj(GrillBitHash, GrillPos)

    Objects[#Objects + 1] = GrillEntity
    Objects[#Objects + 1] = GrillBitEntity

    FreezeEntityPosition(GrillEntity, true)
    FreezeEntityPosition(GrillBitEntity, true)

    return {
        Main = Grill,
        Bit = GrillBit
    }
end

local function CreateReaders()
    local Readers = {}

    local ReaderModel = GetHashKey('m23_1_prop_m31_control_panel_01a')

    for i = 1, #Config.Doors do
        local Door = Config.Doors[i]
        local DoorKey = Door.Key
        local ReaderCoords = Door.Reader

        if ReaderCoords then
            local ReaderEntity, Reader = exports['mani-bridge']:CreateObj(ReaderModel, ReaderCoords)

            Objects[#Objects + 1] = ReaderEntity
            
            Readers[#Readers+1] = { NetId = Reader, DoorKey = DoorKey }
        end
    end

    return Readers
end

local function SetupReaders()
    for i = 1, #Heist.Readers do
        local ReaderData = Heist.Readers[i]
        
        Target:addEntity(ReaderData.NetId, {
            label = 'Swipe Kortet',
            name = 'humane_heist_reader_' .. ReaderData.DoorKey,
            icon = 'fa-solid fa-id-card',
            distance = 2.5,
            items = Config.Card.ItemName,
            onSelect = function(Data)
                TriggerEvent('ox_inventory:disarm', true)
                exports['mani-bridge']:CardSwipe(function()
                    local Success, Error = Jet.Callback.Await('mani-humaneheist:server:UseReader', false, ReaderData.DoorKey)
                    if not Success then Jet.Notify({ title = 'Fejl', description = Error, type = 'error' } ) end
                end, Data.entity)
            end,
        })
    end
end

local function SetupKeypads()
    for i = 1, #Heist.Keypads do
        local KeypadData = Heist.Keypads[i]

        local Blip = CreateBlip({ Coords = Config.Keypads.Locations[KeypadData.Coords], Label = 'Keypad', Sprite = 619, Color = 1, Scale = 0.5, ShortRange = false })
        
        Blips.Keypads[i] = Blip

        Target:addEntity(KeypadData.NetId, {
            label = 'Hack Keypad',
            name = 'humane_heist_keypad_' .. i,
            icon = 'fa-solid fa-keyboard',
            distance = 2.5,
            canInteract = function()
                return not Heist.Keypads[i].Hacked
            end,
            onSelect = function(Data)
                TriggerEvent('ox_inventory:disarm', true)
                exports['mani-bridge']:HackUSB(function()
                    if exports['mani-minigames']:Untangle({
                        Timer = 20,
                        Dots = 9
                    }) then
                        local Success, Error, LastKeypad = Jet.Callback.Await('mani-humaneheist:server:HackKeypad', false, i)
                        if not Success then Jet.Notify({ title = 'Fejl', description = Error, type = 'error' } ) return end
                        if LastKeypad then Jet.Notify({ title = 'Succes', description = 'Alle keypads er hacket.', type = 'success' } ) return end
                    end
                end, Data.entity)
            end
        })
    end
end

local function CreateKeypads()
    local ChosenCoords = {}
    local Locations = {}

    local Amount = math.random(Config.Keypads.Amount[1], Config.Keypads.Amount[2])

    local KeypadModel = GetHashKey('ch_prop_casino_keypad_02')

    for i = 1, Amount do
        local Location = math.random(1, #Config.Keypads.Locations)
        while ChosenCoords[Location] do
            Location = math.random(1, #Config.Keypads.Locations)
        end
        ChosenCoords[Location] = true

        local KeypadEntity, KeypadNetid = exports['mani-bridge']:CreateObj(KeypadModel, Config.Keypads.Locations[Location])

        Objects[#Objects + 1] = KeypadEntity

        Locations[#Locations + 1] = {
            Coords = Location,
            NetId = KeypadNetid,
            Hacked = false
        }
    end

    return Locations
end

local function SetupGuards()
    if Config.Debug then return end

    AddRelationshipGroup('HUMANE_GUARDS')
    local GuardGroup = GetHashKey('HUMANE_GUARDS')

    for i = 1, #Config.Guards.Locations do
        local GuardPos = Config.Guards.Locations[i]
        local Ped = exports['mani-bridge']:CreateNPC(GetHashKey('U_M_M_JewelSec_01'), GuardPos)

        Objects[#Objects + 1] = Ped

        SetPedCombatAttributes(Ped, 46, true)
        SetPedAsEnemy(Ped, true)
        SetPedArmour(Ped, Config.Guards.Status.Armor)
        SetEntityHealth(Ped, Config.Guards.Status.Health)
        SetPedAccuracy(Ped, Config.Guards.Status.Accuracy)
        SetPedCombatAbility(Ped, 2)
        SetPedCombatMovement(Ped, 2)
        SetPedCombatRange(Ped, 2)
        SetPedAlertness(Ped, 3)
        
        GiveWeaponToPed(Ped, GetHashKey(Config.Guards.Weapons[math.random(1, #Config.Guards.Weapons)]), 9999, false, false)

        SetPedRelationshipGroupHash(Ped, GuardGroup)
    end

    SetRelationshipBetweenGroups(5, GuardGroup, GetHashKey('PLAYER'))
    SetRelationshipBetweenGroups(0, GuardGroup, GuardGroup)
end

local function CreateChemicals()
    local TubeModel = GetHashKey('p_chem_vial_02b_s')
    local VialModel = GetHashKey('prop_cs_vial_01')
    local TubePos = vec4(3560.52, 3672.68, 28.50, 272.40521240234)
    local VialPos = vec4(3560.486816, 3672.732422, 28.276993, 271.98004150391)

    local TubeEntity, Tube = exports['mani-bridge']:CreateObj(TubeModel, TubePos)
    local VialEntity, Vial = exports['mani-bridge']:CreateObj(VialModel, VialPos)

    Objects[#Objects + 1] = TubeEntity
    Objects[#Objects + 1] = VialEntity

    FreezeEntityPosition(TubeEntity, true)
    FreezeEntityPosition(VialEntity, true)

    return {
        Tube = Tube,
        Vial = Vial
    }
end

local function CreateCrates()
    local CrateModel = GetHashKey('xm3_prop_xm3_crate_01a')
    local Crates = {}

    local Amount = math.random(Config.Crates.Amount[1], Config.Crates.Amount[2])

    local ChosenCoords = {}

    for i = 1, Amount do
        local Location = math.random(1, #Config.Crates.Locations)
        while ChosenCoords[Location] do
            Location = math.random(1, #Config.Crates.Locations)
        end
        ChosenCoords[Location] = true

        local CrateEntity, CrateNetid = exports['mani-bridge']:CreateObj(CrateModel, Config.Crates.Locations[Location])

        Objects[#Objects + 1] = CrateEntity

        Crates[#Crates + 1] = {
            Coords = Location,
            NetId = CrateNetid,
            Opened = false
        }
    end

    return Crates
end

local function SetupCrates()
    for i = 1, #Heist.Crates do
        local CrateData = Heist.Crates[i]

        local Blip = CreateBlip({ Coords = Config.Crates.Locations[CrateData.Coords], Label = 'Crate', Sprite = 478, Color = 2, Scale = 0.5, ShortRange = false })

        Blips.Crates[i] = Blip

        Target:addEntity(CrateData.NetId, {
            label = 'Åben Kasse',
            name = 'humane_heist_crate_' .. i,
            icon = 'fa-solid fa-box',
            distance = 2.5,
            canInteract = function()
                return not Heist.Crates[i].Opened
            end,
            onSelect = function(Data)
                TriggerEvent('ox_inventory:disarm', true)
                Jet.Scenes.OpenCrate(Data.entity, function()

                end)
            end
        })
    end
end

Jet.Callback.Register('mani-humaneheist:client:SetupHeist', function()
    local Grills = CreateGrill()
    local Readers = CreateReaders()
    local Chemicals = CreateChemicals()
    local Keypads = CreateKeypads()
    local Crates = CreateCrates()

    return {
        Grills = Grills,
        Readers = Readers,
        Chemicals = Chemicals,
        Keypads = Keypads,
        Crates = Crates
    }
end)

RegisterNetEvent('mani-humaneheist:client:StartHeist', function(HeistData)
    Heist = HeistData

    Target:addEntity(Heist.Grill.Bit, {
        label = 'Brug Gas Cutter',
        name = 'humane_heist_grill_bit',
        icon = 'fa-solid fa-scissors',
        distance = 2.5,
        canInteract = function() return Heist.State == 1 end,
        onSelect = CutGrill
    })

    SetupReaders()

    SetupKeypads()

    SetupCrates()

    Target:addSphereZone({
        coords = vec3(3536.08, 3658.97, 28.12),
        name = 'humane_exit',
        radius = 0.5,
        debug = Config.Debug,
        debugColour = vec4(51, 54, 92, 50.0),
        options = {
            label = 'Hack Garage',
            icon = 'fa-solid fa-laptop-code',
            distance = 2.5,
            onSelect = function()
                TriggerEvent('ox_inventory:disarm', true)
                if exports['mani-minigames']:ColorShape({
                    Timer = 10,
                    Rounds = 3,
                    MinCards = 3,
                    MaxCards = 4,
                    Anim = {
                        Scenario = 'WORLD_HUMAN_STAND_MOBILE_FACILITY',
                    }
                }) then
                    Jet.Notify({ title = 'Succes', description = 'Garage låst op', type = 'success' } )
                    TriggerServerEvent('mani-humaneheist:server:OpenExit')
                end
            end
        }
    })

    SetupGuards()
end)

local function OpenHeistMenu()
    local Success, Error = Jet.Callback.Await('mani-humaneheist:server:HeistData', false)
    if not Success then Jet.Notify({ title = 'Fejl', description = Error, type = 'error' } ) return end

    -- local Confirm = lib.alertDialog({
    --     header = 'Start Heist',
    --     content = 'Kræver:  \n Hacking Device  \n Adgangskort  \n \n Er du sikker på du vil starte heistet?',
    --     centered = true,
    --     cancel = true
    -- })

    local Confirm = 'confirm'

    if Confirm == 'confirm' then
        Success = Jet.Callback.Await('mani-humaneheist:server:HeistDistance', false)
        if not Success then Jet.Notify({ title = 'Cooldown', description = 'Humane Labs er allerede blevet røvet.', type = 'error' } ) return end
        Jet.Notify({ title = 'Heist Startet', description = 'Gå til Humane Labs og begynd heistet', type = 'success' } )
    end
end

if Config.Debug then OpenHeistMenu() end

CreateThread(function()
    for ConfigDoor = 1, #Config.Doors do
        local Door = Config.Doors[ConfigDoor]
        Doors[Door.Key] = {}
        if Door.Double then
            for DoorIndex = 1, #Door.Double do
                local SubDoor = Door.Double[DoorIndex]
                SubDoor.Hash = GetHashKey(('mani_humane_%s_%d'):format(Door.Key, DoorIndex))
                AddDoorToSystem(SubDoor.Hash, SubDoor.Model, SubDoor.Coords.x, SubDoor.Coords.y, SubDoor.Coords.z, false, false, false)
                DoorSystemSetDoorState(SubDoor.Hash, 1, false, false)
                Doors[Door.Key][#Doors[Door.Key] + 1] = SubDoor.Hash
            end
        else
            Door.Hash = GetHashKey(('mani_humane_%s'):format(Door.Key))
            AddDoorToSystem(Door.Hash, Door.Model, Door.Coords.x, Door.Coords.y, Door.Coords.z, false, false, false)
            DoorSystemSetDoorState(Door.Hash, 1, false, false)
            Doors[Door.Key][1] = Door.Hash
        end
    end

    local NPCModel = GetHashKey(Config.NPC.Model)
    local NPCCoords = Config.NPC.Coords

    Jet.Points.New({
        coords = NPCCoords,
        distance = 75,
        onEnter = function(self)
            Jet.Request.Model(NPCModel)
            local NPC = CreatePed(4, NPCModel, NPCCoords.x, NPCCoords.y, NPCCoords.z, NPCCoords.w, false, true)
            FreezeEntityPosition(NPC, true)
            SetEntityInvincible(NPC, true)
            SetBlockingOfNonTemporaryEvents(NPC, true)

            SetModelAsNoLongerNeeded(NPCModel)

            self.NPC = NPC

            Target:addLocalEntity(NPC, {
                label = 'Humane Heist',
                icon = 'fa-solid fa-briefcase',
                distance = 2.5,
                onSelect = OpenHeistMenu,
            })
        end,
        onExit = function(self)
            Target:removeLocalEntity(self.NPC)
            DeleteEntity(self.NPC)
        end
    })
end)

RegisterNetEvent('mani-humaneheist:client:HackKeypad', function(HeistData, Index)
    Heist = HeistData

    Target:removeEntity(Heist.Keypads[Index].NetId)

    RemoveBlip(Blips.Keypads[Index])
end)

RegisterNetEvent('mani-humaneheist:client:SetupChemicals', function(HeistData)
    Heist = HeistData

    Target:addEntity(Heist.Chemicals.Tube, {
        label = 'Tag Kemisk Tube',
        name = 'humane_heist_chemical_tube',
        icon = 'fa-solid fa-flask',
        distance = 2.5,
        canInteract = function() return Heist.State == 3 end,
        onSelect = TakeChemical,
    })
end)

RegisterNetEvent('mani-humaneheist:client:FinishHeist', function()
    local NetIds = {}

    NetIds[#NetIds + 1] = Heist.Grill.Bit
    NetIds[#NetIds + 1] = Heist.Chemicals.Tube

    Target:removeEntity(NetIds)

    Heist = {}
end)

RegisterNetEvent('mani-humaneheist:client:UpdateHeist', function(HeistData) Heist = HeistData end)

RegisterNetEvent('mani-humaneheist:client:UnlockDoor', function(Key)
    for i = 1, #Doors[Key] do
        local DoorHash = Doors[Key][i]
        DoorSystemSetDoorState(DoorHash, 0, false, false)
    end

    if Key == 'exit' and next(Heist) then
        Target:removeZone('humane_exit')
    end
end)

RegisterNetEvent('w', function()
    local Coords = vec3(3832.85, 3665.67, -23.0)
    local Blip = CreateBlip({ Coords = Coords })
    
    SetBlipRoute(Blip, true)

    CreateThread(function()
        local PlayerCoords = GetEntityCoords(cache.ped)
        while #(PlayerCoords - Coords) > 50.0 do
            PlayerCoords = GetEntityCoords(cache.ped)
            Wait(2500)
        end

        RemoveBlip(Blip)
    end)
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end

    for i = 1, #Objects do
        DeleteObject(Objects[i])
    end
end)