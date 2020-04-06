--------------------------------------------------------------------------------
--   HELP
--------------------------------------------------------------------------------
function on_alias_voyage_help()
	local f = io.open(GetPluginInfo (GetPluginID (), 20).."help.txt", 'r')
	ColourNote("whitesmoke", "", f:read("*a"))
	f:close()
end
 

