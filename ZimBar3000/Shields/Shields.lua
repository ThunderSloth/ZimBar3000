function on_trigger_shields_group_update(name, line, wildcards, styles)
    local sign = name:match("join") and 1 or -1
    local player = wildcards.player
    if player == "You" then
        groupmates.You = {TPA = 0, CCC = 0, EFF = 0, BUG = 0, MS = 0}
    else
        if sign > 0 then
			groupmates[player] = {TPA = 0, CCC = 0, EFF = 0, BUG = 0, MS = 0}
        else
			for i, v in ipairs(groupmates) do
				groupmates[player] = nil
			end
        end
    end
end

function on_trigger_shields_gather(name, line, wildcards, styles)
	group_shields_player = wildcards.player or "You"
end

function shields_get_current_level(line)
	return 1
end

function on_trigger_shields_update(name, line, wildcards, styles)
	local function get_player(player_long)
		if player_long then
			for k in pairs(groupmates) do
				if player_long:match(k) then
					return k
				end
			end
		end
	end
	-- TPA, CCC, EFF, BUG, MS
	local shield = name:sub(10, 12):gsub("_", "")
	local player = get_player(name:sub(14, 14) == "Y"  and "You" or wildcards.player or group_shields_player)
	local status = name:sub(16, 16)
	if player then
		if status == 'D' then -- down
			groupmates[player][shield] = 0
		elseif status == 'A' then -- current level
			groupmates[player][shield] = shields_get_current_level(line)
		elseif status == 'U' then -- up
			groupmates[player][shield] = groupmates[player][shield] + 1
		end
	end
end

groupmates = groupmates or {You = {TPA = 0, CCC = 0, EFF = 0, BUG = 0, MS = 0}}
