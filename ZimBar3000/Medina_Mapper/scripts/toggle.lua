--------------------------------------------------------------------------------
--  ENTER AND EXIT HANDLING
--------------------------------------------------------------------------------
function medina_enter()
    if not(med.is_in_medina) then
        med.is_in_medina,  med.room_uncertainty = true, false
        med.commands.move, med.commands.look, med.sequence = {}, {}, {}
        med.commands.move.count, med.commands.look.count = 0, 0
        EnableGroup("medina", true)
        -- delete timer med.timer_reset_thyngs
        -- delete timer med.timer_reset_visited
    end
end

function medina_exit()
    if med.is_in_medina then
        med.is_in_medina, med.room_uncertainty = false, false
        local previous_room = med.sequence[1] or false
        med.sequence = {}; med.sequence[0] = previous_room
        EnableGroup("medina", false)
        if GetTriggerInfo("medina_exit", 8) then -- no need to enable if gmcp is active
            EnableTrigger("medina_enter", true)
        end
        -- set timer med.timer_reset_thyngs
        -- set timer med.timer_reset_visited
    end
    WindowShow(win, false)
end
