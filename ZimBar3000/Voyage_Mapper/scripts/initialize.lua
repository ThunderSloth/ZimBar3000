--------------------------------------------------------------------------------
--   PLUGIN START
--------------------------------------------------------------------------------
function on_plugin_start()
    require "tprint"
    require "serialize"
    require "words_to_numbers"
    win = "voyage_map"..GetPluginID() -- define window name
    voyage_get_variables()
    voyage_get_windows(voy.colours)
    voyage_window_setup(window_width, window_height, voy.colours)
    voyage_get_hotspots(voy.dimensions)
    rotate_vertical_font(voy.colours)
    voyage_get_triggers(voy.colours)
    voyage_get_timers()
    if (type(window_pos_x) == "number") and (type(window_pos_y) == "number") then
	   WindowPosition(win, window_pos_x, window_pos_y, 0, 2)
    end
    voyage_request_config()
end
--------------------------------------------------------------------------------
--   VARIABLES
--------------------------------------------------------------------------------
function voyage_get_variables()
    defualt_window_width, defualt_window_height = 300, 300
    window_width, window_height = tonumber(GetVariable("window_width") or defualt_window_width), tonumber(GetVariable("window_height") or defualt_window_height)
    window_pos_x, window_pos_y  = tonumber(GetVariable("window_pos_x")), tonumber(GetVariable("window_pos_y"))
    held = {
		L = "", R = "",                                  -- contents or left/right hands
		tools = {},                                      -- saved tools
		containers = {"inventory", "scabbard", "floor"}, -- saved containers
		amo = {                                          -- amo types and respective containers
			["arbalest bolt"]        = "inventory", 
			["fire axe"]             = "floor", 
			["steel-tipped harpoon"] = "floor"}, 
		reload = {L = "", R = ""},                       -- amo/weapon preference                  
		seaweed = "",                                    -- weedwacker preference
		ice = ""}                                        -- icebreaker preference
    assert(loadstring(GetVariable("held") or "")) ()
    voyage_reset_xp() -- time/xp table
    voy = {
        rooms = {                              --(n    ne    e    se    s    sw    w    nw   )          (e    w   )            (u    d  )              (n    ne    e    se    s    sw    w    nw   )
            -- upper deck (starting at nose of boat, moving left to right then downwards):
            {location = {x = 2, y = 1,}, exits = {                se=4,      sw=2            }, doors = {         }, overboard = {n=21,ne=21,e=21,                 w=21,nw=21, overboard = 21,},},
            {location = {x = 1, y = 2,}, exits = {     ne=1,            s=5,                 }, doors = {e=3,     }, overboard = {n=21,                      sw=21,w=21,nw=21, overboard = 21,},},
            {location = {x = 2, y = 2,}, exits = {                                           }, doors = {e=4, w=2,}, },
            {location = {x = 3, y = 2,}, exits = {                      s=7,            nw=1,}, doors = {     w=3,}, overboard = {n=21,ne=21,e=21,se=21,                       overboard = 21,},},
            {location = {x = 1, y = 3,}, exits = {n=2,       e=6, se=9, s=8,                 }, doors = {         }, overboard = {                           sw=21,w=21,nw=21, overboard = 21,}, down = {ne = 15, down = 15,},},
            {location = {x = 2, y = 3,}, exits = {           e=7, se=10,s=9, sw=8, w=5,      }, doors = {         }, },
            {location = {x = 3, y = 3,}, exits = {n=4,                  s=10,sw=9, w=6,      }, doors = {         }, overboard = {     ne=21,e=21,se=21,                       overboard = 21,}, down = {nw = 17, down = 17,},},
            {location = {x = 1, y = 4,}, exits = {n=5, ne=6, e=9,                            }, doors = {         }, overboard = {                se=21,s=21,sw=21,w=21,nw=21},},
            {location = {x = 2, y = 4,}, exits = {n=6, ne=7, e=10,                 w=8, nw=5,}, doors = {         }, overboard = {                se=21,s=21,sw=21,            overboard = 21,},},
            {location = {x = 3, y = 4,}, exits = {n=7,                             w=9, nw=6,}, doors = {         }, overboard = {     ne=21,e=21,se=21,s=21,sw=21,            overboard = 21,},},
            -- lower deck (starting at nose of boat, moving left to right then downwards):
            {location = {x = 5, y = 1,}, exits = {                se=14,    sw=12,           }, doors = {         }, },
            {location = {x = 4, y = 2,}, exits = {     ne=11,           s=15,                }, doors = {e=13,    }, },
            {location = {x = 5, y = 2,}, exits = {                                           }, doors = {     w=12}, },
            {location = {x = 6, y = 2,}, exits = {                      s=17,           nw=11}, doors = {         }, },
            {location = {x = 4, y = 3,}, exits = {n=12,                 s=18,                }, doors = {         }, up =        {     ne=5, e=5, se=5,      sw=5, w=5, nw=5, up=5,},},
            {location = {x = 5, y = 3,}, exits = {                                           }, doors = {e=17,    }, },
            {location = {x = 6, y = 3,}, exits = {n=14,                 s=20,                }, doors = {     w=16}, up =        {     ne=7, e=7, se=7,      sw=7,      nw=7, up=7,},},
            {location = {x = 4, y = 4,}, exits = {n=15,                                      }, doors = {e=19,    }, },
            {location = {x = 5, y = 4,}, exits = {                                           }, doors = {     w=18}, },
            {location = {x = 6, y = 4,}, exits = {n=17                                       }, doors = {         }, },
            -- overboard (surface, under-water):
            {location = {x =3.4, y =1 }, exits = {                                           }, doors = {         }, board =     {n=21,ne=21,e=21,se=21,s=21,sw=21,w=21,nw=21, board = 21,}, down = {down = 22,}},
            {location = {x =3.6, y=1.2}, exits = {                                           }, doors = {         }, up =        {n=21,ne=21,e=21,se=21,s=21,sw=21,w=21,nw=21,up=21},},
            -- mast
            {location = {x = 100, y = 100}, exits = {}, doors = {}, down = {},},},
        colours = voyage_get_colours(),
    }
    voy.position = {}
    for i, v in ipairs(voy.rooms) do
        voy.position[v.location.x] = voy.position[v.location.x] or {}
        voy.position[v.location.x][v.location.y] = i
        voy.rooms[i].look = {look = i}
    end
    -- room identifiers
    local id = {
        "21de9d4c3c3c9b4cd41483937f63c98f20c856c8",
        "549b279912bf26749f193103f5a698d1763c4195",
        "fb106e274d6161cebcbba8dfb256b718f896d800",
        "7061b06e4b2dcc679cbb7f708ff75024c60aa5ad",
        "afe5ba7685f3ad5d6e2c72a1a26a1c4e49c8b121",
        "276f933f8ae0836c030480f9913b5839b99f412c",
        "cc132ec2ee473ae6a3293cc7c07ea34aa573b08a",
        "b6278d2a3a3f2f6ebdf33ba6c37dd21a681aa6ad",
        "300d37af6bc80eeb8b1d85bba0dc9e349bfdb0c5",
        "bb128c612942e5adb1f2568ef0b0ecf95bf435dd",
        "37ceaa9225c6079b6f4c1c1822f6586c8f3562c1",
        "a3acea848c2fb367e7d38792d3a5c58e45aac205",
        "68c73bf8cbd4bdf2d5f056dfb0c4f7f873c43357",
        "7011a9bed74b1a416349e8b251f0d312c1c01311",
        "9af6f1f64b8728b62a572a0540be43110cb109ad",
        "8380ae44a26adabd8cfcc4c66315fccaf375dd96",
        "bb1f4ee5a2a4e1dca0a91559d4934c2710080ffd",
        "8fb3cbee200ce4c47426e357635cf027354a0645",
        "e97301502f9725e070d40542e02b9df68384c223",
        "69785e30295575f22400335deda7284980a8647b",
        "9733e7ccc12d4c9b8e310611cec35c05f0557e3f",
        "2eb7b5e1c41e616f5278cff9bece9c9a6840a274",
        "01cef59ef1d5914600f1cf94d4f3f9fb8f585020",}
    voy.id = {}
    for i, v in ipairs(id) do
        voy.id[v] = i
    end
    voy.re = voyage_get_regex()
    voyage_reset_metatable()
end
--------------------------------------------------------------------------------
--   RESETS
--------------------------------------------------------------------------------
function voyage_reset_metatable()
    for i, v in ipairs(voy.rooms) do
        voy.rooms[i].players = {}             -- players in room
        voy.rooms[i].dragons = {}             -- mobs in room
        if i == 12 then
            voy.rooms[i].dragons["aggy the pale green swamp dragon"   ] = "aggy"
            voy.rooms[i].dragons["idiot the bright red swamp dragon"  ] = "idiot"
        elseif i == 14 then
            voy.rooms[i].dragons["nugget the dark purple swamp dragon"] = "nugget"
            voy.rooms[i].dragons["bitey the sky blue swamp dragon"    ] = "bitey"
        end
        if i == 13 or i == 16 or i == 19 then -- store rooms
            voy.rooms[i].junk = {deck = {}, boilers = {}, fight = {},}
        end
        if i == 6 or i == 13 or i == 16 or 1 == 19 then
            voy.rooms[i].smashed = false      -- status of shelves and mast
        end
        voy.rooms[i].objects = {              -- store room junk
			-- deck
            ropes = 0,
            nails = 0,
            boards = 0,
            hammers = 0,
            buckets = 0,
            towels = 0,
            lemons = 0,
			-- boiler
            tanks = 0,
            rods = 0,
            toys = 0,
            balls = 0,
            polish = 0,
            coal = 0,
            bottles = 0,
			-- combat
            harpoons = 0,
            axes = 0,
            arbalests = 0,
            bolts = 0,
            bandages = 0,
        }
        voy.rooms[i].visable = false          -- is the room in-vision?
        voy.rooms[i].fire    = 0              -- fire in room
        voy.rooms[i].ice     = 0              -- ice in room
        voy.rooms[i].rope    = {}             -- ropes in room
        voy.rooms[i].crate   = {}             -- crates in room
    end
    voy.hull = {                              -- hull conditions
		condition = 0, 
		seaweed   = 0, 
		ice       = 0,} 
    voy.rope = {                              -- upperdeck rope (tied to railing) 
		railing   = false, 
		condition = 0} 
    voy.players   = {}                        -- set of players
    voy.dragons   = {                         -- set of dragons with corresponding colours
        ["aggy the pale green swamp dragon"   ] = voy.colours.dragons.aggy,
        ["idiot the bright red swamp dragon"  ] = voy.colours.dragons.idiot,
        ["nugget the dark purple swamp dragon"] = voy.colours.dragons.nugget,
        ["bitey the sky blue swamp dragon"    ] = voy.colours.dragons.bitey,}
    voy.dragon = {}                           -- dragon attributes
    local dragons = { "aggy", "idiot", "nugget", "bitey", }
    for i, v in ipairs(dragons) do
        voy.dragon[v] = {guage = i, circle = false, asleep = true, hunger = 0, boredom = 0,}
    end
    for k, v in pairs(voy.dragons) do
        local name = string.match(k, "^(%w+)")
        voy.dragon[name].long = k
    end
    voy.doubleclick = {                       -- doubleclick action selected
        options = {
            function() Send("pour buckets on fire" ) end,
            function() Send("nosoul stamp out fire") end,
            function() 
                local ice_tool = held.ice ~= "" and held.ice or "knife"
                Send("break ice with held "..ice_tool) 
            end,
            function() Send("hit dragon with control rod") end,
        }, 
        selected     = 2}
    voy.population   = {}                     -- list of players/mobs present
    voy.lightning    = false                  -- lightning direction
    voy.fire         = {}                     -- contains rooms on fire
    voy.ice          = {}                     -- contains rooms with ice on floor
    voy.kraken       = false                  -- kraken attack and direction
    voy.serpent      = false                  -- serpent attack and direction
    voy.part         = 1                      -- part
    voy.stage        = "Calm"                 -- stage
    voy.look_room    = false                  -- room that is being looked at
    voy.drag = {                              -- for dragging objects
		object       = "tank", 
		on           = false}
    voy.steering     = false                  -- are you holding wheel?
    voy.sea          = false                  -- sea map data
    voy.speed        = 0                      -- speed of ship
    voy.heading      = "H"                    -- top of compass
    voy.direction    = 0                      -- wheel notch
    voy.commands     = {                      -- queued commands
		move         = {count = 0}, 
		look         = {count = 0}}
    voy.sequence     = {}                     -- room trajectory
    voy.sequence[1]  = 7                      -- current room
    voy.is_in_voyage = false                  -- are you on the ship?
    voy.is_night     = false                  -- is it night?
    held.L, held.R   = "", ""                 -- held items
end
--------------------------------------------------------------------------------
--   PLUGIN CALLBACKS
--------------------------------------------------------------------------------
function OnPluginSaveState () -- save variables
	SetVariable("window_width", window_width)
	SetVariable("window_height", window_height)
	SetVariable("window_pos_x", WindowInfo(win, 10))
	SetVariable("window_pos_y", WindowInfo(win, 11))
	SetVariable("held", "held = "..serialize.save_simple(held))
end

function OnPluginInstall() end
function OnPluginEnable() WindowShow(win, true) end   -- show miniwindow on enable
function OnPluginDisable() WindowShow(win, false) end -- hide miniwindow on disable
function OnPluginClose() WindowShow(win, false) end   -- hide miniwindow on close
