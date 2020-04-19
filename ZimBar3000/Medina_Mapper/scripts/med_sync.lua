--------------------------------------------------------------------------------
--   SYNC FUNCTIONS
--------------------------------------------------------------------------------
function on_trigger_medina_receive_sync(name, line, wildcards, styles)
	med.sync = {data = {}, is_valid = false}
	medina_draw_sync_sword(wildcards)
	medina_handle_incoming_sync(wildcards.sync, wildcards.version, wildcards.sender)
end
-- accept sync without argument / send sync to player with argument (player name)
function on_alias_medina_sync(name, line, wildcards)
	if wildcards.player ~= '' then -- sending
		Send('tell '..wildcards.player..' '..medina_get_sync())
	else -- accepting
		if med.sync.is_valid then
			medina_reset_rooms()
			for room, v in pairs(med.sync.data) do
				if v.solved then
					for static, _ in medina_order_exits(v) do
						if not (room == 'A' and static == 'nw' or room == 'R' and static == 'se') then
							local temp = v[static]
							med.rooms[room].normalized[static] = temp
							med.rooms[room].solved = med.sync.recieved
							if temp then
								med.rooms[room].exits = 
									med.rooms[room].exits or 
									room == 'A' and {nw = {exits = false, room = false}} or 
									room == 'R' and {se = {exits = false, room = false}} or {}
								med.rooms[room].exits[temp] = {exits = false, room = false}
								for adj_room, dir in pairs(med.rooms[room].exit_rooms) do
									if static == dir then
										med.rooms[room].exits[temp].room = adj_room
									end
								end
							end
						end
					end
					med.rooms[room].solved =  med.sync.time
				end
			end
			medina_draw_base(med.dimensions, med.colours)
			medina_print_map()
		else
			medina_print_error('No sync data available')
		end
	end
end
-- construct sync data for sending to other players
function medina_get_sync()
	local text, time, n = "", 0, 0 
	local ex = {n = 1, ne = 2, e = 3, se = 4, s = 5, sw = 6, w = 7, nw = 8}
	local A, R = 65, 82
    for i = A, R  do
		local room = string.char(i)
        for static, temp in medina_order_exits(med.rooms[room].normalized) do
			if not (room == 'A' and static == 'nw' or room == 'R' and static == 'se') then
				text = text..tostring(ex[temp] or '0')
            end
        end
        if med.rooms[room].solved then
            time = time + med.rooms[room].solved
			n = n + 1
        end
    end
	time = tostring(n == 0 and 0 or math.floor(time / n))
	text = time .. text
    local version = string.format ("%1.1f", GetPluginInfo (MED, 19) )
    local signiture = "/zMMv" .. version .. "/"
    local based = medina_convert_base(text, 10, 94) --:format("%0c", 56)
    --based = string.rep('!', 56 - #based)..based 
    local hilt, blade = "cxxxxx][={>>>",--[[SUPER BADASS SWORD LOL]]"_>>>"
    local sync_sword =  hilt .. based .. signiture .. blade 
    return sync_sword
end
-- unpack incomming sync data, validate and parse
function medina_handle_incoming_sync(sync, version, sender)
	local function invalid_data(reason)
		med.sync = {data = {}, is_valid = false}
		medina_print_error("Invalid sync data: "..reason.."; "..sender.."")
	end
	if #sync < 40 then
		sync = medina_convert_base(sync, 94, 10)
		local total_rooms = 56
		local n = #sync - total_rooms
		if 0 < n and n <= 10 then
			local time, mapdata = string.match(sync, '^(' .. string.rep('.', n) .. ')(%d*)$')
			time = tonumber(time)
			if time and #mapdata == total_rooms then
				local ex = {'n', 'ne', 'e', 'se', 's', 'sw', 'w', 'nw'}; ex[0] = false
				local unpacked, solved = {}, 0
				local A, R, n = 65, 82, 1
				for i = A, R do
					local room = string.char(i)
					local prevent_duplicate_exits = {}
					for static, temp in medina_order_exits(med.rooms[room].normalized) do
						if not (room == 'A' and static == 'nw' or room == 'R' and static == 'se') then
							unpacked[room] = unpacked[room] or {solved = true}
							local m = tonumber(mapdata:sub(n, n))
							if ex[m] ~= nil then
								if not prevent_duplicate_exits[ex[m]] then
									if m > 0 then
										prevent_duplicate_exits[ex[m]] = true
									end
									unpacked[room][static] = ex[m]
									if not unpacked[room][static] then
										unpacked[room].solved = false
									end							
								else
									print (m, ex[m])
									invalid_data("duplicate exits")
									return
								end
								n = n + 1
							else
								invalid_data("incorrect format")
								return
							end
						end
					end
					if unpacked[room].solved then
						solved = solved + 1
					end
				end
				local percent = (math.floor((solved/18) *10000 + 0.5) / 100)
				med.sync = {data = unpacked, is_valid = true, time = time}
				medina_sync_unpacking_successful(percent, time, version, sender)
				return
			end
		end
	end
	invalid_data("incorrect length")
end
-- display average time since solved rooms have been solved
-- and percentage of solved rooms out of all rooms
-- offer hyperlink to accept sync
function medina_sync_unpacking_successful(percent, time, version, sender)
	time = os.time() - time
	local text_colour1, text_colour2, text_colour3 = "gray", "lightgray", "orange"
	ColourTell(
		text_colour2, "", sender, 
		text_colour1, "", " has sent you medina map data: ", 
		text_colour2, "", "[",
		text_colour3 , "", percent.."\%",
		text_colour2, "", "] "
	)
	ColourNote(text_colour1, "", "("..string.format("%.2d:%.2d:%.2d", time/(60*60), time/60%60, time%60)..")")
	ColourTell(
		text_colour1, "", "Type/Click on ",
		text_colour2, "", "'"
	)
	Hyperlink ("medina sync", "medina sync", "Update medina map!", "orange", "black", 0)
	ColourNote(
		text_colour2, "", "'",
		text_colour1, "", " to update",
		text_colour1, "", "!"
	)
	ColourNote(
		text_colour1, "black", "(This will override your current map.)"
	)
	if GetPluginInfo(MED, 19) < tonumber(version) then
		medina_print_error("There is a newer version of this plugin available!")
	end
	Note('\n')
end
-- colour incomming sync tell (technically we are omitting it and printing it again)
function medina_draw_sync_sword(wildcards)
	local background_colour = RGBColourToName(AdjustColour (GetInfo(271), 1))
	local hilt_colour, sword_colour1, sword_colour2, blood_colour = "orange", "lightgray", "gray", "red"
	local blade_len = #wildcards.blade0
	ColourTell(background_colour, background_colour, wildcards.tell..'\n', hilt_colour, background_colour, wildcards.hilt)
	local i = 1
	for _, v in ipairs({'ricasso', 'blade1', 'blade2', 'blade3', 'blade4', 'blade5', 'point'}) do
		for c in wildcards[v]:gmatch(".") do
			sword_colour1 = RGBColourToName( 
				AdjustColour (ColourNameToRGB (sword_colour1), 
				i < blade_len / 2 and 3 or 2) )
			sword_colour2 = RGBColourToName( 
				AdjustColour (ColourNameToRGB (sword_colour2), 
				i < blade_len / 2 and 2 or 3) )
			local text_colour = (v == 'blade1'  or v == 'blade5') and sword_colour2 or v == 'blade3' and blood_colour or sword_colour1
			local bg_colour   = (v == 'ricasso' or v == 'point' ) and background_colour or sword_colour1
			ColourTell(text_colour, bg_colour, c)
			i = i + 1
		end
	end
	Note("\n")
end
-- convert from base 10 to base 94 (all printable ascii char)
-- and vice versa for string compression and basic encryption
function medina_convert_base(s, b1, b2)
	local function get_bases()
		local base = {
			[10] = {}, 
			[94] = {},
		}
		for i = 33, 126 do
		  table.insert(base[94], string.char(i))
		end
		for i = 48, 57 do
			table.insert(base[10], string.char(i))
		end
		for k, v in pairs(base) do
			base[k][0] = v[1]
			table.remove(base[k], 1)
		end
		return base
	end
	local base = get_bases()
	local function list_to_set(t1)
		t2 = {}
		for k, v in pairs(t1) do
			t2[tostring(v)] = k
		end
		return t2
	end
	local function copy_list(t1)
		t2 = {}
		for k, v in pairs(t1) do
			t2[k] = v
		end
		return t2
	end
    local tb1, tb2 = list_to_set(base[b1]), copy_list(base[b2])
    local function b1_to_dec(s)
		bc.digits (5000)
        local dec = bc.number(0)
        for i = 1, #s do
            local c = s:sub(i,i)
            dec = bc.add( dec, bc.mul( tb1[c], bc.pow (b1, (#s - i) ) ) )
        end
        return dec
    end
    local function dec_to_b2(dec)
        local q, r, t = dec, 0, {}
        local m = 1
        while not bc.iszero (q)  do
			bc.digits (5000)
            q, r = bc.divmod (q, b2)
            if not r then r = 0 end
            table.insert(t, 1, bc.tonumber(r))
            m = m + 1
            if m == 100000 then break end
        end
        s = ""
        for i, v in ipairs(t) do
			if tb2[v] then
				s = s..tb2[v]
            end
        end
        return s
    end
    local based = dec_to_b2(b1_to_dec(s))
    local min = {[10] = '57', [94] = '30'}
    based = string.format('%'..min[b2]..'s', based):gsub(' ', base[b2][0])
	return based
end
