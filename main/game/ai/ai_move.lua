-- Передвижение ботов
local M = {}

-- Передвиджение от точки
function M.move_item_from(self, position_from, handle, speed)
	local position = go.get_position()
	local dir = (position_from - position) * (-1)

	local start_x, start_y = astar_utils:screen_to_coords(position.x, position.y)
	local max_cost = 1 -- near

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
					sort = sort - 100
				end
				local dot = vmath.dot(dir, position_to - position) * 0.00001
				sort = sort + dot
				--print("sort", sort, result_collision)
				table.insert(result, {
					position = position_to,
					sort = sort,
					collision = result_collision
				})
			end
		end
	end

	if #result > 0 then
		table.sort(result, function (a, b)
			return a.sort > b.sort
		end)
		local position_to = result[1].position

		--pprint(result, "-----------------")

		M.move_item(self, position_functions.go_get_perspective_z(position_to), handle)
	else
		if handle then
			handle(self)
		end
		sprite.set_hflip("#body", dir.x < 0)
	end
end

-- Пердвижение к точке
function M.move_item(self, position_to, handle)
	local position = go.get_position()

	local dir = position_to - position
	local len = vmath.length(dir)

	local duration = len / self.speed
	live_bar.position_to(self, position_to, duration)
	go.cancel_animations(".", "position")
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
			print(self.target_position, self.target_vector)
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
					M.move_to_object(self, url, handle_success, handle_error)
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

	if self.timer_check_distation_attack then
		timer.cancel(self.timer_check_distation_attack)
		self.timer_check_distation_attack = nil
	end
end

return M