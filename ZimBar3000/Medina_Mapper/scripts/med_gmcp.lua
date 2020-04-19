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
        medina_recieve_GMCP(data_line)
    end
end

function medina_recieve_GMCP(text)
    if text:match("^room.info .*") then
        local id = text:match('^.*"identifier":"(.-)".*$')
        --print(id)
        if id == "BPMedina" then medina_enter() else medina_exit() end
    end
end
--------------------------------------------------------------------------------
--   PACKET EVENTS
--------------------------------------------------------------------------------
function OnPluginPacketReceived(pkt)
	--print(pkt)
end
--------------------------------------------------------------------------------
--   PLUGIN COMMUNICATION
--------------------------------------------------------------------------------
function OnPluginBroadcast(msg, id, name, text)
	if msg == 173 then
		medina_update_colours(msg, id, name, text)
	elseif msg == 727 then
		medina_update_fonts(msg, id, name, text)
	end
end
