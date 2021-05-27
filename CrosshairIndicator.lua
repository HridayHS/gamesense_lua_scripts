local curtime = globals.curtime
local unset_event_callback = client.unset_event_callback
local render_circle_outline, measure_text, render_text = renderer.circle_outline, renderer.measure_text, renderer.text
local table_insert = table.insert
local ui_get = ui.get

local x, y = client.screen_size()

local Width = (x / 2)+6
local Height = (y / 2)+6

local indicators = {}

local TIME_TO_PLANT_BOMB = 3
local timeAtBombWillBePlanted

local function innerCircleOutlinePercentage()
    local timeElapsed = (curtime() + TIME_TO_PLANT_BOMB) - timeAtBombWillBePlanted
    local timeElapsedInPerc = (timeElapsed / TIME_TO_PLANT_BOMB * 100) + 0.5
    return timeElapsedInPerc * 0.01
end

-- Gap between indicators text
local indicatorTextGap = 12

-- Outer circle
local o_circleRadius = 6
local o_cricleThickness = o_circleRadius/2

-- Inner circle
local i_circleRadius = o_circleRadius-1
local i_cricleThickness = (o_circleRadius-1)/3

-- Main
client.set_event_callback('paint', function ()
	for i=1, #indicators do
		local indicator = indicators[i]

		local text = indicator.text
		local r, g, b, a = indicator.r, indicator.g, indicator.b, indicator.a

		local textH = Height + (i*-indicatorTextGap) + (#indicators*indicatorTextGap)

		render_text(Width, textH, r, g, b, a, 'd', 0, text)

		if isBombBeingPlanted and text:find('Bombsite') then
			local m_textW, m_textH = measure_text('d', text)

			local cricleW = Width+m_textW+o_circleRadius+4
			local cricleH = textH+(m_textH/1.71)

			render_circle_outline(cricleW, cricleH, 0, 0, 0, 200, o_circleRadius, 0, 1.0, o_cricleThickness)
			render_circle_outline(cricleW, cricleH, 255, 255, 255, 200, i_circleRadius, 0, innerCircleOutlinePercentage(), i_cricleThickness)
		end
	end

	-- Reset indicator table
	indicators = {}
end)

client.set_event_callback('bomb_beginplant', function ()
    timeAtBombWillBePlanted = curtime() + TIME_TO_PLANT_BOMB
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
	unset_event_callback('indicator', IndicatorCallback)
end)

-- DPI Support
local DPI_SCALE = ui.reference('Misc', 'Settings', 'DPI scale')

local DPI_SCALE_SETTINGS = {
	['100%'] = { indicatorTextGap = 12, o_circleRadius = 6 },
	['125%'] = { indicatorTextGap = 13, o_circleRadius = 7 },
	['150%'] = { indicatorTextGap = 15, o_circleRadius = 8 },
	['175%'] = { indicatorTextGap = 18, o_circleRadius = 9 },
	['200%'] = { indicatorTextGap = 20, o_circleRadius = 10 }
}

local function DPI_SCALE_HANDLER()
	local DPI = ui_get(DPI_SCALE)

	-- Update local variables --
	indicatorTextGap = DPI_SCALE_SETTINGS[DPI].indicatorTextGap

	o_circleRadius = DPI_SCALE_SETTINGS[DPI].o_circleRadius
	o_cricleThickness = o_circleRadius/2

	i_circleRadius = o_circleRadius-1
	i_cricleThickness = (o_circleRadius-1)/3
end

ui.set_callback(DPI_SCALE, DPI_SCALE_HANDLER)

DPI_SCALE_HANDLER()