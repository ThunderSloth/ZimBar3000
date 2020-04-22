 --[[ Zimbus's
  _________.__                .___               _____                                    ._.
 /   _____/|  |__ _____     __| _/____   ______ /     \ _____  ______ ______   ___________| |
 \_____  \ |  |  \\__  \   / __ |/ __ \ /  ___//  \ /  \\__  \ \____ \\____ \_/ __ \_  __ \ |
 /        \|   Y  \/ __ \_/ /_/ \  ___/ \___ \/    Y    \/ __ \|  |_> >  |_> >  ___/|  | \/\|
/_______  /|___|  (____  /\____ |\___  >____  >____|__  (____  /   __/|   __/ \___  >__|   __
        \/      \/     \/      \/    \/     \/        \/     \/|__|   |__|        \/       \]]
--------------------------------------------------------------------------------
--   LOAD FUNCTIONS
--------------------------------------------------------------------------------
local funcs = {

	'initialize', -- load variables, plugin callbacks
	
	'setup',      -- create windows, calculate dimensions/coordinates, resize windows, load images
	
	'fonts',      -- load fonts
	
	'resets',     -- generating/resetting metatable data/timers
	
	'colours',    -- get colours
	
	'regex',	  -- compile regular expressions
	
	'gmcp',       -- gmcp initiation and events, plus cross-plugin communication
	
	'triggers',   -- room trigger events, construct room triggers, do xml injections
	
	'graphics',   -- draw miniwindow
	              
	'hotspots',   -- interactive zones, drag/resize/other handlers
	
	'menu',       -- titlebar and room menus
	
	'toggle',     -- enter/exit handling
	
	'move',       -- movement/look handling; command normalization, related trigger/alias events
	
	'mobs',       -- mob/player tracking
				
	'bfs',        -- breadth-first search (shortest-path algorithm)
	
	'config',     -- mudside compatability configuration
	
	'help',       -- help-file
	
}
for _, f in ipairs(funcs) do
	dofile(SHA_PATH .. "scripts\\sha_" .. (f) .. ".lua")
end
----------------------------------------------------------------------
--   START EXECUTION HERE
--------------------------------------------------------------------------------
on_plugin_start()

shades_print_map()

