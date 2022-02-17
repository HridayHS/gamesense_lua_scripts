local userid_to_entindex = client.userid_to_entindex
local entity_get_local_player, entity_get_player_name = entity.get_local_player, entity.get_player_name
local globals_maxplayers = globals.maxplayers

local GameStateAPI = panorama.open().GameStateAPI

local function UnmutePlayer(playerEntIndex)
    local player_xuid = GameStateAPI.GetPlayerXuidStringFromEntIndex(playerEntIndex)
    if player_xuid ~= '0' and GameStateAPI.IsSelectedPlayerMuted(player_xuid) then
        GameStateAPI.ToggleMute(player_xuid)
        print('Unmuted player: ', entity_get_player_name(playerEntIndex))
    end
end

client.set_event_callback('player_connect_full', function (event)
    local playerUserID = event.userid
    local playerEntIndex = userid_to_entindex(playerUserID)

    -- Run through all players, unmute them if muted and then return.
    if (playerEntIndex == entity_get_local_player()) then
        for player=1, globals_maxplayers() do
            UnmutePlayer(player)
        end
        return
    end

    -- Unmute player
    UnmutePlayer(playerEntIndex)
end)