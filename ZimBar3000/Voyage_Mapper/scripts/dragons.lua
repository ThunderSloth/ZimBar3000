--------------------------------------------------------------------------------
--   HUNGER/BOREDOM
--------------------------------------------------------------------------------
function on_trigger_voyage_dragon_look(name, line, wildcards, styles)
    local function get_dragon(colour)
        local dragons = {green = "aggy", red = "idiot", purple = "nugget", blue = "bitey",}
        for k, v in pairs(dragons) do
            if colour:match(k) then
                return v
            end
        end
    end
    local function get_hunger(condition)
        local hunger = tonumber(condition:match("hungry [(](%d+)[/]%d+[)]")) -- i.e. 'not at all hungry (13/100)'
        if hunger then
            return hunger
        elseif condition:match("very hungry") then
            return 90
        elseif condition:match("somewhat hungry") then
            return 70
        elseif condition:match("little hungry") then
            return 50
        else
            return 0
        end
    end
    local function get_boredom(condition)
        local bored = tonumber(condition:match("bored [(](%d+)[/]%d+[)]"))
        if bored then
            return bored
        elseif condition:match("very bored") then
            return 90
        elseif condition:match("somewhat bored") then
            return 70
        elseif condition:match("little bored") then
            return 50
        else
            return 0
        end
    end
    local function get_sleep(condition)
        return condition:match("asleep") and true or false
    end
    local function get_position(position)
        return position:match("circle") and true or false
    end
    local coor, dim, col = voy.coordinates.circle, voy.dimensions, voy.colours
    local dragon = get_dragon(wildcards.colour)
    local condition = wildcards.condition
    if condition == "energetic" then
        voy.dragon[dragon].hunger = 0
        voy.dragon[dragon].boredom = 0
    else
        voy.dragon[dragon].hunger = get_hunger(condition)
        voy.dragon[dragon].boredom = get_boredom(condition)
    end
    voy.dragon[dragon].asleep = get_sleep(condition)
    voy.dragon[dragon].circle = get_position(wildcards.position)
    voyage_draw_guages(dim, col)
    voyage_print_map()
end
--------------------------------------------------------------------------------
--   SLEEP
--------------------------------------------------------------------------------
function on_trigger_voyage_dragon_wake(name, line, wildcards, styles)
    local dragon = string.lower(wildcards.dragon)
    if voy.dragon[dragon] then
        voy.dragon[dragon].asleep = false
        voy.dragon[dragon].circle = false
    end
    voyage_draw_guages(voy.dimensions, voy.colours)
    voyage_print_map()
end

function on_trigger_voyage_dragon_sleep(name, line, wildcards, styles)
    local dragon = string.lower(wildcards.dragon)
    if voy.dragon[dragon] then
        voy.dragon[dragon].asleep = true
        voy.dragon[dragon].circle = false
    end
    voyage_draw_guages(voy.dimensions, voy.colours)
    voyage_print_map()
end
--------------------------------------------------------------------------------
--   CIRCLE
--------------------------------------------------------------------------------
function on_trigger_voyage_dragon_circle(name, line, wildcards, styles)
    local dragon = string.lower(wildcards.dragon)
    local current_room = voy.sequence[1]
    if voy.dragon[dragon] then
        voy.dragon[dragon].circle = true
    end
    local name = voy.dragon[dragon] and voy.dragon[dragon].long or false
    if not voy.rooms[current_room].dragons[name] then
        for r, v in ipairs(voy.rooms) do
            if voy.rooms[r].dragons[name] then
                voy.rooms[r].dragons[name] = nil
                break
            end
        end
        voy.rooms[current_room].dragons[name] = dragon
        voyage_update_population()
    end
    voyage_print_map()
end

function on_trigger_voyage_dragon_uncircle(name, line, wildcards, styles)
    local dragon = string.lower(wildcards.dragon)
    local current_room = voy.sequence[1]
    if voy.dragon[dragon] then
        local name = voy.dragon and voy.dragon[dragon].long or false
        for r, v in ipairs(voy.rooms) do
            if voy.rooms[r].dragons[name] then
                voy.rooms[r].dragons[name] = nil
                break
            end
        end
        voy.rooms[current_room].dragons[name] = dragon
        voy.dragon[dragon].circle = false
        voyage_update_population()
        voyage_print_map()
    end
end
--------------------------------------------------------------------------------
--   GET/DROP
--------------------------------------------------------------------------------
function on_trigger_voyage_dragon_get(name, line, wildcards, styles)
    local dragon = string.lower(wildcards.dragon)
    local current_room = voy.sequence[1]
    if voy.dragon[dragon] then
        local name = voy.dragon[dragon].long
        if voy.rooms[current_room].dragons[name] then
            voy.rooms[current_room].dragons[name] = nil
        else
            for r, v in ipairs(voy.rooms) do
                if voy.rooms[r].dragons[name] then
                    voy.rooms[r].dragons[name] = nil
                    break
                end
            end
        end
        voy.dragon[dragon].circle = false
        voyage_update_population()
        voyage_print_map()
    end
end

function on_trigger_voyage_dragon_drop(name, line, wildcards, styles)
    local dragon = string.lower(wildcards.dragon)
    local current_room = voy.sequence[1]
    if voy.dragon[dragon] then
        local name = voy.dragon and voy.dragon[dragon].long or false
        for r, v in ipairs(voy.rooms) do
            if voy.rooms[r].dragons[name] then
                voy.rooms[r].dragons[name] = nil
                break
            end
        end
        voy.rooms[current_room].dragons[name] = dragon
        voy.dragon[dragon].circle = false
        voyage_update_population()
        voyage_print_map()
    end
end

function on_trigger_voyage_dragon_drop_and_wake(name, line, wildcards, styles)
    local dragon = string.lower(wildcards.dragon)
    local current_room = voy.sequence[1]
    if voy.dragon[dragon] then
        local name = voy.dragon and voy.dragon[dragon].long or false
        for r, v in ipairs(voy.rooms) do
            if voy.rooms[r].dragons[name] then
                voy.rooms[r].dragons[name] = nil
                break
            end
        end
        voy.rooms[current_room].dragons[name] = dragon
        voy.dragon[dragon].circle = false
        voy.dragon[dragon].asleep = false
        voyage_update_population()
        voyage_draw_guages(voy.dimensions, voy.colours)
        voyage_print_map()
    end
end
--------------------------------------------------------------------------------
--   PLAY
--------------------------------------------------------------------------------
function on_trigger_voyage_dragon_play(name, line, wildcards, styles)
    local room = voy.sequence[1]
    local object = name:match("voyage_dragon_play_(.*)")
    voy.rooms[room].objects[object] = voy.rooms[room].objects[object] - 1 > 0 and voy.rooms[room].objects[object] - 1 or 0
    local dragon = string.lower(wildcards.dragon)
    if voy.dragon[dragon] then
        voy.dragon[dragon].boredom = 0
        voy.dragon[dragon].circle = false
        voyage_draw_guages(voy.dimensions, voy.colours)
    end
    voyage_print_map()
end
--------------------------------------------------------------------------------
--   FEED
--------------------------------------------------------------------------------
function on_trigger_voyage_dragon_feed_initiate(name, line, wildcards, styles)
    local dragon = string.lower(wildcards.dragon)
    if voy.dragon[dragon] then
        voy.dragon[dragon].hunger = voy.dragon[dragon].hunger / 2
        voy.dragon[dragon].circle = false
        voyage_draw_guages(voy.dimensions, voy.colours)
        voyage_print_map()
    end
end

function on_trigger_voyage_dragon_feed_continue(name, line, wildcards, styles)
    local dragon = string.lower(wildcards.dragon)
    if voy.dragon[dragon] then
        voy.dragon[dragon].hunger = voy.dragon[dragon].hunger  / 2
        voy.dragon[dragon].circle = false
        voyage_draw_guages(voy.dimensions, voy.colours)
        voyage_print_map()    
    end
end

function on_trigger_voyage_dragon_feed_complete(name, line, wildcards, styles)
    voyage_update_objects(voy.sequence[1], "a "..wildcards.objects, true)
    local dragon = string.lower(wildcards.dragon)
    if voy.dragon[dragon] then
        voy.dragon[dragon].hunger = 0
        voy.dragon[dragon].circle = false
        voyage_draw_guages(voy.dimensions, voy.colours)
    end
    voyage_print_map()
end
