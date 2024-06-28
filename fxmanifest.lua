--[[ FX Information ]]--
fx_version   'cerulean'
lua54        'yes'
game         'gta5'

--[[ Resource Information ]]--
name         'fun-trucker'
author       'funes781'
version      '1.0.0'
description  "[ESX] Trucker Job"

--[[ Manifest ]]--


shared_scripts {
    'locales/strings.lua',
    'shared/*.lua',
    '@ox_lib/init.lua',
}

server_script {
    'server/*.lua',
}

client_scripts { 
    'client/*.lua',
}
