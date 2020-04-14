--------------------------------------------------------------------------------
--   MINIWINDOW SETUP
--------------------------------------------------------------------------------
function smugs_get_windows(dim) -- dimensions
    local col = smu.colours.window
    WindowCreate(win.."copy_from", 0, 0, 0, 0, miniwin.pos_center_all, 0, col.transparent) -- for loading images
    WindowCreate(win.."base", 0, 0, 0, 0, miniwin.pos_center_all, 0, col.transparent) -- base: room structure, static objects
    WindowCreate(win, 0, 0, 0, 0, miniwin.pos_center_all, 0, col.background) -- display window: only dynamic objects will be printed directly here
    WindowCreate(win.."overlay", 0, 0, 0, 0, miniwin.pos_center_all, 0, col.transparent) --overlay: room-letters
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
        end

        local function get_letter_coordinates(dim, k, v, origin)
            local width = WindowTextWidth(win, "larger", k)
            local x1 = origin.x - (dim.room.x / 2) + (dim.room.x - width) / 2
            local y1 = origin.y - (dim.room.y / 2) + (dim.room.y - dim.font.larger) / 2
            local x2, y2 = 0, 0
            smu.coordinates.rooms[k].letter = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
        end

        smu.coordinates = {rooms = {}, title_text = {}, exit_text = {}}
        smu.coordinates.title_text.y1 = ((dim.font.title * 1.1) - dim.font.title) / 2
        smu.coordinates.exit_text.y1  = dim.buffer.y + dim.block.y
        for k, v in pairs(smu.rooms) do
            smu.coordinates.rooms[k] = {}
            smu.coordinates.rooms[k].room = {outter = {}, inner = {}}
            local room_center = {
                x = dim.buffer.x + (v.location.x * dim.block.x) - (dim.block.x / 2),
                y = dim.buffer.y + (v.location.y * dim.block.y)}
            local x1 = room_center.x - (dim.room.x / 2)
            local y1 = room_center.y - (dim.room.y / 2)
            local x2 = room_center.x + (dim.room.x / 2)
            local y2 = room_center.y + (dim.room.y / 2)
            smu.coordinates.rooms[k].room.outter = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
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
        local col = smu.colours.window
        WindowResize(win.."copy_from", dim.exit.x - 4, dim.exit.y - 4, miniwin.pos_center_all, 0, col.transparent) -- for loading images
        WindowResize(win.."base", dim.window.x, dim.window.y, miniwin.pos_center_all, 0, col.transparent) -- base: room structure, static objects and bmp images
        WindowResize(win, dim.window.x, dim.window.y, col.background) -- display window: only dynamic objects will be printed directly here
        WindowResize(win.."overlay", dim.window.x, dim.window.y, miniwin.pos_center_all, 0, col.transparent) --overlay: room-letters
    end

local function get_font(dim) -- dimensions
        smu.dimensions.font = {}
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
                smu.dimensions.font[c] = h or 0
            end
            local loaded = WindowFontList(win)
            for k, v in pairs(loaded) do
                --print(v, WindowFontInfo(win, v, 21), WindowFontInfo(win, v, 1))
            end
        end
    end

    local dimensions, colours = get_window_dimensions(window_width, window_height), smu.colours
    resize_windows(dimensions)
    get_font(dimensions)
    get_room_coordinates(dimensions)
    smugs_draw_base(dimensions, colours)
    smugs_draw_overlay(dimensions, colours)

end
