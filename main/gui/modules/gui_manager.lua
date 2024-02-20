local storage_gui = require "main.storage.storage_gui"
-- Работа с окнами скринов
local M = {}

-- Добавление гуи экрана
function M.add_screen(id, url)
	--local id = msg.url().fragment
	local id = storage_gui.components_visible_hash_to_id[msg.url().fragment]
	storage_gui.components_visible[id] = url

	table.insert(storage_gui.components_gui, 1, url)
end

-- Добавление гуи экрана
function M.remove_screen(url)
	local id = msg.url().fragment
	storage_gui.components_visible[id] = nil

	for i = #storage_gui.components_gui, 1, -1 do
		if  storage_gui.components_gui[i] == url then
			table.remove(storage_gui.components_gui, i)
		end
	end
end

-- Получение id гуи экрана
function M.get_screen_id(url)
	for id, item in pairs(storage_gui.components_visible) do
		if item == url then
			return id
		end
	end

	return false
end

return M