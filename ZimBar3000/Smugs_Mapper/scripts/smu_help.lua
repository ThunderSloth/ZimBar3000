--------------------------------------------------------------------------------
--   HELP
--------------------------------------------------------------------------------
function on_alias_smugs_help()
	local f = io.open(SMU_PATH.."help.txt", 'r')
	ColourNote("whitesmoke", "", f:read("*a"))
	f:close()
end

