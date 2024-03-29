--------------------------------------------------------------------------------
--   TITLEBAR MENU
--------------------------------------------------------------------------------
function shades_get_title_menu()
    local options = {}
    local menu = "!^Shades Mapper v"..GetPluginInfo (SHA, 19)
    menu = menu.."||Help||Configure||reset||>Options|>Colours|"
    table.insert(options, function()
        on_alias_shades_help()
    end)
    table.insert(options, function()
        on_alias_shades_configure()
    end)
    table.insert(options, function()
        on_alias_shades_reset()
    end)
    menu = menu.."restore all||"
    table.insert(options, function()
        shades_restore_every_default_colour()
    end)    
    menu = menu.."defaults|"
    table.insert(options, function()
		local colours = {}
		for k, v in pairsByKeys(sha.colours) do
			if type(v) == 'table' then
				for i, v in ipairs(v) do
					colours[k..tostring(i)] = (k.." "..tostring(i)):gsub("_", " "):gsub("^%w", string.upper):gsub("(%W%w)", string.upper)
				end
			else
				colours[k] = k:gsub("_", " "):gsub("^%w", string.upper):gsub("(%W%w)", string.upper)
			end
		end
        local restore_default = utils.multilistbox ("Select colour(s) to restore to default:", "Default Colour Picker", colours)
        if restore_default then
			shades_restore_default_colour(restore_default)
		end
    end)	
	menu = menu..">custom|"
	local section = false
	for k, v in pairsByKeys(sha.colours) do
		if not section then
			section = k:match("^(%w+)")
			menu = menu..">"..section.."|"
		elseif not k:match("^"..section) then
			section = k:match("^(%w+)")
			menu = menu.."<|>"..section.."|"
		end
		local colour_name = k:gsub("_", " ")
		if type(v) == "table" then
			menu = menu.."|"
			for i, vv in ipairs(v) do
				menu = menu..colour_name.." "..tostring(i).."|"
				table.insert(options, function()
					shades_select_custom_colour(vv, k, i)
				end)
			end
			menu = menu.."|"
		else
			table.insert(options, function()
				shades_select_custom_colour(v, k)
			end)
			menu = menu..colour_name.."|"
		end
	end
	menu = menu.."<|<|"
	local plugin_fonts = {
		titlebar_text   = "Select font for titlebar:",
		room_character  = "Select font for characters displayed inside of map rooms:",
		text_window     = "Select font for mob text window:",
		exit_number     = "Select font for numbers displayed inside of exits:",
	}
	menu = menu.."<|>fonts|restore all||custom|"
	table.insert(options, function()
		shades_restore_every_default_font()
	end)
	table.insert(options, function()
		local font_ids = {}
		for k, v in pairs(plugin_fonts) do
			font_ids[k] = string.gsub(" "..k:gsub("_", " "), "%W%l", string.upper):sub(2)
		end
		local font_id = utils.listbox("Choose a font:", "Custom Font Picker", font_ids)
		if font_id then
			local default_fonts = {}
			fdb = sqlite3.open(fonts_database)
			for t in fdb:nrows("SELECT name, preset1, preset2 FROM fonts") do
				default_fonts[t.name] = {t.preset1, t.preset2}
			end
			fdb:close()
			local f_tbl = utils.getfontfamilies() -- all possible fonts
			local display_default = {}
			-- if our chosen font exists then pick it
			for name, t in pairs(default_fonts) do
				display_default[name] = false
				for i, v in ipairs(t) do
					if f_tbl[v] then
						display_default[name] = v
						break
					end
				end
			end
			local fonts = {}
			for k, _ in pairs(f_tbl) do
				table.insert(fonts, k)
			end
			local new_font = utils.listbox(plugin_fonts[font_id], "Custom Font Picker", fonts, display_default[font_id])
			shades_select_custom_font(font_id, fonts, new_font)
		end
	end)
	menu = menu.."<|<"
	menu = (string.gsub(menu, "%W%l", string.upper):sub(2));menu = "!"..menu:gsub("(||+)", "||"):gsub("(V%d)", string.lower)
    result = string.lower(WindowMenu(win, 
      WindowInfo(win, 14), --x
      WindowInfo(win, 15), --y
      menu))
    if result ~= "" then
        options[tonumber(result)]()
    end
end
