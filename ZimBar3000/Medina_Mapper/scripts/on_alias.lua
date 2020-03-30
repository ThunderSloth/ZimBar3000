--------------------------------------------------------------------------------
--   ALIAS EVENTS
--------------------------------------------------------------------------------
-- on entering movement direction
function on_alias_medina_move_room(name, line, wildcards)
    local function to_list(t1) t2 = {}; for k, v in pairs(t1) do if v then table.insert(t2, k) end end; return t2 end
    med.commands.move.count = (med.commands.move.count or 0) + 1 -- used in 'stop' handling
    local direction = medina_format_direction(wildcards.direction) 
    local to_send, possible_rooms = direction, {}
    local trajectory_room = #med.sequence[#med.sequence] == 1 and med.sequence[#med.sequence][1] or false
    if direction:match("l") then
        for _, v in ipairs(med.sequence[#med.sequence]) do
		  possible_rooms[v] = true
        end
    elseif med.rooms[trajectory_room] and med.rooms[trajectory_room].normalized[direction] then
        to_send = med.rooms[trajectory_room].normalized[direction] -- normalize
        possible_rooms = {}
        if med.rooms[trajectory_room].exits and med.rooms[trajectory_room].exits[to_send] 
        and med.rooms[trajectory_room].exits[to_send].room then
            possible_rooms[med.rooms[trajectory_room].exits[to_send].room] = true
        end
    else
        possible_rooms = medina_get_seq(med.sequence[#med.sequence], direction)
    end
    table.insert(med.sequence, to_list(possible_rooms))
    table.insert(med.commands.move, to_send)
    Send(to_send)
    medina_print_map()
end
-- on entering looking in a direction
function on_alias_medina_look_room(name, line, wildcards)
    med.commands.look.count = (med.commands.look.count or 0) + 1
    local direction = medina_format_direction(wildcards.direction)
	local trajectory_room, to_send = #med.sequence[#med.sequence] == 1 and med.sequence[#med.sequence][1] or false, "l "
	if trajectory_room and med.rooms[trajectory_room].solved and med.rooms[trajectory_room].normalized[direction]then 
        -- unlike movement, look-directions only normalize after all exits in a room are solved
        -- otherwise you could get stuck
        to_send = to_send..med.rooms[trajectory_room].normalized[direction] -- normalized
        table.insert(med.commands.look, med.rooms[trajectory_room].normalized[direction])
	else
		to_send = to_send..direction --unaltered
		table.insert(med.commands.look, direction)
	end
    Send(to_send)
    medina_debug_movement()
end
-- on entering stop
function on_alias_medina_stop(name, line, wildcards)
    med.commands.move.count, med.commands.look.count = 0, 0
    Send("stop")
end
-- display internal variables for debugging
function on_alias_medina_table(name, line, wildcards) -- 'medt'
    local room = wildcards.room:upper()
    if room:match("^[A-R]$") then
        print("med.rooms:",room..":");tprint(med.rooms[room])
    else
        print("med.players");tprint(med.players)
        print("med.rooms");tprint(med.rooms)
        print("med.commands.move");tprint(med.commands.move)
        print("med.sequence");tprint(med.sequence)
        print("med.commands.look");tprint(med.commands.look)
    end
end
-- reset map or a specific room
function on_alias_medina_reset(name, line, wildcards) -- 'medr'
    local current_room, is_reset_room, reset_room = med.sequence[1] and #med.sequence[1] == 1 and med.sequence[1][1] or false, wildcards.is_reset_room, wildcards.room:upper()
    if reset_room:match("^[A-R]$") then -- room specified
        medina_reset_room(reset_room); medina_print_map()
        if current_room and current_room == reset_room then Send("l") end -- gather exits
    elseif is_reset_room ~= "" then
        if current_room then medina_reset_room(current_room); medina_print_map(); Send("l") end -- 'room' with no argument
    else
        medina_reset_rooms(); medina_print_map() -- no arguments: reset everything
        if med.is_in_medina then Send("l") end
    end
end
-- show map window
function on_alias_medina_window_open(name, line, wildcards) medina_print_map() end -- 'medwo'
-- close map window (this does not disable the plugin, the window will appear again if you are in the medina)
function on_alias_medina_window_exit(name, line, wildcards) WindowShow(win, false) end -- 'medwx'
-- reposition window to center of screen
function on_alias_medina_window_center(name, line, wildcards) WindowPosition(win, 0, 0, miniwin.pos_center_all, 0); medina_print_map() end -- 'medwc'
