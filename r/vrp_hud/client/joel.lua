

local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")

cRP = {}
Tunnel.bindInterface("vrp_hud",cRP)
vSERVER = Tunnel.getInterface("vrp_garages")

onInt = false
local hour = 0
local voice = 2
local minute = 0
local month = ""
local hunger = 100
local thirst = 100
local dayMonth = 0
local varDay = "th"
local showHud = true
local showMovie = false
local showRadar = false
local sBuffer = {}
local seatbelt = false
local ExNoCarro = false
local timedown = 0
local talking = false

local menu_celular = false
RegisterNetEvent("status:celular")
AddEventHandler("status:celular",function(status)
	menu_celular = status
end)

function calculateTimeDisplay()
	hour = GetClockHours()
	month = GetClockMonth()
	minute = GetClockMinutes()
	dayMonth = GetClockDayOfMonth()

	if hour <= 9 then
		hour = "0"..hour
	end

	if minute <= 9 then
		minute = "0"..minute
	end

	if month == 0 then
		month = "January"
	elseif month == 1 then
		month = "February"
	elseif month == 2 then
		month = "March"
	elseif month == 3 then
		month = "April"
	elseif month == 4 then
		month = "May"
	elseif month == 5 then
		month = "June"
	elseif month == 6 then
		month = "July"
	elseif month == 7 then
		month = "August"
	elseif month == 8 then
		month = "September"
	elseif month == 9 then
		month = "October"
	elseif month == 10 then
		month = "November"
	elseif month == 11 then
		month = "December"
	end
end

-- RegisterNetEvent("vrp_hud:Tokovoip")
-- AddEventHandler("vrp_hud:Tokovoip",function(status)
-- 	voice = status
-- end)

-- RegisterNetEvent("vrp_hud:TokovoipTalking")
-- AddEventHandler("vrp_hud:TokovoipTalking",function(status)
-- 	talking = status
-- end)

-- RegisterNetEvent("statusFome")
-- AddEventHandler("statusFome",function(number)
-- 	hunger = parseInt(number)
-- end)

-- RegisterNetEvent("statusSede")
-- AddEventHandler("statusSede",function(number)
-- 	thirst = parseInt(number)
-- end)

RegisterNetEvent("hudActived")
AddEventHandler("hudActived",function()
	showHud = true
end)

Citizen.CreateThread(function()
	while true do
		if IsPauseMenuActive() or IsScreenFadedOut() or menu_celular then
			SendNUIMessage({ hud = false, movie = false })
		else
			local ped = PlayerPedId()
			local armour = GetPedArmour(ped)
			local health = (GetEntityHealth(GetPlayerPed(-1))-100)/300*100
			local stamina = GetPlayerSprintStaminaRemaining(PlayerId())
			nsei,baixo,alto = GetVehicleLightsState(GetVehiclePedIsIn(PlayerPedId()))
			local x,y,z = table.unpack(GetEntityCoords(ped))
			local street = GetStreetNameFromHashKey(GetStreetNameAtCoord(x,y,z))

			calculateTimeDisplay()

			if dayOfMonth == 1 then
				varDay = "st"
			elseif dayOfMonth == 2 then
				varDay = "nd"
			elseif dayOfMonth == 3 then
				varDay = "rd"
			else
				varDay = "th"
			end

			local ped = PlayerPedId()
			local car = GetVehiclePedIsIn(ped)

			if not showHud then 
				showRadar = false 
			end

			if IsPedOnAnyBike(ped) then
				showRadar = true
			end
			
			if not IsPedInAnyVehicle(ped) then 
				showRadar = false
				DisplayRadar(showRadar)
			end

			if baixo == 1 and alto == 0 then
				farol = 1
			elseif  alto == 1 then
				farol = 2
			else
				farol = 0
      		end

			if IsPedInAnyVehicle(ped) then
				showRadar = true
				local vehicle = GetVehiclePedIsIn(ped)

				local fuel = GetVehicleFuelLevel(vehicle)
				local enginehealth = GetVehicleEngineHealth(vehicle)
				local speed = GetEntitySpeed(vehicle) * 3.6

				SendNUIMessage({ hud = showHud, movie = showMovie, car = true, day = dayMonth..varDay, month = month, hour = hour, minute = minute, street = street, radio = radioDisplay, voice = voice, talking = talking, health = parseInt(health), armour = parseInt(armour), thirst = parseInt(thirst), hunger = parseInt(hunger), stamina = parseInt(stamina), fuel = parseInt(fuel), speed = parseInt(speed), seatbelt = seatbelt, farol = farol, enginehealth = enginehealth })
			else
				SendNUIMessage({ hud = showHud, movie = showMovie, car = false, day = dayMonth..varDay, month = month, hour = hour, minute = minute, street = street, radio = radioDisplay, voice = voice, talking = talking, health = parseInt(health), armour = parseInt(armour), thirst = parseInt(thirst), hunger = parseInt(hunger), stamina = parseInt(stamina) })
			end
		end

		Citizen.Wait(200)
	end
end)

RegisterCommand('seat', function(source, args, rawCmd)
	local ped = PlayerPedId()
	if IsPedInAnyVehicle(ped, false) then	
		local carrinhu = GetVehiclePedIsIn(ped, false)
		if not CintoSeguranca then
			if args[1] then
				local acento = parseInt(args[1])
				if acento == 1 then
					if IsVehicleSeatFree(carrinhu, -1) then 
						if GetPedInVehicleSeat(carrinhu, 0) == ped then
							SetPedIntoVehicle(ped, carrinhu, -1)
						else
							TriggerEvent('Notify', 'negado',"Negado", 'Você só pode passar para o P1 a partir do P2.')
						end
					else
						TriggerEvent('Notify', 'negado',"Negado", 'O acento deve estar livre.')
					end
				elseif acento == 2 then
					if IsVehicleSeatFree(carrinhu, 0) then 
						if GetPedInVehicleSeat(carrinhu, -1) == ped then
							SetPedIntoVehicle(ped, carrinhu, 0)
						else
							TriggerEvent('Notify', 'negado',"Negado", 'Você só pode passar para o P2 a partir do P1.')
						end
					else
						TriggerEvent('Notify', 'negado',"Negado", 'O acento deve estar livre.')
					end
				elseif acento == 3 then
					if IsVehicleSeatFree(carrinhu, 1) then 
						if GetPedInVehicleSeat(carrinhu, 2) == ped then
							SetPedIntoVehicle(ped, carrinhu, 1)
						else
							TriggerEvent('Notify', 'negado',"Negado", 'Você só pode passar para o P3 a partir do P4.')
						end
					else
						TriggerEvent('Notify', 'negado',"Negado", 'O acento deve estar livre.')
					end
				elseif acento == 4 then
					if IsVehicleSeatFree(carrinhu, 2) then 
						if GetPedInVehicleSeat(carrinhu, 1) == ped then
							SetPedIntoVehicle(ped, carrinhu, 2)
						else
							TriggerEvent('Notify', 'negado',"Negado", 'Você só pode passar para o P4 a partir do P3.')
						end
					else
						TriggerEvent('Notify', 'negado',"Negado", 'O acento deve estar livre.')
					end
				end
			else
				TriggerEvent('Notify', 'negado',"Negado", 'Especifique o acento que quer ir!')
			end
		else
			TriggerEvent('Notify', 'negado',"Negado", 'Você não pode utilizar esse comando com o cinto de segurança!')
		end
	end
end)

RegisterKeyMapping('hud:interact', 'Abrir menu de interação', 'keyboard', 'I')

RegisterCommand('hud:interact', function()
	local ped = PlayerPedId()
	if not IsPedInAnyVehicle(ped) then
		onInt = true
		SendNUIMessage({ interact = true })
		SetNuiFocus(true, true)
		TransitionToBlurred(1000)
	else
		TriggerEvent("Notify","negado","Você não pode abrir o menu em um veículo.")
	end
end)

RegisterNUICallback('hideFocus',function()
	SetNuiFocus(false, false)
	onInt = false
	TransitionFromBlurred(1000)
end)

RegisterNUICallback('hideHUD',function()
	TriggerEvent("bdl:triggerhud")
end)
-- /HUD
RegisterCommand("hud",function(source,args)
	TriggerEvent("bdl:triggerhud")
end)
-- HIDE HUD
RegisterNetEvent("bdl:triggerhud")
AddEventHandler("bdl:triggerhud",function()
	showHud =  not showHud
end)
-- /MOVIE
RegisterCommand("movie",function(source,args)
	showMovie = not showMovie
end)
-- CINTO
IsCar = function(veh)
	local vc = GetVehicleClass(veh)
	return (vc >= 0 and vc <= 7) or (vc >= 9 and vc <= 12) or (vc >= 15 and vc <= 20)
end

Citizen.CreateThread(function()
	while true do
		local timeDistance = 500
		local ped = PlayerPedId()
		local car = GetVehiclePedIsIn(ped)

		if car ~= 0 and (ExNoCarro or IsCar(car)) then
			ExNoCarro = true
			if seatbelt then
				DisableControlAction(0,75)
			end

			timeDistance = 4
			sBuffer[2] = sBuffer[1]
			sBuffer[1] = GetEntitySpeed(car)

			if sBuffer[2] ~= nil and not seatbelt and GetEntitySpeedVector(car,true).y > 1.0 and sBuffer[1] > 10.25 and (sBuffer[2] - sBuffer[1]) > (sBuffer[1] * 0.255) then
				SetEntityHealth(ped,GetEntityHealth(ped)-10)
				TaskLeaveVehicle(ped,GetVehiclePedIsIn(ped),4160)
				timedown = 10
			end

			if IsControlJustReleased(1,73) then
				if seatbelt then
					TriggerEvent("vrp_sound:source","unbelt",0.5)
					seatbelt = false
				else
					TriggerEvent("vrp_sound:source","belt",0.5)
					seatbelt = true
				end
			end

			if IsPedOnAnyBike(ped) then
				showRadar = true
			end

			if not seatbelt and not showHud then 
				showRadar = false
			end

		elseif ExNoCarro then
			ExNoCarro = false
			seatbelt = false
			sBuffer[1],sBuffer[2] = 0.0,0.0
		end
		DisplayRadar(showRadar)
		Citizen.Wait(timeDistance)
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		local ped = PlayerPedId()
		if timedown > 0 and GetEntityHealth(ped) > 101 then
			timedown = timedown - 1
			if timedown <= 1 then
				TriggerServerEvent("vrp_inventory:Cancel")
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		local ped = PlayerPedId()
		if timedown > 1 and GetEntityHealth(ped) > 101 then
			if not IsEntityPlayingAnim(ped,"anim@heists@ornate_bank@hostages@hit","hit_react_die_loop_ped_a",3) then
				vRP.playAnim(false,{"anim@heists@ornate_bank@hostages@hit","hit_react_die_loop_ped_a"},true)
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		local TimeDistance = 500
		if timedown > 0 then
			TimeDistance = 4
			DisableControlAction(0,288,true)
			DisableControlAction(0,289,true)
			DisableControlAction(0,170,true)
			DisableControlAction(0,187,true)
			DisableControlAction(0,189,true)
			DisableControlAction(0,190,true)
			DisableControlAction(0,188,true)
			DisableControlAction(0,57,true)
			DisableControlAction(0,105,true)
			DisableControlAction(0,167,true)
			DisableControlAction(0,20,true)
			DisableControlAction(0,29,true)
		end
		Citizen.Wait(TimeDistance)
	end
end)

--------------------------------------------------------------------------------------
-- ATENÇÃO! ESTE SISTEMA É GRATUITO, NÃO MONETIZE-O DE NENHUMA FORMA
-- BAIXE SEMPRE DO LINK AUTORIZADO! (https://github.com/rossinijs/bdl_newhud)
-- NENHUM DANO OU PREJUÍZO CAUSADO POR LINKS DE TERCEIROS É DE NOSSA RESPONSABILIDADE
-- DESENVOLVIDO POR rossiniJS (discord: Edu#0069)
--------------------------------------------------------------------------------------