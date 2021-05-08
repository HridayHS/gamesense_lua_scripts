local client_exec = client.exec
local entity_is_enemy = entity.is_enemy

client.set_event_callback('player_chat', function (event)
	if entity_is_enemy(event.entity) then
		client_exec('say                               ')
	end
end)