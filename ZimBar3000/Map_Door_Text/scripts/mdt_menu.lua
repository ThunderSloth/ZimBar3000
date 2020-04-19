--------------------------------------------------------------------------------
--   TITLEBAR MENU
--------------------------------------------------------------------------------
function mdt_get_title_menu(mw)
    local options = {}
    local menu = "!^Map Door Text v"..GetPluginInfo (GetPluginID (), 19)
    menu = menu.."||Help||Configure||>Options|>Colours|"
    table.insert(options, function()
        on_alias_mdt_help()
    end)
    table.insert(options, function()
        on_alias_mdt_configure()
    end)
    for m, f in pairs({custom = mdt_select_custom_colour, defaults = mdt_restore_default_colour}) do
		menu = menu..">"..m.."|"
		if m == "defaults" then
			menu = menu.."restore all||"
			table.insert(options, function()
				mdt_restore_every_default_colour()
			end)		
		end
		local section = false
		for k, v in pairsByKeys(mdt.colours) do
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
	local plugin_fonts = {
		titlebar_text   = "Select font for titlebar:",
		room_character  = "Select font for characters displayed inside of map rooms:",
		text_window     = "Select font for mob text window:",
	}
	menu = menu.."<|>fonts|>defaults|restore all||"
	table.insert(options, function()
		mdt_restore_every_default_font()
	end)
	for k, v in pairs(plugin_fonts) do
		menu = menu..k:gsub("_", " ").."|"
		table.insert(options, function()
			mdt_restore_default_font(k)
		end)
	end
	menu = menu.."<|>custom|"
	for k, v in pairs(plugin_fonts) do
		menu = menu..k:gsub("_", " ").."|"
		table.insert(options, function()
			local t = {}
			local title = "Custom Font Picker"
			local fonts, t = {}, utils.getfontfamilies()
			for k, _ in pairs(t) do
				table.insert(fonts, k)
			end
			mdt_select_custom_font(k, fonts, utils.listbox(v, title, fonts))
		end)
		
	end
	menu = menu.."<|<|>font size|"
	for i = 8, 20 do
		menu = menu..(selected_font_size == i and "+" or "")..tostring(i).."|"
		table.insert(options, function()
			selected_font_size = i
			mdt_draw_text(mdt.styles)
		end)	
	end
	menu = menu.."<|<"
	menu = (string.gsub(menu, "%W%l", string.upper):sub(2));menu = "!"..menu:gsub("(||+)", "||"):gsub("(V%d)", string.lower)
    result = string.lower(WindowMenu(win[mw], 
      WindowInfo(win[mw], 14), --x
      WindowInfo(win[mw], 15), --y
      menu))
    if result ~= "" then
        options[tonumber(result)]()
    end
end
