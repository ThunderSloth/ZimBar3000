--------------------------------------------------------------------------------
--   HOTSPOTS
--------------------------------------------------------------------------------
function mdt_get_hotspots(dim) -- dimensions
	for i in ipairs(win) do
		-- titlebar
	    WindowAddHotspot(
			win[i], "title"..tostring(i),
			0, 0, dim.window[i].x, dim.font.title, 
			"", "", "mousedown", "cancelmousedown", "mouseup", 
			"Left-click to drag!", 1, 0)
		-- add drag handler
		WindowDragHandler(win[i], "title"..tostring(i), "dragmove", "dragrelease", 0)
		-- add resize handler
		WindowAddHotspot(
			win[i], "resize"..tostring(i), 
			dim.window[i].x - 10, dim.window[i].y - 10, dim.window[i].x, dim.window[i].y, 
			"MouseOver", "CancelMouseOver", "mousedown", "", "MouseUp", 
			"Left-click to resize!", 6, 0)
		WindowDragHandler(win[i], "resize"..tostring(i), "resizemove", "resizerelease", 0)
    end
end
--------------------------------------------------------------------------------
--   HOTSPOT HANDLERS
--------------------------------------------------------------------------------
function dragmove(flags, hotspot_id)
	if hotspot_id:match("title%d") then
		local mw = tonumber(hotspot_id:match("title(%d)$"))
		local max_x, max_y = GetInfo(281), GetInfo(280)
        local min_x, min_y = 0, 0
        local drag_x, drag_y = WindowInfo(win[mw], 17), WindowInfo(win[mw], 18)
        local to_x, to_y = drag_x - from_x, drag_y - from_y
        if to_x < min_x then 
            to_x = 0 
        elseif to_x + window_width[mw]> max_x then
            to_x = max_x - window_width[mw]
        end
        if to_y < min_y then 
            to_y = 0 
        elseif to_y + window_height[mw] > max_y then
            to_y = max_y - window_height[mw]
        end
		WindowPosition(win[mw], to_x, to_y, 0, 2) -- move the window to the new location
		if drag_x < min_x or drag_x > max_x or
		   drag_y < min_y or drag_y > max_y then -- change the mouse cursor shape appropriately
			check(SetCursor(11)) -- x cursor
		else
			check(SetCursor(1)) -- hand cursor
		end
	end
end

function dragrelease(flags, hotspot_id) end
-- called when the resize drag widget is moved
function resizemove(flags, hotspot_id)
	local mw = tonumber(hotspot_id:match("(%d)$"))
    local min = {100, 100}
    local start_x, start_y = WindowInfo(win[mw], 10), WindowInfo(win[mw], 11)
    local drag_x,   drag_y = WindowInfo(win[mw], 17), WindowInfo(win[mw], 18)
    local max_x,     max_y = GetInfo(281),        GetInfo(280)
    window_width [mw] = drag_x - start_x
    window_height[mw] = drag_y - start_y
    window_pos_x [mw] = drag_x
    window_pos_y [mw] = drag_y
    -- force square + titlebar for map window
    if mw == 1 then
		if window_width[mw] > window_height[mw] - FIXED_TITLE_HEIGHT then 
			window_height[mw] = window_width[mw] + FIXED_TITLE_HEIGHT
		else
			window_width[mw] = window_height[mw] - FIXED_TITLE_HEIGHT
		end
    end
    local out_of_bounds = false
    if window_width[mw]  + start_x > max_x then 
        window_width[mw]  = max_x - start_x
		if mw == 1 then
			window_height[mw] = window_width[mw] + FIXED_TITLE_HEIGHT
        end
        out_of_bounds = true
    end
    if window_height[mw] + start_y > max_y then 
        window_height[mw] = max_y - start_y
        if mw == 1 then
			window_width[mw]  = window_height[mw] - FIXED_TITLE_HEIGHT
        end
        out_of_bounds = true
    end
    if window_width[mw]  < min[mw] then 
        window_width[mw]  = min[mw]
        if mw == 1 then
			window_height[mw] = window_width[mw] + FIXED_TITLE_HEIGHT
        end
        out_of_bounds = true 
    end
    if window_height[mw] < min[mw] then 
        window_height[mw] = min[mw]
        if mw == 1 then
			window_width[mw]  = window_height[mw] - FIXED_TITLE_HEIGHT
        end
        out_of_bounds = true
    end
    if out_of_bounds then
        check(SetCursor(11)) -- x cursor
    else
        check(SetCursor(6)) -- resize cursor
    end
    if (utils.timer() - (last_refresh or 0) > 0.0333) then
        WindowResize(win[mw], window_width[mw], window_height[mw], mdt.colours.window.background)
        WindowDrawImage(win[mw], "win"..tostring(mw), 0, 0, window_width[mw], window_height[mw], 2)
        WindowShow(win[mw])
        last_refresh = utils.timer()
   end
end
-- called after the resize widget is released
function resizerelease(flags, hotspot_id)
	local mw = tonumber(hotspot_id:match("(%d)$"))
    mdt_window_setup(window_width, window_height)
    mdt_get_hotspots(mdt.dimensions)
    if mw == 1 then
		mdt_draw_map(mdt.rooms)
    else
		mdt_draw_text(mdt.styles)
    end
end
-- called when mouse button is pressed on hotspot
function mousedown(flags, hotspot_id)
	local mw = tonumber(hotspot_id:match("(%d)$"))
    if hotspot_id:match("title") then
		from_x, from_y = WindowInfo(win[mw], 14), WindowInfo(win[mw], 15)
    elseif hotspot_id:match("resize") then
        WindowImageFromWindow(win[mw], "win"..tostring(mw), win[mw])
    end
end

function mouseup(flags, id)

end
