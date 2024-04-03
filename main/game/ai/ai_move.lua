-- Передвижение ботов
local M = {}

-- Передвиджение от точки
function M.move_item_from(self, position_from, handle, speed)
	local position = go.get_position()
	local dir = (position_from - position) * (-1)

	local start_x, start_y = astar_utils:screen_to_coords(position.x, position.y)
	local max_cost = 2 -- near

	local near_result, near_size, nears = astar.solve_near(start_x, start_y, max_cost)

	local result = {}
	if near_result == astar.SOLVED then
		for i, v in ipairs(nears) do
			local x,y = astar_utils:coords_to_screen(v.x, v.y)
			if v.x ~= start_x or v.y ~= start_y then
				local sort = 0
				local position_to = vmath.vector3(x, y, 0)
				local result_collision = physics.raycast(go.get_position(), position_to, {hash("default")}, options)
				if result_collision then
					sort = sort + 10000
					
				end
				local dot = vmath.dot(dir, position_to - position)
				if dot > 0 then
					sort = sort + 100
				end
				--sort = sort + dot
				if self.to_point then
					print("sort_astar", sort, dir, position_to - position)
				end

				if not result_collision then
					table.insert(result, {
						position = position_to,
						sort = sort,
						collision = result_collision
					})
				end
			end
		end
	end

	if #result > 0 then
		table.sort(result, function (a, b)
			return a.sort > b.sort
		end)
		local position_to = result[1].position

		M.move_item(self, position_functions.go_get_perspective_z(position_to), handle)
	else
		if handle then
			timer.delay(1, false, handle)
		end
		sprite.set_hflip("#body", dir.x < 0)
	end
end

-- Передвиджение от точки
function M.move_random(self, max_cost, handle, dir)
	local dir = dir or self.dir or vmath.vector(-1, 0, 0)
	local position = go.get_position()
	local start_x, start_y = astar_utils:screen_to_coords(position.x, position.y)
	local max_cost = max_cost or 2

	-- Находим случайную плитку
	local near_result, near_size, nears = astar.solve_near(start_x, start_y, max_cost)

	-- Находим случайные координаты
	local coordinate_random
	if near_result == astar.SOLVED then
		-- Удаляем первую плитку
		table.remove(nears, 1)
		for i = #nears, 1, -1 do
			local item = nears[i]
			local x,y = astar_utils:coords_to_screen(item.x, item.y)

			-- Проверяем, есть ли коллизии 
			local left_position = vmath.vector3(x - 3, y - 3, 0)
			local right_position = vmath.vector3(x + 3, y + 3, 0)
			local result_collision = physics.raycast(left_position, right_position, {hash("default")}, options)
			
			if not result_collision then
				
				-- Нет коллизии, добавляем
				local position_to = vmath.vector3(x, y, 0)

				-- Смотрим направление
				if vmath.dot(dir, position_to - position) > 0 then
					nears[i].cost = nears[i].cost + 3
				end
				nears[i].position_to = position_to
			else
				table.remove(nears, i)
			end
		end
	end

	-- Сортируем
	table.sort(nears, function (a, b)
		return a.cost > b.cost
	end)

	if #nears > 6 then
		coordinate_random = nears[math.random(1,6)].position_to
	else
		coordinate_random = nears[math.random(1,#nears)].position_to
	end

	self.dir = vmath.normalize(coordinate_random - position)

	M.move_to_position(self, coordinate_random, handle, handle_error)
end

-- Пердвижение к точке
function M.move_item(self, position_to, handle)
	local position = go.get_position()

	local dir = position_to - position
	local len = vmath.length(dir)

	local duration = len / self.speed
	live_bar.position_to(self, position_to, duration)
	go.cancel_animations(".", "position")
	if self.timer_move_item then
		timer.cancel(self.timer_move_item)
		self.timer_move_item = nil
	end
	if len > 3 then
		-- Если есть слушатель
		go.animate(".", "position", go.PLAYBACK_ONCE_FORWARD, position_functions.go_get_perspective_z(position_to), go.EASING_LINEAR, duration, 0)
		self.timer_move_item = timer.delay(duration, false, handle)

		if self.handle_move_item then
			self.handle_move_item(self, position, position_to, duration, dir)
		end
	else
		position_functions.go_set_perspective_z(position_to)
		if handle then
			handle(self)
		end
	end

	character_animations.play(self, "move")
	sprite.set_hflip("#body", dir.x < 0)

	
end

-- Пердвижение к цели
--[[
handle_success(self) -- Цель достигнута
handle_error(self, error_code) -- Невозможно достигнуть цели
handle_no_object_target(self) -- Объект удалён из мира
--]]
function M.move_to_object(self, url, handle_success, handle_error, handle_no_object_target, handle_item_move)
	local position = go.get_position()

	if not go_controller.is_object(url) then
		-- Если объект удалён
		if handle_no_object_target then
			handle_no_object_target(self)
		end
		return
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
			--[[
			if handle_error then
				local error_code = path_size
				handle_error(self, error_code)
			end
			--]]
			M.move_item(self, self.target_position, handle_success)
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
					if handle_item_move then
						handle_item_move(self)
					end
					M.move_to_object(self, url, handle_success, handle_error, handle_no_object_target)
				end)
			end
		end
	end
end

-- Пердвижение к цели
--[[
handle_success(self) -- Цель достигнута
handle_error(self, error_code) -- Невозможно достигнуть цели
handle_no_object_target(self) -- Объект удалён из мира
--]]
function M.move_to_position(self, move_position_to, handle_success, handle_error)
	local position = go.get_position()

	local dir = move_position_to - position
	local distantion_magnite = 16
	local dist = vmath.length(dir)

	if dist == 0 then
		-- Объект на позиции
		if handle_success then
			handle_success(self)
		end

	elseif dist < distantion_magnite then
		-- Маленькое расстояние до цели
		M.move_item(self, move_position_to, handle_success)

	else
		local result, path_size, totalcost, path = astar_functions.get_path(self, move_position_to)

		if not result then
			-- Нет доступа к цели
			--[[
			if handle_error then
				local error_code = path_size
				handle_error(self, error_code)
			end
			]]--
			M.move_item(self, move_position_to, handle_success)
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
					if handle_item_move then
						handle_item_move(self)
					end
					M.move_to_position(self, move_position_to, handle_success, handle_error)
				end)
			end
		end
	end
end

-- Остановка движения
function M.stop(self)
	--go.cancel_animations(go.get_id(), "position")
	live_bar.update_position(self)

	go.cancel_animations(".", "position")

	if self.timer_check_distation_attack then
		timer.cancel(self.timer_check_distation_attack)
		self.timer_check_distation_attack = nil
	end

	-- Останавливаем движение
	if self.timer_move_item then
		timer.cancel(self.timer_move_item)
		self.timer_move_item = nil
	end
end

return M