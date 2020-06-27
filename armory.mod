return {
	run = function()
		fassert(rawget(_G, "new_mod"), "armory must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("armory", {
			mod_script       = "scripts/mods/armory/armory",
			mod_data         = "scripts/mods/armory/armory_data",
			mod_localization = "scripts/mods/armory/armory_localization"
		})
	end,
	packages = {
		"resource_packages/armory/armory"
	}
}
