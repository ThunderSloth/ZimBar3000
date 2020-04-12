--------------------------------------------------------------------------------
--  ENTER AND EXIT HANDLING
--------------------------------------------------------------------------------
function medina_enter()
    if not(med.is_in_medina) then
        med.is_in_medina = true
        med.commands.move, med.commands.look, med.sequence = {}, {}, {}
        med.commands.move.count, med.commands.look.count = 0, 0
        EnableGroup("medina", true)
        DeleteTimer("medina_unvisit")
        DeleteTimer("medina_depopulate")
    end
end

function medina_exit()
    if med.is_in_medina then
        med.is_in_medina = false
        local previous_room = med.sequence[1] or false
        med.sequence = {}; med.sequence[0] = previous_room
        EnableGroup("medina", false)
        AddTimer("medina_unvisit", 0, 3, 0, "", timer_flag.Enabled + timer_flag.Replace + timer_flag.Temporary + timer_flag.OneShot, "medina_unvisit")
        AddTimer("medina_depopulate", 0, 3, 0, "", timer_flag.Enabled + timer_flag.Replace + timer_flag.Temporary + timer_flag.OneShot, "medina_depopulate")
    end
    WindowShow(win, false)
end
