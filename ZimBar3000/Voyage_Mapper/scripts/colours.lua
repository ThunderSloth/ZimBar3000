--------------------------------------------------------------------------------
--   COLOURS
--------------------------------------------------------------------------------
function voyage_get_colours()
    local col = {
        window = {
            background = "black",
            border =     "white",
            transparent ="teal",},
        title = {
            text =       "black",
            border =     "white",
            fill =       "lightgray",
            lightning =  "red",
            serpent =    "fuchsia",
            kraken =     "fuchsia",},
        rooms = {
            border =     "white",
            background = "black",
            boiler =     "red",
            bridge =     "tan",
            wheel =      "gray",
            water =      "blue",
            letter =     "lightblue",
            fire =       "red",
            ice =        "cyan",},
        exits = {
            border =     "lightgray",
            background = "black",},
        doors = {
            border =     "white",
            background = "black",},
        hull = {
            default =    "gray",
            fade =       "white",
            damage =     "red",
            ice =        "cyan",
            seaweed =    "lawngreen",
            hull =       "lightcoral",},
        thyngs = {
            you =        "yellow",
            look =       "white",
            ghost =      "yellow",
            players =    "white",
            numbers =    "white",
            rope =       "orange",
            cleat =      "gray",
            lightning =  "red",
            serpent =    "fuchsia",
            kraken =     "fuchsia",},
        objects = {
            item =       "dimgray",
            zero =       "dimgray",
            some =       "darkgray",
            held =       "lightsteelblue",},
        dragons = {
            aggy  =      "green",
            idiot  =     "red",
            nugget  =    "purple",
            bitey  =     "blue",
            asleep =     "lightgray",
            circle =     "red",},
		sea = {
			frame =      "white",
			x =          "lightgray",
			grid =       "black",
			notch =      "gray",
			wheel =      "yellow",
			direction =  "orange",
			water =      "blue",
			ripple =     "dodgerblue",
			wake =       "dodgerblue",
			current =    "dodgerblue",
			whirlpool =  "dodgerblue",
			seaweed =    "limegreen",
			reef =       "fuchsia",
			land =      {"orange",    "forestgreen"         },
			boat =      {"sienna",    "silver"              },  
			debris =    {"burlywood", "sienna"              },
			wood =      {"sienna",    "burlywood"           },                 
			turtle =    {"silver",    "olivedrab"           },
			flow =      {"white",     "cyan"                },
			fog =       {"white",     "lightgray",  "gray"  },                
			iceberg =   {"cyan",      "white",      "silver"},
			outcrop =   {"gray",      "silver"              },
			cove =      {"gray",      "silver",     "black" },
		},
        notes = {
            background = "black",
            partial =    "gray",
            error =      "red",
            link =       "yellow",
            text =       "cornflowerblue",},}
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
