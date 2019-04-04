local Keys = {
    ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
    ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
    ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
    ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

-- internal variables
ESX                             = nil
local other_ped_attacked        = nil
local ped                       = nil
local isDead                    = nil
local objCoords                 = nil
local PlayerData                = {}
local GUI                       = {}
local model                     = {}
local Licenses                  = {}
local animation                 = {}
local object                    = {}
local getball                   = false
local IsHavingAnimal            = false
local IsHavingLicenses          = false
local attacking                 = false
local ordre                     = false
local isAttached                = false
local inanimation               = false
local balle                     = false
local status                    = 100
local come                      = 0
GUI.Time                        = 0

Citizen.CreateThread(function()

    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end

    Citizen.Wait(5000)
	DoRequestModel(-1788665315) -- chien
	DoRequestModel(1462895032)  -- chat
	DoRequestModel(1682622302)  -- loup
	DoRequestModel(-541762431)  -- lapin
	DoRequestModel(1318032802)  -- husky
	DoRequestModel(-1323586730) -- cochon
	DoRequestModel(1125994524)  -- caniche
	DoRequestModel(1832265812)  -- carlin
	DoRequestModel(882848737)   -- retriever
	DoRequestModel(1126154828)  -- berger
	DoRequestModel(-1384627013) -- westie
	DoRequestModel(351016938)   -- rottweiler

end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer

    ESX.TriggerServerCallback('eden_animal:animalName', function(data)
        if data ~= nil then
            IsHavingAnimal = true
        end
    end)

    ESX.TriggerServerCallback('eden_animal:animalLicenses', function(data)
        if data ~= nil then
            IsHavingLicenses = true
        end
    end)

    ESX.TriggerServerCallback('eden_animal:dead', function(data)
        if data ~= nil then
            isDead = true
        end
    end)

    ESX.TriggerServerCallback('eden_animal:status', function(data)

        if data ~= nil then
            data = data
        end
    end)

    ESX.TriggerServerCallback("esx_streetvendor:getSteamId", function(steamId)
        SteamID = steamId
    end)

end)

function OpenPetMenu()

    local health        = GetEntityHealth(ped) / 2.0
    local LocalisDead   = false

    ESX.TriggerServerCallback('eden_animal:animalName', function(data)
        if data ~= nil  then
            IsHavingAnimal = true
        end
    end)

    ESX.TriggerServerCallback('eden_animal:dead', function(data)
        if data ~= nil then
            isDead = true
            LocalisDead = true
        end
    end)

    ESX.TriggerServerCallback('eden_animal:animalLicenses', function(data)
        if data ~= nil then
            IsHavingLicenses = true
        end
    end)

    ESX.TriggerServerCallback('eden_animal:status', function(data)
        if data ~= nil then
            status = data
        end
    end)

    local elements = {}

    if come == 1 and status ~= nil then

        table.insert(elements, {label = _U('hunger') .. status .. '%', value = nil})
        table.insert(elements, {label = _U('life') .. health .. '%', value = nil})
        table.insert(elements, {label = _U('givefood'), value = 'graille'})
        table.insert(elements, {label = _U('attachpet'), value = 'attached_animal'})

        if isInVehicle then
            table.insert(elements, {label = _U('getpetdown'), value = 'vehicules'})
        else
            table.insert(elements, {label = _U('getpetinside'), value = 'vehicules'})
        end

        if ordre then
            table.insert(elements, {label = _U('giveorders'), value = 'ordres'})
        end

        table.insert(elements, {label = _U('come_back'), value = 'come_back'})
        table.insert(elements, {label = _U('doghouse'), value = 'niche'})
    else
        table.insert(elements, {label = _U('callpet'), value = 'come_animal'})
    end

    ESX.UI.Menu.CloseAll()

    ESX.UI.Menu.Open(
        'default', GetCurrentResourceName(), 'eden_animal',
        {
            title    = _U('pet_management'),
            align    = 'top-left',
            elements = elements,
        },
        function(data, menu)
            if data.current.value == 'come_animal' and come == 0 and LocalisDead == false then

                ESX.TriggerServerCallback('eden_animal:animalName', function(pet)
                    if (pet == "chien") then
                        model = -1788665315
                        come = 1
                        ordre = true
                        openchien()
                    elseif (pet == "chat") then
                        model = 1462895032
                        come = 1
                        ordre = true
                        openchien()
                    elseif (pet == "singe") then
                        model = -1469565163
                        ordre = false
                        come = 1
                        openchien()
                    elseif (pet == "loup") then
                        model = 1682622302
                        come = 1
                        ordre = true
                        openchien()
                    elseif (pet == "lapin") then
                        model = -541762431
                        come = 1
                        ordre = false
                        openchien()
                    elseif (pet == "husky") then
                        model = 1318032802
                        come = 1
                        ordre = true
                        openchien()
                    elseif (pet == "cochon") then
                        model = -1323586730
                        come = 1
                        ordre = false
                        openchien()
                    elseif (pet == "caniche") then
                        model = 1125994524
                        come = 1
                        ordre = false
                        openchien()
                    elseif (pet == "carlin") then
                        model = 1832265812
                        come = 1
                        ordre = true
                        openchien()
                    elseif (pet == "retriever") then
                        model = 882848737
                        come = 1
                        ordre = true
                        openchien()
                    elseif (pet == "berger") then
                        model = 1126154828
                        come = 1
                        ordre = false
                        openchien()
                    elseif (pet == "westie") then
                        model = -1384627013
                        come = 1
                        ordre = false
                        openchien()
                    elseif pet == 'rottweiler' then
                        model = 351016938
                        come = 1
                        ordre = true
                        openchien()
                    else

                        print('eden_animal: unknown pet ' .. pet)
                    end

                end)

                menu.close()

            elseif data.current.value == 'attached_animal' then

                if not IsPedSittingInAnyVehicle(ped) then

	                if isAttached == false then
		                attached()
		                isAttached = true
	                else
		                detached()
		                isAttached = false
                    end
                    
                else
                    ESX.ShowNotification(_U('dontattachhiminacar'))
                end

            elseif data.current.value == 'ordres' then

                GivePetOrders()
                menu.close()

            elseif data.current.value == 'graille' and status ~= nil then
                
                local count     = 0
                local inventory = ESX.GetPlayerData().inventory
                local coords1   = GetEntityCoords(PlayerPedId())
                local coords2   = GetEntityCoords(ped)
                local distance  = GetDistanceBetweenCoords(coords1, coords2, true)

                for i=1, #inventory, 1 do
                    if inventory[i].name == 'croquettes' then
                        count = inventory[i].count
                    end
                end

                if distance < 5 then
                    if count >= 1 then
                        if status < 100 then
                            
                            TriggerServerEvent('eden_animal:checkEat')
                            ESX.ShowNotification(_U('give_croquettes'))
                        
                        else
                            ESX.ShowNotification(_U('nomorehunger'))
                        end
                    
                    else
                        ESX.ShowNotification(_U('donthavefood'))
                    end

                    menu.close()
                else
                    ESX.ShowNotification(_U('hestoofar'))
                    menu.close()
                end

            elseif data.current.value == 'vehicules' then

                local playerPed = PlayerPedId()
                local coords    = GetEntityCoords(playerPed)
                local vehicle   = GetVehiclePedIsUsing(playerPed)
                local coords2   = GetEntityCoords(ped)
                local distance  = GetDistanceBetweenCoords(coords, coords2, true)

                if not isInVehicle then

                    if IsPedSittingInAnyVehicle(playerPed) then

                        if distance < 8 then
                            
							attached()
                            Wait(200)
                            
							if IsVehicleSeatFree(vehicle, 1) then
								SetPedIntoVehicle(ped, vehicle, 1)
								isInVehicle = true
							elseif IsVehicleSeatFree(vehicle, 2) then
								isInVehicle = true
								SetPedIntoVehicle(ped, vehicle, 2)
							elseif IsVehicleSeatFree(vehicle, 0) then
								isInVehicle = true
								SetPedIntoVehicle(ped, vehicle, 0)
							end

							TaskWarpPedIntoVehicle(ped, vehicle, -2)
							menu.close()
						else
						    ESX.ShowNotification(_U('toofarfromcar'))
                        end
                        
					else
						ESX.ShowNotification(_U('youneedtobeincar'))
                    end

                else

                    if not IsPedSittingInAnyVehicle(playerPed) then
                        
                        SetEntityCoords(ped, coords, 1, 0, 0, 1)
	                    Wait(100)
	                    detached()
	                    isInVehicle = false
						menu.close()

                    else
					    ESX.ShowNotification(_U('yourstillinacar'))
					end
                
                end

            elseif data.current.value == 'come_back' then

                local playerPed     = PlayerPedId()
				local GroupHandle   = GetPlayerGroup(PlayerId())
                local coords        = GetEntityCoords(GetPlayerPed(-1))
                
                TaskGoToCoordAnyMeans(ped, coords, 5.0, 0, 0, 786603, 0xbf800000)
                SetGroupSeparationRange(GroupHandle, 999999.9)
                TaskFollowToOffsetOfEntity(ped, playerPed, 0.5, 0.0, 0.0, 5.0, -1, 0.0, 1)
                SetPedAsGroupMember(ped, GroupHandle)
                FreezeEntityPosition(ped, false)

                menu.close()
            elseif data.current.value == 'niche' then

                local playerPed     = PlayerPedId()
				local GroupHandle   = GetPlayerGroup(PlayerId())
                local coords        = GetEntityCoords(playerPed)
                
                TaskGoToCoordAnyMeans(ped, coords, 5.0, 0, 0, 786603, 0xbf800000)
                SetGroupSeparationRange(GroupHandle, 999999.9)

                menu.close()
                Wait(15000)

                SetEntityCoords(ped, -4432.4321, -5643.3969, 999, true, true, true, true)
                ped = nil
				come = 0
            end

        end,
        
        function(data, menu)
            menu.close()
        end

    )

end

function GivePetOrders()

    ESX.TriggerServerCallback('eden_animal:animalName', function(pet)
        local elements = {}

        if not inanimation then

        if pet ~= 'chat' then
			table.insert(elements, {label = _U('balle'), value = 'balle'})
		end

		table.insert(elements, {label = _U('pied'),     value = 'pied'})
		table.insert(elements, {label = _U('doghouse'), value = 'return_doghouse'})

		if pet == 'chien' or pet == 'husky' then
			table.insert(elements, {label = _U('sitdown'), value = 'assis'})
            table.insert(elements, {label = _U('getdown'), value = 'coucher'})
            table.insert(elements, {label = _U('tricks'), value = 'tricks'})
            table.insert(elements, {label = _U('jump'), value = 'jump'})
		elseif pet == 'chat' then
			table.insert(elements, {label = _U('getdown'), value = 'coucher2'})
		elseif pet == 'loup' then
			table.insert(elements, {label = _U('getdown'), value = 'coucher3'})
		elseif pet == 'carlin' then
			table.insert(elements, {label = _U('sitdown'), value = 'assis2'})
		elseif pet == 'retriever' then
			table.insert(elements, {label = _U('sitdown'), value = 'assis3'})
		elseif pet == 'rottweiler' then
			table.insert(elements, {label = _U('sitdown'), value = 'assis4'})
		end
        
    else
	    table.insert(elements, {label = _U('getup'), value = 'debout'})
	end

    ESX.UI.Menu.CloseAll()
    ESX.UI.Menu.Open(
        'default', GetCurrentResourceName(), 'give_orders',
        {
            title    = _U('pet_orders'),
            align    = 'top-left',
            elements = elements,

        },
        function(data, menu)

            if data.current.value == 'return_doghouse' then

				local GroupHandle = GetPlayerGroup(PlayerId())
				local coords      = GetEntityCoords(PlayerPedId())

				ESX.ShowNotification(_U('doghouse_returning'))

				SetGroupSeparationRange(GroupHandle, 1.9)
				SetPedNeverLeavesGroup(ped, false)
				TaskGoToCoordAnyMeans(ped, coords.x + 40, coords.y, coords.z, 5.0, 0, 0, 786603, 0xbf800000)

				Citizen.Wait(5000)
				DeleteEntity(ped)
				come = 0

				ESX.UI.Menu.CloseAll()
            elseif data.current.value == 'pied' then
                
				local coords = GetEntityCoords(PlayerPedId())
				TaskGoToCoordAnyMeans(ped, coords, 5.0, 0, 0, 786603, 0xbf800000)
                menu.close()
                
            elseif data.current.value == 'balle' then
                
				local pedCoords = GetEntityCoords(ped)
				object = GetClosestObjectOfType(pedCoords, 190.0, GetHashKey('w_am_baseball'))

				if DoesEntityExist(object) then
					balle = true
					objCoords = GetEntityCoords(object)
					TaskGoToCoordAnyMeans(ped, objCoords, 5.0, 0, 0, 786603, 0xbf800000)
					local GroupHandle = GetPlayerGroup(PlayerId())
					SetGroupSeparationRange(GroupHandle, 1.9)
					SetPedNeverLeavesGroup(ped, false)
					menu.close()
				else
					ESX.ShowNotification(_U('noball'))
                end
  
            elseif data.current.value == 'assis' then -- [chien ]
            
                DoRequestAnimSet('creatures@rottweiler@amb@world_dog_sitting@base')
                TaskPlayAnim( ped, 'creatures@rottweiler@amb@world_dog_sitting@base', 'base' ,8.0, -8, -1, 1, 0, false, false, false )
                inanimation = true
                menu.close()

            elseif data.current.value == 'coucher' then

                DoRequestAnimSet('creatures@rottweiler@amb@sleep_in_kennel@')
                TaskPlayAnim( ped, 'creatures@rottweiler@amb@sleep_in_kennel@', 'sleep_in_kennel' ,8.0, -8, -1, 1, 0, false, false, false )
                inanimation = true
                menu.close()

            elseif data.current.value == 'tricks' then
                
                DoRequestAnimSet('creatures@rottweiler@tricks@')
                TaskPlayAnim( ped, 'creatures@rottweiler@tricks@', 'beg_enter' ,8.0, -8, -1, 0, 0, false, false, false )
                inanimation = true
                menu.close()

            elseif data.current.value == 'jump' then

                DoRequestAnimSet('creatures@retriever@melee@base@')
                TaskPlayAnim( ped, 'creatures@retriever@melee@base@', 'hit_from_back' ,8.0, -8, -1, 0, 0, false, false, false )
                inanimation = true
                menu.close()

            elseif data.current.value == 'coucher2' then -- [chat ]

                DoRequestAnimSet('creatures@cat@amb@world_cat_sleeping_ground@idle_a')
                TaskPlayAnim( ped, 'creatures@cat@amb@world_cat_sleeping_ground@idle_a', 'idle_a' ,8.0, -8, -1, 1, 0, false, false, false )
                inanimation = true
                menu.close()

            elseif data.current.value == 'coucher3' then -- [loup ]

                DoRequestAnimSet('creatures@coyote@amb@world_coyote_rest@idle_a')
                TaskPlayAnim( ped, 'creatures@coyote@amb@world_coyote_rest@idle_a', 'idle_a' ,8.0, -8, -1, 1, 0, false, false, false )
                inanimation = true
                menu.close()

            elseif data.current.value == 'assis2' then -- [carlin ]
                
                DoRequestAnimSet('creatures@carlin@amb@world_dog_sitting@idle_a')
                TaskPlayAnim( ped, 'creatures@carlin@amb@world_dog_sitting@idle_a', 'idle_b' ,8.0, -8, -1, 1, 0, false, false, false )
                inanimation = true
                menu.close()

            elseif data.current.value == 'assis3' then -- [retriever ]
                
                DoRequestAnimSet('creatures@retriever@amb@world_dog_sitting@idle_a')
                TaskPlayAnim( ped, 'creatures@retriever@amb@world_dog_sitting@idle_a', 'idle_c' ,8.0, -8, -1, 1, 0, false, false, false )
                inanimation = true
                menu.close()

            elseif data.current.value == 'assis4' then -- [rottweiler ]

				DoRequestAnimSet('creatures@rottweiler@amb@world_dog_sitting@idle_a')
				TaskPlayAnim(ped, 'creatures@rottweiler@amb@world_dog_sitting@idle_a', 'idle_c' ,8.0, -8, -1, 1, 0, false, false, false)
				inanimation = true
                menu.close()
            
            elseif data.current.value == 'debout' then

                ClearPedTasks(ped)
                inanimation = false
                menu.close()
            end

            menu.close()
        end,
    
        function(data, menu)
            menu.close()
        end)

    end)
    
end

function attached()

    local GroupHandle = GetPlayerGroup(PlayerId())
	SetGroupSeparationRange(GroupHandle, 1.9)
	SetPedNeverLeavesGroup(ped, false)
    FreezeEntityPosition(ped, true)
    
end

function detached()

    local GroupHandle = GetPlayerGroup(PlayerId())
	SetGroupSeparationRange(GroupHandle, 999999.9)
	SetPedNeverLeavesGroup(ped, true)
	SetPedAsGroupMember(ped, GroupHandle)
    FreezeEntityPosition(ped, false)

end

function DisplayHelpText(str)

    SetTextComponentFormat("STRING")
    AddTextComponentString(str)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)

end

function openchien()
    local playerPed     = GetPlayerPed(-1)
    local LastPosition  = GetEntityCoords(GetPlayerPed(-1))
    local GroupHandle   = GetPlayerGroup(PlayerId())

    DoRequestAnimSet('rcmnigel1c')
    TaskPlayAnim(GetPlayerPed(-1), 'rcmnigel1c', 'hailing_whistle_waive_a', 8.0, -8, -1, 120, 0, false, false, false)

    SetTimeout(5000, function()

        if ped == nil then

            ped = CreatePed(28, model, LastPosition.x +1, LastPosition.y +1, LastPosition.z -1, 1, 1)

            SetPedAsGroupLeader(playerPed, GroupHandle)
            SetPedAsGroupMember(ped, GroupHandle)
            SetPedNeverLeavesGroup(ped, true)
            SetPedCanBeTargetted(ped, false)
            SetEntityAsMissionEntity(ped, true,true)
            attacking = false

        end

    end)

end

function OpenPetShop()

    local elements = {
        {label = _U('buyCroquette') .. '- <span style="color:green;">$70</span>',   value = 'buyCroquette'},
        {label = _U('buyBall') .. '- <span style="color:green;">$30</span>',        value = 'buyBall'},
        {label = _U('buyLiscence') .. '- <span style="color:green;">$100000</span>',    value = 'buyLiscence'},
    }

    if IsHavingAnimal == false then
        table.insert(elements, {label = _U('dog') .. '- <span style="color:green;">$2400</span>',        value = "chien",    price = 2400})
        table.insert(elements, {label = _U('cat') .. '- <span style="color:green;">$1250</span>',        value = "chat",     price = 1250})
        table.insert(elements, {label = _U('monkey') .. '- <span style="color:green;">$8000</span>',     value = "singe",    price = 8000})
        table.insert(elements, {label = _U('wolf') .. '- <span style="color:green;">$30000</span>',      value = "loup",     price = 30000})
        table.insert(elements, {label = _U('bunny') .. '- <span style="color:green;">$150</span>',       value = "lapin",    price = 150})
        table.insert(elements, {label = _U('husky') .. '- <span style="color:green;">$3200</span>',      value = "husky",    price = 3200})
        table.insert(elements, {label = _U('pig') .. '- <span style="color:green;">$10000</span>',       value = "cochon",   price = 10000})
        table.insert(elements, {label = _U('poodle') .. '- <span style="color:green;">$3500</span>',     value = "caniche",  price = 3500})
        table.insert(elements, {label = _U('pug') .. '- <span style="color:green;">$1900</span>',        value = "carlin",   price = 1900})
        table.insert(elements, {label = _U('retriever') .. '- <span style="color:green;">$2100</span>',  value = "retriever",price = 2100})
        table.insert(elements, {label = _U('asatian') .. '- <span style="color:green;">$2000</span>',    value = "berger",   price = 2000})
        table.insert(elements, {label = _U('westie') .. '- <span style="color:green;">$3150</span>',     value = "westie",   price = 3150})
    end


    if isDead ~= nil then
        table.insert(elements, {label = _U('revive_pet') .. '- <span style="color:green;">$1000</span>',         value = "revive_pet",})
    end

    if SteamID == Config.SteamID then
        table.insert(elements, {label = '<span style="color:blue;"><------------ Gestion ------------></span>', value = nil,})
        table.insert(elements, {label = _U('amount'),             			                                    value = "getBalance",})
        table.insert(elements, {label = _U('all_remove'),             			                                value = "RemoveBalance",})
    end

    ESX.UI.Menu.Open(
    'default', GetCurrentResourceName(), 'animalerie',
    {
        title    = _U('pet_shop2'),
        align 	 = 'top-left',
        elements = elements
    },
    function(data, menu)

        if data.current.value == 'buyCroquette' then
            TriggerServerEvent('eden_animal:buyCroquette')
            menu.close()
        elseif data.current.value == 'buyBall' then
            TriggerServerEvent('eden_animal:buyBall')
            menu.close()
        elseif data.current.value == 'buyLiscence' then
            TriggerServerEvent('eden_animal:buyLiscence')
            menu.close()
        elseif data.current.value == 'revive_pet' then
            TriggerServerEvent('eden_animal:revive')
            menu.close()
        elseif data.current.value == 'getBalance' then
            TriggerServerEvent('eden_animal:getBalance')
            menu.close()
        elseif  data.current .value =='RemoveBalance' then
            TriggerServerEvent('eden_animal:RemoveBalance')
            menu.close()
        else
            TriggerServerEvent('eden_animal:takeAnimal', data.current.value, data.current.price)
            menu.close()
        end
    end)
end

function DoRequestModel(model)
	RequestModel(model)
	while not HasModelLoaded(model) do
		Citizen.Wait(1)
	end
end

function DoRequestAnimSet(anim)
	RequestAnimDict(anim)
	while not HasAnimDictLoaded(anim) do
		Citizen.Wait(1)
	end
end

Citizen.CreateThread(function()

    while true do
        Citizen.Wait(0)

        if ped ~= nil and GetEntityHealth(ped) <= 0 then

            TriggerServerEvent('eden_animal:isDead')
            ESX.ShowNotification(_U('pet_dead'))

            ped     = nil
            isDead  = true
            come    = 0

            Citizen.Wait(120000)
            SetEntityCoords(ped, -4432.4321, -5643.3969, 999, true, true, true, true)
        end

        if status == 10 then
            ESX.ShowNotification(_U('have_angry'))
        end

        if status == 0 then
            SetEntityHealth(ped, 0)
            TriggerServerEvent('eden_animal:isDead')
        end

    end

end)

-- Key Controls
Citizen.CreateThread(function()

    while true do
        Citizen.Wait(0)

		if IsControlPressed(0, Keys['F9']) and GetLastInputMethod(2) and IsHavingAnimal and not ESX.UI.Menu.IsOpen('default', GetCurrentResourceName(), 'pet_menu') and (GetGameTimer() - GUI.Time) > 150 then

            TriggerServerEvent('eden_animal:checkEat')
            Citizen.Wait(500)
            OpenAnimal()
            GUI.Time = GetGameTimer()
        
        end

        if IsControlJustPressed(0, Keys['F10']) and GetLastInputMethod(2) and not ESX.UI.Menu.IsOpen('default', GetCurrentResourceName(), 'pet_menu') then
            
            if ped ~= nil then
                TriggerEvent("eden_animal:Attack")
            end

        end

    end

end)

Citizen.CreateThread(function()

	while true do
        Citizen.Wait(0)
        
        local coord = GetEntityCoords(PlayerPedId())

        if GetDistanceBetweenCoords(coord, Config.Zones.PetShop.Pos.x, Config.Zones.PetShop.Pos.y, Config.Zones.PetShop.Pos.z, true) < 2 then
            
            ESX.ShowHelpNotification(_U('enterkey'))
            
            if IsControlJustPressed(0, Keys['E']) then
                TriggerEvent('eden_animal:checkDead')
                OpenPetShop()
            end

        else
			Citizen.Wait(500)
        end

    end

end)

Citizen.CreateThread(function()

    while true do
        Citizen.Wait(0)

        local coords      = GetEntityCoords(GetPlayerPed(-1))
        local isInMarker  = false
        local currentZone = nil

        for k,v in pairs(Config.Zones) do
            if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < v.Size.x) then
                isInMarker  = true
                currentZone = k
            end
        end

        if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
            HasAlreadyEnteredMarker = true
            LastZone                = currentZone
            TriggerEvent('eden_animal:hasEnteredMarker', currentZone)
        end

        if not isInMarker and HasAlreadyEnteredMarker then
            HasAlreadyEnteredMarker = false
            TriggerEvent('eden_animal:hasExitedMarker', LastZone)
        end
    end
end)

-- Create Blips
Citizen.CreateThread(function()
	local blip = AddBlipForCoord(Config.Zones.PetShop.Pos.x, Config.Zones.PetShop.Pos.y, Config.Zones.PetShop.Pos.z)

	SetBlipSprite (blip, Config.Zones.PetShop.Sprite)
	SetBlipDisplay(blip, Config.Zones.PetShop.Display)
	SetBlipScale  (blip, Config.Zones.PetShop.Scale)
	SetBlipAsShortRange(blip, true)

	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(_U('pet_shop'))
	EndTextCommandSetBlipName(blip)
end)


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local coords = GetEntityCoords(GetPlayerPed(-1))

        for k,v in pairs(Config.Zones) do
            if(v.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance) then
                DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, v.Color.r, v.Color.g, v.Color.b, 100, false, true, 2, false, false, false, false)
            end

        end

    end

end)

Citizen.CreateThread(function()

    while true do
        Citizen.Wait(30)

        if balle == true then

            local coords1   = GetEntityCoords(GetPlayerPed(-1))
            local coords2   = GetEntityCoords(ped)
            local distance  = GetDistanceBetweenCoords(objCoords, coords2, true)
            local distance2 = GetDistanceBetweenCoords(coords1, coords2, true)

            if distance < 0.5 then
                
                AttachEntityToEntity(object, ped, GetPedBoneIndex(ped, 17188), 0.120, 0.010, 0.010, 5.0, 150.0, 0.0, true, true, false, true, 1, true)
                TaskGoToCoordAnyMeans(ped, coords1, 5.0, 0, 0, 786603, 0xbf800000)

                balle = false
                getball = true

            end

        elseif getball == true then

            local coords1       = GetEntityCoords(GetPlayerPed(-1))
            local coords2       = GetEntityCoords(ped)
            local distance2     = GetDistanceBetweenCoords(coords1, coords2, true)
            local GroupHandle   = GetPlayerGroup(PlayerId())

            if distance2 < 1.5 then

                DetachEntity(object,false,false)
                Wait(50)
                SetEntityAsMissionEntity(object)
                DeleteEntity(object)
                GiveWeaponToPed(GetPlayerPed(-1), GetHashKey("WEAPON_BALL"), 1, false, true)
                SetGroupSeparationRange(GroupHandle, 999999.9)
                TaskFollowToOffsetOfEntity(ped, GetPlayerPed(PlayerId()), 0.5, 0.0, 0.0, 5.0, -1, 0.0, 1)
                SetPedAsGroupMember(ped, GroupHandle)
                getball = false
            end

        end

    end

end)

AddEventHandler('eden_animal:hasExitedMarker', function(zone)
    CurrentAction = nil
    ESX.UI.Menu.CloseAll()
end)

RegisterNetEvent('eden_animal:addLicenseAttack')
AddEventHandler('eden_animal:addLicenseAttack', function()

    ESX.TriggerServerCallback('eden_animal:animalLicenses', function(data)
    
        if data ~= nil then
            IsHavingLicenses = true
        end

    end)

end)

RegisterNetEvent('eden_animal:checkDead')
AddEventHandler('eden_animal:checkDead', function()

    ESX.TriggerServerCallback('eden_animal:dead', function(data)
        
        if data ~= nil then
            isDead = true
        end

    end)

end)

RegisterNetEvent('eden_animal:havingPed')
AddEventHandler('eden_animal:havingPed', function()

    ESX.TriggerServerCallback('eden_animal:animalName', function(data)
        
        if data ~= nil then
            IsHavingAnimal = true
        end

    end)

end)

RegisterNetEvent('eden_animal:instance')
AddEventHandler('eden_animal:instance', function()

    SetEntityAsNoLongerNeeded(ped)
    SetEntityCoords(ped, -4432.4321, -5643.3969, 999, true, true, true, true)
    ped = nil
    come = 0

end)

RegisterNetEvent('eden_animal:liscenseAddItem')
AddEventHandler('eden_animal:liscenseAddItem', function()

    ESX.TriggerServerCallback('eden_animal:animalName', function(data)

        if data ~= nil then
            IsHavingAnimal = true
        end

    end)

    ESX.TriggerServerCallback('eden_animal:animalLicenses', function(data)

        if data ~= nil then
            IsHavingLicenses = true
        end

    end)

    if IsHavingAnimal then
        TriggerServerEvent('eden_animal:itemLiscense')
        ESX.ShowNotification('Vous venez d\'obetenir une liscense d\'attaque')
    else
        ESX.ShowNotification('~r~Nous n\'avez pas d\'animaux')
    end

end)

RegisterNetEvent("eden_animal:Attack")
AddEventHandler("eden_animal:Attack", function()

    TriggerServerEvent('eden_animal:checkEat')

	local bool, other_ped = GetEntityPlayerIsFreeAimingAt(PlayerId())
    other_ped_attacked = other_ped

    if IsHavingLicenses == true then

        if attacking == false then

            if IsEntityAPed(other_ped) then

                if not IsEntityDead(other_ped) then

                    ClearPedTasks(ped)
                    Wait(250)
                    SetCanAttackFriendly(ped, true, true)
                    TaskPutPedDirectlyIntoMelee(ped, other_ped, 0.0, -1.0, 0.0, 0)
                    other_ped_attacked = other_ped
                    attacking = true
                    TriggerServerEvent('eden_animal:logs')

                else
                    SetCanAttackFriendly(ped, false, false)
                end

            end

        else
            attacking = false
            other_ped_attacked = nil
            TaskFollowToOffsetOfEntity(ped, GetPlayerPed(PlayerId()), 0.5, 0.0, 0.0, 5.0, -1, 0.0, 1)
            SetGroupSeparationRange(GroupHandle, 999999.9)
            SetPedAsGroupMember(ped, GroupHandle)
        end

    else
        ESX.ShowNotification(_U('dont_have_licenses'))
    end

end)
