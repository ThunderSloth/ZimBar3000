--------------------------------------------------------------------------------
--   CONFIGURATION
--------------------------------------------------------------------------------
function on_alias_mdt_configure()
	dofile(GetPluginInfo(GetPluginID (), 20):gsub("\\([A-Za-z_]+)\\$", "\\shared\\").."zconfig.lua")
end
 
