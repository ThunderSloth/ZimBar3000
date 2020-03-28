--[[ Zimbus's
  _________                             _____                                    ._.
 /   _____/ _____  __ __  ____  ______ /     \ _____  ______ ______   ___________| |
 \_____  \ /     \|  |  \/ ___\/  ___//  \ /  \\__  \ \____ \\____ \_/ __ \_  __ \ |
 /        \  Y Y  \  |  / /_/  >___ \/    Y    \/ __ \|  |_> >  |_> >  ___/|  | \/\|
/_______  /__|_|  /____/\___  /____  >____|__  (____  /   __/|   __/ \___  >__|   __
        \/      \/     /_____/     \/        \/     \/|__|   |__|        \/       \]]
--------------------------------------------------------------------------------
--   INSTALL AND SAVE
--------------------------------------------------------------------------------
function on_plugin_start()
    require "tprint"
    require "serialize"
    win = "smugs_map"..GetPluginID() -- define window name
    smugs_get_variables()
    smugs_get_windows()
    smugs_window_setup(window_width, window_height)
    smugs_get_hotspots(smu.dimensions)
    if (type(window_pos_x) == "number") and (type(window_pos_y) == "number") then
	   WindowPosition(win, window_pos_x, window_pos_y, 0, 2)
    end
end

function smugs_get_variables()
    defualt_window_width = 300
    defualt_window_height = 300
    window_width, window_height = tonumber(GetVariable("window_width") or defualt_window_width), tonumber(GetVariable("window_height") or defualt_window_height)
    window_pos_x, window_pos_y = tonumber(GetVariable("window_pos_x")), tonumber(GetVariable("window_pos_y"))
    smu = {
        id = {
            ["ebff897af2b8bb6800a9a8636143099d0714be07"] = "A",
            ["c0495c993b8ba463e6b3008a88f962ae28084582"] = "B",
            ["501c0b35601b8649c57bb98b8a1d6c2d1f1cea02"] = "C",
            ["8c022638ba642395094bc4dc7ba0a3aaf64c02c1"] = "D",
            ["898b33dcc8da01ef21b064f66062ea2f89235f5f"] = "E",
            ["0b43758d635f631d46b1a1f041fd651e446856ca"] = "F",  --    0 1 2 3 4 5 6 7 8 9 10
            ["1793722d05f49d48f28ce3a49e8b97d59158b916"] = "G",  --   ************************
            ["e28d07530ae163f93ade722c780ce897a4e93a15"] = "H",  -- 0 *                      *
            ["a184520b84e948f89e621ab50a500c47faefa920"] = "I",  --   *                      *
            ["8048df6be9b61c0f49e988924185ce937a38814b"] = "J",  -- 1 *          E-F         *
            ["f026140904d9f0c910b4975b937b20189f225605"] = "K",  --   *         /   \        *
            ["952786ea48134ac3505cbabb6567ef35fad13af8"] = "L",  -- 2 *      C-D     G-H     *
            ["b9bb8741399c7bdf6836cb06148c2e7c4f033853"] = "M",  --   * \   /   \   /   \    *
            ["0663269ccae61f6b313cb378213c74131b394fbc"] = "N",  -- 3 *  A-B     U-V     I   *
            ["03a3ca540e9c7fc9dfa914d213b974a0b207f596"] = "O",  --   *     \   /   \   /    *
            ["3fedc83188999bd20733ba77f02409aee8011127"] = "P",  -- 4 *      S-T  Z  W-J     *
            ["033906622a542f9e0550608b86932dff52d7e8c2"] = "Q",  --   *     /   \   /   \    *
            ["6ef15a8643f1515f8a96fb646dd8e2ab80bade15"] = "R",  -- 5 *    R     Y-X     K   *
            ["ddabfb40040805889125b223a2d679e0a9716fd2"] = "S",  --   *     \   /   \   /    *
            ["468f6243998bda671161e6afe079ff5fac866fc1"] = "T",  -- 6 *      Q-P     M-L     *
            ["372dd28add7bfc7ed26f4da4047a501afcf24696"] = "U",  --   *         \   /        *
            ["d57af869e7ff7abe31ceb1245ccbc6d47df49b7b"] = "V",  -- 7 *          O-N         *
            ["a9734849233e5f97fd676676a9853b22b0cb22e8"] = "W",  --   *                      *
            ["4e6aef2cd732fb35c2c110d768605f4aa56194af"] = "X",  -- 8 *                      *
            ["16a0b8c39025147f9f87cf860b76380af6c9e1d4"] = "Y",  --   ************************
			["886a1404021cdfb21668823aa0ab2cefd05fbcd1"] = "Z",},
        rooms = {                                                
            A = {location = {x = 1, y = 3,}, exits = {e  = "B", nw = "entrance"   ,},},
            B = {location = {x = 2, y = 3,}, exits = {ne = "C", se = "S", w  = "A",},},
            C = {location = {x = 3, y = 2,}, exits = {e  = "D", sw = "B"          ,},},
            D = {location = {x = 4, y = 2,}, exits = {ne = "E", se = "U", w  = "C",},},
            E = {location = {x = 5, y = 1,}, exits = {e  = "F", sw = "D"          ,},},
            F = {location = {x = 6, y = 1,}, exits = {se = "G", w  = "E"          ,},},
            G = {location = {x = 7, y = 2,}, exits = {e  = "H", sw = "V", nw = "F",},},
            H = {location = {x = 8, y = 2,}, exits = {se = "I", w  = "G"          ,},},
            I = {location = {x = 9, y = 3,}, exits = {sw = "J", nw = "H"          ,},},
            J = {location = {x = 8, y = 4,}, exits = {ne = "I", se = "K", w  = "W",},},
            K = {location = {x = 9, y = 5,}, exits = {sw = "L", nw = "J"          ,},},
            L = {location = {x = 8, y = 6,}, exits = {ne = "K", w  = "M"          ,},},
            M = {location = {x = 7, y = 6,}, exits = {e  = "L", sw = "N", nw = "X",},},
            N = {location = {x = 6, y = 7,}, exits = {ne = "M", w  = "O"          ,},},
            O = {location = {x = 5, y = 7,}, exits = {e  = "N", nw = "P"          ,},},
            P = {location = {x = 4, y = 6,}, exits = {ne = "Y", se = "O", w  = "Q",},},
            Q = {location = {x = 3, y = 6,}, exits = {e  = "P", nw = "R"          ,},},
            R = {location = {x = 2, y = 5,}, exits = {se = "Q", ne = "S"          ,},},
            S = {location = {x = 3, y = 4,}, exits = {e  = "T", sw = "R", nw = "B",},},
            T = {location = {x = 4, y = 4,}, exits = {ne = "U", se = "Y", w  = "S",},},
            U = {location = {x = 5, y = 3,}, exits = {e  = "V", sw = "T", nw = "D",},},
            V = {location = {x = 6, y = 3,}, exits = {ne = "G", se = "W", w  = "U",},},
            W = {location = {x = 7, y = 4,}, exits = {e  = "J", sw = "X", nw = "V",},},
            X = {location = {x = 6, y = 5,}, exits = {ne = "W", se = "M", w  = "Y",},},
            Y = {location = {x = 5, y = 5,}, exits = {e  = "X", sw = "P", nw = "T",},},
            Z = {location = {x =5.5,y = 4,}, exits = {                             },},
            entrance = {location = {x=-100, y=-100}, exits = {se = "A"},},
            },
        chambers = {I = true, T = true, N = true,},
        colours = smugs_get_colours(),
        commands = {count = 0},
        sequence = {},
        is_in_smugs = false,
    }
    for k, v in pairs(smu.rooms) do -- create inverse set of exits
        smu.rooms[k].path = smu.rooms[k].path or {}
        for r, x in pairs(v.exits) do
            smu.rooms[k].path[x] = r
        end
    end
end

function smugs_get_colours()

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
            chambers =   "red",
            exits =      "lightgray",
            entrance =   "white",
            visited =    "gray",
            unvisited =  "lightblue",},
        thyngs = {
            you =        "yellow",
            ghost =      "yellow",
            players =    "blue",
            captain =    "fuchsia",
            smugglers =  "white",
            others =     "gray",
            xp = {"#003300", "#004c00", "#006600", "#007f00", "#009900", "#00b200", "#00cc00", "#00e500", "#00ff00",},},
        note = {
            bracket =    "white",
            error =      "red",
            text =       "gray",},}

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
function smugs_get_windows(dim) -- dimensions
    local col = smu.colours.window
    WindowCreate(win.."copy_from", 0, 0, 0, 0, miniwin.pos_center_all, 0, col.transparent) -- for loading images
    WindowCreate(win.."base", 0, 0, 0, 0, miniwin.pos_center_all, 0, col.transparent) -- base: room structure, static objects
    WindowCreate(win, 0, 0, 0, 0, miniwin.pos_center_all, 0, col.background) -- display window: only dynamic objects will be printed directly here
    WindowCreate(win.."overlay", 0, 0, 0, 0, miniwin.pos_center_all, 0, col.transparent) --overlay: room-letters
    WindowSetZOrder(win, 200)
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

function smugs_get_hotspots(dim) -- dimensions
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
    for r, v in pairs(smu.rooms) do
        local coor = smu.coordinates.rooms[r].room.outter
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
        WindowResize(win, window_width, window_height, smu.colours.window.background)
        WindowDrawImage(win, "win", 0, 0, window_width, window_height, 2)
        WindowShow(win)
        last_refresh = utils.timer()
   end
end

-- called after the resize widget is released
function ResizeReleaseCallback()
    smugs_window_setup(window_width, window_height)
    smugs_get_hotspots(smu.dimensions)
    smugs_print_map()
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
        smugs_get_shortest_path(smu.rooms, smu.sequence[#smu.sequence], id)
    end
end
--------------------------------------------------------------------------------
--   SHORTEST PATH
--------------------------------------------------------------------------------
function smugs_get_shortest_path(graph, start_node, end_node) -- BFS
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
            for k, v in pairs(g[current].exits) do
                if not(visited[v]) then
                    visited[v] = true
                    table.insert(queue, v)
                    g[v].parent = current
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
                local direction = smu.rooms[current].path[v]
                on_alias_smugs_move_room('name', 'line', {direction = direction})
                current = v
            end
        else
            ColourNote("white", "black", "<", "red", "black", "No path found!", "white", "black", ">")
        end
    end
    return solved
end
--------------------------------------------------------------------------------
--   GRAPHICAL FUNCTIONS
--------------------------------------------------------------------------------
function smugs_draw_room(room, coor, col, mw) -- room, coordinates, colours, miniwindow
    if room ~= 'entrance' then
        local chamber = smu.chambers[room]
        if chamber then
            WindowCircleOp(mw, 2, -- draw room
                coor.room.outter.x1, coor.room.outter.y1, coor.room.outter.x2, coor.room.outter.y2,            
                col.window.background, 0, 1,
                col.rooms.chambers, miniwin.brush_fine_pattern)
        end
        WindowRectOp(mw, 1, coor.room.outter.x1, coor.room.outter.y1, coor.room.outter.x2, coor.room.outter.y2, col.rooms.border)
    end
end

function smugs_draw_room_exits(room, coor, col, mw) -- room, coordinates, colours, miniwindow
    if room ~= 'entrance' then
        for dir, v in pairs(smu.rooms[room].exits) do
            local line_style =  v == 'entrance' and miniwin.pen_dot    or miniwin.pen_solid
            local line_colour = v == 'entrance' and col.rooms.entrance or col.rooms.exits
            WindowLine(
                mw, 
                coor.exit[dir].x1, coor.exit[dir].y1, coor.exit[dir].x2, coor.exit[dir].y2,  
                line_colour, line_style, 1)
        end
    end
end

function smugs_draw_base(dim, col) -- dimensions, colours
    local coordinates = smu.coordinates
    WindowCircleOp( -- window border
        win.."base", miniwin.circle_rectangle, 
        0, 0, dim.window.x, dim.window.y,
        col.window.border, miniwin.pen_solid, 1,
        col.window.background, 0) 
    WindowCircleOp( -- title bar
        win.."base", miniwin.circle_rectangle, 
        0, 0, dim.window.x, dim.font.title * 1.1,
        col.title.border, miniwin.pen_solid, 1,
        col.title.fill, 0)
    local title = "Smugs Cave"
    local text_width = WindowTextWidth(win.."base", "title", title)
    local x1 = (dim.window.x - text_width) / 2
    local y1 = coordinates.title_text.y1 
    local x2 = x1 + text_width
    local y2 = y1 + dim.font.title
    WindowText(win.."base", "title", title, x1, y1, x2, y2, col.title.text)
    for room, coor in pairs(coordinates.rooms) do
        smugs_draw_room_exits(room, coor, col, win.."base") -- draw exits
        smugs_draw_room(room, coor, col, win.."base") -- draw room
    end
end

function smugs_draw_room_letter(room, coor, col) -- room, coordinates, colours
    if room ~= 'entrance' then
        local letter_colour = smu.rooms[room].visited and col.rooms.visited or col.rooms.unvisited
        WindowText (win.."overlay", "larger", room,
            coor.letter.x1, coor.letter.y1, 0, 0,
            letter_colour, 
            false)
    end
end

function smugs_draw_overlay(dim, col) -- dimensions, colours
    WindowCircleOp( -- transparent background
        win.."overlay", miniwin.circle_rectangle, 
        0, 0, dim.window.x, dim.window.y,
        col.window.transparent, miniwin.pen_solid, 1,
        col.window.transparent, 0)
    local coordinates = smu.coordinates
    for room, coor in pairs(coordinates.rooms) do
        smugs_draw_room_letter(room, coor, col)
    end
end

function smugs_print_map()
    local start_time = os.clock()
    local function draw_dynamic(coordinates, col, current_room)
        local function draw_thyng(room, coor, colour) -- room, coordinates
            if room then
                WindowCircleOp(win, 2,
                    coor.room.inner.x1, coor.room.inner.y1, coor.room.inner.x2, coor.room.inner.y2,            
                    colour, 0, 0,
                    colour, 0)
            end
        end
        local function draw_border(room, coor, colour)
            if room then
                WindowRectOp(win, miniwin.rect_frame, 
                    coor.room.outter.x1, coor.room.outter.y1, coor.room.outter.x2, coor.room.outter.y2,
                    colour)
            end
        end
        local trajectory_room = smu.sequence[#smu.sequence]
        draw_border(trajectory_room, coordinates.rooms[trajectory_room], col.thyngs.ghost)
        draw_thyng(current_room, coordinates.rooms[current_room], col.thyngs.you)
    end
    local current_room = smu.sequence[1] or false
    WindowImageFromWindow(win, "base", win.."base")
    WindowDrawImage(win, "base", 0, 0, 0, 0, 1) -- copy base
    draw_dynamic(smu.coordinates, smu.colours, current_room) -- add dynamic
    WindowImageFromWindow(win, "overlay", win.."overlay")
    WindowDrawImage(win, "overlay", 0, 0, 0, 0, 3) -- copy overlay
    WindowShow(win, true)
    --print(os.clock() - start_time) -- speed test
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
        smugs_recieve_GMCP(data_line)
    end
end

function smugs_recieve_GMCP(text)
    if text:match("^room.info .*") then
        local id = text:match('^.*"identifier":"(.-)".*$')
        local room = smu.id[id]
        if room then
            smugs_enter()
            smugs_move_room(room)
        else
            smugs_exit()
            WindowShow(win, false)
        end
    end
end
--------------------------------------------------------------------------------
--  ENTER AND EXIT HANDLING
--------------------------------------------------------------------------------
function smugs_enter()
    if not(smu.is_in_smugs) then
        smu.is_in_smugs = true
        smu.commands, smu.sequence = {count = 0}, {}
        EnableGroup("smugs", true)
        DeleteTimer("smugs_unvisit")
    end
end

function smugs_exit()
    if smu.is_in_smugs then
        smu.is_in_smugs = false
        smu.commands, smu.sequence = {count = 0}, {}
        EnableGroup("smugs", false)
        AddTimer("smugs_unvisit", 0, 3, 0, "", timer_flag.Enabled + timer_flag.Replace + timer_flag.Temporary + timer_flag.OneShot, "smugs_unvisit")
    end
end

function smugs_unvisit()
    for r, _ in pairs(smu.rooms) do
        smu.rooms[r].visited = false
        smugs_draw_room_letter(r, smu.coordinates.rooms[r], smu.colours)
    end
end
--------------------------------------------------------------------------------
--   MOVEMENT HANDLING
--------------------------------------------------------------------------------
function smugs_move_room(room)
    table.remove(smu.commands, 1); table.remove(smu.sequence, 1)
    smu.sequence[1] = room
    if not(smu.rooms[room].visited) then
        smu.rooms[room].visited = true
        smugs_draw_room_letter(room, smu.coordinates.rooms[room], smu.colours)
    end
    smugs_print_map()
end

function on_alias_smugs_move_room(name, line, wildcards)
    smu.commands.count = (smu.commands.count or 0) + 1 -- used in 'stop' handling
    local direction = smugs_format_direction(wildcards.direction)
    if smu.rooms[smu.sequence[#smu.sequence]] and smu.rooms[smu.sequence[#smu.sequence]].exits[direction] then
        table.insert(smu.sequence, smu.rooms[smu.sequence[#smu.sequence]].exits[direction])
    end
    table.insert(smu.commands, direction)
    Send(direction)
    smugs_print_map()
end

function on_alias_smugs_stop(name, line, wildcards)
    smu.commands.count = 0
    Send("stop")
    smugs_print_map()
end

function on_trigger_smugs_remove_queue()
    while(smu.commands[smu.commands.count + 1] ~= nil) do
	   table.remove(smu.commands, smu.commands.count + 1)
    end
    while(smu.sequence[smu.commands.count + 2]) do
	   table.remove(smu.sequence, smu.commands.count + 2)
    end
    smugs_print_map()
end

function on_trigger_smugs_you_follow(name, line, wildcards, styles)
    smu.commands.count = (smu.commands.count or 0) + 1 -- used in 'stop' handling
    local direction = smugs_format_direction(wildcards.direction)
    while(smu.sequence[2]) do
	   table.remove(smu.sequence, 2)
    end
    table.insert(smu.commands, 1, direction)
    for _, v in ipairs(smu.commands) do
        if smu.rooms[smu.sequence[#smu.sequence]] and smu.rooms[smu.sequence[#smu.sequence]].exits[direction] then
            table.insert(smu.sequence, smu.rooms[smu.sequence[#smu.sequence]].exits[direction])
        end
    end
    smugs_print_map()
end

function smugs_format_direction(long_direction)
    local direction = string.lower(long_direction)
	direction = direction:gsub("north", "n")
	direction = direction:gsub("east", "e")
	direction = direction:gsub("south", "s")
	direction = direction:gsub("west", "w")
	direction = direction:gsub("look", "l")
    return direction
end
--------------------------------------------------------------------------------
--   START EXECUTION HERE
--------------------------------------------------------------------------------
on_plugin_start()

smugs_print_map()
