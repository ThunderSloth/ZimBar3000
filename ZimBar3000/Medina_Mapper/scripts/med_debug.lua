--------------------------------------------------------------------------------
--   DEBUG FUNCTIONS
--------------------------------------------------------------------------------
function medina_debug_movement()
	local debug_movement = false
    if debug_movement then
        print("room sequence:");tprint(med.sequence)
        print("queued commands:");tprint(med.commands.move)
        print("queued look commands:");tprint(med.commands.look)
    end
end

function medina_print_error(msg)
	local text_colour1, text_colour2, text_colour3 = "gray", "lightgray", "orange"
	ColourNote(
		text_colour2, "", "<",
		text_colour3, "", msg,
		text_colour2, "", ">")
end
