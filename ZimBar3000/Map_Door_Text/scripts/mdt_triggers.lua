--------------------------------------------------------------------------------
--  TRIGGERS
--------------------------------------------------------------------------------
function mdt_get_triggers()
	local function get_xml_injection(xml)
		local code = ([[
			<send>
			-- when we parse gmcp data, we identify players by embedded colour tags.
			-- we will use the same logic for trigger data, however we must grab the 
			-- style run before it is altered by colourchanging triggers from a another
			-- plugin (for example a mob-colourer.) Because of these timing issues,
			-- we set the plugin priority to far below zero and have the code executed
			-- directly in the send field, rather than a script function.
			local n = GetLinesInBufferCount()
			local styles = GetStyleInfo (n)
			n = n - 1
			-- the last line in the buffer can be broken up by word-wraps, so we must
			-- loop backwards until we find a new line, in order to determine the
			-- actual start of the last line
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
			-- now we forge ansii colour tags so that we can use the exact same function
			-- that parses gmcp, for simplicity
			local formatted_as_gmcp, bs = "", string.char(92)
			for i, v in ipairs(styles) do
				if GetNormalColour(8) ~= v.textcolour then
					formatted_as_gmcp = formatted_as_gmcp..bs.."u001b[4zMXP&lt;"..v.textcolour.."MXP&gt;"..Trim(v.text)..bs.."u001b[3z"
				else
					formatted_as_gmcp = formatted_as_gmcp..v.text
				end
			end
			mdt_parse_map_door_text(formatted_as_gmcp)
			</send>]]):gsub('\t\t\t', '')
		return xml:gsub('"%s*>',  '">\n' .. code)
	end
	
	ImportXML( get_xml_injection( ExportXML (0, "mdt_map_door_look") ) )
	
end
