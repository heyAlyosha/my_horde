-- функции для работы с массивами
local M = {}

function M.swap(array, index1, index2)
	array[index1], array[index2] = array[index2], array[index1]
end
-- Перемешивание массивов в случайно порядке
function M.shake(array)
	local counter = #array

	while counter > 1 do
		local index = math.random(counter)

		M.swap(array, index, counter)		
		counter = counter - 1
	end
end

return M