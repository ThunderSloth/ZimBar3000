-------------------------------------------------------------------------------
--  GRAPHICAL FUNCTIONS
-------------------------------------------------------------------------------
function shades_draw_room(room, coor, col, mw) -- room, coordinates, colours, miniwindow
    WindowCircleOp(mw, 2, -- draw room
	    coor.room.outer.x1, coor.room.outer.y1, coor.room.outer.x2, coor.room.outer.y2,            
	    col.room_border, 0, 1,
	    col.room_background, 0)
end

function shades_draw_room_exits(room, coor, col, mw) --room, coordinates, colours, miniwindow
    for norm, num in pairs(sha.rooms[room].normalized) do
        WindowCircleOp(mw, 2, -- draw exit
            coor.exit[norm].border.x1, coor.exit[norm].border.y1, coor.exit[norm].border.x2, coor.exit[norm].border.y2,            
            col.exit_border, 0, 1,
            col.exit_fill, miniwin.brush_solid)
        if not(room == "K" and (norm == "ne" or norm == "se")) then
            WindowLine(
                mw, 
                coor.exit[norm].line.x1, coor.exit[norm].line.y1, coor.exit[norm].line.x2, coor.exit[norm].line.y2,
                col.exit_line_link, miniwin.pen_solid, 1)
        end
        shades_draw_exit_number(num, coor.exit[norm], col.exit_number[num])
    end
end

function shades_draw_exit_number(num, coor, col) -- room, coordinates, colours
    WindowText (win.."base", "exit_number", num,
        coor.letter.x1, coor.letter.y1, 0, 0,
        col, 
        false)
end

function shades_draw_base(dim, col) -- dimensions, colours
    local coordinates = sha.coordinates
    WindowCircleOp( -- window border
        win.."base", miniwin.circle_rectangle, 
        0, 0, dim.window.x, dim.window.y,
        col.window_border, miniwin.pen_solid, 1,
        col.window_background, 0)
    WindowLine( -- w exit
        win.."base", 
        coordinates.w_exit.x1, coordinates.w_exit.y1, coordinates.w_exit.x2, coordinates.w_exit.y2, 
        col.exit_line_entrance, miniwin.pen_dot, 1)
    for _, r in ipairs({"B", "Q"}) do
        WindowPolygon(win.."base", sha.coordinates.arrowhead[r],
            col.exit_arrow, miniwin.pen_solid, 1,
            col.exit_arrow, miniwin.brush_solid,
            true,
            false)
        WindowBezier (win.."base", sha.coordinates.arrowcurve[r], 
              col.exit_arrow, miniwin.pen_dot, 1)
    end
    WindowCircleOp( -- title bar
        win.."base", miniwin.circle_rectangle, 
        0, 0, dim.window.x, dim.font.titlebar_text * 1.1,
        col.titlebar_border, miniwin.pen_solid, 1,
        col.titlebar_fill, 0)
    local title = "Shades Maze"
    local text_width = WindowTextWidth(win.."base", "titlebar_text", title)
    local x1 = (dim.window.x - text_width) / 2
    local y1 = coordinates.title_text.y1 
    local x2 = x1 + text_width
    local y2 = y1 + dim.font.titlebar_text
    WindowText(win.."base", "titlebar_text", title, x1, y1, x2, y2, col.titlebar_text)
    for room, coor in pairs(coordinates.rooms) do
        shades_draw_room(room, coor, col, win.."base") -- draw room
        shades_draw_room_exits(room, coor, col, win.."base") -- draw exits
    end
end

function shades_draw_room_letter(room, coor, col) -- room, coordinates, colours
    local letter_colour = sha.rooms[room].visited and col.room_text_visited or col.room_text_unvisited
    WindowText (win.."overlay", "room_character", room,
        coor.letter.x1, coor.letter.y1, 0, 0,
        letter_colour, 
        false)
end

function shades_draw_overlay(dim, col) -- dimensions, colours
    WindowCircleOp( -- transparent background
        win.."overlay", miniwin.circle_rectangle, 
        0, 0, dim.window.x, dim.window.y,
        col.window_transparency, miniwin.pen_solid, 1,
        col.window_transparency, 0)
    local coordinates = sha.coordinates
    for room, coor in pairs(coordinates.rooms) do
        shades_draw_room_letter(room, coor, col)
    end
end

function shades_print_map()
    local start_time = os.clock()
    local function draw_dynamic(coordinates, col, current_room)
    	-- draw outer room fill
		local function draw_scry(room, coor, colour1, colour2)
            local fill_style = #room == 1 and 0 or 8
            for _ , r in ipairs(room) do
                WindowCircleOp(win, 2,
                    coor[r].room.outer.x1, coor[r].room.outer.y1, coor[r].room.outer.x2, coor[r].room.outer.y2,            
                    col.window_background, 0, 0,
                    colour1, fill_style)
                WindowRectOp (win, 1, coor[r].room.outer.x1, coor[r].room.outer.y1, coor[r].room.outer.x2, coor[r].room.outer.y2, colour2)
            end
        end
        -- draw inner fill
        local function draw_thyng(room, coor, colour)
            for i , r in ipairs(room) do
                local fill_style = i == 1 and 0 or 8
                WindowCircleOp(win, 2,
                    coor[r].room.inner.x1, coor[r].room.inner.y1, coor[r].room.inner.x2, coor[r].room.inner.y2,            
                    col.window_background, 0, 0,
                    colour, fill_style)
                WindowRectOp (win, 1, coor[r].room.inner.x1, coor[r].room.inner.y1, coor[r].room.inner.x2, coor[r].room.inner.y2, colour)
            end
        end
        local function draw_border(room, coor, colour)
            for _ , r in ipairs(room) do
                WindowRectOp(win, miniwin.rect_frame, 
                    coor[r].room.outer.x1, coor[r].room.outer.y1, coor[r].room.outer.x2, coor[r].room.outer.y2,
                    colour)
            end
        end
        -- insert players/mobs
        local function draw_population(coordinates, col)
			local fill_colours = {}
			for room, v in pairs(sha.rooms) do
				local player_room = false
				local room_colour = false
				for p, c in pairs(v.thyngs.players) do
					player_room = true
					room_colour = c
					break
				end
				if not room_colour then
					local xp = math.ceil(v.thyngs.mobs.muggers / 2 + v.thyngs.mobs.fighters + v.thyngs.mobs.trolls * 2)
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
        local function get_text_styles(current_room, trajectory_room, look_room, fill_colours, col)
			if IsPluginInstalled(MDT) and PluginSupports(MDT, "mdt_special_area_text") == error_code.eOK then
				local icon_styles = {}
				for r, v in pairs(fill_colours) do
					icon_styles[r] = {
						colour = sha.rooms[r].visited and col.room_text_visited or col.room_text_unvisited,
						colour = v.colour,
						bg_colour = v.bg_colour,
						border_colour = col.room_border,
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
						trolls   = sha.rooms[k].thyngs.mobs.trolls,
						fighters = sha.rooms[k].thyngs.mobs.fighters,
						muggers  = sha.rooms[k].thyngs.mobs.muggers,	
					}
					for _, mob in ipairs({"trolls", "fighters", "muggers"}) do
						local n = mobs[mob]
						local text, colour, bg_colour, border_colour, underline, fill_style = "", col.room_text_xp[#col.room_text_xp], false, false, false, 0
						if n > 0 then
							local text = n == 1 and mob:gsub("(s)$", "") or tostring(n).." "..mob
							local m = {muggers = 1/4, fighters = 1/2, trolls = 1}
							local xp = m[mob] * n
							if xp < 1/2 then
								colour = col.room_text_xp[2]
							elseif xp < 3/4 then
								colour = col.room_text_xp[3]
							elseif xp < 1 then
								colour = col.room_text_xp[4]
							else
								bg_colour =	col.room_inner_fill_xp[math.ceil(xp) > 9 and 9 or math.ceil(xp)]	
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
					for player, player_colour in pairsByKeys(sha.rooms[k].thyngs.players) do
						table.insert(text_styles[#text_styles], {
							text = player,
							colour = col.room_text_player,
							bg_colour = player_colour,
							border_colour = false,
							fill_style = 0,						
						})
					end
				end
				CallPlugin(MDT, "mdt_special_area_text", "text_styles = "..serialize.save_simple(text_styles), "Somewhere In The Shades")
			end
        end
        local trajectory_room, scry_room = #sha.sequence ~= 0 and sha.sequence[#sha.sequence] or {}, sha.scry_room or {}
		draw_scry(scry_room, coordinates.rooms, col.room_outer_fill_scry, col.room_border_scry)
		local fill_colours = draw_population(coordinates, col)
        draw_thyng(current_room, coordinates.rooms, col.room_inner_fill_you)
        draw_border(trajectory_room, coordinates.rooms, col.room_border_trajectory)
        get_text_styles(current_room, trajectory_room, scry_room, fill_colours, col)
    end
    local current_room = sha.sequence[1] or {}
    WindowImageFromWindow(win, "base", win.."base")
    WindowDrawImage(win, "base", 0, 0, 0, 0, 1) -- copy base
    draw_dynamic(sha.coordinates, sha.colours, current_room) -- add dynamic
    WindowImageFromWindow(win, "overlay", win.."overlay")
    WindowDrawImage(win, "overlay", 0, 0, 0, 0, 3) -- copy overlay
    WindowShow(win, true)
    --print(os.clock() - start_time) -- speed test
end
