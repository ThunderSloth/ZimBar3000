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
function voyage_update_xp(xp)
    xp_t.current = xp
    if xp_t[voy.part - 1] and not xp_t[voy.part - 1].xp then
        xp_t[voy.part - 1].xp = xp
    end
    voyage_draw_xp()
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
        if part == 'total' then
            part = "Total : "
        else
            part = "Part "..tostring(part)..": "
        end
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
            local part = tostring(i)
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
    if xp_t[0].xp and xp_t[0].time and (xp_t[4].xp or xp_t.current) then
        local xp = (xp_t[4].xp or xp_t.current) - xp_t[0].xp
        local time = (xp_t[4].time or os.time()) - xp_t[0].time
        local rate = time == 0 and 0 or round(((xp * 60^2) / (time * 1000)), 2)
        local line = format_line('total', xp, time, rate)
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
