--------------------------------------------------------------------------------
--   MINIWINDOW SETUP
--------------------------------------------------------------------------------
function mdt_get_windows(dim) -- dimensions
    for k in pairs(win) do
		WindowCreate(win[k], 0, 0, 0, 0, miniwin.pos_center_all, 0, mdt.colours.window_background)
	end
    WindowSetZOrder(win[1], 201)
    WindowSetZOrder(win[2], 200)
end

function mdt_window_setup(window_width, window_height) -- define window attributes
    local function get_window_dimensions(window_width, window_height)
		local dim = {}
        dim.window = {
            {x = window_width[1], y = window_height[1]},
            {x = window_width[2], y = window_height[2]},}
        dim.buffer = {
			{x = 0, y = 0},
            {x = 5, y = 5},}
        dim.map = {
            x = (dim.window[1].x - dim.buffer[1].x * 2), 
            y = (dim.window[1].y - dim.buffer[1].y * 2) - FIXED_TITLE_HEIGHT }
        for _, k in ipairs({'block', 'room', 'thyng', 'exit', 'door'}) do
			dim[k] = {}
        end
        local min_vision, max_vision = 0, 5
        for i = min_vision, max_vision do
			dim.block[i] = {
				x = dim.map.x / (i * 2 + 1), 
				y = dim.map.y / (i * 2 + 1),} 
			dim.room[i] = {
				x = dim.block[i].x * .6, 
				y = dim.block[i].y * .6}
			dim.thyng[i] = {
				x = dim.room[i].x * .75, 
				y = dim.room[i].y * .75,}
			dim.exit[i] = {
				x = (dim.block[i].x - dim.room[i].x), 
				y = (dim.block[i].y - dim.room[i].y),}	
			dim.door[i] = {
				x = (dim.block[i].x - dim.room[i].x) / 2, 
				y = (dim.block[i].y - dim.room[i].y) / 2,}
        end

        return dim
    end

    local function get_coordinates(dim) --dimensions
        local function get_exit_coordinates(dim, i, dir, room_center)
			local x1 = room_center.x + (dim.room[i].x / 2) *  dir[1]
			local y1 = room_center.y + (dim.room[i].y / 2) * -dir[2]
			local x2 = x1 + dim.exit[i].x *  dir[1]
			local y2 = y1 + dim.exit[i].y * -dir[2]
			return {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
        end
        local function get_door_coordinates(dim, i, dir, room_center)
			local function fix_order(p1, p2)
				if edge == 'door' and p1 > p2 then
					return p2, p1
				else
					return p1, p2
				end
			end
			local door_center = {
				x = room_center.x + ((dim.room[i].x + dim.door[i].x) / 2) *  dir[1],
				y = room_center.y + ((dim.room[i].y + dim.door[i].y) / 2) * -dir[2],
			}
			local x1 = door_center.x - (dim.door[i].x / 2)  
			local y1 = door_center.y - (dim.door[i].y / 2)
			local x2 = door_center.x + (dim.door[i].x / 2)
			local y2 = door_center.y + (dim.door[i].y / 2)
			x1, x2 = fix_order(x1, x2);y1, y2 = fix_order(y1, y2)
			return {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
        end
        local function get_room_coordinates(dim, i, x, y, map_origin)
			local room_center = {
				x = map_origin.x + dim.block[i].x *  x,
				y = map_origin.y + dim.block[i].y * -y,
			}
			mdt.coordinates.rooms[i][y][x] = {outer = {}, inner = {}}
			local x1 = room_center.x - dim.room[i].x / 2
			local y1 = room_center.y - dim.room[i].y / 2
			local x2 = room_center.x + dim.room[i].x / 2
			local y2 = room_center.y + dim.room[i].y / 2
			mdt.coordinates.rooms[i][y][x].outer =  {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
			x1 = room_center.x - dim.thyng[i].x / 2
			y1 = room_center.y - dim.thyng[i].y / 2
			x2 = room_center.x + dim.thyng[i].x / 2
			y2 = room_center.y + dim.thyng[i].y / 2		
			mdt.coordinates.rooms[i][y][x].inner =   {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
			local function give_direction(edge)
				if edge == "n"  then return  0,  1 end
				if edge == "ne" then return  1,  1 end
				if edge == "e"  then return  1,  0 end
				if edge == "se" then return  1, -1 end
				if edge == "s"  then return  0, -1 end
				if edge == "sw" then return -1, -1 end
				if edge == "w"  then return -1,  0 end
				if edge == "nw" then return -1,  1 end
			end
			for _1, dir in ipairs({'n', 'ne', 'e', 'se', 's', 'sw', 'w', 'nw'}) do
					mdt.coordinates.rooms[i][y][x].exit = mdt.coordinates.rooms[i][y][x].exit or {}
					mdt.coordinates.rooms[i][y][x].exit[dir] = 
						get_exit_coordinates(dim, i, {give_direction(dir)}, room_center)
					mdt.coordinates.rooms[i][y][x].door = mdt.coordinates.rooms[i][y][x].door or {}
					mdt.coordinates.rooms[i][y][x].door[dir] = 
						get_door_coordinates(dim, i, {give_direction(dir)}, room_center)
			end
        end
		mdt.coordinates = {rooms = {}, title_text = {},}
        mdt.coordinates.title_text.y1 = ((dim.font.title * 1.1) - dim.font.title) / 2
        local map_origin = {
			x = (dim.map.x / 2) + dim.buffer[1].x,
			y = (dim.map.y / 2) + dim.buffer[1].y + FIXED_TITLE_HEIGHT,}
		local min_vision, max_vision = 0, 5
		for i = min_vision, max_vision do
			mdt.coordinates.rooms[i] = {}
			for y = -i, i do
				mdt.coordinates.rooms[i][y] = {}
				for x = -i, i do
					get_room_coordinates(dim, i, x, y, map_origin)
				end
			end
		end
    end

    local function resize_windows(dim) -- dimensions 
        for k in pairs(win) do
			local clone = {map = 1, text = 2}
			local i = clone[k] or k
			WindowResize(win[k], dim.window[i].x, dim.window[i].y, miniwin.pos_center_all, 0, mdt.colours.window_transparency)
        end
    end

	local function get_font(dim) -- dimensions
		-- chose our fonts, pick backups if unavailable
		local function choose_fonts()
			local chosen_fonts = {false, false}
			local f_tbl = utils.getfontfamilies() -- all possible fonts
			local choice = { -- our choice for each font, with two backups
				{"System", "Fixedsys", "Arial"},       -- title
				{"Dina", "Arial", "Helvetica"},        -- others
			}
			 -- if our chosen font exists then pick it
			for i, t in ipairs(choice) do
				for ii, f in ipairs(t) do
					if f_tbl[f] then
						chosen_fonts[i] = f
						break
					end
				end
			end
			-- if none of our chosen fonts are avaliable, pick the first one that is
			for i, f in ipairs(chosen_fonts) do 
				if not f then
					for k in pairs(f_tbl) do
						chosen_fonts[i] = k
						break
					end
				end
			end
			assert(chosen_fonts[1] and chosen_fonts[2], "Fonts not loaded!")
			return chosen_fonts
		end
		local fonts = choose_fonts()
		-- determine font size based on font and max height
		local function get_size(font_id, font_name, max_height)
			local max_size, font_size = 200, 1
			local font_height = 0
			while (font_height <= max_height) and (font_size < max_size) do
				-- load the font in order to determine its size size
				WindowFont(win[1], font_id, font_name, font_size, false, false, true, false)
				font_height = tonumber(WindowFontInfo(win[1], font_id, 1)) or font_height or 0
				-- if it passes or maximums then we have found our size
				if font_height > max_height or font_size > max_size then
					-- use previous size
					return (font_size - 1) > 1 and (font_size - 1) or 1
				end
				-- try the next size up
				font_size = font_size + 1
			end
		end
		-- load font and retun font height
		local function load_font(font_id, font_name, font_size)
			-- load fonts on each miniwindow
			for k, mw in pairs(win) do
				WindowFont(mw, font_id, font_name, font_size, false, false, false, false)
				WindowFont(mw, font_id.."underlined", font_name, font_size, false, false, true, false)
			end
			return tonumber(WindowFontInfo(win[1], font_id, 1)) or font_height or 0
		end
		-- our sizes are all determine by entirely different methods
		local font_methods = {
			title = ( -- determined by fixed hight
				function(font_id)
					local font_name = fonts[1] 
					local font_size   = get_size(font_id, font_name, FIXED_TITLE_HEIGHT)
					local font_height = load_font(font_id, font_name, font_size)
					mdt.dimensions.font[font_id] = font_height -- single value
				end),
			map = ( -- determined by room proportions, there will be a diffrent size for each possible vision limit
				function(font_id)
					mdt.dimensions.font[font_id] = {}
					local font_name = fonts[2]
					for i = 0, #dim.room do         
						local font_size   = get_size(font_id..tostring(i), font_name, dim.room[i].y)
						local font_height = load_font(font_id..tostring(i), font_name, font_size)
						mdt.dimensions.font[font_id][i] = font_height -- store by vision limit
					end
				end),
			text = ( -- preset sizes
				function(font_id)
					mdt.dimensions.font[font_id] = {}
					local font_name = fonts[2]
					for font_size = 8, 14 do 
						local font_height = load_font(font_id..tostring(font_size), font_name, font_size)
						mdt.dimensions.font[font_id][font_size] = font_height -- store by size
					end
				end),
		}
		mdt.dimensions.font = {}
		for font_id, func in pairs(font_methods) do
			func(font_id)
		end
	end
    mdt.dimensions = get_window_dimensions(window_width, window_height)
    resize_windows(mdt.dimensions)
    get_font(mdt.dimensions)
    get_coordinates(mdt.dimensions)
end
