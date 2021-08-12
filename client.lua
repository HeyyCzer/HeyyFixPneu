local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")
heyyczer = Tunnel.getInterface("heyy_fixpneu")

local hasPermission = not heyyCfg.needsPermission
local containsPneu = not heyyCfg.needsPneu

Citizen.CreateThread(function()
	Citizen.Wait(1000)
	while true do
		local idle = 3000
		local plyPed = GetPlayerPed(-1)
		local vehicle = GetClosestVehicleToPlayer()
		
		local animDict = "amb@medic@standing@kneel@idle_a"
		local animName = "idle_a"
		
		local animDict2 = "amb@prop_human_parking_meter@female@idle_a"
		local animName2 = "idle_a_female"
		
		if vehicle ~= 0 then
			local closestTire = GetClosestVehicleTire(vehicle)
			if closestTire ~= nil and hasPermission and containsPneu then
				if IsVehicleTyreBurst(vehicle, closestTire.tireIndex, 0) then
					idle = 5
					Draw3DText(closestTire.bonePos.x, closestTire.bonePos.y, closestTire.bonePos.z, "~g~[E] ~w~Reparar pneu")
					if IsControlJustPressed(1, 38) then
						RequestAnimDict(animDict)
						while not HasAnimDictLoaded(animDict) do
							Citizen.Wait(100)
						end
						RequestAnimDict(animDict2)
						while not HasAnimDictLoaded(animDict2) do
							Citizen.Wait(100)
						end

						if heyyczer.usePneu() then
							vRP._playAnim(false,{{"amb@medic@standing@kneel@idle_a" , "idle_a"}},true)
							Citizen.Wait(1000)
							vRP._playAnim(true,{{"amb@prop_human_parking_meter@female@idle_a" , "idle_a_female"}},true)
							
							TriggerEvent("progress", heyyCfg.repairDuration, "Reparando pneu")
							
							Citizen.Wait(heyyCfg.repairDuration)

							SetVehicleTyreFixed(vehicle, closestTire.tireIndex)
							TriggerServerEvent("FixPneu:SyncToClient", VehToNet(vehicle), closestTire.tireIndex)
								
							TriggerEvent("Notify","sucesso","Você reparou o <b>Pneu</b> com sucesso!")
							Citizen.Wait(1000)
							ClearPedTasks(plyPed) -- Immediately
						end
					end
				end
			end
		end
		Citizen.Wait(idle)
	end
end)

Citizen.CreateThread(function()
	while heyyCfg.needsPneu == true or heyyCfg.needsPermission == true do
		if heyyCfg.needsPneu then containsPneu = heyyczer.containsPneu() end
		if heyyCfg.needsPermission then hasPermission = heyyczer.hasPermission() end
		Citizen.Wait(5000)
	end
end)

function GetClosestVehicleToPlayer()
	local player = PlayerId()
	local plyPed = GetPlayerPed(player)
	local plyPos = GetEntityCoords(plyPed, false)
	local plyOffset = GetOffsetFromEntityInWorldCoords(plyPed, 0.0, 1.0, 0.0)
	local radius = 3.0
	local rayHandle = StartShapeTestCapsule(plyPos.x, plyPos.y, plyPos.z, plyOffset.x, plyOffset.y, plyOffset.z, radius, 10, plyPed, 7)
	local _, _, _, _, vehicle = GetShapeTestResult(rayHandle)
	return vehicle
end

function GetClosestVehicleTire(vehicle)
	local tireBones = {"wheel_lf", "wheel_rf", "wheel_lm1", "wheel_rm1", "wheel_lm2", "wheel_rm2", "wheel_lm3", "wheel_rm3", "wheel_lr", "wheel_rr"}
	local tireIndex = {
		["wheel_lf"] = 0,
		["wheel_rf"] = 1,
		["wheel_lm1"] = 2,
		["wheel_rm1"] = 3,
		["wheel_lm2"] = 45,
		["wheel_rm2"] = 47,
		["wheel_lm3"] = 46,
		["wheel_rm3"] = 48,
		["wheel_lr"] = 4,
		["wheel_rr"] = 5,
	}
	local player = PlayerId()
	local plyPed = GetPlayerPed(player)
	local plyPos = GetEntityCoords(plyPed, false)
	local minDistance = 1.0
	local closestTire = nil
	
	for a = 1, #tireBones do
		local bonePos = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, tireBones[a]))
		local distance = Vdist(plyPos.x, plyPos.y, plyPos.z, bonePos.x, bonePos.y, bonePos.z)

		if closestTire == nil then
			if distance <= minDistance then
				closestTire = {bone = tireBones[a], boneDist = distance, bonePos = bonePos, tireIndex = tireIndex[tireBones[a]]}
			end
		else
			if distance < closestTire.boneDist then
				closestTire = {bone = tireBones[a], boneDist = distance, bonePos = bonePos, tireIndex = tireIndex[tireBones[a]]}
			end
		end
	end

	return closestTire
end

RegisterNetEvent("FixPneu:forceSync")
AddEventHandler("FixPneu:forceSync", function(netVeh, tyre)
	SetVehicleTyreFixed(NetToVeh(netVeh), tyre)	
end)


function Draw3DText(x,y,z,text)
	local onScreen,_x,_y = World3dToScreen2d(x,y,z)
	SetTextFont(4)
	SetTextScale(0.35,0.35)
	SetTextColour(255,255,255,150)
	SetTextEntry("STRING")
	SetTextCentre(1)
	AddTextComponentString(text)
	DrawText(_x,_y)
	local factor = (string.len(text))/370
	DrawRect(_x,_y+0.0125,0.01+factor,0.03,0,0,0,80)
end
