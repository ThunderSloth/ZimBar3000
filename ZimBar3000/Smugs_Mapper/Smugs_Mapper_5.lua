--[[ Zimbus's
  _________                             _____                                    ._.
 /   _____/ _____  __ __  ____  ______ /     \ _____  ______ ______   ___________| |
 \_____  \ /     \|  |  \/ ___\/  ___//  \ /  \\__  \ \____ \\____ \_/ __ \_  __ \ |
 /        \  Y Y  \  |  / /_/  >___ \/    Y    \/ __ \|  |_> >  |_> >  ___/|  | \/\|
/_______  /__|_|  /____/\___  /____  >____|__  (____  /   __/|   __/ \___  >__|   __
        \/      \/     /_____/     \/        \/     \/|__|   |__|        \/       \]]
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
	
	'triggers',   -- room trigger events, construct room triggers, do xml injections
	
	'graphics',   -- draw miniwindow
	              
	'hotspots',   -- interactive zones, drag/resize/other handlers
	
	'menu',       -- titlebar and room menus
	
	'toggle',     -- enter/exit handling
	
	'move',       -- movement/look handling; command normalization, related trigger/alias events
	
	'mobs',       -- mob/player tracking
				
	'bfs',        -- breadth-first search (shortest-path algorithm)
	
	'debug',      -- expose internal variables
	
	'config',     -- mudside compatability configuration
	
	'help',       -- help-file
	
}
for _, f in ipairs(funcs) do
	dofile (GetPluginInfo (GetPluginID (), 20) .. "scripts\\smu_" .. (f) .. ".lua")
end
--------------------------------------------------------------------------------
--   START EXECUTION HERE
--------------------------------------------------------------------------------
on_plugin_start()

smugs_print_map()
