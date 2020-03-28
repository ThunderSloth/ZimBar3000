 --[[ Zimbus's
  _________.__                .___               _____                                    ._.
 /   _____/|  |__ _____     __| _/____   ______ /     \ _____  ______ ______   ___________| |
 \_____  \ |  |  \\__  \   / __ |/ __ \ /  ___//  \ /  \\__  \ \____ \\____ \_/ __ \_  __ \ |
 /        \|   Y  \/ __ \_/ /_/ \  ___/ \___ \/    Y    \/ __ \|  |_> >  |_> >  ___/|  | \/\|
/_______  /|___|  (____  /\____ |\___  >____  >____|__  (____  /   __/|   __/ \___  >__|   __
        \/      \/     \/      \/    \/     \/        \/     \/|__|   |__|        \/       \]]
--------------------------------------------------------------------------------
--   INSTALL AND SAVE
--------------------------------------------------------------------------------
function on_plugin_start()
    require "tprint"
    require "serialize"
    win = "shades_map"..GetPluginID() -- define window name
    shades_get_variables()
    shades_get_windows()
    shades_window_setup(window_width, window_height)
    shades_get_hotspots(sha.dimensions)
    shades_get_triggers()
    if (type(window_pos_x) == "number") and (type(window_pos_y) == "number") then
	   WindowPosition(win, window_pos_x, window_pos_y, 0, 2)
    end
end

function shades_get_variables()
    defualt_window_width = 300
    defualt_window_height = 300
    window_width, window_height = tonumber(GetVariable("window_width") or defualt_window_width), tonumber(GetVariable("window_height") or defualt_window_height)
    window_pos_x, window_pos_y = tonumber(GetVariable("window_pos_x")), tonumber(GetVariable("window_pos_y"))
   --[[1 2 3 4 5
     **************
    1*     A-B<-  *
     *    /|x|\ \ *
    2*   C-D-E-F )*
     *  /|x|x|x|/ *
    3*-G-H-I-J-K  *
     *  \|x|x|x|\ *
    4*   L-M-N-O )*
     *    \|x|/ / *
    5*     P-Q<-  *
     **************]]    
    sha = {
        rooms = {--      ( 1    2    3    4    5    6    7    8  )               (n    ne    e    se    s    sw    w    nw   )
            A = {exits = {"E", "C", "D", "B",                    }, normalized = {           e=4, se=1, s=3, sw=2,           }, location = {x = 3, y = 1,}, },
            B = {exits = {"F", "A", "E", "D",                    }, normalized = {                se=1, s=3, sw=4, w=2,      }, location = {x = 4, y = 1,}, },
            C = {exits = {"G", "I", "D", "H", "A",               }, normalized = {     ne=5, e=3, se=2, s=4, sw=1,           }, location = {x = 2, y = 2,}, },
            D = {exits = {"H", "C", "E", "I", "J", "A", "B",     }, normalized = {n=6, ne=7, e=3, se=5, s=4, sw=1, w=2,      }, location = {x = 3, y = 2,}, },
            E = {exits = {"I", "K", "J", "D", "A", "F", "B",     }, normalized = {n=7,       e=6, se=2, s=3, sw=1, w=4, nw=5,}, location = {x = 4, y = 2,}, },
            F = {exits = {"K", "E", "B", "J",                    }, normalized = {                      s=1, sw=4, w=2, nw=3,}, location = {x = 5, y = 2,}, },
            G = {exits = {"C", "L", "H",                         }, normalized = {     ne=1, e=3, se=2,                      }, location = {x = 1, y = 3,}, },
            H = {exits = {"G", "D", "M", "C", "L", "I",          }, normalized = {n=4, ne=2, e=6, se=3, s=5,       w=1,      }, location = {x = 2, y = 3,}, },
            I = {exits = {"C", "H", "D", "E", "M", "L", "J", "N",}, normalized = {n=3, ne=4, e=7, se=8, s=5, sw=6, w=2, nw=1,}, location = {x = 3, y = 3,}, },
            J = {exits = {"K", "D", "E", "I", "M", "N", "O", "F",}, normalized = {n=3, ne=8, e=1, se=7, s=6, sw=5, w=4, nw=2,}, location = {x = 4, y = 3,}, },
            K = {exits = {"N", "J", "E", "Q", "O", "F", "B",     }, normalized = {n=6, ne=7,      se=4, s=5, sw=1, w=2, nw=3,}, location = {x = 5, y = 3,}, },
            L = {exits = {"G", "I", "M", "H", "P",               }, normalized = {n=4, ne=2, e=3, se=5,                 nw=1,}, location = {x = 2, y = 4,}, },
            M = {exits = {"L", "I", "J", "H", "N", "P", "Q",     }, normalized = {n=2, ne=3, e=5, se=7, s=6,       w=1, nw=4,}, location = {x = 3, y = 4,}, },
            N = {exits = {"J", "K", "M", "I", "P", "O", "Q",     }, normalized = {n=1, ne=2, e=6,       s=7, sw=5, w=3, nw=4,}, location = {x = 4, y = 4,}, },
            O = {exits = {"Q", "N", "K", "J",                    }, normalized = {n=3,                       sw=1, w=2, nw=4,}, location = {x = 5, y = 4,}, },
            P = {exits = {"N", "M", "L", "Q",                    }, normalized = {n=2, ne=1, e=4,                       nw=3,}, location = {x = 3, y = 5,}, },
            Q = {exits = {"P", "M", "N", "O",                    }, normalized = {n=3, ne=4,                       w=1, nw=2,}, location = {x = 4, y = 5,}, },
        },
        colours = shades_get_colours(),
        commands = {count = 0},
        sequence = {},
        is_in_shades = false,}
    for k, v in pairs(sha.rooms) do -- create inverse set of exits
        sha.rooms[k].path = sha.rooms[k].path or {}
        for r, x in pairs(v.exits) do
            sha.rooms[k].path[x] = r
        end
    end
end

function shades_get_colours()
    local col = {
        window = {
            background = "black",
            border =     "white",
            transparent ="teal",},
        title = {
            text =       "black",
            border =     "white",
            fill =       "lightgray",},
        rooms = {
            border =     "white",
            background = "black",
            visited =    "gray",
            unvisited =  "lightblue",},
        exits = {
            border =     "gray",
            background = "black",
            line =       "gray",
            special =    "white",
            numbers =   {"#a9a9a9", "#ff0000", "#ff7f00", "#9b870c", "#228b22", "#0000ff", "#9370db", "#ba55d3",},},
        arrows = {
            border =     "white",
            fill =       "white",},
        thyngs = {
            you =        "yellow",
            ghost =      "yellow",
            players =    "blue",
            trolls =     "red",
            fighters =   "yellow",
            muggers =    "white",
            others =     "gray",
            xp = {"#003300", "#004c00", "#006600", "#007f00", "#009900", "#00b200", "#00cc00", "#00e500", "#00ff00",},},
        note = {
            bracket =   "white",
            error =     "red",
            text =      "gray",},}

    for k, v in pairs(col) do
        for kk, c in pairs(v) do
            if type(c) == 'string' then
                col[k][kk] = ColourNameToRGB(c)
            else
                for i, cc in ipairs(c) do
                   col[k][kk][i] = ColourNameToRGB(cc) 
                end
            end
        end
    end
    return col
end

function OnPluginSaveState () -- save variables
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
function shades_get_windows()
    local col = sha.colours.window
    WindowCreate(win.."copy_from", 0, 0, 0, 0, miniwin.pos_center_all, 0, col.transparent) -- for loading images
    WindowCreate(win.."base", 0, 0, 0, 0, miniwin.pos_center_all, 0, col.transparent) -- base: room structure, static objects
    WindowCreate(win, 0, 0, 0, 0, miniwin.pos_center_all, 0, col.background) -- display window: only dynamic objects will be printed directly here
    WindowCreate(win.."overlay", 0, 0, 0, 0, miniwin.pos_center_all, 0, col.transparent) --overlay: room-letters
    WindowSetZOrder(win, 200)
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

function shades_get_hotspots(dim) -- dimensions
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
    for r, v in pairs(sha.rooms) do
        local coor = sha.coordinates.rooms[r].room.outter
        WindowAddHotspot(win, r,
             coor.x1, coor.y1, coor.x2, coor.y2,
             "",   -- MouseOver
             "",   -- CancelMouseOver
             "mousedown",
             "cancelmousedown", 
             "mouseup", 
             '', -- tooltip text
             1, 0)  -- hand cursor
    end
end
--------------------------------------------------------------------------------
--   HOTSPOT HANDLERS
--------------------------------------------------------------------------------
function dragmove(flags, hotspot_id)
	if hotspot_id == "title" then
        local max_x, max_y = GetInfo(281), GetInfo(280)
        local min_x, min_y = 0, 0
		local drag_x, drag_y = WindowInfo(win, 17), WindowInfo(win, 18)
        local to_x, to_y = drag_x - from_x, drag_y - from_y
        if to_x < min_x then 
            to_x = 0 
        elseif to_x + window_width> max_x then
            to_x = max_x - window_width
        end
        if to_y < min_y then 
            to_y = 0 
        elseif to_y + window_height > max_y then
            to_y = max_y - window_height
        end
		WindowPosition(win, to_x, to_y, 0, 2) -- move the window to the new location
		if drag_x < min_x or drag_x > max_x or
		   drag_y < min_y or drag_y > max_y then -- change the mouse cursor shape appropriately
			check(SetCursor(11)) -- x cursor
		else
			check(SetCursor(1)) -- hand cursor
		end
	end
end
function dragrelease(flags, hotspot_id) end

-- called when the resize drag widget is moved
function ResizeMoveCallback()
    local min = 300
    local start_x, start_y = WindowInfo(win, 10), WindowInfo(win, 11)
    local drag_x,   drag_y = WindowInfo(win, 17), WindowInfo(win, 18)
    local max_x,     max_y = GetInfo(281),        GetInfo(280)
    window_width  = drag_x - start_x
    window_height = drag_y - start_y
    window_pos_x =  drag_x
    window_pos_y =  drag_y
    if window_width > window_height then -- force square
        window_height = window_width
    else
        window_width = window_height
    end
    local out_of_bounds = false
    if window_width  + start_x > max_x then 
        window_width  = max_x - start_x; window_height = window_width; out_of_bounds = true
    end
    if window_height + start_y > max_y then 
        window_height = max_y - start_y; window_width  = window_height; out_of_bounds = true
    end
    if window_width  < min then 
        window_width  = min; window_height = window_width; out_of_bounds = true 
    end
    if window_height < min then 
        window_height = min; window_width  = window_height; out_of_bounds = true
    end
    if out_of_bounds then
        check(SetCursor(11)) -- x cursor
    else
        check(SetCursor(6)) -- resize cursor
    end
    if (utils.timer() - (last_refresh or 0) > 0.0333) then
        WindowResize(win, window_width, window_height, sha.colours.window.background)
        WindowDrawImage(win, "win", 0, 0, window_width, window_height, 2)
        WindowShow(win)
        last_refresh = utils.timer()
   end
end

-- called after the resize widget is released
function ResizeReleaseCallback()
    shades_window_setup(window_width, window_height)
    shades_get_hotspots(sha.dimensions)
    shades_print_map()
end

-- called when mouse button is pressed on hotspot
function mousedown(flags, hotspot_id)
    if hotspot_id == "title" then
		from_x, from_y = WindowInfo(win, 14), WindowInfo(win, 15)
    elseif (hotspot_id == "resize") then
        WindowImageFromWindow(win, "win", win)
    end
end

function mouseup(flags, id)
	if id:match("^[A-Z]$") then
        shades_get_shortest_path(sha.rooms, sha.sequence[#sha.sequence][1], id)
    end
end
--------------------------------------------------------------------------------
--   SHORTEST PATH
--------------------------------------------------------------------------------
function shades_get_shortest_path(graph, start_node, end_node) -- BFS
    local function humanized_pairs(t1) --sorts by key length so that orthagonal directions will come before diagonal directions, creating a more human-like route
        local t2 = {}
        for k, _ in pairs(t1) do table.insert(t2, k) end
            table.sort(t2, function(a,b)
                if string.len(a) == string.len(b) then
                    return a < b
                else
                    return string.len(a) < string.len(b) 
                end
            end)
        local i = 0
        return function() 
            i = i + 1
            if t2[i] then 
                return t2[i], t1[t2[i]] 
            end 
        end
    end
    local function deepcopy(orig)
        local orig_type = type(orig)
        local copy
        if orig_type == 'table' then
            copy = {}
            for orig_key, orig_value in next, orig, nil do
                copy[deepcopy(orig_key)] = deepcopy(orig_value)
            end
            setmetatable(copy, deepcopy(getmetatable(orig)))
        else -- number, string, boolean, etc
            copy = orig
        end
        return copy
    end
    local g, solved = deepcopy(graph), false
    if start_node then
        local queue, visited, current = {}, {}, ""
        queue[1] = start_node
        visited[start_node] = true
        g[start_node].parent = false
        while #queue > 0 do
            current = queue[1]
            table.remove(queue, 1)
           if current == end_node then
                solved = true
               break
            end
            for _, i in humanized_pairs(g[current].normalized) do
                local r = g[current].exits[i]
                if not(visited[r]) then
                    visited[r] = true
                    table.insert(queue, r)
                    g[r].parent = current
                end
            end  
        end
        local path, source_node = {}, g[end_node].parent
        while source_node do
            table.insert(path, 1, source_node)
            source_node = g[source_node].parent
        end
        table.insert(path, end_node);table.remove(path, 1)
        local path_text = {}
        if solved then
            current = start_node
            for _, v in ipairs(path) do
                local direction = sha.rooms[current].path[v]
                on_alias_shades_move_room('name', 'line', {direction = direction})
                current = v
            end
        else
            ColourNote("white", "black", "<", "red", "black", "No path found!", "white", "black", ">")
        end
    end
    return solved
end
-------------------------------------------------------------------------------
--  GRAPHICAL FUNCTIONS
-------------------------------------------------------------------------------
function shades_draw_room(room, coor, col, mw) -- room, coordinates, colours, miniwindow
    WindowCircleOp(mw, 2, -- draw room
	    coor.room.outter.x1, coor.room.outter.y1, coor.room.outter.x2, coor.room.outter.y2,            
	    col.rooms.border, 0, 1,
	    col.rooms.background, miniwin.brush_null)
end

function shades_draw_room_exits(room, coor, col, mw) --room, coordinates, colours, miniwindow
    for norm, num in pairs(sha.rooms[room].normalized) do
        WindowCircleOp(mw, 2, -- draw exit
            coor.exit[norm].border.x1, coor.exit[norm].border.y1, coor.exit[norm].border.x2, coor.exit[norm].border.y2,            
            col.exits.border, 0, 1,
            col.exits.background, miniwin.brush_solid)
        if not(room == "K" and (norm == "ne" or norm == "se")) then
            WindowLine(
                mw, 
                coor.exit[norm].line.x1, coor.exit[norm].line.y1, coor.exit[norm].line.x2, coor.exit[norm].line.y2,
                col.exits.line, miniwin.pen_solid, 1)
        end
        shades_draw_exit_number(num, coor.exit[norm], col.exits.numbers[num])
    end
end

function shades_draw_exit_number(num, coor, col) -- room, coordinates, colours
    WindowText (win.."base", "smaller", num,
        coor.letter.x1, coor.letter.y1, 0, 0,
        col, 
        false)
end

function shades_draw_base(dim, col) -- dimensions, colours
    local coordinates = sha.coordinates
    WindowCircleOp( -- window border
        win.."base", miniwin.circle_rectangle, 
        0, 0, dim.window.x, dim.window.y,
        col.window.border, miniwin.pen_solid, 1,
        col.window.background, 0)
    WindowLine( -- w exit
        win.."base", 
        coordinates.w_exit.x1, coordinates.w_exit.y1, coordinates.w_exit.x2, coordinates.w_exit.y2, 
        col.exits.special, miniwin.pen_dot, 1)
    for _, r in ipairs({"B", "Q"}) do
        WindowPolygon(win.."base", sha.coordinates.arrowhead[r],
            col.arrows.border, miniwin.pen_solid, 1,
            col.arrows.fill, miniwin.brush_solid,
            true,
            false)
        WindowBezier (win.."base", sha.coordinates.arrowcurve[r], 
              col.arrows.border, miniwin.pen_dot, 1)
    end
    WindowCircleOp( -- title bar
        win.."base", miniwin.circle_rectangle, 
        0, 0, dim.window.x, dim.font.title * 1.1,
        col.title.border, miniwin.pen_solid, 1,
        col.title.fill, 0)
    local title = "Shades Maze"
    local text_width = WindowTextWidth(win.."base", "title", title)
    local x1 = (dim.window.x - text_width) / 2
    local y1 = coordinates.title_text.y1 
    local x2 = x1 + text_width
    local y2 = y1 + dim.font.title
    WindowText(win.."base", "title", title, x1, y1, x2, y2, col.title.text)
    for room, coor in pairs(coordinates.rooms) do
        shades_draw_room(room, coor, col, win.."base") -- draw room
        shades_draw_room_exits(room, coor, col, win.."base") -- draw exits
    end
end

function shades_draw_room_letter(room, coor, col) -- room, coordinates, colours
    local letter_colour = sha.rooms[room].visited and col.rooms.visited or col.rooms.unvisited
    WindowText (win.."overlay", "larger", room,
        coor.letter.x1, coor.letter.y1, 0, 0,
        letter_colour, 
        false)
end

function shades_draw_overlay(dim, col) -- dimensions, colours
    WindowCircleOp( -- transparent background
        win.."overlay", miniwin.circle_rectangle, 
        0, 0, dim.window.x, dim.window.y,
        col.window.transparent, miniwin.pen_solid, 1,
        col.window.transparent, 0)
    local coordinates = sha.coordinates
    for room, coor in pairs(coordinates.rooms) do
        shades_draw_room_letter(room, coor, col)
    end
end

function shades_print_map()
    local start_time = os.clock()
    local function draw_dynamic(coordinates, col, current_room)
        local function draw_thyng(room, coor, colour) -- room, coordinates
            for i , r in ipairs(room) do
                local fill_style = i == 1 and 0 or 8
                WindowCircleOp(win, 2,
                    coor[r].room.inner.x1, coor[r].room.inner.y1, coor[r].room.inner.x2, coor[r].room.inner.y2,            
                    col.window.background, 0, 0,
                    colour, fill_style)
                WindowRectOp (win, 1, coor[r].room.inner.x1, coor[r].room.inner.y1, coor[r].room.inner.x2, coor[r].room.inner.y2, colour)
            end
        end
        local function draw_border(room, coor, colour)
            for _ , r in ipairs(room) do
                WindowRectOp(win, miniwin.rect_frame, 
                    coor[r].room.outter.x1, coor[r].room.outter.y1, coor[r].room.outter.x2, coor[r].room.outter.y2,
                    colour)
            end
        end
        local trajectory_room = #sha.sequence ~= 0 and sha.sequence[#sha.sequence] or {}
        draw_border(trajectory_room, coordinates.rooms, col.thyngs.ghost)
        draw_thyng(current_room, coordinates.rooms, col.thyngs.you)
    end
    local current_room = sha.sequence[1] or {}
    WindowImageFromWindow(win, "base", win.."base")
    WindowDrawImage(win, "base", 0, 0, 0, 0, 1) -- copy base
    draw_dynamic(sha.coordinates, sha.colours, current_room) -- add dynamic
    WindowImageFromWindow(win, "overlay", win.."overlay")
    WindowDrawImage(win, "overlay", 0, 0, 0, 0, 3) -- copy overlay
    WindowShow(win, true)
    --print(os.clock() - start_time) -- speed test
end

-------------------------------------------------------------------------------
--  CONSTRUCT TRIGGERS
-------------------------------------------------------------------------------
function shades_get_triggers()
    local desc = {
        title = {"somewhere in the Shades", "maze entrance",}, -- entrance = G
        scry  = "(?<scry>(The crystal ball changes to show a vision of the area where .* is|The image in the crystal ball fades, but quickly returns showing a new area|You see a vision in the .*|You look through the .* (door|fur)|You see a vision in the silver mirror|You see):|You focus past the .* baton, and visualise the place you remembered...|You briefly see a vision.)",
        look  = "(?<look>.*)",
        map = "([@ ]+\\n)?",
        moon  = "((It is night and|The (water|land) is lit up by) the.*(?<moon>(crescent|(three )?quarter|half|gibbous|no|full) moon)( is hidden by the clouds)?.\\n)?",
        long = {
            "Deep, deep into the Shades. This alley is like every other alley in this rabbit warren of death.  It is dank, dark and foggy, everything looks the same...",
            "The alleyways here all look the same.  Dim fires flicker in the distance, providing more a kind of glow than real light.",
            "There is no hope of ever escaping this nightmare.  Grime covers the walls, and the dank slime underfoot makes walking slippery.  The ever present fog and gloom makes trying to see a way out impossible.",
            "There is no hope of ever escaping this nightmare.  Grime covers the walls, and the dank slime underfoot makes walking slippery.  The ever present fog and gloom makes trying to see a way out impossible.",
            "This room is like any of the other alleyways, dank, dark and foggy.  It has lots of exits that lead to other dank, dark and foggy alleyways.  Howls of fear and pain echo around from the walls.",
            "duplicate: BFOQ",
            "This is deep in the Shades.  What passes for civilization in these parts is to the west, but otherwise there are three alleyways in weaving twisting directions which don't appear on any compass.  Further in is a deadly maze of dangerous alleyways.",
            "There is no hope of ever escaping this nightmare.  Grime covers the walls, and the dank slime underfoot makes walking slippery.  The ever present fog and gloom makes trying to see a way out impossible.",
            "The Lady is evidently not on your side; at every turn lies another twisting alleyway.  Dim torches flicker red through the fog, providing more a sinister red glow than any real light.",
            "There is no hope of ever escaping this nightmare.  Grime covers the walls, and the dank slime underfoot makes walking slippery.  The ever present fog and gloom makes trying to see a way out impossible.",
            "This rabbit warren of smoky, hazy alleys is never ending.  The gloom and fog mask the direction of the screams that echo in the distance...",
            "This dark, dank, foggy alleyway leads to other dark dank foggy alleyways.  The gloom hides the worst of the horrors that these alleys contain.",
            "The alleyways here all look the same.  Dim fires flicker in the distance, providing more a kind of glow than real light.",
            "duplicate: DN",
            "duplicate: BFOQ",
            "Deep, deep into the Shades. This alleyway is like every other alleyway in this rabbit warren of death.  It is dank, dark and foggy, everything looks the same...",
            "duplicate: BFOQ",
        },
        extra1   = "(?<extra1>.*\\n)?",
        extra2   = "(?<extra2>.*\\n)?",
        weather1 = "(?<weather1>It is an? .*)\\n",
        weather2 = "(?<weather2>(?!.* obvious exits:).*\\n)?",
    }
    desc.not_moon = desc.moon:gsub("[(][?]<moon>[(]crescent|[(]three [)][?]quarter|half|gibbous|no|full[)] moon[)]", "moon"):gsub("\\n[)][?]", ")"):gsub("^[(]", "(?!")

    for i, v in ipairs(desc.title) do
      desc.title[i] = '(?<title>\\['..v..'\\])'
    end

    local triggers = {}
    for i = 1, 17 do
        local letter = string.char(i + 64)
        local regex = '^'
        local count = 1
        if r == 'G' then
            regex = regex..desc.title[2]..'$'
        else
            regex = regex..'('..desc.title[1]..'|'..desc.scry..'|'..desc.not_moon..desc.look..')\\n'..desc.map..desc.moon..desc.long[i]
            count = 4
            if letter:match("[BCDFHJMNOQ]") then
                regex = regex..'\\n'
                local order = {'extra1', 'extra2', 'weather1', 'weather2', 'exits',}
                for _, k in ipairs(order) do
                    if k == 'exits' then
                        local n = #sha.rooms[letter].exits
                        local num = {'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine'}
                        local exits = '(?<exits>There are (?(?=.* enter door.)'..num[(n + 1)]..'|'..num[(n)]..') obvious exits: .*)'
                        regex = regex..exits
                    else
                        regex = regex..desc[k]
                    end
                    count = count + 1
                end
            end
            regex = regex..'\\Z'
        end

        local name = letter
        if name:match("[BFOQ]") then
            name = 'BFOQ'
        elseif name:match("[DN]") then
            name = 'DN'
        end

        local script = 'on_trigger_shades_verbose'
        local multi_line = r == 'G' and 'n' or 'y' 
        
        triggers[i] = {
            match = regex,
            group ='shades',
            name = 'shades_verbose_'..name,
            script = script,
            multi_line = multi_line,
            count = count,
            keep_evaluating = 'y',
            regexp = 'y',
            sequence = '100',}

    end
    
    for _, i in ipairs({6, 14, 15, 17}) do
        triggers[i] = {} -- remove duplicates
    end

    for _, v in pairs(triggers) do
        if v.match then
            AddTrigger(v.name, v.match, "", trigger_flag.KeepEvaluating + trigger_flag.IgnoreCase + trigger_flag.RegularExpression, custom_colour.NoChange, 0, "", v.script)
            SetTriggerOption (v.name, "group", v.group)
            SetTriggerOption (v.name, "multi_line", v.multi_line)
            if v.multi_line == 'y' then
                SetTriggerOption (v.name, "lines_to_match", v.count)
            end
            SetTriggerOption (v.name, "enabled", "n")
        end
    end
    
end
-------------------------------------------------------------------------------
--  GMCP EVENTS
-------------------------------------------------------------------------------
-- set GMCP connection
function OnPluginTelnetRequest(msg_type, data_line)
    local function send_GMCP(packet) -- send packet to mud to initialize handshake
        assert(packet, "send_GMCP passed nil message")
        SendPkt(string.char(0xFF, 0xFA, 201)..(string.gsub(packet, "\255", "\255\255")) .. string.char(0xFF, 0xF0))
    end
    if msg_type == 201 then
        if data_line == "WILL" then
            return true
        elseif (data_line == "SENT_DO") then
            send_GMCP(string.format('Core.Hello { "client": "MUSHclient", "version": "%s" }', Version()))
            local supports = '"room.info", "room.map", "room.writtenmap", "char.vitals", "char.info"'
            send_GMCP('Core.Supports.Set [ '..utils.base64decode(utils.base64encode(supports))..' ]')
            return true
        end
    end
    return false
end

-- on plugin callback to pick up GMCP
function OnPluginTelnetSubnegotiation(msg_type, data_line)
    if msg_type == 201 and data_line:match("([%a.]+)%s+.*") then
        shades_recieve_GMCP(data_line)
    end
end

function shades_recieve_GMCP(text)
    if text:match("^room.info .*") then
        local id = text:match('^.*"identifier":"(.-)".*$')
        if id == "01bbd8b887e71314d8e358cbaf4f585391206bc4" or id == "AMShades" then
            shades_enter()
        else
            shades_exit()
        end
    end
end
--------------------------------------------------------------------------------
--  ENTER AND EXIT HANDLING
--------------------------------------------------------------------------------
function shades_enter()
    if not(sha.is_in_shades) then
        sha.is_in_shades = true
        sha.commands, sha.sequence = {count = 0}, {}
        EnableGroup("shades", true)
        DeleteTimer("shades_unvisit")
    end
end

function shades_exit()
    if sha.is_in_shades then
        sha.is_in_shades = false
        sha.commands, sha.sequence = {count = 0}, {}
        EnableGroup("shades", false)
        AddTimer("shades_unvisit", 0, 3, 0, "", timer_flag.Enabled + timer_flag.Replace + timer_flag.Temporary + timer_flag.OneShot, "shades_unvisit")
    end
    WindowShow(win, false)
end

function shades_unvisit()
    for r, _ in pairs(sha.rooms) do
        sha.rooms[r].visited = false
        shades_draw_room_letter(r, sha.coordinates.rooms[r], sha.colours)
    end
end
--------------------------------------------------------------------------------
--   MOVEMENT HANDLING
--------------------------------------------------------------------------------
function shades_move_room(room)
    if sha.commands[1] ~= "l" then 
        sha.commands[0] = sha.commands[1]
        sha.sequence[0] = sha.sequence[1]
    end
    table.remove(sha.commands, 1); table.remove(sha.sequence, 1)
    local direction = sha.commands[0]
    local current_room, presumed_room = room, sha.sequence[1] or {}
    local previous_room = sha.sequence[0] or {}
    previous_room, current_room = shades_verify_room(previous_room, current_room, presumed_room)
    sha.sequence[0], sha.sequence[1] = previous_room, current_room
    local absolute_current = #current_room == 1 and current_room[1] or false
    if absolute_current and not(sha.rooms[absolute_current].visited) then
        sha.rooms[absolute_current].visited = true
        shades_draw_room_letter(absolute_current, sha.coordinates.rooms[absolute_current], sha.colours) 
    end
    local absolute_previous = #previous_room == 1 and previous_room[1] or false
    if absolute_previous and not(sha.rooms[absolute_previous].visited) then
        sha.rooms[absolute_previous].visited = true
        shades_draw_room_letter(absolute_previous, sha.coordinates.rooms[absolute_previous], sha.colours) 
    end
    shades_construct_seq()
    shades_print_map()
end

function shades_verify_room(previous_room, current_room, presumed_room)
    local possible_current, possible_previous, presumed_room = {}, {}, shades_to_set(presumed_room)
    for _, r in ipairs(current_room or {}) do
        if presumed_room[r] then -- presumed must be in set of current
            possible_current[r] = true
        end
    end
    possible_current = shades_to_list(possible_current)
    if #possible_current == 0 then -- no overlap
        possible_current = current_room
    end
    local direction = sha.commands[0] or false
    if direction then
        for _, pr in ipairs(previous_room) do
            for _2, pc in ipairs(possible_current) do
                if sha.rooms[pr].exits[direction] == pc or sha.rooms[pr].normalized[direction] == pc then
                    possible_previous[pr] = true
                end
            end
        end
        possible_previous = shades_to_list(possible_previous)
    end
    return possible_previous, possible_current
end

function shades_construct_seq()
    while(sha.sequence[2]) do table.remove(sha.sequence, 2) end
    for _, direction in ipairs(sha.commands) do
        table.insert(sha.sequence, shades_to_list(shades_get_seq(sha.sequence[#sha.sequence], direction)))
    end
end

function shades_get_seq(start_room, direction)
    local end_room = {}
    if direction == "l" then
        for _, r in ipairs(start_room) do
            end_room[r] = true
        end
    else
        for _, r in ipairs(start_room) do --tag
            if sha.rooms[r].exits[direction] then
                end_room[sha.rooms[r].exits[direction]] = true
            elseif sha.rooms[r].normalized[direction] and sha.rooms[r].exits[sha.rooms[r].normalized[direction]] then
                end_room[sha.rooms[r].exits[sha.rooms[r].normalized[direction]]] = true
            elseif not (r == 'G' and direction == 'w') then
                end_room[r] = true            
            end
        end
    end
    return end_room -- in set form
end

function on_alias_shades_move_room(name, line, wildcards)
    sha.commands.count = (sha.commands.count or 0) + 1 -- used in 'stop' handling
    local direction = shades_format_direction(wildcards.direction) 
    local first_room = sha.sequence[#sha.sequence] and sha.sequence[#sha.sequence][1] or false
    local possible_rooms, to_send = {}, direction
    if direction == "l" then
        for i, v in ipairs(sha.sequence[#sha.sequence]) do
            possible_rooms[i] = v
        end
    elseif first_room and not (first_room == 'G' and direction == 'w') then
        if sha.rooms[first_room].exits[direction] then
            for _, r in ipairs(sha.sequence[#sha.sequence] or {}) do
                if sha.rooms[r].exits[direction] then
                    possible_rooms[sha.rooms[r].exits[direction]] = true
                end
            end
            possible_rooms = shades_to_list(possible_rooms)
        elseif sha.rooms[first_room].normalized[direction] then
            to_send = sha.rooms[first_room].normalized[direction]
            for _, r in ipairs(sha.sequence[#sha.sequence] or {}) do
                if sha.rooms[r].exits[to_send] then
                    possible_rooms[sha.rooms[r].exits[to_send]] = true
                end
            end
            possible_rooms = shades_to_list(possible_rooms)
        else
            for i, v in ipairs(sha.sequence[#sha.sequence]) do
                possible_rooms[i] = v
            end
        end
    end
    table.insert(sha.sequence, possible_rooms)
    table.insert(sha.commands, to_send)
    Send(to_send)
    shades_print_map()
end

function on_trigger_shades_you_follow(name, line, wildcards, styles)
    sha.commands.count = (sha.commands.count or 0) + 1 -- used in 'stop' handling
    local direction = tonumber(wildcards.direction)
    table.insert(sha.commands, 1, direction)
    shades_construct_seq()
    shades_print_map()
end

function on_alias_shades_stop(name, line, wildcards)
    sha.commands.count = 0
    Send("stop")
    shades_print_map()
end

function on_trigger_shades_remove_queue(name, line, wildcards, styles)
    while(sha.commands[sha.commands.count + 1] ~= nil) do
	   table.remove(sha.commands, sha.commands.count + 1)
    end
    while(sha.sequence[sha.commands.count + 2]) do
	   table.remove(sha.sequence, sha.commands.count + 2)
    end
    shades_print_map()
end

function on_trigger_shades_command_fail(name, line, wildcards, styles)
    table.remove(sha.commands, 1)
    shades_construct_seq()
    shades_print_map()
end

function shades_format_direction(long_direction)
    local direction = string.lower(long_direction)
    direction = direction:gsub("north", "n")
    direction = direction:gsub("east", "e")
    direction = direction:gsub("south", "s")
    direction = direction:gsub("west", "w")
    direction = direction:gsub("look", "l")
    return tonumber(direction) or direction
end
--------------------------------------------------------------------------------
--   SET AND LIST CONVERSION
--------------------------------------------------------------------------------
function shades_to_set(t1) local t2 = {}; for _, v in ipairs(t1) do t2[v] = true end; return t2 end

function shades_to_list(t1)
    local order = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q",}
    local t2 = {}
    for _, r in ipairs(order) do
        if t1[r] then
            table.insert(t2, r) 
        end
    end
    return t2 
end
--------------------------------------------------------------------------------
--   VERBOSE ROOM DESCRIPTION TRIGGER EVENT
--------------------------------------------------------------------------------
function on_trigger_shades_verbose(name, line, wildcards, styles)
    local s = name:match('%w+$')
    local room = {}
    for r in string.gmatch(s, '.') do
      table.insert(room, r)
    end
    shades_move_room(room)
end
--------------------------------------------------------------------------------
--   BRIEF ROOM DESCRIPTION TRIGGER EVENTS
--------------------------------------------------------------------------------
function on_trigger_shades_brief_entrance(name, line, wildcards, styles)
    local room = {"G"}
    shades_move_room(room)
end

function on_trigger_shades_brief(name, line, wildcards, styles)
    local r= {{}, {}, {}, {"A", "B", "F", "O", "P", "Q"}, {"C", "L"}, {"H"}, {"D", "E", "K", "M", "N"}, {"I", "J"},}
    local room = r[tonumber(wildcards.exits)]
    shades_move_room(room)
end
--------------------------------------------------------------------------------
--   START EXECUTION HERE
--------------------------------------------------------------------------------
on_plugin_start()

shades_print_map()

