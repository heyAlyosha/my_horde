-- Храним контент для категорий вопроса
local M = {}

local game_content_functions = require "main.game.content.modules.game_content_functions"
local core_prorgress = require "main.core.core_progress.core_prorgress"

M.catalog = {}

-- Компании по ключу
M.catalog_keys = {}
M.quests_content = {}
M.quests_tournir = {}

function M.init(self)
	local is_replace_placeholder = false
	game_content_functions.load_content(self, "company", group_columns, function (self, row_id, row_item)
		local item = row_item
		item.id = row_id
		item.levels = {}

		M.catalog_keys[row_id] = item
	end, is_replace_placeholder)

	M.catalog = game_content_functions.create_catalog(self, "sort", M.catalog_keys, sort_function)

	-- Закачиваем уровни
	game_content_functions.load_content(self, "levels", group_columns, function (self, row_id, row_item)
		local item = row_item

		if M.catalog_keys[item.company_id] then
			M.catalog_keys[item.company_id].levels = M.catalog_keys[item.company_id].levels or {}
			-- Загружаем отдельный уровень
			M.catalog_keys[item.company_id].levels[item.id] = {
				id = item.id,
				collection_id = item.collection_id
			}
		end
	end, is_replace_placeholder)
end

-- Получение всех компаний игрока
function M.get_all(user_lang)
	local default_lang = "ru"
	local lang = user_lang or "ru"
	local result = {}

	for i = 1, #M.catalog do
		result[#result + 1] = M.get_id(M.catalog[i].id, user_lang)

	end

	return result
end

-- Получение компании по id
function M.get_id(id, user_lang)
	local lang = user_lang or "ru"
	local item = M.catalog_keys[id]
	local levels = #item.levels
	local progress_all = levels
	local progress_count = 0
	local status = "default"

	-- НАходим прогресс категории
	local levels_complexity = core_prorgress.get_progress_category(id)
	for level_id, level in pairs(levels_complexity) do
		progress_count = progress_count + 1
	end

	-- забираем значение по ключу
	if progress_count == progress_all then
		status = "success"
	end

	item.progress_all = progress_all
	item.progress_count = progress_count
	item.status = status

	return item
end

return M