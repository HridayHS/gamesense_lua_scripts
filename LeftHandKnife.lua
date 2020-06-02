local entity_is_alive, entity_get_prop, entity_get_classname, entity_get_local_player, entity_get_player_weapon = entity.is_alive, entity.get_prop, entity.get_classname, entity.get_local_player, entity.get_player_weapon

local function GetWeaponClassname()
	return entity_get_classname(entity_get_player_weapon(entity_is_alive(entity_get_local_player()) and entity_get_local_player() or entity_get_prop(entity_get_local_player(), 'm_hObserverTarget')))
end

client.set_event_callback('pre_render', function ()
	if GetWeaponClassname() == 'CKnife' or GetWeaponClassname() == 'CKnifeGG' then
		cvar.cl_righthand:set_int(0)
	else
		cvar.cl_righthand:set_int(1)
	end
end)