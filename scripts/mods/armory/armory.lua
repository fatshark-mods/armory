local mod = get_mod("armory")

mod.refresh_power_levels = function (profile_name, career_name)

    mod.power_level = BackendUtils.get_total_power_level(profile_name, career_name)
    mod.scaled_cleave_power_level = ActionUtils.scale_power_levels(mod.power_level, "cleave", nil, "hardest")
    mod.scaled_attack_power_level = ActionUtils.scale_power_levels(mod.power_level, "attack", nil, "hardest")

end

--mod:dofile("scripts/mods/armory/widgets/armory_widgets")
--mod:dofile("scripts/mods/armory/armory_view/armory_view")
mod:dofile("scripts/mods/armory/hero_view_state_armory")
mod:dofile("scripts/mods/armory/armory_weapon_preview")

--local view_data = {
--    view_name = "armory_view",
--    view_settings = {
--        init_view_function = function (ingame_ui_context)
--            return ArmoryView:new(ingame_ui_context)
--        end,
--        active = {
--            inn = true,
--            ingame = false
--        },
--        blocked_transitions = {
--            inn = {},
--            ingame = {}
--        }
--    },
--    view_transitions = {
--        open_armory_view = function (ingame_ui)
--            ingame_ui.current_view = "armory_view"
--        end,
--        close_armory_view = function (ingame_ui)
--            ingame_ui.current_view = nil
--        end
--    }
--}
--mod:register_view(view_data)

if IngameMenuKeymaps.win32 then
    IngameMenuKeymaps.win32.right_hold = {
        "mouse",
        "right",
        "held"
    }
    IngameMenuKeymaps.win32.shift_hold = {
        "keyboard",
        "left shift",
        "held"
    }
    IngameMenuKeymaps.win32.ctrl_hold = {
        "keyboard",
        "left ctrl",
        "held"
    }
end

-- Insert our custom view as a child state of HeroView
mod:hook(HeroView, "init", function (orig_func, self, ingame_ui_context)

    local result = orig_func(self, ingame_ui_context)

    local armory = {
        name = "armory",
        state_name = "HeroViewStateArmory",
        hotkey_disabled = true,
        draw_background_world = false,
        camera_position = {
            0,
            0,
            0
        },
        camera_rotation = {
            0,
            0,
            0
        },
        contains_new_content = function ()
            return false
        end
    }
    local settings_by_screen = self._state_machine_params.settings_by_screen

    local found = false
    for index, screen in ipairs(settings_by_screen) do
        if screen.name == "armory" then
            found = true
            break
        end
    end
    if not found then table.insert(settings_by_screen, armory) end

    mod.ingame_ui_context = ingame_ui_context

    return result
end)

mod:hook_safe(StateInGameRunning, "update", function (self)
    if not mod.ingame_ui_context then
        mod.ingame_ui_context = self.ingame_ui_context
        mod:hook_disable(StateInGameRunning, "update")
    end
end)

local function get_upvalue_by_name(obj, upvalue_name)
    for _, v in pairs(obj) do
        if type(v) == "function" then
            local debug_info = debug.getinfo(v)
            local func = debug_info.func
            local upvalues_n = debug_info.nups

            for i = 1, upvalues_n do
                local up_name, up_value = debug.getupvalue(func, i)
                if up_name == upvalue_name then
                    mod:echo(up_value)
                    return up_value, i, v
                end
            end

        end
    end
end

local function set_upvalue_by_name(obj, upvalue_name, new_value)
    local upvalue, upvalue_index, func = get_upvalue_by_name(obj, upvalue_name)
    debug.setupvalue(func, upvalue_index, new_value)
end

mod:hook(Unit, "get_data", function(func, unit, ...)
    if unit == nil or not unit then
        return
    end

    return func(unit, ...)
end)

set_upvalue_by_name(ActionUtils, "unit_get_data", Unit.get_data)

mod.open_armory_view = function ()
    if not mod.ingame_ui_context or not mod.ingame_ui_context.is_in_inn then
        return
    else
        local ingame_ui = mod.ingame_ui_context.ingame_ui

        ingame_ui:transition_with_fade("hero_view", {
            menu_state_name = "armory"
        })
    end
end

mod.buff_settings = {
    es = {
        reaper = {
            is_active = false,
            multiplier = 0.15
        },
        merrier = {
            is_active = false,
            multiplier = 0.03,
            num_stacks = 5
        }
    },
    dr = {},
    we = {},
    wh = {},
    bw = {}
}
mod.current_hero = nil

mod:command("armory", "Opens the Armory", mod.open_armory_view)

--local base_damage = mod.get_damage(Managers.player:local_player().player_unit, ItemMasterList[self.requested_weapon_name], damage_profile, mod.power_level, "hardest")
mod.get_damage = function (use_player, item, damage_profile, index, breed_name, hit_zone)
    local unit = use_player and Managers.player:local_player().player_unit or nil
    local damage_source = ItemMasterList[item].name
    local hit_zone_name = hit_zone or "torso"
    local target_index = index or 1
    local target_settings = (index and damage_profile.targets and damage_profile.targets[index]) or damage_profile.default_target
    local boost_curve = BoostCurves[target_settings.boost_curve_type]
    local boost_damage_multiplier = nil
    local is_critical_strike = false
    local backstab_multiplier = 1
    local breed = Breeds[breed_name] or Breeds.chaos_fanatic
    local armor_type = (breed.hitzone_armor_categories and breed.hitzone_armor_categories[hit_zone_name]) or breed.armor_category
    local primary_armor_type = (breed.hitzone_primary_armor_categories and breed.hitzone_primary_armor_categories[hit_zone_name] and breed.hitzone_primary_armor_categories[hit_zone_name].attack) or breed.primary_armor_category or armor_type
    local dropoff_scalar = 0
    local has_power_boost = false
    local difficulty_level = "hardest"

    local player = Managers.player:local_player()
    local profile_name, career_name = hero_and_career_name_from_index(player:profile_index(), player:career_index())
    mod.refresh_power_levels(profile_name, career_name)

    local damage = DamageUtils.calculate_damage_tooltip(unit, damage_source, mod.power_level, hit_zone_name, damage_profile, index, boost_curve, boost_damage_multiplier, is_critical_strike, backstab_multiplier, breed, dropoff_scalar, has_power_boost, difficulty_level, armor_type, primary_armor_type)

    return damage
end

mod:hook(ActionUtils, "scale_power_levels", function (orig_func, ...)
    local scaled_power_level = orig_func(...)

    local total_multipliers = 0
    if mod.current_hero then
        for buff_name, buff_settings in pairs(mod.buff_settings[mod.current_hero]) do
            if buff_settings.is_active then
                total_multipliers = total_multipliers + (buff_settings.num_stacks or 1) * buff_settings.multiplier
            end
        end
        scaled_power_level = scaled_power_level * (1 + total_multipliers)
    end

    return scaled_power_level
end)

mod:hook_disable(ActionUtils, "scale_power_levels")

mod:hook_safe(HeroViewStateOverview, "_handle_input", function (self, dt, t)
    local armory_button = self._widgets_by_name.armory_button
    UIWidgetUtils.animate_default_button(armory_button, dt)

    if self:_is_button_hover_enter(armory_button) then
        self:play_sound("play_gui_equipment_button_hover")
    end

    if self:_is_button_pressed(armory_button) then
        self:requested_screen_change_by_name("armory")
    end
end)

mod:hook(HeroViewStateOverview, "create_ui_elements", function (orig_func, self, params)
    mod:hook_enable(UISceneGraph, "init_scenegraph")

    local result = orig_func(self, params)

    local armory_button_widget_definition = UIWidgets.create_default_button("armory_button", { 380, 42 }, nil, nil, "Armory", 24, nil, "button_detail_04", 34)
    local armory_button_widget = UIWidget.init(armory_button_widget_definition)
    self._widgets[#self._widgets + 1] = armory_button_widget
    self._widgets_by_name["armory_button"] = armory_button_widget

    mod:hook_disable(UISceneGraph, "init_scenegraph")

    return result
end)

mod:hook(UISceneGraph, "init_scenegraph", function (orig_func, scenegraph)
    scenegraph.armory_button = {
        vertical_alignment = "bottom",
        horizontal_alignment = "left",
        parent = "window",
        size = {
            380,
            42
        },
        position = {
            150,
            -16,
            10
        }
    }

    return orig_func(scenegraph)
end)

mod:hook_disable(UISceneGraph, "init_scenegraph")