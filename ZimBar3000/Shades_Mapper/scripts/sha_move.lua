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
    shades_set_follow_delay(previous_room, sha.commands[0])
    sha.scry_room = false
    shades_reset_thyngs(room)
    shades_construct_seq()
    shades_print_map()
end

function shades_scry_room(room)
	sha.scry_room = room
	shades_reset_thyngs(room)
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

