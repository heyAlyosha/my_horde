-- Передвижение ботов
local M = {}

-- Добавление цели мобу
function M.add_target(self, url_target)
	local position = go.get_position()
	local key_target = go_controller.url_to_key(url_target)
	local target = storage_game.go_targets[key_target]

	if not go_controller.is_object(url_target) then
		return false
	end

	-- Ищем расположение
	local possible_targets = {}
	local position_target_object = go.get_position(url_target)
	for k, item in pairs(target.targets) do
		if item.is_move then
			possible_targets[#possible_targets+1] = {
				id = k,
				vector_target = item.vector_target, 
				sort = #item.characters * 1000 + vmath.length(item.position - position)
			}
		end
	end

	-- Сортируем по ценности 
	table.sort(possible_targets, function (a, b)
		return a.sort < b.sort
	end)

	if possible_targets[1] then
		self.target = url_target
		self.target_vector = possible_targets[1].vector_target
		self.target_id_point = possible_targets[1].id

		-- УВелличиваем кол-во нацеленных объектов
		storage_game.go_targets[key_target].targets[self.target_id_point].count_object = storage_game.go_targets[key_target].targets[self.target_id_point].count_object + 1
		storage_game.go_targets[key_target].target_current = storage_game.go_targets[key_target].target_current + 1

		-- Ссылка на атакующего персонажа
		table.insert(storage_game.go_targets[key_target].targets[self.target_id_point].characters, msg.url(go.get_id()))
		return true
	else
		return false
	end
end

-- Удаление цели
function M.delete_target(self, url_target)
	local key_target = go_controller.url_to_key(url_target)
	local target = storage_game.go_targets[key_target]

	if target then
		storage_game.go_targets[key_target].targets[self.target_id_point].count_object = storage_game.go_targets[key_target].targets[self.target_id_point].count_object - 1
		storage_game.go_targets[key_target].target_current = storage_game.go_targets[key_target].target_current -1

		-- Удаляем из массива объекта атакующего бота
		local url_key = go_controller.url_to_key(msg.url(go.get_id()))
		for i, url_attack_object in ipairs(storage_game.go_targets[key_target].targets[self.target_id_point].characters) do
			if url_key == go_controller.url_to_key(url_attack_object) then
				table.remove(storage_game.go_targets[key_target].targets[self.target_id_point].characters, i)
				break
			end
		end
	end

	self.target = nil
	self.target_vector = nil
	self.target_id_point = nil
end

-- Хватает дистанции для атаки
function M.check_distance_attack(self, url, handle_error)
	self.distantion_attack = self.distantion_attack or 0
	if not go_controller.is_object(url) then
		if handle_error then
			handle_error(self)
		end
	elseif vmath.length(go.get_position(url) - go.get_position()) <= self.distantion_attack then
		local result = physics.raycast(go.get_position(), go.get_position(url), {hash("default")}, options)
		return not result or #result == 0
	end

	return false
end


return M