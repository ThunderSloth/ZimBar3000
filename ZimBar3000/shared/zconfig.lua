function run_config()    

    function on_trigger_option(name, line, wildcards, styles)
        local k1, k2 = name:match("^(.*)_(%w+)$")
        k1 = k1:gsub("_", " ")
        if not wildcards.option:match(options[k1][k2]) then
            zconfig = zconfig..(k1.." "..k2.." = "..options[k1][k2])..";"
        end
    end
    
    function on_trigger_playername(name, line, wildcards, styles)
		if wildcards.p_colour == "none" then
			zconfig = zconfig.."options colour playername = cyan;"
			was_player_colour_altered = true
		end
    end

    function on_trigger_zoption_removed(name, line, wildcards, styles)
        if #zconfig == 0 then
            print("\nYou are already configured!")
        else
            AddTrigger("zconfig_added", '^\\w+ alias "zconfig"', "", trigger_flag.Enabled + trigger_flag.Temporary + trigger_flag.RegularExpression + trigger_flag.OneShot + trigger_flag.KeepEvaluating + trigger_flag.Replace, -1, 0, "", "on_trigger_zconfig_added")
            Send("alias zconfig "..zconfig.."unalias zconfig")
        end
    end
    
    function on_trigger_zconfig_added(name, line, wildcards, styles)
        AddTrigger("zconfig_removed", '^Successfully unaliased "zconfig":.*$', "", trigger_flag.Enabled + trigger_flag.Temporary + trigger_flag.RegularExpression + trigger_flag.OneShot + trigger_flag.KeepEvaluating + trigger_flag.Replace, -1, 0, "", "on_trigger_zconfig_removed")
        Send("zconfig")
    end    
    
    function on_trigger_zconfig_removed(name, line, wildcards, styles)
		if was_player_colour_altered then
			print("Your 'playername' colour option must be set.\nIt has been changed to: cyan. You may change it to any colour you'd like.\nIt is also reccomended that you set 'groupmate' and 'playerkiller' too, although not required.")
		end
		print("\nConfiguration complete!") 
    end
    
    options = {
        ["options terminal"] = {
            type = "network",
        },
        ["options combat monitor"] = {
            state = "on",
        },
        ["options mxp"] = {
            enabled = "on",
            livingmenus = "off",
            objectmenus = "off",
        },
        ["options output"] = {
            combat = "verbose",
            prompt = "off",
            shortinlong =  "on",
            numbers = "numeric",
            aciiart = "on",
            usercolour = "on",
        },
        ["options output map"] = {
            frame = "off",
            glance = "top",
            glancecity = "top",
            look = "top",
            lookcity = "top",
            plain = "off",
            reversecolour = "off",
            written = "off",
            mxp = "off",
        },
    }
	was_player_colour_altered = false
	
    zoption, zconfig = "", ""
     for k1, t in pairs(options) do
        for k2, v in pairs(t) do
            local m = "^\\s+"..k2.."\\s+= (?<option>\\w+) .*$"
            local name = (k1.."_"..k2):gsub(" ", "_")
            AddTrigger(name, m, "", trigger_flag.Enabled + trigger_flag.Temporary + trigger_flag.RegularExpression + trigger_flag.OneShot + trigger_flag.KeepEvaluating + trigger_flag.Replace, -1, 0, "", "on_trigger_option") 
        end
        zoption = zoption..k1..";"
    end
    
    AddTrigger("playername", "^Colour playername\\s+= [[](?<p_colour>\\w+)[]].*", "", trigger_flag.Enabled + trigger_flag.Temporary + trigger_flag.RegularExpression + trigger_flag.OneShot + trigger_flag.KeepEvaluating + trigger_flag.Replace, -1, 0, "", "on_trigger_playername") 

    AddTrigger("zoption_removed", '^Successfully unaliased "zoption":.*$', "", trigger_flag.Enabled + trigger_flag.Temporary + trigger_flag.RegularExpression + trigger_flag.OneShot + trigger_flag.KeepEvaluating + trigger_flag.Replace, -1, 0, "", "on_trigger_zoption_removed")
        
    Send("alias zoption "..zoption.."options colour playername;".."unalias zoption");Send("zoption")
    
end

run_config()
