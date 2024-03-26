-- Модуль атаки орды
local M = {}

function M.visible(self, visible_items)
	local change_visible = false
	self.target_objects = self.target_objects or {}
	self.target_objects_useful = self.target_objects_useful or 0
	-- Итерация просмотра для определения устревших 
	self.iteration_visible_objects = self.iteration_visible_objects or 0
	self.iteration_visible_objects = self.iteration_visible_objects + 1

	if visible_items then
		-- Сортируем
		table.sort(visible_items, function (a, b)
			return a.target_useful > b.target_useful
		end)

		-- Проходимся по целям в зоне видимости
		self.target_objects_useful = visible_items[1].target_useful
		for i = 1, #visible_items do
			local item = visible_items[i]
			if item.target_useful < self.target_objects_useful then
				-- Убераем менее ценную цель
				visible_items[i] = nil
			else
				-- Была ли уже цель в обзоре орды
				local key_target = go_controller.url_to_key(item.url)
				if not self.target_objects[key_target] then
					M.add_target(self, key_target, item)
					change_visible = true
				end

				self.target_objects[key_target].iteration_visible_objects = self.iteration_visible_objects
			end
		end
	end

	-- Смотрим устаревшие
	for key_target, item in pairs(self.target_objects) do
		if item.iteration_visible_objects ~= self.iteration_visible_objects then
			M.delete_target(self, key_target, item)
		end
	end

	if change_visible then
		M.horde_attack(self)
	end
end

-- Добавление цели для орды
function M.add_target(self, key_target, item)
	self.target_objects[key_target] = {
		key_target = key_target,
		url = item.url,
		target_useful = item.target_useful,
		iteration_visible_objects = self.iteration_visible_objects or 0,
		targets_count = 0,
		enemies = {}
	}
end

-- Удаление цели
function M.delete_target(self, key_target, item)
	self.target_objects[key_target] = nil
end

-- Цели по зомбикам на них
function M.get_targets_sort(self)
	local result = {}

	for k, item in pairs(self.target_objects) do
		result[#result + 1] = item
	end

	table.sort(result, function (a, b)
		return a.targets_count > b.targets_count
	end)

	return result
end

-- Атака орды
function M.horde_attack(self)
	local targets = M.get_targets_sort(self)

	local index_target = #targets
	-- Зомбики из орды
	for horde_index = #self.horde, 1, -1 do
		local item = self.horde[horde_index]
		local target_item = targets[index_target]
		local position_zombie = go.get_position(item.url)
		local zombie = character_zombie_main.add_zombie_attack(self, horde_index, position_zombie, target_item.url)

		M.add_zombie_target(self, zombie, target_item)

		index_target = index_target - 1
		if index_target < 1 then
			index_target = #targets
		end
	end

	-- Обычные зомбики
	for k, zombie in pairs(self.zombies) do
		local target_item = targets[index_target]

		M.add_zombie_target(self, zombie, target_item)

		index_target = index_target - 1
		if index_target < 1 then
			index_target = #targets
		end
	end
end

-- Добавление цели зомбику
function M.add_zombie_target(self, zombie, target)
	-- Если у зомбика уже была цель
	if zombie.target_key then
		M.delete_zombie_target(self, zombie)
	end

	table.insert(target.enemies, zombie.url)
	target.targets_count = #target.enemies

	-- Если это первая цель, записываем ему
	if #target.enemies == 1 then
		msg.post(target.url, "add_target", {target = zombie.url})
	end

	msg.post(zombie.url, "add_target", {target = target.url})
	zombie.target_key = target.key
end

-- Удаление цели зомбику
function M.delete_zombie_target(self, zombie)
	local target = self.target_objects[zombie.target_key]
	for i, url_zombie in ipairs(target.enemies) do
		if go_controller.url_to_key(url_zombie) == go_controller.url_to_key(zombie.url) then
			table.remove(target.enemies, i)
		end
	end
	target.targets_count = #target.enemies
	zombie.target_key = nil

	-- Если это первая цель, записываем ему
	if #target.enemies > 0 then
		msg.post(target.url, "add_target", {target = target.enemies[1]})
	end
end

return M