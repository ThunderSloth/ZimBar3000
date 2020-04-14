--------------------------------------------------------------------------------
--   CONSTRUCT TRIGGERS
--------------------------------------------------------------------------------
-- room triggers
function medina_get_trigs()
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
            group ='medina_rooms',
            name = 'medina_room_'..name,
            script = script,
            multi_line = 'y',
            count = count,
            keep_evaluating = 'y',
            regexp = 'y',
            sequence = 100,}
    end
	
	triggers[14] = {} -- remove duplicate (H or N)
	
	-- if we send directly to script there will be timing issues cause by other
	-- plugins altering our style runs, so we must inject xml into the send field
	-- we need our style runs unaltered so that we can determine players
	-- without false positives
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

    for _, v in pairs(triggers) do
        if v.match then
            AddTrigger(v.name, v.match, "", trigger_flag.KeepEvaluating + trigger_flag.IgnoreCase + trigger_flag.RegularExpression, custom_colour.NoChange, 0, "", v.script)
            SetTriggerOption (v.name, "group", v.group)
            SetTriggerOption (v.name, "multi_line", "y")
            SetTriggerOption (v.name, "lines_to_match", v.count)
            SetTriggerOption (v.name, "enabled", "y")
            SetTriggerOption (v.name, "sequence", sequence)
			SetTriggerOption (v.name, "send_to", 12)
            local trig = get_xml_injection( ExportXML (0, v.name) )
            ImportXML (trig);--print(trig)
        end
    end
    
    local tracking = {"enter", "exit"} 
    for _, v in ipairs(tracking) do
        local f = io.open(GetPluginInfo(GetPluginID (), 20):gsub("\\([A-Za-z_]+)\\$", "\\shared\\")..v..".txt", 'r')
		local match_on = Trim(assert(f:read("*a"), "Can't locate "..v..".txt"))
		AddTrigger("medina__mob_"..v, match_on, "", trigger_flag.KeepEvaluating + trigger_flag.IgnoreCase + trigger_flag.RegularExpression, custom_colour.NoChange, 0, "", "on_trigger_medina_mob_track")
		f:close()
		SetTriggerOption ("medina__mob_"..v, "group", "medina")
		SetTriggerOption ("medina__mob_"..v, "send_to", 12)
    end

	for i, v in ipairs({"medina_room_brief", "medina_mob_enter", "medina_mob_exit"}) do
		ImportXML ( get_xml_injection( ExportXML (0, v) ) )
    end
end
