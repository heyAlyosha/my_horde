-- Функции для переключателя влево - вправо
local M = {}

-- Пролистываем 
function M.listen(self, id, current_value, array_values, function_change)
	local add_index = 1

	-- Смотрим в какую сторону листать массив
	if id == "left" then
		add_index = -1
	elseif id == "right" then
		add_index = 1
	else
		add_index = 0
	end

	-- ищем текущую позицию цвета
	local current_index = 0
	for i = 1, #array_values do
		local item = array_values[i]

		if item == current_value then
			current_index = i
			break
		end
	end

	-- ищем следующую позицию
	local next_index = current_index + add_index

	-- смотрим есть ли она
	if next_index > #array_values then
		next_index = 1
	elseif next_index < 1 then
		next_index = #array_values
	end

	current_value = array_values[next_index]

	if function_change then
		function_change(self, current_value, next_index)
	end

	return current_value
end

return M