fx_version 'cerulean'
game 'gta5'
use_fxv2_oal 'yes'

lua54 'yes'
author 'ManiMods'

client_scripts {
    'client/*.lua'
}

server_scripts {
    'open/server.lua',
    'server/*.lua'
}

shared_script '@jet-lib/init.lua'

files {
    'config.lua',
    'open/client.lua'
}