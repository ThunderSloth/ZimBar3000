--------------------------------------------------------------------------------
--   INSTALL AND SAVE
--------------------------------------------------------------------------------
function on_plugin_start()
    require "tprint"
    require "serialize"
    require "var"
	require "pairsbykeys"
	require "check"
    win = {"map" .. MDT, "text" .. MDT, map = "map_staging" .. MDT, text = "text_staging" .. MDT}
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
	quowmap_database =  GetPluginInfo(MDT, 20):gsub("\\([A-Za-z_]+)\\$", "\\shared\\").."_quowmap_database.db"
	colours_database =  GetPluginInfo(MDT, 20):gsub("\\([A-Za-z_]+)\\$", "\\shared\\").."_colours.db"
	fonts_database   =  GetPluginInfo(MDT, 20):gsub("\\([A-Za-z_]+)\\$", "\\shared\\").."_fonts.db"
	FIXED_TITLE_HEIGHT = 16
    assert(loadstring(GetVariable("window_width" ) or ""))()
    assert(loadstring(GetVariable("window_height") or ""))()
    window_width  = window_width  or {300, 600}
    window_height = window_height or {300, 300 + FIXED_TITLE_HEIGHT}
    assert(loadstring(GetVariable("window_pos_x" ) or ""))()
    assert(loadstring(GetVariable("window_pos_y" ) or ""))()  
    selected_font_size = GetVariable("selected_font_size")
    selected_font_size = tonumber(selected_font_size) or 13
    -- 'rooms' will be used to store room data by x, y location relative to the origin ('you' in the center)
    -- 'locations' will be used to store location data by room id
    -- 'fight rooms' will contain which rooms have mobs actively engaged in battle (with 'you')
	-- 'text' will contain room info for our text window
	mdt = mdt or {rooms = {range = 0}, locations = {}, fight_room = {}, text = {}}
	mdt.title = {"Map Door Text: Map", "Map Door Text: Text"}
    mdt_get_colours()
    mdt_get_map_ids()  
    mdt_get_special_areas()
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
	mdt.map_ids = {"Ankh-Morpork", "AM Assassins", "AM Buildings", "AM Cruets", "AM Docks", "AM Guilds", "AM Isle of Gods", "Shades Maze", "Temple of Small Gods", "AM Temples", "AM Thieves", "Unseen University", "AM Warriors", "Pseudopolis Watch House", "Magpyr's Castle", "Bois", "Bes Pelargic", "BP Buildings", "BP Estates", "BP Wizards", "Brown Islands", "Death's Domain", "Djelibeybi", "IIL - DJB Wizards", "Ephebe", "Ephebe Underdocks", "Genua", "Genua Sewers", "GRFLX Caves", "Hashishim Caves", "Klatch Region", "Lancre Region", "Mano Rossa", "Monks of Cool", "Netherworld", false, "Pumpkin Town", "Ramtops Regions", "Sto-Lat", "Academy of Artificers", "Cabbage Warehouse", "AoA Library", "Sto-Lat Sewers", "Sprite Caves", "Sto Plains Region", "Uberwald Region", "UU Library", "Klatchian Farmsteads", "CTF Arena", "PK Arena", "AM Post Office", "Ninja Guild", "The Travelling Shop", "Slippery Hollow", "House of Magic - Creel", "Special Areas", "Skund Wolf Trail", "Medina", "Copperhead", "The Citadel", "AM Fools' Guild", "Thursday's Island", "SS Unsinkable", }
end

function mdt_get_special_areas()
	local ids = {
		"AMShades", "BPMedina",
		-- smugs
		"ebff897af2b8bb6800a9a8636143099d0714be07",
		"c0495c993b8ba463e6b3008a88f962ae28084582",
		"501c0b35601b8649c57bb98b8a1d6c2d1f1cea02",
		"8c022638ba642395094bc4dc7ba0a3aaf64c02c1",
		"898b33dcc8da01ef21b064f66062ea2f89235f5f",
		"0b43758d635f631d46b1a1f041fd651e446856ca",  
		"1793722d05f49d48f28ce3a49e8b97d59158b916",            
		"e28d07530ae163f93ade722c780ce897a4e93a15",            
		"a184520b84e948f89e621ab50a500c47faefa920",            
		"8048df6be9b61c0f49e988924185ce937a38814b",            
		"f026140904d9f0c910b4975b937b20189f225605",            
		"952786ea48134ac3505cbabb6567ef35fad13af8",            
		"b9bb8741399c7bdf6836cb06148c2e7c4f033853",            
		"0663269ccae61f6b313cb378213c74131b394fbc",            
		"03a3ca540e9c7fc9dfa914d213b974a0b207f596",            
		"3fedc83188999bd20733ba77f02409aee8011127",            
		"033906622a542f9e0550608b86932dff52d7e8c2",            
		"6ef15a8643f1515f8a96fb646dd8e2ab80bade15",            
		"ddabfb40040805889125b223a2d679e0a9716fd2",            
		"468f6243998bda671161e6afe079ff5fac866fc1",            
		"372dd28add7bfc7ed26f4da4047a501afcf24696",            
		"d57af869e7ff7abe31ceb1245ccbc6d47df49b7b",            
		"a9734849233e5f97fd676676a9853b22b0cb22e8",            
		"4e6aef2cd732fb35c2c110d768605f4aa56194af",            
		"16a0b8c39025147f9f87cf860b76380af6c9e1d4",			
		"886a1404021cdfb21668823aa0ab2cefd05fbcd1",}
	mdt.special_areas = {}
	for _, v in ipairs(ids) do
		mdt.special_areas[v] = true
	end
end
-- save variables
function OnPluginSaveState () 
	window_pos_x = {WindowInfo(win[1], 10), WindowInfo(win[2], 10)}
	window_pos_y = {WindowInfo(win[1], 11), WindowInfo(win[2], 11)}
	var.window_width  = "window_width  = " ..serialize.save_simple(window_width)
	var.window_height = "window_height = " ..serialize.save_simple(window_height)
	var.window_pos_x  = "window_pos_x  = " ..serialize.save_simple(window_pos_x)
	var.window_pos_y  = "window_pos_y  = " ..serialize.save_simple(window_pos_y)
	var.selected_font_size = selected_font_size
end

function OnPluginInstall() end
function OnPluginEnable()  WindowShow(win[1], true ); WindowShow(win[2], true ) end -- show miniwindow on enable
function OnPluginDisable() WindowShow(win[1], false); WindowShow(win[2], false) end -- hide miniwindow on disable
function OnPluginClose()   WindowShow(win[1], false); WindowShow(win[2], false) end -- hide miniwindow on close
