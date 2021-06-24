--------------------------------------------------------------------------------
-- Cache common functions
--------------------------------------------------------------------------------
local render_indicator = renderer.indicator
local ui_get, ui_set, ui_set_visible = ui.get, ui.set, ui.set_visible

--------------------------------------------------------------------------------
-- Constants and variables
--------------------------------------------------------------------------------
local min_damage_ref = ui.reference('Rage', 'Aimbot', 'Minimum damage')

local damage_overrides = { [0] = 'Auto' }
for i=1, 26 do
	damage_overrides[100+i] = 'HP + ' .. i
end

local enable_ref = ui.new_checkbox('Rage', 'Other', 'Minimum damage override')
local indicator_ref = ui.new_color_picker('Rage', 'Other', 'Indicator color', 255, 255, 255, 255)

local restore_dmamage_ref = ui.new_slider('Rage', 'Other', 'Restore damage', 0, 126, 10, true, nil, 1, damage_overrides)
local override_damage_ref = ui.new_slider('Rage', 'Other', 'Override damage', 0, 126, 101, true, nil, 1, damage_overrides)
local override_hk_ref = ui.new_hotkey('Rage', 'Other', 'Damage override hotkey', true)

--------------------------------------------------------------------------------
-- Callback functions
--------------------------------------------------------------------------------
local function on_paint()
	if ui_get(override_hk_ref) then
		local r, g, b, a = ui_get(indicator_ref)
		render_indicator(r, g, b, a, 'Damage: ', ui_get(min_damage_ref))
	end
end

local function on_setup_command()
	local damage = ui_get(override_hk_ref) and ui_get(override_damage_ref) or ui_get(restore_dmamage_ref)
	ui_set(min_damage_ref, damage)
end

local function on_override_damage_toggle()
	local isMinimumDamageOverrideEnabled = ui_get(enable_ref)

	ui_set_visible(restore_dmamage_ref, isMinimumDamageOverrideEnabled)
	ui_set_visible(override_damage_ref, isMinimumDamageOverrideEnabled)
	ui_set_visible(override_hk_ref, isMinimumDamageOverrideEnabled)

	if isMinimumDamageOverrideEnabled then
		client.set_event_callback('setup_command', on_setup_command)
		client.set_event_callback('paint', on_paint)
	else
		client.unset_event_callback('setup_command', on_setup_command)
		client.unset_event_callback('paint', on_paint)
	end
end

ui.set_callback(enable_ref, on_override_damage_toggle)
on_override_damage_toggle()