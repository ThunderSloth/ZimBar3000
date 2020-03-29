--------------------------------------------------------------------------------
--   GRAPHICAL FUNCTIONS
--------------------------------------------------------------------------------
function medina_draw_room(room, coor, col, mw) -- room, coordinates, colours, miniwindow
    local border_colour = med.rooms[room].solved and col.rooms.solved or col.rooms.unsolved
    WindowCircleOp(mw, 2, -- draw room
	    coor.room.outter.x1, coor.room.outter.y1, coor.room.outter.x2, coor.room.outter.y2,            
	    border_colour, 0, 1,
	    col.window.background, miniwin.brush_null)
end

function medina_draw_room_exits(room, coor, col, mw) --room, coordinates, colours, miniwindow
    for norm, dir in pairs(med.rooms[room].normalized) do
        local border_colour = dir and col.exits.solved or col.exits.unsolved
        WindowCircleOp(mw, 2, -- draw exit
            coor.exit[norm].x1, coor.exit[norm].y1, coor.exit[norm].x2, coor.exit[norm].y2,            
            border_colour, 0, 1,
            col.window.background, miniwin.brush_solid)
        if dir then WindowDrawImage(mw, dir, coor.exit[norm].x1 + 2, coor.exit[norm].y1 + 2, 0, 0, 1) end --if solved draw arrow
    end
end

function medina_draw_base(dim, col) -- dimensions, colours
    local coordinates = med.coordinates
    WindowCircleOp( -- window border
        win.."base", miniwin.circle_rectangle, 
        0, 0, dim.window.x, dim.window.y,
        col.window.border, miniwin.pen_solid, 1,
        col.window.background, 0) 
    WindowLine( -- nw exit
        win.."base", 
        0, dim.block.y / 2, dim.buffer.x, dim.buffer.y + (dim.block.y / 2), 
        col.exits.static, miniwin.pen_dot, 1)
    WindowLine( -- se exit
        win.."base", 
        (dim.block.x * 6) + dim.buffer.x, (dim.block.y * 5.5) + dim.buffer.y, dim.window.x, dim.window.y - (dim.block.y / 2), 
        col.exits.static, miniwin.pen_dot, 1)
    WindowCircleOp( -- title bar
        win.."base", miniwin.circle_rectangle, 
        0, 0, dim.window.x, dim.font.title * 1.1,
        col.title.border, miniwin.pen_solid, 1,
        col.title.fill, 0)
    local title = "Medina"
    local text_width = WindowTextWidth(win.."base", "title", title)
    local x1 = (dim.window.x - text_width) / 2
    local y1 = coordinates.title_text.y1 
    local x2 = x1 + text_width
    local y2 = y1 + dim.font.title
    WindowText(win.."base", "title", title, x1, y1, x2, y2, col.title.text)
    for room, coor in pairs(coordinates.rooms) do
        medina_draw_room(room, coor, col, win.."base") -- draw room
        medina_draw_room_exits(room, coor, col, win.."base") -- draw exits
    end
end

function medina_draw_room_letter(room, coor, col) -- room, coordinates, colours
    local letter_colour = med.rooms[room].visited and col.rooms.visited or col.rooms.unvisited
    WindowText (win.."overlay", "larger", room,
        coor.letter.x1, coor.letter.y1, 0, 0,
        letter_colour, 
        false)
end

function medina_draw_overlay(dim, col) -- dimensions, colours
    WindowCircleOp( -- transparent background
        win.."overlay", miniwin.circle_rectangle, 
        0, 0, dim.window.x, dim.window.y,
        col.window.transparent, miniwin.pen_solid, 1,
        col.window.transparent, 0)
    local coordinates = med.coordinates
    for room, coor in pairs(coordinates.rooms) do
        medina_draw_room_letter(room, coor, col)
    end
end

function medina_print_map(look_room)
    local start_time = os.clock()
    local function draw_exit_text(coor, dim, current_room)
        local function get_exit_text_info(unsolved_exits, exit_col, absolute_current)
            local function get_exit_colour(dir, exit_col, absolute_current)
                if absolute_current then
                    if med.rooms[absolute_current].exits and med.rooms[absolute_current].exits[dir] and med.rooms[absolute_current].exits[dir].exits then
                        return exit_col.halfsolved
                    else
                        return exit_col.unsolved
                    end
                else
                    return exit_col.unsolved
                end
            end
            local exit_text, for_text_length, comma = {}, "[", false
            for _, v in ipairs(unsolved_exits) do
                if comma then
                    table.insert(exit_text, {colour = exit_col.comma, text = ", "})
                    for_text_length = for_text_length..", "
                else
                    table.insert(exit_text, {colour = exit_col.bracket, text = "["})
                end
                table.insert(exit_text, {colour = get_exit_colour(v, exit_col, absolute_current), text = v})
                for_text_length = for_text_length..v
                comma = true
            end
            for_text_length = for_text_length.."]"
            table.insert(exit_text, {colour = exit_col.bracket, text = "]"})
            return WindowTextWidth(win, "larger", for_text_length), exit_text
        end
        local directions = {n = true, ne = true, e = true, se = true, s = true, sw = true, w = true, nw = true}
        for dir, _ in pairs(directions) do WindowDeleteHotspot(win, dir) end
        local unsolved_exits = {}
        local absolute_current = #current_room == 1 and current_room[1] or false
        if absolute_current and med.rooms[absolute_current].exits then
            for dir, solved in medina_order_exits(med.rooms[current_room[1]].exits) do
                if not(absolute_current == "A" and dir == "nw") and not(absolute_current == "R" and dir == "se") and not(solved.room) then table.insert(unsolved_exits, dir) end
            end
        elseif current_room.exits then
            for dir, _ in medina_order_exits(current_room.exits) do
                table.insert(unsolved_exits, dir)
            end
        end
        if #unsolved_exits > 0 then
            local text_width, exit_text = get_exit_text_info(unsolved_exits, med.colours.exits, absolute_current)
            local x1 = (dim.window.x - text_width) / 2
            local y1 = coor.y1
            local y2 = y1 + dim.font.larger
            for _, v in ipairs(exit_text) do
                local x2 = x1 + WindowTextWidth(win, "larger", v.text)
                if directions[v.text] then
                     WindowAddHotspot(win, v.text,  
                        x1, y1, x2, y2,
                        "mouseover", 
                        "cancelmouseover", 
                        "mousedown",
                        "cancelmousedown", 
                        "mouseup", 
                        "Look "..v.text,
                        miniwin.cursor_hand, 0)
                end
                x1 = x1 + WindowText(win, "larger", v.text, x1, y1, x2, y2, v.colour)
            end
        end
    end
    local function draw_dynamic(coordinates, col, current_room, look_room)
        local function draw_thyng(room, coor, colour) -- room, coordinates, colours
            local fill_style = #room == 1 and 0 or 8
            for _ , r in ipairs(room) do
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
        local trajectory_room = #med.sequence ~= 0 and med.sequence[#med.sequence] or {}
        draw_border(trajectory_room, coordinates.rooms, col.rooms.ghost)
        draw_thyng(look_room, coordinates.rooms, col.rooms.look)
        draw_thyng(current_room, coordinates.rooms, col.thyngs.you)
    end
    local current_room, look_room = med.sequence[1] or {}, look_room or {}
    WindowImageFromWindow(win, "base", win.."base")
    WindowDrawImage(win, "base", 0, 0, 0, 0, 1) -- copy base
    draw_dynamic(med.coordinates, med.colours, current_room, look_room) -- add dynamic
    draw_exit_text(med.coordinates.exit_text, med.dimensions, current_room)
    WindowImageFromWindow(win, "overlay", win.."overlay")
    WindowDrawImage(win, "overlay", 0, 0, 0, 0, 3) -- copy overlay
    WindowShow(win, true)
    --print(os.clock() - start_time) -- speed test
end
