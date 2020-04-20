--------------------------------------------------------------------------------
--   MOB TRACKING
--------------------------------------------------------------------------------
-- on any event of mobs/players entering/exiting a room
-- or looking at/moving to a room that is occupied by mobs/players
function on_trigger_smugs_mob_track(name, line, wildcards, styles)
	local sign = name:match("exit") and -1 or 1
	smugs_get_mobs(wildcards, sign)
end
-- parse mobs/players and respective quantities from trigger matches
-- update room data accordingly and refresh map
function smugs_get_mobs(wildcards, sign)
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
		if mob:match("smuggler captain") then
			mob = "captain"
		elseif mob:match("smugglers?$") then
			mob = "smugglers"
		end
		return mob
	end
	local room = smu.sequence[1]
	local text = string.lower(wildcards.thyngs)
	local direction = wildcards.direction or false
    -- direction if applicable
	if direction == "" then
		direction = false
	elseif direction then
		direction = smugs_format_direction(direction)
	end
	-- set aggro
	if text:match(" fighting ") then
		smu.rooms[room].aggro = true
	end
	smu.regex.verbiage:gmatch(text, function (_, t)
		text = text:gsub(t.verbiage, "")
	end)
    local is_players = false
    local population = {mobs = {captain = 0, smugglers = 0}, players = {},}
	local thyngs = ", "..text:gsub(" and ", ", ")
    -- get players with colours, mobs with quantities
	for thyng in string.gmatch(thyngs, '([^,]+)') do
		thyng = Trim(thyng)
		if smu.players[thyng] then
			local player, p_colour = thyng, smu.players[thyng]
			smu.regex.titles:gmatch(player, function (_, t)
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
				for r, _ in pairs(smu.rooms) do
					smu.rooms[r].thyngs.players[name] = nil
				end
				if sign > 0 then
					smu.rooms[room].thyngs.players[name] = v	
				elseif direction then
					local trajectory_room = smu.rooms[room].exits[direction]
					if trajectory_room then
						smu.rooms[trajectory_room].thyngs.players[name] = v
					end
				end
			elseif name == "captain" and v > 0 then
				smugs_reset_hidey_hole()
				for r, _ in pairs(smu.rooms) do
					-- remove captain from elsewhere, as he is unique
					smu.rooms[r].thyngs.mobs.captain = 0
				end
				if sign > 0 then
					-- if add
					smu.rooms[room].thyngs.mobs.captain = 1	
				elseif smu.rooms[room].thyngs.mobs.smugglers + smu.rooms[room].thyngs.mobs.captain == 0 then
					-- if subtract and no smugs then turn aggro off
					smu.rooms[room].aggro = false
				end
			elseif v > 0 then 
				-- add or remove quantity based on sign
				smu.rooms[room].thyngs.mobs.smugglers = smu.rooms[room].thyngs.mobs.smugglers + v * sign > 0 and smu.rooms[room].thyngs.mobs.smugglers + v * sign or 0
				-- aggro in our room, before change
				local aggro = smu.rooms[room].aggro
				-- if no mobs remaining, turn off aggro
				if smu.rooms[room].thyngs.mobs.smugglers + smu.rooms[room].thyngs.mobs.captain == 0 then
					smu.rooms[room].aggro = false
				end
				-- if enter or exit
				if direction then
					local other_room = smu.rooms[room].exits[direction]
					if other_room then
						-- aggro in other room
						local other_aggro = smu.rooms[other_room].aggro
						-- add or remove quantity in other room
						smu.rooms[other_room].thyngs.mobs.smugglers = smu.rooms[other_room].thyngs.mobs.smugglers + v * - sign > 0 and smu.rooms[other_room].thyngs.mobs.smugglers + v * - sign or 0
						-- if no mobs left in other room, remove aggro
						if smu.rooms[other_room].thyngs.mobs.smugglers + smu.rooms[other_room].thyngs.mobs.captain == 0 then
							smu.rooms[other_room].aggro = false
							-- move aggro if applicable
							smu.rooms[room].aggro = other_aggro
						else -- if there are mobs in other room now
							-- move aggro from our room to other room
							smu.rooms[other_room].aggro = aggro
						end
					end
				end
            end
        end
    end
    smugs_print_map()
end

function on_trigger_smugs_room_aggro(name, line, wildcards, styles)
	local room = smu.sequence[1]
	smu.rooms[room].aggro = true
	smugs_print_map()
end

function smugs_set_follow_delay(previous_room, direction)
	if previous_room and smu.rooms[previous_room].aggro and direction then
		local n = smu.rooms[previous_room].thyngs.mobs.smugglers
		if n > 0 then
			-- send previous room, direction and quantity to timer script via name
			AddTimer(previous_room.."_"..direction.."_"..tostring(n), 0, 0, 5.25, "", timer_flag.Enabled + timer_flag.Replace + timer_flag.Temporary + timer_flag.OneShot, "smugs_follow_delay")
		end
	end
end

function smugs_follow_delay(name)
	local current_room = smu.sequence[1] or false
	local room, direction, n = name:match("^(%w*)_(%w*)_(%d+)$")
	if room and direction and n then
		local trajectory_room = smu.rooms[room].exits[direction]
		local n = tonumber(n)
		-- we can not be in the start or end room, we have other methods to track those scenarios
		if trajectory_room and not (current_room == room) then
			-- mobs will not follow if any player is in their room
			for k, _ in pairs(smu.rooms[room].thyngs.players) do
				if k then 
				return end
			end
			-- get current quanity for comparison
			local p = smu.rooms[room].thyngs.mobs.smugglers
			local m = smu.rooms[trajectory_room].thyngs.mobs.smugglers 
			if p - n < 0 then
				n = p
			end
			-- remove quantity from 
			smu.rooms[room].thyngs.mobs.smugglers = p - n
			if not(trajectory_room == current_room) then
				if smu.rooms[room].thyngs.mobs.captain > 0 then
					-- if captain, move half
					local n0 = math.ceil(n / 2)
					local n1 = math.floor(n / 2)
					smu.rooms[room].thyngs.mobs.smugglers = n + n0
					smu.rooms[trajectory_room].thyngs.mobs.smugglers = m + n1			
				else
					-- if no captain, move quantity
					smu.rooms[trajectory_room].thyngs.mobs.smugglers = m + n
				end
				-- set aggro in start and end room if smugs are present
				smu.rooms[trajectory_room].aggro = smu.rooms[trajectory_room].thyngs.mobs.smugglers > 0 and true or false
			end
			smu.rooms[room].aggro = smu.rooms[room].thyngs.mobs.smugglers > 0 and true or false
			-- print only if in smugs
			if smu.is_in_smugs then
				smugs_print_map()
			end
		end
	end
end
