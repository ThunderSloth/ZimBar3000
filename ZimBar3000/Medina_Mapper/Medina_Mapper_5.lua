--[[ Zimbus's
   _____             .___.__                   _____                                    ._.
  /     \   ____   __| _/|__| ____ _____      /     \ _____  ______ ______   ___________| |
 /  \ /  \_/ __ \ / __ | |  |/    \\__  \    /  \ /  \\__  \ \____ \\____ \_/ __ \_  __ \ |
/    Y    \  ___// /_/ | |  |   |  \/ __ \_ /    Y    \/ __ \|  |_> >  |_> >  ___/|  | \/\|
\____|__  /\___  >____ | |__|___|  (____  / \____|__  (____  /   __/|   __/ \___  >__|   __
        \/     \/     \/         \/     \/          \/     \/|__|   |__|        \/       \]]
--------------------------------------------------------------------------------
--   LOAD FUNCTIONS
--------------------------------------------------------------------------------
local funcs = {

	'initialize', -- load variables, plugin callbacks
	
	'setup',      -- create windows, calculate dimensions/coordinates, resize windows, load fonts/images
	
	'resets',     -- generating/resetting metatable data/timers
	
	'colours',    -- get colours
	
	'regex',	  -- compile regular expressions
	
	'gmcp',       -- gmcp initiation and events
	
	'triggers',   -- construct room triggers, do xml injections
	
	'graphics',   -- draw miniwindow
	              
	'hotspots',   -- interactive zones, drag/resize/other handlers
	
	'menu',       -- titlebar and room menus
	
	'on_trigger', -- trigger events
	
	'on_alias',   -- alias events
	
	'toggle',     -- enter/exit handling
	
	'move',       -- movement/look handling; command normalization
	
	'solve',      -- exit solving
	
	'mobs',       -- mob/player tracking
			
	'sync',       -- send/recieve map data with other players  
	
	'bfs',        -- breadth-first search (shortest-path algorithm)
	
	'debug',      -- expose internal variables
	
	'config',     -- mudside compatability configuration
	
	'help',       -- help-file
	
}
for _, f in ipairs(funcs) do
	dofile (GetPluginInfo (GetPluginID (), 20) .. "scripts\\med_" .. (f) .. ".lua")
end
--------------------------------------------------------------------------------
--   START EXECUTION HERE
--------------------------------------------------------------------------------

on_plugin_start()

medina_print_map()

--tprint(med.rooms)
--tprint(med.exit_counts)
--tprint(med.colours)
--tprint(med.coordinates)
--tprint(med.sequence)
--tprint(med.commands.move)
--tprint(med.commands.look)
