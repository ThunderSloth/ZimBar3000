--------------------------------------------------------------------------------
--   VERBOSE ROOM DESCRIPTION TRIGGER EVENT
--------------------------------------------------------------------------------
function on_trigger_shades_verbose(name, line, wildcards, styles)
	local s = name:match('%w+$')
	local room = {}
	for r in string.gmatch(s, '.') do
	  table.insert(room, r)
	end
    if wildcards.title ~= '' and sha.is_in_shades then
		if wildcards.thyngs ~= '' then
			on_trigger_shades_mob_track("here", line, {thyngs = wildcards.thyngs}, styles, sha.sequence[1])
		else
			shades_move_room(room)
		end
	else
	    if wildcards.thyngs ~= '' then
			on_trigger_shades_mob_track("here", line, {thyngs = wildcards.thyngs}, styles, sha.scry_room)
		else
			shades_scry_room(room)
		end		
	end
end


--------------------------------------------------------------------------------
--   BRIEF ROOM DESCRIPTION TRIGGER EVENTS
--------------------------------------------------------------------------------
function on_trigger_shades_brief_entrance(name, line, wildcards, styles)
	local room = {"G"}
    if wildcards.thyngs ~= '' then
		on_trigger_shades_mob_track("here", line, {thyngs = wildcards.thyngs}, styles, sha.sequence[1])
    else
		shades_move_room(room)
    end
end

function on_trigger_shades_brief(name, line, wildcards, styles)
	local r= {{}, {}, {}, {"A", "B", "F", "O", "P", "Q"}, {"C", "L"}, {"H"}, {"D", "E", "K", "M", "N"}, {"I", "J"},}
	local room = r[tonumber(wildcards.exits)]
    if wildcards.thyngs ~= '' then
		on_trigger_shades_mob_track("here", line, {thyngs = wildcards.thyngs}, styles, sha.sequence[1])
	else
		shades_move_room(room)
	end
end
-------------------------------------------------------------------------------
--  CONSTRUCT TRIGGERS
-------------------------------------------------------------------------------
function shades_get_trigs()
    local desc = {
        title = {"somewhere in the Shades", "maze entrance",}, -- entrance = G
        scry  = "(?<scry>.*)",
        map = "([@ ]+\\n)?",
        G_map = "(.*?@.*?\\n)?([| ]+\\n)?",
        moon  = "((It is night and|The (water|land) is lit up by) the.*(?<moon>(crescent|(three )?quarter|half|gibbous|no|full) moon)( is hidden by the clouds)?.\\n)?",
        long = {
            "Deep, deep into the Shades. This alley is like every other alley in this rabbit warren of death.  It is dank, dark and foggy, everything looks the same...",
            "The alleyways here all look the same.  Dim fires flicker in the distance, providing more a kind of glow than real light.",
            "There is no hope of ever escaping this nightmare.  Grime covers the walls, and the dank slime underfoot makes walking slippery.  The ever present fog and gloom makes trying to see a way out impossible.",
            "There is no hope of ever escaping this nightmare.  Grime covers the walls, and the dank slime underfoot makes walking slippery.  The ever present fog and gloom makes trying to see a way out impossible.",
            "This room is like any of the other alleyways, dank, dark and foggy.  It has lots of exits that lead to other dank, dark and foggy alleyways.  Howls of fear and pain echo around from the walls.",
            "duplicate: BFOQ",
            "This is deep in the Shades.  What passes for civilization in these parts is to the west, but otherwise there are three alleyways in weaving twisting directions which don't appear on any compass.  Further in is a deadly maze of dangerous alleyways.",
            "There is no hope of ever escaping this nightmare.  Grime covers the walls, and the dank slime underfoot makes walking slippery.  The ever present fog and gloom makes trying to see a way out impossible.",
            "The Lady is evidently not on your side; at every turn lies another twisting alleyway.  Dim torches flicker red through the fog, providing more a sinister red glow than any real light.",
            "There is no hope of ever escaping this nightmare.  Grime covers the walls, and the dank slime underfoot makes walking slippery.  The ever present fog and gloom makes trying to see a way out impossible.",
            "This rabbit warren of smoky, hazy alleys is never ending.  The gloom and fog mask the direction of the screams that echo in the distance...",
            "This dark, dank, foggy alleyway leads to other dark dank foggy alleyways.  The gloom hides the worst of the horrors that these alleys contain.",
            "The alleyways here all look the same.  Dim fires flicker in the distance, providing more a kind of glow than real light.",
            "duplicate: DN",
            "duplicate: BFOQ",
            "Deep, deep into the Shades. This alleyway is like every other alleyway in this rabbit warren of death.  It is dank, dark and foggy, everything looks the same...",
            "duplicate: BFOQ",
        },
        extra1   = "(?<extra1>.*\\n)?",
        extra2   = "(?<extra2>.*\\n)?",
        weather1 = "(?<weather1>It is an? .*)\\n",
        weather2 = "(?<weather2>(?!.* obvious exits:).*\\n)?",
        thyngs   = "(\\n(?<thyngs>.* here.))?\\Z",
    }
    desc.not_moon = desc.moon:gsub("[(][?]<moon>[(]crescent|[(]three [)][?]quarter|half|gibbous|no|full[)] moon[)]", "moon"):gsub("\\n[)][?]", ")"):gsub("^[(]", "(?!")

    for i, v in ipairs(desc.title) do
      desc.title[i] = '(?<title>\\['..v..'\\])'
    end

    local triggers = {}
    for i = 1, 17 do
        local letter = string.char(i + 64)
        local regex = '^'
        local count = 4
		if letter  == 'G' then
			regex = regex..'('..desc.title[2]..'|'..desc.not_moon..desc.scry..')\\n'..desc.G_map..desc.moon..desc.long[i]
			count = count + 1		
		else
			regex = regex..'('..desc.title[1]..'|'..desc.not_moon..desc.scry..')\\n'..desc.map..desc.moon..desc.long[i]
		end
		regex = regex..'\\n'
		local order = {'extra1', 'extra2', 'weather1', 'weather2', 'exits', 'thyngs'}
		for _, k in ipairs(order) do
			if k == 'exits' then
				local n = #sha.rooms[letter].exits
				local num = {'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine'}
				local exits = '(?<exits>There are (?(?=.* enter door.)'..num[(n + 1)]..'|'..num[(n)]..') obvious exits: .*)'
				if letter  == 'G' then
					exits = "(?<exits>There are .* obvious exits: .*)"
				end
				regex = regex..exits
			else
				regex = regex..desc[k]
			end
			count = count + 1
		end

        local name = letter
        if name:match("[BFOQ]") then
            name = 'BFOQ'
        elseif name:match("[DN]") then
            name = 'DN'
        end

        local script = 'on_trigger_shades_verbose'
        
        triggers[i] = {
            match = regex,
            group ='shades_rooms',
            name = 'shades_verbose_'..name,
            script = script,
            multi_line = "y",
            count = count,
            keep_evaluating = 'y',
            regexp = 'y',
            sequence = '100',}
    end
    
    for _, i in ipairs({6, 14, 15, 17}) do
        triggers[i] = {} -- remove duplicates
    end
    
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
			        sha.players[string.lower(Trim(v.text))] = v.textcolour
			    end
			  end
			end
			</send>]]):gsub('\t\t\t', '')
		return xml:gsub('"%s*>',  '">\n' .. code)
	end

    for _, v in pairs(triggers) do
        if v.match then
            check(AddTrigger(v.name, v.match, "", trigger_flag.KeepEvaluating + trigger_flag.IgnoreCase + trigger_flag.RegularExpression, custom_colour.NoChange, 0, "", v.script))
            SetTriggerOption (v.name, "group", v.group)
            SetTriggerOption (v.name, "multi_line", v.multi_line)
            if v.multi_line == 'y' then
                SetTriggerOption (v.name, "lines_to_match", v.count)
            end
            SetTriggerOption (v.name, "enabled", "y")
			SetTriggerOption (v.name, "send_to", 12)
            local trig = get_xml_injection( ExportXML (0, v.name) )
            ImportXML (trig)
        end
    end
    
    local tracking = {"enter", "exit"} 
    for _, v in ipairs(tracking) do
        local f = io.open(SHA_PATH:gsub("\\([A-Za-z_]+)\\$", "\\shared\\")..v..".txt", 'r')
		local match_on = Trim(assert(f:read("*a"), "Can't locate "..v..".txt"))
		check(AddTrigger("shades_mob_"..v, match_on, "", trigger_flag.KeepEvaluating + trigger_flag.IgnoreCase + trigger_flag.RegularExpression, custom_colour.NoChange, 0, "", "on_trigger_shades_mob_track"))
		f:close()
		SetTriggerOption ("shades_mob_"..v, "group", "shades")
		SetTriggerOption ("shades_mob_"..v, "send_to", 12)
    end

	for i, v in ipairs({"shades_room_brief", "shades_mob_enter", "shades_mob_exit"}) do
		ImportXML ( get_xml_injection( ExportXML (0, v) ) )
    end
    
end

