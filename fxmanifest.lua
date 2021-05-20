fx_version 'adamant'

game 'gta5'

description 'MasterkinG32 HUD (Discord: MasterkinG32#9999) - (MasterCity.iR)'

version '1.0.0'

ui_page 'html/index.html'

client_scripts {
	'client/*.lua'
}

server_scripts {
	'server/main.lua',
	'server/config.lua'
}

files {
	'html/*.png',
	'html/*.gif',
	'html/*.css',
	'html/*.js',
	'html/*.svg',
	'html/*.ttf',
	'html/*.html',
}

dependency 'es_extended'
