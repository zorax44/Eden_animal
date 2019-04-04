ESX = nil
Pet = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

AddEventHandler('onMySQLReady', function()
	local result = MySQL.Sync.fetchAll('SELECT * FROM pet', {})
	Pet = {}

    for i = 1, #result, 1 do
		local current = result[i]
		
    	Pet[current.identifier] = {
    		identifier = current.identifier,
    		name = current.name,
			licenses = current.licenses,
			status = current.status,
			dead = current.dead
		};
	end
	
end)

function ReloadPet()
	local result = MySQL.Sync.fetchAll('SELECT * FROM pet', {})
	Pet = {}

    for i = 1, #result, 1 do
		local current = result[i]
		
    	Pet[current.identifier] = {
    		identifier = current.identifier,
    		name = current.name,
			licenses = current.licenses,
			status = current.status,
			dead = current.dead
		};
	end

end

ESX.RegisterServerCallback("esx_streetvendor:getSteamId", function(source, cb)
	local _source = source
	cb(GetPlayerIdentifiers(_source)[1])
end)

ESX.RegisterServerCallback("eden_animal:animalName", function(_source , cb)
	local source    = _source
	local xPlayer   = ESX.GetPlayerFromId(source)

	if (Pet[xPlayer.identifier] ~= nil) then
		cb(Pet[xPlayer.identifier].name)
	else
		cb(nil)
	end
end)

ESX.RegisterServerCallback("eden_animal:dead", function(_source , cb)
	local source    = _source
	local xPlayer   = ESX.GetPlayerFromId(source)

	if (Pet[xPlayer.identifier] ~= nil) then
		cb(Pet[xPlayer.identifier].dead)
	else
		cb(nil)
	end
end)

ESX.RegisterServerCallback("eden_animal:animalLicenses", function(_source , cb)
	local source    = _source
	local xPlayer   = ESX.GetPlayerFromId(source)

	if (Pet[xPlayer.identifier] ~= nil) then
		cb(Pet[xPlayer.identifier].licenses)
	else
		cb(nil)
	end
end)

ESX.RegisterServerCallback("eden_animal:status", function(_source , cb)
	local source   = _source
	local xPlayer  = ESX.GetPlayerFromId(source)

	if (Pet[xPlayer.identifier] ~= nil) then
		cb(Pet[xPlayer.identifier].status)
  	end
end)

RegisterServerEvent("eden_animal:checkEat")
AddEventHandler("eden_animal:checkEat", function()
	ReloadPet()
end)

RegisterServerEvent("eden_animal:isDead")
AddEventHandler("eden_animal:isDead", function()
    local _source        = source
    local xPlayer        = ESX.GetPlayerFromId(_source)

	MySQL.Async.execute('UPDATE pet SET dead = true WHERE identifier = @identifier', {
		['@identifier']    = xPlayer.identifier
	})

	Pet[xPlayer.identifier].dead = true
end)

RegisterServerEvent("eden_animal:revive")
AddEventHandler("eden_animal:revive", function()
    local _source        = source
	local xPlayer        = ESX.GetPlayerFromId(_source)
	local price 		 = 1000

	if xPlayer.get('money') >= price then

		xPlayer.removeMoney(price)

		MySQL.Async.execute('UPDATE pet SET dead = null WHERE identifier = @identifier', {
			['@identifier']    = xPlayer.identifier
		})

		Pet[xPlayer.identifier].dead = nil

		TriggerClientEvent('eden_animal:checkDead', _source)
		TriggerClientEvent('esx:showNotification', _source, ('Vous venez de recuprer votre animal pour ~g~' .. price ..'$'))

		TriggerEvent('esx_addonaccount:getSharedAccount', 'society_animal', function(account)
			account.addMoney(price)
		end)
	else
		TriggerClientEvent('esx:showNotification', _source, ('Vous n\'avez pas sufisement d\'argent'))
	end
end)

RegisterServerEvent('eden_animal:startHarvest')
AddEventHandler('eden_animal:startHarvest', function()
	local _source = source
	local xPlayer        = ESX.GetPlayerFromId(_source)

		xPlayer.removeInventoryItem('croquettes', 1)

		MySQL.Async.execute('UPDATE pet SET status = status + 15  WHERE identifier = @identifier', {
			['@identifier']    = xPlayer.identifier
		}
	)
end)

RegisterServerEvent('eden_animal:logs')
AddEventHandler('eden_animal:logs', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	print( xPlayer.name .. ' viens de faire attaquer son chien')
end)

RegisterServerEvent('eden_animal:buyCroquette')
AddEventHandler('eden_animal:buyCroquette', function()
	local _source 	= source
	local xPlayer 	= ESX.GetPlayerFromId(_source)
	local price 	  = 5
	local file      = io.open('logs/animal.txt', "a")
	local time      = os.date("%d/%m/%y %X")
	local newFile   = "".. xPlayer.name .. " viens d \'acheter : des croquettes pour " .. price .. "$ // " .. time .. "\n"

	if xPlayer.get('money') >= price then

		xPlayer.removeMoney(price)
		xPlayer.addInventoryItem('croquettes', 1)
		TriggerClientEvent('esx:showNotification', _source, ('Vous venez d\'acheter des corquettes pour ~g~' .. price ..'$'))
		file:write(newFile)
		file:flush()
		file:close()

		TriggerEvent('esx_addonaccount:getSharedAccount', 'society_animal', function(account)
			account.addMoney(price)
		end)
	else
		TriggerClientEvent('esx:showNotification', _source, ('Vous n\'avez pas sufisement d\'argent'))
	end
end)

RegisterServerEvent('eden_animal:buyBall')
AddEventHandler('eden_animal:buyBall', function()
	local _source	= source
	local xPlayer	= ESX.GetPlayerFromId(_source)
	local price 	= 10
	local file    = io.open('logs/animal.txt', "a")
	local time    = os.date("%d/%m/%y %X")
	local newFile = "".. xPlayer.name .. " viens d \'acheter : une balle d\'une valeur de " .. price .. "$ // " .. time .. "\n"

	if xPlayer.get('money') >= price then

		xPlayer.removeMoney(price)
		xPlayer.addWeapon("WEAPON_BALL", 1)
		TriggerClientEvent('esx:showNotification', _source, ('Vous venez d\'acheter une balle pour ~g~' .. price ..'$'))

		file:write(newFile)
		file:flush()
		file:close()

		TriggerEvent('esx_addonaccount:getSharedAccount', 'society_animal', function(account)
			account.addMoney(price)
		end)
	else
		TriggerClientEvent('esx:showNotification', _source, ('Vous n\'avez pas sufisement d\'argent'))
	end
end)

RegisterServerEvent('eden_animal:takeAnimal')
AddEventHandler('eden_animal:takeAnimal',function(animalName, price)

	local _source  = source
	local xPlayer  = ESX.GetPlayerFromId(source)
	local file     = io.open('logs/animal.txt', "a")
	local time     = os.date("%d/%m/%y %X")
	local newFile  = "".. xPlayer.name .. " viens d \'acheter : "  .. animalName .. " d\'une valeur de " .. price .. " $ // " .. time .. " \n"

	if xPlayer.get('money') >= price then

		xPlayer.removeMoney(price)

		TriggerEvent('esx_addonaccount:getSharedAccount', 'society_animal', function(account)
			account.addMoney(price)
		end)

		if Pet[xPlayer.identifier] == nil then
			MySQL.Async.execute('INSERT INTO pet (identifier, name, licenses, status) VALUES (@identifier, @name, @licenses, @status)', {
				['@identifier'] = xPlayer.identifier,
				['@name'] = animalName,
				['@licenses'] = nil,
				['@status'] = 100
			}, function(result)
			end)

			Pet[xPlayer.identifier] = {
				identifier = xPlayer.identifier,
				name = animalName,
				licenses = nil,
				status = 100,
				dead = nil
			};
		end

		TriggerClientEvent('esx:showNotification', _source, ('Vous venez d\'acheter un ' .. animalName .. ' pour ~g~ ' .. price.. ' $'))

		file:write(newFile)
		file:flush()
		file:close()
		TriggerClientEvent('eden_animal:havingPed', _source )
	else
		TriggerClientEvent('esx:showNotification', _source, ('Vous n\'avez pas sufisement d\'argent'))
	end
end)

RegisterServerEvent('eden_animal:buyLiscence')
AddEventHandler('eden_animal:buyLiscence',function()

	local _source 	= source
	local price 	= 100000
	local xPlayer  	= ESX.GetPlayerFromId(source)
	local file      = io.open('logs/animal.txt', "a")
	local time      = os.date("%d/%m/%y %X")
	local newFile   = "".. xPlayer.name .. " viens d \'acheter : une liscence d\'une valeur de " .. price .. " $ // " .. time .. " \n"

	if xPlayer.get('money') >= price then

		xPlayer.removeMoney(price)
		MySQL.Async.execute('UPDATE pet SET licenses = @attack WHERE identifier = @identifier',	{
			['@identifier']    = xPlayer.identifier,
			['@attack']    	   = true
		})

		Pet[xPlayer.identifier].licenses = true
		TriggerEvent('eden_animal:addLicenseAttack')
		TriggerEvent('esx_addonaccount:getSharedAccount', 'society_animal', function(account)
			account.addMoney(price)
		end)

		TriggerClientEvent('esx:showNotification', _source, ('Vous venez d\'acheter une license pour ~g~ ' .. price.. ' $'))
		TriggerClientEvent('esx:showNotification', _source, ('Appuyez sur ~b~F10~s~ tout en visant la cible pour que votre animal attaque'))

		file:write(newFile)
		file:flush()
		file:close()
	else
		TriggerClientEvent('esx:showNotification', _source, ('Vous n\'avez pas sufisement d\'argent'))
	end
end)

RegisterServerEvent('eden_animal:getBalance')
AddEventHandler('eden_animal:getBalance', function()

	TriggerEvent('esx_addonaccount:getSharedAccount', 'society_animal', function(account)

		local _source 		  = source
		local xPlayer         = ESX.GetPlayerFromId(source)
		local account 		  = account.money

		TriggerClientEvent('esx:showNotification', _source, ('Le solde du compte de votre entreprise est de : ~g~' .. account ..'$'))
	end)
end)

RegisterServerEvent('eden_animal:RemoveBalance')
AddEventHandler('eden_animal:RemoveBalance', function()

	TriggerEvent('esx_addonaccount:getSharedAccount', 'society_animal', function(account)
		local _source 		  = source
		local xPlayer         = ESX.GetPlayerFromId(source)
		local amount 		  = account.money

		account.removeMoney(amount)
		xPlayer.addMoney(amount)
		TriggerClientEvent('esx:showNotification', _source, ('Vous venez de retirer : ~g~' .. amount ..'$'))
	end)
end)

ESX.RegisterUsableItem('attacklisence', function(source)
	local _source  = source
	TriggerClientEvent('eden_animal:liscenseAddItem', _source)
end)

RegisterServerEvent('eden_animal:itemLiscense')
AddEventHandler('eden_animal:itemLiscense', function()

	local _source  = source
	local xPlayer  = ESX.GetPlayerFromId(source)

	MySQL.Async.execute('UPDATE pet SET licenses = @licenses WHERE identifier = @identifier', {
		['@identifier'] = xPlayer.identifier,
		['@licenses'] = true,
	}, function(result)
	end)

	Pet[xPlayer.identifier] = {
		identifier = xPlayer.identifier,
		licenses = true,
	};
end)

function UpdateSavePet()

	local xPlayers 	= ESX.GetPlayers()
	local UpdateEat = 10 -- In minutes

	for i=1, #xPlayers, 1 do

		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		local data    = {}

		MySQL.Async.execute('UPDATE pet SET status  = status - 5 WHERE identifier = @identifier', {
		 	['@identifier'] = xPlayer.identifier
		})
	end
	SetTimeout(UpdateEat * 60 * 1000, UpdateSavePet)
end

UpdateSavePet()
