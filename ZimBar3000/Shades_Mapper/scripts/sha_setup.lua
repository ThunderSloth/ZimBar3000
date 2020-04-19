--------------------------------------------------------------------------------
--   MINIWINDOW SETUP
--------------------------------------------------------------------------------
function shades_get_windows()
    WindowCreate(win.."copy_from", 0, 0, 0, 0, miniwin.pos_center_all, 0, sha.colours.window_transparency) -- for loading images
    WindowCreate(win.."base", 0, 0, 0, 0, miniwin.pos_center_all, 0, sha.colours.window_transparency) -- base: room structure, static objects
    WindowCreate(win, 0, 0, 0, 0, miniwin.pos_center_all, 0, sha.colours.window_background) -- display window: only dynamic objects will be printed directly here
    WindowCreate(win.."overlay", 0, 0, 0, 0, miniwin.pos_center_all, 0, sha.colours.window_transparency) --overlay: room-letters
    WindowSetZOrder(win, 203)
end

function shades_window_setup(window_width, window_height) -- define window attributes
    
    local function get_window_dimensions(window_width, window_height)
        sha.dimensions = {}
        sha.dimensions.window = {
            x = window_width, 
            y = window_height}
        sha.dimensions.buffer = {
            x = window_width  * .03, 
            y = window_height * .03}
        sha.dimensions.map = {
            x = window_width  - sha.dimensions.buffer.x * 2, 
            y = window_height - sha.dimensions.buffer.y * 2}
        sha.dimensions.block = {
            x = sha.dimensions.map.x/5, 
            y = sha.dimensions.map.y/5} 
        sha.dimensions.room = {
            x = sha.dimensions.block.x * .5, 
            y = sha.dimensions.block.y * .5,}
        sha.dimensions.exit = {
            x = (sha.dimensions.block.x - sha.dimensions.room.x)*.87 / 2, 
            y = (sha.dimensions.block.y - sha.dimensions.room.y)*.87 / 2}
        return sha.dimensions
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

            sha.coordinates.rooms[k].exit = {}
            local exit_center = {}
            for dir, num in pairs(v.normalized) do
                local x_dir, y_dir = give_direction(dir) 
                local exit_center = {
                    x = origin.x + ((dim.room.x + dim.exit.x) / 2) * x_dir,
                    y = origin.y + ((dim.room.y + dim.exit.y) / 2) *-y_dir,}
                local x1 = exit_center.x - dim.exit.x/2
                local y1 = exit_center.y - dim.exit.y/2
                local x2 = exit_center.x + dim.exit.x/2
                local y2 = exit_center.y + dim.exit.y/2
                sha.coordinates.rooms[k].exit[dir] = {border = {x1 = x1, y1 = y1, x2 = x2, y2 = y2},}
                x1 = origin.x + ((dim.room.x / 2) + dim.exit.x) * x_dir
                y1 = origin.y + ((dim.room.y / 2) + dim.exit.y) *-y_dir
                x2 = origin.x + ((dim.block.x + 2) / 2) * x_dir
                y2 = origin.y + ((dim.block.y + 2) / 2) *-y_dir
                sha.coordinates.rooms[k].exit[dir].line = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
                local width = WindowTextWidth(win.."base", "exit_number", tostring(num))
                x1 = exit_center.x - (width / 2)
                y1 = exit_center.y - (dim.font.exit_number / 2)
                x2, y2 = 0, 0
                sha.coordinates.rooms[k].exit[dir].letter = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
            end
            local function get_poly_format(t)
                local function round(n)
                    return n % 1 >= 0.5 and math.ceil(n) or math.floor(n)
                end
                s = ""
                for _, v in ipairs(t) do
                    if s ~= "" then
                        s = s..","
                    end
                    s = s..tostring(round(v))
                end
                return s
            end
            if k == "G" then -- w exit
                local x1 = origin.x - dim.room.x / 2
                local y1 = origin.y
                local x2 = 0
                local y2 = y1
                sha.coordinates.w_exit = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
            elseif k == "B" or k == "Q" then -- arrowheads
                sha.coordinates.arrowhead = sha.coordinates.arrowhead or {}
                local tri = {}
                table.insert(tri, origin.x + dim.room.x / 2)
                table.insert(tri, origin.y)                  
                table.insert(tri, tri[1] + dim.exit.x)       
                table.insert(tri, tri[2] + dim.exit.y / 2)   
                table.insert(tri, tri[1] + dim.exit.x / 2)
                table.insert(tri, tri[2])
                table.insert(tri, tri[3])                    
                table.insert(tri, tri[2] - dim.exit.y / 2)   
                sha.coordinates.arrowhead[k] = get_poly_format(tri)
            elseif k == "K" then -- arrow curves
                sha.coordinates.arrowcurve = sha.coordinates.arrowcurve or {}
                for dir, r in pairs({ne = "B", se = "Q",}) do
                    local curve = {}
                    local x_dir, y_dir = give_direction(dir) 
                    table.insert(curve, origin.x + (dim.room.x / 2) + dim.exit.x)
                    table.insert(curve, origin.y + ((dim.room.y / 2) + dim.exit.y) *-y_dir)
                    table.insert(curve, curve[1])
                    table.insert(curve, curve[2] + dim.block.y *-y_dir)
                    table.insert(curve, curve[3])
                    table.insert(curve, curve[4] + (dim.block.y - dim.exit.y - (dim.room.y / 2)) *-y_dir)
                    table.insert(curve, curve[5] - dim.block.x - (dim.exit.x / 2))                  
                    table.insert(curve, curve[6])
                    sha.coordinates.arrowcurve[r] = get_poly_format(curve)
                end
            end
        end

        local function get_letter_coordinates(dim, k, v, origin)
            local width = WindowTextWidth(win, "room_character", k)
            local x1 = origin.x - (dim.room.x / 2) + (dim.room.x - width) / 2
            local y1 = origin.y - (dim.room.y / 2) + (dim.room.y - dim.font.room_character) / 2
            local x2, y2 = 0, 0
            sha.coordinates.rooms[k].letter = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
        end

        sha.coordinates = {rooms = {}, title_text = {}, exit_text = {}}
        sha.coordinates.title_text.y1 = ((dim.font.titlebar_text * 1.1) - dim.font.titlebar_text) / 2
        sha.coordinates.exit_text.y1  = dim.buffer.y + dim.block.y
        for k, v in pairs(sha.rooms) do
            sha.coordinates.rooms[k] = {}
            sha.coordinates.rooms[k].room = {outer = {}, inner = {}}
            local room_center = {
                x = dim.buffer.x + (v.location.x * dim.block.x) - (dim.block.x / 2),
                y = dim.buffer.y + (v.location.y * dim.block.y) - (dim.block.y / 2)}
            local x1 = room_center.x - (dim.room.x / 2)
            local y1 = room_center.y - (dim.room.y / 2)
            local x2 = room_center.x + (dim.room.x / 2)
            local y2 = room_center.y + (dim.room.y / 2)
            sha.coordinates.rooms[k].room.outer = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
            get_exit_coordinates(dim, k, v, room_center)
            get_letter_coordinates(dim, k, v, room_center)
            x1 = room_center.x - ((dim.room.x * .73) / 2)
            y1 = room_center.y - ((dim.room.y * .73) / 2)
            x2 = room_center.x + ((dim.room.x * .73) / 2)
            y2 = room_center.y + ((dim.room.y * .73) / 2)
            sha.coordinates.rooms[k].room.inner  = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
        end
    end

    local function resize_windows(dim) -- dimensions 
        local col = sha.colours.window
        WindowResize(win.."copy_from", dim.exit.x - 4, dim.exit.y - 4, miniwin.pos_center_all, 0, sha.colours.window_transparency) -- for loading images
        WindowResize(win.."base", dim.window.x, dim.window.y, miniwin.pos_center_all, 0, sha.colours.window_transparency) -- base: room structure, static objects and bmp images
        WindowResize(win, dim.window.x, dim.window.y, sha.colours.window_background) -- display window: only dynamic objects will be printed directly here
        WindowResize(win.."overlay", dim.window.x, dim.window.y, miniwin.pos_center_all, 0, sha.colours.window_transparency) --overlay: room-letters
    end
    
    local dimensions, colours = get_window_dimensions(window_width, window_height), sha.colours
    resize_windows(dimensions)
    shades_get_font(dimensions)
    get_room_coordinates(dimensions)
    shades_draw_base(dimensions, colours)
    shades_draw_overlay(dimensions, colours)
end

