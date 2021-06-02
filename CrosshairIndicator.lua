local curtime = globals.curtime
local key_state, unset_event_callback = client.key_state, client.unset_event_callback
local render_circle_outline, measure_text, render_text = renderer.circle_outline, renderer.measure_text, renderer.text
local table_insert = table.insert
local ui_get, is_menu_open, mouse_position = ui.get, ui.is_menu_open, ui.mouse_position

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

-- Drag
local isMoving = false
local grabX, grabY

-- WIP
local iWidthInPer, iHeightInPer = 51, 50
local RENDER_TEXT_FLAGS = 'd'

local function UpdateIndicatorTextFlags()
	if iWidthInPer > 50 then
		RENDER_TEXT_FLAGS = 'd'
	elseif iWidthInPer < 50 then
		RENDER_TEXT_FLAGS = 'dr'
	elseif iWidthInPer == 50 then
		RENDER_TEXT_FLAGS = 'dc'
	end
end
-- WIP

local function DragText(textH, m_textW, m_textH, iArrLength)
	if not is_menu_open() or not key_state(0x01) then
		isMoving = false
		return
	end

	local mX, mY = mouse_position()

	if iWidthInPer > 50 then
		isTextSelected = (mX >= Width and mX <= (Width+m_textW))
			and (mY >= textH and mY <= (textH+m_textH))
	elseif iWidthInPer < 50 then
		isTextSelected = (mX >= (Width-m_textW) and mX <= Width+15)
			and (mY >= textH and mY <= (textH+m_textH))
	elseif iWidthInPer == 50 then
		isTextSelected = (mX >= (Width-(m_textW/2)) and mX <= (Width+m_textW))
			and (mY >= textH and mY <= (textH+m_textH))
	end

	if not isTextSelected then
		return
	end

	if not isMoving then
		grabX, grabY = mX - Width, mY - (Height + (iArrLength*-indicatorTextGap) + (iArrLength*indicatorTextGap))
		isMoving = true
	end

	Width, Height = mX-grabX, mY-grabY

	-- Update indicator style based on position
	iWidthInPer = (Width / x) * 100
	iHeightInPer = ((Height + (iArrLength*-indicatorTextGap) + (iArrLength*indicatorTextGap)) / y) * 100
	UpdateIndicatorTextFlags()
end
--

-- Main
client.set_event_callback('paint', function ()
	-- Indicators array length
	local iArrLength = #indicators

	for i=1, iArrLength do
		local indicator = indicators[i]

		local text = indicator.text
		local r, g, b, a = indicator.r, indicator.g, indicator.b, indicator.a

		local textH
		if iHeightInPer >= 50 then
			textH = Height + (i*-indicatorTextGap) + (iArrLength*indicatorTextGap)
		else
			textH = Height + (i*-indicatorTextGap)
		end
		
		local m_textW, m_textH = measure_text(RENDER_TEXT_FLAGS, text)

		-- Drag
		DragText(textH, m_textW, m_textH, iArrLength)

		render_text(Width, textH, r, g, b, a, RENDER_TEXT_FLAGS, 0, text)

		if isBombBeingPlanted and text:find('Bombsite') then
			local cricleW, cricleH

			if RENDER_TEXT_FLAGS == 'd' then
				cricleW = Width+m_textW+o_circleRadius+4
				cricleH = textH+(m_textH/1.71)
			elseif RENDER_TEXT_FLAGS == 'dr' then
				cricleW = Width+o_circleRadius+4
				cricleH = textH+(m_textH/1.71)
			elseif RENDER_TEXT_FLAGS == 'dc' then
				cricleW = Width+(m_textW/2)+o_circleRadius+4
				cricleH = textH
			end

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