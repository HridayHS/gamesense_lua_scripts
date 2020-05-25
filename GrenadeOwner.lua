-- LUA
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

GrenadeOwner.DrawOwnerName = function ()
	local Grenades = ui_get(GrenadeOwner.Grenades)
	if Grenades[1] == nil then
		return
	end

	local isGrenadeESPOn = ui_get(References.GrenadeESP)

	for i=1, #Grenades do
		-- Decoy Grenades
		if Grenades[i] == 'Decoy' then
			local Decoys = entity_get_all('CDecoyProjectile')
			for i=1, #Decoys do
				local DecoyOriginX, DecoyOriginY, DecoyOriginZ = entity_get_origin(Decoys[i])
				local WorldX, WorldY = renderer_world_to_screen(DecoyOriginX, DecoyOriginY, DecoyOriginZ)
				if WorldX ~= nil then
					local DecoyOwnerEntity = entity_get_prop(Decoys[i], 'm_hThrower')
					local DecoyOwnerName = string_upper(entity_get_player_name(DecoyOwnerEntity))
					local RenderTextString

					if DecoyOwnerEntity == entity_get_local_player() then
						RenderTextString = 'YOUR'
					elseif not entity_is_enemy(DecoyOwnerEntity) then
						RenderTextString = 'TEAMMATE  ' .. DecoyOwnerName
					elseif entity_is_enemy(DecoyOwnerEntity) and ui_get(GrenadeOwner.EnemyName) then
						RenderTextString = 'ENEMY  ' .. DecoyOwnerName
					end

					if RenderTextString ~= nil then
						renderer_text(WorldX, WorldY, 255, 255, 255, 255, '-c', 0, RenderTextString)
						if not isGrenadeESPOn then
							renderer_text(WorldX, WorldY+12, 255, 255, 255, 255, '-c', 0, 'DECOY')
						end
					end
				end
			end
		end

		-- Smoke Grenades
		if Grenades[i] == 'Smoke' then
			local Smokes = entity_get_all('CSmokeGrenadeProjectile')
			for i=1, #Smokes do
				local SmokeOriginX, SmokeOriginY, SmokeOriginZ = entity_get_origin(Smokes[i])
				local WorldX, WorldY = renderer_world_to_screen(SmokeOriginX, SmokeOriginY, SmokeOriginZ)
				if WorldX ~= nil then
					local SmokeOwnerEntity = entity_get_prop(Smokes[i], 'm_hThrower')
					local SmokeOwnerName = string_upper(entity_get_player_name(SmokeOwnerEntity))
					local RenderTextString

					if SmokeOwnerEntity == entity_get_local_player() then
						RenderTextString = 'YOUR'
					elseif not entity_is_enemy(SmokeOwnerEntity) then
						RenderTextString = 'TEAMMATE  ' .. SmokeOwnerName
					elseif entity_is_enemy(SmokeOwnerEntity) and ui_get(GrenadeOwner.EnemyName) then
						RenderTextString = 'ENEMY  ' .. SmokeOwnerName
					end

					if RenderTextString ~= nil then
						renderer_text(WorldX, WorldY, 255, 255, 255, 255, '-c', 0, RenderTextString)
						if not isGrenadeESPOn then
							renderer_text(WorldX, WorldY+12, 255, 255, 255, 255, '-c', 0, 'SMOKE')
						end
					end
				end
			end
		end

		-- Molotov
		if Grenades[i] == 'Molotov' then
			-- Molotov Projectile
			local MolotovProjectice = entity_get_all('CMolotovProjectile')
			for i=1, #MolotovProjectice do
				local MolotovOriginX, MolotovOriginY, MolotovOriginZ = entity_get_origin(MolotovProjectice[i])
				local WorldX, WorldY = renderer_world_to_screen(MolotovOriginX, MolotovOriginY, MolotovOriginZ)
				if WorldX ~= nil then
					local MolotovOwnerEntity = entity_get_prop(MolotovProjectice[i], 'm_hThrower')
					local MolotovOwnerName = string_upper(entity_get_player_name(MolotovOwnerEntity))
					local RenderTextString

					if MolotovOwnerEntity == entity_get_local_player() then
						RenderTextString = 'YOUR'
					elseif not entity_is_enemy(MolotovOwnerEntity) then
						RenderTextString = 'TEAMMATE  ' .. MolotovOwnerName
					elseif entity_is_enemy(MolotovOwnerEntity) and ui_get(GrenadeOwner.EnemyName) then
						RenderTextString = 'ENEMY  ' .. MolotovOwnerName
					end

					if RenderTextString ~= nil then
						renderer_text(WorldX, WorldY, 255, 255, 255, 255, '-c', 0, RenderTextString)
						if not isGrenadeESPOn then
							renderer_text(WorldX, WorldY+12, 255, 255, 255, 255, '-c', 0, 'MOLLY')
						end
					end
				end
			end

			-- Exploded Molotov
			local Molotov = entity_get_all('CInferno')
			for i=1, #Molotov do
				local MolotovOriginX, MolotovOriginY, MolotovOriginZ = entity_get_origin(Molotov[i])
				local WorldX, WorldY = renderer_world_to_screen(MolotovOriginX, MolotovOriginY, MolotovOriginZ)
				if WorldX ~= nil then
					local MolotovOwnerEntity = entity_get_prop(Molotov[i], 'm_hOwnerEntity')
					local MolotovOwnerName = string_upper(entity_get_player_name(MolotovOwnerEntity))
					local RenderTextString

					if MolotovOwnerEntity == entity_get_local_player() then
						RenderTextString = 'YOUR'
					elseif not entity_is_enemy(MolotovOwnerEntity) then
						RenderTextString = 'TEAMMATE  ' .. MolotovOwnerName
					elseif entity_is_enemy(MolotovOwnerEntity) and ui_get(GrenadeOwner.EnemyName) then
						RenderTextString = 'ENEMY  ' .. MolotovOwnerName
					end

					if RenderTextString ~= nil then
						renderer_text(WorldX, WorldY, 255, 255, 255, 255, '-c', 0, RenderTextString)
						if not isGrenadeESPOn then
							renderer_text(WorldX, WorldY+12, 255, 255, 255, 255, '-c', 0, 'MOLLY')
						end
					end
				end
			end
		end
	end
end

ui.set_callback(GrenadeOwner.Enabled, function (itemNumber)
	-- Get grenade owner state
	local isGrenadeOwnerEnabled = ui_get(itemNumber)

	-- Handle menu items
	ui_set_visible(GrenadeOwner.Grenades, isGrenadeOwnerEnabled)
	ui_set_visible(GrenadeOwner.EnemyName, isGrenadeOwnerEnabled)

	-- Handle main function
	if isGrenadeOwnerEnabled then
		client_set_event_callback('paint', GrenadeOwner.DrawOwnerName)
	else
		client_unset_event_callback('paint', GrenadeOwner.DrawOwnerName)
	end
end)