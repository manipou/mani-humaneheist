local Config = {}

Config.Debug = false

Config.Contract = {
    Enabled = true,
    Label = 'Humane Heist',
    Description = 'Infiltrate the Humane Labs facility and extract classified vial research data. Requires stealth and coordination.',
    Image = 'https://r2.fivemanage.com/WmVydXgpgFklWNec1F7Gy/vrC1C5N.jpg',
    RequiredLevel = 1,
    XPReward = 150
}

Config.Police = {
    Job = 'police',
    Dispatch = true,
    Required = 0
}

Config.NPC = { -- Temp Heist NPC Indtil tablet/pc app.
    Model = 'G_M_M_ChiGoon_02',
    Coords = vec4(-546.80, -1805.50, 21.49, 61.46)
}

Config.Card = {
    Uses = 8,
    ItemName = 'humane_card'
}

Config.Chemical = {
    Item = 'chem_vial',
    Amount = { 1, 1 }
}

Config.HackingDevice = 'hacking_device'

Config.Guards = {
    Locations = {
        vec4(3527.44, 3693.46, 19.99, 12.76),
        vec4(3523.61, 3681.16, 19.99, 358.42),
        vec4(3522.37, 3688.93, 19.99, 257.39),
        vec4(3532.30, 3674.30, 19.99, 168.23),
        vec4(3526.76, 3673.63, 27.12, 259.34),
        vec4(3532.07, 3664.75, 27.12, 81.84),
        vec4(3528.49, 3660.12, 27.12, 327.97),
        vec4(3534.66, 3645.66, 26.52, 349.06),
        vec4(3540.63, 3667.15, 27.12, 130.50),
        vec4(3538.11, 3659.72, 27.12, 48.65),
        vec4(3550.11, 3657.90, 27.12, 168.61),
        vec4(3553.03, 3656.44, 27.12, 84.39),
        vec4(3555.03, 3661.43, 27.12, 76.89),
        vec4(3551.15, 3664.96, 27.12, 166.77),
        vec4(3561.15, 3679.02, 27.12, 79.65),
        vec4(3555.17, 3681.04, 27.12, 186.51),
        vec4(3559.71, 3665.59, 27.12, 79.98),
        vec4(3561.09, 3684.85, 27.12, 175.39),
        vec4(3567.50, 3682.37, 27.12, 78.56),
        vec4(3568.13, 3701.73, 27.12, 168.57),
        vec4(3563.10, 3690.27, 27.12, 265.00),
        vec4(3585.75, 3691.60, 26.12, 83.85),
        vec4(3584.74, 3683.25, 26.62, 336.67),
        vec4(3591.32, 3677.14, 26.62, 7.42)
    },
    Weapons = {
        'WEAPON_COMBATPDW',
        'WEAPON_ASSAULTRIFLE_MK2',
        'WEAPON_CARBINERIFLE_MK2'
    },
    Status = {
        Health = 200,
        Armor = 100,
        Accuracy = 75
    }
}

Config.Keypads = {
    Amount = { 1, 1 },
    Locations = {
        vec4(3531.94, 3651.47, 27.95, -10.0),
        vec4(3549.31, 3641.15, 28.46, -100.0),
        vec4(3552.63, 3655.3410644531, 28.44, 170.0),
        vec4(3562.98, 3680.11, 28.46, -10.0),
        vec4(3562.11, 3687.3959960938, 28.44, 170.0),
        vec4(3560.36, 3664.0883789062, 28.44, 170.0)
    }
}

-- Config.Crates = {
--     Locations = {
--         vec4(3608.59, 3744.80, 27.6, -125.0),
--         vec4(3613.61, 3749.85, 27.69, -125.0),
--         vec4(3624.11, 3736.15, 27.69, 55.0),
--         vec4(3605.15, 3728.75, 28.68, -35.0)
--     },
--     Loot = { -- Must add up to 100% total
--         { Item = 'gold_bar', Amount = { 50, 100 }, Chance = 70 },
--         { Item = 'weapon_pistol', Amount = { 1, 1 }, Chance = 10 },
--         { Item = 'weapon_pistol50', Amount = { 1, 1 }, Chance = 5 },
--         { Item = 'weapon_pistolxm3', Amount = { 1, 1 }, Chance = 5 },
--         { Item = 'weapon_machinepistol', Amount = { 1, 1 }, Chance = 1 },
--         { Item = 'weapon_microsmg', Amount = { 1, 1 }, Chance = 1 },
--         { Item = 'weapon_minismg', Amount = { 1, 1 }, Chance = 1 },
--         { Item = 'armor', Amount = { 1, 5 }, Chance = 7 }
--     },
--     Amount = { 3, 4 }
-- }

Config.Doors = {
    {
        Key = 'entrance',
        Model = 19193616,
        Coords = vec3(3526.0205078125, 3702.2426757812, 21.341960906982),
        Reader = vec4(3523.9748535156, 3702.7253417969, 21.416620254517, 170.0)
    },
    {
        Key = 'labdoor1',
        Double = {
            {
                Model = 161378502,
                Coords = vec3(3530.5300292969, 3671.0639648438, 27.117721557617),
            },
            {
                Model = -1572101598,
                Coords = vec3(3533.0954589844, 3670.6147460938, 27.117725372314),
            }
        },
        Reader = vec4(3530.2143554688, 3671.2546386719, 28.46, 170.0)
    },
    {
        Key = 'labdoor2',
        Double = {
            {
                Model = 161378502,
                Coords = vec3(3532.5209960938, 3663.3051757812, 27.11826133728),
            },
            {
                Model = -1572101598,
                Coords = vec3(3532.9709472656, 3665.8701171875, 27.118263244629),
            }
        },
        Reader = vec4(3531.9946289062, 3662.7570800781, 28.46, -100.0)
    },
    {
        Key = 'labdoor3',
        Double = {
            {
                Model = 161378502,
                Coords = vec3(3551.5776367188, 3658.3430175781, 27.117876052856),
            },
            {
                Model = -1572101598,
                Coords = vec3(3549.0122070312, 3658.791015625, 27.117876052856),
            }
        },
        Reader = vec4(3552.1022949219, 3657.8950195312, 28.46, -10.0)
    },
    {
        Key = 'labdoor4',
        Double = {
            {
                Model = 161378502,
                Coords = vec3(3555.4367675781, 3664.8010253906, 27.118925094604),
            },
            {
                Model = -1572101598,
                Coords = vec3(3552.8723144531, 3665.2546386719, 27.11904335022),
            }
        },
        Reader = vec4(3555.648, 3664.61, 28.46, -10.0)
    },
    {
        Key = 'main', -- main Door isn't unlockable before all keypads are hacked.
        Model = 161378502,
        Coords = vec3(3557.5546875, 3669.1918945312, 27.119510650635),
        Reader = vec4(3557.3454589844, 3668.7624511719, 28.46, -100.0)
    },
    {
        Key = 'labdoor6',
        Double = {
            {
                Model = 161378502,
                Coords = vec3(3558.30859375, 3681.0874023438, 27.119667053223),
            },
            {
                Model = -1572101598,
                Coords = vec3(3555.7434082031, 3681.5378417969, 27.119686126709),
            }
        },
        Reader = vec4(3558.5319824219, 3680.9064941406, 28.495389938354, -10.0)
    },
    {
        Key = 'labdoor7',
        Double = {
            {
                Model = 161378502,
                Coords = vec3(3567.6364746094, 3684.287109375, 27.117874145508),
            },
            {
                Model = -1572101598,
                Coords = vec3(3565.0720214844, 3684.7399902344, 27.117870330811),
            }
        },
        Reader = vec4(3567.9033203125, 3684.1064453125, 28.46, -10.0)
    },
    {
        Key = 'exit',
        Double = {
            {
                Model = -1081024910,
                Coords = vec3(3627.7131347656, 3746.7163085938, 27.690086364746),
            },
            {
                Model = -1081024910,
                Coords = vec3(3620.8427734375, 3751.5270996094, 27.69207572937),
            }
        }
    }
}

return Config