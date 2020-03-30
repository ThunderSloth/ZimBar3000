--------------------------------------------------------------------------------
--   INSTALL AND SAVE
--------------------------------------------------------------------------------
function on_plugin_start()
    require "tprint"
    require "serialize"
    win = "medina_map"..GetPluginID() -- define window name
    medina_get_variables()
    medina_get_regex()
    medina_get_triggers()
    medina_get_windows()
    medina_window_setup(window_width, window_height) -- define window attributes
    medina_get_hotspots(med.dimensions)
    if (type(window_pos_x) == "number") and (type(window_pos_y) == "number") then
	   WindowPosition(win, window_pos_x, window_pos_y, 0, 2)
    end
    --medina_get_timers()
end
-- load variables
function medina_get_variables() 
    defualt_window_width, defualt_window_height = 300, 300
    window_width, window_height = tonumber(GetVariable("window_width") or defualt_window_width), tonumber(GetVariable("window_height") or defualt_window_height)
    window_pos_x, window_pos_y = tonumber(GetVariable("window_pos_x")), tonumber(GetVariable("window_pos_y"))
    assert(loadstring(GetVariable("med") or ""))()
    if not med then med = {}; medina_reset_rooms() end
    med.exit_counts = medina_get_exit_counts(med.rooms) -- for brief/night solving
    med.colours = medina_get_colours()
    med.players = {} -- set containing playernames with associated colour
    med.sync = {received = false, data = {}, is_valid = false}
    med.commands = {move = {count = 0}, look = {count = 0}}
    -- keep track of all rooms (or all possible rooms) in our queued trajectory
    -- where index 1 refers to our current room (or rooms)
    -- and the last item in the table refers to our final trajectory room
    -- we will also reserve index 0 ro store history of previous room
    med.sequence = {}
    med.is_in_medina = false
end
-- save variables
function OnPluginSaveState () 
	SetVariable("med", "med = "..serialize.save_simple(med))
	SetVariable("window_width", window_width)
	SetVariable("window_height", window_height)
	SetVariable("window_pos_x", WindowInfo(win, 10))
	SetVariable("window_pos_y", WindowInfo(win, 11))
end

function OnPluginInstall() end
function OnPluginEnable() WindowShow(win, true) end -- show miniwindow on enable
function OnPluginDisable() WindowShow(win, false) end -- hide miniwindow on disable
function OnPluginClose() WindowShow(win, false) end -- hide miniwindow on close

