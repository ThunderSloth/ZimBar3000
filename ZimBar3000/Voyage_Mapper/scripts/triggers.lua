--------------------------------------------------------------------------------
--   TRIGGERS
--------------------------------------------------------------------------------
function voyage_get_triggers(col)
    -- room triggers are built here
    local desc = {
        long = { 
            "This is the foremost point of the ship.*",
            "The bridge, a small wooden room on the upper deck, lies through the door to starboard.*",
            "This is a spacious room atop the ship, meant for the captain to do his or her navigation from.*",
            "The bridge, a small wooden room perched atop the deck, lies through the door to port.*",
            "This is about halfway down the upper deck of the SS Unsinkable.*",
            "Here, in the middle of the upper deck.*",
            "duplicate of 5",
            "Aft of this point, the giant paddlewheel .* starboard corner.*",
            "The upper deck abruptly ends here.*",
            "Aft of this point, the giant paddlewheel .* port corner.*",
            "This is the front end of the lower deck of the SS Unsinkable.*",
            "This corner of the port side of the lower deck has been repurposed to hold a couple of dragon pens.*",
            "This is an incredibly cluttered storeroom.*",
            "This corner of the starboard side of the lower deck has been repurposed with a couple of dragon pens.*",
            "This is the middle .* hemmed in to starboard .*",
            "duplicate of 13",
            "This is the middle .* hemmed in to port .*",
            "The bulk of this corner .* port corridor, it seems like it wasn't in the original plans for the ship.",
            "duplicate of 13",
            "The bulk of this corner .* starboard corridor, it seems like it wasn't in the original plans for the ship.",
            "This expanse of water is the surface of the Circle Sea.* SS Unsinkable lies to the .*",
            "This is just under the surface of the Circle Sea.*",
            "Here, perched precariously at the top of the mast, the view is magnificent.  Wide expanses of ocean stretch out below you in all directions."},
        title = {
            "fore end of the upper deck",
            "port fore corner of the upper deck",
            "bridge of the SS Unsinkable",
            "starboard fore corner of the upper deck",
            "port side of the upper deck",
            "middle of the upper deck",
            "starboard side of the upper deck",
            "port aft corner of the upper deck",
            "aft end of the upper deck",
            "starboard aft corner of the upper deck",
            "fore corner of the lower deck",
            "port fore corner of the lower deck",
            "Store C",
            "starboard fore corner of the lower deck",
            "port corridor of the lower deck",
            "Store B",
            "starboard corridor of the lower deck",
            "port boiler room",
            "Store A",
            "starboard boiler room",
            "the Circle Sea near the SS Unsinkable",
            "the Circle Sea near the SS Unsinkable",
            "atop the mast",},
        sea = "([~@=^vn._?$*OGHP ]{9}\\n){9}",
        boat = "([-|\\\\\\/x&$@*+v^ ]+\\n){0,7}",
        scry = "(?<scry>(The crystal ball changes to show a vision of the area where .* is|The image in the crystal ball fades, but quickly returns showing a new area|You see a vision in the .*|You look through the .* (door|fur)|You see a vision in the silver mirror|You see):|You focus past the .* baton, and visualise the place you remembered\\.\\.\\.|You briefly see a vision\\.)",
        moon = "((It is night and|The (water|land) is lit up by) the.*(?<moon>(crescent|(three )?quarter|half|gibbous|no|full) moon)( is hidden by the clouds)?.\\n)?",
        condition = "((?<condition>.*)\\n)?",
        speed = "(The (paddlewheel behind the )?ship is .* (?<speed>(standstill|slowly|moderate|rapidly|blur)).*)\\n",
        monster = "((?<monster>A huge (kraken has its tentacles wrapped|sea serpent is coiled) around the ship, eyeing you hungrily.)\\n)?",
        hsac = ("(?<hsac>There is a (\\w+ ){1,3}of blood on the \\w+.\\n)?"),
        weather = "((?<weather>It is an? .*)\\n)",
        thunder = "((?<thunder>Peals of thunder.*)\\n)?",
        exits = "There (is|are) \\w+ obvious exits?: (?<exits>.*)\\.",
        condition_repeat = "(\\n\\k<condition>)?",
        thyngs = "(\\n(?<thyngs>.* (is|are) (\\w+ing (at attention|for food|in the small red circle|around curiously|on to the ship's wheel)|(knocked out |\\w+ing ([io]n the (\\w+ ){1,2})?)here|sprawled in a heap))\\.)?",
        objects = "(\\n(?<objects>.* ([Aa] small fire has started here.|Fire fills the room, burning merrily without regard for the structural integrity of the ship.|(is|are)( (sitting|mounted|lying|pinned|bolted|set|standing|stacked up|coiled|painted|tying( .*)?)|eagerly licking|filled)?( (on|in(to)?|to|at|beside|across|against|opposite|with))? (the (deck|floor( in front of the boiler|boards)?|ground|door|(.* )?walls?|prow|table|window|side of the cabin|pile of \\w+)|\\w+ (heap|small pile|railing|cargo crates? down securely|huge conflagration, sparks spilling out into the nearby rooms))\\.)))?",
        order = {"view", "moon", "long", "condition", "speed", "monster", "hsac", "weather", "thunder", "exits", "condition_repeat", "thyngs", "objects",},}
    desc.not_moon_line = desc.moon:gsub("[(][?]<moon>[(]crescent|[(]three [)][?]quarter|half|gibbous|no|full[)] moon[)]", "moon"):gsub("\\n[)][?]", ")"):gsub("^[(]", "(?!")

    desc.title[5] = desc.title[5]:gsub("port", "(?<side>port|starboard)")
    desc.title[13] = desc.title[13]:gsub("C", "(?<store>[A-C])")

    desc.view = {}
    for i, v in ipairs(desc.title) do
        if i > 20 and i < 23 then
            desc.view[i] = "^(\\[(?<title>"..desc.title[i]..")\\]\\n"..desc.sea.. "|"..desc.not_moon_line.."("..desc.scry.."|(?<look>.*))\\n)"   
        else
            desc.view[i] = "^(\\[(?<title>"..desc.title[i]..")\\]\\n"..desc.boat.."|"..desc.not_moon_line.."("..desc.scry.."|(?<look>.*))\\n)"
        end
        desc.long[i] = desc.long[i].."\\n"
    end

    for i, v in ipairs(desc.long) do
        desc.long[i] = "(?<description>"..v..")"
    end

    desc.outdoors = {}
    for i = 1, 10, 1 do
        if i ~= 3 then
            desc.outdoors[i] = true
        end
    end
    desc.outdoors[21] = true
    desc.outdoors[23] = true

    local triggers = {}
    for i = 1, #desc.long, 1 do
        local name = tostring(i)
        if i == 5 then
            name = "hatches"
        elseif i == 13 then
            name = "stores"
        end
        triggers[i] = {
            match = '',
            group ='voyage',
            name = 'on_trigger_voyage_room_'..name,
            script = 'on_trigger_voyage_room',
            multi_line = 'y',
            count = 0,
            keep_evaluating = 'y',
            regexp = 'y',
            sequence = '100',}
        for _, l in ipairs(desc.order) do
            if type(desc[l]) == "table" then
                triggers[i].match = triggers[i].match..desc[l][i]
                triggers[i].count = triggers[i].count + 1
            else
                if (desc.outdoors[i] or not(l == "moon" or l == "weather" or l == "thunder")) and not(l == "speed" and (i > 10 and i < 23)) then
                    if l == "exits" and i == 23 then
                        triggers[i].match = triggers[i].match.."There are no obvious exits.(?<exits>)"
                    else
                        triggers[i].match = triggers[i].match..desc[l]
                    end
                    triggers[i].count = triggers[i].count + 1
                end
            end
        end
        triggers[i].match = triggers[i].match..'\\Z'
        if i > 20 and i < 23 then
            triggers[i].count = triggers[i].count + 9 
        else
            triggers[i].count = triggers[i].count + 7
        end
    end
    triggers[7] = {}
    triggers[16] = {}
    triggers[19] = {}

    for i, v in pairs(triggers) do
        if v.match then
            AddTrigger(v.name, v.match, "", trigger_flag.KeepEvaluating + trigger_flag.IgnoreCase + trigger_flag.RegularExpression, custom_colour.NoChange, 0, "", v.script)
            SetTriggerOption (v.name, "group", v.group)
            SetTriggerOption (v.name, "multi_line", "y")
            SetTriggerOption (v.name, "lines_to_match", v.count)
            SetTriggerOption (v.name, "enabled", "n")
            local match_to_print = false -- for debugging regex
			if i == match_to_print then
				print(v.match)
			end
        end
    end
    -- add colouring to existing triggers
    triggers = {
        -- monsters
        voyage_serpent_attack_on_you = {col.thyngs.you, col.thyngs.serpent},
        voyage_serpent_attack_on_other = {col.notes.background, col.thyngs.serpent},
        voyage_serpent_attack_off = {col.thyngs.serpent, col.notes.background},
        voyage_serpent_attack_off_command_fail = {col.thyngs.serpent, col.notes.background},

        voyage_kraken_attack_on_you = {col.thyngs.you, col.thyngs.kraken},
        voyage_kraken_attack_on_other = {col.notes.background, col.thyngs.kraken},
        voyage_kraken_attack_off = {col.thyngs.kraken, col.notes.background},
        voyage_kraken_attack_off_command_fail = {col.thyngs.kraken, col.notes.background},
        -- rooms
        voyage_fire_on = {col.thyngs.you, col.rooms.fire},
        voyage_fire_grow = {col.thyngs.you, col.rooms.fire},
        voyage_fire_adjacent = {col.notes.background, col.rooms.fire},
        voyage_lightning_hit = {col.notes.background, col.thyngs.lightning},
        voyage_fire_shrink = {col.rooms.fire, col.notes.partial},
        voyage_fire_off = {col.rooms.fire, col.notes.background},

        voyage_ice_on = {col.thyngs.you, col.rooms.ice},
        voyage_ice_shrink = {col.rooms.ice, col.notes.partial},
        voyage_ice_off = {col.rooms.ice, col.notes.background},
        -- hull
        voyage_ice_hit = {col.notes.background, col.hull.ice},
        voyage_ice_fix_partial = {col.hull.ice, col.notes.partial},
        voyage_ice_fix = {col.hull.ice, col.notes.background},

        voyage_seaweed_hit = {col.notes.background, col.hull.seaweed},
        voyage_seaweed_fix_partial = {col.hull.seaweed, col.notes.partial},
        voyage_seaweed_fix = {col.hull.seaweed, col.notes.background},

        voyage_hull_damaged = {col.notes.background, col.hull.hull},
        voyage_hull_fix_partial = {col.hull.hull, col.notes.partial},
        voyage_hull_fix = {col.hull.hull, col.notes.background},
        -- whirlpool
        voyage_whirlpool = {col.notes.background, col.sea.whirlpool},
        -- crrents
        voyage_backwards_current = {col.notes.background, col.sea.current},}

    for k, v in pairs(triggers) do
        SetTriggerOption(k, "custom_colour", 17)
        SetTriggerOption(k, "colour_change_type", 0)
        SetTriggerOption(k, "other_text_colour", v[1])
        SetTriggerOption(k, "other_back_colour", v[2])
    end

end
