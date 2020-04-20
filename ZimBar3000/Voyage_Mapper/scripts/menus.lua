--------------------------------------------------------------------------------
--   TITLE
--------------------------------------------------------------------------------
function voyage_get_title_menu()
    local options = {}
    local menu = "!^Voyage Mapper v"..GetPluginInfo (GetPluginID (), 19)
    menu = menu.."||Help||Configure|"
    table.insert(options, function()
        on_alias_voyage_help()
    end)
    table.insert(options, function()
        on_alias_voyage_configure()
    end)
    result = string.lower(WindowMenu(win, 
      WindowInfo(win, 14), --x
      WindowInfo(win, 15), --y
      menu))
    if result ~= "" then
        options[tonumber(result)]()
    end
end
--------------------------------------------------------------------------------
--   ROOMS
--------------------------------------------------------------------------------
function voyage_get_room_menu(room)
    local options = {}
    local current_room, trajectory_room = voy.sequence[1], voy.sequence[#voy.sequence]
    local menu = "|look|"
    table.insert(options, function()
        if room == current_room then
            Send("look")
        else
            voyage_get_shortest_path(voy.rooms, trajectory_room, room, "look")
        end
    end)
    if room == 21 then
        menu = menu.."|board||repair hull||cut seaweed|break ice|"
        table.insert(options, function()
            voyage_get_shortest_path(voy.rooms, trajectory_room, room)
            voy.commands.move.count = (voy.commands.move.count or 0) + 1
            Send("board")
            table.insert(voy.sequence, voy.rooms[21].board.board)
            voyage_print_map()
        end)
        table.insert(options, function()
            voyage_get_shortest_path(voy.rooms, trajectory_room, room);Send("repair hull with boards and nails")
        end)
        table.insert(options, function()
            local seaweed_tool = held.seaweed == "" and "knife" or held.seaweed
            voyage_get_shortest_path(voy.rooms, trajectory_room, room);Send("cut seaweed with held "..seaweed_tool)
        end)
        table.insert(options, function()
            local ice_tool = held.ice == "" and "knife" or held.ice
            voyage_get_shortest_path(voy.rooms, trajectory_room, room);Send("break ice with held "..ice_tool)
        end)
    end
    if room <= 20 then
        menu = menu.."|^double-click:|"..(voy.doubleclick.selected == 1 and "+" or "").."pour buckets|"..(voy.doubleclick.selected == 2 and "+" or "").."stomp fire|"..(voy.doubleclick.selected == 3 and "+" or "").."break ice|"..(voy.doubleclick.selected == 4 and "+" or "").."hit dragon|"
        for i = 1, 4, 1 do
            table.insert(options, function()
                voyage_get_shortest_path(voy.rooms, trajectory_room, room)
                voy.doubleclick.selected = i
            end)
        end
    end
    if room == 13 or room == 16 or room == 19 then
        menu = menu.."|look junk|-|^search Weapons:|"
        table.insert(options, function()
            voyage_get_shortest_path(voy.rooms, trajectory_room, room);Send("look junk")
        end)
        for k, v in pairs(voy.rooms[room].junk.fight) do
            menu = menu.."|"..k
            table.insert(options, function()
                voyage_get_shortest_path(voy.rooms, trajectory_room, room);Send("search "..k)
            end)
        end
        menu = menu.."|-|^search deck Items:|"
        for k, v in pairs(voy.rooms[room].junk.deck) do
            menu = menu.."|"..k
            table.insert(options, function()
                voyage_get_shortest_path(voy.rooms, trajectory_room, room);Send("search "..k)
            end)
        end
        menu = menu.."|-|^search boiler items:|"
        for k, v in pairs(voy.rooms[room].junk.boilers) do
            menu = menu.."|"..k
            table.insert(options, function()
                voyage_get_shortest_path(voy.rooms, trajectory_room, room);Send("search "..k)
            end)
        end
        menu = menu.."|"
    end
    if room == 1 then
        menu = menu.."|hold wheel|"
        table.insert(options, function()
            voyage_get_shortest_path(voy.rooms, trajectory_room, room);Send("hold wheel");Send("look sea")
        end)
    end
    if not(room == 3) and room <= 10 then
        menu = menu.."|look ropes|"
        table.insert(options, function()
            voyage_get_shortest_path(voy.rooms, trajectory_room, room);Send("look ropes")
        end)
    end
    if not(room <= 10 or room == 13 or room == 16 or room >= 18) then
        menu = menu.."|look ropes/cargo|>tie cargo "
        table.insert(options, function()
            voyage_get_shortest_path(voy.rooms, trajectory_room, room);Send("look cargo");Send("look ropes")
        end)
        local crates = 0
        for i, v in ipairs(voy.rooms[room].crate) do
            if v then crates = crates + 1 end
        end
        local ropes = 0
        for i, v in ipairs(voy.rooms[room].rope) do
            if v.untied then ropes = ropes + 1 end
        end
        local tied = #voy.rooms[room].crate - crates
        if #voy.rooms[room].crate == 0 then
            menu = menu.."(0/0)|"
        else
            menu = menu.."("..tied.."/"..#voy.rooms[room].crate..")|"
        end
        if ropes > 0 and crates > 0 then
            for i = 1, crates do
                menu = menu..(i).."|"
                table.insert(options, function()
                    voyage_get_shortest_path(voy.rooms, trajectory_room, room)
                    local crates_to_tie, rope_to_use = {}, 1
                    for ii, v in ipairs(voy.rooms[room].crate) do
                        if v then table.insert(crates_to_tie, ii) end
                        if #crates_to_tie == i then break end
                    end
                    for ii, v in ipairs(voy.rooms[room].rope) do
                        if v.untied and voy.rooms[room].rope[rope_to_use] and voy.rooms[room].rope[rope_to_use].condition > v.condition then
                            rope_to_use = ii
                        end
                    end
                    local s = "tie "
                    for ii, v in ipairs(crates_to_tie) do
                        s = s.."crate "..v..(ii == #crates_to_tie and "" or ",")
                    end
                    s = s.." down with rope "..rope_to_use
                    Send(s)
                end)
            end
        end
        menu = menu.."<|>untie ropes|"
        tied = #voy.rooms[room].rope - ropes
        ropes = {{},{},{}};ropes[0] = {} -- 0 through 3
        for i, v in ipairs(voy.rooms[room].rope) do
            if not v.untied then
                table.insert(ropes[v.condition], i)
            end
        end
        local conditions = {"excellent", "frayed", "very frayed", "poor"}
        for i, v in ipairs(conditions) do
            if #ropes[i - 1] > 0 then
                table.insert(options, function()
                    voyage_get_shortest_path(voy.rooms, trajectory_room, room)
                    local s = "untie "
                    for ii, vv in ipairs(ropes[i - 1]) do
                        s = s.."rope "..vv..(ii == #ropes[i - 1] and "" or ",")
                    end
                    Send(s)
                end)
            else
                menu = menu.."^"
            end
            menu = menu..v.."|"
        end
        menu = menu.."<|"
    end
    if room <= 10 and room ~= 3 and room ~= 6 and room ~= 9 then
        menu = menu..(voy.rope.railing and "+" or "").."tie railing|"
        table.insert(options, function()
            voyage_get_shortest_path(voy.rooms, trajectory_room, room)
            if voy.rope.railing then
                Send("untie rope")
            else
                Send("tie me to railing with rope")
            end
        end)

    end
    if room == 3 then
        menu = menu.."|look compass|look charts|"
        table.insert(options, function()
            voyage_get_shortest_path(voy.rooms, trajectory_room, room);Send("look compass")
        end)
        table.insert(options, function()
            voyage_get_shortest_path(voy.rooms, trajectory_room, room);Send("look charts")
        end)
    end
    if room == 6 then
        menu = menu.."|"..(voy.rooms[room].smashed and "^" or "").."climb mast"
        if not voy.rooms[room].smashed then
            table.insert(options, function()
                voyage_get_shortest_path(voy.rooms, trajectory_room, room);Send("climb mast")
            end)
        end
        menu = menu.."|"..(voy.rooms[room].smashed and "^" or "").."smash mast|"
        if not voy.rooms[room].smashed then
            table.insert(options, function()
                voyage_get_shortest_path(voy.rooms, trajectory_room, room);Send("smash mast with axe")
            end)
        end
    end
    if room == 13 or room == 16 or room == 19 then
        menu = menu.."|"..(voy.rooms[room].smashed and "^" or "").."smash table|"
        if not voy.rooms[room].smashed then
            table.insert(options, function()
                voyage_get_shortest_path(voy.rooms, trajectory_room, room);Send("smash table with axe")
            end)
        end
    end
    if room == 18 or room == 20 then
        menu = menu.."|look boiler|fill boiler|pull lever|"
        table.insert(options, function()
            voyage_get_shortest_path(voy.rooms, trajectory_room, room);Send("look boiler")
        end)
        table.insert(options, function()
            voyage_get_shortest_path(voy.rooms, trajectory_room, room);Send("fill boiler from tank");Send("bury empty tanks")
        end)
        table.insert(options, function()
            voyage_get_shortest_path(voy.rooms, trajectory_room, room);Send("pull lever")
        end)
    end
    if room <= 20 then
        menu = menu.."|drop dragon|>get dragon"
        table.insert(options, function()
            voyage_get_shortest_path(voy.rooms, trajectory_room, room);Send("drop dragons")
        end)
        for _, v in ipairs({[1] = "dragon", [2] = "aggy", [3] = "idiot", [4] = "bitey", [5] = "nugget"}) do
            menu = menu.."|"..v
            table.insert(options, function()
                voyage_get_shortest_path(voy.rooms, trajectory_room, room);Send("get "..v)
            end)
        end
        menu = menu.."|<|"
    end
    local deck = "ropes&nails&boards&unheld carpenter's hammers&buckets&towels&lemons"
    local weapons = "unheld steel-tipped harpoons&unheld fire axes&unheld arbalests&unheld arbalest bolts&bandages"
    local boiler = "unheld control rods&toys&every shoe polish&every coal&brown bottles except klein bottles"
        menu = menu.."|^drop items:|all|deck|weapons|boiler|"
        for i, v in ipairs({[1] = deck.."&"..weapons.."&"..boiler, [2] = deck, [3] = weapons, [4] = boiler}) do
            table.insert(options, function()
                voyage_get_shortest_path(voy.rooms, trajectory_room, room);Send("drop "..v)
            end)
        end
    if room <= 20 then
        menu = menu.."|^get items:|all|deck|weapons|boiler|"
        for i, v in ipairs({[1] = deck.."&"..weapons.."&"..boiler, [2] = deck, [3] = weapons, [4] = boiler}) do
            table.insert(options, function()
                voyage_get_shortest_path(voy.rooms, trajectory_room, room);Send("get "..v)
            end)
        end
    end
    if room >= 11 and room <= 20 then
        menu = menu.."|"..(voy.drag.on and voy.drag.object:match("tank") and "+" or "").."drag tank|"
        table.insert(options, function()
            if voy.drag.on and voy.drag.object:match("tank") then
                voyage_get_shortest_path(voy.rooms, trajectory_room, room)
                voy.drag.on = false
                ColourNote(voy.colours.notes.text, voy.colours.notes.background, 'Drag: off')
            else
                voyage_get_shortest_path(voy.rooms, trajectory_room, room)
                voy.drag = {object = "tank", on = true}
                ColourNote(voy.colours.notes.text, voy.colours.notes.background, 'Drag: "tank"')
            end
        end)
        menu = menu..(voy.drag.on and voy.drag.object:match("crate") and "+" or "").."drag crate|"
        table.insert(options, function()
            if voy.drag.on and voy.drag.object:match("crate") then
                voy.drag.on = false
                ColourNote(voy.colours.notes.text, voy.colours.notes.background, 'Drag: off')
            else
                voy.drag = {object = "crate", on = true}
                ColourNote(voy.colours.notes.text, voy.colours.notes.background, 'Drag: "crate"')
            end
        end)
    end
    menu = string.gsub(menu, "%W%l", string.upper):sub(2);menu = "!"..menu
    result = string.lower(WindowMenu(win, 
      WindowInfo(win, 14), --x
      WindowInfo(win, 15), --y
      menu))
    if result ~= "" then
        options[tonumber(result)]()
    end
end
--------------------------------------------------------------------------------
--   OBJECTS
--------------------------------------------------------------------------------
function voyage_get_object_menu(object, column)
    local room = voy.look_room or voy.sequence[1]
    local function move_to(trajectory_room, look_room)
        if look_room then
            return function() voyage_get_shortest_path(voy.rooms, trajectory_room, look_room) end
        else
            return function() end
        end
    end
    local f = move_to(voy.sequence[#voy.sequence], voy.look_room)
    local options = {}
    local menu = "|get all items||get "
    local deck = "ropes&nails&boards&carpenter's hammers&buckets&towels&lemons"
    local weapons = "steel-tipped harpoons&fire axes&arbalests&arbalest bolts&bandages"
    local boiler = "control rods&toys&every shoe polish&every coal&brown bottles"
    table.insert(options, function()
        f();Send("get "..deck.."&"..weapons.."&"..boiler)
    end)
    if column == 1 then
        menu = menu.."boiler items|"
        table.insert(options, function()
            f();Send("get "..boiler)
        end)
    elseif column == 2 then
        menu = menu.."deck items|"
        table.insert(options, function()
            f();Send("get "..deck)
        end)
    else
        menu = menu.."weapons|"
        table.insert(options, function()
            f();Send("get "..weapons)
        end)
    end
    menu = menu.."|drop "..object.."|"
    table.insert(options, function()
        f();Send("drop "..(object == "toys" and "toy animals" or object))
    end)
    if object == "tanks" then
        menu = menu.."|"..(voy.drag.on and voy.drag.object:match("tank") and "+" or "").."drag tank|"
        table.insert(options, function()
            f()
            if voy.drag.on and voy.drag.object:match("tank") then
                voy.drag.on = false
                ColourNote(voy.colours.notes.text, voy.colours.notes.background, 'Drag: off')
            else
                voy.drag = {object = "tank", on = true}
                ColourNote(voy.colours.notes.text, voy.colours.notes.background, 'Drag: "tank"')
            end
        end)
    else
        if voy.rooms[room].objects[object] > 0 then
            menu = menu.."|get "..object..":|"
            table.insert(options, function()
                f();Send("get "..object)
            end)
            for i = 1, voy.rooms[room].objects[object] <= 20 and voy.rooms[room].objects[object] or 20, 1 do
                menu = menu..tostring(i).."|"
				object = (object == "toys" and "toy animals") or object
                if i == 1 then
                    table.insert(options, function()
                        f();Send("get 1 "..object:gsub("s$", ""))
                    end)
                else
                    table.insert(options, function()
                        f();Send("get "..tostring(i).." "..object)
                    end)
                end
            end
        else
            menu = menu.."|^".."get "..object.."|"
        end
    end
    menu = string.gsub(menu, "%W%l", string.upper):sub(2);menu = "!"..menu
    result = string.lower(WindowMenu(win, 
      WindowInfo(win, 14), --x
      WindowInfo(win, 15), --y
      menu))
    if result ~= "" then
        options[tonumber(result)]()
    end
end

--------------------------------------------------------------------------------
--   VERTICAL TEXT
--------------------------------------------------------------------------------
function voyage_get_held_menu(hand)
    local options = {}
    local menu = "|"
    if held[hand] ~= "" then
        menu = menu.."+"..held[hand].."|"
        table.insert(options, function()
            voyage_hold_tool(hand, "")
        end)
    end
    for k, v in pairs(held.tools) do
        if k ~= held[hand] then
            menu = menu..k.."|"
            table.insert(options, function()
                voyage_hold_tool(hand, k)
            end)
        end
    end
    menu = menu.."|>edit tools|>add tool|"
        if held.tools[held[hand]] then
           menu = menu.."^"
        else
            table.insert(options, function()
                held.tools[held[hand]] = "inventory"
                ColourNote(voy.colours.notes.text, voy.colours.notes.background, "Tool: '"..held[hand].."' has been added.")
            end)
        end
        menu = menu.."add "..held[hand].."|add new|"
        table.insert(options, function()
            ColourNote(voy.colours.notes.text, voy.colours.notes.background, 'Please enter entire tool name:')
            PasteCommand("voyage add tool = ")
        end)
    menu = menu.."<|>remove tool|"
    for k, v in pairs(held.tools) do
        menu = menu..k.."|"
        table.insert(options, function()
            held.tools[k] = nil
            ColourNote(voy.colours.notes.text, voy.colours.notes.background, "Tool: '"..k.."' has been removed.")
        end)     
    end
    menu = menu.."<||>set container|"
    for k, v in pairs(held.tools) do
        menu = menu..">"..k.."|"
        for i, vv in ipairs(held.containers) do
            if v == vv then
                menu = menu.."+"
                table.insert(options, function()
                    held.tools[k] = "inventory"
                    ColourNote(voy.colours.notes.text, voy.colours.notes.background, "Container: 'inventory' set for tool: '"..k..".'")
                end)
            else
                table.insert(options, function()
                    held.tools[k] = vv
                    ColourNote(voy.colours.notes.text, voy.colours.notes.background, "Container: '"..vv.."' set for tool: '"..k..".'")
                end) 
            end
            menu = menu..vv.."|"
        end
        menu = menu.."<|"
    end
    menu = menu.."<|<||>edit containers|add new container|>remove container|"
    table.insert(options, function()
        ColourNote(voy.colours.notes.text, voy.colours.notes.background, 'Please enter entire container name:')
        PasteCommand("voyage add container = ")
    end)
    for i, v in ipairs(held.containers) do
        if v == "inventory" or v == "scabbard" or v == "floor" then
            menu = menu.."^"
        else
            table.insert(options, function()
                table.remove(held.containers, i)
                ColourNote(voy.colours.notes.text, voy.colours.notes.background, "Container: '"..v.."' has been removed.")
                for k, vv in pairs(held.tools) do
                    if v == vv then
                        held.tools[k] = "inventory"
                        ColourNote(voy.colours.notes.text, voy.colours.notes.background, "Container: 'inventory' set for tool: '"..k..".'")
                    end
                end
            end)
        end
        menu = menu..v.."|"
    end
    menu = menu.."<|<||>set ice-breaker|"
        menu = menu.."+"..(held.ice == "" and "knife|" or held.ice.."|")
        table.insert(options, function()
            held.ice = ""
            ColourNote(voy.colours.notes.text, voy.colours.notes.background, "Tool: 'knife' (default) set for ice-breaker.")
        end)
        for k, v in pairs(held.tools) do
            if k ~= held.ice then
                menu = menu..k.."|"
                table.insert(options, function()
                    held.ice = k
                    ColourNote(voy.colours.notes.text, voy.colours.notes.background, "Tool: '"..k.."' set for ice-breaker.")
                end)
            end
        end
    menu = menu.."<|>set weed-cutter|"
        menu = menu.."+"..(held.seaweed == "" and "knife|" or held.seaweed.."|")
        table.insert(options, function()
            held.seaweed = ""
            ColourNote(voy.colours.notes.text, voy.colours.notes.background, "Tool: 'knife' (default) set for weed-cutter.")
        end)
        for k, v in pairs(held.tools) do
            if k ~= held.seaweed then
                menu = menu..k.."|"
                table.insert(options, function()
                    held.seaweed = k
                    ColourNote(voy.colours.notes.text, voy.colours.notes.background, "Tool: '"..k.."' set for weed-cutter.")
                end)
            end
        end
    menu = menu.."<|"
    menu = string.gsub(menu, "[-|^+>< ]%l", string.upper):sub(2);menu = "!"..menu
    result = string.lower(WindowMenu(win, 
      WindowInfo(win, 14), --x
      WindowInfo(win, 15), --y
      menu))
    if result ~= "" then
        options[tonumber(result)]()
    end
end
--------------------------------------------------------------------------------
--   COMPASS (STEERING-MODE)
--------------------------------------------------------------------------------
function voyage_get_compass_menu(id)
    local options = {}
    local menu = "!^orientation:|"
    local directions = {"hubwards", "widdershins-hubwards", "widdershins", "widdershins-rimwards", "rimwards", "turnwise-rimwards", "turnwise", "turnwise-hubwards"}
    local dir = {"H", "WH", "W", "WR", "R", "TR", "T", "TH"}
    for i, v in ipairs(directions) do
        menu = menu.."|"..(dir[i] == voy.heading and "+" or "")..v
        table.insert(options, function()
            voy.heading = dir[i]
            voyage_print_map()
        end)
    end
    menu = string.gsub(menu, "%W%l", string.upper):sub(2);menu = "!"..menu
    result = string.lower(WindowMenu(win, 
        WindowInfo(win, 14), --x
        WindowInfo(win, 15), --y
        menu))
    if result ~= "" then
        options[tonumber(result)]()
    end
end
--------------------------------------------------------------------------------
--   SEA (STEERING-MODE)
--------------------------------------------------------------------------------
function voyage_get_sea_menu()
    local options = {}
    local menu = "!look overboard|"..(voy.is_night and "^" or "").."look sun|"..(voy.is_night and "" or "^").."look stars|"
 	table.insert(options, function()
		Send("look overboard")
	end)
 	table.insert(options, function()
		Send("look "..(voy.is_night and "stars" or "sun"))
	end)      
    menu = menu.."look here||"
 	table.insert(options, function()
		Send("look")
	end) 
    menu = menu.."OB and resume||"
 	table.insert(options, function()
		local commands = {"overboard", "board", "hold wheel", "look sea"}
		for i, v in ipairs(commands) do
			Execute(v)
		end
	end)      
    menu = menu.."repair hull||"
	table.insert(options, function()
		local commands = {"overboard", "repair hull with boards and nails", "board", "hold wheel", "look sea"}
		for i, v in ipairs(commands) do
			Execute(v)
		end
	end)   
    menu = menu.."cut seaweed|"  
	table.insert(options, function()
		local seaweed_tool = held.seaweed == "" and "knife" or held.seaweed
		local commands = {"overboard", "cut seaweed with held "..seaweed_tool, "board", "hold wheel", "look sea"}
		for i, v in ipairs(commands) do
			Execute(v)
		end
	end)       
    menu = menu.."break ice||"
	table.insert(options, function()
		local ice_tool = held.ice == "" and "knife" or held.ice
		local commands = {"overboard", "break ice with held "..ice_tool, "board", "hold wheel", "look sea"}
		for i, v in ipairs(commands) do
			Execute(v)
		end
	end)
	menu = menu.."look compass|"
	table.insert(options, function()
		local commands = {"sw", "e", "look compass", "e", "nw", "hold wheel", "look sea"}
		for i, v in ipairs(commands) do
			Execute(v)
		end
	end)
	menu = menu.."look charts|"
	table.insert(options, function()
		local commands = {"sw", "e", "look charts", "e", "nw", "hold wheel", "look sea"}
		for i, v in ipairs(commands) do
			Execute(v)
		end
	end)
	menu = menu.."look both||"
	table.insert(options, function()
		local commands = {"sw", "e", "look compass", "look charts", "e", "nw", "hold wheel", "look sea"}
		for i, v in ipairs(commands) do
			Execute(v)
		end
	end)
	menu = menu.."report stage|"
	table.insert(options, function()
		Send("group say "..voy.stage.."!")
	end)
    menu = string.gsub(menu, "%W%l", string.upper):sub(2);menu = "!"..menu
    result = string.lower(WindowMenu(win, 
        WindowInfo(win, 14), --x
        WindowInfo(win, 15), --y
        menu))
    if result ~= "" then
        options[tonumber(result)]()
    end
end
--------------------------------------------------------------------------------
--   DRAGON CIRCLES/GUAGES
--------------------------------------------------------------------------------
function voyage_get_circle_menu(room)
    local options = {}
    local menu = "|^circle:||"
    local trajectory_room = voy.sequence[#voy.sequence]
    local dragons = {[1] = "aggy the pale green swamp dragon", [2] = "idiot the bright red swamp dragon", [3] = "nugget the dark purple swamp dragon", [4] = "bitey the sky blue swamp dragon",}
    for _, v in ipairs(dragons) do
        local d = v:match("^(%w+)")
        if voy.dragon[d].circle then
            if voy.rooms[room].dragons[v] and voy.rooms[room].dragons[v] then
                menu = menu.."+"
                table.insert(options, function()
                    voyage_get_shortest_path(voy.rooms, trajectory_room, room);Send("get "..d);Send("drop "..d);
                end)
            else
                menu = menu.."^"
            end
        else
            local elsewhere = false
            for i, v2 in ipairs(voy.population) do
                if voy.rooms[v2.room].dragons[v] then
                    if v2.room ~= room then
                        elsewhere = true
                        menu = menu.."^"; break
                    end
                end
            end
            if not elsewhere then
                table.insert(options, function()
                    voyage_get_shortest_path(voy.rooms, trajectory_room, room);Send("get "..d);Send("place "..d.." in circle");
                end)
            end
        end
        menu = menu..d.."|"
    end
    menu = menu.."|^sleep:||"
    for _, v in ipairs(dragons) do
        local d = v:match("^(%w+)")
        if voy.dragon[d].asleep then
            if voy.rooms[room].dragons[v] and voy.rooms[room].dragons[v] then
                menu = menu.."+"
                table.insert(options, function()
                    voyage_get_shortest_path(voy.rooms, trajectory_room, room);Send("wake "..d)
                end)
            else
                menu = menu.."^"
            end
        else
            local elsewhere = false
            for i, v2 in ipairs(voy.population) do
                if voy.rooms[v2.room].dragons[v] then
                    if v2.room ~= room then
                        elsewhere = true
                        menu = menu.."^"; break
                    end
                end
            end
            if not elsewhere then
                table.insert(options, function()
                    voyage_get_shortest_path(voy.rooms, trajectory_room, room)
                    if voy.dragon[d] and voy.dragon[d].circle then
                        Send("get "..d);Send("drop "..d)
                    end
                    Send("hit "..d.." with control rod")
                end)
            end
        end
        menu = menu..d.."|"
    end
    menu = string.gsub(menu, "%W%l", string.upper):sub(2);menu = "!"..menu
    result = string.lower(WindowMenu(win, 
      WindowInfo(win, 14), --x
      WindowInfo(win, 15), --y
      menu))
    if result ~= "" then
        options[tonumber(result)]()
    end
end

function voyage_get_dragon_menu(dragon)
    local options = {}
    local menu = "|^feed "..dragon..":|"
    menu = menu.."|coal|polish|bottle|"
    table.insert(options, function()
        Send("feed coal to "..dragon)
    end)
    table.insert(options, function()
        Send("feed polish to "..dragon)
    end)
    table.insert(options, function()
        Send("feed bottle to "..dragon)
    end)
    menu = menu.."|^play:||toy|ball|"
    table.insert(options, function()
        Send("squeeze animal")
    end)
    table.insert(options, function()
        Send("throw toy ball")
    end)
    if voy.dragon[dragon].asleep then
        menu = menu.."|+sleep|"
        table.insert(options, function()
            Send("wake "..dragon)
        end)
    else
        menu = menu.."|sleep|"
        table.insert(options, function()
            if voy.dragon[dragon] and voy.dragon[dragon].circle then
                Send("get "..dragon);Send("drop "..dragon)
            end
            Send("hit "..dragon.." with control rod")
        end)
    end
    if voy.dragon[dragon].circle then
        menu = menu.."|+circle|"
        table.insert(options, function()
            Send("get "..dragon);Send("drop "..dragon);
        end)
    else
        menu = menu.."|circle|"
        table.insert(options, function()
            Send("get "..dragon);Send("place "..dragon.." in circle");
        end)
    end
    menu = menu.."|look|"
    table.insert(options, function()
        Send("look dragons")
    end)
    menu = string.gsub(menu, "%W%l", string.upper):sub(2);menu = "!"..menu
    result = string.lower(WindowMenu(win, 
      WindowInfo(win, 14), --x
      WindowInfo(win, 15), --y
      menu))
    if result ~= "" then
        options[tonumber(result)]()
    end
end
--------------------------------------------------------------------------------
--   MONSTERS
--------------------------------------------------------------------------------
function voyage_get_monster_menu(monster)
    local options = {}
    local menu = "|attack||reload||hold arbalests||>left|"
    table.insert(options, function()
        voyage_fire()
    end)
    table.insert(options, function()
        voyage_reload()
    end)  
    table.insert(options, function()
        voyage_hold_tool("L", "");voyage_hold_tool("R", "")
        Send("hold arbalests")
    end)
    for k, v in pairs(held.amo) do
        menu = menu..(k == held.reload.L and "+" or "")..k.."|"
        if k == held.reload.L then
            table.insert(options, function()
                held.reload.L = ""
                ColourNote(voy.colours.notes.text, voy.colours.notes.background, "Left hand set to not be used in reload.")
            end)
        else
            table.insert(options, function()
                held.reload.L = k
                ColourNote(voy.colours.notes.text, voy.colours.notes.background, "Left hand set to reload with: '"..k..".'")
            end)
        end
    end
    menu = menu.."<|>right|"
    for k, v in pairs(held.amo) do
        menu = menu..(k == held.reload.R and "+" or "")..k.."|"
        if k == held.reload.R then
            table.insert(options, function()
                held.reload.R = ""
                ColourNote(voy.colours.notes.text, voy.colours.notes.background, "Right hand set to not be used in reload.")
            end)
        else
            table.insert(options, function()
                held.reload.R = k
                ColourNote(voy.colours.notes.text, voy.colours.notes.background, "Right hand set to reload with: '"..k..".'")
            end)
        end
    end
    menu = menu.."<||>set container|"
    for k, v in pairs(held.amo) do
        menu = menu..">"..k.."|"
        for i, vv in ipairs(held.containers) do
            if vv ~= "scabbard" then
                if v == vv then
                    menu = menu.."+"
                    table.insert(options, function()
                        held.amo[k] = "inventory"
                        ColourNote(voy.colours.notes.text, voy.colours.notes.background, "Container: 'inventory' set for amo: '"..k..".'")
                    end)
                else
                    table.insert(options, function()
                        held.amo[k] = vv  
                        ColourNote(voy.colours.notes.text, voy.colours.notes.background, "Container: '"..vv.."' set for amo: '"..k..".'")
                    end)
                end
                menu = menu..vv.."|"
            end
        end
        menu = menu.."<|"
    end
    menu = string.gsub(menu, "[-|^+>< ]%l", string.upper):sub(2);menu = "!"..menu
    result = string.lower(WindowMenu(win, 
      WindowInfo(win, 14), --x
      WindowInfo(win, 15), --y
      menu))
    if result ~= "" then
        options[tonumber(result)]()
    end
end

