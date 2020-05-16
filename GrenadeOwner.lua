local GrenadeOwner = {
	Label = ui.new_label('Lua', 'A', 'Grenade Owner'),
	Enabled = ui.new_checkbox('Lua', 'A', 'Enabled'),
	Grenades = ui.new_multiselect('Lua', 'A', 'Grenades', 'Decoy', 'Smoke'),
	Textcolor = ui.new_color_picker('Lua', 'A', 'Text Color', 255, 255, 255, 255),
	EnemyName = ui.new_checkbox('Lua', 'A', 'Show enemy name'),
}
local Ref_GrenadeESP = ui.reference('VISUALS', 'Other ESP', 'Grenades')

client.set_event_callback('paint', function()
	-- Return if Master Switch is disabled.
	if not ui.get(GrenadeOwner.Enabled) then
		return
	end

	local isGrenadeESPOn = ui.get(Ref_GrenadeESP)
	local Grenades = ui.get(GrenadeOwner.Grenades)
	local R, G, B, A = ui.get(GrenadeOwner.Textcolor)

	for i=1, #Grenades do
		-- Decoy Grenades
		if Grenades[i] == 'Decoy' then
			local Decoys = entity.get_all('CDecoyProjectile')
			for i=1, #Decoys do
				local DecoyOriginX, DecoyOriginY, DecoyOriginZ = entity.get_prop(Decoys[i], 'm_vecOrigin')
				local WorldX, WorldY = renderer.world_to_screen(DecoyOriginX, DecoyOriginY, DecoyOriginZ)
				if WorldX ~= nil then
					local DecoyOwnerEntity = entity.get_prop(Decoys[i], 'm_hThrower')
					local DecoyOwnerName = string.upper(entity.get_player_name(DecoyOwnerEntity))

					local RenderTextString
					if DecoyOwnerEntity == entity.get_local_player() then
						RenderTextString = 'OWN DECOY'
					elseif entity.is_enemy(DecoyOwnerEntity) and ui.get(GrenadeOwner.EnemyName) then
						if isGrenadeESPOn then
							RenderTextString = 'ENEMY ' .. DecoyOwnerName
						else
							RenderTextString = DecoyOwnerName .. "'S DECOY"
						end
					elseif not entity.is_enemy(DecoyOwnerEntity) then
						if isGrenadeESPOn then
							RenderTextString = 'TEAMMATE ' .. DecoyOwnerName
						else
							RenderTextString = DecoyOwnerName .. "'S DECOY"
						end
					end

					if RenderTextString ~= nil then
						renderer.text(WorldX, WorldY, R, G, B, A, '-c', 0, RenderTextString)
					end
				end
			end
		end

		-- Smoke Grenades
		if Grenades[i] == 'Smoke' then
			local Smokes = entity.get_all('CSmokeGrenadeProjectile')
			for i=1, #Smokes do
				local SmokeOriginX, SmokeOriginY, SmokeOriginZ = entity.get_prop(Smokes[i], 'm_vecOrigin')
				local WorldX, WorldY = renderer.world_to_screen(SmokeOriginX, SmokeOriginY, SmokeOriginZ)
				if WorldX ~= nil then
					local SmokeOwnerEntity = entity.get_prop(Smokes[i], 'm_hThrower')
					local SmokeOwnerName = string.upper(entity.get_player_name(SmokeOwnerEntity))
					
					local RenderTextString
					if SmokeOwnerEntity == entity.get_local_player() then
						RenderTextString = 'OWN SMOKE'
					elseif entity.is_enemy(SmokeOwnerEntity and ui.get(GrenadeOwner.EnemyName) then
						if isGrenadeESPOn then
							RenderTextString = 'ENEMY ' .. SmokeOwnerName
						else
							RenderTextString = SmokeOwnerName .. "'S SMOKE"
						end
					elseif not entity.is_enemy(SmokeOwnerEntity) then
						if isGrenadeESPOn then
							RenderTextString = 'TEAMMATE ' .. SmokeOwnerName
						else
							RenderTextString = SmokeOwnerName .. "'S SMOKE"
						end
					end

					if RenderTextString ~= nil then
						renderer.text(WorldX, WorldY, R, G, B, A, '-c', 0, RenderTextString)
					end
				end
			end
		end
	end
end)