-- Орда
local M = {}

M.start_radius = 13
M.start_angle = 35
M.add_step_radius = 12
M.add_step_angle = -20
M.interval_zombie = 20

-- Позиции для орды
M.positions = {}

-- Добавление зомбика в орду
function M.add_zombie_horde(self, skin_id, human_id, position)
	local position = position or M.get_position(self, go.get_position(), #self.horde + 1)
	local properties = {
		parent = msg.url(),
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

		self.target_add_horde = M.get_position(self, go.get_position(), #self.horde)
		character_zombie_main.change_horde(self)
		if self.command == hash("player") then
			M.move_horde_player(self)
		end
	end
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
				--[[
				-- Проверить В ту ли коллизию упёрся
				for i = 1, #result do
					local item_raycast_collision = result[i]
					if item_raycast_collision.id == collision_message.other_id then
						-- Если луч упёрся в ту коллизию
						--draw.line(self.position_center_horde, item_raycast_collision.position)
						position_to = position_functions.go_get_perspective_z(item_raycast_collision.position, item.url)

						is_collision = true
						break
					end
				end
				--]]
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

		-- Анимация ходьбы
		if self.animation_horde ~= self.last_animation_horde then
			sprite.play_flipbook(item.url_sprite, "zombie_"..item.skin_id.."_"..item.human_id .. "_run")
		end
	end
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

		-- АНимация
		if self.animation_horde ~= self.last_animation_horde then
			sprite.play_flipbook(item.url_sprite, "zombie_"..item.skin_id.."_"..item.human_id .. "_".. self.animation_horde)
		end
	end

	-- Анимация орды
	self.last_animation_horde = self.animation_horde
end


function M.on_update(self)
	-- УСтанавливаем расположение орды
	self.collisions_zombie = self.collisions_zombie or {}
	if self.movement and vmath.length(self.movement) > 0 then
		self.animation_horde = "run"
		M.move_horde_player(self)

	else
		self.animation_horde = "default"
		if self.animation_horde ~= self.last_animation_horde then
			for i = 1, #self.horde do
				local item = self.horde[i]
				-- Анимация покоя
				sprite.play_flipbook(item.url_sprite, "zombie_"..item.skin_id.."_"..item.human_id .. "_default")
			end
		end
	end
	self.last_animation_horde = self.animation_horde

	--[[
	for i = 1, #self.collisions_zombie do
		local item = self.collisions_zombie[i]

		if item.collision_physic then
			local collision_message =  item.collision_physic.message
			local storage_item = item.storage or {}
			position_functions.go_set_perspective_z(collision_message.position, item.url)
			item.collision_physic = nil
		end
		
	end
	--]]
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
function M.get_position(self, сenter_position, index_to_horde)
	local сenter_position = сenter_position or vmath.vector3(0)

	if M.positions[index_to_horde] then
		-- Если есть кешированный результат
		return сenter_position + M.positions[index_to_horde]
	else
		local center = vmath.vector3(0)
		local radius = M.start_radius 
		local interval = 15
		local current_angle = 0
		local row = 1
		local add_angle

		-- Точки вокруг
		for i = 1, index_to_horde do
			-- Находим угол
			if not add_angle then
				add_angle = M.get_angle_radius(radius, row)
			end

			if current_angle > 360 then
				current_angle = 0
				row = row + 1
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
			M.positions[i] = vmath.vector3(x, y, 0)
		end

		return сenter_position + M.positions[index_to_horde]

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

return M