local mod = get_mod("armory")

local definitions = mod:dofile("scripts/mods/armory/definitions/hero_view_state_armory_definitions")
local widget_definitions = definitions.widgets
local viewport_widget_definition = definitions.viewport_widget
local category_settings = definitions.category_settings
local scenegraph_definition = definitions.scenegraph_definition
local animation_definitions = definitions.animation_definitions
local attack_list = definitions.attack_list
local weapon_preview_data = definitions.weapon_preview_data
local highlight_widget_list = definitions.highlight_widget_list

local total_attack_num

local hero_abbreviations = {
    "es",
    "dr",
    "we",
    "wh",
    "bw"
}

local hero_weapons = {
    es = {},
    dr = {},
    we = {},
    wh = {},
    bw = {}
}

HeroViewStateArmory = class(HeroViewStateArmory)
HeroViewStateArmory.NAME = "HeroViewStateArmory"

HeroViewStateArmory.on_enter = function (self, params)
    print("[HeroViewState] Enter Substate HeroViewStateBestiary")

    self.parent = params.parent
    local ingame_ui_context = params.ingame_ui_context
    self.ingame_ui_context = ingame_ui_context
    self.ui_renderer = ingame_ui_context.ui_renderer
    self.ui_top_renderer = ingame_ui_context.ui_top_renderer
    self.input_manager = ingame_ui_context.input_manager
    self.voting_manager = ingame_ui_context.voting_manager
    self.profile_synchronizer = ingame_ui_context.profile_synchronizer
    self.statistics_db = ingame_ui_context.statistics_db
    self.render_settings = {
        snap_pixel_positions = true
    }
    self.wwise_world = params.wwise_world
    self.ingame_ui = ingame_ui_context.ingame_ui

    self.world_previewer = params.world_previewer
    self.platform = PLATFORM
    local player_manager = Managers.player
    local local_player = player_manager:local_player()
    self._stats_id = local_player:stats_id()
    self.player_manager = player_manager
    self.peer_id = ingame_ui_context.peer_id
    self.local_player_id = ingame_ui_context.local_player_id
    self.player = local_player
    local profile_index = self.profile_synchronizer:profile_by_peer(self.peer_id, self.local_player_id)
    local profile_settings = SPProfiles[profile_index]
    local display_name = profile_settings.display_name
    local hero_attributes = Managers.backend:get_interface("hero_attributes")
    local career_index = hero_attributes:get(display_name, "career")
    self.hero_name = display_name
    self.career_index = career_index
    self.profile_index = profile_index
    self.is_server = self.parent.is_server
    self._animations = {}
    self._ui_animations = {}
    self.weapon_skin_data = {}

    self:create_ui_elements(params)

    self:play_sound("play_gui_lobby_button_00_heroic_deed")

    mod:hook_enable(ActionUtils, "scale_power_levels")

    local selected_hero_index = mod:get("selected_hero_index")
    if selected_hero_index then
        self:_select_hero_button_by_index(selected_hero_index)
    end

    --local selected_weapon_tab_index = mod:get("selected_weapon_tab_index")
    --if selected_weapon_tab_index then
    --    self:_select_weapon_tab_by_index(selected_weapon_tab_index)
    --end

    local selected_weapon_index = mod:get("selected_weapon_index")
    if selected_weapon_index then
        self.requested_weapon_name = mod:get("selected_weapon_name")
        self:_select_weapon_by_index(selected_weapon_index)
    end
end

HeroViewStateArmory.create_ui_elements = function (self, params)
    self.ui_scenegraph = UISceneGraph.init_scenegraph(scenegraph_definition)

    local widgets = {}
    local widgets_by_name = {}
    for name, widget_definition in pairs(widget_definitions) do
        if widget_definition then
            local widget = UIWidget.init(widget_definition)
            widgets[#widgets + 1] = widget
            widgets_by_name[name] = widget
        end
    end
    self._widgets = widgets
    self._widgets_by_name = widgets_by_name

    UIRenderer.clear_scenegraph_queue(self.ui_renderer)

    self.ui_animator = UIAnimator:new(self.ui_scenegraph, animation_definitions)

    self:_setup_weapon_tabs()
    self:_clear_item_info()

    self._inventory_package_name = "resource_packages/inventory"

    Managers.package:load(self._inventory_package_name, "armory")
end

-- Borrowed from `hero_window_loadout_inventory.lua:124`; HeroWindowLoadoutInventory._setup_tab_widget()
HeroViewStateArmory._setup_weapon_tabs = function (self)

    local widgets = self._widgets
    local widgets_by_name = self._widgets_by_name
    local item_tabs_segments = UIWidget.init(UIWidgets.create_simple_centered_texture_amount("menu_frame_09_divider_vertical", {
        5,
        35
    }, "item_tabs_segments", 1))
    local item_tabs_segments_top = UIWidget.init(UIWidgets.create_simple_centered_texture_amount("menu_frame_09_divider_top", {
        17,
        9
    }, "item_tabs_segments_top", 1))
    local item_tabs_segments_bottom = UIWidget.init(UIWidgets.create_simple_centered_texture_amount("menu_frame_09_divider_bottom", {
        17,
        9
    }, "item_tabs_segments_bottom", 1))

    widgets_by_name.item_tabs_segments = item_tabs_segments
    widgets_by_name.item_tabs_segments_top = item_tabs_segments_top
    widgets_by_name.item_tabs_segments_bottom = item_tabs_segments_bottom
    widgets[#widgets + 1] = item_tabs_segments
    widgets[#widgets + 1] = item_tabs_segments_top
    widgets[#widgets + 1] = item_tabs_segments_bottom

    local scenegraph_id = "item_tabs"
    local widget_definition = UIWidgets.create_default_icon_tabs(scenegraph_id, scenegraph_definition.item_tabs.size, 2)
    local widget = UIWidget.init(widget_definition)
    widgets_by_name[scenegraph_id] = widget
    widgets[#widgets + 1] = widget
    local widget_content = widget.content

    for i = 1, 2, 1 do
        local name_suffix = "_" .. tostring(i)
        local hotspot_name = "hotspot" .. name_suffix
        local icon_name = "icon" .. name_suffix
        local hotspot_content = widget_content[hotspot_name]
        local category = category_settings[i]
        local icon = category.icon
        hotspot_content[icon_name] = icon
        hotspot_content.category_index = i
    end

    self._selected_item_category_index = mod:get("selected_weapon_tab_index") or 1
    self:_select_weapon_tab_by_index(self._selected_item_category_index)

end

HeroViewStateArmory.update = function (self, dt, t)
    local input_service = self:input_service()

    self:_update_animations(dt)
    self:draw(dt, input_service)

    if self.world_previewer then
        self.world_previewer:update_weapon(dt, t, false)
    end

    if self:_has_active_level_vote() then
        self:close_menu(true)
    else
        self:_handle_input(dt, t)
    end
end

HeroViewStateArmory.post_update = function (self, dt)
    if not self._viewport_widget and self:_initial_packages_loaded() then
        self._viewport_widget = UIWidget.init(viewport_widget_definition)
    end

    if not self.initialized and self._viewport_widget then
        local world_previewer = MenuWorldPreviewer:new(self.ingame_ui_context, nil, "armory")

        world_previewer:on_enter(self._viewport_widget, "armory")

        self.world_previewer = world_previewer
        self.initialized = true
    end

    if self.world_previewer then
        ScriptWorld.activate_viewport(self._viewport_widget.element.pass_data[1].world, self._viewport_widget.element.pass_data[1].viewport)

        self:_update_weapon_sync()

        self.world_previewer:post_update_armory(dt)
    end


end

HeroViewStateArmory._initial_packages_loaded = function (self)
    local inventory_package_loaded = Managers.package:has_loaded(self._inventory_package_name, "armory")

    return inventory_package_loaded
end

HeroViewStateArmory._update_weapon_sync = function (self)
    if self.world_previewer then

        if self.weapon_name ~= self.requested_weapon_name then

            self.world_previewer:clear_units_armory()
            self.weapon_name = self.requested_weapon_name
            self:_fetch_weapon_skin_data()
            self:spawn_weapon()
            self:_cycle_illusions("next", mod:get("selected_illusion_index"))

        end

    end
end

HeroViewStateArmory.spawn_weapon = function (self, illusion_data)
    local world_previewer = self.world_previewer

    if not world_previewer then
        return
    end

    self.weapon_unit_spawned = false

    local function callback()
        self.weapon_unit_spawned = true
    end

    local weapon_data = ItemMasterList[self.weapon_name]
    if illusion_data then
        weapon_data = illusion_data
    end

    world_previewer:spawn_weapon_unit(weapon_data, callback)
end

HeroViewStateArmory._update_animations = function (self, dt)
    self.ui_animator:update(dt)

    for name, ui_animation in pairs(self._ui_animations) do
        UIAnimation.update(ui_animation, dt)

        if UIAnimation.completed(ui_animation) then
            self._ui_animations[name] = nil
        end
    end

    local widgets_by_name = self._widgets_by_name
    local exit_button = widgets_by_name.exit_button
    local item_tabs = widgets_by_name.item_tabs
    local reset_preview_button = widgets_by_name.reset_preview_button
    local prev_illusion_button = widgets_by_name.prev_illusion_button
    local next_illusion_button = widgets_by_name.next_illusion_button

    UIWidgetUtils.animate_default_icon_tabs(item_tabs, dt)
    UIWidgetUtils.animate_default_button(exit_button, dt)
    UIWidgetUtils.animate_default_button(reset_preview_button, dt)
    UIWidgetUtils.animate_default_button(prev_illusion_button, dt)
    UIWidgetUtils.animate_default_button(next_illusion_button, dt)

end

HeroViewStateArmory._handle_input = function (self, dt, t)
    local esc_pressed = self:input_service():get("toggle_menu")
    local widgets_by_name = self._widgets_by_name
    local exit_button = widgets_by_name.exit_button
    local reset_preview_button = widgets_by_name.reset_preview_button
    local prev_illusion_button = widgets_by_name.prev_illusion_button
    local next_illusion_button = widgets_by_name.next_illusion_button

    if self:_is_hero_button_hovered() then
        self:play_sound("play_gui_hero_select_hero_hover")
    end

    if (
            self:_is_button_hover_enter(exit_button) or
            self:_is_button_hover_enter(prev_illusion_button) or
            self:_is_button_hover_enter(next_illusion_button)
    ) then
        self:play_sound("play_gui_equipment_button_hover")
    end

    if self:_is_button_hover_enter(reset_preview_button) then
        self.reset_preview_button_hovered = true
        self:play_sound("play_gui_equipment_button_hover")
        reset_preview_button.content.title_text = "Reset Camera"
    end

    if self.reset_preview_button_hovered and not self:_is_button_hover(reset_preview_button) then
        reset_preview_button.content.title_text = self.previous_reset_preview_text
    end

    local tab_index_hovered = self:_is_weapon_tab_hovered()

    if tab_index_hovered then
        self:play_sound("play_gui_inventory_tab_hover")
    end

    local tab_index_pressed = self:_is_weapon_tab_pressed()

    if tab_index_pressed and tab_index_pressed ~= self._selected_item_category_index then
        self:_select_weapon_tab_by_index(tab_index_pressed)
        self:play_sound("play_gui_inventory_tab_click")
    end

    local hero_index = self:_is_hero_button_pressed()

    if hero_index then
        self:_select_hero_button_by_index(hero_index)
    end

    local is_selected, weapon_index = self:_is_weapon_button_pressed()

    if weapon_index and not is_selected then
        self:_select_weapon_by_index(weapon_index)
    end

    if self:_is_button_pressed(reset_preview_button) then
        self:play_sound("Play_hud_hover")
        self:_reset_camera()
    end

    if self:_is_button_pressed(prev_illusion_button) then
        self:play_sound("Play_hud_hover")
        self:_cycle_illusions("prev")
    end

    if self:_is_button_pressed(next_illusion_button) then
        self:play_sound("Play_hud_hover")
        self:_cycle_illusions("next")
    end

    if esc_pressed or self:_is_button_pressed(exit_button) then
        self:play_sound("Play_hud_hover")
        self:close_menu()

        return
    end

    self:_handle_hero_button_hover("icon")
    self:_handle_tray_hover()
    self:_handle_detail_info()
end

HeroViewStateArmory._reset_camera = function (self)
    if self.world_previewer then
        self.world_previewer:reset_camera()
    end
end

HeroViewStateArmory._cycle_illusions = function (self, direction, initial_index)
    if not self.world_previewer then
        return
    end

    local delta = (initial_index and initial_index - 1) or 1
    if direction == "prev" then
        delta = -1
    end

    local weapon_name = self.weapon_name
    local weapon_skin_data = self.weapon_skin_data[weapon_name] or {}

    if #weapon_skin_data == 0 then
        return
    end

    local illusion_index = self.current_illusion_index or 1
    illusion_index = illusion_index + delta

    if illusion_index > #weapon_skin_data then
        illusion_index = 1
    elseif illusion_index < 1 then
        illusion_index = #weapon_skin_data
    end

    local illusion_data = weapon_skin_data[illusion_index]
    self.current_illusion_index = illusion_index
    mod:set("selected_illusion_index", illusion_index)

    local widgets_by_name = self._widgets_by_name
    local reset_preview_button = widgets_by_name.reset_preview_button

    reset_preview_button.content.title_text = Localize(illusion_data.display_name)
    self.previous_reset_preview_text = reset_preview_button.content.title_text

    self:spawn_weapon(illusion_data)

end

HeroViewStateArmory._select_weapon_tab_by_index = function (self, index, initial)
    local widget = self._widgets_by_name.item_tabs
    local content = widget.content
    local amount = content.amount

    for i = 1, amount, 1 do
        local name_suffix = "_" .. tostring(i)
        local hotspot_name = "hotspot" .. name_suffix
        local hotspot_content = content[hotspot_name]
        local category_index = hotspot_content.category_index
        hotspot_content.is_selected = index == category_index
        if initial or hotspot_content.is_selected then
            mod:set("selected_weapon_tab_index", index)
            self._selected_item_category_index = category_index
            self:_populate_item_grid(self._selected_hero_index, self._selected_item_category_index)
        end
    end
end

HeroViewStateArmory._is_button_hover_enter = function (self, widget)
    local content = widget.content
    local hotspot = content.button_hotspot

    return hotspot.on_hover_enter
end

HeroViewStateArmory._is_button_hover = function (self, widget)
    local content = widget.content
    local hotspot = content.button_hotspot

    return hotspot.is_hover
end

HeroViewStateArmory._is_button_hover_exit = function (self, widget)
    local content = widget.content
    local hotspot = content.button_hotspot

    return hotspot.on_hover_exit

end

HeroViewStateArmory._is_weapon_tab_hovered = function (self)
    local widget = self._widgets_by_name.item_tabs
    local content = widget.content
    local amount = content.amount

    for i = 1, amount, 1 do
        local name_suffix = "_" .. tostring(i)
        local hotspot_name = "hotspot" .. name_suffix
        local hotspot_content = content[hotspot_name]

        if hotspot_content.on_hover_enter then
            return i
        end
    end

end

HeroViewStateArmory._is_weapon_tab_pressed = function (self)
    local widget = self._widgets_by_name.item_tabs
    local widget_content = widget.content
    local amount = widget_content.amount

    for i = 1, amount, 1 do
        local name_sufix = "_" .. tostring(i)
        local hotspot_name = "hotspot" .. name_sufix
        local hotspot_content = widget_content[hotspot_name]

        if hotspot_content.on_release and not hotspot_content.is_selected and not hotspot_content.is_disabled then
            return hotspot_content.category_index
        end
    end
end

HeroViewStateArmory._select_weapon_by_index = function (self, slot_index)
    self:play_sound("play_gui_equipment_equip_hero")

    local widget = self._widgets_by_name.item_grid
    local content = widget.content
    local rows = content.rows
    local cols = content.columns

    local row_index = math.floor((slot_index - 1) / cols) + 1
    local col_index = (slot_index - 1) % cols + 1

    for i = 1, rows, 1 do
        for j = 1, cols, 1 do
            local name_suffix = "_" .. tostring(i) .. "_" .. tostring(j)
            local hotspot_name = "hotspot" .. name_suffix
            local hotspot_content = content[hotspot_name]

            local selected = (i == row_index and j == col_index)
            hotspot_content.is_selected = selected

            if selected then
                local item = content["item" .. name_suffix]

                if item then
                    mod:set("selected_weapon_index", slot_index)
                    mod:set("selected_weapon_name", item.name)

                    self.requested_weapon_name = item.name

                    self:_display_item_info(item)

                    self:_highlight_off(self.ignore_dehover_group, true)
                    self:_clear_detail_info()
                end

            end
        end
    end
end

HeroViewStateArmory._display_item_info = function (self, item)
    self:_clear_item_info()

    self._widgets_by_name.coming_soon.content.visible = true

    self._widgets_by_name.prev_illusion_button.content.visible = true
    self._widgets_by_name.next_illusion_button.content.visible = true
    self._widgets_by_name.reset_preview_button.content.visible = true
    self._widgets_by_name.reset_preview_button.content.title_text = Localize(item.display_name)
    self.previous_reset_preview_text = self._widgets_by_name.reset_preview_button.content.title_text

    local template = Weapons[item.template]
    local attacks = attack_list[self._selected_hero_abbr][item.template]

    if attacks then

        local item_category = self._selected_item_category_index

        -- Melee weapon information differs vastly from ranged weapon information; let's separate those concerns
        if item_category == 1 then      -- melee
            local light_attacks = {}
            local heavy_attacks = {}
            local push_attack

            for attack_name, attack_data in pairs(template.actions.action_one) do
                for i = 1, #attacks.light, 1 do
                    if attacks.light[i] == attack_name then
                        light_attacks[attack_name] = attack_data
                    end
                end

                if attacks.push == attack_name then
                    push_attack = attack_data
                end

                for i = 1, #attacks.heavy, 1 do
                    if attacks.heavy[i] == attack_name then
                        heavy_attacks[attack_name] = attack_data
                    end
                end
            end

            local push_action = template.actions.action_one.push

            local stamina = template.max_fatigue_points and template.max_fatigue_points / 2 or nil
            local dodge_count = template.dodge_count or 1
            local dodge_bonus = (template.buffs.change_dodge_distance.external_optional_multiplier * 100 - 100) or 0

            local block_angle = template.block_angle
            local block_fatigue_multiplier = template.block_fatigue_point_multiplier or 1
            local outer_block_fatigue_multiplier =  template.outer_block_fatigue_point_multiplier or 2
            local push_radius = (push_action and push_action.push_radius) or 0
            local push_angle = (push_action and push_action.push_angle) or 0
            local outer_push_angle = (push_action and push_action.outer_push_angle) or 0

            local melee_base_data = {
                name = item.item_type,
                stamina = stamina,
                dodge_count = dodge_count,
                dodge_bonus = dodge_bonus,
                block_angle = block_angle,
                block_fatigue_multiplier = block_fatigue_multiplier,
                outer_block_fatigue_multiplier = outer_block_fatigue_multiplier,
                push_radius = math.max(push_radius, 2.5),
                push_angle = push_angle,
                outer_push_angle = outer_push_angle
            }

            self:_display_melee_base_info(melee_base_data)

            local melee_action_data = {
                light_attacks = light_attacks,
                heavy_attacks = heavy_attacks,
                push_attack_action = push_attack
            }

            self:_display_melee_action_info(attacks, melee_action_data)

        elseif item_category == 2 then  -- ranged
            local ranged_attacks = {}
            local alternate_attacks = {}

            for attack_name, attack_data in pairs(template.actions.action_one) do
                for i = 1, #attacks.ranged, 1 do
                    if attacks.ranged[i][1] == attack_name then
                        ranged_attacks[attack_name] = attack_data
                    end
                end

                for i = 1, #attacks.alternate, 1 do
                    if attacks.alternate[i][1] == attack_name then
                        alternate_attacks[attack_name] = attack_data
                    end
                end
            end

            for attack_name, attack_data in pairs(template.actions.action_two) do
                for i = 1, #attacks.alternate, 1 do
                    if attacks.alternate[i][1] == attack_name then
                        alternate_attacks[attack_name] = attack_data
                    end
                end
            end

            local dodge_count = template.dodge_count or 1
            local dodge_bonus = (template.buffs.change_dodge_distance.external_optional_multiplier * 100 - 100) or 0
            --local max_range = (template.attack_meta_data and template.attack_meta_data.max_range)

            local timed_data = template.actions.action_one.default.timed_data
            local projectile_lifetime
            if timed_data then
                projectile_lifetime = timed_data.life_time
            end

            local reload_time
            local max_ammo
            local ammo_per_clip
            local max_overcharge
            if template.ammo_data then
                if template.ammo_data.ammo_immediately_available then
                    reload_time = 0
                else
                    reload_time = template.ammo_data.reload_time
                end
                max_ammo = template.ammo_data.max_ammo
                ammo_per_clip = template.ammo_data.ammo_per_clip or 1
            elseif template.overcharge_data then
                max_overcharge = template.overcharge_data.max_value or 40
            end


            local ranged_base_data = {
                name = item.item_type,
                reload_time = reload_time,
                max_ammo = max_ammo,
                ammo_per_clip = ammo_per_clip,
                max_overcharge = max_overcharge,
                dodge_count = dodge_count,
                dodge_bonus = dodge_bonus,
                projectile_lifetime = projectile_lifetime
            }

            self:_display_ranged_base_info(ranged_base_data)

            local ranged_action_data = {
                ranged_attacks = ranged_attacks,
                alternate_attacks = alternate_attacks
            }

            self:_display_ranged_action_info(attacks, ranged_action_data)
        end
    end
end

HeroViewStateArmory._display_ranged_base_info = function (self, data)
    local widgets = self._widgets_by_name

    for widget_name, widget in pairs(widgets) do
        if string.match(widget_name, "base_info_ranged_") ~= nil or string.match(widget_name, "_dodge_") or string.match(widget_name, "header") then
            if widget.content then
                widget.content.visible = true
            end

            if widget_name == "header_cleave_damage_abbr" then
                widget.content.text = "D"
            elseif widget_name == "header_cleave_stagger_abbr" then
                widget.content.text = "S"
            end
        end
    end

    widgets.header_title_text.content.text = Localize(data.name)

    widgets.base_info_dodge_bonus_value.content.text = string.format("%.0f", data.dodge_bonus) .. "%"
    widgets.base_info_dodge_count_value.content.text = tostring(data.dodge_count)

    if data.reload_time then
        widgets.base_info_ranged_reload_time_value.content.text = string.format("%.2f", data.reload_time) .. "s"

        for widget_name, widget in pairs(widgets) do
            if string.match(widget_name, "_overcharge") ~= nil then
                widget.content.visible = false
            end
        end
    else
        for widget_name, widget in pairs(widgets) do
            if string.match(widget_name, "reload_time") ~= nil or string.match(widget_name, "_ammo") ~= nil then
                widget.content.visible = false
            end
        end

        if data.max_overcharge then
            widgets.base_info_ranged_overcharge_value.content.text = tostring(data.max_overcharge)
        end
    end

    widgets.base_info_ranged_ammo_value_left.content.text = tostring(data.ammo_per_clip)
    widgets.base_info_ranged_ammo_value_right.content.text = tostring(data.max_ammo)

    --if data.projectile_lifetime then
    --    widgets.base_info_ranged_max_range_value.content.text = tostring(data.projectile_lifetime) .. "s"
    --    widgets.base_info_ranged_max_range_tooltip.content.tooltip_text = "Projectile Lifetime"
    --    widgets.base_info_ranged_max_range_icon.content.texture_id = "solar_time"
    --else
    --    widgets.base_info_ranged_max_range_tooltip.content.tooltip_text = "Max Range"
    --    widgets.base_info_ranged_max_range_icon.content.texture_id = "spyglass"
    --    widgets.base_info_ranged_max_range_value.content.text = (data.max_range and tostring(data.max_range) .. "m") or "Until Impact"
    --end
end

HeroViewStateArmory._display_ranged_action_info = function (self, attacks, data)
    local widgets = self._widgets_by_name

    local ranged_attacks = data.ranged_attacks
    local alternate_attacks = data.alternate_attacks

    total_attack_num = #attacks.ranged + #attacks.alternate

    for i = 1, #attacks.ranged, 1 do
        local widget_name = "action_info_ranged_attack" .. tostring(i)
        widgets[widget_name].content.visible = true

        for k, widget in pairs(widgets) do
            if string.match(k, widget_name) then
                widget.content.visible = true
            end
        end

        local text_widget = widget_name .. "_text"
        widgets[text_widget].content.text = attacks.ranged[i][2]

        local attack = ranged_attacks[attacks.ranged[i][1]]

        local chain = self:_get_followup_chain_action(attack)

        local attack_speed
        if chain then
            attack_speed = string.format("%.2f", chain.start_time / (attack.anim_time_scale or 1))
            widgets[widget_name.."_attack_speed"].content.text = attack_speed .. "s"
        else
            widgets[widget_name.."_attack_speed"].content.text = (attack.total_time ~= math.huge and string.format("%.2f", attack.total_time) .. "s") or "Varies"
        end

        local damage_profile = (attack.impact_data and DamageProfileTemplates[attack.impact_data.damage_profile]) or DamageProfileTemplates[attack.damage_profile] or DamageProfileTemplates.default
        --local base_damage = self:_calc_base_damage(damage_profile, 1)
        local base_damage = mod.get_damage(true, self.requested_weapon_name, damage_profile, 1)
        local armor_damage = mod.get_damage(true, self.requested_weapon_name, damage_profile, 1, "skaven_storm_vermin")

        if damage_profile.no_stagger_damage_reduction then
            base_damage = DamageUtils.networkify_damage(base_damage * 1.2)
            armor_damage = DamageUtils.networkify_damage(armor_damage * 1.2)
        end

        local max_targets_damage, max_targets_stagger = ActionUtils.get_max_targets(damage_profile, mod.scaled_cleave_power_level)
        widgets[widget_name.."_damage_limit"].content.text = string.format("%.2f", max_targets_damage)
        widgets[widget_name.."_stagger_limit"].content.text = string.format("%.2f", max_targets_stagger)

        --local armor_damage, heavy_armor_damage = self:_calc_base_damage(damage_profile, 2)
        widgets[widget_name.."_armor_damage"].content.text = armor_damage > 0 and string.format("%.2f", armor_damage) or ""
        widgets[widget_name.."_base_damage"].content.text = base_damage > 0 and string.format("%.2f", base_damage) or ""
        --widgets[widget_name.."_armor_damage_text"].content.text = string.format("%.2f", armor_damage)

        local special_property = self:_get_special_property(attack, damage_profile)
        widgets[widget_name.."_special"].content.text = special_property
    end

    for i = 1, #attacks.alternate, 1 do
        local widget_name = "action_info_ranged_attack" .. tostring(#attacks.ranged + i)
        widgets[widget_name].content.visible = true

        for k, widget in pairs(widgets) do
            if string.match(k, widget_name) then
                widget.content.visible = true
            end
        end

        local text_widget = widget_name .. "_text"
        widgets[text_widget].content.text = attacks.alternate[i][2]

        local attack = alternate_attacks[attacks.alternate[i][1]]

        local chain = self:_get_followup_chain_action(attack)

        local attack_speed
        if chain then
            attack_speed = string.format("%.2f", chain.start_time / (attack.anim_time_scale or 1))
            widgets[widget_name.."_attack_speed"].content.text = attack_speed .. "s"
        else
            widgets[widget_name.."_attack_speed"].content.text = (attack.total_time ~= math.huge and string.format("%.2f", attack.total_time) .. "s") or "Varies"
        end

        local damage_profile = (attack.impact_data and DamageProfileTemplates[attack.impact_data.damage_profile]) or DamageProfileTemplates[attack.damage_profile] or DamageProfileTemplates.default
        local base_damage = mod.get_damage(true, self.requested_weapon_name, damage_profile, 1)
        local armor_damage = mod.get_damage(true, self.requested_weapon_name, damage_profile, 1, "skaven_storm_vermin")

        if damage_profile.no_stagger_damage_reduction then
            base_damage = DamageUtils.networkify_damage(base_damage * 1.2)
            armor_damage = DamageUtils.networkify_damage(armor_damage * 1.2)
        end

        local max_targets_damage, max_targets_stagger = ActionUtils.get_max_targets(damage_profile, mod.scaled_cleave_power_level)
        widgets[widget_name.."_damage_limit"].content.text = string.format("%.2f", max_targets_damage)
        widgets[widget_name.."_stagger_limit"].content.text = string.format("%.2f", max_targets_stagger)

        --local armor_damage, heavy_armor_damage = self:_calc_base_damage(damage_profile, 2)
        widgets[widget_name.."_armor_damage"].content.text = armor_damage > 0 and string.format("%.0f", armor_damage) or ""
        widgets[widget_name.."_base_damage"].content.text = base_damage > 0 and string.format("%.2f", base_damage) or ""

        local special_property = self:_get_special_property(attack, damage_profile)
        widgets[widget_name.."_special"].content.text = special_property

    end
end

HeroViewStateArmory._display_melee_base_info = function (self, data)
    local widgets = self._widgets_by_name

    widgets.header_title_text.content.text = Localize(data.name)

    widgets.base_info_melee_stamina_value.content.text = data.stamina or ""

    widgets.base_info_melee_push_radius_value.content.text = data.push_radius or ""

    widgets.base_info_melee_block_efficiency_value_left.content.text = ("x" .. string.format("%.1f", data.block_fatigue_multiplier)) or ""
    widgets.base_info_melee_block_efficiency_value_right.content.text = ("x" .. string.format("%.1f", data.outer_block_fatigue_multiplier)) or ""

    local degree_symbol = "\u{00B0}"
    widgets.base_info_melee_push_angles_value_left.content.text = (tostring(data.push_angle) .. degree_symbol) or ""
    widgets.base_info_melee_push_angles_value_right.content.text = (tostring(data.outer_push_angle) .. degree_symbol) or ""

    widgets.base_info_melee_block_angle_value.content.text = (tostring(data.block_angle) .. degree_symbol) or ""

    widgets.base_info_dodge_bonus_value.content.text = string.format( "%.0f", data.dodge_bonus ) .. "%"

    widgets.base_info_dodge_count_value.content.text = tostring(data.dodge_count) or ""


    for widget_name, widget in pairs(widgets) do
        if string.match(widget_name, "_melee_") ~= nil or string.match(widget_name, "_dodge_") or string.match(widget_name, "header") then
            if widget.content then
                widget.content.visible = true
            end
        end

        if widget_name == "header_cleave_damage_abbr" then
            widget.content.text = "D"
        elseif widget_name == "header_cleave_stagger_abbr" then
            widget.content.text = "S"
        end

    end
end

HeroViewStateArmory._display_melee_action_info = function (self, attacks, data)
    local widgets = self._widgets_by_name

    local light_attacks = data.light_attacks
    local heavy_attacks = data.heavy_attacks
    local push_attack_action = data.push_attack_action

    total_attack_num = 5 + #attacks.heavy

    for i = 1, #attacks.light, 1 do
        local widget_name = "action_info_light_attack" .. tostring(i)
        widgets[widget_name].content.visible = true

        for k, widget in pairs(widgets) do
            if string.match(k, widget_name) then
                widget.content.visible = true
            end
        end

        local text_widget = widget_name .. "_text"
        widgets[text_widget].content.text = "Light Attack " .. tostring(i)

        local attack = light_attacks[attacks.light[i]]

        local chain = self:_get_followup_chain_action(attack)
        local attack_speed = string.format("%.2f", chain.start_time / (attack.anim_time_scale or 1))
        widgets[widget_name.."_attack_speed"].content.text = attack_speed .. "s"

        local damage_profile = DamageProfileTemplates[attack.damage_profile] or DamageProfileTemplates[attack.damage_profile_right]
        --local base_damage = self:_calc_base_damage(damage_profile, 1)
        local base_damage = mod.get_damage(true, self.requested_weapon_name, damage_profile, 1)

        local max_targets_damage, max_targets_stagger = ActionUtils.get_max_targets(damage_profile, mod.scaled_cleave_power_level)
        widgets[widget_name.."_damage_limit"].content.text = string.format("%.2f", max_targets_damage)
        widgets[widget_name.."_stagger_limit"].content.text = string.format("%.2f", max_targets_stagger)

        --local armor_damage = self:_calc_base_damage(damage_profile, 2)
        local armor_damage = mod.get_damage(true, self.requested_weapon_name, damage_profile, 1, "skaven_storm_vermin")
        widgets[widget_name.."_armor_damage"].content.text = armor_damage > 0 and string.format("%.2f", armor_damage) or ""
        widgets[widget_name.."_base_damage"].content.text = base_damage > 0 and string.format("%.2f", base_damage) or ""

        local special_property = self:_get_special_property(attack, damage_profile)
        widgets[widget_name.."_special"].content.text = special_property



        local unarmored_damage = {}
        local armored_damage = {}
        local monster_damage = {}
        local berserker_damage = {}
        local heavy_armor_damage = {}

        --local max_targets = math.ceil(max_targets_damage / Breeds["skaven_slave"].hit_mass_counts[5])
        --for i = 1, max_targets, 1 do
        --    unarmored_damage[i] = string.format("%.2f", mod.get_damage(false, self.requested_weapon_name, damage_profile, i, "skaven_slave"))
        --    armored_damage[i] = string.format("%.2f", mod.get_damage(false, self.requested_weapon_name, damage_profile, i, "skaven_storm_vermin"))
        --    monster_damage[i] = string.format("%.2f", mod.get_damage(false, self.requested_weapon_name, damage_profile, i, "skaven_rat_ogre"))
        --    berserker_damage[i] = string.format("%.2f", mod.get_damage(false, self.requested_weapon_name, damage_profile, i, "skaven_plague_monk"))
        --    heavy_armor_damage[i] = string.format("%.2f", mod.get_damage(false, self.requested_weapon_name, damage_profile, i, "chaos_warrior"))
        --
        --end

        --widgets[widget_name.."_hotspot"].content.data = {
        --    desc = "Unarmored: " .. table.concat(unarmored_damage, ', ')
        --            .. "\nArmored: " .. table.concat(armored_damage, ', ')
        --            .. "\nMonster: " .. table.concat(monster_damage, ', ')
        --            .. "\nBerserker: " .. table.concat(berserker_damage, ', ')
        --            .. "\nHeavily Armored: " .. table.concat(heavy_armor_damage, ', ')
        --}


    end

    local has_charged_attacks
    local charge_attack_index
    for i = 1, #attacks.heavy, 1 do
        local widget_name = "action_info_heavy_attack" .. tostring(i)
        widgets[widget_name].content.visible = true

        for k, widget in pairs(widgets) do
            if string.match(k, widget_name) then
                widget.content.visible = true
            end
        end

        local attack = heavy_attacks[attacks.heavy[i]]

        -- If weapon has charged attacks, we'll have to make some adjustments to the displayed attack index
        local charged = string.match(attack.damage_profile or attack.damage_profile_right, "charged") ~= nil
        if charged then
            widgets[widget_name.."_text"].content.text = "Heavy Attack " .. tostring((charge_attack_index) or i - 1) .. " Charged"
            has_charged_attacks = true
            charge_attack_index = i
        else
            charge_attack_index = (has_charged_attacks and charge_attack_index) or i
            widgets[widget_name.."_text"].content.text = "Heavy Attack " .. tostring(charge_attack_index)
        end

        local chain = self:_get_followup_chain_action(attack)
        local attack_speed = string.format("%.2f", chain.start_time / (attack.anim_time_scale or 1))
        widgets[widget_name.."_attack_speed"].content.text = attack_speed .. "s"

        local damage_profile = DamageProfileTemplates[attack.damage_profile] or DamageProfileTemplates[attack.damage_profile_right]
        --local base_damage = self:_calc_base_damage(damage_profile, 1)
        local base_damage = mod.get_damage(true, self.requested_weapon_name, damage_profile, 1)

        local max_targets_damage, max_targets_stagger = ActionUtils.get_max_targets(damage_profile, mod.scaled_cleave_power_level)
        widgets[widget_name.."_damage_limit"].content.text = string.format("%.2f", max_targets_damage)
        widgets[widget_name.."_stagger_limit"].content.text = string.format("%.2f", max_targets_stagger)

        --local armor_damage = self:_calc_base_damage(damage_profile, 2)
        local armor_damage = mod.get_damage(true, self.requested_weapon_name, damage_profile, 1, "skaven_storm_vermin")
        widgets[widget_name.."_armor_damage"].content.text = armor_damage > 0 and string.format("%.2f", armor_damage) or ""
        widgets[widget_name.."_base_damage"].content.text = base_damage > 0 and string.format("%.2f", base_damage) or ""

        local special_property = self:_get_special_property(attack, damage_profile)
        widgets[widget_name.."_special"].content.text = special_property

        --widgets[widget_name.."_hotspot"].content.data = {
        --    desc = "Unarmored: " .. tostring(mod.get_damage(false, self.requested_weapon_name, damage_profile))
        --            .. "\nArmored: " .. tostring(mod.get_damage(false, self.requested_weapon_name, damage_profile, nil, "skaven_storm_vermin"))
        --            .. "\nMonster: " .. tostring(mod.get_damage(false, self.requested_weapon_name, damage_profile, nil, "skaven_rat_ogre"))
        --            .. "\nBerserker: " .. tostring(mod.get_damage(false, self.requested_weapon_name, damage_profile, nil, "skaven_plague_monk"))
        --            .. "\nHeavily Armored: " .. tostring(mod.get_damage(false, self.requested_weapon_name, damage_profile, nil, "chaos_warrior"))
        --}

    end

    local widget_name = "action_info_push_attack"

    widgets[widget_name].content.visible = true
    for k, widget in pairs(widgets) do
        if string.match(k, widget_name) then
            widget.content.visible = true
        end
    end

    widgets.action_info_push_attack_text.content.text = "Push Attack"
    local attack = push_attack_action

    if attack then
        local chain = self:_get_followup_chain_action(attack)
        local attack_speed = string.format("%.2f", chain.start_time / (attack.anim_time_scale or 1))
        widgets.action_info_push_attack_attack_speed.content.text = attack_speed .. "s"

        local damage_profile = DamageProfileTemplates[attack.damage_profile] or DamageProfileTemplates[attack.damage_profile_right]
        --local base_damage = self:_calc_base_damage(damage_profile, 1)
        local base_damage = mod.get_damage(true, self.requested_weapon_name, damage_profile, 1)

        local max_targets_damage, max_targets_stagger = ActionUtils.get_max_targets(damage_profile, mod.scaled_cleave_power_level)
        widgets[widget_name.."_damage_limit"].content.text = string.format("%.2f", max_targets_damage)
        widgets[widget_name.."_stagger_limit"].content.text = string.format("%.2f", max_targets_stagger)

        --local armor_damage = self:_calc_base_damage(damage_profile, 2)
        local armor_damage = mod.get_damage(true, self.requested_weapon_name, damage_profile, 1, "skaven_storm_vermin")
        widgets[widget_name.."_armor_damage"].content.text = armor_damage > 0 and string.format("%.2f", armor_damage) or ""
        widgets[widget_name.."_base_damage"].content.text = base_damage > 0 and string.format("%.2f", base_damage) or ""

        local special_property = self:_get_special_property(attack, damage_profile)
        widgets.action_info_push_attack_special.content.text = special_property

        --widgets[widget_name.."_hotspot"].content.data = {
        --    desc = "Unarmored: " .. tostring(mod.get_damage(false, self.requested_weapon_name, damage_profile))
        --            .. "\nArmored: " .. tostring(mod.get_damage(false, self.requested_weapon_name, damage_profile, nil, "skaven_storm_vermin"))
        --            .. "\nMonster: " .. tostring(mod.get_damage(false, self.requested_weapon_name, damage_profile, nil, "skaven_rat_ogre"))
        --            .. "\nBerserker: " .. tostring(mod.get_damage(false, self.requested_weapon_name, damage_profile, nil, "skaven_plague_monk"))
        --            .. "\nHeavily Armored: " .. tostring(mod.get_damage(false, self.requested_weapon_name, damage_profile, nil, "chaos_warrior"))
        --}
    end
end

HeroViewStateArmory._get_followup_chain_action = function (self, attack)
    if not attack then
        return
    end

    local chains = attack.allowed_chain_actions

    for index, chain in ipairs(chains) do
        if chain.action == "action_one" and chain.start_time > 0 then
            return chain
        end
    end

end

HeroViewStateArmory._calc_base_damage = function (self, damage_profile, armor_category, target_index)
    target_index = target_index or 1
    local target_settings = damage_profile.targets and damage_profile.targets[target_index] or damage_profile.default_target
    local dropoff_settings = target_settings.range_dropoff_settings or damage_profile.range_dropoff_settings
    local dropoff_scalar = 0

    if dropoff_settings then
        local dropoff_start = dropoff_settings.dropoff_start
        local dropoff_end = dropoff_settings.dropoff_end
        local dropoff_range = dropoff_end - dropoff_start
        local dropoff_distance = math.clamp(-dropoff_start, 0, dropoff_range)
        dropoff_scalar = dropoff_distance / dropoff_range
    end

    local attack_power = ActionUtils.get_power_level("attack", mod.power_level, damage_profile, target_settings, nil, dropoff_scalar, nil, "hardest")
    local attack_armor_power_modifier = ActionUtils.get_armor_power_modifier("attack", damage_profile, target_settings, armor_category, armor_category, nil, dropoff_scalar)
    local percentage = ActionUtils.get_power_level_percentage(attack_power * attack_armor_power_modifier)
    local base_damage = DamageUtils.networkify_damage(100 * percentage)

    return base_damage
end

HeroViewStateArmory._get_special_property = function (self, attack, damage_profile)
    local target_settings = damage_profile.targets[1] or damage_profile.targets[2]
    local default_target_settings = damage_profile.default_target
    local dot_template_name = target_settings and target_settings.dot_template_name or default_target_settings.dot_template_name or ""

    local prop_text_array = {}

    if attack.additional_critical_strike_chance and attack.additional_critical_strike_chance > 0 then
        prop_text_array[#prop_text_array + 1] = "+" .. tostring(attack.additional_critical_strike_chance * 100) .. "% Crit"
    end

    if dot_template_name then
        if string.match(dot_template_name, "bleed") then
            prop_text_array[#prop_text_array + 1] = "Bleeds"
        end
        if string.match(dot_template_name, "burning") or string.match(dot_template_name, "deus_01_dot") then
            prop_text_array[#prop_text_array + 1] = "Burns"
        end
        if string.match(dot_template_name, "poison") then
            prop_text_array[#prop_text_array + 1] = "Poisons"
        end
    end

    if attack.impact_data and attack.impact_data.aoe then
        prop_text_array[#prop_text_array + 1] = "Area Damage"
    end

    if attack.hit_mass_count then

        if attack.hit_mass_count["skaven_storm_vermin_with_shield"] then
            prop_text_array[#prop_text_array + 1] = "Tank"
        elseif attack.hit_mass_count["chaos_warrior"] then
            prop_text_array[#prop_text_array + 1] = "Heavy Linesman"
        else
            prop_text_array[#prop_text_array + 1] = "Linesman"
        end
    end

    return table.concat(prop_text_array, ', ')
end

HeroViewStateArmory._calc_headshot_modifier = function (self, damage_profile)
    if not damage_profile then
        return
    end

    return (damage_profile.targets[1] or damage_profile.targets[2] or damage_profile.default_target).boost_curve_coefficient_headshot
end

HeroViewStateArmory._clear_item_info = function (self)
    self._widgets_by_name.coming_soon.content.visible = false
    for widget_name, widget in pairs(self._widgets_by_name) do
        if string.find(widget_name, "base_info_") == 1 and widget.content then
            widget.content.visible = false
            widget.content.text = ""
        elseif string.find(widget_name, "action_info_") == 1 and widget.content then
            widget.content.visible = false
            widget.content.text = ""
        elseif string.find(widget_name, "header_") == 1 and widget.content then
            widget.content.visible = false
            widget.content.text = ""
        elseif string.find(widget_name, "reset_preview") == 1 and widget.content then
            widget.content.visible = false
        elseif string.find(widget_name, "_illusion_button") and widget.content then
            widget.content.visible = false
        end
    end
end

local categories = {
    "melee",
    "ranged"
}
HeroViewStateArmory._populate_item_grid = function (self, hero_index, category_index)
    if not self._selected_hero_index then
        return
    end

    self:_clear_item_grid()

    category_index = category_index or self._selected_item_category_index

    local weapons = self:_fetch_weapons(hero_index)

    local i = 1
    for _, item in pairs(weapons) do
        if categories[category_index] == item.slot_type then
            self:_add_item_to_slot_index(i, item)
            i = i + 1
        end
    end

end

-- Borrowed from ItemGridUI.clear_item_grid
HeroViewStateArmory._clear_item_grid = function (self)
    local widget = self._widgets_by_name.item_grid
    local content = widget.content
    local rows = content.rows
    local columns = content.columns

    for i = 1, rows, 1 do
        for k = 1, columns, 1 do
            local name_sufix = "_" .. tostring(i) .. "_" .. tostring(k)
            local item_icon_name = "item_icon" .. name_sufix
            local hotspot_name = "hotspot" .. name_sufix
            local item_content = content[hotspot_name]
            content["item" .. name_sufix] = nil
            item_content[item_icon_name] = nil
            item_content.is_selected = false
        end
    end
end

HeroViewStateArmory._add_item_to_slot_index = function (self, slot_index, item)
    local widget = self._widgets_by_name.item_grid
    local content = widget.content
    local cols = content.columns
    local row_index = math.floor((slot_index - 1) / cols) + 1
    local col_index = (slot_index - 1) % cols + 1
    local name_suffix = "_" .. tostring(row_index) .. "_" .. tostring(col_index)
    local item_icon_name = "item_icon" .. name_suffix
    local hotspot_name = "hotspot" .. name_suffix
    local item_content = content[hotspot_name]
    content["item" .. name_suffix] = item

    if item then
        item.data = table.clone(item)
        local inventory_icon, display_name = UIUtils.get_ui_information_from_item(item)

        item_content[item_icon_name] = inventory_icon
        item_content.fake_item = true
    else
        item_content.disable_button = true
        item_content[item_icon_name] = nil
    end
end

local ignored_item_types = {
    "hat",
    "skin",
    "hood",
    "tutorial",
    "magic"
}
HeroViewStateArmory._fetch_weapons = function (self, index)
    local hero = hero_abbreviations[index]

    -- No sense fetching more than once
    for weapon_name, _ in pairs(hero_weapons[hero]) do
        if weapon_name ~= nil then
            return hero_weapons[hero]
        end
    end

    for item_name, item in pairs(ItemMasterList) do
        if string.find(item_name, hero .. "_") == 1 then

            local is_ignored = ignored_item_types[item.item_type]
            if not is_ignored then
                for _, type in ipairs(ignored_item_types) do
                    if string.match(item_name, type) ~= nil or string.match(item_name, "_%d%d%d%d") ~= nil or string.match(item_name, "_preview") ~= nil then
                        is_ignored = true

                        break
                    end
                end
            end

            if not is_ignored then
                hero_weapons[hero][item_name] = item
            end
        end
    end

    -- Looks like someone was lazy
    if hero == "es" then
        hero_weapons[hero]["es_1h_flail"] = nil
    elseif hero == "wh" then
        hero_weapons[hero]["es_1h_flail"] = ItemMasterList.es_1h_flail
    elseif hero == "we" then
        hero_weapons[hero]["we_longbow_trueflight"] = nil
    end

    return hero_weapons[hero]
end

HeroViewStateArmory._fetch_weapon_skin_data = function (self)
    local weapon_name = self.weapon_name
    local weapon_skin_data = self.weapon_skin_data[weapon_name] or {}

    mod:set("preview_data", weapon_preview_data[weapon_name])

    -- No sense fetching more than once
    if #weapon_skin_data > 0 then
        return
    end

    local skin_prefix = mod:get("preview_data").skin_prefix .. "_skin"

    local regular_skins = {}
    local runed_skins = {}

    for skin_name in pairs(WeaponSkins.skins) do
        if string.match(skin_name, skin_prefix .. "_%d%d_runed") then
            table.insert(runed_skins, skin_name)
        elseif string.match(skin_name, skin_prefix .. "_%d%d") then
            table.insert(regular_skins, skin_name)
        end
    end
    table.sort(regular_skins)
    table.sort(runed_skins)

    local skins = {}
    for _, skin in ipairs(regular_skins) do
        skins[#skins + 1] = WeaponSkins.skins[skin]
        skins[#skins].name = skin
    end

    local display_name = ItemMasterList[self.weapon_name].display_name
    if skins[1].display_name ~= display_name then
        for index, skin in ipairs(skins) do
            if skin.display_name == display_name then
                table.remove(skins, index)
                table.insert(skins, index, skins[1])
                table.remove(skins, 1)
                table.insert(skins, 1, skin)
            end
        end
    end

    for _, skin in ipairs(runed_skins) do
        skins[#skins + 1] = WeaponSkins.skins[skin]
        skins[#skins].name = skin
    end

    self.weapon_skin_data[weapon_name] = skins
end

HeroViewStateArmory._is_weapon_button_pressed = function (self)
    local widget = self._widgets_by_name.item_grid
    local content = widget.content
    local rows = content.rows
    local cols = content.columns
    local slot_index = 1

    for i = 1, rows, 1 do
        for j = 1, cols, 1 do
            local name_suffix = "_" .. tostring(i) .. "_" .. tostring(j)
            local hotspot_name = "hotspot" .. name_suffix
            local hotspot_content = content[hotspot_name]
            local item = content["item" .. name_suffix]

            if item and hotspot_content.on_pressed then
                local is_selected = hotspot_content.is_selected

                return is_selected, slot_index
            end

            slot_index = slot_index + 1
        end
    end
end

HeroViewStateArmory._is_hero_button_pressed = function (self)
    local widget = self._widgets_by_name.hero_buttons
    local widget_content = widget.content
    local amount = widget_content.amount

    for i = 1, amount, 1 do
        local name_suffix = "_" .. tostring(i)
        local hotspot_name = "hotspot" .. name_suffix
        local hotspot_content = widget_content[hotspot_name]

        if hotspot_content.on_pressed then
            return i
        end
    end
end

local hero_bg_colors = {
    es = { 255, 9, 12, 56 },
    dr = { 255, 23, 66, 86 },
    we = { 255, 22, 41, 12 },
    wh = { 255, 55, 20, 13 },
    bw = { 255, 65, 16, 11 }
}
HeroViewStateArmory._select_hero_button_by_index = function (self, index)
    if index == self._selected_hero_index then
        return
    end

    mod:set("selected_hero_index", index)

    self:_clear_item_grid()
    self:play_sound("play_gui_hero_select_hero_click")

    local widget = self._widgets_by_name.hero_buttons
    local widget_content = widget.content
    local widget_style = widget.style
    local amount = widget_content.amount
    for i = 1, amount, 1 do
        local name_suffix = "_" .. tostring(i)
        local hotspot_name = "hotspot" .. name_suffix
        local hotspot_content = widget_content[hotspot_name]
        local icon_name = "icon" .. name_suffix
        local selected = i == index
        hotspot_content.is_selected = selected
        local icon_style = widget_style[icon_name]
        local icon_color = icon_style.color
        icon_color[2] = (selected and 255) or 100
        icon_color[3] = (selected and 255) or 100
        icon_color[4] = (selected and 255) or 100
    end

    self._selected_hero_index = index
    self._selected_hero_abbr = hero_abbreviations[index]
    mod.current_hero = self._selected_hero_abbr

    widget = self._widgets_by_name.window_bg
    widget.style.tiling_texture.color = hero_bg_colors[self._selected_hero_abbr]

    self:_populate_item_grid(index)

end

HeroViewStateArmory._is_hero_button_hovered = function (self, widget)
    widget = widget or self._widgets_by_name.hero_buttons
    local widget_content = widget.content
    local amount = widget_content.amount

    for i = 1, amount, 1 do
        local name_suffix = "_" .. tostring(i)
        local hotspot_name = "hotspot" .. name_suffix
        local hotspot_content = widget_content[hotspot_name]

        if hotspot_content.on_hover_enter and not hotspot_content.is_selected then
            return i
        end
    end
end

HeroViewStateArmory._is_hero_button_dehovered = function (self, widget)
    widget = widget or self._widgets_by_name.hero_buttons
    local widget_content = widget.content
    local amount = widget_content.amount

    for i = 1, amount, 1 do
        local name_suffix = "_" .. tostring(i)
        local hotspot_name = "hotspot" .. name_suffix
        local hotspot_content = widget_content[hotspot_name]

        if hotspot_content.on_hover_exit and not hotspot_content.is_selected then
            return i
        end
    end
end

HeroViewStateArmory._handle_hero_button_hover = function (self, style_prefix, widget)
    widget = widget or self._widgets_by_name.hero_buttons
    local hover_index = self:_is_hero_button_hovered(widget)

    if hover_index then
        self:_on_hero_button_hover(style_prefix .. "_" .. hover_index, widget)
    end

    local dehover_index = self:_is_hero_button_dehovered(widget)

    if dehover_index then
        self:_on_hero_button_dehover(style_prefix .. "_" .. dehover_index, widget)
    end
end

HeroViewStateArmory._handle_detail_info = function (self)
    local widgets_by_name = self._widgets_by_name
    local highlight_widgets = highlight_widget_list

    for index, widget_group in ipairs(highlight_widgets) do
        local hotspot_widget = widgets_by_name[widget_group .. "_hotspot"]

        if string.match(widget_group, "tray") == nil and self:_is_button_pressed(hotspot_widget) then

            if self.ignore_dehover_group ~= widget_group then
                self:_highlight_off(self.ignore_dehover_group, true)
            end

            self.ignore_dehover_group = widget_group
            self:_clear_detail_info()
            self:_highlight_on(widget_group)
            self:play_sound("Play_hud_hover")
            self:_display_detail_info(hotspot_widget.content.data)
        end
    end
end

HeroViewStateArmory._clear_detail_info = function (self)
    local widgets = self._widgets_by_name

    widgets.detail_info_title.content.text = ""
    widgets.detail_info_desc.content.text = "Rotate weapons using left-drag and right-drag."
    widgets.detail_info_desc2.content.text = "Rotate the camera around weapons using shift + left-drag;\npan the camera up or down with shift + right-drag;\nzoom in/out with the scroll-wheel."
    widgets.detail_info_desc2.style.font_size = 20
    widgets.coming_soon.content.text = "Select an attack or icon group for more details."
end

HeroViewStateArmory._display_detail_info = function (self, data)
    local widgets = self._widgets_by_name

    if data then
        local detail_title_widget = widgets.detail_info_title
        local detail_desc_widget = widgets.detail_info_desc
        local detail_desc2_widget = widgets.detail_info_desc2

        detail_title_widget.content.text = data.title or ""
        detail_desc_widget.content.text = data.desc or ""
        detail_desc2_widget.content.text = data.desc2 or ""
        widgets.coming_soon.content.text = ""

    else
        widgets.coming_soon.content.text = ""
        widgets.detail_info_title.content.text = "Attack Details Coming Soon"
    end
end

HeroViewStateArmory._handle_tray_hover = function (self)
    local widgets_by_name = self._widgets_by_name
    local highlight_widgets = highlight_widget_list

    for index, widget_group in ipairs(highlight_widgets) do
        local hotspot_widget = widgets_by_name[widget_group .. "_hotspot"]


        local hover_index = self:_is_tray_hovered(hotspot_widget)

        if hover_index then
            self:play_sound("play_gui_equipment_button_hover")
            self:_highlight_on(widget_group)
        end

        local dehover_index = self:_is_tray_dehovered(hotspot_widget)

        if dehover_index then
            self:_highlight_off(widget_group)
        end
    end

end

HeroViewStateArmory._highlight_on = function (self, widget_group)
    local widgets_by_name = self._widgets_by_name
    local background_widget = widgets_by_name[widget_group .. "_bg"]
    local frame_widget = widgets_by_name[widget_group .. "_hover"]

    self:_on_tray_hover(background_widget, widget_group, "style", "tiling_texture")
    self:_on_tray_hover(frame_widget, widget_group, "content", "frame")

    -- Adjust height of column highlight frame to match height of attack table
    local column_frame_widget = widgets_by_name[widget_group.."_column_hover"]
    if column_frame_widget then
        local scenegraph_size = self.ui_scenegraph[column_frame_widget.scenegraph_id].size
        scenegraph_size[2] = (total_attack_num * 35)
        self:_on_tray_hover(column_frame_widget, widget_group, "content", "frame")
    end

    local column_bg_widget = widgets_by_name[widget_group.."_column_bg"]
    if column_bg_widget then
        self:_on_tray_hover(column_bg_widget, widget_group, "style", "tiling_texture", true)
    end
end

HeroViewStateArmory._highlight_off = function (self, widget_group, force_off)
    if not widget_group or (not force_off and self.ignore_dehover_group == widget_group) then
        return
    end

    local widgets_by_name = self._widgets_by_name
    local background_widget = widgets_by_name[widget_group .. "_bg"]
    local frame_widget = widgets_by_name[widget_group .. "_hover"]

    self:_on_tray_dehover(background_widget, widget_group, "style", "tiling_texture")
    self:_on_tray_dehover(frame_widget, widget_group, "content", "frame")

    local column_frame_widget = widgets_by_name[widget_group.."_column_hover"]
    if column_frame_widget then
        self:_on_tray_dehover(column_frame_widget, widget_group, "content", "frame")
    end

    local column_bg_widget = widgets_by_name[widget_group.."_column_bg"]
    if column_bg_widget then
        self:_on_tray_dehover(column_bg_widget, widget_group, "style", "tiling_texture", true)
    end
end

HeroViewStateArmory._on_tray_hover = function (self, widget, widget_group, pass_type, style_id, alpha_only)
    if not widget then
        return
    end

    if pass_type == "style" then
        local ui_animations = self._ui_animations
        local animation_name = "tray_" .. tostring(widget_group) .. "_" .. style_id
        local widget_style = widget.style
        local pass_style = widget_style[style_id]
        local current_color_value = pass_style.color[2]
        local target_color_value = 255
        local total_time = UISettings.scoreboard.topic_hover_duration
        local animation_duration = (1 - current_color_value / target_color_value) * total_time

        if alpha_only then
            if animation_duration > 0 then
                ui_animations[animation_name .. "_hover_" .. 1] = self:_animate_element_by_time(pass_style.color, 1, current_color_value, target_color_value, animation_duration)
            else
                pass_style.color[1] = target_color_value
            end
        else
            for i = 2, 4, 1 do
                if animation_duration > 0 then
                    ui_animations[animation_name .. "_hover_" .. i] = self:_animate_element_by_time(pass_style.color, i, current_color_value, target_color_value, animation_duration)
                else
                    pass_style.color[i] = target_color_value
                end
            end
        end
    elseif pass_type == "content" then
        local widget_style = widget.style
        local pass_style = widget_style[style_id]
        local target_color_value = 255
        pass_style.color[1] = target_color_value
    end



end

HeroViewStateArmory._on_tray_dehover = function (self, widget, widget_group, pass_type, style_id, alpha_only)
    if not widget then
        return
    end

    if pass_type == "style" then
        local ui_animations = self._ui_animations
        local animation_name = "tray_" .. tostring(widget_group) .. "_" .. style_id
        local widget_style = widget.style
        local pass_style = widget_style[style_id]
        local current_color_value = pass_style.color[1]
        local target_color_value = 100
        local total_time = UISettings.scoreboard.topic_hover_duration
        local animation_duration = current_color_value / 255 * total_time

        if alpha_only then
            target_color_value = 0
            if animation_duration > 0 then
                ui_animations[animation_name .. "_hover_" .. 1] = self:_animate_element_by_time(pass_style.color, 1, current_color_value, target_color_value, animation_duration)
            else
                pass_style.color[1] = target_color_value
            end
        else
            for i = 2, 4, 1 do
                if animation_duration > 0 then
                    ui_animations[animation_name .. "_hover_" .. i] = self:_animate_element_by_time(pass_style.color, i, current_color_value, target_color_value, animation_duration)
                else
                    pass_style.color[i] = target_color_value
                end
            end
        end
    elseif pass_type == "content" then
        local widget_style = widget.style
        local pass_style = widget_style[style_id]
        local target_color_value = 0
        pass_style.color[1] = target_color_value
    end
end

HeroViewStateArmory._is_tray_hovered = function (self, widget)
    local widget_content = widget.content

    local hotspot_name = "hotspot"
    local hotspot_content = widget_content[hotspot_name]

    if hotspot_content.on_hover_enter then
        return true
    end
end

HeroViewStateArmory._is_tray_dehovered = function (self, widget)
    local widget_content = widget.content

    local hotspot_name = "hotspot"
    local hotspot_content = widget_content[hotspot_name]

    if hotspot_content.on_hover_exit then
        return true
    end
end

HeroViewStateArmory._on_hero_button_hover = function (self, style_id, widget)
    widget = widget or self._widgets_by_name.hero_buttons
    local ui_animations = self._ui_animations
    local animation_name = "option_button_" .. style_id
    local widget_style = widget.style
    local pass_style = widget_style[style_id]
    local current_color_value = pass_style.color[2]
    local target_color_value = 255
    local total_time = UISettings.scoreboard.topic_hover_duration
    local animation_duration = (1 - current_color_value / target_color_value) * total_time

    for i = 2, 4, 1 do
        if animation_duration > 0 then
            ui_animations[animation_name .. "_hover_" .. i] = self:_animate_element_by_time(pass_style.color, i, current_color_value, target_color_value, animation_duration)
        else
            pass_style.color[i] = target_color_value
        end
    end
end

HeroViewStateArmory._on_hero_button_dehover = function (self, style_id, widget)
    widget = widget or self._widgets_by_name.hero_buttons
    local ui_animations = self._ui_animations
    local animation_name = "option_button_" .. style_id
    local widget_style = widget.style
    local pass_style = widget_style[style_id]
    local current_color_value = pass_style.color[1]
    local target_color_value = 100
    local total_time = UISettings.scoreboard.topic_hover_duration
    local animation_duration = current_color_value / 255 * total_time

    for i = 2, 4, 1 do
        if animation_duration > 0 then
            ui_animations[animation_name .. "_hover_" .. i] = self:_animate_element_by_time(pass_style.color, i, current_color_value, target_color_value, animation_duration)
        else
            pass_style.color[1] = target_color_value
        end
    end
end

HeroViewStateArmory._animate_element_by_time = function (self, target, target_index, from, to, time)
    local new_animation = UIAnimation.init(UIAnimation.function_by_time, target, target_index, from, to, time, math.ease_out_quad)

    return new_animation
end

HeroViewStateArmory._is_button_pressed = function (self, widget)
    local content = widget.content
    local hotspot = content.button_hotspot or content.hotspot

    if hotspot.on_release then
        hotspot.on_release = false

        return true
    end
end

HeroViewStateArmory.close_menu = function (self, ignore_sound_on_close_menu)
    if not ignore_sound_on_close_menu then
        self:play_sound("Play_gui_achivements_menu_close")
    end

    ignore_sound_on_close_menu = true

    self.parent:close_menu(nil, ignore_sound_on_close_menu)
end

HeroViewStateArmory.draw = function (self, dt, input_service)
    local ui_renderer = self.ui_renderer
    local ui_scenegraph = self.ui_scenegraph
    local render_settings = self.render_settings

    if self._viewport_widget then
        UIRenderer.begin_pass(ui_renderer, ui_scenegraph, input_service, dt, nil, self.render_settings)
        UIRenderer.draw_widget(ui_renderer, self._viewport_widget)
        UIRenderer.end_pass(ui_renderer)
    end

    UIRenderer.begin_pass(ui_renderer, ui_scenegraph, input_service, dt, nil, render_settings)

    local snap_pixel_positions = render_settings.snap_pixel_positions
    local alpha_multiplier = render_settings.alpha_multiplier or 1

    for _, widget in pairs(self._widgets) do
        if widget.snap_pixel_positions ~= nil then
            render_settings.snap_pixel_positions = widget.snap_pixel_positions
        end

        render_settings.alpha_multiplier = widget.alpha_multiplier or alpha_multiplier

        UIRenderer.draw_widget(ui_renderer, widget)

        render_settings.snap_pixel_positions = snap_pixel_positions
    end

    UIRenderer.end_pass(ui_renderer)

    render_settings.alpha_multiplier = alpha_multiplier
end

HeroViewStateArmory.input_service = function (self)
    return self.parent:input_service()
end

HeroViewStateArmory.play_sound = function (self, event)
    self.parent:play_sound(event)
end

HeroViewStateArmory._has_active_level_vote = function (self)
    local voting_manager = self.voting_manager
    local active_vote_name = voting_manager:vote_in_progress()
    local is_mission_vote = active_vote_name == "game_settings_vote" or active_vote_name == "game_settings_deed_vote"

    return is_mission_vote and not voting_manager:has_voted(Network.peer_id())
end

HeroViewStateArmory.on_exit = function (self)
    self.ui_animator = nil

    if self.world_previewer then
        self.world_previewer:prepare_exit_armory()
        self.world_previewer:on_exit()
        self.world_previewer:destroy()
    end

    if self._viewport_widget then
        UIWidget.destroy(self.ui_renderer, self._viewport_widget)

        self._viewport_widget = nil
    end

    Managers.package:unload(self._inventory_package_name, "armory")

    self._level_package_name = nil
    self._inventory_package_name = nil

    mod:hook_disable(ActionUtils, "scale_power_levels")
end