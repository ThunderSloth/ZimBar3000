--------------------------------------------------------------------------------
--   CREATE WINDOWS
--------------------------------------------------------------------------------
function voyage_get_windows(col) -- colours 
    WindowCreate(win,              0, 0, 0, 0, miniwin.pos_center_all, 0, col.window.transparent) -- display window: only dynamic objects will be printed directly here   
    WindowCreate(win.."copy_from", 0, 0, 0, 0, miniwin.pos_center_all, 0, col.window.transparent) -- for loading images
    WindowCreate(win.."base",      0, 0, 0, 0, miniwin.pos_center_all, 0, col.window.transparent) -- base: room structure, static objects and bmp images
    WindowCreate(win.."underlay",  0, 0, 0, 0, miniwin.pos_center_all, 0, col.window.transparent) -- underlay: hull
    WindowCreate(win.."guages",    0, 0, 0, 0, miniwin.pos_center_all, 0, col.window.transparent) -- dragon hunger/boredom levels
    WindowCreate(win.."circles",   0, 0, 0, 0, miniwin.pos_center_all, 0, col.window.transparent) -- dragon 'circles'
    WindowCreate(win.."21",        0, 0, 0, 0, miniwin.pos_center_all, 0, col.window.transparent) -- surface-level overboard room (21); we must draw image seperatly so that it does not get overlapped by under-water room (22)
    WindowCreate(win.."hand",      0, 0, 0, 0, miniwin.pos_center_all, 0, col.window.transparent) -- vertical text (construction)
    WindowCreate(win.."held",      0, 0, 0, 0, miniwin.pos_center_all, 0, col.window.transparent) -- vertical text
    WindowCreate(win.."kraken",    0, 0, 0, 0, miniwin.pos_center_all, 0, col.window.transparent) -- kraken
    WindowCreate(win.."serpent",   0, 0, 0, 0, miniwin.pos_center_all, 0, col.window.transparent) -- serpent
    WindowCreate(win.."help",      0, 0, 0, 0, miniwin.pos_center_all, 0, col.window.transparent) -- help (unused)
    WindowCreate(win.."sea_frame", 0, 0, 0, 0, miniwin.pos_center_all, 0, col.window.transparent) -- sea map frame
    WindowCreate(win.."sea_map",   0, 0, 0, 0, miniwin.pos_center_all, 0, col.window.transparent) -- sea map
    WindowCreate(win.."sea_room",  0, 0, 0, 0, miniwin.pos_center_all, 0, col.window.background ) -- sea map room (individual room construction)
    WindowSetZOrder(win, 205)
end
--------------------------------------------------------------------------------
--   WINDOW SETUP
--------------------------------------------------------------------------------
function voyage_window_setup(window_width, window_height, colours)
    local start_time = os.clock()
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	--   DIMENSIONS
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- set dimensions based off window size
    local function get_window_dimensions(window_width, window_height) 
        voy.dimensions = {}
        voy.dimensions.window = {
            x = window_width, 
            y = window_height}
        voy.dimensions.buffer = {
            x = window_width  * .03, 
            y = window_height * .03}
        voy.dimensions.map = {
            x = window_width  - voy.dimensions.buffer.x * 2, 
            y = window_height - voy.dimensions.buffer.y * 2}
        voy.dimensions.sea = {
            x = voy.dimensions.map.x * .85, 
            y = voy.dimensions.map.y * .85}
        voy.dimensions.sea.block = {
            x = voy.dimensions.sea.x / 5, 
            y = voy.dimensions.sea.y / 5}
        voy.dimensions.block = {
            x = voy.dimensions.map.x/6, 
            y = voy.dimensions.map.y/6}
        voy.dimensions.room = {
            x = voy.dimensions.block.x * .6, 
            y = voy.dimensions.block.y * .6}
        voy.dimensions.thyng = {
            x = voy.dimensions.room.x * .73, 
            y = voy.dimensions.room.y * .73}
        voy.dimensions.dragon = {
            x = voy.dimensions.thyng.x * .9 / 2, 
            y = voy.dimensions.thyng.y * .9 / 2}
        voy.dimensions.circle = {
            x = voy.dimensions.room.x *.85 / 2, 
            y = voy.dimensions.room.y * .85}
        voy.dimensions.shift = {
            x = 0, 
            y = window_height * 0}
        voy.dimensions.hull = {
            x = voy.dimensions.room.x * .5, 
            y = voy.dimensions.room.y * .5}
        voy.dimensions.wheel = {
            x = voy.dimensions.room.x * .5, 
            y = voy.dimensions.room.y * .5}
        voy.dimensions.exit = {
            x = (voy.dimensions.block.x - voy.dimensions.room.x) / 2, 
            y = (voy.dimensions.block.y - voy.dimensions.room.y) / 2}
        voy.dimensions.cleat = voy.dimensions.room.x * .14
        voy.dimensions.guage = {}
        voy.dimensions.guage.box = {
            x = (voy.dimensions.block.x *  .82),
            y = (voy.dimensions.block.y * 1.5)}
        voy.dimensions.guage.buffer = {
            x = voy.dimensions.guage.box.y * .05,
            y = voy.dimensions.guage.box.y * .05}
        voy.dimensions.guage.group = {
            x = voy.dimensions.guage.box.x - voy.dimensions.guage.buffer.x * 2,
            y = voy.dimensions.guage.box.y - voy.dimensions.guage.buffer.y * 2}
        voy.dimensions.guage.block = {
            x = voy.dimensions.guage.group.x / 2,
            y = voy.dimensions.guage.group.y / 2}
        voy.dimensions.guage.guage = {
            x = voy.dimensions.guage.block.x - (voy.dimensions.buffer.x / 2),
            y = voy.dimensions.guage.block.y}
        voy.dimensions.text = {}
        voy.dimensions.text.buffer = {
            x = voy.dimensions.buffer.x + (voy.dimensions.block.x / 2) - (voy.dimensions.room.x / 2)
        }
        voy.dimensions.text.thyngs = {
            x = ((voy.dimensions.window.x - voy.dimensions.text.buffer.x * 2) / 2) + (voy.dimensions.block.x - voy.dimensions.room.x) / 2
        }
        voy.dimensions.text.objects = {
            x = ((voy.dimensions.window.x - voy.dimensions.text.buffer.x * 2) - voy.dimensions.text.thyngs.x) / 3
        }
        voy.dimensions.text.held = {
            x = voy.dimensions.buffer.x + (voy.dimensions.block.x - voy.dimensions.room.x) / 2,
        }
        return voy.dimensions
    end
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	--   COORDINATES
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- predetermine the coordinates of everything that will be drawn
    local function get_coordinates(dim) --dimensions
        local function give_direction(exit)
            if exit == "n" then return 0, 1 end
            if exit == "ne" then return 1, 1 end
            if exit == "e" then return 1, 0 end
            if exit == "se" then return 1, -1 end
            if exit == "s" then return 0, -1 end
            if exit == "sw" then return -1, -1 end
            if exit == "w" then return -1, 0 end
            if exit == "nw" then return -1, 1 end
        end
		-- convert table containing coordinates into string form
        local function get_poly_format(t)
            local function round(n)
                return n % 1 >= 0.5 and math.ceil(n) or math.floor(n)
            end
            s = ""
            for _, v in ipairs(t) do
                if s ~= "" then
                    s = s..","
                end
                s = s..tostring(round(v))
            end
            return s
        end

        local function get_title_coordinates(dim) -- dimensions
            voy.coordinates.title.bar = {x1 = 0, y1 = 0, x2 = dim.window.x, y2 = dim.title[1].y * 1.1}
            voy.coordinates.title.text = {}
            local x1 = (dim.window.x - dim.title.width) / 2
            local y1 = (voy.coordinates.title.bar.y2 - dim.title[1].y) / 2
            local y2 = y1 + dim.title[1].y
            for i, v in ipairs(dim.title) do
                local x2 = x1 + v.x
                voy.coordinates.title.text[i] = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
                x1 = x2
            end
        end

        local function get_exit_coordinates(dim, k, v, origin) -- dimensions, room, room values, center
            voy.coordinates.rooms[k].directions = {}
            local directions = {"n", "ne", "e", "se", "s", "sw", "w", "nw",} 
            for _, dir in pairs(directions) do
                local x_dir, y_dir = give_direction(dir) 
                local x1 = origin.x + dim.room.x/2  *  x_dir
                local y1 = origin.y + dim.room.y/2  * -y_dir
                local x2 = origin.x + (dim.block.x+1)/2 *  x_dir
                local y2 = origin.y + (dim.block.y+1)/2 * -y_dir
                voy.coordinates.rooms[k].directions[dir] = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
            end
            voy.coordinates.rooms[k].exit = {}
            for dir, rm in pairs(v.exits) do
                local x_dir, y_dir = give_direction(dir) 
                local x1 = origin.x + dim.room.x/2  *  x_dir
                local y1 = origin.y + dim.room.y/2  * -y_dir
                local x2 = origin.x + (dim.block.x+1)/2 *  x_dir
                local y2 = origin.y + (dim.block.y+1)/2 * -y_dir
                if not(rm) then
                    local m = (y2-y1)/(x2-x1)
                    local b = y1 - m * x1
                    x2 = 0
                    y2 = b
                end
                voy.coordinates.rooms[k].exit[dir] = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
            end
            voy.coordinates.rooms[k].door = {}
            for dir, rm in pairs(v.doors) do
                local x_dir, y_dir = give_direction(dir) 
                local x1 = origin.x + dim.room.x/2  *  x_dir
                local y1 = origin.y + dim.room.y/2  * -y_dir
                local x2 = origin.x + (dim.block.x+1)/2 *  x_dir
                local y2 = origin.y + (dim.block.y+1)/2 * -y_dir
                if not(rm) then
                    local m = (y2-y1)/(x2-x1)
                    local b = y1 - m * x1
                    x2 = 0
                    y2 = b
                end
                voy.coordinates.rooms[k].door[dir] = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
            end
        end

        local function get_letter_coordinates(dim, i, origin) -- dimesnions, room, center
            local l = i == 19 and "A" or i == 16 and "B" or i == 13 and "C" or false
            if l then
                local width = WindowTextWidth(win, "larger", l)
                local x1 = origin.x - (dim.room.x / 2) + (dim.room.x - width) / 2
                local y1 = origin.y - (dim.room.y / 2) + (dim.room.y - dim.font.larger) / 2
                local x2, y2 = 0, 0
                voy.coordinates.rooms[i].letter = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
            end
        end

        local function get_text_coordinates(dim, coor) -- dimensions, coordinates
            voy.coordinates.text = {thyng = {}, object = {},}
            local x_thyng = dim.text.buffer.x
            local top = coor.rooms[8].room.outter.y2 
            local height = dim.window.x - top
            local x_object = dim.text.buffer.x + dim.text.thyngs.x
            for i = 1, 30, 1 do
                voy.coordinates.text.thyng[i] = {}
                for ii = 1, i, 1 do
                    local y1 = top + (height / (i + 1) * ii) - (dim.font.smaller / 2)
                    local y2 = y1 + dim.font.smaller
                    voy.coordinates.text.thyng[i][ii] = {x1 = x_thyng, y1 = y1}
                    if i == 7 then
                        local x1 = x_object
                        for iii, v in ipairs({[1] = "plsh: ", [2] = "hamr: ", [3] = "poon: "}) do
                            local x2 = x1 + WindowTextWidth(win, "smaller", v) * .90
                            voy.coordinates.text.object[ii] = voy.coordinates.text.object[ii] or {}
                            voy.coordinates.text.object[ii][iii] = {x1 = x1, x2 = x2, y1 = y1, y2 = y2}
                            x1 = x2 + WindowTextWidth(win, "smaller", "20+") * 1.1
                        end 
                    end
                end
            end
        end

        local function get_guage_coordinates(dim, coor) -- dimensions, coordinates
            local x1 = 0
            local y1 = 0
            local x2 = dim.window.x
            local y2 = dim.guage.box.y + coor.title.bar.y2
            voy.coordinates.guages = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
            voy.coordinates.guage = {}
            y1 = coor.title.bar.y2 + dim.guage.buffer.y
            y2 = y1 + dim.guage.guage.y
            y3 = y2 + dim.guage.guage.y
            local count = 0
            for i = 1, -1, -2 do
                for ii = 0, 1, 1 do
                    count = count + 1
                    x1 = (ii * (dim.guage.block.x - dim.guage.buffer.x / 2) + dim.guage.buffer.x) * i
                    if x1 < 0 then
                        x1 = dim.window.x + x1
                    end
                    x2 = x1 + dim.guage.guage.x * i
                    local function order(x1, x2)
                        if x1 > x2 then
                            return x2, x1
                        else
                            return x1, x2
                        end
                    end
                    x1, x2 = order(x1, x2) -- because hotspots won't draw backwards
                    voy.coordinates.guage[count] = {x1 = x1, y1 = y1 , x2 = x2, y2 = y2, y3 = y3}
                end
            end
        end

        local function get_circle_coordinates(dim, i, origin, side) -- dimensions, room, center, right or left
            voy.coordinates.circle = voy.coordinates.circle or {}
            local center = {
                x = origin.x + (dim.room.x / 2) * side,
                y = origin.y,}
            local x1 = center.x - (dim.circle.x / 2)
            local x2 = center.x + (dim.circle.x / 2)
            local y1 = center.y - (dim.circle.y / 2)
            local y2 = center.y + (dim.circle.y / 2)
            voy.coordinates.circle[i] = {}
            voy.coordinates.circle[i].outter = {x1 = x1 - 1, y1 = y1 - 1, x2 = x2 + 1, y2 = y2 + 1}
            voy.coordinates.circle[i].inner =  {x1 = x1 + 1, y1 = y1 + 1, x2 = x2 - 1, y2 = y2 - 1}
            x1 = x1 + (dim.thyng.x - dim.dragon.x) / 6
            y1 = (dim.thyng.y - 2 * dim.dragon.y) / 6
            x2 = x1 + dim.dragon.x
            y2 = y1 + dim.dragon.y
            voy.coordinates.circle[i][1] = {x1 = x1, y1 = y1 , x2 = x2, y2 = y2}
            local spots = {1, -1}
            for n, v in ipairs(spots) do
                x1 = center.x - (dim.dragon.x / 2)
                x2 = center.x + (dim.dragon.x / 2)
                y1 = center.y - ((dim.thyng.y - 2 * dim.dragon.y) / 6) * v
                y2 = center.y - (dim.dragon.y + (dim.thyng.y - 2 * dim.dragon.y) / 6) * v
                voy.coordinates.circle[i][n] = {x1 = x1, y1 = y1 , x2 = x2, y2 = y2}
            end
        end
        
        local function get_dragon_coordinates(dim, i, origin) -- dimensions, room, center
            voy.coordinates.rooms[i].room.dragons = {}
            local x1 = (dim.thyng.x - 2 * dim.dragon.x) / 6
            local y1 = (dim.thyng.y - 2 * dim.dragon.y) / 6
            local x2 = x1 + dim.dragon.x
            local y2 = y1 + dim.dragon.y
            local quadrants = {{1, 1}, {1, -1}, {-1, -1}, {-1, 1},}
            for _, v in ipairs(quadrants) do
                table.insert(voy.coordinates.rooms[i].room.dragons, {x1 = origin.x + x1 * v[1], y1 = origin.y + y1 * -v[2], x2 = origin.x + x2 * v[1], y2 = origin.y + y2 * -v[2],})
            end
        end
            
        local function get_hull_coordinates(dim, i, origin) -- dimensions, room, center
            local hull = {[2] = "ne", [4] = "nw", [12] = "ne", [14] = "nw",}
            if hull[i] then -- hull curves
                voy.coordinates.hull = voy.coordinates.hull or {}
                local curve = {}
                local x_dir, y_dir = give_direction(hull[i]) 
                table.insert(curve, origin.x)
                table.insert(curve, origin.y - (dim.room.y / 2) - 2)
                table.insert(curve, curve[1])
                table.insert(curve, curve[2] - dim.block.y + dim.room.y)
                table.insert(curve, curve[3] + (dim.block.x / 2) * x_dir)
                table.insert(curve, curve[4] - dim.room.y)
                table.insert(curve, curve[5] + (dim.block.x / 2) * x_dir)
                table.insert(curve, curve[6] - dim.hull.y)            
                voy.coordinates.hull[i] = get_poly_format(curve)
            end
        end

        local function get_railing_coordinates(dim, i, origin) -- dimensions, room, center
           local railing = {[1] = "n", [2] = "w", [5] = "w", [8] = "w", [10] = "e", [7] = "e", [4] = "e"}
            if railing[i] then
                local x_dir, y_dir = give_direction(railing[i])
                local x1 = origin.x + (dim.room.x / 2) * x_dir
                local y1 = origin.y + (dim.room.y / 2) *-y_dir
                voy.coordinates.rooms[i].railing = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
                origin = {x = x1, y = y1}
                local r = dim.cleat
                x1 = origin.x + r
                y1 = origin.y + r
                x2 = origin.x - r
                y2 = origin.y - r
                voy.coordinates.rooms[i].cleat = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
            end
        end
        
        local function get_wheel_coordinates(x1, y1, x2, y2, dim, origin) -- left, top, right, bottom, dimensions, origin
            x1 = origin.x - (dim.wheel.x / 2)
            y1 = origin.y - (dim.wheel.y / 2)
            x2 = origin.x + (dim.wheel.x / 2)
            y2 = origin.y + (dim.wheel.y / 2)
            voy.coordinates.wheel = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
        end

        local function get_lasso_coordinates(dim, i, origin) -- dimensions, room, center
            local x1 = origin.x + (dim.thyng.x / 2)
            local y1 = origin.y
            local x2 = origin.x - (dim.thyng.x / 2)
            local y2 = y1
            voy.coordinates.rooms[i].lasso = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
        end

        local function get_held_coordinates(dim, coor) -- dimensions, coordinates
            voy.coordinates.held = {}
            local h = dim.font.sides
            local y_cen = dim.buffer.y + (2 * dim.block.y) + dim.shift.y
            local w = WindowTextWidth(win, "sides", "L")
            local x1 = (voy.dimensions.text.held.x - w) / 2
            local x2 = x1 + w
            local y1 = y_cen - h / 2
            local y2 = y1 + h
            voy.coordinates.held.L = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
            local decent = WindowFontInfo(win.."upright", "vf", 3)
            local shift_x = w * .2 + decent 
            local shift_y = y2 + h * .2
            voy.coordinates.held.L.text = {x1 = x1 - shift_x, y1 = y1 + shift_y}
            w = WindowTextWidth(win, "sides", "R")
            x2 = dim.window.x - x1
            x1 = x2 - w
            voy.coordinates.held.R = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
            shift_x = w * .1
            voy.coordinates.held.R.text = {x1 = x1 + shift_x, y1 = y1 + shift_y}
        end
        -- coordinates to draw kraken/serpent
        function get_monster_coordinates(dim, coor) -- dimensions, coordinates
            local function get_tentacles(i, p, center, width, height, head)
                local tent = {L = {}, R = {}}
                for t, n in pairs({L = -1, R = 1}) do
                    local w = ((width / 2) * .8) * ((p - i + 1) / p)
                    local h = head * ((p - i + 1) / p)
                    table.insert(tent[t], {})
                    table.insert(tent[t][1], center.x - (n * head * .2));table.insert(tent[t][1], center.y - i * 3)
                    table.insert(tent[t][1], tent[t][1][1] + n * w);table.insert(tent[t][1], tent[t][1][2] + head)
                    table.insert(tent[t][1], tent[t][1][1] + n * w);table.insert(tent[t][1], tent[t][1][2])
                    table.insert(tent[t][1], tent[t][1][5]);table.insert(tent[t][1], tent[t][1][2] - h / 2 )
                    table.insert(tent[t], {})
                    table.insert(tent[t][2], tent[t][1][7]);table.insert(tent[t][2], tent[t][1][8])
                    table.insert(tent[t][2], tent[t][2][1]);table.insert(tent[t][2], tent[t][2][2] - h / 2 )
                    table.insert(tent[t][2], tent[t][2][3] - n * (i == 2 and 1 or 1) * (w * .25));table.insert(tent[t][2], tent[t][2][4])
                    table.insert(tent[t][2], tent[t][2][5]);table.insert(tent[t][2], tent[t][2][6] + h / 2 )
                end
                for k, t in pairs(tent) do
                    for i, v in ipairs(t) do
                        tent[k][i] = get_poly_format(v)
                    end
                end
                return tent
            end
            voy.coordinates.kraken = {}
            voy.coordinates.serpent = {}
            local x1 = coor.rooms[1].room.outter.x2
            local y1 = dim.font.title
            local x2 = coor.rooms[11].room.outter.x1
            local y2 = coor.rooms[21].room.outter.y1
            voy.coordinates.kraken  = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
            voy.coordinates.serpent = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
            --kraken
            local width = (x1 - x2) * .95
            local height = y2 - y1
            local center = {
                x = dim.window.x / 2,
                y = height / 2 + y1}
            local head = height * .5
            x1 = center.x - head / 2
            y1 = center.y - head / 2
            x2 = center.x + head / 2
            y2 = center.y + head / 2
            voy.coordinates.kraken.head = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
            voy.coordinates.kraken.tentacles = {}
            center.y = y2
            local p = 3
            for i = 1, 3 do
                table.insert(voy.coordinates.kraken.tentacles, get_tentacles(i, p, center, width, height, head))
            end
            --serpent
            function get_coils(i, p, start, width, height, head)
                local coils = {}
                local n = i - (p + 1) / 2
                local seg = width / 6
                local hump = head * 1.1
                table.insert(coils, {})
                table.insert(coils[1], start.x);table.insert(coils[1], start.y + n)
                table.insert(coils[1], coils[1][1] + seg);table.insert(coils[1], coils[1][2])
                table.insert(coils[1], coils[1][3] + seg);table.insert(coils[1], coils[1][2] - hump * .8)
                table.insert(coils[1], coils[1][5] + seg);table.insert(coils[1], coils[1][2])
                table.insert(coils, {})
                table.insert(coils[2], coils[1][7]);table.insert(coils[2], coils[1][8])
                table.insert(coils[2], coils[2][1] + seg);table.insert(coils[2], coils[2][2] + hump)
                table.insert(coils[2], coils[2][3] + seg);table.insert(coils[2], coils[2][2] - hump)
                table.insert(coils[2], coils[2][5] + seg);table.insert(coils[2], start.y)
                for i, v in ipairs(coils) do
                    coils[i] = get_poly_format(v) 
                end
                return coils
            end
            width = math.abs(width) * .8
            x1 = x1 - (width / 2)
            x2 = x2 - (width / 2)
            voy.coordinates.serpent.head = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
            voy.coordinates.serpent.coils = {}
            p = head *.6
            for i = 1, p do
                table.insert(voy.coordinates.serpent.coils, get_coils(i, p, {x = x2 - 1, y = center.y - head / 2}, width, height, head))
            end
        end
        local function get_sea_coordinates(dim, coor) -- dimensions, coordinates
            local center = {
                x = dim.window.x / 2,
                y = (dim.window.y + coor.title.bar.y2) / 2
            }
            local c = dim.sea.x
            local r = c / 2
            local w = c / 5
            local h = w
            local x1 = center.x - r
            local x2 = center.x + r
            local y1 = center.y - r
            local y2 = center.y + r
            voy.coordinates.sea = {}
            local function circle_point(x0, y0, r, theta)
                local x = x0 + r * math.cos(theta)
                local y = y0 - r * math.sin(theta)
                return x, y
            end
            local function rad(angle)
                return angle * math.pi / 180
            end
            voy.coordinates.direction = {}
            local r0 = math.sqrt(WindowTextWidth(win, "title", "WR")^2 + WindowFontInfo(win, "title", 1)^2) / 2
            local i = -2
            for theta = 180, 0, -45 do
                local x, y = circle_point(center.x, center.y, r + r0, rad(theta))
                voy.coordinates.direction[i] = {x1 = x - r0, y1 = y - r0, x2 = x + r0, y2 = y + r0}
                i = i + 1
            end
            voy.coordinates.compass = {}
            for theta = 90, -270, -45 do
                local x, y = circle_point(center.x, center.y, r + r0, rad(theta))
                table.insert(voy.coordinates.compass, {x = x, y = y})
            end
            voy.coordinates.sea.frame = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
            voy.coordinates.sea.map = {}
            local left = x1
            for y = 1, 5 do
                y2 = y1 + h
                x1 = left
                voy.coordinates.sea.map[y] = {}
                for x = 1, 5 do
                    x2 = x1 + w
                    voy.coordinates.sea.map[y][x] = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
                    x1 = x2
                end
                y1 = y2
            end
            voy.coordinates.sea.boat = {deck = {}, hull = {}, turnwheel = {}, poly = {}, poly_wreck = {}, speed = {}, wake = {}}
            center.x = w / 2
            center.y = h / 2
            local n = w * .16
            local m = n * 1.4
            local p = n * .4
            q = n * .9
            x1 = center.x - n
            x2 = center.x + n
            y1 = center.y - n
            y2 = center.y + n
            voy.coordinates.sea.boat.deck.outter = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
            local x3 = center.x
            local y3 = y1 - m
            voy.coordinates.sea.boat.hull = {x1 = x1 - 1, y1 = y1 - 3, x2 = x2 + 1, y2 = y1 - 3, x3 = x3, y3 = y3 - 3}
            voy.coordinates.sea.boat.poly = get_poly_format({x1, center.y + n, x1, y1, x3, y3, x2, y1, x2, center.y + n,})
            voy.coordinates.sea.boat.poly_wreck = get_poly_format({x1, y2 + m, x1, y1, x3, y3, x2, y1, x2, y2 + m,})
            x1 = center.x - p
            x2 = center.x + p
            y1 = center.y - p - n
            y2 = center.y + p - n
            voy.coordinates.sea.boat.deck.inner = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
            x1 = center.x - q
            x2 = center.x + q
            y1 = center.y + n - p
            y2 = center.y + n + p
            voy.coordinates.sea.boat.turnwheel = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
            x1 = center.x - n
            x2 = center.x + n
            y1 = center.y + n + p + 1
            y3 = h
            local left  = w / 5
            local right = w - left
            voy.coordinates.sea.boat.speed = {
                {x1 = x1, y1 = y1, x2 = left,  y2 = y3}, 
                {x1 = x2, y1 = y1, x2 = right, y2 = y3}
            }
            voy.coordinates.sea.boat.wake = get_poly_format({x1, y1, x2, y1, right, y3, left, y3,})
            voy.coordinates.sea.boat.rest = {x1 = x1, y1 = y1, x2 = x2, y2 = y1}
            local tw = WindowTextWidth(win, "larger", "x")
            local th = WindowFontInfo(win, "larger", 1)
            x2 = dim.window.x - dim.buffer.x
            x1 = x2 - tw
            y1 = dim.title[1].y
            y2 = y1 + th
            voy.coordinates.sea.exit = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
        end
        voy.coordinates = {rooms = {}, title = {},}
        get_title_coordinates(dim)
        for i, v in ipairs(voy.rooms) do
            voy.coordinates.rooms[i] = {
                room = {outter = {}, inner = {},},}
            local room_center = {
                x = dim.buffer.x + (v.location.x * dim.block.x) - (dim.block.x / 2),
                y = dim.buffer.y + (v.location.y * dim.block.y) + dim.shift.y}
            voy.coordinates.rooms[i].origin = {x = room_center.x, y = room_center.y,}
            get_lasso_coordinates(dim, i, room_center)
            local x1 = room_center.x - (dim.room.x / 2)
            local y1 = room_center.y - (dim.room.y / 2)
            local x2 = room_center.x + (dim.room.x / 2)
            local y2 = room_center.y + (dim.room.y / 2)
            voy.coordinates.rooms[i].room.outter = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
            if i == 1 then
                get_wheel_coordinates(x1, y1, x2, y2, dim, room_center)
            end
            get_exit_coordinates(dim, i, v, room_center)
            get_letter_coordinates(dim, i, room_center)
            x1 = room_center.x - (dim.thyng.x / 2)
            y1 = room_center.y - (dim.thyng.y / 2)
            x2 = room_center.x + (dim.thyng.x / 2)
            y2 = room_center.y + (dim.thyng.y / 2)
            voy.coordinates.rooms[i].room.inner  = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
            get_dragon_coordinates(dim, i, room_center)
            get_hull_coordinates(dim, i, room_center)
            get_railing_coordinates(dim, i, room_center)
            if i == 18 then
                get_circle_coordinates(dim, i, room_center, -1)
            elseif i == 20 then
                get_circle_coordinates(dim, i, room_center, 1)
            end
        end
        voy.coordinates.text = {}
        get_text_coordinates(dim, voy.coordinates)
        get_guage_coordinates(dim, voy.coordinates)
        get_held_coordinates(dim, voy.coordinates)
        get_monster_coordinates(dim, voy.coordinates)
        get_sea_coordinates(dim, voy.coordinates)
    end
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	--   RESIZE WINDOWS
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    local function resize_windows(dim, col) -- dimensions, colours
        WindowResize(win,              dim.window.x, dim.window.y, col.window.transparent) 
        WindowResize(win.."copy_from", dim.room.x,   dim.room.y,   col.window.transparent) 
        WindowResize(win.."base",      dim.window.x, dim.window.y, col.window.transparent) 
        WindowResize(win.."underlay",  dim.window.x, dim.window.y, col.window.transparent) 
        WindowResize(win.."guages",    dim.window.x, dim.window.y, col.window.transparent) 
        WindowResize(win.."circles",   dim.window.x, dim.window.y, col.window.transparent) 
        WindowResize(win.."21",        dim.window.x, dim.window.y, col.window.transparent) 
        WindowResize(win.."held",      dim.window.x, dim.window.y, col.window.transparent)
        WindowResize(win.."kraken",    dim.window.x, dim.window.y, col.window.transparent)
        WindowResize(win.."serpent",   dim.window.x, dim.window.y, col.window.transparent)
        WindowResize(win.."help",      dim.window.x, dim.window.y, col.window.transparent)
        WindowResize(win.."sea_frame", dim.window.x, dim.window.y, col.window.transparent)
        WindowResize(win.."sea_map",   dim.window.x, dim.window.y, col.window.transparent)
        WindowResize(win.."sea_room",  dim.sea.block.x, dim.sea.block.y, col.window.background)
        voyage_reset_held(dim, col)
    end
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	--   LOAD FONTS
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    local function get_font(dim, col) -- dimensions, colours
        local function load_vertical_font(font, size)
            WindowCreate(win.."upright", 0, 0, 0, 0, miniwin.pos_center_all, 0, col.window.background)
            WindowCreate(win.."rotated", 0, 0, 0, 0, miniwin.pos_center_all, 0, col.window.background)
            assert(WindowFont(win.."upright", "vf", font, size, false, false, false, false), tostring(win).."upright "..tostring(c).." "..tostring(f).." "..tostring(s))
        end
        voy.dimensions.font = {}

        local f_tbl = utils.getfontfamilies ()
        local font = {false, false}
        for i, t in ipairs({
            {"System", "Fixedsys", "Arial"},  -- choices for font 1 (title)
            {"Dina", "Arial", "Helvetica"}    -- choices for font 2
        }) do
            for ii, f in ipairs(t) do
                if f_tbl[f] then
                    font[i] = f
                    break
                end
            end
        end
         -- if none of our chosen fonts are avaliable, pick the first one that is
        for i, f in ipairs(font) do
            if not f then
                for k in pairs(f_tbl) do
                    font[i] = k
                    break
                end
            end
        end
        
        assert(font[1] and font[2], "Fonts not loaded!")
        for c, p in pairs({title = 150 / 11, larger = dim.thyng.y, smaller = dim.window.y / 24, sides = dim.text.held.x * 0.7, sea = dim.sea.y / 5}) do
            local max = 200
            local h, s = 0, 1
            local f = c == "title" and font[1] or font[2]
            if c == "sides" then
                local w = 0
                while (w < p) and (s < max) do
                    assert(WindowFont(win, c, f, s, false, false, true, false), tostring(win).." "..tostring(c).." "..tostring(f).." "..tostring(s))
                    w = tonumber(WindowTextWidth(win, c, "R")) or w or 0
                    h = tonumber(WindowFontInfo(win, c, 1)) or h or 0
                    s = s + 1
                end
                local hv, sv, cv, fv = 0, 1, "cv", font[2]
                while (hv < w) and (sv < max) do
                    assert(WindowFont(win, cv, fv, sv, false, false, false, false), tostring(win).." "..tostring(cv).." "..tostring(fv).." "..tostring(sv))
                    hv = tonumber(WindowFontInfo(win, cv, 1)) or hv or 0
                    sv = sv + 1
                end
                load_vertical_font(fv, sv)
            else
                while (h < p) and (s < max) do
                    assert(WindowFont(win, c, f, s, false, false, false, false), tostring(win).." "..tostring(c).." "..tostring(f).." "..tostring(s))
                    h = tonumber(WindowFontInfo(win, c, 1)) or h or 0
                    s = s + 1
                end
            end
            for _, mw in ipairs({win.."base", win.."underlay", win.."held", win.."21", win.."sea_frame", win.."sea_map", win.."sea_room"}) do
                assert(WindowFont(mw, c, f, s, false, false, c == "sides" or false, false), tostring(mw).." "..tostring(c).." "..tostring(f).." "..tostring(s))
                voy.dimensions.font[c] = h or 0
            end
            local loaded = WindowFontList(win)
            for k, v in pairs(loaded) do
                --print(v, WindowFontInfo(win, v, 21), WindowFontInfo(win, v, 1))
            end
        end
    end
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	--   TITLE DIMENSIONS
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    local function get_title_dimensions(dim) -- dimensions
        local mw = win.."base"
        voy.title = {"SS Unsinkable - ", "Part: ", "", " - Stage: ", "",}
        voy.dimensions.title = {}
        for i, v in ipairs(voy.title) do
            voy.dimensions.title[i] = {x = WindowTextWidth(mw, "title", voy.title[i]), y = dim.font.title,}
        end
        local stages = {"Fire", "Ice", "Calm", "Wind", "Fog", "Serpant", "Kraken"}
        for i, v in ipairs(stages) do
            local sw = WindowTextWidth(mw, "title", v)
            voy.dimensions.title[5].x = sw > voy.dimensions.title[5].x and sw or voy.dimensions.title[5].x             
            voy.dimensions.title[5].x = sw > voy.dimensions.title[5].x and sw or voy.dimensions.title[5].x             
            if i <= 4 then
                local nw = WindowTextWidth(mw, "title", tostring(i))
                voy.dimensions.title[3].x = nw > voy.dimensions.title[3].x and nw or voy.dimensions.title[3].x
            end
        end
        voy.dimensions.title.width = 0
        for i, v in ipairs(voy.dimensions.title) do
            voy.dimensions.title.width = voy.dimensions.title.width + v.x
        end
    end
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	--   IMAGES
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    local function get_images(dim) -- dimensions
        file_path = (GetPluginInfo(GetPluginID(), 6)):match("^(.*\\).*$")
        local img = {"up", "down"}
        for _, v in ipairs(img) do
            WindowLoadImage (win.."copy_from", v, file_path.."images\\"..v..".bmp")
            WindowDrawImage(win.."copy_from", v, 0, 0, dim.room.x, dim.room.y, 2)
            WindowImageFromWindow(win.."base", v, win.."copy_from")
        end
        WindowLoadImage (win.."help", "help", file_path.."images\\help.bmp")
        WindowDrawImage(win.."help", "help", 0, 0, dim.window.x, dim.window.y, 2)
    end
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	--   GENERATE SEA ROOMS
	--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~   
    local function get_sea_rooms(dim, col) -- dimensions, colours
        local mw = win.."sea_room"
        local function bg(is_land)
            local w = dim.sea.block.x + 1
            local h = dim.sea.block.y + 1
            if is_land then
                WindowCircleOp(mw, 2, 
                    0, 0, w, h,            
                    col.sea.land[1], miniwin.pen_null, 0,
                    col.sea.land[2], miniwin.brush_medium_pattern)    
            else -- on water
                WindowCircleOp(mw, 2, 
                    0, 0, w, h,            
                    col.sea.water, miniwin.pen_null, 0,
                    col.sea.water, miniwin.brush_waves_horizontal)
            end
        end
        local w = dim.sea.block.x + 1
        local h = dim.sea.block.y + 1
        local p = w - (w * .8)
        local x1 = p
        local y1 = p
        local x2 = w - p
        local y2 = w - p
        local draw_sea_room = {
            ['@'] = 
                (function() -- boat
                    bg()
                    local col = voy.colours
                    local coor = voy.coordinates.sea.boat
                    local percentage = voy.hull.condition
                    local outline = col.hull.default
                    WindowCircleOp(mw, 2, -- turnwheel
                        coor.turnwheel.x1, coor.turnwheel.y1, coor.turnwheel.x2, coor.turnwheel.y2,           
                        col.sea.boat[1], miniwin.pen_solid, 1,
                        col.sea.boat[1], miniwin.brush_solid)
                    WindowPolygon(mw, coor.poly_wreck, -- boat
                        outline, miniwin.pen_solid, 2,
                        col.sea.boat[2], miniwin.brush_hatch_horizontal,
                        true,  
                        false)
                    local center = h / 2
                    local x1 = center - (w / 4)
                    local x2 = center + (w / 4)
                    local y1 = center
                    local y2 = center + (w / 6)
                    WindowCircleOp(mw, 2, 
                       x1, y1, x2, y2,          
                        col.sea.water, miniwin.pen_solid, 2,
                        col.sea.water, miniwin.brush_waves_horizontal)
                    WindowLine(mw, 
                        x1, y1, x2, y1,  
                        col.sea.ripple, miniwin.pen_solid, 1)
                    WindowLine(mw, 
                        x1, y2 - 3, x2, y2 - 3,  
                        col.sea.ripple, miniwin.pen_solid, 1)
                end),
            ['~'] = 
                (function() -- water
                    bg()
                end),
            [' '] = 
                (function() -- nothing
                    bg()
                end),
            ['.'] = 
                (function() -- debris
                    bg()
                    local n = p / 2
                    local shift = w * .2
                    local c = w / 10
                    local r = c / 2
                    local left = {x1, x1 + shift}
                    local right = {x2 - shift, x2}
                    local y_pos = {y1 + n, h / 2, y2 - n}
                    for i, v in ipairs(y_pos) do
                        WindowLine(mw, -- bottom shadow
                            left[i] or left[1], v + r, right[i] or right[1], v + r,  
                            col.sea.ripple, miniwin.pen_solid, 1)
                        WindowCircleOp(mw, 1, -- left end
                            (left[i] or left[1]) - r, v - r, (left[i] or left[1]) + r, v + r,           
                            col.sea.debris[2], miniwin.pen_solid, 1,
                            col.sea.debris[1], miniwin.brush_solid)
                        WindowCircleOp(mw, 2, -- log
                            left[i] or left[1], v - r, right[i] or right[1], v + r,           
                            col.sea.debris[1], miniwin.pen_null, 0,
                            col.sea.debris[1], miniwin.brush_solid)
                        WindowLine(mw, -- top shadow
                            left[i] or left[1], v - r, right[i] or right[1], v - r,  
                            col.sea.debris[2], miniwin.pen_solid, r)
                        WindowCircleOp(mw, 1,  -- right end
                            (right[i] or right[1]) - r, v - r, (right[i] or right[1]) + r, v + r,           
                            col.sea.debris[2], miniwin.pen_solid, 1,
                            col.sea.debris[1], miniwin.brush_solid)
                    end
                end),
            ['-'] = 
                (function() -- driftwood
                    bg()
                    local n = p / 2
                    WindowCircleOp(mw, 2, 
                        x1, y1 + n, x2, y2 - n,            
                        col.sea.wood[1], miniwin.pen_null, 0,
                        col.sea.wood[2], miniwin.brush_waves_horizontal)
                    WindowLine(mw, 
                        x2, y1 + n, x2, y2 - n,  
                        col.sea.ripple, miniwin.pen_solid, 1)
                    WindowLine(mw, 
                        x1, y2 - n, x2, y2 - n,
                        col.sea.ripple, miniwin.pen_solid, 1)
                end),
            ['O'] = 
                (function() -- turtle
                    bg()
                    local n = w * .05
                    local n2 = w / 16
                    WindowCircleOp(mw, 1, 
                        w/2 - n2 * .9, y2 - n2 * 2, w/2 + n2 * .9, y2 + n2 * 1.1,            
                        col.sea.turtle[1], miniwin.pen_solid, 1,
                        col.sea.turtle[2], miniwin.brush_solid)
                    WindowLine(
                        mw, 
                        x1, y1 + n2, x2, y2 - n2,  
                        col.sea.turtle[2], miniwin.pen_solid, w / 10)
                    WindowLine(
                        mw, 
                        x2, y1 + n2, x1, y2 - n2,  
                        col.sea.turtle[2], miniwin.pen_solid, w / 10)
                    WindowCircleOp(mw, 1, 
                        w/2 - n2 * .5, y1 - n2 / 2, w/2 + n2 * .5, y1 + n2,            
                        col.sea.turtle[2], miniwin.pen_solid, 1,
                        col.sea.turtle[2], miniwin.brush_solid)
                    WindowCircleOp(mw, 1,
                        x1 + n, y1 + n, x2 - n, y2 - n,            
                        col.sea.turtle[1], miniwin.pen_solid, 3,
                        col.sea.turtle[2], miniwin.brush_hatch_cross_diagonal)
                end),
            ['='] = 
                (function() -- ice flow
                    bg()
                    local n = p / 2
                    WindowCircleOp(mw, 2, 
                        x1, y1, x2, y2,            
                        col.sea.flow[1], miniwin.pen_null, 0,
                        col.sea.flow[2], miniwin.brush_hatch_backwards_diagonal, 5, 5)
                    WindowLine(mw, 
                        x2, y1, x2, y2,  
                        col.sea.ripple, miniwin.pen_solid, 1)
                    WindowLine(mw, 
                        x1, y2, x2, y2,
                        col.sea.ripple, miniwin.pen_solid, 1)
                end),
            ['$'] = 
                (function() -- seaweed
                    bg()
                    local top = {1.5, .2, 1, .3, 1.9}
                    local left = w / 7
                    local right = 0
                    for i = 1, 5 do
                        right = i * left + w / 7
                         WindowCircleOp(mw, 2, 
                            i * left, y1 * (1 + top[i]), right, y2,            
                            col.sea.water, miniwin.pen_null, 0,
                            col.sea.seaweed, miniwin.brush_waves_vertical)
                    end
                    WindowLine(mw, 
                        left, y2, right, y2,  
                        col.sea.ripple, miniwin.pen_solid, 1)
                end),
            ['?'] = 
                (function() -- fog
                    bg()
                    WindowCircleOp(mw, 2, 
                        0, 0, w, h,            
                        col.sea.fog[1], miniwin.pen_null, 0,
                        col.sea.fog[2], miniwin.brush_medium_pattern)
                    local shift = (w - WindowTextWidth(mw, "sea", "?")) / 2
                    WindowText (mw, "sea", "?",
                                shift, 0, 0, 0,  -- rectangle
                                col.sea.fog[3], 
                                false)
                end),
            ['^'] = 
                (function() -- current
                    bg()
                    local x1, y1 = w / 2, 0
                    while y1 <= h do
                        local y2 = y1 + x1
                        for i = - 1, 1, 2 do
                            local x2 = x1 * (1 + i)
                            WindowLine(mw, 
                            x1, y1, x2, y2,  
                            col.sea.current, miniwin.pen_solid, 2)
                        end
                        y1 = y1 + 8
                    end
                end),
            ['v'] = 
                (function() -- backwards current
                    bg()
                    local x1, y1 = w / 2, h
                    while y1 >= 0 do
                        local y2 = y1 - x1
                        for i = - 1, 1, 2 do
                            local x2 = x1 * (1 + i)
                            WindowLine(mw, 
                            x1, y1, x2, y2,  
                            col.sea.current, miniwin.pen_solid, 2)
                        end
                        y1 = y1 - 8
                    end
                end),
            ['G'] = 
                (function() -- whirlpool
                    bg()
                    local function round(n)
                        return n % 1 >= 0.5 and math.ceil(n) or math.floor(n)
                    end
                    local x1, y1, i = 0, 0, 1
                    while x1 <= w and i < 1000 do
                        local t = i / 20 * math.pi
                        local x2 = (1 + t) * math.cos(t)
                        local y2 = (1 + t) * math.sin(t)
                        local shift = w / 2
                        WindowLine(mw, 
                        x1 + shift, y1 + shift, x2 + shift, y2 + shift,  
                        col.sea.whirlpool, miniwin.pen_solid, 2)
                        x1, y1 = x2, y2
                        i = i + 1
                    end
                end), 
            ['_'] = 
                (function() -- coral reef
                    bg()
                    local top = {1.5, .2, 1, .3, 1.9}
                    local left = w / 7
                    local right = 0
                    for i = 1, 5 do
                        right = i * left + w / 7
                         WindowCircleOp(mw, 2, 
                            i * left, y1 * (1 + top[i]), right, y2,            
                            col.sea.water, miniwin.pen_null, 0,
                            col.sea.reef, miniwin.brush_waves_vertical)
                    end
                    WindowLine(mw, 
                        left, y2, right, y2,  
                        col.sea.ripple, miniwin.pen_solid, 1)
                end),
            ['*'] = 
                (function() -- iceberg
                    local function round(n)
                        return n % 1 >= 0.5 and math.ceil(n) or math.floor(n)
                    end
                    bg()
                    local points = {w / 2, y1, x1, y2 - 2, w * 2 / 3, y2 - 2}
                    local str = ""
                    for i, v in ipairs(points) do
                        str = str..tostring(round(v))..(i < #points and "," or "")
                    end
                    WindowPolygon (mw, str,
                        col.sea.iceberg[1], 0, 0,  
                        col.sea.iceberg[2], miniwin.brush_waves_horizontal ,    
                        true,  
                        false)
                    local points = {w / 2, y1, w * 2 / 3, y2 - 2, x2, y2 - 2}--- (x2 - (w * 2 / 3))}
                    local str = ""
                    for i, v in ipairs(points) do
                        str = str..tostring(round(v))..(i < #points and "," or "")
                    end
                    WindowPolygon (mw, str,
                        col.sea.iceberg[3], 0, 0,  
                        col.sea.iceberg[3], miniwin.brush_solid,    
                        true,  
                        false)
                    WindowLine(mw, 
                        x1, y2, x2, y2,  
                        col.sea.ripple, miniwin.pen_solid, 1)
                end),
            ['n'] = 
                (function() -- rocky outcrop
                    bg("is_land")
                    WindowCircleOp(mw, 2, 
                        0, 0, w, y1,          
                        col.sea.water, miniwin.pen_null, 0,
                        col.sea.water, miniwin.brush_waves_horizontal)
                    WindowCircleOp(mw, 2, 
                        0, h * .7, w, h,          
                        col.sea.water, miniwin.pen_null, 0,
                        col.sea.water, miniwin.brush_waves_horizontal)
                    WindowCircleOp(mw, 2, 
                        0, h/2, w, h * .8 - 2,            
                        col.sea.outcrop[1], miniwin.pen_solid, 3,
                        col.sea.outcrop[2], miniwin.brush_hatch_cross)
                    WindowLine(mw, 
                        0, h * .8, w, h * .8,  
                        col.sea.ripple, miniwin.pen_solid, 1)
                end),
            ['H'] = 
                (function() -- land
                    bg("is_land")
                end),
            ['P'] =
                (function()  -- cove
                    bg("is_land")
                    WindowCircleOp(mw, 2, 
                        0, h / 3, w, h * .8 - 3,            
                        col.sea.cove[1], miniwin.pen_solid, 3,
                        col.sea.cove[2], miniwin.brush_hatch_cross)
                    WindowCircleOp(mw, 1, 
                        x1, h / 3, x2, h * 1.5,            
                        col.sea.cove[1], miniwin.pen_solid, 7,
                        col.sea.water, miniwin.brush_null)
                    WindowCircleOp(mw, 1, 
                        x1, ((h / 3) * 1.1) , x2, (h * 1.5),            
                        col.sea.cove[3], miniwin.pen_null, 1,
                        col.sea.cove[3], miniwin.brush_fine_pattern)
                    WindowCircleOp(mw, 1, 
                        x1 + (w * .05) - 1, (h * .8) * .8 , x2 - (w * .05) + 1, (h * .8) * 1.2,            
                        col.sea.ripple, miniwin.pen_solid, 1,
                        col.sea.water, miniwin.brush_solid)
                    WindowCircleOp(mw, 2, 
                        0, h * .8 - 3, w, h,          
                        col.sea.water, miniwin.pen_null, 0,
                        col.sea.water, miniwin.brush_waves_horizontal)
                    WindowLine(
                        mw, 
                        0, (h * .8) - 3, x1 + (w * .05), (h * .8) - 3,  
                        col.sea.cove[2], miniwin.pen_solid + 512, 3)
                    WindowLine(
                        mw, 
                        x2 - (w * .05), (h * .8) - 3, w, (h * .8) - 3,  
                        col.sea.cove[2], miniwin.pen_solid + 512, 3)
                    WindowLine(
                        mw, 
                        x2 - (w * .05), h * .8, w, h * .8,  
                        col.sea.ripple, miniwin.pen_solid, 1)
                    WindowLine(
                        mw, 
                        0, h * .8, x1 + (w * .05), h * .8,  
                        col.sea.ripple, miniwin.pen_solid, 1)
                end),
        }
        for k, v in pairs(draw_sea_room) do
            v(); WindowImageFromWindow(win.."sea_map", k, mw)
        end
    end
    
    local dimensions = get_window_dimensions(window_width, window_height)
    
    resize_windows(dimensions, colours)
    get_font(dimensions, colours)
    get_title_dimensions(dimensions)
    get_coordinates(dimensions)
    get_images(dimensions)
    get_sea_rooms(dimensions, colours)
    voyage_draw_base(dimensions, colours)
    voyage_draw_underlay(dimensions, colours)
    voyage_draw_guages(dimensions, colours)
    voyage_draw_circles(voy.coordinates.circle, colours)
    voyage_draw_kraken(voy.coordinates.kraken, colours)
    voyage_draw_serpent(voy.coordinates.serpent, colours)
    
    --print("total:", os.clock() - start_time) -- speed test
end
