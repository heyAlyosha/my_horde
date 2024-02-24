-- функции для позиции
local M = {}

-- Получение z перспективы
function M.get_perspective_z(y)
	return (storage_game.map_settings.size.y - y) / 1000
end


function M.add_perspective_z(position)
	position.z = position.z + M.get_perspective_z(position.y)
	return position
end

function M.go_set_perspective_z(position, url)
	position = position or go.get_position()
	position.z = M.get_perspective_z(position.y)
	go.set_position(position, url)

	return position
end

function M.go_get_perspective_z(position)
	position = position or go.get_position()
	position.z = M.get_perspective_z(position.y)
	return position
end

return M