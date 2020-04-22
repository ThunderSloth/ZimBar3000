--------------------------------------------------------------------------------
--   HOTSPOTS (MAIN WINDOW)
--------------------------------------------------------------------------------
function voyage_get_hotspots(dim) -- dimensions
	WindowDeleteAllHotspots(win)
	WindowAddHotspot(win, "title",
		 0, 0, dim.window.x, dim.font.title, 
		 "",
		 "",  
		 "mousedown",
		 "cancelmousedown", 
		 "mouseup", 
		"Left-click to drag!",
		 1, 0)
	WindowDragHandler(win, "title", "dragmove", "dragrelease", 0)
	-- add handler for resizing
	WindowAddHotspot(win, "resize", dim.window.x - 10, dim.window.y - 10, dim.window.x, dim.window.y, "MouseOver", "CancelMouseOver", "mousedown", "", "MouseUp", "Left-click to resize!", 6, 0)
	WindowDragHandler(win, "resize", "ResizeMoveCallback", "ResizeReleaseCallback", 0)
	local title = {
			"fore end of the upper deck",
			"port fore corner of the upper deck",
			"bridge of the SS Unsinkable",
			"starboard fore corner of the upper deck",
			"port side of the upper deck",
			"middle of the upper deck",
			"starboard side of the upper deck",
			"port aft corner of the upper deck",
			"aft end of the upper deck",
			"starboard aft corner of the upper deck",
			"fore corner of the lower deck",
			"port fore corner of the lower deck",
			"Store C",
			"starboard fore corner of the lower deck",
			"port corridor of the lower deck",
			"Store B",
			"starboard corridor of the lower deck",
			"port boiler room",
			"Store A",
			"starboard boiler room",
			"the Circle Sea near the SS Unsinkable",
			"the Circle Sea near the SS Unsinkable (under-water)",
			"atop the mast",}
	for r, v in ipairs(voy.coordinates.rooms) do -- rooms
		WindowAddHotspot(win, r,  
			v.room.outter.x1, v.room.outter.y1, v.room.outter.x2, v.room.outter.y2,
			"mouseover", 
			"cancelmouseover", 
			"mousedown",
			"cancelmousedown", 
			"mouseup", 
			title[r],
			miniwin.cursor_hand, 0)
	end
	local order = {
		{"tanks", "rods", "toys", "balls", "polish", "coal", "bottles",},
		{"ropes", "nails", "boards", "hammers", "buckets", "towels", "lemons",},
		{"harpoons", "axes", "arbalests", "bolts", "bandages",},}
	local coor = voy.coordinates.text.object
	for i, t in ipairs(order) do
		for ii, v in ipairs(t) do
			WindowAddHotspot(win, "object"..tostring(i)..v,  -- object lists
				coor[ii][i].x1, coor[ii][i].y1, coor[ii][i].x2, coor[ii][i].y2,
				"mouseover", 
				"cancelmouseover", 
				"mousedown",
				"cancelmousedown", 
				"mouseup", 
				v,
				miniwin.cursor_hand, 0)
		end
	end
	local coor = voy.coordinates.guage -- dragon levels
	for k, v in pairs(voy.dragon) do
		local i = v.guage
		WindowAddHotspot(win, "hunger_"..k,
			coor[i].x1, coor[i].y1, coor[i].x2, coor[i].y2,
			"mouseover", 
			"cancelmouseover", 
			"mousedown",
			"cancelmousedown", 
			"mouseup", 
			"Hunger: "..k:gsub("^%l", string.upper),
			miniwin.cursor_hand, 0) 
		WindowAddHotspot(win, "boredom_"..k,
			coor[i].x1, coor[i].y2, coor[i].x2, coor[i].y3,
			"mouseover", 
			"cancelmouseover", 
			"mousedown",
			"cancelmousedown", 
			"mouseup", 
			"Boredom: "..k:gsub("^%l", string.upper),
			miniwin.cursor_hand, 0)
	end
	for k, v in pairs(voy.coordinates.circle) do
		WindowAddHotspot(win, "0circle_"..tostring(k), -- '0circle' to gain priority over rooms
			v.outter.x1, v.outter.y1, v.outter.x2, v.outter.y2,
			"mouseover", 
			"cancelmouseover", 
			"mousedown",
			"cancelmousedown", 
			"mouseup", 
			(k == 18 and "Port" or "Starboard").." Dragon Circle",
			miniwin.cursor_hand, 0)
	end
	coor = voy.coordinates.held
	local bottom = voy.coordinates.circle[20].outter.y1
	WindowAddHotspot(win, "L", --left held
		coor.L.x1, coor.L.y1, coor.L.x2, bottom,
		"mouseover", 
		"cancelmouseover", 
		"mousedown",
		"cancelmousedown", 
		"mouseup", 
		"Left Hand",
		miniwin.cursor_hand, 0)
	WindowAddHotspot(win, "R", --right held
		coor.R.x1, coor.R.y1, coor.R.x2, bottom,
		"mouseover", 
		"cancelmouseover", 
		"mousedown",
		"cancelmousedown", 
		"mouseup", 
		"Right Hand",
		miniwin.cursor_hand, 0)
	coor = voy.coordinates.kraken
	WindowAddHotspot(win, "z_monster",
		coor.x1, coor.y1, coor.x2, coor.y2,
		"mouseover", 
		"cancelmouseover", 
		"mousedown",
		"cancelmousedown", 
		"mouseup", 
		"Combat Area",
		miniwin.cursor_plus, 0)  -- crosshair
	coor = voy.coordinates.text.object[6][3]
	local x1 = voy.coordinates.text.object[6][3].x1
	local y1 = voy.coordinates.text.object[6][3].y1
	local x2 = voy.coordinates.text.object[7][3].x2
	local y2 = voy.coordinates.text.object[7][3].y2
	WindowAddHotspot(win, "xp",
		coor.x1, coor.y1, coor.x2, coor.y2,
		"mouseover", 
		"cancelmouseover", 
		"mousedown",
		"cancelmousedown", 
		"mouseup", 
		"Xp / Hr",  
		miniwin.cursor_hand, 0)  
	coor = voy.coordinates.text.object[7][3]
	WindowAddHotspot(win, "time",
		coor.x1, coor.y1, coor.x2, coor.y2,
		"mouseover", 
		"cancelmouseover", 
		"mousedown",
		"cancelmousedown", 
		"mouseup", 
		"Time Since Boarding", 
		miniwin.cursor_hand, 0)  
end
--------------------------------------------------------------------------------
--   HOTSPOTS (STEERING MODE)
--------------------------------------------------------------------------------
function voyage_get_steering_hotspots(dim)
    local notches = {[-2] = 'Wheel Leftmost', [-1] = 'Wheel Left', [0] = 'Wheel Center', [1] = 'Wheel Right', [2] = 'Wheel Rightmost'}
    for k, v in pairs(voy.coordinates.direction) do
        WindowAddHotspot(win, "notch"..k,
            v.x1, v.y1, v.x2, v.y2,
            "mouseover", 
            "cancelmouseover", 
            "mousedown",
            "cancelmousedown", 
            "mouseup", 
            notches[k],  
            miniwin.cursor_hand, 0)  
    end
    coor = voy.coordinates.sea.exit
    WindowAddHotspot(win, "x",
        coor.x1, coor.y1, coor.x2, coor.y2,
        "mouseover", 
        "cancelmouseover", 
        "mousedown",
        "cancelmousedown", 
        "mouseup", 
        "Unhold Wheel",  
        miniwin.cursor_hand, 0)
    coor = voy.coordinates.sea.map[2][3]
    WindowAddHotspot(win, "overboard",
        coor.x1, coor.y1, coor.x2, coor.y2,
        "mouseover", 
        "cancelmouseover", 
        "mousedown",
        "cancelmousedown", 
        "mouseup", 
        "Jump Overboard and Back!",  
        miniwin.cursor_hand, 0)     
    coor = voy.coordinates.sea.map[3][3]
    WindowAddHotspot(win, "hull",
        coor.x1, coor.y1, coor.x2, coor.y2 - (coor.y2 - coor.y1) / 2,
        "mouseover", 
        "cancelmouseover", 
        "mousedown",
        "cancelmousedown", 
        "mouseup", 
        "Update Hull",  
        miniwin.cursor_hand, 0)  
    WindowAddHotspot(win, "speed",
        coor.x1, coor.y2 - (coor.y2 - coor.y1) / 2, coor.x2, coor.y2,
        "mouseover", 
        "cancelmouseover", 
        "mousedown",
        "cancelmousedown", 
        "mouseup", 
        "Update Speed",
        miniwin.cursor_hand, 0)
end
--------------------------------------------------------------------------------
--   HOTSPOTS (SERPENT / KRAKEN)
--------------------------------------------------------------------------------
function voyage_get_hotspot_monster(coor, monster)
	WindowAddHotspot(win, monster,
		 coor[monster].head.x1, coor[monster].head.y1, coor[monster].head.x2, coor[monster].head.y2, 
		 "",   
		 "",   
		 "mousedown",
		 "cancelmousedown", 
		 "mouseup", 
		 monster:gsub("^%l", string.upper)..'!', 
		 3, 0)  
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
        WindowResize(win, window_width, window_height, ColourNameToRGB("white"))
        WindowDrawImage(win, "win", 0, 0, window_width, window_height, 2)
        WindowShow(win)
        last_refresh = utils.timer()
   end
end
-- called after the resize widget is released
function ResizeReleaseCallback()
    voyage_window_setup(window_width, window_height, voy.colours)
    voyage_print_map() -- draw map before loading vertical fonts in order to mitigate lag
    voyage_get_hotspots(voy.dimensions)
    if voy.sea then
        voyage_captain_mode_on()
    end
    rotate_vertical_font(voy.colours)
    voyage_print_map() -- display with vertical fonts
end
-- called when mouse button is pressed on hotspot
function mousedown(flags, hotspot_id)
    if hotspot_id == "title" then
		from_x, from_y = WindowInfo(win, 14), WindowInfo(win, 15)
    elseif (hotspot_id == "resize") then
        WindowImageFromWindow(win, "win", win)
    end
end
-- on mouse up
function mouseup(flags, id)
    if id:match("^[0-9]+$") then
        local room = tonumber(id)
        if flags == 16 then -- left click
            voyage_get_shortest_path(voy.rooms, voy.sequence[#voy.sequence], room)
        elseif flags == 32 then -- right click
            if room then
                voyage_get_room_menu(room)
            end
        elseif flags == 80 then -- double-click
            if room == 21 then
                voyage_get_shortest_path(voy.rooms, voy.sequence[#voy.sequence], room)
                voy.commands.move.count = (voy.commands.move.count or 0) + 1
                Send("board")
                table.insert(voy.sequence, voy.rooms[21].board.board)
                voyage_print_map()
            else
                voy.doubleclick.options[voy.doubleclick.selected]()
            end
        end
    elseif id:match("object") then
        local column, object = id:match("object([1-3])(%w+)")
        if flags == 32 then
            voyage_get_object_menu(object, tonumber(column))
        elseif flags == 16 or flags == 80 then
            if voy.look_room then
                voyage_get_shortest_path(voy.rooms, voy.sequence[#voy.sequence], voy.look_room)
            end
            if object == "tanks" then
                if voy.drag.on and voy.drag.object:match("tank") then
                    voy.drag.on = false
                    ColourNote(voy.colours.notes.text, voy.colours.notes.background, 'Drag: off')
                else
                    voy.drag = {object = "tank", on = true}
                    ColourNote(voy.colours.notes.text, voy.colours.notes.background, 'Drag: "tank"')
                end
            elseif object == "toys" then
				Send("get 1 toy animal")
            else
                Send("get 1 "..object:gsub("s$", ""))
            end
        end
    elseif id:match("hunger") or id:match("boredom") then
        if flags == 32 then
        local dragon = id:match("^%w+_(%w+)")
        voyage_get_dragon_menu(dragon)
        elseif flags == 16 then
            Send("look dragons")
        end
    elseif id:match("circle") then
        local room = tonumber(id:match("_(%d%d)"))
        if flags == 32 then
            voyage_get_circle_menu(room)
        elseif flags == 16 then
            voyage_get_shortest_path(voy.rooms, voy.sequence[#voy.sequence], room)
            Send("look dragons")
        end
    elseif id == "L" or id == "R" then
        if flags == 32 then
            voyage_get_held_menu(id)
        elseif flags == 16 then
            Send("inventory")
        end
    elseif id:match("serpent") or id:match("kraken") or id:match("z_monster") then
        if flags == 32 then
            voyage_get_monster_menu(id)
        elseif flags == 16 then
            if id:match("z_monster") then
                voyage_reload()
            else
                voyage_fire()
            end
        end
    elseif id:match("title") and flags == 32 then
        voyage_get_title_menu()
    elseif (id == "time" or id == "xp") and flags == 16 then
        on_alias_voyage_print_xp()
    elseif id:match("notch") then
        if flags == 16 then
            local notch = tonumber(id:match("notch(.*)"))
            voyage_turn_wheel(notch)
        elseif flags == 32 then
            voyage_get_compass_menu(id)
        end
    elseif id == "x" then
        Send("unhold wheel")
        on_trigger_voyage_steering_off()
    elseif id == "hull" or id == "speed" or id == "overboard" then
		if flags == 32 then
			voyage_get_sea_menu()
		elseif id == "hull" then
			Send("look overboard")
		elseif id == "speed" then
			Send("look")
		elseif id == "overboard" then
			Send("overboard")
			Send("board")
			Send("hold wheel")
		end
    end
end
