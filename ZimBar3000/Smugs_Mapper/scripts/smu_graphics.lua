--------------------------------------------------------------------------------
--   GRAPHICAL FUNCTIONS
--------------------------------------------------------------------------------
function smugs_draw_room(room, coor, col, mw) -- room, coordinates, colours, miniwindow
    if room ~= 'entrance' then
        local chamber = smu.chambers[room]
        if chamber then
            WindowCircleOp(mw, 2, -- draw room
                coor.room.outter.x1, coor.room.outter.y1, coor.room.outter.x2, coor.room.outter.y2,            
                col.window_background, 0, 1,
                col.room_outter_fill_chamber, miniwin.brush_fine_pattern)
        end
        WindowRectOp(mw, 1, coor.room.outter.x1, coor.room.outter.y1, coor.room.outter.x2, coor.room.outter.y2, col.room_border)
    end
end

function smugs_draw_room_exits(room, coor, col, mw) -- room, coordinates, colours, miniwindow
    if room ~= 'entrance' then
        for dir, v in pairs(smu.rooms[room].exits) do
            local line_style =  v == 'entrance' and miniwin.pen_dot    or miniwin.pen_solid
            local line_colour = v == 'entrance' and col.exit_line_entrance or col.exit_line
            WindowLine(
                mw, 
                coor.exit[dir].x1, coor.exit[dir].y1, coor.exit[dir].x2, coor.exit[dir].y2,  
                line_colour, line_style, 1)
        end
    end
end

function smugs_draw_base(dim, col) -- dimensions, colours
    local coordinates = smu.coordinates
    WindowCircleOp( -- window border
        win.."base", miniwin.circle_rectangle, 
        0, 0, dim.window.x, dim.window.y,
        col.window_border, miniwin.pen_solid, 1,
        col.window_background, 0) 
    WindowCircleOp( -- title bar
        win.."base", miniwin.circle_rectangle, 
        0, 0, dim.window.x, dim.font.title * 1.1,
        col.titlebar_border, miniwin.pen_solid, 1,
        col.titlebar_fill, 0)
    local title = "Smugs Cave"
    local text_width = WindowTextWidth(win.."base", "title", title)
    local x1 = (dim.window.x - text_width) / 2
    local y1 = coordinates.title_text.y1 
    local x2 = x1 + text_width
    local y2 = y1 + dim.font.title
    WindowText(win.."base", "title", title, x1, y1, x2, y2, col.titlebar_text)
    for room, coor in pairs(coordinates.rooms) do
        smugs_draw_room_exits(room, coor, col, win.."base") -- draw exits
        smugs_draw_room(room, coor, col, win.."base") -- draw room
    end
end

function smugs_draw_room_letter(room, coor, col) -- room, coordinates, colours
    if room ~= 'entrance' then
        local letter_colour = smu.rooms[room].visited and col.room_text_visited or col.room_text_unvisited
        WindowText (win.."overlay", "larger", room,
            coor.letter.x1, coor.letter.y1, 0, 0,
            letter_colour, 
            false)
    end
end

function smugs_draw_overlay(dim, col) -- dimensions, colours
    WindowCircleOp( -- transparent background
        win.."overlay", miniwin.circle_rectangle, 
        0, 0, dim.window.x, dim.window.y,
        col.window_transparency, miniwin.pen_solid, 1,
        col.window_transparency, 0)
    local coordinates = smu.coordinates
    for room, coor in pairs(coordinates.rooms) do
        smugs_draw_room_letter(room, coor, col)
    end
end

function smugs_print_map()
    local start_time = os.clock()
    local function draw_dynamic(coordinates, col, current_room)
        -- draw inner fill
        local function draw_thyng(room, coor, colour)
            if room then
                WindowCircleOp(win, 2,
                    coor.room.inner.x1, coor.room.inner.y1, coor.room.inner.x2, coor.room.inner.y2,            
                    colour, 0, 0,
                    colour, 0)
            end
        end
        -- room border
        local function draw_border(room, coor, colour)
            if room then
                WindowRectOp(win, miniwin.rect_frame, 
                    coor.room.outter.x1, coor.room.outter.y1, coor.room.outter.x2, coor.room.outter.y2,
                    colour)
            end
        end
        -- insert players/mobs
        local function draw_population(coor, col)
			local fill_colours = {}
			for room, v in pairs(smu.rooms) do
				local player_room = false
				local room_colour = false
				for p, c in pairs(v.thyngs.players) do
					player_room = true
					room_colour = c
					break
				end
				if not room_colour then
					if smu.rooms[room].thyngs.mobs.captain > 0 then
						room_colour = col.room_inner_fill_captain
					elseif smu.rooms[room].thyngs.mobs.smugglers > 0 then
						room_colour = col.room_inner_fill_xp[smu.rooms[room].thyngs.mobs.smugglers > 9 and 9 or smu.rooms[room].thyngs.mobs.smugglers]
					end
				end
				if room_colour then
					draw_thyng(room, coor[room], room_colour)
					fill_colours[room] = {
						bg_colour = room_colour, 
						colour = player_room and col.room_text_player or col.room_text_xp[#col.room_text_xp],
						border_colour == smu.rooms[room].aggro and col.room_border_fight or col.room_border}
				end
				if smu.rooms[room].aggro then
					draw_border(room, coor[room], col.room_border_fight)
				end
			end
			return fill_colours
        end
        local function get_text_styles(current_room, trajectory_room, fill_colours, col)
			if IsPluginInstalled(MDT) and PluginSupports(MDT, "mdt_special_area_text") == error_code.eOK then
				local icon_styles = {}
				for r, v in pairs(fill_colours) do
					icon_styles[r] = {
						colour = smu.rooms[r].visited and col.room_border_visited or col.room_border_unvisited,
						colour = v.colour,
						bg_colour = v.bg_colour,
						border_colour = v.border,
						fill_style = 0
					}
				end
	
				if icon_styles[current_room] then
					local fill_style = #current_room == 1 and 0 or 8
					icon_styles[current_room].bg_colour = col.room_inner_fill_you
					icon_styles[current_room].colour = col.room_text_player
					icon_styles[current_room].fill_style = fill_style
					icon_styles[current_room].border_colour = col.room_border
				end


				if icon_styles[trajectory_room] then
					icon_styles[trajectory_room].border_colour = col.room_border_trajectory
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
						captain   = smu.rooms[k].thyngs.mobs.captain,
						smugglers = smu.rooms[k].thyngs.mobs.smugglers,	
					}
					for _, mob in ipairs({"captain", "smugglers"}) do
						local n = mobs[mob]
						local text, colour, bg_colour, border_colour, underline, fill_style = "", col.room_text_xp[#col.room_text_xp], false, false, false, 0
						if n > 0 then
							if mob == "captain" then
								bg_colour = col.room_inner_fill_captain
							elseif n < 4 then
								colour = col.room_text_xp[n + 1]
							else
								bg_colour = col.room_inner_fill_xp[n > 9 and 9 or n]	
							end
							text = n == 1 and mob:gsub("(s)$", "") or tostring(n).." "..mob
							table.insert(text_styles[#text_styles], {
								text = text,
								colour = colour,
								bg_colour = bg_colour,
								border_colour = border_colour,
								fill_style = 0,						
							})
						end
					end
					for player, player_colour in pairsByKeys(smu.rooms[k].thyngs.players) do
						table.insert(text_styles[#text_styles], {
							text = player,
							colour = col.room_text_player,
							bg_colour = player_colour,
							border_colour = false,
							fill_style = 0,						
						})
					end
				end
				CallPlugin(MDT, "mdt_special_area_text", "text_styles = "..serialize.save_simple(text_styles), smu.text_title:gsub("^(%w)", string.upper):gsub("(%s%w)", string.upper))
			end
		end
        local trajectory_room = smu.sequence[#smu.sequence]
        local fill_colours = draw_population(coordinates.rooms, col)
        draw_thyng(current_room, coordinates.rooms[current_room], col.room_inner_fill_you)
        if current_room and trajectory_room and not (current_room == trajectory_room and smu.rooms[current_room].aggro) then
			draw_border(trajectory_room, coordinates.rooms[trajectory_room], col.room_border_trajectory)
		end
        get_text_styles(current_room, trajectory_room, fill_colours, col)
    end
    local current_room = smu.sequence[1] or false
    WindowImageFromWindow(win, "base", win.."base")
    WindowDrawImage(win, "base", 0, 0, 0, 0, 1) -- copy base
    draw_dynamic(smu.coordinates, smu.colours, current_room) -- add dynamic
    WindowImageFromWindow(win, "overlay", win.."overlay")
    WindowDrawImage(win, "overlay", 0, 0, 0, 0, 3) -- copy overlay
    WindowShow(win, true)
    --print(os.clock() - start_time) -- speed test
end

