-- Орда
local M = {}

M.start_radius = 20
M.start_angle = 35
M.add_step_radius = 12
M.add_step_angle = -20
M.interval_zombie = 20

-- Позиции для орды
M.positions = {}
-- Позиции для кругового вращения
M.positions_circle = {}

-- Добавление зомбика в орду
function M.add_zombie_horde(self, skin_id, human_id, position)
	local position = position or M.get_position(self, go.get_position(), #self.horde + 1)
	local properties = {
		parent = msg.url(),
		command = self.command,
		skin_id = skin_id,
		human_id = human_id,
	}

	if self.max_horde == 0 or self.size_horde < self.max_horde then
		local id = factory.create("#zombie_horde_factory", position, rotation, properties)
		self.horde[#self.horde + 1] = {
			id = id,
			url = msg.url(id),
			url_script = msg.url(nil, id, "script"),
			url_sprite = msg.url(nil, id, "body"),
			skin_id = skin_id,
			human_id = human_id,
		}

		self.animation_horde = self.animation_horde or "default"
		M.set_animation_item(self, self.horde[#self.horde], self.animation_horde)

		self.target_add_horde = M.get_position(self, go.get_position(), #self.horde)
		character_zombie_main.change_horde(self)
		if not self.is_circle_horde and self.command == hash("player") then
			-- Обычная орда
			M.move_horde_player(self)
		elseif self.is_circle_horde then 
			
		end

		M.compile(self)
	end
end

-- Добавление атакующего зомбика
function M.add_zombie_attack(self, horde_index, position, target, message)
	local position = position or go.get_position(item.url)
	local url_key

	if horde_index and self.horde[horde_index] then
		-- Из орды
		local item = self.horde[horde_index]

		-- Удаляем зомбика из орды
		table.remove(self.horde, horde_index)
		go.delete(item.url)

		local properties = {
			command = self.command,
			skin_id = item.skin_id,
			human_id = item.human_id,
			parent = msg.url(go.get_id()),
			target = target,
			position_horde = horde.get_position(self, nil, horde_index)
		}
		local go_id = factory.create("#zombie_factory", position, rotation, properties)
		local url = msg.url(go_id)
		url_key = go_controller.url_to_key(url)
		self.zombies[url_key] = {
			id = go_id,
			url = url,
			url_script = msg.url(nil, go_id, "script"),
			url_sprite = msg.url(nil, go_id, "body"),
			skin_id = item.skin_id,
			human_id = item.human_id,
		}
	else
		-- Из сообщения
		local properties = {
			command = self.command,
			skin_id = message.skin_id or self.skin_id,
			human_id = message.human_id or 0,
			parent = msg.url(go.get_id()),
			target = target,
			position_horde = horde.get_position(self, nil, self.size_horde + 1)
		}
		local go_id = factory.create("#zombie_factory", position, rotation, properties)
		local url = msg.url(go_id)
		url_key = go_controller.url_to_key(url)
		self.zombies[url_key] = {
			id = go_id,
			url = url,
			url_script = msg.url(nil, go_id, "script"),
			url_sprite = msg.url(nil, go_id, "body"),
			skin_id = message.skin_id or self.skin_id,
			human_id = message.human_id or 0
		}
	end

	character_zombie_main.change_horde(self)

	return self.zombies[url_key]
end

-- СОбрать орду вокруг игрока
function M.compile(self)
	for i, zombie_horde in ipairs(self.horde) do
		local position, vector, row, row_i = M.get_position(self, go.get_position(), i)

		zombie_horde.vector = vector
		zombie_horde.row = row
		zombie_horde.row_i = row_i
	end
end

-- Уничтожение зомби в орде
function M.delete_zombie_horde(self, index, effect_dead)
	local item = self.horde[index]

	-- Удаляем зомбика из орды
	if item then
		table.remove(self.horde, index)

		if effect_dead then
			msg.post(storage_game.map.url_script, "effect", {
				position = go.get_position(item.url),
				animation_id = hash("effect_zombie_death"), 
				timer_delete = 3
			})
		end

		go.delete(item.url)
		character_zombie_main.change_horde(self)
	end
end

-- УСтановка анимации для орды
function M.set_animation_horde(self, animation_id)
	-- Анимация ходьбы
	if self.animation_horde ~= animation_id then
		for i, item in ipairs(self.horde) do
			if item.animation_id ~= animation_id then
				
				M.set_animation_item(self, item, animation_id)
			end
		end
	end

	self.animation_horde = animation_id
end

-- УСтановка анимации для орды
function M.set_animation_item(self, zombie, animation_id)
	-- Анимация ходьбы
	local no_old = false
	local live = go.get(zombie.url_script, "live")
	local max_live = self.zombie_live
	local animation = game_content_skins.play_flipbook(self, zombie.url_sprite, zombie.skin_id, zombie.human_id, animation_id, no_old, live, max_live)
	zombie.animation_id = animation_id
end

-- Передвижение орды игрока
function M.move_horde_player(self)
	for i = 1, #self.horde do
		local item = self.horde[i]

		local position_to
		local position = M.get_position(self, self.position_center_horde, i)

		if item.id and storage_game.go_objects[item.id].collision_physic then
			-- Если есть коллизии столкновений
			local collision_message =  storage_game.go_objects[item.id].collision_physic.message
			local storage_item = storage_game.go_objects[item.id].storage or {}

			--local options = {all = true}
			local result = physics.raycast(self.position_center_horde, position, {hash("default")}, options)
			if result then
				-- Смотрим в тот ли объект уткается  луч
				local is_collision = true
				position_to = position_functions.go_get_perspective_z(result.position, item.url)

				if not is_collision then
					-- Столкновения луча не подходят
					position_to = position_functions.go_get_perspective_z(position, item.url)
				end

			else
				position_to = position_functions.go_get_perspective_z(position, item.url)
				storage_game.go_objects[item.id].collision_physic = nil
			end
		else
			-- Не столкновений
			position_to = position_functions.go_get_perspective_z(position, item.url)
		end

		-- Определяем расстояние
		local dir = go.get_position(item.url) - position_to
		local length = vmath.length(dir)

		if not item.animate_position_to then
			if length < 3 then
				-- Маленькое расстояние, просто перемещаем
				go.set_position(position_to, item.url)
			else
				-- Большое расстояние, анимируем
				item.animate_position_to = true
				local speed = 75
				local duration = length / speed
				go.animate(item.url, "position", go.PLAYBACK_ONCE_FORWARD, position_to, gui.EASING_LINEAR, duration, 0, function (self)
					item.animate_position_to = nil
				end)
			end
		end

		storage_game.go_objects[item.id].collision_physic = nil

		-- Поворачиваем в сторону игрока
		sprite.set_hflip(item.url_sprite, self.movement.x < 0)
	end

	M.set_animation_horde(self, "run")
end



-- Передвижение орды бота
function M.move_horde_bot(self, position_to, duration, dir)
	local dist = vmath.length(position_to - go.get_position())
	if dist > 0 then
		self.animation_horde = "run"
	else
		self.animation_horde = "default"
	end

	for i = 1, #self.horde do
		local item = self.horde[i]

		local position = go.get_position(item.url)
		local position_zombie_to = M.get_position(self, position_to, i)

		local result = physics.raycast(position_to, position_zombie_to, {hash("default")}, options)
		-- Есть столкновения
		if result then
			position_zombie_to = result.position
		end
		position_zombie_to = position_functions.go_get_perspective_z(position_zombie_to, item.url)

		dir = dir or vmath.normalize(position_zombie_to - position)
		duration = duration or vmath.length(position_zombie_to - position) / 75

		sprite.set_hflip(item.url_sprite, dir.x < 0)

		--go.cancel_animations(item.url, "position")
		go.animate(item.url, "position", go.PLAYBACK_ONCE_FORWARD, position_zombie_to, gui.EASING_LINEAR, duration)
	end

	-- Анимация
	if self.animation_horde ~= self.last_animation_horde then
		M.set_animation_horde(self, self.animation_horde)
	end

	-- Анимация орды
	self.last_animation_horde = self.animation_horde
end




function M.on_update(self)
	-- УСтанавливаем расположение орды
	self.collisions_zombie = self.collisions_zombie or {}
	if self.movement and vmath.length(self.movement) > 0 then
		M.move_horde_player(self)
		M.set_animation_horde(self, "run")

	else
		M.set_animation_horde(self, "default")

	end
	self.last_animation_horde = self.animation_horde
end

-- Получение угла, основываясь
function M.get_angle_radius(radius, row)
	-- Стартовая точка
	local point_start_radius = vmath.vector3(0)
	point_start_radius.y = point_start_radius.y + radius + M.add_step_radius * (row - 1)

	-- Следующая точка с заданным
	local point_next_radius = vmath.vector3(point_start_radius.x + M.interval_zombie, point_start_radius.y, 0)

	-- Угол между этими векторами
	local ans = math.acos(vmath.dot(point_start_radius, point_next_radius) / (vmath.length(point_start_radius) * vmath.length(point_next_radius)))
	return math.deg(ans)
end

-- Получение позиции для расположения зомбика
--return position, vector, row, row_i
function M.get_position(self, сenter_position, index_to_horde)
	local сenter_position = сenter_position or vmath.vector3(0)

	if M.positions[index_to_horde] then
		-- Если есть кешированный результат
		return сenter_position + M.positions[index_to_horde].vector, M.positions[index_to_horde].vector, M.positions[index_to_horde].row, M.positions[index_to_horde].row_i
	else
		local center = vmath.vector3(0)
		local radius = M.start_radius 
		local interval = 15
		local current_angle = 0
		local row = 1
		local row_i = 1
		local add_angle

		-- Точки вокруг
		for i = 1, index_to_horde do
			-- Находим угол
			if not add_angle then
				add_angle = M.get_angle_radius(radius, row)
			end

			if current_angle > 355 then
				current_angle = 0
				row = row + 1
				row_i = 1
				add_angle = M.get_angle_radius(radius, row)
			end

			local point_item = vmath.vector3(0)
			point_item.y = point_item.y + radius + M.add_step_radius * 0.7 * (row - 1)

			local dir = center - point_item
			current_angle = current_angle + add_angle

			x = dir.x*math.cos(math.rad(current_angle)) - dir.y*math.sin(math.rad(current_angle))
			y = dir.y*math.cos(math.rad(current_angle)) + dir.x*math.sin(math.rad(current_angle))

			-- Добавляем небольшой рандом
			math.randomseed(i)
			x = x + math.random(-2, 2)
			y = y + math.random(-2, 2) - 3

			-- Сохраняем позиции
			M.positions[i] = {
				vector = vmath.vector3(x, y, 0),
				row = row,
				row_i = row_i,
				dist_center = vmath.length(vmath.vector3(x, y, 0))
			}
			-- Сохраняем позиции для кругового вращения
			M.positions_circle[row] = M.positions_circle[row] or {}
			M.positions_circle[row][row_i] = M.positions[i].vector

			-- Увеличиваем место в ряду 
			row_i = row_i + 1
		end

		return сenter_position + M.positions[index_to_horde].vector, M.positions[index_to_horde].vector, M.positions[index_to_horde].row, M.positions[index_to_horde].row_i
	end
end

-- Дистанция для добавления в орду
function M.check_distantion_add_horde(self, parent, position_from, position_parent)
	local target_add_horde = go.get(msg.url(parent.socket, parent.path, "script"), "target_add_horde")
	
	local position_parent = position_parent or go.get_position(parent)
	local position_from = position_from or go.get_position()

	local dist_add_horde = vmath.length(target_add_horde - position_parent) + 10
	local dist_to_parent = vmath.length(position_from - position_parent)

	return dist_to_parent <= dist_add_horde
end

-- Убить всех зомбиков
function M.killing_all(self)
	for index, zombie in ipairs(self.horde) do
		if zombie.url.path == url_zombie.path then
			horde.delete_zombie_horde(self, index, true)
			break
		end
	end

	for k, zombie in pairs(self.zombies) do
		msg.post(zombie.url, "killing")
	end
end

return M