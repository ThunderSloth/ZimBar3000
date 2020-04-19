--------------------------------------------------------------------------------
--   COLOURS
--------------------------------------------------------------------------------
function medina_get_colours()
	med.colours = {}
	cdb = sqlite3.open(colours_database)
	for t in cdb:nrows("SELECT colour_name FROM medina") do 
		for k, v in pairs(t) do
			med.colours[v] = {}
			for c in cdb:nrows("SELECT * FROM "..v) do
				med.colours[v][c.id] = c.custom or ColourNameToRGB(c.preset)
			end
			if #med.colours[v] == 1 then
				med.colours[v] = med.colours[v][1]
			end
		end 
	end
	cdb:close()
end

function medina_select_custom_colour(colour, colour_name, i)
	local new_colour = PickColour(colour)
	if new_colour ~= -1 then
		if i then
			med.colours[colour_name][i] = new_colour
		else
			med.colours[colour_name] = new_colour
		end
		cdb = sqlite3.open(colours_database)
		cdb:exec("UPDATE "..colour_name.." SET custom = "..new_colour..(i and " WHERE id = "..tostring(i) or ""))
		cdb:close()
		BroadcastPlugin(173, colour_name..(i and tostring(i) or ""))
		medina_draw_base(med.dimensions, med.colours)
		medina_draw_overlay(med.dimensions, med.colours)
		medina_print_map()
	end
end

function medina_restore_default_colour(colour_names)
	cdb = sqlite3.open(colours_database)
    for k, v in pairs(colour_names) do
		colour_name, i = k:match("^(.*)(%d)$")
		colour_name = colour_name or k
		cdb:exec("UPDATE "..colour_name.." SET custom = NULL"..(i and " WHERE id = "..tostring(i) or "")..";")
		for c in cdb:nrows("SELECT preset FROM "..colour_name..(i and " WHERE id = "..tostring(i) or "")) do
			if i then
				med.colours[colour_name][i] = ColourNameToRGB(c.preset)
			else
				med.colours[colour_name] = ColourNameToRGB(c.preset)
			end
		end	
	end
	cdb:close()
	BroadcastPlugin(173, "all")
	medina_draw_base(med.dimensions, med.colours)
	medina_draw_overlay(med.dimensions, med.colours)
	medina_print_map()
end

function medina_restore_every_default_colour()
	local stmt = ""
	cdb = sqlite3.open(colours_database)
	local every_colour = {}
	for t in cdb:nrows("SELECT colour_name FROM colours") do
		table.insert(every_colour, t.colour_name)
	end
	for _, colour_name in ipairs(every_colour) do
		stmt = stmt.."UPDATE "..colour_name.." SET custom = NULL;"
	end
	cdb:exec(stmt)
	cdb:close()
	medina_get_colours()
	BroadcastPlugin(173, "all")
	medina_draw_base(med.dimensions, med.colours)
	medina_draw_overlay(med.dimensions, med.colours)
	medina_print_map()
end

function medina_update_colours(msg, id, name, text)
	if text == "all" then
		medina_get_colours()
		medina_draw_base(med.dimensions, med.colours)
		medina_draw_overlay(med.dimensions, med.colours)
		if WindowInfo(win, 5) then
			medina_print_map()				
		end		
	else
		local colour_name, i = text:match("^(.-)(%d?)$")
		if i then i = tonumber(i) end
		cdb = sqlite3.open(colours_database)
		for c in cdb:nrows("SELECT * FROM "..colour_name..(i and " WHERE id = "..tostring(i) or "")) do
			if i then
				med.colours[colour_name][i] = c.custom or ColourNameToRGB(c.preset)
			else
				med.colours[colour_name] = c.custom or ColourNameToRGB(c.preset)
			end
		end	
		cdb:close()
		medina_draw_base(med.dimensions, med.colours)
		medina_draw_overlay(med.dimensions, med.colours)
		if WindowInfo(win, 5) then
			medina_print_map()				
		end				
	end
end
