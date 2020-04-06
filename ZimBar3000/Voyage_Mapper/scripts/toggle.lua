--------------------------------------------------------------------------------
--  ENTER
--------------------------------------------------------------------------------
function voyage_enter()
    if not(voy.is_in_voyage) then
        local function reset_map(coor, dim, col, mw)
            voyage_draw_hull_upper(coor, col.hull.defualt, mw)
            voyage_draw_hull_lower(coor, col.hull.defualt, mw)
            voyage_draw_part(coor, col, mw)
            voyage_draw_stage(coor, col, mw)
            voyage_draw_guages(dim, col)
        end
        voyage_request_config()
        voyage_reset_metatable()
        voyage_reset_xp()
        voy.is_in_voyage = true
        reset_map(voy.coordinates, voy.dimensions, voy.colours, win.."underlay")
        EnableGroup("voyage", true)
        EnableTimer("ticker", true)
        voyage_get_hotspots(voy.dimensions)
    end
end
--------------------------------------------------------------------------------
--  EXIT
--------------------------------------------------------------------------------
function voyage_exit()
    if voy.is_in_voyage then
        voyage_reset_metatable()
        EnableGroup("voyage", false)
        EnableTimer("ticker", false)
        xp_t.is_need_final_xp = true
        xp_t[6].time = os.time()
    end
end
