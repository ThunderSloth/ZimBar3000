--[[ Zimbus's
____   ____                                    _____     
\   \ /   /___ ___.__._____     ____   ____   /     \ _____  ______ ______   ___________ 
 \   Y   /  _ <   |  |\__  \   / ___\_/ __ \ /  \ /  \\__  \ \____ \\____ \_/ __ \_  __ \
  \     (  <_> )___  | / __ \_/ /_/  >  ___//    Y    \/ __ \|  |_> >  |_> >  ___/|  | \/
   \___/ \____// ____|(____  /\___  / \___  >____|__  (____  /   __/|   __/ \___  >__|   
               \/          \//_____/      \/        \/     \/|__|   |__|        \/  ]]   
--------------------------------------------------------------------------------
--   LOAD FUNCTIONS
--------------------------------------------------------------------------------
local funcs = {

	'initialize', -- load: variables, metatable, resets, plugin callbacks
	
	'setup',      -- create windows, calculate dimensions/coordinates, resize windows, load fonts/images, generate sea-map elements
	
	'colours',    -- get coulours        
	
	'regex',	  -- compiler regular expressions: mdt, hull condition, fires, dragons, title-stripping
	
	'gmcp',       -- gmcp initiation and events
	
	'triggers',   -- construct room triggers and colorize existing triggers
	
	'graphics',   -- dynamic drawing: main map, base/underlay, rooms, exits/doors, vertical text, colour-fading,  
	              -- boat elements, titlebar, xp/time, dragon circles/guages, monsters
	              
	'hotspots',   -- interactive zones: main window, steering-mode, monsters; drag/resize/other handlers
	
	'menus',      -- drop-down menus: titlebar, rooms, objects, vertical text, compass (steering-mode), dragon circle/guages, monsters
	
	'attributes', -- attribute events: part, stage, ice, fire/lightning, hull (condition, ice, seaweed), serpent, kraken, rope, mast, shelves
	
	'toggle',     -- enter/exit handling
	
	'move',       -- movement tracking, command normalization, item dragging, player/dragon tracking
	
	'look',       -- look handling: command normalization/tracking; updates from look-room: description (mast/shelves), 
				  -- condition (fire/ice), speed, stage (weather/monster), thyngs (players/dragons), objects (and fires)
				  
	'steering',   -- captain-mode toggle, look-sea, tracking: steering-wheel, boat direction, movement detection
	
	'dragons',    -- dragon tracking: hunger/boredom levels, sleep, circle, get/drop, play/feed
	
	'objects',    -- object (ropes, nails, boards etc.) parsing and tracking
	
	'tools',      -- tool (held-items, vertically displayed) editing, handling and tracking
	
	'junk',       -- junk (store-room items) parsing and tracking
	
	'mdt',        -- map door text (from gmcp data) parsing
	
	'bfs',        -- breadth-first search (shortest-path algorithm)
	
	'stats',      -- xp/time, genrate report
	
	'config',     -- mudside compatability configuration
	
	'help',       -- help-file
	
}
for _, f in ipairs(funcs) do
	dofile (GetPluginInfo (GetPluginID (), 20) .. "scripts\\" .. (f) .. ".lua")
end
--------------------------------------------------------------------------------
--   START EXECUTION HERE
--------------------------------------------------------------------------------
on_plugin_start()

function show_example()
	voy.steering = true
	local map = {
		"",
		" ??? ", 
		".@~$=",    
		"nG@O-",
		"^_~v*",
		" HPH ",
	}
	on_trigger_voyage_look_sea("name", "line", map, "styles")
	voy.speed = 4
	voyage_print_map()
end

-- word to number charts, compass
-- timer for monster

show_example()

