local client_set_event_callback, client_unset_event_callback = client.set_event_callback, client.unset_event_callback
local entity_get_prop, entity_get_game_rules = entity.get_prop, entity.get_game_rules
local renderer_circle_outline, renderer_line, renderer_text = renderer.circle_outline, renderer.line, renderer.text
local ui_get, ui_set, ui_set_visible = ui.get, ui.set, ui.set_visible

local FakelagLimit = ui.reference('AA', 'Fake lag', 'Limit')
local x, y = client.screen_size()

local Indicator = {
	Enabled = ui.new_checkbox('AA', 'Fake lag', 'Indicator'),
	LineWidth = ui.new_slider('AA', 'Fake lag', 'Line width', 1, 6, 2, false, nil, 50),
	LineColor = ui.new_color_picker('AA', 'Fake lag', 'Line color', 255, 255, 255, 255),
	DisplayFakelagValue = ui.new_checkbox('AA', 'Fake lag', 'Display fakelag value'),
	FakelagValueColor = ui.new_color_picker('AA', 'Fake lag', 'Fakelag value color', 255, 255, 255, 255),
	CircleColorLabel = ui.new_label('AA', 'Fake lag', 'Circle color'),
	CircleColor = ui.new_color_picker('AA', 'Fake lag', 'Circle color', 255, 255, 255, 255),
}

local SCREEN_MIDDLE = x / 2
local SCREEN_BOTTOM = y - 15

local LINE_WIDTH = 100

local CIRCLE_POS = SCREEN_MIDDLE + (-LINE_WIDTH+10)
local CIRCLE_RADIUS = 10

local FAKELAG_LIMIT = 6
local chokedCommands, chokedCommandsToRender = 0, 0

local function getCirclePos()
	if chokedCommandsToRender == 0 then
		return (-LINE_WIDTH+10)
	end

	if entity_get_prop(entity_get_game_rules(), 'm_bIsValveDS') == 1 then
		FAKELAG_LIMIT = 6
	else
		FAKELAG_LIMIT = ui_get(FakelagLimit)
	end

	local FAKELAG_LIMIT_IN_HALF = FAKELAG_LIMIT / 2

	local INTIAL_POSITION = (LINE_WIDTH-10) / FAKELAG_LIMIT_IN_HALF
	
	local POSITION_TO_RENDER = chokedCommandsToRender * INTIAL_POSITION
	
	if chokedCommandsToRender <= FAKELAG_LIMIT_IN_HALF then
		return (-LINE_WIDTH+10) + POSITION_TO_RENDER
	else
		return POSITION_TO_RENDER - (LINE_WIDTH-10)
	end
end

--
ui_set(Indicator.Enabled, true)

ui.set_callback(Indicator.LineWidth, function (itemNumber)
	LINE_WIDTH = ui_get(itemNumber) * 50
	CIRCLE_POS = SCREEN_MIDDLE + getCirclePos()
end)

local LINE_COLOR = {255, 255, 255, 255}
ui.set_callback(Indicator.LineColor, function (itemNumber)
	local lineColor = { ui_get(itemNumber) }
	for i=1, 4 do
		LINE_COLOR[i] = lineColor[i]
	end
end)

ui_set(Indicator.DisplayFakelagValue, true)

local FAKELAG_VALUE_COLOR = {255, 255, 255, 255}
ui.set_callback(Indicator.FakelagValueColor, function (itemNumber)
	local fakelagValueColor = { ui_get(itemNumber) }
	for i=1, 4 do
		FAKELAG_VALUE_COLOR[i] = fakelagValueColor[i]
	end
end)

local CIRCLE_COLOR = {255, 255, 255, 255}
ui.set_callback(Indicator.CircleColor, function (itemNumber)
	local circleColor = { ui_get(itemNumber) }
	for i=1, 4 do
		CIRCLE_COLOR[i] = circleColor[i]
	end
end)
--

local function on_setup_command(e)
	local getChokedCommands = e.chokedcommands
	if getChokedCommands < chokedCommands then
		chokedCommandsToRender = chokedCommands
		CIRCLE_POS = SCREEN_MIDDLE + getCirclePos()
	end
	chokedCommands = getChokedCommands
end

local function on_paint()
	renderer_line(SCREEN_MIDDLE-LINE_WIDTH, SCREEN_BOTTOM, CIRCLE_POS-CIRCLE_RADIUS, SCREEN_BOTTOM, LINE_COLOR[1], LINE_COLOR[2], LINE_COLOR[3], LINE_COLOR[4]) -- Line 1 before circle
	renderer_line(CIRCLE_POS+CIRCLE_RADIUS, SCREEN_BOTTOM, SCREEN_MIDDLE+LINE_WIDTH, SCREEN_BOTTOM, LINE_COLOR[1], LINE_COLOR[2], LINE_COLOR[3], LINE_COLOR[4]) -- Line 2 after circle

	renderer_circle_outline(CIRCLE_POS, SCREEN_BOTTOM, CIRCLE_COLOR[1], CIRCLE_COLOR[2], CIRCLE_COLOR[3], CIRCLE_COLOR[4], CIRCLE_RADIUS, 0, 1.0, 1)

	if ui_get(Indicator.DisplayFakelagValue) then
		renderer_text(CIRCLE_POS, SCREEN_BOTTOM, FAKELAG_VALUE_COLOR[1], FAKELAG_VALUE_COLOR[2], FAKELAG_VALUE_COLOR[3], FAKELAG_VALUE_COLOR[4], 'c', 0, chokedCommandsToRender)
	end
end

local function IndicatorItemHandler()
	local isIndicatorEnabled = ui_get(Indicator.Enabled)

	for key, value in pairs(Indicator) do
		if key ~= 'Enabled' then
			ui_set_visible(value, isIndicatorEnabled)
		end
	end

	if isIndicatorEnabled then
		client_set_event_callback('paint', on_paint)
		client_set_event_callback('setup_command', on_setup_command)
	else
		client_unset_event_callback('paint', on_paint)
		client_unset_event_callback('setup_command', on_setup_command)
	end
end
ui.set_callback(Indicator.Enabled, IndicatorItemHandler)

IndicatorItemHandler()