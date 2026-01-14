local Config, Inventory = lib.load('config'), exports['ox_inventory']

local Heist = {
    State = 0,
    Grill = {},
    GrillLoop = true,
    GrillCount = 0,
    Readers = {},
    Chemicals = {}
}

RegisterNetEvent('mani-humaneheist:server:StartHeist', function(Data)
    if Heist.State ~= 0 then return end

    local Source = source

    Heist.State = 1

    Heist.Grill = Data.Grills
    Heist.Readers = Data.Readers
    Heist.Chemicals = Data.Chemicals

    exports['mani-bridge']:DoAction(Source, function(TeamSource)
        TriggerClientEvent('mani-humaneheist:client:StartHeist', TeamSource, Heist)
    end)
end)

lib.callback.register('mani-humaneheist:server:UseReader', function(Source, DoorKey)
    local Search = Inventory:Search(Source, 'slots', Config.Card.ItemName)
    local Item = Search[1]
    if not Item then return false, 'Du mangler et adgangskort' end

    if Item.count > 1 then return false, 'Du har 2 adgangskort i hånden' end

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

lib.callback.register('mani-humaneheist:server:CutGrill', function(Source)
    if Heist.State ~= 1 then return false, 'Du kan ikke skære gitteret nu' end
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

lib.callback.register('mani-humaneheist:server:TakeChemical', function(Source)
    if Heist.State ~= 2 then return false, 'Du kan ikke tage kemikalier nu' end
    Heist.State = 3

    local Amount = math.random(Config.Chemical.Amount[1], Config.Chemical.Amount[2])

    Inventory:AddItem(Source, Config.Chemical.Item, Amount)

    exports['mani-bridge']:DoAction(Source, function(TeamSource)
        TriggerClientEvent('mani-humaneheist:client:FinishHeist', TeamSource, Heist)
    end)

    return true
end)