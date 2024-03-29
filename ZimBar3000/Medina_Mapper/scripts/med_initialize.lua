--------------------------------------------------------------------------------
--   INSTALL AND SAVE
--------------------------------------------------------------------------------
function on_plugin_start()
	require "tprint" 
	require "serialize" 
	require "var"
	require "pairsbykeys"
    require "check"
    win = "medina_map"..MED -- define window name
    medina_get_variables()
    medina_get_regex()
    medina_get_trigs()
    medina_get_windows()
    medina_window_setup(window_width, window_height) -- define window attributes
    medina_get_hotspots(med.dimensions)
    if (type(window_pos_x) == "number") and (type(window_pos_y) == "number") then
	   WindowPosition(win, window_pos_x, window_pos_y, 0, 2)
    end
end
-- load variables
function medina_get_variables() 
	MDT = "a4f2436e923441ce4ba7ab6b" -- mdt plugin
	colours_database =  GetPluginInfo(MED , 20):gsub("\\([A-Za-z_]+)\\$", "\\shared\\").."_colours.db"
	fonts_database   =  GetPluginInfo(MED , 20):gsub("\\([A-Za-z_]+)\\$", "\\shared\\").."_fonts.db"
	FIXED_TITLE_HEIGHT = 16
    default_window_width, default_window_height = 300, 300
    window_width, window_height = tonumber(GetVariable("window_width") or default_window_width), tonumber(GetVariable("window_height") or default_window_height)
    window_pos_x, window_pos_y = tonumber(GetVariable("window_pos_x")), tonumber(GetVariable("window_pos_y"))
    arrow_set = GetVariable("arrow_set") or "default"
    assert(loadstring(GetVariable("med") or ""))()
    if not med then med = {}; medina_reset_rooms() end
    med.exit_counts = medina_get_exit_counts(med.rooms) -- for brief/night solving
    medina_get_colours()
    med.players = {} -- set containing playernames with associated colour
    med.sync = {received = false, data = {}, is_valid = false}
    med.look_room = false     -- store the room we are looking at
    med.scry_room = false     -- store the room we are scrying
    med.herd_path = {}        -- highling of consecutive matching exits
    -- keep track of all rooms (or all possible rooms) in our queued trajectory
    -- where index 1 refers to our current room (or rooms)
    -- and the last item in the table refers to our final trajectory room
    -- we will also reserve index 0 ro store history of previous room
    med.sequence = {}
    -- our queued commands
    med.commands = {move = {count = 0}, look = {count = 0}}
    med.is_in_medina = false
    -- check if mdt plugin is installed and grab
    
end
-- save variables
function OnPluginSaveState () 
	var.med = "med = "..serialize.save_simple(med)
	var.window_width = window_width
	var.window_height = window_height
	var.window_pos_x = WindowInfo(win, 10)
	var.window_pos_y = WindowInfo(win, 11)
	var.arrow_set = arrow_set
end

function OnPluginInstall() end
function OnPluginEnable() WindowShow(win, true) end -- show miniwindow on enable
function OnPluginDisable() WindowShow(win, false) end -- hide miniwindow on disable
function OnPluginClose() WindowShow(win, false) end -- hide miniwindow on close

