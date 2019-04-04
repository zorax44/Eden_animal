resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

description 'Eden Animal'

version '1.4.0'

client_scripts {
	'@es_extended/locale.lua',
	'locale/fr.lua',
	'locale/en.lua',
	'locales/sv.lua',
	'locales/de.lua',
	'locales/es.lua',
	'locales/pl.lua',
	'config.lua',
	'client/main.lua'
}

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'@es_extended/locale.lua',
	'locale/fr.lua',
	'locale/en.lua',
	'locales/sv.lua',
	'locales/de.lua',
	'locales/es.lua',
	'locales/pl.lua',
	'config.lua',
	'server/main.lua'
}
