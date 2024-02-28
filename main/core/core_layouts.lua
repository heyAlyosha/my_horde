-- УПравление компоновками игры
local M = {}

local storage_game = require "main.game.storage.storage_game"

M.layout = {
	id = "",
	data = {},
}

-- Очистка данных
function M.clear_data()
	M.layout = {
		id = "",
		data = {},
	}
end

-- Запись данных
function M.set_data(id, data)
	M.layout = M.layout or {}
	data = data or {}

	if M.layout.id ~= id then
		-- Если это другой лаяут, перезаписываем
		M.layout.id = id
		M.layout.data = data or {}
	else
		-- Если это тот же самый, то переписываем только данные 
		for key, item in pairs(data) do
			M.layout.data[key] = item
		end
	end
end

function M.get_data()
	return {
		id = M.layout.id or  "",
		data = M.layout.data or  {},
	}
end

return M