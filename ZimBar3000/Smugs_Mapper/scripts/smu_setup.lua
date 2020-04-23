--------------------------------------------------------------------------------
--   MINIWINDOW SETUP
--------------------------------------------------------------------------------
function smugs_get_windows(dim) -- dimensions
    WindowCreate(win.."copy_from", 0, 0, 0, 0, miniwin.pos_center_all, 0, smu.colours.window_transparency) -- for loading images
    WindowCreate(win.."base", 0, 0, 0, 0, miniwin.pos_center_all, 0, smu.colours.window_transparency) -- base: room structure, static objects
    WindowCreate(win, 0, 0, 0, 0, miniwin.pos_center_all, 0, smu.colours.window_background) -- display window: only dynamic objects will be printed directly here
    WindowCreate(win.."overlay", 0, 0, 0, 0, miniwin.pos_center_all, 0, smu.colours.window_transparency) --overlay: room-letters
    WindowSetZOrder(win, 202)
end

function smugs_window_setup(window_width, window_height) -- define window attributes
    
    local function get_window_dimensions(window_width, window_height)
        smu.dimensions = {}
        smu.dimensions.window = {
            x = window_width, 
            y = window_height}
        smu.dimensions.buffer = {
            x = window_width  * .03, 
            y = window_height * .03}
        smu.dimensions.map = {
            x = window_width  - smu.dimensions.buffer.x * 2, 
            y = window_height - smu.dimensions.buffer.y * 2}
        smu.dimensions.block = {
            x = smu.dimensions.map.x/10, 
            y = smu.dimensions.map.y/8} 
        smu.dimensions.room = {
            x = smu.dimensions.block.x * (.6/.8), 
            y = smu.dimensions.block.y * .6}
        smu.dimensions.exit = {
            x = (smu.dimensions.block.x - smu.dimensions.room.x) / 2, 
            y = (smu.dimensions.block.y - smu.dimensions.room.y) / 2}
        smu.dimensions.down = {
            x = smu.dimensions.room.x * .45, 
            y = smu.dimensions.room.y * .45}
        return smu.dimensions
    end

    local function get_room_coordinates(dim) --dimensions

        local function get_exit_coordinates(dim, k, v, origin)

            local function give_direction(exit)
                if exit == "n" then return 0, 1 end
                if exit == "ne" then return 1, 1 end
                if exit == "e" then return 1, 0 end
                if exit == "se" then return 1, -1 end
                if exit == "s" then return 0, -1 end
                if exit == "sw" then return -1, -1 end
                if exit == "w" then return -1, 0 end
                if exit == "nw" then return -1, 1 end
            end

            smu.coordinates.rooms[k].exit = {}
            local exit_center = {}
            for dir, rm in pairs(v.exits) do
                local x_dir, y_dir = give_direction(dir) 
                local x1 = origin.x + dim.room.x/2  *  x_dir
                local y1 = origin.y + dim.room.y/2  * -y_dir
                local x2 = origin.x + (dim.block.x+1)/2 *  x_dir
                local y2 = origin.y + (dim.block.y+1)/2 * -y_dir
                if rm == 'entrance' then
                    local m = (y2-y1)/(x2-x1)
                    local b = y1 - m * x1
                    x2 = 0
                    y2 = b
                end
                smu.coordinates.rooms[k].exit[dir] = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
            end
            
            smu.coordinates.rooms[k].down = {}
			local x1 = origin.x - dim.down.x/2
			local y1 = origin.y + dim.room.y/2
			local x2 = origin.x + dim.down.x/2
			local y2 = y1 + dim.down.y
			smu.coordinates.rooms[k].down = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
        end

        local function get_letter_coordinates(dim, k, v, origin)
            local width = WindowTextWidth(win, "room_character", k)
            local x1 = origin.x - (dim.room.x / 2) + (dim.room.x - width) / 2
            local y1 = origin.y - (dim.room.y / 2) + (dim.room.y - dim.font.room_character) / 2
            local x2, y2 = 0, 0
            smu.coordinates.rooms[k].letter = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
        end

        smu.coordinates = {rooms = {}, title_text = {}, exit_text = {}}
        smu.coordinates.title_text.y1 = ((dim.font.titlebar_text * 1.1) - dim.font.titlebar_text) / 2
        smu.coordinates.exit_text.y1  = dim.buffer.y + dim.block.y
        for k, v in pairs(smu.rooms) do
            smu.coordinates.rooms[k] = {}
            smu.coordinates.rooms[k].room = {outer = {}, inner = {}}
            local room_center = {
                x = dim.buffer.x + (v.location.x * dim.block.x) - (dim.block.x / 2),
                y = dim.buffer.y + (v.location.y * dim.block.y)}
            local x1 = room_center.x - (dim.room.x / 2)
            local y1 = room_center.y - (dim.room.y / 2)
            local x2 = room_center.x + (dim.room.x / 2)
            local y2 = room_center.y + (dim.room.y / 2)
            smu.coordinates.rooms[k].room.outer = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
            get_exit_coordinates(dim, k, v, room_center)
            get_letter_coordinates(dim, k, v, room_center)
            x1 = room_center.x - ((dim.room.x * .73) / 2)
            y1 = room_center.y - ((dim.room.y * .73) / 2)
            x2 = room_center.x + ((dim.room.x * .73) / 2)
            y2 = room_center.y + ((dim.room.y * .73) / 2)
            smu.coordinates.rooms[k].room.inner  = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
        end
    end

    local function resize_windows(dim) -- dimensions 
        WindowResize(win.."copy_from", dim.down.x - 2, dim.down.y - 2, miniwin.pos_center_all, 0, smu.colours.window_transparency) -- for loading images
        WindowResize(win.."base", dim.window.x, dim.window.y, miniwin.pos_center_all, 0, smu.colours.window_transparency) -- base: room structure, static objects and bmp images
        WindowResize(win, dim.window.x, dim.window.y, smu.colours.window_background) -- display window: only dynamic objects will be printed directly here
        WindowResize(win.."overlay", dim.window.x, dim.window.y, miniwin.pos_center_all, 0, smu.colours.window_transparency) --overlay: room-letters
		window_pos_x = WindowInfo(win, 10)
		window_pos_y = WindowInfo(win, 11)
		WindowPosition(win, window_pos_x, window_pos_y, 0, 2)
    end

	-- load arrows for exit representation
    local function get_images(dim) -- dimensions
        local file_path = SMU_PATH:gsub("\\([A-Za-z_]+)\\$", "\\shared\\images\\")
		check(WindowLoadImage(win.."copy_from", "down", file_path.."down.bmp"))
		check(WindowDrawImage(win.."copy_from", "down", 0, 0, dim.down.x - 2, dim.down.y - 2, 2))
		check(WindowImageFromWindow(win, "down", win.."copy_from"))
    end
    local dimensions, colours = get_window_dimensions(window_width, window_height), smu.colours
    resize_windows(dimensions)
    smugs_get_font(dimensions)
    get_room_coordinates(dimensions)
    get_images(dimensions)
    smugs_draw_base(dimensions, colours)
    smugs_draw_overlay(dimensions, colours)

end
