--------------------------------------------------------------------------------
--  RESET FUNCTIONS
--------------------------------------------------------------------------------
function smugs_reset_rooms()
    smu = {
        id = {
            ["ebff897af2b8bb6800a9a8636143099d0714be07"] = "A",
            ["c0495c993b8ba463e6b3008a88f962ae28084582"] = "B",
            ["501c0b35601b8649c57bb98b8a1d6c2d1f1cea02"] = "C",
            ["8c022638ba642395094bc4dc7ba0a3aaf64c02c1"] = "D",
            ["898b33dcc8da01ef21b064f66062ea2f89235f5f"] = "E",
            ["0b43758d635f631d46b1a1f041fd651e446856ca"] = "F",  --    0 1 2 3 4 5 6 7 8 9 10
            ["1793722d05f49d48f28ce3a49e8b97d59158b916"] = "G",  --   ************************
            ["e28d07530ae163f93ade722c780ce897a4e93a15"] = "H",  -- 0 *                      *
            ["a184520b84e948f89e621ab50a500c47faefa920"] = "I",  --   *                      *
            ["8048df6be9b61c0f49e988924185ce937a38814b"] = "J",  -- 1 *          E-F         *
            ["f026140904d9f0c910b4975b937b20189f225605"] = "K",  --   *         /   \        *
            ["952786ea48134ac3505cbabb6567ef35fad13af8"] = "L",  -- 2 *      C-D     G-H     *
            ["b9bb8741399c7bdf6836cb06148c2e7c4f033853"] = "M",  --   * \   /   \   /   \    *
            ["0663269ccae61f6b313cb378213c74131b394fbc"] = "N",  -- 3 *  A-B     U-V     I   *
            ["03a3ca540e9c7fc9dfa914d213b974a0b207f596"] = "O",  --   *     \   /   \   /    *
            ["3fedc83188999bd20733ba77f02409aee8011127"] = "P",  -- 4 *      S-T  Z  W-J     *
            ["033906622a542f9e0550608b86932dff52d7e8c2"] = "Q",  --   *     /   \   /   \    *
            ["6ef15a8643f1515f8a96fb646dd8e2ab80bade15"] = "R",  -- 5 *    R     Y-X     K   *
            ["ddabfb40040805889125b223a2d679e0a9716fd2"] = "S",  --   *     \   /   \   /    *
            ["468f6243998bda671161e6afe079ff5fac866fc1"] = "T",  -- 6 *      Q-P     M-L     *
            ["372dd28add7bfc7ed26f4da4047a501afcf24696"] = "U",  --   *         \   /        *
            ["d57af869e7ff7abe31ceb1245ccbc6d47df49b7b"] = "V",  -- 7 *          O-N         *
            ["a9734849233e5f97fd676676a9853b22b0cb22e8"] = "W",  --   *                      *
            ["4e6aef2cd732fb35c2c110d768605f4aa56194af"] = "X",  -- 8 *                      *
            ["16a0b8c39025147f9f87cf860b76380af6c9e1d4"] = "Y",  --   ************************
			["886a1404021cdfb21668823aa0ab2cefd05fbcd1"] = "Z",},
        rooms = {                                                
            A = {location = {x = 1, y = 3,}, exits = {e  = "B", nw = "entrance"   ,},},
            B = {location = {x = 2, y = 3,}, exits = {ne = "C", se = "S", w  = "A",},},
            C = {location = {x = 3, y = 2,}, exits = {e  = "D", sw = "B"          ,},},
            D = {location = {x = 4, y = 2,}, exits = {ne = "E", se = "U", w  = "C",},},
            E = {location = {x = 5, y = 1,}, exits = {e  = "F", sw = "D"          ,},},
            F = {location = {x = 6, y = 1,}, exits = {se = "G", w  = "E"          ,},},
            G = {location = {x = 7, y = 2,}, exits = {e  = "H", sw = "V", nw = "F",},},
            H = {location = {x = 8, y = 2,}, exits = {se = "I", w  = "G"          ,},},
            I = {location = {x = 9, y = 3,}, exits = {sw = "J", nw = "H"          ,},},
            J = {location = {x = 8, y = 4,}, exits = {ne = "I", se = "K", w  = "W",},},
            K = {location = {x = 9, y = 5,}, exits = {sw = "L", nw = "J"          ,},},
            L = {location = {x = 8, y = 6,}, exits = {ne = "K", w  = "M"          ,},},
            M = {location = {x = 7, y = 6,}, exits = {e  = "L", sw = "N", nw = "X",},},
            N = {location = {x = 6, y = 7,}, exits = {ne = "M", w  = "O"          ,},},
            O = {location = {x = 5, y = 7,}, exits = {e  = "N", nw = "P"          ,},},
            P = {location = {x = 4, y = 6,}, exits = {ne = "Y", se = "O", w  = "Q",},},
            Q = {location = {x = 3, y = 6,}, exits = {e  = "P", nw = "R"          ,},},
            R = {location = {x = 2, y = 5,}, exits = {se = "Q", ne = "S"          ,},},
            S = {location = {x = 3, y = 4,}, exits = {e  = "T", sw = "R", nw = "B",},},
            T = {location = {x = 4, y = 4,}, exits = {ne = "U", se = "Y", w  = "S",},},
            U = {location = {x = 5, y = 3,}, exits = {e  = "V", sw = "T", nw = "D",},},
            V = {location = {x = 6, y = 3,}, exits = {ne = "G", se = "W", w  = "U",},},
            W = {location = {x = 7, y = 4,}, exits = {e  = "J", sw = "X", nw = "V",},},
            X = {location = {x = 6, y = 5,}, exits = {ne = "W", se = "M", w  = "Y",},},
            Y = {location = {x = 5, y = 5,}, exits = {e  = "X", sw = "P", nw = "T",},},
            Z = {location = {x =5.5,y = 4,}, exits = {                             },},
            entrance = {location = {x=-100, y=-100}, exits = {se = "A"},},
            },
        chambers = {I = true, T = true, N = true,},}
     -- create inverse set of exits
    for k, v in pairs(smu.rooms) do
        smu.rooms[k].path = smu.rooms[k].path or {}
        for r, x in pairs(v.exits) do
            smu.rooms[k].path[x] = r
        end
    end
    smugs_unvisit()
    smugs_depopulate()
end

-- reset mobs/players in a specific room
function smugs_reset_thyngs(room)
	smu.rooms[room].thyngs = {mobs = {captain = 0, smugglers =  0}, players = {}}
	smu.rooms[room].aggro = false
end

-- reset all mobs
function smugs_depopulate()
	for r, _ in pairs(smu.rooms) do
		smugs_reset_thyngs(r)
	end
end

-- reset all
function smugs_unvisit()
    for r, _ in pairs(smu.rooms) do
        smu.rooms[r].visited = false
       	if (tonumber(WindowInfo(win.."overlay", 3) or 0) > 0) and smu.coordinates then -- if overlay has been constructed,
			smugs_draw_room_letter(r, smu.coordinates.rooms[r], smu.colours)
		end
    end
end




