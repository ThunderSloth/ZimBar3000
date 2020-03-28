--------------------------------------------------------------------------------
--   JUNK PASRSING
--------------------------------------------------------------------------------
function on_trigger_voyage_junk_look(name, line, wildcards, styles)
    local objects = {
        deck = {
            ["coil of rope"] = "ropes",
            ["few nails"] = "nails",
            ["wooden board"] = "boards",
            ["carpenter's hammer"] = "hammers",
            ["fire bucket"] = "buckets",
            ["old linen towel"] = "towels",
            ["large lemon"] = "lemons",},
        boilers = {
            ["water tank"] = "tanks",
            ["control rod"] = "rods",
            ["squeaky toy animal"] = "toys",
            ["rubber toy ball"] = "balls",
            ["tin of shoe polish"] = "polish",
            ["lump of coal"] = "coal",
            ["bottle of rum"] = "bottles",},
        fight = {
            ["steel-tipped harpoon"] = "harpoons",
            ["fire axe"] = "axes",
            ["arbalest"] = "arbalests",
            ["arbalest bolt"] = "bolts",
            ["box of bandages"] = "bandages",},}
    local junk = ","..wildcards.junk:gsub(" and ", ", "):gsub(", ", ","):gsub("an? ", "")
    local current_room = voy.sequence[1]
    if current_room == 13 or current_room == 16 or current_room == 19 then
        voy.rooms[current_room].junk = {deck = {}, boilers = {}, fight = {},}
        for object in string.gmatch(junk, '[^,]+') do
            for k, v in pairs(objects) do
                if v[object] then 
                    voy.rooms[current_room].junk[k] = voy.rooms[current_room].junk[k] or {}
                    voy.rooms[current_room].junk[k][v[object]] = true
                end
            end
        end
    end
end

function on_trigger_voyage_junk_none(name, line, wildcards, styles)
    local current_room = voy.sequence[1]
    if current_room == 13 or current_room == 16 or current_room == 19 then
        voy.rooms[current_room].junk = {deck = {}, boilers = {}, fight = {},}
    end
end
--------------------------------------------------------------------------------
--   JUNK TRACKING
--------------------------------------------------------------------------------
function on_trigger_voyage_junk_find(name, line, wildcards, styles)
    local function get_object(object)
        local objects = {
            deck = {
                ["coils? of rope"] = "ropes",
                ["iron nails?"] = "nails",
                ["wooden boards?"] = "boards",
                ["carpenter's hammers?"] = "hammers",
                ["fire buckets?"] = "buckets",
                ["old linen towels?"] = "towels",
                ["juicy lemons?"] = "lemons",},
            boilers = {
                ["water tanks?"] = "tanks",
                ["control rods?"] = "rods",
                ["squeaky toy animals?"] = "toys",
                ["rubber toy balls?"] = "balls",
                ["tins? of shoe polish"] = "polish",
                ["lumps? of coal"] = "coal",
                ["large brown bottles?"] = "bottles",},
            fight = {
                ["steel[-]tipped harpoons?"] = "harpoons",
                ["fire axes?"] = "axes",
                ["arbalests?$"] = "arbalests",
                ["arbalest bolts?"] = "bolts",
                ["boxe?s? of bandages"] = "bandages",},}
        for k, t in pairs(objects) do
            for m, v in pairs(t) do
                if object:match(m) then 
                    return k, v
                end 
            end
        end
    end
    local current_room = voy.sequence[1]
    if current_room == 13 or current_room == 16 or current_room == 19 then
        local type, object = get_object(wildcards.object)
        if voy.rooms[current_room].junk[type] and voy.rooms[current_room].junk[type][object] then
            voy.rooms[current_room].junk[type][object] = nil
            if object == "tanks" then
                voyage_update_objects(voy.sequence[1], wildcards.quantity.." "..wildcards.object)
                voyage_print_map()
            end
        end
    end
end

