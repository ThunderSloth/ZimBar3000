--------------------------------------------------------------------------------
--   RESET FUNCTIONS
--------------------------------------------------------------------------------
-- default metadata
function medina_reset_rooms()
    med.rooms = {
        A = {exit_rooms = {B = "e", E = "se",D = "s"},                             location = {x = 1, y = 1}}, -- nw exit room
        B = {exit_rooms = {C = "e", E = "s", A = "w"},                             location = {x = 2, y = 1}},
        C = {exit_rooms = {F = "s", B = "w"},                                      location = {x = 3, y = 1}},
        D = {exit_rooms = {A = "n", E = "e", H = "se"},                            location = {x = 1, y = 2}},
        E = {exit_rooms = {B = "n", F = "e", I = "se",D = "w", A = "nw"},          location = {x = 2, y = 2}}, -- five-exit room
        F = {exit_rooms = {C = "n", G = "e", I = "s", E = "w"},                    location = {x = 3, y = 2}},
        G = {exit_rooms = {K = "se",F = "w"},                                      location = {x = 4, y = 2}},
        H = {exit_rooms = {I = "e", L = "se",D = "nw", },                          location = {x = 2, y = 3}},
        I = {exit_rooms = {F = "n", J = "e", M = "se", L = "s",H = "w", E = "nw"}, location = {x = 3, y = 3}}, -- heart
        J = {exit_rooms = {K = "e", N = "se",I = "w"},                             location = {x = 4, y = 3}},
        K = {exit_rooms = {J = "w", G = "nw"},                                     location = {x = 5, y = 3}},
        L = {exit_rooms = {I = "n", M = "e", O = "s",  H = "nw"},                  location = {x = 3, y = 4}},
        M = {exit_rooms = {N = "e", P = "s", L = "w",  I = "nw"},                  location = {x = 4, y = 4}},
        N = {exit_rooms = {Q = "s", M = "w", J = "nw"},                            location = {x = 5, y = 4}},
        O = {exit_rooms = {L = "n", P = "e"},                                      location = {x = 3, y = 5}},
        P = {exit_rooms = {M = "n", Q = "e", O = "w"},                             location = {x = 4, y = 5}},
        Q = {exit_rooms = {N = "n", R = "e", P = "w"},                             location = {x = 5, y = 5}},
        R = {exit_rooms = {Q = "w"},                                               location = {x = 6, y = 5}},} -- se exit room
	for room, _ in pairs(med.rooms) do medina_reset_room(room) end
end
-- reset specific room
function medina_reset_room(room)
    medina_reset_room_exits(room)
    med.rooms[room].visited = false
    medina_reset_thyngs(room)
    if (tonumber(WindowInfo(win.."overlay", 3) or 0) > 0) and med.coordinates then -- if overlay has been constructed,
        medina_draw_room_letter(room, med.coordinates.rooms[room], med.colours) -- reprint letter
    end
end
-- reset all all exit data of a specific toom
function medina_reset_room_exits(room)
    for _, dir in pairs(med.rooms[room].exit_rooms) do
        med.rooms[room].normalized = med.rooms[room].normalized or {}
        med.rooms[room].normalized[dir] = false
    end
    med.rooms[room].solved = false
    med.rooms[room].exits = false
    if room == "A" then med.rooms.A.normalized.nw = "nw" end -- these are the static exits to medina
    if room == "R" then med.rooms.R.normalized.se = "se" end
    if (tonumber(WindowInfo(win.."base", 3) or 0) > 0) and med.coordinates then -- if base layer has been constructed,
        medina_draw_room(room, med.coordinates.rooms[room], med.colours, win.."base") -- redraw room
        medina_draw_room_exits(room, med.coordinates.rooms[room], med.colours, win.."base") -- redraw exits
    end
end
-- reset mobs/players in a specific room
function medina_reset_thyngs(room)
	if type(room) == 'table' then
		for i, r in ipairs(room) do
			med.rooms[r].thyngs = {mobs = {thugs = 0, heavies = 0, boss =  0}, players = {}}
		end
	else
		med.rooms[room].thyngs  = {mobs = {thugs = 0, heavies = 0, boss =  0}, players = {}}
	end
end
-- reset all mobs
function medina_depopulate()
	for r, _ in pairs(med.rooms) do
		medina_reset_thyngs(r)
	end
end
-- reset all visited
function medina_unvisit()
	for r, _ in pairs(med.rooms) do
		med.rooms[r].visited = false
		if (tonumber(WindowInfo(win.."overlay", 3) or 0) > 0) and med.coordinates then -- if overlay has been constructed,
			medina_draw_room_letter(r, med.coordinates.rooms[r], med.colours) -- reprint letter
        end
	end
end
