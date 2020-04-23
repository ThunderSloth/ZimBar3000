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
	spots_get_spot_data()
	window_pos_x, window_pos_y = tonumber(GetVariable("window_pos_x")), tonumber(GetVariable("window_pos_y"))
	spots_get_colours()

end

function OnPluginSaveState () -- save variables
	var.spt= "spt = "..serialize.save_simple(spt)
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
function spots_get_spot_data()
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
	spt.sort_mode = {"static", "number", "colour", selected = spt.sort_mode or "colour"}
	spt.title = spt.title or "Spots"
	spt.current_spot = {} -- use table so we can easily handle boss+medina, cap+smugs
	spt.current_xp = false
	spt.need_final_xp = {}
end

-- initial setting, identical to never visited
function restore_spot(spot)
	spt.spots[spot].kill_count   = 0
	for _, v in ipairs({"time_entered", "time_exited", "time_killed", "initial_xp", "final_xp", "is_down ", "is_big_spawn"}) do
		spt.spots[spot][v] = false
	end
end

function restore_all_spots()
	for k in pairs(spt.spots) do
		restore_spot(k)
	end
end

-- mimic killing a spot (scry somebody killing spot, arrive to empty spot as another group is leaving ect.)
function reset_spot(spot)
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
		window_pos_x = WindowInfo(win, 10)
		window_pos_y = WindowInfo(win, 11)
		WindowPosition(win, window_pos_x, window_pos_y, 0, 2)
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
        for k in pairs(spt.current_spot) do
			is_in_spot = true; break
        end
        if is_in_spot and not spt.current_spot[spot_name] then
			spots_leave_spot(spt.current_spot)
        end
        if spot_name and not spt.current_spot[spot_name] then
			spots_enter_spot(spot_name)
		end
    end
end
--------------------------------------------------------------------------------
--   ENTER / EXIT HANDLING
--------------------------------------------------------------------------------
function spots_enter_spot(spot_name)
	spt.current_spot[spot_name] = true
	spt.spots[spot_name].time_exited = false
	spt.need_final_xp[spot_name] = nil
	-- don't reset if last exited was within 2 minutes
	-- (reshielding crocs, giants toss etc.)
	if not (spt.spots[spot_name].time_entered and os.time() - spt.spots[spot_name].time_entered <= 120 )then
		spt.spots[spot_name].time_entered = os.time()
		spt.spots[spot_name].kill_count = 0
		spt.spots[spot_name].initial_xp = spt.current_xp
		spt.spots[spot_name].final_xp = spt.current_xp
	end
end

function spots_leave_spot(spot)
	local function leave_spot(spot_name)
		spt.current_spot[spot_name] = nil
		spt.spots[spot_name].time_exited = os.time()
		spt.spots[spot_name].final_xp = spt.current_xp
		spt.need_final_xp[spot_name] = true
		if spt.spots[spot_name].kill_count >= spt.spots[spot_name].kill_reset then
			spt.spots[spot_name].time_killed = os.time()
			spt.spots[spot_name].is_down = false
			if spt.spots[spot_name].kill_count >= spt.spots[spot_name].kill_high then
				spt.spots[spot_name].big_spawn = true
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
			if spt.spots[k].kill_count >= spt.spots[k].kill_reset then
				spt.spots[k].time_killed = os.time()
				spt.spots[k].is_down = false
				if spt.spots[k].kill_count >= spt.spots[k].kill_high then
					spt.spots[k].big_spawn = true
				end
			end
		end
	end
end

function on_trigger_spots_bury(name, line, wildcards, styles)
	if spt.current_spot.shades then
	
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
	spots_refresh_spots(dim)
	WindowShow(win)
end

function spots_draw_spot(spot_name, v, col, dim, mw)
	local function get_spot_colour(v, col, is_spot) 
		local text_colour = col.spot_text_unvisited
		local bg_colour = col.window_background
		if is_spot and v.time_killed then
			text_colour = col.spot_text
			local last_killed = (os.time() - v.time_killed) / 60
			for i = 1, 5 do
				if v.range[i] > last_killed then
					bg_colour = col.time_range[i]
					break
				end
			end
		elseif v.time_entered then
			text_colour = col.spot_text
			local last_entered = (os.time() - v.time_entered) / 60
			for i = 1, 5 do
				if v.range[i] > last_entered then
					if i == 5 then
						bg_colour = col.time_range[i]
					else
						bg_colour = spots_fade_RGB(col.time_range[i], col.time_range[i + 1], .5)
					end
					break
				end
			end		
		end
		--print(text_colour, bg_colour)
		return text_colour, bg_colour
	end
	local function draw_name(spot_name, v, col, dim, mw)
		local display_name = spot_name -- to make it easy to add support for customizable names later on (long names, abbrv.)
		local text_colour, bg_colour = get_spot_colour(v, col, true)
		WindowCircleOp(mw, 2, 0, 0, dim.spot.x, dim.spot.y, bg_colour, 0, 1, bg_colour, 0)
		local w = WindowTextWidth(mw, "spot_text",  display_name)
		local x1 = (dim.spot.x - w) / 2
		local min = 1; if x1 < min then x1 = min end
		WindowText(mw, "spot_text", display_name, x1, 0, 0, 0, text_colour)
	end
	local function draw_time(spot_name, v, col, dim, mw)
		local function get_time(start_time, end_time)
			if start_time then
				local minutes, seconds = 0, 0
				if not(end_time) then end_time = os.time() end
				minutes = math.floor((end_time-start_time)/60)
				seconds = (end_time-start_time)-(minutes*60)
				if seconds < 10 then
					seconds = "0"..tostring(seconds)
				end
				return tostring(minutes), tostring(seconds)
			else
				return false, false
			end
		end
		local minutes, seconds = get_time(v.time_exited)
		local text_colour, bg_colour = get_spot_colour(v, col, false)
		local coor = spt.coordinates.time
		WindowCircleOp(mw, 2, coor.x1, coor.y1, coor.x2, coor.y2, bg_colour, 0, 1, bg_colour, 0)
		coor = spt.coordinates.colon
		WindowText(mw, "spot_time", ":", coor.x1, 0, 0, 0, text_colour)
		if minutes and seconds then
			local w = WindowTextWidth(mw, "spot_time", minutes)
			WindowText(mw, "spot_time", minutes, coor.x1 - w - dim.line_buffer.x, 0, 0, 0, text_colour)
			WindowText(mw, "spot_time", seconds, coor.x2 + dim.line_buffer.x, 0, 0, 0, text_colour)
		end
	end
	local mw = win..spot_name
	WindowCircleOp(mw, 2, 0, 0, dim.spot_line.x, dim.spot_line.y, col.window_background, 0, 1, col.window_background, 0)
	draw_time(spot_name, v, col, dim, mw)
	draw_name(spot_name, v, col, dim, mw)
	WindowImageFromWindow(win, spot_name, mw)
	local coor = spt.coordinates.spot_line[v.id]
    WindowDrawImage(win, spot_name, coor.x1, coor.y1, 0, 0, 1)	
end

function spots_refresh_spots(dim)
	for k, v in pairs(spt.spots) do
		spots_draw_spot(k, v, spt.colours, dim)
	end
end

function spot_timer_tic()
	spots_refresh_spots(spt.dimensions)
end
--------------------------------------------------------------------------------
--   START EXECUTION HERE
--------------------------------------------------------------------------------

on_plugin_start()
tprint(spt.colours)
