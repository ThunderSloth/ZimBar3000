--[[ Zimbus's
   _____             .___.__                   _____                                    ._.
  /     \   ____   __| _/|__| ____ _____      /     \ _____  ______ ______   ___________| |
 /  \ /  \_/ __ \ / __ | |  |/    \\__  \    /  \ /  \\__  \ \____ \\____ \_/ __ \_  __ \ |
/    Y    \  ___// /_/ | |  |   |  \/ __ \_ /    Y    \/ __ \|  |_> >  |_> >  ___/|  | \/\|
\____|__  /\___  >____ | |__|___|  (____  / \____|__  (____  /   __/|   __/ \___  >__|   __
        \/     \/     \/         \/     \/          \/     \/|__|   |__|        \/       \]]
--------------------------------------------------------------------------------
--   INSTALL AND SAVE
--------------------------------------------------------------------------------
function on_plugin_start()
    require "tprint"
    require "serialize"
    win = "medina_map"..GetPluginID() -- define window name
    medina_get_variables()
    medina_get_regex()
    medina_get_triggers()
    medina_get_windows()
    medina_window_setup(window_width, window_height) -- define window attributes
    medina_get_hotspots(med.dimensions)
    if (type(window_pos_x) == "number") and (type(window_pos_y) == "number") then
	   WindowPosition(win, window_pos_x, window_pos_y, 0, 2)
    end
    --medina_get_timers()
end

function medina_get_variables() -- load variables
    defualt_window_width, defualt_window_height = 300, 300
    window_width, window_height = tonumber(GetVariable("window_width") or defualt_window_width), tonumber(GetVariable("window_height") or defualt_window_height)
    window_pos_x, window_pos_y = tonumber(GetVariable("window_pos_x")), tonumber(GetVariable("window_pos_y"))
    assert(loadstring(GetVariable("med") or ""))()
    if not med then med = {}; medina_reset_rooms() end
    med.exit_counts = medina_get_exit_counts(med.rooms)
    med.colours = medina_get_colours()
    med.players = {} -- set containing playernames with associated colour
    med.sync = {received = false, data = {}, is_valid = false}
    med.commands = {move = {count = 0}, look = {count = 0}}
    med.sequence = {}
    med.is_in_medina = false
end

function OnPluginSaveState () -- save variables
	SetVariable("med", "med = "..serialize.save_simple(med))
	SetVariable("window_width", window_width)
	SetVariable("window_height", window_height)
	SetVariable("window_pos_x", WindowInfo(win, 10))
	SetVariable("window_pos_y", WindowInfo(win, 11))
end

function OnPluginInstall() end
function OnPluginEnable() WindowShow(win, true) end -- show miniwindow on enable
function OnPluginDisable() WindowShow(win, false) end -- hide miniwindow on disable
function OnPluginClose() WindowShow(win, false) end -- hide miniwindow on close
--------------------------------------------------------------------------------
--   MINIWINDOW SETUP
--------------------------------------------------------------------------------
function medina_get_windows()
    local col = med.colours.window
    WindowCreate(win.."copy_from", 0, 0, 0, 0, miniwin.pos_center_all, 0, col.transparent) -- for loading images
    WindowCreate(win.."base", 0, 0, 0, 0, miniwin.pos_center_all, 0, col.transparent) -- base: room structure, static objects and bmp images
    WindowCreate(win, 0, 0, 0, 0, miniwin.pos_center_all, 0, med.colours.window.background) -- load dummy window -- display window: only dynamic objects will be printed directly here
    WindowCreate(win.."overlay", 0, 0, 0, 0, miniwin.pos_center_all, 0, col.transparent) --overlay: room-letters
    WindowSetZOrder(win, 200)
end

function medina_get_hotspots(dim) -- dimensions
    WindowAddHotspot(win, "title",
         0, 0, dim.window.x, dim.font.title, 
         "",   -- MouseOver
         "",   -- CancelMouseOver
         "mousedown",
         "cancelmousedown", 
         "mouseup", 
        "Left-click to drag!", -- tooltip text
         1, 0)  -- hand cursor
    WindowDragHandler(win, "title", "dragmove", "dragrelease", 0)
    -- add handler for resizing
    WindowAddHotspot(win, "resize", dim.window.x - 10, dim.window.y - 10, dim.window.x, dim.window.y, "MouseOver", "CancelMouseOver", "mousedown", "", "MouseUp", "Left-click to resize!", 6, 0)
    WindowDragHandler(win, "resize", "ResizeMoveCallback", "ResizeReleaseCallback", 0)
    for r, v in pairs(med.rooms) do
        local coor = med.coordinates.rooms[r].room.outter
        WindowAddHotspot(win, r,
             coor.x1, coor.y1, coor.x2, coor.y2,
             "",   
             "",  
             "mousedown",
             "cancelmousedown", 
             "mouseup", 
             '', 
             1, 0) 
    end
end

function medina_window_setup(window_width, window_height) -- define window attributes
    
    local function get_window_dimensions(window_width, window_height)
        med.dimensions = {}
        med.dimensions.window = {
            x = window_width, 
            y = window_height}
        med.dimensions.buffer = {
            x = window_width  * .05, 
            y = window_height * .05}
        med.dimensions.map = {
            x = window_width  - med.dimensions.buffer.x * 2, 
            y = window_height - med.dimensions.buffer.y * 2}
        med.dimensions.block = {
            x = med.dimensions.map.x/6, 
            y = med.dimensions.map.y/6} 
        med.dimensions.room = {
            x = med.dimensions.block.x * .5, 
            y = med.dimensions.block.y * .5}
        med.dimensions.exit = {
            x = (med.dimensions.block.x - med.dimensions.room.x) / 2, 
            y = (med.dimensions.block.y - med.dimensions.room.y) / 2}
        return med.dimensions
    end

    local function get_room_coordinates(dim) --dimensions

        local function get_exit_coordinates(dim, k, v, origin)

            local function give_direction(exit)
                if exit == "n" then return 0, 1 end
                if exit == "ne" then return 1, 1 end
                if exit == "e" then return 1, 0 end
                if exit == "se" then return 1, -1 end
                if exit == "s" then return 0, -1 end
                if exit == "sw" then return -1, -1 end
                if exit == "w" then return -1, 0 end
                if exit == "nw" then return -1, 1 end
            end

            med.coordinates.rooms[k].exit = {}
            local exit_center = {}
            for dir, _ in pairs(v.normalized) do
                local x_dir, y_dir = give_direction(dir) 
                local exit_center = {
                    x = origin.x + ((dim.room.x + dim.exit.x) / 2) * x_dir,
                    y = origin.y + ((dim.room.y + dim.exit.y) / 2) *-y_dir,}
                local x1 = exit_center.x - dim.exit.x/2
                local y1 = exit_center.y - dim.exit.y/2
                local x2 = exit_center.x + dim.exit.x/2
                local y2 = exit_center.y + dim.exit.y/2
                med.coordinates.rooms[k].exit[dir] = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
            end
        end

        local function get_letter_coordinates(dim, k, v, origin)
            local width = WindowTextWidth(win, "larger", k)
            local x1 = origin.x - (dim.room.x / 2) + (dim.room.x - width) / 2
            local y1 = origin.y - (dim.room.y / 2) + (dim.room.y - dim.font.larger) / 2
            local x2, y2 = 0, 0
            med.coordinates.rooms[k].letter = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
        end

        med.coordinates = {rooms = {}, title_text = {}, exit_text = {}}
        med.coordinates.title_text.y1 = ((dim.font.title * 1.1) - dim.font.title) / 2
        med.coordinates.exit_text.y1  = dim.buffer.y + dim.block.y * 5.5
        for k, v in pairs(med.rooms) do
            med.coordinates.rooms[k] = {}
            med.coordinates.rooms[k].room = {outter = {}, inner = {}}
            local room_center = {
                x = dim.buffer.x + (v.location.x * dim.block.x) - (dim.block.x / 2),
                y = dim.buffer.y + (v.location.y * dim.block.y)}
            local x1 = room_center.x - (dim.room.x / 2)
            local y1 = room_center.y - (dim.room.y / 2)
            local x2 = room_center.x + (dim.room.x / 2)
            local y2 = room_center.y + (dim.room.y / 2)
            med.coordinates.rooms[k].room.outter = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
            get_exit_coordinates(dim, k, v, room_center)
            get_letter_coordinates(dim, k, v, room_center)
            x1 = room_center.x - ((dim.room.x * .75) / 2)
            y1 = room_center.y - ((dim.room.y * .75) / 2)
            x2 = room_center.x + ((dim.room.x * .75) / 2)
            y2 = room_center.y + ((dim.room.y * .75) / 2)
            med.coordinates.rooms[k].room.inner  = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
        end
    end

    local function resize_windows(dim) -- dimensions
        local col = med.colours.window
        WindowResize(win.."copy_from", dim.exit.x - 4, dim.exit.y - 4, miniwin.pos_center_all, 0, col.transparent) -- for loading images
        WindowResize(win.."base", dim.window.x, dim.window.y, miniwin.pos_center_all, 0, col.transparent) -- base: room structure, static objects and bmp images
        WindowResize(win, dim.window.x, dim.window.y, col.background) -- display window: only dynamic objects will be printed directly here
        WindowResize(win.."overlay", dim.window.x, dim.window.y, miniwin.pos_center_all, 0, col.transparent) --overlay: room-letters
    end

    local function get_font(dim) -- dimensions
        med.dimensions.font = {}
        local f_tbl = utils.getfontfamilies ()
        local font = {false, false}
        local choice = {
            {"System", "Fixedsys", "Arial"},  -- choices for font 1 (title)
            {"Dina", "Arial", "Helvetica"}    -- choices for font 2
        }
        for i, t in ipairs(choice) do -- if our chosen font exists then pick it
            for ii, f in ipairs(t) do
                if f_tbl[f] then
                    font[i] = f
                    break
                end
            end
        end
        for i, f in ipairs(font) do -- if none of our chosen fonts are avaliable, pick the first one that is
            if not f then
                for k in pairs(f_tbl) do
                    font[i] = k
                    break
                end
            end
        end
        assert(font[1] and font[2], "Fonts not loaded!")
        for c, p in pairs({title = 150 / 11, larger = dim.room.y}) do
            local max = 200
            local h, s = 0, 1
            local f = c == "title" and font[1] or font[2]
            while (h < p) and (s < max) do
                assert(WindowFont(win, c, f, s, false, false, false, false), tostring(win).." "..tostring(c).." "..tostring(f).." "..tostring(s))
                h = tonumber(WindowFontInfo(win, c, 1)) or h or 0
                if h > p then
                    s = (s - 1) > 1 and (s - 1) or 1
                    assert(WindowFont(win, c, f, s, false, false, false, false), tostring(win).." "..tostring(c).." "..tostring(f).." "..tostring(s))
                    h = tonumber(WindowFontInfo(win, c, 1)) or h or 0
                    break
                end
                s = s + 1
            end
            for _, mw in ipairs({win.."base", win.."underlay", win.."overlay"}) do
                assert(WindowFont(mw, c, f, s, false, false, false, false), tostring(mw).." "..tostring(c).." "..tostring(f).." "..tostring(s))
                med.dimensions.font[c] = h or 0
            end
        end
    end

    local function get_images(dim) -- dimensions
        file_path = (GetPluginInfo(GetPluginID(), 6)):match("^(.*\\).*$")
        local dir = {"n", "ne", "e", "se", "s", "sw", "w", "nw"}
        for _, v in ipairs(dir) do
            WindowLoadImage (win.."copy_from", v, file_path.."arrows\\"..v..".bmp")
            WindowDrawImage(win.."copy_from", v, 0, 0, dim.exit.x - 4, dim.exit.y - 4, 2)
            WindowImageFromWindow(win.."base", v, win.."copy_from")
        end
    end
    local dimensions, colours = get_window_dimensions(window_width, window_height), med.colours
    resize_windows(dimensions)
    get_font(dimensions)
    get_room_coordinates(dimensions)
    get_images(dimensions)
    medina_draw_base(dimensions, colours)
    medina_draw_overlay(dimensions, colours)
end

function medina_get_colours()
    col = {
        window = {
            background = "black",
            border =     "white",
            transparent ="teal",},
        title = {
            text =       "black",
            border =     "white",
            fill =       "lightgray",},
        rooms = {
            solved =     "white",
            unsolved =   "red",
            ghost =      "yellow",
            herd_path =  "blue",
            look =       "white", 
            scry =       "white",
            visited =    "gray",
            unvisited =  "lightblue",},
        exits = {
            solved =     "gray",
            unsolved =   "red",
            halfsolved = "gray",
            herd_path =  "blue",
            static =     "white",
            bracket =    "white",
            comma =      "white",},
        thyngs = {
            you =        "yellow",
            boss =       "fuchsia",
            heavy =      "yellow",
            thug =       "white",
            xp = {"#003300", "#004c00", "#006600", "#007f00", "#009900", "#00b200", "#00cc00", "#00e500", "#00ff00",},
            players =    "blue",
            others =     "gray",},
        note = {
            bracket =    "white",
            error =      "red",
            text =       "gray",},}
    for k, v in pairs(col) do
        for kk, c in pairs(v) do
            if type(c) == 'string' then
                col[k][kk] = ColourNameToRGB(c)
            else
                for i, cc in ipairs(c) do
                   col[k][kk][i] = ColourNameToRGB(cc) 
                end
            end
        end
    end
    return col
end
--------------------------------------------------------------------------------
--   RESET FUNCTIONS
--------------------------------------------------------------------------------
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

function medina_reset_room(room)
    medina_reset_room_exits(room)
    med.rooms[room].visited = false
    medina_reset_thyngs(room)
    if (tonumber(WindowInfo(win.."overlay", 3) or 0) > 0) and med.coordinates then -- if overlay has been constructed,
        medina_draw_room_letter(room, med.coordinates.rooms[room], med.colours) -- reprint letter
    end
    --DeleteTimer(room) --delete expiration timer
end

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

function medina_reset_thyngs(room)
	if type(room) == 'table' then
		for i, r in ipairs(room) do
			med.rooms[r].thyngs = {mobs = {thugs = 0, heavies = 0, boss =  0}, players = {}}
		end
	else
		med.rooms[room].thyngs  = {mobs = {thugs = 0, heavies = 0, boss =  0}, players = {}}
	end
end
--------------------------------------------------------------------------------
--   REGULAR EXPRESSIONS
--------------------------------------------------------------------------------
function medina_get_regex()
	regex = {
		verbiage = rex.new(" (?<verbiage>(is|are) \\w*?ing ([io]n the \\w*? )?here[. ])"),
		titles   = rex.new(
[[(?(DEFINE)
(?# GUILDS: )
(?'assassins'(d(octo)?r|professor))
(?'priests'((?(?=blessed|venerable|holy)(blessed|venerable|holy)( (brother|sister|father|mother))?|(brother|sister|father|mother))|(mostly )?reverend|blessed|beatus|saint|high priest(ess)?|(his|her|it'?s) eminence|minister|outcast))
(?'thieves'(crafty|crooked|dastardly|dishonest|dodgy|elusive|evasive|furtive|greased|honest|latent|((light|quick)[-]|butter)?finger(ed|s)|quiet|shady|shifty|silent|slick|sly|tricky))
(?'witches'(?# duplicates: mother, old, mistress, sister)((?# goodie, goody)good(y|ie)|gammer|gra(mma|nny)|(?# mss, mee)m[se]{2}|(?# nanny, nanna)nann[ay]|aunty|biddy|black|mama|wee|wicked|young))
(?'wizards'(fat|stuffed|overfed|gimlet[-]eyed|robust|bearded|burly|plump|rotund|thin|tiny|mystic|obscure|complex|learned|potent|wise|grumpy|cryptic|dark|scholarly|grey[-]?(haired|beard)|adroit|dire|maven|quantum|savant|unseen|(arch)?(master|mistress|mage)))
(?# COUNCIL: )
(?'council_am'(dame|lady|lord|sir)) 
(?'court_positive'the (amazing|civic[-]minded|elegant|eloquent|(helpful|upstanding(?= citizen))( citizen)?|stylish|utterly fluffy|wonderful))
(?'court_punishment'(appallingly filthy|corpse looter|dull|feebleminded|i (promise i won't do it again|got punished( and all i got was this lousy title)?)|insignificant|lying|malingering|naughty spawn|necrokleptomaniac|offensive|pillock|pointless|repentant|reprobate|shopkeeper murderer|silly spammy git|sitting in the corner|smelly|tantrum thrower|too stupid to live|vagrant|(very ){1,2}sorry|waste of space|whinging))
(?'council_djb'(?# duplicates: feebleminded, corpse looter, cowardly)(sultana?|(shai|sitt) (al[-](khasa|ri'asa)|ishqu?araya|a'daha)|nawab|qasar|mazrat|effendi|ya'uq|mutasharid|ishqu?araya|naughty spawn|kill stealer|idiotic|offensive|corpse looter|cat hating|heathen|foreign dog|infidel|shopkeeper murderer|destitute|parasitic|hated|cowardly|criminal|felon))
(?# ACHIEVEMENTS: )
(?'achievements_thieves'(ruinous|fingers))
(?'achievements_warriors'(centurion|chef|head(master|mistress)|impaler|pulveriser))
(?'achievements_witches'(destined|nasty|terrible))
(?'achievements_fools'pious)
(?'achievements_wizards'(erratic mechanic|mysterious|arcana))
(?'achievements_priests'(templar|healer|saintly))
(?'achievements_assassins'(lethal|venomous))
(?'achievements_all'(?# axe-master, shieldmaster/mistress, staffmaster/mistress)((sword|shield|staff|axe[-])(master|mistress)|antiquated|archaic|old( (wo)?man)?|bloodthirsty|bruiser|champion|competent|contender|crimewave|crusher|cultured|cutthroat|deckhand|decrepit|diplomatic|duelist|elementalist|energetic|exterminator|festive|filthy|flatulent|fossilized|gifted|golden|knifey|legendary|literate|masterful|medical|miner|multilingual|[nm]urse|mythical|nimble|obsolete|opulent|paranoid|perverse|prehistoric|rock[-]hard|rouge|senile|captain|stormrider|unburiable|unexpected|unlucky|unstoppable|venerable|versatile|virtuoso|wealthy))
(?'quest_points'(well travelled|persistent))
(?# MISC: )
(?'general'm([sx]|rs?|iss))
(?'genua'(?# m, monsieur, mlle, mademoiselle, mme, madame)m(?=(\Z|$| |me|lle|onsieur|adame|ademoiselle))(me|lle|onsieur|adame|ademoiselle)?)
(?'ghosts'(lonely|mournful|scary|spooky|wandering))
(?'musketeers'(cheating|cowardly))
(?'debaters'(diplomatic|uncreative)))(?#
 TITLE REGEX: 
)^(?<title>(?P>assassins)|(?P>priests)|(?P>thieves)|(?P>witches)|(?P>wizards)|(?P>council_am)|(?P>court_positive)|(?P>court_punishment)|(?P>council_djb)|(?P>achievements_thieves)|(?P>achievements_warriors)|(?P>achievements_witches)|(?P>achievements_fools)|(?P>achievements_wizards)|(?P>achievements_priests)|(?P>achievements_assassins)|(?P>achievements_all)|(?P>quest_points)|(?P>general)|(?P>genua)|(?P>ghosts)|(?P>musketeers)|(?P>debaters)) ]])
}
end
--------------------------------------------------------------------------------
--   CONSTRUCT TRIGGERS
--------------------------------------------------------------------------------
function medina_get_triggers()
    local desc = {
        title = "(?<title>\\[somewhere in an alleyway\\])",
        scry  = "(?<scry>(The crystal ball changes to show a vision of the area where .* is|The image in the crystal ball fades, but quickly returns showing a new area|You see a vision in the .*|You look through the .* (door|fur)|You see a vision in the silver mirror|You see):|You focus past the .* baton, and visualise the place you remembered...|You briefly see a vision.)",
        look  = "(?<look>.*)",
        moon  = "((It is night and|The (water|land) is lit up by) the.*(?<moon>(crescent|(three )?quarter|half|gibbous|no|full) moon)( is hidden by the clouds)?.\\n)?",
        long  = {
            "This is a small winding alleyway, and there are other alleys leading off it.  They are all small and winding too.  The walls are too high to see over, and buildings block your view in all directions.  A person could easily get lost in here unless they had a good memory, or a map.",
            "Standing in an alleyway, surrounded by buildings and other alleys, your head spins as you struggle to get your bearings.  You fail miserably.  Alleys lead in several directions.",
            "The alleyway gets very narrow here. There are other alleys leading off it.  They are all small and winding too.  The walls are too high to see over, and buildings block your view in all directions.  A person could easily get lost in here unless they had a good memory, or a map.",
            "This is a small winding alleyway with a T-junction.  All three possible exits look very similar and very alley-ly.  The alleys are narrow, winding and difficult to navigate safely without a map.",
            "You are standing in a small winding alleyway.  There are other alleys leading off it.  They are all small and winding too.  The walls are too high to see over, and buildings block your view in all directions.  A person could easily get lost in here unless they had a good memory, or a map.",
            "This is a cross alleyways.  Like a cross-roads, but with alleyways.  They go this way and that.  You can't work out which way is north and you wish you'd brought a compass.",
            "At least at this point in the maze your decision is simple.  Either go that way, or that way.  The alleyway simply bends here, and you can continue or go back.  It's entirely up to you.",
            "You are standing in a small winding alleyway.  There are other alleys leading off it.  They are all small and winding too.  The walls are too high to see over, and buildings block your view in all directions.  A person could easily get lost in here unless they had a good memory, or a map.",
            "In the heart of the Red Triangle maze, alleys lead in all directions, and you are unsure which way to turn.  Six alleys meet here, or possibly, depending on your point of view leave from here.  Either way, there are a lot of possible exits.",
            "Three alleyways merge here.  They all look the same, and all go in different directions.  Small buildings line the alleyways.  The exit ahead of you looks familiar, or does it\\?",
            "Isn't this the same place you were in 5 minutes ago\\?  Maybe not.  But perhaps it is, who knows\\?  The alleyway bends here and you have a choice of two identical exits.",
            "As an Empire the Aurient is complex and easy to get lost in.  This set of alleyways could easily be a metaphor for the whole of Agatea.  They are complex and, you've guessed it, easy to get lost in.",
            "You are standing in a small winding alleyway.  There are other alleys leading off it.  They are all small and winding too.  The walls are too high to see over, and buildings block your view in all directions.  A person could easily get lost in here unless they had a good memory, or a map.",
            "duplicate: H or N",
            "You are standing in a small winding alleyway.  There are other alleys leading off it.  They are all small and winding too.  The walls are too high to see over, and buildings block your view in all directions.  A person could easily get lost in here unless they had a good memory, or a map.",
            "You are standing in a small winding alleyway.  There are other alleys leading off it.  They are all small and winding too.  The alley leads north and south.  Or is it east and west\\?  You are completely unsure.",
            "The alleys twist and turn, until you eventually arrive here.  Here is nowhere special, just another junction within the maze of alleys in the Red Triangle.",
            "This is a small winding alleyway, dark and with other alleys leading off it.  They are all small and winding too.  The walls are too high to see over, and buildings block your view in all directions.  A person could easily get lost in here unless they had a good memory, or a map.",
            "Somewhere in an alleyway.  It's dark here, isn't it\\?"
        },
        extra1   = "(?<extra1>.*\\n)?",
        extra2   = "(?<extra2>.*\\n)?",
        weather1 = "(?<weather1>It is an? .*)\\n",
        weather2 = "(?<weather2>(?!.* obvious exits:).*\\n)?",
        exits    = {4, 3, 2, 3, 5, 4, 2, 3, 6, 3, 2, 4, 4, 3, 2, 3, 3, 2,},
        thyngs   = "(\\n(?<thyngs>.* here.))?\\Z"
    }
    desc.not_moon = desc.moon:gsub("[(][?]<moon>[(]crescent|[(]three [)][?]quarter|half|gibbous|no|full[)] moon[)]", "moon"):gsub("\\n[)][?]", ")"):gsub("^[(]", "(?!")

    local triggers = {}
    for i = 1, 19 do
        local letter = string.char(i + 64)
        local regex = '^('..desc.title..'|'..desc.scry..'|'..desc.not_moon..desc.look..')\\n'
        local count = 1
        local order = {'moon', 'long', 'extra1', 'extra2', 'weather1', 'weather2', 'exits', 'thyngs'}
        for _, v in ipairs(order) do
            if type(desc[v]) == 'table' then
                if v == 'exits' then
                    local n = desc.exits[i]
                    local exits = ''
                    if n then
                        local num = {'one', 'two', 'three', 'four', 'five', 'six', 'seven'}
                        exits = '(?<exits>There are (?(?=.* enter door.)'..(num[n + 1])..'|'..(num[n])..') obvious exits: .*)'
                    else
                        exits = '(?<exits>There are \\w+ obvious exits: .*)'
                    end
                    regex = regex..exits
                else
                    regex = regex..desc[v][i]..'\\n'
                end
            else
                regex = regex..desc[v]
            end
            count = count + 1
        end
        local name = letter
        local script = 'on_trigger_medina_room'
        if name == 'H' then
            name = 'H_or_N'
        elseif i == 19 then
            name = 'dark_room'
            script = 'on_trigger_medina_dark_room'
        end
        triggers[i] = {
            match = regex,
            group ='medina',
            name = 'medina_room_'..name,
            script = script,
            multi_line = 'y',
            count = count,
            keep_evaluating = 'y',
            regexp = 'y',
            sequence = 100,}
    end
	
	triggers[14] = {} -- remove duplicate (H or N)
	
	local function get_xml_injection(xml)
		local code = ([[
			<send>
			if "%%&lt;thyngs&gt;" ~= '' then
			  local n = GetLinesInBufferCount()
			  local styles = GetStyleInfo (n)
			  n = n - 1
			  while not GetLineInfo(n, 3) do	
			    local t = GetStyleInfo (n)
			    if type(t) == 'table' then
				  for i, v in ipairs(t) do
				    if i == #t and styles[i].textcolour == v.textcolour then
				      styles[i].text = v.text..styles[i].text
				      styles[i].length = styles[i].length + v.length
				    else
				      table.insert(styles, i, v)
				    end
				  end
				end
				n = n - 1
			    if n == -1000 then break end
			  end
			  for i, v in ipairs(styles) do
				if GetNormalColour(8) ~= v.textcolour then
			        med.players[string.lower(Trim(v.text))] = v.textcolour
			    end
			  end
			end
			</send>]]):gsub('\t\t\t', '')
		return xml:gsub('"%s*>',  '">\n' .. code)
	end
	
    ImportXML ( get_xml_injection( ExportXML (0, "medina_mob_enter") ) )
	ImportXML ( get_xml_injection( ExportXML (0, "medina_mob_exit" ) ) )
    
    for _, v in pairs(triggers) do
        if v.match then
            AddTrigger(v.name, v.match, "", trigger_flag.KeepEvaluating + trigger_flag.IgnoreCase + trigger_flag.RegularExpression, custom_colour.NoChange, 0, "", v.script)
            SetTriggerOption (v.name, "group", v.group)
            SetTriggerOption (v.name, "multi_line", "y")
            SetTriggerOption (v.name, "lines_to_match", v.count)
            SetTriggerOption (v.name, "enabled", "n")
            SetTriggerOption (v.name, "sequence", sequence)
			SetTriggerOption (v.name, "send_to", 12)
            local trig = get_xml_injection( ExportXML (0, v.name) )
            ImportXML (trig); -- print(trig)
        end
    end
end
--------------------------------------------------------------------------------
--   HOTSPOT HANDLERS
--------------------------------------------------------------------------------
function dragmove(flags, hotspot_id)
	if hotspot_id == "title" then
        local max_x, max_y = GetInfo(281), GetInfo(280)
        local min_x, min_y = 0, 0
		local drag_x, drag_y = WindowInfo(win, 17), WindowInfo(win, 18)
        local to_x, to_y = drag_x - from_x, drag_y - from_y
        if to_x < min_x then 
            to_x = 0 
        elseif to_x + window_width> max_x then
            to_x = max_x - window_width
        end
        if to_y < min_y then 
            to_y = 0 
        elseif to_y + window_height > max_y then
            to_y = max_y - window_height
        end
		WindowPosition(win, to_x, to_y, 0, 2) -- move the window to the new location
		if drag_x < min_x or drag_x > max_x or
		   drag_y < min_y or drag_y > max_y then -- change the mouse cursor shape appropriately
			check(SetCursor(11)) -- x cursor
		else
			check(SetCursor(1)) -- hand cursor
		end
	end
end
function dragrelease(flags, hotspot_id) end

-- called when the resize drag widget is moved
function ResizeMoveCallback()
    local min = 300
    local start_x, start_y = WindowInfo(win, 10), WindowInfo(win, 11)
    local drag_x,   drag_y = WindowInfo(win, 17), WindowInfo(win, 18)
    local max_x,     max_y = GetInfo(281),        GetInfo(280)
    window_width  = drag_x - start_x
    window_height = drag_y - start_y
    window_pos_x =  drag_x
    window_pos_y =  drag_y
    if window_width > window_height then -- force square
        window_height = window_width
    else
        window_width = window_height
    end
    local out_of_bounds = false
    if window_width  + start_x > max_x then 
        window_width  = max_x - start_x; window_height = window_width; out_of_bounds = true
    end
    if window_height + start_y > max_y then 
        window_height = max_y - start_y; window_width  = window_height; out_of_bounds = true
    end
    if window_width  < min then 
        window_width  = min; window_height = window_width; out_of_bounds = true 
    end
    if window_height < min then 
        window_height = min; window_width  = window_height; out_of_bounds = true
    end
    if out_of_bounds then
        check(SetCursor(11)) -- x cursor
    else
        check(SetCursor(6)) -- resize cursor
    end
    if (utils.timer() - (last_refresh or 0) > 0.0333) then
        WindowResize(win, window_width, window_height, ColourNameToRGB("white"))
        WindowDrawImage(win, "win", 0, 0, window_width, window_height, 2)
        WindowShow(win)
        last_refresh = utils.timer()
   end
end

-- called after the resize widget is released
function ResizeReleaseCallback()
    medina_window_setup(window_width, window_height)
    medina_get_hotspots(med.dimensions)
    medina_print_map()
end

-- called when mouse button is pressed on hotspot
function mousedown(flags, hotspot_id)
    if hotspot_id == "title" then
		from_x, from_y = WindowInfo(win, 14), WindowInfo(win, 15)
    elseif (hotspot_id == "resize") then
        WindowImageFromWindow(win, "win", win)
    end
end

function mouseup(flags, id)
    if id:match("^[nesw]+$") then
        on_alias_medina_look_room('name', 'line', {direction = id})
	elseif id:match("^[A-R]$") then
        medina_get_shortest_path(med.rooms, med.sequence[#med.sequence][1], id)
    end
end

--------------------------------------------------------------------------------
--   SHORTEST PATH
--------------------------------------------------------------------------------
function medina_get_shortest_path(graph, start_node, end_node) -- BFS
    local function deepcopy(orig)
        local orig_type = type(orig)
        local copy
        if orig_type == 'table' then
            copy = {}
            for orig_key, orig_value in next, orig, nil do
                copy[deepcopy(orig_key)] = deepcopy(orig_value)
            end
            setmetatable(copy, deepcopy(getmetatable(orig)))
        else -- number, string, boolean, etc
            copy = orig
        end
        return copy
    end
    local g, solved = deepcopy(graph), false
    if start_node then
        local queue, visited, current = {}, {}, ""
        queue[1] = start_node
        visited[start_node] = true
        g[start_node].parent = false
        while #queue > 0 do
            current = queue[1]
            table.remove(queue, 1)
           if current == end_node then
                solved = true
               break
            end
            for k, v in pairs(g[current].exit_rooms) do
                if not(visited[k]) then
                    if g[current].normalized[v] then
                        visited[k] = true
                        table.insert(queue, k)
                        g[k].parent = current
                    end
                end
            end  
        end
        local path, source_node = {}, g[end_node].parent
        while source_node do
            table.insert(path, 1, source_node)
            source_node = g[source_node].parent
        end
        table.insert(path, end_node);table.remove(path, 1)
        local path_text = {}
        if solved then
            current = start_node
            for _, v in ipairs(path) do
                local direction = g[current].exit_rooms[v]
                on_alias_medina_move_room(name, line, {direction = direction})
                current = v
            end
        else
            ColourNote("white", "black", "<", "red", "black", "No path found. Unlock more exits!", "white", "black", ">")
        end
    end
    return solved
end
--------------------------------------------------------------------------------
--   GRAPHICAL FUNCTIONS
--------------------------------------------------------------------------------
function medina_draw_room(room, coor, col, mw) -- room, coordinates, colours, miniwindow
    local border_colour = med.rooms[room].solved and col.rooms.solved or col.rooms.unsolved
    WindowCircleOp(mw, 2, -- draw room
	    coor.room.outter.x1, coor.room.outter.y1, coor.room.outter.x2, coor.room.outter.y2,            
	    border_colour, 0, 1,
	    col.window.background, miniwin.brush_null)
end

function medina_draw_room_exits(room, coor, col, mw) --room, coordinates, colours, miniwindow
    for norm, dir in pairs(med.rooms[room].normalized) do
        local border_colour = dir and col.exits.solved or col.exits.unsolved
        WindowCircleOp(mw, 2, -- draw exit
            coor.exit[norm].x1, coor.exit[norm].y1, coor.exit[norm].x2, coor.exit[norm].y2,            
            border_colour, 0, 1,
            col.window.background, miniwin.brush_solid)
        if dir then WindowDrawImage(mw, dir, coor.exit[norm].x1 + 2, coor.exit[norm].y1 + 2, 0, 0, 1) end --if solved draw arrow
    end
end

function medina_draw_base(dim, col) -- dimensions, colours
    local coordinates = med.coordinates
    WindowCircleOp( -- window border
        win.."base", miniwin.circle_rectangle, 
        0, 0, dim.window.x, dim.window.y,
        col.window.border, miniwin.pen_solid, 1,
        col.window.background, 0) 
    WindowLine( -- nw exit
        win.."base", 
        0, dim.block.y / 2, dim.buffer.x, dim.buffer.y + (dim.block.y / 2), 
        col.exits.static, miniwin.pen_dot, 1)
    WindowLine( -- se exit
        win.."base", 
        (dim.block.x * 6) + dim.buffer.x, (dim.block.y * 5.5) + dim.buffer.y, dim.window.x, dim.window.y - (dim.block.y / 2), 
        col.exits.static, miniwin.pen_dot, 1)
    WindowCircleOp( -- title bar
        win.."base", miniwin.circle_rectangle, 
        0, 0, dim.window.x, dim.font.title * 1.1,
        col.title.border, miniwin.pen_solid, 1,
        col.title.fill, 0)
    local title = "Medina"
    local text_width = WindowTextWidth(win.."base", "title", title)
    local x1 = (dim.window.x - text_width) / 2
    local y1 = coordinates.title_text.y1 
    local x2 = x1 + text_width
    local y2 = y1 + dim.font.title
    WindowText(win.."base", "title", title, x1, y1, x2, y2, col.title.text)
    for room, coor in pairs(coordinates.rooms) do
        medina_draw_room(room, coor, col, win.."base") -- draw room
        medina_draw_room_exits(room, coor, col, win.."base") -- draw exits
    end
end

function medina_draw_room_letter(room, coor, col) -- room, coordinates, colours
    local letter_colour = med.rooms[room].visited and col.rooms.visited or col.rooms.unvisited
    WindowText (win.."overlay", "larger", room,
        coor.letter.x1, coor.letter.y1, 0, 0,
        letter_colour, 
        false)
end

function medina_draw_overlay(dim, col) -- dimensions, colours
    WindowCircleOp( -- transparent background
        win.."overlay", miniwin.circle_rectangle, 
        0, 0, dim.window.x, dim.window.y,
        col.window.transparent, miniwin.pen_solid, 1,
        col.window.transparent, 0)
    local coordinates = med.coordinates
    for room, coor in pairs(coordinates.rooms) do
        medina_draw_room_letter(room, coor, col)
    end
end

function medina_print_map(look_room)
    local start_time = os.clock()
    local function draw_exit_text(coor, dim, current_room)
        local function get_exit_text_info(unsolved_exits, exit_col, absolute_current)
            local function get_exit_colour(dir, exit_col, absolute_current)
                if absolute_current then
                    if med.rooms[absolute_current].exits and med.rooms[absolute_current].exits[dir] and med.rooms[absolute_current].exits[dir].exits then
                        return exit_col.halfsolved
                    else
                        return exit_col.unsolved
                    end
                else
                    return exit_col.unsolved
                end
            end
            local exit_text, for_text_length, comma = {}, "[", false
            for _, v in ipairs(unsolved_exits) do
                if comma then
                    table.insert(exit_text, {colour = exit_col.comma, text = ", "})
                    for_text_length = for_text_length..", "
                else
                    table.insert(exit_text, {colour = exit_col.bracket, text = "["})
                end
                table.insert(exit_text, {colour = get_exit_colour(v, exit_col, absolute_current), text = v})
                for_text_length = for_text_length..v
                comma = true
            end
            for_text_length = for_text_length.."]"
            table.insert(exit_text, {colour = exit_col.bracket, text = "]"})
            return WindowTextWidth(win, "larger", for_text_length), exit_text
        end
        local directions = {n = true, ne = true, e = true, se = true, s = true, sw = true, w = true, nw = true}
        for dir, _ in pairs(directions) do WindowDeleteHotspot(win, dir) end
        local unsolved_exits = {}
        local absolute_current = #current_room == 1 and current_room[1] or false
        if absolute_current and med.rooms[absolute_current].exits then
            for dir, solved in medina_order_exits(med.rooms[current_room[1]].exits) do
                if not(absolute_current == "A" and dir == "nw") and not(absolute_current == "R" and dir == "se") and not(solved.room) then table.insert(unsolved_exits, dir) end
            end
        elseif current_room.exits then
            for dir, _ in medina_order_exits(current_room.exits) do
                table.insert(unsolved_exits, dir)
            end
        end
        if #unsolved_exits > 0 then
            local text_width, exit_text = get_exit_text_info(unsolved_exits, med.colours.exits, absolute_current)
            local x1 = (dim.window.x - text_width) / 2
            local y1 = coor.y1
            local y2 = y1 + dim.font.larger
            for _, v in ipairs(exit_text) do
                local x2 = x1 + WindowTextWidth(win, "larger", v.text)
                if directions[v.text] then
                     WindowAddHotspot(win, v.text,  
                        x1, y1, x2, y2,
                        "mouseover", 
                        "cancelmouseover", 
                        "mousedown",
                        "cancelmousedown", 
                        "mouseup", 
                        "Look "..v.text,
                        miniwin.cursor_hand, 0)
                end
                x1 = x1 + WindowText(win, "larger", v.text, x1, y1, x2, y2, v.colour)
            end
        end
    end
    local function draw_dynamic(coordinates, col, current_room, look_room)
        local function draw_thyng(room, coor, colour) -- room, coordinates, colours
            local fill_style = #room == 1 and 0 or 8
            for _ , r in ipairs(room) do
                WindowCircleOp(win, 2,
                    coor[r].room.inner.x1, coor[r].room.inner.y1, coor[r].room.inner.x2, coor[r].room.inner.y2,            
                    col.window.background, 0, 0,
                    colour, fill_style)
                WindowRectOp (win, 1, coor[r].room.inner.x1, coor[r].room.inner.y1, coor[r].room.inner.x2, coor[r].room.inner.y2, colour)
            end
        end
        local function draw_border(room, coor, colour)
            for _ , r in ipairs(room) do
                WindowRectOp(win, miniwin.rect_frame, 
                    coor[r].room.outter.x1, coor[r].room.outter.y1, coor[r].room.outter.x2, coor[r].room.outter.y2,
                    colour)
            end
        end
        local trajectory_room = #med.sequence ~= 0 and med.sequence[#med.sequence] or {}
        draw_border(trajectory_room, coordinates.rooms, col.rooms.ghost)
        draw_thyng(look_room, coordinates.rooms, col.rooms.look)
        draw_thyng(current_room, coordinates.rooms, col.thyngs.you)
    end
    local current_room, look_room = med.sequence[1] or {}, look_room or {}
    WindowImageFromWindow(win, "base", win.."base")
    WindowDrawImage(win, "base", 0, 0, 0, 0, 1) -- copy base
    draw_dynamic(med.coordinates, med.colours, current_room, look_room) -- add dynamic
    draw_exit_text(med.coordinates.exit_text, med.dimensions, current_room)
    WindowImageFromWindow(win, "overlay", win.."overlay")
    WindowDrawImage(win, "overlay", 0, 0, 0, 0, 3) -- copy overlay
    WindowShow(win, true)
    --print(os.clock() - start_time) -- speed test
end
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
--   TRIGGER EVENTS
--------------------------------------------------------------------------------
function on_trigger_medina_room_brief(name, line, wildcards, styles)
    local function get_brief_exits(str)
        local t = {}
        str = str..","
        for dir in str:gmatch("(.-),") do
            if dir:match("^[nsew][ew]?$") then
               table.insert(t, dir) 
            end
        end
        return t
    end
    local function list_to_set(t1) local t2 = {}; for _, v in ipairs(t1) do t2[v] = true end; return t2 end
    local exits = get_brief_exits(wildcards.exits)
    local room = medina_get_room(med.sequence[1], exits)
    medina_move_room(room, list_to_set(exits))
end

function on_trigger_medina_room(name, line, wildcards, styles)
    local exits = medina_exit_string_to_set(wildcards.exits)
    local certainty = name:match("medina_room_([A-R])$")
    local room = certainty and {certainty} or {"H", "N"}
    if wildcards.title ~= '' then
		medina_reset_thyngs(room)
        if wildcards.thyngs ~= '' then
            on_trigger_medina_mob_track("here", line, {thyngs = wildcards.thyngs}, styles, room)
        else
            medina_move_room(room, exits)
        end
    elseif wildcards.look ~= '' then
        local simulate_night = false -- for testing night mode
        if simulate_night then
            on_trigger_medina_dark_room(name, line, wildcards, styles)
        else
            if wildcards.thyngs ~= '' then
                --print('thyngs spotted in look room')
            else
                medina_look_room(room, exits)
            end
        end
    end
end

function on_trigger_medina_dark_room(name, line, wildcards, styles)
    local function list_to_set(t1) local t2 = {}; for _, v in ipairs(t1) do t2[v] = true end; return t2 end
    local current_room = med.sequence[1]
    if wildcards.title ~= '' then
        if wildcards.thyngs ~= '' then
            --print('thyngs spotted in dark room')
        else
            local exits  = medina_exit_string_to_list(wildcards.exits)
            local room = medina_get_room(current_room, exits)
            medina_move_room(room, list_to_set(exits))
        end
    elseif wildcards.look ~= '' then
        if wildcards.thyngs ~= '' then
            --print('thyngs spotted in look dark room')
        else
            local exits = medina_exit_string_to_list(wildcards.exits)
            local room = medina_get_room(current_room, exits)
            medina_look_room(room, list_to_set(exits))
        end
    end
end

function on_trigger_medina_too_dark(name, line, wildcards, styles)
    medina_print_map(medina_get_presumed_look(med.sequence[1], med.commands.look[1]))
    table.remove(med.commands.look, 1)
end

function on_trigger_medina_look_out_of_bounds(name, line, wildcards, styles)
    table.remove(med.commands.look, 1)
end

function on_trigger_medina_remove_queue(name, line, wildcards, styles)
    -- we can't just clear the tables entirely because commands may have been entered after 'stop'
    while(med.commands.look[med.commands.look.count + 1]) do
	   table.remove(med.commands.look, (med.commands.look.count + 1))
    end
    while(med.commands.move[med.commands.move.count + 1] ~= nil) do
	   table.remove(med.commands.move, (med.commands.move.count + 1))
    end
    while(med.sequence[med.commands.move.count + 2]) do
	   table.remove(med.sequence, (med.commands.move.count + 2))
    end
    medina_print_map()
end

function on_trigger_medina_command_fail(name, line, wildcards, styles)
    table.remove(med.commands.move, 1);table.remove(med.sequence, 2)
    medina_construct_seq()
    medina_print_map()
end

function on_trigger_medina_you_follow(name, line, wildcards, styles)
    med.commands.move.count = (med.commands.move.count or 0) + 1 -- used in 'stop' handling
    local direction = medina_format_direction(wildcards.direction)
    table.insert(med.commands.move, 1, direction)
    medina_construct_seq()
end

function on_trigger_medina_mob_track(name, line, wildcards, styles, room)
	local sign = name:match("exit") and -1 or 1
	medina_get_mobs(wildcards, sign, room)
end
--------------------------------------------------------------------------------
--   ALIAS EVENTS
--------------------------------------------------------------------------------
--movement/look handlers
function on_alias_medina_move_room(name, line, wildcards)
    local function to_list(t1) t2 = {}; for k, v in pairs(t1) do if v then table.insert(t2, k) end end; return t2 end
    med.commands.move.count = (med.commands.move.count or 0) + 1 -- used in 'stop' handling
    local direction = medina_format_direction(wildcards.direction) 
    local to_send, possible_rooms = direction, {}
    local trajectory_room = #med.sequence[#med.sequence] == 1 and med.sequence[#med.sequence][1] or false
    if direction:match("l") then
        for _, v in ipairs(med.sequence[#med.sequence]) do
		  possible_rooms[v] = true
        end
    elseif med.rooms[trajectory_room] and med.rooms[trajectory_room].normalized[direction] then
        to_send = med.rooms[trajectory_room].normalized[direction] -- normalize
        possible_rooms = {}
        if med.rooms[trajectory_room].exits and med.rooms[trajectory_room].exits[to_send] 
        and med.rooms[trajectory_room].exits[to_send].room then
            possible_rooms[med.rooms[trajectory_room].exits[to_send].room] = true
        end
    else
        possible_rooms = medina_get_seq(med.sequence[#med.sequence], direction)
    end
    table.insert(med.sequence, to_list(possible_rooms))
    table.insert(med.commands.move, to_send)
    Send(to_send)
    medina_print_map()
end

function on_alias_medina_look_room(name, line, wildcards)
    med.commands.look.count = (med.commands.look.count or 0) + 1
    local direction = medina_format_direction(wildcards.direction)
	local trajectory_room, to_send = #med.sequence[#med.sequence] == 1 and med.sequence[#med.sequence][1] or false, "l "
	if trajectory_room and med.rooms[trajectory_room].solved and med.rooms[trajectory_room].normalized[direction]then 
        -- unlike movement, look-directions only normalize after all exits in a room are solved
        -- otherwise you could get stuck
        to_send = to_send..med.rooms[trajectory_room].normalized[direction] -- normalized
        table.insert(med.commands.look, med.rooms[trajectory_room].normalized[direction])
	else
		to_send = to_send..direction --unaltered
		table.insert(med.commands.look, direction)
	end
    Send(to_send)
    medina_debug_movement()
end

function on_alias_medina_stop(name, line, wildcards)
    med.commands.move.count, med.commands.look.count = 0, 0
    Send("stop")
end
-- debugging
function on_alias_medina_table(name, line, wildcards) -- 'medt'
    local room = wildcards.room:upper()
    if room:match("^[A-R]$") then
        print("med.rooms:",room..":");tprint(med.rooms[room])
    else
        print("med.players");tprint(med.players)
        print("med.rooms");tprint(med.rooms)
        print("med.commands.move");tprint(med.commands.move)
        print("med.sequence");tprint(med.sequence)
        print("med.commands.look");tprint(med.commands.look)
    end
end
-- commands
function on_alias_medina_reset(name, line, wildcards) -- 'medr'
    local current_room, is_reset_room, reset_room = med.sequence[1] and #med.sequence[1] == 1 and med.sequence[1][1] or false, wildcards.is_reset_room, wildcards.room:upper()
    if reset_room:match("^[A-R]$") then -- room specified
        medina_reset_room(reset_room); medina_print_map()
        if current_room and current_room == reset_room then Send("l") end -- gather exits
    elseif is_reset_room ~= "" then
        if current_room then medina_reset_room(current_room); medina_print_map(); Send("l") end -- 'room' with no argument
    else
        medina_reset_rooms(); medina_print_map() -- no arguments: reset everything
        if med.is_in_medina then Send("l") end
    end
end

function on_alias_medina_window_open(name, line, wildcards) medina_print_map() end -- 'medwo'

function on_alias_medina_window_exit(name, line, wildcards) WindowShow(win, false) end -- 'medwx'

function on_alias_medina_window_center(name, line, wildcards) WindowPosition(win, 0, 0, miniwin.pos_center_all, 0); medina_print_map() end -- 'medwc'
--------------------------------------------------------------------------------
--  ENTER AND EXIT HANDLING
--------------------------------------------------------------------------------
function medina_enter()
    if not(med.is_in_medina) then
        med.is_in_medina,  med.room_uncertainty = true, false
        med.commands.move, med.commands.look, med.sequence = {}, {}, {}
        med.commands.move.count, med.commands.look.count = 0, 0
        EnableGroup("medina", true)
        -- delete timer med.timer_reset_thyngs
        -- delete timer med.timer_reset_visited
    end
end

function medina_exit()
    if med.is_in_medina then
        med.is_in_medina, med.room_uncertainty = false, false
        local previous_room = med.sequence[1] or false
        med.sequence = {}; med.sequence[0] = previous_room
        EnableGroup("medina", false)
        if GetTriggerInfo("medina_exit", 8) then -- no need to enable if gmcp is active
            EnableTrigger("medina_enter", true)
        end
        -- set timer med.timer_reset_thyngs
        -- set timer med.timer_reset_visited
    end
    WindowShow(win, false)
end
--------------------------------------------------------------------------------
--   MOVEMENT AND LOOK HANDLING
--------------------------------------------------------------------------------
function medina_move_room(room, exits)
    if med.commands.move[1] ~= "l" then 
        med.commands.move[0] = med.commands.move[1]
        med.sequence[0] = med.sequence[1]
    else
        exits = med.sequence[1].exits or exits
    end
    table.remove(med.commands.move, 1); table.remove(med.sequence, 1)
    local direction = med.commands.move[0]
    local current_room, current_exits, presumed_room = room, exits, med.sequence[1] or {}
    local previous_room, previous_exits = med.sequence[0] or {}, med.sequence[0] and med.sequence[0].exits or false
    previous_room, current_room = medina_verify_room(previous_room, previous_exits, direction, current_room, presumed_room, current_exits)
    med.sequence[0], med.sequence[1] = previous_room, current_room
    local absolute_current = #current_room == 1 and current_room[1] or false
    if absolute_current and not(med.rooms[absolute_current].visited) then
        med.rooms[absolute_current].visited = true
        medina_draw_room_letter(absolute_current, med.coordinates.rooms[absolute_current], med.colours) 
    end
    medina_construct_seq()
    medina_print_map()
end

function medina_look_room(room, exits)
    med.commands.look[0] = med.commands.look[1]
    table.remove(med.commands.look, 1)
    local direction, look_direction = med.commands.move[0], med.commands.look[0]
    local current_room, current_exits = med.sequence[1] or {}, med.sequence[1] and med.sequence[1].exits or false
    local previous_room, previous_exits = med.sequence[0], med.sequence[0] and med.sequence[0].exits or false
    local look_room, look_exits = room, exits
    local presumed_room, presumed_look = med.sequence[1] or {}, medina_get_presumed_look(current_room, look_direction)
    current_room, look_room = medina_verify_room(current_room, current_exits, look_direction, look_room, presumed_look, look_exits)
    previous_room, current_room = medina_verify_room(previous_room, previous_exits, direction, current_room, presumed_room, current_exits)
    med.sequence[0], med.sequence[1] = previous_room, current_room
    local absolute_look = #look_room == 1 and look_room[1] or false  
    if absolute_look and not(med.rooms[absolute_look].visited) then
        med.rooms[absolute_look].visited = true
        medina_draw_room_letter(absolute_look, med.coordinates.rooms[absolute_look], med.colours) 
    end
    medina_construct_seq()
    medina_print_map(look_room)
end

function medina_get_presumed_look(room, dir)
    local presumed_look = {}
    for _, r in ipairs(room) do
        local predictable = false
        if med.rooms[r].exits and med.rooms[r].exits[dir] and med.rooms[r].exits[dir].room then
            table.insert(presumed_look, med.rooms[r].exits[dir].room); predictable = true
        end
        if not(predictable) then
            for k, v in pairs(med.rooms[r].exit_rooms) do
                if not med.rooms[r].normalized[v] then
                    table.insert(presumed_look, k) 
                end
            end
        end
    end
    return presumed_look
end

function medina_construct_seq()
    local function to_list(t1) t2 = {}; for k, v in pairs(t1) do if v then table.insert(t2, k) end end; return t2 end
    while(med.sequence[2]) do table.remove(med.sequence, 2) end
    for _, direction in ipairs(med.commands.move) do
        table.insert(med.sequence, to_list(medina_get_seq(med.sequence[#med.sequence], direction)))
    end
end

function medina_get_seq(start_room, direction)
    local function get_adj(r)
        t = {}
        t[r] = true
        for k, v in pairs(med.rooms[r].exit_rooms) do
            if not(med.rooms[r].normalized[v]) then
                t[k] = true
            end
        end
        return t
    end
    local end_room = {}
    if direction:match("l") then
        end_room = start_room
    else
         for _, r in ipairs(start_room) do
            if med.rooms[r] and med.rooms[r].exits and med.rooms[r].exits[direction] 
            and med.rooms[r].exits[direction].room then
            --if we know where we're going
                end_room[med.rooms[r].exits[direction].room] = true
            elseif med.rooms[r] and med.rooms[r].exits and not(med.rooms[r].exits[direction]) 
            and not(r == "R" and direction == "se") and not(r == "A" and direction == "nw") then
            --if we know that the exit does not exist
                end_room[r] = true
            elseif not(r == "R" and direction == "se") and not(r == "A" and direction == "nw") then
                for k, _2 in pairs(get_adj(r)) do
                    end_room[k] = true
                end
            end
        end
    end
    return end_room -- in set form
end

function medina_exit_string_to_set(str)
    local t = {}
    if str:match(" north[%s%.,]") then t.n = true end
    if str:match(" northeast[%s%.,]") then t.ne = true end
    if str:match(" east[%s%.,]") then t.e = true end
    if str:match(" southeast[%s%.,]") then t.se = true end
    if str:match(" south[%s%.,]") then t.s = true end
    if str:match(" southwest[%s%.,]") then t.sw = true end
    if str:match(" west[%s%.,]") then t.w = true end
    if str:match(" northwest[%s%.,]") then t.nw = true end  
    return t
end

function medina_exit_string_to_list(str)
    local t = {}
	if str:match(" north[%s%.,]") then table.insert(t, "n") end
	if str:match(" northeast[%s%.,]") then table.insert(t, "ne") end
	if str:match(" east[%s%.,]") then table.insert(t, "e") end
	if str:match(" southeast[%s%.,]") then table.insert(t, "se") end
	if str:match(" south[%s%.,]") then table.insert(t, "s") end
	if str:match(" southwest[%s%.,]") then table.insert(t, "sw") end
	if str:match(" west[%s%.,]") then table.insert(t, "w") end
	if str:match(" northwest[%s%.,]") then table.insert(t, "nw") end
    return t
end

function medina_format_direction(long_direction)
    local direction = string.lower(long_direction)
	direction = direction:gsub("north", "n")
	direction = direction:gsub("east", "e")
	direction = direction:gsub("south", "s")
	direction = direction:gsub("west", "w")
	direction = direction:gsub("look", "l")
    return direction
end
-- order exits
function medina_order_exits(t1)
	local t2 = {}
	local order = {n = 1, ne = 2, e = 3, se = 4, s = 5, sw = 6, w = 7, nw = 8}
	for k, _ in pairs(t1) do
		if order[k] then
			table.insert(t2, k)
		end 
	end
	table.sort(t2, function(a,b) return order[a]<order[b] end)
	local i = 0
	return function() i = i + 1; if t2[i] then return t2[i], t1[t2[i]] end end
end
--------------------------------------------------------------------------------
--   EXIT SOLVING
--------------------------------------------------------------------------------
function medina_solve_exit(start_room, direction, end_room)
    if start_room and direction and end_room then
        if med.rooms[start_room].exits and med.rooms[start_room].exit_rooms[end_room] then
            if med.rooms[start_room].exits[direction] then
                local normalized = med.rooms[start_room].exit_rooms[end_room]
                med.rooms[start_room].exits[direction].room = end_room
                med.rooms[start_room].normalized[normalized] = direction
            end
        end
        medina_solve_final_count_matches(start_room)
        medina_solve_final_exit(start_room)
        medina_draw_room(start_room, med.coordinates.rooms[start_room], med.colours, win.."base")
        medina_draw_room_exits(start_room, med.coordinates.rooms[start_room], med.colours, win.."base")
    end
end

function medina_solve_final_count_matches(room)
    local function get_count(t) local c = 0; for _, _2 in pairs(t) do c = c + 1 end return c end
    local function to_list(t1) t2 = {}; for k, v in pairs(t1) do if v then table.insert(t2, k) end end; return t2 end
    local function get_possible_rooms(room, exit_count)
        t = {}; for _, v in pairs(med.exit_counts[room].adj_room_exit_count[exit_count].rooms) do t[v] = true end; return {rooms = t, directions = {}}
    end
    if med.rooms[room].exits and not(med.rooms[room].solved) then
        local exit_set = {}
        for dir, v in pairs(med.rooms[room].exits) do
            if v.room then
                local exit_count = med.exit_counts[v.room].adj_room_count
                exit_set[exit_count] = exit_set[exit_count] or get_possible_rooms(room, exit_count)
                exit_set[exit_count].rooms[v.room] = false
            elseif v.exits then
                local exit_count = get_count(v.exits)
                exit_set[exit_count] = exit_set[exit_count] or get_possible_rooms(room, exit_count)
                table.insert(exit_set[exit_count].directions, dir)
            end
        end
        for exit_count, v in pairs(exit_set) do
            local rooms = to_list(v.rooms)
            local final_room = #rooms == 1 and rooms[1] or false
            local final_direction = #v.directions == 1 and v.directions[1] or false
            if final_room and final_direction then
                med.rooms[room].exits[final_direction].room = final_room
                med.rooms[room].normalized[med.rooms[room].exit_rooms[final_room]] = final_direction
            end
        end
    end
end

function medina_solve_final_exit(start_room)
    local count, final_exit = 0, ""
    if med.rooms[start_room].exits then
        for dir, v in pairs(med.rooms[start_room].exits) do
            if not(v.room) and not(start_room == "R" and dir == "se") and not(start_room == "A" and dir == "nw") then
                final_exit = dir
                count = count + 1
                if count > 1 then break end
            end
        end
        if count == 1 then
            local final_room = ""
            for end_room, dir in pairs(med.rooms[start_room].exit_rooms) do
                if not(med.rooms[start_room].normalized[dir]) then
                    med.rooms[start_room].normalized[dir] = final_exit
                    final_room = end_room
                    break
                end
            end
            med.rooms[start_room].exits[final_exit].room = final_room
            med.rooms[start_room].solved = os.time()
            -- set expiration timer
        elseif not(med.rooms[start_room].solved) and count == 0 then
            med.rooms[start_room].solved = os.time()
        end
    end
end

function medina_get_room(start_room, end_exits)
    -- return possible room based off exit counts
    local function to_list(t1) t2 = {}; for k, v in pairs(t1) do if v then table.insert(t2, k) end end; return t2 end
    local exit_count, possible_rooms = #end_exits, {}
    if exit_count == 6 then -- heart
        return {"I"}
    elseif exit_count == 5 then -- 5-exit room
        return {"E"}
    elseif start_room then 
        for _, r in ipairs(start_room) do
            if med.exit_counts[r].adj_room_exit_count[exit_count] then -- exit counts match
                for _2, room in pairs(med.exit_counts[r].adj_room_exit_count[exit_count].rooms) do
                    possible_rooms[room] = true
                end
            end
        end
        return to_list(possible_rooms)
    elseif exit_count == 4 then
        return {"A"}
    elseif exit_count == 2 then
        return {"R"}
    else
        return {}
    end
end

function medina_verify_room(possible_start, start_exits, direction, possible_end, presumed_end, end_exits)
    -- attempt to narrow start and end rooms
    -- if we find certainty we will log exits
    -- if we find discrepensies we will reset
    -- return start and end rooms
    local function to_set(t1) local t2 = {}; for _, v in ipairs(t1) do t2[v] = true end; return t2 end
    local function to_list(t1) local t2 = {}; for k, _ in pairs(t1) do table.insert(t2, k) end; return t2 end
    start_room, end_room, presumed_end, possible_start = {}, {}, to_set(presumed_end), to_set(possible_start)
    
    for _, v in ipairs(possible_end) do
        if presumed_end[v] then
            table.insert(end_room, v) -- overlap between possible and presumed
        end
    end
    local exit_change = false
    if #end_room == 0 then
        end_room = possible_end
        exit_change = true  -- if no overlap, start exits have changed
    end
    for _, v in ipairs(end_room) do
        for k, _ in pairs(med.rooms[v].exit_rooms) do
            if possible_start[k] then
                start_room[k] = true -- narrow start based on overlap
            end
        end
    end
    start_room = to_list(start_room)
    if exit_change then -- reset start exits
        for _, room in ipairs(start_room) do
            medina_reset_room_exits(room)
            if start_exits then
                med.rooms[room].exits = {}
                for dir, _ in pairs(start_exits) do med.rooms[room].exits[dir] = {room = false, exits = false} end
            end
        end
    end
    local absolute_end = #end_room == 1 and end_room[1] or false
    local absolute_start = #start_room == 1 and start_room[1] or false
    if absolute_start and start_exits then
        if not(med.rooms[absolute_start].exits) then
            med.rooms[absolute_start].exits = {}
            for dir, _ in pairs(start_exits) do med.rooms[absolute_start].exits[dir] = {room = false, exits = false} end
        end
        if med.rooms[absolute_start].exits[direction] ~= nil and end_exits then
            med.rooms[absolute_start].exits[direction].exits = {}
            start_exits[direction] = {}
            for dir, _ in pairs(end_exits) do
               start_exits[direction][dir] = true
               med.rooms[absolute_start].exits[direction].exits[dir] = true
               -- logging adjacent-room exit-lists, this will come in handy when dealing with specific cases of uncertainty
            end
        end
        if not(absolute_end) and med.rooms[absolute_start].exits and end_exits and direction then
            -- attempt to narrow uncertainty based on exit-lists
            local function get_count(t) local c = 0; for _, _2 in pairs(t) do c = c + 1 end return c end
            local function get_set_info(room, exit_count)
                local t = {directions = {}, rooms = {}, threshold = 0,}
                if med.exit_counts[room] and med.exit_counts[room].adj_room_exit_count[exit_count] then
                    for _, r in ipairs(med.exit_counts[room].adj_room_exit_count[exit_count].rooms) do
                        t.rooms[r] = {}
                    end
                    t.threshold = med.exit_counts[room].adj_room_exit_count[exit_count].number_of_rooms
                end
               return t
            end
            local exit_sets = {}
            for dir, v in pairs(med.rooms[absolute_start].exits) do
                if v.exits then
                    local exit_count = get_count(v.exits)
                    exit_sets[exit_count] = exit_sets[exit_count] or get_set_info(absolute_start, exit_count)
                    if v.room then
                        exit_sets[exit_count].rooms[v.room] = nil
                    else
                        table.insert(exit_sets[exit_count].directions, dir)
                    end
                    exit_sets[exit_count].threshold = exit_sets[exit_count].threshold - 1
                    if exit_sets[exit_count].threshold == 0 then
                        for r, _ in pairs(exit_sets[exit_count].rooms) do
                            if med.rooms[r].exits then
                                local match = ""
                                for _2, d in ipairs(exit_sets[exit_count].directions) do
                                    match = d
                                    for dd, _3 in pairs(med.rooms[absolute_start].exits[d].exits) do
                                        if med.rooms[r].exits[dd] == nil then
                                            match = false; break
                                        end
                                    end
                                    if match then 
                                        table.insert(exit_sets[exit_count].rooms[r], match)
                                    end
                                end
                                if #exit_sets[exit_count].rooms[r] == 1 then
                                    medina_solve_exit(absolute_start, exit_sets[exit_count].rooms[r][1], r)
                                    if med.rooms[absolute_start].exits[direction].room then
                                        end_room = {}
                                        table.insert(end_room, med.rooms[absolute_start].exits[direction].room)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    absolute_end = #end_room == 1 and end_room[1] or false
    if absolute_end and end_exits then -- end room certainty
         if med.rooms[absolute_end].exits then -- if exits are already logged
            exit_change = false 
            for dir, _ in pairs(end_exits) do if not(med.rooms[absolute_end].exits[dir]) then exit_change = true; break end end
            if exit_change then -- if exits have changed, update them
                medina_reset_room_exits(absolute_end)
                med.rooms[absolute_end].exits = {}
                for dir, _ in pairs(end_exits) do med.rooms[absolute_end].exits[dir] = {room = false, exits = false} end
            end
        else
            med.rooms[absolute_end].exits = {}
            for dir, _ in pairs(end_exits) do med.rooms[absolute_end].exits[dir] = {room = false, exits = false} end -- log exits
        end
    end
    if absolute_start and absolute_end then
        medina_solve_exit(absolute_start, direction, absolute_end)
    end
    if absolute_end == "R" and not(med.rooms.R.solved) then
        medina_solve_final_exit("R") -- auto-solve "R"
        medina_draw_room("R", med.coordinates.rooms.R, med.colours, win.."base")
        medina_draw_room_exits("R", med.coordinates.rooms.R, med.colours, win.."base")
    end
    start_room.exits, end_room.exits = start_exits, end_exits
    return start_room, end_room
end

function medina_get_exit_counts(t) -- compile data relating to exit counts, useful for cases of uncertainty from dark/brief
    local function get_exit_count(room)
        local count = 0
        for _, _2 in pairs(t[room].exit_rooms) do count = count + 1 end
        if room == "A" or room == "R" then count = count + 1 end
        return count
    end
    local exit_counts = {}
    for room, v in pairs(t) do
        exit_counts[room] = {adj_room_exit_count = {}}
        local adj_room_count = 0
        for adj_room, _ in pairs(v.exit_rooms) do
            local n = get_exit_count(adj_room)
            exit_counts[room].adj_room_exit_count[n] = exit_counts[room].adj_room_exit_count[n] or {}
            exit_counts[room].adj_room_exit_count[n].number_of_rooms = (exit_counts[room].adj_room_exit_count[n].number_of_rooms and exit_counts[room].adj_room_exit_count[n].number_of_rooms + 1) or 1
            exit_counts[room].adj_room_exit_count[n].rooms = exit_counts[room].adj_room_exit_count[n].rooms or {}
            table.insert(exit_counts[room].adj_room_exit_count[n].rooms, adj_room)
            adj_room_count = adj_room_count + 1
        end
        if room == "A" or room == "R" then adj_room_count = adj_room_count + 1 end
        exit_counts[room].adj_room_count = adj_room_count
    end
    return exit_counts
end
--------------------------------------------------------------------------------
--   MOB TRACKING
--------------------------------------------------------------------------------
function medina_get_mobs(wildcards, sign, room)
	local function get_quantity(mob)
		local number = {the = 1, two = 2, three = 3, four = 4, five = 5, six = 6, seven = 7, eight = 8, nine = 9, ten = 10, eleven = 11, twelve = 12, thirteen = 13, fourteen = 14, fifteen = 15, sixteen = 16, seventeen = 17, eighteen = 18, nineteen = 19, twenty = 20, many = 21,}
		mob = mob:gsub("^an? ", "the ")
		local n = ""
		n, mob = mob:match("^(%w+) (.*)")
		n = number[n] or 0
		return mob, n
	end
	local function format_mobs(mob, n)
		if n == 1 then
			mob = mob:gsub("y$", "ies"):gsub("([^s])$", "%1s")
		end
		mob = mob:gsub("triad ", "")
		return mob
	end
	room = room or med.sequence[1] or {}
	local text = string.lower(wildcards.thyngs)
	local direction = wildcards.direction
	if direction == "" then
		direction = false
	end
	regex.verbiage:gmatch(text, function (_, t)
		text = text:gsub(t.verbiage, "")
	end)
	local thyngs = ", "..text:gsub(" and ", ", ")
	for thyng in string.gmatch(thyngs, '([^,]+)') do
		thyng = Trim(thyng)
		if med.players[thyng] then
			local player, p_colour = thyng, med.players[thyng]
			regex.titles:gmatch(player, function (_, t)
				player = player:gsub(t.title.." ", "")
			end)
			player = player:gsub("^([a-z']+) .*$", "%1")
			------------------------------------------------------------
			ColourTell(RGBColourToName(p_colour), "black", sign..player)

			for r, v in pairs(med.rooms) do
				med.rooms[r].thyngs.players[player] = nil
			end
			if sign > 0 then
				for i, r in ipairs(room) do
					med.rooms[r].thyngs.players[player] = p_colour
				end
			end
			if direction then
				for i, r in ipairs(room) do
					if med.rooms[r].exits[direction] then
						med.rooms[r].exits[direction].thyngs.players[player] = p_colour
					end
				end	
			end
		else
			local mob, n = get_quantity(thyng)
			mob = format_mobs(mob, n)
			print(mob, n)
			if mob == "thugs" or mob == "heavies" then
				print(2)
				tprint(room)
				for i, r in ipairs(room) do
					med.rooms[r].thyngs.mobs[mob] = med.rooms[r].thyngs.mobs[mob] + n * sign > 0 and med.rooms[r].thyngs.mobs[mob] + n * sign or 0
					print(r, med.rooms[r].thyngs.mobs[mob], n * sign)
				end
				if direction then
					for i, r in ipairs(room) do
						if med.rooms[r].exits[direction] then
							med.rooms[r].exits[direction].thyngs.mobs[mob] = med.rooms[r].exits[direction].thyngs.mobs[mob] + n
						end
					end	
				end 
			elseif mob == "boss" then
				for r, v in pairs(med.rooms) do
					med.rooms[r].thyngs.mobs.boss = 0
				end
				for i, r in ipairs(room) do
					med.rooms[r].thyngs.mobs.boss = sign < 0 and 0 or sign
				end
				if direction then
					for i, r in ipairs(room) do
						if med.rooms[r].exits[direction] then
							med.rooms[r].exits[direction].thyngs.mobs.boss = 1
						end
					end	
				end
			end
		end
	end
end
--------------------------------------------------------------------------------
--   SYNC FUNCTIONS
--------------------------------------------------------------------------------
function on_trigger_medina_receive_sync(name, line, wildcards, styles)
	med.sync = {data = {}, is_valid = false}
	medina_draw_sync_sword(wildcards)
	medina_handle_incoming_sync(wildcards.sync, wildcards.version, wildcards.sender)
end

function on_alias_medina_sync(name, line, wildcards)
	if wildcards.player ~= '' then -- sending
		Send('tell '..wildcards.player..' '..medina_get_sync())
	else -- accepting
		if med.sync.is_valid then
			medina_reset_rooms()
			for room, v in pairs(med.sync.data) do
				if v.solved then
					for static, _ in medina_order_exits(v) do
						if not (room == 'A' and static == 'nw' or room == 'R' and static == 'se') then
							local temp = v[static]
							med.rooms[room].normalized[static] = temp
							med.rooms[room].solved = med.sync.recieved
							if temp then
								med.rooms[room].exits = 
									med.rooms[room].exits or 
									room == 'A' and {nw = {exits = false, room = false}} or 
									room == 'R' and {se = {exits = false, room = false}} or {}
								med.rooms[room].exits[temp] = {exits = false, room = false}
								for adj_room, dir in pairs(med.rooms[room].exit_rooms) do
									if static == dir then
										med.rooms[room].exits[temp].room = adj_room
									end
								end
							end
						end
					end
					med.rooms[room].solved =  med.sync.time
				end
			end
			medina_draw_base(med.dimensions, med.colours)
			medina_print_map()
		else
			medina_print_error('No sync data available')
		end
	end
end

function medina_get_sync()
	local text, time, n = "", 0, 0 
	local ex = {n = 1, ne = 2, e = 3, se = 4, s = 5, sw = 6, w = 7, nw = 8}
	local A, R = 65, 82
    for i = A, R  do
		local room = string.char(i)
        for static, temp in medina_order_exits(med.rooms[room].normalized) do
			if not (room == 'A' and static == 'nw' or room == 'R' and static == 'se') then
				text = text..tostring(ex[temp] or '0')
            end
        end
        if med.rooms[room].solved then
            time = time + med.rooms[room].solved
			n = n + 1
        end
    end
	time = tostring(n == 0 and 0 or math.floor(time / n))
	text = time .. text
    local version = string.format ("%1.1f", GetPluginInfo (GetPluginID (), 19) )
    local signiture = "/zMMv" .. version .. "/"
    local based = medina_convert_base(text, 10, 94):format("%0c", 56)
    local hilt, blade = "cxxxxx][={>>>",--[[SUPER BADASS SWORD LOL]]"_>>>"
    local sync_sword =  hilt .. based .. signiture .. blade 
    return sync_sword
end

function medina_handle_incoming_sync(sync, version, sender)
	local function invalid_data(reason)
		med.sync = {data = {}, is_valid = false}
		medina_print_error("Invalid sync data: "..reason.."; "..sender.."")
	end
	if #sync < 40 then
		sync = medina_convert_base(sync, 94, 10)
		local total_rooms = 56
		local n = #sync - total_rooms
		if 0 < n and n <= 10 then
			local time, mapdata = string.match(sync, '^(' .. string.rep('.', n) .. ')(%d*)$')
			time = tonumber(time)
			if time and #mapdata == total_rooms then
				local ex = {'n', 'ne', 'e', 'se', 's', 'sw', 'w', 'nw'}; ex[0] = false
				local unpacked, solved = {}, 0
				local A, R, n = 65, 82, 1
				for i = A, R do
					local room = string.char(i)
					local prevent_duplicate_exits = {}
					for static, temp in medina_order_exits(med.rooms[room].normalized) do
						if not (room == 'A' and static == 'nw' or room == 'R' and static == 'se') then
							unpacked[room] = unpacked[room] or {solved = true}
							local m = tonumber(mapdata:sub(n, n))
							if ex[m] ~= nil then
								if not prevent_duplicate_exits[ex[m]] then
									if m > 0 then
										prevent_duplicate_exits[ex[m]] = true
									end
									unpacked[room][static] = ex[m]
									if not unpacked[room][static] then
										unpacked[room].solved = false
									end							
								else
									print (m, ex[m])
									invalid_data("duplicate exits")
									return
								end
								n = n + 1
							else
								invalid_data("incorrect format")
								return
							end
						end
					end
					if unpacked[room].solved then
						solved = solved + 1
					end
				end
				local percent = (math.floor((solved/18) *10000 + 0.5) / 100)
				med.sync = {data = unpacked, is_valid = true, time = time}
				medina_sync_unpacking_successful(percent, time, version, sender)
				return
			end
		end
	end
	invalid_data("incorrect length")
end

function medina_sync_unpacking_successful(percent, time, version, sender)
	time = os.time() - time
	local text_colour1, text_colour2, text_colour3 = "gray", "lightgray", "orange"
	ColourTell(
		text_colour2, "", sender, 
		text_colour1, "", " has sent you medina map data: ", 
		text_colour2, "", "[",
		text_colour3 , "", percent.."\%",
		text_colour2, "", "] "
	)
	ColourNote(text_colour1, "", "("..string.format("%.2d:%.2d:%.2d", time/(60*60), time/60%60, time%60)..")")
	ColourTell(
		text_colour1, "", "Type/Click on ",
		text_colour2, "", "'"
	)
	Hyperlink ("medina sync", "medina sync", "Update medina map!", "orange", "black", 0)
	ColourNote(
		text_colour2, "", "'",
		text_colour1, "", " to update",
		text_colour1, "", "!"
	)
	ColourNote(
		text_colour1, "black", "(This will override your current map.)"
	)
	if GetPluginInfo(GetPluginID (), 19) < tonumber(version) then
		medina_print_error("There is a newer version of this plugin available!")
	end
	Note('\n')
end

function medina_draw_sync_sword(wildcards)
	local background_colour = RGBColourToName(AdjustColour (GetInfo(271), 1))
	local hilt_colour, sword_colour1, sword_colour2, blood_colour = "orange", "lightgray", "gray", "red"
	local blade_len = #wildcards.blade0
	ColourTell(background_colour, background_colour, wildcards.tell..'\n', hilt_colour, background_colour, wildcards.hilt)
	local i = 1
	for _, v in ipairs({'ricasso', 'blade1', 'blade2', 'blade3', 'blade4', 'blade5', 'point'}) do
		for c in wildcards[v]:gmatch(".") do
			sword_colour1 = RGBColourToName( 
				AdjustColour (ColourNameToRGB (sword_colour1), 
				i < blade_len / 2 and 3 or 2) )
			sword_colour2 = RGBColourToName( 
				AdjustColour (ColourNameToRGB (sword_colour2), 
				i < blade_len / 2 and 2 or 3) )
			local text_colour = (v == 'blade1'  or v == 'blade5') and sword_colour2 or v == 'blade3' and blood_colour or sword_colour1
			local bg_colour   = (v == 'ricasso' or v == 'point' ) and background_colour or sword_colour1
			ColourTell(text_colour, bg_colour, c)
			i = i + 1
		end
	end
	Note("\n")
end

function medina_convert_base(s, b1, b2)
	local function get_bases()
		local base = {
			[10] = {}, 
			[94] = {},
		}
		for i = 33, 126 do
		  table.insert(base[94], string.char(i))
		end
		for i = 48, 57 do
			table.insert(base[10], string.char(i))
		end
		for k, v in pairs(base) do
			base[k][0] = v[1]
			table.remove(base[k], 1)
		end
		return base
	end
	local base = get_bases()
	local function list_to_set(t1)
		t2 = {}
		for k, v in pairs(t1) do
			t2[tostring(v)] = k
		end
		return t2
	end
	local function copy_list(t1)
		t2 = {}
		for k, v in pairs(t1) do
			t2[k] = v
		end
		return t2
	end
    local tb1, tb2 = list_to_set(base[b1]), copy_list(base[b2])
    local function b1_to_dec(s)
		bc.digits (5000)
        local dec = bc.number(0)
        for i = 1, #s do
            local c = s:sub(i,i)
            dec = bc.add( dec, bc.mul( tb1[c], bc.pow (b1, (#s - i) ) ) )
        end
        return dec
    end
    local function dec_to_b2(dec)
        local q, r, t = dec, 0, {}
        local m = 1
        while not bc.iszero (q)  do
			bc.digits (5000)
            q, r = bc.divmod (q, b2)
            if not r then r = 0 end
            table.insert(t, 1, bc.tonumber(r))
            m = m + 1
            if m == 100000 then break end
        end
        s = ""
        for i, v in ipairs(t) do
			if tb2[v] then
				s = s..tb2[v]
            end
        end
        return s
    end
    local based = dec_to_b2(b1_to_dec(s))
    local min = {[10] = '57', [94] = '30'}
    based = string.format('%'..min[b2]..'s', based):gsub(' ', base[b2][0])
	return based
end

--------------------------------------------------------------------------------
--   DEBUG FUNCTIONS
--------------------------------------------------------------------------------
function medina_debug_movement()
	local debug_movement = false
    if debug_movement then
        print("room sequence:");tprint(med.sequence)
        print("queued commands:");tprint(med.commands.move)
        print("queued look commands:");tprint(med.commands.look)
    end
end

function medina_print_error(msg)
	local text_colour1, text_colour2, text_colour3 = "gray", "lightgray", "orange"
	ColourNote(
		text_colour2, "", "<",
		text_colour3, "", msg,
		text_colour2, "", ">")
end
--------------------------------------------------------------------------------
--   START EXECUTION HERE
--------------------------------------------------------------------------------
on_plugin_start()

--[[
med.rooms.Q.exits = {n = {exits = false, room = "N"}, e = {exits = false, room = "R"}, w = {exits = false, room = "P"},}
med.rooms.Q.normalized = {e = "e", n = "n", w = "w",}
med.rooms.Q.solved = os.time()]]



--local start_time = os.clock()
--print(os.clock() - start_time) --speed test

--tprint(med.rooms)
--tprint(med.exit_counts)
--tprint(med.colours)
--tprint(med.coordinates)
--tprint(med.sequence)
--tprint(med.commands.move)
--tprint(med.commands.look)
    
