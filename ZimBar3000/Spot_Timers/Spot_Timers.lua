--------------------------------------------------------------------------------
--   INSTALL AND SAVE
--------------------------------------------------------------------------------
function on_plugin_start()
    require "tprint"
    require "serialize"
    require "var"	
    require "pairsbykeys"
	require "check"
    win = "spots"..SPT-- define window name
    spots_get_variables()
    spots_get_windows()
    spots_window_setup(window_width, window_height)
    spots_get_hotspots(spt.dimensions)
end

function spots_get_variables()
	colours_database =  GetPluginInfo(SPT, 20):gsub("\\([^\\]+)\\$", "\\shared\\").."_colours.db"
	fonts_database   =  GetPluginInfo(SPT, 20):gsub("\\([^\\]+)\\$", "\\shared\\").."_fonts.db"
	spots_database   =  GetPluginInfo(SPT, 20):gsub("\\([^\\]+)\\$", "\\shared\\").."_spots.db"
	FIXED_TITLE_HEIGHT = 16
    local default_window_width, default_window_height = 100, 500
    window_width, window_height = tonumber(GetVariable("window_width") or default_window_width), tonumber(GetVariable("window_height") or default_window_height)
	assert(loadstring(GetVariable("spt") or ""))()
	spots_get_data()
	window_pos_x, window_pos_y = tonumber(GetVariable("window_pos_x")), tonumber(GetVariable("window_pos_y"))
	spots_get_colours()

end

function OnPluginSaveState () -- save variables
	var.spt = "spt = "..serialize.save_simple(spt)
	var.window_width = window_width
	var.window_height = window_height
	var.window_pos_x = WindowInfo(win, 10)
	var.window_pos_y = WindowInfo(win, 11)
end

function OnPluginInstall() end
function OnPluginEnable() WindowShow(win, true) end -- show miniwindow on enable
function OnPluginDisable() WindowShow(win, false) end -- hide miniwindow on disable
function OnPluginClose() WindowShow(win, false) end -- hide miniwindow on close
--------------------------------------------------------------------------------
--   RESET FUNCTIONS
--------------------------------------------------------------------------------
function spots_get_data()
	-- get room ids
	spt = spt or {}
	spt.room_ids = {}; spt.spots = spt.spots or {}
	sdb = sqlite3.open(spots_database)
	for t in sdb:nrows("SELECT * FROM room_ids") do 
		spt.room_ids[t.id] = t.spot
	end
	-- get spot attributes
	regex = {mob = {}}
	for t in sdb:nrows("SELECT * FROM spots") do 
		spt.spots[t.name] = spt.spots[t.name] or {}
		for k, v in pairs(t) do
			if k ~= "name" then
				if k == "mob" then
					regex.mob[t.name] = rex.new(v)
				elseif k:match("range%d") then
					local i = tonumber(k:match("range(%d)"))
					spt.spots[t.name].range = spt.spots[t.name].range or {}
					spt.spots[t.name].range[i] = v
				else
					spt.spots[t.name][k] = v
				end
			end
		end
	end
	sdb:close()
	for spot in pairs(spt.spots) do
		spt.spots[spot].kill_count = spt.spots[spot].kill_count or 0
		for _, v in ipairs({"time_entered", "time_exited", "time_killed", "initial_xp", "final_xp", "is_down ", "is_big_spawn", "is_hidden"}) do
			spt.spots[spot][v] = spt.spots[spot][v] or false
		end
		spt.spots[spot].position = spt.spots[spot].id
	end
	spt.sort_mode = spt.sort_mode or {}
	spt.sort_mode = {"static", "number", "colour", selected = spt.sort_mode.selected or 3}
	spt.title = spt.title or "Spots"
	spt.current_spot = {} -- use table so we can easily handle boss+medina, cap+smugs
	spt.current_xp = false
	spt.need_final_xp = {}
end

-- initial setting, identical to never visited
function spots_restore(spot)
	spt.spots[spot].kill_count   = 0
	for _, v in ipairs({"time_entered", "time_exited", "time_killed", "initial_xp", "final_xp", "is_down", "is_big_spawn"}) do
		spt.spots[spot][v] = false
	end
end

function spots_restore_all()
	for k in pairs(spt.spots) do
		restore_spot(k)
	end
end

-- mimic killing a spot (scry somebody killing spot, arrive to empty spot as another group is leaving ect.)
function spots_reset(spot)
	spt.spots[k].kill_count   = 0
	spt.spots[k].initial_xp   = 0
	spt.spots[k].final_xp     = 0
	spt.spots[k].is_down      = false
	spt.spots[k].is_big_spawn = false
	spt.spots[k].time_entered = os.time()
	spt.spots[k].time_exited  = os.time()
	spt.spots[k].time_killed  = os.time()
end
--------------------------------------------------------------------------------
--   MINIWINDOW SETUP
--------------------------------------------------------------------------------
function spots_get_windows(dim) -- dimensions
    WindowCreate(win, 0, 0, 0, 0, miniwin.pos_center_all, 0, spt.colours.window_background)
    for k in pairs(spt.spots) do
		 WindowCreate(win..k, 0, 0, 0, 0, miniwin.pos_center_all, 0, spt.colours.window_background)
    end
    WindowCreate(win.."stats", 0, 0, 0, 0, miniwin.pos_center_all, 0, spt.colours.window_background)   
    WindowSetZOrder(win, 199)
end

function spots_window_setup(window_width, window_height) -- define window attributes
    
    local function get_window_dimensions(window_width, window_height)
        local dim = {}
        dim.window = {
			x = window_width,
			y = window_height,}
        dim.titlebar = {
			x = window_width,
			y = FIXED_TITLE_HEIGHT,}
        dim.buffer = {
			x = 5,
			y = 5,}
        dim.line_buffer = {
			x = 2,
			y = 2,}
		dim.not_titlebar = {
			x = window_width,
			y = window_height - FIXED_TITLE_HEIGHT,}	
		local stat_lines = 3	
		local spot_lines = 0
		for k, v in pairs(spt.spots) do
			if not v.is_hidden then
				spot_lines = spot_lines + 1
			end
		end	
		local total_lines = spot_lines + stat_lines
		dim.stat_section = {
			x = window_width - 2 * dim.buffer.x,
			y = ((dim.not_titlebar.y / total_lines) * stat_lines) - 2 * dim.buffer.y}			
		dim.spot_section = {
			x = window_width - 2 * dim.buffer.x,
			y = ((dim.not_titlebar.y / total_lines) * spot_lines) - 2 * dim.buffer.y}	
		dim.stat_line = {
			x = dim.stat_section.x,
			y = (dim.stat_section.y - dim.line_buffer.y * (stat_lines - 1)) / stat_lines,}
		dim.spot_line = {
			x = dim.spot_section.x,
			y = (dim.spot_section.y - dim.line_buffer.y * (spot_lines - 1)) / spot_lines,}
		dim.time = {
			x = (dim.spot_section.x - dim.line_buffer.x) / 2,
			y = dim.spot_line.y,}
		dim.spot = {
			x = (dim.spot_section.x - dim.line_buffer.x) / 2,
			y = dim.spot_line.y,}
        return dim
    end

    local function get_coordinates(dim) --dimensions
		spt.coordinates = {}
		-- titlebar coordinates in respect to main mw
		spt.coordinates.titlebar = {x1 = 0, y1 = 0, x2 = dim.titlebar.x, y2 = dim.titlebar.y}
		-- spot-line coordinates in respect to main mw
		spt.coordinates.spot_line = {} 
		local x1 = dim.buffer.x
		local x2 = x1 + dim.spot_line.x
		local y1 = dim.titlebar.y + dim.buffer.y
		local y2 = y1 + dim.spot_line.y
		for _ in pairs(spt.spots) do
			y2 = y1 + dim.spot_line.y
			table.insert(spt.coordinates.spot_line, {x1 = x1, y1 = y1, x2 = x2, y2 = y2})
			y1 = y2 + dim.line_buffer.y
		end
		-- spot, time, colon coordinates in respect to hidden miniwindow used to stage images    
		spt.coordinates.spot = {x1 = 0, y1 = 0, x2 = dim.spot.x, y2 = dim.spot.y}	
		x1 = dim.spot.x + dim.line_buffer.x
		x2 = x1 + dim.time.x
		spt.coordinates.time = {x1 = x1, y1 = 0, x2 = x2, y2 = dim.time.y}
		local w = WindowTextWidth(win, "spot_time", ":")
		x1 = x2 - (dim.time.x + w) / 2
		x2 = x1 + w
		spt.coordinates.colon = {x1 = x1, y1 = 0, x2 = x2, y2 = dim.time.y}
		-- divider coordinates in respect to main mw
		x1 = 0
		x2 = dim.window.x
		y1 = dim.window.y - (dim.stat_section.y + 2 * dim.buffer.y)
		y2 = y1
		spt.coordinates.divider = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
	end

    local function resize_windows(dim) -- dimensions 
        WindowResize(win, dim.window.x, dim.window.y, miniwin.pos_center_all, 0, spt.colours.window_background)
		for k in pairs(spt.spots) do
			WindowResize(win..k, dim.spot_line.x, dim.spot_line.y, miniwin.pos_center_all, 0, spt.colours.window_background)
		end
		WindowResize(win.."stats", dim.stat_section.x, dim.stat_section.y, miniwin.pos_center_all, 0, spt.colours.window_background)
		WindowPosition(win, WindowInfo(win, 10), WindowInfo(win, 11), 0, 2)
	end
    spt.dimensions = get_window_dimensions(window_width, window_height)
    spots_get_font (spt.dimensions)
    resize_windows (spt.dimensions)
    get_coordinates(spt.dimensions)
    spots_draw_base(spt.dimensions)
end
--------------------------------------------------------------------------------
--   COLOURS
--------------------------------------------------------------------------------
function spots_get_colours()
	spt.colours = {}
	cdb = sqlite3.open(colours_database)
	for t in cdb:nrows("SELECT colour_name FROM spots") do 
		for k, v in pairs(t) do
			spt.colours[v] = {}
			for c in cdb:nrows("SELECT * FROM "..v) do
				spt.colours[v][c.id] = c.custom or ColourNameToRGB(c.preset)
			end
			if #spt.colours[v] == 1 then
				spt.colours[v] = spt.colours[v][1]
			end
		end 
	end
	cdb:close()
end

function spots_select_custom_colour(colour, colour_name, i)
	local new_colour = PickColour(colour)
	if new_colour ~= -1 then
		if i then
			spt.colours[colour_name][i] = new_colour
		else
			spt.colours[colour_name] = new_colour
		end
		cdb = sqlite3.open(colours_database)
		cdb:exec("UPDATE "..colour_name.." SET custom = "..new_colour..(i and " WHERE id = "..tostring(i) or ""))
		cdb:close()
		BroadcastPlugin(173, colour_name..(i and tostring(i) or ""))
		--run setup and print here
	end
end

function spots_restore_default_colour(colour_names)
	cdb = sqlite3.open(colours_database)
    for k, v in pairs(colour_names) do
		colour_name, i = k:match("^(.*)(%d)$")
		colour_name = colour_name or k
		cdb:exec("UPDATE "..colour_name.." SET custom = NULL"..(i and " WHERE id = "..tostring(i) or "")..";")
		for c in cdb:nrows("SELECT preset FROM "..colour_name..(i and " WHERE id = "..tostring(i) or "")) do
			if i then
				spt.colours[colour_name][i] = ColourNameToRGB(c.preset)
			else
				spt.colours[colour_name] = ColourNameToRGB(c.preset)
			end
		end	
	end
	cdb:close()
	BroadcastPlugin(173, "all")
	--run setup and print here
end

function spots_restore_every_default_colour()
	local stmt = ""
	cdb = sqlite3.open(colours_database)
	local every_colour = {}
	for t in cdb:nrows("SELECT colour_name FROM colours") do
		table.insert(every_colour, t.colour_name)
	end
	for _, colour_name in ipairs(every_colour) do
		stmt = stmt.."UPDATE "..colour_name.." SET custom = NULL;"
	end
	cdb:exec(stmt)
	cdb:close()
	spots_get_colours()
	BroadcastPlugin(173, "all")
	--run setup and print here
end

function spots_update_colours(msg, id, name, text)
	if text == "all" then
		spots_get_colours()
		--run setup and print here
	else
		local colour_name, i = text:match("^(.-)(%d?)$")
		if i then i = tonumber(i) end
		cdb = sqlite3.open(colours_database)
		for c in cdb:nrows("SELECT * FROM "..colour_name..(i and " WHERE id = "..tostring(i) or "")) do
			if i then
				spt.colours[colour_name][i] = c.custom or ColourNameToRGB(c.preset)
			else
				spt.colours[colour_name] = c.custom or ColourNameToRGB(c.preset)
			end
		end	
		cdb:close()
		--run setup and print here		
	end
end

function spots_fade_RGB(colour1, colour2, percentage)
		local function rgb_to_hex(col)
			if type(col) == "number" then
				local b, g, r = string.match(string.format("%06x", col), "([0-9a-f][0-9a-f])([0-9a-f][0-9a-f])([0-9a-f][0-9a-f])")
				return "#"..r..g..b
			else
				return col
			end
		end
		local function dec_to_hex(dec)
			dec = tonumber(dec)
			local hex = string.format("%X", dec)
			if dec < 16 then
				return "0"..tostring(hex)
			else
				return hex
			end
		end
		colour1 = rgb_to_hex(colour1)
		colour2 = rgb_to_hex(colour2)
		r1, g1, b1 = string.match(colour1, "#([0-9a-f][0-9a-f])([0-9a-f][0-9a-f])([0-9a-f][0-9a-f])")
		r2, g2, b2 = string.match(colour2, "#([0-9a-f][0-9a-f])([0-9a-f][0-9a-f])([0-9a-f][0-9a-f])")
		r3 = tonumber(r1, 16)*(100-percentage)/100.0 + tonumber(r2, 16)*(percentage)/100.0
		g3 = tonumber(g1, 16)*(100-percentage)/100.0 + tonumber(g2, 16)*(percentage)/100.0
		b3 = tonumber(b1, 16)*(100-percentage)/100.0 + tonumber(b2, 16)*(percentage)/100.0
		return ColourNameToRGB("#"..dec_to_hex(r3).. dec_to_hex(g3)..dec_to_hex(b3))
	end
--------------------------------------------------------------------------------
--   FONTS
--------------------------------------------------------------------------------
function spots_get_font(dim)
	spt.dimensions.font = {}
	-- chose our fonts, pick backups if unavailable
	local function choose_fonts()
		local font_choices = {}
		fdb = sqlite3.open(fonts_database)
		for t in fdb:nrows("SELECT * FROM fonts") do
			font_choices[t.name] = {t.custom or "", t.preset1, t.preset2}
		end
		fdb:close()
		local f_tbl = utils.getfontfamilies() -- all possible fonts
		local chosen_fonts = {}
		 -- if our chosen font exists then pick it
		for name, t in pairs(font_choices) do
			chosen_fonts[name] = false
			for i, v in ipairs(t) do
				if f_tbl[v] then
					chosen_fonts[name] = v
					break
				end
			end
		end
		-- if none of our chosen fonts are avaliable, pick the first one that is
		for name, v in pairs(chosen_fonts) do 
			if not v then
				for k in pairs(f_tbl) do
					chosen_fonts[name] = k
					break
				end
			end
		end
		return chosen_fonts
	end
	local fonts = choose_fonts()
	for c, p in pairs({titlebar_text = FIXED_TITLE_HEIGHT, spot_text = dim.spot_line.y, spot_time = dim.spot_line.y, spot_stats = dim.stat_line.y}) do
		local max = 200
		local h, s = 0, 1
		local f = fonts[c]
		while (h < p) and (s < max) do
			assert(WindowFont(win, c, f, s, false, false, false, false), tostring(win).." "..tostring(c).." "..tostring(f).." "..tostring(s))
			h = tonumber(WindowFontInfo(win, c, 1)) or h or 0
			if h > p then
				s = (s - 1) > 1 and (s - 1) or 1
				assert(WindowFont(win, c, f, s, false, false, false, false), tostring(win).." "..tostring(c).." "..tostring(f).." "..tostring(s))
				h = tonumber(WindowFontInfo(win, c, 1)) or h or 0
				break
			end
			s = s + 1
		end
		for _, mw in ipairs(WindowList()) do
			if mw:match(SPT) then
				assert(WindowFont(mw, c, f, s, false, false, false, false), tostring(mw).." "..tostring(c).." "..tostring(f).." "..tostring(s))
				assert(WindowFont(mw, c.."underlined", f, s, false, false, true, false), tostring(mw).." "..tostring(c).." "..tostring(f).." "..tostring(s))
				assert(WindowFont(mw, c.."strikethrough", f, s, false, false, false, true), tostring(mw).." "..tostring(c).." "..tostring(f).." "..tostring(s))
				spt.dimensions.font[c] = h or 0
			end
		end
	end
end
    
function spots_select_custom_font(font_id, fonts, i)
	if i then
		local new_font = fonts[i]
		fdb = sqlite3.open(fonts_database)
		fdb:exec([[UPDATE fonts SET custom = ']]..new_font..[[' WHERE name = ']]..font_id..[[';]])
		fdb:close()
		BroadcastPlugin(727, "update fonts")
		spots_window_setup(window_width, window_height)
		-- print here
	end
end

function spots_restore_default_font(font_id)
	fdb = sqlite3.open(fonts_database)
	fdb:exec([[UPDATE fonts SET custom = NULL WHERE name = ']]..font_id..[[';]])
	fdb:close()
	BroadcastPlugin(727, "update fonts")
	spots_window_setup(window_width, window_height)
	--print window here
end

function spots_restore_every_default_font()
	fdb = sqlite3.open(fonts_database)
	fdb:exec([[UPDATE fonts SET custom = NULL;]])
	fdb:close()
	BroadcastPlugin(727, "update fonts")
	spots_window_setup(window_width, window_height)
	--print window here
end

function spots_update_fonts(msg, id, name, text)
	spots_window_setup(window_width, window_height)
	--print window here
end
--------------------------------------------------------------------------------
--   HOTSPOTS
--------------------------------------------------------------------------------
function spots_get_hotspots(dim) -- dimensions
    WindowAddHotspot(win, "title",
         0, 0, dim.window.x, dim.font.titlebar_text, 
         "",   
         "",  
         "mousedown",
         "cancelmousedown", 
         "mouseup", 
        "Left-click to drag!", 
         1, 0)  
    WindowDragHandler(win, "title", "dragmove", "dragrelease", 0)
    -- add handler for resizing
    WindowAddHotspot(win, "resize", dim.window.x - 10, dim.window.y - 10, dim.window.x, dim.window.y, "MouseOver", "CancelMouseOver", "mousedown", "", "MouseUp", "Left-click to resize!", 6, 0)
    WindowDragHandler(win, "resize", "ResizeMoveCallback", "ResizeReleaseCallback", 0)
end
--------------------------------------------------------------------------------
--   HOTSPOT HANDLERS
--------------------------------------------------------------------------------
-- drag handler
function dragmove(flags, hotspot_id)
	if hotspot_id == "title" then
        local max_x, max_y = GetInfo(281), GetInfo(280)
        local min_x, min_y = 0, 0
		local drag_x, drag_y = WindowInfo(win, 17), WindowInfo(win, 18)
        local to_x, to_y = drag_x - from_x, drag_y - from_y
        if to_x < min_x then 
            to_x = 0 
        elseif to_x + window_width > max_x then
            to_x = max_x - window_width
        end
        if to_y < min_y then 
            to_y = 0 
        elseif to_y + window_height > max_y then
            to_y = max_y - window_height
        end
		WindowPosition(win, to_x, to_y, 0, 2) -- move the window to the new location
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
function ResizeMoveCallback()
    local auto_pos = WindowInfo(win, 7)
    if auto_pos ~= 0 then 
		-- workaround to weirdness with intitial resize, if window has not
		-- yet been moved with drag-handler. Basically, auto positioning is calculated 
		-- each time the screen is redrawn so we have to force a redraw to know
		-- it's coordinates and then manually position the window to where it already is 
		-- in order to remove it from auto-positioning mode
		Repaint() 
		WindowPosition(win, WindowInfo(win, 10), WindowInfo(win, 11), 0, 2)
	end
    local min_x, min_y = 50, 50
    local start_x, start_y = WindowInfo(win, 10), WindowInfo(win, 11)
    local drag_x,   drag_y = WindowInfo(win, 17), WindowInfo(win, 18)
    local max_x,     max_y = GetInfo(281),        GetInfo(280)
    window_width  = drag_x - start_x
    window_height = drag_y - start_y
    window_pos_x =  drag_x
    window_pos_y =  drag_y

    local out_of_bounds = false
    if window_width  + start_x > max_x then 
        window_width  = max_x - start_x; out_of_bounds = true
    end
    if window_height + start_y > max_y then 
        window_height = max_y - start_y; out_of_bounds = true
    end
    if window_width  < min_x then 
        window_width  = min_x; out_of_bounds = true 
    end
    if window_height < min_y then 
        window_height = min_y; out_of_bounds = true
    end
    if out_of_bounds then
        check(SetCursor(11)) -- x cursor
    else
        check(SetCursor(6)) -- resize cursor
    end
    if (utils.timer() - (last_refresh or 0) > 0.0333) then
        WindowResize(win, window_width, window_height, spt.colours.window_background)
        WindowDrawImage(win, "win", 0, 0, window_width, window_height, 2)
        WindowShow(win)
        last_refresh = utils.timer()
   end
end

-- called after the resize widget is released
function ResizeReleaseCallback()
    spots_window_setup(window_width, window_height)
    spots_get_hotspots(spt.dimensions)
end

-- called when mouse button is pressed on hotspot
function mousedown(flags, hotspot_id)
    if hotspot_id == "title" then
		from_x, from_y = WindowInfo(win, 14), WindowInfo(win, 15)
    elseif (hotspot_id == "resize") then
        WindowImageFromWindow(win, "win", win)
    end
end

function mouseup(flags, id)
	if id:match("title") and flags == 32 then
		--spots_get_title_menu()
    end
end
--------------------------------------------------------------------------------
--   PLUGIN COMMUNICATION
--------------------------------------------------------------------------------
function OnPluginBroadcast(msg, id, name, text)
	if msg == 173 then
		--spots_update_colours(msg, id, name, text)
	elseif msg == 727 then
		--spots_update_fonts(msg, id, name, text)
	end
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
        spots_recieve_GMCP(data_line)
    end
end

function spots_recieve_GMCP(text)
    if text:match("^char.vitals .*") then
        local xp = tonumber(text:match('"xp":(%d+)'))
		spt.current_xp = xp
		-- we can't just set final xp to current cp as we leave because
		-- it may not have been updated with bury xp yet
		for k in pairs(spt.need_final_xp) do
			spt.spots[k].final_xp = xp
		end
		spt.need_final_xp = {}
    elseif text:match("^room.info .*") then
        local id = text:match('^.*"identifier":"(.-)".*$')
        local spot_name = spt.room_ids[id]
        local is_in_spot = false
        local is_need_update = false
        for k in pairs(spt.current_spot) do
			is_in_spot = true; break
        end
        if is_in_spot and not spt.current_spot[spot_name] then
			spots_leave(spt.current_spot); is_need_update = true
        end
        if spot_name and not spt.current_spot[spot_name] then
			spots_enter(spot_name); is_need_update = true
		end
		if is_need_update then
			spots_print(spt.dimensions)
		end
    end
end
--------------------------------------------------------------------------------
--   ENTER / EXIT HANDLING
--------------------------------------------------------------------------------
function spots_enter(spot_name)
	if spot_name == "medina" then
		EnableTrigger("spots_enter_boss")
	elseif spot_name == "smugs" then
		EnableTrigger("spots_enter_captain")
	elseif spot_name == "shades" then
		EnableTrigger("spots_shades_bury")
	end	
	spt.current_spot[spot_name] = true
	spt.spots[spot_name].time_exited = false
	spt.need_final_xp[spot_name] = nil
	-- don't reset if last exited was within 2 minutes
	-- (reshielding crocs, giants toss etc.)
	if spt.spots[spot_name].time_entered and os.time() - spt.spots[spot_name].time_entered >= 120 or not (spt.spots[spot_name].time_entered)  then
		spt.spots[spot_name].time_entered = os.time()
		spt.spots[spot_name].kill_count = 0
		spt.spots[spot_name].initial_xp = spt.current_xp
		spt.spots[spot_name].final_xp = spt.current_xp
	end
	print("enter", spot_name)
end

function spots_leave(spot)
	local function leave_spot(spot_name)
		if spot_name == "medina" and spt.current_spot.boss then
			leave_spot("boss")
			EnableTrigger("spots_enter_boss", false)
		elseif spot_name == "smugs" and spt.current_spot.captain then
			leave_spot(captain)
			EnableTrigger("spots_enter_captain", false)
		elseif spot_name == "shades" then
			EnableTrigger("spots_shades_bury", false)
		end	
		spt.current_spot[spot_name] = nil
		spt.spots[spot_name].time_exited = os.time()
		spt.spots[spot_name].final_xp = spt.current_xp
		spt.need_final_xp[spot_name] = true
		spt.spots[spot_name].is_down = true
		spt.spots[spot_name].is_big_spawn = false
		if spt.spots[spot_name].kill_count >= spt.spots[spot_name].kill_reset then
			spt.spots[spot_name].time_killed = os.time()
			spt.spots[spot_name].is_down = false
			if spt.spots[spot_name].kill_count >= spt.spots[spot_name].kill_high then
				spt.spots[spot_name].is_big_spawn = true
			end
		end
		print("leave", spot_name)
	end
	if type(spot) == "table" then
		for k in pairs(spot) do
			leave_spot(k)
		end
	else
		leave_spot(spot)
	end
end
--------------------------------------------------------------------------------
--   TRIGGER EVENTS
--------------------------------------------------------------------------------
function on_trigger_spots_kill(name, line, wildcards, styles)
	for k in pairs(spt.current_spot) do
		local s, e, t = regex.mob[k]:match(wildcards.mob)
		if t then
			spt.spots[k].kill_count = spt.spots[k].kill_count + 1
			if k == "boss" or k == "captain" then
				spots_leave(k)
			end
			-- we use equals and not not equals or greater than so we don't
			-- continuously reset time after threshold
			if spt.spots[k].kill_count == spt.spots[k].kill_reset then
				spt.spots[k].time_killed = os.time()
				spt.spots[k].is_down = false
			end
			if spt.spots[k].kill_count == spt.spots[k].kill_high then
				spt.spots[k].is_big_spawn = true
			end
		end
	end
end

function on_trigger_spots_enter_sub_spot(name, line, wildcards, styles)
	local spot_name = name:match("_(%w+)$")
	if not spt.current_spot[spot_name] then
		spots_enter(spot_name)
	end
end
-- use bury instead of kill for shades count as to not miss data while herding
function on_trigger_spots_shades_bury(name, line, wildcards, styles)
	local numbers = {a = 1, an = 1, the = 1, one = 1, two = 2, three = 3, four = 4, five = 5, six = 6, seven = 7, eight = 8, nine = 9, ten = 10, eleven = 11, twelve = 12, thirteen = 13, fourteen = 14, fifteen = 15, sixteen = 16, seventeen = 17, eighteen = 18, nineteen = 19, twenty = 20, many = 20,}
	wildcards.mobs:gsub("(%w+) corpse", function(c)
		spt.spots.shades.kill_count = spt.spots.shades.kill_count + (numbers[c] or 0)
	end)
	if spt.spots.shades.kill_count >= spt.spots.shades.kill_reset then
		spt.spots.shades.time_killed = os.time()
		spt.spots.shades.is_down = false
		if spt.spots.shades.kill_count >= spt.spots.shades.kill_high then
			spt.spots.shades.is_big_spawn = true
		end
	end
end
--------------------------------------------------------------------------------
--   GRAPHICS
--------------------------------------------------------------------------------
function spots_draw_titlebar(dim, col)
	local coor = spt.coordinates.titlebar
	WindowCircleOp(win, 2, coor.x1, coor.y1, coor.x2, coor.y2, col.titlebar_border, 0, 1, col.titlebar_fill, 0)
	local w = WindowTextWidth(win, "titlebar_text", spt.title)
	local x1 = (dim.window.x - w) / 2
	local min = 1
	if x1 < min then x1 = min end
	WindowText(win, "titlebar_text", spt.title, x1, 0, 0, 0, col.titlebar_text)
end

function spots_draw_base(dim)
	local col = spt.colours
	local coor = spt.coordinates.divider
	WindowCircleOp(win, 2, 0, 0, dim.window.x, dim.window.y, col.window_border, 0, 1, col.window_background, 0)
	spots_draw_titlebar(dim, col)
	WindowLine(win, coor.x1, coor.y1, coor.x2, coor.y2, col.window_divider, miniwin.pen_dot, 1)
	spots_print(dim)
end

function spots_print(dim)
	-- draw individual spot lines and print to main window
	local function draw_spot(spot_name, v, col, dim, pos)
		-- draw spot name
		local function draw_name(spot_name, v, col, dim, mw)
			local display_name = spot_name -- add if statements here if you don't like the default display names
			local text_colour, bg_colour = v.text_colour[2], v.bg_colour[2]
			WindowCircleOp(mw, 2, 0, 0, dim.spot.x, dim.spot.y, bg_colour, 0, 1, bg_colour, 0)
			local w = WindowTextWidth(mw, "spot_text", display_name..(v.is_big_spawn and "!" or ""))
			local x1 = (dim.spot.x - w) / 2
			local min = 1; if x1 < min then x1 = min end
			-- use strikethrough if spot is down, add exclimation point if there was an especially large spawn
			WindowText(mw, "spot_text"..(v.is_down and "strikethrough" or ""), display_name..(v.is_big_spawn and "!" or ""), x1, 0, 0, 0, text_colour)
		end
		-- draw display time
		local function draw_time(spot_name, v, col, dim, mw)
			local text_colour, bg_colour = v.text_colour[1], v.bg_colour[1]
			local coor = spt.coordinates.time
			WindowCircleOp(mw, 2, coor.x1, coor.y1, coor.x2, coor.y2, bg_colour, 0, 1, bg_colour, 0)
			coor = spt.coordinates.colon
			WindowText(mw, "spot_time", ":", coor.x1, 0, 0, 0, text_colour)
			if v.minutes and v.seconds then
				local w = WindowTextWidth(mw, "spot_time", v.minutes)
				WindowText(mw, "spot_time", v.minutes, coor.x1 - w - dim.line_buffer.x, 0, 0, 0, text_colour)
				WindowText(mw, "spot_time", v.seconds, coor.x2 + dim.line_buffer.x, 0, 0, 0, text_colour)
			end
		end
		local mw = win..spot_name
		WindowCircleOp(mw, 2, 0, 0, dim.spot_line.x, dim.spot_line.y, col.window_background, 0, 1, col.window_background, 0)
		draw_time(spot_name, v, col, dim, mw)
		draw_name(spot_name, v, col, dim, mw)
		WindowImageFromWindow(win, spot_name, mw)
		local coor = spt.coordinates.spot_line[pos]
		-- print to main window
		WindowDrawImage(win, spot_name, coor.x1, coor.y1, 0, 0, 1)	
	end
	-- determine text and background colours for names and times
	local function get_spot_colour(spot_name, v, col) 
		local text_colour = {col.spot_text_unvisited, col.spot_text_unvisited} 
		local bg_colour   = {col.window_background,   col.window_background}
		local range, percentage
		-- spot name colour is based on time killed, time colour is based on time entered
		for i, start_time in ipairs({v.time_entered, v.time_killed,}) do
			range, percentage = 8, 0
			-- the 'range' refers to the current time range that our time point falls into
			-- the only reason we classify this now is to make it easier to sort by colour
			-- later. The possible values are as follows:
			-- 1 = below range point 1
			-- 2 = below range point 2
			-- 3 = below range point 3
			-- 4 = below range point 4
			-- 5 = below range point 5
			-- 6 = above range point 5
			-- 7 = never visited while up
			-- 8 = completly unvisited
			if start_time then
				text_colour[i] = col.spot_text
				local end_time = (os.time() - start_time) / 60
				for p = 1, 5 do
					range = p
					if v.range[p] > end_time then	
						if p == 1 then
							-- colour at minimum
							bg_colour[i] = col.time_range[p]
							break
						else
							local min , max = v.range[p - 1] or 0, v.range[p]
							percentage =  (end_time - min) / (max - min) * 100		
							-- colour fade based on percentage between range points
							bg_colour[i] = spots_fade_RGB(col.time_range[p - 1], col.time_range[p], percentage)
							break
						end
					elseif p == 5 then
						range = range + 1
						-- colour at maximum
						bg_colour[i] = col.time_range[p]
					end
				end
			else
				if v.is_down then range = 7 end
			end
		end
		--print(spot_name, text_colour, bg_colour, range, percentage, v.time_killed and( (os.time() - v.time_killed) / 60))
		return text_colour, bg_colour, range, percentage
	end
	-- get our display time, this function returns miutes and seconds
	-- seperatly so that we can ensure that the colon in the middle
	-- always remains perfectly centered, even with non mono space fonts
	local function get_time(spot_name, v)
		-- leaving the option to easily code in display of another time
		-- i.e. time exited or killed
		local start_time = v.time_entered 
		local end_time = os.time()
		if start_time then
			local minutes, seconds = 0, 0
			minutes = math.floor((end_time - start_time) / 60)
			seconds = (end_time - start_time) - (minutes * 60)
			if seconds < 10 then
				seconds = "0"..tostring(seconds)
			end
			return tostring(minutes), tostring(seconds), start_time
		else
			return false, false, false
		end
	end
	for k, v in pairs(spt.spots) do
		-- restore spot after 2 hours, no real reason to keep counting
		if v.time_entered and os.time() - v.time_entered > 2 * 60^2 then
			spots_restore(k)
		end
		-- grab colours, text display and info helpful to sorting
		local text_colour, bg_colour, current_range, percentage = get_spot_colour(k, v, spt.colours)
		local minutes, seconds, display_time = get_time(k, v)
		spt.spots[k].text_colour = text_colour
		spt.spots[k].bg_colour = bg_colour
		spt.spots[k].current_range = current_range
		spt.spots[k].percentage = percentage
		spt.spots[k].minutes = minutes
		spt.spots[k].seconds = seconds
		spt.spots[k].display_time = display_time
		spt.spots[k].pos = pos
	end
	-- now that we have our colours and diplay times
	-- we can order spots based on our sorting method
	-- and draw them as we iterate through
	local pos = 1
	for k, v in spots_sort(spt.spots, spt.sort_mode[spt.sort_mode.selected]) do
		draw_spot(k, v, spt.colours, dim, pos)
		pos = pos + 1
	end
	WindowShow(win)
end

function spot_timer_tic()
	spots_print(spt.dimensions)
end
--------------------------------------------------------------------------------
--   SORTING ITERATOR
--------------------------------------------------------------------------------
function spots_sort(t, sort_mode)
    local keys = {}
    for k in pairs(t) do table.insert(keys, k) end
    if sort_mode == "static" then
		-- id (integer primary key autoincrement from database)
        table.sort(keys, function(a, b) return t[a].id < t[b].id end)   
    elseif sort_mode == "time" then
		-- display time (false values first so that unvisited remains at top) --> id
		table.sort(keys, function(a, b) 
			if t[a].display_time and t[b].display_time and not (t[a].display_time == t[b].display_time) then
				return t[a].display_time < t[b].display_time
			elseif t[a].display_time or t[b].display_time and not (t[a].display_time == t[b].display_time) then
				return not t[a].display_time and t[b].display_time
			else
				return t[a].id < t[b].id
			end
		end)   
    elseif sort_mode == "colour" then 	
		-- range -> percentage (from min to max with range) --> display time --> id
        table.sort(keys, function(a, b) 
			if t[a].current_range ~= t[b].current_range then
				return t[a].current_range > t[b].current_range
			elseif t[a].percentage ~= t[b].percentage then
				return t[a].percentage > t[b].percentage
			elseif t[a].display_time and t[b].display_time and not (t[a].display_time == t[b].display_time) then
				return t[a].display_time < t[b].display_time
			elseif t[a].display_time or t[b].display_time and not (t[a].display_time == t[b].display_time) then
				return not t[a].display_time and t[b].display_time
			else
				return t[a].id < t[b].id
			end
		end)
	else
		-- alphabetical
        table.sort(keys) 
    end
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end
--------------------------------------------------------------------------------
--   DEBUGGING
--------------------------------------------------------------------------------
function on_alias_spots_table(name, line, wildcards)
	if wildcards.spot ~= "" then
		if spt.spots[wildcards.spot] then
			print(wildcards.spot)
			tprint(spt.spots[wildcards.spot])
		end
	else
		tprint(spt.spots)
	end
end
--------------------------------------------------------------------------------
--   START EXECUTION HERE
--------------------------------------------------------------------------------
print("YOU ARE USING THE WRONG TIMERS, THIS VERSION HAS NOT BEEN FINISHED YET :)")
on_plugin_start()
