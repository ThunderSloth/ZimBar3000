-------------------------------------------------------------------------------
--   DEBUGGING
-------------------------------------------------------------------------------
function bprint(t)
	local debug = false
	if debug then
		if type(t) == 'table' then
			tprint(t)
		else
			print(t)
		end
	end
end

function on_alias_mdt_debug_gmpc(name, line, wildcards)
	print(map_door_text)
end
