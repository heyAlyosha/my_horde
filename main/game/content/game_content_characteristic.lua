local storage_player = require "main.storage.storage_player"

local game_content_functions = require "main.game.content.modules.game_content_functions"

-- Информация про ботов
local M = {}
M.catalog_keys = {}
M.catalog = {}

-- Получение отдельного
function M.init(self)
	local is_replace_placeholder = false
	M.catalog_keys = game_content_functions.load_content(self, "characteristic", group_columns, function_render_row, is_replace_placeholder)
	M.catalog = game_content_functions.create_catalog(self, "sort", M.catalog_keys)
end

-- Кешируем
function M.create_cache()
	-- Если нет ключей каталога - кэшируем их
	if #M.catalog_keys < 1 then
		for i = 1, #M.catalog do
			local item = M.catalog[i]
			M.catalog_keys[item.id] = item
		end
	end
end

-- Получение отдельного
function M.get_id(self, id)
	-- Находим элемент
	local item = M.catalog_keys[id]

	if not item then
		return false
	end

	-- Получаем характеристики игрока
	local characteristics = storage_player.characteristics
	item.start_value = item.start_value or 0
	item.level = characteristics[id] or 0
	item.buff = M.get_buff(self, item.id, item.level)

	-- Определяем данные для следующего уровня
	item.next_level = item.level + 1
	if item.next_level > 10 then
		item.next_level = false
		item.next_buff = false
	else
		item.next_level = item.next_level
		item.next_buff = M.get_buff(self, item.id, item.next_level)
	end

	return item
end

function M.get_all(self)
	local result = {}

	for i, item in ipairs(M.catalog) do
		result[i] = M.get_id(self, item.id)
	end

	return result
end

-- Получение баффа
function M.get_buff(self, id, level)
	local level = level or  0

	local item = M.catalog_keys[id]
	if item then
		item.start_value = item.start_value or 0

		return item.start_value + level * item.step
	else
		return 0
	end
end

return M