-- Функции для работы с игровым текстовым контентом
local M = {}

local csv = require "main.modules.csv"

-- Загрузка контента
function M.load_content(self, csv_name, group_columns, function_render_row, is_replace_placeholder)
	-- Контент из csv файла
	local config_id = csv_name
	local separator = ";"
	csv.load(config_id, "/main/game/csv/"..csv_name..".csv", separator)
	local matrix = csv.get_matrix(config_id)

	-- Нужно ли заменять плейсхолдеры
	if is_replace_placeholder == nil then
		is_replace_placeholder = true
	end

	for row_id, row_item in pairs(matrix) do
		for item_key, item_value in pairs(row_item) do
			-- Если есть плейсхолдер id
			if is_replace_placeholder and type(item_value) == "string" and string.find(item_value, "{{id}}") then
				matrix[row_id][item_key] = string.gsub(item_value, "{{id}}", row_id)
			end

			if item_value == "false" then
				item_value = false
				matrix[row_id][item_key] = false
			end

			-- Группируем колонки, если надо
			if group_columns and group_columns[item_key] then
				local from_item = item_value
				local to_key = group_columns[item_key]

				row_item[to_key] = row_item[to_key] or {}
				row_item[to_key][item_key] = item_value
			end
		end

		if function_render_row then
			function_render_row(self, row_id, matrix[row_id])
		else
			matrix[row_id].id = row_id
		end
	end

	return matrix
end

-- Получение строк
function M.get_rows(self, csv_name, function_render_row)
	local result = csv.get_matrix(csv_name)

	for i = 1, result do
		if function_render_row then
			local row_id = i
			local row_item = result[i]

			function_render_row(self, row_id, row_item)
		end
	end
end

-- Создание отсортированного каталога
function M.create_catalog(self, sort_key, array_keys, sort_function)
	local result = {}
	for k, v in pairs(array_keys) do
		v.id = k
		table.insert(result, v)
	end

	if sort_function then
		table.sort(result, sort_function)

	else
		table.sort(result, function (a, b)
			return a[sort_key] > b[sort_key]
		end)
	end

	return result
end

return M