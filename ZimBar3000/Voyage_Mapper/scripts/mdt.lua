--------------------------------------------------------------------------------
--   MAP DOOR TEXT PARSING
--------------------------------------------------------------------------------
function voyage_parse_written_map(mdt, re) -- text, regex

    local function get_room(current_room, x, y)
        if current_room and voy.position[voy.rooms[current_room].location.x + x] and 
        voy.position[voy.rooms[current_room].location.x + x][voy.rooms[current_room].location.y + y] then
            return voy.position[voy.rooms[current_room].location.x + x][voy.rooms[current_room].location.y + y]
        else
            return false
        end
    end
    -- repeat sub-strings following integers 
    local function expand_numbers(text) 
        text = text:gsub("(%d) (%w+)", 
        function(s1, s2) 
            return string.rep(s2.." ", tonumber(s1))
        end)
        return text
    end
	-- replace written words with integers 
    local function word_to_int(text) 
        local numbers = {"one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen", "twenty"}
        for i, word in ipairs(numbers) do
            text = text:gsub(" "..word.." ", " "..i.." "):gsub("^"..word.." ", " "..i.." "):gsub(" "..word.."$", " "..i.." ")	
        end
        return text
    end
    
	local directions = { 
		fore = {x = 0, y = 1},
		starboardfore = {x = 1, y = 1},
		starboard = {x = 1, y = 0},
		starboardaft = {x = 1, y = -1},
		aft = {x = 0, y = -1},
		portaft = {x = -1, y = -1},
		port = {x = -1, y = 0},
		portfore = {x = -1, y = 1}}

    --eliminate false deliminaters
    mdt = string.lower(word_to_int(mdt:gsub("black and white","black white")))
    --determine players
    re.players:gmatch(mdt, function (_, t)
		if not voy.players[t.player] then
			if t.player and t.colour then
				voy.players[t.player] = ColourNameToRGB(t.colour)~= -1 and ColourNameToRGB(t.colour) or ColourNameToRGB("orange")
			end
		end
    end)
    --simplify
    mdt = mdt:gsub(" and ", ", "):gsub("\\u001b", ""):gsub("[[][3-4]z", ""):gsub("room.writtenmap .", ""):gsub('[\\]n["]', ""):gsub("starboard aft", "starboardaft"):gsub("starboard fore", "starboardfore"):gsub("port aft", "portaft"):gsub("port fore", "portfore")
	-- parse vision
    local vision = {max = 0}
    for i, v in ipairs(voy.rooms) do
        voy.rooms[i].visable = false
    end
    re.vision:gmatch(mdt, function (_, t) 
            table.insert(vision, {})
            mdt = mdt:gsub(t[1], "")
            local len = {x = 0, y = 0,}
            re.directions:gmatch(expand_numbers(t[1]), function (_2, dir)
                table.insert(vision[#vision], dir[1])
                len.x = len.x + directions[dir[1]].x
                len.y = len.y + directions[dir[1]].y
                if vision.max < math.abs(len.x) then vision.max = math.abs(len.x) end
                if vision.max < math.abs(len.y) then vision.max = math.abs(len.y) end			
            end)
    end)
  
	for _, t in ipairs(vision) do
		local x, y = 0, 0
		for _2, dir in ipairs(t) do
			x = x + directions[dir].x
			y = y + directions[dir].y * -1
			local r = get_room(voy.sequence[1], x, y)
            if r then voy.rooms[r].players = {}; voy.rooms[r].dragons = {}; voy.rooms[r].visable = true end
		end
	end

	-- parse doors
	re.doors:gmatch(mdt, function (_, t)
		mdt = mdt:gsub(t[1], "")
		t[1] = expand_numbers(t[1])
		local x, y = 0, 0
		re.door_and_exit_paths:gmatch(t[1], function (_2, dir)
			x = x + directions[dir[1]].x
			y = y + directions[dir[1]].y * -1
		end)
		re.door_and_exit_directions:gmatch(t[1], function (_2, dir)
			local xx = x + directions[dir[1]].x
			local yy = y + directions[dir[1]].y * -1
		end)	
	end)
    
	-- parse exits
	re.exits:gmatch(mdt, function (_, t)
		mdt = mdt:gsub(t[1], "")
		t[1] = expand_numbers(t[1])
		local x, y = 0, 0
		re.door_and_exit_paths:gmatch(t[1], function (_2, dir)
			x = x + directions[dir[1]].x
			y = y + directions[dir[1]].y * - 1
		end)
		re.door_and_exit_directions:gmatch(t[1], function (_2, dir)
			local xx = x + directions[dir[1]].x
			local yy = y + directions[dir[1]].y * -1
		end)	
	end)	

	-- parse population
    local population = {player_rooms = 0}
	re.population:gmatch(mdt, function (_, t)
        local is_player, is_dragon = false, false
		local x, y = 0, 0
		re.directions:gmatch(expand_numbers(t[1]), function (_2, dir)
			x = x + directions[dir[1]].x
			y = y + directions[dir[1]].y * - 1	
		end)
        t[1] = word_to_int(string.lower(" "..t[1]):gsub("mxp\<.-mxp\>", ""):gsub(" an? ", " "):gsub(" are ", " is "):gsub("( is .*)$", ""))
        for thyng in string.gmatch(t[1], '([^,]+)') do
            thyng = thyng:gsub("^ ", "")
			local r = get_room(voy.sequence[1], x, y)
            if voy.players[thyng] then
                for i, v in ipairs(voy.rooms) do
                    if v.players[thyng] then
                        voy.rooms[i].players[thyng] = nil
                        break
                    end
                end
                if r then 
                    local name = thyng
                    re.titles:gmatch(thyng, function (_3, t2)
                        name = name:gsub(t2.title.." ", "")
                    end)
                    name = name:gsub("^([a-z']+) .*$", "%1")
                    voy.rooms[r].players[thyng] = name
                    if not(is_player) then
                        is_player = true
                        if not is_dragon then
                            population[#population + 1] = {}
                        end
                        population[#population] = {room = r, colour = voy.players[thyng]}
                        population.player_rooms = population.player_rooms + 1
                    end
                end
            elseif voy.dragons[thyng] then
                for i, v in ipairs(voy.rooms) do
                    if v.dragons[thyng] then
                        voy.rooms[i].dragons[thyng] = nil
                        break
                    end
                end
                if r then
                    voy.rooms[r].dragons[thyng] = string.match(thyng, "^(%w+)")
                    if not(is_player) and not(is_dragon) then
                        is_dragon = true
                        population[#population + 1] = {room = r, colour = false}
                    end
                end
            end
        end
	end)
    for r, v in ipairs(voy.rooms) do
        if not(v.visable) then
            local is_player, is_dragon = false, false
            for k, _ in pairs(v.players) do
                is_player = k
                break
            end
            if not(is_player) then
                for k, _ in pairs(v.dragons) do
                    is_dragon = k
                    break
                end
            end
            if voy.players[is_player] then
                population[#population + 1] = {room = r, colour = voy.players[is_player]}
                population.player_rooms = population.player_rooms + 1
            elseif is_dragon then
                population[#population + 1] = {room = r, colour = false}
            end
        end
    end
    voy.population = population
    voyage_print_map()
end
