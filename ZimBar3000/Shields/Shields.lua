-- add or subtract players to group
function on_trigger_shields_group_update(name, line, wildcards, styles)
    local status, player = wildcards.status, wildcards.player
    if player == "You" then
        groupmates.You = {TPA = 0, CCC = 0, EFF = 0, BUG = 0, MS = 0}
    else
        if status == "joined" then
			groupmates[player] = {TPA = 0, CCC = 0, EFF = 0, BUG = 0, MS = 0}
        else
			for i, v in ipairs(groupmates) do
				groupmates[player] = nil
			end
        end
    end
end
-- log which player preceeding shield lines belong to
-- also add player to group and/or reset their shields
function on_trigger_shields_gather(name, line, wildcards, styles)
	group_shields_player = wildcards.player or "You"
	groupmates[group_shields_player] = {TPA = 0, CCC = 0, EFF = 0, BUG = 0, MS = 0}
end

function shields_get_current_level(line)
	return 1
end
-- update solo/group shields
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
		if shield == "nil" then
			print(player, "none")
			groupmates[player] = {TPA = 0, CCC = 0, EFF = 0, BUG = 0, MS = 0}
		else
			if status == 'D' then -- down
				print(player, shield, "down")
				groupmates[player][shield] = 0
			elseif status == 'A' then -- current level
				print(player, shield, "current level")
				groupmates[player][shield] = shields_get_current_level(line)
			elseif status == 'U' then -- up
				print(player, shield, "up")
				groupmates[player][shield] = groupmates[player][shield] + 1
			end
		end
	end
end



groupmates = groupmates or {You = {TPA = 0, CCC = 0, EFF = 0, BUG = 0, MS = 0}}
