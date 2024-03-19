local storage_player = require "main.storage.storage_player"
local api_player = require "main.game.api.api_player"
local game_content_functions = require "main.game.content.modules.game_content_functions"

-- Информация про достижения
local M = {}
M.catalog_keys = {}
M.catalog = {}

function M.init(self)
	local is_replace_placeholder = false
	M.catalog_keys = game_content_functions.load_content(self, "achieve", group_columns, function (self, row_id, item)
		item.value = {
			stars = item.stars,
			dop_id = item.dop_id,
			dop_type = item.dop_type
		}

		item.title_id_string = string.gsub(item.title_id_string, "{{id}}", row_id)
		item.description_id_string = string.gsub(item.description_id_string, "{{id}}", row_id)
	end, is_replace_placeholder)
	M.catalog = game_content_functions.create_catalog(self, "sort", M.catalog_keys, sort_function)
end

-- Получение данных для артефактов
function M.get_catalog(self, core_achieve_functions)
	local result = {}

	for i, item in ipairs(M.catalog) do
		local item =  M.get_item(item.id, core_achieve_functions)

		result[#result + 1] = item
	end

	return result
end

function M.get_item(id, core_achieve_functions)
	local item = M.catalog_keys[id]
	if not item then
		return false
	else
		-- Находим прогресс и прохождение 
		local count = 0
		local success = false

		-- Получаем прогресс ачивки
		if core_achieve_functions then
			local progress = core_achieve_functions.get_progress(id)

			count = progress.achieve_progress
			success = progress.status
		end

		-- Еслит ачивка получена - ставим 
		if success then
			count = item.count
		end

		local result = item

		if not result.max_count then
			local max_count = item.count
			result.max_count = max_count
		end
		result.count = count
		result.success = success

		return result
	end
end

return M