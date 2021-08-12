local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
heyyczer = {}
Tunnel.bindInterface("heyy_fixpneu", heyyczer)


function heyyczer.hasPermission()
	if not heyyCfg.needsPermission then return true end
	
	local source = source
	local user_id = vRP.getUserId(source)
	return vRP.hasPermission(user_id, heyyCfg.permission)
end


function heyyczer.containsPneu()
	local source = source
	
	local user_id = vRP.getUserId(source)
	if vRP.getInventoryItemAmount(user_id, heyyCfg.itemIndex) > 0 then
		return true
	end
	return false
end


function heyyczer.usePneu()
	if not heyyCfg.needsPneu then
		return true
	end
	
	local source = source
	
	local user_id = vRP.getUserId(source)
	if vRP.tryGetInventoryItem(user_id, heyyCfg.itemIndex, heyyCfg.itemAmount) then
		return true
	end
	TriggerClientEvent("Notify",source,"negado","Você precisa de <b>" .. heyyCfg.itemAmount .. "x " .. vRP.itemNameList(heyyCfg.itemIndex) .. "</b> para isto!")
	return false
end

RegisterServerEvent("FixPneu:SyncToClient")
AddEventHandler("FixPneu:SyncToClient", function(client, tireIndex)
	TriggerClientEvent("FixPneu:forceSync", client, tireIndex)
end)
