--------------------------------------------------------------------------------
--   CAPTAIN-MODE TOGGLE
--------------------------------------------------------------------------------
function voyage_captain_mode_on()
    local hotspots = WindowHotspotList(win)
    if hotspots then
        local keep = {resize = true, time = true, title = true, xp = true}
        for _, v in ipairs (hotspots) do
            if not keep[v] then
                WindowDeleteHotspot(win, v)
            end
        end
        voyage_get_steering_hotspots(voy.dimensions)
    end 
end

function voyage_captain_mode_off()
    voyage_get_hotspots(voy.dimensions)
    voyage_draw_stage(voy.coordinates, voy.colours, win.."underlay")
end
--------------------------------------------------------------------------------
--   LOOK SEA
--------------------------------------------------------------------------------
function on_trigger_voyage_look_sea(name, line, wildcards, styles)
    if voy.steering then
        if not voy.sea then
            voy.sea = {}
            voyage_captain_mode_on()
        end
        for i = 2, 6 do
            voy.sea[i - 1] = wildcards[i] or "~~~~~"
        end
        voyage_print_map()
    end
end
--------------------------------------------------------------------------------
--   STEERING WHEEL TRACKING
--------------------------------------------------------------------------------
function on_trigger_voyage_steering_on(name, line, wildcards, styles)
    voy.steering = true
end

function on_trigger_voyage_steering_off(name, line, wildcards, styles) 
    voy.steering, voy.sea = false, false
    voyage_captain_mode_off()
    voyage_print_map()
end

function voyage_turn_wheel(end_notch)
    local start_notch = voy.direction
    local delta = math.abs(end_notch - start_notch)
    local command = "hold wheel"
    if end_notch == 0 then
        command = "centre wheel"
    elseif end_notch > start_notch then
        command = "turn wheel starboard"
    elseif end_notch < start_notch then
        command = "turn wheel port"
    end
    if end_notch ~= 0 and delta > 1 then
        Send(command.." by "..delta)
    else
        Send(command)
    end
    voy.direction = end_notch
    voyage_print_map()
end
--------------------------------------------------------------------------------
--   DIRECTION TRACKING
--------------------------------------------------------------------------------
function on_trigger_voyage_boat_turn(name, line, wildcards, styles)
    local function new_direction(rotation)
        local dir = {"H", "WH", "W", "WR", "R", "TR", "T", "TH"}
        local rid = {H = 1, WH = 2, W = 3, WR = 4, R = 5, TR = 6, T = 7, TH = 8}
        local n = rid[voy.heading]
        n = n + rotation
        while n < 1 or n > 8 do
            if n < 1 then
                n = n + 8
            elseif n > 8 then
                n = n - 8
            end
        end
        return dir[n]
    end
    local rotation = 0
    if wildcards.direction == "port" then 
        rotation = -1
    elseif wildcards.direction == "starboard" then
        rotation = 1
    end
    if wildcards.sharply ~= "" then
        rotation = rotation * 2
    end
    voy.heading = new_direction(rotation)
    voyage_print_map()
end

function on_trigger_voyage_set_direction(name, line, wildcards, styles)
	local directions = {
		["hubwards"] = "H", 
		["widdershins-hubwards"] = "WH", 
		["widdershins"] = "W", 
		["widdershins-rimwards"] = "WR", 
		["rimwards"] = "R", 
		["turnwise-rimwards"] = "TR", 
		["turnwise"] = "T", 
		["turnwise-hubwards"] = "TH",}
	local dir = string.lower(wildcards.direction)
	voy.heading = directions[dir] or voy.heading
    voyage_print_map()
end

function on_trigger_voyage_charts(name, line, wildcards, styles)

end

function on_trigger_voyage_whirlpool(name, line, wildcards, styles)
	voy.heading = "?"
	voyage_print_map()
end
--------------------------------------------------------------------------------
--   MOVEMENT DETECTION
--------------------------------------------------------------------------------
function on_trigger_voyage_boat_start(name, line, wildcards, styles) 
    voy.speed = 1
    if voy.sea then
        voyage_print_map()
    end
    -- detect first movement to signify search stage completion
    if xp_t.current_range == 1 then
		voyage_complete_xp_range("Search")
	end
end

function on_trigger_voyage_boat_stop(name, line, wildcards, styles) 
    voy.speed = 0
    if voy.sea then
        voyage_print_map()
    end
end
