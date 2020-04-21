--------------------------------------------------------------------------------
--   HELP
--------------------------------------------------------------------------------
function on_alias_medina_help()
	local f = io.open(MED_PATH.."help.txt", 'r')
	ColourNote("whitesmoke", "", f:read("*a"))
	f:close()
end
