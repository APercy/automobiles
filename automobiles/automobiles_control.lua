--global constants

automobiles.vector_up = vector.new(0, 1, 0)

function automobiles.check_road_is_ok(obj, max_acc_factor)
	local pos_below = obj:get_pos()
	pos_below.y = pos_below.y - 0.1
	local node_below = minetest.get_node(pos_below).name
    --minetest.chat_send_all(node_below)
    local nodedef = minetest.registered_nodes[node_below]
    if nodedef.liquidtype == "none" then
        local slow_nodes = {
                            ['default:ice '] = 0.01,
                            ['default:cave_ice'] = 0.01,
                           }
        local acc = slow_nodes[node_below]
        if acc == nil then acc = max_acc_factor end
        return acc
    else
        return 0
    end
end

function automobiles.control(self, dtime, hull_direction, longit_speed, longit_drag, later_drag, accel, max_acc_factor, max_speed, steering_limit, steering_speed)
    self._last_time_command = self._last_time_command + dtime
    if self._last_time_command > 1 then self._last_time_command = 1 end

	local player = minetest.get_player_by_name(self.driver_name)
    local retval_accel = accel;
    local stop = false
    
	-- player control
	if player then
		local ctrl = player:get_player_control()
		
        local acc = 0

        if longit_speed < roadster.max_speed and ctrl.up then
            --get acceleration factor
            acc = automobiles.check_road_is_ok(self.object, max_acc_factor)
            --minetest.chat_send_all('engineacc: '.. engineacc)
            if acc > 1 and acc < max_acc_factor and longit_speed > 0 then
                --improper road will reduce speed
                acc = -1
            end
        end

        --reversing
	    if ctrl.sneak and longit_speed <= 1.0 and longit_speed > -1.0 then
            acc = -1
	    end

        --break
        if ctrl.down then
        
            --total stop
            --wheel break
            if longit_speed > 0 then
                acc = -5
                if (longit_speed + acc) < 0 then
                    acc = longit_speed * -1
                end
            end
            if longit_speed < 0 then
                acc = 5
                if (longit_speed + acc) > 0 then
                    acc = longit_speed * -1
                end
            end
            if abs(longit_speed) < 0.2 then
                stop = true
            end
        end

        if acc then retval_accel=vector.add(accel,vector.multiply(hull_direction,acc)) end

		-- steering
		if ctrl.right then
			self._steering_angle = math.max(self._steering_angle-steering_speed*dtime,-steering_limit)
		elseif ctrl.left then
			self._steering_angle = math.min(self._steering_angle+steering_speed*dtime,steering_limit)
        else
            --center steering
            if longit_speed > 0 then
                local factor = 1
                if self._steering_angle > 0 then factor = -1 end
                local correction = (steering_limit*(longit_speed/100)) * factor
                local before_correction = self._steering_angle
                self._steering_angle = self._steering_angle + correction
                if math.sign(before_correction) ~= math.sign(self._steering_angle) then self._steering_angle = 0 end
            end
		end

        local angle_factor = self._steering_angle / 60
        if angle_factor < 0 then angle_factor = angle_factor * -1 end
        local deacc_on_curve = longit_speed * angle_factor
        deacc_on_curve = deacc_on_curve * -1
        if deacc_on_curve then retval_accel=vector.add(retval_accel,vector.multiply(hull_direction,deacc_on_curve)) end
    
	end

    return retval_accel, stop
end


