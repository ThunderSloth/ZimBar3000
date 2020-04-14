--------------------------------------------------------------------------------
--   INSTALL AND SAVE
--------------------------------------------------------------------------------
function on_plugin_start()
    require "tprint"
    require "serialize"
    require "var"
    win = {"map" .. GetPluginID(), "text" .. GetPluginID(), map = "map_staging" .. GetPluginID(), text = "text_staging" .. GetPluginID()}
    mdt_get_variables()
    mdt_get_regex()
    mdt_get_windows()
    mdt_window_setup(window_width, window_height)
    mdt_get_hotspots(mdt.dimensions)
    mdt_get_triggers()
    mdt_pos_window()
end
-- load variables
function mdt_get_variables()
	quowmap_database =  GetPluginInfo(GetPluginID (), 20):gsub("\\([A-Za-z_]+)\\$", "\\shared\\").."_quowmap_database.db"
	FIXED_TITLE_HEIGHT = 16
    assert(loadstring(GetVariable("window_width" ) or ""))()
    assert(loadstring(GetVariable("window_height") or ""))()
    window_width  = window_width  or {300, 600}
    window_height = window_height or {300, 300 + FIXED_TITLE_HEIGHT}
    assert(loadstring(GetVariable("window_pos_x" ) or ""))()
    assert(loadstring(GetVariable("window_pos_y" ) or ""))()  
    -- 'rooms' will be used to store room data by x, y location relative to the origin ('you' in the center)
    -- 'locations' will be used to store location data by room id
    -- 'fight rooms' will contain which rooms have mobs actively engaged in battle (with 'you')
	-- 'text' will contain room info for our text window
	mdt = mdt or {rooms = {range = 0}, locations = {}, fight_room = {}, text = {}}
	mdt.title = {"Map Door Text: Map", "Map Door Text: Text"}
    mdt.colours = mdt_get_colours()
    mdt.map_ids = mdt_get_map_ids()  
    mdt.special_areas = mdt_get_special_areas()
    mdt.sequence = {}
    mdt.commands = {move = {count = 0}, look = {count = 0}}
    mdt.styles = {}
end
-- position windows
function mdt_pos_window()
	if type(window_pos_x) == 'table' and type(window_pos_y) == 'table' then
		for i in ipairs(win) do
			window_pos_x[i] = tonumber(window_pos_x[i])
			window_pos_y[i] = tonumber(window_pos_y[i])
			if (type(window_pos_x[i]) == "number") and (type(window_pos_y[i]) == "number") then
			   WindowPosition(win[i], window_pos_x[i], window_pos_y[i], 0, 2)
			end    
		end
    else
        for i in ipairs(win) do
			window_pos_x = {WindowInfo(win[1], 10), WindowInfo(win[2], 10)}
			window_pos_y = {WindowInfo(win[1], 11), WindowInfo(win[2], 11)}
        end
    end
end
-- map ids
function mdt_get_map_ids()
	local ids = {"Ankh-Morpork", "AM Assassins", "AM Buildings", "AM Cruets", "AM Docks", "AM Guilds", "AM Isle of Gods", "Shades Maze", "Temple of Small Gods", "AM Temples", "AM Thieves", "Unseen University", "AM Warriors", "Pseudopolis Watch House", "Magpyr's Castle", "Bois", "Bes Pelargic", "BP Buildings", "BP Estates", "BP Wizards", "Brown Islands", "Death's Domain", "Djelibeybi", "IIL - DJB Wizards", "Ephebe", "Ephebe Underdocks", "Genua", "Genua Sewers", "GRFLX Caves", "Hashishim Caves", "Klatch Region", "Lancre Region", "Mano Rossa", "Monks of Cool", "Netherworld", false, "Pumpkin Town", "Ramtops Regions", "Sto-Lat", "Academy of Artificers", "Cabbage Warehouse", "AoA Library", "Sto-Lat Sewers", "Sprite Caves", "Sto Plains Region", "Uberwald Region", "UU Library", "Klatchian Farmsteads", "CTF Arena", "PK Arena", "AM Post Office", "Ninja Guild", "The Travelling Shop", "Slippery Hollow", "House of Magic - Creel", "Special Areas", "Skund Wolf Trail", "Medina", "Copperhead", "The Citadel", "AM Fools' Guild", "Thursday's Island", "SS Unsinkable", }
	return ids
end

function mdt_get_special_areas()
	local ids = {"AMShades", "BPMedina"}
	local t = {}
	for _, v in ipairs(ids) do
		t[v] = true
	end
	return t
end
-- save variables
function OnPluginSaveState () 
	window_pos_x = {WindowInfo(win[1], 10), WindowInfo(win[2], 10)}
	window_pos_y = {WindowInfo(win[1], 11), WindowInfo(win[2], 11)}
	var.window_width  = "window_width  = " ..serialize.save_simple(window_width)
	var.window_height = "window_height = " ..serialize.save_simple(window_height)
	var.window_pos_x  = "window_pos_x  = " ..serialize.save_simple(window_pos_x)
	var.window_pos_y  = "window_pos_y  = " ..serialize.save_simple(window_pos_y)
end

function OnPluginInstall() end
function OnPluginEnable()  WindowShow(win[1], true ); WindowShow(win[2], true ) end -- show miniwindow on enable
function OnPluginDisable() WindowShow(win[1], false); WindowShow(win[2], false) end -- hide miniwindow on disable
function OnPluginClose()   WindowShow(win[1], false); WindowShow(win[2], false) end -- hide miniwindow on close
