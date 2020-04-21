function run_mush_config()
	local world_options = {
		alternative_inverse = 0,
		alt_arrow_recalls_partial = 0,
		always_record_command_history = 0,
		arrows_change_history = 1,
		arrow_keys_wrap = 0,
		arrow_recalls_partial = 0,
		autosay_exclude_macros = 0,
		auto_allow_files = 0,
		auto_copy_to_clipboard_in_html = 0,
		auto_pause = 1,
		keep_pause_at_bottom = 0,
		auto_repeat = 0,
		auto_resize_command_window = 0,
		auto_resize_minimum_lines = 1,
		auto_resize_maximum_lines = 20,
		auto_wrap_window_width = 0,
		carriage_return_clears_line = 0,
		chat_foreground_colour = 255,
		chat_background_colour = 0,
		chat_max_lines_per_message = 0,
		chat_max_bytes_per_message = 0,
		chat_port = 4050,
		confirm_on_paste = 1,
		confirm_on_send = 1,
		connect_method = 0,
		convert_ga_to_newline = 0,
		custom_16_is_default_colour = 0,
		detect_pueblo = 1,
		do_not_add_macros_to_command_history = 0,
		do_not_show_outstanding_lines = 0,
		display_my_input = 1,
		double_click_inserts = 0,
		double_click_sends = 0,
		echo_colour = 0,
		echo_hyperlink_in_output_window = 1,
		edit_script_with_notepad = 0,
		enable_aliases = 1,
		enable_beeps = 1,
		enable_scripts = 1,
		enable_spam_prevention = 0,
		enable_speed_walk = 0,
		disable_compression = 0,
		do_not_translate_iac_to_iac_iac = 0,
		enable_timers = 1,
		enable_triggers = 1,
		enable_trigger_sounds = 1,
		keep_commands_on_same_line = 0,
		script_errors_to_output_window = 1,
		ignore_mxp_colour_changes = 0,
		line_information = 1,
		line_spacing = 0,
		no_echo_off = 0,
		flash_taskbar_icon = 0,
		ignore_chat_colours = 0,
		indent_paras = 1,
		keypad_enable = 1,
		mud_can_change_link_colour = 1,
		mud_can_remove_underline = 0,
		mud_can_change_options = 1,
		mxp_debug_level = 0,
		naws = 0,
		output_font_charset = 0,
		paste_commented_softcode = 0,
		paste_delay = 0,
		paste_delay_per_lines = 1,
		paste_echo = 0,
		play_sounds_in_background = 1,
		pixel_offset = 1,
		send_echo = 0,
		send_file_commented_softcode = 0,
		send_file_delay = 0,
		send_file_delay_per_lines = 1,
		send_keep_alives = 0,
		show_connect_disconnect = 1,
		spell_check_on_send = 0,
		start_paused = 0,
		tool_tip_visible_time = 5000,
		tool_tip_start_time = 400,
		translate_backslash_sequences = 0,
		underline_hyperlinks = 1,
		unpause_on_send = 1,
		use_mxp = 0,
		utf_8 = 0,
		warn_if_scripting_inactive = 1,}
	for k, v in pairs(world_options) do
		SetOption (k, v)
	end
end

function run_mud_config()    

    function on_trigger_option(name, line, wildcards, styles)
        local k1, k2 = name:match("^(.*)_(%w+)$")
        k1 = k1:gsub("_", " ")
        if not wildcards.option:match(mud_options[k1][k2]) then
            zconfig = zconfig..(k1.." "..k2.." = "..mud_options[k1][k2])..";"
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
            ColourNote("gray", "", "\nYou are already configured!")
        else
            AddTrigger("zconfig_added", '^.?\\w+ alias "zconfig"', "", trigger_flag.Enabled + trigger_flag.Temporary + trigger_flag.RegularExpression + trigger_flag.OneShot + trigger_flag.KeepEvaluating + trigger_flag.Replace, -1, 0, "", "on_trigger_zconfig_added")
            Send("alias zconfig "..zconfig.."unalias zconfig")
        end
    end
    
    function on_trigger_zconfig_added(name, line, wildcards, styles)
        AddTrigger("zconfig_removed", '^.?Successfully unaliased "zconfig":.*$', "", trigger_flag.Enabled + trigger_flag.Temporary + trigger_flag.RegularExpression + trigger_flag.OneShot + trigger_flag.KeepEvaluating + trigger_flag.Replace, -1, 0, "", "on_trigger_zconfig_removed")
        Send("zconfig")
    end    
    
    function on_trigger_zconfig_removed(name, line, wildcards, styles)
		if was_player_colour_altered then
			ColourTell("gray", "", "Playername colour must be set. It has been changed to: ")
			ColourTell("black", "cyan", "cyan.");ColourNote("gray", "", "\nYou may change it to any colour you'd like.\n")
		end
		ColourNote("gray", "", "Configuration complete!") 
    end
    
    mud_options = {
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
     for k1, t in pairs(mud_options) do
        for k2, v in pairs(t) do
            local m = "^.?\\s+"..k2.."\\s+= (?<option>\\S+) .*$"
            local name = (k1.."_"..k2):gsub(" ", "_")
            AddTrigger(name, m, "", trigger_flag.Enabled + trigger_flag.Temporary + trigger_flag.RegularExpression + trigger_flag.OneShot + trigger_flag.KeepEvaluating + trigger_flag.Replace, -1, 0, "", "on_trigger_option")
        end
        zoption = zoption..k1..";"
    end
    
    AddTrigger("playername", "^.?Colour playername\\s+= [[](?<p_colour>\\w+)[]].*", "", trigger_flag.Enabled + trigger_flag.Temporary + trigger_flag.RegularExpression + trigger_flag.OneShot + trigger_flag.KeepEvaluating + trigger_flag.Replace, -1, 0, "", "on_trigger_playername")

    AddTrigger("zoption_removed", '^.?Successfully unaliased "zoption":.*$', "", trigger_flag.Enabled + trigger_flag.Temporary + trigger_flag.RegularExpression + trigger_flag.OneShot + trigger_flag.KeepEvaluating + trigger_flag.Replace, -1, 0, "", "on_trigger_zoption_removed")
        
    Send("alias zoption "..zoption.."options colour playername;".."unalias zoption");Send("zoption")
    
end
ColourNote("gray", "", "Running configuration:")
run_mush_config()
run_mud_config()
