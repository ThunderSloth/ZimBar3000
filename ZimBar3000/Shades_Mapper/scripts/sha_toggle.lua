--------------------------------------------------------------------------------
--  ENTER AND EXIT HANDLING
--------------------------------------------------------------------------------
function shades_enter()
    if not(sha.is_in_shades) then
        sha.is_in_shades = true
        sha.commands, sha.sequence = {count = 0}, {}
        EnableGroup("shades", true)
        DeleteTimer("shades_unvisit")
        DeleteTimer("shades_depopulate")
    end
end

function shades_exit()
    if sha.is_in_shades then
        sha.is_in_shades = false
        sha.commands, sha.sequence = {count = 0}, {}
        EnableGroup("shades", false)
        check(AddTimer("shades_unvisit", 0, 3, 0, "", timer_flag.Enabled + timer_flag.Replace + timer_flag.Temporary + timer_flag.OneShot, "shades_unvisit"))
        check(AddTimer("shades_depopulate", 0, 3, 0, "", timer_flag.Enabled + timer_flag.Replace + timer_flag.Temporary + timer_flag.OneShot, "shades_depopulate"))
    end
    WindowShow(win, false)
end

