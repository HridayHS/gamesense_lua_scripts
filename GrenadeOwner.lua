local References = {
	GrenadeESP = ui.reference('VISUALS', 'Other ESP', 'Grenades')
}

local GrenadeOwner = {
	Label = ui.new_label('Lua', 'A', 'Grenade Owner'),
	Enabled = ui.new_checkbox('Lua', 'A', 'Enabled'),
	Grenades = ui.new_multiselect('Lua', 'A', 'Grenades', 'Decoy', 'Smoke'),
	EnemyName = ui.new_checkbox('Lua', 'A', 'Show enemy name'),
}

ui.set_visible(GrenadeOwner.Grenades, false)
ui.set_visible(GrenadeOwner.EnemyName, false)

GrenadeOwner.DrawOwnerName = function ()
	local isGrenadeESPOn = ui.get(References.GrenadeESP)
	local Grenades = ui.get(GrenadeOwner.Grenades)

	for i=1, #Grenades do
		-- Decoy Grenades
		if Grenades[i] == 'Decoy' then
			local Decoys = entity.get_all('CDecoyProjectile')
			for i=1, #Decoys do
				local DecoyOriginX, DecoyOriginY, DecoyOriginZ = entity.get_origin(Decoys[i])
				local WorldX, WorldY = renderer.world_to_screen(DecoyOriginX, DecoyOriginY, DecoyOriginZ)
				if WorldX ~= nil then
					local DecoyOwnerEntity = entity.get_prop(Decoys[i], 'm_hThrower')
					local DecoyOwnerName = string.upper(entity.get_player_name(DecoyOwnerEntity))
					local RenderTextString	

					if DecoyOwnerEntity == entity.get_local_player() then
						RenderTextString = 'YOUR'
					elseif not entity.is_enemy(DecoyOwnerEntity) then
						RenderTextString = 'TEAMMATE  ' .. DecoyOwnerName
					elseif entity.is_enemy(DecoyOwnerEntity) and ui.get(GrenadeOwner.EnemyName) then
						RenderTextString = 'ENEMY  ' .. DecoyOwnerName
					end

					if RenderTextString ~= nil then
						renderer.text(WorldX, WorldY, 255, 255, 255, 255, '-c', 0, RenderTextString)
						if not isGrenadeESPOn then
							renderer.text(WorldX, WorldY+12, 255, 255, 255, 255, '-c', 0, 'DECOY')
						end
					end
				end
			end
		end

		-- Smoke Grenades
		if Grenades[i] == 'Smoke' then
			local Smokes = entity.get_all('CSmokeGrenadeProjectile')
			for i=1, #Smokes do
				local SmokeOriginX, SmokeOriginY, SmokeOriginZ = entity.get_origin(Smokes[i])
				local WorldX, WorldY = renderer.world_to_screen(SmokeOriginX, SmokeOriginY, SmokeOriginZ)
				if WorldX ~= nil then
					local SmokeOwnerEntity = entity.get_prop(Smokes[i], 'm_hThrower')
					local SmokeOwnerName = string.upper(entity.get_player_name(SmokeOwnerEntity))
					local RenderTextString

					if SmokeOwnerEntity == entity.get_local_player() then
						RenderTextString = 'YOUR'
					elseif not entity.is_enemy(SmokeOwnerEntity) then
						RenderTextString = 'TEAMMATE  ' .. SmokeOwnerName
					elseif entity.is_enemy(SmokeOwnerEntity) and ui.get(GrenadeOwner.EnemyName) then
						RenderTextString = 'ENEMY  ' .. SmokeOwnerName
					end

					if RenderTextString ~= nil then
						renderer.text(WorldX, WorldY, 255, 255, 255, 255, '-c', 0, RenderTextString)
						if not isGrenadeESPOn then
							renderer.text(WorldX, WorldY+12, 255, 255, 255, 255, '-c', 0, 'SMOKE')
						end
					end
				end
			end
		end
	end
end

ui.set_callback(GrenadeOwner.Enabled, function (itemNumber)
	local isGrenadeOwnerEnabled = ui.get(itemNumber)

	-- Handle Menu Items
	ui.set_visible(GrenadeOwner.Grenades, isGrenadeOwnerEnabled)
	ui.set_visible(GrenadeOwner.EnemyName, isGrenadeOwnerEnabled)

	-- Main
	if isGrenadeOwnerEnabled then
		client.set_event_callback('paint', GrenadeOwner.DrawOwnerName)
	else
		client.unset_event_callback('paint', GrenadeOwner.DrawOwnerName)
	end
end)