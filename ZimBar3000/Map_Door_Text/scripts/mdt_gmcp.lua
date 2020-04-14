-------------------------------------------------------------------------------
--  GMCP EVENTS
-------------------------------------------------------------------------------
-- set GMCP connection
function OnPluginTelnetRequest(msg_type, data_line)
    local function send_GMCP(packet) -- send packet to mud to initialize handshake
        assert(packet, "send_GMCP passed nil message")
        SendPkt(string.char(0xFF, 0xFA, 201)..(string.gsub(packet, "\255", "\255\255")) .. string.char(0xFF, 0xF0))
    end
    if msg_type == 201 then
        if data_line == "WILL" then
            return true
        elseif (data_line == "SENT_DO") then
            send_GMCP(string.format('Core.Hello { "client": "MUSHclient", "version": "%s" }', Version()))
            local supports = '"room.info", "room.map", "room.writtenmap", "char.vitals", "char.info"'
            send_GMCP('Core.Supports.Set [ '..utils.base64decode(utils.base64encode(supports))..' ]')
            return true
        end
    end
    return false
end
-- on plugin callback to pick up GMCP
function OnPluginTelnetSubnegotiation(msg_type, data_line)
    if msg_type == 201 and data_line:match("([%a.]+)%s+.*") then
        mdt_recieve_GMCP(data_line)
    end
end
-- on GMPC receipt
function mdt_recieve_GMCP(text)
	local function get_map_name(room_id)
		local map_id = false
		if room_id then
			qdb = sqlite3.open(quowmap_database)
			for t in qdb:nrows("SELECT map_id FROM rooms WHERE room_id = '"..room_id.."'") do 
				map_id = t.map_id 
			end
			qdb:close()
		end
		return mdt.map_ids[map_id] or "Discworld"
	end
	if (string.sub(text, 1, 10) == "room.info ") then	
		table.remove(mdt.sequence, 1)
		table.remove(mdt.commands.move, 1)
		mdt.sequence[1] = text:match('^.*"identifier":"(.-)".*$')
		mdt.title[1] = get_map_name(mdt.sequence[1])
		if mdt.sequence[1] and not mdt.special_areas[mdt.sequence[1]] then
			mdt.title[2] = (text:match('"name":"(.-)"') or "unknown"):gsub("^(%w)", string.upper):gsub("(%s%w)", string.upper)
		end
	elseif (string.sub(text, 1, 9) == "room.map ") then
		mdt_parse_map(text)
    elseif (string.sub(text, 1, 16) == "room.writtenmap ") and 
		mdt.sequence[1] and not mdt.special_areas[mdt.sequence[1]]
	then
		speed_test = os.time()
		text = text:match('"(.*)\\n"') or ""
		map_door_text = text
        mdt_parse_map_door_text(text)
    end
end
-------------------------------------------------------------------------------
--  CROSS-PLUGIN COMMUNICATION
-------------------------------------------------------------------------------
function mdt_special_area_text(special_text_styles, special_title)
	assert(loadstring(special_text_styles))()
	mdt.styles = text_styles
	mdt.title[2] = special_title
	mdt_draw_text(mdt.styles)
end
