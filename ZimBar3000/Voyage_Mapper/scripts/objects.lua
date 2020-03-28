--------------------------------------------------------------------------------
--   OBJECT PARSING
--------------------------------------------------------------------------------
function voyage_update_objects(room, text, is_subtract)
    local function to_num(text) -- replace written words with integers 
        local numbers = {"an?", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen", "twenty", "many"}
        for i, word in ipairs(numbers) do
            text = text:gsub(" "..word.." ", " "..i.." "):gsub("^"..word.." ", i.." "):gsub(" "..word.."$", " "..i)	
        end
        text = text:gsub(" the ", " 1 "):gsub("^the ", "1 "):gsub(" the$", " 1")
        return text
    end
    local objects = {
		-- deck
        ["coil of rope"] = "ropes",
        ["iron nail"] = "nails",
        ["wooden board"] = "boards",
        ["carpenter's hammer"] = "hammers",
        ["fire bucket"] = "buckets",
        ["old linen towel"] = "towels",
        ["juicy lemon"] = "lemons",
		-- boiler
        ["large water tank"] = "tanks",
        ["control rod"] = "rods",
        ["squeaky toy animal"] = "toys",
        ["rubber toy ball"] = "balls",
        ["tin of shoe polish"] = "polish",
        ["medium sized lump of coal"] = "coal",
        ["large brown bottle"] = "bottles",
		-- combat
        ["steel-tipped harpoon"] = "harpoons",
        ["fire axe"] = "axes",
        ["arbalest"] = "arbalests",
        ["arbalest bolt"] = "bolts",
        ["box of bandages"] = "bandages",}
    text = to_num(string.lower(text)):gsub(" and ", ", "):gsub("[.,] ", ","):gsub(" are ", " is ")
    for stuff in string.gmatch(text, '([^,]+)') do
        local n, s = stuff:gsub(" is .*", ""):match("^(%d+) (.*) ?$")
        n = tonumber(n) 
        if n and s then
            if is_subtract then
                n = -n
            end
            if objects[s] then
                local o = objects[s]
                voy.rooms[room].objects[o] = voy.rooms[room].objects[o] + n > 0 and voy.rooms[room].objects[o] + n or 0
            elseif objects[s:gsub("s$", "")] then
                local o = objects[s:gsub("s$", "")]
                voy.rooms[room].objects[o] = voy.rooms[room].objects[o] + n > 0 and voy.rooms[room].objects[o] + n or 0
            elseif objects[s:gsub("(%w+)%l of ", "%1 of ")] then -- i.e. 'medium sized lumpS of coal'
                local o = objects[s:gsub("(%w+)%l of ", "%1 of ")]
                voy.rooms[room].objects[o] = voy.rooms[room].objects[o] + n > 0 and voy.rooms[room].objects[o] + n or 0
            end
        end
    end
end
--------------------------------------------------------------------------------
--   OBJECT TRACKING
--------------------------------------------------------------------------------
-- get
function voyage_object_get(name, line, wildcards, styles)
    voyage_update_objects(voy.sequence[1], wildcards.objects, true)
    voyage_print_map()
end
-- drop
function voyage_object_drop(name, line, wildcards, styles)
    voyage_update_objects(voy.sequence[1], wildcards.objects)
    if wildcards.you ~= "" then
        on_trigger_voyage_tools_sheathe("", "", {tools = wildcards.objects}, "")
    end
    voyage_print_map()
end
-- bury
function voyage_object_bury(name, line, wildcards, styles)
    voyage_update_objects(voy.sequence[1], wildcards.objects, true)
    voyage_print_map()
end
-- drag: in
function voyage_object_tank_in(name, line, wildcards, styles)
    voyage_update_objects(voy.sequence[1], "a large water tank")
    voyage_print_map()
end
-- drag: out
function voyage_object_tank_out(name, line, wildcards, styles)
    voyage_update_objects(voy.sequence[1], "a large water tank", true)
    voyage_print_map()
end
