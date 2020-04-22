--------------------------------------------------------------------------------
--   SHORTEST PATH
--------------------------------------------------------------------------------
function smugs_get_shortest_path(graph, start_node, end_node) -- BFS
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
            for k, v in pairs(g[current].exits) do
                if not(visited[v]) then
                    visited[v] = true
                    table.insert(queue, v)
                    g[v].parent = current
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
                local direction = smu.rooms[current].path[v]
                on_alias_smugs_move_room('name', 'line', {direction = direction})
                current = v
            end
        else
            ColourNote("white", "black", "<", "red", "black", "No path found!", "white", "black", ">")
        end
    end
    return solved
end
