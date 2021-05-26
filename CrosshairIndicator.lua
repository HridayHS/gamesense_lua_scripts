local renderer_text = renderer.text
local table_insert = table.insert

local x, y = client.screen_size()

local Width = (x / 2)+6
local Height = (y / 2)+6

local indicators = {}

local function IndicatorCallback(indicator)
	table_insert(indicators, indicator)
end

client.set_event_callback('indicator', IndicatorCallback)

client.set_event_callback('shutdown', function ()
	client.unset_event_callback('indicator', IndicatorCallback)
end)

-- Main
client.set_event_callback('paint', function ()
	for i=1, #indicators do
		local indicator = indicators[i]

		local text = indicator.text
		local r, g, b, a = indicator.r, indicator.g, indicator.b, indicator.a

		local textH = (i * -12) + (#indicators * 12)
		renderer_text(Width, Height+textH, r, g, b, a, nil, 0, text)

		indicators[i] = nil
	end
end)