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
			targets = {},
		}

		-- области вокруг объекта для атаки
		local target_item = storage_game.go_targets[M.url_to_key(url)]
		local position = go.get_position()
		local map_url = go.get(msg.url("map#map_core"), "map_url")

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

-- Добавление go
function M.delete(self)
	storage_game.go_urls[go.get_id()] = nil
	storage_game.go_ids[msg.url(go.get_id())] = nil

	-- Существет ли объект
	local url_original = msg.url()
	local url = msg.url(url_original.socket, url_original.path, nil)
	storage_game.go_keys[M.url_to_key(url)] = nil
end

-- Есть ли объект
function M.is_object(url)
	return storage_game.go_keys[M.url_to_key(url)]
end

-- url в ключ для массива
function M.url_to_key(url)
	return hash_to_hex(url.socket or hash("")) .. hash_to_hex(url.path) .. hash_to_hex(url.fragment or hash(""))
end

-- Url объекта
function M.url_object(url)
	return msg.url(url.socket, url.path, nil)
end

return M