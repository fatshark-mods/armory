local mod = get_mod("armory")

return {
	name = "Armory",
	description = mod:localize("mod_description"),

    options = {
        widgets = {
            {
                setting_id = "open_armory_view",
                type = "keybind",
                default_value = {},
                keybind_global = false,
                keybind_trigger = "pressed",
                keybind_type = "function_call",     --[[ function_call, view_toggle, mod_toggle ]]
                function_name = "open_armory_view", -- Used w/ keybind_type = "function_call"
                --view_name = "armory_view",        -- Used w/ keybind_type = "view_toggle", must be nil otherwise
                transition_data = {                 -- Used w/ keybind_type = "view_toggle"
                    open_view_transition_name = "open_armory_view",

                    close_view_transition_name = "close_armory_view",

                    transition_fade = true
                },
            }
        },
    },
    
	--options_widgets = {
	--	{
	--		["setting_name"] = "open_armory_view",
	--		["widget_type"] = "keybind",
	--		["text"] = mod:localize("open_armory_view"),
	--		["tooltip"] = mod:localize("open_armory_view_tooltip"),
	--		["default_value"] = {},
	--		["action"] = "open_armory_view"
	--	}
	--},

    custom_gui_textures = {
        textures = {
            "gui/armory/armory_atlas"
        },
        atlases = {
            {
                "materials/armory/armory_atlas",
                "armory_atlas",
                "armory_atlas_masked"
            }
        },
        ui_renderer_injections = {
            {
                "ingame_ui",
                "materials/armory/armory_atlas",
            },
        },
    },
}