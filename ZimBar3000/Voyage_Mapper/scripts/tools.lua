--------------------------------------------------------------------------------
--   EDIT TOOLS
--------------------------------------------------------------------------------
function on_alias_voyage_add_tool(name, line, wildcards, styles)
    local tool = string.lower(wildcards.tool)
    if tool ~= "" then
		if not held.tools[tool] then
			held.tools[tool] = "inventory"
			ColourNote(voy.colours.notes.text, voy.colours.notes.background, "Tool: '"..tool.."' has been added.")
		end
    else
		ColourNote(voy.colours.notes.text, voy.colours.notes.background, "Can not add blank tool!")
    end
end

function on_alias_voyage_add_container(name, line, wildcards, styles)
    local container = string.lower(wildcards.container)
    local is_already_added = false
    for i, v in ipairs(held.containers) do
        if v == container then
            is_already_added = true
            break
        end
    end
    if container ~= "" then
		if not is_already_added then
			table.insert(held.containers, container)
			ColourNote(voy.colours.notes.text, voy.colours.notes.background, "Container: '"..container.."' has been added.")
		end
	else
		ColourNote(voy.colours.notes.text, voy.colours.notes.background, "Can not add blank container!")
    end
end
--------------------------------------------------------------------------------
--   SWAP TOOLS
--------------------------------------------------------------------------------
function voyage_hold_tool(hand, new_tool)
    if held.L ~= "" and held.L == held.R and hand == "R" then
        hand = "L" 
        -- in the situation of holding duplicates in each hand it is easier to switch to left hand
        -- due to a lack of info in the mud's wording and the fact that left is default when unspecified
    end
    local old_tool = held[hand]
    local other_hand = hand == "L" and "R" or "L"
    local hand_long = hand == "L" and "left hand" or "right hand"
    if new_tool ~= old_tool then -- make sure it isn't already in hand
        if old_tool ~= "" then
            local p = (hand == "R" and old_tool == held[other_hand]) and " 2" or "" -- to avoid handling wrong weapon when dealing with duplicates
            if held.tools[old_tool] and held.tools[old_tool] ~= "inventory" then -- if container is set for old and isn't 'inventory'
                if held.tools[old_tool] == "scabbard" then
                    Send("sheathe held "..old_tool..p)
                elseif held.tools[old_tool] == "floor" then
                    Send("drop held "..old_tool..p)
                else
                    Send("put held "..old_tool..p.." in "..held.tools[old_tool])
                end
            else
                Send("unhold held "..old_tool..p)
            end
        end
        if new_tool ~= "" then
            if held.tools[new_tool] and held.tools[new_tool] ~= "inventory" then
                if held.tools[new_tool] == "scabbard" then
                    Send("draw "..new_tool.." into "..hand_long)
                elseif held.tools[new_tool] == "floor" then
                    Send("get "..new_tool)
                    Send("hold unheld "..new_tool.." in "..hand_long)
                else
                    Send("get "..new_tool.." from "..held.tools[new_tool])
                    Send("hold unheld "..new_tool.." in "..hand_long)
                end
            else
                Send("hold unheld "..new_tool.." in "..hand_long)
            end
        end
    end
end
--------------------------------------------------------------------------------
--   ATTACK / RELOAD
--------------------------------------------------------------------------------
function voyage_fire()
    if held.L == held.R and held.L == "arbalest" then
        Send("fire held arbalest 1 at monster")
        Send("fire held arbalest 2 at monster")
    else
        for i, hand in ipairs({"L", "R"}) do
            if held[hand] == "arbalest" then
                Send("fire held arbalest at monster")
            elseif held[hand] == "fire axe" then
                Send("throw held axe at monster")
            elseif held[hand] == "steel-tipped harpoon" then
                Send("throw held harpoon at monster")
            end
        end   
    end
end

function voyage_reload()
        if held.reload.L == held.reload.R and held.reload.L ~= "" then
            local amo = held.reload.L; local container = held.amo[amo]
            if container then
                if container == "floor" then
                    if held.L ~= amo and held.R ~= amo then
                        Send("get 2 "..amo.."s")
                    else
                        Send("get "..amo)
                    end
                elseif container ~= "inventory" then
                    if held.L ~= amo and held.R ~= amo then
                        Send("get 2 "..amo.."s from "..container)
                    else
                        Send("get "..amo.." from "..container)
                    end
                end
                if amo == "arbalest bolt" then
                    Send("load held arbalest 1 with bolt")
                    Send("load held arbalest 2 with bolt")
                else
                    if held.L ~= amo and held.R ~= amo then
                        Send("hold 2 "..amo.."s")
                    elseif held.L ~= amo then
                        Send("hold unheld "..amo.." in left hand")
                    else
                        Send("hold unheld "..amo.." in right hand")
                    end
                end
            end
        else
            for i, hand in ipairs({"L", "R"}) do
                if held.reload[hand] ~= "" then
                    local amo = held.reload[hand]; local container = held.amo[amo]
                    if container then
                        if container == "floor" then
                            if amo ~= "arbalest bolt" and held[hand] ~= amo then
                                Send("get "..amo)
                            end
                        elseif container ~= "inventory" then
                            if amo ~= "arbalest bolt" and held[hand] ~= amo then
                                Send("get "..amo.." from "..container)
                            end
                        end
                        if amo == "arbalest bolt" then
                            Send("load held arbalest with bolt")
                        else
                            Send("hold unheld "..amo.." in "..(hand == "L" and "left" or "right").." hand")
                        end
                    end
                end
            end
        end
    end
--------------------------------------------------------------------------------
--   TOOL TRACKING
--------------------------------------------------------------------------------
function on_trigger_voyage_tools_holding(name, line, wildcards, styles)
    local change = false
    if wildcards.left ~= held.L then
        held.L = wildcards.left
        voyage_draw_held("L")
        change = true
    end
    if wildcards.right ~= held.R then
        held.R = wildcards.right
        voyage_draw_held("R")
        change = true
    end
    if change then
        voyage_print_map()
    end
end

function on_trigger_voyage_tools_hold(name, line, wildcards, styles)
    local right, left = false, false
    if wildcards.pair ~= "" then
        left, right = wildcards.pair, wildcards.pair
    else
        if wildcards.left ~= "" then
            left = wildcards.left
        end
        if wildcards.right ~= "" then
            right = wildcards.right
        end
    end
    if left then
        held.L = left
        voyage_draw_held("L")
    end
    if right then
        held.R = right
        voyage_draw_held("R")
    end
    voyage_print_map()
end

function on_trigger_voyage_tools_unhold(name, line, wildcards, styles)
    if (wildcards.pair ~= "")
    or (wildcards.left ~= "" and wildcards.right ~= "")
    or (wildcards.tool1 ~= "" and wildcards.tool2 ~= "") then
        held.L, held.R = "", ""
        voyage_redraw_held()
    elseif wildcards.left ~= "" or wildcards.right ~= "" then
        if wildcards.left ~= "" then
            held.L = ""
            voyage_draw_held("L")
        end
        if wildcards.right ~= "" then
            held.R = ""
            voyage_draw_held("R")
        end
    elseif wildcards.tool1 ~= "" or wildcards.tool2 ~= "" then      
        if wildcards.tool1 ~= "" then
            if wildcards.tool1 == held.L then
                held.L = ""
                voyage_draw_held("L")
            elseif wildcards.tool1 == held.R then
                held.R = ""
                voyage_draw_held("R")
            end
        end
        if wildcards.tool2 ~= "" then
            if wildcards.tool1 == held.R then
                held.R = ""
                voyage_draw_held("R")
            elseif wildcards.tool1 == held.L then
                held.L = ""
                voyage_draw_held("L")
            end
        end
    end
    voyage_print_map()
end

function on_trigger_voyage_tools_draw(name, line, wildcards, styles)
    local hand = wildcards.L ~= "" and "L" or "R"
    held[hand] = wildcards.tool
    voyage_draw_held(hand)
    voyage_print_map()
end

function on_trigger_voyage_tools_sheathe(name, line, wildcards, styles)
    local function to_num(text) -- replace written words with integers 
        local numbers = {"the", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen", "twenty", "many"}
        for i, word in ipairs(numbers) do
            text = text:gsub(" "..word.." ", " "..i.." "):gsub("^"..word.." ", i.." "):gsub(" "..word.."$", " "..i)	
        end
        text = text:gsub(" an? ", " 1 "):gsub("^an? ", "1 "):gsub(" an?$", " 1")	
        return text
    end
    local tools = to_num(string.lower(wildcards.tools)):gsub(" and ", ", "):gsub("[.,] ", ",")
    local right, left = false, false
    for stuff in string.gmatch(tools, '([^,]+)') do
        stuff = stuff:gsub("^(%D+)", "1 %1")
        local n, s = stuff:match("^(%d+) (.*) ?$")
        n = tonumber(n)     
        if n and s then
            for i = 1, (n > 1 and 2 or 1) do
                if held.L and (s == held.L or s == held.L..'s') and not left then
                    left = true
                elseif held.R and (s == held.R or s == held.R..'s') and not right then
                    right = true
                end
            end
            if left and right then break end
        end
    end
    if left then
        held.L = ""
        voyage_draw_held("L")
    end
    if right then
        held.R = ""
        voyage_draw_held("R")
    end
    voyage_print_map()
end


function on_alias_voyage_debug_held()
	tprint(held)
end

function on_alias_voyage_reset_held()
	voyage_get_held()
end


