fx_version 'cerulean'
game 'gta5'
use_fxv2_oal 'yes'

lua54 'yes'
author 'ManiMods'

client_scripts {
    'client/*.lua'
}

server_scripts {
    'server/*.lua'
}

shared_scripts {
    '@ox_lib/init.lua',
}

files {
    'config.lua',
}