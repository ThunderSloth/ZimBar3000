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

