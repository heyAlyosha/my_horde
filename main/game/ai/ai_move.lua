-- Передвижение ботов
local M = {}

-- Пердвижение к точке
function M.move_item(self, position_to, handle)
	local position = go.get_position()

	local dir = position_to - position
	local len = vmath.length(dir)

	local duration = len / self.speed
	go.animate(go.get_id(), "position", go.PLAYBACK_ONCE_FORWARD, position_functions.go_get_perspective_z(position_to), go.EASING_LINEAR, duration, 0, handle)

	character_animations.play(self, "move")
	sprite.set_hflip("#body", dir.x < 0)
end

-- Пердвижение к цели
--[[
handle_success(self) -- Цель достигнута
handle_error(self, error_code) -- Невозможно достигнуть цели
handle_no_object_target(self) -- Объект удалён из мира
--]]
function M.move_to_object(self, url, handle_success, handle_error, handle_no_object_target)
	local position = go.get_position()

	if not go_controller.is_object(url) then
		-- Если объект удалён
		if handle_no_object_target then
			handle_no_object_target(self)
		end
		return
	end

	-- Если атакует, чекаем расстояние
	if self.is_attack and not self.timer_check_distation_attack then
		self.timer_check_distation_attack = timer.delay(0.2, true, function (self)
			print("check_distance_attack", ai_attack.check_distance_attack(self, url))
			if ai_attack.check_distance_attack(self, url) then
				M.stop(self)
				timer.delay(0.25, true, function (self)
					if ai_attack.check_distance_attack(self, url) then
						character_attack.attack(self, url)
					end
				end)
			end
			
		end)
	end

	self.target_vector = self.target_vector or vmath.vector3(0)
	self.target_position = go.get_position(url) + self.target_vector

	local dir = self.target_position - position
	local distantion_magnite = 16
	local dist = vmath.length(dir)

	if dist == 0 then
		-- Объект на позиции
		if handle_success then
			handle_success(self)
		end

	elseif dist < distantion_magnite then
		-- Маленькое расстояние до цели
		M.move_item(self, self.target_position, handle_success)
	else
		local result, path_size, totalcost, path = astar_functions.get_path(self, self.target_position)

		if not result then
			-- Нет доступа к цели
			if handle_error then
				local error_code = path_size
				handle_error(self, error_code)
			end
		else
			table.remove(path, 1)
			-- Двигамеся по сетке астар
			if not path or #path < 1 then
				if handle_success then
					handle_success(self)
				end
			else
				local x,y = astar_utils:coords_to_screen(path[1].x, path[1].y)
				local position_to = vmath.vector3(x, y, 0)
				M.move_item(self, position_to, function (self)
					M.move_to_object(self, url, handle_success, handle_error)
				end)
			end
			
		end

		
	end

end

-- Остановка движения
function M.stop(self)
	go.cancel_animations(go.get_id(), "position")

	if self.timer_check_distation_attack then
		timer.cancel(self.timer_check_distation_attack)
		self.timer_check_distation_attack = nil
	end
end

return M