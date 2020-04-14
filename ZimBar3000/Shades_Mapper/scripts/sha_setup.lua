--------------------------------------------------------------------------------
--   MINIWINDOW SETUP
--------------------------------------------------------------------------------
function shades_get_windows()
    local col = sha.colours.window
    WindowCreate(win.."copy_from", 0, 0, 0, 0, miniwin.pos_center_all, 0, col.transparent) -- for loading images
    WindowCreate(win.."base", 0, 0, 0, 0, miniwin.pos_center_all, 0, col.transparent) -- base: room structure, static objects
    WindowCreate(win, 0, 0, 0, 0, miniwin.pos_center_all, 0, col.background) -- display window: only dynamic objects will be printed directly here
    WindowCreate(win.."overlay", 0, 0, 0, 0, miniwin.pos_center_all, 0, col.transparent) --overlay: room-letters
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
                local width = WindowTextWidth(win.."base", "smaller", tostring(num))
                x1 = exit_center.x - (width / 2)
                y1 = exit_center.y - (dim.font.smaller / 2)
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
            local width = WindowTextWidth(win, "larger", k)
            local x1 = origin.x - (dim.room.x / 2) + (dim.room.x - width) / 2
            local y1 = origin.y - (dim.room.y / 2) + (dim.room.y - dim.font.larger) / 2
            local x2, y2 = 0, 0
            sha.coordinates.rooms[k].letter = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
        end

        sha.coordinates = {rooms = {}, title_text = {}, exit_text = {}}
        sha.coordinates.title_text.y1 = ((dim.font.title * 1.1) - dim.font.title) / 2
        sha.coordinates.exit_text.y1  = dim.buffer.y + dim.block.y
        for k, v in pairs(sha.rooms) do
            sha.coordinates.rooms[k] = {}
            sha.coordinates.rooms[k].room = {outter = {}, inner = {}}
            local room_center = {
                x = dim.buffer.x + (v.location.x * dim.block.x) - (dim.block.x / 2),
                y = dim.buffer.y + (v.location.y * dim.block.y) - (dim.block.y / 2)}
            local x1 = room_center.x - (dim.room.x / 2)
            local y1 = room_center.y - (dim.room.y / 2)
            local x2 = room_center.x + (dim.room.x / 2)
            local y2 = room_center.y + (dim.room.y / 2)
            sha.coordinates.rooms[k].room.outter = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
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
        WindowResize(win.."copy_from", dim.exit.x - 4, dim.exit.y - 4, miniwin.pos_center_all, 0, col.transparent) -- for loading images
        WindowResize(win.."base", dim.window.x, dim.window.y, miniwin.pos_center_all, 0, col.transparent) -- base: room structure, static objects and bmp images
        WindowResize(win, dim.window.x, dim.window.y, col.background) -- display window: only dynamic objects will be printed directly here
        WindowResize(win.."overlay", dim.window.x, dim.window.y, miniwin.pos_center_all, 0, col.transparent) --overlay: room-letters
    end

    local function get_font(dim) -- dimensions
        sha.dimensions.font = {}
        local f_tbl = utils.getfontfamilies ()
        local font = {false, false}
        local choice = {
            {"System", "Fixedsys", "Arial"},       -- choices for font 1 (title)
            {"Dina", "Arial", "Helvetica"},        -- choices for font 2 (larger)
            {"Helvetica", "System", "Arial"}       -- choices for font 3 (smaller)
        }
        for i, t in ipairs(choice) do -- if our chosen font exists then pick it
            for ii, f in ipairs(t) do
                if f_tbl[f] then
                    font[i] = f
                    break
                end
            end
        end
        for i, f in ipairs(font) do -- if none of our chosen fonts are avaliable, pick the first one that is
            if not f then
                for k in pairs(f_tbl) do
                    font[i] = k
                    break
                end
            end
        end
        assert(font[1] and font[2], "Fonts not loaded!")
        for c, p in pairs({title = 150 / 11, larger = dim.room.y, smaller = dim.exit.y}) do
            local max = 200
            local h, s = 0, 1
            local t = {title = 1, larger = 2, smaller = 3}
            local f = font[t[c]]
            while (h < p) and (s < max) do
                assert(WindowFont(win, c, f, s, false, false, false, false), tostring(win).." "..tostring(c).." "..tostring(f).." "..tostring(s))
                h = tonumber(WindowFontInfo(win, c, 1)) or h or 0
                if h > p then
                    s = (s - 1) > 1 and (s - 1) or 1
                    assert(WindowFont(win, c, f, s, false, false, false, false), tostring(win).." "..tostring(c).." "..tostring(f).." "..tostring(s))
                    h = tonumber(WindowFontInfo(win, c, 1)) or h or 0
                    break
                end
                s = s + 1
            end
            for _, mw in ipairs({win.."base", win.."underlay", win.."overlay"}) do
                assert(WindowFont(mw, c, f, s, false, false, false, false), tostring(mw).." "..tostring(c).." "..tostring(f).." "..tostring(s))
                sha.dimensions.font[c] = h or 0
            end
            local loaded = WindowFontList(win)
            for k, v in pairs(loaded) do
                --print(v, WindowFontInfo(win, v, 21), WindowFontInfo(win, v, 1))
            end
        end
    end
    
    local dimensions, colours = get_window_dimensions(window_width, window_height), sha.colours
    resize_windows(dimensions)
    get_font(dimensions)
    get_room_coordinates(dimensions)
    shades_draw_base(dimensions, colours)
    shades_draw_overlay(dimensions, colours)
end

