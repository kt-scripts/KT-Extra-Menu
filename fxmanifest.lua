fx_version 'cerulean'
game 'gta5'

name 'Vehicle Extra Menu'
description 'Livery and Extras Menu for Vehicles'
author 'Fabian'
version '1.0.0'

lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'locales/*.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/version.lua',
    'server/main.lua'
}

dependencies {
    'ox_lib'
}