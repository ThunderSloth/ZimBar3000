--------------------------------------------------------------------------------
--   LOOK NORMALIZING
--------------------------------------------------------------------------------
function on_alias_voyage_look_to(name, line, wildcards, styles)
    local directions = {["fore"] = "n", ["starboard fore"] = "ne", ["starboard"] = "e", ["starboard aft"] = "se", ["aft"] = "s", ["port aft"] = "sw", ["port"] = "w", ["port fore"] = "nw",}
    voy.commands.look.count = (voy.commands.look.count or 0) + 1 -- used in 'stop' handling
    local look_room, command = voyage_normalize_direction(voyage_format_direction(wildcards))
    table.insert(voy.commands.look, directions[command] or command)
    Send("look "..command)
end
--------------------------------------------------------------------------------
--   LOOK ROOM
--------------------------------------------------------------------------------
function on_trigger_voyage_room(name, line, wildcards, styles)
    local function reset_room(room)
        if tonumber(room) then
            local function reset_adjacent_rooms(room)
                if room < 21 then
                    local exit_types = {"exits", "doors", "up", "down", "board",}
                    for _, v in ipairs(exit_types) do
                        if voy.rooms[room][v] then
                            for _2, r in pairs(voy.rooms[room][v]) do
								if voy.rooms[r].visable then
									voy.rooms[r].fire = 0
                                end
                            end
                        end
                    end
                end
            end
            voy.rooms[room].players = {}
            voy.rooms[room].dragons = {}
            voyage_update_population()
            voy.rooms[room].ice = 0
            voyage_update_ice()
            voy.rooms[room].fire = 0
            if #voy.fire > 0 then
                reset_adjacent_rooms(room)
            end
            voyage_update_fire()
            for k, v in pairs(voy.rooms[room].objects) do
                voy.rooms[room].objects[k] = 0
            end
        end
    end
    local room = name:match("on_trigger_voyage_room_(.+)")
    if wildcards.title ~= "" then
        room = voy.sequence[1]
        if wildcards.objects ~= "" then
            voyage_look_objects(room, wildcards.objects)
        elseif wildcards.thyngs ~= "" then
            voyage_look_thyngs(room, wildcards.thyngs)
        else
            reset_room(room)
            voyage_look_description(room, wildcards.description)
            voyage_look_condition(room, wildcards.condition)
            voyage_look_speed(wildcards.speed)
            voyage_update_stage(room, wildcards.monster, wildcards.weather)
        end
        voyage_print_map()
    elseif wildcards.look ~= "" then
        if wildcards.objects ~= "" then
            room = voy.look_room
            if room then
                voyage_look_objects(room, wildcards.objects)
            end
        elseif wildcards.thyngs ~= "" then
            room = voy.look_room
            if room then
                voyage_look_thyngs(room, wildcards.thyngs)
            end
        else
            if tonumber(room) then
                room = tonumber(room)
            else
                local function get_room(rooms, current_room, command)
                    local exit_types = {"exits", "doors", "up", "board",}
                    for _, room in ipairs(rooms) do
                        for _2, v in ipairs(exit_types) do
                            if voy.rooms[current_room][v] and voy.rooms[current_room][v][command] and voy.rooms[current_room][v][command] == room then
                                return room
                            end
                        end
                    end
                end
                if room == "hatches" then
                    room = get_room({5, 7}, voy.sequence[1], voy.commands.look[1])
                elseif room == "stores" then
                    room = get_room({13, 16, 19}, voy.sequence[1], voy.commands.look[1])
                end
            end
            reset_room(room)
            voyage_look_description(room, wildcards.description)
            voyage_look_condition(room, wildcards.condition)
            voyage_look_speed(wildcards.speed)
            voyage_update_stage(room, wildcards.monster, wildcards.weather)
            voy.look_room = room
            voy.commands.look[0] = voy.commands.look[1]
            table.remove(voy.commands.look, 1)
        end
        voyage_print_map(room)
    end
end
--------------------------------------------------------------------------------
--   DESCRIPTION (MAST/SHELVES)
--------------------------------------------------------------------------------
function voyage_look_description(room, desc)
    if room == 6 or room == 13 or room == 16 or room == 19 then
        if desc:match("sawdust") then
            voy.rooms[room].smashed = true
        end
    end
end
--------------------------------------------------------------------------------
--   CONDITION (FIRE/ICE)
--------------------------------------------------------------------------------
function voyage_look_condition(room, text)
    if tonumber(room) then
        local directions = {["fore"] = "n", ["starboardfore"] = "ne", ["starboard"] = "e", ["starboardaft"] = "se", ["aft"] = "s", ["portaft"] = "sw", ["port"] = "w", ["portfore"] = "nw",}
        voy.re.adjacent_fire:gmatch(text, function (_, t)
            local line = t[1]:gsub("starboard aft", "starboardaft"):gsub("starboard fore", "starboardfore"):gsub("port aft", "portaft"):gsub("port fore", "portfore")
            voy.re.directions:gmatch(line, function (_2, t2)
                local dir = t2[1]
                local fire_room = voy.rooms[room].exits[directions[dir]] or voy.rooms[room].doors[directions[dir]] or false
                if fire_room then
                    voy.rooms[fire_room].fire = voy.rooms[fire_room].fire == 0 and 3 or voy.rooms[fire_room].fire
                end
                voyage_update_fire()
            end)
        end)
        if room < 21 and text:match(" ice[., ]") then
            if text:match("[Aa] little ice has formed around the edges of the floor") then
                voy.rooms[room].ice = 3
            elseif text:match("[Ss]ome of the floor is coated in a slippery layer of ice") then
                voy.rooms[room].ice = 4
            elseif text:match("[Mm]ost of the floor is coated in a slippery layer of ice") then
                voy.rooms[room].ice = 5
            elseif text:match("[Mm]ost of the floor is heavily coated in a very slippery layer of ice.") then
                voy.rooms[room].ice = 6
            end
            voyage_update_ice()
        end
    end
end
--------------------------------------------------------------------------------
--   SPEED
--------------------------------------------------------------------------------
function voyage_look_speed(speed)
    if speed then
        local speeds = {standstill = 0, slowly = 1, moderate = 2, rapidly = 3, blur = 4}
        voy.speed = speeds[speed] or 0
    end
end
--------------------------------------------------------------------------------
--   STAGE (WEATHER/MONSTER)
--------------------------------------------------------------------------------
function voyage_update_stage(room, monster, weather)
    local function reset_highlights()
        voy.kraken = false
        voy.serpent = false
        voy.lightning = false
    end
    if tonumber(room) then
        if (room <= 10 or room == 21 or room == 23) and room ~= 3 then
			voy.is_night = weather:match("night") and true or false
            if monster:match("coiled around the ship") then --serpent
                if voy.stage ~= "Serpent" then
                    voy.stage = "Serpent"; voyage_draw_stage(voy.coordinates, voy.colours, win.."underlay"); reset_highlights()
                    xp_t[4].name = "Serpent"
                end
            elseif monster:match("tentacles wrapped around the ship") then --kraken
                if voy.stage ~= "Kraken" then
                    voy.stage = "Kraken"; voyage_draw_stage(voy.coordinates, voy.colours, win.."underlay"); reset_highlights()
                    xp_t[4].name = "Kraken"
                end
            else
                if weather:match("clear sky") then --calm
                    if voy.stage ~= "Calm" then
                        voy.stage = "Calm"; voyage_draw_stage(voy.coordinates, voy.colours, win.."underlay"); reset_highlights()            
                    end
                elseif weather:match("gale[-]force") then --wind
                    if voy.stage ~= "Wind" then
                        voy.stage = "Wind"; voyage_draw_stage(voy.coordinates, voy.colours, win.."underlay"); reset_highlights() 
                    end
                elseif weather:match("heavy fog") then --fog
                    if voy.stage ~= "Fog" then
                        voy.stage = "Fog"; voyage_draw_stage(voy.coordinates, voy.colours, win.."underlay"); reset_highlights() 
                    end
                elseif weather:match("driving hail") then --ice
                    if voy.stage ~= "Ice" then
                        voy.stage = "Ice"; voyage_draw_stage(voy.coordinates, voy.colours, win.."underlay"); reset_highlights() 
                    end
                elseif weather:match("packed cloud cover") then --fire
                    if voy.stage ~= "Fire" then
                        voy.stage = "Fire"; voyage_draw_stage(voy.coordinates, voy.colours, win.."underlay"); reset_highlights() 
                    end
                end
            end
        else
            if voy.stage ~= "???" then
                voy.stage = "???"; voyage_draw_stage(voy.coordinates, voy.colours, win.."underlay"); reset_highlights() 
            end
        end
    end
end
--------------------------------------------------------------------------------
--   THYNGS (PLAYERS/DRAGONS)
--------------------------------------------------------------------------------
function voyage_look_thyngs(room, text)
    local function get_dragons(str)
        local t = {}
        local dragons = {"aggy", "idiot", "nugget", "bitey",}
        for i, v in ipairs(dragons) do
            if str:match(v) then
                t[v] = true
            end
        end
        return t
    end
    local thyngs = string.lower(text)
    local _1, _2, t = voy.re.sleeping:match(thyngs)
    local sleeping = t and t[1] or false
    local sleepers = sleeping and get_dragons(sleeping) or {}
    local _1, _2, t = voy.re.circle:match(thyngs)
    local circle = t and t[1] or false
    local circled = circle and get_dragons(circle) or {}
    local is_update_guages = false
    thyngs = ","..thyngs:gsub("on to the ship's wheel", "here"):gsub("for food", "here"):gsub("at attention", "here"):gsub("around curiously", "here"):gsub("in the small red circle", "here"):gsub("sprawled in a heap", "iing here"):gsub("knocked out here", "iing here"):gsub("[oi]n the %w+ here", "here"):gsub(" %w+ %w+ing here[.]?", ""):gsub(" and ", ", "):gsub(", ",",")
    for thyng in string.gmatch(thyngs, '[^,]+') do	
		thyng = Trim(thyng)
        if voy.players[thyng] then
            for r, v in ipairs(voy.rooms) do
                if voy.rooms[r].players[thyng] then
                    voy.rooms[r].players[thyng] = nil
                    break
                end
            end
            local name = thyng
            voy.re.titles:gmatch(thyng, function (_, t)
                name = name:gsub(t.title.." ", "")
            end)
            name = name:gsub("^([a-z']+) .*$", "%1")
            voy.rooms[room].players[thyng] = name -- thisline
        elseif voy.dragons[thyng] then
            for i, v in ipairs(voy.rooms) do
                if v.dragons[thyng] then
                    voy.rooms[i].dragons[thyng] = nil
                    break
                end
            end
            local name = string.match(thyng, "^(%w+)")
            voy.rooms[room].dragons[thyng] = name
            if voy.dragon[name] then
                local s = voy.dragon[name].asleep
                voy.dragon[name].asleep = sleepers[name] or false
                if s ~= voy.dragon[name].asleep then
                    is_update_guages = true
                end
                voy.dragon[name].circle = circled[name] or false
            end
        end
    end
    if is_update_guages then
        voyage_draw_guages(voy.dimensions, voy.colours)
    end
    voyage_update_population()
end
--------------------------------------------------------------------------------
--   OBJECTS (AND FIRES)
--------------------------------------------------------------------------------
function voyage_look_objects(room, text)
    -- fires
    if tonumber(room) then
        local fire = 0
        if text:match("burning merrily") then
            fire = 6
        elseif text:match("conflagration") then
            fire = 5
        elseif text:match("blazes") then
            fire = 4
        elseif text:match("small fire has started") then
            fire = 3
        end
        if voy.rooms[room].fire ~= fire then
            voy.rooms[room].fire = fire
            voyage_update_fire()
        end
    -- objects
    voyage_update_objects(room, text)
    end
end
