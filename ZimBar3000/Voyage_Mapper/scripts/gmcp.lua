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
        voyage_recieve_GMCP(data_line)
    end
end
-- on GMPC receipt
function voyage_recieve_GMCP(text)
    if text:match("^char.vitals .*") and (voy.is_in_voyage or xp_t.need_final) then
        local xp = tonumber(text:match('"xp":(%d+)'))
        voyage_update_xp(xp)
        voyage_update_final_xp(xp)
    elseif text:match("^room.info .*") then
        local id = text:match('^.*"identifier":"(.-)".*$')
        --print(id)
        local room = voy.id[id]
        if room then
            voyage_enter()
            voyage_move_room(room)
        else
            voyage_exit()
            WindowShow(win, false)
        end
    end
    if (string.sub(text, 1, 16) == "room.writtenmap ") and voy.is_in_voyage then
        --print(text)
        voyage_parse_written_map(text, voy.re)
    end
end
