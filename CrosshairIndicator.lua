local curtime = globals.curtime
local key_state, unset_event_callback = client.key_state, client.unset_event_callback
local render_circle_outline, measure_text, render_text = renderer.circle_outline, renderer.measure_text, renderer.text
local table_insert = table.insert
local ui_get, is_menu_open, menu_position, menu_size, mouse_position = ui.get, ui.is_menu_open, ui.menu_position, ui.menu_size, ui.mouse_position

local x, y = client.screen_size()

local width = (x / 2)+6
local height = (y / 2)+6

local indicators = {}

-- Override default indicators
local function indicatorCallback(indicator)
	table_insert(indicators, indicator)
end

client.set_event_callback('indicator', indicatorCallback)

-- Unset custom indicator event callback on shutdown event.
client.set_event_callback('shutdown', function ()
	unset_event_callback('indicator', indicatorCallback)
end)
--

-- Drag support
local isMoving = false
local grabX, grabY

local iWidthInPer, iHeightInPer = 51, 50
local renderTextFlags = 'd'

local function updateIndicatorTextFlags()
	if iWidthInPer > 50 then
		renderTextFlags = 'd' -- Uncentered text
	elseif iWidthInPer < 50 then
		renderTextFlags = 'dr' -- Right-aligned text
	elseif iWidthInPer == 50 then
		renderTextFlags = 'dc' -- Centered text
	end
end

local function dragText(textH, m_textW, m_textH, indicatorTextGap, iArrLength)
	if not is_menu_open() or not key_state(0x01) then
		isMoving = false
		return
	end

	-- Mouse x and y cordinates
	local mX, mY = mouse_position()

	local menuX, menuY = menu_position()
	local menuW, menuH = menu_size()

	local isMenuSelected = (mX >= menuX and mX <= (menuX+menuW))
		and (mY >= menuY and mY <= (menuY+menuH))

	-- Return if menu is selected.
	if isMenuSelected then
		return
	end

	if iWidthInPer > 50 then -- Is indicators on left side of the screen.
		isTextSelected = (mX >= width and mX <= (width+m_textW))
			and (mY >= textH and mY <= (textH+m_textH))
	elseif iWidthInPer < 50 then -- Is indicators on right side of the screen.
		isTextSelected = (mX >= (width-m_textW) and mX <= width)
			and (mY >= textH and mY <= (textH+m_textH))
	elseif iWidthInPer == 50 then -- Or if indicators are in the middle of the screen.
		isTextSelected = (mX >= (width-(m_textW/2)) and mX <= (width+m_textW))
			and (mY >= textH and mY <= (textH+m_textH))
	end

	-- Return if indicators are not selected.
	if not isTextSelected then
		return
	end

	if not isMoving then
		grabX, grabY = mX - width, mY - (height + (iArrLength*-indicatorTextGap) + (iArrLength*indicatorTextGap))
		isMoving = true
	end

	-- Update width and height
	width, height = mX-grabX, mY-grabY

	-- Update indicator style based on position
	iWidthInPer = (width / x) * 100
	iHeightInPer = ((height + (iArrLength*-indicatorTextGap) + (iArrLength*indicatorTextGap)) / y) * 100
	updateIndicatorTextFlags()
end
--

-- Main
local indicatorTextGap = 12 -- Gap between indicators

-- Bomb planting timer outer circle arguments
local o_circleRadius = 6
local o_cricleThickness = o_circleRadius/2

-- Bomb planting timer inner circle arguments
local i_circleRadius = o_circleRadius-1
local i_cricleThickness = (o_circleRadius-1)/3

local TIME_TO_PLANT_BOMB = 3
local timeAtBombWillBePlanted

local function innerCircleOutlinePercentage()
	local timeElapsed = (curtime() + TIME_TO_PLANT_BOMB) - timeAtBombWillBePlanted
	local timeElapsedInPerc = (timeElapsed / TIME_TO_PLANT_BOMB * 100) + 0.5
	return timeElapsedInPerc * 0.01
end

client.set_event_callback('paint', function ()
	-- Indicators array length
	local iArrLength = #indicators

	for i=1, iArrLength do
		local indicator = indicators[i]

		local text = indicator.text
		local r, g, b, a = indicator.r, indicator.g, indicator.b, indicator.a

		local textH
		if iHeightInPer >= 50 then
			textH = height + (i*-indicatorTextGap) + (iArrLength*indicatorTextGap)
		else
			textH = height + (i*-indicatorTextGap)
		end
		
		local m_textW, m_textH = measure_text(renderTextFlags, text)

		-- Drag support
		dragText(textH, m_textW, m_textH, indicatorTextGap, iArrLength)

		-- Render indicator
		render_text(width, textH, r, g, b, a, renderTextFlags, 0, text)

		-- Draw planting c4 timer
		if isBombBeingPlanted and text:find('Bombsite') then
			local cricleW, cricleH

			if renderTextFlags == 'd' then
				cricleW = width+m_textW+o_circleRadius+4
				cricleH = textH+(m_textH/1.71)
			elseif renderTextFlags == 'dr' then
				cricleW = width+o_circleRadius+4
				cricleH = textH+(m_textH/1.71)
			elseif renderTextFlags == 'dc' then
				cricleW = width+(m_textW/2)+o_circleRadius+4
				cricleH = textH
			end

			render_circle_outline(cricleW, cricleH, 0, 0, 0, 200, o_circleRadius, 0, 1.0, o_cricleThickness)
			render_circle_outline(cricleW, cricleH, 255, 255, 255, 200, i_circleRadius, 0, innerCircleOutlinePercentage(), i_cricleThickness)
		end
	end

	-- Reset indicators table
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

-- DPI Support
local DPI_SCALE = ui.reference('Misc', 'Settings', 'DPI scale')

local DPI_SCALE_SETTINGS = {
	['100%'] = { indicatorTextGap = 12, o_circleRadius = 6 },
	['125%'] = { indicatorTextGap = 13, o_circleRadius = 7 },
	['150%'] = { indicatorTextGap = 15, o_circleRadius = 8 },
	['175%'] = { indicatorTextGap = 18, o_circleRadius = 9 },
	['200%'] = { indicatorTextGap = 20, o_circleRadius = 10 }
}

local function DPIScaleHandler()
	local DPI = ui_get(DPI_SCALE)

	-- Update local variables --
	indicatorTextGap = DPI_SCALE_SETTINGS[DPI].indicatorTextGap

	o_circleRadius = DPI_SCALE_SETTINGS[DPI].o_circleRadius
	o_cricleThickness = o_circleRadius/2

	i_circleRadius = o_circleRadius-1
	i_cricleThickness = (o_circleRadius-1)/3
end

ui.set_callback(DPI_SCALE, DPIScaleHandler)

DPIScaleHandler()