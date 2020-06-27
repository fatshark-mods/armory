local mod = get_mod("armory")

return {
	name = "Armory",
	description = mod:localize("mod_description"),

	options_widgets = {
		{
			["setting_name"] = "open_armory_view",
			["widget_type"] = "keybind",
			["text"] = mod:localize("open_armory_view"),
			["tooltip"] = mod:localize("open_armory_view_tooltip"),
			["default_value"] = {},
			["action"] = "open_armory_view"
		}
	},

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