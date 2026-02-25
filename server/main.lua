local Config = require 'config'
local Inventory = exports['ox_inventory']
local Open = require 'open.server'
local CrateItems = {}

local Heist = {
    Active = false,
    State = 0,
    Grill = {},
    GrillLoop = true,
    GrillCount = 0,
    Readers = {},
    Chemicals = {},
    Keypads = {},
    Crates = {},
    HackedKeypads = 0
}

Jet.Callback.Register('mani-humaneheist:server:UseReader', function(Source, DoorKey)
    local Search = Inventory:Search(Source, 'slots', Config.Card.ItemName)
    local Item = Search[1]
    if not Item then return false, 'Du mangler et adgangskort' end

    if Item.count > 1 then return false, 'Du har 2 adgangskort i hånden' end

    if DoorKey == 'main' and Heist.State ~= 3 then return false, 'Adgangskortet har ikke adgang hertil endnu' end

    local Durability = Item.metadata.durability or 100
    local NewDurability = Durability - (100 / Config.Card.Uses)

    if NewDurability <= 0 then
        Inventory:RemoveItem(Source, Config.Card.ItemName, 1, Item.slot)
    else
        Inventory:SetDurability(Source, Item.slot, NewDurability)
    end

    TriggerClientEvent('mani-humaneheist:client:UnlockDoor', -1, DoorKey)

    return true
end)

Jet.Callback.Register('mani-humaneheist:server:CutGrill', function(Source)
    if Heist.State < 1 then return false, 'Du kan ikke skære gitteret nu' end
    Heist.State = 2

    exports['mani-bridge']:DoAction(Source, function(TeamSource)
        TriggerClientEvent('mani-humaneheist:client:UpdateHeist', TeamSource, Heist)
    end)

    return true
end)

RegisterNetEvent('mani-humaneheist:server:OpenGrill', function ()
    local Source = source

    local GrillBit = Heist.Grill.Bit
    local Entity = NetworkGetEntityFromNetworkId(GrillBit)

    FreezeEntityPosition(Entity, false)

    Heist.GrillLoop = false

    exports['mani-bridge']:DoAction(Source, function(TeamSource)
        TriggerClientEvent('mani-humaneheist:client:SetupChemicals', TeamSource, Heist)
    end)
end)

Jet.Callback.Register('mani-humaneheist:server:VerifyChemical', function(Source)
    if Heist.State < 3 then return false, 'Du kan ikke tage kemikalier nu' end

    Heist.State = 4

    return true
end)

Jet.Callback.Register('mani-humaneheist:server:TakeChemical', function(Source)
    if Heist.State < 4 then return false, 'Du kan ikke tage kemikalier nu' end
    Heist.State = 5

    local VialProp = NetworkGetEntityFromNetworkId(Heist.Chemicals.Vial)
    DeleteEntity(VialProp)

    local Amount = math.random(Config.Chemical.Amount[1], Config.Chemical.Amount[2])

    Inventory:AddItem(Source, Config.Chemical.Item, Amount)

    Open.Log(Source, ('Looted %sx %s from Humane Heist'):format(Amount, Config.Chemical.Item))

    CreateThread(function()
        local PlayerPed = GetPlayerPed(Source)
        local PlayerCoords = GetEntityCoords(PlayerPed)
        local HumaneCoords = vec3(3832.85, 3665.67, -23.0)

        local Distance = #(PlayerCoords - HumaneCoords)

        -- TODO: TEST DISTANCE

        print(Distance)

        while Distance < 200.0 do
            Wait(10000)

            PlayerPed = GetPlayerPed(Source)
            PlayerCoords = GetEntityCoords(PlayerPed)
            Distance = #(PlayerCoords - HumaneCoords)

            print(Distance)
        end

        exports['mani-bridge']:DoAction(Source, function(TeamSource)
            TriggerClientEvent('mani-humaneheist:client:FinishHeist', TeamSource, Heist)
        end)

        DeleteEntity(NetworkGetEntityFromNetworkId(Heist.Grill.Bit))
        DeleteEntity(NetworkGetEntityFromNetworkId(Heist.Grill.Main))
        DeleteEntity(NetworkGetEntityFromNetworkId(Heist.Chemicals.Tube))
        DeleteEntity(NetworkGetEntityFromNetworkId(Heist.Chemicals.Vial))

        for i = 1, #Heist.Readers do
            DeleteEntity(NetworkGetEntityFromNetworkId(Heist.Readers[i].NetId))
        end

        for i = 1, #Heist.Keypads do
            DeleteEntity(NetworkGetEntityFromNetworkId(Heist.Keypads[i].NetId))
        end

        Heist = {}
    end)

    return true
end)

RegisterNetEvent('mani-humaneheist:server:OpenExit', function()
    TriggerClientEvent('mani-humaneheist:client:UnlockDoor', -1, 'exit')
end)

Jet.Callback.Register('mani-humaneheist:server:HeistData', function(Source)
    local PoliceCount = exports['mani-bridge']:GetJobCount('police')

    if Heist.Active then return false, 'Det er for sent.' end
    if PoliceCount < Config.MinPolice then return false, 'Der er ikke nok politi.' end

    return true
end)

Jet.Callback.Register('mani-humaneheist:server:HeistDistance', function(Source)
    if Heist.Active then return false end
    Heist.Active = true

    local TeamMembers = {}
    local HumaneCoords = vec3(3832.85, 3665.67, -23.0)

    exports['mani-bridge']:DoAction(Source, function(TeamSource)
        print(TeamSource)
        TeamMembers[#TeamMembers + 1] = TeamSource
        TriggerClientEvent('mani-humaneheist:client:SetupBlip', TeamSource)
    end)

    CreateThread(function()
        local InArea = false

        while not InArea do
            for i = 1, #TeamMembers do
                local TeamSource = TeamMembers[i]
                local PlayerPed = GetPlayerPed(TeamSource)
                local PlayerCoords = GetEntityCoords(PlayerPed)

                local Distance = #(PlayerCoords - HumaneCoords)
                if Distance < 50.0 then
                    InArea = true

                    local Data = Jet.Callback.Await('mani-humaneheist:client:SetupHeist', TeamSource, false)

                    Heist.State = 1

                    Heist.Grill = Data.Grills
                    Heist.Readers = Data.Readers
                    Heist.Chemicals = Data.Chemicals
                    Heist.Keypads = Data.Keypads
                    Heist.Crates = Data.Crates

                    Open.Log(Source, 'Started Humane Heist')

                    for i = 1, #TeamMembers do
                        local MemberSource = TeamMembers[i]
                        TriggerClientEvent('mani-humaneheist:client:StartHeist', MemberSource, Heist)
                    end

                    break
                end
            end

            Wait(5000)
        end
    end)

    return true
end)

Jet.Callback.Register('mani-humaneheist:server:HackKeypad', function(Source, Index)
    local Keypad = Heist.Keypads[Index]
    if not Keypad then return false, 'Nøglepanelet findes ikke' end

    if Keypad.Hacked then return false, 'Nøglepanelet er allerede hackede' end
    Keypad.Hacked = true

    local LastKeypad

    Heist.HackedKeypads = Heist.HackedKeypads + 1
    if Heist.HackedKeypads >= #Heist.Keypads then
        Heist.State = 3
        LastKeypad = true
    end

    exports['mani-bridge']:DoAction(Source, function(TeamSource)
        TriggerClientEvent('mani-humaneheist:client:HackKeypad', TeamSource, Heist, Index)
    end)

    return true, nil, LastKeypad
end)

CreateThread(function()
    for i = 1, #Config.Crates.Items do
        local Item = Config.Crates.Items[i]
        for j = 1, Item.Chance do
            CrateItems[#CrateItems + 1] = i
        end
    end
end)