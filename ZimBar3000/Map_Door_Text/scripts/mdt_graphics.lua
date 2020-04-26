-------------------------------------------------------------------------------
--  GRAPHICS
-------------------------------------------------------------------------------
function mdt_print_map()
	function draw_ghost()
		local trajectory_room =  mdt.sequence[#mdt.sequence]
		-- if our trajectory room is on our map
		local ghost = mdt.locations[trajectory_room] and mdt.locations[trajectory_room].map
		if ghost then
			local coor = mdt.coordinates
			local x = ghost.x
			local y = ghost.y
			local view = mdt.rooms.range == 0 and 1 or mdt.rooms.range 
			local x1 = coor.rooms[view][y][x].outer.x1
			local y1 = coor.rooms[view][y][x].outer.y1
			local x2 = coor.rooms[view][y][x].outer.x2
			local y2 = coor.rooms[view][y][x].outer.y2
			WindowRectOp(win[1], 1, x1, y1, x2, y2, mdt.colours.room_border_trajectory)
		end
	end
    WindowDrawImage(win[1], "map_image", 0, 0, 0, 0, 1)
    draw_ghost()
	WindowShow(win[1])	
end

function mdt_print_text()
	function draw_ghost()
		local trajectory_room =  mdt.sequence[#mdt.sequence]
		-- if our trajectory room is on our map
		local ghost = mdt.locations[trajectory_room] and mdt.locations[trajectory_room].text
		if ghost then
			local x1 = ghost.x1
			local y1 = ghost.y1
			local x2 = ghost.x2
			local y2 = ghost.y2
			WindowRectOp(win[2], 1, x1, y1, x2, y2, mdt.colours.room_border_trajectory)
		end
	end
	WindowDrawImage(win[2], "text_image", 0, 0, 0, 0, 1)
	draw_ghost()
	WindowShow(win[2])
end

function mdt_window_background(mw, dim, col)
	local clone = {map = 1, text = 2}
	local i = clone[mw] or mw
    WindowRectOp(win[mw], 2, 0, 0, dim.window[i].x, dim.window[i].y, col.window_background)
end

function mdt_titlebar(mw, dim, coor, col)
	local clone = {map = 1, text = 2}
	local i = clone[mw] or mw
	-- add window border also 
    WindowRectOp(win[mw], 1, 0, 0, dim.window[i].x, dim.window[i].y, col.window_border) 
	WindowGradient (win[mw], 0, 0, dim.window[i].x, FIXED_TITLE_HEIGHT, 
		col.titlebar_fill[1], 
        col.titlebar_fill[2], 
        miniwin.gradient_vertical)
    WindowRectOp(win[mw], miniwin.rect_draw_edge, 0, 0, dim.window[i].x, FIXED_TITLE_HEIGHT,
        miniwin.rect_edge_etched, 
        miniwin.rect_edge_at_all)
	local w = WindowTextWidth(win[i], "titlebar_text", mdt.title[i])
	local x1 = (dim.window[i].x - w) / 2
	local min = 1
	if x1 < min then x1 = min end
	WindowText(win[mw], "titlebar_text", mdt.title[i], 
		x1, 0, 0, 0,
		col.titlebar_text)      
end

function mdt_draw_map(map_data)
	local function draw_room_exits(mw, dim, coor, colour, map_data, view, x, y)
		for _, exit in ipairs(map_data[y][x].exits) do
			local x1 = coor.rooms[view][y][x].exit[exit].x1
			local y1 = coor.rooms[view][y][x].exit[exit].y1
			local x2 = coor.rooms[view][y][x].exit[exit].x2
			local y2 = coor.rooms[view][y][x].exit[exit].y2	
			WindowLine(mw, x1, y1, x2, y2, colour, 0, 1)
		end
	end
	local function draw_room_doors(mw, dim, coor, colour1, colour2, map_data, view, x, y)
		for _, door in ipairs(map_data[y][x].doors) do
			local x1 = coor.rooms[view][y][x].door[door].x1
			local y1 = coor.rooms[view][y][x].door[door].y1
			local x2 = coor.rooms[view][y][x].door[door].x2
			local y2 = coor.rooms[view][y][x].door[door].y2
			WindowCircleOp(mw, 2, x1, y1, x2, y2, colour1, 0, 1, colour2, 0)
		end
	end
	local function draw_room(mw, dim, coor, colour1, colour2, map_data, view, x, y)
		local x1 = coor.rooms[view][y][x].outer.x1
		local y1 = coor.rooms[view][y][x].outer.y1
		local x2 = coor.rooms[view][y][x].outer.x2
		local y2 = coor.rooms[view][y][x].outer.y2
		WindowCircleOp(mw, 2, x1, y1, x2, y2, colour1, 0, 1, colour2, 0)
	end
	local function draw_room_border(mw, dim, coor, colour, map_data, view, x, y)
		local x1 = coor.rooms[view][y][x].outer.x1
		local y1 = coor.rooms[view][y][x].outer.y1
		local x2 = coor.rooms[view][y][x].outer.x2
		local y2 = coor.rooms[view][y][x].outer.y2
		WindowRectOp(mw, 1, x1, y1, x2, y2, colour)
	end
	local function draw_room_fill(mw, dim, coor, colour, map_data, view, x, y)
		local x1 = coor.rooms[view][y][x].inner.x1
		local y1 = coor.rooms[view][y][x].inner.y1
		local x2 = coor.rooms[view][y][x].inner.x2
		local y2 = coor.rooms[view][y][x].inner.y2
		WindowRectOp(mw, 2, x1, y1, x2, y2, colour)
	end
	local function draw_room_number(mw, dim, coor, colour, map_data, view, x, y, xp, underlined)
		local font_id = "room_character"..tostring(view)
		local w = WindowTextWidth(mw, font_id, xp)
		local x1 = coor.rooms[view][y][x].outer.x1 + (dim.room[view].x - w) / 2
		local y1 = coor.rooms[view][y][x].outer.y1 + (dim.room[view].y - dim.font.room_character[view]) / 2
		WindowText(mw, underlined and font_id.."underlined" or font_id, xp, x1, y1, 0, 0, colour, false)
	end
	local function draw_room_thyngs(mw, dim, coor, col, map_data, view, x, y, room_count, player_room)
	
		local function get_fight_rooms(mw, dim, coor, col,map_data, view, x, y, room_count)
		-- in order to determine fight rooms, we take gmcp map data and
		-- iterate over the room charectors and their coresponding colour codes.
		-- if the colour is 'red' and it is not a door ('+'), then we have a fight room.
		-- we record these by the index they were found at.
		local id =  map_data[y][x].id
		local border_colour = false
		if id then
			if mdt.fight_room[room_count] then
				-- transfer from index
				mdt.fight_room[id] = true
				-- to room id, so that offset will not occur
				-- if we are given map door text from a trigger
				-- rather then gmcp (different vision limits)
				mdt.fight_room[room_count] = nil
			end
			if mdt.fight_room[id] then
				border_colour =  col.room_border_fight
			end
		end
		return border_colour
	end
		local players_or_mobs = false
        local pop = map_data[y][x].population
		local icon, icon_colour, icon_bg = "", 0, false
		if map_data[y][x].population.is_player_room then
			players_or_mobs = "players"
			for k, v in pairs(map_data[y][x].population.players) do
				icon_bg = ColourNameToRGB(v.colour) ~= -1 and ColourNameToRGB(v.colour) or v.colour
				break
			end
			icon = string.char(player_room)
            icon_colour = col.room_text_player
			player_room = player_room + 1
		elseif map_data[y][x].population.is_mob_room then
			players_or_mobs = "mobs"
            local function round(num, place)
                local mult = 10^(place or 0)
                return math.floor(num * mult + 0.5) / mult
            end
            if pop.xp < 1/4 then
                icon_colour = col.room_text_xp[1]
                icon = 0                -- 0
            elseif pop.xp < 1/2 then
                icon_colour = col.room_text_xp[2]
                icon = string.char(188) -- 1/4
            elseif pop.xp < 3/4 then
                icon_colour = col.room_text_xp[3]
                icon = string.char(189) -- 1/2
            elseif pop.xp < 1 then
                icon_colour = col.room_text_xp[4]
                icon = string.char(190) -- 3/4
            else
				icon_colour = col.room_text_xp[#col.room_text_xp]
                icon = round(pop.xp)        -- 1-9
                icon = icon >= 10 and 9 or icon
                -- only colour fill room if xp is greater than one
                if icon >= 1 then
                    icon_bg = col.room_inner_fill_xp[icon]
                end
            end
		end
		if players_or_mobs then
			local is_immobile, is_priest, is_money = pop.is_immobile, pop.is_priest, pop.is_money
			if icon_bg then
				draw_room_fill(mw, dim, coor, icon_bg, map_data, view, x, y)
			end
			local icon_border =  get_fight_rooms(mw, dim, coor, col,map_data, view, x, y, room_count) or is_priest and col.room_border_priest or is_money and col.room_border_money or false	
			if icon_border  then
				draw_room_border(mw, dim, coor, icon_border , map_data, view, x, y)
			end
			draw_room_number(mw, dim, coor, icon_colour, map_data, view, x, y, icon, is_immobile)
			local function format_path(t1)
				local t2 = {}
				for i, v in ipairs(t1) do
					if v == (t2[#t2] and t2[#t2].direction) then
						t2[#t2].distance = t2[#t2].distance + 1
					else
						table.insert(t2, {direction = v, distance = 1})
					end
				end
				local s = false
				for i, v in ipairs(t2) do
					if not s then s = "" else s = s..", " end
					s = s..tostring(v.distance).." "..v.direction
				end
			  return s
			end
			local path = map_data[y][x].path
			local formatted_path = format_path(path)
			mdt.text.longest_path = #formatted_path > #mdt.text.longest_path and formatted_path or mdt.text.longest_path
			local room_info = {
				path = path, 
				formatted_path = formatted_path,
				icon = icon, 
				icon_colour = icon_colour, 
				icon_bg = icon_bg, 
				icon_border = icon_border or col.room_border,
				underline = is_immobile, 
				xp = pop.xp, 
				x = x,
				y = y,
			}
			table.insert(mdt.text[players_or_mobs], room_info)
        end
		return room_count + 1, player_room
	end
	local function draw_map_rooms(mw, dim, coor, col, map_data)
		mdt.text = {players = {}, mobs = {}, longest_path = ""}
		local range = map_data.range
		-- avoid awkward zoom-ins
		local view = range < 1 and 1 or range
		local player_room = 65
		-- count rooms and iterate in a way in which we can match our fight room
		-- indexes to their corresponding x, y locations
		local room_count = 1
		for y = range, - range, -1 do
			for x = - range, range do
				if map_data[y][x].in_vision then				
					draw_room(mw, dim, coor, col.room_border, col.room_background, map_data, view, x, y)
					draw_room_exits(mw, dim, coor, col.exit_line,  map_data, view, x, y)
					draw_room_doors(mw, dim, coor, col.exit_border_door, col.exit_fill_door,  map_data, view, x, y)
					room_count, player_room = draw_room_thyngs(mw, dim, coor, col, map_data, view, x, y, room_count, player_room)
				end
			end
		end	
		draw_room_fill(mw, dim, coor, col.room_inner_fill_you, map_data, view, 0, 0) -- you
	end
	local mw, dim, coor, col = "map", mdt.dimensions, mdt.coordinates, mdt.colours
	mdt_window_background(mw, dim, col)
	draw_map_rooms(win[mw], dim, coor, col, map_data)
	mdt_titlebar(mw, dim, coor.titlebar, col)
	WindowImageFromWindow(win[1], "map_image", win[mw])
	mdt_print_map()
end

function mdt_prepare_text(map_data)
	local function get_text_styles(mw, dim, coor, col, map_data)
		local function order_population(players_or_mobs)
			table.sort(mdt.text[players_or_mobs], function(a,b) 
				if players_or_mobs == "players" then
					return a.icon < b.icon 
				else
					return a.xp > b.xp
				end
			end)
		end
		-- sort and consolidate
		mdt.text.population = {}
		for _1, players_or_mobs in ipairs({"players", "mobs"}) do
			order_population(players_or_mobs)
			for _2, v in ipairs(mdt.text[players_or_mobs]) do
				table.insert(mdt.text.population, v)
			end
		end
		-- get styles for room
		local function get_room_styles(map_data, x, y)
			local rs = {}
			-- add players
			for k, v in pairs(map_data[y][x].population.players) do
				local text, colour, bg_colour, border_colour, underline = k, col.room_text_player, ColourNameToRGB(v.colour) ~= -1 and ColourNameToRGB(v.colour) or v.colour, false, false
				table.insert(rs, {text = text, colour = colour, bg_colour = bg_colour, border_colour = border_colour, underline = underline})
			end
			-- add mobs
			for i = 5, 0, -1 do
				for k, v in pairs(map_data[y][x].population.mobs[i]) do
					local text, colour, bg_colour, border_colour, underline = "", 0, false, false, v.is_immobile
					if v.plural == "men" or k ~= "" then
						if v.quantity > 1 then
							text = v.quantity.." "..k..v.plural
						else
							text = k..v.singular
						end
						local xp_val = {1/12, 1/6, 1/3, 2/3, 1}
						local xp = (xp_val[i] or 0) * v.quantity
						if xp < 1/4 then
							colour = col.room_text_xp[1]
						elseif xp < 1/2 then
							colour = col.room_text_xp[2]
						elseif xp < 3/4 then
							colour = col.room_text_xp[3]
						elseif xp < 1 then
							colour = col.room_text_xp[4]
						else
							colour = col.room_text_xp[5]
							bg_colour = xp > 9 and col.room_inner_fill_xp[9] or col.room_inner_fill_xp[math.floor(xp)]
						end
						if v.is_priest then
							border_colour = col.room_border_priest
						elseif v.is_money then
							border_colour = col.room_border_money
						end
						table.insert(rs, {text = text, colour = colour, bg_colour = bg_colour, border_colour = border_colour, underline = underline})
					end
				end
			end
			return rs
		end
		-- get styles for every room
		local function get_styles(mw, dim, coor, col, map_data)
			local styles = {}
			for i, v in ipairs(mdt.text.population) do
				local rs = get_room_styles(map_data, v.x, v.y)
				-- add icon
				table.insert(rs, 1, {text = v.icon, colour = v.icon_colour, bg_colour = v.icon_bg, border_colour = v.icon_border, underline = v.underline})
				-- add path
				table.insert(rs, 2, {text = v.formatted_path, colour = col.path_text, bg_colour = false, border_colour = false, underline = false})
				-- must have more than just the the icon and path 
				-- in the event that the only thing occupying a room is an empty string.
				-- (the regex captures return empty strings interntionally for certain things
				-- we would like to omit, like clouds or pets)
				if #rs > 2 then 
					table.insert(styles, rs)
				end
				rs[0] = mdt.rooms[v.y][v.x].id
			end
			return styles
		end
		local styles = get_styles(mw, dim, coor, col, map_data)
		return styles, mdt.text.longest_path
	end
	local mw, dim, coor, col = "text", mdt.dimensions, mdt.coordinates, mdt.colours
	mdt.styles, mdt.longest_path = get_text_styles(mw, dim, coor, col, map_data)
	mdt_draw_text(mdt.styles)
end

function mdt_draw_text(styles)
	local longest_path = mdt.longest_path
	local function draw_text(mw, dim, coor, col)
		local function next_line(y2, h)
			local line_buffer = 3
			local y1 = y2 + line_buffer
			return y1, y1 + h 
		end
		local font_size = selected_font_size
		local font_id = "text_window"..tostring(font_size)
		local h =  dim.font.text_window[font_size]
		local y1 = dim.buffer[2].y + FIXED_TITLE_HEIGHT
		local y2 = y1 + h
		for _, t in ipairs(styles) do
			local space = WindowTextWidth(win[2], font_id, " ")
			local x1, x2 = dim.buffer[2].x, 0
			for i, v in ipairs(t) do
				if i == 1 then -- icon
					x2 = x1 + h -- create square
					if v.bg_colour then
						WindowRectOp (win[mw], 2, x1, y1, x2, y2, v.bg_colour)
					end
					if v.border_colour then
						WindowRectOp (win[mw], 1, x1, y1, x2, y2, v.border_colour) 
					end
					local id = t[0] or false
					if mdt.locations[id] then
						-- save locations so we can use them to highlight ghost
						mdt.locations[id].text = {
							x1 = x1,
							y1 = y1,
							x2 = x2,
							y2 = y2,
						}
					end
					local w = WindowTextWidth(win[2], font_id, v.text)
					x1 = x1 + (h - w) / 2
					WindowText(win[mw], v.underline and font_id.."underlined" or font_id, v.text, x1, y1, 0, 0, v.colour)
				elseif i == 2 then -- path
					WindowText(win[mw], font_id, v.text, x1, y1, 0, 0, v.colour)
					if longest_path ~= "" then
						x2 = x1 + WindowTextWidth(win[2], font_id, longest_path) + space
					else
						x2 = x2 + space
					end
					x2 = x2 + WindowText(win[mw], font_id, ":", x2, y1, 0, 0, v.colour)
				else -- mobs
					local text = i == #t and v.text or v.text..","
					x2 = x1 + WindowTextWidth(win[2], font_id, text)
					if v.bg_colour then
						WindowRectOp (win[mw], 2, x1 - 1, y1, x2 + 1, y2, v.bg_colour)
					end
					if v.border_colour then
						WindowRectOp (win[mw], 1, x1 - 1, y1, x2 + 1, y2, v.border_colour) 	
					end		
					WindowText(win[mw], v.underline and font_id.."underlined" or font_id, text, x1, y1, 0, 0, v.colour)
				end
				x1 = x2 + space
			end
			y1, y2 = next_line(y2, h)
		end
	end
	longest_path = longest_path or ""
	local mw, dim, coor, col = "text", mdt.dimensions, mdt.coordinates, mdt.colours
	mdt_window_background(mw, dim, col, map_data)
	draw_text(mw, dim, coor, col)
	mdt_titlebar(mw, dim, coor.titlebar, col)
	WindowImageFromWindow(win[2], "text_image", win[mw])
	mdt_print_text()
end
