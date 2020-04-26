--------------------------------------------------------------------------------
--   FONTS
--------------------------------------------------------------------------------
function shades_get_font(dim)
	sha.dimensions.font = {}
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
	for c, p in pairs({titlebar_text = FIXED_TITLE_HEIGHT - 2, room_character = dim.room.y, exit_number = dim.exit.y}) do
		local max = 200
		local h, s = 0, 1
		local f = fonts[c]
		while (h < p) and (s < max) do
			assert(WindowFont(win, c, f, s, false, false, false, false), tostring(win).." "..tostring(c).." "..tostring(f).." "..tostring(s))
			h = tonumber(WindowFontInfo(win, c, 1)) or h or 0
			if h > p then
				s = (s - 1) > 1 and (s - 1) or 1
				assert(WindowFont(win, c, f, s, false, false, false, false), tostring(win).." "..tostring(c).." "..tostring(f).." "..tostring(s))
				h = tonumber(WindowFontInfo(win, c, 1)) or h or 0
				break
			end
			s = s + 1
		end
		for _, mw in ipairs({win.."base", win.."underlay", win.."overlay"}) do
			assert(WindowFont(mw, c, f, s, false, false, false, false), tostring(mw).." "..tostring(c).." "..tostring(f).." "..tostring(s))
			sha.dimensions.font[c] = h or 0
		end
	end
end
    
function shades_select_custom_font(font_id, fonts, i)
	if i then
		local new_font = fonts[i]
		fdb = sqlite3.open(fonts_database)
		fdb:exec([[UPDATE fonts SET custom = ']]..new_font..[[' WHERE name = ']]..font_id..[[';]])
		fdb:close()
		BroadcastPlugin(727, "update fonts")
		shades_window_setup(window_width, window_height)
		shades_print_map()
	end
end

function shades_restore_default_font(font_id)
	fdb = sqlite3.open(fonts_database)
	fdb:exec([[UPDATE fonts SET custom = NULL WHERE name = ']]..font_id..[[';]])
	fdb:close()
	BroadcastPlugin(727, "update fonts")
	shades_window_setup(window_width, window_height)
	shades_print_map()
end

function shades_restore_every_default_font()
	fdb = sqlite3.open(fonts_database)
	fdb:exec([[UPDATE fonts SET custom = NULL;]])
	fdb:close()
	BroadcastPlugin(727, "update fonts")
	shades_window_setup(window_width, window_height)
	shades_print_map()
end

function shades_update_fonts(msg, id, name, text)
	shades_window_setup(window_width, window_height)
	if WindowInfo(win, 5) then
		shades_print_map()				
	end	
end
