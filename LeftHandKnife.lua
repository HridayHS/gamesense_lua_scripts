local entity_is_alive, entity_get_prop, entity_get_classname, entity_get_local_player, entity_get_player_weapon = entity.is_alive, entity.get_prop, entity.get_classname, entity.get_local_player, entity.get_player_weapon

local LeftHandKnife = {
	Enabled = ui.new_checkbox('Misc', 'Miscellaneous', 'Left hand knife'),
	Main = function ()
		if entity_get_classname(entity_get_player_weapon(entity_is_alive(entity_get_local_player()) and entity_get_local_player() or entity_get_prop(entity_get_local_player(), 'm_hObserverTarget'))) == 'CKnife' then
			cvar.cl_righthand:set_int(0)
		else
			cvar.cl_righthand:set_int(1)
		end
	end
}

ui.set_callback(LeftHandKnife.Enabled, function (item)
	if ui.get(item) then
		client.set_event_callback('net_update_start', LeftHandKnife.Main)
	else
		client.unset_event_callback('net_update_start', LeftHandKnife.Main)
	end
end)