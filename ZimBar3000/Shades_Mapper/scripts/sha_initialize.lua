--------------------------------------------------------------------------------
--   INSTALL AND SAVE
--------------------------------------------------------------------------------
function on_plugin_start()
    require "tprint"
    require "serialize"
    require "var"	
    require "pairsbykeys"
	require "check"
    win = "shades_map"..SHA -- define window name
    shades_get_variables()
    shades_get_windows()
    shades_window_setup(window_width, window_height)
    shades_get_hotspots(sha.dimensions)
    shades_get_regex()
    shades_get_trigs()
    if (type(window_pos_x) == "number") and (type(window_pos_y) == "number") then
	   WindowPosition(win, window_pos_x, window_pos_y, 0, 2)
    end
end

function shades_get_variables()
	MDT = "a4f2436e923441ce4ba7ab6b" -- mdt plugin
	colours_database =  GetPluginInfo(SHA, 20):gsub("\\([A-Za-z_]+)\\$", "\\shared\\").."_colours.db"
	fonts_database   =  GetPluginInfo(SHA, 20):gsub("\\([A-Za-z_]+)\\$", "\\shared\\").."_fonts.db"
	FIXED_TITLE_HEIGHT = 16
    defualt_window_width, defualt_window_height = 300, 300
    window_width, window_height = tonumber(GetVariable("window_width") or defualt_window_width), tonumber(GetVariable("window_height") or defualt_window_height)
    window_pos_x, window_pos_y = tonumber(GetVariable("window_pos_x")), tonumber(GetVariable("window_pos_y"))
    assert(loadstring(GetVariable("sha") or ""))()
    if not sha then sha = {}; shades_reset_rooms() end
	shades_get_colours()
	sha.commands = {count = 0}
	sha.sequence = {}
	sha.scry_room = false
	sha.players = {}
	sha.is_in_shades = false
end

function OnPluginSaveState () -- save variables
	var.sha = "sha = "..serialize.save_simple(sha)
	var.window_width = window_width
	var.window_height = window_height
	var.window_pos_x = WindowInfo(win, 10)
	var.window_pos_y = WindowInfo(win, 11)
end

function OnPluginInstall() end
function OnPluginEnable() WindowShow(win, true) end -- show miniwindow on enable
function OnPluginDisable() WindowShow(win, false) end -- hide miniwindow on disable
function OnPluginClose() WindowShow(win, false) end -- hide miniwindow on close

