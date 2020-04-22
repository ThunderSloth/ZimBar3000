--------------------------------------------------------------------------------
--   SHORTEST PATH
--------------------------------------------------------------------------------
-- for auto-walking by mouseclick
function medina_get_shortest_path(graph, start_node, end_node, is_look) -- BFS
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
            for k, v in pairs(g[current].exit_rooms) do
                if not(visited[k]) then
                    if g[current].normalized[v] then
                        visited[k] = true
                        table.insert(queue, k)
                        g[k].parent = current
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
        local path_text = {}
        if solved then
            current = start_node
            for i, v in ipairs(path) do
                local direction = g[current].exit_rooms[v]
                if i == #path and is_look then
					on_alias_medina_look_room(name, line, {direction = direction})
                else
					on_alias_medina_move_room(name, line, {direction = direction})
                end
                current = v
            end
        else
            ColourNote("white", "black", "<", "red", "black", "No path found. Unlock more exits!", "white", "black", ">")
        end
    end
    return solved
end
