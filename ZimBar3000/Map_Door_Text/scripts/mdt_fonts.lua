-------------------------------------------------------------------------------
--   FONTS
-------------------------------------------------------------------------------
function mdt_get_font(dim) -- dimensions
	-- chose our fonts, pick backups if unavailable
	local function choose_fonts()
		local font_choices = {}
		fdb = sqlite3.open(fonts_database)
		for t in fdb:nrows("SELECT * FROM fonts") do
			font_choices[t.name] = {t.custom or "", t.preset1, t.preset2}
		end
		fdb:close()
		local f_tbl = utils.getfontfamilies() -- all possible fonts
		local chosen_fonts = {}
		 -- if our chosen font exists then pick it
		for name, t in pairs(font_choices) do
			chosen_fonts[name] = false
			for i, v in ipairs(t) do
				if f_tbl[v] then
					chosen_fonts[name] = v
					break
				end
			end
		end
		-- if none of our chosen fonts are avaliable, pick the first one that is
		for name, v in pairs(chosen_fonts) do 
			if not v then
				for k in pairs(f_tbl) do
					chosen_fonts[name] = k
					break
				end
			end
		end
		return chosen_fonts
	end
	local fonts = choose_fonts()
	-- determine font size based on font and max height
	local function get_size(font_id, font_name, max_height)
		local max_size, font_size = 200, 1
		local font_height = 0
		while (font_height <= max_height) and (font_size < max_size) do
			-- load the font in order to determine its size size
			WindowFont(win[1], font_id, font_name, font_size, false, false, true, false)
			font_height = tonumber(WindowFontInfo(win[1], font_id, 1)) or font_height or 0
			-- if it passes or maximums then we have found our size
			if font_height > max_height or font_size > max_size then
				-- use previous size
				return (font_size - 1) > 1 and (font_size - 1) or 1
			end
			-- try the next size up
			font_size = font_size + 1
		end
	end
	-- load font and retun font height
	local function load_font(font_id, font_name, font_size)
		-- load fonts on each miniwindow
		for k, mw in pairs(win) do
			WindowFont(mw, font_id, font_name, font_size, false, false, false, false)
			WindowFont(mw, font_id.."underlined", font_name, font_size, false, false, true, false)
		end
		return tonumber(WindowFontInfo(win[1], font_id, 1)) or font_height or 0
	end
	-- our sizes are all determine by entirely different methods
	local font_methods = {
		titlebar_text = ( -- determined by fixed hight
			function(font_id)
				local font_name = fonts.titlebar_text 
				local font_size   = get_size(font_id, font_name, FIXED_TITLE_HEIGHT)
				local font_height = load_font(font_id, font_name, font_size)
				mdt.dimensions.font[font_id] = font_height -- single value
			end),
		room_character = ( -- determined by room proportions, there will be a diffrent size for each possible vision limit
			function(font_id)
				mdt.dimensions.font[font_id] = {}
				local font_name = fonts.room_character
				for i = 0, #dim.room do         
					local font_size   = get_size(font_id..tostring(i), font_name, dim.room[i].y)
					local font_height = load_font(font_id..tostring(i), font_name, font_size)
					mdt.dimensions.font[font_id][i] = font_height -- store by vision limit
				end
			end),
		text_window = ( -- preset sizes
			function(font_id)
				mdt.dimensions.font[font_id] = {}
				local font_name = fonts.text_window
				for font_size = 8, 20 do 
					local font_height = load_font(font_id..tostring(font_size), font_name, font_size)
					mdt.dimensions.font[font_id][font_size] = font_height -- store by size
				end
			end),
	}
	mdt.dimensions.font = {}
	for font_id, func in pairs(font_methods) do
		func(font_id)
	end	
end

function mdt_select_custom_font(font_id, fonts, i)
	if i then
		local new_font = fonts[i]
		fdb = sqlite3.open(fonts_database)
		fdb:exec([[UPDATE fonts SET custom = ']]..new_font..[[' WHERE name = ']]..font_id..[[';]])
		fdb:close()
		mdt_window_setup(window_width, window_height)
		if not (mdt.sequence[1] and mdt.special_areas[mdt.sequence[1]]) then
			mdt_draw_map(mdt.rooms)
			mdt_prepare_text(mdt.rooms)
		end
	end
end

function mdt_restore_default_font(font_id)
	fdb = sqlite3.open(fonts_database)
	fdb:exec([[UPDATE fonts SET custom = NULL WHERE name = ']]..font_id..[[';]])
	fdb:close()
	mdt_window_setup(window_width, window_height)
	if not (mdt.sequence[1] and mdt.special_areas[mdt.sequence[1]]) then
		mdt_draw_map(mdt.rooms)
		mdt_prepare_text(mdt.rooms)
	end
end

function mdt_restore_every_default_font()
	fdb = sqlite3.open(fonts_database)
	fdb:exec([[UPDATE fonts SET custom = NULL;]])
	fdb:close()
	mdt_window_setup(window_width, window_height)
	if not (mdt.sequence[1] and mdt.special_areas[mdt.sequence[1]]) then
		mdt_draw_map(mdt.rooms)
		mdt_prepare_text(mdt.rooms)
	end
end
