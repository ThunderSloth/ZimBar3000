--------------------------------------------------------------------------------
--   CONFIGURATION
--------------------------------------------------------------------------------
function on_alias_medina_configure()
	dofile(MED_PATH:gsub("\\([A-Za-z_]+)\\$", "\\shared\\").."zconfig.lua")
end
