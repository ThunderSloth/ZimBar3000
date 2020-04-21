--------------------------------------------------------------------------------
--   HELP
--------------------------------------------------------------------------------
function on_alias_shades_help()
	local f = io.open(SHA_PATH.."help.txt", 'r')
	ColourNote("whitesmoke", "", f:read("*a"))
	f:close()
end
