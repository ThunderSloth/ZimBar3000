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
        recieve_GMCP(data_line)
    end
end
-- handle GMCP data
function recieve_GMCP(text)
    if text:sub(1, 9) == "char.info" then
		your_name = text:match([["capname":"(%w+)"]])
    end
end
-------------------------------------------------------------------------------
--  MAIN
-------------------------------------------------------------------------------
-- add or subtract players to group
function groupmate_update(name, line, wildcards, styles)
    local status, player = wildcards.status, wildcards.player
    if player == "You" then
        groupmates.You = {TPA = 0, CCC = 0, EFF = 0, BUG = 0, MS = 0}
    else
        if status == "joined" then
			groupmates[player] = {TPA = 0, CCC = 0, EFF = 0, BUG = 0, MS = 0}
        else
			groupmates[player] = nil
        end
    end
end
-- because GMCP only sends name on login this is our secondary method of 
-- grabbing your name
function get_your_name(name, line, wildcards, styles)
	your_name = wildcards.player
end
-- log which player preceeding shield lines belong to
-- also add player to group and/or reset their shields
function start_shields_gather(name, line, wildcards, styles)
	shields_line_player = wildcards.player or "You"
	groupmates[shields_line_player] = {TPA = 0, CCC = 0, EFF = 0, BUG = 0, MS = 0}
end
-- handle shield update triggers for TPA, CCC, EFF, BUG and MS
function shields_update(name, line, wildcards, styles)
	local function get_player_short(long)
		for k in pairs(groupmates) do
			if long:match(k) then
				return k
			end
		end
	end
	local shield, level = name:match("^(%w+)_([^_]+)")
	local player = wildcards.player
	if not player then
		player = "You"
	elseif player == "" then
		player = shields_line_player
	end
	if player == your_name then
		player = "You"
	end
	player = get_player_short(player)
	if player then
		if shield == "ALL" then
			groupmates[player] = {TPA = 0, CCC = 0, EFF = 0, BUG = 0, MS = 0}
		else
			if level == "plus" then
				level = groupmates[player][shield] + 1
			elseif level == "minus" then
				level = groupmates[player][shield] - 1 > 0 and groupmates[player][shield] - 1 or 1
			end
			groupmates[player][shield] = level
		end
	end
	print(player, shield, level)
end
-------------------------------------------------------------------------------
--  START EXECUTION HERE
-------------------------------------------------------------------------------
your_name = your_name or "You"
groupmates = groupmates or {You = {TPA = 0, CCC = 0, EFF = 0, BUG = 0, MS = 0}}
