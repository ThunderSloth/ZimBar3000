--------------------------------------------------------------------------------
--   INSTALL AND SAVE
--------------------------------------------------------------------------------
function on_plugin_start()
    require "tprint"
    require "serialize"
    win = "medina_map"..GetPluginID() -- define window name
    medina_get_variables()
    medina_get_regex()
    medina_get_triggers()
    medina_get_windows()
    medina_window_setup(window_width, window_height) -- define window attributes
    medina_get_hotspots(med.dimensions)
    if (type(window_pos_x) == "number") and (type(window_pos_y) == "number") then
	   WindowPosition(win, window_pos_x, window_pos_y, 0, 2)
    end
    --medina_get_timers()
end

function medina_get_variables() -- load variables
    defualt_window_width, defualt_window_height = 300, 300
    window_width, window_height = tonumber(GetVariable("window_width") or defualt_window_width), tonumber(GetVariable("window_height") or defualt_window_height)
    window_pos_x, window_pos_y = tonumber(GetVariable("window_pos_x")), tonumber(GetVariable("window_pos_y"))
    assert(loadstring(GetVariable("med") or ""))()
    if not med then med = {}; medina_reset_rooms() end
    med.exit_counts = medina_get_exit_counts(med.rooms)
    med.colours = medina_get_colours()
    med.players = {} -- set containing playernames with associated colour
    med.sync = {received = false, data = {}, is_valid = false}
    med.commands = {move = {count = 0}, look = {count = 0}}
    med.sequence = {}
    med.is_in_medina = false
end

function OnPluginSaveState () -- save variables
	SetVariable("med", "med = "..serialize.save_simple(med))
	SetVariable("window_width", window_width)
	SetVariable("window_height", window_height)
	SetVariable("window_pos_x", WindowInfo(win, 10))
	SetVariable("window_pos_y", WindowInfo(win, 11))
end

function OnPluginInstall() end
function OnPluginEnable() WindowShow(win, true) end -- show miniwindow on enable
function OnPluginDisable() WindowShow(win, false) end -- hide miniwindow on disable
function OnPluginClose() WindowShow(win, false) end -- hide miniwindow on close
--------------------------------------------------------------------------------
--   MINIWINDOW SETUP
--------------------------------------------------------------------------------
function medina_get_windows()
    local col = med.colours.window
    WindowCreate(win.."copy_from", 0, 0, 0, 0, miniwin.pos_center_all, 0, col.transparent) -- for loading images
    WindowCreate(win.."base", 0, 0, 0, 0, miniwin.pos_center_all, 0, col.transparent) -- base: room structure, static objects and bmp images
    WindowCreate(win, 0, 0, 0, 0, miniwin.pos_center_all, 0, med.colours.window.background) -- load dummy window -- display window: only dynamic objects will be printed directly here
    WindowCreate(win.."overlay", 0, 0, 0, 0, miniwin.pos_center_all, 0, col.transparent) --overlay: room-letters
    WindowSetZOrder(win, 200)
end

function medina_get_hotspots(dim) -- dimensions
    WindowAddHotspot(win, "title",
         0, 0, dim.window.x, dim.font.title, 
         "",   -- MouseOver
         "",   -- CancelMouseOver
         "mousedown",
         "cancelmousedown", 
         "mouseup", 
        "Left-click to drag!", -- tooltip text
         1, 0)  -- hand cursor
    WindowDragHandler(win, "title", "dragmove", "dragrelease", 0)
    -- add handler for resizing
    WindowAddHotspot(win, "resize", dim.window.x - 10, dim.window.y - 10, dim.window.x, dim.window.y, "MouseOver", "CancelMouseOver", "mousedown", "", "MouseUp", "Left-click to resize!", 6, 0)
    WindowDragHandler(win, "resize", "ResizeMoveCallback", "ResizeReleaseCallback", 0)
    for r, v in pairs(med.rooms) do
        local coor = med.coordinates.rooms[r].room.outter
        WindowAddHotspot(win, r,
             coor.x1, coor.y1, coor.x2, coor.y2,
             "",   
             "",  
             "mousedown",
             "cancelmousedown", 
             "mouseup", 
             '', 
             1, 0) 
    end
end

function medina_window_setup(window_width, window_height) -- define window attributes
    
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
            med.coordinates.rooms[k].room = {outter = {}, inner = {}}
            local room_center = {
                x = dim.buffer.x + (v.location.x * dim.block.x) - (dim.block.x / 2),
                y = dim.buffer.y + (v.location.y * dim.block.y)}
            local x1 = room_center.x - (dim.room.x / 2)
            local y1 = room_center.y - (dim.room.y / 2)
            local x2 = room_center.x + (dim.room.x / 2)
            local y2 = room_center.y + (dim.room.y / 2)
            med.coordinates.rooms[k].room.outter = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
            get_exit_coordinates(dim, k, v, room_center)
            get_letter_coordinates(dim, k, v, room_center)
            x1 = room_center.x - ((dim.room.x * .75) / 2)
            y1 = room_center.y - ((dim.room.y * .75) / 2)
            x2 = room_center.x + ((dim.room.x * .75) / 2)
            y2 = room_center.y + ((dim.room.y * .75) / 2)
            med.coordinates.rooms[k].room.inner  = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
        end
    end

    local function resize_windows(dim) -- dimensions
        local col = med.colours.window
        WindowResize(win.."copy_from", dim.exit.x - 4, dim.exit.y - 4, miniwin.pos_center_all, 0, col.transparent) -- for loading images
        WindowResize(win.."base", dim.window.x, dim.window.y, miniwin.pos_center_all, 0, col.transparent) -- base: room structure, static objects and bmp images
        WindowResize(win, dim.window.x, dim.window.y, col.background) -- display window: only dynamic objects will be printed directly here
        WindowResize(win.."overlay", dim.window.x, dim.window.y, miniwin.pos_center_all, 0, col.transparent) --overlay: room-letters
    end

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

    local function get_images(dim) -- dimensions
        file_path = (GetPluginInfo(GetPluginID(), 6)):match("^(.*\\).*$")
        local dir = {"n", "ne", "e", "se", "s", "sw", "w", "nw"}
        for _, v in ipairs(dir) do
            WindowLoadImage (win.."copy_from", v, file_path.."arrows\\"..v..".bmp")
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
