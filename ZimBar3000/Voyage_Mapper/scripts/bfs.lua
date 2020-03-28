--------------------------------------------------------------------------------
--   BREADTH-FIRST SEARCH
--------------------------------------------------------------------------------
function voyage_get_shortest_path(graph, start_node, end_node, is_look) -- map-data, start-room, end-room, travel to or just look?

	--sort by key length so that orthagonal directions will come before diagonal directions, creating a more human-like route   
	local function humanized_pairs(t1) 
        local t2 = {}
        for k, _ in pairs(t1) do table.insert(t2, k) end
            table.sort(t2, function(a,b)
                if string.len(a) == string.len(b) then
                    return a < b
                else
                    return string.len(a) < string.len(b) 
                end
            end)
        local i = 0
        return function() 
            i = i + 1
            if t2[i] then 
                return t2[i], t1[t2[i]] 
            end 
        end
    end
    -- duplicate graph so we don't alter our meta-table
    local function deepcopy(orig)
        local orig_type = type(orig)
        local copy
        if orig_type == 'table' then
            copy = {}
            for orig_key, orig_value in next, orig, nil do
                copy[deepcopy(orig_key)] = deepcopy(orig_value)
            end
            setmetatable(copy, deepcopy(getmetatable(orig)))
        else -- number, string, boolean, etc
            copy = orig
        end
        return copy
    end
    
    local g, solved = deepcopy(graph), false
    if start_node then
        local queue, visited, current = {}, {}, ""
        queue[1] = start_node
        visited[start_node] = true
        g[start_node].parent = false
        local commands = {}
        while #queue > 0 do
            current = queue[1]
            table.remove(queue, 1)
            if current == end_node then
                solved = true
                break
            end
            local exit_types = {"up", "down", "exits", "doors", "board", "overboard",}
            -- eliminate vertical movement when dragging because dragging upwards is impossible
            if voy.drag.on then table.remove(exit_types, 1);table.remove(exit_types, 1) end 
            for _, et in ipairs(exit_types) do
                if g[current][et] then
                    for dir, r in humanized_pairs(g[current][et]) do
                        if not(visited[r]) then
                            if r == 21 and current ~= 22 then
                                for k, _ in pairs(g[21].board) do
                                    g[21].board[k] = current
                                    voy.rooms[21].board[k] = current
                                end
                            end
                            visited[r] = true
                            table.insert(queue, r)
                            g[r].parent = current
                            if et ~= "exits" and et ~= "doors" then
                                commands[r] = et
                            else
                                commands[r] = dir
                            end
                        end
                    end 
                end
            end
        end
        local path, source_node = {}, g[end_node].parent
        while source_node do
            table.insert(path, 1, source_node)
            source_node = g[source_node].parent
        end
        table.insert(path, end_node);table.remove(path, 1)
        current = start_node
        local directions = {n = "fore", ne = "starboard fore", e = "starboard", se = "starboard aft", s = "aft", sw = "port aft", w = "port", nw = "port fore",}
        for i, v in ipairs(path) do
            if is_look and i == #path then
                local directions_2 = {["fore"] = "n", ["starboard fore"] = "ne", ["starboard"] = "e", ["starboard aft"] = "se", ["aft"] = "s", ["port aft"] = "sw", ["port"] = "w", ["port fore"] = "nw",}
                voy.commands.look.count = (voy.commands.look.count or 0) + 1 -- used in 'stop' handling
                table.insert(voy.commands.look, (directions_2[commands[v]] or commands[v]))
                Send("look "..(directions[commands[v]] or commands[v]))
            else
                voy.commands.move.count = (voy.commands.move.count or 0) + 1 -- used in 'stop' handling
                if voy.drag.on then
                    Send("drag "..voy.drag.object.." "..(directions[commands[v]] or commands[v]))
                else
                    Send(directions[commands[v]] or commands[v])
                end
                table.insert(voy.sequence, v)
            end
            current = v
        end
    end
    voyage_print_map()
end
