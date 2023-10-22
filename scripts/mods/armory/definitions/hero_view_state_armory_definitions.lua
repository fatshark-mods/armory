local mod = get_mod("armory")

local scenegraph_definition = mod:dofile("scripts/mods/armory/definitions/hero_view_state_armory_scenegraph")

-- Borrowed from UIWidgets.create_grid()
mod.create_grid = function (scenegraph_id, size, rows, slots_per_row, slot_width_spacing, slot_height_spacing)
    local default_color = {
        255,
        255,
        255,
        255
    }
    local icon_size = {
        70,
        70
    }
    local slot_size = {
        70,
        70
    }
    slot_width_spacing = slot_width_spacing or 8
    slot_height_spacing = slot_height_spacing or 8
    local widget = {
        element = {}
    }
    local passes = {}
    local content = {
        rows = rows,
        columns = slots_per_row,
        slots = rows * slots_per_row
    }
    local style = {}

    local row_length = slots_per_row * slot_size[1] + slot_width_spacing * (slots_per_row - 1)
    local row_difference_to_background = size[1] - row_length
    local column_height = rows * slot_size[2] + slot_height_spacing * (rows - 1)
    local column_difference_to_background = size[2] - column_height
    local slot_start_offset = {
        row_difference_to_background / 2,
        size[2] - column_difference_to_background / 2 - slot_size[2]
    }
    local offset_layer = 3

    for i = 1, rows, 1 do
        for k = 1, slots_per_row, 1 do
            local name_suffix = "_" .. tostring(i) .. "_" .. tostring(k)
            local column_start_index = i - 1
            local row_start_index = k - 1
            local offset = {
                slot_start_offset[1] + row_start_index * (slot_size[1] + slot_width_spacing),
                slot_start_offset[2] - column_start_index * (slot_size[2] + slot_height_spacing),
                offset_layer
            }
            local item_name = "item" .. name_suffix
            local hotspot_name = "hotspot" .. name_suffix
            passes[#passes + 1] = {
                pass_type = "hotspot",
                content_id = hotspot_name,
                style_id = hotspot_name
            }
            style[hotspot_name] = {
                size = slot_size,
                offset = offset
            }
            content[hotspot_name] = {
                drag_texture_size = slot_size
            }
            local item_icon_name = "item_icon" .. name_suffix
            passes[#passes + 1] = {
                pass_type = "texture",
                content_id = hotspot_name,
                texture_id = item_icon_name,
                style_id = item_icon_name,
                content_check_function = function (content)
                    return content[item_icon_name]
                end
            }
            style[item_icon_name] = {
                size = icon_size,
                color = {
                    255,
                    255,
                    255,
                    255
                },
                offset = {
                    offset[1],
                    offset[2],
                    1
                }
            }
            local slot_background_frame_name = "item_frame" .. name_suffix
            passes[#passes + 1] = {
                pass_type = "texture",
                content_id = hotspot_name,
                texture_id = slot_background_frame_name,
                style_id = slot_background_frame_name,
                content_check_function = function (content)
                    return content[item_icon_name]
                end
            }
            style[slot_background_frame_name] = {
                size = icon_size,
                color = {
                    255,
                    255,
                    255,
                    255
                },
                offset = {
                    offset[1],
                    offset[2],
                    4
                }
            }
            content[hotspot_name][slot_background_frame_name] = "item_frame"
            local rarity_texture_name = "rarity_texture" .. name_suffix
            passes[#passes + 1] = {
                pass_type = "texture",
                texture_id = rarity_texture_name,
                style_id = rarity_texture_name,
                content_check_function = function (content)
                    return content[hotspot_name][item_icon_name] and content[item_name]
                end
            }
            style[rarity_texture_name] = {
                size = icon_size,
                color = {
                    255,
                    255,
                    255,
                    255
                },
                offset = {
                    offset[1],
                    offset[2],
                    0
                }
            }
            content[rarity_texture_name] = "icon_bg_default"
            local slot_name = "slot" .. name_suffix
            passes[#passes + 1] = {
                pass_type = "texture",
                content_id = hotspot_name,
                texture_id = slot_name,
                style_id = slot_name,
                content_check_function = function (content)
                    return not content[item_icon_name] and not content.hide_slot
                end
            }
            style[slot_name] = {
                size = slot_size,
                color = {
                    255,
                    255,
                    255,
                    255
                },
                offset = {
                    offset[1],
                    offset[2],
                    0
                }
            }
            content[hotspot_name][slot_name] = "menu_slot_frame_01"
            local slot_hover_name = "slot_hover" .. name_suffix
            passes[#passes + 1] = {
                pass_type = "texture",
                content_id = hotspot_name,
                texture_id = slot_hover_name,
                style_id = slot_hover_name,
                content_check_function = function (content)
                    return content.highlight or content.is_hover or content.is_selected
                end
            }
            style[slot_hover_name] = {
                size = {
                    118,
                    118
                },
                color = {
                    255,
                    255,
                    255,
                    255
                },
                offset = {
                    offset[1] - (118 - slot_size[1]) / 2,
                    offset[2] - (118 - slot_size[2]) / 2,
                    0
                }
            }
            content[hotspot_name][slot_hover_name] = "item_icon_hover"
            local slot_selected_name = "slot_selected" .. name_suffix
            passes[#passes + 1] = {
                pass_type = "texture",
                content_id = hotspot_name,
                texture_id = slot_selected_name,
                style_id = slot_selected_name,
                content_check_function = function (content)
                    return content.is_selected
                end
            }
            style[slot_selected_name] = {
                size = {
                    70,
                    70
                },
                color = {
                    255,
                    255,
                    255,
                    255
                },
                offset = {
                    offset[1] - (70 - slot_size[1]) / 2,
                    offset[2] - (70 - slot_size[2]) / 2,
                    6
                }
            }
            content[hotspot_name][slot_selected_name] = "item_icon_selection"
            local disabled_name = "disabled_rect" .. name_suffix
            passes[#passes + 1] = {
                pass_type = "rect",
                content_id = hotspot_name,
                style_id = disabled_name,
                content_check_function = function (content)
                    return content[item_icon_name] and (content.reserved or content.unwieldable)
                end
            }
            style[disabled_name] = {
                size = icon_size,
                color = {
                    210,
                    10,
                    10,
                    10
                },
                offset = {
                    offset[1],
                    offset[2],
                    3
                }
            }
            local new_frame_settings = UIFrameSettings.frame_outer_glow_01
            local new_frame_width = new_frame_settings.texture_sizes.corner[1]
            local new_icon_name = "new_icon" .. name_suffix
            passes[#passes + 1] = {
                pass_type = "texture_frame",
                texture_id = new_icon_name,
                style_id = new_icon_name,
                content_check_function = function (content)
                    local item = content["item" .. name_suffix]

                    return content[new_icon_name] and item and ItemHelper.is_new_backend_id(item.backend_id)
                end,
                content_change_function = function (content, style)
                    local item = content["item" .. name_suffix]
                    local backend_id = item and item.backend_id

                    if item and ItemHelper.is_new_backend_id(backend_id) then
                        local progress = 0.5 + math.sin(Application.time_since_launch() * 5) * 0.5
                        style.color[1] = 55 + progress * 200
                        local hotspot = content[hotspot_name]

                        if hotspot.on_hover_enter and ItemHelper.is_new_backend_id(backend_id) then
                            ItemHelper.unmark_backend_id_as_new(backend_id)
                        end
                    end
                end
            }
            style[new_icon_name] = {
                size = {
                    icon_size[1] + new_frame_width * 2,
                    icon_size[2] + new_frame_width * 2
                },
                color = default_color,
                texture_size = new_frame_settings.texture_size,
                texture_sizes = new_frame_settings.texture_sizes,
                offset = {
                    offset[1] - new_frame_width,
                    offset[2] - new_frame_width,
                    10
                }
            }
            content[new_icon_name] = new_frame_settings.texture
        end
    end

    widget.element.passes = passes
    widget.content = content
    widget.style = style
    widget.offset = {
        0,
        0,
        0
    }
    widget.scenegraph_id = scenegraph_id

    return widget
end

-- Borrowed from UIWidgets.create_icon_selector()
mod.create_icon_selector_with_default_color = function (scenegraph_id, icon_size, slot_icons, slot_spacing, use_frame, optional_frame_size, optional_allow_multi_hover, color)
    local default_color = color or {
        255,
        100,
        100,
        100
    }
    local amount = #slot_icons
    local widget = {
        element = {}
    }
    local passes = {}
    local content = {
        amount = amount
    }
    local style = {}
    local slot_width_spacing = slot_spacing or 0
    local offset_layer = 0
    local total_length = -slot_width_spacing
    local start_width_offset = 0

    for k = 1, amount, 1 do
        local name_suffix = "_" .. tostring(k)
        total_length = total_length + icon_size[1] + slot_width_spacing
        local offset = {
            start_width_offset,
            0,
            offset_layer
        }
        local hotspot_name = "hotspot" .. name_suffix
        passes[#passes + 1] = {
            pass_type = "hotspot",
            content_id = hotspot_name,
            style_id = hotspot_name
        }
        style[hotspot_name] = {
            size = icon_size,
            offset = offset
        }
        content[hotspot_name] = {
            allow_multi_hover = optional_allow_multi_hover
        }
        local hotspot_content = content[hotspot_name]
        local icon_texture = slot_icons[k]
        local icon_name = "icon" .. name_suffix
        passes[#passes + 1] = {
            pass_type = "texture",
            content_id = hotspot_name,
            texture_id = icon_name,
            style_id = icon_name
        }
        style[icon_name] = {
            size = icon_size,
            color = default_color,
            offset = {
                offset[1],
                offset[2],
                offset[3] + 2
            }
        }
        hotspot_content[icon_name] = icon_texture
        local selection_icon_name = "selection_icon" .. name_suffix
        passes[#passes + 1] = {
            pass_type = "texture",
            content_id = hotspot_name,
            texture_id = selection_icon_name,
            style_id = selection_icon_name,
            content_check_function = function (content)
                return content[selection_icon_name] and content.is_selected
            end
        }
        style[selection_icon_name] = {
            size = icon_size,
            color = default_color,
            offset = {
                offset[1],
                offset[2],
                offset[3] + 3
            },
            default_offset = {
                offset[1],
                offset[2],
                offset[3] + 4
            }
        }
        local disabled_name = "disabled" .. name_suffix
        passes[#passes + 1] = {
            pass_type = "texture",
            content_id = hotspot_name,
            texture_id = disabled_name,
            style_id = disabled_name,
            content_check_function = function (content)
                return content.disable_button and not content.locked
            end
        }
        style[disabled_name] = {
            size = icon_size,
            color = default_color,
            offset = {
                offset[1],
                offset[2],
                offset[3] + 4
            }
        }
        hotspot_content[disabled_name] = "kick_player_icon"
        local locked_name = "locked" .. name_suffix
        passes[#passes + 1] = {
            pass_type = "texture",
            content_id = hotspot_name,
            texture_id = locked_name,
            style_id = locked_name,
            content_check_function = function (content)
                return content.locked
            end
        }
        style[locked_name] = {
            size = {
                30,
                38
            },
            color = default_color,
            offset = {
                (offset[1] + icon_size[1] / 2) - 15,
                (offset[2] + icon_size[2] / 2) - 19,
                offset[3] + 5
            }
        }
        hotspot_content[locked_name] = "locked_icon_01"

        if use_frame then
            local frame_name = "frame" .. name_suffix
            passes[#passes + 1] = {
                pass_type = "texture",
                content_id = hotspot_name,
                texture_id = frame_name,
                style_id = frame_name
            }
            local frame_size = (optional_frame_size and table.clone(optional_frame_size)) or {
                86,
                108
            }
            style[frame_name] = {
                size = {
                    frame_size[1],
                    frame_size[2]
                },
                color = default_color,
                offset = {
                    (offset[1] + icon_size[1] / 2) - frame_size[1] / 2,
                    (offset[2] + icon_size[2] / 2) - frame_size[2] / 2,
                    offset[3] + 3
                }
            }
            hotspot_content[frame_name] = "portrait_frame_hero_selection"
        end

        start_width_offset = start_width_offset + icon_size[1] + slot_width_spacing
    end

    widget.element.passes = passes
    widget.content = content
    widget.style = style
    widget.offset = {
        -total_length / 2,
        0,
        0
    }
    widget.scenegraph_id = scenegraph_id

    return widget
end

local title_text_style = {
    use_shadow = true,
    upper_case = true,
    localize = false,
    font_size = 28,
    horizontal_alignment = "center",
    vertical_alignment = "center",
    dynamic_font_size = true,
    font_type = "hell_shark_header",
    text_color = Colors.get_color_table_with_alpha("font_title", 255),
    offset = { 0, 0, 2 }
}

local detail_title_text_style = {
    use_shadow = true,
    upper_case = true,
    localize = false,
    font_size = 48,
    horizontal_alignment = "center",
    vertical_alignment = "center",
    dynamic_font_size = true,
    font_type = "hell_shark_header",
    text_color = Colors.get_color_table_with_alpha("font_title", 255),
    offset = { 0, 0, 2 }
}

local header_title_text_style = {
    use_shadow = true,
    upper_case = false,
    localize = false,
    font_size = 48,
    vertical_alignment = "center",
    horizontal_alignment = "left",
    dynamic_font_size = true,
    font_type = "hell_shark_header",
    text_color = Colors.get_color_table_with_alpha("font_title", 255),
    offset = { 0, 0, 2 }
}

local base_info_text_style = {
    use_shadow = true,
    upper_case = false,
    localize = false,
    font_size = 24,
    vertical_alignment = "center",
    horizontal_alignment = "left",
    dynamic_font_size = true,
    font_type = "hell_shark",
    text_color = Colors.get_color_table_with_alpha("font_default", 255),
    offset = { 0, 0, 0}
}

local base_info_armor_damage_style = {
    use_shadow = true,
    upper_case = false,
    localize = false,
    font_size = 24,
    vertical_alignment = "center",
    horizontal_alignment = "center",
    dynamic_font_size = true,
    font_type = "hell_shark",
    text_color = Colors.get_color_table_with_alpha("font_default", 255),
    offset = { 0, 0, 0}
}

local base_info_value_style_center = {
    use_shadow = true,
    upper_case = false,
    localize = false,
    font_size = 24,
    dynamic_font_size = false,
    word_wrap = true,
    vertical_alignment = "center",
    horizontal_alignment = "center",
    font_type  = "hell_shark",
    text_color = Colors.get_color_table_with_alpha("font_default", 255),
    offset = { 0, 0, 0 }
}

local base_info_value_style_right_align = {
    use_shadow = true,
    upper_case = false,
    localize = false,
    font_size = 24,
    vertical_alignment = "center",
    horizontal_alignment = "right",
    dynamic_font_size = false,
    font_type  = "hell_shark",
    text_color = Colors.get_color_table_with_alpha("font_default", 255),
    offset = { 0, 0, 0 }
}

local base_info_value_style_left_align = {
    use_shadow = true,
    upper_case = false,
    localize = false,
    font_size = 24,
    vertical_alignment = "center",
    horizontal_alignment = "left",
    dynamic_font_size = false,
    font_type  = "hell_shark",
    text_color = Colors.get_color_table_with_alpha("font_default", 255),
    offset = { 0, 0, 0 }
}

local tooltip_text_style = {
    font_size = 20,
    localize = false,
    horizontal_alignment = "left",
    vertical_alignment = "top",
    font_type = "hell_shark",
    max_width = 500,
    text_color = Colors.get_color_table_with_alpha("white", 255),
    line_colors = {},
    offset = { 0, 0, 3 }

}

local viewport_widget = {
    scenegraph_id = "weapon_preview_viewport",
    element = UIElements.Viewport,
    style = {
        viewport = {
            viewport_name = "weapon_preview_viewport",
            level_name = "levels/end_screen/world",
            --level_name = "levels/ui_keep_menu/world",
            shading_environment = "environment/ui_end_screen",
            --shading_environment = "environment/blank_offscreen_chest_item",
            enable_sub_gui = false,
            fov = 65,
            world_name = "weapon_preview",
            world_flags = {
                Application.DISABLE_SOUND,
                Application.DISABLE_ESRAM
            },
            camera_position = { 0, 0, 0 },
            camera_lookat = { 0, 0, 1 },
            layer = 990
        }
    },
    content = {
        button_hotspot = {
            allow_multi_hover = true
        }
    }
}

local animation_definitions = {
    on_enter = {
        {
            name = "fade_in",
            start_progress = 0,
            end_progress = 0.3,
            init = function (ui_scenegraph, scenegraph_definition, widgets, params)
                params.render_settings.alpha_multiplier = 0
            end,
            update = function (ui_scenegraph, scenegraph_definition, widgets, progress, params)
                local anim_progress = math.easeOutCubic(progress)
                params.render_settings.alpha_multiplier = anim_progress
            end,
            on_complete = function (ui_scenegraph, scenegraph_definition, widgets, params)
                return
            end
        }
    },
    on_exit = {
        {
            name = "fade_out",
            start_progress = 0,
            end_progress = 0.3,
            init = function (ui_scenegraph, scenegraph_definition, widgets, params)
                params.render_settings.alpha_multiplier = 1
            end,
            update = function (ui_scenegraph, scenegraph_definition, widgets, progress, params)
                local anim_progress = math.easeOutCubic(progress)
                params.render_settings.alpha_multiplier = 1 - anim_progress
            end,
            on_complete = function (ui_scenegraph, scenegraph_definition, widgets, params)
                return
            end
        }
    }
}

local hero_icons = {
    "hero_icon_es",
    "hero_icon_dr",
    "hero_icon_ww",
    "hero_icon_wh",
    "hero_icon_bw"
}

local widgets = {
    window = UIWidgets.create_frame("window", scenegraph_definition.window.size, "menu_frame_11"),
    window_bg = UIWidgets.create_tiled_texture("window_bg", "talent_tree_bg_01", { 1065, 820 }, nil, false, { 255, 100, 100, 100 }),
    exit_button = UIWidgets.create_default_button("exit_button", scenegraph_definition.exit_button.size, nil, nil, Localize("menu_close"), 24, nil, "button_detail_04", 34),
    title = UIWidgets.create_simple_texture("frame_title_bg", "title"),
    title_bg = UIWidgets.create_background("title_bg", scenegraph_definition.title_bg.size, "menu_frame_bg_02"),
    title_text = UIWidgets.create_simple_text(mod:localize("armory_title"), "title_text", nil, nil, title_text_style),

    hero_tray = UIWidgets.create_frame("hero_tray", scenegraph_definition.hero_tray.size, "menu_frame_09", 20),
    hero_tray_hover = UIWidgets.create_frame("hero_tray", scenegraph_definition.hero_tray.size, "menu_frame_12", 22),
    hero_tray_hotspot = UIWidgets.create_simple_hotspot("hero_tray"),
    hero_tray_bg = UIWidgets.create_tiled_texture("hero_tray_bg", "crafting_bg_top", { 520, 221 }, nil, nil, { 255, 100, 100, 100}),
    hero_buttons = mod.create_icon_selector_with_default_color("hero_tray_icons", { 81, 81 }, hero_icons, 20),

    weapon_tray = UIWidgets.create_frame("weapon_tray", scenegraph_definition.weapon_tray.size, "menu_frame_09", 20),
    weapon_tray_hover = UIWidgets.create_frame("weapon_tray", scenegraph_definition.weapon_tray.size, "menu_frame_12", 22),
    weapon_tray_hotspot = UIWidgets.create_simple_hotspot("weapon_tray"),
    weapon_tray_bg = UIWidgets.create_tiled_texture("weapon_tray_bg", "background_leather_02", { 520, 820 }, nil, nil, { 255, 100, 100, 100 }),
    item_tabs = UIWidgets.create_frame("item_tabs", scenegraph_definition.item_tabs.size, "menu_frame_09", 15),
    item_grid = mod.create_grid("item_grid", scenegraph_definition.item_grid.size, 2, 7, 10, 10),

    weapon_preview_tray = UIWidgets.create_frame("weapon_preview_tray", scenegraph_definition.weapon_preview_tray.size, "menu_frame_09"),
    weapon_preview_tray_hover = UIWidgets.create_frame("weapon_preview_tray", scenegraph_definition.weapon_preview_tray.size, "menu_frame_12"),
    weapon_preview_tray_hotspot = UIWidgets.create_simple_hotspot("weapon_preview_tray"),
    weapon_preview_button_tray = UIWidgets.create_frame("weapon_preview_button_tray", scenegraph_definition.weapon_preview_button_tray.size, "menu_frame_09", 18),
    weapon_preview_button_tray_hover = UIWidgets.create_frame("weapon_preview_button_tray", scenegraph_definition.weapon_preview_button_tray.size, "menu_frame_12", 25),
    weapon_preview_button_tray_hotspot = UIWidgets.create_simple_hotspot("weapon_preview_button_tray"),
    weapon_preview_button_tray_bg = UIWidgets.create_tiled_texture("weapon_preview_button_tray", "menu_frame_bg_01", { 960, 1080 }, nil, nil, { 255, 100, 100, 100 }),

    reset_preview_button = UIWidgets.create_default_button("reset_preview_button", scenegraph_definition.reset_preview_button.size, nil, nil, "", 24, nil),
    prev_illusion_button = UIWidgets.create_default_button("prev_illusion_button", scenegraph_definition.prev_illusion_button.size, nil, nil, "Prev", 24, nil),
    next_illusion_button = UIWidgets.create_default_button("next_illusion_button", scenegraph_definition.next_illusion_button.size, nil, nil, "Next", 24, nil),

    right_window_tray = UIWidgets.create_frame("right_window_tray", scenegraph_definition.right_window_tray.size, "menu_frame_09", 20),
    right_window_tray_hover = UIWidgets.create_frame("right_window_tray", scenegraph_definition.right_window_tray.size, "menu_frame_12", 22),
    right_window_tray_hotspot = UIWidgets.create_simple_hotspot("right_window_tray"),
    right_window_tray_bg = UIWidgets.create_tiled_texture("right_window_tray", "menu_frame_bg_02", { 960, 1080 }, nil, nil, { 255, 100, 100, 100 }),

    header_title_text = UIWidgets.create_simple_text("", "header_title_text", nil, nil, header_title_text_style),
    header_title_divider = UIWidgets.create_simple_texture("divider_01_bottom", "header_title_divider"),
    header_table_divider = UIWidgets.create_simple_texture("divider_01_top", "header_table_divider"),

    header_attack_speed = UIWidgets.create_frame("header_attack_speed", scenegraph_definition.header_attack_speed.size, "menu_frame_09", 0),
    header_attack_speed_hover = UIWidgets.create_frame("header_attack_speed", scenegraph_definition.header_attack_speed.size, "menu_frame_12", 25),
    header_attack_speed_column_hover = UIWidgets.create_frame("header_attack_speed_column", scenegraph_definition.header_attack_speed_column.size, "menu_frame_12", 24),
    header_attack_speed_column_bg = UIWidgets.create_tiled_texture("header_attack_speed_column", "menu_frame_bg_02", { 960, 1080 }, nil, nil, { 0, 255, 255, 255 }),
    header_attack_speed_bg = UIWidgets.create_tiled_texture("header_attack_speed", "menu_frame_bg_02", { 960, 1080 }, nil, nil, { 255, 100, 100, 100 }),
    header_attack_speed_hotspot = UIWidgets.create_simple_hotspot("header_attack_speed"),
    header_attack_speed_tooltip = UIWidgets.create_simple_tooltip("Attack Speed", "header_attack_speed", nil, tooltip_text_style),
    header_attack_speed_icon = UIWidgets.create_simple_texture("sword_array", "header_attack_speed_icon"),

    header_cleave = UIWidgets.create_frame("header_cleave", scenegraph_definition.header_cleave.size, "menu_frame_09", 1),
    header_cleave_hover = UIWidgets.create_frame("header_cleave", scenegraph_definition.header_cleave.size, "menu_frame_12", 25),
    header_cleave_column_hover = UIWidgets.create_frame("header_cleave_column", scenegraph_definition.header_cleave_column.size, "menu_frame_12", 24),
    header_cleave_column_bg = UIWidgets.create_tiled_texture("header_cleave_column", "menu_frame_bg_02", { 960, 1080 }, nil, nil, { 0, 255, 255, 255 }),
    header_cleave_bg = UIWidgets.create_tiled_texture("header_cleave", "menu_frame_bg_02", { 960, 1080 }, nil, nil, { 255, 100, 100, 100 }),
    header_cleave_hotspot = UIWidgets.create_simple_hotspot("header_cleave"),
    header_cleave_tooltip = UIWidgets.create_simple_tooltip("Cleave Limit (Damage / Stagger)", "header_cleave", nil, tooltip_text_style),
    header_cleave_icon = UIWidgets.create_simple_texture("split_body", "header_cleave_icon"),
    header_cleave_damage_abbr = UIWidgets.create_simple_text("D", "header_cleave_damage_abbr", nil, nil, base_info_value_style_center),
    header_cleave_stagger_abbr = UIWidgets.create_simple_text("S", "header_cleave_stagger_abbr", nil, nil, base_info_value_style_center),

    header_armor_damage = UIWidgets.create_frame("header_armor_damage", scenegraph_definition.header_armor_damage.size, "menu_frame_09", 1),
    header_armor_damage_hover = UIWidgets.create_frame("header_armor_damage", scenegraph_definition.header_armor_damage.size, "menu_frame_12", 25),
    header_armor_damage_column_hover = UIWidgets.create_frame("header_armor_damage_column", scenegraph_definition.header_armor_damage_column.size, "menu_frame_12", 24),
    header_armor_damage_column_bg = UIWidgets.create_tiled_texture("header_armor_damage_column", "menu_frame_bg_02", { 960, 1080 }, nil, nil, { 0, 255, 255, 255 }),
    header_armor_damage_bg = UIWidgets.create_tiled_texture("header_armor_damage", "menu_frame_bg_02", { 960, 1080 }, nil, nil, { 255, 100, 100, 100 }),
    header_armor_damage_hotspot = UIWidgets.create_simple_hotspot("header_armor_damage"),
    header_armor_damage_tooltip = UIWidgets.create_simple_tooltip("Armor Damage", "header_armor_damage", nil, tooltip_text_style),
    header_armor_damage_icon = UIWidgets.create_simple_texture("mutator_icon_elite_run", "header_armor_damage_icon"),

    header_base_damage = UIWidgets.create_frame("header_base_damage", scenegraph_definition.header_base_damage.size, "menu_frame_09", 1),
    header_base_damage_hover = UIWidgets.create_frame("header_base_damage", scenegraph_definition.header_base_damage.size, "menu_frame_12", 25),
    header_base_damage_column_hover = UIWidgets.create_frame("header_base_damage_column", scenegraph_definition.header_base_damage_column.size, "menu_frame_12", 24),
    header_base_damage_column_bg = UIWidgets.create_tiled_texture("header_base_damage_column", "menu_frame_bg_02", { 960, 1080 }, nil, nil, { 0, 255, 255, 255 }),
    header_base_damage_bg = UIWidgets.create_tiled_texture("header_base_damage", "menu_frame_bg_02", { 960, 1080 }, nil, nil, { 255, 100, 100, 100 }),
    header_base_damage_hotspot = UIWidgets.create_simple_hotspot("header_base_damage"),
    header_base_damage_tooltip = UIWidgets.create_simple_tooltip("Base Damage", "header_base_damage", nil, tooltip_text_style),
    header_base_damage_icon = UIWidgets.create_simple_texture("mutator_icon_whiterun", "header_base_damage_icon"),

    header_special_property = UIWidgets.create_frame("header_special_property", scenegraph_definition.header_special_property.size, "menu_frame_09", 1),
    header_special_property_hover = UIWidgets.create_frame("header_special_property", scenegraph_definition.header_special_property.size, "menu_frame_12", 25),
    header_special_property_column_hover = UIWidgets.create_frame("header_special_property_column", scenegraph_definition.header_special_property_column.size, "menu_frame_12", 24),
    header_special_property_column_bg = UIWidgets.create_tiled_texture("header_special_property_column", "menu_frame_bg_02", { 960, 1080 }, nil, nil, { 0, 255, 255, 255 }),
    header_special_property_bg = UIWidgets.create_tiled_texture("header_special_property", "menu_frame_bg_02", { 960, 1080 }, nil, nil, { 255, 100, 100, 100 }),
    header_special_property_hotspot = UIWidgets.create_simple_hotspot("header_special_property"),
    header_special_property_tooltip = UIWidgets.create_simple_tooltip("Special Properties", "header_special_property", nil, tooltip_text_style),
    header_special_property_icon = UIWidgets.create_simple_texture("half_body_crawling", "header_special_property_icon"),

    base_info_melee_stamina = UIWidgets.create_simple_tooltip("Stamina Shields", "base_info_melee_stamina", nil, tooltip_text_style),
    base_info_melee_stamina_icon = UIWidgets.create_simple_texture("fatigue_icon_01", "base_info_melee_stamina_icon"),
    base_info_melee_stamina_value = UIWidgets.create_simple_text("", "base_info_melee_stamina_value", nil, nil, base_info_value_style_left_align),

    action_info_ranged_attack1 = UIWidgets.create_frame("action_info_ranged_attack1", scenegraph_definition.action_info_ranged_attack1, "menu_frame_09", 1),
    action_info_ranged_attack1_hover = UIWidgets.create_frame("action_info_ranged_attack1", scenegraph_definition.action_info_ranged_attack1, "menu_frame_12", 25),
    action_info_ranged_attack1_bg = UIWidgets.create_tiled_texture("action_info_ranged_attack1", "menu_frame_bg_02", { 960, 1080 }, nil, nil, { 255, 100, 100, 100 }),
    action_info_ranged_attack1_hotspot = UIWidgets.create_simple_hotspot("action_info_ranged_attack1"),
    action_info_ranged_attack1_text = UIWidgets.create_simple_text("", "action_info_ranged_attack1_text", nil, nil, base_info_text_style),
    action_info_ranged_attack1_attack_speed = UIWidgets.create_simple_text("", "action_info_ranged_attack1_attack_speed", nil, nil, base_info_value_style_center),
    action_info_ranged_attack1_damage_limit = UIWidgets.create_simple_text("", "action_info_ranged_attack1_damage_limit", nil, nil, base_info_value_style_left_align),
    action_info_ranged_attack1_stagger_limit = UIWidgets.create_simple_text("", "action_info_ranged_attack1_stagger_limit", nil, nil, base_info_value_style_right_align),
    action_info_ranged_attack1_special = UIWidgets.create_simple_text("", "action_info_ranged_attack1_special", nil, nil, base_info_text_style),
    action_info_ranged_attack1_armor_damage = UIWidgets.create_simple_text("", "action_info_ranged_attack1_armor_damage", nil, nil, base_info_armor_damage_style),
    action_info_ranged_attack1_base_damage = UIWidgets.create_simple_text("", "action_info_ranged_attack1_base_damage", nil, nil, base_info_armor_damage_style),

    action_info_ranged_attack2 = UIWidgets.create_frame("action_info_ranged_attack2", scenegraph_definition.action_info_ranged_attack2, "menu_frame_09", 1),
    action_info_ranged_attack2_hover = UIWidgets.create_frame("action_info_ranged_attack2", scenegraph_definition.action_info_ranged_attack2, "menu_frame_12", 25),
    action_info_ranged_attack2_bg = UIWidgets.create_tiled_texture("action_info_ranged_attack2", "menu_frame_bg_02", { 960, 1080 }, nil, nil, { 255, 100, 100, 100 }),
    action_info_ranged_attack2_hotspot = UIWidgets.create_simple_hotspot("action_info_ranged_attack2"),
    action_info_ranged_attack2_text = UIWidgets.create_simple_text("", "action_info_ranged_attack2_text", nil, nil, base_info_text_style),
    action_info_ranged_attack2_attack_speed = UIWidgets.create_simple_text("", "action_info_ranged_attack2_attack_speed", nil, nil, base_info_value_style_center),
    action_info_ranged_attack2_damage_limit = UIWidgets.create_simple_text("", "action_info_ranged_attack2_damage_limit", nil, nil, base_info_value_style_left_align),
    action_info_ranged_attack2_stagger_limit = UIWidgets.create_simple_text("", "action_info_ranged_attack2_stagger_limit", nil, nil, base_info_value_style_right_align),
    action_info_ranged_attack2_armor_damage = UIWidgets.create_simple_texture("tabs_icon_close", "action_info_ranged_attack2_armor_damage"),
    action_info_ranged_attack2_base_damage = UIWidgets.create_simple_texture("tabs_icon_close", "action_info_ranged_attack2_base_damage"),
    action_info_ranged_attack2_special = UIWidgets.create_simple_text("", "action_info_ranged_attack2_special", nil, nil, base_info_text_style),
    action_info_ranged_attack2_armor_damage = UIWidgets.create_simple_text("", "action_info_ranged_attack2_armor_damage", nil, nil, base_info_armor_damage_style),
    action_info_ranged_attack2_base_damage = UIWidgets.create_simple_text("", "action_info_ranged_attack2_base_damage", nil, nil, base_info_armor_damage_style),

    action_info_ranged_attack3 = UIWidgets.create_frame("action_info_ranged_attack3", scenegraph_definition.action_info_ranged_attack3, "menu_frame_09", 1),
    action_info_ranged_attack3_hover = UIWidgets.create_frame("action_info_ranged_attack3", scenegraph_definition.action_info_ranged_attack3, "menu_frame_12", 25),
    action_info_ranged_attack3_bg = UIWidgets.create_tiled_texture("action_info_ranged_attack3", "menu_frame_bg_02", { 960, 1080 }, nil, nil, { 255, 100, 100, 100 }),
    action_info_ranged_attack3_hotspot = UIWidgets.create_simple_hotspot("action_info_ranged_attack3"),
    action_info_ranged_attack3_text = UIWidgets.create_simple_text("", "action_info_ranged_attack3_text", nil, nil, base_info_text_style),
    action_info_ranged_attack3_attack_speed = UIWidgets.create_simple_text("", "action_info_ranged_attack3_attack_speed", nil, nil, base_info_value_style_center),
    action_info_ranged_attack3_damage_limit = UIWidgets.create_simple_text("", "action_info_ranged_attack3_damage_limit", nil, nil, base_info_value_style_left_align),
    action_info_ranged_attack3_stagger_limit = UIWidgets.create_simple_text("", "action_info_ranged_attack3_stagger_limit", nil, nil, base_info_value_style_right_align),
    action_info_ranged_attack3_armor_damage = UIWidgets.create_simple_texture("tabs_icon_close", "action_info_ranged_attack3_armor_damage"),
    action_info_ranged_attack3_base_damage = UIWidgets.create_simple_texture("tabs_icon_close", "action_info_ranged_attack3_base_damage"),
    action_info_ranged_attack3_special = UIWidgets.create_simple_text("", "action_info_ranged_attack3_special", nil, nil, base_info_text_style),
    action_info_ranged_attack3_armor_damage = UIWidgets.create_simple_text("", "action_info_ranged_attack3_armor_damage", nil, nil, base_info_armor_damage_style),
    action_info_ranged_attack3_base_damage = UIWidgets.create_simple_text("", "action_info_ranged_attack3_base_damage", nil, nil, base_info_armor_damage_style),

    action_info_ranged_attack4 = UIWidgets.create_frame("action_info_ranged_attack4", scenegraph_definition.action_info_ranged_attack4, "menu_frame_09", 1),
    action_info_ranged_attack4_hover = UIWidgets.create_frame("action_info_ranged_attack4", scenegraph_definition.action_info_ranged_attack4, "menu_frame_12", 25),
    action_info_ranged_attack4_bg = UIWidgets.create_tiled_texture("action_info_ranged_attack4", "menu_frame_bg_02", { 960, 1080 }, nil, nil, { 255, 100, 100, 100 }),
    action_info_ranged_attack4_hotspot = UIWidgets.create_simple_hotspot("action_info_ranged_attack4"),
    action_info_ranged_attack4_text = UIWidgets.create_simple_text("", "action_info_ranged_attack4_text", nil, nil, base_info_text_style),
    action_info_ranged_attack4_attack_speed = UIWidgets.create_simple_text("", "action_info_ranged_attack4_attack_speed", nil, nil, base_info_value_style_center),
    action_info_ranged_attack4_damage_limit = UIWidgets.create_simple_text("", "action_info_ranged_attack4_damage_limit", nil, nil, base_info_value_style_left_align),
    action_info_ranged_attack4_stagger_limit = UIWidgets.create_simple_text("", "action_info_ranged_attack4_stagger_limit", nil, nil, base_info_value_style_right_align),
    action_info_ranged_attack4_armor_damage = UIWidgets.create_simple_texture("tabs_icon_close", "action_info_ranged_attack4_armor_damage"),
    action_info_ranged_attack4_base_damage = UIWidgets.create_simple_texture("tabs_icon_close", "action_info_ranged_attack4_base_damage"),
    action_info_ranged_attack4_special = UIWidgets.create_simple_text("", "action_info_ranged_attack4_special", nil, nil, base_info_text_style),
    action_info_ranged_attack4_armor_damage = UIWidgets.create_simple_text("", "action_info_ranged_attack4_armor_damage", nil, nil, base_info_armor_damage_style),
    action_info_ranged_attack4_base_damage = UIWidgets.create_simple_text("", "action_info_ranged_attack4_base_damage", nil, nil, base_info_armor_damage_style),

    action_info_ranged_attack5 = UIWidgets.create_frame("action_info_ranged_attack5", scenegraph_definition.action_info_ranged_attack5, "menu_frame_09", 1),
    action_info_ranged_attack5_hover = UIWidgets.create_frame("action_info_ranged_attack5", scenegraph_definition.action_info_ranged_attack5, "menu_frame_12", 25),
    action_info_ranged_attack5_bg = UIWidgets.create_tiled_texture("action_info_ranged_attack5", "menu_frame_bg_02", { 960, 1080 }, nil, nil, { 255, 100, 100, 100 }),
    action_info_ranged_attack5_hotspot = UIWidgets.create_simple_hotspot("action_info_ranged_attack5"),
    action_info_ranged_attack5_text = UIWidgets.create_simple_text("", "action_info_ranged_attack5_text", nil, nil, base_info_text_style),
    action_info_ranged_attack5_attack_speed = UIWidgets.create_simple_text("", "action_info_ranged_attack5_attack_speed", nil, nil, base_info_value_style_center),
    action_info_ranged_attack5_damage_limit = UIWidgets.create_simple_text("", "action_info_ranged_attack5_damage_limit", nil, nil, base_info_value_style_left_align),
    action_info_ranged_attack5_stagger_limit = UIWidgets.create_simple_text("", "action_info_ranged_attack5_stagger_limit", nil, nil, base_info_value_style_right_align),
    action_info_ranged_attack5_special = UIWidgets.create_simple_text("", "action_info_ranged_attack5_special", nil, nil, base_info_text_style),
    action_info_ranged_attack5_armor_damage = UIWidgets.create_simple_text("", "action_info_ranged_attack5_armor_damage", nil, nil, base_info_armor_damage_style),
    action_info_ranged_attack5_base_damage = UIWidgets.create_simple_text("", "action_info_ranged_attack5_base_damage", nil, nil, base_info_armor_damage_style),

    action_info_ranged_attack6 = UIWidgets.create_frame("action_info_ranged_attack6", scenegraph_definition.action_info_ranged_attack6, "menu_frame_09", 1),
    action_info_ranged_attack6_hover = UIWidgets.create_frame("action_info_ranged_attack6", scenegraph_definition.action_info_ranged_attack6, "menu_frame_12", 25),
    action_info_ranged_attack6_bg = UIWidgets.create_tiled_texture("action_info_ranged_attack6", "menu_frame_bg_02", { 960, 1080 }, nil, nil, { 255, 100, 100, 100 }),
    action_info_ranged_attack6_hotspot = UIWidgets.create_simple_hotspot("action_info_ranged_attack6"),
    action_info_ranged_attack6_text = UIWidgets.create_simple_text("", "action_info_ranged_attack6_text", nil, nil, base_info_text_style),
    action_info_ranged_attack6_attack_speed = UIWidgets.create_simple_text("", "action_info_ranged_attack6_attack_speed", nil, nil, base_info_value_style_center),
    action_info_ranged_attack6_damage_limit = UIWidgets.create_simple_text("", "action_info_ranged_attack6_damage_limit", nil, nil, base_info_value_style_left_align),
    action_info_ranged_attack6_stagger_limit = UIWidgets.create_simple_text("", "action_info_ranged_attack6_stagger_limit", nil, nil, base_info_value_style_right_align),
    action_info_ranged_attack6_special = UIWidgets.create_simple_text("", "action_info_ranged_attack6_special", nil, nil, base_info_text_style),
    action_info_ranged_attack6_armor_damage = UIWidgets.create_simple_text("", "action_info_ranged_attack6_armor_damage", nil, nil, base_info_armor_damage_style),
    action_info_ranged_attack6_base_damage = UIWidgets.create_simple_text("", "action_info_ranged_attack6_base_damage", nil, nil, base_info_armor_damage_style),

    action_info_ranged_attack7 = UIWidgets.create_frame("action_info_ranged_attack7", scenegraph_definition.action_info_ranged_attack7, "menu_frame_09", 1),
    action_info_ranged_attack7_hover = UIWidgets.create_frame("action_info_ranged_attack7", scenegraph_definition.action_info_ranged_attack7, "menu_frame_12", 25),
    action_info_ranged_attack7_bg = UIWidgets.create_tiled_texture("action_info_ranged_attack7", "menu_frame_bg_02", { 960, 1080 }, nil, nil, { 255, 100, 100, 100 }),
    action_info_ranged_attack7_hotspot = UIWidgets.create_simple_hotspot("action_info_ranged_attack7"),
    action_info_ranged_attack7_text = UIWidgets.create_simple_text("", "action_info_ranged_attack7_text", nil, nil, base_info_text_style),
    action_info_ranged_attack7_attack_speed = UIWidgets.create_simple_text("", "action_info_ranged_attack7_attack_speed", nil, nil, base_info_value_style_center),
    action_info_ranged_attack7_damage_limit = UIWidgets.create_simple_text("", "action_info_ranged_attack7_damage_limit", nil, nil, base_info_value_style_left_align),
    action_info_ranged_attack7_stagger_limit = UIWidgets.create_simple_text("", "action_info_ranged_attack7_stagger_limit", nil, nil, base_info_value_style_right_align),
    action_info_ranged_attack7_special = UIWidgets.create_simple_text("", "action_info_ranged_attack7_special", nil, nil, base_info_text_style),
    action_info_ranged_attack7_armor_damage = UIWidgets.create_simple_text("", "action_info_ranged_attack7_armor_damage", nil, nil, base_info_armor_damage_style),
    action_info_ranged_attack7_base_damage = UIWidgets.create_simple_text("", "action_info_ranged_attack7_base_damage", nil, nil, base_info_armor_damage_style),

    action_info_light_attack1 = UIWidgets.create_frame("action_info_light_attack1", scenegraph_definition.action_info_light_attack1, "menu_frame_09", 1),
    action_info_light_attack1_hover = UIWidgets.create_frame("action_info_light_attack1", scenegraph_definition.action_info_light_attack1, "menu_frame_12", 25),
    action_info_light_attack1_bg = UIWidgets.create_tiled_texture("action_info_light_attack1", "menu_frame_bg_02", { 960, 1080 }, nil, nil, { 255, 100, 100, 100 }),
    action_info_light_attack1_hotspot = UIWidgets.create_simple_hotspot("action_info_light_attack1"),
    action_info_light_attack1_text = UIWidgets.create_simple_text("", "action_info_light_attack1_text", nil, nil, base_info_text_style),
    action_info_light_attack1_attack_speed = UIWidgets.create_simple_text("", "action_info_light_attack1_attack_speed", nil, nil, base_info_value_style_center),
    action_info_light_attack1_damage_limit = UIWidgets.create_simple_text("", "action_info_light_attack1_damage_limit", nil, nil, base_info_value_style_left_align),
    action_info_light_attack1_stagger_limit = UIWidgets.create_simple_text("", "action_info_light_attack1_stagger_limit", nil, nil, base_info_value_style_right_align),
    action_info_light_attack1_armor_damage = UIWidgets.create_simple_texture("tabs_icon_close", "action_info_light_attack1_armor_damage"),
    action_info_light_attack1_base_damage = UIWidgets.create_simple_texture("tabs_icon_close", "action_info_light_attack1_base_damage"),
    action_info_light_attack1_special = UIWidgets.create_simple_text("", "action_info_light_attack1_special", nil, nil, base_info_text_style),
    action_info_light_attack1_armor_damage = UIWidgets.create_simple_text("", "action_info_light_attack1_armor_damage", nil, nil, base_info_armor_damage_style),
    action_info_light_attack1_base_damage = UIWidgets.create_simple_text("", "action_info_light_attack1_base_damage", nil, nil, base_info_armor_damage_style),

    action_info_light_attack2 = UIWidgets.create_frame("action_info_light_attack2", scenegraph_definition.action_info_light_attack2, "menu_frame_09", 1),
    action_info_light_attack2_hover = UIWidgets.create_frame("action_info_light_attack2", scenegraph_definition.action_info_light_attack2, "menu_frame_12", 25),
    action_info_light_attack2_bg = UIWidgets.create_tiled_texture("action_info_light_attack2", "menu_frame_bg_02", { 960, 1080 }, nil, nil, { 255, 100, 100, 100 }),
    action_info_light_attack2_hotspot = UIWidgets.create_simple_hotspot("action_info_light_attack2"),
    action_info_light_attack2_text = UIWidgets.create_simple_text("", "action_info_light_attack2_text", nil, nil, base_info_text_style),
    action_info_light_attack2_attack_speed = UIWidgets.create_simple_text("", "action_info_light_attack2_attack_speed", nil, nil, base_info_value_style_center),
    action_info_light_attack2_damage_limit = UIWidgets.create_simple_text("", "action_info_light_attack2_damage_limit", nil, nil, base_info_value_style_left_align),
    action_info_light_attack2_stagger_limit = UIWidgets.create_simple_text("", "action_info_light_attack2_stagger_limit", nil, nil, base_info_value_style_right_align),
    action_info_light_attack2_armor_damage = UIWidgets.create_simple_texture("tabs_icon_close", "action_info_light_attack2_armor_damage"),
    action_info_light_attack2_base_damage = UIWidgets.create_simple_texture("tabs_icon_close", "action_info_light_attack2_base_damage"),
    action_info_light_attack2_special = UIWidgets.create_simple_text("", "action_info_light_attack2_special", nil, nil, base_info_text_style),
    action_info_light_attack2_armor_damage = UIWidgets.create_simple_text("", "action_info_light_attack2_armor_damage", nil, nil, base_info_armor_damage_style),
    action_info_light_attack2_base_damage = UIWidgets.create_simple_text("", "action_info_light_attack2_base_damage", nil, nil, base_info_armor_damage_style),

    action_info_light_attack3 = UIWidgets.create_frame("action_info_light_attack3", scenegraph_definition.action_info_light_attack3, "menu_frame_09", 1),
    action_info_light_attack3_hover = UIWidgets.create_frame("action_info_light_attack3", scenegraph_definition.action_info_light_attack3, "menu_frame_12", 25),
    action_info_light_attack3_bg = UIWidgets.create_tiled_texture("action_info_light_attack3", "menu_frame_bg_02", { 960, 1080 }, nil, nil, { 255, 100, 100, 100 }),
    action_info_light_attack3_hotspot = UIWidgets.create_simple_hotspot("action_info_light_attack3"),
    action_info_light_attack3_text = UIWidgets.create_simple_text("", "action_info_light_attack3_text", nil, nil, base_info_text_style),
    action_info_light_attack3_attack_speed = UIWidgets.create_simple_text("", "action_info_light_attack3_attack_speed", nil, nil, base_info_value_style_center),
    action_info_light_attack3_damage_limit = UIWidgets.create_simple_text("", "action_info_light_attack3_damage_limit", nil, nil, base_info_value_style_left_align),
    action_info_light_attack3_stagger_limit = UIWidgets.create_simple_text("", "action_info_light_attack3_stagger_limit", nil, nil, base_info_value_style_right_align),
    action_info_light_attack3_armor_damage = UIWidgets.create_simple_texture("tabs_icon_close", "action_info_light_attack3_armor_damage"),
    action_info_light_attack3_base_damage = UIWidgets.create_simple_texture("tabs_icon_close", "action_info_light_attack3_base_damage"),
    action_info_light_attack3_special = UIWidgets.create_simple_text("", "action_info_light_attack3_special", nil, nil, base_info_text_style),
    action_info_light_attack3_armor_damage = UIWidgets.create_simple_text("", "action_info_light_attack3_armor_damage", nil, nil, base_info_armor_damage_style),
    action_info_light_attack3_base_damage = UIWidgets.create_simple_text("", "action_info_light_attack3_base_damage", nil, nil, base_info_armor_damage_style),

    action_info_light_attack4 = UIWidgets.create_frame("action_info_light_attack4", scenegraph_definition.action_info_light_attack4, "menu_frame_09", 1),
    action_info_light_attack4_hover = UIWidgets.create_frame("action_info_light_attack4", scenegraph_definition.action_info_light_attack4, "menu_frame_12", 25),
    action_info_light_attack4_bg = UIWidgets.create_tiled_texture("action_info_light_attack4", "menu_frame_bg_02", { 960, 1080 }, nil, nil, { 255, 100, 100, 100 }),
    action_info_light_attack4_hotspot = UIWidgets.create_simple_hotspot("action_info_light_attack4"),
    action_info_light_attack4_text = UIWidgets.create_simple_text("", "action_info_light_attack4_text", nil, nil, base_info_text_style),
    action_info_light_attack4_attack_speed = UIWidgets.create_simple_text("", "action_info_light_attack4_attack_speed", nil, nil, base_info_value_style_center),
    action_info_light_attack4_damage_limit = UIWidgets.create_simple_text("", "action_info_light_attack4_damage_limit", nil, nil, base_info_value_style_left_align),
    action_info_light_attack4_stagger_limit = UIWidgets.create_simple_text("", "action_info_light_attack4_stagger_limit", nil, nil, base_info_value_style_right_align),
    action_info_light_attack4_armor_damage = UIWidgets.create_simple_texture("tabs_icon_close", "action_info_light_attack4_armor_damage"),
    action_info_light_attack4_base_damage = UIWidgets.create_simple_texture("tabs_icon_close", "action_info_light_attack4_base_damage"),
    action_info_light_attack4_special = UIWidgets.create_simple_text("", "action_info_light_attack4_special", nil, nil, base_info_text_style),
    action_info_light_attack4_armor_damage = UIWidgets.create_simple_text("", "action_info_light_attack4_armor_damage", nil, nil, base_info_armor_damage_style),
    action_info_light_attack4_base_damage = UIWidgets.create_simple_text("", "action_info_light_attack4_base_damage", nil, nil, base_info_armor_damage_style),

    action_info_light_attack5 = UIWidgets.create_frame("action_info_light_attack5", scenegraph_definition.action_info_light_attack5, "menu_frame_09", 1),
    action_info_light_attack5_hover = UIWidgets.create_frame("action_info_light_attack5", scenegraph_definition.action_info_light_attack5, "menu_frame_12", 25),
    action_info_light_attack5_bg = UIWidgets.create_tiled_texture("action_info_light_attack5", "menu_frame_bg_02", { 960, 1080 }, nil, nil, { 255, 100, 100, 100 }),
    action_info_light_attack5_hotspot = UIWidgets.create_simple_hotspot("action_info_light_attack5"),
    action_info_light_attack5_text = UIWidgets.create_simple_text("", "action_info_light_attack5_text", nil, nil, base_info_text_style),
    action_info_light_attack5_attack_speed = UIWidgets.create_simple_text("", "action_info_light_attack5_attack_speed", nil, nil, base_info_value_style_center),
    action_info_light_attack5_damage_limit = UIWidgets.create_simple_text("", "action_info_light_attack5_damage_limit", nil, nil, base_info_value_style_left_align),
    action_info_light_attack5_stagger_limit = UIWidgets.create_simple_text("", "action_info_light_attack5_stagger_limit", nil, nil, base_info_value_style_right_align),
    action_info_light_attack5_armor_damage = UIWidgets.create_simple_texture("tabs_icon_close", "action_info_light_attack5_armor_damage"),
    action_info_light_attack5_base_damage = UIWidgets.create_simple_texture("tabs_icon_close", "action_info_light_attack5_base_damage"),
    action_info_light_attack5_special = UIWidgets.create_simple_text("", "action_info_light_attack5_special", nil, nil, base_info_text_style),
    action_info_light_attack5_armor_damage = UIWidgets.create_simple_text("", "action_info_light_attack5_armor_damage", nil, nil, base_info_armor_damage_style),
    action_info_light_attack5_base_damage = UIWidgets.create_simple_text("", "action_info_light_attack5_base_damage", nil, nil, base_info_armor_damage_style),

    action_info_push_attack = UIWidgets.create_frame("action_info_push_attack", scenegraph_definition.action_info_push_attack.size, "menu_frame_09", 1),
    action_info_push_attack_hover = UIWidgets.create_frame("action_info_push_attack", scenegraph_definition.action_info_push_attack.size, "menu_frame_12", 25),
    action_info_push_attack_bg = UIWidgets.create_tiled_texture("action_info_push_attack", "menu_frame_bg_02", { 960, 1080 }, nil, nil, { 255, 100, 100, 100 }),
    action_info_push_attack_hotspot = UIWidgets.create_simple_hotspot("action_info_push_attack"),
    action_info_push_attack_text = UIWidgets.create_simple_text("", "action_info_push_attack_text", nil, nil, base_info_text_style),
    action_info_push_attack_attack_speed = UIWidgets.create_simple_text("", "action_info_push_attack_attack_speed", nil, nil, base_info_value_style_center),
    action_info_push_attack_damage_limit = UIWidgets.create_simple_text("", "action_info_push_attack_damage_limit", nil, nil, base_info_value_style_left_align),
    action_info_push_attack_stagger_limit = UIWidgets.create_simple_text("", "action_info_push_attack_stagger_limit", nil, nil, base_info_value_style_right_align),
    action_info_push_attack_armor_damage = UIWidgets.create_simple_texture("tabs_icon_close", "action_info_push_attack_armor_damage"),
    action_info_push_attack_base_damage = UIWidgets.create_simple_texture("tabs_icon_close", "action_info_push_attack_base_damage"),
    action_info_push_attack_special = UIWidgets.create_simple_text("", "action_info_push_attack_special", nil, nil, base_info_text_style),
    action_info_push_attack_armor_damage = UIWidgets.create_simple_text("", "action_info_push_attack_armor_damage", nil, nil, base_info_armor_damage_style),
    action_info_push_attack_base_damage = UIWidgets.create_simple_text("", "action_info_push_attack_base_damage", nil, nil, base_info_armor_damage_style),

    action_info_heavy_attack1 = UIWidgets.create_frame("action_info_heavy_attack1", scenegraph_definition.action_info_heavy_attack1, "menu_frame_09", 1),
    action_info_heavy_attack1_hover = UIWidgets.create_frame("action_info_heavy_attack1", scenegraph_definition.action_info_heavy_attack1, "menu_frame_12", 25),
    action_info_heavy_attack1_bg = UIWidgets.create_tiled_texture("action_info_heavy_attack1", "menu_frame_bg_02", { 960, 1080 }, nil, nil, { 255, 100, 100, 100 }),
    action_info_heavy_attack1_hotspot = UIWidgets.create_simple_hotspot("action_info_heavy_attack1"),
    action_info_heavy_attack1_text = UIWidgets.create_simple_text("", "action_info_heavy_attack1_text", nil, nil, base_info_text_style),
    action_info_heavy_attack1_attack_speed = UIWidgets.create_simple_text("", "action_info_heavy_attack1_attack_speed", nil, nil, base_info_value_style_center),
    action_info_heavy_attack1_damage_limit = UIWidgets.create_simple_text("", "action_info_heavy_attack1_damage_limit", nil, nil, base_info_value_style_left_align),
    action_info_heavy_attack1_stagger_limit = UIWidgets.create_simple_text("", "action_info_heavy_attack1_stagger_limit", nil, nil, base_info_value_style_right_align),
    action_info_heavy_attack1_armor_damage = UIWidgets.create_simple_texture("tabs_icon_close", "action_info_heavy_attack1_armor_damage"),
    action_info_heavy_attack1_base_damage = UIWidgets.create_simple_texture("tabs_icon_close", "action_info_heavy_attack1_base_damage"),
    action_info_heavy_attack1_special = UIWidgets.create_simple_text("", "action_info_heavy_attack1_special", nil, nil, base_info_text_style),
    action_info_heavy_attack1_armor_damage = UIWidgets.create_simple_text("", "action_info_heavy_attack1_armor_damage", nil, nil, base_info_armor_damage_style),
    action_info_heavy_attack1_base_damage = UIWidgets.create_simple_text("", "action_info_heavy_attack1_base_damage", nil, nil, base_info_armor_damage_style),

    action_info_heavy_attack2 = UIWidgets.create_frame("action_info_heavy_attack2", scenegraph_definition.action_info_heavy_attack2, "menu_frame_09", 1),
    action_info_heavy_attack2_hover = UIWidgets.create_frame("action_info_heavy_attack2", scenegraph_definition.action_info_heavy_attack2, "menu_frame_12", 25),
    action_info_heavy_attack2_bg = UIWidgets.create_tiled_texture("action_info_heavy_attack2", "menu_frame_bg_02", { 960, 1080 }, nil, nil, { 255, 100, 100, 100 }),
    action_info_heavy_attack2_hotspot = UIWidgets.create_simple_hotspot("action_info_heavy_attack2"),
    action_info_heavy_attack2_text = UIWidgets.create_simple_text("", "action_info_heavy_attack2_text", nil, nil, base_info_text_style),
    action_info_heavy_attack2_attack_speed = UIWidgets.create_simple_text("", "action_info_heavy_attack2_attack_speed", nil, nil, base_info_value_style_center),
    action_info_heavy_attack2_damage_limit = UIWidgets.create_simple_text("", "action_info_heavy_attack2_damage_limit", nil, nil, base_info_value_style_left_align),
    action_info_heavy_attack2_stagger_limit = UIWidgets.create_simple_text("", "action_info_heavy_attack2_stagger_limit", nil, nil, base_info_value_style_right_align),
    action_info_heavy_attack2_armor_damage = UIWidgets.create_simple_texture("tabs_icon_close", "action_info_heavy_attack2_armor_damage"),
    action_info_heavy_attack2_base_damage = UIWidgets.create_simple_texture("tabs_icon_close", "action_info_heavy_attack2_base_damage"),
    action_info_heavy_attack2_special = UIWidgets.create_simple_text("", "action_info_heavy_attack2_special", nil, nil, base_info_text_style),
    action_info_heavy_attack2_armor_damage = UIWidgets.create_simple_text("", "action_info_heavy_attack2_armor_damage", nil, nil, base_info_armor_damage_style),
    action_info_heavy_attack2_base_damage = UIWidgets.create_simple_text("", "action_info_heavy_attack2_base_damage", nil, nil, base_info_armor_damage_style),

    action_info_heavy_attack3 = UIWidgets.create_frame("action_info_heavy_attack3", scenegraph_definition.action_info_heavy_attack3, "menu_frame_09", 1),
    action_info_heavy_attack3_hover = UIWidgets.create_frame("action_info_heavy_attack3", scenegraph_definition.action_info_heavy_attack3, "menu_frame_12", 25),
    action_info_heavy_attack3_bg = UIWidgets.create_tiled_texture("action_info_heavy_attack3", "menu_frame_bg_02", { 960, 1080 }, nil, nil, { 255, 100, 100, 100 }),
    action_info_heavy_attack3_hotspot = UIWidgets.create_simple_hotspot("action_info_heavy_attack3"),
    action_info_heavy_attack3_text = UIWidgets.create_simple_text("", "action_info_heavy_attack3_text", nil, nil, base_info_text_style),
    action_info_heavy_attack3_attack_speed = UIWidgets.create_simple_text("", "action_info_heavy_attack3_attack_speed", nil, nil, base_info_value_style_center),
    action_info_heavy_attack3_damage_limit = UIWidgets.create_simple_text("", "action_info_heavy_attack3_damage_limit", nil, nil, base_info_value_style_left_align),
    action_info_heavy_attack3_stagger_limit = UIWidgets.create_simple_text("", "action_info_heavy_attack3_stagger_limit", nil, nil, base_info_value_style_right_align),
    action_info_heavy_attack3_armor_damage = UIWidgets.create_simple_texture("tabs_icon_close", "action_info_heavy_attack3_armor_damage"),
    action_info_heavy_attack3_base_damage = UIWidgets.create_simple_texture("tabs_icon_close", "action_info_heavy_attack3_base_damage"),
    action_info_heavy_attack3_special = UIWidgets.create_simple_text("", "action_info_heavy_attack3_special", nil, nil, base_info_text_style),
    action_info_heavy_attack3_armor_damage = UIWidgets.create_simple_text("", "action_info_heavy_attack3_armor_damage", nil, nil, base_info_armor_damage_style),
    action_info_heavy_attack3_base_damage = UIWidgets.create_simple_text("", "action_info_heavy_attack3_base_damage", nil, nil, base_info_armor_damage_style),

    action_info_heavy_attack4 = UIWidgets.create_frame("action_info_heavy_attack4", scenegraph_definition.action_info_heavy_attack4, "menu_frame_09", 1),
    action_info_heavy_attack4_hover = UIWidgets.create_frame("action_info_heavy_attack4", scenegraph_definition.action_info_heavy_attack4, "menu_frame_12", 25),
    action_info_heavy_attack4_bg = UIWidgets.create_tiled_texture("action_info_heavy_attack4", "menu_frame_bg_02", { 960, 1080 }, nil, nil, { 255, 100, 100, 100 }),
    action_info_heavy_attack4_hotspot = UIWidgets.create_simple_hotspot("action_info_heavy_attack4"),
    action_info_heavy_attack4_text = UIWidgets.create_simple_text("", "action_info_heavy_attack4_text", nil, nil, base_info_text_style),
    action_info_heavy_attack4_attack_speed = UIWidgets.create_simple_text("", "action_info_heavy_attack4_attack_speed", nil, nil, base_info_value_style_center),
    action_info_heavy_attack4_damage_limit = UIWidgets.create_simple_text("", "action_info_heavy_attack4_damage_limit", nil, nil, base_info_value_style_left_align),
    action_info_heavy_attack4_stagger_limit = UIWidgets.create_simple_text("", "action_info_heavy_attack4_stagger_limit", nil, nil, base_info_value_style_right_align),
    action_info_heavy_attack4_armor_damage = UIWidgets.create_simple_texture("tabs_icon_close", "action_info_heavy_attack4_armor_damage"),
    action_info_heavy_attack4_base_damage = UIWidgets.create_simple_texture("tabs_icon_close", "action_info_heavy_attack4_base_damage"),
    action_info_heavy_attack4_special = UIWidgets.create_simple_text("", "action_info_heavy_attack4_special", nil, nil, base_info_text_style),
    action_info_heavy_attack4_armor_damage = UIWidgets.create_simple_text("", "action_info_heavy_attack4_armor_damage", nil, nil, base_info_armor_damage_style),
    action_info_heavy_attack4_base_damage = UIWidgets.create_simple_text("", "action_info_heavy_attack4_base_damage", nil, nil, base_info_armor_damage_style),

    base_info_melee_block_angle = UIWidgets.create_frame("base_info_melee_block_angle", scenegraph_definition.base_info_melee_block_angle.size, "menu_frame_09", 18),
    base_info_melee_block_angle_hover = UIWidgets.create_frame("base_info_melee_block_angle", scenegraph_definition.base_info_melee_block_angle.size, "menu_frame_12", 25),
    base_info_melee_block_angle_bg = UIWidgets.create_tiled_texture("base_info_melee_block_angle", "menu_frame_bg_02", { 960, 1080 }, nil, nil, { 255, 100, 100, 100 }),
    base_info_melee_block_angle_hotspot = UIWidgets.create_simple_hotspot("base_info_melee_block_angle"),
    base_info_melee_block_angle_tooltip = UIWidgets.create_simple_tooltip("Effective Block Angle", "base_info_melee_block_angle", nil, tooltip_text_style),
    base_info_melee_block_angle_icon = UIWidgets.create_simple_texture("surrounded_shield", "base_info_melee_block_angle_icon"),
    base_info_melee_block_angle_value = UIWidgets.create_simple_text("", "base_info_melee_block_angle_value", nil, nil, base_info_value_style_right_align),

    base_info_melee_block_efficiency = UIWidgets.create_frame("base_info_melee_block_efficiency", scenegraph_definition.base_info_melee_block_efficiency.size, "menu_frame_09", 18),
    base_info_melee_block_efficiency_hover = UIWidgets.create_frame("base_info_melee_block_efficiency", scenegraph_definition.base_info_melee_block_efficiency.size, "menu_frame_12", 25),
    base_info_melee_block_efficiency_bg = UIWidgets.create_tiled_texture("base_info_melee_block_efficiency", "menu_frame_bg_02", { 960, 1080 }, nil, nil, { 255, 100, 100, 100 }),
    base_info_melee_block_efficiency_hotspot = UIWidgets.create_simple_hotspot("base_info_melee_block_efficiency"),
    base_info_melee_block_efficiency_tooltip = UIWidgets.create_simple_tooltip("Inner / Outer Block Cost Modifiers", "base_info_melee_block_efficiency", nil, tooltip_text_style),
    base_info_melee_block_efficiency_icon = UIWidgets.create_simple_texture("melee_shield_on_assist", "base_info_melee_block_efficiency_icon"),
    base_info_melee_block_efficiency_value_left = UIWidgets.create_simple_text("", "base_info_melee_block_efficiency_value_left", nil, nil, base_info_value_style_left_align),
    base_info_melee_block_efficiency_value_right = UIWidgets.create_simple_text("", "base_info_melee_block_efficiency_value_right", nil, nil, base_info_value_style_right_align),

    base_info_dodge_bonus = UIWidgets.create_frame("base_info_dodge_bonus", scenegraph_definition.base_info_dodge_bonus.size, "menu_frame_09", 18),
    base_info_dodge_bonus_hover = UIWidgets.create_frame("base_info_dodge_bonus", scenegraph_definition.base_info_dodge_bonus.size, "menu_frame_12", 25),
    base_info_dodge_bonus_bg = UIWidgets.create_tiled_texture("base_info_dodge_bonus", "menu_frame_bg_02", { 960, 1080 }, nil, nil, { 255, 100, 100, 100 }),
    base_info_dodge_bonus_hotspot = UIWidgets.create_simple_hotspot("base_info_dodge_bonus"),
    base_info_dodge_bonus_tooltip = UIWidgets.create_simple_tooltip("Dodge Bonus (Speed & Distance)", "base_info_dodge_bonus", nil, tooltip_text_style),
    base_info_dodge_bonus_icon = UIWidgets.create_simple_texture("dodging", "base_info_dodge_bonus_icon"),
    base_info_dodge_bonus_value = UIWidgets.create_simple_text("", "base_info_dodge_bonus_value", nil, nil, base_info_value_style_right_align),

    base_info_dodge_count = UIWidgets.create_frame("base_info_dodge_count", scenegraph_definition.base_info_dodge_count.size, "menu_frame_09", 18),
    base_info_dodge_count_hover = UIWidgets.create_frame("base_info_dodge_count", scenegraph_definition.base_info_dodge_count.size, "menu_frame_12", 25),
    base_info_dodge_count_bg = UIWidgets.create_tiled_texture("base_info_dodge_count", "menu_frame_bg_02", { 960, 1080 }, nil, nil, { 255, 100, 100, 100 }),
    base_info_dodge_count_hotspot = UIWidgets.create_simple_hotspot("base_info_dodge_count"),
    base_info_dodge_count_tooltip = UIWidgets.create_simple_tooltip("Effective Dodge Count", "base_info_dodge_count", nil, tooltip_text_style),
    base_info_dodge_count_icon = UIWidgets.create_simple_texture("shield_bash", "base_info_dodge_count_icon"),
    base_info_dodge_count_value = UIWidgets.create_simple_text("", "base_info_dodge_count_value", nil, nil, base_info_value_style_left_align),

    base_info_melee_push_angles = UIWidgets.create_frame("base_info_melee_push_angles", scenegraph_definition.base_info_melee_push_angles.size, "menu_frame_09", 18),
    base_info_melee_push_angles_hover = UIWidgets.create_frame("base_info_melee_push_angles", scenegraph_definition.base_info_melee_push_angles.size, "menu_frame_12", 25),
    base_info_melee_push_angles_bg = UIWidgets.create_tiled_texture("base_info_melee_push_angles", "menu_frame_bg_02", { 960, 1080 }, nil, nil, { 255, 100, 100, 100 }),
    base_info_melee_push_angles_hotspot = UIWidgets.create_simple_hotspot("base_info_melee_push_angles"),
    base_info_melee_push_angles_tooltip = UIWidgets.create_simple_tooltip("Inner / Outer Push Angles", "base_info_melee_push_angles", nil, tooltip_text_style),
    base_info_melee_push_angles_icon = UIWidgets.create_simple_texture("melee_increase_damage_on_block", "base_info_melee_push_angles_icon"),
    base_info_melee_push_angles_value_left = UIWidgets.create_simple_text("", "base_info_melee_push_angles_value_left", nil, nil, base_info_value_style_left_align),
    base_info_melee_push_angles_value_right = UIWidgets.create_simple_text("", "base_info_melee_push_angles_value_right", nil, nil, base_info_value_style_right_align),

    base_info_melee_push_radius = UIWidgets.create_frame("base_info_melee_push_radius", scenegraph_definition.base_info_melee_push_radius.size, "menu_frame_09", 18),
    base_info_melee_push_radius_hover = UIWidgets.create_frame("base_info_melee_push_radius", scenegraph_definition.base_info_melee_push_radius.size, "menu_frame_12", 25),
    base_info_melee_push_radius_bg = UIWidgets.create_tiled_texture("base_info_melee_push_radius", "menu_frame_bg_02", { 960, 1080 }, nil, nil, { 255, 100, 100, 100 }),
    base_info_melee_push_radius_hotspot = UIWidgets.create_simple_hotspot("base_info_melee_push_radius"),
    base_info_melee_push_radius_tooltip = UIWidgets.create_simple_tooltip("Push Radius", "base_info_melee_push_radius", nil, tooltip_text_style),
    base_info_melee_push_radius_icon = UIWidgets.create_simple_texture("melee_counter_push_power", "base_info_melee_push_radius_icon"),
    base_info_melee_push_radius_value = UIWidgets.create_simple_text("", "base_info_melee_push_radius_value", nil, nil, base_info_value_style_left_align),

    base_info_ranged_reload_time = UIWidgets.create_frame("base_info_ranged_reload_time", scenegraph_definition.base_info_ranged_reload_time.size, "menu_frame_09", 18),
    base_info_ranged_reload_time_hover = UIWidgets.create_frame("base_info_ranged_reload_time", scenegraph_definition.base_info_ranged_reload_time.size, "menu_frame_12", 25),
    base_info_ranged_reload_time_bg = UIWidgets.create_tiled_texture("base_info_ranged_reload_time", "menu_frame_bg_02", { 960, 1080 }, nil, nil, { 255, 100, 100, 100 }),
    base_info_ranged_reload_time_hotspot = UIWidgets.create_simple_hotspot("base_info_ranged_reload_time"),
    base_info_ranged_reload_time_tooltip = UIWidgets.create_simple_tooltip("Reload Time", "base_info_ranged_reload_time", nil, tooltip_text_style),
    base_info_ranged_reload_time_icon = UIWidgets.create_simple_texture("time_forward", "base_info_ranged_reload_time_icon"),
    base_info_ranged_reload_time_value = UIWidgets.create_simple_text("", "base_info_ranged_reload_time_value", nil, nil, base_info_value_style_right_align),

    base_info_ranged_ammo = UIWidgets.create_frame("base_info_ranged_ammo", scenegraph_definition.base_info_ranged_ammo.size, "menu_frame_09", 18),
    base_info_ranged_ammo_hover = UIWidgets.create_frame("base_info_ranged_ammo", scenegraph_definition.base_info_ranged_ammo.size, "menu_frame_12", 25),
    base_info_ranged_ammo_bg = UIWidgets.create_tiled_texture("base_info_ranged_ammo", "menu_frame_bg_02", { 960, 1080 }, nil, nil, { 255, 100, 100, 100 }),
    base_info_ranged_ammo_hotspot = UIWidgets.create_simple_hotspot("base_info_ranged_ammo"),
    base_info_ranged_ammo_tooltip = UIWidgets.create_simple_tooltip("Ammo Per Clip / Max Ammo", "base_info_ranged_ammo", nil, tooltip_text_style),
    base_info_ranged_ammo_icon = UIWidgets.create_simple_texture("quiver", "base_info_ranged_ammo_icon"),
    base_info_ranged_ammo_value_left = UIWidgets.create_simple_text("", "base_info_ranged_ammo_value_left", nil, nil, base_info_value_style_left_align),
    base_info_ranged_ammo_value_right = UIWidgets.create_simple_text("", "base_info_ranged_ammo_value_right", nil, nil, base_info_value_style_right_align),

    base_info_ranged_overcharge = UIWidgets.create_frame("base_info_ranged_overcharge", scenegraph_definition.base_info_ranged_overcharge.size, "menu_frame_09", 18),
    base_info_ranged_overcharge_hover = UIWidgets.create_frame("base_info_ranged_overcharge", scenegraph_definition.base_info_ranged_overcharge.size, "menu_frame_12", 25),
    base_info_ranged_overcharge_bg = UIWidgets.create_tiled_texture("base_info_ranged_overcharge", "menu_frame_bg_02", { 960, 1080 }, nil, nil, { 255, 100, 100, 100 }),
    base_info_ranged_overcharge_hotspot = UIWidgets.create_simple_hotspot("base_info_ranged_overcharge"),
    base_info_ranged_overcharge_tooltip = UIWidgets.create_simple_tooltip("Max Overcharge", "base_info_ranged_overcharge", nil, tooltip_text_style),
    base_info_ranged_overcharge_icon = UIWidgets.create_simple_texture("flame", "base_info_ranged_overcharge_icon"),
    base_info_ranged_overcharge_value = UIWidgets.create_simple_text("", "base_info_ranged_overcharge_value", nil, nil, base_info_value_style_right_align),

    --base_info_ranged_max_range = UIWidgets.create_frame("base_info_ranged_max_range", scenegraph_definition.base_info_ranged_max_range.size, "menu_frame_09", 18),
    --base_info_ranged_max_range_hover = UIWidgets.create_frame("base_info_ranged_max_range", scenegraph_definition.base_info_ranged_max_range.size, "menu_frame_12", 25),
    --base_info_ranged_max_range_bg = UIWidgets.create_tiled_texture("base_info_ranged_max_range", "menu_frame_bg_02", { 960, 1080 }, nil, nil, { 255, 100, 100, 100 }),
    --base_info_ranged_max_range_hotspot = UIWidgets.create_simple_hotspot("base_info_ranged_max_range"),
    --base_info_ranged_max_range_tooltip = UIWidgets.create_simple_tooltip("Max Range", "base_info_ranged_max_range", nil, tooltip_text_style),
    --base_info_ranged_max_range_icon = UIWidgets.create_simple_texture("spyglass", "base_info_ranged_max_range_icon"),
    --base_info_ranged_max_range_value = UIWidgets.create_simple_text("", "base_info_ranged_max_range_value", nil, nil, base_info_value_style_left_align),

    coming_soon = UIWidgets.create_simple_text("", "coming_soon", nil, nil, base_info_value_style_center),

    detail_info_title = UIWidgets.create_simple_text("", "detail_info_title", nil, nil, detail_title_text_style),
    detail_info_desc = UIWidgets.create_simple_text("", "detail_info_desc", nil, nil, base_info_value_style_center),
    detail_info_desc2 = UIWidgets.create_simple_text("", "detail_info_desc2", nil, nil, base_info_value_style_center),

    viewport_background_widget = UIWidgets.create_background("weapon_preview_viewport", scenegraph_definition.weapon_preview_viewport.size, "item_tooltip_background_old", {255, 0, 0, 0})
}

for widget_name, widget in pairs(widgets) do
    if string.match(widget_name, "_hover") ~= nil then
        widget.style.frame.color = { 0, 255, 255, 255 }
    end
end

local detail_info = {
    header_attack_speed_hotspot = {
        title = "Attack Speed",
        desc = "The amount of time from after an attack starts until a follow-up attack can be executed."
    },
    header_cleave_hotspot = {
        title = "Cleave Limit",
        desc = "The total mass an attack can penetrate, before modifiers (see Special Properties)."
    },
    header_armor_damage_hotspot = {
        title = "Armor Damage",
        desc = "Indicates the amount of damage an attack will deal against armored opponents, before bonuses. Does not include Chaos Warriors, bosses, or lords."
    },
    header_base_damage_hotspot = {
        title = "Base Damage",
        desc = "Indicates the amount of damage an attack will deal against unarmored opponents, before bonuses."
    },
    header_special_property_hotspot = {
        title = "Special Properties",
        desc = "Burns, Bleeds, Poisons: Indicates the type of damage over time an attack inflicts.",
        desc2 = "Crit: Indicates the bonus to critical chance.\n\nLinesman, Heavy Linesman, Tank: Indicates the mass modifier of an attack.\nRefer to an enemy's entry in bestiary for specifics."
    },
    base_info_ranged_max_range_hotspot = {
        title = "Max Range / Projectile Lifetime",
        desc = "The maximum distance, in meters, that this weapon's projectiles can reach.",
        desc2 = "The maximum time, in seconds, this weapon's projectiles will remain active."
    },
    base_info_ranged_ammo_hotspot = {
        title = "Ammunition",
        desc = "The amount of ammunition in this weapon's clip and the maximum amount of ammunition this weapon holds."
    },
    base_info_ranged_overcharge_hotspot = {
        title = "Max Overcharge",
        desc = "The maximum amount of overcharge this weapon can generate before exploding."
    },
    base_info_ranged_reload_time_hotspot = {
        title = "Reload Time",
        desc = "The time, in seconds, it takes to refill this weapon's clip."
    },
    base_info_dodge_count_hotspot = {
        title = "Effective Dodge Count",
        desc = "The maximum number of consecutive, full-strength dodges you can perform.",
        desc2 = "(Note: This count resets after a short duration without dodging.)"
    },
    base_info_dodge_bonus_hotspot = {
        title = "Dodge Bonus",
        desc = "The bonus (or penalty) this weapon provides your dodge speed and dodge distance."
    },
    base_info_melee_block_angle_hotspot = {
        title = "Effective Block Angle",
        desc = "The size of the angle, in degrees, where this weapon's Inner Block Cost Modifier takes effect.",
        desc2 = "(Note: Blocks outside the effective angle use this weapon's Outer Block Cost Modifier."
    },
    base_info_melee_block_efficiency_hotspot = {
        title = "Block Cost Modifiers",
        desc = "Block costs are multiplied by the appropriate modifier to determine stamina shield damage."
    },
    base_info_melee_push_angles_hotspot = {
        title = "Push Angles",
        desc = "The size of the angles, in degrees, where this weapon's strong and weak pushes take effect.",
    },
    base_info_melee_push_radius_hotspot = {
        title = "Push Radius",
        desc = "The distance, in meters, from you that this weapon's push angles take effect."
    }
}

for widget_name, widget in pairs(widgets) do
    if string.match(widget_name, "_hotspot") ~= nil then
        widget.content.data = detail_info[widget_name]
    end
end

local category_settings = {
    {
        name = "melee",
        item_filter = "slot_type == melee",
        hero_specific_filter = false,
        display_name = Localize("inventory_screen_melee_weapon_title"),
        item_types = {
            "melee"
        },
        icon = UISettings.slot_icons.melee
    },
    {
        name = "ranged",
        item_filter = "slot_type == ranged",
        hero_specific_filter = false,
        display_name = Localize("inventory_screen_ranged_weapon_title"),
        item_types = {
            "ranged"
        },
        icon = UISettings.slot_icons.ranged
    }
}

local attack_list = mod:dofile("scripts/mods/armory/definitions/armory_wanted_attack_list")
local weapon_preview_data = mod:dofile("scripts/mods/armory/definitions/armory_wanted_weapon_data")

local highlight_widget_list = {
    "hero_tray",
    "weapon_tray",
    "weapon_preview_tray",
    "weapon_preview_button_tray",
    "right_window_tray",

    "header_attack_speed",
    "header_cleave",
    "header_armor_damage",
    "header_base_damage",
    "header_special_property",

    "action_info_ranged_attack1",
    "action_info_ranged_attack2",
    "action_info_ranged_attack3",
    "action_info_ranged_attack4",

    "action_info_light_attack1",
    "action_info_light_attack2",
    "action_info_light_attack3",
    "action_info_light_attack4",
    "action_info_light_attack5",
    "action_info_push_attack",
    "action_info_heavy_attack1",
    "action_info_heavy_attack2",
    "action_info_heavy_attack3",
    "action_info_heavy_attack4",

    "base_info_melee_block_angle",
    "base_info_melee_block_efficiency",
    "base_info_dodge_bonus",
    "base_info_dodge_count",
    "base_info_melee_push_angles",
    "base_info_melee_push_radius",

    "base_info_ranged_reload_time",
    "base_info_ranged_ammo",
    "base_info_ranged_overcharge",
    --"base_info_ranged_max_range",
}

return {
    widgets = widgets,
    viewport_widget = viewport_widget,
    category_settings = category_settings,
    scenegraph_definition = scenegraph_definition,
    animation_definitions = animation_definitions,
    attack_list = attack_list,
    weapon_preview_data = weapon_preview_data,
    highlight_widget_list = highlight_widget_list
}