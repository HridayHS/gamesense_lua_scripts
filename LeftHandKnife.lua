local client_exec, client_set_event_callback, client_unset_event_callback = client.exec, client.set_event_callback, client.unset_event_callback
local entity_get_classname, entity_get_local_player, entity_get_player_weapon = entity.get_classname, entity.get_local_player, entity.get_player_weapon
local ui_get = ui.get

local LeftHandKnife = {
	Enabled = ui.new_checkbox('Lua', 'B', 'Left Hand Knife'),
	Main = function()
		if entity_get_classname(entity_get_player_weapon(entity_get_local_player())) == 'CKnife' then
			client_exec('cl_righthand 0')
		else
			client_exec('cl_righthand 1')
		end
	end
}

ui.set_callback(LeftHandKnife.Enabled, function(item)
	if ui_get(item) then
		client_set_event_callback('setup_command', LeftHandKnife.Main)
	else
		client_unset_event_callback('setup_command', LeftHandKnife.Main)
	end
end)