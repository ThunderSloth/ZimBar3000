-------------------------------------------------------------------------------
--  PARSE MAP
-------------------------------------------------------------------------------
function mdt_parse_map(text)
	mdt.fight_room = {}
	local i = 1
	text:gsub("<(%w+)MXP>[^+]", function(c)
		mdt.fight_room[i] = c == "Red"
		i = i + 1
	end)
end
-------------------------------------------------------------------------------
--  PARSE MAP DOOR TEXT
-------------------------------------------------------------------------------
function mdt_parse_map_door_text(text)
	-- determine coordinate shift
	local function move_point(d_long)
		local x, y = 0, 0; 	local d_short = ""
		if d_long:match('north') then
			y =  1; d_short = "n"
		elseif d_long:match('south') then
			y = -1; d_short = "s"
		end
		if d_long:match('east') then
			x =  1; d_short = d_short.."e"
		elseif d_long:match('west') then
			x = -1; d_short = d_short.."w"
		end
		return x, y, d_short
	end
	local word_to_int = {one = 1, two = 2, three = 3, four = 4, five = 5}
	-- decifer exit and door locations
	local function log_edges(s)
		local facing, path = s:match('^(.*) of(.*)$')
		local edges = {}
		local x, y = 0, 0
		mdt.regex.direction:gmatch(facing, function (_, t)
			local face_x, face_y, dir = move_point(t.DIRECTION)
			table.insert(edges, dir)
		end)
		mdt.regex.path:gmatch(path, function (_, t)
			local n = word_to_int[t.NUMBER] or 0
			local move_x, move_y, dir = move_point(t.DIRECTION)
			for i = 1, n do
				x = x + move_x
				y = y + move_y
			end
		end)
		return x, y, edges
	end
	-- strip title and family name
	local function parse_players(p_long)
		local p_short = string.lower(p_long)
		mdt.regex.titles:gmatch(p_short, function (_, t)
			p_short = p_short:gsub(t.title.." ", "")
		end)
		return p_short:gsub("^([a-z']+) .*$", "%1")
	end
	local function parse_mobs(m_long)
		local m_short = string.lower(m_long)
		local _1, _2, t = mdt.regex.xp:match(m_short)
		if type(t) ~= 'table' then
			-- handle edge cases
			_1, _2, t = mdt.regex.remainder:match(m_short)
		end
		local n = 1
		for i, v in ipairs(t) do
			if i > 21 then
				break
			elseif v then
				n = i
				break
			end
		end
		while #t > 0 do 
			table.remove(t) -- remove indecies
		end
		for k, m_short in pairs(t) do
			if m_short and k~= 'hiding' then
				local is_immobile, is_priest, is_money = false, false, false
				local tier, singular, plural, flag = k:match("^xp(%d*)(%w*)_(%w*)_(%w*)$")
				if flag:match("P") then
					is_priest = true
				end
				if flag:match("I") then
					is_immobile = true
				end
				if flag:match("M") then
					is_money = true
				end
				tier = tonumber(tier)
				return m_long, m_short, tier, singular, plural, n, is_immobile, is_priest, is_money
			end
		end
	end
	local function parse_room_population(t)
		-- xp exact is the exact vaule of xp, short is rounded to one digit, and long is rounded to 100ths
		local population = {players ={}, mobs = {}, is_player_room = false, is_mob_room = false, xp = 0, is_immobile = false, is_priest = false}
		for i = 0, 5 do
			population.mobs[i] = {}
		end
		for _, thyng in ipairs(t) do
			local _1, _2, c = mdt.regex.players:match(thyng)
			if c and c.colour and c.player then
			-- players
				population.is_player_room = true
				local p_long, p_colour = c.player, c.colour
				local p_short = parse_players(p_long)
				population.players[p_short] = {colour = p_colour, long = p_long}
			else 
			-- mobs
				population.is_mob_room = true
				local m_long, m_short, tier, singular, plural, n, is_immobile, is_priest, is_money = parse_mobs(thyng)
				population.mobs[tier][m_short] = population.mobs[tier][m_short] or {quantity = 0, singular = singular, plural = plural, long = {}, is_immobile = is_immobile, is_priest = is_priest, is_money = is_money}
				population.mobs[tier][m_short].quantity = population.mobs[tier][m_short].quantity + n
				table.insert(population.mobs[tier][m_short].long, m_long)
				if is_immobile then
					population.is_immobile = true
				end
				if is_priest then
					population.is_priest = true
				end
				if is_money then
					population.is_money = true
				end
				-- calculate xp total
				local xp_val = {1/12, 1/6, 1/3, 2/3, 1}
				population.xp = population.xp + (xp_val[tier] or 0) * n
			end
		end
		return population
	end
	local parse_map_door_text = {
		-- log nodes
		VISION = ( 
			function(s) 
				local room_id, path = mdt.sequence[1], {}
				local x, y = 0, 0
				mdt.regex.path:gmatch(s, function (_, t)
					local n = word_to_int[t.NUMBER] or 0
					local move_x, move_y, dir = move_point(t.DIRECTION)
					for i = 1, n do
						-- add exits as we follow the path, because these exits
						-- are not explicitly stated in the written text
						-- as the ones at the end of your vision range are
						table.insert(mdt.rooms[y][x].exits, dir)
						x = x + move_x
						y = y + move_y
						table.insert(path, dir)
						mdt.rooms[y][x].path = {}
						for i, v in ipairs(path) do
							table.insert(mdt.rooms[y][x].path, v)
						end
						room_id = mdt_get_exit_room(room_id, dir)
						if room_id then
							mdt.locations[room_id] = {map = {x = x, y = y}}
						end
						mdt.rooms[y][x].id = room_id
						mdt.rooms[y][x].in_vision = true
					end
					for _, m in ipairs({x, y}) do
						if math.abs(m) > mdt.rooms.range then
							mdt.rooms.range = math.abs(m)
						end
					end
				end)
			end), 
		-- log edges
		DOORS = ( 
			function(s) 
				local x, y, t = log_edges(s)
				mdt.rooms[y][x].doors = t
			end),
		EXITS = (
			function(s) 
				local x, y, t = log_edges(s)
				mdt.rooms[y][x].exits = t
			end),
		-- populate
		POPULATION = (
			function(s) 
				local thyngs = {}
				mdt.regex.thyngs:gmatch(s, function (_, t)
					local thyng = t.THYNG
					table.insert(thyngs, thyng)
				end)
				local x, y = 0, 0
				mdt.regex.path:gmatch(s, function (_, t)
					local n = word_to_int[t.NUMBER] or 0
					local move_x, move_y, dir = move_point(t.DIRECTION)
					for i = 1, n do
						x = x + move_x
						y = y + move_y
					end
				end)
				mdt.rooms[y][x].population = parse_room_population(thyngs)
			end),
	}
	bprint(text)
	mdt.rooms = {range = 0}
	for y = -5, 5 do
		mdt.rooms[y] = {}
		for x = -5, 5 do
			mdt.rooms[y][x] = {in_vision = false, id = false, doors = {}, path = {}, exits = {}, population = {}}
		end
	end
	mdt.rooms[0][0].in_vision = true
	mdt.rooms[0][0].id = mdt.sequence[1]
	mdt.locations = {}
	if mdt.sequence[1] then
		mdt.locations[mdt.sequence[1]] = {map = {x = 0, y = 0}}
	end
	mdt.regex.map_door_text:gmatch(text, function (_, t)
		while #t > 0 do 
			table.remove(t) -- remove indecies
		end
		for k, v in pairs(t) do
			if v then
				parse_map_door_text[k](v)
			end
		end
    end)
    --tprint(mdt.rooms)
    mdt_draw_map (mdt.rooms)
    mdt_prepare_text(mdt.rooms)
end
