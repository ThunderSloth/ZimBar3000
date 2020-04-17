--------------------------------------------------------------------------------
--   TITLEBAR MENU
--------------------------------------------------------------------------------
function smugs_get_title_menu()
    local options = {}
    local menu = "!^Smugs Mapper v"..GetPluginInfo (GetPluginID (), 19)
    menu = menu.."||Help||Configure||>Options|>Colours|"
    table.insert(options, function()
        on_alias_smugs_help()
    end)
    table.insert(options, function()
        on_alias_smugs_configure()
    end)
    for m, f in pairs({custom = smugs_select_custom_colour, defaults = smugs_restore_default_colour}) do
		menu = menu..">"..m.."|"
		if m == "defaults" then
			menu = menu.."restore all||"
			table.insert(options, function()
				smugs_restore_every_default_colour()
			end)		
		end
		local section = false
		for k, v in pairsByKeys(smu.colours) do
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
	menu = menu.."<"
	menu = (string.gsub(menu, "%W%l", string.upper):sub(2));menu = "!"..menu:gsub("(||+)", "||"):gsub("(V%d)", string.lower)
    result = string.lower(WindowMenu(win, 
      WindowInfo(win, 14), --x
      WindowInfo(win, 15), --y
      menu))
    if result ~= "" then
        options[tonumber(result)]()
    end
end
