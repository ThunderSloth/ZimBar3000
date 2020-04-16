--------------------------------------------------------------------------------
--   COLOURS
--------------------------------------------------------------------------------
function smugs_get_colours()
	smu.colours = {}
	cdb = sqlite3.open(colours_database)
	for t in cdb:nrows("SELECT colour_name FROM smugs") do 
		for k, v in pairs(t) do
			smu.colours[v] = {}
			for c in cdb:nrows("SELECT * FROM "..v) do
				smu.colours[v][c.id] = ColourNameToRGB(c.custom or c.preset)
			end
			if #smu.colours[v] == 1 then
				smu.colours[v] = smu.colours[v][1]
			end
		end 
	end
	cdb:close()
end
