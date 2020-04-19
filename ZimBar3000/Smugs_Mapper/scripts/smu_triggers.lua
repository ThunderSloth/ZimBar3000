--------------------------------------------------------------------------------
--  XML INJECTIONS
--------------------------------------------------------------------------------
function smugs_get_triggers()
	-- if we send directly to script there will be timing issues cause by other
	-- plugins altering our style runs, so we must inject xml into the send field
	-- we need our style runs unaltered so that we can determine players
	-- without false positives
	local function get_xml_injection(xml)
		local code = ([[
			<send>
			if "%%&lt;thyngs&gt;" ~= '' then
			  local n = GetLinesInBufferCount()
			  local styles = GetStyleInfo (n)
			  n = n - 1
			  while not GetLineInfo(n, 3) do	
			    local t = GetStyleInfo (n)
			    if type(t) == 'table' then
				  for i, v in ipairs(t) do
				    if i == #t and styles[i].textcolour == v.textcolour then
				      styles[i].text = v.text..styles[i].text
				      styles[i].length = styles[i].length + v.length
				    else
				      table.insert(styles, i, v)
				    end
				  end
				end
				n = n - 1
			    if n == -1000 then break end
			  end
			  for i, v in ipairs(styles) do
				if GetNormalColour(8) ~= v.textcolour then
			        smu.players[string.lower(Trim(v.text))] = v.textcolour
			    end
			  end
			end
			</send>]]):gsub('\t\t\t', '')
		return xml:gsub('"%s*>',  '">\n' .. code)
	end
    
    local tracking = {"enter", "exit"} 
    for _, v in ipairs(tracking) do
        local f = io.open(SMU_PATH:gsub("\\([A-Za-z_]+)\\$", "\\shared\\")..v..".txt", 'r')
		local match_on = Trim(assert(f:read("*a"), "Can't locate "..v..".txt"))
		AddTrigger("smugs_mob_"..v, match_on, "", trigger_flag.KeepEvaluating + trigger_flag.IgnoreCase + trigger_flag.RegularExpression, custom_colour.NoChange, 0, "", "on_trigger_smugs_mob_track")
		f:close()
		SetTriggerOption ("smugs_mob_"..v, "group", "smugs")
		SetTriggerOption ("smugs_mob_"..v, "send_to", 12)
    end

	for i, v in ipairs({"smugs_mob_here", "smugs_mob_enter", "smugs_mob_exit"}) do
		ImportXML ( get_xml_injection( ExportXML (0, v) ) )
    end
 end
