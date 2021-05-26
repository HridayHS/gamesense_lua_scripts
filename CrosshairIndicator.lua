local renderer_text = renderer.text
local table_insert = table.insert

local indicators = {}

local x, y = client.screen_size()

local Width = x / 2
local Height = (y / 2)

client.set_event_callback('paint', function ()
	for i=1, #indicators do
		local indicator = indicators[i]

		local text = indicator.text
		local r, g, b, a = indicator.r, indicator.g, indicator.b, indicator.a

		renderer_text(Width, Height+(i*15), r, g, b, a, 'c', 0, text)

		-- Remove so we can set again
		indicators[i] = nil
	end
end)

local function IndicatorCallback(indicator)
	table_insert(indicators, indicator)
end

client.set_event_callback('indicator', IndicatorCallback)

client.set_event_callback('shutdown', function ()
	client.unset_event_callback('indicator', IndicatorCallback)
end)