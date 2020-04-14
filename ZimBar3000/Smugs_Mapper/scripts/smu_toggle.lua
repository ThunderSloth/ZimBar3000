--------------------------------------------------------------------------------
--  ENTER AND EXIT HANDLING
--------------------------------------------------------------------------------
function smugs_enter()
    if not(smu.is_in_smugs) then
        smu.is_in_smugs = true
        smu.commands, smu.sequence = {count = 0}, {}
        EnableGroup("smugs", true)
        DeleteTimer("smugs_unvisit")
    end
end

function smugs_exit()
    if smu.is_in_smugs then
        smu.is_in_smugs = false
        smu.commands, smu.sequence = {count = 0}, {}
        EnableGroup("smugs", false)
        AddTimer("smugs_unvisit", 0, 3, 0, "", timer_flag.Enabled + timer_flag.Replace + timer_flag.Temporary + timer_flag.OneShot, "smugs_unvisit")
    end
end

function smugs_unvisit()
    for r, _ in pairs(smu.rooms) do
        smu.rooms[r].visited = false
        smugs_draw_room_letter(r, smu.coordinates.rooms[r], smu.colours)
    end
end
