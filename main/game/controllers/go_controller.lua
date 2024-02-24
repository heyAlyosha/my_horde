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