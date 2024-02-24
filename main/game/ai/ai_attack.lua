-- Передвижение ботов
local M = {}

-- Добавление цели мобу
function M.add_target(self, url_target)
	local position = go.get_position()
	local target = storage_game.go_targets[go_controller.url_to_key(url_target)]

	-- Ищем расположение
	local possible_targets = {}
	local position_target_object = go.get_position(url_target)
	
	for k, item in pairs(target.targets) do
		possible_targets[#possible_targets+1] = {
			id = k,
			vector_target = item.vector_target, 
			sort = #item.characters * 1000 + vmath.length(item.position - position)
		}
	end
	--pprint("possible_targets", possible_targets)

	-- Сортируем по ценности 
	table.sort(possible_targets, function (a, b)
		return a.sort < b.sort
	end)

	self.target = url_target
	self.target_vector = possible_targets[1].vector_target

	pprint(target.targets[possible_targets[1].id])
	table.insert(target.targets[possible_targets[1].id].characters, msg.url())
end

-- Пердвижение к точке
function M.move_to_attack(self, position_to, handle)
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

	self.target_position = go.get_position(url)

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
				local error_code = result.path_size
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



return M