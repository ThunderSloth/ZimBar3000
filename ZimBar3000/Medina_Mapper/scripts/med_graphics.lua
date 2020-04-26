--------------------------------------------------------------------------------
--   GRAPHICAL FUNCTIONS
--------------------------------------------------------------------------------
-- draw map room according to solved status
function medina_draw_room(room, coor, col, mw) -- room, coordinates, colours, miniwindow
    local border_colour = med.rooms[room].solved and col.room_border or col.room_border_unsolved
    WindowCircleOp(mw, 2, -- draw room
	    coor.room.outer.x1, coor.room.outer.y1, coor.room.outer.x2, coor.room.outer.y2,            
	    border_colour, 0, 1,
	    col.room_background, 0)
end
-- draw room exits according to solved status
function medina_draw_room_exits(room, coor, col, mw) --room, coordinates, colours, miniwindow
    for norm, dir in pairs(med.rooms[room].normalized) do
        local border_colour = dir and col.exit_border or col.exit_border_unsolved
        local fill_colour = dir and col.exit_fill or col.exit_fill_unsolved
        WindowCircleOp(mw, 2, -- draw exit
            coor.exit[norm].x1, coor.exit[norm].y1, coor.exit[norm].x2, coor.exit[norm].y2,            
            border_colour, 0, 1,
            fill_colour, 0)
        if dir then WindowDrawImage(mw, dir, coor.exit[norm].x1 + 2, coor.exit[norm].y1 + 2, 0, 0, 1) end --if solved draw arrow
    end
end
-- base layer (rooms, exits, titlebar)
function medina_draw_base(dim, col) -- dimensions, colours
    local coordinates = med.coordinates
    WindowCircleOp( -- window border
        win.."base", miniwin.circle_rectangle, 
        0, 0, dim.window.x, dim.window.y,
        col.window_border, miniwin.pen_solid, 1,
        col.window_background, 0) 
    WindowLine( -- nw exit
        win.."base", 
        0, dim.block.y / 2, dim.buffer.x, dim.buffer.y + (dim.block.y / 2), 
        col.exit_line_entrance, miniwin.pen_dot, 1)
    WindowLine( -- se exit
        win.."base", 
        (dim.block.x * 6) + dim.buffer.x, (dim.block.y * 5.5) + dim.buffer.y, dim.window.x, dim.window.y - (dim.block.y / 2), 
        col.exit_line_entrance, miniwin.pen_dot, 1)
	WindowGradient (win.."base", 0, 0, dim.window.x, FIXED_TITLE_HEIGHT, -- titlebar
		col.titlebar_fill[1], 
        col.titlebar_fill[2], 
        miniwin.gradient_vertical)
    WindowRectOp(win.."base", miniwin.rect_draw_edge, 0, 0, dim.window.x, FIXED_TITLE_HEIGHT,
        miniwin.rect_edge_etched, 
        miniwin.rect_edge_at_all)
    local title = "Medina"
    local text_width = WindowTextWidth(win.."base", "titlebar_text", title)
    local x1 = (dim.window.x - text_width) / 2
    local y1 = coordinates.title_text.y1 
    local x2 = x1 + text_width
    local y2 = y1 + dim.font.titlebar_text
    WindowText(win.."base", "titlebar_text", title, x1, y1, x2, y2, col.titlebar_text)
    for room, coor in pairs(coordinates.rooms) do
        medina_draw_room(room, coor, col, win.."base") -- draw room
        medina_draw_room_exits(room, coor, col, win.."base") -- draw exits
    end
end
-- draw room letter
function medina_draw_room_letter(room, coor, col) -- room, coordinates, colours
    local letter_colour = med.rooms[room].visited and col.room_text_visited or col.room_text_unvisited
    WindowText (win.."overlay", "room_character", room,
        coor.letter.x1, coor.letter.y1, 0, 0,
        letter_colour, 
        false)
end
-- room-letter layer
function medina_draw_overlay(dim, col) -- dimensions, colours
    WindowCircleOp( -- transparent background
        win.."overlay", miniwin.circle_rectangle, 
        0, 0, dim.window.x, dim.window.y,
        col.window_transparency, miniwin.pen_solid, 1,
        col.window_transparency, 0)
    local coordinates = med.coordinates
    for room, coor in pairs(coordinates.rooms) do
        medina_draw_room_letter(room, coor, col)
    end
end
-- draw dynamic elements (you, mobs, highlights ect.) on top of 
-- base (rooms, exits, titlebar) and layer overlay (room-letters) on top, then display
function medina_print_map()
    local start_time = os.clock()
    local function draw_exit_text(coor, dim, current_room)
        local function get_exit_text_info(unsolved_exits, col, absolute_current)
            local function get_exit_colour(dir, col, absolute_current)
                if absolute_current then
                    if med.rooms[absolute_current].exits and med.rooms[absolute_current].exits[dir] and med.rooms[absolute_current].exits[dir].exits then
                        return col.exit_text_halfsolved
                    else
                        return col.exit_border_unsolved
                    end
                else
                    return col.exit_border_unsolved
                end
            end
            local exit_text, for_text_length, comma = {}, "[", false
            for _, v in ipairs(unsolved_exits) do
                if comma then
                    table.insert(exit_text, {colour = col.exit_text_comma, text = ", "})
                    for_text_length = for_text_length..", "
                else
                    table.insert(exit_text, {colour = col.exit_text_bracket, text = "["})
                end
                table.insert(exit_text, {colour = get_exit_colour(v, col, absolute_current), text = v})
                for_text_length = for_text_length..v
                comma = true
            end
            for_text_length = for_text_length.."]"
            table.insert(exit_text, {colour = col.exit_text_bracket, text = "]"})
            return WindowTextWidth(win, "room_character", for_text_length), exit_text
        end
        local directions = {n = true, ne = true, e = true, se = true, s = true, sw = true, w = true, nw = true}
        for dir, _ in pairs(directions) do WindowDeleteHotspot(win, dir) end
        local unsolved_exits = {}
        local absolute_current = #current_room == 1 and current_room[1] or false
        if absolute_current and med.rooms[absolute_current].exits then
            for dir, solved in medina_order_exits(med.rooms[current_room[1]].exits) do
                if not(absolute_current == "A" and dir == "nw") and not(absolute_current == "R" and dir == "se") and not(solved.room) then table.insert(unsolved_exits, dir) end
            end
        elseif current_room.exits then
            for dir, _ in medina_order_exits(current_room.exits) do
                table.insert(unsolved_exits, dir)
            end
        end
        if #unsolved_exits > 0 then
            local text_width, exit_text = get_exit_text_info(unsolved_exits, med.colours, absolute_current)
            local x1 = (dim.window.x - text_width) / 2
            local y1 = coor.y1
            local y2 = y1 + dim.font.room_character
            for _, v in ipairs(exit_text) do
                local x2 = x1 + WindowTextWidth(win, "room_character", v.text)
                if directions[v.text] then
                     WindowAddHotspot(win, v.text,  
                        x1, y1, x2, y2,
                        "mouseover", 
                        "cancelmouseover", 
                        "mousedown",
                        "cancelmousedown", 
                        "mouseup", 
                        "Look "..v.text,
                        miniwin.cursor_hand, 0)
                end
                x1 = x1 + WindowText(win, "room_character", v.text, x1, y1, x2, y2, v.colour)
            end
        end
    end
    local function draw_dynamic(coordinates, col, current_room, look_room, scry_room)
		-- draw outer room fill
		local function draw_look(room, coor, colour1, colour2) -- room, coordinates, colours
            local fill_style = #room == 1 and 0 or 8
            for _ , r in ipairs(room) do
                WindowCircleOp(win, 2,
                    coor[r].room.outer.x1, coor[r].room.outer.y1, coor[r].room.outer.x2, coor[r].room.outer.y2,            
                    med.colours.window_background, 0, 0,
                    colour1, fill_style)
                WindowRectOp (win, 1, coor[r].room.outer.x1, coor[r].room.outer.y1, coor[r].room.outer.x2, coor[r].room.outer.y2, colour2)
            end
        end
        -- draw inner room fill
        local function draw_thyng(room, coor, colour) -- room, coordinates, colours
            local fill_style = #room == 1 and 0 or 8
            for _ , r in ipairs(room) do
                WindowCircleOp(win, 2,
                    coor[r].room.inner.x1, coor[r].room.inner.y1, coor[r].room.inner.x2, coor[r].room.inner.y2,            
                    med.colours.window_background, 0, 0,
                    colour, fill_style)
                WindowRectOp (win, 1, coor[r].room.inner.x1, coor[r].room.inner.y1, coor[r].room.inner.x2, coor[r].room.inner.y2, colour)
            end
        end
        -- colour room border
        local function draw_border(room, coor, colour)
            for _ , r in ipairs(room) do
                WindowRectOp(win, 1, coor[r].room.outer.x1, coor[r].room.outer.y1, coor[r].room.outer.x2, coor[r].room.outer.y2, colour)
            end
        end
        local function draw_exit_border(coor, colour)
			WindowRectOp(win, 1, coor.x1, coor.y1, coor.x2, coor.y2, colour)			
        end
        --highlight herd path
        function draw_herd_path(coor, col)
			local herd_path = med.herd_path
			for herd_start, dir in pairs(herd_path) do
				local herd_set = {}
				local herd_room = herd_start
				local break_at = 100
				while med.rooms[herd_room].exits and med.rooms[herd_room].exits[dir] and med.rooms[herd_room].exits[dir].room do
					local previous_room = herd_room
					herd_room = med.rooms[herd_room].exits[dir].room
					if not herd_set[herd_room] then
						herd_set[herd_room] = dir
						draw_border({herd_room}, coor, col)
						local static_exit = med.rooms[previous_room].exit_rooms[herd_room]
						draw_exit_border(coor[previous_room].exit[static_exit], col)
					else
						break
					end
					break_at = break_at - 1; if break_at <= 0 then break end
				end
			end
        end
        -- insert players/mobs
        local function draw_population(coordinates, col)
			local fill_colours = {}
			for room, v in pairs(med.rooms) do
				local player_room = false
				local room_colour = false
				for p, c in pairs(v.thyngs.players) do
					player_room = true
					room_colour = c
					break
				end
				if not room_colour then
					room_colour = v.thyngs.mobs.boss == 1 and col.room_inner_fill_boss or false
				end
				if not room_colour then
					local xp = v.thyngs.mobs.thugs + 2 * v.thyngs.mobs.heavies
					if xp > 0 then
						room_colour = col.room_inner_fill_xp[xp > 9 and 9 or xp]
					end
				end
				if room_colour then
					draw_thyng({room}, coordinates.rooms, room_colour)
					fill_colours[room] = {bg_colour = room_colour, colour = player_room and col.room_text_player or col.room_text_xp[#col.room_text_xp]}
				end
			end
			return fill_colours
        end
        -- creating a styles table to send to our mdt plugin
        local function get_text_styles(current_room, trajectory_room, look_room, scry_room, fill_colours, col)
			if IsPluginInstalled(MDT) and PluginSupports(MDT, "mdt_special_area_text") == error_code.eOK then
				local icon_styles = {}
				for r, v in pairs(fill_colours) do
					icon_styles[r] = {
						colour = med.rooms[r].visited and col.room_text_visited or col.room_text_unvisited,
						colour = v.colour,
						bg_colour = v.bg_colour,
						border_colour = med.rooms[r].solved and col.room_border or col.room_border_unsolved,
						fill_style = 0
					}
				end
				for _, r in ipairs(current_room) do
					if icon_styles[r] then
						local fill_style = #current_room == 1 and 0 or 8
						icon_styles[r].bg_colour = col.room_inner_fill_you
						icon_styles[r].colour = col.room_text_player
						icon_styles[r].fill_style = fill_style
						icon_styles[r].border_colour = col.room_border
					end
				end
				for _, r in ipairs(trajectory_room) do
					if icon_styles[r] then
						icon_styles[r].border_colour = col.room_border_trajectory
					end
				end
				local text_styles = {}
				for k, v in pairsByKeys(icon_styles) do
					table.insert(text_styles,{{
						text = k,
						colour = v.colour,
						bg_colour = v.bg_colour,
						border_colour = v.border_colour,
						fill_style = v.fill_style,
					},{ -- placeholder for path
						text = "",
						colour = col.path_text,
						bg_colour = false,
						border_colour = false,
						fill_style = 0,	
					}})
					local mobs = {
						boss    = med.rooms[k].thyngs.mobs.boss,
						heavies = med.rooms[k].thyngs.mobs.heavies,
						thugs   = med.rooms[k].thyngs.mobs.thugs,	
					}
					-- exploiting the fact that "boss, heavies, thugs" 
					-- just happens to be in alphabetical order 
					for mob, n in pairsByKeys(mobs) do
						local text, colour, bg_colour, border_colour, underline, fill_style = "", col.room_text_xp[#col.room_text_xp], false, false, false, 0
						if n > 0 then
							if mob == "boss" then
								text = "boss"
								bg_colour = col.room_inner_fill_boss
							elseif mob == "heavies" then
								if n > 1 then
									text = tostring(n).." heavies"
								else
									text = "heavy"
								end
								bg_colour = col.room_inner_fill_xp[n * 2 > 9 and 9 or n * 2]
							elseif mob == "thugs" then
								if n > 1 then
									text = tostring(n).." thugs"
								else
									text = "thug"
								end
								if n < 4 then
									colour = col.room_text_xp[n + 1]
								else
									bg_colour =	col.room_inner_fill_xp[n > 9 and 9 or math.ceil(n)]
								end
							end
							table.insert(text_styles[#text_styles], {
								text = text,
								colour = colour,
								bg_colour = bg_colour,
								border_colour = border_colour,
								fill_style = 0,						
							})
						end
					end
					for player, player_colour in pairsByKeys(med.rooms[k].thyngs.players) do
							table.insert(text_styles[#text_styles], {
								text = player,
								colour = col.room_text_player,
								bg_colour = player_colour,
								border_colour = false,
								fill_style = 0,						
							})
					end
				end
				CallPlugin(MDT, "mdt_special_area_text", "text_styles = "..serialize.save_simple(text_styles), "Somewhere In An Alleyway")
			end
        end
        local trajectory_room = #med.sequence ~= 0 and med.sequence[#med.sequence] or {} 
        draw_look(look_room, coordinates.rooms, col.room_outer_fill_look, col.room_border_look) -- look
        draw_look(scry_room, coordinates.rooms, col.room_outer_fill_scry, col.room_border_scry) -- scry
		local fill_colours = draw_population(coordinates, col)
		draw_thyng(current_room, coordinates.rooms, col.room_inner_fill_you) -- you
		draw_herd_path(coordinates.rooms, col.room_border_exit_set)
		draw_border(trajectory_room, coordinates.rooms, col.room_border_trajectory) -- ghost
		get_text_styles(current_room, trajectory_room, look_room, scry_room, fill_colours, col)
    end
    local current_room, look_room, scry_room = med.sequence[1] or {}, med.look_room or {}, med.scry_room or {}
    WindowImageFromWindow(win, "base", win.."base")
    WindowDrawImage(win, "base", 0, 0, 0, 0, 1) -- draw base
    draw_dynamic(med.coordinates, med.colours, current_room, look_room, scry_room) -- add dynamic
    draw_exit_text(med.coordinates.exit_text, med.dimensions, current_room)
    WindowImageFromWindow(win, "overlay", win.."overlay")
    WindowDrawImage(win, "overlay", 0, 0, 0, 0, 3) -- draw overlay
    WindowShow(win, true)
    --print(os.clock() - start_time) -- speed test
end
