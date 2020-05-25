-- Lua
local string_upper = string.upper

-- Gamesense API
local client_set_event_callback, client_unset_event_callback = client.set_event_callback, client.unset_event_callback
local entity_get_all, entity_get_origin, entity_get_prop, entity_get_local_player, entity_get_player_name, entity_is_enemy = entity.get_all, entity.get_origin, entity.get_prop, entity.get_local_player, entity.get_player_name, entity.is_enemy
local renderer_text, renderer_world_to_screen = renderer.text, renderer.world_to_screen
local ui_get, ui_set_visible = ui.get, ui.set_visible

local References = {
	GrenadeESP = ui.reference('VISUALS', 'Other ESP', 'Grenades')
}

local GrenadeOwner = {
	Label = ui.new_label('Lua', 'A', 'Grenade Owner'),
	Enabled = ui.new_checkbox('Lua', 'A', 'Enabled'),
	Grenades = ui.new_multiselect('Lua', 'A', 'Grenades', 'Decoy', 'Smoke', 'Molotov'),
	EnemyName = ui.new_checkbox('Lua', 'A', 'Show enemy name'),
}

ui_set_visible(GrenadeOwner.Grenades, false)
ui_set_visible(GrenadeOwner.EnemyName, false)

local GrenadeNetvar = {
	['Decoy'] = {
		Netvar = 'CDecoyProjectile'
	},
	['Smoke'] = {
		Netvar = 'CSmokeGrenadeProjectile'
	},
	['Molotov'] = {
		Netvar = 'CInferno'
	}
}

GrenadeOwner.DrawOwnerName = function ()
	local Grenades = ui_get(GrenadeOwner.Grenades)

	if #Grenades == 0 then
		return
	end

	for i=1, #Grenades do
		local Grenade = Grenades[i]
		local GrenadeEntity = entity_get_all(GrenadeNetvar[Grenade].Netvar)

		for i=1, #GrenadeEntity do
			local GrenadeOriginX, GrenadeOriginY, GrenadeOriginZ = entity_get_origin(GrenadeEntity[i])
			local WorldX, WorldY = renderer.world_to_screen(GrenadeOriginX, GrenadeOriginY, GrenadeOriginZ)
			if WorldX ~= nil then
				local GrenadeOwnerEntity = entity_get_prop(GrenadeEntity[i], 'm_hOwnerEntity')
				local GrenadeOwnerName = string_upper(entity_get_player_name(GrenadeOwnerEntity))

				local StringToRender = nil

				if GrenadeOwnerEntity == entity_get_local_player() then
					StringToRender = 'YOUR'
				elseif not entity_is_enemy(GrenadeOwnerEntity) then
					StringToRender = 'TEAMMATE  ' .. GrenadeOwnerName
				elseif entity_is_enemy(GrenadeOwnerEntity) and ui_get(GrenadeOwner.EnemyName) then
					StringToRender = 'ENEMY  ' .. GrenadeOwnerName
				end

				if StringToRender ~= nil then
					renderer_text(WorldX, WorldY, 255, 255, 255, 255, '-c', 0, StringToRender)
					if not ui_get(References.GrenadeESP) then
						local GrenadeName = string_upper(Grenade)
						if Grenade == 'Molotov' then
							GrenadeName = 'MOLLY'
						end
						renderer_text(WorldX, WorldY+12, 255, 255, 255, 255, '-c', 0, GrenadeName)
					end
				end
			end
		end
	end
end

ui.set_callback(GrenadeOwner.Enabled, function (itemNumber)
	local isGrenadeOwnerEnabled = ui_get(itemNumber)

	-- Handle menu items visibility
	ui_set_visible(GrenadeOwner.Grenades, isGrenadeOwnerEnabled)
	ui_set_visible(GrenadeOwner.EnemyName, isGrenadeOwnerEnabled)

	-- Handle grenade owner drawing function
	if isGrenadeOwnerEnabled then
		client_set_event_callback('paint', GrenadeOwner.DrawOwnerName)
	else
		client_unset_event_callback('paint', GrenadeOwner.DrawOwnerName)
	end
end)