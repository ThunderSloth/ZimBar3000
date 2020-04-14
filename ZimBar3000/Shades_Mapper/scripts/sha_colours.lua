--------------------------------------------------------------------------------
--   COLOURS
--------------------------------------------------------------------------------
function shades_get_colours()
    local col = {
        window = {
            background = "black",
            border =     "white",
            transparent ="teal",},
        title = {
            text =       "black",
            border =     "white",
            fill =       "lightgray",},
        rooms = {
            border =     "white",
            background = "black",
            visited =    "gray",
            unvisited =  "lightblue",
            scry1 =      "white", 
            scry2 =      "gray",},
        exits = {
            border =     "gray",
            background = "black",
            line =       "gray",
            special =    "white",
            numbers =   {"#a9a9a9", "#ff0000", "#ff7f00", "#9b870c", "#228b22", "#0000ff", "#9370db", "#ba55d3",},},
        arrows = {
            border =     "white",
            fill =       "white",},
        thyngs = {
            you =        "yellow",
            ghost =      "yellow",
            xp = {"#003300", "#004c00", "#006600", "#007f00", "#009900", "#00b200", "#00cc00", "#00e500", "#00ff00",},},
        text = {      
			xp = {"#808080", "#a9a9a9", "#c0c0c0", "#ffffff"},
			players =    "black",
			path =       "cornflowerblue",},
        note = {
            bracket =   "white",
            error =     "red",
            text =      "gray",},}

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
