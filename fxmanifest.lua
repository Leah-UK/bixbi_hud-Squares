--[[----------------------------------
Creation Date:	05/10/21
]]------------------------------------
fx_version 'cerulean'
game 'gta5'
author 'Leah#0001'
version '1.0'
versioncheck 'https://raw.githubusercontent.com/Leah-UK/bixbi_hud-Squares/main/bixbi_hud.lua'
lua54 'yes'

shared_scripts {
	'@es_extended/imports.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}

ui_page 'ui/index.html'
files {
    'ui/*.html',
    'ui/*.js',
    'ui/*.css',
}