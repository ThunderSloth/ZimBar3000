--------------------------------------------------------------------------------
--   SHORTEST PATH
--------------------------------------------------------------------------------
function shades_get_shortest_path(graph, start_node, end_node) -- BFS
    local function humanized_pairs(t1) --sorts by key length so that orthagonal directions will come before diagonal directions, creating a more human-like route
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
        while #queue > 0 do
            current = queue[1]
            table.remove(queue, 1)
           if current == end_node then
                solved = true
               break
            end
            for _, i in humanized_pairs(g[current].normalized) do
                local r = g[current].exits[i]
                if not(visited[r]) then
                    visited[r] = true
                    table.insert(queue, r)
                    g[r].parent = current
                end
            end  
        end
        local path, source_node = {}, g[end_node].parent
        while source_node do
            table.insert(path, 1, source_node)
            source_node = g[source_node].parent
        end
        table.insert(path, end_node);table.remove(path, 1)
        local path_text = {}
        if solved then
            current = start_node
            for _, v in ipairs(path) do
                local direction = sha.rooms[current].path[v]
                on_alias_shades_move_room('name', 'line', {direction = direction})
                current = v
            end
        else
            ColourNote("white", "black", "<", "red", "black", "No path found!", "white", "black", ">")
        end
    end
    return solved
end

