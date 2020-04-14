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
