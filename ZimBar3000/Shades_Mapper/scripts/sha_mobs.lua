
--------------------------------------------------------------------------------
--   MOB TRACKING
--------------------------------------------------------------------------------
-- on any event of mobs/players entering/exiting a room
-- or looking at/moving to a room that is occupied by mobs/players
function on_trigger_shades_mob_track(name, line, wildcards, styles, room)
	local sign = name:match("exit") and -1 or 1
	shades_get_mobs(wildcards, sign, room)
end
-- parse mobs/players and respective quantities from trigger matches
-- update room data accordingly and refresh map
function shades_get_mobs(wildcards, sign, room)
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
		if mob:match("troll") then
			mob = "trolls"
		elseif mob:match("fighter") then
			mob = "fighters"
		elseif mob:match("mugger") then
			mob = "muggers"
		end
		return mob
	end
	local room = room or sha.sequence[1] or {}
	local text = string.lower(wildcards.thyngs)
	regex.verbiage:gmatch(text, function (_, t)
		text = text:gsub(t.verbiage, "")
	end)
    local is_players = false
    local population = {mobs = {trolls = 0, fighters = 0, muggers =  0}, players = {},}
	local thyngs = ", "..text:gsub(" and ", ", ")
    -- get players with colours, mobs with quantities
	for thyng in string.gmatch(thyngs, '([^,]+)') do
		thyng = Trim(thyng)
		if sha.players[thyng] then
			local player, p_colour = thyng, sha.players[thyng]
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
	
    for players_or_mobs, t in pairs(population) do
        -- in mobs, v contains quantity 
        -- in players, v contains player colour
        for name, v in pairs(t) do
            if players_or_mobs == "players" then
				for r, _ in pairs(sha.rooms) do
					sha.rooms[r].thyngs.players[name] = nil
				end
				if sign > 0 then
					for _, r in ipairs(room) do
						sha.rooms[r].thyngs.players[name] = v
					end
				end
			else
				for _, r in ipairs(room) do
					sha.rooms[r].thyngs.mobs[name] = sha.rooms[r].thyngs.mobs[name] + v * sign > 0 and sha.rooms[r].thyngs.mobs[name] + v * sign or 0
				end
            end
        end
    end
    shades_print_map()
end

function shades_set_follow_delay(previous_room, direction)
	if previous_room and direction then
		local rooms = ""
		local trolls, fighters, muggers = 0, 0, 0
		for _, r in ipairs(previous_room) do
			trolls = sha.rooms[r].thyngs.mobs.trolls 
			fighters = sha.rooms[r].thyngs.mobs.fighters 
			muggers = sha.rooms[r].thyngs.mobs.muggers 
			if trolls + fighters + muggers > 0 then
				rooms = rooms..r			
			end
		end
		if #rooms > 0 then
			local name = false
			for _, v in ipairs({rooms, direction, trolls, fighters, muggers}) do
				name = name and name.."_"..tostring(v) or rooms
			end
			AddTimer(name, 0, 0, 5.25, "", timer_flag.Enabled + timer_flag.Replace + timer_flag.Temporary + timer_flag.OneShot, "shades_follow_delay")
		end
	end
end

function shades_follow_delay(name)
	local rooms, direction, trolls, fighters, muggers = name:match("^(%w*)_(%d)_(%d+)_(%d+)_(%d+)$")
	if rooms and direction and trolls and fighters and muggers then
		direction = tonumber(direction)
		local mobs = {trolls = trolls, fighters = fighters, muggers = muggers}
		for k, v in pairs(mobs) do
			mobs[k] = tonumber(v)
		end
		local current_room = {}
		for i, v in ipairs (sha.sequence[1] or {}) do
			current_room[v] = true
		end
		rooms:gsub(".", function(start_room)
			local end_room = sha.rooms[start_room].exits[direction]
			local is_player = false
			for k, _ in pairs(sha.rooms[start_room].thyngs.players) do
				if r then 
					is_player = true
				end -- only if players are not present in the room
			end
			-- can not follow to entrance room, or if a player is in the room
			if end_room ~= 'G' and not is_player then
				for k, v in pairs(mobs) do
					if not current_room[start_room] then
						local p = sha.rooms[start_room].thyngs.mobs[k]
						local n = v
						if p - n < 0 then n = p end
						sha.rooms[start_room].thyngs.mobs[k] = p - n
					end
					if not current_room[end_room] then
						local p = sha.rooms[end_room].thyngs.mobs[k]
						local n = v
						sha.rooms[end_room].thyngs.mobs[k] = p + n					
					end
				end
			end
		end)
		if sha.is_in_shades then
			shades_print_map()
		end
	end
end
		
		
