--------------------------------------------------------------------------------
-- Cache common functions
--------------------------------------------------------------------------------
local bit_band = bit.band
local get_local_player, get_player_weapon, get_prop, is_alive = entity.get_local_player, entity.get_player_weapon, entity.get_prop, entity.is_alive
local json_parse, json_stringify = json.parse, json.stringify
local ui_get, ui_set, ui_set_visible = ui.get,  ui.set, ui.set_visible

--------------------------------------------------------------------------------
-- Constants and variables
--------------------------------------------------------------------------------
local enable_ref = ui.new_checkbox('RAGE', 'Other', 'Weapon configs')
local config_ref

local references = {}
local references_builtin = {}

local config_name_to_idx = {}
local config_idx_to_name = {}
local config_idx_to_settings = {}
local weapon_id_to_config_idx = {}

local IDX_GLOBAL = 1
local active_config_idx

--------------------------------------------------------------------------------
-- Utility functions
--------------------------------------------------------------------------------
local function write_settings(config_idx)
	if config_idx then
		local config_settings = config_idx_to_settings[config_idx]
		for setting_key, ref in pairs(references_builtin) do
			config_settings[setting_key] = ui_get(ref)
		end
	end
end

local function save_settings(config_idx)
	if config_idx then
		local config_settings = config_idx_to_settings[config_idx]
		ui_set(references[config_idx], json_stringify(config_settings))
	end
end

local function load_settings(config_idx)
	if config_idx then
		local raw_config_settings = ui_get(references[config_idx])
		local config_settings = json_parse(raw_config_settings)
		for setting_key, value in pairs(config_settings) do
			local set_successful = pcall(ui_set, references_builtin[setting_key], value)
		end
	end
end

local function update_config(config_idx)
	if active_config_idx ~= config_idx then
		write_settings(active_config_idx)
		save_settings(active_config_idx)
		load_settings(config_idx)
		active_config_idx = config_idx
		ui_set(config_ref, config_idx_to_name[config_idx])
	end
end

local function init_config(name, ...)
	local config_idx = #references+1
	references[config_idx] = ui.new_string(name..' adaptive settings', '{}')

	config_name_to_idx[name] = config_idx
	config_idx_to_name[config_idx] = name
	config_idx_to_settings[config_idx] = {}

	for _, weapon_id in ipairs({...}) do
		weapon_id_to_config_idx[weapon_id] = config_idx
	end
end

local function init_setting(tab, container, name, setting_key, default_value)
	local ref_successful, ref = pcall(ui.reference, tab, container, name)
	if ref_successful then
		references_builtin[setting_key] = ref
		for config_idx=IDX_GLOBAL, #config_idx_to_settings do
			local config_settings = config_idx_to_settings[config_idx]
			config_settings[setting_key] = ui_get(ref)
		end
	end
end

--------------------------------------------------------------------------------
-- Callback functions
--------------------------------------------------------------------------------
local function on_setup_command()
	local local_player = get_local_player()
	local weapon = get_player_weapon(local_player)
	if weapon then
		local weapon_id = bit_band(get_prop(weapon, 'm_iItemDefinitionIndex'), 0xFFFF)
		update_config(weapon_id_to_config_idx[weapon_id] or IDX_GLOBAL)
	end
end

local function on_pre_config_save()
	write_settings(active_config_idx)
	save_settings(active_config_idx)
end

local function on_config_select(ref)
	-- Return if local player is alive
	if is_alive(get_local_player()) then
		return
	end

	local config_idx = config_name_to_idx[ui_get(ref)]
	if active_config_idx then
		update_config(config_idx)
	end
	active_config_idx = config_idx
end

local function on_weapon_config_toggle()
	local isWeaponConfigsEnabled = ui_get(enable_ref)

	ui_set_visible(config_ref, isWeaponConfigsEnabled)
	
	local event_callback = isWeaponConfigsEnabled and client.set_event_callback or client.unset_event_callback
	event_callback('setup_command', on_setup_command)
	event_callback('pre_config_save', on_pre_config_save)
end

--------------------------------------------------------------------------------
-- Initialization code
--------------------------------------------------------------------------------
init_config('Global')
init_config('Auto', 11, 38)
init_config('Awp', 9)
init_config('Scout', 40)
init_config('Desert Eagle', 1)
init_config('Revolver', 64)
init_config('Pistol', 2, 3, 4, 30, 32, 36, 61, 63)
init_config('Rifle', 7, 8, 10, 13, 16, 39, 60)
init_config('Submachine gun', 17, 19, 23, 24, 26, 33, 34)
init_config('Shotgun', 25, 27, 29, 35)
init_config('Machine gun', 14, 28)

init_setting('Rage', 'Aimbot', 'Target selection', 'target_selection')
init_setting('Rage', 'Aimbot', 'Target hitbox', 'target_hitbox')
init_setting('Rage', 'Aimbot', 'Multi-point', 'multi_point')
init_setting('Rage', 'Aimbot', 'Multi-point scale', 'multi_point_scale')
init_setting('Rage', 'Aimbot', 'Prefer safe point', 'safe_point_prefer')
init_setting('Rage', 'Aimbot', 'Avoid unsafe hitboxes', 'avoid_unsafe_hitboxes')
init_setting('Rage', 'Aimbot', 'Automatic fire', 'automatic_fire')
init_setting('Rage', 'Aimbot', 'Automatic penetration', 'automatic_penetration')
init_setting('Rage', 'Aimbot', 'Silent aim', 'silent_aim')
init_setting('Rage', 'Aimbot', 'Minimum hit chance', 'hit_chance')
init_setting('Rage', 'Aimbot', 'Minimum damage', 'minimum_damage')
init_setting('Rage', 'Aimbot', 'Automatic scope', 'automatic_scope')
init_setting('Rage', 'Aimbot', 'Maximum FOV', 'maximum_fov')
init_setting('Rage', 'Other', 'Accuracy boost', 'accuracy_boost')
init_setting('Rage', 'Other', 'Delay shot', 'delay_shot')
init_setting('Rage', 'Other', 'Quick stop', 'quick_stop')
init_setting('Rage', 'Other', 'Quick stop options', 'quick_stop_options')
init_setting('Rage', 'Other', 'Prefer body aim', 'prefer_baim')
init_setting('Rage', 'Other', 'Prefer body aim disablers', 'prefer_baim_disablers')
init_setting('Rage', 'Other', 'Force body aim on peek', 'force_baim_peek')
init_setting('Rage', 'Other', 'Double tap mode', 'dt_mode')
init_setting('Rage', 'Other', 'Double tap hit chance', 'dt_hit_chance')
init_setting('Rage', 'Other', 'Double tap quick stop', 'dt_quick_stop')

client.delay_call(0, function ()
	init_setting('Rage', 'Other', 'Minimum damage override', 'damage_override_enable')
	init_setting('Rage', 'Other', 'Restore damage', 'damage_override_restore')
	init_setting('Rage', 'Other', 'Override damage', 'damage_override_override')
end)

-- Save the default config settings
for config_idx=IDX_GLOBAL, #references do
	save_settings(config_idx)
end

config_ref = ui.new_combobox('RAGE', 'Other', '\nActive config', config_idx_to_name)

-- Enable reference callback
ui.set_callback(enable_ref, on_weapon_config_toggle)
on_weapon_config_toggle()

-- Update the active config idx when the script is loaded and on combobox select.
ui.set_callback(config_ref, on_config_select)