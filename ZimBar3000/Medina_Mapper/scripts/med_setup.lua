--------------------------------------------------------------------------------
--   CREATE WINDOWS
--------------------------------------------------------------------------------
function medina_get_windows()
    WindowCreate(win.."copy_from", 0, 0, 0, 0, miniwin.pos_center_all, 0, med.colours.window_transparency) -- stage for image loading
    WindowCreate(win.."base", 0, 0, 0, 0, miniwin.pos_center_all, 0, med.colours.window_transparency)      -- base: room structure, static objects and bmp images
    WindowCreate(win, 0, 0, 0, 0, miniwin.pos_center_all, 0, med.colours.window_background)-- display window: dynamic objects draw here
    WindowCreate(win.."overlay", 0, 0, 0, 0, miniwin.pos_center_all, 0, med.colours.window_transparency)   -- overlay: room-letters
    WindowSetZOrder(win, 204)
end
--------------------------------------------------------------------------------
--   WINDOW SETUP
--------------------------------------------------------------------------------
function medina_window_setup(window_width, window_height) 
    --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	--   DIMENSIONS
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- set dimensions based off window size
    local function get_window_dimensions(window_width, window_height)
        med.dimensions = {}
        med.dimensions.window = {
            x = window_width, 
            y = window_height}
        med.dimensions.buffer = {
            x = window_width  * .05, 
            y = window_height * .05}
        med.dimensions.map = {
            x = window_width  - med.dimensions.buffer.x * 2, 
            y = window_height - med.dimensions.buffer.y * 2}
        med.dimensions.block = {
            x = med.dimensions.map.x/6, 
            y = med.dimensions.map.y/6} 
        med.dimensions.room = {
            x = med.dimensions.block.x * .5, 
            y = med.dimensions.block.y * .5}
        med.dimensions.exit = {
            x = (med.dimensions.block.x - med.dimensions.room.x) / 2, 
            y = (med.dimensions.block.y - med.dimensions.room.y) / 2}
        return med.dimensions
    end
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	--   COORDINATES
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- predetermine the coordinates of everything that will be drawn
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

            med.coordinates.rooms[k].exit = {}
            local exit_center = {}
            for dir, _ in pairs(v.normalized) do
                local x_dir, y_dir = give_direction(dir) 
                local exit_center = {
                    x = origin.x + ((dim.room.x + dim.exit.x) / 2) * x_dir,
                    y = origin.y + ((dim.room.y + dim.exit.y) / 2) *-y_dir,}
                local x1 = exit_center.x - dim.exit.x/2
                local y1 = exit_center.y - dim.exit.y/2
                local x2 = exit_center.x + dim.exit.x/2
                local y2 = exit_center.y + dim.exit.y/2
                med.coordinates.rooms[k].exit[dir] = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
            end
        end

        local function get_letter_coordinates(dim, k, v, origin)
            local width = WindowTextWidth(win, "larger", k)
            local x1 = origin.x - (dim.room.x / 2) + (dim.room.x - width) / 2
            local y1 = origin.y - (dim.room.y / 2) + (dim.room.y - dim.font.larger) / 2
            local x2, y2 = 0, 0
            med.coordinates.rooms[k].letter = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
        end

        med.coordinates = {rooms = {}, title_text = {}, exit_text = {}}
        med.coordinates.title_text.y1 = ((dim.font.title * 1.1) - dim.font.title) / 2
        med.coordinates.exit_text.y1  = dim.buffer.y + dim.block.y * 5.5
        for k, v in pairs(med.rooms) do
            med.coordinates.rooms[k] = {}
            med.coordinates.rooms[k].room = {outer = {}, inner = {}}
            local room_center = {
                x = dim.buffer.x + (v.location.x * dim.block.x) - (dim.block.x / 2),
                y = dim.buffer.y + (v.location.y * dim.block.y)}
            local x1 = room_center.x - (dim.room.x / 2)
            local y1 = room_center.y - (dim.room.y / 2)
            local x2 = room_center.x + (dim.room.x / 2)
            local y2 = room_center.y + (dim.room.y / 2)
            med.coordinates.rooms[k].room.outer = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
            get_exit_coordinates(dim, k, v, room_center)
            get_letter_coordinates(dim, k, v, room_center)
            x1 = room_center.x - ((dim.room.x * .75) / 2)
            y1 = room_center.y - ((dim.room.y * .75) / 2)
            x2 = room_center.x + ((dim.room.x * .75) / 2)
            y2 = room_center.y + ((dim.room.y * .75) / 2)
            med.coordinates.rooms[k].room.inner  = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
        end
    end
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	--   DIMENSIONS
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- resize windows to saved or defualt size
    local function resize_windows(dim) -- dimensions
        WindowResize(win.."copy_from", dim.exit.x - 4, dim.exit.y - 4, miniwin.pos_center_all, 0, med.colours.window_transparency) -- for loading images
        WindowResize(win.."base", dim.window.x, dim.window.y, miniwin.pos_center_all, 0, med.colours.window_transparency) -- base: room structure, static objects and bmp images
        WindowResize(win, dim.window.x, dim.window.y, med.colours.window_background) -- display window: only dynamic objects will be printed directly here
        WindowResize(win.."overlay", dim.window.x, dim.window.y, miniwin.pos_center_all, 0, med.colours.window_transparency) --overlay: room-letters
    end
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	--   DIMENSIONS
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- load font based on window size
    local function get_font(dim) -- dimensions
        med.dimensions.font = {}
        local f_tbl = utils.getfontfamilies ()
        local font = {false, false}
        local choice = {
            {"System", "Fixedsys", "Arial"},  -- choices for font 1 (title)
            {"Dina", "Arial", "Helvetica"}    -- choices for font 2
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
        for c, p in pairs({title = 150 / 11, larger = dim.room.y}) do
            local max = 200
            local h, s = 0, 1
            local f = c == "title" and font[1] or font[2]
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
                med.dimensions.font[c] = h or 0
            end
        end
    end
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	--   IMAGES
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- load arrows for exit representation
    local function get_images(dim) -- dimensions
		arrow_set = arrow_set or "default"
        local file_path = (GetPluginInfo(GetPluginID(), 6)):match("^(.*\\).*$").."arrows\\"..arrow_set.."\\"
        local dir = {"n", "ne", "e", "se", "s", "sw", "w", "nw"}
        for _, v in ipairs(dir) do
            WindowLoadImage (win.."copy_from", v, file_path..v..".bmp")
            WindowDrawImage(win.."copy_from", v, 0, 0, dim.exit.x - 4, dim.exit.y - 4, 2)
            WindowImageFromWindow(win.."base", v, win.."copy_from")
        end
    end
    local dimensions, colours = get_window_dimensions(window_width, window_height), med.colours
    resize_windows(dimensions)
    get_font(dimensions)
    get_room_coordinates(dimensions)
    get_images(dimensions)
    medina_draw_base(dimensions, colours)
    medina_draw_overlay(dimensions, colours)
end
