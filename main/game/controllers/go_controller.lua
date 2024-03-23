-- КОнтроллер игровых объектов
local M = {}



-- Добавление go
function M.add(self)
	storage_game.go_urls[go.get_id()] = msg.url()
	storage_game.go_ids[msg.url(go.get_id())] = go.get_id()

	-- Существет ли объект
	local url_original = msg.url()
	local url = msg.url(url_original.socket, url_original.path, nil)
	storage_game.go_keys[M.url_to_key(url)] = msg.url()
	

	-- Объект - цель
	if self.targets and self.targets > 0 then
		storage_game.go_targets[M.url_to_key(url)] = {
			-- Сколько 
			target_max = self.targets,
			target_current = 0,
			target_dynamic = self.target_dynamic,
			target_useful = self.target_useful or 0,
			targets = {},
		}

		-- области вокруг объекта для атаки
		local target_item = storage_game.go_targets[M.url_to_key(url)]
		local position = go.get_position()
		--print(msg.url("map#map_core"))

		local map_url = go.get(storage_game.map.url_script, "map_url")

		for i = 1, self.targets do
			local rot = vmath.quat_rotation_z(3.141592563 * 2 / self.targets * i)
			local vec = vmath.rotate(rot, self.target_dist)

			local position_target =  position + vec

			-- Доступен ли для перемещения ботов
			local x, y = astar_utils:screen_to_coords(position_target.x, position_target.y)
			x = x + 1
			y = y + 1

			local tile = tilemap.get_tile(map_url, hash("move"), x, y)
			local is_move = tile ~= 0

			target_item.targets["target_"..i] = {
				count_object = 0,
				vector_target = vec,
				position = position_target,
				is_move = is_move,
				characters = {},
				x = x,
				y = y,
				tile = tile
			}
		end
	end
end

-- Удаление go
function M.delete(self)
	local url_key = M.url_to_key(msg.url(go.get_id()))

	storage_game.go_urls[go.get_id()] = nil
	storage_game.go_ids[msg.url(go.get_id())] = nil

	-- Существет ли объект
	local url_original = msg.url()
	local url = msg.url(url_original.socket, url_original.path, nil)
	storage_game.go_keys[url_key] = nil

	-- Объект - цель
	if self.targets and self.targets > 0 then
		local go_target = storage_game.go_targets[url_key]

		-- области вокруг объекта для атаки
		local target_item = storage_game.go_targets[url_key]
		for key, target_point in pairs(target_item.targets) do
			for i, url_object_attack in ipairs(target_point.characters) do
				-- Рассылаем сообщения, что объект удалён
				if M.is_object(url_object_attack) then
					msg.post(url_object_attack, "object_visible_kill")
				end
			end
		end
	end

	-- Удаляем видимый объект для ботов
	if self.group_name and self.group_id and self.visible_object_id then
		ai_vision.delete_object(self, self.group_name, self.visible_object_id)
	end

	live_bar.delete(self)
end

-- Записываем предметы объекта на карту
function M.object_items_spawn_to_map(self)
	-- Записываем предметы для карты
	local item_types = {"coins", "xp", "resource", "star"}

	for i, id_item in ipairs(item_types) do
		if self["spawn_"..id_item] and self["spawn_"..id_item] > 0 then
			storage_game.map["count_"..id_item] = storage_game.map["count_"..id_item] or 0
			storage_game.map["count_"..id_item] = storage_game.map["count_"..id_item] + self["spawn_"..id_item] 
		end
	end
end

-- Есть ли объект
function M.is_object(url)
	if not url then
		return false
	end
	url = M.url_object(url)

	return storage_game.go_keys[M.url_to_key(url)]
end

-- url в ключ для массива
function M.url_to_key(url)
	return hash_to_hex(url.socket or hash("")) .. hash_to_hex(url.path) .. hash_to_hex(url.fragment or hash(""))
end

-- Url без фрагмента
function M.url_object(url)
	return msg.url(url.socket, url.path, nil)
end

return M