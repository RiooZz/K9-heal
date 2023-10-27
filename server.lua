ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterCommand("givepoint", function(source, args)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.addAccountMoney("bank", tonumber(args[1]))
end)

local bags = {}

-----------------------------------------------------------------------------------------
-- EVENT'S --
-----------------------------------------------------------------------------------------

RegisterNetEvent('wais:lootbag:playerDeath', function(source, attackerid)
    local src      = source
    local xPlayer  = ESX.GetPlayerFromId(src)
    local ped      = GetPlayerPed(src)
    local pCoords  = GetEntityCoords(ped)
    local randomid = GenerateId()
    local inventory = exports["k9-inventory"]:GetInventory(src, "inventory")
    if bags[randomid] == nil then
        bags[randomid] = {items = {}, weapons = {}, coords = pCoords, entityid = 0, cleaming = false, name = "[" ..xPlayer.getIdUnique().. "] " .. GetPlayerName(src)}

        for i=1, #inventory, 1 do
            if inventory[i].count >= 1 then
                local litem, rien, label = exports["k9-inventory"]:GetItemByName(src, "inventory", inventory[i].name)
                --print("item", xPlayer.inventory[i].name, " type", xPlayer.inventory[i].inventoryType)
                table.insert(bags[randomid]["items"], {item = inventory[i].name, count = inventory[i].count, label = label.label})
                exports["k9-inventory"]:RemoveItem(src, "inventory", inventory[i].name, inventory[i].count)
            end
        end

        if not Config.WeaponItems then
            for k, weapon in pairs(xPlayer.getLoadout()) do
                local label = ESX.GetWeaponLabel(weapon.name)
                if label then
                    table.insert(bags[randomid]["weapons"], {
                        name = weapon.name,
                        ammo = weapon.ammo,
                        label = label,
                        components = weapon.components,
                        tintIndex = weapon.tintIndex
                    })
                    xPlayer.removeWeapon(weapon.name)
                end
            end
        end

        TriggerClientEvent('wais:dropNewBag', -1, randomid, bags[randomid])
    end
end)

-- RegisterServerEvent('esx:onPlayerDeath')
-- AddEventHandler('esx:onPlayerDeath', function(data)
--     local src      = source
--     local xPlayer  = ESX.GetPlayerFromId(src)
--     local ped      = GetPlayerPed(src)
--     local pCoords  = GetEntityCoords(ped)
--     local randomid = GenerateId()

--     if bags[randomid] == nil then
--         bags[randomid] = {items = {}, weapons = {}, coords = pCoords, entityid = 0, cleaming = false}

--         for i=1, #xPlayer.inventory, 1 do
--             if xPlayer.inventory[i].count > 0 then
--                 table.insert(bags[randomid]["items"], {item = xPlayer.inventory[i].name, count = xPlayer.inventory[i].count})
--                 xPlayer.removeInventoryItem(xPlayer.inventory[i].name, xPlayer.inventory[i].count)
--             end
--         end

--         if not Config.WeaponItems then
--             for k, weapon in pairs(xPlayer.getLoadout()) do
--                 local label = ESX.GetWeaponLabel(weapon.name)
--                 if label then
--                     table.insert(bags[randomid]["weapons"], {
--                         name = weapon.name,
--                         ammo = weapon.ammo,
--                         label = label,
--                         components = weapon.components,
--                         tintIndex = weapon.tintIndex
--                     })
--                     xPlayer.removeWeapon(weapon.name)
--                 end
--             end
--         end

--         TriggerClientEvent('wais:dropNewBag', -1, randomid, bags[randomid])
--     end
-- end)

RegisterNetEvent('wais:claimBag', function(bagid)
    local src = source
    local xPlayer  = ESX.GetPlayerFromId(src)
    local bag = ""
    if not bags[bagid].claiming then
        TriggerClientEvent('wais:deleteBag', -1, bagid)
        bags[bagid].claiming = true
        xPlayer.showNotification("You looted the ~p~" ..bags[bagid].name.. " ~s~death bag")
        for k, v in pairs(bags[bagid].items) do
            exports["k9-inventory"]:AddItem(src, "inventory", v.item, v.count)
            xPlayer.showNotification("You found ~p~"..v.count.. "x " ..v.label)
            bag = bag .. " " ..v.count.. "x " ..v.label.. " \n"
        end
        if bag == "" then bag = "No content in the loot bag" end
        sendToDiscord("Logs Lootbag","**[" ..xPlayer.getIdUnique().. "] " ..GetPlayerName(src).. "** took the lootbag from **"..bags[bagid].name.. "** \n \nHere is the content: \n \n**" ..bag.. "**", "Logs", "https://discord.com/api/webhooks/1095484744008999043/wUC7KGs-W_Y3mo1p4EB10sF4kxS-oYNAAgGqHTqRLj6UvT1LYtVfMq0Z4p9MmZeaij8V")
        if not Config.WeaponItems then
            for k, v in pairs(bags[bagid].weapons) do
                xPlayer.addWeapon(v.name, v.ammo)
            end
        end
        bags[bagid] = nil
    end

end)

-----------------------------------------------------------------------------------------
-- CALLBACK'S --
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
-- COMMAND'S --
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
-- FUNCTİON'S --
-----------------------------------------------------------------------------------------

function GenerateId()
    math.randomseed(GetGameTimer())
    local random = math.random(1, 2000)
    return random
end

function sendToDiscord(name, message, footer, web)
    local embed = {
          {
              ["color"] = 16753920,
              ["title"] = "**".. name .."**",
              ["description"] = message,
              ["footer"] = {
                  ["text"] = footer,
              },
          }
      }
  
    PerformHttpRequest(web, function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
end
-----------------------------------------------------------------------------------------
-- VERSİON CHECK'S --
-----------------------------------------------------------------------------------------