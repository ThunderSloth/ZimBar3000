
--------------------------------------------------------------------------------
--   HOTSPOTS
--------------------------------------------------------------------------------
function shades_get_hotspots(dim) -- dimensions
    WindowAddHotspot(win, "title",
         0, 0, dim.window.x, dim.font.titlebar_text, 
         "",   -- MouseOver
         "",   -- CancelMouseOver
         "mousedown",
         "cancelmousedown", 
         "mouseup", 
        "Left-click to drag!", -- tooltip text
         1, 0)  -- hand cursor
    WindowDragHandler(win, "title", "dragmove", "dragrelease", 0)
    -- add handler for resizing
    WindowAddHotspot(win, "resize", dim.window.x - 10, dim.window.y - 10, dim.window.x, dim.window.y, "MouseOver", "CancelMouseOver", "mousedown", "", "MouseUp", "Left-click to resize!", 6, 0)
    WindowDragHandler(win, "resize", "ResizeMoveCallback", "ResizeReleaseCallback", 0)
    for r, v in pairs(sha.rooms) do
        local coor = sha.coordinates.rooms[r].room.outer
        WindowAddHotspot(win, r,
             coor.x1, coor.y1, coor.x2, coor.y2,
             "",   -- MouseOver
             "",   -- CancelMouseOver
             "mousedown",
             "cancelmousedown", 
             "mouseup", 
             '', -- tooltip text
             1, 0)  -- hand cursor
    end
end
--------------------------------------------------------------------------------
--   HOTSPOT HANDLERS
--------------------------------------------------------------------------------
function dragmove(flags, hotspot_id)
	if hotspot_id == "title" then
        local max_x, max_y = GetInfo(281), GetInfo(280)
        local min_x, min_y = 0, 0
		local drag_x, drag_y = WindowInfo(win, 17), WindowInfo(win, 18)
        local to_x, to_y = drag_x - from_x, drag_y - from_y
        if to_x < min_x then 
            to_x = 0 
        elseif to_x + window_width> max_x then
            to_x = max_x - window_width
        end
        if to_y < min_y then 
            to_y = 0 
        elseif to_y + window_height > max_y then
            to_y = max_y - window_height
        end
		WindowPosition(win, to_x, to_y, 0, 2) -- move the window to the new location
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
function ResizeMoveCallback()
    local auto_pos = WindowInfo(win, 7)
    if auto_pos ~= 0 then 
		-- workaround to weirdness with intitial resize, if window has not
		-- yet been moved with drag-handler. Basically, auto positioning is calculated 
		-- each time the screen is redrawn so we have to force a redraw to know
		-- it's coordinates and then manually position the window to where it already is 
		-- in order to remove it from auto-positioning mode
		Repaint() 
		WindowPosition(win, WindowInfo(win, 10), WindowInfo(win, 11), 0, 2)
	end
    local min = 300
    local start_x, start_y = WindowInfo(win, 10), WindowInfo(win, 11)
    local drag_x,   drag_y = WindowInfo(win, 17), WindowInfo(win, 18)
    local max_x,     max_y = GetInfo(281),        GetInfo(280)
    window_width  = drag_x - start_x
    window_height = drag_y - start_y
    window_pos_x =  drag_x
    window_pos_y =  drag_y
    if window_width > window_height then -- force square
        window_height = window_width
    else
        window_width = window_height
    end
    local out_of_bounds = false
    if window_width  + start_x > max_x then 
        window_width  = max_x - start_x; window_height = window_width; out_of_bounds = true
    end
    if window_height + start_y > max_y then 
        window_height = max_y - start_y; window_width  = window_height; out_of_bounds = true
    end
    if window_width  < min then 
        window_width  = min; window_height = window_width; out_of_bounds = true 
    end
    if window_height < min then 
        window_height = min; window_width  = window_height; out_of_bounds = true
    end
    if out_of_bounds then
        check(SetCursor(11)) -- x cursor
    else
        check(SetCursor(6)) -- resize cursor
    end
    if (utils.timer() - (last_refresh or 0) > 0.0333) then
        WindowResize(win, window_width, window_height, sha.colours.window_background)
        WindowDrawImage(win, "win", 0, 0, window_width, window_height, 2)
        WindowShow(win)
        last_refresh = utils.timer()
   end
end

-- called after the resize widget is released
function ResizeReleaseCallback()
    shades_window_setup(window_width, window_height)
    shades_get_hotspots(sha.dimensions)
    shades_print_map()
end

-- called when mouse button is pressed on hotspot
function mousedown(flags, hotspot_id)
    if hotspot_id == "title" then
		from_x, from_y = WindowInfo(win, 14), WindowInfo(win, 15)
    elseif (hotspot_id == "resize") then
        WindowImageFromWindow(win, "win", win)
    end
end

function mouseup(flags, id)
	if id:match("title") and flags == 32 then
		shades_get_title_menu()
	elseif id:match("^[A-Z]$") and flags == 16 then
        shades_get_shortest_path(sha.rooms, sha.sequence[#sha.sequence][1], id)
    end
end

