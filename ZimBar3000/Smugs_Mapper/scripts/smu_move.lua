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
