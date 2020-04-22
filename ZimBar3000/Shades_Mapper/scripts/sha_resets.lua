--------------------------------------------------------------------------------
--   RESET FUNCTIONS
--------------------------------------------------------------------------------
function shades_reset_rooms()
   --[[1 2 3 4 5
     **************
    1*     A-B<-  *
     *    /|x|\ \ *
    2*   C-D-E-F )*
     *  /|x|x|x|/ *
    3*-G-H-I-J-K  *
     *  \|x|x|x|\ *
    4*   L-M-N-O )*
     *    \|x|/ / *
    5*     P-Q<-  *
     **************]]    
    sha = {
        rooms = {--      ( 1    2    3    4    5    6    7    8  )               (n    ne    e    se    s    sw    w    nw   )
            A = {exits = {"E", "C", "D", "B",                    }, normalized = {           e=4, se=1, s=3, sw=2,           }, location = {x = 3, y = 1,}, },
            B = {exits = {"F", "A", "E", "D",                    }, normalized = {                se=1, s=3, sw=4, w=2,      }, location = {x = 4, y = 1,}, },
            C = {exits = {"G", "I", "D", "H", "A",               }, normalized = {     ne=5, e=3, se=2, s=4, sw=1,           }, location = {x = 2, y = 2,}, },
            D = {exits = {"H", "C", "E", "I", "J", "A", "B",     }, normalized = {n=6, ne=7, e=3, se=5, s=4, sw=1, w=2,      }, location = {x = 3, y = 2,}, },
            E = {exits = {"I", "K", "J", "D", "A", "F", "B",     }, normalized = {n=7,       e=6, se=2, s=3, sw=1, w=4, nw=5,}, location = {x = 4, y = 2,}, },
            F = {exits = {"K", "E", "B", "J",                    }, normalized = {                      s=1, sw=4, w=2, nw=3,}, location = {x = 5, y = 2,}, },
            G = {exits = {"C", "L", "H",                         }, normalized = {     ne=1, e=3, se=2,                      }, location = {x = 1, y = 3,}, },
            H = {exits = {"G", "D", "M", "C", "L", "I",          }, normalized = {n=4, ne=2, e=6, se=3, s=5,       w=1,      }, location = {x = 2, y = 3,}, },
            I = {exits = {"C", "H", "D", "E", "M", "L", "J", "N",}, normalized = {n=3, ne=4, e=7, se=8, s=5, sw=6, w=2, nw=1,}, location = {x = 3, y = 3,}, },
            J = {exits = {"K", "D", "E", "I", "M", "N", "O", "F",}, normalized = {n=3, ne=8, e=1, se=7, s=6, sw=5, w=4, nw=2,}, location = {x = 4, y = 3,}, },
            K = {exits = {"N", "J", "E", "Q", "O", "F", "B",     }, normalized = {n=6, ne=7,      se=4, s=5, sw=1, w=2, nw=3,}, location = {x = 5, y = 3,}, },
            L = {exits = {"G", "I", "M", "H", "P",               }, normalized = {n=4, ne=2, e=3, se=5,                 nw=1,}, location = {x = 2, y = 4,}, },
            M = {exits = {"L", "I", "J", "H", "N", "P", "Q",     }, normalized = {n=2, ne=3, e=5, se=7, s=6,       w=1, nw=4,}, location = {x = 3, y = 4,}, },
            N = {exits = {"J", "K", "M", "I", "P", "O", "Q",     }, normalized = {n=1, ne=2, e=6,       s=7, sw=5, w=3, nw=4,}, location = {x = 4, y = 4,}, },
            O = {exits = {"Q", "N", "K", "J",                    }, normalized = {n=3,                       sw=1, w=2, nw=4,}, location = {x = 5, y = 4,}, },
            P = {exits = {"N", "M", "L", "Q",                    }, normalized = {n=2, ne=1, e=4,                       nw=3,}, location = {x = 3, y = 5,}, },
            Q = {exits = {"P", "M", "N", "O",                    }, normalized = {n=3, ne=4,                       w=1, nw=2,}, location = {x = 4, y = 5,}, },
        }}
    for k, v in pairs(sha.rooms) do -- create inverse set of exits
        sha.rooms[k].path = sha.rooms[k].path or {}
        for r, x in pairs(v.exits) do
            sha.rooms[k].path[x] = r
        end
    end
    shades_unvisit()
    shades_depopulate()
end
-- reset visited rooms
function shades_unvisit()
    for r, _ in pairs(sha.rooms) do
        sha.rooms[r].visited = false
        if (tonumber(WindowInfo(win.."overlay", 3) or 0) > 0) and sha.coordinates then -- if overlay has been constructed,
			shades_draw_room_letter(r, sha.coordinates.rooms[r], sha.colours)
        end
    end
end

-- reset mobs/players in a specific room
function shades_reset_thyngs(room)
	if type(room) == 'table' then
		for i, r in ipairs(room) do
			sha.rooms[r].thyngs = {mobs = {trolls = 0, fighters = 0, muggers =  0}, players = {}}
		end
	else
		sha.rooms[room].thyngs = {mobs = {trolls = 0, fighters = 0, muggers =  0}, players = {}}
	end
end
-- reset all mobs
function shades_depopulate()
	for r, _ in pairs(sha.rooms) do
		shades_reset_thyngs(r)
	end
end

function on_alias_shades_reset()
    shades_unvisit()
    shades_depopulate()
    shades_print_map()
end

