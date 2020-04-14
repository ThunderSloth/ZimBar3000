--------------------------------------------------------------------------------
--   INSTALL AND SAVE
--------------------------------------------------------------------------------
function on_plugin_start()
    require "tprint"
    require "serialize"
    require "var"
    win = "smugs_map"..GetPluginID() -- define window name
    smugs_get_variables()
    smugs_get_windows()
    smugs_window_setup(window_width, window_height)
    smugs_get_hotspots(smu.dimensions)
    smugs_get_regex()
    smu_get_triggers()
    if (type(window_pos_x) == "number") and (type(window_pos_y) == "number") then
	   WindowPosition(win, window_pos_x, window_pos_y, 0, 2)
    end
end

function smugs_get_variables()
    defualt_window_width, defualt_window_height = 300, 300
    window_width, window_height = tonumber(GetVariable("window_width") or defualt_window_width), tonumber(GetVariable("window_height") or defualt_window_height)
    window_pos_x, window_pos_y = tonumber(GetVariable("window_pos_x")), tonumber(GetVariable("window_pos_y"))
    assert(loadstring(GetVariable("smu") or ""))()
    if not smu then smu = {}; smugs_reset_rooms() end
	smu.colours = smugs_get_colours()
	smu.commands = {count = 0}
	smu.sequence = {}
	smu.players = {}
	smu.is_in_smugs = false
    for k, v in pairs(smu.rooms) do -- create inverse set of exits
        smu.rooms[k].path = smu.rooms[k].path or {}
        for r, x in pairs(v.exits) do
            smu.rooms[k].path[x] = r
        end
    end
end

function OnPluginSaveState () -- save variables
	var.window_width  = window_width
	var.window_height = window_height
	var.window_pos_x  = WindowInfo(win, 10)
	var.window_pos_y  = WindowInfo(win, 11)
end

function OnPluginInstall() end
function OnPluginEnable() WindowShow(win, true) end -- show miniwindow on enable
function OnPluginDisable() WindowShow(win, false) end -- hide miniwindow on disable
function OnPluginClose() WindowShow(win, false) end -- hide miniwindow on close
