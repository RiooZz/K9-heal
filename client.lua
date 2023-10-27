ESX = nil
Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

local bags = {}

-----------------------------------------------------------------------------------------
-- EVENT'S --
-----------------------------------------------------------------------------------------

AddEventHandler('gameEventTriggered', function(name, data)
    if name == "CEventNetworkEntityDamage" then
        victim = tonumber(data[1])
        attacker = tonumber(data[2])
        victimDied = tonumber(data[6]) == 1 and true or false 
        weaponHash = tonumber(data[7])
        isMeleeDamage = tonumber(data[10]) ~= 0 and true or false 
        vehicleDamageTypeFlag = tonumber(data[11]) 
        local FoundLastDamagedBone, LastDamagedBone = GetPedLastDamageBone(victim)
        local bonehash = -1 
        if FoundLastDamagedBone then
            bonehash = tonumber(LastDamagedBone)
        end
        local PPed = PlayerPedId()
        local distance = IsEntityAPed(attacker) and #(GetEntityCoords(attacker) - GetEntityCoords(victim)) or -1
        local isplayer = IsPedAPlayer(attacker)
        local attackerid = isplayer and GetPlayerServerId(NetworkGetPlayerIndexFromPed(attacker)) or tostring(attacker==-1 and " " or attacker)
        local deadid = isplayer and GetPlayerServerId(NetworkGetPlayerIndexFromPed(victim)) or tostring(victim==-1 and " " or victim)
        local victimName = GetPlayerName(PlayerId())

        if not IsPedAPlayer(victim) or not IsPedAPlayer(attacker) then return end
		if victim == PPed then 
            if victimDied then
                if IsEntityAPed(attacker) then
                    TriggerServerEvent('wais:lootbag:playerDeath', deadid, attackerid)
                end
            end 
        end
    end

end)

RegisterNetEvent('wais:dropNewBag', function(tableid, tableInformation)
	local foundGround, zpos = GetGroundZFor_3dCoord(tableInformation["coords"].x, tableInformation["coords"].y, tableInformation["coords"].z)
	bags[tableid] = { 
		["coords"] = {x = tableInformation["coords"].x, y = tableInformation["coords"].y, z = zpos},
		["entityid"] = nil,
		["lootbagid"] = tableid
	}
	if not Config.LootProp then return end
	RequestModel(Config.LootProp)
	while (not HasModelLoaded(Config.LootProp)) do
		Citizen.Wait(1)
	end
	bags[tableid]["entityid"] = CreateObject(Config.LootProp, bags[tableid]["coords"].x, bags[tableid]["coords"].y, bags[tableid]["coords"].z, false, false, false)
	SetEntityCollision(bags[tableid]["entityid"], false, true)
	FreezeEntityPosition(bags[tableid]["entityid"], true)
end)

RegisterNetEvent('wais:deleteBag', function(bagid)
	DeleteObject(bags[bagid]["entityid"])
	bags[bagid] = nil
end)

-----------------------------------------------------------------------------------------
-- NUI CALLBACK'S --
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
-- FUNCTION'S --
-----------------------------------------------------------------------------------------

function DrawText3D(x, y, z, text)
	SetTextScale(0.30, 0.30)
	SetTextFont(0)
	SetTextProportional(1)
	SetTextColour(255, 255, 255, 215)
	SetTextEntry("STRING")
	SetTextCentre(1)
	AddTextComponentString(text)
	SetDrawOrigin(x,y,z, 0)
	DrawText(0.0, 0.0)
	local factor = (string.len(text)) / 370
	DrawRect(0.0, 0.0+0.0125, 0.025+ factor, 0.03, 15, 16, 17, 100)
    ClearDrawOrigin()
end

-----------------------------------------------------------------------------------------
-- COMMAND'S --
-----------------------------------------------------------------------------------------



-----------------------------------------------------------------------------------------
-- THREAD'S --
-----------------------------------------------------------------------------------------

CreateThread(function()
	while true do
		local sleep = 250
		local ped = PlayerPedId()
		local pCoords = GetEntityCoords(ped)
		--print(GetGroundZFor_3dCoord_2(pCoords, true))
		for _, v in pairs(bags) do
			
			--local distance = #(pCoords - vector3(v.coords.x, v.coords.y, v.coords.z))
			local distance = math.sqrt((v.coords.x - pCoords.x)^2 + (v.coords.y - pCoords.y)^2)
			if distance <= 1.7 then
				sleep = 7
				--DrawText3D(v.coords.x, v.coords.y, v.coords.z, "[E] Search Lootbag")
				
				ESX.ShowHelpNotification("[E] Search Lootbag")
				if IsControlJustPressed(0, 46) then
					if not IsPedInAnyVehicle(ped, false) then
						if not IsEntityDead(ped) then
							TriggerServerEvent('wais:claimBag', v.lootbagid)
						end
					end
				end
			end
		end

		Wait(sleep)
	end
end)