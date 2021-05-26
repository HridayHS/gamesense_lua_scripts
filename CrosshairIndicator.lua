local globals_curtime = globals.curtime
local renderer_circle_outline, renderer_measure_text, renderer_text = renderer.circle_outline, renderer.measure_text, renderer.text
local table_insert = table.insert

local x, y = client.screen_size()

local Width = (x / 2)+6
local Height = (y / 2)+6

local indicators = {}

-- Main
local TIME_TO_PLANT_BOMB = 3
local timeAtBombWillBePlanted

local function innerCircleOutlinePercentage()
    local timeElapsed = globals_curtime() + TIME_TO_PLANT_BOMB - timeAtBombWillBePlanted
    local timeElapsedInPercentage = (timeElapsed / TIME_TO_PLANT_BOMB * 100) + 0.5
    return timeElapsedInPercentage * 0.01
end

client.set_event_callback('paint', function ()
	for i=1, #indicators do
		local indicator = indicators[i]

		local text = indicator.text
		local r, g, b, a = indicator.r, indicator.g, indicator.b, indicator.a

		local textH = Height + (i*-12) + (#indicators*12)

		renderer_text(Width, textH, r, g, b, a, nil, 0, text)

		if isBombBeingPlanted and text:find('Bombsite') then
			local m_textW, m_textH = renderer_measure_text(nil, text)

			local cricleW = Width+m_textW+10
			local cricleH = textH+(m_textH/1.55)

			renderer_circle_outline(cricleW, cricleH, 0, 0, 0, 200, 6, 0, 1.0, 3)
			renderer_circle_outline(cricleW, cricleH, 255, 255, 255, 200, 5, 0, innerCircleOutlinePercentage(), 1.6)
		end
	end

	for i=1, #indicators do
		indicators[i] = nil
	end
end)

client.set_event_callback('bomb_beginplant', function ()
    timeAtBombWillBePlanted = globals_curtime() + TIME_TO_PLANT_BOMB
    isBombBeingPlanted = true
end)

client.set_event_callback('bomb_abortplant', function ()
    isBombBeingPlanted = false
end)

client.set_event_callback('bomb_planted', function ()
	isBombBeingPlanted = false
end)

--
local function IndicatorCallback(indicator)
	table_insert(indicators, indicator)
end

client.set_event_callback('indicator', IndicatorCallback)

client.set_event_callback('shutdown', function ()
	client.unset_event_callback('indicator', IndicatorCallback)
end)