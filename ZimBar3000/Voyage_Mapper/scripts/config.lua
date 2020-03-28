--------------------------------------------------------------------------------
--   CONFIGURATION
--------------------------------------------------------------------------------
function on_alias_voyage_configure(name, line, wildcards)
    local function run_config(t)
        local function print_t(t, path, str)
            local path, str = path or {}, str or ""
            if type(t) == "table" then
                for k, v in pairs(t) do
                    table.insert(path, k)
                    str = print_t(v, path, str)
                    table.remove(path, #path)
                end
                return str
            else
                local s = ""
                for i, v in ipairs(path) do
                    if type(v) ~= "number" then
                        s = s.." "..v
                    end
                end
                return str..s.." "..t..";"
            end
        end
        Send("alias zconfig"..print_t(t).."frimble *** configuration complete! ***")
        Send("zconfig")
    end
    local config = {
        cols = {80},
        term = {"ansi", "network"},
        options = {
            combat = {
				"monitor state=on"
			},
            mxp = {
				"enabled=on", 
				"objectmenus=off", 
				"livingmenus=off",
			},
            output = {
                "combat=verbose",
                "prompt=off",
                "shortinlong=on",
                "usercolour=on",
                "numbers=numeric",
                "look=verbose",
                "asciiart=on",
                map = {
                    "frame=off", 
                    "glance=top", 
                    "glancecity=top", 
                    "look=top", 
                    "lookcity=top", 
                    "plain=off", 
                    "reversecolour=off", 
                    "written=off", 
                    "mxp=off",
                },
            },
        },
    }
    run_config(config)
end

function voyage_request_config()
    local col = voy.colours.notes
    Note("")
    ColourTell(col.text, "", "Please run: '")
    Hyperlink ("voyage configure", "Voyage Configure", "Run Voyage Configuration", "orange", "", 0)
    ColourNote(col.text, "", "' to ensure compatibility, if you have not already done so. (This will change your MUD-side settings.)")
    Note("")
end
