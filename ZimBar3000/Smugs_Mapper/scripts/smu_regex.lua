--------------------------------------------------------------------------------
--   REGULAR EXPRESSIONS
--------------------------------------------------------------------------------
function smugs_get_regex()
	local f = io.open(SMU_PATH:gsub("\\([A-Za-z_]+)\\$", "\\shared\\").."titles.txt", 'r')
	local title_regex = Trim(assert(f:read("*a"), "Can't locate titles.txt"))
	f:close()
	smu.regex = {
		verbiage = rex.new(" (?<verbiage>(is|are) \\w*?ing ([io]n the \\w*? )?here[. ])"),
		titles   = rex.new(title_regex),
	}
end
