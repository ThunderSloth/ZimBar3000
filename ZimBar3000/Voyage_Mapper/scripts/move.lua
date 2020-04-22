--------------------------------------------------------------------------------
--   MOVEMENT TRACKING
--------------------------------------------------------------------------------
function voyage_move_room(current_room)
    if current_room ~= voy.sequence[1] then
        voy.lightning = false -- only remove lightning highlight when you move rooms or change stages
    end
    table.remove(voy.commands.move, 1); table.remove(voy.sequence, 1)
    if voy.sequence[0] ~= voy.sequence[1] then
        voy.sequence[0] = voy.sequence[1]
    end
    local previous_room = voy.sequence[0]
    if current_room == 21 and tonumber(previous_room) and previous_room < 21 then
        for k, _ in pairs(voy.rooms[21].board) do
            voy.rooms[21].board[k] = previous_room -- you always board onto wherever you overboarded from
        end
    end
    voy.sequence[1] = current_room
    voyage_print_map()
end

function voyage_construct_seq()
    while(voy.sequence[2]) do
	   table.remove(voy.sequence, 2)
    end
    local exit_types = {"exits", "doors", "up", "down", "board", "overboard", "look",}
    for _, command in ipairs(voy.commands.move) do
        for _2, v in ipairs(exit_types) do
            local trajectory_room = voy.sequence[#voy.sequence]
            if voy.rooms[trajectory_room][v] and voy.rooms[trajectory_room][v][command] then
                    table.insert(voy.sequence, voy.rooms[trajectory_room][v][command] )              
                break
            end
        end
    end
end

function on_alias_voyage_stop(name, line, wildcards)
    voy.commands.move.count, voy.commands.look.count = 0, 0
    Send("stop")
    voyage_print_map()
end

function on_trigger_voyage_remove_queue()
    while(voy.commands.move[voy.commands.move.count + 1] ~= nil) do
	   table.remove(voy.commands.move, voy.commands.move.count + 1)
    end
    while(voy.commands.look[voy.commands.look.count + 1]) do
	   table.remove(voy.commands.look, (voy.commands.look.count + 1))
    end
    while(voy.sequence[voy.commands.move.count + 2]) do
	   table.remove(voy.sequence, voy.commands.move.count + 2)
    end
    voyage_print_map()
end

function on_trigger_voyage_you_follow(name, line, wildcards, styles)
    voy.commands.move.count = (voy.commands.move.count or 0) + 1 -- used in 'stop' handling
    local direction = voyage_format_direction(wildcards)
    table.insert(voy.commands.move, 1, direction)
    voyage_construct_seq()
    voyage_print_map()
end

function on_trigger_voyage_you_skid(name, line, wildcards, styles)
    local direction = voyage_format_direction(wildcards)
    voy.commands.move[1] = direction
    voyage_construct_seq()
    voyage_print_map()
end

function on_trigger_voyage_command_fail(name, line, wildcards, styles)
    table.remove(voy.commands.move, 1)
    voyage_construct_seq()
    voyage_print_map()
end

function on_trigger_voyage_look_fail(name, line, wildcards, styles)
    table.remove(voy.commands.look, 1)
    voyage_print_map()
end

function on_trigger_voyage_drag_fail(name, line, wildcards, styles)
    if wildcards.object == voy.drag.object then
        local col = voy.colours.notes
        ColourNote(col.text, col.background, 'Drag: off')
        voy.drag.on = false
        table.remove(voy.commands.move, 1)
        voyage_construct_seq()
        voyage_print_map()
    end
end

function voyage_format_direction(direction)
    local function format_cardinal(cardinal)
        local cardinal = string.lower(cardinal)
        cardinal = cardinal:gsub("north", "n")
        cardinal = cardinal:gsub("east", "e")
        cardinal = cardinal:gsub("south", "s")
        cardinal = cardinal:gsub("west", "w")
        return cardinal
    end
    local function format_nautical(nautical)
        local nautical = string.lower(nautical)
        local cardinal = ""
        if nautical:match("fore") then
            cardinal = "n"
        elseif nautical:match("aft") then
            cardinal = "s"
        end
        if nautical:match("starboard") then
            cardinal = cardinal.."e"
        elseif nautical:match("port") then
            cardinal = cardinal.."w"
        end
        return cardinal
    end
    local function format_command(command)
        local command = string.lower(command)
        command = command:gsub("^u$", "up")
        command = command:gsub("^d$", "down")
        command = command:gsub("^o$", "overboard")
        command = command:gsub("^b$", "board")
        command = command:gsub("^l$", "look")
        return command
    end
    if direction.cardinal and direction.cardinal ~= "" then
        return format_cardinal(direction.cardinal)
    elseif direction.nautical and direction.nautical ~= "" then
        return format_nautical(direction.nautical)
    else
        return format_command(direction.command)
    end
end
--------------------------------------------------------------------------------
--   COMMAND NORMALIZATION
--------------------------------------------------------------------------------
function on_alias_voyage_move_room(name, line, wildcards)
    voy.commands.move.count = (voy.commands.move.count or 0) + 1 -- used in 'stop' handling
    local trajectory_room, command = voyage_normalize_direction(voyage_format_direction(wildcards))
    local previous_room = voy.sequence[0]
    table.insert(voy.sequence, trajectory_room)
    table.insert(voy.commands.move, command)
    if trajectory_room == 21 and tonumber(previous_room) and previous_room < 21 then
        for k, _ in pairs(voy.rooms[21].board) do
            voy.rooms[21].board[k] = previous_room -- you always board onto wherever you overboarded from
        end
    end
    if voy.drag.on then
        Send("drag "..voy.drag.object.." "..command)
    else
        Send(command)
    end
    voyage_print_map()
end

function voyage_normalize_direction(command)
    local directions = {n = "fore", ne = "starboard fore", e = "starboard", se = "starboard aft", s = "aft", sw = "port aft", w = "port", nw = "port fore",}
    local exit_types = {"exits", "doors", "up", "down", "board", "overboard", "look",}
    local trajectory_room = voy.sequence[#voy.sequence]
    local end_room = trajectory_room
    for _, v in ipairs(exit_types) do
        if voy.rooms[trajectory_room][v] and voy.rooms[trajectory_room][v][command] then
            if v == "overboard" then
                if #voy.sequence == 1 then -- only allow normalized overboarding without a queued trajectory, otherwise it would be too easy to accidently jump off deck
                    command = v
                else
                    break
                end
            elseif v == "board" then
                command = v 
            elseif v == "up" or v == "down" then
                command = v
            end
            end_room = voy.rooms[trajectory_room][v][command]
            break
        end
    end
    command = directions[command] or command
    return end_room, command
end
--------------------------------------------------------------------------------
--   ITEM DRAGGING
--------------------------------------------------------------------------------
function on_alias_voyage_drag_room(name, line, wildcards)
    voy.commands.move.count = (voy.commands.move.count or 0) + 1 -- used in 'stop' handling
    local trajectory_room, command = voyage_normalize_direction(voyage_format_direction(wildcards))
    table.insert(voy.sequence, trajectory_room)
    table.insert(voy.commands.move, command)
    local object = wildcards.object ~= "" and wildcards.object or "tank"
    voy.drag.object = string.lower(object)
    Send("drag "..object.." "..command)
    voyage_print_map()
end

function on_alias_voyage_drag_toggle(name, line, wildcards)
    local object = string.lower(wildcards.object)
    local col = voy.colours.notes
    if line == "dt" then 
        ColourNote(col.text, col.background, 'Drag: "tank"')
        voy.drag = {object = "tank", on = true}
    elseif object == "off" or object == "" then
        ColourNote(col.text, col.background, 'Drag: off')
        voy.drag = {object = "tank", on = false}
    else 
        ColourNote(col.text, col.background, 'Drag: "'..object..'"')
        voy.drag = {object = object, on = true}
    end
end
-- automaticly toggle drag off when we fill boiler
function on_trigger_voyage_boiler_fill(name, line, wildcards, styles)
	local col = voy.colours.notes
	if voy.drag.on then
        ColourNote(col.text, col.background, 'Drag: off')
        voy.drag = {object = "tank", on = false}		
	end
end
--------------------------------------------------------------------------------
--   PLAYER/DRAGON TRACKING
--------------------------------------------------------------------------------
function voyage_update_population()
    local population = {player_rooms = 0}
    for r, v in ipairs(voy.rooms) do
        local is_player, is_dragon = false, false
        for k, _ in pairs(v.players) do
            is_player = k
            break
        end
        if not(is_player) then
            for k, _ in pairs(v.dragons) do
                is_dragon = k
                break
            end
        end
        if voy.players[is_player] then
            population[#population + 1] = {room = r, colour = voy.players[is_player]}
            population.player_rooms = population.player_rooms + 1
        elseif is_dragon then
            population[#population + 1] = {room = r, colour = false}
        end
    end
    voy.population = population
end
-- players
function on_trigger_voyage_player_enter(name, line, wildcards, styles)
    local function move_players_in(end_room, players)
        local is_change = false
        for player in string.gmatch(players, '[^,]+') do
            if voy.players[player] then
                for r, v in ipairs(voy.rooms) do
                    if voy.rooms[r].players[player] then
                        voy.rooms[r].players[player] = nil
                        break
                    end
                end
                local name = player
                voy.re.titles:gmatch(player, function (_, t)
                    name = name:gsub(t.title.." ", "")
                end)
                name = name:gsub("^([a-z']+) .*$", "%1")
                voy.rooms[end_room].players[player] = name
                is_change = true
            end
        end
        if is_change then
            voyage_update_population()
            voyage_print_map()
        end
    end
    local players = ","..string.lower(wildcards.players):gsub(" and ", ","):gsub(", ", ",")
    local current_room = voy.sequence[1]
    move_players_in(current_room, players)
end

function on_trigger_voyage_player_leave(name, line, wildcards, styles)
    local function get_end_room(start_room, exit_types, direction)
        for i, v in ipairs(exit_types) do
            if voy.rooms[start_room][v] and voy.rooms[start_room][v][direction] then
                return voy.rooms[start_room][v][direction]
            end
        end    
    end
    local function move_players_out(start_room, end_room, players)
        local is_change = false
        for player in string.gmatch(players, '[^,]+') do
            if voy.players[player] and end_room then
                local name = player
                voy.re.titles:gmatch(player, function (_, t)
                    name = name:gsub(t.title.." ", "")
                end)
                name = name:gsub("^([a-z']+) .*$", "%1")
                if voy.rooms[start_room].players[player] then
                    voy.rooms[start_room].players[player] = nil
                else
                    for r, v in ipairs(voy.rooms) do
                        if voy.rooms[r].players[player] then
                            voy.rooms[r].players[player] = nil
                            break
                        end
                    end
                end
                voy.rooms[end_room].players[player] = name
                is_change = true
            end
        end
        if is_change then
            voyage_update_population()
            voyage_print_map()
        end
    end
    local players = ","..string.lower(wildcards.players):gsub(" and ", ","):gsub(", ", ",")
    local start_room, end_room = voy.sequence[1], false
    if wildcards.overboard ~= "" then
        end_room = get_end_room(start_room,  {"overboard"}, "overboard")
    elseif wildcards.board ~= "" then
        end_room = get_end_room(start_room,  {"board"}, "board")
    elseif wildcards.lateral == "up" then
        end_room = get_end_room(start_room, {"up"}, "up")
    elseif wildcards.lateral == "down" then
        end_room = get_end_room(start_room, {"down"}, "down")
    else
        local directions = {["fore"] = "n", ["starboard fore"] = "ne", ["starboard"] = "e", ["starboard aft"] = "se", ["aft"] = "s", ["port aft"] = "sw", ["port"] = "w", ["port fore"] = "nw",}
        end_room = get_end_room(start_room,  {"exits", "doors"}, directions[wildcards.nautical])
    end
    move_players_out(start_room, end_room, players)
end
-- dragons
function on_trigger_voyage_dragon_enter(name, line, wildcards, styles)
    local function move_dragons_in(end_room, dragons)
        local is_change = false
        for dragon in string.gmatch(dragons, '[^,]+') do
            if voy.dragons[dragon] then
                for r, v in ipairs(voy.rooms) do
                    if voy.rooms[r].dragons[dragon] then
                        voy.rooms[r].dragons[dragon] = nil
                        break
                    end
                end
                local name = string.match(dragon, "^(%w+)")
                voy.rooms[end_room].dragons[dragon] = name
                if voy.dragon[name] then
                    voy.dragon[name].circle = false
                end
                is_change = true
            end
        end
        if is_change then
            voyage_update_population()
            voyage_print_map()
        end
    end
    local dragons = ","..string.lower(wildcards.dragons):gsub(" and ", ","):gsub(", ", ",")
    local current_room = voy.sequence[1]
    move_dragons_in(current_room, dragons)
end

function on_trigger_voyage_dragon_leave(name, line, wildcards, styles)
    local function get_end_room(start_room, exit_types, direction)
        for i, v in ipairs(exit_types) do
            if voy.rooms[start_room][v] and voy.rooms[start_room][v][direction] then
                return voy.rooms[start_room][v][direction]
            end
        end    
    end
    local function move_dragons_out(start_room, end_room, dragons)
        local is_change = false
        for dragon in string.gmatch(dragons, '[^,]+') do
            if voy.dragons[dragon] and end_room then
                if voy.rooms[start_room].dragons[dragon] then
                    voy.rooms[start_room].dragons[dragon] = nil
                else
                    for r, v in ipairs(voy.rooms) do
                        if voy.rooms[r].dragons[dragon] then
                            voy.rooms[r].dragons[dragon] = nil
                            break
                        end
                    end
                end
                local name = string.match(dragon, "^(%w+)") 
                voy.rooms[end_room].dragons[dragon] = name
                if voy.dragon[name] then
                    voy.dragon[name].circle = false
                end
                is_change = true
            end
        end
        if is_change then
            voyage_update_population()
            voyage_print_map()
        end
    end
    local dragons = ","..string.lower(wildcards.dragons):gsub(" and ", ","):gsub(", ", ",")
    local start_room, end_room = voy.sequence[1], false
    if wildcards.lateral == "up" then
        end_room = get_end_room(start_room, {"up"}, "up")
    elseif wildcards.lateral == "down" then
        end_room = get_end_room(start_room, {"down"}, "down")
    else
        local directions = {["fore"] = "n", ["starboard fore"] = "ne", ["starboard"] = "e", ["starboard aft"] = "se", ["aft"] = "s", ["port aft"] = "sw", ["port"] = "w", ["port fore"] = "nw",}
        end_room = get_end_room(start_room,  {"exits", "doors"}, directions[wildcards.nautical])
    end
    move_dragons_out(start_room, end_room, dragons)
end
