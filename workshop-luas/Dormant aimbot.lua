local math_max, string_format = math.max, string.format

local client_eye_position, client_log, client_trace_bullet, client_visible = client.eye_position, client.log, client.trace_bullet, client.visible
local entity_get_bounding_box, entity_get_local_player, entity_get_origin, entity_get_player_resource, entity_get_player_weapon, entity_get_prop, entity_is_alive, entity_is_dormant, entity_is_enemy = entity.get_bounding_box, entity.get_local_player, entity.get_origin, entity.get_player_resource, entity.get_player_weapon, entity.get_prop, entity.is_alive, entity.is_dormant, entity.is_enemy
local globals_maxplayers, globals_tickcount, globals_tickinterval = globals.maxplayers, globals.tickcount, globals.tickinterval
local plist_get = plist.get
local render_indicator = renderer.indicator
local set_event_callback, unset_event_callback = client.set_event_callback, client.unset_event_callback
local ui_get, ui_name, ui_set_visible = ui.get, ui.name, ui.set_visible

local ffi = require 'ffi'
local vector = require 'vector'
local weapons = require 'gamesense/csgo_weapons'

local native_GetClientEntity = vtable_bind('client_panorama.dll', 'VClientEntityList003', 3, 'void*(__thiscall*)(void*,int)')
local native_IsWeapon = vtable_thunk(165, 'bool(__thiscall*)(void*)')
local native_GetInaccuracy = vtable_thunk(482, 'float(__thiscall*)(void*)')

local ref = {
	mindmg = ui.reference('RAGE', 'Aimbot', 'Minimum damage'),
	dormantEsp = ui.reference('VISUALS', 'Player ESP', 'Dormant'),
}

local menu = {
	dormant_switch = ui.new_checkbox('RAGE', 'Aimbot', 'Dormant aimbot'),
	dormant_key = ui.new_hotkey('RAGE', 'Aimbot', 'Dormant aimbot', true),
	dormant_mindmg = ui.new_slider('RAGE', 'Aimbot', 'Dormant minimum damage', 0, 100, 10, true),
	dormant_indicator = ui.new_checkbox('RAGE', 'Aimbot', 'Dormant indicator'),
	dormant_aimbot_requirements = {
		ui.new_label('RAGE', 'Aimbot', 'Visuals->Player ESP->Dormant: Off'),
		ui.new_label('RAGE', 'Aimbot', 'Dormant ESP is off!'),
		ui.new_label('RAGE', 'Aimbot', 'Enable it for dormant aimbot to work'),
		ui.new_label('RAGE', 'Aimbot', 'and re-enable dormant aimbot.')
	}
}

local player_info_prev = {}
local roundStarted = 0

local function modify_velocity(e, goalspeed)
	local minspeed = math.sqrt((e.forwardmove * e.forwardmove) + (e.sidemove * e.sidemove))
	if goalspeed <= 0 or minspeed <= 0 then
		return
	end

	if e.in_duck == 1 then
		goalspeed = goalspeed * 2.94117647
	end

	if minspeed <= goalspeed then
		return
	end

	local speedfactor = goalspeed / minspeed
	e.forwardmove = e.forwardmove * speedfactor
	e.sidemove = e.sidemove * speedfactor
end

local function on_setup_command(cmd)
	if not ui_get(menu.dormant_switch) then
		return
	end

	local lp = entity_get_local_player()

	local my_weapon = entity_get_player_weapon(lp)
	if not my_weapon then
		return
	end

	local ent = native_GetClientEntity(my_weapon)
	if ent == nil or not native_IsWeapon(ent) then
		return
	end

	local inaccuracy = native_GetInaccuracy(ent)
	if inaccuracy == nil then
		return
	end

	local tickcount = globals_tickcount()
	local player_resource = entity_get_player_resource()
	local eyepos = vector(client_eye_position())
	local simtime = entity_get_prop(lp, 'm_flSimulationTime')
	local weapon = weapons(my_weapon)
	local scoped = entity_get_prop(lp, 'm_bIsScoped') == 1
	local onground = bit.band(entity_get_prop(lp, 'm_fFlags'), bit.lshift(1, 0))

	-- To prevent shooting at ghost dormant esp @ the beginning of round
	if tickcount < roundStarted then
		return
	end

	local can_shoot
	if weapon.is_revolver then -- for some reason can_shoot returns always false with r8 despite all 3 props being true, no idea why
		can_shoot = simtime > entity_get_prop(my_weapon, 'm_flNextPrimaryAttack') -- doing this fixes it ><
	elseif weapon.is_melee_weapon then
		can_shoot = false
	else
		can_shoot = simtime > math_max(entity_get_prop(lp, 'm_flNextAttack'), entity_get_prop(my_weapon, 'm_flNextPrimaryAttack'), entity_get_prop(my_weapon, 'm_flNextSecondaryAttack'))
	end

	-- New player info
	local player_info = {}

	-- Loop through all players and continue if they're connected
	for player=1, globals_maxplayers() do
		-- If player is not connected skip the loop.
		if entity_get_prop(player_resource, 'm_bConnected', player) ~= 1 then
			goto skip
		end

		-- If player is whitelisted skip the loop.
		if plist_get(player, 'Add to whitelist') then
				goto skip
		end

		if entity_is_enemy(player) and entity_is_dormant(player) then
			local can_hit

			local origin = vector(entity_get_origin(player))
			local x1, y1, x2, y2, alpha_multiplier = entity_get_bounding_box(player) -- grab alpha of the dormant esp
				
			if player_info_prev[player] ~= nil and origin.x ~= 0 and alpha_multiplier > 0 then -- if origin / dormant esp is valid
				local old_origin, old_alpha, old_hittable = unpack(player_info_prev[player])

				-- update check
				local dormant_accurate = alpha_multiplier > 0.795 -- for debug purposes lower this to 0.1

				if dormant_accurate then
					local target = origin + vector(0, 0, 40)
					local pitch, yaw = eyepos:to(target):angles()
					local ent, dmg = client_trace_bullet(lp, eyepos.x, eyepos.y, eyepos.z, target.x, target.y, target.z, true)

					can_hit = (dmg > ui_get(menu.dormant_mindmg)) and (not client_visible(target.x, target.y, target.z)) -- added visibility check to mitigate shooting at anomalies?
					if can_shoot and can_hit and ui_get(menu.dormant_key) then
						modify_velocity(cmd, (scoped and weapon.max_player_speed_alt or weapon.max_player_speed)*0.33)

						-- autoscope
						if not scoped and weapon.type == 'sniperrifle' and cmd.in_jump == 0 and onground == 1 then
							cmd.in_attack2 = 1
						end
							
						if inaccuracy < 0.009 and cmd.chokedcommands == 0 then
							cmd.pitch = pitch
							cmd.yaw = yaw
							cmd.in_attack = 1

							-- dont shoot again
							can_shoot = false
							-- client_log(string_format('Taking a shot at: %s | tickcount: %d | predcited damage: %d | inaccuracy: %.3f | Alpha: %.3f', entity.get_player_name(player), tickcount, dmg, inaccuracy, alpha_multiplier))
						end
					end
				end
			end
			player_info[player] = {origin, alpha_multiplier, can_hit}
		end
		::skip::
	end
	player_info_prev = player_info
end

client.register_esp_flag('DA', 255, 255, 255, function (player)
	if ui_get(menu.dormant_switch) and entity.is_enemy(player) and player_info_prev[player] ~= nil and entity_is_alive(entity_get_local_player()) then
		local _, _, can_hit = unpack(player_info_prev[player])
		return can_hit
	end
end)

local function DAIndicator()
	-- Return if local player is not alive.
	if not entity_is_alive(entity_get_local_player()) then
		return
	end

	local isDormantAimbotEnabled = ui_get(menu.dormant_switch) and ui_get(menu.dormant_key)

	if not isDormantAimbotEnabled then
		return
	end

	local colors = {132, 196, 20, 245}

	for k, v in pairs(player_info_prev) do 
		if k ~= nil then 
			if v[3] == true then 
				colors = {252, 222, 30, 245}
				break
			end
		end
	end

	render_indicator(colors[1], colors[2], colors[3], colors[4], 'DA')
end

local function resetter()
	local freezetime = (cvar.mp_freezetime:get_float()+1) / globals_tickinterval() -- get freezetime plus 1 second and disable dormantbob for that amount of ticks
	roundStarted = globals_tickcount() + freezetime
end

local function itemHandler(reference)
	local itemState = ui_get(reference)

	-- Return event callback to be used based on itemState
	local event_callback = itemState and set_event_callback or unset_event_callback

	-- Event callbacks for menu.dormant_switch and menu items aimbot visibility checks
	if ui_name(reference) == 'Dormant aimbot' then
		local dormantESPState = ui_get(ref.dormantEsp)

		-- Visibility checks
		ui_set_visible(menu.dormant_mindmg, itemState and dormantESPState)
		ui_set_visible(menu.dormant_indicator, itemState and dormantESPState)

		for i=1, #menu.dormant_aimbot_requirements do
			local label_reference = menu.dormant_aimbot_requirements[i]
			ui_set_visible(label_reference, itemState and not dormantESPState)
		end

		-- Callbacks
		event_callback('setup_command', on_setup_command)
		event_callback('round_prestart', resetter)
	end

	-- Event callback for menu.dormant_indicator
	if ui_name(reference) == 'Dormant indicator' then
		event_callback('paint', DAIndicator)
	end
end

ui.set_callback(menu.dormant_switch, itemHandler)
ui.set_callback(menu.dormant_indicator, itemHandler)

-- Set default values for new menu items
ui.set(menu.dormant_indicator, true)

ui_set_visible(menu.dormant_mindmg, false)
ui_set_visible(menu.dormant_indicator, false)

for i=1, #menu.dormant_aimbot_requirements do
	local label_reference = menu.dormant_aimbot_requirements[i]
	ui_set_visible(label_reference, false)
end