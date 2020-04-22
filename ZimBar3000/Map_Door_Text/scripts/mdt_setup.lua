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
        mdt.coordinates.title_text.y1 = ((dim.font.titlebar_text * 1.1) - dim.font.titlebar_text) / 2
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
    mdt.dimensions = get_window_dimensions(window_width, window_height)
    resize_windows(mdt.dimensions)
    mdt_get_font(mdt.dimensions)
    get_coordinates(mdt.dimensions)
end
