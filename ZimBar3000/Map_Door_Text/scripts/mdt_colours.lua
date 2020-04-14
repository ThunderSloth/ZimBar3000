--------------------------------------------------------------------------------
--   COLOURS
--------------------------------------------------------------------------------
function mdt_get_colours()
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
            exits =      "lightgray",
            doors =      "red",
            entrance =   "white",
            fight =      "red",},
        thyngs = {
            you =        "yellow",
            ghost =      "yellow",
            priests =    "orange",
            money =      "mediumorchid",
            xp = {       "#003300", "#004c00", "#006600", "#007f00", "#009900", "#00b200", "#00cc00", "#00e500", "#00ff00",},},
        text = {      
			xp = {       "#696969", "#808080", "#a9a9a9", "#c0c0c0", "#ffffff"},
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
