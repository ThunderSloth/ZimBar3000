--------------------------------------------------------------------------------
--   MOVEMENT HANDLING
--------------------------------------------------------------------------------
 -- handle movement commands
function OnPluginSent(text)
	if smu.is_in_smugs then
		if text == "stop" then
			smu.commands.count = 0
			smugs_print_map()
		else
			local directions = {n = "n", ne = "ne", e = "e", s = "s", se = "se", s = "s", sw = "sw", w = "w", nw = "nw", north = "n", northeast = "ne", east = "e", southeast = "se", south = "s", southwest = "sw", west = "w", northwest = "nw",}
			local dir = directions[text]
			if dir then
				smu.commands.count = (smu.commands.count or 0) + 1 -- used in 'stop' handling
				if smu.rooms[smu.sequence[#smu.sequence]] and smu.rooms[smu.sequence[#smu.sequence]].exits[dir] then
					table.insert(smu.sequence, smu.rooms[smu.sequence[#smu.sequence]].exits[dir])
				end
				table.insert(smu.commands, dir)
				smugs_print_map()
			elseif text == "l" or text == "look" then
				smu.commands.count = (smu.commands.count or 0) + 1
				table.insert(smu.commands, "l")
				table.insert(smu.sequence, smu.sequence[#smu.sequence])
				smugs_print_map()
			end
		end
    end
end
 
function smugs_move_room(room)
	if smu.commands[1] ~= "l" then 
        smu.commands[0] = smu.commands[1]
        smu.sequence[0] = smu.sequence[1]
    end
    table.remove(smu.commands, 1); table.remove(smu.sequence, 1)
    smu.sequence[1] = room
    if not(smu.rooms[room].visited) then
        smu.rooms[room].visited = true
        smugs_draw_room_letter(room, smu.coordinates.rooms[room], smu.colours)
    end
    smugs_set_follow_delay(smu.sequence[0], smu.commands[0])
    smugs_reset_thyngs(room)
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
