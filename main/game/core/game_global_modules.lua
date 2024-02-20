-- Глобальные переменные
local M = {}

M.game_content_wheel = require "main.game.content.game_content_wheel"


-- Получить новые уровни, которые игрок ещё не видел
function M.get_new_levels(self, array_levels, array_visible_levels)
	local result = {}
	local all_visible

	array_levels = array_levels or {}
	array_visible_levels = array_visible_levels or {}

	for id, level in pairs(array_levels) do
		if not array_visible_levels["level_"..id] then
			table.insert(result, id)
		end
	end

	-- Если нет айдишников, значит все просмотрены
	all_visible = #result < 1

	return result, all_visible
end

return M