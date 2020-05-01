
--[[Zimbus's
   _____               ________                     ___________              __  ._.
  /     \ _____  ______\______ \   ____   __________\__    ___/___ ___  ____/  |_| |
 /  \ /  \\__  \ \____ \|    |  \ /  _ \ /  _ \_  __ \|    |_/ __ \\  \/  /\   __\ |
/    Y    \/ __ \|  |_> >    `   (  <_> |  <_> )  | \/|    |\  ___/ >    <  |  |  \|
\____|__  (____  /   __/_______  /\____/ \____/|__|   |____| \___  >__/\_ \ |__|  __
        \/     \/|__|          \/                                \/      \/       \]]
--------------------------------------------------------------------------------
--   LOAD FUNCTIONS
--------------------------------------------------------------------------------
local funcs = {

	'initialize', -- load variables, plugin callbacks
	
	'setup',      -- create windows, calculate dimensions/coordinates, resize windows, load images
	
	'fonts',      -- load fonts
	
	'parse',      -- main map door text parsing function
	
	'colours',    -- get colours
	
	'regex',	  -- compile regular expressions
	
	'gmcp',       -- gmcp initiation and events, plus cross-plugin communication
	
	'triggers',   -- xml injections
	
	'graphics',   -- draw miniwindows
	              
	'hotspots',   -- interactive zones, drag/resize/other handlers
	
	'menu',       -- titlebar and room menus
	
	'toggle',     -- enter/exit handling
	
	'move',       -- movement/look handling, related trigger/alias events
	
	'mobs',       -- mob/player tracking
				
	'bfs',        -- breadth-first search (shortest-path algorithm)
	
	'debug',      -- debugging aliases
	
	'config',     -- mudside compatability configuration
	
	'help',       -- help-file
	
}
for _, f in ipairs(funcs) do
	dofile (MDT_PATH .. "scripts\\mdt_" .. (f) .. ".lua")
end
--------------------------------------------------------------------------------
--   START EXECUTION HERE
--------------------------------------------------------------------------------

on_plugin_start()

mdt_parse_map_door_text("")

