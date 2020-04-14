
--[[Zimbus's
   _____               ________                     ___________              __  ._.
  /     \ _____  ______\______ \   ____   __________\__    ___/___ ___  ____/  |_| |
 /  \ /  \\__  \ \____ \|    |  \ /  _ \ /  _ \_  __ \|    |_/ __ \\  \/  /\   __\ |
/    Y    \/ __ \|  |_> >    `   (  <_> |  <_> )  | \/|    |\  ___/ >    <  |  |  \|
\____|__  (____  /   __/_______  /\____/ \____/|__|   |____| \___  >__/\_ \ |__|  __
        \/     \/|__|          \/                                \/      \/       \]]
--------------------------------------------------------------------------------
--   INSTALL AND SAVE
--------------------------------------------------------------------------------
function on_plugin_start()
    require "tprint"
    require "serialize"
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
	SetVariable("window_width" , "window_width  = " ..serialize.save_simple(window_width))
	SetVariable("window_height", "window_height = " ..serialize.save_simple(window_height))
	SetVariable("window_pos_x" , "window_pos_x  = " ..serialize.save_simple(window_pos_x))
	SetVariable("window_pos_y" , "window_pos_y  = " ..serialize.save_simple(window_pos_y))
end

function OnPluginInstall() end
function OnPluginEnable()  WindowShow(win[1], true ); WindowShow(win[2], true ) end -- show miniwindow on enable
function OnPluginDisable() WindowShow(win[1], false); WindowShow(win[2], false) end -- hide miniwindow on disable
function OnPluginClose()   WindowShow(win[1], false); WindowShow(win[2], false) end -- hide miniwindow on close
--------------------------------------------------------------------------------
--   MINIWINDOW SETUP
--------------------------------------------------------------------------------
function mdt_get_windows(dim) -- dimensions
    local col = mdt.colours.window
    for k in pairs(win) do
		WindowCreate(win[k], 0, 0, 0, 0, miniwin.pos_center_all, 0, col.background)
	end
    WindowSetZOrder(win[1], 201)
    WindowSetZOrder(win[2], 200)
end

function mdt_window_setup(window_width, window_height) -- define window attributes
    local function get_window_dimensions(window_width, window_height)
		local dim = {}
        dim.window = {
            {x = window_width[1], y = window_height[1]},
            {x = window_width[2], y = window_height[2]},}
        dim.buffer = {
			{x = 0, y = 0},
            {x = 5, y = 5},}
        dim.map = {
            x = (dim.window[1].x - dim.buffer[1].x * 2), 
            y = (dim.window[1].y - dim.buffer[1].y * 2) - FIXED_TITLE_HEIGHT }
        for _, k in ipairs({'block', 'room', 'thyng', 'exit', 'door'}) do
			dim[k] = {}
        end
        local min_vision, max_vision = 0, 5
        for i = min_vision, max_vision do
			dim.block[i] = {
				x = dim.map.x / (i * 2 + 1), 
				y = dim.map.y / (i * 2 + 1),} 
			dim.room[i] = {
				x = dim.block[i].x * .6, 
				y = dim.block[i].y * .6}
			dim.thyng[i] = {
				x = dim.room[i].x * .75, 
				y = dim.room[i].y * .75,}
			dim.exit[i] = {
				x = (dim.block[i].x - dim.room[i].x), 
				y = (dim.block[i].y - dim.room[i].y),}	
			dim.door[i] = {
				x = (dim.block[i].x - dim.room[i].x) / 2, 
				y = (dim.block[i].y - dim.room[i].y) / 2,}
        end

        return dim
    end

    local function get_coordinates(dim) --dimensions
        local function get_exit_coordinates(dim, i, dir, room_center)
			local x1 = room_center.x + (dim.room[i].x / 2) *  dir[1]
			local y1 = room_center.y + (dim.room[i].y / 2) * -dir[2]
			local x2 = x1 + dim.exit[i].x *  dir[1]
			local y2 = y1 + dim.exit[i].y * -dir[2]
			return {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
        end
        local function get_door_coordinates(dim, i, dir, room_center)
			local function fix_order(p1, p2)
				if edge == 'door' and p1 > p2 then
					return p2, p1
				else
					return p1, p2
				end
			end
			local door_center = {
				x = room_center.x + ((dim.room[i].x + dim.door[i].x) / 2) *  dir[1],
				y = room_center.y + ((dim.room[i].y + dim.door[i].y) / 2) * -dir[2],
			}
			local x1 = door_center.x - (dim.door[i].x / 2)  
			local y1 = door_center.y - (dim.door[i].y / 2)
			local x2 = door_center.x + (dim.door[i].x / 2)
			local y2 = door_center.y + (dim.door[i].y / 2)
			x1, x2 = fix_order(x1, x2);y1, y2 = fix_order(y1, y2)
			return {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
        end
        local function get_room_coordinates(dim, i, x, y, map_origin)
			local room_center = {
				x = map_origin.x + dim.block[i].x *  x,
				y = map_origin.y + dim.block[i].y * -y,
			}
			mdt.coordinates.rooms[i][y][x] = {outter = {}, inner = {}}
			local x1 = room_center.x - dim.room[i].x / 2
			local y1 = room_center.y - dim.room[i].y / 2
			local x2 = room_center.x + dim.room[i].x / 2
			local y2 = room_center.y + dim.room[i].y / 2
			mdt.coordinates.rooms[i][y][x].outter =  {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
			x1 = room_center.x - dim.thyng[i].x / 2
			y1 = room_center.y - dim.thyng[i].y / 2
			x2 = room_center.x + dim.thyng[i].x / 2
			y2 = room_center.y + dim.thyng[i].y / 2		
			mdt.coordinates.rooms[i][y][x].inner =   {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
			local function give_direction(edge)
				if edge == "n"  then return  0,  1 end
				if edge == "ne" then return  1,  1 end
				if edge == "e"  then return  1,  0 end
				if edge == "se" then return  1, -1 end
				if edge == "s"  then return  0, -1 end
				if edge == "sw" then return -1, -1 end
				if edge == "w"  then return -1,  0 end
				if edge == "nw" then return -1,  1 end
			end
			for _1, dir in ipairs({'n', 'ne', 'e', 'se', 's', 'sw', 'w', 'nw'}) do
					mdt.coordinates.rooms[i][y][x].exit = mdt.coordinates.rooms[i][y][x].exit or {}
					mdt.coordinates.rooms[i][y][x].exit[dir] = 
						get_exit_coordinates(dim, i, {give_direction(dir)}, room_center)
					mdt.coordinates.rooms[i][y][x].door = mdt.coordinates.rooms[i][y][x].door or {}
					mdt.coordinates.rooms[i][y][x].door[dir] = 
						get_door_coordinates(dim, i, {give_direction(dir)}, room_center)
			end
        end
		mdt.coordinates = {rooms = {}, title_text = {},}
        mdt.coordinates.title_text.y1 = ((dim.font.title * 1.1) - dim.font.title) / 2
        local map_origin = {
			x = (dim.map.x / 2) + dim.buffer[1].x,
			y = (dim.map.y / 2) + dim.buffer[1].y + FIXED_TITLE_HEIGHT,}
		local min_vision, max_vision = 0, 5
		for i = min_vision, max_vision do
			mdt.coordinates.rooms[i] = {}
			for y = -i, i do
				mdt.coordinates.rooms[i][y] = {}
				for x = -i, i do
					get_room_coordinates(dim, i, x, y, map_origin)
				end
			end
		end
    end

    local function resize_windows(dim) -- dimensions 
        local col = mdt.colours.window
        for k in pairs(win) do
			local clone = {map = 1, text = 2}
			local i = clone[k] or k
			WindowResize(win[k], dim.window[i].x, dim.window[i].y, miniwin.pos_center_all, 0, col.transparent)
        end
    end

	local function get_font(dim) -- dimensions
		-- chose our fonts, pick backups if unavailable
		local function choose_fonts()
			local chosen_fonts = {false, false}
			local f_tbl = utils.getfontfamilies() -- all possible fonts
			local choice = { -- our choice for each font, with two backups
				{"System", "Fixedsys", "Arial"},       -- title
				{"Dina", "Arial", "Helvetica"},        -- others
			}
			 -- if our chosen font exists then pick it
			for i, t in ipairs(choice) do
				for ii, f in ipairs(t) do
					if f_tbl[f] then
						chosen_fonts[i] = f
						break
					end
				end
			end
			-- if none of our chosen fonts are avaliable, pick the first one that is
			for i, f in ipairs(chosen_fonts) do 
				if not f then
					for k in pairs(f_tbl) do
						chosen_fonts[i] = k
						break
					end
				end
			end
			assert(chosen_fonts[1] and chosen_fonts[2], "Fonts not loaded!")
			return chosen_fonts
		end
		local fonts = choose_fonts()
		-- determine font size based on font and max height
		local function get_size(font_id, font_name, max_height)
			local max_size, font_size = 200, 1
			local font_height = 0
			while (font_height <= max_height) and (font_size < max_size) do
				-- load the font in order to determine its size size
				WindowFont(win[1], font_id, font_name, font_size, false, false, true, false)
				font_height = tonumber(WindowFontInfo(win[1], font_id, 1)) or font_height or 0
				-- if it passes or maximums then we have found our size
				if font_height > max_height or font_size > max_size then
					-- use previous size
					return (font_size - 1) > 1 and (font_size - 1) or 1
				end
				-- try the next size up
				font_size = font_size + 1
			end
		end
		-- load font and retun font height
		local function load_font(font_id, font_name, font_size)
			-- load fonts on each miniwindow
			for k, mw in pairs(win) do
				WindowFont(mw, font_id, font_name, font_size, false, false, false, false)
				WindowFont(mw, font_id.."underlined", font_name, font_size, false, false, true, false)
			end
			return tonumber(WindowFontInfo(win[1], font_id, 1)) or font_height or 0
		end
		-- our sizes are all determine by entirely different methods
		local font_methods = {
			title = ( -- determined by fixed hight
				function(font_id)
					local font_name = fonts[1] 
					local font_size   = get_size(font_id, font_name, FIXED_TITLE_HEIGHT)
					local font_height = load_font(font_id, font_name, font_size)
					mdt.dimensions.font[font_id] = font_height -- single value
				end),
			map = ( -- determined by room proportions, there will be a diffrent size for each possible vision limit
				function(font_id)
					mdt.dimensions.font[font_id] = {}
					local font_name = fonts[2]
					for i = 0, #dim.room do         
						local font_size   = get_size(font_id..tostring(i), font_name, dim.room[i].y)
						local font_height = load_font(font_id..tostring(i), font_name, font_size)
						mdt.dimensions.font[font_id][i] = font_height -- store by vision limit
					end
				end),
			text = ( -- preset sizes
				function(font_id)
					mdt.dimensions.font[font_id] = {}
					local font_name = fonts[2]
					for font_size = 8, 14 do 
						local font_height = load_font(font_id..tostring(font_size), font_name, font_size)
						mdt.dimensions.font[font_id][font_size] = font_height -- store by size
					end
				end),
		}
		mdt.dimensions.font = {}
		for font_id, func in pairs(font_methods) do
			func(font_id)
		end
	end
    mdt.dimensions = get_window_dimensions(window_width, window_height)
    resize_windows(mdt.dimensions)
    get_font(mdt.dimensions)
    get_coordinates(mdt.dimensions)
end
--------------------------------------------------------------------------------
--   HOTSPOTS
--------------------------------------------------------------------------------
function mdt_get_hotspots(dim) -- dimensions
	for i in ipairs(win) do
		-- titlebar
	    WindowAddHotspot(
			win[i], "title"..tostring(i),
			0, 0, dim.window[i].x, dim.font.title, 
			"", "", "mousedown", "cancelmousedown", "mouseup", 
			"Left-click to drag!", 1, 0)
		-- add drag handler
		WindowDragHandler(win[i], "title"..tostring(i), "dragmove", "dragrelease", 0)
		-- add resize handler
		WindowAddHotspot(
			win[i], "resize"..tostring(i), 
			dim.window[i].x - 10, dim.window[i].y - 10, dim.window[i].x, dim.window[i].y, 
			"MouseOver", "CancelMouseOver", "mousedown", "", "MouseUp", 
			"Left-click to resize!", 6, 0)
		WindowDragHandler(win[i], "resize"..tostring(i), "resizemove", "resizerelease", 0)
    end
end
--------------------------------------------------------------------------------
--   HOTSPOT HANDLERS
--------------------------------------------------------------------------------
function dragmove(flags, hotspot_id)
	if hotspot_id:match("title%d") then
		local mw = tonumber(hotspot_id:match("title(%d)$"))
		local max_x, max_y = GetInfo(281), GetInfo(280)
        local min_x, min_y = 0, 0
        local drag_x, drag_y = WindowInfo(win[mw], 17), WindowInfo(win[mw], 18)
        local to_x, to_y = drag_x - from_x, drag_y - from_y
        if to_x < min_x then 
            to_x = 0 
        elseif to_x + window_width[mw]> max_x then
            to_x = max_x - window_width[mw]
        end
        if to_y < min_y then 
            to_y = 0 
        elseif to_y + window_height[mw] > max_y then
            to_y = max_y - window_height[mw]
        end
		WindowPosition(win[mw], to_x, to_y, 0, 2) -- move the window to the new location
		if drag_x < min_x or drag_x > max_x or
		   drag_y < min_y or drag_y > max_y then -- change the mouse cursor shape appropriately
			check(SetCursor(11)) -- x cursor
		else
			check(SetCursor(1)) -- hand cursor
		end
	end
end

function dragrelease(flags, hotspot_id) end
-- called when the resize drag widget is moved
function resizemove(flags, hotspot_id)
	local mw = tonumber(hotspot_id:match("(%d)$"))
    local min = {100, 100}
    local start_x, start_y = WindowInfo(win[mw], 10), WindowInfo(win[mw], 11)
    local drag_x,   drag_y = WindowInfo(win[mw], 17), WindowInfo(win[mw], 18)
    local max_x,     max_y = GetInfo(281),        GetInfo(280)
    window_width [mw] = drag_x - start_x
    window_height[mw] = drag_y - start_y
    window_pos_x [mw] = drag_x
    window_pos_y [mw] = drag_y
    -- force square + titlebar for map window
    if mw == 1 then
		if window_width[mw] > window_height[mw] - FIXED_TITLE_HEIGHT then 
			window_height[mw] = window_width[mw] + FIXED_TITLE_HEIGHT
		else
			window_width[mw] = window_height[mw] - FIXED_TITLE_HEIGHT
		end
    end
    local out_of_bounds = false
    if window_width[mw]  + start_x > max_x then 
        window_width[mw]  = max_x - start_x
		if mw == 1 then
			window_height[mw] = window_width[mw] + FIXED_TITLE_HEIGHT
        end
        out_of_bounds = true
    end
    if window_height[mw] + start_y > max_y then 
        window_height[mw] = max_y - start_y
        if mw == 1 then
			window_width[mw]  = window_height[mw] - FIXED_TITLE_HEIGHT
        end
        out_of_bounds = true
    end
    if window_width[mw]  < min[mw] then 
        window_width[mw]  = min[mw]
        if mw == 1 then
			window_height[mw] = window_width[mw] + FIXED_TITLE_HEIGHT
        end
        out_of_bounds = true 
    end
    if window_height[mw] < min[mw] then 
        window_height[mw] = min[mw]
        if mw == 1 then
			window_width[mw]  = window_height[mw] - FIXED_TITLE_HEIGHT
        end
        out_of_bounds = true
    end
    if out_of_bounds then
        check(SetCursor(11)) -- x cursor
    else
        check(SetCursor(6)) -- resize cursor
    end
    if (utils.timer() - (last_refresh or 0) > 0.0333) then
        WindowResize(win[mw], window_width[mw], window_height[mw], mdt.colours.window.background)
        WindowDrawImage(win[mw], "win"..tostring(mw), 0, 0, window_width[mw], window_height[mw], 2)
        WindowShow(win[mw])
        last_refresh = utils.timer()
   end
end
-- called after the resize widget is released
function resizerelease(flags, hotspot_id)
	local mw = tonumber(hotspot_id:match("(%d)$"))
    mdt_window_setup(window_width, window_height)
    mdt_get_hotspots(mdt.dimensions)
    if mw == 1 then
		mdt_draw_map(mdt.rooms)
    else
		mdt_draw_text(mdt.styles)
    end
end
-- called when mouse button is pressed on hotspot
function mousedown(flags, hotspot_id)
	local mw = tonumber(hotspot_id:match("(%d)$"))
    if hotspot_id:match("title") then
		from_x, from_y = WindowInfo(win[mw], 14), WindowInfo(win[mw], 15)
    elseif hotspot_id:match("resize") then
        WindowImageFromWindow(win[mw], "win"..tostring(mw), win[mw])
    end
end

function mouseup(flags, id)

end
--------------------------------------------------------------------------------
--  TRIGGERS
--------------------------------------------------------------------------------
function mdt_get_triggers()
	local function get_xml_injection(xml)
		local code = ([[
			<send>
			-- when we parse gmcp data, we identify players by embedded colour tags.
			-- we will use the same logic for trigger data, however we must grab the 
			-- style run before it is altered by colourchanging triggers from a another
			-- plugin (for example a mob-colourer.) Because of these timing issues,
			-- we set the plugin priority to far below zero and have the code executed
			-- directly in the send field, rather than a script function.
			local n = GetLinesInBufferCount()
			local styles = GetStyleInfo (n)
			n = n - 1
			-- the last line in the buffer can be broken up by word-wraps, so we must
			-- loop backwards until we find a new line, in order to determine the
			-- actual start of the last line
			while not GetLineInfo(n, 3) do	
				local t = GetStyleInfo (n)
				if type(t) == 'table' then
					for i, v in ipairs(t) do
						if i == #t and styles[i].textcolour == v.textcolour then
							styles[i].text = v.text..styles[i].text
							styles[i].length = styles[i].length + v.length
						else
							table.insert(styles, i, v)
						end
					end
				end
				n = n - 1
				if n == -1000 then break end
			end
			-- now we forge ansii colour tags so that we can use the exact same function
			-- that parses gmcp, for simplicity
			local formatted_as_gmcp, bs = "", string.char(92)
			for i, v in ipairs(styles) do
				if GetNormalColour(8) ~= v.textcolour then
					formatted_as_gmcp = formatted_as_gmcp..bs.."u001b[4zMXP&lt;"..v.textcolour.."MXP&gt;"..Trim(v.text)..bs.."u001b[3z"
				else
					formatted_as_gmcp = formatted_as_gmcp..v.text
				end
			end
			mdt_parse_map_door_text(formatted_as_gmcp)
			</send>]]):gsub('\t\t\t', '')
		return xml:gsub('"%s*>',  '">\n' .. code)
	end
	
	ImportXML ( get_xml_injection( ExportXML (0, "mdt_map_door_look") ) )

end
-------------------------------------------------------------------------------
--  GMCP EVENTS
-------------------------------------------------------------------------------
-- set GMCP connection
function OnPluginTelnetRequest(msg_type, data_line)
    local function send_GMCP(packet) -- send packet to mud to initialize handshake
        assert(packet, "send_GMCP passed nil message")
        SendPkt(string.char(0xFF, 0xFA, 201)..(string.gsub(packet, "\255", "\255\255")) .. string.char(0xFF, 0xF0))
    end
    if msg_type == 201 then
        if data_line == "WILL" then
            return true
        elseif (data_line == "SENT_DO") then
            send_GMCP(string.format('Core.Hello { "client": "MUSHclient", "version": "%s" }', Version()))
            local supports = '"room.info", "room.map", "room.writtenmap", "char.vitals", "char.info"'
            send_GMCP('Core.Supports.Set [ '..utils.base64decode(utils.base64encode(supports))..' ]')
            return true
        end
    end
    return false
end
-- on plugin callback to pick up GMCP
function OnPluginTelnetSubnegotiation(msg_type, data_line)
    if msg_type == 201 and data_line:match("([%a.]+)%s+.*") then
        mdt_recieve_GMCP(data_line)
    end
end
-- on GMPC receipt
function mdt_recieve_GMCP(text)
	local function get_map_name(room_id)
		local map_id = false
		if room_id then
			qdb = sqlite3.open(quowmap_database)
			for t in qdb:nrows("SELECT map_id FROM rooms WHERE room_id = '"..room_id.."'") do 
				map_id = t.map_id 
			end
			qdb:close()
		end
		return mdt.map_ids[map_id] or "Discworld"
	end
	if (string.sub(text, 1, 10) == "room.info ") then	
		table.remove(mdt.sequence, 1)
		table.remove(mdt.commands.move, 1)
		mdt.sequence[1] = text:match('^.*"identifier":"(.-)".*$')
		mdt.title[1] = get_map_name(mdt.sequence[1])
		if mdt.sequence[1] and not mdt.special_areas[mdt.sequence[1]] then
			mdt.title[2] = (text:match('"name":"(.-)"') or "unknown"):gsub("^(%w)", string.upper):gsub("(%s%w)", string.upper)
		end
	elseif (string.sub(text, 1, 9) == "room.map ") then
		mdt_parse_map(text)
    elseif (string.sub(text, 1, 16) == "room.writtenmap ") and 
		mdt.sequence[1] and not mdt.special_areas[mdt.sequence[1]]
	then
		speed_test = os.time()
		text = text:match('"(.*)\\n"') or ""
		map_door_text = text
        mdt_parse_map_door_text(text)
    end
end
--------------------------------------------------------------------------------
--   COLOURS
--------------------------------------------------------------------------------
function mdt_get_colours()
    local col = {
        window = {
            background = "black",
            border =     "white",
            transparent ="teal",},
        title = {
            text =       "black",
            border =     "white",
            fill =       "lightgray",},
        rooms = {
            border =     "white",
            background = "black",
            exits =      "lightgray",
            doors =      "red",
            entrance =   "white",
            fight =      "red",},
        thyngs = {
            you =        "yellow",
            ghost =      "yellow",
            priests =    "orange",
            money =      "mediumorchid",
            xp = {       "#003300", "#004c00", "#006600", "#007f00", "#009900", "#00b200", "#00cc00", "#00e500", "#00ff00",},},
        numbers = {      
			xp = {       "#696969", "#808080", "#a9a9a9", "#c0c0c0", "#ffffff"},},
		letters = {
			players =    "black",},
		text = {
			path =       "cornflowerblue",},
        note = {
            bracket =    "white",
            error =      "red",
            text =       "gray",},}

    for k, v in pairs(col) do
        for kk, c in pairs(v) do
            if type(c) == 'string' then
                col[k][kk] = ColourNameToRGB(c)
            else
                for i, cc in ipairs(c) do
                   col[k][kk][i] = ColourNameToRGB(cc) 
                end
            end
        end
    end
    return col
end
-------------------------------------------------------------------------------
--  GRAPHICS
-------------------------------------------------------------------------------
function mdt_print_map()
	function draw_ghost()
		local trajectory_room =  mdt.sequence[#mdt.sequence]
		-- if our trajectory room is on our map
		local ghost = mdt.locations[trajectory_room] and mdt.locations[trajectory_room].map
		if ghost then
			local coor = mdt.coordinates
			local x = ghost.x
			local y = ghost.y
			local view = mdt.rooms.range == 0 and 1 or mdt.rooms.range 
			local x1 = coor.rooms[view][y][x].outter.x1
			local y1 = coor.rooms[view][y][x].outter.y1
			local x2 = coor.rooms[view][y][x].outter.x2
			local y2 = coor.rooms[view][y][x].outter.y2
			WindowRectOp(win[1], 1, x1, y1, x2, y2, mdt.colours.thyngs.ghost)
		end
	end
    WindowDrawImage(win[1], "map_image", 0, 0, 0, 0, 1)
    draw_ghost()
	WindowShow(win[1])	
end

function mdt_print_text()
	function draw_ghost()
		local trajectory_room =  mdt.sequence[#mdt.sequence]
		-- if our trajectory room is on our map
		local ghost = mdt.locations[trajectory_room] and mdt.locations[trajectory_room].text
		if ghost then
			local x1 = ghost.x1
			local y1 = ghost.y1
			local x2 = ghost.x2
			local y2 = ghost.y2
			WindowRectOp(win[2], 1, x1, y1, x2, y2, mdt.colours.thyngs.ghost)
		end
	end
	WindowDrawImage(win[2], "text_image", 0, 0, 0, 0, 1)
	draw_ghost()
	WindowShow(win[2])
end

function mdt_window_background(mw, dim, col)
	local clone = {map = 1, text = 2}
	local i = clone[mw] or mw
    WindowRectOp(win[mw], 2, 0, 0, dim.window[i].x, dim.window[i].y, col.window.background)
end

function mdt_titlebar(mw, dim, coor, col)
	local clone = {map = 1, text = 2}
	local i = clone[mw] or mw
	WindowCircleOp (win[mw], 2, 
		0, 0, dim.window[i].x, dim.font.title,
		col.window.border, 0, 1, col.title.fill, 0)
	local w = WindowTextWidth(win[i], "title", mdt.title[i])
	local x1 = (dim.window[i].x - w) / 2
	local min = 1
	if x1 < min then x1 = min end
	WindowText(win[mw], "title", mdt.title[i], 
		x1, 0, 0, 0,
		col.title.text)
	-- add window border also 
    WindowRectOp(win[mw], 1, 0, 0, dim.window[i].x, dim.window[i].y, col.window.border)       
end

function mdt_draw_map(map_data)
	local function draw_room_exits(mw, dim, coor, colour, map_data, view, x, y)
		for _, exit in ipairs(map_data[y][x].exits) do
			local x1 = coor.rooms[view][y][x].exit[exit].x1
			local y1 = coor.rooms[view][y][x].exit[exit].y1
			local x2 = coor.rooms[view][y][x].exit[exit].x2
			local y2 = coor.rooms[view][y][x].exit[exit].y2	
			WindowLine(mw, x1, y1, x2, y2, colour, 0, 1)
		end
	end
	local function draw_room_doors(mw, dim, coor, colour, map_data, view, x, y)
		for _, door in ipairs(map_data[y][x].doors) do
			local x1 = coor.rooms[view][y][x].door[door].x1
			local y1 = coor.rooms[view][y][x].door[door].y1
			local x2 = coor.rooms[view][y][x].door[door].x2
			local y2 = coor.rooms[view][y][x].door[door].y2
			WindowRectOp(mw, 1, x1, y1, x2, y2, colour)
		end
	end
	local function draw_room_border(mw, dim, coor, colour, map_data, view, x, y)
		local x1 = coor.rooms[view][y][x].outter.x1
		local y1 = coor.rooms[view][y][x].outter.y1
		local x2 = coor.rooms[view][y][x].outter.x2
		local y2 = coor.rooms[view][y][x].outter.y2
		WindowRectOp(mw, 1, x1, y1, x2, y2, colour)
	end
	local function draw_room_fill(mw, dim, coor, colour, map_data, view, x, y)
		local x1 = coor.rooms[view][y][x].inner.x1
		local y1 = coor.rooms[view][y][x].inner.y1
		local x2 = coor.rooms[view][y][x].inner.x2
		local y2 = coor.rooms[view][y][x].inner.y2
		WindowRectOp(mw, 2, x1, y1, x2, y2, colour)
	end
	local function draw_room_number(mw, dim, coor, colour, map_data, view, x, y, xp, underlined)
		local font_id = "map"..tostring(view)
		local w = WindowTextWidth(mw, font_id, xp)
		local x1 = coor.rooms[view][y][x].outter.x1 + (dim.room[view].x - w) / 2
		local y1 = coor.rooms[view][y][x].outter.y1 + (dim.room[view].y - dim.font.map[view]) / 2
		WindowText(mw, underlined and font_id.."underlined" or font_id, xp, x1, y1, 0, 0, colour, false)
	end
	local function draw_room_thyngs(mw, dim, coor, col, map_data, view, x, y, room_count, player_room)
	
		local function get_fight_rooms(mw, dim, coor, col,map_data, view, x, y, room_count)
		-- in order to determine fight rooms, we take gmcp map data and
		-- iterate over the room charectors and their coresponding colour codes.
		-- if the colour is 'red' and it is not a door ('+'), then we have a fight room.
		-- we record these by the index they were found at.
		local id =  map_data[y][x].id
		local border_colour = false
		if id then
			if mdt.fight_room[room_count] then
				-- transfer from index
				mdt.fight_room[id] = true
				-- to room id, so that offset will not occur
				-- if we are given map door text from a trigger
				-- rather then gmcp (different vision limits)
				mdt.fight_room[room_count] = nil
			end
			if mdt.fight_room[id] then
				border_colour =  col.rooms.fight
			end
		end
		return border_colour
	end
		local players_or_mobs = false
        local pop = map_data[y][x].population
		local icon, icon_colour, icon_bg = "", 0, false
		if map_data[y][x].population.is_player_room then
			players_or_mobs = "players"
			for k, v in pairs(map_data[y][x].population.players) do
				icon_bg = ColourNameToRGB(v.colour) ~= -1 and ColourNameToRGB(v.colour) or v.colour
				break
			end
			icon = string.char(player_room)
            icon_colour = col.letters.players
			player_room = player_room + 1
		elseif map_data[y][x].population.is_mob_room then
			players_or_mobs = "mobs"
            local function round(num, place)
                local mult = 10^(place or 0)
                return math.floor(num * mult + 0.5) / mult
            end
            if pop.xp < 1/4 then
                icon_colour = col.numbers.xp[1]
                icon = 0                -- 0
            elseif pop.xp < 1/2 then
                icon_colour = col.numbers.xp[2]
                icon = string.char(188) -- 1/4
            elseif pop.xp < 3/4 then
                icon_colour = col.numbers.xp[3]
                icon = string.char(189) -- 1/2
            elseif pop.xp < 1 then
                icon_colour = col.numbers.xp[4]
                icon = string.char(190) -- 3/4
            else
				icon_colour = col.numbers.xp[#col.numbers.xp]
                icon = round(pop.xp)        -- 1-9
                icon = icon >= 10 and 9 or icon
                -- only colour fill room if xp is greater than one
                if icon >= 1 then
                    icon_bg = col.thyngs.xp[icon]
                end
            end
		end
		if players_or_mobs then
			local is_immobile, is_priest, is_money = pop.is_immobile, pop.is_priest, pop.is_money
			if icon_bg then
				draw_room_fill(mw, dim, coor, icon_bg, map_data, view, x, y)
			end
			local icon_border =  get_fight_rooms(mw, dim, coor, col,map_data, view, x, y, room_count) or is_priest and col.thyngs.priests or is_money and col.thyngs.money or false	
			if icon_border  then
				draw_room_border(mw, dim, coor, icon_border , map_data, view, x, y)
			end
			draw_room_number(mw, dim, coor, icon_colour, map_data, view, x, y, icon, is_immobile)
			local function format_path(t1)
				local t2 = {}
				for i, v in ipairs(t1) do
					if v == (t2[#t2] and t2[#t2].direction) then
						t2[#t2].distance = t2[#t2].distance + 1
					else
						table.insert(t2, {direction = v, distance = 1})
					end
				end
				local s = false
				for i, v in ipairs(t2) do
					if not s then s = "" else s = s..", " end
					s = s..tostring(v.distance).." "..v.direction
				end
			  return s
			end
			local path = map_data[y][x].path
			local formatted_path = format_path(path)
			mdt.text.longest_path = #formatted_path > #mdt.text.longest_path and formatted_path or mdt.text.longest_path
			local room_info = {
				path = path, 
				formatted_path = formatted_path,
				icon = icon, 
				icon_colour = icon_colour, 
				icon_bg = icon_bg, 
				icon_border = icon_border or col.rooms.border,
				underline = is_immobile, 
				xp = pop.xp, 
				x = x,
				y = y,
			}
			table.insert(mdt.text[players_or_mobs], room_info)
        end
		return room_count + 1, player_room
	end
	local function draw_map_rooms(mw, dim, coor, col, map_data)
		mdt.text = {players = {}, mobs = {}, longest_path = ""}
		local range = map_data.range
		-- avoid awkward zoom-ins
		local view = range < 1 and 1 or range
		local player_room = 65
		-- count rooms and iterate in a way in which we can match our fight room
		-- indexes to their corresponding x, y locations
		local room_count = 1
		for y = range, - range, -1 do
			for x = - range, range do
				if map_data[y][x].in_vision then				
					draw_room_border(mw, dim, coor, col.rooms.border, map_data, view, x, y)
					draw_room_exits (mw, dim, coor, col.rooms.exits,  map_data, view, x, y)
					draw_room_doors (mw, dim, coor, col.rooms.doors,  map_data, view, x, y)
					room_count, player_room = draw_room_thyngs(mw, dim, coor, col,map_data, view, x, y, room_count, player_room)
				end
			end
		end	
		draw_room_fill(mw, dim, coor, col.thyngs.you, map_data, view, 0, 0) -- you
	end
	local mw, dim, coor, col = "map", mdt.dimensions, mdt.coordinates, mdt.colours
	mdt_window_background(mw, dim, col)
	draw_map_rooms(win[mw], dim, coor, col, map_data)
	mdt_titlebar(mw, dim, coor.titlebar, col)
	WindowImageFromWindow(win[1], "map_image", win[mw])
	mdt_print_map()
end

function mdt_prepare_text(map_data)
	local function get_text_styles(mw, dim, coor, col, map_data)
		local function order_population(players_or_mobs)
			table.sort(mdt.text[players_or_mobs], function(a,b) 
				if players_or_mobs == "players" then
					return a.icon < b.icon 
				else
					return a.xp > b.xp
				end
			end)
		end
		-- sort and consolidate
		mdt.text.population = {}
		for _1, players_or_mobs in ipairs({"players", "mobs"}) do
			order_population(players_or_mobs)
			for _2, v in ipairs(mdt.text[players_or_mobs]) do
				table.insert(mdt.text.population, v)
			end
		end
		-- get styles for room
		local function get_room_styles(map_data, x, y)
			local rs = {}
			-- add players
			for k, v in pairs(map_data[y][x].population.players) do
				local text, colour, bg_colour, border_colour, underline = k, col.letters.players, ColourNameToRGB(v.colour) ~= -1 and ColourNameToRGB(v.colour) or v.colour, false, false
				table.insert(rs, {text = text, colour = colour, bg_colour = bg_colour, border_colour = border_colour, underline = underline})
			end
			-- add mobs
			for i = 5, 0, -1 do
				for k, v in pairs(map_data[y][x].population.mobs[i]) do
					local text, colour, bg_colour, border_colour, underline = "", 0, false, false, v.is_immobile
					if v.quantity > 1 then
						text = v.quantity.." "..k..v.plural
					else
						text = k..v.singular
					end
					if text ~= "" then
						local xp_val = {1/12, 1/6, 1/3, 2/3, 1}
						local xp = (xp_val[i] or 0) * v.quantity
						if xp < 1/4 then
							colour = col.numbers.xp[1]
						elseif xp < 1/2 then
							colour = col.numbers.xp[2]
						elseif xp < 3/4 then
							colour = col.numbers.xp[3]
						elseif xp < 1 then
							colour = col.numbers.xp[4]
						else
							colour = col.numbers.xp[5]
							bg_colour = xp > 9 and col.thyngs.xp[9] or col.thyngs.xp[math.floor(xp)]
						end
						if v.is_priest then
							border_colour = col.thyngs.priests
						elseif v.is_money then
							border_colour = col.thyngs.money
						end
						table.insert(rs, {text = text, colour = colour, bg_colour = bg_colour, border_colour = border_colour, underline = underline})
					end
				end
			end
			return rs
		end
		-- get styles for every room
		local function get_styles(mw, dim, coor, col, map_data)
			local styles = {}
			for i, v in ipairs(mdt.text.population) do
				local rs = get_room_styles(map_data, v.x, v.y)
				-- add icon
				table.insert(rs, 1, {text = v.icon, colour = v.icon_colour, bg_colour = v.icon_bg, border_colour = v.icon_border, underline = v.underline})
				-- add path
				table.insert(rs, 2, {text = v.formatted_path, colour = col.text.path, bg_colour = false, border_colour = false, underline = false})
				-- must have more than just the the icon and path 
				-- in the event that the only thing occupying a room is an empty string.
				-- (the regex captures return empty strings interntionally for certain things
				-- we would like to omit, like clouds or pets)
				if #rs > 1 then 
					table.insert(styles, rs)
				end
				rs[0] = mdt.rooms[v.y][v.x].id
			end
			return styles
		end
		local styles = get_styles(mw, dim, coor, col, map_data)
		return styles, mdt.text.longest_path
	end
	local mw, dim, coor, col = "text", mdt.dimensions, mdt.coordinates, mdt.colours
	mdt.styles, longest_path = get_text_styles(mw, dim, coor, col, map_data)
	mdt_draw_text(mdt.styles, longest_path)
end

function mdt_draw_text(styles, longest_path)
	local function draw_text(mw, dim, coor, col)
		local function next_line(y2, h)
			local line_buffer = 3
			local y1 = y2 + line_buffer
			return y1, y1 + h 
		end
		local font_size = 13
		local font_id = "text"..tostring(font_size)
		local h =  dim.font.text[font_size]
		local y1 = dim.buffer[2].y + FIXED_TITLE_HEIGHT
		local y2 = y1 + h
		for _, t in ipairs(styles) do
			local space = WindowTextWidth(win[2], font_id, " ")
			local x1, x2 = dim.buffer[2].x, 0
			for i, v in ipairs(t) do
				if i == 1 then -- icon
					x2 = x1 + h -- create square
					if v.bg_colour then
						WindowRectOp (win[mw], 2, x1, y1, x2, y2, v.bg_colour)
					end
					if v.border_colour then
						WindowRectOp (win[mw], 1, x1, y1, x2, y2, v.border_colour) 
					end
					local id = t[0] or false
					if mdt.locations[id] then
						-- save locations so we can used them to highlight ghost
						mdt.locations[id].text = {
							x1 = x1,
							y1 = y1,
							x2 = x2,
							y2 = y2,
						}
					end
					local w = WindowTextWidth(win[2], font_id, v.text)
					x1 = x1 + (h - w) / 2
					WindowText(win[mw], v.underline and font_id.."underlined" or font_id, v.text, x1, y1, 0, 0, v.colour)
				elseif i == 2 then -- path
					WindowText(win[mw], font_id, v.text, x1, y1, 0, 0, v.colour)
					if longest_path ~= "" then
						x2 = x1 + WindowTextWidth(win[2], font_id, longest_path) + space
					else
						x2 = x2 + space
					end
					x2 = x2 + WindowText(win[mw], font_id, ":", x2, y1, 0, 0, v.colour)
				else -- mobs
					local text = i == #t and v.text or v.text..","
					x2 = x1 + WindowTextWidth(win[2], font_id, text)
					if v.bg_colour then
						WindowRectOp (win[mw], 2, x1 - 1, y1, x2 + 1, y2, v.bg_colour)
					end
					if v.border_colour then
						WindowRectOp (win[mw], 1, x1 - 1, y1, x2 + 1, y2, v.border_colour) 	
					end		
					WindowText(win[mw], v.underline and font_id.."underlined" or font_id, text, x1, y1, 0, 0, v.colour)
				end
				x1 = x2 + space
			end
			y1, y2 = next_line(y2, h)
		end
	end
	longest_path = longest_path or ""
	local mw, dim, coor, col = "text", mdt.dimensions, mdt.coordinates, mdt.colours
	mdt_window_background(mw, dim, col, map_data)
	draw_text(mw, dim, coor, col)
	mdt_titlebar(mw, dim, coor.titlebar, col)
	WindowImageFromWindow(win[2], "text_image", win[mw])
	mdt_print_text()
end
-------------------------------------------------------------------------------
--  CROSS-PLUGIN COMMUNICATION
-------------------------------------------------------------------------------
function mdt_special_area_text(special_text_styles, special_title)
	assert(loadstring(special_text_styles))()
	mdt.styles = text_styles
	mdt.title[2] = special_title
	mdt_draw_text(mdt.styles)
end
-------------------------------------------------------------------------------
--  PARSE MAP
-------------------------------------------------------------------------------
function mdt_parse_map(text)
	mdt.fight_room = {}
	local i = 1
	text:gsub("<(%w+)MXP>[^+]", function(c)
		mdt.fight_room[i] = c == "Red"
		i = i + 1
	end)
end
-------------------------------------------------------------------------------
--  PARSE MAP DOOR TEXT
-------------------------------------------------------------------------------
function mdt_parse_map_door_text(text)
	-- determine coordinate shift
	local function move_point(d_long)
		local x, y = 0, 0; 	local d_short = ""
		if d_long:match('north') then
			y =  1; d_short = "n"
		elseif d_long:match('south') then
			y = -1; d_short = "s"
		end
		if d_long:match('east') then
			x =  1; d_short = d_short.."e"
		elseif d_long:match('west') then
			x = -1; d_short = d_short.."w"
		end
		return x, y, d_short
	end
	local word_to_int = {one = 1, two = 2, three = 3, four = 4, five = 5}
	-- decifer exit and door locations
	local function log_edges(s)
		local facing, path = s:match('^(.*) of(.*)$')
		local edges = {}
		local x, y = 0, 0
		mdt.regex.direction:gmatch(facing, function (_, t)
			local face_x, face_y, dir = move_point(t.DIRECTION)
			table.insert(edges, dir)
		end)
		mdt.regex.path:gmatch(path, function (_, t)
			local n = word_to_int[t.NUMBER] or 0
			local move_x, move_y, dir = move_point(t.DIRECTION)
			for i = 1, n do
				x = x + move_x
				y = y + move_y
			end
		end)
		return x, y, edges
	end
	-- strip title and family name
	local function parse_players(p_long)
		local p_short = string.lower(p_long)
		mdt.regex.titles:gmatch(p_short, function (_, t)
			p_short = p_short:gsub(t.title.." ", "")
		end)
		return p_short:gsub("^([a-z']+) .*$", "%1")
	end
	local function parse_mobs(m_long)
		local m_short = string.lower(m_long)
		local _1, _2, t = mdt.regex.xp:match(m_short)
		if type(t) ~= 'table' then
			-- handle edge cases
			_1, _2, t = mdt.regex.remainder:match(m_short)
		end
		local n = 1
		for i, v in ipairs(t) do
			if i > 21 then
				break
			elseif v then
				n = i
				break
			end
		end
		while #t > 0 do 
			table.remove(t) -- remove indecies
		end
		for k, m_short in pairs(t) do
			if m_short and k~= 'hiding' then
				local is_immobile, is_priest, is_money = false, false, false
				local tier, singular, plural, flag = k:match("^xp(%d*)(%w*)_(%w*)_(%w*)$")
				if flag:match("P") then
					is_priest = true
				end
				if flag:match("I") then
					is_immobile = true
				end
				if flag:match("M") then
					is_money = true
				end
				tier = tonumber(tier)
				return m_long, m_short, tier, singular, plural, n, is_immobile, is_priest, is_money
			end
		end
	end
	local function parse_room_population(t)
		-- xp exact is the exact vaule of xp, short is rounded to one digit, and long is rounded to 100ths
		local population = {players ={}, mobs = {}, is_player_room = false, is_mob_room = false, xp = 0, is_immobile = false, is_priest = false}
		for i = 0, 5 do
			population.mobs[i] = {}
		end
		for _, thyng in ipairs(t) do
			local _1, _2, c = mdt.regex.players:match(thyng)
			if c and c.colour and c.player then
			-- players
				population.is_player_room = true
				local p_long, p_colour = c.player, c.colour
				local p_short = parse_players(p_long)
				population.players[p_short] = {colour = p_colour, long = p_long}
			else 
			-- mobs
				population.is_mob_room = true
				local m_long, m_short, tier, singular, plural, n, is_immobile, is_priest, is_money = parse_mobs(thyng)
				population.mobs[tier][m_short] = population.mobs[tier][m_short] or {quantity = 0, singular = singular, plural = plural, long = {}, is_immobile = is_immobile, is_priest = is_priest, is_money = is_money}
				population.mobs[tier][m_short].quantity = population.mobs[tier][m_short].quantity + n
				table.insert(population.mobs[tier][m_short].long, m_long)
				if is_immobile then
					population.is_immobile = true
				end
				if is_priest then
					population.is_priest = true
				end
				if is_money then
					population.is_money = true
				end
				-- calculate xp total
				local xp_val = {1/12, 1/6, 1/3, 2/3, 1}
				population.xp = population.xp + (xp_val[tier] or 0) * n
			end
		end
		return population
	end
	local parse_map_door_text = {
		-- log nodes
		VISION = ( 
			function(s) 
				local room_id, path = mdt.sequence[1], {}
				local x, y = 0, 0
				mdt.regex.path:gmatch(s, function (_, t)
					local n = word_to_int[t.NUMBER] or 0
					local move_x, move_y, dir = move_point(t.DIRECTION)
					for i = 1, n do
						-- add exits as we follow the path, because these exits
						-- are not explicitly stated in the written text
						-- as the ones at the end of your vision range are
						table.insert(mdt.rooms[y][x].exits, dir)
						x = x + move_x
						y = y + move_y
						table.insert(path, dir)
						mdt.rooms[y][x].path = {}
						for i, v in ipairs(path) do
							table.insert(mdt.rooms[y][x].path, v)
						end
						room_id = mdt_get_exit_room(room_id, dir)
						if room_id then
							mdt.locations[room_id] = {map = {x = x, y = y}}
						end
						mdt.rooms[y][x].id = room_id
						mdt.rooms[y][x].in_vision = true
					end
					for _, m in ipairs({x, y}) do
						if math.abs(m) > mdt.rooms.range then
							mdt.rooms.range = math.abs(m)
						end
					end
				end)
			end), 
		-- log edges
		DOORS = ( 
			function(s) 
				local x, y, t = log_edges(s)
				mdt.rooms[y][x].doors = t
			end),
		EXITS = (
			function(s) 
				local x, y, t = log_edges(s)
				mdt.rooms[y][x].exits = t
			end),
		-- populate
		POPULATION = (
			function(s) 
				local thyngs = {}
				mdt.regex.thyngs:gmatch(s, function (_, t)
					local thyng = t.THYNG
					table.insert(thyngs, thyng)
				end)
				local x, y = 0, 0
				mdt.regex.path:gmatch(s, function (_, t)
					local n = word_to_int[t.NUMBER] or 0
					local move_x, move_y, dir = move_point(t.DIRECTION)
					for i = 1, n do
						x = x + move_x
						y = y + move_y
					end
				end)
				mdt.rooms[y][x].population = parse_room_population(thyngs)
			end),
	}
	bprint(text)
	mdt.rooms = {range = 0}
	for y = -5, 5 do
		mdt.rooms[y] = {}
		for x = -5, 5 do
			mdt.rooms[y][x] = {in_vision = false, id = false, doors = {}, path = {}, exits = {}, population = {}}
		end
	end
	mdt.rooms[0][0].in_vision = true
	mdt.rooms[0][0].id = mdt.sequence[1]
	mdt.locations = {}
	if mdt.sequence[1] then
		mdt.locations[mdt.sequence[1]] = {map = {x = 0, y = 0}}
	end
	mdt.regex.map_door_text:gmatch(text, function (_, t)
		while #t > 0 do 
			table.remove(t) -- remove indecies
		end
		for k, v in pairs(t) do
			if v then
				parse_map_door_text[k](v)
			end
		end
    end)
    --tprint(mdt.rooms)
    mdt_draw_map (mdt.rooms)
    mdt_prepare_text(mdt.rooms)
end
-------------------------------------------------------------------------------
--  MOVEMENT TRACKING
-------------------------------------------------------------------------------
function mdt_get_exit_room(start_id, exit)
	local end_id = false
	if start_id then
		qdb = sqlite3.open(quowmap_database)
		for t in qdb:nrows("SELECT connect_id FROM room_exits WHERE room_id = '"..start_id.."' AND exit = '"..exit.."'") do 
			end_id = t.connect_id or false 
		end
		qdb:close()		
	end
	return end_id
end
-- handle movement commands
function OnPluginSent(text)
    if text == "stop" then
        mdt.commands.move.count, mdt.commands.look.count = 0, 0
    else
        local directions = {n = "n", ne = "ne", e = "e", s = "s", se = "se", s = "s", sw = "sw", w = "w", nw = "nw", north = "n", northeast = "ne", east = "e", southeast = "se", south = "s", southwest = "sw", west = "w", northwest = "nw",}
        local dir = directions[text]
        if dir then
			mdt.commands.move.count = mdt.commands.move.count + 1
			table.insert(mdt.commands.move, dir)
            table.insert(mdt.sequence, mdt_get_exit_room(mdt.sequence[#mdt.sequence], dir) or mdt.sequence[#mdt.sequence])
            mdt_print_map()
            mdt_print_text()
        elseif text == "l" or text == "look" then
			mdt.commands.move.count = mdt.commands.move.count + 1
			table.insert(mdt.commands.move, "l")
			table.insert(mdt.sequence, mdt.sequence[#mdt.sequence])
        end
    end
end
-- we can't just clear the tables entirely because commands may have been entered after 'stop'
function on_trigger_mdt_remove_queue(name, line, wildcards, styles) 
    while(mdt.commands.move[mdt.commands.move.count + 1] ~= nil) do
	   table.remove(mdt.commands.move, (mdt.commands.move.count + 1))
    end
    while(mdt.sequence[mdt.commands.move.count + 2]) do
	   table.remove(mdt.sequence, (mdt.commands.move.count + 2))
    end
    mdt_print_map()
    mdt_print_text()
end
-- on attempting to move in a nonexistent direction
function on_trigger_mdt_command_fail(name, line, wildcards, styles)
    table.remove(mdt.commands.move, 1);table.remove(mdt.sequence, 2)
    mdt_construct_seq()
    mdt_print_map()
    mdt_print_text()
end
-- on following another player
function on_trigger_mdt_you_follow(name, line, wildcards, styles)
    mdt.commands.move.count = (mdt.commands.move.count or 0) + 1 -- used in 'stop' handling
    local directions = {n = "n", ne = "ne", e = "e", s = "s", se = "se", s = "s", sw = "sw", w = "w", nw = "nw", north = "n", northeast = "ne", east = "e", southeast = "se", south = "s", southwest = "sw", west = "w", northwest = "nw",}
    local dir = directions[wildcards.driection]
    table.insert(med.commands.move, 1, dir)
    medina_construct_seq()
    mdt_print_map()
    mdt_print_text()
end
-- on any event that distrupts our trajectory we must recalculate the sequence
function mdt_construct_seq()
	while(mdt.sequence[2]) do table.remove(mdt.sequence, 2) end
	for i, command in ipairs(mdt.commands.move) do
		if command == "l" then
			table.insert(mdt.sequence, mdt.sequence[#mdt.sequence])
		elseif command then
			table.insert(mdt.sequence, mdt_get_exit_room(mdt.sequence[#mdt.sequence], command) or mdt.sequence[#mdt.sequence])
		end
	end
end
-------------------------------------------------------------------------------
--  REGULAR EXPRESSIONS
-------------------------------------------------------------------------------
function mdt_get_regex()

	local f = io.open(GetPluginInfo(GetPluginID (), 20):gsub("\\([A-Za-z_]+)\\$", "\\shared\\").."titles.txt", 'r')
	local title_regex = Trim(assert(f:read("*a"), "Can't locate titles.txt"))
	f:close()
	mdt.regex = {
		titles   = rex.new(title_regex),
		map_door_text = rex.new([[
(?(DEFINE)
(?'direction'(?<ns>north|south)?(?(ns)(east|west)?|(east|west)))
(?'number'(one|two|three|four|five))
(?'positions'(((?P>direction)(,| and)? )+))
(?'locations'((?P>number) (?P>direction)((,| and)? |))+)
(?'vision'[Tt]he limit of your vision is (?P>locations)from here( and)?(, | |[.]$))
(?'doors'([Aa] )?[Dd]oors? (?P>positions)of ((?P>locations)|here(, | |))+)
(?'exits'([Aa]n? (hard to see through )?)?[Ee]xits? (?P>positions)of ((?P>locations)|here(, | |))+)
(?'population'(?! ?(((?P>vision)|(?P>doors)|(?P>exits)))).*?(?P>locations)(?=(\.|(?P>population)|(?P>vision)|(?P>doors)|(?P>exits))))
)(?# 
MAP DOOR TEXT:
)(?:(?<VISION>(?P>vision))|(?<DOORS>(?P>doors))|(?<EXITS>(?P>exits))|(?<POPULATION>(?P>population)))[.]?]]),
		path = rex.new([[
(?(DEFINE)
(?'direction'(?<ns>north|south)?(?(ns)(east|west)?|(east|west)))
(?'number'(one|two|three|four|five)))(?#
 PATH:
) (?<NUMBER>(?P>number)) (?<DIRECTION>(?P>direction))(,| |$)]]),
		direction = rex.new([[(?#
 DIRECTION:
)(?<DIRECTION>(?<ns>north|south)?(?(ns)(east|west)?|(east|west)))(,| |$)]]),
		thyngs = rex.new([[
(?(DEFINE)
(?'direction'(?<ns>north|south)?(?(ns)(east|west)?|(east|west)))
(?'number'(one|two|three|four|five))
(?'path' (is|are) (?P>number) (?P>direction).*$)
(?'deliminator'(, (?!\w+ Horseman)|(?<!orange|black) and (?!(white|yellow|orange|red|blue|green|tan|purple) )))
(?'thyng'.*?(?=((?P>deliminator)|(?P>path))))
)(?#
 MOB/PLAYER:
)(?<THYNG>(?P>thyng))((?<DELIMINATOR>(?P>deliminator))|(?P>path))]]),
		players = rex.new([[(?#
PLAYER:		
)(\\u001b\[4zMXP<(C )?(?<colour>.*?)MXP>)+(?<player>.*)\\u001b\[3z]]),
		xp = rex.new(
[[^(?:(?:(an?|one)|(two)|(three)|(four)|(five)|(six)|(seven)|(eight)|(nine)|(ten)|(eleven)|(twelve)|(thirteen)|(fourteen)|(fifteen)|(sixteen)|(seventeen)|(eighteen)|(nineteen)|(twenty)|(many)) )?.*?((?#
Capture groups are named in this format: xp<tier>_<singular suffix>_<plural suffix>_<flags: I = immobile, M = money, P = priest> 
HIGH XP: 5
* us --> i
)(?<xp5us_i_>hippopotam)(us|i)|(?#
* y --> ies
)(?<xp5y_ies_>ceremonial sentr)(y|ies)|(?#
* '' --> s
)((?<xp5_s_>(palace|imperial|ceremonial|city) guard|(hulking|towering|lumbering|mean|terrifying|looming|huge) troll|althea|casanunda|casso|ciaco|cicone|clemence|debois|giant( leader)?|grflx soldier|gumboni|hamish|harvard|heric|hoplite|kang wu|knight|marchella|mr. hyena|ms. crane|ninja|outlaw|persuica|phos-phor|rahn-fara-wai|ronin|rujona|samurai|smuggler captain|student|the grflx|boss|truckle|vincent|vyrt|willie)|(?<xp5_s_P>hattian guard)|(?<xp5_s_I>citadel guard)|(?<xp5_s_M>d'reg))s?|(?#
* man --> men
)((?<xp5man_men_>(helms))|(?<xp5man_men_M>d'reg (wo)?))m[ea]n|(?#
 MEDIUM HIGH XP: 4
* '' --> s
)((?<xp4_s_IM>cutthroat)|(?<xp4_s_M>(foul|surplus) warrior)|(?<xp4_s_>(swarthy|burly|muscular) slave|assassin|barbarian|bodyguard|bois|brindisian (boy|girl|nonna)|captain|character|courtesan|crocodile|dancer|drunk patron|evil cabbage|fighter|grflx \w+[^s]|khepresh|lascarim|monk|mugger|nitsuni|officer|pirate|powerful athlete|prodo|red-bearded dwarf|sebboh|security guard|sergeant|skipper|smuggler|soldier|splatter|stevedore|teh-takk-eht|the weasel|thug|tsimo handler|tsimo wrestler|warrior|weapon master)|(?<xp4_s_P>priest))s?|(?#
* x --> xen
)(?<xp4x_xen_>grfl)x(en)?|(?#
* y --> ies
)(?<xp4y_ies_>genteel lad|mercenar|triad heav)(y|ies)|(?#
* ss --> sses
)(?<xp4ss_sses_P>prieste)(ss(es)?)|(?#
* man --> men
)((?<xp4man_men_M>(gentle|noble) ?(wo)?)|(?<xp4man_men_>(athletic|rowdy|sophisticated) wo|(stern.looking|tough|wiry|burly|muscular|muscled|sinewy|hefty) |brindisian |watch))m[ea]n|(?#
 MEDIUM XP: 3
* y --> ies
)((?<xp3y_ies_M>(beautiful|enticing|elegant) lad)|(?<xp3y_ies_>ebon|(?!old )lad))(y|ies)|(?#
* '' --> s
)((?<xp3_s_>actor|adnew|athlete|banker|brawler|calligrapher|civil servant|corporal nobbs|courtesan|crier|daft bugger|dealer|deborah macghi|dogbottler|druid|dwarf warrior|fibre|gnirble|gritjaw thighsplitter|hag|hawker|(?<!s)hopper|hrun|jeweller|lawyer|lip-phon lap-top|lotheraniel|mandarin|masqued magician|merchant|notserp|onuwen|poet|protester|recruit|royal judge|scribe|silversmith|souvlakios|stren|tfat chick|thibeau|tourist|trader|travelling troll|trickster|tuchoille|vendor|wenche|wizard)|(?<xp3_s_I>donkey)|(?<xp3_s_M>(official|bureaucrat|philosopher)))s?|(?#
* man --> men
)((?<xp3man_men_M>(debonair|proud|rich|scarred) (wo)?)|(?<xp3man_men_>crew|conm(wo)?|fisher|sales(wo)?|tally))m[ea]n|(?#
 MEDIUM LOW XP: 2
* f --> ves
)(?<xp2f_ves_>thie)(f|ves)|(?#
* y --> ies
)(?<xp2y_ies_>old lad)(y|ies)|(?#
* fe --> ves
)(?<xp2fe_ves_I>housewi)|(?#
* '' --> s
)((?<xp2_s_M>(swarthy|muscular) slave|duke|courtier)|(<xp2_s_M>(well.off|rich) citizen)|(?<xp2_s_>accountant|ambassador|architect|artisan|beggar|believer|brat|cadger|cat|citizen|dinoe|docker|dog|drunk guest|dwarf|engineer|farmer|father|juggler|labourer|mother|nacirrut|paperboy|pickpocket|sailor|sandy ptate|seller|sensei|servant|slave|sle-pingh-beuh-tei|snaxabraxas|sow|starlet|stone mason|sweeper|troll|ylit)|(?<xp2_s_I>(adelphe|calleis|cynere|driver|goat|lea|limos|odeas|urchin))s?)|(?#
* man --> men
)(?<xp2man_men_>(old )?(wo)?)m[ea]n|(?#
 LOW XP:  1
* '' --> ren
)(?<xp1_ren_>child)(ren)?|(?#
* '' --> s
)(?<xp1_s_>boy|bullfrog|cabbage|cadger|crow|dog|dragon|drunkard|duck(ling)?|girl|hen|hound|mendicant|pigeon|potter|rat|schoolboy|scorpion|snake|tortoise|youth|zombie)s?|(?#
* ouse --> ice
)(?<xp1ouse_ice_>m)(ouse|ice)|(?#
 ZERO XP: 0
* '' --> s
)(?<xp0_s_>(?<=(cloud))|(?<=(fruitbat))|horseman .*?|(?<=(truffle pig))s?))(?<hiding> [(]hiding[)])?$]]),
		remainder = rex.new(
[[^(?:(?:(an?|one)|(two)|(three)|(four)|(five)|(six)|(seven)|(eight)|(nine)|(ten)|(eleven)|(twelve)|(thirteen)|(fourteen)|(fifteen)|(sixteen)|(seventeen)|(eighteen)|(nineteen)|(twenty)|(many)) )?(?#
 REMAINDER: 00
)((?<xp00ss_sses_>.*(?=ss(es)?))|(?<xp00y_ies_>.*?(?=(y|ies)))|(?<xp00man_men_>.*?(?=m[ea]n))|(?<xp00_s_>.*?(?=s?)))(ss(es)?|y|ies|m[ea]n|s)?(?<hiding> [(]hiding[)])?$]]),
	}
end
-------------------------------------------------------------------------------
--   DEBUGGING
-------------------------------------------------------------------------------
function bprint(t)
	local debug = false
	if debug then
		if type(t) == 'table' then
			tprint(t)
		else
			print(t)
		end
	end
end

function on_alias_mdt_debug_gmpc(name, line, wildcards)
	print(map_door_text)
end
--------------------------------------------------------------------------------
--   START EXECUTION HERE
--------------------------------------------------------------------------------
on_plugin_start()
