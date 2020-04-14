
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
		local rooms, is_mobs = "", false
		for _, r in ipairs(previous_room) do
			rooms = rooms..r
			if 
				sha.rooms[r].thyngs.mobs.muggers  > 0 or
				sha.rooms[r].thyngs.mobs.fighters > 0 or
				sha.rooms[r].thyngs.mobs.trolls   > 0
			then
				is_mobs = true
			end
		end
		if is_mobs then
			AddTimer(rooms.."_"..direction, 0, 0, 5.25, "", timer_flag.Enabled + timer_flag.Replace + timer_flag.Temporary + timer_flag.OneShot, "shades_follow_delay")
		end
	end
end

function shades_follow_delay(name)
	local s, direction = name:match("^(%w*)_(%d)$")
	if s and direction then
		direction = tonumber(direction)
		local room = {}
		s:gsub(".", function(c)
			for k, _ in pairs(sha.rooms[c].thyngs.players) do
				if k then 
				return end -- only if players are not present in the room
			end
			table.insert(room, c)
		end)
		for _, r in ipairs(room) do
			local mobs = {
				muggers =  sha.rooms[r].thyngs.mobs.muggers,
				fighters = sha.rooms[r].thyngs.mobs.fighters,
				trolls =   sha.rooms[r].thyngs.mobs.trolls,
			}
			local trajectory_room = sha.rooms[r].exits[direction]
			local current_room = sha.sequence[1] or {}
			local is_impeding = false
			for _, cr in ipairs(current_room) do
				if cr == trajectory_room then is_impeding = true end
			end
			sha.rooms[r].thyngs.mobs = {muggers = 0, fighters = 0, trolls = 0}
			if not is_impeding then
				sha.rooms[trajectory_room].thyngs.mobs = {muggers = mobs.muggers, fighters = mobs.fighters, trolls = mobs.trolls}
			end
			if sha.is_in_shades then
				shades_print_map()
			end
		end
	end
end
