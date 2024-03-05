-- Глобальная функция
local M = {}

-- Формрует ассоциативный объект по id из массива
function M.render_keys(Module, array)
	if not Module._keys or #Module._keys == 0 then
		for i, item in ipairs(array) do
			Module._keys[item.id] = item
		end
	end

	return Module._keys
end

-- ПУстая таблица
function M.is_empty(table)
	local empty_table = true

	for k, v in pairs(table) do
		empty_table = false
		break
	end

	return empty_table
end

return M 