local ui_get, ui_set = ui.get, ui.set

local ThirdpersonAlive, ThirdpersonAliveHotkey = ui.reference('Visuals', 'Effects', 'Force third person (alive)')
local ThirdpersonDead = ui.reference('Visuals', 'Effects', 'Force third person (dead)')

client.set_event_callback('net_update_start', function ()
    ui_set(ThirdpersonDead, ui_get(ThirdpersonAliveHotkey))
end)