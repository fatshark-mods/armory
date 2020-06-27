local mod = get_mod("armory")

local DEFAULT_ANGLE = math.degrees_to_radians(90)
local initial_rotation_box = QuaternionBox()

mod:hook_safe(MenuWorldPreviewer, "on_enter", function  (self)
    mod._camera_default_position = {
        z = 1.7,
        x = -1.5,
        y = -1.5
    }

    self.camera_x_pan_current = -1.5
    self.camera_x_pan_target = -1.5

    self.camera_y_pan_current = -1.5
    self.camera_y_pan_target = -1.5

    self.camera_z_pan_current = 0
    self.camera_z_pan_target = 0

    self.camera_x_angle_current = 0
    self.camera_x_angle_target = 0

    self.camera_z_angle_current = 1.5
    self.camera_z_angle_target = 1.5

    self.camera_zoom_current = 1
    self.camera_zoom_target = 1

end)

MenuWorldPreviewer.request_spawn_weapon_unit = function (self, weapon_data, callback)
    self._requested_weapon_spawn_data = {
        frame_delay = 3,
        weapon_data = weapon_data,
        callback = callback,
    }
    self:clear_units_armory()
end

MenuWorldPreviewer.prepare_exit_armory = function (self)
    self:clear_units_armory()
end

MenuWorldPreviewer.clear_units_armory = function (self, reset_camera)
    local world = self.world
    local weapon_units = self.weapon_units

    if weapon_units ~= nil then
        for _, weapon_unit in pairs(weapon_units) do
            World.destroy_unit(world, weapon_unit)
        end
        self.weapon_units = nil
    end
end

MenuWorldPreviewer.update_weapon = function (self, dt, t, input_disabled)
    local weapon_units = self.weapon_units

    if weapon_units ~= nil then
        local skin_data = self.skin_data

        if self.camera_z_angle_target > math.pi * 2 then
            self.camera_z_angle_current = self.camera_z_angle_current - math.pi * 2
            self.camera_z_angle_target = self.camera_z_angle_target - math.pi * 2
        end

        local weapon_z_angle_new = math.lerp(self.camera_z_angle_current, self.camera_z_angle_target, 0.1)
        self.camera_z_angle_current = weapon_z_angle_new
        local weapon_x_angle_new = math.lerp(self.camera_x_angle_current, self.camera_x_angle_target, 0.1)
        self.camera_x_angle_current = weapon_x_angle_new

        local right_weapon_unit = weapon_units.right_weapon_unit
        if right_weapon_unit then

            local x_rot = Quaternion(Vector3.right(), -weapon_x_angle_new)
            local z_rot = Quaternion(Vector3.up(), -weapon_z_angle_new)


            if skin_data.is_ranged then
                z_rot = Quaternion(Vector3.forward(), -weapon_z_angle_new)
            end

            local result = Quaternion.multiply(x_rot, z_rot)
            Unit.set_local_rotation(right_weapon_unit, 0, result)

        end

        local left_weapon_unit = weapon_units.left_weapon_unit
        if left_weapon_unit then

            local is_shield_unit = skin_data and string.match(skin_data.skin_prefix, "shield")
            if not is_shield_unit then

                local x_rot = Quaternion(Vector3.right(), -weapon_x_angle_new)
                local z_rot = Quaternion(Vector3.up(), -weapon_z_angle_new)



                local result = Quaternion.multiply(x_rot, z_rot)
                Unit.set_local_rotation(left_weapon_unit, 0, result)
            end
        end
    end

    if self.camera_z_pan_target < -0.75 then
        self.camera_z_pan_target = -0.75
    elseif self.camera_z_pan_target > 1 then
        self.camera_z_pan_target = 1
    end

    if self.camera_zoom_target > 2 then
        self.camera_zoom_target = 2
    elseif self.camera_zoom_target < 0.25 then
        self.camera_zoom_target = 0.25
    end

    local camera_x_pan_new = math.lerp(self.camera_x_pan_current, self.camera_x_pan_target,0.1)
    self.camera_x_pan_current = camera_x_pan_new

    local camera_y_pan_new = math.lerp(self.camera_y_pan_current, self.camera_y_pan_target, 0.1)
    self.camera_y_pan_current = camera_y_pan_new

    local camera_z_pan_new = math.lerp(self.camera_z_pan_current, self.camera_z_pan_target, 0.1)
    self.camera_z_pan_current = camera_z_pan_new

    local camera_zoom_new = math.lerp(self.camera_zoom_current, self.camera_zoom_target, 0.1)
    self.camera_zoom_current = camera_zoom_new

    local camera_default_position = mod._camera_default_position
    local camera_position_new = Vector3.zero()
    camera_position_new.x = camera_zoom_new * math.sin(-camera_x_pan_new)
    camera_position_new.y = camera_zoom_new * math.cos(-camera_y_pan_new)
    camera_position_new.z = camera_default_position.z - camera_z_pan_new
    local lookat_target = Vector3(0, 0, camera_position_new.z)
    local direction = Vector3.normalize(lookat_target - camera_position_new)
    --direction.z = direction.z - camera_z_pan_new
    local rotation = Quaternion.look(direction)

    ScriptCamera.set_local_position(self.camera, camera_position_new)
    ScriptCamera.set_local_rotation(self.camera, rotation)

    local input_service = self.input_manager:get_service("hero_view")



    if not input_disabled then
        self:handle_mouse_input_armory(input_service, dt)
        self:handle_controller_input(input_service, dt)
    end
end


--[[
    Mouse controls:
        left-drag: rotate weapon about its z-axis
        right-drag: rotate weapon about its x-axis
        scroll up/down: zoom in/out
        shift + left-drag: rotate camera around weapon
]]

local mouse_pos_temp = {}
MenuWorldPreviewer.handle_mouse_input_armory = function (self, input_service, dt)
    local weapon_units = self.weapon_units

    if weapon_units == nil or not self.input_manager:is_device_active("mouse") then
        return
    end

    local mouse = input_service:get("cursor")

    if not mouse then
        return
    end

    local viewport_widget = self.viewport_widget
    local content = viewport_widget.content
    local button_hotspot = content.button_hotspot
    local is_hover = button_hotspot and button_hotspot.is_hover

    if is_hover then
        if input_service:get("left_press") then
            self.is_rotating_unit = true
            self.last_mouse_position = nil
        elseif input_service:get("right_press") then
            self.is_rotating_unit = true
            self.last_mouse_position = nil
        elseif input_service:get("scroll_axis") then
            self.is_rotating_unit = true
        end


    end

    local is_rotating_unit = self.is_rotating_unit
    local left_mouse_hold = input_service:get("left_hold")
    local right_mouse_hold = input_service:get("right_hold")
    local scroll_wheel = input_service:get("scroll_axis")
    local shift_hold = input_service:get("shift_hold")

    if is_rotating_unit and (left_mouse_hold or right_mouse_hold) then
        if self.last_mouse_position then
            if shift_hold then
                if left_mouse_hold then
                    self.camera_y_pan_target = self.camera_y_pan_target - (mouse.x - self.last_mouse_position[1]) * 0.0115
                    self.camera_x_pan_target = self.camera_x_pan_target - (mouse.x - self.last_mouse_position[1]) * 0.0115
                end
                if right_mouse_hold then
                    self.camera_z_pan_target = self.camera_z_pan_target - (mouse.y - self.last_mouse_position[2]) * 0.005
                end
            else
                if left_mouse_hold then
                    self.camera_z_angle_target = self.camera_z_angle_target - (mouse.x - self.last_mouse_position[1]) * 0.01
                end
                if right_mouse_hold then
                    self.camera_x_angle_target = self.camera_x_angle_target + (mouse.x - self.last_mouse_position[1]) * 0.01
                end
            end
        end

        mouse_pos_temp[1] = mouse.x
        mouse_pos_temp[2] = mouse.y
        self.last_mouse_position = mouse_pos_temp
    elseif is_hover and is_rotating_unit and scroll_wheel then
        self.camera_zoom_target = self.camera_zoom_target - (scroll_wheel[2]) * 0.25
    elseif is_rotating_unit then
        self.is_rotating_unit = false
    end
end

MenuWorldPreviewer.handle_controller_input_armory = function (self, input_service, dt)

end

MenuWorldPreviewer.post_update_armory = function (self, dt)
    self:_update_units_visibility_armory(dt)
    self:_handle_weapon_spawn_request()
    self:_poll_armory_package_loading()
end

MenuWorldPreviewer._poll_armory_package_loading = function (self)
    local data = self._weapon_loading_package_data

    if not data or data.loaded then
        return
    end

    local requested_weapon_spawn_data = self._requested_weapon_spawn_data

    if requested_weapon_spawn_data then
        return
    end

    local reference_name = self:_reference_name()
    local package_manager = Managers.package
    local package_names = data.package_names
    local all_packages_loaded = true

    for i = 1, #package_names, 1 do
        local package_name = package_names[i]
        if not package_manager:has_loaded(package_name, reference_name) then
            all_packages_loaded = false

            break
        end
    end

    if all_packages_loaded then
        self:_spawn_weapon_unit(data)

        local callback = data.callback

        if callback then
            callback()
        end

        data.loaded = true
    end
end

MenuWorldPreviewer._update_units_visibility_armory = function (self)
    local unit_visibility_frame_delay = self.unit_visibility_frame_delay

    if unit_visibility_frame_delay and unit_visibility_frame_delay > 0 then
        self.unit_visibility_frame_delay = unit_visibility_frame_delay - 1

        return
    end

    for unit, _ in pairs(self._hidden_units) do
        if Unit.alive(unit) then
            Unit.set_unit_visibility(unit, true)
            self._hidden_units[unit] = nil
        end

    end

end

MenuWorldPreviewer._handle_weapon_spawn_request = function (self)
    local requested_weapon_spawn_data = self._requested_weapon_spawn_data
    if requested_weapon_spawn_data then
        local frame_delay = requested_weapon_spawn_data.frame_delay

        if frame_delay == 0 then
            local weapon_data = requested_weapon_spawn_data.weapon_data
            local callback = requested_weapon_spawn_data.callback

            self:_load_weapon_unit(weapon_data, callback)

            self._requested_weapon_spawn_data = nil
        else
            requested_weapon_spawn_data.frame_delay = frame_delay - 1
        end
    end
end

MenuWorldPreviewer._load_weapon_unit = function (self, weapon_data, callback)
    self:_unload_all_packages()

    local package_names = {}

    local weapon_units = BackendUtils.get_item_units(weapon_data)

    local right_hand_unit = weapon_units.right_hand_unit
    local left_hand_unit = weapon_units.left_hand_unit

    if string.match(weapon_data.name, "dr_1h_throwing_axes") then
        right_hand_unit = weapon_units.ammo_unit .. "_3p"
        package_names[#package_names + 1] = right_hand_unit
    elseif right_hand_unit then
        right_hand_unit = right_hand_unit .. "_3p"
        package_names[#package_names + 1] = right_hand_unit
    end

    if left_hand_unit then
        left_hand_unit = left_hand_unit .. "_3p"
        package_names[#package_names + 1] = left_hand_unit
    end

    local data = {
        num_loaded_packages = 0,
        package_names = package_names,
        num_packages = #package_names,
        callback = callback,
        weapon_data = weapon_data,
        weapon_units = {
            right_hand_unit = right_hand_unit,
            left_hand_unit = left_hand_unit
        }
    }

    self:_load_packages(package_names)
    self._weapon_loading_package_data = data
end

MenuWorldPreviewer._spawn_weapon_unit = function (self, data)
    local weapon_units = data.weapon_units
    local world = self.world
    local skin_data = self.skin_data

    local right_hand_unit = weapon_units.right_hand_unit
    local left_hand_unit = weapon_units.left_hand_unit

    local right_weapon_unit
    if right_hand_unit then
        right_hand_unit = right_hand_unit
        right_weapon_unit = World.spawn_unit(world, right_hand_unit)

        local position = (skin_data and skin_data.position.right_hand_unit) or { 0, 0, 1.35 }
        Unit.set_local_position(right_weapon_unit, 0, Vector3(position[1], position[2], position[3]))

        Unit.set_unit_visibility(right_weapon_unit, false)
        self._hidden_units[right_weapon_unit] = true

        if Unit.has_lod_object(right_weapon_unit, "lod") then
            local lod_object = Unit.lod_object(right_weapon_unit, "lod")

            LODObject.set_static_select(lod_object, 0)
        end

        local material_settings = data.weapon_data and data.weapon_data.material_settings
        if material_settings then
            GearUtils.apply_material_settings(right_weapon_unit, material_settings)
        end
    end

    local left_weapon_unit
    if left_hand_unit then
        left_hand_unit = left_hand_unit
        left_weapon_unit = World.spawn_unit(world, left_hand_unit)

        local position = (skin_data and skin_data.position.left_hand_unit) or { 0.28, 0.25, 1.7 }
        Unit.set_local_position(left_weapon_unit, 0, Vector3(-position[1], position[2], position[3]))

        if skin_data and skin_data.is_ranged then
            local z_rot = Quaternion(Vector3.up(), -DEFAULT_ANGLE)
            Unit.set_local_rotation(left_weapon_unit, 0, z_rot)
        else
            local z_rot = Quaternion(Vector3.up(), math.degrees_to_radians(165))

            local is_shield_unit = skin_data and string.match(skin_data.skin_prefix, "shield")
            if is_shield_unit then
                Unit.set_local_rotation(left_weapon_unit, 0, z_rot)
            else
                local x_rot = Quaternion(Vector3.right(), 0)
                local result = Quaternion.multiply(z_rot, x_rot)

                --Unit.set_local_rotation(left_weapon_unit, 0, result)

                initial_rotation_box:store(result)
            end
        end

        Unit.set_unit_visibility(left_weapon_unit, false)
        self._hidden_units[left_weapon_unit] = true

        if Unit.has_lod_object(left_weapon_unit, "lod") then
            local lod_object = Unit.lod_object(left_weapon_unit, "lod")

            LODObject.set_static_select(lod_object, 0)
        end

        local material_settings = data.weapon_data and data.weapon_data.material_settings
        if material_settings then
            GearUtils.apply_material_settings(left_weapon_unit, material_settings)
        end
    end

    self.unit_visibility_frame_delay = 5
    self.camera_z_angle_current = 0
    self.camera_z_angle_target = 0

    self.weapon_units = {
        right_weapon_unit = right_weapon_unit,
        left_weapon_unit = left_weapon_unit
    }
end

MenuWorldPreviewer.spawn_weapon_unit = function (self, weapon_data, callback)
    self.skin_data = mod:get("preview_data")
    self:request_spawn_weapon_unit(weapon_data, callback)
end

MenuWorldPreviewer.reset_camera = function (self)
    if not self.camera then
        return
    end

    local position = Vector3(mod._camera_default_position.x, mod._camera_default_position.y, mod._camera_default_position.z)

    self.camera_x_pan_current = -1.5
    self.camera_x_pan_target = -1.5
    self.camera_y_pan_current = -1.5
    self.camera_y_pan_target = -1.5
    self.camera_z_pan_target = 0
    self.camera_x_angle_target = 0
    self.camera_z_angle_target = 0
    self.camera_zoom_target = 1

    ScriptCamera.set_local_position(self.camera, position)
end
