fx_version 'cerulean'
game 'gta5'

lua54 'yes'

author 'Zeraphis'
description 'Business Bell'
version '1.0.0'

shared_scripts {
  '@ox_lib/init.lua',
  'config.lua',
  'framework.lua'
}

client_scripts {
  'client/framework.lua',
  'client/main.lua'
}

server_scripts {
  'server/main.lua'
}
