--------------------------------------------------------------------------------
--   HELP
--------------------------------------------------------------------------------
function on_alias_mdt_help()
	local f = io.open(MDT_PATH.."help.txt", 'r')
	ColourNote("whitesmoke", "", f:read("*a"))
	f:close()
end
