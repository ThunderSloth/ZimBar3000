--------------------------------------------------------------------------------
--   MAIN MAP
--------------------------------------------------------------------------------
function voyage_print_map(look_room)
    local start_time = os.clock()
    -- temporarily colour titlebar
    local function highlight_titlebar(coor, colour, text)
        local col = voy.colours
        WindowCircleOp(
        win, miniwin.circle_rectangle, 
        coor.title.bar.x1, coor.title.bar.y1, coor.title.bar.x2, coor.title.bar.y2,
        col.title.border, miniwin.pen_solid, 1,
        colour, 0)
        for i, v in ipairs(coor.title.text) do   
            WindowText(win, "title", voy.title[i], 
                v.x1, v.y1, v.x2, v.y2, 
                col.title.text)
        end
        local x1 = coor.title.text[3].x1
        local y1 = coor.title.text[3].y1
        local x2 = coor.title.text[3].x2
        local y2 = coor.title.text[3].y2
        WindowText(win, "title", voy.part, 
            x1, y1, x2, y2, 
            col.title.text)
        x1 = coor.title.text[5].x1
        y1 = coor.title.text[5].y1
        x2 = coor.title.text[5].x2
        y2 = coor.title.text[5].y2
        WindowText(win, "title", text, 
            x1, y1, x2, y2, 
            col.title.text)
    end
	-- draw titlebar
    local function get_titlebar(coordinates, dim, col)
        local hl = {"lightning", "serpent", "kraken"}
        for _, v in ipairs(hl) do
			if voy[v] then
				local c = col.title[v] or col.thyngs[v]
				local txt = v == "lightning" and "Fire" or v:gsub("^%l", string.upper)
				highlight_titlebar(coordinates, c, txt)
				return
            end
        end
        voyage_draw_title(dim, coordinates, col, win)
        voyage_draw_part(coordinates, col, win)
        voyage_draw_stage(coordinates, col, win)
    end
    -- draw dynamic map elements
    local function draw_main_mode(coordinates, dimensions, col)
        -- colour fading
        local function fade_RGB(colour1, colour2, percentage)
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
        -- draw inner-room fill
        local function draw_thyng(room, coor, colour)
            if room then
                WindowCircleOp(room == 21 and win.."21" or win, 2,
                    coor.room.inner.x1, coor.room.inner.y1, coor.room.inner.x2, coor.room.inner.y2,            
                    colour, 0, 0,
                    colour, 0)
            end
        end
        -- draw room border
        local function draw_border(room, coor, colour, border)
            if room then
                WindowCircleOp(win, 2,
                    coor.room.outter.x1, coor.room.outter.y1, coor.room.outter.x2, coor.room.outter.y2,        
                    colour, 0, border or 1,
                    colour, 1)
            end
        end
        -- draw room number
        local function draw_num(num, room, coor, dim, current_room, col)
            local w = WindowTextWidth(win, "larger", num)
            local x1 = coor.room.outter.x1 + (dim.room.x - w) / 2
            local y1 = coor.room.outter.y1 + (dim.room.y - dim.font.larger) / 2
            WindowText(room == 21 and win.."21" or win, "larger", num,
                x1, y1, 0, 0,
                col, 
                false)
        end
        -- draw inversion to indicate look
        local function draw_look(room, current_room, coor) 
            if room and room ~= current_room then
                WindowRectOp(room == 21 and win.."21" or win, 3, coor.room.outter.x1, coor.room.outter.y1, coor.room.outter.x2, coor.room.outter.y2, 0)
            end
        end
        -- draw overboard room seperatly
        local function draw_overboard_room(current_room, coordinates, col)
            -- erase old image from win.."21"
            WindowRectOp(win.."21", 2, 0, 0, voy.dimensions.window.x, voy.dimensions.window.y, col.window.transparent)
            -- draw 21 seperatly, also invert on look in order to keep waves blue after a second invert 
            voyage_draw_room(21, coordinates.rooms[21], col, win.."21", look_room == 21 and look_room ~= current_room and "invert") 
        end
        -- re-insert pre-drawn overboard room (after 22 has been drawn)
        local function add_overboard_room()
            WindowImageFromWindow(win, "21", win.."21")
            WindowDrawImage(win, "21", 0, 0, 0, 0, 3)   
        end
        -- highlight exit (lightning/monster attack direction)
        local function highlight_direction(room, coordinates, colour, dir)
            local coor = coordinates.rooms[room].directions[dir]
            if coor then
                WindowLine(win, coor.x1, coor.y1, coor.x2, coor.y2, colour, 0, 3)
            end
        end
        -- draw room fire
        local function draw_fire(coordinates, col)
            for i, v in ipairs(voy.fire) do
                draw_border(v.room, coordinates.rooms[v.room], col.rooms.fire, v.size)
            end
        end
        -- draw room ice
        local function draw_ice(coordinates, col)
            for i, v in ipairs(voy.ice) do
                draw_border(v.room, coordinates.rooms[v.room], col.rooms.ice, v.size)
            end   
        end
        -- colour titlebar/exit: lightning strike
        local function draw_lightning(current_room, coordinates, col, dir)
            if dir then
                highlight_direction(current_room, coordinates, col.thyngs.lightning, dir)
                highlight_titlebar(coordinates, col.thyngs.lightning, "Fire")
            end
        end
        -- colour titlebar/exit: serpent attack
        local function draw_serpent(coordinates, col, serpent)
            if serpent then
                highlight_titlebar(coordinates, col.title.serpent, "Serpent")
                if type(serpent) == "table" then
                    draw_border(serpent.room, coordinates.rooms[serpent.room], col.thyngs.serpent, 3)
                    highlight_direction(serpent.room, coordinates, col.thyngs.serpent, serpent.direction)
                end
            end
        end
        -- colour titlebar/exit: kraken attack
         local function draw_kraken(coordinates, col, kraken)
             if kraken then
                highlight_titlebar(coordinates, col.title.kraken, "Kraken")
                if type(kraken) == "table" then
                    draw_border(kraken.room, coordinates.rooms[kraken.room], col.thyngs.kraken, 3)
                    highlight_direction(kraken.room, coordinates, col.thyngs.kraken, kraken.direction)
                end
            end           
        end
        -- draw rope tied from you to railing
        local function draw_rope(start_room, end_room, coor, col)
            if start_room and end_room then
                local condition = voy.rope.condition == 3 and 2 or voy.rope.condition
                local thickness = condition == 0 and 2 or 1
                local x1 = coor[start_room].railing.x1
                local y1 = coor[start_room].railing.y1
                local x2 = coor[end_room].origin.x
                local y2 = coor[end_room].origin.y
                WindowLine(end_room == 21 and win.."21" or win, x1, y1, x2, y2, col.thyngs.rope, condition, thickness) -- rope
                x1 = coor[start_room].cleat.x1
                y1 = coor[start_room].cleat.y1
                x2 = coor[start_room].cleat.x2
                y2 = coor[start_room].cleat.y2
                WindowCircleOp (win, 1, x1, y1, x2, y2, col.thyngs.rope, 0, 2, col.window.background, 0) -- knot
            end
        end
        -- draw rope attached to you
        local function draw_lasso(start_room, end_room, coor, col)
            if start_room and end_room then
                local condition = voy.rope.condition
                local x1 = coor[end_room].lasso.x1
                local y1 = coor[end_room].lasso.y1
                local x2 = coor[end_room].lasso.x2
                for i = -1, 1, 1 do 
                    y = y1 + i
                    WindowLine(end_room == 21 and win.."21" or win, x1, y, x2, y, col.thyngs.rope, -- lasso
                        (condition == 1 and i == 0 and 2) or 
                        (condition == 2 and (i == 1 or i == -1) and 2) or 
                        (condition == 3 and (i == 1 or i == -1) and 5) or 
                        (condition == 3 and (i == 0) and 2) or 0,
                        1)
                end
            end
        end
        -- draw play/dragon text
        local function draw_thyng_text(num, room, current_room, look_room, coor, col)
			-- create style-run
            local function get_styles(num, room, col)
                local comma, styles = false, {}
                table.insert(styles, {text = tostring(num).." ", colour = room == current_room and voy.colours.thyngs.you or voy.colours.thyngs.numbers,})
                for k, v in pairs(voy.rooms[room].players) do
                    if comma then
                        table.insert(styles, {text = ", ", colour = col})
                    end
                    table.insert(styles, {text = v, colour = col})
                    comma = true
                end
                for k, v in pairs(voy.rooms[room].dragons) do
                    if comma then
                        table.insert(styles, {text = ", ", colour = styles[#styles].colour or col})
                    end
                    table.insert(styles, {text = v, colour = look_room == room and AdjustColour(voy.dragons[k], 1) -- inverting on look-room so that when we invert again dragons will have original colours
                        or voy.dragons[k] or col})
                    comma = true
                end
                return styles
            end
            
            local x1 = coor.x1
            local y1 = coor.y1
            for _, v in ipairs(get_styles(num, room, col)) do
                x1 = x1 + WindowText(win, "smaller", v.text,
                    x1, y1, 0, 0,
                    v.colour, 
                    false)
            end
            local x2 = x1 + 1
            x1 = coor.x1 - 1
            local y2 = y1 + voy.dimensions.font.smaller
            if look_room == room then
                WindowRectOp(win, 3, x1, y1, x2, y2, 0)
            end
        end
        -- draw object text
        local function draw_object_text(room, coor, col)
            local order = {
                {"tanks", "rods", "toys", "balls", "polish", "coal", "bottles",},
                {"ropes", "nails", "boards", "hammers", "buckets", "towels", "lemons",},
                {"harpoons", "axes", "arbalests", "bolts", "bandages",},}
            local short = {
                tanks = "tank", rods = "rod", toys = "toy", balls = "ball", polish = "plsh", coal = "coal", bottles = "rum",
                ropes = "rope", nails = "nail", boards = "bord", hammers = "hamr", buckets = "bckt", towels = "towl", lemons = "lemn",
                harpoons = "poon", axes = "axe", arbalests = "rblst", bolts = "bolt", bandages = "band",}
            local obj = voy.rooms[room].objects
            for i, t in ipairs(order) do
                for ii, v in ipairs(t) do
                    local x1 = coor[ii][i].x1
                    local x2 = coor[ii][i].x2
                    local y1 = coor[ii][i].y1
                    local txt = short[v]..":"
                    local n, c = voy.rooms[room].objects[v], 0
                    if n <= 0 then
                        c = col.objects.zero
                        n = ""
                    elseif n > 0 and n <= 20 then
                        c = col.objects.some
                        n = tostring(n)
                    else
                        c = col.objects.some
                        n = "20+"
                    end
                    WindowText(win, "smaller", txt, x1, y1, 0, 0, c, false)
                    WindowText(win, "smaller", n, x2, y1, 0, 0, col.objects.item, false)
                end
            end 
        end
        -- populate map with players/dragons
        local function draw_population(current_room, coordinates, col)
            voyage_draw_circles(coordinates.circle, voy.colours) -- reset dragon 'circles'
            local player_room = 0
            for i, v in ipairs(voy.population) do
                local colour = v.colour
                if colour then
                    player_room = player_room + 1
                    colour = fade_RGB(col.thyngs.players, v.colour, (player_room / voy.population.player_rooms) * 100)
                    if v.room ~= current_room then
                        draw_thyng(v.room, coordinates.rooms[v.room], colour)
                    end
                end
                local counts = {}
                for dragon, _ in pairs(voy.rooms[v.room].dragons) do
                    local coor = coordinates.rooms[v.room].room.dragons[1]
                    local name = string.match(dragon, "^(%w+)")
                    local mw = win
                    local d_colour = voy.dragons[dragon]
                    counts[v.room] = counts[v.room] or {room = 0, circle = 0,} 
                    if voy.dragon[name] and voy.dragon[name].circle and (v.room == 18 or v.room == 20) then
                        counts[v.room].circle = counts[v.room].circle + 1 <= 2 and counts[v.room].circle + 1 or 1
                        coor = coordinates.circle[v.room] and coordinates.circle[v.room][counts[v.room].circle] or coor
                        mw = win.."circles"
                    else
                        if look_room == v.room then
                            d_colour =  AdjustColour(d_colour, 1)
                        end
                        counts[v.room].room = counts[v.room].room + 1 <= 4 and counts[v.room].room + 1 or 1
                        coor = coordinates.rooms[v.room].room.dragons[counts[v.room].room]
                    end
                    WindowCircleOp(mw, 2,
                        coor.x1, coor.y1, coor.x2, coor.y2,            
                        d_colour, 0, 0,
                        d_colour, 0)
                end
                draw_num(i, v.room, coordinates.rooms[v.room], voy.dimensions, current_room,
                    v.room == current_room and col.window.background or 
                    col.thyngs.numbers) 
                draw_thyng_text(i, v.room, current_room, look_room, coordinates.text.thyng[#voy.population][i], colour)
            end
        end
        
        voy.look_room = look_room or false
        local current_room = voy.sequence[1] or false
        local trajectory_room = voy.sequence[#voy.sequence]
        local rope_room = voy.rope.railing
        
        draw_overboard_room(current_room, coordinates, col)
        draw_thyng(current_room, coordinates.rooms[current_room], col.thyngs.you) -- you
        draw_population(current_room, coordinates, col)
        draw_look(look_room, current_room, coordinates.rooms[look_room])
        draw_object_text(look_room or current_room, coordinates.text.object, col)
        draw_fire(coordinates, col)
        draw_ice(coordinates, col)
        draw_lightning(current_room, coordinates, col, voy.lightning)
        draw_serpent(coordinates, col, voy.serpent)
        draw_kraken(coordinates, col, voy.kraken)
        draw_rope(rope_room, current_room, coordinates.rooms, col)
        draw_lasso(rope_room, current_room, coordinates.rooms, col)
        add_overboard_room()
        draw_border(trajectory_room, coordinates.rooms[trajectory_room], col.thyngs.ghost) -- ghost
        
    end
    local function draw_captain_mode(coordinates, dim, col)
		-- clear contents
		local function draw_background(dim, coordinates)
            WindowCircleOp( -- window border
                win.."sea_frame", miniwin.circle_rectangle, 
                0, 0, dim.window.x, dim.window.y,
                col.window.border, miniwin.pen_solid, 1,
                col.window.background, 0)
            WindowCircleOp( -- defining transparency colour
                win.."sea_frame", miniwin.circle_rectangle, 
                0, 0, dim.window.x, coordinates.title.bar.y2,
                col.window.transparent, miniwin.pen_solid, 0,
                col.window.transparent, 0)
        end
        -- draw mini boat in center of map
        local function draw_boat(coor, dim, col, left, top, right, bottom)
			-- draw ice, seaweed and damage on hull
            local function draw_sea_hull(coor, col)
                local percentage, colour = 0, col.hull.defualt
                if voy.hull.seaweed > 0 then
                    percentage = voy.hull.seaweed
                    colour = voyage_fade_RGB(percentage == 0 and col.hull.defualt or col.hull.fade, col.hull.seaweed, percentage)
                elseif voy.hull.ice > 0 then
                    percentage = voy.hull.ice
                    colour = voyage_fade_RGB(percentage == 0 and col.hull.defualt or col.hull.fade, col.hull.ice, percentage)
                end
                if percentage > 0 then
                    WindowLine (win.."sea_room", coor.hull.x1, coor.hull.y1, coor.hull.x3, coor.hull.y3, colour, 0, 2)
                    WindowLine (win.."sea_room", coor.hull.x2, coor.hull.y2, coor.hull.x3, coor.hull.y3, colour, 0, 2)
                end
            end
            -- draw wake behind boat
            local function draw_speed(coor, col)
                local speed = voy.speed
                if speed == 0 then
                    WindowLine(win.."sea_room", coor.rest.x1, coor.rest.y1, coor.rest.x2, coor.rest.y2, col.sea.wake, 0, 1)
                else
                    if speed == 3 then
                        WindowPolygon(win.."sea_room", coor.wake,
                            col.sea.wake, miniwin.pen_null, 0,
                            col.sea.water, miniwin.brush_waves_horizontal,
                            true,  
                            false)
                    elseif speed == 4 then
                        WindowPolygon(win.."sea_room", coor.wake,
                            col.sea.water, miniwin.pen_null, 0,
                            col.sea.wake, miniwin.brush_waves_horizontal,
                            true,  
                            false)
                    end
                    for i = 1, 2 do
                        WindowLine(win.."sea_room", coor.speed[i].x1, coor.speed[i].y1, coor.speed[i].x2, coor.speed[i].y2, col.sea.wake, 0, speed == 1 and 1 or 2)
                    end
                end
            end
            
            local w = dim.sea.block.x + 1
            local h = dim.sea.block.y + 1
            local percentage = voy.hull.condition
            local outline = voyage_fade_RGB(percentage == 0 and col.hull.defualt or col.hull.fade, col.hull.damage, percentage)
            WindowCircleOp(win.."sea_room", 2, -- background water
                0, 0, w, h,            
                col.sea.water, miniwin.pen_null, 0,
                col.sea.water, miniwin.brush_solid)
            WindowCircleOp(win.."sea_room", 2, -- turnwheel
                coor.turnwheel.x1, coor.turnwheel.y1, coor.turnwheel.x2, coor.turnwheel.y2,           
                col.sea.boat[1], miniwin.pen_solid, 1,
                col.sea.boat[1], miniwin.brush_solid)
            WindowPolygon(win.."sea_room", coor.poly, -- boat
                outline, miniwin.pen_solid, 2,
                col.sea.boat[2], miniwin.brush_hatch_horizontal,   
                true,  
                false)
            draw_sea_hull(coor, col)
            x1 = coor.deck.inner.x1
            y1 = coor.deck.inner.y1
            x2 = coor.deck.inner.x2
            y2 = coor.deck.inner.y2
            WindowCircleOp(win.."sea_room", 2, -- you
                x1, y1, x2, y2,           
                col.sea.grid, miniwin.pen_solid, 1,
                col.thyngs.you, miniwin.brush_solid)
            draw_speed(coor, col)
            WindowImageFromWindow(win.."sea_map", "boat", win.."sea_room")
            WindowDrawImage(win.."sea_map", "boat", left, top, right, bottom, 1)
        end
        -- draw sea rooms
        local function draw_sea(coor, dim, col)
            WindowCircleOp( -- window border
                win.."sea_map", miniwin.circle_rectangle, 
                0, 0, dim.window.x, dim.window.y,
                col.window.border, miniwin.pen_solid, 0,
                col.window.transparent, 0)
            for y, v in ipairs(voy.sea) do
                for x = 1, #v do
                local c = v:sub(x,x)
                    coor = voy.coordinates.sea.map[y][x]
                    if y == 3 and x == 3 then
                        draw_boat(voy.coordinates.sea.boat, dim, col, coor.x1, coor.y1, coor.x2, coor.y2)
                    elseif c == "P" and voy.part == 1 then
                        WindowTransformImage (win.."sea_map", c, coor.x2, coor.y2,  miniwin.image_copy,  -1,  0,  0,  -1)
                    else
                        WindowDrawImage(win.."sea_map", c, coor.x1, coor.y1, coor.x2, coor.y2, 1)
                    end
                end 
            end
            for i = 2, 5 do
                local x1 = voy.coordinates.sea.map[1][i].x1
                local x2 = x1
                local y1 = voy.coordinates.sea.map[i][1].y1
                local y2 = y1
                local x_start = voy.coordinates.sea.frame.x1
                local x_end =   voy.coordinates.sea.frame.x2
                local y_start = voy.coordinates.sea.frame.y1
                local y_end =   voy.coordinates.sea.frame.y2
                WindowLine (win.."sea_map", x1, y_start, x2, y_end, col.sea.grid, 0, 3)
                WindowLine (win.."sea_map", x_start, y1, x_end, y2, col.sea.grid, 0, 3)
            end
        end
        -- draw frame with circular "hole" to layer over sea map
        local function draw_frame(coor, col)
            local directions = {'H', 'WH', 'W', 'WR', 'R', 'TR', 'T', 'TH'}
            local count = 0
            while directions[1] ~= voy.heading do
                table.insert(directions, directions[1])
                table.remove(directions, 1)
                count = count + 1
                if count > #directions then break end
            end
            for i = -2, 2, 1 do
                coor = voy.coordinates.direction[i]
                WindowCircleOp(win.."sea_frame", 1, coor.x1, coor.y1, coor.x2, coor.y2,
                     i == voy.direction and col.sea.wheel or col.sea.notch, 0, 2, 
                     col.window.background, 0)
            end
            coor = voy.coordinates.compass
            for i, v in ipairs(directions) do
                local text = v
                local w = WindowTextWidth(win.."sea_frame", "title", text)
                local h = WindowFontInfo(win.."sea_frame", "title", 1)
                local x1 = coor[i].x - w / 2
                local y1 = coor[i].y - h / 2
                WindowText(win.."sea_frame", "title", text, 
                    x1, y1, 0, 0, 
                    col.sea.direction, false)
            end
            coor = voy.coordinates.sea.frame
            WindowCircleOp(win.."sea_frame", 1, coor.x1, coor.y1, coor.x2, coor.y2,
                col.sea.frame, 0, 2, col.window.transparent, 0)
            coor = voy.coordinates.sea.exit
            WindowText(win.."sea_frame", "larger", "x", 
                    coor.x1, coor.y1, 0, 0, 
                    col.sea.x, false)
        end

        draw_background(dim, coordinates)
        draw_sea(coordinates, dim, col)
        draw_frame(coordinates, col)
        
    end
    if not voy.sea then -- main mode
    
        local function add_layer(layer)
            if layer == "main" then
                draw_main_mode(voy.coordinates, voy.dimensions, voy.colours) -- draw dynamic
            elseif  
                layer ~= "kraken"  and layer ~= "serpent" or
                layer == "kraken"  and voy.stage == layer:gsub("^%l", string.upper) or
                layer == "serpent" and voy.stage == layer:gsub("^%l", string.upper) 
            then
                local x1, y1, x2, y2 = 0, 0, 0, 0 
                if layer == "guages" then
                    local coor = voy.coordinates.guages
                    x1, y1, x2, y2 = coor.x1, coor.y1, coor.x2, coor.y2
                end
                WindowImageFromWindow(win, layer, win..layer)
                WindowDrawImage(win, layer, x1, y1, x2, y2, layer == "base" and 1 or 3)         
            end
        end
        
        local layers = {
			"base", 
			"underlay", 
			"main", 
			"guages", 
			"circles", 
			"held", 
			"kraken", 
			"serpent"
		}
        for _, v in ipairs(layers) do
            add_layer(v)
        end
        
    else -- captain mode
        local function add_layer(layer)
            if layer == "sea_map" then
				-- draw sea map
                draw_captain_mode(voy.coordinates, voy.dimensions, voy.colours)
            elseif layer == "sea_frame" then
				-- layer sea frame over sea map and then layer sea map over win
                WindowImageFromWindow(win.."sea_map", "sea_frame", win.."sea_frame")
                WindowDrawImage(win.."sea_map", "sea_frame", 0, 0, 0, 0, 3) 
                WindowImageFromWindow(win, "sea_map", win.."sea_map")
                WindowDrawImage(win, "sea_map", 0, 0, 0, 0, 1)
            else
				-- draw titlebar
				get_titlebar(voy.coordinates, voy.dimensions, voy.colours)
            end
        end
        
        local layers = {
			"sea_map", 
			"sea_frame", 
			"titlebar"
		}
        for _, v in ipairs(layers) do
            add_layer(v)
        end
            
    end
    
    voyage_draw_time()
    voyage_draw_xp()
    
    WindowShow(win, true)
    --print(os.clock() - start_time) -- speed test
end
--------------------------------------------------------------------------------
--   BASE / UNDERLAY
--------------------------------------------------------------------------------
function voyage_draw_base(dim, col)
    local coordinates = voy.coordinates
    WindowCircleOp( -- window border
        win.."base", miniwin.circle_rectangle, 
        0, 0, dim.window.x, dim.window.y,
        col.window.border, miniwin.pen_solid, 1,
        col.window.background, 0) 
    voyage_draw_title(dim, coordinates, col, win.."base")
    local stores = {[19] = "A", [16] = "B", [13] = "C"}
    for room = #coordinates.rooms, 1, -1 do 
        local coor = coordinates.rooms[room]
        voyage_draw_cleats(coor, col, win.."base")
        voyage_draw_room_exits(room, coor, col, win.."base") -- draw exits
        voyage_draw_room_doors(room, coor, col, win.."base") -- draw doors
        voyage_draw_room(room, coor, col, win.."base")       -- draw room
        if stores[room] then
            voyage_draw_room_letter(win.."base", stores[room], coordinates.rooms[room], col.rooms.letter)
        end
    end
    for k, v in pairs(voy.coordinates.held) do
        WindowText (win.."base", "sides", k, -- 'R' and 'L' to indicate held tool
            v.x1, v.y1, 0, 0,
            col.thyngs.you, 
            false)
    end
end

function voyage_draw_underlay(dim, col)
    WindowCircleOp( -- transparent background
        win.."underlay", miniwin.circle_rectangle, 
        0, 0, dim.window.x, dim.window.y,
        col.window.transparent, miniwin.pen_solid, 1,
        col.window.transparent, 0)
    local coor = voy.coordinates
    voyage_draw_part(coor, col, win.."underlay")
    voyage_draw_stage(coor, col, win.."underlay")
    local percentage = voy.hull.condition
    voyage_draw_hull_lower(voy.coordinates, voyage_fade_RGB(percentage == 0 and col.hull.defualt or col.hull.fade, col.hull.damage, percentage), win.."underlay")
    local colour = col.hull.defualt
    if voy.hull.ice > 0 then
        colour = voyage_fade_RGB(col.hull.fade, col.hull.seaweed, voy.hull.ice)
    elseif voy.hull.seaweed > 0 then
        colour = voyage_fade_RGB(col.hull.fade, col.hull.seaweed, voy.hull.seaweed)
    end
    voyage_draw_hull_upper(voy.coordinates, colour, win.."underlay")
end

function voyage_reset_held(dim, col)
	WindowCircleOp( -- clear vertical text on resize
		win.."held", miniwin.circle_rectangle, 
		0, 0, dim.window.x, dim.window.y,
		col.window.transparent, miniwin.pen_solid, 1,
		col.window.transparent, 0)
end
--------------------------------------------------------------------------------
--   ROOMS / EXITS / DOORS
--------------------------------------------------------------------------------
function voyage_draw_room(room, coor, col, mw, is_invert) -- room, coordinates, colours, miniwindow , inversion? (on look)
    local function draw_fill(room, coor, colour, mw, fill_style)
        WindowCircleOp(mw, 2,
            coor.room.outter.x1, coor.room.outter.y1, coor.room.outter.x2, coor.room.outter.y2,            
            colour, 0, 1,
            col.rooms.background, fill_style)
    end
    WindowRectOp(mw, 2, coor.room.outter.x1, coor.room.outter.y1, coor.room.outter.x2, coor.room.outter.y2, col.window.background)
    if room == 3 then
        draw_fill(room, coor, col.rooms.bridge, mw, miniwin.brush_fine_pattern)
    elseif room == 21 then
        draw_fill(room, coor, is_invert and AdjustColour(col.rooms.water, 1) or col.rooms.water, mw, miniwin.brush_waves_horizontal)
    elseif room == 1 then
        WindowCircleOp(mw, miniwin.circle_ellipse, -- steering wheel
            voy.coordinates.wheel.x1, voy.coordinates.wheel.y1, voy.coordinates.wheel.x2, voy.coordinates.wheel.y2,   
            col.rooms.wheel, 0, 2,
            col.rooms.background, miniwin.brush_solid)
    elseif room == 5 or room == 7 then
        WindowDrawImage(mw, "down", coor.room.outter.x1, coor.room.outter.y1, coor.room.outter.x2, coor.room.outter.y2, 1) -- v
    elseif room == 15 or room == 17 then
        WindowDrawImage(mw, "up",   coor.room.outter.x1, coor.room.outter.y1, coor.room.outter.x2, coor.room.outter.y2, 1) -- ^
    end
    WindowRectOp(mw, 1, coor.room.outter.x1, coor.room.outter.y1, coor.room.outter.x2, coor.room.outter.y2, col.rooms.border)
end

function voyage_draw_room_exits(room, coor, col, mw) 
    for dir, v in pairs(voy.rooms[room].exits) do
        WindowLine(
            mw, 
            coor.exit[dir].x1, coor.exit[dir].y1, coor.exit[dir].x2, coor.exit[dir].y2,  
            col.exits.border, miniwin.pen_solid, 1)
    end
end

function voyage_draw_room_doors(room, coor, col, mw) 
    for dir, v in pairs(voy.rooms[room].doors) do
        WindowLine(
            mw, 
            coor.door[dir].x1, coor.door[dir].y1, coor.door[dir].x2, coor.door[dir].y2,  
            col.doors.border, miniwin.pen_dot, 1)
    end
end

function voyage_draw_room_letter(mw, letter, coor, col) 
    WindowText (mw, "larger", letter,
        coor.letter.x1, coor.letter.y1, 0, 0,
        col, 
        false)
end
--------------------------------------------------------------------------------
--   VERTICAL TEXT
--------------------------------------------------------------------------------
function voyage_draw_held(hand)
    local text = (held[hand]:match("(%S+)$")) or ""
    local dim = voy.dimensions.font
    local col = voy.colours
    local width = WindowInfo(win.."hand", 3)
    WindowCircleOp( -- transparent background
        win.."hand", miniwin.circle_rectangle, 
        0, 0, width, WindowInfo(win.."hand", 4),
        col.window.transparent, miniwin.pen_solid, 1,
        col.window.transparent, 0)
    local y1 = 0
    text:gsub("[-!?.'a-z ]", function(l)
        WindowDrawImage(win.."hand", l, 0, y1, 0, 0, miniwin.image_transparent_copy)
        y1 = y1 + dim.rotated[l].y
    end)
    local height = y1
    WindowImageFromWindow(win.."held", "hand", win.."hand")
    local coor = voy.coordinates.held[hand]
    y1 = coor.y2 + dim.sides * .2
    local x1 = coor.text.x1
    if hand == "L" then
        WindowCircleOp( -- transparent background
            win.."held", miniwin.circle_rectangle, 
            x1, 0, x1 + width, voy.dimensions.window.y,
            col.window.transparent, miniwin.pen_solid, 1,
            col.window.transparent, 0)
        WindowTransformImage(win.."held", "hand", x1 + width, y1 + height, miniwin.image_copy,  -1,  0,  0,  -1)
    else
        WindowCircleOp( -- transparent background
            win.."held", miniwin.circle_rectangle, 
            x1, 0, x1 + width, voy.dimensions.window.y,
            col.window.transparent, miniwin.pen_solid, 1,
            col.window.transparent, 0)
        WindowDrawImage(win.."held", "hand", x1, y1, 0, 0, miniwin.image_copy) 
    end
end

function voyage_redraw_held()
    for i, v in ipairs({"R", "L"}) do
        local text = held[v]
        voyage_draw_held(v)
    end
end

function rotate_vertical_font(col)
    voy.dimensions.font.rotated = {}
    local colour = col.objects.held
    local alphabet = "-!?.'abcdefghijklmnopqrstuvwxyz "
    local hv = WindowFontInfo(win.."upright", "vf", 1)
    alphabet:gsub(".", function(l)
        local wv = WindowTextWidth(win.."upright", "vf", l)
        WindowResize(win.."upright", wv, hv, ColourNameToRGB("purple"))
        WindowRectOp(win.."upright", 2, 0, 0, wv, hv, ColourNameToRGB("purple"))
        WindowResize(win.."rotated", hv, wv, ColourNameToRGB("purple"))
        WindowText(win.."upright", "vf", l, 0, 0, wv, hv, colour, false)
        for x = 1, wv do
            for y = 1, hv do
                local pixel = WindowGetPixel(win.."upright", x, hv - y)
                WindowSetPixel(win.."rotated", y, x, pixel)
                WindowImageFromWindow(win.."hand", l, win.."rotated")
                voy.dimensions.font.rotated[l] = {x = hv, y = wv}
            end
        end
    end)
    WindowResize(win.."hand", hv, voy.dimensions.window.y, col.window.transparent)
    voyage_redraw_held()
end
--------------------------------------------------------------------------------
--   COLOR-FADING
--------------------------------------------------------------------------------
function voyage_fade_RGB(colour1, colour2, percentage)
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
--   BOAT ELEMENTS
--------------------------------------------------------------------------------
function voyage_draw_hull(coor, colour, mw)
    WindowBezier (mw, coor, 
      colour, miniwin.pen_solid, 2)
end

function voyage_draw_hull_upper(coor, colour, mw)
    voyage_draw_hull(coor.hull[2], colour, mw)
    voyage_draw_hull(coor.hull[4], colour, mw)
end

function voyage_draw_hull_lower(coor, colour, mw)
    voyage_draw_hull(coor.hull[12], colour, mw)
    voyage_draw_hull(coor.hull[14], colour, mw)
end

function voyage_draw_cleats(coor, col, mw) -- locations where ropes are tied
    if coor.cleat then
        WindowCircleOp(mw, 1, coor.cleat.x1, coor.cleat.y1, coor.cleat.x2, coor.cleat.y2, col.thyngs.cleat, 0, 2, col.window.background, 0)
    end
end
--------------------------------------------------------------------------------
--   TITLEBAR
--------------------------------------------------------------------------------
function voyage_draw_title(dim, coor, col, mw)
    WindowCircleOp(
    mw, miniwin.circle_rectangle, 
    coor.title.bar.x1, coor.title.bar.y1, coor.title.bar.x2, coor.title.bar.y2,
    col.title.border, miniwin.pen_solid, 1,
    col.title.fill, 0)
    for i, v in ipairs(coor.title.text) do   
        WindowText(mw, "title", voy.title[i], 
            v.x1, v.y1, v.x2, v.y2, 
            col.title.text)
    end
end

function voyage_draw_part(coor, col, mw)
    local x1 = coor.title.text[3].x1
    local y1 = coor.title.text[3].y1
    local x2 = coor.title.text[3].x2
    local y2 = coor.title.text[3].y2
    WindowRectOp(mw, 2, x1, y1 + 2, x2, y2, col.title.fill)
    WindowText(mw, "title", voy.part, 
        x1, y1, x2, y2, 
        col.title.text)
end

function voyage_draw_stage(coor, col, mw)
    if voy.stage == "Serpent" and not voy.sea then
		voyage_get_hotspot_monster(coor, "serpent")
    else
        WindowDeleteHotspot(win, "serpent")
    end
    if voy.stage == "Kraken" and not voy.sea then
		voyage_get_hotspot_monster(coor, "kraken")
    else
        WindowDeleteHotspot (win, "kraken")
    end
    local x1 = coor.title.text[5].x1
    local y1 = coor.title.text[5].y1
    local x2 = coor.title.text[5].x2
    local y2 = coor.title.text[5].y2
    WindowRectOp(mw, 2, x1, y1 + 2, x2, y2, col.title.fill)
    WindowText(mw, "title", voy.stage, 
        x1, y1, x2, y2, 
        col.title.text)
end
--------------------------------------------------------------------------------
--   XP / TIME
--------------------------------------------------------------------------------
function voyage_draw_time()
    local function get_time()
        local t = (os.time() - xp_t[0].time)
        return string.format("%.2d:%.2d", t/60%60, t%60)
    end
    local col = voy.colours
    local coor = voy.coordinates.text.object[7][3]
    WindowCircleOp( -- erase current time
        win, miniwin.circle_rectangle, 
        coor.x1, coor.y1, coor.x2, coor.y2,
        col.window.background, miniwin.pen_solid, 2,
        col.window.background, 0)
    WindowText(win, "smaller", get_time(),
        coor.x1, coor.y1, coor.x2, coor.y2,
        col.thyngs.you, 
        false)
end

function voyage_draw_xp()
    if voy.is_in_voyage then
        local function round(num, n)
            local mult = 10^(n or 0)
            return math.floor(num * mult + 0.5) / mult
        end
        local function get_rate()
            local delta_xp = (xp_t.current_xp and xp_t[0].xp and xp_t.current_xp - xp_t[0].xp) or 0 
            local delta_t = (os.time() - xp_t[0].time)
            local rate = delta_t == 0 and 0 or (delta_xp * 60^2) / (delta_t * 1000)
            return tostring(string.format("%.2f", round(rate, 1))).."k"
        end
        local col = voy.colours
        local coor = voy.coordinates.text.object[6][3]
        WindowCircleOp( -- erase current rate
            win, miniwin.circle_rectangle, 
            coor.x1, coor.y1, voy.dimensions.window.x-1, coor.y2,
            col.window.background, miniwin.pen_solid, 2,
            col.window.background, 0)
        WindowText(win, "smaller", get_rate(),
            coor.x1, coor.y1, voy.dimensions.window.x-1, coor.y2,
            col.thyngs.numbers, 
            false)
    end
end
--------------------------------------------------------------------------------
--   DRAGON CIRCLES / GUAGES
--------------------------------------------------------------------------------
function voyage_draw_circles(coor, col)
    WindowCircleOp( -- transparent background
        win.."circles", miniwin.circle_rectangle, 
        0, 0, voy.dimensions.window.x, voy.dimensions.window.y,
        col.window.transparent, miniwin.pen_solid, 1,
        col.window.transparent, 0)
    for k, v in pairs(coor) do
        WindowCircleOp(win.."circles", 2,
            v.outter.x1, v.outter.y1, v.outter.x2, v.outter.y2,           
            col.dragons.circle, 0, 1,
            col.window.background, 0)
    end
end

function voyage_draw_guages(dim, col)
    local coor = voy.coordinates.guage
    WindowCircleOp( 
        win.."guages", miniwin.circle_rectangle, 
        0, 0, dim.window.x, dim.window.y,
        col.window.transparent, miniwin.pen_solid, 1,
        col.window.transparent, 0)
    for k, v in pairs(voy.dragon) do
        local i = v.guage
        local hunger = dim.guage.guage.y * ((100 - v.hunger) / 100)
        local boredom = dim.guage.guage.y * ((100 - v.boredom) / 100)
        local fill_style = v.asleep and 8 or 0
        local border_colour = v.asleep and col.dragons.asleep or col.window.border
        WindowCircleOp( -- fill: hunger
            win.."guages", miniwin.circle_rectangle, 
            coor[i].x1, coor[i].y2, coor[i].x2, coor[i].y2 - hunger,
            col.dragons.asleep, miniwin.pen_null, 0,
            col.dragons[k], fill_style)
        WindowCircleOp( -- fill: boredom
            win.."guages", miniwin.circle_rectangle, 
            coor[i].x1, coor[i].y2, coor[i].x2, coor[i].y2 + boredom,
            col.dragons.asleep, miniwin.pen_null, 0,
            col.dragons[k], fill_style)
        WindowCircleOp( -- outline: hunger
            win.."guages", miniwin.circle_rectangle, 
            coor[i].x1, coor[i].y1, coor[i].x2, coor[i].y2,
            border_colour, miniwin.pen_solid, 1,
            col.window.transparent, 1)
        WindowCircleOp( -- outline: boredom
            win.."guages", miniwin.circle_rectangle, 
            coor[i].x1, coor[i].y2, coor[i].x2, coor[i].y3,
            border_colour, miniwin.pen_solid, 1,
            col.window.transparent, 1)
    end
end
--------------------------------------------------------------------------------
--   MONSTERS
--------------------------------------------------------------------------------
function voyage_draw_serpent(coor, col)
    local function darker(colour, p)
        for i = 1, p do
            colour = AdjustColour(colour, 3)
        end
        return colour
    end
    local dim = voy.dimensions
    WindowCircleOp( 
        win.."serpent", miniwin.circle_rectangle, 
        0, 0, dim.window.x, dim.window.y,
        col.window.transparent, miniwin.pen_solid, 1,
        col.window.transparent, 0)
    local border = 2
    local min = border
    local max = #coor.coils - border + 1
    local fill_h = #coor.coils - border * 2
    local colour = col.thyngs.serpent
    for i, t in ipairs(voy.coordinates.serpent.coils) do
        if i > min and i < max then
            for _, v in ipairs(t) do
                local percentage = (i / (fill_h * 3)) * 100
                WindowBezier (win.."serpent", v, 
                    voyage_fade_RGB(colour, col.window.background, percentage), miniwin.pen_solid, 1)
                
            end
        end
    end
    for i, t in ipairs(voy.coordinates.serpent.coils) do
        if i <= min or i >= max then
            for _, v in ipairs(t) do
                WindowBezier (win.."serpent", v, 
                    darker(col.thyngs.serpent, 0), miniwin.pen_solid, 1)
            end
        end
    end
    WindowCircleOp( 
        win.."serpent", miniwin.circle_rectangle, 
        coor.head.x1, coor.head.y1, coor.head.x2, coor.head.y2,
        col.thyngs.serpent, miniwin.pen_solid, 2,
        darker(col.thyngs.serpent, 12), 0)
    WindowImageFromWindow(win, "serpent", win.."serpent")
end

function voyage_draw_kraken(coor, col)
    local function darker(colour, p)
        for i = 1, p do
            colour = AdjustColour(colour, 3)
        end
        return colour
    end
    local dim = voy.dimensions
    WindowCircleOp( 
        win.."kraken", miniwin.circle_rectangle, 
        0, 0, dim.window.x, dim.window.y,
        col.window.transparent, miniwin.pen_solid, 1,
        col.window.transparent, 0)
    local colours = {}
    for i, v in ipairs(coor.tentacles) do
        table.insert(colours, colours[i - 1] and darker(colours[i - 1], 6) or darker(col.thyngs.kraken, 6))
    end
    for i = #coor.tentacles, 1, -1 do
        for _, v in pairs(coor.tentacles[i]) do
            local pen = 2
            for _2, seg in ipairs(v) do
                WindowBezier (win.."kraken", seg, 
                  colours[i], miniwin.pen_solid, pen)
            end
        end
    end
    WindowCircleOp( 
        win.."kraken", miniwin.circle_rectangle, 
        coor.head.x1, coor.head.y1, coor.head.x2, coor.head.y2,
        col.thyngs.kraken, miniwin.pen_solid, 2,
        darker(col.thyngs.kraken, 12), 0)
    WindowImageFromWindow(win, "kraken", win.."kraken")
end
