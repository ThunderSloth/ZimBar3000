--------------------------------------------------------------------------------
--   TRIGGER EVENTS
--------------------------------------------------------------------------------
function on_trigger_medina_room_brief(name, line, wildcards, styles)
    local function get_brief_exits(str)
        local t = {}
        str = str..","
        for dir in str:gmatch("(.-),") do
            if dir:match("^[nsew][ew]?$") then
               table.insert(t, dir) 
            end
        end
        return t
    end
    local function list_to_set(t1) local t2 = {}; for _, v in ipairs(t1) do t2[v] = true end; return t2 end
    local exits = get_brief_exits(wildcards.exits)
    local room = medina_get_room(med.sequence[1], exits)
    medina_move_room(room, list_to_set(exits))
end

function on_trigger_medina_room(name, line, wildcards, styles)
    local exits = medina_exit_string_to_set(wildcards.exits)
    local certainty = name:match("medina_room_([A-R])$")
    local room = certainty and {certainty} or {"H", "N"}
    if wildcards.title ~= '' then
		medina_reset_thyngs(room)
        if wildcards.thyngs ~= '' then
            on_trigger_medina_mob_track("here", line, {thyngs = wildcards.thyngs}, styles, room)
        else
            medina_move_room(room, exits)
        end
    elseif wildcards.look ~= '' then
        local simulate_night = false -- for testing night mode
        if simulate_night then
            on_trigger_medina_dark_room(name, line, wildcards, styles)
        else
            if wildcards.thyngs ~= '' then
                --print('thyngs spotted in look room')
            else
                medina_look_room(room, exits)
            end
        end
    end
end

function on_trigger_medina_dark_room(name, line, wildcards, styles)
    local function list_to_set(t1) local t2 = {}; for _, v in ipairs(t1) do t2[v] = true end; return t2 end
    local current_room = med.sequence[1]
    if wildcards.title ~= '' then
        if wildcards.thyngs ~= '' then
            --print('thyngs spotted in dark room')
        else
            local exits  = medina_exit_string_to_list(wildcards.exits)
            local room = medina_get_room(current_room, exits)
            medina_move_room(room, list_to_set(exits))
        end
    elseif wildcards.look ~= '' then
        if wildcards.thyngs ~= '' then
            --print('thyngs spotted in look dark room')
        else
            local exits = medina_exit_string_to_list(wildcards.exits)
            local room = medina_get_room(current_room, exits)
            medina_look_room(room, list_to_set(exits))
        end
    end
end

function on_trigger_medina_too_dark(name, line, wildcards, styles)
    medina_print_map(medina_get_presumed_look(med.sequence[1], med.commands.look[1]))
    table.remove(med.commands.look, 1)
end

function on_trigger_medina_look_out_of_bounds(name, line, wildcards, styles)
    table.remove(med.commands.look, 1)
end

function on_trigger_medina_remove_queue(name, line, wildcards, styles)
    -- we can't just clear the tables entirely because commands may have been entered after 'stop'
    while(med.commands.look[med.commands.look.count + 1]) do
	   table.remove(med.commands.look, (med.commands.look.count + 1))
    end
    while(med.commands.move[med.commands.move.count + 1] ~= nil) do
	   table.remove(med.commands.move, (med.commands.move.count + 1))
    end
    while(med.sequence[med.commands.move.count + 2]) do
	   table.remove(med.sequence, (med.commands.move.count + 2))
    end
    medina_print_map()
end

function on_trigger_medina_command_fail(name, line, wildcards, styles)
    table.remove(med.commands.move, 1);table.remove(med.sequence, 2)
    medina_construct_seq()
    medina_print_map()
end

function on_trigger_medina_you_follow(name, line, wildcards, styles)
    med.commands.move.count = (med.commands.move.count or 0) + 1 -- used in 'stop' handling
    local direction = medina_format_direction(wildcards.direction)
    table.insert(med.commands.move, 1, direction)
    medina_construct_seq()
end

function on_trigger_medina_mob_track(name, line, wildcards, styles, room)
	local sign = name:match("exit") and -1 or 1
	medina_get_mobs(wildcards, sign, room)
end
