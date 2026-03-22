local Config = require 'config'
local Inventory = exports['ox_inventory']
local Open = require 'open.server'

local Heist = {}

---@type function | nil
local CompleteContract = nil

local function ResetHeist()
    Heist = {
        Active = false,
        State = 0,
        Grill = {},
        GrillLoop = true,
        GrillCount = 0,
        Readers = {},
        Chemicals = {},
        Keypads = {},
        HackedKeypads = 0
    }
end

local function TeamAction(Source, Func)
    local Team = exports['mani-contracts']:GetTeam(Source)
    if Team then
        Team:Run(Func)
    else
        Func({ Source = Source})
    end
end

CreateThread(function()
    ResetHeist()

    if not Config.Contract.Enabled then return end
    while GetResourceState('mani-contracts') ~= 'started' do Wait(5000) end

    CompleteContract = exports['mani-contracts']:Register({
        Label = Config.Contract.Label,
        Description = Config.Contract.Description,
        Image = Config.Contract.Image,
        Export = 'StartHeist',
        OneTime = true,
        -- Cooldown = 3 * 60 * 60 * 1000,
        RequiredLevel = Config.Contract.RequiredLevel,
        Difficulty = 'Hard',
        Limited = true,
        XPReward = Config.Contract.XPReward,
        MinPolice = Config.Police.Required,
        Requirements = {
            '1x Humane Labs Access Card',
            '1x ?Hacking Device'
        },
    })
end)

Jet.Callback.Register('mani-humaneheist:server:UseReader', function(Source, DoorKey)
    local Search = Inventory:Search(Source, 'slots', Config.Card.ItemName)
    local Item = Search[1]
    if not Item then return { Success = false, Message = 'Du mangler et adgangskort' } end

    if Item.count > 1 then return { Success = false, Message = 'Du har 2 adgangskort i hånden' } end

    if DoorKey == 'main' and Heist.State ~= 3 then return { Success = false, Message = 'Adgangskortet har ikke adgang hertil endnu' } end

    local Durability = Item.metadata.durability or 100
    local NewDurability = Durability - (100 / Config.Card.Uses)

    if NewDurability <= 0 then
        Inventory:RemoveItem(Source, Config.Card.ItemName, 1, Item.slot)
    else
        Inventory:SetDurability(Source, Item.slot, NewDurability)
    end

    TriggerClientEvent('mani-humaneheist:client:UnlockDoor', -1, DoorKey)

    return { Success = true }
end)

Jet.Callback.Register('mani-humaneheist:server:CutGrill', function(Source)
    if Heist.State < 1 then return { Success = false, Message = 'Du kan ikke skære gitteret nu' } end
    Heist.State = 2


    TeamAction(Source, function(Member)
        TriggerClientEvent('mani-humaneheist:client:UpdateHeist', Member.Source, Heist)
    end)

    return { Success = true }
end)

RegisterNetEvent('mani-humaneheist:server:OpenGrill', function ()
    local Source = source

    local GrillBit = Heist.Grill.Bit
    local Entity = NetworkGetEntityFromNetworkId(GrillBit)

    FreezeEntityPosition(Entity, false)

    Heist.GrillLoop = false

    TeamAction(Source, function(Member)
        TriggerClientEvent('mani-humaneheist:client:SetupChemicals', Member.Source, Heist)
    end)
end)

Jet.Callback.Register('mani-humaneheist:server:VerifyChemical', function(Source)
    if Heist.State < 3 then return { Success = false, Message = 'Du kan ikke tage kemikalier nu' } end

    Heist.State = 4

    return { Success = true }
end)

Jet.Callback.Register('mani-humaneheist:server:TakeChemical', function(Source)
    if Heist.State < 4 then return { Success = false, Message = 'Du kan ikke tage kemikalier nu' } end
    Heist.State = 5

    local VialProp = NetworkGetEntityFromNetworkId(Heist.Chemicals.Vial)
    DeleteEntity(VialProp)

    local Amount = math.random(Config.Chemical.Amount[1], Config.Chemical.Amount[2])

    Inventory:AddItem(Source, Config.Chemical.Item, Amount)

    Open.Log(Source, ('Looted %sx %s from Humane Heist'):format(Amount, Config.Chemical.Item))

    CreateThread(function()
        local PlayerPed = GetPlayerPed(Source)
        local PlayerCoords = GetEntityCoords(PlayerPed)
        local HumaneCoords = vec3(3560.52, 3672.68, 28.50)

        local Distance = #(PlayerCoords - HumaneCoords)

        if CompleteContract ~= nil then CompleteContract(Source, true) end

        while Distance < 400.0 do
            Wait(10000)

            PlayerPed = GetPlayerPed(Source)
            PlayerCoords = GetEntityCoords(PlayerPed)
            Distance = #(PlayerCoords - HumaneCoords)
        end

        TeamAction(Source, function(Member)
            TriggerClientEvent('mani-humaneheist:client:FinishHeist', Member.Source, Heist)
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

        ResetHeist()
    end)

    return { Success = true }
end)

RegisterNetEvent('mani-humaneheist:server:OpenExit', function()
    TriggerClientEvent('mani-humaneheist:client:UnlockDoor', -1, 'exit')
end)

Jet.Callback.Register('mani-humaneheist:server:HeistDistance', function(Source)
    if Heist.Active then return { Success = false, Message = 'Heist er allerede aktivt' } end
    Heist.Active = true

    local PoliceCount = Jet.GetJobCount(Config.Police.Job)
    if PoliceCount < Config.Police.Required then return { Success = false, Message = 'Der er ikke nok politi.' } end

    local TeamMembers = {}
    local HumaneCoords = vec3(3832.85, 3665.67, -23.0)

    TeamAction(Source, function(Member)
        TeamMembers[#TeamMembers + 1] = Member.Source
        TriggerClientEvent('mani-humaneheist:client:SetupBlip', Member.Source)
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

                    Open.Log(Source, 'Started Humane Heist')

                    for MemberIndex = 1, #TeamMembers do
                        local MemberSource = TeamMembers[MemberIndex]
                        TriggerClientEvent('mani-humaneheist:client:StartHeist', MemberSource, Heist)
                    end

                    break
                end
            end

            Wait(5000)
        end
    end)

    return { Success = true }
end)

Jet.Callback.Register('mani-humaneheist:server:HackKeypad', function(Source, Index)
    local Keypad = Heist.Keypads[Index]
    if not Keypad then return { Success = false, Message = 'Nøglepanelet findes ikke' } end

    if Keypad.Hacked then return { Success = false, Message = 'Nøglepanelet er allerede hackede' } end
    Keypad.Hacked = true

    local LastKeypad

    Heist.HackedKeypads = Heist.HackedKeypads + 1
    if Heist.HackedKeypads >= #Heist.Keypads then
        Heist.State = 3
        LastKeypad = true
    end

    TeamAction(Source, function(Member)
        TriggerClientEvent('mani-humaneheist:client:HackKeypad', Member.Source, Heist, Index)
    end)

    return { Success = true, LastKeypad = LastKeypad }
end)