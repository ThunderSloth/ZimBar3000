--------------------------------------------------------------------------------
--   MOB TRACKING
--------------------------------------------------------------------------------
-- parse mobs/players and respective quantities from trigger matches
-- update room data accordingly and refresh map
function medina_get_mobs(wildcards, sign, room)
	local function get_quantity(mob)
		local number = {the = 1, two = 2, three = 3, four = 4, five = 5, six = 6, seven = 7, eight = 8, nine = 9, ten = 10, eleven = 11, twelve = 12, thirteen = 13, fourteen = 14, fifteen = 15, sixteen = 16, seventeen = 17, eighteen = 18, nineteen = 19, twenty = 20, many = 21,}
		mob = mob:gsub("^an? ", "the ")
		local n = ""
		if mob:match("^(%w+) (.*)") then
			n, mob = mob:match("^(%w+) (.*)")
		end
		n = number[n] or 1
		return mob, n
	end
	local function format_mobs(mob, n)
		if n == 1 then
			mob = mob:gsub("y$", "ies"):gsub("([^s])$", "%1s")
		end
		mob = mob:gsub("triad ", "")
		return mob
	end
	local room = room or med.sequence[1] or {}
	local text = string.lower(wildcards.thyngs)
	local direction = wildcards.direction or false
    -- direction if applicable
	if direction == "" then
		direction = false
	elseif direction then
		direction = medina_format_direction(direction)
		med.herd_path = {}
		for _, r in ipairs(med.sequence[1] or {}) do
			med.herd_path[r] = direction
		end
	end
	regex.verbiage:gmatch(text, function (_, t)
		text = text:gsub(t.verbiage, "")
	end)
    local is_players = false
    local population = {mobs = {thugs = 0, heavies = 0, boss =  0}, players = {},}
	local thyngs = ", "..text:gsub(" and ", ", ")
    -- get players with colours, mobs with quantities
	for thyng in string.gmatch(thyngs, '([^,]+)') do
		thyng = Trim(thyng)
		if med.players[thyng] then
			local player, p_colour = thyng, med.players[thyng]
			regex.titles:gmatch(player, function (_, t)
				player = player:gsub(t.title.." ", "")
			end)
			player = player:gsub("^([a-z']+) .*$", "%1")
			population.players[player] = p_colour
            is_players = true
		else
			local mob, n = get_quantity(thyng)
			mob = format_mobs(mob, n)
			if population.mobs[mob] then
                population.mobs[mob] = population.mobs[mob] + n
			end
		end
	end
    -- get player or mob trajectory
    local function get_trajectory_room(start_room, distance, direction)
        local end_room = {}
        for _, r in ipairs(start_room) do
            local path_room = r
            local rooms_moved = 0
            while 
                med.rooms[path_room].exits and 
                med.rooms[path_room].exits[direction] and 
                med.rooms[path_room].exits[direction].room and
                rooms_moved < distance
            do
                path_room = med.rooms[path_room].exits[direction].room
                rooms_moved = rooms_moved + 1
            end
            end_room[path_room] = true
        end
        return end_room
    end
    local distance = 
        is_player and 1 or population.mobs.thugs - 1 > 0 and population.mobs.thugs or 1
    for players_or_mobs, t in pairs(population) do
        -- in mobs, v contains quantity 
        -- in players, v contains player colour
        for name, v in pairs(t) do
            if players_or_mobs == "players" then
                -- remove from every room
                for r, _ in pairs(med.rooms) do
                    med.rooms[r].thyngs.players[name] = nil
                end
                -- if entering, add to room
                if sign > 0 then
                    for _, r in ipairs(room) do
                        med.rooms[r].thyngs.players[name] = v
                    end
                -- if exiting with direction, add to trajectory room
                elseif direction then
                    local trajectory_room = get_trajectory_room(room, distance, direction)
                    for r, _ in pairs(trajectory_room) do
                        med.rooms[r].thyngs.players[name] = v
                    end
                end
            elseif name == "boss" and v > 0 then
                local previous_boss_room = {}
                -- remove from every room
                for r, _ in pairs(med.rooms) do
                    if med.rooms[r].thyngs.mobs.boss > 0 then
                        -- we record previous room so that we know where to 
                        -- remove accompanying mobs from if entering
                        previous_boss_room[r] = true
                    end
                    med.rooms[r].thyngs.mobs.boss = 0
                end
                -- add or remove from room
                for _, r in ipairs(room) do
                   previous_boss_room[r] = nil
                   med.rooms[r].thyngs.mobs.boss = sign > 0 and 1 or 0
                end
                -- if entering, remove all mobs from previous room
                for r, _ in pairs(previous_boss_room) do
                    med.rooms[r].thyngs.mobs = {thugs = 0, heavies = 0, boss =  0}
                end
                -- if exiting with direction, add to trajectory room
                if direction then
                    local trajectory_room = get_trajectory_room(room, distance, direction)
                    for r, _ in pairs(trajectory_room) do
                        med.rooms[r].thyngs.mobs.boss = 1
                    end          
                end     
            elseif v > 0 then
               -- add or remove from room
                for _, r in ipairs(room) do
                    med.rooms[r].thyngs.mobs[name] = med.rooms[r].thyngs.mobs[name] + 
                    v * sign > 0 and med.rooms[r].thyngs.mobs[name] + v * sign or 0
                end
                -- if exiting with direction
                if direction then
                    local trajectory_room = get_trajectory_room(room, distance, direction)
                    for r, _ in pairs(trajectory_room) do
                        med.rooms[r].thyngs.mobs[name] =  med.rooms[r].thyngs.mobs[name] + v
                    end                
                end
            end
        end
    end
    medina_print_map()
end

function medina_set_follow_delay(previous_room, direction)
	if previous_room and direction then
		local rooms = ""
		local boss, heavies, thugs = 0, 0, 0
		for _, r in ipairs(previous_room) do
			boss = med.rooms[r].thyngs.mobs.boss
			heavies = med.rooms[r].thyngs.mobs.heavies
			thugs = med.rooms[r].thyngs.mobs.thugs
			if boss + thugs + heavies > 0 then
				rooms = rooms..r			
			end
		end
		if #rooms > 0 then
			local name = false
			for _, v in ipairs({rooms, direction, boss, heavies, thugs}) do
				name = name and name.."_"..tostring(v) or rooms
			end
			AddTimer(name, 0, 0, 5.25, "", timer_flag.Enabled + timer_flag.Replace + timer_flag.Temporary + timer_flag.OneShot, "medina_follow_delay")
		end
	end
end
		
function medina_follow_delay(name)
	local rooms, direction, boss, heavies, thugs = name:match("^(%w*)_(%w+)_(%d+)_(%d+)_(%d+)$")
	if rooms and  direction and boss and heavies and thugs then
		local mobs = {boss = boss, heavies = heavies, thugs = thugs}
		for k, v in pairs(mobs) do
			mobs[k] = tonumber(v)
		end
		local distance = mobs.thugs
		local current_room = {}
		for i, v in ipairs (med.sequence[1] or {}) do
			current_room[v] = true
		end
		rooms:gsub(".", function(start_room)
			is_player = false
			for k, _ in pairs(med.rooms[start_room].thyngs.players) do
				if k then 
					is_player = true
				end -- only if players are not present in the room
			end
			if not (is_player and current_room[start_room]) then
				local end_room = start_room
				local rooms_moved = 0
				local impeding = false
				while 
					med.rooms[end_room].exits and 
					med.rooms[end_room].exits[direction] and 
					med.rooms[end_room].exits[direction].room and
					rooms_moved < distance
				do
					end_room = med.rooms[end_room].exits[direction].room
					rooms_moved = rooms_moved + 1
					if current_room[end_room] then
						impeding = true
						break
					end
				end
				for k, v in pairs(mobs) do				
					local p = med.rooms[start_room].thyngs.mobs[k]
					local n = v
					if p - n < 0 then n = p end
					med.rooms[start_room].thyngs.mobs[k] = p - n
					if not impeding then
						local p = med.rooms[end_room].thyngs.mobs[k]
						local n = v
						med.rooms[end_room].thyngs.mobs[k] = p + n					
					end
				end				
				if med.is_in_medina then
					medina_print_map()
				end
			end
		end)
	end
end


