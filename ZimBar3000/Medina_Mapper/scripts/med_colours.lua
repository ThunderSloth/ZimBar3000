--------------------------------------------------------------------------------
--   COLOURS
--------------------------------------------------------------------------------
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
            herd_path =  "cyan",
            look1 =      "white", 
            look2 =      "gray",
            scry =       "white",
            visited =    "gray",
            unvisited =  "lightblue",},
        exits = {
            solved =     "gray",
            unsolved =   "red",
            halfsolved = "gray",
            static =     "white",
            bracket =    "white",
            comma =      "white",},
        thyngs = {
            you =        "yellow",
            ghost =      "yellow",
            boss =       "fuchsia",
            xp = {"#003300", "#004c00", "#006600", "#007f00", "#009900", "#00b200", "#00cc00", "#00e500", "#00ff00",},},
        text = {      
			xp = {"#808080", "#a9a9a9", "#c0c0c0", "#ffffff"},
			players =    "black",
			path =       "cornflowerblue",},
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
