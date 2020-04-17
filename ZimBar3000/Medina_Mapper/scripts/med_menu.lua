--------------------------------------------------------------------------------
--   ROOM MENU
--------------------------------------------------------------------------------
function medina_room_menu(room)
    local options = {}
    local menu = "|look"
	table.insert(options, function()
		medina_get_shortest_path(med.rooms, med.sequence[#med.sequence] and med.sequence[#med.sequence][1] or false, room, "is_look") 
	end)
    menu = string.gsub(menu, "%W%l", string.upper):sub(2);menu = "!"..menu
    result = string.lower(
		WindowMenu(win, 
		WindowInfo(win, 14), --x
		WindowInfo(win, 15), --y
		menu))
    if result ~= "" then
        options[tonumber(result)]()
    end
end
--------------------------------------------------------------------------------
--   TITLEBAR MENU
--------------------------------------------------------------------------------
function medina_get_title_menu()
    local options = {}
    local menu = "!^Medina Mapper v"..GetPluginInfo (GetPluginID (), 19)
    menu = menu.."||Help||Configure||>Options|>Colours|"
    table.insert(options, function()
        on_alias_medina_help()
    end)
    table.insert(options, function()
        on_alias_medina_configure()
    end)
    for m, f in pairs({custom = medina_select_custom_colour, defaults = medina_restore_default_colour}) do
		menu = menu..">"..m.."|"
		if m == "defaults" then
			menu = menu.."restore all||"
			table.insert(options, function()
				medina_restore_every_default_colour()
			end)		
		end
		local section = false
		for k, v in pairsByKeys(med.colours) do
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
						f(vv, k, i)
					end)
				end
				menu = menu.."|"
			else
				table.insert(options, function()
					f(v, k)
				end)
				menu = menu..colour_name.."|"
			end
		end
		menu = menu.."<|<|"
	end
	menu = menu.."<|>arrows|"
	menu = menu..(arrow_set == "default" and "+" or "").."default|"
	table.insert(options, function()
		arrow_set = "default"
		medina_window_setup(window_width, window_height)
		medina_print_map()
	end)
	menu = menu..(arrow_set == "rainbow" and "+" or "").."rainbow|"
	table.insert(options, function()
		arrow_set = "rainbow"
	    medina_window_setup(window_width, window_height)
		medina_print_map()	
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
