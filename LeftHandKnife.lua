local LeftHandKnife = {
	Enabled = ui.new_checkbox('Lua', 'B', 'Left Hand Knife'),
	Main = function ()
		if entity.get_classname(entity.get_player_weapon(entity.get_local_player())) == 'CKnife' then
			client.exec('cl_righthand 0')
		else
			client.exec('cl_righthand 1')
		end
	end	
}

ui.set_callback(LeftHandKnife.Enabled, function (itemNumber)
	if ui.get(itemNumber) then
		client.set_event_callback('setup_command', LeftHandKnife.Main)
	else
		client.unset_event_callback('setup_command', LeftHandKnife.Main)
	end
end)