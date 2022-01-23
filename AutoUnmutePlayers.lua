local entity_get_local_player, entity_get_player_name = entity.get_local_player, entity.get_player_name
local globals_maxplayers = globals.maxplayers

local GameStateAPI = panorama.open().GameStateAPI

local function UnmutePlayer(player_ent_index)
    local player_xuid = GameStateAPI.GetPlayerXuidStringFromEntIndex(player_ent_index)
    if player_xuid ~= '0' and GameStateAPI.HasCommunicationAbuseMute(player_xuid) then
        GameStateAPI.ToggleMute(player_xuid)
        print('Unmuted player: ', entity_get_player_name(player_ent_index))
    end
end

client.set_event_callback('player_connect_full', function (event)
    local player_ent_index = event.index + 1

    -- Run through all players, unmute them if muted and then return.
    if (player_ent_index == entity_get_local_player()) then
        for player=1, globals_maxplayers() do
            UnmutePlayer(player)
        end
        return
    end

    -- Unmute player
    UnmutePlayer(player_ent_index)
end)