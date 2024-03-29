-- Передвижение ботов
local M = {}

-- Добавление цели мобу
function M.is_target(self)
	return self.target ~= nil or self.target ~= false
end

-- Добавление цели мобу
function M.add_target(self, url_target)
	local position = go.get_position()
	local key_target = go_controller.url_to_key(url_target)
	local target = storage_game.go_targets[key_target]

	if not go_controller.is_object(url_target) then
		return false
	end

	if self.target then
		M.delete_target(self, self.target)
	end

	-- Ищем расположение
	local possible_targets = {}
	local position_target_object = go.get_position(url_target)

	if not target.target_dynamic then
		-- Если цель стоит на месте
		for k, item in pairs(target.targets) do
			if item.is_move then
				possible_targets[#possible_targets+1] = {
					id = k,
					vector_target = item.vector_target, 
					sort = #item.characters * 1000 + vmath.length(item.position - position)
				}
			end
		end
	else
		-- Если цель двигается
		for k, item in pairs(target.targets) do
			if item.is_move then
				-- Если цель стоит на месте
				local dir = position_target_object + item.vector_target - position
				local result = physics.raycast(position_target_object, position_target_object + item.vector_target, {hash("default")}, options)
				local sort = #item.characters * 1000 + vmath.length(dir)

				if result then
					sort = sort + 10000
				end
				
				possible_targets[#possible_targets+1] = {
					id = k,
					vector_target = item.vector_target, 
					sort = sort
				}
			end
		end
	end

	-- Сортируем по ценности 
	table.sort(possible_targets, function (a, b)
		return a.sort < b.sort
	end)

	if possible_targets[1] then
		self.target = url_target
		self.target_current_useful = target.target_useful
		self.target_vector = possible_targets[1].vector_target
		self.target_id_point = possible_targets[1].id

		-- УВелличиваем кол-во нацеленных объектов
		storage_game.go_targets[key_target].targets[self.target_id_point].count_object = storage_game.go_targets[key_target].targets[self.target_id_point].count_object + 1
		storage_game.go_targets[key_target].target_current = storage_game.go_targets[key_target].target_current + 1

		-- Ссылка на атакующего персонажа
		table.insert(storage_game.go_targets[key_target].targets[self.target_id_point].characters, msg.url(go.get_id()))

		-- Если динамическая цель
		if target.target_dynamic then
			local url_script = go_controller.url_script(self.target)
			--local enemy_target = go.get(url_script, "target")

			local status, enemy_target = pcall(go.get,url_script, "target");

			-- Если у противника другая цель, меняем её
			if status and go_controller.url_to_key() ~= go_controller.url_to_key(enemy_target) then
				--msg.post(self.target, "add_target", {target = go_controller.url_object()})
			end
		end
		return true
	else
		return false
	end
end

-- Удаление цели
function M.delete_target(self, url_target)
	local key_target = go_controller.url_to_key(url_target)
	local target = storage_game.go_targets[key_target]

	if target and go_controller.is_object(target) then
		if self.target_id_point then
			storage_game.go_targets[key_target].targets[self.target_id_point].count_object = storage_game.go_targets[key_target].targets[self.target_id_point].count_object - 1
		end
		storage_game.go_targets[key_target].target_current = storage_game.go_targets[key_target].target_current -1

		-- Удаляем из массива объекта атакующего бота
		if self.target_id_point then
			local url_key = go_controller.url_to_key(msg.url(go.get_id()))
			for i, url_attack_object in ipairs(storage_game.go_targets[key_target].targets[self.target_id_point].characters) do
				if url_key == go_controller.url_to_key(url_attack_object) then
					table.remove(storage_game.go_targets[key_target].targets[self.target_id_point].characters, i)
					break
				end
			end
		end
	end

	self.target = nil
	self.target_vector = nil
	self.target_id_point = nil
	self.target_current_userful = nil
end

-- Хватает дистанции для атаки
function M.check_distance_attack(self, url, handle_error)
	self.distantion_attack = self.distantion_attack or 0
	local target_vector = self.target_vector or vmath.vector3(0)
	if not go_controller.is_object(url) then
		if handle_error then
			handle_error(self)
		end

	elseif vmath.length(go.get_position(url) + target_vector - go.get_position()) <= self.distantion_attack then
		local result = physics.raycast(go.get_position(), go.get_position(url), {hash("default")}, options)
		return not result or #result == 0

	end

	return false
end


return M