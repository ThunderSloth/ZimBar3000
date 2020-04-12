--------------------------------------------------------------------------------
--   EXIT SOLVING
--------------------------------------------------------------------------------
-- apply changes to mapdata and minimap after our other functions have eliminated uncertainty through various means
function medina_solve_exit(start_room, direction, end_room)
    if start_room and direction and end_room then
        if med.rooms[start_room].exits and med.rooms[start_room].exit_rooms[end_room] then
            if med.rooms[start_room].exits[direction] then
                local normalized = med.rooms[start_room].exit_rooms[end_room]
                med.rooms[start_room].exits[direction].room = end_room
                med.rooms[start_room].normalized[normalized] = direction
            end
        end
        medina_solve_final_count_matches(start_room)
        medina_solve_final_exit(start_room)
        medina_draw_room(start_room, med.coordinates.rooms[start_room], med.colours, win.."base")
        medina_draw_room_exits(start_room, med.coordinates.rooms[start_room], med.colours, win.."base")
    end
end
-- for situations in which we have gathered all exit information from a specific set of adjacent exit-quantity rooms 
-- (i.e. all of the adjacent rooms that contain for example, 3 exits) and we solved all of these exits but one
function medina_solve_final_count_matches(room)
    local function get_count(t) local c = 0; for _, _2 in pairs(t) do c = c + 1 end return c end
    local function to_list(t1) t2 = {}; for k, v in pairs(t1) do if v then table.insert(t2, k) end end; return t2 end
    local function get_possible_rooms(room, exit_count)
        t = {}; for _, v in pairs(med.exit_counts[room].adj_room_exit_count[exit_count].rooms) do t[v] = true end; return {rooms = t, directions = {}}
    end
    if med.rooms[room].exits and not(med.rooms[room].solved) then
        local exit_set = {}
        for dir, v in pairs(med.rooms[room].exits) do
            if v.room then
                local exit_count = med.exit_counts[v.room].adj_room_count
                exit_set[exit_count] = exit_set[exit_count] or get_possible_rooms(room, exit_count)
                exit_set[exit_count].rooms[v.room] = false
            elseif v.exits then
                local exit_count = get_count(v.exits)
                exit_set[exit_count] = exit_set[exit_count] or get_possible_rooms(room, exit_count)
                table.insert(exit_set[exit_count].directions, dir)
            end
        end
        for exit_count, v in pairs(exit_set) do
            local rooms = to_list(v.rooms)
            local final_room = #rooms == 1 and rooms[1] or false
            local final_direction = #v.directions == 1 and v.directions[1] or false
            if final_room and final_direction then
                med.rooms[room].exits[final_direction].room = final_room
                med.rooms[room].normalized[med.rooms[room].exit_rooms[final_room]] = final_direction
            end
        end
    end
end
-- if all exits but one have been solved, use process of elimination to solve the last one
function medina_solve_final_exit(start_room)
    local count, final_exit = 0, ""
    if med.rooms[start_room].exits then
        for dir, v in pairs(med.rooms[start_room].exits) do
            if not(v.room) and not(start_room == "R" and dir == "se") and not(start_room == "A" and dir == "nw") then
                final_exit = dir
                count = count + 1
                if count > 1 then break end
            end
        end
        if count == 1 then
            local final_room = ""
            for end_room, dir in pairs(med.rooms[start_room].exit_rooms) do
                if not(med.rooms[start_room].normalized[dir]) then
                    med.rooms[start_room].normalized[dir] = final_exit
                    final_room = end_room
                    break
                end
            end
            med.rooms[start_room].exits[final_exit].room = final_room
            med.rooms[start_room].solved = os.time()
            -- set expiration timer
        elseif not(med.rooms[start_room].solved) and count == 0 then
            med.rooms[start_room].solved = os.time()
        end
    end
end
-- return possible room based off exit counts
function medina_get_room(start_room, end_exits) 
    local function to_list(t1) t2 = {}; for k, v in pairs(t1) do if v then table.insert(t2, k) end end; return t2 end
    local exit_count, possible_rooms = #end_exits, {}
    if exit_count == 6 then -- heart
        return {"I"}
    elseif exit_count == 5 then -- 5-exit room
        return {"E"}
    elseif start_room then 
        for _, r in ipairs(start_room) do
            if med.exit_counts[r].adj_room_exit_count[exit_count] then -- exit counts match
                for _2, room in pairs(med.exit_counts[r].adj_room_exit_count[exit_count].rooms) do
                    possible_rooms[room] = true
                end
            end
        end
        return to_list(possible_rooms)
    elseif exit_count == 4 then
        return {"A"}
    elseif exit_count == 2 then
        return {"R"}
    else
        return {}
    end
end
-- attempt to narrow based of exits
function medina_get_scry_room(room, exits)

end
-- attempt to narrow start and end rooms
-- if we find certainty we will log exits
-- if we find discrepensies we will reset
-- return start and end rooms
function medina_verify_room(possible_start, start_exits, direction, possible_end, presumed_end, end_exits)
    local function to_set(t1) local t2 = {}; for _, v in ipairs(t1) do t2[v] = true end; return t2 end
    local function to_list(t1) local t2 = {}; for k, _ in pairs(t1) do table.insert(t2, k) end; return t2 end
    start_room, end_room, presumed_end, possible_start = {}, {}, to_set(presumed_end), to_set(possible_start)
    
    for _, v in ipairs(possible_end) do
        if presumed_end[v] then
            table.insert(end_room, v) -- overlap between possible and presumed
        end
    end
    local exit_change = false
    if #end_room == 0 then
        end_room = possible_end
        exit_change = true  -- if no overlap, start exits have changed
    end
    for _, v in ipairs(end_room) do
        for k, _ in pairs(med.rooms[v].exit_rooms) do
            if possible_start[k] then
                start_room[k] = true -- narrow start based on overlap
            end
        end
    end
    start_room = to_list(start_room)
    if exit_change then -- reset start exits
        for _, room in ipairs(start_room) do
            medina_reset_room_exits(room)
            if start_exits then
                med.rooms[room].exits = {}
                for dir, _ in pairs(start_exits) do med.rooms[room].exits[dir] = {room = false, exits = false} end
            end
        end
    end
    local absolute_end = #end_room == 1 and end_room[1] or false
    local absolute_start = #start_room == 1 and start_room[1] or false
    if absolute_start and start_exits then
        if not(med.rooms[absolute_start].exits) then
            med.rooms[absolute_start].exits = {}
            for dir, _ in pairs(start_exits) do med.rooms[absolute_start].exits[dir] = {room = false, exits = false} end
        end
        if med.rooms[absolute_start].exits[direction] ~= nil and end_exits then
            med.rooms[absolute_start].exits[direction].exits = {}
            start_exits[direction] = {}
            -- logging adjacent-room exit-lists, this will come in handy when dealing with specific cases of uncertainty
            for dir, _ in pairs(end_exits) do
               start_exits[direction][dir] = true
               med.rooms[absolute_start].exits[direction].exits[dir] = true
            end
        end
        -- attempt to narrow uncertainty based on exit-lists
        if not(absolute_end) and med.rooms[absolute_start].exits and end_exits and direction then
            local function get_count(t) local c = 0; for _, _2 in pairs(t) do c = c + 1 end return c end
            local function get_set_info(room, exit_count)
                local t = {directions = {}, rooms = {}, threshold = 0,}
                if med.exit_counts[room] and med.exit_counts[room].adj_room_exit_count[exit_count] then
                    for _, r in ipairs(med.exit_counts[room].adj_room_exit_count[exit_count].rooms) do
                        t.rooms[r] = {}
                    end
                    t.threshold = med.exit_counts[room].adj_room_exit_count[exit_count].number_of_rooms
                end
               return t
            end
            local exit_sets = {}
            for dir, v in pairs(med.rooms[absolute_start].exits) do
                if v.exits then
                    local exit_count = get_count(v.exits)
                    exit_sets[exit_count] = exit_sets[exit_count] or get_set_info(absolute_start, exit_count)
                    if v.room then
                        exit_sets[exit_count].rooms[v.room] = nil
                    else
                        table.insert(exit_sets[exit_count].directions, dir)
                    end
                    exit_sets[exit_count].threshold = exit_sets[exit_count].threshold - 1
                    if exit_sets[exit_count].threshold == 0 then
                        for r, _ in pairs(exit_sets[exit_count].rooms) do
                            if med.rooms[r].exits then
                                local match = ""
                                for _2, d in ipairs(exit_sets[exit_count].directions) do
                                    match = d
                                    for dd, _3 in pairs(med.rooms[absolute_start].exits[d].exits) do
                                        if med.rooms[r].exits[dd] == nil then
                                            match = false; break
                                        end
                                    end
                                    if match then 
                                        table.insert(exit_sets[exit_count].rooms[r], match)
                                    end
                                end
                                if #exit_sets[exit_count].rooms[r] == 1 then
                                    medina_solve_exit(absolute_start, exit_sets[exit_count].rooms[r][1], r)
                                    if med.rooms[absolute_start].exits[direction].room then
                                        end_room = {}
                                        table.insert(end_room, med.rooms[absolute_start].exits[direction].room)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    absolute_end = #end_room == 1 and end_room[1] or false
    if absolute_end and end_exits then -- end room certainty
         if med.rooms[absolute_end].exits then -- if exits are already logged
            exit_change = false 
            for dir, _ in pairs(end_exits) do if not(med.rooms[absolute_end].exits[dir]) then exit_change = true; break end end
            if exit_change then -- if exits have changed, update them
                medina_reset_room_exits(absolute_end)
                med.rooms[absolute_end].exits = {}
                for dir, _ in pairs(end_exits) do med.rooms[absolute_end].exits[dir] = {room = false, exits = false} end
            end
        else
            med.rooms[absolute_end].exits = {}
            for dir, _ in pairs(end_exits) do med.rooms[absolute_end].exits[dir] = {room = false, exits = false} end -- log exits
        end
    end
    if absolute_start and absolute_end then
        medina_solve_exit(absolute_start, direction, absolute_end)
    end
    if absolute_end == "R" and not(med.rooms.R.solved) then
        medina_solve_final_exit("R") -- auto-solve "R"
        medina_draw_room("R", med.coordinates.rooms.R, med.colours, win.."base")
        medina_draw_room_exits("R", med.coordinates.rooms.R, med.colours, win.."base")
    end
    start_room.exits, end_room.exits = start_exits, end_exits
    return start_room, end_room
end
-- compile data relating to exit counts, this will be neccessary for cases of uncertainty from dark/brief
function medina_get_exit_counts(t)
    local function get_exit_count(room)
        local count = 0
        for _, _2 in pairs(t[room].exit_rooms) do count = count + 1 end
        if room == "A" or room == "R" then count = count + 1 end
        return count
    end
    local exit_counts = {}
    for room, v in pairs(t) do
        exit_counts[room] = {adj_room_exit_count = {}}
        local adj_room_count = 0
        for adj_room, _ in pairs(v.exit_rooms) do
            local n = get_exit_count(adj_room)
            exit_counts[room].adj_room_exit_count[n] = exit_counts[room].adj_room_exit_count[n] or {}
            exit_counts[room].adj_room_exit_count[n].number_of_rooms = (exit_counts[room].adj_room_exit_count[n].number_of_rooms and exit_counts[room].adj_room_exit_count[n].number_of_rooms + 1) or 1
            exit_counts[room].adj_room_exit_count[n].rooms = exit_counts[room].adj_room_exit_count[n].rooms or {}
            table.insert(exit_counts[room].adj_room_exit_count[n].rooms, adj_room)
            adj_room_count = adj_room_count + 1
        end
        if room == "A" or room == "R" then adj_room_count = adj_room_count + 1 end
        exit_counts[room].adj_room_count = adj_room_count
    end
    return exit_counts
end
