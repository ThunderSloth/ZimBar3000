--------------------------------------------------------------------------------
--   COLOURS
--------------------------------------------------------------------------------
function mdt_get_colours()
	mdt.colours = {}
	cdb = sqlite3.open(colours_database)
	for t in cdb:nrows("SELECT colour_name FROM mdt") do 
		for k, v in pairs(t) do
			mdt.colours[v] = {}
			for c in cdb:nrows("SELECT * FROM "..v) do
				mdt.colours[v][c.id] = ColourNameToRGB(c.custom or c.preset)
			end
			if #mdt.colours[v] == 1 then
				mdt.colours[v] = mdt.colours[v][1]
			end
		end 
	end
	cdb:close()
end
