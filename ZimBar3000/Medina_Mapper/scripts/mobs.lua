--------------------------------------------------------------------------------
--   MOB TRACKING
--------------------------------------------------------------------------------
-- parse mobs/players and respective quantities from trigger matches
-- update room data accordingly and refresh map
function medina_get_mobs(wildcards, sign, room)
	--[[local function get_quantity(mob)
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
	if direction == "" then
		direction = false
	elseif direction then
		direction = medina_format_direction(direction)
	end
	regex.verbiage:gmatch(text, function (_, t)
		text = text:gsub(t.verbiage, "")
	end)
	local thyngs = ", "..text:gsub(" and ", ", ")
	for thyng in string.gmatch(thyngs, '([^,]+)') do
		thyng = Trim(thyng)
		if med.players[thyng] then
			local player, p_colour = thyng, med.players[thyng]
			regex.titles:gmatch(player, function (_, t)
				player = player:gsub(t.title.." ", "")
			end)
			player = player:gsub("^([a-z']+) .*$", "%1")
			for r, v in pairs(med.rooms) do
				med.rooms[r].thyngs.players[player] = nil
			end
			if sign > 0 then
				for i, r in ipairs(room) do
					med.rooms[r].thyngs.players[player] = p_colour
				end
			end
			if direction then
				for i, r in ipairs(room) do
					if med.rooms[r].exits[direction] then
						med.rooms[r].exits[direction].thyngs.players[player] = p_colour
					end
				end	
			end
		else
			local mob, n = get_quantity(thyng)
			mob = format_mobs(mob, n)
			if mob == "thugs" or mob == "heavies" and tonumber(n) then
				for i, r in ipairs(room) do
					med.rooms[r].thyngs.mobs[mob] = med.rooms[r].thyngs.mobs[mob] + n * sign > 0 and med.rooms[r].thyngs.mobs[mob] + n * sign or 0
				end
				if direction then
					for _, r in ipairs(room) do
						local adj_room = med.rooms[r].exits[direction] and med.rooms[r].exits[direction].room
						if adj_room then
							med.rooms[adj_room].thyngs.mobs[mob] = med.rooms[adj_room].thyngs.mobs[mob] + n
						end
					end
				end 
			elseif mob == "boss" then
				for r, v in pairs(med.rooms) do
					med.rooms[r].thyngs.mobs.boss = 0
				end
				for i, r in ipairs(room) do
					med.rooms[r].thyngs.mobs.boss = sign < 0 and 0 or sign
				end
				if direction then
					for _, r in ipairs(room) do
						local adj_room = med.rooms[r].exits[direction] and med.rooms[r].exits[direction].room
						if adj_room then
							med.rooms[adj_room].exits[direction].thyngs.mobs.boss = 1
						end
					end
				end 
			end
		end
	end
	medina_print_map()]]
end
