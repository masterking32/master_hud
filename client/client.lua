ESX = nil
local food = 0
local thirst = 0
local isCarSeatRuned = false
local SeatBeltOn = false
local speedBuffer = {}
local velBuffer = {}
local showUI = true

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(100)
    end
end)

RegisterNetEvent("esx_status:onTick")
AddEventHandler("esx_status:onTick", function(status)
    TriggerEvent('esx_status:getStatus', 'hunger', function(status)
        food = status.val / 10000
    end)
	
    TriggerEvent('esx_status:getStatus', 'thirst', function(status)
        thirst = status.val / 10000
    end)
end)

function IsCarSeatSupport(veh)
  local vc = GetVehicleClass(veh)
  return (vc >= 0 and vc <= 7) or (vc >= 9 and vc <= 12) or (vc >= 17 and vc <= 20)
end

Citizen.CreateThread(function()
    while true do 
        Citizen.Wait(0)
		
        local IsInCar = false
		local speed = 0
		local speedwarn = false
        if IsPedSittingInAnyVehicle(PlayerPedId()) then
            IsInCar = true
			local pedVehicle = GetVehiclePedIsIn(PlayerPedId(), false)
			speed = math.ceil(GetEntitySpeed(pedVehicle) * 3.6)
			
			if speed > 100 then
				speedwarn = true
			end
			
			if isCarSeatRuned == false then
				isCarSeatRuned = true
				if IsCarSeatSupport(pedVehicle) then
					SeatCheck()
				else
					SeatBeltOn = false
				end
			end
		else
			isCarSeatRuned = false
			SeatBeltOn = false
        end
		
        SendNUIMessage({
            armour = GetPedArmour(PlayerPedId()),
            health = GetEntityHealth(PlayerPedId()) - 100,
            food = food,
            thirst = thirst,
			InCar = IsInCar,
			speed = speed,
			seat = SeatBeltOn,
			show = showUI,
			speedwarn = speedwarn
        })
		
		if IsInCar == false then
			Citizen.Wait(1000)
		else
			Citizen.Wait(100)
		end
    end
end)

function SeatCheck()
	Citizen.CreateThread(function()
		SeatBeltOn = false
		speedBuffer[1], speedBuffer[2] = 0.0, 0.0
		local ped = PlayerPedId()
		local car = GetVehiclePedIsIn(ped)
	
		while isCarSeatRuned do 
			Citizen.Wait(0)
			if SeatBeltOn then 
				DisableControlAction(0, 75, true)  -- Disable exit vehicle when stop
				DisableControlAction(27, 75, true) -- Disable exit vehicle when Driving
			end
			
			speedBuffer[2] = speedBuffer[1]
			speedBuffer[1] = GetEntitySpeed(car)
	  
			if speedBuffer[2] ~= nil and GetEntitySpeedVector(car, true).y > 1.0 and (speedBuffer[2] - speedBuffer[1]) > (speedBuffer[1] * 0.255) then
				if speedBuffer[1] > (100.0 / 3.6) and not SeatBeltOn then
					local co = GetEntityCoords(ped)
					local fw = Fwv(ped)
					SetEntityCoords(ped, co.x + fw.x, co.y + fw.y, co.z - 0.47, true, true, true)
					SetEntityVelocity(ped, velBuffer[2].x, velBuffer[2].y, velBuffer[2].z)
					Citizen.Wait(1)
					SetPedToRagdoll(ped, 1000, 1000, 0, 0, 0, 0)
				elseif speedBuffer[1] > (80.0 / 3.6) and not SeatBeltOn then
					SetEntityHealth(ped, GetEntityHealth(ped) - 30)
				elseif speedBuffer[1] > (150.0 / 3.6) and SeatBeltOn then
					SetEntityHealth(ped, GetEntityHealth(ped) - 40)
				elseif speedBuffer[1] > (80.0 / 3.6) and SeatBeltOn then
					SetEntityHealth(ped, GetEntityHealth(ped) - 10)
				end
			end
			
			velBuffer[2] = velBuffer[1]
			velBuffer[1] = GetEntityVelocity(car)
		end
		
		SeatBeltOn = false
	end)
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if IsControlJustReleased(0, 182) and IsPedSittingInAnyVehicle(PlayerPedId()) then
			if SeatBeltOn then
				SeatBeltOn = false
				TriggerServerEvent('InteractSound_SV:PlayOnSource', 'unbuckle', 0.3)
			else
				SeatBeltOn = true
				TriggerServerEvent('InteractSound_SV:PlayOnSource', 'buckle', 0.3)
			end
		end
	end
end)

-- U can use it for ther resources like PutInVeh for policejob!
RegisterNetEvent('master_hud:CloseSeatBelt')
AddEventHandler('master_hud:CloseSeatBelt', function() 
	if not IsPedSittingInAnyVehicle(PlayerPedId()) then
		return
	end
	
	SeatBeltOn = true
end)

function Fwv(entity)
	local hr = GetEntityHeading(entity) + 90.0
	if hr < 0.0 then hr = 360.0 + hr end
	hr = hr * 0.0174533
	return { x = math.cos(hr) * 2.0, y = math.sin(hr) * 2.0 }
end

TriggerEvent('chat:addSuggestion', '/togglehud', 'Toggle UI', {})
RegisterCommand('togglehud', function(source, args, raw)
	showUI = not showUI
end)

TriggerEvent('chat:addSuggestion', '/toggleui', 'Toggle UI', {})
RegisterCommand('toggleui', function(source, args, raw)
	showUI = not showUI
end)
