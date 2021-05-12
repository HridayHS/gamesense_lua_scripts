local getChokedcommands = globals.chokedcommands
local entity_get_prop, entity_get_game_rules = entity.get_prop, entity.get_game_rules
local renderer_circle_outline, renderer_line, renderer_text = renderer.circle_outline, renderer.line, renderer.text
local ui_get = ui.get

local FakelagLimit = ui.reference('AA', 'Fake lag', 'Limit')
local x, y = client.screen_size()

--[[
	x = width
	y = height
]]

local SCREEN_MIDDLE = x / 2
local SCREEN_BOTTOM = y - 15

local CIRCLE_POS = SCREEN_MIDDLE + 0
local CIRCLE_RADIUS = 10

local FAKELAG_LIMIT
local chokedCommands, chokedCommandsToRender = 0, 0

local getCirclePos = function (chokedCommandsToRender)
	if chokedCommandsToRender == 0 then
		return -90
	end

	if entity_get_prop(entity_get_game_rules(), 'm_bIsValveDS') == 1 then
		FAKELAG_LIMIT = 6
	else
		FAKELAG_LIMIT = ui_get(FakelagLimit)
	end

	local FAKELAG_LIMIT_IN_HALF = FAKELAG_LIMIT / 2

	local INTIAL_POSITION = 90 / FAKELAG_LIMIT_IN_HALF
	
	local POSITION_TO_RENDER = chokedCommandsToRender * INTIAL_POSITION
	
	if chokedCommandsToRender <= FAKELAG_LIMIT_IN_HALF then
		return -90 + POSITION_TO_RENDER
	else
		return POSITION_TO_RENDER - 90
	end
end

client.set_event_callback('paint', function ()
	-- Chokedcommands
	if getChokedcommands() < chokedCommands then
		chokedCommandsToRender = chokedCommands
	end
	chokedCommands = getChokedcommands()
	
	CIRCLE_POS = SCREEN_MIDDLE + getCirclePos(chokedCommandsToRender)

	renderer_line(SCREEN_MIDDLE-100, SCREEN_BOTTOM, CIRCLE_POS-CIRCLE_RADIUS, SCREEN_BOTTOM, 255, 255, 255, 255) -- Line 1 before circle
	renderer_line(CIRCLE_POS+CIRCLE_RADIUS, SCREEN_BOTTOM, SCREEN_MIDDLE+100, SCREEN_BOTTOM, 255, 255, 255, 255) -- Line 2 after circle

	renderer_circle_outline(CIRCLE_POS, SCREEN_BOTTOM, 255, 255, 255, 255, CIRCLE_RADIUS, 0, 1.0, 1)
	renderer_text(CIRCLE_POS, SCREEN_BOTTOM, 255, 255, 255, 255, 'cb', 0, chokedCommandsToRender)
end)