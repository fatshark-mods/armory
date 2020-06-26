local window_default_settings = UISettings.game_start_windows
local window_size = window_default_settings.large_window_size   -- 1600 x 900

local left_window_size = {  -- 548 x 722
    math.floor( (window_size[1] + 44) / 3 ),
    window_size[2] - 62
}

local right_window_size = {
    math.floor(window_size[1] - left_window_size[1] - 66),
    math.floor(left_window_size[2])
}

local base_info_segment_width = right_window_size[1] / 6

return {
    root = {
        is_root = true,
        size = { 1920, 1080 },
        position = { 0, 0, UILayer.default }
    },
    menu_root = {
        parent = "root",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { 1920, 1080 },
        position = { 0, 0, 0 }
    },
    screen = {
        scale = "fit",
        size = { 1920, 1080 },
        position = { 0, 0, UILayer.default }
    },

    header = {
        parent = "menu_root",
        vertical_alignment = "top",
        horizontal_alignment = "center",
        size = { 1920, 1080 },
        position = { 0, -20, 100 }
    },
    window = {
        parent = "screen",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = window_size,
        position = { 0, 0, 1 }
    },
    window_bg = {
        parent = "window",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { window_size[1] - 5, window_size[2] - 5 },
        position = { 0, 0, 0 }
    },
    exit_button = {
        parent = "window",
        vertical_alignment = "bottom",
        horizontal_alignment = "center",
        size = { 380, 42 },
        position = { 0, -16, 42 }
    },
    title = {
        parent = "window",
        vertical_alignment = "top",
        horizontal_alignment = "center",
        size = { 658, 60 },
        position = { 0, 34, 46 }
    },
    title_bg = {
        parent = "title",
        vertical_alignment = "top",
        horizontal_alignment = "center",
        size = { 410, 40 },
        position = { 0, -15, -1 }
    },
    title_text = {
        parent = "title",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { 350, 50 },
        position = { 0, -3, 2}
    },

    right_window = {
        parent = "window",
        vertical_alignment = "top",
        horizontal_alignment = "right",
        size = right_window_size,
        position = { -30, -31, 2 }
    },

    left_window = {
        parent = "window",
        vertical_alignment = "center",
        horizontal_alignment = "left",
        size = { left_window_size[1] - 60, left_window_size[2] },
        position = { 30, 0, 2 }
    },
    right_window_tray = {
        parent = "right_window",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = right_window_size,
        position = { 0, 0, 2 }
    },
    right_window_tray_bottom = {
        parent = "right_window_tray",
        vertical_alignment = "bottom",
        horizontal_alignment = "center",
        size = { right_window_size[1], 50 },
        position = { 0, 5, 0 }
    },
    header_title_bar = {
        parent = "right_window_tray",
        vertical_alignment = "top",
        horizontal_alignment = "right",
        size = { right_window_size[1], 75 },
        position = { 0, 0, 2 }
    },
    header_title_divider = {
        parent = "header_title_bar",
        vertical_alignment = "bottom",
        horizontal_alignment = "center",
        size = { right_window_size[1] - 30, 21 },
        position = { 0, 0, 2 }
    },
    header_table_divider = {
        parent = "action_info_heavy_attack4",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { 264, 32 },
        position = { 0, -50, 0 }
    },

    header_title_text = {
        parent = "header_title_divider",
        vertical_alignment = "bottom",
        horizontal_alignment = "left",
        size = { base_info_segment_width * 2 + 25, 50 },
        position = { 5, -5, 50 }
    },

    header_attack_speed = {
        parent = "header_title_divider",
        vertical_alignment = "bottom",
        horizontal_alignment = "center",
        size = { base_info_segment_width / 2, 50 },
        position = { -base_info_segment_width / 2, 0, -1 }
    },
    header_attack_speed_icon = {
        parent = "header_attack_speed",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { 40, 40 },
        position = { 0, 0, 3 }
    },
    header_attack_speed_column = {
        parent = "header_attack_speed",
        vertical_alignment = "top",
        horizontal_alignment = "center",
        size = { base_info_segment_width / 2, 275 },
        position = { 0, -45, 1 }
    },

    header_cleave = {
        parent = "header_attack_speed",
        vertical_alignment = "center",
        horizontal_alignment = "right",
        size = { base_info_segment_width, 50 },
        position = { base_info_segment_width, 0, 0 }
    },
    header_cleave_icon = {
        parent = "header_cleave",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { 40, 40 },
        position = { 0, 0, 3 }
    },
    header_cleave_damage_abbr = {
        parent = "header_cleave",
        vertical_alignment = "center",
        horizontal_alignment = "left",
        size = { base_info_segment_width / 3, 50 },
        position = { 0, 0, 0 }
    },
    header_cleave_stagger_abbr = {
        parent = "header_cleave",
        vertical_alignment = "center",
        horizontal_alignment = "right",
        size = { base_info_segment_width / 3, 50 },
        position = { 0, 0, 0 }
    },
    header_cleave_column = {
        parent = "header_cleave",
        vertical_alignment = "top",
        horizontal_alignment = "center",
        size = { base_info_segment_width, 275 },
        position = { 0, -45, 1 }
    },

    header_armor_damage = {
        parent = "header_base_damage",
        vertical_alignment = "center",
        horizontal_alignment = "right",
        size = { base_info_segment_width / 2, 50 },
        position = { base_info_segment_width / 2, 0, 0 }
    },
    header_armor_damage_icon = {
        parent = "header_armor_damage",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { 40, 40 },
        position = { 0, 0, 3 }
    },
    header_armor_damage_column = {
        parent = "header_armor_damage",
        vertical_alignment = "top",
        horizontal_alignment = "center",
        size = { base_info_segment_width / 2, 275 },
        position = { 0, -45, 1 }
    },

    header_base_damage = {
        parent = "header_cleave",
        vertical_alignment = "center",
        horizontal_alignment = "right",
        size = { base_info_segment_width / 2, 50 },
        position = { base_info_segment_width / 2, 0, 0 }
    },
    header_base_damage_icon = {
        parent = "header_base_damage",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { 40, 40 },
        position = { 0, 0, 3 }
    },
    header_base_damage_column = {
        parent = "header_base_damage",
        vertical_alignment = "top",
        horizontal_alignment = "center",
        size = { base_info_segment_width / 2, 275 },
        position = { 0, -45, 1 }
    },

    header_special_property = {
        parent = "header_armor_damage",
        vertical_alignment = "center",
        horizontal_alignment = "right",
        size = { base_info_segment_width / 2, 50 },
        position = { base_info_segment_width / 2, 0, 0 }
    },
    header_special_property_icon = {
        parent = "header_special_property",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { 40, 40 },
        position = { 0, 0, 3 }
    },
    header_special_property_column = {
        parent = "header_special_property",
        vertical_alignment = "top",
        horizontal_alignment = "left",
        size = { base_info_segment_width + 28, 275 },
        position = { 0, -45, 1 }
    },

    base_info_melee_stamina = {
        parent = "header_title_divider",
        vertical_alignment = "bottom",
        horizontal_alignment = "right",
        size = { math.floor((right_window_size[1] / 2) / 6 + 10), 50 },
        position = { -10, 0, 2 }
    },
    base_info_melee_stamina_icon = {
        parent = "base_info_melee_stamina",
        vertical_alignment = "center",
        horizontal_alignment = "right",
        size = { 160, 160 },
        position = { 20, 0, 0 }
    },
    base_info_melee_stamina_value = {
        parent = "base_info_melee_stamina",
        vertical_alignment = "center",
        horizontal_alignment = "right",
        size = { 35, 35},
        position = { 0, 0, 0 }
    },

    action_info_ranged_attack1 = {
        parent = "header_title_divider",
        vertical_alignment = "top",
        horizontal_alignment = "left",
        size = { right_window_size[1] - 30, 35 },
        position = { 0, -16, -2 }
    },
    action_info_ranged_attack1_text = {
        parent = "action_info_ranged_attack1",
        vertical_alignment = "center",
        horizontal_alignment = "left",
        size = { right_window_size[1] / 2 - 5, 35 },
        position = { 15, 0, 2 },
    },
    action_info_ranged_attack1_attack_speed = {
        parent = "header_attack_speed",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { base_info_segment_width / 2, 35 },
        position = { 0, -37, 2 }
    },
    action_info_ranged_attack1_damage_limit = {
        parent = "header_cleave",
        vertical_alignment = "center",
        horizontal_alignment = "left",
        size = { base_info_segment_width / 2, 35 },
        position = { 10, -37, 2 }
    },
    action_info_ranged_attack1_stagger_limit = {
        parent = "header_cleave",
        vertical_alignment = "center",
        horizontal_alignment = "right",
        size = { base_info_segment_width / 2, 35 },
        position = { -10, -37, 2 }
    },
    action_info_ranged_attack1_armor_damage = {
        parent = "header_armor_damage",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { base_info_segment_width / 2, 35 },
        position = { 0, -37, 2 }
    },
    action_info_ranged_attack1_base_damage = {
        parent = "header_base_damage",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { base_info_segment_width / 2, 35 },
        position = { 0, -37, 2 }
    },
    action_info_ranged_attack1_special = {
        parent = "header_special_property",
        vertical_alignment = "center",
        horizontal_alignment = "left",
        size = { base_info_segment_width, 35 },
        position = { 15, -40, 2 }
    },

    action_info_ranged_attack2 = {
        parent = "action_info_ranged_attack1",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { right_window_size[1] - 30, 35 },
        position = { 0, -35, 0 }
    },
    action_info_ranged_attack2_text = {
        parent = "action_info_ranged_attack2",
        vertical_alignment = "center",
        horizontal_alignment = "left",
        size = { right_window_size[1] / 2 - 5, 35 },
        position = { 15, 0, 2 }
    },
    action_info_ranged_attack2_attack_speed = {
        parent = "action_info_ranged_attack1_attack_speed",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { base_info_segment_width / 2, 35 },
        position = { 0, -35, 0 }
    },
    action_info_ranged_attack2_damage_limit = {
        parent = "action_info_ranged_attack1_damage_limit",
        vertical_alignment = "center",
        horizontal_alignment = "left",
        size = { base_info_segment_width / 2, 35 },
        position = { 0, -35, 0 }
    },
    action_info_ranged_attack2_stagger_limit = {
        parent = "action_info_ranged_attack1_stagger_limit",
        vertical_alignment = "center",
        horizontal_alignment = "right",
        size = { base_info_segment_width / 2, 35 },
        position = { 0, -35, 0 }
    },
    action_info_ranged_attack2_armor_damage = {
        parent = "action_info_ranged_attack1_armor_damage",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { base_info_segment_width / 2, 35 },
        position = { 0, -35, 0 }
    },
    action_info_ranged_attack2_base_damage = {
        parent = "action_info_ranged_attack1_base_damage",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { base_info_segment_width / 2, 35 },
        position = { 0, -35, 0 }
    },
    action_info_ranged_attack2_special = {
        parent = "action_info_ranged_attack1_special",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { base_info_segment_width, 35 },
        position = { 0, -35, 0 }
    },

    action_info_ranged_attack3 = {
        parent = "action_info_ranged_attack2",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { right_window_size[1] - 30, 35 },
        position = { 0, -35, 0 }
    },
    action_info_ranged_attack3_text = {
        parent = "action_info_ranged_attack3",
        vertical_alignment = "center",
        horizontal_alignment = "left",
        size = { right_window_size[1] / 2 - 5, 35 },
        position = { 15, 0, 2 }
    },
    action_info_ranged_attack3_attack_speed = {
        parent = "action_info_ranged_attack2_attack_speed",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { base_info_segment_width / 2, 35 },
        position = { 0, -35, 0 }
    },
    action_info_ranged_attack3_damage_limit = {
        parent = "action_info_ranged_attack2_damage_limit",
        vertical_alignment = "center",
        horizontal_alignment = "left",
        size = { base_info_segment_width / 2, 35 },
        position = { 0, -35, 0 }
    },
    action_info_ranged_attack3_stagger_limit = {
        parent = "action_info_ranged_attack2_stagger_limit",
        vertical_alignment = "center",
        horizontal_alignment = "right",
        size = { base_info_segment_width / 2, 35 },
        position = { 0, -35, 0 }
    },
    action_info_ranged_attack3_armor_damage = {
        parent = "action_info_ranged_attack2_armor_damage",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { base_info_segment_width / 2, 35 },
        position = { 0, -35, 1 }
    },
    action_info_ranged_attack3_base_damage = {
        parent = "action_info_ranged_attack2_base_damage",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { base_info_segment_width / 2, 35 },
        position = { 0, -35, 1 }
    },
    action_info_ranged_attack3_special = {
        parent = "action_info_ranged_attack2_special",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { base_info_segment_width, 35 },
        position = { 0, -35, 0 }
    },

    action_info_ranged_attack4 = {
        parent = "action_info_ranged_attack3",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { right_window_size[1] - 30, 35 },
        position = { 0, -35, 0 }
    },
    action_info_ranged_attack4_text = {
        parent = "action_info_ranged_attack4",
        vertical_alignment = "center",
        horizontal_alignment = "left",
        size = { right_window_size[1] / 2 - 5, 35 },
        position = { 15, 0, 2 }
    },
    action_info_ranged_attack4_attack_speed = {
        parent = "action_info_ranged_attack3_attack_speed",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { base_info_segment_width / 2, 35 },
        position = { 0, -35, 0 }
    },
    action_info_ranged_attack4_damage_limit = {
        parent = "action_info_ranged_attack3_damage_limit",
        vertical_alignment = "center",
        horizontal_alignment = "left",
        size = { base_info_segment_width / 2, 35 },
        position = { 0, -35, 0 }
    },
    action_info_ranged_attack4_stagger_limit = {
        parent = "action_info_ranged_attack3_stagger_limit",
        vertical_alignment = "center",
        horizontal_alignment = "right",
        size = { base_info_segment_width / 2, 35 },
        position = { 0, -35, 0 }
    },
    action_info_ranged_attack4_armor_damage = {
        parent = "action_info_ranged_attack3_armor_damage",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { base_info_segment_width / 2, 35 },
        position = { 0, -35, 1 }
    },
    action_info_ranged_attack4_base_damage = {
        parent = "action_info_ranged_attack3_base_damage",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { base_info_segment_width / 2, 35 },
        position = { 0, -35, 1 }
    },
    action_info_ranged_attack4_special = {
        parent = "action_info_ranged_attack3_special",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { base_info_segment_width, 35 },
        position = { 0, -35, 0 }
    },

    action_info_light_attack1 = {
        parent = "header_title_divider",
        vertical_alignment = "top",
        horizontal_alignment = "left",
        size = { right_window_size[1] - 30, 35 },
        position = { 0, -16, -2 }
    },
    action_info_light_attack1_text = {
        parent = "action_info_light_attack1",
        vertical_alignment = "center",
        horizontal_alignment = "left",
        size = { right_window_size[1] / 2 - 5, 35 },
        position = { 15, 0, 2 },
    },
    action_info_light_attack1_attack_speed = {
        parent = "header_attack_speed",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { base_info_segment_width / 2, 35 },
        position = { 0, -37, 2 }
    },
    action_info_light_attack1_damage_limit = {
        parent = "header_cleave",
        vertical_alignment = "center",
        horizontal_alignment = "left",
        size = { base_info_segment_width / 2, 35 },
        position = { 10, -37, 2 }
    },
    action_info_light_attack1_stagger_limit = {
        parent = "header_cleave",
        vertical_alignment = "center",
        horizontal_alignment = "right",
        size = { base_info_segment_width / 2, 35 },
        position = { -10, -37, 2 }
    },
    action_info_light_attack1_armor_damage = {
        parent = "header_armor_damage",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { base_info_segment_width / 2, 35 },
        position = { 0, -37, 2 }
    },
    action_info_light_attack1_base_damage = {
        parent = "header_base_damage",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { base_info_segment_width / 2, 35 },
        position = { 0, -37, 2 }
    },
    action_info_light_attack1_special = {
        parent = "header_special_property",
        vertical_alignment = "center",
        horizontal_alignment = "left",
        size = { base_info_segment_width, 35 },
        position = { 15, -40, 2 }
    },

    action_info_light_attack2 = {
        parent = "action_info_light_attack1",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { right_window_size[1] - 30, 35 },
        position = { 0, -35, 0 }
    },
    action_info_light_attack2_text = {
        parent = "action_info_light_attack2",
        vertical_alignment = "center",
        horizontal_alignment = "left",
        size = { right_window_size[1] / 2 - 5, 35 },
        position = { 15, 0, 2 }
    },
    action_info_light_attack2_attack_speed = {
        parent = "action_info_light_attack1_attack_speed",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { base_info_segment_width / 2, 35 },
        position = { 0, -35, 0 }
    },
    action_info_light_attack2_damage_limit = {
        parent = "action_info_light_attack1_damage_limit",
        vertical_alignment = "center",
        horizontal_alignment = "left",
        size = { base_info_segment_width / 2, 35 },
        position = { 0, -35, 0 }
    },
    action_info_light_attack2_stagger_limit = {
        parent = "action_info_light_attack1_stagger_limit",
        vertical_alignment = "center",
        horizontal_alignment = "right",
        size = { base_info_segment_width / 2, 35 },
        position = { 0, -35, 0 }
    },
    action_info_light_attack2_armor_damage = {
        parent = "action_info_light_attack1_armor_damage",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { base_info_segment_width / 2, 35 },
        position = { 0, -35, 0 }
    },
    action_info_light_attack2_base_damage = {
        parent = "action_info_light_attack1_base_damage",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { base_info_segment_width / 2, 35 },
        position = { 0, -35, 0 }
    },
    action_info_light_attack2_special = {
        parent = "action_info_light_attack1_special",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { base_info_segment_width, 35 },
        position = { 0, -35, 0 }
    },

    action_info_light_attack3 = {
        parent = "action_info_light_attack2",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { right_window_size[1] - 30, 35 },
        position = { 0, -35, 0 }
    },
    action_info_light_attack3_text = {
        parent = "action_info_light_attack3",
        vertical_alignment = "center",
        horizontal_alignment = "left",
        size = { right_window_size[1] / 2 - 5, 35 },
        position = { 15, 0, 2 }
    },
    action_info_light_attack3_attack_speed = {
        parent = "action_info_light_attack2_attack_speed",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { base_info_segment_width / 2, 35 },
        position = { 0, -35, 0 }
    },
    action_info_light_attack3_damage_limit = {
        parent = "action_info_light_attack2_damage_limit",
        vertical_alignment = "center",
        horizontal_alignment = "left",
        size = { base_info_segment_width / 2, 35 },
        position = { 0, -35, 0 }
    },
    action_info_light_attack3_stagger_limit = {
        parent = "action_info_light_attack2_stagger_limit",
        vertical_alignment = "center",
        horizontal_alignment = "right",
        size = { base_info_segment_width / 2, 35 },
        position = { 0, -35, 0 }
    },
    action_info_light_attack3_armor_damage = {
        parent = "action_info_light_attack2_armor_damage",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { base_info_segment_width / 2, 35 },
        position = { 0, -35, 1 }
    },
    action_info_light_attack3_base_damage = {
        parent = "action_info_light_attack2_base_damage",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { base_info_segment_width / 2, 35 },
        position = { 0, -35, 1 }
    },
    action_info_light_attack3_special = {
        parent = "action_info_light_attack2_special",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { base_info_segment_width, 35 },
        position = { 0, -35, 0 }
    },

    action_info_light_attack4 = {
        parent = "action_info_light_attack3",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { right_window_size[1] - 30, 35 },
        position = { 0, -35, 0 }
    },
    action_info_light_attack4_text = {
        parent = "action_info_light_attack4",
        vertical_alignment = "center",
        horizontal_alignment = "left",
        size = { right_window_size[1] / 2 - 5, 35 },
        position = { 15, 0, 2 }
    },
    action_info_light_attack4_attack_speed = {
        parent = "action_info_light_attack3_attack_speed",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { base_info_segment_width / 2, 35 },
        position = { 0, -35, 0 }
    },
    action_info_light_attack4_damage_limit = {
        parent = "action_info_light_attack3_damage_limit",
        vertical_alignment = "center",
        horizontal_alignment = "left",
        size = { base_info_segment_width / 2, 35 },
        position = { 0, -35, 0 }
    },
    action_info_light_attack4_stagger_limit = {
        parent = "action_info_light_attack3_stagger_limit",
        vertical_alignment = "center",
        horizontal_alignment = "right",
        size = { base_info_segment_width / 2, 35 },
        position = { 0, -35, 0 }
    },
    action_info_light_attack4_armor_damage = {
        parent = "action_info_light_attack3_armor_damage",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { base_info_segment_width / 2, 35 },
        position = { 0, -35, 1 }
    },
    action_info_light_attack4_base_damage = {
        parent = "action_info_light_attack3_base_damage",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { base_info_segment_width / 2, 35 },
        position = { 0, -35, 1 }
    },
    action_info_light_attack4_special = {
        parent = "action_info_light_attack3_special",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { base_info_segment_width, 35 },
        position = { 0, -35, 0 }
    },

    action_info_push_attack = {
        parent = "action_info_light_attack4",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { right_window_size[1] - 30, 35 },
        position = { 0, -35, 0 }
    },
    action_info_push_attack_text = {
        parent = "action_info_push_attack",
        vertical_alignment = "center",
        horizontal_alignment = "left",
        size = { right_window_size[1] / 2 - 5, 35 },
        position = { 15, 0, 2 }
    },
    action_info_push_attack_attack_speed = {
        parent = "action_info_light_attack4_attack_speed",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { base_info_segment_width / 2, 35 },
        position = { 0, -35, 0 }
    },
    action_info_push_attack_damage_limit = {
        parent = "action_info_light_attack4_damage_limit",
        vertical_alignment = "center",
        horizontal_alignment = "left",
        size = { base_info_segment_width / 2, 35 },
        position = { 0, -35, 0 }
    },
    action_info_push_attack_stagger_limit = {
        parent = "action_info_light_attack4_stagger_limit",
        vertical_alignment = "center",
        horizontal_alignment = "right",
        size = { base_info_segment_width / 2, 35 },
        position = { 0, -35, 0 }
    },
    action_info_push_attack_armor_damage = {
        parent = "action_info_light_attack4_armor_damage",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { base_info_segment_width / 2, 35 },
        position = { 0, -35, 1 }
    },
    action_info_push_attack_base_damage = {
        parent = "action_info_light_attack4_base_damage",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { base_info_segment_width / 2, 35 },
        position = { 0, -35, 1 }
    },
    action_info_push_attack_special = {
        parent = "action_info_light_attack4_special",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { base_info_segment_width, 35 },
        position = { 0, -35, 0 }
    },

    action_info_heavy_attack1 = {
        parent = "action_info_push_attack",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { right_window_size[1] - 30, 35 },
        position = { 0, -35, 0 }
    },
    action_info_heavy_attack1_text = {
        parent = "action_info_heavy_attack1",
        vertical_alignment = "center",
        horizontal_alignment = "left",
        size = { right_window_size[1] / 2 - 5, 35 },
        position = { 15, 0, 2 }
    },
    action_info_heavy_attack1_attack_speed = {
        parent = "action_info_push_attack_attack_speed",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { base_info_segment_width / 2, 35 },
        position = { 0, -35, 0 }
    },
    action_info_heavy_attack1_damage_limit = {
        parent = "action_info_push_attack_damage_limit",
        vertical_alignment = "center",
        horizontal_alignment = "left",
        size = { base_info_segment_width / 2, 35 },
        position = { 0, -35, 0 }
    },
    action_info_heavy_attack1_stagger_limit = {
        parent = "action_info_push_attack_stagger_limit",
        vertical_alignment = "center",
        horizontal_alignment = "right",
        size = { base_info_segment_width / 2, 35 },
        position = { 0, -35, 0 }
    },
    action_info_heavy_attack1_armor_damage = {
        parent = "action_info_push_attack_armor_damage",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { base_info_segment_width / 2, 35 },
        position = { 0, -35, 1 }
    },
    action_info_heavy_attack1_base_damage = {
        parent = "action_info_push_attack_base_damage",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { base_info_segment_width / 2, 35 },
        position = { 0, -35, 1 }
    },
    action_info_heavy_attack1_special = {
        parent = "action_info_push_attack_special",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { base_info_segment_width, 35 },
        position = { 0, -35, 0 }
    },

    action_info_heavy_attack2 = {
        parent = "action_info_heavy_attack1",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { right_window_size[1] - 30, 35 },
        position = { 0, -35, 0 }
    },
    action_info_heavy_attack2_text = {
        parent = "action_info_heavy_attack2",
        vertical_alignment = "center",
        horizontal_alignment = "left",
        size = { right_window_size[1] / 2 - 5, 35 },
        position = { 15, 0, 2 }
    },
    action_info_heavy_attack2_attack_speed = {
        parent = "action_info_heavy_attack1_attack_speed",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { base_info_segment_width / 2, 35 },
        position = { 0, -35, 0 }
    },
    action_info_heavy_attack2_damage_limit = {
        parent = "action_info_heavy_attack1_damage_limit",
        vertical_alignment = "center",
        horizontal_alignment = "left",
        size = { base_info_segment_width / 2, 35 },
        position = { 0, -35, 0 }
    },
    action_info_heavy_attack2_stagger_limit = {
        parent = "action_info_heavy_attack1_stagger_limit",
        vertical_alignment = "center",
        horizontal_alignment = "right",
        size = { base_info_segment_width / 2, 35 },
        position = { 0, -35, 0 }
    },
    action_info_heavy_attack2_armor_damage = {
        parent = "action_info_heavy_attack1_armor_damage",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { base_info_segment_width / 2, 35 },
        position = { 0, -35, 1 }
    },
    action_info_heavy_attack2_base_damage = {
        parent = "action_info_heavy_attack1_base_damage",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { base_info_segment_width / 2, 35 },
        position = { 0, -35, 1 }
    },
    action_info_heavy_attack2_special = {
        parent = "action_info_heavy_attack1_special",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { base_info_segment_width, 35 },
        position = { 0, -35, 0 }
    },


    action_info_heavy_attack3 = {
        parent = "action_info_heavy_attack2",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { right_window_size[1] - 30, 35 },
        position = { 0, -35, 0 }
    },
    action_info_heavy_attack3_text = {
        parent = "action_info_heavy_attack3",
        vertical_alignment = "center",
        horizontal_alignment = "left",
        size = { right_window_size[1] / 2 - 5, 35 },
        position = { 15, 0, 2 }
    },
    action_info_heavy_attack3_attack_speed = {
        parent = "action_info_heavy_attack2_attack_speed",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { base_info_segment_width / 2, 35 },
        position = { 0, -35, 0 }
    },
    action_info_heavy_attack3_damage_limit = {
        parent = "action_info_heavy_attack2_damage_limit",
        vertical_alignment = "center",
        horizontal_alignment = "left",
        size = { base_info_segment_width / 2, 35 },
        position = { 0, -35, 0 }
    },
    action_info_heavy_attack3_stagger_limit = {
        parent = "action_info_heavy_attack2_stagger_limit",
        vertical_alignment = "center",
        horizontal_alignment = "right",
        size = { base_info_segment_width / 2, 35 },
        position = { 0, -35, 0 }
    },
    action_info_heavy_attack3_armor_damage = {
        parent = "action_info_heavy_attack2_armor_damage",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { base_info_segment_width / 2, 35 },
        position = { 0, -35, 1 }
    },
    action_info_heavy_attack3_base_damage = {
        parent = "action_info_heavy_attack2_base_damage",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { base_info_segment_width / 2, 35 },
        position = { 0, -35, 1 }
    },
    action_info_heavy_attack3_special = {
        parent = "action_info_heavy_attack2_special",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { base_info_segment_width, 35 },
        position = { 0, -35, 0 }
    },

    action_info_heavy_attack4 = {
        parent = "action_info_heavy_attack3",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { right_window_size[1] - 30, 35 },
        position = { 0, -35, 0 }
    },
    action_info_heavy_attack4_text = {
        parent = "action_info_heavy_attack4",
        vertical_alignment = "center",
        horizontal_alignment = "left",
        size = { right_window_size[1] / 2 - 5, 35 },
        position = { 15, 0, 2 }
    },
    action_info_heavy_attack4_attack_speed = {
        parent = "action_info_heavy_attack3_attack_speed",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { base_info_segment_width / 2, 35 },
        position = { 0, -35, 0 }
    },
    action_info_heavy_attack4_damage_limit = {
        parent = "action_info_heavy_attack3_damage_limit",
        vertical_alignment = "center",
        horizontal_alignment = "left",
        size = { base_info_segment_width / 2, 35 },
        position = { 0, -35, 0 }
    },
    action_info_heavy_attack4_stagger_limit = {
        parent = "action_info_heavy_attack3_stagger_limit",
        vertical_alignment = "center",
        horizontal_alignment = "right",
        size = { base_info_segment_width / 2, 35 },
        position = { 0, -35, 0 }
    },
    action_info_heavy_attack4_armor_damage = {
        parent = "action_info_heavy_attack3_armor_damage",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { base_info_segment_width / 2, 35 },
        position = { 0, -35, 1 }
    },
    action_info_heavy_attack4_base_damage = {
        parent = "action_info_heavy_attack3_base_damage",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { base_info_segment_width / 2, 35 },
        position = { 0, -35, 1 }
    },
    action_info_heavy_attack4_special = {
        parent = "action_info_heavy_attack3_special",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { base_info_segment_width, 35 },
        position = { 0, -35, 0 }
    },
    
    base_info_ranged_reload_time = {
        parent = "right_window_tray",
        vertical_alignment = "bottom",
        horizontal_alignment = "left",
        size = { base_info_segment_width - 10, 60 },
        position = { 0, 0, 1 }
    },
    base_info_ranged_reload_time_icon = {
        parent = "base_info_ranged_reload_time",
        vertical_alignment = "center",
        horizontal_alignment = "left",
        size = { 40, 40 },
        position = { 15, 0, 2 }
    },
    base_info_ranged_reload_time_value = {
        parent = "base_info_ranged_reload_time",
        vertical_alignment = "center",
        horizontal_alignment = "right",
        size = { base_info_segment_width - 10, 35 },
        position = { -15, 0, 1 }
    },

    base_info_ranged_ammo = {
        parent = "right_window_tray",
        vertical_alignment = "bottom",
        horizontal_alignment = "left",
        size = { base_info_segment_width + 20, 60 },
        position = { base_info_segment_width - 10, 0, 1 }
    },
    base_info_ranged_ammo_icon = {
        parent = "base_info_ranged_ammo",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { 40, 40 },
        position = { 0, 0, 2 }
    },
    base_info_ranged_ammo_value_left = {
        parent = "base_info_ranged_ammo",
        vertical_alignment = "center",
        horizontal_alignment = "left",
        size = { base_info_segment_width + 20, 40 },
        position = { 7, 0, 1 }
    },
    base_info_ranged_ammo_value_right = {
        parent = "base_info_ranged_ammo",
        vertical_alignment = "center",
        horizontal_alignment = "right",
        size = { base_info_segment_width + 20, 40 },
        position = { -15, 0, 1 }
    },

    base_info_ranged_overcharge = {
        parent = "right_window_tray",
        vertical_alignment = "bottom",
        horizontal_alignment = "left",
        size = { base_info_segment_width + 20, 60 },
        position = { base_info_segment_width - 10, 0, 1 }
    },
    base_info_ranged_overcharge_icon = {
        parent = "base_info_ranged_overcharge",
        vertical_alignment = "center",
        horizontal_alignment = "left",
        size = { 40, 40 },
        position = { 15, 0, 2 }
    },
    base_info_ranged_overcharge_value = {
        parent = "base_info_ranged_overcharge",
        vertical_alignment = "center",
        horizontal_alignment = "right",
        size = { base_info_segment_width + 20, 40 },
        position = { -15, 0, 1 }
    },

    base_info_ranged_max_range = {
        parent = "right_window_tray",
        vertical_alignment = "bottom",
        horizontal_alignment = "right",
        size = { base_info_segment_width + 20, 60 },
        position = { -base_info_segment_width + 10, 0, 1 }
    },
    base_info_ranged_max_range_icon = {
        parent = "base_info_ranged_max_range",
        vertical_alignment = "center",
        horizontal_alignment = "right",
        size = { 40, 40 },
        position = { -15, 0, 2 }
    },
    base_info_ranged_max_range_value = {
        parent = "base_info_ranged_max_range",
        vertical_alignment = "center",
        horizontal_alignment = "left",
        size = { base_info_segment_width - 10 - 40, 35 },
        position = { 7, 0, 1 }
    },

    base_info_melee_block_angle = {
        parent = "right_window_tray",
        vertical_alignment = "bottom",
        horizontal_alignment = "left",
        size = { base_info_segment_width - 10, 60 },
        position = { 0, 0, 1 }
    },
    base_info_melee_block_angle_icon = {
        parent = "base_info_melee_block_angle",
        vertical_alignment = "center",
        horizontal_alignment = "left",
        size = { 40, 40 },
        position = { 15, 0, 2 }
    },
    base_info_melee_block_angle_value = {
        parent = "base_info_melee_block_angle",
        vertical_alignment = "center",
        horizontal_alignment = "right",
        size = { (base_info_segment_width - 10), 35 },
        position = { -15, 0, 1 }
    },

    base_info_melee_block_efficiency = {
        parent = "right_window_tray",
        vertical_alignment = "bottom",
        horizontal_alignment = "left",
        size = { base_info_segment_width + 20, 60 },
        position = { base_info_segment_width - 10, 0, 1 }
    },
    base_info_melee_block_efficiency_icon = {
        parent = "base_info_melee_block_efficiency",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { 40, 40 },
        position = { 0, 0, 2 }
    },
    base_info_melee_block_efficiency_value_left = {
        parent = "base_info_melee_block_efficiency",
        vertical_alignment = "center",
        horizontal_alignment = "left",
        size = { base_info_segment_width + 20, 40 },
        position = { 7, 0, 1 }
    },
    base_info_melee_block_efficiency_value_right = {
        parent = "base_info_melee_block_efficiency",
        vertical_alignment = "center",
        horizontal_alignment = "right",
        size = { base_info_segment_width + 20, 40 },
        position = { -15, 0, 1 }
    },

    base_info_dodge_bonus = {
        parent = "right_window_tray",
        vertical_alignment = "bottom",
        horizontal_alignment = "center",
        size = { base_info_segment_width - 10, 60 },
        position = { -base_info_segment_width / 2 + 5, 0, 1 }
    },
    base_info_dodge_bonus_icon = {
        parent = "base_info_dodge_bonus",
        vertical_alignment = "center",
        horizontal_alignment = "left",
        size = { 40, 40 },
        position = { 15, 0, 2 }
    },
    base_info_dodge_bonus_value = {
        parent = "base_info_dodge_bonus",
        vertical_alignment = "center",
        horizontal_alignment = "right",
        size = { base_info_segment_width - 10, 35 },
        position = { -15, 0, 1 }
    },

    base_info_dodge_count = {
        parent = "right_window_tray",
        vertical_alignment = "bottom",
        horizontal_alignment = "center",
        size = { base_info_segment_width - 10, 60 },
        position = { base_info_segment_width / 2 - 5, 0, 1 }
    },
    base_info_dodge_count_icon = {
        parent = "base_info_dodge_count",
        vertical_alignment = "center",
        horizontal_alignment = "right",
        size = { 40, 40 },
        position = { -15, 0, 2 }
    },
    base_info_dodge_count_value = {
        parent = "base_info_dodge_count",
        vertical_alignment = "center",
        horizontal_alignment = "left",
        size = { base_info_segment_width - 10, 35 },
        position = { 15, 0, 1 }
    },

    base_info_melee_push_angles = {
        parent = "right_window_tray",
        vertical_alignment = "bottom",
        horizontal_alignment = "right",
        size = { base_info_segment_width + 20, 60 },
        position = { -base_info_segment_width + 10, 0, 1 }
    },
    base_info_melee_push_angles_icon = {
        parent = "base_info_melee_push_angles",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { 40, 40 },
        position = { 0, 0, 2 }
    },
    base_info_melee_push_angles_value_left = {
        parent = "base_info_melee_push_angles",
        vertical_alignment = "center",
        horizontal_alignment = "left",
        size = { base_info_segment_width + 20, 40 },
        position = { 5, 0, 1 }
    },
    base_info_melee_push_angles_value_right = {
        parent = "base_info_melee_push_angles",
        vertical_alignment = "center",
        horizontal_alignment = "right",
        size = { base_info_segment_width + 20, 40 },
        position = { -5, 0, 1 }
    },

    base_info_melee_push_radius = {
        parent = "right_window_tray",
        vertical_alignment = "bottom",
        horizontal_alignment = "right",
        size = { base_info_segment_width - 10, 60},
        position = { 0, 0, 1 }
    },
    base_info_melee_push_radius_icon = {
        parent = "base_info_melee_push_radius",
        vertical_alignment = "center",
        horizontal_alignment = "right",
        size = { 40, 40 },
        position = { -15, 0, 2 }
    },
    base_info_melee_push_radius_value = {
        parent = "base_info_melee_push_radius",
        vertical_alignment = "center",
        horizontal_alignment = "left",
        size = { base_info_segment_width - 10, 35 },
        position = { 15, 0, 1 }
    },

    weapon_preview_tray = {
        parent = "left_window",
        vertical_alignment = "bottom",
        horizontal_alignment = "center",
        size = { left_window_size[1], left_window_size[2] - 395 },
        position = { 30, 0, 1 }
    },
    weapon_preview_viewport = {
        parent = "weapon_preview_tray",
        vertical_alignment = "top",
        horizontal_alignment = "center",
        size = { left_window_size[1] - 10, left_window_size[2] - 475 },
        position = { 0, -5, 8 }
    },
    weapon_preview_button_tray = {
        parent = "weapon_preview_tray",
        vertical_alignment = "bottom",
        horizontal_alignment = "center",
        size = { left_window_size[1], 75 },
        position = { 0, 0, 0 }
    },
    reset_preview_button = {
        parent = "weapon_preview_button_tray",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { left_window_size[1] * 0.55, 75 },
        position = { 0, 0, 1 }
    },
    prev_illusion_button = {
        parent = "weapon_preview_button_tray",
        vertical_alignment = "center",
        horizontal_alignment = "left",
        size = { 100, 75 },
        position = { 10, 0, 1 }
    },
    next_illusion_button = {
        parent = "weapon_preview_button_tray",
        vertical_alignment = "center",
        horizontal_alignment = "right",
        size = { 100, 75 },
        position = { -10, 0, 1 }
    },

    hero_tray = {
        parent = "left_window",
        vertical_alignment = "top",
        horizontal_alignment = "center",
        size = { left_window_size[1], 150 },
        position = { 30, 0, 5 }
    },
    hero_tray_fade = {
        parent = "hero_tray",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { left_window_size[1] - 4, 150 - 4 },
        position = { 0, 0, 1 }
    },
    hero_tray_bg = {
        parent = "hero_tray",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { left_window_size[1], 150 },
        position = { 0, 0, 0 }
    },
    hero_tray_icons = {
        parent = "hero_tray",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { left_window_size[1], 150 },
        position = { left_window_size[1] / 2, 33, 1 }
    },

    weapon_tray = {
        parent = "hero_tray",
        vertical_alignment = "top",
        horizontal_alignment = "center",
        size = { left_window_size[1], 225 },
        position = { 0, -160, 5 }
    },
    weapon_tray_fade = {
        parent = "weapon_tray",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { left_window_size[1] - 4, 225 - 44 },
        position = { 0, 0, 1 }
    },
    weapon_tray_bg = {
        parent = "weapon_tray",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { left_window_size[1], 225 },
        position = { 0, 0, 0 }
    },

    item_tabs = {
        parent = "weapon_tray",
        vertical_alignment = "top",
        horizontal_alignment = "center",
        size = { left_window_size[1], 40 },
        position = { 0, 0, 1 }
    },
    item_tabs_segments = {
        parent = "item_tabs",
        vertical_alignment = "bottom",
        horizontal_alignment = "center",
        size = { left_window_size[1], 0 },
        position = { 0, 5, 10 }
    },

    item_tabs_segments_top = {
        parent = "item_tabs",
        vertical_alignment = "top",
        horizontal_alignment = "center",
        size = { left_window_size[1], 0 },
        position = { 0, -12, 20 }
    },
    item_tabs_segments_bottom = {
        parent = "item_tabs",
        vertical_alignment = "bottom",
        horizontal_alignment = "center",
        size = { left_window_size[1], 0 },
        position = { 0, 3, 20 }
    },
    item_tabs_divider = {
        parent = "item_tabs",
        vertical_alignment = "bottom",
        horizontal_alignment = "center",
        size = { left_window_size[1], 0 },
        position = { 0, 0, 7 }
    },

    item_grid = {
        parent = "weapon_tray",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { left_window_size[1], 150 - 40 },
        position = { 0, -15, 8 }
    },

    coming_soon = {
        parent = "header_table_divider",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { right_window_size[1] - 30, 50 },
        position = { 0, -50, 2 }
    },

    detail_info_title = {
        parent = "header_table_divider",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { (right_window_size[1] - 30), 50 },
        position = { 0, -50, 2 }
    },

    detail_info_desc = {
        parent = "detail_info_title",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { (right_window_size[1] - 30), 50 },
        position = { 0, -100, 2 }
    },

    detail_info_desc2 = {
        parent = "detail_info_desc",
        vertical_alignment = "center",
        horizontal_alignment = "center",
        size = { right_window_size[1] - 30, 300 },
        position = { 0, - 100, 2 }
    },

    bar_test = {
        parent = "right_window_tray_bottom",
        vertical_alignment = "bottom",
        horizontal_alignment = "center",
        size = { 10, 500 },
        position = { 0, 50, 2 }
    }

}