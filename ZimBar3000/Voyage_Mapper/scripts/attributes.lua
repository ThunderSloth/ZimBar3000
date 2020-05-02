--------------------------------------------------------------------------------
--   PART
--------------------------------------------------------------------------------
function on_trigger_voyage_complete_part(name, line, wildcards, styles)
    local legs = {first = 1, second = 2, third = 3, fourth = 4}
    local finished_part = voy.part
    voy.part = (legs[wildcards.leg] or 0) + 1
    voyage_complete_xp_range(finished_part)
    voyage_draw_part(voy.coordinates, voy.colours, win.."underlay")
    voyage_print_map()
end

function on_trigger_voyage_complete_voyage(name, line, wildcards, styles)
    voyage_update_completion_stats(wildcards)
end
--------------------------------------------------------------------------------
--   STAGE
--------------------------------------------------------------------------------
function on_trigger_voyage_stage_change(name, line, wildcards, styles)
    local stage = name:match("voyage_stage_change_(.+)")
    voy.stage = stage:gsub("^%l", string.upper)
    voyage_draw_stage(voy.coordinates, voy.colours, win.."underlay")
    voy.kraken, voy.serpent = false, false
    voyage_print_map()
end

function on_trigger_voyage_serpent_crest(name, line, wildcards, styles)
	xp_t[4].name = "Serpent"
	on_trigger_voyage_stage_change("voyage_stage_change_serpent", line, wildcards, styles)
end

function on_trigger_voyage_kraken_crest(name, line, wildcards, styles)
	xp_t[4].name = "Kerpent"
	on_trigger_voyage_stage_change("voyage_stage_change_kraken", line, wildcards, styles)
end

function on_trigger_voyage_kill_monster(name, line, wildcards, styles)
	voyage_complete_xp_range("Fight")
	on_trigger_voyage_stage_change("voyage_stage_change_calm", line, wildcards, styles)
end
--------------------------------------------------------------------------------
--   ICE (ROOM)
--------------------------------------------------------------------------------
function voyage_update_ice()
    voy.ice = {}
    for i, v in ipairs(voy.rooms) do
        if v.ice > 0 then
            table.insert(voy.ice, {room = i, size = v.ice})
        end
    end
end

function on_trigger_voyage_ice_on(name, line, wildcards, styles)
    if voy.rooms[voy.sequence[1]].ice >= 3 then
        voy.rooms[voy.sequence[1]].ice = voy.rooms[voy.sequence[1]].ice + 1
    else
        voy.rooms[voy.sequence[1]].ice = 3
    end
    voyage_update_ice()
    voyage_print_map()
end

function on_trigger_voyage_ice_off(name, line, wildcards, styles)
    voy.rooms[voy.sequence[1]].ice = 0
    voyage_update_ice()
    voyage_print_map()
end

function on_trigger_voyage_ice_shrink(name, line, wildcards, styles)
    voy.rooms[voy.sequence[1]].ice = voy.rooms[voy.sequence[1]].ice - 1 > 0 and voy.rooms[voy.sequence[1]].ice - 1 or 1
    voyage_update_ice()
    voyage_print_map()
end
--------------------------------------------------------------------------------
--   FIRE / LIGHTNING
--------------------------------------------------------------------------------
function voyage_update_fire()
    voy.fire = {}
    for i, v in ipairs(voy.rooms) do
        if v.fire > 0 then
            table.insert(voy.fire, {room = i, size = v.fire})
        end
    end
    voyage_print_map()
end

function on_trigger_voyage_lightning_hit(name, line, wildcards, styles)
    local directions = {["fore"] = "n", ["starboard fore"] = "ne", ["starboard"] = "e", ["starboard aft"] = "se", ["aft"] = "s", ["port aft"] = "sw", ["port"] = "w", ["port fore"] = "nw",}
    voy.lightning = directions[wildcards.nautical]
    voyage_print_map()
end

function on_trigger_voyage_fire_on(name, line, wildcards, styles)
    voy.rooms[voy.sequence[1]].fire = 3
    voyage_update_fire()
    voyage_print_map()
end

function on_trigger_voyage_fire_off(name, line, wildcards, styles)
    voy.rooms[voy.sequence[1]].fire = 0
    voyage_update_fire()
    voyage_print_map()
end

function on_trigger_voyage_fire_grow(name, line, wildcards, styles)
    voy.rooms[voy.sequence[1]].fire = voy.rooms[voy.sequence[1]].fire + 1
    voyage_update_fire()
    voyage_print_map()
end

function on_trigger_voyage_fire_shrink(name, line, wildcards, styles)
    voy.rooms[voy.sequence[1]].fire = (voy.rooms[voy.sequence[1]].fire - 1) > 0 and voy.rooms[voy.sequence[1]].fire - 1 or 1
    voyage_update_fire()
    voyage_print_map()
end

function on_trigger_voyage_fire_adjacent(name, line, wildcards, styles)
    local directions = {["fore"] = "n", ["starboard fore"] = "ne", ["starboard"] = "e", ["starboard aft"] = "se", ["aft"] = "s", ["port aft"] = "sw", ["port"] = "w", ["port fore"] = "nw", above = -10, below = 10}
    local dir = wildcards.nautical ~= "" and wildcards.nautical or wildcards.vertical
    local current_room = voy.sequence[1]
    local fire_room
    if type(dir) == "number" then
		fire_room = current_room + directions[dir]
    else
		fire_room = voy.rooms[current_room].exits[directions[dir]] or voy.rooms[current_room].doors[directions[dir]]
    end
     
    if fire_room then
        voy.rooms[fire_room].fire = voy.rooms[fire_room].fire == 0 and 3 or voy.rooms[fire_room].fire
    end
    --print("FIRE!!!!!!", dir)
    voyage_update_fire()
    voyage_print_map()
end
--------------------------------------------------------------------------------
--   HULL
--------------------------------------------------------------------------------
-- hull: condition from look
function on_trigger_voyage_hull_condition(name, line, wildcards, styles)
    local col = voy.colours.hull
    local condition = {"perfect condition", "a little scuffed up", "rather dented", "bears the marks of multiple impacts", "badly cracked",}
    local percentage = 0
    for i, v in ipairs(condition) do
        if line:match(v) then
            percentage = (i - 1) * 20
            voyage_draw_hull_lower(voy.coordinates, voyage_fade_RGB(percentage == 0 and col.default or col.fade, col.damage, percentage), win.."underlay")
            break
        end
    end
    voy.hull.condition = percentage
    percentage = 0
    local seaweed = {"thin covering of glowing dire seaweed", "few strands of glowing dire seaweed", "thick mass of glowing dire seaweed", "colossal amount of glowing dire seaweed"}
    local colour = col.default
    for i, v in ipairs(seaweed) do
        if line:match(v) then
            percentage = i * 25
            colour = voyage_fade_RGB(col.fade, col.seaweed, percentage)
            break
        end
    end
    voy.hull.seaweed = percentage
    percentage = 0
    local ice = {"thin layer of sea ice", "few patches of sea ice", "thick mass of sea ice", "colossal amount of sea ice"}
    for i, v in ipairs(ice) do
        if line:match(v) then
            percentage = i * 25
            colour = voyage_fade_RGB(col.fade, col.ice, percentage)
            break
        end
    end
    voy.hull.ice = percentage 
    voyage_draw_hull_upper(voy.coordinates, colour, win.."underlay")
    voyage_print_map()
end

-- hull: update from group say
function on_trigger_voyage_group_update(name, line, wildcards, styles)
    line = string.lower(line)
    local update = false
    local col = voy.colours.hull.default
    if voy.re.hull_report:match(line) then
        voy.hull.condition = 0
        voyage_draw_hull_lower(voy.coordinates, col, win.."underlay")
        update = true
    end
    if voy.re.other_report:match(line) and (line:match(" weed") or line:match(" seaweed") or line:match(" ice")) then
        voy.hull.ice, voy.hull.seaweed = 0, 0
        voyage_draw_hull_upper(voy.coordinates, col, win.."underlay")
        update = true
    end
    if update then
        voyage_print_map()
    end
end

-- hull: condition
function on_trigger_voyage_hull_fix(name, line, wildcards, styles)
    local col = voy.colours.hull.default
    voy.hull.condition = 0
    voyage_draw_hull_lower(voy.coordinates, col, win.."underlay")
    voyage_print_map()
end

function on_trigger_voyage_hull_fix_partial(name, line, wildcards, styles)
    local col = voy.colours.hull
    local percentage = (voy.hull.condition - 20) > 0 and voy.hull.condition - 20 or 20
    voy.hull.condition = percentage
    voyage_draw_hull_lower(voy.coordinates, voyage_fade_RGB(col.fade, col.damage, percentage), win.."underlay")
    voyage_print_map()
end

function on_trigger_voyage_hull_hit(name, line, wildcards, styles)
    local hits = {
		["creaking a little more than before"] = 1, 
		["giant turtle bellowing"] = 1,
		["shaking violently from the collision"] = 1,
		["taking quite a beating"] = 2, 
		["breaks with an distant snap"] = 3, 
		["last legs"] = 4, 
		["breached"] = 5,
	}
    local col = voy.colours.hull
    local percentage = voy.hull.condition
    for k, i in pairs(hits) do
        if line:match(k) then
                percentage = ((i + 1) * 20) < 100 and (i + 1) * 20 or 100
            break
        end
    end
    voy.hull.condition = percentage
    voyage_draw_hull_lower(voy.coordinates, voyage_fade_RGB(col.fade, col.damage, percentage), win.."underlay")
    voyage_print_map()
end

-- hull: seaweed
function on_trigger_voyage_seaweed_fix(name, line, wildcards, styles)
    local col = voy.colours.hull.default
    voy.hull.seaweed, voy.hull.ice = 0, 0
    voyage_draw_hull_upper(voy.coordinates, col, win.."underlay")
    voyage_print_map()
end

function on_trigger_voyage_seaweed_fix_partial(name, line, wildcards, styles)
    local col = voy.colours.hull
    percentage = (voy.hull.seaweed - 25) > 0 and (voy.hull.seaweed - 25) or 10
    voy.hull.seaweed = percentage
    voy.hull.ice = 0
    voyage_draw_hull_upper(voy.coordinates, voyage_fade_RGB(col.fade, col.seaweed, percentage), win.."underlay")
    voyage_print_map()
end

function on_trigger_voyage_seaweed_hit(name, line, wildcards, styles)
    local col = voy.colours.hull
    local percentage = (voy.hull.seaweed + 50) < 100 and voy.hull.seaweed + 50 or 100
    voy.hull.seaweed = percentage
    voy.hull.ice = 0
    voyage_draw_hull_upper(voy.coordinates, voyage_fade_RGB(col.fade, col.seaweed, percentage), win.."underlay")
    voyage_print_map()
end

-- hull: ice
function on_trigger_voyage_ice_fix(name, line, wildcards, styles)
    local col = voy.colours.hull.default
    voy.hull.ice, voy.hull.seaweed = 0, 0
    voyage_draw_hull_upper(voy.coordinates, col, win.."underlay")
    voyage_print_map()
end

function on_trigger_voyage_ice_fix_partial(name, line, wildcards, styles)
    local col = voy.colours.hull
    local percentage = (voy.hull.ice - 25) > 0 and (voy.hull.ice - 25) or 10
    voy.hull.ice = percentage
    voy.hull.seaweed = 0
    voyage_draw_hull_upper(voy.coordinates, voyage_fade_RGB(col.fade, col.ice, percentage), win.."underlay")
    voyage_print_map()
end

function on_trigger_voyage_ice_hit(name, line, wildcards, styles)
    local col = voy.colours.hull
    local percentage = (voy.hull.ice + 50) < 100 and voy.hull.ice + 50 or 100
    voy.hull.ice = percentage
    voy.hull.seaweed = 0
    voyage_draw_hull_upper(voy.coordinates, voyage_fade_RGB(col.fade, col.ice, percentage), win.."underlay")
    voyage_print_map()
end
--------------------------------------------------------------------------------
--   SERPENT
--------------------------------------------------------------------------------
function on_trigger_voyage_serpent_attack_on_you(name, line, wildcards, styles)
    local directions = {["fore"] = "n", ["starboard fore"] = "ne", ["starboard"] = "e", ["starboard aft"] = "se", ["aft"] = "s", ["port aft"] = "sw", ["port"] = "w", ["port fore"] = "nw",}
    voy.serpent = {direction = directions[wildcards.nautical] or true, room = voy.sequence[1]}
    voyage_print_map()
end

function on_trigger_voyage_serpent_attack_on_other(name, line, wildcards, styles)
    voy.serpent = true
    voyage_print_map()
end

function on_trigger_voyage_serpent_attack_off(name, line, wildcards, styles)
    voy.serpent = false
    voyage_print_map()
end

function on_trigger_voyage_serpent_attack_off_command_fail(name, line, wildcards, styles)
    voy.serpent = false
    table.remove(voy.commands.move, 1)
    voyage_construct_seq()
    voyage_print_map()
end
--------------------------------------------------------------------------------
--   KRAKEN
--------------------------------------------------------------------------------
function on_trigger_voyage_kraken_attack_on_you(name, line, wildcards, styles)
    local directions = {["fore"] = "n", ["starboard fore"] = "ne", ["starboard"] = "e", ["starboard aft"] = "se", ["aft"] = "s", ["port aft"] = "sw", ["port"] = "w", ["port fore"] = "nw",}
    voy.kraken = {direction = directions[wildcards.nautical] or true, room = voy.sequence[1]}   
    voyage_print_map()
end

function on_trigger_voyage_kraken_attack_on_other(name, line, wildcards, styles)
    voy.kraken = true
    voyage_print_map()
end

function on_trigger_voyage_kraken_attack_off(name, line, wildcards, styles)
    voy.kraken = false
    voyage_print_map()
end

function on_trigger_voyage_kraken_attack_off_command_fail(name, line, wildcards, styles)
    voy.kraken = false
    table.remove(voy.commands.move, 1)
    voyage_construct_seq()
    voyage_print_map()
end
--------------------------------------------------------------------------------
--   ROPE
--------------------------------------------------------------------------------
function on_trigger_voyage_rope_condition(name, line, wildcards, styles)
    local condition = wildcards.condition
    if not(voy.rope.railing) then
        voy.rope.railing = voy.sequence[1]
    end
    if condition:match("thread") then
        voy.rope.condition = 3
    elseif condition:match("very") then
        voy.rope.condition = 2
    elseif condition:match("frayed") then
        voy.rope.condition = 1
    else
        voy.rope.condition = 0
    end
    voyage_print_map()
end

function on_trigger_voyage_rope_on(name, line, wildcards, styles)
    voy.rope.railing = voy.sequence[1]
    voy.rope.condition = 0
    voyage_print_map()
end

function on_trigger_voyage_rope_off(name, line, wildcards, styles)
    voy.rope.railing = false
    voy.rope.condition = 0
    voyage_print_map()
end

function on_trigger_voyage_rope_first(name, line, wildcards, styles)
    voy.rooms[voy.sequence[1]].rope = {}
    local condition = wildcards.condition
    if condition:match("thread") then
        condition = 3
    elseif condition:match("very") then
        condition = 2
    elseif condition:match("frayed") then
        condition = 1
    else
        condition = 0
    end
    if wildcards.tying == "" then
        table.insert(voy.rooms[voy.sequence[1]].rope, {untied = true, condition = condition})
    else
        table.insert(voy.rooms[voy.sequence[1]].rope, {untied = false, condition = condition})
    end
end

function on_trigger_voyage_rope(name, line, wildcards, styles)
    local condition = wildcards.condition
    if condition:match("thread") then
        condition = 3
    elseif condition:match("very") then
        condition = 2
    elseif condition:match("frayed") then
        condition = 1
    else
        condition = 0
    end
    if wildcards.tying == "" then
        table.insert(voy.rooms[voy.sequence[1]].rope, {untied = true, condition = condition})
    else
        table.insert(voy.rooms[voy.sequence[1]].rope, {untied = false, condition = condition})
    end
end

function on_trigger_voyage_crate_first(name, line, wildcards, styles)
    voy.rooms[voy.sequence[1]].crate = {}
    if wildcards.tied == "" then
        table.insert(voy.rooms[voy.sequence[1]].crate, true)
    else
        table.insert(voy.rooms[voy.sequence[1]].crate, false)
    end
end

function on_trigger_voyage_crate(name, line, wildcards, styles)
    if wildcards.tied == "" then
        table.insert(voy.rooms[voy.sequence[1]].crate, true)
    else
        table.insert(voy.rooms[voy.sequence[1]].crate, false)
    end
end
--------------------------------------------------------------------------------
--   MAST / SHELVES
--------------------------------------------------------------------------------
function voyage_mast_down(name, line, wildcards, styles)
    local room = voy.sequence[1]
    if room == 6 then
        voy.rooms[room].smashed = true
		voy.rooms[room].objects.boards = voy.rooms[room].objects.boards + 20
		voyage_print_map()
    end
end
  
function voyage_shelf_down(name, line, wildcards, styles)
    local room = voy.sequence[1]
    if room == 13 or room == 16 or room == 19 then
        voy.rooms[room].smashed = true
		voy.rooms[room].objects.boards = voy.rooms[room].objects.boards + 20
		voyage_print_map()
    end
end
