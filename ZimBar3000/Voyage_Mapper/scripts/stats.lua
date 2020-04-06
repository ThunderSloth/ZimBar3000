--------------------------------------------------------------------------------
--   TIME
--------------------------------------------------------------------------------
function voyage_get_timers()
    AddTimer("ticker", 0, 0, .25, "", 0, "voyage_update_time")
end

function voyage_update_time()
    voyage_draw_time()
    voyage_draw_xp()
end
--------------------------------------------------------------------------------
--   XP
--------------------------------------------------------------------------------
function voyage_reset_xp()
    xp_t = {current_xp = false, current_range = 1, is_need_initial_xp = true, is_need_final_xp = false, crates = 0, group = 0 }
    -- xp at at different stages/parts
    local xp_ranges = {"", "Search", "Part 1", "Part 2", "Fight", "Part 3", "Part 4"}
    for i = 0, 6 do
        xp_t[i] = {time = false, xp = false, name = xp_ranges[i + 1]}  
    end									 
    xp_t[0].time = os.time()                  -- starting xp
end

function voyage_update_xp(xp)
	-- xp ranges tracked are as follows:
    -- start - searching - part 1 - part 2 - fight - part 3 - part 4 - finish
	-- technically part three starts at the end of two,  but we will treat the
	-- end of the fight as the beginning of three, because it will provide
	-- more meaningful data
    xp_t.current_xp = xp
	if xp_t.is_need_initial_xp then
		xp_t[0].xp = xp
		xp_t.is_need_initial_xp = false
	end
	xp_t[xp_t.current_range].xp = xp
    voyage_draw_xp()
end

function voyage_complete_xp_range(range)
	local xp_ranges = {Search = 1, [1] = 2, [2] = 3, Fight = 4, [3] = 5, [4]= 6}
	xp_t[xp_ranges[range]].time = os.time()
	xp_t.current_range = xp_ranges[range] + 1
end


function voyage_update_completion_stats(wildcards)
    local num = {one = 1, two = 2, three = 3, four = 4, five = 5, six = 6, seven = 7, eight = 8}
    xp_t.crates = num[wildcards.crates] or 0
    xp_t.group  = num[wildcards.group ] or 0
end

function voyage_update_final_xp(xp)
	if xp_t.is_need_final_xp then
		xp_t[#xp_t].xp = xp
		xp_t.is_need_final_xp = false
		on_alias_voyage_print_xp()
	end
end
--------------------------------------------------------------------------------
--   GENERATE REPORT
--------------------------------------------------------------------------------
function on_alias_voyage_print_xp(name, line, wildcards)
    local function round(num, n)
        local mult = 10^(n or 0)
        return math.floor(num * mult + 0.5) / mult
    end
    local function format_time(t)
        return string.format("%.2d:%.2d", t/60%60, t%60)
    end
    local function format_line(part, xp, time, rate)
        xp = tostring(xp).." xp"
        time = " in "..format_time(time)
        rate = " ("..tostring(rate).." kxp/h)"
        return part..xp..time..rate
    end
    local col = voy.colours.notes
    local summary = {"Voyage XP Summary:","",}
    local printed = false
    for i, v in ipairs(xp_t) do
        if xp_t[i - 1].xp and v.xp and xp_t[i - 1].time and v.time then
            local part = xp_t[i].name..": "
            local xp = v.xp - xp_t[i - 1].xp
            local time = v.time - xp_t[i - 1].time
            local rate = time == 0 and 0 or round(((xp * 60^2) / (time * 1000)), 2)
            local line = format_line(part, xp, time, rate)
            table.insert(summary, line)
            printed = true
        end
    end
    if printed then
        table.insert(summary, "")
    end
    if xp_t[0].xp and xp_t[0].time and (xp_t[6].xp or xp_t.current_xp) then
        local xp = (xp_t[6].xp or xp_t.current_xp) - xp_t[0].xp
        local time = (xp_t[6].time or os.time()) - xp_t[0].time
        local rate = time == 0 and 0 or round(((xp * 60^2) / (time * 1000)), 2)
        local line = format_line('Total : ', xp, time, rate)
        table.insert(summary, line)
        if xp_t.crates ~= 0 then
            table.insert(summary, "Crates: "..tostring(xp_t.crates).."/8")
        end
        if xp_t.group ~= 0 then
            table.insert(summary, "Group : "..tostring(xp_t.group))
        end
        table.insert(summary, "")
        printed = true
    end
    if not printed then
        table.insert(summary, "(No data available.)");table.insert(summary, "")
    end
    for i, v in ipairs(summary) do
        if not wildcards then
            if i == 1 then
                Hyperlink("voyage group report xp", summary[1], "Report XP summary to Group", "orange", "", 0);print("")
            else
                ColourNote(col.text, "", v)
            end
        else
            if v ~= "" then
                Send("group say "..v)
            end
        end
    end
end

function on_alias_voyage_depug_xp(name, line, wildcards)
	tprint(xp_t)
end
