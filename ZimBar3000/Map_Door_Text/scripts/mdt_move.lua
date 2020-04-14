-------------------------------------------------------------------------------
--  MOVEMENT TRACKING
-------------------------------------------------------------------------------
function mdt_get_exit_room(start_id, exit)
	local end_id = false
	if start_id then
		qdb = sqlite3.open(quowmap_database)
		for t in qdb:nrows("SELECT connect_id FROM room_exits WHERE room_id = '"..start_id.."' AND exit = '"..exit.."'") do 
			end_id = t.connect_id or false 
		end
		qdb:close()		
	end
	return end_id
end
-- handle movement commands
function OnPluginSent(text)
    if text == "stop" then
        mdt.commands.move.count, mdt.commands.look.count = 0, 0
    else
        local directions = {n = "n", ne = "ne", e = "e", s = "s", se = "se", s = "s", sw = "sw", w = "w", nw = "nw", north = "n", northeast = "ne", east = "e", southeast = "se", south = "s", southwest = "sw", west = "w", northwest = "nw",}
        local dir = directions[text]
        if dir then
			mdt.commands.move.count = mdt.commands.move.count + 1
			table.insert(mdt.commands.move, dir)
            table.insert(mdt.sequence, mdt_get_exit_room(mdt.sequence[#mdt.sequence], dir) or mdt.sequence[#mdt.sequence])
            mdt_print_map()
            mdt_print_text()
        elseif text == "l" or text == "look" then
			mdt.commands.move.count = mdt.commands.move.count + 1
			table.insert(mdt.commands.move, "l")
			table.insert(mdt.sequence, mdt.sequence[#mdt.sequence])
        end
    end
end
-- we can't just clear the tables entirely because commands may have been entered after 'stop'
function on_trigger_mdt_remove_queue(name, line, wildcards, styles) 
    while(mdt.commands.move[mdt.commands.move.count + 1] ~= nil) do
	   table.remove(mdt.commands.move, (mdt.commands.move.count + 1))
    end
    while(mdt.sequence[mdt.commands.move.count + 2]) do
	   table.remove(mdt.sequence, (mdt.commands.move.count + 2))
    end
    mdt_print_map()
    mdt_print_text()
end
-- on attempting to move in a nonexistent direction
function on_trigger_mdt_command_fail(name, line, wildcards, styles)
    table.remove(mdt.commands.move, 1);table.remove(mdt.sequence, 2)
    mdt_construct_seq()
    mdt_print_map()
    mdt_print_text()
end
-- on following another player
function on_trigger_mdt_you_follow(name, line, wildcards, styles)
    mdt.commands.move.count = (mdt.commands.move.count or 0) + 1 -- used in 'stop' handling
    local directions = {n = "n", ne = "ne", e = "e", s = "s", se = "se", s = "s", sw = "sw", w = "w", nw = "nw", north = "n", northeast = "ne", east = "e", southeast = "se", south = "s", southwest = "sw", west = "w", northwest = "nw",}
    local dir = directions[wildcards.driection]
    table.insert(med.commands.move, 1, dir)
    medina_construct_seq()
    mdt_print_map()
    mdt_print_text()
end
-- on any event that distrupts our trajectory we must recalculate the sequence
function mdt_construct_seq()
	while(mdt.sequence[2]) do table.remove(mdt.sequence, 2) end
	for i, command in ipairs(mdt.commands.move) do
		if command == "l" then
			table.insert(mdt.sequence, mdt.sequence[#mdt.sequence])
		elseif command then
			table.insert(mdt.sequence, mdt_get_exit_room(mdt.sequence[#mdt.sequence], command) or mdt.sequence[#mdt.sequence])
		end
	end
end
